# Narrative
# --------
# pr()
#
# Extracted from stzgraphtest.ring, block #28.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

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
