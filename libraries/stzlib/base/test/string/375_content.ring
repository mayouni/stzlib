load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT(what, :After = anchor) inserts right after the anchor substring
# (:To works too). Archive block #375.

Scenario("Adding after an anchor")
	Given('"Ring programmin language."')
	o1 = new stzString("Ring programmin language.")
	o1.AddXT("g", :After = "programmin")
	Then("the missing g lands", o1.Content(), "Ring programming language.")
EndScenario()

Summary()
