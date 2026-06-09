# Narrative
# --------
# Combined options
#
# Extracted from stzdiagramtest.ring, block #37.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("CompleteTest")
oDiag {
	SetLayout("TB")              # Short form of TopBottom

	SetPenWidth(2)
	SetEdgeColor("gray+")
	
	SetEdgeStyle(:ErrorFlow)
	SetEdgePenWidth(2)

	AddNodeXTT("start", "Begin", [ :type = "start", :color = "success" ])
	AddNodeXTT("proc1", "Validate", [ :type = "process", :color = "primary" ])
	AddNodeXTT("dec1", "Valid?", [ :type = "decision", :color = "warning" ])
	AddNodeXTT("error", "Error", [ :type = "error", :color = "danger" ])
	AddNodeXTT("done", "Complete", [ :type = "endpoint", :color = "success" ])
	
	Connect("start", "proc1")
	ConnectXT("proc1", "dec1", "Check")
	ConnectXT("dec1", "error", "No")
	ConnectXT("dec1", "done", "Yes")
	
	? NodeCount() #--> 5
	? EdgeCount() #--> 4
	
	? Code()
	View()
}

pf()
# Executed in 0.59 second(s) in Ring 1.25
