TasksMenu = Menu:new()
TasksMenu.__index = TasksMenu

function TasksMenu:setup()
	self.submenu = Constants.EnumSubmenu.TASKS
	
	self.task_list = {player={}, all={}}
	
	self.buttons = {
		{
			x = 565, y = 675, w = 150, h = 35, text = {{0,0,0,1}, ("Add Task"):translate()},
			click = function() self:new_task() end
		},
		{
			x = 600, y = 540, w = 80, h = 35, text = {{0,0,0,1}, ("Add Task"):translate()},
			click = function() self:register_task() end, disabled = true
		},
		{
			x = 195, y = 39, w = 250, h = 59, text = "",
			click = function() self.list_toggle = false end
		},
		{
			x = 835, y = 39, w = 250, h = 59, text = "",
			click = function() self.list_toggle = true end
		}
	}
		
	self.sprites = {
		bg_img = love.graphics.newImage("assets/menus/MenuTasks.png"),
		tab = love.graphics.newImage("assets/menus/ShopTab.png"),
	}
	
	self.loading=true
	self.list_toggle = false
	self.scroll = {0,0,0,0,0}
	self.scroll_size = {1,1,1,1,1}
	
	self.tab_size = {1,0}

	self.player_task_buttons = {}
	self.other_task_buttons = {}
	
	API.load_tasks():success(function(response)
		self.task_list = response
		self:register_buttons()
		self:update_scrolls()
	end):after(function()
		self.loading = false
	end)
end

function TasksMenu:update_scrolls()
	local total_tasks = {0,0,0,0,0}
	local task, task_type
	for _, task in ipairs(self.task_list.player) do
		total_tasks[task.type] = total_tasks[task.type] + 1
	end
	
	for task_type = 1,4 do
		if total_tasks[task_type] > 7 then
			self.scroll_size[task_type] = 7/total_tasks[task_type]
		else
			self.scroll_size[task_type] = 1
		end
	end
	
	self.scroll_size[5] = 1
	total_tasks[5] = math.ceil(#self.task_list.all/4)
	if total_tasks[5] > 5 then
		self.scroll_size[5] = 5/total_tasks[5]
	end
end

function TasksMenu:register_buttons()
	local idxs = {0,0,0,0}	
	local idx, x, y
	
	self.player_task_buttons = {}
	
	for _, task in ipairs(self.task_list.player) do	
		idxs[task.type] = idxs[task.type] + 1
		idx = idxs[task.type]
		x = 15 + 320 * (task.type-1)
		y = 105 + 70*idx
	
		table.insert(self.player_task_buttons, {
			x = x+5, y = y+30, w = 80, h=25, text = ("Finish"):translate(), disabled = task.finished,
			click = function() self:finish_task(task) end
		})
		table.insert(self.player_task_buttons, {
			x = x+235, y = y+42, r = 12, text = "", form = "circle",
			click = function()
			if not self.viewing_details then self.viewing_details = task end end
		})
	end
	
	self.other_task_buttons = {}
	
	for idx, task in ipairs(self.task_list.all) do	
		x = 15 + 310*((idx-1)%4)
		y = 75 + 100*math.ceil(idx/4)
	
		table.insert(self.other_task_buttons, {
			x = x+255, y = y+15, r = 10, text = "", form = "circle", disabled=task.reviewed,
			click = function() self:review_task(task, true) end
		})
		table.insert(self.other_task_buttons, {
			x = x+255, y = y+40, r = 10, text = "", form = "circle", disabled=task.reviewed,
			click = function() self:review_task(task, false) end
		})
		table.insert(self.other_task_buttons, {
			x = x+255, y = y+72, r = 12, text = "", form = "circle",
			click = function()
			if not self.viewing_details then self.viewing_details = task end end
		})
	end
end

function TasksMenu:move_buttons()
	local idx, task, btn_idx, delta_y, y
	local idxs = {0,0,0,0}
	
	if self.list_toggle then
		for idx, task in ipairs(self.task_list.all) do
			y = 75 + 100*math.ceil(idx/4)
			delta_y = self.scroll[5]*500*((1/self.scroll_size[5])-1)
			self.other_task_buttons[3*(idx-1) + 1].y = y + 15 - delta_y
			self.other_task_buttons[3*(idx-1) + 2].y = y + 40 - delta_y
			self.other_task_buttons[3*(idx-1) + 3].y = y + 72 - delta_y
		end
	else
		for idx, task in ipairs(self.task_list.player) do	
			idxs[task.type] = idxs[task.type] + 1
			btn_idx = idxs[task.type]
			
			delta_y = self.scroll[task.type]*500*((1/self.scroll_size[task.type])-1)
		
			self.player_task_buttons[2*(idx-1) + 1].y = 135 + 70*btn_idx - delta_y
			self.player_task_buttons[2*(idx-1) + 2].y = 147 + 70*btn_idx - delta_y
		end
	end
end

function TasksMenu:new_task()
	self.buttons[1].disabled = true
	self.buttons[2].disabled = false
	self.creating_task = {name = "", description = "", type = 1}
	Textbox:init()
	self.name_box = Textbox:new("name",350,200,380,40, {1,0.5,0.5})
	self.desc_box = Textbox:new("desc",350,300,380,200, {1,0.5,0.5}, 5)
end

function TasksMenu:close_popup()
	Textbox:dispose()
	self.creating_task = nil
	self.buttons[1].disabled = nil
	self.buttons[2].disabled = true
end

function TasksMenu:review_task(task, is_positive)
	self:reload_promise(API.review_task(task, is_positive))
end

function TasksMenu:finish_task(task)
	if task.finished then return end
	self:reload_promise(API.finish_task(task))
end

function TasksMenu:register_task()
	self:reload_promise(API.create_task(self.creating_task))
	self:close_popup()
end

function TasksMenu:reload_promise(promise)
	self.loading = true
	promise:after(function()
		API.load_tasks():success(function(response)
			self.task_list = response
			self:register_buttons()
			self:update_scrolls()
		end):after(function()
			self.loading = false
		end)
	end)
end

function TasksMenu:show()
	
	View.draw(self.sprites.bg_img, 0, 0, 0, 2/3)
	
	--/--

	View.printf(("Tasks"):translate(), 0, 10, 1829, "center", 0, 35/50)
	
	local tab_x = 195
	local idx
	for idx = 1,2 do
		View.draw(self.sprites.tab, tab_x, 39 + 59*(1-self.tab_size[idx]), 0, 1, self.tab_size[idx])
		tab_x = tab_x + 640
	end
	
	View.printf(("My Tasks"):translate(), 0, 55, 1280, "center", 0, 1/2)
	View.printf(("Other Tasks"):translate(), 640, 55, 1280, "center", 0, 1/2)
	
	--/--
	
	local task, day, hour, minute, x, y, btn_idx
	local idxs = {0,0,0,0}
	local timer = {nil,nil,nil,nil}

	local function scroll_stencil()
	   love.graphics.rectangle("fill", 0, 164, 1280, 502)
	end

	View.stencil(scroll_stencil, "replace", 1) 
    View.setStencilTest("greater", 0)
	
	if self.list_toggle then
	
		for idx, task in ipairs(self.task_list.all) do
			btn_idx = 3*(idx-1) + 1
			x = 15 + 310 * ((idx-1)%4)
			y = 75 + 100*math.ceil(idx/4) - self.scroll[5]*500*((1/self.scroll_size[5])-1)
			
			self:draw_panel(x,y,280,90)
			
			View.setColor(0,0,0)
			View.print(task.name, x+5, y+5, 0, 1/3)
			View.print(task.owner, x+5, y+25, 0, 1/4)
			View.print(task.description, x+5, y+45, 0, 1/5)
			
			View.print(task.approvals, x+230, y+10, 0, 1/5)
			View.print(task.reports, x+230, y+35, 0, 1/5)
			
			self:draw_btn(self.other_task_buttons[btn_idx])
			self:draw_btn(self.other_task_buttons[btn_idx+1])
			self:draw_btn(self.other_task_buttons[btn_idx+2])
		end
		
		View.setColor(1,1,1)
		y = 165 + self.scroll[5]*(500*(1-self.scroll_size[5]))
		View.rectangle("line", 290+320*(3), 165, 20, 500)
		View.rectangle("fill", 290+320*(3), y, 20, 500 * self.scroll_size[5])
		
		--/--
	
	else
		
		for i=1,3 do
			View.draw(self.div_img, 320*i, 100, 0, 1, 680)
		end
		
		for idx, task in ipairs(self.task_list.player) do
			btn_idx = 2*(idx-1) + 1
			idxs[task.type] = idxs[task.type] + 1
			idx = idxs[task.type]
			x = 15 + 320 * (task.type-1)
			y = 105 + 70*idx - self.scroll[task.type]*500*((1/self.scroll_size[task.type])-1)
			
			self:draw_panel(x,y,260,60)
			
			View.setColor(0,0,0)
			
			View.print(task.name, x+5, y+5, 0, 1/3)
			
			if task.type > 1 and not task.finished and not timer[task.type] then
				minute = string.format("%02d", math.floor(task.time_left/60)%60)
				hour = string.format("%02d", math.floor(task.time_left/3600)%24)
				day = string.format("%02d", math.floor(task.time_left/86400))
				
				timer[task.type] = day..":"..hour..":"..minute..":"..string.format("%02d",task.time_left%60)
			end
						
			if task.finished then
				View.print("V: "..task.approvals, x+40, y+40, 0, 1/5)
				View.print("X: "..task.reports, x+90, y+40, 0, 1/5)
			else
				self:draw_btn(self.player_task_buttons[btn_idx])
			end
			self:draw_btn(self.player_task_buttons[btn_idx + 1])
		end
		
		View.setColor(1,1,1)
		local scroll_idx
		for scroll_idx = 1, 4 do
			y = 165 + self.scroll[scroll_idx]*(500*(1-self.scroll_size[scroll_idx]))
			View.rectangle("line", 290+320*(scroll_idx-1), 165, 20, 500)
			View.rectangle("fill", 290+320*(scroll_idx-1), y, 20, 500 * self.scroll_size[scroll_idx])
		end
	end
	
	View.setStencilTest()
	
	if not self.list_toggle then
		local names = {"One-Off", "Daily", "Weekly", "Monthly"}
		
		for idx = 1,4 do
			x = 15 + 320 * (idx-1)
			View.printf(names[idx]:translate(), x, 105, 640, "center", 0, 1/2)
			if timer[idx] then
				View.printf("Time left:"..timer[idx], x, 135, 960, "center", 0, 1/3)
			end
		end
	end
	
	self:draw_btn(self.buttons[1])
	
	--/--
	
	if self.creating_task then
		self:create_popup()
	end
	
	if self.viewing_details then
		self:show_details(self.viewing_details)
	end
end

function TasksMenu:show_details(task)
	View.setColor(0,0,0,0.5)
	View.rectangle("fill", 0,0,1280,720)
	View.setColor(0.1,0,0,1)
	View.rectangle("fill", 320, 180, 640, 360)
	View.setColor(1,1,1,1)
	View.rectangle("line", 320, 180, 640, 360)
	
	View.printf(("Task Details"):translate(), 0, 190, 2560, "center", 0, 0.5)
	
	local cats = {"One-Off task", "Daily task", "Weekly task", "Monthly task"}
	View.print(task.name.." - "..cats[task.type]:translate(), 330, 230, 0, 0.4)
	View.print(("Task by"):translate().." "..task.owner, 330, 260, 0, 0.3)
	View.printf(("Description"):translate()..":", 330, 360, 2067, "left", 0, 0.3)
	View.print(task.description, 330, 380, 0, 0.3)
	
	if task.finished then
		View.print(("Approvals"):translate()..": "..task.approvals, 330, 300, 0, 0.3)
		View.print(("Reports"):translate()..": "..task.reports, 330, 320, 0, 0.3)
	else
		local minute, day, hour, time_str
		minute = string.format("%02d", math.floor(task.time_left/60)%60)
		hour = string.format("%02d", math.floor(task.time_left/3600)%24)
		day = string.format("%02d", math.floor(task.time_left/86400))
		
		time_str = day..":"..hour..":"..minute..":"..string.format("%02d",task.time_left%60)
		View.print(("Time left"):translate()..":", 330, 300, 0, 0.3)
		View.print(time_str, 330, 320, 0, 0.3)
	end
	
	View.printf(("Click anywhere to close"):translate(), 0, 510, 5120, "center", 0, 0.25)
end

function TasksMenu:create_popup()
	View.setColor(0,0,0,0.5)
	View.rectangle("fill", 0,0,1280,720)
	View.setColor(0,0,0,1)
	View.rectangle("fill", 320,120,640,480)
	View.setColor(1,1,1,1)
	View.rectangle("line", 320,120,640,480)
	
	View.printf(("New Task"):translate(), 320, 130, 1280, "center", 0, 1/2)
	View.print(("Name"):translate(), 350, 170, 0, 1/3)
	View.print(("Description"):translate(), 350, 270, 0, 1/3)
	
	View.print(("One-Off"):translate(), 820, 250, 0, 1/3)
	View.print(("Daily"):translate(), 820, 300, 0, 1/3)
	View.print(("Weekly"):translate(), 820, 350, 0, 1/3)
	View.print(("Monthly"):translate(), 820, 400, 0, 1/3)
	
	local i
	for i=1,4 do
		View.rectangle("line", 790, 200+i*50, 20, 20)
	end
	
	View.rectangle("fill", 790, 200+self.creating_task.type*50, 20, 20)
	
	self:draw_btn(self.buttons[2])
end

function TasksMenu:sub_update(dt)
	if self.timer >= 60 then 
		self.timer = self.timer - 60
		for _, task in ipairs(self.task_list.player) do
			if task.time_left == 1 then API.load_tasks() self:reload_promise() end
			task.time_left = math.max(0,task.time_left - 1)
		end
	end
	if self.creating_task then
		self.creating_task.name = self.name_box.text
		self.creating_task.description = self.desc_box.text
	end
	if self.scrolling then
		if not self:is_down(1) then
			self.scrolling = nil
		else
			local y, max_scroll, progress
			_, y = self:get_mouse_position()
			y = (y - 165) - 250*self.scroll_size[self.scrolling]
			max_scroll = 500 - 500*self.scroll_size[self.scrolling]
			self.scroll[self.scrolling] = math.max(0, math.min(y, max_scroll))/max_scroll
			self:move_buttons()
		end
	end
	
	local curr_tab = 1
	if self.list_toggle then curr_tab = 2 end
	
	self.tab_size[curr_tab] = math.min(1, self.tab_size[curr_tab] + 10*dt)
	self.tab_size[curr_tab%2 + 1] = math.max(0, self.tab_size[curr_tab%2 + 1] - 10*dt)
end

function TasksMenu:mousepressed(x,y,k) 
	if self.loading or self.disabled then return end
		
	if (x<=60 and y<=60) and self.back_btn then
		MyLib.FadeToColor(0.25, {function() 
			self:close_func() 
			MainMenu:new()
		end})
		self.disabled = true
		return
	end
	
	if k == 1 then
		if self.viewing_details then 
			self.viewing_details = nil 
			return 
		end
		local btn, idx
		for _, btn in ipairs(self.buttons) do
			if not btn.disabled then
				if btn.form == "circle" then
					if (btn.x-x)*(btn.x-x) + (btn.y-y)*(btn.y-y) <= btn.r*btn.r and not btn.disabled then
						btn.click()
						return
					end
				else
					if x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h and not btn.disabled then
						btn.click()
						return
					end
				end
			end
		end
		
		if y >= 165 and y <= 665 and not self.creating_task then
			local btn_list = self.player_task_buttons
			if self.list_toggle then btn_list = self.other_task_buttons end
			for _, btn in ipairs(btn_list) do
				if not btn.disabled then
					if btn.form == "circle" then
						if (btn.x-x)*(btn.x-x) + (btn.y-y)*(btn.y-y) <= btn.r*btn.r and not btn.disabled then
							btn.click()
							return
						end
					else
						if x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h and not btn.disabled then
							btn.click()
							return
						end
					end
				end
			end
		end
	end
	
	self:click(x,y,k)
end

function TasksMenu:click(x,y,k)
	if k == 2 then
		MyLib.FadeToColor(0.25, {function() 
			Textbox:dispose()
			MainMenu:new()
		end})
	else
	
		if self.creating_task then
			if x >= 320 and x <= 960 and y>= 120 and y<= 600 then
				if x>= 790 and x<= 810 and y>= 250 and y <= 420 and y%50<=20 then
					self.creating_task.type = math.floor((y-200)/50)
				end
			else
				self:close_popup()
			end
			return
		end
		
		if x%320 > 290 and x%320 < 310 and y > 165 and y < 665 and not self.list_toggle then
			local scroll = math.ceil(x/320)
			if self.scroll_size[scroll] < 1 then
				self.scrolling = scroll
			end
		end
		if self.list_toggle and x > 290+(3*320) and x < 310+(3*320) and y > 165 and y < 665 then
			self.scrolling = 5
		end
	end
end
