# Narrative
# --------
# Path Explanation
#
# Extracted from stzgraphtest.ring, block #34.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("ImpactTest")
oGraph {
	AddNode("db")
	AddNode("api")
	AddNode("worker1")
	AddNode("worker2")
	
	ConnectXT("db", "api", "exposes")
	ConnectXT("api", "worker1", "is_used_by")
	ConnectXT("api", "worker2", "is_used_by")

	? @@NL( ExplainPath("db", "worker2") )
}
#-->
'
[
	"db → api : because {db} exposes {api}",
	"api → worker2 : because {api} is used by {worker2}"
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 9: ADVANCED QUERYING
#============================================#
