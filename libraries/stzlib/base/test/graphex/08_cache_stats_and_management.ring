# Narrative
# --------
# Cache stats and management
#
# Extracted from stzgraphextest.ring, block #8.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Test")
oGraph.AddNodeXT(:a, "A")

oGx = new stzGraphex("{@Node(A)}", oGraph)

? "Initial cache: " + @@(oGx.CacheStats())
? oGx.Match(oGraph)
? "After match: " + @@(oGx.CacheStats())

oGx.ClearCache()
? "After clear: " + @@(oGx.CacheStats())

oGx.SetCacheSize(50)
? "New max size: " + @@(oGx.CacheStats())

pf()
