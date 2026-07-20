#!/usr/bin/env python

import csv, os

os.makedirs("headerRemoved", exist_ok=True)

# Loop through every file in the current working directory.
for csv_filename in os.listdir("."):
    if not csv_filename.endswith(".csv"):
        continue
    print("Removing header from " + csv_filename + "...")

    # Read the CSV file (skipping the first row)
    csv_rows = []
    csv_file_obj = open(csv_filename)
    reader_obj = csv.reader(csv_file_obj)
    for row in reader_obj:
        if reader_obj.line_num == 1:
            continue  # Skip the first row.
        csv_rows.append(row)
    csv_file_obj.close()

    # Write the CSV file.
    csv_file_obj = open(os.path.join("headerRemoved", csv_filename), "w", newline="")
    csv_writer = csv.writer(csv_file_obj)
    for row in csv_rows:
        csv_writer.writerow(row)
    csv_file_obj.close()
