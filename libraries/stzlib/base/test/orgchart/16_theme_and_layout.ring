# Narrative
# --------
# Theme and layout
#
# Extracted from stzorgcharttest.ring, block #16.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    SetTheme("vibrant")
    SetLayout(:LeftRight)
    SetEdgeLineStyle(:Curved) #ERR no effect!
    
    ? Theme() #--> "vibrant"
    ? Layout() #--> "leftright"
    ? Splines() #--> "curved"
    
    AddExecutiveXT(:@ceo, "CEO")
    AddManagerXT(:@vp_eng, "VP Engineering")
    AddStaffXT(:@dev1, "Developer 1")
    AddStaffXT(:@dev2, "Developer 2")

    ReportsTo(:@vp_eng, :@ceo)
    ReportsTo(:@dev1, :@vp_eng)
    ReportsTo(:@dev2, :@vp_eng)

    View() // should displays horizontal tree with curved edges
    #ERR // Theme is not applied, Splines are not curved!
}

pf()
# Executed in 0.04 second(s) in Ring 1.24
