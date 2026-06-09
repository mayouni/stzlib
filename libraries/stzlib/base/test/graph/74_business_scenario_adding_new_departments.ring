# Narrative
# --------
# Business scenario: Adding new departments
#
# Extracted from stzgraphtest.ring, block #74.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oBaseline = new stzGraph("current_org")
oBaseline {
	AddNode("ceo")
	AddNode("sales")
	AddNode("engineering")
	
	Connect("ceo", "sales")
	Connect("ceo", "engineering")
}

oVariation = oBaseline.Copy()
oVariation {
	# What if we add new departments?
	AddNode("marketing")
	AddNode("hr")
	AddNode("finance")
	
	Connect("ceo", "marketing")
	Connect("ceo", "hr")
	Connect("ceo", "finance")
}

aDiff = oBaseline.CompareWith(oVariation) # Or Diff()
? @@NL( aDiff )
#-->
`
[
	[
		"summary",
		[
			[ "nodesadded", 3 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 0 ],
			[ "edgesremoved", 3 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[
				"added",
				[ "marketing", "hr", "finance" ]
			],
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
						[ "from", "ceo" ],
						[ "to", "marketing" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "hr" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "finance" ],
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
					[ "from", 3 ],
					[ "to", 6 ],
					[ "change", "+100%" ],
					[ "delta", 3 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 2 ],
					[ "to", 5 ],
					[ "change", "+150%" ],
					[ "delta", 3 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.33 ],
					[ "to", 0.17 ],
					[ "change", "-50%" ],
					[ "delta", -0.17 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 2 ],
					[ "to", 5 ],
					[ "change", "+150%" ],
					[ "delta", 3 ]
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
					[ "from", 1.33 ],
					[ "to", 1.67 ],
					[ "change", "+25.00%" ],
					[ "delta", 0.33 ]
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
						[ "ceo" ]
					],
					[
						"to",
						[ "ceo" ]
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
					[ "ceo", "Can now reach 3 more node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[
						"ceo",
						"Criticality increased (degree 2 → 5)"
					]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Added 3 node(s)",
			"Removed 3 edge(s)",
			"Density -50%"
		]
	]
]
`

pf()
# Executed in 0.14 second(s) in Ring 1.24

#------------------#
#   REMOVE NODES   #
#------------------#
