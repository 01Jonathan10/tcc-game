# Generated by Django 3.0.8 on 2020-08-11 13:18

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('API', '0027_auto_20200811_1133'),
    ]

    operations = [
        migrations.AddField(
            model_name='taskinstance',
            name='disabled',
            field=models.BooleanField(default=False),
        ),
    ]
