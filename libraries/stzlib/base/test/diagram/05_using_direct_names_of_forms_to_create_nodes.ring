# Narrative
# --------
# Using direct names of forms to create nodes
#
# Extracted from stzdiagramtest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("")
oDiag {
	# Rounded/Elliptical Shapes
	AddCircleXT(:@Node1, "Circle")
	AddDoubleCircleXT(:@Node2, "Double Circle")
	AddEllipseXT(:@Node3, "Ellipse")
	AddEggXT(:@Node4, "Egg")
	
	# Quadrilateral Shapes
	AddSquareXT(:@Node5, "Square")
	AddRectXT(:@Node6, "Rect")
	AddBoxXT(:@Node7, "Box")
	AddParallelogramXT(:@Node8, "Parallelogram")
	AddTrapeziumXT(:@Node9, "Trapezium")
	AddInvTrapeziumXT(:@Node10, "Inverted Trapezium")
	AddDiamondXT(:@Node11, "Diamond")
	
	# Polygon Shapes
	AddTriangleXT(:@Node12, "Triangle")
	AddInvTriangleXT(:@Node13, "Inverted Triangle")
	AddPentagonXT(:@Node14, "Pentagon")
	AddHexagonXT(:@Node15, "Hexagon")
	AddSeptagonXT(:@Node16, "Septagon")
	AddOctagonXT(:@Node17, "Octagon")
	AddTripleOctagonXT(:@Node18, "Triple Octagon")
	
	# Non-geometric/Conceptual Shapes
	AddCylinderXT(:@Node19, "Cylinder")
	AddHouseXT(:@Node20, "House")
	AddTabXT(:@Node21, "Tab")
	AddFolderXT(:@Node22, "Folder")
	AddComponentXT(:@Node23, "Component")
	AddNoteXTT(:@Node24, "Note", [ :type = "yellow" ])

	View()
}

pf()
