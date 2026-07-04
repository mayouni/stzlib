load "../../stzBase.ring"
load "../_narrated.ring"

# Roman numerals carry the Latin script (UAX #24).
# Archive block #845.

Scenario("The numeral two")
	Then("Latin script", StzStringQ("Ⅱ").IsLatin(), TRUE)
	Then("and a Roman number", StzCharQ("Ⅱ").IsRomanNumber(), TRUE)
EndScenario()

Summary()
