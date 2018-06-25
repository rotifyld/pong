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
end


function love.conf(t)
	t.identity = "save"
	t.console = true
end

function love.load()

	canvas = {margin = 50, x = love.graphics.getWidth(), y = love.graphics.getHeight()}
	powerUpProb = 0.7 --0.2
	mainFont = love.graphics.newFont("now_light.ttf", 30)
	
	local Player = require("player")
	Ball = require("ball")
	PowerUp = require("powerUp")
	Particle = require("particle")
	
	playerLeft = Player("w", "s", 50, {175/255, 238/255, 238/255, 1})
	playerRight = Player("up", "down", canvas.x - 50, {1, 192/255, 203/255, 1})

	balls = {}
	powerUps = {}
	score = {}

	newRound(nil)
end

-- reset game
function love.keypressed(k)
	if k == "r" then newRound(nil) end

	if k == "0" then love.graphics.captureScreenshot("screenshot.png") end
end

function love.update(dt)

	-- reset Game
--	if love.keyboard.isDown("r") then newRound(nil)	end

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
end