# Narrative
# --------
# Creating nodes in sequence
#
# Extracted from stzdiagramtest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("SequenceDemo")
oDiag {
	SetLayout("TB")
	SetEdgeStyle(:Normal)

	AddNodeXTT("start", "Begin", [ :type = "start", :color = "success" ])
	AddNodeXTT("proc1", "Step 1", [ :type = "process", :color = "primary" ])
	AddNodeXTT("proc2", "Step 2", [ :type = "process", :color = "primary" ])
	AddNodeXTT("proc3", "Step 3", [ :type = "process", :color = "primary" ])
	AddNodeXTT("done", "Complete", [ :type = "endpoint", :color = "success" ])

	# Instead of using Connect(@nod1, @node2) for each eadge, we write:
	ConnectSequence([ "start", "proc1", "proc2", "proc3", "done" ])

	View()
}

pf()
# Executed in 0.56 second(s) in Ring 1.25
