# Narrative
# --------
# THE MULTILINGUAL PACK: one semantic core, many linguistic skins -- made
# real over the unified lexicon. A language pack is pure DATA keyed by the
# SAME semantic IDs as English (:semantic_mappings for exact dictionary
# words, :phrases for multi-word naturalness + synonym bags). Registering
# it with StzAddNaturalLanguage() makes the language speakable in
# NaturallyIn() -- including GROWN operations: the French "enleve les
# doublons" and its Arabic equivalent both land on METHOD_REMOVEDUPLICATES,
# a verb no hand ever added to the dictionary.
#
# French and Arabic packs ship in natural/stzNaturalLangData.ring; any
# language can be added the same way at runtime, no code, no loads.
# (Test descriptions stay ASCII; French/Arabic live in the code strings.)

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Language packs register as pure data")
	Then("the French pack is registered", StzHasLanguagePack("fr"), TRUE)
	Then("the Arabic pack is registered", StzHasLanguagePack("ar"), TRUE)
	Then("an unregistered language reports FALSE", StzHasLanguagePack("de"), FALSE)
	Then("the language roster covers en/ha/fr/ar/tr",
		@@( StzNaturalLanguages() ), @@([ "en", "ha", "fr", "ar", "tr" ]))
EndScenario()

Scenario("French natural programs execute -- including grown operations")
	of1 = NaturallyIn("fr", "Crée une liste avec [ 5, 3, 5, 1 ] et enlève les doublons")
	Then("French phrase -> METHOD_REMOVEDUPLICATES (a GROWN verb)",
		@@( of1.Result() ), @@([ 5, 3, 1 ]))

	of2 = NaturallyIn("french", "Crée une chaine avec 'softanza' et mets la en majuscules")
	Then("full language name works, dictionary word resolves",
		of2.Result(), "SOFTANZA")

	of3 = NaturallyIn("fr", "Crée une chaine avec 'a.b' et remplace '.' par '_'")
	Then("two-param replace in French", of3.Result(), "a_b")

	of4 = NaturallyIn("fr", "Crée une chaine avec 'ring' et mets la à l'envers")
	Then("the contraction l'envers survives quote pairing AND resolves",
		of4.Result(), "gnir")
EndScenario()

Scenario("Arabic natural programs execute -- same semantic IDs, RTL script")
	oa1 = NaturallyIn("ar", "أنشئ قائمة مع [ 3, 1, 3, 2 ] أزل التكرارات")
	Then("Arabic phrase -> METHOD_REMOVEDUPLICATES (same grown verb)",
		@@( oa1.Result() ), @@([ 3, 1, 2 ]))

	oa2 = NaturallyIn("ar", "أنشئ قائمة مع [ 1, 2, 3 ] اعكس القائمة")
	Then("Arabic dictionary verb reverses the list",
		@@( oa2.Result() ), @@([ 3, 2, 1 ]))
EndScenario()

Scenario("Arabic is LINGUISTICALLY CORRECT, not transliterated English")
	Given("attached bi- preposition, pronoun suffixes -ha/-hu, verb variants")

	# 'with' is the attached preposition bi-, and 'its duplicates' is ONE
	# inflected word: takraratu-HA (list is feminine in Arabic)
	ol1 = NaturallyIn("ar", "أنشئ قائمة بـ [ 3, 1, 3, 2 ] و أزل تكراراتها")
	Then("bi- preposition + azil takraratu-ha (suffixed noun)",
		@@( ol1.Result() ), @@([ 3, 1, 2 ]))

	# 'containing' (tahtawi 3ala) reads naturally as the value indicator
	ol2 = NaturallyIn("ar", "أنشئ قائمة تحتوي على [ 5, 4, 5 ] ثم احذف التكرارات")
	Then("tahtawi 3ala (containing) + the ihdhif verb variant",
		@@( ol2.Result() ), @@([ 5, 4 ]))

	# a pronoun-suffixed DICTIONARY verb needs no pack phrase at all:
	# i3kis-ha (reverse-it-fem) canonicalizes to the base verb
	ol3 = NaturallyIn("ar", "أنشئ قائمة بـ [ 1, 2, 3 ] ثم اعكسها")
	Then("i3kis-ha: suffixed dictionary verb resolves via canonicalization",
		@@( ol3.Result() ), @@([ 3, 2, 1 ]))

	# hadhf: the third verb variant of removal
	ol4 = NaturallyIn("ar", "أنشئ قائمة مع [ 7, 7, 2 ] حذف المكررات")
	Then("hadhf al-mukarrarat (verb variant + article form)",
		@@( ol4.Result() ), @@([ 7, 2 ]))

	# iqlib is the alternative of i3kis for reversal -- and gender
	# agreement holds: -ha on the feminine list, -hu on the masculine text
	ol5 = NaturallyIn("ar", "أنشئ قائمة بـ [ 1, 2, 3 ] ثم اقلبها")
	Then("iqlib-ha: the reversal verb alternative, feminine suffix",
		@@( ol5.Result() ), @@([ 3, 2, 1 ]))

	ol6 = NaturallyIn("ar", "أنشئ نصا بـ 'ring' ثم اقلبه")
	Then("iqlib-hu: same verb, masculine suffix on the text object",
		ol6.Result(), "gnir")
EndScenario()

Scenario("Vocalized, real-world Arabic writing is accepted")
	Given("tashkeel/tatweel stripped as marks, wa-/fa- stripped as attached conjunctions")

	# the once-crashing sentence: tanween on qa'imatan, stretched bi--,
	# shadda on thumma, and wa- glued to iqlib-ha -- two chained actions
	ov1 = NaturallyIn("ar", "أنشئ قائمةً بــ [ 3, 1, 3, 1, 3, 2 ] ثمّ احذف تكراراتها واقلبها")
	Then("fully vocalized sentence: dedup THEN wa-reverse",
		@@( ov1.Result() ), @@([ 2, 1, 3 ]))

	ov2 = NaturallyIn("ar", "أنشئ قائمةً بـ [ 1, 2 ] اعكسها")
	Then("tanween on the object noun", @@( ov2.Result() ), @@([ 2, 1 ]))

	ov3 = NaturallyIn("ar", "أنشئ قائمة بــــ [ 1, 2 ] اعكسها")
	Then("bi- stretched with many tatweels", @@( ov3.Result() ), @@([ 2, 1 ]))

	ov4 = NaturallyIn("ar", "أنشئ قائمة بـ [ 1, 2, 2 ] ثمّ أزل التكرارات واعكسها")
	Then("shadda on thumma + wa-attached dictionary verb",
		@@( ov4.Result() ), @@([ 2, 1 ]))
EndScenario()

Scenario("Verified affix chains: risky strips allowed when the base is known")
	Given("construct-and-verify stripping over conjunction/preposition/article/suffix")
	Then("the fused wa+bi+al+word canonicalizes to its base",
		StzSemLangCanonToken("ar", "وبالتكرارات"), "تكرارات")

	ov5 = NaturallyIn("ar", "أنشئ قائمة بـ [ 5, 5, 1 ] فاحذف التكرارات")
	Then("fa- attached to the verb executes (fa-ihdhif = so-remove)",
		@@( ov5.Result() ), @@([ 5, 1 ]))
EndScenario()

Scenario("One ranker for all languages: unlisted words carried by rare ones")
	os1 = NaturallyIn("fr", "Crée une liste avec [ 5, 3, 5, 1 ] et vire les doublons")
	Then("'vire' was never listed -- the rare 'doublons' decides via IDF",
		@@( os1.Result() ), @@([ 5, 3, 1 ]))
EndScenario()

Scenario("The system says what it did NOT understand, in any language")
	aL1 = StzNaturalLintIn("fr", "Crée une chaine avec 'x' et majuscul la")
	Then("French lint flags the typo", aL1[:understood], 0)
	Then("...and suggests the nearest known word",
		@@( aL1[:unresolved] ), @@([ [ "majuscul", "majuscule" ] ]))

	of9 = NaturallyIn("fr", "Crée une chaine avec 'softanza' et mets la en majuscules")
	Then("a fully understood program reports UnderstoodAll",
		of9.UnderstoodAll(), TRUE)
EndScenario()

Scenario("French elision generalizes through the same canonicalizer")
	oe1 = NaturallyIn("fr", "Crée une chaine avec 'ring' et mets la à l'envers")
	Then("l'envers (elided article, apostrophe intact)", oe1.Result(), "gnir")
	oe2 = NaturallyIn("fr", "Crée une chaine avec 'ring' et mets la envers")
	Then("bare envers matches the same canonical form", oe2.Result(), "gnir")
EndScenario()

Scenario("The language-aware resolver answers directly")
	Then("fr 'doublons' alone resolves via pack-bag membership",
		StzResolveSemanticInLang("fr", "doublons"), "METHOD_REMOVEDUPLICATES")
	Then("fr 'capitales' resolves",
		StzResolveSemanticInLang("fr", "capitales"), "METHOD_UPPERCASE")
	Then("fr gibberish resolves to nothing",
		StzResolveSemanticInLang("fr", "zzqx"), "")
	Then("en delegation intact: 'capitals'",
		StzResolveSemanticInLang("en", "capitals"), "METHOD_UPPERCASE")
EndScenario()

Scenario("A language can be added at RUNTIME as a data block")
	StzAddNaturalLanguage([
		:code = "sw",
		:name = "swahili",
		:script = "latin",
		:ignored_words = [ "na", "ya", "kwa", "hii" ],
		:semantic_mappings = [
			[:natural = "unda",     :semantic = "CREATE_OBJECT"],
			[:natural = "orodha",   :semantic = "OBJECT_LIST"],
			[:natural = "na",       :semantic = "VALUE_INDICATOR"],
			[:natural = "panga",    :semantic = "METHOD_SORT"]
		],
		:phrases = [
			[:semantic = "METHOD_REMOVEDUPLICATES", :words = "ondoa nakala, futa nakala"]
		]
	])
	Then("the runtime pack registers", StzHasLanguagePack("sw"), TRUE)
	osw = NaturallyIn("sw", "Unda orodha na [ 9, 4, 9 ] ondoa nakala")
	Then("...and its phrases execute grown operations immediately",
		@@( osw.Result() ), @@([ 9, 4 ]))
EndScenario()

Scenario("Role-based grammar: Turkish SOV executes (the word-order unlock)")
	Given(":object_before_create + :params_before_verb declared as pack grammar")

	# verb-final creation: "[ 3, 1, 3 ] with a list CREATE" -- the value
	# and the object word both precede the verb
	ot1 = NaturallyIn("tr", "[ 3, 1, 3 ] ile bir liste oluştur ve tekrarları kaldır")
	Then("verb-final creation + case-suffixed dedup phrase",
		@@( ot1.Result() ), @@([ 3, 1 ]))

	# parameters BEFORE their verb: "'.' instead-of '_' PUT"
	ot2 = NaturallyIn("tr", "'a.b' ile bir metin oluştur '.' yerine '_' koy")
	Then("backward parameter extraction keeps textual order",
		ot2.Result(), "a_b")

	ot3 = NaturallyIn("tr", "[ 1, 2, 3 ] ile bir liste oluştur ve tersine çevir")
	Then("SOV phrase reversal", @@( ot3.Result() ), @@([ 3, 2, 1 ]))
EndScenario()

Scenario("Existing languages unaffected (regression)")
	oe = Naturally("Create a list with [ 3, 1, 3 ] and Remove its duplicates")
	Then("English", @@( oe.Result() ), @@([ 3, 1 ]))
	oh = NaturallyIn("hausa", "Yi rubutu dauke 'hello' Maida shi")
	Then("Hausa", oh.Result(), "HELLO")
EndScenario()

Summary()
