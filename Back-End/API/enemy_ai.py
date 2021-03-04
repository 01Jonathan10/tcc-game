from API.constants import ObjType


def get_ai_actions(character, board_state, char_id):
    actions = [{}, {}, {'action': 'pass'}]
    actions[0] = get_move_action(character, board_state, char_id)
    actions[1] = get_attack_action(character, board_state, char_id)

    actions = [action for action in actions if action]

    return actions


def get_move_action(character, board_state, char_id):
    new_position = {"x": character['position']['x'], "y": character['position']['y']}

    ai_var = board_state['objects'][char_id]['ai_vars'][0]
    board_state['objects'][char_id]['ai_vars'][0] = (board_state['objects'][char_id]['ai_vars'][0] + 1) % 4

    if ai_var % 2 == 0:
        new_position['x'] += ai_var - 1
    else:
        new_position['y'] += ai_var - 2

    for object in board_state['objects']:
        if object['position']['x'] == new_position['x'] and object['position']['y'] == new_position['y']:
            return None

    character['new_position'] = new_position

    return {
        "action": "move",
        "position": character['position'],
        "new_position": new_position,
    }


def get_attack_action(character, board_state, char_id):
    position = character.get('new_position') or character['position']
    if character.get('new_position'):
        del character['new_position']

    action = {
        "action": "attack",
        "position": position,
        "skill": character['skills'][0]
    }

    directions = [
        [position['x'] + 1, position['y']],
        [position['x'], position['y'] + 1],
        [position['x'] - 1, position['y']],
        [position['x'], position['y'] - 1]
    ]

    for object in board_state['objects']:
        for direction in range(4):
            if object['position']['x'] == directions[direction][0] and object['position']['y'] == directions[direction][1]:
                if object['type'] == ObjType.PLAYER:
                    action['direction'] = direction + 1
                    print(action)
                    return action

    return None
