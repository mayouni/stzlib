# Narrative
# --------
# Edge props
#
# Extracted from stzgraphtest.ring, block #40.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("EdgeMetaTest")
oGraph {
	AddNode("a")
	AddNode("b")
	Connect("a", "b")
	
	SetEdgeProperties("a", "b", [:bandwidth = 1000, :protocol = "tcp"])
	
	? @@( EdgeProperties(:from = "a", :to = "b") ) + NL
	#--> [ "bandwidth", "protocol" ]

	? @@( EdgePropsXT("a", "b") ) + NL
	#--> [ [ "bandwidth", 1000 ], [ "protocol", "tcp" ] ]
	
	UpdateEdgeProperty("a", "b", "latency", 5)
	
	? EdgeProp("a", "b", "latency")
	#--> 5
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 13: EDGE OPERATIONS
#============================================#
