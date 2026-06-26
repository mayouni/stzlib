load "../../stzBase.ring"
load "../_narrated.ring"

# SubStringsBoundedBy('"') -- the substrings enclosed by a single quote-mark bound.
# (Unlike BoundedBy("&"), this single-bound form works.) Archive block #217.

Scenario("Extracting quoted segments")
	Given('a line with two double-quoted segments')
	o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')
	Then("both quoted contents are returned, spaces preserved",
		ListEq( o1.SubStringsBoundedBy('"'), [ "<    leave spaces    >", "< leave spaces >" ] ), TRUE)
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
