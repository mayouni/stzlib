load "../../stzBase.ring"

/*
	G4b -- THE ACCESSIBILITY BRIDGE. The tree, handed to the platform.

	G4a built the tree and asserted its laws: every focusable node has a
	role and a name, reading order equals keyboard order, unknown bounds
	are null rather than a zero rectangle. All of that was checkable
	without leaving the process, and none of it proved a screen reader
	could hear a word.

	THIS GUARD CANNOT PROVE THAT EITHER, AND SAYS SO. In-process, "we
	pushed a tree" looks identical on a machine with a screen reader and a
	machine without one. The verdict has to come from a client that shares
	no code with us, and it did -- Windows' own UI Automation, driven from
	`gui_a11y_read.ps1` against `gui_a11y_host.ring`. What that pair
	measured is recorded in the plan and reproduced at the foot of this
	file. What THIS guard holds is everything else: the lifetime, the
	contract, the refusals, and the honesty of the counters.

	THE ONE COUNTER THAT MATTERS is `TimesRead`. `TimesAnnounced` counts
	what we did. `TimesRead` counts the times an assistive technology
	actually asked. A bridge that reported success on pushes alone would
	be indistinguishable from a bridge that did nothing, so the guard
	asserts the two are DIFFERENT numbers and that the second stays zero
	on a quiet machine -- which is the truth here, not a failure.
*/

? ""
? "=========================================================="
? " G4b: THE TREE, HANDED TO THE PLATFORM"
? "=========================================================="

nOK = 0
nBad = 0

#---------------------------------------------------------------------
? ""
? "-- 1. The runtime, and its absence ---------------------------"
#---------------------------------------------------------------------
/*
	A machine without the vendored accesskit.dll has no bridge, and that
	is a state to report rather than an error to raise -- the same call
	the GPU plane makes about a machine with no device. So the first
	thing asserted is that ASKING is safe.
*/

bReady = StzScreenReaderAvailable()
? "  accessibility runtime present: " + bReady
Chk("asking whether a bridge exists never raises", TRUE)

if NOT bReady
	? ""
	? "  No accessibility runtime on this machine. Everything below"
	? "  needs one, so the guard stops here rather than passing"
	? "  vacuously -- a suite that reports green without exercising"
	? "  anything is the failure mode this house calls a dead guard."
	? ""
	? " " + nOK + " assertions green, " + nBad + " failed (runtime absent)"
	return
ok

Chk("the engine agrees it is loaded", StzEngineA11yIsAvailable() = 1)
Chk("asking twice is idempotent", StzScreenReaderAvailable())

#---------------------------------------------------------------------
? ""
? "-- 2. A tree worth handing over ------------------------------"
#---------------------------------------------------------------------
/*
	The bridge carries what G4a already publishes, unchanged. So the
	first thing to establish is that the JSON is a CONTRACT and not an
	incidental format -- G4b is its first consumer, and the first
	consumer is what turns a format into an interface.
*/

oU = new stzUiDocument("console.panel")
Chk("the document is clean", oU.IsClean())
oU.UseFont(FontPath())
oP = oU.ToPanel()
oT = new stzAccessibilityTree(oU, oP)
Chk("the tree has nodes", oT.NodeCount() > 0)

cJ = oT.ToJSON()
Chk("...and publishes them as JSON", len(cJ) > 100)

# THE GAP G4b FOUND IN THE FORMAT. The JSON carried `depth` but not
# `children`, so the structure was RECOVERABLE (a node's children are
# the following nodes at depth+1) and not STATED. A platform tree needs
# parents and children explicitly, and a structure a reader must infer
# is one a reader can infer wrongly.
Chk("every node states its children, not just its depth",
   len(StzFindCS('"children"', cJ, TRUE)) > 0)
Chk("...and depth survives too, because it is what makes the flat list " +
   "readable in order", len(StzFindCS('"depth"', cJ, TRUE)) > 0)

#---------------------------------------------------------------------
? ""
? "-- 3. Attaching to a real window -----------------------------"
#---------------------------------------------------------------------
/*
	The bridge attaches to the platform's own window handle -- an HWND,
	an NSWindow, an X11 id. There is no other route: a UIA provider must
	answer WM_GETOBJECT on the window's own handle, so no out-of-process
	arrangement can substitute, which is why G4b waited on the window
	being wired at all.
*/

if NOT StzWindowingAvailable()
	? "  (no windowing on this machine -- the attach path is not exercised)"
	? ""
	? " " + nOK + " assertions green, " + nBad + " failed (no windowing)"
	return
ok

oW = new stzWindow(420, 320, "stz a11y guard")
nH = oW.NativeHandle()
Chk("the window has a platform handle", nH > 0)

oB = new stzScreenReaderBridge(oW)
Chk("the bridge attaches", oB.IsLive())
Chk("...and reports no error when it did", oB.LastError() = "")

#---------------------------------------------------------------------
? ""
? "-- 4. Handing the tree over ----------------------------------"
#---------------------------------------------------------------------

Chk("announcing a tree object succeeds", oB.Announce(oT))
Chk("...and the platform holds every node", oB.NodeCount() = oT.NodeCount())
Chk("announcing the JSON directly works too -- the JSON is the contract",
   oB.Announce(cJ))
Chk("...and both were counted", oB.TimesAnnounced() = 2)

# ANNOUNCING AGAIN IS THE NORMAL CASE, not an edge one: an interface
# that changed must be re-announced, and a bridge that leaked a tree per
# push would be found here rather than after an hour of use.
for i = 1 to 20
	oB.Announce(oT)
next
Chk("twenty more pushes are accepted", oB.TimesAnnounced() = 22)
Chk("...and the node count did not drift", oB.NodeCount() = oT.NodeCount())

#---------------------------------------------------------------------
? ""
? "-- 5. The counter that tells the truth -----------------------"
#---------------------------------------------------------------------
/*
	This is the honest part of the whole phase. We have pushed a tree 22
	times. On a machine with no screen reader running, NOTHING HAS READ
	IT, and the bridge must say so rather than counting its own calls as
	success.
*/

? "  announced " + oB.TimesAnnounced() + " times, read " +
  oB.TimesRead() + " times"
Chk("the two counters are not the same number", oB.TimesAnnounced() != oB.TimesRead())
Chk("nothing has read the tree on a quiet machine", oB.TimesRead() = 0)
Chk("...and the bridge admits it", oB.IsBeingRead() = FALSE)

# The negative sibling is the whole external procedure, and it RAN:
# gui_a11y_host.ring + gui_a11y_read.ps1 drove Windows' own UI
# Automation against a live window and this same counter moved to 1.
# See the foot of this file.

#---------------------------------------------------------------------
? ""
? "-- 6. Refusals -----------------------------------------------"
#---------------------------------------------------------------------

Chk("malformed JSON is refused, not published",
   oB.Announce("{ this is not json") = FALSE)
Chk("...and the good tree is still what the platform holds",
   oB.NodeCount() = oT.NodeCount())
Chk("an empty document is refused", oB.Announce('{"nodes": []}') = FALSE)

oB.Free()
Chk("a freed bridge is not live", oB.IsLive() = FALSE)
Chk("...and refuses to announce", oB.Announce(oT) = FALSE)
Chk("...and its stats are empty rather than stale", len(oB.Stats()) = 0)

oW.Free()

#---------------------------------------------------------------------
? ""
? "-- 7. What a real client actually saw ------------------------"
#---------------------------------------------------------------------
/*
	Reproduce, in two terminals:

	    ring gui_a11y_host.ring 20
	    powershell -File gui_a11y_read.ps1

	Measured 2026-08-15 on Windows 11, using the platform's own UI
	Automation and no Softanza code:

	    WINDOW name=[STZ-A11Y-PROBE-WINDOW] type=ControlType.Window
	    COUNT 11
	    NODE type=Text   name=[NAV CONSOLE]
	    NODE type=Group  name=[BEARING 137.4   RANGE 8.20 km]
	    NODE type=Group  name=[drift nominal - hull 98%]
	    NODE type=Button name=[Fire]   focusable=yes
	    NODE type=Button name=[Abort]  focusable=yes
	    NODE type=StatusBar name=[click me through the camera]

	...and on the host side, the same event seen from the other end:

	    FINAL announced=1 read=1 nodes=12
	    VERDICT something read the tree

	THE ROLE MAPPING WAS MEASURED, NOT CHOSEN. Our `label` role -- a run
	of static text -- has three plausible homes in AccessKit and two of
	them lose the text, in different ways:

	    LABEL      present as ControlType.Text with an EMPTY NAME. The
	               whole instrument readout was silent while the heading
	               beside it announced fine. Present and silent is the
	               worst of the three.
	    TEXT_RUN   GONE. The client's descendant count fell from 11 to 7.
	    PARAGRAPH  visible, named, announced. What is shipped.

	None of that is visible from inside the process, and no assertion
	written beforehand would have caught it -- which is now the fourth
	time this plane has learned the same lesson.
*/

Chk("this guard does not claim to have heard a screen reader", TRUE)

#---------------------------------------------------------------------
? ""
? "=========================================================="
? " " + nOK + " assertions green, " + nBad + " failed"
? "=========================================================="
? ""

#-- the helpers, at the FOOT: code after the first func belongs to it

func Chk(cWhat, bCond)
	if bCond
		nOK++
	else
		nBad++
		? "  FAIL: " + cWhat
	ok

func FontPath
	_a_ = [ "C:\Windows\Fonts\segoeui.ttf", "C:\Windows\Fonts\arial.ttf" ]
	_aC132_ = _a_
	_nC132_ = len(_aC132_)
	for _iC132_ = 1 to _nC132_
		_c_ = _aC132_[_iC132_]
		if fexists(_c_)
			return _c_
		ok
	next
	return ""
