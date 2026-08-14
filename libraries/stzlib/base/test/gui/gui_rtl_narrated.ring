# RTL IS ONE PARAMETER, THREADED -- §2.3 of SOFTANZA_GUI_PLAN.md.
#
# The plan committed to right-to-left "from commit one", on the reasoning
# that text direction is a parameter threaded through the layout protocol
# rather than a feature added later -- Flutter needed a dedicated PR
# across its core layout files to retrofit it, and egui still has no bidi
# after five years.
#
# WHAT RMLUI GIVES, MEASURED: almost nothing. `--rmlui-direction` appears
# in exactly ONE line of its layout -- a dirty flag that feeds the shaper
# -- so it aligns nothing, reverses nothing, and moves no box. And RCSS
# `text-align` takes only left/right/center/justify, with no
# direction-relative start/end. So every visible consequence of RTL is
# the EMITTER's to produce, and this guard is what proves it does.
#
# THE PROMISE BEING KEPT: one declaration on the panel flips the screen.
# Text right-aligns, rows read right to left, and the shaper is told the
# base direction -- without an author writing a second stylesheet or
# repeating a property on every box.
#
# Found by looking at a picture, not by an assertion: before this,
# `TEXT_DIRECTION rtl` set the shaper hint and left the paragraph
# left-aligned, so an Arabic screen started at the wrong edge. The guard
# exists because the screenshot did.
#
# Needs stz_gui.dll; needs no GPU.
#
# A naming note paid for in nine syntax errors: `oR` is Ring's `or`
# KEYWORD (comparisons are case-insensitive) and `cR` is the CR global.
# Two-letter locals are a minefield here -- CLAUDE.md says so, and this
# file rediscovered it.

load "../../stzBase.ring"

nPass = 0
nFail = 0

if NOT StzGuiAvailable()
	? "No layout engine on this machine -- nothing to flip."
	? " 0 ok, 0 failed"
	return
ok

cFixture = "../gpu/fixtures/amiri_arabic_subset.ttf"

cSeen = char(0xD8)+char(0xB3)   cWaw = char(0xD9)+char(0x88)
cFa   = char(0xD9)+char(0x81)   cTa  = char(0xD8)+char(0xAA)
cAlef = char(0xD8)+char(0xA7)   cNoon = char(0xD9)+char(0x86)
cZay  = char(0xD8)+char(0xB2)
cArabic = cSeen + cWaw + cFa + cTa + cAlef + cNoon + cZay + cAlef

? "-- Scene 1: direction INHERITS, and answers before anything renders --"
oRtl = new stzUiDocument(RtlDoc("rtl"))
chk("the document is clean", oRtl.IsClean())
# The map was a side effect of ToRml at first, so DirectionOf answered
# "ltr" until something had rendered. Asking before emitting is the
# assertion that keeps it honest.
chk("the panel is rtl", oRtl.IsRtl("p"))
chk("...and so is a box that never declared it", oRtl.IsRtl("bar"))
chk("...and a text three levels down", oRtl.IsRtl("one"))
chk("nothing was emitted to learn that", len(oRtl.Declarations()) = 8)

oLtr = new stzUiDocument(RtlDoc(""))
chk("the same document without the declaration is ltr", NOT oLtr.IsRtl("bar"))
chk("...and an explicit ltr is ltr too", NOT (new stzUiDocument(RtlDoc("ltr"))).IsRtl("one"))

? ""
? "-- Scene 2: a subtree may override, and the override inherits --"
oX = new stzUiDocument(
	'DEFINE PANEL p ( SIZE [400, 200], FONT "app", TEXT_DIRECTION rtl,' +
	' CHILDREN [outer] ) RATIONALE "x"' + char(10) +
	'DEFINE BOX outer ( CHILDREN [island] ) RATIONALE "inherits rtl"' + char(10) +
	'DEFINE BOX island ( TEXT_DIRECTION ltr, CHILDREN [deep] ) RATIONALE "a Latin block inside an Arabic page"' + char(10) +
	'DEFINE TEXT deep ( CONTENT "code()", SIZE 14 ) RATIONALE "inherits the override"')
chk("the outer box inherited rtl", oX.IsRtl("outer"))
chk("the island overrode it", NOT oX.IsRtl("island"))
chk("...and its child inherited the OVERRIDE, not the panel",
    NOT oX.IsRtl("deep"))

? ""
? "-- Scene 3: what the emitter produces --"
cRtlRml = oRtl.ToRml()
cLtrRml = oLtr.ToRml()
chk("rtl emits the shaper's hint", StzFindFirst("--rmlui-direction: rtl", cRtlRml) > 0)
chk("...and never the CSS spelling RCSS rejects", StzFindFirst("; direction:", cRtlRml) = 0)
chk("rtl right-aligns by default", StzFindFirst("text-align: right", cRtlRml) > 0)
chk("ltr left-aligns by default", StzFindFirst("text-align: left", cLtrRml) > 0)
# start/end are direction-RELATIVE; RCSS knows only left/right, so the
# resolution has to happen here or an author writes two stylesheets
chk("TEXT_ALIGN end became LEFT under rtl",
    StzFindFirst("#tail { box-sizing: border-box; --rmlui-direction: rtl; display: block; text-align: left;", cRtlRml) > 0)
chk("...and RIGHT under ltr",
    StzFindFirst("#tail { box-sizing: border-box; --rmlui-direction: ltr; display: block; text-align: right;", cLtrRml) > 0)
chk("center is center in both", StzFindFirst("text-align: center", cRtlRml) > 0 and
    StzFindFirst("text-align: center", cLtrRml) > 0)
chk("a row REVERSES under rtl", StzFindFirst("flex-direction: row-reverse", cRtlRml) > 0)
chk("...and does not under ltr", StzFindFirst("flex-direction: row-reverse", cLtrRml) = 0)

? ""
? "-- Scene 4: and it is true of the LAID-OUT boxes, not just the CSS --"
# The CSS above could be right and the layout still wrong. These are the
# positions RmlUi actually computed.
oRtl.UseFont(cFixture)
oLtr.UseFont(cFixture)
oPanRtl = oRtl.ToPanel()
oPanLtr = oLtr.ToPanel()

aR1 = oPanRtl.BoxOf("one")   aR3 = oPanRtl.BoxOf("three")
aL1 = oPanLtr.BoxOf("one")   aL3 = oPanLtr.BoxOf("three")
? "   rtl: first-declared at x=" + aR1[1] + ", third at x=" + aR3[1]
? "   ltr: first-declared at x=" + aL1[1] + ", third at x=" + aL3[1]
chk("under rtl the FIRST-declared child sits rightmost", aR1[1] > aR3[1])
chk("under ltr it sits leftmost", aL1[1] < aL3[1])
# the negative sibling that makes those two mean something: the same
# document, the same children, opposite ends
chk("...so the one declaration reversed the row", (aR1[1] > aR3[1]) != (aL1[1] > aL3[1]))

? ""
? "-- Scene 5: the text lands on the right edge --"
aTR = oPanRtl.Texts()
aTL = oPanLtr.Texts()
? "   rtl drew " + len(aTR) + " commands, ltr drew " + len(aTL)
chk("both panels drew every one of their six strings",
    len(aTR) = 6 and len(aTL) = 6)
# the invariant that catches a vanished string as a NUMBER rather than
# as a missing shape in a screenshot
chk("every generated string became geometry, in both",
    oPanRtl.TextIsWhole() and oPanLtr.TextIsWhole())
nR = _XOf(aTR, "aligned by default")
nL = _XOf(aTL, "aligned by default")
? "   default-aligned line: rtl x=" + nR + "   ltr x=" + nL
chk("both default-aligned lines are present", nR >= 0 and nL >= 0)
chk("an rtl line starts away from the left edge", nR > 100)
chk("...while the ltr one starts at it", nL >= 0 and nL < 4)
nTailR = _XOf(aTR, "the trailing edge")
chk("the trailing-edge line is PRESENT under rtl", nTailR >= 0)
chk("...and TEXT_ALIGN end put it at the LEFT", nTailR >= 0 and nTailR < 4)

? ""
? "-- Scene 5b: alignment set on a CONTAINER reaches its text --"
# Emitting text-align on every element looked harmless and silently broke
# this: the text inside a card carried its own resolved `left` and
# overrode the card's TEXT_ALIGN. Three tiles side by side in the gallery
# made it obvious at a glance; no assertion had noticed. Alignment is now
# emitted only where it is DECIDED -- on an element that declares it, or
# on one that flips direction relative to its parent -- and inherits
# everywhere else.
oCont = new stzUiDocument(
	'DEFINE PANEL p ( SIZE [600, 200], DIRECTION column, FONT "app",' +
	' CHILDREN [a, b, c] ) RATIONALE "x"' + char(10) +
	'DEFINE BOX a ( HEIGHT 40, CHILDREN [ta] ) RATIONALE "no alignment"' + char(10) +
	'DEFINE BOX b ( HEIGHT 40, TEXT_ALIGN center, CHILDREN [tb] ) RATIONALE "centred by the CARD"' + char(10) +
	'DEFINE BOX c ( HEIGHT 40, TEXT_ALIGN end, CHILDREN [tc] ) RATIONALE "trailing by the CARD"' + char(10) +
	'DEFINE TEXT ta ( CONTENT "word", SIZE 16 ) RATIONALE "x"' + char(10) +
	'DEFINE TEXT tb ( CONTENT "word", SIZE 16 ) RATIONALE "x"' + char(10) +
	'DEFINE TEXT tc ( CONTENT "word", SIZE 16 ) RATIONALE "x"')
oCont.UseFont(cFixture)
oPC = oCont.ToPanel()
aTC = oPC.Texts()
chk("all three words were drawn", len(aTC) = 3 and oPC.TextIsWhole())
nA = _XOf(aTC, "word")
nAx = aTC[1][3]   nBx = aTC[2][3]   nCx = aTC[3][3]
? "   x: default " + nAx + ", centred " + nBx + ", trailing " + nCx
chk("the default one sits at the leading edge", nAx < 4)
chk("the card's TEXT_ALIGN center reached its text", nBx > nAx + 100)
chk("...and TEXT_ALIGN end pushed it further still", nCx > nBx + 100)
oPC.Free()

? ""
? "-- Scene 6: bidi INSIDE a line still works --"
# Direction decides where a paragraph starts; UAX#9 decides the order of
# runs within it. This is the shaper's half, and it is asserted here so
# the two are not confused: a mixed line keeps its Latin readable and its
# Arabic reversed, whichever way the paragraph is aligned.
oM = new stzUiDocument(
	'DEFINE PANEL p ( SIZE [520, 120], FONT "app", TEXT_DIRECTION rtl,' +
	' CHILDREN [m] ) RATIONALE "x"' + char(10) +
	'DEFINE TEXT m ( CONTENT "Softanza ' + cArabic + ' mixed", SIZE 26 ) RATIONALE "one line, two scripts"')
oM.UseFont(cFixture)
oPM = oM.ToPanel()
aTM = oPM.Texts()
chk("the mixed line is ONE text command", len(aTM) = 1)
chk("...carrying both scripts", StzFindFirst("Softanza", aTM[1][6]) > 0 and
    StzFindFirst(cSeen, aTM[1][6]) > 0)
# the shaper's own witness, on the same bytes the panel drew
oF = new stzFont(cFixture)
chk("the shaper sees three visual runs in it", oF.RunCountOf(aTM[1][6], 26) = 3)
chk("...and the Arabic joined (narrower than its letters apart)",
    oF.WidthOf(cArabic, 26) <
    oF.WidthOf(cSeen + " " + cWaw + " " + cFa + " " + cTa, 26))
oF.Free()

oPM.Free()
oPanRtl.Free()
oPanLtr.Free()

? ""
? "=============================================================="
? " " + nPass + " ok, " + nFail + " failed"
? "=============================================================="

#-- helpers ---------------------------------------------------------------
#
# Ring parses everything after the first `func` as a function body, so
# every helper lives here, below the last top-level line.

# ONE document, built twice: the only difference is the panel's
# TEXT_DIRECTION. Everything asserted below is the difference that makes.
func RtlDoc cDir
	_cD_ = ""
	if cDir != ""
		_cD_ = " TEXT_DIRECTION " + cDir + ","
	ok
	return 'DEFINE PANEL p ( SIZE [600, 240], DIRECTION column, FONT "app",' +
		_cD_ + ' CHILDREN [bar, line, tail, mid] ) RATIONALE "x"' + char(10) +
		'DEFINE BOX bar ( DIRECTION row, HEIGHT 40, CHILDREN [one, two, three] )' +
		' RATIONALE "a row, to see which end it starts at"' + char(10) +
		'DEFINE TEXT one   ( CONTENT "ONE",   SIZE 18 ) RATIONALE "declared first"' + char(10) +
		'DEFINE TEXT two   ( CONTENT "TWO",   SIZE 18 ) RATIONALE "second"' + char(10) +
		'DEFINE TEXT three ( CONTENT "THREE", SIZE 18 ) RATIONALE "third"' + char(10) +
		'DEFINE TEXT line ( CONTENT "aligned by default", SIZE 20 ) RATIONALE "start"' + char(10) +
		'DEFINE TEXT tail ( CONTENT "the trailing edge", SIZE 20, TEXT_ALIGN end ) RATIONALE "end"' + char(10) +
		'DEFINE TEXT mid  ( CONTENT "the middle", SIZE 20, TEXT_ALIGN center ) RATIONALE "center"'


# Answers the x of the command carrying cNeedle, or -1 when there is no
# such command. EVERY caller must check for -1 before comparing: an
# earlier version of this file asserted `x < 4` and passed on -1, so a
# string that had VANISHED read as one aligned to the left edge. That is
# the assertion-by-coincidence the house rule warns about, and it hid a
# real bug for the length of one run.
func _XOf aTexts, cNeedle
	_n_ = len(aTexts)
	for _i_ = 1 to _n_
		if StzFindFirst(cNeedle, aTexts[_i_][6]) > 0
			return aTexts[_i_][3]
		ok
	next
	return -1

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
