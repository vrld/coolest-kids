local st = {}

local time, bottle, parcour, failed, won
function st:enter(prev)
	time, failed, won = 0, 0, false

	bottle = {
		x = 695, y = 55,
		grabbed = false,
		rot = 0
	}

	parcour = love.image.newImageData('img/parcour_only.png')

	Sound.stream.loocos:setLooping(true)
	self.snd = Sound.stream.loocos:play()
	self.snd:setVolume(1)
end

function st:leave()
	local tfade, fade_time = 0, 1.2
	Timer.do_for(fade_time, function(dt)
		tfade = tfade + dt
		self.snd:setVolume(1 * (1-tfade/fade_time))
	end, function()
		Sound.stream.loocos:stop()
	end)
end

function st:draw()
	love.graphics.setBackgroundColor(0,0,100)
	love.graphics.setColor(255,255,255)
	love.graphics.draw(Image.parcour)

	if failed > 1 then
		love.graphics.print('[s] to skip', 5,5)
	end

	love.graphics.draw(Image.bottle, bottle.x, bottle.y, bottle.rot,2,2, 8,20)
end

function st:update(dt)
	if bottle.grabbed then
		bottle.x, bottle.y = love.mouse.getPosition()
		love.mouse.setVisible(false)
		bottle.rot = math.sin(time * 3 * math.pi) * math.pi * .2
		time = time + dt
	else
		love.mouse.setVisible(true)
	end

	if bottle.x >= 61 and bottle.x <= 86 and bottle.y >= 580 then
		GS.transition(State.socool)
		if not won then
			won = true
			Sound.static.tadaaa:play()
		end
	elseif bottle.grabbed then
		local _,_,_,a = parcour:getPixel(bottle.x, bottle.y)
		if a == 0 then
			bottle.grabbed = false
			Sound.static.glass:play()
			Timer.add(.2, function()
				failed = failed + 1
				bottle.x, bottle.y = 695, 55
			end)
		end
	end
end

function st:mousepressed(x,y)
	local d = vector(x,y):dist(vector(bottle.x, bottle.y))
	if d <= 20 then
		bottle.grabbed = true
	end
end

function st:mousereleased()
	bottle.grabbed = false
end

function st:keypressed(key)
	if key == 's' then
		GS.transition(State.socool)
	end
end

return st
