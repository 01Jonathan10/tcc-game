math.randomseed(os.time())

function love.quit() love.thread.getChannel("taskChannel"):push("kill") end

fps = 60
love.filesystem.setRequirePath('scripts/MyLib/?.lua')
require ('MyLib')

love.filesystem.setRequirePath('scripts/API/?.lua')
API = {}
local scripts = love.filesystem.getDirectoryItems('scripts/API')
table.sort (scripts)
for _, filename in ipairs(scripts) do
	if filename:sub(#filename-3) == ".lua" and filename ~= "API_Server.lua" then
		require (filename:sub (1, #filename-4))
	end
end


love.filesystem.setRequirePath( 'scripts/?.lua' )
scripts = love.filesystem.getDirectoryItems("scripts")
table.sort (scripts)
for _, filename in ipairs(scripts) do
	if filename:sub(#filename-3) == ".lua" then
		require (filename:sub (1, #filename-4))
	end
end

love.filesystem.setRequirePath( 'scripts/Json/?.lua' )
Json = require("json")

love.filesystem.setRequirePath('scripts/shaders/?.lua')
require("CharCreationShader")

View = love.graphics

MyLib.MyLibSetup()

love.graphics.setFont(Constants.FONT)
GameController.debug = is_debug
is_debug = nil

API.run_thread()
GameController.timer = 0
GameController.begin_game()
