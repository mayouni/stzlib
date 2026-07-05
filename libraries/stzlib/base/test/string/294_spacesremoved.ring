load "../../stzBase.ring"
load "../_narrated.ring"

# SpacesRemoved on a list of strings (functional), then RemoveSpaces
# (mutating). Archive block #294 (spaces-removed variant).

Scenario("Squeezing the spaces out of a string list")
	o1 = new stzListOfStrings([ " r   in g", "r ing", "  r     i ng  " ])
	Then("all become ring",
		ListEq( o1.SpacesRemoved(), [ "ring", "ring", "ring" ] ), TRUE)
	o1.RemoveSpaces()
	Then("... and in place too",
		ListEq( o1.Content(), [ "ring", "ring", "ring" ] ), TRUE)
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
