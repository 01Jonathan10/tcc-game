Player = Character:new()
Player.__index = Player

function Player:new(obj)
	local new = Character.new(Player, obj)
	
	new.level = obj.level or 1
	new.class = obj.class or Constants.EnumClass.MAGE
	new.gender = obj.gender or Constants.EnumGender.F
	
	new.energy = obj.energy
	new.xp = obj.xp
	new.gold = obj.gold
	new.diamonds = obj.diamonds
	
	new.traits = obj.traits or {
		[Constants.EnumTrait.SKIN] = 1,
		[Constants.EnumTrait.EYES] = 1,
		[Constants.EnumTrait.HAIR] = 2,
	}
	
	new.trait_colors = obj.trait_colors or {
		[Constants.EnumTrait.SKIN] = {1, 0.9, 0.6, 1},
		[Constants.EnumTrait.EYES] = {0, 0.35, 1, 1},
		[Constants.EnumTrait.HAIR] = {0.2, 0.2, 0.2, 1},
	}
	
	new.equipment = obj.equipment or {}
	new.cosmetics = obj.cosmetics or {}
	new.skills = obj.skills or {}
	
	new.id = obj.id
	
	return new
end

function Player:xp_to_next()
	return 500*self.level*self.level*self.level/4
end

function Player:unload_model()
	self.model_data = nil
end

function Player:get_cosmetic(cat)
	return self.cosmetics[cat] or self.equipment[cat]
end

function Player:load_model()
	if self.model_data then return end
		
	self.model_data = {
		anim_data = love.filesystem.load('assets/character/anim_data_'..self:get_cosmetic(Constants.ItemCategory.WEAPON).wpn_type..'.lua')(),
		shader = Constants.char_shader,
		hair = {
			img = love.graphics.newImage('assets/character/Heads.png'),
			quads = {},
			f_quads = {},
		},
		body = {
			img = love.graphics.newImage(string.format('assets/character/Body_Parts_%s.png', self.gender)),
			quads = {},
		},
		eyes = {
			img = love.graphics.newImage('assets/character/Eyes.png'),
			quads = {},
			b_quads = {},
		},
		helm = {quads = {}},
		armor = {
			img = love.graphics.newImage(string.format('assets/equips/%i/img.png', self:get_cosmetic(Constants.ItemCategory.ARMOR).kind)),
			quads = {},
			data = love.filesystem.load(string.format('assets/equips/%i/data.lua', self:get_cosmetic(Constants.ItemCategory.ARMOR).kind))()
		},
		shadow = Utils.shine_img()
	}
	
	if self:get_cosmetic(Constants.ItemCategory.HEAD).kind == 0 then 
		self.model_data.helm.img=nil 
		self.model_data.helm.data = {type=Constants.EnumHatType.NONE} 
	else
		self.model_data.helm = {
			img = love.graphics.newImage(string.format('assets/equips/%i/img.png', self:get_cosmetic(Constants.ItemCategory.HEAD).kind)),
			quads = {},
			data = love.filesystem.load(string.format('assets/equips/%i/data.lua', self:get_cosmetic(Constants.ItemCategory.HEAD).kind))()
		}
	end
	
	if self:get_cosmetic(Constants.ItemCategory.WEAPON).kind == 0 then 
		self.model_data.weapon=nil 
	else
		self.model_data.weapon = love.graphics.newImage(string.format('assets/equips/%i/img.png', self:get_cosmetic(Constants.ItemCategory.WEAPON).kind))
	end
			
	for i = 0, 8 do 
		table.insert(self.model_data.body.quads, View.newQuad((i%3)*300, math.floor(i/3)*300, 300, 300, 900, 900)) 
	end
	
	table.insert(self.model_data.body.quads, View.newQuad((4%3)*300, math.floor(4/3)*300, 300, 300, 900, 900)) 
	table.insert(self.model_data.body.quads, View.newQuad((2%3)*300, math.floor(2/3)*300, 300, 300, 900, 900)) 
	
	for i =0,16 do 
		table.insert(self.model_data.hair.quads, View.newQuad(0, i*500, 500, 500, 1000, 7000))
		table.insert(self.model_data.eyes.quads, View.newQuad((i%4)*500, math.floor(i/4)*500, 500, 500, 2000, 2000))
		table.insert(self.model_data.hair.f_quads, View.newQuad(500, i*500, 500, 500, 1000, 7000))
	end
	
	table.insert(self.model_data.helm.quads, View.newQuad(0, 0, 500, 500, 1000, 500))
	table.insert(self.model_data.helm.quads, View.newQuad(500,0, 500, 500, 1000, 500)) 
	
	table.insert(self.model_data.armor.quads, View.newQuad(0, 0, 500, 500, 1500, 1100))
	table.insert(self.model_data.armor.quads, View.newQuad(500, 0, 500, 500, 1500, 1100))
	table.insert(self.model_data.armor.quads, View.newQuad(1000, 0, 500, 500, 1500, 1100))
	
	for i=0,2 do
		table.insert(self.model_data.armor.quads, View.newQuad(0, 500+300*i, 300, 300, 1500, 1100))
		table.insert(self.model_data.armor.quads, View.newQuad(300, 500+300*i, 300, 300, 1500, 1100))
		table.insert(self.model_data.armor.quads, View.newQuad(600, 500+300*i, 300, 300, 1500, 1100))
		table.insert(self.model_data.armor.quads, View.newQuad(900, 500+300*i, 300, 300, 1500, 1100))
		table.insert(self.model_data.armor.quads, View.newQuad(1200, 500+300*i, 300, 300, 1500, 1100))
	end
	
	self.model_data.shader:sendColor("hair_color", self.trait_colors.hair)
	self.model_data.shader:sendColor("eye_color", self.trait_colors.eyes)
	self.model_data.shader:sendColor("skin_color", self.trait_colors.skin)
end

function Player:update_model(setting)
	if (not setting or not self.model_data) then self:unload_model() self:load_model() end
	
	local options = {
		anim_data = function() self.model_data.anim_data = love.filesystem.load('assets/character/anim_data_'..self:get_cosmetic(Constants.ItemCategory.WEAPON).wpn_type..'.lua')() end,
		hair = function() self.model_data.hair.img = love.graphics.newImage('assets/character/Heads.png') end,
		body = function() self.model_data.body.img = love.graphics.newImage(string.format('assets/character/Body_Parts_%s.png', self.gender)) end,
		eyes = function() self.model_data.eyes.img = love.graphics.newImage('assets/character/Heads.png') end,
		
		helm = function() 
			if self:get_cosmetic(Constants.ItemCategory.HEAD).kind == 0 then self.model_data.helm.img=nil self.model_data.helm.data = {type=Constants.EnumHatType.NONE} return end
			self.model_data.helm.img = love.graphics.newImage(string.format('assets/equips/%i/img.png', self:get_cosmetic(Constants.ItemCategory.HEAD).kind)) 
			self.model_data.helm.data = love.filesystem.load(string.format('assets/equips/%i/data.lua', self:get_cosmetic(Constants.ItemCategory.HEAD).kind))()
		end,
		
		armor= function()
			self.model_data.armor.img = love.graphics.newImage(string.format('assets/equips/%i/img.png', self:get_cosmetic(Constants.ItemCategory.ARMOR).kind)) 
			self.model_data.armor.data = love.filesystem.load(string.format('assets/equips/%i/data.lua', self:get_cosmetic(Constants.ItemCategory.ARMOR).kind))()
		end,
		
		weapon= function()
			self.model_data.weapon = love.graphics.newImage(string.format('assets/equips/%i/img.png', self:get_cosmetic(Constants.ItemCategory.WEAPON).kind))
			self.model_data.anim_data = love.filesystem.load('assets/character/anim_data_'..self:get_cosmetic(Constants.ItemCategory.WEAPON).wpn_type..'.lua')()
		end
	}
	
	options[setting]()
end

function Player:draw_model(off_x,off_y, scale, frame, disable_shadow)
	if not self.model_data then self:load_model() end
	
	local anim_data = self.model_data.anim_data
	local hat_data = self.model_data.helm.data
	local armor_data = self.model_data.armor.data
	
	if frame > 60 then frame = 121-frame end
	local parts_img = self.model_data.body.img
	local parts_quads = self.model_data.body.quads
	local part, progress
	local x,y,r,sx,sy
	
	local canvas = View.newCanvas(700,800)
	local origin = View.getCanvas()
	
	progress = Utils.sig(frame/59)
	
	local head_position = {
		x=anim_data[1].x1 + progress*(anim_data[1].x2-anim_data[1].x1), 
		y=anim_data[1].y1 + progress*(anim_data[1].y2-anim_data[1].y1),
	}

	local body_position = {
		x=anim_data[anim_data.body].x1 + progress*(anim_data[anim_data.body].x2-anim_data[anim_data.body].x1), 
		y=anim_data[anim_data.body].y1 + progress*(anim_data[anim_data.body].y2-anim_data[anim_data.body].y1) + 100,
		r=(anim_data[anim_data.body].r1 or 0) + progress*((anim_data[anim_data.body].r2 or 0)-(anim_data[anim_data.body].r1 or 0)),
		sx=(anim_data[anim_data.body].sx1 or 1) + progress*((anim_data[anim_data.body].sx2 or 1)-(anim_data[anim_data.body].sx1 or 1)),
		sy=(anim_data[anim_data.body].sy1 or 1) + progress*((anim_data[anim_data.body].sy2 or 1)-(anim_data[anim_data.body].sy1 or 1)),
		ox=80,
		oy=30,
	}
		
	love.graphics.setCanvas({canvas, stencil=true})
	love.graphics.push()
	love.graphics.origin()
	
		if not disable_shadow then
			View.setColor(0,0,0,0.8)
			View.draw(self.model_data.shadow, 100,750,0,2,0.2)
			View.draw(self.model_data.shadow, 100,750,0,2,0.2)
			View.setColor(1,1,1,1)
		end
		
		if self.model_data.helm.img then View.draw(self.model_data.helm.img, self.model_data.helm.quads[2], head_position.x-90, head_position.y-100) end
		
		love.graphics.stencil(function() 
			love.graphics.polygon("fill", 
				head_position.x-60, 
				head_position.y+160,
				head_position.x+440, 
				head_position.y+200,
				head_position.x+440, 
				head_position.y+580,
				head_position.x-60, 
				head_position.y+580
		) end, "replace", 1)
		
	    if hat_data.type == Constants.EnumHatType.HAT then love.graphics.setStencilTest("greater", 0) end
		if hat_data.type ~= Constants.EnumHatType.HELM then 
			love.graphics.setShader(self.model_data.shader)
			View.draw(self.model_data.hair.img, self.model_data.hair.quads[self.traits.hair], head_position.x-60, head_position.y+80, 0, 0.8)
			love.graphics.setShader()
		end
		love.graphics.setStencilTest()
		
		View.draw(self.model_data.armor.img, self.model_data.armor.quads[2], body_position.x, body_position.y, body_position.r, body_position.sx, body_position.sy, body_position.ox, body_position.oy)
		
		local draw_behind = self.model_data.armor.data.draw_behind or {}
		local draw_over = self.model_data.armor.data.draw_over or {}
		local elbows_behind = self.model_data.armor.data.elbows_behind
		
		for i= #anim_data, 1, -1 do
			part = anim_data[i]
			
			part.r1 = part.r1 or 0
			part.r2 = part.r2 or part.r1
			part.sx1 = part.sx1 or 1
			part.sx2 = part.sx2 or part.sx1
			part.sy1 = part.sy1 or 1
			part.sy2 = part.sy2 or part.sy1
			
			x = part.x1 + progress*(part.x2-part.x1)
			y = part.y1 + progress*(part.y2-part.y1)
			r = part.r1 + progress*(part.r2-part.r1)
			sx = part.sx1 + progress*(part.sx2-part.sx1)
			sy = part.sy1 + progress*(part.sy2-part.sy1)
			
			if draw_behind[part.id] then
				View.draw(self.model_data.armor.img, self.model_data.armor.quads[draw_behind[part.id]], x, y+100, r, sx, sy, part.ox or 0, part.oy or 0)
			end
			
			if not (self.model_data.armor.data.replace_parts[part.id] or part.id <= -1) then
				love.graphics.setShader(self.model_data.shader)
				View.draw(parts_img, parts_quads[part.id], x, y+100, r, sx, sy, part.ox or 0, part.oy or 0)
				love.graphics.setShader()
			end
			
			if draw_over[part.id] then
				View.draw(self.model_data.armor.img, self.model_data.armor.quads[draw_over[part.id]], x, y+100, r, sx, sy, part.ox or 0, part.oy or 0)
			end
			
			if part.id == Constants.EnumBodyPart.BODY then
				View.draw(self.model_data.armor.img, self.model_data.armor.quads[1], body_position.x, body_position.y, body_position.r, body_position.sx, body_position.sy, body_position.ox, body_position.oy)
			end
			
			if part.id == -1 then
				View.draw(self.model_data.weapon, x, y, r, sx, sy, part.ox, part.oy)
			end
			
			if elbows_behind and part.id == Constants.EnumBodyPart.ARM_1 then
				part = anim_data[i+1]
			
				if part.id == Constants.EnumBodyPart.ARM_2_1 or part.id == Constants.EnumBodyPart.ARM_2_2 then
			
					part.r1 = part.r1 or 0
					part.r2 = part.r2 or part.r1
					part.sx1 = part.sx1 or 1
					part.sx2 = part.sx2 or part.sx1
					part.sy1 = part.sy1 or 1
					part.sy2 = part.sy2 or part.sy1
					
					x = part.x1 + progress*(part.x2-part.x1)
					y = part.y1 + progress*(part.y2-part.y1)
					r = part.r1 + progress*(part.r2-part.r1)
					sx = part.sx1 + progress*(part.sx2-part.sx1)
					sy = part.sy1 + progress*(part.sy2-part.sy1)
					
					View.draw(self.model_data.armor.img, self.model_data.armor.quads[draw_over[part.id]], x, y+100, r, sx, sy, part.ox or 0, part.oy or 0)
				end
			end	
		end
			
		View.draw(self.model_data.armor.img, self.model_data.armor.quads[3], body_position.x, body_position.y, body_position.r, body_position.sx, body_position.sy, body_position.ox, body_position.oy)
		
		love.graphics.setShader(self.model_data.shader)	
		View.draw(self.model_data.eyes.img, self.model_data.eyes.quads[self.traits.eyes], head_position.x-60, head_position.y+80, 0, 0.8)
		love.graphics.setShader()
		
		if hat_data.type ~= Constants.EnumHatType.HELM then 
			love.graphics.setShader(self.model_data.shader)	
			View.draw(self.model_data.hair.img, self.model_data.hair.f_quads[self.traits.hair], head_position.x-60, head_position.y+80, 0, 0.8)
			love.graphics.setShader()
		end
		
		if self.model_data.helm.img then View.draw(self.model_data.helm.img, self.model_data.helm.quads[1], head_position.x-90, head_position.y-100) end
	
	love.graphics.pop()	
	love.graphics.setCanvas(origin)

	View.draw(canvas, off_x,off_y, 0, scale)
end

function Player:load_mini_sprite()
	self:load_model()
	
	love.filesystem.setRequirePath( 'scripts/shaders/?.lua' )
	require("GaussianBlur")
	local shader = Constants.blur_shader
	Constants.blur_shader = nil
	
	local quads = {}
	local x,y,frame
	
	local canvas = View.newCanvas(7000,4800)
	View.setCanvas(canvas)
	love.graphics.push()
	love.graphics.origin()
	
	for frame=0,59 do
		x = 700*(frame%10)
		y = 800*(math.floor(frame/10))
		table.insert(quads, View.newQuad(x/5,y/5,140,160,1400,960))
		self:draw_model(x,y,1,frame)
	end
	
	self:unload_model()
	
	local canvas_blurred = View.newCanvas(1400,1200)
	View.setCanvas(canvas_blurred)
	View.setShader(shader)
	View.draw(canvas,0,0,0,0.2)
	View.setShader()
	View.setCanvas()

	love.graphics.pop()
	
	self.quest_sprite = {img = love.graphics.newImage(canvas_blurred:newImageData()), quads = quads, frames = #quads}
end

function Player:draw_mini(x,y,frame, scale, lock_flip)
	if frame > 60 then frame = 121-frame end
	local scale = scale or 1
	local scale_x = scale
	if (not lock_flip) and (self.facing == 1 or self.facing == 2) then scale_x = -1 end
	
	View.draw(self.quest_sprite.img, self.quest_sprite.quads[frame], x, y-150, 0, scale_x, scale, 70, 0)
end

function Player:unload_mini()
	self.quest_sprite = nil
end