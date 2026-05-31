# Narrative
# --------
# Inserting an Element at Position
#
# Extracted from stzjsontest.ring, block #25.

load "../../../stzBase.ring"


pr()

oJson = new stzJson('[1, 2, 3]')
oJson.Insert(2, 1.5)

? oJson.ToString()
#--> [1,1.5,2,3]

pf()
# Executed in 0.04 second(s) in Ring 1.22
