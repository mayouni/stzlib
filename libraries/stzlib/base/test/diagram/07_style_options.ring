# Narrative
# --------
# Style options
#
# Extracted from stzdiagramtest.ring, block #7.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("StyleTest")
oDiag {
	SetTheme(:pro)
	SetLayout(:TopDown)
	# Node styling
	SetNodePenWidth(2)
	SetNodePenStyle("bold+dashed")  # or "bold,dashed"
	
	# Edge styling
	SetEdgePenWidth(3)
	SetEdgePenStyle("dotted")
	SetArrowHead("vee")
	SetArrowTail("diamond")
	SetEdgeColor("red")
	
	AddNodeXTT("a", "Start", [ :type = "start", :color = "success" ])
	AddNodeXTT("b", "End", [ :type = "endpoint", :color = "danger" ])
	Connect("a", "b")
	
	View()
	? code()
}

pf()
