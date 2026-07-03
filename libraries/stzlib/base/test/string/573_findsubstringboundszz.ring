load "../../stzBase.ring"
load "../_narrated.ring"

# FindTheseSubStringBounds: only occurrences IMMEDIATELY bounded by the
# EXPLICIT tokens count (noword's inner word and _word_ do not);
# RemoveTheseSubStringBounds strips just those tokens. (The archive
# #--> of the plain FindSubStringBoundsZZ line was a copy-paste of the
# These-form's flat value.) Archive block #573.

Scenario("Explicitly bounded words")
	o1 = new stzString("bla word bla <<word>> bla bla <<noword>> bla <<word>> word _word_")
	Then("the token positions, flat",
		ListEq( o1.FindTheseSubStringBounds("word", [ "<<", ">>" ]),
			[ 14, 20, 46, 52 ] ), TRUE)
	Then("their spans",
		ListEq( o1.FindTheseSubStringBoundsZZ("word", [ "<<", ">>" ]),
			[ [14, 15], [20, 21], [46, 47], [52, 53] ] ), TRUE)
	o1.RemoveTheseSubStringBounds("word", [ "<<", ">>" ])
	Then("only those tokens vanish",
		o1.Content(), "bla word bla word bla bla <<noword>> bla word word _word_")
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
