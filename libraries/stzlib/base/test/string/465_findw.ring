load "../../stzBase.ring"
load "../_narrated.ring"

# FindW with the isDigit char-class predicate -- the positions of the digit
# characters. Engine-backed, no eval(). Migrated from the retired FindWXT; its
# Q(@char).IsNumberInString() sugar (not in the engine DSL) is rewritten to
# isDigit(@char).

Scenario("FindW locates the digit characters")
	Given('the string "1 AA 6 B 0 CCC 6 DD 1 Z"')
	Then("FindW with isDigit(@char) reports the digit positions",
		@@( Q("1 AA 6 B 0 CCC 6 DD 1 Z").FindW('isDigit(@char)') ), @@([ 1, 6, 10, 16, 21 ]))
EndScenario()

Summary()
