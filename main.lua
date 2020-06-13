local threedee = require "threedee"

local shader = nil

function love.load()
	shader = love.graphics.newShader(threedee.FRAGMENT_SHADER, threedee.VERTEX_SHADER)
end

function love.draw()
	love.graphics.clear(0.5, 0.4, 0.2)

	-- Start drawing in 3D.
	love.graphics.setShader(shader)
	
	-- Set up the camera for the scene.
	local ratio = love.graphics.getWidth() / love.graphics.getHeight()
	shader:send("threedee_perspective", "row", threedee.perspectiveMatrix(math.rad(90), ratio, 1, 30))
	shader:send("threedee_camera", "row", threedee.orthoMatrix({2.5, 2.5, 2}, {0.5, 0.5, 5.5}, 0))


	local cube_z = 5
	local format = {
		{"VertexPosition", "float", 3},
		{"VertexTexCoord", "float", 2},
	}
	local cube = love.graphics.newMesh(format, {
		{0, 0, 0 + cube_z; 0, 0},
		{1, 0, 0 + cube_z; 0, 0},
		{0, 1, 0 + cube_z; 0, 0},
		{1, 1, 0 + cube_z; 0, 0},
		{0, 1, 1 + cube_z; 0, 0},
		{1, 1, 1 + cube_z; 0, 0},
	}, "strip")
	love.graphics.draw(cube)

	-- Stop drawing in 3D.
	love.graphics.setShader()
end
