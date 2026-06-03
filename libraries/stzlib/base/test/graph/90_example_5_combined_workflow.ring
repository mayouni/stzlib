# Narrative
# --------
# EXAMPLE 5: Combined Workflow
#
# Extracted from stzgraphtest.ring, block #90.

load "../../stzBase.ring"

# Query → Validate → Project → Analyze

pr()

# Register DAG validation
StzGraphQ("approval_flow") {

	AddNodeXTT("submit", "Submit Request", [:type = "start"])
	AddNodeXTT("review", "Peer Review", [:type = "approval"])
	AddNodeXTT("manager", "Manager Approval", [:type = "approval"])
	AddNodeXTT("exec", "Executive Approval", [:type = "approval"])
	AddNodeXTT("complete", "Complete", [:type = "end"])

	Connect("submit", "review")
	Connect("review", "manager")
	Connect("manager", "complete")

	UseRulesFrom(:dag)

	# Validate only approval steps
	QueryQ() {
		Match([:nodes, :props = [:type = "approval"]])
		ValidateWith(["dag"])  # Validates matched subgraph only
		Select("*")
		Execute()

		aApprovals = Result()
	}

	# Number of approaval nodes validated?
	? len(aApprovals)
	#--> 3

	# Add executive path
	Connect("manager", "exec")
	Connect("exec", "complete")

	# Create view for what-if analysis
	QueryQ() {
		Match([:nodes, :props = [:type = "approval"]])
		oView = ToViewQ()
	}

	# Critical approvals
	? @@(oView.MostCriticalNodes(2))

	# Simulate removal (doesn't affect original)
	oView.RemoveThisNode("manager")

	# After removal, view has this number of nodes
	? oView.NodesCount()
	#--> 2

	# While origianle graph has
	? NodesCount()
	#--> 5
}

pf()
# Executed in 0.02 second(s) in Ring 1.25
