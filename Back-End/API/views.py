import datetime
import json

from django.contrib.auth import authenticate
from django.db.models import Exists, OuterRef, Q, F
from django.http import HttpResponseForbidden
from django.views.decorators.csrf import csrf_exempt
from rest_framework.authtoken.models import Token
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from . import controllers
from . import models
from . import serializers
from .constants import Constants
from .constants import ItemType
from .quest_controller import QuestController
from .utils import rgb_to_color


class BaseView(APIView):
    permission_classes = (IsAuthenticated,)

    @csrf_exempt
    def dispatch(self, *args, **kwargs):
        return super(BaseView, self).dispatch(*args, **kwargs)


class GetToken(APIView):
    @csrf_exempt
    def dispatch(self, *args, **kwargs):
        return super(GetToken, self).dispatch(*args, **kwargs)

    def post(self, request, *args, **kwargs):
        data = json.loads(request.body)

        user = authenticate(username=data.get('username', ""), password=data.get('password', ''))
        token = None
        if user is not None:
            token, _ = Token.objects.get_or_create(user=user)
            char_data = {"nochar": (not models.Player.objects.filter(user=user).exists())}
            return Response({"token": token.pk, "player": char_data})
        return HttpResponseForbidden()


class CreatePlayer(BaseView):
    def post(self, request):
        request.data['trait_hair'] = request.data['traits']['hair']
        request.data['trait_skin'] = request.data['traits']['skin']
        request.data['trait_eyes'] = request.data['traits']['eyes']

        serializer = serializers.PlayerSerializer(data=request.data)

        if not serializer.is_valid():
            raise Exception("Name must be filled")

        player = serializer.save()

        player.user = request.user

        player.trait_hair_color = rgb_to_color(request.data['trait_colors']['hair'])
        player.trait_skin_color = rgb_to_color(request.data['trait_colors']['skin'])
        player.trait_eyes_color = rgb_to_color(request.data['trait_colors']['eyes'])

        player.job = models.PlayerClass.objects.get(pk=request.data['class'])
        player.energy = Constants.MAX_ENERGY

        controllers.PlayerController.set_initial_stats(player)

        basic_attack = models.Skill.objects.get(pk=1)
        player.save()
        player.skills.add(basic_attack)

        controllers.PlayerController.gain_starting_items(player)

        return Response({'status': 'ok'})


class GetPlayer(BaseView):
    def get(self, request):
        player = request.user.player

        controllers.PlayerController.update_player(player)

        char_data = serializers.PlayerSerializer(player).data
        char_data["equipment"] = serializers.ItemInstanceSerializer(player.get_equipment(), many=True).data
        char_data["cosmetics"] = serializers.ItemInstanceSerializer(player.get_cosmetics(), many=True).data
        return Response(char_data)


class UpdatePlayer(BaseView):
    def get(self, request):
        controllers.PlayerController.update_player(request.user.player)

        return Response({"energy": request.user.player.energy})


class GetSkills(BaseView):
    def get(self, request):
        return Response(serializers.SkillSerializer(models.Skill.objects.all(), many=True).data)


class GetQuestSkills(BaseView):
    def get(self, request):
        players = models.Player.objects.filter(questinstance__id=request.GET.get('q_i_id'))
        skills = models.Skill.objects.filter(player__in=players)
        return Response(serializers.SkillSerializer(skills, many=True).data)


class GetPlayerSkills(BaseView):
    def get(self, request):
        player = request.user.player
        player_skills = models.Skill.objects.filter(
            Q(level_req__lte=player.level),
            Q(job_req__isnull=True) | Q(job_req=player.job)
        )
        return Response(serializers.SkillSerializer(player_skills, many=True).data)


class GetPlayerItems(BaseView):
    def get(self, request):
        player = models.Player.objects.get(pk=request.user.player.pk)
        return Response(serializers.ItemInstanceSerializer(player.get_items(), many=True).data)


class EquipItem(BaseView):
    def post(self, request):

        if request.data['id'] == -1:
            if request.data.get('cat') in [ItemType.WEAPON, ItemType.ARMOR] and request.data.get('cosmetic') is None:
                return HttpResponseForbidden()
            if request.data.get('cosmetic'):
                controllers.PlayerController.unequip_cosmetic(self.request.user.player, request.data.get('cat'))
            else:
                controllers.PlayerController.unequip_item(self.request.user.player, request.data.get('cat'),
                                                          slot=request.data.get('slot'))
            return Response({})

        i_i = models.ItemInstance.objects.get(pk=request.data['id'])
        if i_i.owner == request.user.player:
            if request.data.get('cosmetic'):
                controllers.PlayerController.equip_cosmetic(i_i.owner, i_i)
            else:
                controllers.PlayerController.equip_item(i_i.owner, i_i, slot=request.data.get('slot'))
            return Response({})

        return HttpResponseForbidden()


class GetQuests(BaseView):
    def get(self, request):
        player = self.request.user.player
        data = serializers.QuestSerializer(models.Quest.objects.all().extra(select={'player_id': player.pk}),
                                           many=True).data
        return Response(data)


class EnterQuest(BaseView):
    def post(self, request):
        quest = models.Quest.objects.get(pk=request.data.get('id'))

        q_i = QuestController.enter_quest(quest, request.data.get('difficulty'), request.user.player)
        if q_i is not None:
            return Response({
                "quest": serializers.QuestMapSerializer(q_i).data,
                "diff": request.data.get('difficulty')
            })

        current = models.QuestInstance.objects.filter(players=self.request.user.player, active=True).first()
        message = "Can't enter quest! You're still in quest"
        return HttpResponseForbidden(
            f"{message} {current.quest.name} - "
            f"{models.QuestInstance.DIFFICULTY_CHOICES[current.difficulty-1][1]}")


class QuestActions(BaseView):
    def post(self, request):
        q_i = models.QuestInstance.objects.filter(players=request.user.player, active=True)
        if not q_i.exists():
            return HttpResponseForbidden()

        board_state = QuestController.execute_actions(request.data, q_i.get())

        if board_state:
            return Response(board_state)

        return HttpResponseForbidden()

    def get(self, request):
        q_i = models.QuestInstance.objects.filter(players=request.user.player, active=True)
        if not q_i.exists():
            return HttpResponseForbidden()

        board_state = QuestController(q_i.get()).board_state

        if board_state:
            return Response(board_state)

        return HttpResponseForbidden()


class TaskList(BaseView):
    def get(self, request):
        player_tasks = models.TaskInstance.objects.filter(task__owner=request.user.player, disabled=False).order_by(
            F("finished").desc(nulls_first=True))
        other_tasks = models.TaskInstance.objects.filter(finished__isnull=False, disabled=False).exclude(
            task__owner=request.user.player)

        other_tasks = other_tasks.annotate(
            reviewed=Exists(models.TaskReview.objects.filter(task__pk=OuterRef('pk'), reviewer=request.user.player)))

        response = {
            "player": serializers.TaskInstanceSerializer(player_tasks, many=True).data,
            "all": serializers.TaskInstanceSerializer(other_tasks, many=True,
                                                      context={"player": request.user.player}).data
        }

        return Response(response)


class CreateTask(BaseView):
    def post(self, request):
        player = self.request.user.player

        controllers.TaskController.create_task(player, request.data)

        return Response({})


class FinishTask(BaseView):
    def post(self, request):
        player = self.request.user.player

        t_i = models.TaskInstance.objects.filter(pk=request.data.get('pk'), task__owner=player, finished__isnull=True,
                                                 disabled=False)

        if t_i.exists():
            t_i = t_i.get()

            if t_i.deadline < datetime.datetime.now():
                return HttpResponseForbidden()

            t_i.finished = datetime.datetime.now()
            t_i.save()

            t_i.owner.gold += t_i.base_reward()
            t_i.owner.save()

            controllers.TaskController.create_next(t_i)
            return Response({})

        return HttpResponseForbidden()


class ReviewTask(BaseView):
    def post(self, request):
        player = self.request.user.player

        t_i = models.TaskInstance.objects.filter(pk=request.data.get('pk'), finished__isnull=False, disabled=False)

        if t_i.exists():
            t_i = t_i.get()

            prev_review = models.TaskReview.objects.filter(reviewer=player, task=t_i)
            if prev_review.exists():
                return HttpResponseForbidden()

            models.TaskReview.objects.create(task=t_i, reviewer=player, positive=request.data.get('positive'))

            player.gold += t_i.base_reward()
            player.save()

            if request.data.get('positive'):
                t_i.owner.gold += t_i.base_reward()
                t_i.owner.save()

            return Response({})

        return HttpResponseForbidden()


class ScoreList(BaseView):
    def get(self, request):
        player_scores = models.Score.objects.filter(owner=request.user.player, active=True)

        semesters = models.Semester.objects.filter(score__in=player_scores).all().distinct()

        response = []

        for semester in semesters:
            data = {"name": semester.name, "subjects": []}
            scores = player_scores.filter(semester=semester).order_by('subject__name')

            for score in scores:
                if len(data.get("subjects")) == 0 or data.get("subjects")[-1].get("pk") != score.subject.pk:
                    data["subjects"].append({"name": score.subject.name, "scores": [], "pk": score.subject.pk})
                data["subjects"][-1]["scores"].append(serializers.ScoreSerializer(score).data)
            response.append(data)

        return Response(response)


class ClaimScore(BaseView):
    def post(self, request):
        player = self.request.user.player

        score = models.Score.objects.filter(owner=player, pk=request.data.get('pk'))

        if score.exists():
            score.get().claim()
            return Response({})

        return HttpResponseForbidden()


class ShopItems(BaseView):
    def get(self, request):
        items = models.Item.objects.all().annotate(
            bought=Exists(models.ItemInstance.objects.filter(item=OuterRef('pk'), owner=request.user.player))
        )

        return Response(serializers.ItemSerializer(items, many=True).data)


class BuyShopItem(BaseView):
    def post(self, request):
        player = request.user.player
        item = models.Item.objects.get(pk=request.data.get('pk'))

        not_enough_money = item.price > player.gold
        has_item = models.ItemInstance.objects.filter(owner=player, item=item).exists()

        if has_item or not_enough_money:
            return HttpResponseForbidden()

        player.gold -= item.price
        player.save()
        models.ItemInstance.objects.create(item=item, owner=player)

        return Response({})
