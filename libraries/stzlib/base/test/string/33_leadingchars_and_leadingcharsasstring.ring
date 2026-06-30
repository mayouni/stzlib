load "../../stzBase.ring"
load "../_narrated.ring"

# Leading / trailing run of identical chars. The list form and the string form:
#   LeadingChars()         -> the chars as a LIST    (e.g. [ "-", "-", "-" ])
#   LeadingCharsAsString() -> the run as a STRING    (e.g. "---")
#   LeadingCharsXT() / ...AsSubString() -- string-form aliases.
# Archive block #33.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): LeadingChars()/TrailingChars() must
# return a LIST, but currently return the STRING "---" (and the string aliases
# delegate to them). The string-form aliases are asserted below; LeadingChars()/
# TrailingChars() are exercised as un-asserted NOTEs until the fix-pass.

Scenario("The leading / trailing run as a string (alias forms)")
	Given('"---Ring"')
	o1 = new stzString("---Ring")
	Then("LeadingCharsAsString() is the run as a string", o1.LeadingCharsAsString(), "---")
	Then("LeadingCharsXT() is the same", o1.LeadingCharsXT(), "---")
	Then("LeadingChars() is the run as a LIST", ListEq( o1.LeadingChars(), [ "-", "-", "-" ] ), TRUE)

	Given('"Ring---"')
	o2 = new stzString("Ring---")
	Then("TrailingCharsXT() is the trailing run as a string", o2.TrailingCharsXT(), "---")
	Then("TrailingChars() is the run as a LIST", ListEq( o2.TrailingChars(), [ "-", "-", "-" ] ), TRUE)
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
