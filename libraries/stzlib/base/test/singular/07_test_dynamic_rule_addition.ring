# Narrative
# --------
# Test dynamic rule addition
#
# Extracted from stzsingulartest.ring, block #7.

load "../../stzBase.ring"


pr()

? Singular("cacti")      #--> cacti  (before rule addition)
AddSingularRule("^cacti$", "cactus", "exact", 1, "custom")
? Singular("cacti")      #--> cactus (after rule addition)
pf()

# Executed in 0.16 second(s) in Ring 1.22
