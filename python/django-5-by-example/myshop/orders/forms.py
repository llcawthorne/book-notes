from django import forms
from django.utils.text import capfirst
from django.utils.translation import gettext_lazy as _
from localflavor.us.forms import USZipCodeField

from .models import Order


class OrderCreateForm(forms.ModelForm):
    # A field declared on the form doesn't inherit the model field's
    # verbose_name, so reuse the translated "postal code" label.
    postal_code = USZipCodeField(label=capfirst(_("postal code")))

    class Meta:
        model = Order
        fields = ["first_name", "last_name", "email", "address", "postal_code", "city"]
