Map = Map or {}
Map.__index = Map

-- INICIALIZACAO

function Map:new(quest)
	local map = Map.load_map(quest)

	map.mouse_over = nil
	map.timer = 0
	map.poll_timer = 0
	map.frame = 1

	map.request_queue = {}
	map.curr_action = {}

	QuestController.map = map

	map:set_camera_player()

	self.loading = true
	API.get_skills(quest.id):success(function(response_data)
		Skill.loaded_skills = Skill:translate_response(response_data)
		local idx, id
		for idx, skill in ipairs(GameController.player.skills) do
			GameController.player.skills[idx] = Skill:get(skill.id)
		end
	end):after(function()
		self.loading = nil
	end)

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
	map.action_count = quest.map_data.curr_action

	return map
end

-- UPDATE

function Map:update(dt)
	self.timer = (self.timer + 40*dt)%120
	self.frame = math.floor(self.timer) + 1

	self.poll_timer = self.poll_timer + dt
	if self.poll_timer >= 5 and (not self.updating_actions) and (not self.action_queue) then
        self.updating_actions = true
		API.update_map_actions():success(function(response_data)
            local new_action
            self.action_queue = {}

            for idx = self.action_count+1,#response_data.actions do
                new_action = response_data.actions[idx]
                table.insert(self.action_queue, new_action)
            end
            if not self.curr_action.type then self:resolve() end
        end):after(function()
            self.loading = nil
            self.updating_actions = nil
        end)
        self.poll_timer = 0
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
