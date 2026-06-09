# Narrative
# --------
# Workflow dependency analysis
#
# Extracted from stzgraphtest.ring, block #58.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


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
