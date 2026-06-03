# Narrative
# --------
# pr()
#
# Extracted from stzknowledgegraphtest.ring, block #17.
#ERR Error (R3) : Calling Function without definition: loadrulebase

load "../../stzBase.ring"

pr()

# Load from file
oBank = new stzOrgChart("Softabank")
oBank {
    LoadOrgChart("../_data/softabank.stzorg")
    LoadRuleBase("bceao_complete.stzrulz")
    
    # Or combine multiple sources
    LoadRuleBase("banking")   # Pre-built class
    LoadRuleBase(new stzSOXRuleBase())  # Direct object
    LoadRuleBase("custom_rules.stzrulz")  # File
    
    # Same API works
    ? IsValid()
    ? @@NL( Validate() )
    ? @@NL( ValidateXT(:bceao) )
}

#-->
`
0
[
	[ "status", "fail" ],
	[ "validatorsrun", 5 ],
	[ "validatorsfailed", 2 ],
	[ "totalissues", 10 ],
	[
		"results",
		[
			[
				[ "status", "pass" ],
				[ "domain", "BCEAO_governance" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "segregation_of_duties" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "span_of_control" ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "fail" ],
				[ "domain", "vacancy" ],
				[ "issuecount", 4 ],
				[
					"issues",
					[ "Vacant positions: 4" ]
				],
				[
					"affectednodes",
					[
						"board",
						"cro",
						"cto",
						"security_manager"
					]
				]
			],
			[
				[ "status", "fail" ],
				[ "domain", "succession" ],
				[ "issuecount", 6 ],
				[
					"issues",
					[
						"No successor: ",
						"ceo",
						"No successor: ",
						"cfo",
						"No successor: ",
						"treasury_head"
					]
				],
				[
					"affectednodes",
					[ "ceo", "cfo", "treasury_head" ]
				]
			]
		]
	],
	[
		"affectednodes",
		[
			"board",
			"cro",
			"cto",
			"security_manager",
			"ceo",
			"cfo",
			"treasury_head"
		]
	]
]
`

#-->
`
[
	[ "status", "pass" ],
	[ "domain", "BCEAO_governance" ],
	[ "issuecount", 0 ],
	[ "issues", [  ] ]
]
`

pf()
