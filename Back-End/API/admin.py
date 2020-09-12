from django.contrib import admin
from django import forms

from . import models

class PlayerForm( forms.ModelForm ):
	stats = forms.CharField( widget=forms.Textarea )
	class Meta:
		model = models.Player
		exclude = ()

class PlayerAdmin( admin.ModelAdmin ):
	form = PlayerForm
	

admin.site.register(models.Player, PlayerAdmin)
admin.site.register(models.Enemy)
admin.site.register(models.PlayerClass)
admin.site.register(models.Item)
admin.site.register(models.ItemInstance)
admin.site.register(models.Quest)
admin.site.register(models.QuestInstance)
admin.site.register(models.Skill)
admin.site.register(models.Task)
admin.site.register(models.TaskInstance)
admin.site.register(models.TaskReview)
admin.site.register(models.Semester)
admin.site.register(models.Subject)
admin.site.register(models.Score)