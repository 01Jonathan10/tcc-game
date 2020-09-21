function love.update(dt)

	collectgarbage()
	
	GameController.timer = (GameController.timer + dt) %1
	
	if API.promise then
		local response = API.r_channel:pop()
		if response then
			local prom = API.promise
			API.promise = nil
			prom:handle(response)
		end
	end

	if GameController.state == Constants.EnumGameState.MENU then
		GameController.menu:update(dt)
	elseif GameController.state == Constants.EnumGameState.QUEST then
		QuestController.update(dt)
	elseif GameController.state == Constants.EnumGameState.LOGIN then
		GameController.login_screen:update(dt)
	elseif GameController.state == Constants.EnumGameState.CREATION then
		GameController.char_creation:update(dt)
	end
end
