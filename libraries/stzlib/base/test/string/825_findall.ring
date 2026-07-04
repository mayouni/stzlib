load "../../stzBase.ring"
load "../_narrated.ring"

# FindAll / FindNthOccurrence(:Of) / ContainsNtimes.
# Archive block #825.

Scenario("Four texts")
	o1 = new stzString("text this text is written with the text of my scrampy text")
	Then("all four found",
		ListEq( o1.FindAll("text"), [ 1, 11, 36, 55 ] ), TRUE)
	Then("the 4th, named-param style",
		o1.FindNthOccurrence(4, :Of = "text"), 55)
	Then("contains exactly four", o1.ContainsNtimes(4, "text"), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if aA[i] != aE[i] return FALSE ok
	next
	return TRUE
