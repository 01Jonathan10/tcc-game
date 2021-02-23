import datetime
from dateutil.relativedelta import *
from django.db.models import Q

from .models import Item, ItemInstance, Task, TaskInstance
from .constants import ItemType


class PlayerController:
    @staticmethod
    def gain_starting_items(player):
        items = Item.objects.filter(name__startswith=player.job.name + "'")
        items = items.filter(Q(name__endswith=player.gender + ')') | Q(type=1))
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

        i_i.equipped = True
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

        i_i.cosmetic = True
        i_i.save()

    @staticmethod
    def unequip_cosmetic(player, category):
        prev = ItemInstance.objects.filter(item__type=category, owner=player, cosmetic=True)

        if prev.exists():
            prev.update(cosmetic=False)

    @staticmethod
    def update_player(player):
        PlayerController.update_player_energy(player)

        tasks_past_deadline = TaskInstance.objects.filter(task__owner=player, finished__isnull=True,
                                                          deadline__lt=datetime.datetime.now())
        TaskController.update_deadlines(tasks_past_deadline.all())

        now = datetime.datetime.now()
        now = datetime.datetime(now.year, now.month, now.day, now.hour, now.minute)
        player.last_update = now
        player.save()

    @staticmethod
    def update_player_energy(player):
        delta = datetime.datetime.now() - player.last_update
        min_passed = int(delta.seconds / 60)
        if min_passed >= 1:
            player.energy = min(player.energy + min_passed, 100)


class TaskController:

    @staticmethod
    def update_deadlines(tasks):
        for taskinstance in tasks:
            while taskinstance.deadline < datetime.datetime.now():
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
