load "../../stzBase.ring"
load "../_narrated.ring"

# The auto-bound family: FindBoundedSubString finds the occurrences that
# carry non-space bound runs on BOTH sides (the trailing bare "word" has
# none); FindSubStringBounds returns the runs' start positions and its ZZ
# their spans. Archive block #567.

Scenario("Bounded occurrences vs their bounds")
	o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>> word")
	Then("the bounded occurrences",
		ListEq( o1.FindBoundedSubString("word"), [ 11, 28, 41 ] ), TRUE)
	Then("... their spans",
		ListEq( o1.FindBoundedSubStringZZ("word"),
			[ [11, 14], [28, 31], [41, 44] ] ), TRUE)
	Then("the bound runs' starts",
		ListEq( o1.FindSubStringBounds("word"), [ 9, 15, 26, 32, 39, 45 ] ), TRUE)
	Then("... and their spans",
		ListEq( o1.FindSubStringBoundsZZ("word"),
			[ [9, 10], [15, 16], [26, 27], [32, 33], [39, 40], [45, 46] ] ), TRUE)
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
