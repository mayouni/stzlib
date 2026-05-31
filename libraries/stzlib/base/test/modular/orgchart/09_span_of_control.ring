# Narrative
# --------
# Span of control
#
# Extracted from stzorgcharttest.ring, block #9.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP 1")
    AddManagerXT("vp2", "VP 2")
    AddStaffXT("staff1", "Staff 1")
    AddStaffXT("staff2", "Staff 2")
    
    ReportsTo("vp1", "ceo")
    ReportsTo("vp2", "ceo")
    ReportsTo("staff1", "vp1")
    ReportsTo("staff2", "vp1")

    View()
    ? AverageSpanOfControl() #--> 2.0
}

pf()
