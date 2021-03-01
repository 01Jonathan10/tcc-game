MainMenu = Menu:new()
MainMenu.__index = MainMenu

function MainMenu:setup()
	self.submenu = Constants.EnumSubmenu.MAIN
	self.back_btn = false
	self.timer = 0
	self.frame = 1
	self.menu_list = {MainMenu, ItemsMenu, ScoresMenu, QuestsMenu, SkillMenu, ShopMenu, TasksMenu, HelpMenu, OptionsMenu}

	self.buttons = {
		{
			x = 1000,y = 420, r = 50, form = 'circle', text="",
			click = function() self:setMenu(2) end
		},
		{
			x = 1080,y = 250, r = 100, form = 'circle', text="",
			click = function() self:setMenu(4) end
		},
		{
			x = 1000,y = 540, r = 50, form = 'circle', text="",
			click = function() self:setMenu(7) end
		},
		{
			x = 1160,y = 420, r = 50, form = 'circle', text="",
			click = function() self:setMenu(3) end
		},
		{
			x = 1160,y = 540, r = 50, form = 'circle', text="",
			click = function() self:setMenu(6) end
		},
	}

	self.icons = love.graphics.newImage("assets/icons/MenuIcons.png")
	self.icon_quads = {}

	for i=0,4 do
		table.insert(self.icon_quads, View.newQuad(i*200,0,200,200,1000,200))
	end
	
	GameController.player:load_model()
	
	self.bg_img = love.graphics.newImage("assets/Main.png")
	
	self:request_update()
end

function MainMenu:show()
	local player = GameController.player
	
	View.draw(self.bg_img,0,0)
	player:draw_model(350,60,0.8,self.frame)
	
	View.print(player.name, 10, 500)
	View.print(player.class.name..", Level "..player.level, 10, 560, 0, 1/2)
	
	
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

	for index, btn in ipairs(self.buttons) do
		self:draw_btn(btn)
		View.draw(self.icons, self.icon_quads[index], btn.x - btn.r - 1, btn.y - btn.r - 1, 0, btn.r/98)
	end
end

function MainMenu:update(dt)
	self.timer = (self.timer + 20*dt)
	if self.timer > 120 then
		self.timer = self.timer - 120
		self:request_update()
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
			self:setMenu(selection)
		end
	end
end

function MainMenu:setMenu(selection)
	self.disabled = true
	MyLib.FadeToColor(0.25, {function()
		self.menu_list[selection]:new()
	end})
end

function MainMenu:request_update()
	API.update_player():success(function(data)
		GameController.player.energy = data.energy or GameController.player.energy
		GameController.player.gold = data.gold or GameController.player.gold
		GameController.player.diamonds = data.gold or GameController.player.diamonds
		GameController.player.xp = data.gold or GameController.player.xp
	end)
end
