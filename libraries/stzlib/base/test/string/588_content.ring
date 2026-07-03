load "../../stzBase.ring"
load "../_narrated.ring"

# AddBounds wraps the content. Archive block #588.

Scenario("Wrapping a word")
	o1 = new stzString("word")
	o1.AddBounds(["<<",">>"])
	Then("bounded", o1.Content(), "<<word>>")
EndScenario()

Summary()
