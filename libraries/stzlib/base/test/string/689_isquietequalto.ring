load "../../stzBase.ring"
load "../_narrated.ring"

# The quiet-equality ratio is a dial: 0.09 by default, raise it for a
# more permissive check. Archive block #689.

Scenario("Two spellings of a famous name")
	o1 = new stzString("mahmoud fayed")
	Then("too far apart at the default ratio",
		o1.IsQuietEqualTo("Mahmood al-feiyed"), FALSE)
	Then("the default ratio", QuietEqualityRatio(), 0.09)
	SetQuietEqualityRatio(0.35)
	Then("close enough at 0.35",
		o1.IsQuietEqualTo("Mahmood al-feiyed"), TRUE)
	SetQuietEqualityRatio(0.09)
EndScenario()

Summary()
