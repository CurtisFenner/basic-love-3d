local FRAGMENT_SHADER = [===[
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		vec4 texcolor = Texel(texture, texture_coords);
	
		//if (texcolor.w < 0.5) discard;
		return (texcolor - (texcolor * vec4(1.0, 0.0, 0.0, 0.0))) * color;
	}
]===]

-- TODO: Instead of defining my own variables, I could use the
-- built in https://love2d.org/wiki/Shader_Variables

local VERTEX_SHADER = [===[
	extern mat4 threedee_perspective;
	extern mat4 threedee_camera;
	
	vec4 position(mat4 transform_projection, vec4 vertex_position) {
		return threedee_perspective * threedee_camera * vertex_position;
	}
]===]

-- RETURNS a perspective matrix in row-major order:
-- Compute the homogenous screen coordinates as 
-- `return * column_vector(x, y, z, 1)`.
local function perspectiveMatrix(vfov_rad, hv_ratio, far, near)
	-- This is a good explanation:
	-- https://www.scratchapixel.com/lessons/3d-basic-rendering/perspective-and-orthographic-projection-matrix/building-basic-perspective-projection-matrix
	local sy = 1 / math.tan(vfov_rad / 2)
	local sx = sy / hv_ratio
	local a = -far / (far - near)
	local b = -(far * near) / (far - near)
	return {
		sx, 0, 0, 0;
		0, sy, 0, 0;
		0, 0, a, -1;
		0, 0, b, 0;
	}
end

-- RETURNS the cell in the ith row and jth column of the 4x4 row-major matrix m.
local function mat4get(m, i, j)
	assert(#m == 16)
	return m[4 * (i - 1) + j]
end

-- Multiplies two 4x4 row-major matrices.
local function mat4mul(a, b)
	assert(#a == 16)
	assert(#b == 16)

	local o = {}
	for i = 1, 4 do
		for j = 1, 4 do
			-- o[i, j] = A[row i] . B[col j]
			local s = 0
			for k = 1, 4 do
				s = s + mat4get(a, i, k) * mat4get(b, k, j)
			end
			o[#o + 1] = s
		end
	end
	return o
end

-- RETURNS the cross product of two vectors
local function cross(a, b)
	assert(#a == 3 and #b == 3)

	return {
		a[2] * b[3] - a[3] * b[2],
		-(a[1] * b[3] - a[3] * b[1]),
		a[1] * b[2] - a[2] * b[1],
	}
end

-- RETURNS the magnitude of a vector
local function mag(v)
	local s = 0
	for i = 1, #v do
		s = s + v[i] ^ 2
	end
	return math.sqrt(s)
end

-- RETURNS a unit-vector in the same direction as v
local function unit(v)
	assert(#v == 3)
	local m = mag(v)
	return {v[1] / m, v[2] / m, v[3] / m}
end

-- RETURNS the dot prodcut of a and b
local function dot(a, b)
	return a[1] * b[1] + a[2] * b[2] + a[3] * b[3]
end

-- RETURNS a matrix transforming from world space to (orthogonal) camera space.
-- from: the vantage position of the camera
-- to: the position the camera is looking at
-- zspin: currently unimplemented; the spin around the z (forward) axis:
--        0 has (0, +1, 0) as upward; 180 would be "upside down".
local function orthoMatrix(from, to, zspin)
	assert(zspin == 0, "TODO")
	assert(#from == 3, "#from == 3")
	assert(#to == 3, "#to == 3")

	local translation_matrix = {
		1, 0, 0, -from[1];
		0, 1, 0, -from[2];
		0, 0, 1, -from[3];
		0, 0, 0, 1;
	}

	local forward = unit {to[1] - from[1], to[2] - from[2], to[3] - from[3]}
	local rightward = unit(cross(forward, {0, 1, 0}))
	local upward = cross(rightward, forward)
	local ortho_matrix = {
		rightward[1], rightward[2], rightward[3], 0;
		upward[1], upward[2], upward[3], 0;
		-- NB: +Z is forward here.
		forward[1], forward[2], forward[3], 0;
		0, 0, 0, 1;
	}

	return mat4mul(ortho_matrix, translation_matrix)
end

return {
	VERTEX_SHADER = VERTEX_SHADER,
	FRAGMENT_SHADER = FRAGMENT_SHADER,
	perspectiveMatrix = perspectiveMatrix,
	orthoMatrix = orthoMatrix,
}
