# Narrative
# --------
# Edge style variations
#
# Extracted from stzdiagramtest.ring, block #33.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag2 = new stzDiagram("EdgeStyleTest")
oDiag2 {
	SetTheme(:Neutral)
	SetLayout(:TopDown)
	SetEdgeStyle(:Conditional)  # Semantic → dashed
	# SetEdgeStyle(:Dashed)     # Visual term

	SetEdgeColor("blue")
	
	AddNodeXTT("a", "Start", [ :type = "start", :color = "success" ])
	AddNodeXTT("b", "Check", [ :type = "decision", :color = "warning" ])
	AddNodeXTT("c", "End", [ :type = "endpoint", :color = "danger" ])
	
	Connect("a", "b")
	ConnectXT("b", "c", "Yes")
	
	View()
}

pf()
# Executed in 0.53 second(s) in Ring 1.25
