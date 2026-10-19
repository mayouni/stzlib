load "../../stzBase.ring"
load "../_narrated.ring"

# stzStringSplitter -- the four rows of the register (DEFECTS.md): Partition, PartitionAfter,
# RPartition and RPartitionAfter.
#
# Before: each returned ONE piece in a one-item list (key=value=more at = gave only key, value=more,
# key=value and more). The register blamed a NUL-separated engine buffer cut at its first NUL; the
# engine's partition entries in fact hand back a single piece per call (the piece before, the piece
# after), and the library used each answer as if it were the whole cut. The cut is now rebuilt from
# the two pieces, so the four methods answer:
#   Partition        [ before, separator, after ] at the FIRST occurrence
#   PartitionAfter   [ before + separator, after ] at the first occurrence
#   RPartition       [ before, separator, after ] at the LAST occurrence
#   RPartitionAfter  [ before + separator, after ] at the last occurrence
# and, when the separator is absent (or empty, or the text is empty), the shapes of
# stzString.Partition / RPartition: [ text, "", "" ], [ "", "", text ], [ text, "" ], [ "", text ].
#
# Three independent references: the literal answers of Python's str.partition / rpartition (generated
# once, pinned below), a byte-level model written in this file (substr find, then a backward scan),
# and stzString.Partition / RPartition where those are themselves right. Hebrew, Arabic, accented and
# emoji texts are built from char codes and never printed. Run from inside test/string.

# Ring is case-insensitive about names: cSmallE and cBigE are two names, e and E would be one.
cHeb1 = char(215) + char(169) + char(215) + char(156) + char(215) + char(149) + char(215) + char(157)
cHeb2 = char(215) + char(160) + char(215) + char(144) + char(215) + char(157)
cArM = char(217) + char(133)
cSmallE = char(195) + char(169)
cBigE = char(195) + char(137)
cEmo = char(240) + char(159) + char(152) + char(128)
cEuro = char(226) + char(130) + char(172)
cNl = char(10)

# [ text, separator, python partition, python rpartition ] -- generated from Python 3 str.partition
# and str.rpartition, the empty separator excluded (Python raises on it)
aPy = []
aPy + [ "key=value=more", "=", [ "key", "=", "value=more" ], [ "key=value", "=", "more" ] ]
aPy + [ "a-b", "-", [ "a", "-", "b" ], [ "a", "-", "b" ] ]
aPy + [ "x=y=z", "=", [ "x", "=", "y=z" ], [ "x=y", "=", "z" ] ]
aPy + [ "one two", " ", [ "one", " ", "two" ], [ "one", " ", "two" ] ]
aPy + [ "=ab", "=", [ "", "=", "ab" ], [ "", "=", "ab" ] ]
aPy + [ "ab=", "=", [ "ab", "=", "" ], [ "ab", "=", "" ] ]
aPy + [ "=", "=", [ "", "=", "" ], [ "", "=", "" ] ]
aPy + [ "abc", "abc", [ "", "abc", "" ], [ "", "abc", "" ] ]
aPy + [ "abc", "z", [ "abc", "", "" ], [ "", "", "abc" ] ]
aPy + [ "", "=", [ "", "", "" ], [ "", "", "" ] ]
aPy + [ "aaa", "aa", [ "", "aa", "a" ], [ "a", "aa", "" ] ]
aPy + [ "aaaa", "aa", [ "", "aa", "aa" ], [ "aa", "aa", "" ] ]
aPy + [ "a.b.c", ".", [ "a", ".", "b.c" ], [ "a.b", ".", "c" ] ]
aPy + [ "a(b(c", "(", [ "a", "(", "b(c" ], [ "a(b", "(", "c" ] ]
aPy + [ "x[]y[]z", "[]", [ "x", "[]", "y[]z" ], [ "x[]y", "[]", "z" ] ]
aPy + [ "a*b*c", "*", [ "a", "*", "b*c" ], [ "a*b", "*", "c" ] ]
aPy + [ "a+b+c", "+", [ "a", "+", "b+c" ], [ "a+b", "+", "c" ] ]
aPy + [ "a|b|c", "|", [ "a", "|", "b|c" ], [ "a|b", "|", "c" ] ]
aPy + [ "a::b::c", "::", [ "a", "::", "b::c" ], [ "a::b", "::", "c" ] ]
aPy + [ "a, b, c", ", ", [ "a", ", ", "b, c" ], [ "a, b", ", ", "c" ] ]
aPy + [ "abcabc", "ca", [ "ab", "ca", "bc" ], [ "ab", "ca", "bc" ] ]
aPy + [ "==", "=", [ "", "=", "=" ], [ "=", "=", "" ] ]
aPy + [ "a===b", "==", [ "a", "==", "=b" ], [ "a=", "==", "b" ] ]
aPy + [ "ab", "abc", [ "ab", "", "" ], [ "", "", "ab" ] ]
aPy + [ "=a=", "=", [ "", "=", "a=" ], [ "=a", "=", "" ] ]
aPy + [ "a^b$c", "$", [ "a^b", "$", "c" ], [ "a^b", "$", "c" ] ]
aPy + [ "a?b?c", "?", [ "a", "?", "b?c" ], [ "a?b", "?", "c" ] ]
aPy + [ "a{b}c", "{", [ "a", "{", "b}c" ], [ "a", "{", "b}c" ] ]
aPy + [ "a=b", "=", [ "a", "=", "b" ], [ "a", "=", "b" ] ]

# [ label, text, separator ] -- the Unicode and special cases, texts built from char codes
aUni = []
aUni + [ "hebrew words", cHeb1 + " " + cHeb2 + ", " + cHeb1, " " ]
aUni + [ "hebrew separator", "x" + cHeb1 + "y" + cHeb1 + "z", cHeb1 ]
aUni + [ "hebrew text ascii separator", cHeb1 + "=" + cHeb2 + "=" + cHeb1, "=" ]
aUni + [ "arabic meem separator", "a" + cArM + "b" + cArM + "c", cArM ]
aUni + [ "accented separator", "a" + cSmallE + "b" + cSmallE + "c", cSmallE ]
aUni + [ "accented text ascii separator", "caf" + cSmallE + "-" + cSmallE + "t" + cSmallE, "-" ]
aUni + [ "emoji separator", "a" + cEmo + "b" + cEmo + "c", cEmo ]
aUni + [ "double emoji separator", "a" + cEmo + cEmo + "b" + cEmo + cEmo + "c", cEmo + cEmo ]
aUni + [ "emoji ends the text", "a" + cEmo, cEmo ]
aUni + [ "emoji starts the text", cEmo + "a", cEmo ]
aUni + [ "three-byte separator", "1" + cEuro + "2" + cEuro + "3", cEuro ]
aUni + [ "mixed scripts", cHeb1 + cEmo + cArM + cEmo + "z", cEmo ]
aUni + [ "newline separator", "a" + cNl + "b" + cNl + "c", cNl ]
aUni + [ "backslash is literal", "a" + char(92) + "d b" + char(92) + "d", char(92) + "d" ]
aUni + [ "dot is literal", "a.b.c", "." ]
aUni + [ "regex class is literal", "a[0-9]b[0-9]c", "[0-9]" ]
aUni + [ "dot star is literal", "xa.*b.*c", ".*" ]
aUni + [ "separator longer than text", "ab", "abc" ]
aUni + [ "empty separator", "abc", "" ]
aUni + [ "both empty", "", "" ]
aUni + [ "empty text", "", "=" ]
aUni + [ "separator is the whole hebrew text", cHeb1, cHeb1 ]

# ------------------------------------------------------------------------------------------------

Scenario("The register's own example: key=value=more at =")
	o = new stzStringSplitter("key=value=more")
	aP = o.Partition("=")
	aPa = o.PartitionAfter("=")
	aR = o.RPartition("=")
	aRa = o.RPartitionAfter("=")
	bOk1 = SameList(aP, [ "key", "=", "value=more" ])
	bOk2 = SameList(aPa, [ "key=", "value=more" ])
	bOk3 = SameList(aR, [ "key=value", "=", "more" ])
	bOk4 = SameList(aRa, [ "key=value=", "more" ])
	Then("Partition cuts into before, separator and after", bOk1, 1)
	Then("PartitionAfter keeps the separator on the first part", bOk2, 1)
	Then("RPartition cuts at the LAST separator", bOk3, 1)
	Then("RPartitionAfter keeps the separator on the first part", bOk4, 1)
	Then("Partition is no longer a one-item list", len(aP), 3)
	Then("PartitionAfter is no longer a one-item list", len(aPa), 2)
	Then("RPartition is no longer a one-item list", len(aR), 3)
	Then("RPartitionAfter is no longer a one-item list", len(aRa), 2)
	bOld1 = SameList(aP, [ "key" ])
	bOld2 = SameList(aPa, [ "value=more" ])
	bOld3 = SameList(aR, [ "key=value" ])
	bOld4 = SameList(aRa, [ "more" ])
	Then("the old answer (only key) is not the answer", bOld1, 0)
	Then("the old answer (only value=more) is not the answer", bOld2, 0)
	Then("the old answer (only key=value) is not the answer", bOld3, 0)
	Then("the old answer (only more) is not the answer", bOld4, 0)
	bSame = SameList(aP, aR)
	Then("the first and last cuts differ on a text holding the separator twice", bSame, 0)
EndScenario()

Scenario("The other cases the register confirmed: a-b, x=y=z, one two and a Hebrew text")
	o = new stzStringSplitter("a-b")
	aP = o.Partition("-")
	aRa = o.RPartitionAfter("-")
	bOk1 = SameList(aP, [ "a", "-", "b" ])
	bOk2 = SameList(aRa, [ "a-", "b" ])
	Then("a-b Partition at -", bOk1, 1)
	Then("a-b RPartitionAfter at -", bOk2, 1)
	o = new stzStringSplitter("x=y=z")
	aPa = o.PartitionAfter("=")
	aR = o.RPartition("=")
	bOk3 = SameList(aPa, [ "x=", "y=z" ])
	bOk4 = SameList(aR, [ "x=y", "=", "z" ])
	Then("x=y=z PartitionAfter at =", bOk3, 1)
	Then("x=y=z RPartition at =", bOk4, 1)
	o = new stzStringSplitter("one two")
	aP = o.Partition(" ")
	bOk5 = SameList(aP, [ "one", " ", "two" ])
	Then("one two Partition at a space", bOk5, 1)
	cHebText = cHeb1 + " " + cHeb2
	o = new stzStringSplitter(cHebText)
	aP = o.Partition(" ")
	aRa = o.RPartitionAfter(" ")
	bH1 = SameList(aP, [ cHeb1, " ", cHeb2 ])
	bH2 = SameList(aRa, [ cHeb1 + " ", cHeb2 ])
	bH3 = SameList(aP, [ cHebText ])
	Then("a Hebrew text cut at the space: before, separator, after", bH1, 1)
	Then("RPartitionAfter keeps the space on the first Hebrew word", bH2, 1)
	Then("the Hebrew cut is not the Hebrew text whole", bH3, 0)
EndScenario()

Scenario("Python's str.partition and rpartition, on 29 ASCII (text, separator) pairs")
	nPyOk = 0
	nPyKo = 0
	nPyPa = 0
	nPyRa = 0
	nPyJoin = 0
	nPy = len(aPy)
	for i = 1 to nPy
		cT = aPy[i][1]
		cS = aPy[i][2]
		aWantP = aPy[i][3]
		aWantR = aPy[i][4]
		o = new stzStringSplitter(cT)
		aGotP = o.Partition(cS)
		aGotR = o.RPartition(cS)
		aGotPa = o.PartitionAfter(cS)
		aGotRa = o.RPartitionAfter(cS)
		if SameList(aGotP, aWantP) = 1
			nPyOk++
		else
			nPyKo++
			? "    Partition differs from Python on [" + cT + "] / [" + cS + "]"
		ok
		if SameList(aGotR, aWantR) = 1
			nPyOk++
		else
			nPyKo++
			? "    RPartition differs from Python on [" + cT + "] / [" + cS + "]"
		ok
		# the "After" forms are Python's pieces with the separator glued to the first part
		if SameList(aGotPa, [ aWantP[1] + aWantP[2], aWantP[3] ]) = 1
			nPyPa++
		ok
		if SameList(aGotRa, [ aWantR[1] + aWantR[2], aWantR[3] ]) = 1
			nPyRa++
		ok
		if strcmp(JoinOf(aGotP), cT) = 0 and strcmp(JoinOf(aGotR), cT) = 0 and strcmp(JoinOf(aGotPa), cT) = 0 and strcmp(JoinOf(aGotRa), cT) = 0
			nPyJoin++
		ok
	next
	nWant = nPy * 2
	Then("Partition and RPartition agree with Python on every pair (both forms)", nPyOk, nWant)
	Then("none of them disagrees", nPyKo, 0)
	Then("PartitionAfter agrees with Python's pieces on every pair", nPyPa, nPy)
	Then("RPartitionAfter agrees with Python's pieces on every pair", nPyRa, nPy)
	Then("the pieces of all four join back to the text on every pair", nPyJoin, nPy)
	Then("the table holds 29 pairs", nPy, 29)
EndScenario()

Scenario("Hebrew, Arabic, accented, emoji, multi-character and regex-special separators, against a byte model")
	nUni = len(aUni)
	nUniP = 0
	nUniPa = 0
	nUniR = 0
	nUniRa = 0
	nUniJoin = 0
	for i = 1 to nUni
		cLabel = aUni[i][1]
		cT = aUni[i][2]
		cS = aUni[i][3]
		o = new stzStringSplitter(cT)
		aGotP = o.Partition(cS)
		aGotPa = o.PartitionAfter(cS)
		aGotR = o.RPartition(cS)
		aGotRa = o.RPartitionAfter(cS)
		aF = RefCut(cT, cS, 0)
		aL = RefCut(cT, cS, 1)
		aWantP = RefShape(cT, aF, 3, 0)
		aWantPa = RefShape(cT, aF, 2, 0)
		aWantR = RefShape(cT, aL, 3, 1)
		aWantRa = RefShape(cT, aL, 2, 1)
		if SameList(aGotP, aWantP) = 1
			nUniP++
		else
			? "    Partition differs on case: " + cLabel
		ok
		if SameList(aGotPa, aWantPa) = 1
			nUniPa++
		else
			? "    PartitionAfter differs on case: " + cLabel
		ok
		if SameList(aGotR, aWantR) = 1
			nUniR++
		else
			? "    RPartition differs on case: " + cLabel
		ok
		if SameList(aGotRa, aWantRa) = 1
			nUniRa++
		else
			? "    RPartitionAfter differs on case: " + cLabel
		ok
		if strcmp(JoinOf(aGotP), cT) = 0 and strcmp(JoinOf(aGotPa), cT) = 0 and strcmp(JoinOf(aGotR), cT) = 0 and strcmp(JoinOf(aGotRa), cT) = 0
			nUniJoin++
		else
			? "    a join differs on case: " + cLabel
		ok
	next
	Then("Partition equals the byte model on every case", nUniP, nUni)
	Then("PartitionAfter equals the byte model on every case", nUniPa, nUni)
	Then("RPartition equals the byte model on every case", nUniR, nUni)
	Then("RPartitionAfter equals the byte model on every case", nUniRa, nUni)
	Then("all four join back to the text on every case", nUniJoin, nUni)
	Then("the table holds 22 cases", nUni, 22)
EndScenario()

Scenario("The pieces of the Unicode cuts, pinned literally (the model could share a blind spot)")
	o = new stzStringSplitter("a" + cEmo + "b" + cEmo + "c")
	aP = o.Partition(cEmo)
	aRa = o.RPartitionAfter(cEmo)
	bE1 = SameList(aP, [ "a", cEmo, "b" + cEmo + "c" ])
	bE2 = SameList(aRa, [ "a" + cEmo + "b" + cEmo, "c" ])
	nLenE = StzLen(aP[1])
	nLenSep = StzLen(aP[2])
	Then("emoji Partition: before, the emoji itself, and after keeping the second emoji", bE1, 1)
	Then("emoji RPartitionAfter: first part ends on the last emoji", bE2, 1)
	Then("the text before is 1 character", nLenE, 1)
	Then("the emoji separator is 1 character, 4 bytes", nLenSep * 10 + ring_len(aP[2]), 14)
	o = new stzStringSplitter("x" + cHeb1 + "y" + cHeb1 + "z")
	aR = o.RPartition(cHeb1)
	bH1 = SameList(aR, [ "x" + cHeb1 + "y", cHeb1, "z" ])
	bH2 = SameList([ aR[1] ], [ "x" ])
	Then("Hebrew RPartition: before holds the first Hebrew run, after is the last letter", bH1, 1)
	Then("Hebrew RPartition cuts at the later run, not the earlier", bH2, 0)
	o = new stzStringSplitter("a" + cSmallE + "b" + cSmallE + "c")
	aPa = o.PartitionAfter(cSmallE)
	bA1 = SameList(aPa, [ "a" + cSmallE, "b" + cSmallE + "c" ])
	nLenA = StzLen(aPa[1])
	Then("accented PartitionAfter keeps the accented letter on the first part", bA1, 1)
	Then("the first part is 2 characters, 3 bytes", nLenA * 10 + ring_len(aPa[1]), 23)
EndScenario()

Scenario("A separator that is absent, an empty separator and an empty text keep the stzString shapes")
	o = new stzStringSplitter("abc")
	b1 = SameList(o.Partition("z"), [ "abc", "", "" ])
	b2 = SameList(o.PartitionAfter("z"), [ "abc", "" ])
	b3 = SameList(o.RPartition("z"), [ "", "", "abc" ])
	b4 = SameList(o.RPartitionAfter("z"), [ "", "abc" ])
	Then("absent: Partition gives text, empty, empty", b1, 1)
	Then("absent: PartitionAfter gives text, empty", b2, 1)
	Then("absent: RPartition gives empty, empty, text", b3, 1)
	Then("absent: RPartitionAfter gives empty, text", b4, 1)
	b5 = SameList(o.Partition(""), [ "abc", "", "" ])
	b6 = SameList(o.PartitionAfter(""), [ "abc", "" ])
	b7 = SameList(o.RPartition(""), [ "", "", "abc" ])
	b8 = SameList(o.RPartitionAfter(""), [ "", "abc" ])
	Then("an empty separator never matches: Partition", b5, 1)
	Then("an empty separator never matches: PartitionAfter", b6, 1)
	Then("an empty separator never matches: RPartition", b7, 1)
	Then("an empty separator never matches: RPartitionAfter", b8, 1)
	oEmpty = new stzStringSplitter("")
	b9 = SameList(oEmpty.Partition("="), [ "", "", "" ])
	b10 = SameList(oEmpty.PartitionAfter("="), [ "", "" ])
	b11 = SameList(oEmpty.RPartition("="), [ "", "", "" ])
	b12 = SameList(oEmpty.RPartitionAfter("="), [ "", "" ])
	Then("an empty text: Partition", b9, 1)
	Then("an empty text: PartitionAfter", b10, 1)
	Then("an empty text: RPartition", b11, 1)
	Then("an empty text: RPartitionAfter", b12, 1)
	b13 = SameList(o.Partition("b"), [ "abc", "", "" ])
	b14 = SameList(o.RPartitionAfter("b"), [ "", "abc" ])
	b15 = SameList(o.Partition("B"), [ "abc", "", "" ])
	Then("a present separator is NOT given the absent shape (Partition)", b13, 0)
	Then("a present separator is NOT given the absent shape (RPartitionAfter)", b14, 0)
	Then("case matters by default: B is absent from abc", b15, 1)
EndScenario()

Scenario("A separator at the very start, at the very end, or equal to the whole text")
	o = new stzStringSplitter("=ab")
	b1 = SameList(o.Partition("="), [ "", "=", "ab" ])
	b2 = SameList(o.PartitionAfter("="), [ "=", "ab" ])
	b3 = SameList(o.RPartition("="), [ "", "=", "ab" ])
	b4 = SameList(o.RPartitionAfter("="), [ "=", "ab" ])
	Then("at the start: Partition", b1, 1)
	Then("at the start: PartitionAfter", b2, 1)
	Then("at the start: RPartition", b3, 1)
	Then("at the start: RPartitionAfter", b4, 1)
	o = new stzStringSplitter("ab=")
	b5 = SameList(o.Partition("="), [ "ab", "=", "" ])
	b6 = SameList(o.PartitionAfter("="), [ "ab=", "" ])
	b7 = SameList(o.RPartition("="), [ "ab", "=", "" ])
	b8 = SameList(o.RPartitionAfter("="), [ "ab=", "" ])
	Then("at the end: Partition", b5, 1)
	Then("at the end: PartitionAfter", b6, 1)
	Then("at the end: RPartition", b7, 1)
	Then("at the end: RPartitionAfter", b8, 1)
	o = new stzStringSplitter("abc")
	b9 = SameList(o.Partition("abc"), [ "", "abc", "" ])
	b10 = SameList(o.RPartitionAfter("abc"), [ "abc", "" ])
	Then("equal to the whole text: Partition", b9, 1)
	Then("equal to the whole text: RPartitionAfter", b10, 1)
	o = new stzStringSplitter("=a=")
	b11 = SameList(o.Partition("="), [ "", "=", "a=" ])
	b12 = SameList(o.RPartition("="), [ "=a", "=", "" ])
	b13 = SameList(o.Partition("="), o.RPartition("="))
	Then("at both ends: Partition cuts at the first", b11, 1)
	Then("at both ends: RPartition cuts at the last", b12, 1)
	Then("at both ends the first and the last cuts differ", b13, 0)
EndScenario()

Scenario("Overlapping occurrences: the first starts earliest, the last starts latest")
	o = new stzStringSplitter("aaa")
	b1 = SameList(o.Partition("aa"), [ "", "aa", "a" ])
	b2 = SameList(o.RPartition("aa"), [ "a", "aa", "" ])
	b3 = SameList(o.PartitionAfter("aa"), [ "aa", "a" ])
	b4 = SameList(o.RPartitionAfter("aa"), [ "aaa", "" ])
	b5 = SameList(o.RPartition("aa"), [ "", "aa", "a" ])
	Then("aaa at aa: Partition takes the occurrence at 1", b1, 1)
	Then("aaa at aa: RPartition takes the occurrence at 2", b2, 1)
	Then("aaa at aa: PartitionAfter", b3, 1)
	Then("aaa at aa: RPartitionAfter", b4, 1)
	Then("RPartition does NOT take the occurrence at 1", b5, 0)
	o = new stzStringSplitter("a===b")
	b6 = SameList(o.Partition("=="), [ "a", "==", "=b" ])
	b7 = SameList(o.RPartition("=="), [ "a=", "==", "b" ])
	Then("a===b at ==: Partition", b6, 1)
	Then("a===b at ==: RPartition", b7, 1)
EndScenario()

Scenario("stzString.Partition and RPartition give the same cut wherever the separator is present")
	nAgree = 0
	nAgreeTry = 0
	nBoth = len(aPy)
	for i = 1 to nBoth
		cT = aPy[i][1]
		cS = aPy[i][2]
		aF = RefCut(cT, cS, 0)
		if aF[1] = 1
			oStr = new stzString(cT)
			oSp = new stzStringSplitter(cT)
			nAgreeTry++
			if SameList(oSp.Partition(cS), oStr.Partition(cS)) = 1 and SameList(oSp.RPartition(cS), oStr.RPartition(cS)) = 1
				nAgree++
			else
				? "    disagrees with stzString on [" + cT + "] / [" + cS + "]"
			ok
		ok
	next
	nUni = len(aUni)
	for i = 1 to nUni
		cT = aUni[i][2]
		cS = aUni[i][3]
		aF = RefCut(cT, cS, 0)
		if aF[1] = 1
			oStr = new stzString(cT)
			oSp = new stzStringSplitter(cT)
			nAgreeTry++
			if SameList(oSp.Partition(cS), oStr.Partition(cS)) = 1 and SameList(oSp.RPartition(cS), oStr.RPartition(cS)) = 1
				nAgree++
			else
				? "    disagrees with stzString on case: " + aUni[i][1]
			ok
		ok
	next
	bEnough = (nAgreeTry >= 30)
	Then("every present-separator case agrees with stzString", nAgree, nAgreeTry)
	Then("at least 30 cases were compared", bEnough, 1)
	oStr = new stzString("key=value=more")
	bWrong = SameList(oStr.Partition("="), [ "key", "=", "value" ])
	Then("stzString does not give a deliberately wrong cut", bWrong, 0)
EndScenario()

Scenario("The case-sensitive twins: the flag 0 ignores case and the cut keeps the text's own spelling")
	o = new stzStringSplitter("Key=V=Key")
	b1 = SameList(o.PartitionCS("KEY", 1), [ "Key=V=Key", "", "" ])
	b2 = SameList(o.PartitionCS("KEY", 0), [ "", "Key", "=V=Key" ])
	b3 = SameList(o.RPartitionCS("KEY", 0), [ "Key=V=", "Key", "" ])
	b4 = SameList(o.RPartitionCS("KEY", 1), [ "", "", "Key=V=Key" ])
	b5 = SameList(o.PartitionAfterCS("kEy", 0), [ "Key", "=V=Key" ])
	b6 = SameList(o.RPartitionAfterCS("kEy", 0), [ "Key=V=Key", "" ])
	b7 = SameList(o.PartitionCS("KEY", 1), o.PartitionCS("KEY", 0))
	b8 = SameList(o.PartitionCS("Key", 1), o.PartitionCS("Key", 0))
	b9 = SameList(o.Partition("Key"), o.PartitionCS("Key", 1))
	Then("CS 1 does not find KEY", b1, 1)
	Then("CS 0 finds KEY and returns the text's spelling", b2, 1)
	Then("CS 0 RPartition takes the last Key", b3, 1)
	Then("CS 1 RPartition does not find KEY", b4, 1)
	Then("CS 0 PartitionAfter", b5, 1)
	Then("CS 0 RPartitionAfter", b6, 1)
	Then("CS 1 and CS 0 differ on a mismatching case", b7, 0)
	Then("CS 1 and CS 0 agree on a matching case", b8, 1)
	Then("the plain form is CS 1", b9, 1)
	o = new stzStringSplitter("a" + cSmallE + "b" + cBigE + "c")
	aCiP = o.PartitionCS(cBigE, 0)
	aCiR = o.RPartitionCS(cSmallE, 0)
	aCsP = o.PartitionCS(cBigE, 1)
	b10 = SameList(aCiP, [ "a", cSmallE, "b" + cBigE + "c" ])
	b11 = SameList(aCiR, [ "a" + cSmallE + "b", cBigE, "c" ])
	b12 = SameList(aCsP, [ "a" + cSmallE + "b", cBigE, "c" ])
	b13 = SameList(aCsP, aCiP)
	Then("accented capital matches the small letter when case is ignored (own spelling kept)", b10, 1)
	Then("RPartition ignoring case takes the later capital", b11, 1)
	Then("with case kept, the capital cuts at the capital", b12, 1)
	Then("with case kept the capital does not cut at the small letter", b13, 0)
EndScenario()

Scenario("The splitter built over a stzString, a bad separator type, and scale")
	oStr = new stzString("key=value=more")
	oSp = new stzStringSplitter(oStr)
	b1 = SameList(oSp.Partition("="), [ "key", "=", "value=more" ])
	b2 = SameList(oSp.RPartitionAfter("="), [ "key=value=", "more" ])
	Then("built over a stzString: Partition", b1, 1)
	Then("built over a stzString: RPartitionAfter", b2, 1)
	cErr = ""
	try
		oSp.Partition(5)
	catch
		cErr = cCatchError
	done
	bRaised = (cErr != "")
	Then("a number as separator raises", bRaised, 1)
	cErr2 = ""
	try
		oSp.RPartitionAfter([ "a" ])
	catch
		cErr2 = cCatchError
	done
	bRaised2 = (cErr2 != "")
	Then("a list as separator raises", bRaised2, 1)
	cErr3 = ""
	try
		oSp.Partition("=")
	catch
		cErr3 = cCatchError
	done
	Then("a string separator does not raise", cErr3, "")
	cHuge = copy("a", 100000) + "=" + copy("b", 100000) + "=" + copy("c", 50000)
	oHuge = new stzStringSplitter(cHuge)
	aHugeP = oHuge.Partition("=")
	aHugeR = oHuge.RPartition("=")
	aLensP = [ ring_len(aHugeP[1]), ring_len(aHugeP[2]), ring_len(aHugeP[3]) ]
	aLensR = [ ring_len(aHugeR[1]), ring_len(aHugeR[2]), ring_len(aHugeR[3]) ]
	Then("a 250k text: Partition before is 100000 bytes", aLensP[1], 100000)
	Then("a 250k text: Partition separator is 1 byte", aLensP[2], 1)
	Then("a 250k text: Partition after is 150001 bytes", aLensP[3], 150001)
	Then("a 250k text: RPartition before is 200001 bytes", aLensR[1], 200001)
	Then("a 250k text: RPartition after is 50000 bytes", aLensR[3], 50000)
	bDiffer = (ring_len(aHugeP[1]) = ring_len(aHugeR[1]))
	Then("the first and last cuts of the big text differ", bDiffer, 0)
EndScenario()

Scenario("The neighbours in the class are unchanged: Split, SplitBefore, SplitAfter, SplitByRegex")
	o = new stzStringSplitter("a,b,,c")
	b1 = SameList(o.Split(","), [ "a", "b", "", "c" ])
	b2 = SameList(o.SplitAfter(","), [ "a,", "b,", ",", "c" ])
	b3 = SameList(o.SplitBefore(","), [ "a", ",b", ",", ",c" ])
	b4 = SameList(o.SplitByRegex(",+"), [ "a", "b", "c" ])
	b5 = SameList(o.Split(","), o.Partition(","))
	Then("Split drops the separators", b1, 1)
	Then("SplitAfter keeps them", b2, 1)
	Then("SplitBefore keeps them", b3, 1)
	Then("SplitByRegex matches a run", b4, 1)
	Then("Split is not Partition", b5, 0)
EndScenario()

Summary()

# ---------------------------------------------------------------------------------------------
# helpers (at the end: top-level code after a func belongs to that func in Ring)

# 1 when two lists of texts have the same length and the same texts, compared byte for byte.
# Ring functions see the main program's variables, so every name here is prefixed to stay clear of
# the loops that call these helpers (a bare i in a helper would clobber the caller's loop counter).
func SameList(hA, hB)
	if NOT isList(hA) or NOT isList(hB)
		return 0
	ok
	hnA = len(hA)
	if hnA != len(hB)
		return 0
	ok
	for hi = 1 to hnA
		if NOT isString(hA[hi]) or NOT isString(hB[hi])
			return 0
		ok
		if strcmp(hA[hi], hB[hi]) != 0
			return 0
		ok
	next
	return 1

func JoinOf(hPieces)
	hcJoin = ""
	hnP = len(hPieces)
	for hi = 1 to hnP
		hcJoin += hPieces[hi]
	next
	return hcJoin

# The byte-level model: [ found, before, separator, after ] at the first (hnLast 0) or the last (hnLast 1)
# occurrence, found with Ring's byte substr on valid UTF-8 (a separator is whole characters, so a byte
# match lands on a character boundary), the last one by scanning backwards.
func RefCut(hcText, hcSep, hnLast)
	hnText = len(hcText)
	hnSep = len(hcSep)
	if hnText = 0 or hnSep = 0 or hnSep > hnText
		return [ 0, "", "", "" ]
	ok
	hnPos = 0
	if hnLast = 0
		hnPos = substr(hcText, hcSep)
	else
		hi = hnText - hnSep + 1
		while hi >= 1
			if strcmp(substr(hcText, hi, hnSep), hcSep) = 0
				hnPos = hi
				exit
			ok
			hi--
		end
	ok
	if hnPos = 0
		return [ 0, "", "", "" ]
	ok
	hcBefore = ""
	if hnPos > 1
		hcBefore = substr(hcText, 1, hnPos - 1)
	ok
	hcAfter = ""
	hnEnd = hnPos + hnSep
	if hnEnd <= hnText
		hcAfter = substr(hcText, hnEnd, hnText - hnEnd + 1)
	ok
	return [ 1, hcBefore, hcSep, hcAfter ]

# The answer the model expects: hnParts 3 gives [ before, sep, after ], 2 gives [ before + sep, after ];
# when absent, the first-occurrence forms keep the text on the left, the last-occurrence forms on the right.
func RefShape(hcText, haCut, hnParts, hnLast)
	if haCut[1] = 0
		if hnParts = 3
			if hnLast = 0
				return [ hcText, "", "" ]
			ok
			return [ "", "", hcText ]
		ok
		if hnLast = 0
			return [ hcText, "" ]
		ok
		return [ "", hcText ]
	ok
	if hnParts = 3
		return [ haCut[2], haCut[3], haCut[4] ]
	ok
	return [ haCut[2] + haCut[3], haCut[4] ]
