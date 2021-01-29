Promise = {}
Promise.__index = Promise

function Promise:new()
	obj = {
		active = true,
		success_callback = function(data) end,
		error_callback = function(data) API.error(data) end,
		after_callback = function () end
	}
	setmetatable(obj, Promise)
	
	if API.promise then
		local tmp = API.promise.after_callback
		API.promise:after(function() 
			tmp()
			API.promise = obj
		end)
	else
		API.promise = obj
	end
	return obj
end

function Promise:success(func)
	self.success_callback = func
	return self
end

function Promise:fail(func)
	self.error_callback = func
	return self
end

function Promise:after(func)
	self.after_callback = func
	return self
end

function Promise:handle(response)
	if response.status == Constants.STATUS_OK then
		self.success_callback(Json.decode(response[1]))
	else
		self.error_callback({status=response.status})
	end
	
	self.after_callback()
end