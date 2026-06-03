# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #24.

load "../../stzBase.ring"


? Intersection([ "A":"C", "A":"C", "A":"C" ])
#--> [ "A", "B", "C" ]

? Intersection([ "A":"C", "A":"B", "A":"C" ])
#--> [ "A", "B" ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
