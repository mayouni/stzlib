# Narrative
# --------
# Span of control validation
#
# Extracted from stzorgcharttest.ring, block #12.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("WideOrg")
oOrg {
    AddExecutiveXT("boss", "Boss")

    for i = 1 to 12
        AddStaffXT("s" + i, "Staff " + i)
        ReportsTo("s" + i, "boss")
    end
    
    ? @@NL( ValidateXT(:SpanOfControl) )

}
#-->
'
[
	[ "status", "fail" ],
	[ "domain", "span_of_control" ],
	[
		"issues",
		[ "Excessive span: boss (12 reports)" ]
	]
]
'

pf()
