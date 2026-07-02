load "../../stzBase.ring"
load "../_narrated.ring"

# The global history switch: KeepHistory() makes plain Q() chains record;
# DontKeepHistory() turns it off (History() then returns []). The
# archive's RemoveWXTQ spelling is retired -> RemoveCharsWQ.
# Archive block #469.

Scenario("Recording off by default")
	Then("the chain just transforms",
		Q("1 AA 2 B 3 CCC 4 DD 5 Z").
			RemoveCharsWQ('Q(@Char).IsNumberInString()').
			RemoveSpacesQ().
			RemoveDuplicatedCharsQ().
			Content(), "ABCDZ")
EndScenario()

Scenario("KeepHistory turns recording on")
	KeepHistory()
	Then("plain Q() now captures the steps",
		ListEq( Q("1 AA 2 B 3 CCC 4 DD 5 Z").
			RemoveCharsWQ('Q(@Char).IsNumberInString()').
			RemoveSpacesQ().
			RemoveDuplicatedCharsQ().
			History(),
			[ "1 AA 2 B 3 CCC 4 DD 5 Z",
			  " AA  B  CCC  DD  Z",
			  "AABCCCDDZ",
			  "ABCDZ" ] ), TRUE)
EndScenario()

Scenario("DontKeepHistory turns it back off")
	DontKeepHistory()
	Then("the history is empty again",
		ListEq( Q("1 AA 2 B 3 CCC 4 DD 5 Z").
			RemoveCharsWQ('Q(@Char).IsNumberInString()').
			RemoveSpacesQ().
			RemoveDuplicatedCharsQ().
			History(), [ ] ), TRUE)
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
