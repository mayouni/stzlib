# Narrative
# --------
# Position hierarchy analysis
#
# Extracted from stzorgcharttest.ring, block #10.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")

    AddManagerXT("vp1", "VP 1")
    AddManagerXT("vp2", "VP 2")

    AddStaffXT("s1", "Staff 1")
    AddStaffXT("s2", "Staff 2")
    AddStaffXT("s3", "Staff 3")

    ? @@NL( PositionsByLevel() ) + NL
	#-->
	'
	[
		[
			"executive",
			[ "ceo" ]
		],
		[
			"management",
			[ "vp1", "vp2" ]
		],
		[
			"staff",
			[ "s1", "s2", "s3" ]
		]
	]
	'

    ? @@NL( PositionsByLevelN() )
	#-->
	'
	[
		[ "executive", 1 ],
		[ "management", 2 ],
		[ "staff", 3 ]
	]
	'

}

pf()
# Executed in 0.03 second(s) in Ring 1.24
