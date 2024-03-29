ShopMenu = Menu:new()
ShopMenu.__index = ShopMenu

function ShopMenu:setup()
	self.submenu = Constants.EnumSubmenu.SHOP
	
	self.item_list = self:organize_and_load({})
	
	self.curr_cat = Constants.ItemCategory.WEAPON
	self.curr_item = nil

	self.tab_height = {1,0,0,0}
	
	GameController.player:load_model()
	
	self.buttons = {{
		x = 700, y = 650, w = 200, h = 50, text = {{0,0,0,1}, ("Buy"):translate()},
		click = function() self:buy_item() end
	}}
	
	self.sprites = {
		bg_img = love.graphics.newImage("assets/menus/MenuShop.png"),
		tab = love.graphics.newImage("assets/menus/ShopTab.png"),
	}
	
	self.loading = true
	API.get_shop_items():success(function(response)
		self.item_list = self:organize_and_load(response)
	end):after(function() 
		self.loading = nil
	end)
end

function ShopMenu:show()
	
	local frame = math.floor(self.timer/3)%120 + 1
	local player = GameController.player
	
	View.draw(self.sprites.bg_img, 0, 0, 0, 2/3)
	
	--/--
	
	player:draw_model(35,0,0.55,frame)
	
	View.print(player.name, 20, 420, 0, 0.5)
	View.print(player.class.name..", Level "..player.level, 20, 450, 0, 0.3)
	View.printf(player.gold.." G", -20, 420, 1600, "right", 0, 0.3)
	View.printf(player.diamonds.." Diamonds", -20, 450, 1600, "right", 0, 0.3)
	
	--/--
	
	View.printf(("Shop"):translate(), 480, 10, 1143, "center", 0, 35/50)
	
	local idx, item, cat
	local categories = {"Weapons", "Helms", "Armors", "Accessories"}

	for idx, cat in ipairs(categories) do
		View.draw(self.sprites.tab, 497 + 200*(idx-1), 79 + 59*(1-self.tab_height[idx])*2/3, 0, 2/3, self.tab_height[idx]*2/3)
		View.printf(cat, 480 + 200*(idx-1), 89, 500, "center", 0, 2/5)
	end
	
	--/--

	for idx, item in ipairs(self.item_list[self.curr_cat]) do
		x = 490 + 100*((idx-1)%8)
		y = 130 + 100*math.floor((idx-1)/8)
		if item.bought then
			item:draw_icon(x,y,80, 0.3)
		else
			item:draw_icon(x,y,80)
		end
	end
	
	--/--
	
	View.setColor(0,0,0)
	
	View.printf("Stats", 0,  490, 800,"center", 0, 0.6)
	
	local stats = player.stats
	View.print("Max HP: "..stats.hp	, 20,  550, 0, 0.4)
	View.print("Atk: "..stats.atk	, 20,  590, 0, 0.4)
	View.print("Def: "..stats.def	, 260, 590, 0, 0.4)
	View.print("M Def: "..stats.mdef, 20,  630, 0, 0.4)
	View.print("Luck: "..stats.luck	, 260, 630, 0, 0.4)
	View.print("Speed: "..stats.speed, 20,  670, 0, 0.4)
	View.print("Mov: "..stats.mov	, 260, 670, 0, 0.4)
	
	View.setColor(1,1,1)
	
	--/--
	
	if self.selection then
		local item = self.selection
		item:draw_icon(490,530,180)
		View.print(item.name, 680, 540, 0, 3/5)
		View.print(item.price.." G", 680, 580, 0, 2/5)
		self:draw_btn(self.buttons[1])
	end
end

function ShopMenu:organize_and_load(items)
	local new_list = {{},{},{},{}}	
	local new_item = nil
	local item
	
	for _, item in ipairs(items) do
		new_item = Item:new(item)
		new_item.id = 0
		new_item.kind = item.pk
		new_item:load_single_icon(item.type)
		table.insert(new_list[item.type], new_item)
	end
	
	return new_list
end

function ShopMenu:click(x,y,k)
	if k == 2 then
		MyLib.FadeToColor(0.25, {function() 
			MainMenu:new()
		end})
	else
		if y>=70 and y<=120 and x>=480 and x<1280 then
			self.curr_cat = math.floor((x-480)/200) + 1
			self.selection = nil
			return
		end
		
		if y>=130 and y<=520 and x>=490 then
			local lin, col
			col = math.floor((x-490)/100)
			lin = math.floor((y-130)/100)
			if (x-490)%100<=80 and (y-130)%100<=80 then
				local selected_item = self.item_list[self.curr_cat][8*lin + col + 1]
				if selected_item then
					if not selected_item.bought then
						self.selection = selected_item
					end
				end
			end
			return
		end
	end
end

function ShopMenu:buy_item()
	if not self.selection then return end

	self.loading = true
	self.buttons[1].disabled = true
	
	API.buy_item(self.selection):success(function()
		GameController.player.gold = GameController.player.gold - self.selection.price
		self.selection.bought = true
		self.selection = nil
	end):fail(function()
		Alert:new("Can't buy Item!", AlertTypes.error)
	end):after(function()
		self.loading = nil
		self.buttons[1].disabled = false
	end)	
end

function ShopMenu:sub_update(dt)
	local cat
	for cat = 1,4 do
		if self.curr_cat == cat and self.tab_height[cat] < 1 then
			self.tab_height[cat] = math.min(1, self.tab_height[cat] + (2-self.tab_height[cat])*5*dt)
		end
		if self.curr_cat ~= cat and self.tab_height[cat] > 0 then
			self.tab_height[cat] = math.max(0, self.tab_height[cat] - (1+self.tab_height[cat])*5*dt)
		end
	end
end

function ShopMenu:close_func()
	Item.icons = {}
end
