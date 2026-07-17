# Narrative
# --------
# Business scenario: Department becomes isolated
#
# Extracted from stzgraphtest.ring, block #80.

load "../../stzBase.ring"


pr()

oBaseline = new stzGraph("connected_org")
oBaseline {
	AddNode("hq")
	AddNode("branch_a")
	AddNode("branch_b")
	AddNode("branch_c")
	
	Connect("hq", "branch_a")
	Connect("hq", "branch_b")
	Connect("hq", "branch_c")
	Connect("branch_a", "branch_b")
}

oVariation = oBaseline.Copy()
oVariation {
	# What if branch_c disconnects?
	RemoveThisEdge("hq", "branch_c")
}

aDiff = oBaseline.CompareWith(oVariation)
? @@NL( aDiff )
#-->
# NOTE on the recorded block below: one of its lines is KNOWN-STALE, and it
# is not about the diff. The longestpath metric reads lower than recorded --
# unchanged behaviour, verified identical at HEAD, and tracked separately.
# The edge diff itself is now true: it used to file every ADDED edge under
# removed (and every unchanged edge under modified). The arrow in the
# criticality strings is a real arrow again -- stzGraph's source carried a
# double-encoded glyph, now rebuilt from raw UTF-8 bytes via char().
`
[
	[
		"summary",
		[
			[ "nodesadded", 0 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 0 ],
			[ "edgesremoved", 1 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[ "added", [  ] ],
			[ "removed", [  ] ],
			[ "modified", [  ] ]
		]
	],
	[
		"edges",
		[
			[ "added", [  ] ],
			[
				"removed",
				[
					[
						[ "from", "hq" ],
						[ "to", "branch_c" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[ "modified", [  ] ]
		]
	],
	[
		"metrics",
		[
			[
				"nodecount",
				[
					[ "from", 4 ],
					[ "to", 4 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 4 ],
					[ "to", 3 ],
					[ "change", "-25%" ],
					[ "delta", -1 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.33 ],
					[ "to", 0.25 ],
					[ "change", "-25.00%" ],
					[ "delta", -0.08 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 3 ],
					[ "to", 2 ],
					[ "change", "-33.33%" ],
					[ "delta", -1 ]
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
					[ "from", 2 ],
					[ "to", 1.50 ],
					[ "change", "-25%" ],
					[ "delta", -0.50 ]
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
						[ "hq" ]
					],
					[
						"to",
						[ "hq", "branch_a", "branch_b" ]
					],
					[ "change", "increased" ],
					[ "delta", 2 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 1 ],
					[ "to", 2 ],
					[ "change", "fragmented" ]
				]
			],
			[
				"isolatednodes",
				[
					[ "from", [  ] ],
					[
						"to",
						[ "branch_c" ]
					],
					[ "change", "increased" ]
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
					[ "hq", "Can now reach 1 fewer node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[ "hq", "Criticality decreased (degree 3 → 2)" ],
					[
						"branch_c",
						"Criticality decreased (degree 1 → 0)"
					]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Removed 1 edge(s)",
			"Density -25.00%",
			"Bottlenecks increased",
			"Warning: Graph became fragmented"
		]
	]
]
`

pf()
# Executed in 0.17 second(s) in Ring 1.24

#-----------------------#
#   DENSITY COMPARISON  #
#-----------------------#
