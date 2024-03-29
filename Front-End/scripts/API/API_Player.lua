function API.get_player_items()
	API.channel:push({message = "get", url="/api/player/items"})
	return Promise:new()
end

function API.equip_item(item, category, cosmetic)	
	local data = {id=item.id, slot=(category==Constants.ItemCategory.ACC_2), cat=category, cosmetic=cosmetic or false}
	API.channel:push({message = "post", url="/api/player/equip/", body=Json.encode(data)})
	return Promise:new()
end

function API.get_quests()	
	API.channel:push({message = "get", url="/api/player/quests"})
	return Promise:new()
end

function API.load_tasks()
	API.channel:push({message = "get", url="/api/tasks/all"})
	return Promise:new()
end

function API.finish_task(task)
	API.channel:push({message = "post", url="/api/tasks/finish", body=Json.encode(task)})
	return Promise:new()
end

function API.review_task(task, positive)
	API.channel:push({message = "post", url="/api/tasks/review", body=Json.encode({pk=task.pk, positive=positive})})
	return Promise:new()
end

function API.create_task(task)
	API.channel:push({message = "post", url="/api/tasks/create", body=Json.encode(task)})
	return Promise:new()
end

function API.load_scores()
	API.channel:push({message = "get", url="/api/scores/all"})
	return Promise:new()
end

function API.claim_score(score)
	API.channel:push({message = "post", url="/api/scores/claim", body=Json.encode{pk=score.pk}})
	return Promise:new()
end

function API.update_player()
	API.channel:push({message = "get", url="/api/player/update"})
	return Promise:new()
end

function API.get_shop_items()
	API.channel:push({message = "get", url="/api/shop"})
	return Promise:new()
end

function API.buy_item(item)
	API.channel:push({message = "post", url="/api/shop/buy", body=Json.encode{pk=item.kind}})
	return Promise:new()
end

function API.get_skills(quest_id)
	API.channel:push({message = "get", url="/api/skills/quest?q_i_id="..quest_id})
	return Promise:new()
end

function API.get_player_skills()
	API.channel:push({message = "get", url="/api/skills/player"})
	return Promise:new()
end
