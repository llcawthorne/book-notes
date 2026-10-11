from django.shortcuts import get_object_or_404, redirect, render

from cart.forms import CartAddProductForm

from .models import Category, Product
from .recommender import Recommender


def by_name(objects):
    # Translated fields can't go in Meta.ordering, so sort by the name shown in
    # the current language, which applies Parler's fallbacks.
    return sorted(
        objects,
        key=lambda obj: obj.safe_translation_getter(
            "name", default="", any_language=True
        ).casefold(),
    )


def product_list(request, category_slug=None):
    category = None
    categories = Category.objects.prefetch_related("translations")
    products = Product.objects.filter(available=True).prefetch_related("translations")
    if category_slug:
        # Category slugs are unique across all languages, so a slug from any
        # language finds the category. Redirect to the slug for the current
        # language (es-mx falls back to es), which also fixes language
        # switching, since set_language keeps the old slug in the URL.
        category = get_object_or_404(Category, translations__slug=category_slug)
        if category.slug != category_slug:
            return redirect(category, permanent=True)
        products = products.filter(category=category)
    return render(
        request,
        "shop/product/list.html",
        {
            "category": category,
            "categories": by_name(categories),
            "products": by_name(products),
        },
    )


def product_detail(request, id, slug):
    # Look up by id alone, then redirect any other slug to the current
    # language's one, for the same reasons as the category lookup above.
    product = get_object_or_404(Product, id=id, available=True)
    if product.slug != slug:
        return redirect(product, permanent=True)
    cart_product_form = CartAddProductForm()
    r = Recommender()
    recommended_products = r.suggest_products_for([product], 4)
    return render(
        request,
        "shop/product/detail.html",
        {
            "product": product,
            "cart_product_form": cart_product_form,
            "recommended_products": recommended_products,
        },
    )
