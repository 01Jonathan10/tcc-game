# Generated by Django 3.0.8 on 2020-07-31 15:39

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('API', '0009_player_stats'),
    ]

    operations = [
        migrations.CreateModel(
            name='Skill',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=20)),
                ('power', models.IntegerField()),
                ('dmg_type', models.IntegerField(choices=[(1, 'Physical'), (2, 'Magical'), (3, 'True')])),
                ('effect', models.TextField(max_length=200)),
                ('range', models.CharField(max_length=30)),
                ('anim_id', models.IntegerField(choices=[(1, 'Attack'), (2, 'Cast')])),
            ],
        ),
    ]
