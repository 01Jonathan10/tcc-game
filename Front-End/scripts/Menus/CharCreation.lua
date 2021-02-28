CharCreation = {}
CharCreation.__index = CharCreation

function CharCreation:new(obj)
	View.setLineWidth(3)
	local obj = obj or {}
	local i
	
	setmetatable(obj, self)
	
	Textbox:init()
	obj.name_box = Textbox:new("name",930,550,320,50, {1,0.5,0.5})
	
	obj.bg_img = love.graphics.newImage("assets/menus/CharCreation.png")
	
	obj.class_options = Class:get_starter_classes()
	obj.selected_class = obj.class_options[math.random(1,#obj.class_options)]
	
	obj.new_char = {
		name = "",
		gender = Constants.EnumGender.F,
		traits = {
			[Constants.EnumTrait.SKIN] = 1,
			[Constants.EnumTrait.EYES] = 2,
			[Constants.EnumTrait.HAIR] = 2,
		},
		trait_colors = {
			[Constants.EnumTrait.SKIN] = {1, 0.9, 0.6, 1},
			[Constants.EnumTrait.EYES] = {0, 0.35, 1, 1},
			[Constants.EnumTrait.HAIR] = {0.2, 0.2, 0.2, 1},
		},
		equipment = {
			[Constants.ItemCategory.HEAD]  = Item:new({id=0, kind=obj.selected_class.id}),
			[Constants.ItemCategory.ARMOR] = Item:new({id=0, kind=obj.selected_class.id+3}),
		},
		cosmetics = {},
	}
	
	setmetatable(obj.new_char, Player)
	
	obj.class_icons = love.graphics.newImage('assets/icons/Class_Icons.png')
	obj.gender_icons = love.graphics.newImage('assets/icons/GenderIcons.png')
	obj.class_quads = {}
	obj.gender_quads = {}

	for i=0,2 do obj.class_quads[i+1] = View.newQuad(i*100, 0, 100, 100, 300, 100) end
	for i=0,1 do obj.gender_quads[i+1] = View.newQuad(i*100, 0, 100, 100, 200, 100) end

	obj.shader = Constants.char_shader
		
	obj.sprites = {
		hair = {
			img = love.graphics.newImage('assets/character/Heads.png'),
			quads = {},
			f_quads = {},
		},
		eyes = {
			img = love.graphics.newImage('assets/character/Eyes.png'),
			quads = {},
		}
	}
	
	for i =0,8 do
		table.insert(obj.sprites.hair.quads, View.newQuad(0, i*500, 500, 500, 1000, 4500))
		table.insert(obj.sprites.hair.f_quads, View.newQuad(500, i*500, 500, 500, 1000, 4500))
	end
	
	for i=0,8 do
		table.insert(obj.sprites.eyes.quads, View.newQuad((i%4)*500, math.floor(i/4)*500, 500, 500, 2000, 1500))
	end
	
	obj.picker_imgs = {
		skinpick = love.graphics.newImage('assets/menus/SkinColorPicker.png'),
		colorpick = love.graphics.newImage('assets/menus/ColorPicker.png'),
	}
	
	obj.pickers = {
		{x=220, y=200, trait=Constants.EnumTrait.HAIR, image = obj.picker_imgs.colorpick},
		{x=220, y=350, trait=Constants.EnumTrait.EYES, image = obj.picker_imgs.colorpick},
		{x=120, y=590, trait=Constants.EnumTrait.SKIN, image = obj.picker_imgs.skinpick},
	}

	obj.shader:sendColor("hair_color", obj.new_char.trait_colors.hair)
	obj.shader:sendColor("eye_color", obj.new_char.trait_colors.eyes)
	obj.shader:sendColor("skin_color", obj.new_char.trait_colors.skin)
	
	obj.frame = 1
	obj.timer = 0
	
	obj.shine_img = Utils.shine_img()
	
	obj.anim_data = love.filesystem.load('assets/character/anim_data_0.lua')()
	obj:set_class()
	
	return obj
end

function CharCreation:set_class()
	local class_offset = (self.selected_class.id-1)*2
	if self.new_char.gender == Constants.EnumGender.M then
		class_offset = class_offset + 9
	end
	self.new_char.equipment = {
		[Constants.ItemCategory.HEAD]  = Item:new({id=0, kind=class_offset+1}),
		[Constants.ItemCategory.ARMOR] = Item:new({id=0, kind=class_offset+2}),
		[Constants.ItemCategory.WEAPON] = Item:new({id=0, kind=0, wpn_type = Constants.WpnCategory.NONE}),
	}
	self.new_char:update_model("helm")
	self.new_char:update_model("armor")
	self.new_char.class = self.selected_class.id
end

function CharCreation:draw()
	local character = self.new_char
	
	View.draw(self.bg_img, 0, 0)
	
	character:draw_model(420,180,0.6,self.frame)
	
	View.printf(("Name"):translate(), 990, 510, 400, "center", 0, 1/2)
	
	View.print(("Hair"):translate(),310,180, 0, 1/2)
	View.setColor(0.5,0.5,0.5)
	View.rectangle("fill", 60, 150, 100,100)
	View.setColor(1,1,1)
	View.rectangle("line", 60, 150, 100,100)

	View.print(("Face"):translate(),310,330, 0, 1/2)
	View.setColor(0.5,0.5,0.5)
	View.rectangle("fill", 60, 300, 100,100)
	View.setColor(1,1,1)
	View.rectangle("line", 60, 300, 100, 100)

	View.print(("Skin tone"):translate(),180,575, 0, 1/2)

	love.graphics.setShader(self.shader)

	View.draw(self.sprites.hair.img, self.sprites.hair.quads[character.traits.hair], 60, 150, 0, 0.2)
	View.draw(self.new_char.model_data.body.img, self.new_char.model_data.body.quads[1], 113, 156, 0, 1/4, 1/4, 150)
	View.draw(self.sprites.hair.img, self.sprites.hair.f_quads[character.traits.hair], 60, 150, 0, 0.2)

	View.draw(self.new_char.model_data.body.img, self.new_char.model_data.body.quads[1], 115, 280, 0, 1/2, 1/2, 150)
	View.draw(self.sprites.eyes.img, self.sprites.eyes.quads[character.traits.eyes], 110, 270, 0, 0.4, 0.4, 250)

	love.graphics.setShader()

	if self.new_char.gender == Constants.EnumGender.F then
		View.draw(self.shine_img, 40, 400, 0, 0.7)
	else
		View.draw(self.shine_img, 150, 400, 0, 0.7)
	end

	View.setColor(0,0,0,0.5)
	View.circle("fill", 223, 203, Constants.PICKER_RADIUS)
	love.graphics.setColor(character.trait_colors.hair)
	View.circle("fill", 220, 200, Constants.PICKER_RADIUS)

	View.setColor(0,0,0,0.5)
	View.circle("fill", 223, 353, Constants.PICKER_RADIUS)
	love.graphics.setColor(character.trait_colors.eyes)
	View.circle("fill", 220, 350, Constants.PICKER_RADIUS)

	View.setColor(0,0,0,0.5)
	View.circle("fill", 123, 593, Constants.PICKER_RADIUS)
	love.graphics.setColor(character.trait_colors.skin)
	View.circle("fill", 120, 590, Constants.PICKER_RADIUS)
	
	love.graphics.setColor(1,1,1)

	View.draw(self.gender_icons, self.gender_quads[1], 90, 450, 0, 0.7)
	View.draw(self.gender_icons, self.gender_quads[2], 200, 450, 0, 0.7)

	if self.picker then
		local picker = self.picker
		View.draw(picker.image,picker.x-100,picker.y-100)
	end
	
	if self.picking_trait then
		self:draw_trait_picker()
	else
		self:draw_class_picker()
	end
	
	View.setColor(0.3,0.3,0.3)
	View.rectangle("fill", 970, 630, 240, 60)
	View.setColor(1,1,1)
	View.printf("Ready", 990, 640, 250, "center", 0, 4/5)
	
	if self.loading then
		Utils.draw_loading(self.timer/15)
	end
end

function CharCreation:draw_trait_picker()
	View.printf(("Appearance"):translate(), 970, 70, 400,"center", 0, 3/5)
	
	local i, option
	local x, y
	
	for i, option in ipairs(self.sprites[self.picking_trait].quads) do
		x, y = 940 + 100*((i-1)%3), 120 + 100*math.floor((i-1)/3)
		View.setColor(0.5,0.5,0.5)
		View.rectangle("fill", x, y, 100, 100)
		View.setColor(1,1,1)
		View.rectangle("line", x, y, 100, 100)
	end
	
	love.graphics.setShader(self.shader)	
	
	for i, option in ipairs(self.sprites[self.picking_trait].quads) do
		x, y = 940 + 100*((i-1)%3), 120 + 100*math.floor((i-1)/3)
		if self.picking_trait == "eyes" then
			View.draw(self.new_char.model_data.body.img, self.new_char.model_data.body.quads[1], x+55, y-20, 0, 1/2, 1/2, 150)
			View.draw(self.sprites[self.picking_trait].img, self.sprites[self.picking_trait].quads[i], x+50, y-30, 0, 0.4, 0.4, 250)
		else
			View.draw(self.sprites[self.picking_trait].img, self.sprites[self.picking_trait].quads[i], x, y, 0, 0.2)
			View.draw(self.new_char.model_data.body.img, self.new_char.model_data.body.quads[1], x+53, y+6, 0, 1/4, 1/4, 150)
		end
	end
	
	if self.picking_trait == Constants.EnumTrait.HAIR then
		for i, option in ipairs(self.sprites[self.picking_trait].quads) do
			x, y = 940 + 100*((i-1)%3), 120 + 100*math.floor((i-1)/3)
			View.draw(self.sprites[self.picking_trait].img, self.sprites[self.picking_trait].f_quads[i], x, y, 0, 0.2)
		end
	end
	
	love.graphics.setShader()
end

function CharCreation:draw_class_picker()
	View.printf(("Class"):translate(), 980, 100, 300,"center", 0, 3/5)
	local i, class
	
	class = self.class_highlight or self.selected_class
	View.draw(self.shine_img, 820 + 100*class.id, 125, 0, 2/5)
	
	View.printf(class.name:translate(), 950, 220, 500, "left", 0, 1/2)
	View.printf(class.description:translate(), 950, 260, 250*50/15, "left", 0, 15/50)
	
	for i, class in ipairs(self.class_options) do
		View.draw(self.class_icons,self.class_quads[class.id], 845 + 100*i, 150, 0, 1/2)
	end
end

function CharCreation:update(dt)
	self.new_char.name = self.name_box.text
	self.timer = (self.timer + 60*dt)%360
	self.frame = math.floor(self.timer/3)%120 + 1
	
	local i, class
	local mx, my = Utils.convert_coords(love.mouse.getPosition())
	
	self.class_highlight = nil
	
	if not self.picking_trait then
		local x, y
		for i, class in ipairs(self.class_options) do
			x, y = 870 + 100*i, 175
			if (mx-x)*(mx-x) + (my-y)*(my-y) <= 625 then
				self.class_highlight = class
			end
		end
	end
end

function CharCreation:mousepressed(x,y,k)
	if k ~= 1 or self.disabled then return end
	local picker

	if self.picker and x > self.picker.x-100 and x < (self.picker.x + 100) and y > self.picker.y-100 and y < (self.picker.y + 100) then
		local picker_file = 'assets/menus/ColorPicker.png'
		if self.picker.trait == Constants.EnumTrait.SKIN then picker_file = 'assets/menus/SkinColorPicker.png' end
		
		local color = {love.image.newImageData(picker_file):getPixel(x - self.picker.x + 100, y - self.picker.y + 100)}
		self.new_char.trait_colors[self.picker.trait] = color
		
		self.shader:sendColor("hair_color", self.new_char.trait_colors.hair)
		self.shader:sendColor("eye_color", self.new_char.trait_colors.eyes)
		self.shader:sendColor("skin_color", self.new_char.trait_colors.skin)
		
		self.picker = nil
		return
	end
	
	for _,picker in ipairs(self.pickers) do
		if ((x-picker.x)*(x-picker.x) + (y-picker.y)*(y-picker.y)<Constants.PICKER_RADIUS*Constants.PICKER_RADIUS) then
			self.picker = picker
			self.picking_trait = nil
			return
		end
	end
	
	self.picker = nil
	
	if x >= 60 and x <= 160 and y >= 150 and y <= 250 then
		self.picking_trait = Constants.EnumTrait.HAIR
		return
	end
	
	if x >= 60 and x <= 160 and y >= 300 and y <= 400 then
		self.picking_trait = Constants.EnumTrait.EYES
		return
	end

	View.draw(self.gender_icons, self.gender_quads[1], 90, 450, 0, 0.7)
	View.draw(self.gender_icons, self.gender_quads[2], 200, 450, 0, 0.7)

	if ((x-125)*(x-125) + (y-485)*(y-485)<(35*35)) then
		self.new_char.gender = Constants.EnumGender.F
		self.new_char:update_model("body")
		self:set_class()
	end

	if ((x-235)*(x-235) + (y-485)*(y-485)<(35*35)) then
		self.new_char.gender = Constants.EnumGender.M
		self.new_char:update_model("body")
		self:set_class()
	end
	
	if self.picking_trait then
		local max_op = table.getn(self.sprites[self.picking_trait].quads)
		local curr_op = nil
		
		if x > 940 and x < 1240 and y > 120 and y < 620 then
			curr_op = math.ceil((x-940)/100) + 3*math.floor((y-120)/100)
			if curr_op <= max_op then
				self.new_char.traits[self.picking_trait] = curr_op
			end
			self.picking_trait = nil
		end
	else
		local cx, cy
		for i, class in ipairs(self.class_options) do
			cx, cy = 870 + 100*i, 175
			if (x-cx)*(x-cx) + (cy-y)*(cy-y) <= 625 then
				self.selected_class = class
				self:set_class()
				return
			end
		end
	end
	
	if x >= 970 and x <= 1210 and y >= 630 and y <= 690 then

		self.sprites.hair.img = love.graphics.newImage('assets/character/Heads.png')
		self.sprites.eyes.img = love.graphics.newImage('assets/character/Eyes.png')
		self.new_char.model_data = nil

		--self.disabled = true
		--self.loading = true
		--local new_char = self.new_char
		--API.create_player(new_char):success(function(response)
		--	GameController.go_to_menu()
		--end):fail(function(data)
		--	Alert:new("Name must be filled", AlertTypes.error)
		--	self.disabled = false
		--end):after(function()
		--	self.loading = false
		--end)
	end	
end
