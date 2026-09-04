load "../../stzBase.ring"
load "gg_drakon_scenes.ring"

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
aDS = oShort._LabelDemand(SFONT, 14, 70, SLOT, 0)
aDW = oWide._LabelDemand(SFONT, 14, 70, SLOT, 0)
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
aDU = oUnbr._LabelDemand(SFONT, 14, 70, SLOT, 0)
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

# -- TWO INDEPENDENT READINGS OF THE SAME TRUTH --------------------------
# aDischarged is built at RUN time by the discharges() calls as each section
# is reached. StzSuiteDischargesOf reads the same declarations STATICALLY
# out of the source. They are separate code paths over separate inputs, and
# a house law says an identity computed from one set of anchors proves
# nothing -- so the check that means something is these two agreeing. It
# also catches a declaration attached to a section that never runs.
aPcStatic = StzSuiteDischargesOf([ "gg_adversarial.ring" ])
chkeq("runtime and static declaration counts agree",
      len(aDischarged), len(aPcStatic))
bPcSame = TRUE
nPcD = len(aDischarged)
for iPc = 1 to nPcD
	bPcFound = FALSE
	nPcS = len(aPcStatic)
	for jPc = 1 to nPcS
		if aPcStatic[jPc][1] = aDischarged[iPc][1] and
		   aPcStatic[jPc][2] = aDischarged[iPc][2]
			bPcFound = TRUE
			exit
		ok
	next
	if NOT bPcFound  bPcSame = FALSE  ok
next
chk("and every runtime pair is present in the static parse", bPcSame)
bPcBogus = FALSE
nPcS = len(aPcStatic)
for jPc = 1 to nPcS
	if aPcStatic[jPc][1] = "ZZ9"  bPcBogus = TRUE  ok
next
chk("NEGATIVE: an item no section declares is ABSENT from the static parse",
    NOT bPcBogus)

# -- and the artefact itself ---------------------------------------------
cPcPath = "../../graphics/SOFTANZA_GRAPH_PLANE_PLAN.md"
aPcLive = StzCheckPlanCoverage(read(cPcPath), cPcPath, aDischarged)
nPcL = len(aPcLive)
for iPc = 1 to nPcL
	? "   STALE  " + aPcLive[iPc][:where] + "  " + aPcLive[iPc][:rule]
	? "          " + aPcLive[iPc][:message]
next
chk("THE PLAN'S GENERATED TABLE IS CURRENT", nPcL = 0)
? "   declarations this suite made: " + len(aDischarged) +
  " over " + len(StzPlanItemsOf(read(cPcPath))) + " plan items"


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
