load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceFirstNChars / ReplaceLastNChars. Archive block #778.

Scenario("Swapping the ends")
	o1 = new stzString("---Ring!")
	o1.ReplaceFirstNChars(3, :With = "Hi ")
	Then("head replaced", o1.Content(), "Hi Ring!")
	o2 = new stzString("Hi Ring---")
	o2.ReplaceLastNChars(3, :With = "!")
	Then("tail replaced", o2.Content(), "Hi Ring!")
EndScenario()

Summary()
