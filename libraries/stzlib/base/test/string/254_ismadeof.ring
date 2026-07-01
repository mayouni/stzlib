load "../../stzBase.ring"
load "../_narrated.ring"

# IsMadeOf(sub) / IsMadeOf([parts]) -- is the whole string made only of the
# given substring(s)? IsMadeOfNumbers() -- only digits? Archive block #254.

Scenario("Checking what a string is made of")
	Then("'121212' is made of '12'", Q("121212").IsMadeOf("12"), TRUE)
	Then("'121212' is made of ['1','2']", Q("121212").IsMadeOf([ "1", "2" ]), TRUE)
	Then("'984332' is made of numbers", Q("984332").IsMadeOfNumbers(), TRUE)
EndScenario()

Summary()
