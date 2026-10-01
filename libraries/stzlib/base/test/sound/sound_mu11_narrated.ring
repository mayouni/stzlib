# MU11 -- the staff gets its KEY SIGNATURE, and the drums their own STAFF.
#
#     StzSoundStaffQ(oScore)                          # the key read from the music
#     StzSoundStaffQ(oScore).SetKey("Bb")             # or set
#     StzSoundStaffQ(oScore).SetKeyOfMode(:maqam, :hijaz)   # or taken from a mode
#
# Held, as MU10 was, to the rules of notation through the MODEL the page is
# drawn from: which letters the key carries and where each sits, how every
# pitch is SPELLED in that key, which notes still need an accidental; and, on
# the percussion staves, where each stroke sits and with which head.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(3)

? "== MU11: the key signature, and the percussion staff =="
? ""

? "-- Scene 1: a key read from the music -- the Western circle of fifths --"
oD = StzSoundScoreOfQ("d4 e4 f#4 g4 a4 b4 c#5 d5")
oSD = StzSoundStaffQ(oD)
oSD.ToSVG("")
aK = Mu11Of(oSD.Model(), "keysig")
? "   D E F# G A B C# D: " + oSD.KeyName() + " -- " + Mu11Key(oSD.Key())
Chk("a D major scale is read as D major: F sharp and C sharp in the key, in that order", Mu11Key(oSD.Key()) = "F+1 C+1 ")
Chk("and drawn where the tradition puts them: F# on the top line, C# in the third space", Mu11Col(aK, 7) = "8 5 ")
Chk("so no note in it needs an accidental", len(Mu11Of(oSD.Model(), "acc")) = 0)
oDb = StzSoundScoreOfQ("d3 e3 f#3 g3 a3 b3 c#4 d4").On(:piano)
oSDb = StzSoundStaffQ(oDb)
oSDb.ToSVG("")
Chk("in the bass clef the same key sits two octaves lower: F# on the fourth line, C# in the second space",
    Mu11Col(Mu11Of(oSDb.Model(), "keysig"), 7) = "6 3 ")
oF = StzSoundScoreOfQ("f4 g4 a4 bb4 c5 bb4 a4 b4 c5")
oSF = StzSoundStaffQ(oF)
oSF.ToSVG("")
aHF = Mu11Of(oSF.Model(), "head")
aAF = Mu11Of(oSF.Model(), "acc")
? "   F G A Bb C Bb A B C: " + oSF.KeyName() + "; the fourth note is spelled " + aHF[4][8] + " " + aHF[4][9]
Chk("a melody in F is read as F major, and THE KEY SPELLS: the note between A and B is B flat, not A sharp",
    oSF.KeyName() = "F major (1 flat)" and aHF[4][8] = "B4" and aHF[4][9] = -1)
Chk("only the note that leaves the key is marked: the B natural, with a natural sign", len(aAF) = 1 and aAF[1][7] = 0)

? ""
? "-- Scene 2: a key set by name, by fifths, or not at all --"
oM = StzSoundScoreOfQ("c5 d5 e5 f5")
Chk("SetKey('Bb') is two flats, B then E", Mu11Key(Mu11KeyOf(oM, "Bb")) = "B-1 E-1 ")
Chk("SetKey('F#m') is three sharps: F# minor is A major's signature", Mu11Key(Mu11KeyOf(oM, "F#m")) = "F+1 C+1 G+1 ")
Chk("SetKey('Ddor') is no sharps or flats: D dorian is C major's", Mu11Key(Mu11KeyOf(oM, "Ddor")) = "")
Chk("SetKey(-3) is three flats", Mu11Key(Mu11KeyOf(oM, -3)) = "B-1 E-1 A-1 ")
Chk("SetKey('none') writes no signature, and every alteration on its note", Mu11Key(Mu11KeyOf(oD, "none")) = "")
oBad = StzSoundStaffQ(oM).SetKey("H#")
Chk("and a key that is no key is refused: " + oBad.LastError(), substr(oBad.LastError(), "not a key") > 0)
oAs = StzSoundScoreQ().On(:flute).NoteAt(0, 466.1638, 1)
oSAs = StzSoundStaffQ(oAs).SetKey("Bb")
oSAs.ToSVG("")
aHA = Mu11Of(oSAs.Model(), "head")
Chk("in B flat, 466 Hz is B flat with no accidental -- the key decides the letter, not the frequency",
    aHA[1][8] = "B4" and aHA[1][9] = -1 and len(Mu11Of(oSAs.Model(), "acc")) = 0)

# where ONLY the key can decide: in F# major the key sharpens E, so the pitch
# a piano calls F is written E sharp -- the key's own letter -- with no sign
oEs = StzSoundScoreQ().On(:flute).NoteAt(0, 349.2282, 1)
oSEs = StzSoundStaffQ(oEs).SetKey("F#")
oSEs.ToSVG("")
aHE = Mu11Of(oSEs.Model(), "head")
Chk("in F# major, the pitch of F is written E sharp, the letter the key gives it, with no accidental",
    aHE[1][8] = "E4" and aHE[1][9] = 1 and len(Mu11Of(oSEs.Model(), "acc")) = 0)

? ""
? "-- Scene 3: the maqam key -- quarter tones IN the signature, as Arabic notation writes them --"
oRst = StzSoundUniverseQ(:maqam).NoCycle(4).SonifyQ([ 1, 3, 2, 5, 4, 7, 6, 8, 3, 11 ])
oSR = StzSoundStaffQ(oRst)
oSR.ToSVG("")
? "   the Rast series: " + oSR.KeyName()
Chk("Rast read from the music: B half-flat and E half-flat in the key", Mu11Key(oSR.Key()) = "B-0.500 E-0.500 ")
Chk("so its half-flat third and seventh need no accidental at all", len(Mu11Of(oSR.Model(), "acc")) = 0)
Chk("Hijaz on D, from its declaration: B flat, E flat -- and F sharp", Mu11Key(Mu11ModeKey(oD, :maqam, :hijaz)) = "B-1 E-1 F+1 ")
Chk("Tunisian Sika, from its declaration: B half-flat, E half-flat", Mu11Key(Mu11ModeKey(oD, :tunisian, :sika)) = "B-0.500 E-0.500 ")
Chk("Rasd al-Dhil, from its declaration: the half-flats, then Snoussi's F half-SHARP among the sharps",
    Mu11Key(Mu11ModeKey(oD, :tunisian, :rasdaldhil)) = "B-0.500 E-0.500 F+0.500 ")
oSl = StzSoundStaffQ(oD).SetKeyOfMode(:gamelan, :slendro)
Chk("a mode of five degrees has no key signature, and says so: " + oSl.LastError(), substr(oSl.LastError(), "seven degrees") > 0)
oLong = StzSoundScoreQ().On(:flute)
for k = 0 to 63  oLong.NoteAt(k, 293.6648 * pow(2, ((k % 7) * 2 - (k % 7 > 2)) / 12), 1) next
oSLg = StzSoundStaffQ(oLong).SetKey("D")
oSLg.ToSVG("")
Chk("the signature is repeated at the head of every system (" + oSLg.Systems() + " systems)",
    len(Mu11Of(oSLg.Model(), "keysig")) = 2 * oSLg.Systems() and oSLg.Systems() > 1)

? ""
? "-- Scene 4: the percussion staff --"
oP = StzSoundScoreQ().Tempo(96)
oP.On(:oud).NoteAt(0, "C4", 1).NoteAt(1, "D4", 1).NoteAt(2, "E4-50", 2)
oP.On(:darbouka).StrokeAt(0, :dum, 1).StrokeAt(1, :tak, 0.5).StrokeAt(1.5, :ka, 0.5).StrokeAt(2, :dum, 1).StrokeAt(3, :tak, 1)
oP.On(:drumkit).StrokeAt(0, :kick, 1).StrokeAt(0, :hihat, 0.5).StrokeAt(0.5, :hihat, 0.5).StrokeAt(1, :snare, 1)
oP.StrokeAt(2, :kick, 1).StrokeAt(3, :snare, 1)
oSP = StzSoundStaffQ(oP)
cSP = oSP.ToSVG("")
aMP = oSP.Model()
? "   staves: " + oSP.Clefs()[1][2] + ", " + oSP.Clefs()[2][2] + ", " + oSP.Clefs()[3][2]
Chk("the drums get staves of their own, UNDER the pitched one", oSP.Clefs()[1][2] = "treble" and
    oSP.Clefs()[2][1] = "darbouka" and oSP.Clefs()[2][2] = "perc1" and oSP.Clefs()[3][1] = "drumkit" and oSP.Clefs()[3][2] = "perc5")
aLn = Mu11Of(aMP, "lines")
Chk("a hand drum's staff is ONE line, the kit's five", Mu11Col(aLn, 4) = "5 1 5 ")
aSt2 = Mu11Staff(Mu11Of(aMP, "stroke"), 2)
? "   darbouka: " + Mu11Col(aSt2, 6) + "at steps " + Mu11Col(aSt2, 7)
Chk("on the darbouka's line: dum UNDER it, tak OVER it, ka over it with an x head",
    Mu11Col(aSt2, 6) = "dum tak ka dum tak " and Mu11Col(aSt2, 7) = "3 5 5 3 5 " and Mu11Col(aSt2, 8) = "0 0 1 0 0 ")
Chk("with the syllables a darbouka player reads beneath: D T K D T", Mu11Count(cSP, ">D</text>") = 2 and
    Mu11Count(cSP, ">T</text>") = 2 and Mu11Count(cSP, ">K</text>") = 1)
aSt3 = Mu11Staff(Mu11Of(aMP, "stroke"), 3)
? "   kit: " + Mu11Col(aSt3, 6) + "at steps " + Mu11Col(aSt3, 7)
Chk("on the kit: the kick in the bottom space, the snare in the third, the hihat above the staff as an x",
    Mu11Has(aSt3, "kick", 1, FALSE) and Mu11Has(aSt3, "snare", 5, FALSE) and Mu11Has(aSt3, "hihat", 9, TRUE))
aH3 = Mu11Staff(Mu11Of(aMP, "head"), 3)
Chk("a kick struck with a hihat is ONE chord: two heads on one stem", aH3[1][5] = aH3[2][5] and aH3[1][12] = aH3[2][12])
bUp = TRUE
for h in Mu11Of(aMP, "head")
	if h[2] > 1 and h[11] != "up"  bUp = FALSE ok
next
Chk("every stem on the drum staves points up", bUp)
Chk("tak and ka, two eighths on one beat, are beamed like any eighths", len(Mu11Staff(Mu11Of(aMP, "beam"), 2)) = 1)
Chk("the key signature is on the oud's staff only, never on a drum's",
    len(Mu11Of(aMP, "keysig")) = 1 and Mu11Of(aMP, "keysig")[1][2] = 1)
Chk("and nothing is lost: strokes are no longer a loss", len(oSP.Losses()) = 0)
oU = StzSoundUniverseQ(:tunisian)
oPf = oU.PerformQ("1 2 3 4 5 4 3 2", 1)
oSPf = StzSoundStaffQ(oPf)
oSPf.ToSVG("")
? "   a Tunisian performance, btayhi on the darbouka: staves " + len(oSPf.Clefs()) + ", key " + oSPf.KeyName()
Chk("a universe's performance draws its melody on a staff and its cycle on the drum's line",
    len(oSPf.Clefs()) = 2 and oSPf.Clefs()[2][2] = "perc1" and len(Mu11Of(oSPf.Model(), "stroke")) > 0)
aX = Mu11XmlBalanced(cSP)
Chk("the page is well-formed SVG (" + aX[2] + " elements)", aX[1])

? ""
? "-- The listener's line --"
? "   Whether the drum line reads as a darbouka player writes btayhi, and the maqam"
? "   signature as an Arab musician expects it, is not a number: UNPERCEIVED."

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

func Mu11Of aM, cKind
	_a_ = []
	for _e_ in aM
		if _e_[1] = cKind  _a_ + _e_ ok
	next
	return _a_

func Mu11Staff aL, nStaff
	_a_ = []
	for _e_ in aL
		if _e_[2] = nStaff  _a_ + _e_ ok
	next
	return _a_

func Mu11Col aL, nCol
	_s_ = ""
	for _e_ in aL  _s_ += "" + _e_[nCol] + " " next
	return _s_

# a signature as text: "F+1 C+1 ", "B-0.500 E-0.500 "
func Mu11Key aK
	_s_ = ""
	for _k_ in aK
		_a_ = "" + _k_[2]
		if _k_[2] > 0  _a_ = "+" + _a_ ok
		_s_ += _k_[1] + _a_ + " "
	next
	return _s_

func Mu11KeyOf oScore, pKey
	_o_ = StzSoundStaffQ(oScore)
	_o_.SetKey(pKey)
	_o_.ToSVG("")
	return _o_.Key()

func Mu11ModeKey oScore, pU, pM
	_o_ = StzSoundStaffQ(oScore)
	_o_.SetKeyOfMode(pU, pM)
	_o_.ToSVG("")
	return _o_.Key()

func Mu11Has aL, cStroke, nStep, bX
	for _e_ in aL
		if _e_[6] = cStroke and _e_[7] = nStep and _e_[8] = bX  return TRUE ok
	next
	return FALSE

func Mu11Count cS, cPat
	_n_ = 0
	_k_ = 1
	while TRUE
		_p_ = substr(substr(cS, _k_, len(cS) - _k_ + 1), cPat)
		if _p_ = 0  exit ok
		_n_++
		_k_ += _p_ + len(cPat) - 1
	end
	return _n_

func Mu11XmlBalanced cX
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
