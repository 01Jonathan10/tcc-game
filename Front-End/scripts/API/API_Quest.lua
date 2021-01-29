function API.enter_quest(quest, diff)
	local data = {id=quest.id, difficulty=diff}
	API.channel:push({message = "post", url="/api/quest/enter/", body=Json.encode(data)})
	return Promise:new()
end

function API.execute_quest_actions(actions)
	API.channel:push({message = "post", url="/api/quest/actions/", body=Json.encode(actions)})
	return Promise:new()
end

function API.update_map_actions()
	API.channel:push({message = "get", url="/api/quest/actions/"})
end