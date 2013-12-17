local st = {}
local gui = require 'Quickie'

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

local function title_img()
	steps = 4
	for i = 1,steps do
		local s = i / steps
		local o = (1 - math.sqrt(s)) * 180 * (math.sin(t*.2*math.pi) * .2 + 1)
		love.graphics.setColor(255,255,255,255*s*s*s)
		love.graphics.draw(Image.title, -o/2,-o/2, 0, (WIDTH+o)/WIDTH, (HEIGHT+o)/HEIGHT)
	end
end

local function background()
	local x = triangle_osc(t/10) * WIDTH/2 - WIDTH/2
	love.graphics.draw(Image.background, x,0, 0,2,1)
	title_img()
end

function st:update(dt)
	t = t + dt
end

function st:draw()
	background()
	love.graphics.setFont(Font.Flashit[90])
	printfcool('The Coolest Kids on the Block', 30)
	love.graphics.setColor(20,16,10,220)
	love.graphics.rectangle('fill', 0,0, WIDTH, HEIGHT)

	love.graphics.setFont(Font.Flashit[90])
	printfcool('CREDITS', 40)

	love.graphics.setColor(255,255,255)
	love.graphics.setFont(Font.slkscr[30])
	love.graphics.printf([['The Coolest Kids on The Block'

Created in 48 hours for the 28th Ludum Dare

Made by vrld (vrld.org)
using the freshest L:OVE (love2d.org)

Awesome Fonts:
`Flashit' by `Pizzadude' (1001freefonts.com)
`silkscreen' by Jason Kotte (kotte.org)]], 0, HEIGHT/2-160, WIDTH, 'center')

	gui.core.draw()
end

function st:update(dt)
	gui.group.push{grow = 'right', pos = {WIDTH/2-125,HEIGHT-80}, size={250,50}}
	love.graphics.setFont(Font.Flashit[40])
	if gui.Button{text = 'Back'} then
		GS.pop()
	end
	gui.group.pop{}
end

return st
