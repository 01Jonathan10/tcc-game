
def get_ai_actions(character, board_state, char_id):
	actions = [{},{},{'action': 'pass'}]
	actions[0] = get_move_action(character, board_state, char_id)
	actions[1] = get_attack_action(character, board_state, char_id)
	return actions
	
def get_move_action(character, board_state, char_id):
	new_position = {"x": character['position']['x'],"y": character['position']['y']}
	
	ai_var = board_state['objects'][char_id]['ai_vars'][0]
	board_state['objects'][char_id]['ai_vars'][0] = (board_state['objects'][char_id]['ai_vars'][0] + 1)%4
	
	if ai_var%2 == 0:
		new_position['x'] += ai_var - 1
	else:
		new_position['y'] += ai_var - 2
	
	return {
		"action": "move",
		"position": character['position'],
		"new_position": new_position,
	}
	
def get_attack_action(character, board_state, char_id):
	return {
		"action": "attack",
		"position": character['position'],
		"direction": 3,
		"skill": character['skills'][0]
	}