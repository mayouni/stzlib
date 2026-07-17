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

#-----------------------------------------#
#  4. restructure.stzsim                  #
#     Simulation (changes between graphs) #
#=========================================#

# Example of a .stzsim file format -- see ../_data/restructure.stzsim
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

# How to use .stzsim file format?
#
# A .stzsim is a graph's CHANGES, written down: what a proposed restructure
# would add and remove. You read a baseline, apply the changes, and look at
# what you would get -- before doing it for real.

# Loading baseline
oBaseline = new stzGraph("current_org")
oBaseline.LoadFromStzGraf("../_data/org_current.stzgraf")

? "Before: " + oBaseline.NodeCount() + " nodes, " + oBaseline.EdgeCount() + " edges"
#--> Before: 8 nodes, 7 edges

? "Treasury reports to the CEO: " + oBaseline.EdgeExists("ceo", "treasury_head")
#--> Treasury reports to the CEO: 1

# Applying simulation
cSimulation = read("../_data/restructure.stzsim")
oBaseline.ApplySimulation(cSimulation)

# After changes
? "  Nodes: " + oBaseline.NodeCount() #--> Nodes: 10
? "  Edges: " + oBaseline.EdgeCount() #--> Edges: 9

# ... which is exactly what the file's own metrics section promised
# (nodeCount: 8 -> 10, edgeCount: 7 -> 9).

? "Treasury now reports to the CFO: " + oBaseline.EdgeExists("cfo", "treasury_head")
#--> Treasury now reports to the CFO: 1

? "... and no longer to the CEO: " + (NOT oBaseline.EdgeExists("ceo", "treasury_head"))
#--> ... and no longer to the CEO: 1

# An added node keeps the label the simulation gave it (spaces normalise to
# underscores -- a label carries no spaces in a stzGraph).
? "The new officer is labelled: " + oBaseline.NodeLabel("risk_officer")
#--> The new officer is labelled: Risk_Officer

#--------------------------------------------------#
# 5. Complete workflow example using file formats  #
#==================================================#

# Step 1: Create and save a graph

	oCompany = new stzGraph("MyCompany")
	oCompany {
		AddNodeXTT("ceo", "CEO", [:level = 5])
		AddNodeXTT("cto", "CTO", [:level = 4, :department = "tech", :role = "manager"])
		AddNodeXTT("cfo", "CFO", [:level = 4, :department = "finance"])
		AddNodeXTT("eng1", "Engineer 1", [:level = 2, :department = "tech"])
		AddNode("eng1_approval")

		Connect("ceo", "cto")
		Connect("ceo", "cfo")
		Connect("cto", "eng1")

		SaveToStzGraf("_mycompany.stzgraf")
	}

	? "Saved: " + fexists("_mycompany.stzgraf") #--> Saved: 1

# Step 2: Load custom functions (already in this process from block 1 --
#         a second load is a no-op, which is the point)

	oCompany.LoadRuleFunctionsFrom("../_data/custom_functions.stzrulf")

# Step 3: Load rules

	oCompany.LoadFromStzRulz("../_data/compliance_rules.stzrulz")

# Step 4: Apply rules

	oCompany.UseRulesFrom(:banking)
	aDerived = oCompany.ApplyDerivationRulesXT()
	? "  Derived edges: " + len(aDerived[:edgesAdded]) #--> Derived edges: 2

	# Two rules fired, each deriving what it knows:
	#   reporting_is_transitive  -> ceo can reach eng1 through cto
	#   MANAGER_APPROVAL_RIGHTS  -> cto (role: manager) can approve eng1's
	#                               approval node, which exists
	? "  ceo -> eng1 (transitivity) : " + oCompany.EdgeExists("ceo", "eng1")
	#--> ceo -> eng1 (transitivity) : 1
	? "  cto -> eng1_approval (custom rule) : " + oCompany.EdgeExists("cto", "eng1_approval")
	#--> cto -> eng1_approval (custom rule) : 1

# Step 5: Create variation

	oVariation = oCompany.Copy()
	oVariation {
		AddNodeXTT("coo", "COO", [:level = 4])
		RemoveThisEdge("ceo", "cto")
		Connect("ceo", "coo")
		Connect("coo", "cto")
	}

# Step 6: Export simulation

	cSim = oVariation.ExportToStzSim(oCompany)
	write("_add_coo.stzsim", cSim)
	? "  Saved to _add_coo.stzsim" #--> Saved to _add_coo.stzsim

	# The diff says ONLY what changed -- one node in, one edge out, two in.
	# (An edge that never moved appears in neither list.)
	? "  add node coo declared: " + (StzFindFirst(cSim, "add node coo") > 0)
	#--> add node coo declared: 1
	? "  remove edge ceo -> cto declared: " + (StzFindFirst(cSim, "remove edge ceo -> cto") > 0)
	#--> remove edge ceo -> cto declared: 1

	# And it round-trips: replay it onto the original and you get the variation.
	oReplay = oCompany.Copy()
	oReplay.ApplySimulation(cSim)
	? "  Replayed == variation: " + (oReplay.NodeCount() = oVariation.NodeCount() and
		oReplay.EdgeCount() = oVariation.EdgeCount())
	#--> Replayed == variation: 1

# Step 7: Validate

	? "Validating structure..."
	aResult = oVariation.Validate()

	# Validate() answers with a REPORT, not a bare flag: what it ran, what
	# failed, and every issue it found. (The block used to read aResult[1],
	# which is the ["status","pass"] PAIR -- a list, so printing it raised
	# R21. It had never run to find out.)
	? "  Valid: " + aResult[:status] #--> Valid: pass
	? "  Validators run: " + aResult[:validatorsRun] #--> Validators run: 3
	? "  Issues: " + aResult[:totalIssues] #--> Issues: 0

	remove("_mycompany.stzgraf")
	remove("_add_coo.stzsim")

pf()

#--- Key Concepts explored in those samples:

	# 1. Rules are registered globally, loaded per-graph

	# 2. Queries match subsets of the graph, rules apply
	#    only to those matches

	# 3. ToGraphQ() = independent copy for analysis

	# 4. ToViewQ() = linked view with commit/rollback

	# 5. Three rule types: Constraint (guard),
	#    Derivation (auto-generate), Validation (verify)
