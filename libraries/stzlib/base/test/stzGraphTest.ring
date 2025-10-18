load "../stzbase.ring"

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
*/
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
*/
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

pf()
