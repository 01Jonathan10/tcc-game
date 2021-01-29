math.randomseed(os.time())

function love.quit() love.thread.getChannel("taskChannel"):push("kill") end

fps = 60
love.filesystem.setRequirePath('scripts/MyLib/?.lua')
require ('MyLib')

function import_directory(path, exclude)
	local exclude = exclude or {}
	local skipped = nil
	love.filesystem.setRequirePath( path..'/?.lua' )
	local scripts = love.filesystem.getDirectoryItems(path)
	table.sort (scripts)
	for _, filename in ipairs(scripts) do
		skipped = false
		for _, excluded_name in ipairs(exclude) do
			if excluded_name == filename then
				skipped = true
			end
		end
		if filename:sub(#filename-3) == ".lua" and not skipped then
			require (filename:sub (1, #filename-4))
		end
	end
end

API = {}
import_directory('scripts/API', {"API_Server.lua"})
import_directory('scripts')
import_directory('scripts/Menus')
import_directory('scripts/Characters')
import_directory('scripts/Layout')

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
