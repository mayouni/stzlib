# Narrative
# --------
# Path Matching
#
# Extracted from stzgraphtest.ring, block #37.

load "../../../stzBase.ring"


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
