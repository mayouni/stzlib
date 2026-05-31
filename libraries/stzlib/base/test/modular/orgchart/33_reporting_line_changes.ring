# Narrative
# --------
# Reporting line changes
#
# Extracted from stzorgcharttest.ring, block #33.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP 1")
    AddManagerXT("vp2", "VP 2")
    AddStaffXT("dev1", "Dev")
    
    ReportsTo("vp1", "ceo")
    ReportsTo("vp2", "ceo")
    ReportsTo("dev1", "vp1")
    
    ? @@( DirectReports("vp1") ) #--> ["dev1"]
    ? @@( DirectReports("vp2") ) #--> []
    
    ChangeReportingLine("dev1", "vp2")
    
    ? @@( DirectReports("vp1") ) #--> []
    ? @@( DirectReports("vp2") ) #--> ["dev1"]
}

pf()
