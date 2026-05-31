# Narrative
# --------
# Removing an Element by Index
#
# Extracted from stzjsontest.ring, block #26.

load "../../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')
oJson.RemoveAt(2)

? oJson.ToString()
#--> [1,3]

pf()
# Executed in 0.03 second(s) in Ring 1.22
