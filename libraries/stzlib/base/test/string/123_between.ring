load "../../stzBase.ring"
load "../_narrated.ring"

# Between(open, :And = close) and BoundedBy([open, close]) -- the substrings
# enclosed between a DISTINCT open/close pair. Archive block #123. (With a
# distinct [open,close] pair these work; the single-repeated-bound form is broken
# -- see block #121 and _AUDIT_DEFECTS.md.)

Scenario("The text enclosed between distinct bounds")
	Given('"<<***>>**<<***>>"')
	o1 = new stzString("<<***>>**<<***>>")
	Then("Between('<<', :And='>>') gives the enclosed parts",
		ListEq( o1.Between("<<", :and = ">>"), [ "***", "***" ] ), TRUE)
	Then("BoundedBy(['<<','>>']) agrees",
		ListEq( o1.BoundedBy([ "<<", ">>" ]), [ "***", "***" ] ), TRUE)
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
