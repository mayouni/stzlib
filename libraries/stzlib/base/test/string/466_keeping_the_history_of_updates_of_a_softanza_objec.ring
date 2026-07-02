load "../../stzBase.ring"
load "../_narrated.ring"

# QH() keeps the history of a transformation chain: the initial value
# plus each fluent op's result. (The archive's RemoveWXTQ spelling is
# retired; RemoveCharsWQ is the eval-free W replacement.) History() is
# consuming -- it returns the stream and clears it. Archive block #466.

Scenario("A chain without history")
	Then("the result is clear, the path forgotten",
		Q("1 AA 2 B 3 CCC 4 DD 5 Z").
			RemoveCharsWQ('Q(@Char).IsNumberInString()').
			RemoveSpacesQ().
			RemoveDuplicatedCharsQ().
			Content(), "ABCDZ")
EndScenario()

Scenario("The same chain through QH")
	Then("every step is captured",
		ListEq( QH("1 AA 2 B 3 CCC 4 DD 5 Z").
			RemoveCharsWQ('Q(@Char).IsNumberInString()').
			RemoveSpacesQ().
			RemoveDuplicatedCharsQ().
			History(),
			[ "1 AA 2 B 3 CCC 4 DD 5 Z",
			  " AA  B  CCC  DD  Z",
			  "AABCCCDDZ",
			  "ABCDZ" ] ), TRUE)
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
