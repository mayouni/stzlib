# Narrative
# --------
# Vacancy tracking
#
# Extracted from stzorgcharttest.ring, block #5.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp1, "VP Sales")
    AddStaffXT(:@dev1, "Developer")
    
    AddPersonXT(:@alice, "Alice")
    Assign(:@alice, :ToNode = :@ceo)
    
    ? @@( VacantPositions() )
    #--> ["vp1", "dev1"]

    ? VacancyRate()
    #--> 66.67
}

pf()
# Executed in 0.03 second(s) in Ring 1.24
