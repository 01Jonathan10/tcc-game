Quest = {}
Quest.__index = Quest

function Quest:new(obj)
	local obj = obj or {}
			
	setmetatable(obj, self)
		
	return obj
end

function Quest:rewards_list_str(diff)	
	return (300*diff).." Gold\n"..(500*diff).." XP"
end

function Quest:fc_rewards_str(diff)	
	return (1000*diff).." Gold\n"..(1500*diff).." XP"
end
