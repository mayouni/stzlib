load "../../stzBase.ring"
load "../_narrated.ring"

# AllCharsAreXT with an evaluation-direction option, and the raw Check()
# predicate over each char. Archive block #481 (check variant).

Scenario("Multi-kind check and a raw predicate")
	Then("248 chars are even positive numbers (RTL evaluation)",
		Q("248").AllCharsAreXT([ :Even, :Positive, :Numbers ], :EvaluateFrom = :RTL), TRUE)
	Then("every char of 123 passes the raw isnumber check",
		Q("123").Check( 'isnumber( 0+(@char) )' ), TRUE)
EndScenario()

Summary()
