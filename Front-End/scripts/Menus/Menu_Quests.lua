QuestsMenu = Menu:new()
QuestsMenu.__index = QuestsMenu

function QuestsMenu:setup()
	self.submenu = Constants.EnumSubmenu.MISSIONS
	self.selection = nil
	self.mouseover = nil
	self.mouseover_diff = nil
	self.mouseover_go = nil
	self.diff_select = nil
	self.quest_list = {}
	self.total_quests = #self.quest_list
	
	self.loading = true
	
	API.get_quests():success(function(response)
		local each
		for _, each in ipairs(response) do				
			table.insert(self.quest_list, Quest:new(each))
		end
		self.total_quests = #self.quest_list
	end):after(function()
		self.loading = nil
	end)
	
	View.setLineWidth(3)
end

function QuestsMenu:show()
	local index, quest

	View.line(0,130,1280,130)
	View.line(320,130,320,720)

	View.printf(("Quests"):translate(), 0, 15, 1829, "center", 0, 35/50)
	View.printf(("Energy"):translate()..":", 0, 60, 3200, "center", 0, 2/5)
	View.printf("100/100", 0, 90, 3200, "center", 0, 2/5)
	
	if self.selection then
		self:show_quest()
	else
		View.printf(("Select a quest"):translate(), 320, 400, 2400, "center", 0, 2/5)
	end
	
	for index, quest in ipairs(self.quest_list) do
		View.print(quest.name, 30, 160+40*(index-1),0,15/50)
	end
	
end

function QuestsMenu:sub_update(dt)
	local mx, my = Utils.convert_coords(love.mouse.getPosition())
	
	self.mouseover = nil
	self.mouseover_go = nil
	self.mouseover_diff = nil
	
	if mx<=320 and my>150 and my<=150+40*self.total_quests then
		local index = math.ceil((my - 150)/40)
		self.mouseover = self.quest_list[index]
	end
	
	if self.selection then
		if mx>=320 and mx <= 790 and my > 450 and my <= 630 then
			self.mouseover_diff = math.ceil((my-450)/60)
		end
	end
	
	if self.diff_select and my>645 and mx>700 and mx<900 then
		self.mouseover_go = true
	end
end

--TODO: Alterar pra considerar que não tem dados de update
function QuestsMenu:click(x,y,k)
	if self.disabled then return end
	
	if k == 2 then
		MyLib.FadeToColor(0.25, {function() 
			MainMenu:new()
		end})
	 else
		if self.mouseover then
			self.selection = self.mouseover
			self.mouseover_diff = nil
			self.diff_select = nil
		end
		if self.mouseover_diff then
			self.diff_select = self.mouseover_diff
		end
		if self.mouseover_go then
			self.disabled = true
			self.loading = true
			
			API.enter_quest(self.selection, self.diff_select):success(function(response)
				MyLib.FadeToColor(0.25, {function()
					GameController.player:unload_model()
					GameController.start_quest(response.quest, response.diff, response.actions)
				end})
			end):fail(function(data)
				self.disabled = nil
				self.loading = nil
				API.error(data)
			end)
		end
	end
end

function QuestsMenu:show_quest()	
	View.printf(self.selection.name:translate(), 320, 150, 2400, "center", 0, 2/5)
	View.printf(self.selection.description:translate(), 340, 220, 3000, "left", 0, 15/50)
	
	View.printf(("Difficulties"):translate(), 340, 400, 1200, "center", 0, 2/5)
	
	View.print(("Easy"):translate(), 340, 470, 0, 15/50)
	if self.selection.cleared[Constants.EnumDiff.EASY] then View.print(("Cleared"):translate(), 520, 470, 0, 15/50) end
	
	View.print(("Medium"):translate(), 340, 530, 0, 15/50)
	if self.selection.cleared[Constants.EnumDiff.MEDIUM] then View.print(("Cleared"):translate(), 520, 530, 0, 15/50) end
	
	View.print(("Hard"):translate(), 340, 590, 0, 15/50)
	if self.selection.cleared[Constants.EnumDiff.HARD] then View.print(("Cleared"):translate(), 520, 590, 0, 15/50) end
	
	if self.diff_select then
		View.printf(("Rewards"):translate(), 800, 400, 1200, "center", 0, 2/5)
		View.printf(self.selection:rewards_list_str(self.diff_select), 820, 450, 3000, "left", 0, 15/50)
		
		if not self.selection.cleared[self.diff_select] then
			View.printf(("First Clear Rewards"):translate(), 800, 520, 1200, "center", 0, 2/5)
			View.printf(self.selection:fc_rewards_str(self.diff_select), 820, 570, 3000, "left", 0, 15/50)
		end
		
		View.printf(("Go"):translate(), 320, 650, 2400, "center", 0, 2/5)
		View.printf(("Energy Cost"):translate()..": "..self.selection.energy[self.diff_select], 320, 690, 3200, "center", 0, 15/50)
	end
end