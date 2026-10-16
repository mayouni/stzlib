load "../../stzBase.ring"
load "../_narrated.ring"

# stzRegex -- the defect register, one scenario per family, each fact worked out by hand.
# Run from inside test/regex.
#
# Hand-checked facts the scenarios rest on (positions are 1-based BYTE positions: the engine counts
# bytes, so one accented letter is two):
#   \d on "1234" has four matches starting at 1, 2, 3, 4 -- a match may start right where the last ended
#   "12 345 6": the digit runs start at 1, 4 and 8
#   "éaéé": é takes bytes 1-2, a is byte 3, é takes 4-5, the last é 6-7, so é starts at 1, 4, 6
#   "שלום 12 34": four Hebrew letters take 8 bytes, the space is byte 9, "12" starts at 10, "34" at 13
#   ((x)(y)(z)) holds one bracket with three inside it: the nesting is 2 deep although 4 brackets match
#   (a(b(c)d)e) nests 3 deep; ((a)(b(c))) nests 3 deep
#
# FIXED   : FindMatches (+ aliases, MatchesZ, FindMatchesZZ, MatchesZZ -- the same skipped character),
#           FindCapture (follows FindMatchesZZ), HasGroups (now a fact about the PATTERN), FindPartialMatch,
#           PartialMatchLength, RecursiveDepth, NestedDepth (real nesting), Explain, ExplainXT (no raise)
# STUBS   : LastError, PatternErrorOffset -- the engine throws the compile error away (stz_regex_new returns
#           null), so the stubs are kept and the guard pins what they do
# DECISION: FindPartialMatch answers 0 for "no match" (the Find convention and PartialMatchStart's answer)
#           where the old block said it raised an error; Explain answers an empty text for an unknown pattern

cDigits = "\d"

Scenario("FindMatches: a match that starts where the last one ended is not skipped")
	oRx = RxNew(cDigits)
	oRx.MatchFirst("1234")
	Then("\d on 1234 starts at 1, 2, 3, 4", @@(oRx.FindMatches()), "[ 1, 2, 3, 4 ]")
	Then("...as many positions as Matches finds matches", len(oRx.FindMatches()), len(oRx.Matches()))
	Then("...and as NumberOfMatches says", oRx.NumberOfMatches(), 4)
	Then("the alias FindValues agrees", @@(oRx.FindValues()), "[ 1, 2, 3, 4 ]")
	Then("the alias FindMatchingValuesZ agrees", @@(oRx.FindMatchingValuesZ()), "[ 1, 2, 3, 4 ]")

	oRx = RxNew("ab")
	oRx.MatchFirst("ababab")
	Then("ab on ababab starts at 1, 3, 5", @@(oRx.FindMatches()), "[ 1, 3, 5 ]")

	oRx = RxNew("\d+")
	oRx.MatchFirst("12 345 6")
	Then("separated runs were always right: 1, 4, 8", @@(oRx.FindMatches()), "[ 1, 4, 8 ]")

	oRx = RxNew("é")
	oRx.MatchFirst("éaéé")
	Then("accented text: the accented e in 'e a e e' starts at byte 1, 4, 6", @@(oRx.FindMatches()), "[ 1, 4, 6 ]")
	Then("...three matches, as Matches finds", len(oRx.Matches()), 3)

	oRx = RxNew("\d+")
	oRx.MatchFirst("שלום 12 34")
	Then("Hebrew text: digit runs start at byte 10 and 13", @@(oRx.FindMatches()), "[ 10, 13 ]")

	# THE NEGATIVE SIBLINGS: nothing to find stays empty, and so does a pattern that never saw a text
	oRx = RxNew(cDigits)
	oRx.MatchFirst("abc")
	Then("no digit in abc: no position", @@(oRx.FindMatches()), "[ ]")
	oRx = RxNew(cDigits)
	Then("no text given yet: no position", @@(oRx.FindMatches()), "[ ]")
	oRx = RxNew("é")
	oRx.MatchFirst("abc")
	Then("no accented e in abc: no position", @@(oRx.FindMatches()), "[ ]")
EndScenario()

Scenario("The Z and ZZ readers walk the matches the same way")
	oRx = RxNew(cDigits)
	oRx.MatchFirst("1234")
	Then("MatchesZ gives all four values with their positions",
		@@(oRx.MatchesZ()), '[ [ "1", 1 ], [ "2", 2 ], [ "3", 3 ], [ "4", 4 ] ]')
	Then("FindMatchesZZ gives four sections, end one past the match (as 00_regex_narrated pins)",
		@@(oRx.FindMatchesZZ()), "[ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ] ]")
	Then("MatchesZZ gives the values with their sections",
		@@(oRx.MatchesZZ()), '[ [ "1", [ 1, 2 ] ], [ "2", [ 2, 3 ] ], [ "3", [ 3, 4 ] ], [ "4", [ 4, 5 ] ] ]')
	Then("the alias ValuesAndTheirPositions agrees with MatchesZ",
		@@(oRx.ValuesAndTheirPositions()), @@(oRx.MatchesZ()))

	oRx = RxNew("é")
	oRx.MatchFirst("éé")
	Then("accented text: two accented letters give two value-position pairs, bytes 1 and 3",
		@@(oRx.MatchesZ()), '[ [ "é", 1 ], [ "é", 3 ] ]')

	oRx = RxNew("\d+")
	oRx.MatchFirst("a12b345c6")
	Then("separated runs were always right", @@(oRx.MatchesZ()), '[ [ "12", 2 ], [ "345", 5 ], [ "6", 9 ] ]')
	oRx = RxNew(cDigits)
	oRx.MatchFirst("abc")
	Then("no match: MatchesZ is empty", @@(oRx.MatchesZ()), "[ ]")
	Then("no match: FindMatchesZZ is empty", @@(oRx.FindMatchesZZ()), "[ ]")
	Then("no match: MatchesZZ is empty", @@(oRx.MatchesZZ()), "[ ]")
EndScenario()

Scenario("FindCapture: the start of each whole match, none skipped")
	oRx = RxNew(cDigits)
	oRx.MatchFirst("1234")
	Then("\d on 1234 starts at 1, 2, 3, 4", @@(oRx.FindCapture()), "[ 1, 2, 3, 4 ]")
	Then("the alias FindCaptures agrees", @@(oRx.FindCaptures()), "[ 1, 2, 3, 4 ]")

	oRx = RxNew("(\d)(\d)")
	oRx.MatchFirst("123456")
	Then("(\d)(\d) on 123456 starts at 1, 3, 5 (the old skip answered 1, 4)", @@(oRx.FindCapture()), "[ 1, 3, 5 ]")

	oRx = RxNew("a(b)")
	oRx.MatchFirst("abab")
	Then("a(b) on abab starts at 1 and 3, not at the group", @@(oRx.FindCapture()), "[ 1, 3 ]")

	oRx = RxNew("(é)(é)")
	oRx.MatchFirst("ééééé")
	Then("accented text: pairs start at byte 1 and 5", @@(oRx.FindCapture()), "[ 1, 5 ]")

	oRx = RxNew("a(b)")
	oRx.MatchFirst("xyz")
	Then("no match: nothing to find", @@(oRx.FindCapture()), "[ ]")
EndScenario()

Scenario("HasGroups: a fact about the PATTERN, not about the last match")
	# no parenthesis, or none that captures
	Then("abc has no group before a match", RxNew("abc").HasGroups(), FALSE)
	oRx = RxNew("abc")
	oRx.MatchFirst("abc")
	Then("abc has no group after a match either (the whole match is not a group)", oRx.HasGroups(), FALSE)
	Then("...although the engine reports one capture, the whole match", oRx.CaptureCount(), 1)
	Then("a non-capturing (?:a) is not a group", RxNew("(?:a)b").HasGroups(), FALSE)
	Then("an escaped \(a\) is not a group", RxNew("\(a\)").HasGroups(), FALSE)
	Then("a bracket in a class [(] is not a group", RxNew("[(]a").HasGroups(), FALSE)
	Then("a lookahead (?=a) is not a group", RxNew("(?=a)a").HasGroups(), FALSE)
	Then("a lookbehind (?<=a) is not a group", RxNew("(?<=a)b").HasGroups(), FALSE)
	Then("a negative lookbehind (?<!a) is not a group", RxNew("(?<!a)b").HasGroups(), FALSE)
	Then("an inline option (?i) is not a group", RxNew("(?i)abc").HasGroups(), FALSE)
	Then("a quoted \Q(a)\E is not a group", RxNew("\Q(a)\E").HasGroups(), FALSE)
	Then("a comment group (?#(x)) is not a group", RxNew("a(?#(x))b").HasGroups(), FALSE)
	Then("a class holding a POSIX name [[:alpha:](] is not a group", RxNew("[[:alpha:](]a").HasGroups(), FALSE)

	# a group, before any match, after a match and after a failed one
	oRx = RxNew("(a)(b)")
	Then("(a)(b) has groups before any match", oRx.HasGroups(), TRUE)
	oRx.MatchFirst("ab")
	Then("...after a successful match", oRx.HasGroups(), TRUE)
	oRx.MatchFirst("zzz")
	Then("...and after a failed match", oRx.HasGroups(), TRUE)
	Then("a named (?<n>a) is a group", RxNew("(?<n>a)").HasGroups(), TRUE)
	Then("a named (?P<n>a) is a group", RxNew("(?P<n>a)").HasGroups(), TRUE)
	Then("a named (?'n'a) is a group", RxNew("(?'n'a)").HasGroups(), TRUE)
	Then("a group after a class [(]( is still found", RxNew("[(](a)").HasGroups(), TRUE)
	Then("a group after an escaped paren \((a) is found", RxNew("\((a)").HasGroups(), TRUE)
	Then("a group after an escaped backslash \\(a) is found", RxNew("\\(a)").HasGroups(), TRUE)
	Then("an accented pattern is a group", RxNew("(é)").HasGroups(), TRUE)
	Then("a pattern that does not compile has none", RxNew("(unclosed").HasGroups(), FALSE)

	# the readers that used to lean on it keep their behaviour
	oRx = RxNew("(\w+)=(\d+)")
	oRx.Match("k=5")
	Then("CaptureGroups still lists whole match then groups", @@(oRx.CaptureGroups()), '[ "k=5", "k", "5" ]')
	oRx = RxNew("abc")
	oRx.MatchFirst("abc")
	Then("CaptureGroups of a group-less pattern after a match still lists the whole match", @@(oRx.CaptureGroups()), '[ "abc" ]')
	oRx = RxNew("abc")
	bRaised = RaisesOn(oRx)
	Then("CaptureGroups with no match yet still raises", bRaised, TRUE)
	oRx.Match("zzz")
	Then("CaptureGroups after a failed match still raises", RaisesOn(oRx), TRUE)
EndScenario()

Scenario("LastError and PatternErrorOffset: placeholders, the engine does not hand the error back")
	oBad = RxNew("(unclosed")
	oOk = RxNew("abc")
	Then("a pattern with a missing parenthesis does not compile", oBad.IsValid(), FALSE)
	Then("...and a good pattern does", oOk.IsValid(), TRUE)
	Then("LastError is the empty text for the bad pattern (placeholder)", oBad.LastError(), "")
	Then("...and for the good one", oOk.LastError(), "")
	Then("PatternErrorOffset is -1 for the bad pattern (placeholder)", oBad.PatternErrorOffset(), -1)
	Then("...and for the good one", oOk.PatternErrorOffset(), -1)
	Then("a bad pattern does not raise: every match call answers FALSE", oBad.Match("x"), FALSE)
EndScenario()

Scenario("FindPartialMatch: where a partial or complete match starts, 0 when there is none")
	oRx = RxNew("^\d{3}-\d{2}-\d{4}$")
	Then("12 is the beginning of an SSN: starts at 1", oRx.FindPartialMatch("12"), 1)
	Then("123-45 too", oRx.FindPartialMatch("123-45"), 1)
	Then("a complete SSN starts at 1", oRx.FindPartialMatch("123-45-6789"), 1)
	Then("the alias FindPartialMatchZ agrees", oRx.FindPartialMatchZ("12"), 1)
	# THE NEGATIVE SIBLINGS: used to raise R2 (index out of range)
	bRaised = 0
	nAnswer = -9
	try
		nAnswer = oRx.FindPartialMatch("abc")
	catch
		bRaised = 1
	done
	Then("abc cannot become an SSN: no raise", bRaised, FALSE)
	Then("...the answer is 0", nAnswer, 0)
	Then("an empty text: 0", oRx.FindPartialMatch(""), 0)
	Then("it agrees with PartialMatchStart for a miss", oRx.FindPartialMatch("abc"), oRx.PartialMatchStart("abc"))
	Then("it agrees with PartialMatchStart for a hit", oRx.FindPartialMatch("12"), oRx.PartialMatchStart("12"))

	oRx = RxNew("^é{3}$")
	Then("accented text: two accented letters begin a run of three: starts at 1", oRx.FindPartialMatch("éé"), 1)
	Then("...and ab is not", oRx.FindPartialMatch("ab"), 0)
EndScenario()

Scenario("PartialMatchLength: the length of the partial or complete match, in characters")
	oRx = RxNew("^\d{3}-\d{2}-\d{4}$")
	Then("12 gives 2", oRx.PartialMatchLength("12"), 2)
	Then("123- gives 4", oRx.PartialMatchLength("123-"), 4)
	Then("a complete 123-45-6789 gives 11", oRx.PartialMatchLength("123-45-6789"), 11)
	Then("the alias PartialMatchSize agrees", oRx.PartialMatchSize("123-"), 4)
	Then("the alias PartialMatchNumberOfChars agrees", oRx.PartialMatchNumberOfChars("123-"), 4)
	Then("no match gives 0", oRx.PartialMatchLength("abc"), 0)
	Then("...and so does the empty text", oRx.PartialMatchLength(""), 0)

	oRx = RxNew("^\d{3}$")
	Then("\d{3}: 12 gives 2", oRx.PartialMatchLength("12"), 2)
	Then("\d{3}: 123 gives 3", oRx.PartialMatchLength("123"), 3)
	Then("\d{3}: 1 gives 1", oRx.PartialMatchLength("1"), 1)

	oRx = RxNew("^é{3}$")
	Then("accented text counts characters: two letters give 2, not their 4 bytes", oRx.PartialMatchLength("éé"), 2)
	Then("...and three letters give 3", oRx.PartialMatchLength("ééé"), 3)
	Then("...and xyz gives 0", oRx.PartialMatchLength("xyz"), 0)
EndScenario()

Scenario("RecursiveDepth and NestedDepth: the real nesting, not the number of matches")
	cNest = "\((?:[^()]+|(?R))*\)"
	oRx = RxNew(cNest)
	Then("an unused object has depth 0", oRx.RecursiveDepth(), 0)

	oRx.MatchRecursive("(x)")
	Then("(x) is 1 deep", oRx.RecursiveDepth(), 1)
	oRx.MatchRecursive("((x))")
	Then("((x)) is 2 deep", oRx.RecursiveDepth(), 2)
	oRx.MatchRecursive("(((x)))")
	Then("(((x))) is 3 deep (3 matches, a single chain)", oRx.RecursiveDepth(), 3)
	oRx.MatchRecursive("((x)(y)(z))")
	Then("((x)(y)(z)) is 2 deep, although 4 brackets match", oRx.RecursiveDepth(), 2)
	Then("...NestedDepth says the same", oRx.NestedDepth(), 2)
	Then("...the four brackets are still all listed by RecursiveSubStrings", len(oRx.RecursiveSubStrings()), 4)
	oRx.MatchRecursive("(a(b(c)d)e)")
	Then("(a(b(c)d)e) is 3 deep", oRx.RecursiveDepth(), 3)
	oRx.MatchRecursive("((a)(b(c)))")
	Then("((a)(b(c))) is 3 deep, with 4 matches", oRx.RecursiveDepth(), 3)
	Then("...NestedDepth says 3 too", oRx.NestedDepth(), 3)
	oRx.MatchRecursive("((é)(ü))")
	Then("accented text: two accented siblings in one bracket are 2 deep", oRx.RecursiveDepth(), 2)
	oRx.MatchRecursive("(((é)))")
	Then("accented text: three nested accented brackets are 3 deep", oRx.RecursiveDepth(), 3)

	oRx = RxNew("(abc(?R)?)")
	oRx.MatchRecursive("abcabcabc")
	Then("(abc(?R)?) over abcabcabc nests 3 deep", oRx.RecursiveDepth(), 3)

	# THE NEGATIVE SIBLINGS: no recursive match, no depth
	oRx = RxNew(cNest)
	oRx.MatchRecursive("x")
	Then("a text that does not match has depth 0", oRx.RecursiveDepth(), 0)
	Then("...NestedDepth too", oRx.NestedDepth(), 0)
	oRx.MatchRecursive("((x)")
	Then("an unbalanced text does not match: depth 0", oRx.RecursiveDepth(), 0)
EndScenario()

Scenario("Explain: a known pattern is explained, an unknown one answers an empty text instead of raising")
	oRx = RxNew("^([^\d]*)(\d+)$")
	Then("a catalogue pattern is explained", StzFindFirst("Splits string", oRx.Explain()) > 0, TRUE)
	Then("...and ExplainXT is longer", len(oRx.ExplainXT()) > len(oRx.Explain()), TRUE)

	oRx = RxNew("a+b")
	bRaised = 0
	cText = "x"
	try
		cText = oRx.Explain()
	catch
		bRaised = 1
	done
	Then("an unknown pattern does not raise", bRaised, FALSE)
	Then("...Explain answers the empty text", cText, "")
	bRaised = 0
	cText = "x"
	try
		cText = oRx.ExplainXT()
	catch
		bRaised = 1
	done
	Then("...ExplainXT does not raise", bRaised, FALSE)
	Then("...and answers the empty text", cText, "")

	# a catalogue pattern that has a name but no explanation entry used to raise too
	oRx = RxNew(pat(:integer))
	bRaised = 0
	cText = "x"
	try
		cText = oRx.Explain()
	catch
		bRaised = 1
	done
	Then("a catalogue pattern with no explanation entry does not raise", bRaised, FALSE)
	Then("...and answers the empty text", cText, "")
	oRx = RxNew("é+ü")
	Then("an accented unknown pattern answers the empty text", oRx.Explain(), "")
EndScenario()

Summary()

func RxNew cPattern
	return new stzRegex(cPattern)

func RaisesOn oRx
	bRaised = 0
	try
		oRx.CaptureGroups()
	catch
		bRaised = 1
	done
	return bRaised
