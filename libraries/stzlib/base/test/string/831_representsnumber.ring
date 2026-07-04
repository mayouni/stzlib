load "../../stzBase.ring"
load "../_narrated.ring"

# The Represents* number-literal family on an octal REAL.
# Archive block #831.

Scenario("An octal real, sixteen questions")
	o1 = new stzString("0o20723.034")
	Then("a number", o1.RepresentsNumber(), TRUE)
	Then("not signed", o1.RepresentsSignedNumber(), FALSE)
	Then("so unsigned", o1.RepresentsUnsignedNumber(), TRUE)
	Then("calculable", o1.RepresentsCalculableNumber(), TRUE)
	Then("not an integer (it has a dot)", o1.RepresentsInteger(), FALSE)
	Then("nor a signed one", o1.RepresentsSignedInteger(), FALSE)
	Then("nor an unsigned one", o1.RepresentsUnsignedInteger(), FALSE)
	Then("nor calculable-as-integer", o1.RepresentsCalculableInteger(), FALSE)
	Then("a real number", o1.RepresentsRealNumber(), TRUE)
	Then("not a signed real", o1.RepresentsSignedRealNumber(), FALSE)
	Then("an unsigned real", o1.RepresentsUnsignedRealNumber(), TRUE)
	Then("a calculable real", o1.RepresentsCalculableRealNumber(), TRUE)
	Then("not decimal-form", o1.RepresentsNumberInDecimalForm(), FALSE)
	Then("not binary-form", o1.RepresentsNumberInBinaryForm(), FALSE)
	Then("not hex-form", o1.RepresentsNumberInHexForm(), FALSE)
	Then("octal-form", o1.RepresentsNumberInOctalForm(), TRUE)
EndScenario()

Summary()
