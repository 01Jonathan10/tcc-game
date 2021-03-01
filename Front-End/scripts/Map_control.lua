Map = Map or {}
Map.__index = Map

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
	self:update_promise()
	self.loading = true
	self.request_queue = {}
end

function Map:update_promise()
	API.execute_quest_actions(self.request_queue):success(function(response_data)
		local new_action
		self.action_queue = self.action_queue or {}

		for idx = self.action_count+1,#response_data.actions do
			new_action = response_data.actions[idx]
			table.insert(self.action_queue, new_action)
		end

		if not self.curr_action.type then self:resolve() end
	end):after(function()
		self.loading = nil
	end)
end

function Map:resolve()
	local action = self.action_queue[1]
	if not action then return end
	table.remove(self.action_queue, 1)

	self.action_count = self.action_count + 1

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

		self.curr_action = {type="end"}

		Alert:new(message, AlertTypes.notification, function()
			MyLib.FadeToColor(0.25, {function()
				GameController.go_to_menu():after(function()
					GameController.unload_map()
				end)
			end})
		end)
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
