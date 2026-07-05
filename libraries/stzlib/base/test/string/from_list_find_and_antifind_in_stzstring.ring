load "../../stzBase.ring"
load "../_narrated.ring"

# Find locates the hearts; AntiFind locates everything else, and
# AntiFindZZ gives the non-heart runs as sections.
# Extracted from stzlisttest.ring, block #35.

Scenario("Find and anti-find")
	o1 = new stzString("12♥45♥67♥9")
	Then("the hearts",
		ListEq( o1.Find("♥"), [ 3, 6, 9 ] ), TRUE)
	Then("everything but the hearts",
		ListEq( o1.AntiFind("♥"), [ 1, 2, 4, 5, 7, 8, 10 ] ), TRUE)
	Then("the non-heart runs",
		ListEq( o1.AntiFindZZ("♥"),
			[ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ] ), TRUE)
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
