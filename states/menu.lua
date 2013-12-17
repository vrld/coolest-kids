local gui = require 'Quickie'

local st = {}

local steps, t, effect
function st:init()
	--[===[if love.graphics.isSupported('canvas', 'shader') then
		effect = {
			buffer1 = love.graphics.newCanvas(),
			buffer2 = love.graphics.newCanvas(),
			shader = love.graphics.newShader[[
				extern vec2 direction;
				vec4 effect(vec4 color, Image tex, vec2 tc, vec2 _)
				{
					return  Texel(tex, tc) * .5
					      + Texel(tex, tc - direction) * .15
					      + Texel(tex, tc - direction * 2.) * .15
					      + Texel(tex, tc - direction * 3.) * .15
					      + Texel(tex, tc + direction) * .15
					      + Texel(tex, tc + direction * 2.) * .15
					      + Texel(tex, tc + direction * 3.) * .15;
				}
			]]
		}
	end--]===]
	gui.core.style.gradient:set(255,255)

	gui.core.style.color.normal.bg = {0,0,0, 80}
	gui.core.style.color.hot.bg    = {0,0,0,180}
	gui.core.style.color.active.bg = {0,0,0,180}

	gui.core.style.color.normal.fg = {255,255,255}
	gui.core.style.color.hot.fg    = {153,255,0}
	gui.core.style.color.active.fg = {255,100,32}

	gui.core.style.color.normal.border = {0,0,0,0}
	gui.core.style.color.hot.border = {0,0,0,0}
	gui.core.style.color.active.border = {0,0,0,0}

	gui.keyboard.disable()
end

function st:enter()
	steps, t = 4,0
end

function st:update(dt)
	t = t + dt
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

function st:draw()
	if effect then
		effect.buffer1:renderTo(background)
		love.graphics.setShader(effect.shader)
		effect.shader:send('direction', {1/WIDTH,0})
		effect.buffer2:renderTo(function()
			love.graphics.draw(effect.buffer1)
		end)

		effect.shader:send('direction', {0,.5/HEIGHT})
		love.graphics.draw(effect.buffer2)
		love.graphics.setShader()
	else
		background()
	end

	love.graphics.setFont(Font.Flashit[90])
	printfcool('The Coolest Kids on the Block', 90)

	gui.core.draw()
end

function st:update(dt)
	gui.group.push{grow = 'right', pos = {20,HEIGHT-100}, size={250,50}}
	love.graphics.setFont(Font.Flashit[40])
	if gui.Button{text = 'Start'} then
		GS.switch(State.socool)
	end
	if gui.Button{text = 'Credits'} then
		GS.push(State.credits)
	end
	if gui.Button{text = 'Exit'} then
		love.event.push('quit')
	end
	gui.group.pop{}
end

return st
