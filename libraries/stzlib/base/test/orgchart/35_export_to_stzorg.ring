# Narrative
# --------
# Export to .stzorg
#
# Extracted from stzorgcharttest.ring, block #35.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddPersonXT("p1", "Alice")
    AssignPerson("p1", "ceo")
    
    cFormat = ToStzOrg()
    # Returns formatted .stzorg text
    
    WriteToStzOrgFile("../_data/test.stzorg") # Harmonize with stzDiagram/stzGraph
    ? read("../_data/test.stzorg")
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

departments
'

pf()
