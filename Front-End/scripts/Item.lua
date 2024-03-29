Item = {}
Item.__index = Item
Item.icons = {}
Item.border_img = love.graphics.newImage("assets/menus/ItemBorder.png")

Item.rarities = {
	{1,0,0},
	{0.7,0.7,0.8},
	{0.99, 0.85, 0.45}
}

--TODO: Currencies as actual items
Item.currency = {
	diamond = love.graphics.newImage("assets/items/diamond.png"),
	gold = love.graphics.newImage("assets/items/gold.png"),
	xp = love.graphics.newImage("assets/items/xp.png")
}

function Item:new(obj)
	local obj = obj or {id=0, kind=0}
	
	obj.name = obj.name or "Test_Item "..obj.kind.." - "..obj.id
		
	setmetatable(obj, self)
		
	return obj
end

function Item:draw_icon(x,y, size, alpha)
	local alpha = alpha or 1
	if self == Constants.NoneItem then
		View.setColor(1,1,1, alpha)
		View.draw(Item.border_img, x, y, 0, size/100)
	else
		local color = Item.rarities[self.rarity or 1]
		color[4] = alpha
		View.setColor(unpack(color))
		View.draw(Item.border_img, x, y, 0, size/100)
		View.setColor(1,1,1, alpha)
		View.draw(Item.icons[self.kind], x, y, 0, size/500)
	end
	View.setColor(1,1,1)
end

function Item.load_icons(list)
	for cat, sublist in ipairs(list) do
		for _, item in ipairs(sublist) do
			Item.icons[item.kind] = Item.icons[item.kind] or item:load_single_icon(cat)
		end
	end
end

function Item:load_single_icon(cat)
	if self.kind <= 0 or Item.icons[self.kind] then return end
	local canvas = View.newCanvas(500,500)
	local img = love.graphics.newImage(string.format('assets/equips/%i/img.png', self.kind))
	local i
	
	View.setCanvas(canvas)

	love.graphics.push()
	love.graphics.origin()
	
	if cat == Constants.ItemCategory.WEAPON then
		View.draw(img, 0, 0)
	elseif cat == Constants.ItemCategory.ARMOR then
		View.draw(img, View.newQuad(500, 0, 500, 500, 1500, 1100),15, 0)
		View.draw(img, View.newQuad(0, 0, 500, 500, 1500, 1100),15, 0)
		View.draw(img, View.newQuad(1000, 0, 500, 500, 1500, 1100),15, 0)
	elseif cat == Constants.ItemCategory.HEAD then
		for i = 1,0,-1 do
			View.draw(img, View.newQuad(i*500, 0, 500, 500, 1000, 500),5, 0)
		end
	elseif cat >= Constants.ItemCategory.ACC then
		View.draw(img, 0, 0)
	end

	love.graphics.pop()
	
	View.setCanvas()
	
	Item.icons[self.kind] = love.graphics.newImage(canvas:newImageData())
	return Item.icons[self.kind]
end

function Item.draw_currency(x, y, size, currency)
	View.setColor(Item.rarities[3])
	View.draw(Item.border_img, x, y, 0, size/100)
	View.setColor(1,1,1)
	View.draw(Item.currency[currency], x, y, 0, size/500)
end

Constants.NoneItem = Item:new({id=-1, kind=0, name="No Item", stats={}})
