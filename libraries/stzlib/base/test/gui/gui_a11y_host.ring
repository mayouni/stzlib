# THE HOST HALF of G4b's proof: a real window, a real tree, held open
# long enough for a real UI Automation client to read it back.
#
#     ring gui_a11y_host.ring [seconds]
#
# It opens a window, attaches the bridge, announces the accessibility
# tree from console.panel, and then sits there pumping frames while it
# watches ONE number: how many times something has asked for the tree.
#
# WHY THIS SHAPE. In-process, the only evidence a bridge works is that we
# handed a tree over -- which is identical on a machine with a screen
# reader and a machine without one. The verdict has to come from outside,
# from a client that shares no code with us. `gui_a11y_read.ps1` is that
# client: Windows' own UI Automation, the same API a screen reader uses.
#
# So the proof has TWO sides that must agree:
#
#     the client sees our node names, roles and bounds
#     our own counter sees the read happen
#
# Either alone is weak. A client could be reading some other window; a
# counter could be counting our own calls. Together they are the same
# event observed from both ends.

load "../../stzBase.ring"

func main
	nSecs = 12
	if len(sysargv) >= 3
		nSecs = 0 + sysargv[3]
	ok

	if NOT StzGuiAvailable()
		? "NO-LAYOUT"
		return
	ok
	if NOT StzWindowingAvailable()
		? "NO-WINDOW"
		return
	ok

	oU = new stzUiDocument("console.panel")
	if NOT oU.IsClean()
		? "UNCLEAN"
		? oU.Report()
		return
	ok
	oU.UseFont(FontPath())
	oP = oU.ToPanel()
	oT = new stzAccessibilityTree(oU, oP)

	# THE TITLE IS THE ADDRESS the client finds us by, so it is distinctive
	# on purpose -- a client that matched "console" might find anything.
	oW = new stzWindow(560, 400, "STZ-A11Y-PROBE-WINDOW")

	oB = new stzScreenReaderBridge(oW)
	if NOT oB.IsLive()
		? "NO-BRIDGE: " + oB.LastError()
		oW.Free()
		return
	ok

	if NOT oB.Announce(oT)
		? "ANNOUNCE-FAILED: " + oB.LastError()
		oW.Free()
		return
	ok

	? "READY hwnd=" + oW.NativeHandle() + " nodes=" + oB.NodeCount()
	write("a11y_host_ready.txt", "" + oW.NativeHandle())

	oC = new stzCanvas(oW.Width(), oW.Height())
	nEnd = oW.FrameCount() + nSecs * 60
	while oW.IsOpen()
		oW.Poll()
		if oW.KeyPressed(:Escape)
			exit
		ok
		# CLEAR FIRST. A frame loop that draws into a canvas without
		# clearing it APPENDS forever -- 7 shapes a frame here, 2,800 by
		# frame 400 -- and every one of them is re-tessellated and
		# re-uploaded on every render. It is also what exposed the
		# 256-bind-group cliff in the render pass, since each frame's
		# text became another draw segment. The cliff is fixed; this
		# loop was still wrong.
		oC.Clear()
		oP.DrawInto(oC)
		oW.Draw(oC)
		if oW.FrameCount() > nEnd
			exit
		ok
	end

	# THE NUMBER THIS WHOLE PROGRAM EXISTS TO PRINT.
	aS = oB.Stats()
	? "FINAL announced=" + aS[1] + " read=" + aS[2] + " nodes=" + aS[3]
	if oB.IsBeingRead()
		? "VERDICT something read the tree"
	else
		? "VERDICT nothing ever asked -- no assistive client attached"
	ok

	remove("a11y_host_ready.txt")
	oB.Free()
	oW.Free()

func FontPath
	_a_ = [ "C:\Windows\Fonts\segoeui.ttf", "C:\Windows\Fonts\arial.ttf" ]
	for _c_ in _a_
		if fexists(_c_)
			return _c_
		ok
	next
	return ""
