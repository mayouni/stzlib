load "../../stzBase.ring"
load "../_narrated.ring"

# stzStringChecker -- the three rows of the register (DEFECTS.md): HasLeadingChars,
# HasTrailingChars and HasLeadingAndTrailingChars.
#
# Before: all three answered 0 for every text. HasLeadingChars and HasTrailingChars took the first
# two (the last two) characters with StzEngineStringCharAtToString and compared them with =; that
# call hands back an engine HANDLE, a new number on every call, so two handles are never equal even
# when the two characters are. HasLeadingAndTrailingChars was the AND of the two and so always 0.
# Now the two characters are taken as text (StzMid, which counts code points) and compared byte
# for byte with strcmp, so the answers are:
#   HasLeadingChars              the text starts with two equal characters
#   HasTrailingChars             the text ends with two equal characters
#   HasLeadingAndTrailingChars   both of the above, put to the same text
# A character is one Unicode code point; letter case counts; a text of fewer than two characters
# answers 0; a text of one character repeated (aa, aaaa) is both leading and trailing. This is the
# contract of stzString.HasLeadingChars (a run of at least two equal characters), which the checker
# now agrees with on every text of the table.
#
# Three independent references: the literal expected answers of the table below (written from the
# contract, not computed), the mirror relation (a text ends with a repeat exactly when its reverse
# starts with one) and stzString's own methods of the same names. Hebrew, Arabic, Cyrillic, accented,
# euro and emoji texts are built from char codes and never printed. Run from inside test/string.

# Ring is case-insensitive about names: every name here is distinct under that rule, and each is
# prefixed because a library method that assigns a plain name overwrites a global of the same name.
gcEacute = char(195) + char(169)
gcBigEacute = char(195) + char(137)
gcAleph = char(215) + char(144)
gcBet = char(215) + char(145)
gcMeem = char(217) + char(133)
gcAlefAr = char(216) + char(167)
gcBaAr = char(216) + char(168)
gcCyrBig = char(208) + char(144)
gcCyrSmall = char(208) + char(176)
gcEuro = char(226) + char(130) + char(172)
gcKip = char(226) + char(130) + char(173)
gcGrin = char(240) + char(159) + char(152) + char(128)
gcBeam = char(240) + char(159) + char(152) + char(129)
gcAcute = char(204) + char(129)
gcTab = char(9)
gcNl = char(10)

# [ label, text, HasLeadingChars, HasTrailingChars, HasLeadingAndTrailingChars ] -- the expected
# answers are literals, written from the contract
gaTable = []
gaTable + [ "empty text", "", 0, 0, 0 ]
gaTable + [ "one letter", "a", 0, 0, 0 ]
gaTable + [ "aa", "aa", 1, 1, 1 ]
gaTable + [ "ab", "ab", 0, 0, 0 ]
gaTable + [ "aab", "aab", 1, 0, 0 ]
gaTable + [ "abb", "abb", 0, 1, 0 ]
gaTable + [ "xxyy", "xxyy", 1, 1, 1 ]
gaTable + [ "aabaa", "aabaa", 1, 1, 1 ]
gaTable + [ "aaaa", "aaaa", 1, 1, 1 ]
gaTable + [ "aaab", "aaab", 1, 0, 0 ]
gaTable + [ "baaa", "baaa", 0, 1, 0 ]
gaTable + [ "abab", "abab", 0, 0, 0 ]
gaTable + [ "aba", "aba", 0, 0, 0 ]
gaTable + [ "abba", "abba", 0, 0, 0 ]
gaTable + [ "aabb", "aabb", 1, 1, 1 ]
gaTable + [ "a long run", "aaaaaaaa", 1, 1, 1 ]
gaTable + [ "Aa (case differs)", "Aa", 0, 0, 0 ]
gaTable + [ "aA (case differs)", "aA", 0, 0, 0 ]
gaTable + [ "AAb", "AAb", 1, 0, 0 ]
gaTable + [ "bAA", "bAA", 0, 1, 0 ]
gaTable + [ "AAa (repeat, then a case change)", "AAa", 1, 0, 0 ]
gaTable + [ "aAA (a case change, then a repeat)", "aAA", 0, 1, 0 ]
gaTable + [ "two spaces then x", "  x", 1, 0, 0 ]
gaTable + [ "x then two spaces", "x  ", 0, 1, 0 ]
gaTable + [ "digits 112", "112", 1, 0, 0 ]
gaTable + [ "digits 211", "211", 0, 1, 0 ]
gaTable + [ "two dashes", "--", 1, 1, 1 ]
gaTable + [ "dash letters dash", "-ab-", 0, 0, 0 ]
gaTable + [ "two tabs", gcTab + gcTab, 1, 1, 1 ]
gaTable + [ "newline, a, newline", gcNl + "a" + gcNl, 0, 0, 0 ]
gaTable + [ "two newlines then a", gcNl + gcNl + "a", 1, 0, 0 ]
gaTable + [ "two e-acute then b", gcEacute + gcEacute + "b", 1, 0, 0 ]
gaTable + [ "b then two e-acute", "b" + gcEacute + gcEacute, 0, 1, 0 ]
gaTable + [ "two e-acute", gcEacute + gcEacute, 1, 1, 1 ]
gaTable + [ "e-acute then E-acute (case differs)", gcEacute + gcBigEacute, 0, 0, 0 ]
gaTable + [ "e-acute, t, e-acute", gcEacute + "t" + gcEacute, 0, 0, 0 ]
gaTable + [ "two aleph then b", gcAleph + gcAleph + "b", 1, 0, 0 ]
gaTable + [ "b then two aleph", "b" + gcAleph + gcAleph, 0, 1, 0 ]
gaTable + [ "aleph bet (same lead byte)", gcAleph + gcBet, 0, 0, 0 ]
gaTable + [ "two aleph", gcAleph + gcAleph, 1, 1, 1 ]
gaTable + [ "aleph aleph bet aleph aleph", gcAleph + gcAleph + gcBet + gcAleph + gcAleph, 1, 1, 1 ]
gaTable + [ "two arabic meem", gcMeem + gcMeem, 1, 1, 1 ]
gaTable + [ "arabic alef then ba (same lead byte)", gcAlefAr + gcBaAr, 0, 0, 0 ]
gaTable + [ "cyrillic capital then small a (case differs)", gcCyrBig + gcCyrSmall, 0, 0, 0 ]
gaTable + [ "two euro signs", gcEuro + gcEuro, 1, 1, 1 ]
gaTable + [ "euro then kip (same first two bytes)", gcEuro + gcKip, 0, 0, 0 ]
gaTable + [ "two emoji then b", gcGrin + gcGrin + "b", 1, 0, 0 ]
gaTable + [ "b then two emoji", "b" + gcGrin + gcGrin, 0, 1, 0 ]
gaTable + [ "two emoji", gcGrin + gcGrin, 1, 1, 1 ]
gaTable + [ "two different emoji (same first three bytes)", gcGrin + gcBeam, 0, 0, 0 ]
gaTable + [ "emoji, a, emoji", gcGrin + "a" + gcGrin, 0, 0, 0 ]
gaTable + [ "e-acute written e + accent, twice", "e" + gcAcute + "e" + gcAcute, 0, 0, 0 ]
gaTable + [ "two e then an accent", "ee" + gcAcute, 1, 0, 0 ]
gaTable + [ "an accent then two e", gcAcute + "ee", 0, 1, 0 ]
gaTable + [ "the combining accent twice", gcAcute + gcAcute, 1, 1, 1 ]

# ------------------------------------------------------------------------------------------------

Scenario("The register's examples: aab, xxyy, abb and aabaa all answered 0")
	gO = new stzStringChecker("aab")
	gnL1 = gO.HasLeadingChars()
	gnT1 = gO.HasTrailingChars()
	gnB1 = gO.HasLeadingAndTrailingChars()
	Then("aab starts with a repeated character", gnL1, 1)
	Then("aab does not end with one", gnT1, 0)
	Then("aab is therefore not both", gnB1, 0)
	gO = new stzStringChecker("abb")
	gnL2 = gO.HasLeadingChars()
	gnT2 = gO.HasTrailingChars()
	gnB2 = gO.HasLeadingAndTrailingChars()
	Then("abb does not start with a repeated character", gnL2, 0)
	Then("abb ends with one", gnT2, 1)
	Then("abb is therefore not both", gnB2, 0)
	gO = new stzStringChecker("xxyy")
	gnL3 = gO.HasLeadingChars()
	gnT3 = gO.HasTrailingChars()
	gnB3 = gO.HasLeadingAndTrailingChars()
	Then("xxyy starts with a repeated character (xx)", gnL3, 1)
	Then("xxyy ends with one (yy)", gnT3, 1)
	Then("xxyy is both", gnB3, 1)
	gO = new stzStringChecker("aabaa")
	gnL4 = gO.HasLeadingChars()
	gnT4 = gO.HasTrailingChars()
	gnB4 = gO.HasLeadingAndTrailingChars()
	Then("aabaa starts with a repeated character", gnL4, 1)
	Then("aabaa ends with one", gnT4, 1)
	Then("aabaa is both (it answered 0 because it was the AND of two zeros)", gnB4, 1)
	gO = new stzStringChecker("abab")
	gnL5 = gO.HasLeadingChars()
	gnT5 = gO.HasTrailingChars()
	gnB5 = gO.HasLeadingAndTrailingChars()
	Then("abab, which repeats no character at either end, starts with none", gnL5, 0)
	Then("abab ends with none", gnT5, 0)
	Then("abab is not both", gnB5, 0)
EndScenario()

Scenario("The root cause: the engine call returns a handle, and two handles are never equal")
	gnPh = StzEngineString("aa")
	gnH1 = StzEngineStringCharAtToString(gnPh, 1)
	gnH2 = StzEngineStringCharAtToString(gnPh, 2)
	gnSame = (gnH1 = gnH2)
	gnIsNumber = isNumber(gnH1)
	Then("the two characters of aa come back as numbers (handles), not as text", gnIsNumber, 1)
	Then("the two handles differ although both characters are a", gnSame, 0)
	gcOne = StzMid("aa", 1, 1)
	gcTwo = StzMid("aa", 2, 1)
	gnTxt = strcmp(gcOne, gcTwo)
	Then("the two characters taken as text are equal", gnTxt, 0)
	gcOne = StzMid("ab", 1, 1)
	gcTwo = StzMid("ab", 2, 1)
	gnTxt = strcmp(gcOne, gcTwo)
	Then("and differ for ab (a negative sibling: the text comparison is not always true)", gnTxt != 0, 1)
	StzEngineStringFree(gnH1)
	StzEngineStringFree(gnH2)
	StzEngineStringFree(gnPh)
EndScenario()

Scenario("The table of texts: the three predicates against the literal expected answers")
	gnRows = len(gaTable)
	gnBadL = 0
	gnBadT = 0
	gnBadB = 0
	gnOnesL = 0
	gnZerosL = 0
	gnOnesT = 0
	gnZerosT = 0
	gnOnesB = 0
	gnZerosB = 0
	for gnI = 1 to gnRows
		gcTxt = gaTable[gnI][2]
		gO = new stzStringChecker(gcTxt)
		gnGotL = gO.HasLeadingChars()
		gnGotT = gO.HasTrailingChars()
		gnGotB = gO.HasLeadingAndTrailingChars()
		if gnGotL != gaTable[gnI][3]
			gnBadL++
			? "    HasLeadingChars wrong on: " + gaTable[gnI][1]
		ok
		if gnGotT != gaTable[gnI][4]
			gnBadT++
			? "    HasTrailingChars wrong on: " + gaTable[gnI][1]
		ok
		if gnGotB != gaTable[gnI][5]
			gnBadB++
			? "    HasLeadingAndTrailingChars wrong on: " + gaTable[gnI][1]
		ok
		if gaTable[gnI][3] = 1 gnOnesL++ else gnZerosL++ ok
		if gaTable[gnI][4] = 1 gnOnesT++ else gnZerosT++ ok
		if gaTable[gnI][5] = 1 gnOnesB++ else gnZerosB++ ok
	next
	gnEnough = (gnRows >= 40)
	Then("the table holds at least 40 texts", gnEnough, 1)
	Then("HasLeadingChars is right on every text", gnBadL, 0)
	Then("HasTrailingChars is right on every text", gnBadT, 0)
	Then("HasLeadingAndTrailingChars is right on every text", gnBadB, 0)
	gnBoth = (gnOnesL > 0 and gnZerosL > 0 and gnOnesT > 0 and gnZerosT > 0 and gnOnesB > 0 and gnZerosB > 0)
	Then("the table expects both answers for each predicate, so a constant answer cannot pass", gnBoth, 1)
EndScenario()

Scenario("The edges of the length: 0, 1 and 2 characters")
	gO = new stzStringChecker("")
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars() + gO.HasLeadingAndTrailingChars()
	Then("an empty text repeats nothing", gnA, 0)
	gO = new stzStringChecker("a")
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars() + gO.HasLeadingAndTrailingChars()
	Then("one character is not a repeat", gnA, 0)
	gO = new stzStringChecker(gcEacute)
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars() + gO.HasLeadingAndTrailingChars()
	Then("one accented character, two bytes long, is not a repeat either", gnA, 0)
	gO = new stzStringChecker("aa")
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars() + gO.HasLeadingAndTrailingChars()
	Then("two equal characters are a repeat at both ends: all three answer 1", gnA, 3)
	gO = new stzStringChecker("ab")
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars() + gO.HasLeadingAndTrailingChars()
	Then("two different characters are not", gnA, 0)
	gO = new stzStringChecker(gcEacute + "b")
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars() + gO.HasLeadingAndTrailingChars()
	Then("an accented character followed by b is not a repeat (3 bytes, 2 characters)", gnA, 0)
EndScenario()

Scenario("Letter case counts: Aa and aA are not repeats, AA and aa are")
	gO = new stzStringChecker("Aa")
	gnL = gO.HasLeadingChars()
	gnT = gO.HasTrailingChars()
	Then("Aa does not start with a repeat", gnL, 0)
	Then("Aa does not end with one", gnT, 0)
	gO = new stzStringChecker("AA")
	gnL = gO.HasLeadingChars()
	gnT = gO.HasTrailingChars()
	Then("AA starts with a repeat", gnL, 1)
	Then("AA ends with one", gnT, 1)
	gO = new stzStringChecker("aAa")
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars()
	Then("aAa repeats nothing at either end, whatever a case-blind reading says", gnA, 0)
	gO = new stzStringChecker(gcCyrBig + gcCyrSmall)
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars()
	Then("a Cyrillic capital and its small form differ", gnA, 0)
	gO = new stzStringChecker(gcCyrSmall + gcCyrSmall)
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars()
	Then("the small form twice repeats", gnA, 2)
EndScenario()

Scenario("Non-ASCII text: a character is a code point, never a byte")
	gO = new stzStringChecker(gcEacute + gcEacute + "b")
	gnL = gO.HasLeadingChars()
	Then("e-acute twice starts a text", gnL, 1)
	gO = new stzStringChecker(gcAleph + gcBet)
	gnL = gO.HasLeadingChars()
	Then("aleph and bet share their first byte and are not a repeat", gnL, 0)
	gO = new stzStringChecker(gcAleph + gcAleph)
	gnL = gO.HasLeadingChars()
	Then("a Hebrew letter twice is a repeat", gnL, 1)
	gO = new stzStringChecker(gcGrin + gcBeam)
	gnL = gO.HasLeadingChars()
	gnT = gO.HasTrailingChars()
	Then("two different emoji share their first three bytes and are not a repeat (start)", gnL, 0)
	Then("two different emoji are not a repeat (end)", gnT, 0)
	gO = new stzStringChecker(gcGrin + gcGrin)
	gnL = gO.HasLeadingChars()
	gnT = gO.HasTrailingChars()
	Then("an emoji twice is a repeat (start)", gnL, 1)
	Then("an emoji twice is a repeat (end)", gnT, 1)
	gO = new stzStringChecker(gcEuro + gcKip)
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars()
	Then("euro and kip signs share their first two bytes and are not a repeat", gnA, 0)
	gO = new stzStringChecker(gcAlefAr + gcBaAr)
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars()
	Then("arabic alef and ba share their first byte and are not a repeat", gnA, 0)
	gO = new stzStringChecker(gcAleph + gcAleph + gcBet + gcAleph + gcAleph)
	gnB = gO.HasLeadingAndTrailingChars()
	Then("a Hebrew aabaa pattern is both leading and trailing", gnB, 1)
EndScenario()

Scenario("Combining sequences: the letter and its accent are two characters")
	gcDecomp = "e" + gcAcute
	gO = new stzStringChecker(gcDecomp + gcDecomp)
	gnL = gO.HasLeadingChars()
	gnT = gO.HasTrailingChars()
	gnN = gO.NumberOfChars()
	Then("e with a separate accent, twice, is four characters", gnN, 4)
	Then("it does not start with a repeat (e then the accent)", gnL, 0)
	Then("it does not end with one (the last two are e and the accent)", gnT, 0)
	gO = new stzStringChecker("ee" + gcAcute)
	gnL = gO.HasLeadingChars()
	gnT = gO.HasTrailingChars()
	Then("two e then an accent starts with a repeat", gnL, 1)
	Then("two e then an accent does not end with one", gnT, 0)
	gO = new stzStringChecker(gcAcute + gcAcute)
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars()
	Then("the bare accent twice is a repeat of code points at both ends", gnA, 2)
	gO = new stzStringChecker(gcEacute + gcEacute)
	gnA = gO.HasLeadingChars() + gO.HasTrailingChars()
	Then("the precomposed e-acute twice is a repeat at both ends", gnA, 2)
EndScenario()

Scenario("The mirror relation: a text ends with a repeat exactly when its reverse starts with one")
	gnMirror = 0
	gnMirrorBad = 0
	for gnI = 1 to len(gaTable)
		gcTxt = gaTable[gnI][2]
		gcRev = StzReverse(gcTxt)
		gO = new stzStringChecker(gcTxt)
		gR = new stzStringChecker(gcRev)
		gnT = gO.HasTrailingChars()
		gnL = gR.HasLeadingChars()
		gnL2 = gO.HasLeadingChars()
		gnT2 = gR.HasTrailingChars()
		if gnT = gnL and gnL2 = gnT2
			gnMirror++
		else
			gnMirrorBad++
			? "    mirror broken on: " + gaTable[gnI][1]
		ok
	next
	gnRows = len(gaTable)
	Then("the relation holds on every text of the table", gnMirror, gnRows)
	Then("it is never broken", gnMirrorBad, 0)
	gO = new stzStringChecker("aab")
	gR = new stzStringChecker("baa")
	gnX = gO.HasLeadingChars()
	gnY = gR.HasTrailingChars()
	Then("aab starts with a repeat and baa, its reverse, ends with one", gnX + gnY, 2)
	gnX = gO.HasTrailingChars()
	gnY = gR.HasLeadingChars()
	Then("and neither answers the other end", gnX + gnY, 0)
EndScenario()

Scenario("HasLeadingAndTrailingChars is both questions put to the same text")
	gnAndOk = 0
	gnAndBad = 0
	for gnI = 1 to len(gaTable)
		gO = new stzStringChecker(gaTable[gnI][2])
		gnL = gO.HasLeadingChars()
		gnT = gO.HasTrailingChars()
		gnB = gO.HasLeadingAndTrailingChars()
		gnWant = 0
		if gnL = 1 and gnT = 1
			gnWant = 1
		ok
		if gnB = gnWant
			gnAndOk++
		else
			gnAndBad++
		ok
	next
	gnRows = len(gaTable)
	Then("it equals leading AND trailing on every text", gnAndOk, gnRows)
	Then("it never differs", gnAndBad, 0)
	gO = new stzStringChecker("aaaa")
	gnB = gO.HasLeadingAndTrailingChars()
	Then("a text made of one character repeated is both (aaaa)", gnB, 1)
	gO = new stzStringChecker("aa")
	gnB = gO.HasLeadingAndTrailingChars()
	Then("and so is its shortest form (aa)", gnB, 1)
	gO = new stzStringChecker("aabcc")
	gnB = gO.HasLeadingAndTrailingChars()
	Then("a repeat at each end with other things between: both", gnB, 1)
	gO = new stzStringChecker("aabc")
	gnB = gO.HasLeadingAndTrailingChars()
	Then("a repeat at one end only is not both", gnB, 0)
EndScenario()

Scenario("Agreement with stzString's methods of the same names, over the whole table")
	gnAgree = 0
	gnDisagree = 0
	for gnI = 1 to len(gaTable)
		gcTxt = gaTable[gnI][2]
		gO = new stzStringChecker(gcTxt)
		gS = new stzString(gcTxt)
		gnCL = gO.HasLeadingChars()
		gnCT = gO.HasTrailingChars()
		gnCB = gO.HasLeadingAndTrailingChars()
		gnSL = gS.HasLeadingChars()
		gnST = gS.HasTrailingChars()
		gnSB = gS.HasLeadingAndTrailingChars()
		if gnCL = gnSL and gnCT = gnST and gnCB = gnSB
			gnAgree++
		else
			gnDisagree++
			? "    checker and stzString disagree on: " + gaTable[gnI][1]
		ok
	next
	gnRows = len(gaTable)
	Then("the checker and stzString agree on every text", gnAgree, gnRows)
	Then("they never disagree", gnDisagree, 0)
	# the checker built over a stzString object (the way stzString uses it) answers the same
	gS = new stzString("aabaa")
	gO = new stzStringChecker(gS)
	gnX = gO.HasLeadingAndTrailingChars()
	Then("a checker built over a stzString object answers 1 for aabaa", gnX, 1)
	gS = new stzString("aab")
	gO = new stzStringChecker(gS)
	gnX = gO.HasLeadingAndTrailingChars()
	Then("and 0 for aab", gnX, 0)
EndScenario()

Scenario("The questions leave the text alone and give the same answer when asked twice")
	gcUni = gcGrin + gcGrin + "x" + gcEacute + gcEacute
	gO = new stzStringChecker(gcUni)
	gnF1 = gO.HasLeadingChars()
	gnF2 = gO.HasLeadingChars()
	gnG1 = gO.HasTrailingChars()
	gnG2 = gO.HasTrailingChars()
	gcAfter = gO.Content()
	gnSameText = strcmp(gcAfter, gcUni)
	Then("the text is unchanged after the questions", gnSameText, 0)
	Then("the leading question gives the same answer twice (1)", gnF1 + gnF2, 2)
	Then("the trailing question gives the same answer twice (1)", gnG1 + gnG2, 2)
	gnChars = gO.NumberOfChars()
	Then("the text is still five characters long", gnChars, 5)
EndScenario()

Summary()
