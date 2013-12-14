local st = {}

local steps, t
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

function st:draw()
	local x = triangle_osc(t/10) * WIDTH/2 - WIDTH/2
	love.graphics.draw(Image.background, x,0, 0,2,1)
	title_img()

	love.graphics.setFont(Font.Flashit[90])
	printfcool('The Coolest Kids on the Block', 80)

	love.graphics.setFont(Font.Flashit[50])
	printfcool('Press Enter', 500, 3)
end

function st:keypressed(key)
	if key == 'return' then
		GS.switch(State.socool)
	end
end

return st
