SkillMenu = Menu:new()
SkillMenu.__index = SkillMenu

function SkillMenu:setup()
	self.submenu = Constants.EnumSubmenu.SKILL
	self.skill_list = {}
	
	local skill
	self.player_set = {}
	for _, skill in ipairs(GameController.player.skills) do self.player_set[skill.id] = true end
	
	self.class_icons = love.graphics.newImage('assets/icons/Class_Icons.png')
	self.class_quads = {}
	
	self.grid_img = self:load_grid()
	
	for i=0,2 do table.insert(self.class_quads, View.newQuad(i*100, 0, 100, 100, 300, 100)) end
		
	self.loading=true
	API.get_player_skills()
	Promise:new():success(function(response) 
		self.skill_list = response
		Skill.loaded_skills = Skill:translate_response(response)
	end):after(function()
		self.loading = false
	end)
end

function SkillMenu:show()
	local player = GameController.player
	
	View.printf(("Skills"):translate(), 0, 15, 1829, "center", 0, 35/50)
	
	View.printf("Level "..player.level.." "..player.class.name, 0, 70, 3200,"center",0, 0.4)
	
	self:show_class_tree()
	
	View.line(320,0,320,720)
	View.line(0,480,320,480)
	View.line(320,120, 1280, 120)
	View.line(960,120, 960, 720)
	View.line(320,510, 960, 510)
	
	local idx, skill,x, y
	for idx, skill in ipairs(self.skill_list) do
		x = 330 + 320*((idx-1)%2)
		y = 130 + 30*math.floor((idx-1)/2)
		
		if self.player_set[skill.id] then
			View.circle("fill", x+10, y+10, 10)
		end
		
		View.print(skill.name, x + 30, y, 0, 0.4)
	end
	
	for idx = 1,4 do
		x = 400 + (idx-1)*160
		y = 635 - 40*(idx%2)
		if GameController.player.skills[idx] and not self.on_setup then
			skill = Skill:get(GameController.player.skills[idx].id)
			View.setColor(1,1,1)
			View.printf(skill.name, x-80, y-10, 400, "center", 0, 0.4)
		else
			View.setColor(0.2,0.2,0.2)
		end
		
		View.circle("line", x, y, 75)
	end
	
	View.setColor(1,1,1)
	
	if self.selected_skill then
		self:show_skill()
	end
end

function SkillMenu:show_class_tree()
	View.print("<Class Tree here>", 30, 220, 0, 0.5)
end

function SkillMenu:show_skill()
	local skill = self.selected_skill
	local x, y, pos
	View.printf(skill.name, 960,130,640, "center", 0, 0.5)
	View.printf(skill.description, 970,400,1200, "left", 0, 0.25)
		
	self:draw_grid()
	
	if skill.effect.type == "damage" then
		View.print("Power: "..skill.effect.power, 970,470, 0, 0.25)
	end
end

function SkillMenu:draw_grid()
	View.setColor(0.2,0.2,0.2)
	View.draw(self.grid_img, 990,170)
	
	View.setColor(0.3,0,0)
	for _, pos in ipairs(self.skill_range) do
		x = 1022 + pos[1]*65/2 + pos[2]*65/2
		y = 305 - pos[1]*15 + pos[2]*15
		self:draw_square_grid(x,y, "fill")
	end
	
	View.setColor(0.9,0,0)
	for _, pos in ipairs(self.skill_range) do
		x = 1022 + pos[1]*65/2 + pos[2]*65/2
		y = 305 - pos[1]*15 + pos[2]*15
		self:draw_square_grid(x,y)
	end
	
	View.setColor(0,1,0.2)
	x = 1022
	y = 305
	self:draw_square_grid(x,y)
	love.graphics.polygon("fill", x+41, y - 11,  x+57, y-11, x+57, y-4)
	
	View.setColor(1,1,1)
	View.rectangle("line", 990, 170, 260, 200)
end

function SkillMenu:draw_square_grid(x, y, mode)
	love.graphics.polygon(mode or "line", x, y, x+65/2, y - 15, x+65, y, x+65/2, y+15)
end

function SkillMenu:load_grid()
	local canvas = View.newCanvas(260,200)
	View.setCanvas(canvas)
	love.graphics.push()
	love.graphics.origin()
	for i=-3,8 do
	View.line(0,0+30*i,260,120+30*i)
	View.line(0,120+30*i,260,0+30*i)
	end
	love.graphics.pop()
	View.setCanvas()
	return love.graphics.newImage(canvas:newImageData())
end

function SkillMenu:get_skill_range()
	local pos
	local delta, letter
	local elem, i
	local rot, angle
	local instr = {F=0,R=1,B=2,L=3}
	local skill = self.selected_skill
	
	self.skill_range = {}
	
	for _, elem in ipairs(skill.range) do
		pos = {x=0, y=0}
		for i = 1,string.len(elem)/2 do
			delta = tonumber(elem:sub(2*(i-1)+2,2*(i-1)+2))
			letter = elem:sub(2*(i-1)+1,2*(i-1)+1)

			rot = (instr[letter] + 1)%4
			angle = (rot/2)*math.pi
			pos.x = pos.x + math.floor(math.sin(angle)*delta +0.5)
			pos.y = pos.y - math.floor(math.cos(angle)*delta +0.5)
		end
		
		table.insert(self.skill_range, {pos.x, pos.y})
	end
end

function SkillMenu:click(x,y,k)
	if k == 2 then
		MyLib.FadeToColor(0.25, {function() 
			MainMenu:new()
		end})
	else
		if x>=320 and x<960 and y>=120 and y<500 then
			local lin = math.floor((y-120)/30)
			local col = math.floor((x-320)/320)
			
			self.selected_skill = self.skill_list[2*lin+col+1]
			if self.selected_skill then self:get_skill_range() end
		end
	end
end

function SkillMenu:close_func()
	Skill.loaded_skills = {}
end