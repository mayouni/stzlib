# Narrative
# --------
# NNL 2.0 -- the renovated Near-Natural Language device layer (see
# doc/design/NNL_REVIEW.md). This suite is the EXECUTABLE SPECIFICATION the
# review demanded: the paradigm decayed invisibly for years because no test
# ever locked its surface. Covers: the repaired descriptor dispatch, the
# flagship sentence, the regenerated noun surface (from the semantic
# lexicon), the expectation register with the NEW comparative determiners,
# the accountability surface (WhyCheckFailed/WhyStopped on the chain,
# detached Why() for the console), the NEW conditional mood, the NEW
# ordinal reference, and the accountable refusal that replaced silent
# absorb-anything typo tolerance.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("The descriptor dispatch answers truthfully again")
	Given("@isLowercase was a char-only predicate: any WORD answered 0, poisoning every :Lowercase chain")
	Then("'ring' IS lowercase", @isLowercase("ring"), TRUE)
	Then("'RING' is not", @isLowercase("RING"), FALSE)
	Then("the article's opening example finally answers as printed",
		Q("ring").IsAXT([ :Lowercase, :Latin, :String ]), TRUE)
EndScenario()

Scenario("The flagship sentence runs")
	Given("'The word ring is a lowercase Latin word with a length of 4 letters and only 1 vowel'")
	# MARKERLESS (the author's ruling): no M anywhere, exactly like the
	# English -- the subject is the topic by being the subject; "only 1
	# vowel" attaches to the word by selectional restriction (lengths
	# have no vowels). UnitQ replaces the article's .Q(:Letters): a Q()
	# method would shadow the global Q() (the len() trap).
	bFlag = TheWordQ("ring").IsAQ([ :Lowercase, :Latin, :Word ]).WithQ().
		ALengthQ().OfQ(4).UnitQ(:Letters).AndQ().OnlyQ(1).VowelNB()
	Then("definite reference, articles, ellipsis, agreement -- one chain, TRUE",
		bFlag, TRUE)
EndScenario()

Scenario("The regenerated noun surface (from the semantic lexicon)")
	Given("41 countable nouns x N/NQ/NB/NBQ (+B/BQ) devices, generated not hand-typed")
	Then("a string counts its words", Q("hello brave world").WordN(), 3)
	Then("a list counts its items", Q([ 1, 2, 3 ]).ItemN(), 3)
	Then("ellipsis: '...and only 3 items'", Q([ 1, 2, 3 ]).Only(3).ItemNB(), TRUE)
	SetLastValue([ "A", "I", "E" ])
	Then("value agreement: the vowels ARE the remembered ones",
		Q("AnnIE").VowelsB(), TRUE)
EndScenario()

Scenario("Comparative determiners -- degree words for the expectation (NEW)")
	Then("'at least 2 vowels'", Q("AnnIE").AtLeast(2).VowelNB(), TRUE)
	Then("'at most 2 vowels' refuses on 3", Q("AnnIE").AtMost(2).VowelNB(), FALSE)
	Then("...and explains itself", Why(), "no: expected atmost 2, found 3")

	# the explanation lives ON the chain (the WhyChainStopped precedent):
	# two interleaved chains never lie to each other
	oc1 = Q("AnnIE")
	oc2 = Q("hello world")
	oc1.AtMost(2).VowelNB()
	oc2.AtLeast(5).WordNB()
	Then("each chain keeps ITS OWN reason",
		oc1.WhyCheckFailed(), "no: expected atmost 2, found 3")
	Then("even after another chain checked",
		oc2.WhyCheckFailed(), "no: expected atleast 5, found 2")
	Then("a fresh object answers honestly",
		Q("x").WhyCheckFailed(), "no check has been made on this object yet")
	oc3 = Q("AnnIE")
	oc3.AtLeast(2).VowelNB()
	Then("a PASSED check is not explained (the archive never did)",
		oc3.WhyCheckFailed(), "the last check did not fail")
	Then("a LIVE object is polite about WhyStopped (the archive's way)",
		oc1.WhyStopped(), "the chain is not stopped")
	Then("a FALSE premise records why the chain stopped",
		Q("AnnIE").AtMost(2).VowelNBQ().WhyStopped(),
		"no: expected atmost 2, found 3")
	Then("'more than 2 words'",
		Q("hello brave new world").MoreThan(2).WordNB(), TRUE)
	Then("'about 10 items' tolerates 9 (vagueness, +/-10%)",
		Q([ 1,2,3,4,5,6,7,8,9 ]).About(10).ItemNB(), TRUE)
	Then("'between 2 and 4 words'",
		Q("hello brave world").BetweenN(2, 4).WordNB(), TRUE)
EndScenario()

Scenario("Conditional mood -- the chain branches on its own truth (NEW)")
	# the two branches carry DIFFERENT actions -- only one ever runs
	Then("a TRUE premise runs IfSo (uppercase), skips Otherwise (reverse)",
		Q("ring").IsAQ(:String).IfSo(:Uppercase).Otherwise(:Reverse).Content(),
		"RING")
	Then("a FALSE premise carries its origin...",
		classname( Q("hello").IsAQ(:Number) ), "stzfalseobject")
	Then("...skips IfSo (reverse), and Otherwise (uppercase) runs on it",
		Q("hello").IsAQ(:Number).IfSo(:Reverse).Otherwise(:Uppercase).Content(),
		"HELLO")
EndScenario()

Scenario("Ordinal reference -- 'the second word' (NEW, stzOrdinal wired)")
	Then("the 2nd word", Q("hello brave world").TheNth(2, :Words), "brave")
	Then("the first vowel", Q("softanza").TheFirst(:Vowels), "o")
	Then("the last vowel", Q("softanza").TheLast(:Vowels), "a")
EndScenario()

Scenario("Accountability replaced silent typo tolerance")
	Given("the archive handled typos by hand-written @Misspelled aliases that absorbed anything")
	bRefused = FALSE
	try
		Q(5).VowelNB()
	catch
		bRefused = TRUE
	done
	Then("a number cannot count vowels -- REFUSED, not absorbed", bRefused, TRUE)

	bRefused2 = FALSE
	try
		Q("ring")._NNLCall("upercase", [])   # typo -> suggestion, not silence
	catch
		bRefused2 = TRUE
	done
	Then("an unknown stem refuses with a did-you-mean", bRefused2, TRUE)
EndScenario()

Scenario("The grammaticality doctrine -- the chain IS the sentence")
	Given("a relative pronoun needs a VERB: which HAS a length -- a chain that runs but does not parse as English is a bug in NNL terms; and reference is MARKERLESS: the subject is the topic, comebacks resolve by selectional attachment, pronouns (ItQ/ItsQ/TheirQ) serve true ambiguity")

	# the corrected canonical statement, exactly as the author wrote it:
	# 'The word ring is a word which has a length of 4.' No later clause
	# refers back to the word, so NO M.
	Then("TheWordQ (no M) ... WhichQ().HasQ().ALengthQ().Of(4)",
		TheWordQ("ring").IsAQ(:Word).WhichQ().HasQ().ALengthQ().Of(4), TRUE)

	# the single-symbol descriptor continues the chain now (it used to
	# fall through IsAQ's core-type switch and return nothing)
	Then("IsAQ(:Word) continues on the typed object",
		classname( TheWordQ("ring").IsAQ(:Word) ), "stzstring")
EndScenario()

Scenario("P2: the context lives ON the chain -- agent safety")
	Given("determiners set the expectation on the object they return; devices that build new objects carry it; *QM recalls read the chain-local main first")

	# two DISCOURSES built side by side, each a GRAMMATICAL sentence and
	# MARKERLESS: the subject travels as chain-local context; the
	# '...and only N vowels' clause attaches back by selectional
	# restriction -- no memorize marker, no recall marker
	od1 = TheWordQ("ring").IsAQ(:Word).WhichQ().HasQ().ALengthQ().OfQ(4)
	od2 = TheWordQ("softanza").IsAQ(:Word).WhichQ().HasQ().ALengthQ().OfQ(8)
	Then("the FIRST discourse still holds ITS subject",
		od1.NNLMainRaw().Content(), "ring")
	Then("the second holds its own", od2.NNLMainRaw().Content(), "softanza")
	Then("'...and only 1 vowel' attaches to RING",
		od1.AndQ().OnlyQ(1).VowelNB(), TRUE)
	Then("'...and only 3 vowels' attaches to SOFTANZA",
		od2.AndQ().OnlyQ(3).VowelNB(), TRUE)
	Then("the explicit pronoun recalls the subject too",
		od1.ItsQ().Content(), "ring")

	# two expectations built side by side: neither clobbers the other
	oe1 = Q("AnnIE").AtMost(2)
	oe2 = Q("hello world").AtLeast(5)
	Then("the first chain keeps ITS atmost-2", oe1.VowelNB(), FALSE)
	Then("...for its own reason",
		oe1.WhyCheckFailed(), "no: expected atmost 2, found 3")
	Then("the second keeps ITS atleast-5 (2 words -> no)",
		oe2.WordNB(), FALSE)
EndScenario()

Scenario("Q3: truth-functional coordination -- the author's formulations")
	Given("'It is either a number or a string' -- the fused copula IsEitherQ coordinates TYPE NOUNS (ANumberQ/AStringQ...); the first disjunct may fail without falsifying; a satisfied disjunction skips the rest. No NotQ anywhere: negation lives in negative forms, antonyms, and the OrNot tag")

	Then("'Ring is either a number or a string' -- second disjunct decides",
		classname( Q("Ring").IsEitherQ().ANumberQ().OrQ().AStringQ() ),
		"stzstring")
	Then("'123 is either a string or a list' -- both fail, false",
		classname( Q(123).IsEitherQ().AStringQ().OrQ().AListQ() ),
		"stzfalseobject")
	Then("first disjunct holds: the rest is SKIPPED, the number untouched",
		classname( Q(123).IsEitherQ().ANumberQ().OrQ().AStringQ() ),
		"stznumber")

	Then("'Ring is neither a number nor a list'",
		classname( Q("Ring").IsNeitherQ().ANumberQ().NorQ().AListQ() ),
		"stzstring")
	Then("the author's variant: '...nor is IT a list' (pronoun carries the figure)",
		classname( Q("Ring").NeitherQ().IsAQ(:Number).NorQ().ItQ().IsAQ(:List) ),
		"stzstring")
	Then("neither fails when one predicate holds",
		classname( Q("Ring").IsNeitherQ().AStringQ().NorQ().AListQ() ),
		"stzfalseobject")

	# the number-typing fix that Q3 exposed, locked forever
	Then("a number is NOT a string (descriptors test the TYPED value)",
		classname( Q(123).IsAQ(:String) ), "stzfalseobject")
	Then("and IS a number", classname( Q(123).IsAQ(:Number) ), "stznumber")
EndScenario()

Scenario("Q3b: distributive quantifiers -- each / any / none")
	Given("the quantifier opens a figure; the NEXT predicate distributes over the items and the fold explains itself per item; singular agreement by design (each IS, none IS) -- the collective plural lives in AreQ")

	Then("'each is a number'",
		classname( Q([ 1, 2, 3 ]).EachQ().IsAQ(:Number) ), "stzlist")
	oQf = Q([ 1, "x", 3 ]).EachQ().IsAQ(:Number)
	Then("...and the failing ITEM is named",
		oQf.WhyStopped(), 'no: item 2 ("x") does not hold, and each must')
	Then("'any of them is a number'",
		classname( Q([ "a", 5, "b" ]).AnyQ().IsAQ(:Number) ), "stzlist")
	Then("'none is a number'",
		classname( Q([ "a", "b" ]).NoneQ().IsAQ(:Number) ), "stzlist")
	Then("...and a holding item breaks none",
		Q([ "a", 7 ]).NoneQ().IsAQ(:Number).WhyStopped(),
		"no: item 2 (7) holds, and none may")

	Then("'each has at least 2 vowels' (the ellipsis device distributes)",
		Q([ "AnnIE", "aeiou" ]).EachQ().AtLeast(2).VowelNB(), TRUE)
	Then("...failure names the item AND the expectation",
		Q([ "AnnIE", "sky" ]).EachQ().AtLeast(2).VowelNB(), FALSE)
	Then("...", Why(),
		'no: item 2 ("sky") fails -- no: expected atleast 2, found 0')
	Then("'any has at least 3 vowels'",
		Q([ "sky", "AnnIE" ]).AnyQ().AtLeast(3).VowelNB(), TRUE)

	Then("a string is a plural of its chars: 'each is a vowel'",
		classname( Q("aeiou").EachQ().IsAQ([ :Vowel ]) ), "stzstring")

	# the author's formulations, verbatim: the InQ topic opener and the
	# quantifier-NOUN units; ALL takes the collective road (AreQ) and
	# answers with the TYPED list
	Then("'In [1, x, 3], each item is a number' -- refused at item 2",
		classname( InQ([ 1, "x", 3 ]).EachItemQ().IsAQ(:Number) ),
		"stzfalseobject")
	Then("'In [1, 2, 3], all items are numbers' -- the TYPED answer",
		classname( InQ([ 1, 2, 3 ]).AllItemsQ().AreQ(:Numbers) ),
		"stzlistofnumbers")
	Then("...and the mixed list is refused (the Are stub answered TRUE
		for ANY non-empty list; repaired)",
		classname( InQ([ 1, "x", 3 ]).AllItemsQ().AreQ(:Numbers) ),
		"stzfalseobject")
	Then("'no item is a number'",
		classname( InQ([ "a", "b" ]).NoItemQ().IsAQ(:Number) ), "stzlist")
EndScenario()

Scenario("The aliasing doctrine and QC() -- chain on a clone")
	Given("never alias stz objects with = (copies share the engine handle); QC completes the Q/QC/QH trio: chain on a clone, the original untouched")
	oQc = new stzString("ring")
	Then("QC(obj) chains on a CLONE", QC(oQc).UppercaseQ().Content(), "RING")
	Then("...and the original is untouched", oQc.Content(), "ring")
	aQc = [ 1, 2, 2 ]
	Then("QC(list) protects the caller's list",
		@@( QC(aQc).RemoveDuplicatesQ().Content() ), "[ 1, 2 ]")
	Then("...which still holds its duplicates", @@( aQc ), "[ 1, 2, 2 ]")

	# lazy subject stamping: no birth snapshot to dangle
	oLz = Q("ring")
	oLz.Uppercase()
	Then("mutate THEN interrupt: attachment sees the LIVE subject",
		oLz.ALengthQ().OnlyQ(1).VowelNB(), TRUE)
EndScenario()

Scenario("The monad keeps its discourse role")
	Given("a false premise absorbs what follows and stays explainable")
	Then("counting through a false premise answers 0",
		Q("hello").IsAQ(:Number).VowelNB(), FALSE)
	Then("and says why", Why(), "no: the premise before was already false")
EndScenario()

Summary()
