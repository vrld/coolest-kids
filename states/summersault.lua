local st = {}

local messages = {}
local function say(msg, dx, dy, r,g,b,a)
	messages[msg] = {dx = dx or 0, dy = dy or -10, dt = 2, color = {r or 255,g or 255,b or 255,a or 255}}
end

local height, anim, clouds, sky = {}, {}, {}
function st:init()
	height.bottom = Image.house_bottom:getHeight() * 2
	height.middle = Image.house_middle:getHeight() * 2
	height.top    = Image.house_top:getHeight() * 2

	anim.stand = {
		love.graphics.newQuad( 0,0, 32,32, 192,32),
	}
	anim.jump = {
		love.graphics.newQuad( 0,0, 32,32, 192,32),
		love.graphics.newQuad(32,0, 32,32, 192,32),
		love.graphics.newQuad(64,0, 32,32, 192,32),
	}
	anim.fly  = {
		love.graphics.newQuad( 96,0, 32,32, 192,32),
		love.graphics.newQuad(128,0, 32,32, 192,32),
	}
	anim.land = {
		love.graphics.newQuad(160,0, 32,32, 192,32),
	}

	sky = love.graphics.newQuad(0,0,1,1,1,1)

	clouds = {x = -7200, q = love.graphics.newQuad(0,0,800*10,200,800,200)}
	Image.clouds:setWrap('repeat', 'repeat')
end

local timer, cam, may_jump, flying, player, blood, won, lost, show_skip
function st:enter(prev)
	timer = Timer.new()
	cam = camera()
	cam:move(200, height.top + height.middle*2 + height.bottom - HEIGHT)

	may_jump, flying = false, false
	if prev ~= st then
		timer:tween(5, cam, {y = 0}, 'in-out-quint', function()
			may_jump = true
		end)
	else
		Sound.static.woosh:play()
		show_skip = true
		timer:tween(.5, cam, {y = 0}, 'in-out-quint', function()
			may_jump = true
		end)
	end

	anim.current = anim.stand
	anim.frame = 1
	anim.dt = 0

	player = {x = WIDTH-103, y = -20, rot = 0, rotvel = 0}

	love.graphics.setFont(Font[30])

	blood = {sb = love.graphics.newSpriteBatch(Image.blood, 512)}
	for i = 1,512 do
		local phi, v = (love.math.random() - .5) * math.pi * .3, love.math.random() * 190 + 20
		v = v * math.abs(1 - phi)^1.2
		local r,s = love.math.random()*math.pi, love.math.random()*.4+.8
		local x,y = love.math.random()*5-10, 0
		blood[i] = {
			pos = vector(x,y), v = vector(math.sin(phi), -math.cos(phi)) * v, r=r,s=s,
			id = blood.sb:add(x, y, r,s,s, 2.5,2.5)
		}
	end
	clouds.x = -7200

	won, lost = false, false
end

function st:draw()
	local cam_y = cam.y
	cam.y = math.floor(cam.y)
	cam:attach()
	love.graphics.setBackgroundColor(51,102,255)
	love.graphics.draw(Image.sky, sky, 0,0,0, WIDTH*2, height.top+height.middle*2+height.bottom)
	love.graphics.setColor(255,255,255)
	love.graphics.draw(Image.sun, 200,-300)
	love.graphics.draw(Image.clouds, clouds.q, clouds.x, -100, .1, 1.3,1)
	love.graphics.draw(Image.pavement,             0, height.top+height.middle*2+height.bottom-200, 0,2,2)
	love.graphics.draw(Image.house_bottom, WIDTH-200, height.top+height.middle*2, 0,2,2)
	love.graphics.draw(Image.house_middle, WIDTH-200, height.top+height.middle, 0,2,2)
	love.graphics.draw(Image.house_middle, WIDTH-200, height.top, 0,2,2)
	love.graphics.draw(Image.house_top,    WIDTH-200, 0, 0,2,2)

	love.graphics.draw(Image.jump, anim.current[anim.frame], player.x, player.y, player.rot, 2,2, 16,16)
	if may_jump then
		love.graphics.print('[space]', WIDTH-180,-120)
	end

	for str,m in pairs(messages) do
		love.graphics.setColor(m.color)
		love.graphics.print(str, player.x + m.dx, player.y + m.dy)
	end

	love.graphics.print(player.trot or '', player.x -100, player.y - 100)

	if blood.splash then
		love.graphics.setColor(255,255,255)
		love.graphics.draw(blood.sb, player.x,player.y+2)
	end
	cam:detach()
	cam.y = cam_y

	if lost then
		love.graphics.print('[r] to retry', 10,HEIGHT-80)
		if show_skip then
			love.graphics.print('[s] to skip', 10,HEIGHT-50)
		end
	end
end

function st:update(dt)
	if blood.splash then
		for _,b in ipairs(blood) do
			b.v.y = b.v.y + 320 * dt / 2
			b.pos = b.pos + b.v * dt
			b.v.y = b.v.y + 320 * dt / 2
			if b.pos.y < 0 then
				blood.sb:set(b.id, b.pos.x, b.pos.y, b.r, b.s,b.s, 2.5,2.5)
			end
		end
	end
	clouds.x = clouds.x + dt*5
	anim.dt = anim.dt + dt
	if anim.dt > .2 then
		anim.dt = anim.dt - .2
		anim.frame = anim.frame % #anim.current + 1
	end

	for str,m in pairs(messages) do
		m.dt = m.dt - dt
		if m.dt <= 0 then
			messages[str] = nil
		end
	end

	if flying then
		cam.y = math.min(math.max(cam.y, player.y-100), height.top+height.middle*2+height.bottom-HEIGHT/2)
		if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
			player.rotvel = player.rotvel - .02
		elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
			player.rotvel = player.rotvel + .02
		end

		player.rot = player.rot + player.rotvel * dt
	end

	timer:update(dt)
end

function st:keypressed(key)
	if may_jump and key == ' ' then
		Sound.static.wind:play()
		Sound.static.wind:setPitch(1.2)
		local woosh = Sound.static.woosh:play()
		woosh:setPitch(.4)
		may_jump = false
		say('[arrows] [a] [d]', -80, -80, 255,255,255)
		anim.current = anim.jump
		timer:tween(2.8, player, {x = player.x - 280}, 'out-quad')
		timer:tween(.3, player, {y = player.y - 20}, 'in-out-quad', function()
			anim.current, anim.frame, flying = anim.fly, 1, true
			--timer:add(2.3, function()
			--	Sound.static.land:play()
			--	local rot = (player.rot - math.pi/2) % (2 * math.pi)
			--	if math.abs(player.rotvel) >= 3 or (rot >= .35 and rot <= 2*math.pi-.35) then
			--		Sound.static.splatter:play()
			--	end
			--end)
			timer:tween(2.5, player, {y = height.top+height.middle*2+height.bottom-32}, 'quad', function()
				Sound.static.land:play()
				anim.current, anim.frame, flying = anim.land, 1, false
				if math.abs(player.rot) > 4 then
					won = true
				end
				player.rot = player.rot - math.pi/2
				player.rot = player.rot % (2 * math.pi)

				if math.abs(player.rotvel) < 3 and (player.rot < .3 or player.rot > 2*math.pi-.3) then
					player.rot = 0
				else
					Sound.static.splatter:play()
					player.rot = math.pi/2 * (-player.rot / math.abs(player.rot))
					blood.splash = true
					timer:tween(.1, player, {y = player.y + 30})
					won = false
				end

				if won then
					timer:add(.3, function() Sound.static.tadaaa:play() end)
					timer:add(2.5, function() GS.transition(State.socool) end)
				end
				lost = not won
			end)
		end)
	end

	if lost and key == 'r' then
		GS.switch(State.summersault)
	end

	if (lost and key == 's') or (won and key == ' ') then
		GS.transition(State.socool)
	end
end

return st
