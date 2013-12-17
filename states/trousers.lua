local st_main, st_prepull, st_drag = {}, {}, {}

local intense, more_intense = Sound.static.intense, Sound.static.more_intense
function st_main:enter(pre, fadeout)
	self.pre = nil
	if fadeout then
		self.pre = pre
		Timer.add(2, function() GS.transition(State.socool) end)
	else
		intense:setLooping(true)
		intense:play()
	end
end

function st_main:leave()
	intense:stop()
end

function st_main:draw()
	if self.pre then
		self.pre:draw()
		return
	end
	love.graphics.setColor(255,255,255)
	love.graphics.draw(Image.cop)
	love.graphics.printf('Use the mouse', 0,30, WIDTH, 'center')
end

function st_main:mousepressed()
	if self.pre then return end
	GS.switch(st_prepull)
end

function st_prepull:enter()
	more_intense:setLooping(true)
	more_intense:play()
end

function st_prepull:leave()
	more_intense:stop()
end

function st_prepull:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(Image.trousers_on)

	love.graphics.printf('Click and drag down quick', 0,HEIGHT/2-20, WIDTH, 'center')
end

function st_prepull:mousepressed(x,y,btn)
	GS.switch(st_drag, y)
end

function st_drag:enter(pre)
	self.t = 0
	self.mx, self.my = love.mouse.getPosition()
	self.trousers_y = nil
	Sound.static.undress:play()
end

function st_drag:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(Image.trousers_down)

	if self.trousers_y then
		love.graphics.draw(Image.trousers, 0,self.trousers_y)
		if self.trousers_y == 0 then
			love.graphics.printf('[r] to retry\n[s] to skip', 0,HEIGHT/2-20, WIDTH, 'center')
		end
	else
		local _, my = love.mouse.getPosition()
		local dy = math.max(0, my - self.my) * .5
		love.graphics.draw(Image.trousers, 0,dy)
	end
end

function st_drag:update(dt)
	if self.trousers_y then
		self.trousers_y = math.max(0, self.trousers_y + self.trousers_speed * dt)
		self.trousers_speed = self.trousers_speed - dt^.7 * 300
		if self.trousers_y > HEIGHT then
			GS.switch(st_main, true)
			Sound.static.tadaaa:play()
		end
	else
		self.t = self.t + dt
	end
end

function st_drag:mousereleased(_, y)
	if self.trousers_y then return end
	local dy = math.max(0, y - self.my) * .5
	self.trousers_y = dy
	self.trousers_speed = dy / self.t
end

function st_drag:mousefocus(has_focus)
	if not has_focus then
		self:mousereleased(love.mouse.getPosition())
	end
end

function st_drag:keyreleased(key)
	if key == 'r' then GS.switch(st_prepull) end
	if key == 's' then
		GS.switch(st_main, true)
	end
end

return st_main
