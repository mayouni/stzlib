# Narrative
# --------
# THE UNIFICATION PROTOTYPE: one lexicon shared by the natural-programming
# stack (stzNatural execution) and the reflection stack (Ask/Explain).
#
# Softanza held the same lexical fact -- "these surface words mean this
# canonical action" -- in three copies: stzNatural's :semantic_mappings,
# stzNaturalCode's _ActionsXT form glossary, and the #@ aka retrieval tags
# in the class sources. stzSemanticResolver merges them into ONE
# semantic-ID-keyed lexicon, and stzNatural consults it as a fallback for
# words its dictionary does not know.
#
# Net effect proven here: "Capitals it" executes METHOD_UPPERCASE although
# "capitals" appears nowhere in the semantic dictionary -- it is recovered
# from the #@ aka tags of Uppercase ("upper case, capitals, all caps").
# Provenance guards guarantee quoted VALUES are never hijacked: 'Create a
# string with "capitals"' keeps its literal.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("The unified lexicon resolves paraphrases to canonical semantic IDs")
	Given("the merged lexicon (dictionary seed + _ActionsXT forms + #@ aka tags)")
	Then("'caps' (an Uppercase aka word) -> METHOD_UPPERCASE",
		StzResolveSemantic("caps"), "METHOD_UPPERCASE")
	Then("'capitals' -> METHOD_UPPERCASE",
		StzResolveSemantic("capitals"), "METHOD_UPPERCASE")
	Then("'mirrored' (a Reversed aka word) -> METHOD_REVERSE",
		StzResolveSemantic("mirrored"), "METHOD_REVERSE")
	Then("'frame' (dictionary synonym, also merged) -> METHOD_BOX",
		StzResolveSemantic("frame"), "METHOD_BOX")
	Then("gibberish 'zzqx' resolves to nothing",
		StzResolveSemantic("zzqx"), "")
	Then("too-short 'up' resolves to nothing",
		StzResolveSemantic("up"), "")
EndScenario()

Scenario("Naturally() executes paraphrases absent from its dictionary")
	When("natural code uses 'Capitals' -- not a dictionary word")
	o1 = Naturally("Create a string with 'softanza' Capitals it")
	Then("the generated Ring code calls Uppercase()",
		StzFindFirst(o1.Code(), "Uppercase()") > 0, TRUE)
	Then("...and executing it yields SOFTANZA",
		o1.Result(), "SOFTANZA")

	When("natural code uses 'Mirrored' -- recovered from Reverse aka tags")
	o2 = Naturally("Create a string with 'ring' Mirrored it")
	Then("the string is reversed to gnir", o2.Result(), "gnir")
EndScenario()

Scenario("Quoted values are never hijacked (provenance guard)")
	Given("a VALUE spelled exactly like a resolvable action word")
	o3 = Naturally("Create a string with 'capitals' Uppercase it")
	Then("'capitals' stays the literal content", o3.Result(), "CAPITALS")

	o4 = Naturally('Create a string with "change me" Change "me" to "this"')
	Then("quoted param 'this' survives although this is an ignored word",
		o4.Result(), "change this")
EndScenario()

Scenario("Classic dictionary behavior unchanged (regression)")
	o5 = Naturally("Create a string with 'softanza' Uppercase it")
	Then("plain dictionary verb still works", o5.Result(), "SOFTANZA")

	o6 = Naturally("Create a string with 'a.b' Replace '.' with '_'")
	Then("two-param Replace still works", o6.Result(), "a_b")

	o7 = NaturallyIn("hausa", "Yi rubutu dauke 'hello' Maida shi")
	Then("multilingual path (full language name) works", o7.Result(), "HELLO")

	o8 = NaturallyIn("ha", "Yi rubutu dauke 'hello' Maida shi")
	Then("multilingual path (language code) works", o8.Result(), "HELLO")
EndScenario()

Summary()
