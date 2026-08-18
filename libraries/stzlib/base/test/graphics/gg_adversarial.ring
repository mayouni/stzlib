load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	WHAT THE GUARDS COULD NOT SEE

	Every assertion in this file exists because a DEFECT SURVIVED A GREEN
	SUITE and was found by rendering a picture and looking at it.

	  - gg_nodeshapes proves every shape stays inside its box. The cylinder's
	    cap did stay inside its box, and was still wrong: at 26x200 the cap
	    was 26px deep and 13px across -- an ellipse taller than it is wide,
	    which is not a circle seen in perspective from any angle. Containment
	    was true and the shape was broken.

	  - stzGraph's label rule was DECIDED, its test was rewritten, and the
	    library line was never removed. Nothing failed, because a `#-->`
	    block is not compared to anything, the narration path replaced the
	    underscores back with spaces before a human read them, and the one
	    export test that showed the damage had recorded its expectation FROM
	    the buggy render.

	  - Nothing at all knew whether a node BOX fits the rank it landed in.
	    The layout spreads a rank evenly and knows nothing about box width;
	    the caller sets box width and knows nothing about rank population.
	    Sixteen 96px nodes went 82px apart and were drawn on top of one
	    another.

	The common shape: each property is about the PICTURE, and every
	instrument pointed somewhere else. So these assertions read pixels, or
	they assert the mechanism directly and prove the instrument can fail.

	Run:  ring gg_adversarial.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " WHAT THE GUARDS COULD NOT SEE"
? "=============================================================="

if NOT StzGraphicsDevice()
	? ""
	? " (no device -- every property here is a PIXEL property, so this"
	? "  file is UNJUDGED on this machine rather than passed)"
	return
ok

#---------------------------------------------------------------------------
? ""
? "-- 1. Painter order, across the segment KINDS ---------------"
#
# Images arrived as a third SegKind beside shapes and text, and the claim
# was that the ordered segment list interleaves them. "Both drew" would
# pass on a renderer that painted all images last. So: a shape, then an
# image ON TOP of it, and the overlap is read in pixels.
#---------------------------------------------------------------------------

FILL = "#C81E1E"          # the under-shape
IMG  = [ 30, 90, 200 ]    # the over-image

oA = new stzCanvas(240, 160)
oA.SetBackgroundQ("#FFFFFF")
oA.FillQ(FILL).AddRect(20, 20, 200, 120)
oA.AddImage(60, 50, 120, 60, 2, 2, _Solid(2, 2, IMG[1], IMG[2], IMG[3], 255))
cPx = oA.ToPixels()

aMid = _PixelAt(cPx, 240, 120, 80)     # inside BOTH
? "   the overlap reads : " + aMid[1] + "," + aMid[2] + "," + aMid[3]
chk("the image covers the shape it was issued after",
    _Near(aMid, IMG, 6))

# THE NEGATIVE SIBLING. The same two draws in the OTHER order must give the
# other answer -- otherwise this measures "an image was drawn somewhere",
# not ordering.
oB = new stzCanvas(240, 160)
oB.SetBackgroundQ("#FFFFFF")
oB.AddImage(60, 50, 120, 60, 2, 2, _Solid(2, 2, IMG[1], IMG[2], IMG[3], 255))
oB.Flush()
oB.FillQ(FILL).AddRect(20, 20, 200, 120)
aMid2 = _PixelAt(oB.ToPixels(), 240, 120, 80)
? "   issued the other way round : " + aMid2[1] + "," + aMid2[2] + "," + aMid2[3]
chk("...and the shape covers the image when issued after IT",
    NOT _Near(aMid2, IMG, 6))

#---------------------------------------------------------------------------
? ""
? "-- 2. An image's ALPHA blends, it does not replace ----------"
#---------------------------------------------------------------------------

GROUND = [ 200, 200, 0 ]
oC = new stzCanvas(240, 120)
oC.SetBackgroundQ("#FFFFFF")
oC.FillQ("#C8C800").AddRect(0, 0, 240, 120)
oC.AddImage(20, 20, 80, 80, 2, 2, _Solid(2, 2, 0, 0, 255, 128))    # half
oC.AddImage(140, 20, 80, 80, 2, 2, _Solid(2, 2, 0, 0, 255, 255))   # opaque
cPx = oC.ToPixels()

aHalf = _PixelAt(cPx, 240, 60, 60)
aFull = _PixelAt(cPx, 240, 180, 60)
? "   alpha 128 : " + aHalf[1] + "," + aHalf[2] + "," + aHalf[3]
? "   alpha 255 : " + aFull[1] + "," + aFull[2] + "," + aFull[3]

chk("an opaque image IS its own colour", _Near(aFull, [ 0, 0, 255 ], 6))
chk("a half-alpha image is neither the ground...",
    NOT _Near(aHalf, GROUND, 20))
chk("...nor the image colour", NOT _Near(aHalf, [ 0, 0, 255 ], 20))
chk("...but lies between the two", aHalf[3] > 90 and aHalf[1] > 60)

#---------------------------------------------------------------------------
? ""
? "-- 3. A shape must survive the box a DIAGRAM gives it -------"
#
# Every node shape was first drawn in a friendly 140x100. A diagram hands
# over whatever the layout produced -- 300x40 for a long label, 26x200 in a
# tall column. The cylinder's cap is the case that broke: its depth was a
# fraction of the HEIGHT alone, so a tall box made an ellipse deeper than
# it was wide.
#
# Read off the model rather than the pixels: a cap is an ellipse, and the
# property is "rx >= ry" -- foreshortening only ever flattens.
#---------------------------------------------------------------------------

nBadCap = 0
cWorst = ""
for aBox in [ [ 140, 100 ], [ 300, 40 ], [ 26, 200 ], [ 40, 300 ], [ 200, 26 ] ]
	oD = new stzCanvas(400, 400)
	oD.SetBackgroundQ("#FFFFFF").FillQ("#3C6E9A")
	StzDrawNodeShape(oD, :Cylinder, 20, 20, aBox[1], aBox[2])
	for aE in _CapsIn(oD.ToSVG())
		if aE[1] < aE[2]
			nBadCap++
			if cWorst = ""
				cWorst = "" + aBox[1] + "x" + aBox[2] + " -> rx " + aE[1] +
					" ry " + aE[2]
			ok
		ok
	next
next
? "   cylinder caps deeper than they are wide : " + nBadCap
if cWorst != ""  ? "   worst : " + cWorst  ok
chkeq("a cylinder's cap is an ellipse foreshortening can produce", nBadCap, 0)

# THE NEGATIVE SIBLING: the reading is done by _EllipsesIn, so prove it can
# SEE a bad cap. This is the geometry the old formula produced at 26x200.
oE = new stzCanvas(120, 260)
oE.SetBackgroundQ("#FFFFFF").FillQ("#3C6E9A")
oE.AddEllipse(60, 40, 13, 26)              # rx 13, ry 26 -- the old defect
nSeen = 0
for aE in _CapsIn(oE.ToSVG())
	if aE[1] < aE[2]  nSeen++  ok
next
? "   the old geometry, drawn deliberately, is seen : " + nSeen + " time(s)"
chk("the cap check DISCRIMINATES", nSeen = 1)

#---------------------------------------------------------------------------
? ""
? "-- 4. Boxes must FIT the rank they landed in ----------------"
#
# Counted in pixels: the BACKGROUND must still be visible between one box
# and the next.
#
# The obvious instrument was counting runs of the NODE colour and expecting
# sixteen. It answered sixteen whether the boxes were separated or fused,
# because every box is STROKED -- two abutting boxes are still two runs of
# green with a dark border between them. It was measuring "sixteen boxes
# were drawn", which was never in doubt, and not "sixteen boxes can be told
# apart", which is the whole property. Gaps of background are the thing a
# reader actually sees.
#---------------------------------------------------------------------------

NODEC = "#2E7D32"
oG = new stzDiagram("fan")
oG.AddNodeXTT("root", "Root", [ :type = "box", :color = NODEC ])
for i = 1 to 16
	oG.AddNodeXTT("k" + i, "Kid " + i, [ :type = "box", :color = NODEC ])
	oG.AddEdge("root", "k" + i)
next

aOpt = [ :Width = 1200, :Height = 500, :NodeWidth = 96, :NodeHeight = 34 ]
nFit = _GapsInDensestRow(oG.ToCanvasXT(aOpt), 1200, 500, NODEC)
? "   16 nodes in a 1200px picture, boxes asked for 96px wide"
? "   gaps of background between them : " + nFit + " (16 boxes -> 15 gaps)"
chkeq("every node in the rank can be told from its neighbour", nFit, 15)

# THE NEGATIVE SIBLING, and the proof that the fit pass is what fixed it:
# the same picture with fitting switched OFF must fuse the boxes into a wall.
aOff = [ :Width = 1200, :Height = 500, :NodeWidth = 96, :NodeHeight = 34,
         :FitBoxes = 0 ]
nRaw = _GapsInDensestRow(oG.ToCanvasXT(aOff), 1200, 500, NODEC)
? "   the same picture with :FitBoxes = FALSE : " + nRaw + " gaps"
chk("without fitting the boxes really do run together", nRaw < 15)

# and the mechanism itself, where the arithmetic is visible
? "   scale for 16 nodes 82px apart, 96px boxes : " +
  oG._RankFitScale(_Rank(16, 82), 96, 34)
chk("a crowded rank scales DOWN", oG._RankFitScale(_Rank(16, 82), 96, 34) < 1)
chk("a roomy rank is left ALONE", oG._RankFitScale(_Rank(4, 300), 96, 34) = 1)

#---------------------------------------------------------------------------
? ""
? "-- 5. A label reaches the picture AS AUTHORED ---------------"
#
# Asserted at the far end -- in the drawn output -- because the defect this
# replaces was invisible everywhere upstream of it.
#
# NOT by looking for the string in the SVG. The first version did, and both
# its assertions were vacuous: this renderer converts glyphs to geometry, so
# an SVG of a picture reading "VP Sales" contains neither "VP Sales" nor
# "VP_Sales" -- "it says the right thing" and "it never says the wrong
# thing" were both true of a file containing no text whatsoever.
#
# What CAN be asserted about a rasterised label is that the two spellings
# produce different pictures, and that one spelling always produces the
# same one. Then "the label reaches the picture" is a claim about ink.
#---------------------------------------------------------------------------

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
cSpace  = _LabelPixels("VP Sales", oFont)
cScore  = _LabelPixels("VP_Sales", oFont)
cAgain  = _LabelPixels("VP Sales", oFont)

chk("the same label renders the same picture twice", cSpace = cAgain)
chk("a space and an underscore are NOT the same picture", cSpace != cScore)

oH = new stzDiagram("org")
oH.AddNodeXTT("vp", "VP Sales", [ :type = "box", :color = "Primary.Solid" ])
chk("...and the label a diagram carries is the one authored",
    oH.Nodes()[1][:label] = "VP Sales")
chk("the dot export carries it too, quoted",
    StzFindFirst('label="VP Sales"', oH.ToDot()) > 0)

oI = new stzGraph("nl")
oI.AddNodeXT("@x", "two" + char(10) + "lines")
chk("a NEWLINE is still normalised -- it would break the emitted dot",
    oI.Nodes()[1][:label] = "two_lines")

#---------------------------------------------------------------------------
? ""
? "-- 6. A parent sits OVER its children -----------------------"
#
# Ordering and placement are different questions, and only the first had an
# answer. The engine's sweep minimised crossings, then the face placed each
# node at `position / (width + 1)` -- every layer stretched across the whole
# picture whatever its population. A layer of nine was spread as wide as a
# layer of sixteen, so a node's children were positioned by their ORDINAL
# rather than under their parent, and the bottom row of a 40-node tree
# fanned across the entire canvas on long diagonals.
#
# The property is measured, not eyeballed: how far, on average, a parent
# sits from the centre of its own children.
#---------------------------------------------------------------------------

CW = 1200
oGr = new stzGraph("tree")
for i = 1 to 40  oGr.AddNode("n" + i)  next
for i = 2 to 40  oGr.Connect("n" + floor(i / 2), "n" + i)  next
oGC = new stzGraphCanvas(oGr, [ :Layout = :Hierarchical,
	:Width = CW, :Height = 600 ])
aPos = oGC.Positions()

nErr = _MeanCentringError(aPos, CW)
? "   a parent's distance from the centre of its children"
? "   placed by the engine  : " + nErr + "% of the canvas width"
chk("a parent sits over its children", nErr < 4)

# THE NEGATIVE SIBLING, and the proof that PLACEMENT is what changed: the
# very same layout, the very same order, respaced the old way -- each layer
# spread evenly across the full width by ordinal.
nOld = _MeanCentringError(_RespaceByOrdinal(aPos, CW), CW)
? "   respaced by ordinal   : " + nOld + "% -- the placement it replaced"
chk("...and the ordinal spread really was worse", nOld > nErr * 2)

#---------------------------------------------------------------------------
? ""
? "-- 7. Spacing is the CONTRACT; the size is derived ----------"
#
# dot's model, and this tier had it inverted: the caller fixed a canvas
# and the layout stretched to fill it, so the minimum gap between nodes
# was whatever the stretch left over -- 2px in a crowded rank, 20px in a
# loose one, in the same picture. Meanwhile SetNodeSeparation existed, in
# dot's own units, and only the DOT WRITER read it.
#
# So: a render that names no size must honour the separation contract
# EXACTLY -- the tightest gap in the picture IS nodesep, because the
# engine's isotonic pass pins the tightest pair at exactly one slot.
#---------------------------------------------------------------------------

oN = new stzDiagram("fan2")
oN.AddNodeXTT("root", "Root", [ :type = "box", :color = NODEC ])
for i = 1 to 16
	oN.AddNodeXTT("k" + i, "Kid " + i, [ :type = "box", :color = NODEC ])
	oN.AddEdge("root", "k" + i)
next
nSep = floor(oN.NodeSeparation() * 96)
oNat = oN.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 34 ])
? "   contract : nodesep = " + nSep + "px   canvas derived : " +
  oNat.Width() + "x" + oNat.Height()
nGap = _MinGapPx(oNat, oNat.Width(), oNat.Height(), NODEC)
? "   tightest gap in the natural render : " + nGap + "px"
chk("the tightest gap IS the nodesep contract (within stroke+AA)",
    nGap >= nSep - 8 and nGap <= nSep + 2)

# THE NEGATIVE SIBLING: the same diagram forced into a canvas too small
# for the contract must break it -- otherwise the check above would pass
# on any renderer that leaves big gaps for any reason at all.
oCr = oN.ToCanvasXT([ :Width = 700, :Height = 240,
	:NodeWidth = 96, :NodeHeight = 34 ])
nCr = _MinGapPx(oCr, 700, 240, NODEC)
? "   the same diagram crushed into 700px : " + nCr + "px"
chk("...and a canvas too small for the contract breaks it", nCr < nSep - 20)

#---------------------------------------------------------------------------
? ""
? "-- 8. A long edge goes AROUND the boxes, not through them ---"
#
# The step of the Sugiyama pipeline that was missing. An edge spanning
# more than one rank was a straight line from source to target, so a
# 9-stage pipeline with a 1->9 edge drew that edge across seven boxes.
# No routing rule could have saved it: the edge had no presence in the
# ranks it crossed, so nothing reserved room for it. Dummy nodes give it
# one, and the chain read back out IS the route.
#
# Measured in pixels, over the node fill: a routed edge never paints
# grey inside a box.
#---------------------------------------------------------------------------

BLU = "#1E6FE0"
oL = new stzDiagram("pipe")
for i = 1 to 9
	oL.AddNodeXTT("s" + i, "Stage " + i, [ :type = "box", :color = BLU ])
next
for i = 1 to 8  oL.AddEdge("s" + i, "s" + (i+1))  next
oL.AddEdge("s1", "s9")          # spans eight ranks
oL.AddEdge("s2", "s7")          # spans five

oLc = oL.ToCanvasXT([ :NodeWidth = 110, :NodeHeight = 34 ])
nCross = _EdgeInkInsideBoxes(oLc, oLc.Width(), oLc.Height(), BLU)
? "   canvas " + oLc.Width() + "x" + oLc.Height() +
  "   edge ink found inside node boxes : " + nCross
chk("no long edge is drawn through a node", nCross = 0)

# THE NEGATIVE SIBLING: the instrument must be able to SEE an edge over a
# box, so draw one deliberately and measure the same way.
oX = new stzCanvas(200, 120)
oX.SetBackgroundQ("#FFFFFF")
oX.FillQ(BLU).AddRect(40, 30, 120, 60)
oX.Flush()
oX.AddLineQ(20, 60, 180, 60).Stroke("#8A8A8A", 2)
nX = _EdgeInkInsideBoxes(oX, 200, 120, BLU)
? "   a line drawn deliberately across a box reads : " + nX
chk("the crossing check DISCRIMINATES", nX > 0)

#---------------------------------------------------------------------------
? ""
? "-- 9. A cluster box holds its members, and NO STRANGER -------"
#
# A cluster used to be a box drawn around whatever the layout produced.
# It never constrained anything, so a cluster whose members did not
# happen to land together got a box containing other people's nodes: two
# databases at opposite ends of a rank gave a "Data" box with the logger
# sitting inside it. The drawing was faithful and the box was correct --
# it bounded its members exactly, and its members were scattered.
#
# The property is about CONTAINMENT, so it is measured in the geometry a
# reader sees: is a non-member's box inside the cluster's rectangle.
#---------------------------------------------------------------------------

oS = new stzDiagram("svc")
for a in [ [ "web1", "Web A" ], [ "web2", "Web B" ], [ "api1", "API A" ],
           [ "api2", "API B" ], [ "db1", "DB A" ], [ "db2", "DB B" ],
           [ "lb", "Balancer" ], [ "log", "Logger" ] ]
	oS.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oS.AddEdge("lb", "web1")    oS.AddEdge("lb", "web2")
oS.AddEdge("web1", "api1")  oS.AddEdge("web2", "api2")
oS.AddEdge("api1", "db1")   oS.AddEdge("api2", "db2")
oS.AddEdge("web1", "log")   oS.AddEdge("api2", "log")
oS.AddClusterXTT("front", "Frontend", [ "web1", "web2" ], "#C2185B")
oS.AddClusterXTT("data", "Data", [ "db1", "db2" ], "#2E7D32")

BW = 110  BH = 34
aP2 = _DiagramXY(oS, BW, BH)
nIntr = _StrangersInClusters(oS, aP2, BW, BH)
? "   non-members found inside a cluster box : " + nIntr
chkeq("a cluster contains only its own", nIntr, 0)

# ...and it must still CONTAIN them -- a box that holds nobody would also
# score zero intruders, which is the way this assertion could pass while
# meaning nothing.
nHeld = _MembersInClusters(oS, aP2, BW, BH)
? "   members found inside their own box     : " + nHeld + " of 4"
chkeq("...and it does contain all of them", nHeld, 4)

# THE NEGATIVE SIBLING: the same measurement against a cluster whose
# members are deliberately NOT together must report an intruder, or the
# check cannot tell a constrained layout from an unconstrained one.
oB2 = new stzDiagram("bad")
for a in [ [ "x1", "X1" ], [ "mid", "Mid" ], [ "x2", "X2" ], [ "r", "R" ] ]
	oB2.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oB2.AddEdge("r", "x1")  oB2.AddEdge("r", "mid")  oB2.AddEdge("r", "x2")
oB2.AddClusterXTT("ends", "Ends", [ "x1", "x2" ], "#C2185B")
aB2 = _DiagramXY(oB2, BW, BH)
# force the scattered arrangement the constraint exists to prevent
aB2 = [ [ "x1", 100, 200 ], [ "mid", 300, 200 ], [ "x2", 500, 200 ],
        [ "r", 300, 80 ] ]
nBad2 = _StrangersInClusters(oB2, aB2, BW, BH)
? "   a deliberately scattered cluster reports : " + nBad2
chk("the containment check DISCRIMINATES", nBad2 > 0)

#---------------------------------------------------------------------------
? ""
? "-- 10. A self-loop is a LOOP, and is allowed ----------------"
#
# Two defects sat on top of each other here, and the first hid the second.
#
# A self-loop made the whole diagram UNRENDERABLE. Longest-path layering
# treats `lay[u]+1 > lay[u]` as never settling, so one self-edge had the
# engine refuse the graph as cyclic -- a state machine with a single
# "stay in this state" arrow could not be drawn at all, and the message
# blamed a cycle its author would not recognise as one. A self-loop
# constrains nothing about a node's depth, so layering ignores it.
#
# Underneath that, the loop drew as NOTHING: both ends clip to the same
# point, so the generic path emitted a zero-length segment. The most
# complete kind of rendering bug -- there is nothing wrong to notice.
#---------------------------------------------------------------------------

LOOPC = "#1E6FE0"
oSL = new stzDiagram("fsm")
for a in [ [ "a", "Idle" ], [ "b", "Busy" ], [ "c", "Done" ] ]
	oSL.AddNodeXTT(a[1], a[2], [ :type = "box", :color = LOOPC ])
next
oSL.AddEdge("a", "a")
oSL.AddEdge("b", "b")
oSL.AddEdge("a", "b")
oSL.AddEdge("b", "c")

# it RENDERS at all -- the layering fix
oSLc = oSL.ToCanvasXT([ :NodeWidth = 110, :NodeHeight = 40 ])
? "   a graph with self-loops renders : " + oSLc.Width() + "x" + oSLc.Height()
chk("a self-loop no longer refuses the whole picture", oSLc.Width() > 0)

# ...and the loop is VISIBLE, in the space beyond the node it belongs to
nInk = _InkRightOfBoxes(oSLc, oSLc.Width(), oSLc.Height(), LOOPC)
? "   edge ink drawn beside the nodes : " + nInk
chk("the loop is actually drawn", nInk > 20)

# THE NEGATIVE SIBLING: the same diagram WITHOUT the self-loops must have
# nothing out there, or this counts any stray pixel as a loop.
oNL2 = new stzDiagram("fsm2")
for a in [ [ "a", "Idle" ], [ "b", "Busy" ], [ "c", "Done" ] ]
	oNL2.AddNodeXTT(a[1], a[2], [ :type = "box", :color = LOOPC ])
next
oNL2.AddEdge("a", "b")
oNL2.AddEdge("b", "c")
oNL2c = oNL2.ToCanvasXT([ :NodeWidth = 110, :NodeHeight = 40 ])
nNo = _InkRightOfBoxes(oNL2c, oNL2c.Width(), oNL2c.Height(), LOOPC)
? "   the same graph with no self-loops : " + nNo
chk("the loop check DISCRIMINATES", nNo < nInk / 4)

# PARALLEL EDGES ARE REFUSED BY DESIGN, not missing by accident. stzGraph
# is a SIMPLE graph, and a silently doubled edge would corrupt every count,
# path and metric that walks the adjacency. Asserted so the decision cannot
# be reversed by accident -- and so the refusal keeps SAYING what to do.
chk("a parallel edge is refused", Raises('
	o = new stzGraph("g")
	o.AddNode("a")  o.AddNode("b")
	o.AddEdge("a", "b")
	o.AddEdge("a", "b")
'))
try
	oPE = new stzGraph("g")
	oPE.AddNode("a")  oPE.AddNode("b")
	oPE.AddEdge("a", "b")
	oPE.AddEdge("a", "b")
catch
	cPE = cCatchError
done
chk("...and the refusal names the model, not just the fact",
    StzFindFirst("simple graph", StzLower(cPE)) > 0)
chk("...and points at the way forward",
    StzFindFirst("connectifabsent", StzLower(cPE)) > 0)

# a SECOND self-loop is that same refusal, and says so in its own words
try
	oSD = new stzGraph("g")
	oSD.AddNode("a")
	oSD.AddEdge("a", "a")
	oSD.AddEdge("a", "a")
catch
	cSD = cCatchError
done
? "   " + cSD
chk("a second self-loop is refused as the parallel edge it is",
    StzFindFirst("self-loop", StzLower(cSD)) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 11. An edge label reaches the PICTURE --------------------"
#
# The labels were in the model, they reached the dot writer, and this
# tier never drew them: an edge that said "fails check" in the data was
# an anonymous arrow on the page. Nothing failed anywhere, because every
# test that cared about edge labels asked the MODEL or the DOT, and both
# were right.
#---------------------------------------------------------------------------

EFONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oEL = new stzDiagram("flow")
for a in [ [ "req", "Request" ], [ "val", "Validate" ],
           [ "ok", "Accept" ], [ "no", "Reject" ] ]
	oEL.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oEL.AddEdgeXT("req", "val", "submits")
oEL.AddEdgeXT("val", "ok", "passes")
oEL.AddEdgeXT("val", "no", "fails check")

# THE SAME DIAGRAM, LABELLED AND NOT, COMPARED PIXEL FOR PIXEL. Counting
# ink in the rank gaps needed a rule for "which rows are gaps", and every
# rule got it wrong: everything non-white swept up the EDGES, which are
# present either way; restricting to dark pixels then swept up the node
# BORDERS, which are darker than the text and sit on exactly the rows a
# node-fill test calls empty. Both measured something real and neither
# measured labels. Two renders differing ONLY in their labels need no
# such rule -- whatever changed IS the labels.
aLOpt = [ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 40 ]
oELc = oEL.ToCanvasXT(aLOpt)

oNL3 = new stzDiagram("flow2")
for a in [ [ "req", "Request" ], [ "val", "Validate" ],
           [ "ok", "Accept" ], [ "no", "Reject" ] ]
	oNL3.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oNL3.AddEdge("req", "val")  oNL3.AddEdge("val", "ok")  oNL3.AddEdge("val", "no")
oNL3c = oNL3.ToCanvasXT(aLOpt)

? "   canvases : labelled " + oELc.Width() + "x" + oELc.Height() +
  ", unlabelled " + oNL3c.Width() + "x" + oNL3c.Height()
nDiffL = _PixelsDiffering(oELc, oNL3c)
? "   pixels differing between the two renders : " + nDiffL
chk("an edge label is actually drawn", nDiffL > 300)

# THE NEGATIVE SIBLING: the same diagram rendered TWICE must differ in
# nothing at all, or the comparison is reporting noise.
nSame = _PixelsDiffering(oELc, oEL.ToCanvasXT(aLOpt))
? "   the labelled diagram against ITSELF : " + nSame
chkeq("the label check DISCRIMINATES", nSame, 0)

# ...and the gap GROWS to hold them WHEN IT HAS TO. At the default rank
# separation there is already room -- 76px of gap against the ~62px a
# line of text needs -- so asserting the labelled picture is simply
# taller compares two diagrams that both had enough space, and fails on a
# working reservation. The property only has teeth where the gap is too
# small to write in, so that is where it is asked.
aTight = [ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 40, :RankSep = 8 ]
nTightL = oEL.ToCanvasXT(aTight).Height()
nTightN = oNL3.ToCanvasXT(aTight).Height()
? "   with :RankSep = 8 -- labelled " + nTightL +
  ", unlabelled " + nTightN
chk("a labelled diagram reserves the room to write in", nTightL > nTightN)
chk("...and an unlabelled one keeps the separation it asked for",
    nTightN < oNL3c.Height())

#---------------------------------------------------------------------------
? ""
? "-- 12. SetLayout HONOURS what it accepted -------------------"
#
# It took any string and stored it. An unrecognised name fell through
# _NativeRankDir's default and became top-down IN SILENCE -- so
# SetLayout(:LeftToRight) drew a top-down picture with nothing anywhere
# saying the instruction had been dropped. Every horizontal caller in
# this library was affected, because the vertical directions had seven
# spellings each and the horizontal ones had exactly one.
#---------------------------------------------------------------------------

for aL in [ [ :TopDown, "TB" ], [ :BottomUp, "BT" ],
            [ :LeftRight, "LR" ], [ :LeftToRight, "LR" ],
            [ :RightLeft, "RL" ], [ "lr", "LR" ] ]
	oLy = new stzDiagram("t")
	oLy.SetLayout(aL[1])
	chkeq("  " + aL[1] + " means " + aL[2], oLy._NativeRankDir(), aL[2])
next

chk("an unknown layout is REFUSED, not silently defaulted", Raises('
	o = new stzDiagram("t")
	o.SetLayout(:Sideways)
'))
try
	oLB = new stzDiagram("t")
	oLB.SetLayout(:Sideways)
catch
	cLB = cCatchError
done
chk("...and the refusal lists what IS accepted",
    StzFindFirst("lefttoright", StzReplace(StzLower(cLB), ":", "")) > 0 or
    StzFindFirst("leftright", StzReplace(StzLower(cLB), ":", "")) > 0)

# a graphviz ENGINE name is a different axis and stays accepted
chk("an engine name is still accepted", NOT Raises('
	o = new stzDiagram("t")
	o.SetLayout("dot")
'))

#---------------------------------------------------------------------------
? ""
? "-- 13. ORTHO means ortho, including the self-loops ----------"
#
# The loop ignored the spline setting entirely and was always a curve, so
# a picture asked for splines=ortho came back with every edge
# right-angled EXCEPT its self-loops -- one rounded shape among the
# corners, which reads as a mistake rather than a style.
#
# The property is not "the loop looks different now", it is that EVERY
# segment in the picture is axis-aligned. Read off the emitted geometry,
# which is where that is decidable.
#---------------------------------------------------------------------------

oOr = new stzDiagram("fsm3")
for a in [ [ "a", "Idle" ], [ "b", "Busy" ], [ "c", "Done" ] ]
	oOr.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oOr.AddEdge("a", "a")
oOr.AddEdge("b", "b")
oOr.AddEdge("a", "b")
oOr.AddEdge("b", "c")

oOr.SetSplines("ortho")
EDGERGB = "rgb(138,138,138)"      # the default edge colour, #8A8A8A
nSkew = _NonAxialSegments(oOr.ToSVGXT([ :NodeWidth = 110, :NodeHeight = 40 ]), EDGERGB)
? "   segments that are neither horizontal nor vertical : " + nSkew
chkeq("under ortho, every segment is axis-aligned", nSkew, 0)

# THE NEGATIVE SIBLING: the same diagram with curves must be full of
# segments that are neither -- otherwise this counts nothing at all,
# which is also zero.
oOr.SetSplines("spline")
nCurve = _NonAxialSegments(oOr.ToSVGXT([ :NodeWidth = 110, :NodeHeight = 40 ]), EDGERGB)
? "   the same diagram with curves : " + nCurve
chk("the orthogonality check DISCRIMINATES", nCurve > 20)

# ...and the LOOP specifically is what changed, not just the edges: with
# no self-loops at all, ortho and curve differ far less.
oNS = new stzDiagram("fsm4")
for a in [ [ "a", "Idle" ], [ "b", "Busy" ], [ "c", "Done" ] ]
	oNS.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oNS.AddEdge("a", "b")  oNS.AddEdge("b", "c")
oNS.SetSplines("spline")
nCurveNS = _NonAxialSegments(oNS.ToSVGXT([ :NodeWidth = 110, :NodeHeight = 40 ]), EDGERGB)
? "   curves, but no self-loops : " + nCurveNS
# A VERTICAL CHAIN IS STRAIGHT EVEN IN CURVE MODE -- the quadratic between
# two nodes stacked in one column IS a vertical line -- so this is zero,
# and every segment counted above came from the loops. Asserted as an
# EQUALITY: written as `nCurve > nCurveNS * 1.5` it passes for any
# positive count at all, since anything beats zero.
chkeq("a straight vertical chain has no diagonal segments either way",
      nCurveNS, 0)
chk("...so ALL the curved segments came from the self-loops", nCurve > 20)

#---------------------------------------------------------------------------
? ""
? "-- 14. NESTED clusters: a box inside a box ------------------"
#
# The constraint form was recorded as unable to express nesting. It can,
# once the constraints are applied PER DEPTH -- and the nesting itself
# needs no new API, because a cluster whose node set is a subset of
# another's already IS inside it. Asking the author to also declare a
# parent would be a second statement of one fact, free to disagree.
#
# Three properties, and the third is the one that makes it nesting
# rather than two boxes that happen not to collide.
#---------------------------------------------------------------------------

oNC = new stzDiagram("svc2")
for a in [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
           [ "api1", "API A" ], [ "api2", "API B" ],
           [ "db1", "DB A" ], [ "db2", "DB B" ], [ "log", "Logger" ] ]
	oNC.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oNC.AddEdge("lb", "web1")    oNC.AddEdge("lb", "web2")
oNC.AddEdge("web1", "api1")  oNC.AddEdge("web2", "api2")
oNC.AddEdge("api1", "db1")   oNC.AddEdge("api2", "db2")
oNC.AddEdge("web1", "log")   oNC.AddEdge("api2", "log")
oNC.AddClusterXTT("backend", "Backend",
	[ "api1", "api2", "db1", "db2" ], "#5E35B1")
oNC.AddClusterXTT("data", "Data", [ "db1", "db2" ], "#2E7D32")

# 1. the nesting is INFERRED, and the right way round
aD = oNC._ClusterDepths()
? "   depths : " + aD[1][1] + "=" + aD[1][3] + "  " + aD[2][1] + "=" + aD[2][3]
chkeq("the outer cluster is depth 1", aD[1][1], "backend")
chkeq("...and the inner one depth 2", aD[2][3], 2)

# 2. neither box holds a stranger
NBW = 100  NBH = 34
aNP = _DiagramXY(oNC, NBW, NBH)
nNStr = _StrangersInClusters(oNC, aNP, NBW, NBH)
? "   non-members inside either box : " + nNStr
chkeq("no cluster holds a stranger, nested or not", nNStr, 0)

# 3. THE NESTING ITSELF: the inner box lies wholly within the outer.
#    Without this, two disjoint boxes drawn side by side would satisfy
#    everything above and be no kind of nesting at all.
aOut = oNC._ClusterBox(oNC._ClusterById("backend"), _ClusterXY(aNP), NBW, NBH)
aIn  = oNC._ClusterBox(oNC._ClusterById("data"), _ClusterXY(aNP), NBW, NBH)
? "   outer " + aOut[1] + "," + aOut[2] + " " + aOut[3] + "x" + aOut[4] +
  "   inner " + aIn[1] + "," + aIn[2] + " " + aIn[3] + "x" + aIn[4]
chk("the inner box lies wholly inside the outer",
    aIn[1] >= aOut[1] and aIn[2] >= aOut[2] and
    aIn[1] + aIn[3] <= aOut[1] + aOut[3] and
    aIn[2] + aIn[4] <= aOut[2] + aOut[4])

# ...and with ROOM for the inner cluster's own label, which is drawn 24px
# above its box. Two borders a few pixels apart would pass the test above
# and still write one label across the other.
chk("...with room above it for its label",
    aIn[2] - aOut[2] >= 24)

# 4. PARTIAL OVERLAP is refused -- two boxes cannot both hold all their
#    own members without one holding a stranger.
chk("clusters that overlap without nesting are REFUSED", Raises('
	o = new stzDiagram("t")
	for c in [ "a", "b", "c" ]
		o.AddNodeXTT(c, c, [ :type = "box" ])
	next
	o.AddEdge("a", "b")  o.AddEdge("b", "c")
	o.AddClusterXTT("x", "X", [ "a", "b" ], "#C2185B")
	o.AddClusterXTT("y", "Y", [ "b", "c" ], "#2E7D32")
	o.ToCanvasXT([ :NodeWidth = 90, :NodeHeight = 30 ])
'))

# THE NEGATIVE SIBLING for that refusal: a genuine NESTING must NOT be
# refused. The first version of the check tested containment in one
# direction only, so every legitimate outer cluster raised the error
# written to forbid a non-nesting -- the refusal fired on exactly the
# case it was meant to permit.
chk("...but a genuine nesting is NOT refused", NOT Raises('
	o = new stzDiagram("t")
	for c in [ "a", "b", "c" ]
		o.AddNodeXTT(c, c, [ :type = "box" ])
	next
	o.AddEdge("a", "b")  o.AddEdge("b", "c")
	o.AddClusterXTT("big", "Big", [ "a", "b", "c" ], "#C2185B")
	o.AddClusterXTT("small", "Small", [ "b", "c" ], "#2E7D32")
	o.ToCanvasXT([ :NodeWidth = 90, :NodeHeight = 30 ])
'))

#---------------------------------------------------------------------------
? ""
? "-- 15. Edge labels STEER the layout ------------------------"
#
# Reserving gap HEIGHT gave a label somewhere to be written and did
# nothing about width, so two edges running close together still fought
# over the same horizontal space and the loser was nudged onto something
# else. Nudging moves the label; only the layout can make ROOM.
#
# A label lives between two ranks, so no node owns it. The demand is
# charged to the TARGET, whose rank then spreads -- and the label is
# placed at a known fraction along its edge so it inherits that spread.
# Those two numbers are the same number seen from two sides, which is why
# _EdgeLabelBias exists and both read it.
#---------------------------------------------------------------------------

SFONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
aSO = [ :Font = SFONT, :NodeWidth = 70, :NodeHeight = 34 ]

oShort = _Fan("c")
oWide  = _Fan("condition number  holds ")
nWShort = oShort.ToCanvasXT(aSO).Width()
nWWide  = oWide.ToCanvasXT(aSO).Width()
? "   canvas with short labels : " + nWShort
? "   canvas with wide  labels : " + nWWide
chk("wide labels widen the picture", nWWide > nWShort * 1.4)

# THE MECHANISM, and its negative sibling in one: the demand is what
# widened it, and it is ZERO when a label is no wider than the node it
# points at -- so an ordinary diagram of short labels is laid out exactly
# as it was before any of this existed.
SLOT = 70 + floor(oShort.NodeSeparation() * 96)
aDS = oShort._LabelDemand(SFONT, 14, 70, SLOT, 0)
aDW = oWide._LabelDemand(SFONT, 14, 70, SLOT, 0)
? "   demand, short : " + @@(aDS)
? "   demand, wide  : " + @@(aDW)
chkeq("a short label demands nothing at all", _MaxOf(aDS), 0)
chk("a wide label demands room", _MaxOf(aDW) > 0.2)

# CHARGED TO THE TARGET, not the source. The router has no incoming
# labelled edge and must demand nothing; its four children must each
# demand the same. Charging the source would widen one rank too early and
# leave the labels as crowded as before.
chkeq("the source of a labelled edge demands nothing", aDW[1], 0)
chk("...and every target demands the same room",
    aDW[2] = aDW[3] and aDW[3] = aDW[4] and aDW[4] = aDW[5])

# THE TWO NUMBERS AGREE. The demand divides by the bias because the label
# stands at that fraction of the way to its target; if the drawing used a
# different fraction the layout would buy space the label is not standing
# in. Asserted by measuring where the label ACTUALLY lands.
oB = new stzDiagram("bias")
oB.AddNodeXTT("p", "P", [ :type = "box", :color = "Info.Solid" ])
oB.AddNodeXTT("q", "Q", [ :type = "box", :color = "Info.Solid" ])
oB.AddEdgeXT("p", "q", "WWWWWWWWWWWWWWWW")
nBias = oB._EdgeLabelBias()
? "   the shared bias : " + nBias
chk("the bias is a fraction of the way to the target",
    nBias > 0.5 and nBias < 1)

#---------------------------------------------------------------------------
? ""
? "-- 16. The edge grammar is DOT'S, asserted against dot's rules ----"
#
# This section has been rewritten ONCE, and the history is the lesson.
# Its first version asserted square tangents at BOTH ends -- a model
# built from intuition, and the wrong one: rendering the same diagrams
# through dot.exe showed near-straight edges AIMED at their targets, a
# soft departure only, and arrowheads pointing along the line. The old
# assertions passed perfectly, because the code satisfied the model and
# the MODEL was what disagreed with the reference. An assertion is only
# as good as the grammar behind it; this one now encodes dot's, learned
# from dot's own output rather than assumed.
#---------------------------------------------------------------------------

oQ = new stzDiagram("q")
oQ.AddNodeXTT("p", "P", [ :type = "box", :color = "Info.Solid" ])
oQ.AddNodeXTT("c", "C", [ :type = "box", :color = "Info.Solid" ])
oQ.AddEdge("p", "c")
QW = 120  QH = 40

# a strongly lateral hop -- the case every fault showed on
aGm = oQ._EdgeGeometry([ 200, 100 ], [ 480, 240 ], QW, QH, "TB", 2)
aFl = aGm[1]
aBs = aGm[2]
aTp = aGm[3]
nFn = len(aFl)

# 1. THE TIP IS ON THE TARGET BORDER. dot clips the spline at the node
#    and puts the head's point exactly there.
? "   tip " + aTp[1] + "," + aTp[2]
chk("the arrow tip touches the target's border",
    fabs(aTp[2] - (240 - QH/2)) < 1.5 or fabs(aTp[1] - (480 - QW/2)) < 1.5)

# 2. THE STROKE IS CUT FOR THE HEAD. The drawn line ends a head's length
#    short of the tip -- drawing to the tip and stamping a head over it is
#    how lines poke past arrowheads.
nGap = sqrt((aTp[1]-aFl[nFn-1])*(aTp[1]-aFl[nFn-1]) +
            (aTp[2]-aFl[nFn])*(aTp[2]-aFl[nFn]))
? "   stroke stops " + nGap + "px short of the tip (head length 13)"
chk("the stroke is cut a head's length before the tip",
    nGap > 10 and nGap < 16)

# 3. THE HEAD POINTS ALONG THE ARRIVING LINE. The base the head is built
#    on IS the last point of the stroke, so head and line cannot disagree
#    by construction -- asserted anyway, against the aim line.
nAimX = 480 - 200
nAimY = 240 - 100
nAimL = sqrt(nAimX*nAimX + nAimY*nAimY)
nHdX = (aTp[1] - aBs[1])
nHdY = (aTp[2] - aBs[2])
nHdL = sqrt(nHdX*nHdX + nHdY*nHdY)
nDot = (nAimX*nHdX + nAimY*nHdY) / (nAimL * nHdL)
? "   head direction vs aim line, cosine : " + nDot
chk("the head points the way the edge travels", nDot > 0.97)

# 4. ONE BEND, ALWAYS OUTWARD -- the outer arc. An S-curve crosses its
#    own chord; dot's edges never do. Signed area side of every sample
#    against the chord must not change sign.
nPos = 0
nNeg = 0
for i = 1 to nFn / 2
	_sx_ = aFl[i*2-1] - aFl[1]
	_sy_ = aFl[i*2] - aFl[2]
	_cr_ = (aFl[nFn-1]-aFl[1]) * _sy_ - (aFl[nFn]-aFl[2]) * _sx_
	if _cr_ > 0.5  nPos++  ok
	if _cr_ < -0.5  nNeg++  ok
next
? "   samples left of the chord " + nPos + ", right " + nNeg
chk("the curve stays on ONE side of its chord -- an arc, never an S",
    nPos = 0 or nNeg = 0)

# THE NEGATIVE SIBLING: the OLD model, still present driving the ortho
# arrowhead, is a quadratic that fails rule 3 -- its arrival is square
# regardless of the aim, so head and line disagree on a lateral edge.
aQ2 = oQ._CurvePoints([ 200, 120 ], [ 480, 220 ], "TB")
nQ2 = len(aQ2)
nOdX = aQ2[nQ2-1] - aQ2[nQ2-3]
nOdY = aQ2[nQ2] - aQ2[nQ2-2]
nOdL = sqrt(nOdX*nOdX + nOdY*nOdY)
nDot2 = (nAimX*nOdX + nAimY*nOdY) / (nAimL * nOdL)
? "   the old curve's arrival vs the aim, cosine : " + nDot2
chk("the old model really did arrive off the aim, which this must see",
    nDot2 < 0.97)

#---------------------------------------------------------------------------
? ""
? "-- 17. Sparse ranks are TIGHT, measured against dot ---------"
#
# The dense ranks always matched dot; the sparse upper ones did not, and
# nothing in this file could see it because every assertion here was
# about a picture on its own terms. Rendering the same 40-node tree
# through dot.exe and comparing SPANS in scale-free units (each
# renderer's own tightest gap = 1) gave: rank of 16 at 0.97x, rank of 8
# at 1.03x -- and the rank of four at 1.21x, the rank of TWO at 2.09x.
#
# THE CAUSE WAS THE OBJECTIVE. Relaxing each layer against the mean of
# one side pins a parent exactly at its children's mean, with no freedom
# left, so a sparse rank is dragged apart by the subtrees below it. dot
# minimises total ABSOLUTE edge length, where a parent anywhere between
# its children costs the same and the slack is spent pulling it toward
# its own parent. A pass relaxing against BOTH directions at once
# recovers most of that.
#
# The numbers below are dot's, measured from `dot -Tplain` on this exact
# tree, not invented thresholds.
#---------------------------------------------------------------------------

oTT = new stzGraph("t40")
for i = 1 to 40  oTT.AddNode("n" + i)  next
for i = 2 to 40  oTT.Connect("n" + floor(i / 2), "n" + i)  next
oTC = new stzGraphCanvas(oTT, [ :Layout = :Hierarchical,
	:Width = 1000, :Height = 700, :Margin = 0 ])
aTP = oTC.Positions()

# dot -Tplain, same tree: tightest gap 1.458in; spans in those units
aDotSpan = [ [ 2, 4.0 ], [ 4, 10.5 ], [ 8, 15.0 ], [ 16, 17.5 ], [ 9, 8.0 ] ]
nUnit = _TightestGap(aTP)
? "   rank | dot | ours | ratio"
nWorst = 0
for aD in aDotSpan
	nOurs = _RankSpan(aTP, aD[1]) / nUnit
	nR = nOurs / aD[2]
	? "   n=" + aD[1] + "   | " + aD[2] + " | " + nOurs + " | " + nR + "x"
	if fabs(nR - 1) > nWorst  nWorst = fabs(nR - 1)  ok
next
? "   worst departure from dot : " + nWorst
chk("every rank is within half of dot's own span", nWorst < 0.5)

# THE NEGATIVE SIBLING is the measurement that started this: 2.09x on the
# rank of two. Asserted as a number so a regression to the one-sided
# relaxation fails here rather than being noticed by eye months later.
nTwo = _RankSpan(aTP, 2) / nUnit / 4.0
? "   the rank of two, which was 2.09x before the combined pass : " + nTwo + "x"
chk("the rank that was worst is no longer twice dot's width", nTwo < 1.6)

#---------------------------------------------------------------------------
? ""
? "-- 18. No node stands in another subtree's TERRITORY --------"
#
# The Principal's rule, and it is the one property none of the seventy
# assertions above could see: every one judged a RANK, and this is a
# claim ACROSS ranks. Node 39, a child of 19, sat between the two
# children of node 10 -- correctly ordered, correctly separated from its
# own neighbours, and standing inside a family it has nothing to do with,
# so the edge reaching it crossed the edge leaving 10. Order was right,
# separation was right, and the drawing still lied about the structure.
#
# A subtree owns the horizontal band from its leftmost to its rightmost
# descendant. Two siblings' bands must not overlap -- then no node can
# appear under a branch that is not its own, by construction.
#---------------------------------------------------------------------------

oTR = new stzGraph("t40b")
for i = 1 to 40  oTR.AddNode("n" + i)  next
for i = 2 to 40  oTR.Connect("n" + floor(i / 2), "n" + i)  next
oRC = new stzGraphCanvas(oTR, [ :Layout = :Hierarchical,
	:Width = 1000, :Height = 700, :Margin = 0 ])
aRP = oRC.Positions()

nOverlap = _OverlappingTerritories(aRP, 40)
? "   sibling subtrees whose bands overlap : " + nOverlap
chkeq("no subtree stands inside another's territory", nOverlap, 0)

# the case the Principal marked, named outright so a regression is
# readable rather than a number
nX39 = _XOf(aRP, "n39")
nLo20 = _SubtreeLo(aRP, 20, 40)
nHi20 = _SubtreeHi(aRP, 20, 40)
? "   node 39 at " + nX39 + " ; node 20's band " + nLo20 + ".." + nHi20
chk("node 39 is NOT inside node 20's band", nX39 < nLo20 or nX39 > nHi20)

# THE NEGATIVE SIBLING, and it caught a flaw in this very check before it
# caught anything about the layout. Written first against node 20's band,
# it reported no violation -- because node 20's subtree is a single chain
# and its band is a POINT (421.05..421.05), so putting node 39 exactly
# there failed the strict inequality by exact equality. A degenerate
# interval is not a place you can be inside of. It now uses node 5's
# band, which has real width.
nLo5 = _SubtreeLo(aRP, 5, 40)
nHi5 = _SubtreeHi(aRP, 5, 40)
aBad = []
for aP in aRP
	if StzLower("" + aP[1]) = "n39"
		aBad + [ aP[1], (nLo5 + nHi5) / 2, aP[3] ]
	else
		aBad + [ aP[1], aP[2], aP[3] ]
	ok
next
? "   node 5's band " + nLo5 + ".." + nHi5 +
  " ; with node 39 moved into it : " + _OverlappingTerritories(aBad, 40)
chk("the territory check DISCRIMINATES",
    _OverlappingTerritories(aBad, 40) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 19. A label must be READABLE on the node it sits on ------"
#
# The contrast system was built in C1-C5, shipped, guarded -- and the
# diagram tier called the naive helper standing next to it. StzContrastingText
# answered "white if the background is dark, black otherwise": a lightness
# TEST standing in for a contrast MEASUREMENT. On mid-tones the two
# disagree, and every semantic role is a mid-tone, so every node label in
# every diagram this library drew failed the minimum this library states:
# white on primary 3.77:1, success 3.41, warning 3.58, danger 4.12,
# against 4.5:1. Black would have cleared all five and was never
# considered, because nothing measured.
#
# A capability built and then not reached for is worse than one never
# built: the picture looked deliberate.
#---------------------------------------------------------------------------

nMin = StzContrastMinimumBodyText()
? "   the stated minimum for body text : " + nMin + ":1"
nWorstC = 99
cWorstR = ""
for cRole in [ :Primary, :Success, :Warning, :Danger, :Info, :Neutral ]
	cFill = StzResolveColor("" + cRole + ".Solid")
	if cFill = ""  loop  ok
	cTxt = StzResolveColor(StzContrastingText(cFill))
	nC = StzContrastOf(cTxt, cFill)
	? "   " + cRole + "  " + cFill + " -> " + cTxt + "  " + nC + ":1"
	if nC < nWorstC  nWorstC = nC  cWorstR = "" + cRole  ok
next
? "   worst role : " + cWorstR + " at " + nWorstC + ":1"
chk("every role's label clears the stated minimum", nWorstC >= nMin)

# THE NEGATIVE SIBLING: the rule this replaced, applied to the same
# fills, must FAIL -- otherwise "they all pass" says nothing about
# whether measuring was what fixed it.
nWorstOld = 99
for cRole in [ :Primary, :Success, :Warning, :Danger, :Info ]
	cFill = StzResolveColor("" + cRole + ".Solid")
	cOld = "black"
	if StzIsDarkColor(cFill)  cOld = "white"  ok
	nC = StzContrastOf(StzResolveColor(cOld), cFill)
	if nC < nWorstOld  nWorstOld = nC  ok
next
? "   the lightness-test rule would give, at worst : " + nWorstOld + ":1"
chk("the rule this replaced really did fail the minimum",
    nWorstOld < nMin)

#---------------------------------------------------------------------------
? ""
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=============================================================="

#---------------------------------------------------------------------------

func chk cWhat, bCond
	if bCond
		? "   ok   " + cWhat
		nOk++
	else
		? "  FAIL  " + cWhat
		nBad++
	ok

func chkeq cWhat, xGot, xWant
	chk(cWhat + "  [got " + xGot + ", want " + xWant + "]", xGot = xWant)

func _Solid nW, nH, r, g, b, a
	_sc_ = ""
	for _si_ = 1 to nW * nH
		_sc_ += char(r) + char(g) + char(b) + char(a)
	next
	return _sc_

func _PixelAt cPx, nW, nX, nY
	_pa_ = (nY * nW + nX) * 4 + 1
	return [ ascii(substr(cPx, _pa_, 1)), ascii(substr(cPx, _pa_ + 1, 1)),
	         ascii(substr(cPx, _pa_ + 2, 1)) ]

func _Near aGot, aWant, nTol
	for _ni_ = 1 to 3
		_nd_ = aGot[_ni_] - aWant[_ni_]
		if _nd_ < 0  _nd_ = -_nd_  ok
		if _nd_ > nTol  return FALSE  ok
	next
	return TRUE

# [ [ halfWidth, halfHeight ], ... ] for every POLYGON in an SVG.
#
# It reads polygons and not <ellipse> tags, and that correction is the whole
# reason the negative sibling below exists. The first version of this
# function looked for `<ellipse`, which the SVG tier never emits -- it
# flattens an ellipse to a polygon. So it found nothing, reported "0 caps
# deeper than wide", and the assertion PASSED on a canvas containing a
# deliberately broken cap. A check that reads the wrong tag agrees with
# every shape in the world.
func _CapsIn cSvg
	_ca_ = []
	_clen_ = StzLen(cSvg)
	for _cn_ in StzFindAll('<polygon points="', cSvg)
		_ctail_ = StzSubStr(cSvg, _cn_, min([ 4000, _clen_ - _cn_ + 1 ]))
		_cq_ = StzFindFirst('"', StzSubStr(_ctail_, 18, StzLen(_ctail_) - 17))
		if _cq_ = 0  loop  ok
		_cpts_ = StzSubStr(_ctail_, 18, _cq_ - 1)
		_cminx_ = -1  _cmaxx_ = -1  _cminy_ = -1  _cmaxy_ = -1
		for _cpair_ in StzSplit(_cpts_, " ")
			_cxy_ = StzSplit(StzTrim(_cpair_), ",")
			if len(_cxy_) != 2  loop  ok
			try
				_cx_ = 0 + _cxy_[1]
				_cy_ = 0 + _cxy_[2]
			catch
				loop
			done
			if _cminx_ < 0 or _cx_ < _cminx_  _cminx_ = _cx_  ok
			if _cmaxx_ < 0 or _cx_ > _cmaxx_  _cmaxx_ = _cx_  ok
			if _cminy_ < 0 or _cy_ < _cminy_  _cminy_ = _cy_  ok
			if _cmaxy_ < 0 or _cy_ > _cmaxy_  _cmaxy_ = _cy_  ok
		next
		if _cmaxx_ >= 0
			_ca_ + [ (_cmaxx_ - _cminx_) / 2, (_cmaxy_ - _cminy_) / 2 ]
		ok
	next
	return _ca_

func _HexRGB cHex
	_hh_ = StzUpper(StzReplace("" + cHex, "#", ""))
	if StzLen(_hh_) != 6  return [ -1, -1, -1 ]  ok
	_hd_ = "0123456789ABCDEF"
	_hr_ = []
	for _hi_ = 0 to 2
		_hA_ = StzFindFirst(StzSubStr(_hh_, _hi_ * 2 + 1, 1), _hd_) - 1
		_hB_ = StzFindFirst(StzSubStr(_hh_, _hi_ * 2 + 2, 1), _hd_) - 1
		if _hA_ < 0 or _hB_ < 0  return [ -1, -1, -1 ]  ok
		_hr_ + (_hA_ * 16 + _hB_)
	next
	return _hr_

# In the row containing the most of cHex, how many stretches of BACKGROUND
# separate one painted box from the next.
#
# Background and not the node colour, and gaps and not runs, for the reason
# in section 4: a stroked box that abuts its neighbour still reads as two
# runs of fill, so counting fill can never see the collision it was written
# to detect.
func _GapsInDensestRow oCanvas, nW, nH, cHex
	_mc_ = _HexRGB(cHex)
	_mpx_ = oCanvas.ToPixels()

	# The densest row: the one with the most node paint in it. Found on a
	# 4x4 STRIDE and then read in full -- a Ring loop over every pixel of a
	# 1200x500 canvas is 600,000 substr calls and takes minutes, which is
	# how the first version of this file came to be killed rather than run.
	# A box is tens of pixels tall, so a stride of 4 cannot miss one.
	_mrow_ = -1
	_mbest_ = 0
	for _my_ = 0 to nH - 1 step 4
		_mn_ = 0
		for _mx_ = 0 to nW - 1 step 4
			if _IsRGB(_mpx_, nW, _mx_, _my_, _mc_)  _mn_++  ok
		next
		if _mn_ > _mbest_  _mbest_ = _mn_  _mrow_ = _my_  ok
	next
	if _mrow_ < 0  return -1  ok

	# only BETWEEN the first and last box, so the empty canvas either side
	# is not counted as a gap
	_mfirst_ = -1  _mlast_ = -1
	for _mx_ = 0 to nW - 1
		if _IsRGB(_mpx_, nW, _mx_, _mrow_, _mc_)
			if _mfirst_ < 0  _mfirst_ = _mx_  ok
			_mlast_ = _mx_
		ok
	next
	if _mfirst_ < 0  return -1  ok

	_mgaps_ = 0
	_mlen_ = 0
	for _mx_ = _mfirst_ to _mlast_
		if _IsRGB(_mpx_, nW, _mx_, _mrow_, [ 255, 255, 255 ])
			_mlen_++
		else
			# 2px, so a stroke plus its antialiasing is never a "gap"
			if _mlen_ >= 2  _mgaps_++  ok
			_mlen_ = 0
		ok
	next
	if _mlen_ >= 2  _mgaps_++  ok
	return _mgaps_

# One node, one label, rendered -- the bytes of the picture.
func _LabelPixels cLabel, oFont
	_lo_ = new stzDiagram("lbl")
	_lo_.AddNodeXTT("n", cLabel, [ :type = "box", :color = "Primary.Solid" ])
	return _lo_.ToCanvasXT([ :Width = 300, :Height = 140, :Font = oFont ]).
		ToPixels()

# The WIDTH of the narrowest background gap between boxes in the densest
# row -- section 7's instrument. Section 4 counts gaps; this measures the
# tightest one, because the spacing contract is a number, not a count.
func _MinGapPx oCanvas, nW, nH, cHex
	_mg_ = _HexRGB(cHex)
	_mgpx_ = oCanvas.ToPixels()

	_mgrow_ = -1
	_mgbest_ = 0
	for _mgy_ = 0 to nH - 1 step 4
		_mgn_ = 0
		for _mgx_ = 0 to nW - 1 step 4
			if _IsRGB(_mgpx_, nW, _mgx_, _mgy_, _mg_)  _mgn_++  ok
		next
		if _mgn_ > _mgbest_  _mgbest_ = _mgn_  _mgrow_ = _mgy_  ok
	next
	if _mgrow_ < 0  return -1  ok

	_mgf_ = -1  _mgl_ = -1
	for _mgx_ = 0 to nW - 1
		if _IsRGB(_mgpx_, nW, _mgx_, _mgrow_, _mg_)
			if _mgf_ < 0  _mgf_ = _mgx_  ok
			_mgl_ = _mgx_
		ok
	next
	if _mgf_ < 0  return -1  ok

	# BETWEEN THE BOXES, not between the white. Measuring runs of background
	# said 2px on a picture whose boxes are 57px apart: an edge arriving at
	# a shallow angle runs almost horizontally along this row and chops each
	# gap into grey fragments, so the narrowest WHITE run is a stroke width
	# and has nothing to do with spacing. What the contract governs is the
	# distance from one box to the next, whatever is drawn in between.
	_mgmin_ = -1
	_mgend_ = -1
	_mglen_ = 0
	for _mgx_ = _mgf_ to _mgl_ + 1
		_mgis_ = 0
		if _mgx_ <= _mgl_
			_mgis_ = _IsRGB(_mgpx_, nW, _mgx_, _mgrow_, _mg_)
		ok
		if _mgis_
			_mglen_++
		else
			# 4px, so an antialiased sliver is not a "box"
			if _mglen_ >= 4
				if _mgend_ >= 0
					_mggap_ = (_mgx_ - _mglen_) - _mgend_ - 1
					if _mgmin_ < 0 or _mggap_ < _mgmin_  _mgmin_ = _mggap_  ok
				ok
				_mgend_ = _mgx_ - 1
			ok
			_mglen_ = 0
		ok
	next
	return _mgmin_

# How many pixels of EDGE ink sit inside a node box. A box is a solid run
# of its fill colour, so a grey pixel with fill on BOTH sides of it, on the
# same row, is an edge crossing that box -- and nothing else is.
func _EdgeInkInsideBoxes oCanvas, nW, nH, cHex
	_ec_ = _HexRGB(cHex)
	_epx_ = oCanvas.ToPixels()
	# SCANNED BY COLUMN, not by row. The row version could not see the case
	# it existed for: a line drawn across a box covers that whole row, so
	# no fill is left on it to bracket the ink, and the check reported a
	# clean picture of a deliberately dirty one. A pixel is inside a box
	# when the box continues ABOVE and BELOW it -- that survives an edge of
	# any thickness and any direction.
	_ehits_ = 0
	for _ey_ = 0 to nH - 1 step 3
		for _ex_ = 0 to nW - 1 step 2
			if _IsRGB(_epx_, nW, _ex_, _ey_, _ec_)  loop  ok
			if _IsRGB(_epx_, nW, _ex_, _ey_, [ 255, 255, 255 ])  loop  ok
			# ink. is there box above AND below, close by?
			_eup_ = 0
			for _ek_ = 1 to 8
				if _ey_ - _ek_ < 0  exit  ok
				if _IsRGB(_epx_, nW, _ex_, _ey_ - _ek_, _ec_)  _eup_ = 1  exit  ok
			next
			if _eup_ = 0  loop  ok
			_edn_ = 0
			for _ek_ = 1 to 8
				if _ey_ + _ek_ > nH - 1  exit  ok
				if _IsRGB(_epx_, nW, _ex_, _ey_ + _ek_, _ec_)  _edn_ = 1  exit  ok
			next
			if _edn_ = 1  _ehits_++  ok
		next
	next
	return _ehits_

func _IsRGB cPx, nW, nX, nY, aRGB
	_ir_ = (nY * nW + nX) * 4 + 1
	return ascii(substr(cPx, _ir_, 1)) = aRGB[1] and
	       ascii(substr(cPx, _ir_ + 1, 1)) = aRGB[2] and
	       ascii(substr(cPx, _ir_ + 2, 1)) = aRGB[3]

# n nodes on one row, nGap apart -- the shape _RankFitScale reads.
func _Rank nCount, nGap
	_ra_ = []
	for _ri_ = 1 to nCount
		_ra_ + [ "n" + _ri_, 40 + (_ri_ - 1) * nGap, 100 ]
	next
	return _ra_

func _XOf aPos, cId
	for _p_ in aPos
		if StzLower("" + _p_[1]) = StzLower("" + cId)  return _p_[2]  ok
	next
	return -1

# Mean |parent.x - mean(children.x)| over the binary tree above, as a
# percentage of the canvas width. Scale-free, so the two placements are
# comparable.
func _MeanCentringError aPos, nW
	_esum_ = 0
	_ecnt_ = 0
	for _ei_ = 1 to 20
		_ep_ = _XOf(aPos, "n" + _ei_)
		if _ep_ < 0  loop  ok
		_ekid_ = 0
		_ekn_ = 0
		for _ec_ in [ _ei_ * 2, _ei_ * 2 + 1 ]
			if _ec_ > 40  loop  ok
			_ex_ = _XOf(aPos, "n" + _ec_)
			if _ex_ < 0  loop  ok
			_ekid_ += _ex_
			_ekn_++
		next
		if _ekn_ = 0  loop  ok
		_ed_ = _ep_ - _ekid_ / _ekn_
		if _ed_ < 0  _ed_ = -_ed_  ok
		_esum_ += _ed_
		_ecnt_++
	next
	if _ecnt_ = 0  return -1  ok
	return (_esum_ / _ecnt_) / nW * 100

# The SAME layout -- same layers, same left-to-right order -- respaced the
# way the face used to: evenly across the full width, by ordinal. This is a
# faithful reconstruction rather than a guess, because it reads the order
# out of the real positions instead of inventing one.
func _RespaceByOrdinal aPos, nW
	_rrows_ = []
	for _rp_ in aPos
		_rk_ = floor(_rp_[3] / 4)
		_rat_ = 0
		for _rj_ = 1 to len(_rrows_)
			if _rrows_[_rj_][1] = _rk_  _rat_ = _rj_  exit  ok
		next
		if _rat_ = 0
			_rrows_ + [ _rk_, [] ]
			_rat_ = len(_rrows_)
		ok
		_rrows_[_rat_][2] + [ _rp_[2], "" + _rp_[1] ]
	next
	_rout_ = []
	for _rr_ in _rrows_
		_rsorted_ = sort(_rr_[2], 1)
		_rw_ = len(_rsorted_)
		for _rk2_ = 1 to _rw_
			_rout_ + [ _rsorted_[_rk2_][2], _rk2_ / (_rw_ + 1) * nW, _rr_[1] * 4 ]
		next
	next
	return _rout_

# The node centres a diagram actually lays out, via the same layout the
# renderer uses -- so the assertion reads the real thing and not a model
# of it.
func _DiagramXY oDiag, nBW, nBH
	_dg_ = new stzGraphCanvas(oDiag, [ :Layout = :Hierarchical,
		:Width = 1000, :Height = 700, :Margin = 0,
		:Clusters = oDiag._ClusterPairs() ])
	return _dg_.Positions()

# How many nodes that are NOT in a cluster have their box inside that
# cluster's rectangle.
func _StrangersInClusters oDiag, aPos, nBW, nBH
	_si_ = 0
	for _cl_ in oDiag.Clusters()
		_box_ = oDiag._ClusterBox(_cl_, _ClusterXY(aPos), nBW, nBH)
		if len(_box_) != 4  loop  ok
		for _p_ in aPos
			_isMem_ = 0
			for _m_ in _cl_[:nodes]
				if StzLower("" + _m_) = StzLower("" + _p_[1])  _isMem_ = 1  exit  ok
			next
			if _isMem_  loop  ok
			if _BoxInside(_p_[2], _p_[3], nBW, nBH, _box_)  _si_++  ok
		next
	next
	return _si_

func _MembersInClusters oDiag, aPos, nBW, nBH
	_mi_ = 0
	for _cl_ in oDiag.Clusters()
		_box_ = oDiag._ClusterBox(_cl_, _ClusterXY(aPos), nBW, nBH)
		if len(_box_) != 4  loop  ok
		for _m_ in _cl_[:nodes]
			for _p_ in aPos
				if StzLower("" + _p_[1]) != StzLower("" + _m_)  loop  ok
				if _BoxInside(_p_[2], _p_[3], nBW, nBH, _box_)  _mi_++  ok
			next
		next
	next
	return _mi_

# _ClusterBox wants ids lowercased, the way ToCanvasXT feeds it
func _ClusterXY aPos
	_cx_ = []
	for _p_ in aPos  _cx_ + [ StzLower("" + _p_[1]), _p_[2], _p_[3] ]  next
	return _cx_

# Is the node box CENTRED at (x,y) wholly within the cluster rectangle?
# Wholly, not overlapping: a node clipping a cluster's padding is untidy,
# a node sitting inside it is a lie about membership.
func _BoxInside nX, nY, nBW, nBH, aBox
	return (nX - nBW / 2) >= aBox[1] and
	       (nX + nBW / 2) <= aBox[1] + aBox[3] and
	       (nY - nBH / 2) >= aBox[2] and
	       (nY + nBH / 2) <= aBox[2] + aBox[4]

# Edge ink lying to the RIGHT of every node box -- where a self-loop is
# drawn in a top-down picture, and where nothing else ever is.
func _InkRightOfBoxes oCanvas, nW, nH, cHex
	_rc_ = _HexRGB(cHex)
	_rpx_ = oCanvas.ToPixels()
	_rmax_ = 0
	for _ry_ = 0 to nH - 1 step 2
		for _rx_ = 0 to nW - 1
			if _IsRGB(_rpx_, nW, _rx_, _ry_, _rc_)
				if _rx_ > _rmax_  _rmax_ = _rx_  ok
			ok
		next
	next
	if _rmax_ = 0  return 0  ok
	_rn_ = 0
	for _ry_ = 0 to nH - 1
		for _rx_ = _rmax_ + 2 to nW - 1
			if _IsRGB(_rpx_, nW, _rx_, _ry_, [ 255, 255, 255 ])  loop  ok
			if _IsRGB(_rpx_, nW, _rx_, _ry_, _rc_)  loop  ok
			_rn_++
		next
	next
	return _rn_

func Raises cCode
	try
		eval(cCode)
	catch
		return TRUE
	done
	return FALSE

# How many pixels differ between two canvases of the SAME size. Answers -1
# when the sizes differ, which is a different fact and must not be reported
# as a difference count.
func _PixelsDiffering oA, oB
	if oA.Width() != oB.Width() or oA.Height() != oB.Height()  return -1  ok
	_da_ = oA.ToPixels()
	_db_ = oB.ToPixels()
	_dn_ = min([ len(_da_), len(_db_) ])
	_dc_ = 0
	for _di_ = 1 to _dn_ step 4
		if substr(_da_, _di_, 1) != substr(_db_, _di_, 1) or
		   substr(_da_, _di_ + 1, 1) != substr(_db_, _di_ + 1, 1) or
		   substr(_da_, _di_ + 2, 1) != substr(_db_, _di_ + 2, 1)
			_dc_++
		ok
	next
	return _dc_

# How many EDGE segments in the SVG are neither horizontal nor vertical.
#
# FILTERED BY STROKE COLOUR, and that correction is the whole reason this
# reads a colour at all. Counting every polyline counted the NODE BOXES:
# a rounded rectangle is emitted as a polyline and its four corners are
# twenty-four short diagonal steps, so three nodes contributed 72
# non-axial segments to an ortho picture and to a curved one alike. The
# instrument was measuring corner rounding and calling it edge routing.
# Edges are drawn in the edge colour and node borders are not, so the
# stroke tells them apart exactly.
func _NonAxialSegments cSvg, cStroke
	_nn_ = 0
	_slen_ = StzLen(cSvg)
	for _sp_ in StzFindAll('<polyline points="', cSvg)
		_stail_ = StzSubStr(cSvg, _sp_, min([ 6000, _slen_ - _sp_ + 1 ]))
		_sq_ = StzFindFirst('"', StzSubStr(_stail_, 19, StzLen(_stail_) - 18))
		if _sq_ = 0  loop  ok
		_spts_ = StzSubStr(_stail_, 19, _sq_ - 1)
		# the whole tag, to read its stroke
		_stagend_ = StzFindFirst(">", _stail_)
		if _stagend_ = 0  loop  ok
		if StzFindFirst(cStroke, StzSubStr(_stail_, 1, _stagend_)) = 0  loop  ok
		_sprev_ = []
		for _spair_ in StzSplit(_spts_, " ")
			_sxy_ = StzSplit(StzTrim(_spair_), ",")
			if len(_sxy_) != 2  loop  ok
			try
				_sx_ = 0 + _sxy_[1]
				_sy_ = 0 + _sxy_[2]
			catch
				loop
			done
			if len(_sprev_) = 2
				# half a pixel of tolerance: the coordinates are written
				# with decimals, and "axis-aligned" is a claim about the
				# geometry, not about float formatting
				if fabs(_sx_ - _sprev_[1]) > 0.5 and
				   fabs(_sy_ - _sprev_[2]) > 0.5
					_nn_++
				ok
			ok
			_sprev_ = [ _sx_, _sy_ ]
		next
	next
	return _nn_

# A router fanning out to four hosts, every edge carrying the same label
# stem -- so the only thing that varies between two calls is label WIDTH.
func _Fan cStem
	_fo_ = new stzDiagram("fan15")
	_fo_.AddNodeXTT("r", "Router", [ :type = "box", :color = "Info.Solid" ])
	for _fi_ = 1 to 4
		_fo_.AddNodeXTT("h" + _fi_, "H" + _fi_,
			[ :type = "box", :color = "Info.Solid" ])
		_fo_.AddEdgeXT("r", "h" + _fi_, cStem + _fi_)
	next
	return _fo_

func _MaxOf paList
	_mx_ = 0
	for _v_ in paList
		if _v_ > _mx_  _mx_ = _v_  ok
	next
	return _mx_

# The smallest gap between adjacent nodes anywhere -- one unit, the same
# normalisation dot's own numbers were reduced by.
func _TightestGap aPos
	_tmin_ = -1
	for _ta_ in _RanksOf(aPos)
		_txs_ = sort(_ta_)
		for _ti_ = 2 to len(_txs_)
			_td_ = _txs_[_ti_] - _txs_[_ti_ - 1]
			if _td_ > 0.001 and (_tmin_ < 0 or _td_ < _tmin_)  _tmin_ = _td_  ok
		next
	next
	if _tmin_ < 0  return 1  ok
	return _tmin_

# The left-to-right extent of the rank holding exactly nCount nodes.
func _RankSpan aPos, nCount
	for _ra_ in _RanksOf(aPos)
		if len(_ra_) = nCount
			_rx_ = sort(_ra_)
			return _rx_[len(_rx_)] - _rx_[1]
		ok
	next
	return 0

func _RanksOf aPos
	_rr_ = []
	for _p_ in aPos
		_rk_ = floor(_p_[3] / 4)
		_rat_ = 0
		for _rj_ = 1 to len(_rr_)
			if _rr_[_rj_][1] = _rk_  _rat_ = _rj_  exit  ok
		next
		if _rat_ = 0
			_rr_ + [ _rk_, [ _p_[2] ] ]
		else
			_rr_[_rat_][2] + _p_[2]
		ok
	next
	_out_ = []
	for _r_ in _rr_  _out_ + _r_[2]  next
	return _out_

# In this tree node k's children are 2k and 2k+1, so a subtree is known
# without walking edges -- the guard states the structure it is checking
# rather than trusting the thing under test to describe itself.
func _SubtreeNodes nRoot, nMax
	_sn_ = []
	_sq_ = [ nRoot ]
	while len(_sq_) > 0
		_sv_ = _sq_[1]
		del(_sq_, 1)
		if _sv_ > nMax  loop  ok
		_sn_ + _sv_
		_sq_ + (_sv_ * 2)
		_sq_ + (_sv_ * 2 + 1)
	end
	return _sn_

func _SubtreeLo aPos, nRoot, nMax
	_l_ = -1
	for _v_ in _SubtreeNodes(nRoot, nMax)
		_x_ = _XOf(aPos, "n" + _v_)
		if _x_ < 0  loop  ok
		if _l_ < 0 or _x_ < _l_  _l_ = _x_  ok
	next
	return _l_

func _SubtreeHi aPos, nRoot, nMax
	_h_ = -1
	for _v_ in _SubtreeNodes(nRoot, nMax)
		_x_ = _XOf(aPos, "n" + _v_)
		if _x_ < 0  loop  ok
		if _x_ > _h_  _h_ = _x_  ok
	next
	return _h_

# Pairs of SIBLINGS whose bands overlap. Siblings only: an ancestor's band
# contains its descendant's by definition, and counting that would be
# counting the tree being a tree.
func _OverlappingTerritories aPos, nMax
	_o_ = 0
	for _p_ = 1 to floor(nMax / 2)
		_a_ = _p_ * 2
		_b_ = _p_ * 2 + 1
		if _b_ > nMax  loop  ok
		_alo_ = _SubtreeLo(aPos, _a_, nMax)
		_ahi_ = _SubtreeHi(aPos, _a_, nMax)
		_blo_ = _SubtreeLo(aPos, _b_, nMax)
		_bhi_ = _SubtreeHi(aPos, _b_, nMax)
		if _alo_ < 0 or _blo_ < 0  loop  ok
		if _ahi_ > _blo_ and _bhi_ > _alo_  _o_++  ok
	next
	return _o_
