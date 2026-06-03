# Narrative
# --------
# Getting Last Element
#
# Extracted from stzjsontest.ring, block #22.

load "../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.Last()
#--> 3

pf()
# Executed in 0.02 second(s) in Ring 1.22
