function love.textinput(text)
	if #GameController.alert_stack > 0 then return end

	if Textbox.active_box then Textbox.active_box:textinput(text) end
end

function love.mousepressed(x, y, k)
	local x, y = Utils.convert_coords(x, y)

	if #GameController.alert_stack > 0 then
		GameController.alert_stack[1]:mousepressed(x, y, k)
		return
	end

	if GameController.state == Constants.EnumGameState.MENU then
		GameController.menu:mousepressed(x, y, k)
	elseif GameController.state == Constants.EnumGameState.QUEST and k==1 then
		QuestController.mousepressed(x, y, k)
	elseif GameController.state == Constants.EnumGameState.LOGIN then
		GameController.login_screen:mousepressed(x, y, k)
	elseif GameController.state == Constants.EnumGameState.CREATION and k==1 then
		GameController.char_creation:mousepressed(x, y, k)
	elseif GameController.state == Constants.EnumGameState.TUTORIAL then
		GameController.tutorial:click()
	end
	
	if Textbox.list then Textbox.mouseclick(x,y,k) end
end

function love.keypressed(key)
	if #GameController.alert_stack > 0 then return end

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
	
	if key == "\'" and GameController.debug then
		print('reload')
		local reloading = 'Menu_Scores'
		
		local menu = GameController.menu
		package.loaded[reloading] = nil
		love.filesystem.setRequirePath( 'scripts/Menus/?.lua' )
		require(reloading)

		GameController.menu = menu

		love.filesystem.setRequirePath( 'scripts/?.lua' )
		package.loaded['1ove_input'] = nil
		require("1ove_input")
	end
end