# Narrative
# --------
# EXAMPLE 3: Graph Projection (ToGraph)
#
# Extracted from stzgraphtest.ring, block #88.

load "../../stzBase.ring"

# Extract query results as independent graph for analysis

pr()

StzGraphQ("project_tasks") {

	# Tasks with status/priority
	AddNodeXTT("design", "UI Design", [:status = "complete", :priority = "high"])
	AddNodeXTT("backend", "Backend API", [:status = "in_progress", :priority = "high"])
	AddNodeXTT("frontend", "Frontend", [:status = "blocked", :priority = "high"])
	AddNodeXTT("testing", "Testing", [:status = "not_started", :priority = "medium"])
	AddNodeXTT("docs", "Documentation", [:status = "not_started", :priority = "low"])

	Connect("design", "frontend")
	Connect("backend", "frontend")
	Connect("frontend", "testing")
	Connect("testing", "docs")

	# How many tasks (nodes) in the full project (graph)?
	? NodesCount()
	#--> 5

	# Project to subgraph: high-priority tasks only
	QueryQ() {
		Match([:nodes, :props = [:priority = "high"]])
		Select("*")
		oHighPriority = ToStzGraph()  # Creates new independent graph
	}

	# Let's focus on the High-priority subgraph
	 oHighPriority {

		# Number of tasks
		? NodesCount()
		#--> 3

		# Density in %
		? Density100()
		#--> 33.33%

		# Any bottlenecks?
		? @@NL( BottleneckNodes() )
		#--> [ "frontend" ]
	}

}

pf()
