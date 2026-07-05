load "../../stzBase.ring"
load "../_narrated.ring"

# IsArabic on a text. Archive block #991.

Scenario("The word one, in Arabic")
	Then("arabic indeed", TQ("واحد").IsArabic(), TRUE)
EndScenario()

Summary()
