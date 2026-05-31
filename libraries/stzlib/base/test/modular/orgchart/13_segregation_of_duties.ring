# Narrative
# --------
# Segregation of duties
#
# Extracted from stzorgcharttest.ring, block #13.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("BankOrg")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("treasury", "Treasury")
    AddManagerXT("ops", "Operations")
    
    SetPositionDepartment("treasury", "treasury")
    SetPositionDepartment("ops", "operations")
    
    ReportsTo("treasury", "ceo")
    ReportsTo("ops", "treasury")  # VIOLATION
    
    ? @@NL( ValidateXT(:SegregationOfDuties) )
}
#-->
'
[
	[ "status", "fail" ],
	[ "domain", "segregation_of_duties" ],
	[ "issuecount", 1 ],
	[
		"issues",
		[ "SOD-001: Operations reports through Treasury" ]
	]
]
'

pf()
