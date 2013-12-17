local st = {}

local t = 0

function st:enter(pre)
	self.pre = pre
	self.ignore_keypress = true
end

local function printfcool(s, y, o)
	o = o or 5
	local ox,oy = math.sin(t*.5*math.pi) * o, math.cos(t*.5*math.pi) * o
	love.graphics.setColor(255,255,255)
	love.graphics.printf(s, -ox, y-oy, WIDTH, 'center')

	love.graphics.setColor(0,0,0)
	love.graphics.printf(s,  ox, y+oy, WIDTH, 'center')

	love.graphics.setColor(153,255,0)
	love.graphics.printf(s,  0, y, WIDTH, 'center')
end

function st:update(dt)
	t = t + dt
end

function st:draw()
	self.pre:draw()
	love.graphics.setColor(20,16,10,190)
	love.graphics.rectangle('fill', 0,0, WIDTH, HEIGHT)

	love.graphics.setFont(Font.Flashit[90])
	printfcool('PAUSE', HEIGHT/2-60)

	love.graphics.setColor(255,255,255)
	love.graphics.setFont(Font[20])
	love.graphics.printf([[[Escape] to quit.
Any other key to resume.]], 0, HEIGHT/2+60, WIDTH, 'center')
end

function st:keypressed(key)
	if self.ignore_keypress then
		self.ignore_keypress = nil
		return
	end

	if key == 'escape' then
		love.event.push('quit')
	else
		GS.pop()
	end
end

return st
