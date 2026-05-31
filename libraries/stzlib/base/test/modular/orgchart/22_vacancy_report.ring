# Narrative
# --------
# Vacancy report
#
# Extracted from stzorgcharttest.ring, block #22.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP Sales")
    
    ? @@NL(Vacant()) #--> [ "ceo", "vp1" ]

    ? @@NL( VacancyReport() )
}
#-->
'
[ "ceo", "vp1" ]
[
	[ "title", "Vacancy Report" ],
	[ "vacancycount", 2 ],
	[ "vacancyrate", 100 ],
	[
		"details",
		[
			[
				[ "position", "ceo" ],
				[ "title", "CEO" ],
				[ "department", "" ],
				[ "level", "staff" ]
			],
			[
				[ "position", "vp1" ],
				[ "title", "VP Sales" ],
				[ "department", "" ],
				[ "level", "staff" ]
			]
		]
	]
]
'

pf()
