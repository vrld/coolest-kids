local HC = require 'HardonCollider'

local st = {}

local timer, collider, player, foes, beerzone, won, lost
function st:enter(prev)
	timer = Timer.new()
	collider = HC(100, function(_,a,b, dx,dy)
		if a ~= player then
			a,b,dx,dy = b,a, -dx,-dy
		end
		if a ~= player then return end
		if b.is_rack then
			a:move(dx,dy)
		elseif b.is_beer_zone then
			player.has_beer = true
		else
			-- set alarmed(b)
			if player.has_beer then
				-- lost
			end
		end
	end)
	won, lost = false, false

	local shape
	for _,triangle in pairs(love.math.triangulate(
		  0,440,  50,434,  52,258,  50,44,  200,58,  362,53,  664,52,
		761,58,  748,174, 754,312, 752,431, 800,434, 800,0,   0,0)) do
		shape = collider:addPolygon(unpack(triangle))
		shape.is_rack = true
		collider:setPassive(shape)
	end

	for _,triangle in pairs(love.math.triangulate(
		148,257, 158,420, 320,410, 468,414, 470,373, 314,365, 209,367, 211,256)) do
		shape = collider:addPolygon(unpack(triangle))
		shape.is_rack = true
		collider:setPassive(shape)
	end

	for _,triangle in pairs(love.math.triangulate(
		125,131, 238,121, 316,131, 431,116, 658,126, 660,194, 674,226, 662,438,
		603,430, 602,368, 596,336, 604,266, 606,190, 502,180, 380,173, 238,167,
		126, 184)) do
		shape = collider:addPolygon(unpack(triangle))
		shape.is_rack = true
		collider:setPassive(shape)
	end

	for _,triangle in pairs(love.math.triangulate(
		100,488, 304,487, 320,600, 246,600, 233,544, 110,546)) do
		shape = collider:addPolygon(unpack(triangle))
		shape.is_rack = true
		collider:setPassive(shape)
	end

	shape = collider:addPolygon(328,261, 491,268, 488,300, 334,297)
	collider:setPassive(shape)

	shape = collider:addPolygon(328,261, 491,268, 488,300, 334,297)
	collider:setPassive(shape)

	beerzone = collider:addRectangle(360,60, 520-360, 30)
	collider:setPassive(beerzone)
	beerzone.is_beer_zone = true

	player = collider:addCircle(700,500, 12)
	player.v = vector(0,0)
	player.rot = 0
	player.quad = {
		love.graphics.newQuad( 0,0, 32,32, 96,64),
		love.graphics.newQuad(32,0, 32,32, 96,64),
		love.graphics.newQuad(64,0, 32,32, 96,64),
		love.graphics.newQuad(32,0, 32,32, 96,64),

		love.graphics.newQuad( 0,32, 32,32, 96,64),
		love.graphics.newQuad(32,32, 32,32, 96,64),
		love.graphics.newQuad(64,32, 32,32, 96,64),
		love.graphics.newQuad(32,32, 32,32, 96,64),
		dt = 0, frametime = .2,
	}
	player.frame = 2

	foes = {
		cashier  = collider:addCircle(192,572, 20),
		guard    = collider:addCircle(98,442, 24),
		customer = collider:addCircle(166,226, 24),
	}
	for name, s in pairs(foes) do
		s.is_foe = true
		local cx,cy = s:center()
		local bonus = name == 'cashier' and 20 or 0
		local cone = collider:addPolygon(cx,cy, cx-30,cy+120+bonus, cx+30,cy+120+bonus)
		local move, rotate = s.move, s.rotate
		s.cone = cone
		function s.move(s, ...)
			move(s, ...)
			cone:move(...)
		end
		function s.rotate(s, r)
			rotate(s, r)
			cone:rotate(r, s:center())
		end
	end

	foes.cashier:rotate(math.pi)
	foes.cashier.rmul = .5
	function foes.cashier:tick(dt)
		if math.abs(self:rotation() - math.pi) > 1 then
			self.rmul = self.rmul * -1
		end
		self:rotate(self.rmul * dt)
	end

	function foes.guard:tick(dt)
	end

	function foes.customer:tick(dt)
	end

	-- guard route
	--   {{98,442}, {94,92}, {705,91}, {706,486}, {315,451}}
	-- customer route
	--   {{116,226, 545,296, 539,366, 480,332, 250,311, 259,222}}
end

function st:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(Image.shop)

--	for s in pairs(collider:shapesInRange(0,0,800,600)) do
--		s:draw('line')
--	end

	love.graphics.setColor(255,255,180,150)
	beerzone:draw('fill')

	for name, f in pairs(foes) do
		love.graphics.setColor(255,255,180,150)
		f.cone:draw('fill')
		love.graphics.setColor(255,255,255)
		f:draw('fill')
	end

	local cx,cy = player:center()
	love.graphics.draw(Image.walk, player.quad[player.frame], cx,cy, player.rot,1,1, 16,16)

	if lost then
		love.graphics.print('[r] to retry', 10,HEIGHT-80)
		if show_skip then
			love.graphics.print('[s] to skip', 10,HEIGHT-50)
		end
	end
end

local acc = vector()
function st:update(dt)
	timer:update(dt)
	player.quad.dt = player.quad.dt + dt
	if player.quad.dt >= player.quad.frametime then
		player.quad.dt = player.quad.dt - player.quad.frametime
		player.frame = player.frame % (#player.quad / 2) + 1
		if player.has_beer then player.frame = player.frame + 4 end
	end

	acc.x, acc.y = 0,0
	if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
		player.rot = player.rot - dt * 5
	elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
		player.rot = player.rot + dt * 5
	end

	if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
		acc.y = -1
	elseif love.keyboard.isDown('s') or love.keyboard.isDown('down') then
		acc.y = 1
	else
		player.dt = 0
		player.frame = 2
		if player.has_beer then player.frame = player.frame + 4 end
	end

	acc:rotate_inplace(player.rot)
	player.v = 70 * acc + player.v * 100 * dt
	player:move((player.v * dt):unpack())

	for _,s in pairs(foes) do
		s:tick(dt)
	end

	collider:update(dt)
end

function st:keypressed(key)
	if lost and key == 'r' then
		GS.switch(State.beer)
	end

	if (lost and key == 's') or (won and key == ' ') then
		GS.transition(State.socool)
	end
end

return st
