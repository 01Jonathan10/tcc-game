import json, os, math, random, datetime
from dateutil.relativedelta import *

from django.conf import settings

from .models import Player, Quest, Item, ItemInstance, QuestInstance, Skill, Task, TaskInstance
from .constants import ItemType, ObjType, DmgType

from . import enemy_ai

class PlayerController():
	@staticmethod
	def gain_starting_items(player):
		items = Item.objects.filter(name__startswith=player.job.name+"'")
		for item in items:
			ItemInstance.objects.create(item=item, owner=player, equipped=True)
			
	@staticmethod
	def set_initial_stats(player):
		player.set_stats({
			"hp": 100,
			"atk": 5,
			"matk": 5,
			"def": 10,
			"mdef": 15,
			"luck": 0,
			"mov": 4,
			"speed": 10
		})
	
	@staticmethod
	def gain_item(player, item):
		ItemInstance.objects.create(item=item, owner=player)
		
	@staticmethod
	def equip_item(player, i_i, slot=False):
		prev = ItemInstance.objects.filter(item__type=i_i.item.type, owner=player, equipped=True)
		
		if prev.exists():
			prev.filter(extra_slot=slot).update(equipped=False)
		
		i_i.equipped=True
		i_i.extra_slot = slot
		i_i.save()
		
	@staticmethod
	def unequip_item(player, category, slot=False):
		category = min(category, ItemType.ACC)
		prev = ItemInstance.objects.filter(item__type=category, owner=player, equipped=True)
		
		if prev.exists():
			prev.filter(extra_slot=slot).update(equipped=False)
			
	@staticmethod
	def equip_cosmetic(player, i_i):
		prev = ItemInstance.objects.filter(item__type=i_i.item.type, owner=player, cosmetic=True)
		
		if prev.exists():
			prev.update(cosmetic=False)
		
		i_i.cosmetic=True
		i_i.save()
			
	@staticmethod
	def unequip_cosmetic(player, category):
		prev = ItemInstance.objects.filter(item__type=category, owner=player, cosmetic=True)
		
		if prev.exists():
			prev.update(cosmetic=False)
			
	@staticmethod
	def update_player(player):
		PlayerController.update_player_energy(player)
		
		tasks_past_deadline = TaskInstance.objects.filter(task__owner=player, finished__isnull=True, deadline__lt=datetime.datetime.now())
		TaskController.update_deadlines(tasks_past_deadline.all())
		
		now = datetime.datetime.now()
		now = datetime.datetime(now.year, now.month, now.day, now.hour, now.minute)
		player.last_update = now
		player.save()
		
	@staticmethod
	def update_player_energy(player):
		delta = datetime.datetime.now() - player.last_update
		min_passed = int(delta.seconds/60)
		if min_passed >= 1:
			player.energy = min(player.energy + min_passed, 100)


class QuestController():
	board_state = None
	def __init__(self, q_i):
		self.board_state = QuestController.get_board_state(q_i)
		self.q_i = q_i
	
	@staticmethod
	def enter_quest(quest, diff, player):
		
		current = QuestInstance.objects.filter(players=player, quest=quest, difficulty=diff, active=True)
		if current.exists():
			return current.get()
			
		if QuestInstance.objects.filter(players=player, active=True).exists():
			return None
		
		energy_cost = quest.base_energy + quest.diff_modifier*(diff-1)
		
		if energy_cost > player.energy:
			return None
			
		q_i = QuestInstance.objects.create(quest=quest, difficulty=diff)
		q_i.players.add(player)
		player.energy = player.energy - energy_cost
		
		q_i.save()
		player.save()
		
		return q_i
		
	@staticmethod
	def execute_actions(actions, q_i):
		qc = QuestController(q_i)
		qc.board_state['actions'] = []
		
		for action in actions:
			if not qc.validate(action):
				return None
				
		for action in actions:
			qc.board_state['actions'].append(action)
			qc.execute(action)
			
		qc.save_board_state(q_i)
		
		return qc.board_state
		
	@staticmethod
	def get_board_state(q_i):
		path = os.path.join(settings.STATIC_ROOT,"data/q_i_info/{}.json".format(q_i.id))
		if not os.path.exists(path):
			board_state = QuestController.starting_board(q_i, path)
		else:
			data = open(path)
			board_state = json.load(data)
			data.close()
		
		return board_state
		
	@staticmethod
	def starting_board(q_i, filename):
		board = {}
		map_data_path = os.path.join(settings.STATIC_ROOT,"data/maps/{}.json".format(q_i.quest.id))
		with open(map_data_path) as file:
			map_data = json.load(file)
		
		board['dim'] = map_data['dim']
		board['objects'] = []
		board['available_actions'] = [True, True]
		char_id = 0
		
		for i, player in enumerate(q_i.players.all()):
			stats = player.get_stats()
			board['objects'].append({
				"type": ObjType.PLAYER,
				"position": {"x": map_data['players'][2*i], "y": map_data['players'][2*i+1]},
				"id": player.pk,
				"char_id": char_id,
				"stats": stats,
				"hp": stats['hp']
			})
			char_id += 1
			
		for i, enemy in enumerate(map_data['enemies']):
			data = QuestController.get_enemy_stats(enemy['id'])
			board['objects'].append({
				"type": ObjType.ENEMY,
				"position": {"x": enemy['position'][0], "y": enemy['position'][1]},
				"id": enemy['id'],
				"char_id": char_id,
				"stats": data['stats'],
				"hp": data['stats']['hp'],
				"name": data['name'],
				"skills": data['skills'],
				"ai_vars": [0]
			})
			char_id += 1
			
		board['turn_order'] = [character['char_id'] for character in board['objects']]
		board['turn'] = 1
		
		board['z_map'] = map_data['z_map']
		board['block_map'] = map_data['block_map']
				
		with open(filename, 'w') as file:
			json.dump(board, file)
			
		return board
		
	@staticmethod
	def get_enemy_stats(id):
		path = os.path.join(settings.STATIC_ROOT,"data/enemies/{}.json".format(id))
		with open(path) as file:
			return json.load(file)
		
	def get_char_in_turn(self, turn):
		id = self.board_state['turn_order'][turn-1]
		return self.board_state['objects'][id]
		
	def get_char_in_pos(self, position):
		for character in self.board_state['objects']:
			if character['position']['x'] == position['x'] and character['position']['y'] == position['y']:
				return character
		return None		

	def validate(self, action):
		character = self.get_char_in_turn(self.board_state['turn'])
		if character['id'] != action['player_id']:
			return None
			
		if action['action'] == "pass":
			return True
			
		if action['action'] == "move":
			if not self.board_state['available_actions'][0]:
				return None
			return True
			
		if action['action'] == "attack":
			if not self.board_state['available_actions'][1]:
				return None
			return True
			
		return None
		
	def execute(self, action):
		character = self.get_char_in_turn(self.board_state['turn'])
		
		if action['action'] == "pass":
			self.board_state['turn'] = self.board_state['turn'] % len(self.board_state['turn_order'])
			self.board_state['turn'] += 1
			current_turn = self.get_char_in_turn(self.board_state['turn'])
			
			while current_turn.get('dead'):
				self.board_state['turn'] = self.board_state['turn'] % len(self.board_state['turn_order'])
				self.board_state['turn'] += 1
				current_turn = self.get_char_in_turn(self.board_state['turn'])
				
			if current_turn['type'] == ObjType.ENEMY and not self.board_state.get('end'):
				actions = enemy_ai.get_ai_actions(current_turn, self.board_state, current_turn['char_id'])
				for ai_action in actions:
					self.board_state['actions'].append(ai_action)
					self.execute(ai_action)
					
			self.board_state['available_actions'] = [True, True]
			return
			
		if action['action'] == "move":				
			character['position'] = action['new_position']
			self.board_state['available_actions'][0] = False
			return
			
		if action['action'] == "attack":
			self.board_state['available_actions'][1] = False
			
			skill = Skill.objects.get(pk=action['skill'])
			cells = self.get_skill_range(character, skill, action['direction'])
			effect = skill.get_effect()
			att_char = self.get_char_in_turn(self.board_state['turn'])
			for cell in cells:
				def_char = self.get_char_in_pos(cell)
				if def_char:
					if effect['type'] == "damage":
						self.cause_damage(att_char, def_char['char_id'], effect)
			return
		
	def save_board_state(self, q_i):
		path = os.path.join(settings.STATIC_ROOT,"data/q_i_info/{}.json".format(q_i.id))
		with open(path, 'w') as file:
			json.dump(self.board_state, file)

	def get_skill_range(self, character, skill, direction):
		origin = {"x":character["position"]["x"], "y":character["position"]["y"]}
		instr = {"F":0,"R":1,"B":2,"L":3}
		elems = skill.range.split(",")
		
		result = []
		
		for elem in elems:
			pos = {"x":origin["x"], "y":origin["y"]}
			for i in range(int(len(elem)/2)):
				delta = int(elem[2*i + 1])
				letter = elem[2*i]
				
				rot = (instr[letter] + direction)%4
				angle = rot*math.pi/2
				pos["x"] += int(math.sin(angle)*delta)
				pos["y"] -= int(math.cos(angle)*delta)
							
			result.append(pos)
			
		return result

	def cause_damage(self, att_char, def_char_id, effect):
		random.seed()
		
		def_char = self.board_state['objects'][def_char_id]
		multiplier = att_char['stats']['atk']
		
		if effect['dmg_type'] == DmgType.PHYSICAL:
			multiplier = multiplier/def_char['stats']['def']
		elif effect['dmg_type'] == DmgType.MAGICAL:
			multiplier = multiplier/def_char['stats']['mdef']
		else:
			multiplier = multiplier/min(def_char['stats']['mdef'],def_char['stats']['def'])

		damage = math.floor(effect['power']*multiplier*(0.85+0.3*random.random()))
				
		self.board_state['actions'].append({
			"action": "take_dmg",
			"char_id": def_char_id,
			"damage": damage
		})
		
		self.board_state['objects'][def_char_id]['hp'] -= damage
		
		if self.board_state['objects'][def_char_id]['hp'] <= 0:
			self.character_die(def_char_id)
			
	def character_die(self, char_id):
		self.board_state['objects'][char_id]['dead'] = True
		self.board_state['objects'][char_id]['position'] = {"x":-1,"y":-1}
		self.board_state['objects'][char_id]['hp'] = 0
		self.board_state['actions'].append({
			"action": "death",
			"char_id": char_id
		})
				
		self.check_end()
		
	def check_end(self):
		enem_victory = True
		player_victory = True
		for character in self.board_state['objects']:
			if not character.get('dead'):
				if character['type'] == ObjType.PLAYER:
					enem_victory = False
				elif character['type'] == ObjType.ENEMY:
					player_victory = False
		
		if not (player_victory or enem_victory):
			return
					
		self.board_state['actions'].append({
			"action": "finish",
			"victory": player_victory
		})
		
		self.board_state['end'] = True
		
		self.q_i.finish(player_victory)


class TaskController():

	@staticmethod
	def update_deadlines(tasks):
		for taskinstance in tasks:
			while(taskinstance.deadline < datetime.datetime.now()):
				if taskinstance.task.type == 2:
					taskinstance.deadline += datetime.timedelta(days=1)
				elif taskinstance.task.type == 3:
					taskinstance.deadline += relativedelta(days=+1, weekday=MO(+1))
				elif taskinstance.task.type == 4:
					taskinstance.deadline += relativedelta(days=+1, day=31)
				else:
					break
			taskinstance.disabled = False
			taskinstance.save()
			
	@staticmethod
	def create_next(taskinstance):
		if taskinstance.task.type > 1:
			t_i = TaskInstance.objects.create(
				task=taskinstance.task, 
				disabled=True,
				created=datetime.datetime.now(),
				deadline=taskinstance.deadline)
			return t_i
				
					
	@staticmethod
	def create_task(player, data):
		task = Task.objects.create(
			name=data.get('name'), 
			description=data.get('description'), 
			type=data.get('type'),
			owner=player
		)
				
		task_instance_model = TaskInstance(
			task=task,
			created=datetime.datetime.now(),
			deadline=datetime.datetime.today(),
		)
		
		deadline = task_instance_model.deadline
		task_instance_model.deadline = datetime.datetime(deadline.year, deadline.month, deadline.day)
		
		if task.type > 1:
			t_i = TaskController.create_next(task_instance_model)
			TaskController.update_deadlines([t_i])
		else:
			task_instance_model.finished = task_instance_model.created
			task_instance_model.deadline = task_instance_model.created + datetime.timedelta(seconds=1)
			task_instance_model.save()
