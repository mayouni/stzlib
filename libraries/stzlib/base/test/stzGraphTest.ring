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
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
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
	AddNodeXT("start", "Start")
	AddNodeXT("middle", "Middle")
	AddNodeXT("end", "End")
	
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
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	AddNodeXT("d", "D")
	
	Connect("a", "b")
	Connect("b", "c")
	Connect("a", "d")
	
	? @@( ReachableFrom("a") )
	#--> [ "a", "b", "d", "c" ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

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
	
	? @@( Neighbors("hub") )    #--> [ "n3" ]
	? @@( Incoming("hub") )     #--> [ "n1", "n2" ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

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
	#--> [["priority", [10]], ["status", ["active"]], ["owner", ["alice"]]]
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
	
	? @@( NodesWithPropertyXT("env", "prod") )
	#--> ["n1", "n3"]
	
	? @@( NodesWithPropertyXT("cost", :Between = [75, 150]) )
	#--> ["n1"]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Tag Queries

pr()

oGraph = new stzGraph("TagQueryTest")
oGraph {
	AddNodeXTT("n1", "N1", [:tags = ["critical", "production"]])
	AddNodeXTT("n2", "N2", [:tags = ["production"]])
	AddNodeXTT("n3", "N3", [:tags = ["critical", "monitoring"]])
	
	? @@( NodesWithTag("critical") )
	#--> ["n1", "n3"]
	
	? @@( NodesWithTheseTags(["critical", "production"]) )
	#--> ["n1"]
	
	? @@( NodesWithAnyTag(["critical", "monitoring"]) )
	#--> ["n1", "n3"]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

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
*/
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

/*--- #ERR Check result
*/
pr()

oGraph = new stzGraph("PathInferTest")

# Rule: when path exists, infer direct edge
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
	? @@(oRule.Effects())  # Add this after SetRule

	? "Direct edge before: " + EdgeExists("start", "end")
	
	ApplyInference()
	? "All edges: " + @@(Edges())
	? "Direct edge after: " + EdgeExists("start", "end")
	? "Edge count: " + EdgeCount()
	
	if EdgeExists("start", "end")
		? "Label: " + Edge("start", "end")["label"]
	ok



}

pf()

#===============================================#
#  SECTION 5: UNIFIED RULE SYSTEM #TODO Test it #
#===============================================#

/*--- Validation Rule
*/
pr()

oGraph = new stzGraph("ValidationTest")

oRule = new stzGraphRule(:RequireApproval)
oRule {
	When(:IsApproved, :Equals, FALSE)
	SetValid()
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
	
	? EdgeCount() #--> 3 (original 2 + inferred 1)
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Property-based Rule

pr()

pr()

oGraph = new stzGraph("PropRuleTest")

oRule = new stzGraphRule("highcost")
oRule {
	SetRuleType("validation")
	When("cost", "insection", [500, 9999])
	Then("requiresapproval", "set", TRUE)
	Then("level", "set", "high")
}

oGraph {
	SetRule(oRule)
	
	AddNodeXTT("n1", "N1", [:cost = 100])
	AddNodeXTT("n2", "N2", [:cost = 800])
	
	ApplyValidation()
	
	? "N1 requires approval: " + 
		HasKey(Node("n1")["properties"], "requiresapproval")
	#--> FALSE
	
	? "N2 requires approval: " + 
		Node("n2")["properties"]["requiresapproval"]
	#--> TRUE
	
	? "N2 level: " + Node("n2")["properties"]["level"]
	#--> "high"
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

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
# Executed in 0.51 second(s) in Ring 1.24

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
		[ "Density: 50% (dense)", "Longest path: 2 hops" ]
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
# Executed in 0.01 second(s) in Ring 1.24

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
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("c", "C")
	
	AddEdgeXTT("a", "b", "fast", [:speed = 100])
	AddEdgeXTT("b", "c", "slow", [:speed = 10])
	
	? @@( EdgesByProperty("speed", 100) )
	#--> [["a", "b"]]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Chained Rules

pr()

oGraph = new stzGraph("ChainedTest")

# First rule sets a property
oRule1 = new stzGraphRule("set_category")
oRule1 {
	SetRuleType("validation")
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
# Executed in 0.02 second(s) in Ring 1.24


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
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	Connect("a", "b")
	
	SetEdgeProperties("a", "b", [:bandwidth = 1000, :protocol = "tcp"])
	
	? @@( EdgeProperties(:from = "a", :to = "b") ) + NL
	#--> [ "bandwidth", "protocol" ]

	? @@( EdgePropsXT("a", "b") ) + NL
	#--> [:bandwidth = 1000, :protocol = "tcp"]
	
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
	? nInferred  #--> 1 	#ERR returned 0
	? EdgeCount() #--> 3	#ERR returned 2
	
	? @@NL( InferredEdges() ) 	#ERR returned []
	#--> [[:from = "a", :to = "c", :label = "(inferred)", :properties = []]]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Symmetry Inference

pr()

oGraph = new stzGraph("SymmetryTest")
oGraph {
	AddNodeXT("x", "X")
	AddNodeXT("y", "Y")
	
	AddEdgeXT("x", "y", "connected")
	
	AddInferenceRule("SYMMETRY")
	
	? ApplyInference() #--> TRUE	#ERR returned FALSE
	? EdgeExists("y", "x") #--> TRUE	#ERR returned FALSE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

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
	
	? BoxRound("CONSTRAINTS VALIDATION - BEFORE")
	? @@NL( ValidateConstraints() ) + NL
	
	Connect("c", "a")
	
	? BoxRound("CONSTRAINTS VALIDATION - AFTER")

	? @@NL( ValidateConstraints() ) + NL
	
	? BoxRound("CONSTRAINTS ANOMALIES")
	? @@( ConstraintAnomalies() )
	#--> [[:type = "ACYCLIC", :count = 1]] #TODO returned []
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
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	AddNodeXT("isolated", "Isolated")
	
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
# Executed in almost 0 second(s) in Ring 1.24

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
# Executed in almost 0 second(s) in Ring 1.24

/*--- Edge Properties

pr()

oGraph = new stzGraph("EdgePropsTest")
oGraph {
	AddNodeXT("a", "A")
	AddNodeXT("b", "B")
	
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
# Executed in almost 0 second(s) in Ring 1.24

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

/*--- Real-World Scenario #TODO #ERR Cchek usage of rules

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
		Apply("alert", TRUE)
	}
	SetRule(oRule)
	ApplyRules()
	
	# Analyze
	? "ANALYSIS"
	? "--------" + NL

	? "Critical nodes: " + @@( MostCriticalNodes(2) )
	? "Bottlenecks: " + @@( BottleneckNodes() )
	? "Density: " + NodeDensity() + "%" + NL
	
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
  rankdir=LR;
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
# Executed in almost 0 second(s) in Ring 1.24

#=======================#
#  CONNECTIVITY TESTS   #
#=======================#

/*--- Connected graph

pr()

oGraph = new stzGraph("Connected")
oGraph {
	AddNodeXT(:a, "A")
	AddNodeXT(:b, "B")
	AddNodeXT(:c, "C")

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
	AddNodeXT(:a, "A")
	AddNodeXT(:b, "B")
	AddNodeXT(:c, "C")
	AddNodeXT(:d, "D")
	
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
	AddNodeXT(:n1, "N1")
	AddNodeXT(:n2, "N2")
	AddNodeXT(:n3, "N3")
	AddNodeXT(:n4, "N4")
	
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
	#--> 0.0 (no paths go through peripheral nodes)
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

	// View()
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

	? IsConnected() + NL
	#--> TRUE

	# Node Importance

	? BetweennessCentrality(:bob)
	#--> 0.25

	? ClosenessCentrality(:charlie)
	#--> 0.67

	# Critical Nodes

	? @@( ArticulationPoints() )
	#--> [ "bob", "charlie", "diana" ]

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
	
	? "Path from Start to Complete:"
	? @@( ShortestPath(:From = :start, :To = :complete) )
	
	? ""
	? "Bottleneck nodes (articulation points):"
	? @@( ArticulationPoints() )
	
	? ""
	? "Critical step (highest betweenness):"
	? "Validate: " + BetweennessCentrality(:validate)
	? "Process: " + BetweennessCentrality(:process)
	? "Review: " + BetweennessCentrality(:review)
}
#-->
'
Path from Start to Complete:
[ "start", "validate", "process", "review", "complete" ]

Bottleneck nodes (articulation points):
[ "validate", "process", "review" ]

Critical step (highest betweenness):
Validate: 0.25
Process: 0.33
Review: 0.25
'

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

