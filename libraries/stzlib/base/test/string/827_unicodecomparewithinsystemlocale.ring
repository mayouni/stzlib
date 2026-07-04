load "../../stzBase.ring"
load "../_narrated.ring"

# UnicodeCompareWithInSystemLocale: case-blind first, and on a tie the
# uppercase side sorts greater (collation convention).
# Archive block #827.

Scenario("Caps against minuscules")
	Then("RESERVE beats reserve on the tie-break",
		Q("RÉSERVÉ").UnicodeCompareWithInSystemLocale("réservé"), :Greater)
EndScenario()

Summary()
