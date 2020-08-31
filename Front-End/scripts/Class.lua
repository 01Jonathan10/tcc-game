Class = {}
Class.__index = Class

function Class:new(obj)
	obj = obj or {}
	setmetatable(obj, Class)
	return obj
end

function Class:get_class(id)
	local class_names = {"Mage", "Knight", "Thief"}
	return Class:new(
		{id = id, 
		name=class_names[id]}
	)
end

function Class:get_starter_classes()
	return {
		Class:new({
			id = Constants.EnumClass.MAGE, 
			name="Mage", 
			description="Skilled in magic, the mages blast away their foes or protect their allies with powerful spells"
		}),
		
		Class:new({
			id = Constants.EnumClass.KNIGHT,
			name="Knight", 
			description="Strong and robust soldiers, knights fight in the frontlines with close-combat weapons and heavy armor"
		}),
		
		Class:new({
			id = Constants.EnumClass.THIEF,
			name="Thief", 
			description="Agile and deadly, thieves fight from the shadows with long range weapons or backstabbing with light blades"
		}),
	}
end