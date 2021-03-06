Timer  = require 'hump.timer'
GS     = require 'hump.gamestate'
camera = require 'hump.camera'
vector = require 'hump.vector'
require 'slam'

function triangle_osc(t)
	return 2 * math.abs(2*((t+.25)%1) - 1) - 1
end

function GS.transition(to, length, ...)
	length = length or 1

	local fade_color, t = {7,5,8,0}, 0
	local draw, update, switch, transition = GS.draw, GS.update, GS.switch, GS.transition
	GS.draw = function()
		draw()
		color = {love.graphics.getColor()}
		love.graphics.setColor(fade_color)
		love.graphics.rectangle('fill', 0,0, WIDTH, HEIGHT)
		love.graphics.setColor(color)
	end
	GS.update = function(dt)
		update(dt)
		t = t + dt
		local s = t/length
		fade_color[4] = math.min(255, math.max(0, s < .5 and 2*s*255 or (2 - 2*s) * 255))
	end
	-- disable switching states while in transition
	GS.switch = function() end
	GS.transition = function() end

	local args = {...}
	Timer.add(length / 2, function() switch(to, unpack(args)) end)
	Timer.add(length, function()
		GS.draw, GS.update, GS.switch, GS.transition = draw, update, switch, transition
	end)
end

-- minimum frame rate
local up = GS.update
GS.update = function(dt)
	if love.keyboard.isDown('1') then dt = dt / 10 end
	return up(math.min(dt, 1/30))
end

local function Proxy(f)
	return setmetatable({}, {__index = function(t,k)
		local v = f(k)
		t[k] = v
		return v
	end})
end

State = Proxy(function(path) return require('states.' .. path) end)
Image = Proxy(function(path)
	local i = love.graphics.newImage('img/'..path..'.png')
	i:setFilter('nearest', 'nearest')
	return i
end)
Font  = Proxy(function(arg)
	if tonumber(arg) then
		return love.graphics.newFont('font/slkscr.ttf', arg)
	end
	return Proxy(function(size) return love.graphics.newFont('font/'..arg..'.ttf', size) end)
end)
Sound = {
	static = Proxy(function(path) return love.audio.newSource('snd/'..path..'.ogg', 'static') end),
	stream = Proxy(function(path) return love.audio.newSource('snd/'..path..'.ogg', 'stream') end)
}
Entities = Proxy(function(path) return require('entities.' .. path) end)

function love.load()
	WIDTH, HEIGHT = love.window.getWidth(), love.window.getHeight()

	GS.registerEvents()
	-- RELEASE
	GS.switch(State.splash)

	-- TEST
	--GS.switch(State.menu)
	--GS.switch(State.socool)
	--GS.switch(State.summersault)
	--GS.switch(State.trousers)
	--GS.switch(State.beer)
end

function love.update(dt)
	Timer.update(dt)
end

function love.keypressed(key)
	if (key == 'escape' or key == 'p') and GS.current() ~= State.pause then
		GS.push(State.pause)
	end
end
