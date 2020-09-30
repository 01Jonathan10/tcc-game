function love.textinput(text)
	if Textbox.active_box then Textbox.active_box:textinput(text) end
end

function love.mousepressed(x, y, k)
	local x, y = Utils.convert_coords(x, y)
	if GameController.state == Constants.EnumGameState.MENU then
		GameController.menu:mousepressed(x, y, k)
	elseif GameController.state == Constants.EnumGameState.QUEST and k==1 then
		QuestController.mousepressed(x, y, k)
	elseif GameController.state == Constants.EnumGameState.LOGIN then
		GameController.login_screen:mousepressed(x, y, k)
	elseif GameController.state == Constants.EnumGameState.CREATION and k==1 then
		GameController.char_creation:mousepressed(x, y, k)
	end
	
	if Textbox.list then Textbox.mouseclick(x,y,k) end
end

function love.keypressed(key)
	if Textbox.active_box then 
		if key == "tab" then
			Textbox.list[Textbox.active_box.index%#Textbox.list + 1]:trigger()
		else
			Textbox.active_box:keypressed(key)
		end
	end

	if GameController.state == Constants.EnumGameState.LOGIN and key == "return" then
		GameController.login_screen:login()
	end
	
	if key == "\'" and GameController.state == Constants.EnumGameState.MENU then
		print('reload')
		local reloading = 'Menu_Tasks'
		
		local menu = GameController.menu
		package.loaded[reloading] = nil
		love.filesystem.setRequirePath( 'scripts/?.lua' )
		require(reloading)

		GameController.menu = menu

		package.loaded['1ove_input'] = nil
		require("1ove_input")
	end
end