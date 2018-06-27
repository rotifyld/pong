local PowerUp = {}
PowerUp.__index = PowerUp

sizeModifier = 1.4
speedModifier = 1.3
colors = {}
colors.trans = {red = {0.5, 0, 0, 0.2}, green = {0, 0.5, 0, 0.2}, blue = {0, 0, 0.5, 0.2}, violet = {0.5, 0, 0.5, 0.2}}

setmetatable(PowerUp, { __call = function(_, ...) return PowerUp.new(...) end })

function PowerUp.new()
	local self = setmetatable({}, PowerUp)
	self.pos = {}
	self.pos.x = love.math.random(150, canvas.x - 150);
	self.pos.y = love.math.random(canvas.margin + 50, canvas.y - canvas.margin - 50);
	self.r = 18 + love.math.random(7) 
	self.state = "spawned"
	self.timerMax = 7 + love.math.random(4)
	self.timer = self.timerMax
	self.type = pickRandomType()
	return self
end

function pickRandomType()
local i = 1 --love.math.random(1, 9)
	if i <= 3 then
		return "green"
	elseif i <= 6 then
		return "red"
	else
		return "blue"
	end
end

function PowerUp:subtract(dt)
	self.timer = self.timer - dt
	if self.timer < 0 then return true end
end

function PowerUp:isCloseEnough(ball)
	return math.sqrt((ball.pos.x - self.pos.x) ^ 2 + (ball.pos.y - self.pos.y) ^ 2) < ball.r + self.r
end

function PowerUp:execute(ball, player, enemy)	-- remove enemy

	if self.type == "blue" then
		self.type = "multiBall"
		self.holder = ball
		n = love.math.random(2) + 2 -- 2 or 3
		return self.holder:generateBalls(n)
	end

	self.state = "collected"
	self.holder = player
	self.timerMax = 10
	self.timer = self.timerMax
	local rand = 8 -- love.math.random(10)
	if self.type == "green" then
		if rand <= 7 then
			self.type = "grow"
			self.holder:changeSize(1, sizeModifier)
		else
			self.type = "speedUp"
			self.holder:changeSpeed(1, speedModifier)
		end
	elseif self.type == "red" then
		if rand <= 7 then
			self.type = "shrink"
			self.holder:changeSize(-1, sizeModifier)
		else
			self.type = "slowDown"
			self.holder:changeSpeed(-1, speedModifier)
		end
	end
end

function PowerUp:unexecute()
	if self.type == "grow" then
		self.holder:changeSize(-1, sizeModifier)
	elseif self.type == "speedUp" then
		self.holder:changeSpeed(-1, speedModifier)
	elseif self.type == "shrink" then
		self.holder:changeSize(1, sizeModifier)
	elseif self.type == "slowDown" then
		self.holder:changeSpeed(1, speedModifier) 
	end
end



function PowerUp:draw()
	if self.state == "spawned" then
		love.graphics.setColor(0.5, 0.5, 0.5)
		love.graphics.setColor(colors.trans[self.type])
		love.graphics.circle("line", self.pos.x, self.pos.y, self.r)
		love.graphics.arc("fill", self.pos.x, self.pos.y, self.r * (5/4), math.pi * 3/2, math.pi * 3/2 + (self.timer / self.timerMax) * 2 * math.pi)
		love.graphics.setColor(1, 1, 1)
		love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
		--love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)			
	else
		--[[local x
		if self.power == "expand" then
			love.graphics.setColor(colors.trans.green)
			if self.holder.pos.x < 300 then x = 50 else x = canvas.x - 50 end
		elseif self.power == "diminish" then
			love.graphics.setColor(colors.trans.red)			
			if self.holder.pos.x < 300 then x = 100 else x = canvas.x - 100 end
		elseif self.power == "reverse" then
			love.graphics.setColor(colors.trans.violet)						
			if self.holder.pos.x < 300 then x = 150 else x = canvas.x - 150 end
		end
		--todo
		love.graphics.arc("fill", x, canvas.margin / 2, 20, math.pi * 3/2, math.pi * 3/2 + (self.timer / self.timerMax) * 2 * math.pi)]]
	end
end

return PowerUp