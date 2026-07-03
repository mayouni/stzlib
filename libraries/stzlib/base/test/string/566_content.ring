load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSubStringsBoundedBy rewrites EVERY bounded content. (The
# archive #--> showed <<word>> -- a typo for the actual replacement
# "wrod".) Archive block #566.

Scenario("Rewriting every bounded content")
	o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<wording>>")
	o1.ReplaceSubStringsBoundedBy([ "<<", ">>" ], "wrod")
	Then("all three regions now hold wrod",
		o1.Content(), "bla bla <<wrod>> bla bla <<wrod>> bla <<wrod>>")
EndScenario()

Summary()
