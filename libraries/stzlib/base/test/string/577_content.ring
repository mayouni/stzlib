load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveAnySubStringBoundedBy empties every region, keeping the bounds.
# Archive block #577.

Scenario("Emptying the regions")
	o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
	o1.RemoveAnySubStringBoundedBy([ "<<", ">>" ])
	Then("the shells remain", o1.Content(), "bla bla <<>> bla bla <<>> bla <<>>")
EndScenario()

Summary()
