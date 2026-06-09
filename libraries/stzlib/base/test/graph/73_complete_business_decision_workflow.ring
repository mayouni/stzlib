# Narrative
# --------
# Complete business decision workflow
#
# Extracted from stzgraphtest.ring, block #73.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

? BoxRound("SCENARIO: ORGANIZATIONAL RESTRUCTURING") + NL

# Current structure
oBaseline = new stzGraph("Q4_2024")
oBaseline {
	AddNodeXT("ceo", "CEO")
	AddNodeXT("vp_sales", "VP Sales")
	AddNodeXT("vp_eng", "VP Engineering")
	AddNodeXT("team_a", "Team A")
	AddNodeXT("team_b", "Team B")
	
	Connect("ceo", "vp_sales")
	Connect("ceo", "vp_eng")
	Connect("vp_eng", "team_a")
	Connect("vp_eng", "team_b")
	
	SetNodeProperty("vp_eng", "reports", 2)
	SetNodeProperty("vp_sales", "reports", 0)
}

? "Current structure:"
? "  Nodes: " + oBaseline.NodeCount()
? "  Edges: " + oBaseline.EdgeCount()
? "  Density: " + oBaseline.NodeDensity()
? ""

# Create 4 different scenarios

# Scenario 1: Add COO
oScenario1 = oBaseline.Copy()
oScenario1 {
	AddNodeXT("coo", "COO")
	RemoveThisEdge("ceo", "vp_sales")
	RemoveThisEdge("ceo", "vp_eng")
	Connect("ceo", "coo")
	Connect("coo", "vp_sales")
	Connect("coo", "vp_eng")
}

# Scenario 2: Add product team
oScenario2 = oBaseline.Copy()
oScenario2 {
	AddNodeXT("vp_product", "VP Product")
	AddNodeXT("product_team", "Product Team")
	Connect("ceo", "vp_product")
	Connect("vp_product", "product_team")
}

# Scenario 3: Flatten hierarchy
oScenario3 = oBaseline.Copy()
oScenario3 {
	RemoveThisEdge("vp_eng", "team_a")
	RemoveThisEdge("vp_eng", "team_b")
	Connect("ceo", "team_a")
	Connect("ceo", "team_b")
}

# Scenario 4: Add cross-functional
oScenario4 = oBaseline.Copy()
oScenario4 {
	Connect("vp_sales", "team_a")  # Cross-functional link
	Connect("vp_sales", "team_b")
}

# Compare all scenarios
oMatrix = oBaseline.CompareWithManyQR([
	["Add_COO", oScenario1],
	["Add_Product", oScenario2],
	["Flatten", oScenario3],
	["Cross_Functional", oScenario4]
], :stzGraphComparison)

? "4 scenarios have been added! Let's compare them..."
oMatrix.Show()

? "Most impactful: " + oMatrix.MostImpactful()
? "Least impactful: " + oMatrix.LeastImpactful()
? ""

? BoxRound("RECOMMENDATION")

? @@NL( oMatrix.Recommend() ) + NL

? BoxRound("DETAILED SUMMARY")

? @@NL( oMatrix.Summary() ) #TODO// listift the string output format

#-->
`
╭────────────────────────────────────────╮
│ SCENARIO: ORGANIZATIONAL RESTRUCTURING │
╰────────────────────────────────────────╯

Current structure:
  Nodes: 5
  Edges: 4
  Density: 0.20

4 scenarios have been added! Let's compare them...
╭──────────────────┬───────────┬─────────────┬───────────┬──────────────────╮
│      Metric      │  Add_coo  │ Add_product │  Flatten  │ Cross_functional │
├──────────────────┼───────────┼─────────────┼───────────┼──────────────────┤
│ NodesAdded       │         1 │           2 │         0 │                0 │
│ NodesRemoved     │         0 │           0 │         0 │                0 │
│ EdgesAdded       │         2 │           0 │         2 │                0 │
│ EdgesRemoved     │         3 │           2 │         2 │                2 │
│ DensityChange    │ -16.67%   │ -28.57%     │ unchanged │ +50.00%          │
│ HasCycles        │ FALSE     │ FALSE       │ FALSE     │ FALSE            │
│ BottleneckChange │ unchanged │ increased   │ reduced   │ unchanged        │
╰──────────────────┴───────────┴─────────────┴───────────┴──────────────────╯
Most impactful: Add_COO
Least impactful: Cross_Functional

╭────────────────╮
│ RECOMMENDATION │
╰────────────────╯
[
	[ "recommended", "Flatten" ],
	[
		"reason",
		"Best balance of structure, connectivity, and acyclicity"
	]
]

╭──────────────────╮
│ DETAILED SUMMARY │
╰──────────────────╯
Baseline: Q4_2024
Variations compared: 4

• Add_COO: Added 1 node(s) and 2 edge(s)
• Add_Product: Added 2 node(s)
• Flatten: Added 2 edge(s)
• Cross_Functional: Removed 2 edge(s)
`

pf()

#-----------------------#
#   ADD NODES ONLY      #
#-----------------------#
