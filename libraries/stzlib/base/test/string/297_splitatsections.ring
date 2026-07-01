load "../../stzBase.ring"
load "../_narrated.ring"

# stzString.SplitAtSections(sections): split the string AT the sections and
# return the COMPLEMENT parts between them (the original monolith routes the
# complement computation through stzSplitter -- see block #296, and the
# sibling archive block on "---456----123--67---" which yields the "---"
# separator parts). NOTE: this block's archive #--> listed the sections'
# own content ("r  in  g", "r  ing") -- inconsistent with the original impl
# AND that sibling block; asserted at the complement per the original.
# Archive block #297.

Scenario("Splitting a string at sections keeps the parts between")
	Given('"r  in  g language is like a r  ing at your fingertips!"')
	o1 = new stzString("r  in  g language is like a r  ing at your fingertips!")
	Then("the two gap parts remain",
		ListEq( o1.SplitAtSections([ [ 1, 8 ], [ 29, 34 ] ]),
			[ " language is like a ", " at your fingertips!" ] ), TRUE)
	Then("the sibling archive example splits into its separator runs",
		ListEq( Q("---456----123--67---").SplitAtSections([ [4, 6], [11, 13], [16, 17] ]),
			[ "---", "----", "--", "---" ] ), TRUE)
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
