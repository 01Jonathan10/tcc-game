# Generated by Django 3.0.8 on 2020-07-28 16:03

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('API', '0002_auto_20200725_1426'),
    ]

    operations = [
        migrations.CreateModel(
            name='Quest',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('number', models.IntegerField()),
                ('name', models.CharField(max_length=100)),
                ('difficulty', models.IntegerField(choices=[(1, 'Easy'), (2, 'Medium'), (3, 'Hard')], default=1)),
            ],
            options={
                'unique_together': {('id', 'difficulty')},
            },
        ),
        migrations.AddField(
            model_name='item',
            name='type',
            field=models.IntegerField(choices=[(1, 'Weapon'), (2, 'Head'), (3, 'Armor'), (4, 'Accessory')], default=1),
        ),
        migrations.AddField(
            model_name='iteminstance',
            name='equipped',
            field=models.BooleanField(default=False),
        ),
        migrations.CreateModel(
            name='QuestInstance',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('quest', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='API.Quest')),
            ],
        ),
    ]
