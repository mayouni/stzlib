load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG2 -- THE KILL CRITERION

	The plan wrote it before any code:

	    "if the face cannot express the supply-chain risk picture already
	     produced by hand in the spike, the abstraction is wrong and gets
	     redesigned before anything is built on it."

	So this file rebuilds exactly that picture -- the same eleven-node
	supply chain, the same question ("if this node fails, how much fails
	with it") -- through the FACE instead of by hand, and checks the
	numbers rather than trusting the pixels.
---------------------------------------------------------------------------*/

decimals(2)

oG = new stzGraph("supply")
oG.AddNodes([ "mine","smelt","chip","board","sensor","cell","pack",
              "motor","ecu","line1","line2","car" ])

oG.AddEdge("mine","smelt")
oG.AddEdge("smelt","chip")
oG.AddEdge("smelt","cell")
oG.AddEdge("chip","board")
oG.AddEdge("board","sensor")
oG.AddEdge("sensor","ecu")
oG.AddEdge("cell","pack")
oG.AddEdge("pack","motor")
oG.AddEdge("motor","ecu")
oG.AddEdge("board","ecu")
oG.AddEdge("ecu","line1")
oG.AddEdge("ecu","line2")
oG.AddEdge("line1","car")
oG.AddEdge("line2","car")

? "graph : " + len(oG.NodesIds()) + " nodes, " + len(oG.Edges()) + " edges"
? ""

#---------------------------------------------------------------------------
? "-- the metric the picture is MADE OF --------------------------"
#
# Not an attribute anybody set. A reachability count: how many nodes fail
# if this one does. The face computes it FROM THE GRAPH.
#---------------------------------------------------------------------------

oGC = oG.GraphCanvas([ :Layout = :Hierarchical, :SizeBy = :Impact,
                       :ColorBy = :Impact ])
aIds = oG.NodesIds()
aImpact = oGC.MetricValues(:Impact)
for i = 1 to len(aIds)
	? "   " + PadR(aIds[i], 8) + " impact " + aImpact[i]
next

# the spike's own answers, recomputed here and checked
? ""
? "   mine reaches everything downstream : " + aImpact[1] +
  "  (11 = every other node)"
? "   car reaches nothing                : " + aImpact[12]
? "   ecu is upstream of 3               : " + aImpact[9]
bOk = (aImpact[1] = 11) and (aImpact[12] = 0) and (aImpact[9] = 3)
? "   the metric matches the spike       : " + bOk

#---------------------------------------------------------------------------
? ""
? "-- the picture, from the same object --------------------------"
#---------------------------------------------------------------------------

oF = NULL
if fexists("C:/Windows/Fonts/segoeui.ttf")
	oF = new stzFont("C:/Windows/Fonts/segoeui.ttf")
ok

oGC.SetSize(1000, 560)
oGC2 = oG.GraphCanvas([ :Layout = :Hierarchical, :SizeBy = :Impact,
                        :ColorBy = :Impact, :Font = oF, :Margin = 90 ])
oGC2.SetSize(1000, 560)
cP = oGC2.ToPNG("gg2_supply_risk.png")
? "   gg2_supply_risk.png : " + len(cP) + " bytes"

# the SVG tier needs no device at all -- the tier ladder still holds
cSvg = oGC2.ToSVG()
? "   SVG tier answers too : " + len(cSvg) + " chars, no device needed"

# and the same graph under the OTHER layout, to show the option is real
oGC3 = oG.GraphCanvas([ :Layout = :Force, :SizeBy = :Impact,
                        :ColorBy = :Impact, :Font = oF ])
oGC3.SetSize(1000, 560)
oGC3.ToPNG("gg2_supply_force.png")
? "   gg2_supply_force.png written (same graph, :Force layout)"

#---------------------------------------------------------------------------
? ""
? "-- the binding is REAL, not decorative ------------------------"
#
# The claim is that size and colour come from the graph's shape. The proof
# is that CHANGING THE SHAPE changes the picture with nothing else touched.
#---------------------------------------------------------------------------

nMineBefore = aImpact[1]
oG2 = new stzGraph("supply2")
oG2.AddNodes([ "mine","smelt","chip","board","sensor","cell","pack",
               "motor","ecu","line1","line2","car" ])
oG2.AddEdge("mine","smelt")
oG2.AddEdge("smelt","chip")
oG2.AddEdge("chip","board")
# the cell branch is CUT: mine no longer reaches pack or motor
oG2.AddEdge("board","sensor")
oG2.AddEdge("sensor","ecu")
oG2.AddEdge("pack","motor")
oG2.AddEdge("motor","ecu")
oG2.AddEdge("ecu","line1")
oG2.AddEdge("ecu","line2")
oG2.AddEdge("line1","car")
oG2.AddEdge("line2","car")

oGC4 = oG2.GraphCanvas([ :SizeBy = :Impact, :ColorBy = :Impact ])
nMineAfter = oGC4.MetricValues(:Impact)[1]
? "   mine impact with the cell branch : " + nMineBefore
? "   ...and with it CUT               : " + nMineAfter
? "   the picture follows the graph    : " + (nMineAfter < nMineBefore)

#---------------------------------------------------------------------------
? ""
? "-- deterministic, like everything under it --------------------"
#---------------------------------------------------------------------------

oGa = oG.GraphCanvas([ :Layout = :Hierarchical, :SizeBy = :Impact ])
oGb = oG.GraphCanvas([ :Layout = :Hierarchical, :SizeBy = :Impact ])
aPa = oGa.Positions()
aPb = oGb.Positions()
bDet = TRUE
for i = 1 to len(aPa)
	if aPa[i][2] != aPb[i][2] or aPa[i][3] != aPb[i][3]
		bDet = FALSE
		exit
	ok
next
? "   same positions on a second build : " + bDet

? ""
? "=============================================================="
? " KILL CRITERION -- the face expresses the spike's picture : " +
  iif(bOk and bDet, "PASS", "FAIL")
? "=============================================================="

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_
