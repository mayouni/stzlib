load "stzlib.ring"


#============================================#
#  SECTION 1: BASIC GRAPH OPERATIONS
#============================================#

/*--- Creating Simple Graph

pr()

oGraph = new stzGraph("SimpleGraph")
oGraph {
	AddNodeXT("n1", "Node 1")
	AddNodeXT("n2", "Node 2")
	AddNodeXT("n3", "Node 3")
	
	Connect("n1", "n2")
	Connect("n2", "n3")
	
	? NodeCount() #--> 3
	? EdgeCount() #--> 2
}

pf()

/*--- Node and Edge Existence

pr()

oGraph = new stzGraph("ExistenceTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	Connect("a", "b")
	
	? HasNode("a")         #--> TRUE
	? HasNode("missing")   #--> FALSE
	? EdgeExists("a", "b") #--> TRUE
	? EdgeExists("b", "a") #--> FALSE
}

pf()

/*--- Path Finding

pr()

oGraph = new stzGraph("PathTest")
oGraph {
	AddNodeXT("start", "Start")
	AddNodeXT("middle", "Middle")
	AddNodeXT("end", "End")
	
	Connect("start", "middle")
	Connect("middle", "end")
	
	? PathExists("start", "end")      #--> TRUE
	? PathExists("start", "isolated") #--> FALSE
	
	? @@NL( FindAllPaths("start", "end") )
	#--> [ ["start", "middle", "end"] ]
}

pf()

/*--- Reachability

pr()

oGraph = new stzGraph("ReachTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	AddNodeXT("d", "D")
	
	Connect("a", "b")
	Connect("b", "c")
	Connect("a", "d")
	
	? @@( ReachableFrom("a") )
	#--> ["a", "b", "d", "c"]
}

pf()

/*--- Neighbors and Incoming

pr()

oGraph = new stzGraph("ConnectionsTest")
oGraph {
	AddNodeXT("hub", "Hub")
	AddNodeXT("n1", "N1")
	AddNodeXT("n2", "N2")
	AddNodeXT("n3", "N3")
	
	Connect("n1", "hub")
	Connect("n2", "hub")
	Connect("hub", "n3")
	
	? @@( Neighbors("hub") )    #--> ["n3"]
	? @@( Incoming("hub") )     #--> ["n1", "n2"]
}

pf()

#============================================#
#  SECTION 2: NODE OPERATIONS
#============================================#

/*--- Node Navigation

pr()

oGraph = new stzGraph("NavTest")
oGraph {
	AddNodeXT("first", "First")
	AddNodeXT("second", "Second")
	AddNodeXT("third", "Third")
	
	? FirstNode()["label"]   #--> "First"
	? LastNode()["label"]    #--> "Third"
	? NodeAt(2)["label"]     #--> "Second"
	? NodePosition("second") #--> 2
}

pf()

/*--- Node Properties

pr()

oGraph = new stzGraph("PropsTest")
oGraph {
	AddNodeXTT("n1", "Node 1", [:priority = 10, :status = "active"])
	
	? NodeProperty("n1", "priority")  #--> 10
	
	SetNodeProperty("n1", "owner", "alice")
	? NodeProperty("n1", "owner")     #--> "alice"
	
	? @@( Properties() )              #--> ["priority", "status", "owner"]
	? @@NL( PropertiesXT() )
	#--> [["priority", [10]], ["status", ["active"]], ["owner", ["alice"]]]
}

pf()

/*--- Node Removal

pr()

oGraph = new stzGraph("RemoveTest")
oGraph {
	AddNodeXT("n1", "N1")
	AddNodeXT("n2", "N2")
	AddNodeXT("n3", "N3")
	Connect("n1", "n2")
	Connect("n2", "n3")
	
	RemoveThisNode("n2")
	? NodeCount() #--> 2
	? EdgeCount() #--> 0
	
	RemoveTheseNodes(["n1", "n3"])
	? NodeCount() #--> 0
}

pf()

/*--- Node Replacement

pr()

oGraph = new stzGraph("ReplaceTest")
oGraph {
	AddNodeXTT("old", "Old", [:type = "test"])
	AddNodeXT("other", "Other")
	Connect("old", "other")
	
	ReplaceThisNode("old", "new")
	? HasNode("old")  #--> FALSE
	? HasNode("new")  #--> TRUE
	? EdgeExists("new", "other") #--> TRUE
}

pf()

/*--- Node Copy and Duplicate

pr()

oGraph = new stzGraph("CopyTest")
oGraph {
	AddNodeXTT("template", "Template", [:color = "blue"])
	AddNodeXT("next", "Next")
	Connect("template", "next")
	
	DuplicateNode("template", "copy1")
	? Node("copy1")["properties"]["color"] #--> "blue"
	
	DuplicateNodeWithEdges("template", "copy2")
	? EdgeExists("copy2", "next") #--> TRUE
}

pf()

/*--- Node Merge

pr()

oGraph = new stzGraph("MergeTest")
oGraph {
	AddNodeXT("s1", "Server 1")
	AddNodeXT("s2", "Server 2")
	AddNodeXT("lb", "Load Balancer")
	AddNodeXT("db", "Database")
	
	Connect("lb", "s1")
	Connect("lb", "s2")
	Connect("s1", "db")
	Connect("s2", "db")
	
	MergeNodes(["s1", "s2"], "cluster", "Cluster")
	? NodeCount() #--> 3
	? EdgeExists("lb", "cluster") #--> TRUE
	? EdgeExists("cluster", "db") #--> TRUE
}

pf()

/*--- Insert Nodes

pr()

oGraph = new stzGraph("InsertTest")
oGraph {
	AddNodeXT("n1", "N1")
	AddNodeXT("n3", "N3")
	Connect("n1", "n3")
	
	InsertNodeBefore("n3", "n2", "N2")
	? EdgeExists("n1", "n2") #--> TRUE
	? EdgeExists("n2", "n3") #--> TRUE
	
	InsertNodeAfter("n3", "n4", "N4")
	? EdgeExists("n3", "n4") #--> TRUE
}

pf()

/*--- Batch Update

pr()

oGraph = new stzGraph("BatchTest")
oGraph {
	AddNodeXTT("n1", "N1", [:priority = 1])
	AddNodeXTT("n2", "N2", [:priority = 2])
	
	UpdateNodes(func(aNode) {
		if HasKey(aNode["properties"], "priority")
			aNode["properties"]["priority"] += 10
		ok
	})
	
	? Node("n1")["properties"]["priority"] #--> 11
}

pf()

#============================================#
#  SECTION 3: PROPERTY & TAG QUERIES
#============================================#

/*--- Property Queries

pr()

oGraph = new stzGraph("PropQueryTest")
oGraph {
	AddNodeXTT("n1", "N1", [:env = "prod", :cost = 100])
	AddNodeXTT("n2", "N2", [:env = "test", :cost = 50])
	AddNodeXTT("n3", "N3", [:env = "prod", :cost = 200])
	
	? @@( NodesWithProperty("env") )
	#--> ["n1", "n2", "n3"]
	
	? @@( NodesWithPropertyValue("env", "prod") )
	#--> ["n1", "n3"]
	
	? @@( NodesWithPropertyInSection("cost", 75, 150) )
	#--> ["n1"]
}

pf()

/*--- Tag Queries

pr()

oGraph = new stzGraph("TagQueryTest")
oGraph {
	AddNodeXTT("n1", "N1", [:tags = ["critical", "production"]])
	AddNodeXTT("n2", "N2", [:tags = ["production"]])
	AddNodeXTT("n3", "N3", [:tags = ["critical", "monitoring"]])
	
	? @@( NodesWithTag("critical") )
	#--> ["n1", "n3"]
	
	? @@( NodesWithAllTags(["critical", "production"]) )
	#--> ["n1"]
	
	? @@( NodesWithAnyTag(["critical", "monitoring"]) )
	#--> ["n1", "n3"]
}

pf()

#============================================#
#  SECTION 4: GRAPH ANALYSIS
#============================================#

/*--- Cycle Detection

pr()

oGraph = new stzGraph("CycleTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	
	Connect("a", "b")
	Connect("b", "c")
	Connect("c", "a")
	
	? CyclicDependencies() #--> TRUE
}

pf()

/*--- Bottleneck Detection

pr()

oGraph = new stzGraph("BottleneckTest")
oGraph {
	AddNodeXT("hub", "Hub")
	AddNodeXT("n1", "N1")
	AddNodeXT("n2", "N2")
	AddNodeXT("n3", "N3")
	
	Connect("n1", "hub")
	Connect("n2", "hub")
	Connect("n3", "hub")
	Connect("hub", "n1")
	
	? @@( BottleneckNodes() ) #--> ["hub"]
}

pf()

/*--- Graph Metrics

pr()

oGraph = new stzGraph("MetricsTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	
	Connect("a", "b")
	Connect("b", "c")
	Connect("a", "c")
	
	? NodeDensity()  #--> 50
	? LongestPath()  #--> 2
}

pf()

/*--- Parallelizable Branches

pr()

oGraph = new stzGraph("ParallelTest")
oGraph {
	AddNodeXT("start", "Start")
	AddNodeXT("pathA", "Path A")
	AddNodeXT("pathB", "Path B")
	AddNodeXT("endA", "End A")
	AddNodeXT("endB", "End B")
	
	Connect("start", "pathA")
	Connect("start", "pathB")
	Connect("pathA", "endA")
	Connect("pathB", "endB")
	
	? @@( ParallelizableBranches() )
	#--> [["pathA", "pathB"]]
}

pf()

/*--- Impact Analysis

pr()

oGraph = new stzGraph("ImpactTest")
oGraph {
	AddNodeXT("db", "Database")
	AddNodeXT("api", "API")
	AddNodeXT("worker1", "Worker1")
	AddNodeXT("worker2", "Worker2")
	
	Connect("db", "api")
	Connect("api", "worker1")
	Connect("api", "worker2")
	
	? ImpactOf("api")           #--> 2
	? @@( FailureScope("api") ) #--> ["worker1", "worker2"]
	? @@( MostCriticalNodes(2) ) #--> ["api", "db"]
}

pf()

#============================================#
#  SECTION 5: UNIFIED RULE SYSTEM
#============================================#

/*--- Validation Rule

pr()

oGraph = new stzGraph("ValidationTest")

oRule = new stzGraphRule("requireapproval")
oRule {
	When("isapproved", :equals = FALSE)
	SetInvalid()
	AddViolation("Requires approval")
}

oGraph {
	SetRule(oRule)
	
	AddNodeXTT("task1", "Task 1", [:isapproved = FALSE])
	AddNodeXTT("task2", "Task 2", [:isapproved = TRUE])
	
	ApplyRules()
	
	? Node("task1")["properties"]["isvalid"]    #--> FALSE
	? Node("task1")["properties"]["violation"]  #--> "Requires approval"
	? HasKey(Node("task2")["properties"], "isvalid") #--> FALSE
}

pf()

/*--- Inference Rule

pr()

oGraph = new stzGraph("InferenceTest")

oRule = new stzGraphRule("transitivity")
oRule {
	When("pathexists", :to = "c")
	AddEdge("a", "c")
}

oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	
	Connect("a", "b")
	Connect("b", "c")
	
	SetRule(oRule)
	ApplyRules()
	
	? EdgeCount() #--> 3 (original 2 + inferred 1)
}

pf()

/*--- Property-based Rule

pr()

oGraph = new stzGraph("PropRuleTest")

oRule = new stzGraphRule("highcost")
oRule {
	When("cost", :InSection = [500, 9999])
	SetProperty("requiresapproval", TRUE)
	SetProperty("level", "high")
}

oGraph {
	SetRule(oRule)
	
	AddNodeXTT("n1", "N1", [:cost = 100])
	AddNodeXTT("n2", "N2", [:cost = 800])
	
	ApplyRules()
	
	? HasKey(Node("n1")["properties"], "requiresapproval") #--> FALSE
	? Node("n2")["properties"]["requiresapproval"]         #--> TRUE
	? Node("n2")["properties"]["level"]                    #--> "high"
}

pf()

/*--- Rule Analysis

pr()

oGraph = new stzGraph("RuleAnalysisTest")

oRule1 = new stzGraphRule("critical")
oRule1 {
	WhenTagExists("critical")
	SetProperty("alert", TRUE)
}

oRule2 = new stzGraphRule("production")
oRule2 {
	When("env", :equals = "prod")
	SetProperty("monitor", TRUE)
}

oGraph {
	SetRule(oRule1)
	SetRule(oRule2)
	
	AddNodeXTT("n1", "N1", [:env = "prod", :tags = ["critical"]])
	AddNodeXTT("n2", "N2", [:env = "test"])
	
	ApplyRules()
	
	? @@( NodesAffectedByRules() )
	#--> ["n1", "n2"]
	
	? @@( NodesAffectedByRule("critical") )
	#--> ["n1"]
	
	aInfo = RulesApplied()
	? aInfo[:hasEffects] #--> TRUE
	? aInfo[:summary]    #--> "2 rule(s) defined, 2 element(s) affected"
}

pf()

#============================================#
#  SECTION 6: EXPORT & VISUALIZATION
#============================================#

/*--- DOT Export

pr()

oGraph = new stzGraph("ExportTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	Connect("a", "b")
	
	? BoxRound("DOT FORMAT")
	? Dot()
}

pf()

/*--- JSON Export

pr()

oGraph = new stzGraph("JSONTest")
oGraph {
	AddNodeXT("input", "Input")
	AddNodeXT("output", "Output")
	Connect("input", "output")
	
	? BoxRound("JSON FORMAT")
	? Json()
}

pf()

/*--- Custom Exporter

pr()

oGraph = new stzGraph("CustomTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	Connect("a", "b")
	
	RegisterExporter("SIMPLE", func {
		return "Nodes: " + This.NodeCount() + ", Edges: " + This.EdgeCount()
	})
	
	? ExportUsing("SIMPLE")
	#--> "Nodes: 2, Edges: 1"
}

pf()

/*--- ASCII Visualization

pr()

oGraph = new stzGraph("VisTest")
oGraph {
	AddNodeXT("start", "Start")
	AddNodeXT("middle", "Middle")
	AddNodeXT("end", "End")
	
	Connect("start", "middle")
	Connect("middle", "end")
	
	Show()
	ShowH()
}

pf()

#============================================#
#  SECTION 7: SNAPSHOTS & TEMPORAL
#============================================#

/*--- Snapshot Management

pr()

oGraph = new stzGraph("SnapshotTest")
oGraph {
	AddNodeXT("n1", "N1")
	AddNodeXT("n2", "N2")
	Connect("n1", "n2")
	
	Snapshot("v1")
	
	AddNodeXT("n3", "N3")
	Connect("n2", "n3")
	
	? @@( Snapshots() ) #--> ["v1"]
	
	aChanges = ChangesSince("v1")
	? @@( aChanges[:nodesAdded] )  #--> ["n3"]
	? @@( aChanges[:edgesAdded] )  #--> [["n2", "n3"]]
	
	RestoreSnapshot("v1")
	? NodeCount() #--> 2
}

pf()

#============================================#
#  SECTION 8: EXPLAIN FEATURE
#============================================#

/*--- Graph Explanation

pr()

oGraph = new stzGraph("ExplainTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	
	Connect("a", "b")
	Connect("b", "c")
	Connect("c", "a")
	
	? @@NL( Explain() )
	#-->
	# [
	#   ["id", "ExplainTest"],
	#   ["type", "graph"],
	#   ["structure", "Graph 'ExplainTest' contains 3 nodes and 3 edges."],
	#   ["rules", "No rules defined."],
	#   ["effects", "No rules matched any elements."]
	# ]
}

pf()

#============================================#
#  SECTION 9: ADVANCED QUERYING
#============================================#

/*--- Query by Pattern

pr()

oGraph = new stzGraph("QueryTest")
oGraph {
	AddNodeXTT("svc1", "Service 1", [:type = "backend"])
	AddNodeXTT("svc2", "Service 2", [:type = "frontend"])
	AddNodeXTT("db1", "Database", [:type = "backend"])
	
	? @@( NodesByType("backend") )
	#--> ["svc1", "db1"]
	
	? @@( NodesByProperty("type", "frontend") )
	#--> ["svc2"]
}

pf()

/*--- Find Node Paths

pr()

oGraph = new stzGraph("FindTest")
oGraph {
	AddNodeXT("start", "Start")
	AddNodeXT("mid1", "Mid1")
	AddNodeXT("mid2", "Mid2")
	AddNodeXT("target", "Target")
	
	Connect("start", "mid1")
	Connect("mid1", "target")
	Connect("start", "mid2")
	Connect("mid2", "target")
	
	? @@NL( FindNode("target") )
	#--> [
	#   ["start", "mid1", "target"],
	#   ["start", "mid2", "target"]
	# ]
}

pf()

/*--- Path Matching

pr()

oGraph = new stzGraph("PathMatchTest")
oGraph {
	AddNodeXT("n1", "N1")
	AddNodeXT("n2", "N2")
	AddNodeXT("n3", "N3")
	AddNodeXT("n4", "N4")
	
	Connect("n1", "n2")
	Connect("n2", "n3")
	Connect("n3", "n4")
	Connect("n1", "n4")
	
	aPaths = FindPathsMatching(func(acPath) {
		return len(acPath) >= 3
	})
	
	? @@NL( aPaths )
	#--> [["n1", "n2", "n3"], ["n2", "n3", "n4"], ["n1", "n2", "n3", "n4"]]
}

pf()

/*--- Edge Property Queries

pr()

oGraph = new stzGraph("EdgePropTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	
	AddEdgeXTT("a", "b", "fast", [:speed = 100])
	AddEdgeXTT("b", "c", "slow", [:speed = 10])
	
	? @@( EdgesByProperty("speed", 100) )
	#--> [["a", "b"]]
}

pf()

#============================================#
#  SECTION 10: METADATA OPERATIONS
#============================================#

/*--- Node Metadata

pr()

oGraph = new stzGraph("MetadataTest")
oGraph {
	AddNodeXT("n1", "Node 1")
	
	SetNodeMetadata("n1", [:owner = "alice", :created = "2024-01-01"])
	
	? @@( GetNodeMetadata("n1") )
	#--> [:owner = "alice", :created = "2024-01-01"]
	
	UpdateNodeMetadata("n1", "modified", "2024-01-15")
	
	? GetNodeMetadata("n1")["modified"]
	#--> "2024-01-15"
	
	RemoveNodeMetadata("n1")
	? @@( GetNodeMetadata("n1") )
	#--> []
}

pf()

/*--- Edge Metadata

pr()

oGraph = new stzGraph("EdgeMetaTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	Connect("a", "b")
	
	SetEdgeMetadata("a", "b", [:bandwidth = 1000, :protocol = "tcp"])
	
	? @@( GetEdgeMetadata("a", "b") )
	#--> [:bandwidth = 1000, :protocol = "tcp"]
	
	UpdateEdgeMetadata("a", "b", "latency", 5)
	
	? GetEdgeMetadata("a", "b")["latency"]
	#--> 5
}

pf()

#============================================#
#  SECTION 11: INFERENCE & KNOWLEDGE
#============================================#

/*--- Built-in Inference

pr()

oGraph = new stzGraph("InferTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	
	Connect("a", "b")
	Connect("b", "c")
	
	AddInferenceRule("TRANSITIVITY")
	
	nInferred = ApplyInference()
	? nInferred  #--> 1
	? EdgeCount() #--> 3
	
	? @@( InferredEdges() )
	#--> [[:from = "a", :to = "c", :label = "(inferred)", :properties = []]]
}

pf()

/*--- Symmetry Inference

pr()

oGraph = new stzGraph("SymmetryTest")
oGraph {
	AddNodeXT("x", "X")
	AddNodeXT("y", "Y")
	
	AddEdgeXT("x", "y", "connected")
	
	AddInferenceRule("SYMMETRY")
	
	nInferred = ApplyInference()
	? nInferred   #--> 1
	? EdgeExists("y", "x") #--> TRUE
}

pf()

/*--- Custom Inference

pr()

oGraph = new stzGraph("CustomInferTest")
oGraph {
	AddNodeXTT("n1", "N1", [:type = "server"])
	AddNodeXTT("n2", "N2", [:type = "server"])
	AddNodeXTT("db", "DB", [:type = "database"])
	
	Connect("n1", "db")
	
	RegisterInferenceRule("SAME_TYPE", func {
		nCount = 0
		aNodes = This.Nodes()
		nLen = len(aNodes)
		
		for i = 1 to nLen
			for j = i + 1 to nLen
				aNode1 = aNodes[i]
				aNode2 = aNodes[j]
				
				if HasKey(aNode1["properties"], "type") and 
				   HasKey(aNode2["properties"], "type")
					if aNode1["properties"]["type"] = aNode2["properties"]["type"]
						if NOT This.EdgeExists(aNode1["id"], aNode2["id"])
							This.AddEdgeXT(aNode1["id"], aNode2["id"], "(peer)")
							nCount += 1
						ok
					ok
				ok
			end
		end
		return nCount
	})
	
	nInferred = ApplyCustomInference("SAME_TYPE")
	? nInferred  #--> 1
	? EdgeExists("n1", "n2") #--> TRUE
}

pf()

/*--- List Inference Rules

pr()

oGraph = new stzGraph("ListInferTest")
oGraph {
	RegisterInferenceRule("RULE_A", func { return 0 })
	RegisterInferenceRule("RULE_B", func { return 0 })
	
	? @@( CustomInferenceRules() )
	#--> ["RULE_A", "RULE_B"]
}

pf()

#============================================#
#  SECTION 12: CONSTRAINTS & VALIDATION
#============================================#

/*--- Acyclic Constraint

pr()

oGraph = new stzGraph("AcyclicTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	
	Connect("a", "b")
	Connect("b", "c")
	
	AddConstraint("ACYCLIC")
	
	? ValidateConstraints() #--> TRUE
	
	Connect("c", "a")
	
	? ValidateConstraints() #--> FALSE
	
	? @@( ConstraintViolations() )
	#--> [[:type = "ACYCLIC", :count = 1]]
}

pf()

/*--- Connected Constraint

pr()

oGraph = new stzGraph("ConnectedTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("isolated", "Isolated")
	
	Connect("a", "b")
	
	AddConstraint("CONNECTED")
	
	? ValidateConstraints() #--> FALSE
	
	Connect("b", "isolated")
	
	? ValidateConstraints() #--> TRUE
}

pf()

#============================================#
#  SECTION 13: EDGE OPERATIONS
#============================================#

/*--- Edge Navigation

pr()

oGraph = new stzGraph("EdgeNavTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	
	AddEdgeXT("a", "b", "first")
	AddEdgeXT("b", "c", "second")
	
	? FirstEdge()["label"]  #--> "first"
	? LastEdge()["label"]   #--> "second"
	? EdgeAt(1)["label"]    #--> "first"
	? EdgePosition("b", "c") #--> 2
}

pf()

/*--- Edge Replacement

pr()

oGraph = new stzGraph("EdgeReplaceTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	
	AddEdgeXT("a", "b", "old")
	
	ReplaceThisEdgeXT("a", "b", "b", "c", "new")
	
	? EdgeExists("a", "b") #--> FALSE
	? EdgeExists("b", "c") #--> TRUE
	? Edge("b", "c")["label"] #--> "new"
}

pf()

/*--- Edge Properties

pr()

oGraph = new stzGraph("EdgePropsTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	
	AddEdgeXTT("a", "b", "link", [:weight = 10])
	
	? EdgeProperty("a", "b", "weight") #--> 10
	
	SetEdgeProperty("a", "b", "status", "active")
	
	? EdgeProperty("a", "b", "status") #--> "active"
}

pf()

#============================================#
#  SECTION 14: BATCH OPERATIONS
#============================================#

/*--- Batch Edge Updates

pr()

oGraph = new stzGraph("BatchEdgeTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	
	AddEdgeXTT("a", "b", "link1", [:cost = 10])
	AddEdgeXTT("b", "c", "link2", [:cost = 20])
	
	UpdateEdges(func(aEdge) {
		if HasKey(aEdge["properties"], "cost")
			aEdge["properties"]["cost"] *= 2
		ok
	})
	
	? EdgeProperty("a", "b", "cost") #--> 20
	? EdgeProperty("b", "c", "cost") #--> 40
}

pf()

/*--- Replace All Operations

pr()

oGraph = new stzGraph("ReplaceAllTest")
oGraph {
	AddNodeXT("n1", "N1")
	AddNodeXT("n2", "N2")
	Connect("n1", "n2")
	
	ReplaceAllNodes([
		[:id = "new1", :label = "New1", :properties = []],
		[:id = "new2", :label = "New2", :properties = []]
	])
	
	? NodeCount() #--> 2
	? EdgeCount() #--> 0
	? HasNode("new1") #--> TRUE
}

pf()

#============================================#
#  SECTION 15: YAML EXPORT
#============================================#

/*--- YAML Format

pr()

oGraph = new stzGraph("YAMLTest")
oGraph {
	AddNodeXTT("srv1", "Server1", [:port = 8080])
	AddNodeXT("srv2", "Server2")
	AddEdgeXT("srv1", "srv2", "connects")
	
	? BoxRound("YAML FORMAT")
	? Yaml()
}

pf()

#============================================#
#  SECTION 16: COMPLETE WORKFLOW
#============================================#

/*--- Real-World Scenario

pr()

oGraph = new stzGraph("MicroserviceGraph")

# Build service architecture
oGraph {
	AddNodeXTT("api", "API Gateway", [:env = "prod", :cost = 100])
	AddNodeXTT("auth", "Auth Service", [:env = "prod", :cost = 50])
	AddNodeXTT("user", "User Service", [:env = "prod", :cost = 200])
	AddNodeXTT("db", "Database", [:env = "prod", :cost = 300])
	
	ConnectXT("api", "auth", "authenticates")
	ConnectXT("api", "user", "routes")
	ConnectXT("auth", "db", "reads")
	ConnectXT("user", "db", "writes")
	
	# Add rules
	oRule = new stzGraphRule("highcost")
	oRule {
		When("cost", :InSection = [200, 9999])
		Apply("alert", TRUE)
	}
	SetRule(oRule)
	ApplyRules()
	
	# Take snapshot
	Snapshot("initial")
	
	# Analyze
	? BoxRound("ANALYSIS")
	? "Critical nodes: " + @@( MostCriticalNodes(2) )
	? "Bottlenecks: " + @@( BottleneckNodes() )
	? "Density: " + NodeDensity() + "%"
	
	# Visualize
	? BoxRound("VISUALIZATION")
	Show()
	
	# Export
	? BoxRound("EXPORT")
	? Dot()
}

pf()
