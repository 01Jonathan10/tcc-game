API.server_domain = "https://tcc-quest-for-the-degree.herokuapp.com/"

API.channel = love.thread.getChannel("taskChannel")
API.r_channel = love.thread.getChannel("responseChannel")
API.http = require("socket.http")
local ltn12 = require("ltn12")

function API.run_thread()
	API.thread = love.thread.newThread("scripts/API/API_Server.lua")
	API.thread:start()
	API.promise = nil
end

function API.post_request(url, data)
	local url = url or ""
	local data = data or "{}"
	local response = {status = nil}
	
	local headers = {
		["Content-Type"] = "application/json",
		["Content-Length"] = data:len()
	}
	if API.token then headers.Authorization = "Token "..API.token end
			
	_, response.status, _ = API.http.request {
		url = API.server_domain..url,
		method = "POST",
		headers = headers,
		
		source = ltn12.source.string(data),
		sink = ltn12.sink.table(response)
	}
	
	return response
end

function API.get_request(url)
	local url = url or ""
	local response = {status = nil}
	
	local headers = {}
	if API.token then headers.Authorization = "Token "..API.token end
			
	_, response.status, _ = API.http.request {
		url = API.server_domain..url,
		method = "GET",
		headers = headers,
		
		sink = ltn12.sink.table(response)
	}
	
	return response
end

function API.error(data)
	-- love.event.push('quit')
	Alert:new(data[1], AlertTypes.error)
end