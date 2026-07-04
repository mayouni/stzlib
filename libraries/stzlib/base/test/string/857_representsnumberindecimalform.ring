load "../../stzBase.ring"
load "../_narrated.ring"

# Decimal vs binary form: without a b prefix, digits read as decimal.
# Archive block #857.

Scenario("Prefixes decide the base")
	Then("plain digits are decimal",
		Q("12500").RepresentsNumberInDecimalForm(), TRUE)
	Then("b-prefixed digits are binary",
		Q("b100011").RepresentsNumberInBinaryForm(), TRUE)
	Then("without the b, not binary",
		Q("100011").RepresentsNumberInBinaryForm(), FALSE)
	Then("... but decimal",
		Q("100011").RepresentsNumberInDecimalForm(), TRUE)
EndScenario()

Summary()
