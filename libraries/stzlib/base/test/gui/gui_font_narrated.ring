# G2 -- THE FONT ENGINE -- base/gui/SOFTANZA_GUI_PLAN.md.
#
# G1's font engine was a monospace stub: every codepoint the same width,
# no glyphs, and a panel that had chrome and nothing to read. G2 replaces
# it with the house's own pipeline -- SheenBidi reorders, HarfBuzz shapes,
# stb_truetype rasters -- so RmlUi lays out with the widths the glyphs
# actually have.
#
# THE ARCHITECTURE, and why it is not a second renderer: the SAME
# gpu_text.zig is compiled into stz_gui.dll (which measures) and
# stz_gpu.dll (which paints). Two copies of one source over one font file
# cannot disagree; a protocol between two DLLs could. And text crosses
# the C ABI as COMMANDS -- font, size, baseline, colour, bytes -- not as
# quads, so this plane owns no glyph atlas and no second rasterizer.
#
# WHAT IS ASSERTED, all of it a MECHANISM:
#   - the SEAM AGREES: the width RmlUi laid out equals the width the
#     shaper reports, to the integer G0 predicted it would round to
#   - it is really SHAPING: 'iii' and 'WWW' get different widths, which
#     the stub could not produce, and Arabic JOINS
#   - the WIDTH CACHE is real: 21 layouts ask 630 times and shape 15
#   - text commands survive RE-RENDER, because RmlUi calls GenerateString
#     only when dirty and replays the compiled result forever after
#   - and the G1 fallback still stands: a document with no registered
#     font lays out exactly as it did
#
# Needs stz_gui.dll; needs no GPU. The committed Amiri fixture is the
# multilingual face, so CI shapes real Arabic with no system font.

load "../../stzBase.ring"

nPass = 0
nFail = 0

if NOT StzGuiAvailable()
	? "No layout engine on this machine -- nothing to measure."
	? " 0 ok, 0 failed"
	return
ok

cFixture = "../gpu/fixtures/amiri_arabic_subset.ttf"

# the library's name in Arabic: sin-waw-fa-ta-alef-noon-zay-alef
cSeen = char(0xD8)+char(0xB3)   cWaw = char(0xD9)+char(0x88)
cFa   = char(0xD9)+char(0x81)   cTa  = char(0xD8)+char(0xAA)
cAlef = char(0xD8)+char(0xA7)   cNoon = char(0xD9)+char(0x86)
cZay  = char(0xD8)+char(0xB2)
cArabic = cSeen + cWaw + cFa + cTa + cAlef + cNoon + cZay + cAlef
# the same letters SEPARATED by spaces: joining cannot happen across a
# space, so this is the same glyphs unjoined -- the classic witness
cApart = cSeen + " " + cWaw + " " + cFa + " " + cTa + " " + cAlef + " " +
	cNoon + " " + cZay + " " + cAlef

# A ROW flex parent, deliberately: a COLUMN one stretches its item across
# the cross axis, so every measurement comes back as the panel's own width
# and the whole scene passes by measuring nothing. Found the hard way.
cStyle = 'body { display: flex; flex-direction: row; align-items: flex-start;' +
	' width: 100%; height: 100%; font-family: app; font-size: 24px; }' +
	' div { display: block; }' +
	' #a { display: block; color: #ffffff; }'

? "-- Scene 1: a font is registered, and it is REAL --"
oP = new stzPanel(900, 200)
oF = oP.UseFont("app", cFixture)
chk("UseFont answers an stzFont to paint with", isObject(oF))
chk("the engine holds one family", oP.FontCount() = 1)
chk("...and it is the fixture, by its glyph count", oF.GlyphCount() = 1449)
chk("registering nothing is refused", oP.UseFont("bad", "not a font at all") = NULL)

? ""
? "-- Scene 2: THE SEAM AGREES -- layout width == shaper width --"
# The one assertion this whole phase exists to make. If these two ever
# part, the panel paints text in a box that was measured for different
# text, and every alignment in every screen is quietly wrong.
aCases = [ "Hamburgefonstiv", "iii", "WWW", cArabic ]
nMaxDelta = 0
nC = len(aCases)
for i = 1 to nC
	nBox = _WidthOf(oP, cStyle, aCases[i])
	nShaped = oF.WidthOf(aCases[i], 24)
	nD = fabs(nBox - nShaped)
	if nD > nMaxDelta
		nMaxDelta = nD
	ok
	? "   layout " + nBox + "  shaper " + nShaped + "  delta " + (floor(nD * 100) / 100)
next
# G0 recorded that GetStringWidth returns an int against our 1/64 px f64.
# So they agree to the ROUNDING and no further -- and saying that is the
# honest assertion, where "equal" would be a lie that passes.
chk("every case agrees within the integer rounding", nMaxDelta < 1.0)
chk("...and the rounding is the ONLY disagreement", nMaxDelta > 0)

? ""
? "-- Scene 3: it is SHAPING, not counting characters --"
# The negative sibling for scene 2: a stub that returned codepoints *
# size/2 would give these two the SAME width. Three narrow letters and
# three wide ones are the cheapest proof that glyphs were consulted.
nNarrow = _WidthOf(oP, cStyle, "iii")
nWide = _WidthOf(oP, cStyle, "WWW")
? "   iii = " + nNarrow + " px, WWW = " + nWide + " px"
chk("three narrow letters are narrower than three wide ones",
    nWide > nNarrow * 2)
chk("...and neither is the stub's codepoints * size/2 (36)",
    nNarrow != 36 and nWide != 36)

# Arabic joins: the same letters, joined and apart. Joined must be
# NARROWER, because joining forms are cursive and share strokes.
nJoined = _WidthOf(oP, cStyle, cArabic)
nApart = _WidthOf(oP, cStyle, cApart)
? "   arabic joined = " + nJoined + " px, the same letters apart = " + nApart + " px"
chk("the joined word is measurably narrower than its letters apart",
    nJoined < nApart)

? ""
? "-- Scene 4: THE WIDTH CACHE -- the precondition, measured --"
# G0 measured 988 GetStringWidth calls per re-layout, unmemoized by
# RmlUi; at ~1 us per real shape that is ~1 ms/frame before a glyph is
# drawn. The plan made a cache a PRECONDITION of this phase, so the gauge
# is here rather than in a comment.
oW = new stzPanel(240, 300)
oW.UseFont("app", cFixture)
oW.LoadMarkup('<rml><head><style>' +
	'body { display: flex; flex-direction: column; width: 100%; height: 100%;' +
	' font-family: app; font-size: 16px; }' +
	' div { display: block; }' +
	' #a { display: block; width: 100%; color: #ffffff; }' +
	'</style></head><body><div id="a">' +
	'the quick brown fox jumps over the lazy dog and keeps running far away' +
	'</div></body></rml>')
oW.Layout()
oW.Record()
nAsk0 = oW.WidthCalls()
nShape0 = oW.ShapeCalls()
for i = 1 to 20
	oW.Resize(240 - (i % 3), 300)
next
oW.Record()
nAsk = oW.WidthCalls()
nShape = oW.ShapeCalls()
? "   21 layouts: RmlUi asked " + nAsk + " times, the shaper ran " + nShape + " times"
? "   cache hits: " + oW.WidthCacheHits()
chk("RmlUi asks far more than once per string", nAsk > 100)
chk("...but the shaper runs only once per distinct token", nShape < 40)
chk("...so the cache absorbed the rest", oW.WidthCacheHits() > nAsk * 0.9)
# the negative sibling: if shapeCalls tracked widthCalls, the cache would
# be absent and the number above would prove nothing
chk("shaping did NOT grow with the layouts", nShape = nShape0)
chk("...while asking did", nAsk > nAsk0)

? ""
? "-- Scene 5: text crosses as COMMANDS, and they SURVIVE --"
aT = oW.Texts()
? "   " + len(aT) + " text commands (one per laid-out line)"
chk("the wrapped paragraph became more than one line", len(aT) > 1)
chk("a command carries its bytes", len(aT[1][6]) > 0)
chk("...its font id", aT[1][1] > 0)
chk("...its size", aT[1][2] = 16)
chk("...and a colour with full alpha", (aT[1][5] % 256) = 255)
# RmlUi calls GenerateString only when the text is DIRTY and replays the
# compiled geometry forever after -- so a recorder that only listened to
# GenerateString would lose every command from the second frame on. This
# is the assertion that caught exactly that, and it is why the command
# rides RmlUi's own geometry cache.
aT2 = oW.Texts()
aT3 = oW.Texts()
chk("re-rendering an unchanged panel keeps every command",
    len(aT2) = len(aT) and len(aT3) = len(aT))
chk("...with the same bytes", aT3[1][6] = aT[1][6])
chk("...and the same baseline", aT3[1][4] = aT[1][4])

? ""
? "-- Scene 6: the lines broke at REAL widths --"
# Every line must fit the panel it was measured for. A stub's widths
# would have broken this paragraph in different places, and a line
# wider than its box is what an author sees as text running off a card.
bFits = 1
nT = len(aT)
for i = 1 to nT
	if oF.WidthOf(aT[i][6], 16) > oW.Width() + 1
		bFits = 0
	ok
next
chk("every line fits the width it was laid out for", bFits = 1)
chk("the first line starts at the origin", aT[1][3] = 0)
if len(aT) > 1
	chk("...and the second sits a line below it", aT[2][4] > aT[1][4])
ok

? ""
? "-- Scene 7: font families are PROCESS-WIDE, and unknown ones fall back --"
# Found by a failing assertion that expected per-panel fonts. RmlUi keeps
# faces in its own global registry and so does this engine, so a family
# registered by ANY panel is visible to every other one in the process.
# That is worth asserting rather than discovering: it means a document
# does not have to re-register a face it did not load, and it means a
# test cannot get the G1 stub back once anything has registered a font.
oS = new stzPanel(300, 100)
oS.LoadMarkup('<rml><head><style>' + cStyle +
	'</style></head><body><div id="a">iii</div></body></rml>')
oS.Layout()
aS = oS.BoxOf("a")
chk("a panel that registered nothing still sees the family", aS[3] = nNarrow)
chk("...so it is NOT the stub's 3 chars * 24/2 = 36", aS[3] != 36)
chk("...and it draws real text", len(oS.Texts()) > 0)
oS.Free()

# a document naming a family nobody registered must still lay out: any
# face beats no face, and the alternative is text that silently vanishes
# (the G1 divergence that cost a screenshot to find)
oU = new stzPanel(300, 100)
oU.LoadMarkup('<rml><head><style>' +
	'body { display: flex; flex-direction: row; align-items: flex-start;' +
	' width: 100%; height: 100%; font-family: nobody_registered_this;' +
	' font-size: 24px; } div { display: block; }' +
	' #a { display: block; color: #ffffff; }' +
	'</style></head><body><div id="a">iii</div></body></rml>')
oU.Layout()
aU = oU.BoxOf("a")
chk("an unknown family falls back to a real face, not to nothing",
    aU[3] = nNarrow)
chk("...and its text still reaches the canvas", len(oU.Texts()) > 0)
oU.Free()

oW.Free()
oP.Free()

? ""
? "=============================================================="
? " " + nPass + " ok, " + nFail + " failed"
? "=============================================================="

#-- helpers ---------------------------------------------------------------

# The laid-out width of one string, through a fresh document each time so
# nothing is inherited from the last measurement.
func _WidthOf oPanel, cStyle, cText
	oPanel.LoadMarkup('<rml><head><style>' + cStyle +
		'</style></head><body><div id="a">' + cText + '</div></body></rml>')
	oPanel.Layout()
	_a_ = oPanel.BoxOf("a")
	if len(_a_) != 4
		return -1
	ok
	return _a_[3]

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
