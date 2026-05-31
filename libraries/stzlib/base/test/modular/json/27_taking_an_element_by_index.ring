# Narrative
# --------
# Taking an Element by Index
#
# Extracted from stzjsontest.ring, block #27.

load "../../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')
vValue = oJson.TakeAt(2)

? vValue
#--> 2

? oJson.ToString()
#--> [1,3]

pf()
# Executed in 0.04 second(s) in Ring 1.22
