-- Configuration
function love.conf(t)
	t.title = "Game"     -- The title of the window the game is in (string)
	t.window.width = 1920
	t.window.height = 1080
	
	t.window.fullscreen = true
	
	-- For Windows debugging
	t.console = false
	is_debug = t.console
end
