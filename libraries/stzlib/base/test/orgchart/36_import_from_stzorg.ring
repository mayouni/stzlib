# Narrative
# --------
# Import from .stzorg
#
# Extracted from stzorgcharttest.ring, block #36.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("Imported")
oOrg {
    ? read("../_data/test.stzorg")
    ImportFromStzOrgFile("../_data/test.stzorg")
    
    ? NodeCount() #--> 1
    ? len(People()) #--> 1
}
#-->
'
orgchart "TechCo"

positions
    ceo
        title: CEO
        level: executive
        department: 
        reportsTo: 

people
    p1
        name: Alice

assignments
    p1 -> ceo

departments'

pf()
