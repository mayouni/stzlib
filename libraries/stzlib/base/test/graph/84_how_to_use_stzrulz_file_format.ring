# Narrative
# --------
# How to use .stzrulz file format?
#
# A .stzrulz file is a graph's RULES, written down. You save the rules a
# graph carries, you load them into another graph, and the two agree.
#
# Extracted from stzgraphtest.ring, block #84.

load "../../stzBase.ring"


pr()

# Loading rules...
oGraph = new stzGraph("org")
oGraph.LoadFromStzRulz("../_data/bceao_banking.stzrulz")

? "Rules loaded: " + oGraph.NumberOfRules()
#--> Rules loaded: 2

# Both BCEAO rules are VALIDATION rules -- the file says so (type: validation),
# and the graph files each rule under its own type. Asking for constraints
# here would answer 0, and truthfully: this file declares none.

? @@( oGraph.RulesSummary()[:Validation] )
#--> [ "board_required", "audit_independence" ]

? @@( oGraph.RulesSummary()[:Constraint] )
#--> [ ]

pf()

#---------------------------------------#
#  3. custom_functions.stzrulf          #
#     Custom rule function definitions  #
#=======================================#

# See ../_data/custom_functions.stzrulf for a real one (loaded by test 85).
# It is pure Ring code: it defines rule functions and registers them into a
# rule group, which UseRulesFrom(:group) then pulls into a graph.
#
# One ordering rule bites everyone once: the RegisterRuleInGroup() calls must
# come ABOVE the func definitions. In Ring, a statement written after a func
# belongs to that func's body -- put the registrations below and they simply
# never run, silently.
