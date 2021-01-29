function API.login_player(login, pass)
	local data = Utils.table_to_json({username=login, password=pass})
	return API.get_token(data)
end

function API.get_token(data)	
	API.channel:push({message = "post", url="/api/get-token/", body=data})
	return Promise:new()
end

function API.get_player()
	API.channel:push({message = "get", url="/api/player/get"})
	return Promise:new()
end

function API.create_player(player)
	local player = Player:new(player)
	local data = {
		level = 1,
		class = player.class,
		gender = player.gender,
		
		traits = player.traits,
		trait_colors = player.trait_colors,
		
		name = player.name,
		hp 	 = player.hp  ,
		atk  = player.atk ,
		def  = player.def ,
		matk = player.matk,
		mdef = player.mdef,
		luck = player.luck,
		mov  = player.mov ,
	}
	local player_data = Json.encode(data)
	
	API.channel:push({message = "post", url="/api/player/create/", body=player_data})
	return Promise:new()
end

function API.translate_player(player_data)
	if player_data.nochar then return player_data end
	local player = {}
		
	function color(hex,i) 
		return tonumber(hex:sub(i+1,i+2),16)/255
	end
	
	player.id = player_data.pk
	player.name = player_data.name
	player.level = player_data.level
	player.class = Class:get_class(player_data.job)
	player.gender = player_data.gender
		
	player.energy = player_data.energy
	player.xp = player_data.xp
	player.gold = player_data.gold
	player.diamonds = player_data.diamonds
	
	player.traits = {
		[Constants.EnumTrait.SKIN] = player_data.trait_skin,
		[Constants.EnumTrait.EYES] = player_data.trait_eyes,
		[Constants.EnumTrait.HAIR] = player_data.trait_hair,
	}
	
	player.trait_colors = {
		[Constants.EnumTrait.SKIN] = {color(player_data.trait_skin_color,1), color(player_data.trait_skin_color,3), color(player_data.trait_skin_color,5), 1},
		[Constants.EnumTrait.EYES] = {color(player_data.trait_eyes_color,1), color(player_data.trait_eyes_color,3), color(player_data.trait_eyes_color,5), 1},
		[Constants.EnumTrait.HAIR] = {color(player_data.trait_hair_color,1), color(player_data.trait_hair_color,3), color(player_data.trait_hair_color,5), 1},
	}

	player.stats = player_data.stats
	
	player.equipment = {}
	player.cosmetics = {}
	local cat
	
	for _, equip in ipairs(player_data.equipment) do
		cat = equip.type
		if equip.extra_slot then cat = cat+1 end
		
		equip.kind = equip.item_id 
		equip.item_id = nil
		
		player.equipment[cat] = Item:new(equip)
	end
	
	for _, equip in ipairs(player_data.cosmetics) do
		cat = equip.type
		equip.kind = equip.item_id
		equip.item_id = nil
		
		player.cosmetics[cat] = Item:new(equip)
	end
	
	for _, cat in pairs(Constants.ItemCategory) do
		player.equipment[cat] = player.equipment[cat] or Constants.NoneItem
	end
	
	if player_data.no_hat then
		player.cosmetics[Constants.ItemCategory.HEAD] = Constants.NoneItem
	end
	
	player.skills = player_data.skills
	
	return player
end