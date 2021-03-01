GameController = {}
GameController.__index = GameController

function GameController.begin_game()
	Textbox:dispose()
	GameController.state = Constants.EnumGameState.LOGIN
	GameController.login_screen = Login:new()
	GameController.alert_stack = {}
end

function GameController.login(player)
	if player.nochar then
		MyLib.FadeToColor(0.25, {function()  
			GameController.state = Constants.EnumGameState.CREATION
			GameController.login_screen = nil
			GameController.char_creation = CharCreation:new()
		end})
	else
		GameController.go_to_menu()
	end
end

function GameController.go_to_menu()
	return API.get_player():success(function(data)
		MyLib.FadeToColor(0.25, {function()
			GameController.login_screen = nil
			GameController.state = Constants.EnumGameState.MENU
			Textbox:dispose()
			GameController.player = Player:new(API.translate_player(data))
			GameController.menu = MainMenu:new()
			GameController.unload_map()
		end})
	end):fail(function(data)
		API.error(data)
		GameController.player = Character:new({})
	end)
end

function GameController.go_to_menu()
	GameController.loading = true
	API.get_player():success(function(data)
		MyLib.FadeToColor(0.25, {function()
			GameController.login_screen = nil
			GameController.state = Constants.EnumGameState.MENU
			Textbox:dispose()
			GameController.player = Player:new(API.translate_player(data))
			GameController.menu = MainMenu:new()
		end})
	end):fail(function(data)
		API.error(data)
		GameController.player = Character:new({})
	end):after(function()
		GameController.loading = nil
	end)
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