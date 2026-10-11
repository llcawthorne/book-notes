from django.db import migrations


def forwards(apps, schema_editor):
    # Copy the existing English values into Parler's translation tables
    # before 0004 drops the old columns.
    Category = apps.get_model("shop", "Category")
    CategoryTranslation = apps.get_model("shop", "CategoryTranslation")
    Product = apps.get_model("shop", "Product")
    ProductTranslation = apps.get_model("shop", "ProductTranslation")

    for category in Category.objects.all():
        CategoryTranslation.objects.create(
            master_id=category.pk,
            language_code="en",
            name=category.name,
            slug=category.slug,
        )
    for product in Product.objects.all():
        ProductTranslation.objects.create(
            master_id=product.pk,
            language_code="en",
            name=product.name,
            slug=product.slug,
            description=product.description,
        )


def backwards(apps, schema_editor):
    Category = apps.get_model("shop", "Category")
    CategoryTranslation = apps.get_model("shop", "CategoryTranslation")
    Product = apps.get_model("shop", "Product")
    ProductTranslation = apps.get_model("shop", "ProductTranslation")

    for t in CategoryTranslation.objects.filter(language_code="en"):
        Category.objects.filter(pk=t.master_id).update(name=t.name, slug=t.slug)
    for t in ProductTranslation.objects.filter(language_code="en"):
        Product.objects.filter(pk=t.master_id).update(
            name=t.name, slug=t.slug, description=t.description
        )


class Migration(migrations.Migration):

    dependencies = [
        ("shop", "0002_translations"),
    ]

    operations = [
        migrations.RunPython(forwards, backwards),
    ]
