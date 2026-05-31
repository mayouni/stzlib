# Narrative
# --------
# Average path length
#
# Extracted from stzgraphtest.ring, block #56.

load "../../../stzBase.ring"


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
