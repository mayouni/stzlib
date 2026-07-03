load "../../stzBase.ring"
load "../_narrated.ring"

# UpTo/DownTo generalize Ring's "A":"E" range syntax to any Unicode
# char (Ring's own : is ASCII/byte-bound). Archive block #635.

Scenario("Ranges, Ring and Softanza")
	Then("Ring's forward range",
		ListEq( "A" : "E", [ "A", "B", "C", "D", "E" ] ), TRUE)
	Then("... and backward",
		ListEq( "E" : "A", [ "E", "D", "C", "B", "A" ] ), TRUE)
	Then("UpTo mirrors it",
		ListEq( Q("A").UpTo("E"), [ "A", "B", "C", "D", "E" ] ), TRUE)
	Then("DownTo too",
		ListEq( Q("E").DownTo("A"), [ "E", "D", "C", "B", "A" ] ), TRUE)
	Then("and it speaks Arabic",
		ListEq( Q("ب").UpTo("ج"), [ "ب", "ة", "ت", "ث", "ج" ] ), TRUE)
	Then("... in both directions",
		ListEq( Q("ج").DownTo("ب"), [ "ج", "ث", "ت", "ة", "ب" ] ), TRUE)
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
