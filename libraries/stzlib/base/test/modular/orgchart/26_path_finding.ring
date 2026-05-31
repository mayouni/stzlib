# Narrative
# --------
# Path finding
#
# Extracted from stzorgcharttest.ring, block #26.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    AddStaffXT("dev1", "Dev")
    
    ReportsTo("vp1", "ceo")
    ReportsTo("dev1", "vp1")
    
    ? @@( PathBetween("ceo", "dev1") )
    #--> ["ceo", "vp1", "dev1"]

    ? ShortestPathLength("ceo", "dev1")
    #--> 2
}

pf()
