# Narrative
# --------
# Basic Initialization from JSON Array
#
# Extracted from stzjsontest.ring, block #18.

load "../../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.ToList()
#--> [1, 2, 3]

pf()
# Executed in 0.03 second(s) in Ring 1.22
