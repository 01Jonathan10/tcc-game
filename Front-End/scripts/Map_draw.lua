Map = Map or {}
Map.__index = Map

-- DESENHO

function Map:draw()
	View.setLineWidth(2)
	local vertices
	local i,j
	
	View.push()
	View.translate(self.camera.x, self.camera.y)
	
	self:draw_grid(sx, sy)
	
	for j=1,self.dim.y do
		for i=self.dim.x,1,-1 do
			self:draw_cell(self[i][j])
		end
	end
	
	if self.mouse_over then
		local sx, sy = self.sx, self.sy
		local cell = self.mouse_over
		local x, y = (cell.x+cell.y)*sx, (cell.y-cell.x)*sy - cell.z*20
		View.setColor(0,0,0.7)
		vertices = {x+8,y,x+sx,y+sy-3,x+2*sx-8,y,x+sx,y-sy+3}
		View.polygon("line",vertices)
	end
	
	View.setColor(1,1,1)
	View.pop()
	
	if self.loading then
		print("loading")
		Utils.draw_loading(self.timer/10)
	end
end

function Map:draw_grid()
	if self.grid_img then View.draw(self.grid_img, 0, 0) return end
	local sx, sy = self.sx, self.sy
	View.setColor(0.3,0.3,0.3)
	local x, y, cell, i, j
	for j=1,self.dim.y do
		for i=self.dim.x,1,-1 do
			cell = self[i][j]
			x, y = (cell.x+cell.y)*sx, (cell.y-cell.x)*sy - cell.z*20
			
			if cell.z > 0 then
				vertices = {x,y, x+sx,y+sy, x+2*sx,y, x+2*sx,y+cell.z*20, x+sx,y+sy+cell.z*20, x,y+cell.z*20}
				View.polygon("fill",vertices)
			end
			
			vertices = {x,y,x+sx,y+sy,x+2*sx,y,x+sx,y-sy}
			View.setColor(0.25,0.25,0.25)
			View.polygon("fill",vertices)
			View.setColor(0.5,0.5,0.5)
			View.polygon("line",vertices)
		end
	end
	
	View.setColor(1,1,1)
end

function Map:draw_cell(cell)
	local sx, sy = self.sx, self.sy
	local x, y = (cell.x+cell.y)*sx, (cell.y-cell.x)*sy - cell.z*20
	
	if cell.highlight then
		if self.phase == Constants.EnumPhase.MOVEMENT then
			View.setColor(0,0.7,0)
		elseif self.phase == Constants.EnumPhase.ACTION then
			View.setColor(1,0,0)
		end
		vertices = {x+16,y,x+sx,y+sy-6,x+2*sx-16,y,x+sx,y-sy+6}
		View.polygon("line",vertices)
	end
	
	View.setColor(1,1,1)
	
	if cell.object then
		local obj = cell.object
		local frame = self.frame
		
		if obj.moving then
			local pos = self.curr_action.position
			local dx, dy = self.curr_action.progress*sx/100, self.curr_action.progress*sy/100
			local cx, cy
			cx, cy = self.curr_action.path[2].x-pos.x, self.curr_action.path[2].y-pos.y
			
			if cx < 0 or cy < 0 then dx = -dx end
			if cx > 0 or cy < 0 then dy = -dy end
			
			if dx < 0 then obj.facing = 3 else obj.facing = 1 end
			
			x, y = (pos.x+pos.y)*sx + dx, (pos.y-pos.x)*sy + dy - pos.z*20
		end
		
		if obj.animation then
			frame = self.frame
		end
		
		obj:draw_mini(x+sx,y,frame)
		
		View.printf(obj.name, x+sx-50, y-200, 400, "center", 0, 0.25)
		self:lifebar(obj, x+sx-50, y-175, 100, 15)
	end
end

function Map:draw_UI()
	local idx, character
	
	character = self.turn_order[self.turn]
	
	View.printf(string.format(("%s's Turn"):translate(), character.name), 0, 10, 2560, "center", 0, 0.5)
	
	local x = 140 + (20-table.getn(self.turn_order))*25
	
	-- Turn Order
	for idx, character in ipairs(self.turn_order) do
		if self.turn_order[self.turn] == character then
			View.rectangle("line", x + 50*(idx-1), 660, 50, 50)
			View.circle("fill", x + 50*(idx-1)+25, 630, 10)
		else
			View.rectangle("line", x + 10 + 50*(idx-1), 680, 30, 30)
		end
	end
	
	-- Player info
	character = GameController.player
	
	self:lifebar(character, 120, 680, 250, 40)
	character:draw_mini(60, 750, self.frame, 1, true)
	View.rectangle("line", 0, 600, 120, 120)
	View.print(character.name, 130, 630, 0, 0.4)
	View.printf(character.curr_hp.."/"..character.stats.hp, 120,687, 500, "center", 0, 0.5)
	
	if self.turn_order[self.turn] == character then
		self:draw_actions()
	end
	
	--	Skill list
	if self.phase == Constants.EnumPhase.ACTION then
		local no_skills = #GameController.player.skills
		local skill, index
			
		View.setColor(0,0,0,0.7)
		View.rectangle("fill", 20, 440-40*no_skills, 330, 40*no_skills)
		
		View.setColor(1,1,1,1)
		for index, skill in ipairs(GameController.player.skills) do
			View.rectangle("line", 20, 440-40*(no_skills-(index-1)), 330, 40)
			View.print(skill.name, 60, 445-40*(no_skills-(index-1)), 0, 3/5)
			
			if self.selected_skill == index then 
				View.circle("fill", 40, 460-40*(no_skills-(index-1)), 10)
			end
		end
	end
	
	if self.curr_action.type == "message" then
		View.setColor(0,0,0,0.5)
		View.rectangle("fill", 240, 540, 800, 160)
		View.setColor(1,1,1,1)
		View.printf(self.curr_action.message, 240, 595, 1600, "center", 0, 0.5)
	end
end

function Map:draw_actions()
	if not self.actions[Constants.EnumPhase.MOVEMENT] then
		View.setColor(1,1,1,0.3)	
	end
	
	View.circle("fill", 85, 500, 40)
	View.printf({{0,0,0,1}, "Move"}, 45,500,400,"center", 0, 0.25)
	
	View.setColor(1,1,1)
	if not self.actions[Constants.EnumPhase.ACTION] then
		View.setColor(1,1,1,0.3)
	end
	
	View.circle("fill", 195, 500, 40)
	View.printf({{0,0,0,1}, "Attack"}, 155,500,400,"center", 0, 0.25)
	
	View.setColor(1,1,1)
	
	View.circle("fill", 305, 500, 40)
	View.printf({{0,0,0,1}, "Pass"}, 265,500,400,"center", 0, 0.25)
end

function Map:lifebar(character, x,y,w,h)
	View.setColor(0.2,0.2,0.2)
	View.rectangle("fill", x, y, w, h)
	View.setColor(0,1,0.2)
	View.rectangle("fill", x, y, math.max(0,w*character.curr_hp/character.stats.hp), h)
	View.setColor(1,1,1)
end