# Narrative
# --------
# Cache performance test
#
# Extracted from stzgraphextest.ring, block #7.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

# Create large graph
oGraph = new stzGraph("Large")
for i = 1 to 100
	cId = ":n" + i
	oGraph.AddNodeXT(cId, "Node" + i)
	if i > 1
		oGraph.AddEdgeXT(":n" + (i-1), cId, "next")
	ok
next

oGx = new stzGraphex("{@Node(Node1) -> @Edge(next) -> @Node(Node2)}", oGraph)

? "=== First Match (no cache) ==="
t1 = clock()
bResult1 = oGx.Match(oGraph)
t2 = clock()
? "Result: " + bResult1
? "Time: " + (t2 - t1)

? "=== Second Match (cached) ==="
t3 = clock()
bResult2 = oGx.Match(oGraph)
t4 = clock()
? "Result: " + bResult2
? "Time: " + (t4 - t3)
? "Speedup: " + ((t2-t1)/(t4-t3))

pf()
