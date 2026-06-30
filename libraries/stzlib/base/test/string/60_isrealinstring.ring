load "../../stzBase.ring"
load "../_narrated.ring"

# IsRealInString tests whether a string holds a real (decimal) number;
# BothAreRealsInStrings checks two at once. Archive block #60.

Scenario("Recognising real numbers held in strings")
	Then("'2.8' is a real in a string", Q("2.8").IsRealInString(), TRUE)
	Then("'3.2' is a real in a string", Q("3.2").IsRealInString(), TRUE)
	Then("both '2.8' and '3.2' are reals", BothAreRealsInStrings("2.8", "3.2"), TRUE)
EndScenario()

Summary()
