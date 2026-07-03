load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveEmptyLinesQ drops the leading empty lines and keeps the data
# rows (trailing spaces preserved). Archive block #512.

Scenario("Cleaning empty lines from semi-structured data")
	o1 = new stzString("

.;1;.;.;.
1;2;3;4;5
.;3;.;.;.
.;4;.;.;.
.;5;.;.;.  " )
	Then("only the data lines remain",
		ListEq( Q(o1.RemoveEmptyLinesQ().Content()).Lines(),
			[ ".;1;.;.;.", "1;2;3;4;5", ".;3;.;.;.", ".;4;.;.;.", ".;5;.;.;.  " ] ), TRUE)
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
