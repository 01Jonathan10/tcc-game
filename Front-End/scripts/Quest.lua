Quest = {}
Quest.__index = Quest

function Quest:new(obj)
	local obj = obj or {}
			
	setmetatable(obj, self)
		
	return obj
end

function Quest:rewards(diff)
	return {
		gold = 300*diff,
		xp = 500*diff
	}
end

function Quest:rewards_list_str(diff)
	local rewards = self:rewards(diff)
	return rewards.gold.." Gold\n"..rewards.xp.." XP"
end

function Quest:fc_rewards_str(diff)
	local rewards = self:rewards(diff)
	return 3*rewards.gold.." Gold\n"..3*rewards.xp.." XP"
end
