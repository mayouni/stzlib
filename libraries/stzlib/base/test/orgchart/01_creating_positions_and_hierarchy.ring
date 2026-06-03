# Narrative
# --------
# Creating positions and hierarchy
#
# Extracted from stzorgcharttest.ring, block #1.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp_eng, "VP Engineering")
    AddStaffXT(:@dev1, "Senior Dev")
    
    ReportsTo(:@vp_eng, :@ceo)
    ReportsTo(:@dev1, :@vp_eng)
    
    ? NodeCount() #--> 3
    ? EdgeCount() #--> 2
}

pf()
# Executed in 0.03 second(s) in Ring 1.24
