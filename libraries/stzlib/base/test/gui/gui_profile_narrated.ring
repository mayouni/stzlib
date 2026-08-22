load "../../stzBase.ring"

/*
	§3 -- THE PROFILE IS A CONTRACT, AND A BROWSER IS THE SECOND
	IMPLEMENTATION.

	§3 is the section that turns a vendoring decision into an
	architecture, and its warning is precise: if Softanza emits RCSS and
	RmlUi renders it, then RMLUI'S COVERAGE SILENTLY BECOMES THE
	DEFINITION of what Softanza's UI can express, and the native and web
	tiers drift apart with nobody noticing.

	It asked for two things and got neither until now:

	  THE PROFILE WRITTEN DOWN AS DATA, "not implied by whatever the
	  emitter happens to produce". Every divergence lived as a constant
	  inside the emitter, which is exactly the thing it warned against.

	  AND "G0 BEGINS THE FIXTURE, in embryo: one document, two
	  renderings, compared. It does not wait for G6." It waited for G6
	  and then some.

	THE FIXTURE FOUND A DEFECT ON ITS FIRST RUN, which is the argument
	for having built it. Ten of twenty-three boxes disagreed, all with
	the same shape: the native side reported RmlUi's CONTENT box while
	the emitter sets `box-sizing: border-box` and this plane's law says a
	declared size is the TOTAL. The showcase's own rationale says it in
	as many words -- "210 means 210, whatever the window does" -- and
	`BoxOf` was answering 170.

	It survived four phases because EVERY CONSUMER WAS SELF-CONSISTENT: a
	guard comparing BoxOf against BoxOf agrees with itself, and
	hit-testing uses RmlUi's own routing. It took a second implementation
	to have anything to disagree with.

	Needs stz_gui.dll. The browser half is a reproduce procedure at the
	foot of this file, because Ring cannot drive a browser -- the same
	shape as the accessibility guard, and for the same reason.
*/

? ""
? "=========================================================="
? " §3: THE PROFILE AS A CONTRACT, AND ITS SECOND ENGINE"
? "=========================================================="

nOK = 0
nBad = 0

if NOT StzGuiAvailable()
	? "No layout engine on this machine -- nothing to project."
	return
ok

#---------------------------------------------------------------------
? ""
? "-- 1. The profile is DATA, not an emitter's habit ------------"
#---------------------------------------------------------------------

Chk("the profile names its properties", len(StzUiProfileProperties()) > 10)
Chk("...and the list is closed -- an unnamed property is unavailable",
   StzUiProfileHasProperty("display") and
   NOT StzUiProfileHasProperty("backdrop-filter"))

# THE DIVERGENCES ARE THE WHOLE REASON THIS IS DATA. Each cost a
# measurement to find, and each lived as a constant inside ToRml until
# the web tier needed the same knowledge.
aD = StzUiProfileDivergences()
? "  divergences recorded: " + len(aD)
Chk("the divergences are recorded", len(aD) >= 3)
Chk("direction is one, and the two tiers spell it differently",
   StzUiProfileSpelling("direction", :native) = "--rmlui-direction" and
   StzUiProfileSpelling("direction", :web) = "direction")
Chk("...and it says WHY, so nobody re-derives it",
   len(StzUiProfileWhyDivergent("direction")) > 40)
Chk("a property that is NOT divergent spells the same in both",
   StzUiProfileSpelling("padding", :native) = "padding" and
   StzUiProfileSpelling("padding", :web) = "padding")
Chk("...and knows it is not divergent",
   NOT StzUiProfileIsDivergent("padding"))
# An empty web spelling is a REAL answer: the tier does not carry it.
Chk("a native-only property answers empty for the web",
   StzUiProfileSpelling("nav", :web) = "")

#---------------------------------------------------------------------
? ""
? "-- 2. Two projections of one document ------------------------"
#---------------------------------------------------------------------

oU = new stzUiDocument("showcase.panel")
Chk("the document is clean", oU.IsClean())
oU.UseFont(FontPath())

cRml = oU.ToRml()
cHtml = oU.ToHtml()
Chk("the native projection is produced", len(cRml) > 500)
Chk("the web projection is produced", len(cHtml) > 500)

# THE DIVERGENCE, VISIBLE IN BOTH OUTPUTS. This is the assertion that
# would fail the day someone hard-codes a spelling again.
Chk("the native projection carries the RCSS spelling",
   len(StzFindCS("--rmlui-direction", cRml, TRUE)) > 0)
Chk("...and the web projection does NOT",
   len(StzFindCS("--rmlui-direction", cHtml, TRUE)) = 0)
Chk("...but does carry the CSS one",
   len(StzFindCS("direction:", cHtml, TRUE)) > 0)

# `nav` has no web spelling, so the whole declaration is dropped rather
# than emitted as a property no browser knows.
Chk("a native-only property is dropped from the web projection, not renamed",
   len(StzFindCS("nav:", cHtml, TRUE)) = 0)

# Both are real documents of their kind.
Chk("the native projection is RML", len(StzFindCS("<rml>", cRml, TRUE)) > 0)
Chk("the web projection is HTML", len(StzFindCS("<!doctype html>", cHtml, TRUE)) > 0)
Chk("...and every declared element appears in BOTH",
   _AllIdsIn(oU, cRml) and _AllIdsIn(oU, cHtml))

#---------------------------------------------------------------------
? ""
? "-- 3. Which boxes the profile actually CLAIMS ----------------"
#---------------------------------------------------------------------
/*
	The fixture's first run supplied this and §3 had not stated it: a box
	whose geometry the DECLARATION determines is a strict observable; one
	with an auto dimension is measured by whichever shaper the tier uses,
	and two shapers legitimately differ.
*/

# PER AXIS, and the first version of this rule was wrong in the dangerous
# direction: it demanded both axes and so classified only 6 of 23 boxes
# as strict -- letting through every one of the ten the border-box defect
# had broken. A check calibrated to miss its own motivating defect is
# worse than none, because it reports green.
Chk("a declared WIDTH is a claim about the width",
   oU.IsStrictWidth("side"))
Chk("...and an undeclared HEIGHT on the same box is not a claim about height",
   NOT oU.IsStrictHeight("side"))
Chk("a TEXT with no declared size claims neither",
   NOT oU.IsStrictWidth("brand") and NOT oU.IsStrictHeight("brand"))
Chk("the rule is the profile's, not the fixture's",
   StzUiProfileIsStrictWidth(TRUE) and NOT StzUiProfileIsStrictWidth(FALSE))
# POSITION needs the predecessors too: one auto-width label earlier in a
# row moves everything after it.
Chk("position is not claimed when an earlier sibling is auto-sized",
   NOT oU.IsStrictlyPlaced("tab_gui"))
? "  tolerance: " + StzUiProfileTolerance() + "px, and the reason is " +
  "rounding rather than generosity"
Chk("the tolerance is stated and small", StzUiProfileTolerance() <= 1)

#---------------------------------------------------------------------
? ""
? "-- 4. THE DEFECT THE FIXTURE FOUND ---------------------------"
#---------------------------------------------------------------------
/*
	`WIDTH 210, PADDING 20` with border-box means the laid-out box is
	210 wide, and the declaration's own rationale says so. Before the
	fixture, BoxOf answered 170 -- RmlUi's content box.

	The consequence outside the fixture is the accessibility bounds: a
	magnifier or a touch-exploration gesture was being sent to a
	rectangle inset by the padding on every side.
*/

oP = oU.ToPanel()
aSide = oP.BoxOf("side")
? "  side: declared WIDTH 210 with PADDING 20, laid out " +
  aSide[3] + " wide"
Chk("a declared width IS the laid-out width -- border box, not content",
   fabs(aSide[3] - 210) <= StzUiProfileTolerance())

# The negative sibling: a padded box whose content area is genuinely
# smaller, so the assertion above cannot be passing by coincidence.
Chk("...and the padding is really there, so 210 is not 210 by accident",
   _DeclaredPadding(oU, "side") = 20)

# The accessibility tree reads the same boxes, so it inherits the fix.
oT = new stzAccessibilityTree(oU, oP)
aB = oT.NodeOf("side")[:bounds]
Chk("the accessibility bounds carry the corrected box",
   len(aB) = 4 and fabs(aB[3] - 210) <= StzUiProfileTolerance())

#---------------------------------------------------------------------
? ""
? "-- 5. The fixture emits, and reports its own verdict ---------"
#---------------------------------------------------------------------

aBoxes = []
for cName in oU.Names()
	a = oP.BoxOf(cName)
	if len(a) = 4
		aBoxes + [ cName, a[1], a[2], a[3], a[4] ]
	ok
next
Chk("every named element has a box to compare", len(aBoxes) > 15)

cFix = oU.ToFixture(aBoxes)
Chk("the fixture is a whole page", len(StzFindCS("<!doctype html>", cFix, TRUE)) > 0)
Chk("...carrying the native boxes with it",
   len(StzFindCS("var NATIVE", cFix, TRUE)) > 0)
Chk("...and the tolerance it will judge by",
   len(StzFindCS("var TOL", cFix, TRUE)) > 0)
# SELF-CHECKING: the page renders a verdict, so a person opening it sees
# the answer without a harness. Every visual defect in this plane was
# found by a person looking.
Chk("...and it publishes a verdict anyone can read",
   len(StzFindCS("stz-verdict", cFix, TRUE)) > 0)
# PER AXIS in the page too: sw, sh and sp are the three claims, so a box
# is judged only on the axes its declaration actually spoke about.
Chk("...marking which AXIS of each box is claimed",
   len(StzFindCS('"sw":true', cFix, TRUE)) > 0 and
   len(StzFindCS('"sw":false', cFix, TRUE)) > 0 and
   len(StzFindCS('"sh":', cFix, TRUE)) > 0 and
   len(StzFindCS('"sp":', cFix, TRUE)) > 0)

write("fixture_showcase.html", cFix)
Chk("the fixture is written where a browser can open it",
   fexists("fixture_showcase.html"))

/*
	REPRODUCE, and this is what it said on 2026-08-22:

	    python -m http.server 8778 --directory libraries/stzlib/base/test/gui
	    open http://localhost:8778/fixture_showcase.html

	    AGREE on every declared box of 23 (tolerance 1px);
	    4 auto-width boxes differ, which is two shapers, not the profile

	Before the border-box fix the same page said DISAGREE on 14. The four
	that still differ are `brand` and the three tab labels -- every one a
	TEXT with no declared WIDTH, differing by 2.95 to 7.25 pixels because
	our HarfBuzz and the browser's shaper measure the same Segoe UI
	string slightly differently, and the x of each drifts by the sum of
	its predecessors.

	AND IT CAN FAIL, which is the half most fixtures skip. Widening one
	box's CLAIMED width by 20 in the native list turned the same page
	red:

	    DISAGREE on 1 declared boxes of 23 (tolerance 1px);
	    4 auto-width boxes differ, which is two shapers, not the profile

	It attributed the 20 to the claimed axis and left the neighbouring
	label's 0.40 text delta unclaimed -- so the page is not merely
	sensitive, it is sensitive to the right thing.

	It must be served over HTTP, not opened as a file: a file:// page is
	a static snapshot and its script never runs -- the first attempt
	reported "no fixture object" rather than a layout result.
*/

Chk("this guard does not claim to have run a browser", TRUE)

#---------------------------------------------------------------------
? ""
? "=========================================================="
? " " + nOK + " assertions green, " + nBad + " failed"
? "=========================================================="
? ""

#-- helpers, at the FOOT: code after the first func belongs to it

func Chk(cWhat, bCond)
	if bCond
		nOK++
	else
		nBad++
		? "  FAIL: " + cWhat
	ok

func _AllIdsIn oU, cText
	_a_ = oU.Names()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		_d_ = oU.DeclOf(_a_[_i_])
		if strcmp(_d_[:kind], "STYLE") = 0 or strcmp(_d_[:kind], "PANEL") = 0
			loop
		ok
		if len(StzFindCS('id="' + _a_[_i_] + '"', cText, TRUE)) = 0
			return 0
		ok
	next
	return 1

func _DeclaredPadding oU, cName
	_d_ = oU.DeclOf(cName)
	if len(_d_) = 0
		return 0
	ok
	_v_ = oU._RawField(_d_[:fields], "PADDING")
	if len(_v_) = 0 or NOT isNumber(_v_[2])
		return 0
	ok
	return _v_[2]

func FontPath
	_a_ = [ "C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf" ]
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if fexists(_a_[_i_])
			return _a_[_i_]
		ok
	next
	return ""
