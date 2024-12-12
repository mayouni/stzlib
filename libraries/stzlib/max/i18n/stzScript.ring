
_aLocaleScriptsXT = [
	/*
	The unicode abreviations are documented here:
	https://unicode.org/iso15924/iso15924-codes.html

	NOTE: we include here only the languages included in Qt Unicode
	--> that we can use to define a locale

	TODO: It seems there is a duplication of data about scripts in two files:
		- here in stzScript.ring, and
		- in stzCharData

		By consequence, two sets of functions exist:
		- LocaleScripts() in this files (stzScript.ring), and
		- UnicodeScripts() in stzCharData.ring

		==> Unify this, and use only the data and function in this file!

	NOTE: Read this resource about number of letters per alphabets
	https://wordfinderx.com/blog/languages-ranked-by-letters-in-alphabet/

	*/
	#     1		    2				3		      4
	#  QtNumber 	ScriptName 		ScriptAbbreviation 	DefaultLanguage

	[ "0" ,		:Common,		"Zyyy",			:undefined			],	
	[ "1" , 	:Arabic, 		"Arab", 		:arabic 			],
	[ "2" , 	:Cyrillic, 		"Cyrl", 		:russian 			],
	[ "3" , 	:Deseret, 		"Dsrt", 		:english 			],
	[ "4" , 	:Gurmukhi, 		"Guru", 		:punjabi 			],
	[ "5" , 	:Simplified_Han, 	"Hans", 		:mandarin 			], # called also :Simplified_Chinese
	[ "6" , 	:Traditional_Han, 	"Hant", 		:mandarin 			], # called also :Traditional_Chinese
	[ "7" , 	:Latin, 		"Latn", 		:english 			],
	[ "8" , 	:Mongolian, 		"Mong", 		:mongolian 			],
	[ "9" , 	:Tifinagh, 		"Tfng", 		:standard_morocco_tamazight 	], # called also :Berber
	[ "10" , 	:Armenian, 		"Armn", 		:armenian 			],
	[ "11" , 	:Bengali, 		"Beng", 		:bengali 			],
	[ "12" , 	:Cherokee, 		"Cher", 		:cherokee 			],
	[ "13" , 	:Devanagari, 		"Deva", 		:bhojpuri 			], # or :bodo or :hindi or :fijian or :konkani and many others
	[ "14" , 	:Ethiopic, 		"Ethi", 		:oromo 				], # or :amharic or :blin or :geez or :tigre or :tigrinya
	[ "15" , 	:Georgian, 		"Geor", 		:georgian 			],
	[ "16" , 	:Greek, 		"Grek", 		:ancient_greek 			],
	[ "17" , 	:Gujarati, 		"Gujr", 		:gujarati 			],
	[ "18" , 	:Hebrew, 		"Hebr", 		:hebrew 			],
	[ "19" , 	:Japanese, 		"Jpan", 		:japanese 			],
	[ "20" , 	:Khmer, 		"Khmr", 		:khmer 				],
	[ "21" , 	:Kannada, 		"Knda", 		:kannada 			],
	[ "22" , 	:Korean, 		"Kore", 		:korean 			],
	[ "23" , 	:Lao, 			"Laoo", 		:lao 				],
	[ "24" , 	:Malayalam, 		"Mlym", 		:malayalam 			],
	[ "25" , 	:Myanmar, 		"Mymr", 		:burmese 			],
	[ "26" , 	:Oriya, 		"Orya", 		:oriya 				],
	[ "27" , 	:Tamil, 		"Taml", 		:tamil 				],
	[ "28" , 	:Telugu, 		"Telu", 		:telugu 			],
	[ "29" , 	:Thaana, 		"Thaa", 		:divehi 			],
	[ "30" , 	:Thai, 			"Thai", 		:thai 				],
	[ "31" , 	:Tibetan, 		"Tibt", 		:tibetan 			],
	[ "32" , 	:Sinhala, 		"Sinhala", 		:sinhala 			],
	[ "33" , 	:Syriac, 		"Syrc", 		:syriac 			],
	[ "34" ,	:Yi, 			"Yiii", 		:sichuan_yi 			],
	[ "35" , 	:Vai, 			"Vaii", 		:vai 				],
	[ "36" , 	:Avestan, 		"Avst", 		:avestan 			],
	[ "37" , 	:Balinese, 		"Bali", 		:balinese 			],
	[ "38" , 	:Bamum, 		"Bamu", 		:bamun 				],
	[ "39" , 	:Batak, 		"Batk", 		:batak_toba 			],
	[ "40" , 	:Bopomofo, 		"Bopo", 		:literary_chinese 		], # or maybe :mandarin_chinese ?
	[ "41" , 	:Brahmi, 		"Brah", 		:sanskrit 			],
	[ "42" , 	:Buginese, 		"Bugi", 		:buginese 			],
	[ "43" , 	:Buhid , 		"Buhd", 		_NULL_ 				], # ! note that the default language here is :buhid
					 							  	   # but we didn't include it because Qt unicode
					  							  	   # don't support it
	[ "44" , 	:Canadian_Aboriginal, 	"Cans", 		:cree 				], # or :inuktitut or :cree or :ojibwa
	[ "45" , 	:Carian, 		"Cari", 		:undefined 				],
	[ "46" , 	:Chakma, 		"Cakm", 		:chakma 			],
	[ "47" , 	:Cham, 			"Cham", 		:undefined			],
	[ "48" , 	:Coptic, 		"Copt", 		:coptic 			],
	[ "49" , 	:Cypriot, 		"Cprt", 		:undefined 				],
	[ "50" , 	:Egyptian_Hieroglyphs, 	"Egyp", 		:ancient_egyptian 		], # There is also :Egyptian_Demotic (egyd)
						                     				   	   # and :Egyptian_Hieratic (egyh)
	[ "51" , 	:Fraser, 		"Lisu", 		:undefined			], # Called also :Lisu
	[ "52" , 	:Glagolitic, 		"Glag", 		:undefined			],
	[ "53" , 	:Gothic, 		"Goth", 		:gothic 			],
	[ "54" , 	:Han, 			"Hant", 		:undefined			],
	[ "55" , 	:Hangul, 		"Hang", 		:undefined			],
	[ "56" , 	:Hanunoo, 		"Hano", 		:undefined			],
	[ "57" , 	:Imperial_Aramaic, 	"Armi", 		:undefined			],
	[ "58" , 	:Inscriptional_Pahlavi, "Phli", 		:undefined			],
	[ "59" , 	:Inscriptional_Parthian,"Prti", 		:undefined			],
	[ "60" , 	:Javanese, 		"Java", 		:javanese 			],
	[ "61" , 	:Kaithi, 		"Kthi", 		:undefined			],
	[ "62" , 	:Katakana, 		"Kana", 		:undefined			],
	[ "63" , 	:Kayah_Li, 		"Kali", 		:undefined			],
	[ "64" , 	:Kharoshthi, 		"Khar", 		:undefined			],
	[ "65" , 	:Lanna, 		"Lana", 		:undefined			], # Called also :Tai_Tham
	[ "66" , 	:Lepcha, 		"Lepc", 		:undefined			], # Called also :Róng. Note that the default language is
					  							           # called :lepcha but we don't include it because Qt Unicode
					  							           # does not recognize it!
	[ "67" , 	:Limbu, 		"Limb", 		:undefined			], # The default language is called :limbu but we don't include it
	[ "68" , 	:Linear_B, 		"Linb", 		:ancient_greek 			],
	[ "69" , 	:Lycian, 		"Lyci", 		:undefined			], # The default language is called :lycian but we don't include it
	[ "70" , 	:Lydian, 		"Lydi", 		:undefined			], # The default language is called :lydian but we don't include it
	[ "71" , 	:Mandaean, 		"Mand", 		:undefined			], # Called also :Mandaic. Note that the default language is calle :Classical_Mandaic
					    							           # but we don't inlcude it because Qt Uniocde does not recognise it
	[ "72" , 	:Meitei_Mayek, 		"Mtei", 		:manipuri 			], # Called also :Meithei and :Meetei
	[ "73" , 	:Meroitic_Hieroglyphs, 	"Mero", 		:undefined			],
	[ "74" , 	:Meroitic_Cursive, 	"Merc", 		:undefined			], # The default language is called :Meroitic_Cursive but
						    						           # we don't include it beceause Qt Unicode does not know it
	[ "75" , 	:Nko, 			"Nkoo", 		:nko 				], # Spelled N’Ko
	[ "76" , 	:New_Tai_Lue, 		"Talu", 		:undefined			], # The default language for this script is Lü, but
					      							           # we don't include it beceause Qt Unicode does not know it
	[ "77" , 	:Ogham, 		"Ogam", 		:old_irish 			],
	[ "78" , 	:Ol_Chiki, 		"Olck", 		:santali 			],
	[ "79" , 	:Old_Italic, 		"Ital", 		:undefined			], # This script is used in these languages: Umbrian, Oscan and Etruscan
					      							           # we don't include them beceause Qt Unicode does not know them
	[ "80" , 	:Old_Persian, 		"Xpeo", 		:old_persian 			],
	[ "81" , 	:Old_South_Arabian, 	"Sarb", 		:undefined			], # This script is used for language Sabaean, but
						     						           # we don't include it beceause Qt Unicode does not know it
	[ "82" , 	:Orkhon, 		"Orkh", 		:undefined			], # Called also :Old_Turkic and :Orkhon_Runic
												           #NOTE that the language corresponding to this script
												           # is :Old_Turkish, but we don't include it because Qt Unicode										   # does not knowt it
	[ "83" , 	:Osmanya, 		"Osma", 		:somali 			],
	[ "84" , 	:Phags_Pa, 		"Phag", 		:literary_chinese 		], # may also be :mandarin_chineese ?
	[ "85" , 	:Phoenician, 		"Phnx", 		:phoenician 			],
	[ "86" , 	:Pollard_Phonetic, 	"Plrd", 		:undefined			], # Called also :Pollard and :Miao
												           # This script corresponds to this language :Large_Flowery_Miao
												           # but we don't include it beceause Qt Unicode does not know it
	[ "87" , 	:Rejang, 		"Rjng", 		:undefined			], # Called also :Redjang and :Kaganga
												           # This script corresponds to the  language of the same name :Rejang
												           # but we don't include it beceause Qt Unicode does not know it
	[ "88" , 	:Runic, 		"Runr", 		:german 			], # can also be :old_norse
	[ "89" , 	:Samaritan, 		"Samr", 		:aramaic 			],
	[ "90" , 	:Saurashtra, 		"Saur", 		:saurashtra 			],
	[ "91" , 	:Sharada, 		"Shrd", 		:sanskrit 			], # Called also :Śāradā
	[ "92" , 	:Shavian, 		"Shaw", 		:english 			], # Called also :Shaw
	[ "93" , 	:Sora_Sompeng, 		"Sora", 		:undefined			], # The script is used in :Sora language
												           # but we don't include it beceause Qt Unicode does not know it
	[ "94" , 	:Cuneiform, 		"Xsux", 		:Akkadian 			], # Called also :Sumero_Akkadian
	[ "95" , 	:Sundanese, 		"Sund", 		:sundanese 			],
	[ "96" , 	:Syloti_Nagri, 		"Sylo", 		:undefined			], # This script is used in :Sylheti language
												           # but we don't include it beceause Qt Unicode does not know it
	[ "97" , 	:Tagalog, 		"Tglg", 		:filipino 			], # Called also :Baybayin and :Alibata
	[ "98" , 	:Tagbanwa, 		"Tagb", 		:undefined			], # This script is used in :Tagbanwa language
												           # but we don't include it beceause Qt Unicode does not know it
	[ "99" , 	:Tai_Le, 		"Tale", 		:tai_nua 			],
	[ "100" , 	:Tai_Viet, 		"Tavt", 		:tai_dam 			],
	[ "101" , 	:Takri, 		"Takr", 		:dogri 				], # Called also :Ṭākrī and :Ṭāṅkrī
	[ "102" , 	:Ugaritic, 		"Ugar", 		:ugaritic 			],
	[ "103" , 	:Braille, 		"Brai", 		:undefined 			],
	[ "104" , 	:Hiragana, 		"Hira", 		:undefined 			],
	[ "105" , 	:Caucasian_Albanian, 	"Aghb", 		:undefined 			], # This script is used in :Lezghian language
												           # but we don't include it beceause Qt Unicode does not know it
	[ "106" , 	:Bassa_Vah, 		"Bass", 		:undefined			],
	[ "107" , 	:Duployan, 		"Dupl", 		:french 			], # Called also :Duployan_Shorthand and :Duployan_Stenography
	[ "108" , 	:Elbasan, 		"Elba", 		:albanian 			],
	[ "109" , 	:Grantha, 		"Gran", 		:sanskrit 			],
	[ "110" , 	:Pahawh_Hmong, 		"Hmng", 		:undefined			], # This script is used in :Hmong language
												           # but we don't include it beceause Qt Unicode does not know it
	[ "111" , 	:Khojki, 		"Khoj", 		:sindhi 			],
	[ "112" , 	:Linear_A, 		"Lina", 		:undefined			], # This script is used in :Linear_A language
												           # but we don't include it beceause Qt Unicode does not know it
	[ "113" , 	:Mahajani, 		"Mahj", 		:hindi 				],
	[ "114" , 	:Manichaean, 		"Mani", 		:persian 			],
	[ "115" , 	:Mende_Kikakui, 	"Mend", 		:undefined			],
	[ "116" , 	:Modi, 			"Modi", 		:marathi 			], # Spelled also :Moḍī
	[ "117" , 	:Mro, 			"Mroo", 		:undefined			], # Spelled also :Mru
												           # This script is used in :Mru language
												           # but we don't include it beceause Qt Unicode does not know it
	[ "118" , 	:Old_North_Arabian, 	"Narb", 		:undefined			], # Called also :Ancient_North_Arabian
												           # This script is used in :Ancient_North_Arabian language
												           # but we don't include it beceause Qt Unicode does not know it
	[ "119" , 	:Nabataean, 		"Nbat", 		:aramaic 			],
	[ "120" , 	:Palmyrene, 		"Palm", 		:aramaic 			],
	[ "121" , 	:Pau_Cin_Hau, 		"Pauc", 		:undefined			],
	[ "122" , 	:Old_Permic, 		"Perm", 		:komi 				],
	[ "123" , 	:Psalter_Pahlavi, 	"Phlp", 		:pahlavi 			],
	[ "124" , 	:Siddham, 		"Sidd", 		:sanskrit 			], # Called also :Siddhaṃ and :Siddhamātṛkā
	[ "125" , 	:Khudawadi, 		"Sind", 		:sindhi 			], # Called alos :Sindhi
	[ "126" , 	:Tirhuta, 		"Tirh", 		:maithili 			],
	[ "127" , 	:Varang_Kshiti, 	"Wara", 		:undefined			], # Called also :Warang_Citi
												           # This script is used in :Ho language
												           # but we don't include it beceause Qt Unicode does not know it
	[ "128" , 	:Ahom, 			"Ahom", 		:undefined			], # Called also :Tai_Ahom
	[ "129" , 	:Anatolian_Hieroglyphs, "Hluw", 		:undefined			], # Called also :Luwian_Hieroglyphs and Hittite_Hieroglyphs
	[ "130" , 	:Hatran, 		"Hatr", 		:undefined			],
	[ "131" , 	:Multani, 		"Mult", 		:undefined			],
	[ "132" , 	:Old_Hungarian, 	"Hung", 		:undefined			], # Called also :Hungarian_Runic
	[ "133" , 	:Sign_Writing, 		"Sgnw", 		:undefined			], # should we consider :american_sign_language
												           # as a default language for this script ?
	[ "134" , 	:Adlam, 		"Adlm", 		:fulah 				],
	[ "135" , 	:Bhaiksuki, 		"Bhks", 		:undefined			],
	[ "136" , 	:Marchen, 		"Marc", 		:undefined			],
	[ "137" , 	:Newa, 			"Newa", 		:newari 			], # Called also :Newar, :Newari, and :Nepāla_Lipi
	[ "138" , 	:Osage, 		"Osge", 		:osage 				],
	[ "139" , 	:Tangut, 		"Tang", 		:undefined			],
	[ "140" , 	:Han_With_Bopomofo, 	"Hanb", 		:literary_chinese 		], # Alias for Han + Bopomofo
												           # We considered here the same default language we put for
												           # the :Bopofomo script (could also be :mandarin_chinese ?)
	[ "141" , 	:Jamo, 			"Jamo", 		:undefined			]  #  Jamo subset of Hangul
]

func LocaleScriptsXT()
	return _aLocaleScriptsXT

func LocaleScripts()
	aResult = []
	for aScriptInfo in LocaleScriptsXT()
		aResult + aScriptInfo[2]
	next

	return aResult

func Script(p)
	if isList(p) and Q(p).IsOfNamedParam()
		p = p[2]
	ok

	if NOT (isString(p) or IsStzString(p) or IsStzText(p) or IsStzChar(p) )
		StzRaise("Incorrect param type! p must be a char, string, stzChar, stzString, or stzText.")
	ok

	if isString(p) and IsChar(p)
		return StzCharQ(p).Script()

	but isString(p)
		return StzTextQ(p).Script()

	but IsStzChar(p)
		return p.Script()

	but IsStzString()
		return p.ToStzText().Script()

	but IsStzText()
		return p.Script()

	ok

	#< @FunctionAlternativeForms

	func ScriptOf(p)
		return Script(p)

	func @Script(p)
		return Script(p)

	func @ScriptOf(p)
		return Script(p)

	#>

func Scripts(p)
	if isList(p) and Q(p).IsOfNamedParam()
		p = p[2]
	ok

	if NOT ( isList(p) or isString(p) or IsStzString(p) or IsStzText(p) )
		StzRaise("Incorrect param type! p must be a list, string, stzString or stzText.")
	ok

	if isList(p)
		acResult = []
		nLen = len(p)

		for i = 1 to nLen
			acResult + Script(p[i])
		next

		return acResult

	but isString(p)
		return StzTextQ(p).Scripts()

	but IsStzString(p)
		return p.ToStzText().Scripts()

	but IsStzText(p)
		return p.Scripts()

	ok

	func ScriptsOf(paListStr)
		return Scripts(paListStr)

	func @Scripts(paListStr)
		return ScriptsOf(paListStr)

	func @ScriptsOf(paListStr)
		return Scripts(paListStr)

func StzScriptQ(pcScriptIdentifier)
	return new stzScript(pcScriptIdentifier)

class stzScript

	#NOTE: the class have a @aScriptInfo@ attribute in PRIVATE section
	# We put it there, because we use it just for initializing the object.
	#--> it does not necessarilay contain all the information the class
	# could provide about the script.

	def init(pcScriptIdentifier)
		if NOT isString(pcScriptIdentifier)
			StzRaise("Incorrect param type! You must provide a string.")
		ok

		if trim(pcScriptIdentifier) = ""
			StzRaise("Incorrect param value! pcScriptIdentifier must not be an empty string.")
		ok

		oStr = new stzString(pcScriptIdentifier)

		if oStr.IsScriptName()
			for aScriptInfo in LocaleScriptsXT()
				if lower(aScriptInfo[2]) = lower(pcScriptIdentifier)
					@aScriptInfo@ = aScriptInfo
					exit
				ok
			next

		but oStr.IsScriptCode()
			for aScriptInfo in LocaleScriptsXT()
				if lower(aScriptInfo[1]) = lower(pcScriptIdentifier)
					@aScriptInfo@ = aScriptInfo
					exit
				ok
			next

		but oStr.IsScriptAbbreviation()
			for aScriptInfo in LocaleScriptsXT()
				if lower(aScriptInfo[3]) = lower(pcScriptIdentifier)
					@aScriptInfo@ = aScriptInfo
					exit
				ok
			next		

		but oStr.IsLocaleAbbreviation()

			StzRaise("Feature unsupported yet!")

		else
			StzRaise("Unsupported script identifier!")
		ok

	def Script()
		return @aScriptInfo@[2]

		def Content()
			return This.Script()

		def Value()
			return Content()

	def QtNumber()
		return @aScriptInfo@[1]

		def Number()
			return This.QtNumber()

	def Name()
		return @aScriptInfo@[2]

	def Abbreviation()
		return @aScriptInfo@[3]

	def DefaultLanguage()
		return @aScriptInfo@[4]

		#-- @Alternatives

		def DefaultLanguageName()
			return This.DefaultLanguage()

		def Language()
			return This.DefaultLanguage()

		def LanguageName()
			return This.DefaultLanguage()

		#-- @Misspelled

		def DefaultLangauge()
			return This.DefaultLanguage()

		def DefaultLangaugeName()
			return This.DefaultLanguage()

		def Langauge()
			return This.DefaultLanguage()

		def LangaugeName()
			return This.DefaultLanguage()

	def DefaultLanguageQtNumber()
		/* We could solve it expressively like this:

		return StzLanguageQ(This.DefaultLanguage()).QtNumber()

		But the following is more performant...
		*/

		cLanguage = This.DefaultLanguage()

		for aLanguageInfo in LocaleLanguagesXT()
			if aLanguageInfo[2] = cLanguage
				return aLanguageInfo[1]
			ok
		next

		#-- @Alternatives

		def DefaultLanguageNumber()
			return This.DefaultLanguageQtNumber()

		def LanguageQtNumber()
			return This.DefaultLanguageQtNumber()

		def LanguageNumber()
			return This.DefaultLanguageQtNumber()

		#-- @Misspelled

		def DefaultLangaugeQtNumber()
			return This.DefaultLanguageQtNumber()

		def DefaultLangaugeNumber()
			return This.DefaultLanguageQtNumber()

		def LangaugeQtNumber()
			return This.DefaultLanguageQtNumber()

		def LangaugeNumber()
			return This.DefaultLanguageQtNumber()

	def DefaultLanguageAbbreviation()
		cLanguage = This.DefaultLanguage()

		for aLanguageInfo in LocaleLanguagesXT()
			if aLanguageInfo[2] = cLanguage
				return aLanguageInfo[3]
			ok
		next

		#-- @Alternative

		def LanguageAbbreviation()
			return This.DefaultLanguageAbbreviation()

		#-- @Misspelled

		def LangaugeAbbreviation()
			return This.DefaultLanguageAbbreviation()

		def DefaultLangaugeAbbreviation()
			return This.DefaultLanguageAbbreviation()

	def DefaultCountry()
		/* We could solve it expressively like this:

		return StzLanguageQ(This.DefaultLanguage()).DefaultCountry()

		But the following is more performant...
		*/
		
		cLanguageQtNumber = This.DefaultLanguageQtNumber()

		for aLanguageInfo in LocaleLanguagesXT()
			if aLanguageInfo[1] = cLanguageQtNumber
				return aLanguageInfo[5]
			ok
		next

		def DefaultCountryName()
			return This.DefaultCountry()

		def Country()
			return This.DefaultCountry()

		def CountryName()
			return This.DefaultCountry()
	
	def DefaultCountryQtNumber()

		cCountry = This.DefaultCountry()

		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[2] = cCountry
				return aCountryInfo[1]
			ok
		next

		def DefaultCountryNumber()
			return This.DefaultCountryQtNumber()

		def CountryQtNumber()
			return This.DefaultCountryQtNumber()

		def CountryNumber()
			return This.DefaultCountryQtNumber()

	def Languages()
		return LanguagesInScript(This.Script())

	PRIVATE

	@aScriptInfo@	# The two @ conventionally mean that the attribute is private
			#--> TODO: Generalize this convention in all the library
