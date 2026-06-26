load "../../stzBase.ring"
load "../_narrated.ring"

# ToList() parses a string that holds a Ring list literal ("[ ... ]") into the
# actual list. Archive block #51.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the archive also expected a
# RANGE-string to expand (' "A" : "E" ' -> [ "A".."E" ], ' "#1" : "#5" ' ->
# [ "#1".."#5" ]), but ToList only handles a "[...]" literal and otherwise falls
# back to Chars() (a raw char split). The range cases are left as un-asserted
# NOTEs. (The Arabic-range line was #o--> non-deterministic in the archive.)

Scenario("Parsing a list-literal string into a list")
	Then("a bracketed literal parses into its items",
		ListEq( Q('[  "ABC" , "EB" , "AA"  , 12 ]').ToList(), [ "ABC", "EB", "AA", 12 ] ), TRUE)
	# Should expand the range; instead ToList char-splits the raw string:
	? "  NOTE  ToList of a quoted A-to-E range is char-split, not expanded -- deferred"
	? "  NOTE  ToList of a quoted #1-to-#5 range is char-split, not expanded -- deferred"
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
