local st = {}

local str, sequence, tw, delta_text

function typewriter(text)
	str = ''
	local co = coroutine.wrap(function()
		for c in text:gmatch('.') do
			str = str .. c
			local dt = math.random() * .07 + .08
			if c == '\n' then
				dt = dt + .1
			end
			if c == '\n' or c:match('%S') then
				if coroutine.yield(dt, true) then
					str = text
					coroutine.yield(0, true)
					break
				end
			end
		end
		while true do
			coroutine.yield(0, false)
		end
	end)

	return co
end

function st:enter(prev)
	if prev == State.summersault then
		sequence = {
			'DUDE! Did you just see that? That was aw...\n...\nPfft, I could have done that. But I dont want to!',
			'What? Nah man, you still have to prove yourself.\nThat jump was just an entry test.',
			'Let\'s see. Oh, I know.\nYou know the L-Mart on third street?',
			'Yeah, go get us a beer!\nWhat are you waiting for?',
			next_state = State.beer
		}
	else
		sequence = {
			'... in her face! HA HA HA!\n...\nWhat do you want, youngen?',
			'Ha, you want one of these?\nSorry youngen.\nYou only get one if you\'re one of us.',
			'What? You think you\'re as cool as we are? Prove it, then.',
			'How? Uhm...\nDo a summersault.',
			'Wha..? How...?\n No, not here you idiot.\nDo it from the roof!',
			next_state = State.summersault
		}
	end
	str, tw = '', typewriter(sequence[1])
	delta_text = 0
end

local t = 0
function st:update(dt)
	t = t + dt
	delta_text = delta_text - dt
	if delta_text < 0 then
		-- TODO: play sound
		delta_text = tw()
	end
end

function st:draw()
	love.graphics.setColor(255,255,255)
	local x = triangle_osc(t/10) * WIDTH/2 - WIDTH/2
	love.graphics.draw(Image.background, x,0, 0,2,1)
	love.graphics.draw(Image.title)

	local s = 1.2
	love.graphics.draw(Image.thetoken, 360,275, math.sin(2*t*math.pi*.2)*.02, s,s, 7,3)
	love.graphics.draw(Image.thetoken, 255,370, math.sin(2*t*math.pi*.22+.12)*.02, s,s, 7,3)
	love.graphics.draw(Image.thetoken, 350,360, math.sin(2*t*math.pi*.19+.42)*.02, s,s, 7,3)
	love.graphics.draw(Image.thetoken, 550,340, math.sin(2*t*math.pi*.21-.2)*.02, s,s, 7,3)
	love.graphics.draw(Image.thetoken, 348,512, math.sin(2*t*math.pi*.18-.82)*.02, s,s, 7,3)

	love.graphics.setColor(0,0,0,120)
	love.graphics.rectangle('fill', 5,HEIGHT-120, WIDTH-10, 115)

	love.graphics.setColor(255,255,255)
	love.graphics.setFont(Font[30])
	love.graphics.printf(str, 10,HEIGHT-115, WIDTH-20, 'left')
end

local function nextmsg()
		local _, running = tw(true)
		if not running then
			table.remove(sequence, 1)
			if #sequence > 0 then
				tw = typewriter(sequence[1])
			else
				GS.switch(sequence.next_state)
			end
		end
end

function st:keypressed(key)
	if key == 'return' or key == ' ' then
		nextmsg()
	end
end

function st:mousepressed()
	nextmsg()
end

return st
