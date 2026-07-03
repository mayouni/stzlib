load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveBoundedSubString removes the BOUNDED occurrences' content only
# -- the bare first and trailing "word"s stay, the bounds stay. (The
# archive #--> had dropped the first bare word by typo -- inconsistent
# with its sibling #570 whose IB removal keeps it.) Archive block #569.

Scenario("Removing the bounded words")
	o1 = new stzString("bla word bla <<word>> bla bla <<word>> bla <<word>> word")
	o1.RemoveBoundedSubString("word")
	Then("only the bounded contents vanish",
		o1.Content(), "bla word bla <<>> bla bla <<>> bla <<>> word")
EndScenario()

Summary()
