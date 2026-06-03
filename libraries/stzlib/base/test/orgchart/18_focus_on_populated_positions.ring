# Narrative
# --------
# Focus on populated positions
#
# Extracted from stzorgcharttest.ring, block #18.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {

    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp1, "VP 1")
    ReportsTo(:@vp1, :@ceo)

    AddPersonXT(:@alice, "Alice")
    AssignPerson(:@alice, :@ceo)
    
    ViewNonVacant()  # ceo highlighted in magenta, vp1 in white
}

pf()
