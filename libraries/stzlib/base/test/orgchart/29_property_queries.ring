# Narrative
# --------
# Property queries
#
# Extracted from stzorgcharttest.ring, block #29.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddManagerXT("vp1", "VP Eng")
    AddManagerXT("vp2", "VP Sales")
    AddStaffXT("dev1", "Dev")
    
    SetPositionDepartment("vp1", "engineering")
    SetPositionDepartment("dev1", "engineering")
    SetPositionDepartment("vp2", "sales")
    
    ? @@( NodesByProperty("department", "engineering") )
    #--> ["vp1", "dev1"]
}

pf()
