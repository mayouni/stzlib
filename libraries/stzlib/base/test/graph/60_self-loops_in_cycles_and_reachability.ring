# Narrative
# --------
# Self-Loops in Cycles and Reachability
#
# Extracted from stzgraphtest.ring, block #60.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()
oGraph = new stzGraph("SelfCycleTest")
oGraph {
	AddNode("a")
	AddNode("b")

	Connect(:Node = "a", :ToNode = "a")  # Self-loop
	Connect(:Node = "a", :ToNode = "b")

	? HasCyclicDependencies()
	#--> TRUE  # Self-loop counts as cycle

	? ReachableFromNode("a")
	#--> [ "a", "b" ]  # Includes self
}
pf()
# Executed in almost 0 second(s) in Ring 1.24

#==============================#
#  GRAPH RULES AND VALIDATION  # 
#==============================#

# Rules System Overview:
# ----------------------
# Three rule types control graph behavior at different phases:
#
# 1. Constraint	- Runs BEFORE operations, blocks invalid changes
# ~> Can I add this edge without breaking rules?

# 2. Derivation - Runs AFTER changes, auto-derives new edges/nodes
# ~> Now that I've added this, derive the implications

# 3. Validation	- Runs on-demand, validates the complete graph state
# ~> Is the graph in a consistent state overall?

# Each rule is a hashlist with:
#   :type     - When it runs (Constraint/Derivation/Validation)
#   :function - What it does (receives graph, returns result)
#   :params   - Configuration data
#   :message  - Human-readable description
#   :severity - :info, :warning, or :error

#==========================================================#
#  GRAPH RULES SYSTEM - COMPLETE EXAMPLES                  #
#  Three rule types: Constraint → Derivation → Validation  #
#==========================================================#
