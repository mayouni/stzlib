load "../stzbase.ring"

/*===================================================
#  stzDiagramTest - Test Suite
#  Each test runs independently
#===================================================*/

#-----------------#
#  TEST 1: CREATE SIMPLE DIAGRAM
#-----------------#

/*--- Building workflow diagram with node types and theme

pr()

oDiag = new stzDiagram("OrderFlow")
oDiag.SetTheme(:Professional)
oDiag.SetLayout(:TopDown)

oDiag.AddDiagramNode("start", "Order Received", :Start, :success)
oDiag.AddDiagramNode("validate", "Validate", :Process, :primary)
oDiag.AddDiagramNode("complete", "Done", :Endpoint, :success)

oDiag.Connect("start", "validate", "")
oDiag.Connect("validate", "complete", "")

? oDiag.NodeCount() #--> 3
? oDiag.EdgeCount() #--> 2

pf()

#-----------------#
#  TEST 2: VALIDATE DAG
#-----------------#

/*--- Ensuring workflow is acyclic

pr()

oDiag = new stzDiagram("ValidDAG")
oDiag.AddDiagramNode("s", "Start", :Start, :success)
oDiag.AddDiagramNode("p", "Process", :Process, :primary)
oDiag.AddDiagramNode("e", "End", :Endpoint, :success)
oDiag.Connect("s", "p", "")
oDiag.Connect("p", "e", "")

? oDiag.ValidateDAG() #--> TRUE

pf()

#-----------------#
#  TEST 3: VALIDATE REACHABILITY
#-----------------#

/*--- Checking all endpoints reachable from start

pr()

oDiag = new stzDiagram("ReachableEndpoints")
oDiag.AddDiagramNode("start", "Start", :Start, :success)
oDiag.AddDiagramNode("process", "Process", :Process, :primary)
oDiag.AddDiagramNode("end", "End", :Endpoint, :success)
oDiag.Connect("start", "process", "")
oDiag.Connect("process", "end", "")

aResult = oDiag.ValidateReachability()
? aResult["status"] #--> pass

pf()

#-----------------#
#  TEST 4: VALIDATE COMPLETENESS
#-----------------#

/*--- Ensuring decisions have multiple paths

pr()

oDiag = new stzDiagram("Completeness")
oDiag.AddDiagramNode("d", "Approved?", :Decision, :warning)
oDiag.AddDiagramNode("yes", "Yes", :Endpoint, :success)
oDiag.AddDiagramNode("no", "No", :Endpoint, :danger)
oDiag.Connect("d", "yes", "Yes")
oDiag.Connect("d", "no", "No")

aResult = oDiag.ValidateCompleteness()
? aResult["status"] #--> pass

pf()

#-----------------#
#  TEST 5: COMPUTE METRICS
#-----------------#

/*--- Analyzing workflow path metrics

pr()

oDiag = new stzDiagram("MetricsTest")
oDiag.AddDiagramNode("start", "Start", :Start, :success)
oDiag.AddDiagramNode("p1", "Step 1", :Process, :primary)
oDiag.AddDiagramNode("p2", "Step 2", :Process, :primary)
oDiag.AddDiagramNode("end", "End", :Endpoint, :success)
oDiag.Connect("start", "p1", "")
oDiag.Connect("p1", "p2", "")
oDiag.Connect("p2", "end", "")

aMetrics = oDiag.ComputeMetrics()
? aMetrics["nodeCount"] #--> 4
? aMetrics["maxPathLength"] #--> 3

pf()

#-----------------#
#  TEST 6: ADD ANNOTATION
#-----------------#

/*--- Adding performance metadata to nodes

pr()

oDiag = new stzDiagram("Annotated")
oDiag.AddDiagramNode("process", "Process", :Process, :primary)

oPerf = new stzDiagramAnnotator(:Performance)
oPerf.Annotate("process", ["latency" = 150, "unit" = "ms"])

oDiag.AddAnnotation(oPerf)

? len(oDiag.AllAnnotations()) #--> 1
? len(oPerf.AllNodeData()) #--> 1

pf()

#-----------------#
#  TEST 7: ANNOTATIONS BY TYPE
#-----------------#

/*--- Retrieving annotations by type

pr()

oDiag = new stzDiagram("AnnotationTypes")
oDiag.AddDiagramNode("n1", "Node 1", :Process, :primary)

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
oDiag.AddDiagramNode("user_api", "User API", :Process, :success)
oDiag.AddDiagramNode("user_db", "User DB", :Storage, :success)
oDiag.AddDiagramNode("order_api", "Order API", :Process, :info)
oDiag.AddDiagramNode("order_db", "Order DB", :Storage, :info)

oDiag.AddCluster("users", "User Domain", ["user_api", "user_db"], "lightgreen")
oDiag.AddCluster("orders", "Order Domain", ["order_api", "order_db"], "lightblue")

? len(oDiag.AllClusters()) #--> 2

pf()

#-----------------#
#  TEST 9: GET CLUSTER INFO
#-----------------#

/*--- Retrieving cluster details

pr()

oDiag = new stzDiagram("ClusterInfo")
oDiag.AddDiagramNode("a", "A", :Process, :primary)
oDiag.AddDiagramNode("b", "B", :Process, :primary)

oDiag.AddCluster("domain1", "My Domain", ["a", "b"], "lightblue")

aClusters = oDiag.AllClusters()
oCluster = aClusters[1]

? oCluster["label"] #--> My Domain
? len(oCluster["nodes"]) #--> 2

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

oDiag1 = new stzDiagram("TopDownLayout")
oDiag1.SetLayout(:TopDown)
? oDiag1.@cLayout #--> TopDown

oDiag2 = new stzDiagram("LeftRightLayout")
oDiag2.SetLayout(:LeftRight)
? oDiag2.@cLayout #--> LeftRight

pf()

#-----------------#
#  TEST 12: SOX COMPLIANCE VALIDATION
#-----------------#

/*--- Validating workflow against SOX rules

pr()

oDiag = new stzDiagram("SoxPayment")
oDiag.AddDiagramNode("submit", "Submit", :Start, :success)
oDiag.AddDiagramNode("approve", "Approve?", :Decision, :warning)
oDiag.AddDiagramNode("pay", "Pay", :Process, :primary)
oDiag.AddDiagramNode("log", "Log", :Data, :neutral)
oDiag.AddDiagramNode("done", "Done", :Endpoint, :success)

oDiag.Connect("submit", "approve", "")
oDiag.Connect("approve", "pay", "Yes")
oDiag.Connect("pay", "log", "")
oDiag.Connect("log", "done", "")

oDiag.GetNode("pay")["properties"]["domain"] = :financial
oDiag.GetNode("approve")["properties"]["requiresApproval"] = TRUE

oSoxValidator = $aDiagramValidators[:SOX]
aResult = oSoxValidator.Validate(oDiag)

? aResult["domain"] #--> SOX
? aResult["issueCount"] >= 0 #--> TRUE

pf()

#-----------------#
#  TEST 13: GDPR COMPLIANCE VALIDATION
#-----------------#

/*--- Validating data flow against GDPR rules

pr()

oDiag = new stzDiagram("GdprData")
oDiag.AddDiagramNode("collect", "Collect", :Process, :primary)
oDiag.AddDiagramNode("process", "Process", :Process, :primary)
oDiag.AddDiagramNode("delete", "Delete", :Process, :info)

oDiag.Connect("collect", "process", "")
oDiag.Connect("collect", "delete", "")

oDiag.GetNode("collect")["properties"]["dataType"] = :personal
oDiag.GetNode("collect")["properties"]["requiresConsent"] = TRUE
oDiag.GetNode("collect")["properties"]["retentionPolicy"] = "1 year"
oDiag.GetNode("delete")["properties"]["operation"] = :delete

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
oDiag.AddDiagramNode("init", "Initiate", :Start, :success)
oDiag.AddDiagramNode("fraud", "Fraud Check", :Process, :info)
oDiag.AddDiagramNode("approve", "Approve?", :Decision, :warning)
oDiag.AddDiagramNode("execute", "Execute", :Process, :primary)
oDiag.AddDiagramNode("done", "Done", :Endpoint, :success)

oDiag.Connect("init", "fraud", "")
oDiag.Connect("fraud", "approve", "")
oDiag.Connect("approve", "execute", "Yes")
oDiag.Connect("execute", "done", "")

oDiag.GetNode("init")["properties"]["transactionType"] = :large
oDiag.GetNode("fraud")["properties"]["operation"] = :fraud_check
oDiag.GetNode("approve")["properties"]["role"] = :approver
oDiag.GetNode("execute")["properties"]["operation"] = :payment

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
oDiag.AddDiagramNode("n1", "Node", :Process, :primary)

aHashlist = oDiag.ToHashlist()

? aHashlist["theme"] #--> Professional
? aHashlist["nodeCount"] >= 0 #--> TRUE

pf()

/*===================================================
#  stzDiagramConvertersTest - Test Suite
#  Each test runs independently
#===================================================*/

#-----------------#
#  TEST 1: GENERATE STZDIAG FORMAT
#-----------------#

/*--- Generating .stzdiagram native text format

pr()

oDiag = new stzDiagram("FormatTest")
oDiag.SetTheme(:Professional)
oDiag.SetLayout(:TopDown)
oDiag.AddDiagramNode("start", "Begin", :Start, :success)
oDiag.AddDiagramNode("process", "Work", :Process, :primary)
oDiag.AddDiagramNode("end", "Finish", :Endpoint, :success)
oDiag.Connect("start", "process", "")
oDiag.Connect("process", "end", "")

oConv = new stzDiagramToStzDiag(oDiag)
cOutput = oConv.Generate()

? (find(cOutput, "diagram") > 0) #--> TRUE
? (find(cOutput, "nodes") > 0) #--> TRUE
? (find(cOutput, "edges") > 0) #--> TRUE

pf()

#-----------------#
#  TEST 2: WRITE STZDIAG TO FILE
#-----------------#

/*--- Saving diagram to .stzdiagram file

pr()

oDiag = new stzDiagram("SaveTest")
oDiag.AddDiagramNode("a", "Node A", :Process, :primary)
oDiag.AddDiagramNode("b", "Node B", :Process, :primary)
oDiag.Connect("a", "b", "flows")

oConv = new stzDiagramToStzDiag(oDiag)
bSuccess = oConv.WriteToFile("test_diagram.stzdiagram")

? bSuccess #--> TRUE
? file_exists("test_diagram.stzdiagram") #--> TRUE

pf()

#-----------------#
#  TEST 3: STZDIAG WITH CLUSTERS
#-----------------#

/*--- Converting diagram with cluster definitions

pr()

oDiag = new stzDiagram("ClusterTest")
oDiag.AddDiagramNode("api", "API", :Process, :success)
oDiag.AddDiagramNode("db", "DB", :Storage, :success)
oDiag.AddCluster("domain", "Service Domain", ["api", "db"], "lightblue")

oConv = new stzDiagramToStzDiag(oDiag)
cOutput = oConv.Generate()

? (find(cOutput, "clusters") > 0) #--> TRUE
? (find(cOutput, "Service Domain") > 0) #--> TRUE

pf()

#-----------------#
#  TEST 4: STZDIAG WITH ANNOTATIONS
#-----------------#

/*--- Converting diagram with annotations

pr()

oDiag = new stzDiagram("AnnotationTest")
oDiag.AddDiagramNode("process", "Process", :Process, :primary)

oPerf = new stzDiagramAnnotator(:Performance)
oPerf.Annotate("process", ["latency" = 150])
oDiag.AddAnnotation(oPerf)

oConv = new stzDiagramToStzDiag(oDiag)
cOutput = oConv.Generate()

? (find(cOutput, "annotations") > 0) #--> TRUE
? (find(cOutput, "performance") > 0) #--> TRUE

pf()

#-----------------#
#  TEST 5: CONVERT TO DOT
#-----------------#

/*--- Converting to Graphviz DOT language

pr()

oDiag = new stzDiagram("DotTest")
oDiag.AddDiagramNode("start", "Start", :Start, :success)
oDiag.AddDiagramNode("end", "End", :Endpoint, :success)
oDiag.Connect("start", "end", "")

oConv = new stzDiagramToDot(oDiag)
cOutput = oConv.Generate()

? (find(cOutput, "digraph") > 0) #--> TRUE
? (find(cOutput, "->") > 0) #--> TRUE
? (find(cOutput, "}") > 0) #--> TRUE

pf()

#-----------------#
#  TEST 6: WRITE DOT FILE
#-----------------#

/*--- Saving to DOT file

pr()

oDiag = new stzDiagram("DotFileTest")
oDiag.AddDiagramNode("a", "A", :Process, :primary)
oDiag.AddDiagramNode("b", "B", :Process, :primary)
oDiag.Connect("a", "b", "")

oConv = new stzDiagramToDot(oDiag)
bSuccess = oConv.WriteToFile("test_diagram.dot")

? bSuccess #--> TRUE
? file_exists("test_diagram.dot") #--> TRUE

pf()

#-----------------#
#  TEST 7: DOT NODE SHAPES
#-----------------#

/*--- Verifying DOT node type shapes

pr()

oDiag = new stzDiagram("DotShapesTest")
oDiag.AddDiagramNode("s", "S", :Start, :success)
oDiag.AddDiagramNode("d", "D", :Decision, :warning)
oDiag.AddDiagramNode("p", "P", :Process, :primary)
oDiag.AddDiagramNode("e", "E", :Endpoint, :success)

oConv = new stzDiagramToDot(oDiag)
cOutput = oConv.Generate()

? (find(cOutput, "polygon") > 0) #--> TRUE
? (find(cOutput, "diamond") > 0) #--> TRUE
? (find(cOutput, "box") > 0) #--> TRUE
? (find(cOutput, "doublecircle") > 0) #--> TRUE

pf()

#-----------------#
#  TEST 8: CONVERT TO MERMAID
#-----------------#

/*--- Converting to Mermaid.js syntax

pr()

oDiag = new stzDiagram("MermaidTest")
oDiag.AddDiagramNode("start", "Start", :Start, :success)
oDiag.AddDiagramNode("decision", "Check", :Decision, :warning)
oDiag.AddDiagramNode("process", "Process", :Process, :primary)
oDiag.AddDiagramNode("end", "End", :Endpoint, :success)

oDiag.Connect("start", "decision", "")
oDiag.Connect("decision", "process", "Yes")
oDiag.Connect("process", "end", "")

oConv = new stzDiagramToMermaid(oDiag)
cOutput = oConv.Generate()

? (find(cOutput, "graph TD") > 0) #--> TRUE
? (find(cOutput, "-->") > 0) #--> TRUE

pf()

#-----------------#
#  TEST 9: WRITE MERMAID FILE
#-----------------#

/*--- Saving to Mermaid file

pr()

oDiag = new stzDiagram("MermaidFileTest")
oDiag.AddDiagramNode("a", "A", :Process, :primary)
oDiag.AddDiagramNode("b", "B", :Process, :primary)
oDiag.Connect("a", "b", "leads")

oConv = new stzDiagramToMermaid(oDiag)
bSuccess = oConv.WriteToFile("test_diagram.mmd")

? bSuccess #--> TRUE
? file_exists("test_diagram.mmd") #--> TRUE

pf()

#-----------------#
#  TEST 10: MERMAID NODE SHAPES
#-----------------#

/*--- Verifying Mermaid node type shapes

pr()

oDiag = new stzDiagram("MermaidShapesTest")
oDiag.AddDiagramNode("s", "S", :Start, :success)
oDiag.AddDiagramNode("d", "D", :Decision, :warning)
oDiag.AddDiagramNode("e", "E", :Endpoint, :success)

oConv = new stzDiagramToMermaid(oDiag)
cOutput = oConv.Generate()

? (find(cOutput, "([") > 0) #--> TRUE
? (find(cOutput, "{{") > 0) #--> TRUE

pf()

#-----------------#
#  TEST 11: CONVERT TO JSON
#-----------------#

/*--- Converting to JSON format

pr()

oDiag = new stzDiagram("JsonTest")
oDiag.SetTheme(:Professional)
oDiag.AddDiagramNode("a", "A", :Process, :primary)
oDiag.AddDiagramNode("b", "B", :Process, :primary)
oDiag.Connect("a", "b", "")

oConv = new stzDiagramToJSON(oDiag)
cOutput = oConv.Generate()

? (find(cOutput, "{") > 0) #--> TRUE
? (find(cOutput, "}") > 0) #--> TRUE
? (find(cOutput, "Professional") > 0) #--> TRUE

pf()

#-----------------#
#  TEST 12: WRITE JSON FILE
#-----------------#

/*--- Saving to JSON file

pr()

oDiag = new stzDiagram("JsonFileTest")
oDiag.AddDiagramNode("x", "X", :Process, :primary)

oConv = new stzDiagramToJSON(oDiag)
bSuccess = oConv.WriteToFile("test_diagram.json")

? bSuccess #--> TRUE
? file_exists("test_diagram.json") #--> TRUE

pf()

#-----------------#
#  TEST 13: JSON STRUCTURE
#-----------------#

/*--- Verifying JSON structure fields

pr()

oDiag = new stzDiagram("JsonStructureTest")
oDiag.AddDiagramNode("n", "Node", :Process, :primary)

oConv = new stzDiagramToJSON(oDiag)
cOutput = oConv.Generate()

? (find(cOutput, "id") > 0) #--> TRUE
? (find(cOutput, "nodes") > 0) #--> TRUE
? (find(cOutput, "edges") > 0) #--> TRUE

pf()

#-----------------#
#  TEST 14: MULTI-FORMAT EXPORT
#-----------------#

/*--- Exporting to all formats simultaneously

pr()

oDiag = new stzDiagram("MultiFormatTest")
oDiag.AddDiagramNode("start", "S", :Start, :success)
oDiag.AddDiagramNode("end", "E", :Endpoint, :success)
oDiag.Connect("start", "end", "")

oStzdiag = new stzDiagramToStzDiag(oDiag)
oDot = new stzDiagramToDot(oDiag)
oMermaid = new stzDiagramToMermaid(oDiag)
oJSON = new stzDiagramToJSON(oDiag)

oStzdiag.WriteToFile("multi_test.stzdiagram")
oDot.WriteToFile("multi_test.dot")
oMermaid.WriteToFile("multi_test.mmd")
oJSON.WriteToFile("multi_test.json")

? file_exists("multi_test.stzdiagram") #--> TRUE
? file_exists("multi_test.dot") #--> TRUE
? file_exists("multi_test.mmd") #--> TRUE
? file_exists("multi_test.json") #--> TRUE

pf()

#-----------------#
#  TEST 15: EDGE LABELS PRESERVATION
#-----------------#

/*--- Verifying edge labels in all formats

pr()

oDiag = new stzDiagram("EdgeLabelTest")
oDiag.AddDiagramNode("a", "A", :Process, :primary)
oDiag.AddDiagramNode("b", "B", :Process, :primary)
oDiag.Connect("a", "b", "important")

oStzdiag = new stzDiagramToStzDiag(oDiag)
cStzOutput = oStzdiag.Generate()

oDot = new stzDiagramToDot(oDiag)
cDotOutput = oDot.Generate()

oMermaid = new stzDiagramToMermaid(oDiag)
cMermaidOutput = oMermaid.Generate()

? (find(cStzOutput, "important") > 0) #--> TRUE
? (find(cDotOutput, "important") > 0) #--> TRUE
? (find(cMermaidOutput, "important") > 0) #--> TRUE

pf()
