# Narrative
# --------
# Multiple validators
#
# Extracted from stzorgcharttest.ring, block #15.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    ReportsTo("vp1", "ceo")
    
    ? @@NL( ValidateXT(["soc", "vacancy"]) )
 
}
#-->
'
[
	[ "status", "fail" ],
	[ "validatorsrun", 2 ],
	[ "validatorsfailed", 1 ],
	[ "totalissues", 2 ],
	[
		"results",
		[
			[
				[ "status", "pass" ],
				[ "domain", "span_of_control" ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "fail" ],
				[ "domain", "vacancy" ],
				[ "issuecount", 2 ],
				[
					"issues",
					[ "Vacant positions: 2" ]
				],
				[
					"affectednodes",
					[ "ceo", "vp1" ]
				]
			]
		]
	],
	[
		"affectednodes",
		[ "ceo", "vp1" ]
	]
]
'

pf()

#=================#
#  VISUALIZATION  #
#=================#
