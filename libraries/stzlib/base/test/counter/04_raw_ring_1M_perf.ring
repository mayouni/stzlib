# Narrative
# --------
# Performance baseline: cycle 1..4 a million times using raw Ring loops
# (no Softanza). Establishes the floor cost against which the Softanza
# stzCounter implementation in block 05 is measured.

load "../../stzBase.ring"

pr()

anResults = []
for i = 1 to 1000000
    nValue = ((i-1) % 4) + 1  # Cycle 1-4
    anResults + nValue
next

pf()
# Reference timing:
# - 0.20s in Ring 1.23
