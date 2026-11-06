load "../../stzBase.ring"
load "../_narrated.ring"

# stzStringList (base/string/stzStringList.ring) -- the two register rows kept as a guard now that the class answers.
# Run from inside this folder:
#     rnxc stzStringList_defects_narrated.ring
# It needs the engine's string and list modules only: no network, no file, no child process.
#
# THE HISTORY: the register said
#   SortBy    "@item is not defined here and raises R24, and a key that is text raises R41 because keys are compared
#             with a greater-than, so only numeric keys such as len(@string) work"
#   Matches   "the old comment says it returns the strings that match, but it answers one verdict for the whole list"
#   Measured under rnxc, before the change: SortBy already took @item and @string alike (the keys come from the W
#   engine since the R17 work) and a text key already sorted, with Ring++'s `>` on text -- so no R24 and no R41. What
#   was left behind: an insertion sort (25 million key comparisons for 5000 strings), a text order that depended on
#   what `>` does with text on the VM that runs it (Ring 1.27 raised R41 there), a key of mixed kinds compared with
#   whatever `>` made of a number against a text, and a doc block still warning of defects the code no longer had.
#   Matches answers a verdict, nobody called it for the strings, and the one sibling that reads like it --
#   stzString.MatchesRegex -- is a verdict too. The comment was the defect.
#
# THE RULES the guard holds the class to:
#   SortBy(pcExpr)   sorts the strings in place by a KEY computed for each one by the W engine, never run as code:
#     @string and @item both stand for the current string, @i and @position for its place; {  } around it are dropped.
#     The keys are all NUMBERS (sorted by value) or all TEXTS (sorted by code point, case-sensitive: capitals before
#     lowercase, a prefix before the longer text, exactly as SortInAscending orders the strings). The sort is STABLE:
#     strings with equal keys keep their order. It is done by the engine's text sort and Ring's numeric sort, not by
#     a loop of key comparisons.
#     A mix of numbers and texts, a key that is a list, and a text key holding the control character 1 are refused by
#     the named error "SortBy: ..."; a condition that needs Ring logic, an empty expression and an expression that is not a text
#     are refused as they were; the list is untouched after a refusal. A list of fewer than two strings is
#     left as it is without reading the expression. len() in the W engine counts BYTES; Q(@string).NumberOfChars()
#     counts characters.
#   Matches(pcRegexPatt)   TRUE (1) when EVERY string matches the pattern as a whole, FALSE (0) when one does not; an
#     empty list is TRUE. It answers a verdict, never the strings. A pattern that is not a text, and an empty
#     pattern, raise a named error; a pattern that is not a valid expression matches nothing.
#   StringsMatching(pcRegexPatt)   the strings that match the pattern as a whole, in their order; [] when none does.
#     Matches(p) is TRUE exactly when StringsMatching(p) holds every string.
#   Nothing else moves: StringsW and Yield answer what they answered.
#
# The text of a result is compared EXACTLY (SlSame): Ring's = on text ignores case, and the whole point of a text
# key is that A comes before a. Every positive carries a negative sibling. ASCII only on the console.

$cSlRaised = ""
$vSlGot = ""
$oSl = ""
$aSlBase = [ "pear", "fig", "apple", "kiwi", "Banana", "cherry", "date" ]

# ---------------------------------------------------------------------------------------------------------------
Scenario("1. SortBy: numeric keys, @string and @item alike")
try
	Given("seven fruit")
	Then("by len(@string): fig first, then the four-letter words in their order", SlSame(SlSorted($aSlBase, "len(@string)"),
		@@([ "fig", "pear", "kiwi", "date", "apple", "Banana", "cherry" ])), 1)
	Then("by len(@item): the same", SlSame(SlSorted($aSlBase, "len(@item)"),
		@@([ "fig", "pear", "kiwi", "date", "apple", "Banana", "cherry" ])), 1)
	Then("by -len(@string): longest first, ties in their order", SlSame(SlSorted($aSlBase, "-len(@string)"),
		@@([ "Banana", "cherry", "apple", "pear", "kiwi", "date", "fig" ])), 1)
	Then("by arithmetic on the key", SlSame(SlSorted($aSlBase, "len(@string) * 2 + 1"),
		@@([ "fig", "pear", "kiwi", "date", "apple", "Banana", "cherry" ])), 1)
	Then("braces around the key are dropped", SlSame(SlSorted($aSlBase, "{ len(@string) }"),
		@@([ "fig", "pear", "kiwi", "date", "apple", "Banana", "cherry" ])), 1)
	Then("by @i: the order does not change", SlSame(SlSorted($aSlBase, "@i"), @@($aSlBase)), 1)
	Then("by @position: the order does not change", SlSame(SlSorted($aSlBase, "@position"), @@($aSlBase)), 1)
	Then("by a verdict, 1 for the words that start with a: the others keep their order, apple goes last",
		SlSame(SlSorted($aSlBase, "Q(@string).StartsWith('a')"), @@([ "pear", "fig", "kiwi", "Banana", "cherry", "date", "apple" ])), 1)
	Then("NEGATIVE: the result is not the strings' own ascending order", SlSameQ(SlSorted($aSlBase, "len(@string)"),
		@@([ "Banana", "apple", "cherry", "date", "fig", "kiwi", "pear" ])), 0)
	Then("a numeric key sorts by value: 1, 9, 10, 100", SlSame(SlSorted([ "10", "9", "100", "1" ], "number(@string)"),
		@@([ "1", "9", "10", "100" ])), 1)
catch
	SlAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("2. SortBy: text keys, by code point, case-sensitive")
try
	Given("the same fruit, with a capital in Banana")
	Then("by @string: the capital first", SlSame(SlSorted($aSlBase, "@string"),
		@@([ "Banana", "apple", "cherry", "date", "fig", "kiwi", "pear" ])), 1)
	Then("by @item: the same", SlSame(SlSorted($aSlBase, "@item"),
		@@([ "Banana", "apple", "cherry", "date", "fig", "kiwi", "pear" ])), 1)
	Then("by upper(@string): the capital no longer decides", SlSame(SlSorted($aSlBase, "upper(@string)"),
		@@([ "apple", "Banana", "cherry", "date", "fig", "kiwi", "pear" ])), 1)
	Then("by lower(@item): the same", SlSame(SlSorted($aSlBase, "lower(@item)"),
		@@([ "apple", "Banana", "cherry", "date", "fig", "kiwi", "pear" ])), 1)
	Then("NEGATIVE: not a case-folded order", SlSameQ(SlSorted($aSlBase, "@string"),
		@@([ "apple", "Banana", "cherry", "date", "fig", "kiwi", "pear" ])), 0)
	Then("capitals and lowercase together: A B a b", SlSame(SlSorted([ "b", "A", "a", "B" ], "@string"), @@([ "A", "B", "a", "b" ])), 1)
	Then("a text key sorts as text: 1, 10, 100, 9", SlSame(SlSorted([ "10", "9", "100", "1" ], "@string"),
		@@([ "1", "10", "100", "9" ])), 1)
	Then("a prefix comes before the longer text", SlSame(SlSorted([ "ab", "a", "abc", "", "b", "aa" ], "@string"),
		@@([ "", "a", "aa", "ab", "abc", "b" ])), 1)
	Then("NEGATIVE: not the order the strings came in", SlSameQ(SlSorted([ "ab", "a", "abc", "", "b", "aa" ], "@string"),
		@@([ "ab", "a", "abc", "", "b", "aa" ])), 0)
	Then("equal text keys keep the strings' order: by the first letter",
		SlSame(SlSorted([ "banana", "apple", "avocado", "blueberry", "apricot", "cherry" ], "left(@string, 1)"),
		@@([ "apple", "avocado", "apricot", "banana", "blueberry", "cherry" ])), 1)
	Then("...and the sibling, on the keys' reverse: the same strings by their last letter, ties in order",
		SlSame(SlSorted([ "ab", "cb", "aa", "ca", "bb" ], "right(@string, 1)"), @@([ "aa", "ca", "ab", "cb", "bb" ])), 1)
	Then("Hebrew, Arabic, accents by code point (UTF-8 bytes in order)", SlSame(SlSorted([ "שלום", "a", "مرحبا", "b", "éé" ], "@string"),
		@@([ "a", "b", "éé", "שלום", "مرحبا" ])), 1)
	Then("a character count through the object: a, éé, three emoji, שלום, مرحبا",
		SlSame(SlSorted([ "שלום", "a", "مرحبا", "😀😀😀", "éé" ], "Q(@string).NumberOfChars()"),
		@@([ "a", "éé", "😀😀😀", "שלום", "مرحبا" ])), 1)
	Then("len() counts bytes: the three emoji (12 bytes) go after مرحبا (10)", SlSame(SlSorted([ "שלום", "a", "مرحبا", "😀😀😀", "éé" ], "len(@string)"),
		@@([ "a", "éé", "שלום", "مرحبا", "😀😀😀" ])), 1)
catch
	SlAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("3. SortBy is stable and agrees with a sort written apart from the library")
try
	Given("300 strings whose lengths and first letters repeat")
	$aSlBig = SlMakeBig(300)
	$oSl = new stzStringList($aSlBig)
	$oSl.SortBy("len(@string)")
	Then("by length: the same 300 strings come back", len($oSl.Content()), 300)
	Then("by length: the order is the stable order, written here by a nested loop",
		SlSame(@@($oSl.Content()), @@(SlRefByLength($aSlBig))), 1)
	$oSl = new stzStringList($aSlBig)
	$oSl.SortBy("left(@string, 2)")
	Then("by the first two letters: the stable order, written here by a nested loop",
		SlSame(@@($oSl.Content()), @@(SlRefByPrefix($aSlBig))), 1)
	Then("NEGATIVE: the by-length order is not the by-prefix order", SlSameQ(@@(SlRefByLength($aSlBig)), @@(SlRefByPrefix($aSlBig))), 0)
	Given("all keys equal")
	Then("the strings do not move", SlSame(SlSorted($aSlBase, "5"), @@($aSlBase)), 1)
	Then("...for a text key too", SlSame(SlSorted($aSlBase, "'k'"), @@($aSlBase)), 1)
catch
	SlAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("4. SortBy refuses by name what it cannot sort, and leaves the list as it was")
try
	Given("keys that are a number for one string and a text for another")
	$oSl = new stzSlMixedKeys([ "x", "y", "z" ])
	cMixed = SlRaised('$oSl.SortBy("whatever")')
	Then("a mixed key raises", len(cMixed) > 0, 1)
	Then("...by the name SortBy", WsHasSl(cMixed, "SortBy:"), 1)
	Then("...saying numbers and texts", WsHasSl(cMixed, "number") and WsHasSl(cMixed, "text"), 1)
	Then("NEGATIVE: it is not R41", WsHasSl(cMixed, "R41"), 0)
	Then("NEGATIVE: it is not R24", WsHasSl(cMixed, "R24"), 0)
	Then("the list is as it was", SlSame(@@($oSl.Content()), @@([ "x", "y", "z" ])), 1)
	Given("a key that is a list")
	$oSl = new stzSlListKeys([ "x", "y", "z" ])
	cList = SlRaised('$oSl.SortBy("whatever")')
	Then("it raises by the name SortBy", WsHasSl(cList, "SortBy:"), 1)
	Then("the list is as it was", SlSame(@@($oSl.Content()), @@([ "x", "y", "z" ])), 1)
	Given("a text key holding the control character 1, which the sort uses to tell a key from its position")
	$oSl = new stzStringList([ "a" + char(1) + "b", "c", "a" ])
	cCtl = SlRaised('$oSl.SortBy("@string")')
	Then("it raises by the name SortBy", WsHasSl(cCtl, "SortBy:"), 1)
	Then("the list is as it was", SlSame(@@($oSl.Content()), @@([ "a" + char(1) + "b", "c", "a" ])), 1)
	Given("expressions the W engine cannot judge")
	$oSl = new stzStringList($aSlBase)
	Then("a function of the caller's is refused, as it was", WsHasSl(SlRaised('$oSl.SortBy("foo(@string)")'), "needs Ring logic"), 1)
	Then("an empty expression is refused, as it was", WsHasSl(SlRaised('$oSl.SortBy("")'), "an expression is required"), 1)
	Then("a blank expression is refused, as it was", WsHasSl(SlRaised('$oSl.SortBy("   ")'), "an expression is required"), 1)
	cNum = SlRaised('$oSl.SortBy(5)')
	Then("an expression that is not a text is refused by name", WsHasSl(cNum, "Incorrect param type!"), 1)
	Then("...naming the parameter", WsHasSl(cNum, "pcExpr"), 1)
	Then("NEGATIVE: not R21 or R41", WsHasSl(cNum, "R21") or WsHasSl(cNum, "R41"), 0)
	Then("the list is as it was after every refusal", SlSame(@@($oSl.Content()), @@($aSlBase)), 1)
	Given("code smuggled into the key")
	cMark = "sl_smuggled_" + len(@@($aSlBase))
	Then("a second statement is refused, not run", len(SlRaised('$oSl.SortBy("len(@string) $vSlGot = ' + "'" + cMark + "'" + '")')) > 0, 1)
	Then("...and it did not run", SlSame($vSlGot, ""), 1)
catch
	SlAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("5. SortBy: sizes, the chained form, the sibling class")
try
	Given("an empty list and a list of one")
	$oSl = new stzStringList([])
	$oSl.SortBy("len(@string)")
	Then("an empty list stays empty", len($oSl.Content()), 0)
	$oSl = new stzStringList([ "solo" ])
	$oSl.SortBy("len(@string)")
	Then("a list of one stays", SlSame(@@($oSl.Content()), @@([ "solo" ])), 1)
	Then("a list of two is sorted", SlSame(SlSorted([ "bb", "a" ], "len(@string)"), @@([ "a", "bb" ])), 1)
	Then("...and left alone when sorted", SlSame(SlSorted([ "a", "bb" ], "len(@string)"), @@([ "a", "bb" ])), 1)
	Given("the chained form")
	$oSl = new stzStringList($aSlBase)
	oSame = $oSl.SortByQ("len(@string)")
	aSame = oSame.Content()
	Then("SortByQ gives the same object back, sorted: fig first", aSame[1], "fig")
	Then("...sorted", SlSame(@@(oSame.Content()), @@([ "fig", "pear", "kiwi", "date", "apple", "Banana", "cherry" ])), 1)
	Given("the other name of the class")
	$oSl = new stzListOfStrings($aSlBase)
	$oSl.SortBy("@item")
	Then("a stzListOfStrings sorts alike", SlSame(@@($oSl.Content()), @@([ "Banana", "apple", "cherry", "date", "fig", "kiwi", "pear" ])), 1)
	Given("5000 strings, keys all different")
	$aSlLong = []
	for nSl = 1 to 5000
		$aSlLong + ("s" + ((nSl * 7919) % 5000) + "z")
	next
	$oSl = new stzStringList($aSlLong)
	nT = clock()
	$oSl.SortBy("@string")
	nMs = clock() - nT
	Then("they come back sorted by text: the first", $oSl.Content()[1], "s0z")
	Then("...and the whole list is the order of Ring's own sort of the strings", SlSame(@@($oSl.Content()), @@(sort($aSlLong))), 1)
	? "      (5000 strings by a text key: " + nMs + " clock ticks)"
catch
	SlAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("6. Matches answers a verdict")
try
	Given("strings and patterns")
	Then("a. matches ab and ac as wholes", SlMatches([ "ab", "ac" ], "a."), 1)
	Then("a does not match them as wholes", SlMatches([ "ab", "ac" ], "a"), 0)
	Then("one failing string makes it FALSE", SlMatches([ "ab", "xc" ], "a."), 0)
	Then("an empty list is TRUE", SlMatches([], "a."), 1)
	Then("an empty list is TRUE for any pattern", SlMatches([], "zzz"), 1)
	Then("the case counts: AB is not a.", SlMatches([ "AB" ], "a."), 0)
	Then("a pattern with a class: [a-z]+ holds for lowercase only", SlMatches([ "abc", "xyz" ], "[a-z]+"), 1)
	Then("...and not when a capital is in", SlMatches([ "abc", "Abc" ], "[a-z]+"), 0)
	Then("Hebrew and Arabic letters match \p{L}+", SlMatches([ "שלום", "مرحبا" ], "\p{L}+"), 1)
	Then("digits: \d+ on 12 and 345", SlMatches([ "12", "345" ], "\d+"), 1)
	Then("...and not on 12 and a5", SlMatches([ "12", "a5" ], "\d+"), 0)
	Then("an accent: é+ on éé and é", SlMatches([ "éé", "é" ], "é+"), 1)
	Then("the whole string must match, not a part: ^a is not ab", SlMatches([ "ab", "ax" ], "^a"), 0)
	Then("the empty string matches .*", SlMatches([ "x", "" ], "^.*$"), 1)
	Then("a pattern that is no valid expression matches nothing", SlMatches([ "ab" ], "("), 0)
	Then("the answer is a number, 1 or 0, never a list", isNumber(SlMatchesRaw([ "ab", "ac" ], "a.")) and not isList(SlMatchesRaw([ "ab", "ac" ], "a.")), 1)
	Then("NEGATIVE: not the strings that match", SlSameQ(@@(SlMatchesRaw([ "ab", "ac", "xc" ], "a.")), @@([ "ab", "ac" ])), 0)
	cEmpty = SlRaised('$vSlGot = new stzStringList([ "ab" ]).Matches("")')
	Then("an empty pattern raises by name", WsHasSl(cEmpty, "non-empty pattern"), 1)
	cNum = SlRaised('$vSlGot = new stzStringList([ "ab" ]).Matches(5)')
	Then("a pattern that is not a text raises by name", WsHasSl(cNum, "Incorrect param type!"), 1)
	Then("NEGATIVE: an empty list does not build the pattern, so an empty pattern on it is TRUE", SlMatches([], ""), 1)
catch
	SlAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("7. StringsMatching answers the strings")
try
	Given("strings and patterns")
	Then("a. keeps ab and ac, in order", SlSame(@@(SlStringsMatching([ "ab", "xc", "ac", "a" ], "a.")), @@([ "ab", "ac" ])), 1)
	Then("nothing matching answers an empty list", SlSame(@@(SlStringsMatching([ "ab", "xc" ], "zz")), @@([])), 1)
	Then("an empty list answers an empty list", SlSame(@@(SlStringsMatching([], "a.")), @@([])), 1)
	Then("the whole string must match", SlSame(@@(SlStringsMatching([ "ab", "a", "ba" ], "a")), @@([ "a" ])), 1)
	Then("the case counts: AB is out, aB is in", SlSame(@@(SlStringsMatching([ "ab", "AB", "aB" ], "a.")), @@([ "ab", "aB" ])), 1)
	Then("Hebrew letters match \p{L}+ and a digit string does not",
		SlSame(@@(SlStringsMatching([ "שלום", "12", "مرحبا" ], "\p{L}+")), @@([ "שלום", "مرحبا" ])), 1)
	Then("the duplicates stay", SlSame(@@(SlStringsMatching([ "ab", "ab", "x" ], "a.")), @@([ "ab", "ab" ])), 1)
	Then("the list itself is not changed", SlSame(@@(SlKept([ "ab", "xc", "ac" ], "a.")), @@([ "ab", "xc", "ac" ])), 1)
	Then("Matches is TRUE exactly when every string is kept", SlMatches([ "ab", "ac" ], "a.") and len(SlStringsMatching([ "ab", "ac" ], "a.")) = 2, 1)
	Then("...and FALSE when one is left out", SlMatches([ "ab", "xc" ], "a.") = 0 and len(SlStringsMatching([ "ab", "xc" ], "a.")) = 1, 1)
	Then("a pattern that is no valid expression keeps nothing", len(SlStringsMatching([ "ab" ], "(")), 0)
	cEmpty = SlRaised('$vSlGot = new stzStringList([ "ab" ]).StringsMatching("")')
	Then("an empty pattern raises by name", WsHasSl(cEmpty, "non-empty pattern"), 1)
	cNum = SlRaised('$vSlGot = new stzStringList([ "ab" ]).StringsMatching(5)')
	Then("a pattern that is not a text raises by name", WsHasSl(cNum, "Incorrect param type!"), 1)
catch
	SlAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("8. the neighbours did not move")
try
	Given("the conditions of StringsW and Yield")
	$oSl = new stzStringList($aSlBase)
	Then("StringsW by @string", SlSame(@@($oSl.StringsW("len(@string) = 4")), @@([ "pear", "kiwi", "date" ])), 1)
	Then("StringsW by @item", SlSame(@@($oSl.StringsW("len(@item) = 4")), @@([ "pear", "kiwi", "date" ])), 1)
	Then("Yield lines up with the list", SlSame(@@($oSl.Yield("len(@string) = 4")), @@([ 1, 0, 0, 1, 0, 0, 1 ])), 1)
	Then("a condition that cannot be judged is false, not an error", SlSame(@@($oSl.StringsW("foo(@string)")), @@([])), 1)
	Then("the list is as it was", SlSame(@@($oSl.Content()), @@($aSlBase)), 1)
	Then("SortInAscending still orders by code point", SlSame(@@($oSl.SortedInAscending()),
		@@([ "Banana", "apple", "cherry", "date", "fig", "kiwi", "pear" ])), 1)
catch
	SlAbort()
done
EndScenario()

Summary()

# ---------------------------------------------------------------------------------------------------------------
# helpers: every name a function reads is a $global (Rule A)

# an EXACT, case-sensitive comparison of two texts through their hex: Ring's = on text ignores case
func SlSame(a, b)
	if isString(a) and isString(b)
		if str2hex(a) = str2hex(b)  return 1  ok
	ok
	? "      (exact compare failed)  got hex [" + left(str2hex("" + a), 100) + "]  wanted hex [" + left(str2hex("" + b), 100) + "]"
	return 0

# the same, quietly: for the negative siblings, which are expected to differ
func SlSameQ(a, b)
	if isString(a) and isString(b)
		if str2hex(a) = str2hex(b)  return 1  ok
	ok
	return 0

# the text form of the list a SortBy leaves
func SlSorted(aList, cExpr)
	$oSl = new stzStringList(aList)
	$oSl.SortBy(cExpr)
	return @@($oSl.Content())

func SlMatches(aList, cPat)
	return SlMatchesRaw(aList, cPat)

func SlMatchesRaw(aList, cPat)
	$oSl = new stzStringList(aList)
	return $oSl.Matches(cPat)

func SlStringsMatching(aList, cPat)
	$oSl = new stzStringList(aList)
	return $oSl.StringsMatching(cPat)

# the list after StringsMatching ran on it
func SlKept(aList, cPat)
	$oSl = new stzStringList(aList)
	$vSlGot = $oSl.StringsMatching(cPat)
	return $oSl.Content()

# 1 when every string is not after its next
func SlInOrder(aList)
	nLen = len(aList)
	for nK = 2 to nLen
		if str2hex(aList[nK - 1]) > str2hex(aList[nK])  return 0  ok
	next
	return 1

# the text of the error a statement raises, "" when it raises nothing
func SlRaised(cCode)
	$cSlRaised = ""
	try
		eval(cCode)
	catch
		$cSlRaised = cCatchError
	done
	return $cSlRaised

func WsHasSl(cHay, cNeedle)
	if StzFindFirst(cNeedle, cHay) > 0  return 1  ok
	return 0

func SlAbort()
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++

# 300 strings: a run of x, y or z of length 1 to 5, then a letter group of 0 to 5 and the number, so lengths and
# two-letter prefixes repeat
func SlMakeBig(nCount)
	aOut = []
	cLetters = "xyzxyz"
	for nK = 1 to nCount
		nRun = ((nK * 7) % 5) + 1
		cItem = ""
		for nR = 1 to nRun
			cItem += cLetters[((nK + nR) % 3) + 1]
		next
		aOut + (cItem + "-" + nK)
	next
	return aOut

# the strings by length, ties in their order: for each length from the least to the greatest, the strings of
# that length in the order they came in
func SlRefByLength(aList)
	nLen = len(aList)
	aOut = []
	nMin = 0
	for nPass = 1 to nLen
		nBest = -1
		for nK = 1 to nLen
			nL = len(aList[nK])
			if nL > nMin and (nBest = -1 or nL < nBest)  nBest = nL  ok
		next
		if nBest = -1  exit  ok
		for nK = 1 to nLen
			if len(aList[nK]) = nBest  aOut + aList[nK]  ok
		next
		nMin = nBest
	next
	return aOut

# the same by the first two letters: the distinct prefixes ascending by their hex, the strings of each in order
func SlRefByPrefix(aList)
	nLen = len(aList)
	aPre = []
	for nK = 1 to nLen
		cP = left(aList[nK], 2)
		bSeen = 0
		for nJ = 1 to len(aPre)
			if aPre[nJ] = cP  bSeen = 1  exit  ok
		next
		if bSeen = 0  aPre + cP  ok
	next
	aPre = sort(aPre)
	aOut = []
	for nJ = 1 to len(aPre)
		for nK = 1 to nLen
			if left(aList[nK], 2) = aPre[nJ]  aOut + aList[nK]  ok
		next
	next
	return aOut

# a list of strings whose keys are, by a seam the class offers, a number and two texts
class stzSlMixedKeys from stzStringList

	def _SortKeys(pcExpr)
		return [ 1, "b", 3 ]

# ...and keys of which one is a list
class stzSlListKeys from stzStringList

	def _SortKeys(pcExpr)
		return [ 1, [ 2 ], 3 ]
