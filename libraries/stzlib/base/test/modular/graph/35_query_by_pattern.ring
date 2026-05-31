# Narrative
# --------
# Query by Pattern
#
# Extracted from stzgraphtest.ring, block #35.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("QueryTest")
oGraph {
	AddNodeXTT("svc1", "Service 1", [:type = "backend"])
	AddNodeXTT("svc2", "Service 2", [:type = "frontend"])
	AddNodeXTT("db1", "Database", [:type = "backend", :sql = "yes"])


	? NodesByType("backend")
	#--> ["svc1", "db1"]

	# Internally, the previous query uses a more general expression
	# bases on the stzGraphFinder class, leading to the same result

	? Find("nodes").Where("type", "=", "backend").Run()
	#--> ["svc1", "db1"]
	
	? Find("nodes").Where("sql", "=", "yes").Run()
	#--> ["db1"]

}

#NODE For more advanced queries use stzGraphQuery

pf()
# Executed in 0.01 second(s) in Ring 1.24
