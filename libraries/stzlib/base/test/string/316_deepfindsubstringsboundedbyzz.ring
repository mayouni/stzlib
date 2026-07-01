load "../../stzBase.ring"
load "../_narrated.ring"

# DEEP nested-bracket extraction, with and without the bounds. The ZZ form
# gives the content span [open+1 .. close-1]; the IBZZ form keeps the bounds
# [open .. close]. Regions are ordered leaves first, then their parents
# (close order). Codepoint-correct (the bullets are multibyte).
# Extracted from stzlisttest.ring, block #316.

Scenario("Deep content spans and substrings")
	Given('"[••[•[••]•[••]]••[••]]"')
	o1 = new stzString("[••[•[••]•[••]]••[••]]")
	Then("the nested content spans, leaves first",
		ListEq( o1.DeepFindSubStringsBoundedByZZ([ "[", "]" ]),
			[ [7,8], [12,13], [19,20], [5,14], [2,21] ] ), TRUE)
	Then("each substring pairs with its span",
		ListEq( o1.DeepSubStringsBoundedByZZ([ "[", "]" ]),
			[ [ "••", [7,8] ], [ "••", [12,13] ], [ "••", [19,20] ],
			  [ "•[••]•[••]", [5,14] ],
			  [ "••[•[••]•[••]]••[••]", [2,21] ] ] ), TRUE)
EndScenario()

Scenario("Deep bound-inclusive spans and substrings")
	Given('the same string')
	o1 = new stzString("[••[•[••]•[••]]••[••]]")
	Then("the IB spans keep the brackets",
		ListEq( o1.DeepFindSubStringsBoundedByIBZZ([ "[", "]" ]),
			[ [6,9], [11,14], [18,21], [4,15], [1,22] ] ), TRUE)
	Then("each IB substring pairs with its span",
		ListEq( o1.DeepSubStringsBoundedByIBZZ([ "[", "]" ]),
			[ [ "[••]", [6,9] ], [ "[••]", [11,14] ], [ "[••]", [18,21] ],
			  [ "[•[••]•[••]]", [4,15] ],
			  [ "[••[•[••]•[••]]••[••]]", [1,22] ] ] ), TRUE)
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
