# .STZUI -- THE AUTHORED SURFACE, JUDGED -- §4b of SOFTANZA_GUI_PLAN.md.
#
# The plane forbade hand-written RML (§4) and StzZui forbids hand-written
# meanings, which left nothing a person may write. .panel is that thing:
# the file is the CONTRACT, RML and HTML are its projections. It conforms
# to the Grammar Commons (C6 v1.0) and records no divergence.
#
# WHAT IS ASSERTED:
#   - the commons' four birth-checks, each WITH its refusal: closure,
#     reference resolution, duplicate declaration, round trip
#   - case-sensitivity, because Ring's lax `=` is the commons' own named
#     trap: `define` must NOT parse as DEFINE
#   - the emitter's defaults absorb every divergence G1 paid to find --
#     asserted on the EMITTED RML, then proven on a LAID-OUT panel
#   - a declared size MEANS its number: the flexbox squeeze that cost the
#     showcase two invisible bars cannot happen to a .panel author
#
# Scenes 1-6 need no GPU and no layout engine beyond stz_gui.dll.

load "../../stzBase.ring"

nPass = 0
nFail = 0

cQ = char(34)

# a small clean document, reused all over
cGood = 'DEFINE PANEL p ( SIZE [400, 300], FONT "app", CHILDREN [a, b] ) RATIONALE "A test screen."' + char(10) +
	'DEFINE BOX a ( WIDTH 100, HEIGHT 40, BACKGROUND "#ff0000" ) RATIONALE "A fixed box."' + char(10) +
	'DEFINE BOX b ( HEIGHT fill, CHILDREN [t] ) RATIONALE "The rest of the screen."' + char(10) +
	'DEFINE TEXT t ( CONTENT "hello", SIZE 16, COLOR "#ffffff" ) RATIONALE "A word."'

? "-- Scene 1: a clean document parses, and the court agrees --"
oU = new stzUiDocument(cGood)
chk("the document is clean", oU.IsClean())
chk("four declarations came through", len(oU.Declarations()) = 4)
chk("a declaration is findable by name", len(oU.DeclOf("b")) > 0)
chk("...and a missing one answers empty", len(oU.DeclOf("zz")) = 0)

? ""
? "-- Scene 2: the court's refusals, each by name --"
# closure: the verb set is closed
chk("a foreign verb is refused",
    _FirstCode('DELETE PANEL p ( ) RATIONALE "x"') = "UNKNOWN_DECLARATION")
chk("a foreign kind is refused",
    _FirstCode('DEFINE VIRUS v ( ) RATIONALE "x"') = "UNKNOWN_DECLARATION")
# the commons' Ring trap: keywords are CASE-SENSITIVE, and Ring's lax `=`
# would silently accept `define` -- so this assertion is the trap's guard
chk("`define` in lowercase does NOT parse (strcmp, not =)",
    _FirstCode('define PANEL p ( ) RATIONALE "x"') = "UNKNOWN_DECLARATION")
# closed field sets
chk("an unknown field is an error, not a shrug",
    _HasCode(cGood + char(10) +
        'DEFINE BOX c ( SORCERY 3 ) RATIONALE "x"', "UNKNOWN_FIELD"))
# references
chk("a child declared nowhere is DANGLING",
    _HasCode('DEFINE PANEL p ( CHILDREN [ghost] ) RATIONALE "x"',
        "DANGLING_REFERENCE"))
chk("a STYLE reference to a non-style is DANGLING",
    _HasCode('DEFINE PANEL p ( CHILDREN [a, b] ) RATIONALE "x"' + char(10) +
        'DEFINE BOX a ( WIDTH 5 ) RATIONALE "x"' + char(10) +
        'DEFINE BOX b ( STYLE a ) RATIONALE "x"', "DANGLING_REFERENCE"))
# duplicates, parents, panels
chk("declaring one name twice is refused",
    _HasCode(cGood + char(10) + 'DEFINE BOX a ( WIDTH 1 ) RATIONALE "x"',
        "DUPLICATE_DECLARATION"))
chk("a box under two parents is refused",
    _HasCode('DEFINE PANEL p ( CHILDREN [a, b] ) RATIONALE "x"' + char(10) +
        'DEFINE BOX a ( CHILDREN [c] ) RATIONALE "x"' + char(10) +
        'DEFINE BOX b ( CHILDREN [c] ) RATIONALE "x"' + char(10) +
        'DEFINE BOX c ( WIDTH 1 ) RATIONALE "x"', "MANY_PARENTS"))
chk("a box no parent places is an ORPHAN",
    _HasCode(cGood + char(10) + 'DEFINE BOX loose ( WIDTH 9 ) RATIONALE "x"',
        "ORPHAN"))
chk("a file with no PANEL is refused", _HasCode(
    'DEFINE BOX a ( WIDTH 1 ) RATIONALE "x"', "NO_PANEL"))
chk("two PANELs are refused", _HasCode(
    'DEFINE PANEL p ( ) RATIONALE "x"' + char(10) +
    'DEFINE PANEL q ( ) RATIONALE "x"', "MANY_PANELS"))
# the commons' one legislated element
chk("a declaration without RATIONALE is refused",
    _HasCode('DEFINE PANEL p ( SIZE [10, 10] )', "MISSING_RATIONALE"))

? ""
? "-- Scene 3: the round trip closes (birth-check 4) --"
# parse -> print -> parse -> print: the two prints must be BYTE-equal.
# This is the check the commons says the elders lack, so it is asserted
# here rather than assumed.
oR1 = new stzUiDocument(cGood)
cP1 = oR1.ToText()
oR2 = new stzUiDocument(cP1)
cP2 = oR2.ToText()
chk("the reprint of a reparse is byte-identical", cP1 = cP2 and len(cP1) > 0)
chk("...and the reparse is still clean", oR2.IsClean())
chk("...with the same declarations", len(oR2.Declarations()) = 4)

? ""
? "-- Scene 4: the emitter absorbs what G1 paid to find --"
cRml = oU.ToRml()
# divergence 4: explicit display on every element
chk("every element carries an explicit display",
    len(StzFindCS("display:", cRml, 1)) >= 4)
# divergence 3: the root fills its panel
chk("the root is sized to the panel", StzFindFirst("width: 100%", cRml) > 0)
# divergence 5: a font-family is always declared
chk("a font-family is always declared", StzFindFirst("font-family:", cRml) > 0)
# divergence 2: XML-closed tags only
chk("no tag is left unclosed", StzFindFirst("<div id=" + cQ + "a" + cQ + "/>", cRml) > 0)
# the design decision: a declared px size is a FLOOR
chk("WIDTH 100 rides with flex-shrink: 0", StzFindFirst("flex-shrink: 0", cRml) > 0)
# divergence 1, on a fresh document
oRtl = new stzUiDocument(
	'DEFINE PANEL p ( FONT "app", CHILDREN [r] ) RATIONALE "x"' + char(10) +
	'DEFINE BOX r ( TEXT_DIRECTION rtl, HEIGHT 20 ) RATIONALE "x"')
chk("TEXT_DIRECTION rtl becomes --rmlui-direction",
    StzFindFirst("--rmlui-direction: rtl", oRtl.ToRml()) > 0)
chk("...and never the CSS spelling RCSS rejects",
    StzFindFirst("; direction:", oRtl.ToRml()) = 0)
# WRAP brings its companion
oW = new stzUiDocument(
	'DEFINE PANEL p ( FONT "app", CHILDREN [w] ) RATIONALE "x"' + char(10) +
	'DEFINE BOX w ( DIRECTION row, WRAP yes, CHILDREN [k] ) RATIONALE "x"' + char(10) +
	'DEFINE BOX k ( WIDTH 10, HEIGHT 10 ) RATIONALE "x"')
chk("WRAP yes brings align-content: flex-start",
    StzFindFirst("align-content: flex-start", oW.ToRml()) > 0)

? ""
? "-- Scene 5: an unclean document REFUSES to project --"
oBad = new stzUiDocument('DEFINE PANEL p ( CHILDREN [ghost] ) RATIONALE "x"')
chk("the court found the dangling child", NOT oBad.IsClean())
bRaised = 0
try
	oBad.ToRml()
catch
	bRaised = 1
done
chk("ToRml raises rather than projecting a broken contract", bRaised = 1)

if NOT StzGuiAvailable()
	? ""
	? "No layout engine on this machine -- the living-panel scenes are skipped."
	? "=============================================================="
	? " " + nPass + " ok, " + nFail + " failed"
	? "=============================================================="
	return
ok

? ""
? "-- Scene 6: the declared sizes ARE the laid-out sizes --"
# THE FONT IS NOT DECORATION HERE. This scene lays a document out and
# checks the boxes came back the declared size -- and it was doing that
# with NO font registered, which means RmlUi was laying out no text at
# all and the sizes were measured on an empty screen. ToPanel refuses
# that now, which is how the gap in this scene was found.
oU.UseFont(_FontPath())
oP = oU.ToPanel()
aA = oP.BoxOf("a")
chk("the panel took the declared SIZE", oP.Width() = 400 and oP.Height() = 300)
chk("WIDTH 100 laid out as exactly 100", aA[3] = 100)
chk("HEIGHT 40 laid out as exactly 40", aA[4] = 40)
aB = oP.BoxOf("b")
chk("HEIGHT fill takes exactly the leftover", aB[4] = 300 - 40)
oP.Free()

# THE BORDER-BOX LAW: an author who declares WIDTH 210 and PADDING 20
# means a 210-pixel region with the padding INSIDE. CSS's content-box
# default would silently make it 250 -- the first .panel screenshot had
# exactly that sidebar, which is why this is now emitted on every box.
oBB = new stzUiDocument(
	'DEFINE PANEL p ( FONT "app", CHILDREN [x] ) RATIONALE "x"' + char(10) +
	'DEFINE BOX x ( WIDTH 100, HEIGHT 60, PADDING 10 ) RATIONALE "x"')
oBP = oBB.ToPanel()
aX = oBP.BoxOf("x")
chk("WIDTH 100 with PADDING 10 occupies 100, not 120 (border-box)",
    aX[3] = 80 and aX[4] = 40)
oBP.Free()

? ""
? "-- Scene 7: the showcase file, from disk to geometry --"
oS = new stzUiDocument("showcase.panel")
chk("showcase.panel is clean", oS.IsClean())
# the committed fixture, so this scene exercises the REAL text path on a
# CI machine with no system font
oS.UseFont("../gpu/fixtures/amiri_arabic_subset.ttf")
chk("...and carries 26 declarations", len(oS.Declarations()) = 26)
oSP = oS.ToPanel()
aBar = oSP.BoxOf("bar")
aSide = oSP.BoxOf("side")
aFoot = oSP.BoxOf("foot")
chk("the bar spans the screen at its declared 52 (padding inside)",
    aBar[3] = 1000 - 12 and aBar[4] = 52 - 12)
# BoxOf answers the CONTENT box; border-box puts the padding inside the
# declared 210, so content = 210 - 2*20. The invariant asserted is the
# declared TOTAL, reconstructed.
chk("the sidebar occupies its declared 210 (content 170 + padding 40)",
    aSide[3] = 210 - 40)
chk("the footer was NOT squeezed (30 total, padding inside)",
    aFoot[4] = 30 - 16)
chk("six cards laid out", len(oSP.BoxOf("card_perf")) = 4)
# G2 retired the bridge this used to prove: the panel now carries its own
# text, so what matters is that every TEXT declaration became a real draw
# command rather than something a caller has to place by hand.
chk("every TEXT declaration became a draw command",
    len(oSP.Texts()) = 12)
chk("...and none of them was lost on the way", oSP.TextIsWhole())
# round trip on the real file too -- a fixture is only a fixture if the
# real artifact passes it
cS1 = oS.ToText()
oS2 = new stzUiDocument(cS1)
chk("the showcase round-trips to a fixpoint", oS2.ToText() = cS1)
oSP.Free()

? ""
? "-- Scene 12: the court's first WARNING, not an error --"
# StzZui's finding 1. A hex literal is a meaning that escaped the
# semantic layer, and this project has watched that happen once already:
# Rule 118, Rule 3 and the graphics engine derived the same five semantic
# values independently and drifted into three spellings. Warn now, refuse
# at G6 -- so the corpus grows with a marked trail instead of a silent
# one.
oW = new stzUiDocument("showcase.panel")
nLit = 0
aDg = oW.Diagnostics()
nDg = len(aDg)
for i = 1 to nDg
	if aDg[i][:code] = "LITERAL_COLOUR"
		nLit++
	ok
next
? "  the showcase raises " + nLit + " literal-colour warnings"
chk("the showcase raises them", nLit > 10)
# THE POINT OF A WARNING: it does not refuse. A check that made every
# existing document unclean would have been reverted within a day.
chk("...and the document is STILL CLEAN", oW.IsClean())
chk("...because a warning is not an error", len(oW.Errors()) = 0)
chk("...and it still projects", len(oW.ToRml()) > 100)

# The negative sibling: a document with no literal colour raises none.
oNoLit = new stzUiDocument('
DEFINE PANEL p ( SIZE [100, 80], FONT "app", CHILDREN [b] ) RATIONALE "No colour named here."
DEFINE BOX b ( HEIGHT 20 ) RATIONALE "Nor here."
')
nLit2 = 0
aDg = oNoLit.Diagnostics()
nDg = len(aDg)
for i = 1 to nDg
	if aDg[i][:code] = "LITERAL_COLOUR"
		nLit2++
	ok
next
chk("a document naming no colour raises no warning", nLit2 = 0)

? ""
? "-- Scene 13: the intent slot, parsed and NOT resolved --"
# StzZui's finding 2. The founding inversion says every UI element must
# trace to at least one intent. The field exists NOW so a file written
# today is complete when the binding lands, rather than needing a pass
# over every declaration.
#
# The finding offered a cheaper answer -- put it beside Roles() -- and
# looking showed it does not apply: Roles() is a closed ARIA vocabulary
# whose own comment says a role is NOT a meaning.
oI = new stzUiDocument('
DEFINE PANEL form ( SIZE [400, 300], FONT "app", SATISFIES [ transfer_funds ], CHILDREN [ row, note ] ) RATIONALE "A transfer screen."
DEFINE BOX row ( HEIGHT 40, SATISFIES confirm_amount ) RATIONALE "One name, no brackets."
DEFINE TEXT note ( CONTENT "nothing claimed" ) RATIONALE "An orphan, by the inversion test."
DEFINE STYLE quiet ( SIZE 12 ) RATIONALE "A style is not an element."
')
chk("a document declaring intents is clean", oI.IsClean())
chk("a list of intents is read", len(oI.IntentsOf("form")) = 1)
chk("...and a BARE name is read as a list of one",
    len(oI.IntentsOf("row")) = 1 and oI.IntentsOf("row")[1] = "confirm_amount")
chk("every intent named anywhere is collected", len(oI.SatisfiedIntents()) = 2)
chk("an element claiming none is an ORPHAN", _Has(oI.Orphans(), "note"))
chk("...and one that claims some is not", NOT _Has(oI.Orphans(), "form"))

# A STYLE IS NOT AN ELEMENT, so it cannot be an orphan -- absent by
# construction rather than by omission. One intent traced through a thing
# that never appears on screen would be worse than no trace at all.
chk("a STYLE is not counted as an orphan", NOT _Has(oI.Orphans(), "quiet"))
chk("...and cannot declare the field at all",
    NOT (new stzUiDocument('
DEFINE PANEL p ( SIZE [10, 10], FONT "app", CHILDREN [s] ) RATIONALE "x"
DEFINE BOX s ( STYLE bad ) RATIONALE "y"
DEFINE STYLE bad ( SATISFIES anything ) RATIONALE "A style may not claim an intent."
')).IsClean())

chk("the slot survives the round-trip fixpoint",
    oI.ToText() = (new stzUiDocument(oI.ToText())).ToText())

# NOTHING IS RESOLVED, and that is deliberate: there is no .zui to
# resolve against from here, and resolution stays StzZui's.
chk("an intent nobody has defined is NOT an error",
    (new stzUiDocument('
DEFINE PANEL p ( SIZE [10, 10], FONT "app", SATISFIES no_such_flow, CHILDREN [b] ) RATIONALE "x"
DEFINE BOX b ( HEIGHT 5 ) RATIONALE "y"
')).IsClean())

? ""
? "=============================================================="
? " " + nPass + " ok, " + nFail + " failed"
? "=============================================================="

#-- helpers ---------------------------------------------------------------

func _FirstCode cText
	_o_ = new stzUiDocument(cText)
	_a_ = _o_.Errors()
	if len(_a_) = 0
		return ""
	ok
	return _a_[1][:code]

func _HasCode cText, cCode
	_o_ = new stzUiDocument(cText)
	_a_ = _o_.Errors()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if strcmp(_a_[_i_][:code], cCode) = 0
			return 1
		ok
	next
	return 0

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func _FontPath
	_a_ = [ "C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf",
	        "../gpu/fixtures/amiri_arabic_subset.ttf" ]
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if fexists(_a_[_i_])
			return _a_[_i_]
		ok
	next
	return ""

func _Has aList, cName
	_n_ = len(aList)
	for _i_ = 1 to _n_
		if aList[_i_] = cName
			return 1
		ok
	next
	return 0
