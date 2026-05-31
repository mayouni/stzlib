# Narrative
# --------
# Graph metrics
#
# Extracted from stzorgcharttest.ring, block #31.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    AddStaffXT("dev1", "Dev")
    
    ReportsTo("vp1", "ceo")
    ReportsTo("dev1", "vp1")
    
    ? NodeDensity() #--> 0.33
    ? Diameter() #--> 2
    ? AveragePathLength() #--> 1.33
}

pf()

#============================================#
#  VISUAL RULES (inherited from stzDiagram)  #
#============================================#
