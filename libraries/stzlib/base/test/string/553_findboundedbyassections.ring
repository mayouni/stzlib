load "../../stzBase.ring"
load "../_narrated.ring"

# FindBoundedByAsSections with distinct bounds and with quotes (a
# same-char bound: each closing quote reopens the next region -- the
# settled overlap rule). Archive block #553.

Scenario("Bounded sections, then their substrings")
	Then("two distinct-bound sections",
		ListEq( Q("txt <<ring>> txt <<ring>>").FindBoundedByAsSections([ "<<", ">>" ]),
			[ [7, 10], [20, 23] ] ), TRUE)
	str = 'for      txt =  "   val1  "   to  "   val2"   do  this or   that!'
	Then("quotes overlap into three sections",
		ListEq( Q(str).FindBoundedByAsSections('"'),
			[ [18, 26], [28, 34], [36, 42] ] ), TRUE)
	Then("their contents",
		ListEq( Q(str).Sections([ [ 18, 26 ], [ 28, 34 ], [ 36, 42 ] ]),
			[ "   val1  ", "   to  ", "   val2" ] ), TRUE)
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
