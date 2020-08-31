GameController = {}
GameController.__index = GameController

function GameController.begin_game()
	Textbox:dispose()
	GameController.state = Constants.EnumGameState.LOGIN
	GameController.login_screen = Login:new()	
end

function GameController.login(player)
	Textbox:dispose()

	if player.nochar then
		GameController.state = Constants.EnumGameState.CREATION
		GameController.char_creation = CharCreation:new()
	else
		GameController.go_to_menu()
	end
end

function GameController.go_to_menu()
	GameController.login_screen = nil
	
	GameController.player = API.get_player()
	
	local tmp = GameController.waiting_api
	GameController.waiting_api = function(response)
		tmp(response)
		Textbox:dispose()
		GameController.state = Constants.EnumGameState.MENU
		MyLib.FadeClass.create(0.25, {}, {}, "fill", {0,0,0,1}, false)
		MyLib.skip_frame = true
		GameController.menu = MainMenu:new()
	end
end

function GameController.start_quest(quest, diff, actions)
	Textbox:dispose()
	GameController.state = Constants.EnumGameState.QUEST
	QuestController.load_quest(quest, actions)
	
	GameController.menu = nil
end

function GameController.unload_map()
	QuestController.map = nil
	GameController.player = nil
	Skill.loaded_skills = {}
	collectgarbage()
end