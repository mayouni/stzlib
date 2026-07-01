load "../../stzBase.ring"
load "../_narrated.ring"

# Empty-substring safety: FindZZ("") finds nothing (not an error), and
# Replace("", new) is a no-op -- unlike Ring's substr which raises. Archive #260.

Scenario("Finding / replacing an empty substring is safe")
	Given('" isNumber( 0+  @item  ) "')
	o1 = new stzString(" isNumber( 0+  @item  ) ")
	Then("FindZZ('') returns an empty list", ListEq( o1.FindZZ(""), [ ] ), TRUE)
	o1.Replace("", "any")
	Then("Replace('', 'any') leaves the content unchanged",
		o1.Content(), " isNumber( 0+  @item  ) ")
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
