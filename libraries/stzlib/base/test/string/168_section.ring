load "../../stzBase.ring"
load "../_narrated.ring"

# Section(:From = a, :To = b) -- per the ORIGINAL SectionCS, the :From
# anchor resolves to its FIRST occurrence and the :To anchor to its
# LAST (FindFirstCS / FindLastCS), so F..A on SOFTANZA spans "FTANZA".
# (Archive block #168's #--> "FTA" contradicted the original impl and
# its sibling block #523; the impl wins.) The char-LIST Section keeps
# its own first-occurrence anchors (list domain). Archive block #168.

Scenario("A section delimited by chars")
	Then("Section(:From='F', :To='A') spans to the LAST A",
		Q("SOFTANZA").Section(:From = "F", :To = "A"), "FTANZA")
	Then("the char-list twin anchors on the first A",
		ListEq( Q("SOFTANZA").CharsQ().Section(:From = "F", :To = "A"), [ "F", "T", "A" ] ), TRUE)
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
