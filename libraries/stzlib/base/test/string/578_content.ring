load "../../stzBase.ring"
load "../_narrated.ring"

# The IB variant removes the bounds as well. Archive block #578.

Scenario("Removing the regions whole")
	o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
	o1.RemoveAnySubStringBoundedByIB([ "<<", ">>" ])
	Then("nothing but the blas", o1.Content(), "bla bla  bla bla  bla ")
EndScenario()

Summary()
