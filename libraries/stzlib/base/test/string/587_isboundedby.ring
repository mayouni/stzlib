load "../../stzBase.ring"
load "../_narrated.ring"

# IsBoundedBy + RemoveTheseBounds. Archive block #587.

Scenario("Checking and stripping bounds")
	o1 = new stzString("<<word>>")
	Then("it is angle-bounded", o1.IsBoundedBy(["<<", ">>"]), TRUE)
	o1.RemoveTheseBounds("<<",">>")
	Then("stripped", o1.Content(), "word")
EndScenario()

Summary()
