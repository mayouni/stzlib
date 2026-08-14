load "../../stzBase.ring"

# ADVERSARIAL VISUAL PROBES -- things claimed but never exercised.
#
# Each writes a picture, and the point is to LOOK at them. Three real
# defects came out of this file that no green suite had reported: a
# cylinder cap deeper than it was wide, a rank of nodes drawn on top of
# one another, and a label whose spaces had been eaten. The properties
# they stand for are asserted in gg_adversarial.ring -- this file is the
# eye, that one is the ratchet.

if NOT StzGraphicsDevice()  ? "no device"  return  ok
oF = new stzFont("C:/Windows/Fonts/segoeui.ttf")

# ---------------------------------------------------------------- 1
# PAINTER ORDER across the NEW segment kind. I added SegKind.image and
# claimed the ordered segment list interleaves draws. Never tested:
# shape, image, text, image, shape -- must layer in THAT order.
oA = new stzCanvas(560, 200)
oA.SetBackgroundQ("#101820")
oA.FillQ("Danger.Solid").AddRect(20, 20, 200, 160)          # under
oA.AddImage(90, 50, 160, 100, 8, 8, _Checker(8, 8))          # over the rect
oA.Flush()
oA.AddTextQ("TEXT OVER IMAGE", 100, 110).SetFontQ(oF, 22).Color(:White)
oA.AddImage(260, 40, 120, 120, 8, 8, _Solid(8, 8, 40, 200, 120, 160))  # semi
oA.Flush()
oA.FillQ("Info.Solid").AddCircle(430, 100, 60)               # last = on top
oA.ToPNG("probe_1_order.png")
? "1 order        : " + oA.ShapeCount() + " commands"

# ---------------------------------------------------------------- 2
# MANY images in one scene. I claimed "two adjacent images are two
# textures and one draw each" and never drew two.
oB = new stzCanvas(560, 200)
oB.SetBackgroundQ("#FFFFFF")
for i = 0 to 5
	oB.AddImage(20 + i * 90, 40, 80, 120, 8, 8,
		_Solid(8, 8, 30 + i * 40, 200 - i * 30, 120, 255))
next
oB.ToPNG("probe_2_many.png")
? "2 many images  : " + oB.ShapeCount() + " commands"

# ---------------------------------------------------------------- 3
# ALPHA in an image. Never tested: a 50% alpha image over a shape must
# blend, not replace.
oC = new stzCanvas(560, 200)
oC.SetBackgroundQ("#FFFFFF")
oC.FillQ("Warning.Solid").AddRect(0, 0, 560, 200)
oC.AddImage(40, 40, 200, 120, 4, 4, _Solid(4, 4, 0, 0, 255, 128))     # half
oC.AddImage(300, 40, 200, 120, 4, 4, _Solid(4, 4, 0, 0, 255, 255))    # opaque
oC.ToPNG("probe_3_alpha.png")
? "3 alpha        : written"

# ---------------------------------------------------------------- 4
# EXTREME shape boxes. Every node shape was drawn in a friendly 140x100.
# A diagram with a long label gives 300x40; a tall one gives 40x200.
oD = new stzCanvas(900, 300)
oD.SetBackgroundQ("#FFFFFF")
aS = [ :Cylinder, :Hexagon, :Note, :Egg, :TripleOctagon, :Component ]
k = 0
for s in aS
	StzDrawNodeShapeXT(oD, s, 20 + k * 145, 20, 130, 26,
		"Warning.Solid", "#333333", 1)                 # very WIDE
	StzDrawNodeShapeXT(oD, s, 20 + k * 145, 70, 26, 200,
		"Info.Solid", "#333333", 1)                    # very TALL
	k++
next
oD.ToPNG("probe_4_extreme.png")
? "4 extreme      : written"

# ---------------------------------------------------------------- 5
# A TEXTURED TORUS. The torus emits uv, and nothing has ever sampled it.
oT = new stzMaterialGraph()
oT.TakesTexture(:skin)
oT.TakesScalar(:amt)
oT.AddNode(:pic, [ :Op = :Sample,   :In = [ :skin, "@uv" ] ])
oT.AddNode(:lit, [ :Op = :Lit,      :In = [ :amt ] ])
oT.AddNode(:out, [ :Op = :Multiply, :In = [ :pic, :lit ] ])
oT.Emits(:out)
oT.Compile()

hTex = StzEngineGpuTextureNew(16, 16, 1)          # nearest: cells stay crisp
StzEngineGpuTextureWrite(hTex, _Checker(16, 16))

oS = new stzScene(520, 380)
oS.SetBackgroundQ("#0A0E18").SetCamera(0, 2.4, 5.0, 0, 0, 0)
oS.SetLight(-0.45, -0.8, -0.4, "#FFFFFF", "#202838")
oS.AddMesh(new stzMesh([ :Torus, 1.5, 0.55, 96, 48 ]), 0, 0, 0)
oS.SetMaterial(oT.ToMaterial(), [ :skin = hTex, :amt = 0.3 ])
oS.ToPNG("probe_5_torus_uv.png")
? "5 torus uv     : written"

# ---------------------------------------------------------------- 6
# A BIG diagram. Everything so far had 5 nodes.
oG = new stzDiagram("big")
aRoles = [ :Primary, :Success, :Warning, :Danger, :Info ]
for i = 1 to 40
	cRole = "" + aRoles[ (i % 5) + 1 ] + ".Solid"
	oG.AddNodeXTT("n" + i, "Node " + i, [ :type = "box", :color = cRole ])
next
for i = 2 to 40
	oG.AddEdge("n" + floor(i / 2), "n" + i)          # a binary tree
next
oG.ToPNGXT("probe_6_bigdiagram.png",
	[ :Width = 1400, :Height = 800, :Font = oF, :NodeWidth = 96,
	  :NodeHeight = 34, :FontSize = 12 ])
? "6 big diagram  : 40 nodes, " + len(oG.Edges()) + " edges"

# ...and the same tree with ORTHOGONAL routing. Both are the SAME layout --
# the difference is only how an edge travels between two placed nodes.
oG.SetSplines("ortho")
oG.ToPNGXT("probe_6_ortho.png",
	[ :Width = 1400, :Height = 800, :Font = oF, :NodeWidth = 96,
	  :NodeHeight = 34, :FontSize = 12 ])
? "6b ortho       : same layout, right-angled edges"

# ...and NAMING NO SIZE, which is the honest way to draw this. The picture
# takes its size from its content: every gap exactly nodesep, every rank
# exactly ranksep, as dot does. The two above are the same tree squeezed
# into a canvas that was never wide enough for its contract.
aNat = [ :Font = oF, :NodeWidth = 96, :NodeHeight = 34, :FontSize = 12 ]
oNat = oG.ToCanvasXT(aNat)
oNat.ToPNG("probe_6_natural_ortho.png")
? "6c natural     : " + oNat.Width() + "x" + oNat.Height() + " derived, ortho"
oG.SetSplines("spline")
oG.ToCanvasXT(aNat).ToPNG("probe_6_natural.png")
? "6d natural     : the same, curved"

# ---------------------------------------------------------------- 7
# ONE node, and a VERY long label. Degenerate layouts.
oH = new stzDiagram("one")
oH.AddNodeXTT(:solo, "A label far longer than the box it must live inside",
	[ :type = "box", :color = "Success.Solid" ])
oH.ToPNGXT("probe_7_degenerate.png",
	[ :Width = 480, :Height = 220, :Font = oF ])
? "7 degenerate   : written"

# ---------------------------------------------------------------- 8
# The FIT, before and after. Sixteen 96px boxes cannot fit across 1200px,
# and until the fit pass existed they were simply drawn overlapping.
oFan = new stzDiagram("fan")
oFan.AddNodeXTT("root", "Root", [ :type = "box", :color = "#2E7D32" ])
for i = 1 to 16
	oFan.AddNodeXTT("k" + i, "Kid " + i, [ :type = "box", :color = "#2E7D32" ])
	oFan.AddEdge("root", "k" + i)
next
aFit = [ :Width = 1200, :Height = 420, :NodeWidth = 96, :NodeHeight = 34,
         :Font = oF, :FontSize = 12 ]
oFan.ToPNGXT("probe_8_fit_after.png", aFit)
oFan.ToPNGXT("probe_8_fit_before.png", aFit + [ [ :FitBoxes, 0 ] ])
? "8 fit          : before/after written"

# ---------------------------------------------------------------- 9
# LONG EDGES. An edge spanning more than one rank has no presence in the
# ranks it crosses unless dummy nodes give it one -- without them it was a
# straight line drawn through every box in between.
oL = new stzDiagram("pipe")
for i = 1 to 9
	oL.AddNodeXTT("s" + i, "Stage " + i, [ :type = "box", :color = "Info.Solid" ])
next
for i = 1 to 8  oL.AddEdge("s" + i, "s" + (i+1))  next
oL.AddEdge("s1", "s9")
oL.AddEdge("s2", "s7")
oL.ToCanvasXT([ :Font = oF, :NodeWidth = 110, :NodeHeight = 34 ]).
	ToPNG("probe_9_longedge.png")
? "9 long edges   : routed around, not through"

? ""
? "wrote 9 probes"

#---------------------------------------------------------------------------

func _Checker nW, nH
	_c_ = ""
	for _y_ = 0 to nH - 1
		for _x_ = 0 to nW - 1
			if (_x_ + _y_) % 2 = 0
				_c_ += char(250) + char(250) + char(250) + char(255)
			else
				_c_ += char(30) + char(90) + char(200) + char(255)
			ok
		next
	next
	return _c_

func _Solid nW, nH, r, g, b, a
	_c_ = ""
	for _i_ = 1 to nW * nH
		_c_ += char(r) + char(g) + char(b) + char(a)
	next
	return _c_
