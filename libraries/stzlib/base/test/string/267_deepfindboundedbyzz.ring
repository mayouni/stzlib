load "../../stzBase.ring"
load "../_narrated.ring"

# DeepFindBoundedByZZ recurses into NESTED [ ] regions, returning each region's
# [from,to] span -- LEAVES first, then parents. Archive block #267.

Scenario("Deep-finding nested [ ] regions")
	Given('a nested bracket structure')
	o1 = new stzString('[
	"1", "1",
		["2", "♥", "2"],
	"1",
		["2",
			["3", "♥",
				["4",
					["5", "♥"],
				"4",
					["5","♥"],
				"♥"],
			"3"]
		]

]')
	Then("every nested region is found, leaves before parents",
		ListEq( o1.DeepFindBoundedByZZ([ "[", "]" ]),
			[ [17,29], [77,84], [103,109], [66,119], [51,128], [42,132], [2,135] ] ), TRUE)
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
