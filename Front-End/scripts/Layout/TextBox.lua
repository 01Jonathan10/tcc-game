Textbox = {}
Textbox.__index = Textbox

local utf8 = require('utf8')

function Textbox:init()
	Textbox.list = {}
	Textbox.active_box = nil
end

function Textbox:dispose()
	Textbox.list = nil
	Textbox.active_box = nil
end

function Textbox:new(name, x, y, width, height, color, lines, is_password)
	local box = {
		name = name,
		x = x,
		y = y,
		width = width,
		height = height,
		color = color,
		lines = lines or 1,
		
		text = "",
		active = false,
		cursor = 0,
		index = #Textbox.list + 1,
		is_password = is_password or nil
	}
	
	setmetatable(box, self)
	table.insert(Textbox.list, box)
	
	return box
end

function Textbox:draw()
	color = {unpack(self.color)}
	color[4] = 1
	if not self.active then color[4] = 0.5 end
		
	View.setColor(unpack(color))
	View.rectangle("fill",self.x,self.y,self.width,self.height)
	View.setColor(1,1,1)
	local size = self.height/(self.lines or 1)
	local text = self.text
	if self.is_password then
		text = ""
		for _ = 1,#self.text do
			text = "*"..text
		end
	end
	View.printf(text,self.x+size/10,self.y+size/10, self.width*250/(size*3), "left", 0, size*3/250)
end

function Textbox:textinput(t)
	self.text = self.text..t
end

function Textbox:keypressed(key)
	if key == "backspace" then 
		self.text = self.text:remove_last()
	end
end

function Textbox:trigger()
	self.cursor = #self.text
	if Textbox.active_box then Textbox.active_box.active = false end
	self.active = true
	Textbox.active_box = self
end

function Textbox.mouseclick(x,y,k)
	if k ~= 1 then return end
	if Textbox.active_box then Textbox.active_box.active = false Textbox.active_box = nil end
	for _, box in ipairs(Textbox.list) do 
		if x >= box.x and x <= box.x+box.width and y >= box.y and y <= box.y + box.height then
			box:trigger()
		end
	end
end

function Textbox.draw_all()
	for _, box in ipairs(Textbox.list) do box:draw() end
end
