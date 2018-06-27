local Player = {}
Player.__index = Player

setmetatable(Player, { __call = function(_, ...) return Player.new(...) end })

function Player.new(upKey, downKey, posX, rgba)
	local self = setmetatable({}, Player)
	self.key = {up = upKey, down = downKey}
	self.pos = {x = posX, y = canvas.y / 2}
	self.size = {}
	self.size.base = {x = 5, y = 60} -- y=60
	self.size.curr = {x = self.size.base.x, y = self.size.base.y}
	self.size.modifier = 0
	self.speed = {}
	self.speed.base = 250 -- 300?
	self.speed.curr = self.speed.base
	self.speed.modifier = 0
	self.rgba = rgba
	--[[self.stripes = {}
	self.stripes.pos = 0
	self.stripes.margin = 5
	self.stripes.distance = 10]]
	return self
end

function Player:move(dt)
	local move = 0
	if love.keyboard.isDown(self.key.up) and self.pos.y - self.size.curr.y > 0 then
	    move = move - 1
	end
	if love.keyboard.isDown(self.key.down) and self.pos.y + self.size.curr.y < canvas.y then
	    move = move + 1
	end
	self.pos.y = self.pos.y + move * dt * self.speed.curr
	--[[
	self.stripes.pos = (self.stripes.pos + dt * 20)
	if self.stripes.pos > self.stripes.distance then self.stripes.pos = self.stripes.pos - self.stripes.distance end]]
end

function Player:changeSize(i, sizeModifier)
	self.size.modifier = self.size.modifier + i
	self.size.curr.y = self.size.base.y * (sizeModifier ^ self.size.modifier)
end

function Player:changeSpeed(i, speedModifier)
	self.speed.modifier = self.speed.modifier + i
	self.speed.curr = self.speed.base * (speedModifier ^ self.speed.modifier)
end

function Player:draw()
	love.graphics.setColor(self.rgba)
	love.graphics.rectangle("fill", self.pos.x - self.size.curr.x, self.pos.y - self.size.curr.y, 2 * self.size.curr.x, 2 * self.size.curr.y)

	--[[ todo: animating speed up
	if self.speed.modifier ~= 0 then
		local rgba
		if self.speed.modifier > 0 then
			love.graphics.setColor(0, 0.5, 0, 0.2)
		else
			love.graphics.setColor(0.5, 0, 0, 0.2)
		end
		local x = self.pos.x - self.size.curr.x - self.stripes.margin
		local y = self.pos.y - self.size.curr.y - self.stripes.margin + self.stripes.pos
		local width = 2 * (self.size.curr.x + self.stripes.margin)
		local maxY = self.pos.y + self.size.curr.y + self.stripes.margin - (2 * self.size.curr.x + 2 * self.stripes.margin)

		for yy = y
		while y < maxY do
			love.graphics.line(x, y, x + width, y + width)
			y = y + self.stripes.distance
		end
	end]]
end

function Player:reset()
	self.pos.y = canvas.y / 2
end


return Player
