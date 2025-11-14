load "../stzbase.ring"

#-----------------#
#  TEST 1: CREATE SIMPLE DIAGRAM
#-----------------#

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

#-----------------#
#  TEST 2: VALIDATE DAG
#-----------------#

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

#-----------------#
#  TEST 3: VALIDATE REACHABILITY
#-----------------#

/*--- Checking all endpoints reachable from start

pr()

oDiag = new stzDiagram("ReachableEndpoints")
oDiag.AddNodeXT("start", "Start", :Start, :Success)
oDiag.AddNodeXT("process", "Process", :Process, :Primary)
oDiag.AddNodeXT("end", "End", :Endpoint, :Success)
oDiag.Connect("start", "process")
oDiag.Connect("process", "end")

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

oDiag.AddNodeXT(:Submit, "Submit", :Start, :Success)
oDiag.AddNodeXT(:Approve, "Approve?", :Decision, :Warning)
oDiag.AddNodeXT(:Pay, "Pay", :Process, :Primary)
oDiag.AddNodeXT(:Log, "Log", :Data, :Neutral)
oDiag.AddNodeXT(:Done, "Done", :Endpoint, :Success)

oDiag.Connect(:Submit, :Approve)
oDiag.ConnectXT(:Approve, :Pay, " Yes")
oDiag.Connect(:Pay, :Log)
oDiag.Connect(:Log, :Done)

oDiag.View()

oDiag.Node("pay")["properties"]["domain"] = :financial
oDiag.Node("approve")["properties"]["requiresApproval"] = TRUE

oSoxValidator = $aDiagramValidators[:SOX]
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

    end
        label: "Finish"
        type: endpoint
        color: success

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
*/
pr()

oDiag3 = new stzDiagram("NodeTypeTest")
oDiag3 {
	SetTheme(:pro)           # Semantic
	# SetTheme("professional") # Alias
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
*/

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
*/
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

oDiag.AddNodewithMetaData("collect", "Data Collection", :Process, :Info,
	[:retention_days = 90], ["gdpr"])

oDiag.AddNodeWithMetaData("payment", "Payment Processing", :Process, :Warning,
	[:encryption = TRUE], ["pci"])

? oDiag.code()
oDiag.View()

pf()
