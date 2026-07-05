load "../../stzBase.ring"
load "../_narrated.ring"

# FindWF (function form) finds the items a predicate accepts. The
# retired FindWXT / textual-W form can't call arbitrary methods/funcs
# -- the W DSL only lowers engine predicates -- so a func predicate
# (real Ring logic) is the right tool. Extracted from stzlisttest.ring,
# block #264 (migrated from the retired WXT form).

Scenario("The numeric rows of a table")
	o1 = new stzList([ "ABCDEF", "GHIJKL", "123346", "MNOPQU", "RSTUVW", "984332" ])
	Then("rows 3 and 6 are numbers",
		ListEq( o1.FindWF( func it { return isNumberInString(it) } ),
			[ 3, 6 ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if aA[i] != aE[i] return FALSE ok
	next
	return TRUE
