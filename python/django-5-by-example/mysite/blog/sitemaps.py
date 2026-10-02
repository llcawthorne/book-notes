from django.contrib.sitemaps import Sitemap
from django.db.models import Max
from django.urls import reverse
from taggit.models import Tag

from .models import Post


class PostSitemap(Sitemap):
    changefreq = "weekly"
    priority = 0.9

    def items(self):
        return Post.published.all()

    def lastmod(self, obj):
        return obj.updated


class TagSitemap(Sitemap):
    changefreq = "weekly"
    priority = 0.5

    def items(self):
        return Tag.objects.filter(pk__in=Post.published.values("tags")).order_by("slug")

    def location(self, tag):
        return reverse("blog:post_list_by_tag", args=[tag.slug])

    def lastmod(self, tag):
        return Post.published.filter(tags=tag).aggregate(Max("updated"))["updated__max"]
