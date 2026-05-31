# Narrative
# --------
# Getting First Element
#
# Extracted from stzjsontest.ring, block #21.

load "../../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')

? oJson.First()
#--> 1

pf()
# Executed in 0.02 second(s) in Ring 1.22
