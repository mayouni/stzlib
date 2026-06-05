# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #18.

load "../../stzBase.ring"

pr()

? Q(1:7) - These(3:5) # Or AllThese() or EachIn()
#--> [ 1, 2, 6, 7 ]

? Q(1:7) - These(3:5)
#--> [ 1, 2, 6, 7 ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
