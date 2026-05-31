# Narrative
# --------
# How to use .stzrulf file format?
#
# Extracted from stzgraphtest.ring, block #85.

load "../../../stzBase.ring"


pr()

# Loading custom functions
oGraph = new stzGraph("banking_system")

# Load the function definitions first
oGraph.LoadRuleFunctionsFrom("custom_functions.stzrulf")

# Then load the rules that reference them
oGraph.LoadFromStzRulz("compliance_rules.stzrulz")

# Now the custom functions are available
oGraph.UseRulesFrom(:banking)
oGraph.UseRulesFrom(:hr)

pf()

#-----------------------------------------#
#  4. restructure.stzsim                  #
#     Simulation (changes between graphs) #
#=========================================#

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

pr()

# How to use .stzsim file format?

# Loading baseline
oBaseline = new stzGraph("current_org")
oBaseline.LoadFromStzGraf("org_current.stzgraf")

# Applying simulation
cSimulation = read("restructure.stzsim")
oBaseline.ApplySimulation(cSimulation)

# After changes
? "  Nodes: " + oBaseline.NodeCount()
? "  Edges: " + oBaseline.EdgeCount()

pf()

#--------------------------------------------------#
# 5. Complete workflow example using file formats  #
#==================================================#

pr()

# Step 1: Create and save a graph

	oCompany = new stzGraph("MyCompany")
	oCompany {
		AddNodeXTT("ceo", "CEO", [:level = 5])
		AddNodeXTT("cto", "CTO", [:level = 4, :department = "tech"])
		AddNodeXTT("cfo", "CFO", [:level = 4, :department = "finance"])
		AddNodeXTT("eng1", "Engineer 1", [:level = 2, :department = "tech"])
		
		Connect("ceo", "cto")
		Connect("ceo", "cfo")
		Connect("cto", "eng1")
		
		? "Saving graph to supply_chain.stzgraf..."
		SaveToStzGraf("mycompany.stzgraf")
	}

# Step 2: Load custom functions

	load "custom_functions.stzrulf"

# Step 3: Load rules

	oCompany.LoadFromStzRulz("compliance_rules.stzrulz")

# Step 4: Apply rules

	oCompany.UseRulesFrom(:banking)
	nDerived = oCompany.ApplyDerivations()
	? "  Derived edges: " + nDerived

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
	write("add_coo.stzsim", cSim)
	? "  Saved to add_coo.stzsim"
	
	# Step 7: Validate
	? "Validating structure..."
	aResult = oVariation.Validate()
	? "  Valid: " + aResult[1]

pf()

#==================#
#  RAISING ERRORS  #
#==================#

pr()

oReseau = new stzGraph("Trounées Niamey")
#--> ERROR MESSAGE: Inncorrect Id! pcId must be a string without spaces nor new lines.

pf()

#============================================#
#  Query-Triggered Rules & Graph Projection  #
#============================================#

#--- Key Concepts explored in those samples:

	# 1. Rules are registered globally, loaded per-graph
	
	# 2. Queries match subsets of the graph, rules apply
	#    only to those matches
	
	# 3. ToGraphQ() = independent copy for analysis
	
	# 4. ToViewQ() = linked view with commit/rollback
	
	# 5. Three rule types: Constraint (guard),
	#    Derivation (auto-generate), Validation (verify)
