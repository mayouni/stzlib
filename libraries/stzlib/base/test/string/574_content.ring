load "../../stzBase.ring"
load "../_narrated.ring"

# Replacing one bounded content, method and ReplaceXT spellings.
# Archive block #574.

Scenario("Fixing the noword")
	o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
	o1.ReplaceSubStringBoundedBy("noword", [ "<<", ">>" ], :With = "word")
	Then("the method form", o1.Content(), "bla bla <<word>> bla bla <<word>> bla <<word>>")
	o2 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
	o2.ReplaceXT("noword", :BoundedBy = ["<<", ">>"], :With = "word")
	Then("the XT form", o2.Content(), "bla bla <<word>> bla bla <<word>> bla <<word>>")
EndScenario()

Summary()
