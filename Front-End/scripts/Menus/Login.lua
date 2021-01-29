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

	if self.message then
		View.setColor(1,0.2,0.2)
		View.printf(self.message:translate(), 240, 540, 2000, "center", 0, 2/5)
		View.setColor(1,1,1)
	end
	
	if self.loading then
		Utils.draw_loading(self.timer*4)
	end
end

function Login:update(dt)
	self.timer = (self.timer + dt)
end

function Login:mousepressed(x,y,k)
	if x >= 520 and x <= 760 and y >= 600 and y <= 660 and k == 1 and not self.disabled then
		self.invalid = nil
		self.disabled = true
		self.timer = 0
		self:login()
	end
end

function Login:login()
	API.login_player(self.login_box.text, self.pass_box.text)
	self.loading=true
	self.invalid = false
	self.message = nil
	Promise:new():success(function(data)
		local player = {}
		
		API.channel:push({message="set_token", token=data.token})
					
		if data.player.nochar then
			player = {nochar = true}
		end
		
		GameController.login(player)
	end):fail(function(data)
		if data.status == 403 then
			self.invalid = true
		else
			self.message = data[1]
		end
		self.disabled = false
	end):after(function()
		self.loading = nil
	end)
end