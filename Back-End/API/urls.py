from django.urls import path

from . import views

urlpatterns = [
	path(r'get-token/', views.GetToken.as_view(), name='get_token'),
	
	path(r'skills/all', views.GetSkills.as_view(), name='get_skills'),
	path(r'skills/player', views.GetPlayerSkills.as_view(), name='get_player_skills'),
	path(r'skills/quest', views.GetQuestSkills.as_view(), name='get_quest_skills'),
	
	path(r'scores/all', views.ScoreList.as_view(), name='get_scores'),
	path(r'scores/claim', views.ClaimScore.as_view(), name='claim_score'),
	
	path(r'tasks/all', views.TaskList.as_view(), name='get_tasks'),
	path(r'tasks/create', views.CreateTask.as_view(), name='create_task'),
	path(r'tasks/finish', views.FinishTask.as_view(), name='finish_task'),
	path(r'tasks/review', views.ReviewTask.as_view(), name='review_task'),
	
	path(r'player/get', views.GetPlayer.as_view(), name='get_player'),
	path(r'player/update', views.UpdatePlayer.as_view(), name='update_player'),
	path(r'player/items', views.GetPlayerItems.as_view(), name='get_player_items'),
	path(r'player/create/', views.CreatePlayer.as_view(), name='create_player'),
	path(r'player/equip/', views.EquipItem.as_view(), name='equip_item'),
	path(r'player/quests', views.GetQuests.as_view(), name='get_quests'),
	
	path(r'quest/enter/', views.EnterQuest.as_view(), name='enter_quest'),
	path(r'quest/actions/', views.QuestActions.as_view(), name='quest_actions'),
	
	path(r'shop', views.ShopItems.as_view(), name='shop'),
	path(r'shop/buy', views.BuyShopItem.as_view(), name='shop_buy'),
]
