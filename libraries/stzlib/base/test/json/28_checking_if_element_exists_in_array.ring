# Narrative
# --------
# Checking if Element Exists in Array
#
# Extracted from stzjsontest.ring, block #28.

load "../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.Contains(2)
#--> TRUE

? oJson.Contains(4)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.22
