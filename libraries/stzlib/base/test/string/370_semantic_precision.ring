load "../../stzBase.ring"
load "../_narrated.ring"

# SEMANTIC PRECISION -- the loose "larger/smaller" verbs compare by NUMBER
# OF CHARS, and the precise twins HasMoreChars / HasLessChars say so
# explicitly (reading with the :Than named param). "SFTANZA" (7) vs
# "RING" (4). Extracted from stzlisttest.ring, block #370.

Scenario("Size verbs on strings")
	Then("SFTANZA is larger than RING",
		Q("SFTANZA").IsLargerThan("RING"), TRUE)
	Then("... precisely: has more chars",
		Q("SFTANZA").HasMoreChars(:Than = "RING"), TRUE)
	Then("RING is smaller",
		Q("RING").IsSmaller(:Than = "SFTANZA"), TRUE)
	Then("... precisely: has less chars",
		Q("RING").HasLessChars(:Than = "SFTANZA"), TRUE)
EndScenario()

Summary()
