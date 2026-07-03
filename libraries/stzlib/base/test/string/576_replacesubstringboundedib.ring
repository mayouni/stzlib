load "../../stzBase.ring"
load "../_narrated.ring"

# The IB replace swallows the bounds too. Archive block #576.

Scenario("Replacing bounded blocks whole")
	o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>.")
	o1.ReplaceSubStringBoundedByIB("word", [ "<<", ">>" ], "WORD")
	Then("the method form", o1.Content(), "bla bla WORD bla bla WORD bla WORD.")
	o2 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>.")
	o2.ReplaceXT("word", :BoundedByIB = ["<<", ">>"], :With = "WORD")
	Then("the XT form", o2.Content(), "bla bla WORD bla bla WORD bla WORD.")
EndScenario()

Summary()
