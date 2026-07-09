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
	Then("the language roster covers en/ha/fr/ar",
		@@( StzNaturalLanguages() ), @@([ "en", "ha", "fr", "ar" ]))
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

Scenario("Existing languages unaffected (regression)")
	oe = Naturally("Create a list with [ 3, 1, 3 ] and Remove its duplicates")
	Then("English", @@( oe.Result() ), @@([ 3, 1 ]))
	oh = NaturallyIn("hausa", "Yi rubutu dauke 'hello' Maida shi")
	Then("Hausa", oh.Result(), "HELLO")
EndScenario()

Summary()
