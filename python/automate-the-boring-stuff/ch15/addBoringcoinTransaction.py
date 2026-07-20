#!/usr/bin/env python

import sys, ezsheets

if len(sys.argv) < 4:
    print("Usage: python addBoringcoinTransaction.py sender recipient amount")
    sys.exit()

# Get the transaction infor frmo the command line arguments:
sender, recipient, amount = sys.argv[1:]

# We will get "The caller does not have permission" error when we try to change
# this URL since it isn't our Sheet
ss = ezsheets.Spreadsheet("https://autbor.com/boringcoin")
sheet = ss.sheets[0]

# Add one more row to the sheet for the new transaction
sheet.rowCount += 1

sheet[1, sheet.rowCount] = sender
sheet[2, sheet.rowCount] = recipient
sheet[3, sheet.rowCount] = amount
