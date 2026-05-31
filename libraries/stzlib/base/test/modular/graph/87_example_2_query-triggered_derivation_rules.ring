# Narrative
# --------
# EXAMPLE 2: Query-Triggered Derivation Rules
#
# Extracted from stzgraphtest.ring, block #87.

load "../../../stzBase.ring"

# Goal : Auto-generate edges from patterns in matched subgraph

pr()

# Register transitive closure rule
RegisterRule(:SEMANTIC, "AUTO_TRANSITIVITY", [
	:type = :Derivation,
	:function = DerivationFunc_Transitivity(),
	:params = [],
	:message = "Transitive closure",
	:severity = :info
])

StzGraphQ("knowledge_base") {

	# Taxonomy hierarchy
	AddNodeXT("mammals", "Mammals")
	AddNodeXT("dogs", "Dogs")
	AddNodeXT("poodles", "Poodles")
	AddNodeXT("birds", "Birds")
	AddNodeXT("sparrows", "Sparrows")

	ConnectXT("poodles", "dogs", "is_a")
	ConnectXT("dogs", "mammals", "is_a")
	ConnectXT("sparrows", "birds", "is_a")

	# Edges before derivation
	? EdgesCount()
	#--> 3

	UseRulesFrom(:SEMANTIC)

	# Derive transitivity only on is_a edges
	QueryQ() {
		MatchEdge([:labeled, "is_a"])
		DeriveUsing("AUTO_TRANSITIVITY")
		Execute()
	}

	# Edges after derivation
	? EdgesCount()
	#--> 4
	
	# Verify derived edge exists
	? EdgeExists("poodles", "mammals")
	#-->  TRUE
}

pf()
# Executed in 0.01 second(s) in Ring 1.25
