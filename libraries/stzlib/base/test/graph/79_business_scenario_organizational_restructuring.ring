# Narrative
# --------
# Business scenario: Organizational restructuring
#
# Extracted from stzgraphtest.ring, block #79.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oBaseline = new stzGraph("old_structure")
oBaseline {
	AddNodeXT("ceo", "CEO")
	AddNodeXT("vp_eng", "VP Engineering")
	AddNodeXT("vp_sales", "VP Sales")
	AddNodeXT("team_a", "Team A")
	AddNodeXT("team_b", "Team B")
	AddNodeXT("team_c", "Team C")
	
	Connect("ceo", "vp_eng")
	Connect("ceo", "vp_sales")
	Connect("vp_eng", "team_a")
	Connect("vp_eng", "team_b")
	Connect("vp_sales", "team_c")
	
	SetNodeProperty("vp_eng", "reports", 2)
	SetNodeProperty("vp_sales", "reports", 1)
}

oVariation = oBaseline.Copy()
oVariation {
	# Restructuring: add COO layer
	AddNodeXT("coo", "Chief Operating Officer")
	
	# Reroute reporting
	RemoveThisEdge("ceo", "vp_eng")
	RemoveThisEdge("ceo", "vp_sales")
	Connect("ceo", "coo")
	Connect("coo", "vp_eng")
	Connect("coo", "vp_sales")
	
	# Add new department
	AddNodeXT("vp_product", "VP Product")
	Connect("coo", "vp_product")
	
	# Update properties
	SetNodeProperty("vp_eng", "reports", 2)
	SetNodeProperty("vp_sales", "reports", 1)
	SetNodeProperty("vp_product", "reports", 0)
}

aDiff = oBaseline.CompareWith(oVariation)
? @@NL( aDiff )
#-->
`
[
	[
		"summary",
		[
			[ "nodesadded", 2 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 2 ],
			[ "edgesremoved", 4 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[
				"added",
				[ "coo", "vp_product" ]
			],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"edges",
		[
			[
				"added",
				[
					[
						[ "from", "ceo" ],
						[ "to", "vp_eng" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "vp_sales" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[
				"removed",
				[
					[
						[ "from", "ceo" ],
						[ "to", "coo" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_eng" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_sales" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_product" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[
				"modified",
				[
					[
						[ "from", "vp_eng" ],
						[ "to", "team_a" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "vp_eng" ],
						[ "to", "team_a" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "vp_eng" ],
						[ "to", "team_b" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "vp_eng" ],
						[ "to", "team_b" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "vp_sales" ],
						[ "to", "team_c" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "vp_sales" ],
						[ "to", "team_c" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "coo" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "coo" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_eng" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_eng" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_sales" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_sales" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_product" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "coo" ],
						[ "to", "vp_product" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 6 ],
					[ "to", 8 ],
					[ "change", "+33.33%" ],
					[ "delta", 2 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 5 ],
					[ "to", 7 ],
					[ "change", "+40%" ],
					[ "delta", 2 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.17 ],
					[ "to", 0.12 ],
					[ "change", "-25.00%" ],
					[ "delta", -0.04 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 5 ],
					[ "to", 7 ],
					[ "change", "+40%" ],
					[ "delta", 2 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", "FALSE" ],
					[ "to", "FALSE" ],
					[ "change", "unchanged" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 1.67 ],
					[ "to", 1.75 ],
					[ "change", "+5.00%" ],
					[ "delta", 0.08 ]
				]
			]
		]
	],
	[
		"topology",
		[
			[
				"bottlenecks",
				[
					[
						"from",
						[ "ceo", "vp_eng", "vp_sales" ]
					],
					[
						"to",
						[ "vp_eng", "vp_sales", "coo" ]
					],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 1 ],
					[ "to", 1 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"isolatednodes",
				[
					[ "from", [  ] ],
					[ "to", [  ] ],
					[ "change", "unchanged" ]
				]
			]
		]
	],
	[
		"impact",
		[
			[
				"reachabilitychanges",
				[
					[ "ceo", "Can now reach 2 more node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[
						"ceo",
						"Criticality decreased (degree 2 → 1)"
					],
					[ "coo", "New critical node (degree 4)" ]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Added 2 node(s) and 2 edge(s)",
			"Removed 4 edge(s)",
			"Density -25.00%"
		]
	]
]
`

pf()
# Executed in 0.47 second(s) in Ring 1.24

#------------------------#
#   GRAPH FRAGMENTATION  #
#------------------------#
