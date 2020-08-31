local channel = love.thread.getChannel("taskChannel")
local r_channel = love.thread.getChannel("responseChannel")
local response, data

love.filesystem.setRequirePath('scripts/API/?.lua')
API = {}
require('API')

while true do
	task = channel:pop()
	
	if task then
		if task == "kill" then break end
		
		if task.message == "post" then
			response = API.post_request(task.url, task.body)
			data = ""
			for _, part in ipairs(response) do data = data..part end
			response[1] = data
			
			r_channel:push(response)
		
		elseif task.message == "get" then
			response = API.get_request(task.url)
			data = ""
			for _, part in ipairs(response) do data = data..part end
			response[1] = data
			
			r_channel:push(response)
		
		elseif task.message == "set_token" then
			API.token = task.token
		end
	end
end
