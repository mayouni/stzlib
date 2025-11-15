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

? ResolveColor(:lightblue)   # Should map to blue+
? ResolveColor(:lightgreen)  # Should map to green+
? ResolveColor(:lightyellow) # Should map to yellow+
? ResolveColor(:darkgreen)   # Should map to green-
? ResolveColor(:darkblue)    # Should map to blue-
? ResolveColor(:darkred)     # Should map to red-


/*--- Full Palette Count

pr()

aPalette = BuildColorPalette()
? len(aPalette) #--> 125
#--> 24 base + (24 × 4 intensities) = 120

pf()

/*--- Creating Test Diagram

pr()

oDiag = new stzDiagram("ColorSystemTest")
oDiag {
	# Base colors
	AddNodeXT("n1", "Red Base", :Process, :red)
	AddNodeXT("n2", "Blue Base", :Process, :blue)
	
	# Intensities
	AddNodeXT("n3", "Red Dark", :Process, "red++")
	AddNodeXT("n4", "Blue Light", :Process, "blue--")
	
	# Semantic
	AddNodeXT("n5", "Success", :Process, :Success)
	AddNodeXT("n6", "Warning", :Decision, :Warning)
	
	# Extended palette
	AddNodeXT("n7", "Coral", :Process, :coral)
	AddNodeXT("n8", "Lavender", :Process, :lavender)
	
	# Direct hex
	AddNodeXT("n9", "Custom", :Process, "#FF6B9D")
	
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

	AddNodeXT("start", "Order Received", :Start, :Success)
	AddNodeXT("validate", "Validate", :Process, :Primary)
	AddNodeXT("complete", "Done", :Endpoint, :Success)

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
#  TEST 2: VALIDATE DAG  {
#------------------------#

/*--- Ensuring workflow is acyclic

pr()

oDiag = new stzDiagram("ValidDAG")
oDiag.AddNodeXT("s", "Start", :Start, :Success)
oDiag.AddNodeXT("p", "Process", :Process, :Primary)
oDiag.AddNodeXT("e", "End", :Endpoint, :Success)
oDiag.Connect("s", "p")
oDiag.Connect("p", "e")

? oDiag.ValidateDAG() #--> TRUE

pf()

#---------------------------------#
#  TEST 3: VALIDATE REACHABILITY  #
#---------------------------------#

/*--- Checking all endpoints reachable from start

pr()

oDiag = new stzDiagram("ReachableEndpoints")
oDiag.AddNodeXT("start", "Start", :Start, :Success)
oDiag.AddNodeXT("process", "Process", :Process, :Primary)
oDiag.AddNodeXT("end", "End", :Endpoint, :Success)
oDiag.Connect("start", "process")
oDiag.Connect("process", "end")

odiag.view()
aResult = oDiag.ValidateReachability()
? aResult["status"] #--> pass

pf()

#-----------------#
#  TEST 4: VALIDATE COMPLETENESS
#-----------------#

/*--- Ensuring decisions have multiple paths

pr()

oDiag = new stzDiagram("Completeness")
oDiag.AddNodeXT("d", "Approved?", :Decision, :Warning)
oDiag.AddNodeXT("yes", "Yes", :Endpoint, :Success)
oDiag.AddNodeXT("no", "No", :Endpoint, :Danger)
oDiag.ConnectXT("d", "yes", "Yes")
oDiag.ConnectXT("d", "no", "No")

aResult = oDiag.ValidateCompleteness()
? aResult["status"] #--> pass

pf()

#-----------------#
#  TEST 5: COMPUTE METRICS
#-----------------#

/*--- Analyzing workflow path metrics

pr()

oDiag = new stzDiagram("MetricsTest")
oDiag.AddNodeXT("start", "Start", :Start, :Success)
oDiag.AddNodeXT("p1", "Step 1", :Process, :Primary)
oDiag.AddNodeXT("p2", "Step 2", :Process, :Primary)
oDiag.AddNodeXT("end", "End", :Endpoint, :Success)
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
oDiag.AddNodeXT("process", "Process", :Process, :Primary)

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
oDiag.AddNodeXT("n1", "Node 1", :Process, :Primary)

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
oDiag.AddNodeXT("user_api", "User API", :Process, :Success)
oDiag.AddNodeXT("user_db", "User DB", :Storage, :Success)
oDiag.AddNodeXT("order_api", "Order API", :Process, :Info)
oDiag.AddNodeXT("order_db", "Order DB", :Storage, :Info)

oDiag.AddCluster("users", "User Domain", ["user_api", "user_db"], :LightGreen)
oDiag.AddCluster("orders", "Order Domain", ["order_api", "order_db"], :Lightblue)

? len(oDiag.Clusters()) #--> 2

pf()

#-----------------#
#  TEST 9: GET CLUSTER INFO
#-----------------#

/*--- Retrieving cluster details

pr()

oDiag = new stzDiagram("ClusterInfo")
oDiag.AddNodeXT("a", "A", :Process, :primary)
oDiag.AddNodeXT("b", "B", :Process, :primary)

oDiag.AddCluster("domain1", "My Domain", ["a", "b"], "lightblue")

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
? oDiag1.@cTheme #--> Light

oDiag2 = new stzDiagram("DarkTheme")
oDiag2.SetTheme(:Dark)
? oDiag2.@cTheme #--> Dark

oDiag3 = new stzDiagram("VibrantTheme")
oDiag3.SetTheme(:Vibrant)
? oDiag3.@cTheme #--> Vibrant

pf()

#-----------------#
#  TEST 11: SET LAYOUT
#-----------------#

/*--- Testing different layout configurations

pr()

oDiag1 = new stzDiagram("MyDiagram")
oDiag1.SetLayout(:TopDown)
? oDiag1.@cLayout #--> TopDown

oDiag2 = new stzDiagram("MyDiagram")
oDiag2.SetLayout(:LeftRight)
? oDiag2.@cLayout #--> LeftRight

pf()

#-----------------#
#  TEST 12: SOX COMPLIANCE VALIDATION
#-----------------#

/*--- Validating workflow against SOX rules

pr()

oDiag = new stzDiagram("SoxPayment")
oDiag {
	AddNodeXT(:@Submit, "Submit", :Start, :Success)
	AddNodeXT(:@Approve, "Approve?", :Decision, :Warning)
	AddNodeXT(:@Pay, "Pay", :Process, :Primary)
	AddNodeXT(:@Log, "Log", :Data, :Neutral)
	AddNodeXT(:@Done, "Done", :Endpoint, :Success)

	Connect(:@Submit, :@Approve)
	ConnectXT(:@Approve, :@Pay, "Yes")
	Connect(:@Pay, :@Log)
	Connect(:@Log, :@Done)

	View()
}

oSoxValidator = new stzDiagramValidator(:SOX)//$aDiagramValidators[:SOX]
aResult = oSoxValidator.Validate(oDiag)

? aResult["domain"] #--> sox
? aResult["issueCount"] >= 0 #--> TRUE

pf()

#-----------------#
#  TEST 13: GDPR COMPLIANCE VALIDATION
#-----------------#

/*--- Validating data flow against GDPR rules

pr()

oDiag = new stzDiagram("GdprData")
oDiag.AddNodeXT("collect", "Collect", :Process, :primary)
oDiag.AddNodeXT("process", "Process", :Process, :primary)
oDiag.AddNodeXT("delete", "Delete", :Process, :info)

oDiag.Connect("collect", "process")
oDiag.Connect("collect", "delete")

oDiag.Node("collect")["properties"]["dataType"] = :personal
oDiag.Node("collect")["properties"]["requiresConsent"] = TRUE
oDiag.Node("collect")["properties"]["retentionPolicy"] = "1 year"
oDiag.Node("delete")["properties"]["operation"] = :delete

oGdprValidator = $aDiagramValidators[:GDPR]
aResult = oGdprValidator.Validate(oDiag)

? aResult["domain"] #--> GDPR
? aResult["issueCount"] >= 0 #--> TRUE

pf()

#-----------------#
#  TEST 14: BANKING COMPLIANCE VALIDATION
#-----------------#

/*--- Validating transaction against banking rules

pr()

oDiag = new stzDiagram("BankingTx")
oDiag.AddNodeXT("init", "Initiate", :Start, :success)
oDiag.AddNodeXT("fraud", "Fraud Check", :Process, :info)
oDiag.AddNodeXT("approve", "Approve?", :Decision, :warning)
oDiag.AddNodeXT("execute", "Execute", :Process, :primary)
oDiag.AddNodeXT("done", "Done", :Endpoint, :success)

oDiag.Connect("init", "fraud")
oDiag.Connect("fraud", "approve")
oDiag.ConnectXT("approve", "execute", "Yes")
oDiag.Connect("execute", "done")

oDiag.Node("init")["properties"]["transactionType"] = :large
oDiag.Node("fraud")["properties"]["operation"] = :fraud_check
oDiag.Node("approve")["properties"]["role"] = :approver
oDiag.Node("execute")["properties"]["operation"] = :payment

oBankingValidator = $aDiagramValidators[:Banking]
aResult = oBankingValidator.Validate(oDiag)

? aResult["domain"] #--> Banking
? aResult["issueCount"] >= 0 #--> TRUE

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

/*===================================================
#  stzDiagramConvertersTest - Test Suite
#  Each test runs independently
#===================================================

#-----------------#
#  TEST 1: GENERATE STZDIAG FORMAT
#-----------------#

/*--- Generating .stzdiag native text format

pr()

oDiag = new stzDiagram("FormatTest")
oDiag.SetTheme(:pro)
oDiag.SetLayout(:TopDown)
oDiag.AddNodeXT("start", "Begin", :Start, :success)
oDiag.AddNodeXT("process", "Work", :Process, :primary)
oDiag.AddNodeXT("end", "Finish", :Endpoint, :success)
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
        color: #008000

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
oDiag.AddCluster("domain", "Service Domain", ["api", "db"], "lightblue")

? oDiag.stzdiag()
#-->
'
diagram "ClusterTest"

metadata
    theme: null
    layout: null

nodes
    api
        label: "API"
        type: process
        color: success

    db
        label: "DB"
        type: storage
        color: success

clusters
    domain
        label: "Service Domain"
        nodes: [api, db]
        color: lightblue
'

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

#ERR edges are not displayed!
pr()

oDiag = new stzDiagram("DotShapesTest")
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
#ERRROR

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
#-->
'
graph TD
    start(["Start"])
    decision{{"Check"}}
    process[["Process"]]
    end([" End "])

    start --> decision
    decision --> process |Yes|
    process --> end
'
#-->
'
graph TD
    start(["Start"])
    decision{{"Check"}}
    process[["Process"]]
    end([" End "])

    start --> decision
    decision --> process |Yes|
    process --> end
'
#ERROR in MermaidJs editor
'
Syntax error
rror: Error: Parse error on line 5:
Error: Error: Parse error on line 5:
...ss[["Process"]]    end([" End "])    
----------------------^
Expecting 'SEMI', 'NEWLINE', 'SPACE', 'EOF', 'subgraph', 'acc_title', 'acc_descr', 'acc_descr_multiline_value', 'AMP', 'COLON', 'STYLE', 'LINKSTYLE', 'CLASSDEF', 'CLASS', 'CLICK', 'DOWN', 'DEFAULT', 'NUM', 'COMMA', 'NODE_STRING', 'BRKT', 'MINUS', 'MULT', 'UNICODE_TEXT', 'direction_tb', 'direction_bt', 'direction_rl', 'direction_lr', got 'end'

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
{"id":"JsonStructureTest","nodes":[{"id":"n","label":"Node","properties":{"type":"process","color":"primary"}}],"edges":{},"properties":{},"theme":"NULL","layout":"NULL","clusters":{},"annotations":{},"templates":{}}
'

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

oDiag3 = new stzDiagram("NodeTypeTest")
oDiag3 {
	SetTheme(:pro)           # Semantic
	SetLayout(:BottomUp)
	
	# Using semantic types
	AddNodeXT("s1", "Begin", :Start, :Success)
	AddNodeXT("p1", "Work", :Process, :Primary)
	AddNodeXT("d1", "Choice?", :Decision, :Warning)
	AddNodeXT("e1", "Done", :Endpoint, :Danger)
	
	# Using visual terms (if implemented)
	# AddNodeXT("s2", "Begin", :Ellipse, :Success)
	# AddNodeXT("p2", "Work", :Box, :Primary)
	
	Connect("s1", "p1")
	Connect("p1", "d1")
	Connect("d1", "e1")
	
	View()
}

pf()

/*-- Test 4: Theme variations

pr()

oDiag4 = new stzDiagram("ThemeTest")
oDiag4 {
	SetTheme(:Vibrant)       # Or :Light, :Dark, :Pro
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

/*-- Test 5: Combined options

pr()

oDiag5 = new stzDiagram("CompleteTest")
oDiag5 {
	SetTheme(:Light)
	SetLayout("lr")              # Short form
	SetEdgeStyle(:ErrorFlow)     # Semantic → dotted
	SetEdgeColor("gray")
	
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
	SetFont("helvetica")
	SetFontSize(18)
	SetTheme(:Pro)
	
	AddNodeXT("n1", "Custom Font", :Start, :Success)
	AddNodeXT("n2", "Arial 18pt", :Process, :Primary)
	ConnectXT("n1", "n2", "size")
	
	View()
}

pf()

#------------------------------#
#  VISUAL RULES AND SEMANTICS  #
#------------------------------#


/*---  Example 1: Security Risk Visualization

pr()

# Create the diagram object

oDiag = new stzDiagram("SecurityFlow")

# Define visual rules based on metadata

oHighRiskRule = new stzVisualRule("high_risk")
oHighRiskRule {
	WhenMetadataInRange("risk_score", 70, 100)
	ApplyColor("#FF4444")
	ApplyPenWidth(3)
}

oSecureRule = new stzVisualRule("secure")
oSecureRule {
	WhenTagExists(:security)
}

# Crafing the diagram object

oDiag {

	# Use those rules inside the diagram object

	AddVisualRule(oHighRiskRule)
	AddVisualRule(oSecureRule)

	# Add nodes with metadata

	AddNodeWithMetaData("auth", "Authentication", :Process, :Primary,
		[ :risk_score = 85, :sla_ms = 100], # <-- metadata
		[ :security, :critical ] # <-- tags
	)

	AddNodeWithMetaData("db", "Database", :Storage, :Info,
		[ :risk_score = 45, :encrypted = TRUE],
		[ :security ]
	)

	AddEdgeWithMetaData("auth", "db", "query",
		[ :type = "requires"],
		[ :data_flow ]
	)

	? Code()
	View()
}


pf()

/*---  Example 2: Performance Monitoring

pr()

oDiag = new stzDiagram("APIFlow")

# Performance-based coloring
oSlowRule = new stzVisualRule("slow_api")
oSlowRule.WhenMetadataInRange("latency_ms", 500, 9999).
	  ApplyColor("#FFA500")

oFastRule = new stzVisualRule("fast_api")
oFastRule.WhenMetadataInRange("latency_ms", 0, 100).
	  ApplyColor("#44FF44")

oDiag.AddVisualRule(oSlowRule)
oDiag.AddVisualRule(oFastRule)

oDiag.AddNodeWithMetaData("api1", "User API", :Process, :Primary,
	[ :latency_ms = 50, :throughput = 1000], [:api])

oDiag.AddNodeWithMetaData("api2", "Payment API", :Process, :Primary,
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
oPciRule.WhenTagExists(:pci).
	 ApplyColor("#0066CC")

oDiag.AddVisualRule(oGdprRule)
oDiag.AddVisualRule(oPciRule)

oDiag.AddNodeWithMetaData("collect", "Data Collection", :Process, :Info,
	[:retention_days = 90], ["gdpr"])

oDiag.AddNodeWithMetaData("payment", "Payment Processing", :Process, :Warning,
	[:encryption = TRUE], ["pci"])

? oDiag.code()
oDiag.View()

pf()

/*---------------------------#
#  TEST 4: Exact Value Matching
#---------------------------#

pr()

oDiag = new stzDiagram("EnvironmentColors")

# Production systems get red warning color
oProductionRule = new stzVisualRule("prod_warning")
oProductionRule {
	WhenMetadataEquals("env", "production")
	ApplyColor("#FF0000")
	ApplyPenWidth(4)
}

oDiag {
	AddVisualRule(oProductionRule)
	
	AddNodeWithMetaData("prod_db", "Production DB", :Storage, :Primary,
		[:env = "production", :replicas = 3], [:database])
	
	AddNodeWithMetaData("dev_db", "Dev DB", :Storage, :Info,
		[:env = "development"], [:database])
	
	Connect("prod_db", "dev_db")
	View()
}

pf()

/*---------------------------#
#  TEST 5: Priority Gradient
#---------------------------#

pr()

oDiag = new stzDiagram("TaskPriority")

# Three-tier priority visualization
oLowPrio = new stzVisualRule("low")
oLowPrio {
	WhenMetadataInRange("priority", 0, 33)
	ApplyColor("#CCCCCC")  # Gray for low
}

oMedPrio = new stzVisualRule("medium")
oMedPrio {
	WhenMetadataInRange("priority", 34, 66)
	ApplyColor("#4488FF")  # Blue for medium
}

oHighPrio = new stzVisualRule("high")
oHighPrio {
	WhenMetadataInRange("priority", 67, 100)
	ApplyColor("#FF4444")  # Red for high
	ApplyPenWidth(3)
}

oDiag {
	AddVisualRule(oLowPrio)
	AddVisualRule(oMedPrio)
	AddVisualRule(oHighPrio)
	
	AddNodeWithMetaData("task1", "Cleanup", :Process, :Neutral, 
		[:priority = 20], [])
	AddNodeWithMetaData("task2", "Review", :Process, :Info, 
		[:priority = 50], [])
	AddNodeWithMetaData("task3", "Deploy", :Process, :Danger, 
		[:priority = 90], [:critical])
	
	Connect("task1", "task2")
	Connect("task2", "task3")
	
	View()
}

pf()

/*---------------------------#
#  TEST 6: Edge Styling
#---------------------------#
"TODO see why all are blue
pr()

oDiag = new stzDiagram("ConnectionTypes")

# Synchronous calls are bold and blue
oSyncEdge = new stzVisualRule("sync")
oSyncEdge {
	WhenMetadataEquals("type", "sync")
	ApplyStyle("bold")
	ApplyColor("#0066CC")
}

# Async calls are dashed and gray
oAsyncEdge = new stzVisualRule("async")
oAsyncEdge {
	WhenMetadataEquals("type", "async")
	ApplyStyle("dashed")
	ApplyColor("#999999")
}

oDiag {
	AddVisualRule(oSyncEdge)
	AddVisualRule(oAsyncEdge)
	
	AddNode("api", "API Gateway")
	AddNode("service", "Auth Service")
	AddNode("cache", "Redis Cache")
	
	AddEdgeWithMetaData("api", "service", "authenticate", 
		[:type = "sync"], [])
	AddEdgeWithMetaData("service", "cache", "invalidate", 
		[:type = "async"], [])
	
	View()
	? Code()
}

pf()

/*---------------------------#
#  TEST 7: Metadata Presence
#---------------------------#

pr()

oDiag = new stzDiagram("SlaMonitoring")

# Any node with SLA gets thick border
oHasSla = new stzVisualRule("sla_defined")
oHasSla {
	WhenMetadataExists("sla_ms")
	ApplyPenWidth(2)
	ApplyColor(:green)
}

oDiag {
	AddVisualRule(oHasSla)
	
	AddNodeWithMetaData("critical_api", "Payment API", :Process, :Primary,
		[:sla_ms = 100, :uptime = 99.99], [])
	
	AddNodeWithMetaData("batch_job", "Batch Job", :Process, :Info,
		[:schedule = "daily" ], [])  # No SLA
	
	Connect("critical_api", "batch_job")
	View()
}

pf()

/*---------------------------#
#  TEST 8: Rule Cascading
#---------------------------#

pr()

oDiag = new stzDiagram("RuleOverride")

# Base rule for all APIs
oApiBase = new stzVisualRule("api_base")
oApiBase {
	WhenTagExists(:api)
	ApplyColor("#E0E0E0")
}

# Override for critical APIs (applied last, takes precedence)
oCritical = new stzVisualRule("critical_override")
oCritical {
	WhenTagExists(:critical)
	ApplyColor("#FF0000")
	ApplyPenWidth(4)
}

oDiag {
	AddVisualRule(oApiBase)     # Applied first
	AddVisualRule(oCritical)    # Overrides color for critical
	
	AddNodeWithMetaData("standard", "User API", :Process, :Primary,
		[], [:api])
	
	AddNodeWithMetaData("vital", "Payment API", :Process, :Primary,
		[], [:api, :critical])  # Gets both rules, last wins
	
	Connect("standard", "vital")
	View()
}

pf()

#---------------------------#
#  TEST 9: Dynamic Shapes
#---------------------------#

pr()

oDiag = new stzDiagram("ServiceTypes")

# Storage services get cylinder shape
oStorageShape = new stzVisualRule("storage")
oStorageShape {
	WhenTagExists(:storage)
	ApplyShape("cylinder")
	ApplyColor("#8B4513")
}

# Queue services get parallelogram
oQueueShape = new stzVisualRule("queue")
oQueueShape {
	WhenTagExists(:messaging)
	ApplyShape("parallelogram")
	ApplyColor("#FFA500")
}

oDiag {
	AddVisualRule(oStorageShape)
	AddVisualRule(oQueueShape)
	
	AddNodeWithMetaData("postgres", "PostgreSQL", :Process, :Info,
		[:type = "relational"], [:storage, :database])
	
	AddNodeWithMetaData("rabbitmq", "RabbitMQ", :Process, :Warning,
		[:type = "broker"], [:messaging, :queue])
	
	AddNodeWithMetaData("api", "REST API", :Process, :Primary,
		[], [:service])
	
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
	WhenMetadataInRange("latency_ms", 500, 9999)
	ApplyColor("#FFA500")
	ApplyPenWidth(2)
}

oDiag {
	AddVisualRule(oEncrypted)
	AddVisualRule(oSlow)
	
	AddNodeWithMetaData("secure_db", "Encrypted DB", :Storage, :Success,
		[], [:encrypted])
	
	AddNodeWithMetaData("slow_api", "Legacy API", :Process, :Warning,
		[:latency_ms = 750], [])
	
	# Generate legend showing all rule mappings
	? "=== Visual Rules Legend ==="
	? @@NL( MetadataLegend() )
	
	View()
}

pf()

/*---------------------------#
#  TEST 11: Complex Workflow
#---------------------------#

pr()

oDiag = new stzDiagram("E2EMonitoring")

# Combine multiple rules for realistic monitoring
oHighLoad = new stzVisualRule("load")
oHighLoad {
	WhenMetadataInRange("load_pct", 80, 100)
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
	WhenMetadataEquals("status", "deprecated")
	ApplyColor("#888888")
	ApplyStyle("dotted,filled")
}

oDiag {
	AddVisualRule(oHighLoad)
	AddVisualRule(oEncrypted)
	AddVisualRule(oDeprecated)
	
	AddNodeWithMetaData("lb", "Load Balancer", :Process, :Primary,
		[:load_pct = 85], [:critical])
	
	AddNodeWithMetaData("db", "Database", :Storage, :Primary,
		[:load_pct = 60], [:encrypted])
	
	AddNodeWithMetaData("old_api", "Legacy API", :Process, :Neutral,
		[:status = "deprecated"], [])
	
	Connect("lb", "db")
	Connect("lb", "old_api")
	
	View()
}

pf()

#---------------------------#
#  Microservices Health Dashboard
#---------------------------#

pr()

oDiag = new stzDiagram("ServiceHealth")

# Health-based coloring: green=healthy, yellow=degraded, red=down
oHealthy = new stzVisualRule("healthy")
oHealthy{
	WhenMetadataEquals("status", "up")
	ApplyColor("#00AA01")
}

oDegraded = new stzVisualRule("degraded")
oDegraded{
	WhenMetadataEquals("status", "degraded")
	ApplyColor("#FFAA00")
	ApplyPenWidth(2)
}

oDown = new stzVisualRule("down")
oDown {
	WhenMetadataEquals("status", "down")
	ApplyColor("#FF0000")
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
	
	AddVisualRule(oHealthy)
	AddVisualRule(oDegraded)
	AddVisualRule(oDown)
	AddVisualRule(oCritical)
	
	AddNodeWithMetaData("gateway", "API Gateway", :Process, :Primary,
		[:status = "up", :latency_ms = 45], [:critical])
	
	AddNodeWithMetaData("auth", "Auth Service", :Process, :Primary,
		[:status = "degraded", :latency_ms = 320], [:critical])
	
	AddNodeWithMetaData("users", "Users API", :Process, :Primary,
		[:status = "up", :latency_ms = 80], [])
	
	AddNodeWithMetaData("orders", "Orders API", :Process, :Primary,
		[:status = "down", :latency_ms = 0], [:critical])
	
	AddNodeWithMetaData("db", "PostgreSQL", :Storage, :Info,
		[:status = "up", :replicas = 3], [:critical])
	
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

#ERR Datawarehsous node whoe on white!
pr()

oDiag = new stzDiagram("DataCompliance")

# PII data gets special marking
oPiiData = new stzVisualRule("pii")
oPiiData {
	WhenTagExists(:pii)
	ApplyPenWidth(3)
}

# Encrypted connections
oEncrypted = new stzVisualRule("encrypted")
oEncrypted {
	WhenMetadataEquals("encrypted", TRUE)
	ApplyStyle("bold")
}

# Audit logging required
oAudited = new stzVisualRule("audit")
oAudited {
	WhenTagExists(:audit)
	ApplyShape("octagon")
}

oDiag {
	SetTheme(:vibrant)
	SetLayout(:LeftRight)
	
	AddVisualRule(oPiiData)
	AddVisualRule(oEncrypted)
	AddVisualRule(oAudited)
	
	AddNodeWithMetaData("collect", "Data Collector", :Process, :Info,
		[], [:audit])
	
	AddNodeWithMetaData("transform", "ETL Pipeline", :Process, :Primary,
		[], [])
	
	AddNodeWithMetaData("warehouse", "Data Warehouse", :Storage, :Success,
		[:encrypted = TRUE], [:pii, :audit])
	
	AddNodeWithMetaData("analytics", "Analytics", :Process, :Primary,
		[], [])
	
	AddNodeWithMetaData("reports", "Reports", :Endpoint, :Info,
		[], [:audit])
	
	AddEdgeWithMetaData("collect", "transform", "raw", 
		[:encrypted = FALSE], [])
	
	AddEdgeWithMetaData("transform", "warehouse", "store", 
		[:encrypted = TRUE], [])
	
	AddEdgeWithMetaData("warehouse", "analytics", "query", 
		[:encrypted = TRUE], [])
	
	AddEdgeWithMetaData("analytics", "reports", "publish", 
		[:encrypted = FALSE], [])
	
	View()
? Code()
}

pf()

/*---------------------------#
#  Cost-Based Infrastructure
#---------------------------#

pr()

oDiag = new stzDiagram("CloudCosts")

# Color by monthly cost
oLowCost = new stzVisualRule("cheap")
oLowCost {
	WhenMetadataInRange("monthly_usd", 0, 100)
	ApplyColor("#E8F5E9")
}

oMedCost = new stzVisualRule("moderate")
oMedCost {
	WhenMetadataInRange("monthly_usd", 101, 500)
	ApplyColor("#FFF9C4")
}

oHighCost = new stzVisualRule("expensive")
oHighCost {
	WhenMetadataInRange("monthly_usd", 501, 9999)
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
	SetTheme(:light)
	
	AddVisualRule(oLowCost)
	AddVisualRule(oMedCost)
	AddVisualRule(oHighCost)
	AddVisualRule(oProduction)
	
	AddNodeWithMetaData("lb", "Load Balancer", :Process, :Primary,
		[:monthly_usd = 50], [:production])
	
	AddNodeWithMetaData("app1", "App Server 1", :Process, :Primary,
		[:monthly_usd = 200], [:production])
	
	AddNodeWithMetaData("app2", "App Server 2", :Process, :Primary,
		[:monthly_usd = 200], [:production])
	
	AddNodeWithMetaData("rds", "RDS Database", :Storage, :Info,
		[:monthly_usd = 800], [:production])
	
	AddNodeWithMetaData("cache", "Redis Cache", :Storage, :Warning,
		[:monthly_usd = 120], [:production])
	
	AddNodeWithMetaData("s3", "S3 Storage", :Storage, :Success,
		[:monthly_usd = 30], [:production])
	
	Connect("lb", "app1")
	Connect("lb", "app2")
	Connect("app1", "rds")
	Connect("app2", "rds")
	Connect("app1", "cache")
	Connect("app2", "cache")
	Connect("app1", "s3")
	
	View()
}

pf()

/*---------------------------#
#  Security Zones
#---------------------------#

pr()

oDiag = new stzDiagram("SecurityArchitecture")

# Color by security zone
oPublic = new stzVisualRule("public_zone")
oPublic {
	WhenMetadataEquals("zone", "public")
	ApplyColor("#FFE0B2")
}

oDmz = new stzVisualRule("dmz_zone")
oDmz {
	WhenMetadataEquals("zone", "dmz")
	ApplyColor("#FFF59D")
}

oPrivate = new stzVisualRule("private_zone")
oPrivate {
	WhenMetadataEquals("zone", "private")
	ApplyColor("#C8E6C9")
}

# Firewall edges
oFirewall = new stzVisualRule("firewall")
oFirewall {
	WhenMetadataEquals("firewall", TRUE)
	ApplyStyle("bold")
	ApplyColor("#FF5722")
	ApplyPenWidth(3)
}

oDiag {
	SetTheme(:pro)
	SetLayout(:TopDown)
	
	AddVisualRule(oPublic)
	AddVisualRule(oDmz)
	AddVisualRule(oPrivate)
	AddVisualRule(oFirewall)
	
	AddNodeWithMetaData("internet", "Internet", :Start, :Info,
		[:zone = "public"], [])
	
	AddNodeWithMetaData("waf", "WAF", :Process, :Warning,
		[:zone = "dmz"], [:security])
	
	AddNodeWithMetaData("lb", "Load Balancer", :Process, :Primary,
		[:zone = "dmz"], [])
	
	AddNodeWithMetaData("web", "Web Tier", :Process, :Primary,
		[:zone = "private"], [])
	
	AddNodeWithMetaData("app", "App Tier", :Process, :Primary,
		[:zone = "private"], [])
	
	AddNodeWithMetaData("db", "Database", :Storage, :Success,
		[:zone = "private"], [:encrypted])
	
	AddEdgeWithMetaData("internet", "waf", "443", 
		[:firewall = TRUE], [])
	
	AddEdgeWithMetaData("waf", "lb", "https", 
		[:firewall = TRUE], [])
	
	AddEdgeWithMetaData("lb", "web", "internal", 
		[:firewall = FALSE], [])
	
	AddEdgeWithMetaData("web", "app", "api", 
		[:firewall = TRUE], [])
	
	AddEdgeWithMetaData("app", "db", "query", 
		[:firewall = TRUE], [])
	
	View()
}

pf()

/*---------------------------#
#  CI/CD Pipeline States
#---------------------------#

pr()

oDiag = new stzDiagram("DeploymentPipeline")

# Stage status coloring
oPassed = new stzVisualRule("passed")
oPassed {

	When(:lastrun, :Equals = "pass")
	UseColor("#4CAF50") # Allow resolving color name (like :red), semantic (like :Success)
	# Add UseColorXT("red++", "white") # first is node background, the second is the color of the text

# We should not favoor the use of actual colore values, especially when they
# are hex values because they are not expressive. Keep them supported but add
# the resolvecolor feature anywhre to allow using colore names and color semantic types
# as noted above. Also, make a semantic engering of color names so they are bot
# powerful and string to use:

# all starts by givin a name to an actual hex color in an abstruct gloabla container
# called @acColors not as it is made now (splitted between @acEdgeColors and other containers)

# Also, it's confusing to say $acNodeColors = [ :Start = "lightgreen", ... ] while they
# are actually $acNodeTypesAndTheirColors or $acNodeColorByType. This is not a superficial naming
# choice, because it frees the name @acColors from any dependency to anything, because the same
# coloers can be used with any thing

# The same clean naming design should be applied to colors semantics meaning, so we keep oonly one
# copy of everthing and just make the ling between them in an other container.

# Also, the color names should be creatively simple and powerfully expressive in the same time:
# so each color will have 5 levels of densitin: gray--, gray-, gray, gray+, and gray+++
# The feature should be automatically activated for any new color we add to the unique color container
# where we define names for coler within their actual hexvalues. So for example, whey we add :cyan = "#00FFFF",
# then cyan--, cyan--, cyan+, and cyan++ should all be supported (and resolved when used as coloer values anywhre)
# (even in other classes, so make the resolve color dature as global function)

# also, wwe should avoit confusing namings like "lightgreen" and "lightgreen" and use
# "green-" instead, etc.


//	WhenMetadataEquals("last_run", "pass")
//	ApplyColor("#4CAF50")
}

oFailed = new stzVisualRule("failed")
oFailed {
	When(:last_run, :Equals = "fail")
	UseColor("#F44336")
//	WhenMetadataEquals("last_run", "fail")
//	ApplyColor("#F44336")
}

oRunning = new stzVisualRule("running")
oRunning {
	When(:last_run, :Equals = "running")
	UseColor("#2196F3")
	UsePenWidth(2)
//	WhenMetadataEquals("last_run", "running")
//	ApplyColor("#2196F3")
//	ApplyPenWidth(2)
}

# Critical stages
oCriticalStage = new stzVisualRule("critical_stage")
oCriticalStage {
	WhenTagExists(:gate)
	ApplyShape("diamond")
}

oDiag {
	SetTheme(:lightgray)
	SetLayout(:TopDown)
	
# Rules can be composed from exitant set of rules, which more accurade for clean design and reusable rules
	AddVisualRule(oPassed)
	AddVisualRule(oFailed)
	AddVisualRule(oRunning)
	AddVisualRule(oCriticalStage)
	
# Also rules can be defined directly here, which is more intuitive for focused usage
#	When(:lastrun, :Equals = "pass")
#	UseColor("#4CAF50") # Allow resolving color name (like :red), semantic (like :Success)

# And we can check them by calling Rules() #--> Their content lists
# Or by calling RulesObjects() #--> Thir stzRule objects

# Finaly, like colore paletes, we should be able to define named rulesets as data conatiners
#  at the gloabl level, classifid by domain, so we can load all the rules of all the domain
# we want to work with, without the necessity of adding each rule indiviually
#~> this will allow powerful business domains chekcs in banking, quality, legal, etc

	AddNodeWithMetaData("commit", "Git Commit", :Start, :Success,
		[:last_run = "pass"], [])
	
# Allow using AddNodeXTT() as an alternative : be careful of confusion with
# parent same method. In fact, I think we don't need implementing this method
# at all at this class level, the parent one is sufficient. It's also a better
# design decision, because adding metadata is a feature abstructed is stzGraph
# to be reused by all it's child classes. The point is that this one has an
# additiona tag param at the end that i don't see why we ever need it! Because
# tages are themselves medatadat since we can add them as :tags = [ ... ] in the
# metadata param... Review this design!

# the same thing should  be done to AddEdgeWithMetaData!

	AddNodeWithMetaData("build", "Build", :Process, :Primary,
		[:last_run = "pass", :duration_s = 120], [])
	
	AddNodeWithMetaData("unit", "Unit Tests", :Process, :Primary,
		[:last_run = "running", :duration_s = 45], [])
	
	AddNodeWithMetaData("security", "Security Scan", :Decision, :Warning,
		[:last_run = "pass", :issues = 0], [:gate])
	
	AddNodeWithMetaData("deploy_stage", "Deploy Staging", :Process, :Info,
		[:last_run = "pass"], [])
	
	AddNodeWithMetaData("integration", "Integration Tests", :Process, :Primary,
		[:last_run = "fail", :failed_tests = 3], [])
	
	AddNodeWithMetaData("approval", "Manual Approval", :Decision, :Warning,
		[:last_run = "pass"], [:gate])
	
	AddNodeWithMetaData("deploy_prod", "Deploy Production", :Endpoint, :Success,
		[:last_run = "pass"], [])
	
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
        color: #008000

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
        color: danger

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

pf()
#--> Executed in 0.08 second(s) in Ring 1.24

/*-- Import as Subdiagram

pr()

oDiag = new stzDiagram("MainFlow")
oDiag.AddNodeXT("start", "Main Start", :start, :success)
oDiag.AddNodeXT("main", "Main Process", :process, :primary)
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
oDiag.AddNodeXT("n1", "Node 1", :process, :blue)
oDiag.AddNodeXT("n2", "Node 2", :process, :blue)
oDiag.AddNodeXT("n3", "Node 3", :process, :blue)
oDiag.Connect("n1", "n2")
oDiag.Connect("n2", "n3")

? oDiag.NodeCount()
#--> 3
? oDiag.EdgeCount()
#--> 2

oDiag.RemoveNode("n2")

? oDiag.NodeCount()
#--> 2
? oDiag.EdgeCount()
#--> 0 (both edges removed)

pf()
#--> Executed in 0.04 second(s) in Ring 1.24

/*-- Remove Multiple Nodes

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXT("n1", "Node 1", :process, :blue)
oDiag.AddNodeXT("n2", "Node 2", :process, :blue)
oDiag.AddNodeXT("n3", "Node 3", :process, :blue)
oDiag.AddNodeXT("n4", "Node 4", :process, :blue)
oDiag.Connect("n1", "n2")
oDiag.Connect("n3", "n4")

oDiag.RemoveNodes(["n2", "n4"])

? oDiag.NodeCount()
#--> 2

pf()
#--> Executed in 0.03 second(s) in Ring 1.24

/*-- Clear All Nodes
*/
pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXT("n1", "Node 1", :process, :blue)
oDiag.AddNodeXT("n2", "Node 2", :process, :blue)
oDiag.Connect("n1", "n2")
oDiag.SetNodeMetadata("n1", [:priority = "high"])

oDiag.RemoveAllNodes()

? oDiag.NodeCount()
#--> 0
? oDiag.EdgeCount()
#--> 0
? len(oDiag.@aNodeMetadata)
#--> 0

pf()
#--> Executed in 0.02 second(s) in Ring 1.24

/*-- Replace Node with Edge Preservation

pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXT("n1", "Node 1", :process, :blue)
oDiag.AddNodeXT("old", "Old Node", :process, :yellow)
oDiag.AddNodeXT("n3", "Node 3", :process, :blue)
oDiag.Connect("n1", "old")
oDiag.Connect("old", "n3")

oDiag.ReplaceNode("old", "new", "New Node", :process, :green)

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
