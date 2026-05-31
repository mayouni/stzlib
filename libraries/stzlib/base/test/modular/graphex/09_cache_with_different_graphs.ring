# Narrative
# --------
# Cache with different graphs
#
# Extracted from stzgraphextest.ring, block #9.

load "../../../stzBase.ring"


pr()

oGraph1 = new stzGraph("G1")
oGraph1.AddNodeXT(:a, "Start")

oGraph2 = new stzGraph("G2")
oGraph2.AddNodeXT(:a, "Start")
oGraph2.AddNodeXT(:b, "End")

oGx = new stzGraphex("{@Node(Start)}", oGraph1)

? oGx.Match(oGraph1)  # Cached
? oGx.Match(oGraph2)  # Different graph signature
? "Cache entries: " + @@(oGx.CacheStats())

pf()

#============================#
#  ENHANCEMENT 4: PROPERTY CONSTRAINTS TESTS
#============================#
