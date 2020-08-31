Character = {}
Character.__index = Character

function Character:new(obj)
	local new = {}
	local obj = obj or {}
	
	new.name = obj.name or "Test_Char"
	
	new.stats = obj.stats or {
		hp 	 = 0,
		atk  = 0,
		def  = 0,
		matk = 0,
		mdef = 0,
		luck = 0,
		mov  = 0,
		speed= 0,
	}
	
	setmetatable(new, self)
	return new
end

function Character:unload_mini() 
	self.quest_sprite = nil
end

function Character:draw_mini(x,y,frame, scale, lock_flip)
	local scale = scale or 1
	local scale_x = scale
	if (not lock_flip) and (self.facing == 1 or self.facing == 2) then scale_x = -1 end
	quad = self.quest_sprite.quads[1+math.floor(frame/5)%self.quest_sprite.frames]
	
	View.draw(self.quest_sprite.img, quad, x-10, y-150, 0, scale_x, scale, 70, 0)
end

function Character:die()

end