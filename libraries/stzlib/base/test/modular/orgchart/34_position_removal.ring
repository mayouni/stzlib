# Narrative
# --------
# Position removal
#
# Extracted from stzorgcharttest.ring, block #34.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    AddPersonXT("p1", "Alice")
    AssignPerson("p1", "vp1")
    
    ? NodeCount() #--> 2
    ? len(People()) #--> 1
    
    RemovePosition("vp1")
    
    ? NodeCount() #--> 1
    ? @@( PersonData("p1")[:position] ) #--> ""
}

pf()

#=================#
#  EXPORT/IMPORT  #
#=================#
