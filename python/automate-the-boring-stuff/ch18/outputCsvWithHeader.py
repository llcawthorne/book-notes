#!/usr/bin/env python
import csv

example_file = open("exampleWithHeader3.csv")
example_dict_reader = csv.DictReader(example_file)
for row in example_dict_reader:
    print(row["Timestamp"], row["Fruit"], row["Quantity"])
