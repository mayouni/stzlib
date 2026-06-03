# Narrative
# --------
# Property range queries
#
# Extracted from stzorgcharttest.ring, block #30.
#ERR Error (R3) : Calling Function without definition: nodeswithpropertyxt

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddManagerXT(:@mgr, "IT Manager")

    AddStaffXT(:@dev1, "Developer 1")
    AddStaffXT(:@dev2, "Developer 2")
    AddStaffXT(:@dev3, "Developer 3")
    
    ReportsTo(:@dev1, :@mgr)
    ReportsTo(:@dev2, :@mgr)
    ReportsTo(:@dev3, :@mgr)

    SetNodeProperty(:@dev1, "performance", 85)
    SetNodeProperty(:@dev2, "performance", 65)
    SetNodeProperty(:@dev3, "performance", 92)
    
    acHigh = NodesWithPropertyXT("performance", :Between = [80, 100]) #TODO
    ? @@( acHigh ) #--> ["dev1", "dev3"]

    ViewPerformant()
}

pf()
