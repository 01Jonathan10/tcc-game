# Generated by Django 3.0.8 on 2020-08-12 19:42

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('API', '0029_auto_20200812_1940'),
    ]

    operations = [
        migrations.AlterField(
            model_name='taskinstance',
            name='finished',
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
