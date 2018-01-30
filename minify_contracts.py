#!python3

import json
import sys

assert len(sys.argv) >= 3, "Must have input file and at least one contract"
filename = sys.argv[1]
keepers = [f+':'+f.split('/')[-1].split('.')[0] for f in sys.argv[2:]]

with open(filename, 'r') as f:
    contracts = json.loads(f.read())

filtered_contracts = {}
for c, artifacts in contracts['contracts'].items():
    if c in keepers:
        filtered_contracts[c] = artifacts

contracts['contracts'] = filtered_contracts

print(json.dumps(contracts, indent=2))
