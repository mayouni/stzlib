# Narrative
# --------
# BCEAO governance
#
# Extracted from stzorgcharttest.ring, block #14.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("BankOrg")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("audit", "Audit")
    SetPositionDepartment("audit", "audit")
    ReportsTo("audit", "ceo")
    
    ? @@NL( ValidateXT(:BCEAO) )
}
#-->
'
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
]
'

pf()
