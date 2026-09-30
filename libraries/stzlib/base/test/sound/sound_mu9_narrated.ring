# MU9 -- MusicXML read back. With MU8's MIDI and ABC, every format the
# library writes is now read:
#
#     MusicXML text --FromMusicXMLQ--> the same stzSoundScore
#
# Held to the same three things as MU8's readers:
#   1. the writer's own files come back as the score that wrote them;
#   2. a score written BY HAND for this guard, from the MusicXML 4.0 rules --
#      three parts, a transposing clarinet, voices by <backup>, a chord, a
#      triplet, repeats with two endings, a tie across a barline, percussion by
#      <midi-unpitched> -- is read as those rules say, checked against values
#      worked out by hand;
#   3. what a score cannot hold is COUNTED, and what cannot be read is REFUSED.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(3)

? "== MU9: MusicXML read back into one stzSoundScore =="
? ""

? "-- Scene 1: the writer's own MusicXML comes back --"
oRd = StzSoundNotationReaderQ()
oRast = StzSoundUniverseQ(:maqam).NoCycle(4).SonifyQ([ 1, 3, 2, 5, 4, 7, 6, 8, 3, 11 ])
oA = oRd.FromMusicXMLQ(StzSoundNotationQ(oRast).ToMusicXML("Rast"))
aCmp = Mu9Compare(oRast, oA)
? "   Rast: worst onset " + aCmp[2] + " beats, worst pitch " + aCmp[3] + " cents, title '" + oRd.Title() + "'"
Chk("every note, every length, the tempo, and the title", aCmp[1] and aCmp[2] = 0 and oA.TempoInBpm() = 96 and
    oRd.Title() = "Rast")
Chk("every pitch EXACT: <alter>-0.5</alter> is a quarter tone again, and the part name the oud",
    aCmp[3] < 0.001 and aCmp[5])
oT = StzSoundScoreQ().Tempo(90)
oT.On(:oud).NoteAt(0, "C4", 1).NoteAt(2, "D4", 10).NoteAt(12, "E4-50", 0.5)
oT.On(:flute).NoteAt(0, "G4", 2).NoteAt(0, "B4", 2).NoteAt(0, "D5", 2).NoteAt(4, "A4", 1.5)
cX = StzSoundNotationQ(oT).ToMusicXML("two voices")
oTB = oRd.FromMusicXMLQ(cX)
aCmp = Mu9Compare(oT, oTB)
Chk("two parts; a chord written with <chord/>; a ten-beat note written as tied pieces across two barlines comes back ONE note",
    aCmp[1] and aCmp[2] = 0 and aCmp[3] < 0.001 and aCmp[5])
Chk("and MusicXML -> score -> MusicXML is the same text, character for character",
    StzSoundNotationQ(oTB).ToMusicXML("two voices") = cX)

? ""
? "-- Scene 2: a score written BY HAND from the MusicXML rules --"
cH = Mu9HandScore()
? "   " + len(cH) + " characters: a DOCTYPE, a comment, three parts, five measures each"
oH = oRd.FromMusicXMLQ(cH)
? "   title: '" + oRd.Title() + "'"
aP1 = []
aP2 = []
aP3 = []
for e in oH.Events()
	if e[4] = "flute"
		aP1 + e
	but e[6] != ""
		aP3 + e
	else
		aP2 + e
	ok
next
for e in aP1  ? "     flute  beat " + e[1] + ", " + e[2] + " beats, midi " + Mu9Midi(e[3]) + ", velocity " + e[5] next
aWant1 = [ [0,1,73], [1,1,74], [1,1,78], [2,1/3,76], [7/3,1/3,78], [8/3,1/3,79],
           [3,1.5,81], [3,3,62], [5,1,83],
           [6,3,79],
           [9,1.5,81], [9,3,62], [11,1,83],
           [13,3,78], [16,2,76] ]
Chk("the title's &amp; is an ampersand again: " + oRd.Title(), oRd.Title() = "Guard score & its repeats")
Chk("'Traverso' names no instrument here, and its <midi-program>74</midi-program> (MusicXML counts from 1) is the flute",
    len(aP1) = 15)
Chk("the repeat PLAYED -- measures 1 2 3 2 4 5: ending 1 on the first pass, ending 2 on the second, " +
    "and each note where the rules put it", Mu9Want(aP1, aWant1))
Chk("<chord/> starts with the note before it; 8 of 24 divisions is a triplet's third of a beat",
    Mu9At(aP1, 3)[1] = 1 and fabs(Mu9At(aP1, 5)[2] - 1/3) < 0.000000001)
Chk("<backup> puts voice 2's D4 under voice 1, at the measure's start, on both passes",
    Mu9At(aP1, 8)[1] = 3 and Mu9Midi(Mu9At(aP1, 8)[3]) = 62 and Mu9At(aP1, 12)[1] = 9 and Mu9Midi(Mu9At(aP1, 12)[3]) = 62)
Chk("a <tie> across the barline from ending 2 into measure 5 is ONE note: F#5, three beats from 13",
    Mu9At(aP1, 14)[1] = 13 and Mu9At(aP1, 14)[2] = 3)
Chk("dynamics='100' is forte, MIDI 90; <sound dynamics='50'/> holds from measure 3 on",
    fabs(Mu9At(aP1, 1)[5] - 90 / 127) < 0.0001 and fabs(Mu9At(aP1, 10)[5] - 45 / 127) < 0.0001 and Mu9At(aP1, 2)[5] = 0.8)
Chk("the clarinet in Bb SOUNDS a tone below what it reads: written D5, E5 are C5 at 0 and D5 at 6",
    len(aP2) = 2 and Mu9Midi(Mu9At(aP2, 1)[3]) = 72 and Mu9At(aP2, 1)[1] = 0 and Mu9Midi(Mu9At(aP2, 2)[3]) = 74 and Mu9At(aP2, 2)[1] = 6)
Chk("an unpitched note on <midi-unpitched>39</midi-unpitched> (GM key 38) is a snare on the kit",
    len(aP3) = 1 and Mu9At(aP3, 1)[6] = "snare" and Mu9At(aP3, 1)[4] = "drumkit" and Mu9At(aP3, 1)[1] = 0)
Chk("<sound tempo='84'/> is the tempo", oH.TempoInBpm() = 84)
aL = oRd.Losses()
? "   losses:"
for c in aL  ? "     - " + c next
Chk("and everything a score cannot hold is COUNTED: the grace note, the lyric, the chord symbol, the trill, the tempo " +
    "change, the triangle, and a 'Clarinet in Bb' that names no instrument here",
    Mu9Has(aL, "grace") and Mu9Has(aL, "lyrics") and Mu9Has(aL, "harmony") and Mu9Has(aL, "ornaments") and
    Mu9Has(aL, "keeps the first (84") and Mu9Has(aL, "unpitched") and Mu9Has(aL, "'Clarinet in Bb'") and len(aL) = 7)

? ""
? "-- Scene 3: every format the library writes, it now reads -- in any order --"
oM1 = oRd.FromMidiBytesQ(StzSoundNotationQ(oTB).ToMidiBytes())
Chk("MusicXML -> score -> MIDI -> score -> MusicXML: the same text", StzSoundNotationQ(oM1).ToMusicXML("two voices") = cX)
cAbc = StzSoundNotationQ(oT).ToABC("two voices")
oA1 = oRd.FromMusicXMLQ(StzSoundNotationQ(oRd.FromAbcQ(cAbc)).ToMusicXML("two voices"))
Chk("ABC -> score -> MusicXML -> score -> ABC: the same text", StzSoundNotationQ(oA1).ToABC("two voices") = cAbc)
cHa = StzSoundNotationQ(oH).ToABC("by hand")
Chk("and the hand-written MusicXML becomes ABC, the repeat played out, and its C#5 written ^c",
    substr(cHa, "^c") > 0)

? ""
? "-- Scene 4: what is REFUSED, and why --"
q = char(34)
Chk("text that is no XML: " + Mu9Refused(oRd.FromMusicXMLQ("hello"), oRd), substr(oRd.LastError(), "no element") > 0)
Chk("XML that is not well-formed: " + Mu9Refused(oRd.FromMusicXMLQ("<score-partwise><part></score-partwise>"), oRd),
    substr(oRd.LastError(), "well-formed") > 0)
Chk("score-timewise: " + Mu9Refused(oRd.FromMusicXMLQ("<score-timewise/>"), oRd), substr(oRd.LastError(), "timewise") > 0)
Chk("a compressed .mxl: " + Mu9Refused(oRd.FromMusicXMLQ("PK" + char(3) + char(4) + "zipdata"), oRd),
    substr(oRd.LastError(), "unzip") > 0)
Chk("an XML that is not a score: " + Mu9Refused(oRd.FromMusicXMLQ("<html><body/></html>"), oRd),
    substr(oRd.LastError(), "<html>") > 0)
Chk("a duration before any divisions: " + Mu9Refused(oRd.FromMusicXMLQ("<score-partwise><part-list/><part id=" + q + "P1" + q +
    "><measure><note><pitch><step>C</step><octave>4</octave></pitch><duration>1</duration></note></measure></part>" +
    "</score-partwise>"), oRd), substr(oRd.LastError(), "divisions") > 0)

? ""
? "-- What MU9 does NOT do --"
? "   score-timewise and compressed .mxl are refused. Jumps (D.C., D.S., coda) are not"
? "   followed; glissandos are read as their first pitch; one tempo per score. The key"
? "   signature is not needed: MusicXML writes every alteration on its note."

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

func Mu9Cents nA, nB
	if nA <= 0 or nB <= 0  return 9999 ok
	return 1200 * log(nA / nB) / log(2)

func Mu9Midi nHz
	return floor((69 + 12 * log(nHz / 440) / log(2)) * 10000 + 0.5) / 10000

func Mu9Sorted oS
	_a_ = []
	for _e_ in oS.Events()
		_a_ + [ floor(_e_[1] * 480 + 0.5) * 100000 + floor(_e_[3] * 10 + 0.5), _e_ ]
	next
	_a_ = sort(_a_, 1)
	_r_ = []
	for _x_ in _a_  _r_ + _x_[2] next
	return _r_

# [ same count, worst onset/length, worst pitch (cents), -, instruments equal ]
func Mu9Compare oA, oB
	if NOT isObject(oB)  return [ FALSE, 99, 99, 0, FALSE ] ok
	_a_ = Mu9Sorted(oA)
	_b_ = Mu9Sorted(oB)
	if len(_a_) != len(_b_)  return [ FALSE, 99, 99, 0, FALSE ] ok
	_wt_ = 0  _wp_ = 0  _bi_ = TRUE
	for _k_ = 1 to len(_a_)
		_x_ = _a_[_k_]
		_y_ = _b_[_k_]
		_d_ = fabs(_x_[1] - _y_[1])
		if fabs(_x_[2] - _y_[2]) > _d_  _d_ = fabs(_x_[2] - _y_[2]) ok
		if _d_ > _wt_  _wt_ = _d_ ok
		if _x_[3] > 0
			_c_ = fabs(Mu9Cents(_x_[3], _y_[3]))
			if _c_ > _wp_  _wp_ = _c_ ok
		ok
		if _x_[4] != _y_[4]  _bi_ = FALSE ok
	next
	return [ TRUE, _wt_, _wp_, 0, _bi_ ]

# events against [ beat, beats, midi ] rows, in order
func Mu9Want aE, aW
	if len(aE) != len(aW)  return FALSE ok
	for _k_ = 1 to len(aW)
		if fabs(aE[_k_][1] - aW[_k_][1]) > 0.000000001  return FALSE ok
		if fabs(aE[_k_][2] - aW[_k_][2]) > 0.000000001  return FALSE ok
		if fabs(Mu9Midi(aE[_k_][3]) - aW[_k_][3]) > 0.0001  return FALSE ok
	next
	return TRUE

# the k-th event, or one that matches nothing when a wrong reading came back
# short -- so a failed count fails its checks instead of stopping the guard
func Mu9At aL, nK
	if nK <= len(aL)  return aL[nK] ok
	return [ -1, -1, 1, "", -1, "none", 0 ]

func Mu9Has aL, cPart
	for _c_ in aL
		if substr(_c_, cPart) > 0  return TRUE ok
	next
	return FALSE

func Mu9Refused oX, oRdr
	if isObject(oX)  return "NOT refused" ok
	return "refused -- " + oRdr.LastError()

# ---- a MusicXML score BY HAND. Each line is what MusicXML 4.0 prescribes;
# the expected values in Scene 2 were worked out from these lines, not read
# from the reader.

func Mu9HandScore
	q = char(34)
	_a_ = [
	"<?xml version=" + q + "1.0" + q + " encoding=" + q + "UTF-8" + q + " standalone=" + q + "no" + q + "?>",
	"<!DOCTYPE score-partwise PUBLIC " + q + "-//Recordare//DTD MusicXML 4.0 Partwise//EN" + q + " " + q +
	    "http://www.musicxml.org/dtds/partwise.dtd" + q + ">",
	"<score-partwise version=" + q + "4.0" + q + ">",
	"  <work><work-title>Guard score &amp; its repeats</work-title></work>",
	"  <!-- written by hand for the MU9 guard; nothing here came from the writer -->",
	"  <part-list>",
	"    <score-part id=" + q + "P1" + q + "><part-name>Traverso</part-name>",
	"      <midi-instrument id=" + q + "P1-I1" + q + "><midi-program>74</midi-program></midi-instrument></score-part>",
	"    <score-part id=" + q + "P2" + q + "><part-name>Clarinet in Bb</part-name></score-part>",
	"    <score-part id=" + q + "P3" + q + "><part-name>Percussion</part-name>",
	"      <score-instrument id=" + q + "P3-I38" + q + "><instrument-name>Snare</instrument-name></score-instrument>",
	"      <score-instrument id=" + q + "P3-I82" + q + "><instrument-name>Triangle</instrument-name></score-instrument>",
	"      <midi-instrument id=" + q + "P3-I38" + q + "><midi-channel>10</midi-channel><midi-unpitched>39</midi-unpitched></midi-instrument>",
	"      <midi-instrument id=" + q + "P3-I82" + q + "><midi-channel>10</midi-channel><midi-unpitched>82</midi-unpitched></midi-instrument>",
	"    </score-part>",
	"  </part-list>",
	# P1: 3/4, 24 divisions a quarter
	"  <part id=" + q + "P1" + q + ">",
	"    <measure number=" + q + "1" + q + ">",
	"      <attributes><divisions>24</divisions><key><fifths>2</fifths></key><time><beats>3</beats><beat-type>4</beat-type></time></attributes>",
	"      <direction placement=" + q + "above" + q + "><direction-type><metronome><beat-unit>quarter</beat-unit><per-minute>84</per-minute></metronome></direction-type><sound tempo=" + q + "84" + q + "/></direction>",
	"      <note dynamics=" + q + "100" + q + "><pitch><step>C</step><alter>1</alter><octave>5</octave></pitch><duration>24</duration><voice>1</voice><type>quarter</type></note>",
	"      <note><pitch><step>D</step><octave>5</octave></pitch><duration>24</duration><voice>1</voice><type>quarter</type></note>",
	"      <note><chord/><pitch><step>F</step><alter>1</alter><octave>5</octave></pitch><duration>24</duration><voice>1</voice><type>quarter</type></note>",
	"      <note><pitch><step>E</step><octave>5</octave></pitch><duration>8</duration><voice>1</voice><type>eighth</type><time-modification><actual-notes>3</actual-notes><normal-notes>2</normal-notes></time-modification></note>",
	"      <note><pitch><step>F</step><alter>1</alter><octave>5</octave></pitch><duration>8</duration><voice>1</voice><type>eighth</type></note>",
	"      <note><pitch><step>G</step><octave>5</octave></pitch><duration>8</duration><voice>1</voice><type>eighth</type></note>",
	"    </measure>",
	"    <measure number=" + q + "2" + q + ">",
	"      <barline location=" + q + "left" + q + "><bar-style>heavy-light</bar-style><repeat direction=" + q + "forward" + q + "/></barline>",
	"      <note><pitch><step>A</step><octave>5</octave></pitch><duration>36</duration><voice>1</voice><type>quarter</type><dot/></note>",
	"      <note><rest/><duration>12</duration><voice>1</voice><type>eighth</type></note>",
	"      <note><grace/><pitch><step>C</step><octave>6</octave></pitch><voice>1</voice><type>16th</type></note>",
	"      <note><pitch><step>B</step><octave>5</octave></pitch><duration>24</duration><voice>1</voice><type>quarter</type><lyric><text>la</text></lyric></note>",
	"      <backup><duration>72</duration></backup>",
	"      <note><pitch><step>D</step><octave>4</octave></pitch><duration>72</duration><voice>2</voice><type>half</type><dot/></note>",
	"    </measure>",
	"    <measure number=" + q + "3" + q + ">",
	"      <barline location=" + q + "left" + q + "><ending number=" + q + "1" + q + " type=" + q + "start" + q + "/></barline>",
	"      <direction><direction-type><dynamics><p/></dynamics></direction-type><sound dynamics=" + q + "50" + q + "/></direction>",
	"      <note><pitch><step>G</step><octave>5</octave></pitch><duration>72</duration><voice>1</voice><type>half</type><dot/></note>",
	"      <barline location=" + q + "right" + q + "><bar-style>light-heavy</bar-style><ending number=" + q + "1" + q + " type=" + q + "stop" + q + "/><repeat direction=" + q + "backward" + q + "/></barline>",
	"    </measure>",
	"    <measure number=" + q + "4" + q + ">",
	"      <barline location=" + q + "left" + q + "><ending number=" + q + "2" + q + " type=" + q + "start" + q + "/></barline>",
	"      <note><rest/><duration>24</duration><voice>1</voice><type>quarter</type></note>",
	"      <note><pitch><step>F</step><alter>1</alter><octave>5</octave></pitch><duration>48</duration><tie type=" + q + "start" + q + "/><voice>1</voice><type>half</type><notations><tied type=" + q + "start" + q + "/></notations></note>",
	"      <barline location=" + q + "right" + q + "><ending number=" + q + "2" + q + " type=" + q + "discontinue" + q + "/></barline>",
	"    </measure>",
	"    <measure number=" + q + "5" + q + ">",
	"      <harmony><root><root-step>D</root-step></root><kind>major</kind></harmony>",
	"      <note><pitch><step>F</step><alter>1</alter><octave>5</octave></pitch><duration>24</duration><tie type=" + q + "stop" + q + "/><voice>1</voice><type>quarter</type><notations><tied type=" + q + "stop" + q + "/></notations></note>",
	"      <direction><direction-type><words>rit.</words></direction-type><sound tempo=" + q + "60" + q + "/></direction>",
	"      <note><pitch><step>E</step><octave>5</octave></pitch><duration>48</duration><voice>1</voice><type>half</type><notations><ornaments><trill-mark/></ornaments></notations></note>",
	"      <barline location=" + q + "right" + q + "><bar-style>light-heavy</bar-style></barline>",
	"    </measure>",
	"  </part>",
	# P2: a clarinet in Bb, written a tone above what sounds; 2 divisions a quarter
	"  <part id=" + q + "P2" + q + ">",
	"    <measure number=" + q + "1" + q + "><attributes><divisions>2</divisions><transpose><diatonic>-1</diatonic><chromatic>-2</chromatic></transpose></attributes>",
	"      <note><pitch><step>D</step><octave>5</octave></pitch><duration>6</duration><voice>1</voice><type>half</type><dot/></note></measure>",
	"    <measure number=" + q + "2" + q + "><forward><duration>6</duration></forward></measure>",
	"    <measure number=" + q + "3" + q + "><note><pitch><step>E</step><octave>5</octave></pitch><duration>6</duration><voice>1</voice><type>half</type><dot/></note></measure>",
	"    <measure number=" + q + "4" + q + "><note><rest/><duration>6</duration></note></measure>",
	"    <measure number=" + q + "5" + q + "><note><rest/><duration>6</duration></note></measure>",
	"  </part>",
	# P3: percussion, 1 division a quarter
	"  <part id=" + q + "P3" + q + ">",
	"    <measure number=" + q + "1" + q + "><attributes><divisions>1</divisions></attributes>",
	"      <note><unpitched><display-step>C</display-step><display-octave>5</display-octave></unpitched><duration>1</duration><instrument id=" + q + "P3-I38" + q + "/><voice>1</voice><type>quarter</type></note>",
	"      <note><unpitched><display-step>E</display-step><display-octave>5</display-octave></unpitched><duration>1</duration><instrument id=" + q + "P3-I82" + q + "/><voice>1</voice><type>quarter</type></note>",
	"      <note><rest/><duration>1</duration></note></measure>",
	"    <measure number=" + q + "2" + q + "><note><rest measure=" + q + "yes" + q + "/><duration>3</duration></note></measure>",
	"    <measure number=" + q + "3" + q + "><note><rest measure=" + q + "yes" + q + "/><duration>3</duration></note></measure>",
	"    <measure number=" + q + "4" + q + "><note><rest measure=" + q + "yes" + q + "/><duration>3</duration></note></measure>",
	"    <measure number=" + q + "5" + q + "><note><rest measure=" + q + "yes" + q + "/><duration>3</duration></note></measure>",
	"  </part>",
	"</score-partwise>" ]
	_s_ = ""
	for _l_ in _a_  _s_ += _l_ + nl next
	return _s_
