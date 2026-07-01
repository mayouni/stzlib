load "../../stzBase.ring"
load "../_narrated.ring"

# NestedSubStringsIB: split the (simplified) string at every bound marker
# and keep each fragment from one marker to the next INCLUSIVE -- so
# neighbours share a "[" or "]". The trailing "] ]" pieces are the closing
# markers winding back out. Extracted from stzlisttest.ring, block #320.

Scenario("Nested inclusive fragments of a bracketed literal")
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
	Then("the simplified nesting reads back as inclusive fragments",
		ListEq( o1.SimplifyQ().NestedSubStringsIB(:BoundedBy = [ "[", "]" ]),
		[ '[ "1", "1", [',
		  '["2", "♥", "2"]',
		  '], "1", [',
		  '["2", [',
		  '["3", "♥", [',
		  '["4", [',
		  '["5", "♥"]',
		  '], "4", [',
		  '["5","♥"]',
		  '], "♥"]',
		  '], "3"]',
		  "] ]",
		  "] ]" ] ), TRUE)
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
