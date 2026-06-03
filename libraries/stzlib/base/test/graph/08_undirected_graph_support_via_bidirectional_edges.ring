# Narrative
# --------
# Undirected Graph Support (via bidirectional edges)
#
# Extracted from stzgraphtest.ring, block #8.

load "../../stzBase.ring"


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
