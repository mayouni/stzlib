load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceW / ReplaceWQ -- replace every character matching the predicate with a
# new char (the :With named param gives the replacement). Engine-backed, no
# eval(). Migrated from the retired ReplaceCharsWXT. IsNotLetter is now
# Unicode-correct: symbol characters (heart, star) are NOT letters, so they are
# the ones replaced.

Scenario("ReplaceW replaces every non-letter with a space")
	Given("letter groups separated by symbol characters")
	Then("Q(@char).IsNotLetter() targets the symbols, leaving spaced words",
		Q("ABC♥DEF★GHI♥JKL").ReplaceWQ('Q(@char).IsNotLetter()', :With = " ").Content(),
		"ABC DEF GHI JKL")
EndScenario()

Summary()
