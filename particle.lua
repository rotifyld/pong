local Particle = {}
Particle.__index = Particle

setmetatable(Particle, { __call = function(_, ...) return Particle.new(...) end })

function Particle.new(pos, v, speed, b)
	local self = setmetatable({}, Particle)
	self.pos = {}
	self.pos.x = pos.x
	self.pos.y = pos.y
	self.v = {}
	if b then -- numbers in next 5 lines were chosen by trial-and-error
		self.v.x = (v.x * 1.3 + love.math.random() - 0.5)
		self.v.y = (v.y * 1.3 + love.math.random() - 0.5)
	else 
		self.v.x = (v.x * 0.7 + love.math.random() * 0.2 - 0.1)
		self.v.y = (v.y * 0.7 + love.math.random() * 0.2 - 0.1)
	end
	-- picking random shape and color
	self.shape = love.math.random(6) + 1
	self.rgba = {1, 1, 1, 0.4}
	local color = love.math.random(3)
	self.rgba[color] = 0
	self.r = love.math.random(4) + 2

	self.timer = {}
	self.timer.max = love.math.random() * 0.5 + 0.5
	self.timer.left = self.timer.max
	self.speed = speed

	return self
end

function Particle:move(dt)
	-- lifespan countdown
	print("NEW particle: timer.max = " .. self.timer.max  --[[.." timer.left = " .. self.timer.left]])
	self.timer.left = self.timer.left - dt
	if self.timer.left < 0 then return true end

	self.pos.x = self.pos.x + dt * self.v.x * self.speed * (self.timer.left / self.timer.max)
	self.pos.y = self.pos.y + dt * self.v.y * self.speed * (self.timer.left / self.timer.max)
end

function Particle:draw()
	love.graphics.setColor(self.rgba)
	if self.shape == 2 then
		love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
	else
		love.graphics.circle("fill", self.pos.x, self.pos.y, self.r, self.shape)
	end
end



return Particle