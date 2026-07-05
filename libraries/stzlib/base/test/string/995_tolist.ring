load "../../stzBase.ring"
load "../_narrated.ring"

# ToList expands char RANGES inside the string -- latin and Arabic
# alike (the archive listed the raw chars of the source string, the
# pre-range-expansion behavior; ToList has expanded ranges since the
# chunk-37 UpTo/DownTo generalisation). Archive block #995.

Scenario("Two ranges in strings")
	Then("A through C",
		ListEq( Q(' "A" : "C" ').ToList(), [ "A", "B", "C" ] ), TRUE)
	Then("alif through jim",
		ListEq( Q(' "ا" : "ج" ').ToList(),
			[ "ا", "ب", "ة", "ت", "ث", "ج" ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if aA[i] != aE[i] return FALSE ok
	next
	return TRUE
