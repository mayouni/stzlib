
_aLocaleScriptsXT = [
	/*
	The unicode abreviations are documented here:
	https://unicode.org/iso15924/iso15924-codes.html

	NOTE: we include here only the languages included in Qt Unicode
	--> that we can use to define a locale
	*/
	#     1		    2				3		      4
	#  QtNumber 	ScriptName 		ScriptAbbreviation 	DefaultLanguage
	
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
	[ "15" , 	:Georgian, 		"Geor", 		:Georgian 			],
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
	[ "43" , 	:Buhid , 		"Buhd", 		NULL 				], # ! note that the default language here is :buhid
					 							  	   # but we didn't include it because Qt unicode
					  							  	   # don't support it
	[ "44" , 	:Canadian_Aboriginal, 	"Cans", 		:cree 				], # or :inuktitut or :cree or :ojibwa
	[ "45" , 	:Carian, 		"Cari", 		NULL 				],
	[ "46" , 	:Chakma, 		"Cakm", 		:chakma 			],
	[ "47" , 	:Cham, 			"Cham", 		NULL 				],
	[ "48" , 	:Coptic, 		"Copt", 		:coptic 			],
	[ "49" , 	:Cypriot, 		"Cprt", 		NULL 				],
	[ "50" , 	:Egyptian_Hieroglyphs, 	"Egyp", 		:ancient_egyptian 		], # There is also :Egyptian_Demotic (egyd)
						                     				   # and :Egyptian_Hieratic (egyh)
	[ "51" , 	:Fraser, 		"Lisu", 		NULL 				], # Called also :Lisu
	[ "52" , 	:Glagolitic, 		"Glag", 		NULL 				],
	[ "53" , 	:Gothic, 		"Goth", 		:gothic 			],
	[ "54" , 	:Han, 			"Hant", 		NULL 				],
	[ "55" , 	:Hangul, 		"Hang", 		NULL 				],
	[ "56" , 	:Hanunoo, 		"Hano", 		NULL 				],
	[ "57" , 	:Imperial_Aramaic, 	"Armi", 		NULL 				],
	[ "58" , 	:Inscriptional_Pahlavi, "Phli", 		NULL 				],
	[ "59" , 	:Inscriptional_Parthian,"Prti", 		NULL 				],
	[ "60" , 	:Javanese, 		"Java", 		:javanese 			],
	[ "61" , 	:Kaithi, 		"Kthi", 		NULL 				],
	[ "62" , 	:Katakana, 		"Kana", 		NULL 				],
	[ "63" , 	:Kayah_Li, 		"Kali", 		NULL 				],
	[ "64" , 	:Kharoshthi, 		"Khar", 		NULL 				],
	[ "65" , 	:Lanna, 		"Lana", 		NULL 				], # Called also :Tai_Tham
	[ "66" , 	:Lepcha, 		"Lepc", 		NULL 				], # Called also :Róng. Note that the default language is
					  							   # called :lepcha but we don't include it because Qt Unicode
					  							   # does not recognize it!
	[ "67" , 	:Limbu, 		"Limb", 		NULL 				], # The default language is called :limbu but we don't include it
	[ "68" , 	:Linear_B, 		"Linb", 		:ancient_greek 			],
	[ "69" , 	:Lycian, 		"Lyci", 		NULL 				], # The default language is called :lycian but we don't include it
	[ "70" , 	:Lydian, 		"Lydi", 		NULL 				], # The default language is called :lydian but we don't include it
	[ "71" , 	:Mandaean, 		"Mand", 		NULL 				], # Called also :Mandaic. Note that the default language is calle :Classical_Mandaic
					    							   # but we don't inlcude it because Qt Uniocde does not recognise it
	[ "72" , 	:Meitei_Mayek, 		"Mtei", 		:manipuri 			], # Called also :Meithei and :Meetei
	[ "73" , 	:Meroitic_Hieroglyphs, 	"Mero", 		NULL 				],
	[ "74" , 	:Meroitic_Cursive, 	"Merc", 		NULL 				], # The default language is called :Meroitic_Cursive but
						    						   # we don't include it beceause Qt Unicode does not know it
	[ "75" , 	:Nko, 			"Nkoo", 		:nko 				], # Spelled N’Ko
	[ "76" , 	:New_Tai_Lue, 		"Talu", 		NULL 				], # The default language for this script is Lü, but
					      							   # we don't include it beceause Qt Unicode does not know it
	[ "77" , 	:Ogham, 		"Ogam", 		:old_irish 			],
	[ "78" , 	:Ol_Chiki, 		"Olck", 		:santali 			],
	[ "79" , 	:Old_Italic, 		"Ital", 		NULL 				], # This script is used in these languages: Umbrian, Oscan and Etruscan
					      							   # we don't include them beceause Qt Unicode does not know them
	[ "80" , 	:Old_Persian, 		"Xpeo", 		:old_persian 			],
	[ "81" , 	:Old_South_Arabian, 	"Sarb", 		NULL 				], # This script is used for language Sabaean, but
						     						   # we don't include it beceause Qt Unicode does not know it
	[ "82" , 	:Orkhon, 		"Orkh", 		NULL 				], # Called also :Old_Turkic and :Orkhon_Runic
												   # Note that the language corresponding to this script
												   # is :Old_Turkish, but we don't include it because Qt Unicode										   # does not knowt it
	[ "83" , 	:Osmanya, 		"Osma", 		:somali 			],
	[ "84" , 	:Phags_Pa, 		"Phag", 		:literary_chinese 		], # may also be :mandarin_chineese ?
	[ "85" , 	:Phoenician, 		"Phnx", 		:phoenician 			],
	[ "86" , 	:Pollard_Phonetic, 	"Plrd", 		NULL 				], # Called also :Pollard and :Miao
												   # This script corresponds to this language :Large_Flowery_Miao
												   # but we don't include it beceause Qt Unicode does not know it
	[ "87" , 	:Rejang, 		"Rjng", 		NULL 				], # Called also :Redjang and :Kaganga
												   # This script corresponds to the  language of the same name :Rejang
												   # but we don't include it beceause Qt Unicode does not know it
	[ "88" , 	:Runic, 		"Runr", 		:german 			], # can also be :old_norse
	[ "89" , 	:Samaritan, 		"Samr", 		:aramaic 			],
	[ "90" , 	:Saurashtra, 		"Saur", 		:saurashtra 			],
	[ "91" , 	:Sharada, 		"Shrd", 		:sanskrit 			], # Called also :Śāradā
	[ "92" , 	:Shavian, 		"Shaw", 		:english 			], # Called also :Shaw
	[ "93" , 	:Sora_Sompeng, 		"Sora", 		NULL 				], # The script is used in :Sora language
												   # but we don't include it beceause Qt Unicode does not know it
	[ "94" , 	:Cuneiform, 		"Xsux", 		:Akkadian 			], # Called also :Sumero_Akkadian
	[ "95" , 	:Sundanese, 		"Sund", 		:sundanese 			],
	[ "96" , 	:Syloti_Nagri, 		"Sylo", 		NULL 				], # This script is used in :Sylheti language
												   # but we don't include it beceause Qt Unicode does not know it
	[ "97" , 	:Tagalog, 		"Tglg", 		:filipino 			], # Called also :Baybayin and :Alibata
	[ "98" , 	:Tagbanwa, 		"Tagb", 		NULL 				], # This script is used in :Tagbanwa language
												   # but we don't include it beceause Qt Unicode does not know it
	[ "99" , 	:Tai_Le, 		"Tale", 		:tai_nua 			],
	[ "100" , 	:Tai_Viet, 		"Tavt", 		:tai_dam 			],
	[ "101" , 	:Takri, 		"Takr", 		:dogri 				], # Called also :Ṭākrī and :Ṭāṅkrī
	[ "102" , 	:Ugaritic, 		"Ugar", 		:ugaritic 			],
	[ "103" , 	:Braille, 		"Brai", 		NULL 				],
	[ "104" , 	:Hiragana, 		"Hira", 		NULL 				],
	[ "105" , 	:Caucasian_Albanian, 	"Aghb", 		NULL 				], # This script is used in :Lezghian language
												   # but we don't include it beceause Qt Unicode does not know it
	[ "106" , 	:Bassa_Vah, 		"Bass", 		NULL 				],
	[ "107" , 	:Duployan, 		"Dupl", 		:french 			], # Called also :Duployan_Shorthand and :Duployan_Stenography
	[ "108" , 	:Elbasan, 		"Elba", 		:albanian 			],
	[ "109" , 	:Grantha, 		"Gran", 		:sanskrit 			],
	[ "110" , 	:Pahawh_Hmong, 		"Hmng", 		NULL 				], # This script is used in :Hmong language
												   # but we don't include it beceause Qt Unicode does not know it
	[ "111" , 	:Khojki, 		"Khoj", 		:sindhi 			],
	[ "112" , 	:Linear_A, 		"Lina", 		NULL 				], # This script is used in :Linear_A language
												   # but we don't include it beceause Qt Unicode does not know it
	[ "113" , 	:Mahajani, 		"Mahj", 		:hindi 				],
	[ "114" , 	:Manichaean, 		"Mani", 		:persian 			],
	[ "115" , 	:Mende_Kikakui, 	"Mend", 		NULL 				],
	[ "116" , 	:Modi, 			"Modi", 		:marathi 			], # Spelled also :Moḍī
	[ "117" , 	:Mro, 			"Mroo", 		NULL 				], # Spelled also :Mru
												   # This script is used in :Mru language
												   # but we don't include it beceause Qt Unicode does not know it
	[ "118" , 	:Old_North_Arabian, 	"Narb", 		NULL 				], # Called also :Ancient_North_Arabian
												   # This script is used in :Ancient_North_Arabian language
												   # but we don't include it beceause Qt Unicode does not know it
	[ "119" , 	:Nabataean, 		"Nbat", 		:aramaic 			],
	[ "120" , 	:Palmyrene, 		"Palm", 		:aramaic 			],
	[ "121" , 	:Pau_Cin_Hau, 		"Pauc", 		NULL 				],
	[ "122" , 	:Old_Permic, 		"Perm", 		:komi 				],
	[ "123" , 	:Psalter_Pahlavi, 	"Phlp", 		:pahlavi 			],
	[ "124" , 	:Siddham, 		"Sidd", 		:sanskrit 			], # Called also :Siddhaṃ and :Siddhamātṛkā
	[ "125" , 	:Khudawadi, 		"Sind", 		:sindhi 			], # Called alos :Sindhi
	[ "126" , 	:Tirhuta, 		"Tirh", 		:maithili 			],
	[ "127" , 	:Varang_Kshiti, 	"Wara", 		NULL 				], # Called also :Warang_Citi
												   # This script is used in :Ho language
												   # but we don't include it beceause Qt Unicode does not know it
	[ "128" , 	:Ahom, 			"Ahom", 		NULL 				], # Called also :Tai_Ahom
	[ "129" , 	:Anatolian_Hieroglyphs, "Hluw", 		NULL 				], # Called also :Luwian_Hieroglyphs and Hittite_Hieroglyphs
	[ "130" , 	:Hatran, 		"Hatr", 		NULL 				],
	[ "131" , 	:Multani, 		"Mult", 		NULL 				],
	[ "132" , 	:Old_Hungarian, 	"Hung", 		NULL 				], # Called also :Hungarian_Runic
	[ "133" , 	:Sign_Writing, 		"Sgnw", 		NULL 				], # should we consider :american_sign_language
												   # as a default language for this script ?
	[ "134" , 	:Adlam, 		"Adlm", 		:fulah 				],
	[ "135" , 	:Bhaiksuki, 		"Bhks", 		NULL 				],
	[ "136" , 	:Marchen, 		"Marc", 		NULL 				],
	[ "137" , 	:Newa, 			"Newa", 		:newari 			], # Called also :Newar, :Newari, and :Nepāla_Lipi
	[ "138" , 	:Osage, 		"Osge", 		:osage 				],
	[ "139" , 	:Tangut, 		"Tang", 		NULL 				],
	[ "140" , 	:Han_With_Bopomofo, 	"Hanb", 		:literary_chinese 		], # Alias for Han + Bopomofo
												   # We considered here the same default language we put for
												   # the :Bopofomo script (could also be :mandarin_chinese ?)
	[ "141" , 	:Jamo, 			"Jamo", 		NULL 				] #  Jamo subset of Hangul
]

func LocaleScriptsXT()
	return _aLocaleScriptsXT

func LocaleScripts()
	aResult = []
	for aScriptInfo in LocaleScriptsXT()
		aResult + aScriptInfo[2]
	next

	return aResult

func StzScriptQ(pcScriptIdentifier)
	return new stzScript(pcScriptIdentifier)

class stzScript

	# NOTE: the class have a @aScriptInfo@ attribute in PRIVATE section
	# We put it there, because we use it just for initializing the object.
	# --> it does not necessarilay contain all the information the class
	# could provide about the script.

	def init(pcScriptIdentifier)
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
			// TODO

		else
			raise(stzScriptError(:UnsupportedScriptIdentifier))
		ok

	def Script()
		return @aScriptInfo@[2]

		def Content()
			return This.Script()

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

		def DefaultLanguageName()
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

		def DefaultLanguageNumber()
			return This.DefaultLanguageQtNumber()

	def DefaultLanguageAbbreviation()
		cLanguage = This.DefaultLanguage()

		for aLanguageInfo in LocaleLanguagesXT()
			if aLanguageInfo[2] = cLanguage
				return aLanguageInfo[3]
			ok
		next

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
	
	def DefaultCountryQtNumber()

		cCountry = This.DefaultCountry()

		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[2] = cCountry
				return aCountryInfo[1]
			ok
		next

		def DefaultCountryNumber()
			return This.DefaultCountryQtNumber()

	def Languages()
		return LanguagesInScript(This.Script())

	PRIVATE

	@aScriptInfo@	# The two @ conventionally mean that the attribute is private
			# --> Generalize this convention in all the library
