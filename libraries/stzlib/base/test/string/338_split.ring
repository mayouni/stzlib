load "../../stzBase.ring"
load "../_narrated.ring"

# A fluent split-and-filter chain: SplitQ gives a stzList, IfQ gates the
# rest of the chain on a condition (here written WITHOUT the This. prefix),
# and RemoveFirstAndLastItemsQ trims the ends. (The archive notes the ELSE
# case of IfQ as a #TODO better suited to stzChainOfValue -- behavior when
# the condition FAILS stays undefined here.) Archive block #338.

Scenario("Conditional fluent chain on a split result")
	Given('"**aa***aa**aa***"')
	o1 = new stzString("**aa***aa**aa***")
	Then("the middle parts survive the IfQ gate",
		ListEq( o1.SplitQ("aa").IfQ('NumberOfItems() > 2').RemoveFirstAndLastItemsQ().Content(),
			[ "***", "**" ] ), TRUE)
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
