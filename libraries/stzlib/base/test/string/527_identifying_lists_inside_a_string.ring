load "../../stzBase.ring"
load "../_narrated.ring"

# Lists hosted in strings: recognition (normal [..] and short a:b
# forms), form conversion, and runtime evaluation back to a real list.
# The To*Form converters render at the canonical @@ spacing
# ("[ 1, 2, 3 ]" -- the archive showed hand-typed "[1, 2, 3]").
# Archive block #527.

Scenario("Recognizing lists in strings")
	Then("a normal-form list", StzStringQ('[1,2,3]').IsListInString(), TRUE)
	Then("a short-form range", StzStringQ('1:3').IsListInString(), TRUE)
	Then("a char range", StzStringQ(' "A":"C" ').IsListInString(), TRUE)
	Then("an Arabic char range", StzStringQ(' "ا":"ج" ').IsListInString(), TRUE)
	Then("the normal form named", StzStringQ('[1,2,3]').IsListInNormalForm(), TRUE)
	Then("the short form named", StzStringQ('1:3').IsListInShortForm(), TRUE)
	Then("... for char ranges too", StzStringQ(' "A":"C" ').IsListInShortForm(), TRUE)
	Then("... and Arabic ones", StzStringQ(' "ا":"ج" ').IsListInShortForm(), TRUE)
EndScenario()

Scenario("Contiguity of the hosted list")
	Then("[1,3] is not contiguous", StzStringQ('[1,3]').IsContiguousListInString(), FALSE)
	Then("1:3 is", StzStringQ('1:3').IsContiguousListInString(), TRUE)
	Then("A:C is", StzStringQ(' "A":"C" ').IsContiguousListInString(), TRUE)
	Then("the Arabic range is", StzStringQ(' "ا":"ج" ').IsContiguousListInString(), TRUE)
	Then("IsContiguous on a real range", IsContiguous(1:3), TRUE)
	Then("... and on a char range", IsContiguous("A":"E"), TRUE)
	Then("contiguous + normal form",
		StzStringQ('[1,2,3]').IsContiguousListInNormalForm(), TRUE)
	Then("contiguous + short form",
		StzStringQ('1:3').IsContiguousListInShortForm(), TRUE)
	Then("... char ranges",
		StzStringQ(' "A":"C" ').IsContiguousListInShortForm(), TRUE)
	Then("... Arabic ranges",
		StzStringQ(' "ا":"ج" ').IsContiguousListInShortForm(), TRUE)
EndScenario()

Scenario("Converting between the forms")
	Then("normal to short", StzStringQ('[1,2,3]').ToListInShortForm(), "1 : 3")
	Then("short to normal", StzStringQ('1:3').ToListInNormalForm(), "[ 1, 2, 3 ]")
	Then("a string list to short",
		StzStringQ(' ["A","B","C","D"] ').ToListInShortForm(), '"A" : "D"')
	Then("an Arabic range to short",
		StzStringQ(' "ا":"ج" ').ToListInShortForm(), '"ا" : "ج"')
	Then("the default rendering is normal",
		StzStringQ('[1,2,3]').ToListInString(), "[ 1, 2, 3 ]")
	Then("... whatever hosted it", StzStringQ('1:3').ToListInString(), "[ 1, 2, 3 ]")
	Then("... expanding char ranges",
		StzStringQ(' "A":"C" ').ToListInString(), '[ "A", "B", "C" ]')
	Then("the SF abbreviation",
		StzStringQ('[1,2, 3]').ToListInStringSF(), "1 : 3")
	Then("... on a short host", StzStringQ('1:3').ToListInStringSF(), "1 : 3")
	Then("... on a string list",
		StzStringQ(' ["A","B","C","D"] ').ToListInStringSF(), '"A" : "D"')
	Then("... on an Arabic list",
		StzStringQ(' [ "ا", "ب", "ة", "ت" ] ').ToListInStringSF(), '"ا" : "ت"')
EndScenario()

Scenario("Evaluating back to a live list")
	Then("a number range", ListEq( StzStringQ('1:3').ToList(), [1, 2, 3] ), TRUE)
	Then("a char range",
		ListEq( StzStringQ(' "A":"C" ').ToList(), ["A", "B", "C"] ), TRUE)
	Then("an Arabic char range",
		ListEq( StzStringQ(' "ا":"ج" ').ToList(),
			[ "ا", "ب", "ة", "ت", "ث", "ج" ] ), TRUE)
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
