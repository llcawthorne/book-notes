from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models
from django.utils import timezone


class CouponQuerySet(models.QuerySet):
    def valid(self):
        now = timezone.now()
        return self.filter(active=True, valid_from__lte=now, valid_to__gte=now)


class Coupon(models.Model):
    code = models.CharField(max_length=50, unique=True)
    valid_from = models.DateTimeField()
    valid_to = models.DateTimeField()
    discount = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text="Percentage value (0 to 100)",
    )
    active = models.BooleanField()

    objects = CouponQuerySet.as_manager()

    def __str__(self):
        return self.code
