# Narrative
# --------
# Succession risk
#
# Extracted from stzorgcharttest.ring, block #11.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    
    AddPersonXT("p1", "Alice")
    AddPersonXT("p2", "Bob")
    AssignPerson("p1", "ceo")
    AssignPerson("p2", "vp1")
    
    ? @@( SuccessionRisk() ) #--> ["ceo", "vp1"]
    
    SetNodeProperty("vp1", "successor", "some_person")
    
    ? @@( SuccessionRisk() ) #--> ["ceo"] #ERROR returned [ "ceo", "vp1" ]
}

pf()

#==============#
#  VALIDATION  #
#==============#
