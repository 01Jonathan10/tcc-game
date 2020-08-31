Map = {}
Map.__index = Map

-- INICIALIZACAO

function Map:new(quest)
	local map = Map.load_map(quest)
	
	map.mouse_over = nil
	map.timer = 0
	map.frame = 1
	
	map.request_queue = {}
	map.curr_action = {}
	
	QuestController.map = map
	
	map:set_camera_player()
	
	API.get_skills(quest.id)
	map.calling_api = true
	map.waiting_skills = true
	
	return map
end

function Map.load_map(quest)
	local map = {dim = quest.map_data.dim, camera={x=0,y=0}, sx = 60, sy = 25}
	setmetatable(map, Map)
	QuestController.map = map
	
	map.player_team = {}
	map.enem_team = {}
	map.turn_order = {}
	
	local i,j,z, cells, cell, enemy
	
	for i=1,map.dim.x do
		map[i] = {}
		for j=1,map.dim.y do
			map[i][j] = {x=i,y=j,z=0}
		end
	end
	
	for z, cells in ipairs(quest.map_data.z_map) do
		for _, cell in ipairs(cells) do
			map[cell[1]][cell[2]].z = z
		end
	end
	
	for _, cell in ipairs(quest.map_data.block_map) do
		map[cell[1]][cell[2]].block = true
	end
	
	local characters = {}
	local obj
	
	for _, object in ipairs(quest.map_data.objects) do
		
		if object.dead then
			obj = object
		elseif object.type == Constants.EnumObjType.PLAYER then
			obj = GameController.player
		elseif object.type == Constants.EnumObjType.ENEMY then
			obj = Enemy:new({name = object.name, stats=object.stats, id=object.id})
		end
		
		table.insert(characters, obj)
		
		if not object.dead then 
			QuestController.add_obj(obj, object.position.x, object.position.y, object.type == Constants.EnumObjType.ENEMY)
		end
		
		obj.curr_hp = object.hp
	end
	
	for _, id in ipairs(quest.map_data.turn_order) do
		table.insert(map.turn_order, characters[id+1])
	end
	
	map.turn = quest.map_data.turn
	map.phase = Constants.EnumPhase.IDLE
	
	local turn_owner = map.turn_order[map.turn]
	
	map:set_camera_focus_to_char(turn_owner)
	
	map.actions = quest.map_data.available_actions
		
	return map
end

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
	
	if self.calling_api then
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

-- UPDATE

function Map:update(dt)
	self.timer = (self.timer + 40*dt)%120
	self.frame = math.floor(self.timer) + 1
		
	if self.calling_api then
		local response = API.r_channel:pop()
		
		if response then
			if response.status == Constants.STATUS_OK then
				local response_data = (Json.decode(response[1]))
				if self.waiting_skills then
					Skill.loaded_skills = Skill:translate_response(response_data)
										
					local idx, id
					for idx, skill in ipairs(GameController.player.skills) do
						GameController.player.skills[idx] = Skill:get(skill.id)
					end				
				else
					local new_action
					self.action_queue = self.action_queue or {}
									
					for _, new_action in ipairs(response_data.actions) do
						table.insert(self.action_queue, new_action)
					end
					
					if not self.curr_action.type then self:resolve() end
				end
			end
			self.waiting_skills = nil
			self.calling_api = nil
		end
		
		return
	end
	
	if self.curr_action.type == "animation" then
		self.curr_action.anim_timer = self.curr_action.anim_timer + 60*dt
		if self.curr_action.anim_timer > self.curr_action.duration then
			self.curr_action.after()
		end
	end
	
	if self.curr_action.type == "move" then
		self.curr_action.progress = self.curr_action.progress + 400*dt
		if self.curr_action.progress >= 100 then
			self.curr_action.progress = self.curr_action.progress - 100
			table.remove(self.curr_action.path, 1)
			self.curr_action.position = self.curr_action.path[1]
		end
		
		if #self.curr_action.path <= 1 then
			self.curr_action.after()
		end
	end
	
	local mx, my = Utils.convert_coords(love.mouse.getPosition())
	local col, lin
	local sx, sy = self.sx, self.sy
	
	self:update_camera(dt,mx,my)
	
	mx = mx - self.camera.x
	my = my - self.camera.y
		
	col = math.floor(mx/(2*sx) - my/(2*sy))
	lin = math.floor(mx/(2*sx) + my/(2*sy))
	
	self.mouse_over = nil
	
	if col>=1 and col<=self.dim.x and lin>=1 and lin<=self.dim.y then
		self.mouse_over = self[col][lin]
	end
	
	if self.mouse_over and self.phase == Constants.EnumPhase.ACTION then
		local dx = self.mouse_over.x - GameController.player.position.x
		local dy = self.mouse_over.y - GameController.player.position.y
		
		local prev = GameController.player.facing
		
		if math.abs(dx)>math.abs(dy) then
			if dx > 0 then GameController.player.facing = 1 else GameController.player.facing = 3 end
		elseif math.abs(dy)>math.abs(dx) then
			if dy > 0 then GameController.player.facing = 2 else GameController.player.facing = 0 end
		end
		
		local skill_id = GameController.player.skills[self.selected_skill].id
		if prev ~= GameController.player.facing then self:get_skill_range(Skill:get(skill_id), GameController.player.facing) end
	end
end

function Map:update_camera(dt,mx,my)
	if self.camera.focus then
		local dx, dy
		dx = self.camera.focus.x - self.camera.x
		dy = self.camera.focus.y - self.camera.y
		
		self.camera.x = self.camera.x + dx*Constants.CAMERA_SPEED*dt/50
		self.camera.y = self.camera.y + dy*Constants.CAMERA_SPEED*dt/50
		
		if math.abs(dx) < 1 then self.camera.x = self.camera.focus.x end
		if math.abs(dy) < 1 then self.camera.y = self.camera.focus.y end
		
		if dx == 0 and dy == 0 then
			self.camera.focus = nil
		end
	else
		if mx <= 1 then self.camera.x = self.camera.x + Constants.CAMERA_SPEED*dt end
		if mx >= 1279 then self.camera.x = self.camera.x - Constants.CAMERA_SPEED*dt end
		
		if my <= 1 then self.camera.y = self.camera.y + Constants.CAMERA_SPEED*dt end
		if my >= 719 then self.camera.y = self.camera.y - Constants.CAMERA_SPEED*dt end
	end
	
	self.camera.x = math.min(math.max(self.camera.x, -(self.dim.x+self.dim.y)*self.sx+1080), self.sx)
	self.camera.y = math.min(math.max(self.camera.y, -(self.dim.y*self.sy)+620), self.dim.x*self.sy+200)	
end

-- INPUT

function Map:click(x, y, k)
	local cell = nil
	
	if self.calling_api then return end
	if self.curr_action.type then 
		if self.curr_action.type == "message" then
			if self.curr_action.after then
				self.curr_action.after()
			else
				self.curr_action = {}
				self:resolve()
			end
		end
		return
	end
	
	local mx = x - self.camera.x
	local my = y - self.camera.y
	local col = math.floor(mx/(2*self.sx) - my/(2*self.sy))
	local lin = math.floor(mx/(2*self.sx) + my/(2*self.sy))
	if col>=1 and col<=self.dim.x and lin>=1 and lin<=self.dim.y then
		cell = self[col][lin]
	end
	
	local d_sq = (x-85)*(x-85) + (y-500)*(y-500)
	if d_sq < 1600 and self.actions[Constants.EnumPhase.MOVEMENT] and self.phase ~= Constants.EnumPhase.MOVEMENT then 
		self.phase = Constants.EnumPhase.MOVEMENT 
		self:reset_highlights()
		self:get_movement_options(GameController.player.stats.mov) return
	end
	
	d_sq = (x-195)*(x-195) + (y-500)*(y-500)
	if d_sq < 1600 and self.actions[Constants.EnumPhase.ACTION] and self.phase ~= Constants.EnumPhase.ACTION then 
		self:reset_highlights()
		self.phase = Constants.EnumPhase.ACTION 
		self.selected_skill = 1 
		self:get_skill_range(GameController.player.skills[1],GameController.player.facing)
		return
	end
	
	d_sq = (x-305)*(x-305) + (y-500)*(y-500)
	if d_sq < 1600 then self:pass_turn() return end
	
	if self.phase == Constants.EnumPhase.ACTION then
		if x > 20 and x < 350 and y < 440 and y > 440-(40*#GameController.player.skills) then
			self.selected_skill = math.ceil((y-440+(40*#GameController.player.skills))/40)
			return
		end
	end

	if cell then
		if self.phase == Constants.EnumPhase.MOVEMENT then
			if cell.highlight then
				self:move_char(self.turn_order[self.turn], cell)
			else
				self.phase = Constants.EnumPhase.IDLE
			end
		elseif self.phase == Constants.EnumPhase.ACTION then
			if #self.skill_range>0 then
				self:attack(GameController.player.skills[self.selected_skill].id, self.turn_order[self.turn], GameController.player.facing)
			end
		end
	end
	
	self:reset_highlights()
end

-- CALCULATIONS

function Map:reset_highlights()
	for _, row in ipairs(self) do
		for _, cell in ipairs(row) do
			cell.highlight = nil
		end
	end
end

function Map:get_skill_range(skill, direction)
	self:reset_highlights()
	local character = self.turn_order[self.turn]
	local origin = {x=character.position.x, y=character.position.y}
	local pos
	local delta, letter
	local elem, i
	local rot, angle
	local instr = {F=0,R=1,B=2,L=3}
	local dx, dy
	local cell, col
	
	self.skill_range = {}
	
	for _, elem in ipairs(skill.range) do
		pos = {x=origin.x, y=origin.y}
		for i = 1,string.len(elem)/2 do
			delta = tonumber(elem:sub(2*(i-1)+2,2*(i-1)+2))
			letter = elem:sub(2*(i-1)+1,2*(i-1)+1)
			
			rot = (instr[letter] + direction)%4
			angle = (rot/2)*math.pi
			pos.x = pos.x + math.floor(math.sin(angle)*delta +0.5)
			pos.y = pos.y - math.floor(math.cos(angle)*delta +0.5)
		end
		
		col = self[pos.x]
		if col then cell = col[pos.y] end
		if cell then
			cell.highlight = true
			table.insert(self.skill_range, cell)
		end
	end
end

function Map:move_char(character, new_cell)
	local orig_cell = character.position.cell
	
	table.insert(self.request_queue, {
		action = "move",
		position = {x=orig_cell.x, y=orig_cell.y},
		new_position = {x=new_cell.x, y=new_cell.y},
		player_id = character.id,
	})
	
	self:make_request()
	
end

function Map:attack(skill_id, att_char, direction)

	table.insert(self.request_queue, {
		action = "attack", 
		position = {x=att_char.position.x, y=att_char.position.y},
		direction = direction,
		player_id = att_char.id,
		skill = skill_id,
	})
	
	self:make_request()

end

function Map:pass_turn()

	table.insert(self.request_queue, {
		action = "pass",
		player_id = self.turn_order[self.turn].id,
	})
		
	self:make_request()

end

function Map:make_request()
	API.execute_quest_actions(self.request_queue)
	self.request_queue = {}
	self.calling_api = true
end

function Map:resolve()
	local action = self.action_queue[1]	
	if not action then return end
	table.remove(self.action_queue, 1)
		
	if action.action == "pass" then
		self.phase = Constants.EnumPhase.IDLE
		self.turn = (self.turn%table.getn(self.turn_order)) + 1
		local turn_owner = self.turn_order[self.turn]
		
		while turn_owner.dead do
			self.turn = (self.turn%table.getn(self.turn_order)) + 1
			turn_owner = self.turn_order[self.turn]
		end
		
		self:set_camera_focus_to_char(turn_owner)
		
		self.actions = {true, true}
		
		self:reset_highlights()
		self:resolve()
	
	elseif action.action == "move" then
		local orig_cell = self[action.position.x][action.position.y]
		local new_cell = self[action.new_position.x][action.new_position.y]
		local character = self.turn_order[self.turn]
		
		self:set_camera_focus_to_char(character)
		
		self.actions[Constants.EnumPhase.MOVEMENT] = nil
		self.phase = Constants.EnumPhase.IDLE
		
		local tmp_action = {
			type = "move",
			progress = 0,
			path = self:a_star(action.position.x, action.position.y, action.new_position.x, action.new_position.y),
			position = orig_cell,
			after = function()
				self.curr_action = {}
				orig_cell.object = nil
				orig_cell.block = nil
				new_cell.object = character
				new_cell.block = true
				character.position = {x = new_cell.x, y = new_cell.y, cell = new_cell}
				character.moving = nil
				self:resolve()
			end
		}
		
		if character ~= GameController.player then
			self.curr_action = {
				type = "message", message=character.name.." Moves!", after=function() character.moving = true self.curr_action = tmp_action end
			}
		else
			character.moving = true
			self.curr_action = tmp_action
		end
	
	elseif action.action == "attack" then		
		local skill = Skill:get(action.skill)
		local att_char = self.turn_order[self.turn]
		
		att_char.facing = action.direction
		
		self.actions[Constants.EnumPhase.ACTION] = nil
		self.phase = Constants.EnumPhase.IDLE
		
		self:set_camera_focus_to_char(att_char)
		self:reset_highlights()
		
		self.curr_action = {type = "message", message=att_char.name.." uses "..skill.name.."!"}
	
	elseif action.action == "take_dmg" then		
		local character = self.turn_order[action.char_id+1]
		
		character.curr_hp = math.max(0, character.curr_hp - action.damage)
		
		self.curr_action = {type = "message", message=character.name.." took "..action.damage.." damage!"}
	
	elseif action.action == "death" then		
		local character = self.turn_order[action.char_id+1]
		local cell = self[character.position.x][character.position.y]
		
		character.dead = true
		
		cell.block = nil
		cell.object = nil
		
		self.curr_action = {type = "message", message=character.name.." fell in battle!"}
		
	elseif action.action == "finish" then
		local message = "You won the battle! Congratulations!"
		if not action.victory then message = "You lost the battle..." end
		
		self.curr_action = {type = "message", message=message, after = function()
			self.curr_action = {type="end"}
			MyLib.FadeToColor(0.25, {function()
				GameController.unload_map()
				GameController.go_to_menu()
			end})
		end}
	end
end

function Map:set_camera_focus_to_char(character)
	local x, y
	x, y = (character.position.x+character.position.y)*self.sx, (character.position.y-character.position.x)*self.sy - character.position.cell.z*20
	self:set_camera_focus(-(x+self.sx-640), -(y-360))
end

function Map:set_camera_focus(x, y)
	x = math.min(math.max(x, -(self.dim.x+self.dim.y)*self.sx+1080), self.sx)
	y = math.min(math.max(y, -(self.dim.y*self.sy)+620), self.dim.x*self.sy+200)	
	self.camera.focus = {x=x, y=y}
end

function Map:set_camera_player()
	local player = GameController.player
	local x, y
	x, y = (player.position.x+player.position.y)*self.sx, (player.position.y-player.position.x)*self.sy - player.position.cell.z*20
	self.camera.x=-(x+self.sx-640) 
	self.camera.y=-(y-360)
end

function Map:get_movement_options(mov)
	local max_height = 1
	self:tree_search(self.turn_order[self.turn].position.cell,mov, true, max_height)
	self.turn_order[self.turn].position.cell.highlight = nil
end

function Map:tree_search(cell, mov, ignore_blocked, max_height)
	if mov == 0 then return end
	
	for _, neighbor in ipairs(self:neighbor_cells(cell, ignore_blocked, max_height)) do
		neighbor.highlight = true
		self:tree_search(neighbor, mov-1, ignore_blocked, max_height)
	end
end

function Map:neighbor_cells(cell, ignore_blocked, max_height)
	local max_height = max_height or 999
	local list = {}
	local new_cell = {}
	
	if cell.x > 1 then
		new_cell = self[cell.x-1][cell.y]
		if (not ignore_blocked) or (math.abs(new_cell.z - cell.z) <= max_height and (not new_cell.block)) then
			table.insert(list, new_cell)
		end
	end
	
	if cell.x < self.dim.x then
		new_cell = self[cell.x+1][cell.y]
		if (not ignore_blocked) or (math.abs(new_cell.z - cell.z) <= max_height and (not new_cell.block)) then
			table.insert(list, new_cell)
		end
	end
	
	if cell.y > 1 then
		new_cell = self[cell.x][cell.y-1]
		if (not ignore_blocked) or (math.abs(new_cell.z - cell.z) <= max_height and (not new_cell.block)) then
			table.insert(list, new_cell)
		end
	end
	
	if cell.y < self.dim.y then
		new_cell = self[cell.x][cell.y+1]
		if (not ignore_blocked) or (math.abs(new_cell.z - cell.z) <= max_height and (not new_cell.block)) then
			table.insert(list, new_cell)
		end
	end
	
	return list
end
