from django import template
from django.utils.formats import number_format
from django.utils.translation import gettext as _

register = template.Library()


@register.filter
def usd(amount):
    # Everything is charged in US dollars, so outside English the format marks
    # it as US$ (Mexico's peso also uses "$"). Translators choose the order,
    # e.g. "60,00 US$" in Spain and Germany, "US$60.00" in Mexico and Japan.
    return _("$%(amount)s") % {"amount": number_format(amount, 2, force_grouping=True)}
