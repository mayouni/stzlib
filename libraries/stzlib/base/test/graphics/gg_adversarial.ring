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
nOk = 0  nBad = 0  nSecClock = 0

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
# AN EXPLICIT SIZE, so the two renders are comparable pixel for pixel.
# Left to natural sizing they differ in WIDTH -- a labelled diagram
# reserves room its unlabelled twin does not -- and the comparison
# answered "different sizes" rather than anything about labels. The
# reservation is section 15's subject; here it is a confound.
aLOpt = [ :Font = EFONT, :NodeWidth = 110, :NodeHeight = 40,
          :Width = 420, :Height = 320 ]
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
sec("-- 12. SetLayout HONOURS what it accepted -------------------")
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
for a in [ [ "a", "Idle" ], [ "b", "Busy" ], [ "c", "Done" ] ]
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
for _dch_ in _DiagChords(oOr.ToSVGXT([ :NodeWidth = 110, :NodeHeight = 40 ]),
	EDGERGB)
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
for aD in aDotSpan
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
for cRole in [ :Primary, :Success, :Warning, :Danger, :Info, :Neutral ]
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
for cRole in [ :Primary, :Success, :Warning, :Danger, :Info ]
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
for aTS in aTypeShape
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
for c in [ "L", "R", "T" ]
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
for c in [ "S", "A", "B" ]
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
for a in [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
           [ "api1", "API A" ], [ "api2", "API B" ],
           [ "db1", "DB A" ], [ "db2", "DB B" ], [ "log", "Logger" ] ]
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
for aP in aVP
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
for a in [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
           [ "api1", "API A" ], [ "api2", "API B" ],
           [ "db1", "DB A" ], [ "db2", "DB B" ], [ "log", "Logger" ] ]
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
for aN in oFC.RenderNodeRects()
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
for aN in oFC.RenderNodeRects()
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
for aN in oFC.RenderNodeRects()
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
for a in [ [ "a", "A" ], [ "b", "B" ], [ "c", "C" ] ]
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
for a in [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
           [ "api1", "API A" ], [ "api2", "API B" ] ]
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
for aN in oFC.RenderNodeRects()
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
for a in [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
           [ "api1", "API A" ], [ "api2", "API B" ],
           [ "db1", "DB A" ], [ "db2", "DB B" ], [ "log", "Logger" ] ]
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
for aN in oTD.RenderNodeRects()
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
for a in [ [ "a", "A" ], [ "c", "C" ], [ "b", "B" ] ]
	oBn.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oBn.AddEdge("a", "c")
oBn.AddEdge("c", "b")
oBn.AddEdge("a", "b")
oBn.AddClusterXTT("fence", "Fence", [ "c" ], "#5E35B1")
oBn.SetSplines("ortho")
cBn = oBn.ToSVGXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nBCx = 0  nBT = 0  nCB = 0
for aN in oBn.RenderNodeRects()
	if aN[5] = "b"
		nBCx = aN[1] + aN[3] / 2
		nBT = aN[2]
	but aN[5] = "c"
		nCB = aN[2] + aN[4]
	ok
next
aMid = _BorderCrossings(cBn, EDGERGB, nCB + 8, nBCx - 300, nBCx + 300, 1)
nDetour = -1
for v in aMid
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
for v in aBLow
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
for a in [ [ "top", "Top" ], [ "l", "L" ], [ "r", "R" ], [ "far", "FAR" ] ]
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
for p in oClr.RenderEdgePaths()
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
for aL in aLbs
	# own-path distance, same interval arithmetic as the placer's
	nOwn = 1000000
	for aP in oLb.RenderEdgePaths()
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
for aL in oLd.RenderLabels()
	bOn33 = 0
	for aP in oLd.RenderEdgePaths()
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
for aP in oLd.RenderEdgePaths()
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
for r in oLd.RenderNodeRects()
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
for nKids in [ 2, 3, 4, 5, 6 ]
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
	for rr in oC.RenderNodeRects()
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
for a in [ "a", "b", "c", "d" ]
	oCh.AddNodeXTT(a, StzUpper(a), [ :type = "box", :color = "Info.Solid" ])
next
oCh.AddEdge("a", "b")  oCh.AddEdge("b", "c")  oCh.AddEdge("c", "d")
oCh.SetSplines("ortho")
oCh.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nSpread = 0
nFirst = -100000
for rr in oCh.RenderNodeRects()
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
for rr in oTwo.RenderNodeRects()
	aAt + [ rr[5], rr[1] + rr[3] / 2 ]
next
nP = 0  nQ = 0
aPk = []  aQk = []
for e in aAt
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
for a in [ "p", "k1", "k2", "s" ]
	oShr.AddNodeXTT(a, StzUpper(a), [ :type = "box", :color = "Info.Solid" ])
next
oShr.AddNodeXTT("far", "FAR", [ :type = "box", :color = "Info.Solid" ])
oShr.AddEdge("p", "k1")     oShr.AddEdge("p", "k2")
oShr.AddEdge("s", "far")    oShr.AddEdge("k1", "far")
oShr.SetSplines("ortho")
oShr.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nK1 = -100000  nFar = -100000
for rr in oShr.RenderNodeRects()
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
for a in [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
           [ "api1","API A" ],[ "api2","API B" ],
           [ "db1","DB A" ],[ "db2","DB B" ],[ "log","Logger" ] ]
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
for r in oRy.RenderNodeRects()
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
for p in oRy.RenderEdgePaths()
	aF = p[2]
	aV = []
	for i = 1 to len(aF) - 3 step 2
		if fabs(aF[i+2] - aF[i]) < 0.5 and fabs(aF[i+3] - aF[i+1]) > 1
			aV + fabs(aF[i+3] - aF[i+1])
		ok
	next
	bCross = 0
	for v in aV
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
for c in oRy.RenderClusterRects()
	if c[2] < nFrameTop  nFrameTop = c[2]  ok
next
nChan = -1
for p in oRy.RenderEdgePaths()
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
for a in [ "p", "c1", "c2" ]
	oFlat.AddNodeXTT(a, StzUpper(a), [ :type = "box", :color = "Info.Solid" ])
next
oFlat.AddEdge("p", "c1")  oFlat.AddEdge("p", "c2")
oFlat.AddClusterXTT("g", "G", [ "c1", "c2" ], "#5E35B1")
nFlat = oFlat._ClusterChromeAbove(13)
oNest = new stzDiagram("nest36")
for a in [ "p", "c1", "c2" ]
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
for a in [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
           [ "api1","API A" ],[ "api2","API B" ],
           [ "db1","DB A" ],[ "db2","DB B" ],[ "log","Logger" ] ]
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
for p in oSv.RenderEdgePaths()
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
for r in oSv.RenderNodeRects()
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
for c in oSv.RenderClusterRects()
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
for c in oSv.RenderClusterRects()
	if StzFindFirst("db1", c[5]) > 0 and StzFindFirst("api1", c[5]) = 0
		nData = c[2]
	ok
next
nApiB = 0  nDbT = 0
for r in oSv.RenderNodeRects()
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
for p in oFan.RenderEdgePaths()
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
for a in [ "p", "q" ]
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
for r in oFm.RenderNodeRects()
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
for e in oFm.Edges()
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
for r in oOne.RenderNodeRects()
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
for a in [ [ "p","P" ],[ "a","A" ],[ "b","B" ],[ "far","FAR" ] ]
	oCl.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oCl.AddEdge("p", "a")  oCl.AddEdge("p", "b")  oCl.AddEdge("p", "far")
oCl.AddClusterXTT("g", "G", [ "a", "b" ], "#5E35B1")
oCl.SetSplines("ortho")
oCl.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nFrameR = 0
for c in oCl.RenderClusterRects()
	if c[1] + c[3] > nFrameR  nFrameR = c[1] + c[3]  ok
next
nFarL = 1000000
for r in oCl.RenderNodeRects()
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
	for r in oPl.RenderNodeRects()
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
for r in oPl.RenderNodeRects()
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
for a in [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
           [ "api1","API A" ],[ "api2","API B" ],
           [ "db1","DB A" ],[ "db2","DB B" ] ]
	oSv.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oSv.AddEdge("lb","web1")   oSv.AddEdge("lb","web2")
oSv.AddEdge("web1","api1") oSv.AddEdge("web2","api2")
oSv.AddEdge("api1","db1")  oSv.AddEdge("api2","db2")
oSv.SetSplines("ortho")
oSv.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nLb = 0  nW1 = 0  nW2 = 0  nA1 = 0  nD1 = 0
for r in oSv.RenderNodeRects()
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
for r in oFn.RenderNodeRects()
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
for aS in aPg
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
for a in [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ] ]
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
for r in oPk.RenderNodeRects()
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
for p in aEP
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
chk("a pick costs well under a millisecond", nMs < 1)
chkeq("...and every one of them found its node", nHit, nPicks)

#---------------------------------------------------------------------------
? ""
sec("-- 41. GG7b: a PIN outranks the layout ------------------------")
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
for rr in oPn.RenderNodeRects()  aFree + [ rr[5], rr[1] + rr[3] / 2 ]  next
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
for rr in oPn.RenderNodeRects()
	aPinned + [ rr[5], rr[1] + rr[3] / 2 ]
next
? "   pinned to slot 10: k1 at " + _Xof42(aPinned, "k1") + ", k4 at " +
  _Xof42(aPinned, "k4")
chk("a pinned cell moves PAST its siblings",
    _Xof42(aPinned, "k1") > _Xof42(aPinned, "k4"))
nGone = 0
for a in [ "k2", "k3", "k4" ]
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
for rr in oPn.RenderNodeRects()
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
for rr in oAg.RenderNodeRects()  aBefore + [ rr[5], rr[1] + rr[3] / 2 ]  next
# k1 is leftmost already; pinning it to the far left agrees with that
oAg.Pin("k1", 0 - 3)
oAg.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36 ])
nOrderKept = 1
for a in [ "k1", "k2", "k3", "k4" ]
	for b in [ "k1", "k2", "k3", "k4" ]
		if a = b  loop  ok
		bB = _Xof42(aBefore, a) < _Xof42(aBefore, b)
		aNow = []
		for rr in oAg.RenderNodeRects()
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
for rr in oPf.RenderNodeRects()
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
for rr in oSs.RenderNodeRects()
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
for rr in oSs.RenderNodeRects()
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
for a in [ [ "web1", "Web A" ], [ "web2", "Web B" ] ]
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
for a in [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
           [ "api1","API A" ],[ "api2","API B" ],
           [ "db1","DB A" ],[ "db2","DB B" ],[ "log","Logger" ] ]
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
for p2 in aAuP
	aE2 = StzSplit(p2[1], ">")
	nSx = -1  nTx2 = -1
	for r in oAu.RenderNodeRects()
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
for a in [ [ "root","Root" ], [ "spine","Spine" ], [ "leafa","Leaf A" ],
           [ "deep","Deep" ] ]
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
for _cf_ in StzFindAll("<rect", cSvgS)
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
for a in [ [ "a","A" ],[ "b","B" ],[ "c","C" ],[ "d","D" ] ]
	oRw.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oRw.AddEdge("a","b")  oRw.AddEdge("a","c")  oRw.AddEdge("b","d")
oRw.SetSplines("ortho")
oRw.ToCanvasXT([ :NodeWidth = 96, :NodeHeight = 36, :Width = 900, :Height = 600 ])

# the a>c path, pressed 8px shy of its arrow end
aRwP = []
for p49 in oRw.RenderEdgePaths()
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
for p49 in oRw.RenderEdgePaths()
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
for aDnK in [ [ "task", "box" ], [ "decision", "diamond" ],
              [ "database", "cylinder" ], [ "start", "ellipse" ],
              [ "end", "doublecircle" ], [ "state", "circle" ] ]
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
for aDnR in aDnF
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
for aOgR in aOg
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
for r53 in aSmR
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
for r53 in aSm53
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
for aLcL in oLc.RenderLabels()
	_nLcMin_ = 1000000
	for aLcP in oLc.RenderEdgePaths()
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
for aLcN in oLc.RenderNodeLabels()
	if aLcN[6] = 1
		nLcOut++
		# below means BELOW: the plate's top at or under the glyph's
		# bottom, for the two circle-family cells
		for aLcR in oLc.RenderNodeRects()
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
for aLcN in oLc.RenderNodeLabels()
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
for aLcN in oLc2.RenderNodeLabels()
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
for aTwP in oTw.RenderEdgePaths()
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
for rTw in oTw.RenderNodeRects()
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
for rRg in aRgR
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
for vRg in aRgRad
	if vRg < nRgLo  nRgLo = vRg  ok
	if vRg > nRgHi  nRgHi = vRg  ok
next
? "   border radii " + nRgLo + ".." + nRgHi + " , hub at " + nRgHub
chk("the peers sit on ONE circle -- a border, not a rank",
    nRgHi - nRgLo < 2)
chk("...and the hub is in the MIDDLE, not on it", nRgHub < nRgLo / 2)

# THE ENTRY OPENS THE RING AT THE TOP, where every convention puts it
nRgInitY = 0  nRgTop = 1000000
for rRg in aRgR
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
for aRgP in oRg.RenderEdgePaths()
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
for rRg in oRg2.RenderNodeRects()
	if rRg[5] = "p"  nRg2 = rRg[2]  ok
next
nRg2b = 1000000
for rRg in oRg2.RenderNodeRects()
	if rRg[5] != "p" and rRg[2] < nRg2b  nRg2b = rRg[2]  ok
next
chk("a diagram that declares no layout mode is still LAYERED",
    nRg2 < nRg2b - 20)


sec("-- 57. MODES: a state machine has no NEXT -------------------")
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
for cMd in aMdC
	for idMd in cMd[:nodes]
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
for cMd in aMdC
	for idMd in cMd[:nodes]
		if StzLower("" + idMd) = "init"  nMdSolo++  ok
		if StzLower("" + idMd) = "gone"  nMdSolo++  ok
	next
next
chkeq("a state you cannot return to is not a region", nMdSolo, 0)

# NO ORDER INSIDE A MODE: the peers share a row, so the picture makes no
# claim about which comes first -- that is the whole correction
aMdR = oMd.RenderNodeRects()
nMdY = -1  nMdSame = 0
for rMd in aMdR
	if rMd[5] = "closed"  nMdY = rMd[2]  ok
next
for rMd in aMdR
	if rMd[5] = "open" or rMd[5] = "locked"
		if fabs(rMd[2] - nMdY) < 2  nMdSame++  ok
	ok
next
chkeq("states you move freely among are drawn as PEERS, unordered",
      nMdSame, 2)

# AND THE IRREVERSIBLE PASSAGE IS THE ONLY THING RANKED
nMdInit = -1  nMdGone = -1
for rMd in aMdR
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
for cMd in oMd2.Clusters()
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
for cMd in oMd3.Clusters()
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
for rMk in oMk.RenderNodeRects()
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
for aMkP in oMk.RenderEdgePaths()
	aMkE = StzSplit(aMkP[1], ">")
	if len(aMkE) != 2  loop  ok
	if aMkE[2] != "e"  loop  ok
	_fMk_ = aMkP[2]
	_nMk_ = len(_fMk_)
	if _nMk_ < 4  loop  ok
	for rMk in oMk.RenderNodeRects()
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
for rMk in oMk2.RenderNodeRects()
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

# UNIFIED AT THE MARK: both arrivals end at the same point, which is the
# mark's own centre-line -- one arrow, not two grazing a dot
aLwA = []  aLwB = []
for aLwP in oLw.RenderEdgePaths()
	if aLwP[1] = "still>e"   aLwA = aLwP[2]  ok
	if aLwP[1] = "moving>e"  aLwB = aLwP[2]  ok
next
chk("both edges into the mark are drawn",
    len(aLwA) >= 4 and len(aLwB) >= 4)
nLwDx = fabs(aLwA[ len(aLwA) - 1 ] - aLwB[ len(aLwB) - 1 ])
? "   the two arrivals differ by " + nLwDx + "px at the mark"
chk("edges arriving at a MARK are unified before reaching it",
    nLwDx < 1)
nLwMx = -1
for rLw in oLw.RenderNodeRects()
	if rLw[5] = "e"  nLwMx = rLw[1] + rLw[3] / 2  ok
next
chk("...on the mark's own centre-line", fabs(aLwA[ len(aLwA) - 1 ] - nLwMx) < 2)

# ...AND THE SAME AT A DEPARTURE: one stem out of the entry mark
nLwOut = 0
for aLwP in oLw.RenderEdgePaths()
	aLwE = StzSplit(aLwP[1], ">")
	if len(aLwE) = 2 and aLwE[1] = "i"  nLwOut++  ok
next
chkeq("the entry mark has one edge, drawn from its centre", nLwOut, 1)

# VERTICALITY: a lone state sits on its one neighbour's column
nLwI = -1  nLwS = -1
for rLw in oLw.RenderNodeRects()
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
for aLwR in oLw2.RenderClusterRects()
	for aLwP in oLw2.RenderEdgePaths()
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
for rLw in oLw3.RenderNodeRects()
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
for rLw in oLw4.RenderNodeRects()
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
for aFmR in oFm.RenderEdgePaths()
	if aFmR[1] = "closed>open"  aFmP = aFmR[2]  ok
next
? "   the peer edge has " + (len(aFmP) / 2) + " points"
chkeq("two neighbours on one row are joined by ONE segment",
      len(aFmP), 4)
chk("...and it is horizontal, with no hook into a border",
    fabs(aFmP[2] - aFmP[4]) < 1)

# "too tight" -- the rail stands clear of the frame it lives in
nFmRail = -1
for aFmR in oFm.RenderEdgePaths()
	if aFmR[1] != "open>closed"  loop  ok
	for iFm = 2 to len(aFmR[2]) step 2
		if aFmR[2][iFm] > nFmRail  nFmRail = aFmR[2][iFm]  ok
	next
next
nFmBot = -1
for aFmC in oFm.RenderClusterRects()
	if aFmC[2] + aFmC[4] > nFmBot  nFmBot = aFmC[2] + aFmC[4]  ok
next
? "   the rail sits " + (nFmBot - nFmRail) + "px above the frame's rule"
chk("a rail inside a frame keeps its air", nFmBot - nFmRail >= 12)
chk("...and is inside it at all", nFmRail < nFmBot)

# "waste" -- the entry gap holds what crosses it and no more. Compared
# against the frame's own chrome, which is the only thing that
# legitimately lives there.
nFmIy = -1  nFmTop = 1000000
for rFm in oFm.RenderNodeRects()
	if rFm[5] = "i"  nFmIy = rFm[2] + rFm[4]  ok
next
for aFmC in oFm.RenderClusterRects()
	if aFmC[2] < nFmTop  nFmTop = aFmC[2]  ok
next
? "   the entry gap is " + (nFmTop - nFmIy) + "px above the frame"
chk("an unlabelled entry gap is not twice what stands in it",
    nFmTop - nFmIy < 200)

# "mal positioned" -- every event label sits on ITS OWN edge's ink
nFmFar = 0
for aFmL in oFm.RenderLabels()
	_dFm_ = 1000000
	for aFmR in oFm.RenderEdgePaths()
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
for rLn in oLn.RenderNodeRects()
	if rLn[5] = "closed"  nLnRow = rLn[2] + rLn[4] / 2  ok
next
chk("...both below the row they return along",
    nLn1 > nLnRow and nLn2 > nLnRow)

# ...AND EACH LABEL ON ITS OWN LANE
nLnC = -1  nLnU = -1
for aLnL in oLn.RenderLabels()
	if aLnL[1] = "close"   nLnC = aLnL[3]  ok
	if aLnL[1] = "unlock"  nLnU = aLnL[3]  ok
next
chk("each event sits on its own return, not between two",
    fabs(nLnC - nLnU) >= oLn._LineClearance() - 1)

# THE FRAME HOLDS THEM, and holds nothing else: no more than a pad of
# empty floor under the lowest rail
nLnBot = -1
for aLnC in oLn.RenderClusterRects()
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
for rLn in oLn.RenderNodeRects()
	if rLn[5] = "i"  nLnI = rLn[2] + rLn[4]  ok
next
for aLnC in oLn.RenderClusterRects()
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
for aU3 in [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
             [ "api1","API A" ],[ "api2","API B" ],
             [ "db1","DB A" ],[ "db2","DB B" ],[ "log","Logger" ] ]
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
for aUniS in aUni
	cUniN = aUniS[1]
	oUni = aUniS[2]

	# (a) EVERY EDGE TOUCHES BOTH ITS NODES
	for aUniP in oUni.RenderEdgePaths()
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
	for aUniL in oUni.RenderLabels()
		aUniK = StzSplit("" + aUniL[6], ">")
		if len(aUniK) != 2  loop  ok
		for aUniC in oUni.RenderClusterRects()
			bUniIn = 0
			for cUniM in aUniC[5]
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
	for aUniP in oUni.RenderEdgePaths()
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
			for rUni in oUni.RenderNodeRects()
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
	for aUniL in oUni.RenderLabels()
		for aUniP in oUni.RenderEdgePaths()
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
	for aUniL in oUni.RenderLabels()
		for aUniC in oUni.RenderClusterRects()
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
for rUg in oUg.RenderNodeRects()
	if rUg[5] = "i"     nUgI = rUg[2] + rUg[4]  ok
	if rUg[5] = "gone"  nUgG = rUg[2]  ok
next
nUgTop = 1000000  nUgBot = 0
for cUg in oUg.RenderClusterRects()
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
	for aUpL in oUp.RenderLabels()
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
for aBtP in oBt.RenderEdgePaths()
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
for aBtP in oBt.RenderEdgePaths()
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
for rIn in oIn.RenderNodeRects()
	if rIn[5] = "p0"  nInRow = rIn[2] + rIn[4] / 2  ok
next
aInDepth = []
for cInK in [ "p1>p0", "a1>a0", "d1>d0" ]
	aInP = []
	for aInR in oIn.RenderEdgePaths()
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
for aInC in oIn.RenderClusterRects()
	for cInK in [ "p1>p0", "a1>a0", "d1>d0" ]
		for aInR in oIn.RenderEdgePaths()
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
for rDr in oDr.RenderNodeRects()
	if rDr[5] = "closed"  nDrRow = rDr[2] + rDr[4] / 2  ok
next
nDrDeep = nDrRow
for cDrK in [ "open>closed", "closed>locked", "locked>closed" ]
	for aDrR in oDr.RenderEdgePaths()
		if aDrR[1] != cDrK  loop  ok
		nDrN = len(aDrR[2]) / 2
		for iDr = 1 to nDrN
			if aDrR[2][iDr * 2] > nDrDeep  nDrDeep = aDrR[2][iDr * 2]  ok
		next
	next
next
nDrFloor = 0
for aDrC in oDr.RenderClusterRects()
	if aDrC[2] + aDrC[4] > nDrFloor  nDrFloor = aDrC[2] + aDrC[4]  ok
next
? "   three rails, the deepest at y=" + nDrDeep + ", floor at y=" + nDrFloor
chk("a frame holds every rail, not just the ones a pair asked for",
    nDrFloor >= nDrDeep)

# ...AND THE PAIR THAT BOTH STEPPED ASIDE IS STILL TWO STAIRCASES, not
# one mirrored into a diagonal off the edge of its own picture.
nDrSkew = 0
for cDrK in [ "closed>locked", "locked>closed" ]
	for aDrR in oDr.RenderEdgePaths()
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
for aPpO in [ oBt, oIn, oDr ]
	nPpX1 = 0  nPpY1 = 0
	for rPp in aPpO.RenderNodeRects()
		if rPp[1] + rPp[3] > nPpX1  nPpX1 = rPp[1] + rPp[3]  ok
		if rPp[2] + rPp[4] > nPpY1  nPpY1 = rPp[2] + rPp[4]  ok
	next
	for rPp in aPpO.RenderClusterRects()
		if rPp[1] + rPp[3] > nPpX1  nPpX1 = rPp[1] + rPp[3]  ok
		if rPp[2] + rPp[4] > nPpY1  nPpY1 = rPp[2] + rPp[4]  ok
	next
	for aPpP in aPpO.RenderEdgePaths()
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
	for aPpL in aPpO.RenderNodeLabels()
		if aPpL[2] + aPpL[4] > nPpX1  nPpX1 = aPpL[2] + aPpL[4]  ok
		if aPpL[3] + aPpL[5] > nPpY1  nPpY1 = aPpL[3] + aPpL[5]  ok
	next
	for aPpL in aPpO.RenderLabels()
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
for aAhO in [ oBt, oIn, oDr ]
	for aAhP in aAhO.RenderEdgePaths()
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
for rLd in oLd.RenderNodeRects()
	nLdCy = rLd[2] + rLd[4] / 2
	aLdX = []
	for aLdP in oLd.RenderEdgePaths()
		nLdN = len(aLdP[2]) / 2
		for iLd in [ 1, nLdN ]
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
for rLd in oLd.RenderNodeRects()
	if rLd[5] != "c"  loop  ok
	for aLdP in oLd.RenderEdgePaths()
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
for rLd in oLd.RenderNodeRects()
	if rLd[5] = "a"  nLdRow = rLd[2] + rLd[4] / 2  ok
next
aLdRun = []
for aLdP in oLd.RenderEdgePaths()
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
for rAir in oAir.RenderClusterRects()  aAirF = rAir  next
nAirT = 1000000  nAirL = 1000000  nAirR = 0  nAirB = 0
for rAir in oAir.RenderNodeRects()
	if rAir[2] < nAirT  nAirT = rAir[2]  ok
	if rAir[1] < nAirL  nAirL = rAir[1]  ok
	if rAir[1] + rAir[3] > nAirR  nAirR = rAir[1] + rAir[3]  ok
	if rAir[2] + rAir[4] > nAirB  nAirB = rAir[2] + rAir[4]  ok
next
for aAirL in oAir.RenderLabels()
	if aAirL[3] + aAirL[5] / 2 > nAirB  nAirB = aAirL[3] + aAirL[5] / 2  ok
next
# ...AND THE RAILS THEMSELVES. A rail writes its word above its own
# line, so the deepest ink in a frame is the deepest LINE -- measuring
# only the words answered the air under a word that has a rail beneath
# it, which is not the distance anybody looks at.
for aAirP in oAir.RenderEdgePaths()
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
for rInk in oInk.RenderNodeRects()
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
for cWtId in [ "m", "s" ]
	iWtN++
	aWtR = []
	for rWt in oWt.RenderNodeRects()
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
for aMidL in oMid.RenderLabels()
	for aMidP in oMid.RenderEdgePaths()
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
for rDr7 in oDr7.RenderClusterRects()  aFr7 = rDr7  next
nMk7I = 0  nMk7G = 0
for rDr7 in oDr7.RenderNodeRects()
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
for rDr7 in oDr7.RenderNodeRects()
	if rDr7[5] = "i" or rDr7[5] = "gone"  loop  ok
	if rDr7[1] < nL7  nL7 = rDr7[1]  ok
	if rDr7[1] + rDr7[3] > nR7  nR7 = rDr7[1] + rDr7[3]  ok
next
for aL7 in oDr7.RenderLabels()
	if aL7[2] + aL7[4] / 2 > nR7  nR7 = aL7[2] + aL7[4] / 2  ok
next
for aP7 in oDr7.RenderEdgePaths()
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
for rEx in oEx.RenderNodeRects()
	if rEx[5] = "pend"  nExRow = rEx[2] + rEx[4] / 2  ok
next
aExRun = []
for aExP in oEx.RenderEdgePaths()
	nExN = len(aExP[2]) / 2
	for iEx = 1 to nExN - 1
		if fabs(aExP[2][iEx * 2] - aExP[2][iEx * 2 + 2]) > 1  loop  ok
		if fabs(aExP[2][iEx * 2 + 1] - aExP[2][iEx * 2 - 1]) < 20  loop  ok
		if aExP[2][iEx * 2] <= nExRow + 4  loop  ok
		# one RUN, not one segment: a staircase can turn twice at the
		# same depth and that is still one line at that depth
		bExSeen = 0
		for nExQ in aExRun
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
for aExC in oEx.RenderClusterRects()
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
nHpRoom = nHpR * 2 + oHp._LineClearance()
nHpBad = 0
nHpNear = 1000000
for aHp in oHp.RenderHops()
	for aHpP in oHp.RenderEdgePaths()
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
for cBpK in [ "entry", "invoke", "human", "event-wait", "timer-wait",
	"compensate", "step", "gateway", "terminal", "suspension" ]
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
for rBp in oBp.RenderNodeRects()
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
for aBpL in oBp.RenderNodeLabels()
	if aBpL[6] != 1  loop  ok       # the ones written OUTSIDE their glyph
	if aBpL[2] - aBpL[4] / 2 < 0  nBpOff++  ok
	if aBpL[2] + aBpL[4] / 2 > oBp.LastCanvas().Width()  nBpOff++  ok
next
chkeq("a name written outside its mark stays on the paper", nBpOff, 0)

# (7) ...AND THE PICTURE STILL OBEYS THE CONTRACT. A domain is a
#     profile, not an exemption: every law sections 62 and 63 hold of
#     every other template holds here.
nBpBad = 0
for aBpE in oBp.Edges()
	rBpA = _Rect49(oBp, StzLower("" + aBpE[:from]))
	rBpB = _Rect49(oBp, StzLower("" + aBpE[:to]))
	aBpP = []
	for aBpR in oBp.RenderEdgePaths()
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
for cSpN in [ "s", "recv", "check", "pack", "bill", "done" ]
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
for cGlN in StzNotations()
	oGl = StzNotation(cGlN)
	for cGlK in oGl.Kinds()
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
for rCn in oBp.RenderNodeRects()
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
for aSmE in [ [ "g", "ship" ], [ "g", "back" ] ]
	aSmP = []
	for aSmR in oSm.RenderEdgePaths()
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
for aSmR in oSm.RenderEdgePaths()
	nSmN = len(aSmR[2]) / 2
	for iSm = 1 to nSmN
		if aSmR[2][iSm * 2 - 1] < 0  nSmOff++  ok
		if aSmR[2][iSm * 2] < 0  nSmOff++  ok
		if aSmR[2][iSm * 2 - 1] > oSm.LastCanvas().Width()  nSmOff++  ok
		if aSmR[2][iSm * 2] > oSm.LastCanvas().Height()  nSmOff++  ok
	next
next
chkeq("every flow is drawn on the paper it was measured for", nSmOff, 0)


#---------------------------------------------------------------------------
? ""
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
	for _a_ in [ [ "p","Parent" ], [ "l","Left" ], [ "r","Right" ],
	             [ "d","Deep" ] ]
		_g_.AddNodeXTT(_a_[1], _a_[2], [ :type = "box", :color = "#4477FF" ])
	next
	_g_.AddEdge("p","l")  _g_.AddEdge("p","r")  _g_.AddEdge("l","d")
	_g_.SetSplines("ortho")
	return _g_

func _G50
	_g_ = new stzDiagram("g50")
	for _a_ in [ [ "lb","Balancer" ],[ "web1","Web A" ],[ "web2","Web B" ],
	             [ "api1","API A" ],[ "api2","API B" ],
	             [ "db1","DB A" ],[ "db2","DB B" ],[ "log","Logger" ] ]
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
	for _lp62_ in oDg.RenderEdgePaths()
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
	for _r49_ in oDg.RenderNodeRects()
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
	for _drR_ in aRects
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
	for _drR_ in _drW_
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
	for _erR_ in aRects
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
	for _r_ in oDiag.RenderNodeRects()
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
	for _r_ in oDiag.RenderNodeRects()
		if _r_[5] = StzLower("" + cId)  return _r_[1] + _r_[3] / 2  ok
	next
	return -1

func _Xof42 aList, cId
	for _e_ in aList
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
	for _bcP_ in StzFindAll('<polyline points="', cSvg)
		_bcT_ = StzSubStr(cSvg, _bcP_, min([ 6000, _bcL_ - _bcP_ + 1 ]))
		_bcQ_ = StzFindFirst('"', StzSubStr(_bcT_, 19, StzLen(_bcT_) - 18))
		if _bcQ_ = 0  loop  ok
		_bcTag_ = StzFindFirst(">", _bcT_)
		if _bcTag_ = 0  loop  ok
		if StzFindFirst(cStroke, StzSubStr(_bcT_, 1, _bcTag_)) = 0  loop  ok
		_bcPrev_ = []
		for _bcPr_ in StzSplit(StzSubStr(_bcT_, 19, _bcQ_ - 1), " ")
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
	for _dp_ in StzFindAll('<polyline points="', cSvg)
		_dtail_ = StzSubStr(cSvg, _dp_, min([ 6000, _dlen_ - _dp_ + 1 ]))
		_dq_ = StzFindFirst('"', StzSubStr(_dtail_, 19, StzLen(_dtail_) - 18))
		if _dq_ = 0  loop  ok
		_dpts_ = StzSubStr(_dtail_, 19, _dq_ - 1)
		_dtagend_ = StzFindFirst(">", _dtail_)
		if _dtagend_ = 0  loop  ok
		if StzFindFirst(cStroke, StzSubStr(_dtail_, 1, _dtagend_)) = 0  loop  ok
		_dprev_ = []
		for _dpair_ in StzSplit(_dpts_, " ")
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
func _Upscaled oC
	_uw_ = oC.Width()
	_uh_ = oC.Height()
	_up_ = oC.ToPixels()
	_uo_ = ""
	for _uy_ = 0 to _uh_ * 2 - 1
		for _ux_ = 0 to _uw_ * 2 - 1
			_ua_ = (floor(_uy_ / 2) * _uw_ + floor(_ux_ / 2)) * 4 + 1
			_uo_ += substr(_up_, _ua_, 4)
		next
	next
	return [ _uw_ * 2, _uh_ * 2, _uo_ ]

# Percentage of sampled pixels where the two disagree. Takes either a
# canvas or the [w,h,pixels] an enlargement returns.
func _DiffFromUpscale oSmall, xBig
	_da_ = _Upscaled(oSmall)
	if isList(xBig)
		_dw_ = xBig[1]  _dh_ = xBig[2]  _db_ = xBig[3]
	else
		_dw_ = xBig.Width()  _dh_ = xBig.Height()  _db_ = xBig.ToPixels()
	ok
	if _dw_ != _da_[1] or _dh_ != _da_[2]  return 100  ok
	# COUNTED WHERE THERE IS INK, not over the whole canvas. Sampling
	# everything put most of a mostly-white picture into the denominator
	# and reported 1% -- true, and useless: the two renders agree
	# perfectly about the background, and every difference that matters
	# lives on a glyph or an edge. A metric diluted by the part nobody
	# disputes cannot see the part they do.
	_dn_ = min([ len(_da_[3]), len(_db_) ])
	_dc_ = 0  _dt_ = 0
	_di_ = 1
	while _di_ <= _dn_ - 3
		_dva_ = ascii(substr(_da_[3], _di_, 1))
		_dvb_ = ascii(substr(_db_, _di_, 1))
		if _dva_ < 245 or _dvb_ < 245
			_dt_++
			if fabs(_dva_ - _dvb_) > 12  _dc_++  ok
		ok
		_di_ += 4
	end
	if _dt_ = 0  return 0  ok
	return floor(_dc_ * 100 / _dt_)

# Edge polylines whose FIRST step moves AGAINST the rank direction -- in a
# top-down picture, upward. Aim-angled departures are grammar v3's right;
# backward ones are a hook at the source in any grammar.
func _BackwardDepartures cSvg, cStroke
	_sd_ = 0
	_slen2_ = StzLen(cSvg)
	for _sp2_ in StzFindAll('<polyline points="', cSvg)
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
	for _e_ in oDiag.Edges()
		_xa_ = _XOf(aPos, "" + _e_[:from])
		_xb_ = _XOf(aPos, "" + _e_[:to])
		if _xa_ < 0 or _xb_ < 0  loop  ok
		_d_ = fabs(_xa_ - _xb_)
		if _d_ > 0.5 and _d_ < 40  _nm_++  ok
	next
	return _nm_

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
