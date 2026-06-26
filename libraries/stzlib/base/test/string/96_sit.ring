load "../../stzBase.ring"
load "../_narrated.ring"

# Sit(:OnSection = [a,b], :Harvest = [:NCharsBefore = m, :NCharsAfter = n]) --
# "sit" on a section and harvest the m chars just before it and the n chars just
# after it (here: the bounds around "nice"). Archive block #96.

Scenario("Harvesting the chars bounding a section")
	Given('"what a <<nice>>> day!" (nice at 10..13)')
	o1 = new stzString("what a <<nice>>> day!")
	Then("the 2 chars before and 3 after are the bounds",
		ListEq( o1.Sit(:OnSection = [10, 13], :Harvest = [ :NCharsBefore = 2, :NCharsAfter = 3 ]),
			[ "<<", ">>>" ] ), TRUE)
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
