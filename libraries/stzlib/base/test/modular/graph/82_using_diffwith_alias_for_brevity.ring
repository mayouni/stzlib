# Narrative
# --------
# Using DiffWith() alias for brevity
#
# Extracted from stzgraphtest.ring, block #82.

load "../../../stzBase.ring"


pr()

oA = new stzGraph("simple")
oA {
	AddNode("x")
	AddNode("y")
	Connect("x", "y")
}

oB = oA.Copy()
oB.AddNode("z")
oB.Connect("y", "z")

aDiff = oA.DiffWith(oB)
? @@NL(aDiff)
#-->
`
[
	[
		"summary",
		[
			[ "nodesadded", 1 ],
			[ "nodesremoved", 0 ],
			[ "edgesadded", 0 ],
			[ "edgesremoved", 1 ],
			[ "propertieschanged", 0 ]
		]
	],
	[
		"nodes",
		[
			[
				"added",
				[ "z" ]
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
						[ "from", "y" ],
						[ "to", "z" ],
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
					[ "from", 2 ],
					[ "to", 3 ],
					[ "change", "+50%" ],
					[ "delta", 1 ]
				]
			],
			[
				"edgecount",
				[
					[ "from", 1 ],
					[ "to", 2 ],
					[ "change", "+100%" ],
					[ "delta", 1 ]
				]
			],
			[
				"density",
				[
					[ "from", 0.50 ],
					[ "to", 0.33 ],
					[ "change", "-33.33%" ],
					[ "delta", -0.17 ]
				]
			],
			[
				"longestpath",
				[
					[ "from", 1 ],
					[ "to", 2 ],
					[ "change", "+100%" ],
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
					[ "from", 1 ],
					[ "to", 1.33 ],
					[ "change", "+33.33%" ],
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
					[ "from", [  ] ],
					[
						"to",
						[ "y" ]
					],
					[ "change", "increased" ],
					[ "delta", 1 ]
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
					[ "x", "Can now reach 1 more node(s)" ],
					[ "y", "Can now reach 1 more node(s)" ]
				]
			],
			[
				"criticalitychanges",
				[
					[ "y", "Criticality increased (degree 1 → 2)" ]
				]
			]
		]
	],
	[
		"explanation",
		[
			"Added 1 node(s)",
			"Removed 1 edge(s)",
			"Density -33.33%",
			"Bottlenecks increased"
		]
	]
]
`

pf()
" Executed in 0.06 second(s) in Ring 1.25
# Executed in 0.12 second(s) in Ring 1.24

#============================================#
#  stzGraph Serialization Format Examples    #
#  Shows final output of each format         #
#============================================#

# SUMMARY OF FORMATS
#-------------------

# .stzgraf  - Graph structure (nodes/edges/properties)
# .stzrulz  - Rule definitions (properties)
# .stzrulf  - Rule functions (Ring code)
# .stzsim   - Simulations (change sets)

# Usage pattern:
#  1. Define graph → .stzgraf
#  2. Define custom functions → .stzrulf
#  3. Define rules → .stzrulz (references .stzrulf)
#  4. Apply changes → .stzsim

# Benefits:
# • Separation of data and logic"
# • Version control friendly"
# • Plugin-like extensibility"
# • Human-readable formats"

#---------------------------#
#  1. supply_chain.stzgraf  #
#    Pure graph structure   #
#===========================#

# EXAMPLE OF .stzgraf file content
#---------------------------------
`
graph "Global_Supply_Chain"
    type: directed

nodes
    warehouse_ny
    warehouse_la
    factory_cn
    factory_mx
    distributor_eu

edges
    factory_cn -> warehouse_ny
    factory_cn -> warehouse_la
    factory_mx -> warehouse_la
    warehouse_ny -> distributor_eu
    warehouse_la -> distributor_eu

properties
    warehouse_ny
        capacity: 50000
        location: "New York"
        status: active

    warehouse_la
        capacity: 45000
        location: "Los Angeles"
        status: active

    factory_cn
        output: 100000
        location: Shenzhen
        cost_per_unit: 2.5

    factory_mx
        output: 75000
        location: Monterrey
        cost_per_unit: 3.2

    distributor_eu
        coverage: Europe
        demand: 75000
`
