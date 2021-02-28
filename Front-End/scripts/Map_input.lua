Map = Map or {}
Map.__index = Map

-- INPUT

function Map:click(x, y, k)
	local cell

	if self.loading then return end

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