local Ball = {}
Ball.__index = Ball

setmetatable(Ball, { __call = function(_, ...) return Ball.new(...) end })

particlesProb = 0.05

function Ball.new(x, y, dirPhi)
	local self = setmetatable({}, Ball)
	self.pos = {}
	self.pos.x = x
	self.pos.y = y
	self.v = {x = math.cos(dirPhi), y = math.sin(dirPhi)}
	self.r = 9
	self.speed = 400
	self.rgba = {0, 0, 0, 1}
	self.shape = love.math.random(6) + 1
	self.particles = {}
	return self
end

function Ball:move(dt)

	-- collision w/ playerLeft
	if self.pos.x - self.r < playerLeft.pos.x + playerLeft.size.curr.x then
		if self.pos.x - self.r > playerLeft.pos.x - dt * self.speed and self.pos.y > playerLeft.pos.y - playerLeft.size.curr.y and self.pos.y < playerLeft.pos.y + playerLeft.size.curr.y then
			currentPhi = math.asin(self.v.y / 1)
			touchPhi = (self.pos.y - playerLeft.pos.y) / (playerLeft.size.curr.y) * maxPhi

			phi = median(-1 * maxPhi, currentPhi + touchPhi, maxPhi)
			self.v.x = math.cos(phi)
			self.v.y = math.sin(phi)

			-- generate particles
			local n = love.math.random(4) + 5
			for i = 1, n, 1 do table.insert(self.particles, Particle(self.pos, self.v, self.speed, true)) end
		elseif self.pos.x < 0 then
			return("right")
		end
	end

	-- collision w/ playerRight
	if self.pos.x + self.r > playerRight.pos.x - playerRight.size.curr.x then
		if self.pos.x + self.r < playerRight.pos.x + dt * self.speed and self.pos.y > playerRight.pos.y - playerRight.size.curr.y and self.pos.y < playerRight.pos.y + playerRight.size.curr.y then
			currentPhi = math.asin(self.v.y / 1)
			touchPhi = (self.pos.y - playerRight.pos.y) / (playerRight.size.curr.y) * maxPhi

			phi = median(-1 * maxPhi, currentPhi + touchPhi, maxPhi)
			self.v.x = -1 * math.cos(phi)
			self.v.y = math.sin(phi)

			-- generate particles
			local n = love.math.random(4) + 4
			for i = 1, n, 1 do table.insert(self.particles, Particle(self.pos, self.v, self.speed, true)) end
		elseif self.pos.x > canvas.x then
			return("left")
		end
	end

	-- collision w/ margin
	if self.pos.y - self.r < canvas.margin and self.v.y < 0
		or self.pos.y + self.r > canvas.y - canvas.margin and self.v.y > 0 then
		self.v.y = (-1) * self.v.y
	end

	-- if ball is moving too vertically - slowly skew its movement
	if math.abs(self.v.y) > math.abs(self.v.x) then
		local q = dt * 0.1
		if self.v.y > 0 then
			self.v.y = self.v.y - q
		else
			self.v.y = self.v.y + q
		end
		if self.v.x > 0 then
			self.v.x = self.v.x + q
		else
			self.v.x = self.v.x - q
		end
	end

	-- move
	self.pos.x = self.pos.x + dt * self.v.x * self.speed
	self.pos.y = self.pos.y + dt * self.v.y * self.speed

	-- add new particles
	if love.math.random() < particlesProb then table.insert(self.particles, Particle(self.pos, self.v, self.speed, false)) end

	-- move particles
	for i, p in pairs(self.particles) do
		if p:move(dt) then table.remove(self.particles, i) end
	end
end


function Ball:draw()
	-- draw particles
	for _, p in pairs(self.particles) do p:draw() end

	-- draw ball
	love.graphics.setColor(1, 1, 1, 1)
	if self.shape == 2 then
		love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
		love.graphics.setColor(self.rgba)
		love.graphics.circle("line", self.pos.x, self.pos.y, self.r)
	else
		love.graphics.circle("fill", self.pos.x, self.pos.y, self.r, self.shape)
		love.graphics.setColor(self.rgba)
		love.graphics.circle("line", self.pos.x, self.pos.y, self.r, self.shape)
	end
end

function Ball:dir()
	if self.v.x > 0 then return "right" else return "left" end
end

maxPhi = math.pi * 0.25

function Ball:generateBalls(n)
	local balls = {}
	local dir = 0
	local phi = math.asin(self.v.y)

	for i = 1, n, 1 do
		local currPhi = dir +  phi + (love.math.random() / 0.6) - 0.3
		dir = dir + math.pi -- eventually improve for big n
		table.insert(balls, Ball(self.pos.x, self.pos.y, currPhi))
	end
	return balls
end

function median(a, b, c)
	return math.max(math.min(a,b), math.min(math.max(a,b),c))
end


return Ball
