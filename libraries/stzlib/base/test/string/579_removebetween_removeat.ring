load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT at explicit positions -- one or many. Archive block #579.

Scenario("Surgical removes")
	o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
	o1.RemoveXT("word", :AtPosition = 11)
	Then("one occurrence removed",
		o1.Content(), "bla bla <<>> bla bla <<noword>> bla <<word>>")
	o2 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
	o2.RemoveXT("word", :AtPositions = [ 11, 43 ])
	Then("two occurrences removed",
		o2.Content(), "bla bla <<>> bla bla <<noword>> bla <<>>")
EndScenario()

Summary()
