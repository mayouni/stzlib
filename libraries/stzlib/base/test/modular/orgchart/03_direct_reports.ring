# Narrative
# --------
# Direct reports
#
# Extracted from stzorgcharttest.ring, block #3.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp1, "VP Sales")
    AddManagerXT(:@vp2, "VP Ops")
    
    ReportsTo(:@vp1, :@ceo)
    ReportsTo(:@vp2, :@ceo)
    
    ? @@( DirectReports(:@ceo) )
    #--> [ "@vp1", "@vp2" ]

    ? DirectReportsN(:@ceo)
    #--> 2
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

#===============#
#  PEOPLE MGMT  #
#===============#
