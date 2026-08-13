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
chk("the simulation names the node to add", StzFindFirst("add node risk_officer", cSim) > 0)
chk("... the edge to remove", StzFindFirst("remove edge ceo -> treasury_head", cSim) > 0)
chk("... and never mentions the edge that stayed",
	StzFindFirst("edge ceo -> cfo", cSim) = 0)

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
chk("SetNodeLabel says it afterwards", oL.NodeLabel("x") = "The X")

# A LABEL KEEPS ITS SPACES. It is DISPLAY text, not an id.
#
# This line used to demand the opposite, and I made _NormalizeLabel obey it --
# wrongly. The no-spaces rule belongs to _IsWellFormedId, which governs node
# IDS; applying it to labels made a rendered diagram read VP_Sales. That was
# caught by drawing a 40-node diagram and READING it, not by any assertion:
# test 32's expected output had been transcribed FROM the buggy render, and
# ExplainPath quietly put the spaces back, so the suite confirmed itself.
#
# What a label normalises is NEWLINES, which would break the render. Nothing
# else.
chk("... and keeps its spaces, being display text", oL.NodeLabel("x") = "The X")

oL.SetNodeLabel("x", "Two" + char(10) + "Lines")
chk("... while a NEWLINE is normalised away", StzFindFirst(char(10), oL.NodeLabel("x")) = 0)

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
? "-- Scene 6: a copy is its own graph, index and all --"

# THE defect that killed Scene 3 for as long as this guard existed.
#
# @pNodeIdx / @pEdgeIdx / @pEngineGraph are engine HANDLES, and Ring copies a
# handle by value. A copy therefore shared the original's index while owning
# its own @aNodes, and AddNodeXTT writes new keys straight into that shared
# map -- so a node added to the COPY answered NodeExists on the ORIGINAL.
#
# The staleness check could not see it: it compares @nNodeIdxCount against
# len(@aNodes), and on the original both are still 2. Only the shared map grew.
#
# What made it hard to read is that the error blamed the honest party.
# ApplySimulation asked NodeExists, was told the node was already there, so it
# skipped the AddNode -- and SetNodeLabel, which scans @aNodes for real, raised
# "Node 'risk_officer' does not exist."
#
# The index is only built on demand, so a probe must ASK something first --
# without the NodeExists below, @pNodeIdx is still "" and nothing leaks.

oOrig = new stzGraph("iso")
oOrig.AddNodeXT("a", "A")
oOrig.AddNodeXT("b", "B")
oOrig.AddEdge("a", "b")

chk("the original knows its own node", oOrig.NodeExists("a"))   # builds the index

oClone = oOrig.Copy()
oClone.AddNodeXT("c", "C")
oClone.AddEdge("b", "c")

chk("the clone sees what it added", oClone.NodeExists("c"))
chk("... and counts it", oClone.NodeCount() = 3)

# The four that failed before the fix.
chk("the ORIGINAL does not see the clone's node", NOT oOrig.NodeExists("c"))
chk("... and its count is untouched", oOrig.NodeCount() = 2)
chk("... nor does it see the clone's edge", NOT oOrig.EdgeExists("b", "c"))
chk("... and its edge count is untouched", oOrig.EdgeCount() = 1)

# The negative sibling: detaching the caches must not have COST the copy its
# contents. A Copy() that returned an empty graph would pass everything above.
chk("the clone still carries the original's nodes", oClone.NodeExists("a") and oClone.NodeExists("b"))
chk("... and the original's edge", oClone.EdgeExists("a", "b"))

# ... and the leak has no preferred direction: adding to the ORIGINAL after
# the copy was taken must not reach the clone either.
oOrig.AddNodeXT("d", "D")
chk("a node added to the original stays out of the clone", NOT oClone.NodeExists("d"))

? ""
? "-- Scene 7: one label rule, whichever spelling you call --"

# _NormalizeLabel and _NormaliseLabel were written as alternative FORMS of
# each other and were not: one replaced newlines, the other SPACES, and every
# call site used the first. Half the rule was dead code.
#
# The dead half was also the WRONG half. Making the alias delegate looked like
# the tidy fix and resurrected a rule labels must not have -- see Scene 4. The
# alias delegates now, and what it delegates to leaves spaces alone.
#
# Both doors must agree: a label given at birth and one said afterwards are
# the same label, whichever spelling of the normaliser is called.

oN = new stzGraph("nrm")
oN.AddNodeXT("n1", "Chief Risk Officer")
chk("a label given at birth keeps its spaces", oN.NodeLabel("n1") = "Chief Risk Officer")
oN.AddNode("n2")
oN.SetNodeLabel("n2", "Head Of Audit")
chk("... and so does one said afterwards", oN.NodeLabel("n2") = "Head Of Audit")
chk("a label with nothing to normalise is untouched", _NormalizeLabelProbe(oN, "n3", "Treasurer") = "Treasurer")

# ...and the two doors agree on the NEWLINE too, which is the one thing a
# label really cannot carry.
oN.AddNodeXT("n4", "Two" + char(10) + "Lines")
chk("a newline is normalised at birth", StzFindFirst(char(10), oN.NodeLabel("n4")) = 0)
chk("... and both doors give the same answer",
	oN.NodeLabel("n4") = _NormalizeLabelProbe(oN, "n5", "Two" + char(10) + "Lines"))

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func _NormalizeLabelProbe(poGraph, pcId, pcLabel)
	poGraph.AddNodeXT(pcId, pcLabel)
	return poGraph.NodeLabel(pcId)

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
