load "../../stzBase.ring"
load "../_narrated.ring"

# The history feature on a NUMBER chain. NOTE: the archive's #--> showed
# 45 for the value (wrong arithmetic: ((12500+500-1500)/500)*2 = 46) and
# omitted the initial 12500 from the history -- inconsistent with its
# own sibling blocks #466/#467/#469 where the initial value opens the
# stream; asserted at the uniform impl behavior. Archive block #468.

Scenario("A number chain, then its history")
	Then("the computed value",
		Q(12500).
			AddQ(500).
			RetrieveQ(1500).
			DivideByQ(500).
			MultiplyByQ(2).
			Value(), 46)
	Then("the captured steps (initial included)",
		ListEq( Qh(12500).
			AddQ(500).
			RetrieveQ(1500).
			DivideByQ(500).
			MultiplyByQ(2).
			History(), [ 12500, 13000, 11500, 23, 46 ] ), TRUE)
	DontKeepHistory()
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
