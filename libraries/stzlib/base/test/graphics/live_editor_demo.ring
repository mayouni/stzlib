# A LIVE DIAGRAM EDITOR -- GG7, end to end.
#
#   run:  ring live_editor_demo.ring
#
#   drag a cell        press on it, move, release
#   draw a link        hold L, press one cell, release on another
#   re-aim a link      grab it near either end, drop it on another cell
#   remove a link      hold X and click it
#   undo / redo        U / R
#   quit               Escape, or close the window
#
# What makes it a live diagram rather than a picture: the layout only
# ADVISES. A cell you move is pinned and no pass argues with it, the
# picture answers questions (which cell is under the cursor), and every
# edit is a command with an inverse.
#
# The frame does almost nothing on purpose. A drag records the pointer
# and paints a ghost over the picture already on screen; the layout runs
# once, when you let go. Re-laying a 500-node diagram out costs eleven
# seconds, so a gesture must never ask for one.

load "../../stzBase.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")

oDiag = new stzDiagram("live")
_aA123_ = [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
           [ "api1", "API A" ], [ "api2", "API B" ],
           [ "db1", "DB A" ], [ "db2", "DB B" ], [ "log", "Logger" ] ]
_nA123_ = len(_aA123_)
for _iA123_ = 1 to _nA123_
	a = _aA123_[_iA123_]
	oDiag.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
next
oDiag.AddEdge("lb", "web1")    oDiag.AddEdge("lb", "web2")
oDiag.AddEdge("web1", "api1")  oDiag.AddEdge("web2", "api2")
oDiag.AddEdge("api1", "db1")   oDiag.AddEdge("api2", "db2")
oDiag.AddEdge("web1", "log")   oDiag.AddEdge("api2", "log")
oDiag.SetSplines("ortho")

W = 1100  H = 760
aOpt = [ :Font = oFont, :NodeWidth = 96, :NodeHeight = 36, :FontSize = 13,
         :Width = W, :Height = H ]

oWin = new stzWindow(W, H, "Softanza -- live diagram (drag cells; L+drag links; grab a link by its end; X+click removes)")
oDiag.ToCanvasXT(aOpt)

? "live editor open. drag cells; L+drag to link; grab a link near its end to re-aim it; X+click removes it."

bWasDown = 0
bLink = 0
nFrames = 0

while oWin.IsOpen()
	oWin.Poll()
	nFrames++

	if oWin.KeyPressed(:Escape)  exit  ok

	# LINK MODE while L is held: the same machine, a different state
	bNow = oWin.KeyDown(:L)
	if bNow and NOT bLink   oDiag.BeginLinking()   ok
	if NOT bNow and bLink   oDiag.EndLinking()     ok
	bLink = bNow

	if oWin.KeyPressed(:U)
		if oDiag.Undo()  oDiag.ToCanvasXT(aOpt)  ok
	ok
	if oWin.KeyPressed(:R)
		if oDiag.Redo()  oDiag.ToCanvasXT(aOpt)  ok
	ok

	# the pointer, fed to the state machine as events
	nX = oWin.MouseX()
	nY = oWin.MouseY()
	bDown = oWin.MouseDown(1)
	bChanged = 0

	if bDown and NOT bWasDown
		# X held: the click is a REMOVAL, not a gesture
		if oWin.KeyDown(:X)
			if oDiag.RemoveLinkAt(nX, nY)  bChanged = 1  ok
		else
			oDiag.OnPress(nX, nY)
		ok
	but bDown and bWasDown
		oDiag.OnMove(nX, nY)
	but NOT bDown and bWasDown
		nLog = len(oDiag.EditLog())
		oDiag.OnRelease(nX, nY)
		if len(oDiag.EditLog()) != nLog  bChanged = 1  ok
	ok
	bWasDown = bDown

	# THE LAYOUT RUNS ONLY WHEN THE MODEL MOVED
	if bChanged  oDiag.ToCanvasXT(aOpt)  ok

	# ...and the gesture is painted OVER the picture we already have.
	# A cell in hand ghosts as a box; a link's knob in hand ghosts as a
	# line from its anchored end to the cursor -- the author sees what
	# the link WOULD mean before letting go.
	aGhost = oDiag.DragPreview()
	if len(aGhost) = 3
		oOv = new stzCanvas(W, H)
		oOv.SetBackgroundQ("#00000000")
		if oDiag.UiState() = :Rewiring
			aAnch = oDiag.RewireAnchor()
			if len(aAnch) = 2
				oOv.FillQ("#00000000").StrokeQ("#FF6A00", 2).
					AddLine(aAnch[1], aAnch[2], aGhost[2], aGhost[3])
			ok
		else
			oOv.FillQ("#00000000").StrokeQ("#FF6A00", 2).
				AddRect(aGhost[2] - 48, aGhost[3] - 18, 96, 36)
		ok
		oOv.Flush()
		oWin.DrawXT(oDiag.LastCanvas(), oOv)
	else
		oWin.Draw(oDiag.LastCanvas())
	ok
end

? "closed after " + nFrames + " frames. " + len(oDiag.EditLog()) +
  " edit(s) in the log."
