TasksMenu = Menu:new()
TasksMenu.__index = TasksMenu

function TasksMenu:setup()
	self.submenu = Constants.EnumSubmenu.TASKS
	
	self.task_list = {player={}, all={}}
	
	self.buttons = {
		{
			x = 480, y = 80, w = 150, h = 35, text = {{0,0,0,1}, ("Add Task"):translate()},
			click = function() self:new_task() end
		},
		{
			x = 600, y = 540, w = 80, h = 35, text = {{0,0,0,1}, ("Add Task"):translate()},
			click = function() self:register_task() end, disabled = true
		}
	}

	self.loading=true
	API.load_tasks()
	Promise:new():success(function(response) 
		self.task_list = response
	end):after(function()
		self.loading = false
	end)
end

function TasksMenu:new_task()
	self.buttons[1].disabled = true
	self.buttons[2].disabled = nil
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

function TasksMenu:register_task()
	API.create_task(self.creating_task)
	self:reload_promise()
	self:close_popup()
end

function TasksMenu:reload_promise()
	self.loading = true
	Promise:new():after(function(response)
		API.load_tasks()
		Promise:new():success(function(response) 
			self.task_list = response
		end):after(function()
			self.loading = false
		end)
	end)
end

function TasksMenu:show()
	View.printf(("Tasks"):translate(), 0, 15, 1829, "center", 0, 35/50)
	View.printf(("My Tasks"):translate(), 0, 85, 1280, "center", 0, 1/2)
	View.printf(("Other Tasks"):translate(), 640, 85, 1280, "center", 0, 1/2)
	View.line(0, 70, 1280, 70)
	View.line(640, 70, 640, 720)
	
	local idx, task, day, hour, minute
	local task_types = {"", " - Daily", " - Weekly", " - Monthly"}
	for idx, task in ipairs(self.task_list.player) do	
		View.line(0,25 + 100*idx,640,25 + 100*idx)
		View.line(0,125 + 100*idx,640,125 + 100*idx)
		
		View.print(task.name..task_types[task.type]:translate(), 20, 25 + 100*idx, 0, 1/3)
		View.printf(task.description, 20, 50 + 100*idx, 1280, "left", 0, 1/4)
		
		if task.type > 1 and not task.finished then
			minute = string.format("%02d", math.floor(task.time_left/60)%60)
			hour = string.format("%02d", math.floor(task.time_left/3600)%24)
			day = string.format("%02d", math.floor(task.time_left/86400))
			
			View.print(("Time Left"):translate(), 550, 65+100*idx, 0, 1/4)
			View.print(day..":"..hour..":"..minute..":"..task.time_left%60, 550, 85+100*idx, 0, 1/4)
		end
		
		if task.finished then
			View.print("V", 410, 60 + 100*idx, 0, 1/5)
			View.print("X", 460, 60 + 100*idx, 0, 1/5)
			View.print(task.approvals, 410, 90 + 100*idx, 0, 1/5)
			View.print(task.reports, 460, 90 + 100*idx, 0, 1/5)
		else
			View.rectangle("fill", 360, 60 + 100*idx, 150, 40)
			View.printf({{0,0,0,1}, ("Finish Task"):translate()}, 360, 70 + 100*idx, 375 ,"center", 0, 2/5)
		end
	end
	
	for idx, task in ipairs(self.task_list.all) do
		View.line(640,25 + 100*idx,1280,25 + 100*idx)
		View.line(640,125 + 100*idx,1280,125 + 100*idx)
		
		View.print(task.name..task_types[task.type]:translate(), 660, 25 + 100*idx, 0, 1/3)
		View.printf(task.description, 660, 50 + 100*idx, 1280, "left", 0, 1/4)
		
		View.circle("fill", 1025, 80+100*idx, 25)
		View.print(task.approvals, 1055, 70+100*idx, 0, 1/5)
		View.circle("fill", 1125, 80+100*idx, 25)
		View.print(task.reports, 1155, 70+100*idx, 0, 1/5)
	end
	
	self:draw_btn(self.buttons[1])
	
	if self.creating_task then
		self:create_popup()
	end
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
		for _, task in ipairs(self.task_list.player) do task.time_left = math.max(0,task.time_left - 1) end
		for _, task in ipairs(self.task_list.all) do task.time_left = math.max(0,task.time_left - 1) end
	end
	if self.creating_task then
		self.creating_task.name = self.name_box.text
		self.creating_task.description = self.desc_box.text
	end
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
	
		local idx, task
		if x >=360 and x <= 510 then
			for idx, task in ipairs(self.task_list.player) do
				if not task.finished then
					if y>= 60+100*idx and y<= 100 + 100*idx then
						API.finish_task(task)
						self:reload_promise()
						return
					end
				else
					return
				end
			end
		elseif x>=1000 and x<=1150 then
			local y_delta
			for idx, task in ipairs(self.task_list.all) do
				y_delta = (y-(80+100*idx))*(y-(80+100*idx))
				if not task.reviewed then
					if y_delta + (1025-x)*(1025-x) <= 625 then
						API.review_task(task, true)
						self:reload_promise()
						return
					elseif y_delta + (1125-x)*(1125-x) <= 625 then
						API.review_task(task, false)
						self:reload_promise()
						return
					end
				end
			end
		end
	end
end
