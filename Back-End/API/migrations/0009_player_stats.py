# Generated by Django 3.0.8 on 2020-07-30 03:08

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('API', '0008_auto_20200729_1134'),
    ]

    operations = [
        migrations.AddField(
            model_name='player',
            name='stats',
            field=models.CharField(default='', max_length=200),
            preserve_default=False,
        ),
    ]
