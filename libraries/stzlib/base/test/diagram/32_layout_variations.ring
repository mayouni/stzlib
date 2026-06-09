# Narrative
# --------
# Layout variations
#
# Extracted from stzdiagramtest.ring, block #32.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag1 = new stzDiagram("LayoutTest")
oDiag1 {
	SetTheme(:gray) # Or :Print or :Gray :LightGray or :DarkGray or :Access
	SetLayout(:LeftRight)      # Semantic
	# SetLayout(:LR)           # Short form
	
	AddNodeXTT("n1", "Node 1", [ :type = "start", :color = "success" ])
	AddNodeXTT("n2", "Node 2", [ :type = "process", :color = "primary" ])
	AddNodeXTT("n3", "Node 3", [ :type = "endpoint", :color = "danger" ])
	
	Connect("n1", "n2")
	Connect("n2", "n3")
	
	? Dot()
	View()
}
#-->
'
digraph "layouttest" {
    graph [rankdir=LR, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=0.60, ranksep=0.80, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#000000", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    n1 [label="Node_1", shape=ellipse, style="solid,filled", fillcolor="#7F7F7F", fontcolor="white"]
    n2 [label="Node_2", shape=box, style="rounded,solid,filled", fillcolor="#646464", fontcolor="white"]
    n3 [label="Node_3", shape=doublecircle, style="solid,filled", fillcolor="#D0D0D0", fontcolor="black"]

    n1 -> n2
    n2 -> n3

}
'

pf()
# Executed in 0.48 second(s) in Ring 1.25
