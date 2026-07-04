load "../../stzBase.ring"
load "../_narrated.ring"

# Binary-form literals: the sign belongs BEFORE the 0b prefix.
# Archive block #833.

Scenario("Three binary spellings")
	Then("plain", Q("0b110001.1001").RepresentsNumberInBinaryForm(), TRUE)
	Then("signed before the prefix",
		Q("-0b110001.1001").RepresentsNumberInBinaryForm(), TRUE)
	Then("sign inside: malformed",
		Q("0b-110001.1001").RepresentsNumberInBinaryForm(), FALSE)
EndScenario()

Summary()
