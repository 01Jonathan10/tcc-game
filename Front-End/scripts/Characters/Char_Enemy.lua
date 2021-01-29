Enemy = Character:new()
Enemy.__index = Enemy

Enemy.imgs = {}

function Enemy:new(obj)
	new = Character.new(Enemy, obj)
	
	new.id = obj.id
	
	return new
end

function Enemy:load_mini_sprite()
	if self.quest_sprite then return end
	if Enemy.imgs[self.id] then self.quest_sprite = Enemy.imgs[self.id] return end
	
	local quads = {}
	local img = love.graphics.newImage(string.format("assets/enemies/%i/img.png", self.id))
	
	
	for i=0,2 do
		table.insert(quads, View.newQuad(i*160,0,160,200,480,200))
	end
	
	Enemy.imgs[self.id] = {quads = quads, img = img, frames = #quads}
	self.quest_sprite = Enemy.imgs[self.id]
end

function Enemy:unload_all_mini()
	Enemy.imgs = {}
	for _, each in ipairs(Enemy.enemy_list) do
		self.quest_sprite = nil
	end
end
