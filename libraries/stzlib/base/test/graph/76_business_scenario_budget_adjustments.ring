# Narrative
# --------
# Business scenario: Budget adjustments
#
# Extracted from stzgraphtest.ring, block #76.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oBaseline = new stzGraph("budget_plan")
oBaseline {
	AddNodeXT("sales", "Sales Department")
	AddNodeXT("engineering", "Engineering")
	AddNodeXT("marketing", "Marketing")
	
	SetNodeProperty("sales", "budget", 100000)
	SetNodeProperty("sales", "headcount", 5)
	SetNodeProperty("engineering", "budget", 200000)
	SetNodeProperty("engineering", "headcount", 10)
	SetNodeProperty("marketing", "budget", 80000)
	SetNodeProperty("marketing", "headcount", 3)
}

oVariation = oBaseline.Copy()
oVariation {
	# What if we increase sales budget?
	SetNodeProperty("sales", "budget", 150000)
	SetNodeProperty("sales", "headcount", 8)
	
	# And reduce marketing?
	SetNodeProperty("marketing", "budget", 60000)
}

aDiff = oBaseline.CompareWith(oVariation)
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
			[ "propertieschanged", 2 ]
		]
	],
	[
		"nodes",
		[
			[ "added", [  ] ],
			[ "removed", [  ] ],
			[
				"modified",
				[
					[
						"sales",
						[
							[
								"property",
								"budget",
								100000,
								150000
							],
							[
								"property",
								"headcount",
								5,
								8
							]
						]
					],
					[
						"marketing",
						[
							[
								"property",
								"budget",
								80000,
								60000
							]
						]
					]
				]
			]
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
					[ "from", 0 ],
					[ "to", 0 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"density",
				[
					[ "from", 0 ],
					[ "to", 0 ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 0 ],
					[ "to", 0 ],
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
					[ "from", 0 ],
					[ "to", 0 ],
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
					[ "from", [  ] ],
					[ "to", [  ] ],
					[ "change", "unchanged" ],
					[ "delta", 0 ]
				]
			],
			[
				"connectedcomponents",
				[
					[ "from", 3 ],
					[ "to", 3 ],
					[ "change", "unchanged" ]
				]
			],
			[
				"isolatednodes",
				[
					[
						"from",
						[ "sales", "engineering", "marketing" ]
					],
					[
						"to",
						[ "sales", "engineering", "marketing" ]
					],
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
		[ "Modified 2 node propertie(s)" ]
	]
]
'

pf()
# Executed in 0.04 second(s) in Ring 1.24

#-----------------------#
#   BOTTLENECK CHANGES  #
#-----------------------#
