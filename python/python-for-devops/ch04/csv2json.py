#!/usr/bin/env python
import csv
import json

print(json.dumps(list(csv.reader(open("addresses.csv")))))
