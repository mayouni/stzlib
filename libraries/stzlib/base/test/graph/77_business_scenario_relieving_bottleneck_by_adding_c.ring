# Narrative
# --------
# Business scenario: Relieving bottleneck by adding cache layer
#
# Extracted from stzgraphtest.ring, block #77.

load "../../stzBase.ring"


pr()

oBaseline = new stzGraph("api_architecture")
oBaseline {
	AddNode("client")
	AddNode("api")
	AddNode("db")
	AddNode("backup_db")
	
	Connect("client", "api")
	Connect("api", "db")
	Connect("api", "backup_db")
	Connect("db", "backup_db")
}

oVariation = oBaseline.Copy()
oVariation {
	# What if we add caching layer?
	AddNode("cache")
	
	# Reroute some connections through cache
	RemoveThisEdge("api", "db")
	Connect("api", "cache")
	Connect("cache", "db")
}

aDiff = oBaseline.CompareWith(oVariation)
? @@NL( aDiff )
#-->
'
[
	[
		"summary",
		[
			[ "nodesadded", 1 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 1 ],
			[ "edgesremoved", 2 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[
				"added",
				[ "cache" ]
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
						[ "from", "api" ],
						[ "to", "db" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[
				"removed",
				[
					[
						[ "from", "api" ],
						[ "to", "cache" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "cache" ],
						[ "to", "db" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					]
				]
			],
			[
				"modified",
				[
					[
						[ "from", "client" ],
						[ "to", "api" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "api" ],
						[ "to", "backup_db" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "db" ],
						[ "to", "backup_db" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "api" ],
						[ "to", "cache" ],
						[ "label", "" ],
						[ "properties", [  ] ]
					],
					[
						[ "from", "cache" ],
						[ "to", "db" ],
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
					[ "from", 4 ],
					[ "to", 5 ],
					[ "change", "+25%" ],
					[ "delta", 1 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 4 ],
					[ "to", 5 ],
					[ "change", "+25%" ],
					[ "delta", 1 ]
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
					[ "to", 4 ],
					[ "change", "+33.33%" ],
					[ "delta", 1 ]
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
					[ "to", 2 ],
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
						[ "api" ]
					],
					[
						"to",
						[ "api" ]
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
					[ "client", "Can now reach 1 more node(s)" ],
					[ "api", "Can now reach 1 more node(s)" ]
				]
			],
			[ "criticalitychanges", [  ] ]
		]
	],
	[
		"explanation",
		[
			"Added 1 node(s) and 1 edge(s)",
			"Removed 2 edge(s)",
			"Density -25.00%"
		]
	]
]
'

pf()
# Executed in 0.21 second(s) in Ring 1.24

#-----------------------#
#   CYCLE INTRODUCTION  #
#-----------------------#
