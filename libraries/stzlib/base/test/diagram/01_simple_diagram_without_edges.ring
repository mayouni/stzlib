# Narrative
# --------
# Simple diagram without edges
#
# Extracted from stzdiagramtest.ring, block #1.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("")
oDiag {

	AddNodeXTT(:@Node1, "Circle", [:type = "circle", :color = "white"])
	AddNodeXTT(:@Node2, "Double Circle", [:type = "DoubleCircle", :color = "White" ])
	AddNodeXTT(:@Node3, "Ellipse", [:type = "Ellipse", :color = "White" ])
	AddNodeXTT(:@Node4, "Egg", [:type = "Egg", :color = "White"])

	? code()
	View()
}

pf()
# Executed in 0.50 second(s) in Ring 1.24
