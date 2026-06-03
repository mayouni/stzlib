# Narrative
# --------
# Succession report
#
# Extracted from stzorgcharttest.ring, block #24.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP Sales")
    ReportsTo("vp1", "ceo")

    ? @@NL( ComplianceReport() )
}
#-->
'
[
	[ "title", "Compliance Status Report" ],
	[ "date", "03/12/2025" ],
	[
		"checks",
		[
			[
				[ "status", "fail" ],
				[ "domain", "BCEAO_governance" ],
				[ "issuecount", 2 ],
				[
					"issues",
					[
						"BCEAO-001: No Board of Directors found",
						"BCEAO-003: No dedicated Risk Management function"
					]
				]
			],
			[
				[ "status", "pass" ],
				[ "domain", "span_of_control" ],
				[ "issues", [  ] ]
			],
			[
				[ "status", "pass" ],
				[ "domain", "segregation_of_duties" ],
				[ "issuecount", 0 ],
				[ "issues", [  ] ]
			]
		]
	],
	[ "overallstatus", "non-compliant" ],
	[ "failedchecks", 1 ]
]
'

pf()
