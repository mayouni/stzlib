# Narrative
# --------
# Focus on vacant positions
#
# Extracted from stzorgcharttest.ring, block #17.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {

    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp1, "VP 1")
    ReportsTo(:@vp1, :@ceo)

    AddPersonXT(:@alice, "Alice")
    AssignPerson(:@alice, :@ceo)

    ViewVacant()  # vp1 highlighted in magenta, ceo in gold
}

pf()
