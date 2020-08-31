Menu = {}
Menu.__index = Menu

function Menu:new(obj)
	local obj = obj or {}
	
	obj.back_btn = true
	obj.buttons = {}
	
	self.timer = 0
	
	setmetatable(obj, self)
	obj:setup()
	
	GameController.menu = obj
	
	return obj
end

function Menu:draw()
	self:show()
	
	if self.back_btn then
		View.rectangle("fill", 0,0,60,60)
	end
	
	if self.calling_api then
		Utils.draw_loading(self.timer/15)
	end
end

function Menu:draw_buttons()	
	for _, btn in ipairs(self.buttons) do
		self:draw_btn(btn)
	end
end

function Menu:draw_btn(btn)
	local size = math.min(btn.w, btn.h)/150
	View.rectangle("fill", btn.x, btn.y, btn.w, btn.h)
	View.printf(btn.text, btn.x, btn.y + btn.h/3, btn.w/size, "center", 0, size)
end

function Menu:update(dt)
	self.timer = (self.timer + 60*dt)%360
	
	if self.calling_api then
		local response = API.r_channel:pop()
		
		if response then
			if response.status == Constants.STATUS_OK then
				self:handle_response(Json.decode(response[1]), self.calling_api)
			else
				API.error()
				self.calling_api = nil
			end
		end
	end
	
	self:sub_update(dt)
end

function Menu:mousepressed(x,y,k) 
	if self.calling_api or self.disabled then return end
		
	if (x<=60 and y<=60) and self.back_btn then
		MyLib.FadeToColor(0.25, {function() 
			self:close_func() 
			MainMenu:new()
		end})
		self.disabled = true
		return
	end
	
	for _, btn in ipairs(self.buttons) do
		if x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h and not btn.disabled then
			btn.click()
			return
		end
	end
	
	self:click(x,y,k)
end

function Menu:setup() end
function Menu:show() end
function Menu:sub_update(dt) end
function Menu:textinput(text) end
function Menu:keypressed(key) end
function Menu:close_func() end
function Menu:handle_response(response, calling_api) end