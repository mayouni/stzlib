load "../../stzBase.ring"
load "../_narrated.ring"

# The Turkish dotless i: script and cases. Archive block #654.

Scenario("The letter that broke Qt")
	Then("its script reads latin", TQ("ı").Script(), :Latin)
	Then("it is lowercase", Q("ı").StringCase(), :Lowercase)
	Then("its dotted capital is uppercase", Q("İ").StringCase(), :Uppercase)
EndScenario()

Summary()
