# Narrative
# --------
# Business analyst exploring 3 restructuring options
#
# Extracted from stzgraphtest.ring, block #70.

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

# Compare all at once with named variations
aComparison = oBaseline.CompareWithMany([
	["Add_COO_Layer", oOptionA],
	["Flat_Structure", oOptionB],
	["Matrix_Org", oOptionC]
])

? @@NL( aComparison )
#-->
'
[
	[
		"comparisons",
		[
			[
				[ "name", "Add_COO_Layer" ],
				[ "nodesadded", 1 ],
				[ "nodesremoved", 0 ],
				[ "edgesadded", 2 ],
				[ "edgesremoved", 3 ],
				[ "densitychange", "-20.00%" ],
				[ "hascycles", 0 ],
				[ "bottleneckchange", "increased" ],
				[ "explanation", "Added 1 node(s) and 2 edge(s)" ]
			],
			[
				[ "name", "Flat_Structure" ],
				[ "nodesadded", 2 ],
				[ "nodesremoved", 0 ],
				[ "edgesadded", 0 ],
				[ "edgesremoved", 2 ],
				[ "densitychange", "-33.33%" ],
				[ "hascycles", 0 ],
				[ "bottleneckchange", "unchanged" ],
				[ "explanation", "Added 2 node(s)" ]
			],
			[
				[ "name", "Matrix_Org" ],
				[ "nodesadded", 1 ],
				[ "nodesremoved", 0 ],
				[ "edgesadded", 0 ],
				[ "edgesremoved", 3 ],
				[ "densitychange", "+20.00%" ],
				[ "hascycles", 0 ],
				[ "bottleneckchange", "increased" ],
				[ "explanation", "Added 1 node(s)" ]
			]
		]
	],
	[ "baseline", "current_structure" ],
	[ "count", 3 ]
]
'

pf()
# Executed in 0.45 second(s) in Ring 1.24

#------------------------------------#
#   COMPARISON MATRIX AS SZTABLE     #
#------------------------------------#
