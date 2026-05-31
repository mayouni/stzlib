# Narrative
# --------
# Business scenario: Downsizing
#
# Extracted from stzgraphtest.ring, block #75.

load "../../../stzBase.ring"


pr()

oBaseline = new stzGraph("full_org")
oBaseline {
	AddNode("ceo")
	AddNode("dept_a")
	AddNode("dept_b")
	AddNode("dept_c")
	AddNode("contractor_1")
	AddNode("contractor_2")
	
	Connect("ceo", "dept_a")
	Connect("ceo", "dept_b")
	Connect("ceo", "dept_c")
	Connect("dept_a", "contractor_1")
	Connect("dept_b", "contractor_2")
}

oVariation = oBaseline.Copy()
oVariation {
	# What if we remove contractors?
	RemoveThisNode("contractor_1")
	RemoveThisNode("contractor_2")
}

aDiff = oBaseline.CompareWith(oVariation)
? @@NL( aDiff )
#-->
`
[
	[
		"summary",
		[
			[ "nodesadded", 0 ],
			[ "nodesremoved", 2 ],
			[ "edgesadded", 2 ],
			[ "edgesremoved", 0 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[ "added", [  ] ],
			[
				"removed",
				[ "contractor_1", "contractor_2" ]
			],
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
						[ "from", "dept_a" ],
						[ "to", "contractor_1" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "dept_b" ],
						[ "to", "contractor_2" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[ "removed", [  ] ],
			[
				"modified",
				[
					[
						[ "from", "ceo" ],
						[ "to", "dept_a" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "dept_a" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "dept_b" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "dept_b" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "dept_c" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "ceo" ],
						[ "to", "dept_c" ],
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
					[ "to", 4 ],
					[ "change", "-33.33%" ],
					[ "delta", -2 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 5 ],
					[ "to", 3 ],
					[ "change", "-40%" ],
					[ "delta", -2 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.17 ],
					[ "to", 0.25 ],
					[ "change", "+50.00%" ],
					[ "delta", 0.08 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 5 ],
					[ "to", 3 ],
					[ "change", "-40%" ],
					[ "delta", -2 ]
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
					[ "to", 1.50 ],
					[ "change", "-10.00%" ],
					[ "delta", -0.17 ]
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
						[ "ceo", "dept_a", "dept_b" ]
					],
					[
						"to",
						[ "ceo" ]
					],
					[ "change", "reduced" ],
					[ "delta", -2 ]
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
					[ "ceo", "Can now reach 2 fewer node(s)" ],
					[ "dept_a", "Can now reach 1 fewer node(s)" ],
					[ "dept_b", "Can now reach 1 fewer node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[
						"dept_a",
						"Criticality decreased (degree 2 → 1)"
					],
					[
						"dept_b",
						"Criticality decreased (degree 2 → 1)"
					]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Added 2 edge(s)",
			"Removed 2 node(s)",
			"Density +50.00%",
			"Bottlenecks reduced (improvement)"
		]
	]
]
`

pf()
# Executed in 0.22 second(s) in Ring 1.25
# Executed in 0.26 second(s) in Ring 1.24

#-----------------------#
#   MODIFY PROPERTIES   #
#-----------------------#
