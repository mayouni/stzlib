load "../../stzBase.ring"
load "../_narrated.ring"

# ConsecutiveSubStringsOfNChars(n): the n-char windows obtained by tiling the
# string from each of the n phase offsets (phase-major order) -- across all
# phases that is EVERY window of length n, so the count is len-n+1 (26 here,
# which the pre-audit impl got wrong). FindConsecutiveSubStringsOfNChars(n)
# returns the unique phase offsets; the Z/ZZ forms carry the [substring, start]
# / [substring, span] grouping. Archive block #291.

Scenario("Phase-tiled consecutive substrings of 4 chars")
	Given('"phpringringringpythonrubyruby" (29 chars)')
	o1 = new stzString("phpringringringpythonrubyruby")
	Then("their number is 29-4+1", o1.NumberOfConsecutiveSubStringsOfNChars(4), 26)
	Then("the windows, phase-major",
		ListEq( o1.ConsecutiveSubStringsOfNChars(4),
		[ "phpr", "ingr", "ingr", "ingp", "ytho", "nrub", "yrub",
		  "hpri", "ngri", "ngri", "ngpy", "thon", "ruby", "ruby",
		  "prin", "grin", "grin", "gpyt", "honr", "ubyr", "ring",
		  "ring", "ring", "pyth", "onru", "byru" ] ), TRUE)
	Then("the Find form returns the unique phase offsets",
		ListEq( o1.FindConsecutiveSubStringsOfNChars(4), [ 1, 2, 3, 4 ] ), TRUE)
	Then("the FindZZ form returns the spans, phase-major",
		ListEq( o1.FindConsecutiveSubStringsOfNCharsZZ(4),
		[ [1,4], [5,8], [9,12], [13,16], [17,20], [21,24], [25,28],
		  [2,5], [6,9], [10,13], [14,17], [18,21], [22,25], [26,29],
		  [3,6], [7,10], [11,14], [15,18], [19,22], [23,26],
		  [4,7], [8,11], [12,15], [16,19], [20,23], [24,27] ] ), TRUE)
	Then("the Z grouping pairs each window with its start",
		ListEq( o1.ConsecutiveSubStringsOfNCharsZ(4),
		[ [ "phpr", 1 ], [ "ingr", 5 ], [ "ingr", 9 ], [ "ingp", 13 ], [ "ytho", 17 ],
		  [ "nrub", 21 ], [ "yrub", 25 ], [ "hpri", 2 ], [ "ngri", 6 ], [ "ngri", 10 ],
		  [ "ngpy", 14 ], [ "thon", 18 ], [ "ruby", 22 ], [ "ruby", 26 ], [ "prin", 3 ],
		  [ "grin", 7 ], [ "grin", 11 ], [ "gpyt", 15 ], [ "honr", 19 ], [ "ubyr", 23 ],
		  [ "ring", 4 ], [ "ring", 8 ], [ "ring", 12 ], [ "pyth", 16 ], [ "onru", 20 ],
		  [ "byru", 24 ] ] ), TRUE)
	Then("the ZZ grouping pairs each window with its span",
		ListEq( o1.ConsecutiveSubStringsOfNCharsZZ(4),
		[ [ "phpr", [1,4] ], [ "ingr", [5,8] ], [ "ingr", [9,12] ],
		  [ "ingp", [13,16] ], [ "ytho", [17,20] ], [ "nrub", [21,24] ],
		  [ "yrub", [25,28] ], [ "hpri", [2,5] ], [ "ngri", [6,9] ],
		  [ "ngri", [10,13] ], [ "ngpy", [14,17] ], [ "thon", [18,21] ],
		  [ "ruby", [22,25] ], [ "ruby", [26,29] ], [ "prin", [3,6] ],
		  [ "grin", [7,10] ], [ "grin", [11,14] ], [ "gpyt", [15,18] ],
		  [ "honr", [19,22] ], [ "ubyr", [23,26] ], [ "ring", [4,7] ],
		  [ "ring", [8,11] ], [ "ring", [12,15] ], [ "pyth", [16,19] ],
		  [ "onru", [20,23] ], [ "byru", [24,27] ] ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
