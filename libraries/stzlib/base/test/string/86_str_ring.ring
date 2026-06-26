load "../../stzBase.ring"
load "../_narrated.ring"

# Plain Ring string indexing on a large (40000-char) buffer: first and last char.
# Archive block #86.

Scenario("Indexing the ends of a big string")
	str = ""
	for i = 1 to 10000
		str += "ring"
	next
	Given("a 40000-char string of repeated 'ring'")
	Then("str[1] is the first char", str[1], "r")
	Then("str[len(str)] is the last char", str[len(str)], "g")
EndScenario()

Summary()
