# MU12 -- KEY CHANGES inside a piece, and the drum kit in TWO VOICES.
#
#     StzSoundStaffQ(oScore).KeyChangeAt(16, "D")              # at a barline
#     StzSoundStaffQ(oScore).KeyChangeOfModeAt(16, :maqam, :hijaz)
#     StzSoundStaffQ(oScore)                # or found in the music, by sections
#
# Held, as MU10 and MU11 were, to the rules of notation through the MODEL the
# page is drawn from: where each key begins, what is cancelled, what each bar
# remembers and spells in; and on the kit, which limb plays in which voice.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(3)

? "== MU12: key changes, and the two-voice kit =="
? ""

cTune = "c4 d4 e4 f4 g4 a4 b4 c5 c5 b4 a4 g4 f4 e4 d4 c4 " +
        "d4 e4 f#4 g4 a4 b4 c#5 d5 d5 c#5 b4 a4 g4 f#4 e4 d4 " +
        "c4 d4 e4 f4 g4 a4 b4 c5"

? "-- Scene 1: a key change asked for, at a barline --"
oT = StzSoundScoreOfQ(cTune)
oW = StzSoundStaffQ(oT).SetWidth(2600).KeyChangeAt(16, "D").KeyChangeAt(32, "C")
oW.ToSVG("")
aM = oW.Model()
? "   C for four bars, D for four, C for two -- on one long system:"
for c in oW.KeyChanges()  ? "     bar " + c[1] + ": " + c[2] next
Chk("the key changes at bar 5 to D major, and at bar 9 back to C", len(oW.KeyChanges()) = 2 and
    oW.KeyChanges()[1][1] = 5 and oW.KeyChanges()[1][2] = "D major (2 sharps)" and oW.KeyChanges()[2][1] = 9)
aKc = Mu12Of(aM, "keychange")
Chk("each change is drawn where it happens, inside the system", oW.Systems() = 1 and Mu12Col(aKc, 4) = "5 9 ")
Chk("a DOUBLE barline closes the bar before each change", Mu12Col(Mu12Of(aM, "dblbar"), 4) = "4 8 ")
aN = Mu12Of(aM, "keychangenat")
Chk("going back to C, naturals cancel the F sharp and the C sharp, in the order they stood",
    Mu12Col(aN, 4) = "F C " and Mu12Col(aKc, 5) = "0 2 ")
aKs = Mu12Of(aM, "keysig")
Chk("and the new key is drawn after them: F# and C# at bar 5", Mu12KeyAt(aKs, 5) = "F+1 C+1 ")
Chk("each bar spells in, and remembers, the key in force there: not one accidental in ten bars",
    len(Mu12Of(aM, "acc")) = 0)
aHd = Mu12Of(aM, "head")
Chk("so the note between F and G is F sharp in the D bars and F natural in the C ones",
    aHd[19][8] = "F4" and aHd[19][9] = 1 and aHd[4][9] = 0 and aHd[36][9] = 0)
# where only the bar's key decides the letter: C sharpens what it must, so after
# a change to F the pitch between A and B must be spelled B FLAT, as F spells it
oCF = StzSoundScoreOfQ("c4 d4 e4 f4 g4 a4 b4 c5 c5 b4 a4 g4 f4 e4 d4 c4 f4 g4 a4 bb4 c5 bb4 a4 g4")
oSCF = StzSoundStaffQ(oCF).KeyChangeAt(16, "F")
oSCF.ToSVG("")
aHcf = Mu12Of(oSCF.Model(), "head")
Chk("after a change to F, the note between A and B is spelled in F: B flat, not the A sharp C would write",
    aHcf[20][8] = "B4" and aHcf[20][9] = -1 and len(Mu12Of(oSCF.Model(), "acc")) = 0)
oOff = StzSoundStaffQ(oT).KeyChangeAt(18, "D")
oOff.ToSVG("")
Chk("a change asked for inside a bar is written at the next barline, and counted: " + Mu12First(oOff.Losses()),
    oOff.KeyChanges()[1][1] = 6 and Mu12Has(oOff.Losses(), "next barline"))
oBad = StzSoundStaffQ(oT).KeyChangeAt(16, "Hx")
Chk("a change to a key that is no key is refused", substr(oBad.LastError(), "not a key") > 0)
oHz = StzSoundStaffQ(oT).KeyChangeOfModeAt(16, :maqam, :hijaz)
oHz.ToSVG("")
Chk("a change into a declared MODE takes its signature: Hijaz's B flat, E flat, F sharp at bar 5",
    Mu12KeyAt(Mu12Of(oHz.Model(), "keysig"), 5) = "B-1 E-1 F+1 " and substr(oHz.KeyChanges()[1][2], "hijaz") > 0)

aSer = [ 1, 3, 2, 5, 4, 7, 6, 8, 3, 11, 9, 8, 6, 5, 3, 1 ]
oRa = StzSoundUniverseQ(:maqam).NoCycle(4).SonifyQ(aSer)
oRa.Then(StzSoundUniverseQ(:maqam).Mode(:hijaz).NoCycle(4).SonifyQ(aSer))
oSRH = StzSoundStaffQ(oRa).KeyChangeOfModeAt(16, :maqam, :hijaz)
oSRH.ToSVG("")
? "   Rast, then Hijaz from bar 5: " + oSRH.KeyName()
Chk("the opening key is read from the bars BEFORE the change: Rast's C with B and E half-flat, not a key bent by Hijaz's F sharps",
    left(oSRH.KeyName(), 7) = "C major" and substr(oSRH.KeyName(), "B half-flat, E half-flat") > 0)

? ""
? "-- Scene 2: at the head of a system, and the courtesy key before it --"
oNw = StzSoundStaffQ(oT).SetWidth(400).KeyChangeAt(16, "D").KeyChangeAt(32, "C")
oNw.ToSVG("")
aMn = Mu12Of(oNw.Model(), "system")
nSysOf5 = Mu12SystemOf(aMn, 5)
? "   a narrow page: " + oNw.Systems() + " systems; bar 5 begins system " + nSysOf5
Chk("when a change begins a system, the system's head carries the new key",
    Mu12KeyAt(Mu12Of(oNw.Model(), "keysig"), 5) = "F+1 C+1 " and Mu12FirstBar(aMn, nSysOf5) = 5)
aCt = Mu12Of(oNw.Model(), "keycourtesy")
Chk("and the system before it ends with a COURTESY key, after its last barline", Mu12Col(aCt, 4) = "5 9 ")

? ""
? "-- Scene 3: key changes found in the music --"
oE = StzSoundScoreOfQ("c4 d4 e4 f4 g4 a4 b4 c5 c5 b4 a4 g4 f4 e4 d4 c4 " +
                      "e4 f#4 g#4 a4 b4 c#5 d#5 e5 e5 d#5 c#5 b4 a4 g#4 f#4 e4")
oSE = StzSoundStaffQ(oE)
oSE.ToSVG("")
? "   four bars of C, four of E: " + oSE.KeyName() + " -> " + Mu12ChangesText(oSE.KeyChanges())
Chk("a passage in C then one in E is read as C major, CHANGING to E major at the bar E begins",
    oSE.KeyName() = "C major (no sharps or flats)" and len(oSE.KeyChanges()) = 1 and oSE.KeyChanges()[1][1] = 5 and
    oSE.KeyChanges()[1][2] = "E major (4 sharps)")
oF = StzSoundScoreOfQ("c4 d4 e4 f4 g4 a4 b4 c5 c5 b4 a4 f#4 g4 e4 d4 c4 " +
                      "c4 d4 e4 f4 g4 a4 b4 c5 c5 b4 a4 g4 f4 e4 d4 c4")
oSF = StzSoundStaffQ(oF)
oSF.ToSVG("")
Chk("ONE F sharp in eight bars of C changes nothing: a change must save more than it costs",
    len(oSF.KeyChanges()) = 0 and len(Mu12Of(oSF.Model(), "acc")) >= 1)
oSF2 = StzSoundStaffQ(oE).SetKeyChanges(FALSE)
oSF2.ToSVG("")
Chk("and SetKeyChanges(FALSE) keeps one key for the whole piece", len(oSF2.KeyChanges()) = 0)

? ""
? "-- Scene 4: the drum kit in two voices --"
oKt = StzSoundScoreQ().Tempo(100).On(:drumkit)
for b = 0 to 7
	if b % 2 = 0  oKt.StrokeAt(b, :kick, 1) ok
	if b % 2 = 1  oKt.StrokeAt(b, :snare, 1) ok
	oKt.StrokeAt(b, :hihat, 0.5).StrokeAt(b + 0.5, :hihat, 0.5)
next
oKt.StrokeAt(6.5, :kick, 0.5)
oSK = StzSoundStaffQ(oKt)
oSK.ToSVG("")
aMk = oSK.Model()
aSt = Mu12Of(aMk, "stroke")
nHandsUp = 0
nFeetDown = 0
for x in aSt
	if (x[6] = "hihat" or x[6] = "snare") and x[9] = "up"  nHandsUp++ ok
	if x[6] = "kick" and x[9] = "down"  nFeetDown++ ok
next
? "   " + len(oSK.Clefs()) + " staff; hands in the upper voice: " + nHandsUp + " strokes; feet in the lower: " + nFeetDown
Chk("the kit is ONE staff, with the hands -- hihat and snare -- in the upper voice and the kick in the lower",
    len(oSK.Clefs()) = 1 and nHandsUp = 20 and nFeetDown = 5 and len(aSt) = 25)
bDirs = TRUE
for h in Mu12Of(aMk, "head")
	if h[8] = "kick" and h[11] != "down"  bDirs = FALSE ok
	if h[8] != "kick" and h[11] != "up"  bDirs = FALSE ok
next
Chk("the hands' stems go UP and the feet's go DOWN, whatever the heads' height", bDirs)
aRk = Mu12Of(aMk, "rest")
Chk("each voice keeps its own rhythm: the feet rest on beats 2 and 4 -- four quarter rests, all in the lower voice",
    len(aRk) = 4 and Mu12Col(aRk, 8) = "down down down down " and Mu12Col(aRk, 6) = "4 4 4 4 ")
aBk = Mu12Of(aMk, "beam")
Chk("the hands' eighths are beamed above; the two kicks in beat 7 are beamed BELOW",
    Mu12Count(aBk, 7, "up") = 8 and Mu12Count(aBk, 7, "down") = 1)
oH = StzSoundScoreQ().On(:drumkit).StrokeAt(0, :hihat, 0.5).StrokeAt(0.5, :hihat, 0.5).StrokeAt(1, :snare, 1)
oSH = StzSoundStaffQ(oH)
oSH.ToSVG("")
Chk("a kit played by the hands alone stays one voice", Mu12Col(Mu12Of(oSH.Model(), "stroke"), 9) = "  " + " ")
cK = oSK.ToSVG("")
aX = Mu12XmlBalanced(cK)
Chk("the page is well-formed SVG (" + aX[2] + " elements)", aX[1])

? ""
? "-- The listener's line --"
? "   Whether a drummer reads the kit as written, and a modulation as an"
? "   engraver would mark it, is not a number: UNPERCEIVED."

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

func Mu12Of aM, cKind
	_a_ = []
	for _e_ in aM
		if _e_[1] = cKind  _a_ + _e_ ok
	next
	return _a_

func Mu12Col aL, nCol
	_s_ = ""
	for _e_ in aL  _s_ += "" + _e_[nCol] + " " next
	return _s_

func Mu12Count aL, nCol, cVal
	_n_ = 0
	for _e_ in aL
		if _e_[nCol] = cVal  _n_++ ok
	next
	return _n_

# the signature drawn at bar n: "F+1 C+1 "
func Mu12KeyAt aKs, nBar
	_s_ = ""
	for _k_ in aKs
		if _k_[8] = nBar
			_a_ = "" + _k_[5]
			if _k_[5] > 0  _a_ = "+" + _a_ ok
			_s_ += _k_[4] + _a_ + " "
		ok
	next
	return _s_

func Mu12SystemOf aSy, nBar
	_b_ = 0
	for _s_ in aSy
		if nBar > _b_ and nBar <= _b_ + _s_[3]  return _s_[2] ok
		_b_ += _s_[3]
	next
	return 0

func Mu12FirstBar aSy, nSys
	_b_ = 1
	for _s_ in aSy
		if _s_[2] = nSys  return _b_ ok
		_b_ += _s_[3]
	next
	return 0

func Mu12ChangesText aC
	if len(aC) = 0  return "no change" ok
	_s_ = ""
	for _c_ in aC
		if _s_ != ""  _s_ += "; " ok
		_s_ += "bar " + _c_[1] + ": " + _c_[2]
	next
	return _s_

func Mu12Has aL, cPart
	for _c_ in aL
		if substr(_c_, cPart) > 0  return TRUE ok
	next
	return FALSE

func Mu12First aL
	if len(aL) = 0  return "(none)" ok
	return aL[1]

func Mu12XmlBalanced cX
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
