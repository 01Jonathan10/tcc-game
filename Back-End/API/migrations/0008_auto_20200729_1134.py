# Generated by Django 3.0.8 on 2020-07-29 14:34

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('API', '0007_quest_map_id'),
    ]

    operations = [
        migrations.AddField(
            model_name='iteminstance',
            name='cosmetic',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='player',
            name='energy',
            field=models.IntegerField(default=0),
        ),
    ]
