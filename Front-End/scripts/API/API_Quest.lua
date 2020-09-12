function API.enter_quest(quest, diff)
	local data = {id=quest.id, difficulty=diff}
	API.channel:push({message = "post", url="/api/quest/enter/", body=Json.encode(data)})
end

function API.execute_quest_actions(actions)
	API.channel:push({message = "post", url="/api/quest/actions/", body=Json.encode(actions)})
end