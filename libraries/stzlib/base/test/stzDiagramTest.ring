load "../stzbase.ring"

#--------------------------------------------------#
#  TESTING COLOR SEMANTIC DESIGN & INFRASTRUCTURE  #
#--------------------------------------------------#

/*--- Base Colors

pr()

? ResolveColor(:red)      #--> #FF0000
? ResolveColor(:blue)     #--> #0000FF
? ResolveColor(:green)    #--> #008000
? ResolveColor(:yellow)   #--> #FFFF00
? ResolveColor(:white)    #--> #FFFFFF
? ResolveColor(:black)    #--> #000000
? ResolveColor(:gray)     #--> #808080

pf()

/*--- Base colors Intensities

pr()

# Grayscale
? "--- GRAYSCALE ---"
? "white--  : " + ResolveColor("white--")
? "white-   : " + ResolveColor("white-")
? "white    : " + ResolveColor("white")
? "white+   : " + ResolveColor("white+")
? "white++  : " + ResolveColor("white++")
? ""

? "black--  : " + ResolveColor("black--")
? "black-   : " + ResolveColor("black-")
? "black    : " + ResolveColor("black")
? "black+   : " + ResolveColor("black+")
? "black++  : " + ResolveColor("black++")
? ""

? "gray--   : " + ResolveColor("gray--")
? "gray-    : " + ResolveColor("gray-")
? "gray     : " + ResolveColor("gray")
? "gray+    : " + ResolveColor("gray+")
? "gray++   : " + ResolveColor("gray++")
? NL

# Primary Colors
? "--- PRIMARY COLORS ---"
? "red--    : " + ResolveColor("red--")
? "red-     : " + ResolveColor("red-")
? "red      : " + ResolveColor("red")
? "red+     : " + ResolveColor("red+")
? "red++    : " + ResolveColor("red++")
? ""

? "green--  : " + ResolveColor("green--")
? "green-   : " + ResolveColor("green-")
? "green    : " + ResolveColor("green")
? "green+   : " + ResolveColor("green+")
? "green++  : " + ResolveColor("green++")
? ""

? "blue--   : " + ResolveColor("blue--")
? "blue-    : " + ResolveColor("blue-")
? "blue     : " + ResolveColor("blue")
? "blue+    : " + ResolveColor("blue+")
? "blue++   : " + ResolveColor("blue++")
? ""

? "yellow-- : " + ResolveColor("yellow--")
? "yellow-  : " + ResolveColor("yellow-")
? "yellow   : " + ResolveColor("yellow")
? "yellow+  : " + ResolveColor("yellow+")
? "yellow++ : " + ResolveColor("yellow++")
? NL

# Secondary Colors
? "--- SECONDARY COLORS ---"
? "orange-- : " + ResolveColor("orange--")
? "orange-  : " + ResolveColor("orange-")
? "orange   : " + ResolveColor("orange")
? "orange+  : " + ResolveColor("orange+")
? "orange++ : " + ResolveColor("orange++")
? ""

? "purple-- : " + ResolveColor("purple--")
? "purple-  : " + ResolveColor("purple-")
? "purple   : " + ResolveColor("purple")
? "purple+  : " + ResolveColor("purple+")
? "purple++ : " + ResolveColor("purple++")
? ""

? "cyan--   : " + ResolveColor("cyan--")
? "cyan-    : " + ResolveColor("cyan-")
? "cyan     : " + ResolveColor("cyan")
? "cyan+    : " + ResolveColor("cyan+")
? "cyan++   : " + ResolveColor("cyan++")
? ""

? "magenta--: " + ResolveColor("magenta--")
? "magenta- : " + ResolveColor("magenta-")
? "magenta  : " + ResolveColor("magenta")
? "magenta+ : " + ResolveColor("magenta+")
? "magenta++: " + ResolveColor("magenta++")
? NL

# Extended Palette
? "--- EXTENDED PALETTE ---"
? "brown--  : " + ResolveColor("brown--")
? "brown-   : " + ResolveColor("brown-")
? "brown    : " + ResolveColor("brown")
? "brown+   : " + ResolveColor("brown+")
? "brown++  : " + ResolveColor("brown++")
? ""

? "pink--   : " + ResolveColor("pink--")
? "pink-    : " + ResolveColor("pink-")
? "pink     : " + ResolveColor("pink")
? "pink+    : " + ResolveColor("pink+")
? "pink++   : " + ResolveColor("pink++")
? ""

? "coral--  : " + ResolveColor("coral--")
? "coral-   : " + ResolveColor("coral-")
? "coral    : " + ResolveColor("coral")
? "coral+   : " + ResolveColor("coral+")
? "coral++  : " + ResolveColor("coral++")
? ""

? "teal--   : " + ResolveColor("teal--")
? "teal-    : " + ResolveColor("teal-")
? "teal     : " + ResolveColor("teal")
? "teal+    : " + ResolveColor("teal+")
? "teal++   : " + ResolveColor("teal++")
? ""

? "lavender--: " + ResolveColor("lavender--")
? "lavender- : " + ResolveColor("lavender-")
? "lavender  : " + ResolveColor("lavender")
? "lavender+ : " + ResolveColor("lavender+")
? "lavender++: " + ResolveColor("lavender++")

#-->
'
--- GRAYSCALE ---
white--  : #FFFFFF
white-   : #FFFFFF
white    : #FFFFFF
white+   : #333333
white++  : #0C0C0C

black--  : #E0E0E0
black-   : #A3A3A3
black    : #000000
black+   : #000000
black++  : #000000

gray--   : #EFEFEF
gray-    : #D1D1D1
gray     : #808080
gray+    : #656565
gray++   : #333333


--- PRIMARY COLORS ---
red--    : #FFE0E0
red-     : #FFA3A3
red      : #FF0000
red+     : #C94D4D
red++    : #660000

green--  : #E0EFE0
green-   : #A3D1A3
green    : #008000
green+   : #4D654D
green++  : #003300

blue--   : #E0E0FF
blue-    : #A3A3FF
blue     : #0000FF
blue+    : #4D4DC9
blue++   : #000066

yellow-- : #FFFFE0
yellow-  : #FFFFA3
yellow   : #FFFF00
yellow+  : #333300
yellow++ : #0C0C00


--- SECONDARY COLORS ---
orange-- : #FFF4E0
orange-  : #FFDEA3
orange   : #FFA500
orange+  : #332100
orange++ : #0C0800

purple-- : #EFE0EF
purple-  : #D1A3D1
purple   : #800080
purple+  : #654D65
purple++ : #330033

cyan--   : #E0FFFF
cyan-    : #A3FFFF
cyan     : #00FFFF
cyan+    : #003333
cyan++   : #000C0C

magenta--: #FFE0FF
magenta- : #FFA3FF
magenta  : #FF00FF
magenta+ : #C94DC9
magenta++: #660066


--- EXTENDED PALETTE ---
brown--  : #F4E5E5
brown-   : #DEB2B2
brown    : #A52A2A
brown+   : #822121
brown++  : #421010

pink--   : #FFF7F8
pink-    : #FFE8EC
pink     : #FFC0CB
pink+    : #332628
pink++   : #0C090A

coral--  : #FFEFEA
coral-   : #FFD0C0
coral    : #FF7F50
coral+   : #331910
coral++  : #0C0604

teal--   : #E0EFEF
teal-    : #A3D1D1
teal     : #008080
teal+    : #4D6565
teal++   : #003333

lavender--: #FCFCFE
lavender- : #F6F6FD
lavender  : #E6E6FA
lavender+ : #2E2E32
lavender++: #0B0B0C
'

pf()


/*--- Semantic Colors
? ResolveColor(:Success)  # Should resolve to green
? ResolveColor(:Warning)  # Should resolve to yellow
? ResolveColor(:Danger)   # Should resolve to red
? ResolveColor(:Info)     # Should resolve to blue
? ResolveColor(:Primary)  # Should resolve to blue
? ResolveColor(:Neutral)  # Should resolve to gray


/*--- Node Type Colors
? ColorForNodeType(:Start)        # Should be green
? ColorForNodeType(:Process)      # Should be blue
? ColorForNodeType(:Decision)     # Should be yellow
? ColorForNodeType(:Endpoint)     # Should be coral
? ColorForNodeType(:State)        # Should be cyan
? ColorForNodeType(:Storage)      # Should be gray
? ColorForNodeType(:Data)         # Should be lavender


/*--- Direct Hex Colors
? ResolveColor("#FF5733")  # Should return: #FF5733
? ResolveColor("#00AAFF")  # Should return: #00AAFF
? ResolveColor("#123456")  # Should return: #123456


/*--- Extended Palette
? ResolveColor(:brown)     # #A52A2A
? ResolveColor(:pink)      # #FFC0CB
? ResolveColor(:navy)      # #000080
? ResolveColor(:teal)      # #008080
? ResolveColor(:coral)     # #FF7F50
? ResolveColor(:salmon)    # #FA8072
? ResolveColor(:lavender)  # #E6E6FA
? ResolveColor(:steelblue) # #4682B4


/*--- Full Intensity Chain: Coral
? ResolveColor("coral--")
? ResolveColor("coral-")
? ResolveColor("coral")
? ResolveColor("coral+")
? ResolveColor("coral++")

/*--- Full Intensity Chain: Teal
? ResolveColor("teal--")
? ResolveColor("teal-")
? ResolveColor("teal")
? ResolveColor("teal+")
? ResolveColor("teal++")


/*--- Legacy Color Names

pr()

? ResolveColor(:lightblue)   # Should map to blue+ 	#--> #4D4DC9
? ResolveColor(:lightgreen)  # Should map to green+	#--> #4D654D
? ResolveColor(:lightyellow) # Should map to yellow+	#--> #333300
? ResolveColor(:darkgreen)   # Should map to green-	#--> #A3D1A3
? ResolveColor(:darkblue)    # Should map to blue-	#--> #A3A3FF
? ResolveColor(:darkred)     # Should map to red-	#--> #FFA3A3

pf()

/*--- Full Palette Count

pr()

aPalette = BuildColorPalette()
? len(aPalette) #--> 125
#--> 24 base + (24 × 4 intensities) = 120

pf()

/*---

pr()

# Softanza enhances DOT/Graphviz in several ways:
# 1. Forces layout respect: Graphviz ignores rankdir for disconnected nodes.
#    Softanza adds invisible edges to enforce TopDown/LeftRight layouts.
# 2. Smart defaults: Black edges (not blue), TopDown orientation (not LeftRight).
# 3. Intuitive behavior: Diagrams "just work" without needing Graphviz expertise.

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

/*--- Node forms

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

/*--- Using direct names of forms to create nodes

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
	AddNoteXTT(:@Node24, "Note", [ :color = "yellow" ])

	View()
}

pf()

/*--- Like in stzGraph, three levels are allowed: AddNode(), AddNodeXT() and AddNodeXTT()
*/
pr()

o1 = new stzDiagram("")
o1 {
	SetSplines("spline")
	AddNode("a")
	AddNodeXT("b", "pass")
	AddNodeXTT("c", "end", [ :type = "endpoint", :color = "yellow" ]) 
	Connect("a", "b")
	ConnectXT("a", "c", "focus")
	View()
}

pf()

/*--- Style options

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

/*--- Creating Test Diagram

pr()

oDiag = new stzDiagram("ColorSystemTest")
oDiag {
	SetPenWidth(5)
	# Base colors
	AddNodeXTT("n1", "Red Base", [
		:type = "process",
		:color = "red"
	])

	AddNodeXTT("n2", "Blue Base", [
		:type = "process",
		:color = "blue"
	])

	# Intensities
	AddNodeXTT("n3", "Red Dark", [
		:type = "process",
		:color = "red++"
	])

	AddNodeXTT("n4", "Blue Light", [
		:type = "process",
		:color = "blue--"
	])
	
	# Semantic
	AddNodeXTT("n5", "Success", [
		:type = "process",
		:color = "success"
	])

	AddNodeXTT("n6", "Warning", [
		:tpe = "decision",
		:color = "warning"
	])
	
	# Extended palette
	AddNodeXTT("n7", "Coral", [
		:type = "process",
		:color = "coral"
	])

	AddNodeXTT("n8", "Lavender", [
		:type = "process",
		:color = "vender"
	])
	
	# Direct hex
	AddNodeXTT("n9", "Custom", [
		:type = "process",
		:color = "#FF6B9D"
	])
	
	Connect("n1", "n2")
	Connect("n2", "n3")
	Connect("n3", "n4")
	Connect("n4", "n5")
	Connect("n5", "n6")
	Connect("n6", "n7")
	Connect("n7", "n8")
	Connect("n8", "n9")
	
	? Code()
	View()
}

pf()

#-------------------------#
#  CREATE SIMPLE DIAGRAM  #
#-------------------------#

/*--- Building workflow diagram with node types and theme

pr()

oDiag = new stzDiagram("OrderFlow")
oDiag {
	SetTheme("pro")
	AddNodeXTT("start", "Order Received", [
		:type = "start",
		:color = "success"]
	)

	AddNodeXTT("validate", "Validate", [
		:type = "process",
		:color = "primary"
	])

	AddNodeXTT("complete", "Done", [
		:type = "endpoint", :color = "success"
	])

	# Test with .................. :Note,....:Yellow)

	Connect("start", "validate")
	Connect("validate", "complete")

	? NodeCount() #--> 3
	? EdgeCount() #--> 2

	? Dot()

	View()
}

#-->
'
digraph "OrderFlow" {
    graph [rankdir=TB, bgcolor=white, fontname=Helvetica]
    node [fontname=Helvetica]
    edge [fontname=Helvetica, color=black]

    start [label="Order Received", shape=ellipse, style="filled", fillcolor="#006633", fontcolor="white"]
    validate [label="Validate", shape=box, style="rounded,filled", fillcolor="lightblue", fontcolor="black"]
    complete [label="Done", shape=doublecircle, style="filled", fillcolor="#006633", fontcolor="white"]

    start -> validate
    validate -> complete

}
'

pf()

#------------------------#
#  TEST 2: VALIDATE DAG  #
#------------------------#

/*--- Ensuring workflow is acyclic

pr()

oDiag = new stzDiagram("ValidDAG")

oDiag.AddNodeXTT("s", "Start", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("p", "Process", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("e", "End", [ :type = "endpoint", :color = "success" ])

oDiag.Connect("s", "p")
oDiag.Connect("p", "e")

? oDiag.Validate("DAG") #--> TRUE

pf()

#---------------------------------#
#  TEST 3: VALIDATE REACHABILITY  #
#---------------------------------#

/*--- Checking all endpoints reachable from start

pr()

oDiag = new stzDiagram("ReachableEndpoints")

oDiag.AddNodeXTT("start", "Start", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("process", "Process", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("end", "End", [ :type = "endpoint", :color = "success" ])

oDiag.Connect("start", "process")
oDiag.Connect("process", "end")

odiag.view()
? oDiag.Validate("Reachability")
? @@NL(oDiag.ValidationResult()) # Or simply Resul()
#-->
'[
	[ "status", "pass" ],
	[ "domain", "reachability" ],
	[ "issuecount", 0 ],
	[ "issues", [  ] ]
]
'

? oDiag.ValidationStatus() # Or simply Status()
#--> pass

pf()

#-----------------#
#  TEST 4: VALIDATE COMPLETENESS
#-----------------#

/*--- Ensuring decisions have multiple paths

pr()

oDiag = new stzDiagram("Completeness")

oDiag.AddNodeXTT("d", "Approved?", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("yes", "Yes", [ :type = "endpoint", :color = "success" ])
oDiag.AddNodeXTT("no", "No", [ :type = "endpoint", :color = "danger" ])

oDiag.ConnectXT("d", "yes", "Yes")
oDiag.ConnectXT("d", "no", "No")

? oDiag.Validate(:Completeness) #--> TRUE
? oDiag.Status() #--> pass

pf()

#-----------------#
#  TEST 5: COMPUTE METRICS
#-----------------#

/*--- Analyzing workflow path metrics

pr()

oDiag = new stzDiagram("MetricsTest")

oDiag.AddNodeXTT("start", "Start", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("p1", "Step 1", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("p2", "Step 2", [ :type = "process", :color = "primary" ])

oDiag.AddNodeXTT("end", "End", [ :type = "endpoint", :color = "success" ])

oDiag.Connect("start", "p1")
oDiag.Connect("p1", "p2")
oDiag.Connect("p2", "end")

aMetrics = oDiag.ComputeMetrics()
? @@NL(aMetrics)
#-->
'
[
	[ "avgpathlength", 2 ],
	[ "maxpathlength", 3 ],
	[
		"bottlenecks",
		[ "p1", "p2" ]
	],
	[ "density", 25 ],
	[ "nodecount", 4 ],
	[ "edgecount", 3 ]
]
'

? aMetrics[:NodeCount] #--> 4
? aMetrics[:MaxPathLength] #--> 3

pf()

#-----------------#
#  TEST 6: ADD ANNOTATION
#-----------------#

/*--- Adding performance metadata to nodes

pr()

oDiag = new stzDiagram("Annotated")
oDiag.AddNodeXTT("process", "Process", [ :type = "process", :color = "primary" ])

oPerf = new stzDiagramAnnotator(:Performance)
oPerf.Annotate("process", ["latency" = 150, "unit" = "ms"])

oDiag.AddAnnotation(oPerf)

? len(oDiag.Annotations()) #--> 1
? len(oPerf.NodesData()) #--> 1

pf()

#-----------------#
#  TEST 7: ANNOTATIONS BY TYPE
#-----------------#

/*--- Retrieving annotations by type

pr()

oDiag = new stzDiagram("AnnotationTypes")
oDiag.AddNodeXTT("n1", "Node 1", [ :color = "process", :type = "primary" ])

oPerf = new stzDiagramAnnotator(:Performance)
oPerf.Annotate("n1", ["latency" = 100])
oDiag.AddAnnotation(oPerf)

oComp = new stzDiagramAnnotator(:Compliance)
oComp.Annotate("n1", ["status" = "certified"])
oDiag.AddAnnotation(oComp)

aPerf = oDiag.AnnotationsByType(:Performance)
aCompliance = oDiag.AnnotationsByType(:Compliance)

? len(aPerf) #--> 1
? len(aCompliance) #--> 1

pf()

#-----------------#
#  TEST 8: ADD CLUSTERS
#-----------------#

/*--- Grouping nodes into logical domains

pr()

oDiag = new stzDiagram("Clustered")

oDiag.AddNodeXTT("user_api", "User API", [ :color = "process", :type = "success" ])
oDiag.AddNodeXTT("user_db", "User DB", [ :color = "storage", :type = "success" ])
oDiag.AddNodeXTT("order_api", "Order API", [ :color = "process", :type = "info" ])
oDiag.AddNodeXTT("order_db", "Order DB", [ :color = "storage", :type = "info" ])

oDiag.AddClusterXTT("users", "User Domain", ["user_api", "user_db"], :LightGreen)
oDiag.AddClusterXTT("orders", "Order Domain", ["order_api", "order_db"], :Lightblue)

? len(oDiag.Clusters()) #--> 2

pf()

#-----------------#
#  TEST 9: GET CLUSTER INFO
#-----------------#

/*--- Retrieving cluster details

pr()

oDiag = new stzDiagram("ClusterInfo")
oDiag.AddNodeXTT("a", "A", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("b", "B", [ :type = "process", :color = "primary" ])

oDiag.AddClusterXTT("domain1", "My Domain", ["a", "b"], "lightblue")

aClusters = oDiag.Clusters()
aCluster = aClusters[1]

? aCluster["label"] #--> My Domain
? len(aCluster["nodes"]) #--> 2

pf()

#-----------------#
#  TEST 10: SET THEMES
#-----------------#

/*--- Testing different theme configurations

pr()

oDiag1 = new stzDiagram("LightTheme")
oDiag1.SetTheme(:Light)
? oDiag1.Theme() #--> Light

oDiag2 = new stzDiagram("DarkTheme")
oDiag2.SetTheme(:Dark)
? oDiag2.Theme() #--> Dark

oDiag3 = new stzDiagram("VibrantTheme")
oDiag3.SetTheme(:Vibrant)
? oDiag3.Theme() #--> Vibrant

pf()

#-----------------#
#  TEST 11: SET LAYOUT
#-----------------#

/*--- Testing different layout configurations

pr()

oDiag1 = new stzDiagram("MyDiagram")
oDiag1.SetLayout(:TopDown)
? oDiag1.Layout() #--> TopDown

oDiag2 = new stzDiagram("MyDiagram")
oDiag2.SetLayout(:LeftRight)
? oDiag2.Layout() #--> LeftRight

pf()

#-----------------#
#  TEST 12: SOX COMPLIANCE VALIDATION
#-----------------#

/*--- Validating workflow against SOX rules

pr()

oDiag = new stzDiagram("SoxPayment")
oDiag {
	AddNodeXTT(:@Submit, "Submit", [ :type = "start", :color = "success" ])
	AddNodeXTT(:@Approve, "Approve?", [ :type = "decision", :color = "warning" ])
	AddNodeXTT(:@Pay, "Pay", [ :type = "proces", :color = "primary" ])
	AddNodeXTT(:@Log, "Log", [ :type = "data", :color = "neutral" ])
	AddNodeXTT(:@Done, "Done", [ :type = "endpoint", :color = "success" ])

	Connect(:@Submit, :@Approve)
	ConnectXT(:@Approve, :@Pay, "Yes")
	Connect(:@Pay, :@Log)
	Connect(:@Log, :@Done)

	? Validate(:SOX) # Or IsValid(:SOX)
	#--> FALSE

	? @@NL( ValidationIssues() )
	# [
	# 	"SOX-002: Decision node lacks approval requirement: ",
	# 	"@approve"
	# ]

}

pf()

#-----------------#
#  TEST 13: GDPR COMPLIANCE VALIDATION
#-----------------#

/*--- Validating data flow against GDPR rules

pr()

oDiag = new stzDiagram("GdprData")
oDiag {
	AddNodeXTT("collect", "Collect", [ :type = "process", :color = "primary" ])
	AddNodeXTT("process", "Process", [ :type = "process", :color = "primary" ])
	AddNodeXTT("delete", "Delete", [ :type = "process", :color = "info" ])

	Connect("collect", "process")
	Connect("collect", "delete")

	# Set node properties using the new methods
	SetNodeProperties("collect", [
		:dataType = :personal,
		:requiresConsent = TRUE,
		:retentionPolicy = "1 year"
	])

	SetNodeProperty("delete", :operation, :delete)

	SetNodeProperties("process", [
		:dataType = :personal,
		:requiresConsent = TRUE,
		:retentionPolicy = "1 year"
	])

	? Validate(:GDPR) 	   #--> TRUE
	? @@( ValidationIssues() ) #--> []
}

pf()

#-----------------#
#  TEST 14: BANKING COMPLIANCE VALIDATION
#-----------------#

/*--- Validating transaction against banking rules

pr()

oDiag = new stzDiagram("BankingTx")
oDiag {
	AddNodeXT("init", "Initiate", :Start, :success)
	AddNodeXT("fraud", "Fraud Check", :Process, :info)
	AddNodeXT("approve", "Approve?", :Decision, :warning)
	AddNodeXT("execute", "Execute", :Process, :primary)
	AddNodeXT("done", "Done", :Endpoint, :success)

	Connect("init", "fraud")
	Connect("fraud", "approve")
	ConnectXT("approve", "execute", "Yes")
	Connect("execute", "done")

	SetNodeProperty("init", :transactionType, :large)
	SetNodeProperty("fraud", :operation, :fraud_check)
	SetNodeProperty("approve", :role, :approver)
	SetNodeProperty("execute", :operation, :payment)

	? @@(Validate(:Banking))
	#--> TRUE

	? ValidationIssueCount() # Or simply IssueCount()
	#--> 0
}

pf()

#-----------------#
#  TEST 15: EXPORT TO HASHLIST
#-----------------#

/*--- Converting diagram to hashlist representation

pr()

oDiag = new stzDiagram("HashlistExport")
oDiag.SetTheme(:pro)
oDiag.AddNodeXT("n1", "Node", :Process, :primary)

aHashlist = oDiag.ToHashlist()

? aHashlist["theme"] #--> pro
? aHashlist["nodeCount"] >= 0 #--> TRUE

pf()

#-----------------#
#  TEST 1: GENERATE STZDIAG FORMAT
#-----------------#

/*--- Generating .stzdiag native text format

pr()

oDiag = new stzDiagram("FormatTest")
oDiag.SetTheme(:pro)
oDiag.SetLayout(:TopDown)
oDiag.AddNodeXT("start", "Begin", "start", "success-")
oDiag.AddNodeXT("process", "Work", "process", "primary+")
oDiag.AddNodeXT("end", "Finish", "endpoint", "success")
oDiag.Connect("start", "process")
oDiag.Connect("process", "end")

? oDiag.stzdiag()
#-->
'
diagram "FormatTest"

metadata
    theme: light
    layout: topdown

nodes
    start
        label: "Begin"
        type: start
        color: #008000		#TODO should stay semantic!!

    process
        label: "Work"
        type: process
        color: #0000FF

    end
        label: "Finish"
        type: endpoint
        color: #008000

edges
    start -> process

    process -> end
'

oDiag.Show()
#-->
'
        ╭───────╮        
        │ Begin │        
        ╰───────╯        
            |            
            v            
       ╭────────╮        
       │ !Work! │        
       ╰────────╯        
            |            
            v            
       ╭────────╮        
       │ Finish │        
       ╰────────╯    
'

oDiag.View()

pf()

#-----------------#
#  TEST 2: WRITE STZDIAG TO FILE
#-----------------#

/*--- Saving diagram to .stzdiagram file

pr()

oDiag = new stzDiagram("SaveTest")
oDiag.AddNodeXT("a", "Node A", :Process, :primary)
oDiag.AddNodeXT("b", "Node B", :Process, :primary)
oDiag.ConnectXT("a", "b", "flows")

oConv = new stzDiagramToStzDiag(oDiag)
bSuccess = oConv.WriteToFile("test_diagram.stzdiag")

? bSuccess #--> TRUE
? read("test_diagram.stzdiag") #--> TRUE
#-->
'
diagram "SaveTest"

metadata
    theme: null
    layout: null

nodes
    a
        label: "Node A"
        type: process
        color: primary

    b
        label: "Node B"
        type: process
        color: primary

edges
    a -> b
        label: "flows"
'

pf()

#-----------------#
#  TEST 3: STZDIAG WITH CLUSTERS
#-----------------#

/*--- Converting diagram with cluster definitions

pr()

oDiag = new stzDiagram("ClusterTest")
oDiag.AddNodeXT("api", "API", :Process, :success)
oDiag.AddNodeXT("db", "DB", :Storage, :success)
oDiag.AddClusterXTT("domain", "Service Domain", ["api", "db"], "lightblue")

? oDiag.stzdiag()
#-->
'
diagram "ClusterTest"

metadata
    theme: light
    layout: topdown

nodes
    api
        label: "API"
        type: process
        color: #008000

    db
        label: "DB"
        type: storage
        color: #008000

clusters
    domain
        label: "Service Domain"
        nodes: [api, db]
        color: #4D4DC9
'

oDiag.View()

pf()

#-----------------#
#  TEST 4: STZDIAG WITH ANNOTATIONS
#-----------------#

/*--- Converting diagram with annotations

pr()

oDiag = new stzDiagram("AnnotationTest")
oDiag.AddNodeXT("process", "MyProcess", :Process, :primary)

oPerf = new stzDiagramAnnotator(:Performance)
oPerf.Annotate("process", ["latency" = 150])
oDiag.AddAnnotation(oPerf)

? oDiag.stzdiag()
#-->
'
diagram "AnnotationTest"

metadata
    theme: light
    layout: topdown

nodes
    process
        label: "MyProcess"
        type: process
        color: lightblue

annotations
    performance
        process: null
'

pf()

#-----------------#
#  TEST 5: CONVERT TO DOT
#-----------------#

/*--- Converting to Graphviz DOT language

pr()

oDiag = new stzDiagram("DotTest")
oDiag.AddNodeXT("start", "Start", :Start, :success)
oDiag.AddNodeXT("end", "End", :Endpoint, :success)
oDiag.Connect("start", "end")

? oDiag.stzdiag()
oDiag.View()
#-->
'
diagram "DotTest"

metadata
    theme: light
    layout: topdown

nodes
    start
        label: "Start"
        type: start
        color: success

    end
        label: "End"
        type: endpoint
        color: success

edges
    start -> end
'

pf()

#-----------------#
#  TEST 6: WRITE DOT FILE
#-----------------#

/*--- Saving to DOT file

pr()

oDiag = new stzDiagram("DotFileTest")
oDiag.AddNodeXT("a", "A", :Process, :white)
oDiag.AddNodeXT("b", "B", :Process, :white)
oDiag.Connect("a", "b")


oConv = new stzDiagramToDot(oDiag)
bSuccess = oConv.WriteToFile("test_diagram.dot")

? bSuccess #--> TRUE
? read("test_diagram.dot") #--> TRUE
#-->
'
digraph "DotFileTest" {
    graph [rankdir=TB, bgcolor=white, fontname=Helvetica]
    node [fontname=Helvetica]
    edge [fontname=Helvetica, color=NULL]

    a [label="A", shape=box, style="rounded,filled", fillcolor="white"]
    b [label="B", shape=box, style="rounded,filled", fillcolor="white"]

    a -> b

}
'

pf()

#-----------------#
#  TEST 7: DOT NODE SHAPES
#-----------------#

/*--- Verifying DOT node type shapes

pr()

oDiag = new stzDiagram("DotShapesTest")
oDiag.SetTheme("vibrant")
oDiag.AddNodeXT("s", "S", :Start, :success)
oDiag.AddNodeXT("d", "D", :Decision, :warning)
oDiag.AddNodeXT("p", "P", :Process, :primary)
oDiag.AddNodeXT("e", "E", :Endpoint, :success)

? oDiag.Dot()
#-->
'
digraph "DotShapesTest" {
    graph [rankdir=TB, bgcolor=white, fontname=Helvetica]
    node [fontname=Helvetica]
    edge [fontname=Helvetica, color=black, style=solid]

    s [label="S", shape=ellipse, style="filled", fillcolor="lightgreen", fontcolor="black"]
    d [label="D", shape=diamond, style="filled", fillcolor="lightyellow", fontcolor="black"]
    p [label="P", shape=box, style="rounded,filled", fillcolor="lightblue", fontcolor="black"]
    e [label="E", shape=doublecircle, style="filled", fillcolor="lightgreen", fontcolor="black"]


}
'

oDiag.View()


pf()

#-----------------#
#  TEST 8: CONVERT TO MERMAID
#-----------------#

/*--- Converting to Mermaid.js syntax

pr()

oDiag = new stzDiagram("MermaidTest")
oDiag.AddNodeXT("start", "Start", :Start, :success)
oDiag.AddNodeXT("decision", "Check", :Decision, :warning)
oDiag.AddNodeXT("process", "Process", :Process, :primary)
oDiag.AddNodeXT("end", "End", :Endpoint, :success)

oDiag.Connect("start", "decision")
oDiag.ConnectXT("decision", "process", "Yes")
oDiag.Connect("process", "end")

? oDiag.Mermaid()
#--> Past it in https://mermaid.live/
'
graph TD
    node_start(["Start"])
    decision{{"Check"}}
    process["Process"]
    node_end(["End"])

    node_start --> decision
    decision -->|Yes| process
    process --> node_end
'

oDiag.Show()
#-->
'
        ╭───────╮        
        │ Start │        
        ╰───────╯        
            |            
            v            
       ╭─────────╮       
       │ !Check! │       
       ╰─────────╯       
            |            
           Yes           
            |            
            v            
      ╭───────────╮      
      │ !Process! │      
      ╰───────────╯      
            |            
            v            
         ╭─────╮         
         │ End │         
         ╰─────╯   
'

pf()

#-----------------#
#  TEST 9: WRITE MERMAID FILE
#-----------------#

/*--- Saving to Mermaid file

pr()

oDiag = new stzDiagram("MermaidFileTest")
oDiag.AddNodeXT("a", "A", :Process, :primary)
oDiag.AddNodeXT("b", "B", :Process, :primary)
oDiag.ConnectXT("a", "b", "leads")

bSuccess = oDiag.WriteToMermaidFile("test_diagram.mmd") #  # Or just WriteToFile() ~> idenified by .mmd extension
? bSuccess #--> TRUE
? read("test_diagram.mmd") #--> TRUE
#-->
'
graph TD
    a[["A"]]
    b[["B"]]

    a --> b |leads|
'

pf()

#-----------------#
#  TEST 10: MERMAID NODE SHAPES
#-----------------#

/*--- Verifying Mermaid node type shapes

pr()

oDiag = new stzDiagram("MermaidShapesTest")
oDiag.AddNodeXT("s", "S", :Start, :success)
oDiag.AddNodeXT("d", "D", :Decision, :warning)
oDiag.AddNodeXT("e", "E", :Endpoint, :success)

? oDiag.Mermaid()
#-->
'
graph TD
    s(["S"])
    d{{"D"}}
    e([" E "])
'

pf()

#-----------------#
#  TEST 11: CONVERT TO JSON
#-----------------#

/*--- Converting to JSON format

pr()

oDiag = new stzDiagram("JsonTest")
oDiag.SetTheme(:pro)
oDiag.AddNodeXT("a", "A", :Process, :primary)
oDiag.AddNodeXT("b", "B", :Process, :primary)
oDiag.Connect("a", "b")

? oDiag.Json()
#-->
'
{"id":"JsonTest","nodes":[{"id":"a","label":"A","properties":{"type":"process","color":"primary"}},{"id":"b","label":"B","properties":{"type":"process","color":"primary"}}],"edges":[{"from":"a","to":"b","label":"","properties":{}}],"properties":{},"theme":"pro","layout":"NULL","clusters":{},"annotations":{},"templates":{}}
'

#TODO Add JsonXT() --> Indented

pf()

#-----------------#
#  TEST 12: WRITE JSON FILE
#-----------------#

/*--- Saving to JSON file

pr()

oDiag = new stzDiagram("JsonFileTest")
oDiag.AddNodeXT("x", "X", :Process, :primary)

bSuccess = oDiag.WriteToJsonFile("test_diagram.json") # Or just WriteToFile() ~> idenified by .json extension
? bSuccess

? read("test_diagram.json")
#-->
'
{"id":"JsonFileTest","nodes":[{"id":"x","label":"X","properties":{"type":"process","color":"primary"}}],"edges":{},"properties":{},"theme":"NULL","layout":"NULL","clusters":{},"annotations":{},"templates":{}}
'

pf()

#-----------------#
#  TEST 13: JSON STRUCTURE
#-----------------#

/*--- Verifying JSON structure fields

pr()

oDiag = new stzDiagram("JsonStructureTest")
oDiag.AddNodeXT("n", "Node", :Process, :primary)

? oDiag.Json()
#-->
'
{
	"id": "JsonStructureTest",
	"nodes": [
		{
			"id": "n",
			"label": "Node",
			"properties": {
				"type": "process",
				"color": "primary"
			}
		}
	],
	"edges": {},
	"properties": {},
	"theme": "light",
	"layout": "topdown",
	"clusters": {},
	"annotations": {},
	"templates": {}
}

pf()

#-----------------#
#  TEST 15: EDGE LABELS PRESERVATION
#-----------------#

/*--- Verifying edge labels in all formats

pr()

oDiag = new stzDiagram("EdgeLabelTest")
oDiag.AddNodeXT("a", "A", :Process, :primary)
oDiag.AddNodeXT("b", "B", :Process, :primary)
oDiag.ConnectXT("a", "b", "important")

cStzOutput = oDiag.stzdiag()
cDotOutput = odiag.dot()
cMermaidOutput = oDiag.mermaid()

? contains(cStzOutput, "important") #--> TRUE
? contains(cDotOutput, "important") #--> TRUE
? contains(cMermaidOutput, "important") #--> TRUE

pf()

#-------------------------#
# TESTING VISUAL OPTIONS  #
#-------------------------#

/*-- Test 1: Layout variations

pr()

oDiag1 = new stzDiagram("LayoutTest")
oDiag1 {
	SetTheme(:gray) # Or :Print or :Gray :LightGray or :DarkGray or :Access
	SetLayout(:LeftRight)      # Semantic
	# SetLayout(:LR)           # Short form
	
	AddNodeXT("n1", "Node 1", :Start, :Success)
	AddNodeXT("n2", "Node 2", :Process, :Primary)
	AddNodeXT("n3", "Node 3", :Endpoint, :Danger)
	
	Connect("n1", "n2")
	Connect("n2", "n3")
	
	? Dot()
	View()
}
#-->
'
digraph "LayoutTest" {
    graph [rankdir=LR, bgcolor=white, fontname=Helvetica]
    node [fontname=Helvetica]
    edge [fontname=Helvetica, color=black, style=solid]

    n1 [label="Node 1", shape=ellipse, style="filled", fillcolor="lightgreen", fontcolor="black"]
    n2 [label="Node 2", shape=box, style="rounded,filled", fillcolor="lightblue", fontcolor="black"]
    n3 [label="Node 3", shape=doublecircle, style="filled", fillcolor="lightcoral", fontcolor="black"]

    n1 -> n2
    n2 -> n3

}
'

pf()

/*-- Test 2: Edge style variations

pr()

oDiag2 = new stzDiagram("EdgeStyleTest")
oDiag2 {
	SetLayout(:TopDown)
	SetEdgeStyle(:Conditional)  # Semantic → dashed
	# SetEdgeStyle(:Dashed)     # Visual term

	SetEdgeColor("blue")
	
	AddNodeXT("a", "Start", :Start, :Success)
	AddNodeXT("b", "Check", :Decision, :Warning)
	AddNodeXT("c", "End", :Endpoint, :Danger)
	
	Connect("a", "b")
	ConnectXT("b", "c", "Yes")
	
	View()
}

pf()

/*-- Test 3: Node type variations

pr()

oDiag = new stzDiagram("ShapeTest")
oDiag {
	SetTheme(:pro)
	SetLayout(:TopDown)
	
	# Semantic types (shape auto-selected)
	AddNodeXT("start", "Start", "start", :success)
	AddNodeXT("validate", "Validate", "process", :primary)
	AddNodeXT("check", "Valid?", "decision", :warning)
	AddNodeXT("done", "Done", "endpoint", :success)
	
	# Direct DOT shapes (explicit control)
	AddNodeXT("db", "Database", "cylinder", "neutral+") # Note how we made neutral a bit darker with +
	AddNodeXT("alert", "Alert", "hexagon", :danger)
	AddNodeXT("backup", "Backup", "parallelogram", :info)
	AddNodeXT("end", "End", "octagon", :success)
	
	Connect("start", "validate")
	Connect("validate", "check")
	ConnectXT("check", "db", "Yes")
	ConnectXT("check", "alert", "No")
	Connect("db", "backup")
	Connect("backup", "done")
	Connect("alert", "end")
	
	? Code()
	View()
}

pf()

/*-- Test 4: Theme variations

pr()

# Supported thems: light, dark, vibrant, pro, access,
# print, gray, lightgray, darkgray

oDiag4 = new stzDiagram("ThemeTest")
oDiag4 {
	SetTheme(:light)
	SetLayout(:RightLeft)
	SetNodeStrokeColor("navy")
	
	AddNodeXT("x", "Alpha", :Start, :Success)
	AddNodeXT("y", "Beta", :Process, :Primary)
	AddNodeXT("z", "Gamma", :Endpoint, :Info)
	
	Connect("x", "y")
	Connect("y", "z")
	
	View()
}

pf()

/*--- Generating the diagram image in all the supported themes

pr()

# Test all themes with semantic colors
aThemes = ["light", "dark", "vibrant", "pro", "access", 
           "print", "gray", "lightgray", "darkgray"]

aThemes = ["pro"]

for cTheme in aThemes
	oDiag = new stzDiagram("Theme_" + cTheme)
	oDiag {
		SetTheme(cTheme)
		SetLayout(:LeftRight)
		
		# All semantic color types
		AddNodeXT("s", "Start", :Start, :success)
		AddNodeXT("p1", "Process", :Process, :primary)
		AddNodeXT("w", "Warning", :Decision, :warning)
		AddNodeXT("d", "Danger", :Process, :danger)
		AddNodeXT("i", "Info", :Storage, :info)
		AddNodeXT("n", "Neutral", :Process, :neutral)
		AddNodeXT("e", "End", :Endpoint, :success)
		
		Connect("s", "p1")
		Connect("p1", "w")
		ConnectXT("w", "d", "Yes")
		ConnectXT("w", "i", "No")
		Connect("d", "n")
		Connect("i", "n")
		Connect("n", "e")
		
		? "Theme: " + cTheme
		View()
		sleep(2)  # Pause between diagrams
	}
next

pf()

/*-- Test 5: Combined options

pr()

oDiag5 = new stzDiagram("CompleteTest")
oDiag5 {
	SetTheme(:Light)
	SetLayout("lr")              # Short form
	SetEdgeStyle(:ErrorFlow)     # Semantic → dotted
	SetPenWidth(3)
	SetEdgeColor("gray+")
	
	AddNodeXT("start", "Begin", :Start, :Success)
	AddNodeXT("proc1", "Validate", :Process, :Primary)
	AddNodeXT("dec1", "Valid?", :Decision, :Warning)
	AddNodeXT("error", "Error", :Error, :Danger)
	AddNodeXT("done", "Complete", :Endpoint, :Success)
	
	Connect("start", "proc1")
	ConnectXT("proc1", "dec1", "Check")
	ConnectXT("dec1", "error", "No")
	ConnectXT("dec1", "done", "Yes")
	
	? "Nodes: " + NodeCount()
	? "Edges: " + EdgeCount()
	
	View()
}

pf()

/*-- Test 6: Color resolution

pr()

oDiag6 = new stzDiagram("ColorTest")
oDiag6 {
	SetTheme(:vibrant)
	
	# Symbolic colors from palette
	AddNodeXT("n1", "Success", :Process, :Success)
	AddNodeXT("n2", "Warning", :Process, :Warning)
	AddNodeXT("n3", "Danger", :Process, :Danger)
	
	# Direct color names
	AddNodeXT("n4", "Blue", :Process, "lightblue")
	AddNodeXT("n5", "Green", :Process, "lightgreen")
	
	# Hex colors
	AddNodeXT("n6", "Custom", :Process, "#FF9900")
	
	Connect("n1", "n2")
	Connect("n2", "n3")
	Connect("n3", "n4")
	Connect("n4", "n5")
	Connect("n5", "n6")
	
	View()
}

pf()

#----------------#
#  FONT EXAMPLE  #
#----------------#

/*---

pr()

oDiag = new stzDiagram("FontTest")
oDiag {
	SetFont("helvetica") 	#ERR // Not applied
	SetFontSize(24)		#ERR // Idem
	SetTheme(:Pro)
	
	AddNodeXT("n1", "Custom Font", :Start, :Success)
	AddNodeXT("n2", "Arial 24pt", :Process, :Primary)
	ConnectXT("n1", "n2", "size")
	
	View()
}

pf()

#------------------------------#
#  VISUAL RULES AND SEMANTICS  #
#------------------------------#


/*---  Example 1: Security Risk Visualization
*/
pr()

# Create the diagram object

oDiag = new stzDiagram("SecurityFlow")

# Define visual rules based on metadata

oHighRiskRule = new stzVisualRule("high_risk")
oHighRiskRule {
	When("risk_score", :InSection = [70, 100])
	ApplyColor("#FF4444") 	#NOTE // Possible to use hex but better use semantic names
				# Try with ApplyColor("green") or "sucess--" etc
	ApplyPenWidth(3)
}

oSecureRule = new stzVisualRule("secure")
oSecureRule {
	WhenTagExists(:security)
}

# Crafing the diagram object

oDiag {

	# Use those rules inside the diagram object

	SetVisualRule(oHighRiskRule) #TODO// Make rules definable directly here, if not done yet!
	SetVisualRule(oSecureRule)
	ApplyRules()

	# Add nodes with metadata

	AddNodeXTT("auth", "Authentication", [
		:type = "process",
		:color = "primary",
		:risk_score = 85,
		:sla_ms = 100,
		:tags = [ :security, :critical ]
	])

	AddNodeXTT("db", "Database", [
		:type = "storage",
		:color = "info",
		:risk_score = 45,
		:encrypted = TRUE,
		:tags = [ :security ]
	])

	AddEdgeWithXTT("auth", "db", "query", [
		:type = "requires",
		:tags = [ :data_flow ]
	])

	? Code()
	View()
}


pf()

/*---  Example 2: Performance Monitoring

pr()

oDiag = new stzDiagram("APIFlow")

# Performance-based coloring
oSlowRule = new stzVisualRule("slow_api")
oSlowRule.WhenMetadataInSection("latency_ms", 500, 9999)
oSlowRule.ApplyColor("#FFA500")

oFastRule = new stzVisualRule("fast_api")
oFastRule.WhenMetadataInSection("latency_ms", 0, 100)
oFastRule.ApplyColor("#44FF44")

oDiag.SetVisualRule(oSlowRule)
oDiag.SetVisualRule(oFastRule)

oDiag.AddNodeXTT("api1", "User API", :Process, :Primary,
	[ :latency_ms = 50, :throughput = 1000], [:api])

oDiag.AddNodeXTT("api2", "Payment API", :Process, :Primary,
	[ :latency_ms = 800, :throughput = 100], [:api, :critical])


oDiag.View()

pf()

/*---  Example 3: Compliance Tagging

pr()

oDiag = new stzDiagram("DataFlow")

# GDPR compliance visualization
oGdprRule = new stzVisualRule("gdpr")
oGdprRule {
	WhenTagExists(:gdpr)
	ApplyPenWidth(2)
}

# PCI-DSS compliance
oPciRule = new stzVisualRule("pci")
oPciRule.WhenTagExists(:pci)
oPciRule.ApplyColor("#0066CC")

oDiag.SetVisualRule(oGdprRule)
oDiag.SetVisualRule(oPciRule)

oDiag.AddNodeXTT("collect", "Data Collection", :Process, :Info,
	[:retention_days = 90], ["gdpr"])

oDiag.AddNodeXTT("payment", "Payment Processing", :Process, :Warning,
	[:encryption = TRUE], ["pci"])

? oDiag.code()
oDiag.View()

#TODO Enricth the tooltip content in svg format
#TODO Add hyperlinks in svg diagrams for interactive usecases

pf()


/*---------------------------#
#  TEST 4: Exact Value Matching
#---------------------------#

pr()

oDiag = new stzDiagram("EnvironmentColors")

# Production systems get red warning color
oProductionRule = new stzVisualRule("prod_warning")
oProductionRule {
//	WhenMetadataEquals("env", "production")
	# or more elgant:
	When("env", :equals = "production")

	ApplyColor("green")
	ApplyPenWidth(3)
}

oDiag {
	SetVisualRule(oProductionRule)

	AddNodeXTT("prod_db", "Production DB", [
		:Type = :Storage,
		:Color = :Primary,

		:env = "production",
		:replicas = 3,
		:tags = ["database"]
	])
	
	AddNodeXTT("dev_db", "Dev DB", [
		:Type = :Storage,
		:Color = :Info,

		:env = "development",
		:tags = [:database]
	])
	
	Connect("prod_db", "dev_db")
	View()
	? Code()
}

pf()

/*---------------------------#
#  TEST 5: Task Priority
#---------------------------#

pr()

oDiag = new stzDiagram("TaskPriority")

oLowPrio = new stzVisualRule("low")
oLowPrio {
	When("priority", :InSection = [0, 33])
	ApplyColor(:neutral)
}

oMedPrio = new stzVisualRule("medium")
oMedPrio {
	When("priority", :InSection = [34, 66])
	ApplyColor(:info)
}

oHighPrio = new stzVisualRule("high")
oHighPrio {
	When("priority", :InSection = [67, 100])
	ApplyColor(:danger)
	ApplyPenWidth(3)
}

oDiag {
	SetVisualRule(oLowPrio)
	SetVisualRule(oMedPrio)
	SetVisualRule(oHighPrio)
	
	AddNodeXTT("task1", "Cleanup", [
		:type = :process,
		:priority = 20
	])
	
	AddNodeXTT("task2", "Review", [
		:type = :process,
		:priority = 50
	])
	
	AddNodeXTT("task3", "Deploy", [
		:type = :process,
		:priority = 90,
		:tags = [:critical]
	])
	
	Connect("task1", "task2")
	Connect("task2", "task3")
	
	View()
}

pf()

/*---------------------------#
#  TEST 6: Edge Styling
#---------------------------#


pr()

oDiag = new stzDiagram("ConnectionTypes")

oSyncEdge = new stzVisualRule("sync")
oSyncEdge {
	When("type", :equals = "sync")
	ApplyStyle("bold")
	ApplyColor(:primary)
}

oAsyncEdge = new stzVisualRule("async")
oAsyncEdge {
	When("type", :equals = "async")
	ApplyStyle("dashed")
	ApplyColor(:neutral)
}

oDiag {
	SetVisualRule(oSyncEdge)
	SetVisualRule(oAsyncEdge)

	AddNodeXT("api", "API Gateway")
	AddNodeXT("service", "Auth Service")
	AddNodeXT("cache", "Redis Cache")

	AddEdgeXTT("api", "service", "authenticate", [
		:type = "sync"
	])
	
	AddEdgeXTT("service", "cache", "invalidate", [
		:type = "async"
	])

	View()
	? Code()
}

pf()

/*---------------------------#
#  TEST 7: Metadata Presence
#---------------------------#

pr()

oDiag = new stzDiagram("SlaMonitoring")

oHasSla = new stzVisualRule("sla_defined")
oHasSla {
	WhenMetadataExists("sla_ms")  # Use the direct method
	ApplyPenWidth(2)
	ApplyColor(:green)
}

oDiag {
	SetVisualRule(oHasSla)
	
	AddNodeXTT("critical_api", "Payment API", [
		:type = :process,
		:sla_ms = 100,
		:uptime = 99.99
	])
	
	AddNodeXTT("batch_job", "Batch Job", [
		:type = :process,
		:schedule = "daily"
	])
	
	Connect("critical_api", "batch_job")
	View()
? code()
}

pf()

/*---------------------------#
#  TEST 8: Rule Cascading
#---------------------------#

pr()

oDiag = new stzDiagram("RuleOverride")

oApiBase = new stzVisualRule("api_base")
oApiBase {
	WhenTagExists(:api)
	ApplyColor(:neutral)
}

oCritical = new stzVisualRule("critical_override")
oCritical {
	WhenTagExists(:critical)
	ApplyColor(:danger)
	ApplyPenWidth(4)
}

oDiag {
	SetVisualRule(oApiBase)
	SetVisualRule(oCritical)
	
	AddNodeXTT("standard", "User API", [
		:type = :process,
		:tags = [:api]
	])
	
	AddNodeXTT("vital", "Payment API", [
		:type = :process,
		:tags = [:api, :critical]
	])
	
	Connect("standard", "vital")
	View()
}

pf()

#---------------------------#
#  TEST 9: Dynamic Shapes
#---------------------------#

pr()

oDiag = new stzDiagram("ServiceTypes")

oStorageShape = new stzVisualRule("storage")
oStorageShape {
	WhenTagExists(:storage)
	ApplyShape("cylinder")
	ApplyColor(:brown)
}

oQueueShape = new stzVisualRule("queue")
oQueueShape {
	WhenTagExists(:messaging)
	ApplyShape("parallelogram")
	ApplyColor(:orange)
}

oDiag {
	SetVisualRule(oStorageShape)
	SetVisualRule(oQueueShape)
	
	AddNodeXTT("postgres", "PostgreSQL", [
		:type = "relational",
		:tags = [:storage, :database]
	])
	
	AddNodeXTT("rabbitmq", "RabbitMQ", [
		:type = "broker",
		:tags = [:messaging, :queue]
	])
	
	AddNodeXTT("api", "REST API", [
		:tags = [:service]
	])
	
	Connect("api", "postgres")
	Connect("api", "rabbitmq")
	
	View()
}

pf()

/*---------------------------#
#  TEST 10: Self-Documenting
#---------------------------#

pr()

oDiag = new stzDiagram("DocumentedRules")

oEncrypted = new stzVisualRule("secure")
oEncrypted {
	WhenTagExists(:encrypted)
	ApplyColor("#00AA00")
}

oSlow = new stzVisualRule("performance")
oSlow {
	When("latency_ms", :InSection = [500, 9999])
	ApplyColor("#FFA500")
	ApplyPenWidth(2)
}

oDiag {
	SetVisualRule(oEncrypted)
	SetVisualRule(oSlow)
	
	AddNodeXTT("secure_db", "Encrypted DB", [
		:type = :Storage, :color = :Success, :tags = [:encrypted] ])
	
	AddNodeXTT("slow_api", "Legacy API", [
		:type = :Process, :color = :Warning, :latency_ms = 750 ])
	
	# Generate legend showing all rule mappings
	? "=== Visual Rules Legend ==="
	? @@NL( MetadataLegend() )
	
	View()
}
#-->
'
=== Visual Rules Legend ===
[
	"=== METADATA LEGEND ===",
	"",
	"When: tag_exists",
	"  → ",
	"color",
	": ",
	"#00AA00",
	"",
	"When: metadata_range",
	"  → ",
	"color",
	": ",
	"#FFA500",
	"  → ",
	"penwidth",
	": ",
	2,
	""
]
'

pf()

/*---------------------------#
#  TEST 11: Complex Workflow
#---------------------------#

pr()

oDiag = new stzDiagram("E2EMonitoring")

# Combine multiple rules for realistic monitoring
oHighLoad = new stzVisualRule("load")
oHighLoad {
	When("load_pct", :InSection = [80, 100])
	ApplyColor("#FF4444")
	ApplyPenWidth(3)
}

oEncrypted = new stzVisualRule("secure")
oEncrypted {
	WhenTagExists(:encrypted)
	ApplyStyle("bold,filled")
}

oDeprecated = new stzVisualRule("legacy")
oDeprecated {
	When("status", :Equals = "deprecated")
	ApplyColor("#888888")
	ApplyStyle("dotted,filled")
}

oDiag {
	SetVisualRule(oHighLoad)
	SetVisualRule(oEncrypted)
	SetVisualRule(oDeprecated)
	
	AddNodeXTT("lb", "Load Balancer", [
		:Type = "process", :Color = "primary",
		:load_pct = 85, :tags = ["critical"] ])
	
	AddNodeXTT("db", "Database", [
		:type = "storage", :color = "primary",
		:load_pct = 60, :tags = ["encrypted"] ])
	
	AddNodeXTT("old_api", "Legacy API", [
		:type = "process", :color = "neutral",
		:status = "deprecated" ])
	
	Connect("lb", "db")
	Connect("lb", "old_api")
	
	View()
}

pf()

/*---------------------------#
#  Microservices Health Dashboard
#---------------------------#

pr()

oDiag = new stzDiagram("ServiceHealth")

# Health-based coloring: green=healthy, yellow=degraded, red=down
oHealthy = new stzVisualRule("healthy")
oHealthy{
	When("status", :equals = "up")
	ApplyColor("green")
}

oDegraded = new stzVisualRule("degraded")
oDegraded{
	When("status", :equals = "degraded")
	ApplyColor("orange")
	ApplyPenWidth(2)
}

oDown = new stzVisualRule("down")
oDown {
	When("status", :equals = "down")
	ApplyColor("red")
	ApplyPenWidth(3)
}

# Critical services get diamond shape
oCritical = new stzVisualRule("critical_service")
oCritical {
	WhenTagExists(:critical)
	ApplyShape("diamond")
}

oDiag {
	SetTheme(:pro)
	
	SetVisualRule(oHealthy)
	SetVisualRule(oDegraded)
	SetVisualRule(oDown)
	SetVisualRule(oCritical)
	
	AddNodeXTT("gateway", "API Gateway", [
		:type = "process", :color = "primary",
		:status = "up", :latency_ms = 45, :tags = [:critical] ])
	
	AddNodeXTT("auth", "Auth Service",  [
		:type = "process", :color = "primary",
		:status = "degraded", :latency_ms = 320, :tags = [:critical] ])
	
	AddNodeXTT("users", "Users API",  [
		:type = "process", :color = "primary",
		:status = "up", :latency_ms = 80 ])
	
	AddNodeXTT("orders", "Orders API",  [
		:type = "process", :color = "primary",
		:status = "down", :latency_ms = 0, :tags = [:critical] ])
	
	AddNodeXTT("db", "PostgreSQL",  [
		:type = "storage", :type = "info",
		:status = "up", :replicas = 3, :tags = [:critical] ])
	
	Connect("gateway", "auth")
	Connect("gateway", "users")
	Connect("gateway", "orders")
	Connect("users", "db")
	Connect("orders", "db")
	
	View()
}

pf()

/*---------------------------#
#  Data Pipeline with Compliance
#---------------------------#

pr()

oDiag = new stzDiagram("DataCompliance")

oPiiData = new stzVisualRule("pii")
oPiiData {
	WhenTagExists(:pii)
	ApplyPenWidth(3)
}

oEncrypted = new stzVisualRule("encrypted")
oEncrypted {
	When("encrypted", :equals = TRUE)
	ApplyStyle("bold")
}

oAudited = new stzVisualRule("audit")
oAudited {
	WhenTagExists(:audit)
	ApplyShape("octagon")
}

oDiag {
	SetLayout(:LeftRight)
	
	SetVisualRule(oPiiData)
	SetVisualRule(oEncrypted)
	SetVisualRule(oAudited)
	
	AddNodeXTT("collect", "Data Collector", [
		:type = "process", :color = "info", :tags = [:audit]
	])
	
	AddNodeXTT("transform", "ETL Pipeline", [
		:type = "process", :color = "primary"
	])
	
	AddNodeXTT("warehouse", "Data Warehouse", [
		:type = "storage", :color = "success",
		:encrypted = TRUE, :tags = [:pii, :audit]
	])
	
	AddNodeXTT("analytics", "Analytics", [
		:type = "process", :color = "primary"
	])
	
	AddNodeXTT("reports", "Reports", [
		:type = "endpoint", :color = "info",
		:tags = [:audit]
	])
	
	AddEdgeXTT("collect", "transform", "raw", [
		:encrypted = FALSE
	])
	
	AddEdgeXTT("transform", "warehouse", "store", [
		:encrypted = TRUE
	])
	
	AddEdgeXTT("warehouse", "analytics", "query", [
		:encrypted = TRUE
	])
	
	AddEdgeXTT("analytics", "reports", "publish", [
		:encrypted = FALSE
	])
	
	View()
? Code()
}

pf()

/*----------------------------#
#  Cost-Based Infrastructure  #
#-----------------------------#

pr()

oDiag = new stzDiagram("CloudCosts")

# Color by monthly cost
oLowCost = new stzVisualRule("cheap")
oLowCost {
	When("monthly_usd", :InSection = [0, 100])
	ApplyColor("#E8F5E9")
}

oMedCost = new stzVisualRule("moderate")
oMedCost {
	When("monthly_usd", :InSection = [101, 500])
	ApplyColor("#FFF9C4")
}

oHighCost = new stzVisualRule("expensive")
oHighCost {
	When("monthly_usd", :InSection = [501, 9999])
	ApplyColor("#FFCDD2")
	ApplyPenWidth(3)
}

# Production gets thicker borders
#ERR all nodes are thin!!

oProduction = new stzVisualRule("prod")
oProduction {
	WhenTagExists(:production)
	ApplyPenWidth(2)
}

oDiag {

	# Presentation

	SetTheme(:light)
	
	# Structure

	AddNodeXTT("lb", "Load Balancer", [
		:type = "process",
		:color = "primary",
		:monthly_usd = 50,
		:env = "prod",
		:tags = [ "tag1", "tag2", "tag3" ]
	])
	
	AddNodeXTT("app1", "App Server 1",  [
		:type = "process",
		:color = "primary",
		:env = "prod",
		:monthly_usd = 200,
		:tags = [ "critical" ]
	])
	
	AddNodeXTT("app2", "App Server 2",  [
		:type = "process",
		:color = "primary",
		:monthly_usd = 200,
		:env = "preprod"
	])
	
	AddNodeXTT("rds", "RDS Database", [
		:type = "storage",
		:color = "info",
		:monthly_usd = 800,
		:env = "prod",
		:tags = [ "critical" ]
	])
	
	AddNodeXTT("cache", "Redis Cache", [
		:type = "storage",
		:color = "warning",
		:monthly_usd = 120,
		:env = "prod",
		:tags = [ "critical" ]
	])
	
	AddNodeXTT("s3", "S3 Storage", [
		:type = "storage",
		:color = "success",
		:monthly_usd = 30,
		:env = "test"
	])
	
	ConnectXTT("lb", "app1", "", [ :encrypted = TRUE ])
	Connect("lb", "app2")
	Connect("app1", "rds")
	Connect("app2", "rds")
	Connect("app1", "cache")
	Connect("app2", "cache")
	ConnectXTT("app1", "s3", "", [ :encrypted = TRUE ])
	
	# Logic

	SetVisualRule(oLowCost)
	SetVisualRule(oMedCost)
	SetVisualRule(oHighCost)
	SetVisualRule(oProduction)
	ApplyVisualRules()

	# Output
	View()
}

# Softanza offers a powerful analytics API for visual rules

# Analysis

? @@NL( oDiag.Explain() ) + NL
#-->
`
[
	[ "diagram", "CloudCosts" ],
	[
		"structure",
		"Diagram 'CloudCosts' contains 6 nodes and 7 edges."
	],
	[
		"rules",
		"Applied 4 visual rule(s): cheap, moderate, expensive, prod"
	],
	[
		"effects",
		"6 node(s) enhanced, 7 edge(s) enhanced."
	]
]
`

# All nodes with cost property
? @@( oDiag.NodesWithProperty("monthly_usd") ) + NL
#--> [ "lb", "app1", "app2", "rds", "cache", "s3" ]

# Production nodes

? @@( oDiag.NodesWith("env", :equals = "prod") ) + NL
#--> [ "lb", "app1", "rds", "cache" ]

# Mid-range cost
? @@( oDiag.NodesWith("monthly_usd", :InSection = [100, 500]) ) + NL
#--> [ "app1", "app2", "cache" ]

# Edges with encryption property
? @@( oDiag.EdgesWithProperty("encrypted") ) + NL
#--> [ "lb->app1", "app1->s3" ]

# Synchronous edges
? @@( oDiag.EdgesWithPropertyValue("type", "sync") ) + NL

# Nodes affected by visual rules

? @@( oDiag.NodesAffectedByVRules() )+ NL
#--> [ "lb", "app1", "app2", "rds", "cache", "s3" ]

# Nodes containing a given tag

? @@NL( oDiag.NodesWithTag(:critical) ) + NL
#--> [ "app1", "rds", "cache" ]

# All the applied rules
? @@NL( oDiag.VRulesApplied() )
#-->
`
[
	[ "haseffects", 1 ],
	[
		"summary",
		"4 rule(s) defined, 13 element(s) affected"
	],
	[
		"rules",
		[
			[
				[ "id", "cheap" ],
				[ "condition", "metadata_range" ],
				[
					"conditionparams",
					[ "monthly_usd", 0, 100 ]
				],
				[
					"effects",
					[
						[ "color", "#E8F5E9" ]
					]
				],
				[
					"affectednodes",
					[ "lb", "s3" ]
				],
				[ "affectededges", [  ] ],
				[ "matchcount", 2 ]
			],
			[
				[ "id", "moderate" ],
				[ "condition", "metadata_range" ],
				[
					"conditionparams",
					[ "monthly_usd", 101, 500 ]
				],
				[
					"effects",
					[
						[ "color", "#FFF9C4" ]
					]
				],
				[
					"affectednodes",
					[ "app1", "app2", "cache" ]
				],
				[ "affectededges", [  ] ],
				[ "matchcount", 3 ]
			],
			[
				[ "id", "expensive" ],
				[ "condition", "metadata_range" ],
				[
					"conditionparams",
					[ "monthly_usd", 501, 9999 ]
				],
				[
					"effects",
					[
						[ "color", "#FFCDD2" ],
						[ "penwidth", 3 ]
					]
				],
				[
					"affectednodes",
					[ "rds" ]
				],
				[ "affectededges", [  ] ],
				[ "matchcount", 1 ]
			]
		]
	]
]
`

pf()

#--> #TODO #ERR check correctnes of "effects" string


/*---------------------------#
#  Security Zones
#---------------------------#

pr()

oDiag = new stzDiagram("SecurityArchitecture")

# Color by security zone
oPublic = new stzVisualRule("public_zone")
oPublic {
	When("zone", :equals = "public")
	ApplyColor("#FFE0B2")
}

oDmz = new stzVisualRule("dmz_zone")
oDmz {
	When("zone", :equals = "dmz")
	ApplyColor("#FFF59D")
}

oPrivate = new stzVisualRule("private_zone")
oPrivate {
	When("zone", :equals = "private")
	ApplyColor("#C8E6C9")
}

# Firewall edges
oFirewall = new stzVisualRule("firewall")
oFirewall {
	When("firewall", :equals = TRUE)
	ApplyStyle("bold")
	ApplyColor("#FF5722")
	ApplyPenWidth(3)
}

oDiag {

	SetTheme(:pro)
	SetLayout(:TopDown)
	
	# Rules

	SetVisualRule(oPublic)
	SetVisualRule(oDmz)
	SetVisualRule(oPrivate)
	SetVisualRule(oFirewall)
	
	# Nodes

	AddNodeXTT("internet", "Internet", [
		:tye = "start", :color = "info",
		:zone = "public"
	])

	AddNodeXTT("waf", "WAF", [
		:color = "process", :color = "warning",
		:zone = "dmz", :tags = [:security]
	])

	AddNodeXTT("lb", "Load Balancer", [
		:color = "process", :Primary,
		[:zone = "dmz"]
	])

	AddNodeXTT("web", "Web Tier", [
		:type = "process", :color = "primary",
		:zone = "private"
	])

	AddNodeXTT("app", "App Tier", [
		:type = "process", :color = "primary",
		:zone = "private"
	])

	AddNodeXTT("db", "Database", [
		:type = "storage", :color = "success",
		:zone = "private", :tags = [:encrypted]
	])
	
	# Edges

	AddEdgeXTT("internet", "waf", "443", [
		:firewall = TRUE
	])
	
	AddEdgeXTT("waf", "lb", "https",  [
		:firewall = TRUE
	])
	
	AddEdgeXTT("lb", "web", "internal", [
		:firewall = FALSE
	])
	
	AddEdgeXTT("web", "app", "api", [ 
		:firewall = TRUE
	])
	
	AddEdgeXTT("app", "db", "query",  [
		:firewall = TRUE
	])
	

	View()
	? @@NL( Explain() )
}
#-->
`
[
	[ "diagram", "SecurityArchitecture" ],
	[
		"structure",
		"Diagram 'SecurityArchitecture' contains 6 nodes and 5 edges."
	],
	[
		"rules",
		"Applied 4 visual rule(s): public_zone, dmz_zone, private_zone, firewall"
	],
	[ "effects", "No rules matched any elements." ]
]
`

pf()

/*---------------------------#
#  CI/CD Pipeline States
#---------------------------#

pr()

oDiag = new stzDiagram("DeploymentPipeline")

# Stage status coloring
oPassed = new stzVisualRule("passed")
oPassed {

	When(:last_run, :equals = "pass")
	UseColor("white")
	# Add UseColorXT("red++", "white") #TODO first is node background, the second is the color of the text

}

oFailed = new stzVisualRule("failed")
oFailed {
	When(:last_run, :Equals = "fail")
	UseColor("orange")
}

oRunning = new stzVisualRule("running")
oRunning {
	When(:last_run, :Equals = "running")
	UseColor("green")
	UsePenWidth(2)
}

# Critical stages
oCriticalStage = new stzVisualRule("critical_stage")
oCriticalStage {
	WhenTag("gate", :exists)
	ApplyShape("diamond")
}

oDiag {
	SetTheme(:LightGray)
	SetLayout(:TopDown)
	
	# Rules can be composed from exitant set of rules,
	# which is more accurade for clean design and reusable rules
	SetVisualRule(oPassed)
	SetVisualRule(oFailed)
	SetVisualRule(oRunning)
	SetVisualRule(oCriticalStage)
	
	#TODO// But rules should also be defined directly inside the diagram
	# object, which is more intuitive for quick and focused usage
#	When(:lastrun, :Equals = "pass")
#	UseColor("#4CAF50") # Allow resolving color name (like :red), semantic (like :Success)


	AddNodeXTT("commit", "Git Commit", [
		:type = "start",
		:color = "success",
		:last_run = "pass"
	])

	AddNodeXTT("build", "Build", [
		:type = "process",
		:color = "primary",
		:last_run = "pass",
		:duration_s = 120
	])
	
	AddNodeXTT("unit", "Unit Tests", [
		:type = "process",
		:color = "primary",
		:last_run = "running",
		:duration_s = 45
	])
	
	AddNodeXTT("security", "Security Scan", [
		:type = "decision",
		:color = "warning",
		:last_run = "pass",
		:issues = 0,
		:tags = ["gate"]
	])
	
	AddNodeXTT("deploy_stage", "Deploy Staging", [
		:type = "process",
		:color = "info",
		:last_run = "pass"
	])
	
	AddNodeXTT("integration", "Integration Tests", [
		:type = "process",
		:color = "primary",
		:last_run = "fail",
		:failed_tests = 3
	])
	
	AddNodeXTT("approval", "Manual Approval", [
		:type = "decision",
		:color = "warning",
		:last_run = "pass",
		:tags = [:gate]
	])
	
	AddNodeXTT("deploy_prod", "Deploy Production", [
		:type = "endpoint",
		:color = "success",
		:last_run = "pass"
	])
	
	Connect("commit", "build")
	Connect("build", "unit")
	Connect("unit", "security")
	Connect("security", "deploy_stage")
	Connect("deploy_stage", "integration")
	Connect("integration", "approval")
	Connect("approval", "deploy_prod")
	
	View()
}

pf()

#=============================#
#  DIAGRAM IMPORT & EDITING   #
#=============================#

/*-- Basic Import on Empty Diagram

pr()

oDiag = new stzDiagram("MainFlow")

cImported = '
diagram "ProcessFlow"

metadata
    theme: pro
    layout: topdown

nodes
    start
        label: "Begin"
        type: start
        color: green+

    process
        label: "Work"
        type: process
        color: blue+

    end
        label: "Finish"
        type: endpoint
	color: orange
edges
    start -> process
    process -> end
'

oDiag.ImportDiag(cImported)
? oDiag.Code() + NL
? oDiag.NodeCount()
#--> 3

? oDiag.EdgeCount()
#--> 2

? oDiag.View()

pf()
#--> Executed in 0.05 second(s) in Ring 1.24

#=============================#
#  SEMANTIC COLOR IMPORT      #
#=============================#

/*-- Import Diagram with Semantic Colors

pr()

oDiag = new stzDiagram("MainFlow")

cImported = '
diagram "ProcessFlow"

metadata
    theme: pro
    layout: topdown

nodes
    start
        label: "Begin"
        type: start
        color: success

    process
        label: "Work"
        type: process
        color: primary

    validate
        label: "Work"
        type: danger
        color: danger+

    end
        label: "Finish"
        type: endpoint
        color: success

edges
    start -> process
    process -> validate
    validate -> end
'

oDiag.ImportDiag(cImported)
oDiag.Show()
oDiag.View()

#-->
'
        ╭───────╮        
        │ Begin │        
        ╰───────╯        
            |            
            v            
       ╭────────╮        
       │ !Work! │        
       ╰────────╯        
            |            
            v            
       ╭────────╮        
       │ !Work! │        
       ╰────────╯        
            |            
            v            
       ╭────────╮        
       │ Finish │        
       ╰────────╯   
'

pf()
#--> Executed in 0.08 second(s) in Ring 1.24

/*-- Import as Subdiagram

pr()

oDiag = new stzDiagram("MainFlow")

oDiag.AddNodeXTT("start", "Main Start", [
	:type = "start", :color = "success"
])

oDiag.AddNodeXTT("main", "Main Process", [
	:type = "process", :color = "primary"
])

oDiag.Connect("start", "main")

# Diagram before import (note how it contains a "Main Process" node
oDiag.Show()
#-->
'
     ╭────────────╮      
     │ Main Start │      
     ╰────────────╯      
            |            
            v            
    ╭──────────────╮     
    │ Main Process │     
    ╰──────────────╯  
'

# The stzdiag string to be imported (node that it starts with a "Main Process" node

cSubFlow = '
diagram "SubFlow"

nodes
    main
        label: "Main Process"
        type: process
        color: #0000FF

    sub1
        label: "Sub Task 1"
        type: process
        color: #FFA500

    sub2
        label: "Sub Task 2"
        type: process
        color: #FFA500

    result
        label: "Result"
        type: endpoint
        color: #008000

edges
    main -> sub1
    main -> sub2
    sub1 -> result
    sub2 -> result
'

# The import will incrust the subflow in the common "Main Process" node

oDiag.ImportDiag(cSubFlow)
? oDiag.NodeCount()
#--> 5 (start, main, sub1, sub2, result)

? oDiag.HasNode("sub1")
#--> TRUE

? oDiag.Code()

# Let's visuaise the actual diagram (not view() ~> image vs show() ~> ascii from stzGraph)
oDiag.View()

pf()
#--> Executed in 0.06 second(s) in Ring 1.24

/*-- Import Error - Missing Connection Node

pr()

oDiag = new stzDiagram("MainFlow")
oDiag.AddNodeXT("start", "Begin", :start, :success)

cBadImport = '
diagram "BadFlow"

nodes
    process
        label: "Work"
        type: process
        color: #0000FF

    end
        label: "Finish"
        type: endpoint
        color: #008000

edges
    process -> end
'

oDiag.ImportDiag(cBadImport)
#--> ERROR MESSAGE:
# Import failed: First node 'process' not found in current diagram.
# Either add node 'process' first, or clear the diagram with RemoveAllNodes()

pf()
#--> Executed in 0.03 second(s) in Ring 1.24

#========================#
#  NODE REMOVAL          #
#========================#

/*-- Remove Single Node

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXTT("n1", "Node 1", [ :color = "process", :color = "blue" ])
oDiag.AddNodeXTT("n2", "Node 2", [ :color = "process", :color = "blue" ])
oDiag.AddNodeXTT("n3", "Node 3", [ :color = "process", :color = "blue" ])

oDiag.Connect("n1", "n2")
oDiag.Connect("n2", "n3")

? oDiag.NodeCount()
#--> 3
? oDiag.EdgeCount()
#--> 2


oDiag.Show()
#-->
'
       ╭────────╮        
       │ Node 1 │        
       ╰────────╯        
            |            
            v            
      ╭──────────╮       
      │ !Node 2! │       
      ╰──────────╯       
            |            
            v            
       ╭────────╮        
       │ Node 3 │        
       ╰────────╯ 
'

? NL + "------------" + NL + NL

oDiag.RemoveNode("n2")

? oDiag.NodeCount()
#--> 2
? oDiag.EdgeCount()
#--> 0 (both edges removed)

oDiag.Show()
#-->
'
       ╭────────╮        
       │ Node 1 │        
       ╰────────╯        

          ////

       ╭────────╮        
       │ Node 3 │        
       ╰────────╯ 
'

pf()
#--> Executed in 0.04 second(s) in Ring 1.24

/*-- Remove Multiple Nodes

pr()

oDiag = new stzDiagram("Test")

oDiag.AddNodeXTT("n1", "Node 1", [ :color = "process", :color = "blue" ])
oDiag.AddNodeXTT("n2", "Node 2", [ :color = "process", :color = "blue" ])
oDiag.AddNodeXTT("n3", "Node 3", [ :color = "process", :color = "blue" ])
oDiag.AddNodeXTT("n4", "Node 4", [ :color = "process", :color = "blue" ])

oDiag.Connect("n1", "n2")
oDiag.Connect("n3", "n4")
oDiag.show()
#♦-->
'
       ╭────────╮        
       │ Node 1 │        
       ╰────────╯        
            |            
            v            
       ╭────────╮        
       │ Node 2 │        
       ╰────────╯        

          ////

       ╭────────╮        
       │ Node 3 │        
       ╰────────╯        
            |            
            v            
       ╭────────╮        
       │ Node 4 │        
       ╰────────╯ 
'

? NL + "-----------" + NL + NL

oDiag.RemoveTheseNodes(["n2", "n4"])

? oDiag.NodeCount()
#--> 2

oDiag.Show()
#-->
'
       ╭────────╮        
       │ Node 1 │        
       ╰────────╯        

          ////

       ╭────────╮        
       │ Node 3 │        
       ╰────────╯ 
'

pf()
#--> Executed in 0.03 second(s) in Ring 1.24

/*--

pr()

? keys([ [ "color", "process" ], [ "color", "blue" ], [ "priority", "high" ] ])
#--> Incorrect param type! paList must be a hashlist.
#~> Because "color" is used twice as a key.

pf()

/*-- Clear All Nodes

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n2", "Node 2", [ :type = "decision", :color = "green", :unit = "sales" ])

oDiag.Connect("n1", "n2")
oDiag.SetNodeProp("n1", :priority, "high")

? @@( oDiag.NodeProps("n1") ) + NL
#--> [ "type", "color", "priority" ]

? @@( oDiag.NodePropsXT("n1") ) + NL
#--> [ "type", "color", "priority" ]

? @@(oDiag.Props()) + NL
#--> [ "type", "color", "priority", "unit" ]

? @@NL(oDiag.PropsXT()) + NL
#-->
'
[
	[ "type", [ "process" ] ],
	[ "color", [ "blue" ] ],
	[ "priority", [ "high" ] ],
	[ "unit", [ "sales" ] ]
]
'

oDiag.RemoveAllNodes()

? oDiag.NodeCount()
#--> 0
? oDiag.EdgeCount()
#--> 0

pf()

#--> Executed in 0.02 second(s) in Ring 1.24

/*-- Replace Node with Edge Preservation
*/
pr()

oDiag = new stzDiagram("Test")

oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("old", "Old Node", [ :type = "process", :color = "yellow" ])
oDiag.AddNodeXTT("n3", "Node 3", [ :type = "process", :color = "blue" ])

oDiag.Connect("n1", "old")
oDiag.Connect("old", "n3")

oDiag.ReplaceNode("old", "new", "New Node")

? oDiag.HasNode("old")
#--> FALSE
? oDiag.HasNode("new")
#--> TRUE
? oDiag.EdgeCount()
#--> 2 (edges preserved with new node)

pf()
#--> Executed in 0.04 second(s) in Ring 1.24

#========================#
#  METADATA OPERATIONS   #
#========================#

/*-- Set and Get Node Metadata

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXT("task", "Task", :process, :blue)

oDiag.SetNodeMetadata("task", [
    :priority = "high",
    :owner = "Alice",
    :duration = 120
])

aMeta = oDiag.GetNodeMetadata("task")
? aMeta[:priority]
#--> high
? aMeta[:owner]
#--> Alice

pf()
#--> Executed in 0.03 second(s) in Ring 1.24

/*-- Update Node Metadata

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXT("task", "Task", :process, :blue)

oDiag.SetNodeMetadata("task", [:priority = "low"])
oDiag.UpdateNodeMetadata("task", "priority", "critical")
oDiag.UpdateNodeMetadata("task", "status", "active")

aMeta = oDiag.GetNodeMetadata("task")
? aMeta[:priority]
#--> critical
? aMeta[:status]
#--> active

pf()
#--> Executed in 0.03 second(s) in Ring 1.24

/*-- Edge Metadata Operations

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXT("n1", "Node 1", :process, :blue)
oDiag.AddNodeXT("n2", "Node 2", :process, :blue)
oDiag.Connect("n1", "n2")

oDiag.SetEdgeMetadata("n1", "n2", [
    :type = "data_flow",
    :bandwidth = "high",
    :encrypted = TRUE
])

aMeta = oDiag.GetEdgeMetadata("n1", "n2")
? aMeta[:type]
#--> data_flow
? aMeta[:encrypted]
#--> TRUE

pf()
#--> Executed in 0.03 second(s) in Ring 1.24

/*-- Remove Metadata

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXT("n1", "Node 1", :process, :blue)
oDiag.SetNodeMetadata("n1", [:key = "value"])

? len(oDiag.GetNodeMetadata("n1"))
#--> 1

oDiag.RemoveNodeMetadata("n1")

? len(oDiag.GetNodeMetadata("n1"))
#--> 0

pf()
#--> Executed in 0.02 second(s) in Ring 1.24

#================================#
#  COMBINED OPERATIONS           #
#================================#

/*-- Build, Edit, Import, and Visualize

pr()

# Build initial diagram
oDiag = new stzDiagram("PaymentFlow")
oDiag.SetTheme(:pro)
oDiag.AddNodeXT("start", "Request", :start, :success)
oDiag.AddNodeXT("validate", "Validate", :decision, :warning)
oDiag.AddNodeXT("approved", "Approved", :endpoint, :success)
oDiag.Connect("start", "validate")
oDiag.Connect("validate", "approved")

# Add metadata
oDiag.SetNodeMetadata("validate", [
    :rule = "amount < 10000",
    :approver = "system"
])

# Import subflow for manual approval
cManualFlow = '
diagram "ManualApproval"

nodes
    validate
        label: "Validate"
        type: decision
        color: #FFFF00

    manual
        label: "Manual Review"
        type: process
        color: #FFA500

    manager
        label: "Manager Approval"
        type: decision
        color: #FFFF00

    approved
        label: "Approved"
        type: endpoint
        color: #008000

edges
    validate -> manual
    manual -> manager
    manager -> approved
'

oDiag.ImportDiag(cManualFlow)

? oDiag.NodeCount()
#--> 5 (start, validate, manual, manager, approved)

? oDiag.HasNode("manager")
#--> TRUE

# Update metadata
oDiag.UpdateNodeMetadata("validate", "approver", "system+manual")

# Visualize
oDiag.Show()

pf()
#--> Executed in 0.15 second(s) in Ring 1.24
