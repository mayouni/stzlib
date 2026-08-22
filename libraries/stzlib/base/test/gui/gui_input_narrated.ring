# G3 -- INPUT, EVENTS AND FOCUS -- base/gui/SOFTANZA_GUI_PLAN.md.
#
# The gap the plan named: graphics input is POLLED (KeyPressed,
# MouseClicked), which is the game-loop shape and cannot express which
# element was hit, who has focus, or what bubbles. A widget system needs
# events with a target and a route.
#
# WHAT RMLUI ALREADY HAD, and the plan under-credited: full input
# processing, focus, tab order in document order, AND a spatial heuristic
# for directional moves. So G3 is not "build an event model" -- it is
# expose one, decide its SHAPE at the seam, and add what RmlUi does not
# have: a queryable ring, counted refusals, and the input source.
#
# TWO DECISIONS THIS GUARD PINS:
#
#   EVENTS ARE DRAINED, NEVER DISPATCHED. Ring cannot be re-entered
#   safely from inside a C++ event dispatch, so the engine writes events
#   down and the caller takes the list. The house settled this shape
#   twice already -- the display list and the text commands.
#
#   EVERY INPUT VERB TAKES PANEL PIXELS. The coordinate-space frame is
#   DISSOLVED rather than surfaced (§7): a panel admits exactly one
#   space, so nothing can be confused with it, and the conversions are
#   named functions at the boundary -- FromWindow for a window's pixels,
#   FromTexture for a panel hanging in a 3D scene.
#
# RULE 80 (Keyboard Sovereignty) is `machine` tier, which makes the tab
# ring a legal requirement rather than polish. It is asserted as a
# PROPERTY OF THE RUN -- walk the ring, see what it reaches -- not as a
# property of the markup.
#
# Needs stz_gui.dll; needs no GPU.

load "../../stzBase.ring"

nPass = 0
nFail = 0

if NOT StzGuiAvailable()
	? "No layout engine on this machine -- nothing to drive."
	? " 0 ok, 0 failed"
	return
ok

oU = new stzUiDocument("form.panel")
chk("the form document is clean", oU.IsClean())
oU.UseFont("../gpu/fixtures/amiri_arabic_subset.ttf")
oP = oU.ToPanel()

? "-- Scene 1: the tab ring is exactly what was declared FOCUSABLE --"
aRing = oP.TabRing()
? "   ring: " + @@(aRing)
chk("four stops, one per FOCUSABLE box", len(aRing) = 4)
chk("...in document order", aRing[1] = "row_one" and aRing[2] = "row_two" and
    aRing[3] = "confirm" and aRing[4] = "cancel")
# the negative sibling: boxes that did NOT declare FOCUSABLE must be
# absent, or the ring is just a list of everything and proves nothing
chk("the title is not a tab stop", _NotIn(aRing, "title"))
chk("nor is the actions row that merely CONTAINS the buttons",
    _NotIn(aRing, "actions"))
chk("nor a label inside a field", _NotIn(aRing, "label_from"))

? ""
? "-- Scene 2: RULE 80 -- every action is reachable by keyboard alone --"
# Asserted as a property of THE RUN: the ring is walked, and what it
# reaches is what a person with no pointer can reach. A screen whose ring
# omits an action is a screen a keyboard cannot operate, and Rule 80 is
# `machine` tier, so that is a defect rather than a preference.
chk("the act is reachable", NOT _NotIn(aRing, "confirm"))
chk("...and so is the way back, which the rule also requires",
    NOT _NotIn(aRing, "cancel"))

? ""
? "-- Scene 3: focus moves, and REFUSES honestly at the end --"
oP.ClearFocus()
chk("nothing is focused to begin with", oP.Focused() = "")
chk("Tab lands on the first stop", oP.FocusNext() and oP.Focused() = "row_one")
chk("...and again on the second", oP.FocusNext() and oP.Focused() = "row_two")
chk("Shift+Tab goes back", oP.FocusPrevious() and oP.Focused() = "row_one")
oP.FocusOn("cancel")
chk("focus can be set by name", oP.Focused() = "cancel")
# A ring WRAPS: Tab from the last stop returns to the first. That is
# correct and it is what TabRing() detects to know it has been all the
# way round -- a ring that refused at the end would strand a keyboard
# user at the bottom of every screen.
chk("Tab from the last stop wraps to the first", oP.FocusNext())
chk("...to the FIRST stop, not somewhere arbitrary", oP.Focused() = "row_one")
chk("focusing an element that does not exist is refused",
    StzEngineGuiFocus(oP.Id_(), "no_such_box") = 4)

? ""
? "-- Scene 4: directional moves, for an arrow key or a stick --"
# The WAI-ARIA APG contract the plan adopted: ONE tab stop per composite
# widget, arrows WITHIN it. RmlUi picks the target by a spatial
# heuristic, which is what makes `left` mean the box to the left rather
# than the previous sibling.
oP.FocusOn("cancel")
chk("left from the right-hand button reaches the left-hand one",
    oP.FocusLeft() and oP.Focused() = "confirm")
chk("...and right comes back", oP.FocusRight() and oP.Focused() = "cancel")
chk("left again from the leftmost refuses",
    _RefusesLeftTwice(oP))

? ""
? "-- Scene 5: a pointer event is ROUTED, and it bubbles --"
oP.ClearEvents()
aBtn = oP.BoxOf("confirm")
nCx = aBtn[1] + aBtn[3] / 2
nCy = aBtn[2] + aBtn[4] / 2
chk("the point hits the innermost element under it",
    oP.ElementAt(nCx, nCy) = "confirm_text")
oP.ClickAt(nCx, nCy)
aE = oP.Events()
? "   " + len(aE) + " events from one click"
chk("the click produced events", len(aE) > 0)
chk("a click arrived", _HasKind(aE, 1))
chk("...preceded by a press and a release", _HasKind(aE, 2) and _HasKind(aE, 3))
chk("...targeted at the innermost element, not the panel",
    _TargetOfKind(aE, 1) = "confirm_text")
# bubbling: the pointer entering the button also entered its ancestors,
# which is the route a polled input model cannot express at all
chk("the enter chain names the ancestors too",
    _HasTarget(aE, "actions") and _HasTarget(aE, "confirm"))

? ""
? "-- Scene 6: the INPUT SOURCE is on the event, and it differs --"
# The frame §7 chose to surface. It earns its place twice: Rule 80 makes
# "reachable by a human keyboard" materially different from "something
# dispatched a click", and G4 needs an assistive activation
# distinguishable from a pointer one.
chk("a pointer event says pointer", _SourceOfKind(aE, 1) = 0)

oP.ClearEvents()
oP.FocusOn("row_one")
oP.KeyPressed(_KeyTab(), 0)
aK = oP.Events()
chk("a key event was recorded", len(aK) > 0)
chk("...and it says KEYBOARD, not pointer", _SourceOfKind(aK, 8) = 1)
# the negative sibling that makes the source falsifiable: if every event
# said the same thing, the field would be decoration
chk("the two sources are genuinely different values",
    _SourceOfKind(aE, 1) != _SourceOfKind(aK, 8))

? ""
? "-- Scene 7: the queue is BOUNDED and says what it dropped --"
oP.ClearEvents()
chk("clearing empties it", oP.EventCount() = 0)
chk("...and resets the drop count", oP.EventsDropped() = 0)
# 4096 is the ceiling; a caller that never drains must not grow it
# without limit, and what is lost is COUNTED rather than discarded
for i = 1 to 1600
	oP.ClickAt(nCx, nCy)
next
? "   after 1600 undrained clicks: " + oP.EventCount() + " queued, " +
	oP.EventsDropped() + " dropped"
chk("the queue stopped at its ceiling", oP.EventCount() <= 4096)
chk("...and the overflow was counted, not silently discarded",
    oP.EventsDropped() > 0)
oP.ClearEvents()

? ""
? "-- Scene 8: the conversions, named at the boundary --"
# §7's answer to the coordinate-space frame: DISSOLVE it inside the
# panel by admitting one space, and name the conversion where it
# actually happens. These two functions are the whole of that.
aFT = oP.FromTexture(0.5, 0.5)
chk("the centre of a texture is the centre of the panel",
    aFT[1] = oP.Width() / 2 and aFT[2] = oP.Height() / 2)
# v is flipped because a texture's origin is bottom-left and a panel's is
# top-left -- the one place that difference is stated
aTop = oP.FromTexture(0, 1)
chk("v=1 is the TOP of the panel, not the bottom", aTop[2] = 0)
aBottom = oP.FromTexture(0, 0)
chk("...and v=0 is the bottom", aBottom[2] = oP.Height())

? ""
? "-- Scene 9: an in-scene click, through the mapping --"
# This is the whole of §6's in-scene input story: a ray hits a quad, the
# caller has a uv, and the panel takes panel pixels. Nothing about the
# panel knows it is in a scene.
oP.ClearEvents()
aUV = _UvOfCentre(oP, "cancel")
aPt = oP.FromTexture(aUV[1], aUV[2])
chk("the uv maps back onto the button", oP.ElementAt(aPt[1], aPt[2]) = "cancel_text")
oP.ClickAt(aPt[1], aPt[2])
chk("...and a click there reaches it", _HasTarget(oP.Events(), "cancel_text"))

oP.Free()

? ""
? "=============================================================="
? " " + nPass + " ok, " + nFail + " failed"
? "=============================================================="

#-- helpers ---------------------------------------------------------------
#
# Ring parses everything after the first `func` as a function body, so
# every helper lives below the last top-level line.

func _NotIn aList, cName
	_n_ = len(aList)
	for _i_ = 1 to _n_
		if aList[_i_] = cName
			return 0
		ok
	next
	return 1

func _HasKind aEvents, nKind
	_n_ = len(aEvents)
	for _i_ = 1 to _n_
		if aEvents[_i_][1] = nKind
			return 1
		ok
	next
	return 0

func _TargetOfKind aEvents, nKind
	_n_ = len(aEvents)
	for _i_ = 1 to _n_
		if aEvents[_i_][1] = nKind
			return aEvents[_i_][8]
		ok
	next
	return "(none)"

func _SourceOfKind aEvents, nKind
	_n_ = len(aEvents)
	for _i_ = 1 to _n_
		if aEvents[_i_][1] = nKind
			return aEvents[_i_][2]
		ok
	next
	return -1

func _HasTarget aEvents, cName
	_n_ = len(aEvents)
	for _i_ = 1 to _n_
		if aEvents[_i_][8] = cName
			return 1
		ok
	next
	return 0

# The uv a raycast would hand back for the centre of one element, so the
# in-scene scene can be rehearsed without a scene.
func _UvOfCentre oPanel, cName
	_a_ = oPanel.BoxOf(cName)
	_nX_ = _a_[1] + _a_[3] / 2
	_nY_ = _a_[2] + _a_[4] / 2
	return [ _nX_ / oPanel.Width(), 1 - (_nY_ / oPanel.Height()) ]

func _KeyTab
	return 66      # RmlUi's KI_TAB

func _RefusesLeftTwice oPanel
	oPanel.FocusOn("confirm")
	oPanel.FocusLeft()
	return NOT oPanel.FocusLeft() or oPanel.Focused() = "confirm"

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
