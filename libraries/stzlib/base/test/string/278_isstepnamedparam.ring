load "../../stzBase.ring"
load "../_narrated.ring"

# IsStepNamedParam() recognises a :Step = [...] named-param list; the more general
# IsOneOfTheseNamedParams accepts any of a set of keywords. Archive block #278.

Scenario("Recognising a :Step named param")
	Then("':Step = [3, :Andthen=2]' is a step named param",
		Q( :Step = [ 3, :Andthen = 2 ] ).IsStepNamedParam(), TRUE)
	Then("it is one of :Step / :Stepping / :EachNChars",
		Q( :Step = [ 3, :Andthen = 2 ] ).IsOneOfTheseNamedParams([ :Step, :Stepping, :EachNChars ]), TRUE)
EndScenario()

Summary()
