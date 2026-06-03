# Narrative
# --------
# Adding an Element to Array
#
# Extracted from stzjsontest.ring, block #23.

load "../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')
oJson.Add(4)

? oJson.ToString()
#--> [1,2,3,4]

pf()
# Executed in 0.04 second(s) in Ring 1.22
