# Narrative
# --------
# How to use .stzrulf file format?
#
# .stzrulz says WHICH rules a graph carries. .stzrulf says what a custom rule
# DOES -- it is pure Ring code that defines rule functions and registers them
# into a rule group. Together they let a domain teach stzGraph rules the
# library never shipped:
#
#   .stzrulf  -> defines the functions + registers them into a group
#   .stzrulz  -> declares rules that reference functions BY NAME
#   UseRulesFrom(:group) -> pulls the group's rules into this graph
#
# Extracted from stzgraphtest.ring, block #85.

load "../../stzBase.ring"


pr()

# Loading custom functions
oGraph = new stzGraph("banking_system")

# Load the function definitions first
oGraph.LoadRuleFunctionsFrom("../_data/custom_functions.stzrulf")

# Then load the rules that reference them
oGraph.LoadFromStzRulz("../_data/compliance_rules.stzrulz")

? "Declared in the .stzrulz file: " + oGraph.NumberOfRules()
#--> Declared in the .stzrulz file: 3

# Now the custom functions are available
oGraph.UseRulesFrom(:banking)
oGraph.UseRulesFrom(:hr)

? "After pulling in the custom groups: " + oGraph.NumberOfRules()
#--> After pulling in the custom groups: 6

# Each rule sits under its own type -- the ones declared in the file and the
# custom ones from the groups, side by side. (StzRegisterRule upper-cases a
# registered name; a declared one keeps its spelling.)

? @@( oGraph.RulesSummary()[:Constraint] )
#--> [ "no_self_loop", "NO_BACKDATING" ]

? @@( oGraph.RulesSummary()[:Derivation] )
#--> [ "reporting_is_transitive", "MANAGER_APPROVAL_RIGHTS" ]

? @@( oGraph.RulesSummary()[:Validation] )
#--> [ "chart_is_acyclic", "BALANCED_TEAMS" ]

# Pulling the same group again adds nothing -- a rule name is unique per type.
oGraph.UseRulesFrom(:banking)
? "Still: " + oGraph.NumberOfRules()
#--> Still: 6

# And loading the same .stzrulf again is a quiet no-op, not a crash. Ring
# refuses to define a function twice (C22, a COMPILE error try/catch cannot
# catch), so two graphs wanting the same rule functions must not blow up.
oGraph.LoadRuleFunctionsFrom("../_data/custom_functions.stzrulf")
? "Loading the same .stzrulf twice is safe: " + oGraph.NumberOfRules()
#--> Loading the same .stzrulf twice is safe: 6

pf()

#=============================================================================
#  DEFERRED BELOW -- .stzsim and the end-to-end workflow
#
#  The blocks that used to follow here were never executable: they read
#  org_current.stzgraf, restructure.stzsim and mycompany.stzgraf, none of
#  which exist in the repo, and they `load "custom_functions.stzrulf"` at
#  COMPILE time -- which, next to a runtime load of the same file, is the
#  C22 "Function redefinition" this test was headed with for months.
#
#  They are kept below as the record of what .stzsim is meant to do. They
#  are a DIFFERENT feature from the rule file formats (graph simulation and
#  .stzgraf persistence) and want their own fixtures and their own pass.
#=============================================================================

# Example of a .stzsim file format
`
simulation "Move Treasury Under CFO Comparison"
    description: "Changes from baseline"
    date: 2024-12-26

changes

    add node risk_officer
        label: "Risk Officer"

    add node compliance_officer
        label: "Compliance Officer"

    remove edge ceo -> treasury_head

    add edge cfo -> treasury_head
    add edge treasury_head -> risk_officer
    add edge treasury_head -> compliance_officer

metrics

    density: 0.25 -> 0.32
    nodeCount: 8 -> 10
    edgeCount: 7 -> 9
    hasCycles: FALSE -> FALSE
`

# How to use .stzsim file format? (needs org_current.stzgraf + restructure.stzsim)
#
#	oBaseline = new stzGraph("current_org")
#	oBaseline.LoadFromStzGraf("org_current.stzgraf")
#	cSimulation = read("restructure.stzsim")
#	oBaseline.ApplySimulation(cSimulation)
#	? "  Nodes: " + oBaseline.NodeCount()
#	? "  Edges: " + oBaseline.EdgeCount()

# Complete workflow using the file formats (needs the same fixtures)
#
#	oCompany = new stzGraph("MyCompany")
#	oCompany {
#		AddNodeXTT("ceo", "CEO", [:level = 5])
#		AddNodeXTT("cto", "CTO", [:level = 4, :department = "tech"])
#		AddNodeXTT("cfo", "CFO", [:level = 4, :department = "finance"])
#		AddNodeXTT("eng1", "Engineer 1", [:level = 2, :department = "tech"])
#		Connect("ceo", "cto")
#		Connect("ceo", "cfo")
#		Connect("cto", "eng1")
#		SaveToStzGraf("mycompany.stzgraf")
#	}
#	oCompany.LoadRuleFunctionsFrom("../_data/custom_functions.stzrulf")
#	oCompany.LoadFromStzRulz("../_data/compliance_rules.stzrulz")
#	oCompany.UseRulesFrom(:banking)
#	nDerived = oCompany.ApplyDerivations()
#	? "  Derived edges: " + nDerived
#	oVariation = oCompany.Copy()
#	oVariation {
#		AddNodeXTT("coo", "COO", [:level = 4])
#		RemoveThisEdge("ceo", "cto")
#		Connect("ceo", "coo")
#		Connect("coo", "cto")
#	}
#	cSim = oVariation.ExportToStzSim(oCompany)
#	write("add_coo.stzsim", cSim)
#	aResult = oVariation.Validate()
#	? "  Valid: " + aResult[1]

#--- Key Concepts explored in those samples:

	# 1. Rules are registered globally, loaded per-graph

	# 2. Queries match subsets of the graph, rules apply
	#    only to those matches

	# 3. ToGraphQ() = independent copy for analysis

	# 4. ToViewQ() = linked view with commit/rollback

	# 5. Three rule types: Constraint (guard),
	#    Derivation (auto-generate), Validation (verify)
