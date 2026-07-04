load "../../stzBase.ring"
load "../_narrated.ring"

# PartsUsing accepts the This[@i] spelling of the same expression.
# Archive block #706.

Scenario("Partitioning by script, This[@i] style")
	o1 = new stzString("__b和平س__a_ووو")
	Then("same eight runs",
		ListEq( o1.PartsUsing(' StzCharQ(This[@i]).Script() '),
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
