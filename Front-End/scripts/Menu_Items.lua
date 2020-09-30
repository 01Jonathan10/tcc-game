ItemsMenu = Menu:new()
ItemsMenu.__index = ItemsMenu

function ItemsMenu:setup()
	self.submenu = Constants.EnumSubmenu.ITEMS
	
	self.sprites = {
		bg_img = love.graphics.newImage("assets/menus/MenuItems.png")
	}
	
	local cat, item
	for cat, item in ipairs(GameController.player.equipment) do item:load_single_icon(cat) end
	for cat, item in ipairs(GameController.player.cosmetics) do item:load_single_icon(cat) end

	self:request_item_list()
	
	self.item_list = {{},{},{},{}}
	self.cosmetic_mode = false
	
	self.selected_item = nil
	self.category = nil
	self.page = 0
	self.total_pages = 1
	self.equip_selected = false
	self.cat_selected = nil
	
	self.timer = 0
	self.frame = 1
	
	GameController.player:load_model()
	
	View.setLineWidth(3)
	
	self.buttons = {
		{
			-- Change Mode
			x = 440, y = 380, r=35, text = {{0,0,0,1}, ("Cosmetic"):translate()}, form="circle",
			click = function() 
				self.cosmetic_mode = not self.cosmetic_mode
				self.category = nil
				self.buttons[5].disabled = self.cosmetic_mode
				self.buttons[6].disabled = self.cosmetic_mode
			end
		}
	}
	
	local i
	for i=1,3 do
		table.insert(self.buttons, {
			-- Categories
			x = 490 + 35 + 140*(i-1), y = 205, w =70, h = 70, text = "",
			click = function() self:set_category(i) end
		})
	end
	
	for i=1,2 do
		table.insert(self.buttons, {
			-- Categories
			x = 560 + 35 + 140*(i-1), y = 315, w =70, h = 70, text = "",
			click = function() self:set_category(i+3) end
		})
	end
end

function ItemsMenu:request_item_list()
	API.get_player_items()
	self.loading = true
	Promise:new():success(function(data)
		self.item_list = {{},{},{},{}}
		for _, each in ipairs(data) do
			cat = each.type
			each.kind = each.item_id
			each.item_id = nil
			table.insert(self.item_list[cat], Item:new(each))
		end
				
		self.loading = nil
		
		Item.load_icons(self.item_list)
		
		MyLib.skip_frame = true
		
		for cat, list in ipairs(self.item_list) do
			if cat ~= Constants.ItemCategory.ARMOR and cat ~= Constants.ItemCategory.WEAPON then
				table.insert(list, 1, Constants.NoneItem)
			end
		end
	end)
end

function ItemsMenu:request_equip(item, cat, cosmetic_mode)
	API.equip_item(item, cat, cosmetic_mode)
	self.loading = true
	Promise:new():success(function(data)
		if cosmetic_mode then
			if item.id == Constants.NoneItem.id then
				GameController.player.cosmetics[cat] = nil
			else
				GameController.player.cosmetics[cat] = item
			end
		else
			GameController.player.equipment[cat] = item
		end
		
		self.selected_item = item
		self.loading = nil
		
		local cats = {"weapon", "helm","armor"}
		if cats[cat] then GameController.player:update_model(cats[cat]) end
	end)
end

function ItemsMenu:show()

	local equip_list = GameController.player.equipment
	if self.cosmetic_mode then equip_list = GameController.player.cosmetics end
	
	View.draw(self.sprites.bg_img, 0, 0, 0, 2/3)
	
	--/--
	
	GameController.player:draw_model(35,10,0.55,math.ceil(self.timer/3))
	
	--/--
	
	View.print(GameController.player.name, 20, 420, 0, 0.5)
	View.print(GameController.player.class.name..", Level "..GameController.player.level, 20, 450, 0, 0.3)
	View.printf(GameController.player.gold.." G", -20, 420, 1600, "right", 0, 0.3)
	View.printf(GameController.player.diamonds.." Diamonds", -20, 450, 1600, "right", 0, 0.3)
	
	self:draw_btn(self.buttons[1])
	
	--/--

	View.printf(("Equipment"):translate(), 490, 10, 614, "center", 0, 35/50)

	View.setFont(Constants.FONT_DUMBLEDOR)

	View.printf(GameController.player.name, 490, 70, 716, "center", 0, 30/50)

	View.setFont(Constants.FONT)

	View.printf(string.format("Level %i %s", GameController.player.level, GameController.player.class.name:translate()), 490, 115, 1433, "center", 0, 15/50)
	View.print("XP:", 490, 140, 0, 18/50)
	
	--/--
	
	local item, cat

	View.setColor(0,0,0)	
	View.printf("Weapon", 	490, 175, 350, "center", 0, 2/5)
	View.printf("Helm", 	630, 175, 350, "center", 0, 2/5)
	View.printf("Armor", 	770, 175, 350, "center", 0, 2/5)
	View.setColor(1,1,1)

	for cat = 1,3 do
		item = equip_list[cat] or Constants.NoneItem		
		item:draw_icon(490 + 35 + 140*(cat-1),205,70)
	end
	
	if not self.cosmetic_mode then
		
		View.setColor(0,0,0)
		View.printf("Accessories", 	630, 285, 350, "center", 0, 2/5)
		View.setColor(1,1,1)
		
		for cat = 4,5 do
			item = equip_list[cat] or Constants.NoneItem
			item:draw_icon(560 + 35 + 140*(cat-4),315,70)
		end
	end
	
	--/--
	
	if self.category then
		self:show_list()
	end
	
	if self.total_pages>1 then
		View.printf("< Page "..(self.page+1).." >", 480, 680, 2000,"center", 0, 2/5)
	end
	
	--/--
	
	if self.selected_item then
		if self.selected_item.kind > 0 then
			View.draw(Item.icons[self.selected_item.kind], 925, 0, 0, 0.7)
		end
		
		View.setFont(Constants.FONT_DUMBLEDOR)
		View.printf(self.selected_item.name, 920, 250, 600, "center", 0, 3/5)
		View.setFont(Constants.FONT)

		local stat, value, color, sign
		local verbose = {hp="Max HP",mov="Mov",atk="Atk",def="Def",matk="M Atk",mdef="M Def",speed="Speed",luck="Luck"}
		local index = 0

		for stat, value in pairs(self.selected_item.stats) do
			if value > 0 then
				color = {0,1,0}
				sign = '+' 
			else 
				color = {1,0,0}
				sign = '' 
			end
			View.print({color, verbose[stat]..": "..sign..value}, 930 + 170*(index%2), 340+50*math.floor(index/2), 0, 2/5)
			index = index + 1
		end
	end
	
	--/--
	
	View.setColor(0,0,0)
	
	View.printf("Stats", 0,  490, 800,"center", 0, 0.6)
	
	local stats = GameController.player:get_stats()
	
	View.print("Max HP: "..stats.hp	, 20,  550, 0, 0.4)
	View.print("Mov: "..stats.mov	, 260, 550, 0, 0.4)
	View.print("Atk: "..stats.atk	, 20,  590, 0, 0.4)
	View.print("Def: "..stats.def	, 260, 590, 0, 0.4)
	View.print("M Atk: "..stats.matk, 20,  630, 0, 0.4)
	View.print("M Def: "..stats.mdef, 260, 630, 0, 0.4)
	View.print("Speed: "..stats.speed, 20, 670, 0, 0.4)
	View.print("Luck: "..stats.luck	, 260, 670, 0, 0.4)
	View.setColor(1,1,1)
end

function ItemsMenu:show_list()
	local list = self.item_list[math.min(self.category, Constants.ItemCategory.ACC)]
	local index, item, x, y, page
	local offset = 30*self.page+1
	
	page = {unpack(list, offset, offset+29)}

	for index, item in ipairs(page) do
		x = 492 + ((index-1)%10)*79
		y = 435 + math.floor((index-1)/10)*80
		
		if item == Constants.NoneItem then
			View.setColor(0.7,0.7,0.7)
			View.rectangle("fill", x, y, 70, 70, 5)
			View.printf({{0,0,0}, "Remove"}, x,y+(70/2)-15,250, "center", 0, 70/250)
			View.setColor(1,1,1)
		else
			item:draw_icon(x,y,70)
			local equip_list = GameController.player.equipment
			if self.cosmetic_mode then equip_list = GameController.player.cosmetics end
			if equip_list[self.category] and equip_list[self.category].id == item.id then
				View.printf({{0,64,0}, "Equipped"}, x, y+55, 350, "center", 0, 1/5)
			end
		end
	end
	
	if self.category >= Constants.ItemCategory.ACC then
		local other_cat = Constants.ItemCategory.ACC_2 + Constants.ItemCategory.ACC - self.category
		local other_acc_id = GameController.player.equipment[other_cat].id
		for index, item in ipairs(page) do
			if other_acc_id == item.id and item.id>0 then
				x = 492 + ((index-1)%10)*79
				y = 435 + math.floor((index-1)/10)*80
				View.printf({{0,64,0}, "Equipped"}, x, y+55, 350, "center", 0, 1/5)
			end
		end
	end
end

function ItemsMenu:set_category(cat)
	self.category = cat
	self.page = 0
	self.total_pages = math.ceil(table.getn(self.item_list[math.min(self.category, Constants.ItemCategory.ACC)])/30)
	
	if self.cosmetic_mode then
		self.selected_item = GameController.player.cosmetics[cat]
	else
		self.selected_item = GameController.player.equipment[cat]
	end
end

function ItemsMenu:click(x,y,k)
	if k == 2 then
		MyLib.FadeToColor(0.25, {function() 
			MainMenu:new()
		end})
	else
		if self.category then
			
			local lin, col, cat, selected_item
			if (x>=492 and (x-492)%79<=70) then col = math.floor((x-492)/79) + 1 end
			if (y>=435 and y <=670 and (y-435)%80<=70) then lin = math.floor((y-435)/80) end
			cat = math.min(self.category, Constants.ItemCategory.ACC)
			if lin and col then selected_item = self.item_list[cat][30*self.page + 10*lin + col] end
			
			if selected_item then
				if self.category >= Constants.ItemCategory.ACC then
					local other_cat = Constants.ItemCategory.ACC_2 + Constants.ItemCategory.ACC - self.category
					local other_acc_id = GameController.player.equipment[other_cat].id
					if other_acc_id == selected_item.id then
						return
					end
				end
				
				self:request_equip(selected_item, self.category, self.cosmetic_mode)
				return
			end			
		end
		
		if self.total_pages>1 then
			if y > 670 then
				local page_change = 1
				if x < 880 then page_change = -1 end
				
				self.page = math.max(0,math.min(self.page+page_change, self.total_pages-1))
			end
			return
		end
	end
end

function ItemsMenu:close_func()
	Item.icons = {}
end
