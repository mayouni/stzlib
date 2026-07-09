#---------------------------------------------------------------------------#
#  stzNaturalLangData -- shipped natural-language packs                      #
#                                                                            #
#  One semantic core, many linguistic skins: each pack is pure DATA keyed    #
#  by the SAME semantic IDs as English (including GROWN operations like     #
#  METHOD_REMOVEDUPLICATES). Registering a pack makes the language          #
#  immediately speakable in Naturally()/NaturallyIn():                      #
#                                                                            #
#    NaturallyIn("fr", "Crée une liste avec [ 5, 3, 5 ] et enlève les       #
#                       doublons")                                          #
#    NaturallyIn("ar", "<Arabic: create a list ... remove duplicates>")     #
#                                                                            #
#  :semantic_mappings = exact dictionary words (single tokens)              #
#  :phrases           = multi-word naturalness + synonym bags; each phrase  #
#                       is normalized against the pack's own ignored words  #
#                       and matched EXACTLY (longest join wins), single     #
#                       words fall back to bag membership.                  #
#  Add your own language at runtime with the same call -- no code, no      #
#  loads, just a data block.                                                #
#---------------------------------------------------------------------------#

#-- FRENCH ------------------------------------------------------------------

StzAddNaturalLanguage([
	:code = "fr",
	:name = "french",
	:script = "latin",

	# elided articles attach to the word (l'envers, d'abord) -- stripped
	# to the canonical form on both sides, so "envers" == "l'envers"
	:prefix_articles = [ "l'", "d'" ],

	:ignored_words = [
		"le", "la", "les", "un", "une", "de", "des", "du", "en",
		"et", "dans", "puis", "ensuite", "alors", "ce", "cette",
		"ces", "sa", "ses", "son", "moi", "lui", "elle", "il",
		"y", "a", "au", "aux", "mets", "met", "mettre", "par",
		"pour", "est", "sont", "doit", "merci", "stp", "svp",
		"donne", "donnez", "montre-moi"
	],

	:semantic_mappings = [
		[:natural = "crée",       :semantic = "CREATE_OBJECT"],
		[:natural = "cree",       :semantic = "CREATE_OBJECT"],
		[:natural = "créer",      :semantic = "CREATE_OBJECT"],
		[:natural = "creer",      :semantic = "CREATE_OBJECT"],
		[:natural = "fabrique",   :semantic = "CREATE_OBJECT"],
		[:natural = "construis",  :semantic = "CREATE_OBJECT"],

		[:natural = "chaine",     :semantic = "OBJECT_STRING"],
		[:natural = "chaîne",     :semantic = "OBJECT_STRING"],
		[:natural = "texte",      :semantic = "OBJECT_STRING"],
		[:natural = "liste",      :semantic = "OBJECT_LIST"],
		[:natural = "nombre",     :semantic = "OBJECT_NUMBER"],

		[:natural = "avec",       :semantic = "VALUE_INDICATOR"],

		[:natural = "majuscule",  :semantic = "METHOD_UPPERCASE"],
		[:natural = "majuscules", :semantic = "METHOD_UPPERCASE"],
		[:natural = "minuscule",  :semantic = "METHOD_LOWERCASE"],
		[:natural = "minuscules", :semantic = "METHOD_LOWERCASE"],
		[:natural = "inverse",    :semantic = "METHOD_REVERSE"],
		[:natural = "inverser",   :semantic = "METHOD_REVERSE"],
		[:natural = "retourne",   :semantic = "METHOD_REVERSE"],
		[:natural = "trie",       :semantic = "METHOD_SORT"],
		[:natural = "trier",      :semantic = "METHOD_SORT"],
		[:natural = "remplace",   :semantic = "METHOD_REPLACE"],
		[:natural = "remplacer",  :semantic = "METHOD_REPLACE"],
		[:natural = "substitue",  :semantic = "METHOD_REPLACE"],
		[:natural = "espace",     :semantic = "METHOD_SPACIFY"],
		[:natural = "encadre",    :semantic = "METHOD_BOX"],
		[:natural = "encadrer",   :semantic = "METHOD_BOX"],
		[:natural = "arrondi",    :semantic = "MODIFIER_ROUNDED"],
		[:natural = "arrondie",   :semantic = "MODIFIER_ROUNDED"],

		[:natural = "affiche",    :semantic = "OUTPUT_DISPLAY"],
		[:natural = "afficher",   :semantic = "OUTPUT_DISPLAY"],
		[:natural = "montre",     :semantic = "OUTPUT_DISPLAY"]
	],

	:phrases = [
		# grown operations are addressable exactly like hand-authored ones
		[:semantic = "METHOD_REMOVEDUPLICATES",
		 :words = "enlève les doublons, enleve les doublons, supprime les doublons, retire les doublons, sans doublons"],

		[:semantic = "METHOD_UPPERCASE",
		 :words = "en majuscules, tout en majuscules, en capitales"],

		[:semantic = "METHOD_REVERSE",
		 :words = "à l'envers, a l'envers, dans l'autre sens"],

		[:semantic = "METHOD_ISEMPTY",
		 :words = "est vide, est-elle vide, est-il vide, vide"]
	]
])

#-- ARABIC ------------------------------------------------------------------

StzAddNaturalLanguage([
	:code = "ar",
	:name = "arabic",
	:script = "arabic",

	# MORPHOLOGY: the definite article attaches as a prefix (al-) and the
	# possessive/object pronouns attach as suffixes (-ha feminine, -hu
	# masculine, -hum plural...). Canonicalization strips them on both
	# sides, so the linguistically correct inflected forms just work:
	# "remove its-duplicates(fem)" matches "remove the-duplicates".
	:prefix_articles = [ "ال" ],
	:suffix_pronouns = [ "ها", "هما", "هم", "هن", "ه", "كما", "كم", "ك" ],

	:ignored_words = [
		"و", "ثم", "من", "في", "على", "إلى", "الى", "يا", "هذه",
		"هذا", "لو", "سمحت", "رجاء", "هل", "هي", "هو", "ها",
		"القائمة", "السلسلة", "النص", "العدد"
	],

	:semantic_mappings = [
		[:natural = "أنشئ",    :semantic = "CREATE_OBJECT"],
		[:natural = "انشئ",    :semantic = "CREATE_OBJECT"],
		[:natural = "اصنع",    :semantic = "CREATE_OBJECT"],
		[:natural = "كوّن",    :semantic = "CREATE_OBJECT"],
		[:natural = "كون",     :semantic = "CREATE_OBJECT"],

		[:natural = "سلسلة",   :semantic = "OBJECT_STRING"],
		[:natural = "نص",      :semantic = "OBJECT_STRING"],
		[:natural = "نصا",     :semantic = "OBJECT_STRING"],
		[:natural = "قائمة",   :semantic = "OBJECT_LIST"],
		[:natural = "عدد",     :semantic = "OBJECT_NUMBER"],
		[:natural = "عددا",    :semantic = "OBJECT_NUMBER"],
		[:natural = "رقم",     :semantic = "OBJECT_NUMBER"],

		# the attached preposition "bi-" is the correct "with" here
		# (not "ma3a"); "tahtawi 3ala" (containing) reads naturally too.
		# "ma3a" stays accepted -- permissiveness costs nothing.
		[:natural = "بـ",      :semantic = "VALUE_INDICATOR"],
		[:natural = "ب",       :semantic = "VALUE_INDICATOR"],
		[:natural = "تحتوي",   :semantic = "VALUE_INDICATOR"],
		[:natural = "يحتوي",   :semantic = "VALUE_INDICATOR"],
		[:natural = "مع",      :semantic = "VALUE_INDICATOR"],
		[:natural = "بواسطة",  :semantic = "VALUE_INDICATOR"],

		[:natural = "اعكس",    :semantic = "METHOD_REVERSE"],
		[:natural = "اقلب",    :semantic = "METHOD_REVERSE"],
		[:natural = "رتب",     :semantic = "METHOD_SORT"],
		[:natural = "رتّب",    :semantic = "METHOD_SORT"],
		[:natural = "استبدل",  :semantic = "METHOD_REPLACE"],
		[:natural = "بدّل",    :semantic = "METHOD_REPLACE"],
		[:natural = "بدل",     :semantic = "METHOD_REPLACE"],
		[:natural = "كبّر",    :semantic = "METHOD_UPPERCASE"],
		[:natural = "كبر",     :semantic = "METHOD_UPPERCASE"],
		[:natural = "صغّر",    :semantic = "METHOD_LOWERCASE"],
		[:natural = "صغر",     :semantic = "METHOD_LOWERCASE"],

		[:natural = "أظهر",    :semantic = "OUTPUT_DISPLAY"],
		[:natural = "اظهر",    :semantic = "OUTPUT_DISPLAY"],
		[:natural = "اعرض",    :semantic = "OUTPUT_DISPLAY"],
		[:natural = "اطبع",    :semantic = "OUTPUT_DISPLAY"]
	],

	:phrases = [
		# grown operation, addressed in Arabic. The verb comes in its
		# variants (azil -- imperative of azaala -- ihdhif, hadhf), and
		# canonicalization makes "duplicates" match through the article
		# (al-takrarat) AND the pronoun suffix (takraratu-HA).
		[:semantic = "METHOD_REMOVEDUPLICATES",
		 :words = "أزل التكرارات, ازل التكرارات, احذف التكرارات, حذف التكرارات, أزل المكررات, احذف المكررات, حذف المكررات, بدون تكرار"],

		[:semantic = "METHOD_ISEMPTY",
		 :words = "هل هي فارغة, هل هو فارغ, فارغة, فارغ"]
	]
])
