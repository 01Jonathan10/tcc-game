import json, datetime, os

from django.db import models
from django.contrib.auth.models import User
from colorfield.fields import ColorField


class Enemy(models.Model):
	name = models.CharField(max_length=100)
	
	def __str__(self):
		return self.name
	
	
class PlayerClass(models.Model):
	name = models.CharField(max_length=100)
	
	def __str__(self):
		return self.name
		

class Skill(models.Model):
	DAMAGE_TYPES = [
		(1, 'Physical'),
        (2, 'Magical'),
        (3, 'True'),
	]
	
	ANIMATION_TRIGGER = [
		(1, 'Attack'),
        (2, 'Cast'),
	]
	
	name = models.CharField(max_length=20)
	effect = models.TextField(max_length=200)
	description = models.TextField(max_length=200)
	range = models.CharField(max_length=30)
	anim_id = models.IntegerField(choices=ANIMATION_TRIGGER)
	level_req = models.IntegerField(default=1)
	job_req = models.ForeignKey(PlayerClass, on_delete=models.CASCADE, null=True, blank=True)
	
	def __str__(self):
		return self.name
		
	def set_effect(self, x):
		self.effect = json.dumps(x)

	def get_effect(self):
		return json.loads(self.effect)


class Player(models.Model):
	GENDER_CHOICES = [
        ('M', 'Male'),
        ('F', 'Female'),
        ('O', 'Other'),
    ]
	
	user = models.OneToOneField(
		User,
		on_delete=models.CASCADE,
		primary_key=True,
	)
	
	name = models.CharField(max_length=100)
	level = models.IntegerField(default=1)
	xp = models.IntegerField(default=0)
	job = models.ForeignKey(PlayerClass, on_delete=models.SET_NULL, null=True)
	gender = models.CharField(max_length=1, choices=GENDER_CHOICES, default='F')
	energy = models.IntegerField(default=0)
	
	last_update = models.DateTimeField(default=datetime.datetime.now)
	
	gold = models.IntegerField(default=0)
	diamonds = models.IntegerField(default=0)
	
	stats = models.CharField(max_length=200)
	
	trait_skin = models.IntegerField(default=1)
	trait_hair = models.IntegerField(default=1)
	trait_eyes = models.IntegerField(default=1)
	
	trait_skin_color = ColorField()
	trait_hair_color = ColorField()
	trait_eyes_color = ColorField()
	
	no_hat = models.BooleanField(default=False)
	
	skills = models.ManyToManyField(Skill)
	
	def __str__(self):
		return self.name
		
	def get_equipment(self):
		return self.get_items().filter(equipped=True)
		
	def get_cosmetics(self):
		return self.get_items().filter(cosmetic=True)
		
	def get_items(self):
		return ItemInstance.objects.filter(owner=self)
		
	def set_stats(self, x):
		self.stats = json.dumps(x)
		
	def set_stat(self, stat, value):
		stats = self.get_stats()
		stats[stat] = value
		self.set_stats(stats)

	def get_stats(self):
		return json.loads(self.stats)				
		

class Item(models.Model):
	ITEMTYPE_CHOICES = [
		(1, 'Weapon'),
        (2, 'Head'),
        (3, 'Armor'),
        (4, 'Accessory'),
	]
	
	WPNTYPE_CHOICES = [
		(0, 'None'),
		(1, 'Sword'),
        (2, 'Dagger'),
        (3, 'Bow'),
        (4, 'Spear'),
        (5, 'Staff'),
        (6, 'Book'),
	]
	
	name = models.CharField(max_length=100)
	type = models.IntegerField(choices=ITEMTYPE_CHOICES, default=1)
	wpn_type = models.IntegerField(choices=WPNTYPE_CHOICES, default=0)
	price = models.IntegerField(default = 100)
	stats = models.CharField(max_length=200)
	
	def __str__(self):
		return self.name
		
	def get_stats(self):
		return json.loads(self.stats)
		
		
class ItemInstance(models.Model):
	item = models.ForeignKey(Item, on_delete=models.CASCADE)
	owner = models.ForeignKey(Player, on_delete=models.CASCADE)
	equipped = models.BooleanField(default=False)
	cosmetic = models.BooleanField(default=False)
	extra_slot = models.BooleanField(default=False)
	
	def __str__(self):
		return "{},{}".format(self.item.name, self.owner.name)


class Quest(models.Model):
	name = models.CharField(max_length=100)
	description = models.CharField(max_length=1000, blank=True, null=True)
	base_energy = models.IntegerField(default=0)
	diff_modifier = models.IntegerField(default=0)
	map_id = models.IntegerField(default=0)
	
	def __str__(self):
		return self.name
	
	
class QuestInstance(models.Model):
	DIFFICULTY_CHOICES = [
        (1, 'Easy'),
        (2, 'Medium'),
        (3, 'Hard'),
    ]
	
	quest = models.ForeignKey(Quest, on_delete=models.CASCADE)
	difficulty = models.IntegerField(choices=DIFFICULTY_CHOICES, default=1)
	active = models.BooleanField(default=True)
	cleared = models.BooleanField(default=False)
	players = models.ManyToManyField(Player)
	
	def finish(self, victory):
		self.active=False 
		self.cleared=victory
		self.save()
		
		path = os.path.join(settings.STATIC_ROOT,"data/q_i_info/{}.json".format(self.pk))
		if os.path.exists(path):
			os.remove(path)
	
	
class Task(models.Model):
	TASKTYPES = [
        (1, 'One-Off'),
        (2, 'Daily'),
        (3, 'Weekly'),
        (4, 'Monthly'),
    ]
	
	name = models.CharField(max_length=100)
	description = models.CharField(max_length=250, blank=True)
	type = models.IntegerField(choices=TASKTYPES)
	owner = models.ForeignKey(Player, on_delete=models.CASCADE)
	
	def __str__(self):
		return self.name	


class TaskInstance(models.Model):
	task = models.ForeignKey(Task, on_delete=models.CASCADE)
	finished = models.DateTimeField(blank=True, null=True)
	disabled = models.BooleanField(default=False)
	created = models.DateTimeField(default=datetime.datetime.now)
	deadline = models.DateTimeField(default=datetime.datetime.now)		


class TaskReview(models.Model):
	task = models.ForeignKey(TaskInstance, on_delete=models.CASCADE)
	positive = models.BooleanField()
	reviewer = models.ForeignKey(Player, on_delete=models.SET_NULL, null=True)


class Semester(models.Model):
	name = models.CharField(max_length=20)
	
	def __str__(self):
		return self.name


class Subject(models.Model):
	name = models.CharField(max_length=20)
	
	def __str__(self):
		return self.name


class Score(models.Model):
	name = models.CharField(max_length=100)
	score = models.IntegerField()
	max = models.IntegerField()
	owner = models.ForeignKey(Player, on_delete=models.CASCADE)
	active = models.BooleanField(default=True)
	claimed = models.BooleanField(default=False)
	
	subject = models.ForeignKey(Subject, on_delete=models.CASCADE)
	semester = models.ForeignKey(Semester, on_delete=models.CASCADE)	
	
	def __str__(self):
		return self.name
		
	def claim(self):
		self.claimed=True
		self.save()
