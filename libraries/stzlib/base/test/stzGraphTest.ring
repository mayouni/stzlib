load "../stzbase.ring"

/*---
*/
oGraph = new stzGraph("DAGStructure")
oGraph {
    AddNodeXT(:@a, "A")
    AddNodeXT(:@b, "B")
    AddNodeXT(:@c, "C")
    
    AddConstraint("ACYCLIC")
    AddConstraint("CONNECTED")
    
    AddEdge(:@a, :@b) # Or Connect() as you see in the fellowing line
    Connect(:@b, :To = :@c)
}

? oGraph.ValidateConstraints()
#--> TRUE

pf()
#  stzGraphTest - Test Suite

/*--- Three forms of AddEge/Connect method
*/

pr()

oGraph = new stzGraph("DAGStructure")
oGraph {

    # Adding a node by just providong it's ID, wihc will also be it's label

    AddNode(:@a)

    # Adding a node by giving the ID and the label
    AddNodeXT(:@b, "B")

    # Adding a node by giving an ID, a label, and a hashlist of metatdate

    AddNodeXTT(:@c, "C", [ :prop1 = "", :prop2 = "" ])
    
    # Providing only the nodes forming the edge
    AddEdge(:@a, :@b)
    # Or Connect(:@a, :To = :@b)

    # Providing the edges and the label between them
    AddEdgeXT(:@a, :@c, "label")
    # Or ConnectXT(:@a, :To = :@b, :With = "label")
    # You can use :Label = "label" instead of :With

    # Providing the edge, the label, and a hashlist of metada
    AddEdgeXTT(:@a, :@d, "label", [ :prop1 = "", :prop2 = "" ])
    # Or ConnectXTTT(:@a, :To = @d, :Label = "label", :Props = [...]

    ? @@NL( Nodes() ) + NL

    ? @@NL( Edges() )
}


pf()
/*--- Creating a simple 3-node linear graph

pr()

oGraph = new stzGraph("SimpleGraph")
oGraph {
	AddNodeXT(:@1, "Node 1")
	AddNodeXT(:@2, "Node 2")
	AddNodeXT(:@3, "Node 3")

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

oGraph.AddNodeXT(:@start, "Start")
oGraph.AddNodeXT(:@middle, "Middle")
oGraph.AddNodeXT(:@end, "End")
oGraph.AddNodeXT(:@isolated, "Isolated")

oGraph.AddEdge(:@start, :@middle, "")
oGraph.AddEdge(:@middle, :@end, "")

? oGraph.PathExists(:@start, :@end) 		#--> TRUE
? oGraph.PathExists(:@start, :@isolated) 	#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Finding all nodes reachable from a given node

pr()


oGraph = new stzGraph("ReachabilityTest")

oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")
oGraph.AddNodeXT(:@3, "C")
oGraph.AddNodeXT(:@4, "D")

oGraph.AddEdge(:@1, :@2, "")
oGraph.AddEdge(:@2, :@3, "")
oGraph.AddEdge(:@1, :@4, "")

aReachable = oGraph.ReachableFrom(:@1)
? len(aReachable) #--> 4

pf()

/*--- Enumerating all routes in diamond graph

pr()

oGraph = new stzGraph("AllPathsTest")

oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")
oGraph.AddNodeXT(:@3, "C")
oGraph.AddNodeXT(:@4, "D")

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
oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")
oGraph.AddNodeXT(:@3, "C")

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

oGraph.AddNodeXT(:@1, "P1")
oGraph.AddNodeXT(:@2, "P2")
oGraph.AddNodeXT(:@3, "P3")

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

oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")
oGraph.AddNodeXT(:@3, "C")
oGraph.AddNodeXT(:@hub, "Hub")

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

oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")
oGraph.AddNodeXT(:@3, "C")

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

oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")
oGraph.AddNodeXT(:@3, "C")
oGraph.AddNodeXT(:@4, "D")
oGraph.AddNodeXT(:@5, "E")

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

oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")
oGraph.AddNodeXT(:@3, "C")
oGraph.AddNodeXT(:@4, "D")

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

oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")
oGraph.AddNodeXT(:@3, "C")
oGraph.AddNodeXT(:@4, "D")

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

oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")
oGraph.AddNodeXT(:@3, "C")

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

oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")
oGraph.AddNodeXT(:@3, "C")

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
oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")

? oGraph.NodeExists(:@1) #--> TRUE
? oGraph.NodeExists(:@5) #--> FALSE

pf()

#-----------------#
#  TEST 15: EDGE EXISTS
#-----------------#

/*--- Checking edge existence

pr()

oGraph = new stzGraph("EdgeExistsTest")

oGraph.AddNodeXT(:@1, "A")
oGraph.AddNodeXT(:@2, "B")

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
	AddNodeXT(:@request, "Request Submitted")
	AddNodeXT(:@manager, "Manager Review")
	AddNodeXT(:@director, "Director Approval")
	AddNodeXT(:@approved, "Approved")
	
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
	AddNodeXT(:@start, "Start")
	AddNodeXT(:@fast, "Fast Path")
	AddNodeXT(:@standard, "Standard Path")
	AddNodeXT(:@end, "Complete")
	
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
	AddNodeXT(:@p1, "Process 1")
	AddNodeXT(:@p2, "Process 2")
	AddNodeXT(:@p3, "Process 3")
	
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
	AddNodeXT(:@entity, "Entity")
	AddNodeXT(:@person, "Person")
	AddNodeXT(:@employee, "Employee")
	AddNodeXT(:@manager, "Manager")
	
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
    AddNodeXT(:@sourceA, "Data Source A")
    AddNodeXT(:@sourceB, "Data Source B")
    AddNodeXT(:@sourceC, "Data Source C")
    AddNodeXT(:@hub, "Hub")
    AddNodeXT(:@analysis, "Analysis")

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
oGraph.AddNodeXT(:@start, "Start")
oGraph.AddNodeXT(:@pathA1, "Path A-1")
oGraph.AddNodeXT(:@pathA2, "Path A-2")
oGraph.AddNodeXT(:@pathB1, "Path B-1")
oGraph.AddNodeXT(:@pathB2, "Path B-2")

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
oGraph.AddNodeXT(:@database, "Database")
oGraph.AddNodeXT(:@api, "API")
oGraph.AddNodeXT(:@cache, "Cache")
oGraph.AddNodeXT(:@worker1, "Worker1")
oGraph.AddNodeXT(:@worker2, "Worker2")

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
oGraph.AddNodeXT(:@task1, "Task 1")
oGraph.AddNodeXT(:@task2, "Task 2")
oGraph.AddNodeXT(:@task3, "Task 3")

oGraph.AddConstraint("ACYCLIC")
oGraph.AddConstraint("CONNECTED")

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
oGraph.AddNodeXT(:@alice, "Alice")
oGraph.AddNodeXT(:@bob, "Bob")
oGraph.AddNodeXT(:@carol, "Carol")

oGraph.AddEdge(:@alice, :@bob, "manages")
oGraph.AddEdge(:@bob, :@carol, "manages")

oGraph.AddInferenceRule("TRANSITIVITY")
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

#---

pr()

oGraph = new stzGraph("Organization")
oGraph.AddNodeXT(:@alice, "Alice")
oGraph.AddNodeXT(:@bob, "Bob")
oGraph.AddNodeXT(:@carol, "Carol")
oGraph.AddNodeXT(:@david, "David")

oGraph.AddEdgeXT(:@alice, :@bob, "manages")
oGraph.AddEdgeXT(:@bob, :@carol, "manages")
oGraph.AddEdgeXT(:@carol, :@david, "manages")

# Register custom inference rule as autonomous function
oGraph.RegisterInferenceRule("CHAIN_OF_COMMAND", func oGraph {
	nInferred = 0
	acEdges = oGraph.AllEdges()
	acNewEdges = []
	
	nLen = len(acEdges)
	for i = 1 to nLen
		aEdge1 = acEdges[i]
		cMidpoint = aEdge1["to"]
		
		for j = 1 to nLen
			aEdge2 = acEdges[j]
			if aEdge2["from"] = cMidpoint
				cFrom = aEdge1["from"]
				cTo = aEdge2["to"]
				
				if NOT oGraph.EdgeExists(cFrom, cTo)
					if find(acNewEdges, [cFrom, cTo]) = 0
						acNewEdges + [cFrom, cTo]
						nInferred += 1
					ok
				ok
			ok
		end
	end
	
	nNewLen = len(acNewEdges)
	for i = 1 to nNewLen
		aNewEdge = acNewEdges[i]
		oGraph.AddEdgeXT(aNewEdge[1], aNewEdge[2], "(chain-inferred)")
	end
	
	return nInferred
})

? oGraph.ApplyCustomInference("CHAIN_OF_COMMAND")
# Returns: 3

? oGraph.EdgeExists(:@alice, :@carol)
# Returns: 1

? oGraph.CustomInferenceRules()
# Returns: ["CHAIN_OF_COMMAND"]

pf()

/*--- Sample 5: Rich Querying

# Flexible pattern-based searches.

pr()

oGraph = new stzGraph("Codebase")
oGraph.AddNodeXTT(:@fn1, "function1", [:type = "function"])
oGraph.AddNodeXTT(:@fn2, "function2", [:type = "function"])
oGraph.AddNodeXTT(:@mod1, "module1", [:type = "module"])

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
oGraph.AddNodeXT(:@users, "users")
oGraph.AddNodeXT(:@orders, "orders")
oGraph.AddEdge(:@users, :@orders, "has_many")

oGraph.Snapshot("v1.0")

# Make changes
oGraph.AddNodeXT(:@payments, "payments")
oGraph.AddEdge(:@orders, :@payments, "has_many")

? @@(oGraph.Snapshots()) + NL
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

# Serialize graph to standard formats.

pr()

oGraph = new stzGraph("Pipeline")
oGraph.AddNodeXT(:@input, "Input")
oGraph.AddNodeXT(:@process, "Process")
oGraph.AddNodeXT(:@output, "Output")
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
