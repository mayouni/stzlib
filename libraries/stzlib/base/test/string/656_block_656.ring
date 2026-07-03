load "../../stzBase.ring"
load "../_narrated.ring"

# Composed vs decomposed: the precomposed e-circumflex (U+00EA) and the
# e + combining circumflex pair look alike but differ -- Unicode() gives
# a NUMBER for the single char and the codepoint LIST for the pair, and
# CharsNames() names both parts. (Built programmatically so no editor
# normalizes the decomposed literal away.) Archive block #656.

Scenario("Two lookalike circumflexed e's")
	cComposed = StzEngineCharToUtf8(234)
	cDecomposed = "e" + StzEngineCharToUtf8(770)
	Then("Ring sees them different", cComposed = cDecomposed, FALSE)
	Then("Softanza too", Q(cComposed).IsEqualTo(cDecomposed), FALSE)
	Then("the composed one is one char", Q(cComposed).NumberOfChars(), 1)
	Then("... with codepoint 234", Q(cComposed).Unicode(), 234)
	Then("the decomposed one is two chars", Q(cDecomposed).NumberOfChars(), 2)
	Then("... with two codepoints",
		ListEq( Q(cDecomposed).Unicode(), [101, 770] ), TRUE)
	Then("the composed char's name",
		Q(cComposed).CharName(), "LATIN SMALL LETTER E WITH CIRCUMFLEX")
	Then("the decomposed pair's names",
		ListEq( Q(cDecomposed).CharsNames(),
			[ "LATIN SMALL LETTER E", "COMBINING CIRCUMFLEX ACCENT" ] ), TRUE)
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
