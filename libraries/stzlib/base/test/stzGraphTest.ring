load "../stzbase.ring"

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

	Show()
}

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

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Node and Edge Existence

pr()

oGraph = new stzGraph("ExistenceTest")
oGraph {
	AddNode("a")
	AddNode("b")
	Connect("a", "b")
	
	? HasNode("a")         #--> TRUE
	? HasNode("missing")   #--> FALSE
	? EdgeExists("a", "b") #--> TRUE
	? EdgeExists("b", "a") #--> FALSE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Path Finding

pr()

oGraph = new stzGraph("PathTest")
oGraph {
	AddNode("start")
	AddNode("middle")
	AddNode("end")

	Connect("start", :to = "middle")
	Connect("middle", :to = "end")

	? PathExists("start", "end")      #--> TRUE
	? PathExists("start", "isolated") #--> FALSE

	? @@NL( FindAllPaths("start", "end") )
	#--> [ ["start", "middle", "end"] ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Reachability

pr()

oGraph = new stzGraph("ReachTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	AddNode("d")
	
	Connect("a", "b")
	Connect("b", "c")
	Connect("a", "d")
	
	? @@( ReachableFrom("a") )
	#--> [ "a", "b", "d", "c" ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Neighbors and Incoming
*
pr()

oGraph = new stzGraph("ConnectionsTest")
oGraph {
	AddNode("hub")
	AddNode("n1")
	AddNode("n2")
	AddNode("n3")
	
	Connect("n1", "hub")
	Connect("n2", "hub")
	Connect("hub", "n3")
	
	? @@( Neighbors("hub") )    #--> [ "n3" ]
	? @@( Incoming("hub") )     #--> [ "n1", "n2" ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Undirected Graph Support (via bidirectional edges)

pr()

oGraph = new stzGraph("UndirectedTest")
oGraph.AddNode("a")
oGraph.AddNode("b")
oGraph.AddNode("c")

oGraph.Connect("a", "b")  # Directed
oGraph.Connect("b", "a")  # Make bidirectional

? oGraph.IsConnected()   #--> FALSE (because "c" is not connected yet)
oGraph.Connect("b", "c") #--> TRUE
? oGraph.IsConnected() + NL

? oGraph.PathExists("a", "b")  #--> TRUE
? oGraph.PathExists("b", "a")  #--> TRUE

oGraph.Connect("b", "c")
oGraph.Connect("c", "b")
? @@( oGraph.ReachableFrom("a") ) #--> [ "a", "b", "c" ]  # Transitively via bidirectional


pf()
# Executed in 0.01 second(s) in Ring 1.24

/*---

pr()

oGraph = new stzGraph("DebugTest")

# Build graph
oGraph.AddNode("a")
oGraph.AddNode("b") 
oGraph.AddNode("c")

oGraph.Connect("a", "b")
oGraph.Connect("b", "a")
oGraph.Connect("b", "c")
oGraph.Connect("c", "b")

# GRAPH STATE

? @@( oGraph.NodesIds() )
#--> [ "a", "b", "c" ]

? @@NL( oGraph.Edges() ) + NL
#-->
'
[
	[
		[ "from", "a" ],
		[ "to", "b" ],
		[ "label", "" ],
		[ "properties", [  ] ]
	],
	[
		[ "from", "b" ],
		[ "to", "a" ],
		[ "label", "" ],
		[ "properties", [  ] ]
	],
	[
		[ "from", "b" ],
		[ "to", "c" ],
		[ "label", "" ],
		[ "properties", [  ] ]
	],
	[
		[ "from", "c" ],
		[ "to", "b" ],
		[ "label", "" ],
		[ "properties", [  ] ]
	]
]
'

# Test Neighbors and Incoming

? @@NL( oGraph.Neighbors("a") )
#--> [ "b" ]

? @@NL( oGraph.Incoming("a") )
#--> [ "b" ]

? @@NL( oGraph.Neighbors("b") )
#--> [ "a", "c" ]

? @@NL( oGraph.Incoming("b") )
#--> [ "a", "c" ]

? @@NL( oGraph.Neighbors("c") )
#--> [ "b" ]

? @@NL( oGraph.Incoming("c") ) + NL
#--> [ "b" ]

# Test path existence

? oGraph.PathExists("a", "b")
#--> TRUE

? oGraph.PathExists("b", "a")
#--> TRUE

? oGraph.PathExists("a", "c")
#--> TRUE

? oGraph.PathExists("c", "a") + NL
#--> TRUE

# Test ReachableFrom

? @@NL( oGraph.ReachableFrom("a") ) + NL
#--> [ "a", "b", "c" ]

# Test IsConnected
? oGraph.IsConnected() + NL
#--> TRUE

# Manual trace of _IsConnected logic
aNodes = oGraph.Nodes()
? "Starting from: " + aNodes[1]["id"]

acVisited = []
acQueue = [aNodes[1]["id"]]
acVisited + aNodes[1]["id"]
nIdx = 1

? "Initial queue: " + @@(acQueue)

while nIdx <= len(acQueue)
    cCurrent = acQueue[nIdx]
    ? "Processing: " + cCurrent
    
    acNeighbors = oGraph.Neighbors(cCurrent)
    acIncoming = oGraph.Incoming(cCurrent)
    
    ? "  Neighbors: " + @@(acNeighbors)
    ? "  Incoming: " + @@(acIncoming)
    
    for i = 1 to len(acNeighbors)
        cNext = acNeighbors[i]
        if find(acVisited, cNext) = 0
            ? "  Adding neighbor: " + cNext
            acVisited + cNext
            acQueue + cNext
        ok
    end
    
    for i = 1 to len(acIncoming)
        cNext = acIncoming[i]
        if find(acVisited, cNext) = 0
            ? "  Adding incoming: " + cNext
            acVisited + cNext
            acQueue + cNext
        ok
    end
    
    ? "  Visited so far: " + @@(acVisited)
    nIdx += 1
end

? "Final visited: " + @@(acVisited)
? "Total nodes: " + len(aNodes)
? "Should be connected: " + (len(acVisited) = len(aNodes))

#-->
'
Starting from: a
Initial queue: [ "a" ]
Processing: a
  Neighbors: [ "b" ]
  Incoming: [ "b" ]
  Adding neighbor: b
  Visited so far: [ "a", "b" ]
Processing: b
  Neighbors: [ "a", "c" ]
  Incoming: [ "a", "c" ]
  Adding neighbor: c
  Visited so far: [ "a", "b", "c" ]
Processing: c
  Neighbors: [ "b" ]
  Incoming: [ "b" ]
  Visited so far: [ "a", "b", "c" ]
Final visited: [ "a", "b", "c" ]
Total nodes: 3
Should be connected: 1
'

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 2: NODE OPERATIONS
#============================================#

/*--- Node Navigation

pr()

oGraph = new stzGraph("NavTest")
oGraph {
	AddNode("first")
	AddNode("second")
	AddNode("third")
	
	? FirstNode()["label"]   #--> "First"
	? LastNode()["label"]    #--> "Third"
	? NodeAt(2)["label"]     #--> "Second"
	? NodePosition("second") #--> 2
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Node Properties

pr()

oGraph = new stzGraph("PropsTest")
oGraph {
	AddNodeXTT("n1", "Node 1", [:priority = 10, :status = "active"])
	
	? NodeProperty("n1", "priority")
	#--> 10
	
	SetNodeProperty("n1", "owner", "alice")
	? NodeProperty("n1", "owner")
	#--> "alice"
	
	? @@( Properties() )
	#--> ["priority", "status", "owner"]

	? @@NL( PropertiesXT() )
	#-->
	'
	[
		[
			"priority",
			[ 10 ]
		],
		[
			"status",
			[ "active" ]
		],
		[
			"owner",
			[ "alice" ]
		]
	]
'
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

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
# Executed in almost 0 second(s) in Ring 1.24

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
# Executed in almost 0 second(s) in Ring 1.24

/*--- Node Copy and Duplicate

pr()

oGraph = new stzGraph("CopyTest")
oGraph {
	AddNodeXTT("template", "Template", [:color = "blue"])
	AddNodeXT("next", "Next")
	Connect("template", "next")
	
	DuplicateNode("template", "copy1")
	? Node("copy1")["properties"]["color"]
	#--> "blue"
	
	DuplicateNodeWithEdges("template", "copy2")
	? EdgeExists("copy2", "next")
	#--> TRUE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

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
# Executed in 0.01 second(s) in Ring 1.24

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
# Executed in almost 0 second(s) in Ring 1.24

/*--- Batch Update Using Anonymous function

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
# Executed in almost 0 second(s) in Ring 1.24

/*--- Node Splitting (merge inverse: split one node into two with property division)

pr()

oGraph = new stzGraph("SplitTest")
oGraph {
	AddNodeXTT("combined", "Combined", [:tasks = ["t1", "t2"], :priority = 10])
	AddNodeXT("dependent", "Dependent")
	Connect("combined", "dependent")

	# Split into two nodes, dividing properties
	SplitNode("combined", "part1", "part2")
	SetNodeProperty("part1", :tasks, ["t1"])
	SetNodeProperty("part2", :tasks, ["t2"])

	? NodeCount()  #--> 3
	? EdgeExists("part1", "dependent")  #--> TRUE  # Edges duplicated
	? EdgeExists("part2", "dependent")  #--> TRUE
}
pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 3: PROPERTY & TAG QUERIES
#============================================#

# ONE PATTERN - NO CONFUSION
# Find(what).Where(key, op, val).Q()
# Find(what).Having(key, val).Q()
# Find(what).WithProperty(key).Q()
# Find(what).WithTag(tag).Q()

/*---
*/
pr()

oGraph = new stzGraph("UnifiedTest")
oGraph {
	AddNodeXTT("n1", "Server1", [
		:config = [:memory = 1024, :cpu = 4],
		:status = "active",
		:tags = ["prod", "web"]
	])
	AddNodeXTT("n2", "Server2", [
		:config = [:memory = 2048, :cpu = 8],
		:status = "active",
		:tags = ["prod", "db"]
	])
	AddNodeXTT("n3", "Server3", [
		:config = [:memory = 512, :cpu = 2],
		:status = "maintenance",
		:tags = ["dev"]
	])
	
	ConnectXTT("n1", "n2", "link1", [:bandwidth = 100, :tags = ["critical"]])
	ConnectXTT("n2", "n3", "link2", [:bandwidth = 50])
	
	# NODES - All queries use same pattern

	? @@( FindQ("nodes").
	      WithPropertyQ("config.memory").
	      Run()
	)
	#--> ["n1", "n2", "n3"]
	
	? @@( FindQ("nodes").
	      WhereQ("config.memory", "=", 1024).
	      Run()
	)
	#--> ["n1"]
	
	? @@( FindQ("nodes").
	      WhereQ("config.cpu", ">", 4).
	      Run()
	)
	#--> ["n2"]
	
	? @@( FindQ("nodes").
	      WhereQ("label", :contains, "Server").
	      Run()
	)
	#--> ["n1", "n2", "n3"]
	
	? @@( FindQ("nodes").
	      HavingQ("status", "active").
	      Run()
	)
	#--> ["n1", "n2"]
	
	? @@( FindQ("nodes").WithTagQ("prod").Run() )
	#--> ["n1", "n2"]
	
	# CHAINING
	? @@( FindQ("nodes").
	      WhereQ("config.cpu", ">", 2).
	      HavingQ("status", "active").
	      Run()
	)
	#--> ["n1", "n2"]
	
	# EDGES - Same syntax
	? @@( FindQ("edges").WithPropertyQ("bandwidth").Run() )
	#--> ["n1->n2", "n2->n3"]
	
	? @@( FindQ("edges").WhereQ("bandwidth", "=", 100).Run() )
	#--> ["n1->n2"]
	
	? @@( FindQ("edges").WithTagQ("critical").Run() )
	#--> ["n1->n2"]
	
	# RANGES
	? @@( FindQ("nodes").
	      WhereQ("config.memory", :between, [500, 1500]).
	      Run()
	)
	#--> ["n1", "n3"]
}

pf()
# Executed in 0.08 second(s) in Ring 1.24

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
# Executed in almost 0 second(s) in Ring 1.24

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
# Executed in almost 0 second(s) in Ring 1.24

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
	
	? NodeDensity() # Or NodeDensity01() ~> coefficient between 0 and 1
	#--> 0.5

	? NodeDensity100() # Or NodeDensityInPercentage()
	#--> 50 (%)

	? LongestPath()  #--> 2
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

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
	
	? @@( ParallelizableBranches() ) # Or ParaBranches()
	#--> [["pathA", "pathB"]]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

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
# Executed in almost 0 second(s) in Ring 1.24

/*---

pr()

oGraph = new stzGraph("PathInferTest")

oRule = new stzGraphRule("path_shortcut")
oRule {
	SetRuleType("inference")
	WhenPath("start", "end", "exists")
	Then("edge", "add", ["start", "end", "shortcut"])
}

oGraph {
	AddNodeXT("start", "Start")
	AddNodeXT("mid", "Middle")
	AddNodeXT("end", "End")
	
	Connect("start", "mid")
	Connect("mid", "end")
	
	SetRule(oRule)

	? "Direct edge before: " + EdgeExists("start", "end")
	#--> FALSE

	ApplyInference()

	# Now check AFTER exiting the brace context

	# All edges:
	? @@NL(oGraph.Edges())
	#-->
	'
	[
		[
			[ "from", "start" ],
			[ "to", "mid" ],
			[ "label", "" ],
			[ "properties", [  ] ]
		],
		[
			[ "from", "mid" ],
			[ "to", "end" ],
			[ "label", "" ],
			[ "properties", [  ] ]
		],
		[
			[ "from", "start" ],
			[ "to", "end" ],
			[ "label", "shortcut" ],
			[ "properties", [  ] ]
		]
	]
	'

	# Direct edge after:
	? oGraph.EdgeExists("start", "end")
	#--> TRUE

	# Edge count:
	? oGraph.EdgeCount()
	#--> 3

	? @@NL( InferenceReport() )
	#-->
	'
	[
		[ "edgesBeforeInference", 2 ],
		[ "edgesInferred", 1 ],
		[ "edgesAfterInference", 3 ],
		[
			"inferrededges",
			[
				[ "start", "end", "shortcut" ]
			]
		]
	]
	'

}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Weighted Edges and Operations

pr()
oGraph = new stzGraph("WeightedTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")

	ConnectXTT("a", "b", "link1", [:weight = 5])
	ConnectXTT("b", "c", "link2", [:weight = 3])

	? EdgeProperty("a", "b", "weight")  #--> 5
	SetEdgeProperty("a", "b", "weight", 10)
	? EdgeProperty("a", "b", "weight")  #--> 10

	# Total weight along path
	? PathWeight(["a", "b", "c"])  #--> 13  # Sum of weights
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Multi-Edges Between Same Nodes : Raises an error

pr()

oGraph = new stzGraph("MultiEdgeTest")
oGraph {
	AddNode("source")
	AddNode("target")

	ConnectXTT("source", "target", "primary", [:priority = "high"])
	ConnectXTT("source", "target", "backup", [:priority = "low"])
	#--> Edge already exists between 'source' and 'target'!
}

/*---

pr()

oGraph = new stzGraph("EdgeManagementTest")
oGraph {
	AddNode("A")
	AddNode("B")
	AddNode("C")

	# Create multiple edges to different targets
	ConnectXTT("A", "B", "route1", [:speed = "fast"])
	ConnectXTT("A", "C", "route2", [:speed = "slow"])
	ConnectXTT("B", "C", "route3", [:speed = "medium"])

	? EdgeCountBetween("A", "B")  #--> 1
	? EdgeCountBetween("A", "C")  #--> 1

	? @@NL( EdgesBetween("A", "B") )
	#--> [
	# 	["A", "route1", "B"]
	# ]

	? @@NL( EdgesBetween("A", "C") )
	#--> [
	# 	["A", "route2", "C"]
	# ]

	# Remove specific edge by label
	RemoveEdgeByLabel("A", "C", "route2")
	? EdgeCountBetween("A", "C")  #--> 0

}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#===================================#
#  SECTION 5: UNIFIED RULE SYSTEM   #
#===================================#

/*--- Validation Rule

pr()

oGraph = new stzGraph("ValidationTest")

oRule = new stzGraphRule(:RequireApproval)
oRule {
	When(:IsApproved, :Equals, FALSE)
	MarkAsInValid()
	AddAnomaly("Requires approval")

	? @@(Anomalies())
	#--> [ "Requires approval" ]
}

oGraph {
	SetRule(oRule)
	
	AddNodeXTT("task1", "Task 1", [:isapproved = FALSE])
	AddNodeXTT("task2", "Task 2", [:isapproved = TRUE])
	
	ApplyRules()
	
	? Node("task1")["properties"]["isvalid"]    	#--> FALSE
	? Node("task1")["properties"]["Anomaly"]  	#--> "Requires approval"
	? HasKey(Node("task2")["properties"], "isvalid") #--> FALSE
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Inference Rule

pr()

oGraph = new stzGraph("InferenceTest")

oRule = new stzGraphRule("transitivity")
oRule {
	SetRuleType("inference")
	WhenPathExists(:FromNode = "a", :ToNode = "c")
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
	
	? EdgeCount() #--> 3 (original 2 + inferred 1) #ERR returned 2!
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Property-based Rule

pr()

oGraph = new stzGraph("PropRuleTest")

oRule = new stzGraphRule("highcost")
oRule {
	SetRuleType("validation")
	When("cost", "between", [500, 9999])
	Then("requiresapproval", "set", TRUE)
	Then("level", "set", "high")
}

oGraph {
	SetRule(oRule)
	
	AddNodeXTT("n1", "N1", [:cost = 100])
	AddNodeXTT("n2", "N2", [:cost = 800])
	
	ApplyValidation()
	
	# Does N1 requires approval
	? NodeRequiresApproval("n1")
	#--> FALSE
	
	? NodeRequiresApproval("n2")
	#--> TRUE
	
	? NodeXT("n2")[:Level]
	#--> "high"

	? NodeXT("n2")[:Cost]
	#--> 800
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Rule Analysis 1

pr()

oGraph = new stzGraph("RuleAnalysisTest")

# Create rules
oRule1 = new stzGraphRule("critical")
oRule1 {
	SetRuleType("validation")
	WhenTagExists("critical")
	SetProperty("alert", TRUE)
}

oRule2 = new stzGraphRule("production")
oRule2 {
	SetRuleType("validation")
	When("env", "equals", "prod")
	SetProperty("monitor", TRUE)
}

oGraph {
	# Set rules
	SetRule(oRule1)
	SetRule(oRule2)
	
	# Add nodes
	AddNodeXTT("n1", "N1", [:env = "prod", :tags = ["critical"]])
	AddNodeXTT("n2", "N2", [:env = "test"])
	
	# Apply rules
	ApplyRules()
	
	# Check results

	? @@( NodesAffectedByRules() )
	#--> ["n1", "n2"]

	? @@( NodesAffectedByRule("critical") )
	#--> ["n1"]
	
	? @@( NodesAffectedByRule("production") ) + NL
	#--> ["n1"]
	
	# Summary of applied rules

	? @@( RulesApplied() ) + NL
	#--> [ "critical", "production" ]

	? @@NL( RulesAppliedXT() ) + NL
	#-->
	'
	[
		[ "haseffects", 1 ],
		[
			"summary",
			"2 rule(s) defined, 2 element(s) affected"
		],
		[
			"rules",
			[
				[
					[ "id", "critical" ],
					[ "condition", "tagexists" ],
					[
						"conditionparams",
						[ "critical" ]
					],
					[
						"effects",
						[
							[ "set", "alert", 1 ]
						]
					],
					[
						"affectednodes",
						[ "n1" ]
					],
					[ "affectededges", [  ] ],
					[ "matchcount", 1 ]
				],
				[
					[ "id", "production" ],
					[ "condition", "propertyequals" ],
					[
						"conditionparams",
						[ "env", "prod" ]
					],
					[
						"effects",
						[
							[ "set", "monitor", 1 ]
						]
					],
					[
						"affectednodes",
						[ "n1" ]
					],
					[ "affectededges", [  ] ],
					[ "matchcount", 1 ]
				]
			]
		]
	]
	'

	
	# Node Properties After Rules

	? @@( NodePropertiesXT("n1") )
	#--> [ [ "env", "prod" ], [ "tags", [ "critical" ] ], [ "alert", 1 ], [ "monitor", 1 ] ]

	? @@( NodeProperty("n1", "alert") ) 	#--> TRUE (1)
	? @@( NodeProperty("n1", "monitor") ) 	#--> TRUE (1) + NL
	
	? @@( NodePropertiesXT("n2") )
	#--> [ [ "env", "test" ] ]
}

pf()
# Executed in 0.03 second(s) in Ring 1.2

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
	When("env", :equals, "prod")
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
	
	? @@( RulesApplied() )
	#--> [ "critical", "production" ]

	? @@NL( RulesAppliedXT() )
	#-->
	'
	[
		[ "haseffects", 1 ],
		[
			"summary",
			"2 rule(s) defined, 2 element(s) affected"
		],
		[
			"rules",
			[
				[
					[ "id", "critical" ],
					[ "condition", "tagexists" ],
					[
						"conditionparams",
						[ "critical" ]
					],
					[
						"effects",
						[
							[ "set", "alert", 1 ]
						]
					],
					[
						"affectednodes",
						[ "n1" ]
					],
					[ "affectededges", [  ] ],
					[ "matchcount", 1 ]
				],
				[
					[ "id", "production" ],
					[ "condition", "propertyequals" ],
					[
						"conditionparams",
						[ "env", "prod" ]
					],
					[
						"effects",
						[
							[ "set", "monitor", 1 ]
						]
					],
					[
						"affectednodes",
						[ "n1" ]
					],
					[ "affectededges", [  ] ],
					[ "matchcount", 1 ]
				]
			]
		]
	]
	'

	? BoxRound("GRAPH EXPLANATION")
	? @@NL( Explain() )
#-->
'
╭───────────────────╮
│ GRAPH EXPLANATION │
╰───────────────────╯
[
	[
		"general",
		[
			"Graph: RuleAnalysisTest",
			"Nodes: 2 | Edges: 0"
		]
	],
	[
		"bottlenecks",
		[ "No bottlenecks (average degree = 0)" ]
	],
	[
		"cycles",
		[ "No cycles - acyclic graph (DAG)" ]
	],
	[
		"metrics",
		[
			"Density: 0% (no connections)",
			"Longest path: 0 hops (isolated)"
		]
	],
	[
		"rules",
		[
			"Rules applied: 2",
			"  - critical [validation]",
			"  - production [validation]"
		]
	]
]
'

}

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Density and Sparsity Metrics

pr()

oGraph = new stzGraph("DensityTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")

	Connect("a", :to = "b")
	Connect("b", :to = "c")

	? Density() # Direct Graph : 3 nodes, 2 edges → density = 2/(3×2) = 0.33
	#--> 0.33

	? IsSparse() # Assuming threshold < 0.5 is dense, else sparse
	#--> TRUE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*---

pr()

oGraph = new stzGraph("DensityAnalysis")
oGraph {
	# Create sparse graph
	AddNode("a")
	AddNode("b")
	AddNode("c")
	AddNode("d")
	AddNode("e")
	
	Connect("a", "b")
	Connect("b", "c")
	Connect("c", "d")
	
	# SPARSE GRAPH (5 nodes, 3 edges)

	? Density()
	#--> 0.15

	? Density100()
	 #--> 15

	? DensityCategory()
	#--> "very sparse"

	? IsSparse()
	#--> TRUE

	? IsDense() + NL
	#--> FALSE
	
	# Add more edges to make it denser

	Connect("a", "c")
	Connect("a", "d")
	Connect("b", "d")
	Connect("b", "e")
	Connect("c", "e")
	
	# DENSE GRAPH (5 nodes, 9 edges)

	? Density()
	#--> 0.40

	? DensityCategory() + NL
	#--> "sparse" (just below 0.5)
	
	# Make it very dense*

	Connect("a", "e")
	Connect("d", "e")
	
	# VERY DENSE GRAPH (5 nodes, 11 edges)

	? Density()
	#--> 0.50

	? Density100()
	#--> 50

	? DensityLevel()
	#--> "dense"

	? IsDense() + NL
	#--> TRUE
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

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

	Show() # In ascii form in the console
	View() # In graphiz-generated diagram
}
#--> DOT CODE
'
╭────────────╮
│ DOT FORMAT │
╰────────────╯
digraph ExportTest {
  rankdir=LR;
  node [shape=box];

  a [label="A"];
  b [label="B"];

  a -> b;
}
'

#--> IN CONSOLE
'
          ╭───╮          
          │ A │          
          ╰───╯          
            |            
            v            
          ╭───╮          
          │ B │          
          ╰───╯ 
'

#--> (image generated as svg)

# NOTE: If you need more advanced visual diagram features,
# convert the stzGraph object into an stzDiagram object
# using the ToStzDiagram() method, and continue from there.
# TODO: Add an example demonstrating this.

pf()
# Executed in 0.61 second(s) in Ring 1.24

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
#-->
'
╭─────────────╮
│ JSON FORMAT │
╰─────────────╯
{
  "id": "JSONTest",
  "nodes": [
    {"id":"input","label":"Input","properties":{}},
    {"id":"output","label":"Output","properties":{}}
  ],
  "edges": [
    {"from":"input","to":"output","label":"","properties":{}}
  ],
  "metrics": {"nodecount":2,"edgecount":1,"density":50,"longestpath":1,"hascycles":0}
}
'

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- ASCII Visualization

pr()

oGraph = new stzGraph("VisTest")
oGraph {
	AddNodeXT("start", "Start")
	AddNodeXT("middle", "Middle")
	AddNodeXT("end", "End")
	
	Connect("start", "middle")
	Connect("middle", "end")

}

oGraph.Show() # ShowV by default
#-->
'
        ╭───────╮        
        │ Start │        
        ╰───────╯        
            |            
            v            
      ╭──────────╮       
      │ !Middle! │       
      ╰──────────╯       
            |            
            v            
         ╭─────╮         
         │ End │         
         ╰─────╯ 
'

oGraph.ShowH()
#-->
'
╭───────╮     ╭──────────╮     ╭─────╮
│ Start │---->│ !Middle! │---->│ End │
╰───────╯     ╰──────────╯     ╰─────╯
'

pf()
# Executed in 0.04 second(s) in Ring 1.24

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
}
#-->
'
[
	[
		"general",
		[ "Graph: ExplainTest", "Nodes: 3 | Edges: 3" ]
	],
	[
		"bottlenecks",
		[ "No bottlenecks (average degree = 2)" ]
	],
	[
		"cycles",
		[ "WARNING: Circular dependencies detected" ]
	],
	[
		"metrics",
		[
			"Density: 0.50% (sparse)",
			"Longest path: 2 hops"
		]
	],
	[
		"rules",
		[ "No rules applied" ]
	]
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.24

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
	
	? @@( NodesByProp("type", "frontend") )
	#--> ["svc2"]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

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
# Executed in 0.01 second(s) in Ring 1.24

/*--- Path Matching

pr()

oGraph = new stzGraph("PathMatchTest")
oGraph {
	AddNode("n1")
	AddNode("n2")
	AddNode("n3")
	AddNode("n4")
	
	Connect("n1", "n2")
	Connect("n2", "n3")
	Connect("n3", "n4")
	Connect("n1", "n4")
	
	aPaths = PathsMatchingF( func(acPath) {
		return len(acPath) >= 3
	})
	
	? @@NL( aPaths )
	#--> [
	# 	["n1", "n2", "n3"],
	# 	["n2", "n3", "n4"],
	# 	["n1", "n2", "n3", "n4"]
	# ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Edge Property Queries

pr()

oGraph = new stzGraph("EdgePropTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	
	AddEdgeXTT("a", "b", "fast", [:speed = 100])
	AddEdgeXTT("b", "c", "slow", [:speed = 10])
	
	? @@( EdgesByProp("speed", 100) ) # Or EdgesByProperty
	#--> [ [ "a", "b" ] ]

	# Or more expressively:
	? @@( EdgesWhere("speed", :Equals = 100) )
	#--> [ [ "a", "b" ] ]

	? @@( EdgesWhere("speed", :Between = [ 80, 120 ]) )
	#--> [ [ "a", "b" ] ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Chained Rules

pr()

oGraph = new stzGraph("ChainedTest")

# First rule sets a property
oRule1 = new stzGraphRule("set_category")
oRule1 {
	SetRuleType("validation") # Can be commented because "validation" is the default tyoe
	When("cost", "greaterthan", 1000)
	Then("category", "set", "expensive")
}

# Second rule reacts to that property
oRule2 = new stzGraphRule("expensive_handling")
oRule2 {
	SetRuleType("validation")
	When("category", "equals", "expensive")
	Then("approval_level", "set", "executive")
	Then("notification", "set", TRUE)
}

oGraph {
	SetRule(oRule1)
	SetRule(oRule2)
	
	AddNodeXTT("item", "Item X", [:cost = 1500])
	
	ApplyRules()
	
	? @@NL( Node("item") )
	#-->
	'
	[
		[ "id", "item" ],
		[ "label", "Item X" ],
		[
			"properties",
			[
				[ "cost", 1500 ],
				[ "category", "expensive" ],
				[ "approval_level", "executive" ],
				[ "notification", 1 ]
			]
		]
	]
	'

}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
SECTION 9': RULE ENGINE ADVANCED
#============================================#

/*--- Inference Rule Chaining #TODO Checl result correctness

pr()

# Rule 1: Mark nodes with outgoing edges as parents
oRule1 = new stzGraphRule("parent_marker")
oRule1 {
    SetRuleType("inference")
    SetGraph(NULL)  # Will be set by graph
}

# Rule 2: Add transitive inference for paths
oRule2 = new stzGraphRule("path_infer")
oRule2 {
    SetRuleType("inference")
    WhenPathExists(:from = "a", :to = "b")
    AddEdgeXT("a", "b", "(inferred-path)")
}

# Create graph
oGraph = new stzGraph("InferenceChain")
oGraph {
    # Add nodes
    AddNodeXTT("a", "Node A", [:type = "parent"])
    AddNodeXTT("b", "Node B", [:type = "child"])
    AddNodeXTT("c", "Node C", [:type = "child"])
    
    # Add edges
    Connect("a", "b")
    Connect("b", "c")
    
    # Set rules
    SetRule(oRule1)
    SetRule(oRule2)
    
    # Apply inference (will add transitive a->c)
    ApplyInference()
    
    # Now set properties based on graph structure
    SetNodeProperty("a", "hasChild", TRUE)
    SetNodeProperty("b", "inheritsFrom", "a")
    SetNodeProperty("c", "inheritsFrom", "b")
    
    # Display results
    ? "=== Nodes ==="
    ? @@NL( Nodes() ) + NL
    
    ? "=== Edges ==="
    ? @@NL( Edges() ) + NL
    
    ? "=== Node Properties ==="
    ? "Node A hasChild: " + NodeProperty("a", "hasChild")
    ? "Node B inheritsFrom: " + NodeProperty("b", "inheritsFrom")
    ? "Node C inheritsFrom: " + NodeProperty("c", "inheritsFrom")
    ? ""
    
    ? "=== Inference Report ==="
    ? @@NL( InferenceReport() )
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Else Effects in Validation

pr()

oRule = new stzGraphRule("status_check")
oRule {
	SetRuleType("validation")
	When("status", "equals", "active")
	Then("requiredreview", "set", FALSE)
	Else_("requiredreview", "set", TRUE)
}

oGraph = new stzGraph("ElseTest")
oGraph {
	AddNodeXTT("n1", "N1", [:status = "active"])

	ApplyRules()
	Validate()  # Apply with else

	? NodeProperty("n1", "requiredreview")  #--> FALSE

	SetNodeProperty("n1", "status", "inactive")
	Validate()

	? NodeProperty("n1", "requiredreview")  #--> TRUE
}

#ERR Line 2916 Inexistant node key or/and property!

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Multi-Rule Interactions and Conflicts

pr()

oRule1 = new stzGraphRule("priority_boost")
oRule1 {
	SetRuleType("inference")
	When("priority", "lessthan", 10)
	Then("priority", "set", 10)
}

oRule2 = new stzGraphRule("priority_cap")
oRule2 {
	SetRuleType("constraint")
	When("priority", "greaterthan", 8)
	ThenViolation("Priority exceeds cap")
}

oGraph = new stzGraph("MultiRuleTest")
oGraph {
	AddNodeXTT("n1", "N1", [:priority = 5])
	
	ApplyRules()  # Inference first, then constraint
	
	? NodeProperty("n1", "priority")  #--> 5
	? @@( ConstraintViolations() )  #--> [ "Priority exceeds cap" ]  # Conflict detected
	#ERR returned []
}

# along with a general Viloations() method that return them all (and ViloationsXT() that
# return them in a hashlist [ [ "validation", [ .., ... ] ], [ "inference", [ "...", "..."] ], etc ]


pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 10: METADATA OPERATIONS
#============================================#

/*--- Node properties

pr()

oGraph = new stzGraph("MetadataTest")
oGraph {
	AddNodeXT("n1", "Node 1")
	
	SetNodeProperties("n1", [:owner = "alice", :created = "2024-01-01"])
	
	? @@( NodeProperties("n1") )
	#--> [ "owner", "created" ]

	? @@( NodePropertiesXT("n1") )
	#--> [:owner = "alice", :created = "2024-01-01"]
	
	SetNodeProperty("n1", "modified", "2024-01-15")
	
	? NodeProperty("n1", "modified")
	#--> "2024-01-15"
	
	RemoveNodeProperties("n1")
	? @@( NodeProperties("n1") )
	#--> []
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Edge props

pr()

oGraph = new stzGraph("EdgeMetaTest")
oGraph {
	AddNode("a")
	AddNode("b")
	Connect("a", "b")
	
	SetEdgeProperties("a", "b", [:bandwidth = 1000, :protocol = "tcp"])
	
	? @@( EdgeProperties(:from = "a", :to = "b") ) + NL
	#--> [ "bandwidth", "protocol" ]

	? @@( EdgePropsXT("a", "b") ) + NL
	#--> [ [ "bandwidth", 1000 ], [ "protocol", "tcp" ] ]
	
	UpdateEdgeProperty("a", "b", "latency", 5)
	
	? EdgeProp("a", "b", "latency")
	#--> 5
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 11: INFERENCE & KNOWLEDGE
#============================================#
# TODO review it's implementation in the light of the
# abstracted stzGraphRule class and other classes
#UPDATE Done :D بفضل الله

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
	? nInferred
	#--> 1

	? EdgeCount()
	#--> 3
	
	? @@NL( InferredEdges() )
	#-->
	'
	[
		[
			[ "from", "a" ],
			[ "to", "c" ],
			[ "label", "(inferred-transitive)" ],
			[ "properties", [  ] ]
		]
	]
	'
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Symmetry Inference

pr()

oGraph = new stzGraph("SymmetryTest")
oGraph {
	AddNode("x")
	AddNode("y")
	
	AddEdgeXT("x", "y", "connected")
	
	AddInferenceRule("SYMMETRY")
	
	? ApplyInference() #--> TRUE
	? EdgeExists("y", "x") #--> TRUE
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 12: CONSTRAINTS & VALIDATION
#============================================#

/*--- Acyclic Constraint

pr()

oGraph = new stzGraph("AcyclicTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	
	Connect("a", "b")
	Connect("b", "c")
	
	AddConstraint("ACYCLIC")
	
	? BoxRound("CONSTRAINTS VALIDATION - BEFORE")
	? @@NL( ValidateConstraints() ) + NL
	
	Connect("c", "a")
	
	? BoxRound("CONSTRAINTS VALIDATION - AFTER")

	? @@NL( ValidateConstraints() ) + NL
	
	? BoxRound("CONSTRAINTS ANOMALIES")
	? @@( ConstraintAnomalies() )
	#--> [[:type = "ACYCLIC", :count = 1]] []
}
#-->
'
╭─────────────────────────────────╮
│ CONSTRAINTS VALIDATION - BEFORE │
╰─────────────────────────────────╯
[
	[ "status", "pass" ],
	[ "domain", "constraints" ],
	[ "issuecount", 0 ],
	[ "issues", [  ] ],
	[ "affectednodes", [  ] ]
]

╭────────────────────────────────╮
│ CONSTRAINTS VALIDATION - AFTER │
╰────────────────────────────────╯
[
	[ "status", "fail" ],
	[ "domain", "constraints" ],
	[ "issuecount", 1 ],
	[
		"issues",
		[ "Constraint failed: ACYCLIC" ]
	],
	[ "affectednodes", [  ] ]
]

╭───────────────────────╮
│ CONSTRAINTS ANOMALIES │
╰───────────────────────╯
[ [ [ "type", "ACYCLIC" ], [ "count", 1 ] ] ]
'

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Connected Constraint

pr()

oGraph = new stzGraph("ConnectedTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("isolated")
	
	Connect("a", "b")
	
	? BoxRound("CONSTRAINT VALIDATION - BEFORE")
	AddConstraint("CONNECTED")
	
	? @@NL(ValidateConstraints()) + NL
	
	Connect("b", "isolated")
	
	? BoxRound("CONSTRAINT VALIDATION - AFTER")
	? @@NL( ValidateConstraints() )
}
#-->
'
╭────────────────────────────────╮
│ CONSTRAINT VALIDATION - BEFORE │
╰────────────────────────────────╯
[
	[ "status", "fail" ],
	[ "domain", "constraints" ],
	[ "issuecount", 1 ],
	[
		"issues",
		[ "Constraint failed: CONNECTED" ]
	],
	[ "affectednodes", [  ] ]
]

╭───────────────────────────────╮
│ CONSTRAINT VALIDATION - AFTER │
╰───────────────────────────────╯
[
	[ "status", "pass" ],
	[ "domain", "constraints" ],
	[ "issuecount", 0 ],
	[ "issues", [  ] ],
	[ "affectednodes", [  ] ]
]
'

pf()
# Executed in 0.02 second(s) in Ring 1.24

#============================================#
#  SECTION 13: EDGE OPERATIONS
#============================================#

/*--- Edge Navigation

pr()

oGraph = new stzGraph("EdgeNavTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	
	AddEdgeXT("a", "b", "first")
	AddEdgeXT("b", "c", "second")
	
	? @@NL( FirstEdge() ) + NL # Or NthEdge(n)
	#-->
	'
	[
		[ "from", "a" ],
		[ "to", "b" ],
		[ "label", "first" ],
		[ "properties", [  ] ]
	]
	'

	? FirstEdge()["label"]   #--> "first"
	? LastEdge()["label"]    #--> "second"
	? EdgeAt(1)["label"]     #--> "first"
	? EdgePosition("b", "c") #--> 2
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Edge Replacement

pr()

oGraph = new stzGraph("EdgeReplaceTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	
	AddEdgeXT("a", "b", "old")
	
	ReplaceEdgeXT(["a", "b"], :With = ["b", "c"], :Label = "new")
	
	? EdgeExists("a", "b") #--> FALSE
	? EdgeExists("b", "c") #--> TRUE
	? Edge("b", "c")["label"] #--> "new"
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Edge Properties

pr()

oGraph = new stzGraph("EdgePropsTest")
oGraph {
	AddNode("a")
	AddNode("b")
	
	AddEdgeXTT("a", "b", "link", [:weight = 10])
	
	? EdgeProperty("a", "b", "weight") #--> 10
	
	SetEdgeProperty("a", "b", "status", "active")
	
	? EdgeProperty("a", "b", "status")
	#--> "active"
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

#============================================#
#  SECTION 14: BATCH OPERATIONS
#============================================#

/*--- Batch Edge Updates Using Anonymous Functions

pr()

oGraph = new stzGraph("BatchEdgeTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	
	AddEdgeXTT("a", "b", "link1", [:cost = 10])
	AddEdgeXTT("b", "c", "link2", [:cost = 20])
	
	UpdateEdgesF(func(aEdge) {
		if HasKey(aEdge["properties"], "cost")
			aEdge["properties"]["cost"] *= 2
		ok
	})
	
	? EdgeProperty("a", "b", "cost") #--> 20
	? EdgeProperty("b", "c", "cost") #--> 40
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

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
#-->
'
╭─────────────╮
│ YAML FORMAT │
╰─────────────╯
graph: YAMLTest
nodes:
  - id: srv1
    label: Server1
    properties:
      - port
  - id: srv2
    label: Server2

edges:
  - from: srv1
    to: srv2
    label: connects
'

pf()
# Executed in 0.01 second(s) in Ring 1.24

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
		When("cost", :InSection, [200, 9999])
		SetProperty("alert", TRUE)
	}
	SetRule(oRule)
	ApplyRules()
	
	# Analyze
	? "ANALYSIS"
	? "--------" + NL

	? "Critical nodes: " + @@( MostCriticalNodes(2) )
	? "Bottlenecks: " + @@( BottleneckNodes() )
	? "Density: " + NodeDensity100() + "%" + NL
	
	# Visualize
	? "VISUALIZATION"
	? "-------------" + NL

	Show()
	? ""
	
	# Export
	? "EXPORT"
	? "------" + NL

	? Dot()

}
#-->
'
ANALYSIS
--------

Critical nodes: [ "api", "auth" ]
Bottlenecks: [ ]
Density: 33.33%

VISUALIZATION
-------------

     ╭─────────────╮     
     │ API Gateway │     
     ╰─────────────╯     
            |            
      authenticates      
            |            
            v            
    ╭──────────────╮     
    │ Auth Service │     
    ╰──────────────╯     
            |            
          reads          
            |            
            v            
      ╭──────────╮       
      │ Database │       
      ╰──────────╯       

          ////

     ╭─────────────╮  ↑
     │ API Gateway │──╯
     ╰─────────────╯     
            |            
         routes          
            |            
            v            
    ╭──────────────╮     
    │ User Service │     
    ╰──────────────╯     
            |            
         writes          
            |            
            v            
      ╭──────────╮       
      │ Database │       
      ╰──────────╯       

EXPORT
------

digraph MicroserviceGraph {
  rankdir=TD;
  node [shape=box];

  api [label="API Gateway"];
  auth [label="Auth Service"];
  user [label="User Service"];
  db [label="Database"];

  api -> auth [label="authenticates"];
  api -> user [label="routes"];
  auth -> db [label="reads"];
  user -> db [label="writes"];
}
'

pf()
# Executed in 0.06 second(s) in Ring 1.24


#===========================#
#  PATHFINDING ALGORITHMS   #
#===========================#

/*--- Shortest path in linear graph

pr()

oGraph = new stzGraph("Linear")
oGraph {
	AddNodeXT(:n1, "Start")
	AddNodeXT(:n2, "Middle")
	AddNodeXT(:n3, "End")
	
	Connect(:n1, :n2)
	Connect(:n2, :n3)
	
	? @@( ShortestPath(:From = :n1, :To = :n3) )
	#--> ["n1", "n2", "n3"]
	
	? ShortestPathLength(:From = :n1, :To = :n3)
	#--> 2

	Show()
	#-->
	'
	        ╭───────╮        
	        │ Start │        
	        ╰───────╯        
	            |            
	            v            
	      ╭──────────╮       
	      │ !Middle! │       
	      ╰──────────╯       
	            |            
	            v            
	         ╭─────╮         
	         │ End │         
	         ╰─────╯     
	'

}

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Shortest path with multiple routes

pr()

oGraph = new stzGraph("Network")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	AddNode("d")
	
	Connect("a", :with = "b") # See the named param variations
	Connect("a", :to = "c")
	Connect("b", :and = "d")
	Connect("c", "d")
	
	? @@( ShortestPath(:From = "a", :To = "d") )
	#--> ["a", "b", "d"]
	
	? ShortestPathLength(:From = "a", :To = "d")
	#--> 2
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- No path exists

pr()

oGraph = new stzGraph("Disconnected")
oGraph {
	AddNodeXT(:x, "Node X")
	AddNodeXT(:y, "Node Y")
	AddNodeXT(:z, "Node Z")
	
	Connect(:x, :y)
	# z is isolated
	
	? @@( ShortestPath(:From = :x, :To = :z) )
	#--> []
	
	? ShortestPathLength(:From = :x, :To = :z)
	#--> 0
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#=======================#
#  CONNECTIVITY TESTS   #
#=======================#

/*--- Connected graph

pr()

oGraph = new stzGraph("Connected")
oGraph {
	AddNode(:a)
	AddNode(:b)
	AddNode(:c)

	Connect(:a, :b)
	Connect(:b, :c)

	? IsConnected()
	#--> TRUE

	? @@NL( ConnectedComponents() )
	#--> [ [ "a", "b", "c" ] ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Multiple components

pr()

oGraph = new stzGraph("TwoComponents")
oGraph {
	AddNode(:a)
	AddNode(:b)
	AddNode(:c)
	AddNode(:d)

	Connect(:a, :b)
	Connect(:c, :d)

	? IsConnected()
	#--> FALSE

	? @@NL( ConnectedComponents() )
	#--> [["a", "b"], ["c", "d"]]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Articulation points

pr()

oGraph = new stzGraph("Bridge")
oGraph {
	AddNode(:n1)
	AddNode(:n2)
	AddNode(:n3)
	AddNode(:n4)
	
	Connect(:n1, :n2)
	Connect(:n2, :n3)
	Connect(:n3, :n4)
	
	? @@( ArticulationPoints() )
	#--> [:n2, :n3] - Removing either disconnects the graph
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#=======================#
#  CENTRALITY MEASURES  #
#=======================#

/*--- Betweenness centrality

pr()

oGraph = new stzGraph("Star")
oGraph {
	AddNode(:center)
	AddNode(:n1)
	AddNode(:n2)
	AddNode(:n3)
	
	Connect(:n1, :center)
	Connect(:center, :n2)
	Connect(:center, :n3)
	
	? BetweennessCentrality(:center)
	#--> 0.33 (2 out of 6 possible paths go through center in directed graph)
	
	? BetweennessCentrality(:n1)
	#--> 0 (no paths go through peripheral nodes)
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*---

pr()

oGraph = new stzGraph("Star")
oGraph {
	AddNode(:center)
	AddNode(:n1)
	AddNode(:n2)
	AddNode(:n3)

	Connect(:n1, :center)
	Connect(:center, :n1)
	Connect(:n2, :center)
	Connect(:center, :n2)
	Connect(:n3, :center)
	Connect(:center, :n3)

	? BetweennessCentrality(:center)
	#--> 1 (all paths go through center in undirected graph)
	
	? BetweennessCentrality(:n1)
	#--> 0 (no paths go through peripheral nodes)

	View()
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Closeness centrality

pr()

oGraph = new stzGraph("Network")
oGraph {
	AddNode(:a)
	AddNode(:b)
	AddNode(:c)
	
	Connect(:a, :b)
	Connect(:b, :c)
	
	? ClosenessCentrality(:b)
	#--> 1 (average distance = 1)
	
	? ClosenessCentrality(:a)
	#--> 0.67 (average distance = 1.5)
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Clustering coefficient

pr()

oGraph = new stzGraph("Triangle")
oGraph {
	AddNode(:a)
	AddNode(:b)
	AddNode(:c)
	
	Connect(:a, :b)
	Connect(:b, :c)
	Connect(:c, :a)
	
	? ClusteringCoefficient("a")
	#--> 1 (neighbors are fully connected)
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Clustering coefficient in incomplete triangle

pr()

oGraph = new stzGraph("Incomplete")
oGraph {
	AddNode(:x)
	AddNode(:y)
	AddNode(:z)
	
	Connect(:x, :y)
	Connect(:x, :z)
	# y and z not connected
	
	? ClusteringCoeff(:x)
	#--> 0 (neighbors not connected)
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

#==================#
#  GRAPH METRICS   #
#==================#

/*--- Diameter of graph

pr()

oGraph = new stzGraph("Chain")
oGraph {
	AddNode(:n1)
	AddNode(:n2)
	AddNode(:n3)
	AddNode(:n4)
	
	Connect(:n1, :n2)
	Connect(:n2, :n3)
	Connect(:n3, :n4)
	
	? Diameter()
	#--> 3 (longest path: n1 to n4)

	Show()
	#-->
	'
	         ╭────╮          
	         │ n1 │          
	         ╰────╯          
	            |            
	            v            
	        ╭──────╮         
	        │ !n2! │         
	        ╰──────╯         
	            |            
	            v            
	        ╭──────╮         
	        │ !n3! │         
	        ╰──────╯         
	            |            
	            v            
	         ╭────╮          
	         │ n4 │          
	         ╰────╯  
	'

}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Average path length

pr()

oGraph = new stzGraph("Small")
oGraph {
	AddNode(:a)
	AddNode(:b)
	AddNode(:c)
	
	Connect(:a, :b)
	Connect(:b, :c)
	
	? AveragePathLength()
	#--> 1.33 (paths: a-b=1, b-c=1, a-c=2)
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

#============================#
#  COMBINED ALGORITHM TESTS  #
#============================#

/*--- Real-world network analysis

pr()

oGraph = new stzGraph("SocialNetwork")
oGraph {
	AddNode(:alice)
	AddNode(:bob)
	AddNode(:charlie)
	AddNode(:diana)
	AddNode(:eve)
	
	Connect(:alice, :bob)
	Connect(:bob, :charlie)
	Connect(:charlie, :diana)
	Connect(:diana, :eve)
	Connect(:bob, :diana)  # Shortcut
	
	# Network Analysis

	? Diameter()
	#--> 3

	? AveragePathLength()
	#--> 1.60

	? IsConnected() + NL$
	#--> TRUE

	# Node Importance

	? BetweennessCentrality(:bob)
	#--> 0.25

	? ClosenessCentrality(:charlie)
	#--> 0.67

	# Critical Nodes

	? @@( ArticulationPoints() )
	#--> [ "bob", "charlie", "diana" ]

	View()

}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Workflow dependency analysis

pr()

oGraph = new stzGraph("Workflow")
oGraph {
	AddNode(:start)
	AddNode(:validate)
	AddNode(:process)
	AddNode(:review)
	AddNode(:complete)
	
	Connect(:start, :validate)
	Connect(:validate, :process)
	Connect(:process, :review)
	Connect(:review, :complete)
	
	# Path from Start to Complete:
	? @@( ShortestPath(:From = :start, :To = :complete) ) + NL
	#--> [ "start", "validate", "process", "review", "complete" ]

	# Bottleneck nodes (articulation points):
	? @@( ArticulationPoints() ) + NL
	#--> [ "validate", "process", "review" ]

	# Critical step (highest betweenness):"
	? BetweennessCentrality(:validate)
	#--> 0.25

	? BetweennessCentrality(:process)
	#--> 0.33

	? BetweennessCentrality(:review)
	#--> 0.25
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

#============================================#
#  Complete Format Suite Examples            #
#  All 6 formats working together            #
#============================================#

#-----------------------------------#
#  Example 1: supply_chain.stzgraf  #
#-----------------------------------#

/*
graph "Global_Supply_Chain"
    type: directed

nodes
    warehouse_ny
    warehouse_la
    factory_cn
    factory_mx
    distributor_eu

edges
    factory_cn -> warehouse_ny
    factory_cn -> warehouse_la
    factory_mx -> warehouse_la
    warehouse_ny -> distributor_eu
    warehouse_la -> distributor_eu

properties
    warehouse_ny
        capacity: 50000
        location: "New York"
        status: "active"
    
    factory_cn
        output: 100000
        location: "Shenzhen"
        cost_per_unit: 2.5
    
    distributor_eu
        coverage: "Europe"
        demand: 75000
*/

#-----------------------------------#
#  Example 2: payment_flow.stzdiag  #
#-----------------------------------#

/*
diagram "Payment_Processing"

metadata
    theme: pro
    layout: topdown

nodes
    receive
        label: "Receive Payment"
        type: start
        color: green
    
    validate
        label: "Validate Amount"
        type: process
        color: blue
    
    fraud_check
        label: "Fraud Detection"
        type: process
        color: blue
    
    approve
        label: "Manager Approval"
        type: decision
        color: yellow
    
    process_payment
        label: "Process Payment"
        type: process
        color: blue
    
    complete
        label: "Complete"
        type: endpoint
        color: coral

edges
    receive -> validate
    validate -> fraud_check
    fraud_check -> approve
    approve -> process_payment
    process_payment -> complete
*/

#------------------------------------#
#  Example 3: bank_structure.stzorg  #
#------------------------------------#

/*
orgchart "Regional_Bank"

metadata
    theme: pro
    layout: topdown

positions
    board
        title: "Board of Directors"
        level: executive
        department: board
    
    ceo
        title: "CEO"
        level: executive
        reportsTo: board
    
    cfo
        title: "CFO"
        level: management
        department: finance
        reportsTo: ceo

people
    p_alice
        name: "Alice Chen"
    
    p_bob
        name: "Bob Kumar"

assignments
    p_alice -> ceo
    p_bob -> cfo
*/

#-----------------------------------------#
#  Example 4: banking_compliance.stzrulz  #
#-----------------------------------------#

/*
ruleset "Banking Compliance Rules"
    domain: banking
    version: 1.0
    author: Compliance Team

rules

    rule fraud_before_payment
        type: validation
        level: diagram
        severity: error
        
        when
            operation equals "payment"
        then
            fraud_check required TRUE
        message
            "Payment must have fraud detection"
    
    rule ops_treasury_separation
        type: validation
        level: orgchart
        severity: error
        
        when
            department equals "operations"
            path exists to="treasury"
        then
            violation add "SOD violation: Ops under Treasury"
*/

#---------------------------------#
#  Example 5: restructure.stzsim  #
#---------------------------------#

/*
simulation "Treasury_Restructure"
    description: "Move treasury under CFO"
    author: Strategy Team
    date: 2024-01-15

changes

    move treasury_head
        from: ceo
        to: cfo
    
    add position risk_officer
        title: "Risk Officer"
        level: staff
        reportsTo: treasury_head

metrics

    track span_of_control
        for: cfo
        for: ceo
    
    track compliance
        validators: [bceao, banking]

compare

    before_after: span_of_control
    delta: compliance.issueCount
*/

#--------------------------------------#
#  Example 6: corporate_brand.stzstyl  #
#--------------------------------------#

/*
style "Corporate_Banking_Theme"
    theme: pro
    layout: topdown

colors
    executive: gold
    management: blue+
    staff: green-
    focus: magenta+

fonts
    default: helvetica
    size: 12

edges
    style: solid
    color: gray
    spline: ortho
    penwidth: 1

nodes
    penwidth: 2
    penstyle: rounded,filled
    strokecolor: gray

focus
    color: magenta+
    penwidth: 3
*/

#=================================================#
# SECTION 8: SELF-LOOPS AND REFLEXIVE OPERATIONS  #
#=================================================#

#NOTE: self-loops are a common graph feature for
# states or recursive dependencies

/*--- Basic Self-Loop Operations

pr()

oGraph = new stzGraph("SelfLoopTest")
oGraph {
	AddNode("node")
	Connect("node", :to = "node")  # Self-loop

	? EdgeExists(:from = "node", :to = "node")
	#--> TRUE

	SetEdgeProperty(:from = "node", :to = "node", "type", "recursive")
	? EdgeProperty(:from = "node", :to = "node", "type")
	#--> "recursive"

	RemoveEdge(:from = "node", :to = "node")
	? EdgeExists(:from = "node", :to = "node")
	#--> FALSE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Self-Loops in Cycles and Reachability

pr()
oGraph = new stzGraph("SelfCycleTest")
oGraph {
	AddNode("a")
	AddNode("b")

	Connect(:Node = "a", :WithNode = "a")  # Self-loop
	Connect(:Node = "a", :ToNode = "b")

	? CyclicDependencies()  #--> TRUE  # Self-loop counts as cycle
	? ReachableFromNode("a")  #--> [ "a", "b" ]  # Includes self
}
pf()
# Executed in almost 0 second(s) in Ring 1.24


#============================================#
# SECTION 9: RULE ENGINE ADVANCED
#============================================#

/*--- Inference Rule Chaining

pr()

oRule1 = new stzGraphRule("parent_infer")
oRule1 {
	SetRuleType("inference")
	When("type", "equals", "parent")
	Then("haschild", "add", TRUE)
}

oRule2 = new stzGraphRule("child_infer")
oRule2 {
	SetRuleType("inference")
	WhenPathExists("parent", "this")  # Assuming 'this' context
	Then("inheritsfrom", "add", "parent")
}

oGraph = new stzGraph("InferenceChain")
oGraph {
	AddNodeXTT("a", "A", [:type = "parent"])
	AddNodeXTT("b", "B", [:type = "child"])
	Connect("a", "b")

	ApplyRules()

	ApplyInference()  # Chain rules
	? NodeProperty("a", "haschild")  #--> TRUE
	? NodeProperty("b", "inheritsfrom")  #--> "parent"
}

#ERR Line 2916 Inexistant node key or/and property!

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Else Effects in Validation

pr()

oRule = new stzGraphRule("status_check")
oRule {
	SetRuleType("validation")
	When("status", "equals", "active")
	Then("requiredReview", "set", FALSE)
	Elze("requiredReview", "set", TRUE)
}

oGraph = new stzGraph("ElseTest")
oGraph {
	AddNodeXTT("n1", "N1", [:status = "active"])
	ApplyRules()

	Validate()  # Apply with else

	? NodeProperty("n1", "requiredReview")  #--> FALSE
	SetNodeProperty("n1", "status", "inactive")
	
	Validate()
	? NodeProperty("n1", "requiredReview")  #--> TRUE
}
pf()
#ERR Line 2916 Inexistant node key or/and property!

# Executed in almost 0 second(s) in Ring 1.24

/*--- Multi-Rule Interactions and Conflicts

pr()

oRule1 = new stzGraphRule("priority_boost")
oRule1 {
	SetRuleType("inference")
	When("priority", "lessthan", 10)
	Then("priority", "set", 10)
}

oRule2 = new stzGraphRule("priority_cap")
oRule2 {
	SetRuleType("constraint")
	When("priority", "greaterthan", 8)
	ThenViolation("Priority exceeds cap")
}

oGraph = new stzGraph("MultiRuleTest")
oGraph {
	AddNodeXTT("n1", "N1", [:priority = 5])
	ApplyRules()  # Inference first, then constraint

	? NodeProperty("n1", "priority")
	#--> 5

	? @@NL( Violations() )  #--> [ "Priority exceeds cap" ]  # Conflict detected
	#--> #TODO Is this correct:
	'
	[
		[ "constraint", [  ] ],
		[ "inference", [  ] ],
		[
			"validation",
			[ "Graph must be acyclic (DAG)" ]
		]
	]
	'

}
pf()
# Executed in 0.01 second(s) in Ring 1.24
