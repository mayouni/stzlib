# Narrative
# --------
# Adding and assigning people
#
# Extracted from stzorgcharttest.ring, block #4.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT(:@ceo, "CEO")
    AddPersonXT(:@p1, "Sarah Chen")
    Assign(:Person = :@p1, :ToPosition = :@ceo)
    
    ? Position(:@ceo)[:incumbent] #--> "@p1"
    ? Position(:@ceo)[:isVacant] #--> FALSE
    ? PersonData(:@p1)[:position] #--> "@ceo"

    View()
}

pf()
# Visual: CEO node now shows "CEO\nSarah Chen" in gold

#ERR The name of person is not displayed
#ERR node is showan in white
