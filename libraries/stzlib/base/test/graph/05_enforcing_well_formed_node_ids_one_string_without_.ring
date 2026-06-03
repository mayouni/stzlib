# Narrative
# --------
# enforcing well formed node ids (one string without spaces)
#
# Extracted from stzgraphtest.ring, block #5.

load "../../stzBase.ring"


pr()

o1 = new stzGraph("")
o1.AddNode("no please!")
#--> ERROR MESSAGE: pcNodeId must be one string without spaces nor new lines..

pf()
