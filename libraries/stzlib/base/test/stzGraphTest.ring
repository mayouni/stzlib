load "../stzbase.ring"

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

pf()

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

? @@( oGraph.BottleneckNodes() )
#--> [ "@hub" ]

pf()

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
	
	ShowV()
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

/*---- Multi-path process - showing alternatives

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
	
	Show()
}

#-->
'
=== MultiPathProcess (Vertical) ===

[Start]
  |
  expedited
  |
  V
  [Fast Path]
    |
    finish
    |
    V
    [Complete]

[Start]
  |
  normal
  |
  V
  [Standard Path]
    |
    finish
    |
    V
    [Complete]
'

pf()
/*---- Show specific path between nodes

pr()

oProcess = new stzGraph("ServiceFlow")
oProcess {
	AddNode(:@api, "API Gateway")
	AddNode(:@auth, "Auth Service")
	AddNode(:@db, "Database")
	AddNode(:@cache, "Cache")
	
	AddEdge(:@api, :@auth, "validate")
	AddEdge(:@auth, :@db, "query")
	AddEdge(:@db, :@cache, "store")
	
	ShowPath(:@api, :@cache)
}

#-->
'
=== Path from @api to @cache ===

[API Gateway]
   |
   validate
   |
   V
[Auth Service]
   |
   query
   |
   V
[Database]
   |
   store
   |
   V
[Cache]
'

/*---- Show neighborhood analysis

pr()

oOrg = new stzGraph("Organization")
oOrg {
	AddNode(:@ceo, "CEO")
	AddNode(:@director, "Director")
	AddNode(:@manager, "Manager")
	AddNode(:@dev1, "Developer 1")
	AddNode(:@dev2, "Developer 2")
	
	AddEdge(:@ceo, :@director, "manages")
	AddEdge(:@director, :@manager, "manages")
	AddEdge(:@manager, :@dev1, "manages")
	AddEdge(:@manager, :@dev2, "manages")
	
	ShowNeighborhood(:@manager)
}

#-->
'
=== Neighborhood of [Manager] ===

INCOMING:
  [Director]
    (manages)

CENTER: [Manager]

OUTGOING:
  [Developer 1]
    (manages)
  [Developer 2]
    (manages)
'

/*---- Show bottleneck analysis

pr()

oDataFlow = new stzGraph("DataSystem")
oDataFlow {
	AddNode(:@sourceA, "Source A")
	AddNode(:@sourceB, "Source B")
	AddNode(:@sourceC, "Source C")
	AddNode(:@hub, "Central Hub")
	AddNode(:@analysis, "Analysis Service")
	
	AddEdge(:@sourceA, :@hub, "feed")
	AddEdge(:@sourceB, :@hub, "feed")
	AddEdge(:@sourceC, :@hub, "feed")
	AddEdge(:@hub, :@analysis, "output")
	
	ShowBottlenecks()
}

#-->
'
=== BOTTLENECKS ===

[Central Hub]
  Incoming: 3
  Outgoing: 1

'
pf()

/*---- Display statistics

pr()

oGraph = new stzGraph("SystemA")
oGraph {
	AddNode(:@a, "Component A")
	AddNode(:@b, "Component B")
	AddNode(:@c, "Component C")
	
	AddEdge(:@a, :@b, "")
	AddEdge(:@b, :@c, "")
	AddEdge(:@a, :@c, "")
	
	Inspect()
}

#-->
'
=== Graph: SystemA ===
Nodes: 3
Edges: 3
Cyclic: No
Density: 50%
Longest Path: 2
'

pf()

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
	
	? "Has Cycles: " + oCyclic.CyclicDependencies()
	Show()
}

#-->
'
Has Cycles: 1

=== CyclicWorkflow (Vertical) ===

[Process 1]
  |
  next
  |
  V
  [Process 2]
    |
    next
    |
    V
    [Process 3]
      |
      loop
      |
      V
      [Process 1]

(Note: Cycle detected in visualization)
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

	? oHierarchy.PathExists(:@person, :@manager)
	#--> TRUE

	Show()
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
       ╭────────╮        
       │ Person │        
       ╰────────╯        
            |            
          is_a           
            |            
            v            
      ╭──────────╮       
      │ Employee │       
      ╰──────────╯       
            |            
          is_a           
            |            
            v            
       ╭─────────╮       
       │ Manager │       
       ╰─────────╯   
'

pf()
