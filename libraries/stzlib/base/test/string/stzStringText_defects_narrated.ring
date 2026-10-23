load "../../stzBase.ring"
load "../_narrated.ring"

# stzStringText -- the three rows of the register (DEFECTS.md): OnlyScript, OnlyArabic and OnlyLatin.
#
# Before: OnlyScript raised R24 (Using uninitialized variable pcscript) for :Latin, :Hebrew and
# :Arabic alike, because the anonymous function it built is a GLOBAL function and cannot see the
# method's parameter; OnlyArabic and OnlyLatin raised R14 (Calling Method without definition:
# concatenateq), a method that no longer exists. Now:
#   OnlyScript(s)   the characters whose Unicode script is exactly s, in order. A blank, a digit,
#                   a punctuation mark and an emoji are of the common script and GO; a letter of
#                   another script goes. A combining mark (script inherited: an accent, an Arabic
#                   diacritic, a joiner) stays when the character before it stays, so an accented
#                   letter keeps its accent; one with nothing before it goes. The name is case-
#                   folded (:LATIN, :Latin, "latin" are the same); an unknown name gives an empty
#                   text; a name that is not a text raises. Asking for :Common or :Inherited
#                   gives exactly the characters of that script
#   OnlyLatin       the Latin part with the COMMON characters kept between the kept letters (the
#   OnlyArabic      blanks and punctuation that make it readable), the letters of the other
#                   scripts removed, and the blanks and line breaks collapsed to single blanks with
#                   the ends trimmed -- what the retired bodies were written to do. A text with no
#                   letter of the script gives an empty text, whatever else it holds
#
# How the script of a character is read: from the engine's Unicode table, one character at a time
# (StzEngineStringScriptNamesList on a one-character engine string -- the way stzStringChar.Script
# does); the engine offers no call that returns the script of every character at once. A hundred
# thousand characters take a quarter of a second for the lookups.
#
# Independent references: literal expected texts built from char codes (never printed), and for the
# random scenario an oracle written HERE: every text is assembled from pieces whose script is
# declared in this file, so the expected part of each script is the concatenation of its declared
# pieces -- the class is never asked what its own answer should be. Texts are compared byte for
# byte with strcmp (the Ring = on two texts ignores letter case). Run from inside test/string.

gcHeb = char(215) + char(169) + char(215) + char(156) + char(215) + char(149) + char(215) + char(157)
gcAra = char(216) + char(179) + char(217) + char(132) + char(216) + char(167) + char(217) + char(133)
gcEacute = char(195) + char(169)
gcAcute = char(204) + char(129)
gcFatha = char(217) + char(142)
gcGrin = char(240) + char(159) + char(152) + char(128)
gcAlpha = char(206) + char(177)
gcDe = char(208) + char(180)
gcHan = char(228) + char(184) + char(173)
gcTai = char(225) + char(168) + char(160)
gcAleph = char(215) + char(144)
gcBet = char(215) + char(145)
gcAlef = char(216) + char(167)
gcBa = char(216) + char(168)
gcNikud = char(214) + char(176)
gcMixed = "abc" + gcHeb + " " + gcAra + "123"

# --------------------------------------------------------------------------------------------------

Scenario("The register's examples: a mixed text, one script at a time (they raised R24 / R14)")
	gcR = OnlyOf(gcMixed, "S", "latin")
	gnEq = strcmp(gcR, "abc")
	Then("OnlyScript(latin) of abc + shalom + blank + salam + 123 is abc", gnEq, 0)
	gcR = OnlyOf(gcMixed, "S", "hebrew")
	gnEq = strcmp(gcR, gcHeb)
	Then("OnlyScript(hebrew) is the four Hebrew letters", gnEq, 0)
	gcR = OnlyOf(gcMixed, "S", "arabic")
	gnEq = strcmp(gcR, gcAra)
	Then("OnlyScript(arabic) is the four Arabic letters", gnEq, 0)
	gcR = OnlyOf(gcMixed, "S", "latin")
	gnNot = strcmp(gcR, gcHeb)
	Then("negative: the Latin part is not the Hebrew one", gnNot != 0, 1)
	gcR = OnlyOf(gcMixed, "S", "hebrew")
	gnNot = strcmp(gcR, gcAra)
	Then("negative: the Hebrew part is not the Arabic one", gnNot != 0, 1)
	gcR = OnlyOf(gcMixed, "S", "latin")
	gnNot = strcmp(gcR, gcMixed)
	Then("negative: the Latin part is not the whole text", gnNot != 0, 1)
	gcR = OnlyOf(gcMixed, "L", "")
	gnEq = strcmp(gcR, "abc 123")
	Then("OnlyLatin keeps the common characters: abc then a blank then 123", gnEq, 0)
	gcR = OnlyOf(gcMixed, "A", "")
	gnEq = strcmp(gcR, gcAra + "123")
	Then("OnlyArabic is the Arabic letters then 123 (the leading blank is trimmed)", gnEq, 0)
	gcR = OnlyOf(gcMixed, "L", "")
	gnNot = strcmp(gcR, "abc")
	Then("negative: OnlyLatin is NOT the same as OnlyScript(latin): it keeps the blank and the digits", gnNot != 0, 1)
	gcR = OnlyOf(gcMixed, "A", "")
	gnNot = strcmp(gcR, gcHeb)
	Then("negative: OnlyArabic holds no Hebrew letter", gnNot != 0, 1)
EndScenario()

Scenario("The name of the script is case-folded; an unknown or wrong name is told apart")
	gcA = OnlyOf(gcMixed, "S", "Latin")
	gcB = OnlyOf(gcMixed, "S", "LATIN")
	gcC = OnlyOf(gcMixed, "S", "latin")
	gcD = OnlyOf(gcMixed, "S", :Latin)
	gcE = OnlyOf(gcMixed, "S", :LATIN)
	gnEq = strcmp(gcA, "abc")
	Then("Latin gives abc", gnEq, 0)
	gnEq = strcmp(gcB, "abc")
	Then("LATIN gives abc", gnEq, 0)
	gnEq = strcmp(gcC, "abc")
	Then("latin gives abc", gnEq, 0)
	gnEq = strcmp(gcD, "abc")
	Then(":Latin gives abc", gnEq, 0)
	gnEq = strcmp(gcE, "abc")
	Then(":LATIN gives abc", gnEq, 0)
	gcR = OnlyOf(gcMixed, "S", "klingon")
	Then("an unknown script name gives an empty text, no error", gcR, "")
	gcR = OnlyOf(gcMixed, "S", "")
	Then("an empty script name gives an empty text", gcR, "")
	gcR = OnlyOf(gcMixed, "S", "greek")
	Then("a real script that the text does not use gives an empty text", gcR, "")
	gcR = OnlyOf(gcMixed, "S", 123)
	gnRaised = (left(gcR, 8) = "#RAISED ")
	Then("a number as the script name raises", gnRaised, 1)
	gnMsg = substr(gcR, "must be a string")
	Then("with a message that says what is wrong", gnMsg > 0, 1)
	gcR = OnlyOf(gcMixed, "S", "latin")
	gnRaised = (left(gcR, 8) = "#RAISED ")
	Then("negative: a valid name does not raise", gnRaised, 0)
EndScenario()

Scenario("The common characters: OnlyScript drops them, OnlyLatin and OnlyArabic keep them")
	gcTxt = "hello world, 42!"
	gcR = OnlyOf(gcTxt, "S", "latin")
	gnEq = strcmp(gcR, "helloworld")
	Then("OnlyScript(latin) of hello world, 42! drops blank, comma, digits, bang", gnEq, 0)
	gcR = OnlyOf(gcTxt, "L", "")
	gnEq = strcmp(gcR, "hello world, 42!")
	Then("OnlyLatin keeps the same text whole", gnEq, 0)
	gcR = OnlyOf(gcTxt, "S", "common")
	gnEq = strcmp(gcR, " , 42!")
	Then("OnlyScript(common) is exactly the blank, comma, digits and bang", gnEq, 0)
	gcR = OnlyOf("a" + gcGrin + "b", "S", "latin")
	gnEq = strcmp(gcR, "ab")
	Then("an emoji is common: OnlyScript(latin) of a, grin, b is ab", gnEq, 0)
	gcR = OnlyOf("a" + gcGrin + "b", "L", "")
	gnEq = strcmp(gcR, "a" + gcGrin + "b")
	Then("and OnlyLatin keeps it", gnEq, 0)
	gcR = OnlyOf("a" + gcGrin + "b", "S", "common")
	gnEq = strcmp(gcR, gcGrin)
	Then("OnlyScript(common) of it is the emoji alone", gnEq, 0)
	gcR = OnlyOf("a   " + gcHeb + "   b", "L", "")
	gnEq = strcmp(gcR, "a b")
	Then("OnlyLatin: the blanks left around a removed Hebrew word collapse into one", gnEq, 0)
	gcR = OnlyOf("a   " + gcHeb + "   b", "S", "latin")
	gnEq = strcmp(gcR, "ab")
	Then("negative: OnlyScript(latin) does not keep any blank", gnEq, 0)
	gcR = OnlyOf("one" + char(10) + gcHeb + char(10) + "two", "L", "")
	gnEq = strcmp(gcR, "one two")
	Then("OnlyLatin: line breaks collapse to a blank too", gnEq, 0)
	gcR = OnlyOf("123 !", "S", "latin")
	Then("a text of common characters only has no Latin: empty", gcR, "")
	gcR = OnlyOf("123 !", "L", "")
	Then("OnlyLatin of it is empty too, not the digits", gcR, "")
	gcR = OnlyOf("123 !", "A", "")
	Then("OnlyArabic of it is empty too", gcR, "")
	gcR = OnlyOf("123 !", "S", "common")
	gnEq = strcmp(gcR, "123 !")
	Then("while OnlyScript(common) is the text whole", gnEq, 0)
EndScenario()

Scenario("Accents: an accented letter is Latin, a combining accent follows the letter before it")
	gcR = OnlyOf("caf" + gcEacute, "S", "latin")
	gnEq = strcmp(gcR, "caf" + gcEacute)
	Then("e-acute (one code point) is Latin and stays", gnEq, 0)
	gcR = OnlyOf("cafe" + gcAcute, "S", "latin")
	gnEq = strcmp(gcR, "cafe" + gcAcute)
	Then("e then a combining accent stays together (the accent is inherited, it follows its letter)", gnEq, 0)
	gcR = OnlyOf("e" + gcAcute, "S", "inherited")
	gnEq = strcmp(gcR, gcAcute)
	Then("OnlyScript(inherited) of it is the accent alone", gnEq, 0)
	gcR = OnlyOf("e" + gcAcute, "S", "latin")
	gnNot = strcmp(gcR, "e")
	Then("negative: the accent is not lost, the result is not the bare e", gnNot != 0, 1)
	gcR = OnlyOf(gcAcute + "e", "S", "latin")
	gnEq = strcmp(gcR, "e")
	Then("an accent with nothing before it is dropped: accent then e gives e", gnEq, 0)
	gcR = OnlyOf(gcHeb + gcAcute + "a", "S", "latin")
	gnEq = strcmp(gcR, "a")
	Then("an accent after a Hebrew word goes with it (its letter is not kept): a", gnEq, 0)
	gcR = OnlyOf(gcHeb + gcAcute + "a", "S", "hebrew")
	gnEq = strcmp(gcR, gcHeb + gcAcute)
	Then("and stays with the Hebrew part", gnEq, 0)
	gcR = OnlyOf("a b" + gcAcute, "S", "latin")
	gnEq = strcmp(gcR, "ab" + gcAcute)
	Then("an accent after a letter after a dropped blank: the accent stays with b", gnEq, 0)
	gcR = OnlyOf("a " + gcAcute + "b", "S", "latin")
	gnEq = strcmp(gcR, "ab")
	Then("an accent after a dropped blank goes with the blank: ab", gnEq, 0)
	gcR = OnlyOf("a " + gcAcute + "b", "L", "")
	gnEq = strcmp(gcR, "a " + gcAcute + "b")
	Then("while OnlyLatin keeps the blank, so the accent stays with it", gnEq, 0)
	gcTxt = gcAra + gcFatha + gcAra
	gcR = OnlyOf(gcTxt, "S", "arabic")
	gnEq = strcmp(gcR, gcTxt)
	Then("an Arabic text with a diacritic (fatha) keeps its diacritic under OnlyScript(arabic)", gnEq, 0)
	gcR = OnlyOf("abc " + gcTxt + " def", "A", "")
	gnEq = strcmp(gcR, gcTxt)
	Then("and under OnlyArabic", gnEq, 0)
	gcR = OnlyOf(gcTxt, "S", "inherited")
	gnEq = strcmp(gcR, gcFatha)
	Then("OnlyScript(inherited) of it is the fatha alone", gnEq, 0)
	gcR = OnlyOf(gcAleph + gcNikud + gcBet, "S", "hebrew")
	gnEq = strcmp(gcR, gcAleph + gcNikud + gcBet)
	Then("a Hebrew point (nikud) is Hebrew in the table and stays: aleph, point, bet", gnEq, 0)
EndScenario()

Scenario("One script only, none of the script, empty, and the other scripts")
	gcR = OnlyOf("hello", "S", "latin")
	gnEq = strcmp(gcR, "hello")
	Then("a Latin-only text returns itself", gnEq, 0)
	gcR = OnlyOf(gcHeb, "S", "hebrew")
	gnEq = strcmp(gcR, gcHeb)
	Then("a Hebrew-only text returns itself", gnEq, 0)
	gcR = OnlyOf(gcAra, "A", "")
	gnEq = strcmp(gcR, gcAra)
	Then("OnlyArabic of an Arabic-only text is itself", gnEq, 0)
	gcR = OnlyOf("hello", "S", "hebrew")
	Then("negative: a Latin text has no Hebrew: empty", gcR, "")
	gcR = OnlyOf("hello", "A", "")
	Then("negative: OnlyArabic of a Latin text is empty", gcR, "")
	gcR = OnlyOf(gcAra, "L", "")
	Then("negative: OnlyLatin of an Arabic text is empty", gcR, "")
	gcR = OnlyOf("", "S", "latin")
	Then("an empty text gives an empty text (OnlyScript)", gcR, "")
	gcR = OnlyOf("", "L", "")
	Then("an empty text gives an empty text (OnlyLatin)", gcR, "")
	gcR = OnlyOf("", "A", "")
	Then("an empty text gives an empty text (OnlyArabic)", gcR, "")
	gcTxt = "a" + gcAlpha + gcDe + gcHan + gcTai + gcHeb
	gcR = OnlyOf(gcTxt, "S", "greek")
	gnEq = strcmp(gcR, gcAlpha)
	Then("greek picks the alpha", gnEq, 0)
	gcR = OnlyOf(gcTxt, "S", "cyrillic")
	gnEq = strcmp(gcR, gcDe)
	Then("cyrillic picks the de", gnEq, 0)
	gcR = OnlyOf(gcTxt, "S", "han")
	gnEq = strcmp(gcR, gcHan)
	Then("han picks the ideograph", gnEq, 0)
	gcR = OnlyOf(gcTxt, "S", "taitham")
	gnEq = strcmp(gcR, gcTai)
	Then("taitham (the engine's name for Tai Tham) picks that letter", gnEq, 0)
	gcR = OnlyOf(gcTxt, "S", "hebrew")
	gnEq = strcmp(gcR, gcHeb)
	Then("hebrew still picks the four Hebrew letters", gnEq, 0)
	gcR = OnlyOf(gcTxt, "S", "arabic")
	Then("negative: arabic finds nothing in it", gcR, "")
	gcR = OnlyOf(gcTxt, "L", "")
	gnEq = strcmp(gcR, "a")
	Then("OnlyLatin of it is a", gnEq, 0)
EndScenario()

Scenario("The partition: 30 random mixes of scripts, each part checked against a declared oracle")
	# pieces: [ text, script of the piece, 1 if it is a combining mark that follows the piece before it ]
	gaP = []
	gaP + [ "a", "latin", 0 ]
	gaP + [ "Z", "latin", 0 ]
	gaP + [ gcEacute, "latin", 0 ]
	gaP + [ gcAleph, "hebrew", 0 ]
	gaP + [ gcBet, "hebrew", 0 ]
	gaP + [ gcNikud, "hebrew", 0 ]
	gaP + [ gcAlef, "arabic", 0 ]
	gaP + [ gcBa, "arabic", 0 ]
	gaP + [ " ", "common", 0 ]
	gaP + [ "7", "common", 0 ]
	gaP + [ "!", "common", 0 ]
	gaP + [ char(10), "common", 0 ]
	gaP + [ gcGrin, "common", 0 ]
	gaP + [ gcAlpha, "greek", 0 ]
	gaP + [ gcDe, "cyrillic", 0 ]
	gaP + [ gcHan, "han", 0 ]
	gaP + [ gcAcute, "inherited", 1 ]
	gaP + [ gcFatha, "inherited", 1 ]
	gaScripts = [ "latin", "hebrew", "arabic", "common", "greek", "cyrillic", "han" ]
	gnSeed = 20260924
	gnBadStrict = 0
	gnBadKeep = 0
	gnBadSum = 0
	gnBadPartition = 0
	gnBadInh = 0
	gnRaised = 0
	gnChecks = 0
	for gnT = 1 to 30
		gnSeed = (gnSeed * 75 + 74) % 65537
		gnLen = 6 + (gnSeed % 19)
		gcTxt = ""
		gaEff = []
		gaTxt = []
		gcPrevEff = ""
		for gnK = 1 to gnLen
			gnSeed = (gnSeed * 75 + 74) % 65537
			gnPick = 1 + (gnSeed % len(gaP))
			gcPiece = gaP[gnPick][1]
			gcScript = gaP[gnPick][2]
			gnMark = gaP[gnPick][3]
			if gnMark = 1
				if gcPrevEff = ""
					gcEff = "orphan"
				else
					gcEff = gcPrevEff
				ok
			else
				gcEff = gcScript
			ok
			gcPrevEff = gcEff
			if gcEff = "orphan"
				gcPrevEff = "orphan"
			ok
			gcTxt += gcPiece
			gaEff + gcEff
			gaTxt + [ gcPiece, gcScript, gnMark ]
		next
		# orphans chain: a mark after an orphan mark is an orphan too
		gnOrph2 = 0
		for gnK = 1 to len(gaEff)
			if gaEff[gnK] = "orphan"
				gnOrph2++
			ok
		next
		# strict parts against the oracle
		gnSum = 0
		for gnS = 1 to len(gaScripts)
			gcWant = ""
			for gnK = 1 to len(gaEff)
				if gaEff[gnK] = gaScripts[gnS]
					gcWant += gaTxt[gnK][1]
				ok
			next
			gcGot = OnlyOf(gcTxt, "S", gaScripts[gnS])
			if left(gcGot, 8) = "#RAISED "
				gnRaised++
			ok
			gnDiff = strcmp(gcGot, gcWant)
			if gnDiff != 0
				gnBadStrict++
				? "    differs: text " + gnT + " script " + gaScripts[gnS]
			ok
			gnChecks++
			gnSum += StzLen(gcGot)
		next
		# inherited, strict: exactly the marks
		gcWant = ""
		for gnK = 1 to len(gaTxt)
			if gaTxt[gnK][3] = 1
				gcWant += gaTxt[gnK][1]
			ok
		next
		gcGot = OnlyOf(gcTxt, "S", "inherited")
		gnDiff = strcmp(gcGot, gcWant)
		if gnDiff != 0
			gnBadInh++
		ok
		gnChecks++
		# the keep-common forms against the oracle
		for gnS = 1 to 2
			if gnS = 1
				gcName = "latin"
				gcKind = "L"
			else
				gcName = "arabic"
				gcKind = "A"
			ok
			gnHas = 0
			gcJoin = ""
			for gnK = 1 to len(gaEff)
				if gaEff[gnK] = gcName
					gnHas = 1
				ok
				if gaEff[gnK] = gcName or gaEff[gnK] = "common"
					gcJoin += gaTxt[gnK][1]
				ok
			next
			gcWant = ""
			if gnHas = 1
				gcWant = CollapseBlanks(gcJoin)
			ok
			gcGot = OnlyOf(gcTxt, gcKind, "")
			if left(gcGot, 8) = "#RAISED "
				gnRaised++
			ok
			gnDiff = strcmp(gcGot, gcWant)
			if gnDiff != 0
				gnBadKeep++
				? "    keep form differs: text " + gnT + " " + gcName
			ok
			gnChecks++
		next
		# independent accounting: strict parts of every script but inherited + orphans = whole text
		gnTotal = StzLen(gcTxt)
		if gnSum + gnOrph2 != gnTotal
			gnBadSum++
		ok
		# and the three scripts of the register plus everything else
		gnL = StzLen(OnlyOf(gcTxt, "S", "latin"))
		gnH = StzLen(OnlyOf(gcTxt, "S", "hebrew"))
		gnA = StzLen(OnlyOf(gcTxt, "S", "arabic"))
		gnRest = 0
		for gnK = 1 to len(gaEff)
			if gaEff[gnK] != "latin" and gaEff[gnK] != "hebrew" and gaEff[gnK] != "arabic"
				gnRest++
			ok
		next
		if gnL + gnH + gnA + gnRest != gnTotal
			gnBadPartition++
		ok
	next
	Then("30 texts, every script's strict part equals the declared oracle (" + gnChecks + " comparisons)", gnBadStrict, 0)
	Then("OnlyScript(inherited) is exactly the marks of each text", gnBadInh, 0)
	Then("OnlyLatin and OnlyArabic equal the oracle (common kept, blanks collapsed, empty without the script)", gnBadKeep, 0)
	Then("the lengths of all strict parts but inherited, plus the orphan marks, add up to the whole text", gnBadSum, 0)
	Then("latin + hebrew + arabic + all the rest add up to the whole text", gnBadPartition, 0)
	Then("nothing raised", gnRaised, 0)
	gnOracleNotEmpty = (gnChecks > 200)
	Then("the oracle really ran (more than 200 comparisons)", gnOracleNotEmpty, 1)
EndScenario()

Scenario("The oracle can fail: a deliberately wrong expectation is caught (control)")
	gcGot = OnlyOf(gcMixed, "S", "latin")
	gnDiff = strcmp(gcGot, "abc ")
	Then("abc with a trailing blank differs from the Latin part", gnDiff != 0, 1)
	gnDiff = strcmp(gcGot, "ABC")
	Then("a differing letter case is told apart by strcmp", gnDiff != 0, 1)
	gnDiff = strcmp(CollapseBlanks("  a   b  "), "a b")
	Then("the oracle's own blank collapser gives a b", gnDiff, 0)
	gnDiff = strcmp(CollapseBlanks("  a   b  "), "a  b")
	Then("and not two blanks", gnDiff != 0, 1)
EndScenario()

Scenario("A hundred thousand characters: exact result, a few seconds at most")
	gnReps = 6667
	gcBig = ""
	gaRep = []
	for gnI = 1 to gnReps
		gaRep + gcMixed
	next
	gcBig = StzJoinWith(gaRep, "")
	gnBigLen = StzLen(gcBig)
	Then("the text has 100,005 characters", gnBigLen, 100005)
	gnT0 = clock()
	gcR = OnlyOf(gcBig, "S", "hebrew")
	gnSecs = (clock() - gnT0) / clockspersecond()
	gnLenR = StzLen(gcR)
	Then("OnlyScript(hebrew) keeps 4 x 6667 characters", gnLenR, 26668)
	gaRep = []
	for gnI = 1 to gnReps
		gaRep + gcHeb
	next
	gcWant = StzJoinWith(gaRep, "")
	gnDiff = strcmp(gcR, gcWant)
	Then("and they are the Hebrew letters in order", gnDiff, 0)
	gnQuick = (gnSecs < 6)
	Then("in under 6 seconds (measured " + gnSecs + " s)", gnQuick, 1)
	gnT0 = clock()
	gcR = OnlyOf(gcBig, "L", "")
	gnSecs2 = (clock() - gnT0) / clockspersecond()
	gnLenR = StzLen(gcR)
	Then("OnlyLatin keeps abc, a blank and 123 per repetition, 7 x 6667 characters", gnLenR, 46669)
	gnQuick = (gnSecs2 < 6)
	Then("in under 6 seconds (measured " + gnSecs2 + " s)", gnQuick, 1)
	gnSlow = (gnSecs > 60)
	Then("negative: the lookups are not the 15-minute kind", gnSlow, 0)
EndScenario()

Scenario("A call of 100 public methods on a small mixed text raises nothing (the sweep that found the three)")
	gcTxt = "Hello world. " + gcHeb + " " + gcAra + " 123!" + char(10) + "Bye world, " + gcEacute + "t" + gcEacute + " ok." + char(10) + char(10) + "Last line world"
	gaCalls = [ "Abbreviated(8)", "Abbreviate(8)", "BlankLinesRemoved()", "Chars()", "CollapseSpaces()", "CollapseSpacesQ()", "ContainsArabicScript()", "ContainsEachWord(['world'])", "ContainsLatinScript()", "ContainsScript('latin')", "ContainsWord('world')", "Content()", "Copy()", "CountLines()", "CountParagraphs()", "CountScripts()", "CountSentences()", "CountWords()", "DeduplicateLines()", "DiacriticsRemoved()", "DuplicateWordsRemoved()", "FirstLine()", "FirstParagraph()", "FirstSentence()", "FirstWord()", "Initials()", "IsArabicScript()", "IsArabicWord()", "IsCommonScript()", "IsEmpty()", "IsHanScript()", "IsHybridScript()", "IsInheritedScript()", "IsLatinScript()", "IsLatinWord()", "IsWord()", "LastLine()", "LastParagraph()", "LastSentence()", "LastWord()", "Language()", "Lines()", "LinesDeduplicated()", "LinesNumbered()", "Lowercase()", "MostFrequentWord()", "MostFrequentWords(2)", "NMostFrequentWords(2)", "NormalizeSpaces()", "NthLine(2)", "NthParagraph(1)", "NthSentence(1)", "NthWord(2)", "NumberLines()", "NumberOfChars()", "NumberOfChars2()", "NumberOfDistinctScripts()", "NumberOfLines()", "NumberOfParagraphs()", "NumberOfScripts()", "NumberOfSentences()", "NumberOfUniqueWords()", "NumberOfWords()", "OnlyArabic()", "OnlyLatin()", "OnlyScript('latin')", "OnlyScript('hebrew')", "Paragraphs()", "RemoveBlankLines()", "RemoveDiacritics()", "RemoveDuplicateWords()", "RemoveNthWord(2)", "ReverseWords()", "Script()", "ScriptIs('hybrid')", "Scripts()", "Sentences()", "SetLanguage('en')", "Simplified()", "Simplify()", "SortWords()", "SpacesCollapsed()", "SpacesNormalized()", "SwapWords(1, 2)", "Text()", "ToSentenceCase()", "ToSlug()", "ToStzString()", "TruncateWords(3)", "Uppercase()", "UniqueWords()", "WordFrequency('world')", "Words()", "WordsAndTheirCounts()", "WordsAndTheirPositions()", "WordsExcept(['world'])", "WordsPositions()", "WordsReversed()", "WordsSorted()", "WordsTruncated(3)" ]
	gnErr = 0
	gcFirstErr = ""
	for gnI = 1 to len(gaCalls)
		gcOut = Probe(gcTxt, gaCalls[gnI])
		if left(gcOut, 8) = "#RAISED "
			gnErr++
			if gcFirstErr = ""
				gcFirstErr = gaCalls[gnI] + " " + gcOut
			ok
		ok
	next
	Then("no call of the " + len(gaCalls) + " raised (first one that did: '" + gcFirstErr + "')", gnErr, 0)
	gcOut = Probe(gcTxt, "NoSuchMethodAtAll()")
	gnRaised = (left(gcOut, 8) = "#RAISED ")
	Then("control: a method the class does not have is reported as raised", gnRaised, 1)
	gcOut = Probe(gcTxt, "OnlyHebrew()")
	gnRaised = (left(gcOut, 8) = "#RAISED ")
	Then("OnlyHebrew is not a method of the class (OnlyScript with hebrew is the way)", gnRaised, 1)
EndScenario()

Summary()

# --- helpers (at the end: top-level code after a func becomes part of it) ---

func OnlyOf(cText, cKind, cArg)
	cRes = ""
	try
		oT = new stzStringText(cText)
		if cKind = "S"
			cRes = oT.OnlyScript(cArg)
		but cKind = "L"
			cRes = oT.OnlyLatin()
		else
			cRes = oT.OnlyArabic()
		ok
	catch
		cRes = "#RAISED " + cCatchError
	done
	return cRes

func Probe(cText, cCall)
	cRes = ""
	try
		oP = new stzStringText(cText)
		xR = eval("return oP." + cCall)
		cRes = "ok"
	catch
		cRes = "#RAISED " + cCatchError
	done
	return cRes

func CollapseBlanks(cText)
	cOut = ""
	nPendingBlank = 0
	nSeen = 0
	nLen = len(cText)
	for nI = 1 to nLen
		nCode = ascii(cText[nI])
		if nCode = 32 or nCode = 10 or nCode = 9 or nCode = 13
			nPendingBlank = 1
		else
			if nPendingBlank = 1 and nSeen = 1
				cOut += " "
			ok
			cOut += cText[nI]
			nSeen = 1
			nPendingBlank = 0
		ok
	next
	return cOut
