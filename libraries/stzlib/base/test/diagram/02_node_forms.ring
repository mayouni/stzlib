# Narrative
# --------
# Node forms
#
# Extracted from stzdiagramtest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("")
oDiag {

	# Rounded/Elliptical Shapes
	AddNodeXTT(:@Node1, "Circle", [:type = "circle", :color = "white"])
	AddNodeXTT(:@Node2, "Double Circle", [:type = "DoubleCircle", :color = "White" ])
	AddNodeXTT(:@Node3, "Ellpise", [:type = :Ellpise, :color = "White" ])
	AddNodeXTT(:@Node4, "Egg", [:type = :Egg, :color = :White])
	
	# Quadrilateral Shapes (4-sided/Box-like)
	AddNodeXTT(:@Node5, "Square", [:type = :Square, :color = :White])
	AddNodeXTT(:@Node6, "Rect", [:type = :Rect, :color = :White])
	AddNodeXTT(:@Node7, "Box", [:type = :Box, :color = :White])
	AddNodeXTT(:@Node8, "Parallelogram", [:type = :Parallelogram, :color = :White])
	AddNodeXTT(:@Node9, "Trapezium", [:type = :Trapezium, :color = :White])
	AddNodeXTT(:@Node10, "Inverted Trapezium", [:type = :InvTrapezium, :color = :White])
	AddNodeXTT(:@Node11, "Diamond", [:type = :Diamond, :color = :White])
	
	# Polygon Shapes (3 or more sides)
	AddNodeXTT(:@Node12, "Triangle", [:type = :Triangle, :color = :White])
	AddNodeXTT(:@Node13, "Inverted Triangle", [:type = :InvTriangle, :color = :White])
	AddNodeXTT(:@Node14, "Pentagon", [:type = :Pentagon, :color = :White])
	AddNodeXTT(:@Node15, "Hexagon", [:type = :Hexagon, :color = :White])
	AddNodeXTT(:@Node16, "Septagon", [:type = :Septagon, :color = :White])
	AddNodeXTT(:@Node17, "Octagon", [:type = :Octagon, :color = :White])
	AddNodeXTT(:@Node18, "Triple Octagon", [:type = :TripleOctagon, :color = :White])
	
	# Non-geometric/Conceptual Shapes
	AddNodeXTT(:@Node19, "Cylinder", [:type = :Cylinder, :color = :White])
	AddNodeXTT(:@Node20, "House", [:type = :House, :color = :White])
	AddNodeXTT(:@Node21, "Tab", [:type = :Tab, :color = :White])
	AddNodeXTT(:@Node22, "Folder", [:type = :Folder, :color = :White])
	AddNodeXTT(:@Node23, "Component", [:type = :Component, :color = :White])
	AddNodeXTT(:@Node24, "Note", [:type = :Note, :color = :Yellow])

	View()
}

pf()
