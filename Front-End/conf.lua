-- Configuration
function love.conf(t)
	t.title = "Game"     -- The title of the window the game is in (string)
	t.window.width = 1280
	t.window.height = 720
	
	t.window.fullscreen = true
	
	-- For Windows debugging
	t.console = true
	is_debug = t.console
end
