load "../stzbase.ring"

oGraph = new stzGraph("BottleneckTest")
oGraph {
    AddNode(:@a, "A")
    AddNode(:@b, "B")
    AddNode(:@c, "C")
    AddNode(:@hub, "Hub")
    
    AddEdge(:@a, :@hub, "")
    AddEdge(:@b, :@hub, "")
    AddEdge(:@c, :@hub, "")
    AddEdge(:@hub, :@a, "")
    
    ShowWithLegend()
}

pf()
#  stzGraphTest - Test Suite

/*--- Creating a simple 3-node linear graph

pr()

oGraph = new stzGraph("SimpleGraph")
oGraph {
	AddNode(:@1, "Node 1")
	AddNode(:@2, "Node 2")
	AddNode(:@3, "Node 3")

	AddEdge(:@1, :@2, "connects")
	AddEdge(:@2, :@3, "flows")

	? NodeCount() #--> 3
	? EdgeCount() #--> 2
}

pf()
# Executed in almost 0 second(s) in Ring 1.24


/*--- Testing path existence between nodes

pr()

oGraph = new stzGraph("PathTest")

oGraph.AddNode(:@start, "Start")
oGraph.AddNode(:@middle, "Middle")
oGraph.AddNode(:@end, "End")
oGraph.AddNode(:@isolated, "Isolated")

oGraph.AddEdge(:@start, :@middle, "")
oGraph.AddEdge(:@middle, :@end, "")

? oGraph.PathExists(:@start, :@end) 		#--> TRUE
? oGraph.PathExists(:@start, :@isolated) 	#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Finding all nodes reachable from a given node

pr()


oGraph = new stzGraph("ReachabilityTest")

oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")
oGraph.AddNode(:@3, "C")
oGraph.AddNode(:@4, "D")

oGraph.AddEdge(:@1, :@2, "")
oGraph.AddEdge(:@2, :@3, "")
oGraph.AddEdge(:@1, :@4, "")

aReachable = oGraph.ReachableFrom(:@1)
? len(aReachable) #--> 4

pf()

/*--- Enumerating all routes in diamond graph

pr()

oGraph = new stzGraph("AllPathsTest")

oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")
oGraph.AddNode(:@3, "C")
oGraph.AddNode(:@4, "D")

oGraph.AddEdge(:@1, :@2, "")
oGraph.AddEdge(:@1, :@3, "")
oGraph.AddEdge(:@2, :@4, "")
oGraph.AddEdge(:@3, :@4, "")

aAllPaths = oGraph.FindAllPaths(:@1, :@4)
? len(aAllPaths) #--> 2

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Verifying a valid DAG

pr()

oGraph = new stzGraph("AcyclicTest")
oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")
oGraph.AddNode(:@3, "C")

oGraph.AddEdge(:@4, :@2, "")
oGraph.AddEdge(:@5, :@3, "")

? oGraph.CyclicDependencies() #--> FALSE

pf()

#-----------------#
#  TEST 6: CYCLIC GRAPH DETECTION
#-----------------#

/*--- Identifying cycles in graph

pr()

oGraph = new stzGraph("CyclicTest")

oGraph.AddNode(:@1, "P1")
oGraph.AddNode(:@2, "P2")
oGraph.AddNode(:@3, "P3")

oGraph.AddEdge(:@1, :@2, "")
oGraph.AddEdge(:@1, :@2, "")
oGraph.AddEdge(:@3, :@1, "")

? oGraph.CyclicDependencies() #--> TRUE
oGraph.ShowWithLegend()

? NL + BoxRound("Explanation")
? @@NL( oGraph.Explain() )
#-->
'
         ╭────╮          
         │ P3 │          
         ╰────╯          
            |            
            v            
        ╭──────╮         
        │ !P1! │         
        ╰──────╯         
            |            
            v            
         ╭────╮          
         │ P2 │          
         ╰────╯          

          ////

        ╭──────╮  ↑
        │ !P1! │──╯
        ╰──────╯         
            |            
            v            
         ╭────╮          
         │ P2 │          
         ╰────╯  

Legend:

╭───────────┬────────────────────────────────────╮
│   Sign    │              Meaning               │
├───────────┼────────────────────────────────────┤
│ !label!   │ High connectivity hub (bottleneck) │
│ [...] __↑ │ Feedback loop                      │
│ ////      │ Branch separator (multiple paths)  │
╰───────────┴────────────────────────────────────╯ 

╭─────────────╮
│ Explanation │
╰─────────────╯
[
	[
		"general",
		[ "Graph: CyclicTest", "Nodes: 3 | Edges: 3" ]
	],
	[
		"bottlenecks",
		[
			"Bottleneck nodes: @1",
			"All nodes have average degree 2",
			"  @1: degree 3 (above average)"
		]
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
# Executed in 0.14 second(s) in Ring 1.24

#-----------------#
#  TEST 7: BOTTLENECK NODES
#-----------------#

/*--- Finding highly-connected hub nodes

pr()

oGraph = new stzGraph("BottleneckTest")

oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")
oGraph.AddNode(:@3, "C")
oGraph.AddNode(:@hub, "Hub")

oGraph.AddEdge(:@1, :@hub, "")
oGraph.AddEdge(:@2, :@hub, "")
oGraph.AddEdge(:@3, :@hub, "")
oGraph.AddEdge(:@hub, :@1, "")

? @@( oGraph.BottleneckNodes() ) + NL
#--> [ "@hub" ]

oGraph.Show()
#-->
'
          ╭───╮          
          │ B │          
          ╰───╯          
            |            
                         
            |            
            v            
        ╭───────╮        
        │ !Hub! │        
        ╰───────╯        
            |            
                         
            |            
            v            
          ╭───╮          
          │ A │          
          ╰───╯          
            |            
      <CYCLE:  >   
            |              ↑
            ╰──> [!Hub!] ──╯

          ////

          ╭───╮          
          │ C │          
          ╰───╯          
            |            
                         
            |            
            v            
        ╭───────╮        
        │ !Hub! │        
        ╰───────╯        
            |            
                         
            |            
            v            
          ╭───╮          
          │ A │          
          ╰───╯          
            |            
      <CYCLE:  >   
            |              ↑
            ╰──> [!Hub!] ──╯
'

? ""
? BoxRound("EXPLANATION")

? @@NL( oGraph.Explain() )
#-->
'
╭─────────────╮
│ EXPLANATION │
╰─────────────╯
[
	[
		"general",
		[ "Graph: BottleneckTest", "Nodes: 4 | Edges: 4" ]
	],
	[
		"bottlenecks",
		[
			"Bottleneck nodes: @hub",
			"All nodes have average degree 2",
			"  @hub: degree 4 (above average)"
		]
	],
	[
		"cycles",
		[ "WARNING: Circular dependencies detected" ]
	],
	[
		"metrics",
		[
			"Density: 33.33% (moderate)",
			"Longest path: 2 hops"
		]
	]
]
'

pf()
# Executed in 0.16 second(s) in Ring 1.24

#-----------------#
#  TEST 8: GRAPH DENSITY
#-----------------#

/*--- Measuring connection density

pr()

oGraph = new stzGraph("DensityTest")

oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")
oGraph.AddNode(:@3, "C")

oGraph.AddEdge(:@1, :@2, "")
oGraph.AddEdge(:@2, :@3, "")
oGraph.AddEdge(:@1, :@3, "")

nDensity = oGraph.NodeDensity()
? nDensity #--> 50

pf()

#-----------------#
#  TEST 9: LONGEST PATH
#-----------------#

/*--- Finding maximum path length #TODO #ERROR

pr()

oGraph = new stzGraph("LongestPathTest")

oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")
oGraph.AddNode(:@3, "C")
oGraph.AddNode(:@4, "D")
oGraph.AddNode(:@5, "E")

oGraph.AddEdge(:@1, :@2, "")
oGraph.AddEdge(:@2, :@3, "")
oGraph.AddEdge(:@3, :@4, "")
oGraph.AddEdge(:@4, :@5, "")

nLongest = oGraph.LongestPath()
? nLongest #--> 4

pf()

#-----------------#
#  TEST 10: GET NEIGHBORS
#-----------------#

/*--- Finding outgoing connections

pr()

oGraph = new stzGraph("NeighborsTest")

oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")
oGraph.AddNode(:@3, "C")
oGraph.AddNode(:@4, "D")

oGraph.AddEdge(:@1, :@2, "")
oGraph.AddEdge(:@1, :@3, "")
oGraph.AddEdge(:@1, :@4, "")

aNeighbors = oGraph.NeighborsOf(:@1)
? len(aNeighbors) #--> 3

pf()

#-----------------#
#  TEST 11: GET INCOMING
#-----------------#

/*--- Finding incoming connections

pr()

oGraph = new stzGraph("IncomingTest")

oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")
oGraph.AddNode(:@3, "C")
oGraph.AddNode(:@4, "D")

oGraph.AddEdge(:@1, :@4, "")
oGraph.AddEdge(:@2, :@4, "")
oGraph.AddEdge(:@3, :@4, "")

aIncoming = oGraph.IncomingTo(:@4)
? len(aIncoming) #--> 3

pf()

#-----------------#
#  TEST 12: REMOVE NODE
#-----------------#

/*--- Deleting node and its edges

pr()

oGraph = new stzGraph("RemoveNodeTest")

oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")
oGraph.AddNode(:@3, "C")

oGraph.AddEdge(:@1, :@2, "")
oGraph.AddEdge(:@2, :@3, "")

oGraph.RemoveNode(:@2)

? oGraph.NodeCount() #--> 2
? oGraph.EdgeCount() #--> 0

pf()

#-----------------#
#  TEST 13: REMOVE EDGE
#-----------------#

/*--- Deleting single edge

pr()

oGraph = new stzGraph("RemoveEdgeTest")

oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")
oGraph.AddNode(:@3, "C")

oGraph.AddEdge(:@1, :@2, "")
oGraph.AddEdge(:@2, :@3, "")

oGraph.RemoveEdge(:@1, :@2)
? oGraph.EdgeCount() #--> 1

pf()

#-----------------#
#  TEST 14: NODE EXISTS
#-----------------#

/*--- Checking node existence

pr()

oGraph = new stzGraph("NodeExistsTest")
oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")

? oGraph.NodeExists(:@1) #--> TRUE
? oGraph.NodeExists(:@5) #--> FALSE

pf()

#-----------------#
#  TEST 15: EDGE EXISTS
#-----------------#

/*--- Checking edge existence

pr()

oGraph = new stzGraph("EdgeExistsTest")

oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")

oGraph.AddEdge(:@1, :@2, "")

? oGraph.EdgeExists(:@1, :@2) #--> TRUE
? oGraph.EdgeExists(:@2, :@1) #--> FALSE

pf()

#============================================#
#  Demonstrating visualization features      #
#============================================#

#---- Linear workflow - vertical display
=
pr()

oWorkflow = new stzGraph("ApprovalProcess")
oWorkflow {
	AddNode(:@request, "Request Submitted")
	AddNode(:@manager, "Manager Review")
	AddNode(:@director, "Director Approval")
	AddNode(:@approved, "Approved")
	
	AddEdge(:@request, :@manager, "submit")
	AddEdge(:@manager, :@director, "escalate")
	AddEdge(:@director, :@approved, "finalize")
	
	Show()
}

#-->
'
  ╭───────────────────╮  
  │ Request Submitted │  
  ╰───────────────────╯  
            |            
         submit          
            |            
            v            
   ╭────────────────╮    
   │ Manager Review │    
   ╰────────────────╯    
            |            
        escalate         
            |            
            v            
  ╭───────────────────╮  
  │ Director Approval │  
  ╰───────────────────╯  
            |            
        finalize         
            |            
            v            
      ╭──────────╮       
      │ Approved │       
      ╰──────────╯
'

pf()
# Executed in 0.04 second(s) in Ring 1.24

/*---- Multi-path process - showing alternatives #TODO

pr()

oMultiPath = new stzGraph("MultiPathProcess")
oMultiPath {
	AddNode(:@start, "Start")
	AddNode(:@fast, "Fast Path")
	AddNode(:@standard, "Standard Path")
	AddNode(:@end, "Complete")
	
	AddEdge(:@start, :@fast, "expedited")
	AddEdge(:@start, :@standard, "normal")
	AddEdge(:@fast, :@end, "finish")
	AddEdge(:@standard, :@end, "finish")
	
	ShowWithLegend() #TODO Add control : if diagram contains alternatives only vertical dispaly is possible
}

#-->
'
       ╭─────────╮       
       │ !Start! │       
       ╰─────────╯       
            |            
        expedited        
            |            
            v            
     ╭─────────────╮     
     │ !Fast Path! │     
     ╰─────────────╯     
            |            
         finish          
            |            
            v            
     ╭────────────╮      
     │ !Complete! │      
     ╰────────────╯      

          ////

       ╭─────────╮  ↑
       │ !Start! │──╯
       ╰─────────╯       
            |            
         normal          
            |            
            v            
   ╭─────────────────╮   
   │ !Standard Path! │   
   ╰─────────────────╯   
            |            
         finish          
            |            
            v            
     ╭────────────╮      
     │ !Complete! │      
     ╰────────────╯      

Legend:

╭─────────┬────────────────────────────────────╮
│  Sign   │              Meaning               │
├─────────┼────────────────────────────────────┤
│ !label! │ High connectivity hub (bottleneck) │
╰─────────┴────────────────────────────────────╯    
'

? ""
? @@Nl( oMultiPath.Explain() )
#-->
'
[
	[
		"general",
		[
			"Graph: MultiPathProcess",
			"Nodes: 4 | Edges: 4"
		]
	],
	[
		"bottlenecks",
		[ "No bottlenecks (average degree = 2)" ]
	],
	[
		"cycles",
		[ "No cycles - acyclic graph (DAG)" ]
	],
	[
		"metrics",
		[
			"Density: 33.33% (moderate)",
			"Longest path: 3 hops"
		]
	]
]
'
pf()
# Executed in 0.17 second(s) in Ring 1.24

/*---- Cycle detection visualization

pr()

oCyclic = new stzGraph("CyclicWorkflow")
oCyclic {
	AddNode(:@p1, "Process 1")
	AddNode(:@p2, "Process 2")
	AddNode(:@p3, "Process 3")
	
	AddEdge(:@p1, :@p2, "next")
	AddEdge(:@p2, :@p3, "next")
	AddEdge(:@p3, :@p1, "loop")
	
	? oCyclic.CyclicDependencies()
	#--> TRUE

	Show() # or ShowVertical() or ShowV()
}

#-->
'
      ╭───────────╮      
      │ Process 1 │      
      ╰───────────╯      
            |            
          next           
            |            
            v            
      ╭───────────╮      
      │ Process 2 │      
      ╰───────────╯      
            |            
          next           
            |            
            v            
      ╭───────────╮      
      │ Process 3 │      
      ╰───────────╯      
            |            
      <CYCLE: loop>   
            |                  ↑ 
            ╰──> [Process 1] ──╯
'

# And you can display the same diagram horizontall

? ""
oCyclic.ShowH() # Or ShowHorizontal
#-->
'

╭───────────╮         ╭───────────╮         ╭───────────╮
│ Process 1 │--next-->│ Process 2 │--next-->│ Process 3 │
╰───────────╯         ╰───────────╯         ╰───────────╯
      ↑                                           |
      ╰────────────────────loop───────────────────╯
'

pf()

/*---- Reachability analysis

pr()

oHierarchy = new stzGraph("TypeSystem")
oHierarchy {
	AddNode(:@entity, "Entity")
	AddNode(:@person, "Person")
	AddNode(:@employee, "Employee")
	AddNode(:@manager, "Manager")
	
	AddEdge(:@entity, :@person, "is_a")
	AddEdge(:@person, :@employee, "is_a")
	AddEdge(:@employee, :@manager, "is_a")
	
	? @@(oHierarchy.ReachableFrom(:@person))
	#--> [@person, @employee, @manager]

	? oHierarchy.PathExists(:@person, :@manager) + NL
	#--> TRUE

	ShowWithLegend()
}

#-->
'
       ╭────────╮        
       │ Entity │        
       ╰────────╯        
            |            
          is_a           
            |            
            v            
      ╭──────────╮       
      │ !Person! │       
      ╰──────────╯       
            |            
          is_a           
            |            
            v            
     ╭────────────╮      
     │ !Employee! │      
     ╰────────────╯      
            |            
          is_a           
            |            
            v            
       ╭─────────╮       
       │ Manager │       
       ╰─────────╯       

Legend:

╭─────────┬────────────────────────────────────╮
│  Sign   │              Meaning               │
├─────────┼────────────────────────────────────┤
│ !label! │ High connectivity hub (bottleneck) │
╰─────────┴────────────────────────────────────╯ 
'

? @@NL( oHierarchy.Explain() )
#-->
'
[
	[
		"general",
		[ "Graph: TypeSystem", "Nodes: 4 | Edges: 3" ]
	],
	[
		"bottlenecks",
		[
			"Bottleneck nodes: @person, @employee",
			"All nodes have average degree 1.50",
			"  @person: degree 2 (above average)",
			"  @employee: degree 2 (above average)"
		]
	],
	[
		"cycles",
		[ "No cycles - acyclic graph (DAG)" ]
	],
	[
		"metrics",
		[
			"Density: 25% (moderate)",
			"Longest path: 3 hops"
		]
	]
]
'

pf()

/*---

pr()

oDataFlow = new stzGraph("DataSystem")
oDataFlow {
    AddNode(:@sourceA, "Data Source A")
    AddNode(:@sourceB, "Data Source B")
    AddNode(:@sourceC, "Data Source C")
    AddNode(:@hub, "Hub")
    AddNode(:@analysis, "Analysis")

    AddEdge(:@sourceA, :@hub, "")
    AddEdge(:@sourceB, :@hub, "")
    AddEdge(:@sourceC, :@hub, "")
    AddEdge(:@hub, :@analysis, "")

    ? @@(oDataFlow.BottleneckNodes())
    #--> [@hub]

    Show()
}
#-->
'
    ╭───────────────╮    
    │ Data Source A │    
    ╰───────────────╯    
            |            
            v            
        ╭───────╮        
        │ !Hub! │        
        ╰───────╯        
            |            
            v            
      ╭──────────╮       
      │ Analysis │       
      ╰──────────╯       

          ////

    ╭───────────────╮    
    │ Data Source B │    
    ╰───────────────╯    
            |            
            v            
        ╭───────╮        
        │ !Hub! │        
        ╰───────╯        
            |            
            v            
      ╭──────────╮       
      │ Analysis │       
      ╰──────────╯       

          ////

    ╭───────────────╮    
    │ Data Source C │    
    ╰───────────────╯    
            |            
            v            
        ╭───────╮        
        │ !Hub! │        
        ╰───────╯        
            |            
            v            
      ╭──────────╮       
      │ Analysis │       
      ╰──────────╯  
'

pf()

#=====================#
#  ADVANCED FEATURES  #
#=====================#

/*--- Sample 1: Parallelizable Branches

pr()

# Detect independent execution paths that can run concurrently.

oGraph = new stzGraph("TaskSystem")
oGraph.AddNode(:@start, "Start")
oGraph.AddNode(:@pathA1, "Path A-1")
oGraph.AddNode(:@pathA2, "Path A-2")
oGraph.AddNode(:@pathB1, "Path B-1")
oGraph.AddNode(:@pathB2, "Path B-2")

oGraph.AddEdge(:@start, :@pathA1, "")
oGraph.AddEdge(:@start, :@pathB1, "")
oGraph.AddEdge(:@pathA1, :@pathA2, "")
oGraph.AddEdge(:@pathB1, :@pathB2, "")

? oGraph.ParallelizableBranches()
# Returns: [[:@pathA1, :@pathB1]] - branches with no shared downstream

? oGraph.DependencyFreeNodes()
# Returns: [:@start] - only entry point

pf()

/*--- Sample 2: Criticality and Impact

# Identify bottleneck nodes and their failure scope.

pr()

oGraph = new stzGraph("SystemDependencies")
oGraph.AddNode(:@database, "Database")
oGraph.AddNode(:@api, "API")
oGraph.AddNode(:@cache, "Cache")
oGraph.AddNode(:@worker1, "Worker1")
oGraph.AddNode(:@worker2, "Worker2")

oGraph.AddEdge(:@database, :@api, "")
oGraph.AddEdge(:@api, :@worker1, "")
oGraph.AddEdge(:@api, :@worker2, "")

? @@( oGraph.ImpactOf(:@api) )
#--> 2 - affects 2 downstream nodes

? @@( oGraph.FailureScope(:@api) )
#--> [:@worker1, :@worker2] - these fail if API fails

? @@( oGraph.MostCriticalNodes(2) )
#--> [:@api, :@database] - top 2 critical nodes

pf()

/*--- Sample 3: Constraints and Validation

# Enforce structural rules on the graph.

pr()

oGraph = new stzGraph("WorkflowEngine")
oGraph.AddNode(:@task1, "Task 1")
oGraph.AddNode(:@task2, "Task 2")
oGraph.AddNode(:@task3, "Task 3")

oGraph.AddConstraint("NO_CYCLES", "ACYCLIC")
oGraph.AddConstraint("CONNECTED", "CONNECTED")

oGraph.AddEdge(:@task1, :@task2, "")
oGraph.AddEdge(:@task2, :@task3, "")

? oGraph.ValidateConstraints()
# Returns: 1 - all constraints satisfied

? @@( oGraph.ConstraintViolations() )
# Returns: [] - no violations

pf()

/*--- Sample 4: Inference Rules

# Automatically derive implicit relationships.

pr()

oGraph = new stzGraph("Organization")
oGraph.AddNode(:@alice, "Alice")
oGraph.AddNode(:@bob, "Bob")
oGraph.AddNode(:@carol, "Carol")

oGraph.AddEdge(:@alice, :@bob, "manages")
oGraph.AddEdge(:@bob, :@carol, "manages")

oGraph.AddInferenceRule("HIERARCHY", "TRANSITIVITY")
? oGraph.ApplyInference()
# Returns: 1 - created one inferred edge

? oGraph.EdgeExists(:@alice, :@carol)
# Returns: 1 - now alice can reach carol transitively

? @@NL(oGraph.InferredEdges())
#-->
'
[
	[
		[ "from", "@alice" ],
		[ "to", "@carol" ],
		[ "label", "(inferred)" ],
		[ "properties", [  ] ]
	]
]
'

pf()

/*--- Sample 5: Rich Querying

# Flexible pattern-based searches.

pr()

oGraph = new stzGraph("Codebase")
oGraph.AddNodeXT(:@fn1, "function1", [:type = "function"])
oGraph.AddNodeXT(:@fn2, "function2", [:type = "function"])
oGraph.AddNodeXT(:@mod1, "module1", [:type = "module"])

oGraph.AddEdge(:@fn1, :@fn2, "calls")
oGraph.AddEdge(:@fn2, :@mod1, "imports")

? oGraph.Query([:nodeType = "function"])
# Returns: [:@fn1, :@fn2]

? oGraph.Query([:edgeLabel = "calls"])
# Returns: edges with label "calls"

? oGraph.FindNodesWhere(func node { return substr(node["label"], "function") > 0 })
# Returns: [:@fn1, :@fn2]

pf()

/*--- Sample 6: Temporal Snapshots

# Track graph evolution over time.

pr()

oGraph = new stzGraph("DatabaseSchema")
oGraph.AddNode(:@users, "users")
oGraph.AddNode(:@orders, "orders")
oGraph.AddEdge(:@users, :@orders, "has_many")

oGraph.Snapshot("v1.0")

# Make changes
oGraph.AddNode(:@payments, "payments")
oGraph.AddEdge(:@orders, :@payments, "has_many")

? @@(oGraph.ListSnapshots()) + NL
#--> ["v1.0"]

? @@NL(oGraph.ChangesSince("v1.0")) + NL
#-->
'
[
	[
		"nodesadded",
		[ "@payments" ]
	],
	[ "nodesremoved", [  ] ],
	[
		"edgesadded",
		[
			[ "@orders", "@payments" ]
		]
	],
	[ "edgesremoved", [  ] ]
]
'

oGraph.RestoreSnapshot("v1.0")
? oGraph.NodeCount()
#--> 2 - reverted to v1.0 state

pf()

/*--- Sample 7: Export Formats
*/
# Serialize graph to standard formats.

pr()

oGraph = new stzGraph("Pipeline")
oGraph.AddNode(:@input, "Input")
oGraph.AddNode(:@process, "Process")
oGraph.AddNode(:@output, "Output")
oGraph.AddEdge(:@input, :@process, "feeds")
oGraph.AddEdge(:@process, :@output, "produces")

? BoxRound("DOT FORMAT")
? oGraph.ExportDOT() + NL
# Returns: GraphViz DOT format string

? BoxRound("JSON FORMAT")
? oGraph.ExportJSON() + NL
# Returns: JSON with nodes, edges, and metrics

? BoxRound("YAML FORMAT")
? oGraph.ExportYAML()
# Returns: YAML representation

# Custom exporter
? BoxRound("CUSTOM FORMAT")
aAllNodes = oGraph.AllNodes()

oGraph.RegisterExporter("MERMAID", func {
	acNodes = oGraph.AllNodes()
	acEdges = oGraph.AllEdges()
	cMermaid = "graph LR;" + nl
	
	for i = 1 to len(acNodes)
		aNode = acNodes[i]
		cMermaid += "  " + aNode["id"] + "[" + aNode["label"] + "]" + nl
	end
	
	for i = 1 to len(acEdges)
		aEdge = acEdges[i]
		cMermaid += "  " + aEdge["from"] + " --> " + aEdge["to"] + nl
	end
	
	return cMermaid
})

? oGraph.ExportUsing("MERMAID")
# Returns: Mermaid diagram syntax

#-->
'
╭────────────╮
│ DOT FORMAT │
╰────────────╯
digraph Pipeline {
  rankdir=LR;
  node [shape=box];

  @input [label=  @process [label=  @output [label=
  @input -> @process [label=;
  @process -> @output [label=;
}


╭─────────────╮
│ JSON FORMAT │
╰─────────────╯
{"id":"Pipeline","nodes":[{"id":"@input","label":"Input","properties":{}},{"id":"@process","label":"Process","properties":{}},{"id":"@output","label":"Output","properties":{}}],"edges":[{"from":"@input","to":"@process","label":"feeds","properties":{}},{"from":"@process","to":"@output","label":"produces","properties":{}}],"metrics":{"nodecount":3,"edgecount":2,"density":33.33,"longestpath":2,"hascycles":0}}

╭─────────────╮
│ YAML FORMAT │
╰─────────────╯
graph: Pipeline
nodes:
  - id: @input
    label: Input
  - id: @process
    label: Process
  - id: @output
    label: Output

edges:
  - from: @input
    to: @process
    label: feeds
  - from: @process
    to: @output
    label: produces

╭───────────────╮
│ CUSTOM FORMAT │
╰───────────────╯
graph LR; @input --> @process
'

pf()
