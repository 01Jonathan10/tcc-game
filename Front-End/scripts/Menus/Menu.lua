Menu = {}
Menu.__index = Menu

function Menu:new(obj)
	local obj = obj or {}
	
	obj.back_btn = true
	obj.buttons = {}
	
	obj.div_img = love.graphics.newImage("assets/menus/Div.png")
	
	self.timer = 0
	
	setmetatable(obj, self)
	obj:setup()
	
	GameController.menu = obj
	
	MyLib.skip_frame = true
	
	return obj
end

function Menu:draw()
	self:show()
	
	View.setColor(1,1,1)
	if self.back_btn then
		View.rectangle("fill", 0,0,60,60)
	end
	
	if self.loading then
		Utils.draw_loading(self.timer/15)
	end
end

function Menu:draw_buttons()	
	for _, btn in ipairs(self.buttons) do
		self:draw_btn(btn)
	end
end

function Menu:draw_btn(btn)
	if btn.form == "circle" then
		local size = btn.r/175 * (btn.text_size or 1)
		self:draw_btn_circle(btn.x, btn.y, btn.r)
		View.printf(btn.text, btn.x - btn.r, btn.y - (btn.text_size or 1) * btn.r/7, 2*btn.r/size, "center", 0, size)
	else
		local size = (btn.text_size or 1) * math.min(btn.w, btn.h)/150
		self:draw_btn_panel(btn.x, btn.y, btn.w, btn.h)
		View.printf(btn.text, btn.x, btn.y + (btn.h/3)/(btn.text_size or 1), btn.w/size, "center", 0, size)
	end
	View.setColor(1,1,1)
end

function Menu:update(dt)
	self.timer = (self.timer + 60*dt)%360
	self:sub_update(dt)
end

function Menu:mousepressed(x,y,k) 
	if self.loading or self.disabled then return end
		
	if (x<=60 and y<=60) and self.back_btn then
		MyLib.FadeToColor(0.25, {function() 
			self:close_func() 
			MainMenu:new()
		end})
		self.disabled = true
		return
	end
	
	if k == 1 then
		for _, btn in ipairs(self.buttons) do
			if not btn.disabled then
				if btn.form == "circle" then
					if (btn.x-x)*(btn.x-x) + (btn.y-y)*(btn.y-y) <= btn.r*btn.r and not btn.disabled then
						btn.click()
						return
					end
				else
					if x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h and not btn.disabled then
						btn.click()
						return
					end
				end
			end
		end
	end
	
	self:click(x,y,k)
end

function Menu:is_down(btn)
	return love.mouse.isDown(btn)
end

function Menu:get_mouse_position()
	local x,y = love.mouse.getPosition()
	return Utils.convert_coords(x,y)
end

function Menu:draw_panel(x,y,w,h)
	View.setColor(0, 0, 0, 0.6)
	View.rectangle("fill", x+3, y+5, w, h, 5, 5, 10)
	View.setColor(0.92, 0.92, 0.83)
	View.rectangle("fill", x, y, w, h, 5, 5, 10)
	View.setColor(1,1,1)
end

function Menu:draw_btn_panel(x,y,w,h)
	View.setColor(0, 0, 0, 0.6)
	View.rectangle("fill", x+2, y+2, w, h, 2, 2)
	View.setColor(1,1,1)
	View.rectangle("fill", x, y, w, h, 2, 2)
	View.setColor(0,0,0)
end

function Menu:draw_btn_circle(x,y,r)
	View.setColor(0, 0, 0, 0.6)
	View.circle("fill", x+2, y+2, r)
	View.setColor(1,1,1)
	View.circle("fill", x, y, r)
	View.setColor(0,0,0)
end

function Menu:setup() end
function Menu:show() end
function Menu:sub_update(dt) end
function Menu:textinput(text) end
function Menu:keypressed(key) end
function Menu:close_func() end