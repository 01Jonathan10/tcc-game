Login = {}
Login.__index = Login

function Login:new(obj)
	local obj = obj or {}
	
	setmetatable(obj, self)
	
	Textbox:init()
	obj.login_box = Textbox:new("login",390,310,500,50, {1,0.5,0.5})
	obj.pass_box = Textbox:new("password",390,450,500,50, {1,0.5,0.5})
	
	obj.login_box:trigger()
	
	obj.timer = 0
	
	return obj
end

function Login:draw()
	View.printf(("Login Screen"):translate(), 0, 100, 1280, "center")
	View.printf(("Username"):translate(), 540, 270, 500, "center", 0, 2/5)
	View.printf(("Password"):translate(), 540, 410, 500, "center", 0, 2/5)
	
	View.setColor(0.3,0.3,0.3)
	View.rectangle("fill", 520, 590, 240, 60)
	View.setColor(1,1,1)
	View.printf(("Login"):translate(), 540, 600, 250, "center", 0, 4/5)
	
	if self.invalid then
		View.setColor(1,0.2,0.2)
		View.printf(("Invalid username or password."):translate(), 240, 540, 2000, "center", 0, 2/5)
		View.setColor(1,1,1)
	end
	
	if GameController.task_queue>0 then
		Utils.draw_loading(self.timer*4)
	end
end

function Login:update(dt)
	self.timer = (self.timer + dt)
	if GameController.task_queue>0 then
		local message = API.r_channel:pop()
		if message then
			self.player_logged = message
			GameController.task_queue = GameController.task_queue - 1
		end
		return
	end
	
	if self.player_logged then		
		if self.player_logged.status == Constants.STATUS_OK then
			local player_data = Json.decode(self.player_logged[1])
			local player = {}
			
			API.channel:push({message="set_token", token=player_data.token})
						
			if player_data.player.nochar then 
				player = {nochar = true}
			end
			
			MyLib.FadeToColor(0.25, {function() GameController.login(player) end})
		else
			self.invalid = true
			self.disabled = false
		end
		
		self.player_logged = nil
	end
end

function Login:mousepressed(x,y,k)
	if x >= 520 and x <= 760 and y >= 600 and y <= 660 and k == 1 and not self.disabled then
		self.invalid = nil
		self.disabled = true
		self.timer = 0
		API.login_player(self.login_box.text, self.pass_box.text)
	end
end
