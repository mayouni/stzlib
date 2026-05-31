# Narrative
# --------
# Reassignment
#
# Extracted from stzorgcharttest.ring, block #6.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {

    AddStaffXT(:@dev1, "Developer 1")
    AddStaffXT(:@dev2, "Developer 2")

    AddPersonXT(:@bob, "Bob Marley")
    AssignPerson(:@bob, :ToPosition = :@dev1)
    
    ? Position(:@dev1)[:incumbent] #--> @bob
    ? Position(:@dev2)[:incumbent] #--> ""
    
    ReassignPerson(:@bob, :ToPosition = :@dev2)
    
    ? Position(:@dev1)[:incumbent] #--> ""
    ? Position(:@dev2)[:incumbent] #--> @bob
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

#==============#
#  DEPARTMENTS #
#==============#
