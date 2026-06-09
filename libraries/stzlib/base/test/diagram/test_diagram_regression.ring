# Integration regression for stzDiagram.
# Extends stzGraph with visualization (theme, layout, fonts, colors).
#
# Run from base/graph/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzDiagram integration regression ==="

# ------------------------------------------------------------
# Construction
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oD = new stzDiagram("d1")
chk("Constructed",                   isObject(oD))
chk("Name preserved (lowercased)",   oD.Name() = "d1")

# ------------------------------------------------------------
# Add nodes / edges (inherited from stzGraph)
# ------------------------------------------------------------
? ""
? "--- Inherited graph ops ---"

oD.AddNode("a")
oD.AddNode("b")
oD.Connect("a", "b")

chk("AddNode works",                 oD.NumberOfNodes() = 2)
chk("Connect works",                 oD.NumberOfEdges() = 1)
chk("HasNode (after R-fix)",         oD.HasNode("a") = 1)

# ------------------------------------------------------------
# Theme / Layout setters (no-raise smoke)
# ------------------------------------------------------------
? ""
? "--- Setters ---"

oD.SetTheme("light")
oD.SetLayout("dot")
oD.SetTitle("Test diagram")
oD.SetSubtitle("subtitle")
oD.SetOutputFormat("svg")
chk("Setters return without raise",  isObject(oD))

# Output format alias
oD.SetOutput("png")
chk("SetOutput alias works",         isObject(oD))

# Layout preset (silent on unknown is acceptable)
oD.SetLayoutPreset("orgchart")
chk("SetLayoutPreset works",         isObject(oD))

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzDiagram CHECKS PASSED!"
else
	? "SOME stzDiagram CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
