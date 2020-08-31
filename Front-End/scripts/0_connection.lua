function run_server_bg(DNS_table, DNS_log, t_channel)
	local threadCode = "server.lua"
	
	local thread = love.thread.newThread(threadCode)
    thread:start(DNS_table, DNS_log, t_channel)
end

function client_test(msg, is_tcp, destination)
    
	local host, port = "127.0.0.1", "80"
	
    local tcp = assert(socket.tcp())

    tcp:connect(host, port)
	tcp:settimeout(1)
	
	msg = "ping"
		
    tcp:send(msg.."\n")
	
    tcp:close()
end
