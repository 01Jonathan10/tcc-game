Alert = {}
Alert.__index = Alert

AlertTypes = {
	error = "e",
	notification = "n"
}

function Alert:new(message, type)
	local obj = {
		message = message or "Error",
		type = type or AlertTypes.error
	}

	setmetatable(obj, self)

	GameController.alert_stack.insert(obj, 1)
	
	return obj
end

function Alert:draw()
	View.setColor(0,0,0,0.2)
	View.rectangle("fill", 0,0,1280,720)
	

end

function Alert:draw_buttons()
	for _, btn in ipairs(self.buttons) do
		self:draw_btn(btn)
	end
end

function Alert:draw_btn(btn)
	local size = math.min(btn.w, btn.h)/150
	self:draw_btn_panel(btn.x, btn.y, btn.w, btn.h)
	View.printf(btn.text, btn.x, btn.y + btn.h/3, btn.w/size, "center", 0, size)
	View.setColor(1,1,1)
end

function Alert:mousepressed(x, y, k)
	GameController.alert_stack.remove(1)
end

function Alert:draw_btn_panel(x, y, w, h)
	View.setColor(0, 0, 0, 0.6)
	View.rectangle("fill", x+2, y+2, w, h, 2, 2)
	View.setColor(1,1,1)
	View.rectangle("fill", x, y, w, h, 2, 2)
	View.setColor(0,0,0)
end
