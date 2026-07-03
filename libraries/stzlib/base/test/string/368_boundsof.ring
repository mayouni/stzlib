load "../../stzBase.ring"
load "../_narrated.ring"

# BoundsOf over TWO differently-bounded occurrences: each yields its own
# [open, close] pair (the per-occurrence nested shape settled in block
# #42; the archive displayed the pairs flattened into one list). The XT
# cap trims each side; a cap larger than every run changes nothing.
# Archive block #368.

Scenario("Bounds of two occurrences")
	Given('" <<<<word>>> and ~~~~word~~~~~ "')
	o1 = new stzString(" <<<<word>>> and ~~~~word~~~~~ ")
	# RULING (chunk 35): BoundsOf is FLAT per the original impl
	# (blocks #589-#591).
	Then("each occurrence contributes its runs, flat",
		ListEq( o1.BoundsOf( "word"),
			[ "<<<<", ">>>", "~~~~", "~~~~~" ] ), TRUE)
	Then("capped at [3, 2]",
		ListEq( o1.BoundsOfXT( "word", [ 3, 2 ] ),
			[ [ "<<<", ">>" ], [ "~~~", "~~" ] ] ), TRUE)
	Then("a generous cap changes nothing",
		ListEq( o1.BoundsOfXT( "word", 8 ),
			[ [ "<<<<", ">>>" ], [ "~~~~", "~~~~~" ] ] ), TRUE)
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
