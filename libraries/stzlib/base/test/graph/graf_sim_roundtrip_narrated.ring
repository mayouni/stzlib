# .stzgraf + .stzsim ROUND-TRIP -- a graph written down, and a graph's
# CHANGES written down.
#
# .stzgraf is the graph itself; .stzsim is the diff between two of them, so
# you can look at a restructure before doing it. Both are only worth having
# if what comes back is what went in. This proves that, and pins the four
# defects that had kept them from telling the truth:
#
#   the label      -- .stzgraf wrote node ids ONLY, so every node came back
#                     labelled with its own id.
#   the property   -- the parser counted indent with StzMid(line, j, 2),
#                     which asks for TWO chars and so never matched " ":
#                     every property line was read as a node NAME and no
#                     property survived (test 83 said so for months).
#   the type       -- Ring's isdigit() judges ONE char, so isdigit("50000")
#                     is FALSE: numbers came back as strings.
#   the diff       -- Ring's `=` on lists is false even for identical ones,
#                     so diffing raw edge hashlists matched NOTHING and
#                     reported every edge as BOTH added and removed.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: a graph, written down and read back --"

oG = new stzGraph("acme")
oG.AddNodeXTT("ceo", "CEO", [ :level = 5, :department = "executive" ])
oG.AddNodeXTT("cto", "CTO", [ :level = 4, :rate = 2.5 ])
oG.AddNode("eng1")
oG.AddEdgeXT("ceo", "cto", "manages")
oG.AddEdge("cto", "eng1")

oG.SaveToStzGraf("_rt.stzgraf")
chk("the file is really on disk", fexists("_rt.stzgraf"))

oBack = new stzGraph("blank")
oBack.LoadFromStzGraf("_rt.stzgraf")

chk("every node came back", oBack.NodeCount() = 3)
chk("every edge came back", oBack.EdgeCount() = 2)
chk("the graph knows its own name again", oBack.Name() = "acme")

chk("a node's LABEL survives", oBack.NodeLabel("ceo") = "CEO")
chk("... and a node with no label of its own still answers with its id",
	oBack.NodeLabel("eng1") = "eng1")
chk("an edge's label survives", oBack.Edge("ceo", "cto")[:label] = "manages")

chk("a node's PROPERTY survives", oBack.NodeProperty("ceo", "level") = 5)
chk("... as the TYPE it was, not as text",
	isNumber(oBack.NodeProperty("ceo", "level")))
chk("... decimals included", oBack.NodeProperty("cto", "rate") = 2.5)
chk("... and a string stays a string",
	oBack.NodeProperty("ceo", "department") = "executive")

? ""
? "-- Scene 2: the DIFF says only what changed --"

oBase = new stzGraph("org")
oBase.AddNodeXT("ceo", "CEO")
oBase.AddNodeXT("cfo", "CFO")
oBase.AddNodeXT("treasury_head", "Treasury_Head")
oBase.AddEdge("ceo", "cfo")
oBase.AddEdge("ceo", "treasury_head")

oVar = oBase.Copy()
oVar.AddNodeXT("risk_officer", "Risk_Officer")
oVar.RemoveThisEdge("ceo", "treasury_head")
oVar.AddEdge("cfo", "treasury_head")

aDiff = oBase.CompareWith(oVar)

chk("the node that appeared is reported once",
	len(aDiff[:nodes][:added]) = 1 and aDiff[:nodes][:added][1] = "risk_officer")
chk("no node is claimed removed", len(aDiff[:nodes][:removed]) = 0)
chk("the edge that appeared is reported", len(aDiff[:edges][:added]) = 1)
chk("the edge that went is reported", len(aDiff[:edges][:removed]) = 1)

# THE defect this pins: ceo -> cfo never moved. It must appear in NEITHER
# list. It used to appear in BOTH.
bUnchangedQuiet = TRUE
for i = 1 to len(aDiff[:edges][:added])
	if aDiff[:edges][:added][i][:from] = "ceo" and
	   aDiff[:edges][:added][i][:to] = "cfo"
		bUnchangedQuiet = FALSE
	ok
next
for i = 1 to len(aDiff[:edges][:removed])
	if aDiff[:edges][:removed][i][:from] = "ceo" and
	   aDiff[:edges][:removed][i][:to] = "cfo"
		bUnchangedQuiet = FALSE
	ok
next
chk("an edge that never moved is in NEITHER list", bUnchangedQuiet)

? ""
? "-- Scene 3: the changes, written down and replayed --"

cSim = oVar.ExportToStzSim(oBase)
chk("the simulation names the node to add", StzFindFirst(cSim, "add node risk_officer") > 0)
chk("... the edge to remove", StzFindFirst(cSim, "remove edge ceo -> treasury_head") > 0)
chk("... and never mentions the edge that stayed",
	StzFindFirst(cSim, "edge ceo -> cfo") = 0)

oReplay = oBase.Copy()
oReplay.ApplySimulation(cSim)

chk("replaying it reaches the same node count", oReplay.NodeCount() = oVar.NodeCount())
chk("... and the same edge count", oReplay.EdgeCount() = oVar.EdgeCount())
chk("the treasury really moved under the CFO", oReplay.EdgeExists("cfo", "treasury_head"))
chk("... and left the CEO", NOT oReplay.EdgeExists("ceo", "treasury_head"))
chk("an added node carries the LABEL the simulation gave it",
	oReplay.NodeLabel("risk_officer") = "Risk_Officer")

# Applying the same simulation twice must not raise: AddEdge refuses a
# duplicate, so a sim replayed onto a graph that already has part of it
# used to die with "Edge already exists".
bTwice = TRUE
try
	oReplay.ApplySimulation(cSim)
catch
	bTwice = FALSE
done
chk("replaying it AGAIN is harmless, not a raise", bTwice)
chk("... and changes nothing the second time", oReplay.EdgeCount() = oVar.EdgeCount())

? ""
? "-- Scene 4: a label can be SAID after the fact --"

# A node could only ever be labelled at birth. .stzsim learns the label a
# line after the node, so it needed a door.
oL = new stzGraph("lbl")
oL.AddNode("x")
chk("a bare node answers with its id", oL.NodeLabel("x") = "x")
oL.SetNodeLabel("x", "The X")
chk("SetNodeLabel says it afterwards", oL.NodeLabel("x") = "The_X")
chk("... normalised like every other label (no spaces)",
	StzFindFirst(oL.NodeLabel("x"), " ") = 0)

bNoNode = 0
try
	oL.SetNodeLabel("ghost", "Nope")
catch
	bNoNode = 1
done
chk("labelling a node that isn't there REFUSES", bNoNode = 1)

bNoFile = 0
try
	oM = new stzGraph("m")
	oM.LoadFromStzGraf("_no_such_file.stzgraf")
catch
	bNoFile = 1
done
chk("loading a file that isn't there refuses too", bNoFile = 1)

remove("_rt.stzgraf")

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
