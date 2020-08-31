ItemsMenu = Menu:new()
ItemsMenu.__index = ItemsMenu

function ItemsMenu:setup()
	self.submenu = Constants.EnumSubmenu.ITEMS
		
	API.get_player_items()
	
	self.item_list = {{},{},{},{}}
	self.loading = true
	self.cosmetic_mode = false
	
	local tmp = GameController.waiting_api
	GameController.waiting_api = function(response)
		tmp(response)
		self.item_list = GameController.tmp
		GameController.tmp = nil	
		self.loading = nil
		
		Item.load_icons(self.item_list)
		
		MyLib.skip_frame = true
		
		for cat, list in ipairs(self.item_list) do
			if cat ~= Constants.ItemCategory.ARMOR and cat ~= Constants.ItemCategory.WEAPON then
				table.insert(list, 1, Constants.NoneItem)
			end
		end
	end
	
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
end

function ItemsMenu:show()

	local equip_list = GameController.player.equipment
	if self.cosmetic_mode then equip_list = GameController.player.cosmetics end
	local item

	View.line(480,0,480,720)
	View.line(0,480,480,480)
	View.line(480,420, 1280, 420)
	View.line(920,0, 920, 420)
	
	GameController.player:draw_model(35,0,0.55,self.frame)
	View.print(GameController.player.name, 20, 420, 0, 0.5)
	View.print(GameController.player.class.name..", Level "..GameController.player.level, 20, 450, 0, 0.3)
	View.printf(GameController.player.gold.." G", -20, 420, 1600, "right", 0, 0.3)
	View.printf(GameController.player.diamonds.." Diamonds", -20, 450, 1600, "right", 0, 0.3)
	
	View.circle("fill", 440, 380, 35)
	if self.cosmetic_mode then
		View.printf({{0,0,0,1}, "Equipment"}, 405, 375, 350, "center", 0, 1/5)
	else
		View.printf({{0,0,0,1}, "Cosmetics"}, 405, 375, 350, "center", 0, 1/5)
	end
	
	View.printf(("Equip Menu"):translate(), 490, 15, 614, "center", 0, 35/50)
	View.print(GameController.player.name, 490, 65, 0, 15/50)
	View.print(string.format("Level %i %s", GameController.player.level, GameController.player.class.name), 490, 95, 0, 15/50)
	View.print("XP: 0/100", 490, 125, 0, 15/50)
	
	View.print("Wpn:", 490, 180, 0, 15/50)
	item = equip_list[Constants.ItemCategory.WEAPON] or Constants.NoneItem
	View.print(item.name, 560,180,0,15/50)
	
	View.print("Hlm:", 490, 220, 0, 15/50)
	item = equip_list[Constants.ItemCategory.HEAD] or Constants.NoneItem
	View.print(item.name, 560,220,0,15/50)
	
	View.print("Arm:", 490, 260, 0, 15/50)
	item = equip_list[Constants.ItemCategory.ARMOR] or Constants.NoneItem
	View.print(item.name, 560,260,0,15/50)
	
	if self.cosmetic_mode then
	
	else
		View.print("Ac1:", 490, 300, 0, 15/50)
		View.print(equip_list[Constants.ItemCategory.ACC].name, 560,300,0,15/50)
		
		View.print("Ac2:", 490, 340, 0, 15/50)
		View.print(equip_list[Constants.ItemCategory.ACC_2].name, 560,340,0,15/50)
	end
	
	if self.category then
		self:show_list()
	end
	
	if self.selected_item then
		if self.selected_item.kind > 0 then
			View.draw(Item.icons[self.selected_item.kind], 925, 0, 0, 0.7)
		end
		
		View.printf(self.selected_item.name, 920, 250, 450, "center", 0, 4/5)
	end
	
	if self.total_pages>1 then
		View.printf("< Page "..(self.page+1).." >", 480, 680, 2000,"center", 0, 2/5)
	end
	
	View.printf("Stats", 0,  490, 800,"center", 0, 0.6)
	
	local stats = GameController.player.stats
	View.print("Max HP: "..stats.hp	, 20,  550, 0, 0.4)
	View.print("Atk: "..stats.atk	, 20,  590, 0, 0.4)
	View.print("Def: "..stats.def	, 260, 590, 0, 0.4)
	View.print("M Def: "..stats.mdef, 20,  630, 0, 0.4)
	View.print("Luck: "..stats.luck	, 260, 630, 0, 0.4)
	View.print("Speed: "..stats.speed, 20,  670, 0, 0.4)
	View.print("Mov: "..stats.mov	, 260, 670, 0, 0.4)
	
	if self.loading then
		Utils.draw_loading(self.timer/15)
	end
end

function ItemsMenu:handle_response(response, calling_api)
	if calling_api.message == "equip" then
		if self.cosmetic_mode then
			if calling_api.item.id == Constants.NoneItem.id then
				GameController.player.cosmetics[calling_api.category] = nil
			else
				GameController.player.cosmetics[calling_api.category] = calling_api.item
			end
		else
			GameController.player.equipment[calling_api.category] = calling_api.item
		end
		
		local cats = {"weapon", "helm","armor"}
		if cats[self.category] then GameController.player:update_model(cats[self.category]) end
	end
	self.calling_api = nil
end

function ItemsMenu:sub_update(dt)
	self.frame = math.floor(self.timer/3)%120 + 1
	
	self.selected_item = nil
	self.cat_selected = nil
	local col, lin, cat = nil, nil, nil
	local mx, my = Utils.convert_coords(love.mouse.getPosition())
	
	self.equip_selected = (my < 410)
	
	if self.equip_selected then
		if (mx>=490 and mx <= 920) and (my>168 and (my<288 or (my<408 and not self.cosmetic_mode))) then
			self.cat_selected = math.ceil((my-168)/40)
			if self.cosmetic_mode then
				self.selected_item = GameController.player.cosmetics[self.cat_selected] or Constants.NoneItem
			else
				self.selected_item = GameController.player.equipment[self.cat_selected]
			end
		end
	elseif self.category then
		if (mx>=492 and (mx-492)%79<=70) then col = math.floor((mx-492)/79) + 1 end
		if (my>=435 and my <=670 and (my-435)%80<=70) then lin = math.floor((my-435)/80) end
		
		cat = math.min(self.category, Constants.ItemCategory.ACC)
		if lin and col then self.selected_item = self.item_list[cat][30*self.page + 10*lin + col] end
		
		if self.total_pages>1 then
			if my > 670 then
				self.page_change = 1
				if mx < 880 then self.page_change = -1 end
			end
		end
	end
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

--TODO: Alterar pra considerar que não tem dados de update
function ItemsMenu:click(x,y,k)
	if k == 2 then
		MyLib.FadeToColor(0.25, {function() 
			MainMenu:new()
		end})
	else
		if (440-x)*(320-x) + (440-y)*(320-y) <= 35*35 then
			self.cosmetic_mode = not self.cosmetic_mode
			return
		end
		if self.cat_selected then
			self.category = self.cat_selected
			self.page = 0
			self.total_pages = math.ceil(table.getn(self.item_list[math.min(self.category, Constants.ItemCategory.ACC)])/30)
		
		elseif self.selected_item then
			if self.category >= Constants.ItemCategory.ACC then
				local other_cat = Constants.ItemCategory.ACC_2 + Constants.ItemCategory.ACC - self.category
				local other_acc_id = GameController.player.equipment[other_cat].id
				if other_acc_id == self.selected_item.id then
					return
				end
			end
			
			API.equip_item(self.selected_item, self.category, self.cosmetic_mode)
			self.calling_api = {message="equip", category = self.category, item=self.selected_item}
		
		elseif self.page_change then
			self.page = math.max(0,math.min(self.page+self.page_change, self.total_pages-1))
		end
	end
end

function ItemsMenu:close_func()
	Item.icons = {}
end