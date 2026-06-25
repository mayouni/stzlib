load "../../stzBase.ring"
load "../_narrated.ring"

# IsReverseOf -- TRUE if the string (or list) is the reverse of the argument.

Scenario("IsReverseOf on a string and a range")
	Given('the string "ring" and the range 1..3')
	Then('"ring" is the reverse of "gnir"', Q("ring").IsReverseOf("gnir"), TRUE)
	Then("1..3 is the reverse of 3..1", Q(1:3).IsReverseOf(3:1), TRUE)
EndScenario()

Summary()
