load "../../stzBase.ring"
load "../_narrated.ring"

# IsCharName against the Unicode names table. Archive block #648.

Scenario("Recognizing char names")
	Then("a digit name", Q("DIGIT ZERO").IsCharName(), TRUE)
	Then("a latin letter name", Q("LATIN CAPITAL LETTER O").IsCharName(), TRUE)
	Then("a javanese name", Q("JAVANESE PADA PISELEH").IsCharName(), TRUE)
EndScenario()

Summary()
