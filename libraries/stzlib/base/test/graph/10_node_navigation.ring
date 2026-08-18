# Narrative
# --------
# Node Navigation
#
# Extracted from stzgraphtest.ring, block #10.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("NavTest")
oGraph {
	AddNode("first")
	AddNode("second")
	AddNode("third")
	
	# AddNode(id) uses the id AS the label, and AddNodeXTT lowercases the
	# id -- so these are "first", not "First". The capitals were written
	# by hand. AddNodeXT(id, label) is the door for a label of your own.
	? FirstNode()["label"]   #--> first
	? LastNode()["label"]    #--> third
	? NodeAt(2)["label"]     #--> second
	? NodePosition("second") #--> 2
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
