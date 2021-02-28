Alert = {}
Alert.__index = Alert

AlertTypes = {
	error = "e",
	notification = "n"
}

function Alert:new(message, type, callback)
	local obj = {
		message = message or "Error",
		type = type or AlertTypes.error,
		callback = callback or function() end,
		btn = {
			x = 600, y = 400, w=80, h=40, text = {Alert.get_color(type or AlertTypes.error), ("Close"):translate()}
		}
	}

	setmetatable(obj, self)

	table.insert(GameController.alert_stack, 1, obj)

	print(obj.message)

	return obj
end

function Alert:draw()
	View.setColor(0,0,0,0.4)
	View.rectangle("fill", 0,0,1280,720)

	self:draw_panel()
	self:draw_btn(self.btn)

	local color = Alert.get_color(self.type)

	View.printf({color, self.message}, 460, 320, 900, "center", 0, 2/5)
end

function Alert.get_color(type)
	local colors = {
		[AlertTypes.error] = {0.8,0,0},
		[AlertTypes.notification] = {0,0,0}
	}

	return colors[type] or {0,0,0}
end

function Alert:draw_panel()
	View.setColor(0.92, 0.92, 0.83)
	View.rectangle("fill", 450, 260, 380, 200, 5, 5, 10)
end

function Alert:draw_btn(btn)
	View.setColor(1,1,1)
	local size = math.min(btn.w, btn.h)/150
	self:draw_btn_panel(btn.x, btn.y, btn.w, btn.h)
	View.printf(btn.text, btn.x, btn.y + btn.h/3, btn.w/size, "center", 0, size)
end

function Alert:mousepressed(x, y, k)
	local btn = self.btn
	if k == 1 then
		if x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h then
			table.remove(GameController.alert_stack, 1)
			self.callback()
		end
	end
end

function Alert:draw_btn_panel(x, y, w, h)
	View.setColor(0, 0, 0, 0.6)
	View.rectangle("fill", x+2, y+2, w, h, 2, 2)
	View.setColor(1,1,1)
	View.rectangle("fill", x, y, w, h, 2, 2)
end
