# Narrative
# --------
# Replacing an Element in Array
#
# Extracted from stzjsontest.ring, block #29.

load "../../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')
oJson.Replace(2, 2.5)

? oJson.ToString()
#--> [1,2.5,3]

pf()
# Executed in 0.04 second(s) in Ring 1.22
