QuestController = {}
QuestController.__index = QuestController

function QuestController.load_quest(quest, actions)
	QuestController.map = Map:new(quest)
	QuestController.execute_actions(actions)
end

function QuestController.draw()
	QuestController.map:draw()
	QuestController.map:draw_UI()
end

function QuestController.update(dt)
	QuestController.map:update(dt)
end

function QuestController.mousepressed(x, y, k)
	QuestController.map:click(x, y, k)
end

function QuestController.add_obj(obj, x, y, enemy_team)
	local map = QuestController.map
		
	map[x][y].object = obj
	obj.position = {x=x, y=y, cell = map[x][y]}
	map[x][y].block = true
	
	obj.curr_hp = obj.stats.hp
		
	obj:load_mini_sprite()
	
	if enemy_team then
		table.insert(map.enem_team, obj)
		obj.facing = 0
	else
		table.insert(map.player_team, obj)
		obj.facing = 2
	end
end

function QuestController.execute_actions(actions)
	QuestController.map.action_queue = actions
end