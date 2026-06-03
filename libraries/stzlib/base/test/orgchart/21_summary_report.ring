# Narrative
# --------
# Summary report
#
# Extracted from stzorgcharttest.ring, block #21.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp1, "VP")
    AddStaffXT(:@dev1, "Dev")
    
    ? @@NL( SummaryReport() )
}
#-->
'
[
	[ "title", "Organizational Summary" ],
	[ "date", "03/12/2025" ],
	[
		"metrics",
		[
			[ "totalpositions", 3 ],
			[ "filledpositions", 0 ],
			[ "vacancyrate", 100 ],
			[ "avgspan", 0 ],
			[
				"levels",
				[
					[
						"executive",
						[ "ceo" ]
					],
					[
						"management",
						[ "vp1" ]
					],
					[
						"staff",
						[ "dev1" ]
					]
				]
			]
		]
	]
]
'

pf()
