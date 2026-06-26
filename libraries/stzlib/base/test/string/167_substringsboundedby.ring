load "../../stzBase.ring"
load "../_narrated.ring"

# SubStringsBoundedBy([open, close]) -- the substrings enclosed by each bound
# pair. Archive block #167.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the companion BoundedByZZ should
# return each substring grouped with its [from,to] span, but it returns positions
# ONLY (loses the substring) -- same as BoundedByUZ (block 163). Left as a NOTE.

Scenario("The substrings enclosed by << >>")
	Given('"...<<--hi!-->>...<<-->>...<<hi!>>..."')
	o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")
	Then("the three enclosed substrings",
		ListEq( o1.SubStringsBoundedBy([ "<<", ">>" ]), [ "--hi!--", "--", "hi!" ] ), TRUE)
	# BoundedByZZ should pair each substring with its span; returns positions only:
	? "  NOTE  BoundedByZZ -> " + @@(o1.BoundedByZZ([ "<<", ">>" ])) + "  (lost the substrings -- deferred)"
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
