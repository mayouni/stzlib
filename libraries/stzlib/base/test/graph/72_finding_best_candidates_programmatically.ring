# Narrative
# --------
# Finding best candidates programmatically
#
# Extracted from stzgraphtest.ring, block #72.

load "../../stzBase.ring"


pr()

oBaseline = new stzGraph("current_structure")
oBaseline {
	AddNode("ceo")
	AddNode("sales")
	AddNode("engineering")
	AddNode("marketing")
	
	Connect("ceo", "sales")
	Connect("ceo", "engineering")
	Connect("ceo", "marketing")
}

# Option A: Add management layer
oOptionA = oBaseline.Copy()
oOptionA {
	AddNode("coo")
	RemoveThisEdge("ceo", "sales")
	RemoveThisEdge("ceo", "marketing")
	Connect("ceo", "coo")
	Connect("coo", "sales")
	Connect("coo", "marketing")
}

# Option B: Flat structure with more departments
oOptionB = oBaseline.Copy()
oOptionB {
	AddNode("hr")
	AddNode("finance")
	Connect("ceo", "hr")
	Connect("ceo", "finance")
}

# Option C: Matrix organization
oOptionC = oBaseline.Copy()
oOptionC {
	AddNode("operations")
	Connect("sales", "operations")
	Connect("engineering", "operations")
	Connect("marketing", "operations")
}

# Using same variations

oMatrix = oBaseline.CompareWithManyQR([
	["Add_COO_Layer", oOptionA],
	["Flat_Structure", oOptionB],
	["Matrix_Org", oOptionC]
], :stzGraphComparison)

# VARIATIONS WITHOUT CYCLES
? @@( oMatrix.WithoutCycles() ) + NL
#--> [ ]

# SORTED BY NODES ADDED
? @@(oMatrix.ByMetric(:NodesAdded)) + NL
#--> ["Flat_Structure", "Add_COO_Layer", "Matrix_Org"]

# SORTED BY EDGES ADDED
? @@(oMatrix.ByMetric(:EdgesAdded))
#--> [ "Add_COO_Layer", "Flat_Structure", "Matrix_Org" ]

pf()
# Executed in 0.49 second(s) in Ring 1.25
# Executed in 0.52 second(s) in Ring 1.24

#------------------------------------#
#   COMPREHENSIVE WHAT-IF SCENARIO   #
#------------------------------------#
