Item = {}
Item.__index = Item
Item.icons = {}
Item.border_img = love.graphics.newImage("assets/menus/ItemBorder.png")

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
		View.setColor(1,0,0, alpha)
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

Constants.NoneItem = Item:new({id=-1, kind=0, name="No Item", stats={}})
