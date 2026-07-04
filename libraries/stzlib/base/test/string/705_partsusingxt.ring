load "../../stzBase.ring"
load "../_narrated.ring"

# PartsUsingXT partitions the string into runs of chars sharing the
# same value of the given expression -- here, their script.
# Archive block #705.

Scenario("Partitioning by script")
	o1 = new stzString("__b和平س__a_ووو")
	Then("eight script runs",
		ListEq( o1.PartsUsingXT(' StzCharQ(@char).Script() '),
			[ "__", "b", "和平", "س", "__", "a", "_", "ووو" ] ), TRUE)
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
