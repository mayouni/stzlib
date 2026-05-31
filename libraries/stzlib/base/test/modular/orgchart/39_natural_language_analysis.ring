# Narrative
# --------
# Natural language analysis
#
# Extracted from stzorgcharttest.ring, block #39.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    AddStaffXT("dev1", "Dev")
    
    ? @@NL( Explain() )
}
#-->
`
[
	[ "type", "Organization Chart" ],
	[
		"structure",
		"Organization 'TechCo' has 3 positions, 0 people, and 0 departments."
	],
	[
		"hierarchy",
		[
			"executive: 1 positions",
			"management: 1 positions",
			"staff: 1 positions",
			"Average span of control: 0"
		]
	],
	[
		"staffing",
		[
			"Vacancy rate: 100%",
			"Vacant positions: ceo, vp1, dev1"
		]
	],
	[
		"compliance",
		[
			"Found 2 compliance issues",
			"BCEAO: BCEAO-001: No Board of Directors found; BCEAO-003: No dedicated Risk Management function"
		]
	],
	[
		"risks",
		[ "No succession risks identified" ]
	],
	[
		"efficiency",
		[
			"Span of control may be underutilized (< 3 reports average)",
			"HIGH vacancy rate - may impact operations"
		]
	]
]
`

pf()
