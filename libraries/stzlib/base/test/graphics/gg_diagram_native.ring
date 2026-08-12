load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	A DIAGRAM THAT NEEDS NO GRAPHVIZ

	stzDiagram could only be SEEN by shelling out to dot.exe. It now answers
	ToSVG() with no GPU and no graphviz at all, and ToPNG() through the GPU,
	from ONE model.

	LAYOUT IS BORROWED, DRAWING IS NOT. Positions come from stzGraphCanvas --
	the engine-side layout GG1 built and guarded -- because a second layout
	implementation would diverge. The drawing is the diagram's own, because a
	diagram is a different picture from a graph: twenty-four shapes, labels
	inside, clusters behind.

	KILL CRITERION, written before the code and still true: dot wins on
	SPLINE edges routed around nodes and on NESTED clusters. This tier does
	neither, so ToDot() remains the honest answer for those. What it must do
	is every shape in the vocabulary, cluster containment, and no external
	binary.

	Run:  ring gg_diagram_native.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " THE NATIVE DIAGRAM TIER"
? "=============================================================="

# CODE AFTER A func NEVER RUNS in Ring, so every helper lives at the
# BOTTOM of the file. _Net() was up here first and the whole guard printed
# its banner and stopped.
#---------------------------------------------------------------------------
? ""
? "-- 1. It draws, with no external binary ---------------------"
#---------------------------------------------------------------------------

oD = _Net()
cSvg = oD.ToSVG()
? "   SVG : " + len(cSvg) + " chars"
chk("a diagram answers SVG with no device and no graphviz", len(cSvg) > 1000)
chk("and the dot LANGUAGE is still an export, not a dependency",
    len(oD.ToDot()) > 100)

#---------------------------------------------------------------------------
? ""
? "-- 2. Each node wears the shape IT declared -----------------"
#
# The vocabulary is only useful if the mapping is per-node. A diagram that
# drew every node as a box would still produce a plausible picture.
#---------------------------------------------------------------------------

aWant = [ [ "web", "box" ], [ "api", "hexagon" ], [ "db", "cylinder" ],
          [ "cache", "ellipse" ], [ "sla", "note" ] ]
nWrong = 0
for a in oD.Nodes()
	cGot = StzLower("" + oD._NativeShapeOf(a))
	for w in aWant
		if w[1] = StzLower("" + a[:id]) and w[2] != cGot
			nWrong++
			? "   " + a[:id] + " wanted " + w[2] + " got " + cGot
		ok
	next
next
chkeq("every node resolved to the shape it declared", nWrong, 0)

# an unknown shape must DEGRADE to a box, not refuse: one exotic name
# should not stop a whole diagram from drawing
oX = new stzDiagram("x")
oX.AddNodeXTT(:n, "N", [ :type = "Msquare", :color = "#444444" ])
chkeq("an unknown graphviz shape degrades to a box",
      StzLower("" + oX._NativeShapeOf(oX.Nodes()[1])), "box")

#---------------------------------------------------------------------------
? ""
? "-- 3. THE COLOUR BINDS TO ITS OWN NODE ----------------------"
#
# The defect this scene exists for. stzCanvas documents that Fill colours
# the PENDING shape, so styling before drawing lands the colour on the
# PREVIOUS thing -- and with edges drawn first, the first node's colour
# went onto an edge while every other node was right.
#
# A contact sheet hid it completely: every shape still had A colour, so
# the picture looked correct while the binding was wrong. Only sampling the
# pixel at a KNOWN node centre catches it.
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no device -- this is a pixel property; skipped)"
else
	W = 900  H = 620
	oC = oD.ToCanvasXT([ :Width = W, :Height = H ])
	cPx = oC.ToPixels()

	# where each node was actually placed, from the diagram's own layout
	oGC = new stzGraphCanvas(oD, [ :Layout = :Hierarchical,
		:Width = W - 156, :Height = H - 82 ])
	aPos = oGC.Positions()

	aFill = [ [ "web", 62, 110, 168 ], [ "api", 78, 140, 92 ],
	          [ "db", 140, 90, 78 ], [ "cache", 122, 90, 158 ],
	          [ "sla", 158, 140, 78 ] ]
	nBadCol = 0
	for p in aPos
		cId = StzLower("" + p[1])
		px = floor(p[2] + 78)
		py = floor(p[3] + 41)
		nAt = (py * W + px) * 4 + 1
		r = ascii(substr(cPx, nAt, 1))
		g = ascii(substr(cPx, nAt + 1, 1))
		b = ascii(substr(cPx, nAt + 2, 1))
		for f in aFill
			if f[1] = cId
				nD = fabs(r - f[2]) + fabs(g - f[3]) + fabs(b - f[4])
				? "   " + PadR(cId, 7) + " centre rgb " + r + "," + g + "," + b +
				  "   wanted " + f[2] + "," + f[3] + "," + f[4] +
				  iif(nD <= 24, "   ok", "   MISMATCH")
				if nD > 24  nBadCol++  ok
			ok
		next
	next
	chkeq("every node's centre is ITS OWN declared colour", nBadCol, 0)
ok

#---------------------------------------------------------------------------
? ""
? "-- 4. A cluster CONTAINS its members ------------------------"
#
# The one structural promise a cluster makes. Checked against the layout,
# not against the picture, so it holds with or without a device.
#---------------------------------------------------------------------------

W2 = 900  H2 = 620
oGC2 = new stzGraphCanvas(oD, [ :Layout = :Hierarchical,
	:Width = W2 - 156, :Height = H2 - 82 ])
aXY = []
for p in oGC2.Positions()
	aXY + [ StzLower("" + p[1]), p[2] + 78, p[3] + 41 ]
next
aBox = oD._ClusterBox(oD.Clusters()[1], aXY, 132, 58)
? "   cluster box : " + @@(aBox)
chk("the cluster produced a box", len(aBox) = 4)

nOutside = 0
for cM in [ "api", "db", "cache" ]
	for r in aXY
		if r[1] = cM
			if r[2] < aBox[1] or r[2] > aBox[1] + aBox[3] or
			   r[3] < aBox[2] or r[3] > aBox[2] + aBox[4]
				nOutside++
			ok
		ok
	next
next
chkeq("every member sits inside its cluster box", nOutside, 0)

# the negative sibling: a NON-member must be able to fall outside, or the
# check above is satisfied by a box that swallows the canvas
nWebIn = 0
for r in aXY
	if r[1] = "web"
		if r[2] >= aBox[1] and r[2] <= aBox[1] + aBox[3] and
		   r[3] >= aBox[2] and r[3] <= aBox[2] + aBox[4]
			nWebIn = 1
		ok
	ok
next
? "   'web' is not a member, and lands inside the box : " + nWebIn
chkeq("the cluster box does not swallow non-members", nWebIn, 0)

# a cluster naming nodes that are not in the diagram draws NOTHING rather
# than a rectangle at the origin
oG3 = new stzDiagram("ghost")
oG3.AddNodeXTT(:a, "A", [ :type = "box" ])
oG3.AddClusterXTT(:c, "C", [ :nowhere, :alsonowhere ], "#222222")
chkeq("a cluster of unknown nodes draws nothing",
      len(oG3._ClusterBox(oG3.Clusters()[1], [], 100, 50)), 0)

#---------------------------------------------------------------------------
? ""
? "-- 5. Refusals ----------------------------------------------"
#---------------------------------------------------------------------------

chk("an empty diagram refuses to draw", Raises('
	o = new stzDiagram("empty")
	o.ToSVG()
'))

#---------------------------------------------------------------------------
? ""
? "-- 6. The picture -------------------------------------------"
#---------------------------------------------------------------------------

write("gg_diagram_native.svg", oD.ToSVGXT([ :Width = 900, :Height = 620 ]))
? "   wrote gg_diagram_native.svg"
if StzGraphicsDevice()
	oD.ToPNGXT("gg_diagram_native.png", [ :Width = 900, :Height = 620 ])
	? "   wrote gg_diagram_native.png"
ok

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

func Raises cCode
	try
		eval(cCode)
	catch
		return TRUE
	done
	return FALSE

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_

func _Net()
	_o_ = new stzDiagram("net")
	_o_.AddNodeXTT(:web,   "Web",      [ :type = "box",      :color = "#3E6EA8" ])
	_o_.AddNodeXTT(:api,   "API",      [ :type = "hexagon",  :color = "#4E8C5C" ])
	_o_.AddNodeXTT(:db,    "Database", [ :type = "cylinder", :color = "#8C5A4E" ])
	_o_.AddNodeXTT(:cache, "Cache",    [ :type = "ellipse",  :color = "#7A5A9E" ])
	_o_.AddNodeXTT(:sla,   "SLA",      [ :type = "note",     :color = "#9E8C4E" ])
	_o_.AddEdge(:web, :api)
	_o_.AddEdge(:api, :db)
	_o_.AddEdge(:api, :cache)
	_o_.AddEdge(:db, :sla)
	_o_.AddClusterXTT(:backend, "Backend", [ :api, :db, :cache ], "#1B2740")
	return _o_
