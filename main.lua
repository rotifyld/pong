--[[ 23.06.2018 ~ 
author: Dawid Borys
email: dawidborys98@gmail.com

]]
--[[ WIP
 - particles
 - drawing durance of power ups
 - PvC
 - sounds
]]

local function newRound(winner)

	pauseStripesPos = 0
	pauseStripesMax = 30

	playerLeft:reset()
	playerRight:reset()

	if (winner == "left") then
		score.left = score.left + 1
	elseif (winner == "right") then
		score.right = score.right + 1
	else
		score.right = 0
		score.left = 0
	end

	for _, v in pairs(powerUps) do
		if v.state == "collected" then
			v:unexecute()
		end
	end
	powerUps = {}
	balls = {}

	local direction = love.math.random(2) - 1 -- 0 or 1
	print("dir = " .. direction)
	table.insert(balls, Ball(canvas.x / 2, canvas.y / 2, direction * math.pi))

	froze = true
	frozeTime = frozeTimeMax
end


function love.conf(t)
	t.identity = "save"
	t.console = true
end

function love.load()

	canvas = {margin = 50, x = love.graphics.getWidth(), y = love.graphics.getHeight()}
	powerUpProb = 0.4 --0.2

	mainFont = love.graphics.newFont("now_light.ttf", 30)
	smallFont = love.graphics.newFont("now_light.ttf", 15)

	local Player = require("player")
	Ball = require("ball")
	PowerUp = require("powerUp")
	Particle = require("particle")

	playerLeft = Player("w", "s", 50, {175/255, 238/255, 238/255, 1})
	playerRight = Player("up", "down", canvas.x - 50, {1, 192/255, 203/255, 1})

	balls = {}
	powerUps = {}
	score = {}

	frozeTimeMax = 1.5

	newRound(nil)
end

-- reset game
function love.keypressed(k)

	if not paused then
		if k == "r" then newRound(nil) end
	end

	if k == "0" then love.graphics.captureScreenshot("screenshot.png") end

	if k == "p" then paused = not paused end
end

function love.update(dt)

	if paused then
		pauseStripesPos = pauseStripesPos + dt * 100
		if pauseStripesPos > pauseStripesMax then pauseStripesPos = pauseStripesPos - pauseStripesMax end
	elseif froze then
		frozeTime = frozeTime - dt
		if frozeTime < 0 then froze = false end
	else
		-- move balls
		for i, v in pairs(balls) do
			local winner = v:move(dt)
			if winner then
				table.remove(balls, i)
				if next(balls) == nil then
					newRound(winner)
				end
			end
		end

		-- move players
		playerLeft:move(dt)
		playerRight:move(dt)

		-- spawn new power ups
		if love.math.random() < dt * powerUpProb then table.insert(powerUps, PowerUp())	end

		-- operate on power ups
		for i, p in pairs(powerUps) do
			if p:subtract(dt) then
				-- delete a powerUp
				if p.state == "collected" then p:unexecute() end
				table.remove(powerUps, i)
			elseif p.state == "spawned" then
				for _, b in pairs(balls) do
					-- for each ball: check if it's close enough, if so execute a powerUp
					-- todo: not the prettiest one
					local ret = {}
					if p:isCloseEnough(b) then
						if b:dir() == "right" then
							ret = p:execute(b, playerLeft, playerRight)
						else
							ret = p:execute(b, playerRight, playerLeft)
						end
						if ret ~= nil then
							table.remove(powerUps, i)
							for _, b in pairs(ret) do table.insert(balls, b) end
						end
					end
				end
			end
		end

	end
end

function love.draw()
	love.graphics.setBackgroundColor(1, 1, 1)

	-- write score
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(mainFont)
    love.graphics.printf(score.left .. ":" .. score.right, 0, canvas.margin / 3, canvas.x, "center")

	-- draw bgrd lines
	love.graphics.setColor(0.2, 0.2, 0.2)
	love.graphics.line(0, canvas.margin, canvas.x, canvas.margin)
	love.graphics.line(0, canvas.y - canvas.margin, canvas.x, canvas.y - canvas.margin)

	-- draw balls
	for _, v in pairs(balls) do
		v:draw()
	end

	playerLeft:draw()
	playerRight:draw()

	-- draw power ups
	for _, v in pairs(powerUps) do
		v:draw()
	end

	if paused then
		love.graphics.setColor(0, 0, 0, 0.2)
		love.graphics.rectangle("fill", 0, 0, canvas.x, canvas.y)

		local x = (-1) * canvas.y + pauseStripesPos
		while x < canvas.x do
			love.graphics.line(x, 0, x + canvas.y, canvas.y)
			x = x + pauseStripesMax
		end

		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf("g a m e   p a u s e d", 0, canvas.y / 2 - 50, canvas.x, "center")
		love.graphics.setFont(smallFont)
		love.graphics.printf("press P to resume", 0, canvas.y / 2, canvas.x, "center")
	end

	if froze then
		love.graphics.setColor(0, 0, 0, 0.2)
		love.graphics.arc("fill", canvas.x / 2, canvas.y / 2, 200, 3/2 * math.pi, 3/2 * math.pi + (frozeTime/frozeTimeMax) * 2 * math.pi)
	end
end
