local Constants = require("src.constants")

local Particle = {}
Particle.__index = Particle

local function blendColors(color1, color2, ratio)
	return {
		color1[1] * ratio + color2[1] * (1 - ratio),
		color1[2] * ratio + color2[2] * (1 - ratio),
		color1[3] * ratio + color2[3] * (1 - ratio),
	}
end

local function capVelocity(vx, vy)
	local speed = math.sqrt(vx * vx + vy * vy)
	if speed > Constants.MAX_VELOCITY then
		local scale = Constants.MAX_VELOCITY / speed
		return vx * scale, vy * scale
	end
	return vx, vy
end

function Particle.new(x, y, vx, vy, mass)
	local self = setmetatable({}, Particle)
	self.x = x
	self.y = y
	self.vx = vx
	self.vy = vy
	self.mass = mass
	self.radius = Constants.PARTICLE_RADIUS
	self.color = Constants.COLORS[love.math.random(#Constants.COLORS)]
	self.sparks = {}
	self.energized = 0
	self.trail = {}
	return self
end

function Particle:handleWallCollisions()
	local restitution = Constants.WALL_RESTITUTION

	if self.x - self.radius < 0 then
		self.x = self.radius
		self.vx = -self.vx * restitution
	elseif self.x + self.radius > Constants.WINDOW_WIDTH then
		self.x = Constants.WINDOW_WIDTH - self.radius
		self.vx = -self.vx * restitution
	end

	if self.y + self.radius > Constants.WINDOW_HEIGHT then
		self.y = Constants.WINDOW_HEIGHT - self.radius
		self.vy = -self.vy * restitution
		self.vx = self.vx * Constants.GROUND_FRICTION
	elseif self.y - self.radius < 0 then
		self.y = self.radius
		self.vy = -self.vy * restitution
	end
end

function Particle:createSparks(other)
	local dx = other.x - self.x
	local dy = other.y - self.y
	local collision_angle = math.atan(dy, dx)

	local totalMass = self.mass + other.mass
	local ratio = self.mass / totalMass

	local blendedColor = blendColors(self.color, other.color, ratio)

	for i = 1, Constants.SPARK_COUNT do
		local angle = collision_angle + (2 * math.pi / Constants.SPARK_COUNT) * i + love.math.random() * 0.5
		table.insert(self.sparks, {
			x = self.x + dx / 2,
			y = self.y + dy / 2,
			angle = angle,
			life = Constants.SPARK_DURATION,
			color = blendedColor,
		})
	end
end

function Particle:checkCollision(other)
	local dx = other.x - self.x
	local dy = other.y - self.y
	local dist = math.sqrt(dx * dx + dy * dy)

	if dist < (self.radius + other.radius) then
		local nx = dx / dist
		local ny = dy / dist

		local overlap = (self.radius + other.radius) - dist
		local moveX = (overlap * nx) / 2
		local moveY = (overlap * ny) / 2
		self.x = self.x - moveX
		self.y = self.y - moveY
		other.x = other.x + moveX
		other.y = other.y + moveY

		local relativeVelX = self.vx - other.vx
		local relativeVelY = self.vy - other.vy
		local relativeVel = relativeVelX * nx + relativeVelY * ny

		if relativeVel > 0 then
			return false
		end

		local restitution = Constants.PARTICLE_RESTITUTION
		local j = -(1 + restitution) * relativeVel
		j = j / (1 / self.mass + 1 / other.mass)

		local impulseX = (j * nx) / self.mass
		local impulseY = (j * ny) / self.mass

		self.vx, self.vy = capVelocity(self.vx + impulseX, self.vy + impulseY)
		other.vx, other.vy = capVelocity(other.vx - (j * nx) / other.mass, other.vy - (j * ny) / other.mass)

		self:createSparks(other)
		other:createSparks(self)

		return true
	end
	return false
end

function Particle:applyMouseForce(mx, my)
	local dx = self.x - mx
	local dy = self.y - my
	local dist = math.sqrt(dx * dx + dy * dy)

	if dist < Constants.MOUSE_FIELD_RADIUS then
		local force_dist = math.max(dist, Constants.MIN_FORCE_DISTANCE)
		local nx = dx / force_dist
		local ny = dy / force_dist

		local force = (Constants.MOUSE_FIELD_RADIUS - dist) * Constants.MOUSE_FORCE_STRENGTH

		local newVx = self.vx + nx * force / self.mass
		local newVy = self.vy + ny * force / self.mass

		self.vx, self.vy = capVelocity(newVx, newVy)

		self.energized = 0.5

		local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
		if speed > 1 and speed < Constants.MAX_VELOCITY * 0.8 then
			self.vx = self.vx * Constants.MOUSE_BOOST_MULT
			self.vy = self.vy * Constants.MOUSE_BOOST_MULT
		end
	end
end

function Particle:update(dt)
	self.vx, self.vy = capVelocity(self.vx, self.vy)

	self.vy = self.vy + Constants.GRAVITY * dt

	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt

	if self.energized > 0 then
		self.energized = self.energized - dt
	end

	table.insert(self.trail, 1, { x = self.x, y = self.y })
	if #self.trail > Constants.TRAIL_LENGTH then
		table.remove(self.trail)
	end

	for i = #self.sparks, 1, -1 do
		local spark = self.sparks[i]
		spark.life = spark.life - dt
		if spark.life <= 0 then
			table.remove(self.sparks, i)
		end
	end

	self:handleWallCollisions()
end

function Particle:draw()
	for i, pos in ipairs(self.trail) do
		local alpha = (Constants.TRAIL_LENGTH - i + 1) / Constants.TRAIL_LENGTH * Constants.TRAIL_FADE
		love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
		love.graphics.circle("fill", pos.x, pos.y, self.radius * (1 - i / Constants.TRAIL_LENGTH))
	end

	local glowRadius = self.radius * Constants.GLOW_RADIUS_MULT
	local glowAlpha = Constants.GLOW_ALPHA
	if self.energized > 0 then
		glowRadius = glowRadius * (1 + self.energized)
		glowAlpha = glowAlpha * 2
	end
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], glowAlpha)
	love.graphics.circle("fill", self.x, self.y, glowRadius)

	love.graphics.setColor(self.color)
	love.graphics.circle("fill", self.x, self.y, self.radius)

	love.graphics.setLineWidth(2)
	for _, spark in ipairs(self.sparks) do
		local alpha = spark.life / Constants.SPARK_DURATION * Constants.SPARK_ALPHA
		love.graphics.setColor(spark.color[1], spark.color[2], spark.color[3], alpha)
		local endX = spark.x + math.cos(spark.angle) * Constants.SPARK_LENGTH
		local endY = spark.y + math.sin(spark.angle) * Constants.SPARK_LENGTH
		love.graphics.line(spark.x, spark.y, endX, endY)
	end
end

return Particle
