function love.conf(t)
	t.title = "Basic 3D example"
	t.version = "11.2"
	t.window.width = 1200
	t.window.height = 800

	-- NB: Cannot be greater than 24 on some modern hardware.
	t.window.depth = 24

	-- Show print in console
	t.console = true
end
