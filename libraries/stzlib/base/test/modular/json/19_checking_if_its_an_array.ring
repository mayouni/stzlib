# Narrative
# --------
# Checking if it's an Array
#
# Extracted from stzjsontest.ring, block #19.

load "../../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.IsArray()
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.22
