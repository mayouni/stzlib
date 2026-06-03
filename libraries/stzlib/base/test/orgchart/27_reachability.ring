# Narrative
# --------
# Reachability
#
# Extracted from stzorgcharttest.ring, block #27.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP 1")
    AddManagerXT("vp2", "VP 2")
    
    ReportsTo("vp1", "ceo")
    ReportsTo("vp2", "ceo")
    
    ? @@( ReachableFrom("ceo") ) #--> ["ceo", "vp1", "vp2"]
}

pf()
