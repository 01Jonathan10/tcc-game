from rest_framework import serializers
from django.conf import settings

import json, os, datetime

from .models import Player, Quest, QuestInstance, Skill, TaskInstance, Task, TaskReview, Score, Item
from .controllers import QuestController


class SkillIdSerializer(serializers.ModelSerializer):
	class Meta:
		model = Skill
		fields = ['id']
		

class SkillSerializer(serializers.ModelSerializer):
	class Meta:
		model = Skill
		fields = ['id','name','effect','range','anim_id', 'description']
		
	effect = serializers.SerializerMethodField()
	
	def get_effect(self, obj):
		return obj.get_effect()
	

class PlayerSerializer(serializers.ModelSerializer):
	class Meta:
		model = Player
		fields = ['name', 'pk', 'level', 'job', 'gender', 'trait_skin', 'trait_hair', 'trait_eyes', 
		'trait_skin_color', 'trait_hair_color', 'trait_eyes_color', 'energy', 'skills', 'stats', 'xp', 'gold', 'diamonds']
		read_only_fields = ['diamonds', 'gold', 'xp', 'pk', 'energy']
	
	stats = serializers.SerializerMethodField()
	job = serializers.SerializerMethodField()
	
	trait_skin_color = serializers.SerializerMethodField()
	trait_hair_color = serializers.SerializerMethodField()
	trait_eyes_color = serializers.SerializerMethodField()
	
	skills = SkillIdSerializer(read_only=True, many=True)
	
	def get_job(self, obj):
		return obj.job.pk

	def get_trait_skin_color(self, obj):
		return obj.trait_skin_color

	def get_trait_hair_color(self, obj):
		return obj.trait_hair_color

	def get_trait_eyes_color(self, obj):
		return obj.trait_eyes_color
		
	def get_stats(self, obj):
		return obj.get_stats()

	def create(self, validated_data):
		return Player(**validated_data)
		
		
class ItemInstanceSerializer(serializers.Serializer):
	item_id = serializers.SerializerMethodField()
	id = serializers.IntegerField()
	type = serializers.SerializerMethodField()
	wpn_type = serializers.SerializerMethodField()
	name = serializers.SerializerMethodField()
	extra_slot = serializers.BooleanField()
	
	def get_item_id(self, obj):
		return obj.item.pk
	
	def get_type(self, obj):
		return obj.item.type
		
	def get_wpn_type(self, obj):
		return obj.item.wpn_type
		
	def get_name(self, obj):
		return obj.item.name


class QuestSerializer(serializers.ModelSerializer):
	class Meta:
		model = Quest
		fields = ['name', 'description', 'id', 'cleared', 'energy']
	
	cleared = serializers.SerializerMethodField()
	energy = serializers.SerializerMethodField()
	
	def get_cleared(self, obj):
		player_clears = obj.questinstance_set.filter(players__pk=obj.player_id, cleared=True)
		return [player_clears.filter(difficulty=diff).exists() for diff, _ in QuestInstance.DIFFICULTY_CHOICES]
		
	def get_energy(self, obj):
		return [obj.base_energy + obj.diff_modifier*diff for diff in range(len(QuestInstance.DIFFICULTY_CHOICES))]
		
	def get_id(self, obj):
		return self.pk
		
		
class QuestMapSerializer(serializers.Serializer):
	map_data = serializers.SerializerMethodField()
	id = serializers.SerializerMethodField()
	
	def get_map_data(self, obj):
		result = QuestController.get_board_state(obj)
		return result
		
	def get_id(self, obj):
		return obj.pk


class TaskInstanceSerializer(serializers.Serializer):
	name = serializers.SerializerMethodField()
	pk = serializers.IntegerField()
	description = serializers.SerializerMethodField()
	type = serializers.SerializerMethodField()
	finished = serializers.DateTimeField()
	approvals = serializers.SerializerMethodField()
	reports = serializers.SerializerMethodField()
	time_left = serializers.SerializerMethodField()
	reviewed = serializers.BooleanField(required=False)
	
	def get_name(self, obj):
		return obj.task.name
		
	def get_description(self, obj):
		return obj.task.description
		
	def get_type(self, obj):
		return obj.task.type
		
	def get_approvals(self, obj):
		return obj.taskreview_set.filter(positive=True).count()
		
	def get_reports(self, obj):
		return obj.taskreview_set.filter(positive=False).count()
		
	def get_time_left(self, obj):
		if datetime.datetime.now() > obj.deadline:
			return 0
			
		return int((obj.deadline - datetime.datetime.now()).total_seconds())


class ScoreSerializer(serializers.ModelSerializer):
	class Meta:
		model = Score
		fields = ['name', 'score', 'max', 'pk']


class ItemSerializer(serializers.ModelSerializer):
	class Meta:
		model = Item
		fields = ['name', 'wpn_type', 'type', 'price', 'stats', 'bought', 'pk']
		
	stats = serializers.SerializerMethodField()
	bought = serializers.BooleanField()
	
	def get_stats(self, obj):
		return obj.get_stats()
