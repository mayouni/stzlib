# Integration regression suite for stzOrgChart.
# Extends stzGraph -- adds Position, Executive/Management/Staff
# hierarchies, ReportsTo edges, Departments.
#
# Run from base/graph/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzOrgChart integration regression ==="

# ------------------------------------------------------------
# Construction
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oOc = new stzOrgChart("AcmeCorp")    # ID rejects spaces (inherited from stzGraph)
chk("Created without error",        isObject(oOc))

# ------------------------------------------------------------
# AddPosition variants
# ------------------------------------------------------------
? ""
? "--- AddPosition ---"

oOc.AddPosition("ceo")
chk("AddPosition adds node",        oOc.NodeExists("ceo") = 1)

oOc.AddPositionXT("cto", "Chief Technology Officer")
chk("AddPositionXT adds node",      oOc.NodeExists("cto") = 1)

oOc.AddPositionXTT("cfo", "Chief Financial Officer", [ :level = "executive" ])
chk("AddPositionXTT adds node",     oOc.NodeExists("cfo") = 1)

# ------------------------------------------------------------
# Specialised position adders (Executive / Manager / Staff)
# ------------------------------------------------------------
? ""
? "--- Specialised adders ---"

oS = new stzOrgChart("S")
oS.AddExecutive("exec1")
chk("AddExecutive works",           oS.NodeExists("exec1") = 1)

oS.AddManager("mgr1")
chk("AddManager works",             oS.NodeExists("mgr1") = 1)

# AddStaffPosition (bug suspect: uses pcIde typo internally)
oS.AddStaffPosition("staff1")
chk("AddStaffPosition works",       oS.NodeExists("staff1") = 1)

# AddStaff alias (same suspect)
oS.AddStaff("staff2")
chk("AddStaff alias works",         oS.NodeExists("staff2") = 1)

# AddStaffPositionXTT with explicit hashlist (bug suspect: IsHashList(paprop) typo)
oS.AddStaffPositionXTT("staff3", "Engineer", [ :level = "staff" ])
chk("AddStaffPositionXTT works",    oS.NodeExists("staff3") = 1)

# ------------------------------------------------------------
# ReportsTo edges
# ------------------------------------------------------------
? ""
? "--- ReportsTo ---"

oRp =new stzOrgChart("R")
oRp.AddExecutive("boss")
oRp.AddStaff("emp1")
oRp.AddStaff("emp2")
oRp.ReportsTo("emp1", "boss")
oRp.ReportsTo("emp2", "boss")
chk("Edges created",                oRp.NumberOfEdges() >= 2)

# ------------------------------------------------------------
# Positions getter
# ------------------------------------------------------------
? ""
? "--- Positions list ---"

aP = oRp.Positions()
chk("Positions returns list",       isList(aP))
chk("Positions count = 3",          len(aP) = 3)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzOrgChart CHECKS PASSED!"
else
	? "SOME stzOrgChart CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
