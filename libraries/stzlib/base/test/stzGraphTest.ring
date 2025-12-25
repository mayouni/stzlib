
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

#============================================#
#  SECTION 8: EXPLAIN FEATURE
#============================================#

/*--- Graph Explanation

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

*--- Path Explanation

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

#============================================#
#  Complete Format Suite Examples            #
#  All 6 formats working together            #
#============================================#

#TODO

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

#==================================#
#  RULES MANAGEMENT TEST SECTION   #
#==================================#

/*--- DERIVATION RULES

pr()

? BoxRound("DERIVATION RULES - FUNCTION BASED") + NL

# Register derivation rules using built-in functions
RegisterRule(:workflow, "transitive_access", [
	:type = :derivation,
	:function = DerivationFunc_Transitivity(),
	:message = "Access inherited transitively",
	:severity = :info
])

RegisterRule(:security, "symmetric_trust", [
	:type = :derivation,
	:function = DerivationFunc_Symmetry(),
	:message = "Trust is bidirectional",
	:severity = :info
])

# Custom derivation function
RegisterRule(:business, "manager_approval", [
	:type = :derivation,
	:function = func(oGraph) {
		# Managers can approve all subordinate requests
		aNewEdges = []
		aNodes = oGraph.Nodes()
		nLen = len(aNodes)
		
		for i = 1 to nLen
			aNode = aNodes[i]
			if oGraph.NodeProperty(aNode[:id], "role") = "manager"
				cManager = aNode[:id]
				aSubordinates = oGraph.Neighbors(cManager)
				
				nSubLen = len(aSubordinates)
				for j = 1 to nSubLen
					cSub = aSubordinates[j]
					# Manager can approve subordinate's work
					if NOT oGraph.EdgeExists(cSub, cManager + "_approval")
						aNewEdges + [cSub, cManager + "_approval", "(can-approve)", [:type = "approval"]]
					ok
				next
			ok
		next
		
		return aNewEdges
	},
	:message = "Manager approval rights derived",
	:severity = :info
])

# Use the rules
oGraph = new stzGraph("DerivationTest")
oGraph {
	AddNodeXTT("alice", "Alice", [:role = "manager"])
	AddNodeXTT("bob", "Bob", [:role = "developer"])
	AddNodeXTT("resource", "Database", [:type = "resource"])
	
	Connect("alice", "bob")
	Connect("bob", "resource")
	
	? "Before derivation:"
	? "  Edges: " + EdgeCount() + NL
	
	UseRulesFrom(:workflow)
	nDerived = ApplyDerivations()
	
	? "After derivation:"
	? "  Edges: " + EdgeCount()
	? "  Derived: " + nDerived + NL
	
	? "Alice can reach resource: " + PathExists("alice", "resource")
	? @@( "  Path: " + @@(Path("alice", "resource")) ) + NL
	
	Show()
}
#-->
`
╭───────────────────────────────────╮
│ DERIVATION RULES - FUNCTION BASED │
╰───────────────────────────────────╯

Before derivation:
  Edges: 2

After derivation:
  Edges: 3
  Derived: 1

Alice can reach resource: 1
'  Path: [ "alice", "bob", "resource" ]'

        ╭───────╮        
        │ Alice │        
        ╰───────╯        
            |            
            v            
         ╭─────╮         
         │ Bob │         
         ╰─────╯         
            |            
            v            
      ╭──────────╮       
      │ Database │       
      ╰──────────╯       

          ////

        ╭───────╮  ↑
        │ Alice │──╯
        ╰───────╯        
            |            
      (transitive)       
            |            
            v            
      ╭──────────╮       
      │ Database │       
      ╰──────────╯   
`

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*--- CONSTRAINT RULES

pr()

? BoxRound("CONSTRAINT RULES - FUNCTION BASED") + NL

# Register constraints using built-in functions
RegisterRule(:compliance, "no_self_loops", [
	:type = :constraint,
	:function = ConstraintFunc_NoSelfLoop(),
	:params = [],  # Add this
	:message = "Self-approval not allowed",
	:severity = :error
])

RegisterRule(:compliance, "max_reports", [
	:type = :constraint,
	:function = ConstraintFunc_MaxDegree(),
	:params = [:max = 5],  # Move param here
	:message = "Max 5 direct reports",
	:severity = :warning
])

RegisterRule(:security, "sep_finance_audit", [
	:type = :constraint,
	:function = ConstraintFunc_Separation(),
	:params = [:property = "department", :values = ["finance", "audit"]],  # Move params here
	:message = "Finance and Audit must be separated",
	:severity = :error
])

# Custom constraint function
RegisterRule(:business, "approval_hierarchy", [
	:type = :constraint,
	:function = func(oGraph, paRuleParams, paOperationParams) {  # Add paRuleParams
		# Lower level cannot approve higher level
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			cFrom = paOperationParams[:from]
			cTo = paOperationParams[:to]
			# ... rest of code
		ok
		return [FALSE, ""]
	},
	:params = [],
	:message = "Approval hierarchy violated",
	:severity = :error
])

# Use constraints
oGraph = new stzGraph("ConstraintTest")
oGraph {
	AddNodeXTT("john", "John", [:department = "finance", :level = 2])
	AddNodeXTT("mary", "Mary", [:department = "audit", :level = 2])
	AddNodeXTT("peter", "Peter", [:department = "engineering", :level = 1])
	
	UseRulesFrom(:compliance)
	UseRulesFrom(:security)
	UseRulesFrom(:business)
	
	? "Testing constraints..." + NL
	
	# Test 1: Self-loop
	aResult = CheckConstraints([:from = "john", :to = "john"])
	? "1. Self-loop allowed: " + iff(aResult[1] = 1, "TRUE", "FALSE")
	if NOT aResult[1]
		? "   Blocked: " + aResult[2][1][:message]
	ok
	? ""
	
	# Test 2: Separation of duties
	Connect("john", "peter")
	Connect("mary", "peter")
	
	aResult = CheckConstraints([:from = "john", :to = "mary"])
	? "2. Finance-Audit connection allowed: " + iff(aResult[1] = 1, "TRUE", "FALSE")
	if NOT aResult[1]
		? "   Blocked: " + aResult[2][1][:message]
		? "   Severity: " + aResult[2][1][:severity]
	ok
	? ""
	
	# Test 3: Approval hierarchy
	aResult = CheckConstraints([:from = "peter", :to = "john"])
	? "3. Junior approving senior allowed: " + iff(aResult[1] = 1, "TRUE", "FALSE")
	if NOT aResult[1]
		? "   Blocked: " + aResult[2][1][:message]
	ok
}
#-->
'
╭───────────────────────────────────╮
│ CONSTRAINT RULES - FUNCTION BASED │
╰───────────────────────────────────╯

Testing constraints...

1. Self-loop allowed: FALSE
   Blocked: Self-loops not allowed		# John cannot connect to himself

2. Finance-Audit connection allowed: FALSE	# Finance (John) and Audit (Mary) cannot connect
   Blocked: Separation of duties violation
   Severity: error

3. Junior approving senior allowed: TRUE
# Peter (level 1) CAN approve John (level 2) because the rule blocks same-or-lower, not higher levels

'

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- VALIDATION RULES

pr()

? BoxRound("VALIDATION RULES - FUNCTION BASED") + NL

# Register validations using built-in functions
RegisterRule(:workflow, "must_be_dag", [
	:type = :validation,
	:function = ValidationFunc_IsAcyclic(),
	:params = [],  # Add this
	:message = "Workflow must be acyclic",
	:severity = :error
])

RegisterRule(:workflow, "all_connected", [
	:type = :validation,
	:function = ValidationFunc_IsConnected(),
	:params = [],  # Add this
	:message = "All nodes must be connected",
	:severity = :warning
])

RegisterRule(:optimization, "density_check", [
	:type = :validation,
	:function = ValidationFunc_DensityRange(),
	:params = [:min = 0.2, :max = 0.7],  # Move params here
	:message = "Density should be 20-70%",
	:severity = :info
])

# Custom validation function
RegisterRule(:business, "single_entry_point", [
	:type = :validation,
	:function = func(oGraph, paRuleParams) {  # Add paRuleParams parameter
		# Graph must have exactly one node with no incoming edges (entry point)
		nEntryPoints = 0
		aNodes = oGraph.Nodes()
		nLen = len(aNodes)
		
		for i = 1 to nLen
			aNode = aNodes[i]
			if len(oGraph.Incoming(aNode[:id])) = 0
				nEntryPoints++
			ok
		next
		
		if nEntryPoints != 1
			return [FALSE, "Must have exactly one entry point (found " + nEntryPoints + ")"]
		ok
		return [TRUE, ""]
	},
	:params = [],  # Add this
	:message = "Single entry point required",
	:severity = :error
])

# Use validations
oGraph = new stzGraph("ValidationTest")
oGraph {
	AddNode("start")
	AddNode("process")
	AddNode("end")
	
	Connect("start", "process")
	Connect("process", "end")
	
	UseRulesFrom(:workflow)
	UseRulesFrom(:optimization)
	UseRulesFrom(:business)
	
	? "Validating graph..." + NL
	
	aResult = ValidateGraph()
	? "Graph valid: " + iff(aResult[1] = 1, "TRUE", "FALSE")
	
	if NOT aResult[1]
		? "Violations found:"
		nLen = len(aResult[2])
		for i = 1 to nLen
			aViolation = aResult[2][i]
			? "  - " + aViolation[:rule]
			? "    " + aViolation[:message]
			? "    Severity: " + aViolation[:severity]
			? ""
		next
	else
		? "All validations passed!" + NL
	ok
	
	# Add a cycle
	? "Adding cycle..." + NL
	Connect("end", "start")
	
	aResult = ValidateGraph()
	? "Graph valid: " + iff(aResult[1] = 1, "TRUE", "FALSE" ) + NL
	
	if NOT aResult[1]
		nLen = len(aResult[2])
		for i = 1 to nLen
			aViolation = aResult[2][i]
			? "  - " + aViolation[:rule] + ": " + aViolation[:message]
		next
	ok
	
	? ""
	Show() #ERR
}
#-->
'
╭───────────────────────────────────╮
│ VALIDATION RULES - FUNCTION BASED │
╰───────────────────────────────────╯

Validating graph...

Graph valid: TRUE
All validations passed!

Adding cycle...

Graph valid: FALSE

  - must_be_dag: Graph contains cycles
  - single_entry_point: Must have exactly one entry point (found 0)
'

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*------------- VALIDATION RULES

pr()

? BoxRound("VALIDATION RULES - FUNCTION BASED") + NL

# Register validations using built-in functions
RegisterRule(:workflow, "must_be_dag", [
	:type = :validation,
	:function = ValidationFunc_IsAcyclic(),
	:params = [],  # Add this
	:message = "Workflow must be acyclic",
	:severity = :error
])

RegisterRule(:workflow, "all_connected", [
	:type = :validation,
	:function = ValidationFunc_IsConnected(),
	:params = [],  # Add this
	:message = "All nodes must be connected",
	:severity = :warning
])

RegisterRule(:optimization, "density_check", [
	:type = :validation,
	:function = ValidationFunc_DensityRange(),
	:params = [:min = 0.2, :max = 0.7],  # Move params here
	:message = "Density should be 20-70%",
	:severity = :info
])

# Custom validation function
RegisterRule(:business, "single_entry_point", [
	:type = :validation,
	:function = func(oGraph, paRuleParams) {  # Add paRuleParams parameter
		# Graph must have exactly one node with no incoming edges (entry point)
		nEntryPoints = 0
		aNodes = oGraph.Nodes()
		nLen = len(aNodes)
		
		for i = 1 to nLen
			aNode = aNodes[i]
			if len(oGraph.Incoming(aNode[:id])) = 0
				nEntryPoints++
			ok
		next
		
		if nEntryPoints != 1
			return [FALSE, "Must have exactly one entry point (found " + nEntryPoints + ")"]
		ok
		return [TRUE, ""]
	},
	:params = [],  # Add this
	:message = "Single entry point required",
	:severity = :error
])

# Use validations
oGraph = new stzGraph("ValidationTest")
oGraph {
	AddNode("start")
	AddNode("process")
	AddNode("end")
	
	Connect("start", "process")
	Connect("process", "end")
	
	UseRulesFrom(:workflow)
	UseRulesFrom(:optimization)
	UseRulesFrom(:business)
	
	? "Validating graph..." + NL
	
	aResult = ValidateGraph()
	? "Graph valid: " + iff(aResult[1] = 1, "TRUE", "FALSE")
	
	if NOT aResult[1]
		? "Violations found:"
		nLen = len(aResult[2])
		for i = 1 to nLen
			aViolation = aResult[2][i]
			? "  - " + aViolation[:rule]
			? "    " + aViolation[:message]
			? "    Severity: " + aViolation[:severity]
			? ""
		next
	else
		? "All validations passed!" + NL
	ok
	
	# Add a cycle
	? "Adding cycle..." + NL
	Connect("end", "start")
	
	aResult = ValidateGraph()
	? "Graph valid: " + iff(aResult[1] = 1, "TRUE", "FALSE" ) + NL
	
	if NOT aResult[1]
		nLen = len(aResult[2])
		for i = 1 to nLen
			aViolation = aResult[2][i]
			? "  - " + aViolation[:rule] + ": " + aViolation[:message]
		next
	ok
	
	? ""
	View()
	// Show() #ERR #TODO fix the error when the graph has cyclic call
}
#-->
'
Validating graph...

Graph valid: TRUE
All validations passed!

Adding cycle...

Graph valid: FALSE

  - must_be_dag: Graph contains cycles
  - single_entry_point: Must have exactly one entry point (found 0)
'

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*------------- CUSTOM RULES - UNLIMITED FLEXIBILITY

pr()

? BoxRound("CUSTOM RULES - PROJECT MANAGEMENT") + NL

# 1. Derivation: Auto-add test tasks for features
RegisterRule(:project, "auto_testing", [
	:type = :derivation,
	:function = func(oGraph, paRuleParams) {
		aNewEdges = []
		aNodes = oGraph.Nodes()
		nLen = len(aNodes)
		
		for i = 1 to nLen
			aNode = aNodes[i]
			if oGraph.NodeProperty(aNode[:id], "type") = "feature"
				cFeature = aNode[:id]
				cTestNode = cFeature + "_test"
				
				# Add test node if doesn't exist
				if NOT oGraph.NodeExists(cTestNode)
					oGraph.AddNodeXTT(cTestNode, "Test: " + aNode[:label], [:type = "test"])
				ok
				
				# Feature must be done before test
				if NOT oGraph.EdgeExists(cFeature, cTestNode)
					aNewEdges + [cFeature, cTestNode, "(test-after)", [:auto = TRUE]]
				ok
			ok
		next
		
		return aNewEdges
	},
	:params = [],
	:message = "Auto-generated test tasks",
	:severity = :info
])

# 2. Constraint: Features can't depend on tests
RegisterRule(:project, "no_test_deps", [
	:type = :constraint,
	:function = func(oGraph, paRuleParams, paOperationParams) {
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			cFrom = paOperationParams[:from]
			cTo = paOperationParams[:to]
			
			if oGraph.NodeExists(cFrom) and oGraph.NodeExists(cTo)
				cFromType = oGraph.NodeProperty(cFrom, "type")
				cToType = oGraph.NodeProperty(cTo, "type")
				
				if cFromType = "feature" and cToType = "test"
					return [TRUE, "Features cannot depend on tests"]
				ok
			ok
		ok
		return [FALSE, ""]
	},
	:params = [],
	:message = "Invalid feature->test dependency",
	:severity = :error
])

# 3. Validation: All features must have tests
RegisterRule(:project, "complete_testing", [
	:type = :validation,
	:function = func(oGraph, paRuleParams) {
		aNodes = oGraph.Nodes()
		nLen = len(aNodes)
		nFeatures = 0
		nTests = 0
		
		for i = 1 to nLen
			aNode = aNodes[i]
			cType = oGraph.NodeProperty(aNode[:id], "type")
			if cType = "feature"
				nFeatures++
			but cType = "test"
				nTests++
			ok
		next
		
		if nTests < nFeatures
			return [FALSE, "Not all features have tests (" + nTests + "/" + nFeatures + ")"]
		ok
		return [TRUE, ""]
	},
	:params = [],
	:message = "Incomplete test coverage",
	:severity = :warning
])

# Use all custom rules
oGraph = new stzGraph("ProjectPlan")
oGraph {
	AddNodeXTT("login", "Login Feature", [:type = "feature", :priority = 1])
	AddNodeXTT("dashboard", "Dashboard Feature", [:type = "feature", :priority = 2])
	AddNodeXTT("reports", "Reports Feature", [:type = "feature", :priority = 3])
	
	Connect("login", "dashboard")
	Connect("dashboard", "reports")
	
	UseRulesFrom(:project)
	
	? "Initial project:"
	? "  Features: 3"
	? "  Tests: 0" + NL
	
	? "Applying derivation rules..."
	nDerived = ApplyDerivations()
	? "  Generated: " + nDerived + " test tasks" + NL
	
	? "Final project:"
	? "  Total nodes: " + NodeCount()
	? "  Total edges: " + EdgeCount() + NL
	
	? "Validating project..."
	aResult = ValidateGraph()
	? "  Valid: " + iff(aResult[1] = 1, "TRUE", "FALSE")
	
	if NOT aResult[1]
		? "  Issues:"
		nLen = len(aResult[2])
		for i = 1 to nLen
			? "    - " + aResult[2][i][:message]
		next
	ok
	? ""
	
	? @@NL( RulesSummary() )
	
	Show()
}
#-->
`
╭───────────────────────────────────╮
│ CUSTOM RULES - PROJECT MANAGEMENT │
╰───────────────────────────────────╯

Initial project:
  Features: 3
  Tests: 0

Applying derivation rules...
  Generated: 3 test tasks

Final project:
  Total nodes: 6
  Total edges: 5

Validating project...
  Valid: TRUE

[
	[
		"derivations",
		[ "auto_testing" ]
	],
	[
		"constraints",
		[ "no_test_deps" ]
	],
	[
		"validations",
		[ "complete_testing" ]
	],
	[
		"applied",
		[ "auto_testing" ]
	],
	[ "violations", [  ] ]
]
   ╭─────────────────╮   
   │ !Login Feature! │   
   ╰─────────────────╯   
            |            
            v            
 ╭─────────────────────╮ 
 │ !Dashboard Feature! │ 
 ╰─────────────────────╯ 
            |            
            v            
  ╭───────────────────╮  
  │ !Reports Feature! │  
  ╰───────────────────╯  
            |            
      (test-after)       
            |            
            v            
╭───────────────────────╮
│ Test: Reports Feature │
╰───────────────────────╯

          ////

 ╭─────────────────────╮  ↑
 │ !Dashboard Feature! │──╯
 ╰─────────────────────╯ 
            |            
      (test-after)       
            |            
            v            
╭─────────────────────────╮
│ Test: Dashboard Feature │
╰─────────────────────────╯

          ////

   ╭─────────────────╮  ↑
   │ !Login Feature! │──╯
   ╰─────────────────╯   
            |            
      (test-after)       
            |            
            v            
 ╭─────────────────────╮ 
 │ Test: Login Feature │ 
 ╰─────────────────────╯ 
`

pf()
# Executed in 0.08 second(s) in Ring 1.24

/*------------- REAL-WORLD: ACCESS CONTROL

pr()

? BoxRound("REAL-WORLD: ACCESS CONTROL SYSTEM") + NL

# Complete access control with function-based rules

RegisterRule(:access, "inherit_permissions", [
	:type = :derivation,
	:function = DerivationFunc_Transitivity(),
	:params = [],
	:message = "Permissions inherited",
	:severity = :info
])

RegisterRule(:access, "no_privilege_escalation", [
	:type = :constraint,
	:function = func(oGraph, paRuleParams, paOperationParams) {
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :to)
			cFrom = paOperationParams[:from]
			cTo = paOperationParams[:to]
			
			if oGraph.NodeExists(cFrom) and oGraph.NodeExists(cTo)
				cFromType = oGraph.NodeProperty(cFrom, "type")
				cToType = oGraph.NodeProperty(cTo, "type")
				nFromLevel = oGraph.NodeProperty(cFrom, "security_level")
				nToLevel = oGraph.NodeProperty(cTo, "security_level")
				
				if cFromType = "user" and cToType = "resource"
					if isNumber(nFromLevel) and isNumber(nToLevel)
						if nFromLevel < nToLevel
							return [TRUE, "Insufficient security clearance"]
						ok
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

RegisterRule(:access, "audit_compliance", [
	:type = :validation,
	:function = func(oGraph, paRuleParams) {
		# All sensitive resources must have audit trail
		aNodes = oGraph.Nodes()
		nLen = len(aNodes)
		nSensitive = 0
		nAudited = 0
		
		for i = 1 to nLen
			aNode = aNodes[i]
			if oGraph.NodeProperty(aNode[:id], "sensitive") = TRUE
				nSensitive++
				if oGraph.NodeProperty(aNode[:id], "audited") = TRUE
					nAudited++
				ok
			ok
		next
		
		if nAudited < nSensitive
			return [FALSE, "Not all sensitive resources audited (" + nAudited + "/" + nSensitive + ")"]
		ok
		return [TRUE, ""]
	},
	:params = [],
	:message = "Audit compliance check",
	:severity = :error
])

oGraph = new stzGraph("EnterpriseAccess")
oGraph {
	# Users
	AddNodeXTT("alice", "Alice (Admin)", [:type = "user", :security_level = 3])
	AddNodeXTT("bob", "Bob (Manager)", [:type = "user", :security_level = 2])
	AddNodeXTT("charlie", "Charlie (Staff)", [:type = "user", :security_level = 1])
	
	# Groups
	AddNodeXTT("admins", "Administrators", [:type = "group"])
	AddNodeXTT("managers", "Managers", [:type = "group"])
	
	# Resources
	AddNodeXTT("db_prod", "Production DB", [:type = "resource", :security_level = 3, :sensitive = TRUE, :audited = TRUE])
	AddNodeXTT("db_dev", "Development DB", [:type = "resource", :security_level = 1, :sensitive = FALSE, :audited = FALSE])
	
	UseRulesFrom(:access)
	
	? "Setting up access control..."
	Connect("alice", "admins")
	Connect("bob", "managers")
	Connect("admins", "db_prod")
	Connect("managers", "db_dev")
	Connect("charlie", "managers")
	
	? "  Direct relationships: " + EdgeCount() + NL
	
	? "Deriving transitive access..."
	nDerived = ApplyDerivations()
	? "  Derived: " + nDerived
	? "  Total: " + EdgeCount() + NL
	
	? "Access check:"
	? "  Alice -> db_prod: " + PathExists("alice", "db_prod")
	? "  Bob -> db_dev: " + PathExists("bob", "db_dev")
	? "  Charlie -> db_dev: " + PathExists("charlie", "db_dev")
	? "  Charlie -> db_prod: " + PathExists("charlie", "db_prod")
	? ""
	
	? "Testing privilege escalation..."
	aResult = CheckConstraints([:from = "charlie", :to = "db_prod"])
	? "  Charlie can access prod: " + aResult[1]
	if NOT aResult[1]
		? "  Blocked: " + aResult[2][1][:message]
	ok
	? ""
	
	? "Compliance validation..."
	aResult = ValidateGraph()
	? "  Compliant: " + aResult[1]
	if NOT aResult[1]
		nLen = len(aResult[2])
		for i = 1 to nLen
			? "  Issue: " + aResult[2][i][:message]
		next
	ok
	
	? ""
	ShowH() # For ascii-based visualisation
//	View() # For sophisticated graphiz-based visualisation
}
#-->
'
╭───────────────────────────────────╮
│ REAL-WORLD: ACCESS CONTROL SYSTEM │
╰───────────────────────────────────╯

Setting up access control...
  Direct relationships: 5

Deriving transitive access...
  Derived: 3
  Total: 8

Access check:
  Alice -> db_prod: 1
  Bob -> db_dev: 1
  Charlie -> db_dev: 1
  Charlie -> db_prod: 0

Testing privilege escalation...
  Charlie can access prod: 0
  Blocked: Insufficient security clearance

Compliance validation...
  Compliant: 1

╭───────────────╮     ╭────────────────╮     ╭───────────────╮
│ Alice (Admin) │---->│ Administrators │---->│ Production DB │
╰───────────────╯     ╰────────────────╯     ╰───────────────╯
╭───────────────╮     ╭────────────╮     ╭──────────────────╮
│ Bob (Manager) │---->│ !Managers! │---->│ !Development DB! │
╰───────────────╯     ╰────────────╯     ╰──────────────────╯
╭─────────────────╮     ╭────────────╮     ╭──────────────────╮
│ Charlie (Staff) │---->│ !Managers! │---->│ !Development DB! │
╰─────────────────╯     ╰────────────╯ 
'

pf()
# Executed in 0.08 second(s) in Ring 1.24

#============================================#
#  PRACTICAL USE CASE: Graph Type Controls   #
#  Behavior and Validation                   #
#============================================#

/*--- STRUCTURAL graphs forbid cycles (org charts, taxonomies)

pr()

o1 = new stzGraph("company_org")
o1.SetGraphType("structural")

o1.AddNode("ceo")
o1.AddNode("cto") 
o1.AddNode("dev")

o1.Connect("ceo", "cto")
o1.Connect("cto", "dev")

# This should work
? o1.GraphType() #--> "structural"
? o1.CyclesAllowed() #--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- FLOW graphs allow cycles (workflows, state machines)

pr()

o1 = new stzGraph("approval_flow")
o1.SetGraphType("flow")

o1.AddNodes([ "draft", "review", "approved" ])

o1.Connect("draft", "review")
o1.Connect("review", "approved")
o1.Connect("review", "draft")  # rejection loop

? o1.GraphType()
? o1.CyclesAllowed() #--> TRUE
? o1.HasCyclicDependencies() #--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- SEMANTIC graphs track meaning relationships

pr()

o1 = new stzGraph("knowledge")
o1 {
	SetGraphType("semantic")

	AddNode("cat")
	AddNode("mammal")
	AddNode("animal")

	AddEdgeXT("cat", "mammal", "is_a")
	AddEdgeXT("mammal", "animal", "is_a")

	# Auto-apply transitivity rule for semantic graphs
	if ShouldAutoDerive()
		UseDefaultDerivations()
		nAdded = ApplyDerivations()
		? "Semantic graph auto-derived " + nAdded + " edges"
	ok

	# Cat→Animal edge exists?
	? EdgeExists("cat", "animal")
	#--> TRUE
}

pf()

/*--- Type-aware validation

o4 = new stzGraph("mixed_test")
o4.SetGraphType("structural")

o4.AddNode("a")
o4.AddNode("b")
o4.Connect("a", "b")
o4.Connect("b", "a")  # Creates cycle

aResult = o4.ValidateGraph()
? nl + "Structural graph with cycle validation:"
? "Valid? " + aResult[1]  # → FALSE
if len(aResult[2]) > 0
    ? "Violation: " + aResult[2][1][:message]  # "Cycles not allowed in structural graphs"
ok


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
# Executed in 0.02 second(s) in Ring 1.24

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
	AddNode("design")
	AddNode("develop")
	AddNode("test")
	AddNode("deploy")
	
	Connect("design", "develop")
	Connect("develop", "test")
	Connect("test", "deploy")
}

oVariation = oBaseline.Copy()
oVariation {
	# What if we add feedback loop?
	Connect("deploy", "design")  # Creates cycle!
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
						[ "to", "design" ],
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
						"design",
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
	AddNode("top")
	AddNode("mid1")
	AddNode("mid2")
	AddNode("bot1")
	AddNode("bot2")
	
	# Fully connected
	Connect("top", "mid1")
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
*/
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
