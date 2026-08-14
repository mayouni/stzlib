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
