# Narrative
# --------
# View succession risk
#
# Extracted from stzorgcharttest.ring, block #20.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddPersonXT("p1", "Alice")
    AssignPerson("p1", "ceo")
    
    ? @@NL( ValidateXT(:Succession) )

    ViewAtRisk()  # CEO highlighted (no successor designated)
}
#-->
'
[
	[ "status", "fail" ],
	[ "domain", "succession" ],
	[ "issuecount", 1 ],
	[
		"issues",
		[ "No successor: ceo" ]
	],
	[
		"affectednodes",
		[ "ceo" ]
	]
]
'

pf()

#=============#
#  REPORTING  #
#=============#
