# Narrative
# --------
# Business scenario: Comparing sparse vs dense structure
#
# Extracted from stzgraphtest.ring, block #81.

load "../../../stzBase.ring"


pr()

oSparse = new stzGraph("sparse_hierarchy")
oSparse {
	AddNode("top")
	AddNode("mid1")
	AddNode("mid2")
	AddNode("bot1")
	AddNode("bot2")
	
	Connect("top", "mid1")
	Connect("top", "mid2")
	Connect("mid1", "bot1")
	Connect("mid2", "bot2")
}

oDense = new stzGraph("dense_mesh")
oDense {
	AddNodes([ "top", "mid1", "mid2", "bot1", "bot2" ])
	
	# Fully connected
	Connect("top", "mid1")	#TODO // Add ConnectToMany("top", [ "mid1", ...])
	Connect("top", "mid2")
	Connect("top", "bot1")
	Connect("top", "bot2")

	Connect("mid1", "mid2")
	Connect("mid1", "bot1")
	Connect("mid1", "bot2")
	Connect("mid2", "bot1")

	Connect("mid2", "bot2")
	Connect("bot1", "bot2")
}

aDiff = oSparse.CompareWith(oDense)
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
			[ "edgesremoved", 6 ],
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
						[ "from", "top" ],
						[ "to", "bot1" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "top" ],
						[ "to", "bot2" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "mid1" ],
						[ "to", "mid2" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "mid1" ],
						[ "to", "bot2" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "mid2" ],
						[ "to", "bot1" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "bot1" ],
						[ "to", "bot2" ],
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
					[ "from", 5 ],
					[ "to", 5 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 4 ],
					[ "to", 10 ],
					[ "change", "+150%" ],
					[ "delta", 6 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.20 ],
					[ "to", 0.50 ],
					[ "change", "+150.00%" ],
					[ "delta", 0.30 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 4 ],
					[ "to", 4 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
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
					[ "from", 1.60 ],
					[ "to", 4 ],
					[ "change", "+150.00%" ],
					[ "delta", 2.40 ]
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
						[ "top", "mid1", "mid2" ]
					],
					[ "to", [  ] ],
					[ "change", "reduced" ],
					[ "delta", -3 ]
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
					[ "mid1", "Can now reach 2 more node(s)" ],
					[ "mid2", "Can now reach 1 more node(s)" ],
					[ "bot1", "Can now reach 1 more node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[
						"top",
						"Criticality increased (degree 2 → 4)"
					],
					[
						"mid1",
						"Criticality increased (degree 2 → 4)"
					],
					[
						"mid2",
						"Criticality increased (degree 2 → 4)"
					],
					[
						"bot1",
						"Criticality increased (degree 1 → 4)"
					],
					[
						"bot2",
						"Criticality increased (degree 1 → 4)"
					]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Removed 6 edge(s)",
			"Density +150.00%",
			"Bottlenecks reduced (improvement)"
		]
	]
]
`

pf()
# Executed in 0.28 second(s) in Ring 1.24

#-----------------------#
#   QUICK COMPARISON    #
#-----------------------#
