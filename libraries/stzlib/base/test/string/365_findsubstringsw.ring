load "../../stzBase.ring"
load "../_narrated.ring"

# FindSubStringsW / FindSubStringsWZZ -- the substrings (or their [start,end]
# sections, ZZ) matching an engine-DSL @SubString predicate. Engine-backed via
# stzList.FindW over enumerated substrings, no eval(). Migrated from the retired
# FindSubStringsWXT (the { } block that crashed its eval with C27 is stripped).

Scenario("FindSubStringsW with an or-predicate over substrings")
	Given('the string "...ONE...TWO...ONE"')
	Then("the matching substrings",
		@@( Q("...ONE...TWO...ONE").FindSubStringsW('{ @SubString = "ONE" or @SubString = "TWO" }') ),
		@@([ "ONE", "TWO", "ONE" ]))
	Then("FindSubStringsWZZ gives their sections",
		@@( Q("...ONE...TWO...ONE").FindSubStringsWZZ('{ @SubString = "ONE" or @SubString = "TWO" }') ),
		@@([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ]))
EndScenario()

Summary()
