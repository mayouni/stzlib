# Narrative
# --------
# Test @NodeCount vs @Node
#
# Extracted from stzgraphextest.ring, block #3.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("Count")
oGraph {
	AddNodeXT(:a, "A")
	AddNodeXT(:b, "B")
	AddNodeXT(:c, "C")
}

oGx = new stzGraphex("{@NodeCount}", oGraph)
? oGx.Match(oGraph)
#--> Should parse as "nodecount"

pf()

#============================#
#  ENHANCEMENT 2: CASE SENSITIVITY TESTS
#============================#
