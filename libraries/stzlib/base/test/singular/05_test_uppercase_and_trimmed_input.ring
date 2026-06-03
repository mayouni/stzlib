# Narrative
# --------
# Test uppercase and trimmed input
#
# Extracted from stzsingulartest.ring, block #5.

load "../../stzBase.ring"


pr()

? Singular("CATS")       #--> cat
? Singular("  dogs  ")   #--> dog

pf()
# Executed in 0.20 second(s) in Ring 1.22
