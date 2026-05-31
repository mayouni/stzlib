# Narrative
# --------
# Comparing identical graphs should show no changes
#
# Extracted from stzgraphtest.ring, block #69.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("org")
oGraph {
	AddNode("ceo")
	AddNode("manager")
	AddNode("dev")
	
	Connect("ceo", "manager")
	Connect("manager", "dev")
}

oVariation = oGraph.Copy()

aDiff = oGraph.CompareWith(oVariation)
? @@NL( aDiff )
#-->
'
[
	[
		"summary",
		[
			[ "nodesadded", 0 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 0 ],
			[ "edgesremoved", 0 ],
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
			[ "removed", [  ] ],
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
					[ "to", 3 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 2 ],
					[ "to", 2 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.33 ],
					[ "to", 0.33 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 2 ],
					[ "to", 2 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"hascycles",
				[
					[ "from", 0 ],
					[ "to", 0 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"avgdegree",
				[
					[ "from", 1.33 ],
					[ "to", 1.33 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
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
						[ "manager" ]
					],
					[
						"to",
						[ "manager" ]
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
			[ "reachabilitychanges", [  ] ],
			[ "criticalitychanges", [  ] ]
		]
	],
	[
		"explanation",
		[ "No significant changes detected" ]
	]
]
'
pf()
# Executed in 0.08 second(s) in Ring 1.24

#-----------------------------------#
#   COMPARING MULTIPLE VARIATIONS   #
#-----------------------------------#
