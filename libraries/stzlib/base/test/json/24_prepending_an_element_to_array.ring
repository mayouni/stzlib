# Narrative
# --------
# Prepending an Element to Array
#
# Extracted from stzjsontest.ring, block #24.

load "../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')
oJson.Prepend(0)

? oJson.ToString()
#--> [0,1,2,3]

pf()
# Executed in 0.04 second(s) in Ring 1.22
