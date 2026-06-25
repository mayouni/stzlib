load "../../stzBase.ring"
load "../_narrated.ring"

# THE Q-ELEVATION RULE for arithmetic-style operators (*, /, -)
# ------------------------------------------------------------
# Softanza's Q() lifts a raw value into a chainable Softanza object. The same
# idea governs the (*), (/) and (-) operators on a wrapped collection:
#
#   * a RAW scalar on the right  -> a RAW result (a plain Ring list / string),
#       handy to print or pass to Ring code directly.
#   * a Q()-wrapped scalar (or any numeric stz-object) on the right -> the
#       SAME content, but ELEVATED into a chainable stz object, so you can keep
#       querying:  ( Q(paList) * Q(n) ).Content()...  ( Q(str) / Q(n) ).Sorted()...
#
# The CONTENT is identical either way -- only the wrapper differs. The rule is
# the same in stzList and stzString (and stzNumber for scalar arithmetic).
#
# EXCEPTION -- (+): for (+) the right operand is the PAYLOAD being added (not a
# transform parameter), so Q() there is not an elevation signal; (+) adds the
# operand. Use the dedicated Q/These/TheseQ forms (see 424) for elevation in (+)
# chains.

Scenario("stzList (*): repeat -- raw stays raw, Q() elevates")
	Given("the list [1, 2, 3]")
	Then("* 4 returns a RAW list", isList( Q([1,2,3]) * 4 ), TRUE)
	Then("* 4 content is the flat 4x repeat", ListEq( Q([1,2,3]) * 4, [1,2,3,1,2,3,1,2,3,1,2,3] ), TRUE)
	Then("* Q(4) returns an stz OBJECT", isObject( Q([1,2,3]) * Q(4) ), TRUE)
	Then("( * Q(4) ).Content() equals * 4", ListEq( ( Q([1,2,3]) * Q(4) ).Content(), Q([1,2,3]) * 4 ), TRUE)
	Then("the elevated result chains", ListEq( ( Q([1,2,3]) * Q(2) ).Reversed(), [3,2,1,3,2,1] ), TRUE)
	Then("a numeric stz-object (TRUEObject ~> 1) also elevates", ListEq( ( Q(["A","B"]) * TRUEObject() ).Content(), ["A","B"] ), TRUE)
EndScenario()

Scenario("stzList (/): chunk -- raw stays raw, Q() elevates")
	Given("the list [1, 2, 3, 4, 5, 6]")
	Then("/ 3 returns a RAW list", isList( Q([1,2,3,4,5,6]) / 3 ), TRUE)
	Then("/ Q(3) returns an stz OBJECT", isObject( Q([1,2,3,4,5,6]) / Q(3) ), TRUE)
	Then("( / Q(3) ).Content() equals / 3", ListEq( ( Q([1,2,3,4,5,6]) / Q(3) ).Content(), Q([1,2,3,4,5,6]) / 3 ), TRUE)
EndScenario()

Scenario("stzList (-): remove -- raw stays raw, Q() elevates")
	Given("the range 1..5")
	Then("- 3 returns a RAW list", isList( Q(1:5) - 3 ), TRUE)
	Then("- Q(3) returns an stz OBJECT", isObject( Q(1:5) - Q(3) ), TRUE)
	Then("( - Q(3) ).Content() equals - 3", ListEq( ( Q(1:5) - Q(3) ).Content(), Q(1:5) - 3 ), TRUE)
EndScenario()

Scenario("stzString (*) and (/): same rule")
	Given('the strings "ABC" and "ABCDEF"')
	Then('"ABC" * 3 is the raw string ABCABCABC', Q("ABC") * 3, "ABCABCABC")
	Then("* Q(3) returns an stz OBJECT", isObject( Q("ABC") * Q(3) ), TRUE)
	Then("( * Q(3) ).Content() equals * 3", ( Q("ABC") * Q(3) ).Content(), Q("ABC") * 3)
	Then("/ 3 returns a RAW list", isList( Q("ABCDEF") / 3 ), TRUE)
	Then("/ Q(3) returns an stz OBJECT", isObject( Q("ABCDEF") / Q(3) ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if NOT (isList(aA) and isList(aE)) return FALSE ok
	if len(aA) != len(aE) return FALSE ok
	for i = 1 to len(aA)
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
