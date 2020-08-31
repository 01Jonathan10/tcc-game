Skill = {}
Skill.loaded_skills = {}
Skill.__index = Skill

function Skill:new(obj)
	setmetatable(obj, Skill)
		
	obj.range = obj.range:split(',')
		
	return obj
end

function Skill:get(id)
	if Skill.loaded_skills[id] then return Skill.loaded_skills[id] end
	return nil	
end

function Skill:get_multiple(ids)
	local skills, skill = {}, nil
	for _, id in ipairs(ids) do	
		table.insert(skills, Skill:get(id))
	end
	return skills
end

function Skill:translate_response(skill_data)
	local skill_list = {}
		
	for _, each in ipairs(skill_data) do	
		table.insert(skill_list, Skill:new(each))
	end
	
	return skill_list
end
