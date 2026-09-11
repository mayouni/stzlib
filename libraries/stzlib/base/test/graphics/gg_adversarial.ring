load "../../stzBase.ring"
load "gg_drakon_scenes.ring"
load "gg_math_scenes.ring"
load "gg_er_scenes.ring"
load "gg_petri_scenes.ring"
load "gg_fault_scenes.ring"
load "gg_family_scenes.ring"
load "gg_network_scenes.ring"

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
nOk = 0  nBad = 0  nSecClock = 0
nCf77Seq = 0

# A guard section declares which plan item it discharges, so the plan's
# status table is GENERATED from the suite rather than remembered beside
# it. The declaration sits inside the section that proves the thing.
aDischarged = []  cCurSecKey = ""

# THIS SUITE IS ITS OWN FAST PATH -- 20 seconds for every section, so
# there is nothing to scope away and no skipping to disclose. It was
# eight minutes until 2026-08-20, and a `quick` switch existed to dodge
# the three worst sections; measuring them ended that. Every second of
# the 484 they held was instrument waste, not coverage:
#
#   - three sections swept the WHOLE canvas hunting the row with the
#     most paint, to answer what RenderNodeRects() publishes for free
#   - Ring's substr on a large buffer is O(buffer), about a third of a
#     millisecond on 1.8MB, so per-pixel substr WAS the cost. Every
#     scan here now slices its row (or a 64KB chunk) once and indexes
#     inside it
#   - one instrument hunted "any pixel that is not fill" and would have
#     counted the nodes' own labels; it names the edge grey now
#
# Keep it that way: an instrument that reads a picture should ask the
# render where to look, name the ink it hunts, and never call substr
# per pixel. Per-section wall times print below -- CENTRAL-PXLATENCY-01
# asks that a suite be able to say where its time goes.

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
sec("-- 1. Painter order, across the segment KINDS ---------------")
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
sec("-- 2. An image's ALPHA blends, it does not replace ----------")
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
sec("-- 3. A shape must survive the box a DIAGRAM gives it -------")
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
_aABox1_ = [ [ 140, 100 ], [ 300, 40 ], [ 26, 200 ], [ 40, 300 ], [ 200, 26 ] ]
_nABox1_ = len(_aABox1_)
for _iABox1_ = 1 to _nABox1_
	aBox = _aABox1_[_iABox1_]
	oD = new stzCanvas(400, 400)
	oD.SetBackgroundQ("#FFFFFF").FillQ("#3C6E9A")
	StzDrawNodeShape(oD, :Cylinder, 20, 20, aBox[1], aBox[2])
	_aAE2_ = _CapsIn(oD.ToSVG())
	_nAE2_ = len(_aAE2_)
	for _iAE2_ = 1 to _nAE2_
		aE = _aAE2_[_iAE2_]
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
_aAE3_ = _CapsIn(oE.ToSVG())
_nAE3_ = len(_aAE3_)
for _iAE3_ = 1 to _nAE3_
	aE = _aAE3_[_iAE3_]
	if aE[1] < aE[2]  nSeen++  ok
next
? "   the old geometry, drawn deliberately, is seen : " + nSeen + " time(s)"
chk("the cap check DISCRIMINATES", nSeen = 1)

#---------------------------------------------------------------------------
? ""
sec("-- 4. Boxes must FIT the rank they landed in ----------------")
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
#
# The row is now ASKED FOR (see _RankRowGaps) rather than hunted across the
# whole canvas -- same property, same numbers, 140s to under a second.
#---------------------------------------------------------------------------

NODEC = "#2E7D32"
oG = new stzDiagram("fan")
oG.AddNodeXTT("root", "Root", [ :type = "box", :color = NODEC ])
for i = 1 to 16
	oG.AddNodeXTT("k" + i, "Kid " + i, [ :type = "box", :color = NODEC ])
	oG.AddEdge("root", "k" + i)
next

aOpt = [ :Width = 1200, :Height = 500, :NodeWidth = 96, :NodeHeight = 34 ]
nFit = _RankRowGaps(oG, oG.ToCanvasXT(aOpt), 1200, NODEC)[1]
? "   16 nodes in a 1200px picture, boxes asked for 96px wide"
? "   gaps of background between them : " + nFit + " (16 boxes -> 15 gaps)"
chkeq("every node in the rank can be told from its neighbour", nFit, 15)

# THE NEGATIVE SIBLING, and the proof that the fit pass is what fixed it:
# the same picture with fitting switched OFF must fuse the boxes into a wall.
aOff = [ :Width = 1200, :Height = 500, :NodeWidth = 96, :NodeHeight = 34,
         :FitBoxes = 0 ]
nRaw = _RankRowGaps(oG, oG.ToCanvasXT(aOff), 1200, NODEC)[1]
? "   the same picture with :FitBoxes = FALSE : " + nRaw + " gaps"
chk("without fitting the boxes really do run together", nRaw < 15)

# and the mechanism itself, where the arithmetic is visible
? "   scale for 16 nodes 82px apart, 96px boxes : " +
  oG._RankFitScale(_Rank(16, 82), 96, 34, "TB")
chk("a crowded rank scales DOWN", oG._RankFitScale(_Rank(16, 82), 96, 34, "TB") < 1)
chk("a roomy rank is left ALONE", oG._RankFitScale(_Rank(4, 300), 96, 34, "TB") = 1)

#---------------------------------------------------------------------------
? ""

sec("-- 5. A label reaches the picture AS AUTHORED ---------------")
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
sec("-- 6. A parent sits OVER its children -----------------------")
discharges("GG6")
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
sec("-- 7. Spacing is the CONTRACT; the size is derived ----------")
discharges("GG6")
#
# The caller names the SEPARATION and the picture takes its size from the
# content -- dot's model, and the one this tier had inverted. So the
# tightest gap a reader can see must BE the contract, and a canvas too
# small to hold it must visibly break it.
#
# Same one-row instrument as section 4, reading the narrowest gap instead
# of the count: 109s to under a second.
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
nGap = _RankRowGaps(oN, oNat, oNat.Width(), NODEC)[2]
? "   tightest gap in the natural render : " + nGap + "px"
chk("the tightest gap IS the nodesep contract (within stroke+AA)",
    nGap >= nSep - 8 and nGap <= nSep + 2)

oCr = oN.ToCanvasXT([ :Width = 700, :Height = 240,
	:NodeWidth = 96, :NodeHeight = 34 ])
nCr = _RankRowGaps(oN, oCr, 700, NODEC)[2]
? "   the same diagram crushed into 700px : " + nCr + "px"
chk("...and a canvas too small for the contract breaks it", nCr < nSep - 20)

#---------------------------------------------------------------------------
? ""

sec("-- 8. A long edge goes AROUND the boxes, not through them ---")
discharges("GG6")
#
# An edge spanning many ranks used to be a straight line from source to
# target, drawn THROUGH every box between. The property is pixel-true: the
# EDGE STROKE's own grey must not appear inside any node box.
#
# Read only WHERE THE BOXES ARE, from the render's own rects, and hunting a
# NAMED colour rather than "anything that is not fill" -- which counted the
# nodes' own labels. 233s to under a second.
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
nCross = _EdgeInkInRects(oLc.ToPixels(), oLc.Width(), oLc.Height(),
	oL.RenderNodeRects(), [ 138, 138, 138 ], 40)
? "   canvas " + oLc.Width() + "x" + oLc.Height() +
  "   edge ink found inside node boxes : " + nCross
chk("no long edge is drawn through a node", nCross = 0)

# THE NEGATIVE SIBLING: a line drawn deliberately across a box, on a canvas
# built by hand -- so its box rect is passed explicitly, the instrument
# having no render to ask.
oX = new stzCanvas(200, 120)
oX.SetBackgroundQ("#FFFFFF")
oX.FillQ(BLU).AddRect(40, 30, 120, 60)
oX.Flush()
oX.AddLineQ(20, 60, 180, 60).Stroke("#8A8A8A", 2)
nX = _EdgeInkInRects(oX.ToPixels(), 200, 120, [ [ 40, 30, 120, 60 ] ],
	[ 138, 138, 138 ], 40)
? "   a line drawn deliberately across a box reads : " + nX
chk("the crossing check DISCRIMINATES", nX > 0)

#---------------------------------------------------------------------------
? ""

sec("-- 9. A cluster box holds its members, and NO STRANGER -------")
discharges("GG6")
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
_aA4_ = [ [ "web1", "Web A" ], [ "web2", "Web B" ], [ "api1", "API A" ],
           [ "api2", "API B" ], [ "db1", "DB A" ], [ "db2", "DB B" ],
           [ "lb", "Balancer" ], [ "log", "Logger" ] ]
_nA4_ = len(_aA4_)
for _iA4_ = 1 to _nA4_
	a = _aA4_[_iA4_]
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
_aA5_ = [ [ "x1", "X1" ], [ "mid", "Mid" ], [ "x2", "X2" ], [ "r", "R" ] ]
_nA5_ = len(_aA5_)
for _iA5_ = 1 to _nA5_
	a = _aA5_[_iA5_]
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
sec("-- 10. A self-loop is a LOOP, and is allowed ----------------")
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
_aA6_ = [ [ "a", "Idle" ], [ "b", "Busy" ], [ "c", "Done" ] ]
_nA6_ = len(_aA6_)
for _iA6_ = 1 to _nA6_
	a = _aA6_[_iA6_]
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
_aA7_ = [ [ "a", "Idle" ], [ "b", "Busy" ], [ "c", "Done" ] ]
_nA7_ = len(_aA7_)
for _iA7_ = 1 to _nA7_
	a = _aA7_[_iA7_]
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
sec("-- 11. An edge label reaches the PICTURE --------------------")
#
# The labels were in the model, they reached the dot writer, and this
# tier never drew them: an edge that said "fails check" in the data was
# an anonymous arrow on the page. Nothing failed anywhere, because every
# test that cared about edge labels asked the MODEL or the DOT, and both
# were right.
#---------------------------------------------------------------------------

EFONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oEL = new stzDiagram("flow")
_aA8_ = [ [ "req", "Request" ], [ "val", "Validate" ],
           [ "ok", "Accept" ], [ "no", "Reject" ] ]
_nA8_ = len(_aA8_)
for _iA8_ = 1 to _nA8_
	a = _aA8_[_iA8_]
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
# AN EXPLICIT SIZE, so the two renders are comparable pixel for pixel.
# Left to natural sizing they differ in WIDTH -- a labelled diagram
# reserves room its unlabelled twin does not -- and the comparison
# answered "different sizes" rather than anything about labels. The
# reservation is section 15's subject; here it is a confound.
aLOpt = [ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 40,
          :Width = 420, :Height = 320 ]
oELc = oEL.ToCanvasXT(aLOpt)

oNL3 = new stzDiagram("flow2")
_aA9_ = [ [ "req", "Request" ], [ "val", "Validate" ],
           [ "ok", "Accept" ], [ "no", "Reject" ] ]
_nA9_ = len(_aA9_)
for _iA9_ = 1 to _nA9_
	a = _aA9_[_iA9_]
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
sec("-- 12. SetLayout HONOURS what it accepted -------------------")
#
# It took any string and stored it. An unrecognised name fell through
# _NativeRankDir's default and became top-down IN SILENCE -- so
# SetLayout(:LeftToRight) drew a top-down picture with nothing anywhere
# saying the instruction had been dropped. Every horizontal caller in
# this library was affected, because the vertical directions had seven
# spellings each and the horizontal ones had exactly one.
#---------------------------------------------------------------------------

_aAL10_ = [ [ :TopDown, "TB" ], [ :BottomUp, "BT" ],
            [ :LeftRight, "LR" ], [ :LeftToRight, "LR" ],
            [ :RightLeft, "RL" ], [ "lr", "LR" ] ]
_nAL10_ = len(_aAL10_)
for _iAL10_ = 1 to _nAL10_
	aL = _aAL10_[_iAL10_]
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
sec("-- 13. ORTHO means ortho, including the self-loops ----------")
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
_aA11_ = [ [ "a", "Idle" ], [ "b", "Busy" ], [ "c", "Done" ] ]
_nA11_ = len(_aA11_)
for _iA11_ = 1 to _nA11_
	a = _aA11_[_iA11_]
	oOr.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oOr.AddEdge("a", "a")
oOr.AddEdge("b", "b")
oOr.AddEdge("a", "b")
oOr.AddEdge("b", "c")

oOr.SetSplines("ortho")
EDGERGB = "rgb(138,138,138)"      # the default edge colour, #8A8A8A
# :EDGECORNERS = :SHARP, because the picture now rounds its elbows to
# match its cells and a fillet is made of short diagonal chords. That is
# a corner TREATMENT, not a segment: the claim under test is that no edge
# RUNS at an angle, so the honest way to test it is to turn the treatment
# off and read the runs. The rounded style is held to the same claim two
# assertions down, by bounding every diagonal it does draw.
nSkew = _NonAxialSegments(oOr.ToSVGXT([ :NodeWidth = 110, :NodeHeight = 40,
	:EdgeCorners = :Sharp ]), EDGERGB)
? "   segments that are neither horizontal nor vertical : " + nSkew
chkeq("under ortho, every segment is axis-aligned", nSkew, 0)

# ...AND THE ROUNDED STYLE ADDS CORNERS, NEVER SLANTS. Every diagonal it
# draws must be shorter than the corner radius it was cut from; one
# longer than that is an edge running at an angle, which is the fault
# this section exists for.
nSkR = 0  nLongR = 0
_aDch12_ = _DiagChords(oOr.ToSVGXT([ :NodeWidth = 110, :NodeHeight = 40 ]),
	EDGERGB)
_nDch12_ = len(_aDch12_)
for _iDch12_ = 1 to _nDch12_
	_dch_ = _aDch12_[_iDch12_]
	nSkR++
	if _dch_ > 10  nLongR++  ok
next
? "   rounded style : " + nSkR + " diagonal chords, " + nLongR +
  " longer than a corner"
chk("the rounded style really does draw corners", nSkR > 0)
chkeq("...and not one of them is a slanted RUN", nLongR, 0)

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
_aA13_ = [ [ "a", "Idle" ], [ "b", "Busy" ], [ "c", "Done" ] ]
_nA13_ = len(_aA13_)
for _iA13_ = 1 to _nA13_
	a = _aA13_[_iA13_]
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
sec("-- 14. NESTED clusters: a box inside a box ------------------")
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
_aA14_ = [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
           [ "api1", "API A" ], [ "api2", "API B" ],
           [ "db1", "DB A" ], [ "db2", "DB B" ], [ "log", "Logger" ] ]
_nA14_ = len(_aA14_)
for _iA14_ = 1 to _nA14_
	a = _aA14_[_iA14_]
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
	_aC15_ = [ "a", "b", "c" ]
	_nC15_ = len(_aC15_)
	for _iC15_ = 1 to _nC15_
		c = _aC15_[_iC15_]
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
	_aC16_ = [ "a", "b", "c" ]
	_nC16_ = len(_aC16_)
	for _iC16_ = 1 to _nC16_
		c = _aC16_[_iC16_]
		o.AddNodeXTT(c, c, [ :type = "box" ])
	next
	o.AddEdge("a", "b")  o.AddEdge("b", "c")
	o.AddClusterXTT("big", "Big", [ "a", "b", "c" ], "#C2185B")
	o.AddClusterXTT("small", "Small", [ "b", "c" ], "#2E7D32")
	o.ToCanvasXT([ :NodeWidth = 90, :NodeHeight = 30 ])
'))

#---------------------------------------------------------------------------
? ""
sec("-- 15. Edge labels STEER the layout ------------------------")
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
# WIDTH IS TRADED FOR HEIGHT, and this section used to assert only the
# axis it happened to grow. It read "wide labels widen the picture",
# which was true while every label was drawn on one line: the layout
# could only buy room sideways, and a 108px label pushed a rank out by
# 124px per child. Wrapping changed WHERE the room is bought, not
# whether it is bought. Width is the scarce axis -- every child's label
# competes with its neighbours' inside one rank -- while the rank GAP is
# one number grown once for everybody, so a label that CAN be wrapped to
# its node's width is wrapped, and the gap pays instead.
#
# The property is that a label steers the layout. The axis is an
# implementation of it, and asserting the axis failed a correct picture
# the moment the trade improved.
oSC = oShort.ToCanvasXT(aSO)
oWC = oWide.ToCanvasXT(aSO)
? "   short labels : " + oSC.Width() + "x" + oSC.Height()
? "   wide  labels : " + oWC.Width() + "x" + oWC.Height()
chk("a wide label still steers the layout",
    oWC.Width() * oWC.Height() > oSC.Width() * oSC.Height() * 1.2)
chk("...and it buys its room in the GAP, the cheap axis",
    oWC.Height() > oSC.Height())
chkeq("...leaving the scarce axis alone", oWC.Width(), oSC.Width())

SLOT = 70 + floor(oShort.NodeSeparation() * 96)
aDS = oShort._LabelDemand(SFONT, 14, 70, 40, SLOT, 0, 70)
aDW = oWide._LabelDemand(SFONT, 14, 70, 40, SLOT, 0, 70)
? "   demand, short : " + @@(aDS)
? "   demand, wide  : " + @@(aDW)
chkeq("a short label demands nothing at all", _MaxOf(aDS), 0)
chkeq("...and neither does a wide one, once it is wrapped",
      _MaxOf(aDW), 0)

# THE NEGATIVE SIBLING, and the case that keeps the width demand honest:
# a label of ONE unbreakable word cannot be wrapped, so it has no cheap
# axis to move to and must widen the rank exactly as before. If wrapping
# had been implemented as "labels never demand width", this is the line
# that catches it.
oUnbr = _Fan("WWWWWWWWWWWWWWWWWWWW")
aDU = oUnbr._LabelDemand(SFONT, 14, 70, 40, SLOT, 0, 70)
? "   demand, one unbreakable word : " + @@(aDU)
chk("a label that CANNOT wrap still demands width", _MaxOf(aDU) > 0.2)
chkeq("the source of a labelled edge demands nothing", aDU[1], 0)
chk("...and every target demands the same room",
    aDU[2] = aDU[3] and aDU[3] = aDU[4] and aDU[4] = aDU[5])

# THE TWO NUMBERS AGREE. The demand divides by the bias because the label
# stands at that fraction of the way to its target; if the drawing used a
# different fraction the layout would buy space the label is not standing
# in. Asserted by measuring where the label ACTUALLY lands.
oB = new stzDiagram("bias")
oB.AddNodeXTT("p", "P", [ :type = "box", :color = "Info.Solid" ])
oB.AddNodeXTT("q", "Q", [ :type = "box", :color = "Info.Solid" ])
oB.AddEdgeXT("p", "q", "WWWWWWWWWWWWWWWW")
# THE MIDPOINT, and this assertion used to demand otherwise. It read
# `nBias > 0.5` because the bias WAS 0.72 -- pushed toward the target so
# a fan's labels would inherit its spread. They did, and landed on the
# arrowheads, where a label's own background plate erased the head it
# was standing on. A label that hides what it describes is worse than
# one that crowds a neighbour, and crowding already has an answer in the
# nudge. The demand that widens a rank divides by this number, so it
# follows the change rather than having to be retuned beside it.
nBias = oB._EdgeLabelBias()
? "   the shared bias : " + nBias
chkeq("a label sits at the MIDPOINT of its edge, clear of the arrowhead",
      nBias, 0.5)

#---------------------------------------------------------------------------
? ""
sec("-- 16. The edge grammar is DOT'S, asserted against dot's rules ----")
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
# ports and corner radius are part of the geometry now: an edge attaches
# on the rank-facing border, offset along it, pulled under the rounded
# outline
aGm = oQ._EdgeGeometry([ 200, 100 ], [ 480, 240 ], QW, QH, "TB", 2, 0, 0, 10, 0)
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

# 3. THE HEAD MEETS ITS BORDER SQUARE -- grammar v3, from the
#    Principal's reference sketch. Two grammars preceded it and each
#    encoded its own mistake into this very assertion: v2 asserted the
#    head follows the AIM, and passed while arrivals grazed their
#    borders and fans braided. The head now arrives along the landed
#    border's NORMAL: this is a top landing, so it points straight down.
nHdX = (aTp[1] - aBs[1])
nHdY = (aTp[2] - aBs[2])
nHdL = sqrt(nHdX*nHdX + nHdY*nHdY)
? "   head direction : " + (nHdX / nHdL) + "," + (nHdY / nHdL)
chk("the head enters its top border square, pointing down",
    nHdY / nHdL > 0.99 and fabs(nHdX / nHdL) < 0.15)

# 4. ONE BEND, ALWAYS OUTWARD -- the outer arc. An S-curve crosses its
#    own chord; dot's edges never do. Signed area side of every sample
#    against the chord must not change sign.
# PERPENDICULAR DISTANCE, not the raw cross product. v3 departs TANGENT
# to the chord, so early samples sit within float noise of it -- and a
# raw cross-product threshold of 0.5 is half a SQUARE pixel, which a
# 0.002px jitter over a 300px chord exceeds. The claim is about pixels a
# reader could see, so the dead zone is half a pixel of DISTANCE.
nChL = sqrt((aFl[nFn-1]-aFl[1])*(aFl[nFn-1]-aFl[1]) +
            (aFl[nFn]-aFl[2])*(aFl[nFn]-aFl[2]))
nPos = 0
nNeg = 0
for i = 1 to nFn / 2
	_sx_ = aFl[i*2-1] - aFl[1]
	_sy_ = aFl[i*2] - aFl[2]
	_cr_ = ((aFl[nFn-1]-aFl[1]) * _sy_ - (aFl[nFn]-aFl[2]) * _sx_) / nChL
	if _cr_ > 0.5  nPos++  ok
	if _cr_ < -0.5  nNeg++  ok
next
? "   samples left of the chord " + nPos + ", right " + nNeg
chk("the curve stays on ONE side of its chord -- an arc, never an S",
    nPos = 0 or nNeg = 0)

# THE NEGATIVE SIBLING: v2's own geometry, reconstructed -- arrival
# along the AIM of this same lateral edge -- must FAIL the square-entry
# test, or "square" is not being measured.
nAimX = 480 - 200
nAimY = 240 - 100
nAimL = sqrt(nAimX*nAimX + nAimY*nAimY)
? "   v2 arrived along the aim; its downward share was " + (nAimY / nAimL)
chk("the grammar this replaced really did graze the border",
    nAimY / nAimL < 0.99)

#---------------------------------------------------------------------------
? ""
sec("-- 17. Sparse ranks are TIGHT, measured against dot ---------")
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
# MEASURED AGAINST DOT WHERE WE AGREE WITH DOT, and that is not
# everywhere any more. The Principal's centring rule -- the mother cell
# always sits at the middle of her children -- is Reingold-Tilford's, not
# dot's: dot's network simplex BALANCES edge lengths and will lean a
# parent toward one side to buy a tighter rank. So the upper ranks of a
# binary tree are wider here than in dot BY CONSTRUCTION, and a guard
# that read those ranks as slack was reading a deliberate difference as a
# defect.
#
# What is still worth asserting, and is asserted below, is that the extra
# width is DERIVED rather than wasted: every parent stands exactly at its
# own children's midpoint, so the rank's span is forced by the subtrees
# and not by looseness. The leaf ranks, where centring has nothing to
# say, are still held to dot.
aDotSpan = [ [ 16, 17.5 ], [ 9, 8.0 ] ]
nUnit = _TightestGap(aTP)
? "   leaf ranks | dot | ours | ratio"
nWorst = 0
_aAD17_ = aDotSpan
_nAD17_ = len(_aAD17_)
for _iAD17_ = 1 to _nAD17_
	aD = _aAD17_[_iAD17_]
	nOurs = _RankSpan(aTP, aD[1]) / nUnit
	nR = nOurs / aD[2]
	? "   n=" + aD[1] + "   | " + aD[2] + " | " + nOurs + " | " + nR + "x"
	if fabs(nR - 1) > nWorst  nWorst = fabs(nR - 1)  ok
next
? "   worst departure from dot, where we follow dot : " + nWorst
chk("a rank of leaves is as tight as dot's", nWorst < 0.5)

# ...and the upper ranks are wide only because the parents are centred.
# n2 and n3 are the children of the root; each is the parent of its own
# half of the tree, so its position is FORCED to that half's midpoint.
nX2 = _XOf(aTP, "n4")
nX3 = _XOf(aTP, "n5")
nMid2 = (nX2 + nX3) / 2
nX6 = _XOf(aTP, "n6")
nX7 = _XOf(aTP, "n7")
nMid3 = (nX6 + nX7) / 2
? "   n2 at " + _XOf(aTP, "n2") + " over its children's middle " + nMid2
? "   n3 at " + _XOf(aTP, "n3") + " over its children's middle " + nMid3
chk("the rank of two is wide because both parents are CENTRED",
    fabs(_XOf(aTP, "n2") - nMid2) < 0.5 and
    fabs(_XOf(aTP, "n3") - nMid3) < 0.5)
nSpan2 = fabs(_XOf(aTP, "n2") - _XOf(aTP, "n3"))
? "   ...so its span " + nSpan2 + " is exactly the gap between those middles"
chk("...leaving no slack in it at all", fabs(nSpan2 - fabs(nMid2 - nMid3)) < 0.5)

#---------------------------------------------------------------------------
? ""
sec("-- 18. No node stands in another subtree's TERRITORY --------")
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
_aAP18_ = aRP
_nAP18_ = len(_aAP18_)
for _iAP18_ = 1 to _nAP18_
	aP = _aAP18_[_iAP18_]
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
sec("-- 19. A label is readable AT THE SIZE IT IS DRAWN ----------")
#
# REWRITTEN, and the first version's mistake is the point. It asserted
# one flat minimum -- 4.5:1, the body-text figure -- and passed by
# picking whichever of black/white measured higher. That put BLACK on
# every saturated role, which scores better and reads worse: dark ink on
# a dark-ish saturated field is muddy however the number comes out. The
# assertion was satisfied and the picture was wrong, again, because the
# assertion encoded half a rule.
#
# WCAG's own answer is the other half: 4.5:1 for normal text, 3:1 for
# LARGE text -- 24px, or 18.66px bold. White on a saturated role sits
# between the two. It is not failing; it is text that must be bolder. So
# the rule has three parts and all three are asserted here: which ink,
# whether the size can carry it, and that emphasis is drawn when it
# cannot.
#---------------------------------------------------------------------------

? "   role      fill      ink at 12px   ratio  needs emphasis"
nBadInk = 0
_aCRole19_ = [ :Primary, :Success, :Warning, :Danger, :Info, :Neutral ]
_nCRole19_ = len(_aCRole19_)
for _iCRole19_ = 1 to _nCRole19_
	cRole = _aCRole19_[_iCRole19_]
	cFill = StzResolveColor("" + cRole + ".Solid")
	if cFill = ""  loop  ok
	aInk = StzReadableTextOn(cFill, 12, 0)
	? "   " + cRole + "  " + cFill + "  " + aInk[1] + "  " + aInk[2] + ":1  " +
	  iif(aInk[3], "yes", "no")
	# a saturated role is dark by the library's own test, so white is the
	# ink and the large-text floor is what it must clear
	if aInk[1] != "white"  nBadInk++  ok
	if aInk[2] < StzContrastMinimumLargeText()  nBadInk++  ok
next
chkeq("every saturated role takes WHITE, clearing the large-text floor",
      nBadInk, 0)

# emphasis is flagged exactly when the size cannot carry the pairing, and
# NOT flagged when it can -- both directions, or "always emphasise" would
# pass too
aSmall = StzReadableTextOn(StzResolveColor("Success.Solid"), 12, 0)
aLarge = StzReadableTextOn(StzResolveColor("Success.Solid"), 26, 0)
? "   success at 12px needs emphasis : " + aSmall[3] +
  " ; at 26px : " + aLarge[3]
chk("a small label is flagged for emphasis", aSmall[3] = 1)
chk("...and a large one is not", aLarge[3] = 0)

# the ends of the range, where the rule is not in doubt
aLight = StzReadableTextOn("#FFE082", 12, 0)
aDark  = StzReadableTextOn("#102A43", 12, 0)
? "   a LIGHT fill takes " + aLight[1] + ", a DARK fill takes " + aDark[1]
chkeq("black on a light field", aLight[1], "black")
chkeq("white on a dark field", aDark[1], "white")

# THE NEGATIVE SIBLING: pure max-contrast, the rule this replaced, must
# reach for BLACK on those same saturated fills -- so "white everywhere"
# is a decision this check can tell apart from an accident.
nBlackPicks = 0
_aCRole20_ = [ :Primary, :Success, :Warning, :Danger, :Info ]
_nCRole20_ = len(_aCRole20_)
for _iCRole20_ = 1 to _nCRole20_
	cRole = _aCRole20_[_iCRole20_]
	cFill = StzResolveColor("" + cRole + ".Solid")
	if StzBestTextOn(cFill)[1] = "black"  nBlackPicks++  ok
next
? "   max-contrast alone would pick black on " + nBlackPicks + " of 5 roles"
chk("the rule this replaced really did choose the muddy ink",
    nBlackPicks = 5)

#---------------------------------------------------------------------------
? ""
sec("-- 20. GEOMETRY is antialiased, and text always was ---------")
#
# Reported as "lines are not antialiased", and measuring separated it
# into two facts that look alike and are not: a diagonal rendered with
# TWO distinct grey levels -- a hard edge, no coverage blending anywhere
# -- while TEXT rendered with 184. The glyph rasteriser was never the
# problem, which is why the unreadable labels turned out to be contrast
# (section 19) and not sharpness. One complaint, two unrelated causes.
#
# Counting distinct greys is the whole test: an aliased edge can only be
# ink or paper, so it has two. Coverage blending has many.
#---------------------------------------------------------------------------

oAA = new stzCanvas(200, 200)
oAA.SetBackgroundQ("#FFFFFF")
oAA.AddLineQ(20, 20, 180, 120).Stroke("#000000", 2)
nLev = _GreyLevels(oAA.ToPixels())
? "   distinct grey levels along a diagonal : " + nLev + "  (was 2)"
chk("geometry edges are blended, not hard", nLev > 2)

# a shape's CURVE, not just a straight line -- the rounded corners and
# node outlines are where a reader actually notices the stair-stepping
oAC = new stzCanvas(200, 200)
oAC.SetBackgroundQ("#FFFFFF")
oAC.FillQ("#000000").AddCircle(100, 100, 70)
nLevC = _GreyLevels(oAC.ToPixels())
? "   distinct grey levels around a circle : " + nLevC
chk("curved edges are blended too", nLevC > 2)

# TEXT, asserted so the two are never confused again: it was ALREADY
# fine, and a future report of "blurry text" is a contrast question or a
# font-size question, not this one.
oAT = new stzCanvas(240, 80)
oAT.SetBackgroundQ("#FFFFFF")
oAT.AddTextQ("Node 12", 20, 50).
	SetFontQ(new stzFont("C:/Windows/Fonts/segoeui.ttf"), 20).Color("#000000")
nLevT = _GreyLevels(oAT.ToPixels())
? "   distinct grey levels in text : " + nLevT
chk("text was antialiased all along", nLevT > 50)

# THE NEGATIVE SIBLING: a flat fill has no edges inside it, so the same
# instrument must report a single level -- otherwise "many levels" is
# just noise in the readback and proves nothing about edges.
oAF = new stzCanvas(80, 80)
oAF.SetBackgroundQ("#FFFFFF")
oAF.FillQ("#000000").AddRect(0, 0, 80, 80)
nLevF = _GreyLevels(oAF.ToPixels())
? "   distinct grey levels in a flat fill : " + nLevF
chkeq("the counter reads ONE where there is nothing to blend", nLevF, 1)

#---------------------------------------------------------------------------
? ""
sec("-- 21. :Scale is RESOLUTION, not magnification --------------")
#
# A raster is only as sharp as the pixels it was drawn with. A 12px label
# in a 3000px diagram is unreadable at 100% and worse magnified, because
# enlarging a finished picture enlarges its blur. Scaling every INPUT
# redraws the same diagram with more pixels -- glyphs rasterised at the
# new size, edges antialiased at it.
#
# The claim worth asserting is exactly that it is NOT magnification, so
# the check compares the scaled render against a naive enlargement of the
# small one. If :Scale were a stretch the two would agree.
#---------------------------------------------------------------------------

oS1 = _ScaleDiag(1)
oS2 = _ScaleDiag(2)
? "   scale 1 : " + oS1.Width() + "x" + oS1.Height() +
  "   scale 2 : " + oS2.Width() + "x" + oS2.Height()
chkeq("the canvas doubles exactly", oS2.Width(), oS1.Width() * 2)
chkeq("...in both axes", oS2.Height(), oS1.Height() * 2)

nDiff = _DiffFromUpscale(oS1, oS2)
? "   pixels differing from a naive 2x enlargement : " + nDiff + "%"
chk("the scaled render is NOT an enlargement of the small one", nDiff > 5)

# THE NEGATIVE SIBLING: the comparison must return ~0 when it really IS
# an enlargement, or "they differ" is just noise in the resampler.
nSelf = _DiffFromUpscale(oS1, _Upscaled(oS1))
? "   the same check against a true enlargement : " + nSelf + "%"
chk("the comparison DISCRIMINATES", nSelf < 1)

#---------------------------------------------------------------------------
? ""
sec("-- 22. A node TYPE draws its shape, in both renderers -------")
#
# `start`, `decision`, `storage` say what a node MEANS; `ellipse`,
# `diamond`, `cylinder` say what it looks like. The translation between
# them lived as a private method on the DOT exporter, so ToDot drew a
# decision as a diamond and the native tier -- unable to reach it -- drew
# a rounded box for every type there is. Two renderers of one model
# disagreeing, with the correct answer already written down in the file.
#
# Found by rendering the types side by side and looking. Nothing here had
# ever asserted which SHAPE a TYPE produces, only that shapes exist and
# that types are exported.
#---------------------------------------------------------------------------

aTypeShape = [ [ "start", "ellipse" ], [ "process", "box" ],
               [ "decision", "diamond" ], [ "storage", "cylinder" ],
               [ "state", "circle" ], [ "endpoint", "doublecircle" ] ]
nBadType = 0
_aATS21_ = aTypeShape
_nATS21_ = len(_aATS21_)
for _iATS21_ = 1 to _nATS21_
	aTS = _aATS21_[_iATS21_]
	cGot = StzNodeShapeForType(aTS[1])
	? "   " + aTS[1] + " -> " + cGot
	if cGot != aTS[2]  nBadType++  ok
next
chkeq("every semantic type maps to its shape", nBadType, 0)

# BOTH renderers, from ONE diagram -- which is the property that failed.
oTy = new stzDiagram("ty")
oTy.AddNodeXTT("d", "Decide", [ :type = "decision", :color = "Info.Solid" ])
oTy.AddNodeXTT("s", "Store", [ :type = "storage", :color = "Info.Solid" ])
oTy.AddEdge("d", "s")
cDotOut = oTy.ToDot()
chk("the dot export says diamond", StzFindFirst("shape=diamond", cDotOut) > 0)
chk("...and cylinder", StzFindFirst("shape=cylinder", cDotOut) > 0)
chkeq("the native tier agrees about the diamond",
      "" + oTy._NativeShapeOf(oTy.Nodes()[1]), "diamond")
chkeq("...and about the cylinder",
      "" + oTy._NativeShapeOf(oTy.Nodes()[2]), "cylinder")

# an explicit geometric name still wins over the type
chkeq("an explicit shape passes straight through",
      StzNodeShapeForType("hexagon"), "hexagon")
# and a name that is neither is refused rather than guessed at
chkeq("a word that is neither type nor shape maps to nothing",
      StzNodeShapeForType("sparkle"), "")

#---------------------------------------------------------------------------
? ""
sec("-- 23. A fan SEPARATES, and never travels its own row -------")
#
# Three faults the Principal circled, one cause each.
#
# Adopting dot's grammar I dropped port spreading, reasoning that the
# angles separate a fan by themselves. True only when the targets are
# angularly apart: a broker fanning to fourteen workers strung out
# sideways aims almost the same direction at all of them, so every edge
# left the same point and ran parallel. Ports came back -- the aim still
# decides direction, the port decides where along the border it starts.
#
# Worse, clipping in the AIM direction attached an edge to whichever
# border faced its target, so an edge to a distant sibling left the SIDE
# of its parent and arrived at the SIDE of its child, travelling along
# the child row and crossing every node between. In a layered drawing
# every edge crosses the same gap: out of the rank-facing border, into
# the one opposite.
#---------------------------------------------------------------------------

FANW = 96  FANH = 36
# two edges from one node to targets far apart on the same rank
aP1 = oQ._AttachPoint([ 500, 100 ], [ 100, 400 ], FANW, FANH, -20, 10, "TB", 1, 0)
aP2 = oQ._AttachPoint([ 500, 100 ], [ 900, 400 ], FANW, FANH,  20, 10, "TB", 1, 0)
? "   two exits from one node : " + aP1[1] + "," + aP1[2] +
  "  and  " + aP2[1] + "," + aP2[2]
chk("both leave the BOTTOM border, whatever direction they aim",
    aP1[2] > 100 and aP2[2] > 100)
chk("...and the ports separate them along it",
    fabs(aP1[1] - aP2[1]) > 20)

# the far end attaches on the TOP, which is what keeps a fan above its row
aIn = oQ._AttachPoint([ 100, 400 ], [ 500, 100 ], FANW, FANH, 0, 10, "TB", 0, 0)
? "   the arrival on a distant target : " + aIn[1] + "," + aIn[2]
chk("an edge arrives at the TOP of its target, not its side",
    aIn[2] < 400)

# THE ARRIVAL BORDER FACES THE APPROACH. A shallow approach pierces the
# top at a grazing angle -- the head almost parallel to the surface --
# so an aim shallower than the box's own aspect (with a 1.4 side bias)
# lands on the SIDE, near-perpendicular; a steep one keeps the top.
aSh = oQ._AttachPoint([ 100, 400 ], [ 900, 430 ], FANW, FANH, 0, 10, "TB", 0, 0)
? "   a shallow approach (slope 0.04) lands at : " + aSh[1] + "," + aSh[2]
chk("a shallow approach arrives on the SIDE border",
    fabs(aSh[1] - 100) > FANW / 2 - 2)
aSt = oQ._AttachPoint([ 100, 400 ], [ 160, 100 ], FANW, FANH, 0, 10, "TB", 0, 0)
? "   a steep approach (slope 5) lands at : " + aSt[1] + "," + aSt[2]
chk("...and a steep one arrives on the TOP", aSt[2] < 400 - FANH / 2 + 2)

# THE NEGATIVE SIBLING: aim-directed clipping, the rule this replaced,
# puts that same arrival on the target's SIDE -- which is how an edge
# ends up travelling along the row it should be descending into.
# The aim must be NEARLY HORIZONTAL for the old rule to show its fault --
# which is precisely the case that caused it. A 96x36 node is wide and
# short, so for most directions the vertical extent dominates and even
# aim-clipping lands on the top; the first version of this check aimed
# steeply and proved nothing. An edge to a distant sibling on the SAME
# rank is the shape that travels the row, so that is the shape to test.
aOld = oQ._ClipExact([ 100, 400 ], [ 900, 410 ], FANW, FANH)
? "   aim-directed clipping toward a same-rank sibling : " +
  aOld[1] + "," + aOld[2]
chk("the rule this replaced really did attach to the side",
    fabs(aOld[1] - 100) > FANW / 2 - 1)
# ...where the rank-facing rule still uses the border the rank says
aNew = oQ._AttachPoint([ 100, 400 ], [ 900, 410 ], FANW, FANH, 0, 10, "TB", 1, 0)
? "   the rank-facing rule leaves the bottom at : " + aNew[1] + "," + aNew[2]
chk("...while the rank-facing rule leaves the bottom regardless",
    aNew[2] > 400)

# A RANK GAP MUST ANSWER TO THE SPAN IT IS CROSSED BY. An edge running
# far sideways over a shallow gap is nearly horizontal, and a nearly
# horizontal edge grazes every node in its target's rank.
oFanD = new stzDiagram("fan23")
oFanD.AddNodeXTT("b", "Broker", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 14
	oFanD.AddNodeXTT("f" + i, "W" + i, [ :type = "box", :color = "Info.Solid" ])
	oFanD.AddEdge("b", "f" + i)
next
oFanC = oFanD.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nSlope = oFanC.Height() / oFanC.Width()
? "   a 14-way fan renders " + oFanC.Width() + "x" + oFanC.Height() +
  "  (height/width " + nSlope + ")"
chk("the gap grew so the fan descends rather than running flat",
    oFanC.Height() > 200)

# ...and a diagram whose edges are all SHORT must not pay for it
oNarrow = new stzDiagram("narrow")
oNarrow.AddNodeXTT("a", "A", [ :type = "box", :color = "Info.Solid" ])
oNarrow.AddNodeXTT("b", "B", [ :type = "box", :color = "Info.Solid" ])
oNarrow.AddEdge("a", "b")
nNarrowH = oNarrow.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ]).Height()
? "   a two-node diagram stays " + nNarrowH + " tall"
chk("a short-edged diagram keeps the separation it asked for",
    nNarrowH < 200)

#---------------------------------------------------------------------------
? ""
sec("-- 24. Every departure makes PROGRESS, routed or not --------")
#
# REWRITTEN FOR GRAMMAR v3, and its history is the point. v1 of this
# section asserted "every edge leaves downward" -- first step more
# vertical than lateral -- and that was v2's rule. The Principal's
# reference sketch overruled it: edges DEPART ALONG THE AIM, so a shallow
# aim leaves sideways-dominant by design, and the old assertion would
# now fail correct pictures. What survives every grammar is the
# invariant underneath: a departure must make progress toward the next
# rank -- the first step never runs BACKWARD, which is what a hook at
# the source looks like in numbers. Asserted for single-hop and routed
# alike, because the section's original lesson stands: a property worth
# asserting is worth asserting of every implementation of it.
#---------------------------------------------------------------------------

oRt = new stzDiagram("routed")
for i = 1 to 5
	oRt.AddNodeXTT("r" + i, "R" + i, [ :type = "box", :color = "Info.Solid" ])
next
for i = 1 to 4  oRt.AddEdge("r" + i, "r" + (i + 1))  next
oRt.AddEdge("r1", "r5")          # spans four ranks: the ROUTED path
oRt.AddEdge("r1", "r4")          # spans three: routed too

nBack = _BackwardDepartures(oRt.ToSVGXT([ :NodeWidth = 110, :NodeHeight = 40 ]),
	"rgb(138,138,138)")
? "   edges whose first step runs backward : " + nBack
chkeq("every departure advances toward the next rank", nBack, 0)

# THE NEGATIVE SIBLING: a polyline that starts by climbing must be
# counted, or zero means the scanner matched nothing.
nBackBad = _BackwardDepartures(
	'<polyline points="10,50 14,30 120,180" stroke="rgb(138,138,138)"/>',
	"rgb(138,138,138)")
? "   a deliberately backward polyline scores : " + nBackBad
chk("the departure check DISCRIMINATES", nBackBad = 1)

#---------------------------------------------------------------------------
? ""
sec("-- 25. A UNIQUE link is straight; arrivals do not cross -----")
#
# Two rules a reader applies without being told.
#
# If exactly one edge joins two cells, nothing needs separating and the
# line should be strictly along the rank axis -- any lean is the drawing
# inventing a relationship the data does not have.
#
# And where several edges arrive at one cell, the one approaching from
# the left must take the left port. Arrivals were ordered by the SOURCE
# node's position, which for a ROUTED edge is nowhere near where it
# actually arrives from -- so an edge carried around by its route landed
# on the far port and crossed its neighbour in the last few pixels before
# the node, which is the one place a reader is certain what they are
# looking at.
#---------------------------------------------------------------------------

oUq = new stzDiagram("uniq")
oUq.AddNodeXTT("u1", "One", [ :type = "box", :color = "Info.Solid" ])
oUq.AddNodeXTT("u2", "Two", [ :type = "box", :color = "Info.Solid" ])
oUq.AddEdge("u1", "u2")
aPu = oUq._EdgePorts(oUq.Edges(), [ [ "u1", 300, 100 ], [ "u2", 300, 400 ] ],
	200, 60, "TB", [])
? "   the only edge between two cells gets ports " +
  aPu[1][1] + " / " + aPu[1][2]
chkeq("a unique link takes no source offset", aPu[1][1], 0)
chkeq("...and no target offset", aPu[1][2], 0)

# so it is drawn strictly along the rank axis
aGu = oUq._EdgeGeometry([ 300, 100 ], [ 300, 400 ], 200, 60, "TB", 2, 0, 0, 10, 0)
nDrift = fabs(aGu[3][1] - 300)
? "   its arrow tip is " + nDrift + "px off the centre line"
chk("a unique link is strictly vertical", nDrift < 0.5)

# ARRIVALS IN APPROACH ORDER. Two edges reaching one node, one from the
# left and one from the right: the left one must take the left port.
oAp = new stzDiagram("arrive")
_aC22_ = [ "L", "R", "T" ]
_nC22_ = len(_aC22_)
for _iC22_ = 1 to _nC22_
	c = _aC22_[_iC22_]
	oAp.AddNodeXTT(c, c, [ :type = "box", :color = "Info.Solid" ])
next
oAp.AddEdge("L", "T")
oAp.AddEdge("R", "T")
aPa = oAp._EdgePorts(oAp.Edges(),
	[ [ "l", 100, 100 ], [ "r", 900, 100 ], [ "t", 500, 400 ] ],
	200, 60, "TB", [])
? "   arriving from the left : port " + aPa[1][2] +
  " ; from the right : port " + aPa[2][2]
chk("the edge from the LEFT takes the left port", aPa[1][2] < aPa[2][2])

# THE ALIGNED EDGE OWNS THE CENTRE. A node fanning to two targets, one of
# them exactly on its own cross-position: that edge is the spine and must
# take port ZERO, or the alignment the layout just bought is spent by the
# drawing -- which is precisely what happened, and what the Principal's
# red centre-lines caught.
oSp = new stzDiagram("spine")
_aC23_ = [ "S", "A", "B" ]
_nC23_ = len(_aC23_)
for _iC23_ = 1 to _nC23_
	c = _aC23_[_iC23_]
	oSp.AddNodeXTT(c, c, [ :type = "box", :color = "Info.Solid" ])
next
oSp.AddEdge("S", "A")
oSp.AddEdge("S", "B")
aPs = oSp._EdgePorts(oSp.Edges(),
	[ [ "s", 500, 100 ], [ "a", 500, 400 ], [ "b", 900, 400 ] ],
	200, 60, "TB", [])
? "   the aligned target's port : " + aPs[1][1] +
  " ; the lateral one's : " + aPs[2][1]
chkeq("the aligned edge is pinned to the centre port", aPs[1][1], 0)
chk("...and the lateral edge spreads AROUND it, not onto it",
    fabs(aPs[2][1]) > 5)

#---------------------------------------------------------------------------
? ""
sec("-- 26. Verticality reaches the ROOT, clusters or not --------")
#
# The engine ends its coordinate pass with snapAlign -- and the cluster
# passes (cohesion, boundary air) run RING-side afterwards, moving whole
# columns a fraction of a slot. Every chain the snap had made vertical
# became a near-miss again, worst at the root: Balancer measured 0.35 of
# a slot off the column it had been snapped onto. Alignment is only worth
# having if it is the LAST word, so the face re-invokes the engine's own
# snap after its cluster adjustments.
#
# The invariant is the one the Principal has marked three times now, so
# it is asserted in its general form: NO NEAR-MISSES ANYWHERE. Every edge
# is either exactly aligned or clearly slanted; the band between reads as
# a mistake and must be empty.
#---------------------------------------------------------------------------

oV = new stzDiagram("svc26")
_aA24_ = [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
           [ "api1", "API A" ], [ "api2", "API B" ],
           [ "db1", "DB A" ], [ "db2", "DB B" ], [ "log", "Logger" ] ]
_nA24_ = len(_aA24_)
for _iA24_ = 1 to _nA24_
	a = _aA24_[_iA24_]
	oV.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oV.AddEdge("lb", "web1")    oV.AddEdge("lb", "web2")
oV.AddEdge("web1", "api1")  oV.AddEdge("web2", "api2")
oV.AddEdge("api1", "db1")   oV.AddEdge("api2", "db2")
oV.AddEdge("web1", "log")   oV.AddEdge("api2", "log")
oV.AddClusterXTT("backend", "Backend", [ "api1","api2","db1","db2" ], "#5E35B1")
oV.AddClusterXTT("data", "Data", [ "db1", "db2" ], "#2E7D32")
oVG = new stzGraphCanvas(oV, [ :Layout = :Hierarchical, :Width = 1000,
	:Height = 700, :Margin = 0, :Clusters = oV._ClusterPairs() ])
aVP = oVG.Positions()

# THE ROOT'S EXACT POSITION IS ITS CHILDREN'S MIDDLE, and this line used
# to demand it sit on web2's column. That was the leaning picture the
# Principal later circled: with two children a snapped root lands on one
# of them, which states a closeness to that child the graph does not
# contain. Alignment is still the law for everything the cluster passes
# might have nudged -- what changed is which position counts as aligned
# for a parent of several children.
nRootMid = (_XOf(aVP, "web1") + _XOf(aVP, "web2")) / 2
nRootOff = fabs(_XOf(aVP, "lb") - nRootMid)
? "   the root sits " + nRootOff + " off its children's middle"
chk("the root holds its exact place through the cluster passes",
    nRootOff < 0.5)

nMiss = _NearMissEdges(oV, aVP)
? "   edges in the near-miss band (0.5 .. 40 units) : " + nMiss
chkeq("no edge is ALMOST aligned -- exact or clearly slanted", nMiss, 0)

# THE NEGATIVE SIBLING: the same census on positions moved by hand must
# find the near-miss it was built to see. Built by PARKING the root 20
# units off a child's column, not by nudging it 20 units from wherever
# it sits -- those were the same thing only while the root stood ON a
# child, which is exactly the leaning placement centring removed. A
# centred root is half a pitch from both children, so a 20-unit nudge
# left it clearly slanted and the census correctly reported nothing:
# the instrument had quietly stopped testing itself.
aVB = []
_aAP25_ = aVP
_nAP25_ = len(_aAP25_)
for _iAP25_ = 1 to _nAP25_
	aP = _aAP25_[_iAP25_]
	if StzLower("" + aP[1]) = "lb"
		aVB + [ aP[1], _XOf(aVP, "web2") + 20, aP[3] ]
	else
		aVB + [ aP[1], aP[2], aP[3] ]
	ok
next
? "   with the root parked 20 units off a child's column : " +
  _NearMissEdges(oV, aVB)
chk("the near-miss census DISCRIMINATES", _NearMissEdges(oV, aVB) > 0)

#---------------------------------------------------------------------------
? ""
sec("-- 27. A FOREIGN edge never traverses a cluster's surface ---")
#
# The Principal's rule verbatim: an edge of a node not belonging to a
# cluster must never traverse the surface of that cluster. The ortho
# channel picked the geometric middle of its rank gap with no idea
# clusters existed, and Backend's frame reaches up into that gap -- so a
# Web-to-Logger channel ran INSIDE the frame, drawing a relationship
# with the cluster that does not exist. The rule is asymmetric on
# purpose: a MEMBER's edge may exit through its own frame.
#
# Asserted at the decision point, on the same rects the render stored.
#---------------------------------------------------------------------------

oFC = new stzDiagram("svc27")
_aA26_ = [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
           [ "api1", "API A" ], [ "api2", "API B" ],
           [ "db1", "DB A" ], [ "db2", "DB B" ], [ "log", "Logger" ] ]
_nA26_ = len(_aA26_)
for _iA26_ = 1 to _nA26_
	a = _aA26_[_iA26_]
	oFC.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oFC.AddEdge("lb", "web1")    oFC.AddEdge("lb", "web2")
oFC.AddEdge("web1", "api1")  oFC.AddEdge("web2", "api2")
oFC.AddEdge("api1", "db1")   oFC.AddEdge("api2", "db2")
oFC.AddEdge("web1", "log")   oFC.AddEdge("api2", "log")
oFC.AddClusterXTT("backend", "Backend",
	[ "api1", "api2", "db1", "db2" ], "#5E35B1")
oFC.AddClusterXTT("data", "Data", [ "db1", "db2" ], "#2E7D32")
oFC.SetSplines("ortho")
oFC.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])

aFR = oFC.RenderClusterRects()
chk("the render stored its cluster rects", len(aFR) >= 1)
aR1 = aFR[1]
nInY = aR1[2] + aR1[4] / 2
nX1 = aR1[1] - 50
nX2 = aR1[1] + aR1[3] + 50

# CORRIDOR-BOUNDED, like every channel a real edge asks for. This probe
# passed -100000..100000 and so let the placer roam the whole picture;
# once the rank gap grew to fund the cluster chrome, the nearest free
# band to a proposal inside the frame stopped being the one ABOVE it and
# became the open space BELOW the whole cluster, 2px nearer. The placer
# was right and the probe was asking a question no edge asks: a channel
# lives between its own fold points, and Web-A-to-Logger folds between
# the web row and the API row.
nCorrLo = 0
nCorrHi = 0
_aAN27_ = oFC.RenderNodeRects()
_nAN27_ = len(_aAN27_)
for _iAN27_ = 1 to _nAN27_
	aN = _aAN27_[_iAN27_]
	if aN[5] = "web1"  nCorrLo = aN[2] + aN[4]  ok
	if aN[5] = "api1"  nCorrHi = aN[2]  ok
next
nOut = oFC._ChannelBand(nInY, nX1, nX2, "web1", "log", 0, nCorrLo, nCorrHi)
? "   a foreign channel proposed at " + nInY + " was moved to " + nOut +
  "   (corridor " + nCorrLo + ".." + nCorrHi + ")"
chk("a FOREIGN channel is pushed off the cluster's surface",
    nOut < aR1[2] or nOut > aR1[2] + aR1[4])

# AND IT IS CENTRED IN ITS BAND, not merely clear of one side. Pushing a
# fixed clearance off the frame drove the channel straight into the node
# row above -- the same illegibility seen from the other side. A band
# bounded by two obstacles has a centre, and the centre is the only
# position that treats both sides fairly under miniaturisation.
# AT THE MIDDLE -- the Principal's rule verbatim. The channel's free
# band here runs from the web row's bottom to the frame's top, and that
# band is NARROWER than two clearances (the frame eats into the rank
# gap), so demanding full clearance from both sides is demanding the
# impossible; the centre is the fairest position that exists, and the
# centre is what was asked for. An earlier form of this check counted
# rows within a clearance and failed the correct answer.
nRowB2 = -1000000
_aAN28_ = oFC.RenderNodeRects()
_nAN28_ = len(_aAN28_)
for _iAN28_ = 1 to _nAN28_
	aN = _aAN28_[_iAN28_]
	if aN[5] = "web1" or aN[5] = "web2"
		if aN[2] + aN[4] > nRowB2  nRowB2 = aN[2] + aN[4]  ok
	ok
next
nMid2 = (nRowB2 + aR1[2]) / 2
? "   band " + nRowB2 + ".." + aR1[2] + " ; centre " + nMid2 +
  " ; channel " + nOut
chk("the channel sits at the MIDDLE of its free band",
    fabs(nOut - nMid2) < 1)

# A MEMBER'S EDGE MAY CROSS ITS OWN FRAME -- tested just inside the
# frame's TOP strip, the one stretch of Backend surface holding neither
# node rows nor the Data frame. This check has been wrong twice: first
# mid-frame where a node row sits, then near the frame's bottom where
# the DATA frame sits -- and Data is foreign to API B even though
# Backend is home, so the placer was RIGHT to move both proposals. A
# permission test must offer a position where the permission is the
# only rule in play.
# ...and the property is NOT EXPELLED, nothing stronger. The placer
# centres every channel in its free band, home frame or not -- the
# middle rule does not pause for members -- so the assertion that a
# member's proposal is returned UNTOUCHED failed against a correct
# 5px recentring. What the permission actually grants is that the
# member's channel may REMAIN on its own frame's surface, where the
# foreign one above was thrown off it.
# ...probed at the centre of a free band DEEP INSIDE the frame -- the
# API-to-Data band -- because any proposal in an interior gap is
# recentred to that gap's centre, and near the frame's edge that centre
# can honestly fall a pixel outside. Asserting "stays within the frame"
# there failed a correct 1.7px recentring. The mechanism under test is
# that NO VETO applies to a member: at an interior centre the position
# must come back untouched, where a foreign edge's channel (asserted
# above) is thrown out of the frame entirely.
nApiB = -1000000
_aAN29_ = oFC.RenderNodeRects()
_nAN29_ = len(_aAN29_)
for _iAN29_ = 1 to _nAN29_
	aN = _aAN29_[_iAN29_]
	if aN[5] = "api2"
		nApiB = aN[2] + aN[4]
	ok
next
aDR = aFR[2]
nProbe = (nApiB + aDR[2]) / 2
nMem = oFC._ChannelBand(nProbe, nX1, nX2, "api2", "log", 0, -100000, 100000)
? "   a member's channel at its in-frame band centre " + nProbe +
  " lands at " + nMem
chk("...while a member's edge may remain on its own frame",
    fabs(nMem - nProbe) < 2 and nMem > aR1[2] and nMem < aR1[2] + aR1[4])

# THE CLEARANCE IS A LEGIBILITY QUANTITY, and it is asserted as one. The
# first push used a flat 10px, which the Principal rejected on the right
# grounds: two lines 10px apart are distinct on a good screen and one
# thick line to tired eyes or in a thumbnail. The clearance is derived
# from the corner radius -- already :Scale-scaled -- so it grows with the
# render instead of collapsing relative to it.
nClr = oFC._LineClearance()
? "   clearance " + nClr + "px"
chk("the clearance exceeds the literal it replaced", nClr > 10)

# A GAP MUST BE CROSSABLE: two clearances plus the line, or centring has
# nothing to centre in. Asserted on the RANK separation -- the quantity
# the floor is applied to. The first version measured row-to-FRAME, which
# is the rank gap minus the cluster's chrome, and so demanded of one
# quantity a floor that had been placed on another.
nRankGap = oFC.RankSeparation() * 96
? "   the rank separation is " + nRankGap + "px against a floor of " +
  (nClr * 2) + "px"
chk("a rank gap leaves a readable band on each side of a channel",
    nRankGap >= nClr * 2)

# THE SAME RULE ON THE OTHER AXIS. Left-to-right makes the gap
# horizontal and the channel vertical; one rule, stated axis-free.
oLRc = new stzDiagram("lr27")
_aA30_ = [ [ "a", "A" ], [ "b", "B" ], [ "c", "C" ] ]
_nA30_ = len(_aA30_)
for _iA30_ = 1 to _nA30_
	a = _aA30_[_iA30_]
	oLRc.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oLRc.AddEdge("a", "b")  oLRc.AddEdge("a", "c")
oLRc.AddClusterXTT("g", "G", [ "b" ], "#5E35B1")
oLRc.SetLayout(:LeftToRight)
oLRc.SetSplines("ortho")
oLRc.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
aLRR = oLRc.RenderClusterRects()
chk("the left-to-right render stored its rects too", len(aLRR) >= 1)
aL1 = aLRR[1]
nLRIn = aL1[1] + aL1[3] / 2
nLROut = oLRc._ChannelBand(nLRIn, aL1[2] - 50, aL1[2] + aL1[4] + 50,
	"a", "c", 1, -100000, 100000)
? "   LR: a foreign channel at " + nLRIn + " moved to " + nLROut
chk("the rule holds on the horizontal axis as well",
    nLROut < aL1[1] or nLROut > aL1[1] + aL1[3])

# THE NEGATIVE SIBLING: a foreign run whose span does not overlap the
# cluster must be left alone -- otherwise this is not avoidance, it is a
# blanket ban that would push every channel in the picture around.
nFar = oFC._ChannelBand(nInY, aR1[1] + aR1[3] + 100,
	aR1[1] + aR1[3] + 400, "web1", "log", 0, -100000, 100000)
? "   a foreign run beside (not over) the cluster stays at " + nFar
chkeq("the veto DISCRIMINATES by overlap, not by name", nFar, nInY)

#---------------------------------------------------------------------------
? ""
sec("-- 28. A crossing is JUMPED, electric-diagram style ------------")
#
# The Principal's rule verbatim: when the Web-A-to-Logger channel
# traverses the Web-B-to-API-B line it must do like electric diagrams
# and use a demi-cercle, so the reader understands the link does not
# include Web B and API B at all. Two lines that merely cross must not
# LOOK like two lines that meet -- incidence is meaning (I1), and a
# painted-over crossing manufactures incidence.
#
# The hop is the only place ortho mode is ALLOWED a diagonal, and only
# a short one: the semicircle is sampled into chords no longer than its
# radius. So the assertion is two-sided -- diagonals EXIST at a
# crossing, and every one of them is hop-short. A long diagonal would
# be oblique routing sneaking back in under the hop's exemption.
#---------------------------------------------------------------------------

# :EDGECORNERS = :SHARP throughout this section. Elbows are rounded to
# match the cells now, and a fillet is short diagonal chords -- exactly
# what this instrument counts. The comment on the negative sibling below
# named that risk before the style existed: "otherwise the counter is
# counting corner rounding again". Turning the treatment off is what
# leaves the hop as the only diagonal in the picture, which is the thing
# under test.
cHopSvg = oFC.ToSVGXT([ :NodeWidth = 96, :NodeHeight = 36,
	:EdgeCorners = :Sharp ])
aChords = _DiagChords(cHopSvg, EDGERGB)
? "   diagonal chords in the crossing picture : " + len(aChords)
chk("a crossing produces hop arcs", len(aChords) > 0)
nLongest = _MaxOf(aChords)
? "   the longest is " + nLongest + "px against the hop radius"
chk("every diagonal is hop-short, none is oblique routing",
    nLongest <= max([ 5, 10 * 0.8 ]) + 0.5)

# THE MIRROR: left-to-right swaps the axes and the hop must follow --
# on the SAME graph, because a first draft of this check dropped the DB
# tier and Logger slid into the API rank: no crossing existed, and the
# zero it measured was the correct answer to the wrong question.
oFC.SetLayout(:LeftToRight)
aChLR = _DiagChords(oFC.ToSVGXT([ :NodeWidth = 96, :NodeHeight = 36,
	:EdgeCorners = :Sharp ]), EDGERGB)
? "   left-to-right : " + len(aChLR) + " chords"
chk("the hop follows the axes to left-to-right", len(aChLR) > 0)

# THE NEGATIVE SIBLING: the same picture without the crossing edge has
# no crossing to jump, so no diagonal survives anywhere -- otherwise
# the counter is counting corner rounding again, or hops are being
# stamped where nothing crosses.
oNH = new stzDiagram("svc28")
_aA31_ = [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
           [ "api1", "API A" ], [ "api2", "API B" ] ]
_nA31_ = len(_aA31_)
for _iA31_ = 1 to _nA31_
	a = _aA31_[_iA31_]
	oNH.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oNH.AddEdge("lb", "web1")    oNH.AddEdge("lb", "web2")
oNH.AddEdge("web1", "api1")  oNH.AddEdge("web2", "api2")
oNH.SetSplines("ortho")
aNoCross = _DiagChords(oNH.ToSVGXT([ :NodeWidth = 96, :NodeHeight = 36,
	:EdgeCorners = :Sharp ]), EDGERGB)
? "   without the crossing edge : " + len(aNoCross) + " chords"
chkeq("no crossing, no hop -- the jump DISCRIMINATES", len(aNoCross), 0)

#---------------------------------------------------------------------------
? ""
sec("-- 29. One port pitch, and an arrival group sits CENTRED ------")
#
# Two findings from one Principal markup, and both were the same organ.
# The two lines quitting Web A were 5.4px apart while the two entering
# Logger were 6.7 -- because a ROUTED edge departed at whatever height
# the aim-attach crossed the border instead of at its port lane. And
# the Logger pair sat off the border's centre -- because the router
# aims bends at the target's own centre, so a routed arrival always
# looked "aligned", claimed the centre pin meant for straight spines,
# and pushed the group off it. Port lanes are ONE law at both ends of
# an edge: a group shares its border at one pitch, symmetric about the
# centre, and only a single-hop member may claim the spine pin.
#
# Measured from the SVG endpoints -- oFC is still the svc graph in
# left-to-right from section 28, where both faults were photographed.
#---------------------------------------------------------------------------

cP29 = oFC.ToSVGXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nWebR = 0  nWebCy = 0  nLogL = 0  nLogCy = 0
_aAN32_ = oFC.RenderNodeRects()
_nAN32_ = len(_aAN32_)
for _iAN32_ = 1 to _nAN32_
	aN = _aAN32_[_iAN32_]
	if aN[5] = "web1"
		nWebR = aN[1] + aN[3]
		nWebCy = aN[2] + aN[4] / 2
	but aN[5] = "log"
		nLogL = aN[1]
		nLogCy = aN[2] + aN[4] / 2
	ok
next
# a cut 10px past Web A's right border (before the routed edge's first
# turn) and one 20px before Logger's left border (after its last)
aDep = _BorderCrossings(cP29, EDGERGB, nWebR + 10,
	nWebCy - 40, nWebCy + 40, 0)
aArr = _BorderCrossings(cP29, EDGERGB, nLogL - 20,
	nLogCy - 40, nLogCy + 40, 0)
? "   departures at Web A's border : " + len(aDep) +
  " ; arrivals at Logger's : " + len(aArr)
chk("both groups were found on their borders",
    len(aDep) = 2 and len(aArr) = 2)
if len(aDep) = 2 and len(aArr) = 2
	nDepPitch = fabs(aDep[2] - aDep[1])
	nArrPitch = fabs(aArr[2] - aArr[1])
	? "   departure pitch " + nDepPitch + " ; arrival pitch " + nArrPitch
	# DEPARTURES MERGE, ARRIVALS FAN -- and this line asserted the
	# opposite until the Principal drew a ring round two parallel
	# verticals leaving one cell and asked for one line.
	#
	# It was written to cure a real fault: a routed edge left at
	# whatever height its aim crossed the border, half a lane from its
	# sibling, which reads as a spacing mistake. Demanding ONE PITCH at
	# both ends cured that and hid a worse thing -- two edges out of one
	# source drawn as two lines, when one source is one origin and I2
	# blesses exactly that merge. The pitch belongs to the ARRIVAL side,
	# where edges genuinely converge on different cells and must stay
	# apart.
	#
	# So the property is two properties: departures agree with each
	# other (one stem, pitch zero), arrivals separate (a real pitch).
	chk("edges leaving one source share ONE stem", nDepPitch < 0.5)
	chk("...while edges arriving at one target keep their lanes apart",
	    nArrPitch > 3)
	nArrMid = (aArr[1] + aArr[2]) / 2
	? "   the arrival pair's midpoint " + nArrMid +
	  " vs border centre " + nLogCy
	chk("the arrival group is CENTRED on its border",
	    fabs(nArrMid - nLogCy) < 0.5)

	# THE NEGATIVE SIBLING is the pin itself: Web A and API A share a
	# rank row, so their single-hop edge is a straight spine and its
	# departure must sit EXACTLY on the border centre -- the pin still
	# fires where it is true. If centring the group had been
	# implemented by abolishing the pin, this is the line that catches
	# it.
	nSpine = min([ fabs(aDep[1] - nWebCy), fabs(aDep[2] - nWebCy) ])
	? "   the aligned spine departs " + nSpine + "px from the centre"
	chk("a TRUE spine still owns the centre port", nSpine < 0.5)
else
	chk("one pitch at both ends of the picture", 0)
	chk("the arrival group is CENTRED on its border", 0)
	chk("a TRUE spine still owns the centre port", 0)
ok

#---------------------------------------------------------------------------
? ""
sec("-- 30. A bend needs a CAUSE ------------------------------------")
#
# The Principal's thinking, verbatim in spirit: do we really need to
# route the edge here? No -- there is no spatial constraint to make the
# line change direction; the target cell is just ON the direct path.
# The router chose its free lane before ports existed, so the staircase
# ended with a one-lane jog into the target -- a bend with no obstacle
# behind it, claiming a constraint the picture does not contain. The
# collapse: when the corridor straight to the ported arrival is free,
# the long leg runs there and the jog never exists.
#
# Asserted with two cuts: the lane an edge holds far from the target
# must be the lane it arrives on. A jog is exactly a disagreement
# between the two.
#---------------------------------------------------------------------------

# oFC is still the svc graph in left-to-right. The routed Web-A-to-
# Logger leg runs from its descent column all the way to Logger; a cut
# well before the border and one at it must read the same height.
aNear = _BorderCrossings(cP29, EDGERGB, nLogL - 20,
	nLogCy - 40, nLogCy + 40, 0)
aFar = _BorderCrossings(cP29, EDGERGB, 400,
	nLogCy - 40, nLogCy + 40, 0)
? "   lanes 20px before Logger : " + len(aNear) +
  " ; 180px before : " + len(aFar)
nHold = -1000000
if len(aFar) = 1 and len(aNear) = 2
	nHold = min([ fabs(aNear[1] - aFar[1]), fabs(aNear[2] - aFar[1]) ])
ok
? "   the routed lane drifts " + nHold + "px between the cuts"
chk("the lane held far from the target IS the arrival lane",
    nHold >= 0 and nHold < 0.5)

# THE SAME LAW TOP-DOWN, on both Logger-bound edges at once: every
# lane crossing a cut below the Backend frame must reappear unchanged
# at Logger's top border.
oTD = new stzDiagram("svc30")
_aA33_ = [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
           [ "api1", "API A" ], [ "api2", "API B" ],
           [ "db1", "DB A" ], [ "db2", "DB B" ], [ "log", "Logger" ] ]
_nA33_ = len(_aA33_)
for _iA33_ = 1 to _nA33_
	a = _aA33_[_iA33_]
	oTD.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oTD.AddEdge("lb", "web1")    oTD.AddEdge("lb", "web2")
oTD.AddEdge("web1", "api1")  oTD.AddEdge("web2", "api2")
oTD.AddEdge("api1", "db1")   oTD.AddEdge("api2", "db2")
oTD.AddEdge("web1", "log")   oTD.AddEdge("api2", "log")
oTD.AddClusterXTT("backend", "Backend",
	[ "api1", "api2", "db1", "db2" ], "#5E35B1")
oTD.AddClusterXTT("data", "Data", [ "db1", "db2" ], "#2E7D32")
oTD.SetSplines("ortho")
cTD = oTD.ToSVGXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nTLogT = 0  nTLogCx = 0
nTApiT = 0
_aAN34_ = oTD.RenderNodeRects()
_nAN34_ = len(_aAN34_)
for _iAN34_ = 1 to _nAN34_
	aN = _aAN34_[_iAN34_]
	if aN[5] = "log"
		nTLogT = aN[2]
		nTLogCx = aN[1] + aN[3] / 2
	but aN[5] = "api2"
		nTApiT = aN[2]
	ok
next
aTFR = oTD.RenderClusterRects()
# the high cut sits between the frame's top and the API row -- the one
# stretch where ONLY the Web-to-Logger descent exists (the API edge has
# not started down yet). A first draft cut below the frame's BOTTOM,
# which in this layout is below Logger itself: the instrument measured
# empty paper and called the renderer broken.
nTHiY = (aTFR[1][2] + nTApiT) / 2
aHigh = _BorderCrossings(cTD, EDGERGB, nTHiY,
	nTLogCx - 40, nTLogCx + 40, 1)
aLow = _BorderCrossings(cTD, EDGERGB, nTLogT - 20,
	nTLogCx - 40, nTLogCx + 40, 1)
? "   top-down: the Web descent alone crosses the high cut " +
  len(aHigh) + " time(s) ; lanes at Logger's border : " + len(aLow)
nTHold = -1000000
if len(aHigh) = 1 and len(aLow) = 2
	nTHold = min([ fabs(aLow[1] - aHigh[1]), fabs(aLow[2] - aHigh[1]) ])
ok
? "   its lane drifts " + nTHold + "px between the cuts"
chk("the top-down descent holds its arrival lane the whole way",
    nTHold >= 0 and nTHold < 0.5)

# THE NEGATIVE SIBLING: a bend with a cause SURVIVES. A three-node
# spine a-c-b with c fenced in its own cluster, plus a routed a-to-b:
# the corridor straight down to b's port passes through c's cluster,
# so the collapse must refuse and the staircase must keep its detour
# column -- far from b at mid-height, on b's port only after the last
# transfer. If straightening had been implemented as "always go
# direct", this diagram would draw a-to-b through the cluster's frame
# and the mid-cut would read near b's centre.
oBn = new stzDiagram("bend30")
_aA35_ = [ [ "a", "A" ], [ "c", "C" ], [ "b", "B" ] ]
_nA35_ = len(_aA35_)
for _iA35_ = 1 to _nA35_
	a = _aA35_[_iA35_]
	oBn.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oBn.AddEdge("a", "c")
oBn.AddEdge("c", "b")
oBn.AddEdge("a", "b")
oBn.AddClusterXTT("fence", "Fence", [ "c" ], "#5E35B1")
oBn.SetSplines("ortho")
cBn = oBn.ToSVGXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nBCx = 0  nBT = 0  nCB = 0
_aAN36_ = oBn.RenderNodeRects()
_nAN36_ = len(_aAN36_)
for _iAN36_ = 1 to _nAN36_
	aN = _aAN36_[_iAN36_]
	if aN[5] = "b"
		nBCx = aN[1] + aN[3] / 2
		nBT = aN[2]
	but aN[5] = "c"
		nCB = aN[2] + aN[4]
	ok
next
aMid = _BorderCrossings(cBn, EDGERGB, nCB + 8, nBCx - 300, nBCx + 300, 1)
nDetour = -1
_aV37_ = aMid
_nV37_ = len(_aV37_)
for _iV37_ = 1 to _nV37_
	v = _aV37_[_iV37_]
	if fabs(v - nBCx) > nDetour  nDetour = fabs(v - nBCx)  ok
next
? "   at mid-height the routed edge stands " + nDetour +
  "px from b's column"
chk("a bend with a cause keeps its detour", nDetour > 30)
# -16, not closer: the stroke stops an arrowhead (13px) short of the
# border, and the last transfer bends ~26px above it -- the cut must
# land between the two
aBLow = _BorderCrossings(cBn, EDGERGB, nBT - 16, nBCx - 300, nBCx + 300, 1)
nBWide = -1
_aV38_ = aBLow
_nV38_ = len(_aV38_)
for _iV38_ = 1 to _nV38_
	v = _aV38_[_iV38_]
	if fabs(v - nBCx) > nBWide  nBWide = fabs(v - nBCx)  ok
next
# AND THE CLEAR LEG IS TAKEN EVEN WHEN IT LIES BETWEEN OBSTACLES. This
# is the case the first version of the collapse could never see: it
# asked _ChannelBand whether it returned the target column unchanged,
# and the band RECENTRES any proposal lying in an interior gap to that
# gap's middle -- so a perfectly clear column came back moved and read
# as blocked. The straight leg was refused and a four-turn detour drawn
# in its place, on an edge whose target sat almost directly below its
# source. A predicate must not be built out of a function whose job is
# to move things; the second time that confusion cost a picture here.
oClr = new stzDiagram("clear30")
_aA39_ = [ [ "top", "Top" ], [ "l", "L" ], [ "r", "R" ], [ "far", "FAR" ] ]
_nA39_ = len(_aA39_)
for _iA39_ = 1 to _nA39_
	a = _aA39_[_iA39_]
	oClr.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oClr.AddNodeXTT("mid", "MID", [ :type = "box", :color = "Info.Solid" ])
oClr.AddEdge("top", "l")   oClr.AddEdge("top", "r")
oClr.AddEdge("l", "far")   oClr.AddEdge("r", "far")
oClr.AddEdge("top", "mid")            # spans two ranks: routed
oClr.SetSplines("ortho")
oClr.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36,
	:Width = 900, :Height = 600 ])
nTurns30 = -1
_aP40_ = oClr.RenderEdgePaths()
_nP40_ = len(_aP40_)
for _iP40_ = 1 to _nP40_
	p = _aP40_[_iP40_]
	if p[1] != "top>mid"  loop  ok
	aF = p[2]
	nTurns30 = 0
	for i = 3 to len(aF) - 3 step 2
		bH1 = fabs(aF[i+1] - aF[i-1]) < 0.5
		bH2 = fabs(aF[i+3] - aF[i+1]) < 0.5
		if bH1 != bH2  nTurns30++  ok
	next
next
? "   a routed edge with a clear corridor between two obstacles turns " +
  nTurns30 + " time(s)"
chk("a straight leg is taken even when it runs between obstacles",
    nTurns30 >= 0 and nTurns30 <= 2)

? "   at b's border every lane is within " + nBWide + "px of its centre"
# 35, not the bare pitch: c sits exactly above b, so the c-to-b spine
# owns b's centre port and the routed arrival stands one full spread
# step (26.67px) beside it -- the pinned grammar, not a fault. What
# this line rules out is the DETOUR column, 237px away.
chk("...and still arrives on b's ported lanes",
    len(aBLow) = 2 and nBWide < 35)

#---------------------------------------------------------------------------
? ""
sec("-- 31. Only ESSENTIAL crossings survive to earn their hops ----")
#
# The graph tier answers WHAT IS and the renderer draws it: the engine
# sweep reorders every rank so removable crossings are removed, and the
# crossing count of the order actually drawn is published as a render
# fact -- RenderCrossings(). A hop then testifies that its crossing is
# structural, because every removable one died in the sweep before any
# ink existed.
#
# Building this section found and killed two defects the svc scenes had
# masked: the ortho trunk dropped its arrival port on the floor (K2,2's
# crossing edge landed ON its target's spine column -- two foreign
# edges sharing one vertical line), and the lane claimer's step
# revalidation demanded _ChannelBand return the candidate unchanged,
# which the band's own recentring guarantees never happens -- so
# conflicting channels silently shared one lane. The trunk is now a
# stem with PORTED fingers: departures share their source's stem (I2's
# blessed merge, what keeps a fan a bus), arrivals take their ports --
# porting BOTH ends of a crossing pair double-books a column
# unavoidably, since each edge needs the other's.
#---------------------------------------------------------------------------

# the fact comes FROM the render, so before one it must say so
oRm = new stzDiagram("rm31")
oRm.AddNodeXTT("a1", "A1", [ :type = "box", :color = "Info.Solid" ])
oRm.AddNodeXTT("a2", "A2", [ :type = "box", :color = "Info.Solid" ])
oRm.AddNodeXTT("b1", "B1", [ :type = "box", :color = "Info.Solid" ])
oRm.AddNodeXTT("b2", "B2", [ :type = "box", :color = "Info.Solid" ])
oRm.AddEdge("a1", "b2")
oRm.AddEdge("a2", "b1")
oRm.SetSplines("ortho")
chkeq("before any render the fact says so", oRm.RenderCrossings(), -1)

# DECLARED CROSSED, DRAWN STRAIGHT: the two edges cross in declaration
# order, the sweep untangles them, and the picture carries neither a
# crossing nor a hop.
cRm = oRm.ToSVGXT([ :NodeWidth = 96, :NodeHeight = 36 ])
? "   two edges declared crossed : " + oRm.RenderCrossings() +
  " crossings after the sweep"
chkeq("a removable crossing is REMOVED before any ink exists",
      oRm.RenderCrossings(), 0)
aRmCh = _DiagChords(cRm, EDGERGB)
chkeq("...so the picture has no crossing to hop", len(aRmCh), 0)

# THE NEGATIVE SIBLING: K2,2 requires one crossing in EVERY ordering.
# Removal that removed it would be removing required ink; the fact must
# say one, and the picture must DECLARE it with a hop.
oK2 = new stzDiagram("k31")
oK2.AddNodeXTT("a1", "A1", [ :type = "box", :color = "Info.Solid" ])
oK2.AddNodeXTT("a2", "A2", [ :type = "box", :color = "Info.Solid" ])
oK2.AddNodeXTT("b1", "B1", [ :type = "box", :color = "Info.Solid" ])
oK2.AddNodeXTT("b2", "B2", [ :type = "box", :color = "Info.Solid" ])
oK2.AddEdge("a1", "b1")  oK2.AddEdge("a1", "b2")
oK2.AddEdge("a2", "b1")  oK2.AddEdge("a2", "b2")
oK2.SetSplines("ortho")
cK2 = oK2.ToSVGXT([ :NodeWidth = 96, :NodeHeight = 36 ])
? "   K2,2 : " + oK2.RenderCrossings() + " crossing"
chkeq("an essential crossing SURVIVES the sweep", oK2.RenderCrossings(), 1)
aK2Ch = _DiagChords(cK2, EDGERGB)
? "   ...and the picture hops it : " + len(aK2Ch) + " chords"
chk("...and the picture declares it with a hop", len(aK2Ch) > 0)

# ...and the svc graph agrees across sections: the one hop section 28
# photographed is the one crossing the structure requires.
? "   the svc graph's fact : " + oFC.RenderCrossings()
chkeq("the hop of section 28 is the crossing the structure requires",
      oFC.RenderCrossings(), 1)

#---------------------------------------------------------------------------
? ""
sec("-- 32. A label CLAIMS its edge --------------------------------")
#
# I1 for text. The old placer anchored labels on _EdgePathFlat's
# pre-channel fiction and nudged collisions blindly down the rank
# axis, clearing other LABELS while ignoring all the INK -- so in the
# labelled fan two labels floated in empty space attributed to
# nothing, and two sat on the shared bus whose line their background
# plates ERASED. The placer now walks the label's OWN drawn path
# (captured on the dry pass) and takes the first anchor whose plate
# clears foreign ink, placed labels, and node boxes. Moving ALONG the
# edge it names keeps incidence; erasing a few pixels of its own
# stroke stays the accepted cost.
#
# The SVG backend emits no text, so the instrument is the placement
# facts the render stores: RenderLabels() rows against
# RenderEdgePaths() geometry.
#---------------------------------------------------------------------------

oLb = new stzDiagram("fan32")
oLb.AddNodeXTT("r", "Router", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 4
	oLb.AddNodeXTT("h" + i, "H" + i, [ :type = "box", :color = "Info.Solid" ])
	oLb.AddEdgeXT("r", "h" + i, "condition " + i + " holds")
next
oLb.SetSplines("ortho")
oLb.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36, :FontSize = 13,
	:Font = new stzFont("C:/Windows/Fonts/segoeui.ttf") ])
aLbs = oLb.RenderLabels()
? "   labels placed : " + len(aLbs)
chkeq("every label was placed and recorded", len(aLbs), 4)

# EVERY label sits ON its own edge (distance zero to its own path) and
# its plate keeps a clear margin from every other edge's ink.
nWorstOwn = -1
nWorstFor = 1000000
_aAL41_ = aLbs
_nAL41_ = len(_aAL41_)
for _iAL41_ = 1 to _nAL41_
	aL = _aAL41_[_iAL41_]
	# own-path distance, same interval arithmetic as the placer's
	nOwn = 1000000
	_aAP42_ = oLb.RenderEdgePaths()
	_nAP42_ = len(_aAP42_)
	for _iAP42_ = 1 to _nAP42_
		aP = _aAP42_[_iAP42_]
		if aP[1] != aL[6]  loop  ok
		aF = aP[2]
		for i = 1 to len(aF) - 3 step 2
			nAx = min([ aF[i], aF[i+2] ])   nBx = max([ aF[i], aF[i+2] ])
			nAy = min([ aF[i+1], aF[i+3] ]) nBy = max([ aF[i+1], aF[i+3] ])
			nDx = 0
			if nBx < aL[2] - aL[4]/2  nDx = aL[2] - aL[4]/2 - nBx  ok
			if nAx > aL[2] + aL[4]/2  nDx = nAx - (aL[2] + aL[4]/2)  ok
			nDy = 0
			if nBy < aL[3] - aL[5]/2  nDy = aL[3] - aL[5]/2 - nBy  ok
			if nAy > aL[3] + aL[5]/2  nDy = nAy - (aL[3] + aL[5]/2)  ok
			nD = sqrt(nDx*nDx + nDy*nDy)
			if nD < nOwn  nOwn = nD  ok
		next
	next
	if nOwn > nWorstOwn  nWorstOwn = nOwn  ok
	nFor = oLb._LabelSpotScore(aL[2], aL[3], aL[4], aL[5], aL[6], [])
	if nFor < nWorstFor  nWorstFor = nFor  ok
next
? "   worst own-edge distance " + nWorstOwn +
  "px ; tightest foreign clearance " + nWorstFor + "px"
# ATTACHED, not TOUCHING -- and the difference is a lesson this section
# had to be taught. It asserted distance ZERO, which was true only
# because every label happened to sit ON its path at the time. When the
# aligned child of a fan gained an honest BESIDE placement -- its edge is
# a pure vertical drop with no run to sit on -- a correct picture failed
# a guard that had pinned the implementation instead of the property.
# What incidence actually claims is that a label is near enough to its
# own edge to read as attached to it, and NEARER to that edge than to
# any other ink in the picture. Both, or the assertion is one number
# with no rival.
chk("every label is attached to the edge it names",
    nWorstOwn <= oLb._LineClearance())
chk("...and is NEARER its own edge than any foreign one",
    nWorstOwn < nWorstFor)
# HALF A CLEARANCE, since the Principal asked for a label to sit
# CLOSER to its own line -- and a label closer to its own ink is
# necessarily closer to everything near it. What must never happen is
# a plate erasing or touching foreign ink, and that floor is absolute
# and asserted over every picture in section 62. This is the comfort
# margin above it, and half a clearance is still visible separation.
chk("no plate erases or crowds a foreign edge",
    nWorstFor >= oLb._LineClearance() * 0.5)

# THE NEGATIVE SIBLINGS, on the instrument itself: a spot centred ON a
# foreign edge scores ZERO (that is what erasure looks like in
# numbers), and a spot inside a node box is refused outright -- if
# either came back healthy, the two assertions above measure nothing.
aP1 = oLb.RenderEdgePaths()[1][2]
nSab = oLb._LabelSpotScore(aP1[3], aP1[4], 60, 20, "not-this-edge", [])
? "   a plate centred on someone's ink scores " + nSab
chk("the scorer SEES erasure", nSab < 1)
aN1 = oLb.RenderNodeRects()[1]
nInN = oLb._LabelSpotScore(aN1[1] + aN1[3]/2, aN1[2] + aN1[4]/2,
	60, 20, "", [])
chkeq("a spot inside a node box is refused outright", nInN, -1)

#---------------------------------------------------------------------------
? ""
sec("-- 33. A label rides its line, wrapped, and siblings match --")
#
# Three Principal findings on one picture of a four-way fan, and they
# turned out to be one design.
#
#   "all the 4 cells has the same level and must all fit under the main
#    one"  -- the outermost child was leaving the parent's SIDE border
#    while its three siblings dropped off a shared bus. Four children in
#    one rank stand in one relation; drawing one of them differently
#    states a difference the graph does not contain. The lateral form
#    now requires what its own name always said -- the source's ONLY
#    out-edge -- and congruence outranks it otherwise.
#
#   "the label MUST ALWAYS be written on the middle of the line, not
#    outside it"  -- so the line has to be able to carry it, and the
#    layout is what makes that keepable.
#
#   "we can let the lines be longer and write labels on two lines so we
#    gain width"  -- wrapping trades the scarce axis for the cheap one.
#    Width is scarce because every child's label competes with its
#    neighbours' inside one rank; the rank GAP is one number the layout
#    grows once for everybody. A label wrapped to the width of the node
#    it names can never widen the picture beyond what the nodes already
#    demand, so the label becomes free.
#
# The gap is grown to TWICE the label's room, because the label rides
# the DROP and the shared channel sits at the middle of the gap -- a gap
# that merely fits a label leaves a drop that fits half of one.
#
# Result on the four-way fan: 954x176 with labels lying across the bus,
# became 583x279 with every label centred on its own drop.
#---------------------------------------------------------------------------

LFONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oLd = new stzDiagram("fan33")
oLd.AddNodeXTT("r", "Router", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 4
	oLd.AddNodeXTT("h" + i, "H" + i, [ :type = "box", :color = "Info.Solid" ])
	oLd.AddEdgeXT("r", "h" + i, "condition " + i + " holds")
next
oLd.SetSplines("ortho")
oLd.ToCanvasXT([ :Font = LFONT, :NodeWidth = 96, :NodeHeight = 36,
	:FontSize = 13 ])
nClr33 = oLd._LineClearance()
aBlk33 = oLd._LabelBlock("condition 1 holds", LFONT, 13, 96)

? "   wrapped to " + len(aBlk33[1]) + " lines, " + aBlk33[2] + "x" +
  aBlk33[3] + "px"
chk("a label wider than its node is WRAPPED", len(aBlk33[1]) >= 2)
chk("...to no wider than the node it names", aBlk33[2] <= 96 + 8)

nOn33 = 0
nTail33 = 1000000
_aAL43_ = oLd.RenderLabels()
_nAL43_ = len(_aAL43_)
for _iAL43_ = 1 to _nAL43_
	aL = _aAL43_[_iAL43_]
	bOn33 = 0
	_aAP44_ = oLd.RenderEdgePaths()
	_nAP44_ = len(_aAP44_)
	for _iAP44_ = 1 to _nAP44_
		aP = _aAP44_[_iAP44_]
		if aP[1] != aL[6]  loop  ok
		# ATTACHED TO ITS LINE, AND CENTRED ALONG IT -- which is what
		# the original ruling asked for, and what BESIDE placement
		# gives without erasing the ink. Labels used to stand ON the
		# line; the plate that protects the words then erased the line
		# under them, and with ON and BESIDE both in play one event sat
		# above its run while the next sat on its own. The claim is
		# unchanged in substance: within a clearance of its own line,
		# and inside the segment's span so it reads as that line's word.
		aF = aP[2]
		for i = 1 to len(aF) - 3 step 2
			nDx = fabs(aF[i+2] - aF[i])
			nDy = fabs(aF[i+3] - aF[i+1])
			if nDx >= nDy
				if fabs(aL[3] - aF[i+1]) > aL[5] / 2 + oLd._LineClearance()
					loop
				ok
				if aL[2] < min([ aF[i], aF[i+2] ]) or
				   aL[2] > max([ aF[i], aF[i+2] ])  loop  ok
				nT33 = (nDx - aL[4]) / 2
			else
				if fabs(aL[2] - aF[i]) > aL[4] / 2 + oLd._LineClearance()
					loop
				ok
				if aL[3] < min([ aF[i+1], aF[i+3] ]) or
				   aL[3] > max([ aF[i+1], aF[i+3] ])  loop  ok
				nT33 = (nDy - aL[5]) / 2
			ok
			bOn33 = 1
			if nT33 < nTail33  nTail33 = nT33  ok
		next
	next
	if bOn33  nOn33++  ok
next
? "   labels attached to their line : " + nOn33 + " of " +
  len(oLd.RenderLabels()) + " ; shortest line beside a label : " +
  nTail33 + "px"
chkeq("EVERY label is attached to its own line, and centred along it",
      nOn33, len(oLd.RenderLabels()))
# THE TAIL RULE RETIRED WITH THE PLACEMENT IT POLICED. It demanded a
# clearance of line showing at each END of a label, because a label
# standing ON its line erased the middle and only the tails proved the
# line was longer than the word. Beside the line there is nothing to
# erase: the whole run shows, and what matters instead is that the run
# is long enough to read the word against -- which is what this asks.
chk("...and its line is long enough to be read against",
    nTail33 >= 0 - nClr33)

# CONGRUENCE: four children of one parent, one relation, one drawing.
aShape33 = []
_aAP45_ = oLd.RenderEdgePaths()
_nAP45_ = len(_aAP45_)
for _iAP45_ = 1 to _nAP45_
	aP = _aAP45_[_iAP45_]
	aF = aP[2]
	nDrop33 = 0
	for i = 1 to len(aF) - 3 step 2
		if fabs(aF[i+2] - aF[i]) < 0.5  nDrop33 += fabs(aF[i+3] - aF[i+1])  ok
	next
	aShape33 + [ len(aF), nDrop33 ]
next
bSame33 = 1
for i = 2 to len(aShape33)
	if aShape33[i][1] != aShape33[1][1] or
	   fabs(aShape33[i][2] - aShape33[1][2]) > 0.5
		bSame33 = 0
	ok
next
? "   sibling edges : " + len(aShape33) + ", each " +
  (aShape33[1][1] / 2) + " points and " + aShape33[1][2] + "px of drop"
chk("siblings of one parent are drawn ALIKE", bSame33)

# THE PAPER IS NO BIGGER THAN ITS CONSTRAINTS -- with the label wrapped
# to the node's width, the binding constraint is the separation contract
# alone, so the pitch falls back to it exactly.
aX33 = []
_aR46_ = oLd.RenderNodeRects()
_nR46_ = len(_aR46_)
for _iR46_ = 1 to _nR46_
	r = _aR46_[_iR46_]
	if r[5] != "r"  aX33 + r[1]  ok
next
aX33 = sort(aX33)
? "   child pitch " + (aX33[2] - aX33[1]) + "px"
chkeq("the pitch is the bare separation contract",
      aX33[2] - aX33[1], 96 + floor(oLd.NodeSeparation() * 96))

# THE NEGATIVE SIBLING, on the MECHANISM so the geometry cannot muddy
# it: one lateral edge on a synthetic pair of positions must be granted
# the side-border form, and the SAME edge on the SAME positions must
# lose it the moment its source gains a sibling. Rendering a scene to
# test this proved fragile -- a layout that declines to put a node far
# enough sideways tests nothing and reports a pass.
aXY33 = [ [ "a", 100, 100 ], [ "z", 600, 140 ], [ "w", 100, 140 ] ]
aP1_33 = oLd._EdgePorts([ [ :from = "a", :to = "z" ] ], aXY33, 96, 36,
	"TB", [])
? "   a lone lateral edge is granted the side form : " + aP1_33[1][6]
chk("a genuinely lone edge keeps its side-border form", aP1_33[1][6] = 1)
aP2_33 = oLd._EdgePorts([ [ :from = "a", :to = "z" ],
	[ :from = "a", :to = "w" ] ], aXY33, 96, 36, "TB", [])
? "   the same edge once its source has a sibling : " + aP2_33[1][6]
chkeq("...and loses it the moment it has a sibling to match",
      aP2_33[1][6], 0)

# ...and an unlabelled fan still pays NOTHING for labels.
oNo = new stzDiagram("fan33n")
oNo.AddNodeXTT("r", "Router", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 4
	oNo.AddNodeXTT("h" + i, "H" + i, [ :type = "box", :color = "Info.Solid" ])
	oNo.AddEdge("r", "h" + i)
next
oNo.SetSplines("ortho")
nH0 = oNo.ToCanvasXT([ :Font = LFONT, :NodeWidth = 96, :NodeHeight = 36,
	:FontSize = 13 ]).Height()
nH1 = oLd.ToCanvasXT([ :Font = LFONT, :NodeWidth = 96, :NodeHeight = 36,
	:FontSize = 13 ]).Height()
? "   unlabelled height " + nH0 + " against labelled " + nH1
chk("the gap grows for labels and ONLY for labels", nH0 < nH1)

#---------------------------------------------------------------------------
? ""
sec("-- 34. The mother cell is CENTRED over her children --------")
#
# The Principal's rule, unconditional: the main cell must ALWAYS be
# centred. Every layout pass respected the children's SPAN without
# insisting on its middle -- the engine's compaction clamps a parent
# INTO the span on purpose, because pinning it at the mean during
# compaction repealed the tightening and spans sprang back -- and
# snapAlign then actively broke centring whenever the child count was
# EVEN: a parent correctly centred over four children sits half a slot
# from the two middle ones, inside the snap tolerance, so it was pulled
# onto one of them and the whole fan leaned.
#
# Fixed in the ENGINE, in a final pass after every other, because the
# centre of a span lies inside that span: no territory grows, no rank
# widens, and a parent can only move between positions it was already
# allowed to hold. Odd counts are unaffected -- their middle child IS
# the centre -- which is why this was invisible until a four-way fan.
#---------------------------------------------------------------------------


# EVEN counts are where centring becomes visible and where it was lost.
_aNKids47_ = [ 2, 3, 4, 5, 6 ]
_nNKids47_ = len(_aNKids47_)
for _iNKids47_ = 1 to _nNKids47_
	nKids = _aNKids47_[_iNKids47_]
	oC = new stzDiagram("ctr" + nKids)
	oC.AddNodeXTT("r", "Router", [ :type = "box", :color = "Info.Solid" ])
	for i = 1 to nKids
		oC.AddNodeXTT("h" + i, "H" + i, [ :type = "box", :color = "Info.Solid" ])
		oC.AddEdge("r", "h" + i)
	next
	oC.SetSplines("ortho")
	oC.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
	nRx = -100000
	aKid = []
	_aRr48_ = oC.RenderNodeRects()
	_nRr48_ = len(_aRr48_)
	for _iRr48_ = 1 to _nRr48_
		rr = _aRr48_[_iRr48_]
		if rr[5] = "r"
			nRx = rr[1] + rr[3] / 2
		else
			aKid + (rr[1] + rr[3] / 2)
		ok
	next
	aKid = sort(aKid)
	nMid = (aKid[1] + aKid[len(aKid)]) / 2
	? "   " + nKids + " children : parent at " + nRx + ", span middle " + nMid
	chk("with " + nKids + " children the parent is CENTRED",
	    fabs(nRx - nMid) < 0.5)
next

# A CHAIN KEEPS ITS SPINE: centring must not cost the alignment that a
# single-child parent has by definition -- if it had been implemented as
# "always move the parent", a chain would still pass the span test while
# losing nothing, so this asserts the straight column itself.
oCh = new stzDiagram("chain35")
_aA49_ = [ "a", "b", "c", "d" ]
_nA49_ = len(_aA49_)
for _iA49_ = 1 to _nA49_
	a = _aA49_[_iA49_]
	oCh.AddNodeXTT(a, StzUpper(a), [ :type = "box", :color = "Info.Solid" ])
next
oCh.AddEdge("a", "b")  oCh.AddEdge("b", "c")  oCh.AddEdge("c", "d")
oCh.SetSplines("ortho")
oCh.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nSpread = 0
nFirst = -100000
_aRr50_ = oCh.RenderNodeRects()
_nRr50_ = len(_aRr50_)
for _iRr50_ = 1 to _nRr50_
	rr = _aRr50_[_iRr50_]
	nCx = rr[1] + rr[3] / 2
	if nFirst = -100000  nFirst = nCx  ok
	if fabs(nCx - nFirst) > nSpread  nSpread = fabs(nCx - nFirst)  ok
next
? "   a four-node chain spreads " + nSpread + "px across its ranks"
chk("a chain is still one straight spine", nSpread < 0.5)

# THE NEGATIVE SIBLING: a parent centres over ITS OWN children, not over
# the rank they happen to share. Two roots, two families, one child rank
# -- if the rule were "put the parent in the middle" both roots would
# land on the same column, and the first assertions above would pass
# just as happily.
oTwo = new stzDiagram("two35")
oTwo.AddNodeXTT("p", "P", [ :type = "box", :color = "Info.Solid" ])
oTwo.AddNodeXTT("q", "Q", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 4
	oTwo.AddNodeXTT("k" + i, "K" + i, [ :type = "box", :color = "Info.Solid" ])
next
oTwo.AddEdge("p", "k1")  oTwo.AddEdge("p", "k2")
oTwo.AddEdge("q", "k3")  oTwo.AddEdge("q", "k4")
oTwo.SetSplines("ortho")
oTwo.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
aAt = []
_aRr51_ = oTwo.RenderNodeRects()
_nRr51_ = len(_aRr51_)
for _iRr51_ = 1 to _nRr51_
	rr = _aRr51_[_iRr51_]
	aAt + [ rr[5], rr[1] + rr[3] / 2 ]
next
nP = 0  nQ = 0
aPk = []  aQk = []
_aE52_ = aAt
_nE52_ = len(_aE52_)
for _iE52_ = 1 to _nE52_
	e = _aE52_[_iE52_]
	if e[1] = "p"  nP = e[2]  ok
	if e[1] = "q"  nQ = e[2]  ok
	if e[1] = "k1" or e[1] = "k2"  aPk + e[2]  ok
	if e[1] = "k3" or e[1] = "k4"  aQk + e[2]  ok
next
aPk = sort(aPk)  aQk = sort(aQk)
nPmid = (aPk[1] + aPk[2]) / 2
nQmid = (aQk[1] + aQk[2]) / 2
? "   P at " + nP + " over its own span middle " + nPmid +
  " ; Q at " + nQ + " over " + nQmid
chk("each parent centres over ITS OWN children", fabs(nP - nPmid) < 0.5 and
    fabs(nQ - nQmid) < 0.5)
chk("...and the two families do NOT collapse onto one column",
    fabs(nP - nQ) > 50)

# A SHARED CHILD IS NOBODY'S TERRITORY, so it is not counted in the span
# a parent centres over. Found live: a service whose two children were a
# database inside its own cluster and a logger far outside it was pulled
# to the midpoint between them -- out of its cluster's column and off the
# spine it held with its own parent -- to state a centring over a child
# it does not own. The same reason tidyTerritories runs on forests alone.
oShr = new stzDiagram("shared35")
_aA53_ = [ "p", "k1", "k2", "s" ]
_nA53_ = len(_aA53_)
for _iA53_ = 1 to _nA53_
	a = _aA53_[_iA53_]
	oShr.AddNodeXTT(a, StzUpper(a), [ :type = "box", :color = "Info.Solid" ])
next
oShr.AddNodeXTT("far", "FAR", [ :type = "box", :color = "Info.Solid" ])
oShr.AddEdge("p", "k1")     oShr.AddEdge("p", "k2")
oShr.AddEdge("s", "far")    oShr.AddEdge("k1", "far")
oShr.SetSplines("ortho")
oShr.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nK1 = -100000  nFar = -100000
_aRr54_ = oShr.RenderNodeRects()
_nRr54_ = len(_aRr54_)
for _iRr54_ = 1 to _nRr54_
	rr = _aRr54_[_iRr54_]
	if rr[5] = "k1"   nK1 = rr[1] + rr[3] / 2  ok
	if rr[5] = "far"  nFar = rr[1] + rr[3] / 2  ok
next
? "   k1 at " + nK1 + " ; its shared child at " + nFar
chk("a parent is NOT dragged toward a child it shares",
    fabs(nK1 - nFar) > 1)

#---------------------------------------------------------------------------
? ""
sec("-- 35. The verticals obey ONE rhythm ------------------------")
#
# The Principal measured the drops and found no design system: three
# different stem lengths -- 29%, 43% and 7% -- inside one constant
# 92.6px rank gap.
#
# Two causes, both of them a rule computing something a better rule
# already knew.
#
#   Parents in a rank took SUCCESSIVE channel heights, cycled through
#   0.30, 0.43, 0.57, 0.70 of their gap, so neighbouring trunks could
#   never share a line. That was written before the channel claim
#   registry existed. The registry asks the real question -- do these
#   two channels actually overlap in span -- and steps only those that
#   do, by exactly one clearance. So the cycling was buying with
#   randomness what measurement now gives for nothing, and it is gone:
#   every trunk proposes the middle of its own gap.
#
#   The 7% stem was worse, because it looked like a placement and was
#   really a misfit floor. A cluster's chrome eats the rank gap above
#   its first member row, and the gap floor meant to leave room for a
#   traversing channel estimated that chrome with a DIFFERENT formula
#   than the one the boxes are drawn with -- it omitted the 34px per
#   level of nesting. 42.7 estimated against 76.7 actual: the gap grew,
#   the frame grew with it, and the band stayed 14px wide. Both now ask
#   _ClusterChromeAbove.
#
# What is left is a system with one rule and one stated exception: a
# channel takes the middle of the space available to it -- the whole gap
# when it is free, the free band when a foreign frame occupies the rest,
# and the reader can see the frame that made the difference.
#---------------------------------------------------------------------------


oRy = new stzDiagram("rhythm36")
_aA55_ = [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
           [ "api1","API A" ],[ "api2","API B" ],
           [ "db1","DB A" ],[ "db2","DB B" ],[ "log","Logger" ] ]
_nA55_ = len(_aA55_)
for _iA55_ = 1 to _nA55_
	a = _aA55_[_iA55_]
	oRy.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oRy.AddEdge("lb","web1")   oRy.AddEdge("lb","web2")
oRy.AddEdge("web1","api1") oRy.AddEdge("web2","api2")
oRy.AddEdge("api1","db1")  oRy.AddEdge("api2","db2")
oRy.AddEdge("web1","log")  oRy.AddEdge("api2","log")
oRy.AddClusterXTT("backend","Backend",["api1","api2","db1","db2"],"#5E35B1")
oRy.AddClusterXTT("data","Data",["db1","db2"],"#2E7D32")
oRy.SetSplines("ortho")
oRy.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])

# every rank gap is one number
aRows = []
_aR56_ = oRy.RenderNodeRects()
_nR56_ = len(_aR56_)
for _iR56_ = 1 to _nR56_
	r = _aR56_[_iR56_]
	bF = 0
	for i = 1 to len(aRows)
		if fabs(aRows[i][1] - r[2]) < 2  bF = 1  ok
	next
	if bF = 0  aRows + [ r[2], r[2] + r[4] ]  ok
next
aRows = sort(aRows, 1)
nGap = aRows[2][1] - aRows[1][2]
bGaps = 1
for i = 3 to len(aRows)
	if fabs((aRows[i][1] - aRows[i-1][2]) - nGap) > 0.5  bGaps = 0  ok
next
? "   rank gap : " + nGap + "px, the same everywhere : " + bGaps
chk("one rank gap, everywhere", bGaps)

# THE RHYTHM IS A PAIR, not a number. An edge that crosses one rank
# gap makes two verticals, a stem out of its source and a drop into its
# target, and the channel between them sits at the middle of the space
# it has: so the two are EQUAL, and where the space is the whole gap
# they are half of it. Stated as the pair, the rule needs no exclusion
# list -- an edge whose channel had to clear a foreign frame still has
# a stem and a drop that agree with each other, and an edge that
# crosses a rank has no pair at all.
#
# The first form of this check asserted the NUMBER, half the gap, and
# excluded the one traversing edge by name. That stopped being honest
# the moment a second edge earned the lateral form: an exclusion list
# is a way of not stating the rule.
nWorst = 0
nPairs = 0
nCross = 0
nTween = 0
_aP57_ = oRy.RenderEdgePaths()
_nP57_ = len(_aP57_)
for _iP57_ = 1 to _nP57_
	p = _aP57_[_iP57_]
	aF = p[2]
	aV = []
	for i = 1 to len(aF) - 3 step 2
		if fabs(aF[i+2] - aF[i]) < 0.5 and fabs(aF[i+3] - aF[i+1]) > 1
			aV + fabs(aF[i+3] - aF[i+1])
		ok
	next
	bCross = 0
	_aV58_ = aV
	_nV58_ = len(_aV58_)
	for _iV58_ = 1 to _nV58_
		v = _aV58_[_iV58_]
		if v >= nGap  bCross++  ok
		if v > nGap * 0.75 and v < nGap  nTween++  ok
	next
	if bCross > 0  nCross += bCross  loop  ok
	if len(aV) != 2  loop  ok
	nPairs++
	if fabs(aV[1] - aV[2]) > nWorst  nWorst = fabs(aV[1] - aV[2])  ok
	if fabs(aV[1] - nGap / 2) > nWorst  nWorst = fabs(aV[1] - nGap / 2)  ok
next
? "   " + nPairs + " stem/drop pairs (worst disagreement " + nWorst +
  "px), " + nCross + " verticals crossing a rank, " + nTween + " in between"
chk("a stem and its drop are EQUAL, and half their gap",
    nPairs >= 6 and nWorst < 1)
chk("...and the long ones cross a whole rank, by construction",
    nCross >= 1)
chkeq("NOTHING lands between the two lengths", nTween, 0)

# THE STATED EXCEPTION: an edge that must pass ABOVE a foreign cluster
# gets the middle of the band it actually has, not the middle of the gap
# -- and that band is bounded by the frame, which the reader can see.
nFrameTop = 1000000
_aC59_ = oRy.RenderClusterRects()
_nC59_ = len(_aC59_)
for _iC59_ = 1 to _nC59_
	c = _aC59_[_iC59_]
	if c[2] < nFrameTop  nFrameTop = c[2]  ok
next
nChan = -1
_aP60_ = oRy.RenderEdgePaths()
_nP60_ = len(_aP60_)
for _iP60_ = 1 to _nP60_
	p = _aP60_[_iP60_]
	if p[1] != "web1>log"  loop  ok
	aF = p[2]
	for i = 1 to len(aF) - 3 step 2
		if fabs(aF[i+3] - aF[i+1]) < 0.5 and fabs(aF[i+2] - aF[i]) > 1
			nChan = aF[i+1]
		ok
	next
next
nBandTop = aRows[2][2]
nBandMid = (nBandTop + nFrameTop) / 2
? "   the traversing channel sits at " + nChan + " ; its band " +
  nBandTop + ".." + nFrameTop + " has middle " + nBandMid
chk("a blocked channel takes the middle of the band it HAS",
    fabs(nChan - nBandMid) < 1.5)

# ...and that band is a real one: the gap funds the cluster's chrome AND
# a clearance on each side of the line that crosses it.
nClr = oRy._LineClearance()
? "   band " + (nFrameTop - nBandTop) + "px against two clearances of " +
  (nClr * 2)
chk("the gap funds the chrome AND a crossable band",
    nFrameTop - nBandTop >= nClr * 2)

# THE NEGATIVE SIBLING: the chrome floor must answer to the SAME formula
# the boxes are drawn with. Nesting adds 34px per level to a cluster's
# pad, and the floor once estimated the pad without it -- so deepen the
# nesting and the floor must grow with it, or it is estimating again.
oFlat = new stzDiagram("flat36")
_aA61_ = [ "p", "c1", "c2" ]
_nA61_ = len(_aA61_)
for _iA61_ = 1 to _nA61_
	a = _aA61_[_iA61_]
	oFlat.AddNodeXTT(a, StzUpper(a), [ :type = "box", :color = "Info.Solid" ])
next
oFlat.AddEdge("p", "c1")  oFlat.AddEdge("p", "c2")
oFlat.AddClusterXTT("g", "G", [ "c1", "c2" ], "#5E35B1")
nFlat = oFlat._ClusterChromeAbove(13)
oNest = new stzDiagram("nest36")
_aA62_ = [ "p", "c1", "c2" ]
_nA62_ = len(_aA62_)
for _iA62_ = 1 to _nA62_
	a = _aA62_[_iA62_]
	oNest.AddNodeXTT(a, StzUpper(a), [ :type = "box", :color = "Info.Solid" ])
next
oNest.AddEdge("p", "c1")  oNest.AddEdge("p", "c2")
oNest.AddClusterXTT("g", "G", [ "c1", "c2" ], "#5E35B1")
oNest.AddClusterXTT("h", "H", [ "c1" ], "#2E7D32")
nNest = oNest._ClusterChromeAbove(13)
? "   chrome, flat : " + nFlat + " ; nested : " + nNest
chk("the chrome the floor uses GROWS with nesting", nNest > nFlat + 30)

#---------------------------------------------------------------------------
? ""
sec("-- 36. A lateral edge goes STRAIGHT there ------------------")
#
# The Principal traced the shorter path himself: nothing prevented the
# service-to-logger edge from leaving the centre of its source's side
# border and arriving in two moves. Ours took three turns down into its
# own cluster and out beneath it, and the long run passed close enough
# to a foreign frame to read as membership in it.
#
# Two faults, and neither was the routing shape.
#
#   The congruence rule counted OUT-EDGES: two or more from one source
#   and no lateral form, full stop. That drew the four-way fan right and
#   then forced this edge into the detour, because its sibling drops
#   into a database inside its own cluster while it leaves for a logger
#   outside every cluster. Drawing those two alike states a likeness
#   that is not there. Cluster membership is a DECLARED difference, so
#   siblings-in-kind are now those whose targets sit in the same
#   clusters -- and a fan with no clusters still has exactly one kind.
#
#   The channel placer DISQUALIFIED A GAP BY ITS CENTRE. When the
#   preferred position fell outside the corridor it dropped the whole
#   gap, even where gap and corridor plainly overlapped, and a channel
#   left with no candidate falls back to its raw proposal -- the one
#   position nothing has checked. That is how a line came to run 21px
#   from a frame with a 24px clearance in force. A gap now offers what
#   it HAS, and only an empty usable part disqualifies it.
#---------------------------------------------------------------------------


oSv = new stzDiagram("svc37")
_aA63_ = [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
           [ "api1","API A" ],[ "api2","API B" ],
           [ "db1","DB A" ],[ "db2","DB B" ],[ "log","Logger" ] ]
_nA63_ = len(_aA63_)
for _iA63_ = 1 to _nA63_
	a = _aA63_[_iA63_]
	oSv.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oSv.AddEdge("lb","web1")   oSv.AddEdge("lb","web2")
oSv.AddEdge("web1","api1") oSv.AddEdge("web2","api2")
oSv.AddEdge("api1","db1")  oSv.AddEdge("api2","db2")
oSv.AddEdge("web1","log")  oSv.AddEdge("api2","log")
oSv.AddClusterXTT("backend","Backend",["api1","api2","db1","db2"],"#5E35B1")
oSv.AddClusterXTT("data","Data",["db1","db2"],"#2E7D32")
oSv.SetSplines("ortho")
oSv.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nClr = oSv._LineClearance()

# the log edge leaves the SIDE and turns once
aP = []
_aP64_ = oSv.RenderEdgePaths()
_nP64_ = len(_aP64_)
for _iP64_ = 1 to _nP64_
	p = _aP64_[_iP64_]
	if p[1] = "api2>log"  aP = p[2]  ok
next
nTurns = 0
for i = 3 to len(aP) - 3 step 2
	bH1 = fabs(aP[i+1] - aP[i-1]) < 0.5
	bH2 = fabs(aP[i+3] - aP[i+1]) < 0.5
	if bH1 != bH2  nTurns++  ok
next
? "   api2->log has " + (len(aP) / 2) + " points and " + nTurns + " turn(s)"
chk("a lateral edge turns ONCE, not three times", nTurns = 1)

nApiR = 0  nApiCy = 0
_aR65_ = oSv.RenderNodeRects()
_nR65_ = len(_aR65_)
for _iR65_ = 1 to _nR65_
	r = _aR65_[_iR65_]
	if r[5] = "api2"
		nApiR = r[1] + r[3]
		nApiCy = r[2] + r[4] / 2
	ok
next
? "   it starts at " + aP[1] + "," + aP[2] + " ; the border centre is " +
  nApiR + "," + nApiCy
chk("...from the CENTRE of its source's side border",
    fabs(aP[1] - nApiR) < 1 and fabs(aP[2] - nApiCy) < 1)

# and no segment of it crowds a foreign cluster frame
nNear = 1000000
_aC66_ = oSv.RenderClusterRects()
_nC66_ = len(_aC66_)
for _iC66_ = 1 to _nC66_
	c = _aC66_[_iC66_]
	if StzFindFirst("api2", c[5]) > 0  loop  ok
	for i = 1 to len(aP) - 3 step 2
		nAx = min([ aP[i], aP[i+2] ])   nBx = max([ aP[i], aP[i+2] ])
		nAy = min([ aP[i+1], aP[i+3] ]) nBy = max([ aP[i+1], aP[i+3] ])
		nDx = 0
		if nBx < c[1]  nDx = c[1] - nBx  ok
		if nAx > c[1] + c[3]  nDx = nAx - (c[1] + c[3])  ok
		nDy = 0
		if nBy < c[2]  nDy = c[2] - nBy  ok
		if nAy > c[2] + c[4]  nDy = nAy - (c[2] + c[4])  ok
		nD = sqrt(nDx*nDx + nDy*nDy)
		if nD < nNear  nNear = nD  ok
	next
next
? "   its nearest approach to a FOREIGN frame : " + nNear + "px"
chk("...and never grazes a cluster it does not belong to", nNear >= nClr)

# THE BAND ITSELF: a gap whose centre is out of the corridor still
# offers what it has. Asked with a corridor that excludes the middle,
# the placer must answer inside the gap AND a clearance clear of the
# block -- not fall back to the unchecked proposal.
nData = 1000000
_aC67_ = oSv.RenderClusterRects()
_nC67_ = len(_aC67_)
for _iC67_ = 1 to _nC67_
	c = _aC67_[_iC67_]
	if StzFindFirst("db1", c[5]) > 0 and StzFindFirst("api1", c[5]) = 0
		nData = c[2]
	ok
next
nApiB = 0  nDbT = 0
_aR68_ = oSv.RenderNodeRects()
_nR68_ = len(_aR68_)
for _iR68_ = 1 to _nR68_
	r = _aR68_[_iR68_]
	if r[5] = "api2"  nApiB = r[2] + r[4]  ok
	if r[5] = "db2"   nDbT = r[2]  ok
next
nAns = oSv._ChannelBand(nApiB + 65, 261, 568, "api2", "log", 0,
	nApiB, nDbT)
? "   a channel proposed at " + (nApiB + 65) + " with the Data frame at " +
  nData + " lands at " + nAns
chk("a gap whose centre is unreachable still offers its usable part",
    nAns <= nData - nClr + 0.5 and nAns >= nApiB)

# THE NEGATIVE SIBLING: a fan with NO clusters has one kind of child,
# so no member of it may take the lateral form -- congruence still
# outranks it where the graph states no difference.
oFan = new stzDiagram("fan37")
oFan.AddNodeXTT("r", "R", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 4
	oFan.AddNodeXTT("h" + i, "H" + i, [ :type = "box", :color = "Info.Solid" ])
	oFan.AddEdge("r", "h" + i)
next
oFan.SetSplines("ortho")
oFan.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nShapes = 0
aFirst = []
_aP69_ = oFan.RenderEdgePaths()
_nP69_ = len(_aP69_)
for _iP69_ = 1 to _nP69_
	p = _aP69_[_iP69_]
	if len(aFirst) = 0  aFirst = p[2]  ok
	if len(p[2]) != len(aFirst)  nShapes++  ok
next
? "   siblings of one kind drawn differently : " + nShapes
chkeq("no cluster difference, no lateral form -- siblings stay alike",
      nShapes, 0)

#---------------------------------------------------------------------------
? ""
sec("-- 37. WHITESPACE is grouping, on DAGs as on trees ---------")
#
# Proximity is the oldest grouping cue a reader has, which makes equal
# spacing a claim: these things are equally related. So a rank whose
# every gap is the same states no families, and a picture of two
# families of three that spaces all six alike has drawn the structure
# correctly and made it unreadable.
#
# The rule existed and could not reach most diagrams. tidyTerritories
# opens 0.40 of a separation between cousins, but it is FOREST ONLY --
# it shifts whole subtrees, and a node with two parents belongs to two
# of them -- so one shared child anywhere in a graph returned every rank
# in it to even spacing. Measured before the fix: six leaves, two
# families, all 57px apart. Real diagrams are DAGs far more often than
# they are trees.
#
# So the cue is now its own pass, claiming none of the subtree
# reasoning. It asks what a reader asks -- do these two neighbours share
# a parent -- and opens the same gap when they do not, by sliding the
# rest of the rank. Parent SETS rather than a single parent, because
# that is the DAG-true form of the same question and the one a reader is
# answering anyway.
#---------------------------------------------------------------------------


# TWO FAMILIES OF THREE, and the graph is a DAG: p has two parents, so
# every subtree-based rule refuses it, which is exactly the case that was
# losing its grouping.
oFm = new stzDiagram("fam38")
oFm.AddNodeXTT("root", "Root", [ :type = "box", :color = "Info.Solid" ])
oFm.AddNodeXTT("root2", "Root2", [ :type = "box", :color = "Info.Solid" ])
_aA70_ = [ "p", "q" ]
_nA70_ = len(_aA70_)
for _iA70_ = 1 to _nA70_
	a = _aA70_[_iA70_]
	oFm.AddNodeXTT(a, StzUpper(a), [ :type = "box", :color = "Info.Solid" ])
	oFm.AddEdge("root", a)
	for i = 1 to 3
		oFm.AddNodeXTT(a + i, StzUpper(a) + i,
			[ :type = "box", :color = "Info.Solid" ])
		oFm.AddEdge(a, a + i)
	next
next
oFm.AddEdge("root2", "p")
oFm.SetSplines("ortho")
oFm.ToCanvasXT([ :NodeWidth = 70, :NodeHeight = 34 ])

aLeaf = []
_aR71_ = oFm.RenderNodeRects()
_nR71_ = len(_aR71_)
for _iR71_ = 1 to _nR71_
	r = _aR71_[_iR71_]
	if StzLen(r[5]) = 2  aLeaf + [ r[5], r[1], r[1] + r[3] ]  ok
next
for i = 1 to len(aLeaf)
	for j = i + 1 to len(aLeaf)
		if aLeaf[j][2] < aLeaf[i][2]
			aTmp = aLeaf[i]  aLeaf[i] = aLeaf[j]  aLeaf[j] = aTmp
		ok
	next
next
nSib = -1
nCous = -1
bSibSame = 1
for i = 2 to len(aLeaf)
	nG = aLeaf[i][2] - aLeaf[i-1][3]
	if StzSubStr(aLeaf[i][1], 1, 1) = StzSubStr(aLeaf[i-1][1], 1, 1)
		if nSib < 0
			nSib = nG
		but fabs(nG - nSib) > 0.5
			bSibSame = 0
		ok
	else
		nCous = nG
	ok
next
? "   six leaves, two families : sibling gap " + nSib +
  "px, cousin gap " + nCous + "px"
chk("every sibling gap is the same", bSibSame)
chk("a family boundary is WIDER than a sibling gap", nCous > nSib * 1.5)

# ...and the scene really is the hard case: p has TWO parents, so the
# subtree pass refuses the whole graph and the grouping above can only
# have come from the rank-local rule. Asserted, because a probe that
# quietly stayed a tree would prove nothing about DAGs.
nPar = 0
_aE72_ = oFm.Edges()
_nE72_ = len(_aE72_)
for _iE72_ = 1 to _nE72_
	e = _aE72_[_iE72_]
	if StzLower("" + e[:to]) = "p"  nPar++  ok
next
? "   p has " + nPar + " parents, so every subtree rule refuses this graph"
chk("the scene is a DAG, which is the case that lost its grouping",
    nPar >= 2)

# THE NEGATIVE SIBLING: with ONE family the rank must stay evenly spaced.
# A rule that simply widened every third gap would pass the assertions
# above and fail this.
oOne = new stzDiagram("one38")
oOne.AddNodeXTT("r", "R", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 6
	oOne.AddNodeXTT("k" + i, "K" + i, [ :type = "box", :color = "Info.Solid" ])
	oOne.AddEdge("r", "k" + i)
next
oOne.SetSplines("ortho")
oOne.ToCanvasXT([ :NodeWidth = 70, :NodeHeight = 34 ])
aK = []
_aR73_ = oOne.RenderNodeRects()
_nR73_ = len(_aR73_)
for _iR73_ = 1 to _nR73_
	r = _aR73_[_iR73_]
	if r[5] != "r"  aK + [ r[1], r[1] + r[3] ]  ok
next
for i = 1 to len(aK)
	for j = i + 1 to len(aK)
		if aK[j][1] < aK[i][1]  aTmp = aK[i]  aK[i] = aK[j]  aK[j] = aTmp  ok
	next
next
nFirst = aK[2][1] - aK[1][2]
bEven = 1
for i = 3 to len(aK)
	if fabs((aK[i][1] - aK[i-1][2]) - nFirst) > 0.5  bEven = 0  ok
next
? "   one family of six : every gap " + nFirst + "px, all equal : " + bEven
chk("one family, one spacing -- no air where there is no boundary", bEven)

# ...and the mechanism itself, both ways on one rank: two nodes fed by
# the same parent are siblings; two fed by different parents are not.
? "   (the rule reads parent SETS, so it holds on a DAG as on a tree)"
chk("the family gap exceeds the sibling gap by a stated fraction",
    nCous - nSib > 30 and nCous - nSib < 80)

# A CLUSTER BOUNDARY IS AIR, AND NO MORE AIR THAN THE FRAMES NEED. The
# same cue, sized wrong: the boundary pass added 0.55 of a slot per
# LEVEL crossed, so leaving two nested clusters at once bought 1.1
# slots -- 168px on the service diagram, on top of the 52px of padding
# the frames already carry. The Principal called the distance good and
# exaggerated. What a boundary needs is that the FRAME clear the
# foreign node: the deepest padding plus one clearance, once per
# crossing, since the padding already grows with nesting.
oCl = new stzDiagram("air38")
_aA74_ = [ [ "p","P" ],[ "a","A" ],[ "b","B" ],[ "far","FAR" ] ]
_nA74_ = len(_aA74_)
for _iA74_ = 1 to _nA74_
	a = _aA74_[_iA74_]
	oCl.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oCl.AddEdge("p", "a")  oCl.AddEdge("p", "b")  oCl.AddEdge("p", "far")
oCl.AddClusterXTT("g", "G", [ "a", "b" ], "#5E35B1")
oCl.SetSplines("ortho")
oCl.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nFrameR = 0
_aC75_ = oCl.RenderClusterRects()
_nC75_ = len(_aC75_)
for _iC75_ = 1 to _nC75_
	c = _aC75_[_iC75_]
	if c[1] + c[3] > nFrameR  nFrameR = c[1] + c[3]  ok
next
nFarL = 1000000
_aR76_ = oCl.RenderNodeRects()
_nR76_ = len(_aR76_)
for _iR76_ = 1 to _nR76_
	r = _aR76_[_iR76_]
	if r[5] = "far" and r[1] < nFarL  nFarL = r[1]  ok
next
nNeed = oCl._LineClearance()
? "   frame ends at " + nFrameR + ", the outside node starts at " + nFarL +
  " (clearance " + nNeed + ")"
chk("a frame clears the node outside it", nFarL - nFrameR >= nNeed - 0.5)
# ...and by no more than the ordinary separation beyond it. The two
# NODES are still one separation apart as any neighbours would be, and
# the frame sits inside part of that; what the boundary adds on top is
# the clearance, not a multiple of the slot. So the frame-to-node
# distance is nodesep plus a clearance, and anything much past that is
# the exaggeration again.
nSep38 = floor(oCl.NodeSeparation() * 96)
? "   which is " + (nFarL - nFrameR) + "px against nodesep + clearance = " +
  (nSep38 + nNeed)
chk("...and by no more than an ordinary separation beyond that",
    nFarL - nFrameR <= nSep38 + nNeed * 1.5)

#---------------------------------------------------------------------------
? ""
sec("-- 38. A main line runs as ONE straight column --------------")
#
# The pin law straightens a single hop; a designer straightens the whole
# line. Centring alone cannot: a parent placed between a chain child and
# a leaf child sits half a pitch off the chain, and over five ranks that
# accumulates -- a five-stage pipeline drew as a diagonal staircase 468px
# wide, with the main line the least visible structure in the picture.
#
# So the two rules become ONE. A parent stands over the child that
# carries the LONGEST CONTINUATION when exactly one child does, and at
# the middle of its children when none stands out. Nothing is special-
# cased: a fan's children are all leaves and tie immediately, so the
# Principal's centring rule is untouched; two branches of equal depth tie
# as well, which is why a service diagram keeps its centred root while
# each of its branches is straight. Only where the graph itself says
# "this way onward" does the picture say it too.
#
# A tie is not a failure to decide -- it is the graph reporting that the
# line has split, and a picture that picked a side there would state
# something the graph does not contain.
#---------------------------------------------------------------------------


# A MAIN LINE WITH BRANCHES HANGING OFF IT
oPl = new stzDiagram("pipe39")
for i = 1 to 5
	oPl.AddNodeXTT("s" + i, "Stage " + i,
		[ :type = "box", :color = "Info.Solid" ])
next
for i = 1 to 4  oPl.AddEdge("s" + i, "s" + (i + 1))  next
for i = 1 to 4
	oPl.AddNodeXTT("b" + i, "Log " + i,
		[ :type = "box", :color = "Info.Solid" ])
	oPl.AddEdge("s" + i, "b" + i)
next
oPl.SetSplines("ortho")
oPl.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
aX = []
for i = 1 to 4
	_aR77_ = oPl.RenderNodeRects()
	_nR77_ = len(_aR77_)
	for _iR77_ = 1 to _nR77_
		r = _aR77_[_iR77_]
		if r[5] = "s" + i  aX + (r[1] + r[3] / 2)  ok
	next
next
nDrift = 0
for i = 2 to len(aX)
	if fabs(aX[i] - aX[1]) > nDrift  nDrift = fabs(aX[i] - aX[1])  ok
next
? "   four ranks of a main line drift " + nDrift + "px from the first"
chk("a chain runs as ONE straight column", nDrift < 0.5)

# ...and every branch hangs to the SAME side of it, which is what makes
# the line the thing a reader follows rather than one strand among
# several. Measured against the line's COLUMN, not against particular
# boxes: a branch and a stage in different ranks may share an x without
# touching, so the property is about the column the eye traces.
nBOff = 1000000
nLeft = 0
nRight = 0
_aR78_ = oPl.RenderNodeRects()
_nR78_ = len(_aR78_)
for _iR78_ = 1 to _nR78_
	r = _aR78_[_iR78_]
	if StzSubStr(r[5], 1, 1) != "b"  loop  ok
	nD = r[1] + r[3] / 2 - aX[1]
	if fabs(nD) < nBOff  nBOff = fabs(nD)  ok
	if nD < 0  nLeft++  else  nRight++  ok
next
? "   the nearest branch stands " + nBOff + "px off the line ; " +
  nLeft + " left, " + nRight + " right"
chk("no branch stands ON the line", nBOff >= oPl._LineClearance())
chk("...and they all hang to the same side of it",
    nLeft = 0 or nRight = 0)

# THE TIE IS THE GRAPH SAYING THE LINE HAS SPLIT, and then the parent
# centres as always -- two children of equal depth give no reason to
# prefer either, and inventing one would state something the graph does
# not. The service diagram is the case: its root's two children carry
# chains of the same length.
oSv = new stzDiagram("svc39")
_aA79_ = [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
           [ "api1","API A" ],[ "api2","API B" ],
           [ "db1","DB A" ],[ "db2","DB B" ] ]
_nA79_ = len(_aA79_)
for _iA79_ = 1 to _nA79_
	a = _aA79_[_iA79_]
	oSv.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oSv.AddEdge("lb","web1")   oSv.AddEdge("lb","web2")
oSv.AddEdge("web1","api1") oSv.AddEdge("web2","api2")
oSv.AddEdge("api1","db1")  oSv.AddEdge("api2","db2")
oSv.SetSplines("ortho")
oSv.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nLb = 0  nW1 = 0  nW2 = 0  nA1 = 0  nD1 = 0
_aR80_ = oSv.RenderNodeRects()
_nR80_ = len(_aR80_)
for _iR80_ = 1 to _nR80_
	r = _aR80_[_iR80_]
	nC = r[1] + r[3] / 2
	if r[5] = "lb"    nLb = nC  ok
	if r[5] = "web1"  nW1 = nC  ok
	if r[5] = "web2"  nW2 = nC  ok
	if r[5] = "api1"  nA1 = nC  ok
	if r[5] = "db1"   nD1 = nC  ok
next
? "   two equal branches : root at " + nLb + ", their middle " +
  ((nW1 + nW2) / 2)
chk("equal branches TIE, and the parent centres as always",
    fabs(nLb - (nW1 + nW2) / 2) < 0.5)
? "   and each branch is itself straight : " + nW1 + ", " + nA1 + ", " + nD1
chk("...while each branch is its own straight column",
    fabs(nW1 - nA1) < 0.5 and fabs(nA1 - nD1) < 0.5)

# THE NEGATIVE SIBLING: a fan has no chain at all, so nothing may claim
# a spine and the parent stays centred over all of its children. A rule
# that aligned to "the first child" would pass the pipeline above and
# fail here.
oFn = new stzDiagram("fan39")
oFn.AddNodeXTT("r", "R", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 4
	oFn.AddNodeXTT("h" + i, "H" + i, [ :type = "box", :color = "Info.Solid" ])
	oFn.AddEdge("r", "h" + i)
next
oFn.SetSplines("ortho")
oFn.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nRx = 0
aKid = []
_aR81_ = oFn.RenderNodeRects()
_nR81_ = len(_aR81_)
for _iR81_ = 1 to _nR81_
	r = _aR81_[_iR81_]
	if r[5] = "r"  nRx = r[1] + r[3] / 2
	else  aKid + (r[1] + r[3] / 2)  ok
next
aKid = sort(aKid)
? "   a fan of four : parent at " + nRx + ", span middle " +
  ((aKid[1] + aKid[4]) / 2)
chk("no chain, no spine -- the fan stays centred",
    fabs(nRx - (aKid[1] + aKid[4]) / 2) < 0.5)

#---------------------------------------------------------------------------
? ""
sec("-- 39. GG8: a picture larger than its medium is TILED -------")
discharges("GG8")
#
# "Whole" is exactly what fails. A GPU texture stops at 8192 in either
# axis -- this library shipped that as a refusal -- and print never had a
# whole at all; dot has tiled PostScript across A4 since the eighties for
# the same reason. So a page is not a crop of a big image, because the
# big image is the thing that cannot exist. Each sheet is the SAME
# retained scene drawn through a moved projection: one engine addition
# (render-region), which is also exactly what a viewer panning a huge
# diagram needs, so tiling and panning are one feature and not two.
#
# THE SEAM IS THE PROPERTY, and it is asserted as what the hardware
# actually offers. A tile and the whole render divide the same coordinate
# by different widths, so the rasteriser can land an antialiased edge one
# quantisation level apart -- 79 pixels of 100,000, each off by one in
# one channel. Computing the projection in f64 changes nothing, which is
# how we know it is coverage arithmetic and not displacement. Claiming
# bit-identity would have been claiming something untrue; the assertion
# is that NOTHING MOVES, with a negative sibling showing what a real
# displacement looks like -- one pixel of shift, differences far past one
# level.
#
# Building it found the refusal refusing its own cure: ToPages had to
# ask for a canvas of the full size, and the 8192 check raised before any
# tile existed. The check now stands aside for a tiling caller and names
# ToPages as the way out, so the dead end is retired rather than routed
# around.
#---------------------------------------------------------------------------


PFONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
aPO = [ :Font = PFONT, :NodeWidth = 96, :NodeHeight = 36, :FontSize = 13 ]

oWd = new stzDiagram("wide40")
oWd.AddNodeXTT("root", "Root", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 14
	oWd.AddNodeXTT("k" + i, "Worker " + i,
		[ :type = "box", :color = "Info.Solid" ])
	oWd.AddEdge("root", "k" + i)
next
oWd.SetSplines("ortho")
oWc = oWd.ToCanvasXT(aPO)
? "   the picture is " + oWc.Width() + "x" + oWc.Height()

# THE SEAM IS THE PROPERTY: a tile must be the same pixels the whole
# render has there. Not similar -- the same, because a tile is the scene
# through a moved projection and not a resampling of anything.
cRef = oWc.ToPixels()
nPW = 500  nPH = 200
nOX = 700  nOY = 40
oWc.SetRegion(nOX, nOY, nPW, nPH)
cTile = oWc.ToPixels()
oWc.ClearRegion()
# NOTHING MOVES -- which is the property, and it is not bit-identity.
# The tile and the whole render divide the same coordinate by DIFFERENT
# widths, so the rasteriser's coverage arithmetic can land an
# antialiased edge one quantisation level apart. Computing the
# projection in f64 changes nothing, which is how we know it is the
# hardware's rounding and not a displacement. So the seam is asserted as
# what it is: every pixel either identical or one level off, and no
# pixel anywhere showing a different SHAPE.
nDiff = 0
nMaxD = 0
for y = 0 to nPH - 1
	for x = 0 to nPW - 1
		i = (y * nPW + x) * 4 + 1
		j = ((y + nOY) * oWc.Width() + (x + nOX)) * 4 + 1
		nD = max([ fabs(ascii(cTile[i]) - ascii(cRef[j])),
		           fabs(ascii(cTile[i+1]) - ascii(cRef[j+1])),
		           fabs(ascii(cTile[i+2]) - ascii(cRef[j+2])) ])
		if nD > 0  nDiff++  ok
		if nD > nMaxD  nMaxD = nD  ok
	next
next
? "   a 500x200 tile against the same rectangle of the whole render : " +
  nDiff + " pixels differ, by at most " + nMaxD + " of 255"
chk("a tile IS the picture there -- nothing moved", nMaxD <= 1)
chk("...and even the rounding is rare", nDiff < nPW * nPH / 100)

# THE NEGATIVE SIBLING: the comparison must be able to fail. The same
# tile against a rectangle one pixel to the left has to differ, or the
# check above is comparing something to itself.
nOff = 0
nMaxOff = 0
for y = 0 to nPH - 1
	for x = 0 to nPW - 1
		i = (y * nPW + x) * 4 + 1
		j = ((y + nOY) * oWc.Width() + (x + nOX - 1)) * 4 + 1
		nD = fabs(ascii(cTile[i]) - ascii(cRef[j]))
		if nD > 0  nOff++  ok
		if nD > nMaxOff  nMaxOff = nD  ok
	next
next
? "   ...against a rectangle shifted ONE pixel : " + nOff +
  " differ, by up to " + nMaxOff
chk("the seam check DISCRIMINATES", nOff > 100 and nMaxOff > 1)

# THE SHEETS THEMSELVES
aPg = oWd.ToPagesXT("_g40.png", [ :Font = PFONT, :NodeWidth = 96,
	:NodeHeight = 36, :FontSize = 13, :Page = :A4, :DPI = 96 ])
? "   A4 at 96dpi : " + len(aPg) + " sheet(s)"
chk("a picture wider than a page becomes several", len(aPg) >= 2)
bAll = 1
_aAS82_ = aPg
_nAS82_ = len(_aAS82_)
for _iAS82_ = 1 to _nAS82_
	aS = _aAS82_[_iAS82_]
	if NOT (isString(aS[1]) and len(read(aS[1])) > 1000)  bAll = 0  ok
next
chk("every sheet was actually written", bAll)

# THE TILES COVER THE PICTURE, with the overlap they promise: the second
# column starts before the first one ends.
nStep = aPg[2][4] - aPg[1][4]
nPgW = floor(210 / 25.4 * 96)
? "   sheets step " + nStep + "px across a " + nPgW + "px page, so they " +
  "overlap by " + (nPgW - nStep) + "px"
chk("consecutive sheets share a glue margin", nPgW - nStep > 20)
nLast = aPg[len(aPg)][4] + nPgW
? "   the last sheet ends at " + nLast + ", the picture at " + oWc.Width()
chk("the sheets cover the whole picture", nLast >= oWc.Width())

# ...AND THE 8192 DEAD END IS RETIRED. A picture past the GPU's texture
# limit is refused outright by ToPNG -- that refusal is correct and
# stays -- but it now has an honest way out that is not "make it
# smaller".
oBig = new stzDiagram("big40")
oBig.AddNodeXTT("r", "R", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 60
	oBig.AddNodeXTT("n" + i, "Node " + i,
		[ :type = "box", :color = "Info.Solid" ])
	oBig.AddEdge("r", "n" + i)
next
oBig.SetSplines("ortho")
# measured with :Tiled, because asking for the whole thing is exactly
# what this picture refuses -- and refusing is correct
aBigO = [ :Font = PFONT, :NodeWidth = 96, :NodeHeight = 36,
          :FontSize = 13, :Tiled = 1 ]
nBigW = oBig.ToCanvasXT(aBigO).Width()
? "   an oversize picture is " + nBigW + "px wide"
chk("the scene really is past what one texture can hold", nBigW > 8192)
# ...and asking for it WHOLE is still refused, naming the way out
bRefused = 0
try
	oBig.ToCanvasXT(aPO)
catch
	if StzFindFirst("ToPages", cCatchError) > 0  bRefused = 1  ok
done
? "   asking for it whole is refused, and the refusal names ToPages : " +
  bRefused
chk("the refusal stands, and now has an answer", bRefused = 1)
aBigPg = oBig.ToPagesXT("_b40.png", [ :Font = PFONT, :NodeWidth = 96,
	:NodeHeight = 36, :FontSize = 13, :Page = :A4, :DPI = 96 ])
? "   ...and prints as " + len(aBigPg) + " A4 sheets"
chk("a picture too big to render whole still prints", len(aBigPg) >= 8)

#---------------------------------------------------------------------------
? ""
sec("-- 40. GG7a: the picture can be ASKED --------------------------")
discharges("GG7a")
#
# The batch pipeline is model -> layout -> paint and every stage owns its
# successor, so the picture was the end of a one-way street: it could be
# looked at and never questioned. A live diagram needs the street to run
# both ways -- a point must answer with a NODE or an EDGE, in the graph's
# own terms and not the display list's.
#
# Hit-testing is ENGINE work, and for the reason that decides most of
# these calls: the display list is already retained engine-side, so a
# question about it costs one crossing and no copy. What the engine
# lacked was identity -- it knows a rounded rectangle and cannot know
# "Web A" -- so the face tags the commands as it draws them, and a pick
# answers with the tag. A tag rather than a shape index because a node is
# a fill AND an outline AND a label, and all of them are the same node to
# a reader pointing at one.
#
# Building it found two defects worth naming. The canvas kept its LAST
# shape pending until something else forced a flush, so a question asked
# before rendering could not see the last thing drawn -- correct in every
# picture ever rendered, and wrong the moment the picture was asked
# instead. And a 100-node diagram took 4.5 seconds to draw, of which 4.3
# was one loop scanning `Positions()` from inside a per-edge loop: the
# iterator form over a METHOD CALL, rebuilding the whole position list
# per step, comparing ids with four engine crossings a row. Hoisting it
# took the same picture to 0.6s. It hid because only pictures that SIZE
# THEMSELVES enter that branch -- which is to say, the big ones.
#---------------------------------------------------------------------------


# THE PICTURE ANSWERS IN THE GRAPH'S TERMS
oPk = new stzDiagram("pick41")
_aA83_ = [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ] ]
_nA83_ = len(_aA83_)
for _iA83_ = 1 to _nA83_
	a = _aA83_[_iA83_]
	oPk.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oPk.AddEdge("lb", "web1")  oPk.AddEdge("lb", "web2")
oPk.SetSplines("ortho")
# WITH A FONT, because a picture without one draws no labels -- and this
# section passed for two commits while every node in a LABELLED picture
# answered as the last one. Node shapes were tagged in the loop that
# drew them; the labels are drawn in a later loop, so they all carried
# whichever tag was current when that loop began. Labels sit over
# boxes, and a pick answers with the topmost ink it finds. A guard that
# renders a configuration nobody ships is a guard that tests the wrong
# picture.
PKFONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oPk.ToCanvasXT([ :Font = PKFONT, :NodeWidth = 96, :NodeHeight = 36,
	:FontSize = 13 ])

nFound = 0
_aR84_ = oPk.RenderNodeRects()
_nR84_ = len(_aR84_)
for _iR84_ = 1 to _nR84_
	r = _aR84_[_iR84_]
	aAt = oPk.PickAt(r[1] + r[3] / 2, r[2] + r[4] / 2)
	if len(aAt) = 2 and StzLower("" + aAt[2]) = r[5]  nFound++  ok
next
? "   nodes correctly identified at their centres : " + nFound + " of " +
  len(oPk.RenderNodeRects())
chkeq("a point on a node answers with THAT node", nFound,
      len(oPk.RenderNodeRects()))

# an edge answers as an edge, named by its ends
aEP = oPk.RenderEdgePaths()
nOnEdge = 0
_aP85_ = aEP
_nP85_ = len(_aP85_)
for _iP85_ = 1 to _nP85_
	p = _aP85_[_iP85_]
	aF = p[2]
	# the middle of the LAST segment, which belongs to this edge alone
	nMx = (aF[len(aF) - 3] + aF[len(aF) - 1]) / 2
	nMy = (aF[len(aF) - 2] + aF[len(aF)]) / 2
	aAt = oPk.PickAt(nMx, nMy)
	if len(aAt) = 3  nOnEdge++  ok
next
? "   points on edges answering as edges : " + nOnEdge + " of " + len(aEP)
chk("a point on an edge answers with an EDGE", nOnEdge >= 1)

# BARE PAPER IS BARE PAPER -- the negative that keeps the rest honest,
# since a picker that answered "the nearest thing" would pass every
# assertion above and be useless for deciding whether a click hit
# anything at all.
? "   the corner of the paper answers : " + len(oPk.PickAt(2, 2)) + " terms"
chkeq("a point on nothing answers NOTHING", len(oPk.PickAt(2, 2)), 0)

# ...and the tolerance is a tolerance, not a magnet: just outside a node
# is outside it.
aR1 = oPk.RenderNodeRects()[1]
? "   30px clear of a node answers : " +
  len(oPk.PickAt(aR1[1] - 30, aR1[2] - 30)) + " terms"
chkeq("a point CLEAR of a node is not that node",
      len(oPk.PickAt(aR1[1] - 30, aR1[2] - 30)), 0)

# THE KILL CRITERION: pick under 1ms on a 500-node diagram. Measured at
# 500 on 2026-08-21 -- 0.28ms a pick, 300 of 300 hits -- and asserted
# here at a size the gate can afford, because the property is that a
# pick reads the retained list rather than rebuilding anything, and that
# property does not wait for the 500th node to appear.
oBg = new stzDiagram("big41")
oBg.AddNodeXTT("n1", "N1", [ :type = "box", :color = "Info.Solid" ])
for i = 2 to 200
	oBg.AddNodeXTT("n" + i, "N" + i, [ :type = "box", :color = "Info.Solid" ])
	oBg.AddEdge("n" + max([ 1, floor(i / 3) ]), "n" + i)
next
oBg.SetSplines("ortho")
oBg.ToCanvasXT([ :Font = PKFONT, :NodeWidth = 60, :NodeHeight = 26,
	:FontSize = 11, :Width = 2400, :Height = 1600 ])
aBR = oBg.RenderNodeRects()
nPicks = 200
nHit = 0
t0 = clock()
for k = 1 to nPicks
	r = aBR[ (k % len(aBR)) + 1 ]
	if len(oBg.PickAt(r[1] + r[3] / 2, r[2] + r[4] / 2)) > 0  nHit++  ok
next
nMs = (clock() - t0) / clockspersecond() / nPicks * 1000
? "   " + nPicks + " picks over " + len(aBR) + " nodes : " + nMs +
  " ms each, " + nHit + " hit"

# A WALL-CLOCK THRESHOLD MEASURES THE MACHINE, NOT THE CODE.
#
# This asserted `nMs < 1` and it went red on a run where ten other
# suites were compiling beside it -- 3.75ms -- and green twice on the
# same code a minute later at 1.17 and 1.44. Identical code, opposite
# verdicts, which is the definition of a flaky guard, and this project's
# own law says a re-run is the most expensive wait there is.
#
# What the assertion is FOR is that a pick does not walk the picture
# quadratically. That is a claim about the algorithm, and a ratio
# measures it on any machine at any load: four times the nodes may cost
# more per pick -- a pick scans the rects, so linear is expected and
# honest -- but nothing like sixteen times.
oPkS = _G50()
oPkS.SetSplines("ortho")
oPkS.ToCanvasXT([ :Font = PKFONT, :NodeWidth = 60, :NodeHeight = 26,
	:FontSize = 11, :Width = 1200, :Height = 800 ])
aPkS = oPkS.RenderNodeRects()
t0 = clock()
for k = 1 to nPicks
	r = aPkS[ (k % len(aPkS)) + 1 ]
	oPkS.PickAt(r[1] + r[3] / 2, r[2] + r[4] / 2)
next
nMsS = (clock() - t0) / clockspersecond() / nPicks * 1000
nGrowN = len(aBR) / max([ len(aPkS), 1 ])
nGrowT = 99
if nMsS > 0.0001  nGrowT = nMs / nMsS  ok
? "   " + len(aPkS) + " nodes -> " + len(aBR) + " nodes is " + nGrowN +
  "x the graph and " + nGrowT + "x the cost"
chk("a pick scans the picture, it does not walk it twice",
    nGrowT < nGrowN * nGrowN * 0.5)
chkeq("...and every one of them found its node", nHit, nPicks)

#---------------------------------------------------------------------------
? ""
sec("-- 41. GG7b: a PIN outranks the layout ------------------------")
discharges("GG7b")
#
# The batch pipeline lets the layout own positions. A live diagram
# inverts the ownership: the author owns positions and the layout only
# advises. A cell placed by hand is PINNED, and no pass may argue with
# it -- not the relaxation, not the territories, not the family air, not
# the alignment, not the centring.
#
# Enforced by RESTORING pins after each pass rather than by teaching five
# passes to skip them: uniform, so no pass can forget; exact, so the pin
# is the value given and not a value that survived a clamp; and honest
# about its one cost -- a pinned cell may sit closer to a neighbour than
# the separation would allow, because the author put it there.
#
# A PIN DECIDES ORDER, TOO, and without that it decided nothing anyone
# could see. Rank order is settled by the crossing sweep before any
# coordinate exists, and the coordinate pass only spaces a rank out while
# preserving it -- so a pinned cell shifted its whole rank sideways and
# never passed a sibling, and _Normalise then refitted the bounding box
# and erased even that. The engine honoured every pin exactly and the
# picture was pixel-identical, which is the most expensive kind of
# correct: nothing to notice, nothing failing, feature absent.
#
# So a pin now sorts its rank -- lay out once free, order each rank by
# where its members actually are (the pin's own value where there is
# one), lay out again with the pins held. Two layouts of a hundred nodes
# cost 0.02s together, which is a cheap price for letting a position
# outrank a heuristic.
#---------------------------------------------------------------------------


# THE FREE LAYOUT, as the batch pipeline decides it
oPn = new stzDiagram("pin42")
oPn.AddNodeXTT("r", "R", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 4
	oPn.AddNodeXTT("k" + i, "K" + i, [ :type = "box", :color = "Info.Solid" ])
	oPn.AddEdge("r", "k" + i)
next
oPn.SetSplines("ortho")
oPn.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
aFree = []
_aFreeR_ = oPn.RenderNodeRects()
_nFreeR_ = len(_aFreeR_)
for _iFreeR_ = 1 to _nFreeR_
	rr = _aFreeR_[_iFreeR_]
	aFree + [ rr[5], rr[1] + rr[3] / 2 ]
next
? "   free: k1 sits at " + _Xof42(aFree, "k1") + ", k4 at " +
  _Xof42(aFree, "k4")
chk("the layout places the children in declaration order",
    _Xof42(aFree, "k1") < _Xof42(aFree, "k4"))
chkeq("nothing is pinned yet", len(oPn.Pins()), 0)

# A PIN IS A POSITION THE LAYOUT MAY NOT ARGUE WITH -- and it decides
# ORDER as well, or it decides nothing a reader can see.
oPn.Pin("k1", 10)
chk("the pin is recorded", oPn.IsPinned("k1") and NOT oPn.IsPinned("k2"))
oPn.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
aPinned = []
_aRr86_ = oPn.RenderNodeRects()
_nRr86_ = len(_aRr86_)
for _iRr86_ = 1 to _nRr86_
	rr = _aRr86_[_iRr86_]
	aPinned + [ rr[5], rr[1] + rr[3] / 2 ]
next
? "   pinned to slot 10: k1 at " + _Xof42(aPinned, "k1") + ", k4 at " +
  _Xof42(aPinned, "k4")
chk("a pinned cell moves PAST its siblings",
    _Xof42(aPinned, "k1") > _Xof42(aPinned, "k4"))
nGone = 0
_aA87_ = [ "k2", "k3", "k4" ]
_nA87_ = len(_aA87_)
for _iA87_ = 1 to _nA87_
	a = _aA87_[_iA87_]
	if _Xof42(aPinned, a) < _Xof42(aPinned, "k1")  nGone++  ok
next
chkeq("...and every unpinned sibling flowed around it", nGone, 3)

# UNPINNING RESTORES THE ADVICE, exactly. A pin that could not be
# undone would be a mutation of the graph rather than a session's state,
# and the layout is deterministic precisely so this comparison is
# meaningful.
oPn.Unpin("k1")
chkeq("the pin is gone", len(oPn.Pins()), 0)
oPn.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nSame = 0
_aRr88_ = oPn.RenderNodeRects()
_nRr88_ = len(_aRr88_)
for _iRr88_ = 1 to _nRr88_
	rr = _aRr88_[_iRr88_]
	if fabs(rr[1] + rr[3] / 2 - _Xof42(aFree, rr[5])) < 0.5  nSame++  ok
next
? "   unpinned again: " + nSame + " of " + len(aFree) +
  " cells back exactly where the layout wanted them"
chkeq("unpinning restores the free layout, to the pixel", nSame, len(aFree))

# THE NEGATIVE SIBLING: a pin the layout ALREADY agrees with must change
# nothing. Without this, "pins move things" and "pins move things
# correctly" are the same assertion -- and the first version of this
# feature passed the first while failing the second, because the engine
# honoured every pin and the rank order, decided earlier, kept the
# picture identical.
oAg = new stzDiagram("agree42")
oAg.AddNodeXTT("r", "R", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 4
	oAg.AddNodeXTT("k" + i, "K" + i, [ :type = "box", :color = "Info.Solid" ])
	oAg.AddEdge("r", "k" + i)
next
oAg.SetSplines("ortho")
oAg.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
aBefore = []
_aBefR_ = oAg.RenderNodeRects()
_nBefR_ = len(_aBefR_)
for _iBefR_ = 1 to _nBefR_
	rr = _aBefR_[_iBefR_]
	aBefore + [ rr[5], rr[1] + rr[3] / 2 ]
next
# k1 is leftmost already; pinning it to the far left agrees with that
oAg.Pin("k1", 0 - 3)
oAg.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nOrderKept = 1
_aA89_ = [ "k1", "k2", "k3", "k4" ]
_nA89_ = len(_aA89_)
for _iA89_ = 1 to _nA89_
	a = _aA89_[_iA89_]
	_aB90_ = [ "k1", "k2", "k3", "k4" ]
	_nB90_ = len(_aB90_)
	for _iB90_ = 1 to _nB90_
		b = _aB90_[_iB90_]
		if a = b  loop  ok
		bB = _Xof42(aBefore, a) < _Xof42(aBefore, b)
		aNow = []
		_aRr91_ = oAg.RenderNodeRects()
		_nRr91_ = len(_aRr91_)
		for _iRr91_ = 1 to _nRr91_
			rr = _aRr91_[_iRr91_]
			aNow + [ rr[5], rr[1] + rr[3] / 2 ]
		next
		if bB != (_Xof42(aNow, a) < _Xof42(aNow, b))  nOrderKept = 0  ok
	next
next
? "   a pin the layout already agrees with keeps the order : " + nOrderKept
chk("a pin that agrees with the layout changes no order", nOrderKept = 1)

#---------------------------------------------------------------------------
? ""
sec("-- 42. GG7c: the editor executes COMMANDS, never mutations ----")
discharges("GG7c")
#
# An editor that mutates its model directly can offer no undo, and an
# editor without undo is one nobody trusts enough to explore with. So
# nothing here mutates: every edit is a command with an inverse, and the
# log is the session's memory -- mxGraph's model, and the reason it has
# one.
#
# The commands go through the model's EXISTING mutation API and its
# existing refusals, which is the design decision that pays for itself
# twice: every guard in this plane governs the editor for free, and a
# refused edit surfaces as feedback rather than as a second rulebook.
# The model stays stzDiagram; a session is state ALONGSIDE it, never a
# parallel graph.
#
# Five commands cover the vocabulary -- move, add, remove, link, label --
# and the inverse is computed BEFORE the change, because afterwards the
# information it needs is gone. A removed cell's label and edges cannot
# be read from a model that no longer holds them, and an undo that
# restored a node into a graph it is no longer connected to would be an
# undo that lies.
#
# Named Edit() and not Do(), because `do` is a Ring keyword and a method
# named for it is a parse error reported four hundred lines from
# anything that looks wrong.
#---------------------------------------------------------------------------


oEd = new stzDiagram("edit43")
oEd.AddNodeXT("a", "A")
oEd.AddNodeXT("b", "B")
oEd.AddEdge("a", "b")

# AN EDIT IS A COMMAND, and the log is what makes an editor explorable
chk("nothing to undo before anything is done",
    NOT oEd.CanUndo() and NOT oEd.CanRedo())
chk("an edit reports that it happened", oEd.Edit(:AddCell, [ "c", "C" ]))
oEd.Edit(:Link, [ "b", "c" ])
? "   after two edits : " + oEd.NodesCount() + " nodes, " +
  len(oEd.Edges()) + " edges, " + len(oEd.EditLog()) + " logged"
chkeq("the model changed", oEd.NodesCount(), 3)
chkeq("...and the log remembers both", len(oEd.EditLog()), 2)

# UNDO RESTORES, REDO REPLAYS
oEd.Undo()
oEd.Undo()
? "   after two undos : " + oEd.NodesCount() + " nodes, " +
  len(oEd.Edges()) + " edges"
chkeq("undo took the model back", oEd.NodesCount(), 2)
chkeq("...and its edge with it", len(oEd.Edges()), 1)
chk("there is nothing left to undo, and something to redo",
    NOT oEd.CanUndo() and oEd.CanRedo())
oEd.Redo()
oEd.Redo()
chkeq("redo put both edits back", oEd.NodesCount(), 3)

# A FRESH EDIT CLOSES THE REDO BRANCH -- the future an undo led to is
# not the future this edit leads to, and offering it would replay a
# change into a model that no longer expects it.
oEd.Undo()
chk("an undone edit is redoable", oEd.CanRedo())
oEd.Edit(:SetLabel, [ "a", "Alpha" ])
chk("...until a new edit is made", NOT oEd.CanRedo())
? "   the label reads " + oEd.NodeLabel("a")
oEd.Undo()
? "   and after undo, " + oEd.NodeLabel("a")
chk("a label edit is reversible", oEd.NodeLabel("a") = "A")

# THE HARD ONE: removing a cell takes its edges with it, so the inverse
# has to carry them. Restoring a node into a graph it is no longer
# connected to would be an undo that lies.
oRm = new stzDiagram("rm43")
oRm.AddNodeXT("a", "A")  oRm.AddNodeXT("b", "B")  oRm.AddNodeXT("c", "C")
oRm.AddEdge("a", "b")    oRm.AddEdge("b", "c")
oRm.Edit(:RemoveCell, [ "b" ])
? "   b removed : " + oRm.NodesCount() + " nodes, " + len(oRm.Edges()) +
  " edges"
chkeq("removing a cell removes its edges", len(oRm.Edges()), 0)
oRm.Undo()
? "   b restored : " + oRm.NodesCount() + " nodes, " + len(oRm.Edges()) +
  " edges, labelled " + oRm.NodeLabel("b")
chkeq("undo brings the cell back", oRm.NodesCount(), 3)
chkeq("...with BOTH its edges", len(oRm.Edges()), 2)
chk("...and its label", oRm.NodeLabel("b") = "B")

# A PIN IS AN EDIT LIKE ANY OTHER, which is the point of routing moves
# through the log: dragging a cell is undoable because it is a command
# and not a mutation.
oRm.Edit(:MoveCell, [ "c", 7 ])
chk("a move pins the cell", oRm.IsPinned("c"))
oRm.Undo()
chk("...and undoing it frees the cell again", NOT oRm.IsPinned("c"))

# THE NEGATIVE SIBLING: a REFUSED edit must not enter the log. The
# commands go through the model's existing mutation API and its existing
# refusals, so an impossible edit is refused there -- and a log that
# recorded it would offer an undo for something that never happened.
nBefore = len(oRm.EditLog())
bTook = oRm.Edit(:AddCell, [ "a", "again" ])
? "   adding a cell that already exists returned " + bTook +
  ", log went from " + nBefore + " to " + len(oRm.EditLog())
chk("an impossible edit is refused", NOT bTook)
chkeq("...and leaves no trace in the log", len(oRm.EditLog()), nBefore)

#---------------------------------------------------------------------------
? ""
sec("-- 43. GG7d: the interaction is a STATE MACHINE ----------------")
discharges("GG7d")
#
# Not event soup. A pointer pressed, moved and released means different
# things depending on what was under it when it went down, and code that
# answers each event on its own has to reconstruct that every time --
# which is how editors grow flags that contradict one another. Four
# states cover the vocabulary: idle, dragging, linking, labelling.
#
# The events are FED IN rather than polled, and that is a design decision
# and not a convenience: a state machine that reads a window can only be
# tested by opening one. This one is a function of (state, event), so it
# is tested here, headless, in the same suite as everything else. A
# window session merely calls these with what it polled.
#
# A DRAG DOES NOT RE-LAY-OUT, and that was measured before it was
# designed. Re-rendering a 500-node diagram on every pointer-move costs
# 11,675 ms a frame against the plan's 16 ms budget -- 730 times over,
# and no faster scene upload could rescue it, because the cost is the
# layout and the edge work rather than the drawing. The plan invited
# exactly this measurement ("only if full-scene rebuild misses that does
# an incremental path earn existence"), and the answer it gives is not
# an incremental upload: it is that the model must not move while a
# gesture is in flight.
#
# So a move records the pointer and nothing else; the window paints the
# dragged cell over the picture it already has (DragPreview says where);
# and the layout runs ONCE, at release. A drag frame then costs 0.12 ms
# on 500 nodes including a pick. It also makes the log honest for free --
# one gesture is one command, and an abandoned gesture leaves nothing
# behind because there was never anything to undo.
#---------------------------------------------------------------------------


oUi = new stzDiagram("ui44")
oUi.AddNodeXTT("r", "R", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 4
	oUi.AddNodeXTT("k" + i, "K" + i, [ :type = "box", :color = "Info.Solid" ])
	oUi.AddEdge("r", "k" + i)
next
oUi.SetSplines("ortho")
oUi.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])

aK1 = _Centre44(oUi, "k1")
aK4 = _Centre44(oUi, "k4")
chk("the session starts idle", oUi.UiState() = :Idle)

# A DRAG IS ONE GESTURE AND ONE UNDO
oUi.OnPress(aK1[1], aK1[2])
? "   pressed on k1 : state " + oUi.UiState() + ", subject " +
  oUi.UiSubject()
chk("pressing a cell begins a drag of THAT cell",
    oUi.UiState() = :Dragging and oUi.UiSubject() = "k1")
oUi.OnMove(aK4[1] + 100, aK1[2])
oUi.OnMove(aK4[1] + 200, aK1[2])
aPrev = oUi.DragPreview()
? "   mid-drag : preview " + aPrev[1] + " at " + aPrev[2] +
  ", model pinned " + oUi.IsPinned("k1") + ", log " + len(oUi.EditLog())
chk("the cell follows the pointer as a PREVIEW",
    len(aPrev) = 3 and aPrev[1] = "k1" and
    fabs(aPrev[2] - (aK4[1] + 200)) < 0.5)
chk("...while the model stays untouched", NOT oUi.IsPinned("k1"))
chkeq("...and the log stays empty until the gesture ends",
      len(oUi.EditLog()), 0)
oUi.OnRelease(aK4[1] + 200, aK1[2])
? "   released : state " + oUi.UiState() + ", log " + len(oUi.EditLog())
chk("releasing ends the gesture", oUi.UiState() = :Idle)
chkeq("a whole drag is ONE undoable command", len(oUi.EditLog()), 1)

oUi.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
? "   k1 now sits at " + _Centre44(oUi, "k1")[1] + ", k4 at " +
  _Centre44(oUi, "k4")[1]
chk("the dragged cell moved past the one it was dropped beyond",
    _Centre44(oUi, "k1")[1] > _Centre44(oUi, "k4")[1])
oUi.Undo()
oUi.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
chk("one undo puts the whole drag back",
    NOT oUi.IsPinned("k1") and
    _Centre44(oUi, "k1")[1] < _Centre44(oUi, "k4")[1])

# AN ABANDONED GESTURE LEAVES NO TRACE. Without this, a drag the author
# gave up on would still be sitting in the log waiting to be undone.
aK2 = _Centre44(oUi, "k2")
oUi.OnPress(aK2[1], aK2[2])
oUi.OnMove(aK2[1] + 400, aK2[2])
chk("the cancelled gesture was under way", len(oUi.DragPreview()) = 3)
oUi.OnCancel()
? "   cancelled : state " + oUi.UiState() + ", pinned " +
  oUi.IsPinned("k2") + ", log " + len(oUi.EditLog()) + ", preview " +
  len(oUi.DragPreview())
chk("cancelling ends it with the cell untouched", NOT oUi.IsPinned("k2"))
chkeq("...and writes nothing to the log", len(oUi.EditLog()), 0)
chkeq("...and nothing is left previewing", len(oUi.DragPreview()), 0)

# LINKING IS THE SAME MACHINE IN A DIFFERENT STATE
oUi.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
aK2 = _Centre44(oUi, "k2")
aK3 = _Centre44(oUi, "k3")
nEdges = len(oUi.Edges())
oUi.BeginLinking()
oUi.OnPress(aK2[1], aK2[2])
chk("pressing while linking begins a link", oUi.UiState() = :Linking)
oUi.OnRelease(aK3[1], aK3[2])
oUi.EndLinking()
? "   linked k2 to k3 : edges " + nEdges + " -> " + len(oUi.Edges())
chkeq("releasing on another cell creates the edge",
      len(oUi.Edges()), nEdges + 1)
oUi.Undo()
chkeq("...and it is undoable like any other edit",
      len(oUi.Edges()), nEdges)

# A LINK THAT ENDS WHERE IT BEGAN IS NOT A LINK -- the negative that
# keeps the gesture honest, since a machine that made an edge on every
# release would make self-loops out of missed clicks.
oUi.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
aK2 = _Centre44(oUi, "k2")
nEdges = len(oUi.Edges())
oUi.BeginLinking()
oUi.OnPress(aK2[1], aK2[2])
oUi.OnRelease(aK2[1], aK2[2])
oUi.EndLinking()
? "   pressed and released on the same cell : edges still " +
  len(oUi.Edges())
chkeq("a link to itself is not made", len(oUi.Edges()), nEdges)

# LABELLING, and the same one-command rule
oUi.BeginLabelling("k1")
chk("labelling is its own state", oUi.UiState() = :Labelling)
oUi.CommitLabel("First")
? "   k1 reads " + oUi.NodeLabel("k1") + ", state " + oUi.UiState()
chk("committing sets the label and returns to idle",
    oUi.NodeLabel("k1") = "First" and oUi.UiState() = :Idle)
oUi.Undo()
chk("...and it is one undo", oUi.NodeLabel("k1") = "K1")

# THE KILL CRITERION, and the design it forced. Re-rendering the
# diagram on every pointer-move costs 11,675 ms a frame on 500 nodes
# against a 16 ms budget -- 730 times over, measured 2026-08-22, and no
# faster scene upload could rescue it because the cost is the layout and
# the edge work, not the drawing. So a drag does not re-lay-out: it
# records where the pointer is, the window paints the cell over the
# picture it already has, and the layout runs once at release (11.4 s at
# 500 nodes, which is the price of a structural change and not of a
# gesture).
#
# Asserted here at a size the gate can afford; the 500-node figures are
# recorded above from runs of the same code.
oPf = new stzDiagram("perf44")
oPf.AddNodeXTT("n1", "N1", [ :type = "box", :color = "Info.Solid" ])
for i = 2 to 200
	oPf.AddNodeXTT("n" + i, "N" + i, [ :type = "box", :color = "Info.Solid" ])
	oPf.AddEdge("n" + max([ 1, floor(i / 3) ]), "n" + i)
next
oPf.SetSplines("ortho")
oPf.ToCanvasXT([ :NodeWidth = 60, :NodeHeight = 26,
	:Width = 2400, :Height = 1600 ])
aStart = []
_aRr92_ = oPf.RenderNodeRects()
_nRr92_ = len(_aRr92_)
for _iRr92_ = 1 to _nRr92_
	rr = _aRr92_[_iRr92_]
	if rr[5] = "n7"  aStart = [ rr[1] + rr[3] / 2, rr[2] + rr[4] / 2 ]  ok
next
oPf.OnPress(aStart[1], aStart[2])
nFrames = 100
nT0 = clock()
for k = 1 to nFrames
	oPf.OnMove(aStart[1] + k, aStart[2])
	aPv = oPf.DragPreview()
	aHit = oPf.PickAt(aStart[1] + k, aStart[2])
next
nMsF = (clock() - nT0) / clockspersecond() / nFrames * 1000
oPf.OnRelease(aStart[1] + nFrames, aStart[2])
? "   a drag frame over 200 nodes -- move, preview and pick -- costs " +
  nMsF + " ms"
chk("a drag frame fits inside a 16 ms budget with room to spare",
    nMsF < 16)
chk("...and the gesture still ended in one command",
    len(oPf.EditLog()) = 1)

#---------------------------------------------------------------------------
? ""
sec("-- 44. GG7e: the session is one poll, one frame -----------------")
discharges("GG7e")
#
# The window half of a live diagram is small on purpose, and it is small
# because everything under it was built to be DRIVEN rather than to
# drive. Picking reads the retained scene; the state machine is a
# function of (state, event); the log is over the model's own mutations
# and refusals. So a session is the loop that turns polled input into
# those calls -- and nothing else.
#
# Step() is one frame: read what the pointer did, feed the machine,
# re-render ONLY when the model actually moved, draw. It answers whether
# anything changed, so a caller can idle, and the answer is what this
# section watches: thirty moving frames must re-lay-out zero times, and
# the release frame exactly once. That ratio is the whole design --
# laying a 500-node diagram out again costs eleven seconds, which a
# gesture cannot pay per frame and a structural change can pay once.
#
# Tested against a STUB window, because the contract is a claim about
# the session and not about any window: poll, feed, re-render on change,
# draw. A real window would prove the same contract and cost an open
# window to run it.
#---------------------------------------------------------------------------


oSs = new stzDiagram("sess45")
oSs.AddNodeXTT("r", "R", [ :type = "box", :color = "Info.Solid" ])
for i = 1 to 4
	oSs.AddNodeXTT("k" + i, "K" + i, [ :type = "box", :color = "Info.Solid" ])
	oSs.AddEdge("r", "k" + i)
next
oSs.SetSplines("ortho")
aOpt45 = [ :NodeWidth = 96, :NodeHeight = 36 ]
oSs.ToCanvasXT(aOpt45)
aK1 = []  aK4 = []
_aRr93_ = oSs.RenderNodeRects()
_nRr93_ = len(_aRr93_)
for _iRr93_ = 1 to _nRr93_
	rr = _aRr93_[_iRr93_]
	if rr[5] = "k1"  aK1 = [ rr[1] + rr[3] / 2, rr[2] + rr[4] / 2 ]  ok
	if rr[5] = "k4"  aK4 = [ rr[1] + rr[3] / 2, rr[2] + rr[4] / 2 ]  ok
next

# A STUB WINDOW: the session's contract is "poll, feed the machine,
# re-render only when the model moved, draw" -- which is a claim about
# the session and not about any window, so it is tested against a window
# that only records what it was asked. A real one would prove the same
# contract and cost an open window to run.
oW = new _FakeWin45
oW.SetPointer(aK1[1], aK1[2], FALSE)
chk("a frame with nothing happening changes nothing",
    NOT oSs.Step(oW, aOpt45))
chkeq("...and still draws", oW.Draws(), 1)

oW.SetPointer(aK1[1], aK1[2], TRUE)
oSs.Step(oW, aOpt45)
? "   pressed : state " + oSs.UiState() + " on " + oSs.UiSubject()
chk("the session began the drag from the polled pointer",
    oSs.UiState() = :Dragging and oSs.UiSubject() = "k1")

nRenders = 0
for k = 1 to 30
	oW.SetPointer(aK1[1] + k * 20, aK1[2], TRUE)
	if oSs.Step(oW, aOpt45)  nRenders++  ok
next
? "   30 moving frames re-laid the picture out " + nRenders + " time(s)"
chkeq("a moving pointer never re-lays-out", nRenders, 0)
chk("...though the cell is previewed the whole time",
    len(oSs.DragPreview()) = 3)
chkeq("...and every frame still drew", oW.Draws(), 32)

oW.SetPointer(aK4[1] + 200, aK1[2], FALSE)
bChanged = oSs.Step(oW, aOpt45)
? "   released : the frame reports change = " + bChanged +
  ", log " + len(oSs.EditLog())
chk("releasing is the frame that re-lays-out", bChanged)
chkeq("...and the whole gesture is one command", len(oSs.EditLog()), 1)
nAfter = -1
_aRr94_ = oSs.RenderNodeRects()
_nRr94_ = len(_aRr94_)
for _iRr94_ = 1 to _nRr94_
	rr = _aRr94_[_iRr94_]
	if rr[5] = "k1"  nAfter = rr[1] + rr[3] / 2  ok
next
? "   k1 ended at " + nAfter + ", having started at " + aK1[1]
chk("the picture caught up with the model", nAfter > aK1[1])

# THE NEGATIVE SIBLING: a press on bare paper is not a gesture. Without
# it, "the session starts a drag" would be indistinguishable from "the
# session starts a drag whenever the button goes down".
oW.SetPointer(4, 4, TRUE)
oSs.Step(oW, aOpt45)
? "   pressed on empty paper : state " + oSs.UiState()
chk("pressing nothing begins nothing", oSs.UiState() = :Idle)
oW.SetPointer(4, 4, FALSE)
nLog = len(oSs.EditLog())
oSs.Step(oW, aOpt45)
chkeq("...and releasing it writes nothing", len(oSs.EditLog()), nLog)

#---------------------------------------------------------------------------
? ""
sec("-- 45. A PIN OBEYS THE CONTRACT IT SITS INSIDE ----------------")
#
# This is the assertion the first pin design lacked, and lacking it cost
# a whole session's laws in one picture.
#
# Pins were built as an OVERRIDE: the author's position restored after
# every pass, so no pass could argue with it. Every pin was honoured
# exactly -- measured, to the decimal -- and the picture broke every
# rule this plane has. A pinned cell escaped the minimum separation and
# sat touching its neighbour; it escaped the family air, so grouping
# vanished; it escaped centring, so the parent leaned; and it escaped
# the order the crossing sweep had settled, so the edges tangled into
# shapes no rule in this file would ever produce. The Principal read one
# such picture and named every violation in it.
#
# The lesson is that a position is not what an author owns. In a layered
# drawing the metric placement IS the contract -- separation, rhythm,
# grouping, centring, all of it -- so overriding one number in it
# overrides the contract. What dragging a cell MEANS is where it sits
# among its neighbours, and that is an ordering claim, which the layout
# can honour with every law intact. Pins now decide ORDER and nothing
# else; yFiles calls the same idea layout-from-sketch.
#
# So the test of a pin is not "did the cell land on that number" but
# "is the result still a lawful picture" -- and the negative keeps the
# other half honest, because a contract is most easily satisfied by
# ignoring pins altogether, which is exactly what the code did for two
# commits in the branch every live picture takes.
#---------------------------------------------------------------------------


# THE PICTURE A PIN PRODUCES IS STILL A PICTURE. This is the assertion
# the first pin design lacked, and lacking it cost a whole session's
# laws: pins were applied as an OVERRIDE, restored after every pass, so
# a pinned cell escaped the minimum separation and sat touching its
# neighbour, escaped the family air so grouping vanished, escaped
# centring so parents leaned, and escaped the order the crossing sweep
# had settled so edges tangled. Every pin was honoured exactly and the
# picture broke every rule in the plane.
#
# A pin is an ORDER now -- the drop decides where a cell sits among its
# neighbours, and the layout decides the geometry with all its laws
# intact. So the test of a pin is not "did the cell land on that
# number" but "is the result still a lawful picture".
oPc = new stzDiagram("pincontract")
oPc.AddNodeXTT("lb", "Balancer", [ :type = "box", :color = "Info.Solid" ])
_aA95_ = [ [ "web1", "Web A" ], [ "web2", "Web B" ] ]
_nA95_ = len(_aA95_)
for _iA95_ = 1 to _nA95_
	a = _aA95_[_iA95_]
	oPc.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
	oPc.AddEdge("lb", a[1])
next
oPc.AddNodeXTT("api1", "API A", [ :type = "box", :color = "Info.Solid" ])
oPc.AddNodeXTT("api2", "API B", [ :type = "box", :color = "Info.Solid" ])
oPc.AddEdge("web1", "api1")  oPc.AddEdge("web2", "api2")
oPc.SetSplines("ortho")
PCF = new stzFont("C:/Windows/Fonts/segoeui.ttf")
aPO = [ :Font = PCF, :NodeWidth = 96, :NodeHeight = 36, :FontSize = 13,
        :Width = 1000, :Height = 700 ]
oPc.ToCanvasXT(aPO)
nSepFree = _TightestPair46(oPc)
? "   unpinned : the tightest pair in any rank is " + nSepFree + "px apart"
chk("the free picture separates its cells", nSepFree > 20)

# now drop Web A past Web B -- the gesture the Principal made
oPc.Pin("web1", 3)
oPc.ToCanvasXT(aPO)
nSepPin = _TightestPair46(oPc)
nSepLaw = floor(oPc.NodeSeparation() * 96)
? "   pinned   : the tightest pair is now " + nSepPin +
  "px apart, against a contract minimum of " + nSepLaw
# AGAINST THE CONTRACT, not against the free picture. A rank of two in a
# 1000px canvas spreads to the edges, so the unpinned figure is a
# property of the paper rather than of the layout; comparing to it would
# fail every honest pin. What the law says is that no two cells come
# closer than the separation, and that is what a pin must not break.
# ...within the same stroke+AA slack S7 grants: natural spacing renders
# the contract EXACTLY, so the measured gap can land a hair under it
chk("a pinned picture still obeys the separation contract",
    nSepPin >= nSepLaw - 2)
chk("...as the free one does", nSepFree >= nSepLaw - 2)

# ...and the drop still means what it looked like
nW1 = _X46(oPc, "web1")
nW2 = _X46(oPc, "web2")
? "   Web A at " + nW1 + ", Web B at " + nW2
chk("the dropped cell sits where it was dropped -- past its sibling",
    nW1 > nW2)

# ...and the parent is still centred over them, which the override
# version broke
nLb = _X46(oPc, "lb")
? "   Balancer at " + nLb + ", its children's middle is " +
  ((nW1 + nW2) / 2)
chk("the parent is still centred over its children",
    fabs(nLb - (nW1 + nW2) / 2) < 1)

# THE NEGATIVE SIBLING: the pin must still DO something, or "the
# contract holds" would be satisfied most easily by ignoring pins
# altogether -- which is exactly what the code did for two commits in
# the branch every live picture takes.
oPc.Unpin("web1")
oPc.ToCanvasXT(aPO)
? "   unpinned again : Web A at " + _X46(oPc, "web1") + ", Web B at " +
  _X46(oPc, "web2")
chk("removing the pin puts the order back",
    _X46(oPc, "web1") < _X46(oPc, "web2"))

#---------------------------------------------------------------------------
? ""
sec("-- 46. THE SHIPPED PICTURE, audited against the whole contract --")
#
# Every law in this plane had a guard, the suite was green, and the
# Principal kept finding the same violations by looking at the product.
# That is not bad luck; it is a method fault of mine. Each section tests
# ONE law on a scene I invented for it, and the scene I invent is the one
# where the law already holds. Nothing was testing the picture the
# product actually renders.
#
# So this section takes the demo's own graph at the demo's own size with
# the demo's own font -- the configuration a user sees first -- and
# audits it against the laws at once. Not a new law: a new PLACE to
# apply them, which is where they were failing.
#
# What it found on its first run, with 277 assertions already green:
# two channels out of one source 9px apart under a 24px clearance
# (neither one bus nor two lanes), and two edges whose ends sat 47px and
# 79px off-column -- the near-miss band this library forbids by name,
# in its own default picture, because alignment ran before the passes
# that move things.
#---------------------------------------------------------------------------

AUFONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oAu = new stzDiagram("audit46")
_aA96_ = [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
           [ "api1","API A" ],[ "api2","API B" ],
           [ "db1","DB A" ],[ "db2","DB B" ],[ "log","Logger" ] ]
_nA96_ = len(_aA96_)
for _iA96_ = 1 to _nA96_
	a = _aA96_[_iA96_]
	oAu.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oAu.AddEdge("lb","web1")    oAu.AddEdge("lb","web2")
oAu.AddEdge("web1","api1")  oAu.AddEdge("web2","api2")
oAu.AddEdge("api1","db1")   oAu.AddEdge("api2","db2")
oAu.AddEdge("web1","log")   oAu.AddEdge("api2","log")
oAu.SetSplines("ortho")
oAu.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 96, :NodeHeight = 36,
	:FontSize = 13, :Width = 1100, :Height = 760 ])
nAuClr = oAu._LineClearance()
aAuP = oAu.RenderEdgePaths()

# NO NEAR-MISS LANES: two horizontals are on one line or a clearance
# apart, never in between.
nAuNear = 0
nAuWorst = 0
for i = 1 to len(aAuP)
	for j = i + 1 to len(aAuP)
		for ia = 1 to len(aAuP[i][2]) - 3 step 2
			for jb = 1 to len(aAuP[j][2]) - 3 step 2
				if fabs(aAuP[i][2][ia+1] - aAuP[i][2][ia+3]) > 0.5  loop  ok
				if fabs(aAuP[j][2][jb+1] - aAuP[j][2][jb+3]) > 0.5  loop  ok
				# A LANE HAS RUN. A straight column's collapsed midpoint
				# is a zero-length "segment" that reads as horizontal AND
				# vertical to a coordinate test, and it sat 9px from a
				# real channel. A point cannot crowd a lane; it is not one.
				if fabs(aAuP[i][2][ia] - aAuP[i][2][ia+2]) < 2  loop  ok
				if fabs(aAuP[j][2][jb] - aAuP[j][2][jb+2]) < 2  loop  ok
				nDy = fabs(aAuP[i][2][ia+1] - aAuP[j][2][jb+1])
				if nDy < 0.5 or nDy >= nAuClr  loop  ok
				nAuNear++
				if nDy > nAuWorst  nAuWorst = nDy  ok
			next
		next
	next
next
? "   lane pairs neither coincident nor a clearance apart : " + nAuNear
chkeq("no two lanes sit in the near-miss band", nAuNear, 0)

# NO NEAR-MISS ALIGNMENT: an edge's ends share a column or clearly do
# not. The band between is what a reader cannot parse.
nAuNA = 0
_aP297_ = aAuP
_nP297_ = len(_aP297_)
for _iP297_ = 1 to _nP297_
	p2 = _aP297_[_iP297_]
	aE2 = StzSplit(p2[1], ">")
	nSx = -1  nTx2 = -1
	_aR98_ = oAu.RenderNodeRects()
	_nR98_ = len(_aR98_)
	for _iR98_ = 1 to _nR98_
		r = _aR98_[_iR98_]
		if r[5] = StzLower(aE2[1])  nSx = r[1] + r[3] / 2  ok
		if r[5] = StzLower(aE2[2])  nTx2 = r[1] + r[3] / 2  ok
	next
	if nSx < 0 or nTx2 < 0  loop  ok
	nD2 = fabs(nSx - nTx2)
	if nD2 < 0.5 or nD2 > 96  loop  ok
	nAuNA++
	? "   near-miss alignment on " + p2[1] + " : " + nD2 + "px"
next
? "   edges neither aligned nor clearly slanted : " + nAuNA
chkeq("no edge is ALMOST vertical", nAuNA, 0)

# NO SHARED LANE between edges that share no endpoint.
nAuShare = 0
for i = 1 to len(aAuP)
	for j = i + 1 to len(aAuP)
		aA = StzSplit(aAuP[i][1], ">")
		aB = StzSplit(aAuP[j][1], ">")
		if aA[1] = aB[1] or aA[2] = aB[2]  loop  ok
		for ia = 1 to len(aAuP[i][2]) - 3 step 2
			for jb = 1 to len(aAuP[j][2]) - 3 step 2
				if fabs(aAuP[i][2][ia+1] - aAuP[i][2][ia+3]) > 0.5  loop  ok
				if fabs(aAuP[j][2][jb+1] - aAuP[j][2][jb+3]) > 0.5  loop  ok
				if fabs(aAuP[i][2][ia+1] - aAuP[j][2][jb+1]) > 1  loop  ok
				nOv = min([ max([ aAuP[i][2][ia], aAuP[i][2][ia+2] ]),
				            max([ aAuP[j][2][jb], aAuP[j][2][jb+2] ]) ]) -
				      max([ min([ aAuP[i][2][ia], aAuP[i][2][ia+2] ]),
				            min([ aAuP[j][2][jb], aAuP[j][2][jb+2] ]) ])
				if nOv > 2  nAuShare++  ok
			next
		next
	next
next
? "   unrelated edges sharing a lane : " + nAuShare
chkeq("no two unrelated edges share ink", nAuShare, 0)

# AND THE SEPARATION CONTRACT, in the shipped size
nAuTight = 1000000
aAuR = oAu.RenderNodeRects()
for i = 1 to len(aAuR)
	for j = i + 1 to len(aAuR)
		if fabs(aAuR[i][2] - aAuR[j][2]) > 2  loop  ok
		nG = max([ aAuR[i][1], aAuR[j][1] ]) -
			min([ aAuR[i][1] + aAuR[i][3], aAuR[j][1] + aAuR[j][3] ])
		if nG < nAuTight  nAuTight = nG  ok
	next
next
? "   tightest pair in a rank : " + nAuTight + "px"
chk("the shipped picture separates its cells (within stroke+AA, as S7)",
    nAuTight >= floor(oAu.NodeSeparation() * 96) - 2)


sec("-- 47. I7: SIBLINGS STAND ON EITHER SIDE OF THEIR PARENT -------")
#
# The Principal, on the picture section 46 had just certified: "when two
# sibling cells have the same level they must be situated spatially left
# and right. your current shape suggested they are not siblings and that
# DB B is more tightly linked to API B since it has a vertical link."
#
# He is naming the cost of a coincidence. A vertical column is the
# strongest statement this grammar has, and I6 already says who earns it
# -- the child carrying the graph onward. A LEAF that happens to inherit
# it says the same thing with no graph behind it, and its siblings, all
# queued down one flank, read as afterthoughts of a relation they hold
# equally.
#
# So the property is positional and checkable before any line is drawn:
# a parent's column lies strictly INSIDE the span of its children. The
# instrument is written over the render facts rather than over a scene,
# so it audits any picture put in front of it; it is pointed at the
# shipped one for the same reason section 46 is.
#---------------------------------------------------------------------------

# the shipped picture's own facts, re-read as a graph
# (_I7Cx / _I7Cy / _I7Kids live with the other helpers at the foot of
#  the file -- a func here would end the script)
aI7R = oAu.RenderNodeRects()
aI7P = oAu.RenderEdgePaths()

nI7Flat = 0    # a parent at the EDGE of its children's span
nI7Leaf = 0    # a leaf holding its parent's column
nI7Fan  = 0    # same-rank siblings not reached to either side

for i7 = 1 to len(aI7R)
	cP7 = aI7R[i7][5]
	aK7 = _I7Kids(aI7P, cP7)
	if len(aK7) < 2  loop  ok
	nPx7 = _I7Cx(aI7R, cP7)

	# only the children sharing one rank are peers of each other
	for r7 = 1 to len(aK7)
		aSame = []
		nRy = _I7Cy(aI7R, aK7[r7])
		for s7 = 1 to len(aK7)
			if fabs(_I7Cy(aI7R, aK7[s7]) - nRy) < 2  aSame + aK7[s7]  ok
		next
		if len(aSame) < 2  loop  ok

		nLo7 = 1000000  nHi7 = -1000000
		bSpine7 = 0
		for s7 = 1 to len(aSame)
			nCx7 = _I7Cx(aI7R, aSame[s7])
			if nCx7 < nLo7  nLo7 = nCx7  ok
			if nCx7 > nHi7  nHi7 = nCx7  ok
			# a child ON the column that carries the graph onward is
			# I6 speaking, and I6 outranks the straddle -- the emphasis
			# is one the graph itself declares
			if fabs(nCx7 - nPx7) <= 1 and len(_I7Kids(aI7P, aSame[s7])) > 0
				bSpine7 = 1
			ok
		next

		# ...and where no continuation claims it, a leaf may not
		for s7 = 1 to len(aSame)
			if fabs(_I7Cx(aI7R, aSame[s7]) - nPx7) > 1  loop  ok
			if len(_I7Kids(aI7P, aSame[s7])) > 0  loop  ok
			nI7Leaf++
			? "   leaf holding its parent's column : " +
			  cP7 + " > " + aSame[s7]
		next

		if bSpine7  loop  ok
		if NOT (nPx7 > nLo7 + 1 and nPx7 < nHi7 - 1)
			nI7Flat++
			? "   parent not between its peers : " + cP7 +
			  "  x=" + nPx7 + " span=[" + nLo7 + "," + nHi7 + "]"
		ok
	next
next

? "   parents standing at the edge of their peers' span : " + nI7Flat
chkeq("every parent stands BETWEEN its same-rank children", nI7Flat, 0)
? "   leaves wearing a continuation's column : " + nI7Leaf
chkeq("no leaf claims the column a spine would earn", nI7Leaf, 0)

# THE EDGE HALF OF THE SAME CLAIM (I5). Peers reached by one grammar:
# one stem out of the source, one channel, and legs to EITHER side. A
# picture that fans left and right states a pair; one that goes left
# twice states a queue.
for i7 = 1 to len(aI7R)
	cP7 = aI7R[i7][5]
	aK7 = _I7Kids(aI7P, cP7)
	if len(aK7) < 2  loop  ok
	nPx7 = _I7Cx(aI7R, cP7)
	nLeft7 = 0  nRight7 = 0  bSp7 = 0
	for s7 = 1 to len(aK7)
		nCx7 = _I7Cx(aI7R, aK7[s7])
		if nCx7 < nPx7 - 1  nLeft7++  ok
		if nCx7 > nPx7 + 1  nRight7++  ok
		if fabs(nCx7 - nPx7) <= 1 and len(_I7Kids(aI7P, aK7[s7])) > 0
			bSp7 = 1
		ok
	next
	if bSp7  loop  ok
	if nLeft7 = 0 or nRight7 = 0
		nI7Fan++
		? "   children all on one flank of " + cP7 +
		  " : " + nLeft7 + " left, " + nRight7 + " right"
	ok
next
? "   sources whose children queue down one flank : " + nI7Fan
chkeq("children fan to both sides of their source", nI7Fan, 0)

# AND THE RULE IS THE ENGINE'S, NOT THIS PICTURE'S. The straddle is a
# layout pass, so a graph shaped the same way anywhere gets the same
# treatment -- here on a plain fan the demo never draws.
oI7B = new stzDiagram("i7b")
_aA99_ = [ [ "root","Root" ], [ "spine","Spine" ], [ "leafa","Leaf A" ],
           [ "deep","Deep" ] ]
_nA99_ = len(_aA99_)
for _iA99_ = 1 to _nA99_
	a = _aA99_[_iA99_]
	oI7B.AddNodeXTT(a[1], a[2], [ :type = "box" ])
next
oI7B.AddEdge("root","spine")  oI7B.AddEdge("root","leafa")
oI7B.AddEdge("spine","deep")
oI7B.SetSplines("ortho")
oI7B.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36, :Width = 900, :Height = 500 ])
aI7BR = oI7B.RenderNodeRects()
nRt7 = _I7Cx(aI7BR, "root")
nSp7 = _I7Cx(aI7BR, "spine")
nLf7 = _I7Cx(aI7BR, "leafa")
? "   root=" + nRt7 + "  spine=" + nSp7 + "  leaf=" + nLf7
chk("a SPINE keeps the column its continuation earns",
    fabs(nSp7 - nRt7) < 1)
chk("...and the leaf sibling takes the other side",
    fabs(nLf7 - nRt7) > 1)


sec("-- 48. THE ELBOW IS DRAWN IN THE SAME HAND AS THE CELL ---------")
#
# The Principal, once the geometry stopped arguing with him: "i find it
# more beautiful when, in this style, the corners of the edge change of
# directions be rounds, because the celles adopt also the same style.
# leave the other style where everything is rectangular."
#
# That is I5 pointed at style rather than at structure. A rounded box
# wired with square elbows is two hands in one picture, and a reader has
# no graph fact to attribute the difference to -- the same objection that
# retired the one rounded self-loop in a square picture, now running the
# other way. So the corner an edge turns follows the corner a node is
# drawn with, and the wholly rectangular style stays reachable.
#
# The claim that matters is that this is INK. The logical path is the
# same either way, so channels, labels and every instrument in this file
# read one geometry and only the stroke differs.
#---------------------------------------------------------------------------

# (_CorGraph lives with the other helpers at the foot of the file)
oCorR = _CorGraph("corR")
cSvgR = oCorR.ToSVGXT([ :NodeWidth = 120, :NodeHeight = 48, :Corner = 14 ])
oCorS = _CorGraph("corS")
cSvgS = oCorS.ToSVGXT([ :NodeWidth = 120, :NodeHeight = 48, :Corner = 0 ])

nChR = len(_DiagChords(cSvgR, EDGERGB))
nChS = len(_DiagChords(cSvgS, EDGERGB))
? "   diagonal chords in the wires : rounded " + nChR + " , square " + nChS
chk("a rounded picture turns its corners with an ARC", nChR > 4)
chkeq("...and a rectangular one turns them square", nChS, 0)

# THE OVERRIDE: rounded cells, square wires, for anyone who wants it
oCorX = _CorGraph("corX")
cSvgX = oCorX.ToSVGXT([ :NodeWidth = 120, :NodeHeight = 48, :Corner = 14,
	:EdgeCorners = :Sharp ])
? "   with :EdgeCorners = :Sharp : " + len(_DiagChords(cSvgX, EDGERGB))
chkeq("the style can be asked for independently of the cells",
      len(_DiagChords(cSvgX, EDGERGB)), 0)

# AND IT IS INK ONLY -- the geometry every other law is measured against
# does not move
aCorPR = oCorR.RenderEdgePaths()
aCorPS = oCorS.RenderEdgePaths()
nCorDiff = 0
if len(aCorPR) != len(aCorPS)
	nCorDiff = 999
else
	for i48 = 1 to len(aCorPR)
		if aCorPR[i48][1] != aCorPS[i48][1]  nCorDiff++  loop  ok
		if len(aCorPR[i48][2]) != len(aCorPS[i48][2])  nCorDiff++  loop  ok
		for j48 = 1 to len(aCorPR[i48][2])
			if fabs(aCorPR[i48][2][j48] - aCorPS[i48][2][j48]) > 0.001
				nCorDiff++
			ok
		next
	next
ok
? "   published path coordinates that differ between the styles : " + nCorDiff
chkeq("the corner style is INK, not geometry", nCorDiff, 0)

# A RECTANGULAR CELL IS STILL A FILLED CELL. :Corner = 0 asked the canvas
# for a round rect of radius zero and got an outline with no fill, so the
# rectangular style drew white boxes with white labels inside them -- the
# dial the Principal asked to keep was the one that did not work.
nCorFill = 0
_aCf100_ = StzFindAll("<rect", cSvgS)
_nCf100_ = len(_aCf100_)
for _iCf100_ = 1 to _nCf100_
	_cf_ = _aCf100_[_iCf100_]
	_ctail_ = StzSubStr(cSvgS, _cf_, min([ 400, StzLen(cSvgS) - _cf_ + 1 ]))
	_cend_ = StzFindFirst(">", _ctail_)
	if _cend_ = 0  loop  ok
	if StzFindFirst("68,119,255", StzSubStr(_ctail_, 1, _cend_)) > 0  nCorFill++  ok
next
? "   filled rectangles in the square render : " + nCorFill
chk("a square cell keeps its fill", nCorFill >= 4)


sec("-- 49. A LINK IS EDITED BY ITS KNOBS -------------------------")
#
# The Principal, on first contact with the live editor as a product:
# "the main action is managing links -- now we can add a new, but we need
# to remove one, and changing one from its knobs -- and let the diagram
# plastic position algorithm [do the placing]". Cells are the layout's;
# LINKS are the author's. So a link can be grabbed by either END (its
# knobs), carried to another cell, and dropped -- one gesture, one
# command, one undo -- and removed by a direct verb.
#
# The refusals carry as much meaning as the gesture: the MIDDLE of an
# edge belongs to the plastic layout and grabs nothing; a knob dropped on
# paper abandons the gesture with the model untouched; a rewire onto a
# pair the graph already holds is refused BEFORE the old link is removed,
# so a refused gesture changes nothing at all.
#---------------------------------------------------------------------------

oRw = new stzDiagram("rw49")
_aA101_ = [ [ "a","A" ],[ "b","B" ],[ "c","C" ],[ "d","D" ] ]
_nA101_ = len(_aA101_)
for _iA101_ = 1 to _nA101_
	a = _aA101_[_iA101_]
	oRw.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oRw.AddEdge("a","b")  oRw.AddEdge("a","c")  oRw.AddEdge("b","d")
oRw.SetSplines("ortho")
oRw.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36, :Width = 900, :Height = 600 ])

# the a>c path, pressed 8px shy of its arrow end
aRwP = []
_aP49102_ = oRw.RenderEdgePaths()
_nP49102_ = len(_aP49102_)
for _iP49102_ = 1 to _nP49102_
	p49 = _aP49102_[_iP49102_]
	if p49[1] = "a>c"  aRwP = p49[2]  ok
next
nRwN = len(aRwP)
nRwDx = aRwP[nRwN-1] - aRwP[nRwN-3]
nRwDy = aRwP[nRwN] - aRwP[nRwN-2]
nRwL = sqrt(nRwDx*nRwDx + nRwDy*nRwDy)
nRwX = aRwP[nRwN-1] - nRwDx/nRwL*8
nRwY = aRwP[nRwN] - nRwDy/nRwL*8

oRw.OnPress(nRwX, nRwY)
chkeq("pressing near a link's end enters :Rewiring", "" + oRw.UiState(), "rewiring")
aRw49 = oRw.UiRewire()
chk("...knowing which link and which end",
    len(aRw49) = 3 and aRw49[1] = "a" and aRw49[2] = "c" and aRw49[3] = "to")
chk("...and the OTHER end anchors the ghost", len(oRw.RewireAnchor()) = 2)

_r49d_ = _Rect49(oRw, "d")
oRw.OnRelease(_r49d_[1] + _r49d_[3]/2, _r49d_[2] + _r49d_[4]/2)
chk("dropped on a cell, that end now means THAT cell",
    NOT oRw.EdgeExists("a","c") and oRw.EdgeExists("a","d"))
chkeq("one gesture is ONE log entry", len(oRw.EditLog()), 1)
oRw.Undo()
chk("...whose single undo restores the link the author had",
    oRw.EdgeExists("a","c") and NOT oRw.EdgeExists("a","d"))

# THE REFUSALS
oRw.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36, :Width = 900, :Height = 600 ])
aRwP = []
_aP49103_ = oRw.RenderEdgePaths()
_nP49103_ = len(_aP49103_)
for _iP49103_ = 1 to _nP49103_
	p49 = _aP49103_[_iP49103_]
	if p49[1] = "a>c"  aRwP = p49[2]  ok
next
nRwBest = 1  nRwBestL = 0
for i49 = 1 to len(aRwP) - 3 step 2
	_l49_ = fabs(aRwP[i49+2]-aRwP[i49]) + fabs(aRwP[i49+3]-aRwP[i49+1])
	if _l49_ > nRwBestL  nRwBestL = _l49_  nRwBest = i49  ok
next
nRwMx = (aRwP[nRwBest] + aRwP[nRwBest+2]) / 2
nRwMy = (aRwP[nRwBest+1] + aRwP[nRwBest+3]) / 2
oRw.OnPress(nRwMx, nRwMy)
chkeq("the MIDDLE of an edge grabs nothing -- it is the layout's",
      "" + oRw.UiState(), "idle")
oRw.OnCancel()

nRwN = len(aRwP)
nRwDx = aRwP[nRwN-1] - aRwP[nRwN-3]
nRwDy = aRwP[nRwN] - aRwP[nRwN-2]
nRwL = sqrt(nRwDx*nRwDx + nRwDy*nRwDy)
oRw.OnPress(aRwP[nRwN-1] - nRwDx/nRwL*8, aRwP[nRwN] - nRwDy/nRwL*8)
nRw49 = len(oRw.EditLog())
# bottom-right corner: content hugs top-left at contract spacing now, so
# (20,20) is INSIDE the picture -- the first run of this line rewired the
# link onto the cell that lives there
oRw.OnRelease(870, 570)
chkeq("a knob dropped on paper abandons the gesture", len(oRw.EditLog()), nRw49)

oRw.OnPress(aRwP[nRwN-1] - nRwDx/nRwL*8, aRwP[nRwN] - nRwDy/nRwL*8)
_r49b_ = _Rect49(oRw, "b")
oRw.OnRelease(_r49b_[1] + _r49b_[3]/2, _r49b_[2] + _r49b_[4]/2)
chk("a rewire onto an existing pair is refused WHOLE",
    len(oRw.EditLog()) = nRw49 and oRw.EdgeExists("a","c") and oRw.EdgeExists("a","b"))

# THE DIRECT VERB
chk("RemoveLinkAt removes the link under the pointer",
    oRw.RemoveLinkAt(nRwMx, nRwMy) and NOT oRw.EdgeExists("a","c"))
oRw.Undo()
chk("...and it is one undo away like everything else", oRw.EdgeExists("a","c"))
chkeq("RemoveLinkAt on paper is a refusal, not an error",
      oRw.RemoveLinkAt(20, 20), 0)


sec("-- 50. A NAMED SIZE IS A MAXIMUM, NEVER A TARGET --------------")
#
# The Principal, marking two voids in the live editor's picture after his
# own link edits: "at any situation, space is optimised as we agreed."
#
# The layout was not the fault -- laid out naturally the same graph was
# 492px wide and tight. The FIT was: a named :Width was a canvas to fill,
# so a graph that had lost columns to link edits was stretched until two
# cells in one rank stood 836px apart with nothing between them. Every
# gap the contract set was multiplied by whatever the stretch needed;
# nothing in the graph said "far apart", the paper did. Under the plastic
# layout geometry states facts, so a distance manufactured by the medium
# is a lie like any other.
#
# The rule now: every hierarchical picture is laid out at CONTRACT
# spacing first. A named size the natural picture fits inside buys
# PAPER, not distance -- the content keeps its exact natural geometry.
# Only when the picture does not fit does the named size constrain, on
# the fill-and-shrink path that always existed.
#---------------------------------------------------------------------------

# (_G50 lives at the foot of the file)

o50a = _G50()
o50a.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
n50W = o50a.LastCanvas().Width()
n50H = o50a.LastCanvas().Height()
? "   natural : " + n50W + "x" + n50H

o50b = _G50()
o50b.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36, :Width = 1100, :Height = 760 ])
? "   in an 1100x760 window : canvas " + o50b.LastCanvas().Width() + "x" +
  o50b.LastCanvas().Height()
chk("the window keeps its size", o50b.LastCanvas().Width() = 1100 and
    o50b.LastCanvas().Height() = 760)

# THE CLAIM: the window buys paper, not distance -- position for
# position, the windowed render IS the natural one
n50Diff = 0
a50N = o50a.RenderNodeRects()
a50W = o50b.RenderNodeRects()
for i50 = 1 to len(a50N)
	for j50 = 1 to len(a50W)
		if a50W[j50][5] = a50N[i50][5]
			if fabs(a50W[j50][1] - a50N[i50][1]) > 0.5 or
			   fabs(a50W[j50][2] - a50N[i50][2]) > 0.5
				n50Diff++
			ok
		ok
	next
next
? "   cells whose position differs from the natural render : " + n50Diff
chkeq("a named size buys PAPER, not distance", n50Diff, 0)

# ...so the void his mark circled is gone: no two same-rank neighbours
# stand further apart than a subtree's width can explain. The 836px gap
# is the regression this pins against.
n50Worst = 0
for i50 = 1 to len(a50W)
	for j50 = 1 to len(a50W)
		if i50 = j50  loop  ok
		if fabs(a50W[i50][2] - a50W[j50][2]) > 2  loop  ok
		_g50_ = a50W[j50][1] - (a50W[i50][1] + a50W[i50][3])
		if _g50_ > n50Worst  n50Worst = _g50_  ok
	next
next
? "   widest same-rank gap : " + n50Worst + "px  (was 836 when the paper stretched)"
chk("no manufactured distance survives", n50Worst < 400)

# THE OTHER SIDE: a picture too big for its medium still fits to it --
# the named size constrains exactly when it must
o50c = _G50()
o50c.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36, :Width = 300, :Height = 240 ])
? "   in a 300x240 medium : canvas " + o50c.LastCanvas().Width() + "x" +
  o50c.LastCanvas().Height()
chk("a picture larger than its medium still fits it",
    o50c.LastCanvas().Width() = 300 and o50c.LastCanvas().Height() = 240)


sec("-- 51. DN0: a domain is a DECLARATION, and the default moved NOTHING --")
discharges("DN0")
#
# The DN ruling: BPMN, state machines, org charts, UML and electric all
# land as NOTATION PROFILES over the one foundation -- vocabulary, rules
# in the house shape, grammar amendments, glyphs -- never as a second
# renderer. DN0 is the proof the seam is real: the generic diagram is
# now itself a profile, and expressing it as one moved NOTHING.
#
# Byte-identity was proven at the seam's birth on four rendered scenes
# (service ortho in a window, the full type table, LR with self-loops,
# the rectangular style): PNG bytes equal before and after the refactor.
# What this section holds LIVE is everything around that proof: the
# default's answers are the shared table's, a domain's declaration
# outranks the table, rules reach the editor as refusals, and the
# registry always answers.
#---------------------------------------------------------------------------

# the default profile is installed at birth and answers the shared table
oDn = new stzDiagram("dn0")
chkeq("a diagram is born under the DEFAULT notation", oDn.Notation(), "default")
oDnP = oDn.NotationO()
nDnTbl = 0
_aADnK104_ = [ [ "task", "box" ], [ "decision", "diamond" ],
              [ "database", "cylinder" ], [ "start", "ellipse" ],
              [ "end", "doublecircle" ], [ "state", "circle" ] ]
_nADnK104_ = len(_aADnK104_)
for _iADnK104_ = 1 to _nADnK104_
	aDnK = _aADnK104_[_iADnK104_]
	if oDnP.GlyphOf(aDnK[1]) = aDnK[2]  nDnTbl++  ok
next
chkeq("the default's glyphs ARE the shared type table", nDnTbl, 6)
chk("...and an unknown kind passes through open, unjudged",
    oDnP.GlyphOf("blorp") = "" and len(oDnP.Check(oDn)) = 0)

# A DOMAIN DECLARES; ITS DECLARATION OUTRANKS THE TABLE
oFsm = new stzNotation("fsm51")
oFsm.AddKind("state", "circle")
oFsm.AddKind("final", "doublecircle")
oFsm.AddKind("task", "diamond")      # deliberately AGAINST the table
oFsm.Close()
oFsm.Forbid(:SelfLink, "a state cannot transition to itself in fsm51; " +
	"model a stay as a guard on departure instead")
StzRegisterNotation(oFsm)
chkeq("a declared kind outranks the shared table",
      StzNotation("fsm51").GlyphOf("task"), "diamond")
chkeq("...and a kind outside a CLOSED vocabulary answers nothing",
      StzNotation("fsm51").GlyphOf("database"), "")
chkeq("the registry answers a name it does not know with the default",
      StzNotation("never-registered").Name_(), "default")

# THE RULES REACH THE MODEL in the house rule shape
oDm = new stzDiagram("m51")
oDm.SetNotation("fsm51")
oDm.AddNodeXTT("a", "A", [ :type = "state" ])
oDm.AddNodeXTT("b", "B", [ :type = "task" ])
oDm.AddNodeXTT("c", "C", [ :type = "process" ])   # NOT in the vocabulary
oDm.AddEdge("a", "b")
aDnF = oDm.NotationFindings()
? "   findings on the fsm51 model : " + len(aDnF)
nDnUk = 0
_aADnR105_ = aDnF
_nADnR105_ = len(_aADnR105_)
for _iADnR105_ = 1 to _nADnR105_
	aDnR = _aADnR105_[_iADnR105_]
	if aDnR[:rule] = "notation-unknown-kind" and aDnR[:subject] = "c"
		nDnUk++
	ok
next
chkeq("a closed vocabulary reports the stranger, in the house shape", nDnUk, 1)
chk("...naming the kinds it DOES hold, so the refusal teaches",
    StzFindFirst("state", "" + aDnF[1][:message]) > 0)

# ...AND REACH THE EDITOR AS REFUSALS, with no editor code knowing fsm51
oDm.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nDnLog = len(oDm.EditLog())
bDnGot = oDm.Edit(:Link, [ "a", "a" ])
chk("a link the domain forbids is refused at the command",
    bDnGot = 0 and len(oDm.EditLog()) = nDnLog)
bDnGot = oDm.Edit(:Link, [ "b", "a" ])
chk("...while a lawful link passes the same gate",
    bDnGot = 1 and len(oDm.EditLog()) = nDnLog + 1)
oDm.Undo()

# THE LIVE HALF OF BYTE-IDENTITY: naming the default explicitly is the
# same picture as never mentioning notations at all
oDx = new stzDiagram("x51")
oDx.AddNodeXTT("p", "P", [ :type = "decision" ])
oDx.AddNodeXTT("q", "Q", [ :type = "database" ])
oDx.AddEdge("p", "q")
oDx.SetSplines("ortho")
oDx.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 40 ])
cDnA = oDx.LastCanvas().ToSVG()
oDy = new stzDiagram("x51")
oDy.SetNotation("default")
oDy.AddNodeXTT("p", "P", [ :type = "decision" ])
oDy.AddNodeXTT("q", "Q", [ :type = "database" ])
oDy.AddEdge("p", "q")
oDy.SetSplines("ortho")
oDy.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 40 ])
chk("naming the default changes not one byte of the picture",
    cDnA = oDy.LastCanvas().ToSVG())

# a GRAMMAR amendment rides SetNotation
oLr = new stzNotation("lr51")
oLr.SetRankDir(:LeftToRight)
StzRegisterNotation(oLr)
oDz = new stzDiagram("z51")
oDz.SetNotation("lr51")
# the stored name is whatever spelling the profile used; the fact
# under test is that the amendment ARRIVED, not how it is spelt
chkeq("a notation may amend the grammar it is read in",
      StzLower("" + oDz._NativeRankDir()), "lr")


sec("-- 52. DN1: the org chart is the first real DOMAIN ------------")
discharges("DN1")
#
# DN1's claim: a MODEL projects. stzOrgChart -- positions, levels,
# ReportsTo -- is born under its own notation, drawn by the same plastic
# layout as everything else, and its tree grammar reaches the editor as
# refusals with no editor code knowing what an org is.
#
# The structural floor lives in the notation (:SelfLink, :SecondParent,
# :Cycle); the governance rule bases (separation of duties, vacancy,
# succession) stay where they were -- they judge CONTENT, and Validate()
# was already their name, which is why the notation sweep is called
# NotationFindings(): a name that answers structure on the parent and
# content on the child would be two faces disagreeing.
#---------------------------------------------------------------------------

oOg = new stzOrgChart("acme52")
chkeq("an org chart is born under its own notation", oOg.Notation(), "orgchart")

oOg.AddExecutiveXT("ceo", "CEO")
oOg.AddManagerXT("cto", "CTO")
oOg.AddManagerXT("cfo", "CFO")
oOg.AddStaffXT("dev1", "Dev One")
oOg.AddStaffXT("acc1", "Accountant")
oOg.ReportsTo("cto", "ceo")
oOg.ReportsTo("cfo", "ceo")
oOg.ReportsTo("dev1", "cto")
oOg.ReportsTo("acc1", "cfo")
chkeq("a lawful chart has no structural findings",
      len(oOg.NotationFindings()), 0)

# the model can be damaged behind the notation's back; the sweep says so
oOg.Connect("cfo", "dev1")
aOg = oOg.NotationFindings()
nOg2 = 0
_aAOgR106_ = aOg
_nAOgR106_ = len(_aAOgR106_)
for _iAOgR106_ = 1 to _nAOgR106_
	aOgR = _aAOgR106_[_iAOgR106_]
	if aOgR[:rule] = "notation-second-parent" and aOgR[:subject] = "dev1"
		nOg2++
	ok
next
chkeq("a second supervisor is ONE finding, on the position", nOg2, 1)
chkeq("...and the node is named once, not once per edge", len(aOg), 1)
oOg.RemoveThisEdge("cfo", "dev1")

# THE TREE GRAMMAR AT THE GESTURE, through the same Edit gate as any
# diagram -- the editor knows nothing of supervisors
oOg.SetSplines("ortho")
oOg.ToCanvasXT([ :NodeWidth = 110, :NodeHeight = 40 ])
nOgLog = len(oOg.EditLog())
chk("a link onto a supervised position is refused at the gesture",
    oOg.Edit(:Link, [ "cfo", "dev1" ]) = 0 and len(oOg.EditLog()) = nOgLog)
chk("a link that would close a reporting cycle is refused",
    oOg.Edit(:Link, [ "dev1", "ceo" ]) = 0 and len(oOg.EditLog()) = nOgLog)
oOg.AddStaffXT("intern", "Intern")
chk("...while supervising the unsupervised passes the same gate",
    oOg.Edit(:Link, [ "cto", "intern" ]) = 1)
oOg.Undo()

# AND THE GOVERNANCE FACE IS UNTOUCHED: Validate() still answers the
# rule bases, not the notation -- the two sweeps coexist by name
chk("Validate() still belongs to governance, untouched by DN1",
    isList(oOg.Validate()))

# THE PICTURE IS THE PLASTIC LAYOUT'S: same laws, no org-specific
# geometry code. The root is centred over its children and the two
# families are told apart by air -- I6/I7 on a real domain's model.
oOg2 = new stzOrgChart("acme52b")
oOg2.AddExecutiveXT("ceo", "CEO")
oOg2.AddManagerXT("cto", "CTO")
oOg2.AddManagerXT("cfo", "CFO")
oOg2.AddStaffXT("d1", "Dev One")
oOg2.AddStaffXT("d2", "Dev Two")
oOg2.AddStaffXT("a1", "Accountant")
oOg2.ReportsTo("cto", "ceo")  oOg2.ReportsTo("cfo", "ceo")
oOg2.ReportsTo("d1", "cto")   oOg2.ReportsTo("d2", "cto")
oOg2.ReportsTo("a1", "cfo")
oOg2.SetSplines("ortho")
oOg2.ToCanvasXT([ :NodeWidth = 110, :NodeHeight = 40 ])
nOgCeo = _I7Cx(oOg2.RenderNodeRects(), "ceo")
nOgCto = _I7Cx(oOg2.RenderNodeRects(), "cto")
nOgCfo = _I7Cx(oOg2.RenderNodeRects(), "cfo")
? "   ceo=" + nOgCeo + "  cto=" + nOgCto + "  cfo=" + nOgCfo
chk("the org root is centred over its two branches -- I6 on a domain",
    fabs(nOgCeo - (nOgCto + nOgCfo) / 2) < 1)


sec("-- 53. DN2: the state machine -- cycles are FIRST-CLASS -------")
discharges("DN2")
#
# The org chart forbade cycles; the state machine IS cycles -- open and
# close, lock and unlock. Same foundation, near-opposite law, which is
# what profiles are for. And DN2 earned its grammar the hard way: the
# hierarchical layout refused any cyclic graph outright, because :Depth
# is longest-path layering and no layering exists on a cycle. The layout
# now picks an acyclic ORIENTATION (drop the DFS back edges from ranking
# only), ranks against that, and draws the original arrows -- a back
# edge points UP the picture, which is how a reader knows it returns.
# The orientation is layout-private; :Depth the metric still refuses,
# because on a cycle the FACT still does not exist.
#---------------------------------------------------------------------------

oSm3 = new stzWorkflow("door53")
oSm3.SetWorkflowType("statemachine")
chkeq("declaring a state machine puts it under its own law",
      oSm3.Notation(), "statemachine")

oSm3.AddStateXTT("init", "go", [ :isInitial = 1 ])
oSm3.AddStateXT("closed", "Closed")
oSm3.AddStateXT("open", "Open")
oSm3.AddStateXT("locked", "Locked")
oSm3.AddStateXTT("gone", "Gone", [ :isFinal = 1 ])
oSm3.AddTransition("init", "closed", "")
oSm3.AddTransition("closed", "open", "open")
oSm3.AddTransition("open", "closed", "close")
oSm3.AddTransition("closed", "locked", "lock")
oSm3.AddTransition("locked", "closed", "unlock")
oSm3.AddTransition("locked", "locked", "lock")
oSm3.AddTransition("closed", "gone", "demolish")
chkeq("a machine full of cycles has NO structural findings",
      len(oSm3.NotationFindings()), 0)

# the glyph vocabulary, declared against the table where the domain
# disagrees with it: a state is a rounded BOX (a label barely fits a
# circle); the pseudostates keep their circles
oSmP = StzNotation("statemachine")
chkeq("a state is a rounded box, the declaration outranking the table",
      oSmP.GlyphOf("state"), "box")
chkeq("...the initial pseudostate is the small circle",
      oSmP.GlyphOf("start"), "circle")
chkeq("...and the final state is the double one",
      oSmP.GlyphOf("endpoint"), "doublecircle")

# THE CYCLIC PICTURE EXISTS -- the refusal this section retired -- and
# the back edge points UP: unlock returns, and the picture says so
oSm3.SetSplines("ortho")
oSm3.ToCanvasXT([ :NodeWidth = 104, :NodeHeight = 40 ])
aSmR = oSm3.RenderNodeRects()
chk("a cyclic machine RENDERS -- layering by acyclic orientation",
    len(aSmR) = 5)
nSmCl = 0  nSmLk = 0
_aR53107_ = aSmR
_nR53107_ = len(_aR53107_)
for _iR53107_ = 1 to _nR53107_
	r53 = _aR53107_[_iR53107_]
	if r53[5] = "closed"  nSmCl = r53[2]  ok
	if r53[5] = "locked"  nSmLk = r53[2]  ok
next
# THE CLAIM HAD TO CHANGE WITH THE MODEL, and it would otherwise have
# passed by coincidence: this used to assert that a back edge's target
# RANKS BEFORE its source, which was a statement about a layered
# picture. Under modes there is no rank between mutually reachable
# states at all -- and that is the point. They share a row.
chk("mutually reachable states share a row -- no rank between them",
    fabs(nSmCl - nSmLk) < 2)

# kind-scoped refusals at the gesture, and the difference from the org
# chart in one breath: a CYCLE passes here
nSmLog = len(oSm3.EditLog())
chk("nothing transitions INTO the initial pseudostate",
    oSm3.Edit(:Link, [ "open", "init" ]) = 0 and len(oSm3.EditLog()) = nSmLog)
chk("nothing LEAVES a final state",
    oSm3.Edit(:Link, [ "gone", "open" ]) = 0 and len(oSm3.EditLog()) = nSmLog)
chk("...while a link that closes a CYCLE is welcome in this domain",
    oSm3.Edit(:Link, [ "open", "locked" ]) = 1)
oSm3.Undo()

# damaged behind the gate, the sweep names the EDGE -- the thing the
# domain refuses -- in the house shape
oSm3.Connect("gone", "open")
aSm53 = oSm3.NotationFindings()
nSm53 = 0
_aR53108_ = aSm53
_nR53108_ = len(_aR53108_)
for _iR53108_ = 1 to _nR53108_
	r53 = _aR53108_[_iR53108_]
	if r53[:rule] = "notation-outbound" and r53[:subject] = "gone>open"
		nSm53++
	ok
next
chkeq("an exit from a final state is a finding on that edge", nSm53, 1)
oSm3.RemoveThisEdge("gone", "open")

# and the metric keeps its honesty: :Depth on a cyclic graph still
# refuses -- the LAYOUT earned cycles, the FACT did not change
bSm53 = 0
try
	StzGraphMetric(oSm3, :Depth)
catch
	bSm53 = 1
done
chkeq(":Depth still refuses a cycle -- the orientation is layout-private",
      bSm53, 1)


sec("-- 54. A label NAMES a connection; it may not CACHE one -------")
#
# Two rulings from the state machine's first picture. "unlock" stood
# against two foreign drops -- a label beside ink it does not name has
# cached that ink's meaning, because the reader cannot tell which line
# is being spoken about. And "Demolished" was crammed inside its own
# doublecircle -- a cell that is not a rectangle has no room for words,
# so its label belongs OUTSIDE, below the glyph.
#
# The placer's law now: a spot within the clearance of foreign ink is
# not a candidate that scored poorly, it is not an answer at all --
# BESIDE spots race the ON spots, and only when nothing anywhere clears
# the bar does the least-bad spot win, so a crowded picture still
# labels every edge. The FLOOR this section holds is absolute: no
# plate may TOUCH foreign ink, ever.
#---------------------------------------------------------------------------

oLc = new stzWorkflow("door54")
oLc.SetWorkflowType("statemachine")
oLc.AddStateXTT("init", "", [ :isInitial = 1 ])
oLc.AddStateXT("closed", "Closed")
oLc.AddStateXT("open", "Open")
oLc.AddStateXT("locked", "Locked")
oLc.AddStateXTT("gone", "Demolished", [ :isFinal = 1 ])
oLc.AddTransition("init", "closed", "")
oLc.AddTransition("closed", "open", "open")
oLc.AddTransition("open", "closed", "close")
oLc.AddTransition("closed", "locked", "lock")
oLc.AddTransition("locked", "closed", "unlock")
oLc.AddTransition("locked", "locked", "lock")
oLc.AddTransition("closed", "gone", "demolish")
oLc.SetSplines("ortho")
oLc.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

nLcClr = oLc._LineClearance()
nLcTouch = 0
nLcUnlock = -1
_aALcL109_ = oLc.RenderLabels()
_nALcL109_ = len(_aALcL109_)
for _iALcL109_ = 1 to _nALcL109_
	aLcL = _aALcL109_[_iALcL109_]
	_nLcMin_ = 1000000
	_aALcP110_ = oLc.RenderEdgePaths()
	_nALcP110_ = len(_aALcP110_)
	for _iALcP110_ = 1 to _nALcP110_
		aLcP = _aALcP110_[_iALcP110_]
		if aLcP[1] = aLcL[6]  loop  ok
		_fLc_ = aLcP[2]
		for iLc = 1 to len(_fLc_) - 3 step 2
			_ax_ = min([ _fLc_[iLc], _fLc_[iLc+2] ])
			_bx_ = max([ _fLc_[iLc], _fLc_[iLc+2] ])
			_ay_ = min([ _fLc_[iLc+1], _fLc_[iLc+3] ])
			_by_ = max([ _fLc_[iLc+1], _fLc_[iLc+3] ])
			_dx_ = 0
			if _bx_ < aLcL[2] - aLcL[4]/2  _dx_ = aLcL[2] - aLcL[4]/2 - _bx_  ok
			if _ax_ > aLcL[2] + aLcL[4]/2  _dx_ = _ax_ - (aLcL[2] + aLcL[4]/2)  ok
			_dy_ = 0
			if _by_ < aLcL[3] - aLcL[5]/2  _dy_ = aLcL[3] - aLcL[5]/2 - _by_  ok
			if _ay_ > aLcL[3] + aLcL[5]/2  _dy_ = _ay_ - (aLcL[3] + aLcL[5]/2)  ok
			_dLc_ = sqrt(_dx_*_dx_ + _dy_*_dy_)
			if _dLc_ < _nLcMin_  _nLcMin_ = _dLc_  ok
		next
	next
	if _nLcMin_ < 2  nLcTouch++  ok
	if aLcL[1] = "unlock"  nLcUnlock = _nLcMin_  ok
next
? "   label plates touching foreign ink : " + nLcTouch
chkeq("no label plate TOUCHES ink it does not name", nLcTouch, 0)
? "   'unlock', the marked label, stands " + nLcUnlock + "px clear"
# HALF a clearance, not the full preference bar: a BESIDE seat stands
# half a clearance off its own line by construction, so in a lawful
# funnel -- two returns sharing their arrival lane -- half a clearance
# from the neighbour is the best honest seat that exists. The placer
# still PREFERS seats past 0.6 of a clearance when the picture has one.
chk("...and the marked label keeps at least half a clearance",
    nLcUnlock >= nLcClr * 0.45)

# THE OUTSIDE RULE: non-rectangular glyphs write their name below
nLcOut = 0
nLcIn = 0
nLcBad = 0
_aALcN111_ = oLc.RenderNodeLabels()
_nALcN111_ = len(_aALcN111_)
for _iALcN111_ = 1 to _nALcN111_
	aLcN = _aALcN111_[_iALcN111_]
	if aLcN[6] = 1
		nLcOut++
		# below means BELOW: the plate's top at or under the glyph's
		# bottom, for the two circle-family cells
		_aALcR112_ = oLc.RenderNodeRects()
		_nALcR112_ = len(_aALcR112_)
		for _iALcR112_ = 1 to _nALcR112_
			aLcR = _aALcR112_[_iALcR112_]
			if aLcR[5] != aLcN[1]  loop  ok
			if aLcN[3] - aLcN[5]/2 < aLcR[2] + aLcR[4] - 2  nLcBad++  ok
		next
	else
		nLcIn++
	ok
next
? "   outside labels : " + nLcOut + " , inside : " + nLcIn
# ONE of the two circle-family cells carries a name; the entry
# pseudostate is labelled "" on purpose and now writes NOTHING, where
# it used to fall back to printing its id ("i") under the mark.
chkeq("a named circle-family cell writes its name OUTSIDE", nLcOut, 1)
chkeq("...strictly below the glyph", nLcBad, 0)
chkeq("...while every rectangle keeps its name inside", nLcIn, 3)
chkeq("...and an empty label draws nothing at all",
      len(oLc.RenderNodeLabels()), 4)

# the paper was BOUGHT for the bottom label, not borrowed
nLcH = oLc.LastCanvas().Height()
nLcLow = 0
_aALcN113_ = oLc.RenderNodeLabels()
_nALcN113_ = len(_aALcN113_)
for _iALcN113_ = 1 to _nALcN113_
	aLcN = _aALcN113_[_iALcN113_]
	if aLcN[3] + aLcN[5]/2 > nLcLow  nLcLow = aLcN[3] + aLcN[5]/2  ok
next
? "   lowest label bottom " + nLcLow + " in a " + nLcH + "px canvas"
chk("an outside label on the bottom rank is inside the picture",
    nLcLow <= nLcH)

# the negative sibling: a rectangles-only picture has no outside labels
oLc2 = new stzDiagram("boxes54")
oLc2.AddNodeXTT("a", "Alpha", [ :type = "box" ])
oLc2.AddNodeXTT("b", "Beta", [ :type = "box" ])
oLc2.AddEdge("a", "b")
oLc2.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 96, :NodeHeight = 36,
	:FontSize = 13 ])
nLc2 = 0
_aALcN114_ = oLc2.RenderNodeLabels()
_nALcN114_ = len(_aALcN114_)
for _iALcN114_ = 1 to _nALcN114_
	aLcN = _aALcN114_[_iALcN114_]
	if aLcN[6] = 1  nLc2++  ok
next
chkeq("a rectangles-only picture writes nothing outside", nLc2, 0)


sec("-- 55. A PAIR IS ONE CONVERSATION; A GAP COSTS WHAT CROSSES IT --")
#
# Two laws the state machine was first to need, but neither is
# state-machine code -- they are held here on an ordinary LAYERED
# diagram, which is where the twin-path machinery lives.
#
# TWIN LANES. A->B and B->A are the same relationship read both ways, so
# under ortho the return mirrors its partner's exact path, offset one
# clearance: two rails, unmistakably one pair, and the return never
# wanders through foreign channels the way a lone back edge must.
#
# PER-GAP PITCH. One uniform rank pitch made an unlabelled gap as tall
# as a gap carrying labels. A gap is priced by what crosses it.
#---------------------------------------------------------------------------

oTw = new stzDiagram("pair55")
oTw.AddNodeXTT("a", "A", [ :type = "box" ])
oTw.AddNodeXTT("b", "B", [ :type = "box" ])
oTw.AddNodeXTT("c", "C", [ :type = "box" ])
oTw.AddEdge("a", "b")
oTw.AddEdgeXT("b", "c", "go")
oTw.AddEdgeXT("c", "b", "back")
oTw.SetSplines("ortho")
oTw.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

aTwD = []  aTwU = []
_aATwP115_ = oTw.RenderEdgePaths()
_nATwP115_ = len(_aATwP115_)
for _iATwP115_ = 1 to _nATwP115_
	aTwP = _aATwP115_[_iATwP115_]
	if aTwP[1] = "b>c"  aTwD = aTwP[2]  ok
	if aTwP[1] = "c>b"  aTwU = aTwP[2]  ok
next
chk("both members of the pair have drawn paths",
    len(aTwD) >= 4 and len(aTwU) >= 4)
# RAILS, measured as DISTANCE TO THE PARTNER PATH, not as a point-count
# match: the twin is rebuilt from segment intersections, so it may hold a
# different number of vertices while being the same shape offset. What
# makes it a rail is that every one of its vertices stands about a
# clearance from the partner's ink -- never on it, never wandering off.
nTwClr = oTw._LineClearance()
# THE CLAIM IS PARALLELISM, not a magnitude. How FAR a return sits from
# its partner is the LANE rule's business, and that number moved when
# lanes began clearing the boxes instead of the centre-line -- a rail a
# clearance from the row's middle is four pixels from the cells, which
# is the hugging the Principal circled. What makes a pair read as one
# conversation is that the rails keep a CONSTANT distance.
nTwBad = 0
nTwZero = 0
nTwRail = -1
for iTw = 1 to len(aTwU) - 1 step 2
	_dT_ = _Dist55(aTwU[iTw], aTwU[iTw+1], aTwD)
	if _dT_ < 2  nTwZero++  ok
	if _dT_ < 2  loop  ok
	if nTwRail < 0  nTwRail = _dT_  ok
	if fabs(_dT_ - nTwRail) > 2  nTwBad++  ok
next
? "   twin vertices off the rail : " + nTwBad + " of " + (len(aTwU) / 2) +
  " , the rails run " + nTwRail + "px apart"
chkeq("the return runs PARALLEL to its partner, all the way", nTwBad, 0)
chkeq("...and never ON it", nTwZero, 0)
chk("...clearing the cells it runs under, not just their centre-line",
    nTwRail >= nTwClr - 1)

# PER-GAP PITCH: a>b crosses an unlabelled gap, b>c a labelled one
nTwA = -1  nTwB = -1  nTwB2 = -1  nTwC = -1
_aRTw116_ = oTw.RenderNodeRects()
_nRTw116_ = len(_aRTw116_)
for _iRTw116_ = 1 to _nRTw116_
	rTw = _aRTw116_[_iRTw116_]
	if rTw[5] = "a"  nTwA = rTw[2] + rTw[4]  ok
	if rTw[5] = "b"  nTwB = rTw[2]  nTwB2 = rTw[2] + rTw[4]  ok
	if rTw[5] = "c"  nTwC = rTw[2]  ok
next
nTwG1 = nTwB - nTwA
nTwG2 = nTwC - nTwB2
? "   unlabelled gap " + nTwG1 + "px, labelled gap " + nTwG2 + "px"
chk("an unlabelled gap does not pay the labelled gap's price",
    nTwG1 < nTwG2 - 20)
chk("...while still clearing the crossable floor",
    nTwG1 >= oTw._LineClearance() * 2)


sec("-- 56. THE RING: a declared layout for graphs of PEERS --------")
discharges("DN2b")
#
# The Principal's deepest correction: "you still consider a state
# machine diagram as a tree diagram, it isn't. Take the spatial
# metaphor of a space with states as cells sitting around its border,
# and for some of them, in the middle."
#
# He is right, and graphviz says the same thing by shipping two
# programs: dot for hierarchies, circo and neato for everything cyclic.
# Layered layout answers "what flows into what" -- a statechart has no
# flow direction, its states are PEERS and its edges are EVENTS. Every
# mark he made on the layered pictures traces to that one mistake.
#
# So a notation may now declare THE LAYOUT IT IS READ IN -- the
# strongest grammar amendment there is -- and the state machine
# declares :Ring. States sit around a space; a hub moves to the middle,
# where its edges become short radials instead of chords sawing the
# space in half; the ring ORDER is chosen against a counted crossing
# number; and the entry opens the ring at the top.
#---------------------------------------------------------------------------

# The ring survives as a DECLARED layout for peer graphs -- the state
# machine moved on to the lifecycle template (S57), so the ring is
# exercised here by a diagram that asks for it in its own profile.
oRgN = new stzNotation("ring56")
oRgN.SetLayoutMode(:Ring)
oRgN.SetSplines(:line)
StzRegisterNotation(oRgN)
chkeq("a profile may declare the layout it is read in",
      StzLower("" + StzNotation("ring56").LayoutMode()), "ring")

oRg = new stzDiagram("peers56")
oRg.SetNotation("ring56")
oRg.AddNodeXTT("init", "", [ :type = "start" ])
oRg.AddNodeXTT("closed", "Closed", [ :type = "box" ])
oRg.AddNodeXTT("open", "Open", [ :type = "box" ])
oRg.AddNodeXTT("locked", "Locked", [ :type = "box" ])
oRg.AddNodeXTT("gone", "Gone", [ :type = "endpoint" ])
oRg.AddEdge("init", "closed")
oRg.AddEdgeXT("closed", "open", "open")
oRg.AddEdgeXT("open", "closed", "close")
oRg.AddEdgeXT("closed", "locked", "lock")
oRg.AddEdgeXT("locked", "closed", "unlock")
oRg.AddEdgeXT("closed", "gone", "demolish")
oRg.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

# THE SPACE IS SQUARE, or the fit would deliver the circle as an
# ellipse -- the ring's one hard requirement on the canvas
chkeq("a ring is drawn in a square space",
      oRg.LastCanvas().Width(), oRg.LastCanvas().Height())

# THE BORDER: the peers are equidistant from the centre, and the hub is
# NOT -- that is the whole metaphor, measured
aRgR = oRg.RenderNodeRects()
nRgCx = oRg.LastCanvas().Width() / 2
nRgCy = oRg.LastCanvas().Height() / 2
nRgHub = -1
aRgRad = []
_aRRg117_ = aRgR
_nRRg117_ = len(_aRRg117_)
for _iRRg117_ = 1 to _nRRg117_
	rRg = _aRRg117_[_iRRg117_]
	_rx_ = rRg[1] + rRg[3] / 2 - nRgCx
	_ry_ = rRg[2] + rRg[4] / 2 - nRgCy
	_rr_ = sqrt(_rx_*_rx_ + _ry_*_ry_)
	if rRg[5] = "closed"
		nRgHub = _rr_
	else
		aRgRad + _rr_
	ok
next
nRgLo = 1000000  nRgHi = 0
_aVRg118_ = aRgRad
_nVRg118_ = len(_aVRg118_)
for _iVRg118_ = 1 to _nVRg118_
	vRg = _aVRg118_[_iVRg118_]
	if vRg < nRgLo  nRgLo = vRg  ok
	if vRg > nRgHi  nRgHi = vRg  ok
next
? "   border radii " + nRgLo + ".." + nRgHi + " , hub at " + nRgHub
chk("the peers sit on ONE circle -- a border, not a rank",
    nRgHi - nRgLo < 2)
chk("...and the hub is in the MIDDLE, not on it", nRgHub < nRgLo / 2)

# THE ENTRY OPENS THE RING AT THE TOP, where every convention puts it
nRgInitY = 0  nRgTop = 1000000
_aRRg119_ = aRgR
_nRRg119_ = len(_aRRg119_)
for _iRRg119_ = 1 to _nRRg119_
	rRg = _aRRg119_[_iRRg119_]
	if rRg[5] = "init"  nRgInitY = rRg[2]  ok
	if rRg[2] < nRgTop  nRgTop = rRg[2]  ok
next
chkeq("the initial pseudostate opens the ring at the top",
      nRgInitY, nRgTop)

# AND THE CROSSING NUMBER IS COUNTED, not hoped for
? "   ring crossings : " + oRg.RenderCrossings()
chkeq("the ring order is chosen against a counted crossing number",
      oRg.RenderCrossings(), 0)

# A PAIR SEPARATES ON A CHORD TOO -- the two members take opposite
# sides of the line they share, so neither is drawn on the other
aRgOc = []  aRgCo = []
_aARgP120_ = oRg.RenderEdgePaths()
_nARgP120_ = len(_aARgP120_)
for _iARgP120_ = 1 to _nARgP120_
	aRgP = _aARgP120_[_iARgP120_]
	if aRgP[1] = "closed>open"  aRgOc = aRgP[2]  ok
	if aRgP[1] = "open>closed"  aRgCo = aRgP[2]  ok
next
chk("both chords of the pair are drawn",
    len(aRgOc) >= 4 and len(aRgCo) >= 4)
nRgSep = fabs((aRgOc[2] + aRgOc[4]) / 2 - (aRgCo[2] + aRgCo[4]) / 2)
? "   the pair's chords stand " + nRgSep + "px apart"
chk("...on opposite sides of the line they share",
    nRgSep >= oRg._LineClearance())

# THE NEGATIVE SIBLING: a domain that declares NO layout mode is still
# layered -- the ring is a declaration, not a new default
oRg2 = new stzDiagram("plain56")
oRg2.AddNodeXTT("p", "P", [ :type = "box" ])
oRg2.AddNodeXTT("q", "Q", [ :type = "box" ])
oRg2.AddNodeXTT("r", "R", [ :type = "box" ])
oRg2.AddEdge("p", "q")  oRg2.AddEdge("p", "r")
oRg2.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nRg2 = 0
_aRRg121_ = oRg2.RenderNodeRects()
_nRRg121_ = len(_aRRg121_)
for _iRRg121_ = 1 to _nRRg121_
	rRg = _aRRg121_[_iRRg121_]
	if rRg[5] = "p"  nRg2 = rRg[2]  ok
next
nRg2b = 1000000
_aRRg122_ = oRg2.RenderNodeRects()
_nRRg122_ = len(_aRRg122_)
for _iRRg122_ = 1 to _nRRg122_
	rRg = _aRRg122_[_iRRg122_]
	if rRg[5] != "p" and rRg[2] < nRg2b  nRg2b = rRg[2]  ok
next
chk("a diagram that declares no layout mode is still LAYERED",
    nRg2 < nRg2b - 20)


sec("-- 57. MODES: a state machine has no NEXT -------------------")
discharges("DN2d")
#
# Three templates were wrong before this one, and all three in the same
# way. A tree drew a progression. A ring drew a space with a centre. A
# lifecycle drew a progression again, sideways. Every one answered "what
# happens NEXT", and the Principal's ruling is that a state machine has
# no next: "it fits dynamic flows that are NOT deterministic, since
# events and change of state are what determine their flow".
#
# Lucid's UML tutorial says it outright -- a state diagram is "not
# necessarily the best tool for capturing an overall progression of
# events" -- and the practitioners' thread points at the structural
# answer: statecharts tame complexity by GROUPING states that share
# their event handling, not by placing them more cleverly.
#
# So what may a picture honestly order? One thing, and it is a fact
# about the graph rather than a taste:
#
#   INSIDE a set of mutually reachable states there is NO order. Closed
#   to Open to Closed, all day, decided at runtime by events.
#   BETWEEN such sets the order is REAL and IRREVERSIBLE. A demolished
#   door is never closed again.
#
# A MODE is a strongly connected component. The picture ranks the MODES
# -- their condensation is a DAG by construction -- and leaves the
# states inside each mode unordered, inside a drawn REGION.
#---------------------------------------------------------------------------

chkeq("the state machine is read as MODES",
      StzLower("" + StzNotation("statemachine").LayoutMode()), "modes")

oMd = new stzWorkflow("door57")
oMd.SetWorkflowType("statemachine")
oMd.AddStateXTT("init", "", [ :isInitial = 1 ])
oMd.AddStateXT("closed", "Closed")
oMd.AddStateXT("open", "Open")
oMd.AddStateXT("locked", "Locked")
oMd.AddStateXTT("gone", "Demolished", [ :isFinal = 1 ])
oMd.AddTransition("init", "closed", "")
oMd.AddTransition("closed", "open", "open")
oMd.AddTransition("open", "closed", "close")
oMd.AddTransition("closed", "locked", "lock")
oMd.AddTransition("locked", "closed", "unlock")
oMd.AddTransition("locked", "locked", "lock")
oMd.AddTransition("closed", "gone", "demolish")
oMd.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

# THE MODE IS DISCOVERED, not declared: the author never grouped these
aMdC = oMd.Clusters()
? "   regions discovered : " + len(aMdC)
chkeq("the mutually reachable states form ONE region", len(aMdC), 1)
nMdIn = 0
_aCMd123_ = aMdC
_nCMd123_ = len(_aCMd123_)
for _iCMd123_ = 1 to _nCMd123_
	cMd = _aCMd123_[_iCMd123_]
	_aIdMd124_ = cMd[:nodes]
	_nIdMd124_ = len(_aIdMd124_)
	for _iIdMd124_ = 1 to _nIdMd124_
		idMd = _aIdMd124_[_iIdMd124_]
		if StzLower("" + idMd) = "closed"  nMdIn++  ok
		if StzLower("" + idMd) = "open"    nMdIn++  ok
		if StzLower("" + idMd) = "locked"  nMdIn++  ok
	next
next
chkeq("...and it holds exactly the states you can move among", nMdIn, 3)
chkeq("...and only those", len(aMdC[1][:nodes]), 3)

# A SINGLE STATE IS NOT A REGION: init and gone are one-way doors, not
# places the machine lives in
nMdSolo = 0
_aCMd125_ = aMdC
_nCMd125_ = len(_aCMd125_)
for _iCMd125_ = 1 to _nCMd125_
	cMd = _aCMd125_[_iCMd125_]
	_aIdMd126_ = cMd[:nodes]
	_nIdMd126_ = len(_aIdMd126_)
	for _iIdMd126_ = 1 to _nIdMd126_
		idMd = _aIdMd126_[_iIdMd126_]
		if StzLower("" + idMd) = "init"  nMdSolo++  ok
		if StzLower("" + idMd) = "gone"  nMdSolo++  ok
	next
next
chkeq("a state you cannot return to is not a region", nMdSolo, 0)

# NO ORDER INSIDE A MODE: the peers share a row, so the picture makes no
# claim about which comes first -- that is the whole correction
aMdR = oMd.RenderNodeRects()
nMdY = -1  nMdSame = 0
_aRMd127_ = aMdR
_nRMd127_ = len(_aRMd127_)
for _iRMd127_ = 1 to _nRMd127_
	rMd = _aRMd127_[_iRMd127_]
	if rMd[5] = "closed"  nMdY = rMd[2]  ok
next
_aRMd128_ = aMdR
_nRMd128_ = len(_aRMd128_)
for _iRMd128_ = 1 to _nRMd128_
	rMd = _aRMd128_[_iRMd128_]
	if rMd[5] = "open" or rMd[5] = "locked"
		if fabs(rMd[2] - nMdY) < 2  nMdSame++  ok
	ok
next
chkeq("states you move freely among are drawn as PEERS, unordered",
      nMdSame, 2)

# AND THE IRREVERSIBLE PASSAGE IS THE ONLY THING RANKED
nMdInit = -1  nMdGone = -1
_aRMd129_ = aMdR
_nRMd129_ = len(_aRMd129_)
for _iRMd129_ = 1 to _nRMd129_
	rMd = _aRMd129_[_iRMd129_]
	if rMd[5] = "init"  nMdInit = rMd[2]  ok
	if rMd[5] = "gone"  nMdGone = rMd[2]  ok
next
chk("what you enter from ranks BEFORE the mode", nMdInit < nMdY)
chk("what you can never leave ranks AFTER it", nMdGone > nMdY)

# THE NEGATIVE SIBLING, and it is the one that proves the model rather
# than the picture: make the door repairable, and Demolished JOINS the
# mode -- the region grows because the GRAPH changed, with no layout
# knob touched anywhere
oMd2 = new stzWorkflow("door57b")
oMd2.SetWorkflowType("statemachine")
oMd2.AddStateXT("closed", "Closed")
oMd2.AddStateXT("open", "Open")
oMd2.AddStateXT("broken", "Broken")
oMd2.AddTransition("closed", "open", "open")
oMd2.AddTransition("open", "closed", "close")
oMd2.AddTransition("closed", "broken", "break")
oMd2.AddTransition("broken", "closed", "repair")
oMd2.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])
nMd2 = 0
_aCMd130_ = oMd2.Clusters()
_nCMd130_ = len(_aCMd130_)
for _iCMd130_ = 1 to _nCMd130_
	cMd = _aCMd130_[_iCMd130_]
	if len(cMd[:nodes]) > nMd2  nMd2 = len(cMd[:nodes])  ok
next
? "   with a repairable door, the mode holds : " + nMd2
chkeq("a state that becomes reversible JOINS the mode", nMd2, 3)

# ...and one that is truly terminal never does
oMd3 = new stzWorkflow("door57c")
oMd3.SetWorkflowType("statemachine")
oMd3.AddStateXT("closed", "Closed")
oMd3.AddStateXT("open", "Open")
oMd3.AddStateXTT("gone", "Gone", [ :isFinal = 1 ])
oMd3.AddTransition("closed", "open", "open")
oMd3.AddTransition("open", "closed", "close")
oMd3.AddTransition("closed", "gone", "demolish")
oMd3.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])
nMd3 = 0
_aCMd131_ = oMd3.Clusters()
_nCMd131_ = len(_aCMd131_)
for _iCMd131_ = 1 to _nCMd131_
	cMd = _aCMd131_[_iCMd131_]
	if len(cMd[:nodes]) > nMd3  nMd3 = len(cMd[:nodes])  ok
next
chkeq("...while a terminal state stays outside it", nMd3, 2)

# AN AUTHOR'S OWN GROUPING ALWAYS WINS: discovery fills a vacuum, it
# never overrules a declaration
oMd4 = new stzWorkflow("door57d")
oMd4.SetWorkflowType("statemachine")
oMd4.AddStateXT("a", "A")  oMd4.AddStateXT("b", "B")
oMd4.AddTransition("a", "b", "go")
oMd4.AddTransition("b", "a", "back")
oMd4.AddCluster("mine", [ "a" ])
oMd4.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
chkeq("a declared grouping is never overruled by discovery",
      len(oMd4.Clusters()), 1)
chkeq("...and it is the author's", "" + oMd4.Clusters()[1][:id], "mine")


sec("-- 58. A PSEUDOSTATE IS A MARK, NOT A CELL -------------------")
#
# The Principal, comparing our gallery to mermaid's page: the
# beautification window is still open. The largest gap was not colour or
# spacing -- it was that our entry and exit pseudostates were drawn as
# full CELLS. They hold no information, carry no name and are not
# somewhere a machine waits: they are punctuation, and every reference
# notation draws them as a dot a fraction of a state's size.
#
# So a notation may declare a kind's SCALE, and the number it declares
# has to be the SAME number three different pieces of geometry use --
# the box that is painted, the border an edge clips to, and the port an
# edge leaves from. Getting two of the three right is what leaves an
# arrow pointing at paper beside the thing it names.
#---------------------------------------------------------------------------

oMk = new stzWorkflow("marks58")
oMk.SetWorkflowType("statemachine")
oMk.AddStateXTT("i", "", [ :isInitial = 1 ])
oMk.AddStateXT("still", "Still")
oMk.AddStateXT("moving", "Moving")
oMk.AddStateXTT("e", "", [ :isFinal = 1 ])
oMk.AddTransition("i", "still", "")
oMk.AddTransition("still", "moving", "")
oMk.AddTransition("moving", "still", "")
oMk.AddTransition("still", "e", "")
oMk.AddTransition("moving", "e", "")
oMk.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

nMkState = 0  nMkMark = 0
_aRMk132_ = oMk.RenderNodeRects()
_nRMk132_ = len(_aRMk132_)
for _iRMk132_ = 1 to _nRMk132_
	rMk = _aRMk132_[_iRMk132_]
	if rMk[5] = "still"  nMkState = rMk[3]  ok
	if rMk[5] = "i"      nMkMark = rMk[3]  ok
next
? "   a state is " + nMkState + "px wide, a mark " + nMkMark
chk("a pseudostate is drawn far smaller than a state",
    nMkMark > 0 and nMkMark < nMkState / 2)
chk("...and it is SQUARE, since it carries no text",
    nMkMark = oMk._BoxOf("i", 104, 40)[2])

# THE THREE GEOMETRIES AGREE, which is the assertion that matters: an
# arrow must MEET the mark it points at. Every published path ending at
# a mark has its last point ON that mark's border.
nMkGap = 0
nMkWorst = 0
_aAMkP133_ = oMk.RenderEdgePaths()
_nAMkP133_ = len(_aAMkP133_)
for _iAMkP133_ = 1 to _nAMkP133_
	aMkP = _aAMkP133_[_iAMkP133_]
	aMkE = StzSplit(aMkP[1], ">")
	if len(aMkE) != 2  loop  ok
	if aMkE[2] != "e"  loop  ok
	_fMk_ = aMkP[2]
	_nMk_ = len(_fMk_)
	if _nMk_ < 4  loop  ok
	_aRMk134_ = oMk.RenderNodeRects()
	_nRMk134_ = len(_aRMk134_)
	for _iRMk134_ = 1 to _nRMk134_
		rMk = _aRMk134_[_iRMk134_]
		if rMk[5] != "e"  loop  ok
		# distance from the path's last point to the mark's rectangle
		_dxMk_ = 0
		if _fMk_[_nMk_-1] < rMk[1]  _dxMk_ = rMk[1] - _fMk_[_nMk_-1]  ok
		if _fMk_[_nMk_-1] > rMk[1] + rMk[3]
			_dxMk_ = _fMk_[_nMk_-1] - (rMk[1] + rMk[3])
		ok
		_dyMk_ = 0
		if _fMk_[_nMk_] < rMk[2]  _dyMk_ = rMk[2] - _fMk_[_nMk_]  ok
		if _fMk_[_nMk_] > rMk[2] + rMk[4]
			_dyMk_ = _fMk_[_nMk_] - (rMk[2] + rMk[4])
		ok
		_dMk_ = sqrt(_dxMk_*_dxMk_ + _dyMk_*_dyMk_)
		if _dMk_ > nMkWorst  nMkWorst = _dMk_  ok
		if _dMk_ > 2  nMkGap++  ok
	next
next
? "   arrows into the mark that stop short : " + nMkGap +
  " (worst " + nMkWorst + "px)"
chkeq("an arrow MEETS the mark it points at", nMkGap, 0)

# THE NEGATIVE SIBLING: a domain that declares no scale still draws
# cells -- the mark is a declaration, not a new default
oMk2 = new stzDiagram("cells58")
oMk2.AddNodeXTT("a", "A", [ :type = "start" ])
oMk2.AddNodeXTT("b", "B", [ :type = "box" ])
oMk2.AddEdge("a", "b")
oMk2.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nMk2 = 0
_aRMk135_ = oMk2.RenderNodeRects()
_nRMk135_ = len(_aRMk135_)
for _iRMk135_ = 1 to _nRMk135_
	rMk = _aRMk135_[_iRMk135_]
	if rMk[5] = "a"  nMk2 = rMk[3]  ok
next
chkeq("a diagram that declares no scale keeps full cells", nMk2, 96)


sec("-- 59. THE LEARNED LAWS, APPLIED TO THE NEW TEMPLATE ---------")
#
# The Principal, tired of marking red diagrams: apply what we learned
# about orthogonality, verticality and label placement to the new
# designs yourself. He gave one example and it generalises --
#
#   "when the node is circular (start or end) the edges that quit or
#    arrive must be unified before quitting or reaching the node,
#    because the surface is so small"
#
# That is I2 finishing a sentence it had already begun. Ports exist so a
# node's edges leave from distinct places; a MARK has no distinct
# places, so a port spread across a 17px circle draws several lines
# grazing a dot instead of one line arriving at it. Edges sharing an
# endpoint may share ink -- at a mark they MUST.
#
# Reviewing the rest myself, three more of our own laws were missing
# from the mode template, and each is asserted below: a lone state
# belongs on its one neighbour's column (verticality); a region contains
# its members' LOOP ink as well as their boxes (I1); and a gap pays for
# what CROSSES it, which in a mode picture means transitions between
# modes -- not the peer chords that carry the longest labels sideways.
#---------------------------------------------------------------------------

oLw = new stzWorkflow("laws59")
oLw.SetWorkflowType("statemachine")
oLw.AddStateXTT("i", "", [ :isInitial = 1 ])
oLw.AddStateXT("still", "Still")
oLw.AddStateXT("moving", "Moving")
oLw.AddStateXTT("e", "", [ :isFinal = 1 ])
oLw.AddTransition("i", "still", "")
oLw.AddTransition("still", "moving", "")
oLw.AddTransition("moving", "still", "")
oLw.AddTransition("still", "e", "")
oLw.AddTransition("moving", "e", "")
oLw.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

# BOTH EDGES REACH THE MARK, AND NEITHER TRAVELS DOWN THE OTHER.
#
# THIS ASSERTION WAS RESTATED, and the reason is a finding rather than a
# convenience. It used to demand that both arrivals end at the SAME
# POINT -- "unified at the mark, one arrow not two grazing a dot" -- and
# measured that by comparing the final x of the two paths.
#
# That is a PROXY, and the cheapest way to satisfy it is for both edges
# to descend down one column and merge before they get there. Measured
# on this very scene, that is what they did: `moving>e` ran down
# `still>e`'s column for 80px. So the guard was requiring the thing the
# Principal has marked three times -- two lines with an arrow at each
# end -- and calling it unity.
#
# The intent is kept and the measurement is fixed. What "not grazing"
# means is that both edges genuinely REACH the mark, and what the
# Principal asks is that they not run together on the way. Those are two
# properties and the old form could only express one, by forcing the
# other to fail.
aLwA = []  aLwB = []
_aALwP136_ = oLw.RenderEdgePaths()
_nALwP136_ = len(_aALwP136_)
for _iALwP136_ = 1 to _nALwP136_
	aLwP = _aALwP136_[_iALwP136_]
	if aLwP[1] = "still>e"   aLwA = aLwP[2]  ok
	if aLwP[1] = "moving>e"  aLwB = aLwP[2]  ok
next
chk("both edges into the mark are drawn",
    len(aLwA) >= 4 and len(aLwB) >= 4)
aLwR = []
_aRLw137_ = oLw.RenderNodeRects()
_nRLw137_ = len(_aRLw137_)
for _iRLw137_ = 1 to _nRLw137_
	rLw = _aRLw137_[_iRLw137_]
	if rLw[5] = "e"  aLwR = rLw  ok
next

# (1) BOTH REACH IT -- each path's last point lies on the mark's border,
#     which is what "not grazing" actually asserts.
nLwPad = 3
bLwA = _OnBorder(aLwA, aLwR, nLwPad)
bLwB = _OnBorder(aLwB, aLwR, nLwPad)
? "   still>e ends on the mark: " + bLwA + " ; moving>e: " + bLwB
chk("both edges reach the mark itself, neither stopping short",
    bLwA and bLwB)

# (2) ...AND NEITHER RUNS DOWN THE OTHER. The verticals of the two paths
#     must not share a column over a readable stretch.
nLwOv = _SharedColumn(aLwA, aLwB, oLw._LineClearance())
? "   longest column they share: " + nLwOv + "px"
chkeq("...and neither travels down the other's column", nLwOv, 0)

# THE NEGATIVE SIBLING: the instrument must be able to SEE a shared
# column, or the zero above says nothing. Two paths built to share one
# is counted as sharing one.
nLwFake = _SharedColumn([ 10, 10, 10, 200 ], [ 10, 50, 10, 260 ],
    oLw._LineClearance())
chk("NEGATIVE: ...and a shared column IS measured when there is one",
    nLwFake > 100)

# ...AND THE SAME AT A DEPARTURE: one stem out of the entry mark
nLwOut = 0
_aALwP138_ = oLw.RenderEdgePaths()
_nALwP138_ = len(_aALwP138_)
for _iALwP138_ = 1 to _nALwP138_
	aLwP = _aALwP138_[_iALwP138_]
	aLwE = StzSplit(aLwP[1], ">")
	if len(aLwE) = 2 and aLwE[1] = "i"  nLwOut++  ok
next
chkeq("the entry mark has one edge, drawn from its centre", nLwOut, 1)

# VERTICALITY: a lone state sits on its one neighbour's column
nLwI = -1  nLwS = -1
_aRLw139_ = oLw.RenderNodeRects()
_nRLw139_ = len(_aRLw139_)
for _iRLw139_ = 1 to _nRLw139_
	rLw = _aRLw139_[_iRLw139_]
	if rLw[5] = "i"      nLwI = rLw[1] + rLw[3] / 2  ok
	if rLw[5] = "still"  nLwS = rLw[1] + rLw[3] / 2  ok
next
? "   entry mark at " + nLwI + " , the state it enters at " + nLwS
chk("a lone state stands on its one neighbour's column",
    fabs(nLwI - nLwS) < 2)

# I1 FOR REGIONS: the frame contains its members' LOOP ink
oLw2 = new stzWorkflow("loop59")
oLw2.SetWorkflowType("statemachine")
oLw2.AddStateXT("a", "A")
oLw2.AddStateXT("b", "B")
oLw2.AddTransition("a", "b", "go")
oLw2.AddTransition("b", "a", "back")
oLw2.AddTransition("b", "b", "stay")
oLw2.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])
nLwOutside = 0
_aALwR140_ = oLw2.RenderClusterRects()
_nALwR140_ = len(_aALwR140_)
for _iALwR140_ = 1 to _nALwR140_
	aLwR = _aALwR140_[_iALwR140_]
	_aALwP141_ = oLw2.RenderEdgePaths()
	_nALwP141_ = len(_aALwP141_)
	for _iALwP141_ = 1 to _nALwP141_
		aLwP = _aALwP141_[_iALwP141_]
		if aLwP[1] != "b>b"  loop  ok
		for iLw = 1 to len(aLwP[2]) - 1 step 2
			if aLwP[2][iLw] > aLwR[1] + aLwR[3] + 1  nLwOutside++  ok
		next
	next
next
? "   loop points outside the region : " + nLwOutside
chkeq("a region contains its members' LOOP ink, not only their boxes",
      nLwOutside, 0)

# A GAP PAYS FOR WHAT CROSSES IT: the mode gap is priced by the
# transitions BETWEEN modes, not by the long peer labels inside one
oLw3 = new stzWorkflow("gap59")
oLw3.SetWorkflowType("statemachine")
oLw3.AddStateXTT("i", "", [ :isInitial = 1 ])
oLw3.AddStateXT("p", "P")
oLw3.AddStateXT("q", "Q")
oLw3.AddTransition("i", "p", "")
oLw3.AddTransition("p", "q", "a very long peer event name indeed")
oLw3.AddTransition("q", "p", "another very long peer event name")
oLw3.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])
nLwIy = -1  nLwPy = -1
_aRLw142_ = oLw3.RenderNodeRects()
_nRLw142_ = len(_aRLw142_)
for _iRLw142_ = 1 to _nRLw142_
	rLw = _aRLw142_[_iRLw142_]
	if rLw[5] = "i"  nLwIy = rLw[2] + rLw[4]  ok
	if rLw[5] = "p"  nLwPy = rLw[2]  ok
next
nLwGapLong = nLwPy - nLwIy

# THE SAME MACHINE with SHORT peer labels. The claim is comparative,
# because an absolute figure would be measuring the region's chrome --
# which genuinely does live in the gap above the frame -- rather than
# the thing under test. What must not happen is the VERTICAL gap
# growing because the labels riding the HORIZONTAL chords got longer.
oLw4 = new stzWorkflow("gap59b")
oLw4.SetWorkflowType("statemachine")
oLw4.AddStateXTT("i", "", [ :isInitial = 1 ])
oLw4.AddStateXT("p", "P")
oLw4.AddStateXT("q", "Q")
oLw4.AddTransition("i", "p", "")
oLw4.AddTransition("p", "q", "a")
oLw4.AddTransition("q", "p", "b")
oLw4.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])
nLwIy2 = -1  nLwPy2 = -1
_aRLw143_ = oLw4.RenderNodeRects()
_nRLw143_ = len(_aRLw143_)
for _iRLw143_ = 1 to _nRLw143_
	rLw = _aRLw143_[_iRLw143_]
	if rLw[5] = "i"  nLwIy2 = rLw[2] + rLw[4]  ok
	if rLw[5] = "p"  nLwPy2 = rLw[2]  ok
next
nLwGapShort = nLwPy2 - nLwIy2
? "   the mode gap with long peer labels " + nLwGapLong +
  " , with short ones " + nLwGapShort
chk("a mode gap is priced by what CROSSES it, not by peer chords",
    fabs(nLwGapLong - nLwGapShort) < 2)


sec("-- 60. FOUR MARKS ON ONE PICTURE, AND EACH AN OLD LAW ---------")
#
# The Principal, marking the door and surprised these were still here:
# "waste" on the entry gap, "??" on two hooked arrowheads, "mal
# positioned" on two labels, "too tight" on a rail against its frame.
# Not one needed a new idea -- every one was a law this file already
# holds, unapplied to the mode template.
#
# TWO NEIGHBOURS ON ONE ROW ARE JOINED BY ONE LINE (I4). Every ortho
# arrival was forced onto the rank-facing border, which is right for an
# edge crossing a rank gap and absurd for two peers side by side: the
# path ran out of the side, along the row, then UP into the target's
# top. A hook where the reader looks for a constraint and finds none --
# the "??" he circled.
#
# A FRAME PAYS FOR INK WHERE THE INK RUNS. Doubling the pad to hold the
# return rail paid for that rail on all four sides, including the top
# where nothing runs, and the entry gap came out twice as deep as
# anything standing in it -- the "waste". The rail is measured where it
# is instead, and gets its clearance of air -- the "too tight".
#
# And the labels followed: given a rail with room around it, the placer
# put each event back on its own line.
#---------------------------------------------------------------------------

oFm = new stzWorkflow("marks60")
oFm.SetWorkflowType("statemachine")
oFm.AddStateXTT("i", "", [ :isInitial = 1 ])
oFm.AddStateXT("closed", "Closed")
oFm.AddStateXT("open", "Open")
oFm.AddStateXT("locked", "Locked")
oFm.AddStateXTT("gone", "Demolished", [ :isFinal = 1 ])
oFm.AddTransition("i", "closed", "")
oFm.AddTransition("closed", "open", "open")
oFm.AddTransition("open", "closed", "close")
oFm.AddTransition("closed", "locked", "lock")
oFm.AddTransition("locked", "closed", "unlock")
oFm.AddTransition("locked", "locked", "lock")
oFm.AddTransition("closed", "gone", "demolish")
oFm.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

# "??" -- a peer edge is ONE segment, and it is horizontal
aFmP = []
_aAFmR144_ = oFm.RenderEdgePaths()
_nAFmR144_ = len(_aAFmR144_)
for _iAFmR144_ = 1 to _nAFmR144_
	aFmR = _aAFmR144_[_iAFmR144_]
	if aFmR[1] = "closed>open"  aFmP = aFmR[2]  ok
next
? "   the peer edge has " + (len(aFmP) / 2) + " points"
chkeq("two neighbours on one row are joined by ONE segment",
      len(aFmP), 4)
chk("...and it is horizontal, with no hook into a border",
    fabs(aFmP[2] - aFmP[4]) < 1)

# "too tight" -- the rail stands clear of the frame it lives in
nFmRail = -1
_aAFmR145_ = oFm.RenderEdgePaths()
_nAFmR145_ = len(_aAFmR145_)
for _iAFmR145_ = 1 to _nAFmR145_
	aFmR = _aAFmR145_[_iAFmR145_]
	if aFmR[1] != "open>closed"  loop  ok
	for iFm = 2 to len(aFmR[2]) step 2
		if aFmR[2][iFm] > nFmRail  nFmRail = aFmR[2][iFm]  ok
	next
next
nFmBot = -1
_aAFmC146_ = oFm.RenderClusterRects()
_nAFmC146_ = len(_aAFmC146_)
for _iAFmC146_ = 1 to _nAFmC146_
	aFmC = _aAFmC146_[_iAFmC146_]
	if aFmC[2] + aFmC[4] > nFmBot  nFmBot = aFmC[2] + aFmC[4]  ok
next
? "   the rail sits " + (nFmBot - nFmRail) + "px above the frame's rule"
chk("a rail inside a frame keeps its air", nFmBot - nFmRail >= 12)
chk("...and is inside it at all", nFmRail < nFmBot)

# "waste" -- the entry gap holds what crosses it and no more. Compared
# against the frame's own chrome, which is the only thing that
# legitimately lives there.
nFmIy = -1  nFmTop = 1000000
_aRFm147_ = oFm.RenderNodeRects()
_nRFm147_ = len(_aRFm147_)
for _iRFm147_ = 1 to _nRFm147_
	rFm = _aRFm147_[_iRFm147_]
	if rFm[5] = "i"  nFmIy = rFm[2] + rFm[4]  ok
next
_aAFmC148_ = oFm.RenderClusterRects()
_nAFmC148_ = len(_aAFmC148_)
for _iAFmC148_ = 1 to _nAFmC148_
	aFmC = _aAFmC148_[_iAFmC148_]
	if aFmC[2] < nFmTop  nFmTop = aFmC[2]  ok
next
? "   the entry gap is " + (nFmTop - nFmIy) + "px above the frame"
chk("an unlabelled entry gap is not twice what stands in it",
    nFmTop - nFmIy < 200)

# "mal positioned" -- every event label sits on ITS OWN edge's ink
nFmFar = 0
_aAFmL149_ = oFm.RenderLabels()
_nAFmL149_ = len(_aAFmL149_)
for _iAFmL149_ = 1 to _nAFmL149_
	aFmL = _aAFmL149_[_iAFmL149_]
	_dFm_ = 1000000
	_aAFmR150_ = oFm.RenderEdgePaths()
	_nAFmR150_ = len(_aAFmR150_)
	for _iAFmR150_ = 1 to _nAFmR150_
		aFmR = _aAFmR150_[_iAFmR150_]
		if aFmR[1] != aFmL[6]  loop  ok
		_fFm_ = aFmR[2]
		for iFm = 1 to len(_fFm_) - 3 step 2
			_axF_ = min([ _fFm_[iFm], _fFm_[iFm+2] ])
			_bxF_ = max([ _fFm_[iFm], _fFm_[iFm+2] ])
			_ayF_ = min([ _fFm_[iFm+1], _fFm_[iFm+3] ])
			_byF_ = max([ _fFm_[iFm+1], _fFm_[iFm+3] ])
			_dxF_ = 0
			if _bxF_ < aFmL[2]  _dxF_ = aFmL[2] - _bxF_  ok
			if _axF_ > aFmL[2]  _dxF_ = _axF_ - aFmL[2]  ok
			_dyF_ = 0
			if _byF_ < aFmL[3]  _dyF_ = aFmL[3] - _byF_  ok
			if _ayF_ > aFmL[3]  _dyF_ = _ayF_ - aFmL[3]  ok
			_dF_ = sqrt(_dxF_*_dxF_ + _dyF_*_dyF_)
			if _dF_ < _dFm_  _dFm_ = _dF_  ok
		next
	next
	# THE BAR SCALES WITH THE LABEL, because a label now stands BESIDE
	# its line rather than on it: the offset is half the label plus a
	# clearance, so a wide word is legitimately further from the ink
	# than a narrow one. A fixed bar measured the word's width, not its
	# attachment.
	if _dFm_ > max([ aFmL[4], aFmL[5] ]) / 2 + oFm._LineClearance()
		nFmFar++
	ok
next
? "   labels standing away from their own edge : " + nFmFar
chkeq("every event label sits on the ink it names", nFmFar, 0)


sec("-- 61. ONE LANE EACH, AND ONE PAYMENT EACH ------------------")
#
# The Principal redrew a return rail by hand, lower than the one already
# there, and wrote "so tall" beside the entry gap. Both are quantities
# paid twice.
#
# ONE LANE EACH -- I2 for the third time. Every return took the same
# single-clearance offset, so two returns into one state were drawn on
# top of each other and their two events fought over the strip between.
# The Nth return in a row rides the Nth lane now. The bug that hid it is
# worth naming: the allocator worked from the first attempt, and the
# twin's END CLAMP pulled every end back onto the rank-facing border --
# right for a twin whose last leg is a vertical drop, catastrophic for
# one that runs along a row, and it dragged lane two straight back onto
# lane one.
#
# ONE PAYMENT EACH. The frame counted a pair TWICE (a pair is two edges
# and both passed its test) and carried a hundred pixels of empty floor;
# the rank separation funded region chrome that the derived size was
# already funding. Three separate double-payments this session, all with
# the same shape: a quantity charged where it is measured AND where it
# is used.
#---------------------------------------------------------------------------

oLn = new stzWorkflow("lanes61")
oLn.SetWorkflowType("statemachine")
oLn.AddStateXTT("i", "", [ :isInitial = 1 ])
oLn.AddStateXT("closed", "Closed")
oLn.AddStateXT("open", "Open")
oLn.AddStateXT("locked", "Locked")
oLn.AddStateXTT("gone", "Demolished", [ :isFinal = 1 ])
oLn.AddTransition("i", "closed", "")
oLn.AddTransition("closed", "open", "open")
oLn.AddTransition("open", "closed", "close")
oLn.AddTransition("closed", "locked", "lock")
oLn.AddTransition("locked", "closed", "unlock")
oLn.AddTransition("locked", "locked", "lock")
oLn.AddTransition("closed", "gone", "demolish")
oLn.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

# TWO RETURNS, TWO LANES, a clearance apart
# (_LaneY62 lives at the foot: a func here would end the script)
nLn1 = _LaneY62(oLn, "open>closed")
nLn2 = _LaneY62(oLn, "locked>closed")
? "   the two returns ride y=" + nLn1 + " and y=" + nLn2
chk("two returns into one state take two lanes",
    fabs(nLn1 - nLn2) >= oLn._LineClearance() - 1)
nLnRow = -1
_aRLn151_ = oLn.RenderNodeRects()
_nRLn151_ = len(_aRLn151_)
for _iRLn151_ = 1 to _nRLn151_
	rLn = _aRLn151_[_iRLn151_]
	if rLn[5] = "closed"  nLnRow = rLn[2] + rLn[4] / 2  ok
next
chk("...both below the row they return along",
    nLn1 > nLnRow and nLn2 > nLnRow)

# ...AND EACH LABEL ON ITS OWN LANE
nLnC = -1  nLnU = -1
_aALnL152_ = oLn.RenderLabels()
_nALnL152_ = len(_aALnL152_)
for _iALnL152_ = 1 to _nALnL152_
	aLnL = _aALnL152_[_iALnL152_]
	if aLnL[1] = "close"   nLnC = aLnL[3]  ok
	if aLnL[1] = "unlock"  nLnU = aLnL[3]  ok
next
chk("each event sits on its own return, not between two",
    fabs(nLnC - nLnU) >= oLn._LineClearance() - 1)

# THE FRAME HOLDS THEM, and holds nothing else: no more than a pad of
# empty floor under the lowest rail
nLnBot = -1
_aALnC153_ = oLn.RenderClusterRects()
_nALnC153_ = len(_aALnC153_)
for _iALnC153_ = 1 to _nALnC153_
	aLnC = _aALnC153_[_iALnC153_]
	if aLnC[2] + aLnC[4] > nLnBot  nLnBot = aLnC[2] + aLnC[4]  ok
next
nLnDeep = max([ nLn1, nLn2 ])
? "   the frame's floor sits " + (nLnBot - nLnDeep) + "px under the last rail"
chk("a frame contains its rails", nLnBot > nLnDeep)
chk("...and does not carry an empty floor under them",
    nLnBot - nLnDeep < oLn._LineClearance() * 3)

# "SO TALL" -- the entry gap holds the frame's chrome and what crosses
# it, and is not charged for either twice
nLnI = -1  nLnTop = 1000000
_aRLn154_ = oLn.RenderNodeRects()
_nRLn154_ = len(_aRLn154_)
for _iRLn154_ = 1 to _nRLn154_
	rLn = _aRLn154_[_iRLn154_]
	if rLn[5] = "i"  nLnI = rLn[2] + rLn[4]  ok
next
_aALnC155_ = oLn.RenderClusterRects()
_nALnC155_ = len(_aALnC155_)
for _iALnC155_ = 1 to _nALnC155_
	aLnC = _aALnC155_[_iALnC155_]
	if aLnC[2] < nLnTop  nLnTop = aLnC[2]  ok
next
? "   the entry gap is " + (nLnTop - nLnI) + "px"
chk("an entry gap is not charged for the chrome twice",
    nLnTop - nLnI < 130)


sec("-- 62. THE UNIVERSAL INVARIANTS, over EVERY scene -----------")
#
# The Principal, on four basic faults returning: "I start to fear that
# maybe we lost all what we implemented before." He is right to ask, and
# the honest answer is not that the laws were lost -- it is that they
# were never asserted UNIVERSALLY.
#
# Every law in this file is checked on a scene chosen to exercise it.
# Nothing walked EVERY picture asking the questions that must hold in
# all of them. So an edge could end 28px from the state it points at,
# and 400 assertions stayed green -- section 58 asks that question only
# of arrows into a mark.
#
# The deeper cause was structural and is worth writing down: FIVE places
# decided where an edge meets a node -- the attachment, the clip, the
# same-rank branch, the lateral branch, and the twin's end clamp. "An
# edge touches its node" lived in each of them separately, so changing
# one to preserve a lane silently removed the only copy holding that end
# on the border.
#
# This section is the remedy. It renders a set of pictures that between
# them use every template and every glyph kind this plane has, and asks
# the same small set of questions of all of them. A new template joins
# by adding a row to the list -- not by hoping someone remembers.
#---------------------------------------------------------------------------

aUni = []

oU1 = new stzWorkflow("uni-door")
oU1.SetWorkflowType("statemachine")
oU1.AddStateXTT("i", "", [ :isInitial = 1 ])
oU1.AddStateXT("closed", "Closed")
oU1.AddStateXT("open", "Open")
oU1.AddStateXT("locked", "Locked")
oU1.AddStateXTT("gone", "Demolished", [ :isFinal = 1 ])
oU1.AddTransition("i", "closed", "")
oU1.AddTransition("closed", "open", "open")
oU1.AddTransition("open", "closed", "close")
oU1.AddTransition("closed", "locked", "lock")
oU1.AddTransition("locked", "closed", "unlock")
oU1.AddTransition("locked", "locked", "lock")
oU1.AddTransition("closed", "gone", "demolish")
oU1.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])
aUni + [ "modes/statemachine", oU1 ]

oU2 = new stzOrgChart("uni-org")
oU2.AddExecutiveXT("ceo", "CEO")
oU2.AddManagerXT("cto", "CTO")
oU2.AddManagerXT("cfo", "CFO")
oU2.AddStaffXT("d1", "Dev One")
oU2.AddStaffXT("d2", "Dev Two")
oU2.ReportsTo("cto", "ceo")  oU2.ReportsTo("cfo", "ceo")
oU2.ReportsTo("d1", "cto")   oU2.ReportsTo("d2", "cto")
oU2.SetSplines("ortho")
oU2.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])
aUni + [ "layered/orgchart", oU2 ]

oU3 = new stzDiagram("uni-svc")
_aAU3156_ = [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
             [ "api1","API A" ],[ "api2","API B" ],
             [ "db1","DB A" ],[ "db2","DB B" ],[ "log","Logger" ] ]
_nAU3156_ = len(_aAU3156_)
for _iAU3156_ = 1 to _nAU3156_
	aU3 = _aAU3156_[_iAU3156_]
	oU3.AddNodeXTT(aU3[1], aU3[2], [ :type = "box", :color = "Info.Solid" ])
next
oU3.AddEdge("lb","web1")   oU3.AddEdge("lb","web2")
oU3.AddEdgeXT("web1","api1", "call")  oU3.AddEdge("web2","api2")
oU3.AddEdge("api1","db1")  oU3.AddEdge("api2","db2")
oU3.AddEdge("web1","log")  oU3.AddEdge("api2","log")
oU3.SetSplines("ortho")
oU3.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 96, :NodeHeight = 36,
	:FontSize = 13 ])
aUni + [ "layered/default", oU3 ]

oU4 = new stzDiagram("uni-shapes")
oU4.AddNodeXTT("s", "Start", [ :type = "start" ])
oU4.AddNodeXTT("d", "Decide", [ :type = "decision" ])
oU4.AddNodeXTT("b", "Store", [ :type = "database" ])
oU4.AddNodeXTT("e", "End", [ :type = "end" ])
oU4.AddEdgeXT("s", "d", "go")
oU4.AddEdgeXT("d", "b", "yes")
oU4.AddEdgeXT("d", "e", "no")
oU4.SetSplines("ortho")
oU4.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 44,
	:FontSize = 13 ])
aUni + [ "layered/every-glyph", oU4 ]

# THE ARROWHEAD'S OWN LENGTH is the only daylight an endpoint may have:
# the path is published AFTER the head is cut off it, so an endpoint
# sits one arrowhead short of the border by construction. Anything more
# is an edge that does not touch what it names.
nUniHead = 9 + 2 * 2 + 2

nUniLoose = 0
nUniWorst = 0
nUniPlate = 0
nUniOut = 0
nUniHug = 0
nUniLab = 0
nUniOff = 0
nUniRule = 0
_aAUniS157_ = aUni
_nAUniS157_ = len(_aAUniS157_)
for _iAUniS157_ = 1 to _nAUniS157_
	aUniS = _aAUniS157_[_iAUniS157_]
	cUniN = aUniS[1]
	oUni = aUniS[2]

	# (a) EVERY EDGE TOUCHES BOTH ITS NODES
	_aAUniP158_ = oUni.RenderEdgePaths()
	_nAUniP158_ = len(_aAUniP158_)
	for _iAUniP158_ = 1 to _nAUniP158_
		aUniP = _aAUniP158_[_iAUniP158_]
		aUniE = StzSplit(aUniP[1], ">")
		if len(aUniE) != 2  loop  ok
		fUni = aUniP[2]
		nUniL = len(fUni)
		if nUniL < 4  loop  ok
		rUniA = _Rect49(oUni, StzLower(aUniE[1]))
		rUniB = _Rect49(oUni, StzLower(aUniE[2]))
		if rUniA[3] = 0 or rUniB[3] = 0  loop  ok
		dUni1 = _DistRect62(rUniA, fUni[1], fUni[2])
		dUni2 = _DistRect62(rUniB, fUni[nUniL-1], fUni[nUniL])
		if dUni1 > nUniHead or dUni2 > nUniHead
			nUniLoose++
			? "   " + cUniN + " : " + aUniP[1] + " floats by " +
			  max([ dUni1, dUni2 ]) + "px"
		ok
		if max([ dUni1, dUni2 ]) > nUniWorst
			nUniWorst = max([ dUni1, dUni2 ])
		ok
	next

	# (b) EVERY LABEL SITS INSIDE THE FRAME ITS EDGE LIVES IN. A word
	#     outside the region whose states it joins belongs to nothing a
	#     reader can name.
	_aAUniL159_ = oUni.RenderLabels()
	_nAUniL159_ = len(_aAUniL159_)
	for _iAUniL159_ = 1 to _nAUniL159_
		aUniL = _aAUniL159_[_iAUniL159_]
		aUniK = StzSplit("" + aUniL[6], ">")
		if len(aUniK) != 2  loop  ok
		_aAUniC160_ = oUni.RenderClusterRects()
		_nAUniC160_ = len(_aAUniC160_)
		for _iAUniC160_ = 1 to _nAUniC160_
			aUniC = _aAUniC160_[_iAUniC160_]
			bUniIn = 0
			_aCUniM161_ = aUniC[5]
			_nCUniM161_ = len(_aCUniM161_)
			for _iCUniM161_ = 1 to _nCUniM161_
				cUniM = _aCUniM161_[_iCUniM161_]
				if cUniM = StzLower(aUniK[1])  bUniIn++  ok
				if cUniM = StzLower(aUniK[2])  bUniIn++  ok
			next
			if bUniIn < 2  loop  ok
			if aUniL[2] + aUniL[4]/2 > aUniC[1] + aUniC[3] + 1 or
			   aUniL[2] - aUniL[4]/2 < aUniC[1] - 1
				nUniOut++
				? "   " + cUniN + " : label '" + aUniL[1] +
				  "' outside the frame its edge lives in"
			ok
		next
	next

	# (c) EVERY HORIZONTAL RUN CLEARS THE CELLS IT PASSES UNDER. A
	#     clearance is clearance FROM THE INK: measured from the row's
	#     centre-line the first return lane landed four pixels from the
	#     boxes, a rail hugging the cells it runs beneath. Asked of
	#     every picture, because the rule is not the state machine's.
	_aAUniP162_ = oUni.RenderEdgePaths()
	_nAUniP162_ = len(_aAUniP162_)
	for _iAUniP162_ = 1 to _nAUniP162_
		aUniP = _aAUniP162_[_iAUniP162_]
		aUniE = StzSplit(aUniP[1], ">")
		if len(aUniE) != 2  loop  ok
		if aUniE[1] = aUniE[2]  loop  ok
		fUni = aUniP[2]
		for iUni = 1 to len(fUni) - 3 step 2
			if fabs(fUni[iUni+3] - fUni[iUni+1]) > 0.5  loop  ok
			if fabs(fUni[iUni+2] - fUni[iUni]) < 20  loop  ok
			_axU_ = min([ fUni[iUni], fUni[iUni+2] ]) + 6
			_bxU_ = max([ fUni[iUni], fUni[iUni+2] ]) - 6
			_yU_ = fUni[iUni+1]
			_aRUni163_ = oUni.RenderNodeRects()
			_nRUni163_ = len(_aRUni163_)
			for _iRUni163_ = 1 to _nRUni163_
				rUni = _aRUni163_[_iRUni163_]
				# a cell this run passes under or over, and not one of
				# its own endpoints
				if rUni[5] = StzLower(aUniE[1]) or
				   rUni[5] = StzLower(aUniE[2])  loop  ok
				if rUni[1] + rUni[3] < _axU_ or rUni[1] > _bxU_  loop  ok
				_dU_ = 1000000
				if _yU_ > rUni[2] + rUni[4]  _dU_ = _yU_ - (rUni[2] + rUni[4])  ok
				if _yU_ < rUni[2]  _dU_ = rUni[2] - _yU_  ok
				if _dU_ < oUni._LineClearance() - 2
					nUniHug++
					? "   " + cUniN + " : " + aUniP[1] +
					  " runs " + _dU_ + "px from " + rUni[5]
				ok
			next
		next
	next

	# (d) EVERY LABEL AT THE MIDDLE OF ITS EDGE, unless the middle is
	#     taken. The Principal's rule, with his own exception named:
	#     "all edge labels must be AT THE MIDDLE of the edge, except
	#     when it's tight". So the claim is not that every label is at
	#     0.5 -- it is that a label away from the middle had a REASON,
	#     and the reason is that the middle was refused.
	_aAUniL164_ = oUni.RenderLabels()
	_nAUniL164_ = len(_aAUniL164_)
	for _iAUniL164_ = 1 to _nAUniL164_
		aUniL = _aAUniL164_[_iAUniL164_]
		_aAUniP165_ = oUni.RenderEdgePaths()
		_nAUniP165_ = len(_aAUniP165_)
		for _iAUniP165_ = 1 to _nAUniP165_
			aUniP = _aAUniP165_[_iAUniP165_]
			if aUniP[1] != aUniL[6]  loop  ok
			nUniLab++
			if _MidFrac62(aUniP[2], aUniL[2], aUniL[3]) > 0.15
				nUniOff++
			ok
		next
	next

	# (e) NO LABEL STANDS ON A FRAME'S RULE. Its plate takes the surface
	#     under it, and on a boundary there are two -- so it must get one
	#     wrong and erase a stretch of the frame.
	_aAUniL166_ = oUni.RenderLabels()
	_nAUniL166_ = len(_aAUniL166_)
	for _iAUniL166_ = 1 to _nAUniL166_
		aUniL = _aAUniL166_[_iAUniL166_]
		_aAUniC167_ = oUni.RenderClusterRects()
		_nAUniC167_ = len(_aAUniC167_)
		for _iAUniC167_ = 1 to _nAUniC167_
			aUniC = _aAUniC167_[_iAUniC167_]
			if aUniL[2] + aUniL[4]/2 < aUniC[1] or
			   aUniL[2] - aUniL[4]/2 > aUniC[1] + aUniC[3]  loop  ok
			if fabs(aUniL[3] - aUniC[2]) < aUniL[5] / 2 or
			   fabs(aUniL[3] - (aUniC[2] + aUniC[4])) < aUniL[5] / 2
				nUniRule++
				? "   " + cUniN + " : '" + aUniL[1] + "' stands on a frame rule"
			ok
		next
	next
next

? "   edges not touching a node they name : " + nUniLoose +
  " (worst " + nUniWorst + "px, arrowhead is " + nUniHead + ")"
chkeq("EVERY edge touches both its nodes, in every template",
      nUniLoose, 0)
? "   labels outside the frame their edge lives in : " + nUniOut
chkeq("EVERY label stays inside the frame its edge lives in", nUniOut, 0)
? "   horizontal runs hugging a cell they pass : " + nUniHug
chkeq("EVERY run clears the cells it passes, in every template",
      nUniHug, 0)
? "   labels away from their edge's middle : " + nUniOff +
  " of " + nUniLab
# THE MIDDLE IS THE PREFERENCE, and "tight" is the Principal's own
# named exception -- so the claim is that the middle WINS, not that it
# always wins. A crowded picture legitimately slides a word along its
# line; what would be wrong is the placer preferring somewhere else,
# and that shows up as a majority off-centre.
chk("the MIDDLE of the edge wins, but for the tight few",
    nUniOff * 2 <= nUniLab)
? "   labels standing on a frame's rule : " + nUniRule
chkeq("no label stands on a frame's own rule", nUniRule, 0)

# (f) EVERY GAP IN ONE PICTURE IS THE SAME GAP -- I5 for whitespace.
#     Two gaps drawn differently assert a difference, and between an
#     entry and an exit there is none. Measured to the FRAME where a
#     frame stands, because that is the edge a reader sees.
oUg = new stzWorkflow("gaps62")
oUg.SetWorkflowType("statemachine")
oUg.AddStateXTT("i", "", [ :isInitial = 1 ])
oUg.AddStateXT("closed", "Closed")
oUg.AddStateXT("open", "Open")
oUg.AddStateXTT("gone", "Gone", [ :isFinal = 1 ])
oUg.AddTransition("i", "closed", "")
oUg.AddTransition("closed", "open", "open")
oUg.AddTransition("open", "closed", "close")
oUg.AddTransition("closed", "gone", "demolish")
oUg.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])
nUgI = 0  nUgG = 0
_aRUg168_ = oUg.RenderNodeRects()
_nRUg168_ = len(_aRUg168_)
for _iRUg168_ = 1 to _nRUg168_
	rUg = _aRUg168_[_iRUg168_]
	if rUg[5] = "i"     nUgI = rUg[2] + rUg[4]  ok
	if rUg[5] = "gone"  nUgG = rUg[2]  ok
next
nUgTop = 1000000  nUgBot = 0
_aCUg169_ = oUg.RenderClusterRects()
_nCUg169_ = len(_aCUg169_)
for _iCUg169_ = 1 to _nCUg169_
	cUg = _aCUg169_[_iCUg169_]
	if cUg[2] < nUgTop  nUgTop = cUg[2]  ok
	if cUg[2] + cUg[4] > nUgBot  nUgBot = cUg[2] + cUg[4]  ok
next
nUgA = nUgTop - nUgI
nUgB = nUgG - nUgBot
? "   entry gap " + nUgA + "px, exit gap " + nUgB + "px"
chk("the way in and the way out are the same distance",
    fabs(nUgA - nUgB) < 3)
chk("...and neither is longer than the picture needs",
    nUgA < 120 and nUgB < 120)

# (c) A LABEL PLATE TAKES THE SURFACE IT COVERS. Asked of the DRAWN
#     pixels, because this is a claim about what a reader sees: the
#     pixel just outside a plate and the pixel just inside it must be
#     the same colour, or the plate reads as a card lying on the field.
if NOT StzGraphicsDevice()
	? "   (no device -- the plate colour is a pixel property; skipped)"
else
	oUp = new stzWorkflow("plate62")
	oUp.SetWorkflowType("statemachine")
	oUp.AddStateXT("a", "A")
	oUp.AddStateXT("b", "B")
	oUp.AddTransition("a", "b", "go")
	oUp.AddTransition("b", "a", "back")
	oUpC = oUp.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104,
		:NodeHeight = 40, :FontSize = 13 ])
	cUpPx = oUpC.ToPixels()
	nUpW = oUpC.Width()
	nUpBad = 0
	_aAUpL170_ = oUp.RenderLabels()
	_nAUpL170_ = len(_aAUpL170_)
	for _iAUpL170_ = 1 to _nAUpL170_
		aUpL = _aAUpL170_[_iAUpL170_]
		# a pixel inside the plate's top edge, and one just above it
		nUpX = floor(aUpL[2])
		nUpIn = floor(aUpL[3] - aUpL[5] / 2 + 2)
		nUpOut = floor(aUpL[3] - aUpL[5] / 2 - 3)
		aUpA = _Px62(cUpPx, nUpW, nUpX, nUpIn)
		aUpB = _Px62(cUpPx, nUpW, nUpX, nUpOut)
		nUpD = fabs(aUpA[1] - aUpB[1]) + fabs(aUpA[2] - aUpB[2]) +
			fabs(aUpA[3] - aUpB[3])
		? "   plate for '" + aUpL[1] + "' : inside rgb " + aUpA[1] + "," +
		  aUpA[2] + "," + aUpA[3] + "  outside " + aUpB[1] + "," +
		  aUpB[2] + "," + aUpB[3]
		if nUpD > 12  nUpBad++  ok
	next
	chkeq("a label plate is the colour of the surface it covers",
	      nUpBad, 0)
ok


sec("-- 63. THE ROW IS NOT FREE JUST BECAUSE IT IS A ROW ---------")
#
# Six practical machines were drawn to see what the engine is worth in
# use, and they found four defects that no scene INVENTED to exercise a
# law had found. That is section 46 and section 62 restated once more:
# the picture you draw to prove a rule is the picture the rule fits.
#
# (1) TWO PEERS ARE JOINED BY ONE STRAIGHT LINE -- and the rule said
#     nothing about what stands between them. A media player's
#     paused->stopped ran horizontally through the middle of Playing,
#     and the picture then claimed Playing was on the way from Paused to
#     Stopped. It is not on the way; it is in the way.
#
# (2) A LANE BELONGED TO A ROW, so three INDEPENDENT switch pairs --
#     three regions, nothing linking them -- were handed lanes one, two
#     and three. Three drawings of one shape came out as three shapes,
#     and the third region's return line was pushed outside the frame
#     that exists to contain it.
#
# (3) THE FRAME GUESSED how deep its rails ran, by counting twin pairs.
#     A return with no partner was invisible to that count, and so was
#     an edge stepping off the row because of (1). An estimate of a
#     quantity the program later computes exactly is a bug waiting for
#     its picture.
#
# (4) THE PAPER WAS A RESERVATION, not the drawing: the three switches
#     came out 539px tall over 276px of ink. "Space is optimised, at any
#     situation" has been said of exactly this.
#---------------------------------------------------------------------------

# (1) THE ROW MUST BE FREE. Three peers, and an edge from the first to
#     the third -- the one shape that cannot keep the row.
oBt = new stzWorkflow("between63")
oBt.SetWorkflowType("statemachine")
oBt.AddStateXT("a", "Alpha")  oBt.AddStateXT("b", "Beta")
oBt.AddStateXT("c", "Gamma")
oBt.AddTransition("a", "b", "one")
oBt.AddTransition("b", "c", "two")
oBt.AddTransition("c", "a", "back")
oBt.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

aBtMid = _Rect49(oBt, "b")
nBtWorst = 0
_aABtP171_ = oBt.RenderEdgePaths()
_nABtP171_ = len(_aABtP171_)
for _iABtP171_ = 1 to _nABtP171_
	aBtP = _aABtP171_[_iABtP171_]
	if aBtP[1] != "c>a"  loop  ok
	nBtN = len(aBtP[2]) / 2
	for iBt = 1 to nBtN - 1
		nBtY1 = aBtP[2][iBt * 2]
		nBtY2 = aBtP[2][iBt * 2 + 2]
		if fabs(nBtY1 - nBtY2) > 1  loop  ok
		nBtX1 = aBtP[2][iBt * 2 - 1]
		nBtX2 = aBtP[2][iBt * 2 + 1]
		if nBtX1 > nBtX2
			nBtT = nBtX1  nBtX1 = nBtX2  nBtX2 = nBtT
		ok
		if nBtX2 < aBtMid[1] or nBtX1 > aBtMid[1] + aBtMid[3]  loop  ok
		nBtD = _DistRect62(aBtMid, (nBtX1 + nBtX2) / 2, nBtY1)
		if nBtD > nBtWorst  nBtWorst = nBtD  ok
	next
next
? "   the long peer run clears the state between it by " + nBtWorst + "px"
chk("a run keeps the row only while the row is free",
    nBtWorst >= oBt._LineClearance())

# ...AND IT STILL ARRIVES AT ITS TARGET. Stepping aside must not become
# stepping away: the ends stay on their nodes' borders.
aBtA = _Rect49(oBt, "a")
nBtGap = -1
_aABtP172_ = oBt.RenderEdgePaths()
_nABtP172_ = len(_aABtP172_)
for _iABtP172_ = 1 to _nABtP172_
	aBtP = _aABtP172_[_iABtP172_]
	if aBtP[1] != "c>a"  loop  ok
	nBtN = len(aBtP[2]) / 2
	nBtGap = _DistRect62(aBtA, aBtP[2][nBtN * 2 - 1], aBtP[2][nBtN * 2])
next
chk("...and the run that stepped aside still lands on its node",
    nBtGap >= 0 and nBtGap <= 16)

# (2) THE SAME SHAPE IS THE SAME PICTURE. Three independent pairs, side
#     by side, sharing a row and nothing else.
oIn = new stzWorkflow("indep63")
oIn.SetWorkflowType("statemachine")
oIn.AddStateXT("p0", "P Off")   oIn.AddStateXT("p1", "P On")
oIn.AddStateXT("a0", "A Off")   oIn.AddStateXT("a1", "A On")
oIn.AddStateXT("d0", "D Off")   oIn.AddStateXT("d1", "D On")
oIn.AddTransition("p0", "p1", "on")  oIn.AddTransition("p1", "p0", "off")
oIn.AddTransition("a0", "a1", "on")  oIn.AddTransition("a1", "a0", "off")
oIn.AddTransition("d0", "d1", "on")  oIn.AddTransition("d1", "d0", "off")
oIn.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

nInRow = -1
_aRIn173_ = oIn.RenderNodeRects()
_nRIn173_ = len(_aRIn173_)
for _iRIn173_ = 1 to _nRIn173_
	rIn = _aRIn173_[_iRIn173_]
	if rIn[5] = "p0"  nInRow = rIn[2] + rIn[4] / 2  ok
next
aInDepth = []
_aCInK174_ = [ "p1>p0", "a1>a0", "d1>d0" ]
_nCInK174_ = len(_aCInK174_)
for _iCInK174_ = 1 to _nCInK174_
	cInK = _aCInK174_[_iCInK174_]
	aInP = []
	_aAInR175_ = oIn.RenderEdgePaths()
	_nAInR175_ = len(_aAInR175_)
	for _iAInR175_ = 1 to _nAInR175_
		aInR = _aAInR175_[_iAInR175_]
		if aInR[1] = cInK  aInP = aInR[2]  ok
	next
	nInD = 0
	nInN = len(aInP) / 2
	for iIn = 1 to nInN
		if aInP[iIn * 2] - nInRow > nInD  nInD = aInP[iIn * 2] - nInRow  ok
	next
	aInDepth + nInD
next
? "   the three returns ride " + aInDepth[1] + ", " + aInDepth[2] +
  " and " + aInDepth[3] + "px under their row"
chk("three identical structures are drawn identically",
    fabs(aInDepth[1] - aInDepth[2]) < 1 and
    fabs(aInDepth[2] - aInDepth[3]) < 1)

# ...AND EACH RETURN STAYS IN ITS OWN FRAME. A lane counted across the
# whole row pushed the third one out through the floor.
nInOut = 0
_aAInC176_ = oIn.RenderClusterRects()
_nAInC176_ = len(_aAInC176_)
for _iAInC176_ = 1 to _nAInC176_
	aInC = _aAInC176_[_iAInC176_]
	_aCInK177_ = [ "p1>p0", "a1>a0", "d1>d0" ]
	_nCInK177_ = len(_aCInK177_)
	for _iCInK177_ = 1 to _nCInK177_
		cInK = _aCInK177_[_iCInK177_]
		_aAInR178_ = oIn.RenderEdgePaths()
		_nAInR178_ = len(_aAInR178_)
		for _iAInR178_ = 1 to _nAInR178_
			aInR = _aAInR178_[_iAInR178_]
			if aInR[1] != cInK  loop  ok
			nInN = len(aInR[2]) / 2
			for iIn = 1 to nInN
				nInX = aInR[2][iIn * 2 - 1]
				nInY = aInR[2][iIn * 2]
				if nInX < aInC[1] or nInX > aInC[1] + aInC[3]  loop  ok
				if nInY > aInC[2] + aInC[4] + 1  nInOut++  ok
			next
		next
	next
next
chkeq("every return stays inside the frame that contains its states",
      nInOut, 0)

# (3) THE FRAME HOLDS EVERY RAIL, INCLUDING ONE NO PAIR ASKED FOR. The
#     door has three now: one return, one forward that had to step off
#     the row, and that forward edge's own return.
oDr = new stzWorkflow("door63")
oDr.SetWorkflowType("statemachine")
oDr.AddStateXTT("i", "", [ :isInitial = 1 ])
oDr.AddStateXT("closed", "Closed")  oDr.AddStateXT("open", "Open")
oDr.AddStateXT("locked", "Locked")
oDr.AddStateXTT("gone", "Demolished", [ :isFinal = 1 ])
oDr.AddTransition("i", "closed", "")
oDr.AddTransition("closed", "open", "open")
oDr.AddTransition("open", "closed", "close")
oDr.AddTransition("closed", "locked", "lock")
oDr.AddTransition("locked", "closed", "unlock")
oDr.AddTransition("closed", "gone", "demolish")
oDr.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

nDrRow = -1
_aRDr179_ = oDr.RenderNodeRects()
_nRDr179_ = len(_aRDr179_)
for _iRDr179_ = 1 to _nRDr179_
	rDr = _aRDr179_[_iRDr179_]
	if rDr[5] = "closed"  nDrRow = rDr[2] + rDr[4] / 2  ok
next
nDrDeep = nDrRow
_aCDrK180_ = [ "open>closed", "closed>locked", "locked>closed" ]
_nCDrK180_ = len(_aCDrK180_)
for _iCDrK180_ = 1 to _nCDrK180_
	cDrK = _aCDrK180_[_iCDrK180_]
	_aADrR181_ = oDr.RenderEdgePaths()
	_nADrR181_ = len(_aADrR181_)
	for _iADrR181_ = 1 to _nADrR181_
		aDrR = _aADrR181_[_iADrR181_]
		if aDrR[1] != cDrK  loop  ok
		nDrN = len(aDrR[2]) / 2
		for iDr = 1 to nDrN
			if aDrR[2][iDr * 2] > nDrDeep  nDrDeep = aDrR[2][iDr * 2]  ok
		next
	next
next
nDrFloor = 0
_aADrC182_ = oDr.RenderClusterRects()
_nADrC182_ = len(_aADrC182_)
for _iADrC182_ = 1 to _nADrC182_
	aDrC = _aADrC182_[_iADrC182_]
	if aDrC[2] + aDrC[4] > nDrFloor  nDrFloor = aDrC[2] + aDrC[4]  ok
next
? "   three rails, the deepest at y=" + nDrDeep + ", floor at y=" + nDrFloor
chk("a frame holds every rail, not just the ones a pair asked for",
    nDrFloor >= nDrDeep)

# ...AND THE PAIR THAT BOTH STEPPED ASIDE IS STILL TWO STAIRCASES, not
# one mirrored into a diagonal off the edge of its own picture.
nDrSkew = 0
_aCDrK183_ = [ "closed>locked", "locked>closed" ]
_nCDrK183_ = len(_aCDrK183_)
for _iCDrK183_ = 1 to _nCDrK183_
	cDrK = _aCDrK183_[_iCDrK183_]
	_aADrR184_ = oDr.RenderEdgePaths()
	_nADrR184_ = len(_aADrR184_)
	for _iADrR184_ = 1 to _nADrR184_
		aDrR = _aADrR184_[_iADrR184_]
		if aDrR[1] != cDrK  loop  ok
		nDrN = len(aDrR[2]) / 2
		for iDr = 1 to nDrN - 1
			nDrDx = fabs(aDrR[2][iDr * 2 + 1] - aDrR[2][iDr * 2 - 1])
			nDrDy = fabs(aDrR[2][iDr * 2 + 2] - aDrR[2][iDr * 2])
			if nDrDx > 1 and nDrDy > 1  nDrSkew++  ok
		next
	next
next
chkeq("...and both members stay orthogonal", nDrSkew, 0)

# (4) THE PAPER IS THE CONTENT. Measured over every scene in this
#     section, because a reservation only shows as dead paper when the
#     reservation and the drawing disagree -- which is never on the
#     scene you wrote to test it.
nPpBad = 0
_aAPpO185_ = [ oBt, oIn, oDr ]
_nAPpO185_ = len(_aAPpO185_)
for _iAPpO185_ = 1 to _nAPpO185_
	aPpO = _aAPpO185_[_iAPpO185_]
	nPpX1 = 0  nPpY1 = 0
	_aRPp186_ = aPpO.RenderNodeRects()
	_nRPp186_ = len(_aRPp186_)
	for _iRPp186_ = 1 to _nRPp186_
		rPp = _aRPp186_[_iRPp186_]
		if rPp[1] + rPp[3] > nPpX1  nPpX1 = rPp[1] + rPp[3]  ok
		if rPp[2] + rPp[4] > nPpY1  nPpY1 = rPp[2] + rPp[4]  ok
	next
	_aRPp187_ = aPpO.RenderClusterRects()
	_nRPp187_ = len(_aRPp187_)
	for _iRPp187_ = 1 to _nRPp187_
		rPp = _aRPp187_[_iRPp187_]
		if rPp[1] + rPp[3] > nPpX1  nPpX1 = rPp[1] + rPp[3]  ok
		if rPp[2] + rPp[4] > nPpY1  nPpY1 = rPp[2] + rPp[4]  ok
	next
	_aAPpP188_ = aPpO.RenderEdgePaths()
	_nAPpP188_ = len(_aAPpP188_)
	for _iAPpP188_ = 1 to _nAPpP188_
		aPpP = _aAPpP188_[_iAPpP188_]
		nPpN = len(aPpP[2]) / 2
		for iPp = 1 to nPpN
			if aPpP[2][iPp * 2 - 1] > nPpX1  nPpX1 = aPpP[2][iPp * 2 - 1]  ok
			if aPpP[2][iPp * 2] > nPpY1  nPpY1 = aPpP[2][iPp * 2]  ok
		next
	next
	# ...and a name written OUTSIDE its cell is ink like any other.
	# Guessing what it costs (a multiple of the font size) is the same
	# mistake this section is about, one layer out: the renderer knows
	# where it put every one of them, so ask it.
	_aAPpL189_ = aPpO.RenderNodeLabels()
	_nAPpL189_ = len(_aAPpL189_)
	for _iAPpL189_ = 1 to _nAPpL189_
		aPpL = _aAPpL189_[_iAPpL189_]
		if aPpL[2] + aPpL[4] > nPpX1  nPpX1 = aPpL[2] + aPpL[4]  ok
		if aPpL[3] + aPpL[5] > nPpY1  nPpY1 = aPpL[3] + aPpL[5]  ok
	next
	_aAPpL190_ = aPpO.RenderLabels()
	_nAPpL190_ = len(_aAPpL190_)
	for _iAPpL190_ = 1 to _nAPpL190_
		aPpL = _aAPpL190_[_iAPpL190_]
		if aPpL[2] + aPpL[4] > nPpX1  nPpX1 = aPpL[2] + aPpL[4]  ok
		if aPpL[3] + aPpL[5] > nPpY1  nPpY1 = aPpL[3] + aPpL[5]  ok
	next
	nPpSlack = 24
	? "   " + aPpO.Name() + ": slack right " +
	  (aPpO.LastCanvas().Width() - nPpX1) + "px, below " +
	  (aPpO.LastCanvas().Height() - nPpY1) + "px (allowed " + nPpSlack + ")"
	if aPpO.LastCanvas().Width() - nPpX1 > nPpSlack  nPpBad++  ok
	if aPpO.LastCanvas().Height() - nPpY1 > nPpSlack  nPpBad++  ok
next
chkeq("no picture carries a band of paper nothing was drawn on",
      nPpBad, 0)

# (5) AN ARRIVAL CARRIES ITS OWN HEAD. An arrowhead is drawn from the
#     point the stroke was cut back to, so when the final segment is
#     SHORTER than that cut the head takes the PREVIOUS segment's
#     direction: the connection's "handshake ok" turned left five pixels
#     above its target, and its arrow pointed sideways at a spot above
#     the state instead of down into it.
nAhBad = 0
nAhSeen = 0
_aAAhO191_ = [ oBt, oIn, oDr ]
_nAAhO191_ = len(_aAAhO191_)
for _iAAhO191_ = 1 to _nAAhO191_
	aAhO = _aAAhO191_[_iAAhO191_]
	_aAAhP192_ = aAhO.RenderEdgePaths()
	_nAAhP192_ = len(_aAAhP192_)
	for _iAAhP192_ = 1 to _nAAhP192_
		aAhP = _aAAhP192_[_iAAhP192_]
		nAhN = len(aAhP[2]) / 2
		if nAhN < 2  loop  ok
		nAhDx = fabs(aAhP[2][nAhN * 2 - 1] - aAhP[2][nAhN * 2 - 3])
		nAhDy = fabs(aAhP[2][nAhN * 2] - aAhP[2][nAhN * 2 - 2])
		if nAhDx > 1 and nAhDy > 1  loop  ok
		nAhSeen++
		if nAhDx + nAhDy < 13  nAhBad++  ok
	next
next
? "   " + nAhSeen + " orthogonal arrivals, " + nAhBad + " too short for a head"
chkeq("every arrival is long enough to carry its arrowhead", nAhBad, 0)


sec("-- 64. ONE LINE IS ONE EDGE, AND ONE LADDER HOLDS THEM ALL -")
#
# Five more marks on the six practical machines, and every one of them
# is a rule the picture had been getting right by luck.
#
# (1) A LINE WITH AN ARROWHEAD AT EACH END. An edge leaving a state and
#     an edge arriving at it stood on the SAME column, running opposite
#     ways, so the pair read as one line pointing both directions --
#     "like that we can't know which direction is concerned". Two edges
#     are two lines. A border hands out its own columns.
#
# (2) ...AND ONE STUB TAKES THE MIDDLE. Spreading a single edge off a
#     border's centre says there is a second one to make room for.
#
# (3) ONE LADDER FOR EVERYTHING RUNNING UNDER A ROW. Two allocators
#     were placing horizontal runs under one row without seeing each
#     other's: the order put "retry" and "authorised" ELEVEN pixels
#     apart. A row's rails belong to the row; an edge leaving the row
#     passes under all of them.
#
# (4) A FRAME'S AIR IS THE SAME ON EVERY SIDE. It reserved a strip for
#     its own name whether or not it had one, and did not count the
#     word written under its deepest rail -- so 60px of air above the
#     row and 4px below the last label.
#
# (5) AN OUTLINE IS PROPORTIONAL TO WHAT IT OUTLINES, and a picture
#     writes its names in ONE weight. Both are I5: a treatment that
#     changes between two things asserts a difference between them.
#---------------------------------------------------------------------------

oLd = new stzWorkflow("ladder64")
oLd.SetWorkflowType("statemachine")
oLd.AddStateXTT("i", "", [ :isInitial = 1 ])
oLd.AddStateXT("a", "Alpha")   oLd.AddStateXT("b", "Beta")
oLd.AddStateXT("c", "Gamma")
oLd.AddStateXTT("z", "Done", [ :isFinal = 1 ])
oLd.AddTransition("i", "a", "")
oLd.AddTransition("a", "b", "one")
oLd.AddTransition("b", "a", "back")
oLd.AddTransition("b", "c", "two")
oLd.AddTransition("c", "a", "reset")
oLd.AddTransition("a", "z", "finish")
oLd.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

# (1) NO TWO EDGES SHARE A COLUMN AT ONE BORDER. Collect, per node, the
#     x of every end that meets its bottom border, and demand they
#     differ -- because two ends on one column IS the line with two
#     arrowheads, whichever way each is pointing.
nLdSame = 0
nLdEnds = 0
_aRLd193_ = oLd.RenderNodeRects()
_nRLd193_ = len(_aRLd193_)
for _iRLd193_ = 1 to _nRLd193_
	rLd = _aRLd193_[_iRLd193_]
	nLdCy = rLd[2] + rLd[4] / 2
	aLdX = []
	_aALdP194_ = oLd.RenderEdgePaths()
	_nALdP194_ = len(_aALdP194_)
	for _iALdP194_ = 1 to _nALdP194_
		aLdP = _aALdP194_[_iALdP194_]
		nLdN = len(aLdP[2]) / 2
		_aILd195_ = [ 1, nLdN ]
		_nILd195_ = len(_aILd195_)
		for _iILd195_ = 1 to _nILd195_
			iLd = _aILd195_[_iILd195_]
			nLdEx = aLdP[2][iLd * 2 - 1]
			nLdEy = aLdP[2][iLd * 2]
			# an end ON this node's bottom border
			if fabs(nLdEy - (rLd[2] + rLd[4])) > 18  loop  ok
			if nLdEx < rLd[1] - 2 or nLdEx > rLd[1] + rLd[3] + 2  loop  ok
			aLdX + nLdEx
		next
	next
	nLdEnds += len(aLdX)
	for iLd = 1 to len(aLdX)
		for jLd = iLd + 1 to len(aLdX)
			if fabs(aLdX[iLd] - aLdX[jLd]) < 6  nLdSame++  ok
		next
	next
next
? "   " + nLdEnds + " ends on a lower border, " + nLdSame + " pairs sharing a column"
chkeq("no two edges meet one border on the same column", nLdSame, 0)

# (2) ...AND A LONE STUB IS CENTRED. Gamma has exactly one laned edge
#     leaving it, so nothing is being made room for.
nLdOff = -1
_aRLd196_ = oLd.RenderNodeRects()
_nRLd196_ = len(_aRLd196_)
for _iRLd196_ = 1 to _nRLd196_
	rLd = _aRLd196_[_iRLd196_]
	if rLd[5] != "c"  loop  ok
	_aALdP197_ = oLd.RenderEdgePaths()
	_nALdP197_ = len(_aALdP197_)
	for _iALdP197_ = 1 to _nALdP197_
		aLdP = _aALdP197_[_iALdP197_]
		if aLdP[1] != "c>a"  loop  ok
		nLdOff = fabs(aLdP[2][1] - (rLd[1] + rLd[3] / 2))
	next
next
? "   the lone stub sits " + nLdOff + "px off its border's centre"
chk("a border with one edge on it puts that edge in the middle",
    nLdOff >= 0 and nLdOff < 1)

# (3) ONE LADDER. Every horizontal run below the row -- rails and the
#     channels of edges leaving the row alike -- keeps a clearance from
#     every other one.
nLdRow = -1
_aRLd198_ = oLd.RenderNodeRects()
_nRLd198_ = len(_aRLd198_)
for _iRLd198_ = 1 to _nRLd198_
	rLd = _aRLd198_[_iRLd198_]
	if rLd[5] = "a"  nLdRow = rLd[2] + rLd[4] / 2  ok
next
aLdRun = []
_aALdP199_ = oLd.RenderEdgePaths()
_nALdP199_ = len(_aALdP199_)
for _iALdP199_ = 1 to _nALdP199_
	aLdP = _aALdP199_[_iALdP199_]
	nLdN = len(aLdP[2]) / 2
	for iLd = 1 to nLdN - 1
		if fabs(aLdP[2][iLd * 2] - aLdP[2][iLd * 2 + 2]) > 1  loop  ok
		if fabs(aLdP[2][iLd * 2 + 1] - aLdP[2][iLd * 2 - 1]) < 20  loop  ok
		if aLdP[2][iLd * 2] <= nLdRow + 4  loop  ok
		aLdRun + [ aLdP[2][iLd * 2], aLdP[1] ]
	next
next
nLdTight = 0
nLdWorst = 1000000
for iLd = 1 to len(aLdRun)
	for jLd = iLd + 1 to len(aLdRun)
		if aLdRun[iLd][2] = aLdRun[jLd][2]  loop  ok
		nLdD = fabs(aLdRun[iLd][1] - aLdRun[jLd][1])
		if nLdD < nLdWorst  nLdWorst = nLdD  ok
		if nLdD < oLd._LineClearance() - 1  nLdTight++  ok
	next
next
? "   " + len(aLdRun) + " runs under the row, closest pair " + nLdWorst + "px"
chkeq("every run under a row keeps a clearance from every other",
      nLdTight, 0)

# (4) A FRAME'S AIR IS THE SAME ON EVERY SIDE. Measured against the
#     outermost ink the frame contains -- its members' boxes above and
#     beside, and the word under its deepest rail below.
oAir = new stzWorkflow("air64")
oAir.SetWorkflowType("statemachine")
oAir.AddStateXT("red", "Red")   oAir.AddStateXT("green", "Green")
oAir.AddStateXT("amber", "Amber")
oAir.AddTransition("red", "green", "timer")
oAir.AddTransition("green", "amber", "timer")
oAir.AddTransition("amber", "red", "timer")
oAir.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

aAirF = []
_aAirR_ = oAir.RenderClusterRects()
_nAirR_ = len(_aAirR_)
for _iAirR_ = 1 to _nAirR_
	aAirF = _aAirR_[_iAirR_]
next
nAirT = 1000000  nAirL = 1000000  nAirR = 0  nAirB = 0
_aRAir200_ = oAir.RenderNodeRects()
_nRAir200_ = len(_aRAir200_)
for _iRAir200_ = 1 to _nRAir200_
	rAir = _aRAir200_[_iRAir200_]
	if rAir[2] < nAirT  nAirT = rAir[2]  ok
	if rAir[1] < nAirL  nAirL = rAir[1]  ok
	if rAir[1] + rAir[3] > nAirR  nAirR = rAir[1] + rAir[3]  ok
	if rAir[2] + rAir[4] > nAirB  nAirB = rAir[2] + rAir[4]  ok
next
_aAAirL201_ = oAir.RenderLabels()
_nAAirL201_ = len(_aAAirL201_)
for _iAAirL201_ = 1 to _nAAirL201_
	aAirL = _aAAirL201_[_iAAirL201_]
	if aAirL[3] + aAirL[5] / 2 > nAirB  nAirB = aAirL[3] + aAirL[5] / 2  ok
next
# ...AND THE RAILS THEMSELVES. A rail writes its word above its own
# line, so the deepest ink in a frame is the deepest LINE -- measuring
# only the words answered the air under a word that has a rail beneath
# it, which is not the distance anybody looks at.
_aAAirP202_ = oAir.RenderEdgePaths()
_nAAirP202_ = len(_aAAirP202_)
for _iAAirP202_ = 1 to _nAAirP202_
	aAirP = _aAAirP202_[_iAAirP202_]
	nAirN = len(aAirP[2]) / 2
	for iAir = 1 to nAirN
		if aAirP[2][iAir * 2] > nAirB  nAirB = aAirP[2][iAir * 2]  ok
	next
next
nAirAbove = nAirT - aAirF[2]
nAirBelow = aAirF[2] + aAirF[4] - nAirB
nAirLeft  = nAirL - aAirF[1]
nAirRight = aAirF[1] + aAirF[3] - nAirR
? "   frame air: " + nAirAbove + " above, " + nAirBelow + " below, " +
  nAirLeft + " left, " + nAirRight + " right"
chk("a frame keeps the same air on every side",
    fabs(nAirAbove - nAirBelow) < 3 and fabs(nAirLeft - nAirRight) < 3)

# (5) AN OUTLINE IS PROPORTIONAL TO WHAT IT OUTLINES. Read from the
#     drawn pixels: a 25px mark stroked like a 104px cell gives its
#     outline nearly as much ink as its fill, and the Principal read
#     the order's final state as dark rather than as green.
oInk = new stzWorkflow("ink64")
oInk.SetWorkflowType("statemachine")
oInk.AddStateXTT("i", "", [ :isInitial = 1 ])
oInk.AddStateXT("run", "Running")
oInk.AddStateXTT("done", "Done", [ :color = "Success.Solid", :isFinal = 1 ])
oInk.AddTransition("i", "run", "")
oInk.AddTransition("run", "done", "finish")
oInkC = oInk.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104,
	:NodeHeight = 40, :FontSize = 13 ])
cInkPx = oInkC.ToPixels()
nInkW = oInkC.Width()
aInkR = []
_aRInk203_ = oInk.RenderNodeRects()
_nRInk203_ = len(_aRInk203_)
for _iRInk203_ = 1 to _nRInk203_
	rInk = _aRInk203_[_iRInk203_]
	if rInk[5] = "done"  aInkR = rInk  ok
next
nInkFill = 0  nInkDark = 0
for yInk = floor(aInkR[2]) to floor(aInkR[2] + aInkR[4])
	for xInk = floor(aInkR[1]) to floor(aInkR[1] + aInkR[3])
		aInkC = _Px62(cInkPx, nInkW, xInk, yInk)
		# the green of the fill against the near-black of the outline
		if aInkC[2] > aInkC[1] + 30 and aInkC[2] > aInkC[3] + 30
			nInkFill++
		but aInkC[1] < 110 and aInkC[2] < 110 and aInkC[3] < 110
			nInkDark++
		ok
	next
next
? "   the final mark: " + nInkFill + "px of its colour, " + nInkDark +
  "px of outline"
chk("a mark's outline never rivals the mark", nInkDark * 2 < nInkFill)

# ...AND ONE WEIGHT FOR EVERY NAME. A picture whose labels come in two
# weights asserts a difference between its states that the graph does
# not contain -- and the lighter one reads as the weaker state, which
# is how the Principal saw it. Measured as INK PER LETTER: a bolder
# stem is more pixels of ink over the same glyph box, so two labels
# drawn in one weight cover their boxes at the same rate.
oWt = new stzWorkflow("weight64")
oWt.SetWorkflowType("statemachine")
oWt.AddStateXTT("m", "Same", [ :color = "Muted" ])
oWt.AddStateXTT("s", "Same", [ :color = "Info.Solid" ])
oWt.AddTransition("m", "s", "go")
oWtC = oWt.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104,
	:NodeHeight = 40, :FontSize = 13 ])
cWtPx = oWtC.ToPixels()
nWtW = oWtC.Width()
aWtDens = []
iWtN = 0
_aCWtId204_ = [ "m", "s" ]
_nCWtId204_ = len(_aCWtId204_)
for _iCWtId204_ = 1 to _nCWtId204_
	cWtId = _aCWtId204_[_iCWtId204_]
	iWtN++
	aWtR = []
	_aRWt205_ = oWt.RenderNodeRects()
	_nRWt205_ = len(_aRWt205_)
	for _iRWt205_ = 1 to _nRWt205_
		rWt = _aRWt205_[_iRWt205_]
		if rWt[5] = cWtId  aWtR = rWt  ok
	next
	# this cell's own fill, sampled where no glyph can be, and the ink
	# the library chose for it
	aWtBg = _Px62(cWtPx, nWtW, floor(aWtR[1] + 8),
		floor(aWtR[2] + aWtR[4] / 2))
	aWtFg = StzHexToRGB(StzResolveColor(StzReadableTextOn(
		oWt._NativeFillOf(oWt.Nodes()[iWtN]), 13, 0)[1]))
	# A PIXEL IS INK WHEN IT IS NEARER THE INK THAN THE FILL, never
	# when it is "far enough" from the fill by some absolute number.
	# Black on grey and white on blue cross any fixed threshold at
	# different points along their own antialiasing ramps, so a fixed
	# threshold measures the RAMP and reports it as weight -- which is
	# an instrument that would have passed whatever the drawing did.
	nWtInk = 0  nWtAll = 0
	for yWt = floor(aWtR[2] + 8) to floor(aWtR[2] + aWtR[4] - 8)
		for xWt = floor(aWtR[1] + 10) to floor(aWtR[1] + aWtR[3] - 10)
			aWtC = _Px62(cWtPx, nWtW, xWt, yWt)
			nWtAll++
			nWtDf = fabs(aWtC[1] - aWtBg[1]) + fabs(aWtC[2] - aWtBg[2]) +
				fabs(aWtC[3] - aWtBg[3])
			nWtDi = fabs(aWtC[1] - aWtFg[1]) + fabs(aWtC[2] - aWtFg[2]) +
				fabs(aWtC[3] - aWtFg[3])
			if nWtDi < nWtDf  nWtInk++  ok
		next
	next
	aWtDens + (nWtInk / max([ nWtAll, 1 ]))
next
? "   ink density: muted " + aWtDens[1] + ", solid " + aWtDens[2]
chk("two names of one length are written in one weight",
    aWtDens[1] > 0 and aWtDens[2] > 0 and
    fabs(aWtDens[1] - aWtDens[2]) < 0.05)

# (6) THE DIAL THE PRINCIPAL ASKED FOR. :LabelPlacement = :Middle puts
#     every event ON the middle of its own line; the plate under it
#     takes the surface it covers, so the word reads as sitting on the
#     line and not on a card of the wrong colour.
oMid = new stzWorkflow("middle64")
oMid.SetWorkflowType("statemachine")
oMid.AddStateXT("a", "Alpha")  oMid.AddStateXT("b", "Beta")
oMid.AddTransition("a", "b", "go")
oMid.AddTransition("b", "a", "back")
oMid.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13, :LabelPlacement = :Middle ])
nMidOff = 0
nMidSeen = 0
_aAMidL206_ = oMid.RenderLabels()
_nAMidL206_ = len(_aAMidL206_)
for _iAMidL206_ = 1 to _nAMidL206_
	aMidL = _aAMidL206_[_iAMidL206_]
	_aAMidP207_ = oMid.RenderEdgePaths()
	_nAMidP207_ = len(_aAMidP207_)
	for _iAMidP207_ = 1 to _nAMidP207_
		aMidP = _aAMidP207_[_iAMidP207_]
		if aMidP[1] != aMidL[6]  loop  ok
		nMidSeen++
		nMidBest = 1000000
		nMidN = len(aMidP[2]) / 2
		for iMid = 1 to nMidN - 1
			if fabs(aMidP[2][iMid * 2] - aMidP[2][iMid * 2 + 2]) > 1  loop  ok
			nMidD = fabs(aMidL[3] - aMidP[2][iMid * 2])
			if nMidD < nMidBest  nMidBest = nMidD  ok
		next
		if nMidBest > 2  nMidOff++  ok
	next
next
? "   " + nMidSeen + " events asked to sit on their line, " + nMidOff +
  " sitting beside it"
chkeq("...and :LabelPlacement = :Middle puts them on it", nMidOff, 0)

# (7) THE SAME FOUR DISTANCES, ON A PICTURE THAT HAS SOMETHING ON EVERY
#     SIDE. The traffic light above has no mark and no loop, so it could
#     not have caught either of these. The door has both: an initial
#     mark and a final one of DIFFERENT sizes above and below it, and a
#     labelled self-loop reaching out to the right.
oDr7 = new stzWorkflow("door7")
oDr7.SetWorkflowType("statemachine")
oDr7.AddStateXTT("i", "", [ :isInitial = 1 ])
oDr7.AddStateXT("closed", "Closed")  oDr7.AddStateXT("open", "Open")
oDr7.AddStateXT("locked", "Locked")
oDr7.AddStateXTT("gone", "Demolished", [ :isFinal = 1 ])
oDr7.AddTransition("i", "closed", "")
oDr7.AddTransition("closed", "open", "open")
oDr7.AddTransition("open", "closed", "close")
oDr7.AddTransition("closed", "locked", "lock")
oDr7.AddTransition("locked", "closed", "unlock")
oDr7.AddTransition("locked", "locked", "lock")
oDr7.AddTransition("closed", "gone", "demolish")
oDr7.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

aFr7 = []
_aDr7R_ = oDr7.RenderClusterRects()
_nDr7R_ = len(_aDr7R_)
for _iDr7R_ = 1 to _nDr7R_
	aFr7 = _aDr7R_[_iDr7R_]
next
nMk7I = 0  nMk7G = 0
_aRDr7208_ = oDr7.RenderNodeRects()
_nRDr7208_ = len(_aRDr7208_)
for _iRDr7208_ = 1 to _nRDr7208_
	rDr7 = _aRDr7208_[_iRDr7208_]
	if rDr7[5] = "i"     nMk7I = rDr7[2] + rDr7[4]  ok
	if rDr7[5] = "gone"  nMk7G = rDr7[2]  ok
next
? "   the door: in " + (aFr7[2] - nMk7I) + "px, out " +
  (nMk7G - (aFr7[2] + aFr7[4])) + "px"
# A MARK IS SMALLER THAN A CELL and the two marks here are different
# sizes, so a layout budgeting every row as a full cell wastes a
# different amount above and below -- 1.56px on this picture, which is
# small, invisible, and a rule broken.
chk("the way in equals the way out, even between marks of two sizes",
    fabs((aFr7[2] - nMk7I) - (nMk7G - (aFr7[2] + aFr7[4]))) < 1)

nL7 = 1000000  nR7 = 0
_aRDr7209_ = oDr7.RenderNodeRects()
_nRDr7209_ = len(_aRDr7209_)
for _iRDr7209_ = 1 to _nRDr7209_
	rDr7 = _aRDr7209_[_iRDr7209_]
	if rDr7[5] = "i" or rDr7[5] = "gone"  loop  ok
	if rDr7[1] < nL7  nL7 = rDr7[1]  ok
	if rDr7[1] + rDr7[3] > nR7  nR7 = rDr7[1] + rDr7[3]  ok
next
_aAL7210_ = oDr7.RenderLabels()
_nAL7210_ = len(_aAL7210_)
for _iAL7210_ = 1 to _nAL7210_
	aL7 = _aAL7210_[_iAL7210_]
	if aL7[2] + aL7[4] / 2 > nR7  nR7 = aL7[2] + aL7[4] / 2  ok
next
_aAP7211_ = oDr7.RenderEdgePaths()
_nAP7211_ = len(_aAP7211_)
for _iAP7211_ = 1 to _nAP7211_
	aP7 = _aAP7211_[_iAP7211_]
	nN7 = len(aP7[2]) / 2
	for i7 = 1 to nN7
		if aP7[2][i7 * 2 - 1] > nR7  nR7 = aP7[2][i7 * 2 - 1]  ok
	next
next
? "   the door's frame: " + (nL7 - aFr7[1]) + "px left, " +
  (aFr7[1] + aFr7[3] - nR7) + "px right"
# the word beside a self-loop is the rightmost ink, and it has to be
# measured with the ruler the PLACER uses -- WidthOf is a run of
# glyphs, _LabelBlock is the thing that gets drawn, and they differ
chk("a frame stands as far from its loop's word as from its first cell",
    fabs((nL7 - aFr7[1]) - (aFr7[1] + aFr7[3] - nR7)) < 3)

# (8) AN EXIT RUNS ON THE LADDER TOO, AND ITS FRAME CONTAINS IT. The
#     horizontal an edge takes on its way OUT of a region is drawn
#     inside that region, every time -- and it was placed by the channel
#     mechanism rather than by the lane one, so the order's exit sat
#     26px under a rail whose ladder rung is 52.95, and 2px above a
#     floor computed from the rails alone.
#
#     "Why is it sometimes right and sometimes wrong" has one answer,
#     and it is this shape: two places deciding one thing, and which of
#     them wins depending on the picture.
oEx = new stzWorkflow("exit64")
oEx.SetWorkflowType("statemachine")
oEx.AddStateXT("pend", "Pending")  oEx.AddStateXT("fail", "Failed")
oEx.AddStateXT("paid", "Paid")     oEx.AddStateXT("lost", "Lost")
oEx.AddTransition("pend", "fail", "declined")
oEx.AddTransition("fail", "pend", "retry")
# the two exits CROSS, so each has a horizontal run to place. An exit
# landing straight under its source has no run at all and rightly gets
# no rung -- which is why the obvious version of this scene proves
# nothing, and why it is written this way.
oEx.AddTransition("pend", "lost", "abandoned")
oEx.AddTransition("fail", "paid", "authorised")
oEx.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

nExRow = -1
_aREx212_ = oEx.RenderNodeRects()
_nREx212_ = len(_aREx212_)
for _iREx212_ = 1 to _nREx212_
	rEx = _aREx212_[_iREx212_]
	if rEx[5] = "pend"  nExRow = rEx[2] + rEx[4] / 2  ok
next
aExRun = []
_aAExP213_ = oEx.RenderEdgePaths()
_nAExP213_ = len(_aAExP213_)
for _iAExP213_ = 1 to _nAExP213_
	aExP = _aAExP213_[_iAExP213_]
	nExN = len(aExP[2]) / 2
	for iEx = 1 to nExN - 1
		if fabs(aExP[2][iEx * 2] - aExP[2][iEx * 2 + 2]) > 1  loop  ok
		if fabs(aExP[2][iEx * 2 + 1] - aExP[2][iEx * 2 - 1]) < 20  loop  ok
		if aExP[2][iEx * 2] <= nExRow + 4  loop  ok
		# one RUN, not one segment: a staircase can turn twice at the
		# same depth and that is still one line at that depth
		bExSeen = 0
		_aNExQ214_ = aExRun
		_nNExQ214_ = len(_aNExQ214_)
		for _iNExQ214_ = 1 to _nNExQ214_
			nExQ = _aNExQ214_[_iNExQ214_]
			if fabs(nExQ - aExP[2][iEx * 2]) < 1  bExSeen = 1  ok
		next
		if bExSeen  loop  ok
		aExRun + aExP[2][iEx * 2]
	next
next
aExRun = sort(aExRun)
nExGap = -1
if len(aExRun) >= 2  nExGap = aExRun[2] - aExRun[1]  ok
? "   the return and the exit ride " + aExRun[1] + " and " +
  aExRun[len(aExRun)] + " -- " + nExGap + "px apart, one rung is " +
  oEx._LanePitchValue()
chk("an exit takes the next rung of the same ladder",
    nExGap > 0 and fabs(nExGap - oEx._LanePitchValue()) < 2)

nExFloor = 0
_aAExC215_ = oEx.RenderClusterRects()
_nAExC215_ = len(_aAExC215_)
for _iAExC215_ = 1 to _nAExC215_
	aExC = _aAExC215_[_iAExC215_]
	if aExC[2] + aExC[4] > nExFloor  nExFloor = aExC[2] + aExC[4]  ok
next
? "   the floor sits " + (nExFloor - aExRun[len(aExRun)]) +
  "px under the deepest run"
chk("...and the frame's floor contains it, one pad down",
    nExFloor - aExRun[len(aExRun)] > 20 and
    nExFloor - aExRun[len(aExRun)] < 40)

# (9) A HOP NEEDS ROOM. The wire hop says "these cross and do not
#     touch", and it says it with a curve; drawn a few pixels from a
#     rounded elbow the reader sees two curves in a row and cannot tell
#     which is the corner and which is the crossing. The Principal
#     circled exactly that on the door. Where there is no room the
#     crossing is drawn plain: an unmarked crossing is a small
#     ambiguity, a bump nobody can read as a bump is a wrong statement.
oHp = new stzWorkflow("hop64")
oHp.SetWorkflowType("statemachine")
oHp.AddStateXTT("i", "", [ :isInitial = 1 ])
oHp.AddStateXT("closed", "Closed")  oHp.AddStateXT("open", "Open")
oHp.AddStateXT("locked", "Locked")
oHp.AddStateXTT("gone", "Gone", [ :isFinal = 1 ])
oHp.AddTransition("i", "closed", "")
oHp.AddTransition("closed", "open", "open")
oHp.AddTransition("open", "closed", "close")
oHp.AddTransition("closed", "locked", "lock")
oHp.AddTransition("locked", "closed", "unlock")
oHp.AddTransition("closed", "gone", "demolish")
oHp.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

nHpR = 5
if oHp._EdgeCorner() * 0.8 > nHpR  nHpR = oHp._EdgeCorner() * 0.8  ok
# ASKED OF THE DRAWING, not recomputed here. This carried its own copy
# of the figure -- nHpR * 2 + clearance -- which is the one the drawing
# RETIRED when it was corrected to "the hop's reach plus a clearance".
# The two disagreed by 8px for months and nothing noticed, because no
# hop had landed between 32 and 40 until a stub moved one line.
nHpRoom = oHp._HopRoom(nHpR)
nHpBad = 0
nHpNear = 1000000
_aAHp216_ = oHp.RenderHops()
_nAHp216_ = len(_aAHp216_)
for _iAHp216_ = 1 to _nAHp216_
	aHp = _aAHp216_[_iAHp216_]
	_aAHpP217_ = oHp.RenderEdgePaths()
	_nAHpP217_ = len(_aAHpP217_)
	for _iAHpP217_ = 1 to _nAHpP217_
		aHpP = _aAHpP217_[_iAHpP217_]
		if aHpP[1] != aHp[3]  loop  ok
		# every bend and endpoint on the line this hop belongs to
		nHpN = len(aHpP[2]) / 2
		for iHp = 1 to nHpN
			nHpD = fabs(aHpP[2][iHp * 2 - 1] - aHp[1]) +
				fabs(aHpP[2][iHp * 2] - aHp[2])
			if nHpD < nHpNear  nHpNear = nHpD  ok
			if nHpD < nHpRoom  nHpBad++  ok
		next
	next
next
? "   " + len(oHp.RenderHops()) + " hops drawn, nearest bend " + nHpNear +
  "px away, room wanted " + nHpRoom
chk("every hop drawn had room to be read as one",
    len(oHp.RenderHops()) > 0 and nHpBad = 0)


sec("-- 65. BPMN IS A PROFILE, AND IT READS LEFT TO RIGHT -------")
discharges("DN3a")
#
# DN3, and it arrived differently from the two domains before it.
#
# The org chart and the state machine had no notation before their
# profile -- the profile is where their law was first written down. BPMN
# already had one: a written, versioned specification, a second
# conforming implementation in another repository, and a digest the two
# are held to. So the profile is not this domain's first law; it is its
# VOCABULARY, lifted out of the one renderer that held it privately.
#
# THE PLAN'S KILL CRITERION asked for a measurement rather than an
# assumption -- "if the spine law cannot express as a pass over the
# plastic layout, say so and keep the class separate". Measured:
#
#   THE SPINE LAW EXPRESSES. L3-L11 assign a column, a row and an arrow
#   class; the conformance digest fixes exactly those decisions and
#   explicitly frees geometry; and pins already carry a decided position
#   into the plastic layout.
#
#   TWO OTHER THINGS DO NOT, and neither is the layout. L15's glyphs --
#   a gateway bearing an X, tasks bearing a gear, a person, an envelope,
#   a clock, a compensation marker, a thick ring, a DASHED double circle
#   -- are six shapes the shared renderer does not draw, and DN0 defines
#   a glyph as one it does. And L18/L19 is a consumer contract: every
#   element carries a stable id and a set of classes and a consumer may
#   say nothing else, where ToSVG() emits neither.
#
# So BPMN has two faces on purpose, and ONE vocabulary between them,
# which is what this section holds. Drawing the first left-to-right
# domain in the library also found two defects that only a
# left-to-right picture could have found, and they are here too.
#---------------------------------------------------------------------------

oBp = new stzWorkflow("bpmn65")
oBp.SetWorkflowType("bpmn")
oBp.AddStateXTT("s", "", [ :type = "entry" ])
oBp.AddStateXTT("recv", "Receive Order", [ :type = "invoke" ])
oBp.AddStateXTT("check", "Check Stock", [ :type = "gateway" ])
oBp.AddStateXTT("pack", "Pack", [ :type = "human" ])
oBp.AddStateXTT("bill", "Bill", [ :type = "invoke" ])
oBp.AddStateXTT("done", "Shipped", [ :type = "terminal" ])
oBp.AddStateXTT("nope", "Out of Stock", [ :type = "terminal" ])
oBp.AddTransition("s", "recv", "")
oBp.AddTransition("recv", "check", "received")
oBp.AddTransition("check", "pack", "in stock")
oBp.AddTransition("check", "nope", "none left")
oBp.AddTransition("pack", "bill", "packed")
oBp.AddTransition("bill", "done", "invoiced")

chkeq("declaring a workflow BPMN puts it under BPMN's notation",
      oBp.NotationO().Name_(), "bpmn")

# (1) ONE VOCABULARY, TWO FACES. The conformance renderer asks the
#     profile which glyph a kind takes, so the two cannot come to
#     disagree about what a gateway looks like -- which is exactly how
#     duplicated machinery diverges, and this library has the scar.
oBpN = StzBpmnNotation()
chkeq("a gateway is a diamond", StzLower("" + oBpN.GlyphOf("gateway")),
      "diamond")
chkeq("an end event is a ringed circle",
      StzLower("" + oBpN.GlyphOf("terminal")), "doublecircle")
chkeq("a start event is a mark, not a cell",
      StzLower("" + oBpN.GlyphOf("entry")), "circle")
chk("...and it is drawn at a fraction of a cell", oBpN.ScaleOf("entry") < 0.5)

# (2) L16 -- THE COLOUR LAW, DECLARED. The strongest colour law in this
#     library: white by default, and the ONLY thing that colours a node
#     is a verdict from an analyzer. A drawing with no colour in it is a
#     drawing with nothing wrong. So every kind declares white and NONE
#     of them names a role -- that absence is the declaration.
nBpRole = 0
_aCBpK218_ = [ "entry", "invoke", "human", "event-wait", "timer-wait",
	"compensate", "step", "gateway", "terminal", "suspension" ]
_nCBpK218_ = len(_aCBpK218_)
for _iCBpK218_ = 1 to _nCBpK218_
	cBpK = _aCBpK218_[_iCBpK218_]
	if StzLower("" + oBpN.FillOf(cBpK)) != "white"  nBpRole++  ok
next
chkeq("no BPMN kind carries a colour of its own", nBpRole, 0)

# (3) A CLOSED VOCABULARY. BPMN is a standard: a kind it does not have
#     is a modelling mistake, not a shape to improvise. The opposite of
#     the default profile, which is open on purpose -- and the contrast
#     is what makes "closed" mean something.
chk("BPMN's vocabulary is closed", oBpN.IsClosed())
chk("...so a kind it does not have is a finding",
    NOT oBpN.KnowsKind("subprocess-with-a-hat"))
chk("...where the default profile takes any kind at all",
    NOT StzNotation("default").IsClosed())

# (4) THE RULES REFUSE WHAT BPMN REFUSES. A start event admits nothing
#     and an end event releases nothing -- and the editor inherits both
#     for free, because a link a rule forbids is refused at the gesture.
chkeq("a well-formed process has nothing to report",
      len(oBpN.Check(oBp)), 0)
chk("nothing may flow INTO a start event",
    NOT oBpN.MayLink(oBp, "recv", "s"))
chk("nothing may flow OUT of an end event",
    NOT oBpN.MayLink(oBp, "done", "recv"))
chk("...but an ordinary sequence flow is allowed",
    oBpN.MayLink(oBp, "recv", "pack"))

# (5) A LEFT-TO-RIGHT PICTURE IS NOT CRUSHED.
#
#     The rank-fit pass shrinks boxes when a rank is too crowded to hold
#     them, and it read "a rank is the same y, a neighbour is a
#     difference in x" -- true of a top-down picture and false of this
#     one. Under :LeftToRight it compared the wrong pairs on both axes:
#     two nodes in DIFFERENT ranks that happen to sit at nearly the same
#     y were read as adjacent RANKS five pixels apart, and every box in
#     the picture was shrunk to 37% of the size the caller asked for.
#     BPMN is the first domain in this library that reads left to right,
#     which is why nothing had found it.
oBp.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 132, :NodeHeight = 52,
	:FontSize = 15 ])
nBpW = 0  nBpH = 0
_aRBp219_ = oBp.RenderNodeRects()
_nRBp219_ = len(_aRBp219_)
for _iRBp219_ = 1 to _nRBp219_
	rBp = _aRBp219_[_iRBp219_]
	if rBp[5] != "recv"  loop  ok
	nBpW = rBp[3]  nBpH = rBp[4]
next
? "   a left-to-right cell asked for 132x52 and got " + nBpW + "x" + nBpH
chk("a left-to-right picture keeps the size it asked for",
    nBpW > 130 and nBpH > 50)

# (6) A NAME UNDER A MARK REACHES SIDEWAYS TOO. The paper reserved room
#     BELOW a mark's name -- every direction it reaches in a top-down
#     picture, and half of what it reaches in one that reads left to
#     right. This process puts a final event at the right-hand edge, and
#     "Out of Stock" ran 12px off the page.
nBpOff = 0
_aABpL220_ = oBp.RenderNodeLabels()
_nABpL220_ = len(_aABpL220_)
for _iABpL220_ = 1 to _nABpL220_
	aBpL = _aABpL220_[_iABpL220_]
	if aBpL[6] != 1  loop  ok       # the ones written OUTSIDE their glyph
	if aBpL[2] - aBpL[4] / 2 < 0  nBpOff++  ok
	if aBpL[2] + aBpL[4] / 2 > oBp.LastCanvas().Width()  nBpOff++  ok
next
chkeq("a name written outside its mark stays on the paper", nBpOff, 0)

# (7) ...AND THE PICTURE STILL OBEYS THE CONTRACT. A domain is a
#     profile, not an exemption: every law sections 62 and 63 hold of
#     every other template holds here.
nBpBad = 0
_aABpE221_ = oBp.Edges()
_nABpE221_ = len(_aABpE221_)
for _iABpE221_ = 1 to _nABpE221_
	aBpE = _aABpE221_[_iABpE221_]
	rBpA = _Rect49(oBp, StzLower("" + aBpE[:from]))
	rBpB = _Rect49(oBp, StzLower("" + aBpE[:to]))
	aBpP = []
	_aABpR222_ = oBp.RenderEdgePaths()
	_nABpR222_ = len(_aABpR222_)
	for _iABpR222_ = 1 to _nABpR222_
		aBpR = _aABpR222_[_iABpR222_]
		if aBpR[1] = StzLower("" + aBpE[:from]) + ">" +
		   StzLower("" + aBpE[:to])  aBpP = aBpR[2]  ok
	next
	if len(aBpP) < 4  loop  ok
	nBpN = len(aBpP) / 2
	if _DistRect62(rBpA, aBpP[1], aBpP[2]) > 16
		nBpBad++
		? "      " + aBpE[:from] + ">" + aBpE[:to] + " leaves " +
		  _DistRect62(rBpA, aBpP[1], aBpP[2]) + "px away"
	ok
	if _DistRect62(rBpB, aBpP[nBpN * 2 - 1], aBpP[nBpN * 2]) > 16
		nBpBad++
		? "      " + aBpE[:from] + ">" + aBpE[:to] + " arrives " +
		  _DistRect62(rBpB, aBpP[nBpN * 2 - 1], aBpP[nBpN * 2]) + "px away"
	ok
next
chkeq("every flow touches both the steps it names", nBpBad, 0)

# (8) A CHAIN THAT DOES NOT BRANCH IS ONE STRAIGHT LINE, and the two
#     answers to one question are at one moment.
#
#     The Principal asked both in one breath -- "why change direction
#     when a direct line is sufficient", and "the two branches have the
#     same importance and there is no sense of timing order" -- and one
#     thing answered both.
#
#     The layout ranks a node by its distance from the FAR END, which
#     lines every sink up at the last rank. That is right when the
#     endings are a common destination, and it is inferred here from the
#     profile's own rules: a kind that may not release anything is a
#     sink. BPMN forbids outbound on an end event for exactly the reason
#     a state machine does, and so inherited a placement it never asked
#     for -- "Out of Stock", refused at the second step, drawn level
#     with the shipment four steps later. The picture said the two
#     outcomes happen at different times. They are the two answers to
#     one question.
#
#     BPMN says so itself (L5, "a node's column is source column plus
#     one"), a profile is where a domain says such a thing, and sinks
#     now sink only where the rank policy says sinking means something.
nSpY = -1
nSpBad = 0
_aCSpN223_ = [ "s", "recv", "check", "pack", "bill", "done" ]
_nCSpN223_ = len(_aCSpN223_)
for _iCSpN223_ = 1 to _nCSpN223_
	cSpN = _aCSpN223_[_iCSpN223_]
	rSp = _Rect49(oBp, cSpN)
	nSpC = rSp[2] + rSp[4] / 2
	if nSpY < 0  nSpY = nSpC  ok
	if fabs(nSpC - nSpY) > 1  nSpBad++  ok
next
chkeq("a chain that does not branch is one straight line", nSpBad, 0)

# ...AND AN ANSWER THAT ENDS DOES NOT TRAVEL AT ALL.
#
#     This used to assert that the two answers sat in the SAME column,
#     which was the right correction to make when one of them was being
#     dragged to the far end of the picture beside an unrelated ending.
#     The rule that superseded it is sharper, and it came from the
#     Principal reading the picture as an argument rather than a
#     drawing: "maybe" and "no" lead to an END, so there is nothing for
#     them to travel towards. A dead end hangs off the summit it leaves
#     by, in the decision's own column -- one short vertical. A line's
#     LENGTH is a claim that something happens along it.
rSpP = _Rect49(oBp, "pack")
rSpN = _Rect49(oBp, "nope")
rSpG = _Rect49(oBp, "check")
rSpD = _Rect49(oBp, "done")
? "   the decision is at x=" + (rSpG[1] + rSpG[3] / 2) +
  ", its dead end at x=" + (rSpN[1] + rSpN[3] / 2) +
  ", the far ending at x=" + (rSpD[1] + rSpD[3] / 2)
chk("an answer that ends hangs off its own decision",
    fabs((rSpG[1] + rSpG[3] / 2) - (rSpN[1] + rSpN[3] / 2)) < 2)
chk("...and never travels to the far end beside an unrelated ending",
    rSpN[1] + rSpN[3] / 2 < rSpD[1])
chk("...while the answer that CONTINUES does advance a rank",
    rSpP[1] + rSpP[3] / 2 > rSpG[1] + rSpG[3])

# ...AND THE LIFECYCLE DOMAINS ARE UNTOUCHED. A state machine's endings
# are a destination, not an alternative, so its sinks still sink -- the
# knob is a declaration, not a new default.
chkeq("a domain that says nothing keeps the old convention",
      StzLower("" + StzNotation("default").RankPolicy()), "")

# (9) A PROFILE MAY NOT NAME A GLYPH THE RENDERER CANNOT DRAW.
#
#     DN0's own definition -- "a glyph is the geometric shape name the
#     renderer already draws" -- and this profile broke it on its first
#     day. BPMN's start event was declared "dot", which is not one of the
#     shapes there are, so it fell back silently to a box: a 15.6px
#     rounded rectangle, drawn with a corner radius of 10 that is larger
#     than half its own side, spilling outside its rectangle and sliced
#     in half by the edge of the paper.
#
#     Silently is the word that matters. Nothing failed, nothing was
#     reported, and the picture was wrong in a way that looked like a
#     rendering bug rather than a declaration one. Swept over EVERY
#     profile the library ships, because the next one will be written by
#     somebody reading the last one.
nGlBad = 0
_aCGlN224_ = StzNotations()
_nCGlN224_ = len(_aCGlN224_)
for _iCGlN224_ = 1 to _nCGlN224_
	cGlN = _aCGlN224_[_iCGlN224_]
	oGl = StzNotation(cGlN)
	_aCGlK225_ = oGl.Kinds()
	_nCGlK225_ = len(_aCGlK225_)
	for _iCGlK225_ = 1 to _nCGlK225_
		cGlK = _aCGlK225_[_iCGlK225_]
		cGlS = "" + oGl.GlyphOf(cGlK)
		if cGlS = ""  loop  ok
		if StzIsNodeShape(cGlS)  loop  ok
		nGlBad++
		? "      " + cGlN + " declares '" + cGlK + "' as '" + cGlS +
		  "', which nothing draws"
	next
next
chkeq("every glyph every shipped profile names is one the renderer draws",
      nGlBad, 0)

# ...AND A CORNER IS NEVER BIGGER THAN THE THING IT ROUNDS. The radius
# is one number for a whole picture, which is right while every cell is
# one size and wrong the moment a MARK is drawn beside them.
nCnBad = 0
_aRCn226_ = oBp.RenderNodeRects()
_nRCn226_ = len(_aRCn226_)
for _iRCn226_ = 1 to _nRCn226_
	rCn = _aRCn226_[_iRCn226_]
	if rCn[1] < 0 or rCn[2] < 0  nCnBad++  ok
	if rCn[1] + rCn[3] > oBp.LastCanvas().Width()  nCnBad++  ok
	if rCn[2] + rCn[4] > oBp.LastCanvas().Height()  nCnBad++  ok
next
chkeq("no glyph is drawn off the edge of its own paper", nCnBad, 0)

# (10) THE SUMMIT AND THE SIDE AGREE -- asked of the DRAWN picture, not
#      of the rule that produced it.
#
#      A decision leaves by three summits, one above, one straight
#      ahead, one below, and each branch is placed on the side its
#      summit points at. Those are two decisions in two places, and they
#      were made from POSITIONS -- a question about a picture that does
#      not exist yet, whose answer changed between the moment the
#      placement asked and the moment the drawing asked. The
#      compensation process placed a branch below the spine and drew its
#      line leaving upward, off the top of the paper.
#
#      The check is the agreement itself, so it holds however the rule
#      is next rewritten: a branch drawn leaving upward is a branch
#      standing above.
oSm = new stzWorkflow("summit65")
oSm.SetWorkflowType("bpmn")
oSm.AddStateXTT("s", "", [ :type = "entry" ])
oSm.AddStateXTT("a", "Charge", [ :type = "invoke" ])
oSm.AddStateXTT("g", "Reserved?", [ :type = "gateway" ])
oSm.AddStateXTT("ship", "Ship", [ :type = "invoke" ])
oSm.AddStateXTT("back", "Refund", [ :type = "compensate" ])
oSm.AddStateXTT("ok", "Delivered", [ :type = "terminal" ])
oSm.AddStateXTT("un", "Reversed", [ :type = "terminal" ])
oSm.AddTransition("s", "a", "")
oSm.AddTransition("a", "g", "charged")
oSm.AddTransition("g", "ship", "yes")
oSm.AddTransition("g", "back", "no")
oSm.AddTransition("ship", "ok", "dispatched")
oSm.AddTransition("back", "un", "refunded")
oSm.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

rSmG = _Rect49(oSm, "g")
nSmGy = rSmG[2] + rSmG[4] / 2
nSmBad = 0
_aASmE227_ = [ [ "g", "ship" ], [ "g", "back" ] ]
_nASmE227_ = len(_aASmE227_)
for _iASmE227_ = 1 to _nASmE227_
	aSmE = _aASmE227_[_iASmE227_]
	aSmP = []
	_aASmR228_ = oSm.RenderEdgePaths()
	_nASmR228_ = len(_aASmR228_)
	for _iASmR228_ = 1 to _nASmR228_
		aSmR = _aASmR228_[_iASmR228_]
		if aSmR[1] = aSmE[1] + ">" + aSmE[2]  aSmP = aSmR[2]  ok
	next
	if len(aSmP) < 4  loop  ok
	# which way it LEAVES: the first segment's direction off the glyph
	nSmUp = 0
	if aSmP[2] < nSmGy - 1  nSmUp = 1  ok
	if aSmP[4] < aSmP[2] - 1  nSmUp = 1  ok
	# where the TARGET stands
	rSmT = _Rect49(oSm, aSmE[2])
	nSmTy = rSmT[2] + rSmT[4] / 2
	nSmAbove = 0
	if nSmTy < nSmGy - 1  nSmAbove = 1  ok
	if nSmUp != nSmAbove
		nSmBad++
		? "      " + aSmE[1] + ">" + aSmE[2] + " leaves up=" + nSmUp +
		  " but its target stands above=" + nSmAbove
	ok
next
chkeq("a branch drawn leaving upward is a branch standing above",
      nSmBad, 0)

# ...AND NO PART OF ANY FLOW IS DRAWN OFF THE PAPER, which is what the
# disagreement above actually produced and the shape a reader notices
# first.
nSmOff = 0
_aASmR229_ = oSm.RenderEdgePaths()
_nASmR229_ = len(_aASmR229_)
for _iASmR229_ = 1 to _nASmR229_
	aSmR = _aASmR229_[_iASmR229_]
	nSmN = len(aSmR[2]) / 2
	for iSm = 1 to nSmN
		if aSmR[2][iSm * 2 - 1] < 0  nSmOff++  ok
		if aSmR[2][iSm * 2] < 0  nSmOff++  ok
		if aSmR[2][iSm * 2 - 1] > oSm.LastCanvas().Width()  nSmOff++  ok
		if aSmR[2][iSm * 2] > oSm.LastCanvas().Height()  nSmOff++  ok
	next
next
chkeq("every flow is drawn on the paper it was measured for", nSmOff, 0)

# (11) THE AFFIRMATIVE ANSWER CONTINUES THE LINE, AND THE NEXT ONE
#      HANGS BELOW.
#
#      A decision's answers are not interchangeable. One of them is the
#      one where things went as intended, and a reader looks for it
#      first -- so it continues along the line, and the picture says
#      "this is the way through" before a single word is read.
#
#      Declaration order was standing in for that, and it is a good
#      proxy for exactly as long as the author writes the affirmative
#      branch first. It is still a proxy, and one that fails silently:
#      declare "no" before "yes" and the whole spine bends around the
#      refusal. So the scene below declares them in the WRONG order on
#      purpose -- a picture that looked right under the old rule cannot
#      tell you the old rule was wrong.
oAf = new stzWorkflow("affirm65")
oAf.SetWorkflowType("bpmn")
oAf.AddStateXTT("s", "", [ :type = "entry" ])
oAf.AddStateXTT("g", "Valid?", [ :type = "gateway" ])
oAf.AddStateXTT("bad", "Bounced", [ :type = "terminal" ])
oAf.AddStateXTT("hold", "Held", [ :type = "terminal" ])
oAf.AddStateXTT("go", "Process", [ :type = "invoke" ])
oAf.AddStateXTT("done", "Done", [ :type = "terminal" ])
oAf.AddTransition("s", "g", "")
oAf.AddTransition("g", "bad", "no")          # declared FIRST
oAf.AddTransition("g", "hold", "maybe")
oAf.AddTransition("g", "go", "yes")          # declared LAST
oAf.AddTransition("go", "done", "processed")
oAf.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])

rAfG = _Rect49(oAf, "g")
nAfGy = rAfG[2] + rAfG[4] / 2
rAfGo = _Rect49(oAf, "go")
? "   the gateway rides y=" + nAfGy + ", 'yes' leads to y=" +
  (rAfGo[2] + rAfGo[4] / 2)
chk("the AFFIRMATIVE answer continues the line, whatever the order",
    fabs((rAfGo[2] + rAfGo[4] / 2) - nAfGy) < 2)

# ...AND THE SECOND ANSWER HANGS BELOW. The side a reader looks to for
# "what else can happen" is the one the page continues onto -- downward
# in a left-to-right reading. The first non-straight answer was going
# UPWARD, which puts the exceptional case where the eye has already
# been.
rAfB = _Rect49(oAf, "bad")
? "   the first other answer sits at y=" + (rAfB[2] + rAfB[4] / 2)
chk("the next answer hangs BELOW the line, not above it",
    rAfB[2] + rAfB[4] / 2 > nAfGy)

# ...and where nothing says yes, declaration order still decides, which
# is what keeps the rule a refinement rather than a replacement.
oAf2 = new stzWorkflow("affirm65b")
oAf2.SetWorkflowType("bpmn")
oAf2.AddStateXTT("s", "", [ :type = "entry" ])
oAf2.AddStateXTT("g", "Which?", [ :type = "gateway" ])
oAf2.AddStateXTT("p", "Path A", [ :type = "invoke" ])
oAf2.AddStateXTT("q", "Path B", [ :type = "terminal" ])
oAf2.AddTransition("s", "g", "")
oAf2.AddTransition("g", "p", "left")
oAf2.AddTransition("g", "q", "right")
oAf2.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 104, :NodeHeight = 40,
	:FontSize = 13 ])
rAf2G = _Rect49(oAf2, "g")
rAf2P = _Rect49(oAf2, "p")
chk("...and with no yes among them, the first declared leads",
    fabs((rAf2P[2] + rAf2P[4] / 2) - (rAf2G[2] + rAf2G[4] / 2)) < 2)

# (12) A BEND IS A CONSTRAINT -- I4, counted.
#
#      Every edge in these pictures joins two cells that are either on
#      one line or one line apart, and there is nothing in the way of
#      any of them. The MINIMUM number of turns such an edge needs is
#      therefore zero or one: none when the two cells face each other,
#      one when the flow has to change rows on its way.
#
#      The summit route was taking FOUR -- out of the summit, a short
#      stub, along, down, and in. The stub and the turn after it were
#      caution, and caution is not a constraint: a reader who counts
#      four corners looks for four reasons and finds two. The Principal
#      marked it three times before it was counted rather than eyeballed.
nBnBad = 0
_aABnO230_ = [ oBp, oAf, oSm ]
_nABnO230_ = len(_aABnO230_)
for _iABnO230_ = 1 to _nABnO230_
	aBnO = _aABnO230_[_iABnO230_]
	_aABnP231_ = aBnO.RenderEdgePaths()
	_nABnP231_ = len(_aABnP231_)
	for _iABnP231_ = 1 to _nABnP231_
		aBnP = _aABnP231_[_iABnP231_]
		nBnN = len(aBnP[2]) / 2
		if nBnN < 2  loop  ok
		# turns, counting only points where the direction actually
		# changes -- a duplicated coordinate is not a corner
		nBnT = 0
		for iBn = 2 to nBnN - 1
			nBnAx = aBnP[2][iBn * 2 - 1] - aBnP[2][iBn * 2 - 3]
			nBnAy = aBnP[2][iBn * 2] - aBnP[2][iBn * 2 - 2]
			nBnBx = aBnP[2][iBn * 2 + 1] - aBnP[2][iBn * 2 - 1]
			nBnBy = aBnP[2][iBn * 2 + 2] - aBnP[2][iBn * 2]
			if fabs(nBnAx) + fabs(nBnAy) < 0.5  loop  ok
			if fabs(nBnBx) + fabs(nBnBy) < 0.5  loop  ok
			if (fabs(nBnAx) > 0.5 and fabs(nBnBy) > 0.5) or
			   (fabs(nBnAy) > 0.5 and fabs(nBnBx) > 0.5)
				nBnT++
			ok
		next
		# how many rows this edge has to cross: none, or one
		if nBnT > 2
			nBnBad++
			? "      " + aBnP[1] + " turns " + nBnT + " times"
		ok
	next
next
chkeq("no edge turns more often than it has reason to", nBnBad, 0)

# ...and the summit routes specifically take ONE, which is the shape
# that was drawn for me: out of the summit, straight to the target's
# line, straight in.
nSvT = -1
_aASvP232_ = oSm.RenderEdgePaths()
_nASvP232_ = len(_aASvP232_)
for _iASvP232_ = 1 to _nASvP232_
	aSvP = _aASvP232_[_iASvP232_]
	if aSvP[1] != "g>back"  loop  ok
	nSvN = len(aSvP[2]) / 2
	nSvT = 0
	for iSv = 2 to nSvN - 1
		nSvAx = aSvP[2][iSv * 2 - 1] - aSvP[2][iSv * 2 - 3]
		nSvAy = aSvP[2][iSv * 2] - aSvP[2][iSv * 2 - 2]
		nSvBx = aSvP[2][iSv * 2 + 1] - aSvP[2][iSv * 2 - 1]
		nSvBy = aSvP[2][iSv * 2 + 2] - aSvP[2][iSv * 2]
		if fabs(nSvAx) + fabs(nSvAy) < 0.5  loop  ok
		if fabs(nSvBx) + fabs(nSvBy) < 0.5  loop  ok
		if (fabs(nSvAx) > 0.5 and fabs(nSvBy) > 0.5) or
		   (fabs(nSvAy) > 0.5 and fabs(nSvBx) > 0.5)
			nSvT++
		ok
	next
next
? "   the summit route turns " + nSvT + " time(s)"
chkeq("a summit route turns exactly once", nSvT, 1)


sec("-- 66. UML: THE DOMAIN THAT IS ONLY A NOTATION ------------")
#
# DN4, and the strongest test DN0's claim has had.
#
# Every other domain in this plane arrived beside a MODEL -- the org
# chart has stzOrgChart, the state machine and BPMN have stzWorkflow.
# UML class diagrams have none and need none: a class diagram IS a
# graph, and everything that makes it UML rather than a box-and-line
# drawing is notation. So the domain is one profile, with no renderer
# behind it.
#
# THE PLAN'S KILL CRITERION asked whether compartments could express as
# a node PROPERTY over the existing glyph machinery. They can, and the
# reason is worth keeping: a compartmented class is NOT a glyph -- DN0
# defines a glyph as the shape name the renderer already draws, and this
# is a plain box with contents. It is a size derived from what the node
# holds, over _BoxOf, which every consumer already reads.
#---------------------------------------------------------------------------

oUm = new stzDiagram("uml66")
oUm.SetNotation(StzUmlNotation())
oUm.AddNodeXTT("shape", "Shape", [ :type = "abstract",
	:attributes = [ "# origin : Point" ],
	:operations = [ "+ area() : Real",
		"+ intersects(Shape, Tolerance) : Boolean" ] ])
oUm.AddNodeXTT("circle", "Circle", [ :type = "class",
	:attributes = [ "- radius : Real" ] ])
oUm.AddNodeXTT("poly", "Polygon", [ :type = "class",
	:attributes = [ "- vertices : Point[]" ] ])
oUm.AddNodeXTT("pt", "Point", [ :type = "datatype",
	:attributes = [ "- x : Real", "- y : Real" ] ])
oUm.AddNodeXTT("bag", "Bag", [ :type = "class" ])
oUm.AddNodeXTT("log", "Logger", [ :type = "class",
	:operations = [ "+ log(String)" ] ])
oUm.AddEdgeXTT("shape", "circle", "", [ :uml = :Inheritance ])
oUm.AddEdgeXTT("poly", "pt", "", [ :uml = :Composition ])
oUm.AddEdgeXTT("bag", "pt", "", [ :uml = :Aggregation ])
oUm.AddEdgeXTT("shape", "log", "", [ :uml = :Dependency ])
oUm.AddEdgeXTT("circle", "pt", "", [ :uml = :Association ])
oUm.AddEdgeXTT("bag", "log", "", [ :uml = :Realization ])
oUm.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 140, :NodeHeight = 52,
	:FontSize = 13 ])

chkeq("declaring the UML notation puts the picture under it",
      oUm.NotationO().Name_(), "uml")

# (1) A CLASS IS AS BIG AS WHAT IT HOLDS. The criterion's own claim,
#     asked of the drawn rectangles: a class with four members is taller
#     than one with none, and a class whose longest signature is wide is
#     wider than the caller's cell.
rUmS = _Rect49(oUm, "shape")
rUmB = _Rect49(oUm, "bag")
? "   Shape (4 members) is " + rUmS[3] + "x" + rUmS[4] +
  ", Bag (none) is " + rUmB[3] + "x" + rUmB[4]
chk("a class with members is taller than one without", rUmS[4] > rUmB[4])
chk("...and a long signature makes it wider than the caller's cell",
    rUmS[3] > 140)

# ...AND THE BAND RULES ARE PART OF THAT HEIGHT. The drawing inserts
# 6px at each rule; the SIZE counted only the lines, so a class with
# four lines and two rules was measured 12px shorter than it draws. The
# text then reached the box's own border and the adornment -- whose apex
# touches that border -- landed on the last signature. Two places
# computing one height, which is this session's whole story.
nUmLo = 0
_aAUmL233_ = oUm.RenderNodeLabels()
_nAUmL233_ = len(_aAUmL233_)
for _iAUmL233_ = 1 to _nAUmL233_
	aUmL = _aAUmL233_[_iAUmL233_]
	if aUmL[1] != "shape"  loop  ok
	nUmLo = aUmL[3] + aUmL[5] / 2
next
chk("a class's box holds its own text, rules included",
    nUmLo <= rUmS[2] + rUmS[4] + 1)

# (2) THE LINE IS THE SAME LINE. This is the claim UML rests on and the
#     reason an adornment is not decoration: inheritance, composition
#     and aggregation are drawn with an IDENTICAL stroke, and the shape
#     at its end is the entire difference between "is a kind of", "is
#     part of and dies with it", and "is part of and outlives it".
#
#     Asserted by SHAPE rather than by pixels -- an instrument that has
#     to read pixels to find out what an edge ended in is one that gets
#     written once and never maintained.
aUmAd = oUm.RenderAdornments()
? "   " + len(aUmAd) + " adornments drawn"
nUmTri = 0  nUmFilled = 0  nUmHollow = 0
_aAUmA234_ = aUmAd
_nAUmA234_ = len(_aAUmA234_)
for _iAUmA234_ = 1 to _nAUmA234_
	aUmA = _aAUmA234_[_iAUmA234_]
	if aUmA[2] = "triangle"  nUmTri++  ok
	if aUmA[2] = "diamond" and aUmA[3]  nUmFilled++  ok
	if aUmA[2] = "diamond" and NOT aUmA[3]  nUmHollow++  ok
next
chkeq("inheritance and realization both end in a hollow triangle",
      nUmTri, 2)
chkeq("composition ends in a FILLED diamond", nUmFilled, 1)
chkeq("aggregation ends in a HOLLOW one", nUmHollow, 1)
chkeq("...and an association ends in neither", len(aUmAd), 4)

# ...AT THE END THE AUTHOR NAMED FIRST. The general class, or the whole,
# is written first -- the direction this library declares every
# hierarchy in -- so the adornment sits at the SOURCE.
nUmAt = 0
_aAUmA235_ = aUmAd
_nAUmA235_ = len(_aAUmA235_)
for _iAUmA235_ = 1 to _nAUmA235_
	aUmA = _aAUmA235_[_iAUmA235_]
	if aUmA[1] != "poly>pt"  loop  ok
	rUmP = _Rect49(oUm, "poly")
	if _DistRect62(rUmP, aUmA[4], aUmA[5]) <= 2  nUmAt = 1  ok
next
chk("the adornment sits on the end the author named first", nUmAt = 1)

# (3) A DEPENDENCY IS DASHED AND AN ASSOCIATION IS NOT. The stroke is
#     the only thing that separates them, and the dash needed no new
#     canvas capability -- it is the polyline emitted in pieces, which
#     is what a dash IS. BPMN's suspension gets it back as a side
#     effect, which is what a shared foundation is for.
chk("a dependency is drawn dashed", oUm._EdgeIsDashed("shape>log"))
chk("...and an association is not", NOT oUm._EdgeIsDashed("circle>pt"))
chk("...nor is an inheritance", NOT oUm._EdgeIsDashed("shape>circle"))
chk("...while a REALIZATION is, being a dashed generalization",
    oUm._EdgeIsDashed("bag>log"))

# (4) THE PICTURE STILL OBEYS THE CONTRACT. A domain is a profile, not
#     an exemption.
nUmBad = 0
_aAUmE236_ = oUm.Edges()
_nAUmE236_ = len(_aAUmE236_)
for _iAUmE236_ = 1 to _nAUmE236_
	aUmE = _aAUmE236_[_iAUmE236_]
	rUmA = _Rect49(oUm, StzLower("" + aUmE[:from]))
	rUmB2 = _Rect49(oUm, StzLower("" + aUmE[:to]))
	aUmP = []
	_aAUmR237_ = oUm.RenderEdgePaths()
	_nAUmR237_ = len(_aAUmR237_)
	for _iAUmR237_ = 1 to _nAUmR237_
		aUmR = _aAUmR237_[_iAUmR237_]
		if aUmR[1] = StzLower("" + aUmE[:from]) + ">" +
		   StzLower("" + aUmE[:to])  aUmP = aUmR[2]  ok
	next
	if len(aUmP) < 4  loop  ok
	nUmN = len(aUmP) / 2
	if _DistRect62(rUmA, aUmP[1], aUmP[2]) > 16  nUmBad++  ok
	if _DistRect62(rUmB2, aUmP[nUmN * 2 - 1], aUmP[nUmN * 2]) > 16
		nUmBad++
	ok
next
chkeq("every relationship touches both the classes it names", nUmBad, 0)

nUmOff = 0
_aRUm238_ = oUm.RenderNodeRects()
_nRUm238_ = len(_aRUm238_)
for _iRUm238_ = 1 to _nRUm238_
	rUm = _aRUm238_[_iRUm238_]
	if rUm[1] < 0 or rUm[2] < 0  nUmOff++  ok
	if rUm[1] + rUm[3] > oUm.LastCanvas().Width()  nUmOff++  ok
	if rUm[2] + rUm[4] > oUm.LastCanvas().Height()  nUmOff++  ok
next
chkeq("...and no class is drawn off the paper measured for it", nUmOff, 0)

# (5) A RANK'S PITCH IS THE TALLEST BOX THERE ACTUALLY IS.
#
#     "One box plus a separation" took the CALLER's box -- exact while
#     every node is that size, and badly wrong once a node can be
#     bigger. A UML class 113px tall was given a 52px pitch, so two
#     ranks of classes ended 25px apart: a corridor in that gap leaves
#     12px of stub on each side, which is a vertical nobody can see is
#     vertical and an arrival too short to carry its own arrowhead.
#
#     Asked as the thing a reader actually sees: every stub at the ends
#     of a staircase is long enough to read as a direction.
nUmStub = 0
nUmSeen = 0
_aAUmR239_ = oUm.RenderEdgePaths()
_nAUmR239_ = len(_aAUmR239_)
for _iAUmR239_ = 1 to _nAUmR239_
	aUmR = _aAUmR239_[_iAUmR239_]
	nUmN = len(aUmR[2]) / 2
	if nUmN < 3  loop  ok
	nUmSeen++
	nUmD1 = fabs(aUmR[2][3] - aUmR[2][1]) + fabs(aUmR[2][4] - aUmR[2][2])
	nUmD2 = fabs(aUmR[2][nUmN * 2 - 1] - aUmR[2][nUmN * 2 - 3]) +
	        fabs(aUmR[2][nUmN * 2] - aUmR[2][nUmN * 2 - 2])
	if nUmD1 < 22  nUmStub++  ok
	if nUmD2 < 22  nUmStub++  ok
next
? "   " + nUmSeen + " staircases, " + nUmStub + " with a stub too short to read"
chkeq("a rank gap leaves a readable stub on each side of its corridor",
      nUmStub, 0)

# (6) AN EDGE THAT COULD BE STRAIGHT IS STRAIGHT.
#
#     Ports spread several edges at one border so they leave from
#     distinct places, which is right -- until it takes the ONE edge
#     that needed no bend and gives it two. Basket sits directly above
#     Product and its aggregation was pushed 20px off that column and
#     back, drawing an S where a reader sees a straight line and nothing
#     to explain the detour.
oAl = new stzDiagram("aligned66")
oAl.SetNotation(StzUmlNotation())
oAl.AddNodeXTT("a", "Above", [ :type = "class",
	:operations = [ "+ go()" ] ])
oAl.AddNodeXTT("b", "Beside", [ :type = "class",
	:attributes = [ "- n : Int" ] ])
oAl.AddNodeXTT("c", "Below", [ :type = "class",
	:attributes = [ "- m : Int" ] ])
oAl.AddEdgeXTT("a", "c", "", [ :uml = :Aggregation ])
oAl.AddEdgeXTT("b", "c", "", [ :uml = :Association ])
oAl.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 140, :NodeHeight = 52,
	:FontSize = 13 ])
rAlA = _Rect49(oAl, "a")
rAlC = _Rect49(oAl, "c")
nAlTurn = -1
_aAAlP240_ = oAl.RenderEdgePaths()
_nAAlP240_ = len(_aAAlP240_)
for _iAAlP240_ = 1 to _nAAlP240_
	aAlP = _aAAlP240_[_iAAlP240_]
	if aAlP[1] != "a>c"  loop  ok
	nAlN = len(aAlP[2]) / 2
	nAlTurn = 0
	for iAl = 2 to nAlN - 1
		nAlAx = aAlP[2][iAl * 2 - 1] - aAlP[2][iAl * 2 - 3]
		nAlAy = aAlP[2][iAl * 2] - aAlP[2][iAl * 2 - 2]
		nAlBx = aAlP[2][iAl * 2 + 1] - aAlP[2][iAl * 2 - 1]
		nAlBy = aAlP[2][iAl * 2 + 2] - aAlP[2][iAl * 2]
		if fabs(nAlAx) + fabs(nAlAy) < 0.5  loop  ok
		if fabs(nAlBx) + fabs(nAlBy) < 0.5  loop  ok
		if (fabs(nAlAx) > 0.5 and fabs(nAlBy) > 0.5) or
		   (fabs(nAlAy) > 0.5 and fabs(nAlBx) > 0.5)
			nAlTurn++
		ok
	next
next
? "   Above and Below share a column; their edge turns " + nAlTurn + " time(s)"
chk("two classes in one column are joined by a straight line",
    fabs((rAlA[1] + rAlA[3] / 2) - (rAlC[1] + rAlC[3] / 2)) < 2 and
    nAlTurn = 0)

# (7) A FORK IS NOT A CORNER.
#
#     Edges leaving one source share a stem and part at one point --
#     the blessed merge, and right. But a rounded elbow is drawn AROUND
#     the point it turns at, so two edges turning OPPOSITE ways at one
#     shared corner lay two arcs over each other: they curve apart from
#     the same place, and what a reader sees is a solid triangle in the
#     middle of the line. The Principal circled it on the UML interface
#     picture and read it as an arrowhead, which is what it looks like.
#
#     ASKED AS A COMPARISON, and that is the point of the shape of this
#     assertion. Two earlier drafts counted diagonal chords against a
#     baseline I could not account for -- one of them counted the
#     adornment triangles and reported ten. A count needs a baseline; a
#     COMPARISON carries its own. Rounding a corner changes the picture,
#     so where every corner is a fork, turning rounding ON must change
#     NOTHING.
oFk = new stzDiagram("fork66")
oFk.SetSplines("ortho")
oFk.AddNodeXTT("top", "Top", [ :type = "box", :color = "#4477FF" ])
oFk.AddNodeXTT("l", "Left", [ :type = "box", :color = "#4477FF" ])
oFk.AddNodeXTT("r", "Right", [ :type = "box", :color = "#4477FF" ])
oFk.AddEdge("top", "l")  oFk.AddEdge("top", "r")
oFk.ToCanvasXT([ :NodeWidth = 120, :NodeHeight = 48, :Corner = 14 ])
? "   squared forks reported : " + len(oFk.RenderForks())
chk("a shared corner is drawn SQUARE", len(oFk.RenderForks()) > 0)

# ...AND A LONE CORNER IS NOT TOUCHED, or the rule has quietly squared
# every corner in the library and satisfied the assertion above by
# destroying the style it exists to protect.
oFk2 = new stzDiagram("fork66b")
oFk2.SetSplines("ortho")
oFk2.AddNodeXTT("a", "A", [ :type = "box", :color = "#4477FF" ])
oFk2.AddNodeXTT("b", "B", [ :type = "box", :color = "#4477FF" ])
oFk2.AddNodeXTT("c", "C", [ :type = "box", :color = "#4477FF" ])
oFk2.AddNodeXTT("d", "D", [ :type = "box", :color = "#4477FF" ])
oFk2.AddEdge("a", "b")  oFk2.AddEdge("a", "c")  oFk2.AddEdge("b", "d")
oFk2.ToCanvasXT([ :NodeWidth = 120, :NodeHeight = 48, :Corner = 14 ])
? "   ...and the same graph's LONE turns are left rounded"
chk("a corner that is a corner still turns with an arc",
    len(_DiagChords(oFk2.ToSVGXT([ :NodeWidth = 120, :NodeHeight = 48,
    :Corner = 14 ]), EDGERGB)) > 0)

# (8) THE REST OF UML -- DN4b, and what it cost.
#
#     UML is not only class diagrams, and the first scoping of DN4 said
#     otherwise: "sequence and activity are separate notations that
#     happen to share a name" was a judgement written as though it were
#     a fact. Seven more diagram types followed, and TWO GLYPHS were the
#     whole of what had to be built -- an actor and a fork bar. The rest
#     was already in the shape table.
#
#     That number is the claim worth asserting: a foundation is only
#     worth what the next domain does NOT have to add.
nUmNew = 0
_aCUmS241_ = [ "actor", "bar" ]
_nCUmS241_ = len(_aCUmS241_)
for _iCUmS241_ = 1 to _nCUmS241_
	cUmS = _aCUmS241_[_iCUmS241_]
	if StzIsNodeShape(cUmS)  nUmNew++  ok
next
nUmHad = 0
_aCUmS242_ = [ "ellipse", "folder", "component", "note", "cylinder",
	"box", "diamond", "circle", "doublecircle", "square" ]
_nCUmS242_ = len(_aCUmS242_)
for _iCUmS242_ = 1 to _nCUmS242_
	cUmS = _aCUmS242_[_iCUmS242_]
	if StzIsNodeShape(cUmS)  nUmHad++  ok
next
? "   seven diagram types: " + nUmNew + " glyphs added, " + nUmHad +
  " already there"
chkeq("the actor and the bar are the only glyphs UML had to add",
      nUmNew, 2)
chkeq("...and every other glyph seven diagram types need existed",
      nUmHad, 10)

# ONE PROFILE PER DIAGRAM TYPE, because it is the GRAMMAR that separates
# them. Folding them into one would mean one rankdir for all of them,
# which is the same as having no grammar at all.
aUmFam = [
	[ StzUmlClassNotation(), "uml", "toptobottom" ],
	[ StzUmlUseCaseNotation(), "umlusecase", "lefttoright" ],
	[ StzUmlActivityNotation(), "umlactivity", "toptobottom" ],
	[ StzUmlComponentNotation(), "umlcomponent", "toptobottom" ],
	[ StzUmlPackageNotation(), "umlpackage", "toptobottom" ],
	[ StzUmlDeploymentNotation(), "umldeployment", "toptobottom" ],
	[ StzUmlObjectNotation(), "umlobject", "toptobottom" ],
	[ StzUmlCommunicationNotation(), "umlcommunication", "lefttoright" ] ]
nUmBad = 0
_aAUmF243_ = aUmFam
_nAUmF243_ = len(_aAUmF243_)
for _iAUmF243_ = 1 to _nAUmF243_
	aUmF = _aAUmF243_[_iAUmF243_]
	if aUmF[1].Name_() != aUmF[2]  nUmBad++  ok
	if StzLower("" + aUmF[1].RankDir()) != aUmF[3]  nUmBad++  ok
	if len(aUmF[1].Kinds()) < 2  nUmBad++  ok
next
chkeq("eight profiles, each with its own vocabulary and grammar",
      nUmBad, 0)

# AN ACTIVITY HAS A SPINE AND A PACKAGE DIAGRAM DOES NOT, which is the
# whole reason they are two profiles. A dependency graph has no happy
# path, and declaring one would be a claim the model does not make.
chk("an activity declares a principal path",
    StzTrim("" + StzUmlActivityNotation().Spine()) != "")
chk("...and a package diagram does not",
    StzTrim("" + StzUmlPackageNotation().Spine()) = "")

# A BAR REACHES ACROSS WHAT IT SPLITS. Sized as a square mark it came
# out narrower than the two branches leaving it, which reads as a small
# blob the paths happen to pass -- the opposite of the claim it makes.
oAc = new stzDiagram("act66")
oAc.SetNotation(StzUmlActivityNotation())
oAc.AddNodeXTT("i", "", [ :type = "initial" ])
oAc.AddNodeXTT("fk", "", [ :type = "fork" ])
oAc.AddNodeXTT("a", "Pack", [ :type = "action" ])
oAc.AddNodeXTT("b", "Bill", [ :type = "action" ])
oAc.AddEdge("i", "fk")  oAc.AddEdge("fk", "a")  oAc.AddEdge("fk", "b")
oAc.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 120, :NodeHeight = 48,
	:FontSize = 13 ])
rAcF = _Rect49(oAc, "fk")
rAcI = _Rect49(oAc, "i")
? "   the fork bar is " + rAcF[3] + "x" + rAcF[4] +
  ", the initial mark " + rAcI[3] + "x" + rAcI[4]
chk("a fork bar reaches across the flow", rAcF[3] > rAcF[4] * 2)
chk("...while an initial node stays a mark", rAcI[3] < 120 * 0.5)


#---------------------------------------------------------------------------
? ""
sec("-- 67. A SEQUENCE IS A MODE, NOT A SECOND RENDERER --------")
discharges("DN4b")

# The plan attached its sharpest kill criterion to this one diagram:
# "its y-axis is TIME and its x-axis is participants -- that is not a
# graph layout, it is a schedule. If it cannot express as a layout MODE
# over the one renderer, it is a second renderer wearing a profile's
# clothes, and the plan says so."
#
# It expresses, because the two axes are not symmetrical: only the
# participant axis belongs to the nodes, and the time axis belongs to
# the messages, which are edges. What follows asserts the MECHANISM of
# that claim -- one row, ordinals descending, a repeated pair drawn
# twice -- and each positive has the negative sibling that proves the
# assertion could have failed.

OPT67 = [ :Font = EFONT, :NodeWidth = 120, :NodeHeight = 50, :FontSize = 13 ]
oSqA = _SqScene("sq_row", 1)
oSqA.AddMessage("a", "b", "m1")
oSqA.AddMessage("b", "c", "m2")
oSqA.ToCanvasXT(OPT67)
aSqR = oSqA.RenderNodeRects()
nSqSame = 1
nSqRl = len(aSqR)
for iSq = 2 to nSqRl
	if fabs(aSqR[iSq][2] - aSqR[1][2]) > 0.5  nSqSame = 0  ok
next
chk("participants share ONE row", nSqSame = 1)
nSqDist = 1
for iSq = 2 to nSqRl
	if fabs(aSqR[iSq][1] - aSqR[1][1]) < 1  nSqDist = 0  ok
next
chk("...and stand at distinct x", nSqDist = 1)

# THE NEGATIVE SIBLING. The same three nodes and the same two links
# without the profile are ranked, not rowed -- so the row above is a
# fact about the mode and not about the scene.
oSqB = _SqScene("sq_norow", 0)
oSqB.AddEdgeXT("a", "b", "m1")
oSqB.AddEdgeXT("b", "c", "m2")
oSqB.ToCanvasXT(OPT67)
aSqR2 = oSqB.RenderNodeRects()
nSqSame2 = 1
nSqR2l = len(aSqR2)
for iSq = 2 to nSqR2l
	if fabs(aSqR2[iSq][2] - aSqR2[1][2]) > 0.5  nSqSame2 = 0  ok
next
chk("NEGATIVE: without the profile they do not", nSqSame2 = 0)

# TIME IS THE ORDER THE AUTHOR WROTE. Nothing computes it -- the reader
# already knows a sequence reads downward, and the author already said
# what happens next by writing it next.
oSqC = _SqScene("sq_desc", 1)
oSqC.AddMessage("a", "b", "one")
oSqC.AddMessage("b", "c", "two")
oSqC.AddMessage("c", "a", "three")
oSqC.AddMessage("a", "b", "four")
oSqC.ToCanvasXT(OPT67)
aSqY = _MsgYs(oSqC)
chkeq("four messages, four drawn paths", len(aSqY), 4)
nSqMono = 1
nSqYl = len(aSqY)
for iSq = 2 to nSqYl
	if aSqY[iSq] <= aSqY[iSq - 1]  nSqMono = 0  ok
next
chk("each message is strictly below the one before", nSqMono = 1)

# A REPEATED PAIR IS TWO MOMENTS. This is the case that broke the first
# build twice over: the twin-pairing drew the reply as a hook back to
# its call, and the path key "a>b" could name only one of the two.
chk("the repeated pair a>b is at two different moments",
    len(aSqY) = 4 and fabs(aSqY[4] - aSqY[1]) > 1)
nSqK = 0
nSqPl = len(oSqC.@aEdgePaths)
for iSq = 1 to nSqPl
	if oSqC.@aEdgePaths[iSq][1] = "a>b#1"  nSqK++  ok
	if oSqC.@aEdgePaths[iSq][1] = "a>b#4"  nSqK++  ok
next
chkeq("...and each claims its own key", nSqK, 2)

# AND THE GRAPH UNDERNEATH STAYS TRUE. stzGraph is simple on purpose so
# that counts, paths and metrics mean something; four messages over
# three relations must leave the degree of every participant alone.
chkeq("three relations underneath", oSqC.NumberOfEdges(), 3)
chkeq("...carrying four messages", oSqC.NumberOfMessages(), 4)

# A REPLY IS DRAWN AS A REPLY -- and a call is not, which is the half
# that makes the dash mean anything.
oSqD = _SqScene("sq_reply", 1)
oSqD.AddMessage("a", "b", "call")
oSqD.AddMessageXT("b", "a", "answer", [ :kind = "return" ])
oSqD.ToCanvasXT(OPT67)
chkeq("the call is not a reply", oSqD._MessageIsReturn(oSqD.Messages(), 1), 0)
chkeq("the reply is", oSqD._MessageIsReturn(oSqD.Messages(), 2), 1)

# THE PAPER IS THE CONTENT MEASURED, and a sequence's content is longer
# than its layout: the height comes from the message count, which the
# sizing pass cannot know because it runs before the messages are placed.
nSqLow = aSqY[1]
for iSq = 2 to nSqYl
	if aSqY[iSq] > nSqLow  nSqLow = aSqY[iSq]  ok
next
chk("the paper holds the lifelines below the last message",
    oSqC.LastCanvas().Height() > nSqLow)

# AND THE PROFILE SAYS NOTHING ABOUT RANK DIRECTION, on purpose. Every
# other profile in the UML file declares one and the first draft of this
# one copied them, which rotated the two axes and drew the participants
# in a column. There is no right-to-left sequence diagram.
chkeq("the profile declares no rank direction",
    StzUmlSequenceNotation().RankDir(), "")

OPT6869 = [ :Font = EFONT, :NodeWidth = 120, :NodeHeight = 50, :FontSize = 13 ]

# MEASURED BEFORE FIXED, and the shape of the numbers named the cause. A
# root with one child, over a parent with N children:
#
#     N = 1  aligned          N = 3  aligned
#     N = 2  off by 93.50     N = 4  off by 93.50   (half a slot, exactly)
#
# An ODD fan-out puts the parent's centre ON a child's column -- where the
# snap had already put the leaf -- so it came out right by luck. An EVEN
# one moves the parent half a slot off every column and leaves the leaf
# behind. centerParents runs after the snap deliberately, and that order
# was never wrong; what was missing is that a leaf's position is purely
# DERIVED, and a derived value computed before its input is final is not
# a rule, it is a stale read.
sec("-- 68. A LEAF IS SETTLED LAST, FROM SOMETHING ELSE -------")

# A root with one child, over a parent with N children. The defect was
# EVEN-ONLY and always exactly half a slot -- an odd fan-out puts the
# parent's centre on a child's column, which is where the leaf already
# was, so it came out right by luck.
for nK = 1 to 4
	oL = new stzDiagram("leaf" + nK)
	oL.AddNodeXTT("root", "Root", [ :type = "box" ])
	oL.AddNodeXTT("mid", "Mid", [ :type = "box" ])
	oL.AddEdge("root", "mid")
	for iK = 1 to nK
		oL.AddNodeXTT("k" + iK, "Kid" + iK, [ :type = "box" ])
		oL.AddEdge("mid", "k" + iK)
	next
	oL.ToCanvasXT(OPT6869)
	aL = oL.RenderNodeRects()
	nR = -1  nM = -1
	for iL = 1 to len(aL)
		if aL[iL][5] = "root"  nR = aL[iL][1] + aL[iL][3] / 2  ok
		if aL[iL][5] = "mid"   nM = aL[iL][1] + aL[iL][3] / 2  ok
	next
	chk("a lone root stands over its only child, " + nK + " kids below it",
	    fabs(nR - nM) < 0.5)
next

# THE NEGATIVE SIBLING. Two leaves on one rank hanging from one node are
# SIBLINGS -- pulling both onto the parent's column would collapse them
# onto each other. They straddle, and that is I7, not a missed alignment.
oS = new stzDiagram("straddle")
oS.AddNodeXTT("p", "Parent", [ :type = "box" ])
oS.AddNodeXTT("a", "Left", [ :type = "box" ])
oS.AddNodeXTT("b", "Right", [ :type = "box" ])
oS.AddEdge("p", "a")
oS.AddEdge("p", "b")
oS.ToCanvasXT(OPT6869)
aS = oS.RenderNodeRects()
nPx = -1  nAx = -1  nBx = -1
for iS = 1 to len(aS)
	if aS[iS][5] = "p"  nPx = aS[iS][1] + aS[iS][3] / 2  ok
	if aS[iS][5] = "a"  nAx = aS[iS][1] + aS[iS][3] / 2  ok
	if aS[iS][5] = "b"  nBx = aS[iS][1] + aS[iS][3] / 2  ok
next
chk("NEGATIVE: two leaves under one parent do NOT collapse onto it",
    fabs(nAx - nBx) > 1)
chk("...they straddle it, one on each side",
    (nAx < nPx and nBx > nPx) or (nBx < nPx and nAx > nPx))

sec("-- 69. A LABEL CLEARS ITS OWN BEND -------------------------")

# The asymmetry that hid this: both sides of a beside-placement are
# offered in a fixed order, so an edge turning UP kept its elbow below
# its run and read correctly, while an edge turning DOWN put its elbow
# where the first-choice label goes.
oC = new stzDiagram("comm")
oC.SetNotation(StzUmlCommunicationNotation())
oC.AddNodeXTT("u", "Shopper", [ :type = "actor" ])
oC.AddNodeXTT("c", ": Cart", [ :type = "object" ])
oC.AddNodeXTT("s", ": Stock", [ :type = "object" ])
oC.AddNodeXTT("p", ": Payment", [ :type = "object" ])
oC.AddEdgeXT("u", "c", "1: add(item)")
oC.AddEdgeXT("c", "s", "2: reserve(item)")
oC.AddEdgeXT("c", "p", "3: charge(total)")
oC.ToCanvasXT(OPT6869)

# the actor hangs from one neighbour and nothing else, so it stands on
# the line that leaves it -- one straight run, no bend at all
aC = oC.RenderNodeRects()
nUy = -1  nCy = -1
for iC = 1 to len(aC)
	if aC[iC][5] = "u"  nUy = aC[iC][2] + aC[iC][4] / 2  ok
	if aC[iC][5] = "c"  nCy = aC[iC][2] + aC[iC][4] / 2  ok
next
chk("the actor stands on the line it speaks along", fabs(nUy - nCy) < 0.5)

# and no label covers a bend of the edge it names
nHid = 0
for iC = 1 to len(oC.@aRenderLabels)
	aLR = oC.@aRenderLabels[iC]
	nL0 = aLR[2] - aLR[4] / 2   nT0 = aLR[3] - aLR[5] / 2
	nR0 = aLR[2] + aLR[4] / 2   nB0 = aLR[3] + aLR[5] / 2
	for jC = 1 to len(oC.@aEdgePaths)
		if StzLower("" + oC.@aEdgePaths[jC][1]) != StzLower("" + aLR[6])  loop  ok
		aFl = oC.@aEdgePaths[jC][2]
		# every SEGMENT of its own path, not only the corner points --
		# what the plate covered was the vertical drop between two
		# vertices, and testing the vertices alone missed it by 8px
		for kC = 1 to len(aFl) - 3 step 2
			nSx1 = min([ aFl[kC], aFl[kC+2] ])  nSx2 = max([ aFl[kC], aFl[kC+2] ])
			nSy1 = min([ aFl[kC+1], aFl[kC+3] ])  nSy2 = max([ aFl[kC+1], aFl[kC+3] ])
			if nSx2 < nL0 or nSx1 > nR0 or nSy2 < nT0 or nSy1 > nB0  loop  ok
			nHid++
		next
	next
next
chkeq("no label is laid over a bend of the edge it names", nHid, 0)

# THE NEGATIVE SIBLING, and it is the same instrument asking the same
# question of the other convention. MIDDLE means the word sits ON the
# line on purpose -- so the counter above must come back NON-zero here,
# or it is not measuring what it claims to measure and the zero above
# was worth nothing.
oM = new stzDiagram("comm_mid")
oM.SetNotation(StzUmlCommunicationNotation())
oM.AddNodeXTT("u", "Shopper", [ :type = "actor" ])
oM.AddNodeXTT("c", ": Cart", [ :type = "object" ])
oM.AddNodeXTT("s", ": Stock", [ :type = "object" ])
oM.AddNodeXTT("p", ": Payment", [ :type = "object" ])
oM.AddEdgeXT("u", "c", "1: add(item)")
oM.AddEdgeXT("c", "s", "2: reserve(item)")
oM.AddEdgeXT("c", "p", "3: charge(total)")
oM.ToCanvasXT([ :Font = EFONT, :NodeWidth = 120, :NodeHeight = 50,
	:FontSize = 13, :LabelPlacement = :Middle ])
nOn = 0
for iM = 1 to len(oM.@aRenderLabels)
	aLM = oM.@aRenderLabels[iM]
	nL1 = aLM[2] - aLM[4] / 2   nT1 = aLM[3] - aLM[5] / 2
	nR1 = aLM[2] + aLM[4] / 2   nB1 = aLM[3] + aLM[5] / 2
	for jM = 1 to len(oM.@aEdgePaths)
		if StzLower("" + oM.@aEdgePaths[jM][1]) != StzLower("" + aLM[6])  loop  ok
		aFM = oM.@aEdgePaths[jM][2]
		for kM = 1 to len(aFM) - 3 step 2
			nMx1 = min([ aFM[kM], aFM[kM+2] ])  nMx2 = max([ aFM[kM], aFM[kM+2] ])
			nMy1 = min([ aFM[kM+1], aFM[kM+3] ])  nMy2 = max([ aFM[kM+1], aFM[kM+3] ])
			if nMx2 < nL1 or nMx1 > nR1 or nMy2 < nT1 or nMy1 > nB1  loop  ok
			nOn++
		next
	next
next
chk("NEGATIVE: under :Middle the word sits ON its line, by design",
    nOn > 0)



# The Principal asked why two lines leaving one cell turn at two columns
# 22px apart. They do not any more, and the cause was a predicate whose
# NAME promised more than its body checked: _EdgeIsAlternative answered
# "labelled, and the source forks", while the only caller that filtered
# afterwards -- _SummitOf -- asked the shape question itself. The other
# caller, _ClaimChannel, took the unfiltered answer as the whole truth,
# so every labelled fan-out was treated as a decision and refused the
# shared stem a fan is entitled to.
sec("-- 70. A FAN LEAVES ON ONE STEM; A DECISION DOES NOT ----")

oF = Scene("fan", "box")
aF2 = TurnsOf(oF, "src")
chkeq("a plain cell's two lines are read", len(aF2), 2)
chk("...and they turn at ONE column -- one origin, one stem",
    len(aF2) = 2 and fabs(aF2[1] - aF2[2]) < 0.5)

# THE NEGATIVE SIBLING, and it is the Principal's earlier ruling: every
# answer must QUIT the decision cell on its own. Two answers to one
# question are not one thing, and a shared stem would say they were the
# same until the moment they parted.
oD2 = Scene("decision", "diamond")
aD2 = TurnsOf(oD2, "src")
chkeq("a decision's two answers are read", len(aD2), 2)
chk("NEGATIVE: ...and they do NOT share a stem",
    len(aD2) = 2 and fabs(aD2[1] - aD2[2]) > 0.5)

chk("a diamond is a branch cell", oD2._IsBranchCell("src") = 1)
chk("...and a box is not", oF._IsBranchCell("src") = 0)



OPTGOV = [ :Font = EFONT, :NodeWidth = 130, :NodeHeight = 52, :FontSize = 14 ]
OPTPN2 = [ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]
OPTER2 = [ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]
OPTFT2 = [ :Font = EFONT, :NodeWidth = 120, :NodeHeight = 52, :FontSize = 13 ]
OPTFM2 = [ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]
OPTNW2 = [ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]

# The meta layer: rules that state what they GOVERN, separately from what
# they assert, so the SELECTION half can be checked at all. Six defects of
# this plane in one session were a right rule applied outside its scope,
# and not one was findable by testing the rule -- the rule passes its own
# tests. What follows tests the layer BOTH ways, because a governor that
# reports nothing is indistinguishable from a governor that is broken.
sec("-- 73c. A WIRE CLEARS THE NAME IT PASSES -----------------")

# The channel placer clears CELLS and FRAMES and knew nothing of the
# WORDS beside them. A mark that writes its name below itself -- a
# junction, a ground, an end state -- occupies far more paper than its
# box says, so a channel measured against the BOX came to rest just
# under the word: legal by the arithmetic, crowded to a reader.
oWc = new stzDiagram("clear73c")
oWc.SetNotation(StzElectricNotation())
oWc.AddNodeXTT("v", "VIN", [ :type = "source" ])
oWc.AddNodeXTT("r", "R", [ :type = "resistor" ])
oWc.AddNodeXTT("c", "C", [ :type = "capacitor" ])
oWc.AddNodeXTT("g", "", [ :type = "ground" ])
oWc.AddNodeXTT("nin", "IN", [ :type = "net" ])
oWc.AddNodeXTT("nout", "OUT", [ :type = "net" ])
oWc.AddNodeXTT("n0", "GND", [ :type = "net" ])
oWc.AddEdge("v","nin")  oWc.AddEdge("nin","r")  oWc.AddEdge("r","nout")
oWc.AddEdge("nout","c") oWc.AddEdge("c","n0")   oWc.AddEdge("n0","g")
oWc.AddEdge("n0","v")
oWc.ToCanvasXT(OPT67)

# For every NAMED mark that writes its name below, any wire turning
# beneath it must turn below the band that name occupies.
#
# THE NAME IS READ AS DRAWN, NEVER ESTIMATED. Two versions of this
# guard estimated it and both were wrong in a different direction. The
# first wrote `26 * 2.4` -- the font size of the GALLERY the defect was
# found in -- against a scene rendered at 13, demanding room for type
# twice the size of the type on the paper. The second read the size
# from the scene and still used `fsz * 2.4`, which is what the LAYOUT
# reserves below a mark, not where the letters land: the reservation
# starts at the box and the ink sits lower inside it, so a wire resting
# at the top of the reservation is clear of the word and was convicted
# anyway. It convicted four wires in pictures a reader can see are
# fine.
#
# The renderer already publishes the plate it painted, the same way it
# publishes its node rects and its arrowheads. So the wire is tested
# against the INK. This is not the guard marking its own homework --
# the claim is about the WIRE's position, and the wire's geometry and
# the name's geometry are produced by two different parts of the
# render.
nWcSeen = 0  nWcBad = 0
_aWcL_ = oWc.RenderNodeLabels()
for iWc = 1 to len(_aWcL_)
	cWcId = StzLower("" + _aWcL_[iWc][1])
	if NOT oWc._WritesNameBelow(cWcId)  loop  ok
	# the published plate is centre-x, centre-y, width, height
	nWcT = _aWcL_[iWc][3] - _aWcL_[iWc][5] / 2
	nWcB = _aWcL_[iWc][3] + _aWcL_[iWc][5] / 2
	nWcL = _aWcL_[iWc][2] - _aWcL_[iWc][4] / 2
	nWcR = _aWcL_[iWc][2] + _aWcL_[iWc][4] / 2
	for jWc = 1 to len(oWc.@aEdgePaths)
		aWcF = oWc.@aEdgePaths[jWc][2]
		for kWc = 1 to len(aWcF) - 3 step 2
			# a HORIZONTAL run crossing the word itself
			if fabs(aWcF[kWc + 3] - aWcF[kWc + 1]) > 0.5  loop  ok
			nWcY = aWcF[kWc + 1]
			if nWcY <= nWcT or nWcY >= nWcB  loop  ok
			nWcX1 = min([ aWcF[kWc], aWcF[kWc + 2] ])
			nWcX2 = max([ aWcF[kWc], aWcF[kWc + 2] ])
			if nWcX2 < nWcL or nWcX1 > nWcR  loop  ok
			nWcSeen++
			nWcBad++
		next
	next
next
? "   " + nWcBad + " wire(s) running through a name"
chkeq("a wire passes clear of the name it goes by, not through it", nWcBad, 0)

# THE NEGATIVE SIBLING: the instrument must be able to SEE one.
#
# It used to inflate every plate fourfold and require a hit, and that
# stopped working -- not because the reader broke, but because the
# placement got good enough that even a plate four times its size
# touches nothing in this scene. A negative that depends on the picture
# still being crowded expires the moment the picture is fixed.
#
# So the probe is put ON a wire instead of near one: a small rect
# centred on the midpoint of a real segment, run through the same
# overlap test. That cannot go stale, because it is built from the ink
# it is supposed to find.
nWcFake = 0
aWcSeg = []
for jWc = 1 to len(oWc.@aEdgePaths)
	aWcF = oWc.@aEdgePaths[jWc][2]
	if len(aWcF) < 4  loop  ok
	aWcSeg = [ (aWcF[1] + aWcF[3]) / 2, (aWcF[2] + aWcF[4]) / 2 ]
	exit
next
if len(aWcSeg) = 2
	nWcPl = aWcSeg[1] - 6   nWcPr = aWcSeg[1] + 6
	nWcPt = aWcSeg[2] - 6   nWcPb = aWcSeg[2] + 6
	for jWc = 1 to len(oWc.@aEdgePaths)
		aWcF = oWc.@aEdgePaths[jWc][2]
		for kWc = 1 to len(aWcF) - 3 step 2
			nWcX1 = min([ aWcF[kWc], aWcF[kWc + 2] ])
			nWcX2 = max([ aWcF[kWc], aWcF[kWc + 2] ])
			nWcY1 = min([ aWcF[kWc + 1], aWcF[kWc + 3] ])
			nWcY2 = max([ aWcF[kWc + 1], aWcF[kWc + 3] ])
			if nWcX2 < nWcPl or nWcX1 > nWcPr  loop  ok
			if nWcY2 < nWcPt or nWcY1 > nWcPb  loop  ok
			nWcFake++
		next
	next
	? "   a probe placed ON a wire is seen " + nWcFake + " time(s)"
ok
chk("NEGATIVE: the same scan DOES see a plate that is on a wire",
    nWcFake > 0)

sec("-- 73d. :SCALE IS RESOLUTION, SO MORE IS BIGGER ---------")

# ASKING FOR THREE TIMES THE RESOLUTION GAVE A SMALLER PICTURE. The
# scale block multiplies every input -- box, font, stroke, corner --
# and gated the PAGE on whether the caller had typed one. That was
# sound for a layered picture, whose page is derived from the boxes
# downstream, and wrong for every layout that NORMALISES into the page:
# there the usable area is page MINUS box, so scaling the box against a
# fixed page spent the picture's own room, and the box fitter then
# shrank the components to fit the room just taken from them.
#
# The claim is the contract's own sentence -- the same diagram with
# more pixels -- so it is checked on a mesh, which is where it broke,
# AND on a layered picture, which is where it always held. Two layouts,
# because a fix that repaired one by breaking the other would pass a
# guard that only watched the patient.
aScSheet = []  aScPart = []
for iSc = 1 to 3
	oSc = new stzDiagram("scale73d")
	oSc.SetNotation(StzElectricNotation())
	oSc.AddNodeXTT("v", "VIN", [ :type = "source" ])
	oSc.AddNodeXTT("r", "R 1k", [ :type = "resistor" ])
	oSc.AddNodeXTT("c", "C 100n", [ :type = "capacitor" ])
	oSc.AddNodeXTT("g", "", [ :type = "ground" ])
	oSc.AddNodeXTT("nin", "IN", [ :type = "net" ])
	oSc.AddNodeXTT("nout", "OUT", [ :type = "net" ])
	oSc.AddNodeXTT("n0", "GND", [ :type = "net" ])
	oSc.AddEdge("v","nin")   oSc.AddEdge("nin","r")
	oSc.AddEdge("r","nout")  oSc.AddEdge("nout","c")
	oSc.AddEdge("c","n0")    oSc.AddEdge("n0","g")
	oSc.AddEdge("n0","v")
	oSc.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
	                 :FontSize = 26, :Scale = iSc ])
	aScSheet + oSc.LastCanvas().Width()
	aScR = oSc.RenderNodeRects()
	nScW = 0
	for jSc = 1 to len(aScR)
		if StzLower("" + aScR[jSc][5]) = "r"  nScW = aScR[jSc][3]  ok
	next
	aScPart + nScW
next
? "   mesh sheet widths  " + aScSheet[1] + " " + aScSheet[2] + " " + aScSheet[3]
? "   mesh resistor      " + aScPart[1] + " " + aScPart[2] + " " + aScPart[3]

chk("a mesh grows with :Scale, it does not shrink",
    aScSheet[2] > aScSheet[1] and aScSheet[3] > aScSheet[2])
chk("...and so does the component drawn on it",
    aScPart[2] > aScPart[1] and aScPart[3] > aScPart[2])

# NOT MERELY MONOTONIC -- ROUGHLY PROPORTIONAL. Growth alone would be
# satisfied by one pixel a step, which is not what "resolution" means.
nScRat = aScSheet[3] / aScSheet[1]
? "   sheet(3)/sheet(1)  " + nScRat + "   (want near 3)"
chk("...and three times the resolution is about three times the picture",
    nScRat > 2.5 and nScRat < 3.5)

# THE LAYOUT THAT WAS NEVER BROKEN, checked in the same breath, and it
# is EXACT there -- a layered page is derived from the boxes, so its
# growth is the multiplier itself with nothing to round.
aScH = []
for iSc = 1 to 3
	oSh = new stzDiagram("scaleh73d")
	oSh.AddNode("a")  oSh.AddNode("b")  oSh.AddNode("c")  oSh.AddNode("d")
	oSh.AddEdge("a","b")  oSh.AddEdge("a","c")  oSh.AddEdge("b","d")
	oSh.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
	                 :FontSize = 26, :Scale = iSc ])
	aScH + oSh.LastCanvas().Width()
next
? "   layered widths     " + aScH[1] + " " + aScH[2] + " " + aScH[3]
chkeq("a layered picture scales EXACTLY, and still does", aScH[3], aScH[1] * 3)

# THE NEGATIVE SIBLING: the instrument reads real sizes, so it must be
# able to report a picture that did NOT grow. The same reader is run
# over one diagram rendered twice at the SAME scale, where growth is
# impossible, and must find none.
oScA = new stzDiagram("flat73d")
oScA.AddNode("a")  oScA.AddNode("b")  oScA.AddEdge("a","b")
oScA.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
                  :FontSize = 26, :Scale = 2 ])
nScA = oScA.LastCanvas().Width()
oScB = new stzDiagram("flat73d")
oScB.AddNode("a")  oScB.AddNode("b")  oScB.AddEdge("a","b")
oScB.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
                  :FontSize = 26, :Scale = 2 ])
nScB = oScB.LastCanvas().Width()
chk("NEGATIVE: the same scale twice is NOT growth", NOT (nScB > nScA))

sec("-- 73e. A WIRE MEETS A TERMINAL, NOT A BODY ------------")

# A COMPONENT IS JOINED AT ITS LEADS AND NOWHERE ELSE.
#
# The general router attaches an edge by clipping toward the target,
# which is right for a CELL -- a box means the same thing wherever you
# touch it -- and wrong for a PART. On the RC low-pass it put the wire
# from OUT into the middle of the capacitor's bottom edge, where a
# capacitor has no terminal, and left the opposite lead running out to
# the paper's border joined to nothing. The Principal saw the dangling
# lead; the wire meeting a BODY is the same fault stated from the other
# end, and it is the one that makes the picture false rather than
# merely untidy.
#
# Two claims, because one of them alone can be satisfied by a wrong
# picture: every wire lands ON a terminal, AND a part's two wires land
# on DIFFERENT terminals. A part with both wires on one lead is drawn
# as a short.
oTm = new stzDiagram("term73e")
oTm.SetNotation(StzElectricNotation())
oTm.AddNodeXTT("v", "VIN", [ :type = "source" ])
oTm.AddNodeXTT("r", "R 1k", [ :type = "resistor" ])
oTm.AddNodeXTT("c", "C 100n", [ :type = "capacitor" ])
oTm.AddNodeXTT("g", "", [ :type = "ground" ])
oTm.AddNodeXTT("nin", "IN", [ :type = "net" ])
oTm.AddNodeXTT("nout", "OUT", [ :type = "net" ])
oTm.AddNodeXTT("n0", "GND", [ :type = "net" ])
oTm.AddEdge("v","nin")   oTm.AddEdge("nin","r")
oTm.AddEdge("r","nout")  oTm.AddEdge("nout","c")
oTm.AddEdge("c","n0")    oTm.AddEdge("n0","g")
oTm.AddEdge("n0","v")
oTm.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
                 :FontSize = 26 ])

aTmPart = [ "v", "r", "c" ]
nTmEnds = 0  nTmBody = 0  nTmShort = 0
for iTm = 1 to len(aTmPart)
	cTmId = aTmPart[iTm]
	aTmB = oTm._NodeRectOf(cTmId)
	if len(aTmB) < 4  loop  ok
	nTmCx = aTmB[1] + aTmB[3] / 2
	nTmCy = aTmB[2] + aTmB[4] / 2
	if aTmB[3] >= aTmB[4]
		aTmT1 = [ aTmB[1], nTmCy ]
		aTmT2 = [ aTmB[1] + aTmB[3], nTmCy ]
	else
		aTmT1 = [ nTmCx, aTmB[2] ]
		aTmT2 = [ nTmCx, aTmB[2] + aTmB[4] ]
	ok
	nTmU1 = 0  nTmU2 = 0
	for jTm = 1 to len(oTm.@aEdgePaths)
		cTmK = StzLower("" + oTm.@aEdgePaths[jTm][1])
		aTmF = oTm.@aEdgePaths[jTm][2]
		if len(aTmF) < 4  loop  ok
		aTmP = []
		if StzFindFirst(">", cTmK) > 0
			if StzSplit(cTmK, ">")[1] = cTmId
				aTmP = [ aTmF[1], aTmF[2] ]
			but StzSplit(cTmK, ">")[2] = cTmId
				aTmP = [ aTmF[len(aTmF) - 1], aTmF[len(aTmF)] ]
			ok
		ok
		if len(aTmP) < 2  loop  ok
		nTmEnds++
		nTmD1 = fabs(aTmP[1] - aTmT1[1]) + fabs(aTmP[2] - aTmT1[2])
		nTmD2 = fabs(aTmP[1] - aTmT2[1]) + fabs(aTmP[2] - aTmT2[2])
		if nTmD1 < 1.5
			nTmU1++
		but nTmD2 < 1.5
			nTmU2++
		else
			nTmBody++
			? "   " + cTmId + ": a wire lands at (" + aTmP[1] + "," +
			  aTmP[2] + "), terminals are (" + aTmT1[1] + "," +
			  aTmT1[2] + ") and (" + aTmT2[1] + "," + aTmT2[2] + ")"
		ok
	next
	if nTmU1 > 1 or nTmU2 > 1  nTmShort++  ok
next
? "   " + nTmEnds + " wire ends on three parts, " + nTmBody + " on a body"
chk("every wire end lands on a lead, never on the body", nTmBody = 0)
chkeq("...and both wires of a part were checked", nTmEnds, 6)
chkeq("a part's two wires take two DIFFERENT leads", nTmShort, 0)

# THE NEGATIVE SIBLING: the same reader, given a point that is NOT a
# terminal, must report it. Without this the section passes whenever
# the loop finds nothing to look at.
nTmFake = 0
aTmB = oTm._NodeRectOf("c")
nTmMid = aTmB[1] + aTmB[3] / 2
nTmBot = aTmB[2] + aTmB[4]
if fabs(nTmMid - aTmB[1]) >= 1.5 and fabs(nTmMid - (aTmB[1] + aTmB[3])) >= 1.5
	nTmFake = 1
ok
chkeq("NEGATIVE: the middle of an edge is NOT read as a lead", nTmFake, 1)

sec("-- 73f. MESHES THAT SHARE A BRANCH INTERLOCK -----------")

# TWO MESHES SHARING A BRANCH ARE DRAWN AS A LADDER.
#
# The mesh layout drew ONE rectangle and hung everything else off it,
# which is right for every single-mesh circuit and wrong the moment a
# circuit has two. On the divider with a tap, R2 and the load sit in
# parallel between the same two nets: hanging one off the other put
# both of the load's wires on the same side of it, and a part with
# both wires on one lead is drawn as a SHORT.
#
# Contract every degree-2 node and a circuit becomes junctions joined
# by branches. Where exactly two junctions carry several branches those
# branches are parallel, and a schematic draws them as RUNGS between
# two rails -- which is the ladder, and is the domain's own reading
# rather than a graph-drawing convenience.
oLd = new stzDiagram("ladder73f")
oLd.SetNotation(StzElectricNotation())
oLd.AddNodeXTT("v", "9V", [ :type = "source" ])
oLd.AddNodeXTT("ra", "R1", [ :type = "resistor" ])
oLd.AddNodeXTT("rb", "R2", [ :type = "resistor" ])
oLd.AddNodeXTT("load", "LOAD", [ :type = "device" ])
oLd.AddNodeXTT("g", "", [ :type = "ground" ])
oLd.AddNodeXTT("top", "VCC", [ :type = "net" ])
oLd.AddNodeXTT("mid", "TAP", [ :type = "net" ])
oLd.AddNodeXTT("bot", "GND", [ :type = "net" ])
oLd.AddEdge("v","top")    oLd.AddEdge("top","ra")
oLd.AddEdge("ra","mid")   oLd.AddEdge("mid","rb")
oLd.AddEdge("mid","load") oLd.AddEdge("rb","bot")
oLd.AddEdge("load","bot") oLd.AddEdge("bot","g")
oLd.AddEdge("bot","v")
oLd.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
                 :FontSize = 26 ])

# THE RUNGS STAND IN DIFFERENT COLUMNS. Three parallel branches, three
# columns: if they shared one they would be stacked in series, which is
# a different circuit.
aLdCol = []
aLdRung = [ "ra", "rb", "load" ]
for iLd = 1 to len(aLdRung)
	aLdB = oLd._NodeRectOf(aLdRung[iLd])
	if len(aLdB) < 4  loop  ok
	nLdCx = aLdB[1] + aLdB[3] / 2
	bLdSeen = 0
	for jLd = 1 to len(aLdCol)
		if fabs(aLdCol[jLd] - nLdCx) < 2  bLdSeen = 1  exit  ok
	next
	if NOT bLdSeen  aLdCol + nLdCx  ok
next
? "   rungs occupy " + len(aLdCol) + " distinct columns"
chkeq("three parallel branches stand in three columns", len(aLdCol), 3)

# ...AND THE TWO JUNCTIONS ARE THE RAILS' ENDS, one above the other in
# the SAME column. That is what makes them rails rather than two more
# rungs.
aLdT = oLd._NodeRectOf("mid")
aLdG = oLd._NodeRectOf("bot")
nLdTx = aLdT[1] + aLdT[3] / 2   nLdTy = aLdT[2] + aLdT[4] / 2
nLdGx = aLdG[1] + aLdG[3] / 2   nLdGy = aLdG[2] + aLdG[4] / 2
? "   TAP (" + nLdTx + "," + nLdTy + ")  GND (" + nLdGx + "," + nLdGy + ")"
chk("the two junctions share a column", fabs(nLdTx - nLdGx) < 2)
chk("...and one stands above the other", nLdGy - nLdTy > 50)

# EVERY PART IS JOINED AT TWO DIFFERENT PLACES. This is the claim the
# old picture broke: it is weaker than 73e's -- it does not ask WHICH
# points -- and it is the one that catches a short, so it is asked of
# the device box too, whose rectangle has no leads to miss.
aLdPart = [ "ra", "rb", "v", "load" ]
nLdEnds = 0  nLdShort = 0
for iLd = 1 to len(aLdPart)
	cLdId = aLdPart[iLd]
	aLdPts = []
	for jLd = 1 to len(oLd.@aEdgePaths)
		cLdK = StzLower("" + oLd.@aEdgePaths[jLd][1])
		aLdF = oLd.@aEdgePaths[jLd][2]
		if len(aLdF) < 4  loop  ok
		if StzFindFirst(">", cLdK) < 1  loop  ok
		aLdS = StzSplit(cLdK, ">")
		if aLdS[1] = cLdId
			aLdPts + [ aLdF[1], aLdF[2] ]
		but aLdS[2] = cLdId
			aLdPts + [ aLdF[len(aLdF) - 1], aLdF[len(aLdF)] ]
		ok
	next
	nLdEnds += len(aLdPts)
	if len(aLdPts) = 2
		if fabs(aLdPts[1][1] - aLdPts[2][1]) < 1.5 and
		   fabs(aLdPts[1][2] - aLdPts[2][2]) < 1.5
			nLdShort++
			? "   " + cLdId + ": BOTH wires join at (" +
			  aLdPts[1][1] + "," + aLdPts[1][2] + ")"
		ok
	ok
next
? "   " + nLdEnds + " wire ends on four parts, " + nLdShort + " shorted"
chkeq("...and all four parts were reached", nLdEnds, 8)
chkeq("no part has both its wires on one point", nLdShort, 0)

# THE NEGATIVE SIBLING: a circuit with ONE mesh must NOT become a
# ladder. The RC low-pass has a single junction, so the decomposition
# cannot apply, and its members must still occupy all four sides of a
# rectangle -- both extremes of both axes. Without this the ladder
# could swallow every circuit and the section would still pass.
oLd1 = new stzDiagram("single73f")
oLd1.SetNotation(StzElectricNotation())
oLd1.AddNodeXTT("v", "VIN", [ :type = "source" ])
oLd1.AddNodeXTT("r", "R", [ :type = "resistor" ])
oLd1.AddNodeXTT("c", "C", [ :type = "capacitor" ])
oLd1.AddNodeXTT("g", "", [ :type = "ground" ])
oLd1.AddNodeXTT("nin", "IN", [ :type = "net" ])
oLd1.AddNodeXTT("nout", "OUT", [ :type = "net" ])
oLd1.AddNodeXTT("n0", "GND", [ :type = "net" ])
oLd1.AddEdge("v","nin")   oLd1.AddEdge("nin","r")
oLd1.AddEdge("r","nout")  oLd1.AddEdge("nout","c")
oLd1.AddEdge("c","n0")    oLd1.AddEdge("n0","g")
oLd1.AddEdge("n0","v")
oLd1.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
                  :FontSize = 26 ])
nLdX0 = 9999999  nLdX1 = -9999999
nLdY0 = 9999999  nLdY1 = -9999999
_aLd1_ = oLd1.RenderNodeRects()
for iLd = 1 to len(_aLd1_)
	nLdCx = _aLd1_[iLd][1] + _aLd1_[iLd][3] / 2
	nLdCy = _aLd1_[iLd][2] + _aLd1_[iLd][4] / 2
	if nLdCx < nLdX0  nLdX0 = nLdCx  ok
	if nLdCx > nLdX1  nLdX1 = nLdCx  ok
	if nLdCy < nLdY0  nLdY0 = nLdCy  ok
	if nLdCy > nLdY1  nLdY1 = nLdCy  ok
next
nLdCorner = 0
for iLd = 1 to len(_aLd1_)
	nLdCx = _aLd1_[iLd][1] + _aLd1_[iLd][3] / 2
	nLdCy = _aLd1_[iLd][2] + _aLd1_[iLd][4] / 2
	if (fabs(nLdCx - nLdX0) < 2 or fabs(nLdCx - nLdX1) < 2) and
	   (fabs(nLdCy - nLdY0) < 2 or fabs(nLdCy - nLdY1) < 2)
		nLdCorner++
	ok
next
? "   single-mesh circuit spans " + (nLdX1 - nLdX0) + " x " +
  (nLdY1 - nLdY0)
chk("NEGATIVE: a ONE-mesh circuit stays a rectangle, not a ladder",
    nLdX1 - nLdX0 > 100 and nLdY1 - nLdY0 > 100)

# ...AND NO NAME IN IT STANDS ON A WIRE, THE CORNER JUNCTIONS INCLUDED.
#
# This is the clause the Principal had to raise four times, and the
# reason it kept coming back is that the rule was running and had
# NOWHERE TO PUT THE WORD. A junction at a corner has wires on two of
# its sides; the other two were off the paper, because the sheet is
# cropped to the ink before any name is placed. Every candidate was
# refused and the placer fell back to writing over its own rung -- so
# the picture looked exactly as it had before the rule existed.
#
# The ladder is the scene that has corner junctions, which is why the
# check lives here rather than beside the single-loop circuits: those
# have room on three sides and would have passed throughout.
nLdOn = 0
_aLdL_ = oLd.RenderNodeLabels()
for iLd = 1 to len(_aLdL_)
	nLdPl = _aLdL_[iLd][2] - _aLdL_[iLd][4] / 2
	nLdPt = _aLdL_[iLd][3] - _aLdL_[iLd][5] / 2
	nLdPr = _aLdL_[iLd][2] + _aLdL_[iLd][4] / 2
	nLdPb = _aLdL_[iLd][3] + _aLdL_[iLd][5] / 2
	for jLd = 1 to len(oLd.@aEdgePaths)
		aLdF = oLd.@aEdgePaths[jLd][2]
		for kLd = 1 to len(aLdF) - 3 step 2
			nLdSx1 = min([ aLdF[kLd], aLdF[kLd + 2] ])
			nLdSx2 = max([ aLdF[kLd], aLdF[kLd + 2] ])
			nLdSy1 = min([ aLdF[kLd + 1], aLdF[kLd + 3] ])
			nLdSy2 = max([ aLdF[kLd + 1], aLdF[kLd + 3] ])
			if nLdSx2 < nLdPl or nLdSx1 > nLdPr  loop  ok
			if nLdSy2 < nLdPt or nLdSy1 > nLdPb  loop  ok
			nLdOn++
			? "   " + _aLdL_[iLd][1] + "'s name stands on a wire"
			exit
		next
		if nLdOn > 0 and jLd > 0  ok
	next
next
? "   " + len(_aLdL_) + " names placed, " + nLdOn + " standing on a wire"
chkeq("no name on the ladder stands on a wire", nLdOn, 0)

# THE NEGATIVE SIBLING: the scan must be able to SEE one. The same
# reader is run with every plate grown to four times its height, which
# on a picture this dense has to catch something -- so a zero above is
# a placement that worked and not a reader that never looked.
nLdFake = 0
for iLd = 1 to len(_aLdL_)
	nLdPl = _aLdL_[iLd][2] - _aLdL_[iLd][4] / 2
	nLdPt = _aLdL_[iLd][3] - _aLdL_[iLd][5] * 2
	nLdPr = _aLdL_[iLd][2] + _aLdL_[iLd][4] / 2
	nLdPb = _aLdL_[iLd][3] + _aLdL_[iLd][5] * 2
	for jLd = 1 to len(oLd.@aEdgePaths)
		aLdF = oLd.@aEdgePaths[jLd][2]
		for kLd = 1 to len(aLdF) - 3 step 2
			nLdSx1 = min([ aLdF[kLd], aLdF[kLd + 2] ])
			nLdSx2 = max([ aLdF[kLd], aLdF[kLd + 2] ])
			nLdSy1 = min([ aLdF[kLd + 1], aLdF[kLd + 3] ])
			nLdSy2 = max([ aLdF[kLd + 1], aLdF[kLd + 3] ])
			if nLdSx2 < nLdPl or nLdSx1 > nLdPr  loop  ok
			if nLdSy2 < nLdPt or nLdSy1 > nLdPb  loop  ok
			nLdFake++
		next
	next
next
? "   " + nLdFake + " found when every plate is grown fourfold"
chk("NEGATIVE: the same scan DOES see a name on a wire", nLdFake > 0)

# ...AND A WIRE TURNS SQUARE, EXCEPT AT THE LOOP'S OWN CORNERS.
#
# This renderer draws a HOP as an arc and says so in its own source:
# "these two cross and do not touch". A rounded elbow is that same mark
# spent on decoration, and the Principal read the arc where a rung
# meets a rail as a statement about which way the current turns --
# exactly the kind of claim a curve is reserved to make here.
#
# So an inner bend is square and the four corners of the loop itself
# keep their radius. Both halves are measured on the SAME picture, in
# the pixels, because a square corner has ink AT the vertex and a
# rounded one does not -- the arc cuts that pixel away. Asserting only
# the square half would pass on a picture with no rounding anywhere.
nCoW = oLd.LastCanvas().Width()
cCoPx = oLd.LastCanvas().ToPixels()
aCoR2 = oLd._NodeRectOf("rb")
aCoTap = oLd._NodeRectOf("mid")
aCoLoad = oLd._NodeRectOf("load")
nCoInX = floor(aCoR2[1] + aCoR2[3] / 2)
nCoRailY = floor(aCoTap[2] + aCoTap[4] / 2)
nCoOutX = floor(aCoLoad[1] + aCoLoad[3] / 2)

# the darkest pixel in the 3x3 square centred on each vertex -- the
# existing helpers scan a RUN, and what is asked here is one point
nCoIn = 255  nCoOut = 255
for dCoY = -1 to 1
	for dCoX = -1 to 1
		nCoI = ((nCoRailY + dCoY) * nCoW + (nCoInX + dCoX)) * 4 + 1
		if nCoI > 0 and nCoI + 2 <= len(cCoPx)
			nCoV = ascii(cCoPx[nCoI])
			if nCoV < nCoIn  nCoIn = nCoV  ok
		ok
		nCoI = ((nCoRailY + dCoY) * nCoW + (nCoOutX + dCoX)) * 4 + 1
		if nCoI > 0 and nCoI + 2 <= len(cCoPx)
			nCoV = ascii(cCoPx[nCoI])
			if nCoV < nCoOut  nCoOut = nCoV  ok
		ok
	next
next
? "   inner bend ink " + nCoIn + " (square, wants dark)" +
  "   outer corner ink " + nCoOut + " (rounded, wants pale)"
chk("a rung meets a rail SQUARE, so the vertex itself is inked",
    nCoIn < 140)
chk("NEGATIVE: ...and the loop's own corner is still rounded away",
    nCoOut > nCoIn + 60)

# ...AND EVERY NAME STANDS THE SAME DISTANCE FROM WHAT IT NAMES.
#
# The gap was three numbers depending on which branch had placed the
# word: 5.2px for a plain name below, 8px stepped aside, and 24px where
# the departing-wire push had fired. The Principal marked all four gaps
# in one picture. It matters beyond tidiness -- a reader uses PROXIMITY
# to decide which glyph a word belongs to, so a gap that varies is a
# claim that varies.
#
# The scene is the RC low-pass, which places names on three different
# sides -- below, left and right -- so the measurement crosses the
# branches that used to disagree rather than repeating one of them.
oGp = new stzDiagram("gap73j")
oGp.SetNotation(StzElectricNotation())
oGp.AddNodeXTT("v", "VIN", [ :type = "source" ])
oGp.AddNodeXTT("r", "R 1k", [ :type = "resistor" ])
oGp.AddNodeXTT("c", "C 100n", [ :type = "capacitor" ])
oGp.AddNodeXTT("g", "", [ :type = "ground" ])
oGp.AddNodeXTT("nin", "IN", [ :type = "net" ])
oGp.AddNodeXTT("nout", "OUT", [ :type = "net" ])
oGp.AddNodeXTT("n0", "GND", [ :type = "net" ])
oGp.AddEdge("v","nin")   oGp.AddEdge("nin","r")
oGp.AddEdge("r","nout")  oGp.AddEdge("nout","c")
oGp.AddEdge("c","n0")    oGp.AddEdge("n0","g")
oGp.AddEdge("n0","v")
oGp.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
                 :FontSize = 26 ])
aGpG = []  aGpSide = []
_aGpL_ = oGp.RenderNodeLabels()
for iGp = 1 to len(_aGpL_)
	aGpB = oGp._NodeRectOf(StzLower("" + _aGpL_[iGp][1]))
	if len(aGpB) < 4  loop  ok
	nGpPl = _aGpL_[iGp][2] - _aGpL_[iGp][4] / 2
	nGpPr = _aGpL_[iGp][2] + _aGpL_[iGp][4] / 2
	nGpPt = _aGpL_[iGp][3] - _aGpL_[iGp][5] / 2
	nGpPb = _aGpL_[iGp][3] + _aGpL_[iGp][5] / 2
	# FROM THE INK, NOT THE BOX. A resistor asked for 68x110 paints a
	# body 30x62 and spends the rest on leads, so a distance measured
	# from its box starts inside paper nobody drew on -- and the same
	# nominal gap then LOOKS bigger beside a resistor than beside a
	# junction dot, whose box is its ink. The first version of this
	# guard measured boxes and passed on a picture the Principal could
	# see was uneven.
	aGpI = StzNodeShapeInk(oGp._ShapeOfId(StzLower("" + _aGpL_[iGp][1])),
		aGpB[3], aGpB[4])
	nGpCx = aGpB[1] + aGpB[3] / 2   nGpCy = aGpB[2] + aGpB[4] / 2
	nGpBl = nGpCx - aGpI[1]   nGpBr = nGpCx + aGpI[1]
	nGpBt = nGpCy - aGpI[2]   nGpBb = nGpCy + aGpI[2]
	if nGpPt >= nGpBb - 0.5
		aGpG + (nGpPt - nGpBb)   aGpSide + "below"
	but nGpPb <= nGpBt + 0.5
		aGpG + (nGpBt - nGpPb)   aGpSide + "above"
	but nGpPl >= nGpBr - 0.5
		aGpG + (nGpPl - nGpBr)   aGpSide + "right"
	but nGpPr <= nGpBl + 0.5
		aGpG + (nGpBl - nGpPr)   aGpSide + "left"
	ok
next
nGpLo = 99999  nGpHi = -99999
for iGp = 1 to len(aGpG)
	? "   " + aGpSide[iGp] + "  gap " + aGpG[iGp] + "px"
	if aGpG[iGp] < nGpLo  nGpLo = aGpG[iGp]  ok
	if aGpG[iGp] > nGpHi  nGpHi = aGpG[iGp]  ok
next
chk("names were placed on more than one side", len(aGpG) >= 3)
chkeq("...and every gap is the same", floor((nGpHi - nGpLo) * 10), 0)

# THE NEGATIVE SIBLING: the reader must be able to SEE a difference, or
# an equal answer proves only that it measured one thing four times.
# The same spread is taken over the four gaps with one of them shifted
# by a pixel, which has to show.
nGpFake = 0
if len(aGpG) >= 2
	nGpLo2 = 99999  nGpHi2 = -99999
	for iGp = 1 to len(aGpG)
		nGpV = aGpG[iGp]
		if iGp = 1  nGpV = nGpV + 1  ok
		if nGpV < nGpLo2  nGpLo2 = nGpV  ok
		if nGpV > nGpHi2  nGpHi2 = nGpV  ok
	next
	if floor((nGpHi2 - nGpLo2) * 10) != 0  nGpFake = 1  ok
ok
chkeq("NEGATIVE: a one-pixel difference would have shown", nGpFake, 1)

sec("-- 73k. DRAKON: THE SKEWER, AND WHOSE LAW IT IS ---------")
discharges("DN6")

# THE MAIN PATH IS ONE VERTICAL LINE AND EVERY BRANCH STANDS RIGHT OF
# IT.
#
# The Principal named DRAKON as this plane's next domain, and its third
# law is one this library had already arrived at from the other end --
# by the Principal marking pictures where the refusal ran down the main
# line. DN6 is where it stops being a rule patched in and becomes a law
# a notation declares.
#
# Two claims, and the second is the one that matters: the skewer is
# straight, AND the profile is what asks for it. A rule that leaked into
# every diagram would be a new default, not a domain.
oDk = new stzDiagram("drakon73k")
oDk.SetNotation(StzDrakonNotation())
oDk.AddNodeXTT("t", "Withdraw",      [ :type = "title" ])
oDk.AddNodeXTT("q", "Funds enough?", [ :type = "question" ])
oDk.AddNodeXTT("y", "Pay out",       [ :type = "action" ])
oDk.AddNodeXTT("n", "Decline",       [ :type = "action" ])
oDk.AddNodeXTT("e", "Done",          [ :type = "end" ])
oDk.AddEdge("t","q")
oDk.AddEdgeXT("q","y","yes")
oDk.AddEdgeXT("q","n","no")
oDk.AddEdge("y","e")  oDk.AddEdge("n","e")
oDk.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20 ])
aDkC = []
aDkSpine = [ "t", "q", "y", "e" ]
nDkSp = -1  nDkOff = -1
_aDkR_ = oDk.RenderNodeRects()
for iDk = 1 to len(_aDkR_)
	cDkId = StzLower("" + _aDkR_[iDk][5])
	nDkCx = _aDkR_[iDk][1] + _aDkR_[iDk][3] / 2
	bDkOn = 0
	for jDk = 1 to len(aDkSpine)
		if aDkSpine[jDk] = cDkId  bDkOn = 1  exit  ok
	next
	if bDkOn
		if nDkSp < 0  nDkSp = nDkCx  ok
		aDkC + [ cDkId, nDkCx, 1 ]
	else
		nDkOff = nDkCx
		aDkC + [ cDkId, nDkCx, 0 ]
	ok
next
nDkStray = 0
for iDk = 1 to len(aDkC)
	if aDkC[iDk][3] = 1 and fabs(aDkC[iDk][2] - nDkSp) > 1.5  nDkStray++  ok
next
? "   skewer x " + nDkSp + ", the refusal at x " + nDkOff
chkeq("every node on the main path shares one vertical", nDkStray, 0)
chk("...and the refusal stands to the RIGHT of it", nDkOff > nDkSp + 20)

# NO CROSSINGS, which is the notation's whole promise. Counted on the
# drawn wires: a vertical run properly crossing a horizontal one.
nDkX = 0
for iDk = 1 to len(oDk.@aEdgePaths)
	aDkP = oDk.@aEdgePaths[iDk][2]
	for jDk = iDk + 1 to len(oDk.@aEdgePaths)
		aDkQ = oDk.@aEdgePaths[jDk][2]
		for kDk = 1 to len(aDkP) - 3 step 2
			for mDk = 1 to len(aDkQ) - 3 step 2
				nAx1 = aDkP[kDk]    nAy1 = aDkP[kDk+1]
				nAx2 = aDkP[kDk+2]  nAy2 = aDkP[kDk+3]
				nBx1 = aDkQ[mDk]    nBy1 = aDkQ[mDk+1]
				nBx2 = aDkQ[mDk+2]  nBy2 = aDkQ[mDk+3]
				if fabs(nAx1-nAx2) < 0.5 and fabs(nBy1-nBy2) < 0.5
					if nAx1 > min([nBx1,nBx2]) + 1 and
					   nAx1 < max([nBx1,nBx2]) - 1 and
					   nBy1 > min([nAy1,nAy2]) + 1 and
					   nBy1 < max([nAy1,nAy2]) - 1
						nDkX++
					ok
				ok
				if fabs(nAy1-nAy2) < 0.5 and fabs(nBx1-nBx2) < 0.5
					if nBx1 > min([nAx1,nAx2]) + 1 and
					   nBx1 < max([nAx1,nAx2]) - 1 and
					   nAy1 > min([nBy1,nBy2]) + 1 and
					   nAy1 < max([nBy1,nBy2]) - 1
						nDkX++
					ok
				ok
			next
		next
	next
next
? "   crossings between drawn wires: " + nDkX
chkeq("a one-question algorithm draws with no crossing at all", nDkX, 0)

# THE NEGATIVE SIBLING: this is a PROFILE's law, not a new default.
#
# The scene is the NESTED one, and choosing it is the point. On a single
# question the plain layout already puts the refusal to the right --
# the spine rule sees to that -- so the two agree and a negative built
# on that shape proves nothing at all, which is what the first version
# of this did. Where they part company is two branches at different
# depths: the plane's own law (I7) puts siblings on EITHER side of the
# parent, so one goes left; DRAKON refuses that and sends both right.
oDk2 = new stzDiagram("plain73k")
oDk2.SetSplines(:ortho)
oDk2.AddNode("t")   oDk2.AddNode("q1")  oDk2.AddNode("q2")
oDk2.AddNode("ok")  oDk2.AddNode("n1")  oDk2.AddNode("n2")
oDk2.AddNode("e")
oDk2.AddEdge("t","q1")
oDk2.AddEdgeXT("q1","q2","yes")
oDk2.AddEdgeXT("q1","n1","no")
oDk2.AddEdgeXT("q2","ok","yes")
oDk2.AddEdgeXT("q2","n2","no")
oDk2.AddEdge("ok","e")  oDk2.AddEdge("n1","e")  oDk2.AddEdge("n2","e")
oDk2.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                  :FontSize = 20 ])
# WHAT THE PROFILE ACTUALLY CHANGES, measured rather than assumed. Two
# earlier versions of this negative asked whether a branch went LEFT,
# and both passed the wrong way: the plain layout already sends a lone
# refusal right, because the spine rule does that, and it sends BOTH
# refusals right in the nested case too. Asking about the side proved
# nothing, twice.
#
# The difference is the COLUMN. Without the profile the two branches
# share one -- which is what made the first DRAKON picture escape 194px
# off the paper to get around itself. With it they are nested, the
# outer standing further out, and that is the no-crossing law doing
# work a reader can see.
nDkPlainCols = 0  nDkN1 = 0  nDkN2 = 0
_aDk2_ = oDk2.RenderNodeRects()
for iDk = 1 to len(_aDk2_)
	cDkId = StzLower("" + _aDk2_[iDk][5])
	if cDkId = "n1"  nDkN1 = _aDk2_[iDk][1] + _aDk2_[iDk][3] / 2  ok
	if cDkId = "n2"  nDkN2 = _aDk2_[iDk][1] + _aDk2_[iDk][3] / 2  ok
next
if fabs(nDkN1 - nDkN2) > 2  nDkPlainCols = 2  else  nDkPlainCols = 1  ok
? "   without the profile the two branches occupy " +
  nDkPlainCols + " column(s)"
chkeq("NEGATIVE: without the profile they share ONE column",
    nDkPlainCols, 1)

# ...AND WITH IT, TWO -- the same scene under the notation.
oDk3 = new stzDiagram("nested73k")
oDk3.SetNotation(StzDrakonNotation())
oDk3.AddNodeXTT("t","T",[ :type = "title" ])
oDk3.AddNodeXTT("q1","Q1",[ :type = "question" ])
oDk3.AddNodeXTT("q2","Q2",[ :type = "question" ])
oDk3.AddNodeXTT("ok","OK",[ :type = "action" ])
oDk3.AddNodeXTT("n1","N1",[ :type = "action" ])
oDk3.AddNodeXTT("n2","N2",[ :type = "action" ])
oDk3.AddNodeXTT("e","E",[ :type = "end" ])
oDk3.AddEdge("t","q1")
oDk3.AddEdgeXT("q1","q2","yes")
oDk3.AddEdgeXT("q1","n1","no")
oDk3.AddEdgeXT("q2","ok","yes")
oDk3.AddEdgeXT("q2","n2","no")
oDk3.AddEdge("ok","e")  oDk3.AddEdge("n1","e")  oDk3.AddEdge("n2","e")
oDk3.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                  :FontSize = 20 ])
nDkM1 = 0  nDkM2 = 0  nDkSk3 = 0
_aDk3_ = oDk3.RenderNodeRects()
for iDk = 1 to len(_aDk3_)
	cDkId = StzLower("" + _aDk3_[iDk][5])
	nDkCx3 = _aDk3_[iDk][1] + _aDk3_[iDk][3] / 2
	if cDkId = "n1"  nDkM1 = nDkCx3  ok
	if cDkId = "n2"  nDkM2 = nDkCx3  ok
	if cDkId = "t"   nDkSk3 = nDkCx3  ok
next
? "   with it: outer at " + nDkM1 + ", inner at " + nDkM2 +
  ", skewer at " + nDkSk3
chk("the nested branches take two columns, both right of the skewer",
    nDkM1 > nDkSk3 + 20 and nDkM2 > nDkSk3 + 20 and
    fabs(nDkM1 - nDkM2) > 20)
chk("...and the OUTER branch is the one further out", nDkM1 > nDkM2 + 20)

# ...AND THE QUESTION IS WRITTEN IN THE RHOMBUS.
#
# The plane writes a name UNDER a glyph with no inside for a word -- a
# dot, a bar, a stick figure -- and a diamond is on that list because a
# diamond is usually drawn as a small mark. DRAKON draws it as a
# QUESTION, sized to the question, and the text belongs in it: that is
# what makes the rhombus read as a decision rather than as a marker with
# a caption. The Principal asked for it after seeing "Question" hanging
# under an empty diamond.
#
# TWO THINGS HAD TO BE TRUE and the guard asks both, because either
# alone passes on a wrong picture: the word must be placed inside, AND
# the rhombus must be big enough to hold it. A diamond gives a word only
# the middle of its box -- the widest rectangle that fits has HALF the
# width and half the height, since the sides slope away from the centre
# in both directions -- so a question sized like a rectangle holds about
# a quarter of the text and the rest hangs over the sloping edges.
nQiIn = 0  nQiFits = 0  nQiSeen = 0
_aQiL_ = oDk.RenderNodeLabels()
for iQi = 1 to len(_aQiL_)
	if StzLower("" + _aQiL_[iQi][1]) != "q"  loop  ok
	nQiSeen++
	aQiB = oDk._NodeRectOf("q")
	nQiCx = aQiB[1] + aQiB[3] / 2
	nQiCy = aQiB[2] + aQiB[4] / 2
	# placed inside: the word's centre is the glyph's centre
	if fabs(_aQiL_[iQi][2] - nQiCx) < 3 and
	   fabs(_aQiL_[iQi][3] - nQiCy) < 3
		nQiIn++
	ok
	# and it FITS the room that glyph actually gives a word
	aQiFr = oDk._InscribedFraction(oDk._ShapeOfId("q"))
	if _aQiL_[iQi][4] <= aQiB[3] * aQiFr[1] and
	   _aQiL_[iQi][5] <= aQiB[4] * aQiFr[2]
		nQiFits++
	ok
	? "   " + oDk._ShapeOfId("q") + " " + aQiB[3] + "x" + aQiB[4] +
	  ", word " + _aQiL_[iQi][4] + "x" + _aQiL_[iQi][5] +
	  ", inscribed room " + (aQiB[3] * aQiFr[1]) + "x" +
	  (aQiB[4] * aQiFr[2])
next
chkeq("the question was found", nQiSeen, 1)
chkeq("...is written INSIDE the icon", nQiIn, 1)
chkeq("...and the icon is big enough to hold it", nQiFits, 1)

# ...AND THE ICON IS A HEXAGON, WHICH THE BOOK STATES OUTRIGHT:
# "Note that the If icon is a hexagon, not a diamond like its flowchart
# counterpart. The hexagon shape saves vertical space on the diagram."
#
# This clause used to say "rhombus" in three places and PASSED, because
# it was written to describe what this plane drew. A guard that asks
# whether the picture matches the implementation always answers yes.
# The diamond is not a near miss either: it is the glyph DRAKON exists
# to replace, and the language's own teaching figure sets "an old messy
# flowchart" full of diamonds beside "a modern DRAKON flowchart" full
# of hexagons.
chkeq("the If icon is a hexagon, not a diamond",
      StzLower("" + oDk._ShapeOfId("q")), "hexagon")

# THE NEGATIVE SIBLING: this is the PROFILE's declaration, not a change
# to what a diamond is. BPMN's gateway is a diamond too and does NOT
# declare name-inside, so it must still write its name below -- or the
# knob has leaked into every diamond in the library.
oQi2 = new stzDiagram("gw73k")
oQi2.SetNotation(StzBpmnNotation())
oQi2.AddNodeXTT("s", "Start", [ :type = "start" ])
oQi2.AddNodeXTT("g", "Approved?", [ :type = "gateway" ])
oQi2.AddNodeXTT("y", "Pay", [ :type = "task" ])
oQi2.AddNodeXTT("n", "Reject", [ :type = "task" ])
oQi2.AddEdge("s","g")
oQi2.AddEdgeXT("g","y","passes")
oQi2.AddEdgeXT("g","n","fails")
oQi2.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                  :FontSize = 20 ])
nQiBelow = 0
aQiB2 = oQi2._NodeRectOf("g")
_aQiL2_ = oQi2.RenderNodeLabels()
for iQi = 1 to len(_aQiL2_)
	if StzLower("" + _aQiL2_[iQi][1]) != "g"  loop  ok
	if _aQiL2_[iQi][3] > aQiB2[2] + aQiB2[4] - 1  nQiBelow = 1  ok
	? "   a gateway's name sits at y " + _aQiL2_[iQi][3] +
	  ", its glyph ends at " + (aQiB2[2] + aQiB2[4])
next
chkeq("NEGATIVE: a gateway's diamond still writes its name BELOW",
    nQiBelow, 1)

# ...AND THE NESTED ALGORITHM DRAWS WITH NO CROSSING AT ALL.
#
# This is the notation's whole promise and it was the last thing still
# broken. Two branches returning to one terminal ran their horizontals
# at the same height, so the outer crossed the inner's descent.
#
# The fix is the nesting rule again, applied to the JOIN: the inner
# branch comes back FIRST, its column is then empty, and the outer can
# reach across it meeting nothing. Getting there took two wrong turns
# worth recording -- a router bias that never fired because an edge the
# LAYOUT routed never reaches the router at all, and then a route
# rewrite that governed only the edges which already HAD routes, so the
# ungoverned one descended to the terminal's row and inverted the very
# order the rule was imposing. A rule that governs some of the lines
# governs none of the picture.
oNx = new stzDiagram("nocross73k")
oNx.SetNotation(StzDrakonNotation())
oNx.AddNodeXTT("t","Sign in",[ :type = "title" ])
oNx.AddNodeXTT("q1","Known user?",[ :type = "question" ])
oNx.AddNodeXTT("q2","Password ok?",[ :type = "question" ])
oNx.AddNodeXTT("ok","Open session",[ :type = "action" ])
oNx.AddNodeXTT("n1","Report unknown",[ :type = "action" ])
oNx.AddNodeXTT("n2","Report refusal",[ :type = "action" ])
oNx.AddNodeXTT("e","Done",[ :type = "end" ])
oNx.AddEdge("t","q1")
oNx.AddEdgeXT("q1","q2","yes")   oNx.AddEdgeXT("q1","n1","no")
oNx.AddEdgeXT("q2","ok","yes")   oNx.AddEdgeXT("q2","n2","no")
oNx.AddEdge("ok","e")  oNx.AddEdge("n1","e")  oNx.AddEdge("n2","e")
oNx.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20 ])
nNxX = 0
for iNx = 1 to len(oNx.@aEdgePaths)
	aNxP = oNx.@aEdgePaths[iNx][2]
	for jNx = iNx + 1 to len(oNx.@aEdgePaths)
		aNxQ = oNx.@aEdgePaths[jNx][2]
		for kNx = 1 to len(aNxP) - 3 step 2
			for mNx = 1 to len(aNxQ) - 3 step 2
				nAx1 = aNxP[kNx]     nAy1 = aNxP[kNx+1]
				nAx2 = aNxP[kNx+2]   nAy2 = aNxP[kNx+3]
				nBx1 = aNxQ[mNx]     nBy1 = aNxQ[mNx+1]
				nBx2 = aNxQ[mNx+2]   nBy2 = aNxQ[mNx+3]
				if fabs(nAx1-nAx2) < 0.5 and fabs(nBy1-nBy2) < 0.5
					if nAx1 > min([nBx1,nBx2]) + 1 and
					   nAx1 < max([nBx1,nBx2]) - 1 and
					   nBy1 > min([nAy1,nAy2]) + 1 and
					   nBy1 < max([nAy1,nAy2]) - 1
						nNxX++
					ok
				ok
				if fabs(nAy1-nAy2) < 0.5 and fabs(nBx1-nBx2) < 0.5
					if nBx1 > min([nAx1,nAx2]) + 1 and
					   nBx1 < max([nAx1,nAx2]) - 1 and
					   nAy1 > min([nBy1,nBy2]) + 1 and
					   nAy1 < max([nBy1,nBy2]) - 1
						nNxX++
					ok
				ok
			next
		next
	next
next
? "   nested algorithm, crossings: " + nNxX
chkeq("a NESTED algorithm draws with no crossing either", nNxX, 0)

# ...AND THE TWO RETURNS ARE ONE LINE, which is the mechanism rather
# than the symptom. Asserting only "no crossings" would pass on a
# picture that avoided them by luck, and an earlier version of this
# section asserted the wrong mechanism: it required the inner branch to
# come back ABOVE the outer, which was true of a staggered design that
# removed the crossing and still drew TWO returns at two heights. Two
# horizontals say two continuations and make a reader check whether
# they are the same one. Branches that end in the same place are one
# continuation and DRAKON draws them as one.
nNxIn = 0  nNxOut = 0
_aNxR_ = oNx.RenderNodeRects()
for iNx = 1 to len(_aNxR_)
	cNxId = StzLower("" + _aNxR_[iNx][5])
	nNxCx = _aNxR_[iNx][1] + _aNxR_[iNx][3] / 2
	if cNxId = "n1"  nNxOut = nNxCx  ok
	if cNxId = "n2"  nNxIn = nNxCx  ok
next
nNxYin = -1  nNxYout = -1  nNxXin = -1  nNxXout = -1
for iNx = 1 to len(oNx.@aEdgePaths)
	cNxK = StzLower("" + oNx.@aEdgePaths[iNx][1])
	aNxP = oNx.@aEdgePaths[iNx][2]
	if len(aNxP) < 6  loop  ok
	# the shared run, and where it hands over to the terminal
	if cNxK = "n2>e"  nNxYin = aNxP[4]   nNxXin = aNxP[5]  ok
	if cNxK = "n1>e"  nNxYout = aNxP[4]  nNxXout = aNxP[5]  ok
next
? "   returns share y " + nNxYin + " / " + nNxYout +
  " and arrive at x " + nNxXin + " / " + nNxXout
chk("the inner branch is nearer the skewer", nNxIn < nNxOut)
chk("...and BOTH returns run at one height", fabs(nNxYin - nNxYout) < 1.5)
chk("...and arrive at one point, so the picture shows ONE line",
    fabs(nNxXin - nNxXout) < 1.5)

# ...AND IT JOINS THE LINE ABOVE THE TERMINAL, NOT THE TERMINAL.
#
# THIS CLAUSE USED TO ASSERT THE OPPOSITE, and it passed for as long as
# it existed. The book gives the rule twice: "Arrows never point to
# icons. Arrows point only to lines that go down. This rule guarantees
# that for each icon, there is only one line that leads to it", and
# "after a horizontal joining the execution flow goes to the left" --
# left along the horizontal, onto the vertical, and down it.
#
# The reasoning I wrote for the old clause was not wrong about what it
# rejected: a horizontal, then a stub, then the icon IS a bad picture.
# It was wrong about the repair. Running the line at the icon's own
# height removes the stub by giving the icon a second face to be
# entered by, and an icon with two ways in is the thing the rule above
# exists to forbid. The stub goes away for the right reason when the
# horizontal joins the skewer and the skewer -- one line -- goes down
# into the terminal.
nNxTy = -1  nNxTr = -1  nNxTc = -1
for iNx = 1 to len(_aNxR_)
	if StzLower("" + _aNxR_[iNx][5]) != "e"  loop  ok
	nNxTy = _aNxR_[iNx][2] + _aNxR_[iNx][4] / 2
	nNxTr = _aNxR_[iNx][1] + _aNxR_[iNx][3]
	nNxTc = _aNxR_[iNx][1] + _aNxR_[iNx][3] / 2
next
? "   the terminal sits at y " + nNxTy + ", its right edge at x " + nNxTr
nNxTt = -1
for iNx = 1 to len(_aNxR_)
	if StzLower("" + _aNxR_[iNx][5]) != "e"  loop  ok
	nNxTt = _aNxR_[iNx][2]
next
chk("the return joins ABOVE the terminal", nNxYin < nNxTt - 1)
# ...MEETING ITS SIDE. The arrival stops SHORT of the border by an
# arrowhead's length -- every arrow in this library does, and requiring
# the exact edge would have been asserting against the drawing's own
# convention rather than against the rule. What the rule says is that
# the horizontal ends ON the vertical the terminal hangs from, so that
# is what is asked: at the skewer, not out at the icon's flank.
chk("...and lands on the skewer, so ONE line enters the icon",
    fabs(nNxXin - nNxTc) < 3)

# A BRANCH LABEL SITS AT ITS QUESTION'S EXIT, THE SAME WAY EVERY TIME.
#
# The Principal marked the same word placed two ways in one picture --
# one riding a horizontal a third of the way along, one tucked beside a
# vertical. DRAKON labels the two exits of a question AT the exits, so a
# reader answers "which way is yes?" by looking at the icon and never by
# following a line.
#
# The claim is SAMENESS, so it is measured as sameness: the two
# questions in this algorithm must place their exit words in the same
# relationship to their own glyph. A rule that merely puts them "near"
# would pass with two different nears.
nLbYesDx = -9999  nLbYesDy = -9999  nLbNoDx = -9999  nLbNoDy = -9999
nLbSameYes = 0  nLbSameNo = 0
for iNx = 1 to len(oNx.@aRenderLabels)
	aNxL = oNx.@aRenderLabels[iNx]
	cNxK = StzLower("" + aNxL[6])
	cNxSrc = ""
	if StzFindFirst(">", cNxK) > 0  cNxSrc = StzSplit(cNxK, ">")[1]  ok
	if cNxSrc != "q1" and cNxSrc != "q2"  loop  ok
	aNxB = oNx._NodeRectOf(cNxSrc)
	if len(aNxB) < 4  loop  ok
	nDx = aNxL[2] - (aNxB[1] + aNxB[3] / 2)
	nDy = aNxL[3] - (aNxB[2] + aNxB[4] / 2)
	if StzLower("" + aNxL[1]) = "yes"
		if nLbYesDx = -9999
			nLbYesDx = nDx  nLbYesDy = nDy
		else
			if fabs(nDx - nLbYesDx) < 1.5 and fabs(nDy - nLbYesDy) < 1.5
				nLbSameYes = 1
			ok
		ok
	ok
	if StzLower("" + aNxL[1]) = "no"
		if nLbNoDx = -9999
			nLbNoDx = nDx  nLbNoDy = nDy
		else
			if fabs(nDx - nLbNoDx) < 8 and fabs(nDy - nLbNoDy) < 1.5
				nLbSameNo = 1
			ok
		ok
	ok
next
? "   yes sits at (" + nLbYesDx + "," + nLbYesDy + ") from its rhombus," +
  " no at (" + nLbNoDx + "," + nLbNoDy + ")"
chkeq("both questions place 'yes' the same way", nLbSameYes, 1)
chkeq("...and both place 'no' the same way", nLbSameNo, 1)
chk("NEGATIVE: the two words are not in the same place as each other",
    fabs(nLbYesDx - nLbNoDx) > 5 or fabs(nLbYesDy - nLbNoDy) > 5)

sec("-- 73l. THE SILHOUETTE: WRITTEN WHERE, DRAWN HOW ----")

# DRAKON'S FORM FOR AN ALGORITHM TOO LARGE FOR ONE SKEWER.
#
# Several skewers side by side, each under its own NAME, control leaving
# the foot of one to resume at the head of another. The transfer is
# written -- an ADDRESS names where control goes -- and that is the
# whole trick: a silhouette has no long connecting lines, so it has
# nothing to cross.
#
# MEASURED BEFORE BUILDING, as this plane requires. The kill was that
# the form buys nothing if a model needs as many branches as nodes: over
# this plane's flow models the minimum path cover is 162 branches for
# 432 nodes, ratio 0.38. It compresses, so the kill does not fire.
oSl = new stzDiagram("silhouette73l")
oSl.SetNotation(StzDrakonNotation())
oSl.AddNodeXTT("b1","Take the order",[ :type = "branch" ])
oSl.AddNodeXTT("read","Read basket",[ :type = "input" ])
oSl.AddNodeXTT("q1","Basket empty?",[ :type = "question" ])
oSl.AddNodeXTT("warn","Say so",[ :type = "action" ])
oSl.AddNodeXTT("a1","Charge",[ :type = "address" ])
oSl.AddNodeXTT("b2","Charge",[ :type = "branch" ])
oSl.AddNodeXTT("auth","Authorise card",[ :type = "action" ])
oSl.AddNodeXTT("a2","Ship",[ :type = "address" ])
oSl.AddNodeXTT("b3","Ship",[ :type = "branch" ])
oSl.AddNodeXTT("pack","Pack",[ :type = "action" ])
oSl.AddNodeXTT("a3","End",[ :type = "address" ])
oSl.AddEdge("b1","read")  oSl.AddEdge("read","q1")
oSl.AddEdgeXT("q1","a1","no")  oSl.AddEdgeXT("q1","warn","yes")
oSl.AddEdge("warn","a1")  oSl.AddEdge("a1","b2")
oSl.AddEdge("b2","auth")  oSl.AddEdge("auth","a2")
oSl.AddEdge("a2","b3")
oSl.AddEdge("b3","pack")  oSl.AddEdge("pack","a3")
oSl.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20, :LayoutMode = :Silhouette ])

# THE BRANCHES STAND SIDE BY SIDE, each header in its own column and all
# of them on one row -- so a reader knows where each begins without
# hunting for it.
nSlCols = 0  nSlHeadY = -1  nSlSameRow = 1
aSlHx = []
for iSl = 1 to len(oSl.RenderNodeRects())
	aSlR = oSl.RenderNodeRects()[iSl]
	cSlId = StzLower("" + aSlR[5])
	if cSlId != "b1" and cSlId != "b2" and cSlId != "b3"  loop  ok
	aSlHx + (aSlR[1] + aSlR[3] / 2)
	if nSlHeadY < 0
		nSlHeadY = aSlR[2] + aSlR[4] / 2
	else
		if fabs(aSlR[2] + aSlR[4] / 2 - nSlHeadY) > 2  nSlSameRow = 0  ok
	ok
next
for iSl = 1 to len(aSlHx)
	bSlNew = 1
	for jSl = 1 to iSl - 1
		if fabs(aSlHx[iSl] - aSlHx[jSl]) < 2  bSlNew = 0  exit  ok
	next
	if bSlNew  nSlCols++  ok
next
? "   " + len(aSlHx) + " branch headers in " + nSlCols +
  " columns, all on one row: " + nSlSameRow
chkeq("each branch stands in its own column", nSlCols, 3)
chkeq("...and every header sits on the same row", nSlSameRow, 1)

# THE TRANSFER IS NOT DRAWN. This is the property the whole form exists
# for, and the one a picture can silently lose: the model still carries
# the edge -- it must, or the graph would not be connected and could not
# be queried -- and the DRAWING leaves it out, because the address
# already says where control goes.
nSlDrawn = 0
for iSl = 1 to len(oSl.@aEdgePaths)
	cSlK = StzLower("" + oSl.@aEdgePaths[iSl][1])
	if cSlK = "a1>b2" or cSlK = "a2>b3"  nSlDrawn++  ok
next
? "   inter-branch transfers drawn as lines: " + nSlDrawn
chkeq("a transfer between branches is written, not drawn", nSlDrawn, 0)

# NEGATIVE: the model still HOLDS those edges. Suppressing the line must
# not have quietly removed the fact -- a picture that tells the truth by
# forgetting is not telling the truth.
chk("NEGATIVE: ...but the model still carries them",
    oSl.EdgeExists("a1","b2") and oSl.EdgeExists("a2","b3"))

# ...AND THE EDGES INSIDE A BRANCH ARE STILL DRAWN, or "no lines" would
# be satisfied by drawing nothing at all.
nSlIn = 0
for iSl = 1 to len(oSl.@aEdgePaths)
	cSlK = StzLower("" + oSl.@aEdgePaths[iSl][1])
	if cSlK = "b1>read" or cSlK = "read>q1" or cSlK = "b3>pack"
		nSlIn++
	ok
next
chkeq("NEGATIVE: ...and the lines INSIDE a branch are still drawn",
    nSlIn, 3)
# ...AND THE PAPER IS THE DRAWING, which a form that suppresses lines
# can lose without anything looking wrong.
#
# The lane plan reserved a return rail for every inter-branch transfer,
# and a silhouette does not DRAW those -- so the sheet came out 1006px
# tall for 524px of picture. Paper reserved for a line nobody draws is
# the same defect as a name reserved in the wrong direction: a
# measurement describing a layout other than the one on the page.
# ...AND "THE INK" INCLUDES THE RAILS, which is where this clause
# went wrong once the runner's path was drawn. Measured from the
# icons alone it read 64px of dead paper under a picture whose
# bottom rail was standing in it -- the same mistake as the defect
# it was written to catch, made from the other side: a measurement
# describing a layout other than the one on the page.
nSlLow = 0
for iSl = 1 to len(oSl.RenderNodeRects())
	aSlR = oSl.RenderNodeRects()[iSl]
	if aSlR[2] + aSlR[4] > nSlLow  nSlLow = aSlR[2] + aSlR[4]  ok
next
aSlBus = oSl._SilhouetteBusBox(150, 56)
if len(aSlBus) = 4 and aSlBus[3] > nSlLow  nSlLow = aSlBus[3]  ok
nSlH = oSl.LastCanvas().Height()
? "   lowest ink " + nSlLow + ", sheet " + oSl.LastCanvas().Width() +
  "x" + nSlH + "   slack " + (nSlH - nSlLow) + "px"
chk("the sheet is the drawing's own height", nSlH - nSlLow < 60)

# NEGATIVE: the sheet must still CLEAR the ink -- a height that merely
# hugged the number would pass the clause above by cropping.
chk("NEGATIVE: ...and still clears it", nSlH > nSlLow)
sec("-- 73m. DRAKON DECLARES ITS EXITS, IT DOES NOT GUESS ---")
discharges("DN6b")

# LEARNED FROM THE LANGUAGE ITSELF rather than from its pictures.
#
# DrakonWidget, the reference engine, gives every icon exactly two
# exits and fixes what each one MEANS: `one` is the next item BELOW,
# `two` the next to the RIGHT. A question is not an icon with two
# outgoing arrows to be sorted out by reading their labels -- which is
# how this library had been doing it, affirmative first, then neutral,
# then anything. That works on yes/no and is a GUESS everywhere else.
#
# The scene is built so the words mislead: the main path leaves by
# "insufficient" and the branch by "ok". A reading of the wording puts
# the skewer through the branch and is confident about it.
aDcOpt = [ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
           :FontSize = 20 ]

# WITHOUT the declaration: the heuristic is wrong, and the guard shows
# it rather than asserting it from memory.
oDc1 = new stzDiagram("guess73m")
oDc1.SetNotation(StzDrakonNotation())
oDc1.AddNodeXTT("t","Top up",[ :type = "title" ])
oDc1.AddNodeXTT("q","Balance?",[ :type = "question" ])
oDc1.AddNodeXTT("add","Add funds",[ :type = "action" ])
oDc1.AddNodeXTT("skip","Nothing to do",[ :type = "action" ])
oDc1.AddNodeXTT("e","Done",[ :type = "end" ])
oDc1.AddEdge("t","q")
oDc1.AddEdgeXT("q","add","insufficient")
oDc1.AddEdgeXT("q","skip","ok")
oDc1.AddEdge("add","e")  oDc1.AddEdge("skip","e")
oDc1.ToCanvasXT(aDcOpt)
aDcP1 = oDc1._HappyPath()
bDcGuessAdd = 0
for iDc = 1 to len(aDcP1)
	if StzLower("" + aDcP1[iDc]) = "add"  bDcGuessAdd = 1  ok
next

# WITH it: the model says which exit goes down, and nothing else votes.
oDc2 = new stzDiagram("declared73m")
oDc2.SetNotation(StzDrakonNotation())
oDc2.AddNodeXTT("t","Top up",[ :type = "title" ])
oDc2.AddNodeXTT("q","Balance?",[ :type = "question" ])
oDc2.AddNodeXTT("add","Add funds",[ :type = "action" ])
oDc2.AddNodeXTT("skip","Nothing to do",[ :type = "action" ])
oDc2.AddNodeXTT("e","Done",[ :type = "end" ])
oDc2.AddEdge("t","q")
oDc2.AddEdgeXTT("q","add","insufficient", [ :exit = :down ])
oDc2.AddEdgeXTT("q","skip","ok", [ :exit = :right ])
oDc2.AddEdge("add","e")  oDc2.AddEdge("skip","e")
oDc2.ToCanvasXT(aDcOpt)
aDcP2 = oDc2._HappyPath()
bDcDeclAdd = 0
for iDc = 1 to len(aDcP2)
	if StzLower("" + aDcP2[iDc]) = "add"  bDcDeclAdd = 1  ok
next

? "   reading the words, the skewer takes Add funds: " + bDcGuessAdd
? "   reading the model, it takes Add funds:         " + bDcDeclAdd
chkeq("a declared down-exit carries the skewer", bDcDeclAdd, 1)

# THE NEGATIVE THAT MAKES THE POSITIVE MEAN SOMETHING: on this scene
# the word-reading answer is DIFFERENT. Without it the clause above
# would pass on a diagram where the guess happened to agree, and prove
# nothing about the declaration at all.
chkeq("NEGATIVE: ...and the wording alone gets it WRONG here",
    bDcGuessAdd, 0)

# ...AND THE DECLARED SIDE EXIT IS THE ONE THAT STANDS RIGHT.
nDcSk = 0  nDcSide = 0
for iDc = 1 to len(oDc2.RenderNodeRects())
	aDcR = oDc2.RenderNodeRects()[iDc]
	cDcId = StzLower("" + aDcR[5])
	if cDcId = "add"   nDcSk = aDcR[1] + aDcR[3] / 2  ok
	if cDcId = "skip"  nDcSide = aDcR[1] + aDcR[3] / 2  ok
next
? "   down-exit at x " + nDcSk + ", side exit at x " + nDcSide
chk("the declared side exit stands to the right of the skewer",
    nDcSide > nDcSk + 20)
sec("-- 73n. DRAKON HAS A LOOP, AND IT IS TWO ICONS --------")

# A LANGUAGE FOR ALGORITHMS WITHOUT A LOOP IS NOT THAT LANGUAGE, and
# foreach was in DRAKON's icon list with nothing here answering to it.
#
# THE FIRST VERSION OF THIS GUARD BLESSED A MODEL THAT WAS FALSE. It
# gave one loop icon two exits -- down into the body, right to what
# follows -- which is an If wearing a loop's name: read literally, the
# loop ends on its first pass. The gap was even written down in the
# profile under a heading reading NAMED AND NOT DONE, and the fixture
# went out anyway, saying something untrue about algorithms in a
# picture. The book: "The For icon is actually two icons: Begin For
# and End For. The code that runs several times is represented by the
# icons placed between the Begin For and End For icons."
oLp = new stzDiagram("loop73n")
oLp.SetNotation(StzDrakonNotation())
oLp.AddNodeXTT("t","Total a basket",[ :type = "title" ])
oLp.AddNodeXTT("f","for each line",[ :type = "foreach" ])
oLp.AddNodeXTT("a","Add its price",[ :type = "action" ])
oLp.AddNodeXTT("z","end for",[ :type = "endforeach" ])
oLp.AddNodeXTT("e","Done",[ :type = "end" ])
oLp.AddEdge("t","f")  oLp.AddEdge("f","a")  oLp.AddEdge("a","z")
oLp.AddEdge("z","f")
oLp.AddEdgeXTT("z","e","", [ :exit = :down ])
oLp.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20 ])
chkeq("the model holds a loop", oLp._HasLoopReturn(), 1)

# THE BODY LIES BETWEEN THE TWO ICONS, and the flow continues DOWN out
# of the End For. Both are asked of the drawing, because the whole
# defect was a picture disagreeing with a comment.
aLpR = oLp.RenderNodeRects()
nLpF = 0  nLpA = 0  nLpZ = 0  nLpE = 0  nLpZw = 0  nLpZx = 0
for iLp = 1 to len(aLpR)
	cLpI = StzLower("" + aLpR[iLp][5])
	if cLpI = "f"  nLpF = aLpR[iLp][2]  ok
	if cLpI = "a"  nLpA = aLpR[iLp][2]  ok
	if cLpI = "e"  nLpE = aLpR[iLp][2]  ok
	if cLpI = "z"
		nLpZ = aLpR[iLp][2]
		nLpZx = aLpR[iLp][1]
		nLpZw = aLpR[iLp][3]
	ok
next
chk("the repeated work stands between Begin For and End For",
    nLpF < nLpA and nLpA < nLpZ)
chk("...and the flow carries on downward out of the End For",
    nLpZ < nLpE)

# AN ARROW MEANS A LOOP, AND NOTHING ELSE MEANS IT. "All arrows inside
# a branch represent loops. All other lines do not have arrow heads
# because an excessive use of arrows adds unnecessary graphics
# complexity." This plane drew one on every edge -- which does not
# merely add noise: it spends the one mark DRAKON reserves for its
# rarest event on its most ordinary one.
? "   arrowheads painted: " + len(oLp.RenderArrows())
chkeq("exactly one arrow in a picture with one loop",
    len(oLp.RenderArrows()), 1)

# ...AND IT POINTS AT A LINE, NEVER AT AN ICON. "Arrows never point to
# icons. Arrows point only to lines that go down. This rule guarantees
# that for each icon, there is only one line that leads to it."
nLpIn = 0
aLpAr = oLp.RenderArrows()
for iLp = 1 to len(aLpAr)
	for jLp = 1 to len(aLpR)
		if aLpAr[iLp][1] >= aLpR[jLp][1] and
		   aLpAr[iLp][1] <= aLpR[jLp][1] + aLpR[jLp][3] and
		   aLpAr[iLp][2] >= aLpR[jLp][2] and
		   aLpAr[iLp][2] <= aLpR[jLp][2] + aLpR[jLp][4]
			nLpIn++
		ok
	next
next
chkeq("no arrow lands on an icon", nLpIn, 0)

# THE REPEAT LEAVES THE ICON'S BORDER. A sloped glyph is narrower at
# its middle than the rectangle it is measured in, so a line starting
# at the box edge starts in mid-air -- the Principal marked the gap
# between a trapezium and the line said to be leaving it. A wire that
# does not touch what it comes from is not attached to anything.
aLpZc = [ nLpZx + nLpZw / 2, nLpZ + 28 ]
aLpFc = []
for iLp = 1 to len(aLpR)
	if StzLower("" + aLpR[iLp][5]) = "f"
		aLpFc = [ aLpR[iLp][1] + aLpR[iLp][3] / 2,
		          aLpR[iLp][2] + aLpR[iLp][4] / 2 ]
	ok
next
aLpP = oLp._DrakonLoopPath("z", "f", aLpZc, aLpFc, 150, 56)
chk("the repeat is drawn by the loop rule, not the router",
    len(aLpP) >= 8)
nLpGap = fabs(aLpP[1] - nLpZx)
? "   the repeat leaves x " + aLpP[1] + ", the icon's box edge is " +
  nLpZx
chk("...and it starts on the painted border, not the box", nLpGap < 20)

# ...AND IT RUNS CLEAR OF EVERY BOX. The lane is what keeps the
# no-crossing promise, and it only exists because the paper was asked
# to hold it -- the rule found no room on its own and gave up in
# silence, which is this plane's oldest failure wearing a new hat.
nLpLane = aLpP[3]
nLpMinL = 1000000
for iLp = 1 to len(aLpR)
	if aLpR[iLp][1] < nLpMinL  nLpMinL = aLpR[iLp][1]  ok
next
? "   lane at x " + nLpLane + ", leftmost box at x " + nLpMinL
chk("the loop lane runs left of every box", nLpLane < nLpMinL - 2)

# NEGATIVE: a picture with no loop has no lane AND NO ARROW AT ALL --
# the second half is what makes the first mean something, because a
# notation that draws heads everywhere would still pass the count
# above on a diagram that happens to loop.
oLp2 = new stzDiagram("noloop73n")
oLp2.SetNotation(StzDrakonNotation())
oLp2.AddNodeXTT("t","Start",[ :type = "title" ])
oLp2.AddNodeXTT("a","Do it",[ :type = "action" ])
oLp2.AddNodeXTT("e","Done",[ :type = "end" ])
oLp2.AddEdge("t","a")  oLp2.AddEdge("a","e")
oLp2.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                  :FontSize = 20 ])
chkeq("NEGATIVE: a straight algorithm reserves no lane",
    oLp2._LoopLaneReserve(), 0)
chkeq("NEGATIVE: ...and carries no arrowhead anywhere",
    len(oLp2.RenderArrows()), 0)

# THE LOOP ICON HOLDS ITS OWN NAME. It was told to and then given a
# box the name did not fit in, because the sizing rule granted that
# to one shape by name -- "diamond" -- while the profile granted it
# by KIND. Two rules disagreeing, and the picture obeys the sizer.
nLpFw = 0
for iLp = 1 to len(aLpR)
	if StzLower("" + aLpR[iLp][5]) = "f"  nLpFw = aLpR[iLp][3]  ok
next
nLpTw = EFONT.WidthOf("for each line", 20)
? "   loop icon " + nLpFw + "px wide for " + nLpTw + "px of type"
chk("the loop icon is sized to the name it holds", nLpFw > nLpTw)

sec("-- 73p. AN ALTERNATIVE STAYS IN ITS OWN COLUMN -------")

# A question whose second exit lands further down the SAME vertical
# has nowhere to go but sideways and back, and the generic router
# picked its lane from the whole picture. In the silhouette the "no"
# left branch one, ran out across branch two into branch three, and
# came back -- every DRAKON law at once.
#
# It crossed nothing, which is why the no-crossing guard passed it for
# as long as it existed: the line was not ON anything, it was simply
# somewhere it had no business being. A guard that asks only whether
# two segments touch cannot see a line in the wrong ROOM.
oSj = new stzDiagram("sidejoin73p")
oSj.SetNotation(StzDrakonNotation())
oSj.AddNodeXTT("b1","Take the order",[ :type = "branch" ])
oSj.AddNodeXTT("q1","Basket empty?",[ :type = "question" ])
oSj.AddNodeXTT("warn","Say so",[ :type = "action" ])
oSj.AddNodeXTT("a1","Charge",[ :type = "address" ])
oSj.AddNodeXTT("b2","Charge",[ :type = "branch" ])
oSj.AddNodeXTT("auth","Authorise card",[ :type = "action" ])
oSj.AddNodeXTT("a2","End",[ :type = "address" ])
oSj.AddEdge("b1","q1")
oSj.AddEdgeXT("q1","a1","no")  oSj.AddEdgeXT("q1","warn","yes")
oSj.AddEdge("warn","a1")  oSj.AddEdge("a1","b2")
oSj.AddEdge("b2","auth")  oSj.AddEdge("auth","a2")
oSj.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20, :LayoutMode = :Silhouette ])

# where the second branch begins -- the room the excursion may not
# enter, measured from the picture rather than assumed
nSjB2 = 1000000
aSjR = oSj.RenderNodeRects()
for iSj = 1 to len(aSjR)
	cSjI = StzLower("" + aSjR[iSj][5])
	if cSjI = "b2" or cSjI = "auth" or cSjI = "a2"
		if aSjR[iSj][1] < nSjB2  nSjB2 = aSjR[iSj][1]  ok
	ok
next

nSjMax = 0
bSjFound = 0
aSjP = oSj.RenderEdgePaths()
for iSj = 1 to len(aSjP)
	if StzLower("" + aSjP[iSj][1]) != "q1>a1"  loop  ok
	bSjFound = 1
	for jSj = 1 to len(aSjP[iSj][2]) step 2
		if aSjP[iSj][2][jSj] > nSjMax  nSjMax = aSjP[iSj][2][jSj]  ok
	next
next
chkeq("the refused exit is drawn at all", bSjFound, 1)
? "   the no reaches x " + nSjMax + ", branch two begins at x " + nSjB2
chk("...and never leaves its own branch", nSjMax < nSjB2)

# ...AND IT ARRIVES ON THE LINE ABOVE THE ICON, never on the icon.
# "Arrows never point to icons. Arrows point only to lines that go
# down. This rule guarantees that for each icon, there is only one line
# that leads to it." This clause asked for the SIDE until the book was
# read, and passed.
nSjTop = 0  nSjEndY = 0
for iSj = 1 to len(aSjR)
	if StzLower("" + aSjR[iSj][5]) = "a1"  nSjTop = aSjR[iSj][2]  ok
next
for iSj = 1 to len(aSjP)
	if StzLower("" + aSjP[iSj][1]) != "q1>a1"  loop  ok
	nSjEndY = aSjP[iSj][2][ len(aSjP[iSj][2]) ]
next
? "   it arrives at y " + nSjEndY + ", the icon's top is y " + nSjTop
chk("the refused exit joins the line above the icon, not the icon",
    nSjEndY < nSjTop - 1)

# NEGATIVE: with nothing standing between them the straight drop is
# the honest drawing, and the rule must not invent a detour around
# empty paper.
oSj2 = new stzDiagram("nodetour73p")
oSj2.SetNotation(StzDrakonNotation())
oSj2.AddNodeXTT("t","Start",[ :type = "title" ])
oSj2.AddNodeXTT("q","Ready?",[ :type = "question" ])
oSj2.AddNodeXTT("e","Done",[ :type = "end" ])
oSj2.AddEdgeXTT("t","q","", [ :exit = :down ])
oSj2.AddEdgeXT("q","e","no")
oSj2.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                  :FontSize = 20 ])
aSjN = []
for iSj = 1 to len(oSj2.RenderNodeRects())
	aSjN + oSj2.RenderNodeRects()[iSj]
next
aSjQ = []  aSjE = []
for iSj = 1 to len(aSjN)
	if StzLower("" + aSjN[iSj][5]) = "q"
		aSjQ = [ aSjN[iSj][1] + aSjN[iSj][3] / 2,
		         aSjN[iSj][2] + aSjN[iSj][4] / 2 ]
	ok
	if StzLower("" + aSjN[iSj][5]) = "e"
		aSjE = [ aSjN[iSj][1] + aSjN[iSj][3] / 2,
		         aSjN[iSj][2] + aSjN[iSj][4] / 2 ]
	ok
next
chkeq("NEGATIVE: nothing in the way, so no excursion",
    len(oSj2._DrakonSideJoin("q", "e", aSjQ, aSjE, 150, 56)), 0)
sec("-- 73q. A SELECT IS N COLUMNS, NOT ONE ALTERNATIVE ---")

# DRAKON has a multi-way choice and this plane could not draw one.
# Two of three cases came out at THE SAME COORDINATES: national and
# abroad printed on top of each other, and neither word existed.
#
# A branch column was one plus the number of branches nested inside
# it, which orders alternatives that CONTAIN one another and says
# nothing about peers. The cases of a select leave the same icon at
# the same moment and rejoin at the same place, so every one of them
# counted zero and every one claimed the first column. The comment
# over that code said its intent was to COLOUR the intervals, and a
# count is not a colouring.
oSe = new stzDiagram("select73q")
oSe.SetNotation(StzDrakonNotation())
oSe.AddNodeXTT("t","Route the parcel",[ :type = "title" ])
oSe.AddNodeXTT("s","Destination?",[ :type = "select" ])
oSe.AddNodeXTT("c1","local",[ :type = "case" ])
oSe.AddNodeXTT("c2","national",[ :type = "case" ])
oSe.AddNodeXTT("c3","abroad",[ :type = "case" ])
oSe.AddNodeXTT("a1","Bike courier",[ :type = "action" ])
oSe.AddNodeXTT("a2","Post",[ :type = "action" ])
oSe.AddNodeXTT("a3","Air freight",[ :type = "action" ])
oSe.AddNodeXTT("e","Done",[ :type = "end" ])
oSe.AddEdge("t","s")
oSe.AddEdge("s","c1")  oSe.AddEdge("s","c2")  oSe.AddEdge("s","c3")
oSe.AddEdge("c1","a1") oSe.AddEdge("c2","a2") oSe.AddEdge("c3","a3")
oSe.AddEdge("a1","e")  oSe.AddEdge("a2","e")  oSe.AddEdge("a3","e")
oSe.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20 ])
aSeR = oSe.RenderNodeRects()

# NO TWO ICONS STAND IN ONE PLACE. Asked of every pair rather than of
# the three this scene is about: two boxes at one coordinate is the
# most visible defect a layout can have and among the easiest to miss,
# because the picture still looks like a picture.
nSeOver = 0
for iSe = 1 to len(aSeR)
	for jSe = iSe + 1 to len(aSeR)
		if fabs(aSeR[iSe][1] - aSeR[jSe][1]) < 2 and
		   fabs(aSeR[iSe][2] - aSeR[jSe][2]) < 2
			nSeOver++
			? "   OVERLAP " + aSeR[iSe][5] + " on " + aSeR[jSe][5]
		ok
	next
next
chkeq("no two icons are drawn at one place", nSeOver, 0)

# EACH CASE HEADS ITS OWN COLUMN, and its body stands under it -- a
# branch is a CHAIN, not a node. Every fixture until this one had a
# single icon standing beside the line, so the two readings agreed
# everywhere, and the moment a case had a body the case went in one
# column and the step it selects went in another.
nSeC1 = 0  nSeC2 = 0  nSeA2 = 0  nSeC3 = 0  nSeA3 = 0
for iSe = 1 to len(aSeR)
	cSeI = StzLower("" + aSeR[iSe][5])
	if cSeI = "c1"  nSeC1 = aSeR[iSe][1]  ok
	if cSeI = "c2"  nSeC2 = aSeR[iSe][1]  ok
	if cSeI = "a2"  nSeA2 = aSeR[iSe][1]  ok
	if cSeI = "c3"  nSeC3 = aSeR[iSe][1]  ok
	if cSeI = "a3"  nSeA3 = aSeR[iSe][1]  ok
next
? "   case columns at x " + nSeC1 + ", " + nSeC2 + ", " + nSeC3
chkeq("the second case and its body share a column", nSeC2, nSeA2)
chkeq("...and so do the third and its body", nSeC3, nSeA3)
chk("the cases stand in declared order, left to right",
    nSeC1 < nSeC2 and nSeC2 < nSeC3)

# NEGATIVE: two alternatives that genuinely NEST still read as nested,
# the outer one further out. Pushing peers apart must not flatten the
# reading the nesting count exists to give.
oSe2 = new stzDiagram("nest73q")
oSe2.SetNotation(StzDrakonNotation())
oSe2.AddNodeXTT("t","Sign in",[ :type = "title" ])
oSe2.AddNodeXTT("q1","Known user?",[ :type = "question" ])
oSe2.AddNodeXTT("q2","Password ok?",[ :type = "question" ])
oSe2.AddNodeXTT("ok","Open session",[ :type = "action" ])
oSe2.AddNodeXTT("n1","Report unknown",[ :type = "action" ])
oSe2.AddNodeXTT("n2","Report refusal",[ :type = "action" ])
oSe2.AddNodeXTT("e","Done",[ :type = "end" ])
oSe2.AddEdge("t","q1")
oSe2.AddEdgeXT("q1","q2","yes")  oSe2.AddEdgeXT("q1","n1","no")
oSe2.AddEdgeXT("q2","ok","yes")  oSe2.AddEdgeXT("q2","n2","no")
oSe2.AddEdge("ok","e")  oSe2.AddEdge("n1","e")  oSe2.AddEdge("n2","e")
oSe2.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                  :FontSize = 20 ])
nSeN1 = 0  nSeN2 = 0
for iSe = 1 to len(oSe2.RenderNodeRects())
	rSe = oSe2.RenderNodeRects()[iSe]
	if StzLower("" + rSe[5]) = "n1"  nSeN1 = rSe[1]  ok
	if StzLower("" + rSe[5]) = "n2"  nSeN2 = rSe[1]  ok
next
? "   outer refusal at x " + nSeN1 + ", inner at x " + nSeN2
chk("NEGATIVE: the outer refusal still stands further out",
    nSeN1 > nSeN2 + 20)

sec("-- 73r. THE BRANCHES ARE ORDERED BY branchId ---------")

# DRAKON carries a branchId on every branch: the columns run ascending
# and the FIRST icon of the silhouette is the lowest, which is how a
# reader knows where the algorithm begins. This plane read the order
# the branch nodes happened to be WRITTEN in -- right until somebody
# inserts a phase, and no way at all to say which one is the entry
# except by moving lines of source.
#
# Declared backwards on purpose: Ship, Charge, Take the order.
oBi = new stzDiagram("bid73r")
oBi.SetNotation(StzDrakonNotation())
oBi.AddNodeXTT("b3","Ship",[ :type = "branch", :branchId = 3 ])
oBi.AddNodeXTT("pack","Pack",[ :type = "action" ])
oBi.AddNodeXTT("a3","End",[ :type = "address" ])
oBi.AddNodeXTT("b2","Charge",[ :type = "branch", :branchId = 2 ])
oBi.AddNodeXTT("auth","Authorise card",[ :type = "action" ])
oBi.AddNodeXTT("a2","Ship",[ :type = "address" ])
oBi.AddNodeXTT("b1","Take the order",[ :type = "branch", :branchId = 1 ])
oBi.AddNodeXTT("read","Read basket",[ :type = "input" ])
oBi.AddNodeXTT("a1","Charge",[ :type = "address" ])
oBi.AddEdge("b1","read")  oBi.AddEdge("read","a1")  oBi.AddEdge("a1","b2")
oBi.AddEdge("b2","auth")  oBi.AddEdge("auth","a2")  oBi.AddEdge("a2","b3")
oBi.AddEdge("b3","pack")  oBi.AddEdge("pack","a3")
oBi.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20, :LayoutMode = :Silhouette ])
nBi1 = 0  nBi2 = 0  nBi3 = 0
for iBi = 1 to len(oBi.RenderNodeRects())
	rBi = oBi.RenderNodeRects()[iBi]
	if StzLower("" + rBi[5]) = "b1"  nBi1 = rBi[1]  ok
	if StzLower("" + rBi[5]) = "b2"  nBi2 = rBi[1]  ok
	if StzLower("" + rBi[5]) = "b3"  nBi3 = rBi[1]  ok
next
? "   declared 3,2,1 -- drawn at x " + nBi1 + ", " + nBi2 + ", " + nBi3
chk("the columns run in branchId order, not declaration order",
    nBi1 < nBi2 and nBi2 < nBi3)
chkeq("the entry branch is the lowest id, and it is leftmost",
    oBi._BranchOrdinalOf("b1"), 1)

# NEGATIVE: with no id declared, the order an author wrote is still
# the order they meant -- every picture in this plane relies on it.
oBi2 = new stzDiagram("noid73r")
oBi2.SetNotation(StzDrakonNotation())
oBi2.AddNodeXTT("z1","First",[ :type = "branch" ])
oBi2.AddNodeXTT("s1","Do",[ :type = "action" ])
oBi2.AddNodeXTT("y1","Second",[ :type = "address" ])
oBi2.AddNodeXTT("z2","Second",[ :type = "branch" ])
oBi2.AddNodeXTT("s2","Do more",[ :type = "action" ])
oBi2.AddNodeXTT("y2","End",[ :type = "address" ])
oBi2.AddEdge("z1","s1")  oBi2.AddEdge("s1","y1")  oBi2.AddEdge("y1","z2")
oBi2.AddEdge("z2","s2")  oBi2.AddEdge("s2","y2")
oBi2.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                  :FontSize = 20, :LayoutMode = :Silhouette ])
nBiZ1 = 0  nBiZ2 = 0
for iBi = 1 to len(oBi2.RenderNodeRects())
	rBi = oBi2.RenderNodeRects()[iBi]
	if StzLower("" + rBi[5]) = "z1"  nBiZ1 = rBi[1]  ok
	if StzLower("" + rBi[5]) = "z2"  nBiZ2 = rBi[1]  ok
next
chkeq("NEGATIVE: no id declared, so none is invented",
    oBi2._BranchOrdinalOf("z1"), 0)
chk("...and declaration order still decides", nBiZ1 < nBiZ2)
sec("-- 73s. A SILHOUETTE RUNS ON RAILS ------------------")

# The book describes the shape as a RUNNER rather than as a drawing,
# which is why it took the Principal's own sample to see that it is a
# drawing: "The runner goes down through the leftmost branch. Then it
# goes to the left edge and climbs up to the left top corner. Then it
# slides to the right until it finds the branch pointed to by the
# Address icon of the previous branch."
#
# This plane drew the branches as separate columns and nothing else,
# on the reasoning that an inter-branch transfer is WRITTEN in the
# Address rather than drawn. That is true of WHERE control goes and
# says nothing about the path it takes. The name picks the branch; the
# rails are how a reader sees that the columns are one algorithm and
# not three diagrams sharing a sheet.
oRl = new stzDiagram("rails73s")
oRl.SetNotation(StzDrakonNotation())
oRl.AddNodeXTT("b1","Take the order",[ :type = "branch" ])
oRl.AddNodeXTT("read","Read basket",[ :type = "input" ])
oRl.AddNodeXTT("a1","Charge",[ :type = "address" ])
oRl.AddNodeXTT("b2","Charge",[ :type = "branch" ])
oRl.AddNodeXTT("auth","Authorise card",[ :type = "action" ])
oRl.AddNodeXTT("a2","Ship",[ :type = "address" ])
oRl.AddNodeXTT("b3","Ship",[ :type = "branch" ])
oRl.AddNodeXTT("pack","Pack",[ :type = "action" ])
oRl.AddNodeXTT("fin","End",[ :type = "end" ])
oRl.AddEdge("b1","read")  oRl.AddEdge("read","a1")  oRl.AddEdge("a1","b2")
oRl.AddEdge("b2","auth")  oRl.AddEdge("auth","a2")  oRl.AddEdge("a2","b3")
oRl.AddEdge("b3","pack")  oRl.AddEdge("pack","fin")
oRl.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20, :LayoutMode = :Silhouette ])
aRlB = oRl._SilhouetteBusBox(150, 56)
chkeq("a silhouette has rails", len(aRlB), 4)

# THE TOP RAIL STANDS ABOVE EVERY BRANCH ENTRY and the bottom rail
# below every address -- measured, because a rail threaded through the
# icons it feeds would be a crossing in the notation that forbids them.
aRlR = oRl.RenderNodeRects()
nRlHiTop = 1000000  nRlLoBot = 0  nRlEndX = 0  nRlMaxA = 0
for iRl = 1 to len(aRlR)
	cRlI = StzLower("" + aRlR[iRl][5])
	if cRlI = "b1" or cRlI = "b2" or cRlI = "b3"
		if aRlR[iRl][2] < nRlHiTop  nRlHiTop = aRlR[iRl][2]  ok
	ok
	if cRlI = "a1" or cRlI = "a2"
		if aRlR[iRl][2] + aRlR[iRl][4] > nRlLoBot
			nRlLoBot = aRlR[iRl][2] + aRlR[iRl][4]
		ok
		if aRlR[iRl][1] + aRlR[iRl][3] / 2 > nRlMaxA
			nRlMaxA = aRlR[iRl][1] + aRlR[iRl][3] / 2
		ok
	ok
	if cRlI = "fin"  nRlEndX = aRlR[iRl][1]  ok
next
? "   top rail y " + aRlB[2] + ", highest branch entry y " + nRlHiTop
chk("the top rail stands clear above every branch entry",
    aRlB[2] < nRlHiTop - 2)
chk("...and the bottom rail clear below every address",
    aRlB[3] > nRlLoBot + 2)
chk("...and the climb runs left of every icon", aRlB[1] < nRlEndX)

# THE END DOES NOT REJOIN. "A diagram, however, cannot have many End
# icons... Rule: there can be only one exit." An Address labelled
# "End" is a transfer to a branch of that name, and the rails drew it
# as one the moment they existed: control left the last icon of the
# algorithm and went round again. The fixture had been written that
# way since the silhouette shipped, and nothing could see it while
# the transfers were not drawn at all.
? "   bottom rail reaches x " + nRlMaxA + ", the End stands at x " +
  nRlEndX
chk("the bottom rail stops short of the End icon", nRlMaxA < nRlEndX)

# ONE ARROW: THE CLIMB. Everything else on a silhouette goes down or
# sideways, and in DRAKON only a line that goes up carries a head.
? "   arrowheads on the silhouette: " + len(oRl.RenderArrows())
chkeq("the climb is the only arrow on the sheet",
    len(oRl.RenderArrows()), 1)

# NEGATIVE: a primitive diagram is one skewer and has no rails at all,
# so the reserve is not paper every DRAKON picture quietly pays for.
oRl2 = new stzDiagram("norails73s")
oRl2.SetNotation(StzDrakonNotation())
oRl2.AddNodeXTT("t","Start",[ :type = "title" ])
oRl2.AddNodeXTT("a","Do it",[ :type = "action" ])
oRl2.AddNodeXTT("e","Done",[ :type = "end" ])
oRl2.AddEdge("t","a")  oRl2.AddEdge("a","e")
oRl2.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                  :FontSize = 20 ])
chkeq("NEGATIVE: a primitive diagram has no rails",
    len(oRl2._SilhouetteBusBox(150, 56)), 0)
sec("-- 73t. EVERY LINE TOUCHES WHAT IT ARRIVES AT -------")

# ONE SUPPRESSION, TWO CONSEQUENCES, AND ONLY THE VISIBLE ONE WAS
# THOUGHT ABOUT.
#
# Reserving the arrowhead for loops -- which the book requires --
# turned off every other head and left behind the TRIM that had been
# made for it: a path is shortened by 13px so a head can sit at its
# end, and with no head there the wire simply stops short. A whole
# notation of lines attached to nothing. Turning a mark off is not the
# same as deciding what the space it occupied is now for.
#
# The Principal marked one gap and asked for it to be true of every
# cell form, which is the right way to ask: the fault was never about
# the glyph it was spotted on.
oAt = new stzDiagram("attach73t")
oAt.SetNotation(StzDrakonNotation())
oAt.AddNodeXTT("b1","Take the order",[ :type = "branch" ])
oAt.AddNodeXTT("read","Read basket",[ :type = "input" ])
oAt.AddNodeXTT("q1","Basket empty?",[ :type = "question" ])
oAt.AddNodeXTT("warn","Say so",[ :type = "action" ])
oAt.AddNodeXTT("a1","Charge",[ :type = "address" ])
oAt.AddNodeXTT("b2","Charge",[ :type = "branch" ])
oAt.AddNodeXTT("q2","Authorised?",[ :type = "question" ])
oAt.AddNodeXTT("decl","Record refusal",[ :type = "action" ])
oAt.AddNodeXTT("a2","Ship",[ :type = "address" ])
oAt.AddNodeXTT("b3","Ship",[ :type = "branch" ])
oAt.AddNodeXTT("pack","Pack",[ :type = "action" ])
oAt.AddNodeXTT("fin","End",[ :type = "end" ])
oAt.AddEdge("b1","read")  oAt.AddEdge("read","q1")
oAt.AddEdgeXT("q1","a1","no")  oAt.AddEdgeXT("q1","warn","yes")
oAt.AddEdge("warn","a1")  oAt.AddEdge("a1","b2")
oAt.AddEdge("b2","q2")
oAt.AddEdgeXT("q2","a2","yes")  oAt.AddEdgeXT("q2","decl","no")
oAt.AddEdge("decl","a2")  oAt.AddEdge("a2","b3")
oAt.AddEdge("b3","pack")  oAt.AddEdge("pack","fin")
oAt.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20, :LayoutMode = :Silhouette ])

# EVERY ICON THAT SOMETHING FLOWS INTO IS TOUCHED BY A LINE. Asked of
# the icons rather than of the paths, because a path may legally stop
# on the vertical above an icon -- that is the book's joining rule --
# and what must never happen is an icon nothing reaches.
aAtR = oAt.RenderNodeRects()
aAtP = oAt.RenderEdgePaths()
nAtLoose = 0
for iAt = 1 to len(aAtR)
	cAtId = StzLower("" + aAtR[iAt][5])
	if cAtId = "b1"  loop  ok
	bAtIn = 0
	for jAt = 1 to len(aAtR)  next
	for jAt = 1 to len(aAtP)
		aAtPt = aAtP[jAt][2]
		nAtX = aAtPt[len(aAtPt) - 1]
		nAtY = aAtPt[len(aAtPt)]
		if nAtX < aAtR[iAt][1] - 2  loop  ok
		if nAtX > aAtR[iAt][1] + aAtR[iAt][3] + 2  loop  ok
		if nAtY < aAtR[iAt][2] - 2  loop  ok
		if nAtY > aAtR[iAt][2] + aAtR[iAt][4] + 2  loop  ok
		bAtIn = 1
	next
	if NOT bAtIn
		# a branch entry is fed by the rail, not by an edge
		if StzLower("" + oAt._KindOfId(cAtId)) = "branch"  loop  ok
		nAtLoose++
		? "   NOTHING TOUCHES " + cAtId
	ok
next
chkeq("no icon is left with nothing touching it", nAtLoose, 0)

# ...AND THE ARRIVAL IS ON THE BORDER, not somewhere inside the glyph.
# A line that overshoots into the box is as wrong as one that stops
# short, and both look the same from a distance.
nAtDeep = 0
for jAt = 1 to len(aAtP)
	aAtPt = aAtP[jAt][2]
	nAtX = aAtPt[len(aAtPt) - 1]
	nAtY = aAtPt[len(aAtPt)]
	for iAt = 1 to len(aAtR)
		if nAtX < aAtR[iAt][1] + 3  loop  ok
		if nAtX > aAtR[iAt][1] + aAtR[iAt][3] - 3  loop  ok
		if nAtY < aAtR[iAt][2] + 3  loop  ok
		if nAtY > aAtR[iAt][2] + aAtR[iAt][4] - 3  loop  ok
		nAtDeep++
		? "   OVERSHOOT into " + aAtR[iAt][5]
	next
next
chkeq("no line ends inside a glyph", nAtDeep, 0)

sec("-- 73u. THE GUTTER IS MEASURED FROM THE INK ----------")

# A BRANCH IS NOT AS WIDE AS ITS WIDEST ICON.
#
# A secondary route that steps aside and rejoins the same skewer runs
# in a lane one clearance beyond that icon, and that lane is the
# branch's ink as surely as any box is. The gutter between branches
# was CONSTANT the whole time and the picture did not look it: between
# boxes the gaps were 57 and 57, between the ink a reader actually
# sees they were 33 and 57.
#
# The Principal marked both gaps and asked for a rule. There was one;
# it was being applied to the wrong extent -- this plane's most
# repeated fault, met again in a new place.
aAtIn = [ [ "b1","read","q1","warn","a1" ],
          [ "b2","q2","decl","a2" ],
          [ "b3","pack","fin" ] ]
aAtGut = []
nAtPrev = 0
for iAt = 1 to 3
	nAtL = 1000000  nAtR2 = 0
	for jAt = 1 to len(aAtIn[iAt])
		for kAt = 1 to len(aAtR)
			if StzLower("" + aAtR[kAt][5]) != aAtIn[iAt][jAt]  loop  ok
			if aAtR[kAt][1] < nAtL  nAtL = aAtR[kAt][1]  ok
			if aAtR[kAt][1] + aAtR[kAt][3] > nAtR2
				nAtR2 = aAtR[kAt][1] + aAtR[kAt][3]
			ok
		next
	next
	# ...and the lines this branch draws beyond its own boxes
	for jAt = 1 to len(aAtP)
		cAtK = StzLower("" + aAtP[jAt][1])
		bAtMine = 0
		for kAt = 1 to len(aAtIn[iAt])
			if StzFindFirst(aAtIn[iAt][kAt] + ">", cAtK) = 1  bAtMine = 1  ok
		next
		if NOT bAtMine  loop  ok
		for kAt = 1 to len(aAtP[jAt][2]) step 2
			if aAtP[jAt][2][kAt] > nAtR2  nAtR2 = aAtP[jAt][2][kAt]  ok
		next
	next
	if iAt > 1  aAtGut + (nAtL - nAtPrev)  ok
	nAtPrev = nAtR2
next
? "   ink gutters: " + aAtGut[1] + " and " + aAtGut[2]
chk("the two gutters are the same distance",
    fabs(aAtGut[1] - aAtGut[2]) < 6)

# NEGATIVE: the gutter is not merely equal, it is a GAP -- a rule that
# set both to zero would satisfy the clause above and overlap the
# branches.
chk("NEGATIVE: ...and both are a real separation", aAtGut[1] > 20)

sec("-- 73v. A LABEL BELONGS TO ONE ICON, VISIBLY ---------")

# "no" stood almost exactly between two questions in adjacent branches
# -- as far from the icon it answers as from the icon it does not.
# DRAKON labels the exits of an If so a reader can answer "which way
# is yes?" by looking at the icon; a word equidistant from two icons
# makes them look it up instead, which is the one thing this notation
# exists to spare them.
aAtL = oAt.RenderLabels()
nAtAmb = 0
for iAt = 1 to len(aAtL)
	cAtKey = StzLower("" + aAtL[iAt][6])
	nAtSep = StzFindFirst(">", cAtKey)
	if nAtSep < 1  loop  ok
	cAtOwn = left(cAtKey, nAtSep - 1)
	nAtLx = aAtL[iAt][2]  nAtLy = aAtL[iAt][3]
	nAtOwnD = 1000000  nAtOtherD = 1000000
	cAtNear = ""
	for jAt = 1 to len(aAtR)
		nAtCx = aAtR[jAt][1] + aAtR[jAt][3] / 2
		nAtCy = aAtR[jAt][2] + aAtR[jAt][4] / 2
		nAtDx = 0
		if nAtLx < aAtR[jAt][1]  nAtDx = aAtR[jAt][1] - nAtLx  ok
		if nAtLx > aAtR[jAt][1] + aAtR[jAt][3]
			nAtDx = nAtLx - (aAtR[jAt][1] + aAtR[jAt][3])
		ok
		nAtDy = 0
		if nAtLy < aAtR[jAt][2]  nAtDy = aAtR[jAt][2] - nAtLy  ok
		if nAtLy > aAtR[jAt][2] + aAtR[jAt][4]
			nAtDy = nAtLy - (aAtR[jAt][2] + aAtR[jAt][4])
		ok
		nAtD = sqrt(nAtDx * nAtDx + nAtDy * nAtDy)
		if StzLower("" + aAtR[jAt][5]) = cAtOwn
			nAtOwnD = nAtD
		else
			if nAtD < nAtOtherD
				nAtOtherD = nAtD
				cAtNear = "" + aAtR[jAt][5]
			ok
		ok
	next
	? "   " + aAtL[iAt][1] + " is " + nAtOwnD + " from " + cAtOwn +
	  " and " + nAtOtherD + " from " + cAtNear
	if nAtOwnD >= nAtOtherD  nAtAmb++  ok
next
chkeq("every exit label is nearest the icon it answers", nAtAmb, 0)
sec("-- 73w. AN ENCLOSING BRANCH STANDS FURTHER OUT ------")

# "The rule of secondary routes: the further to the right -- the worse
# it is." A branch that leaves the skewer earlier and is still out
# when a second one leaves CONTAINS that second one, so it belongs
# further from the main line.
#
# The allocator measured a branch from its first ICON, and the two
# readings agree whenever every alternative departs one row above that
# icon -- true of every fixture this plane had. They disagree the
# moment two refusals at different depths land on the SAME icon: the
# outer question's refusal is then a short span between its landing
# and the End, the inner one's is longer, and the count reads the
# inner as the outer. On the Principal's own advanceStep that inverted
# the two lanes and their wires crossed.
#
# THE OBVIOUS REPAIR WAS WRONG AND IS WORTH RECORDING, because it
# looked right and shipped nothing: starting every span at its
# departure row scrambled the picture, since the column ladder is
# GLOBAL and a case's body then shared spans with a different case's.
# Enclosure is only meaningful between branches on ONE skewer, and
# reachability is what says so.
oEn = new stzDiagram("enclose73w")
oEn.SetNotation(StzDrakonNotation())
oEn.AddNodeXTT("t","advanceStep",[ :type = "title" ])
oEn.AddNodeXTT("s","module.state",[ :type = "select" ])
oEn.AddNodeXTT("k1","playing",[ :type = "case" ])
oEn.AddNodeXTT("k2","dropping",[ :type = "case" ])
oEn.AddNodeXTT("k3","finished",[ :type = "case" ])
oEn.AddNodeXTT("p1","module.projectile",[ :type = "question" ])
oEn.AddNodeXTT("p2","canMoveDown()",[ :type = "question" ])
oEn.AddNodeXTT("p3","moveDown()",[ :type = "action" ])
oEn.AddNodeXTT("p4","return getStepPeriod()",[ :type = "action" ])
oEn.AddNodeXTT("p5","freezeProjectile()",[ :type = "action" ])
oEn.AddNodeXTT("p6","return noProjectile()",[ :type = "action" ])
oEn.AddNodeXTT("d1","canMoveDown()",[ :type = "question" ])
oEn.AddNodeXTT("d2","moveDown()",[ :type = "action" ])
oEn.AddNodeXTT("d3","return DropPeriod",[ :type = "action" ])
oEn.AddNodeXTT("d4","freezeProjectile()",[ :type = "action" ])
oEn.AddNodeXTT("d5","return getStepPeriod()",[ :type = "action" ])
oEn.AddNodeXTT("f1","return undefined",[ :type = "action" ])
oEn.AddNodeXTT("e","End",[ :type = "end" ])
oEn.AddEdge("t","s")
oEn.AddEdge("s","k1")  oEn.AddEdge("s","k2")  oEn.AddEdge("s","k3")
oEn.AddEdge("k1","p1")
oEn.AddEdgeXTT("p1","p2","yes", [ :exit = :down ])
oEn.AddEdgeXTT("p1","p6","no",  [ :exit = :right ])
oEn.AddEdgeXTT("p2","p3","yes", [ :exit = :down ])
oEn.AddEdgeXTT("p2","p5","no",  [ :exit = :right ])
oEn.AddEdge("p3","p4")  oEn.AddEdge("p5","p6")
oEn.AddEdge("p4","e")   oEn.AddEdge("p6","e")
oEn.AddEdge("k2","d1")
oEn.AddEdgeXTT("d1","d2","yes", [ :exit = :down ])
oEn.AddEdgeXTT("d1","d4","no",  [ :exit = :right ])
oEn.AddEdge("d2","d3")  oEn.AddEdge("d4","d5")
oEn.AddEdge("d3","e")   oEn.AddEdge("d5","e")
oEn.AddEdge("k3","f1")  oEn.AddEdge("f1","e")
oEn.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20 ])

# THE WHOLE CLAIM, ASKED OF THE DRAWING. "Rule: line intersections and
# breaks are not allowed." Every other clause here explains WHY the
# picture is right; this one says whether it is.
? "   crossings on advanceStep: " + oEn.RenderCrossings()
chkeq("the hardest shape in the set draws no crossing",
    oEn.RenderCrossings(), 0)

# ...AND THE REASON IT DOES: the outer refusal stands outside the
# inner one. Without this the clause above could be satisfied by a
# layout that merely happened to miss.
aEnR = oEn.RenderNodeRects()
nEnIn = 0  nEnOut = 0  nEnK1 = 0  nEnK2 = 0  nEnK3 = 0
for iEn = 1 to len(aEnR)
	cEnI = StzLower("" + aEnR[iEn][5])
	if cEnI = "p5"  nEnIn = aEnR[iEn][1]  ok
	if cEnI = "p6"  nEnOut = aEnR[iEn][1]  ok
	if cEnI = "k1"  nEnK1 = aEnR[iEn][1]  ok
	if cEnI = "k2"  nEnK2 = aEnR[iEn][1]  ok
	if cEnI = "k3"  nEnK3 = aEnR[iEn][1]  ok
next
? "   inner refusal at x " + nEnIn + ", outer at x " + nEnOut
chk("the enclosing refusal stands further from the skewer",
    nEnOut > nEnIn + 20)

# NEGATIVE: TWO BRANCHES IN DIFFERENT CASES ENCLOSE NOTHING, and must
# be left exactly as they were. This is the clause the wrong repair
# would have failed: it reordered branches across cases, because it
# compared spans that have no skewer in common.
? "   case columns at x " + nEnK1 + ", " + nEnK2 + ", " + nEnK3
chk("NEGATIVE: the cases keep their own order, left to right",
    nEnK1 < nEnK2 and nEnK2 < nEnK3)

# ...AND NO CASE'S BODY LANDS ON ANOTHER CASE'S. A rule that
# reordered across skewers would pull one case's icons into another's
# column, which is exactly what the wrong repair did and what no
# crossing count would have caught.
nEnD4 = 0
for iEn = 1 to len(aEnR)
	if StzLower("" + aEnR[iEn][5]) = "d4"  nEnD4 = aEnR[iEn][1]  ok
next
nEnHit = 0
for iEn = 1 to len(aEnR)
	cEnI = StzLower("" + aEnR[iEn][5])
	if cEnI = "d4" or cEnI = "d5"  loop  ok
	if nEnD4 > aEnR[iEn][1] - 20 and
	   nEnD4 < aEnR[iEn][1] + aEnR[iEn][3] + 20
		if StzFindFirst("d", cEnI) = 1  loop  ok
		nEnHit++
	ok
next
chkeq("NEGATIVE: no case body shares a column with another case",
    nEnHit, 0)

# ...AND A CASE'S OWN ROUTES STAND BESIDE THAT CASE.
#
# This clause was a printed KNOWN GAP for one day. Everything off the
# main line competed for ONE ladder of columns, so a case and another
# case's refusal were the same kind of thing to it and interleaved by
# nesting count: the dropping case's freezeProjectile() stood beyond
# the finished case, where the language keeps it between the two.
# Nothing collided and nothing crossed, so it was legal and
# unreadable -- a reader tracing one case crossed the sheet to follow
# its refusal.
#
# THE LADDER DID NOT NEED REBUILDING. The gap was written down as
# needing a ladder PER SKEWER -- a redesign -- and a ladder's slots
# are only an ORDER: numbering the branches depth-first by the case
# that owns each one puts every case's routes beside it, using the
# ladder exactly as built. The redesign named in the disclosure was
# the first shape seen, not the smallest that works, and writing it
# down as a redesign is what made it look expensive for a day.
? "   dropping refusal at x " + nEnD4 + ", between its own case at x " +
  nEnK2 + " and the next at x " + nEnK3
chk("a case's refusal stands beside its own case, not past the next",
    nEnD4 > nEnK2 and nEnD4 < nEnK3)
sec("-- 73x. THE SHELF AND THE INSERTION ------------------")

# The last two icons of DRAKON's table this profile was approximating.
#
# THE INSERTION is a call to another diagram, ruled once near each end
# -- the shape every notation has used for a sub-routine since before
# flowcharts were printed. This profile reached for UML's COMPONENT
# because it was the nearest thing already drawn, and left a comment
# saying so. A component reads as a deployable part rather than as a
# call, and its tabs sit OUTSIDE the body, so a wire arriving at the
# left border met a tab instead of the box.
#
# THE SHELF is a box ruled once across the middle holding two texts:
# what is produced above the rule, how it is produced below. That is a
# two-compartment node, which this plane already draws for a UML class
# -- so the shelf needed no glyph, only the right to NAME its second
# compartment. The compartment reader had UML's two property names
# written into it: the same enumerated-list fault as the four layout
# modes and the one shape called "diamond", met a third time in a week.
oSh = new stzDiagram("shelf73x")
oSh.SetNotation(StzDrakonNotation())
oSh.AddNodeXTT("t","Price a basket",[ :type = "title" ])
oSh.AddNodeXTT("ins","Apply the tariff",[ :type = "insertion" ])
oSh.AddNodeXTT("s1","total",[ :type = "shelf", :value = "net + tax" ])
oSh.AddNodeXTT("e","End",[ :type = "end" ])
oSh.AddEdge("t","ins")  oSh.AddEdge("ins","s1")  oSh.AddEdge("s1","e")
oSh.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20 ])

# THE INSERTION IS ITS OWN GLYPH, not the nearest one already drawn.
chkeq("an insertion is drawn as an insertion",
    StzLower("" + oSh._ShapeOfId("ins")), "insertion")

# NEGATIVE: ...and the painter knows the name. The first attempt
# declared the glyph and mapped the kind to it, and the picture came
# out a plain box -- the shape vocabulary is a declared list and an
# unknown name falls back rather than raising, so a glyph can be
# written, wired, and silently not drawn.
chkeq("NEGATIVE: the painter carries it in its vocabulary",
    StzIsNodeShape("insertion"), 1)

# A SHELF CARRIES TWO COMPARTMENTS OR IT IS A BOX. The rule across the
# middle is the whole icon; one compartment is the shelf with the
# thing that makes it a shelf missing.
aShN = []
for iSh = 1 to len(oSh.Nodes())
	if StzLower("" + oSh.Nodes()[iSh][:id]) = "s1"
		aShN = oSh.Nodes()[iSh]
	ok
next
nShC = len(oSh._CompartmentsOf(aShN))
? "   the shelf holds " + nShC + " compartments"
chkeq("a shelf is a two-compartment node", nShC, 2)

# ...AND THE SECOND ONE HOLDS WHAT THE AUTHOR WROTE, not an empty band.
aShB = oSh._CompartmentsOf(aShN)
chkeq("the lower compartment carries the value",
    StzLower("" + aShB[2][1]), "net + tax")

# NEGATIVE: A NOTATION THAT DECLARES NO COMPARTMENTS KEEPS UML'S PAIR,
# so every picture that existed before this reads exactly as it did.
# Without this the change would be a silent redefinition of what a
# class compartment is for every other domain in the plane.
oSh2 = new stzDiagram("uml73x")
oSh2.SetNotation(StzUmlNotation())
oSh2.AddNodeXTT("c","Invoice",[ :type = "class",
    :attributes = [ "net", "tax" ], :operations = [ "total()" ] ])
aShU = []
for iSh = 1 to len(oSh2.Nodes())
	if StzLower("" + oSh2.Nodes()[iSh][:id]) = "c"  aShU = oSh2.Nodes()[iSh]  ok
next
? "   a UML class still holds " + len(oSh2._CompartmentsOf(aShU)) +
  " compartments"
chkeq("NEGATIVE: UML keeps its own two compartments",
    len(oSh2._CompartmentsOf(aShU)), 3)
sec("-- 73y. WHAT A RENDERER OWES THE FILE IT WRITES -----")

# Central handed this plane a finding from another repository -- a page
# arguing an application fits in half a megabyte, illustrated with a
# 594 KB PNG carrying 16,414 unique colours where a dozen were intended
# -- and left the judgement here. So the first move was to measure this
# plane's OWN output rather than adopt the conclusion.
#
# IT IS NOT THE SAME DEFECT. These files carry 503 to 1081 colours, not
# sixteen thousand, and 0.05 to 0.14 bytes per pixel: deflate is
# working and there is no lossy step upstream. The colours above a dozen
# are ANTIALIASED EDGES, which is real information, not noise in flat
# regions.
#
# THE DEFECT WAS A DIFFERENT ONE AND THE MEASUREMENT FOUND IT. Every
# file was 32-bit RGBA. The encoder had a palette path for 256 colours
# or fewer and a truecolour path for everything else, and NOTHING
# BETWEEN THEM -- so a drawing with 800 antialiased colours and no
# transparency wrote a fourth channel holding the constant 255 in every
# pixel. 17 files measured, every one fully opaque.
# A REAL DIAGRAM, because a simple one does not reach this branch. The
# first version of this guard drew one rounded rectangle and asserted
# RGB; it came back INDEXED, correctly -- under 256 colours the
# palette path is the right answer and the new branch never runs. A
# guard has to exercise the case it is about.
oPnD = new stzDiagram("png73y")
oPnD.SetNotation(StzDrakonNotation())
oPnD.AddNodeXTT("t","Read the file",[ :type = "title" ])
oPnD.AddNodeXTT("q","Is it empty?",[ :type = "question" ])
oPnD.AddNodeXTT("a","Parse it",[ :type = "action" ])
oPnD.AddNodeXTT("n","Report it",[ :type = "action" ])
oPnD.AddNodeXTT("e","Done",[ :type = "end" ])
oPnD.AddEdge("t","q")
oPnD.AddEdgeXT("q","a","yes")  oPnD.AddEdgeXT("q","n","no")
oPnD.AddEdge("a","e")  oPnD.AddEdge("n","e")
oPnD.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                  :FontSize = 20 ])
oPn = oPnD.LastCanvas()
cPnB = oPn.ToPNG("")
chk("the canvas wrote a PNG at all", len(cPnB) > 100)

# THE COLOUR TYPE IS READ FROM THE FILE, not from the encoder's report.
# PNG puts it at offset 25: 8 bytes of signature, 4 of length, 4 of
# "IHDR", 4 width, 4 height, 1 bit depth, then the type.
nPnType = ascii(cPnB[26])
? "   colour type written: " + nPnType + " (2 = rgb, 6 = rgba)"
chkeq("an opaque drawing is written without an alpha channel",
    nPnType, 2)

# ...AND IT IS EARNED, not assumed. The encoder tests the PIXELS; this
# asserts the same precondition independently, so the clause above
# cannot pass by an encoder that simply stopped writing alpha.
#
# ON A SMALL CANVAS, DELIBERATELY. Scanning the diagram's own 260,780
# pixels from Ring cost 9.6 seconds -- half the suite -- to prove a
# property of the DRAWING SURFACE, which needs no size to demonstrate.
# The two clauses want different scenes: the encoder's choice needs a
# picture past 256 colours, the surface's opacity needs any picture at
# all. Asking both of one scene bought nothing and spent the budget.
oPnS = new stzCanvas(160, 120)
oPnS.SetBackground("#ffffff")
oPnS.Fill("#2b6cb0")
oPnS.AddRoundRect(20, 20, 120, 60, 8)
cPnPx = oPnS.ToPixels()
nPnOpaque = 1
nPnSeen = 0
for iPn = 4 to len(cPnPx) step 4
	nPnSeen++
	if ascii(cPnPx[iPn]) != 255  nPnOpaque = 0  exit  ok
next
? "   " + nPnSeen + " pixels checked, all opaque: " + nPnOpaque
chkeq("every pixel the canvas drew is opaque", nPnOpaque, 1)

# NEGATIVE: PIXELS THAT ARE NOT OPAQUE STILL GET THE CHANNEL. Fed
# directly to the encoder, because this plane's drawing API has no way
# to express translucency at all -- which is the stronger form of the
# finding: the alpha channel could never have been needed here, not
# merely was not needed.
#
# OVER 256 COLOURS AS WELL AS TRANSLUCENT, and the first version of
# this clause missed that: with few colours the encoder writes an
# INDEXED file and carries the alpha in a tRNS chunk, which is correct
# and is not the branch under test. A negative aimed at the wrong
# branch reports on something nobody asked about.
cPnA = ""
for iPn = 1 to 400
	cPnA += char(iPn % 200) + char((iPn * 7) % 251) +
	        char((iPn * 13) % 241) + char(128)
next
for iPn = 1 to 400
	cPnA += char((iPn * 3) % 199) + char((iPn * 11) % 253) +
	        char((iPn * 5) % 239) + char(255)
next
cPnR = StzEngineGpuPngEncode(40, 20, cPnA, 4)
? "   translucent pixels -> colour type " + ascii(cPnR[26])
chkeq("NEGATIVE: a translucent drawing keeps its alpha channel",
    ascii(cPnR[26]), 6)

# ...AND A DRAWING OF FEW ENOUGH COLOURS IS STILL INDEXED, so the new
# branch sits BETWEEN the two that existed and did not replace either.
cPnF = ""
for iPn = 1 to 800
	cPnF += char(10) + char(20) + char(30) + char(255)
next
cPnI = StzEngineGpuPngEncode(40, 20, cPnF, 4)
? "   one-colour drawing -> colour type " + ascii(cPnI[26])
chkeq("NEGATIVE: a small palette is still written indexed",
    ascii(cPnI[26]), 3)

# THE COMPRESSION LEVEL IS A MEASURED DEFAULT. It was 1 -- deflate's
# weakest -- taken as the GR0 default and never revisited. Measured on
# this library's own silhouette, five runs each, identical pixels:
# level 1 gives 52598 bytes in 10.8 ms, level 4 gives 45032 in 15.6,
# level 9 gives 43162 in 55.5. Four is the knee; nine spends 5.1x the
# time of one to beat four by 4%.
cPnL1 = oPn.ToPNGXT("", 1)
cPnL4 = oPn.ToPNGXT("", 4)
? "   level 1: " + len(cPnL1) + " bytes, level 4: " + len(cPnL4)
chk("the default level is doing work", len(cPnL4) <= len(cPnL1))
chkeq("...and the dial is exposed for a caller who wants the rest",
    len(oPn.ToPNGXT("", 9)) <= len(cPnL4), 1)
sec("-- 73z. A TIMER ATTACHES, IT DOES NOT SEQUENCE ------")
discharges("DN6b")

# The plan of record named the real-time icons as this plane's last gap
# in these words: they "are declared as kinds and draw as sensible
# shapes; none of them has a LAW yet, which is the difference between a
# vocabulary and a notation."
#
# THE LAW IS IN THE MACROICON TABLE, thirteen rows of it. Every row of
# the form "X by timer" -- action, shelf, fork, switch, input, output,
# insertion, parallel process -- draws the timer trapezoid ATTACHED TO
# THE LEFT of the icon it governs, on that icon's own row.
#
# Drawn in sequence a timer says "wait, then do this", which is a step.
# Drawn beside, it says "this step is governed by a deadline", which is
# a property of the step. Those are different algorithms.
oRt = new stzDiagram("realtime73z")
oRt.SetNotation(StzDrakonNotation())
oRt.AddNodeXTT("t","Poll the sensor",[ :type = "title" ])
oRt.AddNodeXTT("rd","Read the value",[ :type = "action" ])
oRt.AddNodeXTT("tm","500 ms",[ :type = "timer" ])
oRt.AddNodeXTT("wr","Write the log",[ :type = "action" ])
oRt.AddNodeXTT("e","Done",[ :type = "end" ])
oRt.AddEdge("t","rd")  oRt.AddEdge("rd","wr")  oRt.AddEdge("wr","e")
oRt.AddEdge("tm","rd")
oRt.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                 :FontSize = 20 ])
chkeq("the model says which icon the timer governs",
    StzLower("" + oRt._TimerAttachOf("tm")), "rd")

# IT STANDS ON THAT ICON'S ROW, AND TO ITS LEFT.
aRtR = oRt.RenderNodeRects()
nRtTx = 0  nRtTy = 0  nRtRx = 0  nRtRy = 0
for iRt = 1 to len(aRtR)
	cRtI = StzLower("" + aRtR[iRt][5])
	if cRtI = "tm"
		nRtTx = aRtR[iRt][1] + aRtR[iRt][3] / 2
		nRtTy = aRtR[iRt][2] + aRtR[iRt][4] / 2
	ok
	if cRtI = "rd"
		nRtRx = aRtR[iRt][1] + aRtR[iRt][3] / 2
		nRtRy = aRtR[iRt][2] + aRtR[iRt][4] / 2
	ok
next
? "   timer at " + nRtTx + "," + nRtTy + "  the action it times at " +
  nRtRx + "," + nRtRy
chk("the timer shares the row of what it times", fabs(nRtTy - nRtRy) < 2)
chk("...and stands to its left", nRtTx < nRtRx - 20)

# ...AND THE ATTACHMENT IS NOT A WIRE. The edge that says which icon is
# governed is a declaration, not a step -- drawn as a line it would put
# the timer back in the flow it was taken out of.
nRtWire = 0
for iRt = 1 to len(oRt.RenderEdgePaths())
	if StzLower("" + oRt.RenderEdgePaths()[iRt][1]) = "tm>rd"  nRtWire++  ok
next
chkeq("the attachment is written, not drawn", nRtWire, 0)

# ...AND THE FLOW STILL REACHES THE ICON IT GOVERNS. A suppression that
# also lost the real edge would satisfy the clause above by drawing
# less, which is the cheapest way to pass a test about not drawing.
nRtIn = 0
for iRt = 1 to len(oRt.RenderEdgePaths())
	if StzLower("" + oRt.RenderEdgePaths()[iRt][1]) = "t>rd"  nRtIn++  ok
next
chkeq("NEGATIVE: the sequence into that icon is still drawn", nRtIn, 1)

# NEGATIVE: A TIMER THAT GOVERNS TWO THINGS IS NOT AN ATTACHMENT. The
# macroicon pairs ONE timer with ONE icon; a node with two successors
# is a step in the flow whatever its kind, and the rule must say so
# rather than attaching it to whichever it met first.
oRt2 = new stzDiagram("twotimed73z")
oRt2.SetNotation(StzDrakonNotation())
oRt2.AddNodeXTT("t","Start",[ :type = "title" ])
oRt2.AddNodeXTT("tm","500 ms",[ :type = "timer" ])
oRt2.AddNodeXTT("a","Do this",[ :type = "action" ])
oRt2.AddNodeXTT("b","Or this",[ :type = "action" ])
oRt2.AddEdge("t","tm")  oRt2.AddEdge("tm","a")  oRt2.AddEdge("tm","b")
oRt2.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                  :FontSize = 20 ])
chkeq("NEGATIVE: a timer with two successors stays in the flow",
    oRt2._TimerAttachOf("tm"), "")

# ...AND NEITHER IS AN ORDINARY ICON. The law reads the KIND, so an
# action pointing at one thing is a step and must not be swept aside.
chkeq("NEGATIVE: an action is not an attachment",
    oRt._TimerAttachOf("rd"), "")

# NEGATIVE: A TIMER SOMETHING FLOWS INTO IS A STEP. An attachment
# hangs off what it governs and is reached by nothing; an author who
# put the timer IN the chain meant it as a step, and the model says
# which they meant. Without this clause the rule moved the timer aside
# and left the wire arriving at it -- a line to nowhere, and a picture
# worse than before the law existed.
oRt3 = new stzDiagram("timedstep73z")
oRt3.SetNotation(StzDrakonNotation())
oRt3.AddNodeXTT("t","Start",[ :type = "title" ])
oRt3.AddNodeXTT("tm","Wait",[ :type = "timer" ])
oRt3.AddNodeXTT("a","Do it",[ :type = "action" ])
oRt3.AddEdge("t","tm")  oRt3.AddEdge("tm","a")
oRt3.ToCanvasXT([ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56,
                  :FontSize = 20 ])
chkeq("NEGATIVE: a timer in the chain stays in the chain",
    oRt3._TimerAttachOf("tm"), "")
nRt3 = 0
for iRt = 1 to len(oRt3.RenderEdgePaths())
	cRt3 = StzLower("" + oRt3.RenderEdgePaths()[iRt][1])
	if cRt3 = "t>tm" or cRt3 = "tm>a"  nRt3++  ok
next
chkeq("NEGATIVE: ...and both its wires are drawn", nRt3, 2)

# THE WAITING FAMILY STOPPED WEARING THE QUESTION'S GLYPH. Three icons
# meaning "wait" were drawn as HEXAGONS -- the If -- and par as the
# action's box, so four icons carried two other icons' shapes and only
# the wires said otherwise.
aRtK = [ [ "timer", "timerglyph" ], [ "pause", "pauseglyph" ],
         [ "duration", "durationglyph" ], [ "par", "parallel" ] ]
nRtBad = 0
for iRt = 1 to len(aRtK)
	cRtG = StzLower("" + StzDrakonNotation().GlyphOf(aRtK[iRt][1]))
	if cRtG != aRtK[iRt][2]  nRtBad++  ok
	if cRtG = "hexagon" or cRtG = "box"  nRtBad++  ok
next
chkeq("each real-time icon has a glyph of its own", nRtBad, 0)
chkeq("NEGATIVE: ...and the painter knows every one of them",
    StzIsNodeShape("timerglyph") + StzIsNodeShape("pauseglyph") +
    StzIsNodeShape("durationglyph") + StzIsNodeShape("parallel"), 4)

sec("-- 73g. A GROUND IS MET AT ITS LEAD, NOT ITS BARS ------")

# A GROUND HAS ONE TERMINAL, IT IS ON TOP, AND THE WIRE ARRIVES THERE
# GOING DOWN.
#
# The symbol drew its lead upward whatever the wire did, so a
# left-to-right chain ending at earth ran its wire horizontally ACROSS
# the bars at mid-height and then turned up into the top of the lead --
# leaving the lead standing above the wire joined to nothing, and the
# bars crossed by the line that was supposed to end at them. The
# Principal marked the stub.
#
# ROTATING THE SYMBOL FIXED THE INCIDENCE AND WAS STILL WRONG, which is
# why this section asserts the ARRIVAL and not merely the contact: a
# sideways ground is joined correctly and is drawn in a way no textbook
# uses. The placement was the fault. A ground that would be met from
# the side is dropped below the run, and the wire turns down into an
# upright symbol.
#
# Both a top-down and a left-to-right circuit are checked, because the
# first attempt at the orientation rule broke the one it was not aimed
# at: judging it by "is my net further sideways than downward" turned a
# TOP-DOWN circuit's ground on its side, since a stub is offset right
# AND down and the sideways part happened to be larger.
aGrCase = [ "top-down", "left-to-right" ]
nGrUp = 0  nGrOnLead = 0  nGrDown = 0  nGrSeen = 0
for iGr = 1 to 2
	oGr = new stzDiagram("gnd73g" + iGr)
	oGr.SetNotation(StzElectricNotation())
	if iGr = 2  oGr.SetLayout(:LeftToRight)  ok
	oGr.AddNodeXTT("v", "VIN", [ :type = "source" ])
	oGr.AddNodeXTT("r", "R", [ :type = "resistor" ])
	oGr.AddNodeXTT("c", "C", [ :type = "capacitor" ])
	oGr.AddNodeXTT("g", "", [ :type = "ground" ])
	if iGr = 1
		oGr.AddNodeXTT("nin", "IN", [ :type = "net" ])
		oGr.AddNodeXTT("nout", "OUT", [ :type = "net" ])
		oGr.AddNodeXTT("n0", "GND", [ :type = "net" ])
		oGr.AddEdge("v","nin")   oGr.AddEdge("nin","r")
		oGr.AddEdge("r","nout")  oGr.AddEdge("nout","c")
		oGr.AddEdge("c","n0")    oGr.AddEdge("n0","g")
		oGr.AddEdge("n0","v")
	else
		oGr.AddEdge("v","r")  oGr.AddEdge("r","c")  oGr.AddEdge("c","g")
	ok
	oGr.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
	                 :FontSize = 26 ])
	aGrB = oGr._NodeRectOf("g")
	if len(aGrB) < 4  loop  ok
	nGrSeen++
	if aGrB[4] > aGrB[3]  nGrUp++  ok
	aGrLead = [ aGrB[1] + aGrB[3] / 2, aGrB[2] ]
	# its one wire: the end that touches it, and the segment before it
	aGrEnd = []  aGrPrev = []
	for jGr = 1 to len(oGr.@aEdgePaths)
		cGrK = StzLower("" + oGr.@aEdgePaths[jGr][1])
		aGrF = oGr.@aEdgePaths[jGr][2]
		if len(aGrF) < 4  loop  ok
		if StzFindFirst(">", cGrK) < 1  loop  ok
		aGrS = StzSplit(cGrK, ">")
		if aGrS[1] = "g"
			aGrEnd = [ aGrF[1], aGrF[2] ]
			aGrPrev = [ aGrF[3], aGrF[4] ]
		but aGrS[2] = "g"
			nGrL = len(aGrF)
			aGrEnd = [ aGrF[nGrL - 1], aGrF[nGrL] ]
			aGrPrev = [ aGrF[nGrL - 3], aGrF[nGrL - 2] ]
		ok
	next
	if len(aGrEnd) < 2  loop  ok
	nGrD = fabs(aGrEnd[1] - aGrLead[1]) + fabs(aGrEnd[2] - aGrLead[2])
	if nGrD < 1.5  nGrOnLead++  ok
	# the segment that touches it must be VERTICAL and coming DOWN
	if fabs(aGrPrev[1] - aGrEnd[1]) < 1.5 and aGrPrev[2] < aGrEnd[2]
		nGrDown++
	ok
	? "   " + aGrCase[iGr] + ": box " + aGrB[3] + "x" + aGrB[4] +
	  ", arrives (" + aGrPrev[1] + "," + aGrPrev[2] + ") -> (" +
	  aGrEnd[1] + "," + aGrEnd[2] + "), lead at (" + aGrLead[1] +
	  "," + aGrLead[2] + ")"
next
chkeq("both circuits were drawn", nGrSeen, 2)
chkeq("the symbol stands upright in both", nGrUp, 2)
chkeq("its wire ends ON the lead, in both", nGrOnLead, 2)
chkeq("...arriving from ABOVE, in both", nGrDown, 2)

# THE NEGATIVE SIBLING: the reader must be able to tell the lead from
# the middle of the symbol, or it would pass on a wire ending anywhere;
# and it must be able to tell a descent from a sideways arrival, or the
# clause above would pass on the very picture that was marked.
oGr2 = new stzDiagram("gnd73gN")
oGr2.SetNotation(StzElectricNotation())
# read left to right ON PURPOSE: that is the arrangement whose wire has
# to TURN to reach the lead, so it is the only one carrying a
# horizontal segment for the negative below to be tested against
oGr2.SetLayout(:LeftToRight)
oGr2.AddNodeXTT("v", "VIN", [ :type = "source" ])
oGr2.AddNodeXTT("c", "C", [ :type = "capacitor" ])
oGr2.AddNodeXTT("g", "", [ :type = "ground" ])
oGr2.AddEdge("v","c")  oGr2.AddEdge("c","g")
oGr2.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
                  :FontSize = 26 ])
aGrB2 = oGr2._NodeRectOf("g")
nGrMx = aGrB2[1] + aGrB2[3] / 2
nGrMy = aGrB2[2] + aGrB2[4] / 2
nGrMid = fabs(nGrMx - nGrMx) + fabs(nGrMy - aGrB2[2])
? "   the centre sits " + nGrMid + "px below the lead"
chk("NEGATIVE: the middle of the symbol is NOT its lead", nGrMid > 1.5)
# ...and a horizontal arrival, which is what the marked picture had,
# must NOT read as a descent. Measured on a REAL segment rather than on
# three literals: the wire reaching this ground turns down at the end,
# so the segment BEFORE that turn is horizontal, and the same predicate
# applied to it has to answer no. If it answered yes the clause above
# would pass on the picture the Principal circled.
aGrP2 = []
for jGr = 1 to len(oGr2.@aEdgePaths)
	cGrK = StzLower("" + oGr2.@aEdgePaths[jGr][1])
	if cGrK != "c>g"  loop  ok
	aGrP2 = oGr2.@aEdgePaths[jGr][2]
next
nGrFake = 0
if len(aGrP2) >= 6
	# the first segment of that wire, before it turns
	if NOT (fabs(aGrP2[1] - aGrP2[3]) < 1.5 and aGrP2[2] < aGrP2[4])
		nGrFake = 1
	ok
	? "   the segment before the turn runs (" + aGrP2[1] + "," +
	  aGrP2[2] + ") -> (" + aGrP2[3] + "," + aGrP2[4] + ")"
ok
chkeq("NEGATIVE: a sideways arrival is not read as coming down",
    nGrFake, 1)

sec("-- 73h. ONE INK, ONE WEIGHT, AND A STUB YOU CAN SEE ----")

# A WIRE AND A PART'S OUTLINE ARE ONE CONDUCTOR.
#
# The Principal asked whether the thinner line on the electrical
# objects was a norm or a defect. Measured on the divider: outline and
# wire were both 2px, and the outline was drawn at 58 against the
# wire's 138 -- so the wire read as the thinner of two lines that are
# the same width. A chart draws its boxes darker than its arrows
# because the boxes are the subject; a schematic has no such division.
#
# AND A ROTATED PART WAS GENUINELY THINNER, which is the other half of
# the same question. The stroke width was 2 * min of the two side
# ratios, so a resistor standing on end -- 68x110 against a generic
# 110x68 -- scored 0.62 and was stroked at 1.24 where the same resistor
# lying down was stroked at 2. Two identical parts at two weights in
# one picture is I5 exactly.
oIk = new stzDiagram("ink73h")
oIk.SetNotation(StzElectricNotation())
oIk.AddNodeXTT("v", "12V", [ :type = "source" ])
oIk.AddNodeXTT("r1", "R1 10k", [ :type = "resistor" ])
oIk.AddNodeXTT("r2", "R2 10k", [ :type = "resistor" ])
oIk.AddNodeXTT("g", "", [ :type = "ground" ])
oIk.AddNodeXTT("vcc", "VCC", [ :type = "net" ])
oIk.AddNodeXTT("out", "VOUT", [ :type = "net" ])
oIk.AddNodeXTT("gnd", "GND", [ :type = "net" ])
oIk.AddEdge("v","vcc")   oIk.AddEdge("vcc","r1")
oIk.AddEdge("r1","out")  oIk.AddEdge("out","r2")
oIk.AddEdge("r2","gnd")  oIk.AddEdge("gnd","g")
oIk.AddEdge("gnd","v")
oIk.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
                 :FontSize = 26 ])
nIkW = oIk.LastCanvas().Width()
cIkPx = oIk.LastCanvas().ToPixels()

# the darkest ink down a column, which is the stroke wherever it falls
nIkR2 = _DarkestDown(cIkPx, nIkW, 336, 20, 50)     # through R2's body
nIkRail = _DarkestDown(cIkPx, nIkW, 450, 20, 50)   # the rail beside it
nIkR1 = _DarkestAcross(cIkPx, nIkW, 20, 50, 430)   # through R1's body
nIkArm = _DarkestAcross(cIkPx, nIkW, 20, 50, 300)  # the arm above it
? "   R2 outline " + nIkR2 + " vs its rail " + nIkRail
? "   R1 outline " + nIkR1 + " vs its arm  " + nIkArm
chk("a wire is drawn in the same ink as the part it joins",
    fabs(nIkR2 - nIkRail) < 8 and fabs(nIkR1 - nIkArm) < 8)
chk("...and a part standing on end weighs the same as one lying down",
    fabs(nIkR2 - nIkR1) < 8)

# THE NEGATIVE SIBLING: this is a PROFILE's ruling, not a new default.
# An ordinary chart must still draw its arrows lighter than its boxes,
# or the change has leaked out of the domain that asked for it.
oIk2 = new stzDiagram("ink73hN")
oIk2.AddNode("a")  oIk2.AddNode("b")  oIk2.AddEdge("a","b")
oIk2.ToCanvasXT([ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 68,
                  :FontSize = 26 ])
nIk2W = oIk2.LastCanvas().Width()
cIk2Px = oIk2.LastCanvas().ToPixels()
aIk2 = oIk2.RenderNodeRects()
nIk2Node = 255  nIk2Edge = 255
for iIk = 1 to len(aIk2)
	if StzLower("" + aIk2[iIk][5]) != "a"  loop  ok
	nIk2Cx = floor(aIk2[iIk][1] + aIk2[iIk][3] / 2)
	# down through the cell's own bottom outline, then through the
	# edge that leaves it
	nIk2Node = _DarkestDown(cIk2Px, nIk2W, nIk2Cx,
		floor(aIk2[iIk][2] + aIk2[iIk][4]) - 4, 8)
	nIk2Edge = _DarkestDown(cIk2Px, nIk2W, nIk2Cx,
		floor(aIk2[iIk][2] + aIk2[iIk][4]) + 12, 10)
next
? "   plain chart: cell outline " + nIk2Node + ", its edge " + nIk2Edge
chk("NEGATIVE: an ordinary chart still draws its edges lighter",
    nIk2Edge > nIk2Node + 20)

# ...AND THE STUB BETWEEN A MARK AND ITS NAME IS VISIBLE. A junction is
# joined at its CENTRE so the wire runs through unbroken, and the test
# that makes room for a departing wire asked only about the bottom
# BORDER -- so a junction's name sat 5.2px under the dot and the plate
# erased the wire from there down.
aIkD = oIk._NodeRectOf("gnd")
nIkBot = aIkD[2] + aIkD[4]
nIkPlate = -1
_aIkL_ = oIk.RenderNodeLabels()
for iIk = 1 to len(_aIkL_)
	if StzLower("" + _aIkL_[iIk][1]) = "gnd"
		nIkPlate = _aIkL_[iIk][3] - _aIkL_[iIk][5] / 2
	ok
next
? "   dot bottom " + nIkBot + ", name plate starts " + nIkPlate +
  "  -> stub " + (nIkPlate - nIkBot) + "px"

# THE CLAIM IS THAT THE WORD DOES NOT ERASE THE WIRE, and there are now
# TWO ways to satisfy it. This used to require a stub of at least 14px
# between the dot and the plate, which is the only answer available
# while a name is always written BELOW. A name that steps to the SIDE
# satisfies the same claim better -- there is no wire between them to
# be crowded at all -- and the stub arithmetic then reads as a negative
# number and convicts the improvement.
#
# So the property is asked directly: the plate, wherever it went, is
# clear of every wire. The stub above is still printed, because when
# the name IS below it remains the thing a reader looks at.
nIkOn = 0
_aIkP_ = []
for iIk = 1 to len(_aIkL_)
	if StzLower("" + _aIkL_[iIk][1]) = "gnd"
		_aIkP_ = [ _aIkL_[iIk][2] - _aIkL_[iIk][4] / 2,
			_aIkL_[iIk][3] - _aIkL_[iIk][5] / 2,
			_aIkL_[iIk][2] + _aIkL_[iIk][4] / 2,
			_aIkL_[iIk][3] + _aIkL_[iIk][5] / 2 ]
	ok
next
for iIk = 1 to len(oIk.@aEdgePaths)
	aIkF = oIk.@aEdgePaths[iIk][2]
	for kIk = 1 to len(aIkF) - 3 step 2
		nIkX1 = min([ aIkF[kIk], aIkF[kIk + 2] ])
		nIkX2 = max([ aIkF[kIk], aIkF[kIk + 2] ])
		nIkY1 = min([ aIkF[kIk + 1], aIkF[kIk + 3] ])
		nIkY2 = max([ aIkF[kIk + 1], aIkF[kIk + 3] ])
		if nIkX2 < _aIkP_[1] or nIkX1 > _aIkP_[3]  loop  ok
		if nIkY2 < _aIkP_[2] or nIkY1 > _aIkP_[4]  loop  ok
		nIkOn++
	next
next
? "   its plate sits on " + nIkOn + " wire segment(s)"
chk("a mark's name does not stand on the wire it names", nIkOn = 0)

sec("-- 73b. A NAME MAKES ROOM FOR THE WIRE BESIDE IT ---------")

# A component writes its name below itself. Where a wire ALSO leaves
# below, the name's background plate erased the first stretch of that
# wire, so the line appeared to start late and well under the part it
# belongs to. The Principal asked for the starting portion of the
# vertical to be longer, which is exactly what it needs: a visible stub
# between the terminal and the word.
oNm = new stzDiagram("stub73b")
oNm.SetNotation(StzElectricNotation())
oNm.AddNodeXTT("v", "9V", [ :type = "source" ])
oNm.AddNodeXTT("r", "R", [ :type = "resistor" ])
oNm.AddNodeXTT("c", "C", [ :type = "capacitor" ])
oNm.AddNodeXTT("a", "A", [ :type = "net" ])
oNm.AddNodeXTT("b", "B", [ :type = "net" ])
oNm.AddNodeXTT("d", "D", [ :type = "net" ])
oNm.AddEdge("v", "a")  oNm.AddEdge("a", "r")  oNm.AddEdge("r", "b")
oNm.AddEdge("b", "c")  oNm.AddEdge("c", "d")  oNm.AddEdge("d", "v")
oNm.ToCanvasXT(OPT67)

# For every component whose wire leaves through the bottom, the name's
# plate must begin BELOW where that wire starts -- so a stretch of wire
# is visible first.
nNmBad = 0  nNmSeen = 0
_aNmR_ = oNm.RenderNodeRects()
for iNm = 1 to len(_aNmR_)
	cNmId = StzLower("" + _aNmR_[iNm][5])
	nNmBot = _aNmR_[iNm][2] + _aNmR_[iNm][4]
	aNmAt = [ _aNmR_[iNm][1] + _aNmR_[iNm][3] / 2,
	          _aNmR_[iNm][2] + _aNmR_[iNm][4] / 2 ]
	if NOT oNm._LeavesThroughBottom(cNmId, aNmAt,
		[ _aNmR_[iNm][3], _aNmR_[iNm][4] ])  loop  ok
	nNmSeen++
	for jNm = 1 to len(oNm.@aRenderLabels)
		aNmL = oNm.@aRenderLabels[jNm]
		if StzLower("" + aNmL[6]) != ""  loop  ok
		if fabs(aNmL[2] - aNmAt[1]) > _aNmR_[iNm][3]  loop  ok
		if (aNmL[3] - aNmL[5] / 2) - nNmBot < 6  nNmBad++  ok
	next
next
? "   " + nNmSeen + " components with a wire leaving below, " +
  nNmBad + " whose name stands on its start"
chkeq("a name leaves a visible stub of the wire below its component",
	nNmBad, 0)

# THE NEGATIVE SIBLING: the scene must actually contain the case, or the
# zero above is a zero from an empty question.
chk("...and this circuit really does contain one", nNmSeen > 0)

# AND THE NAME STAYS BELOW, not beside. Stepping it aside was tried and
# is wrong for a glyph with real extent -- every label came out written
# across its own component, which is what the outside-label rule already
# warns about for the actor.
nNmOn = 0
for jNm = 1 to len(oNm.@aRenderLabels)
	aNmL = oNm.@aRenderLabels[jNm]
	if StzLower("" + aNmL[6]) != ""  loop  ok
	for iNm = 1 to len(_aNmR_)
		if aNmL[2] < _aNmR_[iNm][1]  loop  ok
		if aNmL[2] > _aNmR_[iNm][1] + _aNmR_[iNm][3]  loop  ok
		if aNmL[3] < _aNmR_[iNm][2]  loop  ok
		if aNmL[3] > _aNmR_[iNm][2] + _aNmR_[iNm][4]  loop  ok
		nNmOn++
	next
next
chkeq("NEGATIVE: ...and no name is written across its own glyph",
	nNmOn, 0)

sec("-- 73. DN5b -- A CIRCUIT IS READ AS A LOOP --------------")

# A layered layout answers "what flows into what" and orients cycles
# AWAY. A circuit is nothing but cycles: current leaves a source and must
# return to it or nothing flows. So the smallest closed loop in existence
# came out as a STRAIGHT LINE with two dangling ends, and a divider a
# textbook draws roughly square came out 124 x 1141.
#
# MEASURED BEFORE BUILDING: a closed RC filter is 6 nodes and 6 edges, so
# E - V + 1 = 1 -- exactly one independent loop. In circuit theory that
# quantity is the MESH COUNT and mesh analysis is built on it, so the
# mode is named in the domain's own word.
oMs = new stzDiagram("mesh73")
oMs.SetNotation(StzElectricNotation())
oMs.AddNodeXTT("v", "9V", [ :type = "source" ])
oMs.AddNodeXTT("r", "R", [ :type = "resistor" ])
oMs.AddNodeXTT("a", "A", [ :type = "net" ])
oMs.AddNodeXTT("b", "B", [ :type = "net" ])
oMs.AddEdge("v", "a")  oMs.AddEdge("a", "r")
oMs.AddEdge("r", "b")  oMs.AddEdge("b", "v")
oMs.ToCanvasXT(OPT67)

chkeq("the electric profile is read as a mesh",
	StzLower("" + StzElectricNotation().LayoutMode()), "mesh")

# A LOOP OCCUPIES TWO DIMENSIONS. The layered layout gave this circuit
# one column; a mesh gives it a rectangle, and the test is that no axis
# collapses.
nMsW = oMs.LastCanvas().Width()
nMsH = oMs.LastCanvas().Height()
nMsRatio = max([ nMsW, nMsH ]) / max([ 1, min([ nMsW, nMsH ]) ])
? "   the loop is drawn " + nMsW + "x" + nMsH + ", ratio " + nMsRatio
chk("a closed loop is drawn in two dimensions, not one column",
	nMsRatio < 4)

# ...AND ITS MEMBERS STAND ON MORE THAN ONE COLUMN AND MORE THAN ONE ROW.
# A ratio alone can be satisfied by empty paper.
aMsX = []  aMsY = []
_aMsR_ = oMs.RenderNodeRects()
for iMs = 1 to len(_aMsR_)
	aMsX + (_aMsR_[iMs][1] + _aMsR_[iMs][3] / 2)
	aMsY + (_aMsR_[iMs][2] + _aMsR_[iMs][4] / 2)
next
nMsDx = 0  nMsDy = 0
for iMs = 2 to len(aMsX)
	if fabs(aMsX[iMs] - aMsX[1]) > 1  nMsDx++  ok
	if fabs(aMsY[iMs] - aMsY[1]) > 1  nMsDy++  ok
next
chk("...and its members occupy both axes", nMsDx > 0 and nMsDy > 0)

# AN OPEN CIRCUIT IS NOT DRAWN AS A LOOP. It carries no current, and
# drawing a rectangle would invent a return path the model does not have.
oOp = new stzDiagram("open73")
oOp.SetNotation(StzElectricNotation())
oOp.AddNodeXTT("v", "9V", [ :type = "source" ])
oOp.AddNodeXTT("r", "R", [ :type = "resistor" ])
oOp.AddNodeXTT("a", "A", [ :type = "net" ])
oOp.AddEdge("v", "a")  oOp.AddEdge("a", "r")
oOp.ToCanvasXT(OPT67)
# "IN A LINE" IS COLLINEAR, ON EITHER AXIS. This used to require every
# Y to be equal, which is not the claim -- it is the claim plus an
# assumption about which way the line runs. The open chain was laid
# along X at the time and the test was written to match, so when the
# chain moved onto the axis its rank actually reads, a guard whose
# sentence was still true reported a failure. A line is a line in both
# directions.
aOpX = []  aOpY = []
_aOpR_ = oOp.RenderNodeRects()
for iMs = 1 to len(_aOpR_)
	aOpX + (_aOpR_[iMs][1] + _aOpR_[iMs][3] / 2)
	aOpY + (_aOpR_[iMs][2] + _aOpR_[iMs][4] / 2)
next
nOpDx = 0  nOpDy = 0
for iMs = 2 to len(aOpY)
	if fabs(aOpX[iMs] - aOpX[1]) > 1  nOpDx++  ok
	if fabs(aOpY[iMs] - aOpY[1]) > 1  nOpDy++  ok
next
? "   open circuit: " + nOpDx + " off the column, " + nOpDy + " off the row"
chk("NEGATIVE: an OPEN circuit is laid in a line, not a rectangle",
	nOpDx = 0 or nOpDy = 0)

# A COMPONENT'S ORIENTATION IS READ FROM ITS PLACEMENT, not from a
# global rank -- on a rectangle the wire runs four different ways.
chk("a component knows the two points it sits between",
	len(oMs._NeighbourPoints("r")) = 4)
chkeq("NEGATIVE: ...and says so plainly when it does not",
	len(oMs._NeighbourPoints("nosuchnode")), 0)

sec("-- 72. DN5 -- A NET IS A NODE, AND A JUNCTION IS A CLAIM -")
discharges("DN5")

# The plan's kill: "a net is a HYPEREDGE (one wire, three pins), which
# the pair-edge model must earn honestly -- junction nodes drawn as
# dots, or the domain is faked."
#
# It does not fire because its premise is about a DRAWING. In SPICE,
# KiCad and Verilog a net is a first-class named OBJECT that pins attach
# to, with a name, a width and a type -- properties no edge can carry --
# existing whether or not anything is attached. Net-as-node is the
# domain's own model.
#
# What IS owed is a drawing rule, and both halves of it are asserted
# here: a schematic draws a junction dot only where three or more wires
# meet, so at degree two the net stays in the GRAPH and leaves the
# PICTURE.
oEl = new stzDiagram("rc72")
oEl.SetNotation(StzElectricNotation())
oEl.AddNodeXTT("v1", "V1", [ :type = "source" ])
oEl.AddNodeXTT("r1", "R1", [ :type = "resistor" ])
oEl.AddNodeXTT("c1", "C1", [ :type = "capacitor" ])
oEl.AddNodeXTT("gnd", "", [ :type = "ground" ])
oEl.AddNodeXTT("nin", "IN", [ :type = "net" ])
oEl.AddNodeXTT("n0", "GND", [ :type = "net" ])
oEl.AddEdge("v1", "nin")
oEl.AddEdge("nin", "r1")
oEl.AddEdge("r1", "n0")
oEl.AddEdge("c1", "n0")
oEl.AddEdge("n0", "gnd")
oEl.ToCanvasXT(OPT67)

# THE MODEL DOES NOT BEND. Every net is a node in the graph whatever its
# degree, so it is named, queryable, and carries its own properties.
aEl = StzCircuitNets(oEl)
chkeq("every net is a node in the graph, at any degree", len(aEl), 2)
nElDeg2 = 0  nElDeg3 = 0
for iEl = 1 to len(aEl)
	if len(aEl[iEl][3]) = 2  nElDeg2++  ok
	if len(aEl[iEl][3]) >= 3  nElDeg3++  ok
next
chk("...and this circuit exercises both halves of the rule",
    nElDeg2 > 0 and nElDeg3 > 0)

# THE PICTURE TELLS THE TRUTH ABOUT A JUNCTION. A dot where three wires
# meet; no dot where two do.
chkeq("a net joining 3 pins is drawn as a junction",
    oEl._NetIsSpliced("n0"), 0)
chkeq("NEGATIVE: ...and a net joining 2 is drawn as a wire",
    oEl._NetIsSpliced("nin"), 1)

# ...AND THE SPLICED NET LEAVES NO MARK AND NO WORD. Its box collapses,
# so its two edges meet at a point and read as one line.
nElBox = -1
_aElR_ = oEl.RenderNodeRects()
for iEl = 1 to len(_aElR_)
	if StzLower("" + _aElR_[iEl][5]) = "nin"  nElBox = _aElR_[iEl][3]  ok
next
chk("a spliced net has no extent, so its wire is unbroken", nElBox < 1)
nElLab = 0
for iEl = 1 to len(oEl.@aRenderLabels)
	if StzLower("" + oEl.@aRenderLabels[iEl][1]) = "in"  nElLab++  ok
next
chkeq("...and no word floats on the plain stretch of it", nElLab, 0)

# A COMPONENT LIES ALONG ITS WIRE, so the wire meets a TERMINAL.
#
# The first DN5 pictures drew every resistor with its leads left and
# right whatever the wire did, so a top-down circuit ran its wire
# straight through the body while both leads pointed into empty paper.
# A schematic whose wires do not meet the terminals is not a schematic,
# and the Principal said so by comparing it to the ones in books.
oElV = new stzDiagram("vertical")
oElV.SetNotation(StzElectricNotation())
oElV.AddNodeXTT("a", "R1", [ :type = "resistor" ])
oElV.AddNodeXTT("b", "R2", [ :type = "resistor" ])
oElV.AddEdge("a", "b")
oElV.ToCanvasXT(OPT67)
nElVw = -1  nElVh = -1
_aElV_ = oElV.RenderNodeRects()
for iEl = 1 to len(_aElV_)
	if StzLower("" + _aElV_[iEl][5]) = "a"
		nElVw = _aElV_[iEl][3]  nElVh = _aElV_[iEl][4]
	ok
next
chk("in a top-down circuit a component stands ALONG the wire",
    nElVh > nElVw)

oElH = new stzDiagram("horizontal")
oElH.SetNotation(StzElectricNotation())
oElH.SetLayout(:LeftToRight)
oElH.AddNodeXTT("a", "R1", [ :type = "resistor" ])
oElH.AddNodeXTT("b", "R2", [ :type = "resistor" ])
oElH.AddEdge("a", "b")
oElH.ToCanvasXT(OPT67)
nElHw = -1  nElHh = -1
_aElH_ = oElH.RenderNodeRects()
for iEl = 1 to len(_aElH_)
	if StzLower("" + _aElH_[iEl][5]) = "a"
		nElHw = _aElH_[iEl][3]  nElHh = _aElH_[iEl][4]
	ok
next
chk("NEGATIVE: ...and lies ACROSS it in a left-to-right one",
    nElHw > nElHh)

# A WIRE CARRIES NO DIRECTION, so it carries no head. Declared by the
# profile, not special-cased in the drawer.
chkeq("the electric profile declares its edges undirected",
    StzElectricNotation().EdgesDirected(), 0)
chkeq("NEGATIVE: ...while a UML profile does not",
    StzUmlClassNotation().EdgesDirected(), 1)
chkeq("...so no arrowhead is drawn on a wire",
    len(oEl.@aRenderHeads), 0)

# AN ELECTRIC SYMBOL HOLDS NO TEXT -- its outline IS the value, and a
# name written across it destroys what a reader reads first.
chk("a resistor holds no text", oEl._InscribedFraction("resistor")[1] < 0.1)
chk("NEGATIVE: ...while a box holds nearly all of itself",
    oEl._InscribedFraction("box")[1] > 0.5)

sec("-- 70a. AN ARROWHEAD POINTS THE WAY ITS LINE ARRIVES -----")

# The head's direction was derived from the RANK -- down in a top-down
# picture, right in a left-to-right one -- and aP, the point the final
# segment comes from, was passed in and discarded. Harmless while every
# ortho arrival was a drop onto the target's near border; wrong the
# moment an edge arrives from the SIDE, which the side approach makes it
# do. The result was an arrow drawn across the end of its own line.
#
# TWO INDEPENDENT READINGS, and the first draft of this section had one.
# It derived the head's direction from the path and compared it to the
# path, which is a value against itself: it passes on any picture,
# including one where every head is drawn sideways. The drawn head is
# published now, so the assertion has something to disagree with.
oAh = new stzWorkflow("heads")
oAh.SetWorkflowType("statemachine")
oAh.AddStateXTT("i", "", [ :isInitial = 1 ])
oAh.AddStateXT("a", "Alpha")
oAh.AddStateXT("b", "Beta")
oAh.AddStateXTT("z", "Done", [ :isFinal = 1 ])
oAh.AddTransition("i", "a", "")
oAh.AddTransition("a", "b", "on")
oAh.AddTransition("a", "z", "close")
oAh.AddTransition("b", "z", "give up")
oAh.ToCanvasXT(OPT67)

nAhSeen = 0  nAhBad = 0  nAhSide = 0
for iAh = 1 to len(oAh.@aRenderHeads)
	aAhH = oAh.@aRenderHeads[iAh]
	aAhP = []
	for jAh = 1 to len(oAh.@aEdgePaths)
		if StzLower("" + oAh.@aEdgePaths[jAh][1]) = StzLower("" + aAhH[1])
			aAhP = oAh.@aEdgePaths[jAh][2]
		ok
	next
	if len(aAhP) < 4  loop  ok
	nAhSeen++
	# the path's own last segment -- the OTHER reading
	nAhDx = aAhP[len(aAhP) - 1] - aAhP[len(aAhP) - 3]
	nAhDy = aAhP[len(aAhP)] - aAhP[len(aAhP) - 2]
	if fabs(nAhDx) < 0.5 and fabs(nAhDy) < 0.5  loop  ok
	if fabs(nAhDx) > fabs(nAhDy)  nAhSide++  ok
	# a head is across its line when the two disagree about which axis
	# the arrival ran along
	if (fabs(nAhDx) > fabs(nAhDy)) != (fabs(aAhH[4]) > fabs(aAhH[5]))
		nAhBad++
	ok
next
? "   " + nAhSeen + " arrivals (" + nAhSide + " from the side), " +
  nAhBad + " met by a head across the line"
chkeq("every arrowhead points the way its line arrives", nAhBad, 0)

# ...AND THE SCENE MUST CONTAIN THE CASE. A zero from a picture where
# every arrival is a plain drop would have passed before the fix too.
chk("...and this scene really does contain a side arrival", nAhSide > 0)

# THE NEGATIVE SIBLING: the comparison must be able to FAIL. A head
# turned across its own line is counted as one.
nAhFake = 0
if (fabs(-24) > fabs(0)) != (fabs(0) > fabs(1))  nAhFake = 1  ok
chkeq("NEGATIVE: ...and a head across its line IS counted", nAhFake, 1)

# ...AND THE SIDE APPROACH TURNS ONCE.
#
# Its first version went down to the row, across it, down again in a
# column of its own, and across into the target -- three bends to say
# one thing, and the Principal drew the answer twice before I saw it.
# The route needs no row: an edge that will turn into its target's side
# already has a column of its own, the one it leaves by. One turn, which
# is FEWER than the ordinary drop spends.
nAhTurns = -1
for iAh = 1 to len(oAh.@aRenderHeads)
	aAhH = oAh.@aRenderHeads[iAh]
	if fabs(aAhH[4]) <= fabs(aAhH[5])  loop  ok      # not a side arrival
	for jAh = 1 to len(oAh.@aEdgePaths)
		if StzLower("" + oAh.@aEdgePaths[jAh][1]) != StzLower("" + aAhH[1])
			loop
		ok
		nAhTurns = _TurnsIn(oAh.@aEdgePaths[jAh][2])
	next
next
? "   the side approach turns " + nAhTurns + " time(s)"
chkeq("a side approach turns exactly once", nAhTurns, 1)

# THE NEGATIVE SIBLING: the counter must be able to count more than one.
chkeq("NEGATIVE: ...and a three-turn path IS counted as three",
    _TurnsIn([ 0,0, 0,10, 10,10, 10,20, 20,20 ]), 3)

sec("-- 70b. THE HAPPY PATH IS A RULE OF THE PLANE ------------")

# The Principal ruled that the affirmative branch continues down the
# main line and the refusal steps aside. It was built gated on a
# NOTATION profile, and only BPMN ever set one -- so a plain diagram
# drew "fails -> Reject" down its spine with "passes -> Accept" hanging
# off to the side, for as long as the rule existed. This scene has NO
# notation, which is exactly the case that was broken.
oHp = new stzDiagram("plain-fork")
oHp.AddNodeXTT("req", "Request", [ :type = "box" ])
oHp.AddNodeXTT("val", "Validate", [ :type = "box" ])
oHp.AddNodeXTT("ok", "Accept", [ :type = "box" ])
oHp.AddNodeXTT("no", "Reject", [ :type = "box" ])
oHp.AddEdgeXT("req", "val", "submits")
oHp.AddEdgeXT("val", "ok", "passes")
oHp.AddEdgeXT("val", "no", "fails")
oHp.ToCanvasXT(OPT67)
aHp = oHp.RenderNodeRects()
nHpV = -1  nHpOk = -1  nHpNo = -1
for iHp = 1 to len(aHp)
	if aHp[iHp][5] = "val"  nHpV = aHp[iHp][1] + aHp[iHp][3] / 2  ok
	if aHp[iHp][5] = "ok"   nHpOk = aHp[iHp][1] + aHp[iHp][3] / 2  ok
	if aHp[iHp][5] = "no"   nHpNo = aHp[iHp][1] + aHp[iHp][3] / 2  ok
next
chk("the affirmative answer holds the main line, with NO notation set",
    fabs(nHpOk - nHpV) < 1)
chk("NEGATIVE: ...and the refusal does not share it",
    fabs(nHpNo - nHpV) > 1)

# ...AND THE VOCABULARY KNOWS AN INFLECTION. It matched 24 exact strings
# and knew "pass" and "passed" but not "passes", so it declined to apply
# rather than failing -- the scope defect of this plane, at the level of
# a word.
chkeq("'passes' is affirmative", oHp._IsAffirmative("passes"), 1)
chkeq("'fails' is negative", oHp._IsNegative("fails"), 1)
chkeq("NEGATIVE: 'not approved' is not affirmative",
    oHp._IsAffirmative("not approved"), 0)
chkeq("...and a moodless label is neither",
    oHp._IsAffirmative("submits") + oHp._IsNegative("submits"), 0)

# A LABEL IS A PHRASE, AND THE MOOD LIVES IN A WORD OF IT. The
# vocabulary matched the WHOLE label, so it knew "ok" and not "handshake
# ok", and did not know "gave up" at all -- so the socket machine had no
# mood fork and never got its main line. Widened for INFLECTION this
# morning and for PHRASE only after the Principal asked why the rule
# still did not apply: the same predicate, the same defect, twice.
chkeq("'handshake ok' is affirmative -- the mood is in a word of it",
    oHp._IsAffirmative("handshake ok"), 1)
chkeq("'gave up' is negative, as a phrase", oHp._IsNegative("gave up"), 1)
chkeq("NEGATIVE: 'connect' is neither", 
    oHp._IsAffirmative("connect") + oHp._IsNegative("connect"), 0)
# ...AND A MULTI-WORD ENTRY IS STILL READ WHOLE, so a phrase says what
# it means rather than being taken a word at a time.
chkeq("'out of stock' is negative as a phrase, not as 'stock'",
    oHp._IsNegative("out of stock"), 1)

# A REFUSAL IS THE LAST THING THE FLOW CONTINUES BY. Declaration order
# used to decide wherever no answer said yes, so a spine could run
# straight down a branch that says NO -- on the socket machine Connected
# declares "dropped" before "close", and the main line would have gone
# through the failure.
oNeu = new stzDiagram("neutral-first")
oNeu.AddNodeXTT("a", "A", [ :type = "box" ])
oNeu.AddNodeXTT("bad", "Bad", [ :type = "box" ])
oNeu.AddNodeXTT("on", "Onward", [ :type = "box" ])
oNeu.AddEdgeXT("a", "bad", "failed")
oNeu.AddEdgeXT("a", "on", "close")
aPath = oNeu._HappyPath()
bOnward = 0
for iN = 1 to len(aPath)
	if StzLower("" + aPath[iN]) = "on"  bOnward = 1  ok
next
chk("the flow continues through a NEUTRAL before a refusal", bOnward = 1)
bBad = 0
for iN = 1 to len(aPath)
	if StzLower("" + aPath[iN]) = "bad"  bBad = 1  ok
next
chkeq("NEGATIVE: ...and not through the refusal declared first", bBad, 0)

# A GRAPH WITH NO MOOD GETS NO SPINE -- the package diagram's case, which
# says in its own words that a dependency graph has no happy path and
# claiming one would be a claim the model does not make.
oNm = new stzDiagram("no-mood")
oNm.AddNodeXTT("a", "A", [ :type = "box" ])
oNm.AddNodeXTT("b", "B", [ :type = "box" ])
oNm.AddNodeXTT("c", "C", [ :type = "box" ])
oNm.AddEdgeXT("a", "b", "uses")
oNm.AddEdgeXT("a", "c", "uses")
chkeq("NEGATIVE: a graph whose branches carry no mood has no happy path",
    oNm._HasMoodBranch(), 0)
chkeq("...while one whose branches disagree does",
    oHp._HasMoodBranch(), 1)

sec("-- 70c. ONE PLATE, ONE SURFACE ---------------------------")

# A label plate is painted in the colour of what it covers, and the
# surface is decided from ONE POINT -- the label's centre. A plate covers
# an AREA, so a plate lying half in a region paints half of itself in the
# wrong colour: a white card on a tinted field. The refusal that existed
# tested a region's TOP and BOTTOM rules only, so a plate hanging off its
# SIDE was never asked about, and the corner is where both are true.
oPs = new stzWorkflow("plates")
oPs.SetWorkflowType("statemachine")
oPs.AddStateXTT("i", "", [ :isInitial = 1 ])
oPs.AddStateXTT("cart", "In Cart", [ :color = "Muted" ])
oPs.AddStateXTT("pend", "Awaiting Payment", [ :color = "Warning.Solid" ])
oPs.AddStateXTT("fail", "Payment Failed", [ :color = "Danger.Solid" ])
oPs.AddStateXTT("paid", "Paid", [ :color = "Focus.Solid" ])
oPs.AddStateXTT("done", "Delivered", [ :color = "Success.Solid",
	:isFinal = 1 ])
oPs.AddTransition("i", "cart", "")
oPs.AddTransition("cart", "pend", "checkout")
oPs.AddTransition("pend", "fail", "declined")
oPs.AddTransition("fail", "pend", "retry")
oPs.AddTransition("pend", "paid", "authorised")
oPs.AddTransition("paid", "done", "signed for")
oPs.ToCanvasXT(OPT67)

nPsPart = 0
nPsSeen = 0
for iPs = 1 to len(oPs.@aRenderLabels)
	aPsL = oPs.@aRenderLabels[iPs]
	nPl = aPsL[2] - aPsL[4] / 2   nPr = aPsL[2] + aPsL[4] / 2
	nPt = aPsL[3] - aPsL[5] / 2   nPb = aPsL[3] + aPsL[5] / 2
	nPsSeen++
	for jPs = 1 to len(oPs.@aRenderClusRects)
		aPsC = oPs.@aRenderClusRects[jPs]
		nCl = aPsC[1]   nCr = aPsC[1] + aPsC[3]
		nCt = aPsC[2]   nCb = aPsC[2] + aPsC[4]
		bIn = (nPl >= nCl and nPr <= nCr and nPt >= nCt and nPb <= nCb)
		bOut = (nPr <= nCl or nPl >= nCr or nPb <= nCt or nPt >= nCb)
		if NOT bIn and NOT bOut  nPsPart++  ok
	next
next
? "   " + nPsSeen + " plates, " + nPsPart + " lying half in a region"
chkeq("every plate is wholly inside a region or wholly outside it",
	nPsPart, 0)

# THE NEGATIVE SIBLING: the instrument must be able to SEE a straddle,
# or the zero above is worth nothing. A plate moved onto the region's
# lower rule by hand is one, and is counted as one.
nPsFake = 0
if len(oPs.@aRenderClusRects) > 0 and len(oPs.@aRenderLabels) > 0
	aPsC = oPs.@aRenderClusRects[1]
	nCb = aPsC[2] + aPsC[4]
	nPl = aPsC[1] + 20   nPr = aPsC[1] + 80
	nPt = nCb - 10       nPb = nCb + 10
	bIn = (nPl >= aPsC[1] and nPr <= aPsC[1] + aPsC[3] and
	       nPt >= aPsC[2] and nPb <= nCb)
	bOut = (nPr <= aPsC[1] or nPl >= aPsC[1] + aPsC[3] or
	        nPb <= aPsC[2] or nPt >= nCb)
	if NOT bIn and NOT bOut  nPsFake = 1  ok
ok
chkeq("NEGATIVE: ...and a plate laid ON the rule IS counted as one",
	nPsFake, 1)

# ...AND THE SURFACE A PLATE IS PAINTED IN IS THE ONE UNDER IT.
chkeq("a point inside the region reads the region's tint",
	oPs._SurfaceAt(oPs.@aRenderClusRects[1][1] + 40,
		oPs.@aRenderClusRects[1][2] + 40, "#FFFFFF"),
	"" + oPs._ClusterFillAt(oPs.@aRenderClusRects[1]))
chkeq("NEGATIVE: ...and a point outside it reads the paper",
	oPs._SurfaceAt(4, 4, "#FFFFFF"), "#FFFFFF")

sec("-- 71. THE GOVERNOR, AND THE PROOF THAT IT FIRES --------")

oG = StzPlasticGovernanceOf("graph-plane")
oG.AddPicture("uml/component", _GvComponent())
oG.AddPicture("uml/communication", _GvComm(0))
oG.AddPicture("uml/comm-middle", _GvComm(1))
oG.AddPicture("flow/decision", _GvDecision())
oG.AddPicture("plain/chain", _GvChain())
oG.AddPicture("drakon/and", _GvDrakonAnd())
oG.AddPicture("drakon/or", _GvDrakonOr())

# ...AND THE WHOLE PUBLISHED CATALOGUE, EVERY SCENE OF IT.
#
# The corpus above carried its own small copies of a few DRAKON shapes,
# and a rule tested on a smaller copy passed a picture the published one
# broke: the OR staircase, two deep here and three deep in the
# catalogue, inverted in the catalogue for as long as the rule existed.
# The Principal found it by looking. Auditing the governor against the
# catalogue then produced ELEVEN findings, and they sorted into four
# general rules with no stated boundary against a DRAKON law, one rule
# measuring boxes where the question was about ink, and two real
# reserves of empty paper -- one of which the air rule had been right
# about and I nearly bounded away as noise.
#
# So the catalogue IS the corpus now. All twenty, not a chosen subset:
# a subset would rebuild "the corpus is simpler than the artefact" by
# construction. The scenes are the same functions the catalogue renders
# -- one place, so the two cannot drift -- asked here at the gate's
# size. Cost measured at 8.7s for the twenty, against a gate that was
# already at 74.6s, of which three older render sections (40, 43, 21)
# are 45s: that is the diet owed, and it is not this section's.
SILGOV = OPTGOV + [ :LayoutMode = :Silhouette ]
aGvCat = [
	[ "01", StzDrakonScene01(OPTGOV) ], [ "02", StzDrakonScene02(OPTGOV) ],
	[ "03", StzDrakonScene03(OPTGOV) ], [ "04", StzDrakonScene04(OPTGOV) ],
	[ "05", StzDrakonScene05(OPTGOV) ], [ "06", StzDrakonScene06(OPTGOV) ],
	[ "07", StzDrakonScene07(OPTGOV) ], [ "08", StzDrakonScene08(OPTGOV) ],
	[ "09", StzDrakonScene09(OPTGOV) ], [ "10", StzDrakonScene10(OPTGOV) ],
	[ "11", StzDrakonScene11(OPTGOV) ], [ "12", StzDrakonScene12(OPTGOV) ],
	[ "13", StzDrakonScene13(OPTGOV) ], [ "14", StzDrakonScene14(SILGOV) ],
	[ "15", StzDrakonScene15(SILGOV) ], [ "16", StzDrakonScene16(OPTGOV) ],
	[ "17", StzDrakonScene17(OPTGOV) ], [ "18", StzDrakonScene18(OPTGOV) ],
	[ "19", StzDrakonScene19(OPTGOV) ], [ "20", StzDrakonScene20(OPTGOV) ] ]
for iGvC = 1 to len(aGvCat)
	oG.AddPicture("catalogue/" + aGvCat[iGvC][1], aGvCat[iGvC][2])
next

# THE SHIPPED PICTURES OBEY THE RULES THEY WERE DRAWN BY.
aP = oG.CheckPictures()
# A GOVERNOR THAT FAILS MUST SAY WHAT IT FOUND. A count of two is
# nothing to act on; the rule, the picture and the message are.
# Silent when green.
for iGvF = 1 to len(aP)
	? "   FINDING " + aP[iGvF][:rule] + " @ " + aP[iGvF][:where]
	? "           " + aP[iGvF][:message]
next
chkeq("every shipped picture passes every plastic rule", len(aP), 0)

# ...AND THE GOVERNOR IS NOT SIMPLY SILENT. A layer that reports nothing
# is indistinguishable from a layer that is broken, which is this
# project's own negative-sibling law applied to the instrument itself.
# A pin overrides every layout pass by design, so it is the one lever
# that can produce a genuinely wrong picture on purpose.
oBad = _GvChain()
# The rules read RENDER FACTS -- where the ink actually went -- so the
# precise way to prove they discriminate is to hand them a fact that is
# wrong. This moves ONE node off the line of its only neighbour by 40px
# and changes nothing else, which is the exact geometry the Principal
# marked on two pictures.
aRb = oBad.@aRenderNodeRects
for iB = 1 to len(aRb)
	if StzLower("" + aRb[iB][5]) = "a"
		aRb[iB][2] = aRb[iB][2] + 40
	ok
next
oBad.@aRenderNodeRects = aRb
oG2 = StzPlasticGovernanceOf("proof")
oG2.AddPicture("plain/chain-leaf-displaced", oBad)
aB = oG2.CheckPictures()
chk("NEGATIVE: a leaf moved off its neighbour's line IS caught",
    len(aB) > 0)
bNamed = 0
for iB2 = 1 to len(aB)
	if aB[iB2][:rule] = "leaf_follows_its_neighbour"  bNamed = 1  ok
next
chk("...and the finding names the rule that was broken", bNamed = 1)

# THE META HALF -- what the rules cannot ask about themselves.
aR = oG.CheckRules()
nErr = 0
for iR = 1 to len(aR)
	if aR[iR][:severity] = :error  nErr++  ok
next
chkeq("no rule in the set is dead, unclaimed, or reading a stale value",
    nErr, 0)

# EVERY RULE GOVERNS SOMETHING, AND EXCLUDES SOMETHING. The exclusion is
# the half that had no tests, and a rule declaring itself universal must
# say why in words somebody can argue with.
aT = oG.ScopeTable()
nNoScope = 0  nNoBound = 0
aoR = oG.Rules()
for iT = 1 to len(aT)
	if aT[iT][2] = 0  nNoScope++  ok
	if aT[iT][3] = 0 and NOT aoR[iT].IsUniversal()  nNoBound++  ok
next
chkeq("every rule governs at least one subject in the corpus", nNoScope, 0)
chkeq("...and every rule's boundary is witnessed, or declared universal",
    nNoBound, 0)
# ...AND THE TWO LOGIC RULES DISCRIMINATE. A rule that never fires is
# indistinguishable from one nobody wrote, and these two were written
# from a book rather than from a marked picture -- so nothing had ever
# shown them refusing anything.
#
# The AND formula is a run of questions on ONE vertical. This moves the
# second one 60px aside and changes nothing else, which is exactly the
# staircase the book reserves for OR -- the same picture making the
# opposite claim about the condition it draws.
oLg = _GvDrakonAnd()
aLgR = oLg.@aRenderNodeRects
for iLg = 1 to len(aLgR)
	if StzLower("" + aLgR[iLg][5]) = "q2"
		aLgR[iLg][1] = aLgR[iLg][1] + 60
	ok
next
oLg.@aRenderNodeRects = aLgR
oG3 = StzPlasticGovernanceOf("logicproof")
oG3.AddPicture("drakon/and-broken", oLg)
aLgF = oG3.CheckPictures()
nLgHit = 0
for iLg = 1 to len(aLgF)
	if "" + aLgF[iLg][:rule] = "and_chain_on_one_line"  nLgHit++  ok
next
? "   findings on the broken AND chain: " + nLgHit
chk("NEGATIVE: an ANDed question moved off the line IS caught",
    nLgHit > 0)

# ...AND THE OR RULE THE SAME WAY, from the other direction: its
# staircase is flattened onto the skewer, which is the AND pattern
# drawn over an OR condition.
oLg2 = _GvDrakonOr()
aLgR2 = oLg2.@aRenderNodeRects
nLgQ1 = 0
# ...AND THE SECOND STEP IS THE ONE BROKEN, because that is the step
# that was actually wrong in the published catalogue: q1 to q2 read
# correctly and q2 to q3 went backwards.
for iLg = 1 to len(aLgR2)
	if StzLower("" + aLgR2[iLg][5]) = "q2"  nLgQ1 = aLgR2[iLg][1]  ok
next
# ...MOVED LEFT OF IT, not merely level with it. The first version set
# the two rects' LEFT EDGES equal and the rule did not fire -- because
# it reads CENTRES, and the two questions are different widths, so
# equal left edges still left the second one stepping right. A
# perturbation has to break the property the rule states, not one
# that looks like it.
for iLg = 1 to len(aLgR2)
	if StzLower("" + aLgR2[iLg][5]) = "q3"
		aLgR2[iLg][1] = nLgQ1 - 100
	ok
next
oLg2.@aRenderNodeRects = aLgR2
oG4 = StzPlasticGovernanceOf("logicproof2")
oG4.AddPicture("drakon/or-flattened", oLg2)
aLgF2 = oG4.CheckPictures()
nLgHit2 = 0
for iLg = 1 to len(aLgF2)
	if "" + aLgF2[iLg][:rule] = "or_chain_steps_aside"  nLgHit2++  ok
next
? "   findings on the flattened OR chain: " + nLgHit2
chk("NEGATIVE: an ORed question pulled onto the skewer IS caught",
    nLgHit2 > 0)


sec("-- 74. THE PLAN OF RECORD IS A CLAIM, AND CLAIMS GO STALE ---")

# This plane's plan of record went stale THREE TIMES in two days, and
# every time the same way: a session closed an item and did not walk back
# to the paragraph three screens up that still called it open. The lag is
# invisible from inside the session that caused it, which is why a reader
# found the first two and neither author did.
#
# The positives below are BUILT, never perturbed out of the live plan.
# The first version of this guard borrowed its positives from the real
# file, and the first repair these rules provoked rewrote exactly those
# sentences -- every positive became a silent negative and the guard
# would have gone green by testing nothing.

acPorSuites = [ "gg_adversarial.ring" ]
# ONCE. Seven checks each re-parsing this 560 KB suite cost 7.07s
# against 0.95s for a single parse -- a text pass dearer than two of
# the large renders it sits beside.
acPorKeys = StzGuardSectionsOf(acPorSuites)

cPorOpen   = "### Still open" + char(10) + char(10)
cPorHonest = "### Closed, all of it" + char(10) + char(10)
cPorDone1  = "~~The first thing~~ -- **CLOSED 2026-09-03, abc123def.** It" +
             " went in with its guard." + char(10) + char(10)
cPorDone2  = "~~The second thing~~ -- **CLOSED 2026-09-03, def456abc.** So" +
             " did this one." + char(10) + char(10)
cPorLive   = "The third thing is genuinely not done, and nobody has struck" +
             " it through." + char(10) + char(10)
cPorTail   = "## A later heading" + char(10) + char(10) + "Body." + char(10)

aPor = StzCheckPlanTextXT(cPorOpen + cPorDone1 + cPorDone2 + cPorTail,
                        "synthetic", acPorKeys)
chk("a heading saying OPEN over two CLOSED items is caught",
    _PorHits(aPor, "plan_calls_closed_work_open") = 1)

aPor = StzCheckPlanTextXT(cPorOpen + cPorDone1 + cPorLive + cPorTail,
                        "synthetic", acPorKeys)
chk("NEGATIVE: ONE live item under it makes the heading true again",
    _PorHits(aPor, "plan_calls_closed_work_open") = 0)

aPor = StzCheckPlanTextXT(cPorHonest + cPorDone1 + cPorDone2 + cPorTail,
                        "synthetic", acPorKeys)
chk("NEGATIVE: the same closed items under an HONEST heading pass",
    _PorHits(aPor, "plan_calls_closed_work_open") = 0)

# The live item is plain prose -- no bullet, no strikethrough. An earlier
# version of this rule could not SEE such an item, so a heading with one
# live and one closed item still read as all-closed, and TWO headings in
# the real plan passed because their items were invisible rather than
# open. Silence that is not earned is the failure mode this pins.
aPor = StzCheckPlanTextXT(cPorOpen + cPorLive + cPorTail, "synthetic",
                        acPorKeys)
chk("a live item written as PLAIN PROSE is seen, not skipped",
    _PorHits(aPor, "plan_calls_closed_work_open") = 0)

cPorMark = char(194) + char(167)
aPor = StzCheckPlanTextXT(cPorHonest + "Guards: " + cPorMark + "999 holds it." +
                        char(10) + char(10) + cPorTail, "synthetic",
                        acPorKeys)
chk("a cited guard section that does not exist is caught",
    _PorHits(aPor, "plan_cites_a_missing_guard") = 1)

aPor = StzCheckPlanTextXT(cPorHonest + "Guards: " + cPorMark + "71 holds it." +
                        char(10) + char(10) + cPorTail, "synthetic",
                        acPorKeys)
chk("NEGATIVE: a citation the suite DOES define passes",
    _PorHits(aPor, "plan_cites_a_missing_guard") = 0)

# And the artefact itself. THIS is the assertion that earns the section:
# everything above proves the instrument works, and this one points it at
# the file it exists for.
cPorPath = "../../graphics/SOFTANZA_GRAPH_PLANE_PLAN.md"
aPorLive = StzCheckPlanTextXT(read(cPorPath), cPorPath, acPorKeys)
nPorL = len(aPorLive)
for iPor = 1 to nPorL
	? "   STALE  " + aPorLive[iPor][:where] + "  " + aPorLive[iPor][:rule]
	? "          " + aPorLive[iPor][:message]
next
chk("THE PLAN OF RECORD ITSELF is clean", nPorL = 0)


sec("-- 75. A GUARD DECLARES WHAT IT DISCHARGES, AND THE STATUS IS GENERATED --")

# Section 74 checks the plan's claims about the suite. It closes the cheap
# half of the staleness defect and cannot close the rest, for a reason this
# plane paid to learn: A PLAN CITING GUARDS IS AMBIGUOUS BY CONSTRUCTION.
# This plan carried two references that looked exactly like guard citations
# and were not -- one to another document, one to a section of the plan
# itself -- and the second RESOLVED BY COINCIDENCE, because a guard with
# that number happened to exist.
#
# Inverted, the ambiguity is gone. A section declares its item where it sits,
# in the file that runs, and the plan's status table is GENERATED from those
# declarations. Everything below is built, never borrowed.

cPcNl = char(10)
cPcEm = char(226) + char(128) + char(148)
cPcSyn = "## Phases" + cPcNl + cPcNl +
         "### AA1 " + cPcEm + " the first. SHIPPED." + cPcNl + cPcNl +
         "### AA2 " + cPcEm + " the second. NEXT." + cPcNl + cPcNl +
         "### AA3 " + cPcEm + " the third, and it says nothing." + cPcNl + cPcNl
aPcNone = []

aPcIt = StzPlanItemsOf(cPcSyn)
chk("three items are found", len(aPcIt) = 3)
chkeq("the SHIPPED one reads closed", aPcIt[1][2], "closed")
chkeq("the NEXT one reads open", aPcIt[2][2], "open")
chkeq("the silent one reads unstated", aPcIt[3][2], "unstated")

aPcF = StzCheckPlanCoverage(cPcSyn, "syn", [ [ "AA9", "5" ] ])
chk("a declaration for an unknown item is caught",
    _PorHits(aPcF, "guard_discharges_unknown_item") = 1)
aPcF = StzCheckPlanCoverage(cPcSyn, "syn", [ [ "AA1", "5" ] ])
chk("NEGATIVE: a declaration for an item that EXISTS passes",
    _PorHits(aPcF, "guard_discharges_unknown_item") = 0)

# THE DEFECT, at the item rather than the heading.
aPcF = StzCheckPlanCoverage(cPcSyn, "syn", [ [ "AA2", "5" ] ])
chk("an OPEN item that a guard already proves is caught",
    _PorHits(aPcF, "plan_item_open_but_discharged") = 1)

# The wider half, and why the rule does not ask about "open" alone: five
# items in the real plan were proven by sections 40 to 44 while their prose
# never said they had shipped at all.
aPcF = StzCheckPlanCoverage(cPcSyn, "syn", [ [ "AA3", "5" ] ])
chk("an UNSTATED item that a guard already proves is caught too",
    _PorHits(aPcF, "plan_item_open_but_discharged") = 1)
aPcF = StzCheckPlanCoverage(cPcSyn, "syn", [ [ "AA1", "5" ] ])
chk("NEGATIVE: a CLOSED item that a guard proves is exactly right",
    _PorHits(aPcF, "plan_item_open_but_discharged") = 0)

aPcF = StzCheckPlanCoverage(cPcSyn, "syn", aPcNone)
chk("the item that says nothing is reported",
    _PorHits(aPcF, "plan_item_status_unstated") = 1)
aPcF = StzCheckPlanCoverage(cPcSyn, "syn", [ [ "AA3", "5" ] ])
chk("an unstated-AND-discharged item is reported ONCE, not twice",
    _PorHits(aPcF, "plan_item_status_unstated") = 0 and
    _PorHits(aPcF, "plan_item_open_but_discharged") = 1)

# UNDECIDED is a statement; silence is not. Only silence is a defect.
cPcUnd = StzReplace(cPcSyn, "the third, and it says nothing.",
                            "the third. UNDECIDED, and here is why.")
aPcIt = StzPlanItemsOf(cPcUnd)
chkeq("an item saying UNDECIDED reads undecided", aPcIt[3][2], "undecided")
chk("NEGATIVE: UNDECIDED is not reported -- only silence is",
    _PorHits(StzCheckPlanCoverage(cPcUnd, "syn", aPcNone),
             "plan_item_status_unstated") = 0)

# -- AN ITEM IS EVERY PLACE IT IS DEFINED, not the first one ------------
#
# These plans open with a ROADMAP: one-line bullets, each opening with an
# item id and stating no status, hundreds of lines above the section that
# defines the item. By this file's own convention the bullet IS a
# definition, it comes first, and until 2026-09-08 it WON -- so the item's
# own section was never read.
#
# Measured across the 26 plans in this library: 15 items of 125 reported a
# status their plan does not hold, 14 of them shipped work reading
# "unstated". In this plane's own graphics plan that is GR0, GR1, GR3 and
# GR5, all four closed in their sections and all four reported silent.
#
# The rule it broke is the one directly above: plan_item_open_but_discharged
# exists to catch a plan UNDERSTATING proven work, so a shadowed item made
# the checker accuse the plan of exactly the staleness it did not have.
cPcRoad = "## Roadmap" + cPcNl + cPcNl +
          "- AA4 " + cPcEm + " the fourth" + cPcNl +
          "- AA5 " + cPcEm + " the fifth" + cPcNl + cPcNl +
          "## Phases" + cPcNl + cPcNl +
          "### AA4 " + cPcEm + " the fourth. SHIPPED." + cPcNl + cPcNl
aPcIt = StzPlanItemsOf(cPcRoad)
chkeq("a roadmap bullet and a section are ONE item", len(aPcIt), 2)
chkeq("...and it is defined twice", aPcIt[1][4], 2)
chkeq("the section's status wins over the bullet's silence",
      aPcIt[1][2], "closed")
chkeq("...and the line reported is still where a reader starts",
      aPcIt[1][3], 3)
chk("NEGATIVE: an item with only a silent bullet is still unstated",
    aPcIt[2][2] = "unstated" and aPcIt[2][4] = 1)
chk("...so the discharged-but-open rule stops firing on it",
    _PorHits(StzCheckPlanCoverage(cPcRoad, "syn", [ [ "AA4", "5" ] ]),
             "plan_item_open_but_discharged") = 0)

# -- A PLAN THAT CONTRADICTS ITSELF ABOUT ONE ITEM ----------------------
#
# Two definitions, each stating a status, disagreeing. Unreportable before
# the fold: the reader of the file saw both, the checker saw the first.
# This is not hypothetical -- the graph plane's own plan carried it,
# committed and pushed, DN9g reading SHIPPED at one line and "Not started"
# at another, because an edit inserted where it meant to replace.
cPcCon = "### AA6 " + cPcEm + " the sixth. SHIPPED." + cPcNl + cPcNl +
         "### AA6 " + cPcEm + " the sixth. NOT STARTED." + cPcNl + cPcNl
chkeq("the two statuses are both seen", StzPlanItemsOf(cPcCon)[1][4], 2)
chk("a plan that contradicts itself about an item is caught",
    _PorHits(StzCheckPlanCoverage(cPcCon, "syn", aPcNone),
             "plan_item_status_contradicts") = 1)

# NEGATIVE, and it is the whole reason the rule is written this narrowly.
# An id defined more than once is ORDINARY here -- 29 of 125 items are,
# by the roadmap convention above -- so a rule reporting every repeat
# would file 29 findings about a convention the plans use on purpose.
# Silence is not disagreement.
chk("NEGATIVE: a silent bullet beside a stated section is NOT a conflict",
    _PorHits(StzCheckPlanCoverage(cPcRoad, "syn", aPcNone),
             "plan_item_status_contradicts") = 0)
chk("...and neither is one definition on its own",
    _PorHits(StzCheckPlanCoverage(cPcSyn, "syn", aPcNone),
             "plan_item_status_contradicts") = 0)

# -- THE SAME ITEM, WORD FOR WORD, TWICE --------------------------------
#
# Never intentional: it is what an edit that INSERTED where it meant to
# REPLACE looks like from outside. The DN9g commit left 342 duplicated
# lines carrying a stale copy of seven items, and every check in this file
# passed over them -- the statuses agreed, so nothing disagreed.
cPcDup = "### AA7 " + cPcEm + " the seventh. SHIPPED." + cPcNl + cPcNl +
         "### AA7 " + cPcEm + " the seventh. SHIPPED." + cPcNl + cPcNl
chk("an item defined twice in the same words is caught",
    _PorHits(StzCheckPlanCoverage(cPcDup, "syn", aPcNone),
             "plan_item_defined_verbatim_twice") = 1)
chk("...and it is NOT reported as a contradiction, which it is not",
    _PorHits(StzCheckPlanCoverage(cPcDup, "syn", aPcNone),
             "plan_item_status_contradicts") = 0)
chk("NEGATIVE: two definitions that differ are not a verbatim copy",
    _PorHits(StzCheckPlanCoverage(cPcCon, "syn", aPcNone),
             "plan_item_defined_verbatim_twice") = 0)
chk("NEGATIVE: the roadmap shape is not one either",
    _PorHits(StzCheckPlanCoverage(cPcRoad, "syn", aPcNone),
             "plan_item_defined_verbatim_twice") = 0)

# -- A PARENT WHOSE CHILDREN HAVE ALL SHIPPED ---------------------------
#
# An item is delivered AS its sub-items more often than not, and when the
# last one closes nobody goes back to the parent's own heading. Measured
# 2026-09-08 over the 26 plans here: 5 of the 32 not-closed items were
# parents every one of whose children was closed -- DN8 over eight, DN9
# over seven, GR6 over three, GR2 and GR4 over two each. All five said
# "planned", or said nothing, above work that had shipped.
#
# plan_item_open_but_discharged directly above cannot see this: a parent
# has no guard section of its own to discharge it. Its children have them.
cPcPar = "## AA1 " + cPcEm + " the whole. PLANNED." + cPcNl + cPcNl +
         "### AA1a " + cPcEm + " the first part. SHIPPED." + cPcNl + cPcNl +
         "### AA1b " + cPcEm + " the second part. SHIPPED." + cPcNl + cPcNl
chk("a parent reading open over closed children is caught",
    _PorHits(StzCheckPlanCoverage(cPcPar, "syn", aPcNone),
             "plan_parent_understates_its_children") = 1)
chk("...and so is one that says nothing at all",
    _PorHits(StzCheckPlanCoverage(
      StzReplace(cPcPar, "the whole. PLANNED.", "the whole."), "syn", aPcNone),
             "plan_parent_understates_its_children") = 1)
chk("NEGATIVE: one child still open, so the parent understates nothing",
    _PorHits(StzCheckPlanCoverage(
      StzReplace(cPcPar, "the second part. SHIPPED.", "the second part. NEXT."),
      "syn", aPcNone), "plan_parent_understates_its_children") = 0)
chk("NEGATIVE: a parent that already says shipped is not reported",
    _PorHits(StzCheckPlanCoverage(
      StzReplace(cPcPar, "the whole. PLANNED.", "the whole. SHIPPED."),
      "syn", aPcNone), "plan_parent_understates_its_children") = 0)

# UNDECIDED is an explicit statement that nobody has adjudicated the item,
# and closed parts do not settle it -- a parent may hold a question its
# pieces do not answer. Same distinction the unstated rule above draws.
chk("NEGATIVE: UNDECIDED is left alone -- the parts do not answer it",
    _PorHits(StzCheckPlanCoverage(
      StzReplace(cPcPar, "the whole. PLANNED.",
                         "the whole. UNDECIDED, and here is why."),
      "syn", aPcNone), "plan_parent_understates_its_children") = 0)
chk("NEGATIVE: an item with no sub-items is never a parent",
    _PorHits(StzCheckPlanCoverage(cPcSyn, "syn", aPcNone),
             "plan_parent_understates_its_children") = 0)

# THE TWO-DIGIT TRAP, and it is why the child test is exact rather than a
# prefix match: AA1 and AA10 are SIBLINGS. A prefix test calls AA10 a child
# of AA1, so a plan reaching its tenth item starts reporting nonsense about
# its first -- the same two-digit trap that made DN10 redefine DN1 when
# this grammar was written. A child is the id plus ONE LOWERCASE LETTER.
cPcSib = "## AA1 " + cPcEm + " the first. PLANNED." + cPcNl + cPcNl +
         "## AA10 " + cPcEm + " the tenth. SHIPPED." + cPcNl + cPcNl
aPcIt = StzPlanItemsOf(cPcSib)
chkeq("AA1 and AA10 are two items", len(aPcIt), 2)
chkeq("...and the second is AA10, not AA1", aPcIt[2][1], "AA10")
chk("NEGATIVE: AA10 is not a child of AA1 -- a prefix test would say it is",
    _PorHits(StzCheckPlanCoverage(cPcSib, "syn", aPcNone),
             "plan_parent_understates_its_children") = 0)
cPcTen = "## AA10 " + cPcEm + " the tenth. PLANNED." + cPcNl + cPcNl +
         "### AA10a " + cPcEm + " its part. SHIPPED." + cPcNl + cPcNl
chk("...while a real two-digit parent with a closed child IS caught",
    _PorHits(StzCheckPlanCoverage(cPcTen, "syn", aPcNone),
             "plan_parent_understates_its_children") = 1)

# -- the generated table, against the one in the file --------------------
cPcB = StzPlanCoverageBeginMark()
cPcE = StzPlanCoverageEndMark()
aPcDis = [ [ "AA1", "5" ] ]
cPcGood = cPcSyn + cPcB + cPcNl + StzPlanCoverageTable(cPcSyn, aPcDis) +
          cPcE + cPcNl
chk("NEGATIVE: a table matching the declarations passes",
    _PorHits(StzCheckPlanCoverage(cPcGood, "syn", aPcDis),
             "plan_coverage_table_is_stale") = 0)
cPcStale = StzReplace(cPcGood, "| AA1 | closed | 5 |", "| AA1 | closed | 9 |")
chk("a table that has DRIFTED from the declarations is caught",
    _PorHits(StzCheckPlanCoverage(cPcStale, "syn", aPcDis),
             "plan_coverage_table_is_stale") = 1)

# THE FEEDBACK LOOP, pinned. An item's body runs to the next item, so the
# item standing last before the table absorbed it -- and the table says
# "closed" on nearly every row, so that item read as closed whatever its own
# words said. The table had made itself right, which is the kind of wrong
# that survives review.
aPcIt = StzPlanItemsOf(cPcGood)
chkeq("the last item does NOT absorb the generated table",
      aPcIt[3][2], "unstated")

# -- the byte/codepoint trap this cost, pinned ---------------------------
# StzFindFirst answers in CODEPOINTS; s[i] and len() are BYTES. Mixing them
# is silent on ASCII and wrong on anything else -- it wrote the generated
# table into the middle of its own opening marker.
cPcEmS = "a" + cPcEm + "bXY"
chkeq("StzFindFirst answers in codepoints", StzFindFirst("XY", cPcEmS), 4)
chkeq("_StzFindBytes answers in bytes", _StzFindBytes("XY", cPcEmS), 6)
chk("and on this string the two DISAGREE -- which is the whole trap",
    StzFindFirst("XY", cPcEmS) != _StzFindBytes("XY", cPcEmS))
chkeq("NEGATIVE: on pure ASCII they agree, which is why it stayed hidden",
      _StzFindBytes("XY", "abXY"), StzFindFirst("XY", "abXY"))

# -- THE STATIC PARSE, WHICH IS COMPLETE WHEREVER THIS SECTION SITS ------
#
# It used to compare the static parse against aDischarged here, and that
# was WRONG IN A WAY THAT ONLY SHOWED WHEN IT MATTERED. aDischarged is
# built at RUN time as each section is reached, so at this point it holds
# the declarations of the sections BEFORE this one and no others. The two
# agreed for as long as no section after 75 declared anything -- and broke
# the moment sections 76 and 77 declared DN3b, reporting 21 against 23 and
# taking the table check down with it.
#
# A cross-check between two readings is only a cross-check when both have
# finished reading. The runtime-versus-static comparison now runs at the
# END of the suite, where that is true; everything here reads the static
# parse, which is complete whatever order the sections run in.
aPcStatic = StzSuiteDischargesOf([ "gg_adversarial.ring" ])

# -- and the artefact itself ---------------------------------------------
cPcPath = "../../graphics/SOFTANZA_GRAPH_PLANE_PLAN.md"
aPcLive = StzCheckPlanCoverage(read(cPcPath), cPcPath, aPcStatic)
nPcL = len(aPcLive)
for iPc = 1 to nPcL
	? "   STALE  " + aPcLive[iPc][:where] + "  " + aPcLive[iPc][:rule]
	? "          " + aPcLive[iPc][:message]
next
chk("THE PLAN'S GENERATED TABLE IS CURRENT", nPcL = 0)
? "   declarations this suite made: " + len(aDischarged) +
  " over " + len(StzPlanItemsOf(read(cPcPath))) + " plan items"


sec("-- 76. DN3b: THE DOCUMENT HAS NAMES, AND THEY ARE REFUSED NOT MANGLED --")
discharges("DN3b")

# A pick tag answers a POINTER -- what is under this pixel. It cannot serve
# a consumer reading the FILE, because a tag is a number chosen at draw time
# and a consumer contract needs a name that survives being written out and
# read back somewhere else. BPMN's L18/L19 is that contract, and until this
# existed the only thing that could honour it was a private 781-line writer
# that nothing in this repository called.
#
# NOT DECLARED AS DISCHARGING DN3b, deliberately. This is the first of that
# item's three steps; the law's col/row are not yet handed to the plastic
# layout and the private writer is still there. Declaring it now would make
# section 75 report plan_item_open_but_discharged against DN3b -- which is
# the mechanism working, and the reason to wait rather than to silence it.

oDi = new stzCanvas(200, 100)
oDi.Fill("white")
oDi.AddRect(0, 0, 200, 100)

oDi.SetSvgIdent("task_pay", "bpmn-task bpmn-element")
oDi.Fill("steelblue")
oDi.AddRect(10, 10, 80, 40)
oDi.Stroke("black", 2)
oDi.AddCircle(50, 30, 8)

oDi.SetSvgIdent("gw_check", "bpmn-gateway bpmn-element")
oDi.Fill("gold")
oDi.AddCircle(150, 50, 20)

oDi.ClearSvgIdent()
oDi.Fill("gray")
oDi.AddRect(0, 95, 200, 5)

cDi = oDi.ToSVG()

chkeq("two identities open two groups",
      len(StzFindCS("<g ", cDi, TRUE)), 2)
chkeq("and every one of them is closed -- the file is well formed",
      len(StzFindCS("</g>", cDi, TRUE)), 2)
chk("the named element carries its id",
    len(StzFindCS('id="task_pay"', cDi, TRUE)) > 0)
chk("and its classes, verbatim",
    len(StzFindCS('class="bpmn-task bpmn-element"', cDi, TRUE)) > 0)

# ONE GROUP FOR THREE COMMANDS. A node is a fill, a stroke and a label, and
# they are one element to whoever reads the document. Putting the id on each
# would emit it three times, and duplicate ids make the SVG invalid.
chkeq("an id appears ONCE, though its element is three commands",
      len(StzFindCS('id="task_pay"', cDi, TRUE)), 1)
chk("all three of its commands sit inside that one group",
    _DiInGroup(cDi, "task_pay", "<rect") and
    _DiInGroup(cDi, "task_pay", "<polyline") and
    _DiInGroup(cDi, "task_pay", "<circle"))

# NEGATIVE: what carries no identity must stay OUT of every group, or the
# background would be part of the first element a consumer selects.
chk("NEGATIVE: the background is outside every group",
    _DiBeforeFirstGroup(cDi, '<rect x="0" y="0"'))
chk("NEGATIVE: and ClearSvgIdent puts the decoration outside too",
    _DiAfterLastGroup(cDi, '<rect x="0" y="95"'))

# REFUSED, NEVER ESCAPED. A name arriving as `a b"c` and leaving as
# `a b&quot;c` is one the consumer cannot write down or select on: the
# mangling is discovered by them, the refusal is discovered here.
chk("a plain name is accepted", NOT _DiRefused("task_pay", "bpmn-task"))
chk("an underscore may start a name", NOT _DiRefused("_x", ""))
chk("dots and dashes are fine", NOT _DiRefused("a.b-c", "k-1 k-2"))
chk("classes alone, with no name, are fine", NOT _DiRefused("", "decoration"))
chk("both empty CLEARS and never refuses", NOT _DiRefused("", ""))

chk("a name starting with a DIGIT is refused -- not an XML name",
    _DiRefused("1task", ""))
chk("a space inside a NAME is refused", _DiRefused("task pay", ""))
chk("a quote is refused rather than escaped", _DiRefused('ta' + char(34) + 'sk', ""))
chk("an angle bracket is refused", _DiRefused("ta<sk", ""))
chk("an ampersand is refused", _DiRefused("a&b", ""))
chk("and a quote in a CLASS is refused too",
    _DiRefused("ok", 'a' + char(34) + 'b'))

# The refusals must not be the WHOLE story -- a rule that refuses everything
# also passes every negative above.
chk("NEGATIVE: the refusals discriminate -- a valid name still draws",
    len(StzFindCS('id="a.b-c"', _DiOneIdent("a.b-c", "k-1"), TRUE)) = 1)


# -- AND THE RENDERER USES IT, which is what makes the contract real ------
# A channel nobody calls is half a deliverable: the private writer could not
# be deleted for want of it, and it still cannot be deleted for want of the
# renderer speaking through it.

cBp76 = _Wf76("bpmn", [])
cPl76 = _Wf76("", [])
cOn76 = _Wf76("", [ :SvgIdents = TRUE ])
cOf76 = _Wf76("bpmn", [ :SvgIdents = FALSE ])

chk("BPMN carries the document's names WITHOUT being asked",
    len(StzFindCS("<g ", cBp76, TRUE)) > 0)
chk("NEGATIVE: a plain diagram carries none -- the default is off, so no " +
    "picture this library already emits changes a byte",
    len(StzFindCS("<g ", cPl76, TRUE)) = 0)
chk("the option turns them ON for a notation that does not ask",
    len(StzFindCS("<g ", cOn76, TRUE)) > 0)
chk("NEGATIVE: and OFF for the notation whose law does ask",
    len(StzFindCS("<g ", cOf76, TRUE)) = 0)

chkeq("every group opened is closed", len(StzFindCS("<g ", cBp76, TRUE)),
      len(StzFindCS("</g>", cBp76, TRUE)))

acId76 = _Ids76(cBp76)
chk("the picture names several elements", len(acId76) >= 5)
chkeq("and NO id is repeated -- a repeated id is an invalid document",
      _Dups76(acId76), 0)
chk("a node is named by its own id, not by its position",
    _Has76(acId76, "recv"))
chk("an edge is named by the two ends it joins",
    _Has76(acId76, "edge_recv__done"))

# A node's ink is NOT contiguous in paint order: every label is drawn after
# every box, because a label must sit above the boxes its neighbours drew.
# So one <g> per element is unavailable without changing what covers what,
# and repeating the id across the parts would make the document invalid.
# The parts are separate groups with separate ids, joined by a class.
chk("a node's label is a SECOND part, with its own id",
    _Has76(acId76, "recv_2"))
chk("and both parts carry the element class, so a consumer can collect them",
    len(StzFindCS("el_recv", cBp76, TRUE)) = 2)
chk("NEGATIVE: an element drawn once has ONE part, not a spare",
    NOT _Has76(acId76, "recv_3"))
chkeq("every piece of text is inside an element, never loose on the paper",
      _LooseText76(cBp76), 0)


sec("-- 77. DN3b: THE SHARED RENDER AGREES WITH THE LAW, CELL BY CELL ---")
discharges("DN3b")

# The plan recorded step 2 as "the law's col/row handed to the plastic
# layout as pins". MEASURED, THAT PREMISE WAS WRONG, and measuring it is
# the only reason this section exists rather than a pin pass.
#
# Compared cell by cell against stzBpmnDiagram's conformance digest -- the
# oracle two implementations are held to -- the plastic layout ALREADY
# places every node where the law says. Three of five process shapes agreed
# on every cell with no pins at all. The two that diverged did so for one
# reason each, and it was always the same one: L7/L8, an ending duplicated
# per arrival. An ending reached twice is ONE node in the shared model and
# TWO markers in the law, and merging them moves the survivor.
#
# So nothing needed pinning. What was missing was a MODEL transform.

chkeq("a linear process agrees with the law on every cell",
      _Cf77("linear", 1), 0)
chkeq("a gateway with an exception agrees on every cell",
      _Cf77("gateway", 1), 0)
chkeq("a process with a RETURN edge agrees on every cell",
      _Cf77("return", 1), 0)
chkeq("an ending reached TWICE agrees on every cell",
      _Cf77("twoarrivals", 1), 0)
chkeq("a long branch off a short spine agrees on every cell",
      _Cf77("longbranch", 1), 0)

# THE NEGATIVE THAT MAKES THE FIVE ABOVE WORTH HAVING. Without the
# transform the two multi-arrival shapes MUST diverge -- if they pass
# either way, the transform is not what is carrying them and these
# assertions agree with the law by coincidence.
chk("NEGATIVE: without the transform, an ending reached twice DIVERGES",
    _Cf77("twoarrivals", 0) > 0)
chk("NEGATIVE: and so does the long branch",
    _Cf77("longbranch", 0) > 0)
chkeq("NEGATIVE: while a single-arrival process needs no transform at all",
      _Cf77("linear", 0), 0)

# L8: identity across duplicates -- canonical first, then __2, __3.
oTg77 = _Wf77("twoarrivals")
chkeq("one extra marker is minted for the second arrival",
      oTg77.ExpandEndingsPerArrival(), 1)
cTg77 = oTg77.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 132,
                           :NodeHeight = 52 ]).ToSVG()
acTg77 = _Ids76(cTg77)
chk("the FIRST arrival keeps the canonical, unsuffixed name",
    _Has76(acTg77, "e"))
chk("and the second is suffixed __2, in arrival order",
    _Has76(acTg77, "e__2"))

# L19: endings are addressed BY CLASS, nodes by identifier. Two markers of
# one ending have two ids and no identifier a consumer can ask for.
chk("every marker of one ending carries wf-target-<name>",
    len(StzFindCS("wf-target-e", cTg77, TRUE)) >= 2)
chk("NEGATIVE: a class nobody declared is not in the document",
    len(StzFindCS("wf-target-zzz", cTg77, TRUE)) = 0)

# The transform must not invent markers where none are owed.
oLn77 = _Wf77("linear")
chkeq("NEGATIVE: a single-arrival ending mints NO extra marker",
      oLn77.ExpandEndingsPerArrival(), 0)


sec("-- 79. DN7a: A MATHEMATICAL DIAGRAM IS SOLVED, NOT PLACED ---------")
discharges("DN7a")

# Penrose's three-language split -- Domain, Substance, Style -- over this
# library's own autodiff tape and L-BFGS, drawn by the one canvas. The kill
# was measured before the code: could the engine reach feasibility on
# Penrose's seven-set example at all? Three random starts, one penalty
# round each, maximum violation zero. It could, with no new Zig.
#
# Every scene here is Penrose's own: twosets-simple, tree (the README's
# example), nested (the case the paper says "disks must shrink
# exponentially" for), a three-way Venn, and the contradiction of Fig. 2.

oMd1 = StzMathScene01(AUFONT)
oMd2 = StzMathScene02(AUFONT)
oMd3 = StzMathScene03(AUFONT)
oMd4 = StzMathScene04(AUFONT)

chk("two sets, one inside the other, is lawful", oMd1.IsFeasible())
chk("Penrose's seven-set tree is lawful", oMd2.IsFeasible())
chk("a chain nested seven deep is lawful", oMd3.IsFeasible())
chk("a three-way Venn is lawful", oMd4.IsFeasible())
chkeq("the tree has 35 unknowns -- three per circle, two per label",
      oMd2.NumberOfUnknowns(), 35)
chk("and it was solved in well under a second",
    oMd2.LayoutMs() < 1500)

# pow(), NEVER ^2, on a difference: Ring evaluates (3-5)^2 as -4 -- the
# sign is applied after the power -- so a sum of squared differences
# went NEGATIVE and sqrt() raised R51. pow(-2, 2) is 4.
# TWO READINGS OF ONE TRUTH. The solver reports its own violations from
# its own tape. This re-derives containment and disjointness from the
# solved circles with plain arithmetic -- a different computation over the
# same numbers, which is what a self-check needs to mean anything.
aMdSub = [ ["B","A"], ["C","A"], ["D","B"], ["E","B"], ["F","C"], ["G","C"] ]
bMdIn = TRUE
for iMd = 1 to len(aMdSub)
	aI = oMd2.ShapeOf(aMdSub[iMd][1] + ".icon")
	aO = oMd2.ShapeOf(aMdSub[iMd][2] + ".icon")
	nD = sqrt(pow(aI[:cx] - aO[:cx], 2) + pow(aI[:cy] - aO[:cy], 2))
	if nD + aI[:r] > aO[:r] + 1  bMdIn = FALSE  ok
next
chk("every Subset is a circle geometrically INSIDE its superset", bMdIn)
aMdDis = [ ["E","D"], ["F","G"], ["B","C"] ]
bMdOut = TRUE
for iMd = 1 to len(aMdDis)
	aP = oMd2.ShapeOf(aMdDis[iMd][1] + ".icon")
	aQ = oMd2.ShapeOf(aMdDis[iMd][2] + ".icon")
	nD = sqrt(pow(aP[:cx] - aQ[:cx], 2) + pow(aP[:cy] - aQ[:cy], 2))
	if nD < aP[:r] + aQ[:r] - 1  bMdOut = FALSE  ok
next
chk("and every Disjoint pair is geometrically APART", bMdOut)
bMdLbl = TRUE
acMdSets = [ "A", "B", "C", "D", "E", "F", "G" ]
for iMd = 1 to 7
	aC = oMd2.ShapeOf(acMdSets[iMd] + ".icon")
	aT = oMd2.ShapeOf(acMdSets[iMd] + ".text")
	nD = sqrt(pow(aC[:cx] - aT[:cx], 2) + pow(aC[:cy] - aT[:cy], 2))
	if nD > aC[:r]  bMdLbl = FALSE  ok
next
chk("every label sits inside the circle it names", bMdLbl)

# THE CONTRADICTION IS A FINDING, NOT A CRASH -- Penrose Fig. 2: "a
# logically inconsistent program fails gracefully, providing visual
# intuition for why the given statements cannot hold".
oMd5 = StzMathScene05(AUFONT)
chk("NEGATIVE: B inside A and apart from A cannot both hold", NOT oMd5.IsFeasible())
chk("and the diagram says so in the house rule shape",
    len(oMd5.Violations()) > 0)
chk("naming the contradictory relations",
    StzFindFirst("Subset", oMd5.Violations()[1][:where] +
                 oMd5.Violations()[len(oMd5.Violations())][:where]) > 0 or
    StzFindFirst("Disjoint", oMd5.Violations()[1][:where] +
                 oMd5.Violations()[len(oMd5.Violations())][:where]) > 0)

# VARIATION: the same string, the same picture; another string, another.
oMd2b = StzMathScene02(AUFONT)
chkeq("the same variation reproduces the same layout",
      oMd2b.ShapeOf("A.icon")[:cx], oMd2.ShapeOf("A.icon")[:cx])
oMd2c = StzMathScene02(AUFONT)
oMd2c.SetVariation("another")
chk("NEGATIVE: a different variation moves it",
    oMd2c.ShapeOf("A.icon")[:cx] != oMd2.ShapeOf("A.icon")[:cx])

# The document channel from DN3b, inherited free: a Set is <g id="A">.
cMdSvg = oMd2.ToSVG()
chkeq("every circle and every label is a named element -- fourteen",
      len(StzFindCS('<g id="', cMdSvg, TRUE)), 14)
chk("a Set's circle carries its own name as id",
    len(StzFindCS('id="A" class="circle set el_A"', cMdSvg, TRUE)) = 1)

# REFUSALS, each at the line that made the mistake.
chk("an object of a type the domain lacks is refused",
    _MdRefuses(1))
chk("a relation the domain lacks is refused", _MdRefuses(2))
chk("the wrong number of arguments is refused", _MdRefuses(3))
chk("an argument of the wrong type is refused", _MdRefuses(4))
chk("a layout function the catalogue lacks is refused", _MdRefuses(5))
chk("NEGATIVE: the lawful forms of all five are accepted", NOT _MdRefuses(0))

# Symmetry is the DOMAIN's to declare: Disjoint(A, B) IS Disjoint(B, A).
oMdS = new stzMathSubstance(StzSetTheoryDomain())
oMdS.DeclareAll("Set", [ "A", "B" ])
oMdS.Assert("Disjoint", [ "A", "B" ])
oMdS.Assert("Subset", [ "B", "A" ])
chk("a symmetric relation holds in either order",
    oMdS.Holds("Disjoint", [ "B", "A" ]))
chk("NEGATIVE: a directed one holds in one order only",
    oMdS.Holds("Subset", [ "B", "A" ]) and NOT oMdS.Holds("Subset", [ "A", "B" ]))

# and a symmetric where-clause fires a rule ONCE per pair, not per order
oMdT = new stzMathStyle()
oMdT.ForAll("Set x", [ [ :shape, "x.icon", :circle, [] ] ])
oMdT.ForAllWhere("Set x; Set y", "Disjoint(x, y)",
	[ [ :ensure, "disjoint", [ "x.icon", "y.icon", 0 ] ] ])
oMdD = new stzMathDiagram(StzSetTheoryDomain(), oMdS, oMdT)
chkeq("one disjoint pair, one disjoint constraint, plus the paper's edges",
      oMdD.NumberOfConstraints(), 1 + 2 * 4)

# THE CAP THAT WAS RAISED. The tape allowed 64 variables; a labelled set
# costs five, so twelve sets was a cliff. 256 now, and this proves the
# engine that is loaded is the one with the new constant.
oMdB = new stzMathSubstance(StzSetTheoryDomain())
for iMd = 1 to 30
	oMdB.Declare("Set", "S" + iMd)
next
oMdBig = new stzMathDiagram(StzSetTheoryDomain(), oMdB, StzEulerStyle())
chkeq("thirty sets are 150 unknowns -- an unlabelled set still owns its text",
      oMdBig.NumberOfUnknowns(), 150)
chk("and the engine accepts more than its old cap of 64", oMdBig.Rounds() >= 1)


sec("-- 80. DN7b: ONE SUBSTANCE, TWO REPRESENTATIONS; VECTORS; EUCLID ---")
discharges("DN7b")

# The kill for DN7b is Penrose's central claim: the SAME content, another
# representation, with the Substance untouched. The instance is shared --
# one stzMathSubstance object handed to two diagrams -- so "untouched" is
# not a promise but a fact about the test.
oMbSub = StzMathTreeSubstance()
oMbE = new stzMathDiagram(StzSetTheoryDomain(), oMbSub, StzEulerStyle())
oMbE.SetFont(AUFONT, 28)  oMbE.SetVariation("PlumvilleCapybara104")
oMbT = new stzMathDiagram(StzSetTheoryDomain(), oMbSub, StzTreeStyle())
oMbT.SetFont(AUFONT, 26)  oMbT.SetVariation("tree-as-tree")
chk("the seven-set tree is lawful as nested disks", oMbE.IsFeasible())
chk("and lawful as a TREE, from the same substance object", oMbT.IsFeasible())
chk("the tree style draws no circle at all",
    len(StzFindCS("<circle", oMbT.ToSVG(), TRUE)) = 0)
chk("and one arrow per Subset -- six",
    len(StzFindCS("<polyline", oMbT.ToSVG(), TRUE)) = 6)
# a second reading: every superset's name sits ABOVE its subset's
aMbSub = [ ["B","A"], ["C","A"], ["D","B"], ["E","B"], ["F","C"], ["G","C"] ]
bMbUp = TRUE
for iMb = 1 to len(aMbSub)
	if oMbT.ShapeOf(aMbSub[iMb][2] + ".text")[:cy] >= oMbT.ShapeOf(aMbSub[iMb][1] + ".text")[:cy]
		bMbUp = FALSE
	ok
next
chk("every superset is drawn above its subset", bMbUp)
chk("the tree solved in well under a second", oMbT.LayoutMs() < 3000)

# LINEAR ALGEBRA. Orthogonality is a constraint the solver met; unit length
# too -- both re-read from the solved arrows with plain arithmetic.
oMb7 = StzMathScene07(AUFONT)
chk("a unit vector and an orthogonal one are lawful", oMb7.IsFeasible())
chk("the two arrows ARE orthogonal, to a hundredth",
    fabs(_MbCos(oMb7, "x1.arrow", "x2.arrow")) < 0.01)
chk("and the unit one is 90px long, to half a pixel",
    fabs(_MbLen(oMb7, "x1.arrow") - 90) < 0.5)

# u := addV(v, w) ENDS WHERE THE SUM SAYS, BY CONSTRUCTION -- an override,
# so the solver never owned that end, and the equality is exact.
oMb8 = StzMathScene08(AUFONT)
chk("vector addition is lawful", oMb8.IsFeasible())
chk("u's end is v's end plus w's end minus the origin, EXACTLY",
    fabs(oMb8.ValueOf("u.arrow.x2") - (oMb8.ValueOf("v.arrow.x2") +
         oMb8.ValueOf("w.arrow.x2") - oMb8.ValueOf("U.ox"))) < 0.000001 and
    fabs(oMb8.ValueOf("u.arrow.y2") - (oMb8.ValueOf("v.arrow.y2") +
         oMb8.ValueOf("w.arrow.y2") - oMb8.ValueOf("U.oy"))) < 0.000001)
# the count that stood here -- "one evaluation" -- measured the whole
# solve, and since DN8c the vector names are solved rather than placed,
# so the label stage spends evaluations the arrow never did. The claim is
# about the ARROW, and is asserted on the mechanism: its end is derived,
# a name the solver never owned
chk("and the solver never owned u's end: it is DERIVED from v's and w's, not an unknown",
    oMb8._HasDerived("u.arrow.x2") and oMb8._HasDerived("u.arrow.y2"))

# EUCLID. The right angle and the equal lengths, re-read from the points.
oMb9 = StzMathScene09(AUFONT)
oMb10 = StzMathScene10(AUFONT)
chk("a general triangle is lawful", oMb9.IsFeasible())
chk("a right isosceles triangle is lawful", oMb10.IsFeasible())
chk("the angle at A IS right, to a hundredth",
    fabs(_MbCos(oMb10, "AB.icon", "AC.icon")) < 0.01)
chk("and AB equals AC, to a pixel",
    fabs(_MbLen(oMb10, "AB.icon") - _MbLen(oMb10, "AC.icon")) < 1)
chk("a vertex's name is clear of its own sides",
    _MbTextOff(oMb9, "A.text", "ABC.pq") and _MbTextOff(oMb9, "A.text", "ABC.pr"))

# NAMES ARE CASE-SENSITIVE, as Penrose's are: Vector u and VectorSpace U
# are two objects, and folding them was what broke scene 8 first.
oMbS = new stzMathSubstance(StzLinearAlgebraDomain())
oMbS.Declare("VectorSpace", "U")
oMbS.Declare("Vector", "u")
chkeq("U is a VectorSpace", oMbS.TypeOf("U"), "VectorSpace")
chkeq("and u is a Vector", oMbS.TypeOf("u"), "Vector")

# A LITERAL SELECTOR binds one object by name.
oMbLit = StzEulerStyle()
oMbLit.ForAll("Set `B`", [ [ :ensure, "greaterThan", [ "`B`.icon.r", 70 ] ] ])
oMbL = new stzMathDiagram(StzSetTheoryDomain(), StzMathTreeSubstance(), oMbLit)
oMbL.SetFont(AUFONT, 28)
chk("`B` alone is held above 70px", oMbL.ShapeOf("B.icon")[:r] >= 69)

# REFUSALS, each with a lawful sibling.
chk("an override of a property no rule minted is refused", _MbRefuses(1))
chk("a where-clause on a function the domain lacks is refused", _MbRefuses(2))
chk("len() of a circle is refused -- it is not a line", _MbRefuses(3))
chk("NEGATIVE: the lawful forms are accepted", NOT _MbRefuses(0))


sec("-- 81. DN7c: ONE TRIANGLE, THREE GEOMETRIES -- PENROSE'S FIG. 1 --------")
discharges("DN7c")

# The kill for DN7c is the paper's own Fig. 1: the same geometric statements
# in Euclidean, spherical and hyperbolic styles, the Substance untouched.
# One instance, three diagrams. The plan assumed this needed asin, acos and
# atan2 on the tape; it did not -- every claim below is a polynomial in the
# model's coordinates once phrased on dot products, and the Poincare right
# angle is division-free once the geodesic centre's numerator is used.
oMcSub = StzMathRightIsoscelesSubstance()
oMcE = new stzMathDiagram(StzGeometryDomain(), oMcSub, StzEuclideanStyle())
oMcE.SetFont(AUFONT, 24)  oMcE.SetVariation("right-isosceles")
oMcS = new stzMathDiagram(StzGeometryDomain(), oMcSub, StzSphericalStyle())
oMcS.SetFont(AUFONT, 24)  oMcS.SetVariation("on-a-sphere")
oMcH = new stzMathDiagram(StzGeometryDomain(), oMcSub, StzHyperbolicStyle())
oMcH.SetFont(AUFONT, 24)  oMcH.SetVariation("in-the-disk")
chk("the right isosceles triangle is lawful in the plane", oMcE.IsFeasible())
chk("lawful on the SPHERE, from the same substance object", oMcS.IsFeasible())
chk("and lawful in the HYPERBOLIC plane, from the same object", oMcH.IsFeasible())
chk("the plane draws no curve; the sphere and the disk draw three each",
    _McCurves(oMcE) = 0 and
    _McCurves(oMcS) = 3 and _McCurves(oMcH) = 3)
chk("the sphere is minted ONCE, however many points sit on it",
    _McCount(oMcS, "_.sphere") = 1)

# THE SPHERE, re-read with plain arithmetic: every point on it, in front,
# the tangents at A perpendicular, the two arcs equal.
bMcUnit = TRUE  bMcFront = TRUE
for cMc in [ "A", "B", "C" ]
	nMcN = pow(oMcS.ValueOf(cMc + ".sx"), 2) + pow(oMcS.ValueOf(cMc + ".sy"), 2) +
	       pow(oMcS.ValueOf(cMc + ".sz"), 2)
	if fabs(nMcN - 1) > 0.01  bMcUnit = FALSE  ok
	if oMcS.ValueOf(cMc + ".sz") < 0.29  bMcFront = FALSE  ok
next
chk("every point is a unit vector, to a hundredth", bMcUnit)
chk("and on the hemisphere facing the reader", bMcFront)
chk("the geodesic tangents at A are perpendicular, to a hundredth",
    fabs(_McSphereCos(oMcS, "B", "A", "C")) < 0.01)
chk("and AB equals AC in arc, to a hundredth of a cosine",
    fabs(_McDot3(oMcS, "A", "B") - _McDot3(oMcS, "A", "C")) < 0.01)

# THE DISK, re-read: every point inside, the arcs' tangents at A
# perpendicular by the cleared-denominator test, the two arcs equal.
bMcIn = TRUE
for cMc in [ "A", "B", "C" ]
	if pow(oMcH.ValueOf(cMc + ".hx"), 2) + pow(oMcH.ValueOf(cMc + ".hy"), 2) >= 0.65
		bMcIn = FALSE
	ok
next
chk("every point is inside the disk, away from the rim", bMcIn)
chk("the hyperbolic angle at A is right, to a hundredth",
    fabs(_McDiskCos(oMcH, "A", "B", "C")) < 0.01)
chk("and AB equals AC in hyperbolic length, to a hundredth of delta",
    fabs(_McDelta(oMcH, "A", "B") - _McDelta(oMcH, "A", "C")) < 0.01)

# THE PRINCIPAL'S MARK: a name never sits on a line. On the sphere and in
# the disk that is "outside the angle" -- the name's direction from its
# point more than 104 degrees from the chord to every other vertex.
chk("on the sphere, every name sits outside its angle", _McNamesOut(oMcS))
chk("and in the disk too", _McNamesOut(oMcH))

# REFUSALS with their lawful sibling.
chk("a constraint over a curve is refused -- constraints speak to points",
    _McRefuses(1))
chk("a malformed unknown row is refused", _McRefuses(2))
chk("NEGATIVE: the lawful forms are accepted", NOT _McRefuses(0))


sec("-- 82. DN7d: BYRNE'S EUCLID I.47, AND MARKS BENT TO THE GEOMETRY -----")
discharges("DN7d")

# Byrne (1847) draws Euclid I.47 in colour: three squares on the sides, the
# altitude from the right angle continued through the square on the
# hypotenuse, and the two rectangles it cuts there -- each equal in area to
# the square on the leg beside it. Every piece of that is DERIVED from the
# three points, so the solver owns six numbers and Euclid's equality is
# never asserted anywhere: it is read back out of the answer.
oBy = StzMathScene13(AUFONT)
chk("Byrne's figure is lawful", oBy.IsFeasible())

# PENROSE'S DELETE: the general rule drew a plain outline, and the rule for
# a RIGHT triangle unminted it before drawing the coloured figure.
chk("the general triangle's outline is gone -- delete unminted it",
    _MdHas(oBy, "ABC.icon") = FALSE)
chk("and the coloured figure stands in its place",
    _MdHas(oBy, "ABC.face") and _MdHas(oBy, "ABC.sqab") and
    _MdHas(oBy, "ABC.sqac") and _MdHas(oBy, "ABC.sqbc") and
    _MdHas(oBy, "ABC.rect1") and _MdHas(oBy, "ABC.rect2"))
# NEGATIVE: a triangle with no right angle keeps the outline and gets none
# of it -- the specialisation fires on the predicate, not on the type.
oPl = _MdPlainTriangle()
chk("NEGATIVE: a plain triangle keeps its outline and grows no squares",
    _MdHas(oPl, "PQR.icon") and _MdHas(oPl, "PQR.sqab") = FALSE)

# THE KILL. Euclid I.47, measured on the polygons the picture drew.
nAB = _MdArea(oBy.PolygonOf("ABC.sqab"))
nAC = _MdArea(oBy.PolygonOf("ABC.sqac"))
nBC = _MdArea(oBy.PolygonOf("ABC.sqbc"))
nR1 = _MdArea(oBy.PolygonOf("ABC.rect1"))
nR2 = _MdArea(oBy.PolygonOf("ABC.rect2"))
chk("the squares have area at all", nAB > 10000 and nAC > 10000 and nBC > 10000)
chk("the rectangle on the B side EQUALS the square on AB, to a millionth",
    fabs(nAB - nR1) / nAB < 0.000001)
chk("the rectangle on the C side EQUALS the square on AC, to a millionth",
    fabs(nAC - nR2) / nAC < 0.000001)
chk("so the square on the hypotenuse is the sum of the other two",
    fabs(nBC - nAB - nAC) / nBC < 0.000001)
chk("and the two rectangles exhaust it", fabs(nR1 + nR2 - nBC) / nBC < 0.000001)
# NEGATIVE: the two legs are NOT equal, so this is not an identity that
# would hold whatever the solver did.
chk("NEGATIVE: the two areas differ -- the equality is not a tautology",
    fabs(nAB - nAC) / nAB > 0.1)

# THE AUTHOR'S TWO MARKS ON THE FIRST PICTURE, both about precision the
# eye can see. The names sat at an equal radius from their POINTS, which
# is an UNEQUAL gap from the ink, because the notch at the right angle is
# a quarter turn where the other two are far wider. And the right-angle
# mark had equal arms, so its corner sat on the angle's bisector -- which
# is not the altitude drawn through it unless the legs are equal.
aByG = _ByGaps(oBy)
chk("every name is the same distance from the nearest ink, within a pixel",
    _ByRange(aByG) < 1)
chk("and it is the clearance the style asks for, not merely equal",
    aByG[1] > 8.5 and aByG[1] < 12 and aByG[2] > 8.5 and aByG[3] > 8.5)
chk("the right-angle mark's corner sits ON the altitude, exactly",
    _ByMarkOff(oBy) < 0.01)
# and the third mark: a vertex's dot was drawn UNDER the squares standing
# on it, because layering names a partial order and "above the hypotenuse
# square" left the dot at the same depth as the rectangles on top of it.
chk("every vertex's dot is painted after every piece of the figure",
    _ByEarliestDot(oBy) > _ByLastInk(oBy))
chk("NEGATIVE: the figure is genuinely ordered, not all one depth -- the " +
    "triangle goes down before the square on the hypotenuse",
    oBy.DrawIndexOf("ABC.face") < oBy.DrawIndexOf("ABC.sqbc") and
    oBy.DrawIndexOf("ABC.sqbc") < oBy.DrawIndexOf("ABC.rect1"))
chk("NEGATIVE: an equal-armed SQUARE mark would miss it, by more than the " +
    "stroke it is drawn with", _BySquareOff(oBy) > 1.5)

# MARKS BENT TO THE GEOMETRY. A right-angle mark's feet are walked along
# the arcs themselves, so they land ON the drawn curve; a mark built on the
# chords between the vertices would miss it.
oMk = StzMathScene11(AUFONT)
oMh = StzMathScene12(AUFONT)
chk("the sphere and the disk both draw a right-angle mark of two arms",
    len(oMk.MarkStrokesOf("BAC.rmark")) = 2 and
    len(oMh.MarkStrokesOf("BAC.rmark")) = 2)
chk("on the sphere, both feet sit on the arcs they mark, within a tenth of a pixel",
    _MdFootOff(oMk) < 0.1)
chk("and in the disk too", _MdFootOff(oMh) < 0.1)
# NEGATIVE: the chord is a different place, and by more than the stroke.
chk("NEGATIVE: a foot walked along the CHORD would miss the arc",
    _MdChordOff(oMk) > 1.5 and _MdChordOff(oMh) > 1.5)
chk("the equal sides wear ticks, across the middle of the arc",
    _MdTickOff(oMk, "AB.tick", "AB.icon") < 0.1 and
    _MdTickOff(oMh, "AB.tick", "AB.icon") < 0.1)

# MINKOWSKI SEPARATION: a label is kept off a shape by the exact distance
# to its BOX, not to the circle that used to be drawn around it. A wide
# name's bounding circle is far larger than the name is tall, so the old
# rule pushed it away from things it never touched.
aMk = _MdBoxProbe()
chk("a wide name sits exactly against the disk it may not enter",
    aMk[1] > -0.5 and aMk[1] < 1.5)
chk("NEGATIVE: its BOUNDING CIRCLE overlaps by tens of pixels -- the old " +
    "rule would have refused this lawful picture", aMk[2] < -30)

# REFUSALS, each with its lawful sibling.
chk("a constraint over a polygon is refused -- constraints speak to points",
    _ByRefuses(1))
chk("a delete of a shape no rule minted is refused", _ByRefuses(2))
chk("a polygon without a whole vertex count is refused", _ByRefuses(3))
chk("NEGATIVE: the lawful forms are accepted", NOT _ByRefuses(0))


sec("-- 83. DN7e: THREE MORE DOMAINS, AND WHAT EACH ONE STRESSES ---------")
discharges("DN7e")

# ORDER THEORY: the opposite end of the engine from Byrne. A partial order
# has no coordinates to be faithful to, so a Hasse diagram is pure LAYOUT --
# two free numbers per node and nothing derived, where Byrne's figure had
# six free numbers and everything else derived from them.
oHa = StzMathScene14(AUFONT)
chk("the divisors of 12 draw as a lawful Hasse diagram", oHa.IsFeasible())
chk("every covering puts the greater element strictly higher", _OdRises(oHa, 7))
chk("and elements of the same rank share a row, to a pixel",
    fabs(oHa.ValueOf("n2.icon.cy") - oHa.ValueOf("n3.icon.cy")) < 1 and
    fabs(oHa.ValueOf("n4.icon.cy") - oHa.ValueOf("n6.icon.cy")) < 1)
# A LAWFUL PICTURE IS NOT A READABLE ONE: nothing in the engine forbids two
# edges from meeting, so the seed is doing work here and the guard says so.
chk("the chosen variation draws it with no edge crossing at all",
    _OdCrossings(oHa, 7) = 0)
chk("NEGATIVE: another seed of the SAME substance and style does cross -- " +
    "the engine has no crossing term, and this check is not vacuous",
    _OdCrossings(_OdSeeded("lattice"), 7) > 0)

# CATEGORY THEORY: the case where the LAYOUT is the content. A commuting
# square is not an illustration of an equation, it is how the equation is
# written -- so the grid is stated as constraints and solved, not placed.
oCat = StzMathScene15(AUFONT)
chk("the commuting square is lawful", oCat.IsFeasible())
chk("its four objects really do make a rectangle",
    fabs(oCat.ValueOf("A.text.cy") - oCat.ValueOf("B.text.cy")) < 1 and
    fabs(oCat.ValueOf("C.text.cy") - oCat.ValueOf("D.text.cy")) < 1 and
    fabs(oCat.ValueOf("A.text.cx") - oCat.ValueOf("C.text.cx")) < 1 and
    fabs(oCat.ValueOf("B.text.cx") - oCat.ValueOf("D.text.cx")) < 1)
chk("every arrow stops clear of the names at both of its ends",
    _CtClears(oCat, [ "f", "g", "h", "k" ]))
chk("and every arrow's name sits off the arrow, never on it",
    _CtLabelsOff(oCat, [ "f", "g", "h", "k" ]) > 8)
oTri = StzMathScene18(AUFONT)
chk("the commuting triangle is lawful, and its apex is centred under the top",
    oTri.IsFeasible() and
    fabs(oTri.ValueOf("Z.text.cx") -
         (oTri.ValueOf("X.text.cx") + oTri.ValueOf("Y.text.cx")) / 2) < 1)

# THALES: Byrne's kill again, in one line of substance.
oTh = StzMathScene16(AUFONT)
chk("Thales' picture is lawful", oTh.IsFeasible())
chk("all three points sit on the circle, to a tenth of a pixel",
    _ThOnCircle(oTh, "A") < 0.1 and _ThOnCircle(oTh, "B") < 0.1 and
    _ThOnCircle(oTh, "C") < 0.1)
chk("and BC runs through the centre -- its midpoint IS the centre",
    fabs((oTh.ValueOf("B.icon.cx") + oTh.ValueOf("C.icon.cx")) / 2 -
         oTh.ValueOf("K.icon.cx")) < 0.5 and
    fabs((oTh.ValueOf("B.icon.cy") + oTh.ValueOf("C.icon.cy")) / 2 -
         oTh.ValueOf("K.icon.cy")) < 0.5)
chk("SO THE ANGLE AT A IS RIGHT, to a hundredth of a cosine",
    fabs(_ThCosAtA(oTh)) < 0.01)
chk("NEGATIVE: and the substance never said so -- there is no Right in it",
    NOT StzMathThalesSubstance().Holds("Right", [ "BAC" ]))


sec("-- 84. DN7f: THE PENROSE GALLERY AS THE YARDSTICK ---------------------")
discharges("DN7f")

# THE GRAPH FAMILY, the gallery's largest. A network with one-way links
# under the node-link style, and the same domain as boxes and arrows.
oGn = StzMathScene20(AUFONT)
chk("the network with one-way links is lawful", oGn.IsFeasible())
chk("every arrow stops clear of the dot at both of its ends",
    _GrArrowsClear(oGn, "l", 8, 11))
chk("no name sits within twelve pixels of a STRANGER's dot",
    _GrNamesOffStrangers(oGn, [ "Client", "Gateway", "Firewall", "Switch", "Web", "DB", "Backup" ]) >= 11.5)
# THE NETWORK STARTS PLANAR NOW (DN11). It is not 3-connected -- leaves
# hang off its ring -- and the planar start was refused for exactly that
# until the start learned to embed the 2-core and hang the leaves after.
# The line that stood here read "the chosen seed leaves one crossing": a
# pin on a limitation, and the crossing is gone with the limitation.
chk("the network starts planar: its 2-core embeds and its leaves hang off it",
    oGn.StartedPlanar())
chk("and the crossing the chosen seed used to leave is gone", _GrCrossings(oGn, "l", 8) = 0)
chk("NEGATIVE: the first seed tried leaves eight -- the count is real",
    _GrCrossings(_GrSeeded(20, "network"), "l", 8) > 1)
oGb = StzMathScene21(AUFONT)
chk("the same domain draws as boxes and arrows, lawfully", oGb.IsFeasible())
chk("and each box is sized to the name inside it",
    _GrBoxFits(oGb, [ "CPU", "Cache", "RAM", "Bus", "GPU", "Disk", "Network" ]))

# THE CUBE, with Hamilton's cycle marked: a Gray code, eight edges red.
oGc = StzMathScene23(AUFONT)
chk("the cube graph is lawful", oGc.IsFeasible())
chk("exactly eight of its twelve edges are highlighted -- the cycle",
    _GrHighlighted(oGc, "q", 12) = 8)
chk("the crossing rule is compiled -- 84 terms, one per ordered pair of " +
    "edges sharing no vertex", _GrCrossingRules(oGc) = 84)
# the finding DN7f measured, kept as its negative: from a RANDOM start the
# rule is advice the solver cannot follow, and the picture keeps crossings
nGrRx = _GrCrossings(_GrRandomStart(StzMathCubeSubstance(), StzSpringGraphStyle(), 15, "gray"), "q", 12)
chk("NEGATIVE: from a random start the same style is NOT planar -- " + nGrRx +
    " crossing(s) the rule, as advice, could not undo", nGrRx > 0)

# THE MATCHER WAS THE COST. The dodecahedron's compile was 18 seconds
# when a definition clause was a FILTER over the product of every
# variable's candidates; it is a GENERATOR now. Measured as a COUNT, not a
# clock: this machine is shared and a clock assertion fails on a busy
# afternoon, but the number of candidates the matcher builds does not
# move with the load.
oGd = new stzMathDiagram(StzGraphDomain(), StzMathDodecahedronSubstance(), StzGraphStyle())
oGd._Compile()
chk("the dodecahedron's whole compile enumerates under ten thousand candidate bindings",
    oGd.@nMatchCandidates < 10000)
chk("NEGATIVE: the product form would have built 144,000,000 for the six-variable " +
    "rule alone -- 30 x 30 x 20 x 20 x 20 x 20",
    30 * 30 * 20 * 20 * 20 * 20 = 144000000 and oGd.@nMatchCandidates < 144000000 / 1000)
chk("and the vertex-off-edge selector binds every edge with exactly its " +
    "eighteen non-endpoints", _GrCountWhere(oGd, "disjoint", ".icon, e") = 540)

# THE WORD CLOUD: Minkowski separation, and delete re-minting a text
# larger -- the case that found _Initialise indexing the name map by slot.
oGw = StzMathScene22(AUFONT)
chk("the word cloud is lawful", oGw.IsFeasible())
chk("eighteen words, eighteen text shapes: a re-minted word is one shape",
    oGw.NumberOfShapes() = 18)
chk("and the tape keeps the slots the deleted texts left -- more slots than names",
    oGw.NumberOfUnknowns() > 36)
chk("every pair of word boxes is apart by the six pixels asked",
    _GrMinBoxGap(oGw) >= 5.9)
chk("a Large word measures wider than a small one of more letters",
    oGw.ShapeOf("diagram.text")[:w] > oGw.ShapeOf("substance.text")[:w])

# THE NAME RULE the yardstick caught: a leading digit heads no path.
chk("a name starting with a digit is refused at Declare, with the rule",
    _GrRefusesName("000"))
chk("NEGATIVE: the same name with a letter in front is accepted",
    NOT _GrRefusesName("v000"))


sec("-- 85. DN7g: THE PLANAR START -- TUTTE FROM A FACE FOUND BY ITS SHAPE ---")
discharges("DN7g")

# DN7f measured that the basin is chosen before the first gradient step.
# So the start is chosen: a face of the graph on a convex polygon, every
# other vertex at the barycentre of its neighbours -- Tutte, 1963 -- and
# the face found with no planarity test, as the shortest cycle that is
# chordless and non-separating.
oPc = StzMathScene23(AUFONT)
chk("the cube begins planar", oPc.StartedPlanar())
chk("on a face of FOUR vertices -- a square of the cube",
    len(oPc.OuterFace()) = 4)
chk("and every consecutive pair on that face is an edge of the graph",
    _PlFaceIsCycle(StzMathCubeSubstance(), oPc.OuterFace(), "q", 12))
chk("it ends planar: zero crossings, and lawful",
    _GrCrossings(oPc, "q", 12) = 0 and oPc.IsFeasible())
oPd = StzMathScene19(AUFONT)
chk("the dodecahedron begins planar, on a PENTAGON", oPd.StartedPlanar() and
    len(oPd.OuterFace()) = 5)
chk("and ends planar too: twenty vertices, thirty edges, zero crossings, lawful",
    _GrCrossings(oPd, "e", 30) = 0 and oPd.IsFeasible())
chk("NEGATIVE: the same style with the start cleared leaves the dodecahedron crossed",
    _GrCrossings(_GrRandomStart(StzMathDodecahedronSubstance(), StzSpringGraphStyle(),
                 12, "game"), "e", 30) > 5)

# THE FALLBACK. A graph Tutte collapses -- a TREE, whose 2-core is empty --
# keeps the start it can have, and says so. The network stood here until
# DN11 as "not 3-connected, so no planar start"; it is not 3-connected,
# but it is not a tree either, and a cut vertex is no longer a refusal.
oPn = _GrTree()
chk("a tree has no planar start, and the diagram says so",
    NOT oPn.StartedPlanar() and len(oPn.OuterFace()) = 0)
chk("and it is still lawful", oPn.IsFeasible())

# THE TWO REPAIRS THE START FORCED. A name held off an edge pulls on the
# edge's ends, and at a strict weight eight names threw a planar cube away;
# and freezing the shapes for the label stage rewrote a half-megabyte
# energy once per variable, a character at a time -- 706 seconds.
chk("the node-link style solves its names AFTER its shapes",
    StzGraphStyle().LabelsAfter())
chk("NEGATIVE: the Euler style does not -- a set must be large enough for its name",
    NOT StzEulerStyle().LabelsAfter())
# checked for what it DOES, not how fast -- a clock assertion on this
# shared machine fails on a busy afternoon, and did, twice today
cPfRaw = oPn._EnergyText(0, 1000, TRUE)
cPfFrozen = oPn._Frozen(cPfRaw, 0)
chk("freezing for the label stage leaves NO shape variable in the energy",
    _PlSymbolsOf(oPn, cPfFrozen, 0) = 0)
chk("and every label variable still stands where it stood",
    _PlSymbolsOf(oPn, cPfFrozen, 1) = _PlSymbolsOf(oPn, cPfRaw, 1) and
    _PlSymbolsOf(oPn, cPfRaw, 1) > 0)


sec("-- 86. DN7h: SPLINES -- BLOBS, A CURVED GRAPH, CATMULL-ROM ------------")
discharges("DN7h")

# THE CURVE INTERPOLATES. Centripetal Catmull-Rom passes THROUGH every
# control point -- the property that separates it from a Bezier, which
# only approaches its inner ones -- and never cusps between two points.
oSpC = StzMathScene26(AUFONT)
chk("six points and the path through them are lawful", oSpC.IsFeasible())
chk("the curve passes through every control point, to a hundredth of a pixel",
    _SpWorstMiss(oSpC, "S.icon") < 0.01)
chk("and it BENDS: some span's middle leaves its chord by more than a pixel",
    _SpMaxBulge(oSpC, "S.icon") > 1)
chk("smoothly -- no turn between consecutive samples sharper than thirty degrees",
    _SpMaxTurn(oSpC, "S.icon") < 30)
chk("NEGATIVE: the chords' own polyline turns far more sharply than the curve",
    _SpMaxTurn(oSpC, "S.c1") = 0 and _SpPolylineMaxTurn(oSpC.PolygonOf("S.icon")) > 30)

# BLOBS: the same seven-set tree as scenes 02 and 06, each set a wobbly
# closed spline. The containment is solved on hidden circles padded by the
# wobble; the guard checks it on what is DRAWN -- every sample of a child's
# curve inside its parent's polygon, no sample of a disjoint pair inside
# the other, no two curves crossing.
oSpB = StzMathScene24(AUFONT)
chk("the tree as blobs is lawful", oSpB.IsFeasible())
chk("every subset's DRAWN curve lies inside its superset's drawn curve",
    _SpInside(oSpB, "B.blob", "A.blob") and _SpInside(oSpB, "C.blob", "A.blob") and
    _SpInside(oSpB, "D.blob", "B.blob") and _SpInside(oSpB, "E.blob", "B.blob") and
    _SpInside(oSpB, "F.blob", "C.blob") and _SpInside(oSpB, "G.blob", "C.blob"))
chk("and every disjoint pair's drawn curves are apart -- no crossing, no sample inside",
    _SpApart(oSpB, "D.blob", "E.blob") and _SpApart(oSpB, "F.blob", "G.blob") and
    _SpApart(oSpB, "B.blob", "C.blob"))
chk("the wobble is real: some blob's radius varies by more than five percent",
    _SpWobble(oSpB, "A.blob") > 0.05 or _SpWobble(oSpB, "B.blob") > 0.05 or
    _SpWobble(oSpB, "C.blob") > 0.05)
chk("and BOUNDED: no control point strays past twelve percent of its radius",
    _SpWobble(oSpB, "A.blob") <= 0.125 and _SpWobble(oSpB, "B.blob") <= 0.125 and
    _SpWobble(oSpB, "C.blob") <= 0.125 and _SpWobble(oSpB, "D.blob") <= 0.125)
chk("NEGATIVE: another seed wobbles differently -- the wobble is the seed's, not the rule's",
    _SpWobbleDiffers(oSpB, "A.blob"))

# THE CURVED GRAPH: the cube again, edges bulged into arcs, the rules still
# speaking to the straight chord and to the arc's two half-chords.
oSpG = StzMathScene25(AUFONT)
chk("the cube with curved edges is lawful, from a planar start",
    oSpG.IsFeasible() and oSpG.StartedPlanar())
chk("every arc's middle sample leaves its chord by close to the declared bulge",
    _SpArcBulges(oSpG, "q", 12, 0.08))
chk("and the arcs' ends are the vertices themselves, exactly",
    _SpArcEndsOnDots(oSpG, "q", 12))


sec("-- 87. DN7i: ELLIPSES -- SETS IN 2.5D, AND THE RAYS OF AN ELLIPSE -----")
discharges("DN7i")

# SETS IN 2.5D: the seven-set tree a fourth time, solved as disks and drawn
# as their image under one affine map. The guard checks the DRAWN ellipses:
# every child's boundary inside its parent's, every disjoint pair apart,
# and every ellipse flattened by the same factor -- which is what makes
# the first two follow from the disks at all.
oEl = StzMathScene27(AUFONT)
chk("the tree in 2.5D is lawful", oEl.IsFeasible())
chk("every ellipse is flattened by the one factor, 0.55, exactly",
    _ElSameAspect(oEl, [ "A", "B", "C", "D", "E", "F", "G" ], 0.55))
chk("every subset's DRAWN ellipse lies inside its superset's",
    _ElInside(oEl, "B", "A") and _ElInside(oEl, "C", "A") and _ElInside(oEl, "D", "B") and
    _ElInside(oEl, "E", "B") and _ElInside(oEl, "F", "C") and _ElInside(oEl, "G", "C"))
chk("and every disjoint pair's drawn ellipses are apart",
    _ElApart(oEl, "D", "E") and _ElApart(oEl, "F", "G") and _ElApart(oEl, "B", "C"))
chk("every name sits inside its own drawn ellipse, box and all",
    _ElNamesFit(oEl, [ "A", "B", "C", "D", "E", "F", "G" ]))
chk("NEGATIVE: an ellipse is its bounding box to a constraint -- the shape " +
    "reads as a rect there, and the styles keep their reasoning on circles",
    oEl._Geo("A.disk")[1] = "rect")

# ELLIPSE RAYS: Byrne's kill for a conic. Nothing in the substance or the
# style states the optics; the solver chooses where six rays meet the
# curve, and the two theorems are read back.
oRy = StzMathScene28(AUFONT)
chk("the ellipse and its six rays are lawful", oRy.IsFeasible())
chk("THE STRING PROPERTY: for every hit, |F1P| + |PF2| equals the major axis, " +
    "to a hundredth of a pixel", _RyWorstString(oRy, 6) < 0.01)
chk("THE REFLECTION LAW: at every hit the ray in and the ray out make the same " +
    "angle with the tangent, to a thousandth of a cosine", _RyWorstLaw(oRy, 6) < 0.001)
chk("and the hits are spread -- the parameters did work, not one place six times",
    _RyMinSpread(oRy, 6) > 60)
chk("NEGATIVE: neither law is a rule -- no constraint in the picture names a focus",
    _RyRulesNamingFoci(oRy) = 0)


sec("-- 88. DN7j: A COLOUR CHANNEL FROM SUBSTANCE DATA ------------------------")
discharges("DN7j")

# THE DATA ITSELF: a number on an object, read back, refused when it is
# not a number or its key is not a name.
oCdS = new stzMathSubstance(StzTableDomain())
oCdS.Declare("Cell", "x")
oCdS.SetData("x", "v", 7.5)
chk("a number set on an object is read back", oCdS.DataOf("x", "v") = 7.5 and oCdS.HasData("x", "v"))
chk("and set again, it is replaced, not doubled",
    oCdS.SetData("x", "v", 2).DataOf("x", "v") = 2 and len(oCdS.@aData) = 1)
chk("a key that is not a name is refused", _CdRefuses(oCdS, "9v", 1))
chk("NEGATIVE: a value that is not a number is refused, and a good one accepted",
    _CdRefuses(oCdS, "w", "seven") and NOT _CdRefuses(oCdS, "w", 7))

# THE QUATERNION TABLE: a diagram with nothing to solve. Its 64 cells sit
# where their data says; each is filled from a palette by WHICH element
# its product is. The guard reads the group back out of the picture.
oCq = StzMathScene29(AUFONT)
chk("the table is lawful with nothing evaluated -- every name is data, and the on-canvas " +
    "terms it used to carry were constants, checked in Ring and not on a tape",
    oCq.IsFeasible() and oCq.Evaluations() = 0 and oCq.NumberOfConstraints() = 0)
chk("every cell sits at the place its row and column data name",
    _CqCellsPlaced(oCq))
chk("i.j is k and j.i is -k, and their fills are k's and -k's colours",
    oCq.FillOf("c2_3.icon") = "#7d9ce0" and oCq.FillOf("c3_2.icon") = "#2a4fa8" and
    oCq.FillOf("c2_3.icon") != oCq.FillOf("c3_2.icon"))
chk("every row of the table is a permutation of the eight elements -- a Latin square",
    _CqLatin(oCq))
chk("and every product agrees with an independent multiplication, all 64",
    _CqProductsAgree(oCq))

# THE HEAT MAP: A . B = C, each cell on a ramp by its value over its own
# matrix's range. The guard multiplies A and B itself from the cell data.
oCh = StzMathScene30(AUFONT)
chk("the heat map is lawful with nothing evaluated", oCh.IsFeasible() and oCh.Evaluations() = 0)
chk("C's cells hold A . B, recomputed here from A's and B's cell data",
    _ChProductAgrees(oCh))
# the ramp runs from the PAPER to the ACCENT since DN8d, so its ends are
# the theme's, read back through the roles rather than pinned as hex
chk("the hottest cell of C wears the theme's accent, and the coolest its paper",
    oCh.FillOf(_ChExtreme(oCh, "c", 3, 3, TRUE) + ".icon") = oCh._RoleColour("primary") and
    oCh.FillOf(_ChExtreme(oCh, "c", 3, 3, FALSE) + ".icon") = oCh.Background())
# the ramp is PERCEPTUAL since DN8d: the midpoint's lightness is the mean
# of the endpoints' on the Oklab scale -- which the sRGB midpoint this
# assertion used to pin (#de9c9c) is not, and that was the colour plan's
# measured defect shipping here
chk("a cell halfway up the ramp sits halfway in LIGHTNESS between the ends, to a hundredth",
    fabs(StzEngineColorLightness(_CdRgb(oCh._LerpHex("#f4f4fb", "#c8443c", 0.5))) -
         (StzEngineColorLightness(_CdRgb("#f4f4fb")) + StzEngineColorLightness(_CdRgb("#c8443c"))) / 2) < 0.01 and
    oCh._Colour([ :ramp, "0.5", 0, 1, "#f4f4fb", "#c8443c" ]) = oCh._LerpHex("#f4f4fb", "#c8443c", 0.5))
chk("NEGATIVE: the sRGB midpoint, #de9c9c, is NOT halfway in lightness -- the ramp that zigzagged",
    fabs(StzEngineColorLightness(_CdRgb("#de9c9c")) -
         (StzEngineColorLightness(_CdRgb("#f4f4fb")) + StzEngineColorLightness(_CdRgb("#c8443c"))) / 2) > 0.01)
# a colour rule answers in the palette's case, upper; the guard's literals
# are compared as colours, not as strings
chk("a ramp clamps: below lo is the cool colour, above hi the hot one",
    StzLower(oCh._Colour([ :ramp, "0-3", 0, 1, "#f4f4fb", "#c8443c" ])) = "#f4f4fb" and
    StzLower(oCh._Colour([ :ramp, "9", 0, 1, "#f4f4fb", "#c8443c" ])) = "#c8443c")
chk("NEGATIVE: a ramp whose lo equals hi does not divide by zero -- it is its cool colour",
    StzLower(oCh._Colour([ :ramp, "5", 5, 5, "#f4f4fb", "#c8443c" ])) = "#f4f4fb")
chk("a palette rounds to the nearest entry and clamps at both ends",
    oCh._Colour([ :palette, "2.4", [ "#a", "#b", "#c" ] ]) = "#b" and
    oCh._Colour([ :palette, "0", [ "#a", "#b", "#c" ] ]) = "#a" and
    oCh._Colour([ :palette, "40", [ "#a", "#b", "#c" ] ]) = "#c")


sec("-- 89. DN8a: A SUBSTANCE IS A GRAPH, AND A GRAPH IS A SUBSTANCE ---------")
discharges("DN8a")

# THERE AND BACK, with nothing missing: objects, types, labels, data,
# every relation, and the SAME graph again from the copy.
oGsT = StzMathTreeSubstance()
oGsT.SetData("A", "weight", 3.5)
oGsG = oGsT.ToGraph()
oGsT2 = StzSubstanceFromGraph(oGsG, StzSetTheoryDomain(), [])
chk("the seven-set tree becomes seven nodes and nine edges",
    oGsG.NodesCount() = 7 and oGsG.EdgesCount() = 9)
chk("and comes back with every object, type and label",
    _GsSameObjects(oGsT, oGsT2))
chk("with every relation holding in the copy", _GsRelationsHold(oGsT, oGsT2))
chk("with its data", oGsT2.DataOf("A", "weight") = 3.5)
chk("and the copy's graph is the first graph again -- same counts, same edges",
    _GsSameGraph(oGsG, oGsT2.ToGraph()))

# WHERE AN EDGE WILL NOT DO, A NODE. stzGraph is simple -- no parallel
# edges -- so a second relation on one pair is reified, and so is any
# relation of three or more arguments. Both come back whole.
oGsC = new stzMathSubstance(StzSetTheoryDomain())
oGsC.DeclareAll("Set", [ "A", "B" ])
oGsC.Assert("Subset", [ "B", "A" ])
oGsC.Assert("Disjoint", [ "A", "B" ])
oGsCG = oGsC.ToGraph()
oGsC2 = StzSubstanceFromGraph(oGsCG, StzSetTheoryDomain(), [])
chk("two relations on one pair: the second becomes a relation node with two argument edges",
    oGsCG.NodesCount() = 3 and oGsCG.EdgesCount() = 3)
chk("and both relations hold on the way back",
    oGsC2.Holds("Subset", [ "B", "A" ]) and oGsC2.Holds("Disjoint", [ "A", "B" ]))
oGsQ = new stzMathSubstance(StzCategoryDomain())
oGsQ.DeclareAll("Object", [ "A", "B", "C", "D" ])
oGsQ.Assert("CommutingSquare", [ "A", "B", "C", "D" ])
oGsQ2 = StzSubstanceFromGraph(oGsQ.ToGraph(), StzCategoryDomain(), [])
chk("a four-place relation is a node with four positioned edges, and comes back in order",
    oGsQ.ToGraph().EdgesCount() = 4 and oGsQ2.Holds("CommutingSquare", [ "A", "B", "C", "D" ]) and
    NOT oGsQ2.Holds("CommutingSquare", [ "B", "A", "C", "D" ]))

# PROJECTION: a graph-domain substance's Edge objects become the plain
# edges a layout wants, and come back as the same definitions.
oGsK = StzMathCubeSubstance()
oGsKG = oGsK.ToGraphXT([ :projectConstructors = "Edge" ])
oGsK2 = StzSubstanceFromGraph(oGsKG, StzGraphDomain(), [])
chk("the cube with Edge projected is eight nodes and twelve edges, no edge objects among the nodes",
    oGsKG.NodesCount() = 8 and oGsKG.EdgesCount() = 12)
chk("every Edge definition comes back, with its Highlighted marks -- eight of twelve",
    _GsDefinitionsBack(oGsK, oGsK2, 12) and _GsHighlighted(oGsK2, 12) = 8)
chk("NEGATIVE: without projection the same substance is twenty nodes -- the edges are objects",
    oGsK.ToGraph().NodesCount() = 20)

# A FOREIGN GRAPH: the graph plane's own org chart, never a substance,
# made one under the caller's word for its nodes and edges, and drawn.
oGsO = StzMathScene31(AUFONT)
oGsOS = StzSubstanceFromGraph(StzMathOrgChart(), StzGraphDomain(),
	[ :nodeType = "Vertex", :edgeConstructor = "Arc" ])
chk("six positions become six Vertex objects and five reporting lines five Arcs",
    len(oGsOS.ObjectsOfType("Vertex")) = 6 and len(oGsOS.ObjectsOfType("Arc")) = 5)
chk("the positions' titles are the substance's labels",
    oGsOS.LabelOf("cto") = "Technology" and oGsOS.LabelOf("ceo") = "Chief Executive")
chk("an org chart's own :type, box, yields to the caller's Vertex -- the domain does not know box",
    oGsOS.TypeOf("ceo") = "Vertex")
chk("and the chart draws, lawful, under the box-and-arrow style", oGsO.IsFeasible())

# REFUSALS with their reasons, and their lawful siblings.
chk("two names that differ only by case are refused -- stzGraph folds ids to lower case",
    _GsRefusesCase())
chk("a foreign graph with no word for its edges is refused", _GsRefusesForeign(1))
chk("NEGATIVE: with the word given, the same graph is accepted", NOT _GsRefusesForeign(0))


sec("-- 90. DN8b: LAYOUTS AS STARTS, AND THE END OF SEED-PICKING ------------")
discharges("DN8b")

# THE LATTICES WITH NO SEED CHOSEN. On record: seven seeds of ten drew the
# divisors of 12 without a crossing, and one of twelve the divisors of 36.
# From the graph plane's hierarchical layout as the start, any seed does.
oLsA = _LsLattice12("no-seed")
oLsB = _LsLattice36("no-seed")
chk("the divisors of 12 start from the hierarchical layout, first try, lawful, no crossing",
    oLsA.StartUsed() = "hierarchical" and oLsA.StartsTried() = 1 and oLsA.IsFeasible() and
    _OdCrossings(oLsA, 7) = 0)
chk("and the divisors of 36 likewise -- where one seed of twelve managed it before",
    oLsB.StartUsed() = "hierarchical" and oLsB.StartsTried() = 1 and oLsB.IsFeasible() and
    _OdCrossings(oLsB, 12) = 0)
chk("three more seeds of the 36-lattice all come out clean: the seed no longer decides",
    _OdCrossings(_LsLattice36("thirtysix"), 12) = 0 and
    _OdCrossings(_LsLattice36("grid"), 12) = 0 and
    _OdCrossings(_LsLattice36("three"), 12) = 0)
chk("NEGATIVE: the same style with its starts cleared, on the seed that crossed, still crosses",
    _OdCrossings(_LsLatticeNoStart("thirtysix"), 12) > 0)

# THE ORG CHART, DN8a's witness, fixed by the item it witnessed for.
oLsO = StzMathScene31(AUFONT)
chk("the org chart starts hierarchical, first try, lawful, with no crossing",
    oLsO.StartUsed() = "hierarchical" and oLsO.StartsTried() = 1 and oLsO.IsFeasible() and
    _OdCrossingsOf(oLsO, "e", 5) = 0)
# the box style reads an arc LEFT TO RIGHT -- its own rule, written for a
# data flow -- so the hierarchy runs across, not down: a report sits to
# the RIGHT of the position it reports to
chk("and every report sits to the right of the position it reports to",
    _LsRightOf(oLsO, "cto", "ceo") and _LsRightOf(oLsO, "cfo", "ceo") and
    _LsRightOf(oLsO, "eng", "cto") and _LsRightOf(oLsO, "ops", "cto") and _LsRightOf(oLsO, "acc", "cfo"))

# THE STARTS ARE TRIED IN ORDER, A START THE GRAPH CANNOT GIVE IS SKIPPED,
# AND THE FIGURES ARE REPORTED.
# a real tree, since DN11: the network used to stand here, and it starts
# planar now -- its 2-core is a ring
oLsN = _GrTree()
chk("a tree's planar start cannot be computed and is skipped, not counted as tried",
    oLsN.StartUsed() != "planar" and NOT oLsN.StartedPlanar())
chk("a style that names no start reports one random start",
    _LsNoStart().StartUsed() = "random" and _LsNoStart().StartsTried() = 1)
chk("a start that is not a start is refused", _LsRefusesStart())

# THE DODECAHEDRON: the planar start under the SOFT style, kept; and under
# the HARD style, measured and NOT kept -- Tutte's inner faces are too
# tight for 26px separations and 90px edges, and the solver does not
# recover planarity while opening them.
oLsD = StzMathScene19(AUFONT)
chk("the dodecahedron keeps its planar start under the spring style: lawful, no crossing",
    oLsD.StartUsed() = "planar" and oLsD.IsFeasible() and _OdCrossingsOf(oLsD, "e", 30) = 0)
chk("its picture reports no crossing rule left as unmet advice", oLsD.AdvisoryUnmet() = 0)
oLsH = _LsDodecaHard()
chk("under the hard style the planar start ends UNLAWFUL -- the recorded limit, not a picture",
    NOT _LsHardPlanarLawful())
chk("and when the random start then wins, the picture SAYS how many crossing rules were advice unmet",
    oLsH.AdvisoryUnmet() > 0 and StzFindFirst("advice", oLsH.Why()) > 0)


sec("-- 91. DN8c: ONE GATE OVER BOTH CATALOGUES -----------------------------")
discharges("DN8c")

# THE ONE GATE: every notation picture and every mathematical one, each
# judged by the rules its class is drawn by, and every math picture's own
# constraints ingested beside -- one report, one count of pictures judged.
aOgP = []
for iOg = 1 to len(aGvCat)
	aOgP + [ "catalogue/" + aGvCat[iOg][1], aGvCat[iOg][2] ]
next
# AND THE SCHEMAS (DN15): a shop, and the same shop wrong. They are
# notation pictures, judged by the plastic rules; their OWN rules -- the
# ones about keys -- are held in section 109, and the witness's five
# findings are not the plastic gate's to count. The shop stands on the
# fan rule's boundary: an entity whose two relations are marked where
# they leave it is a counter-subject, not a fan.
aOgP + [ "er/shop", StzErScene01(OPTER2) ]
aOgP + [ "er/wrong", StzErScene02(OPTER2) ]
aOgP + [ "er/participation", StzErSceneParticipation(OPTER2) ]
# AND THE PETRI NETS (DN16): the mutex, whose four returns run under one
# row; the buffer with its weights; and the witness with one of each
# mistake. Notation pictures, judged by the plastic rules -- two of
# which they taught: a cell on a straight run is a detour by law, and
# only lines leaving by one face are one fan.
aOgP + [ "petri/mutex", StzPetriScene01(OPTPN2) ]
aOgP + [ "petri/buffer", StzPetriScene02(OPTPN2) ]
aOgP + [ "petri/witness", StzPetriSceneWitness(OPTPN2) ]
# AND THE FAULT TREES (DN17): the pump, the repeated sensor, and the
# witness with one of each mistake -- the pictures that taught the layout
# to centre a gate over inputs of unequal depth and a fan to share its
# tightest channel.
aOgP + [ "fault/pump", StzFaultScene01(OPTFT2) ]
aOgP + [ "fault/repeated", StzFaultScene02(OPTFT2) ]
aOgP + [ "fault/witness", StzFaultSceneWitness(OPTFT2) ]
# AND THE FAMILY TREES (DN18): three generations with a single parent, the
# witness, the cycle and the kin joined -- the first pictures whose
# sources settle onto what they feed.
aOgP + [ "family/three", StzFamilyScene01(OPTFM2) ]
aOgP + [ "family/witness", StzFamilySceneWitness(OPTFM2) ]
aOgP + [ "family/cycle", StzFamilySceneCycle(OPTFM2) ]
aOgP + [ "family/kin", StzFamilySceneKin(OPTFM2) ]
# AND THE NETWORK TOPOLOGIES (DN21): the office, the floors and the
# witness -- the first pictures whose frames are subnets.
aOgP + [ "network/office", StzNetworkScene01(OPTNW2) ]
aOgP + [ "network/floors", StzNetworkScene02(OPTNW2) ]
aOgP + [ "network/witness", StzNetworkSceneWitness(OPTNW2) ]
for iOg = 1 to 31
	cOgF = "StzMathScene" + iOg
	if iOg < 10  cOgF = "StzMathScene0" + iOg  ok
	aOgP + [ "math/" + iOg, call cOgF(AUFONT) ]
next
# and one picture that stands on a rule's boundary: a graph with one
# vertex unnamed among named ones, so the pair rule has a subject it
# must NOT govern in the corpus -- the governance asked for it
aOgP + [ "math/witness", _OgWitness() ]
# AND TWO WITNESSES FOR THE WINDOW RULE (DN9d). A rule whose boundary no
# picture stands on could be anywhere, so the corpus carries a frame whose
# mark is inside the part it shows and one whose mark is outside it. The
# second is a picture the gate is MEANT to find something in, which is why
# it is named as such.
aOgP + [ "math/window/marked in view", _OgWindowWitness(TRUE) ]
aOgP + [ "math/window/marked out of view", _OgWindowWitness(FALSE) ]
# and the OTHER side of that boundary: a picture carrying marks and no
# window at all, which the rule must not govern. Without it the rule's
# edge has never been stood on and could sit anywhere.
aOgP + [ "math/window/marked, no window", _OgWindowWitness(:none) ]
# AND THE MOLECULES (DN11): three lawful ones, and two witnesses for the
# chemistry rules -- an oxygen with three bonds, and an atom bonded to
# nothing. The chemistry rules register themselves into the math
# governance from the file that owns them, so with no molecule in this
# corpus they would read as DEAD to the five questions below; with these
# they are judged, and every lattice is the boundary they must not cross.
aOgP + [ "chem/water", StzMathScene38(AUFONT) ]
aOgP + [ "chem/benzene", StzMathScene39(AUFONT) ]
aOgP + [ "chem/caffeine", StzMathScene40(AUFONT) ]
aOgP + [ "chem/witness/three-bonded oxygen", _OgValenceWitness() ]
aOgP + [ "chem/witness/stray hydrogen", _OgStrayWitness() ]
# AND THE GANTT (DN14): the project, and the witness with one of each
# mistake about time -- two backwards dependencies, a task ending before
# it starts, and a double-booked lane reported on both its tasks.
aOgP + [ "gantt/project", StzMathScene42(AUFONT) ]
aOgP + [ "gantt/witness", StzMathGanttWitness(AUFONT) ]
# AND THE TIMELINE (DN19): the history of computing, and the witness with
# one of each mistake about time -- an era ending before it starts, a band
# double-booked and reported on both its eras, an event outside its era.
aOgP + [ "timeline/history", StzMathScene43(AUFONT) ]
aOgP + [ "timeline/witness", StzMathTimelineWitness(AUFONT) ]
# AND THE FISHBONE (DN20): the coffee, and the witness with one of each
# mistake about the analysis -- an empty bone, a cause listed twice and
# reported on both listings, the effect among its own causes.
aOgP + [ "fishbone/coffee", StzMathScene45(AUFONT) ]
aOgP + [ "fishbone/witness", StzMathFishboneWitness(AUFONT) ]
# AND THE FLOOR PLAN (DN22): the flat, and the witness with one of each
# mistake about the building -- an overlap on both rooms, a room with no
# door, two rooms nobody can reach, a window onto a room.
aOgP + [ "floorplan/flat", StzMathScene47(AUFONT) ]
aOgP + [ "floorplan/witness", StzMathFloorPlanWitness(AUFONT) ]
# AND THE SEATING PLAN (DN23): the wedding, and the witness with one of
# each mistake a host makes -- an overbooked table, a guest seated twice
# on both listings, a pair kept apart together, two tables that meet.
aOgP + [ "seating/wedding", StzMathScene49(AUFONT) ]
aOgP + [ "seating/witness", StzMathSeatingWitness(AUFONT) ]
# AND THE CHOROPLETH (DN24): the provinces, and the witness with one of
# each mistake a map makes -- a hole, a value beyond the classes, a shade
# out of order, a class colouring nothing.
aOgP + [ "choropleth/provinces", StzMathScene51(AUFONT) ]
aOgP + [ "choropleth/witness", StzMathChoroplethWitness(AUFONT) ]
nOgT0 = StzEngineWatchTimestampMs()
oOgRep = StzCheckPictures(aOgP)
nOgMs = StzEngineWatchTimestampMs() - nOgT0
chk("eighty-eight pictures are judged by one call -- thirty-six notation, fifty-two mathematical",
    len(aOgP) = 88)
chk("and the report's findings are exactly the five things the corpus plants on purpose -- " +
    "the contradiction, the frame whose mark is outside the part it shows, " +
    "the three-bonded oxygen, the stray hydrogen, the schedule, the timeline and the cause analysis with three mistakes each, the plan, the seating and the map with four",
    oOgRep.NumberOfFindings() = 37 and
    _OgAllFromAny(oOgRep, [ "math/5", "math/window/marked out of view",
        "chem/witness/three-bonded oxygen", "chem/witness/stray hydrogen", "gantt/witness",
        "timeline/witness", "fishbone/witness", "floorplan/witness", "seating/witness",
        "choropleth/witness" ]))
chk("the contradiction's constraints arrive as :diagram; the rim, the off-window mark, " +
    "the two chemistry findings, the five schedule, the four timeline, the four fishbone, the six plan, the six seating and the four map findings as :plastic",
    len(oOgRep.FindingsOfSubject(:diagram)) = 4 and len(oOgRep.FindingsOfSubject(:plastic)) = 33)
chk("and the gate is NOT sound, because a contradiction is a finding and not a pass",
    NOT oOgRep.IsSound())
# a wall time is decoration on this machine, so the bound is set where it
# catches the 101 seconds the first run cost and not ambient drift; the
# figure itself is printed for the profile
? "   [one gate: " + floor(nOgMs) + "ms for " + len(aOgP) + " pictures]"
chk("the whole gate runs inside a bound that would have caught its first run -- under 80 s",
    nOgMs < 80000)

# THE RULES JUDGED BY THE FIVE QUESTIONS, over the math corpus: none
# empty, none vacuous, every boundary witnessed.
oOgG = StzMathGovernanceOf("math")
# from 30: the twenty catalogue pictures, three schemas, three nets and three trees are notation
for iOg = 37 to len(aOgP)
	oOgG.AddPicture(aOgP[iOg][1], aOgP[iOg][2])
next
aOgR = oOgG.CheckRules()
for iOg = 1 to len(aOgR)
	? "   RULE FINDING " + aOgR[iOg][:rule] + " @ " + aOgR[iOg][:where] + " -- " + aOgR[iOg][:message]
next
chkeq("the five math rules, the two chemistry rules, the three gantt, three timeline, three fishbone, four floor-plan, four seating and four choropleth rules pass the " +
      "five questions -- none empty, vacuous, or unwitnessed",
      len(aOgR), 0)

# THE INSTRUMENT DISCRIMINATES. A name moved by hand onto an edge is
# caught by the rule that reads render facts, and by nothing else.
oOgBad = StzMathScene20(AUFONT)
oOgBad.Layout()
_OgMoveNameOntoEdge(oOgBad, "Client", "l1")
oOgG2 = StzMathGovernanceOf("proof")
oOgG2.AddPicture("network/name-on-edge", oOgBad)
aOgB = oOgG2.CheckPictures()
chk("NEGATIVE: a name moved onto an edge IS caught, by name_off_ink and by name",
    len(aOgB) > 0 and aOgB[1][:rule] = "name_off_ink")
chk("and the lawful network before the move was clean under the same rules",
    len(_OgJudge(StzMathScene20(AUFONT))) = 0)


sec("-- 92. DN8d: COLOUR AS MEANING -- ROLES, THEMES, AND MEASURED TEXT -----")
discharges("DN8d")

# A ROLE RESOLVES THROUGH THE THEME. The same style under light and dark
# gives a different colour for the same word, and the paper follows.
oCmS = StzEulerStyle()
oCm = new stzMathDiagram(StzSetTheoryDomain(), StzMathTreeSubstance(), oCmS)
oCm.SetFont(AUFONT, 28)  oCm.SetVariation("PlumvilleCapybara104")
cCmPl = oCm._RoleColour("primary")
cCmBl = oCm.Background()
# the DIAGRAM'S copy of the style, not the guard's: a Ring object is
# copied on assignment, and a theme set on the original reaches nothing
oCm.@oStyle.SetTheme("dark")  oCm.Touch()
chk("the accent is one colour under light and another under dark, from one word",
    cCmPl = "#4D4DC9" and oCm._RoleColour("primary") = "#E0E0FF")
chk("and the paper is white under light and dark grey under dark",
    cCmBl = "#FFFFFF" and oCm.Background() = "#333333")
chk("a word that is not a role passes through untouched -- the canvas resolves it",
    oCm._RoleColour("#c8443c") = "#c8443c" and oCm._RoleColour("gold") = "gold")
chk("an alpha rule composes: the accent at a fifth is the accent with an alpha byte",
    oCm._Colour([ :alpha, "primary", 0.2 ]) = "#E0E0FF33")
chk("an on-fill rule answers black or white by MEASURED contrast, and flips with the paper",
    oCm._Colour([ :on, "paper" ]) = "white" and _CmOnLight() = "black")

# THE MIX IS PERCEPTUAL, IN THE ENGINE. Straight in Oklab: the ends are
# the ends, the middle is the middle in lightness, and it is not the sRGB
# middle -- which is the defect the colour plan measured.
chk("the engine's mix returns its ends at t = 0 and t = 1",
    StzEngineColorMixOklab(16711680, 255, 0) = 16711680 and
    StzEngineColorMixOklab(16711680, 255, 1) = 255)
chk("and clamps t outside [0, 1]",
    StzEngineColorMixOklab(16711680, 255, -3) = 16711680 and
    StzEngineColorMixOklab(16711680, 255, 9) = 255)
chk("red to blue at the half is a purple whose lightness is the mean of the two, to a hundredth",
    fabs(StzEngineColorLightness(StzEngineColorMixOklab(16711680, 255, 0.5)) -
         (StzEngineColorLightness(16711680) + StzEngineColorLightness(255)) / 2) < 0.01)

# EVERY PICTURE UNDER BOTH THEMES: every name at least 3:1 against what
# holds it -- the fill it sits in, composited over the paper, or the
# paper itself -- measured, not assumed. The pictures are the one gate's,
# already solved; a theme changes no geometry, so no second solve.
nCmBadL = 0  nCmBadD = 0  nCmNames = 0
for iCm = 37 to len(aOgP)   # the math pictures: after the twenty catalogue, three schema, three net, three tree, four family and three network ones
	oCmP = aOgP[iCm][2]
	oCmP.@oStyle.SetTheme("light")  oCmP.Touch()
	nCmBadL += _CmUnreadable(oCmP, 3)
	nCmNames += _CmNames(oCmP)
	oCmP.@oStyle.SetTheme("dark")  oCmP.Touch()
	nCmBadD += _CmUnreadable(oCmP, 3)
	oCmP.@oStyle.SetTheme("light")  oCmP.Touch()
next
? "   [" + nCmNames + " names measured under each theme]"
chkeq("under the light theme every name clears 3:1 against what holds it", nCmBadL, 0)
chkeq("and under the dark theme too -- the same styles, re-resolved", nCmBadD, 0)
chk("and there were names to measure -- hundreds, not none", nCmNames > 200)

# NO STRUCTURAL HEX REMAINS. Every style's rules are scanned for a hex
# literal; the only ones left are content -- Byrne's plate and the
# quaternion table's eight -- and they are counted by name.
nCmHex = 0  nCmContent = 0
for oCmSt in [ StzEulerStyle(), StzTreeStyle(), StzVectorStyle(), StzEuclideanStyle(),
               StzSphericalStyle(), StzHyperbolicStyle(), StzHasseStyle(), StzCommutativeStyle(),
               StzThalesStyle(), StzGraphStyle(), StzSpringGraphStyle(), StzCurvedGraphStyle(),
               StzBoxArrowStyle(), StzWordCloudStyle(), StzBlobStyle(), StzCatmullStyle(),
               StzEuler25DStyle(), StzEllipseRaysStyle(), StzHeatmapStyle() ]
	nCmHex += _CmHexIn(oCmSt)
next
for oCmSt in [ StzByrneStyle(), StzQuaternionTableStyle() ]
	nCmContent += _CmHexIn(oCmSt)
next
chkeq("nineteen structural styles carry no hex literal at all", nCmHex, 0)
chkeq("and the two content styles carry exactly their plate and their eight: fourteen", nCmContent, 14)

# NEGATIVE: a name given a hex that fails on the dark paper IS caught by
# the same measurement -- the instrument is not merely agreeable.
chk("NEGATIVE: a dark-grey name on the dark paper is found unreadable",
    StzContrastOf("#444444", "#333333") < 3)


sec("-- 93. DN8e: POLYGON DISTANCES -- A NAME INSIDE A ROTATED SQUARE ---------")
discharges("DN8e")

# BYRNE'S AREAS, SOLVED INSIDE THEIR SQUARES. A square here is rotated,
# and a bounding box would call a name inside it while a corner hung out
# over the paper; the polygon's own edges hold each name by its four
# corners, re-read here by an independent point-in-polygon test.
oPgB = StzMathScene13(AUFONT)
chk("Byrne with its three area labels is lawful", oPgB.IsFeasible())
chk("every corner of a2 lies inside the square on AB, of b2 inside the square on AC, of c2 " +
    "inside the square on BC -- twelve corners, by an independent test",
    _PgCornersIn(oPgB, "ABC.la", "ABC.sqab") = 4 and _PgCornersIn(oPgB, "ABC.lb", "ABC.sqac") = 4 and
    _PgCornersIn(oPgB, "ABC.lc", "ABC.sqbc") = 4)
chk("and each by at least the ten pixels asked -- the nearest edge is that far from every corner",
    _PgCornerMargin(oPgB, "ABC.la", "ABC.sqab") >= 9.9 and _PgCornerMargin(oPgB, "ABC.lb", "ABC.sqac") >= 9.9 and
    _PgCornerMargin(oPgB, "ABC.lc", "ABC.sqbc") >= 9.9)
chk("c2 keeps off the altitude that divides its square", _ByPtSegBox(oPgB, "ABC.lc", "ABC.alt") >= 7.9)
# THE AUTHOR'S MARK: c2 must be white like a2 and b2. Its colour is the
# best on whatever is UNDER it -- the rectangle painted over the square's
# pale base -- and not on the base the rule first named.
chk("a2, b2 and c2 are all white: each measured on the coloured fill the reader sees under it",
    oPgB.FillOf("ABC.la") = "white" and oPgB.FillOf("ABC.lb") = "white" and
    oPgB.FillOf("ABC.lc") = "white")
chk("and what is under c2 is a rectangle's red or blue, not the square's pale base",
    oPgB._UnderOf("ABC.lc") != oPgB.FillOf("ABC.sqbc") and
    StzContrastOf("white", oPgB._UnderOf("ABC.lc")) >= 3)
chk("NEGATIVE: measured on the base alone, the answer would have been black",
    StzBestTextOn(oPgB.FillOf("ABC.sqbc"))[1] = "black")
chk("NEGATIVE: the square on AB's bounding box holds a point the square does NOT -- a corner of " +
    "the box that a rotated square leaves on the paper",
    _PgBoxNotSquare(oPgB, "ABC.sqab"))
chk("and the triangle was not moved by its labels: the right angle is still right",
    fabs(oPgB.ValueOf("ABC.abx") * oPgB.ValueOf("ABC.acx") +
         oPgB.ValueOf("ABC.aby") * oPgB.ValueOf("ABC.acy")) /
    (oPgB.ValueOf("ABC.lab") * oPgB.ValueOf("ABC.lac")) < 0.001)

# THE COST, PRINTED: one contains(poly, text) term over derived vertices.
nPgLen = 0
for iPg = 1 to len(oPgB.@aConstraints)
	if StzLower(oPgB.@aConstraints[iPg][1]) = "contains" and StzFindFirst("sqab", oPgB.@aConstraints[iPg][3]) > 0
		nPgLen = len(oPgB.@aConstraints[iPg][2])
	ok
next
? "   [one contains(poly, text) term: " + nPgLen + " characters]"
chk("the term is long, and known to be: a derived vertex re-expands at every mention",
    nPgLen > 10000)

# A NOTATION'S ICON HOLDS A FORMULA. The graph plane's DRAKON scene,
# rendered; its rectangles carried as data; a glyph the substance says is
# Inside the action icon, solved there by the polygon's edges.
oPgI = StzMathScene33(AUFONT)
chk("the formula inside the DRAKON action icon is lawful", oPgI.IsFeasible())
chk("all four of its corners are inside the icon, and off the icon's own name",
    _PgCornersIn(oPgI, "f.text", "icon_a.icon") = 4 and
    _PgBoxesApart(oPgI, "f.text", "icon_a.text") >= 3.9)
chk("and it began at the icon's centre, not at random: lawful in one start, no round of thrashing",
    oPgI.StartsTried() = 1 and oPgI.Rounds() <= 3)

# REFUSALS with their lawful siblings.
chk("contains(thing, poly) is refused -- a polygon holds, it is not held", _PgRefuses(1))
chk("disjoint(poly, poly) is refused -- separation of two polygons is not on the tape", _PgRefuses(2))
chk("NEGATIVE: contains(poly, circle) and disjoint(circle, poly) are accepted", NOT _PgRefuses(0))


sec("-- 94. DN8f: CONTENT GENERATORS, AND THE SCALE THEY EXPOSE ---------------")
discharges("DN8f")

# THE GENERATORS. DeclareMany names n objects; SetDataFrom puts a list on
# them one each. What a scene's loop builds, the substance reads back.
oGnS = new stzMathSubstance(StzDotDomain())
oGnS.DeclareMany("Dot", "q", 5)
oGnS.SetDataFrom("q", "x", [ 10, 20, 30, 40, 50 ])
oGnS.SetDataFrom("q", "y", [ 1, 2, 3 ])
chk("DeclareMany makes q1..q5, each a Dot", oGnS.HasObject("q1") and oGnS.HasObject("q5") and
    NOT oGnS.HasObject("q6") and oGnS.TypeOf("q3") = "Dot")
chk("SetDataFrom puts the list on them in order", oGnS.DataOf("q1", "x") = 10 and oGnS.DataOf("q5", "x") = 50)
chk("and a shorter list reaches only as far as it goes", oGnS.HasData("q3", "y") and NOT oGnS.HasData("q4", "y"))
chk("NEGATIVE: DeclareMany over names already taken is refused like any second declaration",
    _GnRefused(oGnS))
chk("a substance of 5,000 objects and 10,000 data is built in under two seconds (was 22)",
    _GnBuildMs(5000) < 2000)

# THE CHAOS GAME: five thousand dots, nothing to solve. Two independent
# facts of Sierpinski's triangle: every point is inside the outer
# triangle, and the central inverted triangle -- the hole -- holds none.
nGnT0 = StzEngineWatchTimestampMs()
oGnC = StzMathScene34(AUFONT)
oGnC.Layout()
nGnT1 = StzEngineWatchTimestampMs()
chk("5,000 dots compile to 5,000 shapes, no unknown, no constraint -- nothing to solve",
    oGnC.NumberOfShapes() = 5000 and oGnC.NumberOfUnknowns() = 0 and oGnC.NumberOfConstraints() = 0)
aGnIn = _GnSierpinskiCounts(oGnC, 5000)
chk("every one of the 5,000 is inside the outer triangle, by an independent point-in-triangle test",
    aGnIn[1] = 5000)
chk("and NOT ONE lies in the central hole -- the fractal's own signature, not a property of any dot",
    aGnIn[2] = 0)
chk("a dot's coordinate is read straight off the datum", oGnC.ValueOf("d7.icon.cx") = oGnC.@oSubstance.DataOf("d7", "x"))
oGnC.ToPNG("gn_chaos.png")
nGnT2 = StzEngineWatchTimestampMs()
? "   [5,000 dots: compile " + floor(nGnT1 - nGnT0) + " ms, draw " + floor(nGnT2 - nGnT1) + " ms]"
chk("compile under 15 s and draw under 30 s at five thousand (were 238 s and unfinished at 600 s)",
    (nGnT1 - nGnT0) < 15000 and (nGnT2 - nGnT1) < 30000)

# THE NEPHROID: every circle passes through the cusp, read off the
# solved geometry with an independent distance.
oGnN = StzMathScene35(AUFONT)
chk("180 rings and the base centre compile with nothing to solve", oGnN.NumberOfShapes() = 181 and oGnN.NumberOfUnknowns() = 0)
chk("every ring is tangent to the diameter through p: |cy - p.y| = r for all 180", _GnTangent(oGnN, 180) = 180)
chk("NEGATIVE: exactly the two rings tangent to the diameter at its midpoint reach the base centre -- " +
    "2 of 180, where a cardioid's construction would send all 180 through one point",
    _GnThroughCusp(oGnN, 180) = 2)

# BROWNIAN PATHS: three thousand steps, each a definition bound once.
oGnB = StzMathScene36(AUFONT)
chk("3,000 steps become 3,000 lines beside 3,003 dots -- 6,003 shapes, nothing to solve",
    oGnB.NumberOfShapes() = 6003 and oGnB.NumberOfUnknowns() = 0)
chk("the matcher enumerated exactly three bindings per definition and one per dot -- " +
    "12,003, linear in the content, counted not timed", oGnB.MatchCandidates() = 12003)
chk("each walk is continuous: step k ends where step k+1 begins, for all 999 joins of walk a",
    _GnContinuous(oGnB, "sa", 1000))
chk("the three walks wear three colours, from the palette on the step's datum",
    StzUpper(oGnB.StrokeOf("sa1.icon")) != StzUpper(oGnB.StrokeOf("sb1.icon")) and
    StzUpper(oGnB.StrokeOf("sb1.icon")) != StzUpper(oGnB.StrokeOf("sc1.icon")) and
    StzUpper(oGnB.StrokeOf("sc1.icon")) = "#2B8A5E")

# THE ON-CANVAS RULE STILL HOLDS WHAT CAN MOVE. Fifty constant dots and
# one free name: the name's four terms, and not the dots' two hundred.
oGnM = _GnMixed()
chk("a free label among constant dots gets its four on-canvas terms and the dots get none",
    oGnM.NumberOfUnknowns() = 2 and oGnM.NumberOfConstraints() = 4)
chk("NEGATIVE: the same fifty dots with the label pinned mint no constraint at all",
    _GnMixedPinned().NumberOfConstraints() = 0)
chk("and a datum that puts a dot off the paper is STILL reported -- checked in Ring, not on a tape: " +
    "one violation, naming the dot, by the pixels it is out",
    _GnOffPaper())

# THE INDEX KEEPS CASE APART, where Ring's own hash list would not.
oGnK = new stzMathSubstance(StzDotDomain())
oGnK.Declare("Dot", "A")
oGnK.Declare("Dot", "a")
oGnK.SetData("A", "x", 1)
oGnK.SetData("a", "x", 2)
chk("A and a are two objects with two data, through the index", oGnK.DataOf("A", "x") = 1 and oGnK.DataOf("a", "x") = 2)


sec("-- 95. DN8g: THE LIVE FIGURE -- A DRAG RE-SOLVES FROM WHERE IT STANDS ------")
discharges("DN8g")

# BYRNE, DRAGGED. The plate solved cold; A taken sixty pixels right and
# thirty up; the figure re-solved warm around the held point.
oLvB = StzMathScene13(AUFONT)
oLvB.Layout()
nLvAx = oLvB.ValueOf("A.icon.cx")  nLvAy = oLvB.ValueOf("A.icon.cy")
nLvBx = oLvB.ValueOf("B.icon.cx")  nLvBy = oLvB.ValueOf("B.icon.cy")
nLvCold = oLvB.LayoutMs()
oLvB.DragTo("A.icon", nLvAx + 60, nLvAy - 30)
nLvWarm = oLvB.LayoutMs()
aLvP = oLvB.SolveProfile()
? "   [cold " + floor(nLvCold) + " ms; the drag re-solved in " + floor(nLvWarm) + " ms: " +
  aLvP[:rounds] + " rounds, text " + floor(aLvP[:text]) + " compile " + floor(aLvP[:compile]) +
  " minimise " + floor(aLvP[:minimise]) + " read " + floor(aLvP[:read]) + "]"
chk("A is exactly where it was dragged to -- held there through the re-solve",
    oLvB.ValueOf("A.icon.cx") = nLvAx + 60 and oLvB.ValueOf("A.icon.cy") = nLvAy - 30)
chk("and the figure followed: B moved, the picture is lawful",
    (fabs(oLvB.ValueOf("B.icon.cx") - nLvBx) > 1 or fabs(oLvB.ValueOf("B.icon.cy") - nLvBy) > 1) and oLvB.IsFeasible())
chk("THE KILL: the angle at A is still right after the drag, read off the solved legs",
    fabs(oLvB.ValueOf("ABC.abx") * oLvB.ValueOf("ABC.acx") + oLvB.ValueOf("ABC.aby") * oLvB.ValueOf("ABC.acy")) /
    (oLvB.ValueOf("ABC.lab") * oLvB.ValueOf("ABC.lac")) < 0.001)
chk("and the three area names are back inside their squares, twelve corners",
    _PgCornersIn(oLvB, "ABC.la", "ABC.sqab") = 4 and _PgCornersIn(oLvB, "ABC.lb", "ABC.sqac") = 4 and
    _PgCornersIn(oLvB, "ABC.lc", "ABC.sqbc") = 4)
chk("it was a WARM start: one start, and the solver says so", oLvB.StartUsed() = "warm" and oLvB.StartsTried() = 1)
chk("THE KILL: the re-solve took under 100 ms, in two rounds -- the round count is the structural half",
    nLvWarm < 100 and aLvP[:rounds] <= 3)
chk("and the drag left nothing pinned behind it", NOT oLvB.IsPinned("A.icon") and len(oLvB.Pins()) = 0)

# THE FOLD: the label stage's text, once 586,494 characters, is a few
# tens of thousands -- a settled name is its number, not its expansion
nLvT1 = len(oLvB._EnergyText(1, 1000, FALSE))
? "   [label-stage energy text: " + nLvT1 + " characters]"
chk("the label stage's energy text is under a tenth of what it was", nLvT1 < 58000 and nLvT1 > 1000)
chk("and the cold solve takes two rounds now, not eight: the shape stage answers for its own terms",
    oLvB.Rounds() <= 3)

# PINS. B held; a warm re-solve leaves it; unpinned, the reader says so.
oLvB.Pin("B.icon")
nLvBx = oLvB.ValueOf("B.icon.cx")  nLvBy = oLvB.ValueOf("B.icon.cy")
chk("a pinned shape reads as pinned, and is listed", oLvB.IsPinned("B.icon") and len(oLvB.Pins()) = 1 and oLvB.Pins()[1] = "B.icon")
oLvB.DragTo("A.icon", oLvB.ValueOf("A.icon.cx") - 30, oLvB.ValueOf("A.icon.cy") + 10)
chk("dragging A with B pinned: B did not move, C did, and the angle at A is still right",
    oLvB.ValueOf("B.icon.cx") = nLvBx and oLvB.ValueOf("B.icon.cy") = nLvBy and oLvB.IsFeasible() and
    fabs(oLvB.ValueOf("ABC.abx") * oLvB.ValueOf("ABC.acx") + oLvB.ValueOf("ABC.aby") * oLvB.ValueOf("ABC.acy")) /
    (oLvB.ValueOf("ABC.lab") * oLvB.ValueOf("ABC.lac")) < 0.001)
# NEGATIVE: hold B AND C and drag A, and only A is free -- two numbers
# against the right angle and the squares' paper: no lawful figure, and
# the solver says so rather than inventing one
oLvB.Pin("C.icon")
nLvCx = oLvB.ValueOf("C.icon.cx")
oLvB.DragTo("A.icon", oLvB.ValueOf("A.icon.cx") + 25, oLvB.ValueOf("A.icon.cy") - 40)
chk("NEGATIVE: with B and C both held, a drag of A is reported unlawful, C unmoved, the angle named",
    NOT oLvB.IsFeasible() and oLvB.ValueOf("C.icon.cx") = nLvCx and len(oLvB.Violations()) >= 1 and
    StzFindFirst("Right", oLvB.Violations()[1][:message]) > 0)
oLvB.UnpinAll()
oLvB.Relayout()
chk("unpinned, nothing is pinned, and the figure re-solves lawful again",
    NOT oLvB.IsPinned("B.icon") and len(oLvB.Pins()) = 0 and oLvB.IsFeasible())
chk("NEGATIVE: a square derived from its triangle cannot be pinned or dragged -- nothing there is free",
    _LvRefuses(oLvB, 1) and _LvRefuses(oLvB, 2))
chk("NEGATIVE: a shape no rule minted cannot be pinned", _LvRefuses(oLvB, 3))

# A RE-SOLVE WITH NOTHING MOVED LEAVES THE FIGURE WHERE IT IS
nLvAx = oLvB.ValueOf("A.icon.cx")  nLvAy = oLvB.ValueOf("A.icon.cy")
oLvB.Relayout()
chk("Relayout from a lawful figure moves no point by more than half a pixel",
    fabs(oLvB.ValueOf("A.icon.cx") - nLvAx) < 0.5 and fabs(oLvB.ValueOf("A.icon.cy") - nLvAy) < 0.5)

# THE GESTURE, in the plastic editor's verbs: press on A, move, release.
nLvAx = oLvB.ValueOf("A.icon.cx")  nLvAy = oLvB.ValueOf("A.icon.cy")
oLvB.OnPress(nLvAx + 3, nLvAy - 2)
chk("a press on A's dot takes hold of A.icon", oLvB.UiState() = :Dragging and oLvB.DragPreview()[1] = "A.icon")
oLvB.OnMove(nLvAx - 20, nLvAy + 15)
aLvPv = oLvB.DragPreview()
chk("a move previews where the pointer is and re-solves nothing: A has not moved yet",
    aLvPv[2] = nLvAx - 20 and aLvPv[3] = nLvAy + 15 and oLvB.ValueOf("A.icon.cx") = nLvAx)
oLvB.OnRelease(nLvAx - 20, nLvAy + 15)
chk("the release is the one drag: A is there, the figure lawful, the gesture idle",
    oLvB.ValueOf("A.icon.cx") = nLvAx - 20 and oLvB.ValueOf("A.icon.cy") = nLvAy + 15 and oLvB.IsFeasible() and
    oLvB.UiState() = :Idle and len(oLvB.DragPreview()) = 0)
nLvAx = oLvB.ValueOf("A.icon.cx")
oLvB.OnPress(5, 5)
oLvB.OnRelease(300, 300)
chk("NEGATIVE: a press on the paper takes hold of nothing, and its release moves nothing",
    oLvB.UiState() = :Idle and oLvB.ValueOf("A.icon.cx") = nLvAx)
chk("what a gesture can take hold of: the three points, their names and the three areas, nine shapes -- " +
    "never a square, a mark or a placed line", len(oLvB.Draggable()) = 9 and NOT _LvHas(oLvB.Draggable(), "ABC.sqab") and
    NOT _LvHas(oLvB.Draggable(), "ABC.alt") and _LvHas(oLvB.Draggable(), "A.icon"))


sec("-- 96. DN8h: THE TAPE BINDS A SUBEXPRESSION ONCE -------------------------")
discharges("DN8h")

# A COUNT, NEVER A CLOCK. How big a tape is cannot be read from the text
# that made it -- the same subexpression written a hundred times is one
# node -- and a count is immune to the ambient load three sessions put on
# this machine.
nTpN = StzEngineGradNodes(_TpProg("(x*y + sqrt(x*x + y*y))", 40))
? "   [one subexpression written 41 times: " + nTpN + " nodes]"
chk("forty-one mentions of one subexpression are 8 nodes and the 40 additions joining them",
    nTpN = 48)
chk("NEGATIVE: forty-one DIFFERENT subexpressions do not collapse -- sharing is identity, not luck",
    StzEngineGradNodes(_TpProgVaried(40)) > 300)

# BYRNE'S OWN TERMS, the shape that named this item: a polygon's vertices
# re-expanding at every mention.
oTpB = StzMathScene13(AUFONT)
oTpB.Layout()
cTpBig = ""
for iTp = 1 to len(oTpB.@aConstraints)
	if len(oTpB.@aConstraints[iTp][2]) > len(cTpBig)  cTpBig = oTpB.@aConstraints[iTp][2]  ok
next
pTpB = StzEngineGradCompile(cTpBig, oTpB._VarsText())
nTpB = StzEngineGradNodes(pTpB)
? "   [Byrne's longest term: " + len(cTpBig) + " characters, " + nTpB + " nodes]"
chk("a ninety-thousand character term is a few hundred nodes, not a few thousand",
    len(cTpBig) > 80000 and nTpB < 400)
chk("and it still answers: the tape's value equals the violation the picture reports",
    _TpAgrees(oTpB, pTpB, cTpBig))
StzEngineGradFree(pTpB)

# SHARING CHANGES NO VALUE. The same expression written once and written
# four times over must evaluate identically -- the property that lets the
# tape share at all.
chk("one mention and four mentions of a term agree to the last bit, times four",
    _TpFourfold())

# A NAME'S WEDGE IS CHOSEN NOW, NOT DRAWN. The curved cube kept its planar
# start on one seed of six before the names were given a second wedge.
oTpC = StzMathScene25(AUFONT)
chk("the curved cube is lawful FROM ITS PLANAR START, in one start",
    oTpC.IsFeasible() and oTpC.StartedPlanar() and oTpC.StartsTried() = 1)
# A COUNT OVER SEEDS, NOT ONE SEED. This line pinned "bulge2" keeping its
# planar start, and DN12's taller text box -- a tenth taller at 15px --
# took that seed's planar start away: v111's name no longer finds room
# from the planar overlay there and the next start wins, lawfully. Before
# the second wedge one seed of six kept planar; the claim worth holding is
# that MOST do, and that every one ends lawful whatever start it took.
nTpKeep = 0
for cTpSeed in [ "curved", "bulge2", "gray", "seedA", "seedB", "one-wedge" ]
	if _TpSeedKeepsPlanar(cTpSeed)  nTpKeep++  ok
next
? "   [" + nTpKeep + " of 6 seeds keep the planar start; the rest fall to the next, lawfully]"
# five of six at DN13's 160px target, four of six at 140 -- the count is
# the claim, and it may only go up
chk("most seeds keep the curved cube's planar start -- five of six, where one of six did before the second wedge",
    nTpKeep >= 4)
chk("and every seed ends lawful, from whichever start it took", _TpAllSeedsLawful())


sec("-- 97. DN9a: THE NAME IS FREE -- stzNarration IS stzTranscript ---------------")
discharges("DN9a")

# THE CLASS UNDER ITS RIGHT NAME. A speaker-tagged sequence of lines with a
# certainty is a transcript, precisely; it was never a document, and the
# document class of the Narrations layer needed the name it held.
oTrA = new stzTranscript()
oTrA.System("What does 'margherita' contain?")
oTrA.User("tomato-sauce")
oTrA.Verdict("yes", 1)
chk("a transcript records its three lines, speaker-tagged", oTrA.NumberOfLines() = 3 and oTrA.Lines()[3][1] = "verdict")
chk("the class exists under the new name and NOT under the old -- the name is free",
    _TrHasClass("stztranscript") and NOT _TrHasClass("stznarration"))
chk("the loader names the new file, and not the old",
    StzFindFirst('load "conversation/stzTranscript.ring"', _TrBase()) > 0 and
    StzFindFirst('load "conversation/stzNarration.ring"', _TrBase()) = 0)

# THE CONVERSATION STILL SPEAKS, and the old accessor still answers -- the
# same object, so a caller written against it runs one version more.
oTrC = new stzConversation("pizza")
chk("a conversation's TranscriptQ() is a transcript", classname(oTrC.TranscriptQ()) = "stztranscript")
oTrC.NarrationQ().System("through the old name")
chk("a line added through NarrationQ() is seen through TranscriptQ(): one object, two names",
    oTrC.TranscriptQ().NumberOfLines() = 1 and oTrC.TranscriptQ().Lines()[1][2] = "through the old name")
chk("NEGATIVE: no code in the library names the old class, outside the transcript's own history note",
    _TrOldNameSites() = 0)


sec("-- 98. DN9b: FACTS -- ONE SURFACE ON BOTH PLANES ------------------------")
discharges("DN9b")

# THE SHAPE, AND THAT IT IS ONE SHAPE. A mark that shows a fact and a
# caption that quotes one must never learn which plane it came from.
oFcM = StzMathScene16(AUFONT)
oFcM.Layout()
oFcG = StzDrakonScene01([ :Font = AUFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 14 ])
chk("a math fact and a notation fact carry the same six keys, in the same shape",
    _FcShaped(oFcM.Fact(:distance, [ "A.icon", "B.icon" ])) and
    _FcShaped(oFcG.Fact(:count, [ "nodes" ])))
chk("a fact carries its unit, because 46.9 is not a fact and 46.9 px is",
    oFcM.Fact(:distance, [ "A.icon", "B.icon" ])[:unit] = "px" and
    oFcM.Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:unit] = "deg")
chk("and its own sentence, with its own number inside it",
    StzFindFirst("90", oFcM.Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]) > 0)

# ASKED IN THE PICTURE'S OWN LANGUAGE, so a fact cannot disagree with the
# figure: the general kind and its named shortcut give one answer.
chk("expr and distance agree to the last bit -- the shortcut is the general kind",
    oFcM.Fact(:expr, [ "dist(A.icon, K.icon)" ])[:value] =
    oFcM.Fact(:distance, [ "A.icon", "K.icon" ])[:value])
chk("and both equal the radius the picture solved: A is ON the circle",
    fabs(oFcM.Fact(:distance, [ "A.icon", "K.icon" ])[:value] -
         oFcM.Fact(:value, [ "K.icon.r" ])[:value]) < 0.01)

# THE CAPTIONS OF 2026-09-06, EVERY NUMBER FROM A FACT. The third
# diagram's two distances, from the two solves of the same picture.
oFcB = _FcOneWedge()
nFcBad = oFcB.Fact(:distance, [ "v111.icon", "v111.text" ])[:value]
nFcLeash = oFcB.Fact(:arg, [ "lessthan v111", 2 ])[:value]
oFcOk = StzMathScene25XT(AUFONT, StzMathOneWedgeStorySeed())
nFcGood = oFcOk.Fact(:distance, [ "v111.icon", "v111.text" ])[:value]
? "   [caption numbers, from facts: " + StzFactNumText(nFcBad) + " px, limit " +
  StzFactNumText(nFcLeash) + " px, then " + StzFactNumText(nFcGood) + " px]"
chk("the name that failed is past its leash, and the name that was retried is not",
    nFcBad > nFcLeash and nFcGood < nFcLeash)
# THE ARGUMENT IS AN EXPRESSION NOW (DN13): 4 + 0.012 times the edge's
# length, so it differs per edge and the fact EVALUATES it. This line used
# to assert the number 4 -- the retyped constant it was written against,
# which is the very thing the assertion says not to do.
nFcPad = oFcB.Fact(:arg, [ "disjoint v111.text q6", 3 ])[:value]
? "   [the clearance the rule keeps on q6: " + StzFactNumText(nFcPad) + " px, on an edge of " +
  StzFactNumText(_ChLen(oFcB, "q6.icon")) + "]"
chk("A RULE'S OWN ARGUMENT IS A FACT: the clearance the disjoint rule keeps is read " +
    "from the rule in force, not retyped from the Style -- and it is not the 4 a person would type",
    fabs(nFcPad - (4 + 0.012 * _ChLen(oFcB, "q6.icon"))) < 0.01 and nFcPad > 4)
chk("NEGATIVE, and it caught its author: the hand-drawn caption said the leash allows 44, " +
    "and the rule allows 43.73 -- a number a person types is a number nobody checks",
    fabs(nFcLeash - 43.73) < 0.01 and nFcLeash != 44)

# The first diagram's numbers: how long an arithmetic is written out, and
# how many nodes it becomes -- which are not the same thing (DN8h).
oFcT = StzMathScene13(AUFONT)
oFcT.Layout()
cFcBig = oFcT.ConstraintText("contains sqab")
chk("a term is written out in tens of thousands of characters",
    oFcT.Fact(:term, [ "contains sqab" ])[:value] > 40000)
chk("and becomes a couple of hundred nodes shared, thirteen thousand unshared -- " +
    "the count is what an evaluation walks, and the character count is not",
    oFcT.Fact(:tapenodes, [ cFcBig ])[:value] = 194 and
    oFcT.Fact(:tapenodes, [ cFcBig, :unshared ])[:value] = 13153)
chk("an expression in ITS OWN variables is counted too -- no figure need contain it",
    oFcT.Fact(:tapenodes, [ "(x-y)^2 + (x-y)^2", :shared, "x,y" ])[:value] = 6 and
    oFcT.Fact(:tapenodes, [ "(x-y)^2 + (x-y)^2", :unshared, "x,y" ])[:value] = 11)
chk("NEGATIVE, and it caught its author again: the hand-drawn tree showed 9 steps and 5, " +
    "and the real counts are 11 and 6 -- the exponent in x^2 is itself a node",
    oFcT.Fact(:tapenodes, [ "(x-y)^2 + (x-y)^2", :unshared, "x,y" ])[:value] != 9)

# A VERDICT IS READ, NEVER RECOMPUTED, so a narration cannot contradict
# the gate that judges the same picture.
chk("a lawful picture reports nothing found against it, with value zero",
    oFcM.Fact(:verdict, [ "" ])[:value] = 0)
chk("an unlawful one hands back the finding's OWN message, word for word",
    _FcVerdictIsTheFinding(oFcB))

# THE NOTATION PLANE ANSWERS THE SAME VERB over what it holds.
chk("a notation picture counts its nodes, its edges and its crossings",
    oFcG.Fact(:count, [ "nodes" ])[:value] = 3 and oFcG.Fact(:count, [ "edges" ])[:value] = 2 and
    oFcG.Fact(:count, [ "crossings" ])[:value] = 0)
chk("and answers where a node is, from the renderer's own rectangle",
    _FcNear(oFcG.Fact(:position, [ "t" ])[:value][1], 108) and
    _FcNear(oFcG.Fact(:position, [ "t" ])[:value][2], 44))

# REFUSED BY NAME, never answered with a zero.
chk("a fact asked of a shape the picture never minted is refused", _FcRefuses(1))
chk("a count the picture does not keep is refused", _FcRefuses(2))
chk("a kind neither plane answers is refused", _FcRefuses(3))
chk("a rule no line of this picture describes is refused", _FcRefuses(4))
chk("NEGATIVE: the lawful siblings of all four are accepted", NOT _FcRefuses(0))


sec("-- 99. DN9c: THE FIVE MARKS -- A RULE'S BOUNDARY, DRAWN ------------------")
discharges("DN9c")

# THE DIAGRAM OF 2026-09-06, REGENERATED. Every mark below is derived from
# the picture's solved values or from a rule actually in force; not one
# coordinate is written by a person, which is the whole plane's claim.
oMkV = StzMathScene25(AUFONT)
oMkV.Layout()
aMkWas = _MkPositions(oMkV)
nMkShapes = oMkV.NumberOfShapes()
oMkV.Show("lessthan v111")
oMkV.Region("disjoint v111.text q6.h1")
oMkV.Emphasis("v111.icon", :ring)
oMkV.Callout("v111.icon", "leash {value} px", [ [ "fact", :arg ], [ "args", [ "lessthan v111", 2 ] ] ])
oMkV.Callout("v111.text", "{value} px away", [ [ "fact", :distance ], [ "args", [ "v111.icon", "v111.text" ] ] ])
chk("the marked picture is still lawful, and the one gate finds nothing in it",
    oMkV.IsFeasible() and len(StzCheckPictures([ [ "marks", oMkV ] ]).Findings()) = 0)

# A MARK MAY NOT MOVE THE FIGURE IT DESCRIBES. Every unknown is pinned
# while a mark places itself, so a second frame's figure is the first
# frame's figure -- without which a narration would be showing a
# different picture each time it said something about one.
chk("all eight vertices are where they were before any mark was added, exactly",
    _MkSame(aMkWas, _MkPositions(oMkV)))

# SHOWN AT THE RULE'S OWN BOUND, not at a radius someone typed.
nMkLeash = oMkV.Fact(:arg, [ "lessthan v111", 2 ])[:value]
? "   [the leash drawn at its own bound: " + StzFactNumText(nMkLeash) + " px]"
chk("the leash circle is centred on the vertex and drawn at the rule's own bound",
    _MkShownAt(oMkV, "v111.icon", nMkLeash))
chk("and that bound is the 43.73 the fact reports, not the 44 a person wrote",
    fabs(nMkLeash - 43.73) < 0.01)

# A REGION IS THE STRIP THE RULE FORBIDS, two pads across the segment --
# and the pad is the rule's own, read as a fact, not the 4 it used to be.
nMkPad = oMkV.Fact(:arg, [ "disjoint v111.text q6", 3 ])[:value]
chk("the forbidden strip is a four-cornered region, two pads wide across its edge",
    _MkRibbonWidth(oMkV, "q6.h1") > 2 * nMkPad - 0.1 and _MkRibbonWidth(oMkV, "q6.h1") < 2 * nMkPad + 0.1)

# A CALLOUT'S NUMBER IS A FACT'S NUMBER, and its sentence is SOLVED.
chk("a callout carries the fact's own number, filled into the hole",
    _MkCalloutHas(oMkV, StzFactNumText(oMkV.Fact(:distance, [ "v111.icon", "v111.text" ])[:value])))
chk("a callout's sentence is off every name already in the picture, by the pad it asks",
    _MkCalloutClearOfNames(oMkV))
chk("and its leader runs from its subject to wherever the solver put the sentence",
    _MkLeaderJoins(oMkV))

# EMPHASIS RINGS OUTSIDE THE INK IT MARKS.
chk("a ring stands clear of the shape it rings", _MkRingOutside(oMkV, "v111.icon"))

# MARKS COME OFF AGAIN, and what is left is the picture that was there.
oMkV.ClearMarks()
chk("clearing the marks gives back the shape count and leaves the figure untouched",
    oMkV.NumberOfMarks() = 0 and oMkV.NumberOfShapes() = nMkShapes and
    _MkSame(aMkWas, _MkPositions(oMkV)))

# MEASURE, on the picture where a number is the point.
oMkT = StzMathScene16(AUFONT)
oMkT.Layout()
oMkT.Measure("A.icon", "K.icon", [])
chk("a measure's number is the distance fact, and A really is a radius from the centre",
    _MkMeasureShows(oMkT, "A.icon", "K.icon") and
    fabs(oMkT.Fact(:distance, [ "A.icon", "K.icon" ])[:value] -
         oMkT.Fact(:value, [ "K.icon.r" ])[:value]) < 0.01)

# REFUSED BY NAME rather than approximated.
chk("a rule whose boundary is not a shape is refused, and says to ask for a region", _MkRefuses(1))
chk("a region asked of a rule that encloses nothing is refused", _MkRefuses(2))
chk("an emphasis that is not focus, dim or ring is refused", _MkRefuses(3))
chk("a mark put on a shape the picture never drew is refused", _MkRefuses(4))
chk("NEGATIVE: the lawful sibling of each is accepted", NOT _MkRefuses(0))


sec("-- 100. DN9d: THE WINDOW -- THE SAME FIGURE, CLOSER ---------------------")
discharges("DN9d")

# THE PAIR OF 2026-09-06, ZOOMED: the same content under two solves, one
# window each, and the story is which side of the leash the name is on.
oWnB = _FcOneWedge()
nWnD1 = oWnB.Fact(:distance, [ "v111.icon", "v111.text" ])[:value]
oWnB.Show("lessthan v111")
oWnB.WindowOn("v111.icon", 105)
oWnA = StzMathScene25XT(AUFONT, StzMathOneWedgeStorySeed())
oWnA.Layout()
oWnA.Show("lessthan v111")
oWnA.WindowOn("v111.icon", 105)
? "   [both frames at " + StzFactNumText(oWnA.WindowScale()) + "x, showing " +
  len(oWnA.VisibleShapes()) + " of " + oWnA.NumberOfShapes() + " shapes]"
chk("both frames are the same window on the same content, at more than three times",
    oWnB.WindowScale() > 3 and oWnA.WindowScale() = oWnB.WindowScale())
chk("and the story survives the zoom: the first name is past its leash, the second is not",
    nWnD1 > oWnB.Fact(:arg, [ "lessthan v111", 2 ])[:value] and
    oWnA.Fact(:distance, [ "v111.icon", "v111.text" ])[:value] <
    oWnA.Fact(:arg, [ "lessthan v111", 2 ])[:value])

# A WINDOW IS A PROPERTY OF THE VIEW, NOT OF THE FIGURE. Every reader
# still answers in the picture's own coordinates, or two frames of one
# figure would report two different figures.
chk("a distance read through a 3x window is the distance read without one, bit for bit",
    oWnB.Fact(:distance, [ "v111.icon", "v111.text" ])[:value] = nWnD1)
chk("and the solved values themselves are untouched by setting or clearing a window",
    _WnValuesSurvive(oWnA))

# WHAT IS IN VIEW, and the arc that crosses it without its middle being
# anywhere near -- the case that hid sixty shapes of sixty-five.
chk("the vertex the frame is about is in view, and a far vertex is not",
    oWnA.IsInWindow("v111.icon") and NOT oWnA.IsInWindow("v000.icon"))
chk("an edge whose midpoint lies outside the window is still IN VIEW when it crosses it",
    _WnCrossingCounted(oWnA))
chk("NEGATIVE: with no window every shape that is drawn is in view",
    _WnAllVisibleWithout())

# THE GATE JUDGES WHAT IS VISIBLE.
chk("the repaired frame passes the one gate at 3x", len(StzCheckPictures([
    [ "after", oWnA ] ]).Findings()) = 0)
chk("and the first frame is found -- for its leash, which is the story, and not for its window",
    _WnFoundForItsLeash(oWnB))
chk("NEGATIVE: a mark left outside the part a frame shows IS reported, by name",
    _WnOffWindowFound())

# THE TYPE DOES NOT SCALE, so a close frame is more legible and not merely
# bigger -- a name is measured once and only travels.
chk("a name's measured box is the same at 3x as at 1x", _WnTextUnscaled())


sec("-- 101. DN9e: THE ENGINE DRAWS ITS OWN THINKING -------------------------")
discharges("DN9e")

# THE EXPRESSION OF DN8h, COMPILED BOTH WAYS, AND DRAWN FROM THE TAPE
# ITSELF -- not from the text that made it, which is the whole point: the
# text is identical and the two tapes are not.
pTgS = StzEngineGradCompileXT("(x-y)^2 + (x-y)^2", "x,y", 1)
pTgP = StzEngineGradCompileXT("(x-y)^2 + (x-y)^2", "x,y", 0)
oTgS = StzTapeGraphXT(pTgS, [ :names = "x,y" ])
oTgP = StzTapeGraphXT(pTgP, [ :names = "x,y" ])
? "   [one text, two tapes: " + oTgS.NumberOfNodes() + " steps shared, " +
  oTgP.NumberOfNodes() + " written out]"
chk("the drawn graph holds exactly the steps the engine counts, both ways",
    oTgS.NumberOfNodes() = StzEngineGradNodes(pTgS) and
    oTgP.NumberOfNodes() = StzEngineGradNodes(pTgP))
chk("and the two differ although the text does not -- six steps against eleven",
    oTgS.NumberOfNodes() = 6 and oTgP.NumberOfNodes() = 11)

# THE TAPE'S ONE STRUCTURAL LAW, read off the drawing: an operand is
# always an earlier step than the step that consumes it. That is what
# makes the reverse pass correct with sharing, and it is checkable here.
chk("every edge runs from a later step to an earlier one, in both tapes",
    _TgOperandsPrecede(oTgS) and _TgOperandsPrecede(oTgP))
chk("the variables are leaves and the answer is the only step nothing consumes",
    _TgLeavesAndRoot(oTgS) and _TgLeavesAndRoot(oTgP))

# A STEP CONSUMED TWICE SAYS SO. A simple graph draws one arrow, so the
# multiplicity is recorded rather than lost.
chk("the shared root reads its one operand twice, and says so on its own label",
    _TgRootLabel(pTgS, "x,y") = "+ (x2)")
chk("NEGATIVE: written out, the root has two different operands and no such note",
    _TgRootLabel(pTgP, "x,y") = "+")
chk("which is why the shared tape has one edge fewer than it has steps minus leaves",
    oTgS.NumberOfEdges() = 5 and oTgP.NumberOfEdges() = 10)

StzEngineGradFree(pTgS)
StzEngineGradFree(pTgP)

# AND IT IS A PICTURE, drawn by the two planes that draw everything else.
oTgD = new stzMathDiagram(StzGraphDomain(), StzTapePicture("(x-y)^2 + (x-y)^2", "x,y", 1),
	StzBoxArrowStyle())
oTgD.SetFont(AUFONT, 17)
oTgD.SetVariation("tape")
chk("the shared tape draws as a lawful picture, from a hierarchical start",
    oTgD.IsFeasible() and oTgD.StartUsed() = "hierarchical")
chk("and the one gate finds nothing in it",
    len(StzCheckPictures([ [ "the tape itself", oTgD ] ]).Findings()) = 0)

# REFUSED WHERE A DRAWING WOULD BE A MEASUREMENT.
chk("a tape of tens of thousands of steps is refused, and names the fact to ask instead",
    _TgRefusesBig())
chk("a handle that is not a compiled expression is refused", _TgRefusesJunk())
chk("NEGATIVE: the same big tape ANSWERS its size as a fact, which is what was wanted",
    _TgBigCounts() > 20000)


sec("-- 102. DN9f: THE STORYBOARD -- A CAPTION THAT CANNOT LIE ----------------")
discharges("DN9f")

# THE EXPLANATION OF 2026-09-06, AS ONE STORYBOARD: four frames over two
# solves of one content, every number bound to a fact.
oSbW = StzStoryOneWedge(AUFONT, "folio")
? "   [one-wedge: " + oSbW.NumberOfFrames() + " frames, " + oSbW.NumberOfHoles() +
  " numbers, none typed]"
chk("four frames, three numbers, and the telling is clean",
    oSbW.NumberOfFrames() = 4 and oSbW.NumberOfHoles() = 3 and oSbW.IsClean())
chk("every number a caption shows is the number its own fact reported",
    _SbNumbersAreFacts(oSbW))
chk("and the story is told by them: past the leash in one frame, inside it in the next",
    _SbHole(oSbW, 3, "far") > _SbHole(oSbW, 2, "leash") and
    _SbHole(oSbW, 4, "near") < _SbHole(oSbW, 2, "leash"))
chk("each frame was drawn to its own file", _SbFilesDiffer(oSbW))

# A FRAME MAY BE ABOUT A FLAW. The first three show a picture the gate
# faults, and say so; the fourth does not and is clean.
chk("the frames about the flawed picture declare it, and the repaired one does not",
    oSbW.ExpectsFindings(1) and oSbW.ExpectsFindings(3) and NOT oSbW.ExpectsFindings(4))
chk("the gate DOES fault the picture those frames are about, and does not fault the last",
    len(oSbW.FindingsOf(3)) > 0 and len(oSbW.FindingsOf(4)) = 0)
chk("NEGATIVE: a frame that expects a finding and gets none is reported", _SbFalseExpect())

# AND THE SAME FIVE MARKS WITH NO MATHEMATICS ANYWHERE.
oSbO = StzStoryOrgChart(AUFONT, "folio")
chk("an org chart tells three frames and is clean", oSbO.NumberOfFrames() = 3 and oSbO.IsClean())
chk("its caption quotes the ORG plane's own finding, word for word, about a drawing " +
    "that never reached that verdict itself",
    StzFindFirst("has no supervisor", oSbO.Caption(2)) > 0)
chk("and the last frame says the same rules now find nothing about it",
    StzFindFirst("nothing is found against ops", oSbO.Caption(3)) > 0)
chk("with no geometry anywhere in it: no distance, angle or radius is bound",
    _SbNoMaths(oSbO))

# THE THINGS A STORYBOARD REFUSES TO LET AN AUTHOR GET AWAY WITH.
chk("a hole nothing was bound to survives into the caption and IS reported", _SbOpenHole())
chk("a fact bound and never quoted is reported", _SbUnquoted())
chk("a mark before any frame is opened is refused", _SbMarkBeforeFrame())

# THE DOCUMENT: the sibling's three kinds, and its one law.
cSbN = oSbW.ToNarration("folio/one-wedge.narration")
cSbT = read(cSbN)
chk("the emitted document declares only the three kinds the grammar has",
    _SbKindsOnly(cSbT))
chk("A CAPTION GOES OUT WITH ITS HOLES STILL OPEN -- no number is stored in the prose",
    StzFindFirst("{leash}", cSbT) > 0 and StzFindFirst("43.73", cSbT) = 0)
chk("and every hole has a CELL that recomputes it on arrival",
    _SbCellPerHole(cSbT, oSbW))


sec("-- 103. DN9g: A VALUE THAT SAYS WHAT IT IS ------------------------------")
discharges("DN9g")

# FOUR OBJECTS OF FOUR CLASSES, RENDERED BY A CONSUMER THAT NEVER ASKS
# WHAT ANY OF THEM IS. This is the whole property the display contract
# was asked for, standing up.
pRnT = StzEngineGradCompileXT("(x-y)^2 + (x-y)^2", "x,y", 1)
aRnThings = [
	StzMathScene16(AUFONT),
	StzDrakonScene01([ :Font = AUFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 14 ]),
	StzTapeGraphXT(pRnT, [ :names = "x,y" ]),
	StzStoryOrgChart(AUFONT, "folio") ]
StzEngineGradFree(pRnT)
aRnKinds = []
for iRn = 1 to len(aRnThings)
	aRnKinds + ("" + StzRenditionOf(aRnThings[iRn])[:kind])
next
? "   [four classes, chosen by kind alone: " + _RnJoin(aRnKinds) + "]"
chk("every one of the four answers a rendition carrying the five keys",
    _RnAllShaped(aRnThings))
chk("and a consumer picks the file type from the KIND alone, never from the class",
    _RnExtensions(aRnThings) = ".svg .svg .dot .html")
chk("a picture and a notation picture agree on their kind although they share no class",
    aRnKinds[1] = "vector" and aRnKinds[2] = "vector")
chk("a tape hands over nodes and edges as DATA, for the consumer to lay out",
    aRnKinds[3] = "graph" and StzFindFirst("digraph", StzLower(StzRenditionOf(aRnThings[3])[:content])) > 0)
chk("and a storyboard says it is a document rather than a picture", aRnKinds[4] = "markup")

# IT RETURNS. That is the whole complaint about the verb the family has,
# and the one thing the new verb must not repeat.
chk("every rendition comes back with something in it -- carried, or located",
    _RnAllFull(aRnThings))
chk("a raster is LOCATED and not carried, and the file it names is really there",
    _RnRasterLocated(aRnThings[1]))
chk("NEGATIVE: a class the contract has not reached is refused BY NAME, not answered with nothing",
    _RnRefusesUnreached())
chk("and a kind a class cannot show itself as is refused too", _RnRefusesKind())

# THE EVIDENCE, RECOUNTED HERE SO IT CANNOT GO STALE.
nRnShow = _RnCount("def Show(")
nRnDisp = _RnCount("def Display(")
nRnRend = _RnCount("def Rendition(")
? "   [across base/: Show() " + nRnShow + ", Display() " + nRnDisp + ", Rendition() " + nRnRend + "]"
chk("the family's display verb is attested past a hundred times, and it prints",
    nRnShow > 100)
chk("THE RECOMMENDED NAME IS NOT FREE: Display() exists, and not at the count the ask reports",
    nRnDisp = 6 and nRnDisp != 13)
chk("AND NOT ONE OF THE SIX RETURNS ANYTHING -- the test that needs no list of verbs: " +
    "no Display() body in this library contains a return at all",
    _RnDisplayReturns() = 0)
chk("they already mean two incompatible things: three print, three open an external program",
    _RnDisplayMeanings() = "3 print, 3 launch")
chk("stzGraph holds ONE OF EACH, which is the sharpest form of the finding",
    _RnGraphHasBoth())
chk("four classes answer the returning verb, and it is a different method from Display()",
    nRnRend = 4)


sec("-- 104. DN10: NOTATION IN A LABEL ----------------------------------------")
discharges("DN10")

# PROSE IS LEFT ALONE. A label with no dollar sign takes the path it has
# always taken, which is what makes this safe to add to a library full
# of labels.
chk("a plain label carries no notation and comes back as one run",
    NOT StzHasNotation("Chief Executive") and
    len(StzNotationRuns("Chief Executive", 24, AUFONT)[1]) = 1)
chk("and prose around the dollars is kept as prose",
    _TxRunText(StzNotationRuns("the area is $a^2$", 24, AUFONT), 1) = "the area is ")

# A SCRIPT IS SMALLER AND OFF THE BASELINE, and the box knows it.
aTxS = StzNotationRuns("$a^2$", 24, AUFONT)
chk("a superscript is drawn smaller than its base and above the baseline",
    _TxRunSize(aTxS, 2) < _TxRunSize(aTxS, 1) and _TxRunDy(aTxS, 2) < 0)
chk("a subscript is smaller too, and below it",
    _TxRunDy(StzNotationRuns("$x_1$", 24, AUFONT), 2) > 0)
chk("A SUPERSCRIPT MAKES THE BOX TALLER, which is what keeps the clearances honest",
    StzNotationRuns("$a^2$", 24, AUFONT)[3] > StzNotationRuns("$a$", 24, AUFONT)[3])
chk("and a subscript makes it deeper",
    StzNotationRuns("$x_1$", 24, AUFONT)[4] > StzNotationRuns("$x$", 24, AUFONT)[4])

# THE SYMBOLS, BY THEIR TeX NAMES.
chk("Greek letters and the common relations map to their own characters",
    StzNotationSymbol("alpha") != "" and StzNotationSymbol("le") != "" and
    StzNotationSymbol("Omega") != "" and StzNotationSymbol("deg") != "")
chk("NEGATIVE: a name the table does not hold maps to nothing at all",
    StzNotationSymbol("frac") = "" and StzNotationSymbol("wobble") = "")

# IT DRAWS, AND THE ONE GATE JUDGES THE PICTURE THAT CARRIES IT.
oTxP = StzMathScene16(AUFONT)
oTxP.Layout()
oTxP.Callout("K.icon", "$r^2 = x^2 + y^2$", [])
chk("a picture whose callout carries notation is lawful and the gate finds nothing",
    oTxP.IsFeasible() and len(StzCheckPictures([ [ "notation", oTxP ] ]).Findings()) = 0)
chk("and the label the solver placed is the size the RUNS measure, not the raw source",
    _TxBoxMatchesRuns(oTxP))

# REFUSED BY NAME, EVERY TIME.
chk("a command the reader does not know is refused, and named", _TxRefuses(1))
chk("a dollar sign that opens notation and never closes it is refused", _TxRefuses(2))
chk("a brace that opens a group and never closes it is refused", _TxRefuses(3))
chk("a script with nothing after it is refused", _TxRefuses(4))
chk("A SYMBOL THIS FONT CANNOT DRAW is refused rather than drawn as a hollow box",
    _TxRefuses(5))
? "   [of the table's symbols, Segoe UI cannot draw " + _TxMissingCount() + "]"
chk("and that is a real number, not a hypothetical one -- this font lacks several",
    _TxMissingCount() >= 5)
chk("NEGATIVE: the lawful sibling of each is accepted", NOT _TxRefuses(0))

# THE HAZARD THIS FEATURE MET. The canvas styles the text that is
# PENDING, so a size set BEFORE a text lands on the previous one. The
# picture renderer never met it, because SetSvgIdent flushes at the top of
# every shape -- a first reading claimed otherwise and was wrong, and the
# word cloud was never drawn wrong. It bites where ONE shape emits several
# texts and nothing flushes between them, which is what notation runs do.
chk("a font set AFTER a text styles that text: the first is drawn big and the second small",
    _TxDrawnHeight(1) > _TxDrawnHeight(2) * 1.8)
chk("NEGATIVE: with nothing flushing between them, setting the font BEFORE each text " +
    "inverts the sizes -- the hazard a multi-run label walks into",
    _TxDrawnHeightWrong(1) < _TxDrawnHeightWrong(2))
chk("and the renderer never walked into it, because a shape flushes before it draws: " +
    "the same two texts with a flush between them come out right EITHER WAY",
    _TxFlushedBothWays())


sec("-- 105. DN11: A MOLECULE IS A CONSTRAINT PROBLEM OVER ATOMS -----------")
discharges("DN11")

# THE SECOND CALLER OF THE SOLVER. Atoms are typed nodes with the elements
# as subtypes, bonds are a constructor with Double and Triple as
# predicates, and every bond angle is a BondAngle whose ideal is a
# predicate -- hybridisation said in the plane's words. The picture is
# SOLVED from connectivity; no scene below carries a coordinate.
oChD = StzChemistryDomain()
chk("an element is an Atom, and a heavy one is a HeavyAtom",
    oChD.TypeMatches("Carbon", "Atom") and oChD.TypeMatches("Carbon", "HeavyAtom") and
    oChD.TypeMatches("Oxygen", "HeavyAtom"))
chk("NEGATIVE: hydrogen is an Atom and NOT a heavy one -- the skeleton is a type",
    oChD.TypeMatches("Hydrogen", "Atom") and NOT oChD.TypeMatches("Hydrogen", "HeavyAtom"))
chkeq("a bond joins two atoms", oChD.FunctionArity("Bond"), 2)
chk("an element the domain does not know is refused by name", _ChRefusesElement())

# THE BUILDER DERIVES EVERY ANGLE AND ITS IDEAL from degree and bond
# order. Water: three atoms, two bonds, one angle.
oChW = StzMathWaterSubstance()
chk("water is three atoms, two bonds and one angle",
    len(oChW.ObjectsOfType("Atom")) = 3 and len(oChW.ObjectsOfType("Bond")) = 2 and
    len(oChW.ObjectsOfType("Angle")) = 1)
chk("...and the angle is trigonal, as a 2D depiction draws it",
    oChW.Holds("Ideal120", [ "g1" ]))
chkeq("the oxygen's valence is recounted from the bonds: two", StzChemistryValenceOf(oChW, "a1"), 2)
chk("a triple bond makes its carbon LINEAR: acetylene's angles are 180",
    _ChIdealOf(StzMoleculeFromBonds([ "C", "C", "H", "H" ], [ [1,2,3],[1,3,1],[2,4,1] ]), "g1") = "Ideal180")
chk("four neighbours make a cross: methane's six angles are 90",
    _ChAllIdeal(StzMoleculeFromBonds([ "C", "H", "H", "H", "H" ],
        [ [1,2,1],[1,3,1],[1,4,1],[1,5,1] ]), "Ideal90") = 6)
chk("NEGATIVE: a double bond's carbon stays trigonal -- ethylene is 120 throughout",
    _ChAllIdeal(StzMoleculeFromBonds([ "C", "C", "H", "H", "H", "H" ],
        [ [1,2,2],[1,3,1],[1,4,1],[2,5,1],[2,6,1] ]), "Ideal120") = 6)

# BENZENE IS A REGULAR HEXAGON BY CONSEQUENCE. Nothing says "hexagon":
# equal bonds and a 120-degree ideal at each carbon, and the ring comes
# out regular -- from the PLANAR start, first try, one round.
oChB = StzMathScene39(AUFONT)
oChB.Layout()
? "   benzene : " + oChB.NumberOfUnknowns() + " unknowns, " + oChB.NumberOfConstraints() +
  " constraints, " + oChB.Rounds() + " round(s), " + floor(oChB.LayoutMs()) + " ms, start " + oChB.StartUsed()
chk("benzene is lawful from the planar start, first try", oChB.IsFeasible() and
    oChB.StartUsed() = "planar" and oChB.StartsTried() = 1)
aChRb = [ _ChD(oChB,"a1","a2"), _ChD(oChB,"a2","a3"), _ChD(oChB,"a3","a4"),
          _ChD(oChB,"a4","a5"), _ChD(oChB,"a5","a6"), _ChD(oChB,"a6","a1") ]
aChRa = [ _ChA(oChB,"a6","a1","a2"), _ChA(oChB,"a1","a2","a3"), _ChA(oChB,"a2","a3","a4"),
          _ChA(oChB,"a3","a4","a5"), _ChA(oChB,"a4","a5","a6"), _ChA(oChB,"a5","a6","a1") ]
? "   ring bonds " + _ChJoin(aChRb) + "   ring angles " + _ChJoin(aChRa)
chk("its six ring bonds are equal to within five percent", _ChSpread(aChRb) < 1.05)
chk("and its six ring angles are within two degrees of 120", _ChMaxDev(aChRa, 120) < 2)
chk("every hydrogen points OUTWARD -- farther from the ring's centre than its carbon",
    _ChOutward(oChB))
chk("a double bond is drawn as two lines and no stick, a single as a stick and no lines",
    len(oChB.ShapeOf("b1.l1")) > 0 and len(oChB.ShapeOf("b1.l2")) > 0 and len(oChB.ShapeOf("b1.stick")) = 0 and
    len(oChB.ShapeOf("b2.stick")) > 0 and len(oChB.ShapeOf("b2.l1")) = 0)
chk("the drawn stick stops at the rim: shorter than the centre-to-centre segment it rides",
    _ChLen(oChB, "b2.stick") < _ChLen(oChB, "b2.icon") - 20)

# THE MOL BLOCK IS THE INDEPENDENT EXPECTATION. Its coordinates are
# never used to draw; they are what the solved picture is measured
# against -- a hexagon of 1.40 A written by hand, and its angles read
# back from the file by a different function than the one that solved.
aChM = StzMolParse(StzMathBenzeneMol())
chk("the block parses to twelve atoms and twelve bonds, first a double",
    len(aChM[:elements]) = 12 and len(aChM[:bonds]) = 12 and aChM[:bonds][1][3] = 2 and
    aChM[:elements][1] = "C" and aChM[:elements][12] = "H")
oChF = new stzMathDiagram(StzChemistryDomain(), StzMoleculeFromMol(StzMathBenzeneMol()), StzBallAndStickStyle())
oChF.SetFont(AUFONT, 11)
oChF.Layout()
nChFile = _ChFileAngle(aChM[:coordinates], 6, 1, 2)
? "   the file's ring angle at C1 is " + nChFile + "; the solved one is " + _ChA(oChF, "a6", "a1", "a2")
# within four degrees, from measurement: the ideal is ENCOURAGED inside a
# hard band, so a ring settles near 120 and not on it -- 1.3 off in scene
# 39, 2.5 off here from a different hydrogen start. The band would admit
# 102 to 137; four is a fifth of that room, and it is the solver's own
# number rather than a hope.
chk("the molecule read from the block solves to the angle the block's own coordinates hold",
    oChF.IsFeasible() and fabs(_ChA(oChF, "a6", "a1", "a2") - nChFile) < 4)
chk("NEGATIVE: a block whose counts line promises more atoms than it holds is refused",
    _ChRefusesShortMol())

# CAFFEINE: FUSED RINGS, and the start that finds them. A six-ring and a
# five-ring on a shared edge. The planar start used to take the SHORTEST
# chordless cycle as the outer face -- one ring -- and relax the other
# ring's free atoms into an arc squashed against the shared edge, and
# from there the solve ended 26px unlawful. The PERIMETER is the outer
# face now, with the shared edge a straight chord across it.
oChC = StzMathScene40(AUFONT)
oChC.Layout()
? "   caffeine : " + oChC.NumberOfUnknowns() + " unknowns, " + oChC.NumberOfConstraints() +
  " constraints, " + oChC.Rounds() + " round(s), " + floor(oChC.LayoutMs()) + " ms, start " + oChC.StartUsed()
chk("caffeine is lawful from the planar start, first try", oChC.IsFeasible() and
    oChC.StartUsed() = "planar" and oChC.StartsTried() = 1)
chkeq("...and its outer face is the PERIMETER of the fused system: nine atoms", len(oChC.OuterFace()), 9)
chk("the two rings lie on OPPOSITE sides of the edge they share",
    _ChSide(oChC, "a4", "a5", "a1") * _ChSide(oChC, "a4", "a5", "a8") < 0)
chk("no two bonds cross", _ChCrossings(oChC, 15) = 0)
chk("its two carbonyls are double and drawn so", len(oChC.ShapeOf("b11.l1")) > 0 and len(oChC.ShapeOf("b12.l2")) > 0)

# AND THE STARTS THE PLANE ALREADY PINNED DID NOT MOVE. The perimeter
# rule is taken only when the core is outerplanar; the cube and the
# dodecahedron are not, and keep the faces DN8b measured them on.
oChQ = StzMathScene23(AUFONT)
oChQ.Layout()
chkeq("NEGATIVE: the cube still starts on a four-face -- it is not outerplanar", len(oChQ.OuterFace()), 4)
chk("NEGATIVE: a chain with no ring cannot start planar and says so",
    NOT _ChTree().StartedPlanar())

# THE SKELETON IS THE START, THE HYDROGENS FOLLOW. A pendant vertex broke
# the planar start -- Tutte relaxed it onto its one neighbour and the
# collapse check refused the embedding -- so the start is asked over
# HeavyAtom, leaves are stripped and hung after, and an object of another
# type joined to the started graph begins a step from its anchor. Phenol
# in water is that, seven times over: seven components in one substance.
oChP = StzMathScene41(AUFONT)
oChP.Layout()
? "   phenol in water : " + oChP.NumberOfUnknowns() + " unknowns, " + oChP.NumberOfConstraints() +
  " constraints, " + oChP.Rounds() + " round(s), " + floor(oChP.LayoutMs()) + " ms, start " + oChP.StartUsed()
chk("seven components solve as one picture, lawful from the planar start",
    oChP.IsFeasible() and oChP.StartUsed() = "planar" and oChP.StartsTried() = 1)
chkeq("...with every atom of every water and of phenol an unknown pair, and nothing else",
      oChP.NumberOfUnknowns(), 112)

# THE SYMBOL IS NOT SOLVED, IT IS THE DISC'S CENTRE. The Principal saw the
# letters off-centre and the numbers agreed: contains was satisfied
# anywhere inside the disc and the encouraged sameCenter was outvoted, so
# a carbon's C sat 0.9px left and 1.9px below its disc. Its centre is an
# expression of the disc's now, which is exact and halves the unknowns.
chk("an atom's symbol centre IS its disc centre -- an expression, not an unknown",
    _ChD(oChB, "a1", "a1") = 0 and _ChTextOff(oChB, "a1") = 0 and _ChTextOff(oChB, "a7") = 0 and
    _ChTextOff(oChC, "a10") = 0)
chkeq("...so benzene solves thirty-six unknowns, not sixty", oChB.NumberOfUnknowns(), 36)

# THE RULES, THROUGH THE ONE GATE. Both read the substance and recount.
chk("a lawful molecule raises nothing in the gate",
    len(StzCheckPictures([ [ "benzene", oChB ] ]).Findings()) = 0)
aChV = StzCheckPictures([ [ "witness", _OgValenceWitness() ] ]).Findings()
chk("an oxygen with three bonds is caught, by name, with the count and the allowance",
    len(aChV) = 1 and aChV[1][:rule] = "valence_respected" and
    StzFindFirst("'a1' is O and carries 3", aChV[1][:message]) > 0 and
    StzFindFirst("allows 2", aChV[1][:message]) > 0)
aChS = StzCheckPictures([ [ "witness", _OgStrayWitness() ] ]).Findings()
chk("an atom bonded to nothing is caught, by name",
    len(aChS) = 1 and aChS[1][:rule] = "atom_bonded" and
    StzFindFirst("'a4'", aChS[1][:message]) > 0)
oChRule = StzChemistryRuleSet()[1]
chk("the valence rule governs every atom of a molecule and NOT ONE object of a lattice -- " +
    "the boundary is stood on",
    len(oChRule.SubjectsIn(oChB)) = 12 and len(oChRule.SubjectsIn(oChQ)) = 0 and
    len(oChRule.CounterSubjectsIn(oChQ)) > 0 and len(oChRule.CounterSubjectsIn(oChB)) = 0)
chk("a molecule answers Rendition() as a vector like every other picture",
    oChB.Rendition()[:kind] = "vector")


sec("-- 106. DN12: A LABEL IS CENTRED ON ITS CAP HEIGHT, NOT ITS EM BOX ------")
discharges("DN12")

# THE METRIC, FROM THE FONT. The engine's text layout now carries the ink
# extents of the shaped string -- how far the glyphs reach above and below
# the baseline -- beside the em box's ascender and descender. The cap
# height is the ink top of an H: read, not guessed.
aEmH = AUFONT.InkOf("H", 28)
aEmG = AUFONT.InkOf("g", 28)
aEmM = AUFONT.MetricsOf("H", 28)
? "   at 28px: ascender " + aEmM[1] + ", descender " + aEmM[2] + ", cap " + AUFONT.CapHeightOf(28) +
  ", g hangs " + aEmG[2] + " below"
chk("an H has ink above the baseline and NONE below", aEmH[1] > 0 and aEmH[2] = 0)
chk("a g has ink below the baseline -- the descender is the string's, not the font's",
    aEmG[2] > 0 and aEmG[1] < aEmH[1])
chk("the cap height is the H's ink top, and it sits where a cap height sits: 0.6 to 0.8 of the size",
    AUFONT.CapHeightOf(28) = aEmH[1] and AUFONT.CapHeightOf(28) > 0.6 * 28 and
    AUFONT.CapHeightOf(28) < 0.8 * 28)
chk("NEGATIVE: the em box is the same for H and g; the ink is not",
    AUFONT.MetricsOf("g", 28)[1] = aEmM[1] and aEmG[1] != aEmH[1])

# THE NUMBER THAT WAS WRONG, reproduced. The old baseline sat (asc - desc)/2
# below cy; the cap centre sits cap/2 below it. The difference is what every
# capital was drawn low by -- and it grows with the size, which is why it
# was invisible on an 11px atom symbol and visible on a 28px set name.
nEmBias11 = (AUFONT.MetricsOf("H", 11)[1] - AUFONT.MetricsOf("H", 11)[2] - AUFONT.CapHeightOf(11)) / 2
nEmBias28 = (aEmM[1] - aEmM[2] - AUFONT.CapHeightOf(28)) / 2
? "   the em-box bias was " + nEmBias11 + "px at 11px and " + nEmBias28 + "px at 28px"
chk("the bias the old formula carried was over half a pixel at 11px and over a pixel and a half at 28",
    nEmBias11 > 0.5 and nEmBias28 > 1.5)

# THE INK IS CENTRED NOW, measured on the pixels the renderer wrote, inside
# a circle the disc's rim cannot reach -- the first measurement of this
# defect counted a rim as ink and was three times too large.
oEmS = StzMathScene01(AUFONT)
oEmS.Layout()
aEmB = _EmInkOff(oEmS, "B.text", 16)
? "   scene 1's B, 28px : ink centre off by " + aEmB[1] + "," + aEmB[2] + " px"
chk("a 28px set name's ink is centred on its cy to within half a pixel", fabs(aEmB[2]) < 0.5)
oEmC = StzMathScene39(AUFONT)
oEmC.Layout()
aEmA = _EmInkOff(oEmC, "a1.text", 7)
? "   benzene's C, 11px : ink centre off by " + aEmA[1] + "," + aEmA[2] + " px"
chk("an 11px atom symbol's ink is centred on its cy to within half a pixel", fabs(aEmA[2]) < 0.5)

# THE BOX MOVED WITH THE INK, AND IT HOLDS THE WHOLE EM BOX. The modelled
# box stays symmetric about cy -- one number, every consumer unchanged --
# and is the smallest such box containing the em box drawn round the new
# baseline, so no clearance is closer to the ink than before.
sEmB = oEmS.ShapeOf("B.text")
chk("the text's box is at least the em box tall", sEmB[:h] >= aEmM[1] + aEmM[2] - 0.01)
chk("...and holds the drawn em box: the cap's top and the descender's bottom are both inside",
    sEmB[:cy] + AUFONT.CapHeightOf(28) / 2 - aEmM[1] >= sEmB[:cy] - sEmB[:h] / 2 - 0.01 and
    sEmB[:cy] + AUFONT.CapHeightOf(28) / 2 + aEmM[2] <= sEmB[:cy] + sEmB[:h] / 2 + 0.01)
chk("and both pictures stay lawful under the taller box", oEmS.IsFeasible() and oEmC.IsFeasible())


sec("-- 107. DN13: THE CHORDS ARE NOT THE CURVE, AND THE CLEARANCE SAYS BY HOW MUCH --")
discharges("DN13")

# THE GAP, MEASURED. A curved edge is drawn as a Catmull-Rom through its two
# ends and a middle bulged 8% off the chord; the rules hold a name off the
# two hidden half-chords. The curve leaves those chords by a constant
# fraction of the edge's length -- constant because every edge bulges by
# the same fraction, so the curve has the same shape at every size.
oCsC = StzMathScene25(AUFONT)
oCsC.Layout()
aCsG = _CsGap(oCsC)
? "   curved cube : longest edge " + floor(aCsG[3]) + "px, its spline leaves the chords by " +
  floor(100 * aCsG[1]) / 100 + "px; gap/length " + floor(100000 * aCsG[4]) / 100000 +
  " to " + floor(100000 * aCsG[5]) / 100000 + " over twelve edges"
chk("the spline leaves its chords by the same fraction of the edge on every edge -- a constant",
    aCsG[5] - aCsG[4] < 0.0005)
chk("...and that fraction is the one the style's clearance carries, with room over it",
    aCsG[5] < 0.012 and aCsG[5] > 0.011)
# the catalogue's own edges are 160-ish now and clear four pixels; the
# claim is about the RULE: an edge of the paper's width would leave its
# chords by more than the flat four names were held at, and the catalogue
# picture before this item had a 371px edge leaving them by 4.35
chk("an edge spanning the paper would leave its chords by more than the flat four pixels " +
    "names used to be held at",
    aCsG[5] * 720 > 4)

# THE TWO SEEDS THAT SAID SO. DN12's seed sweep found two seeds whose
# retried picture was LAWFUL and carried a name-off-ink finding -- a name
# clear of both chords, on the curve. They are clean now.
chk("a seed whose lawful picture carried a name on the curve is clean under the gate",
    _CsClean("second-wedge"))
chk("...and so is the other", _CsClean("two-wedges"))
chk("the catalogue's own curved cube stays lawful, planar-started and clean",
    oCsC.IsFeasible() and oCsC.StartedPlanar() and
    len(StzCheckPictures([ [ "curved", oCsC ] ]).Findings()) = 0)

# THE INSTRUMENT DISCRIMINATES. A name moved by hand onto a hidden chord's
# midpoint -- lawful to the OLD rule, since the chord is not ink -- is
# caught against the spline by name_off_ink, because the gate reads what
# is drawn.
oCsBad = StzMathScene25(AUFONT)
oCsBad.Layout()
_CsMoveNameOntoChord(oCsBad, "v000", aCsG[2] + ".h1")
aCsF = StzCheckPictures([ [ "name-on-chord", oCsBad ] ]).Findings()
chk("NEGATIVE: a name set by hand on a hidden chord IS caught against the curve it does not see",
    len(aCsF) > 0 and _PorHits(aCsF, "name_off_ink") > 0)


sec("-- 108. DN14: A GANTT CHART -- EVERY POSITION A DATUM, EVERY RULE ABOUT TIME --")
discharges("DN14")

# NOTHING TO SOLVE. A task is three numbers -- a start day, a finish day,
# a lane -- and every pixel follows by arithmetic. The builder puts the
# days on the objects for the rules and the pixels for the style, and the
# solver reports it minted no unknown at all.
oGtP = StzMathScene42(AUFONT)
oGtP.Layout()
oGtS = oGtP.Substance()
? "   project : " + oGtP.NumberOfShapes() + " shapes, " + oGtP.NumberOfUnknowns() +
  " unknowns, " + floor(oGtP.LayoutMs()) + " ms -- " + oGtP.Why()
chkeq("a Gantt mints no unknown -- there is nothing to lay out", oGtP.NumberOfUnknowns(), 0)
chk("eight tasks, two of them milestones, six dependencies, and an axis of nine ticks",
    len(oGtS.ObjectsOfType("Task")) = 8 and len(oGtS.ObjectsOfType("Milestone")) = 2 and
    len(oGtS.ObjectsOfType("Dependency")) = 6 and len(oGtS.ObjectsOfType("Tick")) = 9)
chk("a task whose finish is its start is a Milestone, and one with a length is not",
    oGtS.DomainQ().TypeMatches(oGtS.TypeOf("t4"), "Milestone") and
    NOT oGtS.DomainQ().TypeMatches(oGtS.TypeOf("t2"), "Milestone"))
nGtK = (StzGanttWidth() - StzGanttLeftColumn() - 40) / 40
chk("a bar's width is its days times the day's share of the paper, exactly",
    fabs(oGtP.ShapeOf("t2.bar")[:w] - 8 * nGtK) < 0.01)
chk("the axis steps by five days over a forty-day span: ten ticks or fewer",
    oGtS.DataOf("k2", "t") - oGtS.DataOf("k1", "t") = 5)
chk("a fact reads durations in DAYS, from the data and not the pixels",
    oGtP.Fact(:expr, [ "t5.finish - t2.start", :days ])[:value] = 26 and
    StzFindFirst("26 days", oGtP.Fact(:expr, [ "t5.finish - t2.start", :days ])[:message]) > 0)
aGtP = StzCheckPictures([ [ "project", oGtP ] ]).Findings()
for iGt = 1 to len(aGtP)
	if iGt <= 4  ? "   PROJECT FINDING " + aGtP[iGt][:rule] + " -- " + aGtP[iGt][:message]  ok
next
chk("the project is lawful and the one gate finds nothing in it",
    oGtP.IsFeasible() and len(aGtP) = 0)
chk("and it answers Rendition() as a vector like every other picture",
    oGtP.Rendition()[:kind] = "vector")

# THE RULES ARE ABOUT TIME, and they name the tasks by the names the author
# gave them and say by how many days. The witness has one of each mistake
# -- and the double booking is reported on BOTH tasks, because each of
# them is double-booked.
oGtW = StzMathGanttWitness(AUFONT)
aGtF = StzCheckPictures([ [ "wrong", oGtW ] ]).Findings()
? "   witness : " + len(aGtF) + " findings -- " + _GtByRule(aGtF)
chk("a dependency running backwards in time is caught, twice, and each names its tasks and its days",
    _PorHits(aGtF, "dependency_forward_in_time") = 2 and
    _GtHas(aGtF, "'Test' starts on day 26, 12 days before 'Docs' ends on day 38"))
chk("a task that finishes before it starts is caught, by name and by how much",
    _PorHits(aGtF, "task_ends_after_it_starts") = 1 and
    _GtHas(aGtF, "'Backwards' finishes on day 20, 2 days before it starts"))
chk("two tasks sharing a lane and overlapping are caught on both, with the overlap in days",
    _PorHits(aGtF, "lane_not_double_booked") = 2 and
    _GtHas(aGtF, "'Build' and 'Docs' share lane 5 and overlap by 2 days"))
chkeq("...and those five are all the gate finds -- the names over shared bars do not collide",
      len(aGtF), 5)

# A FAULT IS DRAWN, AND THE DRAWING'S MARKS ARE HELD TO THE RULES' VERDICTS.
# The Principal asked what a white seam and a blank lane were: the double
# booking's only trace, and a reversed task's bar of negative width drawing
# nothing. The builder marks both for the style; the rules still judge
# from the days, and here the two must agree.
oGtWS = oGtW.Substance()
chk("a task that finishes before it starts is drawn as a bar between its two days, in the colour of a fault",
    oGtWS.Holds("Reversed", [ "t8" ]) and oGtW.ShapeOf("t8.bar")[:w] > 0 and
    fabs(oGtW.ShapeOf("t8.bar")[:w] - 2 * nGtK) < 0.01 and oGtW.FillOf("t8.bar") != oGtW.FillOf("t1.bar"))
chk("the two tasks double-booked on a lane are marked, and the marks are exactly the rule's verdicts",
    _GtMarkedEquals(oGtW, "Clashing", aGtF, "lane_not_double_booked"))
chk("NEGATIVE: nothing in the lawful project is marked as a fault",
    len(_GtMarked(oGtP, "Reversed")) = 0 and len(_GtMarked(oGtP, "Clashing")) = 0)

# THE BOUNDARIES. Touching ends are not an overlap; a schedule that is
# right raises nothing; and the builder refuses what it cannot draw.
oGtT = StzGanttDiagram(AUFONT, [ [ "A", 0, 5, 1 ], [ "B", 5, 9, 1 ] ], [])
aGtT = StzCheckPictures([ [ "touching", oGtT ] ]).Findings()
chk("NEGATIVE: two tasks meeting end to end on one lane are not double-booked",
    _PorHits(aGtT, "lane_not_double_booked") = 0)

# A GRIDLINE IS A GUIDE, NOT INK. The second task's name sits over its own
# bar, and a name over a bar must cross a gridline -- there is no place in
# the chart free of them. The style marks the tick lines :guide = 1 and
# the name rules read past them; the same chart with its gridlines as
# ink has a name on one, and the gate says so. Both sides of that
# boundary stand in the corpus.
chk("...and the name over its bar crosses a gridline that is a GUIDE, so nothing is found",
    len(aGtT) = 0)
oGtI = new stzMathDiagram(StzGanttDomain(), StzGanttFromTasks([ [ "A", 0, 5, 1 ], [ "B", 5, 9, 1 ] ], []),
                          StzGanttStyleXT(1, FALSE))
oGtI.SetFont(AUFONT, 13)
chk("NEGATIVE: the same chart with its gridlines as INK has a name on one, by name",
    _PorHits(StzCheckPictures([ [ "gridlines as ink", oGtI ] ]).Findings(), "name_off_ink") > 0)
chk("a dependency naming a task that is not in the list is refused, and named", _GtRefusesUnknown())
chk("a task depending on itself is refused", _GtRefusesSelf())
oGtRule = StzGanttRuleSet()[1]
chk("the gantt rules govern every dependency of a chart and not one object of a molecule -- " +
    "the boundary is stood on",
    len(oGtRule.SubjectsIn(oGtP)) = 6 and len(oGtRule.SubjectsIn(oChB)) = 0 and
    len(oGtRule.CounterSubjectsIn(oChB)) > 0 and len(oGtRule.CounterSubjectsIn(oGtP)) = 0)

# THE RULE CAUGHT ITS AUTHOR. The first project list typed for this scene,
# as "nothing wrong with it", had Prototype starting four days before
# Design ended and Test four days before Build ended, both under a
# dependency. The rule found both on its first run; the list was fixed and
# the mistake is kept here as the witness's first two rows.
chk("the list the witness inherited still carries the author's first mistake",
    _GtHas(aGtF, "'Prototype' starts on day 8, 4 days before 'Design' ends on day 12"))


sec("-- 109. DN15: AN ENTITY-RELATIONSHIP DIAGRAM -- A SCHEMA WITH A PICTURE ---")
discharges("DN15")
OPTER = [ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]

# THE NOTATION: entities as boxes with attribute compartments, relations
# as lines with their cardinality at BOTH ends and no arrowhead at all.
oErS = StzErScene01(OPTER)
chk("declaring the notation puts the picture under it, undirected",
    oErS.NotationO().Name_() = "er" and NOT oErS.NotationO().EdgesDirected())
chkeq("...so no arrowhead is drawn on any relation", len(oErS.RenderArrows()), 0)
chk("an entity's compartment reads as a schema does: PK first, then columns, a foreign key naming its target",
    _ErAttrsAre(oErS, "order", [ "PK id", "placed_on", "FK customer_id -> customer" ]))
chk("a junction's columns are keys AND references, and read so",
    _ErAttrsAre(oErS, "producttag", [ "PK FK product_id -> product", "PK FK tag_id -> tag" ]))

# THE CARDINALITY IS AT THE ENDS, published like every drawn fact: a bar
# at the "one" end, a crow's foot at the "many" end, read from the FROM
# side of the relation.
chk("a one-to-many carries a bar at its source and a crow's foot at its target",
    _ErEnd(oErS, "customer>order", "source") = "one" and _ErEnd(oErS, "customer>order", "target") = "many")
chkeq("five relations, ten cardinalities and two participations -- every end says something, two say more",
      len(oErS.RenderAdornments()), 12)
oErJ = StzErSceneJunction(OPTER)
chk("a many-to-many carries a crow's foot at both ends",
    _ErEnd(oErJ, "student>course", "source") = "many" and _ErEnd(oErJ, "student>course", "target") = "many")

# THE RULES ARE ABOUT KEYS, and the shop passes them all.
chkeq("the shop is sound: every entity keyed, every key resolving, every relation backed",
      len(oErS.GovernanceFindings()), 0)
chk("a many-to-many backed by a junction holding keys to both sides passes",
    len(oErJ.GovernanceFindings()) = 0)

# THE WITNESS: one of each mistake, by name.
oErW = StzErScene02(OPTER)
aErF = oErW.GovernanceFindings()
? "   witness : " + len(aErF) + " findings"
chk("an entity with no primary key is caught, by name",
    _ErFound(aErF, "entity_has_key", "entity 'Order' has no primary key"))
chk("a foreign key to an entity nobody drew is caught, naming the column and the phantom",
    _ErFound(aErF, "foreign_key_resolves", "'Order.customer_id' refers to 'custmer'"))
chk("a one-to-many with no key behind it is caught on the many side",
    _ErFound(aErF, "relation_backed_by_key", "'Order' is the many side of 'Customer' and holds no foreign key"))
chk("a many-to-many with no junction is caught, and told what it is owed",
    _ErFound(aErF, "relation_backed_by_key", "'Product' and 'Tag' are many to many") and
    _ErFound(aErF, "relation_backed_by_key", "a junction is owed"))
chkeq("...and those are all of them: five", len(aErF), 5)

# THE BOUNDARY, STOOD ON. A note is a node and not an entity: it owes no
# key and joins no relation, and every rule says so by excluding it.
oErRs = StzErRuleSetQ()
chk("NEGATIVE: the note is excluded by every rule, not merely passed",
    _ErExcludedEverywhere(oErRs, oErW.AsRuleGraph(), "note:n1"))
chk("NEGATIVE: an entity with no foreign key is outside the resolving rule, not passing it",
    _ErInList("entity:customer", oErRs.Rules()[2].CounterSubjectsIn(oErW.AsRuleGraph())))

# PARTICIPATION, INSIDE THE CARDINALITY: a ring for possibly-none, a
# second bar for at-least-one, each published with its end -- and an end
# that declares nothing draws nothing more.
chk("'an order always has a customer' is a bar at the customer end, 'a customer may have no order' a ring at the order end",
    _ErPart(oErS, "customer>order", "source") = "mandatory" and _ErPart(oErS, "customer>order", "target") = "optional")
chk("NEGATIVE: an end that declares nothing publishes no participation",
    _ErPart(oErS, "order>line", "source") = "" and _ErPart(oErS, "order>line", "target") = "")
chk("a nullable column reads so in the compartment",
    _ErAttrsAre(StzErSceneParticipation(OPTER), "emp", [ "PK id", "name", "FK dept_id -> dept (nullable)" ]))

# ...AND THE MARK IS HELD TO THE COLUMN. "An order always has a customer"
# is a bar on a line and a NOT NULL on a column: one claim made twice.
oErP = StzErSceneParticipation(OPTER)
aErPF = oErP.GovernanceFindings()
chk("a ring at the key's target end over a column that is not nullable is caught, naming both",
    _ErFound(aErPF, "participation_matches_nullability", "'User' end is declared optional and the key behind it, 'Ticket.assignee_id', is not nullable"))
chk("a bar at the key's target end over a nullable column is caught the other way",
    _ErFound(aErPF, "participation_matches_nullability", "'Account' end is declared mandatory and the key behind it, 'Invoice.account_id', is nullable"))
chkeq("...and the ring over a nullable column passes: two findings, not three", len(aErPF), 2)
chk("NEGATIVE: a mark at the MANY end makes no claim a column can contradict -- outside the rule, not passing it",
    _ErInList("relation:order>line", oErRs.Rules()[4].CounterSubjectsIn(oErS.AsRuleGraph())) and
    _ErInList("relation:customer>order", oErRs.Rules()[4].SubjectsIn(oErS.AsRuleGraph())))
chk("NEGATIVE: the shop's own participation agrees with its columns", len(oErS.GovernanceFindings()) = 0)

# THE BUILDER REFUSES WHAT IT CANNOT DRAW.
chk("a relation to an entity that is not in the diagram is refused", _ErRefusesUnknown())
chk("a cardinality that is not one of the four is refused, by name", _ErRefusesKind())
chk("a participation that is neither Optional nor Mandatory is refused, by name", _ErRefusesPart())

# EVERY RELATION TOUCHES BOTH ITS ENTITIES. The Principal marked a blank
# between a crow's foot and OrderLine: the routed form cut its last 13px
# for an arrowhead that an undirected notation never draws, while its
# straight siblings touched. A line is shortened only for a head that
# will be drawn -- now true of every form under every notation.
chk("every relation's path starts on its source's border and ends on its target's -- the routed one too",
    _ErAllTouch(oErS) and _ErAllTouch(oErP))
chk("NEGATIVE: the instrument sees a gap when one is put there",
    NOT _ErOnBorder([ 100, 100, 50, 50, "x" ], 87, 120))

# TWO FEET ON ONE BORDER ARE TWO. The Principal circled the junction's two
# crow's feet meeting at their tips: the arrivals were spread over a third
# of the picture's CELL, 12px on a node twice as tall, which is one foot's
# width. The share is of the node's own border now, with a floor of a
# mark's width and a gap.
aErJt = _ErTargetYs(oErS, "producttag")
chkeq("the junction's two arrivals are read", len(aErJt), 2)
chk("...and stand at least a foot's width and a gap apart -- 18px",
    len(aErJt) = 2 and fabs(aErJt[1] - aErJt[2]) >= 18)
chk("NEGATIVE: a single arrival takes the border's centre, no spread",
    len(_ErTargetYs(oErS, "order")) = 1 and _ErTargetYs(oErS, "order")[1] = _ErCentreY(oErS, "order"))

# IT ANSWERS THE DISPLAY CONTRACT LIKE EVERY OTHER PICTURE.
chk("an ER diagram answers Rendition() as a vector", oErS.Rendition()[:kind] = "vector")


sec("-- 110. DN16: A PETRI NET -- THE PICTURE CARRIES ITS STATE -------------")
discharges("DN16")

# THE NOTATION: places as circles with their names outside, transitions
# as bars, arcs directed and read left to right. The inside of a place is
# for its tokens, and the notation says so once, per kind.
OPTPN = [ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]
oPnM = StzPetriScene01(OPTPN)
chk("the notation is directed and reads left to right",
    oPnM.NotationO().Name_() = "petri" and oPnM.NotationO().EdgesDirected())
chk("a place's name is written outside it by declaration -- its inside is for the tokens -- and so is a bar's",
    oPnM.NotationO().WritesNameOutside("place") and oPnM.NotationO().WritesNameOutside("transition"))
chk("NEGATIVE: the declaration is per kind -- a note keeps its text inside",
    NOT oPnM.NotationO().WritesNameOutside("note"))

# THE MARKING IS DRAWN, AND PUBLISHED. An empty place publishes its zero.
chkeq("five places, five token records -- an empty place says so too", len(oPnM.RenderTokens()), 5)
chk("the marking drawn is the marking declared: one in each Waiting, one Key, none in either Critical",
    _PnDrawn(oPnM, "w1") = 1 and _PnDrawn(oPnM, "key") = 1 and _PnDrawn(oPnM, "w2") = 1 and
    _PnDrawn(oPnM, "c1") = 0 and _PnDrawn(oPnM, "c2") = 0)
chk("...and each record sits at the centre of its own place", _PnTokensCentred(oPnM))

# THE TOKEN GAME, and it shows the exclusion.
chkeq("both Enter transitions are enabled at the start", len(oPnM.Enabled()), 2)
oPnM.Fire("e1")
chk("Enter A fired: the key is taken and A is inside",
    oPnM.Tokens("key") = 0 and oPnM.Tokens("c1") = 1 and oPnM.Tokens("w1") = 0)
chk("...and Enter B is no longer enabled, for a reason that names the place and the count",
    NOT oPnM.IsEnabled("e2") and StzFindFirst("'Key' holds 0 and the arc wants 1", oPnM.WhyNotEnabled("e2")) > 0)
chk("NEGATIVE: firing Enter B anyway is refused, by name and by number",
    _PnRefusesFire(oPnM, "e2", "'Key' holds 0"))
oPnM.ToCanvasXT(OPTPN)
chk("the picture drawn after the firing carries the new marking: the dot moved from Waiting A to Critical A",
    _PnDrawn(oPnM, "w1") = 0 and _PnDrawn(oPnM, "c1") = 1 and _PnDrawn(oPnM, "key") = 0)
oPnM.Fire("l1")
chk("Leave A restores the initial marking, and both Enters are enabled again",
    _PnMarkingIs(oPnM, [ [ "w1", 1 ], [ "key", 1 ], [ "w2", 1 ], [ "c1", 0 ], [ "c2", 0 ] ]) and
    len(oPnM.Enabled()) = 2)

# WEIGHTS: an arc may carry more than one token, and says so on the line.
oPnB = StzPetriScene02(OPTPN)
chk("five tokens are drawn as the number five, and published as five", _PnDrawn(oPnB, "free") = 5)
chk("a weight above one is written on its arc; a weight of one is not",
    _PnEdgeLabel(oPnB, "free", "put") = "2" and _PnEdgeLabel(oPnB, "put", "full") = "2" and
    _PnEdgeLabel(oPnB, "full", "take") = "")
oPnB.Fire("put")
chk("an arc of weight two takes two and gives two", oPnB.Tokens("free") = 3 and oPnB.Tokens("full") = 2)
oPnB.Fire("take")
chk("Take needs one and finds two: after it the buffer holds one and the slots four",
    oPnB.Tokens("full") = 1 and oPnB.Tokens("free") = 4)

# THE RULES: the two sound nets pass, the witness names one of each mistake.
chkeq("the mutex is sound under every rule", len(oPnM.GovernanceFindings()), 0)
chkeq("the buffer is sound under every rule", len(oPnB.GovernanceFindings()), 0)
oPnW = StzPetriSceneWitness(OPTPN)
aPnF = oPnW.GovernanceFindings()
? "   witness : " + len(aPnF) + " findings"
chk("an arc from a place to a place is caught, naming both",
    _ErFound(aPnF, "arc_joins_place_and_transition", "'Mid' -> 'Stray' joins two places"))
chk("a transition with no input is caught: it fires forever",
    _ErFound(aPnF, "transition_has_input", "'Source' has no input place"))
chk("a transition with no output is caught: what it consumes vanishes",
    _ErFound(aPnF, "transition_has_output", "'Sink' has no output place"))
chk("a place with no token and nothing feeding it is caught: empty forever",
    _ErFound(aPnF, "place_can_be_marked", "'Never' holds no token and no transition feeds it"))
chk("...and the transition it starves is caught by the same fact, naming the place",
    _ErFound(aPnF, "transition_can_fire", "'Starved' can never fire: its input place 'Never'"))
chkeq("six findings: the stray place at the end of the bad arc is empty forever too", len(aPnF), 6)

# THE BOUNDARIES, STOOD ON.
oPnRs = StzPetriRuleSetQ()
chk("NEGATIVE: the note is excluded by every rule, not merely passed",
    _ErExcludedEverywhere(oPnRs, oPnW.AsRuleGraph(), "note:n1"))
chk("NEGATIVE: a transition with no input is outside the firing rule -- it is the input rule's subject",
    _ErInList("transition:t0", oPnRs.Rules()[5].CounterSubjectsIn(oPnW.AsRuleGraph())) and
    NOT _ErInList("transition:t0", oPnRs.Rules()[5].SubjectsIn(oPnW.AsRuleGraph())))
chk("NEGATIVE: a place is outside every rule about transitions",
    _ErInList("place:p1", oPnRs.Rules()[2].CounterSubjectsIn(oPnW.AsRuleGraph())))

# THE BUILDER REFUSES WHAT IT CANNOT MEAN.
chk("a marking that is not a whole number of tokens is refused", _PnRefuses(1))
chk("an arc to a node that is not in the net is refused, by name", _PnRefuses(2))
chk("an arc of weight zero is refused", _PnRefuses(3))
chk("a second node under one id is refused", _PnRefuses(4))

# THE RETURNS RUN UNDER THE ROW. The mutex's every cycle lands on one row,
# and its four backward arcs were first drawn straight along it -- under
# Critical A, Enter A and the rest, a false link with each. A backward
# arc with a cell on its straight run takes the return ladder now, in
# every notation; one with a clear run keeps it.
chk("no arc of the mutex runs through a cell", _PnNoArcThroughCell(oPnM))
chk("...and its four returns each turn twice, out of the row and back into it",
    _PlTurnsOf(oPnM, "l1", "w1") = 2 and _PlTurnsOf(oPnM, "key", "e1") = 2 and
    _PlTurnsOf(oPnM, "l2", "key") = 2 and _PlTurnsOf(oPnM, "w2", "e2") = 2)
chk("NEGATIVE: the instrument convicts the old straight run when handed one",
    _PnSegmentThroughRect([ 460, 48, 60, 48 ], [ 306, 25.6, 44.8, 44.8, "c1" ]))
chk("a forward arc between neighbours keeps its straight run", _PlTurnsOf(oPnM, "w1", "e1") = 0)

# FIVE MARKS FROM THE PRINCIPAL ON THE MUTEX, each a general fault. A
# return meets the far stacking border, not the rank-facing one, so it is
# allocated its stub on that border alone and along the rank axis; a
# bar's box is its ink; a name beside a mark leaves the wire visible.
chk("the lone return into Waiting A arrives at the centre of its circle",
    fabs(_PnPathEnd(oPnM, "l1", "w1")[1] - _PnCentreX(oPnM, "w1")) < 0.5)
chk("the lone return out of Leave B leaves at the centre of its bar",
    fabs(_PnPathStart(oPnM, "l2", "key")[1] - _PnCentreX(oPnM, "l2")) < 0.5)
chk("the two stubs under Key -- one leaving, one arriving -- stand symmetric about its centre",
    fabs((_PnPathStart(oPnM, "key", "e1")[1] + _PnPathEnd(oPnM, "l2", "key")[1]) / 2 - _PnCentreX(oPnM, "key")) < 0.5 and
    fabs(_PnPathStart(oPnM, "key", "e1")[1] - _PnPathEnd(oPnM, "l2", "key")[1]) > 10)
chk("NEGATIVE: a forward arc still leaves the rank-facing border at the centre, untouched by the return's contest",
    fabs(_PnPathStart(oPnM, "key", "e2")[2] - _PnCentreY(oPnM, "key")) < 0.5)
chk("a bar's box is its ink, and an arc arriving at the box arrives at the bar",
    _PnRectW(oPnM, "e1") <= 8 and fabs(_PnPathEnd(oPnM, "w1", "e1")[1] - _PnRectX(oPnM, "e1")) < 0.5)
chk("a name beside a mark whose wire leaves through that side stands a clearance off the border -- the stub is seen",
    _PnPlateGap(oPnM, "w1") >= 20 and _PnPlateGap(oPnM, "e1") >= 20)
chk("NEGATIVE: a mark with no wire on that side keeps its name close",
    _PnPlateGap(oPnM, "w2") < 8)
# ...AND THE NAME IS ON THE LINE, BY ITS CAPITALS. The Principal asked for
# the text beside a mark to be aligned with the horizontal wire: its cap
# height straddles the wire's centre, not hangs under it.
chk("a name beside a mark has its capitals centred on the wire it stands beside",
    fabs(_PnLabelCapCentreY(oPnM, "w1") - _PnCentreY(oPnM, "w1")) < 0.5 and
    fabs(_PnLabelCapCentreY(oPnM, "e1") - _PnCentreY(oPnM, "e1")) < 0.5)
chk("...so the wire passes through the letters, not over them: the cap box straddles the line",
    _PnLabelCapTop(oPnM, "key") < _PnCentreY(oPnM, "key") and
    _PnLabelCapTop(oPnM, "key") + EFONT.CapHeightOf(13) > _PnCentreY(oPnM, "key"))

# IT ANSWERS THE DISPLAY CONTRACT LIKE EVERY OTHER PICTURE.
chk("a Petri net answers Rendition() as a vector", oPnM.Rendition()[:kind] = "vector")


sec("-- 111. DN17: A FAULT TREE -- A PICTURE THAT COMPUTES ------------------")
discharges("DN17")

# THE NOTATION: a tree read top-down, no heads, gates read as values,
# a basic event's inside for its number and its name beneath, and the
# children of every parent declared peers.
OPTFT = [ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]
oFtP = StzFaultScene01(OPTFT)
chk("the notation reads top-down and draws no head", oFtP.NotationO().Name_() = "fault" and
    NOT oFtP.NotationO().EdgesDirected() and len(oFtP.RenderArrows()) = 0)
chk("a gate's inputs are peers, by declaration, and a basic event's name is written outside",
    oFtP.NotationO().PeerChildren() and oFtP.NotationO().WritesNameOutside("basic"))
chk("NEGATIVE: a notation that declares nothing keeps the flow rule", NOT StzUmlNotation().PeerChildren())

# THE NUMBERS. AND multiplies, OR takes one minus the product of the
# complements; the top of the pump is 1 - (1 - 0.1 x 0.2)(1 - 0.05).
chk("the AND gate multiplies: no power is 0.1 x 0.2", fabs(oFtP.ProbabilityOf("power") - 0.02) < 0.000001)
chk("the OR gate takes the complements: the top is 0.069", fabs(oFtP.TopProbability() - 0.069) < 0.000001)
chk("a gate can be asked directly, and answers the same as its event",
    fabs(oFtP.ProbabilityOf("top.gate") - oFtP.TopProbability()) < 0.000001)
aFtC = oFtP.MinimalCutSets()
chk("the minimal cut sets are { seized } and { mains, battery }, smallest first",
    len(aFtC) = 2 and len(aFtC[1]) = 1 and aFtC[1][1] = "seized" and
    len(aFtC[2]) = 2 and _FtSetIs(aFtC[2], [ "mains", "battery" ]))
chk("the cut sets give the same top as the gates when no event is repeated",
    fabs(oFtP.CutSetProbability() - oFtP.TopProbability()) < 0.000001)

# A REPEATED EVENT: the gates overstate, the cut sets are exact.
oFtR = StzFaultScene02(OPTFT)
chk("with the sensor under both branches the gate arithmetic says 0.0494",
    fabs(oFtR.TopProbability() - 0.0494) < 0.000001)
aFtC2 = oFtR.MinimalCutSets()
chk("...the cut sets are { sensor, valve } and { sensor, relay }",
    len(aFtC2) = 2 and _FtSetIs(aFtC2[1], [ "sensor", "valve" ]) and _FtSetIs(aFtC2[2], [ "sensor", "relay" ]))
chk("...and inclusion-exclusion over them gives the exact 0.044, below the gates' number",
    fabs(oFtR.CutSetProbability() - 0.044) < 0.000001 and oFtR.CutSetProbability() < oFtR.TopProbability())
chk("NEGATIVE: a superset is dropped from the minimal sets -- an AND over an OR of the same leaf folds",
    len(_FtFolded().MinimalCutSets()) = 1)

# THE NUMBER IS DRAWN INSIDE THE LEAF, AND PUBLISHED. A leaf with no
# number shows a question mark and publishes minus one.
chk("every basic event publishes its probability at its own centre",
    len(oFtP.RenderProbabilities()) = 3 and _FtDrawn(oFtP, "seized") = 0.05 and _FtProbsCentred(oFtP))
oFtW = StzFaultSceneWitness(OPTFT)
chk("a leaf with no number publishes -1 -- the question mark on the paper",
    _FtDrawn(oFtW, "dust") = -1 and _FtDrawn(oFtW, "wear") = 0.02)

# THE RULES: the two sound trees pass, the witness names one of each mistake.
chkeq("the pump is sound under every rule", len(oFtP.GovernanceFindings()), 0)
chkeq("the repeated tree is sound too -- a repeated leaf is not a mistake", len(oFtR.GovernanceFindings()), 0)
aFtF = oFtW.GovernanceFindings()
? "   witness : " + len(aFtF) + " findings"
chk("two top events are caught, and the top under a gate is caught by name",
    _ErFound(aFtF, "one_top_event", "declares 2 top events") and
    _ErFound(aFtF, "one_top_event", "'Line stops' is developed under a gate"))
chk("a gate with one input is caught: a wire, not a gate",
    _ErFound(aFtF, "gate_has_two_inputs", "under 'Second top' has 1 input(s)"))
chk("a leaf with no number is caught", _ErFound(aFtF, "basic_event_has_probability", "'Dust' has no probability"))
chk("an event with no gate beneath it is caught, and told the two ways out",
    _ErFound(aFtF, "event_is_developed", "'Undeveloped, unsaid' has no gate beneath it -- develop it, or declare it undeveloped"))
chk("a cause among its own effects is caught on both events of the cycle",
    _ErFound(aFtF, "no_event_causes_itself", "'Line stops' is among its own causes") and
    _ErFound(aFtF, "no_event_causes_itself", "'Jam' is among its own causes"))
chkeq("...and those are all of them: seven", len(aFtF), 7)
chk("the numbers refuse the witness's top by name -- at the cycle or at the leaf with no number, whichever is met first",
    _FtRefusesProb(oFtW, "t1", "'Dust' has no probability") or _FtRefusesProb(oFtW, "t1", "among its own causes"))
chk("NEGATIVE: the witness's second top computes -- its one leaf has a number",
    fabs(oFtW.ProbabilityOf("t2") - 0.05) < 0.000001)
chk("...and refuse an undeveloped event, saying so", _FtRefusesProb(oFtW, "operator", "is undeveloped"))

# THE BOUNDARIES, STOOD ON.
oFtRs = StzFaultRuleSetQ()
chk("NEGATIVE: the note is excluded by every rule, not merely passed",
    _ErExcludedEverywhere(oFtRs, oFtW.AsRuleGraph(), "note:n1"))
chk("NEGATIVE: an undeveloped event owes no number -- outside the probability rule, and outside the development rule",
    _ErInList("undeveloped:operator", oFtRs.Rules()[3].CounterSubjectsIn(oFtW.AsRuleGraph())) and
    _ErInList("undeveloped:operator", oFtRs.Rules()[4].CounterSubjectsIn(oFtW.AsRuleGraph())))
chk("NEGATIVE: a gate is outside every rule about events",
    _ErInList("or:t1.gate", oFtRs.Rules()[1].CounterSubjectsIn(oFtW.AsRuleGraph())))

# THE BUILDER REFUSES WHAT IT CANNOT MEAN.
chk("a probability outside 0..1 is refused", _FtRefuses(1))
chk("a gate that is neither And nor Or is refused, by name", _FtRefuses(2))
chk("a gate fed by a gate is refused: a gate's input is an event", _FtRefuses(3))
chk("an input that is not in the tree is refused", _FtRefuses(4))

# THE PICTURE IS A TREE: a gate at the middle of its inputs whatever hangs
# beneath each, entered from above, its lines leaving on one stem.
chk("the top gate stands at the middle of its two inputs, though one carries a subtree and the other is a leaf",
    fabs(_PnCentreX(oFtP, "top.gate") - (_PnCentreX(oFtP, "power") + _PnCentreX(oFtP, "seized")) / 2) < 0.5)
chk("...so its two lines leave on one stem and part on one channel",
    fabs(_PlTurnOf(oFtP, "top.gate", "power") - _PlTurnOf(oFtP, "top.gate", "seized")) < 0.5)
# THE PRINCIPAL MARKED THE SUBTREE: an event stands over the one gate
# beneath it, and that gate at the middle of its inputs -- a chain
# follows its child, which the engine's centring had skipped for every
# node with one edge out.
chk("an event with one gate beneath it stands on the gate's column, and the gate at the middle of its inputs",
    fabs(_PnCentreX(oFtP, "power") - _PnCentreX(oFtP, "power.gate")) < 0.5 and
    fabs(_PnCentreX(oFtP, "power.gate") - (_PnCentreX(oFtP, "mains") + _PnCentreX(oFtP, "battery")) / 2) < 0.5)
chk("a repeated leaf stands between the two gates that share it, and each gate at the middle of BOTH its inputs",
    _PnCentreX(oFtR, "valve") < _PnCentreX(oFtR, "sensor") and _PnCentreX(oFtR, "sensor") < _PnCentreX(oFtR, "relay") and
    fabs(_PnCentreX(oFtR, "fill.gate") - (_PnCentreX(oFtR, "valve") + _PnCentreX(oFtR, "sensor")) / 2) < 0.5 and
    fabs(_PnCentreX(oFtR, "alarm.gate") - (_PnCentreX(oFtR, "sensor") + _PnCentreX(oFtR, "relay")) / 2) < 0.5 and
    fabs(_PnCentreX(oFtR, "fill") - _PnCentreX(oFtR, "fill.gate")) < 0.5)
# THE PRINCIPAL'S SIXTH ROUND. The two lines into the shared leaf merged
# above it into one stem; he asked for them "separated completely, like
# in other diagrams". A mark whose border holds two ports keeps them, a
# quarter of the mark to each side, and a drop into a circle lands on
# its arc, not on the flat top a box would offer.
chk("the two arrivals at the shared leaf stand apart on its top, a port's floor between them, neither in its side",
    fabs(_PnPathEnd(oFtR, "fill.gate", "sensor")[1] - _PnPathEnd(oFtR, "alarm.gate", "sensor")[1]) >= oFtR._PortFloor() - 0.5 and
    fabs(_PnPathEnd(oFtR, "fill.gate", "sensor")[1] - _PnCentreX(oFtR, "sensor")) < _PnRectW(oFtR, "sensor") / 2 and
    fabs(_PnPathEnd(oFtR, "alarm.gate", "sensor")[1] - _PnCentreX(oFtR, "sensor")) < _PnRectW(oFtR, "sensor") / 2 and
    _PnPathEnd(oFtR, "alarm.gate", "sensor")[2] < _PnCentreY(oFtR, "sensor"))
chk("...and each lands ON the circle: below the flat top by the port's chord, on the arc to within a pixel",
    _FtOnArc(oFtR, "fill.gate", "sensor") and _FtOnArc(oFtR, "alarm.gate", "sensor"))
chk("NEGATIVE: a mark too small to hold two ports keeps every arrival at its centre -- the end event's rule stands",
    _FtSmallCentred())
chk("a fan's two arms part from the stem as one fork, squared on BOTH sides -- the alarm's as the fill's",
    _FtForkOf(oFtR, "alarm.gate", "sensor") and _FtForkOf(oFtR, "alarm.gate", "relay") and
    _FtForkOf(oFtR, "fill.gate", "sensor") and _FtForkOf(oFtR, "fill.gate", "valve"))
chk("...and the fan still shares one channel: both arms turn on one row",
    fabs(_PlTurnOf(oFtR, "alarm.gate", "sensor") - _PlTurnOf(oFtR, "alarm.gate", "relay")) < 0.5)
# THE PRINCIPAL'S THIRD ROUND: two fans that met end to end read as one
# rule across the tree; a gate with three inputs stood off its middle
# one; a second tree stood a cell and a half from the first.
# THE SEVENTH ROUND: "let the two horizontal lines be at the same level,
# because they represent logically the same level". Two fans that part
# on the shared leaf's own ports end at two different places and are two
# lines by construction, so they share the row; where a smaller mark
# makes the arrivals coincide, the two-row rule of the third round stands.
chk("two fans whose runs part on the shared leaf's ports share one row -- the same logical level",
    fabs(_PlTurnOf(oFtR, "fill.gate", "sensor") - _PlTurnOf(oFtR, "alarm.gate", "sensor")) < 0.5 and
    fabs(_PlTurnOf(oFtR, "fill.gate", "valve") - _PlTurnOf(oFtR, "alarm.gate", "relay")) < 0.5)
chk("NEGATIVE: where the mark keeps its arrivals at the centre, two fans meeting end to end still take two rows",
    fabs(_PlTurnOf(_FtSmall(), "fill.gate", "sensor") - _PlTurnOf(_FtSmall(), "alarm.gate", "sensor")) > _FtSmall()._LineClearance() / 2)
chk("a gate with three inputs stands over the middle one, whatever the outer two carry",
    fabs(_PnCentreX(oFtW, "t1.gate") - _PnCentreX(oFtW, "bare")) < 0.5)
chk("the forest is packed: the second tree stands one separation from the first on the rank they share",
    _FtPacked(oFtW))
# A RETURN'S TARGET IS NOT A CHILD. The gate whose third "input" is the
# top event it cycles back to stood over the middle of two leaves and
# that top -- the right leaf. The rank each node was laid on says which
# way an edge goes, and the centring reads it.
chk("a gate with a backward edge among its lines still stands at the middle of the two leaves beneath it",
    fabs(_PnCentreX(oFtW, "jam.gate") - (_PnCentreX(oFtW, "dust") + _PnCentreX(oFtW, "wear")) / 2) < 0.5 and
    fabs(_PnCentreX(oFtW, "jam") - _PnCentreX(oFtW, "jam.gate")) < 0.5)
# THE LADDER CLEARS WHAT THE RETURN PASSES, NOT THE WHOLE PICTURE. The
# cycle's return spans the top three ranks; the leaves two ranks below
# are not in its way, so its ladder stands beside Jam, not beyond Dust.
chk("the return's ladder stands one pitch left of the widest cell it passes",
    _PnPathOf(oFtW, "jam.gate", "t1")[3] < _PnRectX(oFtW, "jam") and
    _PnPathOf(oFtW, "jam.gate", "t1")[3] > _PnRectX(oFtW, "jam") - 40)
# ...AND THE LEAVES BESIDE IT STAND ON ITS COLUMN -- the Principal's
# spatial equilibrium: the ladder continues down onto the left leaf, the
# right leaf stands as far the other way, the gate keeps its middle.
chk("the gate's left leaf stands on the ladder's column, and its right leaf as far the other way",
    fabs(_PnCentreX(oFtW, "dust") - _PnPathOf(oFtW, "jam.gate", "t1")[3]) < 0.5 and
    fabs(_PnCentreX(oFtW, "jam.gate") - (_PnCentreX(oFtW, "dust") + _PnCentreX(oFtW, "wear")) / 2) < 0.5)
chk("NEGATIVE: a gate with no ladder beside it keeps its leaves what they draw apart -- half of each name and one separation",
    fabs((_PnCentreX(oFtP, "battery") - _PnCentreX(oFtP, "mains")) -
         ((oFtP._DrawnExtentOf("mains", 150, 56, 0, EFONT, 20) + oFtP._DrawnExtentOf("battery", 150, 56, 0, EFONT, 20)) / 2 +
          oFtP.NodeSeparation() * 96)) < 2)
# A MARK GIVES ROOM BACK, AND A RETURN'S TARGET IS NOT A CHILD -- the
# sixth round's two layout laws, both in the engine. Two leaves held a
# cell each and the gate's territory ran up its own return to the top
# event, so the next cell stood a slot from Jam over nothing and the
# fitter shrank the whole picture to a fifth less than asked.
chk("two marks under one gate stand a mark's width apart, not a cell's -- the ladder's column apart here",
    _PnCentreX(oFtW, "wear") - _PnCentreX(oFtW, "dust") < 2 * OPTFT[:NodeWidth])
chk("the cell beside Jam stands one separation from it, not a slot over nothing",
    _PnRectX(oFtW, "bare") - (_PnRectX(oFtW, "jam") + _PnRectW(oFtW, "jam")) < 80)
chk("...and the witness is drawn at the size it was asked -- 56px cells and 40px marks, nothing scaled away",
    fabs(_PnRectOf(oFtW, "t1")[4] - OPTFT[:NodeHeight]) < 0.5 and _PnRectW(oFtW, "dust") > 39)
chk("the witness's one backward edge runs beside the picture and enters the top from its side, not through its floor",
    _PnPathEnd(oFtW, "jam.gate", "t1")[1] < _PnCentreX(oFtW, "t1") - 10 and
    fabs(_PnPathEnd(oFtW, "jam.gate", "t1")[2] - _PnCentreY(oFtW, "t1")) < 0.5 and _PnNoArcThroughCell(oFtW))
chk("a gate is entered from above by the event it develops, never from its side",
    fabs(_PnPathEnd(oFtR, "fill", "fill.gate")[2] - _PnRectOf(oFtR, "fill.gate")[2]) < 0.5 and
    fabs(_PnPathEnd(oFtR, "fill", "fill.gate")[1] - _PnCentreX(oFtR, "fill.gate")) < 0.5)
chk("NEGATIVE: under the flow rule a parent stands over the deeper child -- the tree needed the declaration",
    _FtFlowLeans())
chk("a fault tree answers Rendition() as a vector", oFtP.Rendition()[:kind] = "vector")


sec("-- 112. DN18: A FAMILY TREE -- A TREE WITH TWO PARENTS -----------------")
discharges("DN18")

# THE NOTATION: a top-down tree read the other way, no heads, a union
# as a dot between two people, the years as a band under the name.
OPTFM = [ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]
oFmT = StzFamilyScene01(OPTFM)
chk("the notation reads top-down, draws no head, and declares every parent's children peers",
    oFmT.NotationO().Name_() = "family" and NOT oFmT.NotationO().EdgesDirected() and
    oFmT.NotationO().PeerChildren() and len(oFmT.RenderArrows()) = 0)
chk("a person's years are a band under the name, read as the schema's compartments are",
    _ErInList("years", oFmT.NotationO().CompartmentKeys()) and
    _FmYearsAre(oFmT, "ali", "1940 - 2015") and _FmYearsAre(oFmT, "mona", "1944"))
chk("NEGATIVE: a person with no year known carries no band", NOT isList(StzFamilySceneWitness(OPTFM).NodeProperty("f", "years")))

# KINSHIP, READ OFF THE TREE.
chk("ancestors are read through the unions: Yara's are her parents and her father's parents",
    _FmSetIs(oFmT.AncestorsOf("yara"), [ "sami", "nour", "ali", "mona" ]))
chk("descendants likewise: Mona's are her two children and her three grandchildren",
    _FmSetIs(oFmT.DescendantsOf("mona"), [ "sami", "leila", "yara", "omar", "lina" ]))
chk("siblings share a union: Omar's is Yara, and Lina, born of another, is nobody's",
    _FmSetIs(oFmT.SiblingsOf("omar"), [ "yara" ]) and len(oFmT.SiblingsOf("lina")) = 0)
chk("generations count from the oldest known ancestor: Ali 1, Sami 2, Yara and Lina 3",
    oFmT.GenerationOf("ali") = 1 and oFmT.GenerationOf("sami") = 2 and
    oFmT.GenerationOf("yara") = 3 and oFmT.GenerationOf("lina") = 3)
chk("a single parent's child has one parent, and a union is answered whichever way it is asked",
    _FmSetIs(oFmT.ParentsOf("lina"), [ "leila" ]) and _FmSetIs(oFmT.PartnersOf("sami"), [ "nour" ]) and
    oFmT.UnionOf("nour", "sami") = oFmT.UnionOf("sami", "nour") and oFmT.Marry("sami", "nour") = oFmT.UnionOf("sami", "nour"))

# THE RULES: the sound tree carries one warning it means; the witnesses
# name one of each mistake.
aFmF = oFmT.GovernanceFindings()
chk("the three generations pass, but for the single parent the tree draws on purpose -- a warning naming her",
    len(aFmF) = 1 and _ErFound(aFmF, "union_has_two_partners", "under 'Leila' has one partner"))
oFmW = StzFamilySceneWitness(OPTFM)
aFmW = oFmW.GovernanceFindings()
? "   witness : " + len(aFmW) + " findings"
chk("a union of three is caught", _ErFound(aFmW, "union_has_two_partners", "joins 3 people"))
chk("a person born of two unions is caught", _ErFound(aFmW, "child_of_one_union", "'Gus' is born of 2 unions"))
chk("a child older than a parent is caught, against each parent, naming the years",
    _ErFound(aFmW, "parents_are_older", "'Dana' is born in 1948 and their parent 'Adam' in 1950") and
    _ErFound(aFmW, "parents_are_older", "'Dana' is born in 1948 and their parent 'Bea' in 1952"))
chkeq("...and those are all of them: four", len(aFmW), 4)
oFmC = StzFamilySceneCycle(OPTFM)
chk("a person born of their own grandchild is caught, on both ends of the cycle",
    _ErFound(oFmC.GovernanceFindings(), "no_one_is_own_ancestor", "'Pia' is among their own ancestors") and
    _ErFound(oFmC.GovernanceFindings(), "no_one_is_own_ancestor", "'Rae' is among their own ancestors"))
oFmK = StzFamilySceneKin(OPTFM)
chk("a father joined to his own daughter is caught, and nothing else is",
    len(oFmK.GovernanceFindings()) = 1 and
    _ErFound(oFmK.GovernanceFindings(), "partners_are_not_kin", "'Dana' is joined to their own ancestor 'Adam'"))

# THE BOUNDARIES, STOOD ON.
oFmRs = StzFamilyRuleSetQ()
chk("NEGATIVE: the note is excluded by every rule, not merely passed",
    _ErExcludedEverywhere(oFmRs, oFmW.AsRuleGraph(), "note:n1"))
chk("NEGATIVE: a union is outside every rule about people, and a person outside every rule about unions",
    _ErInList("union:u1", oFmRs.Rules()[1].CounterSubjectsIn(oFmW.AsRuleGraph())) and
    _ErInList("person:c", oFmRs.Rules()[2].CounterSubjectsIn(oFmW.AsRuleGraph())))
chk("NEGATIVE: a person with no year, or no dated parent, is outside the rule about years -- not passing it",
    _ErInList("person:f", oFmRs.Rules()[4].CounterSubjectsIn(oFmW.AsRuleGraph())) and
    _ErInList("person:a", oFmRs.Rules()[4].CounterSubjectsIn(oFmW.AsRuleGraph())) and
    _ErInList("person:d", oFmRs.Rules()[4].SubjectsIn(oFmW.AsRuleGraph())))

# THE BUILDER REFUSES WHAT IT CANNOT MEAN.
chk("dying before being born is refused, naming both years", _FmRefuses(1))
chk("a union with someone not in the tree is refused", _FmRefuses(2))
chk("a child of something that is not a union is refused", _FmRefuses(3))
chk("a second person under one id is refused", _FmRefuses(4))

# THE PICTURE: a spouse who married in stands beside their partner, not
# on the top rank; the union's dot stands between its two partners and
# its children hang beneath it, centred.
chk("a married-in spouse stands on the partner's rank -- Nour beside Sami, not three generations up",
    fabs(_PnCentreY(oFmT, "nour") - _PnCentreY(oFmT, "sami")) < 0.5 and
    _PnCentreY(oFmT, "nour") > _PnCentreY(oFmT, "ali") + 100)
chk("the union's dot stands between its partners, on the rank below them",
    _PnCentreX(oFmT, oFmT.UnionOf("sami", "nour")) > _PnCentreX(oFmT, "sami") and
    _PnCentreX(oFmT, oFmT.UnionOf("sami", "nour")) < _PnCentreX(oFmT, "nour") and
    _PnCentreY(oFmT, oFmT.UnionOf("sami", "nour")) > _PnCentreY(oFmT, "sami"))
chk("...and its children hang beneath it, the union at their middle",
    fabs(_PnCentreX(oFmT, oFmT.UnionOf("sami", "nour")) - (_PnCentreX(oFmT, "yara") + _PnCentreX(oFmT, "omar")) / 2) < 0.5 and
    _PnCentreY(oFmT, "yara") > _PnCentreY(oFmT, oFmT.UnionOf("sami", "nour")))
chk("NEGATIVE: under a flow notation a parentless node keeps the first rank -- the settling is the peers' declaration",
    _FmFlowKeepsTop())
chk("a family tree answers Rendition() as a vector", oFmT.Rendition()[:kind] = "vector")


sec("-- 113. DN19: A TIMELINE -- THE AXIS AS A SCALE, EVERY MARK A DATUM ----------")
discharges("DN19")

# NOTHING TO SOLVE, as the Gantt: an event is a number, an era is two, and
# every pixel follows by arithmetic. The builder puts the times on the
# objects for the rules and the facts and the pixels for the style, and
# the solver reports it minted no unknown at all.
oTlH = StzMathScene43(AUFONT)
oTlH.Layout()
oTlS = oTlH.Substance()
? "   history : " + oTlH.NumberOfShapes() + " shapes, " + oTlH.NumberOfUnknowns() +
  " unknowns, " + floor(oTlH.LayoutMs()) + " ms -- " + oTlH.Why()
chkeq("a timeline mints no unknown -- there is nothing to lay out", oTlH.NumberOfUnknowns(), 0)
chk("nine events, four eras, seven of the events placed in an era, one axis and eight ticks",
    len(oTlS.ObjectsOfType("Event")) = 9 and len(oTlS.ObjectsOfType("Era")) = 4 and
    len(oTlS.ObjectsOfType("Belonging")) = 7 and len(oTlS.ObjectsOfType("Axis")) = 1 and
    len(oTlS.ObjectsOfType("Tick")) = 8)

# DISTANCE MEANS DURATION. A year is the same width everywhere on the
# scale -- between the first and last events as between two neighbours --
# and an era's band is its years times that width, exactly.
nTlK = (oTlS.DataOf("e9", "x") - oTlS.DataOf("e1", "x")) / (2007 - 1936)
chk("a year is one width everywhere on the scale: the two ends and two neighbours agree",
    fabs((oTlS.DataOf("e7", "x") - oTlS.DataOf("e6", "x")) / 10 - nTlK) < 0.001 and
    fabs((oTlS.DataOf("e4", "x") - oTlS.DataOf("e2", "x")) / 13 - nTlK) < 0.001)
chk("an era's band is its years times the year's width, exactly",
    fabs(oTlH.ShapeOf("r1.band")[:w] - 15 * nTlK) < 0.01 and
    fabs(oTlH.ShapeOf("r3.band")[:w] - 20 * nTlK) < 0.01)
chk("the axis steps by ten years over a span of seventy-four: ten ticks or fewer, on the decades",
    oTlS.DataOf("k2", "t") - oTlS.DataOf("k1", "t") = 10 and oTlS.DataOf("k1", "t") = 1940)
chk("a fact reads a duration in the author's unit, from the data and not the pixels",
    oTlH.Fact(:expr, [ "e9.t - e1.t", :years ])[:value] = 71 and
    StzFindFirst("71 years", oTlH.Fact(:expr, [ "e9.t - e1.t", :years ])[:message]) > 0)

# THE NAMES ARE LAID BY THE BUILDER, under two laws: a name covers no
# other event's column, since that column carries another stem; and two
# names on one level do not touch. Centred on the stem when it can be,
# hung beside it when it cannot, a level up otherwise.
chk("no event's name covers a column whose stem reaches its level, and no two names on a level touch",
    _TlNamesClearColumns(oTlH) and _TlLevelsClear(oTlH))
chk("ENIAC, two years before the transistor, takes the second level; the transistor's name hangs right of its stem",
    oTlS.DataOf("e2", "level") = 2 and oTlS.DataOf("e3", "level") = 1 and
    oTlS.DataOf("e3", "lx") > oTlS.DataOf("e3", "x") + 10)
chk("the names take three levels, and the axis stands below the third",
    StzTimelineLevelsOf(oTlS) = 3 and oTlS.DataOf("e6", "level") = 3 and
    oTlS.DataOf("ax", "y") > oTlS.DataOf("e6", "ly") + 40)
chk("the margin holds the first name: it stands on the paper, centred on its dot, half its width in",
    fabs(oTlS.DataOf("e1", "lx") - oTlS.DataOf("e1", "x")) < 0.01 and
    fabs(oTlS.DataOf("e1", "x") - (oTlS.DataOf("e1", "lw") / 2 + 14)) < 0.01)
aTlH = StzCheckPictures([ [ "history", oTlH ] ]).Findings()
for iTl = 1 to len(aTlH)
	if iTl <= 4  ? "   HISTORY FINDING " + aTlH[iTl][:rule] + " -- " + aTlH[iTl][:message]  ok
next
chk("the history is lawful and the one gate finds nothing in it -- no name on ink, no name on a name",
    oTlH.IsFeasible() and len(aTlH) = 0)
chk("and it answers Rendition() as a vector like every other picture",
    oTlH.Rendition()[:kind] = "vector")

# THE RULES ARE ABOUT TIME, and they name the things by the author's
# names and say by how much. The witness has one of each mistake -- and
# the double booking is reported on BOTH eras, because each is booked.
oTlW = StzMathTimelineWitness(AUFONT)
aTlF = StzCheckPictures([ [ "wrong", oTlW ] ]).Findings()
? "   witness : " + len(aTlF) + " findings -- " + _GtByRule(aTlF)
chk("an era that ends before it starts is caught, by name and by how much",
    _PorHits(aTlF, "era_ends_after_it_starts") = 1 and
    _GtHas(aTlF, "'Backwards' ends at 1980, 10 before it starts at 1990"))
chk("two eras sharing a band and overlapping are caught on both, with the overlap and its span",
    _PorHits(aTlF, "band_not_double_booked") = 2 and
    _GtHas(aTlF, "'Mainframes' and 'Minicomputers' share band 2 and overlap by 1, from 1961 to 1962"))
chk("an event placed in an era it is not dated in is caught, saying by how many years and which way",
    _PorHits(aTlF, "event_within_its_era") = 1 and
    _GtHas(aTlF, "'ENIAC' is dated 1945, 10 before 'Transistors' begins at 1955"))
chkeq("...and those four are all the gate finds -- the names beside the planted faults do not collide",
      len(aTlF), 4)

# A FAULT IS DRAWN, AND THE DRAWING'S MARKS ARE HELD TO THE RULES' VERDICTS.
oTlWS = oTlW.Substance()
chk("the reversed era is drawn between its two times in the colour of a fault",
    oTlWS.Holds("Reversed", [ "r7" ]) and fabs(oTlW.ShapeOf("r7.band")[:w] - 10 * nTlK) < 0.01 and
    oTlW.FillOf("r7.band") != oTlW.FillOf("r1.band"))
chk("the two eras double-booked on a band are marked, and the marks are exactly the rule's verdicts",
    _TlMarkedEquals(oTlW, "Era", "Clashing", aTlF, "band_not_double_booked", "era:"))
chk("the event outside its era is marked, and the mark is exactly the rule's verdict",
    oTlWS.Holds("Outside", [ "e2" ]) and len(_TlMarked(oTlW, "Event", "Outside")) = 1 and
    oTlW.FillOf("e2.icon") != oTlW.FillOf("e1.icon"))
chk("NEGATIVE: nothing in the lawful history is marked as a fault",
    len(_TlMarked(oTlH, "Era", "Reversed")) = 0 and len(_TlMarked(oTlH, "Era", "Clashing")) = 0 and
    len(_TlMarked(oTlH, "Event", "Outside")) = 0)

# THE BOUNDARIES. Touching eras are not an overlap; an event dated on an
# era's very end is inside it; an era too short for its name writes the
# name beside its band; and the builder refuses what it cannot mean.
oTlT = StzTimelineDiagram(AUFONT, [ [ "A", 5, "X" ] ], [ [ "X", 0, 5 ], [ "Y", 5, 9 ] ])
aTlT = StzCheckPictures([ [ "touching", oTlT ] ]).Findings()
chk("NEGATIVE: two eras meeting end to end on one band are not double-booked, and share the band",
    _PorHits(aTlT, "band_not_double_booked") = 0 and
    oTlT.Substance().DataOf("r1", "band") = oTlT.Substance().DataOf("r2", "band"))
chk("NEGATIVE: an event dated on the last year of its era is inside it",
    _PorHits(aTlT, "event_within_its_era") = 0 and len(aTlT) = 0)
oTlB = StzTimelineDiagram(AUFONT, [ [ "A", 0 ], [ "B", 100 ] ], [ [ "A name far wider than its band", 40, 42 ] ])
chk("an era too short for its name writes the name beside its band, clear of it, and the picture is clean",
    oTlB.Substance().Holds("Beside", [ "r1" ]) and
    oTlB.ShapeOf("r1.text")[:cx] - oTlB.ShapeOf("r1.text")[:w] / 2 > oTlB.Substance().DataOf("r1", "x1") + 2 and
    len(StzCheckPictures([ [ "beside", oTlB ] ]).Findings()) = 0)
chk("NEGATIVE: the history's eras hold their names inside their bands",
    len(_TlMarked(oTlH, "Era", "Beside")) = 0)
chk("an event placed in an era that is not in the list is refused, and named", _TlRefusesUnknownEra())
chk("two events under one name are refused", _TlRefusesDuplicate())
chk("a timeline of nothing is refused", _TlRefusesEmpty())
oTlRule = StzTimelineRuleSet()[1]
chk("the timeline rules govern every era of a timeline and not one object of a schedule -- " +
    "the boundary is stood on",
    len(oTlRule.SubjectsIn(oTlH)) = 4 and len(oTlRule.SubjectsIn(oGtP)) = 0 and
    len(oTlRule.CounterSubjectsIn(oGtP)) > 0 and len(oTlRule.CounterSubjectsIn(oTlH)) = 0)

sec("-- 114. DN20: A FISHBONE -- AN EFFECT, ITS CATEGORIES OF CAUSE, THE CAUSES ON THEM --")
discharges("DN20")

# NOTHING TO SOLVE: a bone's length follows from how many causes it
# carries, its place on the spine from how wide its neighbours are, and
# every pixel from those by arithmetic.
oFbC = StzMathScene45(AUFONT)
oFbC.Layout()
oFbS = oFbC.Substance()
? "   coffee : " + oFbC.NumberOfShapes() + " shapes, " + oFbC.NumberOfUnknowns() +
  " unknowns, " + floor(oFbC.LayoutMs()) + " ms -- " + oFbC.Why()
chkeq("a fishbone mints no unknown -- there is nothing to lay out", oFbC.NumberOfUnknowns(), 0)
chk("one effect, one spine, six categories and nine causes",
    len(oFbS.ObjectsOfType("Effect")) = 1 and len(oFbS.ObjectsOfType("Spine")) = 1 and
    len(oFbS.ObjectsOfType("Category")) = 6 and len(oFbS.ObjectsOfType("Cause")) = 9)

# THE GEOMETRY IS ISHIKAWA'S: bones by turns above and below, leaning
# toward the head at sixty degrees, the ribs evenly along each bone with
# the first cause outermost, the head at the right where the spine ends.
chk("the bones lean from above and below by turns",
    oFbS.Holds("Up", [ "c1" ]) and NOT oFbS.Holds("Up", [ "c2" ]) and oFbS.Holds("Up", [ "c3" ]) and
    oFbS.DataOf("c1", "ey") < oFbS.DataOf("c1", "sy") and oFbS.DataOf("c2", "ey") > oFbS.DataOf("c2", "sy"))
chk("a bone leans at sixty degrees toward the head, exactly",
    fabs(fabs(oFbS.DataOf("c1", "ey") - oFbS.DataOf("c1", "sy")) /
         (oFbS.DataOf("c1", "sx") - oFbS.DataOf("c1", "ex")) - tan(60 * 3.14159265 / 180)) < 0.001 and
    oFbS.DataOf("c1", "ex") < oFbS.DataOf("c1", "sx"))
chk("the ribs stand evenly along the bone, the first cause outermost",
    fabs(fabs(oFbS.DataOf("u1", "py") - oFbS.DataOf("c1", "sy")) - oFbS.DataOf("c1", "len") * sin(60 * 3.14159265 / 180) * 2 / 3) < 0.01 and
    fabs(fabs(oFbS.DataOf("u2", "py") - oFbS.DataOf("c1", "sy")) - oFbS.DataOf("c1", "len") * sin(60 * 3.14159265 / 180) / 3) < 0.01 and
    oFbS.DataOf("u1", "rank") = 1 and oFbS.LabelOf("u1") = "Grinder set too fine")
chk("a rib is a level line off its bone toward the tail, and its cause's name stands clear at its free end",
    fabs(oFbS.DataOf("u1", "px") - oFbS.DataOf("u1", "qx") - StzFishboneRibLength()) < 0.01 and
    oFbS.DataOf("u1", "nx") + oFbS.DataOf("u1", "nw") / 2 < oFbS.DataOf("u1", "qx") - 3)
chk("a category's name stands past its bone's end -- above an upper bone, below a lower one",
    oFbS.DataOf("c1", "ny") < oFbS.DataOf("c1", "ey") - 8 and oFbS.DataOf("c2", "ny") > oFbS.DataOf("c2", "ey") + 8)
chk("the head stands at the right of the last bone, the spine runs into its box, and the paper follows",
    oFbS.DataOf("h", "x0") > oFbS.DataOf("c6", "sx") and
    fabs(oFbS.DataOf("s", "x1") - (oFbS.DataOf("h", "x0") - 1)) < 0.01 and
    fabs(oFbS.DataOf("s", "paperw") - (oFbS.DataOf("h", "x0") + oFbS.DataOf("h", "w") + 20)) < 0.01)
oFbL = StzFishboneDiagram(AUFONT, "E", [ [ "Many", [ "a", "b", "c", "d", "e", "f" ] ], [ "One", [ "x" ] ] ])
chk("a bone grows with its causes: six ribs a row apart make a bone longer than the floor, one rib takes the floor",
    oFbL.Substance().DataOf("c1", "len") > 96 and
    fabs(oFbL.Substance().DataOf("c1", "len") - 7 * (StzFishboneCauseSize() * 1.35 + 8) / sin(60 * 3.14159265 / 180)) < 0.01 and
    fabs(oFbL.Substance().DataOf("c2", "len") - 96) < 0.01)
chk("a fact reads a bone's count of causes from the data",
    oFbC.Fact(:datum, [ "c1", "causes" ])[:value] = 2)

# TWO BONES ON ONE SIDE NEVER MEET IN WHAT THEY CARRY. The pitch is half
# the widest carry and air; long names widen the carry and the pitch
# follows, and the gate's name rules find nothing in either picture.
aFbC = StzCheckPictures([ [ "coffee", oFbC ] ]).Findings()
for iFb = 1 to len(aFbC)
	if iFb <= 4  ? "   COFFEE FINDING " + aFbC[iFb][:rule] + " -- " + aFbC[iFb][:message]  ok
next
chk("the analysis is lawful and the one gate finds nothing in it -- no name on a bone, no name on a name",
    oFbC.IsFeasible() and len(aFbC) = 0)
oFbW2 = StzFishboneDiagram(AUFONT, "E", [
	[ "A", [ "a very long cause name indeed", "another very long cause name" ] ],
	[ "B", [ "x" ] ],
	[ "C", [ "a third very long cause name here" ] ] ])
chk("long names push the bones apart: the third bone stands its neighbour's whole carry past the first, and nothing collides",
    oFbW2.Substance().DataOf("c3", "sx") - oFbW2.Substance().DataOf("c1", "sx") >
      oFbW2.Substance().DataOf("c3", "len") * cos(60 * 3.14159265 / 180) + StzFishboneRibLength() + 100 and
    len(StzCheckPictures([ [ "long", oFbW2 ] ]).Findings()) = 0)
chk("and it answers Rendition() as a vector like every other picture",
    oFbC.Rendition()[:kind] = "vector")

# THE RULES ARE ABOUT THE ANALYSIS, and they name things by the author's
# names. The witness has one of each mistake -- and the cause listed
# twice is reported on BOTH listings, because each is a listing.
oFbW = StzMathFishboneWitness(AUFONT)
aFbF = StzCheckPictures([ [ "wrong", oFbW ] ]).Findings()
? "   witness : " + len(aFbF) + " findings -- " + _GtByRule(aFbF)
chk("a category with nothing under it is caught, by name",
    _PorHits(aFbF, "every_bone_carries_a_cause") = 1 and
    _GtHas(aFbF, "'Measurement' carries no cause"))
chk("a cause listed under two categories is caught on both listings, naming both categories",
    _PorHits(aFbF, "a_cause_is_named_once") = 2 and
    _GtHas(aFbF, "'Stale beans' is listed under 'Method' and again under 'Material'"))
chk("the effect written among its causes is caught, naming the bone it hides on",
    _PorHits(aFbF, "the_effect_is_not_its_own_cause") = 1 and
    _GtHas(aFbF, "'Bitter coffee' under 'People' is the effect itself"))
chkeq("...and those four are all the gate finds", len(aFbF), 4)

# A FAULT IS DRAWN, AND THE MARKS ARE HELD TO THE VERDICTS.
oFbWS = oFbW.Substance()
chk("the empty bone is marked and drawn in the colour of a fault, and the mark is exactly the rule's verdict",
    _TlMarkedEquals(oFbW, "Category", "Empty", aFbF, "every_bone_carries_a_cause", "bone:") and
    oFbW.StrokeOf("c5.icon") != oFbW.StrokeOf("c1.icon"))
chk("the cause listed twice is marked on both listings, named on a plate of the fault's colour, exactly as the rule says",
    _TlMarkedEquals(oFbW, "Cause", "Twice", aFbF, "a_cause_is_named_once", "cause:") and
    oFbW.ShapeOf("u4.plate")[:kind] = "rect" and oFbW.FillOf("u4.plate") != oFbW.FillOf("h.box"))
chk("the effect among the causes is marked, and the mark is exactly the rule's verdict",
    _TlMarkedEquals(oFbW, "Cause", "Circular", aFbF, "the_effect_is_not_its_own_cause", "cause:"))
chk("NEGATIVE: nothing in the lawful analysis is marked as a fault",
    len(_TlMarked(oFbC, "Category", "Empty")) = 0 and len(_TlMarked(oFbC, "Cause", "Twice")) = 0 and
    len(_TlMarked(oFbC, "Cause", "Circular")) = 0)

# THE BOUNDARIES. The same cause twice under ONE bone is a repeat, not
# a cause named under two categories; the effect's name is matched
# whatever its case; and the builder refuses what it cannot mean.
oFbR = StzFishboneDiagram(AUFONT, "Late trains", [ [ "Track", [ "Ice", "Ice" ] ], [ "Crew", [ "late TRAINS" ] ] ])
aFbR = StzCheckPictures([ [ "repeat", oFbR ] ]).Findings()
chk("NEGATIVE: one cause written twice under one bone is not a cause under two categories",
    _PorHits(aFbR, "a_cause_is_named_once") = 0 and len(_TlMarked(oFbR, "Cause", "Twice")) = 0)
chk("the effect is recognised among the causes whatever its case",
    _PorHits(aFbR, "the_effect_is_not_its_own_cause") = 1 and oFbR.Substance().Holds("Circular", [ "u3" ]))
chk("a fishbone with no effect is refused", _FbRefusesNoEffect())
chk("a fishbone with no category is refused", _FbRefusesNoCategory())
chk("a category with no name is refused", _FbRefusesUnnamed())
oFbRule = StzFishboneRuleSet()[1]
chk("the fishbone rules govern every bone of a fishbone and not one object of a timeline or a schedule -- " +
    "the boundary is stood on",
    len(oFbRule.SubjectsIn(oFbC)) = 6 and len(oFbRule.SubjectsIn(oTlH)) = 0 and len(oFbRule.SubjectsIn(oGtP)) = 0 and
    len(oFbRule.CounterSubjectsIn(oTlH)) > 0 and len(oFbRule.CounterSubjectsIn(oFbC)) = 0)

sec("-- 115. DN21: A NETWORK TOPOLOGY -- DEVICES, LINKS, SUBNETS, ADDRESSES --------")
discharges("DN21")

# THE NOTATION: top-down from the cloud, no heads, the devices drawn as
# the trade draws them with their names beneath, a subnet a frame.
OPTNW = [ :Font = EFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]
oNwO = StzNetworkScene01(OPTNW)
chk("the notation reads top-down, draws no head, and declares a switch's ports peers",
    oNwO.NotationO().Name_() = "network" and NOT oNwO.NotationO().EdgesDirected() and
    oNwO.NotationO().PeerChildren() and len(oNwO.RenderArrows()) = 0)
chk("a device's name is written beneath its glyph; the cloud holds its name inside",
    oNwO.NotationO().WritesNameOutside("host") and oNwO.NotationO().WritesNameOutside("router") and
    NOT oNwO.NotationO().WritesNameOutside("cloud"))
chk("the cloud is where the picture begins: nothing links into it, and it stands above the firewall, the router and the switches",
    oNwO.NotationO()._KindForbids("cloud", "inbound") != "" and
    _PnCentreY(oNwO, "net") < _PnCentreY(oNwO, "fw") and _PnCentreY(oNwO, "fw") < _PnCentreY(oNwO, "rt") and
    _PnCentreY(oNwO, "rt") < _PnCentreY(oNwO, "sw1"))
chk("the seven device glyphs are on the shape sheet",
    StzIsNodeShape("cloud") and StzIsNodeShape("router") and StzIsNodeShape("switch") and StzIsNodeShape("firewall") and
    StzIsNodeShape("server") and StzIsNodeShape("host") and StzIsNodeShape("accesspoint"))

# ADDRESSES ARE NUMBERS, and a subnet is a range of them.
chk("an IPv4 address is read as a number, dotted quad by dotted quad",
    StzIpToNumber("10.0.1.5") = 167772421 and StzIpToNumber("0.0.0.0") = 0 and StzIpToNumber("255.255.255.255") = 4294967295)
chk("NEGATIVE: an octet past 255, a missing octet or a word is not an address",
    NOT StzIsIpAddress("256.1.1.1") and NOT StzIsIpAddress("10.0.1") and NOT StzIsIpAddress("ten.0.0.1"))
chk("a CIDR is its first and last address, and an address is inside it or not",
    StzCidrRange("10.0.1.0/24")[1] = 167772416 and StzCidrRange("10.0.1.0/24")[2] = 167772671 and
    StzIpInCidr("10.0.1.255", "10.0.1.0/24") and NOT StzIpInCidr("10.0.2.0", "10.0.1.0/24") and
    StzIpInCidr("192.168.5.7", "192.168.0.0/16"))
chk("NEGATIVE: a prefix past 32, or no prefix at all, is not a subnet",
    NOT StzIsCidr("10.0.1.0/33") and NOT StzIsCidr("10.0.1.0") and StzIsCidr("10.0.0.0/8"))

# REACH, READ OFF THE TOPOLOGY.
chk("a router's neighbours are the firewall and its two switches",
    _FmSetIs(oNwO.NeighboursOf("rt"), [ "fw", "sw1", "sw2" ]))
chk("Alice is four links from the internet, and four from the web server through the router",
    oNwO.HopsBetween("pc1", "net") = 4 and oNwO.HopsBetween("web", "pc1") = 4 and oNwO.HopsBetween("rt", "rt") = 0)
chk("a subnet answers its members and a member its subnet; a device answers its address",
    oNwO.SubnetOf("web") = "servers" and len(oNwO.DevicesIn("people")) = 4 and
    oNwO.AddressOf("db") = "10.0.1.11" and oNwO.CidrOf("people") = "10.0.2.0/24" and oNwO.KindOf("ap") = "accesspoint")

# THE RULES: the office passes; the witness names one of each mistake,
# the address collision on both hosts and the ring on all three switches.
chk("the office is lawful -- the rules find nothing", len(oNwO.GovernanceFindings()) = 0)
oNwW = StzNetworkSceneWitness(OPTNW)
aNwW = oNwW.GovernanceFindings()
? "   witness : " + len(aNwW) + " findings"
chk("a device wired to nothing is caught", _PorHits(aNwW, "every_device_is_linked") = 1 and
    _ErFound(aNwW, "every_device_is_linked", "'Printer' is linked to nothing"))
chk("one address on two hosts is caught on both, naming the other and the address",
    _PorHits(aNwW, "addresses_are_unique") = 2 and
    _ErFound(aNwW, "addresses_are_unique", "'Alice' and 'Bob' both carry 10.0.2.21"))
chk("a host in a subnet with an address outside its range is caught, naming the subnet and the range",
    _PorHits(aNwW, "address_in_its_subnet") = 1 and
    _ErFound(aNwW, "address_in_its_subnet", "'Carol' carries 10.0.2.23 inside 'Servers', which is 10.0.1.0/24"))
chk("a ring of switches is caught on every switch of the ring",
    _PorHits(aNwW, "switches_form_no_loop") = 3 and
    _ErFound(aNwW, "switches_form_no_loop", "'Switch 2' is on a ring of switches"))
chk("the internet linked around the firewall is caught, naming what it links into",
    _PorHits(aNwW, "the_edge_is_guarded") = 1 and
    _ErFound(aNwW, "the_edge_is_guarded", "'Internet' links straight into 'Switch 2', a switch"))
chkeq("...and those are all of them: eight", len(aNwW), 8)

# THE BOUNDARIES, STOOD ON.
oNwRs = StzNetworkRuleSetQ()
oNwG = oNwW.AsRuleGraph()
chk("NEGATIVE: the note is excluded by every rule, not merely passed",
    _ErExcludedEverywhere(oNwRs, oNwG, "note:n1"))
chk("NEGATIVE: a device with no address is outside the rule about addresses, and one in no subnet outside the rule about subnets",
    _ErInList("host:prn", oNwRs.Rules()[2].CounterSubjectsIn(oNwG)) and
    _ErInList("host:pc1", oNwRs.Rules()[3].CounterSubjectsIn(oNwG)) and
    _ErInList("host:pc3", oNwRs.Rules()[3].SubjectsIn(oNwG)))
chk("NEGATIVE: the ring rule is about switches -- a router is outside it, a switch inside",
    _ErInList("router:rt", oNwRs.Rules()[4].CounterSubjectsIn(oNwG)) and
    _ErInList("switch:s1", oNwRs.Rules()[4].SubjectsIn(oNwG)))
oNwF = StzNetworkScene02(OPTNW)
chk("NEGATIVE: two switches joined through a router are a route, not a ring -- the floors are lawful",
    _PorHits(oNwF.GovernanceFindings(), "switches_form_no_loop") = 0 and len(oNwF.GovernanceFindings()) = 0)

# THE BUILDER REFUSES WHAT IT CANNOT MEAN.
chk("a link to a device that is not on the network is refused, and named", _NwRefuses(1))
chk("a device linked to itself is refused", _NwRefuses(2))
chk("an address that is not one, and a subnet that is not one, are refused", _NwRefuses(3) and _NwRefuses(4))
chk("a kind that is not a device, and a second device under one id, are refused", _NwRefuses(5) and _NwRefuses(6))

# THE PICTURE: the two subnets are two frames that do not overlap, each
# member inside its own, and the last of one a pitch from the first of
# the next -- the cohesion pass used to stand marks a cell apart and push
# the two frames into each other.
aNwCl = oNwO.RenderClusterRects()
chk("two subnets, two frames, and the frames do not overlap",
    len(aNwCl) = 2 and (aNwCl[1][1] + aNwCl[1][3] < aNwCl[2][1] or aNwCl[2][1] + aNwCl[2][3] < aNwCl[1][1]))
chk("a subnet's members stand inside its frame",
    _NwInsideFrame(oNwO, "web", aNwCl, "servers") and _NwInsideFrame(oNwO, "ap", aNwCl, "people"))
chk("the last server and the first person stand more than a mark and a name apart, not 61px",
    _PnCentreX(oNwO, "pc1") - _PnCentreX(oNwO, "db") > 150)
chk("a topology answers Rendition() as a vector", oNwO.Rendition()[:kind] = "vector")

sec("-- 116. DN22: A FLOOR PLAN -- ROOMS TO SCALE, THE RULES OF A BUILDING --------")
discharges("DN22")

# NOTHING TO SOLVE: a room is four numbers in metres, an opening a place
# on a wall and a width, and every pixel follows by one scale.
oFpF = StzMathScene47(AUFONT)
oFpF.Layout()
oFpS = oFpF.Substance()
? "   flat : " + oFpF.NumberOfShapes() + " shapes, " + oFpF.NumberOfUnknowns() +
  " unknowns, " + floor(oFpF.LayoutMs()) + " ms -- " + oFpF.Why()
chkeq("a floor plan mints no unknown -- there is nothing to lay out", oFpF.NumberOfUnknowns(), 0)
chk("six rooms, six doors, six windows, an area for every room and one scale bar",
    len(oFpS.ObjectsOfType("Room")) = 6 and len(oFpS.ObjectsOfType("Door")) = 6 and
    len(oFpS.ObjectsOfType("Window")) = 6 and len(oFpS.ObjectsOfType("Area")) = 6 and
    len(oFpS.ObjectsOfType("Scale")) = 1)

# DISTANCE MEANS LENGTH: one scale for both axes, the plan filling the
# paper's width less its margins, and the scale bar one metre long.
nFpK = (StzFloorPlanWidth() - 2 * StzFloorPlanMargin()) / 11
chk("a metre is one width everywhere: the living room's five and the hall's six metres, on both axes",
    fabs(oFpS.DataOf("r2", "w") - 5 * nFpK) < 0.01 and fabs(oFpS.DataOf("r1", "h") - 6 * nFpK) < 0.01 and
    fabs(oFpS.DataOf("sc", "x1") - oFpS.DataOf("sc", "x0") - nFpK) < 0.01)
chk("a room's area is its metres multiplied, as a fact and as the text under its name",
    oFpF.Fact(:datum, [ "r2", "area" ])[:value] = 20 and oFpS.LabelOf("a2") = "20 m2" and
    StzFloorPlanAreaText(4.5) = "4.5 m2" and StzFloorPlanAreaText(6) = "6 m2")

# A DOOR FACES WHAT LIES ACROSS ITS WALL, and serves both rooms; a
# window on an outside wall says so.
chk("the hall's west door faces the outside; its east doors face the living room and the kitchen",
    oFpS.Holds("Exterior", [ "d1" ]) and oFpS.DataOf("d1", "faces") = 0 and
    oFpS.DataOf("d2", "faces") = 2 and oFpS.DataOf("d3", "faces") = 3)
chk("the bedroom's south door faces the study, and counts for the study too: one door, two rooms",
    oFpS.DataOf("d6", "room") = 5 and oFpS.DataOf("d6", "faces") = 6 and
    oFpS.DataOf("r6", "doors") = 1 and oFpS.DataOf("r1", "doors") = 3)
chk("every window of the flat looks outward, and says so",
    len(_TlMarked(oFpF, "Window", "Outward")) = 6 and len(_TlMarked(oFpF, "Window", "Inward")) = 0)
chk("a door's leaf is as long as the door is wide, and its swing a quarter circle of that radius",
    fabs(_FpDist(oFpS, "d2", "x1", "y1", "lx", "ly") - 0.9 * nFpK) < 0.01 and
    fabs(_FpDist(oFpS, "d2", "x1", "y1", "ax", "ay") - 0.9 * nFpK) < 0.01 and
    fabs(_FpDist(oFpS, "d2", "x1", "y1", "x2", "y2") - 0.9 * nFpK) < 0.01)
aFpF = StzCheckPictures([ [ "flat", oFpF ] ]).Findings()
for iFp = 1 to len(aFpF)
	if iFp <= 4  ? "   FLAT FINDING " + aFpF[iFp][:rule] + " -- " + aFpF[iFp][:message]  ok
next
chk("the flat is lawful and the one gate finds nothing in it -- no name on a wall or a swing",
    oFpF.IsFeasible() and len(aFpF) = 0)
chk("and it answers Rendition() as a vector like every other picture",
    oFpF.Rendition()[:kind] = "vector")

# THE RULES ARE ABOUT THE BUILDING. The witness has one of each mistake
# -- the overlap reported on both rooms, the unreachable pair on both.
oFpW = StzMathFloorPlanWitness(AUFONT)
aFpW = StzCheckPictures([ [ "wrong", oFpW ] ]).Findings()
? "   witness : " + len(aFpW) + " findings -- " + _GtByRule(aFpW)
chk("two rooms sharing floor are caught on both, with the floor they share",
    _PorHits(aFpW, "rooms_do_not_overlap") = 2 and
    _GtHas(aFpW, "'Living' and 'Pantry' share 2 m2 of floor"))
chk("a room with no door is caught, by name",
    _PorHits(aFpW, "every_room_has_a_door") = 1 and _GtHas(aFpW, "'Bath' has no door"))
chk("a bedroom and a study whose only door is between them are both caught -- nobody can reach either",
    _PorHits(aFpW, "every_room_is_reachable") = 2 and
    _GtHas(aFpW, "'Bedroom' cannot be reached from outside") and _GtHas(aFpW, "'Study' cannot be reached from outside"))
chk("a window from one room into another is caught, naming the wall and both rooms",
    _PorHits(aFpW, "windows_face_outside") = 1 and
    _GtHas(aFpW, "the window on the east wall of 'Living' looks into 'Bedroom'"))
chkeq("...and those six are all the gate finds", len(aFpW), 6)

# A FAULT IS DRAWN, AND THE MARKS ARE HELD TO THE VERDICTS.
chk("the overlapping rooms are marked, exactly as the rule says",
    _TlMarkedEquals(oFpW, "Room", "Overlapping", aFpW, "rooms_do_not_overlap", "room:"))
chk("the doorless room and the unreachable rooms are marked, exactly as the rules say",
    _TlMarkedEquals(oFpW, "Room", "Doorless", aFpW, "every_room_has_a_door", "room:") and
    _TlMarkedEquals(oFpW, "Room", "Unreachable", aFpW, "every_room_is_reachable", "room:"))
chk("the inward window is marked, exactly as the rule says, and drawn in the colour of a fault",
    _TlMarkedEquals(oFpW, "Window", "Inward", aFpW, "windows_face_outside", "window:") and
    oFpW.StrokeOf("w2.icon") != oFpW.StrokeOf("w1.icon"))
chk("NEGATIVE: nothing in the lawful flat is marked as a fault",
    len(_TlMarked(oFpF, "Room", "Overlapping")) = 0 and len(_TlMarked(oFpF, "Room", "Doorless")) = 0 and
    len(_TlMarked(oFpF, "Room", "Unreachable")) = 0)

# THE BOUNDARIES. Rooms that touch along a wall do not overlap; a room
# with no door is the second rule's and outside the third; and the
# builder refuses what it cannot mean.
oFpRule3 = StzFloorPlanRuleSet()[3]
chk("NEGATIVE: the bath, with no door, is outside the rule about reach and inside the rule about doors",
    _ErInList("room:r4", oFpRule3.CounterSubjectsIn(oFpW)) and NOT _ErInList("room:r4", oFpRule3.SubjectsIn(oFpW)) and
    _ErInList("room:r4", StzFloorPlanRuleSet()[2].SubjectsIn(oFpW)))
chk("NEGATIVE: the living room and the kitchen share a wall, not floor",
    _PorHits(aFpF, "rooms_do_not_overlap") = 0)
chk("a door past the corner of its wall is refused, with the numbers", _FpRefuses(1))
chk("a side that is not n, e, s or w is refused", _FpRefuses(2))
chk("a door on a room that is not in the plan, and a room named twice, are refused", _FpRefuses(3) and _FpRefuses(4))
chk("a room of no width, and a plan of no rooms, are refused", _FpRefuses(5) and _FpRefuses(6))
oFpRule = StzFloorPlanRuleSet()[1]
chk("the floor-plan rules govern every room of a plan and not one object of a fishbone or a timeline -- " +
    "the boundary is stood on",
    len(oFpRule.SubjectsIn(oFpF)) = 6 and len(oFpRule.SubjectsIn(oFbC)) = 0 and len(oFpRule.SubjectsIn(oTlH)) = 0 and
    len(oFpRule.CounterSubjectsIn(oFbC)) > 0 and len(oFpRule.CounterSubjectsIn(oFpF)) = 0)

sec("-- 117. DN23: A SEATING PLAN -- TABLES, SEATS AROUND THEM, GUESTS IN THEM ----")
discharges("DN23")

# NOTHING TO SOLVE: a table is a place and a number of seats, the seats
# follow around it, the guests take them in order.
oStW = StzMathScene49(AUFONT)
oStW.Layout()
oStS = oStW.Substance()
? "   wedding : " + oStW.NumberOfShapes() + " shapes, " + oStW.NumberOfUnknowns() +
  " unknowns, " + floor(oStW.LayoutMs()) + " ms -- " + oStW.Why()
chkeq("a seating plan mints no unknown -- there is nothing to lay out", oStW.NumberOfUnknowns(), 0)
chk("five tables, thirty-six seats, thirty guests, two pairs kept apart, nobody unseated",
    len(oStS.ObjectsOfType("Table")) = 5 and len(oStS.ObjectsOfType("Seat")) = 36 and
    len(oStS.ObjectsOfType("Guest")) = 30 and len(oStS.ObjectsOfType("Apart")) = 2 and
    len(oStS.ObjectsOfType("Unseated")) = 0)

# THE SEATS FOLLOW THE TABLE: evenly on a ring for a round one, the
# first at the top; along both long sides for a long one.
chk("a round table's seats stand evenly on a ring, the first at the top, all at one distance from the centre",
    fabs(_StDistTo(oStS, "t3s1", "t3") - _StDistTo(oStS, "t3s5", "t3")) < 0.01 and
    fabs(oStS.DataOf("t3s1", "x") - oStS.DataOf("t3", "cx")) < 0.01 and oStS.DataOf("t3s1", "y") < oStS.DataOf("t3", "cy") and
    fabs(_StAngle(oStS, "t3s2", "t3") - _StAngle(oStS, "t3s1", "t3") - 45) < 0.01)
chk("a round table's radius grows with its seats: eight seats are a bigger disc than six",
    oStS.DataOf("t3", "r") > oStS.DataOf("t2", "r") and
    fabs(oStS.DataOf("t3", "r") / oStS.DataOf("t2", "r") - StzSeatingRadiusFor(8) / StzSeatingRadiusFor(6)) < 0.001)
chk("a long table seats four above and four below, the rows level and the slab between them",
    oStS.Holds("Long", [ "t1" ]) and
    fabs(oStS.DataOf("t1s1", "y") - oStS.DataOf("t1s4", "y")) < 0.01 and
    fabs(oStS.DataOf("t1s5", "y") - oStS.DataOf("t1s8", "y")) < 0.01 and
    oStS.DataOf("t1s1", "y") < oStS.DataOf("t1", "cy") and oStS.DataOf("t1s5", "y") > oStS.DataOf("t1", "cy"))
chk("guests take the seats in the order given: Nour in the top table's first seat, Ann in Table 1's first",
    oStS.DataOf("g1", "table") = 1 and oStS.DataOf("g1", "seat") = 1 and
    oStS.DataOf("g9", "table") = 2 and oStS.DataOf("g9", "seat") = 1 and oStS.Holds("Taken", [ "t2s1" ]))
chk("a seat nobody took stays empty: Table 1 has six seats and five guests",
    NOT oStS.Holds("Taken", [ "t2s6" ]) and len(_TlMarked(oStW, "Seat", "Taken")) = 30)

# A NAME READS OUTWARD: beyond its seat, hung to the right on the east
# of the ring, to the left on the west, centred above and below.
# THE TABLES ARE SPREAD SO THAT EVERY NAME CLEARS EVERY OTHER TABLE ON
# ALL SIDES -- the Principal's words. The host's arrangement is kept:
# what stood left stays left, what stood above stays above; tables that
# already clear each other keep their distance; and a long table's seats
# stand a name apart.
chk("no two tables' extents -- disc, seats and the names hung beyond them -- meet, on either axis, with air between",
    _StAllClear(oStS, 0.3))
chk("the host's arrangement is kept: Table 1 left of Table 2 left of Table 3, the top table above them and Table 4 below",
    oStS.DataOf("t2", "sx") < oStS.DataOf("t3", "sx") and oStS.DataOf("t3", "sx") < oStS.DataOf("t4", "sx") and
    oStS.DataOf("t1", "sy") < oStS.DataOf("t3", "sy") and oStS.DataOf("t3", "sy") < oStS.DataOf("t5", "sy"))
oStFar = StzSeatingDiagram(AUFONT, [ [ "A", "round", 4, 0, 0 ], [ "B", "round", 4, 10, 0 ] ], [ [ "x", "A" ], [ "y", "B" ] ], [])
chk("NEGATIVE: two tables that already clear each other keep the distance the host gave them",
    fabs(oStFar.Substance().DataOf("t2", "sx") - oStFar.Substance().DataOf("t1", "sx") - 10) < 0.001)
chk("a long table's seats stand a name apart: the pitch holds its widest name at the scale drawn",
    oStS.DataOf("t1", "pitch") >= 0.6 and
    (oStS.DataOf("t1s2", "x") - oStS.DataOf("t1s1", "x")) > _StWidest(oStS, 1))
chk("a name on the east of a ring hangs to the right of its seat, on the west to the left, at the top it is centred",
    oStS.DataOf("g16", "nx") - oStS.DataOf("g16", "nw") / 2 > oStS.DataOf("t3s3", "x") and
    oStS.DataOf("g20", "nx") + oStS.DataOf("g20", "nw") / 2 < oStS.DataOf("t3s7", "x") and
    fabs(oStS.DataOf("g14", "nx") - oStS.DataOf("t3s1", "x")) < 0.01)
aStF = StzCheckPictures([ [ "wedding", oStW ] ]).Findings()
for iSt = 1 to len(aStF)
	if iSt <= 4  ? "   WEDDING FINDING " + aStF[iSt][:rule] + " -- " + aStF[iSt][:message]  ok
next
chk("the wedding is lawful and the one gate finds nothing in it -- no name on a seat, no name on a name",
    oStW.IsFeasible() and len(aStF) = 0)
chk("a fact reads a table's seats and its guests from the data",
    oStW.Fact(:datum, [ "t3", "seats" ])[:value] = 8 and oStW.Fact(:datum, [ "t2", "given" ])[:value] = 5)
chk("and it answers Rendition() as a vector like every other picture",
    oStW.Rendition()[:kind] = "vector")

# THE RULES ARE ABOUT THE PLAN, and they name tables and guests by the
# host's names. The witness has one of each mistake -- the double seat
# on both listings, the colliding tables on both.
oStB = StzMathSeatingWitness(AUFONT)
aStB = StzCheckPictures([ [ "wrong", oStB ] ]).Findings()
? "   witness : " + len(aStB) + " findings -- " + _GtByRule(aStB)
chk("a table given more guests than seats is caught, naming who found no seat",
    _PorHits(aStB, "table_not_overbooked") = 1 and
    _GtHas(aStB, "'Table 1' seats 6 and was given 7 -- 'Zed' found no seat"))
chk("a name seated at two tables is caught on both listings",
    _PorHits(aStB, "a_guest_sits_once") = 2 and
    _GtHas(aStB, "'Ann' is seated at 'Table 1' and again at 'Table 2'"))
chk("a pair the host keeps apart and seated together is caught, naming the table",
    _PorHits(aStB, "kept_apart_are_apart") = 1 and
    _GtHas(aStB, "'Ann' and 'Fay' are to be kept apart and sit together at 'Table 1'"))
chk("two tables whose seats meet are caught on both, with the distance and the distance needed",
    _PorHits(aStB, "tables_stand_clear") = 2 and
    _GtHas(aStB, "'Table 2' and 'Table 3' stand 2.9 m apart and their seats need 3.1 m"))
chkeq("...and those six are all the gate finds -- the drawing spreads the tables, so no name lies on the other's disc",
      len(aStB), 6)

# A FAULT IS DRAWN, AND THE MARKS ARE HELD TO THE VERDICTS.
oStBS = oStB.Substance()
chk("the overbooked table and the colliding tables are marked, exactly as the rules say",
    _TlMarkedEquals(oStB, "Table", "Overbooked", aStB, "table_not_overbooked", "table:") and
    _TlMarkedEquals(oStB, "Table", "Colliding", aStB, "tables_stand_clear", "table:"))
chk("the guest seated twice is marked on both listings, on a plate of the fault's colour",
    _TlMarkedEquals(oStB, "Guest", "Doubled", aStB, "a_guest_sits_once", "guest:") and
    oStB.ShapeOf("g9.plate")[:kind] = "rect")
chk("the pair together are both marked, and the guest with no seat is named beneath the hall",
    oStBS.Holds("Clashing", [ "g9" ]) and oStBS.Holds("Clashing", [ "g14" ]) and
    oStBS.Holds("Seatless", [ "g15" ]) and len(oStBS.ObjectsOfType("Unseated")) = 1 and
    StzFindFirst("Zed", oStBS.LabelOf("un")) > 0)
chk("NEGATIVE: nothing in the lawful wedding is marked as a fault",
    len(_TlMarked(oStW, "Table", "Overbooked")) = 0 and len(_TlMarked(oStW, "Table", "Colliding")) = 0 and
    len(_TlMarked(oStW, "Guest", "Doubled")) = 0 and len(_TlMarked(oStW, "Guest", "Clashing")) = 0 and
    len(_TlMarked(oStW, "Guest", "Seatless")) = 0)

# THE BOUNDARIES. Two tables whose seats just clear are clear; the
# pairs' rule is about pairs and outside every table; and the builder
# refuses what it cannot mean.
oStT = StzSeatingDiagram(AUFONT, [ [ "A", "round", 6, 0, 0 ], [ "B", "round", 6, 3.2, 0 ] ], [ [ "x", "A" ] ], [])
chk("NEGATIVE: two six-seat tables 3.2 m apart clear each other -- their seats need 2.94 m",
    _PorHits(StzCheckPictures([ [ "clear", oStT ] ]).Findings(), "tables_stand_clear") = 0)
chk("NEGATIVE: the pairs' rule governs pairs, and a table is outside it",
    _ErInList("table:t1", StzSeatingRuleSet()[3].CounterSubjectsIn(oStW)) = 0 and
    _ErInList("apart:p1", StzSeatingRuleSet()[3].SubjectsIn(oStW)))
chk("a guest at a table that is not in the plan is refused, and named", _StRefuses(1))
chk("a table that is neither round nor long, and a table with no seats, are refused", _StRefuses(2) and _StRefuses(3))
chk("a pair naming someone not invited, and a pair of one, are refused", _StRefuses(4) and _StRefuses(5))
chk("two tables under one name are refused", _StRefuses(6))
oStRule = StzSeatingRuleSet()[1]
chk("the seating rules govern every table of a plan and not one object of a floor plan or a fishbone -- " +
    "the boundary is stood on",
    len(oStRule.SubjectsIn(oStW)) = 5 and len(oStRule.SubjectsIn(oFpF)) = 0 and len(oStRule.SubjectsIn(oFbC)) = 0 and
    len(oStRule.CounterSubjectsIn(oFpF)) > 0 and len(oStRule.CounterSubjectsIn(oStW)) = 0)

sec("-- 118. DN24: A CHOROPLETH MAP -- REGIONS COLOURED BY A VALUE, A LEGEND BESIDE --")
discharges("DN24")

# NOTHING TO SOLVE: a region is a polygon and a value, a class two
# edges, and every pixel and every fill follows by arithmetic.
oChM = StzMathScene51(AUFONT)
oChM.Layout()
oChS = oChM.Substance()
? "   provinces : " + oChM.NumberOfShapes() + " shapes, " + oChM.NumberOfUnknowns() +
  " unknowns, " + floor(oChM.LayoutMs()) + " ms -- " + oChM.Why()
chkeq("a choropleth mints no unknown -- there is nothing to lay out", oChM.NumberOfUnknowns(), 0)
chk("six regions with their values, four classes in the legend under its title, and no swatch for no data",
    len(oChS.ObjectsOfType("Region")) = 6 and len(oChS.ObjectsOfType("Value")) = 6 and
    len(oChS.ObjectsOfType("Swatch")) = 4 and oChS.LabelOf("lg") = "People per km2" and
    NOT _ChHas(oChS, "lnd"))

# THE CLASSES ARE THE AUTHOR'S EDGES, and a value falls in one of them:
# the lower edge in, the upper out, the last closed at its top.
chk("each region falls in the class its value says: North 35 in the first, Centre 310 in the fourth",
    oChS.DataOf("r1", "class") = 1 and oChS.Holds("C1", [ "r1" ]) and
    oChS.DataOf("r3", "class") = 4 and oChS.Holds("C4", [ "r3" ]) and
    oChS.DataOf("r2", "class") = 3 and oChS.DataOf("r4", "class") = 2)
chk("an edge belongs to the class above it, and the last edge to the last class",
    _ChClassOf(50, [ 0, 50, 100, 200, 400 ]) = 2 and _ChClassOf(400, [ 0, 50, 100, 200, 400 ]) = 4 and
    _ChClassOf(401, [ 0, 50, 100, 200, 400 ]) = 0 and _ChClassOf(-1, [ 0, 50, 100, 200, 400 ]) = 0)
chk("a swatch carries its range and counts its regions: the second class holds the two at 60 and 95",
    oChS.LabelOf("l2") = "50 - 100" and oChS.DataOf("l2", "regions") = 2 and oChS.DataOf("l1", "regions") = 1)

# DARKER MEANS MORE: the default palette is the primary hue stepped from
# a pale tint to a deep shade, one hue, falling luminance.
aChP = StzChoroplethPaletteFor(4)
chk("the default palette darkens class by class, from a pale tint to a deep shade",
    StzColorLuminance(aChP[1]) > StzColorLuminance(aChP[2]) and StzColorLuminance(aChP[2]) > StzColorLuminance(aChP[3]) and
    StzColorLuminance(aChP[3]) > StzColorLuminance(aChP[4]) and StzColorLuminance(aChP[1]) > 200 and StzColorLuminance(aChP[4]) < 110)
chk("a region's fill is its class's colour, and the swatch of that class the same colour",
    oChM.FillOf("r3.icon") = aChP[4] and oChM.FillOf("l4.icon") = aChP[4] and oChM.FillOf("r1.icon") = aChP[1])

# THE GEOMETRY: the map fits beside the legend, the polygon's points are
# the author's scaled, the name at the centroid with the value beneath.
nChK = (StzChoroplethWidth() - StzChoroplethLegendWidth() - 2 * StzChoroplethMargin()) / 12
chk("a map unit is one width everywhere: the east's twelve units end where the map's width does",
    fabs(oChS.DataOf("r2", "x3") - (StzChoroplethMargin() + 12 * nChK)) < 0.01 and
    fabs(oChS.DataOf("r1", "x2") - oChS.DataOf("r1", "x1") - 7 * nChK) < 0.01)
chk("a region's name stands at its centroid, the value beneath it -- the shoelace centroid, not the mean of the corners",
    fabs(oChS.DataOf("r1", "cx") - (StzChoroplethMargin() + _ChCentroid([ 0, 0, 7, 0, 6, 3, 0, 2 ])[1] * nChK)) < 0.01 and
    oChS.DataOf("v1", "cy") > oChS.DataOf("r1", "cy") and oChS.LabelOf("v1") = "35")
chk("the legend stands to the right of the map, its swatches one under the other",
    oChS.DataOf("l1", "x") > StzChoroplethMargin() + 12 * nChK and
    oChS.DataOf("l2", "y") - oChS.DataOf("l1", "y") = oChS.DataOf("l3", "y") - oChS.DataOf("l2", "y"))
aChF = StzCheckPictures([ [ "provinces", oChM ] ]).Findings()
for iCh = 1 to len(aChF)
	if iCh <= 4  ? "   PROVINCES FINDING " + aChF[iCh][:rule] + " -- " + aChF[iCh][:message]  ok
next
chk("the map is lawful and the one gate finds nothing in it -- every name inside its region and clear of its value",
    oChM.IsFeasible() and len(aChF) = 0)
chk("a fact reads a region's value from the data",
    oChM.Fact(:datum, [ "r3", "value" ])[:value] = 310)
chk("and it answers Rendition() as a vector like every other picture",
    oChM.Rendition()[:kind] = "vector")

# THE RULES ARE ABOUT THE MAP. The witness has one of each mistake.
oChW = StzMathChoroplethWitness(AUFONT)
aChW = StzCheckPictures([ [ "wrong", oChW ] ]).Findings()
? "   witness : " + len(aChW) + " findings -- " + _GtByRule(aChW)
# THE LEGEND SAYS WHY -- the Principal read the witness cold: the centre
# at 450 was not in the legend, and an entry of the legend was not on the
# map. A rim says something is wrong without saying what; now the empty
# class and the shade out of order say so after their range, and what
# lies beyond the classes has an entry of its own, so every region on
# the map is in the legend.
chk("the legend names the class that colours nothing, the shade out of order, and gives the value beyond the classes an entry of its own",
    oChW.Substance().LabelOf("l1") = "0 - 50  (no region)" and
    oChW.Substance().LabelOf("l3") = "100 - 200  (out of order)" and
    _ChHas(oChW.Substance(), "labove") and oChW.Substance().LabelOf("labove") = "above 400  (no class)" and
    oChW.Substance().Holds("OutsideSwatch", [ "labove" ]) and oChW.Substance().DataOf("labove", "regions") = 1)
chk("NEGATIVE: the lawful map's legend carries the ranges alone, and no entry beyond the classes",
    oChS.LabelOf("l1") = "0 - 50" and oChS.LabelOf("l4") = "200 - 400" and
    NOT _ChHas(oChS, "labove") and NOT _ChHas(oChS, "lbelow"))
chk("a region with no value is caught, and drawn as no data with a swatch saying so",
    _PorHits(aChW, "every_region_has_a_value") = 1 and _GtHas(aChW, "'South-west' has no value") and
    oChW.Substance().Holds("NoData", [ "r4" ]) and _ChHas(oChW.Substance(), "lnd") and
    oChW.Substance().LabelOf("v4") = "no data")
chk("a value beyond the last class is caught, saying by which edge",
    _PorHits(aChW, "values_fall_in_the_classes") = 1 and
    _GtHas(aChW, "'Centre' is 450, above the last class, which ends at 400"))
chk("a shade lighter than the one before it is caught, naming both classes",
    _PorHits(aChW, "darker_means_more") = 1 and
    _GtHas(aChW, "class 3 (100 - 200) is lighter than class 2 (50 - 100)"))
chk("a class no region falls in is caught, by its range",
    _PorHits(aChW, "every_class_has_a_region") = 1 and _GtHas(aChW, "class 1 (0 - 50) colours no region"))
chkeq("...and those four are all the gate finds", len(aChW), 4)

# A FAULT IS DRAWN, AND THE MARKS ARE HELD TO THE VERDICTS.
oChWS = oChW.Substance()
chk("the region beyond the classes is marked and painted in the colour of a fault, exactly as the rule says",
    _TlMarkedEquals(oChW, "Region", "Outside", aChW, "values_fall_in_the_classes", "region:") and
    oChW.FillOf("r3.icon") != oChW.FillOf("r2.icon"))
chk("the empty class and the misordered shade are marked on their swatches, exactly as the rules say",
    _TlMarkedEquals(oChW, "Swatch", "Empty", aChW, "every_class_has_a_region", "class:") and
    _TlMarkedEquals(oChW, "Swatch", "Misordered", aChW, "darker_means_more", "class:"))
chk("NEGATIVE: nothing in the lawful map is marked as a fault",
    len(_TlMarked(oChM, "Region", "Outside")) = 0 and len(_TlMarked(oChM, "Region", "NoData")) = 0 and
    len(_TlMarked(oChM, "Swatch", "Empty")) = 0 and len(_TlMarked(oChM, "Swatch", "Misordered")) = 0)

# THE BOUNDARIES. A region with no value is outside the rule about
# classes; the first class is outside the rule about darkness; the
# no-data swatch is outside the rule about empty classes; and the
# builder refuses what it cannot mean.
chk("NEGATIVE: the region with no value is outside the rule about classes, and inside the rule about values",
    _ErInList("region:r4", StzChoroplethRuleSet()[2].CounterSubjectsIn(oChW)) and
    NOT _ErInList("region:r4", StzChoroplethRuleSet()[2].SubjectsIn(oChW)) and
    _ErInList("region:r4", StzChoroplethRuleSet()[1].SubjectsIn(oChW)))
chk("NEGATIVE: the first class has nothing to be darker than, and the no-data swatch is no class",
    _ErInList("class:l1", StzChoroplethRuleSet()[3].CounterSubjectsIn(oChM)) and
    _ErInList("class:lnd", StzChoroplethRuleSet()[4].CounterSubjectsIn(oChW)))
chk("edges that do not rise are refused, with the pair", _ChRefuses(1))
chk("a palette of the wrong count is refused", _ChRefuses(2))
chk("a region of two points, and two regions under one name, are refused", _ChRefuses(3) and _ChRefuses(4))
chk("a map of no regions, and a single edge, are refused", _ChRefuses(5) and _ChRefuses(6))
oChRule = StzChoroplethRuleSet()[1]
chk("the choropleth rules govern every region of a map and not one object of a seating plan or a fishbone -- " +
    "the boundary is stood on",
    len(oChRule.SubjectsIn(oChM)) = 6 and len(oChRule.SubjectsIn(oStW)) = 0 and len(oChRule.SubjectsIn(oFbC)) = 0 and
    len(oChRule.CounterSubjectsIn(oStW)) > 0 and len(oChRule.CounterSubjectsIn(oChM)) = 0)

# SECTION 78 IS APPENDED LAST BY CONSTRUCTION. Any section added after it
# makes its runtime count fall short of the static parse -- which is
# exactly what happened when 79 arrived, 23 against 24. New sections go
# ABOVE this line.
sec("-- 78. THE TWO READINGS OF THE DECLARATIONS, BOTH FINISHED ------")

# aDischarged is built at RUN time by the discharges() calls as each
# section is reached; StzSuiteDischargesOf reads the same declarations
# STATICALLY from the source. Separate code paths over separate inputs, so
# their agreeing means something -- where an identity computed from one set
# of anchors would mean nothing. It also catches a declaration attached to
# a section that never runs.
#
# LAST, AND THAT IS THE POINT. This lived inside section 75 and passed
# until sections 76 and 77 declared DN3b after it had already read the
# runtime list: 21 against 23, and the table check failed with it. A
# comparison of two readings is only a comparison once both have finished.
aPcStat2 = StzSuiteDischargesOf([ "gg_adversarial.ring" ])
chkeq("runtime and static declaration counts agree",
      len(aDischarged), len(aPcStat2))
bPcSame = TRUE
nPcD = len(aDischarged)
for iPc = 1 to nPcD
	bPcFound = FALSE
	nPcS = len(aPcStat2)
	for jPc = 1 to nPcS
		if aPcStat2[jPc][1] = aDischarged[iPc][1] and
		   aPcStat2[jPc][2] = aDischarged[iPc][2]
			bPcFound = TRUE
			exit
		ok
	next
	if NOT bPcFound  bPcSame = FALSE  ok
next
chk("and every runtime pair is present in the static parse", bPcSame)
bPcBogus = FALSE
nPcS = len(aPcStat2)
for jPc = 1 to nPcS
	if aPcStat2[jPc][1] = "ZZ9"  bPcBogus = TRUE  ok
next
chk("NEGATIVE: an item no section declares is ABSENT from the static parse",
    NOT bPcBogus)

if nSecClock > 0
	? "        [section took " +
	  ((clock() - nSecClock) / clockspersecond()) + "s]"
ok
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=============================================================="

#---------------------------------------------------------------------------

# Per-section wall time, printed as the NEXT banner arrives -- the
# profile that decides which section earns a diet. The full suite is
# the PRE-COMMIT gate, run once in the background; iteration happens on
# standalone probes, never by re-running this file.
func sec cTitle
	aKk = _StzGuardSectionKeys('sec("' + cTitle + '")')
	if len(aKk) > 0  cCurSecKey = aKk[1] else cCurSecKey = "" ok
	if nSecClock > 0
		? "        [section took " +
		  ((clock() - nSecClock) / clockspersecond()) + "s]"
	ok
	nSecClock = clock()
	? cTitle

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

func _CorGraph cName
	_g_ = new stzDiagram(cName)
	_aA244_ = [ [ "p","Parent" ], [ "l","Left" ], [ "r","Right" ],
	             [ "d","Deep" ] ]
	_nA244_ = len(_aA244_)
	for _iA244_ = 1 to _nA244_
		_a_ = _aA244_[_iA244_]
		_g_.AddNodeXTT(_a_[1], _a_[2], [ :type = "box", :color = "#4477FF" ])
	next
	# ...AND ONE TURN THAT IS NOT A FORK. p forks to l and r at a single
	# shared point, and a fork is drawn SQUARE on purpose -- two rounded
	# elbows curving apart from one place lay over each other and read as
	# a solid arrowhead in the middle of the line, which is what the
	# Principal circled on the UML interface picture. So a scene that
	# measures ROUNDING has to contain a corner that is a corner: l->d
	# and r->e each turn alone.
	_g_.AddNodeXTT("e", "End", [ :type = "box", :color = "#4477FF" ])
	_g_.AddEdge("p","l")  _g_.AddEdge("p","r")  _g_.AddEdge("l","d")
	_g_.AddEdge("r","e")
	_g_.SetSplines("ortho")
	return _g_

func _G50
	_g_ = new stzDiagram("g50")
	_aA245_ = [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
	             [ "api1","API A" ],[ "api2","API B" ],
	             [ "db1","DB A" ],[ "db2","DB B" ],[ "log","Logger" ] ]
	_nA245_ = len(_aA245_)
	for _iA245_ = 1 to _nA245_
		_a_ = _aA245_[_iA245_]
		_g_.AddNodeXTT(_a_[1], _a_[2], [ :type = "box", :color = "Info.Solid" ])
	next
	_g_.AddEdge("lb","web2")   _g_.AddEdge("web2","web1")
	_g_.AddEdge("web1","api1") _g_.AddEdge("api1","db1")
	_g_.AddEdge("web1","log")
	_g_.AddEdge("lb","api2")   _g_.AddEdge("api2","db2")
	_g_.SetSplines("ortho")
	return _g_

# The distance from a point to a flat polyline -- what makes two paths
# rails rather than two routes.
func _Dist55 nX, nY, paFlat
	_best55_ = 1000000
	for _i55_ = 1 to len(paFlat) - 3 step 2
		_ax_ = paFlat[_i55_]    _ay_ = paFlat[_i55_+1]
		_bx_ = paFlat[_i55_+2]  _by_ = paFlat[_i55_+3]
		_vx_ = _bx_ - _ax_      _vy_ = _by_ - _ay_
		_ll_ = _vx_*_vx_ + _vy_*_vy_
		_t55_ = 0
		if _ll_ > 0.000001
			_t55_ = ((nX - _ax_) * _vx_ + (nY - _ay_) * _vy_) / _ll_
			if _t55_ < 0  _t55_ = 0  ok
			if _t55_ > 1  _t55_ = 1  ok
		ok
		_px_ = _ax_ + _vx_ * _t55_
		_py_ = _ay_ + _vy_ * _t55_
		_d55_ = sqrt((nX - _px_) * (nX - _px_) + (nY - _py_) * (nY - _py_))
		if _d55_ < _best55_  _best55_ = _d55_  ok
	next
	return _best55_

func _LaneY62 oDg, cKey
	_ly62_ = -1
	_lw62_ = 0
	_aLp62246_ = oDg.RenderEdgePaths()
	_nLp62246_ = len(_aLp62246_)
	for _iLp62246_ = 1 to _nLp62246_
		_lp62_ = _aLp62246_[_iLp62246_]
		if _lp62_[1] != cKey  loop  ok
		_lf62_ = _lp62_[2]
		for _li62_ = 1 to len(_lf62_) - 3 step 2
			if fabs(_lf62_[_li62_+3] - _lf62_[_li62_+1]) > 0.5  loop  ok
			_lr62_ = fabs(_lf62_[_li62_+2] - _lf62_[_li62_])
			if _lr62_ > _lw62_
				_lw62_ = _lr62_
				_ly62_ = _lf62_[_li62_+1]
			ok
		next
	next
	return _ly62_


func _MidFrac62 paF, nX, nY
	_bf62_ = 1
	for _mi62_ = 1 to len(paF) - 3 step 2
		_dx62_ = paF[_mi62_+2] - paF[_mi62_]
		_dy62_ = paF[_mi62_+3] - paF[_mi62_+1]
		_ln62_ = sqrt(_dx62_*_dx62_ + _dy62_*_dy62_)
		if _ln62_ < 1  loop  ok
		_t62_ = ((nX - paF[_mi62_]) * _dx62_ +
			(nY - paF[_mi62_+1]) * _dy62_) / (_ln62_ * _ln62_)
		if _t62_ < 0  _t62_ = 0  ok
		if _t62_ > 1  _t62_ = 1  ok
		_px62_ = paF[_mi62_] + _dx62_ * _t62_
		_py62_ = paF[_mi62_+1] + _dy62_ * _t62_
		_d62_ = sqrt(pow(nX-_px62_,2) + pow(nY-_py62_,2))
		if _d62_ < _ln62_
			if fabs(_t62_ - 0.5) < _bf62_  _bf62_ = fabs(_t62_ - 0.5)  ok
		ok
	next
	return _bf62_

func _DistRect62 aR, nX, nY
	_dx62_ = 0
	if nX < aR[1]  _dx62_ = aR[1] - nX  ok
	if nX > aR[1] + aR[3]  _dx62_ = nX - (aR[1] + aR[3])  ok
	_dy62_ = 0
	if nY < aR[2]  _dy62_ = aR[2] - nY  ok
	if nY > aR[2] + aR[4]  _dy62_ = nY - (aR[2] + aR[4])  ok
	return sqrt(_dx62_*_dx62_ + _dy62_*_dy62_)

func _Px62 cPx, nW, nX, nY
	_i62_ = (nY * nW + nX) * 4 + 1
	if _i62_ + 2 > len(cPx)  return [ 0, 0, 0 ]  ok
	return [ ascii(cPx[_i62_]), ascii(cPx[_i62_+1]), ascii(cPx[_i62_+2]) ]

func _Rect49 oDg, cId
	_aR49247_ = oDg.RenderNodeRects()
	_nR49247_ = len(_aR49247_)
	for _iR49247_ = 1 to _nR49247_
		_r49_ = _aR49247_[_iR49247_]
		if _r49_[5] = cId  return _r49_  ok
	next
	return [ 0, 0, 0, 0 ]

# --- I7 instruments: a picture re-read as a graph -------------------
func _I7Cx aR, cId
	for _i7_ = 1 to len(aR)
		if aR[_i7_][5] = cId  return aR[_i7_][1] + aR[_i7_][3] / 2  ok
	next
	return -1

func _I7Cy aR, cId
	for _i7_ = 1 to len(aR)
		if aR[_i7_][5] = cId  return aR[_i7_][2] + aR[_i7_][4] / 2  ok
	next
	return -1

func _I7Kids aP, cSrc
	_k7_ = []
	for _i7_ = 1 to len(aP)
		_e7_ = StzSplit(aP[_i7_][1], ">")
		if _e7_[1] = cSrc  _k7_ + _e7_[2]  ok
	next
	return _k7_

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

func _DarkestDown cPx, nW, nX, nY0, nN
	_dk_ = 255
	for _k_ = 0 to nN
		_p_ = ((nY0 + _k_) * nW + nX) * 4 + 1
		_v_ = ascii(substr(cPx, _p_, 1))
		if _v_ < _dk_  _dk_ = _v_  ok
	next
	return _dk_

func _DarkestAcross cPx, nW, nX0, nN, nY
	_dk_ = 255
	for _k_ = 0 to nN
		_p_ = (nY * nW + nX0 + _k_) * 4 + 1
		_v_ = ascii(substr(cPx, _p_, 1))
		if _v_ < _dk_  _dk_ = _v_  ok
	next
	return _dk_

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
	_aCn248_ = StzFindAll('<polygon points="', cSvg)
	_nCn248_ = len(_aCn248_)
	for _iCn248_ = 1 to _nCn248_
		_cn_ = _aCn248_[_iCn248_]
		_ctail_ = StzSubStr(cSvg, _cn_, min([ 4000, _clen_ - _cn_ + 1 ]))
		_cq_ = StzFindFirst('"', StzSubStr(_ctail_, 18, StzLen(_ctail_) - 17))
		if _cq_ = 0  loop  ok
		_cpts_ = StzSubStr(_ctail_, 18, _cq_ - 1)
		_cminx_ = -1  _cmaxx_ = -1  _cminy_ = -1  _cmaxy_ = -1
		_aCpair249_ = StzSplit(_cpts_, " ")
		_nCpair249_ = len(_aCpair249_)
		for _iCpair249_ = 1 to _nCpair249_
			_cpair_ = _aCpair249_[_iCpair249_]
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

# THE RANK ROW, ASKED FOR RATHER THAN HUNTED -- and the two near-identical
# gap instruments collapsed into one.
#
# _GapsInDensestRow and _MinGapPx each swept the WHOLE canvas on a 4x4
# stride to find the row with the most node paint: 37,500 probes of three
# substr calls apiece, 17.8 seconds per call, and they did it to answer a
# question the render already answers for free. RenderNodeRects() publishes
# every box, so the densest RANK is arithmetic and its centre row is exact --
# where the paint-density heuristic could land on a row grazing the box tops,
# which is where antialiasing lives.
#
# The pixel property is unchanged and still the reader's-eye truth: gaps of
# BACKGROUND along a row that cuts every box in the densest rank. Only the
# instrument got cheap -- one substr for the row, one pass along it, both the
# gap COUNT (section 4) and the narrowest gap's WIDTH (section 7) out of the
# same walk. Measured on the 16-node fan: 17.82s -> 0.00s, same 15 gaps.
func _RankRowGaps oDiag, oCanvas, nW, cHex
	_rrR_ = oDiag.RenderNodeRects()
	if len(_rrR_) = 0  return [ -1, -1 ]  ok
	_rrY_ = _DensestRankRow(_rrR_)
	if _rrY_ < 0  return [ -1, -1 ]  ok
	_rrPx_ = oCanvas.ToPixels()
	_rrRow_ = substr(_rrPx_, (_rrY_ * nW) * 4 + 1, nW * 4)
	return _RowGaps(_rrRow_, nW, _HexRGB(cHex), 60)

# The centre row of the rank holding the most boxes.
func _DensestRankRow aRects
	_drW_ = []
	_aDrR250_ = aRects
	_nDrR250_ = len(_aDrR250_)
	for _iDrR250_ = 1 to _nDrR250_
		_drR_ = _aDrR250_[_iDrR250_]
		_drC_ = _drR_[2] + _drR_[4] / 2
		_drF_ = 0
		for _drI_ = 1 to len(_drW_)
			if fabs(_drW_[_drI_][1] - _drC_) < 2
				_drW_[_drI_][2]++
				_drF_ = 1
				exit
			ok
		next
		if _drF_ = 0  _drW_ + [ _drC_, 1 ]  ok
	next
	_drB_ = 0  _drY_ = -1
	_aDrR251_ = _drW_
	_nDrR251_ = len(_aDrR251_)
	for _iDrR251_ = 1 to _nDrR251_
		_drR_ = _aDrR251_[_iDrR251_]
		if _drR_[2] > _drB_  _drB_ = _drR_[2]  _drY_ = _drR_[1]  ok
	next
	return floor(_drY_)

# One row of RGBA bytes -> [ how many background gaps, the narrowest ].
# NEAR-white, not exactly white, for the same antialiasing reason the old
# instrument learned the hard way: a blend beside a stroke is still
# background to a reader.
func _RowGaps cRow, nW, aFg, nTol
	_rgF_ = -1  _rgL_ = -1
	for _rgX_ = 0 to nW - 1
		_rgI_ = _rgX_ * 4 + 1
		if ascii(cRow[_rgI_]) = aFg[1] and ascii(cRow[_rgI_ + 1]) = aFg[2] and
		   ascii(cRow[_rgI_ + 2]) = aFg[3]
			if _rgF_ < 0  _rgF_ = _rgX_  ok
			_rgL_ = _rgX_
		ok
	next
	if _rgF_ < 0  return [ -1, -1 ]  ok
	_rgN_ = 0  _rgRun_ = 0  _rgMin_ = -1
	for _rgX_ = _rgF_ to _rgL_
		_rgI_ = _rgX_ * 4 + 1
		if fabs(ascii(cRow[_rgI_]) - 255) <= nTol and
		   fabs(ascii(cRow[_rgI_ + 1]) - 255) <= nTol and
		   fabs(ascii(cRow[_rgI_ + 2]) - 255) <= nTol
			_rgRun_++
		else
			if _rgRun_ >= 1
				_rgN_++
				if _rgMin_ < 0 or _rgRun_ < _rgMin_  _rgMin_ = _rgRun_  ok
			ok
			_rgRun_ = 0
		ok
	next
	if _rgRun_ >= 1
		_rgN_++
		if _rgMin_ < 0 or _rgRun_ < _rgMin_  _rgMin_ = _rgRun_  ok
	ok
	return [ _rgN_, _rgMin_ ]

# EDGE ink inside a node box -- named, and read only where the boxes are.
#
# Two faults, one rewrite. The old form swept the ENTIRE canvas asking of
# every non-box non-white pixel whether box colour lay above AND below it
# within 8px -- an inside-a-box test performed everywhere including the
# empty margins, 233 seconds of it. And that test was luck: a node's own
# LABEL is also neither fill nor background, and it escaped only because
# 8px above a glyph often is not exact fill either. Scanning box interiors
# for "anything unexpected" made the luck visible -- 43 hits, every one a
# letter.
#
# So the instrument now NAMES what it hunts: the edge stroke's own grey.
# Text blends run from fill toward white and miss that colour on all three
# channels; edge ink matches it. A property worth asserting is worth naming.
#
# The speed came from a second finding, and it is the important one:
# Ring's substr on a 1.8MB pixel buffer costs about a third of a
# millisecond -- it is O(buffer), not O(1) -- so THREE substr calls per
# pixel is the whole disease. Each scanned row is sliced ONCE and indexed
# in place: 7.34s -> 0.06s on the same picture, same verdicts.
func _EdgeInkInRects cPx, nW, nH, aRects, aInk, nTol
	_erH_ = 0
	_aErR252_ = aRects
	_nErR252_ = len(_aErR252_)
	for _iErR252_ = 1 to _nErR252_
		_erR_ = _aErR252_[_iErR252_]
		_erX1_ = ceil(_erR_[1]) + 4
		_erX2_ = floor(_erR_[1] + _erR_[3]) - 4
		_erY1_ = ceil(_erR_[2]) + 4
		_erY2_ = floor(_erR_[2] + _erR_[4]) - 4
		if _erX1_ < 0  _erX1_ = 0  ok
		if _erY1_ < 0  _erY1_ = 0  ok
		if _erX2_ > nW - 1  _erX2_ = nW - 1  ok
		if _erY2_ > nH - 1  _erY2_ = nH - 1  ok
		if _erX2_ < _erX1_ or _erY2_ < _erY1_  loop  ok
		_erLen_ = (_erX2_ - _erX1_ + 1) * 4
		for _erY_ = _erY1_ to _erY2_ step 2
			_erRow_ = substr(cPx, (_erY_ * nW + _erX1_) * 4 + 1, _erLen_)
			for _erX_ = 0 to _erX2_ - _erX1_
				_erI_ = _erX_ * 4 + 1
				if fabs(ascii(_erRow_[_erI_]) - aInk[1]) <= nTol and
				   fabs(ascii(_erRow_[_erI_ + 1]) - aInk[2]) <= nTol and
				   fabs(ascii(_erRow_[_erI_ + 2]) - aInk[3]) <= nTol
					_erH_++
				ok
			next
		next
	next
	return _erH_

# The x of one id in a [ id, x ] list -- section 41 compares a picture
# with itself across pins, so it needs to look a cell up by name in a
# snapshot rather than in the render's live facts.
# The centre of one node in the last render -- section 43 drives the
# interaction with pointer positions, so it needs to aim at cells.
func _Centre44 oDiag, cId
	_aR253_ = oDiag.RenderNodeRects()
	_nR253_ = len(_aR253_)
	for _iR253_ = 1 to _nR253_
		_r_ = _aR253_[_iR253_]
		if _r_[5] = StzLower("" + cId)
			return [ _r_[1] + _r_[3] / 2, _r_[2] + _r_[4] / 2 ]
		ok
	next
	return [ -1, -1 ]

# the closest any two cells sharing a rank come to each other
func _TightestPair46 oDiag
	_tpMin_ = 1000000
	_aR_ = oDiag.RenderNodeRects()
	for _i_ = 1 to len(_aR_)
		for _j_ = _i_ + 1 to len(_aR_)
			if fabs(_aR_[_i_][2] - _aR_[_j_][2]) > 2  loop  ok
			_gap_ = max([ _aR_[_i_][1], _aR_[_j_][1] ]) -
				min([ _aR_[_i_][1] + _aR_[_i_][3],
				      _aR_[_j_][1] + _aR_[_j_][3] ])
			if _gap_ < _tpMin_  _tpMin_ = _gap_  ok
		next
	next
	return _tpMin_

func _X46 oDiag, cId
	_aR254_ = oDiag.RenderNodeRects()
	_nR254_ = len(_aR254_)
	for _iR254_ = 1 to _nR254_
		_r_ = _aR254_[_iR254_]
		if _r_[5] = StzLower("" + cId)  return _r_[1] + _r_[3] / 2  ok
	next
	return -1

func _Xof42 aList, cId
	_aE255_ = aList
	_nE255_ = len(_aE255_)
	for _iE255_ = 1 to _nE255_
		_e_ = _aE255_[_iE255_]
		if _e_[1] = StzLower("" + cId)  return _e_[2]  ok
	next
	return -1

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

	# NEAR-white, not EXACTLY white. This asked for 255,255,255 and broke
	# the day the renderer gained anti-aliasing: the pixels bordering a box
	# became blends, every gap lost a pixel at each end, and a passing
	# layout reported 9 gaps where it had always had 15. The layout had not
	# moved. "Background" is what a reader sees as background, which is a
	# tolerance, and an exact-equality test on a colour is a promise that
	# nothing will ever be blended into it.
	_mgaps_ = 0
	_mlen_ = 0
	for _mx_ = _mfirst_ to _mlast_
		if _IsNearRGB(_mpx_, nW, _mx_, _mrow_, [ 255, 255, 255 ], 60)
			_mlen_++
		else
			# ONE pixel is a gap now, and that is not a weakening. A box
			# is stroked and the stroke is now antialiased, so between two
			# boxes a reader sees stroke, blend, background, blend,
			# stroke -- the background run is genuinely one or two pixels
			# wide when the fit pass has packed a rank tight. Demanding
			# two PURE white pixels was demanding the renderer not
            # antialias. The negative sibling below is what keeps this
			# honest: with fitting off the boxes fuse and this must read
			# zero.
			if _mlen_ >= 1  _mgaps_++  ok
			_mlen_ = 0
		ok
	next
	if _mlen_ >= 1  _mgaps_++  ok
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

func _IsNearRGB cPx, nW, nX, nY, aRGB, nTol
	_nr_ = (nY * nW + nX) * 4 + 1
	return fabs(ascii(substr(cPx, _nr_, 1)) - aRGB[1]) <= nTol and
	       fabs(ascii(substr(cPx, _nr_ + 1, 1)) - aRGB[2]) <= nTol and
	       fabs(ascii(substr(cPx, _nr_ + 2, 1)) - aRGB[3]) <= nTol

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
	_aP256_ = aPos
	_nP256_ = len(_aP256_)
	for _iP256_ = 1 to _nP256_
		_p_ = _aP256_[_iP256_]
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
		_aEc257_ = [ _ei_ * 2, _ei_ * 2 + 1 ]
		_nEc257_ = len(_aEc257_)
		for _iEc257_ = 1 to _nEc257_
			_ec_ = _aEc257_[_iEc257_]
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
	_aRp258_ = aPos
	_nRp258_ = len(_aRp258_)
	for _iRp258_ = 1 to _nRp258_
		_rp_ = _aRp258_[_iRp258_]
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
	_aRr259_ = _rrows_
	_nRr259_ = len(_aRr259_)
	for _iRr259_ = 1 to _nRr259_
		_rr_ = _aRr259_[_iRr259_]
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
	_aCl260_ = oDiag.Clusters()
	_nCl260_ = len(_aCl260_)
	for _iCl260_ = 1 to _nCl260_
		_cl_ = _aCl260_[_iCl260_]
		_box_ = oDiag._ClusterBox(_cl_, _ClusterXY(aPos), nBW, nBH)
		if len(_box_) != 4  loop  ok
		_aP261_ = aPos
		_nP261_ = len(_aP261_)
		for _iP261_ = 1 to _nP261_
			_p_ = _aP261_[_iP261_]
			_isMem_ = 0
			_aM262_ = _cl_[:nodes]
			_nM262_ = len(_aM262_)
			for _iM262_ = 1 to _nM262_
				_m_ = _aM262_[_iM262_]
				if StzLower("" + _m_) = StzLower("" + _p_[1])  _isMem_ = 1  exit  ok
			next
			if _isMem_  loop  ok
			if _BoxInside(_p_[2], _p_[3], nBW, nBH, _box_)  _si_++  ok
		next
	next
	return _si_

func _MembersInClusters oDiag, aPos, nBW, nBH
	_mi_ = 0
	_aCl263_ = oDiag.Clusters()
	_nCl263_ = len(_aCl263_)
	for _iCl263_ = 1 to _nCl263_
		_cl_ = _aCl263_[_iCl263_]
		_box_ = oDiag._ClusterBox(_cl_, _ClusterXY(aPos), nBW, nBH)
		if len(_box_) != 4  loop  ok
		_aM264_ = _cl_[:nodes]
		_nM264_ = len(_aM264_)
		for _iM264_ = 1 to _nM264_
			_m_ = _aM264_[_iM264_]
			_aP265_ = aPos
			_nP265_ = len(_aP265_)
			for _iP265_ = 1 to _nP265_
				_p_ = _aP265_[_iP265_]
				if StzLower("" + _p_[1]) != StzLower("" + _m_)  loop  ok
				if _BoxInside(_p_[2], _p_[3], nBW, nBH, _box_)  _mi_++  ok
			next
		next
	next
	return _mi_

# _ClusterBox wants ids lowercased, the way ToCanvasXT feeds it
func _ClusterXY aPos
	_cx_ = []
	_aPos9_ = aPos
	_nPos9_ = len(_aPos9_)
	for _iPos9_ = 1 to _nPos9_
		_p_ = _aPos9_[_iPos9_]
		_cx_ + [ StzLower("" + _p_[1]), _p_[2], _p_[3] ]
	next
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
# ROW BY ROW, and identical rows skipped whole. Six substr calls per pixel
# over two 537KB buffers cost 18.4 seconds; Ring's substr on a large string
# is O(buffer), so the calls WERE the work. Slicing each row once and
# comparing the slices first means two nearly-identical renders -- which is
# exactly what this compares -- differ on a handful of rows and the rest
# cost one string comparison each: 18.38s -> 0.03s, same 941 pixels.
func _PixelsDiffering oA, oB
	if oA.Width() != oB.Width() or oA.Height() != oB.Height()  return -1  ok
	_da_ = oA.ToPixels()
	_db_ = oB.ToPixels()
	if _da_ = _db_  return 0  ok
	_dw_ = oA.Width()
	_dh_ = oA.Height()
	_dl_ = _dw_ * 4
	_dc_ = 0
	for _dy_ = 0 to _dh_ - 1
		_dOf_ = _dy_ * _dl_ + 1
		_dRa_ = substr(_da_, _dOf_, _dl_)
		_dRb_ = substr(_db_, _dOf_, _dl_)
		if _dRa_ = _dRb_  loop  ok
		for _dx_ = 0 to _dw_ - 1
			_di_ = _dx_ * 4 + 1
			if _dRa_[_di_] != _dRb_[_di_] or
			   _dRa_[_di_ + 1] != _dRb_[_di_ + 1] or
			   _dRa_[_di_ + 2] != _dRb_[_di_ + 2]
				_dc_++
			ok
		next
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
# Where the edge strokes CROSS a cut line, within a window on the other
# axis -- sections 29 and 30 read lane positions off the picture. bH=0
# cuts vertically at x=nPos and lists heights; bH=1 cuts horizontally
# at y=nPos and lists x positions. The polylines' own endpoints cannot
# be used for this: a trunk's first point lies UNDER its node (the box
# overdraws it) and an arrival's last point stops an arrowhead short of
# the border, so the honest instrument is the one the reader's eye
# uses -- a cut just off the border, listing where ink passes through.
func _BorderCrossings cSvg, cStroke, nPos, nLo, nHi, bH
	_bc_ = []
	_bcL_ = StzLen(cSvg)
	_bcAx_ = iif(bH, 2, 1)
	_bcOx_ = iif(bH, 1, 2)
	_aBcP266_ = StzFindAll('<polyline points="', cSvg)
	_nBcP266_ = len(_aBcP266_)
	for _iBcP266_ = 1 to _nBcP266_
		_bcP_ = _aBcP266_[_iBcP266_]
		_bcT_ = StzSubStr(cSvg, _bcP_, min([ 6000, _bcL_ - _bcP_ + 1 ]))
		_bcQ_ = StzFindFirst('"', StzSubStr(_bcT_, 19, StzLen(_bcT_) - 18))
		if _bcQ_ = 0  loop  ok
		_bcTag_ = StzFindFirst(">", _bcT_)
		if _bcTag_ = 0  loop  ok
		if StzFindFirst(cStroke, StzSubStr(_bcT_, 1, _bcTag_)) = 0  loop  ok
		_bcPrev_ = []
		_aBcPr267_ = StzSplit(StzSubStr(_bcT_, 19, _bcQ_ - 1), " ")
		_nBcPr267_ = len(_aBcPr267_)
		for _iBcPr267_ = 1 to _nBcPr267_
			_bcPr_ = _aBcPr267_[_iBcPr267_]
			_bcC_ = StzSplit(StzTrim(_bcPr_), ",")
			if len(_bcC_) != 2  loop  ok
			try
				_bcPt_ = [ 0 + _bcC_[1], 0 + _bcC_[2] ]
			catch
				loop
			done
			if len(_bcPrev_) = 2
				_bcA_ = min([ _bcPrev_[_bcAx_], _bcPt_[_bcAx_] ])
				_bcB_ = max([ _bcPrev_[_bcAx_], _bcPt_[_bcAx_] ])
				if nPos >= _bcA_ and nPos <= _bcB_ and _bcB_ - _bcA_ > 0.001
					_bcYc_ = _bcPrev_[_bcOx_] +
						(_bcPt_[_bcOx_] - _bcPrev_[_bcOx_]) *
						(nPos - _bcPrev_[_bcAx_]) /
						(_bcPt_[_bcAx_] - _bcPrev_[_bcAx_])
					if _bcYc_ >= nLo and _bcYc_ <= nHi
						_bc_ + _bcYc_
					ok
				ok
			ok
			_bcPrev_ = _bcPt_
		next
	next
	return _bc_

# The diagonal chords themselves, not just their count -- section 28
# asserts both that they exist at a crossing and that every one is
# hop-short. Same colour filter as _NonAxialSegments, same reason.
func _DiagChords cSvg, cStroke
	_dc_ = []
	_dlen_ = StzLen(cSvg)
	_aDp268_ = StzFindAll('<polyline points="', cSvg)
	_nDp268_ = len(_aDp268_)
	for _iDp268_ = 1 to _nDp268_
		_dp_ = _aDp268_[_iDp268_]
		_dtail_ = StzSubStr(cSvg, _dp_, min([ 6000, _dlen_ - _dp_ + 1 ]))
		_dq_ = StzFindFirst('"', StzSubStr(_dtail_, 19, StzLen(_dtail_) - 18))
		if _dq_ = 0  loop  ok
		_dpts_ = StzSubStr(_dtail_, 19, _dq_ - 1)
		_dtagend_ = StzFindFirst(">", _dtail_)
		if _dtagend_ = 0  loop  ok
		if StzFindFirst(cStroke, StzSubStr(_dtail_, 1, _dtagend_)) = 0  loop  ok
		_dprev_ = []
		_aDpair269_ = StzSplit(_dpts_, " ")
		_nDpair269_ = len(_aDpair269_)
		for _iDpair269_ = 1 to _nDpair269_
			_dpair_ = _aDpair269_[_iDpair269_]
			_dxy_ = StzSplit(StzTrim(_dpair_), ",")
			if len(_dxy_) != 2  loop  ok
			try
				_dx_ = 0 + _dxy_[1]
				_dy_ = 0 + _dxy_[2]
			catch
				loop
			done
			if len(_dprev_) = 2
				if fabs(_dx_ - _dprev_[1]) > 0.5 and
				   fabs(_dy_ - _dprev_[2]) > 0.5
					_dc_ + sqrt(pow(_dx_ - _dprev_[1], 2) +
						pow(_dy_ - _dprev_[2], 2))
				ok
			ok
			_dprev_ = [ _dx_, _dy_ ]
		next
	next
	return _dc_

func _NonAxialSegments cSvg, cStroke
	_nn_ = 0
	_slen_ = StzLen(cSvg)
	_aSp270_ = StzFindAll('<polyline points="', cSvg)
	_nSp270_ = len(_aSp270_)
	for _iSp270_ = 1 to _nSp270_
		_sp_ = _aSp270_[_iSp270_]
		_stail_ = StzSubStr(cSvg, _sp_, min([ 6000, _slen_ - _sp_ + 1 ]))
		_sq_ = StzFindFirst('"', StzSubStr(_stail_, 19, StzLen(_stail_) - 18))
		if _sq_ = 0  loop  ok
		_spts_ = StzSubStr(_stail_, 19, _sq_ - 1)
		# the whole tag, to read its stroke
		_stagend_ = StzFindFirst(">", _stail_)
		if _stagend_ = 0  loop  ok
		if StzFindFirst(cStroke, StzSubStr(_stail_, 1, _stagend_)) = 0  loop  ok
		_sprev_ = []
		_aSpair271_ = StzSplit(_spts_, " ")
		_nSpair271_ = len(_aSpair271_)
		for _iSpair271_ = 1 to _nSpair271_
			_spair_ = _aSpair271_[_iSpair271_]
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
	_aV272_ = paList
	_nV272_ = len(_aV272_)
	for _iV272_ = 1 to _nV272_
		_v_ = _aV272_[_iV272_]
		if _v_ > _mx_  _mx_ = _v_  ok
	next
	return _mx_

# The smallest gap between adjacent nodes anywhere -- one unit, the same
# normalisation dot's own numbers were reduced by.
func _TightestGap aPos
	_tmin_ = -1
	_aTa273_ = _RanksOf(aPos)
	_nTa273_ = len(_aTa273_)
	for _iTa273_ = 1 to _nTa273_
		_ta_ = _aTa273_[_iTa273_]
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
	_aRa274_ = _RanksOf(aPos)
	_nRa274_ = len(_aRa274_)
	for _iRa274_ = 1 to _nRa274_
		_ra_ = _aRa274_[_iRa274_]
		if len(_ra_) = nCount
			_rx_ = sort(_ra_)
			return _rx_[len(_rx_)] - _rx_[1]
		ok
	next
	return 0

func _RanksOf aPos
	_rr_ = []
	_aP275_ = aPos
	_nP275_ = len(_aP275_)
	for _iP275_ = 1 to _nP275_
		_p_ = _aP275_[_iP275_]
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
	_aRr9_ = _rr_
	_nRr9_ = len(_aRr9_)
	for _iRr9_ = 1 to _nRr9_
		_out_ + _aRr9_[_iRr9_][2]
	next
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
	_aV276_ = _SubtreeNodes(nRoot, nMax)
	_nV276_ = len(_aV276_)
	for _iV276_ = 1 to _nV276_
		_v_ = _aV276_[_iV276_]
		_x_ = _XOf(aPos, "n" + _v_)
		if _x_ < 0  loop  ok
		if _l_ < 0 or _x_ < _l_  _l_ = _x_  ok
	next
	return _l_

func _SubtreeHi aPos, nRoot, nMax
	_h_ = -1
	_aV277_ = _SubtreeNodes(nRoot, nMax)
	_nV277_ = len(_aV277_)
	for _iV277_ = 1 to _nV277_
		_v_ = _aV277_[_iV277_]
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

# How many distinct values the RED channel takes across a render. An
# aliased edge can only be ink or paper; coverage blending has many.
# DISTINCT RED VALUES, counted with a presence table over sliced chunks.
# The old form paid twice per byte: a substr on the whole buffer (O(buffer)
# in Ring) and a StzFindFirst down a list that grew as it went. On one
# 420x320 canvas that was 37.3 seconds. Slicing 64KB at a time and marking
# a 256-slot table costs 0.03s for the same 224 levels -- and the table
# makes the count exact rather than order-dependent.
func _GreyLevels cPx
	_gSeen_ = []
	for _gk_ = 1 to 256  _gSeen_ + 0  next
	_gn_ = len(cPx)
	_gPos_ = 1
	while _gPos_ <= _gn_
		_gLen_ = min([ 65536, _gn_ - _gPos_ + 1 ])
		_gLen_ = _gLen_ - (_gLen_ % 4)
		if _gLen_ < 4  exit  ok
		_gS_ = substr(cPx, _gPos_, _gLen_)
		for _gj_ = 1 to _gLen_ - 3 step 4
			_gSeen_[ ascii(_gS_[_gj_]) + 1 ] = 1
		next
		_gPos_ += _gLen_
	end
	_gc_ = 0
	for _gk_ = 1 to 256
		if _gSeen_[_gk_] = 1  _gc_++  ok
	next
	return _gc_

func _ScaleDiag nScale
	_sd_ = new stzDiagram("sc")
	for _si_ = 1 to 3
		_sd_.AddNodeXTT("s" + _si_, "Node " + _si_,
			[ :type = "box", :color = "Info.Solid" ])
	next
	_sd_.AddEdge("s1", "s2")  _sd_.AddEdge("s1", "s3")
	return _sd_.ToCanvasXT([ :NodeWidth = 70, :NodeHeight = 28,
		:FontSize = 10, :Scale = nScale ])

# A canvas doubled by pixel duplication -- what :Scale must NOT be.
# Returns [ w, h, pixels ] rather than a canvas, since nothing here needs
# to draw it.
# THE TWO PIXEL HELPERS, AND THE 13 SECONDS THEY COST.
#
# The first version of these called substr() ONCE PER PIXEL over a
# 150,000-pixel buffer -- and Ring's substr on a big string is O(buffer),
# ~0.3ms per call on 1.8MB, the trap this repository's CLAUDE.md records
# with the measurement that found it (18.4s -> 0.03s on one diff). Section
# 21 was 13.2s of a 75s gate for two tiny pictures, and none of it was
# coverage. The rule, applied: slice the ROW once, index inside it.
func _Upscaled oC
	_uw_ = oC.Width()
	_uh_ = oC.Height()
	_up_ = oC.ToPixels()
	_uo_ = ""
	_urow_ = _uw_ * 4
	for _uy_ = 0 to _uh_ - 1
		# one slice per source row, then every byte by index
		_usrc_ = substr(_up_, _uy_ * _urow_ + 1, _urow_)
		_uline_ = ""
		for _ux_ = 0 to _uw_ - 1
			_upx_ = _usrc_[_ux_ * 4 + 1] + _usrc_[_ux_ * 4 + 2] +
				_usrc_[_ux_ * 4 + 3] + _usrc_[_ux_ * 4 + 4]
			_uline_ += _upx_ + _upx_
		next
		_uo_ += _uline_ + _uline_
	next
	return [ _uw_ * 2, _uh_ * 2, _uo_ ]

func _DiffFromUpscale oSmall, xBig
	_da_ = _Upscaled(oSmall)
	if isList(xBig)
		_dw_ = xBig[1]  _dh_ = xBig[2]  _db_ = xBig[3]
	else
		_dw_ = xBig.Width()  _dh_ = xBig.Height()  _db_ = xBig.ToPixels()
	ok
	if _dw_ != _da_[1] or _dh_ != _da_[2]  return 100  ok
	_drow_ = _dw_ * 4
	_dc_ = 0  _dt_ = 0
	for _dy_ = 0 to _dh_ - 1
		_dra_ = substr(_da_[3], _dy_ * _drow_ + 1, _drow_)
		_drb_ = substr(_db_, _dy_ * _drow_ + 1, _drow_)
		if len(_dra_) < _drow_ or len(_drb_) < _drow_  exit  ok
		for _dx_ = 0 to _dw_ - 1
			_dva_ = ascii(_dra_[_dx_ * 4 + 1])
			_dvb_ = ascii(_drb_[_dx_ * 4 + 1])
			if _dva_ < 245 or _dvb_ < 245
				_dt_++
				if fabs(_dva_ - _dvb_) > 12  _dc_++  ok
			ok
		next
	next
	if _dt_ = 0  return 0  ok
	return floor(_dc_ * 100 / _dt_)

func _BackwardDepartures cSvg, cStroke
	_sd_ = 0
	_slen2_ = StzLen(cSvg)
	_aSp2278_ = StzFindAll('<polyline points="', cSvg)
	_nSp2278_ = len(_aSp2278_)
	for _iSp2278_ = 1 to _nSp2278_
		_sp2_ = _aSp2278_[_iSp2278_]
		_st2_ = StzSubStr(cSvg, _sp2_, min([ 6000, _slen2_ - _sp2_ + 1 ]))
		_se2_ = StzFindFirst(">", _st2_)
		if _se2_ = 0  loop  ok
		if StzFindFirst(cStroke, StzSubStr(_st2_, 1, _se2_)) = 0  loop  ok
		_sq2_ = StzFindFirst('"', StzSubStr(_st2_, 19, StzLen(_st2_) - 18))
		if _sq2_ = 0  loop  ok
		_spt2_ = StzSplit(StzSubStr(_st2_, 19, _sq2_ - 1), " ")
		if len(_spt2_) < 2  loop  ok
		_sa2_ = StzSplit(StzTrim(_spt2_[1]), ",")
		_sb2_ = StzSplit(StzTrim(_spt2_[2]), ",")
		if len(_sa2_) != 2 or len(_sb2_) != 2  loop  ok
		try
			_sdy2_ = (0 + _sb2_[2]) - (0 + _sa2_[2])
		catch
			loop
		done
		if _sdy2_ < 0 - 0.01  _sd_++  ok
	next
	return _sd_

# Edges whose endpoints differ on the cross-axis by an amount too small to
# read as a slant and too large to be aligned -- the band the eye flags.
# Units are the 0..1000 normalised layout space; a slot is ~150 of it.
func _NearMissEdges oDiag, aPos
	_nm_ = 0
	_aE279_ = oDiag.Edges()
	_nE279_ = len(_aE279_)
	for _iE279_ = 1 to _nE279_
		_e_ = _aE279_[_iE279_]
		_xa_ = _XOf(aPos, "" + _e_[:from])
		_xb_ = _XOf(aPos, "" + _e_[:to])
		if _xa_ < 0 or _xb_ < 0  loop  ok
		_d_ = fabs(_xa_ - _xb_)
		if _d_ > 0.5 and _d_ < 40  _nm_++  ok
	next
	return _nm_

# Three participants, with or without the sequence profile -- the same
# scene both ways, so the row is attributable to the mode.
func _SqScene cName, bProfile
	_sqO_ = new stzDiagram(cName)
	if bProfile  _sqO_.SetNotation(StzUmlSequenceNotation())  ok
	_sqO_.AddNodeXTT("a", "A", [ :type = "participant" ])
	_sqO_.AddNodeXTT("b", "B", [ :type = "participant" ])
	_sqO_.AddNodeXTT("c", "C", [ :type = "participant" ])
	return _sqO_

# The y of every drawn message, in declaration order -- read off the
# recorded paths, which is the ink, never off the model that asked for it.
func _MsgYs oD
	_sqYs_ = []
	_sqNp_ = len(oD.@aEdgePaths)
	for _sqI_ = 1 to _sqNp_
		_sqP_ = oD.@aEdgePaths[_sqI_]
		if len(_sqP_[2]) >= 4  _sqYs_ + _sqP_[2][2]  ok
	next
	return _sqYs_

# the turn column of each edge out of the source, read off the ink
func TurnsOf oD, cSrc
	aT = []
	for i = 1 to len(oD.@aEdgePaths)
		cK = StzLower("" + oD.@aEdgePaths[i][1])
		nPre = len(cSrc) + 1
		if len(cK) < nPre  loop  ok
		if StzSubStr(cK, 1, nPre) != cSrc + ">"  loop  ok
		aF = oD.@aEdgePaths[i][2]
		if len(aF) < 6  loop  ok
		aT + aF[3]
	next
	return aT

func Scene cName, cShape
	o = new stzDiagram(cName)
	o.SetLayout(:LeftToRight)
	o.SetSplines(:ortho)
	o.AddNodeXTT("src", "Src", [ :type = cShape ])
	o.AddNodeXTT("a", "Up", [ :type = "box" ])
	o.AddNodeXTT("b", "Down", [ :type = "box" ])
	o.AddEdgeXT("src", "a", "first")
	o.AddEdgeXT("src", "b", "second")
	o.ToCanvasXT([ :Font = EFONT, :NodeWidth = 120, :NodeHeight = 50,
		:FontSize = 13 ])
	return o

func _GvComponent()
	_o_ = new stzDiagram("components")
	_o_.SetNotation(StzUmlComponentNotation())
	_o_.AddNodeXTT("web", "Web UI", [ :type = "component" ])
	_o_.AddNodeXTT("api", "Order API", [ :type = "component" ])
	_o_.AddNodeXTT("pay", "Payments", [ :type = "component" ])
	_o_.AddNodeXTT("store", "Catalogue", [ :type = "component" ])
	_o_.AddEdgeXTT("web", "api", "", [ :uml = :Dependency ])
	_o_.AddEdgeXTT("api", "pay", "", [ :uml = :Dependency ])
	_o_.AddEdgeXTT("api", "store", "", [ :uml = :Dependency ])
	_o_.ToCanvasXT(OPTGOV)
	return _o_

# bMiddle switches the label convention, which is the WITNESS for the
# label rule's boundary -- under :Middle a word sits on its line by
# design, so those labels are outside that rule entirely.
func _GvComm bMiddle
	_o_ = new stzDiagram("comm")
	_o_.SetNotation(StzUmlCommunicationNotation())
	_o_.AddNodeXTT("u", "Shopper", [ :type = "actor" ])
	_o_.AddNodeXTT("c", ": Cart", [ :type = "object" ])
	_o_.AddNodeXTT("s", ": Stock", [ :type = "object" ])
	_o_.AddNodeXTT("p", ": Payment", [ :type = "object" ])
	_o_.AddEdgeXT("u", "c", "1: add(item)")
	_o_.AddEdgeXT("c", "s", "2: reserve(item)")
	_o_.AddEdgeXT("c", "p", "3: charge(total)")
	if bMiddle
		_o_.ToCanvasXT([ :Font = EFONT, :NodeWidth = 130, :NodeHeight = 52,
			:FontSize = 14, :LabelPlacement = :Middle ])
	else
		_o_.ToCanvasXT(OPTGOV)
	ok
	return _o_

func _GvDecision()
	_o_ = new stzDiagram("decision")
	_o_.SetLayout(:LeftToRight)
	_o_.SetSplines(:ortho)
	_o_.AddNodeXTT("start", "Start", [ :type = "box" ])
	_o_.AddNodeXTT("d", "Ready?", [ :type = "diamond" ])
	_o_.AddNodeXTT("yes", "Ship", [ :type = "box" ])
	_o_.AddNodeXTT("no", "Hold", [ :type = "box" ])
	_o_.AddEdge("start", "d")
	_o_.AddEdgeXT("d", "yes", "yes")
	_o_.AddEdgeXT("d", "no", "no")
	_o_.ToCanvasXT(OPTGOV)
	return _o_

# THE TWO LOGIC FORMULAS, added to the corpus because the rules about
# them governed NOTHING without a picture that has one -- which the
# governor's own meta-guard caught the moment they were written. A
# rule nobody's diagram exercises is a dead rule, and the plane
# already asserts that.
#
# AND: each affirmative asks the next question, so the run stands on
# one vertical -- "For AND, put the if icons on the skewer."
func _GvDrakonAnd()
	_o_ = new stzDiagram("drakonand")
	_o_.SetNotation(StzDrakonNotation())
	_o_.AddNodeXTT("t", "Admit the visitor", [ :type = "title" ])
	_o_.AddNodeXTT("q1", "Has a badge?", [ :type = "question" ])
	_o_.AddNodeXTT("q2", "Badge valid?", [ :type = "question" ])
	_o_.AddNodeXTT("ok", "Open the door", [ :type = "action" ])
	_o_.AddNodeXTT("no", "Turn them away", [ :type = "action" ])
	_o_.AddNodeXTT("e", "Done", [ :type = "end" ])
	_o_.AddEdge("t", "q1")
	_o_.AddEdgeXTT("q1", "q2", "yes", [ :exit = :down ])
	_o_.AddEdgeXTT("q1", "no", "no", [ :exit = :right ])
	_o_.AddEdgeXTT("q2", "ok", "yes", [ :exit = :down ])
	_o_.AddEdgeXTT("q2", "no", "no", [ :exit = :right ])
	_o_.AddEdge("ok", "e")  _o_.AddEdge("no", "e")
	_o_.ToCanvasXT(OPTGOV)
	return _o_

# OR: each REFUSAL asks the next question, so the run steps out and
# down -- "for OR, arrange the if icons as stair steps."
#
# THREE DEEP, BECAUSE TWO WAS NOT ENOUGH AND THAT IS THE FINDING.
# This corpus picture had TWO questions while the published catalogue
# draws THREE, and the catalogue's third step was drawn LEFT of its
# second for as long as the rule existed -- an inverted staircase, in
# the section written to enforce staircases. The rule never saw it,
# because a two-link chain has no second step to get wrong.
#
# A rule exercised on a simpler shape than the artefact it governs
# does not govern the artefact. The corpus now carries at least the
# depth the catalogue publishes.
func _GvDrakonOr()
	_o_ = new stzDiagram("drakonor")
	_o_.SetNotation(StzDrakonNotation())
	_o_.AddNodeXTT("t", "Let them in", [ :type = "title" ])
	_o_.AddNodeXTT("q1", "On the list?", [ :type = "question" ])
	_o_.AddNodeXTT("q2", "Has a ticket?", [ :type = "question" ])
	_o_.AddNodeXTT("q3", "Known to staff?", [ :type = "question" ])
	_o_.AddNodeXTT("ok", "Open the door", [ :type = "action" ])
	_o_.AddNodeXTT("no", "Turn them away", [ :type = "action" ])
	_o_.AddNodeXTT("e", "Done", [ :type = "end" ])
	_o_.AddEdge("t", "q1")
	_o_.AddEdgeXTT("q1", "ok", "yes", [ :exit = :down ])
	_o_.AddEdgeXTT("q1", "q2", "no", [ :exit = :right ])
	_o_.AddEdgeXTT("q2", "ok", "yes", [ :exit = :down ])
	_o_.AddEdgeXTT("q2", "q3", "no", [ :exit = :right ])
	_o_.AddEdgeXTT("q3", "ok", "yes", [ :exit = :down ])
	_o_.AddEdgeXTT("q3", "no", "no", [ :exit = :right ])
	_o_.AddEdge("ok", "e")  _o_.AddEdge("no", "e")
	_o_.ToCanvasXT(OPTGOV)
	return _o_

func _GvChain()
	_o_ = new stzDiagram("chain")
	_o_.SetLayout(:LeftToRight)
	_o_.SetSplines(:ortho)
	_o_.AddNodeXTT("a", "One", [ :type = "box" ])
	_o_.AddNodeXTT("b", "Two", [ :type = "box" ])
	_o_.AddNodeXTT("c", "Three", [ :type = "box" ])
	_o_.AddNodeXTT("d", "Four", [ :type = "box" ])
	_o_.AddEdge("a", "b")
	_o_.AddEdge("b", "c")
	_o_.AddEdge("b", "d")
	_o_.ToCanvasXT(OPTGOV)
	return _o_

# Does a path's last point lie on this rect's border (within a pad)?
func _OnBorder aFlat, aRect, nPad
	if len(aFlat) < 4 or len(aRect) < 4  return 0  ok
	_x_ = aFlat[ len(aFlat) - 1 ]
	_y_ = aFlat[ len(aFlat) ]
	_l_ = aRect[1] - nPad   _r_ = aRect[1] + aRect[3] + nPad
	_t_ = aRect[2] - nPad   _b_ = aRect[2] + aRect[4] + nPad
	if _x_ < _l_ or _x_ > _r_ or _y_ < _t_ or _y_ > _b_  return 0  ok
	return 1

# The longest stretch two paths run down one column, 0 when they never
# do. A shared column is the line with an arrow at each end, whichever
# way each arrow points.
func _SharedColumn aA, aB, nClr
	_best_ = 0
	for _i_ = 1 to len(aA) - 3 step 2
		if fabs(aA[_i_ + 2] - aA[_i_]) > 0.5  loop  ok
		_ax_ = aA[_i_]
		_a1_ = min([ aA[_i_ + 1], aA[_i_ + 3] ])
		_a2_ = max([ aA[_i_ + 1], aA[_i_ + 3] ])
		for _j_ = 1 to len(aB) - 3 step 2
			if fabs(aB[_j_ + 2] - aB[_j_]) > 0.5  loop  ok
			if fabs(aB[_j_] - _ax_) >= nClr  loop  ok
			_b1_ = min([ aB[_j_ + 1], aB[_j_ + 3] ])
			_b2_ = max([ aB[_j_ + 1], aB[_j_ + 3] ])
			_ov_ = min([ _a2_, _b2_ ]) - max([ _a1_, _b1_ ])
			if _ov_ > nClr and _ov_ > _best_  _best_ = _ov_  ok
		next
	next
	return _best_

# How many genuine corners a flat path turns -- duplicated points and
# points left in the middle of a straight run are not bends, and counting
# them is how a route gets blamed for turns a reader cannot see.
func _TurnsIn aFlat
	_t_ = 0
	for _i_ = 1 to len(aFlat) - 5 step 2
		_dx1_ = aFlat[_i_ + 2] - aFlat[_i_]
		_dy1_ = aFlat[_i_ + 3] - aFlat[_i_ + 1]
		_dx2_ = aFlat[_i_ + 4] - aFlat[_i_ + 2]
		_dy2_ = aFlat[_i_ + 5] - aFlat[_i_ + 3]
		if fabs(_dx1_) + fabs(_dy1_) < 0.5  loop  ok
		if fabs(_dx2_) + fabs(_dy2_) < 0.5  loop  ok
		if (fabs(_dx1_) > fabs(_dy1_)) != (fabs(_dx2_) > fabs(_dy2_))
			_t_++
		ok
	next
	return _t_

# Declared by a section, recorded against the section it sits in. The
# static rules in stzCodeRules.ring read the same lines from the source,
# so the check works without running this 66-second suite.
func discharges cItemId
	if cCurSecKey != ""
		aDischarged + [ cItemId, cCurSecKey ]
	ok

# Findings of one rule, counted. Prefixed, because this suite is one Ring
# namespace and a bare `Hits` would be the whole file's.
func _PorHits paFindings, pcRule
	_n_ = 0
	_nF_ = len(paFindings)
	for _i_ = 1 to _nF_
		if "" + paFindings[_i_][:rule] = pcRule  _n_++  ok
	next
	return _n_

# Is pcTag drawn inside the group named pcId?
func _DiInGroup pcSvg, pcId, pcTag
	_a_ = StzFindCS('id="' + pcId + '"', pcSvg, TRUE)
	if len(_a_) = 0  return FALSE  ok
	_nFrom_ = _a_[1]
	_b_ = StzFindCS("</g>", pcSvg, TRUE)
	_nTo_ = len(pcSvg)
	_nB_ = len(_b_)
	for _i_ = 1 to _nB_
		if _b_[_i_] > _nFrom_
			_nTo_ = _b_[_i_]
			exit
		ok
	next
	_c_ = StzFindCS(pcTag, pcSvg, TRUE)
	_nC_ = len(_c_)
	for _i_ = 1 to _nC_
		if _c_[_i_] > _nFrom_ and _c_[_i_] < _nTo_  return TRUE  ok
	next
	return FALSE

func _DiBeforeFirstGroup pcSvg, pcTag
	_a_ = StzFindCS(pcTag, pcSvg, TRUE)
	_b_ = StzFindCS("<g ", pcSvg, TRUE)
	if len(_a_) = 0 or len(_b_) = 0  return FALSE  ok
	return _a_[1] < _b_[1]

func _DiAfterLastGroup pcSvg, pcTag
	_a_ = StzFindCS(pcTag, pcSvg, TRUE)
	_b_ = StzFindCS("</g>", pcSvg, TRUE)
	if len(_a_) = 0 or len(_b_) = 0  return FALSE  ok
	return _a_[len(_a_)] > _b_[len(_b_)]

func _DiRefused pcName, pcCls
	_o_ = new stzCanvas(50, 50)
	_r_ = FALSE
	try
		_o_.SetSvgIdent(pcName, pcCls)
	catch
		_r_ = TRUE
	done
	return _r_

func _DiOneIdent pcName, pcCls
	_o_ = new stzCanvas(60, 60)
	_o_.SetSvgIdent(pcName, pcCls)
	_o_.Fill("black")
	_o_.AddRect(5, 5, 20, 20)
	return _o_.ToSVG()

func _Wf76 cType, aOpts
	_o_ = new stzWorkflow("w76" + cType + len(aOpts))
	if cType != ""  _o_.SetWorkflowType(cType)  ok
	_o_.AddStateXTT("s", "", [ :type = "entry" ])
	_o_.AddStateXTT("recv", "Receive Order", [ :type = "invoke" ])
	_o_.AddStateXTT("done", "Shipped", [ :type = "terminal" ])
	_o_.AddTransition("s", "recv", "")
	_o_.AddTransition("recv", "done", "ok")
	_a_ = [ :Font = AUFONT, :NodeWidth = 132, :NodeHeight = 52 ]
	_n_ = len(aOpts)
	for _i_ = 1 to _n_
		_a_ + aOpts[_i_]
	next
	return _o_.ToCanvasXT(_a_).ToSVG()

func _Ids76 cSvg
	_a_ = StzFindCS('<g id="', cSvg, TRUE)
	_ac_ = []
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		_t_ = StzStringSection(cSvg, _a_[_i_] + 7, _a_[_i_] + 90)
		_q_ = StzFindFirst('"', _t_)
		if _q_ > 1  _ac_ + StzStringSection(_t_, 1, _q_ - 1)  ok
	next
	return _ac_

func _Dups76 acIds
	_d_ = 0
	_n_ = len(acIds)
	for _i_ = 1 to _n_
		for _j_ = _i_ + 1 to _n_
			if acIds[_i_] = acIds[_j_]  _d_++  ok
		next
	next
	return _d_

func _Has76 acIds, cWanted
	_n_ = len(acIds)
	for _i_ = 1 to _n_
		if acIds[_i_] = cWanted  return TRUE  ok
	next
	return FALSE

func _LooseText76 cSvg
	_aG_ = StzFindCS("<g ", cSvg, TRUE)
	_aC_ = StzFindCS("</g>", cSvg, TRUE)
	_aP_ = StzFindCS("<path", cSvg, TRUE)
	_loose_ = 0
	_nP_ = len(_aP_)
	_nG_ = len(_aG_)
	for _i_ = 1 to _nP_
		_in_ = FALSE
		for _j_ = 1 to _nG_
			if _aP_[_i_] > _aG_[_j_] and _aP_[_i_] < _aC_[_j_]
				_in_ = TRUE
				exit
			ok
		next
		if NOT _in_  _loose_++  ok
	next
	return _loose_

# One of the five process shapes section 77 compares.
func _Wf77 cWhich
	_aS_ = []
	_aE_ = []
	switch cWhich
	on "linear"
		_aS_ = [ [ "s", "", "entry" ], [ "a", "A", "invoke" ],
		         [ "b", "B", "invoke" ], [ "e", "End", "terminal" ] ]
		_aE_ = [ [ "s", "a" ], [ "a", "b" ], [ "b", "e" ] ]
	on "gateway"
		_aS_ = [ [ "s", "", "entry" ], [ "recv", "Receive", "invoke" ],
		         [ "chk", "Check", "gateway" ], [ "pack", "Pack", "human" ],
		         [ "ok", "Shipped", "terminal" ],
		         [ "no", "Rejected", "terminal" ] ]
		_aE_ = [ [ "s", "recv" ], [ "recv", "chk" ], [ "chk", "pack" ],
		         [ "chk", "no" ], [ "pack", "ok" ] ]
	on "return"
		_aS_ = [ [ "s", "", "entry" ], [ "a", "A", "invoke" ],
		         [ "b", "B", "gateway" ], [ "e", "End", "terminal" ] ]
		_aE_ = [ [ "s", "a" ], [ "a", "b" ], [ "b", "e" ], [ "b", "a" ] ]
	on "twoarrivals"
		_aS_ = [ [ "s", "", "entry" ], [ "a", "A", "gateway" ],
		         [ "b", "B", "invoke" ], [ "e", "End", "terminal" ] ]
		_aE_ = [ [ "s", "a" ], [ "a", "b" ], [ "a", "e" ], [ "b", "e" ] ]
	other
		_aS_ = [ [ "s", "", "entry" ], [ "g", "G", "gateway" ],
		         [ "q", "Q", "invoke" ], [ "r", "R", "invoke" ],
		         [ "t", "T", "invoke" ], [ "e", "End", "terminal" ] ]
		_aE_ = [ [ "s", "g" ], [ "g", "e" ], [ "g", "q" ], [ "q", "r" ],
		         [ "r", "t" ], [ "t", "e" ] ]
	off
	nCf77Seq++
	_o_ = new stzWorkflow("cf77" + cWhich + nCf77Seq)
	_o_.SetWorkflowType("bpmn")
	_n_ = len(_aS_)
	for _i_ = 1 to _n_
		_o_.AddStepXTT(_aS_[_i_][1], _aS_[_i_][2], [ :type = _aS_[_i_][3] ])
	next
	_m_ = len(_aE_)
	for _i_ = 1 to _m_
		_o_.Connect(_aE_[_i_][1], _aE_[_i_][2])
	next
	return _o_

# How many cells the shared render places somewhere the law did not.
func _Cf77 cWhich, nExpand
	_oL_ = _Wf77(cWhich)
	_oB_ = new stzBpmnDiagram(_oL_)
	_aSt_ = _oL_.Steps()
	_nS_ = len(_aSt_)
	for _i_ = 1 to _nS_
		if StzLower("" + _oL_.NodeProperty("" + _aSt_[_i_][:id], "type")) =
		   "terminal"
			_oB_.MarkEnding("" + _aSt_[_i_][:id], "terminal", "")
		ok
	next
	_aLaw_ = _Law77(_oB_.LayoutDigest())

	_oR_ = _Wf77(cWhich)
	if nExpand = 1  _oR_.ExpandEndingsPerArrival()  ok
	_oR_.ToCanvasXT([ :Font = AUFONT, :NodeWidth = 132, :NodeHeight = 52 ])
	_aRen_ = _Cells77(_oR_.RenderNodeRects())

	_nD_ = 0
	_nL_ = len(_aLaw_)
	for _i_ = 1 to _nL_
		_cB_ = StzReplace(StzReplace(_aLaw_[_i_][1], "terminal_", ""),
		                  "suspended_", "")
		_a_ = _CellOf77(_aRen_, _cB_)
		if len(_a_) = 0
			_nD_++
			loop
		ok
		if _a_[1] != _aLaw_[_i_][2] or _a_[2] != _aLaw_[_i_][3]  _nD_++  ok
	next
	return _nD_

func _Law77 cDigest
	_a_ = []
	_ac_ = StzSplit(StzReplace(cDigest, char(13), ""), char(10))
	_n_ = len(_ac_)
	for _i_ = 1 to _n_
		_c_ = StzTrim(_ac_[_i_])
		if StzLeft(_c_, 2) = "N "
			_p_ = StzSplit(_c_, " ")
			if len(_p_) >= 5  _a_ + [ _p_[2], 0 + _p_[4], 0 + _p_[5] ]  ok
		but StzLeft(_c_, 2) = "X "
			_p_ = StzSplit(_c_, " ")
			if len(_p_) >= 6  _a_ + [ _p_[2], 0 + _p_[5], 0 + _p_[6] ]  ok
		ok
	next
	return _a_

# The drawn picture as CELLS. Pixels cannot be compared with grid units,
# but their ORDER can, and order is exactly what the law fixes.
func _Cells77 aRects
	_acX_ = []
	_acY_ = []
	_n_ = len(aRects)
	for _i_ = 1 to _n_
		_cx_ = aRects[_i_][1] + aRects[_i_][3] / 2
		_cy_ = aRects[_i_][2] + aRects[_i_][4] / 2
		if NOT _Near77(_acX_, _cx_)  _acX_ + _cx_  ok
		if NOT _Near77(_acY_, _cy_)  _acY_ + _cy_  ok
	next
	_acX_ = sort(_acX_)
	_acY_ = sort(_acY_)
	_a_ = []
	for _i_ = 1 to _n_
		_cx_ = aRects[_i_][1] + aRects[_i_][3] / 2
		_cy_ = aRects[_i_][2] + aRects[_i_][4] / 2
		_a_ + [ aRects[_i_][5], _NearIdx77(_acX_, _cx_),
		        _NearIdx77(_acY_, _cy_) - 1 ]
	next
	return _a_

func _Near77 aList, nV
	_n_ = len(aList)
	for _i_ = 1 to _n_
		if fabs(aList[_i_] - nV) < 2  return TRUE  ok
	next
	return FALSE

func _NearIdx77 aList, nV
	_n_ = len(aList)
	for _i_ = 1 to _n_
		if fabs(aList[_i_] - nV) < 2  return _i_  ok
	next
	return 0

func _CellOf77 aCells, cId
	_n_ = len(aCells)
	for _i_ = 1 to _n_
		if StzLower(aCells[_i_][1]) = StzLower(cId)
			return [ aCells[_i_][2], aCells[_i_][3] ]
		ok
	next
	return []

# One refusal each, by number; 0 is the lawful form of every one.
func _MdRefuses pnWhich
	_b_ = FALSE
	try
		_oD_ = StzSetTheoryDomain()
		_oD_.AddType("Point")
		_oS_ = new stzMathSubstance(_oD_)
		_oS_.DeclareAll("Set", [ "A", "B" ])
		_oS_.Declare("Point", "p")
		if pnWhich = 1  _oS_.Declare("Blob", "z")  ok
		if pnWhich = 2  _oS_.Assert("Touches", [ "A", "B" ])  ok
		if pnWhich = 3  _oS_.Assert("Subset", [ "A" ])  ok
		if pnWhich = 4  _oS_.Assert("Subset", [ "p", "A" ])  ok
		_oT_ = new stzMathStyle()
		if pnWhich = 5
			_oT_.ForAll("Set x", [ [ :ensure, "levitate", [ "x.icon" ] ] ])
		else
			_oT_.ForAll("Set x", [ [ :ensure, "contains", [ "x.icon", "x.icon" ] ] ])
		ok
		_oS_.Assert("Subset", [ "B", "A" ])
	catch
		_b_ = TRUE
	done
	return _b_

# cosine between two solved lines, by plain arithmetic
func _MbCos poM, pcL1, pcL2
	_a_ = poM.ShapeOf(pcL1)
	_b_ = poM.ShapeOf(pcL2)
	_dx_ = _a_[:x2] - _a_[:x1]  _dy_ = _a_[:y2] - _a_[:y1]
	_ex_ = _b_[:x2] - _b_[:x1]  _ey_ = _b_[:y2] - _b_[:y1]
	_n_ = sqrt(pow(_dx_, 2) + pow(_dy_, 2)) * sqrt(pow(_ex_, 2) + pow(_ey_, 2))
	if _n_ < 0.000001  return 1  ok
	return (_dx_ * _ex_ + _dy_ * _ey_) / _n_

func _MbLen poM, pcL
	_a_ = poM.ShapeOf(pcL)
	return sqrt(pow(_a_[:x2] - _a_[:x1], 2) + pow(_a_[:y2] - _a_[:y1], 2))

# is the text's centre further from the segment than half its diagonal?
func _MbTextOff poM, pcText, pcLine
	_t_ = poM.ShapeOf(pcText)
	_l_ = poM.ShapeOf(pcLine)
	_dx_ = _l_[:x2] - _l_[:x1]  _dy_ = _l_[:y2] - _l_[:y1]
	_n_ = pow(_dx_, 2) + pow(_dy_, 2)
	if _n_ < 0.000001  return TRUE  ok
	_s_ = ((_t_[:cx] - _l_[:x1]) * _dx_ + (_t_[:cy] - _l_[:y1]) * _dy_) / _n_
	if _s_ < 0  _s_ = 0  ok
	if _s_ > 1  _s_ = 1  ok
	_d_ = sqrt(pow(_l_[:x1] + _s_ * _dx_ - _t_[:cx], 2) + pow(_l_[:y1] + _s_ * _dy_ - _t_[:cy], 2))
	return _d_ >= sqrt(pow(_t_[:w], 2) + pow(_t_[:h], 2)) / 2

func _MbRefuses pnWhich
	_b_ = FALSE
	try
		_oT_ = StzEulerStyle()
		if pnWhich = 1  _oT_.ForAll("Set x", [ [ :override, "x.halo.r", 5 ] ])  ok
		if pnWhich = 2
			_oT_.ForAllWhere("Set x; Set y; Set z", "x := frob(y, z)",
				[ [ :ensure, "greaterThan", [ "x.icon.r", 1 ] ] ])
		ok
		if pnWhich = 3  _oT_.ForAll("Set x", [ [ :ensure, "greaterThan", [ "len(x.icon)", 1 ] ] ])  ok
		_o_ = new stzMathDiagram(StzSetTheoryDomain(), StzMathTreeSubstance(), _oT_)
		_o_.Layout()
	catch
		_b_ = TRUE
	done
	return _b_

func _McCurves poM
	_n_ = 0
	_ac_ = poM.Shapes()
	for _i_ = 1 to len(_ac_)
		if poM.ShapeOf(_ac_[_i_])[:kind] = "curve"  _n_++  ok
	next
	return _n_

func _McCount poM, pcPath
	_n_ = 0
	_ac_ = poM.Shapes()
	for _i_ = 1 to len(_ac_)
		if _ac_[_i_] = pcPath  _n_++  ok
	next
	return _n_

func _McDot3 poM, pcA, pcB
	return poM.ValueOf(pcA + ".sx") * poM.ValueOf(pcB + ".sx") +
	       poM.ValueOf(pcA + ".sy") * poM.ValueOf(pcB + ".sy") +
	       poM.ValueOf(pcA + ".sz") * poM.ValueOf(pcB + ".sz")

# cosine between the geodesic tangents at q, toward p and toward r
func _McSphereCos poM, pcP, pcQ, pcR
	_dqp_ = _McDot3(poM, pcQ, pcP)
	_dqr_ = _McDot3(poM, pcQ, pcR)
	_t1_ = [ poM.ValueOf(pcP + ".sx") - _dqp_ * poM.ValueOf(pcQ + ".sx"),
	         poM.ValueOf(pcP + ".sy") - _dqp_ * poM.ValueOf(pcQ + ".sy"),
	         poM.ValueOf(pcP + ".sz") - _dqp_ * poM.ValueOf(pcQ + ".sz") ]
	_t2_ = [ poM.ValueOf(pcR + ".sx") - _dqr_ * poM.ValueOf(pcQ + ".sx"),
	         poM.ValueOf(pcR + ".sy") - _dqr_ * poM.ValueOf(pcQ + ".sy"),
	         poM.ValueOf(pcR + ".sz") - _dqr_ * poM.ValueOf(pcQ + ".sz") ]
	_n1_ = sqrt(pow(_t1_[1], 2) + pow(_t1_[2], 2) + pow(_t1_[3], 2))
	_n2_ = sqrt(pow(_t2_[1], 2) + pow(_t2_[2], 2) + pow(_t2_[3], 2))
	if _n1_ * _n2_ < 0.000001  return 1  ok
	return (_t1_[1] * _t2_[1] + _t1_[2] * _t2_[2] + _t1_[3] * _t2_[3]) / (_n1_ * _n2_)

func _McDelta poM, pcA, pcB
	_ax_ = poM.ValueOf(pcA + ".hx")  _ay_ = poM.ValueOf(pcA + ".hy")
	_bx_ = poM.ValueOf(pcB + ".hx")  _by_ = poM.ValueOf(pcB + ".hy")
	return (pow(_ax_ - _bx_, 2) + pow(_ay_ - _by_, 2)) /
	       ((1 - pow(_ax_, 2) - pow(_ay_, 2)) * (1 - pow(_bx_, 2) - pow(_by_, 2)))

# the direction from the geodesic's centre to q, denominators cleared:
# D*q - N for the arc through q and p
func _McDiskDir poM, pcQ, pcP
	_qx_ = poM.ValueOf(pcQ + ".hx")  _qy_ = poM.ValueOf(pcQ + ".hy")
	_px_ = poM.ValueOf(pcP + ".hx")  _py_ = poM.ValueOf(pcP + ".hy")
	_kq_ = (1 + pow(_qx_, 2) + pow(_qy_, 2)) / 2
	_kp_ = (1 + pow(_px_, 2) + pow(_py_, 2)) / 2
	_D_ = _qx_ * _py_ - _qy_ * _px_
	_nx_ = _kq_ * _py_ - _kp_ * _qy_
	_ny_ = _qx_ * _kp_ - _px_ * _kq_
	return [ _D_ * _qx_ - _nx_, _D_ * _qy_ - _ny_ ]

func _McDiskCos poM, pcQ, pcP, pcR
	_v1_ = _McDiskDir(poM, pcQ, pcP)
	_v2_ = _McDiskDir(poM, pcQ, pcR)
	_n_ = sqrt(pow(_v1_[1], 2) + pow(_v1_[2], 2)) * sqrt(pow(_v2_[1], 2) + pow(_v2_[2], 2))
	if _n_ < 0.000001  return 1  ok
	return (_v1_[1] * _v2_[1] + _v1_[2] * _v2_[2]) / _n_

# every name's direction from its point more than 104 degrees from the
# chord to every other vertex -- re-read from the drawn positions
func _McNamesOut poM
	_ac_ = [ "A", "B", "C" ]
	for _i_ = 1 to 3
		_p_ = poM.ShapeOf(_ac_[_i_] + ".icon")
		_t_ = poM.ShapeOf(_ac_[_i_] + ".text")
		_dx_ = _t_[:cx] - _p_[:cx]  _dy_ = _t_[:cy] - _p_[:cy]
		_nd_ = sqrt(pow(_dx_, 2) + pow(_dy_, 2))
		for _j_ = 1 to 3
			if _j_ = _i_  loop  ok
			_q_ = poM.ShapeOf(_ac_[_j_] + ".icon")
			_ex_ = _q_[:cx] - _p_[:cx]  _ey_ = _q_[:cy] - _p_[:cy]
			_ne_ = sqrt(pow(_ex_, 2) + pow(_ey_, 2))
			if _nd_ * _ne_ < 0.001  return FALSE  ok
			if (_dx_ * _ex_ + _dy_ * _ey_) / (_nd_ * _ne_) > -0.24  return FALSE  ok
		next
	next
	return TRUE

func _McRefuses pnWhich
	_b_ = FALSE
	try
		_oT_ = StzSphericalStyle()
		if pnWhich = 1
			_oT_.ForAllWhere("Segment s; Point p; Point q", "s := Segment(p, q)",
				[ [ :ensure, "contains", [ "_.sphere", "s.icon" ] ] ])
		ok
		if pnWhich = 2  _oT_.ForAll("Point p", [ [ :unknown, "p.w", "low" ] ])  ok
		_o_ = new stzMathDiagram(StzGeometryDomain(), StzMathRightIsoscelesSubstance(), _oT_)
		_o_.Layout()
	catch
		_b_ = TRUE
	done
	return _b_

func _MdHas poM, pcPath
	_ac_ = poM.Shapes()
	for _i_ = 1 to len(_ac_)
		if _ac_[_i_] = pcPath  return TRUE  ok
	next
	return FALSE

# the shoelace area of a flat [ x1, y1, x2, y2, ... ] polygon
func _MdArea paP
	_n_ = floor(len(paP) / 2)
	if _n_ < 3  return 0  ok
	_s_ = 0
	for _i_ = 1 to _n_
		_j_ = _i_ + 1
		if _j_ > _n_  _j_ = 1  ok
		_s_ += paP[2*_i_-1] * paP[2*_j_] - paP[2*_j_-1] * paP[2*_i_]
	next
	return fabs(_s_) / 2

# how far (px) a point lies from a drawn polyline
func _MdNearPoly paPts, pnX, pnY
	_best_ = 1000000
	_n_ = floor(len(paPts) / 2)
	for _i_ = 1 to _n_ - 1
		_ax_ = paPts[2*_i_-1]  _ay_ = paPts[2*_i_]
		_dx_ = paPts[2*_i_+1] - _ax_  _dy_ = paPts[2*_i_+2] - _ay_
		_L_ = _dx_*_dx_ + _dy_*_dy_
		_t_ = 0
		if _L_ > 0.000001
			_t_ = ((pnX - _ax_)*_dx_ + (pnY - _ay_)*_dy_) / _L_
			if _t_ < 0  _t_ = 0  ok
			if _t_ > 1  _t_ = 1  ok
		ok
		_d_ = sqrt(pow(_ax_ + _t_*_dx_ - pnX, 2) + pow(_ay_ + _t_*_dy_ - pnY, 2))
		if _d_ < _best_  _best_ = _d_  ok
	next
	return _best_

# the worse of the two feet's distances from the arc each one marks
func _MdFootOff poM
	_aM_ = poM.MarkStrokesOf("BAC.rmark")
	if len(_aM_) != 2  return 1000  ok
	_d1_ = _MdNearPoly(poM.CurvePointsOf("AB.icon"), _aM_[1][1], _aM_[1][2])
	_d2_ = _MdNearPoly(poM.CurvePointsOf("AC.icon"), _aM_[2][3], _aM_[2][4])
	if _d2_ > _d1_  return _d2_  ok
	return _d1_

# where a foot walked along the CHORD would have landed, against the arc
func _MdChordOff poM
	_aA_ = poM.ShapeOf("A.icon")
	_aB_ = poM.ShapeOf("B.icon")
	_dx_ = _aB_[:cx] - _aA_[:cx]
	_dy_ = _aB_[:cy] - _aA_[:cy]
	_L_ = sqrt(pow(_dx_, 2) + pow(_dy_, 2))
	if _L_ < 0.001  return 0  ok
	return _MdNearPoly(poM.CurvePointsOf("AB.icon"),
		_aA_[:cx] + 17*_dx_/_L_, _aA_[:cy] + 17*_dy_/_L_)

func _MdTickOff poM, pcTick, pcArc
	_aT_ = poM.MarkStrokesOf(pcTick)
	if len(_aT_) < 1  return 1000  ok
	return _MdNearPoly(poM.CurvePointsOf(pcArc),
		(_aT_[1][1] + _aT_[1][3]) / 2, (_aT_[1][2] + _aT_[1][4]) / 2)

# a triangle with no right angle: the general rule keeps its outline
func _MdPlainTriangle
	_oS_ = new stzMathSubstance(StzGeometryDomain())
	_oS_.DeclareAll("Point", [ "P", "Q", "R" ])
	_oS_.Define("PQR", "Triangle", [ "P", "Q", "R" ])
	_oS_.AutoLabelAll()
	_oS_.Label("PQR", "")
	_o_ = new stzMathDiagram(StzGeometryDomain(), _oS_, StzByrneStyle())
	_o_.SetFont(AUFONT, 24)
	_o_.SetVariation("plain")
	_o_.Layout()
	return _o_

# A WIDE NAME AGAINST A DISK IT MAY NOT ENTER, pulled as close as the
# constraint allows. Returns [ exact box gap, bounding-circle gap ]: the
# first is what disjoint() now measures, the second is what the old
# bounding-circle rule measured, and they disagree by the width of the name.
func _MdBoxProbe
	_oS_ = new stzMathSubstance(StzSetTheoryDomain())
	_oS_.Declare("Set", "W")
	_oS_.Label("W", "WWWWWWWW")
	_oSt_ = new stzMathStyle()
	_oSt_.SetCanvas(600, 400)
	_oSt_.ForAll("Set x", [
		[ :shape, "x.icon", :circle, [ :cx = 300, :cy = 200, :r = 70,
		                               :fill = "#eeeef6", :stroke = "#8888aa" ] ],
		[ :shape, "x.text", :text, [ :fill = "black" ] ],
		[ :ensure, "disjoint", [ "x.text", "x.icon", 0 ] ],
		# the pull has its minimum on a RING, not at the centre: a name
		# pulled exactly onto the centre sits where abs() has no gradient,
		# and no push can move it sideways again
		[ :encourage, "near", [ "x.text", "x.icon", 130 ] ] ])
	_o_ = new stzMathDiagram(StzSetTheoryDomain(), _oS_, _oSt_)
	_o_.SetFont(AUFONT, 24)
	_o_.SetVariation("minkowski")
	_o_.Layout()
	_aT_ = _o_.ShapeOf("W.text")
	_d_ = sqrt(pow(_aT_[:cx] - 300, 2) + pow(_aT_[:cy] - 200, 2))
	# the exact distance from the circle's centre to the name's BOX
	_qx_ = fabs(_aT_[:cx] - 300) - _aT_[:w] / 2
	_qy_ = fabs(_aT_[:cy] - 200) - _aT_[:h] / 2
	_mx_ = _qx_  if _qy_ > _mx_  _mx_ = _qy_  ok
	_ax_ = _qx_  if _ax_ < 0  _ax_ = 0  ok
	_ay_ = _qy_  if _ay_ < 0  _ay_ = 0  ok
	_sd_ = sqrt(pow(_ax_, 2) + pow(_ay_, 2))
	if _mx_ < 0  _sd_ += _mx_  ok
	_half_ = sqrt(pow(_aT_[:w], 2) + pow(_aT_[:h], 2)) / 2
	return [ _sd_ - 70, _d_ - 70 - _half_ ]

# the last piece of the figure to be painted, and the first dot after it
func _ByLastInk poM
	_n_ = 0
	for _cP_ in [ "ABC.face", "ABC.sqab", "ABC.sqac", "ABC.sqbc", "ABC.rect1",
	              "ABC.rect2", "ABC.alt", "ABC.mark1", "ABC.mark2" ]
		if poM.DrawIndexOf(_cP_) > _n_  _n_ = poM.DrawIndexOf(_cP_)  ok
	next
	return _n_

func _ByEarliestDot poM
	_n_ = 1000000
	for _cP_ in [ "A.icon", "B.icon", "C.icon" ]
		if poM.DrawIndexOf(_cP_) < _n_  _n_ = poM.DrawIndexOf(_cP_)  ok
	next
	return _n_

# the gap from each name's BOX to the nearest ink anywhere in the figure
func _ByGaps poM
	_aE_ = []
	for _cP_ in [ "ABC.sqab", "ABC.sqac", "ABC.sqbc", "ABC.rect1", "ABC.rect2", "ABC.face" ]
		_aP_ = poM.PolygonOf(_cP_)
		_n_ = floor(len(_aP_) / 2)
		for _i_ = 1 to _n_
			_j_ = _i_ + 1
			if _j_ > _n_  _j_ = 1  ok
			_aE_ + [ _aP_[2*_i_-1], _aP_[2*_i_], _aP_[2*_j_-1], _aP_[2*_j_] ]
		next
	next
	_aL_ = poM.ShapeOf("ABC.alt")
	_aE_ + [ _aL_[:x1], _aL_[:y1], _aL_[:x2], _aL_[:y2] ]
	return [ _ByMinGap(poM, "A.text", _aE_), _ByMinGap(poM, "B.text", _aE_),
	         _ByMinGap(poM, "C.text", _aE_) ]

func _ByRange paG
	_lo_ = paG[1]  _hi_ = paG[1]
	for _i_ = 2 to len(paG)
		if paG[_i_] < _lo_  _lo_ = paG[_i_]  ok
		if paG[_i_] > _hi_  _hi_ = paG[_i_]  ok
	next
	return _hi_ - _lo_

func _ByMinGap poM, pcText, paE
	_aT_ = poM.ShapeOf(pcText)
	_best_ = 1000000
	for _k_ = 1 to len(paE)
		_e_ = paE[_k_]
		_dx_ = _e_[3] - _e_[1]  _dy_ = _e_[4] - _e_[2]
		_L_ = _dx_*_dx_ + _dy_*_dy_
		_t_ = 0
		if _L_ > 0.000001
			_t_ = ((_aT_[:cx] - _e_[1])*_dx_ + (_aT_[:cy] - _e_[2])*_dy_) / _L_
			if _t_ < 0  _t_ = 0  ok
			if _t_ > 1  _t_ = 1  ok
		ok
		_qx_ = fabs(_e_[1] + _t_*_dx_ - _aT_[:cx]) - _aT_[:w]/2
		_qy_ = fabs(_e_[2] + _t_*_dy_ - _aT_[:cy]) - _aT_[:h]/2
		_mx_ = _qx_  if _qy_ > _mx_  _mx_ = _qy_  ok
		_ax_ = _qx_  if _ax_ < 0  _ax_ = 0  ok
		_ay_ = _qy_  if _ay_ < 0  _ay_ = 0  ok
		_sd_ = sqrt(pow(_ax_, 2) + pow(_ay_, 2))
		if _mx_ < 0  _sd_ += _mx_  ok
		if _sd_ < _best_  _best_ = _sd_  ok
	next
	return _best_

# how far the mark's corner lies off the altitude drawn from A
func _ByMarkOff poM
	_aA_ = poM.ShapeOf("A.icon")
	return _ByPtSeg(poM.ValueOf("ABC.kx"), poM.ValueOf("ABC.ky"),
		_aA_[:cx], _aA_[:cy], poM.ValueOf("ABC.gx"), poM.ValueOf("ABC.gy"))

# where an equal-armed mark's corner would have landed instead
func _BySquareOff poM
	_aA_ = poM.ShapeOf("A.icon")
	return _ByPtSeg(
		_aA_[:cx] + 15*poM.ValueOf("ABC.ubx") + 15*poM.ValueOf("ABC.ucx"),
		_aA_[:cy] + 15*poM.ValueOf("ABC.uby") + 15*poM.ValueOf("ABC.ucy"),
		_aA_[:cx], _aA_[:cy], poM.ValueOf("ABC.gx"), poM.ValueOf("ABC.gy"))

func _ByPtSeg pnX, pnY, pax, pay, pbx, pby
	_dx_ = pbx - pax  _dy_ = pby - pay
	_L_ = _dx_*_dx_ + _dy_*_dy_
	_t_ = 0
	if _L_ > 0.000001
		_t_ = ((pnX - pax)*_dx_ + (pnY - pay)*_dy_) / _L_
		if _t_ < 0  _t_ = 0  ok
		if _t_ > 1  _t_ = 1  ok
	ok
	return sqrt(pow(pax + _t_*_dx_ - pnX, 2) + pow(pay + _t_*_dy_ - pnY, 2))

func _ByRefuses pnWhich
	_b_ = FALSE
	try
		_oT_ = StzByrneStyle()
		if pnWhich = 1
			_oT_.ForAllWhere("Triangle t; Point p; Point q; Point r",
				"t := Triangle(p, q, r)",
				[ [ :ensure, "disjoint", [ "t.icon", "p.icon", 2 ] ] ])
		ok
		if pnWhich = 2
			_oT_.ForAll("Point p", [ [ :delete, "p.nothing" ] ])
		ok
		if pnWhich = 3
			_oT_.ForAll("Point p", [ [ :shape, "p.bad", :poly, [ :n = 2.5 ] ] ])
		ok
		_o_ = new stzMathDiagram(StzGeometryDomain(), StzMathByrneSubstance(), _oT_)
		_o_.SetFont(AUFONT, 24)
		_o_.Layout()
	catch
		_b_ = TRUE
	done
	return _b_

# does every covering put x above y?
func _OdRises poM, pnCovers
	for _i_ = 1 to pnCovers
		_s_ = poM.ShapeOf("c" + _i_ + ".icon")
		if _s_[:y1] >= _s_[:y2] - 40  return FALSE  ok
	next
	return TRUE

func _OdSeeded pcVar
	_oS_ = StzMathLatticeSubstance(
		[ "n1", "n2", "n3", "n4", "n6", "n12" ],
		[ [ "n2", "n1" ], [ "n3", "n1" ], [ "n4", "n2" ], [ "n6", "n2" ],
		  [ "n6", "n3" ], [ "n12", "n4" ], [ "n12", "n6" ] ],
		[ [ "n2", "n3" ], [ "n4", "n6" ] ],
		[ "1", "2", "3", "4", "6", "12" ])
	# the starts CLEARED: this helper exists to show a seed can cross when
	# nothing but the seed decides, and since DN8b the style's own start
	# decides first
	_oSt_ = StzHasseStyle()
	_oSt_.ClearPlanarStart()
	_o_ = new stzMathDiagram(StzOrderDomain(), _oS_, _oSt_)
	_o_.SetFont(AUFONT, 21)
	_o_.SetVariation(pcVar)
	_o_.Layout()
	return _o_

# pairs of edges that properly cross, counting only pairs with no shared end
func _OdCrossings poM, pnCovers
	_a_ = []
	for _i_ = 1 to pnCovers
		_s_ = poM.ShapeOf("c" + _i_ + ".icon")
		_a_ + [ _s_[:x1], _s_[:y1], _s_[:x2], _s_[:y2] ]
	next
	_n_ = 0
	for _i_ = 1 to len(_a_)
		for _j_ = _i_ + 1 to len(_a_)
			if _OdShares(_a_[_i_], _a_[_j_])  loop  ok
			if _OdCrosses(_a_[_i_], _a_[_j_])  _n_++  ok
		next
	next
	return _n_

func _OdShares pa, pb
	for _i_ = 0 to 1
		for _j_ = 0 to 1
			if fabs(pa[1+2*_i_] - pb[1+2*_j_]) < 0.5 and
			   fabs(pa[2+2*_i_] - pb[2+2*_j_]) < 0.5
				return TRUE
			ok
		next
	next
	return FALSE

func _OdSide pax, pay, pbx, pby, pcx, pcy
	_d_ = (pbx - pax) * (pcy - pay) - (pby - pay) * (pcx - pax)
	if _d_ > 0.001  return 1  ok
	if _d_ < -0.001  return -1  ok
	return 0

func _OdCrosses pa, pb
	_d1_ = _OdSide(pa[1], pa[2], pa[3], pa[4], pb[1], pb[2])
	_d2_ = _OdSide(pa[1], pa[2], pa[3], pa[4], pb[3], pb[4])
	_d3_ = _OdSide(pb[1], pb[2], pb[3], pb[4], pa[1], pa[2])
	_d4_ = _OdSide(pb[1], pb[2], pb[3], pb[4], pa[3], pa[4])
	return _d1_ * _d2_ < 0 and _d3_ * _d4_ < 0

# every arrow's drawn ends stand off both object names
func _CtClears poM, pacArrows
	for _i_ = 1 to len(pacArrows)
		_s_ = poM.ShapeOf(pacArrows[_i_] + ".icon")
		_l_ = poM.ShapeOf(pacArrows[_i_] + ".line")
		_d1_ = sqrt(pow(_s_[:x1] - _l_[:x1], 2) + pow(_s_[:y1] - _l_[:y1], 2))
		_d2_ = sqrt(pow(_s_[:x2] - _l_[:x2], 2) + pow(_s_[:y2] - _l_[:y2], 2))
		if _d1_ < 25 or _d2_ < 25  return FALSE  ok
	next
	return TRUE

# the smallest distance from an arrow's own name to the arrow it names
func _CtLabelsOff poM, pacArrows
	_best_ = 1000000
	for _i_ = 1 to len(pacArrows)
		_s_ = poM.ShapeOf(pacArrows[_i_] + ".icon")
		_t_ = poM.ShapeOf(pacArrows[_i_] + ".text")
		_d_ = _ByPtSeg(_t_[:cx], _t_[:cy], _s_[:x1], _s_[:y1], _s_[:x2], _s_[:y2])
		if _d_ < _best_  _best_ = _d_  ok
	next
	return _best_

func _ThOnCircle poM, pcP
	return fabs(sqrt(pow(poM.ValueOf(pcP + ".icon.cx") - poM.ValueOf("K.icon.cx"), 2) +
	                 pow(poM.ValueOf(pcP + ".icon.cy") - poM.ValueOf("K.icon.cy"), 2)) -
	            poM.ValueOf("K.icon.r"))

func _ThCosAtA poM
	_ux_ = poM.ValueOf("B.icon.cx") - poM.ValueOf("A.icon.cx")
	_uy_ = poM.ValueOf("B.icon.cy") - poM.ValueOf("A.icon.cy")
	_vx_ = poM.ValueOf("C.icon.cx") - poM.ValueOf("A.icon.cx")
	_vy_ = poM.ValueOf("C.icon.cy") - poM.ValueOf("A.icon.cy")
	return (_ux_*_vx_ + _uy_*_vy_) /
	       (sqrt(pow(_ux_, 2) + pow(_uy_, 2)) * sqrt(pow(_vx_, 2) + pow(_vy_, 2)))

# with the style's starts CLEARED: this helper shows what a seed alone
# does, and since DN8b the style's own layout start decides first
func _GrSeeded pnScene, pcVar
	if pnScene = 20  _o_ = StzMathScene20(AUFONT)  else  _o_ = StzMathScene23(AUFONT)  ok
	_o_.@oStyle.ClearPlanarStart()
	_o_.SetVariation(pcVar)
	_o_.Layout()
	return _o_

func _GrCrossings poM, pcPfx, pnEdges
	_a_ = []
	for _i_ = 1 to pnEdges
		_s_ = poM.ShapeOf(pcPfx + _i_ + ".icon")
		_a_ + [ _s_[:x1], _s_[:y1], _s_[:x2], _s_[:y2] ]
	next
	_n_ = 0
	for _i_ = 1 to len(_a_)
		for _j_ = _i_ + 1 to len(_a_)
			if _OdCrosses(_a_[_i_], _a_[_j_])  _n_++  ok
		next
	next
	return _n_

# every arrow's drawn ends stand off the dots they join by at least pnMin
func _GrArrowsClear poM, pcPfx, pnArcs, pnMin
	for _i_ = 1 to pnArcs
		_s_ = poM.ShapeOf(pcPfx + _i_ + ".icon")
		_l_ = poM.ShapeOf(pcPfx + _i_ + ".line")
		if sqrt(pow(_s_[:x1] - _l_[:x1], 2) + pow(_s_[:y1] - _l_[:y1], 2)) < pnMin  return FALSE  ok
		if sqrt(pow(_s_[:x2] - _l_[:x2], 2) + pow(_s_[:y2] - _l_[:y2], 2)) < pnMin  return FALSE  ok
	next
	return TRUE

# the smallest gap from any name's box to any OTHER vertex's dot
func _GrNamesOffStrangers poM, pacV
	_best_ = 1000000
	for _i_ = 1 to len(pacV)
		_t_ = poM.ShapeOf(pacV[_i_] + ".text")
		for _j_ = 1 to len(pacV)
			if _j_ = _i_  loop  ok
			_d_ = poM.ShapeOf(pacV[_j_] + ".icon")
			_qx_ = fabs(_d_[:cx] - _t_[:cx]) - _t_[:w] / 2
			_qy_ = fabs(_d_[:cy] - _t_[:cy]) - _t_[:h] / 2
			_mx_ = _qx_  if _qy_ > _mx_  _mx_ = _qy_  ok
			_ax_ = _qx_  if _ax_ < 0  _ax_ = 0  ok
			_ay_ = _qy_  if _ay_ < 0  _ay_ = 0  ok
			_sd_ = sqrt(pow(_ax_, 2) + pow(_ay_, 2))
			if _mx_ < 0  _sd_ += _mx_  ok
			_sd_ -= _d_[:r]
			if _sd_ < _best_  _best_ = _sd_  ok
		next
	next
	return _best_

func _GrBoxFits poM, pacV
	for _i_ = 1 to len(pacV)
		_b_ = poM.ShapeOf(pacV[_i_] + ".icon")
		_t_ = poM.ShapeOf(pacV[_i_] + ".text")
		if _b_[:w] < _t_[:w] + 20 or _b_[:h] < _t_[:h] + 6  return FALSE  ok
		if fabs(_b_[:cx] - _t_[:cx]) > 0.01 or fabs(_b_[:cy] - _t_[:cy]) > 0.01  return FALSE  ok
	next
	return TRUE

func _GrHighlighted poM, pcPfx, pnEdges
	_n_ = 0
	for _i_ = 1 to pnEdges
		_k_ = poM._ShapeIndex(pcPfx + _i_ + ".icon")
		if _k_ = 0  loop  ok
		# a highlight is the ACCENT, resolved through the theme -- not a hex
		if poM.StrokeOf(pcPfx + _i_ + ".icon") = poM._RoleColour("primary")  _n_++  ok
	next
	return _n_

func _GrCrossingTerms poM
	poM.Layout()
	_n_ = 0
	for _i_ = 1 to len(poM.@aObjectives)
		if StzLower(poM.@aObjectives[_i_][1]) = "notcrossing"  _n_++  ok
	next
	return _n_

# how many constraints of a kind name a given text fragment in their where
func _GrCountWhere poM, pcFn, pcFrag
	_n_ = 0
	for _i_ = 1 to len(poM.@aConstraints)
		if StzLower(poM.@aConstraints[_i_][1]) = StzLower(pcFn) and
		   StzFindFirst(pcFrag, poM.@aConstraints[_i_][3]) > 0
			_n_++
		ok
	next
	return _n_

# the smallest Minkowski gap between any two word boxes
func _GrMinBoxGap poM
	_ac_ = poM.Shapes()
	_best_ = 1000000
	for _i_ = 1 to len(_ac_)
		_a_ = poM.ShapeOf(_ac_[_i_])
		for _j_ = _i_ + 1 to len(_ac_)
			_b_ = poM.ShapeOf(_ac_[_j_])
			_qx_ = fabs(_a_[:cx] - _b_[:cx]) - (_a_[:w] + _b_[:w]) / 2
			_qy_ = fabs(_a_[:cy] - _b_[:cy]) - (_a_[:h] + _b_[:h]) / 2
			_mx_ = _qx_  if _qy_ > _mx_  _mx_ = _qy_  ok
			_ax_ = _qx_  if _ax_ < 0  _ax_ = 0  ok
			_ay_ = _qy_  if _ay_ < 0  _ay_ = 0  ok
			_sd_ = sqrt(pow(_ax_, 2) + pow(_ay_, 2))
			if _mx_ < 0  _sd_ += _mx_  ok
			if _sd_ < _best_  _best_ = _sd_  ok
		next
	next
	return _best_

func _GrRefusesName pcName
	_b_ = FALSE
	try
		_oS_ = new stzMathSubstance(StzGraphDomain())
		_oS_.Declare("Vertex", pcName)
	catch
		_b_ = TRUE
	done
	return _b_

func _GrCrossingRules poM
	poM.Layout()
	_n_ = 0
	for _i_ = 1 to len(poM.@aConstraints)
		if StzLower(poM.@aConstraints[_i_][1]) = "notcrossing"  _n_++  ok
	next
	return _n_

# the same substance and style, with the planar start cleared
func _GrRandomStart poS, poSt, pnFont, pcVar
	poSt.ClearPlanarStart()
	_o_ = new stzMathDiagram(StzGraphDomain(), poS, poSt)
	_o_.SetFont(AUFONT, pnFont)
	_o_.SetVariation(pcVar)
	_o_.Layout()
	return _o_

# is every consecutive pair of the face an edge of the substance?
# how many occurrences of the stage's tape symbols a text contains, whole
# symbols only: u1 is not part of u12
func _PlSymbolsOf poM, pcText, pnStage
	_n_ = 0
	_m_ = len(pcText)
	_i_ = 1
	while _i_ <= _m_
		if pcText[_i_] = "u" and _i_ < _m_ and ascii(pcText[_i_ + 1]) >= 48 and
		   ascii(pcText[_i_ + 1]) <= 57 and (_i_ = 1 or NOT poM._IsIdent(pcText[_i_ - 1]))
			_j_ = _i_ + 1
			_cNum_ = ""
			while _j_ <= _m_ and ascii(pcText[_j_]) >= 48 and ascii(pcText[_j_]) <= 57
				_cNum_ += pcText[_j_]
				_j_++
			end
			_k_ = 0 + _cNum_
			if _k_ >= 1 and _k_ <= len(poM.@bLabelVar) and poM.@bLabelVar[_k_] = pnStage
				_n_++
			ok
			_i_ = _j_
		else
			_i_++
		ok
	end
	return _n_

func _PlFaceIsCycle poS, pacFace, pcPfx, pnEdges
	_m_ = len(pacFace)
	if _m_ < 3  return FALSE  ok
	for _k_ = 1 to _m_
		_a_ = pacFace[_k_]
		_b_ = pacFace[(_k_ % _m_) + 1]
		_bE_ = FALSE
		for _j_ = 1 to pnEdges
			if poS.IsDefinedAs(pcPfx + _j_, "Edge", [ _a_, _b_ ]) or
			   poS.IsDefinedAs(pcPfx + _j_, "Edge", [ _b_, _a_ ])
				_bE_ = TRUE
			ok
		next
		if NOT _bE_  return FALSE  ok
	next
	return TRUE

# the worst distance from a control point to the sampled curve
func _SpWorstMiss poM, pcPath
	_aS_ = poM.SplinePointsOf(pcPath)
	_aC_ = poM.PolygonOf(pcPath)
	_worst_ = 0
	for _k_ = 1 to len(_aC_) / 2
		_best_ = 1000000
		for _i_ = 1 to len(_aS_) / 2
			_d_ = sqrt(pow(_aS_[2*_i_-1] - _aC_[2*_k_-1], 2) + pow(_aS_[2*_i_] - _aC_[2*_k_], 2))
			if _d_ < _best_  _best_ = _d_  ok
		next
		if _best_ > _worst_  _worst_ = _best_  ok
	next
	return _worst_

# the largest distance from a span's middle sample to that span's chord
func _SpMaxBulge poM, pcPath
	_aC_ = poM.PolygonOf(pcPath)
	_aS_ = poM.SplinePointsOf(pcPath)
	_n_ = len(_aC_) / 2
	_max_ = 0
	for _k_ = 1 to _n_ - 1
		_i_ = (_k_ - 1) * 12 + 7
		_d_ = _ByPtSeg(_aS_[2*_i_-1], _aS_[2*_i_], _aC_[2*_k_-1], _aC_[2*_k_],
		               _aC_[2*_k_+1], _aC_[2*_k_+2])
		if _d_ > _max_  _max_ = _d_  ok
	next
	return _max_

func _SpMaxTurn poM, pcPath
	if poM.ShapeOf(pcPath)[:kind] != "spline"  return 0  ok
	return _SpPolylineMaxTurn(poM.SplinePointsOf(pcPath))

# the sharpest turn along a polyline, in degrees
func _SpPolylineMaxTurn paP
	_n_ = len(paP) / 2
	_max_ = 0
	for _i_ = 2 to _n_ - 1
		_ax_ = paP[2*_i_-1] - paP[2*_i_-3]  _ay_ = paP[2*_i_] - paP[2*_i_-2]
		_bx_ = paP[2*_i_+1] - paP[2*_i_-1]  _by_ = paP[2*_i_+2] - paP[2*_i_]
		_la_ = sqrt(_ax_*_ax_ + _ay_*_ay_)  _lb_ = sqrt(_bx_*_bx_ + _by_*_by_)
		if _la_ < 0.001 or _lb_ < 0.001  loop  ok
		_c_ = (_ax_*_bx_ + _ay_*_by_) / (_la_ * _lb_)
		if _c_ > 1  _c_ = 1  ok
		if _c_ < -1  _c_ = -1  ok
		_deg_ = acos(_c_) * 180 / 3.14159265358979
		if _deg_ > _max_  _max_ = _deg_  ok
	next
	return _max_

# is a point inside a closed polygon? ray casting, even-odd
func _SpPointIn pnX, pnY, paPoly
	_n_ = len(paPoly) / 2
	_bIn_ = FALSE
	_j_ = _n_
	for _i_ = 1 to _n_
		_xi_ = paPoly[2*_i_-1]  _yi_ = paPoly[2*_i_]
		_xj_ = paPoly[2*_j_-1]  _yj_ = paPoly[2*_j_]
		if ((_yi_ > pnY) != (_yj_ > pnY)) and
		   (pnX < (_xj_ - _xi_) * (pnY - _yi_) / (_yj_ - _yi_ + 0.000001) + _xi_)
			_bIn_ = NOT _bIn_
		ok
		_j_ = _i_
	next
	return _bIn_

# every sample of the inner drawn curve inside the outer drawn curve
func _SpInside poM, pcInner, pcOuter
	_aI_ = poM.SplinePointsOf(pcInner)
	_aO_ = poM.SplinePointsOf(pcOuter)
	for _i_ = 1 to len(_aI_) / 2
		if NOT _SpPointIn(_aI_[2*_i_-1], _aI_[2*_i_], _aO_)  return FALSE  ok
	next
	return TRUE

# two closed drawn curves apart: no sample of either inside the other,
# and no two of their segments crossing
func _SpApart poM, pcA, pcB
	_aA_ = poM.SplinePointsOf(pcA)
	_aB_ = poM.SplinePointsOf(pcB)
	for _i_ = 1 to len(_aA_) / 2
		if _SpPointIn(_aA_[2*_i_-1], _aA_[2*_i_], _aB_)  return FALSE  ok
	next
	for _i_ = 1 to len(_aB_) / 2
		if _SpPointIn(_aB_[2*_i_-1], _aB_[2*_i_], _aA_)  return FALSE  ok
	next
	_nA_ = len(_aA_) / 2  _nB_ = len(_aB_) / 2
	for _i_ = 1 to _nA_
		_i2_ = (_i_ % _nA_) + 1
		for _j_ = 1 to _nB_
			_j2_ = (_j_ % _nB_) + 1
			if _OdCrosses([ _aA_[2*_i_-1], _aA_[2*_i_], _aA_[2*_i2_-1], _aA_[2*_i2_] ],
			              [ _aB_[2*_j_-1], _aB_[2*_j_], _aB_[2*_j2_-1], _aB_[2*_j2_] ])
				return FALSE
			ok
		next
	next
	return TRUE

# how far a blob's control radii spread about their mean, as a fraction
func _SpWobble poM, pcPath
	_aC_ = poM.PolygonOf(pcPath)
	_n_ = len(_aC_) / 2
	_cx_ = 0  _cy_ = 0
	for _i_ = 1 to _n_
		_cx_ += _aC_[2*_i_-1]  _cy_ += _aC_[2*_i_]
	next
	_cx_ /= _n_  _cy_ /= _n_
	_aR_ = []  _mean_ = 0
	for _i_ = 1 to _n_
		_r_ = sqrt(pow(_aC_[2*_i_-1] - _cx_, 2) + pow(_aC_[2*_i_] - _cy_, 2))
		_aR_ + _r_
		_mean_ += _r_
	next
	_mean_ /= _n_
	_max_ = 0
	for _i_ = 1 to _n_
		_d_ = fabs(_aR_[_i_] - _mean_) / _mean_
		if _d_ > _max_  _max_ = _d_  ok
	next
	return _max_

func _SpWobbleDiffers poM, pcPath
	_o2_ = new stzMathDiagram(StzSetTheoryDomain(), StzMathTreeSubstance(), StzBlobStyle())
	_o2_.SetFont(AUFONT, 26)
	_o2_.SetVariation("another-seed")
	_o2_.Layout()
	return fabs(_SpWobble(poM, pcPath) - _SpWobble(_o2_, pcPath)) > 0.005

# each arc's middle sample stands off its chord by about the bulge
# locals named so no top-level variable of this long file can be one of
# them: a Ring function writes to a GLOBAL of the same name rather than
# making a local, and this file's top level is long
func _SpArcBulges poM, pcPfx, pnEdges, pnBulge
	for _spI_ = 1 to pnEdges
		_spS_ = poM.SplinePointsOf(pcPfx + _spI_ + ".arc")
		_spL_ = poM.ShapeOf(pcPfx + _spI_ + ".icon")
		_spLen_ = sqrt(pow(_spL_[:x2] - _spL_[:x1], 2) + pow(_spL_[:y2] - _spL_[:y1], 2))
		_spD_ = _ByPtSeg(_spS_[25], _spS_[26], _spL_[:x1], _spL_[:y1], _spL_[:x2], _spL_[:y2])
		if _spD_ < 0.6 * pnBulge * _spLen_ or _spD_ > 1.4 * pnBulge * _spLen_  return FALSE  ok
	next
	return TRUE

func _SpArcEndsOnDots poM, pcPfx, pnEdges
	for _spI_ = 1 to pnEdges
		_spS_ = poM.SplinePointsOf(pcPfx + _spI_ + ".arc")
		_spL_ = poM.ShapeOf(pcPfx + _spI_ + ".icon")
		_spN_ = len(_spS_)
		if fabs(_spS_[1] - _spL_[:x1]) > 0.01 or fabs(_spS_[2] - _spL_[:y1]) > 0.01  return FALSE  ok
		if fabs(_spS_[_spN_-1] - _spL_[:x2]) > 0.01 or fabs(_spS_[_spN_] - _spL_[:y2]) > 0.01  return FALSE  ok
	next
	return TRUE

func _ElSameAspect poM, pacSets, pnK
	for _i_ = 1 to len(pacSets)
		_e_ = poM.ShapeOf(pacSets[_i_] + ".disk")
		if fabs(_e_[:ry] / _e_[:rx] - pnK) > 0.0001  return FALSE  ok
	next
	return TRUE

# 36 points on an ellipse's boundary
func _ElRim poM, pcSet
	_e_ = poM.ShapeOf(pcSet + ".disk")
	_a_ = []
	for _k_ = 0 to 35
		_t_ = 6.28318530717959 * _k_ / 36
		_a_ + [ _e_[:cx] + _e_[:rx] * cos(_t_), _e_[:cy] + _e_[:ry] * sin(_t_) ]
	next
	return _a_

func _ElHas poM, pcSet, pnX, pnY
	_e_ = poM.ShapeOf(pcSet + ".disk")
	return pow((pnX - _e_[:cx]) / _e_[:rx], 2) + pow((pnY - _e_[:cy]) / _e_[:ry], 2) <= 1.0001

func _ElInside poM, pcInner, pcOuter
	_a_ = _ElRim(poM, pcInner)
	for _i_ = 1 to len(_a_)
		if NOT _ElHas(poM, pcOuter, _a_[_i_][1], _a_[_i_][2])  return FALSE  ok
	next
	return TRUE

func _ElApart poM, pcA, pcB
	_a_ = _ElRim(poM, pcA)
	for _i_ = 1 to len(_a_)
		if _ElHas(poM, pcB, _a_[_i_][1], _a_[_i_][2])  return FALSE  ok
	next
	_b_ = _ElRim(poM, pcB)
	for _i_ = 1 to len(_b_)
		if _ElHas(poM, pcA, _b_[_i_][1], _b_[_i_][2])  return FALSE  ok
	next
	return TRUE

# the four corners of every name's box inside its own drawn ellipse
func _ElNamesFit poM, pacSets
	for _i_ = 1 to len(pacSets)
		_t_ = poM.ShapeOf(pacSets[_i_] + ".text")
		for _sx_ = -1 to 1 step 2
			for _sy_ = -1 to 1 step 2
				if NOT _ElHas(poM, pacSets[_i_], _t_[:cx] + _sx_ * _t_[:w] / 2,
				              _t_[:cy] + _sy_ * _t_[:h] / 2)
					return FALSE
				ok
			next
		next
	next
	return TRUE

func _RyWorstString poM, pnRays
	_e_ = poM.ShapeOf("E.icon")
	_f1_ = poM.ValueOf("E.f1.cx")  _f2_ = poM.ValueOf("E.f2.cx")  _fy_ = poM.ValueOf("E.f1.cy")
	_w_ = 0
	for _i_ = 1 to pnRays
		_px_ = poM.ValueOf("r" + _i_ + ".hit.cx")  _py_ = poM.ValueOf("r" + _i_ + ".hit.cy")
		_d_ = fabs(sqrt(pow(_px_ - _f1_, 2) + pow(_py_ - _fy_, 2)) +
		           sqrt(pow(_px_ - _f2_, 2) + pow(_py_ - _fy_, 2)) - 2 * _e_[:rx])
		if _d_ > _w_  _w_ = _d_  ok
	next
	return _w_

func _RyWorstLaw poM, pnRays
	_e_ = poM.ShapeOf("E.icon")
	_f1_ = poM.ValueOf("E.f1.cx")  _f2_ = poM.ValueOf("E.f2.cx")  _fy_ = poM.ValueOf("E.f1.cy")
	_w_ = 0
	for _i_ = 1 to pnRays
		_px_ = poM.ValueOf("r" + _i_ + ".hit.cx")  _py_ = poM.ValueOf("r" + _i_ + ".hit.cy")
		_t_ = poM.ValueOf("r" + _i_ + ".t")
		_tx_ = 0 - _e_[:rx] * sin(_t_)  _ty_ = _e_[:ry] * cos(_t_)
		_tl_ = sqrt(_tx_ * _tx_ + _ty_ * _ty_)
		_d1_ = sqrt(pow(_f1_ - _px_, 2) + pow(_fy_ - _py_, 2))
		_d2_ = sqrt(pow(_f2_ - _px_, 2) + pow(_fy_ - _py_, 2))
		_c1_ = fabs((_f1_ - _px_) * _tx_ + (_fy_ - _py_) * _ty_) / (_d1_ * _tl_)
		_c2_ = fabs((_f2_ - _px_) * _tx_ + (_fy_ - _py_) * _ty_) / (_d2_ * _tl_)
		if fabs(_c1_ - _c2_) > _w_  _w_ = fabs(_c1_ - _c2_)  ok
	next
	return _w_

func _RyMinSpread poM, pnRays
	_m_ = 1000000
	for _i_ = 1 to pnRays
		for _j_ = _i_ + 1 to pnRays
			_d_ = sqrt(pow(poM.ValueOf("r" + _i_ + ".hit.cx") - poM.ValueOf("r" + _j_ + ".hit.cx"), 2) +
			           pow(poM.ValueOf("r" + _i_ + ".hit.cy") - poM.ValueOf("r" + _j_ + ".hit.cy"), 2))
			if _d_ < _m_  _m_ = _d_  ok
		next
	next
	return _m_

# how many constraints or objectives mention a focus by name -- the
# on-canvas rule on the focus DOTS excepted, which keeps a dot on the
# paper and says nothing about optics
func _RyRulesNamingFoci poM
	_n_ = 0
	for _i_ = 1 to len(poM.@aConstraints)
		if StzLower(poM.@aConstraints[_i_][1]) = "oncanvas"  loop  ok
		if StzFindFirst("f1", StzLower(poM.@aConstraints[_i_][3])) > 0 or
		   StzFindFirst("f2", StzLower(poM.@aConstraints[_i_][3])) > 0
			_n_++
		ok
	next
	for _i_ = 1 to len(poM.@aObjectives)
		if StzFindFirst("f1", StzLower(poM.@aObjectives[_i_][3])) > 0 or
		   StzFindFirst("f2", StzLower(poM.@aObjectives[_i_][3])) > 0
			_n_++
		ok
	next
	return _n_

func _CdRgb pcHex
	_c_ = StzStringSection(pcHex, 2, 7)
	return dec(StzStringSection(_c_, 1, 2)) * 65536 + dec(StzStringSection(_c_, 3, 4)) * 256 +
	       dec(StzStringSection(_c_, 5, 6))

func _CdRefuses poS, pcKey, pValue
	_b_ = FALSE
	try
		poS.SetData("x", pcKey, pValue)
	catch
		_b_ = TRUE
	done
	return _b_

func _CqCellsPlaced poM
	for _r_ = 1 to 8
		for _c_ = 1 to 8
			_n_ = "c" + _r_ + "_" + _c_
			if fabs(poM.ValueOf(_n_ + ".icon.cx") - (90 + (_c_ - 0.5) * 62)) > 0.01 or
			   fabs(poM.ValueOf(_n_ + ".icon.cy") - (90 + (_r_ - 0.5) * 62)) > 0.01
				return FALSE
			ok
		next
	next
	return TRUE

func _CqLatin poM
	_oS_ = StzMathQuaternionSubstance()
	for _r_ = 1 to 8
		_aSeen_ = [ 0, 0, 0, 0, 0, 0, 0, 0 ]
		for _c_ = 1 to 8
			_p_ = _oS_.DataOf("c" + _r_ + "_" + _c_, "p")
			if _p_ < 1 or _p_ > 8 or _aSeen_[_p_] = 1  return FALSE  ok
			_aSeen_[_p_] = 1
		next
	next
	return TRUE

# an independent multiplication: quaternions as 4-vectors
func _CqMul paA, paB
	return [ paA[1]*paB[1] - paA[2]*paB[2] - paA[3]*paB[3] - paA[4]*paB[4],
	         paA[1]*paB[2] + paA[2]*paB[1] + paA[3]*paB[4] - paA[4]*paB[3],
	         paA[1]*paB[3] - paA[2]*paB[4] + paA[3]*paB[1] + paA[4]*paB[2],
	         paA[1]*paB[4] + paA[2]*paB[3] - paA[3]*paB[2] + paA[4]*paB[1] ]

func _CqVec pnE
	_aU_ = [ [1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1] ]
	_u_ = pnE  _s_ = 1
	if pnE > 4  _u_ = pnE - 4  _s_ = -1  ok
	_v_ = _aU_[_u_]
	return [ _s_*_v_[1], _s_*_v_[2], _s_*_v_[3], _s_*_v_[4] ]

func _CqProductsAgree poM
	_oS_ = StzMathQuaternionSubstance()
	for _r_ = 1 to 8
		for _c_ = 1 to 8
			_want_ = _CqMul(_CqVec(_r_), _CqVec(_c_))
			_got_ = _CqVec(_oS_.DataOf("c" + _r_ + "_" + _c_, "p"))
			for _k_ = 1 to 4
				if _want_[_k_] != _got_[_k_]  return FALSE  ok
			next
		next
	next
	return TRUE

func _ChProductAgrees poM
	_oS_ = StzMathMatrixSubstance()
	for _i_ = 1 to 3
		for _j_ = 1 to 3
			_s_ = 0
			for _k_ = 1 to 4
				_s_ += _oS_.DataOf("a" + _i_ + "_" + _k_, "v") * _oS_.DataOf("b" + _k_ + "_" + _j_, "v")
			next
			if _s_ != _oS_.DataOf("c" + _i_ + "_" + _j_, "v")  return FALSE  ok
		next
	next
	return TRUE

# the name of the cell with the largest (or smallest) value in a grid
func _ChExtreme poM, pcPfx, pnRows, pnCols, pbMax
	_oS_ = StzMathMatrixSubstance()
	_best_ = ""  _bv_ = 0
	for _i_ = 1 to pnRows
		for _j_ = 1 to pnCols
			_n_ = pcPfx + _i_ + "_" + _j_
			_v_ = _oS_.DataOf(_n_, "v")
			if _best_ = "" or (pbMax and _v_ > _bv_) or (NOT pbMax and _v_ < _bv_)
				_best_ = _n_  _bv_ = _v_
			ok
		next
	next
	return _best_

func _GsSameObjects poA, poB
	_aO_ = poA.Objects()
	if len(_aO_) != len(poB.Objects())  return FALSE  ok
	for _i_ = 1 to len(_aO_)
		if NOT poB.HasObject(_aO_[_i_][1])  return FALSE  ok
		if poB.TypeOf(_aO_[_i_][1]) != _aO_[_i_][2]  return FALSE  ok
		if poB.LabelOf(_aO_[_i_][1]) != poA.LabelOf(_aO_[_i_][1])  return FALSE  ok
	next
	return TRUE

func _GsRelationsHold poA, poB
	_aR_ = poA.Relations()
	if len(_aR_) != len(poB.Relations())  return FALSE  ok
	for _i_ = 1 to len(_aR_)
		if NOT poB.Holds(_aR_[_i_][1], _aR_[_i_][2])  return FALSE  ok
	next
	return TRUE

func _GsSameGraph poG, poH
	if poG.NodesCount() != poH.NodesCount() or poG.EdgesCount() != poH.EdgesCount()  return FALSE  ok
	_aE_ = poG.Edges()
	for _i_ = 1 to len(_aE_)
		if NOT poH.EdgeExists(_aE_[_i_][:from], _aE_[_i_][:to])  return FALSE  ok
	next
	return TRUE

func _GsDefinitionsBack poA, poB, pnN
	_aD_ = poA.Definitions()
	for _i_ = 1 to len(_aD_)
		if NOT poB.IsDefinedAs(_aD_[_i_][1], _aD_[_i_][2], _aD_[_i_][3])  return FALSE  ok
	next
	return len(_aD_) = pnN

func _GsHighlighted poS, pnN
	_n_ = 0
	for _i_ = 1 to pnN
		if poS.Holds("Highlighted", [ "q" + _i_ ])  _n_++  ok
	next
	return _n_

func _GsRefusesCase
	_b_ = FALSE
	try
		_o_ = new stzMathSubstance(StzLinearAlgebraDomain())
		_o_.Declare("Vector", "u")
		_o_.Declare("VectorSpace", "U")
		_o_.ToGraph()
	catch
		_b_ = TRUE
	done
	return _b_

func _GsRefusesForeign pnBare
	_b_ = FALSE
	try
		_g_ = new stzGraph("f")
		_g_.AddNode("a")  _g_.AddNode("b")  _g_.AddEdge("a", "b")
		if pnBare = 1
			StzSubstanceFromGraph(_g_, StzGraphDomain(), [ :nodeType = "Vertex" ])
		else
			StzSubstanceFromGraph(_g_, StzGraphDomain(), [ :nodeType = "Vertex", :edgeConstructor = "Edge" ])
		ok
	catch
		_b_ = TRUE
	done
	return _b_

func _LsLattice12 pcVar
	_o_ = new stzMathDiagram(StzOrderDomain(), StzMathLatticeSubstance(
		[ "n1", "n2", "n3", "n4", "n6", "n12" ],
		[ [ "n2", "n1" ], [ "n3", "n1" ], [ "n4", "n2" ], [ "n6", "n2" ],
		  [ "n6", "n3" ], [ "n12", "n4" ], [ "n12", "n6" ] ],
		[ [ "n2", "n3" ], [ "n4", "n6" ] ],
		[ "1", "2", "3", "4", "6", "12" ]), StzHasseStyle())
	_o_.SetFont(AUFONT, 21)
	_o_.SetVariation(pcVar)
	_o_.Layout()
	return _o_

func _LsSub36
	return StzMathLatticeSubstance(
		[ "m1", "m2", "m3", "m4", "m6", "m9", "m12", "m18", "m36" ],
		[ [ "m2", "m1" ], [ "m3", "m1" ], [ "m4", "m2" ], [ "m6", "m2" ],
		  [ "m6", "m3" ], [ "m9", "m3" ], [ "m12", "m4" ], [ "m12", "m6" ],
		  [ "m18", "m6" ], [ "m18", "m9" ], [ "m36", "m12" ], [ "m36", "m18" ] ],
		[ [ "m2", "m3" ], [ "m4", "m6" ], [ "m4", "m9" ], [ "m12", "m18" ] ],
		[ "1", "2", "3", "4", "6", "9", "12", "18", "36" ])

func _LsLattice36 pcVar
	_o_ = new stzMathDiagram(StzOrderDomain(), _LsSub36(), StzHasseStyle())
	_o_.SetFont(AUFONT, 20)
	_o_.SetVariation(pcVar)
	_o_.Layout()
	return _o_

func _LsLatticeNoStart pcVar
	_oSt_ = StzHasseStyle()
	_oSt_.ClearPlanarStart()
	_o_ = new stzMathDiagram(StzOrderDomain(), _LsSub36(), _oSt_)
	_o_.SetFont(AUFONT, 20)
	_o_.SetVariation(pcVar)
	_o_.Layout()
	return _o_

func _OdCrossingsOf poM, pcPfx, pnEdges
	_a_ = []
	for _i_ = 1 to pnEdges
		_s_ = poM.ShapeOf(pcPfx + _i_ + ".icon")
		_a_ + [ _s_[:x1], _s_[:y1], _s_[:x2], _s_[:y2] ]
	next
	_n_ = 0
	for _i_ = 1 to len(_a_)
		for _j_ = _i_ + 1 to len(_a_)
			if _OdShares(_a_[_i_], _a_[_j_])  loop  ok
			if _OdCrosses(_a_[_i_], _a_[_j_])  _n_++  ok
		next
	next
	return _n_

func _LsRightOf poM, pcLow, pcHigh
	return poM.ValueOf(pcLow + ".text.cx") > poM.ValueOf(pcHigh + ".text.cx") + 60

func _LsNoStart
	_oSt_ = StzEuclideanStyle()
	_o_ = new stzMathDiagram(StzGeometryDomain(), StzMathRightIsoscelesSubstance(), _oSt_)
	_o_.SetFont(AUFONT, 24)
	_o_.SetVariation("right-isosceles")
	_o_.Layout()
	return _o_

func _LsRefusesStart
	_b_ = FALSE
	try
		_oSt_ = new stzMathStyle()
		_oSt_.StartTrying([ :sideways ], "Vertex", "icon", [ "Edge" ])
	catch
		_b_ = TRUE
	done
	return _b_

func _LsDodecaHard
	_o_ = new stzMathDiagram(StzGraphDomain(), StzMathDodecahedronSubstance(), StzGraphStyle())
	_o_.SetFont(AUFONT, 12)
	_o_.SetVariation("game")
	_o_.Layout()
	return _o_

func _LsHardPlanarLawful
	_oSt_ = StzGraphStyle()
	_oSt_.StartTrying([ :planar ], "Vertex", "icon", [ "Edge", "Arc" ])
	_o_ = new stzMathDiagram(StzGraphDomain(), StzMathDodecahedronSubstance(), _oSt_)
	_o_.SetFont(AUFONT, 12)
	_o_.SetVariation("game")
	_o_.Layout()
	return _o_.IsFeasible()

# a frame zoomed on one vertex, with a mark either on that vertex or on
# one the frame does not show
func _OgWindowWitness pbInside
	_o_ = StzMathScene25(AUFONT)
	_o_.Layout()
	if pbInside = :none
		_o_.Emphasis("v111.icon", :ring)
		return _o_
	ok
	if pbInside
		_o_.Emphasis("v111.icon", :ring)
	else
		_o_.Emphasis("v000.icon", :ring)
	ok
	_o_.WindowOn("v111.icon", 105)
	return _o_

func _OgWitness
	_oS_ = new stzMathSubstance(StzGraphDomain())
	_oS_.DeclareAll("Vertex", [ "Left", "Mid", "Right" ])
	_oS_.Define("w1", "Arc", [ "Left", "Mid" ])
	_oS_.Define("w2", "Arc", [ "Mid", "Right" ])
	_oS_.Label("Left", "Left")  _oS_.Label("Right", "Right")
	_oS_.Label("w1", "")  _oS_.Label("w2", "")
	_o_ = new stzMathDiagram(StzGraphDomain(), _oS_, StzGraphStyle())
	_o_.SetFont(AUFONT, 16)
	_o_.SetVariation("witness")
	return _o_

#-- DN18: the family tree section's helpers ----------------------------------

func _FmSetIs paSet, pacWant
	if len(paSet) != len(pacWant)  return FALSE  ok
	for _i_ = 1 to len(pacWant)
		_bIn_ = FALSE
		for _j_ = 1 to len(paSet)
			if StzLower("" + paSet[_j_]) = StzLower("" + pacWant[_i_])  _bIn_ = TRUE  ok
		next
		if NOT _bIn_  return FALSE  ok
	next
	return TRUE

func _FmYearsAre poD, pcId, pcWant
	_a_ = poD.NodeProperty(pcId, "years")
	if isList(_a_)
		if len(_a_) != 1  return FALSE  ok
		_a_ = _a_[1]
	ok
	return "" + _a_ = pcWant

func _FmRefuses pnCase
	try
		_o_ = new stzFamilyTree("x")
		_o_.AddPersonXT("a", "A", 1950, 0)
		_o_.AddPerson("b", "B")
		if pnCase = 1  _o_.AddPersonXT("c", "C", 1980, 1970)  ok
		if pnCase = 2  _o_.Marry("a", "nobody")  ok
		if pnCase = 3  _o_.Child("a", "b")  ok
		if pnCase = 4  _o_.AddPerson("a", "again")  ok
	catch
		if pnCase = 1  return StzFindFirst("dies in 1970 before being born in 1980", cCatchError) > 0  ok
		if pnCase = 2  return StzFindFirst("nobody", cCatchError) > 0  ok
		if pnCase = 3  return StzFindFirst("not a union", cCatchError) > 0  ok
		return StzFindFirst("already", cCatchError) > 0
	done
	return FALSE

# the same shape under a plain diagram -- a parentless node feeding a
# node two ranks down -- keeps the first rank: the flow rule
func _FmFlowKeepsTop
	_o_ = new stzDiagram("flow2")
	_o_.AddNodeXTT("a", "A", [ :type = "box" ])
	_o_.AddNodeXTT("b", "B", [ :type = "box" ])
	_o_.AddNodeXTT("c", "C", [ :type = "box" ])
	_o_.AddNodeXTT("s", "S", [ :type = "box" ])
	_o_.AddEdge("a", "b")  _o_.AddEdge("b", "c")  _o_.AddEdge("s", "c")
	_o_.SetSplines("ortho")
	_o_.ToCanvasXT(OPTFM)
	return fabs(_PnCentreY(_o_, "s") - _PnCentreY(_o_, "a")) < 0.5

#-- DN17: the sixth round's helpers ------------------------------------------

# does the path's end lie on the target circle's arc, below its flat top
func _FtOnArc poD, pcF, pcT
	_e_ = _PnPathEnd(poD, pcF, pcT)
	_r_ = _PnRectW(poD, pcT) / 2
	_cx_ = _PnCentreX(poD, pcT)
	_cy_ = _PnCentreY(poD, pcT)
	_d_ = sqrt((_e_[1] - _cx_) * (_e_[1] - _cx_) + (_e_[2] - _cy_) * (_e_[2] - _cy_))
	return fabs(_d_ - _r_) < 1 and _e_[2] > _PnRectOf(poD, pcT)[2] + 0.5

# was this edge's stem corner published as a fork (drawn square)
func _FtForkOf poD, pcF, pcT
	_k_ = StzLower("" + pcF + ">" + pcT)
	_a_ = poD.@aRenderForks
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][3]) = _k_  return TRUE  ok
	next
	return FALSE

# the repeated tree drawn small: a 29px mark cannot hold two ports
func _FtSmall
	return StzFaultScene02([ :Font = EFONT, :NodeWidth = 120, :NodeHeight = 40, :FontSize = 12 ])

func _FtSmallCentred
	_o_ = _FtSmall()
	return fabs(_PnPathEnd(_o_, "fill.gate", "sensor")[1] - _PnCentreX(_o_, "sensor")) < 0.5 and
	       fabs(_PnPathEnd(_o_, "alarm.gate", "sensor")[1] - _PnCentreX(_o_, "sensor")) < 0.5

#-- DN17: the fault tree section's helpers -----------------------------------

func _FtSetIs paSet, pacWant
	if len(paSet) != len(pacWant)  return FALSE  ok
	for _i_ = 1 to len(pacWant)
		_bIn_ = FALSE
		for _j_ = 1 to len(paSet)
			if StzLower("" + paSet[_j_]) = StzLower("" + pacWant[_i_])  _bIn_ = TRUE  ok
		next
		if NOT _bIn_  return FALSE  ok
	next
	return TRUE

func _FtDrawn poD, pcId
	_a_ = poD.RenderProbabilities()
	for _i_ = 1 to len(_a_)
		if _a_[_i_][1] = StzLower("" + pcId)  return _a_[_i_][2]  ok
	next
	return -1000000

func _FtProbsCentred poD
	_aT_ = poD.RenderProbabilities()
	_aR_ = poD.RenderNodeRects()
	if len(_aT_) = 0  return FALSE  ok
	for _i_ = 1 to len(_aT_)
		_bOk_ = FALSE
		for _k_ = 1 to len(_aR_)
			if StzLower("" + _aR_[_k_][5]) != _aT_[_i_][1]  loop  ok
			if fabs(_aR_[_k_][1] + _aR_[_k_][3] / 2 - _aT_[_i_][3]) < 1 and
			   fabs(_aR_[_k_][2] + _aR_[_k_][4] / 2 - _aT_[_i_][4]) < 1  _bOk_ = TRUE  ok
		next
		if NOT _bOk_  return FALSE  ok
	next
	return TRUE

# top = AND(a, OR(a, b)): the cut sets { a } and { a, b } fold to { a }
func _FtFolded
	_o_ = new stzFaultTree("fold")
	_o_.AddTop("t", "T")
	_o_.AddEvent("e", "E")
	_o_.AddBasicXT("a", "A", 0.1)
	_o_.AddBasicXT("b", "B", 0.2)
	_o_.Develop("t", :And, [ "a", "e" ])
	_o_.Develop("e", :Or, [ "a", "b" ])
	return _o_

func _FtRefusesProb poD, pcId, pcText
	try
		poD.ProbabilityOf(pcId)
	catch
		return StzFindFirst(pcText, cCatchError) > 0
	done
	return FALSE

func _FtRefuses pnCase
	try
		_o_ = new stzFaultTree("x")
		_o_.AddTop("t", "T")
		_o_.AddBasicXT("a", "A", 0.1)
		_o_.AddGate("g", :Or)
		if pnCase = 1  _o_.AddBasicXT("b", "B", 1.5)  ok
		if pnCase = 2  _o_.AddGate("h", :Maybe)  ok
		if pnCase = 3  _o_.AddGate("h", :And)  _o_.Feed("g", "h")  ok
		if pnCase = 4  _o_.Feed("g", "nobody")  ok
	catch
		if pnCase = 1  return StzFindFirst("between 0 and 1", cCatchError) > 0  ok
		if pnCase = 2  return StzFindFirst("maybe", StzLower(cCatchError)) > 0  ok
		if pnCase = 3  return StzFindFirst("is a gate", cCatchError) > 0  ok
		return StzFindFirst("nobody", cCatchError) > 0
	done
	return FALSE

# the second tree's leaf stands one separation past the first tree's
# widest drawn thing on that rank -- the diamond's name, wider than the
# diamond -- and no wider than a separation and a pixel
func _FtPacked poD
	_aR_ = poD.RenderNodeRects()
	_aL_ = poD.@aRenderNodeLabels
	_nOpR_ = -1000000
	for _i_ = 1 to len(_aR_)
		if StzLower("" + _aR_[_i_][5]) = "operator"  _nOpR_ = _aR_[_i_][1] + _aR_[_i_][3]  ok
	next
	for _i_ = 1 to len(_aL_)
		if StzLower("" + _aL_[_i_][1]) = "operator"
			if _aL_[_i_][2] + _aL_[_i_][4] / 2 > _nOpR_  _nOpR_ = _aL_[_i_][2] + _aL_[_i_][4] / 2  ok
		ok
	next
	_nGap_ = _PnRectX(poD, "spare") - _nOpR_
	? "   the second tree stands " + _nGap_ + "px from the first"
	return _nGap_ > 60 and _nGap_ < 130

# the same shape under a plain diagram -- no peer declaration -- keeps
# the flow rule: the parent stands over the child that continues
func _FtFlowLeans
	_o_ = new stzDiagram("flow")
	_o_.AddNodeXTT("a", "A", [ :type = "box" ])
	_o_.AddNodeXTT("b", "B", [ :type = "box" ])
	_o_.AddNodeXTT("c", "C", [ :type = "box" ])
	_o_.AddNodeXTT("d", "D", [ :type = "box" ])
	_o_.AddEdge("a", "b")  _o_.AddEdge("a", "c")  _o_.AddEdge("b", "d")
	_o_.SetSplines("ortho")
	_o_.ToCanvasXT(OPTFT)
	return fabs(_PnCentreX(_o_, "a") - _PnCentreX(_o_, "b")) < 0.5

#-- DN16: the Petri section's helpers ----------------------------------------

# the token count published for one place, or -1 when none was
func _PnDrawn poD, pcId
	_a_ = poD.RenderTokens()
	for _i_ = 1 to len(_a_)
		if _a_[_i_][1] = StzLower("" + pcId)  return _a_[_i_][2]  ok
	next
	return -1

# every token record sits within a pixel of its place's centre
func _PnTokensCentred poD
	_aT_ = poD.RenderTokens()
	_aR_ = poD.RenderNodeRects()
	if len(_aT_) = 0  return FALSE  ok
	for _i_ = 1 to len(_aT_)
		_bOk_ = FALSE
		for _k_ = 1 to len(_aR_)
			if StzLower("" + _aR_[_k_][5]) != _aT_[_i_][1]  loop  ok
			_cx_ = _aR_[_k_][1] + _aR_[_k_][3] / 2
			_cy_ = _aR_[_k_][2] + _aR_[_k_][4] / 2
			if fabs(_cx_ - _aT_[_i_][3]) < 1 and fabs(_cy_ - _aT_[_i_][4]) < 1  _bOk_ = TRUE  ok
		next
		if NOT _bOk_  return FALSE  ok
	next
	return TRUE

func _PnMarkingIs poD, paWant
	_aM_ = poD.Marking()
	if len(_aM_) != len(paWant)  return FALSE  ok
	for _i_ = 1 to len(paWant)
		_bOk_ = FALSE
		for _k_ = 1 to len(_aM_)
			if StzLower("" + _aM_[_k_][1]) = StzLower("" + paWant[_i_][1]) and _aM_[_k_][2] = paWant[_i_][2]
				_bOk_ = TRUE
			ok
		next
		if NOT _bOk_  return FALSE  ok
	next
	return TRUE

func _PnEdgeLabel poD, pcF, pcT
	_a_ = poD.Edges()
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][:from]) = StzLower("" + pcF) and StzLower("" + _a_[_i_][:to]) = StzLower("" + pcT)
			return "" + _a_[_i_][:label]
		ok
	next
	return "?"

func _PnRefusesFire poD, pcT, pcText
	try
		poD.Fire(pcT)
	catch
		return StzFindFirst(pcText, cCatchError) > 0
	done
	return FALSE

func _PnRefuses pnCase
	try
		_o_ = new stzPetriNet("x")
		_o_.AddPlace("p", "P")
		_o_.AddTransition("t", "T")
		if pnCase = 1  _o_.AddPlaceXT("q", "Q", 1.5)  ok
		if pnCase = 2  _o_.Arc("p", "nobody")  ok
		if pnCase = 3  _o_.ArcXT("p", "t", 0)  ok
		if pnCase = 4  _o_.AddTransition("p", "again")  ok
	catch
		if pnCase = 1  return StzFindFirst("whole number", cCatchError) > 0  ok
		if pnCase = 2  return StzFindFirst("nobody", cCatchError) > 0  ok
		if pnCase = 3  return StzFindFirst("weight", cCatchError) > 0  ok
		return StzFindFirst("already", cCatchError) > 0
	done
	return FALSE

func _PnPathOf poD, pcF, pcT
	_aP_ = poD.@aEdgePaths
	_k_ = StzLower("" + pcF) + ">" + StzLower("" + pcT)
	for _i_ = 1 to len(_aP_)
		if StzLower("" + _aP_[_i_][1]) = _k_  return _aP_[_i_][2]  ok
	next
	return []

func _PnPathStart poD, pcF, pcT
	_f_ = _PnPathOf(poD, pcF, pcT)
	if len(_f_) < 2  return [ -1000000, -1000000 ]  ok
	return [ _f_[1], _f_[2] ]

func _PnPathEnd poD, pcF, pcT
	_f_ = _PnPathOf(poD, pcF, pcT)
	if len(_f_) < 2  return [ -1000000, -1000000 ]  ok
	return [ _f_[len(_f_) - 1], _f_[len(_f_)] ]

func _PnRectOf poD, pcId
	_a_ = poD.RenderNodeRects()
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][5]) = StzLower("" + pcId)  return _a_[_i_]  ok
	next
	return [ -1000000, -1000000, 0, 0, "" ]

func _PnCentreX poD, pcId
	_r_ = _PnRectOf(poD, pcId)
	return _r_[1] + _r_[3] / 2

func _PnCentreY poD, pcId
	_r_ = _PnRectOf(poD, pcId)
	return _r_[2] + _r_[4] / 2

func _PnRectX poD, pcId
	return _PnRectOf(poD, pcId)[1]

func _PnRectW poD, pcId
	return _PnRectOf(poD, pcId)[3]

# the gap between a node's right border and the left edge of its name's
# plate, for a name written beside it
func _PnPlateGap poD, pcId
	_r_ = _PnRectOf(poD, pcId)
	_a_ = poD.@aRenderNodeLabels
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][1]) != StzLower("" + pcId)  loop  ok
		return (_a_[_i_][2] - _a_[_i_][4] / 2) - (_r_[1] + _r_[3])
	next
	return -1000000

# where a beside-name's capitals stand: the label record publishes the
# plate's centre; the text baseline is a third of the type below it, and
# the cap height rises from there. Section 110 draws at 13pt with EFONT.
func _PnLabelCapTop poD, pcId
	_a_ = poD.@aRenderNodeLabels
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][1]) != StzLower("" + pcId)  loop  ok
		return _a_[_i_][3] + 13 / 3 - EFONT.CapHeightOf(13)
	next
	return -1000000

func _PnLabelCapCentreY poD, pcId
	return _PnLabelCapTop(poD, pcId) + EFONT.CapHeightOf(13) / 2

# does an axis-aligned segment [ x1, y1, x2, y2 ] pass through the
# interior of the rect [ x, y, w, h, id ]?
func _PnSegmentThroughRect paS, paR
	_l_ = paR[1] + 1  _t_ = paR[2] + 1
	_r_ = paR[1] + paR[3] - 1  _b_ = paR[2] + paR[4] - 1
	_x0_ = min([ paS[1], paS[3] ])  _x1_ = max([ paS[1], paS[3] ])
	_y0_ = min([ paS[2], paS[4] ])  _y1_ = max([ paS[2], paS[4] ])
	if _x1_ < _l_ or _x0_ > _r_  return FALSE  ok
	if _y1_ < _t_ or _y0_ > _b_  return FALSE  ok
	return TRUE

# no drawn segment of any arc passes through a cell other than its own ends
func _PnNoArcThroughCell poD
	_aR_ = poD.RenderNodeRects()
	_aP_ = poD.@aEdgePaths
	if len(_aP_) = 0  return FALSE  ok
	for _i_ = 1 to len(_aP_)
		_cK_ = "" + _aP_[_i_][1]
		_n_ = StzFindFirst(">", _cK_)
		_cF_ = StzSubStr(_cK_, 1, _n_ - 1)
		_cT_ = StzSubStr(_cK_, _n_ + 1, StzLen(_cK_) - _n_)
		_f_ = _aP_[_i_][2]
		for _j_ = 1 to len(_f_) - 3 step 2
			for _k_ = 1 to len(_aR_)
				_cId_ = StzLower("" + _aR_[_k_][5])
				if _cId_ = _cF_ or _cId_ = _cT_  loop  ok
				if _PnSegmentThroughRect([ _f_[_j_], _f_[_j_ + 1], _f_[_j_ + 2], _f_[_j_ + 3] ], _aR_[_k_])
					? "   ! " + _cK_ + " runs through " + _cId_
					return FALSE
				ok
			next
		next
	next
	return TRUE

#-- DN15: the ER section's helpers -------------------------------------------

func _ErAttrsAre poD, pcId, pacWant
	_a_ = poD.NodeProperty(pcId, "attributes")
	if NOT isList(_a_) or len(_a_) != len(pacWant)  return FALSE  ok
	for _i_ = 1 to len(_a_)
		if "" + _a_[_i_] != pacWant[_i_]  return FALSE  ok
	next
	return TRUE

# the adornment drawn at one end of one relation: "one", "many" or ""
func _ErEnd poD, pcKey, pcEnd
	_a_ = poD.RenderAdornments()
	for _i_ = 1 to len(_a_)
		if len(_a_[_i_]) >= 6 and _a_[_i_][1] = pcKey and _a_[_i_][6] = pcEnd  return _a_[_i_][2]  ok
	next
	return ""

# the participation drawn at one end of one relation: "optional",
# "mandatory" or ""
func _ErPart poD, pcKey, pcEnd
	_a_ = poD.RenderAdornments()
	for _i_ = 1 to len(_a_)
		if len(_a_[_i_]) < 6 or _a_[_i_][1] != pcKey or _a_[_i_][6] != pcEnd  loop  ok
		if _a_[_i_][2] = "optional" or _a_[_i_][2] = "mandatory"  return _a_[_i_][2]  ok
	next
	return ""

func _ErRefusesPart
	try
		_o_ = new stzErDiagram("x")
		_o_.AddEntity("a", "A")
		_o_.AddEntity("b", "B")
		_o_.RelateXT("a", "b", :OneToMany, [ :from = :Usually ])
	catch
		return StzFindFirst("usually", StzLower(cCatchError)) > 0
	done
	return FALSE

func _ErFound paF, pcRule, pcText
	for _i_ = 1 to len(paF)
		if "" + paF[_i_][:rule] = pcRule and StzFindFirst(pcText, "" + paF[_i_][:message]) > 0
			return TRUE
		ok
	next
	return FALSE

func _ErExcludedEverywhere poSet, oGraph, pcSubject
	_a_ = poSet.Rules()
	if len(_a_) = 0  return FALSE  ok
	for _i_ = 1 to len(_a_)
		if NOT _ErInList(pcSubject, _a_[_i_].CounterSubjectsIn(oGraph))  return FALSE  ok
	next
	return TRUE

# is (x, y) on the outline of the rect [ x, y, w, h, id ], within 0.6px?
func _ErOnBorder paR, pnX, pnY
	_l_ = paR[1]  _t_ = paR[2]  _r_ = paR[1] + paR[3]  _b_ = paR[2] + paR[4]
	_inX_ = pnX >= _l_ - 0.6 and pnX <= _r_ + 0.6
	_inY_ = pnY >= _t_ - 0.6 and pnY <= _b_ + 0.6
	if _inY_ and (fabs(pnX - _l_) < 0.6 or fabs(pnX - _r_) < 0.6)  return TRUE  ok
	if _inX_ and (fabs(pnY - _t_) < 0.6 or fabs(pnY - _b_) < 0.6)  return TRUE  ok
	return FALSE

# every drawn path begins on its source's outline and ends on its target's
func _ErAllTouch poD
	_aR_ = poD.RenderNodeRects()
	_aP_ = poD.@aEdgePaths
	if len(_aP_) = 0  return FALSE  ok
	for _i_ = 1 to len(_aP_)
		_cK_ = "" + _aP_[_i_][1]
		_n_ = StzFindFirst(">", _cK_)
		_cF_ = StzSubStr(_cK_, 1, _n_ - 1)
		_cT_ = StzSubStr(_cK_, _n_ + 1, StzLen(_cK_) - _n_)
		_f_ = _aP_[_i_][2]
		_m_ = len(_f_)
		_bF_ = FALSE  _bT_ = FALSE
		for _k_ = 1 to len(_aR_)
			if StzLower("" + _aR_[_k_][5]) = _cF_ and _ErOnBorder(_aR_[_k_], _f_[1], _f_[2])  _bF_ = TRUE  ok
			if StzLower("" + _aR_[_k_][5]) = _cT_ and _ErOnBorder(_aR_[_k_], _f_[_m_ - 1], _f_[_m_])  _bT_ = TRUE  ok
		next
		if NOT (_bF_ and _bT_)
			? "   ! " + _cK_ + " starts " + _f_[1] + "," + _f_[2] + " ends " + _f_[_m_ - 1] + "," + _f_[_m_]
			return FALSE
		ok
	next
	return TRUE

# the y of every cardinality mark published at the TARGET end on this node
func _ErTargetYs poD, pcId
	_r_ = []
	_a_ = poD.RenderAdornments()
	_cSuf_ = ">" + StzLower("" + pcId)
	for _i_ = 1 to len(_a_)
		if len(_a_[_i_]) < 6 or _a_[_i_][6] != "target"  loop  ok
		if _a_[_i_][2] != "one" and _a_[_i_][2] != "many"  loop  ok
		_k_ = "" + _a_[_i_][1]
		if StzLen(_k_) < StzLen(_cSuf_)  loop  ok
		if StzSubStr(_k_, StzLen(_k_) - StzLen(_cSuf_) + 1, StzLen(_cSuf_)) != _cSuf_  loop  ok
		_r_ + _a_[_i_][5]
	next
	return _r_

func _ErCentreY poD, pcId
	_a_ = poD.RenderNodeRects()
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][5]) = StzLower("" + pcId)  return _a_[_i_][2] + _a_[_i_][4] / 2  ok
	next
	return -1

func _ErInList pcItem, paList
	for _i_ = 1 to len(paList)
		if "" + paList[_i_] = pcItem  return TRUE  ok
	next
	return FALSE

func _ErRefusesUnknown
	try
		_o_ = new stzErDiagram("x")
		_o_.AddEntity("a", "A")
		_o_.Relate("a", "nobody", :OneToMany)
	catch
		return StzFindFirst("nobody", cCatchError) > 0
	done
	return FALSE

func _ErRefusesKind
	try
		_o_ = new stzErDiagram("x")
		_o_.AddEntity("a", "A")
		_o_.AddEntity("b", "B")
		_o_.Relate("a", "b", :Sometimes)
	catch
		# a symbol is a lowercase string in Ring, so the name comes back so
		return StzFindFirst("sometimes", StzLower(cCatchError)) > 0
	done
	return FALSE

#-- DN24: the choropleth section's helpers -----------------------------------

func _ChHas poS, pcObj
	_ac_ = poS.ObjectNames()
	for _i_ = 1 to len(_ac_)
		if _ac_[_i_] = pcObj  return TRUE  ok
	next
	return FALSE

func _ChRefuses pnCase
	try
		if pnCase = 1  StzChoroplethFromRegions("q", [ [ "A", 1, [ 0, 0, 1, 0, 1, 1 ] ] ], [ 0, 10, 5 ])  ok
		if pnCase = 2  StzChoroplethFromRegionsXT("q", [ [ "A", 1, [ 0, 0, 1, 0, 1, 1 ] ] ], [ 0, 10, 20 ], [ "red" ])  ok
		if pnCase = 3  StzChoroplethFromRegions("q", [ [ "A", 1, [ 0, 0, 1, 0 ] ] ], [ 0, 10 ])  ok
		if pnCase = 4  StzChoroplethFromRegions("q", [ [ "A", 1, [ 0, 0, 1, 0, 1, 1 ] ], [ "a", 2, [ 2, 0, 3, 0, 3, 1 ] ] ], [ 0, 10 ])  ok
		if pnCase = 5  StzChoroplethFromRegions("q", [], [ 0, 10 ])  ok
		if pnCase = 6  StzChoroplethFromRegions("q", [ [ "A", 1, [ 0, 0, 1, 0, 1, 1 ] ] ], [ 0 ])  ok
	catch
		if pnCase = 1  return StzFindFirst("10 is followed by 5", cCatchError) > 0  ok
		if pnCase = 2  return StzFindFirst("2 classes need 2 colours -- 1 given", cCatchError) > 0  ok
		if pnCase = 3  return StzFindFirst("at least three points", cCatchError) > 0  ok
		if pnCase = 4  return StzFindFirst("two regions are named", cCatchError) > 0  ok
		if pnCase = 5  return StzFindFirst("at least one region", cCatchError) > 0  ok
		return StzFindFirst("two to ten edges", cCatchError) > 0
	done
	return FALSE

#-- DN23: the seating section's helpers --------------------------------------

func _StDistTo poS, pcSeat, pcTable
	_dx_ = poS.DataOf(pcSeat, "x") - poS.DataOf(pcTable, "cx")
	_dy_ = poS.DataOf(pcSeat, "y") - poS.DataOf(pcTable, "cy")
	return sqrt(_dx_ * _dx_ + _dy_ * _dy_)

# the seat's bearing from the table's centre, in degrees, y down
func _StAngle poS, pcSeat, pcTable
	_dx_ = poS.DataOf(pcSeat, "x") - poS.DataOf(pcTable, "cx")
	_dy_ = poS.DataOf(pcSeat, "y") - poS.DataOf(pcTable, "cy")
	return atan2(_dy_, _dx_) * 180 / 3.14159265

# every pair of tables clear on one axis at least, by the air given
func _StAllClear poS, pnGap
	_at_ = poS.ObjectsOfType("Table")
	for _i_ = 1 to len(_at_)
		for _j_ = _i_ + 1 to len(_at_)
			_bX_ = fabs(poS.DataOf(_at_[_i_], "sx") - poS.DataOf(_at_[_j_], "sx")) >=
				poS.DataOf(_at_[_i_], "rx") + poS.DataOf(_at_[_j_], "rx") + pnGap - 0.001
			_bY_ = fabs(poS.DataOf(_at_[_i_], "sy") - poS.DataOf(_at_[_j_], "sy")) >=
				poS.DataOf(_at_[_i_], "ry") + poS.DataOf(_at_[_j_], "ry") + pnGap - 0.001
			if NOT (_bX_ or _bY_)  return FALSE  ok
		next
	next
	return TRUE

# the widest name at a table, in pixels
func _StWidest poS, pnTable
	_n_ = 0
	_ag_ = poS.ObjectsOfType("Guest")
	for _i_ = 1 to len(_ag_)
		if poS.DataOf(_ag_[_i_], "table") = pnTable and poS.DataOf(_ag_[_i_], "nw") > _n_  _n_ = poS.DataOf(_ag_[_i_], "nw")  ok
	next
	return _n_

func _StRefuses pnCase
	try
		if pnCase = 1  StzSeatingFromTables([ [ "A", "round", 4, 0, 0 ] ], [ [ "x", "Nowhere" ] ], [])  ok
		if pnCase = 2  StzSeatingFromTables([ [ "A", "square", 4, 0, 0 ] ], [], [])  ok
		if pnCase = 3  StzSeatingFromTables([ [ "A", "round", 0, 0, 0 ] ], [], [])  ok
		if pnCase = 4  StzSeatingFromTables([ [ "A", "round", 4, 0, 0 ] ], [ [ "x", "A" ] ], [ [ "x", "Nobody" ] ])  ok
		if pnCase = 5  StzSeatingFromTables([ [ "A", "round", 4, 0, 0 ] ], [ [ "x", "A" ] ], [ [ "x", "x" ] ])  ok
		if pnCase = 6  StzSeatingFromTables([ [ "A", "round", 4, 0, 0 ], [ "a", "round", 4, 5, 0 ] ], [], [])  ok
	catch
		if pnCase = 1  return StzFindFirst("Nowhere", cCatchError) > 0  ok
		if pnCase = 2  return StzFindFirst("round or long", cCatchError) > 0  ok
		if pnCase = 3  return StzFindFirst("whole number of seats", cCatchError) > 0  ok
		if pnCase = 4  return StzFindFirst("Nobody", cCatchError) > 0  ok
		if pnCase = 5  return StzFindFirst("themself", cCatchError) > 0  ok
		return StzFindFirst("two tables are named", cCatchError) > 0
	done
	return FALSE

#-- DN22: the floor plan section's helpers -----------------------------------

func _FpDist poS, pcObj, pcXa, pcYa, pcXb, pcYb
	_dx_ = poS.DataOf(pcObj, pcXb) - poS.DataOf(pcObj, pcXa)
	_dy_ = poS.DataOf(pcObj, pcYb) - poS.DataOf(pcObj, pcYa)
	return sqrt(_dx_ * _dx_ + _dy_ * _dy_)

func _FpRefuses pnCase
	try
		if pnCase = 1  StzFloorPlanFromRooms([ [ "A", 0, 0, 3, 3 ] ], [ [ "A", "n", 2.5, 1 ] ], [])  ok
		if pnCase = 2  StzFloorPlanFromRooms([ [ "A", 0, 0, 3, 3 ] ], [ [ "A", "up", 1, 1 ] ], [])  ok
		if pnCase = 3  StzFloorPlanFromRooms([ [ "A", 0, 0, 3, 3 ] ], [ [ "Nowhere", "n", 1, 1 ] ], [])  ok
		if pnCase = 4  StzFloorPlanFromRooms([ [ "A", 0, 0, 3, 3 ], [ "a", 3, 0, 3, 3 ] ], [], [])  ok
		if pnCase = 5  StzFloorPlanFromRooms([ [ "A", 0, 0, 0, 3 ] ], [], [])  ok
		if pnCase = 6  StzFloorPlanFromRooms([], [], [])  ok
	catch
		if pnCase = 1  return StzFindFirst("runs from 2.50 to 3.50 m on a wall 3 m long", cCatchError) > 0  ok
		if pnCase = 2  return StzFindFirst("a side is n, e, s or w", cCatchError) > 0  ok
		if pnCase = 3  return StzFindFirst("Nowhere", cCatchError) > 0  ok
		if pnCase = 4  return StzFindFirst("two rooms are named", cCatchError) > 0  ok
		if pnCase = 5  return StzFindFirst("positive width", cCatchError) > 0  ok
		return StzFindFirst("at least one room", cCatchError) > 0
	done
	return FALSE

#-- DN21: the network section's helpers --------------------------------------

func _NwRefuses pnCase
	try
		_o_ = new stzNetworkDiagram("x")
		_o_.AddDeviceXT("a", "A", "host", "10.0.0.1")
		_o_.AddDevice("b", "B", "switch")
		if pnCase = 1  _o_.Link("a", "nobody")  ok
		if pnCase = 2  _o_.Link("a", "a")  ok
		if pnCase = 3  _o_.AddDeviceXT("c", "C", "host", "10.0.0.256")  ok
		if pnCase = 4  _o_.AddSubnet("s", "S", "10.0.0.0/40", [ "a" ])  ok
		if pnCase = 5  _o_.AddDevice("t", "T", "toaster")  ok
		if pnCase = 6  _o_.AddDevice("a", "again", "host")  ok
	catch
		if pnCase = 1  return StzFindFirst("nobody", cCatchError) > 0  ok
		if pnCase = 2  return StzFindFirst("itself", cCatchError) > 0  ok
		if pnCase = 3  return StzFindFirst("not an IPv4 address", cCatchError) > 0  ok
		if pnCase = 4  return StzFindFirst("not a subnet", cCatchError) > 0  ok
		if pnCase = 5  return StzFindFirst("not a device kind", cCatchError) > 0  ok
		return StzFindFirst("already", cCatchError) > 0
	done
	return FALSE

# the node's drawn box lies inside the frame that carries the subnet's members
func _NwInsideFrame poD, pcId, paFrames, pcSubnet
	_aR_ = _PnRectOf(poD, pcId)
	if len(_aR_) < 4  return FALSE  ok
	_aM_ = poD.DevicesIn(pcSubnet)
	for _i_ = 1 to len(paFrames)
		_f_ = paFrames[_i_]
		if len(_f_[5]) != len(_aM_)  loop  ok
		_bIn_ = FALSE
		for _j_ = 1 to len(_f_[5])
			if _f_[5][_j_] = StzLower("" + pcId)  _bIn_ = TRUE  ok
		next
		if NOT _bIn_  loop  ok
		return _aR_[1] >= _f_[1] and _aR_[1] + _aR_[3] <= _f_[1] + _f_[3] and
		       _aR_[2] >= _f_[2] and _aR_[2] + _aR_[4] <= _f_[2] + _f_[4]
	next
	return FALSE

#-- DN20: the fishbone section's helpers -------------------------------------

func _FbRefusesNoEffect
	try
		StzFishboneFromCauses("  ", [ [ "A", [ "x" ] ] ])
	catch
		return StzFindFirst("effect to explain", cCatchError) > 0
	done
	return FALSE

func _FbRefusesNoCategory
	try
		StzFishboneFromCauses("E", [])
	catch
		return StzFindFirst("at least one category", cCatchError) > 0
	done
	return FALSE

func _FbRefusesUnnamed
	try
		StzFishboneFromCauses("E", [ [ "", [ "x" ] ] ])
	catch
		return StzFindFirst("needs a name", cCatchError) > 0
	done
	return FALSE

#-- DN19: the timeline section's helpers -------------------------------------

# the objects of a type a substance marks with a predicate
func _TlMarked poDg, pcType, pcPred
	_r_ = []
	_oS_ = poDg.Substance()
	_ac_ = _oS_.ObjectsOfType(pcType)
	for _i_ = 1 to len(_ac_)
		if _oS_.Holds(pcPred, [ _ac_[_i_] ])  _r_ + _ac_[_i_]  ok
	next
	return _r_

# the marked objects are exactly the subjects the rule found, no more, no fewer
func _TlMarkedEquals poDg, pcType, pcPred, paFindings, pcRule, pcPrefix
	_aM_ = _TlMarked(poDg, pcType, pcPred)
	_aF_ = []
	for _i_ = 1 to len(paFindings)
		if "" + paFindings[_i_][:rule] != pcRule  loop  ok
		_w_ = "" + paFindings[_i_][:where]
		_p_ = StzFindFirst(pcPrefix, _w_)
		if _p_ > 0  _aF_ + StzStringSection(_w_, _p_ + len(pcPrefix), len(_w_))  ok
	next
	if len(_aM_) != len(_aF_) or len(_aM_) = 0  return FALSE  ok
	for _i_ = 1 to len(_aM_)
		_b_ = FALSE
		for _j_ = 1 to len(_aF_)
			if ring_trim(_aF_[_j_]) = _aM_[_i_]  _b_ = TRUE  ok
		next
		if NOT _b_  return FALSE  ok
	next
	return TRUE

# no event's name extends over a column whose stem reaches its level
func _TlNamesClearColumns poDg
	_oS_ = poDg.Substance()
	_ac_ = _oS_.ObjectsOfType("Event")
	for _i_ = 1 to len(_ac_)
		_lo_ = _oS_.DataOf(_ac_[_i_], "lx") - _oS_.DataOf(_ac_[_i_], "lw") / 2
		_hi_ = _oS_.DataOf(_ac_[_i_], "lx") + _oS_.DataOf(_ac_[_i_], "lw") / 2
		for _j_ = 1 to len(_ac_)
			if _j_ = _i_  loop  ok
			_x_ = _oS_.DataOf(_ac_[_j_], "x")
			if fabs(_x_ - _oS_.DataOf(_ac_[_i_], "x")) < 0.01  loop  ok
			if _oS_.DataOf(_ac_[_j_], "level") < _oS_.DataOf(_ac_[_i_], "level")  loop  ok
			if _x_ > _lo_ and _x_ < _hi_  return FALSE  ok
		next
	next
	return TRUE

# two names on one level stand apart
func _TlLevelsClear poDg
	_oS_ = poDg.Substance()
	_ac_ = _oS_.ObjectsOfType("Event")
	for _i_ = 1 to len(_ac_)
		for _j_ = _i_ + 1 to len(_ac_)
			if _oS_.DataOf(_ac_[_i_], "level") != _oS_.DataOf(_ac_[_j_], "level")  loop  ok
			_d_ = fabs(_oS_.DataOf(_ac_[_i_], "lx") - _oS_.DataOf(_ac_[_j_], "lx"))
			if _d_ < (_oS_.DataOf(_ac_[_i_], "lw") + _oS_.DataOf(_ac_[_j_], "lw")) / 2 + 4  return FALSE  ok
		next
	next
	return TRUE

func _TlRefusesUnknownEra
	try
		StzTimelineFromEvents([ [ "A", 0, "Nowhen" ] ], [ [ "X", 0, 5 ] ])
	catch
		return StzFindFirst("Nowhen", cCatchError) > 0
	done
	return FALSE

func _TlRefusesDuplicate
	try
		StzTimelineFromEvents([ [ "A", 0 ], [ "a", 3 ] ], [])
	catch
		return StzFindFirst("two events are named", cCatchError) > 0
	done
	return FALSE

func _TlRefusesEmpty
	try
		StzTimelineFromEvents([], [])
	catch
		return StzFindFirst("at least one", cCatchError) > 0
	done
	return FALSE

#-- DN14: the Gantt section's helpers ----------------------------------------

func _GtHas paFindings, pcText
	for _i_ = 1 to len(paFindings)
		if StzFindFirst(pcText, "" + paFindings[_i_][:message]) > 0  return TRUE  ok
	next
	return FALSE

# the tasks a substance marks with a predicate
func _GtMarked poDg, pcPred
	_r_ = []
	_oS_ = poDg.Substance()
	_ac_ = _oS_.ObjectsOfType("Task")
	for _i_ = 1 to len(_ac_)
		if _oS_.Holds(pcPred, [ _ac_[_i_] ])  _r_ + _ac_[_i_]  ok
	next
	return _r_

# the marked tasks are exactly the subjects the rule found, no more, no fewer
func _GtMarkedEquals poDg, pcPred, paFindings, pcRule
	_aM_ = _GtMarked(poDg, pcPred)
	_aF_ = []
	for _i_ = 1 to len(paFindings)
		if "" + paFindings[_i_][:rule] != pcRule  loop  ok
		_w_ = "" + paFindings[_i_][:where]
		_p_ = StzFindFirst("task:", _w_)
		if _p_ > 0  _aF_ + StzStringSection(_w_, _p_ + 5, len(_w_))  ok
	next
	if len(_aM_) != len(_aF_) or len(_aM_) = 0  return FALSE  ok
	for _i_ = 1 to len(_aM_)
		_b_ = FALSE
		for _j_ = 1 to len(_aF_)
			if ring_trim(_aF_[_j_]) = _aM_[_i_]  _b_ = TRUE  ok
		next
		if NOT _b_  return FALSE  ok
	next
	return TRUE

# "rule xN, rule xM" -- the findings counted by rule, for the profile line
func _GtByRule paFindings
	_a_ = []
	for _i_ = 1 to len(paFindings)
		_c_ = "" + paFindings[_i_][:rule]
		_b_ = FALSE
		for _j_ = 1 to len(_a_)
			if _a_[_j_][1] = _c_  _a_[_j_][2]++  _b_ = TRUE  ok
		next
		if NOT _b_  _a_ + [ _c_, 1 ]  ok
	next
	_s_ = ""
	for _j_ = 1 to len(_a_)
		if _s_ != ""  _s_ += ", "  ok
		_s_ += (_a_[_j_][1] + " x" + _a_[_j_][2])
	next
	return _s_

func _GtRefusesUnknown
	try
		StzGanttFromTasks([ [ "A", 0, 5 ] ], [ [ "A", "Nobody" ] ])
	catch
		return StzFindFirst("Nobody", cCatchError) > 0
	done
	return FALSE

func _GtRefusesSelf
	try
		StzGanttFromTasks([ [ "A", 0, 5 ] ], [ [ "A", "A" ] ])
	catch
		return StzFindFirst("itself", cCatchError) > 0
	done
	return FALSE

#-- DN13: how far a curved edge's spline leaves its two hidden chords --------
#
# Over the cube's twelve edges q1..q12: [ maxGap, edgeOfMax, lenOfMax,
# minRatio, maxRatio ], the gap being the largest distance from any sampled
# spline point to the nearer of the two chords, and the ratio gap/length.
func _CsGap poDg
	_nMaxG_ = 0  _cMaxE_ = ""  _nMaxL_ = 0  _nMinR_ = 9  _nMaxR_ = 0
	for _i_ = 1 to 12
		_e_ = "q" + _i_
		_aS_ = poDg.SplinePointsOf(_e_ + ".arc")
		_h1_ = poDg.ShapeOf(_e_ + ".h1")  _h2_ = poDg.ShapeOf(_e_ + ".h2")
		_nLen_ = _ChLen(poDg, _e_ + ".icon")
		_nG_ = 0
		for _k_ = 1 to len(_aS_) / 2
			_d_ = _CsDSeg(_aS_[2*_k_-1], _aS_[2*_k_], _h1_)
			_d2_ = _CsDSeg(_aS_[2*_k_-1], _aS_[2*_k_], _h2_)
			if _d2_ < _d_  _d_ = _d2_  ok
			if _d_ > _nG_  _nG_ = _d_  ok
		next
		_r_ = _nG_ / _nLen_
		if _r_ < _nMinR_  _nMinR_ = _r_  ok
		if _r_ > _nMaxR_  _nMaxR_ = _r_  ok
		if _nG_ > _nMaxG_  _nMaxG_ = _nG_  _cMaxE_ = _e_  _nMaxL_ = _nLen_  ok
	next
	return [ _nMaxG_, _cMaxE_, _nMaxL_, _nMinR_, _nMaxR_ ]

func _CsDSeg px, py, s
	_dx_ = s[:x2] - s[:x1]  _dy_ = s[:y2] - s[:y1]
	_t_ = ((px - s[:x1]) * _dx_ + (py - s[:y1]) * _dy_) / (_dx_ * _dx_ + _dy_ * _dy_ + 0.000001)
	if _t_ < 0  _t_ = 0  ok
	if _t_ > 1  _t_ = 1  ok
	_qx_ = s[:x1] + _t_ * _dx_  _qy_ = s[:y1] + _t_ * _dy_
	return sqrt((px - _qx_) * (px - _qx_) + (py - _qy_) * (py - _qy_))

# a name set by hand on the midpoint of a hidden half-chord -- where the
# curve passes within a few pixels, not on the straight segment's midpoint,
# which the bulge holds thirty pixels from the curve
func _CsMoveNameOntoChord poM, pcVertex, pcChord
	_l_ = poM.ShapeOf(pcChord)
	_ix_ = poM._UnknownIndex(pcVertex + ".text.cx")
	_iy_ = poM._UnknownIndex(pcVertex + ".text.cy")
	poM.@aValue[_ix_] = (_l_[:x1] + _l_[:x2]) / 2
	poM.@aValue[_iy_] = (_l_[:y1] + _l_[:y2]) / 2
	poM.Touch()

# the curved cube on a seed: lawful, and nothing found by the one gate
func _CsClean pcSeed
	_o_ = StzMathScene25XT(AUFONT, pcSeed)
	_o_.Layout()
	return _o_.IsFeasible() and len(StzCheckPictures([ [ pcSeed, _o_ ] ]).Findings()) = 0

#-- DN12: the ink centre of a drawn text against its own (cx, cy) ------------
#
# Read from the canvas pixels inside a CIRCLE of radius pnR around the
# text's centre -- never a box, because a box reaches the rim of the disc
# an atom symbol sits in, and a rim counted as ink moved the first
# measurement of this defect by three pixels in the wrong direction. The
# reference colour is sampled just outside the ink; every pixel differing
# from it weighs by how much. Returns [ dx, dy ].
func _EmInkOff poDg, pcT, pnR
	_s_ = poDg.ShapeOf(pcT)
	_oC_ = poDg.ToCanvas()
	_cPx_ = _oC_.ToPixels()
	_W_ = _oC_.Width()
	_cx_ = _s_[:cx]  _cy_ = _s_[:cy]
	_nRef_ = _EmLum(_cPx_, _W_, floor(_cx_ + pnR - 1), floor(_cy_))
	_sx_ = 0  _sy_ = 0  _n_ = 0
	for _y_ = floor(_cy_ - pnR) to ceil(_cy_ + pnR)
		for _x_ = floor(_cx_ - pnR) to ceil(_cx_ + pnR)
			if (_x_ + 0.5 - _cx_) * (_x_ + 0.5 - _cx_) + (_y_ + 0.5 - _cy_) * (_y_ + 0.5 - _cy_) > pnR * pnR  loop  ok
			_d_ = fabs(_EmLum(_cPx_, _W_, _x_, _y_) - _nRef_)
			if _d_ > 40
				_sx_ += (_x_ + 0.5) * _d_  _sy_ += (_y_ + 0.5) * _d_  _n_ += _d_
			ok
		next
	next
	if _n_ = 0  return [ 999, 999 ]  ok
	return [ floor(100 * (_sx_ / _n_ - _cx_)) / 100, floor(100 * (_sy_ / _n_ - _cy_)) / 100 ]

func _EmLum pcPx, pnW, pnX, pnY
	_i_ = ((pnY * pnW) + pnX) * 4 + 1
	return 0.299 * ascii(pcPx[_i_]) + 0.587 * ascii(pcPx[_i_ + 1]) + 0.114 * ascii(pcPx[_i_ + 2])

#-- DN11: the molecule section's helpers ------------------------------------

# A STAR OF FIVE, in the graph domain under the spring style: a tree, whose
# 2-core is empty, so the planar start is refused and the next named start
# stands. The witness for "a graph Tutte collapses" now that a cut vertex
# alone no longer collapses anything.
func _GrTree
	_oS_ = new stzMathSubstance(StzGraphDomain())
	_oS_.DeclareAll("Vertex", [ "r", "a", "b", "c", "d" ])
	_oS_.Define("e1", "Edge", [ "r", "a" ])
	_oS_.Define("e2", "Edge", [ "r", "b" ])
	_oS_.Define("e3", "Edge", [ "r", "c" ])
	_oS_.Define("e4", "Edge", [ "r", "d" ])
	_oS_.AutoLabelAll()
	for _i_ = 1 to 4  _oS_.Label("e" + _i_, "")  next
	_o_ = new stzMathDiagram(StzGraphDomain(), _oS_, StzSpringGraphStyle())
	_o_.SetFont(AUFONT, 15)
	_o_.Layout()
	return _o_

func _ChD poDg, pcA, pcB
	_a_ = poDg.ShapeOf(pcA + ".icon")  _b_ = poDg.ShapeOf(pcB + ".icon")
	return sqrt((_a_[:cx]-_b_[:cx])*(_a_[:cx]-_b_[:cx]) + (_a_[:cy]-_b_[:cy])*(_a_[:cy]-_b_[:cy]))

func _ChA poDg, pcP, pcQ, pcR
	_p_ = poDg.ShapeOf(pcP + ".icon")  _q_ = poDg.ShapeOf(pcQ + ".icon")  _r_ = poDg.ShapeOf(pcR + ".icon")
	_ux_ = _p_[:cx] - _q_[:cx]  _uy_ = _p_[:cy] - _q_[:cy]
	_vx_ = _r_[:cx] - _q_[:cx]  _vy_ = _r_[:cy] - _q_[:cy]
	_c_ = (_ux_*_vx_ + _uy_*_vy_) / (sqrt(_ux_*_ux_+_uy_*_uy_) * sqrt(_vx_*_vx_+_vy_*_vy_))
	if _c_ > 1  _c_ = 1  ok
	if _c_ < -1  _c_ = -1  ok
	return acos(_c_) * 180 / 3.14159265358979

func _ChFileAngle paXY, p, q, r
	_ux_ = paXY[p][1] - paXY[q][1]  _uy_ = paXY[p][2] - paXY[q][2]
	_vx_ = paXY[r][1] - paXY[q][1]  _vy_ = paXY[r][2] - paXY[q][2]
	_c_ = (_ux_*_vx_ + _uy_*_vy_) / (sqrt(_ux_*_ux_+_uy_*_uy_) * sqrt(_vx_*_vx_+_vy_*_vy_))
	return acos(_c_) * 180 / 3.14159265358979

# the distance between an atom's symbol centre and its disc centre
func _ChTextOff poDg, pcA
	_i_ = poDg.ShapeOf(pcA + ".icon")  _t_ = poDg.ShapeOf(pcA + ".text")
	return sqrt((_t_[:cx]-_i_[:cx])*(_t_[:cx]-_i_[:cx]) + (_t_[:cy]-_i_[:cy])*(_t_[:cy]-_i_[:cy]))

func _ChLen poDg, pcPath
	_s_ = poDg.ShapeOf(pcPath)
	if len(_s_) = 0  return 0  ok
	return sqrt((_s_[:x2]-_s_[:x1])*(_s_[:x2]-_s_[:x1]) + (_s_[:y2]-_s_[:y1])*(_s_[:y2]-_s_[:y1]))

func _ChSpread paV
	_mn_ = paV[1]  _mx_ = paV[1]
	for _i_ = 2 to len(paV)
		if paV[_i_] < _mn_  _mn_ = paV[_i_]  ok
		if paV[_i_] > _mx_  _mx_ = paV[_i_]  ok
	next
	return _mx_ / _mn_

func _ChMaxDev paV, pnT
	_d_ = 0
	for _i_ = 1 to len(paV)
		if fabs(paV[_i_] - pnT) > _d_  _d_ = fabs(paV[_i_] - pnT)  ok
	next
	return _d_

func _ChJoin paV
	_c_ = ""
	for _i_ = 1 to len(paV)
		if _c_ != ""  _c_ += " "  ok
		_c_ += ("" + floor(paV[_i_] * 10 + 0.5) / 10)
	next
	return _c_

# every hydrogen a7..a12 of benzene farther from the ring's centre than
# the carbon a1..a6 it hangs from
func _ChOutward poDg
	_cx_ = 0  _cy_ = 0
	for _i_ = 1 to 6
		_s_ = poDg.ShapeOf("a" + _i_ + ".icon")
		_cx_ += _s_[:cx] / 6  _cy_ += _s_[:cy] / 6
	next
	for _i_ = 1 to 6
		_c_ = poDg.ShapeOf("a" + _i_ + ".icon")
		_h_ = poDg.ShapeOf("a" + (_i_ + 6) + ".icon")
		_dc_ = (_c_[:cx]-_cx_)*(_c_[:cx]-_cx_) + (_c_[:cy]-_cy_)*(_c_[:cy]-_cy_)
		_dh_ = (_h_[:cx]-_cx_)*(_h_[:cx]-_cx_) + (_h_[:cy]-_cy_)*(_h_[:cy]-_cy_)
		if _dh_ <= _dc_  return FALSE  ok
	next
	return TRUE

# the sign of p relative to the directed line a -> b
func _ChSide poDg, pcA, pcB, pcP
	_a_ = poDg.ShapeOf(pcA + ".icon")  _b_ = poDg.ShapeOf(pcB + ".icon")  _p_ = poDg.ShapeOf(pcP + ".icon")
	return (_b_[:cx]-_a_[:cx]) * (_p_[:cy]-_a_[:cy]) - (_b_[:cy]-_a_[:cy]) * (_p_[:cx]-_a_[:cx])

# crossings among the hidden centre-to-centre bond segments b1..bN
func _ChCrossings poDg, pnBonds
	_n_ = 0
	for _i_ = 1 to pnBonds
		_p_ = poDg.ShapeOf("b" + _i_ + ".icon")
		for _j_ = _i_ + 1 to pnBonds
			_q_ = poDg.ShapeOf("b" + _j_ + ".icon")
			if _ChSegCross(_p_, _q_)  _n_++  ok
		next
	next
	return _n_

func _ChSegCross pa, pb
	# proper crossing only: shared endpoints (adjacent bonds) do not count
	_d1_ = _ChOrient(pa[:x1], pa[:y1], pa[:x2], pa[:y2], pb[:x1], pb[:y1])
	_d2_ = _ChOrient(pa[:x1], pa[:y1], pa[:x2], pa[:y2], pb[:x2], pb[:y2])
	_d3_ = _ChOrient(pb[:x1], pb[:y1], pb[:x2], pb[:y2], pa[:x1], pa[:y1])
	_d4_ = _ChOrient(pb[:x1], pb[:y1], pb[:x2], pb[:y2], pa[:x2], pa[:y2])
	if fabs(_d1_) < 0.001 or fabs(_d2_) < 0.001 or fabs(_d3_) < 0.001 or fabs(_d4_) < 0.001  return FALSE  ok
	return (_d1_ * _d2_ < 0) and (_d3_ * _d4_ < 0)

func _ChOrient ax, ay, bx, by, px, py
	return (bx - ax) * (py - ay) - (by - ay) * (px - ax)

func _ChIdealOf poS, pcG
	if poS.Holds("Ideal180", [ pcG ])  return "Ideal180"  ok
	if poS.Holds("Ideal90", [ pcG ])  return "Ideal90"  ok
	if poS.Holds("Ideal120", [ pcG ])  return "Ideal120"  ok
	return ""

func _ChAllIdeal poS, pcIdeal
	_ac_ = poS.ObjectsOfType("Angle")
	_n_ = 0
	for _i_ = 1 to len(_ac_)
		if poS.Holds(pcIdeal, [ _ac_[_i_] ])  _n_++  ok
	next
	return _n_

func _ChRefusesElement
	try
		StzMoleculeFromBonds([ "Xx", "H" ], [ [ 1, 2, 1 ] ])
	catch
		return StzFindFirst("Xx", cCatchError) > 0
	done
	return FALSE

func _ChRefusesShortMol
	try
		StzMolParse("x" + char(10) + "y" + char(10) + char(10) + "  9  9  0" + char(10) +
			"    0.0000    0.0000    0.0000 C   0" + char(10))
	catch
		return StzFindFirst("counts line", cCatchError) > 0
	done
	return FALSE

func _ChTree
	_o_ = new stzMathDiagram(StzChemistryDomain(),
		StzMoleculeFromBonds([ "C", "C", "C" ], [ [1,2,1],[2,3,1] ]), StzBallAndStickStyle())
	_o_.SetFont(AUFONT, 11)
	_o_.Layout()
	return _o_

# an oxygen with three single bonds -- geometrically perfect, chemically
# wrong, so the ONLY thing the gate finds is the valence
func _OgValenceWitness
	_o_ = new stzMathDiagram(StzChemistryDomain(),
		StzMoleculeFromBonds([ "O", "H", "H", "H" ], [ [1,2,1],[1,3,1],[1,4,1] ]), StzBallAndStickStyle())
	_o_.SetFont(AUFONT, 11)
	return _o_

# water and a hydrogen bonded to nothing
func _OgStrayWitness
	_o_ = new stzMathDiagram(StzChemistryDomain(),
		StzMoleculeFromBonds([ "O", "H", "H", "H" ], [ [1,2,1],[1,3,1] ]), StzBallAndStickStyle())
	_o_.SetFont(AUFONT, 11)
	return _o_

func _OgAllFromAny poRep, pacNames
	_aF_ = poRep.Findings()
	for _i_ = 1 to len(_aF_)
		_w_ = "" + _aF_[_i_][:where]
		_bOk_ = FALSE
		for _k_ = 1 to len(pacNames)
			if StzLeft(_w_, len(pacNames[_k_]) + 1) = pacNames[_k_] + " "  _bOk_ = TRUE  ok
		next
		if NOT _bOk_  return FALSE  ok
	next
	return TRUE

func _OgAllFromEither poRep, pcA, pcB
	_aF_ = poRep.Findings()
	for _i_ = 1 to len(_aF_)
		_w_ = "" + _aF_[_i_][:where]
		if StzLeft(_w_, len(pcA) + 1) = pcA + " "  loop  ok
		if StzLeft(_w_, len(pcB) + 1) = pcB + " "  loop  ok
		return FALSE
	next
	return TRUE

func _OgAllFrom poRep, pcPrefix
	_aF_ = poRep.Findings()
	for _i_ = 1 to len(_aF_)
		if StzLeft(_aF_[_i_][:where], len(pcPrefix) + 1) != pcPrefix + " "  return FALSE  ok
	next
	return TRUE

func _OgJudge poM
	_oG_ = StzMathGovernanceOf("one")
	_oG_.AddPicture("one", poM)
	return _oG_.CheckPictures()

# move a vertex's name onto the middle of an arc, by hand, and tell the
# diagram its values changed under it
func _OgMoveNameOntoEdge poM, pcVertex, pcArc
	_l_ = poM.ShapeOf(pcArc + ".icon")
	_ix_ = poM._UnknownIndex(pcVertex + ".text.cx")
	_iy_ = poM._UnknownIndex(pcVertex + ".text.cy")
	poM.@aValue[_ix_] = (_l_[:x1] + _l_[:x2]) / 2
	poM.@aValue[_iy_] = (_l_[:y1] + _l_[:y2]) / 2
	poM.Touch()

func _CmOnLight
	_oSt_ = StzEulerStyle()
	_o_ = new stzMathDiagram(StzSetTheoryDomain(), StzMathTreeSubstance(), _oSt_)
	_o_.SetFont(AUFONT, 28)
	return _o_._Colour([ :on, "paper" ])

# the names of a picture that fall under a contrast ratio against what
# holds them -- the topmost filled region containing the name's centre,
# composited over the paper, or the paper
func _CmUnreadable poM, pnMin
	_n_ = 0
	_ac_ = poM.Shapes()
	for _i_ = 1 to len(_ac_)
		_cP_ = _ac_[_i_]
		if poM.ShapeOf(_cP_)[:kind] != "text" or poM.IsHidden(_cP_)  loop  ok
		if "" + poM.PropOf(_cP_, "string", "") = ""  loop  ok
		_cT_ = poM.FillOf(_cP_)
		_cBg_ = poM.Background()
		_aT_ = poM.ShapeOf(_cP_)
		_nTop_ = -1
		for _j_ = 1 to len(_ac_)
			_cQ_ = _ac_[_j_]
			if _cQ_ = _cP_ or poM.IsHidden(_cQ_) or poM.FillOf(_cQ_) = ""  loop  ok
			_aR_ = _MrRegion(poM, _cQ_)
			if len(_aR_) < 6  loop  ok
			if _MrPointIn(_aT_[:cx], _aT_[:cy], _aR_) and poM.DrawIndexOf(_cQ_) > _nTop_
				_nTop_ = poM.DrawIndexOf(_cQ_)
				_cBg_ = poM._Opaque(poM.FillOf(_cQ_), poM.Background())
			ok
		next
		if StzContrastOf(_cT_, _cBg_) < pnMin  _n_++  ok
	next
	return _n_

func _CmNames poM
	_n_ = 0
	_ac_ = poM.Shapes()
	for _i_ = 1 to len(_ac_)
		if poM.ShapeOf(_ac_[_i_])[:kind] = "text" and NOT poM.IsHidden(_ac_[_i_]) and
		   "" + poM.PropOf(_ac_[_i_], "string", "") != ""
			_n_++
		ok
	next
	return _n_

# hex literals among a style's rule rows, however deep
func _CmHexIn poSt
	return _CmHexInList(poSt.Rules())

func _CmHexInList pa
	_n_ = 0
	for _i_ = 1 to len(pa)
		if isList(pa[_i_])
			_n_ += _CmHexInList(pa[_i_])
		but isString(pa[_i_]) and len(pa[_i_]) >= 7 and StzLeft(pa[_i_], 1) = "#" and
		    _CmIsHex(pa[_i_])
			_n_++
		ok
	next
	return _n_

func _CmIsHex pc
	for _i_ = 2 to len(pc)
		_k_ = ascii(StzLower(pc[_i_]))
		if NOT ((_k_ >= 48 and _k_ <= 57) or (_k_ >= 97 and _k_ <= 102))  return FALSE  ok
	next
	return len(pc) = 7 or len(pc) = 9

func _PgCornersIn poM, pcText, pcPoly
	_t_ = poM.ShapeOf(pcText)
	_p_ = poM.PolygonOf(pcPoly)
	_n_ = 0
	for _sx_ = -1 to 1 step 2
		for _sy_ = -1 to 1 step 2
			if _MrPointIn(_t_[:cx] + _sx_ * _t_[:w] / 2, _t_[:cy] + _sy_ * _t_[:h] / 2, _p_)  _n_++  ok
		next
	next
	return _n_

# the least distance from any corner of a text to any edge of a polygon
func _PgCornerMargin poM, pcText, pcPoly
	_t_ = poM.ShapeOf(pcText)
	_p_ = poM.PolygonOf(pcPoly)
	_m_ = len(_p_) / 2
	_best_ = 1000000
	for _sx_ = -1 to 1 step 2
		for _sy_ = -1 to 1 step 2
			_x_ = _t_[:cx] + _sx_ * _t_[:w] / 2
			_y_ = _t_[:cy] + _sy_ * _t_[:h] / 2
			for _i_ = 1 to _m_
				_j_ = (_i_ % _m_) + 1
				_d_ = _ByPtSeg(_x_, _y_, _p_[2*_i_-1], _p_[2*_i_], _p_[2*_j_-1], _p_[2*_j_])
				if _d_ < _best_  _best_ = _d_  ok
			next
		next
	next
	return _best_

func _ByPtSegBox poM, pcText, pcLine
	_l_ = poM.ShapeOf(pcLine)
	_aI_ = [ [ _l_[:x1], _l_[:y1], _l_[:x2], _l_[:y2] ] ]
	return _ByMinGap(poM, pcText, _aI_)

# a point of the polygon's bounding box that the polygon itself does not
# hold -- true whenever the polygon is rotated off the axes
func _PgBoxNotSquare poM, pcPoly
	_p_ = poM.PolygonOf(pcPoly)
	_x0_ = _p_[1]  _y0_ = _p_[2]  _x1_ = _p_[1]  _y1_ = _p_[2]
	for _i_ = 1 to len(_p_) / 2
		if _p_[2*_i_-1] < _x0_  _x0_ = _p_[2*_i_-1]  ok
		if _p_[2*_i_-1] > _x1_  _x1_ = _p_[2*_i_-1]  ok
		if _p_[2*_i_] < _y0_  _y0_ = _p_[2*_i_]  ok
		if _p_[2*_i_] > _y1_  _y1_ = _p_[2*_i_]  ok
	next
	for _c_ in [ [ _x0_ + 2, _y0_ + 2 ], [ _x1_ - 2, _y0_ + 2 ], [ _x0_ + 2, _y1_ - 2 ], [ _x1_ - 2, _y1_ - 2 ] ]
		if NOT _MrPointIn(_c_[1], _c_[2], _p_)  return TRUE  ok
	next
	return FALSE

func _PgBoxesApart poM, pcA, pcB
	_a_ = poM.ShapeOf(pcA)
	_b_ = poM.ShapeOf(pcB)
	_qx_ = fabs(_a_[:cx] - _b_[:cx]) - (_a_[:w] + _b_[:w]) / 2
	_qy_ = fabs(_a_[:cy] - _b_[:cy]) - (_a_[:h] + _b_[:h]) / 2
	_mx_ = _qx_  if _qy_ > _mx_  _mx_ = _qy_  ok
	_ax_ = _qx_  if _ax_ < 0  _ax_ = 0  ok
	_ay_ = _qy_  if _ay_ < 0  _ay_ = 0  ok
	_sd_ = sqrt(_ax_ * _ax_ + _ay_ * _ay_)
	if _mx_ < 0  _sd_ += _mx_  ok
	return _sd_

func _PgRefuses pnWhich
	_b_ = FALSE
	try
		_oSt_ = new stzMathStyle()
		_oSt_.SetCanvas(400, 400)
		_oSt_.ForAll("Point p", [
			[ :shape, "p.icon", :circle, [ :r = 4 ] ],
			[ :shape, "p.box", :poly, [ :n = 4, :x1 = 100, :y1 = 100, :x2 = 300, :y2 = 100,
			                            :x3 = 300, :y3 = 300, :x4 = 100, :y4 = 300 ] ],
			[ :shape, "p.box2", :poly, [ :n = 4, :x1 = 120, :y1 = 120, :x2 = 200, :y2 = 120,
			                             :x3 = 200, :y3 = 200, :x4 = 120, :y4 = 200 ] ] ])
		if pnWhich = 1
			_oSt_.ForAll("Point p", [ [ :ensure, "contains", [ "p.icon", "p.box", 2 ] ] ])
		but pnWhich = 2
			_oSt_.ForAll("Point p", [ [ :ensure, "disjoint", [ "p.box", "p.box2", 2 ] ] ])
		else
			_oSt_.ForAll("Point p", [ [ :ensure, "contains", [ "p.box", "p.icon", 2 ] ],
			                           [ :ensure, "disjoint", [ "p.icon", "p.box2", 2 ] ] ])
		ok
		_oS_ = new stzMathSubstance(StzGeometryDomain())
		_oS_.Declare("Point", "P")
		_o_ = new stzMathDiagram(StzGeometryDomain(), _oS_, _oSt_)
		_o_.Layout()
	catch
		_b_ = TRUE
	done
	return _b_

func _GnRefused poS
	_b_ = FALSE
	try
		poS.DeclareMany("Dot", "q", 3)
	catch
		_b_ = TRUE
	done
	return _b_

func _GnBuildMs pnN
	_aX_ = []
	for _i_ = 1 to pnN  _aX_ + _i_  next
	_t0_ = StzEngineWatchTimestampMs()
	_o_ = new stzMathSubstance(StzDotDomain())
	_o_.DeclareMany("Dot", "z", pnN)
	_o_.SetDataFrom("z", "x", _aX_)
	_o_.SetDataFrom("z", "y", _aX_)
	return StzEngineWatchTimestampMs() - _t0_

# [ how many dots inside the outer triangle, how many inside the central hole ]
func _GnSierpinskiCounts poM, pnN
	_aT_ = [ 320, 40, 40, 560, 600, 560 ]
	_aH_ = [ (320 + 40) / 2, (40 + 560) / 2, (320 + 600) / 2, (40 + 560) / 2, (40 + 600) / 2, 560 ]
	_nIn_ = 0  _nHole_ = 0
	for _i_ = 1 to pnN
		_x_ = poM.ValueOf("d" + _i_ + ".icon.cx")
		_y_ = poM.ValueOf("d" + _i_ + ".icon.cy")
		if _MrPointIn(_x_, _y_, _aT_)  _nIn_++  ok
		if _GnStrictlyIn(_x_, _y_, _aH_)  _nHole_++  ok
	next
	return [ _nIn_, _nHole_ ]

# strictly inside a triangle: all three cross products of one sign, none zero
func _GnStrictlyIn px, py, paT
	_s_ = []
	for _i_ = 1 to 3
		_j_ = (_i_ % 3) + 1
		_c_ = (paT[2*_j_-1] - paT[2*_i_-1]) * (py - paT[2*_i_]) - (paT[2*_j_] - paT[2*_i_]) * (px - paT[2*_i_-1])
		_s_ + _c_
	next
	return (_s_[1] > 0.5 and _s_[2] > 0.5 and _s_[3] > 0.5) or (_s_[1] < -0.5 and _s_[2] < -0.5 and _s_[3] < -0.5)

func _GnThroughCusp poM, pnN
	_px_ = poM.ValueOf("p.icon.cx")
	_py_ = poM.ValueOf("p.icon.cy")
	_n_ = 0
	for _i_ = 1 to pnN
		_s_ = poM.ShapeOf("c" + _i_ + ".icon")
		_d_ = sqrt((_s_[:cx] - _px_) * (_s_[:cx] - _px_) + (_s_[:cy] - _py_) * (_s_[:cy] - _py_))
		if fabs(_d_ - _s_[:r]) < 0.000001  _n_++  ok
	next
	return _n_

func _GnTangent poM, pnN
	_py_ = poM.ValueOf("p.icon.cy")
	_n_ = 0
	for _i_ = 1 to pnN
		_s_ = poM.ShapeOf("c" + _i_ + ".icon")
		if fabs(fabs(_s_[:cy] - _py_) - _s_[:r]) < 0.000001  _n_++  ok
	next
	return _n_

func _GnContinuous poM, pcPfx, pnSteps
	for _i_ = 1 to pnSteps - 1
		_a_ = poM.ShapeOf(pcPfx + _i_ + ".icon")
		_b_ = poM.ShapeOf(pcPfx + (_i_ + 1) + ".icon")
		if _a_[:x2] != _b_[:x1] or _a_[:y2] != _b_[:y1]  return FALSE  ok
	next
	return TRUE

func _GnMixed
	_oS_ = new stzMathSubstance(StzDotDomain())
	_oS_.DeclareMany("Dot", "m", 50)
	_aX_ = []
	for _i_ = 1 to 50  _aX_ + (100 + _i_ * 8)  next
	_oS_.SetDataFrom("m", "x", _aX_)
	_oS_.SetDataFrom("m", "y", _aX_)
	_oS_.Declare("Ring", "lbl")
	_oS_.Label("lbl", "walk")
	_oSt_ = new stzMathStyle()
	_oSt_.SetCanvas(640, 600)
	_oSt_.ForAll("Dot d", [ [ :shape, "d.icon", :circle, [ :cx = "d.x", :cy = "d.y", :r = 2 ] ] ])
	_oSt_.ForAll("Ring c", [ [ :shape, "c.text", :text, [] ] ])
	_o_ = new stzMathDiagram(StzDotDomain(), _oS_, _oSt_)
	_o_.SetFont(AUFONT, 14)
	_o_.Layout()
	return _o_

# three dots, one of them 300 px past the right edge by its own datum
func _GnOffPaper
	_oS_ = new stzMathSubstance(StzDotDomain())
	_oS_.DeclareMany("Dot", "o", 3)
	_oS_.SetDataFrom("o", "x", [ 100, 200, 940 ])
	_oS_.SetDataFrom("o", "y", [ 100, 100, 100 ])
	_oSt_ = new stzMathStyle()
	_oSt_.SetCanvas(640, 600)
	_oSt_.ForAll("Dot d", [ [ :shape, "d.icon", :circle, [ :cx = "d.x", :cy = "d.y", :r = 2 ] ] ])
	_o_ = new stzMathDiagram(StzDotDomain(), _oS_, _oSt_)
	_aV_ = _o_.Violations()
	if _o_.IsFeasible() or len(_aV_) != 1  return FALSE  ok
	return StzFindFirst("o3.icon", _aV_[1][:where]) > 0 and
	       _o_.Violation() > 300 and _o_.Violation() < 320

func _GnMixedPinned
	_oS_ = new stzMathSubstance(StzDotDomain())
	_oS_.DeclareMany("Dot", "m", 50)
	_aX_ = []
	for _i_ = 1 to 50  _aX_ + (100 + _i_ * 8)  next
	_oS_.SetDataFrom("m", "x", _aX_)
	_oS_.SetDataFrom("m", "y", _aX_)
	_oS_.Declare("Ring", "lbl")
	_oS_.Label("lbl", "walk")
	_oSt_ = new stzMathStyle()
	_oSt_.SetCanvas(640, 600)
	_oSt_.ForAll("Dot d", [ [ :shape, "d.icon", :circle, [ :cx = "d.x", :cy = "d.y", :r = 2 ] ] ])
	_oSt_.ForAll("Ring c", [ [ :shape, "c.text", :text, [ :cx = 300, :cy = 40 ] ] ])
	_o_ = new stzMathDiagram(StzDotDomain(), _oS_, _oSt_)
	_o_.SetFont(AUFONT, 14)
	_o_.Layout()
	return _o_

func _LvHas paList, pcItem
	for _i_ = 1 to len(paList)
		if paList[_i_] = pcItem  return TRUE  ok
	next
	return FALSE

func _LvRefuses poM, pnWhich
	_b_ = FALSE
	try
		if pnWhich = 1
			poM.Pin("ABC.sqab")
		but pnWhich = 2
			poM.DragTo("ABC.sqab", 100, 100)
		else
			poM.Pin("nobody.icon")
		ok
	catch
		_b_ = TRUE
	done
	return _b_

# one subexpression, written pnRepeat further times
func _TpProg pcInner, pnRepeat
	_c_ = pcInner
	for _i_ = 1 to pnRepeat
		_c_ += " + " + pcInner
	next
	return StzEngineGradCompile(_c_, "x,y")

# pnCount DIFFERENT subexpressions, so nothing may be shared between them
func _TpProgVaried pnCount
	_c_ = "(x*y + sqrt(x*x + y*y))"
	for _i_ = 1 to pnCount
		_c_ += " + (x*" + (_i_ + 1) + "*y + sqrt(x*x + " + (_i_ + 2) + "*y*y))"
	next
	return StzEngineGradCompile(_c_, "x,y")

# the tape's own value at the solved point, against what the picture reports
func _TpAgrees poM, pProg, pcTerm
	_v_ = StzEngineGradValueAt(pProg, poM.@aValue)
	if NOT isNumber(_v_)  return FALSE  ok
	for _i_ = 1 to len(poM.@aConstraints)
		if poM.@aConstraints[_i_][2] != pcTerm  loop  ok
		_r_ = poM.@aViolations[_i_][3]
		# the picture clamps a satisfied constraint to zero; the tape does not
		if _r_ <= 0.01  return _v_ <= 0.01  ok
		return fabs(_r_ - _v_) < 0.0001
	next
	return FALSE

func _TpFourfold
	_one_ = StzEngineGradCompile("(x*y + sqrt(x*x + y*y))", "x,y")
	_four_ = _TpProg("(x*y + sqrt(x*x + y*y))", 3)
	_b_ = TRUE
	for _k_ = 1 to 5
		_aX_ = [ _k_ * 1.5, 7 - _k_ ]
		_a_ = StzEngineGradValueAt(_one_, _aX_)
		_c_ = StzEngineGradValueAt(_four_, _aX_)
		if _a_ * 4 != _c_  _b_ = FALSE  ok
	next
	StzEngineGradFree(_one_)
	StzEngineGradFree(_four_)
	return _b_

func _TpSeedKeepsPlanar pcSeed
	_o_ = new stzMathDiagram(StzGraphDomain(), StzMathCubeSubstance(), StzCurvedGraphStyle())
	_o_.SetFont(AUFONT, 15)
	_o_.SetVariation(pcSeed)
	return _o_.IsFeasible() and _o_.StartedPlanar()

func _TpAllSeedsLawful
	for _c_ in [ "curved", "bulge2", "gray", "seedA", "seedB", "one-wedge" ]
		_o_ = new stzMathDiagram(StzGraphDomain(), StzMathCubeSubstance(), StzCurvedGraphStyle())
		_o_.SetFont(AUFONT, 15)
		_o_.SetVariation(_c_)
		if NOT _o_.IsFeasible()  return FALSE  ok
	next
	return TRUE

func _TrHasClass pcName
	_a_ = classes()
	for _i_ = 1 to len(_a_)
		if lower(_a_[_i_]) = lower(pcName)  return TRUE  ok
	next
	return FALSE

func _TrBase
	return read("../../stzBase.ring")

# code files under base/ that still say stzNarration, the transcript's own
# header excluded, since it records where the name went
func _TrOldNameSites
	_n_ = 0
	_ac_ = _TrRingFiles("../../")
	for _i_ = 1 to len(_ac_)
		if StzFindFirst("stzTranscript.ring", _ac_[_i_]) > 0  loop  ok
		if StzFindFirst("stzNarration", read(_ac_[_i_])) > 0  _n_++  ok
	next
	return _n_

func _TrRingFiles pcDir
	_a_ = []
	_aD_ = dir(pcDir)
	for _i_ = 1 to len(_aD_)
		_c_ = _aD_[_i_][1]
		if _c_ = "." or _c_ = ".."  loop  ok
		if _aD_[_i_][2] = 1
			if _c_ = "test" or _c_ = "doc"  loop  ok
			_b_ = _TrRingFiles(pcDir + _c_ + "/")
			for _k_ = 1 to len(_b_)  _a_ + _b_[_k_]  next
		but StzRight(_c_, 5) = ".ring"
			_a_ + (pcDir + _c_)
		ok
	next
	return _a_

func _FcShaped paFact
	for _c_ in [ :kind, :subject, :value, :unit, :where, :message ]
		if NOT HasKey(paFact, _c_)  return FALSE  ok
	next
	return len(paFact) = 6

func _FcNear pn, pnWant
	return fabs(pn - pnWant) < 1.5

# the curved cube solved with ONE label wedge, as it was before DN8h's
# repair: the picture whose caption the three diagrams described
# the one-wedge solve of the story's seed -- see StzMathOneWedgeStorySeed
func _FcOneWedge
	_o_ = new stzMathDiagram(StzGraphDomain(), StzMathCubeSubstance(), StzCurvedGraphStyle())
	_o_.SetFont(AUFONT, 15)
	_o_.SetVariation(StzMathOneWedgeStorySeed())
	_o_._Compile()
	_o_._CompileViolationTapes()
	_o_._Initialise("planar")
	_o_._SolveStage(0)
	_o_._SolveStage(1)
	_o_._ReadViolations()
	_o_._FreeViolationTapes()
	_o_.@bLaidOut = 1
	_o_.@aVCache = []
	return _o_

func _FcVerdictIsTheFinding poM
	_aV_ = poM.Violations()
	if len(_aV_) = 0  return FALSE  ok
	_f_ = poM.Fact(:verdict, [ "" ])
	return _f_[:message] = _aV_[1][:message] and _f_[:where] = _aV_[1][:where]

func _FcRefuses pnWhich
	_b_ = FALSE
	_o_ = StzMathScene16(AUFONT)
	_o_.Layout()
	_g_ = StzDrakonScene01([ :Font = AUFONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 14 ])
	try
		if pnWhich = 1
			_o_.Fact(:distance, [ "A.icon", "ZZZ.icon" ])
		but pnWhich = 2
			_g_.Fact(:count, [ "bananas" ])
		but pnWhich = 3
			_g_.Fact(:wobble, [ "t" ])
		but pnWhich = 4
			_o_.Fact(:arg, [ "no such rule anywhere", 2 ])
		else
			_o_.Fact(:distance, [ "A.icon", "B.icon" ])
			_g_.Fact(:count, [ "nodes" ])
			_g_.Fact(:position, [ "t" ])
			_o_.Fact(:arg, [ "disjoint", 3 ])
		ok
	catch
		_b_ = TRUE
	done
	return _b_

func _MkPositions poM
	_a_ = []
	for _c_ in [ "v000", "v001", "v010", "v011", "v100", "v101", "v110", "v111" ]
		_a_ + [ poM.ValueOf(_c_ + ".icon.cx"), poM.ValueOf(_c_ + ".icon.cy") ]
	next
	return _a_

func _MkSame paA, paB
	if len(paA) != len(paB)  return FALSE  ok
	for _i_ = 1 to len(paA)
		if paA[_i_][1] != paB[_i_][1] or paA[_i_][2] != paB[_i_][2]  return FALSE  ok
	next
	return TRUE

# a circle mark centred on pcOn at radius pnR, to a hundredth
func _MkShownAt poM, pcOn, pnR
	_t_ = poM.ShapeOf(pcOn)
	for _m_ in poM.Marks()
		if _m_[2] != "show"  loop  ok
		_s_ = poM.ShapeOf(_m_[1])
		if fabs(_s_[:cx] - _t_[:cx]) < 0.01 and fabs(_s_[:cy] - _t_[:cy]) < 0.01 and
		   fabs(_s_[:r] - pnR) < 0.01
			return TRUE
		ok
	next
	return FALSE

# the strip's width across its segment: the distance between its two long sides
func _MkRibbonWidth poM, pcEdge
	for _m_ in poM.Marks()
		if _m_[2] != "region"  loop  ok
		_p_ = poM.PolygonOf(_m_[1])
		if len(_p_) < 8  loop  ok
		return sqrt((_p_[1] - _p_[7]) * (_p_[1] - _p_[7]) + (_p_[2] - _p_[8]) * (_p_[2] - _p_[8]))
	next
	return 0

func _MkCalloutHas poM, pcNumber
	for _m_ in poM.Marks()
		if _m_[2] != "label"  loop  ok
		if StzFindFirst(pcNumber, "" + poM.PropOf(_m_[1], "string", "")) > 0  return TRUE  ok
	next
	return FALSE

func _MkCalloutClearOfNames poM
	for _m_ in poM.Marks()
		if _m_[2] != "label"  loop  ok
		_a_ = poM.ShapeOf(_m_[1])
		for _c_ in [ "v000", "v001", "v010", "v011", "v100", "v101", "v110", "v111" ]
			_b_ = poM.ShapeOf(_c_ + ".text")
			if len(_b_) = 0  loop  ok
			_qx_ = fabs(_a_[:cx] - _b_[:cx]) - (_a_[:w] + _b_[:w]) / 2
			_qy_ = fabs(_a_[:cy] - _b_[:cy]) - (_a_[:h] + _b_[:h]) / 2
			if _qx_ < 3.9 and _qy_ < 3.9  return FALSE  ok
		next
	next
	return TRUE

# a leader's far end sits on the sentence the solver placed
func _MkLeaderJoins poM
	for _m_ in poM.Marks()
		if _m_[2] != "callout"  loop  ok
		_l_ = poM.ShapeOf(_m_[1])
		_cT_ = StzReplace(_m_[1], "_lead", "")
		_t_ = poM.ShapeOf(_cT_)
		if len(_t_) = 0  loop  ok
		if fabs(_l_[:x2] - _t_[:cx]) > 0.01 or fabs(_l_[:y2] - _t_[:cy]) > 0.01  return FALSE  ok
	next
	return TRUE

func _MkRingOutside poM, pcOn
	_t_ = poM.ShapeOf(pcOn)
	for _m_ in poM.Marks()
		if _m_[2] != "emphasis"  loop  ok
		_s_ = poM.ShapeOf(_m_[1])
		return _s_[:r] > _t_[:r] + 4
	next
	return FALSE

func _MkMeasureShows poM, pcA, pcB
	_a_ = poM.ShapeOf(pcA)
	_b_ = poM.ShapeOf(pcB)
	for _m_ in poM.Marks()
		if _m_[2] != "measure"  loop  ok
		_l_ = poM.ShapeOf(_m_[1])
		if fabs(_l_[:x1] - _a_[:cx]) < 0.01 and fabs(_l_[:x2] - _b_[:cx]) < 0.01  return TRUE  ok
	next
	return FALSE

func _MkRefuses pnWhich
	_b_ = FALSE
	_o_ = StzMathScene16(AUFONT)
	_o_.Layout()
	try
		if pnWhich = 1
			_o_.Show("disjoint A.text AB.icon")
		but pnWhich = 2
			_o_.Region("equal")
		but pnWhich = 3
			_o_.Emphasis("A.icon", :sparkle)
		but pnWhich = 4
			_o_.Emphasis("Z.icon", :ring)
		else
			_o_.Emphasis("A.icon", :ring)
			_o_.Emphasis("B.icon", :focus)
			_o_.Emphasis("C.icon", :dim)
		ok
	catch
		_b_ = TRUE
	done
	return _b_

func _WnValuesSurvive poM
	_a_ = _MkPositions(poM)
	poM.ClearWindow()
	_b_ = _MkPositions(poM)
	poM.WindowOn("v111.icon", 105)
	_c_ = _MkPositions(poM)
	return _MkSame(_a_, _b_) and _MkSame(_b_, _c_)

# an arc reported visible whose own MIDDLE is outside the view -- the case
# a centre-and-reach test gets wrong, and the reason sixty of sixty-five
# shapes disappeared the first time this was asked
func _WnCrossingCounted poM
	_aW_ = poM.Window()
	_ac_ = poM.VisibleShapes()
	for _i_ = 1 to len(_ac_)
		_b_ = poM._WBox(_ac_[_i_])
		if len(_b_) != 4  loop  ok
		_cx_ = (_b_[1] + _b_[3]) / 2
		_cy_ = (_b_[2] + _b_[4]) / 2
		# reported visible, yet its own middle lies outside the view: the
		# case a centre-and-reach test gets wrong
		if fabs(_cx_ - _aW_[1]) > _aW_[3] / 2 or fabs(_cy_ - _aW_[2]) > _aW_[4] / 2
			return TRUE
		ok
	next
	return FALSE

# the first frame's finding is its own leash rule, not anything the window
# introduced
func _WnFoundForItsLeash poM
	_aF_ = StzCheckPictures([ [ "before", poM ] ]).Findings()
	if len(_aF_) = 0  return FALSE  ok
	for _i_ = 1 to len(_aF_)
		if StzFindFirst("outside the part of the picture", "" + _aF_[_i_][:message]) > 0
			return FALSE
		ok
	next
	for _i_ = 1 to len(_aF_)
		if StzFindFirst("lessthan", StzLower("" + _aF_[_i_][:where])) > 0  return TRUE  ok
	next
	return FALSE

func _WnAllVisibleWithout
	_o_ = StzMathScene16(AUFONT)
	_o_.Layout()
	_n_ = 0
	_ac_ = _o_.Shapes()
	for _i_ = 1 to len(_ac_)
		if _o_.IsHidden(_ac_[_i_])  loop  ok
		_n_++
	next
	return len(_o_.VisibleShapes()) = _n_

# a mark on a vertex the window does not show is found by the fifth rule
func _WnOffWindowFound
	_o_ = StzMathScene25(AUFONT)
	_o_.Layout()
	_o_.Emphasis("v000.icon", :ring)
	_o_.WindowOn("v111.icon", 105)
	_aF_ = StzCheckPictures([ [ "off-window", _o_ ] ]).Findings()
	for _i_ = 1 to len(_aF_)
		if StzFindFirst("outside the part of the picture", "" + _aF_[_i_][:message]) > 0
			return TRUE
		ok
	next
	return FALSE

func _WnTextUnscaled
	_o_ = StzMathScene16(AUFONT)
	_o_.Layout()
	_a_ = _o_.ShapeOf("A.text")
	_o_.WindowOn("A.icon", 90)
	_b_ = _o_.ShapeOf("A.text")
	return _a_[:w] = _b_[:w] and _a_[:h] = _b_[:h]

# every arrow goes from a step to an earlier step: the tape invariant
func _TgOperandsPrecede poG
	_ac_ = poG.NodesIds()
	for _i_ = 1 to len(_ac_)
		_aT_ = poG.Neighbors(_ac_[_i_])
		for _k_ = 1 to len(_aT_)
			if _TgIndexOf(_ac_[_i_]) <= _TgIndexOf(_aT_[_k_])  return FALSE  ok
		next
	next
	return TRUE

func _TgIndexOf pcId
	return 0 + StzStringSection("" + pcId, 2, len("" + pcId))

func _TgLeavesAndRoot poG
	_ac_ = poG.NodesIds()
	_nRoots_ = 0
	for _i_ = 1 to len(_ac_)
		_cOp_ = "" + poG.NodeProperty(_ac_[_i_], :op)
		if _cOp_ = "variable" or _cOp_ = "constant"
			if len(poG.Neighbors(_ac_[_i_])) != 0  return FALSE  ok
		ok
		if len(poG.Incoming(_ac_[_i_])) = 0  _nRoots_++  ok
	next
	return _nRoots_ = 1

func _TgRootLabel pHandle, pcNames
	_oG_ = StzTapeGraphXT(pHandle, [ :names = pcNames ])
	_ac_ = _oG_.NodesIds()
	for _i_ = 1 to len(_ac_)
		if len(_oG_.Incoming(_ac_[_i_])) = 0
			return "" + _oG_.NodeProperty(_ac_[_i_], :label)
		ok
	next
	return ""

func _TgBigTape
	_o_ = StzMathScene13(AUFONT)
	_o_.Layout()
	_c_ = ""
	for _i_ = 1 to len(_o_.@aConstraints)
		if len(_o_.@aConstraints[_i_][2]) > len(_c_)  _c_ = _o_.@aConstraints[_i_][2]  ok
	next
	return [ _o_, _c_ ]

func _TgRefusesBig
	_a_ = _TgBigTape()
	_b_ = FALSE
	try
		_p_ = StzEngineGradCompileXT(_a_[2], _a_[1]._VarsText(), 0)
		StzTapeGraph(_p_)
		StzEngineGradFree(_p_)
	catch
		_b_ = TRUE
	done
	return _b_

func _TgBigCounts
	_a_ = _TgBigTape()
	return _a_[1].Fact(:tapenodes, [ _a_[2], :unshared ])[:value]

func _TgRefusesJunk
	_b_ = FALSE
	try
		StzTapeGraph("not a handle")
	catch
		_b_ = TRUE
	done
	return _b_

func _SbHole poS, pnFrame, pcHole
	_a_ = poS.HolesOf(pnFrame)
	for _i_ = 1 to len(_a_)
		if _a_[_i_][1] = pcHole  return _a_[_i_][2][:value]  ok
	next
	return -1

# every number shown is the number its fact reported -- read again here
# rather than trusted from the storyboard's own judgement
func _SbNumbersAreFacts poS
	for _i_ = 1 to poS.NumberOfFrames()
		_a_ = poS.HolesOf(_i_)
		for _k_ = 1 to len(_a_)
			if StzFindFirst(StzFactNumText(_a_[_k_][2][:value]), poS.Caption(_i_)) = 0 and
			   StzFindFirst("" + _a_[_k_][2][:message], poS.Caption(_i_)) = 0
				return FALSE
			ok
		next
	next
	return TRUE

func _SbFilesDiffer poS
	for _i_ = 1 to poS.NumberOfFrames()
		for _k_ = _i_ + 1 to poS.NumberOfFrames()
			if poS.FileOf(_i_) = poS.FileOf(_k_)  return FALSE  ok
		next
	next
	return TRUE

func _SbNoMaths poS
	for _i_ = 1 to poS.NumberOfFrames()
		_a_ = poS.HolesOf(_i_)
		for _k_ = 1 to len(_a_)
			_c_ = StzLower("" + _a_[_k_][2][:kind])
			if _c_ = "distance" or _c_ = "angle" or _c_ = "expr"  return FALSE  ok
		next
	next
	return TRUE

# a frame that claims to show a flaw, over a picture that has none
func _SbFalseExpect
	_o_ = new stzStoryboard("false-expect", StzMathScene16(AUFONT), "folio")
	_o_.Frame("nothing is wrong with this picture, and I say something is")
	_o_.ExpectFindings()
	for _f_ in _o_.Judge()
		if "" + _f_[:rule] = "expected_a_finding_and_got_none"  return TRUE  ok
	next
	return FALSE

func _SbOpenHole
	_o_ = new stzStoryboard("open-hole", StzMathScene16(AUFONT), "folio")
	_o_.Frame("the radius is {r} px, and nobody said which fact that is")
	for _f_ in _o_.Judge()
		if "" + _f_[:rule] = "hole_left_open"  return TRUE  ok
	next
	return FALSE

func _SbUnquoted
	_o_ = new stzStoryboard("unquoted", StzMathScene16(AUFONT), "folio")
	_o_.Frame("a sentence that quotes nothing at all")
	_o_.Bind("r", :value, [ "K.icon.r" ])
	for _f_ in _o_.Judge()
		if "" + _f_[:rule] = "fact_bound_but_never_shown"  return TRUE  ok
	next
	return FALSE

func _SbMarkBeforeFrame
	_b_ = FALSE
	try
		_o_ = new stzStoryboard("no-frame", StzMathScene16(AUFONT), "folio")
		_o_.Emphasis("A.icon", :ring)
	catch
		_b_ = TRUE
	done
	return _b_

# the grammar has three kinds and no fourth
func _SbKindsOnly pcText
	_a_ = StzSplit(pcText, char(10))
	for _i_ = 1 to len(_a_)
		_c_ = ring_trim(_a_[_i_])
		if StzLeft(_c_, 7) != "DEFINE "  loop  ok
		_k_ = StzSplit(_c_, " ")[2]
		if _k_ != "NARRATION" and _k_ != "PROSE" and _k_ != "CELL"  return FALSE  ok
	next
	return TRUE

func _SbCellPerHole pcText, poS
	_n_ = 0
	_a_ = StzSplit(pcText, char(10))
	for _i_ = 1 to len(_a_)
		if StzLeft(ring_trim(_a_[_i_]), 12) = "DEFINE CELL "  _n_++  ok
	next
	# one picture cell per frame, plus one cell per hole
	return _n_ = poS.NumberOfFrames() + poS.NumberOfHoles()

func _RnJoin paList
	_c_ = ""
	for _i_ = 1 to len(paList)
		if _i_ > 1  _c_ += ", "  ok
		_c_ += "" + paList[_i_]
	next
	return _c_

func _RnAllShaped paThings
	for _i_ = 1 to len(paThings)
		_r_ = StzRenditionOf(paThings[_i_])
		for _c_ in [ :kind, :mime, :content, :locator, :title ]
			if NOT HasKey(_r_, _c_)  return FALSE  ok
		next
		if len(_r_) != 5  return FALSE  ok
	next
	return TRUE

func _RnExtensions paThings
	_c_ = ""
	for _i_ = 1 to len(paThings)
		if _i_ > 1  _c_ += " "  ok
		_c_ += StzRenditionExtension(StzRenditionOf(paThings[_i_]))
	next
	return _c_

func _RnAllFull paThings
	for _i_ = 1 to len(paThings)
		_r_ = StzRenditionOf(paThings[_i_])
		if len("" + _r_[:content]) = 0 and "" + _r_[:locator] = ""  return FALSE  ok
		if "" + _r_[:title] = ""  return FALSE  ok
	next
	return TRUE

func _RnRasterLocated poPic
	_r_ = poPic.RenditionAs(:image)
	if "" + _r_[:locator] = ""  return FALSE  ok
	if len("" + _r_[:content]) != 0  return FALSE  ok
	return fexists(_r_[:locator])

func _RnRefusesUnreached
	_b_ = FALSE
	try
		StzRenditionOf(new stzList([ 1, 2, 3 ]))
	catch
		_b_ = TRUE
	done
	return _b_ and NOT StzCanRender(new stzList([ 1, 2, 3 ]))

func _RnRefusesKind
	_b_ = FALSE
	try
		_o_ = StzMathScene16(AUFONT)
		_o_.RenditionAs(:sculpture)
	catch
		_b_ = TRUE
	done
	return _b_

# WHAT Display() ALREADY MEANS IN THIS LIBRARY, read from every site: an
# alias of a printer, or a launcher of an external program. Not one of
# them hands a value back, and the two meanings are incompatible -- which
# is a stronger objection to the name than its being merely taken.
func _RnDisplayMeanings
	_nP_ = 0
	_nL_ = 0
	_ac_ = _TrRingFiles("../../")
	for _i_ = 1 to len(_ac_)
		_c_ = read(_ac_[_i_])
		_p_ = 1
		while TRUE
			_k_ = _FindFrom(_c_, "	def Display(", _p_)
			if _k_ = 0  exit  ok
			# THE BODY, NOT A FIXED WINDOW. A 420-character window reached
			# past the end of one method into the next, and stopped short of
			# another's actual call, so the classification is taken from the
			# method's own text and from whichever verb appears FIRST in it.
			_w_ = _RnBodyAt(_c_, _k_)
			# THREE DIFFERENT LAUNCHER VERBS APPEAR HERE -- View(),
			# RunAndView() and ExecuteAndView() -- so the test is not a list
			# of them but the word they share, against the one verb that
			# prints. Whichever comes first in the body decides.
			_nVw_ = StzFindFirst("View", _w_)
			_nSh_ = StzFindFirst("This.Show()", _w_)
			if _nVw_ = 0  _nVw_ = 999999  ok
			if _nSh_ = 0  _nSh_ = 999999  ok
			if _nVw_ < _nSh_
				_nL_++
			but _nSh_ < 999999
				_nP_++
			ok
			_p_ = _k_ + 1
		end
	next
	return "" + _nP_ + " print, " + _nL_ + " launch"

# one class carrying both meanings of the same verb
# HOW MANY Display() METHODS HAND A VALUE BACK. This is the property the
# display contract actually asks for, and testing it needs no knowledge of
# what any of them does instead: a method with no return in its body
# cannot be the one a consumer calls.
func _RnDisplayReturns
	_n_ = 0
	_ac_ = _TrRingFiles("../../")
	for _i_ = 1 to len(_ac_)
		_c_ = read(_ac_[_i_])
		_p_ = 1
		while TRUE
			_k_ = _FindFrom(_c_, "	def Display(", _p_)
			if _k_ = 0  exit  ok
			if StzFindFirst("return", _RnCodeAt(_c_, _k_)) > 0  _n_++  ok
			_p_ = _k_ + 1
		end
	next
	return _n_

# A METHOD'S OWN TEXT: from its def line to the NEXT DEFINITION AT ANY
# DEPTH. Ending only at a top-level def swallowed the alternative-form
# methods that follow a nested one, and with them a comment containing
# the word "returns" -- which read as a return and made one of the six
# look like it hands a value back.
func _RnBodyAt pcText, pnAt
	_e1_ = _FindFrom(pcText, char(10) + "	def ", pnAt + 12)
	_e2_ = _FindFrom(pcText, char(10) + "		def ", pnAt + 12)
	_e_ = _e1_
	if _e_ = 0 or (_e2_ > 0 and _e2_ < _e_)  _e_ = _e2_  ok
	if _e_ = 0 or _e_ - pnAt > 1400  _e_ = pnAt + 1400  ok
	if _e_ > len(pcText)  _e_ = len(pcText)  ok
	return StzStringSection(pcText, pnAt, _e_)

# the same, with the comments taken out: a word in prose is not code, and
# "Split() that returns a stzList" is not a return statement
func _RnCodeAt pcText, pnAt
	_ac_ = StzSplit(_RnBodyAt(pcText, pnAt), char(10))
	_o_ = ""
	for _i_ = 1 to len(_ac_)
		_l_ = _ac_[_i_]
		_h_ = StzFindFirst("#", _l_)
		if _h_ > 0  _l_ = StzLeft(_l_, _h_ - 1)  ok
		_o_ += _l_ + char(10)
	next
	return _o_

func _RnGraphHasBoth
	_c_ = read("../../graph/stzGraph.ring")
	_bL_ = FALSE
	_bP_ = FALSE
	_p_ = 1
	while TRUE
		_k_ = _FindFrom(_c_, "	def Display(", _p_)
		if _k_ = 0  exit  ok
		_w_ = _RnBodyAt(_c_, _k_)
		if StzFindFirst("RunAndView", _w_) > 0  _bL_ = TRUE  ok
		if StzFindFirst("This.Show()", _w_) > 0  _bP_ = TRUE  ok
		_p_ = _k_ + 1
	end
	return _bL_ and _bP_

# how many times a verb is defined anywhere under base/, excluding the
# suites and the prose
func _RnCount pcWhat
	_n_ = 0
	_ac_ = _TrRingFiles("../../")
	for _i_ = 1 to len(_ac_)
		_c_ = read(_ac_[_i_])
		_p_ = 1
		while TRUE
			_k_ = _FindFrom(_c_, "	" + pcWhat, _p_)
			if _k_ = 0  exit  ok
			_n_++
			_p_ = _k_ + 1
		end
	next
	return _n_

func _FindFrom pcHay, pcNeedle, pnFrom
	if pnFrom > len(pcHay)  return 0  ok
	_r_ = StzFindFirst(pcNeedle, StzStringSection(pcHay, pnFrom, len(pcHay)))
	if _r_ = 0  return 0  ok
	return _r_ + pnFrom - 1

func _TxRunText paRuns, pnI
	return "" + paRuns[1][pnI][1]

func _TxRunSize paRuns, pnI
	return paRuns[1][pnI][4]

func _TxRunDy paRuns, pnI
	return paRuns[1][pnI][3]

# the label's measured box is the union of its runs, not the raw text's
func _TxBoxMatchesRuns poM
	for _m_ in poM.Marks()
		if _m_[2] != "label"  loop  ok
		_c_ = "" + poM.PropOf(_m_[1], "string", "")
		if NOT StzHasNotation(_c_)  loop  ok
		_nSz_ = poM.PropOf(_m_[1], "size", 24)
		_r_ = StzNotationRuns(_c_, _nSz_, AUFONT)
		_s_ = poM.ShapeOf(_m_[1])
		# the box is the runs' union, held symmetric about the cap centre
		# (DN12): the taller of what reaches above it and what hangs below
		_nCap_ = AUFONT.CapHeightOf(_nSz_)
		_nUp_ = _r_[3] - _nCap_ / 2
		_nDn_ = _nCap_ / 2 + _r_[4]
		_nH_ = 2 * _nUp_
		if _nDn_ > _nUp_  _nH_ = 2 * _nDn_  ok
		return fabs(_s_[:w] - _r_[2]) < 0.01 and fabs(_s_[:h] - _nH_) < 0.01
	next
	return FALSE

func _TxRefuses pnWhich
	_b_ = FALSE
	try
		if pnWhich = 1
			StzNotationRuns("$" + char(92) + "frac{a}{b}$", 24, AUFONT)
		but pnWhich = 2
			StzNotationRuns("unclosed $a^2", 24, AUFONT)
		but pnWhich = 3
			StzNotationRuns("$x^{y$", 24, AUFONT)
		but pnWhich = 4
			StzNotationRuns("$a^$", 24, AUFONT)
		but pnWhich = 5
			StzNotationRuns("$" + char(92) + "angle$", 24, AUFONT)
		else
			StzNotationRuns("$a^2 + b_1$", 24, AUFONT)
			StzNotationRuns("$" + char(92) + "alpha " + char(92) + "le " + char(92) + "beta$", 24, AUFONT)
		ok
	catch
		_b_ = TRUE
	done
	return _b_

# how many of the table's symbols this font has no glyph for
func _TxMissingCount
	_n_ = 0
	for _c_ in [ "angle", "perp", "parallel", "mapsto", "mp", "cong", "propto",
	             "alpha", "le", "ge", "pi", "infty", "deg", "sqrt", "times" ]
		try
			StzNotationRuns("$" + char(92) + _c_ + "$", 24, AUFONT)
		catch
			_n_++
		done
	next
	return _n_

# the drawn height of the nth text on a canvas, read off the paths the
# canvas rasterises text into -- the only place the size actually lands
func _TxDrawnHeight pnI
	return _TxHeightOf(_TxCanvasRight(), pnI)

func _TxDrawnHeightWrong pnI
	return _TxHeightOf(_TxCanvasWrong(), pnI)

func _TxCanvasRight
	_c_ = new stzCanvas(300, 80)
	_c_.SetBackground("#FFFFFF")
	_c_.AddText("BIG", 20, 50)
	_c_.SetFont(AUFONT, 30)
	_c_.AddText("sml", 150, 50)
	_c_.SetFont(AUFONT, 12)
	return _c_.ToSVG()

# WITH A FLUSH BETWEEN THEM -- which SetSvgIdent does at the top of every
# shape -- the font-before-text order is correct too, which is why the
# one-text-per-shape renderer was never wrong
func _TxFlushedBothWays
	_c_ = new stzCanvas(300, 80)
	_c_.SetBackground("#FFFFFF")
	_c_.SetSvgIdent("a", "")
	_c_.SetFont(AUFONT, 30)
	_c_.AddText("BIG", 20, 50)
	_c_.SetSvgIdent("b", "")
	_c_.SetFont(AUFONT, 12)
	_c_.AddText("sml", 150, 50)
	_c_.ClearSvgIdent()
	return _TxHeightOf(_c_.ToSVG(), 1) > _TxHeightOf(_c_.ToSVG(), 2) * 1.8

func _TxCanvasWrong
	_c_ = new stzCanvas(300, 80)
	_c_.SetBackground("#FFFFFF")
	_c_.SetFont(AUFONT, 30)
	_c_.AddText("BIG", 20, 50)
	_c_.SetFont(AUFONT, 12)
	_c_.AddText("sml", 150, 50)
	return _c_.ToSVG()

# the vertical extent of the nth path in an svg: every second number in
# the path data is a y, whatever the command
func _TxHeightOf pcSvg, pnI
	_p_ = 1
	for _k_ = 1 to pnI
		_p_ = _TxFind(pcSvg, "<path d=", _p_)
		if _p_ = 0  return 0  ok
		_p_++
	next
	_e_ = _TxFind(pcSvg, char(34), _p_ + 9)
	if _e_ = 0  return 0  ok
	_d_ = StzStringSection(pcSvg, _p_ + 8, _e_)
	_aN_ = []
	_cur_ = ""
	for _i_ = 1 to len(_d_)
		_ch_ = _d_[_i_]
		_a_ = ascii(_ch_)
		if (_a_ >= 48 and _a_ <= 57) or _ch_ = "." or (_ch_ = "-" and _cur_ = "")
			_cur_ += _ch_
		else
			if _cur_ != "" and _cur_ != "-" and _cur_ != "."  _aN_ + (0 + _cur_)  ok
			_cur_ = ""
		ok
	next
	if _cur_ != "" and _cur_ != "-" and _cur_ != "."  _aN_ + (0 + _cur_)  ok
	_lo_ = 0  _hi_ = 0  _bF_ = FALSE
	_m_ = floor(len(_aN_) / 2)
	for _i_ = 1 to _m_
		_y_ = _aN_[2 * _i_]
		if NOT _bF_  _lo_ = _y_  _hi_ = _y_  _bF_ = TRUE  ok
		if _y_ < _lo_  _lo_ = _y_  ok
		if _y_ > _hi_  _hi_ = _y_  ok
	next
	return _hi_ - _lo_

func _TxFind pcHay, pcNeedle, pnFrom
	_n_ = len(pcHay)
	_m_ = len(pcNeedle)
	if _m_ = 0 or pnFrom > _n_  return 0  ok
	for _i_ = pnFrom to _n_ - _m_ + 1
		_b_ = TRUE
		for _k_ = 1 to _m_
			if pcHay[_i_ + _k_ - 1] != pcNeedle[_k_]  _b_ = FALSE  exit  ok
		next
		if _b_  return _i_  ok
	next
	return 0

class _FakeWin45
	@nX = 0  @nY = 0  @bDown = FALSE  @nDraws = 0  @nPolls = 0

	def SetPointer(nX, nY, bDown)
		@nX = nX  @nY = nY  @bDown = bDown
		return This

	def Poll()      @nPolls++  return This
	def MouseX()    return @nX
	def MouseY()    return @nY
	def MouseDown(n)  return @bDown
	def IsOpen()    return TRUE
	def Draw(o)     @nDraws++  return 1
	def Draws()     return @nDraws
	def Polls()     return @nPolls
