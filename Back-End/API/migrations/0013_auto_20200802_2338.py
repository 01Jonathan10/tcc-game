# Generated by Django 3.0.8 on 2020-08-03 02:38

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('API', '0012_remove_skill_dmg_type'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='skill',
            name='power',
        ),
        migrations.AddField(
            model_name='item',
            name='wpn_type',
            field=models.IntegerField(choices=[(1, 'Weapon'), (2, 'Head'), (3, 'Armor'), (4, 'Accessory')], default=0),
        ),
    ]
