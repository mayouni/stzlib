load "../../stzBase.ring"
load "../_narrated.ring"

# IsEither(a, :Or = b). Archive block #470.

Scenario("Sun or moon")
	str = "sun"
	Then("sun is either moon or sun", Q(str).IsEither("moon", :Or = "sun"), TRUE)
EndScenario()

Summary()
