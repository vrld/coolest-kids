local st = {}

local may_jump, flying, player, blood, won, lost, show_skip
function st:enter(prev)
	self.timer = Timer.new()
	won, lost = false, false
end

function st:draw()
	love.graphics.printf('THIS SPACE INTENTIONALLY LEFT BLANK', 0,HEIGHT/2,WIDTH, 'center')
	if lost then
		love.graphics.print('[r] to retry', 10,HEIGHT-80)
		if show_skip then
			love.graphics.print('[s] to skip', 10,HEIGHT-50)
		end
	end
end

function st:update(dt)
	self.timer:update(dt)
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
