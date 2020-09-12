MainMenu = Menu:new()
MainMenu.__index = MainMenu

function MainMenu:setup()
	self.submenu = Constants.EnumSubmenu.MAIN
	self.back_btn = false
	self.timer = 0
	self.frame = 1
	self.menu_list = {MainMenu, ItemsMenu, ScoresMenu, QuestsMenu, SkillMenu, ShopMenu, TasksMenu, HelpMenu, OptionsMenu}
	self.menu_names = {"Items", "Scores", "Quests", "Skills", "Shop", "Tasks", "Help", "Options"}
	
	GameController.player:load_model()
	
	self.bg_img = love.graphics.newImage("assets/Main.png")
	
	self:request_update(lock)
end

function MainMenu:show()
	local player = GameController.player
	
	View.draw(self.bg_img,0,0)
	player:draw_model(350,60,0.8,self.frame)
	
	View.print(player.name, 350, 10)
	View.print(player.class.name..", Level "..player.level, 350, 70, 0, 1/2)
	
	
	View.print(("Energy"):translate(), 10, 610, 0, 2/5)
	View.setColor(0.4,0.3,0)
	View.rectangle("fill", 10, 635, 330, 20)
	View.setColor(0.8,0.6,0)
	View.rectangle("fill", 10, 635, 330*player.energy/100, 20)
	View.setColor(1,1,1)
	View.printf(player.energy.."/100", 10, 635, 825, "center", 0, 2/5)
	View.print(("Experience"):translate(), 10, 660, 0, 2/5)
	View.setColor(0,0.1,0.4)
	View.rectangle("fill", 10, 685, 330, 20)
	View.setColor(0,0.2,0.8)
	View.rectangle("fill", 10, 685, 330*player.xp/player:xp_to_next(), 20)
	View.setColor(1,1,1)
	View.printf(player.xp.."/"..player:xp_to_next(), 10, 685, 825, "center", 0, 2/5)
	
	
	local i,x,y
	for i=1,8 do
		x = 930 + math.floor((i-1)/4)*180
		y = 100 + 150*((i-1)%4)
		View.rectangle("fill", x, y, 120, 120)
		View.printf({{0,0,0},self.menu_names[i]}, x, y+45, 240, "center", 0, 1/2)
	end
end

function MainMenu:update(dt)
	self.timer = (self.timer + 20*dt)
	if self.timer > 120 then
		self.timer = self.timer - 120
		self:request_update()
	end
	
	if self.updating then
		local response = API.r_channel:pop()
		
		if response then
			if response.status == Constants.STATUS_OK then
				local response_data = Json.decode(response[1])
				GameController.player.energy = response_data.energy
			end
			self.calling_api = nil
			self.updating = nil
		end
	end
	
	self.frame = math.floor(self.timer)%120 + 1
end

function MainMenu:click(x,y,k)	
	if self.disabled then return end
	
	local col, lin
	local selection
	
	if (x>=930 and x<=1230 and (x-930)%180<=120) then 
		col = math.floor((x-930)/180) 
		if (y>=100 and y<=670 and (y-100)%150<=120) then 
			lin = math.floor((y+50)/150)
			selection = 4*col + lin + 1
			self.disabled = true
			MyLib.FadeToColor(0.25, {function()
				self.menu_list[selection]:new()
			end})
		end
	end
end

function MainMenu:request_update(lock)
	self.calling_api = lock or nil
	self.updating = true
	API.update_player()
end
