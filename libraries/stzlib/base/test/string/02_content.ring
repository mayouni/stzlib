load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveFirstAndLastChars -- drop the first and last character of the string.

Scenario("RemoveFirstAndLastChars strips the outer characters")
	Given("a string wrapped in [ and ]")
	Then("removing the first and last chars leaves the inner content",
		RemovedEnds(), ' @$2{"a";1;[1]}U ')
EndScenario()

Summary()

func RemovedEnds
	o = new stzString('[ @$2{"a";1;[1]}U ]')
	o.RemoveFirstAndLastChars()
	return o.Content()
