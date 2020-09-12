function love.draw()
	local Sx, Sy = Utils.convert_coords(1, 1)
	local scale = math.min(1/Sx, 1/Sy)
	love.graphics.scale(scale, scale)
	
	if GameController.waiting_api then
		Utils.draw_loading(GameController.timer*math.pi)
		return
	end

	if GameController.state == Constants.EnumGameState.MENU then
		GameController.menu:draw()
	elseif GameController.state == Constants.EnumGameState.QUEST then
		QuestController.draw()
	elseif GameController.state == Constants.EnumGameState.LOGIN then
		GameController.login_screen:draw()
	elseif GameController.state == Constants.EnumGameState.CREATION then
		GameController.char_creation:draw()
	end
	
	if Textbox.list then
		Textbox.draw_all()
	end
	
	if GameController.debug then love.graphics.print('Memory actually used (in kB): ' .. collectgarbage('count'), 10,10, 0, 0.4) end
end
