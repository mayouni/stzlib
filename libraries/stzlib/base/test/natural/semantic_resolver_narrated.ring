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

Scenario("$aSemanticOperations grows from the reflect harvest")
	Given("active-form verbs of stzString/stzList/stzNumber, arity <= 2, construct-and-verified")
	StzGrowSemanticOperations()
	Then("the operation table grew far beyond the ~17 hand-authored entries",
		len($aSemanticOperations) > 1000, TRUE)
	Then("grown verb 'flatten' resolves by exact method name",
		StzResolveSemantic("flatten"), "METHOD_FLATTEN")
	Then("grown verb 'removeduplicates' resolves",
		StzResolveSemantic("removeduplicates"), "METHOD_REMOVEDUPLICATES")
	Then("...while paraphrase quality SURVIVES the grown lexicon: 'capitals'",
		StzResolveSemantic("capitals"), "METHOD_UPPERCASE")
EndScenario()

Scenario("Grown verbs execute through Naturally() on all three classes")
	og1 = Naturally("Create a list with [ 3, 1, 3, 2, 1 ] RemoveDuplicates it")
	Then("stzList: RemoveDuplicates (grown, 0-param)",
		@@( og1.Result() ), @@([ 3, 1, 2 ]))

	og2 = Naturally("Create a string with 'hello world' UppercaseSubString it with 'world'")
	Then("stzString: UppercaseSubString (grown, 1-param)",
		og2.Result(), "hello WORLD")

	og3 = Naturally("Create a number with 5 Add it with 3")
	Then("stzNumber: Add (grown, 1-param)", og3.Result(), "8")
EndScenario()

Scenario("Truly natural phrasing via multi-word phrase resolution")
	Given("longest exact method-name joins over content words, fillers skipped")
	on1 = Naturally("Create a list with [ 3, 1, 3, 2, 1 ] and Remove its duplicates")
	Then("'Remove its duplicates' -> RemoveDuplicates()",
		@@( on1.Result() ), @@([ 3, 1, 2 ]))

	on2 = Naturally("Create a string with 'hello world' and Uppercase the substring 'world'")
	Then("'Uppercase the substring' outmatches plain Uppercase (longest wins)",
		on2.Result(), "hello WORLD")

	on3 = Naturally("Create a number with 5 and Add 3 to it")
	Then("'Add 3 to it' reads naturally", on3.Result(), "8")

	on4 = Naturally("Create a list with [ 1, 2, 2 ] and Remove it's duplicates please")
	Then("a contraction apostrophe never breaks quote pairing",
		@@( on4.Result() ), @@([ 1, 2 ]))
EndScenario()

Scenario("Query forms: passives and predicates RETURN a value")
	Given("the function-forms grammar mapped to kinds: active=action, passive/predicate=query")
	oq1 = Naturally("Create a string with 'softanza' Is it empty ?")
	Then("'Is it empty ?' answers the question instead of mutating",
		oq1.Result(), 0)

	oq2 = Naturally("Create a string with 'ring' Give me it Reversed")
	Then("'it Reversed' yields the reversed COPY as the result",
		oq2.Result(), "gnir")
EndScenario()

Scenario("Growth safety: wrong-class verbs and missing params degrade to no-ops")
	og4 = Naturally("Create a string with 'ring' Prepend it with 'x-'")
	Then("a stzList-only verb on a string is skipped, never an R14",
		og4.Result(), "ring")

	og5 = Naturally("Create a string with 'ring' Update it")
	Then("a param-hungry verb without its argument emits nothing",
		og5.Result(), "ring")
EndScenario()

Scenario("Understandability: unknown words are reported with suggestions")
	ou1 = Naturally("Create a string with 'softanza' Uppercse it")
	Then("the typo degrades permissively (no crash, no wrong action)",
		ou1.Result(), "softanza")
	Then("...and Unresolved() names it, with the nearest known word",
		@@( ou1.Unresolved() ), @@([ [ "Uppercse", "uppercase" ] ]))

	aLint = StzNaturalLint("Create a string with 'x' Fooify it and Uppercse it")
	Then("lint flags a not-understood narration without running it",
		aLint[:understood], 0)
	Then("...listing every unknown word with its suggestion",
		len(aLint[:unresolved]), 2)

	ou2 = Naturally("Create a list with [ 3, 1, 3 ] and Remove its duplicates")
	Then("a fully understood program reports UnderstoodAll",
		ou2.UnderstoodAll(), TRUE)
EndScenario()

Scenario("Form slots: one verb's whole linguistic family, queryable")
	aFam = StzFormFamily("stzString", "uppercase")
	Then("the family has at least active + passive + fluent + predicate forms",
		len(aFam) >= 4, TRUE)
	acForms = []
	nFam = len(aFam)
	for nIdx = 1 to nFam
		aSlot = aFam[nIdx]
		cForm = aSlot[1]
		if ring_find(acForms, cForm) = 0
			acForms + cForm
		ok
	next
	Then("the active form is slotted", ring_find(acForms, "active") > 0, TRUE)
	Then("the passive form is slotted", ring_find(acForms, "passive") > 0, TRUE)
	Then("the predicate form is slotted", ring_find(acForms, "predicate") > 0, TRUE)
EndScenario()

Scenario("Intents become executable natural plans")
	oP1 = new stzString("hello world")
	cPlan = oP1.PlanForIntent("uppercase it then reverse it")
	Then("the plan opens with the Create line over the live content",
		StzFindFirst(cPlan, "Create a string with 'hello world'") > 0, TRUE)
	Then("...and executing the intent chains both steps",
		oP1.DoIntent("uppercase it then reverse it"), "DLROW OLLEH")

	oP2 = new stzList([ 3, 1, 3 ])
	Then("list intents work, including grown verbs",
		@@( oP2.DoIntent("remove its duplicates then reverse it") ), @@([ 1, 3 ]))

	oP3 = new stzNumber(5)
	Then("number intents work", oP3.DoIntent("add 3 to it"), "8")

	bRaised = FALSE
	try
		oP1.DoIntent("fooify it")
	catch
		bRaised = ( StzFindFirst(cCatchError, "did you mean") > 0 )
	done
	Then("a not-understood intent raises WITH a suggestion (plans are strict)",
		bRaised, TRUE)
EndScenario()

Scenario("Form-slotted aka: predicate words ask, imperative words act")
	Given("aka folded into each record's OWN form slot; ties broken by the imperative default")
	Then("'shouting' (predicate-specific aka) -> the QUERY op",
		StzResolveSemantic("shouting"), "METHOD_ISUPPERCASE")
	Then("'capitals' (voice-neutral, shared) -> the ACTION op wins the tie",
		StzResolveSemantic("capitals"), "METHOD_UPPERCASE")

	ofs1 = Naturally("Create a string with 'SOFTANZA' Is it shouting ?")
	Then("'Is it shouting ?' ANSWERS on uppercase content", ofs1.Result(), 1)
	ofs2 = Naturally("Create a string with 'softanza' Is it shouting ?")
	Then("...and on lowercase content", ofs2.Result(), 0)
EndScenario()

Scenario("Multiple live objects: name them, switch between them")
	om1 = Naturally("Create a string with 'ring' called first Create a string with 'zig' called second Use first Uppercase it")
	Then("two objects coexist; 'Use first' switches back before acting",
		om1.Result(), "RING")

	om2 = Naturally("Create a string with 'ring' called first Create a string with 'zig' called second Use second Reverse it")
	Then("...and 'Use second' addresses the other one", om2.Result(), "giz")

	om3 = Naturally("Create a list with [ 1, 2, 2 ] called basket Create a string with 'hi' called tag Use basket Remove its duplicates")
	Then("mixed types by name, grown verbs included",
		@@( om3.Result() ), @@([ 1, 2 ]))

	om4 = Naturally("Create a string with 'x' called box Use box Uppercase it")
	Then("a dictionary word used as a NAME stays a name (guards)",
		om4.Result(), "X")

	om5 = NaturallyIn("ar", "أنشئ قائمة بـ [ 1, 2, 3 ] سمها سلتي أنشئ قائمة بـ [ 9 ] استخدم سلتي اعكسها")
	Then("Arabic naming works (registry keeps the script; the var is generated)",
		@@( om5.Result() ), @@([ 3, 2, 1 ]))
EndScenario()

Scenario("Variable binding: keep a value, recall it where values go")
	Given("KEEP_INDICATOR binds the current result; bound names recall as variables")

	ovb1 = Naturally("Create a string with '.' Keep it as sep Create a string with 'a.b' Replace sep with '_'")
	Then("a kept CONTENT recalls as a method parameter",
		ovb1.Result(), "a_b")
	Then("...the generated code passes the VARIABLE, not a string",
		StzFindFirst(ovb1.Code(), "Replace(v_sep,") > 0, TRUE)

	ovb2 = Naturally("Create a string with 'ring' Give me it Reversed and keep it as rev Create a string with rev")
	Then("a kept QUERY result recalls as a creation value",
		ovb2.Result(), "gnir")

	ovb3 = Naturally("Create a string with '.' Keep it as sep Create a string with 'a.sep.b' Replace 'sep' with 'Z'")
	Then("a QUOTED name is data, never a reference (provenance guard)",
		ovb3.Result(), "a.Z.b")

	ovb4 = Naturally("Create a string with '-' called dash Keep it as d Create a list with [ 1, 2 ] called basket Use basket Reverse it")
	Then("object names and value names coexist",
		@@( ovb4.Result() ), @@([ 2, 1 ]))
EndScenario()

Scenario("Semantic probing: getters answer instead of silently no-oping")
	Given("growth probes 0-arity noun-headed actives on a live sample: no mutation + a returned value = query")
	op1 = Naturally("Create a string with 'hello' NumberOfChars ?")
	Then("NumberOfChars ANSWERS as a query", op1.Result(), 5)
EndScenario()

Scenario("Strict mode and operation allow-lists (the agent posture)")
	bR1 = FALSE
	try
		NaturallyStrict("Create a string with 'x' Fooify it")
	catch
		bR1 = ( StzFindFirst(cCatchError, "did you mean") > 0 )
	done
	Then("strict mode raises on any not-understood word, with suggestions", bR1, TRUE)

	oal = NaturallyStrictIn("en", "Create a list with [ 3, 1, 3 ] Remove its duplicates", [ "METHOD_REMOVEDUPLICATES" ])
	Then("an allow-listed operation runs", @@( oal.Result() ), @@([ 3, 1 ]))

	bR2 = FALSE
	try
		NaturallyStrictIn("en", "Create a list with [ 3, 1 ] Reverse it", [ "METHOD_REMOVEDUPLICATES" ])
	catch
		bR2 = ( StzFindFirst(cCatchError, "not permitted") > 0 )
	done
	Then("...and everything off the list is grammatically impossible", bR2, TRUE)
EndScenario()

Scenario("Understood(): the engine paraphrases its interpretation back")
	oun = Naturally("Create a list with [ 3, 1, 3 ] called basket Remove its duplicates and keep it as clean")
	Then("the canonical reading is echoed in plain words",
		oun.Understood(),
		"create a list with [ 3, 1, 3 ] -> call it basket -> remove duplicates -> keep it as clean")
EndScenario()

Scenario("Runtime teaching: new words join the live lexicon")
	cTid = StzTeachSynonym("en", "purge", "remove duplicates")
	Then("the meaning resolves through the existing machinery",
		cTid, "METHOD_REMOVEDUPLICATES")
	otc = Naturally("Create a list with [ 5, 5, 2 ] Purge it")
	Then("...and the taught word executes immediately",
		@@( otc.Result() ), @@([ 5, 2 ]))
EndScenario()

Scenario("Predictive suggestions: the engine says what can come NEXT")
	Given("the same token-state machine that executes, run as a guide")
	Then("an empty narration starts with a creation verb",
		ring_find(StzNaturalSuggest(""), "create") > 0, TRUE)
	Then("after 'Create a' come the object types",
		ring_find(StzNaturalSuggest("Create a "), "list") > 0, TRUE)
	Then("after the object comes the value indicator + value shapes",
		ring_find(StzNaturalSuggest("Create a list "), "with") > 0, TRUE)
	Then("after a value come the dictionary action verbs",
		ring_find(StzNaturalSuggest("Create a list with [ 1, 2 ] "), "reverse") > 0, TRUE)
	Then("a mid-word prefix completes over the GROWN vocabulary",
		ring_find(StzNaturalSuggest("Create a list with [ 1, 2 ] rev"), "reverse") > 0, TRUE)
	Then("...and a two-word phrase prefix completes across words",
		ring_find(StzNaturalSuggest("Create a list with [ 1, 2 ] remove d"), "remove duplicates") > 0, TRUE)
	Then("after 'Use' come the objects NAMED in this narration",
		@@( StzNaturalSuggest("Create a list with [ 1 ] called basket Use ") ), @@([ "basket" ]))
	Then("packs suggest in their own language",
		ring_find(StzNaturalSuggestIn("fr", "Crée une liste avec [ 1, 2 ] "), "inverse") > 0, TRUE)
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
