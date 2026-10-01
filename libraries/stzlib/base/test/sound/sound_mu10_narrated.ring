# MU10 -- the score DRAWN: on the staff, as musicians write melodies down; and a
# mode drawn as a LADDER, as maqam scales are taught.
#
#     StzSoundStaffQ(oScore).SaveAs("tune.html", "title")
#     StzSoundUniverseQ(:tunisian).LadderQ().SaveAs("dhil.html")
#
# Both are held to the rules of what they draw, read from the MODEL the drawing
# is made from -- every notehead with its staff step, every accidental, tie,
# beam and rest; every rung with its cents -- not from pixels. Whether the page
# LOOKS like sheet music is the Principal's to say, and the guard says so.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(3)

? "== MU10: the staff, and the maqam ladder =="
? ""

? "-- Scene 1: where a note sits is its pitch --"
oA = StzSoundScoreQ().Tempo(90).On(:flute)
oA.NoteAt(0, "C4", 1).NoteAt(1, "E4", 1).NoteAt(2, "F5", 1).NoteAt(3, "A5", 1)
oSA = StzSoundStaffQ(oA)
oSA.ToSVG("")
aH = Mu10Of(oSA.Model(), "head")
? "   C4 E4 F5 A5 on the treble staff: steps " + Mu10Col(aH, 7) + "(0 is the bottom line, 8 the top)"
Chk("C4 sits on the first ledger line below the treble staff, E4 on its bottom line, F5 on its top line, A5 on the first ledger above",
    Mu10Col(aH, 7) = "-2 0 8 10 ")
Chk("and exactly two ledger lines are drawn: one under C4, one over A5", len(Mu10Of(oSA.Model(), "ledger")) = 2)
Chk("stems go UP below the middle line and DOWN above it", Mu10Col(aH, 11) = "up up down down ")
oB = StzSoundScoreQ().On(:piano).NoteAt(0, "G2", 1).NoteAt(1, "F2", 1).NoteAt(2, "A3", 1).NoteAt(3, "C4", 1)
oSB = StzSoundStaffQ(oB)
oSB.ToSVG("")
aHB = Mu10Of(oSB.Model(), "head")
Chk("a low voice gets the BASS clef, where G2 is the bottom line, A3 the top, and middle C the first ledger above",
    oSB.Clefs()[1][2] = "bass" and Mu10Col(aHB, 7) = "0 -1 8 10 ")

? ""
? "-- Scene 2: the length is the shape --"
oRh = StzSoundScoreQ().On(:flute)
oRh.NoteAt(0, "G4", 0.5).NoteAt(0.5, "A4", 0.5).NoteAt(1, "B4", 0.25).NoteAt(1.25, "C5", 0.25).NoteAt(1.5, "D5", 0.5)
oRh.NoteAt(2, "E5", 1.5).NoteAt(3.5, "D5", 0.5)
oRh.NoteAt(4, "C5", 6)
oRh.NoteAt(11, "G4", 1)
oRh.NoteAt(16, "F4", 4)
oSR = StzSoundStaffQ(oRh)
oSR.ToSVG("")
aM = oSR.Model()
aBeams = Mu10Of(aM, "beam")
? "   beams: " + len(aBeams) + " (" + Mu10Col(aBeams, 5) + "notes; levels " + Mu10Col(aBeams, 6) + ")"
Chk("two eighths on a beat are BEAMED; two sixteenths and an eighth on the next beat take a second beam",
    len(aBeams) = 2 and Mu10Col(aBeams, 5) = "2 3 " and Mu10Col(aBeams, 6) = "1 2 ")
aFl = Mu10Of(aM, "flag")
Chk("an eighth alone on its beat takes a FLAG instead", len(aFl) = 1 and aFl[1][6] = 1)
Chk("a dotted quarter is drawn with its dot", len(Mu10Of(aM, "dot")) = 1)
aT = Mu10Of(aM, "tie")
aHR = Mu10Of(aM, "head")
? "   C5 for six beats from beat 4: " + Mu10Count(aHR, 8, "C5") + " heads, " + len(aT) + " tie(s)"
Chk("a note that crosses a barline is written as two notes TIED: a whole note into a half", len(aT) = 1 and
    Mu10Count(aHR, 8, "C5") = 3)
# and from the MIDDLE of a bar: the room left in the bar decides, not the length
oX = StzSoundScoreQ().On(:flute).NoteAt(3, "A4", 2).NoteAt(5, "B4", 3)
oSX = StzSoundStaffQ(oX)
oSX.ToSVG("")
aHX = Mu10Of(oSX.Model(), "head")
Chk("a half note begun on the fourth beat is a quarter in its bar, tied to a quarter in the next",
    len(aHX) = 3 and aHX[1][4] = 0 and aHX[1][10] = 4 and aHX[2][4] = 1 and aHX[2][10] = 4 and
    len(Mu10Of(oSX.Model(), "tie")) = 1)
aRe = Mu10Of(aM, "rest")
? "   rests: " + Mu10Col(aRe, 6) + "(sixteenths)"
Chk("every gap is a rest, and an empty bar is ONE whole rest", Mu10Col(aRe, 6) = "4 16 ")

? ""
? "-- Scene 3: accidentals hold to the barline; the quarter tones are written --"
oC = StzSoundScoreQ().On(:flute)
oC.NoteAt(0, "C#5", 1).NoteAt(1, "C#5", 1).NoteAt(2, "C5", 1).NoteAt(3, "E4-50", 1).NoteAt(4, "C5", 1).NoteAt(5, "E4-50", 3)
oSC = StzSoundStaffQ(oC)
oSC.ToSVG("")
aAc = Mu10Of(oSC.Model(), "acc")
? "   C#5 C#5 C5 E-half-flat | C5 E-half-flat: accidentals shown " + Mu10Col(aAc, 7)
Chk("the sharp is written once, the natural cancels it, and the next bar needs none: # - n", Mu10Col(aAc, 7) = "1 0 -0.500 -0.500 ")
Chk("the half-flat is written in BOTH bars -- the barline forgets it", len(aAc) = 4 and aAc[4][4] = 1)
cSvgC = oSC.ToSVG("")
Chk("and is drawn as Arabic notation draws it: a flat with a stroke through it", Mu10Accs(cSvgC) >= 2)

? ""
? "-- Scene 4: chords, voices and pages --"
oD = StzSoundScoreQ().On(:piano).NoteAt(0, "C4", 2).NoteAt(0, "D4", 2).NoteAt(0, "G4", 2)
oSD = StzSoundStaffQ(oD)
oSD.ToSVG("")
aHD = Mu10Of(oSD.Model(), "head")
Chk("a second inside a chord sets its two heads either side of the stem", len(aHD) = 3 and aHD[1][5] != aHD[2][5])
oL = StzSoundScoreQ().On(:flute)
for k = 0 to 95  oL.NoteAt(k, 440 * pow(2, (k % 12) / 12), 1) next
oSL = StzSoundStaffQ(oL)
oSL.ToSVG("a long line")
aBl = Mu10Of(oSL.Model(), "barline")
aSy = Mu10Of(oSL.Model(), "system")
nBarsSeen = 0
for s in aSy  nBarsSeen += s[3] next
? "   96 beats: " + oSL.Bars() + " bars in " + oSL.Systems() + " systems"
Chk("a long melody breaks into systems, and every bar is drawn once", oSL.Systems() > 1 and nBarsSeen = 24 and len(aBl) = 24)
nRight = 0
bSame = TRUE
for b in aBl
	if b[3] = 1  nRight = b[5] ok
next
for b in aBl
	if b[4] = Mu10LastBarOf(aSy, b[3]) and b[3] < oSL.Systems() and fabs(b[5] - nRight) > 0.5  bSame = FALSE ok
next
Chk("and every system but the last is justified to the same right edge", bSame)
oV = StzSoundScoreQ().On(:flute).NoteAt(0, "G5", 4).On(:piano).NoteAt(0, "C3", 4)
oSV = StzSoundStaffQ(oV)
oSV.ToSVG("")
Chk("two instruments are two staves, each with its own clef", len(oSV.Clefs()) = 2 and oSV.Clefs()[1][2] = "treble" and
    oSV.Clefs()[2][2] = "bass")

? ""
? "-- Scene 5: the metre --"
oE = StzSoundScoreQ().On(:flute)
for k = 0 to 5  oE.NoteAt(k * 0.5, "D5", 0.5) next
oSE = StzSoundStaffQ(oE).SetMeter(6, 8)
oSE.ToSVG("")
aBE = Mu10Of(oSE.Model(), "beam")
Chk("in 6/8 six eighths are beamed in TWO threes -- by the dotted quarter, not the quarter",
    len(aBE) = 2 and Mu10Col(aBE, 5) = "3 3 ")
Chk("and a metre that is not one is refused", oSE.SetMeter(5, 3).LastError() != "")

? ""
? "-- Scene 6: what the staff cannot show is COUNTED --"
oF = StzSoundScoreQ().On(:oud).NoteAt(0, "C4", 1).On(:darbouka).StrokeAt(1, :dum, 1)
oSF = StzSoundStaffQ(oF)
oSF.ToSVG("")
Chk("drum strokes are not drawn, and Losses says so", Mu10Has(oSF.Losses(), "strokes"))
oG = StzSoundUniverseQ(:gamelan).NoCycle(4).SonifyQ([ 1, 2, 3, 4, 5 ])
oSG = StzSoundStaffQ(oG)
oSG.ToSVG("")
Chk("slendro, which no staff can write, is drawn at the nearest quarter tone and counted",
    Mu10Has(oSG.Losses(), "quarter tone"))
cSvg = oSR.ToSVG("A test")
aX = Mu10XmlBalanced(cSvg)
Chk("the page is well-formed SVG (" + aX[2] + " elements), with a treble clef in it", aX[1] and substr(cSvg, "&#x1D11E;") > 0)

? ""
? "-- Scene 7: the maqam LADDER -- a rung per degree, spaced by cents --"
oLd = StzSoundLadderQ(:tunisian, :dhil)
aRg = oLd.Rungs()
? oLd.ToText()
Chk("Dhil's rungs are its declared degrees, the octave included: 0 200 350 500 700 900 1050 1200",
    Mu10Col(aRg, 3) = "0 200 350 500 700 900 1050 1200 ")
Chk("and its steps are the tone, the three-quarter tones and the tone again, adding to the octave",
    Mu10ListText(oLd.Steps()) = "200 150 150 200 200 150 150 " and Mu10Sum(oLd.Steps()) = 1200)
Chk("the half-flat third is 350 cents: half way between a minor third (300) and a major one (400)", aRg[3][3] = 350)
Chk("each step is named in tones where it is one: 150 is a three-quarter tone", substr(oLd.ToText(), "150  (3/4 tone)") > 0)
aJ = oLd.Ajnas()
Chk("the jins below the tonic spans -500 to 0 cents (rast on G), the one above 0 to 500",
    aJ[1][2] = -500 and aJ[1][3] = 0 and aJ[2][2] = 0 and aJ[2][3] = 500)
cLd = oLd.ToSVG()
Chk("the sources' variants of the third (300, 400) are drawn as their own dotted rungs",
    substr(cLd, "variant 300") > 0 and substr(cLd, "variant 400") > 0)
oSk = StzSoundLadderQ(:tunisian, :sika)
Chk("a jins counted from its own degree lands there: Sika's rast on its third spans 350 to 850",
    oSk.Ajnas()[2][2] = 350 and oSk.Ajnas()[2][3] = 850)
oRs = StzSoundUniverseQ(:maqam).LadderQ()
aDn = oRs.DescendingRungs()
Chk("Rast's seventh is 1050 going up and 1000 coming down: the descending form is its own rung",
    oRs.Rungs()[7][3] = 1050 and aDn[7][3] = 1000 and substr(oRs.ToSVG(), "coming down: 1000") > 0)
oSl = StzSoundLadderQ(:gamelan, :slendro)
Chk("slendro's octave is 1208 cents, as measured -- not forced to 1200 -- and its 231-cent step has no tone name",
    oSl.Rungs()[6][3] = 1208 and substr(oSl.ToText(), "231  " + nl) > 0)
oTd = StzSoundUniverseQ(:maqam).Tonic("D4").LadderQ()
Chk("the ladder keeps the tonic the universe was given: Rast on D starts at 293.66 Hz",
    fabs(oTd.Rungs()[1][4] - 293.665) < 0.01)
oNo = StzSoundLadderQ(:westafrican, "")
? "   a rhythm universe: " + oNo.LastError()
Chk("a universe with no scale has no ladder, and says so", NOT oNo.IsUsable() and substr(oNo.LastError(), "degrees") > 0)

? ""
? "-- The listener's line --"
? "   Whether these pages READ as sheet music to a musician, and as a ladder to"
? "   one who learnt maqam from one, is not a number: UNPERCEIVED."

? ""
? "" + nPass + " passed, " + nFail + " failed"
if nFail > 0
	? "GUARD FAILED"
ok

# ---- helpers --------------------------------------------------------------

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func Mu10Of aM, cKind
	_a_ = []
	for _e_ in aM
		if _e_[1] = cKind  _a_ + _e_ ok
	next
	return _a_

func Mu10Col aL, nCol
	_s_ = ""
	for _e_ in aL  _s_ += "" + _e_[nCol] + " " next
	return _s_

func Mu10ListText aL
	_s_ = ""
	for _e_ in aL  _s_ += "" + _e_ + " " next
	return _s_

func Mu10Sum aL
	_n_ = 0
	for _e_ in aL  _n_ += _e_ next
	return _n_

func Mu10Count aL, nCol, cVal
	_n_ = 0
	for _e_ in aL
		if _e_[nCol] = cVal  _n_++ ok
	next
	return _n_

func Mu10Has aL, cPart
	for _c_ in aL
		if substr(_c_, cPart) > 0  return TRUE ok
	next
	return FALSE

func Mu10LastBarOf aSy, nSys
	_b_ = 0
	for _s_ in aSy
		_b_ += _s_[3]
		if _s_[2] = nSys  return _b_ ok
	next
	return _b_

# a half-flat is a flat (a vertical, then a loop) with a slanted stroke across:
# count the flats' loops drawn, as paths
func Mu10Accs cSvg
	_n_ = 0
	_k_ = 1
	while TRUE
		_p_ = substr(substr(cSvg, _k_, len(cSvg) - _k_ + 1), "stroke-width=" + char(34) + "1.5" + char(34))
		if _p_ = 0  exit ok
		_n_++
		_k_ += _p_ + 5
	end
	return _n_

func Mu10XmlBalanced cX
	_aSt_ = []
	_nEl_ = 0
	_nRoots_ = 0
	_k_ = 1
	_n_ = len(cX)
	while _k_ <= _n_
		if cX[_k_] != "<"
			_k_++
			loop
		ok
		_e_ = _k_
		while _e_ <= _n_ and cX[_e_] != ">"  _e_++ end
		_tag_ = substr(cX, _k_ + 1, _e_ - _k_ - 1)
		_k_ = _e_ + 1
		if len(_tag_) = 0  loop ok
		if _tag_[1] = "?" or _tag_[1] = "!"  loop ok
		_bClose_ = (_tag_[1] = "/")
		_bSelf_ = (_tag_[len(_tag_)] = "/")
		_name_ = ""
		_s0_ = 1
		if _bClose_  _s0_ = 2 ok
		for _j_ = _s0_ to len(_tag_)
			if _tag_[_j_] = " " or _tag_[_j_] = "/"  exit ok
			_name_ += _tag_[_j_]
		next
		if _bClose_
			if len(_aSt_) = 0  return [ FALSE, _nEl_ ] ok
			if _aSt_[len(_aSt_)] != _name_  return [ FALSE, _nEl_ ] ok
			del(_aSt_, len(_aSt_))
		else
			_nEl_++
			if len(_aSt_) = 0  _nRoots_++ ok
			if NOT _bSelf_  _aSt_ + _name_ ok
		ok
	end
	return [ len(_aSt_) = 0 and _nRoots_ = 1, _nEl_ ]
