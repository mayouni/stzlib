load "../../stzBase.ring"
load "../_narrated.ring"

# NestedSubStrings: the text fragments between the "[[[" / "]]]" markers, in
# document order (a multi-delimiter split that drops the markers and the
# empty pieces). Bounds can be multi-char ("[[[") and content multibyte.
# (The archive's SpeedUpX perf line is informational, not asserted.)
# Extracted from stzlisttest.ring, block #321.

Scenario("Nested fragments between triple-bracket markers")
	o1 = new stzString('[[[
	"1", "1",
		[[[ "2", "♥", "2" ]]],
	"1",
		[[[ "2",
			[[[ "3", "♥",
				[[[ "4",
					[[[ "5", "♥" ]]],
				"4",
					[[[ "5", "♥" ]]],
				"♥" ]]],
			"3" ]]]
		]]]

]]]')
	o1.Simplify()
	Then("the fragments read in document order",
		ListEq( o1.NestedSubStrings(:BoundedBy = [ "[[[", "]]]" ]),
		[ ' "1", "1", ',
		  ' "2", "♥", "2" ',
		  ', "1", ',
		  ' "2", ',
		  ' "3", "♥", ',
		  ' "4", ',
		  ' "5", "♥" ',
		  ', "4", ',
		  ' "5", "♥" ',
		  ', "♥" ',
		  ', "3" ',
		  " ",
		  " " ] ), TRUE)
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
