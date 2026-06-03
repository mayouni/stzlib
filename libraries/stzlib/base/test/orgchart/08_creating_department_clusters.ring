# Narrative
# --------
# Creating department clusters
#
# Extracted from stzorgcharttest.ring, block #8.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddManagerXT("vp_eng", "VP Engineering")
    AddStaffXT("dev1", "Dev 1")
    AddStaffXT("dev2", "Dev 2")
    
    AddDepartmentXTT("eng_dept", "Engineering", ["vp_eng", "dev1", "dev2"])
    
    ReportsTo("dev1", "vp_eng")
    ReportsTo("dev2", "vp_eng")

    ? @@NL( Departments() )

    View()
}
#-->
'
[
	[
		[ "id", "eng_dept" ],
		[ "name", "Engineering" ],
		[
			"positions",
			[ "vp_eng", "dev1", "dev2" ]
		],
		[ "head", "" ]
	]
]
'

pf()
# Visual: Engineering positions grouped in shaded cluster box

#==========#
#  METRICS #
#==========#
