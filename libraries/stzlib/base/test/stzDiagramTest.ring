load "../stzbase.ring"

#---------------------------------#
#  TEST FILE OF STZDIAGRAM CLASS  #
#---------------------------------#

#NOTE
# Softanza enhances DOT/Graphviz in several ways:
# 1. Forces layout respect: Graphviz ignores rankdir for disconnected nodes.
#    Softanza adds invisible edges to enforce TopDown/LeftRight layouts.
# 2. Smart defaults: Black edges (not blue), TopDown orientation (not LeftRight).
# 3. Intuitive behavior: Diagrams "just work" without needing Graphviz expertise.


/*--- Simple diagram without edges

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

/*--- Creating nodes in sequence

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

/*--- Creating nodes in sequence with lablels

pr()

oDiag = new stzDiagram("SequenceDemoXT")
oDiag {
	SetLayout("TB")
	SetEdgeStyle(:Normal)
	
	AddNodeXTT(:@Free, "Free", [ :type = "process", :color = "gray" ])
	AddNodeXTT(:@Basic, "Basic", [ :type = "process", :color = "primary" ])
	AddNodeXTT(:@Pro, "Pro", [ :type = "process", :color = "warning" ])
	AddNodeXTT(:@Enterprise, "Enterprise", [ :type = "process", :color = "success" ])
	
	# Sequence with labels between nodes
	ConnectSequenceXT([
		:@Free,
		"Upgrade",
		:@Basic,
		"Upgrade",
		:@Pro,
		"Upgrade",
		:@Enterprise
	])
	
	View()
}

pf()
# Executed in 0.61 second(s) in Ring 1.25

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
	AddNoteXTT(:@Node24, "Note", [ :type = "yellow" ])

	View()
}

pf()

/*--- Like in stzGraph, three levels are allowed: AddNode(), AddNodeXT() and AddNodeXTT()

pr()

o1 = new stzDiagram("")
o1 {
	SetTitle("HELLO TITLE")
	SetSubtitle("Curved Splines")

	SetSplines("curved") # or spline, ortho, polyline, line
	AddNode("a")
	AddNodeXT("b", "pass")
	AddNodeXTT("c", "end", [ :type = "endpoint", :color = "green" ]) 
	Connect("a", "b")
	ConnectXT("a", "c", "focus")
	View()
	? Code()
}
#-->
`
digraph "" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=curved, nodesep=0.60, ranksep=0.80, ordering=out]
    labelloc="t";
    label="
HELLO TITLE
Curved Splines


";
    fontsize=16;

    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#000000", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    a [label="a", shape=box, style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black"]
    b [label="pass", shape=box, style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black"]
    c [label="end", shape=doublecircle, style="solid,filled", fillcolor="#008000", fontcolor="white"]

    a -> b
    a -> c [label="focus"]

}
`

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

/*---

pr()

oDiag = new stzDiagram("ColorSystemTest")
oDiag {
	SetTheme("pro")
	SetPenWidth(2)

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
	
	View()
}

pf()
#--> Executed in 0.70 second(s) in Ring 1.25


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
# Executed in 0.53 second(s) in Ring 1.25

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
# Executed in 0.03 second(s) in Ring 1.24

/*--- Adding performance properties to nodes

pr()

oDiag = new stzDiagram("Annotated")
oDiag.AddNodeXTT("process", "Process", [ :type = "process", :color = "primary" ])

oPerf = new stzDiagramAnnotator(:Performance)
oPerf.Annotate("process", ["latency" = 150, "unit" = "ms"])

oDiag.AddAnnotation(oPerf)

? len(oDiag.Annotations()) #--> 1
? len(oPerf.NodesData()) #--> 1

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Retrieving annotations by type

pr()

oDiag = new stzDiagram("AnnotationTypes")
oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "primary" ])

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
# Executed in 0.03 second(s) in Ring 1.25

#--------------------------------#
#  ORGANIZING NODES IN CLUSTERS  #
#--------------------------------#

/*--- Grouping nodes into logical domains

pr()

oDiag = new stzDiagram("Clustered")

odiag.setTheme("light")
oDiag.AddNodeXTT("user_api", "User API", [ :type = "process", :color = "success" ])
oDiag.AddNodeXTT("user_db", "User DB", [ :type = "storage", :color = "success" ])
oDiag.AddNodeXTT("order_api", "Order API", [ :type = "process", :color = "info" ])
oDiag.AddNodeXTT("order_db", "Order DB", [ :tyoe = "storage", :color = "info" ])

oDiag.AddClusterXTT("users", "User Domain", ["user_api", "user_db"], :LightGreen)
oDiag.AddClusterXTT("orders", "Order Domain", ["order_api", "order_db"], :Lightblue)

oDiag.View()
? len(oDiag.Clusters()) #--> 2

pf()
# Executed in 0.54 second(s) in Ring 1.25

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
# Executed in 0.03 second(s) in Ring 1.25

#--------------#
#  SET THEMES  #
#--------------#

/*--- Testing different theme configurations

pr()

o1 = new stzDiagram("")
o1 {
	SetSplines("curved") # or spline, ortho, polyline, line
	AddNode("a")
	AddNodeXT("b", "pass")
	AddNodeXTT("c", "end", [ :type = "endpoint", :color = "green" ]) 
	Connect("a", "b")
	ConnectXT("a", "c", "focus")

	SetTheme(:dark) # Test with :light or :pro or :neutral...
	? Theme() #--> dark
	View()
}

pf()
# Executed in 0.52 second(s) in Ring 1.25

#--------------#
#  SET LAYOUT  #
#--------------#

/*--- Testing different layout configurations

pr()

o1 = new stzDiagram("")
o1 {
	AddNode("a")
	AddNodeXT("b", "pass")
	AddNodeXTT("c", "end", [ :type = "endpoint", :color = "green" ]) 
	Connect("a", "b")
	ConnectXT("a", "c", "focus")

	SetLayout(:LeftRight) # Try with :LeftRight
	SetSplines("spline") # or curved, ortho, polyline, line

	View()
}

pf()
# Executed in 0.60 second(s) in Ring 1.25

#---------------------------#
#  EXPORT TO OTHER FORMATS  #
#---------------------------#

/*--- Converting diagram to hashlist representation

pr()

oDiag = new stzDiagram("HashlistExport")
oDiag.SetTheme(:pro)
oDiag.AddNodeXT("n1", "Node")

? @@NL( oDiag.ToHashlist() )
#--> [
# 	[ "id", "HashlistExport" ],
# 	[
# 		"nodes",
# 		[
# 			[
# 				[ "id", "n1" ],
# 				[ "label", "Node" ],
# 				[ "properties", [  ] ]
# 			]
# 		]
# 	],
# 	[ "edges", [  ] ],
# 	[ "properties", [  ] ],
# 	[ "theme", "pro" ],
# 	[ "layout", "topdown" ],
# 	[ "clusters", [  ] ],
# 	[ "annotations", [  ] ],
# 	[ "templates", [  ] ]
# ]


pf()
# Executed in 0.02 second(s) in Ring 1.25

/*--- Generating .stzdiag native text format

pr()

oDiag = new stzDiagram("FormatTest")
oDiag.SetTheme(:pro)
oDiag.SetLayout(:TopDown)
oDiag.AddNodeXTT("start", "Begin", [ :type = "start", :color = "success-" ])
oDiag.AddNodeXTT("process", "Work", [ :type = "process", :color = "primary+" ])
oDiag.AddNodeXTT("end", "Finish", [ :type = "endpoint", :color = "success" ])
oDiag.Connect("start", "process")
oDiag.Connect("process", "end")

? oDiag.stzdiag()
#-->
'
diagram "FormatTest"

properties
    theme: pro
    layout: topdown

nodes
    start
        label: "Begin"
        type: start
        color: success-

    process
        label: "Work"
        type: process
        color: primary+

    end
        label: "Finish"
        type: endpoint
        color: success

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
# Executed in 0.49 second(s) in Ring 1.25

/*--- Saving diagram to .stzdiagram file

pr()

oDiag = new stzDiagram("simple")
? oDiag.Name()
#--> sample

oDiag.AddNodeXTT("a", "Node A", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("b", "Node B", [ :type = "process", :color = "primary" ])
oDiag.ConnectXT("a", "b", "flows")

? oDiag.SaveInFolder("txtfiles") # or SaveToFile() without param to save it in current folder
? read("txtfiles/" + oDiag.Name() + ".stzdiag") #--> TRUE
#-->
'
diagram "SaveTest"

properties
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
# Executed in 0.05 second(s) in Ring 1.25

/*--- Converting diagram with cluster definitions

pr()

oDiag = new stzDiagram("ClusterTest")
oDiag.AddNodeXTT("api", "API", [ :type = "process", :color = "success" ])
oDiag.AddNodeXTT("db", "DB", [ :type = "storage", :color = "success" ])
oDiag.AddClusterXTT("domain", "Service Domain", ["api", "db"], "lightblue")

? oDiag.stzdiag()
#-->
'
diagram "ClusterTest"

properties
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
# Executed in 1.10 second(s) in Ring 1.25

/*--- Converting diagram with annotations

pr()

oDiag = new stzDiagram("AnnotationTest")
oDiag.AddNodeXTT("process", "MyProcess", [ :type = "process", :color = "primary" ])

oPerf = new stzDiagramAnnotator(:Performance)
oPerf.Annotate("process", ["latency" = 150])
oDiag.AddAnnotation(oPerf)

? oDiag.stzdiag()
#-->
'
diagram "annotationtest"

properties
    theme: light
    layout: topdown

nodes
    process
        label: "MyProcess"
        type: process
        color: primary

annotations
    performance
        process: null
'

pf()

/*--- Converting to Graphviz DOT language

pr()

oDiag = new stzDiagram("DotTest")
? oDiag.theme()

oDiag.AddNodeXTT("start", "Start", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("end", "End", [ :type = "endpoint", :color = "success" ])
oDiag.Connect("start", "end")

? @@NL( oDiag.ToHashList() ) + NL

//oDiag.View()
#-->
'
diagram "DotTest"

properties
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

/*--- Saving to DOT file

pr()

oDiag = new stzDiagram("simple")
oDiag.AddNodeXTT("a", "Node A", [ :type = "procesd", :Color = "white" ])
oDiag.AddNodeXTT("b", "Node B", [ :type = "process", :Color = "white" ])
oDiag.Connect("a", "b")

if  oDiag.SaveDotInFolder("txtfiles")
	? read("txtfiles/simple.dot")
ok
#-->
'
digraph "simple" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=0.60, ranksep=0.80, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#000000", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    a [label="Node_A", shape=box, style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black"]
    b [label="Node_B", shape=box, style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black"]

    a -> b

}
'

pf()
# Executed in 0.06 second(s) in Ring 1.25

/*--- Verifying DOT node type shapes

pr()

oDiag = new stzDiagram("DotShapesTest")
oDiag.SetTheme("vibrant")
oDiag.AddNodeXTT("s", "Node S", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("d", "Node D", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("p", "Node P", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("e", "Node E", [ :type = "endpoint", :color = "success" ])

? oDiag.Dot()
#-->
'
digraph "dotshapestest" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=0.60, ranksep=0.80, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#000000", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    s [label="Node_S", shape=ellipse, style="solid,filled", fillcolor="#008000", fontcolor="white"]
    d [label="Node_D", shape=diamond, style="solid,filled", fillcolor="#FFA500", fontcolor="black"]
    p [label="Node_P", shape=box, style="rounded,solid,filled", fillcolor="#0000FF", fontcolor="white"]
    e [label="Node_E", shape=doublecircle, style="solid,filled", fillcolor="#008000", fontcolor="white"]

    s -> d [style=invis]
    d -> p [style=invis]
    p -> e [style=invis]

}
'

pf()
# Executed in 0.04 second(s) in Ring 1.25

/*--- Converting to Mermaid.js syntax

pr()

oDiag = new stzDiagram("MermaidTest")
oDiag.AddNodeXTT("start", "Start", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("decision", "Check", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("process", "Process", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("end", "End", [ :type = "endpoint", :color = "success" ])

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
# Executed in 0.06 second(s) in Ring 1.25

/*--- Saving to Mermaid file

pr()

oDiag = new stzDiagram("simple")
oDiag.AddNodeXTT("start", "Start", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("decision", "Check", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("process", "Process", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("end", "End", [ :type = "endpoint", :color = "success" ])

oDiag.Connect("start", "decision")
oDiag.ConnectXT("decision", "process", "Yes")
oDiag.Connect("process", "end")

if oDiag.WriteToMermaidInFolder("txtfiles")
	? read("txtfiles/simple.mmd")
ok

#-->
'
graph TD
    a[["A"]]
    b[["B"]]

    a --> b |leads|
'

pf()

/*--- Verifying Mermaid node type shapes

pr()

oDiag = new stzDiagram("MermaidShapesTest")
oDiag.AddNodeXTT("s", "Node S", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("d", "Node D", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("e", "Node E", [ :type = "endpoint", :color = "success" ])

? oDiag.Mermaid()
#-->
'
graph TD
    s(["Node_S"])
    d{{"Node_D"}}
    e(["Node_E"])
'

pf()

/*--- Converting to JSON format

pr()

oDiag = new stzDiagram("JsonTest")
oDiag.SetTheme(:pro)
oDiag.AddNodeXTT("a", "NodeA", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("b", "NodeB", [ :type = "process", :color = "primary" ])
oDiag.Connect("a", "b")

? oDiag.Json()
#-->
'
{
	"id": "jsontest",
	"nodes": [
		{
			"id": "a",
			"label": "NodeA",
			"properties": {
				"type": "process",
				"color": "primary"
			}
		},
		{
			"id": "b",
			"label": "NodeB",
			"properties": {
				"type": "process",
				"color": "primary"
			}
		}
	],
	"edges": [
		{
			"from": "a",
			"to": "b",
			"label": "",
			"properties": {

			}
		}
	],
	"properties": [
		"type",
		"color"
	],
	"theme": "pro",
	"layout": "topdown",
	"clusters": {

	},
	"annotations": {

	},
	"templates": {

	}
}
'

pf()
# Executed in 0.03 second(s) in Ring 1.25

/*--- Saving to JSON file

pr()

oDiag = new stzDiagram("simple")
oDiag.AddNodeXTT("x", "X Node", [ :type = "process", :color = "primary" ])

if oDiag.WriteToJsonInFolder("txtfiles")
	? read("txtfiles/simple.json")
ok
'
{
	"id": "simple",
	"nodes": [
		{
			"id": "x",
			"label": "X_Node",
			"properties": {
				"type": "process",
				"color": "primary"
			}
		}
	],
	"edges": {

	},
	"properties": [
		"type",
		"color"
	],
	"theme": "pro",
	"layout": "topdown",
	"clusters": {

	},
	"annotations": {

	},
	"templates": {

	}
}
'

pf()
# Executed in 0.03 second(s) in Ring 1.25

/*--- Verifying JSON structure fields

pr()

oDiag = new stzDiagram("JsonStructureTest")
oDiag.AddNodeXTT("n", "Node", [ :type = "process", :color = "primary" ])

? oDiag.Json()
#-->
`
{
	"id": "jsonstructuretest",
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
	"edges": {

	},
	"properties": [
		"type",
		"color"
	],
	"theme": "pro",
	"layout": "topdown",
	"clusters": {

	},
	"annotations": {

	},
	"templates": {

	}
}
`

pf()
# Executed in 0.03 second(s) in Ring 1.25

/*--- Verifying edge labels in all formats

pr()

oDiag = new stzDiagram("EdgeLabelTest")
oDiag.AddNodeXTT("a", "A", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("b", "B", [ :type = "process", :color = "primary" ])
oDiag.ConnectXT("a", "b", "important")

cStzOutput = oDiag.stzdiag()
cDotOutput = odiag.dot()
cMermaidOutput = oDiag.mermaid()

? contains(cStzOutput, "important")
#--> TRUE

? contains(cDotOutput, "important")
#--> TRUE

? contains(cMermaidOutput, "important")
#--> TRUE

pf()
# Executed in 0.03 second(s) in Ring 1.25

#-------------------------#
# TESTING VISUAL OPTIONS  #
#-------------------------#

/*-- Layout variations

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

/*-- Edge style variations

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

/*-- Node type variations

pr()

oDiag = new stzDiagram("ShapeTest")
oDiag {
	SetTheme(:pro)
	SetLayout(:TopDown)
	
	# Semantic types (shape auto-selected)
	AddNodeXTT("start", "Start", [ :type = "start", :color = "success" ])
	AddNodeXTT("validate", "Validate", [ :type = "process", :color = "primary" ])
	AddNodeXTT("check", "Valid?", [ :type = "decision", :color = "warning" ])
	AddNodeXTT("done", "Done", [ :type = "endpoint", :color = "success" ])
	
	# Direct DOT shapes (explicit control)
	AddNodeXTT("db", "Database", [ :type = "cylinder", :color = "neutral+" ]) # Note how we made neutral a bit darker with +
	AddNodeXTT("alert", "Alert", [ :type = "hexagon", :color = "danger" ])
	AddNodeXTT("backup", "Backup", [ :type = "parallelogram", :color = "info" ])
	AddNodeXTT("end", "End", [ :type = "octagon", :color = "success" ])
	
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
# Executed in 0.65 second(s) in Ring 1.25

/*-- Theme variations

pr()

# Supported thems: light, dark, vibrant, pro, access,
# print, gray, lightgray, darkgray

o1 = new stzDiagram("ThemeTest")
o1 {
	SetTheme(:light)
	SetLayout(:RightLeft)
	SetNodeStrokeColor("navy")
	
	AddNodeXTT("x", "Alpha", [ :type = "start", :color = "success" ])
	AddNodeXTT("y", "Beta", [ :type = "process", :color = "primary" ])
	AddNodeXTT("z", "Gamma", [ :type = "endpoint", :color = "primary" ])
	
	Connect("x", "y")
	Connect("y", "z")
	
	? Dot()
	View()
}
#-->
`
digraph "themetest" {
    graph [rankdir=RL, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=0.60, ranksep=0.80, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#000000", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    x [label="Alpha", shape=ellipse, style="solid,filled", fillcolor="#4D654D", fontcolor="white", color="#008000"]
    y [label="Beta", shape=box, style="rounded,solid,filled", fillcolor="#4D4DC9", fontcolor="white", color="#008000"]
    z [label="Gamma", shape=doublecircle, style="solid,filled", fillcolor="#4D4DC9", fontcolor="white", color="#008000"]

    x -> y
    y -> z

}
`

pf()
# Executed in 0.61 second(s) in Ring 1.25

/*--- Generating the diagram image in all the supported themes

pr()

# Test all themes with semantic colors
acThemes = [ "neutral", "light", "dark", "vibrant", "pro",
	     "access", "print", "gray", "lightgray", "darkgray"]

for cTheme in acThemes
	oDiag = new stzDiagram("Theme_" + cTheme)
	oDiag {
		SetTheme(cTheme)
		SetLayout(:LeftRight)
		SetTitle("THEME " + UPPER(cTheme))

		# All semantic color types
		AddNodeXTT("s", "Start", [ :type = "start", :color = "success" ])
		AddNodeXTT("p1", "Process", [ :type = "process", :color = "primary" ])
		AddNodeXTT("w", "Warning", [ :type = "decision", :color = "warning" ])
		AddNodeXTT("d", "Danger", [ :type = "process", :color = "danger" ])
		AddNodeXTT("i", "Info", [ :type = "storage", :color = "info" ])
		AddNodeXTT("n", "Neutral", [ :type = "process", :color = "neutral" ])
		AddNodeXTT("e", "End", [ :type = "endpoint", :color = "success" ])
		
		Connect("s", "p1")
		Connect("p1", "w")
		ConnectXT("w", "d", "Yes")
		ConnectXT("w", "i", "No")
		Connect("d", "n")
		Connect("i", "n")
		Connect("n", "e")
		
		? "Theme: " + cTheme
		View()
	}
next

pf()
# Executed in 6.67 second(s) in Ring 1.25
# Executed in 12.69 second(s) in Ring 1.24

/*-- Combined options

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

/*-- Color resolution

pr()

oDiag6 = new stzDiagram("ColorTest")
oDiag6 {
	SetTheme(:vibrant)
	
	# Symbolic colors from palette
	AddNodeXTT("n1", "Success", [ :type = "process", :color = "success" ])
	AddNodeXTT("n2", "Warning", [ :type = "process", :color = "warning" ])
	AddNodeXTT("n3", "Danger", [ :type = "process", :color = "danger" ])
	
	# Direct color names
	AddNodeXTT("n4", "Blue", [ :type = "process", :color = "lightblue" ])
	AddNodeXTT("n5", "Green", [ :type = "process", :color = "lightgreen" ])
	
	# Hex colors
	AddNodeXTT("n6", "Custom", [ :type = "process", :color = "#FF9900" ])
	
	Connect("n1", "n2")
	Connect("n2", "n3")
	Connect("n3", "n4")
	Connect("n4", "n5")
	Connect("n5", "n6")
	
	View()
}

pf()
# Executed in 0.66 second(s) in Ring 1.25

#----------------#
#  FONT EXAMPLE  #
#----------------#

pr()

oDiag = new stzDiagram("FontTest")
oDiag {

	SetFont("helvetica")
	SetFontSize(24)

	AddNodeXTT("n1", "Custom Font", [ :type = "start", :color = "success" ])
	AddNodeXTT("n2", "Arial 24pt", [ :type = "process", :color = "primary" ])
	ConnectXT("n1", "n2", "size")
	? Code()
	View()
}

pf()
# Executed in 0.46 second(s) in Ring 1.25
# Executed in 0.72 second(s) in Ring 1.24

#-----------------------------------#
#  CONFIGURING THE DIAGRAM TOOLTIP  #
#-----------------------------------#

pr()

o1 = new stzDiagram("Sales")
o1 {

    AddNodeXTT("a", "Marketing", [ 
        :type = "process", 
        :color = "blue",
        :Department = "Sales",
        :Budget = "$50K"
    ])
    
    AddNodeXTT("b", "Operations", [ 
        :type = "process",
        :color = "green",
        :Department = "Ops",
        :Budget = "$100K"
    ])
    
    Connect("a", "b")
    ? Code()

    SetTooltip([ :NodeId, :Type, :Color, :Department, :Budget ])
    // DisableTooltip() # Or SetTooltip("")
    View()
}


# This will show tooltips on hover like:
`
ID: a
Type: process
Color: blue
Department: Sales
Budget: $50K
`

pf()
# Executed in 0.52 second(s) in Ring 1.25
# Executed in 0.60 second(s) in Ring 1.24

#=============================#
#  DIAGRAM IMPORT & EDITING   #
#=============================#

/*-- Basic Import on Empty Diagram

pr()

oDiag = new stzDiagram("MainFlow")

cImported = '
diagram "ProcessFlow"

properties
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
#--> Executed in 0.58 second(s) in Ring 1.25

/*-- Import Diagram with Semantic Colors

pr()

oDiag = new stzDiagram("MainFlow")

cImported = '
diagram "ProcessFlow"

properties
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
#--> Executed in 0.62 second(s) in Ring 1.25

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
#--> Executed in 0.67 second(s) in Ring 1.25

/*-- Import Error - Missing Connection Node

pr()

oDiag = new stzDiagram("MainFlow")
oDiag.AddNodeXTT("start", "Begin", [ :type = "start", :color = "success" ])

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
# Either add node 'process', or clear the diagram with RemoveAllNodes()

pf()
#--> Executed in 0.03 second(s) in Ring 1.24

#================#
#  NODE REMOVAL  #
#================#

/*-- Remove Single Node

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n2", "Node 2", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n3", "Node 3", [ :type = "process", :color = "blue" ])

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
#--> Executed in 0.06 second(s) in Ring 1.25

/*-- Remove Multiple Nodes

pr()

oDiag = new stzDiagram("Test")

oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n2", "Node 2", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n3", "Node 3", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n4", "Node 4", [ :type = "process", :color = "blue" ])

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
#--> Executed in 0.07 second(s) in Ring 1.25

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

#====================================#
#  PROPERTIES OPERATIONS (METADATA)  #
#====================================#

/*-- Set and Get Node properties

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXTT("task", "Task", [ :type = "process", :color = "blue" ])

oDiag.SetNodeProperties("task", [
    :priority = "high",
    :owner = "Alice",
    :duration = 120
])

? @@NL( oDiag.NodePropertiesXT("task") )
#--> [
# 	[ "type", "process" ],
# 	[ "color", "blue" ],
# 	[ "priority", "high" ],
# 	[ "owner", "Alice" ],
# 	[ "duration", 120 ]
# ]

pf()
#--> Executed in 0.02 second(s) in Ring 1.25

/*-- Update Node properties

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXTT("task", "Task", [ :type = "process", :color = "blue" ])

oDiag.SetNodeProp(:task, :priority, "low")
oDiag.UpdateNodeProp(:task, :priority, "critical")
oDiag.UpdateNodeProp(:task, :status, "active")

aMeta = oDiag.NodePropsXT(:task)

? aMeta[:priority]
#--> critical
? aMeta[:status]
#--> active

pf()
#--> Executed in 0.02 second(s) in Ring 1.25

/*-- Edge properties Operations

pr()

oDiag = new stzDiagram("Test")

oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n2", "Node 2", [ :type = "process", :color = "blue" ])
oDiag.Connect("n1", "n2")

oDiag.SetEdgeProps("n1", "n2", [
    :type = "data_flow",
    :bandwidth = "high",
    :encrypted = TRUE
])

aMeta = oDiag.EdgePropsXT("n1", "n2")
? aMeta[:type]
#--> data_flow
? aMeta[:encrypted]
#--> TRUE

pf()
#--> Executed in 0.03 second(s) in Ring 1.24

/*-- Remove properties

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "blue" ])
oDiag.SetNodeProps("n1", [:key = "value"])

? @@(oDiag.NodeProps("n1"))
#--> [ "type", "color", "key" ]

oDiag.RemoveNodeProps("n1")

? @@(oDiag.NodeProps("n1"))
#--> []

pf()
#--> Executed in 0.02 second(s) in Ring 1.24

#=======================#
#  COMBINED OPERATIONS  #
#=======================#

/*-- Build, Edit, Import, and Visualize

pr()

# Build initial diagram
oDiag = new stzDiagram("PaymentFlow")
oDiag.SetTheme(:pro)
oDiag.AddNodeXTT("start", "Request", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("validate", "Validate", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("approved", "Approved", [ :type = "endpoint", :color = "success" ])

oDiag.Connect("start", "validate")
oDiag.Connect("validate", "approved")

# Add properties
oDiag.SetNodeProps("validate", [
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

? @@( oDiag.NodesNames() )
#--< [ "start", "validate", "approved", "manual", "manager", "approved" ]

? oDiag.NodeCount()
#--> 6

? oDiag.HasNode("manager")
#--> TRUE

# Update properties
oDiag.UpdateNodeProp(:validate, "type", "action")
? @@NL( oDiag.Node(:validate) )
#--> [
# 	[ "id", "validate" ],
# 	[ "label", "Validate" ],
# 	[
# 		"properties",
# 		[
# 			[ "type", "action" ],  # HAS BEEN AUPDATED!
# 			[ "color", "warning" ],
# 			[ "rule", "amount < 10000" ],
# 			[ "approver", "system" ]
# 		]
# 	]
# ]

# Visualize
oDiag.View()

oDiag.Show()
#-->
`
       ╭─────────╮       
       │ Request │       
       ╰─────────╯       
            |            
            v            
     ╭────────────╮      
     │ !Validate! │      
     ╰────────────╯      
            |            
            v            
      ╭──────────╮       
      │ Approved │       
      ╰──────────╯       

          ////

     ╭────────────╮  ↑
     │ !Validate! │──╯
     ╰────────────╯      
            |            
            v            
    ╭───────────────╮    
    │ Manual_Review │    
    ╰───────────────╯    
            |            
            v            
  ╭──────────────────╮   
  │ Manager_Approval │   
  ╰──────────────────╯   
            |            
            v            
      ╭──────────╮       
      │ Approved │       
      ╰──────────╯ 
`


pf()
#--> Executed in 0.73 second(s) in Ring 1.25

#======================================#
#  TESTING stzDiagram RULE SYSTEM      #
#  Now properly aligned with stzGraph  #
#======================================#

/*--- VISUAL RULES (DATA-DRIVEN)

pr()

oDiag = new stzDiagram("PricingTiers")
oDiag {
	# Add pricing nodes
	AddNodeXTT(:@free, "Free Tier", [ :Price = 0 ])
	AddNodeXTT(:@basic, "Basic Tier", [ :Price = 10 ])
	AddNodeXTT(:@pro, "Pro Tier", [ :Price = 50 ])
	AddNodeXTT(:@entreprise, "Enterprise Tier", [ :price = 200 ])

	ConnectSequence([ :@free, :@basic, :@pro, :@entreprise ])

	# Register visual rules as pure data
	RegisterVisualRule("CHEAP_GREEN", [
	    :ConditionType = "property_range",
	    :ConditionParams = [ :Price, 0, 30 ],
	    :Effects = [
	        :Color = "green-",
	        :PenWidth = 1
	    ]
	])

	RegisterVisualRule("MID_BLUE", [
	    :ConditionType = "property_range",
	    :ConditionParams = [ :Price, 31, 99 ],
	    :Effects = [
	        :Color = "blue+",
	        :PenWidth = 1
	    ]
	])

	RegisterVisualRule("EXPENSIVE_GOLD", [
	    :ConditionType = "property_range",
	    :ConditionParams = [ :Price, 100, 999999 ],
	    :Effects = [
	        :Color = "gold",
		:PenWidth = 3
	    ]
	])
	
	ApplyVisualRules()
	? @@NL( VisualRulesApplied() ) + NL
	#--> [ "@free", "@basic", "@pro", "@entreprise" ]

	? @@( NodesAffectedByVisualRules() )
	#--> [
	# 	[
	# 		[ "name", "CHEAP_GREEN" ],
	# 		[ "conditiontype", "property_range" ],
	# 		[ "effectscount", 2 ]
	# 	],
	# 	[
	# 		[ "name", "MID_BLUE" ],
	# 		[ "conditiontype", "property_range" ],
	# 		[ "effectscount", 2 ]
	# 	],
	# 	[
	# 		[ "name", "EXPENSIVE_GOLD" ],
	# 		[ "conditiontype", "property_range" ],
	# 		[ "effectscount", 2 ]
	# 	]
	# ]

	View()
? Dot()
}

pf()
# Executed in 0.52 second(s) in Ring 1.25
# Executed in 0.68 second(s) in Ring 1.24

/*--- COMBINED VALIDATION + VISUAL

pr()

oDiag = new stzDiagram("SecurePayment")
oDiag {
	SetTheme("neutral")
	# Nodes with security metadata
	AddNodeXTT(:@input, "User Input", [
		:Type = "start",
		:SecurityLevel = 1,
		:Sensitive = FALSE
	])

	AddNodeXTT(:@valid, "Validate", [
		:Type = "decision",
		:SecurityLevel = 2,
		:RequiresApproval = TRUE,
		:Approver = "security_team"
	])

	AddNodeXTT(:@process, "Process Payment", [
		:Type = "process",
		:SecurityLevel = 3,
		:Amount = 5000
	])

	AddNodeXTT(:@audit, "Audit Log", [
		:Type = "data",
		:SecurityLevel = 3,
		:Sensitive = TRUE
	])

	AddNodeXTT(:@done, "Complete", [
		:Type = "endpoint",
		:SecurityLevel = 1
	])

	Connect(:@input, :@valid)
	Connect(:@valid, :@process)
	Connect(:@process, :@audit)
	Connect(:@audit, :@done)

	# Visual rule: Highlight high-security nodes
	RegisterVisualRule("security_visual", [
		:ConditionType = "property_range",
		:ConditionParams = [ "securitylevel", 3, 5 ],
		:Effects = [
			:Color = "red",
			:Penwidth = 3
		]
	])
	
	# Visual rule: Mark sensitive data
	RegisterVisualRule("sensitive_marker", [
		:ConditionType = "property_equals",
		:ConditionParams = [ "sensitive", TRUE ],
		:Effects = [
			:Color = "orange",
			:Style = "bold,dashed"
		]
	])
	
	ApplyVisualRules()
	
	? @@NL(NodesAffectedByVisualRules()) + NL
	#--> [ "@process", "@audit" ]

	? @@NL( ValidateXT(:SOX) )
	#--> [
	# 	[ "status", "pass" ],
	# 	[ "domain", "sox" ],
	# 	[ "issuecount", 0 ],
	# 	[ "issues", [  ] ],
	# 	[ "affectednodes", [  ] ]
	# ]

	View()
}

#NOTE What's happening:
# 
# 1. @process: Matches security_visual rule only
#  	- Red color, penwidth=3
#
# 2. @audit: Matches both rules
# 	- First rule: security_visual (red, penwidth=3)
# 	- Second rule: sensitive_marker (orange, bold+dashed style)
# 	- Final merge: Orange color (overrides red), penwidth=3, bold+dashed style
#
# Visual confirmation in diagram:
# 	- Process_Payment: Red rounded box, thick border
# 	- Audit_Log: Orange dashed box, thick border ✓
# 
# The rule merging logic is working as designed - later rules override earlier
# ones for the same property (color), while accumulating unique properties
# (penwidth from first rule, style from second rule).

pf()
# Executed in 0.66 second(s) in Ring 1.25

/*--- FLUENT VISUAL RULES (WITH CLASS)

pr()

oDiag = new stzDiagram("TaskPriorities")
oDiag {
	AddNodeXTT("low", "Low Priority", [:priority = 1])
	AddNodeXTT("med", "Medium Priority", [:priority = 5])
	AddNodeXTT("high", "High Priority", [:priority = 10])
	AddNodeXTT("critical", "CRITICAL", [:priority = 15])
	
	Connect("low", "med")
	Connect("med", "high")
	Connect("high", "critical")
	
	# Option 1: Pure data (as before)
	RegisterVisualRule("LOW_PRIORITY", [
		:conditionType = "property_range",
		:conditionParams = ["priority", 1, 3],
		:effects = [["color", "green"]]
	])
	
	RegisterVisualRule("CRITICAL_PRIORITY", [
		:conditionType = "property_range",
		:conditionParams = ["priority", 10, 99],
		:effects = [["color", "red"], [	"penwidth", 3 ]]
	])
	
	ApplyVisualRules()

	? @@NL(VisualRulesApplied())
	
	View()
}

pf()
# Executed in 0.58 second(s) in Ring 1.25

/*--- APPROVAL WORKFLOW VISUALIZATION

pr()

oDiag = new stzDiagram("ExpenseApproval")
oDiag {
    SetTheme(:neutral)
    
    # Build structure
    AddNodeXTT("submit", "Submit", [:type = "start"])
    AddNodeXTT("manager", "Manager", [:type = "decision"])
    AddNodeXTT("process", "Process", [:type = "process"])
    
    Connect("submit", "manager")
    Connect("manager", "process")
    
    # VISUAL RULES ONLY
    RegisterVisualRule("DECISION_HIGHLIGHT", [
        :conditionType = "property_equals",
        :conditionParams = ["type", "decision"],
        :effects = [
            ["color", "orange"],
            ["penwidth", 2]
        ]
    ])
    
    ApplyVisualRules()
    
    # Rendering metrics (not validation)
    ? "Nodes rendered: " + NodeCount()
    ? "Visual rules applied: " + len(VisualRulesApplied())
    
    View()
}

pf()
# Executed in 0.59 second(s) in Ring 1.25

/*--- Visual rules merging with visual rules

pr()

oDiag = new stzDiagram("RuleMerging")
oDiag {
    AddNodeXTT("node1", "Test", [
        :priority = 10,
        :sensitive = TRUE
    ])
    
    # Multiple overlapping rules
    RegisterVisualRule("HIGH_PRIORITY", [
        :conditionType = "property_range",
        :conditionParams = ["priority", 8, 15],
        :effects = [["color", "red"], ["penwidth", 3]]
    ])
    
    RegisterVisualRule("SENSITIVE_DATA", [
        :conditionType = "property_equals",
        :conditionParams = ["sensitive", TRUE],
        :effects = [["color", "orange"], ["style", "dashed"]]
    ])
    
    ApplyVisualRules()
    
    ? "Rules applied to node1:"
    ? @@( NodesAffectedByVisualRules() )
    
    # Should show: orange (overrides red), penwidth 3, dashed style
    View()
}

pf()
# Executed in 0.59 second(s) in Ring 1.25

/*--- Data pipeline health with visual rules

pr()

oDiag = new stzDiagram("DataPipeline")
oDiag {
    SetTheme("dark")
    
    # Pipeline stages with health status
    AddNodeXTT("ingest", "Ingest", [:status = "healthy", :recordsPerHour = 50000])
    AddNodeXTT("clean", "Cleansing", [:status = "degraded", :recordsPerHour = 45000])
    AddNodeXTT("transform", "Transform", [:status = "healthy", :recordsPerHour = 44000])
    AddNodeXTT("enrich", "Enrichment", [:status = "down", :recordsPerHour = 0])
    AddNodeXTT("load", "Load to DW", [:status = "healthy", :recordsPerHour = 40000])
    
    ConnectSequence(["ingest", "clean", "transform", "enrich", "load"])
    
    # Status colors
    RegisterVisualRule("HEALTHY", [
        :conditionType = "property_equals",
        :conditionParams = ["status", "healthy"],
        :effects = [["color", "green+"]]
    ])
    
    RegisterVisualRule("DEGRADED", [
        :conditionType = "property_equals",
        :conditionParams = ["status", "degraded"],
        :effects = [["color", "orange"], ["style", "dashed"]]
    ])
    
    RegisterVisualRule("DOWN", [
        :conditionType = "property_equals",
        :conditionParams = ["status", "down"],
        :effects = [["color", "red"], ["penwidth", 3], ["style", "bold"]]
    ])
    
    # High volume stages
    RegisterVisualRule("HIGH_VOLUME", [
        :conditionType = "property_range",
        :conditionParams = ["recordsPerHour", 40000, 999999],
        :effects = [["shape", "hexagon"]]
    ])
    
    ApplyVisualRules()
    # Pipeline status
    ? @@(NodesAffectedByVisualRules())
    #--> [ "ingest", "clean", "transform", "enrich", "load" ]

    View()
}

pf()
# Executed in 0.59 second(s) in Ring 1.25

/*--- 
*/
pr()

pr()

oDiag = new stzDiagram("SystemAccess")
oDiag {
    
    # Resources with access levels
    AddNodeXTT("public_web", "Public Website", [:accessLevel = "public", :encrypted = FALSE])
    AddNodeXTT("user_portal", "User Portal", [:accessLevel = "authenticated", :encrypted = TRUE])
    AddNodeXTT("admin_panel", "Admin Panel", [:accessLevel = "admin", :encrypted = TRUE])
    AddNodeXTT("db_config", "DB Config", [:accessLevel = "system", :encrypted = TRUE])
    AddNodeXTT("audit_log", "Audit Log", [:accessLevel = "admin", :encrypted = TRUE])
    
    Connect("public_web", "user_portal")
    Connect("user_portal", "admin_panel")
    Connect("admin_panel", "db_config")
    Connect("admin_panel", "audit_log")
    
    # Access level colors
    RegisterVisualRule("PUBLIC", [
        :conditionType = "property_equals",
        :conditionParams = ["accessLevel", "public"],
        :effects = [["color", "green"]]
    ])
    
    RegisterVisualRule("AUTHENTICATED", [
        :conditionType = "property_equals",
        :conditionParams = ["accessLevel", "authenticated"],
        :effects = [["color", "blue"]]
    ])
    
    RegisterVisualRule("ADMIN", [
        :conditionType = "property_equals",
        :conditionParams = ["accessLevel", "admin"],
        :effects = [["color", "orange"], ["penwidth", 2]]
    ])
    
    RegisterVisualRule("SYSTEM", [
        :conditionType = "property_equals",
        :conditionParams = ["accessLevel", "system"],
        :effects = [["color", "red"], ["shape", "octagon"], ["penwidth", 3]]
    ])
    
    # Encryption indicator
    RegisterVisualRule("ENCRYPTED", [
        :conditionType = "property_equals",
        :conditionParams = ["encrypted", TRUE],
        :effects = [["style", "bold,filled"]]
    ])
    
    ApplyVisualRules()
    View()
}

pf()
