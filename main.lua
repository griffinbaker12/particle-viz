local Particle = require("src.particle")
local Constants = require("src.constants")

local particles = {}

function love.load()
	love.window.setTitle("particle viz")
	love.window.setMode(Constants.WINDOW_WIDTH, Constants.WINDOW_HEIGHT)

	for _ = 1, Constants.NUM_PARTICLES do
		local x = love.math.random(Constants.PARTICLE_RADIUS, Constants.WINDOW_WIDTH - Constants.PARTICLE_RADIUS)
		local y = love.math.random(Constants.PARTICLE_RADIUS, Constants.WINDOW_HEIGHT - Constants.PARTICLE_RADIUS)

		local angle = love.math.random() * 2 * math.pi
		local speed = Constants.INITIAL_SPEED
		local vx = speed * math.cos(angle)
		local vy = speed * math.sin(angle)

		local particle = Particle.new(x, y, vx, vy, 20)
		table.insert(particles, particle)
	end
end

function love.draw()
	love.graphics.setBackgroundColor(Constants.BG_COLOR)

	local mx, my = love.mouse.getPosition()
	love.graphics.setBlendMode("add")
	love.graphics.setColor(0.2, 0.3, 0.4, 0.2)
	love.graphics.circle("fill", mx, my, Constants.MOUSE_FIELD_RADIUS)

	for _, particle in ipairs(particles) do
		particle:draw()
	end

	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(0.7, 0.7, 0.8)
end

function love.update(dt)
	local mx, my = love.mouse.getPosition()

	for _, particle in ipairs(particles) do
		particle:update(dt)
		particle:applyMouseForce(mx, my)
	end

	for i = 1, #particles do
		for j = i + 1, #particles do
			particles[i]:checkCollision(particles[j])
		end
	end
end
