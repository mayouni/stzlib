# Narrative
# --------
# Department assignment
#
# Extracted from stzorgcharttest.ring, block #7.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddManagerXT(:@vp_eng, "VP Engineering")
    AddStaffXT(:@dev1, "Developer")

    AddDepartmentXTT(:@eng_dept, "Engineering", [ :@vp_eng, :@dev1 ])

    SetPositionDepartment(:@vp_eng, :@eng_dept)
    SetPositionDepartment(:@dev1, :@eng_dept)
    
    ? NodeProperty(:@vp_eng, :@eng_dept) #--> "engineering"
}
#ERR Inexistant node key or/and property!
# In method nodeproperty()

pf()
