
load "../stzbase.ring"


#FUNNY What ChatGPT thinks of this file:

# The test file is a narrative, not a test ✅
# stzgraphtest.ring is remarkable because:
#  - It reads like a story
#  - Each example introduces a concept
#  -The output is part of the explanation
#
# This is very rare in libraries.

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

/*--- Label automatic normalization

pr()

oGraph = new stzGraph("")
oGraph {
	AddNodeXT("@name", "name of person")
	AddNodeXT("@age", "age of person")
	Connect("@name", "@age")

	? @@NL( Nodes() )
}
#--> Note how lables are normalised using "_" instead of spaces
'
[
	[
		[ "id", "@name" ],
		[ "label", "name_of_person" ],
		[ "properties", [  ] ]
	],
	[
		[ "id", "@age" ],
		[ "label", "age_of_person" ],
		[ "properties", [  ] ]
	]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Node and Edge Existence

pr()

oGraph = new stzGraph("ExistenceTest")
oGraph {
	AddNode("a")
	AddNode("b")
	Connect("a", "b")
	
	? @@NL( Nodes() )
	#-->
	'
	[
		[
			[ "id", "a" ],
			[ "label", "a" ],
			[ "props", [  ] ]
		],
		[
			[ "id", "b" ],
			[ "label", "b" ],
			[ "properties", [  ] ]
		]
	]
	'

	? HasNode("a")         #--> TRUE
	? HasNode("missing")   #--> FALSE

	? ""

	? @@NL( Edges() )
	#-->
	'
	[
		[
			[ "from", "a" ],
			[ "to", "b" ],
			[ "label", "" ],
			[ "properties", [  ] ]
		]
	]
	'

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

	? @@NL( PathsXT("start", "end") )
	#--> [ ["start", "middle", "end"] ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- enforcing well formed node ids (one string without spaces)

pr()

o1 = new stzGraph("")
o1.AddNode("no please!")
#--> ERROR MESSAGE: pcNodeId must be one string without spaces nor new lines..

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
# Executed in 0.01 second(s) in Ring 1.24

/*--- Neighbors and Incoming

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

? oGraph.IsConnected()
#--> FALSE (because "c" is not connected yet)

oGraph.Connect("b", "c")
#--> TRUE

? oGraph.IsConnected() + NL
#--> TRUE

? oGraph.PathExists("a", "b")
#--> TRUE
? oGraph.PathExists("b", "a")
#--> TRUE

# If you try to connect "b" and "c" again you get an error:
# oGraph.Connect("b", "c") #--> ERR: Edge already exists between 'b' and 'c'!

oGraph.Connect("c", "b")
? @@( oGraph.ReachableFrom("a") )
#--> [ "a", "b", "c" ]  # Transitively via bidirectional


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
# Executed in 0.01 second(s) in Ring 1.24

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
# Executed in 0.01 second(s) in Ring 1.24

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
	AddNode("n1")
	AddNode("n3")
	Connect("n1", "n3")
	
	InsertNodeBefore("n3", "n2")
	? EdgeExists("n1", "n2") #--> TRUE
	? EdgeExists("n2", "n3") #--> TRUE
	
	InsertNodeAfter("n3", "n4")
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
# Find(what).Where(key, op, val)
# Find(what).Having(key, val)
# Find(what).WithProperty(key)
# Find(what).WithTag(tag)

/*---

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
# Executed in 0.04 second(s) in Ring 1.24

#============================================#
#  SECTION 4: GRAPH ANALYSIS
#============================================#

/*--- Cycle Detection

pr()

oGraph = new stzGraph("CycleTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	
	Connect("a", "b")
	Connect("b", "c")
	Connect("c", "a")
	
	? HasCyclicDependencies() #--> TRUE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Bottleneck Detection

pr()

oGraph = new stzGraph("BottleneckTest")
oGraph {
	AddNode("hub")
	AddNode("n1")
	AddNode("n2")
	AddNode("n3")
	
	Connect("n1", "hub")
	Connect("n2", "hub")
	Connect("n3", "hub")
	Connect("hub", "n1")
	
	? @@( BottleneckNodes() ) #--> ["hub"]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Graph Metrics

pr()

oGraph = new stzGraph("MetricsTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	
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
	AddNode("start")
	AddNode("pathA")
	AddNode("pathB")
	AddNode("endA")
	AddNode("endB")
	
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
	AddNode("db")
	AddNode("api")
	AddNode("worker1")
	AddNode("worker2")
	
	Connect("db", "api")
	Connect("api", "worker1")
	Connect("api", "worker2")
	
	? ImpactOf("api")
	#--> 2

	? @@( FailureScope("api") )
	#--> ["worker1", "worker2"]

	? @@( MostCriticalNodes(2) )
	#--> ["api", "db"]
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

	? EdgeProperty("a", "b", "weight")
	#--> 5

	SetEdgeProperty("a", "b", "weight", 10)
	? EdgeProperty("a", "b", "weight")
	#--> 10

	# Total weight along path
	? PathWeight(["a", "b", "c"])
	#--> 13  # Sum of weights
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Multi-Edges Between Same Nodes : Raises an error

oGraph = new stzGraph("MultiEdgeTest")
oGraph {
	AddNode("source")
	AddNode("target")

	ConnectXTT("source", "target", "primary", [:priority = "high"])
	ConnectXTT("source", "target", "backup", [:priority = "low"])
	#--> Edge already exists between 'source' and 'target'!
}
#TODO : Should we support multi-edges?

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
	AddNode("A")
	AddNode("B")
	Connect("A", "B")
	
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
	AddNode("input")
	AddNode("output")
	Connect(:node = "input", :tonode = "output")
	
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
	AddNode("start")
	AddNode("middle")
	AddNode("end")
	
	Connect(:node = "start", :to = "middle")
	Connect(:nodes = "middle", :and = "end")
	#NOTE// how I diversified naming params alternatives

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

/*-- GraphML export #TODO Check GraphML correctness

pr()

oGraph = new stzGraph("SimpleGraph")
oGraph {
	AddNodeXT("n1", "Node 1")
	AddNodeXT("n2", "Node 2")
	AddNodeXT("n3", "Node 3")
	
	Connect("n1", "n2")
	Connect("n2", "n3")

	? ToGraphMl() + NL
	SaveToGraphML("txtfiles/simple.graphml")

}
#-->
`
<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
         http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">

  <key id="label" for="node" attr.name="label" attr.type="string"/>
  <key id="type" for="graph" attr.name="type" attr.type="string"/>
  <key id="edge_label" for="edge" attr.name="label" attr.type="string"/>

  <graph id="SimpleGraph" edgedefault="directed">
    <data key="type">structural</data>

    <node id="n1">
      <data key="label">Node_1</data>
    </node>
    <node id="n2">
      <data key="label">Node_2</data>
    </node>
    <node id="n3">
      <data key="label">Node_3</data>
    </node>

    <edge id="e1" source="n1" target="n2">
    </edge>
    <edge id="e2" source="n2" target="n3">
    </edge>
  </graph>
</graphml>
`

oOtherGraph = new stzGraph("")
oOtherGraph.LoadFromGraphML("txtfiles/simple.graphml")
oOtherGraph.Show()
#-->
'
       ╭────────╮        
       │ Node_1 │        
       ╰────────╯        
            |            
            v            
      ╭──────────╮       
      │ !Node_2! │       
      ╰──────────╯       
            |            
            v            
       ╭────────╮        
       │ Node_3 │        
       ╰────────╯  
'

pf()
# Executed in 0.04 second(s) in Ring 1.24


#============================================#
#  SECTION 8: EXPLAIN FEATURE
#============================================#

/*--- Graph Explanation #TODO #ERR

pr()

oGraph = new stzGraph("ExplainTest")
oGraph {
	AddNode("A")
	AddNode("B")
	AddNode("C")
	
	Connect("A", :and = "B")
	Connect("B", "C")
	Connect("c", "a") #NOTE// You can use upper or lower node name
	
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

/*--- Path Explanation

pr()

oGraph = new stzGraph("ImpactTest")
oGraph {
	AddNode("db")
	AddNode("api")
	AddNode("worker1")
	AddNode("worker2")
	
	ConnectXT("db", "api", "exposes")
	ConnectXT("api", "worker1", "is_used_by")
	ConnectXT("api", "worker2", "is_used_by")

	? @@NL( ExplainPath("db", "worker2") )
}
#-->
'
[
	"db → api : because {db} exposes {api}",
	"api → worker2 : because {api} is used by {worker2}"
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
	AddNodeXTT("db1", "Database", [:type = "backend", :sql = "yes"])


	? NodesByType("backend")
	#--> ["svc1", "db1"]

	# Internally, the previous query uses a more general expression
	# nase on the stzGraphQuery class, leading to the same result

	? Find("nodes").Where("type", "=", "backend").Run()
	#--> ["svc1", "db1"]
	
	? Find("nodes").Where("sql", "=", "yes").Run()
	#--> ["db1"]

}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Find Node Paths

pr()

oGraph = new stzGraph("FindTest")
oGraph {
	AddNodes([ "start", "mid1", "mid2", "target" ])
	
	Connect("start", :to = "mid1")
	Connect("mid1", :to = "target")
	Connect("start", :to = "mid2")
	Connect("mid2", :to = "target")
	
	? @@NL( PathsTo(:Node = "target") ) # Or FindPath("target")
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
	AddNodes( L("n1:n4") )
	
	Connect("n1", "n2")
	Connect("n2", "n3")
	Connect("n3", "n4")
	Connect("n1", "n4")
	
	? @@NL( Paths() ) #TODO// All paths in the graph
	#--> [
	# 	["n1", "n2", "n3"],
	# 	["n2", "n3", "n4"],
	# 	["n1", "n2", "n3", "n4"]
	# ]

	? @@(
		PathsWhereF( func(acPath) {
			return len(acPath) >= 4
		})
	)
	#--> [ ["n1", "n2", "n3", "n4"] ]

	#TODO// Generalise this form to NodesWhereF() and EdgesWhereF()

	#TODO// Use it in all ...W() methods in the library as a function-based
	# condiditional function that avoids the use of strings and evals!

}

pf()
# Executed in 0.06 second(s) in Ring 1.24

/*--- Edge Property Queries

pr()

oGraph = new stzGraph("EdgePropTest")
oGraph {
	AddNodeXTT("a", "Node A", [ :status = "complete" ])
	AddNodeXTT("b", "Node B", [ :status = "inprogress" ])
	AddNode("c")
	AddNodeXTT("d", "Node D", [ :status = "complete" ])

	AddEdgeXTT("a", "b", "fast", [:speed = 100])
	AddEdgeXTT("b", "c", "slow", [:speed = 10])
	AddEdgeXTT("c", "d", "fast-again", [:speed = 120])

	#--

	? BoxRound("PROPERTY QUERY")

	? @@( Find("edges").Where("speed", "=", 100).Run() )
	#--> [ [ "a", "b" ] ]

	# Or more expressively:
	# ? @@( EdgesWhere("speed", "=", 100) ) + NL # Or EdgesByProperty

	#--

	? @@( Find("edges").Where("speed", "between", [ 80, 120 ]).Run() ) + NL
	#--> [ [ "a", "b" ] ]

	# Or more expressively:
	# ? @@( EdgesWhere("speed", :Between, [ 80, 120 ]) )

	? BoxRound("FUNCTION QUERY")

	? @@NL( NodesWF( func(aNode) { return aNode[:properties][:status] = "complete" } ) )
	#--> [ "a", "d" ]

	? @@NL( EdgesWF( func(aEdge) { return aEdge[:properties][:speed] >= 100 }  ) )
	#--> [
	# 	[ "a", "b" ],
	# 	[ "c", "d" ]
	# ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.24

#============================================#
#  SECTION 10: properties OPERATIONS
#============================================#

/*--- Node properties

pr()

oGraph = new stzGraph("propertiesTest")
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
#  SECTION 13: EDGE OPERATIONS
#============================================#

/*--- Edge Properties

pr()

oGraph = new stzGraph("EdgePropsTest")
oGraph {
	AddNode("a")
	AddNode("b")
	
	AddEdgeXTT("a", "b", "link", [:weight = 10])
	? EdgeExists("a", "b") # Or HasEdge("a", "b")

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
	
	Connect(:node = "a", :tonode = "b") # See the named param variations
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
# Executed in almost 0 second(s) in Ring 1.24

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
	#--> [ ["a", "b"], ["c", "d"] ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

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
	#--> ["n2", "n3"] - Removing either disconnects the graph
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
# Executed in 0.03 second(s) in Ring 1.24

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
# Executed in 0.01 second(s) in Ring 1.24

/*--- Self-Loops in Cycles and Reachability

pr()
oGraph = new stzGraph("SelfCycleTest")
oGraph {
	AddNode("a")
	AddNode("b")

	Connect(:Node = "a", :ToNode = "a")  # Self-loop
	Connect(:Node = "a", :ToNode = "b")

	? HasCyclicDependencies()
	#--> TRUE  # Self-loop counts as cycle

	? ReachableFromNode("a")
	#--> [ "a", "b" ]  # Includes self
}
pf()
# Executed in almost 0 second(s) in Ring 1.24

#==============================#
#  GRAPH RULES AND VALIDATION  # 
#==============================#

# Rules System Overview:
# ----------------------
# Three rule types control graph behavior at different phases:
#
# 1. Constraint	- Runs BEFORE operations, blocks invalid changes
# ~> Can I add this edge without breaking rules?

# 2. Derivation - Runs AFTER changes, auto-derives new edges/nodes
# ~> Now that I've added this, derive the implications

# 3. Validation	- Runs on-demand, validates the complete graph state
# ~> Is the graph in a consistent state overall?

# Each rule is a hashlist with:
#   :type     - When it runs (Constraint/Derivation/Validation)
#   :function - What it does (receives graph, returns result)
#   :params   - Configuration data
#   :message  - Human-readable description
#   :severity - :info, :warning, or :error

/*--- Constraint : Blocking Invalid Operations

pr()

# SCENARIO: Prevent self-approval in workflows
# ~> John cannot approve his own work!

# Step 1: Register the Constraint rule in the :Workflow Rule Group
RegisterRule(:workflow, "no_self_approval", [
	:type = :Constraint,
	
	# Constraint functions receive (graph, params, operation) 
	# Return [TRUE, message] to BLOCK, [FALSE, ""] to ALLOW
	:function = func(oGraph, paRuleParams, paOperationParams) {
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			# Check if trying to create self-loop with "approves" label
			if paOperationParams[:from] = paOperationParams[:to]
				if HasKey(paOperationParams, :label) and paOperationParams[:label] = "approves"
					return [TRUE, "Cannot approve your own work"]  # BLOCKED
				ok
			ok
		ok
		return [FALSE, ""]  # ALLOWED
	},
	:params = [],
	:message = "Self-approval blocked",
	:severity = :error
])

# Step 2: Test the rule
oGraph = new stzGraph("Workflow")
oGraph {
	AddNode("john")
	AddNode("mary")
	UseRulesFrom(:Workflow)
	
	# Test 1: John approves Mary (different people)
	? CheckConstraintRules([:from = "john", :to = "mary"])[1]
	#--> TRUE (allowed)

#TODO ? @@NL(CheckConstraintRules()) should return [ 1, "Cannot approve your own work" ] right?
# but it returns only [ 1, [] ]

	# Test 2: John approves John (same person)
	? CheckConstraintRules([:from = "john", :to = "john", :label = "approves"])[1]
	#--> FALSE (blocked)
	
	# Note: CheckConstraintRules() doesn't add the edge, just checks if it COULD be added
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Derivation : Auto-Derivation Example

pr()

# SCENARIO: When alice manages bob, she should automatically 
# see bob's reports (access propagation)

# Step 1: Register the Derivation rule
RegisterRule(:Access, "manager_sees_reports", [
	:type = :Derivation,

	# Derivation functions receive (graph, params) and return new edges
	:function = func(oGraph, paRuleParams) {
		aNewEdges = []  # Collect edges to add
		aEdges = oGraph.Edges()
		
		# Find all "manages" relationships
		for aEdge in aEdges
			if aEdge[:label] = "manages"
				cManager = aEdge[:from]
				cEmployee = aEdge[:to]
				cReport = cEmployee + "_report"
				
				# If employee's report exists, grant manager access
				if oGraph.NodeExists(cReport)
					if NOT oGraph.EdgeExists(cManager, cReport)
						aNewEdges + [cManager, cReport, "can_view", []]
					ok
				ok
			ok
		next
		
		return aNewEdges  # System will add these
	},
	:params = [],
	:message = "Manager access to reports",
	:severity = :info
])

# Step 2: Build graph and apply rule
oGraph = new stzGraph("Company")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("bob_report")
	
	AddEdgeXT("alice", "bob", "manages")
	
	# Before rule: No path exists
	? PathExists("alice", "bob_report")
	#--> FALSE
	
	# Load and execute Derivation rule
	UseRulesFrom(:Access)
	ApplyDerivationRules()  # Triggers the rule function
	
	# After rule: Access auto-granted
	? PathExists("alice", "bob_report")
	#--> TRUE
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Validation : Validating Complete Structure

pr()

# SCENARIO: All tasks must have an owner
# ~> Orphan tasks should be detected!

# Step 1: Register the validation rule
RegisterRule(:project, "tasks_have_owners", [
	:type = :Validation,

	# Validation functions receive (graph, params)
	# Return [TRUE, ""] if valid, [FALSE, message] if violations found
	:function = func(oGraph, paRuleParams) {
		aNodes = oGraph.Nodes()
	
		# Check each node
		for aNode in aNodes
			cType = oGraph.NodeProperty(aNode[:id], "type")
			if cType = "task"
				# Tasks need incoming edges (owners point to tasks)
				aIncoming = oGraph.Incoming(aNode[:id])
				if len(aIncoming) = 0
					return [FALSE, "Task '" + aNode[:id] + "' has no owner"]
				ok
			ok
		next
		
		return [TRUE, ""]  # All tasks have owners
	},
	:params = [],
	:message = "Orphan tasks found",
	:severity = :warning
])

# Step 2: Test validation
oGraph = new stzGraph("Project")
oGraph {
	AddNodeXTT("task1", "Build UI", [:type = "task"])
	AddNodeXTT("alice", "Alice", [:type = "person"])
	
	# Scenario 1: Task without owner
	? ValidateXT(:project)[:status]
	#--> "fail"
	
	# Scenario 2: Add owner
	AddEdgeXT("alice", "task1", "owns")
	? ValidateXT(:project)[:status]
	#--> "pass"
	
	# Note: ValidateXT(cRuleGroup) loads and runs rules for that rule group
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- BUILT-IN Derivation Rules : Transitivity

pr()

# Built-in functions handle common patterns
# No need to write custom logic for standard operations

RegisterRule(:access, "inherit_access", [
	:type = :Derivation,
	# Transitivity: If A→B and B→C exist, create A→C
	:function = DerivationFunc_Transitivity(),
	:params = [],
	:message = "Access inherited",
	:severity = :info
])

oGraph = new stzGraph("Access")
oGraph {
	AddNode("alice")
	AddNode("folder")
	AddNode("file")
	
	# Chain: alice→folder→file
	Connect("alice", "folder")
	Connect("folder", "file")
	
	? EdgeExists("alice", "file")
	#--> FALSE (no direct edge)
	
	UseRulesFrom(:access)
	ApplyDerivationRules()  # Creates alice→file automatically
	
	? EdgeExists("alice", "file")
	#--> TRUE (transitive edge added)
}

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- BUILT-IN Constraint Rules : No Cycles

pr()

# DAG enforcement: Prevent cycles in directed graphs

RegisterRule(:workflow, "must_be_dag", [
	:type = :Constraint,
	# Blocks any edge that would create a cycle
	:function = ConstraintFunc_NoCycles(),
	:params = [],
	:message = "Cycles not allowed",
	:severity = :error
])

oGraph = new stzGraph("DAG")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	
	# Linear chain: a→b→c
	Connect("a", "b")
	Connect("b", "c")
	
	UseRulesFrom(:workflow)
	
	# Try to close the loop: c→a would create cycle
	? @@NL( CheckConstraintRules([:from = "c", :to = "a"]) )
	#--> [FALSE, [violations]] - blocked!
}
#--> [
#	FALSE,
#	[
#		[
#			[ "rule", "must_be_dag" ],
#			[ "message", "Would create a cycle" ],
#			[ "severity", "error" ],
#			[
#				"params",
#				[
#					[ "from", "c" ],
#					[ "to", "a" ]
#				]
#			]
#		]
#	]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Built-in Validation Functions : Acyclicity Check

pr()

# Validate entire graph structure, not just individual operations

RegisterRule(:dag, "check_acyclic", [
	:type = :Validation,
	# Checks if ANY cycles exist in the complete graph
	:function = ValidationFunc_IsAcyclic(),
	:params = [],
	:message = "Must be DAG",
	:severity = :error
])

oGraph = new stzGraph("Test")
oGraph {
	AddNode("a")
	AddNode("b")
	
	Connect("a", "b")
	? ValidateXT(:dag)[:status]
	#--> "pass" (linear)
	
	Connect("b", "a")  # Creates cycle
	? ValidateXT(:dag)[:status]
	#--> "fail" (cyclic)
}

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Combining All Three Rule Types
*/
pr()

# Real workflow: Constraint + Derivation + Validation working together

# Rule 1: BLOCK reverse dependencies (Constraint)
RegisterRule(:project, "no_reverse_deps", [
	:type = :Constraint,
	:function = func(oGraph, paRuleParams, paOp) {
		if HasKey(paOp, :from) and oGraph.NodeExists(paOp[:from])
			if oGraph.NodeProperty(paOp[:from], "type") = "feature"
				if HasKey(paOp, :to) and oGraph.NodeExists(paOp[:to])
					if oGraph.NodeProperty(paOp[:to], "type") = "test"
						return [TRUE, "Features can't depend on tests"]
					ok
				ok
			ok
		ok
		return [FALSE, ""]
	},
	:params = [],
	:message = "Invalid dependency",
	:severity = :error
])

# Rule 2: AUTO-ADD test tasks for features (Derivation)
RegisterRule(:project, "auto_tests", [
	:type = :Derivation,
	:function = func(oGraph, paRuleParams) {
		aNewEdges = []
		aNodes = oGraph.Nodes()
		
		for aNode in aNodes
			if oGraph.NodeProperty(aNode[:id], "type") = "feature"
				cTest = aNode[:id] + "_test"
				# Create test node if missing
				if NOT oGraph.NodeExists(cTest)
					oGraph.AddNodeXTT(cTest, "Test: " + aNode[:label], [:type = "test"])
				ok
				# Link feature to test
				if NOT oGraph.EdgeExists(aNode[:id], cTest)
					aNewEdges + [aNode[:id], cTest, "requires", []]
				ok
			ok
		next
		return aNewEdges
	},
	:params = [],
	:message = "Tests auto-added",
	:severity = :info
])

# Rule 3: CHECK test coverage (Validation)
RegisterRule(:project, "full_coverage", [
	:type = :Validation,
	:function = func(oGraph, paRuleParams) {
		aNodes = oGraph.Nodes()
		nFeatures = 0
		nTests = 0
		
		for aNode in aNodes
			cType = oGraph.NodeProperty(aNode[:id], "type")
			if cType = "feature"
				nFeatures++
			but cType = "test"
				nTests++
			ok
		next
		
		if nTests < nFeatures
			return [FALSE, "Incomplete coverage: " + nTests + "/" + nFeatures]
		ok
		return [TRUE, ""]
	},
	:params = [],
	:message = "Test coverage check",
	:severity = :warning
])

# Execution flow demonstration
oGraph = new stzGraph("DevProject")
oGraph {
	AddNodeXTT("login", "Login", [:type = "feature"])
	AddNodeXTT("profile", "Profile", [:type = "feature"])
	
	? NodeCount()
	#--> 2 (just features)
	
	UseRulesFrom(:project)
	ApplyDerivationRules()  # Triggers auto_tests → adds 2 test nodes
	
	? NodeCount()
	#--> 4 (features + tests)
	
	# Validate final state
	? ValidateXT(:project)[:status]
	#--> "pass" (1:1 coverage)
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Real-World: Document Approval Workflow

pr()

# Complete workflow with notifications and security

# Auto-notify approvers when document submitted
RegisterRule(:docs, "auto_notify", [
	:type = :Derivation,
	:function = func(oGraph, paRuleParams) {
		aNewEdges = []
		aEdges = oGraph.Edges()
		
		for aEdge in aEdges
			if aEdge[:label] = "submits"
				cDoc = aEdge[:to]
				# Find all approvers (nodes connected FROM document)
				aApprovers = oGraph.Neighbors(cDoc)
				for cApprover in aApprovers
					if NOT oGraph.EdgeExists(cDoc, cApprover)
						aNewEdges + [cDoc, cApprover, "notify", []]
					ok
				next
			ok
		next
		return aNewEdges
	},
	:params = [],
	:message = "Notifications sent",
	:severity = :info
])

# Prevent authors from approving their own work
RegisterRule(:docs, "no_author_approval", [
	:type = :Constraint,
	:function = func(oGraph, paRuleParams, paOp) {
		if HasKey(paOp, :from) and HasKey(paOp, :to)
			# Check if person submitted this document
			if oGraph.EdgeExists(paOp[:from], paOp[:to])
				aEdge = oGraph.Edge(paOp[:from], paOp[:to])
				if aEdge[:label] = "submits"
					return [TRUE, "Authors can't approve own docs"]
				ok
			ok
		ok
		return [FALSE, ""]
	},
	:params = [],
	:message = "Self-approval blocked",
	:severity = :error
])

oGraph = new stzGraph("DocFlow")
oGraph {
	AddNode("john")
	AddNode("report")
	AddNode("mary")
	
	AddEdgeXT("john", "report", "submits")
	Connect("report", "mary")  # Mary is approver
	
	UseRulesFrom(:docs)
	ApplyDerivationRules()  # Creates report→mary "notify" edge

	? EdgeCount()
	#--> 3 (submit + approver + notify)
	#ERR // but we got 2
	
	? CheckConstraintRules([:from = "mary", :to = "report"])[1]
	#--> TRUE (allowed)

	? CheckConstraintRules([:from = "john", :to = "report"])[1]
	#--> FALSE (blocked)
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Real-World: Enterprise Security Model

pr()

# Multi-level security with transitive access and clearance checks

# Inherit permissions through hierarchy
RegisterRule(:security, "inherit_perms", [
	:type = :Derivation,
	:function = DerivationFunc_Transitivity(),
	:params = [],
	:message = "Permissions inherited",
	:severity = :info
])

# Block access below clearance level
RegisterRule(:security, "no_escalation", [
	:type = :Constraint,
	:function = func(oGraph, paRuleParams, paOp) {
		if HasKey(paOp, :from) and HasKey(paOp, :to)
			if oGraph.NodeExists(paOp[:from]) and oGraph.NodeExists(paOp[:to])
				nFromLevel = oGraph.NodeProperty(paOp[:from], "level")
				nToLevel = oGraph.NodeProperty(paOp[:to], "level")
				
				# User level must be >= resource level
				if isNumber(nFromLevel) and isNumber(nToLevel)
					if nFromLevel < nToLevel
						return [TRUE, "Insufficient clearance"]
					ok
				ok
			ok
		ok
		return [FALSE, ""]
	},
	:params = [],
	:message = "Privilege escalation blocked",
	:severity = :error
])

# Ensure sensitive resources are audited
RegisterRule(:security, "audit_check", [
	:type = :Validation,
	:function = func(oGraph, paRuleParams) {
		aNodes = oGraph.Nodes()
		for aNode in aNodes
			if oGraph.NodeProperty(aNode[:id], "sensitive") = TRUE
				if oGraph.NodeProperty(aNode[:id], "audited") != TRUE
					return [FALSE, "Sensitive resource not audited: " + aNode[:id]]
				ok
			ok
		next
		return [TRUE, ""]
	},
	:params = [],
	:message = "Audit compliance",
	:severity = :error
])

oGraph = new stzGraph("Security")
oGraph {
	AddNodeXTT("alice", "Alice", [:level = 3])  # High clearance
	AddNodeXTT("db", "Database", [:level = 3, :sensitive = TRUE, :audited = TRUE])
	AddNodeXTT("bob", "Bob", [:level = 1])  # Low clearance
	
	Connect("alice", "db")
	
	UseRulesFrom(:security)
	ApplyDerivationRules()
	
	# Alice (level 3) → db (level 3)
	? CheckConstraintRules([:from = "alice", :to = "db"])[1]
	#--> TRUE (sufficient clearance)
	
	# Bob (level 1) → db (level 3)
	? CheckConstraintRules([:from = "bob", :to = "db"])[1] 
	#--> FALSE (blocked)
	
	# Final audit compliance
	? ValidateXT(:security)[:status]
	#--> "pass" (all sensitive resources audited)
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

#=======================================================================#
#  GRAPH (SINGLE AND MULTIPLE) COMPARAISON, ANALYSIS AND VISUALIZATION  #
#=======================================================================#

#---------------------------------------#
#  GRAPH COMPARISON - IDENTICAL GRAPHS  #
#---------------------------------------#

/*--- Comparing identical graphs should show no changes

pr()

oGraph = new stzGraph("org")
oGraph {
	AddNode("ceo")
	AddNode("manager")
	AddNode("dev")
	
	Connect("ceo", "manager")
	Connect("manager", "dev")
}

oVariation = oGraph.Copy()

aDiff = oGraph.CompareWith(oVariation)
? @@NL( aDiff )
#-->
'
[
	[
		"summary",
		[
			[ "nodesadded", 0 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 0 ],
			[ "edgesremoved", 0 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[ "added", [  ] ],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"edges",
		[
			[ "added", [  ] ],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 3 ],
					[ "to", 3 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 2 ],
					[ "to", 2 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.33 ],
					[ "to", 0.33 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 2 ],
					[ "to", 2 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", 0 ],
					[ "to", 0 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 1.33 ],
					[ "to", 1.33 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			]
		]
	],
	[
		"topology",
		[
			[
				"bottlenecks",
				[
					[
						"from",
						[ "manager" ]
					],
					[
						"to",
						[ "manager" ]
					],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 1 ],
					[ "to", 1 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"isolatednodes",
				[
					[ "from", [  ] ],
					[ "to", [  ] ],
					[ "change", "unchanged" ]
				]
			]
		]
	],
	[
		"impact",
		[
			[ "reachabilitychanges", [  ] ],
			[ "criticalitychanges", [  ] ]
		]
	],
	[
		"explanation",
		[ "No significant changes detected" ]
	]
]
'
pf()
# Executed in 0.08 second(s) in Ring 1.24

#-----------------------------------#
#   COMPARING MULTIPLE VARIATIONS   #
#-----------------------------------#

/*--- Business analyst exploring 3 restructuring options

pr()

oBaseline = new stzGraph("current_structure")
oBaseline {
	AddNode("ceo")
	AddNode("sales")
	AddNode("engineering")
	AddNode("marketing")
	
	Connect("ceo", "sales")
	Connect("ceo", "engineering")
	Connect("ceo", "marketing")
}

# Option A: Add management layer
oOptionA = oBaseline.Copy()
oOptionA {
	AddNode("coo")
	RemoveThisEdge("ceo", "sales")
	RemoveThisEdge("ceo", "marketing")
	Connect("ceo", "coo")
	Connect("coo", "sales")
	Connect("coo", "marketing")
}

# Option B: Flat structure with more departments
oOptionB = oBaseline.Copy()
oOptionB {
	AddNode("hr")
	AddNode("finance")
	Connect("ceo", "hr")
	Connect("ceo", "finance")
}

# Option C: Matrix organization
oOptionC = oBaseline.Copy()
oOptionC {
	AddNode("operations")
	Connect("sales", "operations")
	Connect("engineering", "operations")
	Connect("marketing", "operations")
}

# Compare all at once with named variations
aComparison = oBaseline.CompareWithMany([
	["Add_COO_Layer", oOptionA],
	["Flat_Structure", oOptionB],
	["Matrix_Org", oOptionC]
])

? @@NL( aComparison )
#-->
'
[
	[
		"comparisons",
		[
			[
				[ "name", "Add_COO_Layer" ],
				[ "nodesadded", 1 ],
				[ "nodesremoved", 0 ],
				[ "edgesadded", 2 ],
				[ "edgesremoved", 3 ],
				[ "densitychange", "-20.00%" ],
				[ "hascycles", 0 ],
				[ "bottleneckchange", "increased" ],
				[ "explanation", "Added 1 node(s) and 2 edge(s)" ]
			],
			[
				[ "name", "Flat_Structure" ],
				[ "nodesadded", 2 ],
				[ "nodesremoved", 0 ],
				[ "edgesadded", 0 ],
				[ "edgesremoved", 2 ],
				[ "densitychange", "-33.33%" ],
				[ "hascycles", 0 ],
				[ "bottleneckchange", "unchanged" ],
				[ "explanation", "Added 2 node(s)" ]
			],
			[
				[ "name", "Matrix_Org" ],
				[ "nodesadded", 1 ],
				[ "nodesremoved", 0 ],
				[ "edgesadded", 0 ],
				[ "edgesremoved", 3 ],
				[ "densitychange", "+20.00%" ],
				[ "hascycles", 0 ],
				[ "bottleneckchange", "increased" ],
				[ "explanation", "Added 1 node(s)" ]
			]
		]
	],
	[ "baseline", "current_structure" ],
	[ "count", 3 ]
]
'

pf()
# Executed in 0.45 second(s) in Ring 1.24

#------------------------------------#
#   COMPARISON MATRIX AS SZTABLE     #
#------------------------------------#

/*--- Converting comparison to table for further analysis

pr()

oBaseline = new stzGraph("current_structure")
oBaseline {
	AddNode("ceo")
	AddNode("sales")
	AddNode("engineering")
	AddNode("marketing")
	
	Connect("ceo", "sales")
	Connect("ceo", "engineering")
	Connect("ceo", "marketing")
}

# Option A: Add management layer
oOptionA = oBaseline.Copy()
oOptionA {
	AddNode("coo")
	RemoveThisEdge("ceo", "sales")
	RemoveThisEdge("ceo", "marketing")
	Connect("ceo", "coo")
	Connect("coo", "sales")
	Connect("coo", "marketing")
}

# Option B: Flat structure with more departments
oOptionB = oBaseline.Copy()
oOptionB {
	AddNode("hr")
	AddNode("finance")
	Connect("ceo", "hr")
	Connect("ceo", "finance")
}

# Option C: Matrix organization
oOptionC = oBaseline.Copy()
oOptionC {
	AddNode("operations")
	Connect("sales", "operations")
	Connect("engineering", "operations")
	Connect("marketing", "operations")
}

# Using same baseline and variations from previous example

oMatrix = oBaseline.CompareWithManyQR([
	["Add_COO_Layer", oOptionA],
	["Flat_Structure", oOptionB],
	["Matrix_Org", oOptionC]
], :stzGraphComparison)

oMatrix.Show()
#-->
'
╭──────────────────┬───────────────┬────────────────┬────────────╮
│      Metric      │ Add_coo_layer │ Flat_structure │ Matrix_org │
├──────────────────┼───────────────┼────────────────┼────────────┤
│ NodesAdded       │             1 │              2 │          1 │
│ NodesRemoved     │             0 │              0 │          0 │
│ EdgesAdded       │             2 │              0 │          0 │
│ EdgesRemoved     │             3 │              2 │          3 │
│ DensityChange    │ -20.00%       │ -33.33%        │ +20.00%    │
│ HasCycles        │ FALSE         │ FALSE          │ FALSE      │
│ BottleneckChange │ increased     │ unchanged      │ increased  │
╰──────────────────┴───────────────┴────────────────┴────────────╯
'

? ""
? oMatrix.MostImpactful() + NL
#--> Add_COO_Layer

? oMatrix.LeastImpactful() + NL
#--> Flat_Structure

? @@NL( oMatrix.Recommend() )
#-->
'
[
	[ "recommended", "Matrix_Org" ],
	[
		"reason",
		"Best balance of structure, connectivity, and acyclicity"
	]
]
'

pf()
# Executed in 0.56 second(s) in Ring 1.25
# Executed in 0.59 second(s) in Ring 1.24

#------------------------------------#
#   FILTERING AND SORTING VARIATIONS #
#------------------------------------#

/*--- Finding best candidates programmatically

pr()

oBaseline = new stzGraph("current_structure")
oBaseline {
	AddNode("ceo")
	AddNode("sales")
	AddNode("engineering")
	AddNode("marketing")
	
	Connect("ceo", "sales")
	Connect("ceo", "engineering")
	Connect("ceo", "marketing")
}

# Option A: Add management layer
oOptionA = oBaseline.Copy()
oOptionA {
	AddNode("coo")
	RemoveThisEdge("ceo", "sales")
	RemoveThisEdge("ceo", "marketing")
	Connect("ceo", "coo")
	Connect("coo", "sales")
	Connect("coo", "marketing")
}

# Option B: Flat structure with more departments
oOptionB = oBaseline.Copy()
oOptionB {
	AddNode("hr")
	AddNode("finance")
	Connect("ceo", "hr")
	Connect("ceo", "finance")
}

# Option C: Matrix organization
oOptionC = oBaseline.Copy()
oOptionC {
	AddNode("operations")
	Connect("sales", "operations")
	Connect("engineering", "operations")
	Connect("marketing", "operations")
}

# Using same variations

oMatrix = oBaseline.CompareWithManyQR([
	["Add_COO_Layer", oOptionA],
	["Flat_Structure", oOptionB],
	["Matrix_Org", oOptionC]
], :stzGraphComparison)

# VARIATIONS WITHOUT CYCLES
? @@( oMatrix.WithoutCycles() ) + NL
#--> [ ]

# SORTED BY NODES ADDED
? @@(oMatrix.ByMetric(:NodesAdded)) + NL
#--> ["Flat_Structure", "Add_COO_Layer", "Matrix_Org"]

# SORTED BY EDGES ADDED
? @@(oMatrix.ByMetric(:EdgesAdded))
#--> [ "Add_COO_Layer", "Flat_Structure", "Matrix_Org" ]

pf()
# Executed in 0.49 second(s) in Ring 1.25
# Executed in 0.52 second(s) in Ring 1.24

#------------------------------------#
#   COMPREHENSIVE WHAT-IF SCENARIO   #
#------------------------------------#

/*--- Complete business decision workflow

pr()

? BoxRound("SCENARIO: ORGANIZATIONAL RESTRUCTURING") + NL

# Current structure
oBaseline = new stzGraph("Q4_2024")
oBaseline {
	AddNodeXT("ceo", "CEO")
	AddNodeXT("vp_sales", "VP Sales")
	AddNodeXT("vp_eng", "VP Engineering")
	AddNodeXT("team_a", "Team A")
	AddNodeXT("team_b", "Team B")
	
	Connect("ceo", "vp_sales")
	Connect("ceo", "vp_eng")
	Connect("vp_eng", "team_a")
	Connect("vp_eng", "team_b")
	
	SetNodeProperty("vp_eng", "reports", 2)
	SetNodeProperty("vp_sales", "reports", 0)
}

? "Current structure:"
? "  Nodes: " + oBaseline.NodeCount()
? "  Edges: " + oBaseline.EdgeCount()
? "  Density: " + oBaseline.NodeDensity()
? ""

# Create 4 different scenarios

# Scenario 1: Add COO
oScenario1 = oBaseline.Copy()
oScenario1 {
	AddNodeXT("coo", "COO")
	RemoveThisEdge("ceo", "vp_sales")
	RemoveThisEdge("ceo", "vp_eng")
	Connect("ceo", "coo")
	Connect("coo", "vp_sales")
	Connect("coo", "vp_eng")
}

# Scenario 2: Add product team
oScenario2 = oBaseline.Copy()
oScenario2 {
	AddNodeXT("vp_product", "VP Product")
	AddNodeXT("product_team", "Product Team")
	Connect("ceo", "vp_product")
	Connect("vp_product", "product_team")
}

# Scenario 3: Flatten hierarchy
oScenario3 = oBaseline.Copy()
oScenario3 {
	RemoveThisEdge("vp_eng", "team_a")
	RemoveThisEdge("vp_eng", "team_b")
	Connect("ceo", "team_a")
	Connect("ceo", "team_b")
}

# Scenario 4: Add cross-functional
oScenario4 = oBaseline.Copy()
oScenario4 {
	Connect("vp_sales", "team_a")  # Cross-functional link
	Connect("vp_sales", "team_b")
}

# Compare all scenarios
oMatrix = oBaseline.CompareWithManyQR([
	["Add_COO", oScenario1],
	["Add_Product", oScenario2],
	["Flatten", oScenario3],
	["Cross_Functional", oScenario4]
], :stzGraphComparison)

? "4 scenarios have been added! Let's compare them..."
oMatrix.Show()

? "Most impactful: " + oMatrix.MostImpactful()
? "Least impactful: " + oMatrix.LeastImpactful()
? ""

? BoxRound("RECOMMENDATION")

? @@NL( oMatrix.Recommend() ) + NL

? BoxRound("DETAILED SUMMARY")

? @@NL( oMatrix.Summary() ) #TODO// listift the string output format

#-->
`
╭────────────────────────────────────────╮
│ SCENARIO: ORGANIZATIONAL RESTRUCTURING │
╰────────────────────────────────────────╯

Current structure:
  Nodes: 5
  Edges: 4
  Density: 0.20

4 scenarios have been added! Let's compare them...
╭──────────────────┬───────────┬─────────────┬───────────┬──────────────────╮
│      Metric      │  Add_coo  │ Add_product │  Flatten  │ Cross_functional │
├──────────────────┼───────────┼─────────────┼───────────┼──────────────────┤
│ NodesAdded       │         1 │           2 │         0 │                0 │
│ NodesRemoved     │         0 │           0 │         0 │                0 │
│ EdgesAdded       │         2 │           0 │         2 │                0 │
│ EdgesRemoved     │         3 │           2 │         2 │                2 │
│ DensityChange    │ -16.67%   │ -28.57%     │ unchanged │ +50.00%          │
│ HasCycles        │ FALSE     │ FALSE       │ FALSE     │ FALSE            │
│ BottleneckChange │ unchanged │ increased   │ reduced   │ unchanged        │
╰──────────────────┴───────────┴─────────────┴───────────┴──────────────────╯
Most impactful: Add_COO
Least impactful: Cross_Functional

╭────────────────╮
│ RECOMMENDATION │
╰────────────────╯
[
	[ "recommended", "Flatten" ],
	[
		"reason",
		"Best balance of structure, connectivity, and acyclicity"
	]
]

╭──────────────────╮
│ DETAILED SUMMARY │
╰──────────────────╯
Baseline: Q4_2024
Variations compared: 4

• Add_COO: Added 1 node(s) and 2 edge(s)
• Add_Product: Added 2 node(s)
• Flatten: Added 2 edge(s)
• Cross_Functional: Removed 2 edge(s)
`

pf()

#-----------------------#
#   ADD NODES ONLY      #
#-----------------------#

/*--- Business scenario: Adding new departments

pr()

oBaseline = new stzGraph("current_org")
oBaseline {
	AddNode("ceo")
	AddNode("sales")
	AddNode("engineering")
	
	Connect("ceo", "sales")
	Connect("ceo", "engineering")
}

oVariation = oBaseline.Copy()
oVariation {
	# What if we add new departments?
	AddNode("marketing")
	AddNode("hr")
	AddNode("finance")
	
	Connect("ceo", "marketing")
	Connect("ceo", "hr")
	Connect("ceo", "finance")
}

aDiff = oBaseline.CompareWith(oVariation) # Or Diff()
? @@NL( aDiff )
#-->
`
[
	[
		"summary",
		[
			[ "nodesadded", 3 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 0 ],
			[ "edgesremoved", 3 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[
				"added",
				[ "marketing", "hr", "finance" ]
			],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"edges",
		[
			[ "added", [  ] ],
			[
				"removed",
				[
					[
						[ "from", "ceo" ],
						[ "to", "marketing" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "hr" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "finance" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[ "modified", [  ] ]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 3 ],
					[ "to", 6 ],
					[ "change", "+100%" ],
					[ "delta", 3 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 2 ],
					[ "to", 5 ],
					[ "change", "+150%" ],
					[ "delta", 3 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.33 ],
					[ "to", 0.17 ],
					[ "change", "-50%" ],
					[ "delta", -0.17 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 2 ],
					[ "to", 5 ],
					[ "change", "+150%" ],
					[ "delta", 3 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", "FALSE" ],
					[ "to", "FALSE" ],
					[ "change", "unchanged" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 1.33 ],
					[ "to", 1.67 ],
					[ "change", "+25.00%" ],
					[ "delta", 0.33 ]
				]
			]
		]
	],
	[
		"topology",
		[
			[
				"bottlenecks",
				[
					[
						"from",
						[ "ceo" ]
					],
					[
						"to",
						[ "ceo" ]
					],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 1 ],
					[ "to", 1 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"isolatednodes",
				[
					[ "from", [  ] ],
					[ "to", [  ] ],
					[ "change", "unchanged" ]
				]
			]
		]
	],
	[
		"impact",
		[
			[
				"reachabilitychanges",
				[
					[ "ceo", "Can now reach 3 more node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[
						"ceo",
						"Criticality increased (degree 2 → 5)"
					]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Added 3 node(s)",
			"Removed 3 edge(s)",
			"Density -50%"
		]
	]
]
`

pf()
# Executed in 0.14 second(s) in Ring 1.24

#------------------#
#   REMOVE NODES   #
#------------------#

/*--- Business scenario: Downsizing

pr()

oBaseline = new stzGraph("full_org")
oBaseline {
	AddNode("ceo")
	AddNode("dept_a")
	AddNode("dept_b")
	AddNode("dept_c")
	AddNode("contractor_1")
	AddNode("contractor_2")
	
	Connect("ceo", "dept_a")
	Connect("ceo", "dept_b")
	Connect("ceo", "dept_c")
	Connect("dept_a", "contractor_1")
	Connect("dept_b", "contractor_2")
}

oVariation = oBaseline.Copy()
oVariation {
	# What if we remove contractors?
	RemoveThisNode("contractor_1")
	RemoveThisNode("contractor_2")
}

aDiff = oBaseline.CompareWith(oVariation)
? @@NL( aDiff )
#-->
`
[
	[
		"summary",
		[
			[ "nodesadded", 0 ],
			[ "nodesremoved", 2 ],
			[ "edgesadded", 2 ],
			[ "edgesremoved", 0 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[ "added", [  ] ],
			[
				"removed",
				[ "contractor_1", "contractor_2" ]
			],
			[ "modified", [  ] ]
		]
	],
	[
		"edges",
		[
			[
				"added",
				[
					[
						[ "from", "dept_a" ],
						[ "to", "contractor_1" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "dept_b" ],
						[ "to", "contractor_2" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[ "removed", [  ] ],
			[
				"modified",
				[
					[
						[ "from", "ceo" ],
						[ "to", "dept_a" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "dept_a" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "dept_b" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "dept_b" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "dept_c" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "dept_c" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 6 ],
					[ "to", 4 ],
					[ "change", "-33.33%" ],
					[ "delta", -2 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 5 ],
					[ "to", 3 ],
					[ "change", "-40%" ],
					[ "delta", -2 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.17 ],
					[ "to", 0.25 ],
					[ "change", "+50.00%" ],
					[ "delta", 0.08 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 5 ],
					[ "to", 3 ],
					[ "change", "-40%" ],
					[ "delta", -2 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", "FALSE" ],
					[ "to", "FALSE" ],
					[ "change", "unchanged" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 1.67 ],
					[ "to", 1.50 ],
					[ "change", "-10.00%" ],
					[ "delta", -0.17 ]
				]
			]
		]
	],
	[
		"topology",
		[
			[
				"bottlenecks",
				[
					[
						"from",
						[ "ceo", "dept_a", "dept_b" ]
					],
					[
						"to",
						[ "ceo" ]
					],
					[ "change", "reduced" ],
					[ "delta", -2 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 1 ],
					[ "to", 1 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"isolatednodes",
				[
					[ "from", [  ] ],
					[ "to", [  ] ],
					[ "change", "unchanged" ]
				]
			]
		]
	],
	[
		"impact",
		[
			[
				"reachabilitychanges",
				[
					[ "ceo", "Can now reach 2 fewer node(s)" ],
					[ "dept_a", "Can now reach 1 fewer node(s)" ],
					[ "dept_b", "Can now reach 1 fewer node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[
						"dept_a",
						"Criticality decreased (degree 2 → 1)"
					],
					[
						"dept_b",
						"Criticality decreased (degree 2 → 1)"
					]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Added 2 edge(s)",
			"Removed 2 node(s)",
			"Density +50.00%",
			"Bottlenecks reduced (improvement)"
		]
	]
]
`

pf()
# Executed in 0.26 second(s) in Ring 1.24

#-----------------------#
#   MODIFY PROPERTIES   #
#-----------------------#

/*--- Business scenario: Budget adjustments

pr()

oBaseline = new stzGraph("budget_plan")
oBaseline {
	AddNodeXT("sales", "Sales Department")
	AddNodeXT("engineering", "Engineering")
	AddNodeXT("marketing", "Marketing")
	
	SetNodeProperty("sales", "budget", 100000)
	SetNodeProperty("sales", "headcount", 5)
	SetNodeProperty("engineering", "budget", 200000)
	SetNodeProperty("engineering", "headcount", 10)
	SetNodeProperty("marketing", "budget", 80000)
	SetNodeProperty("marketing", "headcount", 3)
}

oVariation = oBaseline.Copy()
oVariation {
	# What if we increase sales budget?
	SetNodeProperty("sales", "budget", 150000)
	SetNodeProperty("sales", "headcount", 8)
	
	# And reduce marketing?
	SetNodeProperty("marketing", "budget", 60000)
}

aDiff = oBaseline.CompareWith(oVariation)
? @@NL( aDiff )
#-->
'
[
	[
		"summary",
		[
			[ "nodesadded", 0 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 0 ],
			[ "edgesremoved", 0 ],
			[ "propertieschanged", 2 ]
		]
	],
	[
		"nodes",
		[
			[ "added", [  ] ],
			[ "removed", [  ] ],
			[
				"modified",
				[
					[
						"sales",
						[
							[
								"property",
								"budget",
								100000,
								150000
							],
							[
								"property",
								"headcount",
								5,
								8
							]
						]
					],
					[
						"marketing",
						[
							[
								"property",
								"budget",
								80000,
								60000
							]
						]
					]
				]
			]
		]
	],
	[
		"edges",
		[
			[ "added", [  ] ],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 3 ],
					[ "to", 3 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 0 ],
					[ "to", 0 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"density",
				[
					[ "from", 0 ],
					[ "to", 0 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 0 ],
					[ "to", 0 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", "FALSE" ],
					[ "to", "FALSE" ],
					[ "change", "unchanged" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 0 ],
					[ "to", 0 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			]
		]
	],
	[
		"topology",
		[
			[
				"bottlenecks",
				[
					[ "from", [  ] ],
					[ "to", [  ] ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 3 ],
					[ "to", 3 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"isolatednodes",
				[
					[
						"from",
						[ "sales", "engineering", "marketing" ]
					],
					[
						"to",
						[ "sales", "engineering", "marketing" ]
					],
					[ "change", "unchanged" ]
				]
			]
		]
	],
	[
		"impact",
		[
			[ "reachabilitychanges", [  ] ],
			[ "criticalitychanges", [  ] ]
		]
	],
	[
		"explanation",
		[ "Modified 2 node propertie(s)" ]
	]
]
'

pf()
# Executed in 0.04 second(s) in Ring 1.24

#-----------------------#
#   BOTTLENECK CHANGES  #
#-----------------------#

/*--- Business scenario: Relieving bottleneck by adding cache layer

pr()

oBaseline = new stzGraph("api_architecture")
oBaseline {
	AddNode("client")
	AddNode("api")
	AddNode("db")
	AddNode("backup_db")
	
	Connect("client", "api")
	Connect("api", "db")
	Connect("api", "backup_db")
	Connect("db", "backup_db")
}

oVariation = oBaseline.Copy()
oVariation {
	# What if we add caching layer?
	AddNode("cache")
	
	# Reroute some connections through cache
	RemoveThisEdge("api", "db")
	Connect("api", "cache")
	Connect("cache", "db")
}

aDiff = oBaseline.CompareWith(oVariation)
? @@NL( aDiff )
#-->
'
[
	[
		"summary",
		[
			[ "nodesadded", 1 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 1 ],
			[ "edgesremoved", 2 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[
				"added",
				[ "cache" ]
			],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"edges",
		[
			[
				"added",
				[
					[
						[ "from", "api" ],
						[ "to", "db" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[
				"removed",
				[
					[
						[ "from", "api" ],
						[ "to", "cache" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "cache" ],
						[ "to", "db" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[
				"modified",
				[
					[
						[ "from", "client" ],
						[ "to", "api" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "api" ],
						[ "to", "backup_db" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "db" ],
						[ "to", "backup_db" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "api" ],
						[ "to", "cache" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "cache" ],
						[ "to", "db" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 4 ],
					[ "to", 5 ],
					[ "change", "+25%" ],
					[ "delta", 1 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 4 ],
					[ "to", 5 ],
					[ "change", "+25%" ],
					[ "delta", 1 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.33 ],
					[ "to", 0.25 ],
					[ "change", "-25.00%" ],
					[ "delta", -0.08 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 3 ],
					[ "to", 4 ],
					[ "change", "+33.33%" ],
					[ "delta", 1 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", "FALSE" ],
					[ "to", "FALSE" ],
					[ "change", "unchanged" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 2 ],
					[ "to", 2 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			]
		]
	],
	[
		"topology",
		[
			[
				"bottlenecks",
				[
					[
						"from",
						[ "api" ]
					],
					[
						"to",
						[ "api" ]
					],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 1 ],
					[ "to", 1 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"isolatednodes",
				[
					[ "from", [  ] ],
					[ "to", [  ] ],
					[ "change", "unchanged" ]
				]
			]
		]
	],
	[
		"impact",
		[
			[
				"reachabilitychanges",
				[
					[ "client", "Can now reach 1 more node(s)" ],
					[ "api", "Can now reach 1 more node(s)" ]
				]
			],
			[ "criticalitychanges", [  ] ]
		]
	],
	[
		"explanation",
		[
			"Added 1 node(s) and 1 edge(s)",
			"Removed 2 edge(s)",
			"Density -25.00%"
		]
	]
]
'

pf()
# Executed in 0.25 second(s) in Ring 1.24

#-----------------------#
#   CYCLE INTRODUCTION  #
#-----------------------#

/*--- Business scenario: Creating circular dependency (warning)

pr()

oBaseline = new stzGraph("workflow")
oBaseline {
	AddNode("Constraint")
	AddNode("develop")
	AddNode("test")
	AddNode("deploy")
	
	Connect("Constraint", "develop")
	Connect("develop", "test")
	Connect("test", "deploy")
}

oVariation = oBaseline.Copy()
oVariation {
	# What if we add feedback loop?
	Connect("deploy", "Constraint")  # Creates cycle!
}

aDiff = oBaseline.CompareWith(oVariation)
? @@NL( aDiff )
#-->
`
[
	[
		"summary",
		[
			[ "nodesadded", 0 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 0 ],
			[ "edgesremoved", 1 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[ "added", [  ] ],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"edges",
		[
			[ "added", [  ] ],
			[
				"removed",
				[
					[
						[ "from", "deploy" ],
						[ "to", "Constraint" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[ "modified", [  ] ]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 4 ],
					[ "to", 4 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 3 ],
					[ "to", 4 ],
					[ "change", "+33.33%" ],
					[ "delta", 1 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.25 ],
					[ "to", 0.33 ],
					[ "change", "+33.33%" ],
					[ "delta", 0.08 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 3 ],
					[ "to", 3 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", "FALSE" ],
					[ "to", "TRUE" ],
					[ "change", "now TRUE" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 1.50 ],
					[ "to", 2 ],
					[ "change", "+33.33%" ],
					[ "delta", 0.50 ]
				]
			]
		]
	],
	[
		"topology",
		[
			[
				"bottlenecks",
				[
					[
						"from",
						[ "develop", "test" ]
					],
					[ "to", [  ] ],
					[ "change", "reduced" ],
					[ "delta", -2 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 1 ],
					[ "to", 1 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"isolatednodes",
				[
					[ "from", [  ] ],
					[ "to", [  ] ],
					[ "change", "unchanged" ]
				]
			]
		]
	],
	[
		"impact",
		[
			[
				"reachabilitychanges",
				[
					[ "develop", "Can now reach 1 more node(s)" ],
					[ "test", "Can now reach 2 more node(s)" ],
					[ "deploy", "Can now reach 3 more node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[
						"Constraint",
						"Criticality increased (degree 1 → 2)"
					],
					[
						"deploy",
						"Criticality increased (degree 1 → 2)"
					]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Removed 1 edge(s)",
			"Density +33.33%",
			"Bottlenecks reduced (improvement)"
		]
	]
]
`

pf()
# Executed in 0.14 second(s) in Ring 1.24

#-----------------------#
#   COMPLEX SCENARIO    #
#-----------------------#

/*--- Business scenario: Organizational restructuring

pr()

oBaseline = new stzGraph("old_structure")
oBaseline {
	AddNodeXT("ceo", "CEO")
	AddNodeXT("vp_eng", "VP Engineering")
	AddNodeXT("vp_sales", "VP Sales")
	AddNodeXT("team_a", "Team A")
	AddNodeXT("team_b", "Team B")
	AddNodeXT("team_c", "Team C")
	
	Connect("ceo", "vp_eng")
	Connect("ceo", "vp_sales")
	Connect("vp_eng", "team_a")
	Connect("vp_eng", "team_b")
	Connect("vp_sales", "team_c")
	
	SetNodeProperty("vp_eng", "reports", 2)
	SetNodeProperty("vp_sales", "reports", 1)
}

oVariation = oBaseline.Copy()
oVariation {
	# Restructuring: add COO layer
	AddNodeXT("coo", "Chief Operating Officer")
	
	# Reroute reporting
	RemoveThisEdge("ceo", "vp_eng")
	RemoveThisEdge("ceo", "vp_sales")
	Connect("ceo", "coo")
	Connect("coo", "vp_eng")
	Connect("coo", "vp_sales")
	
	# Add new department
	AddNodeXT("vp_product", "VP Product")
	Connect("coo", "vp_product")
	
	# Update properties
	SetNodeProperty("vp_eng", "reports", 2)
	SetNodeProperty("vp_sales", "reports", 1)
	SetNodeProperty("vp_product", "reports", 0)
}

aDiff = oBaseline.CompareWith(oVariation)
? @@NL( aDiff )
#-->
`
[
	[
		"summary",
		[
			[ "nodesadded", 2 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 2 ],
			[ "edgesremoved", 4 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[
				"added",
				[ "coo", "vp_product" ]
			],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"edges",
		[
			[
				"added",
				[
					[
						[ "from", "ceo" ],
						[ "to", "vp_eng" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "vp_sales" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[
				"removed",
				[
					[
						[ "from", "ceo" ],
						[ "to", "coo" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_eng" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_sales" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_product" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[
				"modified",
				[
					[
						[ "from", "vp_eng" ],
						[ "to", "team_a" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "vp_eng" ],
						[ "to", "team_a" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "vp_eng" ],
						[ "to", "team_b" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "vp_eng" ],
						[ "to", "team_b" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "vp_sales" ],
						[ "to", "team_c" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "vp_sales" ],
						[ "to", "team_c" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "coo" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "coo" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_eng" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_eng" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_sales" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_sales" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_product" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_product" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 6 ],
					[ "to", 8 ],
					[ "change", "+33.33%" ],
					[ "delta", 2 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 5 ],
					[ "to", 7 ],
					[ "change", "+40%" ],
					[ "delta", 2 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.17 ],
					[ "to", 0.12 ],
					[ "change", "-25.00%" ],
					[ "delta", -0.04 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 5 ],
					[ "to", 7 ],
					[ "change", "+40%" ],
					[ "delta", 2 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", "FALSE" ],
					[ "to", "FALSE" ],
					[ "change", "unchanged" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 1.67 ],
					[ "to", 1.75 ],
					[ "change", "+5.00%" ],
					[ "delta", 0.08 ]
				]
			]
		]
	],
	[
		"topology",
		[
			[
				"bottlenecks",
				[
					[
						"from",
						[ "ceo", "vp_eng", "vp_sales" ]
					],
					[
						"to",
						[ "vp_eng", "vp_sales", "coo" ]
					],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 1 ],
					[ "to", 1 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"isolatednodes",
				[
					[ "from", [  ] ],
					[ "to", [  ] ],
					[ "change", "unchanged" ]
				]
			]
		]
	],
	[
		"impact",
		[
			[
				"reachabilitychanges",
				[
					[ "ceo", "Can now reach 2 more node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[
						"ceo",
						"Criticality decreased (degree 2 → 1)"
					],
					[ "coo", "New critical node (degree 4)" ]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Added 2 node(s) and 2 edge(s)",
			"Removed 4 edge(s)",
			"Density -25.00%"
		]
	]
]
`

pf()
# Executed in 0.47 second(s) in Ring 1.24

#------------------------#
#   GRAPH FRAGMENTATION  #
#------------------------#

/*--- Business scenario: Department becomes isolated

pr()

oBaseline = new stzGraph("connected_org")
oBaseline {
	AddNode("hq")
	AddNode("branch_a")
	AddNode("branch_b")
	AddNode("branch_c")
	
	Connect("hq", "branch_a")
	Connect("hq", "branch_b")
	Connect("hq", "branch_c")
	Connect("branch_a", "branch_b")
}

oVariation = oBaseline.Copy()
oVariation {
	# What if branch_c disconnects?
	RemoveThisEdge("hq", "branch_c")
}

aDiff = oBaseline.CompareWith(oVariation)
? @@NL( aDiff )
#-->
`
[
	[
		"summary",
		[
			[ "nodesadded", 0 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 1 ],
			[ "edgesremoved", 0 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[ "added", [  ] ],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"edges",
		[
			[
				"added",
				[
					[
						[ "from", "hq" ],
						[ "to", "branch_c" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[ "removed", [  ] ],
			[
				"modified",
				[
					[
						[ "from", "hq" ],
						[ "to", "branch_a" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "hq" ],
						[ "to", "branch_b" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "branch_a" ],
						[ "to", "branch_b" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 4 ],
					[ "to", 4 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 4 ],
					[ "to", 3 ],
					[ "change", "-25%" ],
					[ "delta", -1 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.33 ],
					[ "to", 0.25 ],
					[ "change", "-25.00%" ],
					[ "delta", -0.08 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 3 ],
					[ "to", 2 ],
					[ "change", "-33.33%" ],
					[ "delta", -1 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", "FALSE" ],
					[ "to", "FALSE" ],
					[ "change", "unchanged" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 2 ],
					[ "to", 1.50 ],
					[ "change", "-25%" ],
					[ "delta", -0.50 ]
				]
			]
		]
	],
	[
		"topology",
		[
			[
				"bottlenecks",
				[
					[
						"from",
						[ "hq" ]
					],
					[
						"to",
						[ "hq", "branch_a", "branch_b" ]
					],
					[ "change", "increased" ],
					[ "delta", 2 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 1 ],
					[ "to", 2 ],
					[ "change", "fragmented" ]
				]
			],
			[
				"isolatednodes",
				[
					[ "from", [  ] ],
					[
						"to",
						[ "branch_c" ]
					],
					[ "change", "increased" ]
				]
			]
		]
	],
	[
		"impact",
		[
			[
				"reachabilitychanges",
				[
					[ "hq", "Can now reach 1 fewer node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[ "hq", "Criticality decreased (degree 3 → 2)" ],
					[
						"branch_c",
						"Criticality decreased (degree 1 → 0)"
					]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Added 1 edge(s)",
			"Density -25.00%",
			"Bottlenecks increased",
			"Warning: Graph became fragmented"
		]
	]
]
`

pf()
# Executed in 0.17 second(s) in Ring 1.24

#-----------------------#
#   DENSITY COMPARISON  #
#-----------------------#

/*--- Business scenario: Comparing sparse vs dense structure

pr()

oSparse = new stzGraph("sparse_hierarchy")
oSparse {
	AddNode("top")
	AddNode("mid1")
	AddNode("mid2")
	AddNode("bot1")
	AddNode("bot2")
	
	Connect("top", "mid1")
	Connect("top", "mid2")
	Connect("mid1", "bot1")
	Connect("mid2", "bot2")
}

oDense = new stzGraph("dense_mesh")
oDense {
	AddNodes([ "top", "mid1", "mid2", "bot1", "bot2" ])
	
	# Fully connected
	Connect("top", "mid1")	#TODO // Add ConnectToMany("top", [ "mid1", ...])
	Connect("top", "mid2")
	Connect("top", "bot1")
	Connect("top", "bot2")

	Connect("mid1", "mid2")
	Connect("mid1", "bot1")
	Connect("mid1", "bot2")
	Connect("mid2", "bot1")

	Connect("mid2", "bot2")
	Connect("bot1", "bot2")
}

aDiff = oSparse.CompareWith(oDense)
? @@NL( aDiff )
#-->
`
[
	[
		"summary",
		[
			[ "nodesadded", 0 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 0 ],
			[ "edgesremoved", 6 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[ "added", [  ] ],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"edges",
		[
			[ "added", [  ] ],
			[
				"removed",
				[
					[
						[ "from", "top" ],
						[ "to", "bot1" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "top" ],
						[ "to", "bot2" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "mid1" ],
						[ "to", "mid2" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "mid1" ],
						[ "to", "bot2" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "mid2" ],
						[ "to", "bot1" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "bot1" ],
						[ "to", "bot2" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[ "modified", [  ] ]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 5 ],
					[ "to", 5 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 4 ],
					[ "to", 10 ],
					[ "change", "+150%" ],
					[ "delta", 6 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.20 ],
					[ "to", 0.50 ],
					[ "change", "+150.00%" ],
					[ "delta", 0.30 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 4 ],
					[ "to", 4 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", "FALSE" ],
					[ "to", "FALSE" ],
					[ "change", "unchanged" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 1.60 ],
					[ "to", 4 ],
					[ "change", "+150.00%" ],
					[ "delta", 2.40 ]
				]
			]
		]
	],
	[
		"topology",
		[
			[
				"bottlenecks",
				[
					[
						"from",
						[ "top", "mid1", "mid2" ]
					],
					[ "to", [  ] ],
					[ "change", "reduced" ],
					[ "delta", -3 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 1 ],
					[ "to", 1 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"isolatednodes",
				[
					[ "from", [  ] ],
					[ "to", [  ] ],
					[ "change", "unchanged" ]
				]
			]
		]
	],
	[
		"impact",
		[
			[
				"reachabilitychanges",
				[
					[ "mid1", "Can now reach 2 more node(s)" ],
					[ "mid2", "Can now reach 1 more node(s)" ],
					[ "bot1", "Can now reach 1 more node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[
						"top",
						"Criticality increased (degree 2 → 4)"
					],
					[
						"mid1",
						"Criticality increased (degree 2 → 4)"
					],
					[
						"mid2",
						"Criticality increased (degree 2 → 4)"
					],
					[
						"bot1",
						"Criticality increased (degree 1 → 4)"
					],
					[
						"bot2",
						"Criticality increased (degree 1 → 4)"
					]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Removed 6 edge(s)",
			"Density +150.00%",
			"Bottlenecks reduced (improvement)"
		]
	]
]
`

pf()
# Executed in 0.28 second(s) in Ring 1.24

#-----------------------#
#   QUICK COMPARISON    #
#-----------------------#

/*--- Using DiffWith() alias for brevity

pr()

oA = new stzGraph("simple")
oA {
	AddNode("x")
	AddNode("y")
	Connect("x", "y")
}

oB = oA.Copy()
oB.AddNode("z")
oB.Connect("y", "z")

aDiff = oA.DiffWith(oB)
? @@NL(aDiff)
#-->
`
[
	[
		"summary",
		[
			[ "nodesadded", 1 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 0 ],
			[ "edgesremoved", 1 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[
				"added",
				[ "z" ]
			],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"edges",
		[
			[ "added", [  ] ],
			[
				"removed",
				[
					[
						[ "from", "y" ],
						[ "to", "z" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[ "modified", [  ] ]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 2 ],
					[ "to", 3 ],
					[ "change", "+50%" ],
					[ "delta", 1 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 1 ],
					[ "to", 2 ],
					[ "change", "+100%" ],
					[ "delta", 1 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.50 ],
					[ "to", 0.33 ],
					[ "change", "-33.33%" ],
					[ "delta", -0.17 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 1 ],
					[ "to", 2 ],
					[ "change", "+100%" ],
					[ "delta", 1 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", "FALSE" ],
					[ "to", "FALSE" ],
					[ "change", "unchanged" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 1 ],
					[ "to", 1.33 ],
					[ "change", "+33.33%" ],
					[ "delta", 0.33 ]
				]
			]
		]
	],
	[
		"topology",
		[
			[
				"bottlenecks",
				[
					[ "from", [  ] ],
					[
						"to",
						[ "y" ]
					],
					[ "change", "increased" ],
					[ "delta", 1 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 1 ],
					[ "to", 1 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"isolatednodes",
				[
					[ "from", [  ] ],
					[ "to", [  ] ],
					[ "change", "unchanged" ]
				]
			]
		]
	],
	[
		"impact",
		[
			[
				"reachabilitychanges",
				[
					[ "x", "Can now reach 1 more node(s)" ],
					[ "y", "Can now reach 1 more node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[ "y", "Criticality increased (degree 1 → 2)" ]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Added 1 node(s)",
			"Removed 1 edge(s)",
			"Density -33.33%",
			"Bottlenecks increased"
		]
	]
]
`

pf()
# Executed in 0.12 second(s) in Ring 1.24

#============================================#
#  stzGraph Serialization Format Examples    #
#  Shows final output of each format         #
#============================================#

# SUMMARY OF FORMATS
#-------------------

# .stzgraf  - Graph structure (nodes/edges/properties)
# .stzrulz  - Rule definitions (properties)
# .stzrulf  - Rule functions (Ring code)
# .stzsim   - Simulations (change sets)

# Usage pattern:
#  1. Define graph → .stzgraf
#  2. Define custom functions → .stzrulf
#  3. Define rules → .stzrulz (references .stzrulf)
#  4. Apply changes → .stzsim

# Benefits:
# • Separation of data and logic"
# • Version control friendly"
# • Plugin-like extensibility"
# • Human-readable formats"

#---------------------------#
#  1. supply_chain.stzgraf  #
#    Pure graph structure   #
#===========================#

# EXAMPLE OF .stzgraf file content
#---------------------------------
`
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
        status: active

    warehouse_la
        capacity: 45000
        location: "Los Angeles"
        status: active

    factory_cn
        output: 100000
        location: Shenzhen
        cost_per_unit: 2.5

    factory_mx
        output: 75000
        location: Monterrey
        cost_per_unit: 3.2

    distributor_eu
        coverage: Europe
        demand: 75000
`

/*--- How to use .stzgraf file format?

pr()

# Loading graph from file

oGraph = new stzGraph("supply_chain")
oGraph {
	LoadFromStzGraf("txtfiles/supply_chain.stzgraf")

	? NodeCount() #--> 5
	? EdgeCount() #--> 5
	? @@(NodeProperty("warehouse_ny", "capacity")) #ERR
	#--> Should return 50000
	# but returned ""

//	View() #--> See the generated SVG image...

//	Show()
	`
	     ╭────────────╮      
	     │ factory_cn │      
	     ╰────────────╯      
	            |            
	            v            
	    ╭──────────────╮     
	    │ warehouse_ny │     
	    ╰──────────────╯     
	            |            
	            v            
	   ╭────────────────╮    
	   │ distributor_eu │    
	   ╰────────────────╯    
	
	          ////
	
	     ╭────────────╮  ↑	#ERR: returns "â†‘" "â”€â”€â•¯"
	     │ factory_cn │──╯
	     ╰────────────╯      
	            |            
	            v            
	   ╭────────────────╮    
	   │ !warehouse_la! │    
	   ╰────────────────╯    
	            |            
	            v            
	   ╭────────────────╮    
	   │ distributor_eu │    
	   ╰────────────────╯    
	
	          ////
	
	     ╭────────────╮      
	     │ factory_mx │      
	     ╰────────────╯      
	            |            
	            v            
	   ╭────────────────╮    
	   │ !warehouse_la! │    
	   ╰────────────────╯    
	            |            
	            v            
	   ╭────────────────╮    
	   │ distributor_eu │    
	   ╰────────────────╯  
	`
}

pf()
# Executed in 0.04 second(s) in Ring 1.24

#-------------------------------------------#
#  2. compliance_rules.stzrulz              #
#     Rule properties (links to functions)  #
#===========================================#

# EXAMPLE OF .stzrulz file content
#---------------------------------
`
ruleset "Banking Compliance Rules"
    domain: banking
    version: 1.0

rules

    rule no_cycles
        type: constraint
        severity: error
        function: ConstraintFunc_NoCycles
        message
            "Workflows must be acyclic"

    rule separation_of_duties
        type: constraint
        severity: error
        function: ConstraintFunc_Separation
        params
            property: department
            values: ["finance", "audit"]
        message
            "Finance and Audit must be separated"

    rule max_span
        type: constraint
        severity: warning
        function: ConstraintFunc_MaxDegree
        params
            max: 7
        message
            "Maximum 7 direct reports per manager"

    rule all_connected
        type: validation
        severity: error
        function: ValidationFunc_IsConnected
        message
            "All positions must be connected"

    rule inherit_permissions
        type: derivation
        severity: info
        function: DerivationFunc_Transitivity
        message
            "Permissions inherited through hierarchy"
`

/*--- How to use .stzrulz file format?

pr()

#TODO Review the file formats feature to cope with the
# new design of the rule system!

# Loading rules...
oGraph = new stzGraph("org")
oGraph.LoadFromStzRulz("txtfiles/bceao_banking.stzrulz")

? "Rules loaded: " + len(oGraph.RulesSummary()[:constraints])

pf()

#---------------------------------------#
#  3. custom_functions.stzrulf          #
#     Custom rule function definitions  #
#=======================================#

# Example of a .stzrulf file format
#----------------------------------
`
# Banking-specific custom functions
# This is pure Ring code that gets loaded

func CustomFunc_ManagerApproval()
	return func(oGraph, paRuleParams) {
		aNewEdges = []
		aNodes = oGraph.Nodes()
		
		for aNode in aNodes
			if oGraph.NodeProperty(aNode[:id], "role") = "manager"
				cManager = aNode[:id]
				aSubordinates = oGraph.Neighbors(cManager)
				
				for cSub in aSubordinates
					cApprovalNode = cSub + "_approval"
					if oGraph.NodeExists(cApprovalNode)
						if NOT oGraph.EdgeExists(cManager, cApprovalNode)
							aNewEdges + [cManager, cApprovalNode, "can_approve", []]
						ok
					ok
				next
			ok
		next
		
		return aNewEdges
	}

func CustomFunc_NoBackdating()
	return func(oGraph, paRuleParams, paOperationParams) {
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			cFrom = paOperationParams[:from]
			cTo = paOperationParams[:to]
			
			if oGraph.NodeExists(cFrom) and oGraph.NodeExists(cTo)
				dFromDate = oGraph.NodeProperty(cFrom, "date")
				dToDate = oGraph.NodeProperty(cTo, "date")
				
				if isString(dFromDate) and isString(dToDate)
					if dToDate < dFromDate
						return [TRUE, "Cannot backdate transactions"]
					ok
				ok
			ok
		ok
		return [FALSE, ""]
	}

func CustomFunc_BalancedTeams()
	return func(oGraph, paRuleParams) {
		nMinSize = paRuleParams[:minSize]
		nMaxSize = paRuleParams[:maxSize]
		
		aNodes = oGraph.Nodes()
		
		for aNode in aNodes
			if oGraph.NodeProperty(aNode[:id], "role") = "manager"
				nTeamSize = len(oGraph.Neighbors(aNode[:id]))
				
				if nTeamSize < nMinSize
					return [FALSE, "Team " + aNode[:id] + " too small (" + nTeamSize + ")"]
				but nTeamSize > nMaxSize
					return [FALSE, "Team " + aNode[:id] + " too large (" + nTeamSize + ")"]
				ok
			ok
		next
		
		return [TRUE, ""]
	}

# Register these as built-in style functions
RegisterRule(:banking, "manager_approval_rights", [
	:type = :derivation,
	:function = CustomFunc_ManagerApproval(),
	:params = [],
	:message = "Manager approval rights derived",
	:severity = :info
])

RegisterRule(:banking, "no_backdating", [
	:type = :constraint,
	:function = CustomFunc_NoBackdating(),
	:params = [],
	:message = "Backdating not allowed",
	:severity = :error
])

RegisterRule(:hr, "balanced_teams", [
	:type = :validation,
	:function = CustomFunc_BalancedTeams(),
	:params = [:minSize = 3, :maxSize = 8],
	:message = "Teams must be balanced",
	:severity = :warning
])
`

/*--- How to use .stzrulf file format?

pr()

# Loading custom functions
oGraph = new stzGraph("banking_system")

# Load the function definitions first
oGraph.LoadRuleFunctionsFrom("custom_functions.stzrulf")

# Then load the rules that reference them
oGraph.LoadFromStzRulz("compliance_rules.stzrulz")

# Now the custom functions are available
oGraph.UseRulesFrom(:banking)
oGraph.UseRulesFrom(:hr)

pf()

#-----------------------------------------#
#  4. restructure.stzsim                  #
#     Simulation (changes between graphs) #
#=========================================#

# Example of a .stzsim file format
`
simulation "Move Treasury Under CFO Comparison"
    description: "Changes from baseline"
    date: 2024-12-26

changes

    add node risk_officer
        label: "Risk Officer"

    add node compliance_officer
        label: "Compliance Officer"

    remove edge ceo -> treasury_head

    add edge cfo -> treasury_head
    add edge treasury_head -> risk_officer
    add edge treasury_head -> compliance_officer

metrics

    density: 0.25 -> 0.32
    nodeCount: 8 -> 10
    edgeCount: 7 -> 9
    hasCycles: FALSE -> FALSE
`

pr()

# How to use .stzsim file format?

# Loading baseline
oBaseline = new stzGraph("current_org")
oBaseline.LoadFromStzGraf("org_current.stzgraf")

# Applying simulation
cSimulation = read("restructure.stzsim")
oBaseline.ApplySimulation(cSimulation)

# After changes
? "  Nodes: " + oBaseline.NodeCount()
? "  Edges: " + oBaseline.EdgeCount()

pf()

#--------------------------------------------------#
# 5. Complete workflow example using file formats  #
#==================================================#

pr()

# Step 1: Create and save a graph

	oCompany = new stzGraph("MyCompany")
	oCompany {
		AddNodeXTT("ceo", "CEO", [:level = 5])
		AddNodeXTT("cto", "CTO", [:level = 4, :department = "tech"])
		AddNodeXTT("cfo", "CFO", [:level = 4, :department = "finance"])
		AddNodeXTT("eng1", "Engineer 1", [:level = 2, :department = "tech"])
		
		Connect("ceo", "cto")
		Connect("ceo", "cfo")
		Connect("cto", "eng1")
		
		? "Saving graph to supply_chain.stzgraf..."
		SaveToStzGraf("mycompany.stzgraf")
	}

# Step 2: Load custom functions

	load "custom_functions.stzrulf"

# Step 3: Load rules

	oCompany.LoadFromStzRulz("compliance_rules.stzrulz")

# Step 4: Apply rules

	oCompany.UseRulesFrom(:banking)
	nDerived = oCompany.ApplyDerivations()
	? "  Derived edges: " + nDerived

# Step 5: Create variation

	oVariation = oCompany.Copy()
	oVariation {
		AddNodeXTT("coo", "COO", [:level = 4])
		RemoveThisEdge("ceo", "cto")
		Connect("ceo", "coo")
		Connect("coo", "cto")
	}

# Step 6: Export simulation

	cSim = oVariation.ExportToStzSim(oCompany)
	write("add_coo.stzsim", cSim)
	? "  Saved to add_coo.stzsim"
	
	# Step 7: Validate
	? "Validating structure..."
	aResult = oVariation.Validate()
	? "  Valid: " + aResult[1]

pf()

#==================#
#  RAISING ERRORS  #
#==================#

pr()

oReseau = new stzGraph("Trounées Niamey")
#--> ERROR MESSAGE: Inncorrect Id! pcId must be a string without spaces nor new lines.

pf()
