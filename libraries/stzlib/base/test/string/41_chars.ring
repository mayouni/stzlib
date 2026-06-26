load "../../stzBase.ring"
load "../_narrated.ring"

# Chars(str) -- the list of a string's characters. Archive block #41.
#
# NOTE: the archive #--> dropped the "N" ([ "S","O","F","T","A","Z","A" ], 7
# items) -- a copy typo. "SOFTANZA" has 8 chars; impl returns all of them.

Scenario("Splitting a word into its characters")
	Then("Chars('SOFTANZA') lists all 8 chars (incl. the N)",
		ListEq( Chars("SOFTANZA"), [ "S", "O", "F", "T", "A", "N", "Z", "A" ] ), TRUE)
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
