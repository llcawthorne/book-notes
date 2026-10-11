from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("shop", "0003_copy_translations"),
    ]

    operations = [
        # Give the old columns a default first so rolling back can re-add them
        # to existing rows; 0003's backwards step then fills them in.
        migrations.AlterField(
            model_name="category",
            name="name",
            field=models.CharField(max_length=200, default=""),
        ),
        migrations.AlterField(
            model_name="category",
            name="slug",
            field=models.SlugField(max_length=200, unique=True, default=""),
        ),
        migrations.AlterField(
            model_name="product",
            name="name",
            field=models.CharField(max_length=200, default=""),
        ),
        migrations.AlterField(
            model_name="product",
            name="slug",
            field=models.SlugField(max_length=200, default=""),
        ),
        migrations.AlterField(
            model_name="product",
            name="description",
            field=models.TextField(blank=True, default=""),
        ),
        migrations.AlterModelOptions(
            name="category",
            options={"verbose_name": "category", "verbose_name_plural": "categories"},
        ),
        migrations.AlterModelOptions(
            name="product",
            options={},
        ),
        migrations.RemoveIndex(
            model_name="category",
            name="shop_catego_name_289c7e_idx",
        ),
        migrations.RemoveIndex(
            model_name="product",
            name="shop_produc_id_f21274_idx",
        ),
        migrations.RemoveIndex(
            model_name="product",
            name="shop_produc_name_a2070e_idx",
        ),
        migrations.RemoveField(
            model_name="category",
            name="name",
        ),
        migrations.RemoveField(
            model_name="category",
            name="slug",
        ),
        migrations.RemoveField(
            model_name="product",
            name="description",
        ),
        migrations.RemoveField(
            model_name="product",
            name="name",
        ),
        migrations.RemoveField(
            model_name="product",
            name="slug",
        ),
    ]
