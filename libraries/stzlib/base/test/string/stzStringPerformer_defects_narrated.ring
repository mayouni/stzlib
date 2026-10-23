load "../../stzBase.ring"
load "../_narrated.ring"

# stzStringPerformer -- the three rows of the register (DEFECTS.md): Content, Perform and PerformOn.
#
# Before: Perform('upper(@char)') on 'abc' left 'abc' -- the list the engine call returned was
# dropped and never written back -- and PerformOn([1], 'upper(@char)') left 'abc' too: the positions
# were not even read. Content, which returns the text the performer holds, therefore never showed
# a change, because nothing changed it. Now:
#   Perform     the text becomes the results of the expression, written one after the other: exactly
#               the joining of the list Yield gives for the same expression. A number is written as
#               its digits, an empty result removes the character, a longer result makes the text
#               longer, and a text the evaluator does not accept leaves the text as it is
#   PerformOn   the same, for the characters at the given positions only. Positions are 1-based;
#               their order and repeats do not matter (each chosen character is replaced once);
#               0, negative and past-the-end positions are skipped, exactly as YieldOn skips them;
#               a value that is not a list raises, as YieldOn does
#   Content     shows the text as it stands after either
# PerformW and YieldW, which called a FindCharsW the class never had (error R14), now ask the held
# string for the positions.
#
# Where the expression is evaluated: by the ENGINE (StzEngineStringMapChars, expr.zig), never by Ring
# eval. The class source holds no eval, and the helpers on the path (_StzStripBraces,
# _StzNormalizeCharCond, _StzLowerWPredicates) rewrite text only. The last scenario proves it with a
# canary: a global that an injected text would set, across a hostile corpus, and that must stay 0.
# The scenario before it proves the canary CAN be set (a control), so a 0 is a finding and not a
# blind instrument. No real system command, file write or network is in the corpus.
#
# Independent references: the literal expected texts of the tables below (written from the contract,
# not computed by the class), a join and a rebuild written here and not taken from the class, and
# Yield / YieldOn, which already worked. Texts are compared byte for byte with strcmp, because the
# Ring comparison of two texts ignores letter case and would let upper and lower pass as the same.
# Accented, Hebrew, emoji and combining texts are built from char codes and never printed.
# Run from inside test/string.

gcEacute = char(195) + char(169)
gcBigEacute = char(195) + char(137)
gcAleph = char(215) + char(144)
gcBet = char(215) + char(145)
gcGrin = char(240) + char(159) + char(152) + char(128)
gcAcute = char(204) + char(129)
gnCanary = 0

# [ label, text, expression, expected text after Perform ]
gaPerf = []
gaPerf + [ "upper", "abc", "upper(@char)", "ABC" ]
gaPerf + [ "lower", "ABC", "lower(@char)", "abc" ]
gaPerf + [ "doubling", "abc", "@char + @char", "aabbcc" ]
gaPerf + [ "position", "abc", "@i", "123" ]
gaPerf + [ "byte length", "abc", "len(@char)", "111" ]
gaPerf + [ "phrase upper", "hello world", "upper(@char)", "HELLO WORLD" ]
gaPerf + [ "digit test gives 0 and 1", "a1b2", "isDigit(@char)", "0101" ]
gaPerf + [ "if replaces digits", "a1b2", "if(isDigit(@char), '#', @char)", "a#b#" ]
gaPerf + [ "empty result removes every character", "abc", "''", "" ]
gaPerf + [ "empty result removes one", "abc", "if(@char = 'b', '', @char)", "ac" ]
gaPerf + [ "repeat grows the text", "abc", "repeat(@char, 3)", "aaabbbccc" ]
gaPerf + [ "suffix", "abc", "@char + '-'", "a-b-c-" ]
gaPerf + [ "constant", "abc", "'x'", "xxx" ]
gaPerf + [ "arithmetic", "abc", "@i * 2", "246" ]
gaPerf + [ "modulo", "abcd", "@i % 2", "1010" ]
gaPerf + [ "trim removes a space", "a b", "trim(@char)", "ab" ]
gaPerf + [ "unknown function leaves the text", "abc", "nosuch(@char)", "abc" ]
gaPerf + [ "empty expression leaves the text", "abc", "", "abc" ]
gaPerf + [ "semicolon leaves the text", "abc", "upper(@char);x", "abc" ]
gaPerf + [ "empty text stays empty", "", "upper(@char)", "" ]
gaPerf + [ "one letter", "x", "upper(@char)", "X" ]
gaPerf + [ "swap case", "aAbB", "if(isUppercase(@char), lower(@char), upper(@char))", "AaBb" ]
gaPerf + [ "e-acute doubled", gcEacute + "a", "@char + @char", gcEacute + gcEacute + "aa" ]
gaPerf + [ "aleph with a suffix", gcAleph + "b", "@char + '!'", gcAleph + "!b!" ]
gaPerf + [ "emoji doubled", gcGrin + "z", "@char + @char", gcGrin + gcGrin + "zz" ]
gaPerf + [ "braces are stripped", "abc", "{ upper(@char) }", "ABC" ]
gaPerf + [ "number of items", "abc", "@numberofitems", "333" ]
gaPerf + [ "and of two tests", "abc", "isLetter(@char) and @i > 1", "011" ]
gaPerf + [ "equality test", "ab", "@char = 'a'", "10" ]
gaPerf + [ "max of two numbers", "abc", "max(@i, 2)", "223" ]
gaPerf + [ "left and right", "abc", "left(@char, 1) + right(@char, 1)", "aabbcc" ]
gaPerf + [ "whole-number division", "abc", "@i / 2", "011" ]
gaPerf + [ "digits join as text", "12", "@char + @char", "1122" ]
gaPerf + [ "accented letter is not changed by upper", gcEacute + "a", "upper(@char)", gcEacute + "A" ]
gaPerf + [ "unicode text unchanged by identity", gcAleph + gcBet + gcGrin + "e" + gcAcute, "@char", gcAleph + gcBet + gcGrin + "e" + gcAcute ]

# [ label, text, positions, expression, expected text after PerformOn ]
gaOn = []
gaOn + [ "first", "abcde", [ 1 ], "upper(@char)", "Abcde" ]
gaOn + [ "last", "abcde", [ 5 ], "upper(@char)", "abcdE" ]
gaOn + [ "middle", "abcde", [ 3 ], "upper(@char)", "abCde" ]
gaOn + [ "first and last", "abcde", [ 1, 5 ], "upper(@char)", "AbcdE" ]
gaOn + [ "last and first (unsorted)", "abcde", [ 5, 1 ], "upper(@char)", "AbcdE" ]
gaOn + [ "repeated position", "abcde", [ 2, 2, 2 ], "upper(@char)", "aBcde" ]
gaOn + [ "repeated position, growing result", "abc", [ 2, 2 ], "@char + @char", "abbc" ]
gaOn + [ "no positions", "abcde", [], "upper(@char)", "abcde" ]
gaOn + [ "zero is skipped", "abcde", [ 0 ], "upper(@char)", "abcde" ]
gaOn + [ "past the end is skipped", "abcde", [ 6 ], "upper(@char)", "abcde" ]
gaOn + [ "negative is skipped", "abcde", [ -1 ], "upper(@char)", "abcde" ]
gaOn + [ "mixed valid and invalid", "abcde", [ 0, 6, -3, 2 ], "upper(@char)", "aBcde" ]
gaOn + [ "every position", "abcde", [ 1, 2, 3, 4, 5 ], "upper(@char)", "ABCDE" ]
gaOn + [ "unsorted run", "abcde", [ 3, 1, 2 ], "upper(@char)", "ABCde" ]
gaOn + [ "growth at two positions", "abcde", [ 2, 4 ], "@char + @char", "abbcdde" ]
gaOn + [ "position as the result", "abcde", [ 2, 4 ], "@i", "a2c4e" ]
gaOn + [ "position is in the whole text", "abcde", [ 3 ], "@i", "ab3de" ]
gaOn + [ "removal at odd positions", "abcde", [ 1, 3, 5 ], "''", "bd" ]
gaOn + [ "growth at the first two", "abc", [ 1, 2 ], "@char + @char", "aabbc" ]
gaOn + [ "unknown function leaves the text", "abc", [ 1, 2 ], "nosuch(@char)", "abc" ]
gaOn + [ "empty text", "", [ 1 ], "upper(@char)", "" ]
gaOn + [ "e-acute chosen", gcEacute + "bc", [ 1 ], "@char + @char", gcEacute + gcEacute + "bc" ]
gaOn + [ "letter after e-acute chosen", gcEacute + "bc", [ 2 ], "upper(@char)", gcEacute + "Bc" ]
gaOn + [ "aleph chosen", "a" + gcAleph + "c", [ 2 ], "@char + @char", "a" + gcAleph + gcAleph + "c" ]
gaOn + [ "emoji chosen", "a" + gcGrin + "c", [ 2 ], "'-'", "a-c" ]
gaOn + [ "letter after emoji chosen", "a" + gcGrin + "c", [ 3 ], "upper(@char)", "a" + gcGrin + "C" ]
gaOn + [ "combining accent chosen", "e" + gcAcute + "x", [ 2 ], "''", "ex" ]
gaOn + [ "digits", "a1b2", [ 2, 4 ], "@char + @char", "a11b22" ]

# --------------------------------------------------------------------------------------------------

Scenario("The register's examples: Perform and PerformOn changed nothing, Content showed nothing")
	gO = new stzStringPerformer("abc")
	gO.Perform("upper(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "ABC")
	Then("Perform of upper(@char) on abc gives ABC", gnSame, 0)
	gnNotOld = strcmp(gcC, "abc")
	Then("and no longer abc (case counted: strcmp, not =)", gnNotOld != 0, 1)
	gO = new stzStringPerformer("abc")
	gO.PerformOn([ 1 ], "upper(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "Abc")
	Then("PerformOn of [1] with upper(@char) on abc gives Abc", gnSame, 0)
	gnNotAll = strcmp(gcC, "ABC")
	Then("only the first letter changed, not all three", gnNotAll != 0, 1)
	gO = new stzStringPerformer("abc")
	gO.PerformOn([ 1 ], "upper(@char)")
	gO.PerformOn([ 3 ], "upper(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "AbC")
	Then("two PerformOn in a row add up: AbC", gnSame, 0)
EndScenario()

Scenario("Content shows the CURRENT text, never a copy kept from the start")
	gO = new stzStringPerformer("abc")
	gcBefore = gO.Content()
	gnSame = strcmp(gcBefore, "abc")
	Then("before anything is done Content is the text given", gnSame, 0)
	gO.Perform("@char + @char")
	gcAfter1 = gO.Content()
	gnSame = strcmp(gcAfter1, "aabbcc")
	Then("after Perform it is the rewritten text", gnSame, 0)
	gO.PerformOn([ 1 ], "upper(@char)")
	gcAfter2 = gO.Content()
	gnSame = strcmp(gcAfter2, "Aabbcc")
	Then("after PerformOn on top of that it is the newest text", gnSame, 0)
	gnChars = gO.NumberOfChars()
	Then("NumberOfChars follows the rewritten text (6)", gnChars, 6)
	gnEmpty = gO.IsEmpty()
	Then("and IsEmpty answers about it: not empty", gnEmpty, 0)
	gO.Perform("''")
	gcAfter3 = gO.Content()
	Then("a Perform that removes every character leaves an empty Content", gcAfter3, "")
	gnEmpty = gO.IsEmpty()
	Then("IsEmpty is then true", gnEmpty, 1)
	gnChars = gO.NumberOfChars()
	Then("and NumberOfChars is 0", gnChars, 0)
	gO1 = new stzStringPerformer("abc")
	gO2 = new stzStringPerformer("abc")
	gO1.Perform("upper(@char)")
	gcOther = gO2.Content()
	gnSame = strcmp(gcOther, "abc")
	Then("another performer on the same text is not touched", gnSame, 0)
EndScenario()

Scenario("A stzString given to the constructor is never changed by Perform")
	gS = new stzString("abc")
	gO = new stzStringPerformer(gS)
	gO.Perform("upper(@char)")
	gO.PerformOn([ 2 ], "@char + @char")
	gcMine = gO.Content()
	gnSame = strcmp(gcMine, "ABBC")
	Then("the performer holds the rewritten text ABBC", gnSame, 0)
	gcTheirs = gS.Content()
	gnSame = strcmp(gcTheirs, "abc")
	Then("the stzString object still holds abc", gnSame, 0)
	gnNot = strcmp(gcTheirs, "ABBC")
	Then("and not the rewritten text", gnNot != 0, 1)
	gcStill = gS.Content()
	gnLen = gS.NumberOfChars()
	Then("it is still usable afterwards (3 characters)", gnLen, 3)
EndScenario()

Scenario("Perform against Yield: the text is the joining of the list Yield gives, over a table")
	gnRows = len(gaPerf)
	gnLiteralBad = 0
	gnConsistentBad = 0
	gnConsistent = 0
	gnRejected = 0
	gnChanged = 0
	for gnI = 1 to gnRows
		gcTxt = gaPerf[gnI][2]
		gcExp = gaPerf[gnI][3]
		gcWant = gaPerf[gnI][4]
		gOp = new stzStringPerformer(gcTxt)
		gOy = new stzStringPerformer(gcTxt)
		gOp.Perform(gcExp)
		gcGot = gOp.Content()
		gaY = gOy.Yield(gcExp)
		# the reference: Yield's list joined here; a rejected expression (an empty list on a
		# non-empty text) leaves the text as it was
		if len(gaY) = 0 and len(gcTxt) > 0
			gcRef = gcTxt
			gnRejected++
		else
			gcRef = JoinResults(gaY)
			if strcmp(gcRef, gcTxt) != 0 gnChanged++ ok
		ok
		if strcmp(gcGot, gcWant) != 0
			gnLiteralBad++
			? "    Perform differs from the literal on: " + gaPerf[gnI][1]
		ok
		if strcmp(gcGot, gcRef) != 0
			gnConsistentBad++
			? "    Perform differs from the joined Yield on: " + gaPerf[gnI][1]
		else
			gnConsistent++
		ok
	next
	gnEnough = (gnRows >= 25)
	Then("the table holds at least 25 pairs", gnEnough, 1)
	Then("Perform equals the literal expected text on every pair", gnLiteralBad, 0)
	Then("Perform equals the joined Yield on every pair", gnConsistentBad, 0)
	Then("the number of consistent pairs is the number of pairs", gnConsistent, gnRows)
	gnMix = (gnRejected >= 3 and gnChanged >= 20)
	Then("the table has pairs that rewrite the text and pairs the evaluator rejects, so a constant cannot pass", gnMix, 1)
EndScenario()

Scenario("PerformOn against YieldOn: the table of positions, edges included")
	gnRows = len(gaOn)
	gnLiteralBad = 0
	gnConsistentBad = 0
	gnConsistent = 0
	gnSkipRows = 0
	for gnI = 1 to gnRows
		gcTxt = gaOn[gnI][2]
		gaPos = gaOn[gnI][3]
		gcExp = gaOn[gnI][4]
		gcWant = gaOn[gnI][5]
		gOp = new stzStringPerformer(gcTxt)
		gOy = new stzStringPerformer(gcTxt)
		gOp.PerformOn(gaPos, gcExp)
		gcGot = gOp.Content()
		gcRef = RebuildOn(gOy, gcTxt, gaPos, gcExp)
		if strcmp(gcGot, gcWant) != 0
			gnLiteralBad++
			? "    PerformOn differs from the literal on: " + gaOn[gnI][1]
		ok
		if strcmp(gcGot, gcRef) != 0
			gnConsistentBad++
			? "    PerformOn differs from the rebuild with YieldOn on: " + gaOn[gnI][1]
		else
			gnConsistent++
		ok
	next
	gnEnough = (gnRows >= 25)
	Then("the table holds at least 25 rows", gnEnough, 1)
	Then("PerformOn equals the literal expected text on every row", gnLiteralBad, 0)
	Then("PerformOn equals the rebuild from Yield and YieldOn on every row", gnConsistentBad, 0)
	Then("the number of consistent rows is the number of rows", gnConsistent, gnRows)
EndScenario()

Scenario("PerformOn leaves the other characters alone and agrees with YieldOn on which positions count")
	gO = new stzStringPerformer("abcde")
	gaYo = gO.YieldOn([ 0, 6, -3, 2, 2 ], "upper(@char)")
	gnYo = len(gaYo)
	Then("YieldOn gives a result for the two entries that are the position 2 and skips the rest", gnYo, 2)
	gO.PerformOn([ 0, 6, -3, 2, 2 ], "upper(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "aBcde")
	Then("PerformOn changes exactly the character at 2", gnSame, 0)
	gO = new stzStringPerformer("abcde")
	gO.PerformOn([ 2 ], "upper(@char)")
	gcOnlyTwo = gO.Content()
	gnNot = strcmp(gcOnlyTwo, "ABCDE")
	Then("and not the whole text (a negative sibling to the whole-text Perform)", gnNot != 0, 1)
	gnLen = gO.NumberOfChars()
	Then("one result per character keeps the length at 5", gnLen, 5)
	# a value that is not a list raises, as YieldOn does
	gcErrYo = ""
	try
		gaX = gO.YieldOn(2, "upper(@char)")
	catch
		gcErrYo = cCatchError
	done
	gcErrOn = ""
	try
		gO.PerformOn(2, "upper(@char)")
	catch
		gcErrOn = cCatchError
	done
	gnYoRaised = (gcErrYo != "")
	gnOnRaised = (gcErrOn != "")
	Then("YieldOn with a number instead of a list raises", gnYoRaised, 1)
	Then("PerformOn with a number instead of a list raises too", gnOnRaised, 1)
	gcErrOk = ""
	try
		gO.PerformOn([ 1 ], "upper(@char)")
	catch
		gcErrOk = cCatchError
	done
	Then("while a list does not raise", gcErrOk, "")
	gcAfter = gO.Content()
	gnSame = strcmp(gcAfter, "AB" + "cde")
	Then("the refused call changed nothing and the next one worked: ABcde", gnSame, 0)
EndScenario()

Scenario("The W forms: they raised R14 for want of a FindCharsW; now the condition picks the characters")
	gO = new stzStringPerformer("aBcD")
	gaW = gO.YieldW("isUppercase(@char)", "lower(@char)")
	gnOk = SameTexts(gaW, [ "b", "d" ])
	Then("YieldW gives the results for the capitals only: b and d", gnOk, 1)
	gaW2 = gO.YieldW("isLowercase(@char)", "upper(@char)")
	gnOk = SameTexts(gaW2, [ "A", "C" ])
	Then("and for the small letters only: A and C", gnOk, 1)
	gO.PerformW("isUppercase(@char)", "lower(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "abcd")
	Then("PerformW lowers the capitals in place: abcd", gnSame, 0)
	gO = new stzStringPerformer("aBcD")
	gO.PerformW("isLowercase(@char)", "@char + @char")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "aaBccD")
	Then("PerformW with a growing result: aaBccD", gnSame, 0)
	gO = new stzStringPerformer("abc")
	gO.PerformW("isDigit(@char)", "upper(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "abc")
	Then("a condition no character meets leaves the text as it is", gnSame, 0)
	gO = new stzStringPerformer("abc")
	gO.PerformW("@char = 'b'", "'X'")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "aXc")
	Then("a condition on one character: aXc", gnSame, 0)
EndScenario()

Scenario("Every public method once, on a small text")
	gO = new stzStringPerformer("ab")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "ab")
	Then("Content: ab", gnSame, 0)
	gnN = gO.NumberOfChars()
	Then("NumberOfChars: 2", gnN, 2)
	gnE = gO.IsEmpty()
	Then("IsEmpty: 0", gnE, 0)
	gaY = gO.Yield("upper(@char)")
	gnOk = SameTexts(gaY, [ "A", "B" ])
	Then("Yield: A, B", gnOk, 1)
	gaY = gO.YieldOn([ 2 ], "upper(@char)")
	gnOk = SameTexts(gaY, [ "B" ])
	Then("YieldOn: B", gnOk, 1)
	gaY = gO.YieldW("@char = 'a'", "upper(@char)")
	gnOk = SameTexts(gaY, [ "A" ])
	Then("YieldW: A", gnOk, 1)
	gO.Perform("@char + '.'")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "a.b.")
	Then("Perform: a.b.", gnSame, 0)
	gO = new stzStringPerformer("ab")
	gO.PerformOn([ 1 ], "upper(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "Ab")
	Then("PerformOn: Ab", gnSame, 0)
	gO = new stzStringPerformer("ab")
	gO.PerformW("@char = 'b'", "upper(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "aB")
	Then("PerformW: aB", gnSame, 0)
	gO = new stzStringPerformer("ab")
	gOq = gO.PerformQ("upper(@char)")
	gcC = gOq.Content()
	gnSame = strcmp(gcC, "AB")
	Then("PerformQ returns the performer, rewritten: AB", gnSame, 0)
	gOq = gO.PerformOnQ([ 1 ], "lower(@char)")
	gcC = gOq.Content()
	gnSame = strcmp(gcC, "aB")
	Then("PerformOnQ returns the performer, rewritten: aB", gnSame, 0)
	gOq = gO.PerformWQ("@char = 'B'", "lower(@char)")
	gcC = gOq.Content()
	gnSame = strcmp(gcC, "ab")
	Then("PerformWQ returns the performer, rewritten: ab", gnSame, 0)
	gcErr = ""
	try
		gOx = new stzStringPerformer(5)
	catch
		gcErr = cCatchError
	done
	gnRaised = (gcErr != "")
	Then("a number given to the constructor raises", gnRaised, 1)
	gcErr = ""
	try
		gOx = new stzStringPerformer("ok")
	catch
		gcErr = cCatchError
	done
	Then("a text does not", gcErr, "")
EndScenario()

Scenario("Characters, not bytes: accented, Hebrew, emoji and combining texts")
	gcAcc = gcEacute + "a"
	gO = new stzStringPerformer(gcAcc)
	gO.Perform("upper(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, gcEacute + "A")
	Then("upper on e-acute then a: the engine upper changes the ASCII letter A only (e-acute stays)", gnSame, 0)
	gnBig = strcmp(gcC, gcBigEacute + "A")
	Then("it does not give E-acute: the engine's upper and lower are ASCII-only (reported, not hidden)", gnBig != 0, 1)
	gnL = gO.NumberOfChars()
	Then("the text is still 2 characters", gnL, 2)
	gcHeb = gcAleph + gcBet + gcAleph + gcBet
	gO = new stzStringPerformer(gcHeb)
	gO.Perform("lower(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, gcHeb)
	Then("a Hebrew text through lower comes back byte for byte", gnSame, 0)
	gnL = gO.NumberOfChars()
	Then("with 4 characters in 8 bytes", gnL, 4)
	gO = new stzStringPerformer(gcHeb)
	gO.Perform("@char + @char")
	gnL = gO.NumberOfChars()
	Then("a result of two characters grows the Hebrew text from 4 to 8 characters", gnL, 8)
	gcC = gO.Content()
	gnSame = strcmp(gcC, gcAleph + gcAleph + gcBet + gcBet + gcAleph + gcAleph + gcBet + gcBet)
	Then("each letter doubled in place", gnSame, 0)
	gO = new stzStringPerformer(gcHeb)
	gO.PerformOn([ 2, 3 ], "@char + @char")
	gcC = gO.Content()
	gnSame = strcmp(gcC, gcAleph + gcBet + gcBet + gcAleph + gcAleph + gcBet)
	Then("PerformOn on two Hebrew letters doubles those two only", gnSame, 0)
	gO = new stzStringPerformer("a" + gcGrin + "b")
	gO.Perform("@char")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "a" + gcGrin + "b")
	Then("an emoji (4 bytes) through the identity comes back byte for byte", gnSame, 0)
	gnL = gO.NumberOfChars()
	Then("a text of 3 characters", gnL, 3)
	gO.Perform("len(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "141")
	Then("len counts bytes, so the emoji gives 4: 141", gnSame, 0)
	gO = new stzStringPerformer("e" + gcAcute + "x")
	gnL = gO.NumberOfChars()
	Then("a combining sequence is two characters (e, accent) plus x: 3", gnL, 3)
	gO.Perform("@char + @char")
	gnL = gO.NumberOfChars()
	Then("doubled, 6 characters", gnL, 6)
	gO = new stzStringPerformer("e" + gcAcute + "x" + gcGrin)
	gO.Perform("if(len(@char) > 1, '', @char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "ex")
	Then("removing every multi-byte character leaves ex", gnSame, 0)
	gO = new stzStringPerformer(gcGrin + gcGrin + gcGrin)
	gO.PerformOn([ 2 ], "'-'")
	gcC = gO.Content()
	gnSame = strcmp(gcC, gcGrin + "-" + gcGrin)
	Then("the middle of three emoji replaced by a dash", gnSame, 0)
	gnL = gO.NumberOfChars()
	Then("the length in characters is kept when the result is one character: 3", gnL, 3)
EndScenario()

Scenario("A rejected expression leaves the text as it was, and a rejected one is not an empty result")
	gO = new stzStringPerformer("abc")
	gO.Perform("nosuch(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "abc")
	Then("an unknown function: the text stays abc (it is not emptied)", gnSame, 0)
	gaY = gO.Yield("nosuch(@char)")
	gnY = len(gaY)
	Then("and Yield gives no results for it", gnY, 0)
	gO.Perform("")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "abc")
	Then("an empty expression: abc", gnSame, 0)
	gO.PerformOn([ 1, 2 ], "nosuch(@char)")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "abc")
	Then("PerformOn with an unknown function: abc", gnSame, 0)
	gO.Perform("''")
	gcC = gO.Content()
	Then("while an accepted expression whose result is empty does empty the text", gcC, "")
	gO.Perform("upper(@char)")
	gcC = gO.Content()
	Then("an empty text stays empty", gcC, "")
EndScenario()

Scenario("The length limit: 2000 characters are accepted, 2001 are not (the engine overflows its stack on a deeply nested text)")
	gcPad2000 = "upper(@char)" + copy(" ", 1988)
	gcPad2001 = "upper(@char)" + copy(" ", 1989)
	gnL2000 = len(gcPad2000)
	gnL2001 = len(gcPad2001)
	Then("the first text is 2000 characters", gnL2000, 2000)
	Then("the second is 2001", gnL2001, 2001)
	gO = new stzStringPerformer("abc")
	gaY = gO.Yield(gcPad2000)
	gnOk = SameTexts(gaY, [ "A", "B", "C" ])
	Then("2000 characters are evaluated: A, B, C", gnOk, 1)
	gaY = gO.Yield(gcPad2001)
	gnY = len(gaY)
	Then("2001 characters are refused: no results", gnY, 0)
	gO.Perform(gcPad2001)
	gcC = gO.Content()
	gnSame = strcmp(gcC, "abc")
	Then("and Perform leaves the text as it is", gnSame, 0)
	gO.Perform(gcPad2000)
	gcC = gO.Content()
	gnSame = strcmp(gcC, "ABC")
	Then("while the 2000-character one rewrites it: ABC", gnSame, 0)
	gcDeep = "upper(" + copy("(", 900) + "@char" + copy(")", 900) + ")"
	gO = new stzStringPerformer("ab")
	gaY = gO.Yield(gcDeep)
	gnOk = SameTexts(gaY, [ "A", "B" ])
	Then("a text nested 900 deep, under the limit, is evaluated: A, B", gnOk, 1)
EndScenario()

Scenario("CONTROL: the canary can be set -- a Ring eval inside a function reaches the global")
	gnCanary = 0
	RunCanaryControl()
	Then("the control sets the canary to 1, so a 0 later is a finding and not a blind instrument", gnCanary, 1)
	gnCanary = 0
	gcSrc = read("../../string/stzStringPerformer.ring")
	gnHasEval = substr(gcSrc, "eval(")
	Then("the class source holds no eval( anywhere", gnHasEval, 0)
	gnHasEvalSp = substr(gcSrc, "eval (")
	Then("nor eval followed by a space", gnHasEvalSp, 0)
	gnHasExec = substr(gcSrc, "SystemCmd") + substr(gcSrc, "system(") + substr(gcSrc, "Exec(")
	Then("nor a system call", gnHasExec, 0)
	gnEngine = substr(gcSrc, "StzEngineStringMapChars")
	gnIsThere = (gnEngine > 0)
	Then("the evaluation goes through StzEngineStringMapChars, the engine", gnIsThere, 1)
EndScenario()

Scenario("HOSTILE corpus: no injected text runs; the canary stays 0")
	gnCanary = 0
	gaHostile = HostileCorpus()
	gnCount = len(gaHostile)
	gnEnough = (gnCount >= 20)
	Then("the corpus holds at least 20 strings", gnEnough, 1)
	gnTextBad = 0
	gnCrash = 0
	gnAcceptedLiteral = 0
	for gnI = 1 to gnCount
		gcX = gaHostile[gnI][2]
		gcMustReject = gaHostile[gnI][3]
		gO = new stzStringPerformer("abc")
		gO2 = new stzStringPerformer("abc")
		gaY = gO.Yield(gcX)
		gaYo = gO.YieldOn([ 1, 2 ], gcX)
		gO.Perform(gcX)
		gO2.PerformOn([ 2 ], gcX)
		gcAfterPerform = gO.Content()
		gcAfterOn = gO2.Content()
		gO3 = new stzStringPerformer("abc")
		gO3.PerformW(gcX, "upper(@char)")
		gO3.PerformW("@char = 'a'", gcX)
		gaYw = gO3.YieldW(gcX, "upper(@char)")
		if gcMustReject = 1
			# a rejected text changes nothing
			if strcmp(gcAfterPerform, "abc") != 0 or strcmp(gcAfterOn, "abc") != 0
				gnTextBad++
				? "    a text that must be rejected changed the text: " + gaHostile[gnI][1]
			ok
			if len(gaY) != 0
				gnTextBad++
				? "    a text that must be rejected gave results: " + gaHostile[gnI][1]
			ok
		else
			gnAcceptedLiteral++
		ok
	next
	Then("the canary is still 0 after every method on every string", gnCanary, 0)
	Then("every string that must be rejected was rejected (text unchanged, no results)", gnTextBad, 0)
	gnSome = (gnAcceptedLiteral >= 3 and gnAcceptedLiteral < gnCount)
	Then("some strings are accepted as plain literals (a quoted text is a value, never run) and most are not", gnSome, 1)
	# the injected assignment inside a quoted literal is only a value: it is written, not run
	gO = new stzStringPerformer("ab")
	gO.Perform("'; gnCanary=1; '")
	gcC = gO.Content()
	gnSame = strcmp(gcC, "; gnCanary=1; ; gnCanary=1; ")
	Then("a quoted text holding an assignment is written into the text as plain characters", gnSame, 0)
	Then("and the canary is still 0", gnCanary, 0)
	# a condition is judged by the same evaluator
	gO = new stzStringPerformer("abc")
	gO.PerformW("@char = 'a'; gnCanary=1", "upper(@char)")
	gcC = gO.Content()
	Then("a condition with a statement separator is not run either", gnCanary, 0)
	# the instrument reads a long hostile text without a fault
	gcLong = "upper(@char)" + copy(" ; gnCanary=1", 4000)
	gO = new stzStringPerformer("abc")
	gO.Perform(gcLong)
	gcC = gO.Content()
	gnSame = strcmp(gcC, "abc")
	Then("a very long hostile text is rejected and the text stays abc", gnSame, 0)
	Then("the canary is still 0 after it", gnCanary, 0)
EndScenario()

Summary()

# --------------------------------------------------------------------------------------------------
# helpers: functions go at the END of the file (top-level code after a func belongs to it)

# the list joined as text, written here and independent of the class
func JoinResults(paList)
	gcJoin = ""
	gnJn = len(paList)
	for gnJi = 1 to gnJn
		gcJoin += "" + paList[gnJi]
	next
	return gcJoin

# the text rebuilt with Yield and YieldOn only: the distinct valid positions in ascending order
# take YieldOn's results; every other character is taken from Yield("@char"); a rejected
# expression leaves the text as it was
func RebuildOn(poPerf, pcText, paPos, pcExpr)
	gaRbAll = poPerf.Yield(pcExpr)
	if len(gaRbAll) = 0
		return pcText
	ok
	gnRbN = len(gaRbAll)
	gaRbChars = poPerf.Yield("@char")
	gaRbSel = []
	for gnRbI = 1 to gnRbN
		gaRbSel + 0
	next
	gnRbP = len(paPos)
	for gnRbI = 1 to gnRbP
		gnRbV = paPos[gnRbI]
		if gnRbV >= 1 and gnRbV <= gnRbN
			gaRbSel[gnRbV] = 1
		ok
	next
	gaRbPositions = []
	for gnRbI = 1 to gnRbN
		if gaRbSel[gnRbI] = 1
			gaRbPositions + gnRbI
		ok
	next
	gaRbYo = poPerf.YieldOn(gaRbPositions, pcExpr)
	gcRb = ""
	gnRbK = 0
	for gnRbI = 1 to gnRbN
		if gaRbSel[gnRbI] = 1
			gnRbK++
			gcRb += "" + gaRbYo[gnRbK]
		else
			gcRb += gaRbChars[gnRbI]
		ok
	next
	return gcRb

func SameTexts(paA, paB)
	if len(paA) != len(paB)
		return 0
	ok
	gnSt = len(paA)
	for gnSi = 1 to gnSt
		if strcmp("" + paA[gnSi], "" + paB[gnSi]) != 0
			return 0
		ok
	next
	return 1

# a Ring eval inside a function assigning the global canary: proves the instrument can fire
func RunCanaryControl()
	eval("gnCanary = 1")

# [ label, text, must be rejected (1) or is a plain literal that is accepted (0) ]
# Texts built with char codes where they look like something else; none runs a real command.
func HostileCorpus()
	gaHc = []
	gcFullSemi = char(239) + char(188) + char(155)
	gcGreekQ = char(205) + char(190)
	gcFullU = char(239) + char(188) + char(181)
	gcFullOpen = char(239) + char(188) + char(136)
	gcFullClose = char(239) + char(188) + char(137)
	gcCyrA = char(208) + char(176)
	gcNl = char(10)
	gcCr = char(13)
	gcNul = char(0)
	gaHc + [ "semicolon then assignment", "upper(@char);gnCanary=1", 1 ]
	gaHc + [ "newline then assignment", "upper(@char)" + gcNl + "gnCanary=1", 1 ]
	gaHc + [ "crlf then spaced assignment", "upper(@char)" + gcCr + gcNl + "gnCanary = 1", 1 ]
	gaHc + [ "eval with double quotes", 'eval("gnCanary=1")', 1 ]
	gaHc + [ "eval with single quotes", "eval('gnCanary=1')", 1 ]
	gaHc + [ "load word", 'load "x.ring"', 1 ]
	gaHc + [ "the word system as a bare name", "upper(@char) and system", 1 ]
	gaHc + [ "call word", "call gnCanary", 1 ]
	gaHc + [ "quote break-out, single", "'; gnCanary=1; '", 0 ]
	gaHc + [ "quote break-out, double (a quoted text)", '"); gnCanary=1; ("', 0 ]
	gaHc + [ "hash comment", "upper(@char)#", 1 ]
	gaHc + [ "block comment", "upper(@char) /* gnCanary=1 */", 1 ]
	gaHc + [ "NUL then assignment", "upper(@char)" + gcNul + ";gnCanary=1", 1 ]
	gaHc + [ "unbalanced open", "upper(@char", 1 ]
	gaHc + [ "unbalanced close", "upper(@char))", 1 ]
	gaHc + [ "bare assignment", "gnCanary = 1", 1 ]
	gaHc + [ "return word", "return 1", 1 ]
	gaHc + [ "bye word", "bye", 1 ]
	gaHc + [ "separator then bye", "upper(@char); bye", 1 ]
	gaHc + [ "see word", "see 'x'", 1 ]
	gaHc + [ "fullwidth semicolon look-alike", "upper(@char)" + gcFullSemi + "gnCanary=1", 1 ]
	gaHc + [ "greek question mark look-alike", "upper(@char)" + gcGreekQ + "gnCanary=1", 1 ]
	gaHc + [ "fullwidth P in the function name", gcFullU + "pper(@char)", 1 ]
	gaHc + [ "cyrillic a in the variable name", "upper(@ch" + gcCyrA + "r)", 1 ]
	gaHc + [ "fullwidth parentheses", "upper" + gcFullOpen + "@char" + gcFullClose, 1 ]
	gaHc + [ "double-quoted assignment text", '"gnCanary=1"', 0 ]
	gaHc + [ "single-quoted call text", "'eval(1)'", 0 ]
	gaHc + [ "braces with separator", "{ upper(@char); gnCanary=1 }", 1 ]
	gaHc + [ "trailing separator", "upper(@char) ; ", 1 ]
	gaHc + [ "member access", "@char.gnCanary", 1 ]
	gaHc + [ "the word this", "this", 1 ]
	gaHc + [ "a lone at sign", "@", 1 ]
	gaHc + [ "twenty thousand open parentheses (crashed the engine before the length limit)", copy("(", 20000), 1 ]
	gaHc + [ "twenty thousand minus signs", copy("-", 20000) + "1", 1 ]
	gaHc + [ "twenty thousand nots", copy("not ", 20000) + "true", 1 ]
	gaHc + [ "deep nesting with a separator", "upper(" + copy("(", 3000) + "@char" + copy(")", 3000) + ");gnCanary=1", 1 ]
	gaHc + [ "unknown function holding a call word", "len(@char) + sys_call('x')", 1 ]
	return gaHc
