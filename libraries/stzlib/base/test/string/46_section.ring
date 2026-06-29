load "../../stzBase.ring"
load "../_narrated.ring"

# Section(n1, n2) / SectionXT(n1, n2). Section is direction-agnostic: it auto-
# orders the bounds, so Section(5, 3) == Section(3, 5). SectionXT adds negative
# indexing (count from the end). All of this works on stzList too. Archive #46.
#
# SectionXT also REVERSES when n1 > n2 ("543", "876"), where plain Section
# would auto-order to the forward span.

Scenario("Sections of a string, forward and from the end")
	Given('"123456789"')
	o1 = new stzString("123456789")
	Then("Section(3, 5) is the 3..5 span", o1.Section(3, 5), "345")
	Then("Section(5, 3) auto-orders to the same span", o1.Section(5, 3), "345")
	Then("SectionXT(-4, -2) counts from the end", o1.SectionXT(-4, -2), "678")
	Then("SectionXT(5, 3) reverses the span", o1.SectionXT(5, 3), "543")
	Then("SectionXT(-2, -4) reverses from the end", o1.SectionXT(-2, -4), "876")
EndScenario()

Scenario("The same Section works on a stzList")
	Given('new stzList("1":"9")')
	o2 = new stzList("1":"9")
	Then("Section(3, 5) is the 3..5 span", ListEq(o2.Section(3, 5), [ "3", "4", "5" ]), TRUE)
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
