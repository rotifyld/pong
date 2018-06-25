local Player = {}
Player.__index = Player

setmetatable(Player, { __call = function(_, ...) return Player.new(...) end })

function Player.new(upKey, downKey, posX, rgba)
	local self = setmetatable({}, Player)
	self.key = {up = upKey, down = downKey}
	self.pos = {x = posX, y = canvas.y / 2}
	self.size = {x = 5, y = 60} -- y=60
	self.speed = 300
	self.rgba = rgba
	return self
end

function Player:move(dt)
	local move = 0
	if love.keyboard.isDown(self.key.up) and self.pos.y - self.size.y > 0 then
	    move = move - 1
	end
	if love.keyboard.isDown(self.key.down) and self.pos.y + self.size.y < canvas.y then
	    move = move + 1
	end
	self.pos.y = self.pos.y + move * dt * self.speed
end

function Player:grow(sizeModifier)
	self.size.x = self.size.x / sizeModifier
	self.size.y = self.size.y * sizeModifier
end

function Player:shrink(sizeModifier)
	self.size.x = self.size.x * sizeModifier
	self.size.y = self.size.y / sizeModifier
end

function Player:speedUp(speedModifier)
	self.speed = self.speed * speedModifier
end

function Player:slowDown(speedModifier)
	self.speed = self.speed / speedModifier
end

function Player:draw()
	love.graphics.setColor(self.rgba)
	love.graphics.rectangle("fill", self.pos.x - self.size.x, self.pos.y - self.size.y, 2 * self.size.x, 2 * self.size.y)
end

function Player:reset()
	self.pos.y = canvas.y / 2
end


return Player