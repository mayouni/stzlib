# Narrative
# --------
# pr()
#
# Extracted from stzgraphtest.ring, block #9.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

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
    
    _nNeighborsLen_ = len(acNeighbors)
    for i = 1 to _nNeighborsLen_
        cNext = acNeighbors[i]
        if find(acVisited, cNext) = 0
            ? "  Adding neighbor: " + cNext
            acVisited + cNext
            acQueue + cNext
        ok
    end
    
    _nIncomingLen_ = len(acIncoming)
    for i = 1 to _nIncomingLen_
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
