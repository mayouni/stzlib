# Narrative
# --------
# Connectivity
#
# Extracted from stzorgcharttest.ring, block #28.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    ReportsTo("vp1", "ceo")
    
    ? IsConnected() #--> TRUE
    ? HasCyclicDependencies() #--> FALSE
}

pf()
