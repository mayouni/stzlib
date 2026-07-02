load "../../stzBase.ring"
load "../_narrated.ring"

# A four-block medley: the substring-W finders; counting all vs unique
# substrings; the SubStrings/Z/ZZ family on "ABA" (all windows, unique
# ones, and each unique grouped with positions / sections -- NOTE: the
# archive's SubStrings() enumeration order differs, its multiset is
# identical; asserted at the impl's i-major order); a case-insensitive
# IsEitherCS; and the auto-detected Bounds with N-char caps.
# Archive block #366.

Scenario("Finding substrings by condition")
	Given('"...♥♥...♥♥..."')
	o1 = new stzString("...♥♥...♥♥...")
	Then("the matching substrings",
		ListEq( o1.FindSubStringsW('{ @SubString = "♥♥" }'), [ "♥♥", "♥♥" ] ), TRUE)
	Then("... and their spans",
		ListEq( o1.FindSubStringsWZZ('{ @SubString = "♥♥" }'), [ [4, 5], [9, 10] ] ), TRUE)
EndScenario()

Scenario("Counting substrings")
	Given('"..ONE..TWO..ONE.."')
	o1 = new stzString("..ONE..TWO..ONE..")
	Then("all substrings", o1.NumberOfSubStrings(), 153)
	Then("unique substrings", o1.NumberOfUniqueSubStrings(), 120)
EndScenario()

Scenario("The SubStrings family on ABA")
	o1 = new stzString("ABA")
	Then("all windows (i-major order, dup A kept)",
		ListEq( o1.SubStrings(), [ "A", "AB", "ABA", "B", "BA", "A" ] ), TRUE)
	Then("the unique set",
		ListEq( o1.UniqueSubStrings(), [ "A", "AB", "ABA", "B", "BA" ] ), TRUE)
	Then("each unique grouped with its positions",
		ListEq( o1.SubStringsZ(),
			[ [ "A", [1, 3] ], [ "AB", [1] ], [ "ABA", [1] ],
			  [ "B", [2] ], [ "BA", [2] ] ] ), TRUE)
	Then("... and with its sections",
		ListEq( o1.SubStringsZZ(),
			[ [ "A", [ [1,1], [3,3] ] ], [ "AB", [ [1,2] ] ],
			  [ "ABA", [ [1,3] ] ], [ "B", [ [2,2] ] ],
			  [ "BA", [ [2,3] ] ] ] ), TRUE)
EndScenario()

Scenario("Case-insensitive either-check and capped bounds")
	Then('one IS either ONE or TWO, case aside',
		Q("one").IsEitherCS("ONE", :Or = "TWO", :CS = FALSE), TRUE)
	o1 = new stzString("<<<word>>>")
	Then("the auto-detected bounds", ListEq( o1.Bounds(), [ "<<<", ">>>" ] ), TRUE)
	Then("capped at 2 a side",
		ListEq( o1.BoundsXT(:UpToNChars = 2), [ "<<", ">>" ] ), TRUE)
	Then("capped per side",
		ListEq( o1.BoundsXT([ 1, 2 ]), [ "<", ">>" ] ), TRUE)
	Then("the UpToNChars spelling",
		ListEq( o1.BoundsUpToNChars(2), [ "<<", ">>" ] ) and
		ListEq( o1.BoundsUpToNChars([ 1, 2 ]), [ "<", ">>" ] ), TRUE)
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
