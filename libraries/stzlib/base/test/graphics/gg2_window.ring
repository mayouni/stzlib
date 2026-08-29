load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE WHOLE STACK, LIVE

	graph  ->  layout (GG1)  ->  canvas (GR4)  ->  window (GR5)

	Nothing here is a demo shortcut: the graph is an ordinary stzGraph, the
	sizes and colours are computed from it, and the window is the same one
	the gallery uses. Press a key and the picture is REBUILT from the graph,
	not from a cached image.

	    L        layout: hierarchical <-> force
	    I D G    what SIZE and COLOUR mean: impact, depth, degree
	    S        save what you are looking at as a PNG
	    ESC      quit
---------------------------------------------------------------------------*/

if NOT StzWindowingAvailable()
	? "No windowing here -- run gg2_graphcanvas.ring for the file version."
	return
ok

decimals(2)

oG = new stzGraph("supply")
oG.AddNodes([ "mine","smelt","chip","board","sensor","cell","pack",
              "motor","ecu","line1","line2","car","paint","glass","seats" ])
aE = [ ["mine","smelt"], ["smelt","chip"], ["smelt","cell"],
       ["chip","board"], ["board","sensor"], ["sensor","ecu"],
       ["cell","pack"], ["pack","motor"], ["motor","ecu"],
       ["board","ecu"], ["ecu","line1"], ["ecu","line2"],
       ["line1","car"], ["line2","car"],
       ["paint","line1"], ["glass","line2"], ["seats","line2"] ]
_aE16_ = aE
_nE16_ = len(_aE16_)
for _iE16_ = 1 to _nE16_
	e = _aE16_[_iE16_]
	oG.AddEdge(e[1], e[2])
next

oFont = NULL
if fexists("C:/Windows/Fonts/segoeui.ttf")
	oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
ok

oWin = new stzWindow(1100, 660, "Softanza -- a graph drawing itself")
if NOT oWin.CanDraw()
	? "window opened but no GPU device."
	oWin.Free()
	return
ok

aLayouts = [ :Hierarchical, :Force ]
aMetrics = [ :Impact, :Depth, :Degree ]
nL = 1
nM = 1
bDirty = TRUE
oCanvas = NULL

while oWin.IsOpen()
	oWin.Poll()

	if oWin.KeyPressed(:Escape)
		oWin.Close()
		exit
	ok
	if oWin.KeyPressed(:L)
		nL = 3 - nL
		bDirty = TRUE
	ok
	if oWin.KeyPressed(:I)   nM = 1  bDirty = TRUE  ok
	if oWin.KeyPressed(:D)   nM = 2  bDirty = TRUE  ok
	if oWin.KeyPressed(:G)   nM = 3  bDirty = TRUE  ok
	if oWin.WasResized()     bDirty = TRUE  ok
	if oWin.KeyPressed(:S)
		if isObject(oCanvas)
			oCanvas.ToPNG("gg2_window_shot.png")
			? "saved gg2_window_shot.png"
		ok
	ok

	# A WINDOW WITH NO AREA IS A REAL STATE, not an impossible one: it
	# reports 0x0 while it is still being mapped and for as long as it is
	# minimised. Feeding that to a layout asks for a 0x0 canvas, which is
	# correctly refused -- and the refusal killed this demo on the first
	# frame the startup race went the other way.
	if oWin.Width() < 1 or oWin.Height() < 1
		loop
	ok

	# REBUILT FROM THE GRAPH, not from a cached bitmap -- but only when
	# something actually changed, because a layout is real work and a
	# frame loop must not redo it 60 times a second for nothing.
	if bDirty
		oGC = oG.GraphCanvas([ :Layout = aLayouts[nL],
		                       :SizeBy = aMetrics[nM],
		                       :ColorBy = aMetrics[nM],
		                       :Font = oFont, :Margin = 80 ])
		oGC.SetSize(oWin.Width(), oWin.Height())
		oCanvas = oGC.ToCanvas()
		oWin.SetTitle("Softanza graph   layout " + aLayouts[nL] +
			"   size/colour by " + aMetrics[nM] +
			"   [L layout, I D G metric, S save, ESC quit]")
		bDirty = FALSE
	ok

	if isObject(oCanvas)
		oWin.Draw(oCanvas)
	ok
end

? ""
? "frames : " + oWin.FrameCount()
? "surface: " + @@(oWin.Stats())
oWin.Free()
? "closed cleanly."
