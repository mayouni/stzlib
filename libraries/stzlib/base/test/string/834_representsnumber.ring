load "../../stzBase.ring"
load "../_narrated.ring"

# Hex and octal forms, with digit-group underscores, and NumberForm.
# Archive block #834.

Scenario("A hex real with underscores")
	o1 = new stzString("0x12_5AB34.123F")
	Then("a number", o1.RepresentsNumber(), TRUE)
	Then("its form", o1.NumberForm(), :Hex)
	Then("hex-form indeed", o1.RepresentsNumberInHexForm(), TRUE)
EndScenario()

Scenario("An octal real")
	o2 = new stzString("0o2304.307")
	Then("a number", o2.RepresentsNumber(), TRUE)
	Then("its form", o2.NumberForm(), :Octal)
	Then("octal-form indeed", o2.RepresentsNumberInOctalForm(), TRUE)
EndScenario()

Summary()
