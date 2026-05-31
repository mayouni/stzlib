# Narrative
# --------
# Accessing Element by Index
#
# Extracted from stzjsontest.ring, block #20.

load "../../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.At(2)
#--> 2

pf()
# Executed in 0.02 second(s) in Ring 1.22
