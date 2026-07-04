load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(:Nth = n, sub) -- selector-first spelling.
# Archive block #894.

Scenario("The fourth heart")
	o1 = new stzString("_/♥\_/♥\_/♥♥\_/♥\_")
	o1.RemoveXT(:Nth = 4, "♥")
	Then("the double becomes single",
		o1.Content(), "_/♥\_/♥\_/♥\_/♥\_")
EndScenario()

Summary()
