load "../../stzBase.ring"
load "../_narrated.ring"

# IsNumberInString: does the string hold a (decimal) number? Method and
# global forms. Archive block #458.

Scenario("A decimal in a string")
	Then("the method form", Q("123.98").IsNumberInString(), TRUE)
	Then("the global form", IsNumberInString("123.98"), TRUE)
EndScenario()

Summary()
