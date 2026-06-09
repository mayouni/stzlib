# Narrative
# --------
# Converting comparison to table for further analysis
#
# Extracted from stzgraphtest.ring, block #71.
#ERR Error (C22) : Function redefinition, function is already defined!

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

# Using same baseline and variations from previous example

oMatrix = oBaseline.CompareWithManyQR([
	["Add_COO_Layer", oOptionA],
	["Flat_Structure", oOptionB],
	["Matrix_Org", oOptionC]
], :stzGraphComparison)

oMatrix.Show()
#-->
'
╭──────────────────┬───────────────┬────────────────┬────────────╮
│      Metric      │ Add_coo_layer │ Flat_structure │ Matrix_org │
├──────────────────┼───────────────┼────────────────┼────────────┤
│ NodesAdded       │             1 │              2 │          1 │
│ NodesRemoved     │             0 │              0 │          0 │
│ EdgesAdded       │             2 │              0 │          0 │
│ EdgesRemoved     │             3 │              2 │          3 │
│ DensityChange    │ -20.00%       │ -33.33%        │ +20.00%    │
│ HasCycles        │ FALSE         │ FALSE          │ FALSE      │
│ BottleneckChange │ increased     │ unchanged      │ increased  │
╰──────────────────┴───────────────┴────────────────┴────────────╯
'

? ""
? oMatrix.MostImpactful() + NL
#--> Add_COO_Layer

? oMatrix.LeastImpactful() + NL
#--> Flat_Structure

? @@NL( oMatrix.Recommend() )
#-->
'
[
	[ "recommended", "Matrix_Org" ],
	[
		"reason",
		"Best balance of structure, connectivity, and acyclicity"
	]
]
'

pf()
# Executed in 0.49 second(s) in Ring 1.25
# Executed in 0.59 second(s) in Ring 1.24

#------------------------------------#
#   FILTERING AND SORTING VARIATIONS #
#------------------------------------#
