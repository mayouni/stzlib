# Narrative
# --------
# Business scenario: Creating circular dependency (warning)
#
# Extracted from stzgraphtest.ring, block #78.

load "../../stzBase.ring"


pr()

oBaseline = new stzGraph("workflow")
oBaseline {
	AddNode("Constraint")
	AddNode("develop")
	AddNode("test")
	AddNode("deploy")
	
	Connect("Constraint", "develop")
	Connect("develop", "test")
	Connect("test", "deploy")
}

oVariation = oBaseline.Copy()
oVariation {
	# What if we add feedback loop?
	Connect("deploy", "Constraint")  # Creates cycle!
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
						[ "from", "deploy" ],
						[ "to", "Constraint" ],
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
					[ "from", 3 ],
					[ "to", 4 ],
					[ "change", "+33.33%" ],
					[ "delta", 1 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.25 ],
					[ "to", 0.33 ],
					[ "change", "+33.33%" ],
					[ "delta", 0.08 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 3 ],
					[ "to", 3 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", "FALSE" ],
					[ "to", "TRUE" ],
					[ "change", "now TRUE" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 1.50 ],
					[ "to", 2 ],
					[ "change", "+33.33%" ],
					[ "delta", 0.50 ]
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
						[ "develop", "test" ]
					],
					[ "to", [  ] ],
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
					[ "develop", "Can now reach 1 more node(s)" ],
					[ "test", "Can now reach 2 more node(s)" ],
					[ "deploy", "Can now reach 3 more node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[
						"Constraint",
						"Criticality increased (degree 1 → 2)"
					],
					[
						"deploy",
						"Criticality increased (degree 1 → 2)"
					]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Removed 1 edge(s)",
			"Density +33.33%",
			"Bottlenecks reduced (improvement)"
		]
	]
]
`

pf()
# Executed in 0.12 second(s) in Ring 1.25
# Executed in 0.14 second(s) in Ring 1.24

#-----------------------#
#   COMPLEX SCENARIO    #
#-----------------------#
