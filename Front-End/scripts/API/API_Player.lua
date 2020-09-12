function API.get_player_items()
	local response
	API.channel:push({message = "get", url="/api/player/items"})
	
	GameController.waiting_api = function(response)
		local items = {{},{},{},{}}
		
		if response.status == Constants.STATUS_OK then
			local item_data = Json.decode(response[1])
			items = {{},{},{},{}}
			for _, each in ipairs(item_data) do
				cat = each.type
				each.kind = each.item_id
				each.item_id = nil
				table.insert(items[cat], Item:new(each))
			end
		else
			API.error()
		end
		
		GameController.tmp = items
	end
end

function API.equip_item(item, category, cosmetic)	
	local cosmetic = cosmetic or false
	local data = {id=item.id, slot=(category==Constants.ItemCategory.ACC_2), cat=category, cosmetic=cosmetic}
	API.channel:push({message = "post", url="/api/player/equip/", body=Json.encode(data)})
end

function API.get_quests()	
	API.channel:push({message = "get", url="/api/player/quests"})
end

function API.load_tasks()
	API.channel:push({message = "get", url="/api/tasks/all"})
end

function API.finish_task(task)
	API.channel:push({message = "post", url="/api/tasks/finish", body=Json.encode(task)})
end

function API.review_task(task, positive)
	API.channel:push({message = "post", url="/api/tasks/review", body=Json.encode({pk=task.pk, positive=positive})})
end

function API.create_task(task)
	API.channel:push({message = "post", url="/api/tasks/create", body=Json.encode(task)})
end

function API.load_scores()
	API.channel:push({message = "get", url="/api/scores/all"})
end

function API.claim_score(score)
	API.channel:push({message = "post", url="/api/scores/claim", body=Json.encode{pk=score.pk}})
end

function API.update_player()
	API.channel:push({message = "get", url="/api/player/update"})
end

function API.get_shop_items()
	API.channel:push({message = "get", url="/api/shop"})
end

function API.buy_item(item)
	API.channel:push({message = "post", url="/api/shop/buy", body=Json.encode{pk=item.kind}})
end

function API.get_skills(quest_id)
	API.channel:push({message = "get", url="/api/skills/quest?q_i_id="..quest_id})
end

function API.get_player_skills()
	API.channel:push({message = "get", url="/api/skills/player"})
end
