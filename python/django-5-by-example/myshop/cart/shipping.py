import math
from decimal import Decimal

# The base rate covers the first BASE_WEIGHT grams, and each further STEP_WEIGHT
# grams (or part of it) adds STEP_RATE. Set STEP_RATE to 0 for flat-rate
# shipping.
BASE_RATE = Decimal("4.00")
BASE_WEIGHT = 500
STEP_RATE = Decimal("1.00")
STEP_WEIGHT = 500


def shipping_cost(weight):
    steps = math.ceil(max(0, weight - BASE_WEIGHT) / STEP_WEIGHT)
    return BASE_RATE + STEP_RATE * steps
