load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceXT([], :BoundedBy = [open, close], :With = new) replaces the content
# between the bounds (no explicit sub needed). Archive block #194.

Scenario("Replacing content between bounds")
	Given('"bla bla <<♥♥♥>> and bla!"')
	o1 = new stzString("bla bla <<♥♥♥>> and bla!")
	o1.ReplaceXT( [], :BoundedBy = ["<<",">>"], :With = "bla" )
	Then("the bounded content is replaced", o1.Content(), "bla bla <<bla>> and bla!")
EndScenario()

Summary()
