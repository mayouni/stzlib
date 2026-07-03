load "../../stzBase.ring"
load "../_narrated.ring"

# NumberOfOccurrenceCS with the case dial. Archive block #603.

Scenario("Counting Arabic, case aside")
	Then("four hits",
		Q("dfgfdgg Arabic Arabic Arabic dgdgf arabic KKKK").NumberOfOccurrenceCS("Arabic", FALSE), 4)
EndScenario()

Summary()
