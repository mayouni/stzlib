# Narrative
# --------
# Alternation with enhancement tracking
#
# Extracted from stzgraphextest.ring, block #19.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oTargetGraph = new stzGraph("Sample")
oTargetGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Process")
	AddNodeXT(:c, "End")
	AddEdgeXT(:a, :b, "flows")
	AddEdgeXT(:b, :c, "completes")
}

oGraphex = new stzGraphex("{@Node(Start) -> (@Edge(flows)|@Edge(completes)) -> @Node(End)}", oTargetGraph)
oGraphex.EnableDebug()
? "Cache before: " + @@(oGraphex.CacheStats())
? oGraphex.Match(oTargetGraph)
? "Cache after: " + @@(oGraphex.CacheStats())

pf()
