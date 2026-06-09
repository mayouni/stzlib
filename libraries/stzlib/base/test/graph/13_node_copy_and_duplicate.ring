# Narrative
# --------
# Node Copy and Duplicate
#
# Extracted from stzgraphtest.ring, block #13.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("CopyTest")
oGraph {
	AddNodeXTT("template", "Template", [:color = "blue"])
	AddNodeXT("next", "Next")
	Connect("template", "next")
	
	DuplicateNode("template", "copy1")
	? Node("copy1")["properties"]["color"]
	#--> "blue"
	
	DuplicateNodeWithEdges("template", "copy2")
	? EdgeExists("copy2", "next")
	#--> TRUE
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
