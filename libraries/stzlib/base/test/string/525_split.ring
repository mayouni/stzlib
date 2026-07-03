load "../../stzBase.ring"
load "../_narrated.ring"

# Split(:Using = sep) unwraps to the plain (case-sensitive) split; the
# case-insensitive dial is SplitCS(sep, FALSE). EDGE empty parts are
# dropped, interior ones (adjacent separators, "ANDand") are kept -- the
# original Split contract. NOTE: the archive's #--> was written against
# a simplified input (its parts lack the ** and _ decorations the Given
# string carries) with case-insensitive splitting; asserted at the real
# impl outputs for both dials. Archive block #525.

Scenario("Splitting on and")
	o1 = new stzString("and **<Ring>** and _<<PHP>>_ AND <Python/> and _<<<Ruby>>>_ ANDand !!C++!! and")
	Then("case-sensitively, AND stays content",
		ListEq( o1.Split( :Using = "and" ),
			[ " **<Ring>** ", " _<<PHP>>_ AND <Python/> ",
			  " _<<<Ruby>>>_ AND", " !!C++!! " ] ), TRUE)
	Then("case-insensitively, AND splits too",
		ListEq( o1.SplitCS( "and", FALSE ),
			[ " **<Ring>** ", " _<<PHP>>_ ", " <Python/> ",
			  " _<<<Ruby>>>_ ", "", " !!C++!! " ] ), TRUE)
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
