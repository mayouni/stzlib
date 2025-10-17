load "../stzbase.ring"

/*===================================================
#  stzGraph & stzDiagram - Test Suite
#  Each test runs independently - execute one at a time
#===================================================*/

#-----------------#
#  TEST 1: BASIC GRAPH CREATION
#-----------------#

/*--- Creating a simple 3-node linear graph

pr()

oGraph = new stzGraph("SimpleGraph")
oGraph.AddNode("n1", "Node 1", [:])
oGraph.AddNode("n2", "Node 2", [:])
oGraph.AddNode("n3", "Node 3", [:])
oGraph.AddEdge("n1", "n2", "connects", [:])
oGraph.AddEdge("n2", "n3", "flows", [:])

? oGraph.NodeCount() #--> 3
? oGraph.EdgeCount() #--> 2

pf()

#-----------------#
#  TEST 2: PATH EXISTS - BASIC CONNECTIVITY
#-----------------#

/*--- Testing path existence between nodes

pr()

oGraph = new stzGraph("PathTest")
oGraph.AddNode("start", "Start", [:])
oGraph.AddNode("middle", "Middle", [:])
oGraph.AddNode("end", "End", [:])
oGraph.AddNode("isolated", "Isolated", [:])
oGraph.AddEdge("start", "middle", "", [:])
oGraph.AddEdge("middle", "end", "", [:])

? oGraph.PathExists("start", "end") #--> TRUE
? oGraph.PathExists("start", "isolated") #--> FALSE

pf()

#-----------------#
#  TEST 3: REACHABLE NODES
#-----------------#

/*--- Finding all nodes reachable from a given node

pr()

oGraph = new stzGraph("ReachabilityTest")
oGraph.AddNode("a", "A", [:])
oGraph.AddNode("b", "B", [:])
oGraph.AddNode("c", "C", [:])
oGraph.AddNode("d", "D", [:])
oGraph.AddEdge("a", "b", "", [:])
oGraph.AddEdge("b", "c", "", [:])
oGraph.AddEdge("a", "d", "", [:])

aReachable = oGraph.ReachableFrom("a")
? len(aReachable) #--> 4

pf()

#-----------------#
#  TEST 4: FIND ALL PATHS - DIAMOND SHAPE
#-----------------#

/*--- Enumerating all routes between two nodes in a diamond graph

pr()

oGraph = new stzGraph("AllPathsTest")
oGraph.AddNode("a", "A", [:])
oGraph.AddNode("b", "B", [:])
oGraph.AddNode("c", "C", [:])
oGraph.AddNode("d", "D", [:])
oGraph.AddEdge("a", "b", "", [:])
oGraph.AddEdge("a", "c", "", [:])
oGraph.AddEdge("b", "d", "", [:])
oGraph.AddEdge("c", "d", "", [:])

aAllPaths = oGraph.FindAllPaths("a", "d")
? len(aAllPaths) #--> 2

pf()

#-----------------#
#  TEST 5: ACYCLIC GRAPH DETECTION
#-----------------#

/*--- Verifying a valid DAG (no cycles)

pr()

oGraph = new stzGraph("AcyclicTest")
oGraph.AddNode("n1", "N1", [:])
oGraph.AddNode("n2", "N2", [:])
oGraph.AddNode("n3", "N3", [:])
oGraph.AddEdge("n1", "n2", "", [:])
oGraph.AddEdge("n2", "n3", "", [:])

? oGraph.CyclicDependencies() #--> FALSE

pf()

#-----------------#
#  TEST 6: CYCLIC GRAPH DETECTION
#-----------------#

/*--- Identifying cycles in graph (invalid workflow)

pr()

oGraph = new stzGraph("CyclicTest")
oGraph.AddNode("p1", "P1", [:])
oGraph.AddNode("p2", "P2", [:])
oGraph.AddNode("p3", "P3", [:])
oGraph.AddEdge("p1", "p2", "", [:])
oGraph.AddEdge("p2", "p3", "", [:])
oGraph.AddEdge("p3", "p1", "", [:])

? oGraph.CyclicDependencies() #--> TRUE

pf()

#-----------------#
#  TEST 7: BOTTLENECK NODES
#-----------------#

/*--- Finding highly-connected hub nodes

pr()

oGraph = new stzGraph("BottleneckTest")
oGraph.AddNode("a", "A", [:])
oGraph.AddNode("b", "B", [:])
oGraph.AddNode("c", "C", [:])
oGraph.AddNode("hub", "Hub", [:])
oGraph.AddEdge("a", "hub", "", [:])
oGraph.AddEdge("b", "hub", "", [:])
oGraph.AddEdge("c", "hub", "", [:])
oGraph.AddEdge("hub", "a", "", [:])

aBottlenecks = oGraph.BottleneckNodes()
? aBottlenecks #--> [hub]

pf()

#-----------------#
#  TEST 8: GRAPH DENSITY
#-----------------#

/*--- Measuring connection density

pr()

oGraph = new stzGraph("DensityTest")
oGraph.AddNode("n1", "N1", [:])
oGraph.AddNode("n2", "N2", [:])
oGraph.AddNode("n3", "N3", [:])
oGraph.AddEdge("n1", "n2", "", [:])
oGraph.AddEdge("n2", "n3", "", [:])
oGraph.AddEdge("n1", "n3", "", [:])

nDensity = oGraph.NodeDensity()
? nDensity #--> 100 (fully connected triangle)

pf()

#-----------------#
#  TEST 9: CREATE SIMPLE DIAGRAM
#-----------------#

/*--- Building workflow diagram with node types and colors

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
#  TEST 10: VALIDATE DAG
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
#  TEST 11: VALIDATE REACHABILITY
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
? aResult[:status] #--> pass

pf()

#-----------------#
#  TEST 12: VALIDATE COMPLETENESS
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
? aResult[:status] #--> pass

pf()

#-----------------#
#  TEST 13: COMPUTE METRICS
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
? aMetrics[:nodeCount] #--> 4
? aMetrics[:maxPathLength] #--> 3

pf()

#-----------------#
#  TEST 14: ADD ANNOTATION
#-----------------#

/*--- Adding performance metadata to nodes

pr()

oDiag = new stzDiagram("Annotated")
oDiag.AddDiagramNode("process", "Process", :Process, :primary)

oPerf = new stzDiagramAnnotation(:Performance)
oPerf.MapNode("process", [latency: 150, unit: "ms"])

oDiag.AddAnnotation(oPerf)

? len(oDiag.AllAnnotations()) #--> 1
? len(oPerf.AllNodeData()) #--> 1

pf()

#-----------------#
#  TEST 15: ADD CLUSTERS
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
#  TEST 16: SERIALIZE TO STZDIAGRAM
#-----------------#

/*--- Saving workflow to .stzdiagram file

pr()

oDiag = new stzDiagram("SaveTest")
oDiag.SetTheme(:Professional)
oDiag.AddDiagramNode("start", "Begin", :Start, :success)
oDiag.AddDiagramNode("end", "Finish", :Endpoint, :success)
oDiag.Connect("start", "end", "")

oSerializer = new stzDiagramSerializerStzdiag(oDiag)
oSerializer.WriteToFile("test_save.stzdiagram")

? "File saved" #--> File saved

pf()

#-----------------#
#  TEST 17: DESERIALIZE FROM STZDIAGRAM
#-----------------#

/*--- Loading workflow from .stzdiagram file

pr()

oLoader = new stzDiagramSerializerStzdiag(NULL)
oLoaded = oLoader.ReadFromFile("test_save.stzdiagram")

? oLoaded.Id() #--> SaveTest
? oLoaded.NodeCount() #--> 2

pf()

#-----------------#
#  TEST 18: EXPORT TO DOT
#-----------------#

/*--- Converting to Graphviz DOT format

pr()

oDiag = new stzDiagram("DotExport")
oDiag.AddDiagramNode("a", "Node A", :Process, :primary)
oDiag.AddDiagramNode("b", "Node B", :Process, :primary)
oDiag.Connect("a", "b", "")

oDot = new stzDiagramSerializerDot(oDiag)
oDot.WriteToFile("test_export.dot")

? "DOT file created" #--> DOT file created

pf()

#-----------------#
#  TEST 19: EXPORT TO MERMAID
#-----------------#

/*--- Converting to Mermaid format

pr()

oDiag = new stzDiagram("MermaidExport")
oDiag.AddDiagramNode("start", "Start", :Start, :success)
oDiag.AddDiagramNode("end", "End", :Endpoint, :success)
oDiag.Connect("start", "end", "")

oMermaid = new stzDiagramSerializerMermaid(oDiag)
oMermaid.WriteToFile("test_export.mmd")

? "Mermaid file created" #--> Mermaid file created

pf()

#-----------------#
#  TEST 20: EXPORT TO JSON
#-----------------#

/*--- Converting to JSON format

pr()

oDiag = new stzDiagram("JsonExport")
oDiag.AddDiagramNode("x", "Value", :Process, :primary)

oJSON = new stzDiagramSerializerJSON(oDiag)
oJSON.WriteToFile("test_export.json")

? "JSON file created" #--> JSON file created

pf()

#-----------------#
#  TEST 21: SOX COMPLIANCE VALIDATION
#-----------------#

/*--- Validating financial workflow against SOX rules

pr()

InitializeComplianceRegistry()

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

oDiag.GetNode("pay")[:properties][:domain] = :financial
oDiag.GetNode("approve")[:properties][:requiresApproval] = TRUE

aResult = $gComplianceRegistry.ValidateDiagram(oDiag, :SOX)
? aResult[:status] #--> pass or fail

pf()

#-----------------#
#  TEST 22: GDPR COMPLIANCE VALIDATION
#-----------------#

/*--- Validating data processing against GDPR rules

pr()

InitializeComplianceRegistry()

oDiag = new stzDiagram("GdprData")
oDiag.AddDiagramNode("collect", "Collect", :Process, :primary)
oDiag.AddDiagramNode("process", "Process", :Process, :primary)
oDiag.AddDiagramNode("delete", "Delete", :Process, :info)

oDiag.Connect("collect", "process", "")
oDiag.Connect("collect", "delete", "")

oDiag.GetNode("collect")[:properties][:dataType] = :personal
oDiag.GetNode("collect")[:properties][:requiresConsent] = TRUE
oDiag.GetNode("collect")[:properties][:retentionPolicy] = "1 year"
oDiag.GetNode("delete")[:properties][:operation] = :delete

aResult = $gComplianceRegistry.ValidateDiagram(oDiag, :GDPR)
? aResult[:status] #--> pass or fail

pf()

#-----------------#
#  TEST 23: BANKING COMPLIANCE VALIDATION
#-----------------#

/*--- Validating transaction against banking rules

pr()

InitializeComplianceRegistry()

oDiag = new stzDiagram("BankingTx")
oDiag.AddDiagramNode("init", "Initiate", :Start, :success)
oDiag.AddDiagramNode("fraud", "Fraud Check", :Process, :info)
oDiag.AddDiagramNode("approve", "Approve?", :Decision, :warning)
oDiag.AddDiagramNode("execute", "Execute", :Process, :primary)
oDiag.AddDiagramNode("recon", "Reconcile", :Data, :neutral)
oDiag.AddDiagramNode("done", "Done", :Endpoint, :success)

oDiag.Connect("init", "fraud", "")
oDiag.Connect("fraud", "approve", "")
oDiag.Connect("approve", "execute", "Yes")
oDiag.Connect("execute", "recon", "")
oDiag.Connect("recon", "done", "")

oDiag.GetNode("init")[:properties][:transactionType] = :large
oDiag.GetNode("fraud")[:properties][:operation] = :fraud_check
oDiag.GetNode("approve")[:properties][:role] = :approver
oDiag.GetNode("execute")[:properties][:operation] = :payment
oDiag.GetNode("execute")[:properties][:criticality] = :high

aResult = $gComplianceRegistry.ValidateDiagram(oDiag, :Banking)
? aResult[:status] #--> pass or fail

pf()
