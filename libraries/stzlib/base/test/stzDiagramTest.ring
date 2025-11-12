load "../stzbase.ring"

/*===================================================
#  stzDiagramTest - Test Suite
#  Each test runs independently
#===================================================

#-----------------#
#  TEST 1: CREATE SIMPLE DIAGRAM
#-----------------#

/*--- Building workflow diagram with node types and theme
*/
pr()

oDiag = new stzDiagram("OrderFlow")
oDiag.SetTheme(:Professional)
oDiag.SetLayout(:TopDown)

oDiag.AddNodeXT("start", "Order Received", :Start, :Success)
oDiag.AddNodeXT("validate", "Validate", :Process, :Primary)
oDiag.AddNodeXT("complete", "Done", :Endpoint, :Success)

oDiag.Connect("start", "validate")
oDiag.Connect("validate", "complete")

? oDiag.NodeCount() #--> 3
? oDiag.EdgeCount() #--> 2

? oDiag.Dot()

oDiag.Show()

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
oDiag.AddNodeXT("submit", "Submit", :Start, :success)
oDiag.AddNodeXT("approve", "Approve?", :Decision, :warning)
oDiag.AddNodeXT("pay", "Pay", :Process, :primary)
oDiag.AddNodeXT("log", "Log", :Data, :neutral)
oDiag.AddNodeXT("done", "Done", :Endpoint, :success)

oDiag.Connect("submit", "approve")
oDiag.ConnectXT("approve", "pay", "Yes")
oDiag.Connect("pay", "log")
oDiag.Connect("log", "done")

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
oDiag.SetTheme(:Professional)
oDiag.AddNodeXT("n1", "Node", :Process, :primary)

aHashlist = oDiag.ToHashlist()

? aHashlist["theme"] #--> Professional
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
oDiag.SetTheme(:Professional)
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
    theme: professional
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
    theme: null
    layout: null

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
#-->
'
diagram "DotTest"

metadata
    theme: null
    layout: null

nodes
    start
        label: "Start"
        type: start
        color: success

    end
        label: "End"
        type: endpoint
        color: success

edge
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
#ERROR: default color should be translated in color names for dot file

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
    edge [fontname=Helvetica, color=NULL]

    s [label="S", shape=polygon, style="filled", fillcolor="success"]
    d [label="D", shape=diamond, style="filled", fillcolor="warning"]
    p [label="P", shape=box, style="rounded,filled", fillcolor="primary"]
    e [label="E", shape=doublecircle, style="filled", fillcolor="success"]


}
'

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
oDiag.SetTheme(:Professional)
oDiag.AddNodeXT("a", "A", :Process, :primary)
oDiag.AddNodeXT("b", "B", :Process, :primary)
oDiag.Connect("a", "b")

? oDiag.Json()
#-->
'
{"id":"JsonTest","nodes":[{"id":"a","label":"A","properties":{"type":"process","color":"primary"}},{"id":"b","label":"B","properties":{"type":"process","color":"primary"}}],"edges":[{"from":"a","to":"b","label":"","properties":{}}],"properties":{},"theme":"professional","layout":"NULL","clusters":{},"annotations":{},"templates":{}}
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
