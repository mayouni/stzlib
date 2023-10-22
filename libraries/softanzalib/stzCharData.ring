/*
Softanza Library

This file contains data used with the stzChar class, that
is not made available in Qt

Or that are available in Qt but we simplify it, or enrich it
here for our own use.

Author: Mansour Ayouni (kalidianow@gmail.com)
*/


  ////////////////////////////////
 ///   OUTLINE OF THIS FILE   ///
////////////////////////////////

/*
General Unicode info
	Unicode scripts
	Unicode directions
	Unicode categories
	Unicode blocks (TODO)
	Unicode versions

Arabic chars
	Arabic Basmalah
	Arabic 7arakets
	Arabic Shaddah
	Arabic Tamdeed
	Arabic Tinween
	Arabic chars unicodes
	Arabic Rasm chars
	Arabic Hamzahs

Latin chars
	Latin chars unicodes

Numbers staff
	Romans numbers
	Mandarin numbers
	Arabic number fractions
	Octal chars
	Hex chars

Special chars
	Turned chars
	Invertible chars
	Circled chars
	Invisible chars

	Icons chars (TODO)
	Other special chars

Word staff
	Word and sentence separators
	Word non-letter chars

Diacritics
	Latin diactritics
	Arabic diacritics
	Greek diacritics (TODO)
	Hebrew diacritics (TODO)

Dotless LETTERS
	Arabic dottles letters
	Latin Dotless letters

	Mathematical Dotless letters (TODO)
	Any others (TODO)

*/

  ////////////////////////
 ///   DATA SECTION   ///
////////////////////////


	  #--------------------------------------------------------------------#
	 #   UNICODE SCRIPTS, DIRECTIONS, CATEGORIES, BLOCKS, AND VERSIONS    #
	#--------------------------------------------------------------------#

	# Number of chars in Unicode

	_nNumberOfCharsInUnicode = 149_186 # Version 15.0

	# Unicode scripts

	_aUnicodeScriptsXT = [
		# code, name, ranges, languages
		[ "0", :Unknown, [[]], [] ],
		[ "1", :Inherited, [[]], [] ],
		[ "2", :Common, [[]], [] ],
		[ "3", :Latin, [ [0,591] , [7680,7935] , [11360,11391] , [42784,43007] , [43824,43887] ],
			[:Acehnese, :Adyghe, :Afar, :Afrikaans, :Albanian, :Aragonese,
			:Asturian, :Aymara, :Azeri, :Bai, :Banjar, :Basque, :BearyBashe,
			:Belarusian, :Belarusian, :Betawi, :Bislama, :Boholano, :Bosnian,
			:Breton, :BritishLatin, :Bulgarian, :Catalan, :Cebuano, :Chamorro,
			:Cherokee, :Cornish, :Corsican, :Cree, :Croatian, :Czech, :Danish,
			:Dayak, :Dutch, :English, :Esperanto, :Estonian, :Faroese, :Fijian,
			:Filipino, :Finnish, :French, :Fula, :Gaelic, :Galician, :Gaulish,
			:German, :Gikuyu, :Guaraní, :HaitianCreole, :Hausa, :Hawaiian,
			:HiriMotu, :Hmong, :Hungarian, :Hungarian, :Icelandic, :Ido, :Igbo,
			:Ilocano, :Indonesian, :InnuAimun, :Interlingua, :Irish, :Italian,
			:Javanese, :JudeoSpanish, :Kabylian, :Kazakh, :Khasi, :Kinyarwanda,
			:Kirundi, :Klingon, :Kongo, :Konkani, :Kurdish, :Ladino, :Latin,
			:Latvian, :Laz, :Leonese, :Lingala, :Lithuanian, :Luganda, :Luxembourgish,
			:Malagasy, :Malay, :Malé, :Maltese, :Manx, :Māori, :Marshallese,
			:MauritianCreole, :Minangkabau, :Moldovan, :Mongolian, :Montenegrin,
			:Nahuatl, :Nauruan, :Navaho, :NdebeleNorthern, :Ngai, :Nias, :Nobiin,
			:NorthFrisian, :Norwegian, :Occitan, :OldDanish, :OldDutch, :OldEnglish,
			:OldFrisian, :OldHighGerman, :OldScandinavian, :Oromo, :Palauan,
			:Picard, :Polish, :Portuguese, :quechua, :Rohingya, :Romanian,
			:Romansh, :Samoan, :Sasak, :SaterlandFrisian, :Scots, :Serbian,
			:Serbian, :SeychelloisCreole, :Shona, :Slovak, :Slovene, :Somali,
			:SothoNorthern, :SothoSouthern, :Spanish, :Sundanese, :Swahili,
			:Swati, :Swedish, :Tagalog, :Tahitian, :Tamazight, :Tatar, :Tetum,
			:TokPisin, :Tongan, :Tsonga, :Tswana, :TunisianArabic, :Turkish,
			:Turkmen, :Turoyo, :Uzbek, :Vastese, :Venda, :Vietnamese, :Volapük,
			:Võro, :Walloon, :Welsh, :WestFrisian, :Wolof, :Xhosa, :Yoruba,
			:Zazaki, :Zhuang, :Zulu] ],
		[ "4", :Greek, [ [880,1023], [7936,8191], [65856,65935] ], [:Greek,:Coptic] ],
		[ "5", :Cyrillic, [ [1024,1279], [1280,1327], [7296,7311], [11744,11775], [42560,42655] ],
			[:Belarusian, :Bosnian, :Bulgarian, :Ladino, :Kazakh, :Kyrgyz, :Macedonian,
			:Mongolian, :Montenegrin, :Russian, :Serbian, :Ukrainian, :Persian] ],
		[ "6", :Armenian, [[1328,1423]], [:Armenian] ],
		[ "7", :Hebrew, [[1424,1535]], [:Hebrew] ],
		[ "8", :Arabic, [ [1536,1791], [1872,1919], [2208,2303], [64336,65023], [65136,65279], [126464,126719] ],
			[:Acehnese, :Adyghe, :Afrikaans, :Arabic, :Algerian, :Egyptian,
			:Lebanese, :Moroccan, :Iraqi, :Tunisian, :Afar, :Azerbaijani,
			:Arwi, :Bakhtiari, :Balochi, :Balti, :Banjar, :Bashkir,
			:Belarusian, :Bengali, :Amazigh, :Bhadrawahi, :Bosnian,
			:Brahui, :Burushaski , :CentralKurdish, :Cham, :Chechen,
			:Chinese, :Comorian, :CrimeanTatar, :Dari, :Dungan, :Dogri,
			:Dyula, :French, :Filipino, :Fulani, :Gilaki, :Greek, :Harari,
			:Hausa, :Ingush, :Javanese, :JolaFonyi, :JudeoArabic, :JudeoTunisianArabic,
			:JudaeoSpanish, :Kanuri, :Karakalpak, :Kashmiri, :Kazakh, :Khowar,
			:Kurdish, :Kyrgyz, :Lak, :Lezgin, :Luri, :Madurese, :Malagasy,
			:Malay, :Mandinka, :Marwari, :Mazanderani, :Minangkabau,
			:Mozarabic, :Nobiin, :Ngai, :OttomanTurkish, :Pashtu, :Persian,
			:Punjabi, :qashqai, :Rohingya, :Salar, :Saraiki, :Sindhi,
			:Somali, :Songhay, :Spanish, :Swahili, :Tajik, :Talysh,
			:Tatar, :Tausug, :Tuareg, :Turkish, :Turkmen, :Urdu, :Uyghur,
			:Uzbek, :Wakhi, :Wolio, :Wolof, :Yoruba, :Zarma] ],
		[ "9", :Syriac, [[]], [] ],
		[ "10", :Thaana, [[]], [] ],
		[ "11", :Devanagari, [[]], [] ],
		[ "12", :Bengali, [2432,2559], [:Bengali] ],
		[ "13", :Gurmukhi, [[]], [] ],
		[ "14", :Gujarati, [[]], [] ],
		[ "15", :Oriya, [[]], [] ],
		[ "16", :Tamil, [[2944,3007]], [:Tamil] ],
		[ "17", :Telugu, [[3072,3199]], [:Telugu] ],
		[ "18", :Kannada, [[]], [] ],
		[ "19", :Malayalam, [[]], [] ],
		[ "20", :Sinhala, [[]], [] ],
		[ "21", :Thai, [[]], [] ],
		[ "22", :Lao, [[]], [] ],
		[ "23", :Tibetan, [[]], [] ],
		[ "24", :Myanmar, [[]], [] ],
		[ "25", :Georgian, [[]], [] ],
		[ "26", :Hangul, [[]], [] ],
		[ "27", :Ethiopic, [[]], [] ],
		[ "28", :Cherokee, [[]], [] ],
		[ "29", :CanadianAboriginal, [[]], [] ],
		[ "30", :Ogham, [[]], [] ],
		[ "31", :Runic, [[]], [] ],
		[ "32", :Khmer, [[]], [] ],
		[ "33", :Mongolian, [[]], [] ],
		[ "34", :Hiragana, [[]], [] ],
		[ "35", :Katakana, [[]], [] ],
		[ "36", :Bopomofo, [[]], [] ],
		[ "37", :Han, [[]], [] ],
		[ "38", :Yi, [[]], [] ],
		[ "39", :OldItalic, [[]], [] ],
		[ "40", :Gothic, [[]], [] ],
		[ "41", :Deseret, [[]], [] ],
		[ "42", :Tagalog, [[]], [] ],
		[ "43", :Hanunoo, [[]], [] ],
		[ "44", :Buhid, [[]], [] ],
		[ "45", :Tagbanwa, [[]], [] ],
		[ "46", :Coptic, [[]], [] ],
		[ "47", :Limbu, [[]], [] ],
		[ "48", :TaiLe, [[]], [] ],
		[ "49", :LinearB, [[]], [] ],
		[ "50", :Ugaritic, [[]], [] ],
		[ "51", :Shavian, [[]], [] ],
		[ "52", :Osmanya, [[]], [] ],
		[ "53", :Cypriot, [[]], [] ],
		[ "54", :Braille, [[]], [] ],
		[ "55", :Buginese, [[]], [] ],
		[ "56", :NewTaiLue, [[]], [] ],
		[ "57", :Glagolitic, [[]], [] ],
		[ "58", :Tifinagh, [[]], [] ],
		[ "59", :SylotiNagri, [[]], [] ],
		[ "60", :OldPersian, [[]], [] ],
		[ "61", :Kharoshthi, [[]], [] ],
		[ "62", :Balinese, [[]], [] ],
		[ "63", :Cuneiform, [[]], [] ],
		[ "64", :Phoenician, [[]], [] ],
		[ "65", :PhagsPa, [[]], [] ],
		[ "66", :Nko, [[]], [] ],
		[ "67", :Sundanese, [[]], [] ],
		[ "68", :Lepcha, [[]], [] ],
		[ "69", :OlChiki, [[]], [] ],
		[ "70", :Vai, [[]], [] ],
		[ "71", :Saurashtra, [[]], [] ],
		[ "72", :KayahLi, [[]], [] ],
		[ "73", :Rejang, [[]], [] ],
		[ "74", :Lycian, [[]], [] ],
		[ "75", :Carian, [[]], [] ],
		[ "76", :Lydian, [[]], [] ],
		[ "77", :Cham, [[]], [] ],
		[ "78", :TaiTham, [[]], [] ],
		[ "79", :TaiViet, [[]], [] ],
		[ "80", :Avestan, [[]], [] ],
		[ "81", :EgyptianHieroglyphs, [[]], [] ],
		[ "82", :Samaritan, [[]], [] ],
		[ "83", :Lisu, [[]], [] ],
		[ "84", :Bamum, [[]], [] ],
		[ "85", :Javanese, [[]], [] ],
		[ "86", :MeeteiMayek, [[]], [] ],
		[ "87", :ImperialAramaic, [[]], [] ],
		[ "88", :OldSouthArabian, [[]], [] ],
		[ "89", :InscriptionalParthian, [[]], [] ],
		[ "90", :InscriptionalPahlavi, [[]], [] ],
		[ "91", :OldTurkic, [[]], [] ],
		[ "92", :Kaithi, [[]], [] ],
		[ "93", :Batak, [[]], [] ],
		[ "94", :Brahmi, [[]], [] ],
		[ "95", :Mandaic, [[]], [] ],
		[ "96", :Chakma, [[]], [] ],
		[ "97", :MeroiticCursive, [[]], [] ],
		[ "98", :MeroiticHieroglyphs, [[]], [] ],
		[ "99", :Miao, [[]], [] ],
		[ "100", :Sharada, [[]], [] ],
		[ "101", :SoraSompeng, [[]], [] ],
		[ "102", :Takri, [[]], [] ],
		[ "103", :CaucasianAlbanian, [[]], [] ],
		[ "104", :BassaVah, [[]], [] ],
		[ "105", :Duployan, [[]], [] ],
		[ "106", :Elbasan ],
		[ "107", :Grantha, [[]], [] ],
		[ "108", :PahawhHmong, [[]], [] ],
		[ "109", :Khojki, [[]], [] ],
		[ "110", :LinearA, [[]], [] ],
		[ "111", :Mahajani, [[]], [] ],
		[ "112", :Manichaean, [[]], [] ],
		[ "113", :MendeKikakui, [[]], [] ],
		[ "114", :Modi, [[]], [] ],
		[ "115", :Mro, [[]], [] ],
		[ "116", :OldNorthArabian, [[]], [] ],
		[ "117", :Nabataean, [[]], [] ],
		[ "118", :Palmyrene, [[]], [] ],
		[ "119", :PauCinHau, [[]], [] ],
		[ "120", :OldPermic, [[]], [] ],
		[ "121", :PsalterPahlavi, [[]], [] ],
		[ "122", :Siddham, [[]], [] ],
		[ "123", :Khudawadi, [[]], [] ],
		[ "124", :Tirhuta, [[]], [] ],
		[ "125", :WarangCiti, [[]], [] ],
		[ "126", :Ahom, [[]], [] ],
		[ "127", :AnatolianHieroglyphs, [[]], [] ],
		[ "128", :Hatran, [[]], [] ],
		[ "129", :Multani, [[]], [] ],
		[ "130", :OldHungarian, [[]], [] ],
		[ "131", :SignWriting, [[]], [] ],
		[ "132", :Adlam, [[]], [] ],
		[ "133", :Bhaiksuki, [[]], [] ],
		[ "134", :Marchen, [[]], [] ],
		[ "135", :Newa, [[]], [] ],
		[ "136", :Osage, [[]], [] ],
		[ "137", :Tangut, [[]], [] ],
		[ "138", :MasaramGondi, [[]], [] ],
		[ "139", :Nushu, [[]], [] ],
		[ "140", :Soyombo, [[]], [] ],
		[ "141", :ZanabazarSquare, [[]], [] ],
		[ "142", :Dogra, [[]], [] ],
		[ "143", :GunjalaGondi, [[73056,73135]], [:Gondi] ],
		[ "144", :HanifiRohingya, [[68864,68927]], [:Rohingya] ],
		[ "145", :Makasar, [[73440,73455]], [:Makasar] ],
		[ "146", :Medefaidrin, [[93760,93855]], [:Medefaidrin] ],
		[ "147", :OldSogdian, [[69376,69423]], [:Sogdian] ],
		[ "148", :Sogdian, [[69424,69487]], [:Sogdian] ],
		[ "149", :Elymaic, [[69600,69631]], [:Aramaic] ],
		[ "150", :Nandinagari, [[72096,72191]], [:Sansknada] ],
		[ "151", :NyiakengPuachueHmong, [[123136,123215]], [:Hmong] ],
		[ "152", :Wancho, [[123584,123647]], [:Konyak]  ],
		[ "153", :Chorasmian, [[69552,69599]], [:Khwarezmian] ],
		[ "154", :DivesAkuru, [[71936,72031]], [:Maldivian] ],
		[ "155", :KhitanSmallScript, [[101120, 101631]], [:Chineese] ],
		[ "156", :Yezidi, [[69248, 69311]], [:Kurdish] ]	
		
	]

	# Unicode directions

	_aUnicodeDirectionsXT = [
		# QtNbr >  QtName  > StzName > Description
		[ "0", :DirL, :LeftToRight, "Left-to-right" ],
		[ "1", :DirR, :RightToLeft, "Right-to-left" ],
		[ "2", :DirEN, :EuropeanNumber, "European Number" ],
		[ "3", :DirES, :EuropeanNumberSeparator, "European Number Separator" ],
		[ "4", :DirET, :EuropeanNumberTerminator, "European Number Terminator" ],
		[ "5", :DirAN, :ArabicNumber, "Arabic Number" ],
		[ "6", :DirCS, :CommonNumberSeparator, "Common Number Separator" ],
		[ "7", :DirB, :ParagraphSeparator, "Paragraph Separator" ],
		[ "8", :DirS, :SectionSeparator, "Section Separator" ],
		[ "9", :DirWS, :Whitespace, "Whitespace" ],
		[ "10", :DirON, :OtherNeutrals, "Other Neutrals" ],
		[ "11", :DirLRE, :LeftToRightEmbedding, "Left-to-right Embedding" ],
		[ "12", :DirLRO, :LeftToRightOverride, "Left-to-right Override" ],
		[ "13", :DirAL, :RightToLeftArabic, "Right-to-left Arabic" ],
		[ "14", :DirRLE, :RightToLeftEmbedding, "Right-to-left Embedding" ],
		[ "15", :DirRLO, :RightToLeftOverride, "Right-to-left Override" ],
		[ "16", :DirPDF, :PopDirectionalFormat, "Pop Directional Format" ],
		[ "17", :DirNSM, :NonSpacingMark, "Non-Spacing Mark" ],
		[ "18", :DirBN, :BoundaryNeutral, "Boundary Neutral" ]
	
		/*
		TODO: Check for right-to-left Isolate...
		*/
	]
	
	# Unicode categories

	_aUnicodeCategoriesXT = [
		// Spacing mark
		[ "0", :Mark_NonSpacing ],
		[ "1", :Mark_SpacingCombining ],
		[ "2", :Mark_Enclosing ],
	
		[ "3", :Number_DecimalDigit ],
		[ "4", :Number_Letter ],
		[ "5", :Number_Other ], # ***
	
		[ "6", :Separator_Space	],
		[ "7", :Separator_Line ],
		[ "8", :Separator_Paragraph ],
	
		[ "14", :Letter_Uppercase ],
		[ "15", :Letter_Lowercase ],
		[ "16", :Letter_Titlecase ],
		[ "17", :Letter_Modifier ], # ***
		[ "18", :Letter_Other ],
	
		[ "19", :Punctuation_Connector ], # ***
		[ "20", :Punctuation_Dash ],
		[ "21", :Punctuation_Open ],
		[ "22", :Punctuation_Close ],
		[ "23", :Punctuation_InitialQuote ],
		[ "24", :Punctuation_FinalQuote ],
		[ "25", :Punctuation_Other ],
	
		[ "26", :Symbol_Math ],
		[ "27", :Symbol_Currency ],
		[ "28", :Symbol_Modifier ],
		[ "29", :Symbol_Other ],
	
		[ "9", :Other_Control ],
		[ "10", :Other_Format ],
		[ "11", :Other_Surrogate ], # ***
		[ "12", :Other_PrivateUse ],
		[ "13", :Other_NotAssigned ]
	]
	
	  #-----------------#
	 #   PUNCTUATION   #
	#-----------------#

	# WARNING : The two unicode blocks GENERAL_PUNC and SUPPLEMENTAL_PUNCT
	# do not contain basic punctuations like ",",";", and so on.
	# Those are classified in the category "Other Punctuation". Listed here:
	# https://www.compart.com/en/unicode/category/Po

	# TODO --> Add them to this list of unicodes herefater, otherwise the
	# use of Punctuations() function would lead the user to error...

	_anOtherPunctuationUnicodes	= [] # TODO: Comptete it
	_anGeneralPunctuationUnicodes   = 8192  : 8303
	_anSupplementalPunctuationCodes = 11766 : 11903

	# Merging the three lists above
	_anPunctuationUnicodes = []
	for item in _anOtherPunctuationUnicodes
		_anPunctuationUnicodes + item
	next

	for item in _anGeneralPunctuationUnicodes
		_anPunctuationUnicodes + item
	next

	for item in _anSupplementalPunctuationCodes
		_anPunctuationUnicodes + item
	next

	  #-------------------#
	 #   ARABIC STAFF    #
	#-------------------#

	# Arabic Basmalah

	_cAllahAsChar = "ﷲ"
	_cAllahAsString = "اللَّه"

	_cBasmalahAsChar = "﷽"
	_cBasmalahCharUnicode = 65021

	_cBasmalahAsString = "بِسْمِ اللَّهِ الرَّحْمَانِ الرَّحِيمِ"

	_cMuhammedAsChar = "ﷴ"
	_cMuhammedAsString = "مُحَمَّد"
	_cSalatAlaMuhammedAsChar = "ﷺ"
	_cSalatAlaMuhammedAsString = "صَلَّى اللّهُ عَلَيْهِ وَ سَلَّمَ"

	# Arabic letters
	_acArabicLetters = [ "ا","أ","ئ","ء","آ","ب","ت","ة","ث","ج","ح","خ","د","ذ","ر","ز","س","ش","ص","ض","ط","ظ","ع","غ","ف","ق","ك","ل","م","ن","و","ه","ي", "ّ" ]

	# Arabic 7arakets

	_cArabicDhammah = "ُ"		_cArabicDhammahUnicode = 1615
	_cArabicFat7ah = "َ"		_cArabicFat7ahUnicode  = 1614
	_cArabicKasrah = "ِ"		_cArabicKasrahUnicode  = 1616
	_cArabicSukoon = "ْ"		_cArabicSukoonUnicode  = 1618
	_cArabicDoubleDhammah = "ُُ"
	_ArabicDoubleFat7ah = "ََ"
	_ArabicDoubleKasrah = "ِِ"

	
	_anArabic7araketUnicodes = [
		_cArabicDhammahUnicode, _cArabicFat7ahUnicode,
		_cArabicKasrahUnicode, _cArabicSukoonUnicode
	]

	# Arabic Shaddah

	_cArabicShaddah = "ّ"
	
	# Arabic Tamdeed

	_cArabicTamdeed = "ـ" # used to extend arabic words like in حُسَيْـــــن

	# Arabic Tinween

	_anArabicTinweenUnicodes = 1611:1613

	# Arabic chars unicodes

	_anArabicBasicUnicodes = 1536 : 1791
	_anArabicSupplementUnicodes = 1872 : 1919
	_anArabicExtendedAUnicodes = 2208 : 2303
	_anArabicPresentationFormAUnicodes = 64336 : 65023
	_anArabicPresentationFormBUnicodes = 65136 : 65279
	_anArabicMathAlphabeticSymbolUnicodes = 126464 : 126719

	_anQuranicSignUnicodes = 1750 : 1773
	
	# Arabic Presentation Form unicodes

	_anArabicPresentationFormUnicodes = []

	for item in _anArabicPresentationFormAUnicodes
		_anArabicPresentationFormUnicodes + item
	next

	for item in _anArabicPresentationFormBUnicodes
		_anArabicPresentationFormUnicodes + item
	next

	# All Arabic unicodes

	_anArabicUnicodes = []

	for item in _anArabicBasicUnicodes
		_anArabicUnicodes + item
	next
	for item in _anArabicSupplementUnicodes
		_anArabicUnicodes + item
	next
	for item in _anArabicExtendedAUnicodes
		_anArabicUnicodes + item
	next
	for item in _anArabicPresentationFormAUnicodes
		_anArabicUnicodes + item
	next
	for item in _anArabicPresentationFormBUnicodes
		_anArabicUnicodes + item
	next
	for item in _anArabicMathAlphabeticSymbolUnicodes
		_anArabicUnicodes + item
	next

	# Arabic Dotless letters
	# (classic caligraphy without dots, called also Rasm script)

		# List of arabic letters without dots:
		# https://en.wikipedia.org/wiki/Rasm

		# Read about the lacking support in Unicode of
		# rasm not dotter letters for classic arabic calugraphy
		# https://unicode.org/L2/L2014/14109-inline-chars.pdf

		# Equivalent in hebrew of the arabic 7araket:
		# https://en.wikipedia.org/wiki/Niqqud

		# Equivalent in hebrew of the arabic tinkeet and shaddah :
		# https://en.wikipedia.org/wiki/Dagesh

	_anArabicDotlessUnicodes = [
		1609, 1575, 1581, 1583, 1585,
		1587, 1589, 1591, 1593, 1605,
		1607, 1608, 1646, 1647, 1697,
		1705, 1722
	]

	
	_aArabicDotlessCharsXT = [

	# TODO: Wa may need a better data structure
	# to manage some special Dotless letters
	# like ٯ in the word مٯاومه

	[ "ى" , "ى" ],
	[ "ي" , "ٮ" ],

	[ "ح" , "ح" ],
[ "خ" , "ح" ],
[ "ج" , "ح" ],

	[ "د" , "د" ],
	[ "ذ" , "د" ],

	[ "ر" , "ر" ],
	[ "ز" , "ر" ],

	[ "س" , "س" ],
	[ "ش" , "س" ],

	[ "ص" , "ص" ],
	[ "ض" , "ص" ],

	[ "ط" , "ط" ],
	[ "ظ" , "ط" ],

	[ "ک" , "ک" ],
	[ "ك" , "ک" ],

	[ "ع" , "ع" ],
	[ "غ" , "ع" ],

	[ "ٮ" , "ٮ" ],
	[ "ب" , "ٮ" ],
[ "ت" , "ٮ" ],
[ "ث" , "ٮ" ],

	[ "ٯ" ,"ٯ" ],
	[ "ق" ,"ٯ" ],
[ "ف" ,"ٯ" ],

	
[ "ں" ,"ں" ],
[ "ن" ,"ں" ],

[ "ه", "ه" ],
[ "ة", "ه" ]

]

	# Arabic Hamzahs

	_nArabicHamzahWasliahMadhmoumahUnicode = 1649
	_anArabicHamzahWasliahMaksoorahUnicode = [1575,1615]
		# You may ask: Why 2 unicodes to define just one Hamzah? Read below:
	
		/* While Unicode defines one code (1569) for the "اُ" (Hamzah Wasliah Madhmoomah),
		it does not recognize the other variant "اِ" (Hamzah Wasliah Maksoorah) that
		we find in a word like اِنفتاح.
	
		The difficulty we have here is that "اِ" is in fact two chars (Alif + Kasrah),
		while stzChar deels only with one char at a time! So, it will be impossible
		to say:
	
			StzCharQ("اِ").RemoveDiacritic() or
			StzCharQ("اِ").IsDiacritic()
		 
		because "اِ" is not a char but two chars. By contrast, StzString will do
		it correctly:
	
			StzStringQ("اِ").RemoveDiacritic()
			--> returns only Alif as a result ("ا")
	
		Because the Kasrah is recognized as a diacritic that is replaced with NULL.
	
		Clearly, there is a need to add a stzLetter class and use it to manage
		those situations where many chars collaborate in defining only one letter.
		But, for the mean time, stzString should (TODO) also be able to recognize "اِ"
		as beeign one letter:
	
			StzStringQ("اِ").IsLetter() --> TRUE
	
		and as beeing a diacritic:
	
			StzStringQ("اِ").IsDiacritic() --> TRUE
	*/

	_anArabicHamzahKat3iahUnicodes = 1571:1574 + 1569
	_anArabicHamzahWasliahUnicodes = _anArabicHamzahWasliahMaksoorahUnicode + _nArabicHamzahWasliahMadhmoumahUnicode
	
	_anArabicHamzahUnicodes = []

	for item in _anArabicHamzahKat3iahUnicodes
		_anArabicHamzahUnicodes + item
	next
	for item in _anArabicHamzahWasliahUnicodes
		_anArabicHamzahUnicodes + item
	next

	  #-------------------#
	 #   LANTIN STAFF    #
	#-------------------#

	# Latin chars unicodes

	_anLatinBasicUnicodes = 0 : 127
	_anLatin1SupplementUnicodes = 128 : 255
	_anLatinExtendedAUnicodes = 256 : 383
	_anLatinExtendedBUnicodes = 384 : 591
	_anLatinExtendedAdditionalUnicodes = 7680 : 7935
	_anLatinExtendedCUnicodes = 11360 : 11391
	_anLatinExtendedDUnicodes = 42784 : 43007
	_anLatinExtendedEUnicodes = 43824 : 43887
	
	_anLatinUnicodes = []
	
	for item in _anLatinBasicUnicodes
		_anLatinUnicodes + item
	next
	for item in _anLatin1SupplementUnicodes
		_anLatinUnicodes + item
	next
	for item in _anLatinExtendedAUnicodes
		_anLatinUnicodes + item
	next
	for item in _anLatinExtendedBUnicodes
		_anLatinUnicodes + item
	next
	for item in _anLatinExtendedAdditionalUnicodes
		_anLatinUnicodes + item
	next
	for item in _anLatinExtendedCUnicodes
		_anLatinUnicodes + item
	next
	for item in _anLatinExtendedDUnicodes
		_anLatinUnicodes + item
	next
	for item in _anLatinExtendedEUnicodes
		_anLatinUnicodes + item
	next

	# Dotless chars

	_anLatinDotlessUnicodes = [ 97, 101, 111, 117, 305, 567 ]
	# TODO: Add unicodes of uppercased "a", "e", "o", and "u"

	_aLatinDotlessLettersXT = [
		[ "ı", "ı" ],
		[ "i", "ı" ],
		[ "î", "ı" ],

		[ "ȷ", "ȷ" ],
		[ "j", "ȷ" ],

		[ "à", "a" ],
		[ "â", "a" ],

		[ "é", "e" ],
		[ "è", "e" ],
		[ "ê", "e" ],

		[ "ô", "o" ],

		[ "ù", "u" ],
		[ "û", "u"]

		# TODO: # TODO: Add unicodes of uppercased "a", "e", "o", and "u"
	]

	  #--------------------#
	 #   NUMBERS STAFF    #
	#--------------------#

	# Romans numbers
	
	_anRomanNumbersUnicodes = [
		8544, 8545, 8546, 8547, 8548, 8549, 8550,
		8551, 8552, 8553, 8560, 8561, 8562, 8563,
		8564, 8565, 8566, 8567, 8569, 8570
	]

	_acRomanNumbers = [
		"Ⅰ", "ⅰ", "Ⅱ", "ⅱ", "Ⅲ", "ⅲ", "Ⅳ", "ⅳ", "Ⅴ", "ⅴ",
		"Ⅵ", "ⅵ", "Ⅶ", "ⅶ", "Ⅷ", "ⅷ", "Ⅸ", "ⅺ", "Ⅹ", "ⅹ"
	]

	_aRomanNumbersXT = [
		["Ⅰ" , 1],	["ⅰ" , 1],	["Ⅱ" , 2], 	["ⅱ" , 2],
		["Ⅲ" , 3],	["ⅲ" , 3],	["Ⅳ" , 4],	["ⅳ" , 4],
		["Ⅴ" , 5],	["ⅴ" , 5],	["Ⅵ" , 6],	["ⅵ" , 6],

		["Ⅶ" , 7],	["ⅶ" , 7],	["Ⅷ" , 8],	["ⅷ" , 8],
		["Ⅸ" , 9],	["ⅸ" , 9],	["Ⅹ" , 10],	["ⅹ" , 10],
		["Ⅺ" , 11],	["ⅺ" , 11],	["Ⅻ" , 12],	["ⅻ" , 12],
		["Ⅼ" , 50],	["ⅼ" , 50],	["Ⅽ" , 100],	["ⅽ" , 100],
		["Ↄ" , 100],	["ↄ" , 100],	["Ⅾ" , 500],	["ⅾ" , 500],
		["Ⅿ" , 1_000],	["ⅿ" , 1_000],	["ↀ" , 1_000],	["ↁ" , 5_000],
		["ↂ" , 10_000],	["ↅ" , 6],	["ↆ" , 50],	["ↇ" , 50_000],
		["ↈ" , 100_000]	
		/*
		Just for fun:
		253 in roman is ⅭⅭⅬⅢ
		And that's how:
		253 = 100 + 100 + 50 + 3
		       Ⅽ    Ⅽ    Ⅼ  Ⅲ
		*/
	]

	# Mandarin numbers

	_anMandarinNumbersUnicodes = [
		12295, 19968, 19971, 19975, 19977,
		20061, 20108, 20116, 20843, 20845,
		21313, 21315, 22235, 30334
	]

	_acMandarinNumbers = [
		"〇", "一", "二", "三",
		"四", "五", "六", "七",
		"八", "九", "十", "百",
		"千", "万"
	]

	_aMandarinNumbersXT = [
		["〇", 0], 	["一", 1], 	["二", 2], 	["三", 3],
		["四", 4],	["五", 5],	["六", 6],	["七", 7],
		["八", 8],	["九", 9],	["十", 10],	["百", 100],
		["千", 1_000],	["万", 10_000]
		/*
		Just for fun:
		253 in mandarin is 二百五十三
		And that's how:
		253 = 2 * 100 + 5 * 10 +  3
		      二   百   五   十   三
		*/
	]
		
	# Arabic number fractions

	_anArabicNumberFractionsUnicodes = []

	for item in 188:190
		_anArabicNumberFractionsUnicodes + item
	next

	for item in 8528:8530
		_anArabicNumberFractionsUnicodes + item
	next
	for item in 8531:8532
		_anArabicNumberFractionsUnicodes + item
	next
	for item in 8533:8536
		_anArabicNumberFractionsUnicodes + item
	next
	for item in 8537:8542
		_anArabicNumberFractionsUnicodes + item
	next

	_aArabicNumberFractionsXT = [
		[ "1/4", 188 ], #--> "¼"
		[ "1/2", 189 ], #--> "½"
		[ "3/4", 190 ], #--> "¾"
	
		[ "1/7", 8528 ], #--> "⅐"	# could not be printed because of the font
		[ "1/9", 8529 ], #--> "⅑"	# idem
		[ "1/10",8530 ], #--> "⅒"
	
		[ "1/3", 8531 ], #--> "⅓"
		[ "2/3", 8532 ], #--> "⅔"
	
		[ "1/5", 8533 ], #--> "⅕"
		[ "2/5", 8534 ], #--> "⅖"
		[ "3/5", 8535 ], #--> "⅗"
		[ "4/5", 8536 ], #--> "⅘"
	
		[ "1/6", 8537 ], #--> "⅙"
		[ "5/6", 8538 ], #--> "⅚"
	
		[ "1/8", 8539 ], #--> "⅛"
	
		[ "3/8", 8540 ], #--> "⅜"
		[ "5/8", 8541 ], #--> "⅝"
		[ "7/8", 8542 ], #--> "⅞"
	
		[ "1/", 8543 ], #--> "⅟"
	
		[ "0/3", 8585 ] #--> "↉"	# idem
	]

	# Decimal chars

	_acDecimalchars = "0" : "9"

	# Binary chars

	_acBinaryChars = [ "0", "1" ]

	# Octal chars

	_acOctalChars = "0":"7"

	# Hex chars

	_acHexChars = [ "0","1", "2", "3", "4", "5", "6", "7", "8",
		       "9", "10", "11", "12", "13", "14", "15",
		       "A", "B", "C", "D", "E", "F",
		       "a", "b", "c", "d", "e", "f" ]

	  #-------------------------------------------------------#
	 #   INVERTIBLE, TURNED, CIRCLED, AND INVISIBLE CHARS    #
	#-------------------------------------------------------#

	# NOTE: Unicode distinsguishes between:
	# 	- a turned char
	# 	- an inverted char
	# 	- a reversed char
	# 	- a rotated char
	# 	- an inversed char
	# 
	#--> You can read about them here:
	#     https://unicode.org/faq/casemap_charprop.html#16
	# 
	# But this is semantically confusing! That's why Softanza
	# has a different opinion to gain clarity and peace of mind, so:
	# 
	# Rule: All these terms are equivalent : turned, inverted, reversed,
	# inverted, and reverted. And they all mean that the char is turned up
	# or down (the only two options I find them useful in the mean time).
	# 
	# Of course, this may be changed in the future, to cope with the
	# UNICODE standard and benefit from all its features. 
	

	# Invertible chars

	_anInvertibleCharsUnicodes = [
		36, 38, 40, 41, 42, 44, 45, 46, 47, 48, 50, 51, 54,
		57, 59, 60, 61, 62, 65, 69, 70, 71, 73, 75, 76, 77,
		79, 83, 84, 86, 88, 89, 92, 97, 101, 103, 104, 105,
		107, 108, 109, 109, 111, 114, 115, 116, 118, 119,
		120, 121, 123, 124, 125, 126, 164, 171, 172, 187,
		339, 397, 398, 412, 477, 581, 592, 593, 594, 603,
		613, 623, 633, 634, 636, 637, 640, 647, 652, 653,
		654, 670, 948, 953, 7432, 7433, 7444, 7450, 7491,
		7492, 7543, 7545, 8216, 8217, 8220, 8221, 8224,
		8364, 8364, 8489, 8498, 8513, 8514, 8516, 8523,
		8526, 8586, 8587, 8736, 8985, 9750, 9751, 9929,
		9930, 10075, 10076, 10077, 10078, 10658, 11039,
		11202, 11373, 11375, 11376, 11385, 11826, 11829,
		11832, 42800, 42877, 42878, 42879, 42880, 42881,
		42893, 42928, 42929, 43002, 43468, 43469, 43843,
		43856, 43857
	]

	_aInvertibleCharsXT = [
		[ "δ" , "ƍ" ], 	[ "Ɑ" , "Ɒ" ], 	[ "ɑ" , "ɒ" ], 	[ "A" , "Ɐ" ],
		[ "a" , "ɐ" ],	[ "E" , "Ǝ" ],	[ "e" , "ǝ" ],	[ "h" , "ɥ" ],
		
		[ "M" , "Ɯ" ],	[ "m" , "ɯ" ],	[ "r" , "ɹ" ],	[ "ɼ" , "ɺ" ],
		
		[ "t" , "ʇ" ],	[ "V" , "Ʌ" ],	[ "v" , "ʌ" ],	[ "w" , "ʍ" ],
		[ "y" , "ʎ" ],	[ "k" , "ʞ" ],	[ "ɛ" , "ᴈ" ],	[ "i" , "ᴉ" ],
		[ "œ" , "ᴔ" ],	[ "ʀ" , "ᴚ" ],	[ "ᵃ" , "ᵄ" ],	[ "g" , "ᵷ" ],
		[ "’" , "‘" ],	[ "“" , "”" ],	[ "ι" , "℩" ],	[ "Ⅎ" , "F" ],
	
		[ "G" , "⅁" ],	[ "L" , "⅂" ],	[ "Y" , "⅄" ],	[ "&" , "⅋" ],
		[ "ꜰ" , "ⅎ" ],	[ "2" , "↊" ], 	[ "3" , "↋" ], 	[ "¬" , "⌙" ],
		[ "☖" , "⛉" ],	[ "☗" , "⛊" ],	[ "❜" , "❛" ], [ "❞" , "❝" ],
	
		[ "∠" , "⦢" ], [ "⬟" , "⯂" ],	[ "ɽ" , "ⱹ" ], 	[ "," , "⸲" ],
		[ ";" , "⸵" ], 	[ "†" , "⸸" ], 	[ "Ᵹ" , "Ꝿ" ],	[ "ᵹ" , "ꝿ" ],
		[ "L" , "Ꞁ" ],	[ "l" , "ꞁ" ], 	[ "H" , "Ɥ" ],	[ "K" , "Ʞ" ],
		[ "T" , "Ʇ" ],	[ "m" , "ꟺ" ], 	[ "꧌" , "꧍" ],	[ "ɛ" , "ꭃ" ],
		[ "ꭐ" , "ꭑ" ], [ "X", "X" ], [ "x", "x" ], [ "I", "I" ],
		[ "H", "H" ], [ "o", "o" ], [ "O", "O" ], [ "s", "s" ], [ "S", "S" ],

		[ "0", "0" ], [ "9", "6" ],

		[ ".", "." ], [ "-", "-" ], [ "=", "=" ], [ "*", "*" ],
		[ "/", "\" ], [ "(", ")" ], [ "{", "}" ], [ "<", ">" ],
		[ "«", "»" ], [ "¤", "¤" ], [ "|", "|" ], [ "~", "~" ],
		[ "$", "$" ], [ "€", "€" ]
		
	]

	# Turned chars : TODO - Solve confusion with invertible chars!

	_anTurnableNumbersUnicodes = [2, 3]

	_anTurnedNumbersUnicodes = [ 8586, 8587 ]

	_anTurnedCharsUnicodes = [
		397,398,412,477,581,592,594,613,623,624,633,634,
		635,647,652,653,654,670,686,687,692,693,699,786,
		1376,2275,4345,6848,7353,7426,7432,7433,7444,7450,
		7455,7492,7494,7500,7502,7514,7543,7579,7587,7597,
		7610,8216,8220,8489,8498,8513,8514,8516,8523,8526,
		8586,8587,8985,9929,9930,10075,10077,8354,11202,
		11375,11376,11385,11387,11826,11829,11832,42878,
		42879,42880,42881,42893,42928,42929,43002,43469,
		43841,43842,43843,43844,43857,43864,43865,68506,
		71276,128399,128596,128597,128598,128599,128630,
		129567,129567,129568,129569,129570,129571,129572,
		129573,129574,129575,129576,129577,129578,129579,
		129580,129581,129582,129583
	]

	_aTurnableCharsXT = _aInvertibleCharsXT

	# WARNING: Makes it possilbe to check if a char is turnable
	# in uncode using the IsTurnable() function.

	# But what we do here is that we use the same data as
	# "INVERTIBLE" chars (see _aInvertibleCharsXT) above,
	# which may be different, in Unicode, then "TURNABLE"!

	# TODO: Check this and fix it accordingly
	#--> Read this to understand the problem:
	#     https://unicode.org/faq/casemap_charprop.html#16


	# Circled Chars

	_anCircledDigitUnicodes = 9312:9320 + 9450

	_anLatinCircledCapitalLetterUnicodes = 9398:9423
	_anLatinCircledSmallLetterUnicodes = 9424:9449

	_anLatinCircledLetterUnicodes = []

	for item in _anLatinCircledCapitalLetterUnicodes
		_anLatinCircledLetterUnicodes + item
	next
	for item in _anLatinCircledSmallLetterUnicodes
		_anLatinCircledLetterUnicodes + item
	next

	# Invisible chars

	_anInvisibleUnicodes = []

	for item in [ 9, 32, 173, 874 ]
		_anInvisibleUnicodes + item
	next
	for item in [ 1564 ]
		_anInvisibleUnicodes + item
	next
	for item in [ 4447, 4448]
		_anInvisibleUnicodes + item
	next
	for item in [ 6068, 6069 ]
		_anInvisibleUnicodes + item
	next
	for item in [ 6158 ]
		_anInvisibleUnicodes + item
	next
	for item in [ 8192, 8193 ]
		_anInvisibleUnicodes + item
	next
	for item in 8194 : 8207
		_anInvisibleUnicodes + item
	next
	for item in [ 8239 ]
		_anInvisibleUnicodes + item
	next
	for item in 8287 : 8282
		_anInvisibleUnicodes + item
	next
	for item in 8298 : 8303
		_anInvisibleUnicodes + item
	next
	for item in [ 12288 ]
		_anInvisibleUnicodes + item
	next
	for item in [ 10240 ]
		_anInvisibleUnicodes + item
	next
	for item in [ 12644 ]
		_anInvisibleUnicodes + item
	next
	for item in [ 65279 ]
		_anInvisibleUnicodes + item
	next
	for item in [ 65440 ]
		_anInvisibleUnicodes + item
	next
	for item in [ 119129 ]
		_anInvisibleUnicodes + item
	next
	for item in 119155:119162
		_anInvisibleUnicodes + item
	next

	# Invisible chars -- EXTENDED
	_aInvisibleCharsXT = [
	
		# Unicode > Name
	
		[ 9, :Tabulation ],
		[ 32, :Space ],
		[ 173, :SoftHyphen ],
		[ 847, :CombiningGrphemJoiner ],
		
		[ 1564, :ArabicLetterMark ],
		
		[ 4447, :HangulChoseongFiller ],
		[ 4448, :HangulJungseongFiller ],
		
		[ 6068, :KhmerVowelInherentAQ ],
		[ 6069, :KhmerVowelInherentAA ],
		
		[ 6158, :MongolianVowelSeparator ],
		
		[ 8192, :EnQuad ],
		[ 8193, :EmQuad ],
		
		[ 8194, :EnSpace ],
		[ 8195, :EmSpace ],
		[ 8196, :ThreePerEmSpace ],
		[ 8197, :FourPerEmSpace ],
		[ 8198, :SixPerEmSpace ],
		[ 8199, :FigureSpace ],
		[ 8200, :PunctuationSpace ],
		[ 8201, :ThinSpace ],
		[ 8202, :HairSpace ],
		[ 8203, :ZeroWidthSpace ],
		[ 8204, :ZeroWidthNonJoiner ],
		[ 8205, :ZeroWidthJoiner ],
		[ 8206, :LeftToRightMark ],
		[ 8207, :RightoLeftMark ],
		
		[ 8239, :NarrowNoBreakSpace ],
		
		[ 8287, :MediumMathematicalSpace ],
		[ 8288, :WordJoiner ],
		[ 8289, :FunctionApplication ],
		[ 8290, :InvisibleTimes ],
		[ 8291, :InvisibleSpearator ],
		[ 8292, :InvisiblePlus ],
		
		[ 8298, :InhibitSymmetricSwapping ],
		[ 8299, :ActivateSymmetricSwapping ],
		[ 8300, :InhibitArabicFormShaping ],
		[ 8301, :ActivateArabicFormShaping ],
		[ 8302, :NationalDigitShapes ],
		[ 8303, :NominalDigitShapes ],
		
		[ 12288, :IdeographicSpace ],

		[ 10240, :BraillePatternBlank ],

		[ 12644, :HangulFiller ],
		
		[ 65279, :ZeroWidthNoBreakSpace ],
		
		[ 65440, :HalfWidthHangulFiller ],
		
		[ 119129, :MusicalSymbolNullNotehead ],

		[ 119155, :MusicalSymbolBeginBeam ],
		[ 119156, :MusicalSymbolEndBeam ],
		[ 119157, :MusicalSymbolBeginTie ],
		[ 119158, :MusicalSymbolEndTie ],
		[ 119159, :MusicalSymbolBeginSlur ],
		[ 119160, :MusicalSymbolEndSlur ],
		[ 119161, :MusicalSymbolBeginPhrase ],
		[ 119162, :MusicalSymbolEndPhrase ]
		
	]

	  #------------------#
	 #   ICONS CHARS    #
	#------------------#

	# Icons chars TODO

	_aIconNamesAndTheirUniocdes = [
		# Complete the list
	]

	  #----------------#
	 #   WORD STAFF   #
	#----------------#

	_cHyphenShort = "-"

	_cHyphenLong = "—" # used to —delimiet a portion of text— in the sentence.

	_cUnderscore = "_" # used as a separator inside some_how_long_words

	# Word and sentence separators

	_acWordSeparators = [ " ", ".", ",", ";", ":", "!", "?", "؟", "،", "'", "’", "—"  ]
	_acSentenceSeparators = [ ".", "!", "?", "؟" ]

	# Word bounding chars

	_acWordBoundingChars = [
		[ "(", ")" ], [ "[", "]" ], [ "{", "}" ], [ "'", "'" ], [ '"', '"' ]
	]

	# Word non letter chars (TODO: Complete the list)

	_acWordNonLetterChars = []

	for item in [ "_", "-", "*", "/", "\", "+" ]
		_acWordNonLetterChars + item
	next
	for item in ArabicNumbers()
		_acWordNonLetterChars + item
	next

	/* Example of words containing those non-letter chars:
		C++
		Win32,
		ART*F,
		AS/400
	*/

	  #----------------#
	 #   DIACRITICS   #
	#----------------#

	# Latin diactritics

	_anLatinDiacriticsUnicodes = [
		192, 193, 194, 195, 196, 197, 198, 199, 
		200, 201, 202, 203, 204, 205, 206, 207, 
		208, 209, 210, 211, 212, 213, 214, 216, 
		217, 218, 219, 220, 221, 222, 223, 224, 
		225, 226, 227, 228, 229, 230, 231, 232, 
		233, 234, 235, 236, 237, 238, 239, 240, 
		241, 242, 243, 244, 245, 246, 248, 249, 
		250, 251, 252, 253, 254, 255, 256, 257, 
		258, 259, 260, 261, 262, 263, 264, 265, 
		266, 267, 268, 269, 270, 271, 272, 273, 
		274, 275, 276, 277, 278, 279, 280, 281, 
		282, 283, 284, 285, 286, 287, 288, 289, 
		290, 291, 292, 293, 294, 295, 296, 297, 
		298, 299, 300, 301, 302, 303, 304, 305, 
		306, 307, 308, 309, 310, 311, 312, 313, 
		314, 315, 316, 317, 318, 319, 320, 321, 
		322, 323, 324, 325, 326, 327, 328, 329, 
		330, 331, 332, 333, 334, 335, 336, 337, 
		338, 339, 340, 341, 342, 343, 344, 345, 
		346, 347, 348, 349, 350, 351, 352, 353, 
		354, 355, 356, 357, 358, 359, 360, 361, 
		362, 363, 364, 365, 366, 367, 368, 369, 
		370, 371, 372, 373, 374, 375, 376, 377, 
		378, 379, 380, 381, 382, 383, 7923
	]

	_aLatinDiacriticsXT = [
		[ "À", "A", "Capital A, grave accent" ],
		[ "Á", "A", "Capital A, acute accent" ],
		[ "Â", "A", "Capital A, circumflex accent" ],
		[ "Ã", "A", "Capital A, tilde" ],
		[ "Ä", "A", "Capital A, dieresis or umlaut mark" ],
		[ "Å", "A", "Capital A, ring" ],
		[ "Æ", "AE", "Capital AE diphthong" ],
		[ "Ç", "C", "Capital C, cedilla" ],
		[ "È", "E", "Capital E, grave accent" ],
		[ "É", "E", "Capital E, acute accent" ],
		[ "Ê", "E", "Capital E, circumflex accent" ],
		[ "Ë", "E", "Capital E, dieresis or umlaut mark" ],
		[ "Ì", "I", "Capital I, grave accent" ],
		[ "Í", "I", "Capital I, acute accent" ],
		[ "Î", "I", "Capital I, circumflex accent" ],
		[ "Ï", "I", "Capital I, dieresis or umlaut mark" ],
		[ "Ð", "E", "Capital Eth, Icelandic" ],
		[ "Ñ", "N", "Capital N, tilde" ],
		[ "Ò", "O", "Capital O, grave accent" ],
		[ "Ó", "O", "Capital O, acute accent" ],
		[ "Ô", "O", "Capital O, circumflex accent" ],
		[ "Õ", "O", "Capital O, tilde" ],
		[ "Ö", "O", "Capital O, dieresis or umlaut mark" ],
		[ "Ø", "O", "Capital O, slash" ],
		[ "Ù", "U", "Capital U, grave accent" ],
		[ "Ú", "U", "Capital U, acute accent" ],
		[ "Û", "U", "Capital U, circumflex accent" ],
		[ "Ü", "U", "Capital U, dieresis or umlaut mark" ],
		[ "Ý", "Y", "Capital Y, acute accent" ],
		[ "Þ", "P", "Capital thorn, Icelandic" ],
		[ "ß", "s", "Small sharp s, German" ],
		[ "à", "a", "Small a, grave accent" ],
		[ "á", "a", "Small a, acute accent" ],
		[ "â", "a", "Small a, circumflex accent" ],
		[ "ã", "a", "Small a, tilde" ],
		[ "ä", "a", "Small a, dieresis or umlaut mark" ],
		[ "å", "a", "Small a, ring" ],
		[ "æ", "ae", "Small ae diphthong" ],
		[ "ç", "c", "Small c, cedilla" ],
		[ "è", "e", "Small e, grave accent" ],
		[ "é", "e", "Small e, acute accent" ],
		[ "ê", "e", "Small e, circumflex accent" ],
		[ "ë", "e", "Small e, dieresis or umlaut mark" ],
		[ "ì", "i", "Small i, grave accent" ],
		[ "í", "i", "Small i, acute accent" ],
		[ "î", "i", "Small i, circumflex accent" ],
		[ "ï", "i", "Small i, dieresis or umlaut mark" ],
		[ "ð", "e", "Small eth, Icelandic" ],
		[ "ñ", "n", "Small n, tilde" ],
		[ "ò", "o", "Small o, grave accent" ],
		[ "ó", "o", "Small o, acute accent" ],
		[ "ô", "o", "Small o, circumflex accent" ],
		[ "õ", "o", "Small o, tilde" ],
		[ "ö", "o", "Small o, dieresis or umlaut mark" ],
		[ "ø", "o", "Small o, slash" ],
		[ "ù", "u", "Small u, grave accent" ],
		[ "ú", "u", "Small u, acute accent" ],
		[ "û", "u", "Small u, circumflex accent" ],
		[ "ü", "u", "Small u, dieresis or umlaut mark" ],
		[ "ý", "y", "Small y, acute accent" ],
		[ "þ", "p", "Small thorn, Icelandic" ],
		[ "ÿ", "y", "Small y, dieresis or umlaut mark" ],
		[ "Ā", "A", "Capital A, macron accent" ],
		[ "ā", "a", "Small a, macron accent" ],
		[ "Ă", "A", "Capital A, breve accent" ],
		[ "ă", "a", "Small a, breve accent" ],
		[ "Ą", "A", "Capital A, ogonek accent" ],
		[ "ą", "a", "Small a, ogonek accent" ],
		[ "Ć", "C", "Capital C, acute accent" ],
		[ "ć", "c", "Small c, acute accent" ],
		[ "Ĉ", "C", "Capital C, circumflex accent" ],
		[ "ĉ", "c", "Small c, circumflex accent" ],
		[ "Ċ", "C", "Capital C, dot accent" ],
		[ "ċ", "c", "Small c, dot accent" ],
		[ "Č", "C", ",Capital C, caron accent" ],
		[ "č", "c", "Small c, caron accent" ],
		[ "Ď", "D", "Capital D, caron accent" ],
		[ "ď", "d", "Small d, caron accent" ],
		[ "Đ", "D", "Capital D, with stroke accent" ],
		[ "đ", "d", "Small d, with stroke accent" ],
		[ "Ē", "E", "Capital E, macron accent" ],
		[ "ē", "e", "Small e, macron accent" ],
		[ "Ĕ", "E", "Capital E, breve accent" ],
		[ "ĕ", "e", "Small e, breve accent" ],
		[ "Ė", "E", "Capital E, dot accent" ],
		[ "ė", "e", "Small e, dot accent" ],
		[ "Ę", "E", "Capital E, ogonek accent" ],
		[ "ę", "e", "Small e, ogonek accent" ],
		[ "Ě", "E", "Capital E, caron accent" ],
		[ "ě", "e", "Small e, caron accent" ],
		[ "Ĝ", "G", "Capital G, circumflex accent" ],
		[ "ĝ", "g", "Small g, circumflex accent" ],
		[ "Ğ", "G", "Capital G, breve accent" ],
		[ "ğ", "g", "Small g, breve accent" ],
		[ "Ġ", "G", "Capital G, dot accent" ],
		[ "ġ", "g", "Small g, dot accent" ],
		[ "Ģ", "G", "Capital G, cedilla accent" ],
		[ "ģ", "g", "Small g, cedilla accent" ],
		[ "Ĥ", "H", "Capital H, circumflex accent" ],
		[ "ĥ", "h", "Small h, circumflex accent" ],
		[ "Ħ", "H", "Capital H, with stroke accent" ],
		[ "ħ", "h", "Small h, with stroke accent" ],
		[ "Ĩ", "I", "Capital I, tilde accent" ],
		[ "ĩ", "i", "Small i, tilde accent" ],
		[ "Ī", "I", "Capital I, macron accent" ],
		[ "ī", "i", "Small i, macron accent" ],
		[ "Ĭ", "I", "Capital I, breve accent" ],
		[ "ĭ", "i", "Small i, breve accent" ],
		[ "Į", "I", "Capital I, ogonek accent" ],
		[ "į", "i", "Small i, ogonek accent" ],
		[ "İ", "I", "Capital I, dot accent" ],
		[ "ı", "i", "Small dotless i" ],
		[ "Ĳ", "IJ", "Capital ligature IJ" ],
		[ "ĳ", "ij", "Small ligature ij" ],
		[ "Ĵ", "J", "Capital J, circumflex accent" ],
		[ "ĵ", "j", "Small j, circumflex accent" ],
		[ "Ķ", "K", "Capital K, cedilla accent" ],
		[ "ķ", "k", "Small k, cedilla accent" ],
		[ "ĸ", "k", "Small Kra" ],
		[ "Ĺ", "L", "Capital L, acute accent" ],
		[ "ĺ", "l", "Small l, acute accent" ],
		[ "Ļ", "L", "Capital L, cedilla accent" ],
		[ "ļ", "l", "Small l, cedilla accent" ],
		[ "Ľ", "L", "Capital L, caron accent" ],
		[ "ľ", "l", "Small L, caron accent" ],
		[ "Ŀ", "L", "Capital L, middle dot accent" ],
		[ "ŀ", "l", "Small l, middle dot accent" ],
		[ "Ł", "L", "Capital L, with stroke accent" ],
		[ "ł", "l", "Small l, with stroke accent" ],
		[ "Ń", "N", "Capital N, acute accent" ],
		[ "ń", "n", "Small n, acute accent" ],
		[ "Ņ", "N", "Capital N, cedilla accent" ],
		[ "ņ", "n", "Small n, cedilla accent" ],
		[ "Ň", "N", "Capital N, caron accent" ],
		[ "ň", "n", "Small n, caron accent" ],
		[ "ŉ", "n", "Small n, preceded by apostrophe" ],
		[ "Ŋ", "N", "Capital Eng" ],
		[ "ŋ", "n", "Small Eng" ],
		[ "Ō", "O", "Capital O, macron accent" ],
		[ "ō", "o", "Small o, macron accent" ],
		[ "Ŏ", "O", "Capital O, breve accent" ],
		[ "ŏ", "o", "Small o, breve accent" ],
		[ "Ő", "O", "Capital O, with double acute accent" ],
		[ "ő", "o", "Small O, with double acute accent" ],
		[ "Œ", "OE", "Capital Ligature OE" ],
		[ "œ", "oe", "Small Ligature oe" ],
		[ "Ŕ", "R", "Capital R, acute accent" ],
		[ "ŕ", "r", "Small r, acute accent" ],
		[ "Ŗ", "R", "Capital R, cedilla accent" ],
		[ "ŗ", "r", "Small r, cedilla accent" ],
		[ "Ř", "R", "Capital R, caron accent" ],
		[ "ř", "r", "Small r, caron accent" ],
		[ "Ś", "S", "Capital S, acute accent" ],
		[ "ś", "s", "Small s, acute accent" ],
		[ "Ŝ", "S", "Capital S, circumflex accent" ],
		[ "ŝ", "s", "Small s, circumflex accent" ],
		[ "Ş", "S", "Capital S, cedilla accent" ],
		[ "ş", "s", "Small s, cedilla accent" ],
		[ "Š", "S", "Capital S, caron accent" ],
		[ "š", "s", "Small s, caron accent" ],
		[ "Ţ", "T", "Capital T, cedilla accent" ],
		[ "ţ", "t", "Small t, cedilla accent" ],
		[ "Ť", "T", "Capital T, caron accent" ],
		[ "ť", "t", "Small t, caron accent" ],
		[ "Ŧ", "T", "Capital T, with stroke accent" ],
		[ "ŧ", "t", "Small t, with stroke accent" ],
		[ "Ũ", "U", "Capital U, tilde accent" ],
		[ "ũ", "u", "Small u, tilde accent" ],
		[ "Ū", "U", "Capital U, macron accent" ],
		[ "ū", "u", "Small u, macron accent" ],
		[ "Ŭ", "U", "Capital U, breve accent" ],
		[ "ŭ", "u", "Small u, breve accent" ],
		[ "Ů", "U", "Capital U with ring above" ],
		[ "ů", "u", "Small u with ring above" ],
		[ "Ű", "U", "Capital U, double acute accent" ],
		[ "ű", "u", "Small u, double acute accent" ],
		[ "Ų", "U", "Capital U, ogonek accent" ],
		[ "ų", "u", "Small u, ogonek accent" ],
		[ "Ŵ", "W", "Capital W, circumflex accent" ],
		[ "ŵ", "w", "Small w, circumflex accent" ],
		[ "Ŷ", "Y", "Capital Y, circumflex accent" ],
		[ "ŷ", "y", "Small y, circumflex accent" ],
		[ "Ÿ", "Y", "Capital Y, diaeresis accent" ],
		[ "Ź", "Z", "Capital Z, acute accent" ],
		[ "ź", "z", "Small z, acute accent" ],
		[ "Ż", "Z", "Capital Z, dot accent" ],
		[ "ż", "z", "Small Z, dot accent" ],
		[ "Ž", "Z", "Capital Z, caron accent" ],
		[ "ž", "z", "Small z, caron accent" ],
		[ "ſ", "s", "Small long s" ],
		[ "ỳ", "y", "Small y" ]
	]

	# Arabic diacritics

	_anArabicDiacriticsUnicodes = [
		1569, 1611, 1612, 1613, 1614, 1615,
		1616, 1617, 1618, 1648, 1649, 1570
	]
	
	_aArabicDiacriticsXT = [
	
		# Unicode > WithoutDiacritic > Description > Example of removal of diacritic
	
		[ 1571, 1569, "Arabic Hamza Kat3ia ontop of Aleef", "أ --> ء" ],
		[ 1572, 1569, "Arabic Hamza Kat3ia ontop of Waw", "ؤ --> ء" ],
		[ 1573, 1569, "Arabic Hamza Kat3ia under Aleef", "إ --> ء" ],
		[ 1574, 1569, "Arabic Hamza Kat3ia ontop of Waw", "ئ --> ء" ],
	
		[ 1611, NULL, "Arabic Tinween of Fat7ah", "عََ --> ع" ],
		[ 1612, NULL, "Arabic Tinween of Dhammah", "عُُ --> ع" ],
		[ 1613, NULL, "Arabic Tinween of Kasrah", "عِِ --> ع" ],
	
		[ 1614, NULL, "Arabic Fat7ah", "عَ --> ع" ],
		[ 1615, NULL, "Arabic Dhammah", "عُ --> ع" ],
		[ 1616, NULL, "Arabic Kasrah", "عِ --> ع" ],
		[ 1618, NULL, "Arabic Sukoon", "عْ --> ع" ],
	
		[ 1617, NULL, "Arabic Shaddah", "عّ --> ع" ],
	
		[ 1648, NULL, "Arabic small Alif Mamdoodah", "لٰكن --> لكن" ],
	
		[ 1649, 1575, "Arabic Hamzah Wasliah Madhmoomah", "ٱ --> ا" ],
		# The case of Arabic Hamzah Wasliah Maksoorah "اِ" is managed automatically
		# by the fact that these are two chars (Hamzah + Kasrah), and that
		# Kasrah is recognized as a diacritic and replaced by NULL.
	
		[ 1570, 1575, "Arabic ََAlif Mamdoodah", "آ --> ا" ]
		
	]
	
	# Greek diacritics

	_anGreekDiacriticsUnicodes = [
		// TODO
	]

	_aGreekDiacriticsXT = [
		[ "ᾳ", "&" , "Greek, aplpha" ],
		[ "εͅ", "e", "Greek, epsilon" ],
		[ "ῃ", "n", "Greek, eta" ],
		[ "ῳ", "w", "Greek, omega" ],
		[ "ιͅ", "i", "Greek, unavailable" ],
		[ "οͅ", "o", "Greek, unavailable" ],
		[ "υͅ", "u", "Greek, unavailable" ],
		[ "ὺ", "u", "Ancient Greek, Unvailable" ],
		[ "ῦ", "u", "Ancient Greek, Unvailable" ],
		[ "ὸ", "o", "Ancient Greek, Unavailable" ]
	]

	# Hebrew diacritics (TODO)

	_anHebrewDiacriticsUnicodes = [
		// TODO
	]

	_aHebrewDiacriticsXT = [
		// TODO
	]

	# Diacritics

	_anDiacriticsUnicodes = []
	for item in _anLatinDiacriticsUnicodes
		_anDiacriticsUnicodes + item
	next
	for item in _anArabicDiacriticsUnicodes
		_anDiacriticsUnicodes + item
	next
	for item in _anGreekDiacriticsUnicodes
		_anDiacriticsUnicodes + item
	next
	for item in _anHebrewDiacriticsUnicodes
		_anDiacriticsUnicodes + item
	next
	
	# Diacricized chars

	_anDiacricizedUnicodes = []

	for item in _anLatinDiacriticsUnicodes
		_anDiacricizedUnicodes + item
	next
	for item in _anGreekDiacriticsUnicodes
		_anDiacricizedUnicodes + item
	next

	# Diacricized chars -- EXTENDED

	_aDiacricizedCharsXT = []

	for item in _aLatinDiacriticsXT
		_aDiacricizedCharsXT + item
	next
	for item in _aGreekDiacriticsXT
		_aDiacricizedCharsXT + item
	next

	  #----------------------------------#
	 #  NUMBER OF LETTERS PER LANGAUGE  #
	#----------------------------------#

	_aNumberOfLettersPerLanguage = []




  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

	func WorldLanguages()
		return _aWorldLanguages

	func LanguagesInScript(cScript)	
		if NOT isString(cScipt)
			StzRaise("Incorrect param type! cScript must be a string")
		ok

		acUnicodeScriptsXT = UnicodeScriptsXT()
		nLen = len(acUnicodeScriptsXT)

		acResult = []
		for i = 1 to nLen
			if acUnicodeScriptsXT[i][2] = cScript
				acResult = ring_sort(acUnicodeScriptsXT[i][4])
				exit
			ok
		next

		return acResult

	func CommonLanguagesInScripts(pacScripts)
		if NOT isList(pacScripts) and Q(pacScripts).IsListOfStrings()
			StzRaise("Incorrect param type! pacScripts must be a list of strings.")
		ok

		nLen = len(pacScripts)
		aListOfLists = []

		for i = 1 to nLen
			aListOfLists + LanguagesInScript(pacScripts[i])
		next

		acResult = StzListOfListsQ(aListOfLists).CommonItems()
		return acResult

	func ScriptsForLanguage(pcLang)
		return StzLangaugeQ(pcLang).Scripts()

	func CommonScriptsForLanguages(pacLangs)
		if NOT isList(pacLangs) and Q(pacLangs).IsListOfStrings()
			StzRaise("Incorrect param type! pacLangs must be a list of strings.")
		ok

		nLen = len(pacLangs)
		acResult = []
		for i = 1 to nLen
			acResult + StzLanguageQ(pacLangs[i]).Script()
		next
		return acResult

	func QuranicSignUnicodes()
		return _anQuranicSignUnicodes

	func QuranicSigns()
		aResult = []
		for n in _anQuranicSignUnicodes
			oChar = new stzChar(n)
			aResult + oChar.Content()
		next
		return aResult

	func LatinLetters()
		aLetters = "a":"z"
	
		for c in "A":"Z"
			aLetters + c
		next
	
		return aLetters
	
	func ArabicLetters()
		return _acArabicLetters

	func ArabicAndLatinLetters()
		aLetters = ArabicLetters()
		for c in LatinLetters()
			aLetters + c
		next
		return aLetters

	func ArabicHamzahUnicodes()
		return _anArabicHamzahUnicodes

	func LatinAndArabicLetters()
		aLetters = LatinLetters()
		for c in ArabicLetters()
			aLetters + c
		next
		return aLetters

	func ArabicDigits()
		return "0":"9"

		def ArabicNumbers()
			return ArabicDigits()

	func IndianDigits()
		return [
			"۰", "٠",	# Be carefeul: they are different Chars!
			"۱", "١",	# Read this discussion to understand why:
			"۲", "٢",	# shorturl.at/lHK12
			"۳", "٣",
			"٤","٥","٦","٧",
			"۸", "٨",
			"۹", "٩"
			]

		def IndianNumbers()
			return IndianDigits()

		/*
		Try this code in Ring:

		# Ring code	Output		Unicodes
		? "۰" = "٠"	# FALSE		01776	01632
		? "۱" = "١"	# FALSE		01777	01633
		? "۲" = "٢"	# FALSE		01778	01634
		? "۳" = "٣"	# FALSE		01779	01635
		
		? "٤" = "٤"	# TRUE		01636	01636
		? "٥" = "٥"	# TRUE		01637	01637
		? "٦" = "٦"	# TRUE		01638	01638
		? "٧" = "٧"	# TRUE		01639	01639
		
		? "۸" = "٨"	# FALSE		01784	01640	
		? "۹" = "٩"	# FALSE		01785	01641

		The point is that Unicode assigns unique code to Chars and
		not to their visual glyfs. To give a clear example:

		"O", "Ο", and "О" seam the same for us, and for the particular
		font we use in our system to render them, but from a unicode
		stand point, they are different.

		If you try to get their unicode code points, you find them
		respectively: 79, 927, and 1054.

		In fact, the first is Latin "O", the second is Greek "Ο", and
		the third is Cyrillic "О".
		*/
		
	func ArabicAndIndianDigits()
		aDigits = ArabicDigits()
		for c in IndianDigits()
			aDigits + c
		next
		return aDigits

	func RomanNumbersUnicodes()
		return _anRomanNumbersUnicodes

	func RomanNumbers()
		return _acRomanNumbers

	func RomanNumbersAndTheirUnicodes()
		aResult = []

		for aItem in RomanNumbersXT()
			aResult + [ aItem[1], StzCharQ(aItem[1]).Unicode() ]
		next

		return aResult

	func RomanNumbersXT()
		return _aRomanNumbersXT

	func RomanToArabicNumber(pcRomanNumber)
		# Uses the data available in RomanNumbersXT()
		# TODO: In the future, make a more general algorithm
		return RomanNumbersXT()[pcRomanNumber]

	func MandarinNumbersUnicodes()
		return _anMandarinNumbersUnicodes

	func MandarinNumbers()
		return _acMandarinNumbers

	func MandarinNumbersAndTheirUnicodes()
		aResult = []

		for aItem in MandarinNumbersXT()
			aResult + [ aItem[1], StzCharQ(aItem[1]).Unicode() ]
		next

		return aResult

	func MandarinNumbersXT()
		return _aMandarinNumbersXT

	func MandarinToArabicNumber(pcMandarinNumber)
		# Uses the data available in MandarinNumbersXT()
		# TODO: In the future, make a more general algorithm
		return MandarinNumbersXT()[pcMandarinNumber]

	func ArabicNumberFractions()
		aResult = []
		for item in _aArabicNumberFractionsXT
			nUnicode = item[2]
			oChar = new stzChar(nUnicode)
			aResult + oChar.Content()
		next
		return aResult 

	func StringToArabicNumberFraction(pcArbFract)
		nUnicode = _aArabicFractions[pcArbFract]
		oChar = new stzChar(nUnicode)
		return oChar.Content()

	func ArabicNumberFractionsUnicodes()
		aResult = []
		for item in _aArabicNumberFractionsXT 
			aResult + item[2]
		next
		return aResult

		func ArabicFractionsUnicodes()
			return ArabicNumberFractionsUnicodes()

	func ArabicShaddah()
		return _cArabicShaddah
		       
	func Arabic7araket()
		return UnicodesToChars( Arabic7araketUnicodes() )

	func Arabic7araketUnicodes()
		return _anArabic7araketUnicodes

	func Underscore()
		return _cUnderscore

	func HyphenShort()
		return _cHyphenShort

	func HyphenLong()
		return _cHyphenLong
		# "—" : used to —delimiet a portion of text— in the sentence.

	func ArabicTamdeed()
		return _cArabicTamdeed = "ـ"
		# used to extend arabic words like in حُسَيْـــــن

	func StringIsNumberFraction(cStr) # of the form "1/2" or "۱/٢" or "Ⅰ/Ⅱ" or
					  # even "一/二" (in mandarin numerals)
		bResult = FALSE
		oStr = new stzString(cStr)
		if oStr.NumberOfChars() = 3
			aStzChars = oStr.ToListOfStzChars()
			if aStzChars[1].IsANumber() and
			   aStzChars[2].Content() = "/" and
			   aStzChars[3].IsANumber()

				bResult = TRUE
			ok
		ok

		return bResult

	func StringIsArabicNumberFraction(cStr) # of the form "1/2"
		bResult = FALSE
		oStr = new stzString(cStr)
		if oStr.NumberOfChars() = 3
			aStzChars = oStr.ToListOfStzChars()
			if aStzChars[1].IsArabicNumber() and
			   aStzChars[2].Content() = "/" and
			   aStzChars[3].IsArabicNumber()

				bResult = TRUE
			ok
		ok

		return bResult

	func StringIsIndianNumberFraction(cStr) # of the form "۱/٢"
		bResult = FALSE
		oStr = new stzString(cStr)
		if oStr.NumberOfChars() = 3
			aStzChars = oStr.ToListOfStzChars()
			if aStzChars[1].IsIndianNumber() and
			   aStzChars[2].Content() = "/" and
			   aStzChars[3].IsIndianNumber()

				bResult = TRUE
			ok
		ok

		return bResult

	func StringIsRomanNumberFraction(cStr) # of the form "Ⅰ/Ⅱ"
		bResult = FALSE
		oStr = new stzString(cStr)
		if oStr.NumberOfChars() = 3
			aStzChars = oStr.ToListOfStzChars()
			if aStzChars[1].IsRomanNumber() and
			   aStzChars[2].Content() = "/" and
			   aStzChars[3].IsRomanNumber()

				bResult = TRUE
			ok
		ok

		return bResult

	func StringIsMandarinNumberFraction(cStr) # of the form "一/二"
		bResult = FALSE
		oStr = new stzString(cStr)
		if oStr.NumberOfChars() = 3
			aStzChars = oStr.ToListOfStzChars()
			if aStzChars[1].IsMandarinNumber() and
			   aStzChars[2].Content() = "/" and
			   aStzChars[3].IsMandarinNumber()

				bResult = TRUE
			ok
		ok

		return bResult

	func StringToNumberFraction(cStr)
		/*
		Example : these expressions all return the char "½" (unicode 198)
			StringToNumberFractionChar("1/2") # arabic numbers
			StringToNumberFractionChar("۱/٢") # indian numbers
			StringToNumberFractionChar("Ⅰ/Ⅱ") # roman numbers
			StringToNumberFractionChar("一/二") # mandarin numbers
		*/
		if StringIsNumberFraction(cStr)
			oChar = new stzChar(cStr)
			return oChar.Content()
		else
			StzRaise(stzCharError(:CanNotTransformStringToChar))
		ok

	func TurnedDigitUnicodes()
		return [8586,8587]

	func TurnedCharsAndTheirUnicodes()
		aResult = []

		for n in TurnedCharsUnicodes()
			aResult + [ StzCharQ(n).Content(), n ]
		next

		return aResult

	func TurnedDigits()
		aResult = []
		for n in TurnedDigitUnicodes()
			oTempChar = new stzChar(n)
			aResult + oTempChar.Content()
		next
		return aResult

	func CircledCharUnicodes()
		anResult = Q( CircledDigitUnicodes() ).
				MergedWith( CircledLatinLetterUnicodes() )

		return anResult

		func CircledCharsUnicodes()
			return CircledCharUnicodes()

	func CircledChars()
		anResult = Q( CircledDigits() ).
				MergedWith( CircledLatinLetters() )

		return anResult

	func CircledDigitUnicodes()
		return _anCircledDigitUnicodes

		func CircledDigitsUnicodes()
			return CircledDigitUnicodes()

		func CircledNumberUnicodes()
			return CircledDigitUnicodes()

		func CircledNumbersUnicodes()
			return CircledDigitUnicodes()

	func CircledDigits()
		aResult = []
		for n in CircledDigitUnicodes()
			oTempChar = new stzChar(n)
			aResult + oTempChar.Content()
		next
		return aResult

		func CircledNumbers()
			return CircledDigits()

	def CircledDigitsAndUnicodes()
		oTempList = new stzList(CircledDigits())
		aResult = oTempList.AssociatedWith( CircledDigitUnicodes() )
		return aResult

	func CircledLatinLetterUnicodes()
		return _anLatinCircledLetterUnicodes 

	func CircledLatinLetters()
		aResult = []
		for n in CircledLatinLetterUnicodes()
			oTempChar = new stzChar(n)
			aResult + oTempChar.Content()
		next
		return aResult

	func CircledLatinSmallLetterUnicodes()
		return _aCircledLatinSmallLetterUnicodes

	func CircledLatinSmallLetters()
		aResult = []
		for n in CircledLatinSmallLetterUnicodes()
			oTempChar = new stzChar(n)
			aResult + oTempChar.Content()
		next
		return aResult

	func CircledLatinCapitalLetterUnicodes() # TODO: resolve the semantics lower/lowercase/small and upper/uppercase/capital
		return _aCircledLatinCapitalLetterUnicodes

	func CircledLatinCapitalLetters()
		aResult = []
		for n in _CircledLatinCapitalLetterUnicodes()
			oTempChar = new stzChar(n)
			aResult + oTempChar.Content()
		next
		return aResult

	func DecimalChars()
		return _acDecimalchars

	func BinaryChars()
		return _acBinaryChars

	func OctalChars()
		return _acOctalChars

	func HexChars()
		return _acHexChars

ici	func UnicodeScriptsXT()
		return _aUnicodeScriptsXT

	func UnicodeScripts()
		acResult = []

		for item in UnicodeScriptsXT()
			acResult + item[2]
		next

		return acResult

	func ScriptByCode(n)
		for aScriptInfo in UnicodeScripts()
			if aScriptInfo[1] = "" + n
				return aScriptInfo[2]
			ok
		next

		func UnicodeScriptByCode(n)
			return ScriptByCode(n)

	func UnicodeCategoriesXT()
		return _aUnicodeCategoriesXT

	func UnicodeCategories()
		acResult = []

		for aItem in UnicodeCategoriesXT()
			acResult + aItem[2]
		next

		return acResult

	func UnicodeDirectionsXT()
		return _aUnicodeDirectionsXT

	func UnicodeDirections()
		acResult = []

		for aItem in UnicodeDirectionsXT()
			acResult + aItem[3]
		next

		return acResult


	func WordSeparators()
		return _acWordSeparators
	
	func SentenceSeparators()
		return _acSentenceSeparators

	func WordNonLetterChars()
		return _acWordNonLetterChars

	func WordBoundingChars()
		return _acWordBoundingChars

	# Dotless letters

	func ArabicDotlessUnicodes()
		return _anArabicDotlessUnicodes

		func ArabicDotlessLettersUnicodes()
			return _anArabicDotlessUnicodes

	func ArabicDotlessLetters()
		acResult = UnicodesToChars(_anArabicDotlessUnicodes)
		return acResult
	
	func ArabicDotlessLettersXT()
		return _aArabicDotlessCharsXT

	func ArabicDotlessLettersAndTheirUnicodes()
		aResult = Association([ ArabicDotlessLetters(), ArabicDotlessUnicodes() ])
		return aResult

	func ArabicDotlessUnicodesAndTheirLetters()
		aResult = Association([ ArabicDotlessUnicodes(), ArabicDotlessLetters() ])
		return aResult

	#--

	func LatinDotlessUnicodes()
		return _anLatinDotlessUnicodes

		func LatinDotlessLettersUnicodes()
			return _anLatinDotlessUnicodes

	func LatinDotlessLetters()
		acResult = UnicodesToChars(LatinDotlessUnicodes())
		return acResult
	
	func LatinDotlessLettersXT()
		return _aLatinDotlessLettersXT

	func LatinDotlessLettersAndTheirUnicodes()
		aResult = Association([ LatinDotlessLetters(), LatinDotlessUnicodes() ])
		return aResult

	func LatinDotlessUnicodesAndTheirLetters()
		aResult = Association([ LatinDotlessUnicodes(), LatinDotlessLetters() ])
		return aResult

	#--

	func DotlessUnicodes()
		anResult = ArabicDotlessUnicodes()
		anLatin = LatinDotlessUnicodes()
		nLen = len(anLatin)

		for i = 1 to nLen
			anResult + anLatin[i]
		next

		return anResult

	func DotlessLetters()
		acResult = UnicodesToChars(DotlessUnicodes())
		return acResult

	func DotlessLettersXT()
		aResult = ArabicDotlessLettersXT()
		aLatin = LatinDotlessLettersXT()
		nLen = len(aLatin)

		for i = 1 to nLen
			aResult + aLatin[i]
		next

		return aResult

	func DotlessLettersAndTheirUnicodes()
		aResult = Association([ DotlessLetters(), DotlessUnicodes() ])
		return aResult

	func DotlessUnicodesAndTheirLetters()
		aResult = Association([ DotlessUnicodes(), DotlessLetters() ])
		return aResult

	#--

	func Dotless(pcStr)
		cResult = StzStringQ(pcStr).Dotless()
		return cResult

		func WithoutDots(pcStr)
			return Dotless(pcStr)

	# Diacritics

	func DiacriticsXT()
		aResult = []

		for item in  LatinDiacriticsXT()
			aResult + item
		next
		for item in ArabicDiacriticsXT()
			aResult + item
		next

		return aResult

	func LatinDiacriticsUnicodes()
		return _anLatinDiacriticsUnicodes

	func LatinDiacriticsXT()
		return _aLatinDiacriticsXT

	func LatinDiacritics()
		aResult = []
		for n in LatinDiacriticsUnicodes()
			aResult + StzCharQ(n).Content()
		next
		return aResult

	func ArabicDiacriticsUnicodes()
		return _anArabicDiacriticsUnicodes

	func ArabicDiacriticsXT()
		return _aArabicDiacriticsXT

	func DiacriticsUnicodes()
		return _anDiacriticsUnicodes

	func DiacricizedUnicodes()
		return _anDiacricizedUnicodes


	func DiacriticDescription(c)
		if StringIsChar(c) and StzCharQ(c).IsDiacritic()
			for item in DiacriticsXT()
				if item[1] = c
					return item[3]
				ok
			next
		ok

	func DiacriticsOfAsciiLetter(c)
		if StzCharQ(c).IsAsciiLetter()
			aResult = []
			for item in LatinDiacriticsXT()
				if item[2] = c
					aResult + item[1]
				ok
			next

			return aResult
		ok

	# Turnable numbers

	func NumberOfTurnableNumbersUnicodes()
		nResult = len(TurnableNumbersUnicodes())
		return nResult

		func HowManyTurnableNumbersUnicodes()
			return NumberOfTurnableNumbersUnicodes()

		func HowManyTurnableNumbersUnicode()
			return NumberOfTurnableNumbersUnicodes()

	func TurnableNumbersUnicodes()
		return _anTurnableNumbersUnicodes

		func ReversibleNumbersUnicodes()
			return TurnableNumbersUnicodes()

		func InvertibleNumberUnicodes()
			return TurnableNumbersUnicodes()

		func InversibleNumbersUnicodes()
			return TurnableNumbersUnicodes()
		
	func TurnableNumbersUnicodesXT()
		aResult = Association([ TurnableNumbersUnicodes(), turnableNumbers() ])

	func TurnableNumbers()
		return Unicodes(_anTurnableNumbersUnicodes)

		func ReversibleNumbers()
			return TurnableNumbers()

		func InvertibleNumbers()
			return TurnableNumbers()

		func InversibleNumbers()
			return TurnableNumbers()

	func TurnableNumbersXT()
		return Association([ TurnableNumbers(), TurnedNumbers() ])

		func ReversibleNumbersXT()
			return TurnableNumbersXT()

		func InvertibleNumbersXT()
			return TurnableNumbersXT()

		func InversibleNumbersXT()
			return TurnableNumbersXT()

	func TurnableNumbersAndTheirUnicodes()
		return Association([ TurnableNumbers(), TurnableNumbersUnicodes() ])


	# Turned numbers

	func NumberOfTurnedNumbersUnicodes()
		nResult = len(TurnedNumbersUnicodes())
		return nResult

		func HowManyTurnedNumbersUnicodes()
			return NumberOfTurnedNumbersUnicodes()

		func HowManyTurnedNumbersUnicode()
			return NumberOfTurnedNumbersUnicodes()

	func TurnedNumbersUnicodes()
		return _anTurnedNumbersUnicodes

	func TurnedNumbers()
		return UnicodesToChars( TurnedNumbersUnicodes() )

	func TurnedNumbersXT()
		aResult = Association([ TurnedNumbers(), TurnableNumbers() ])
		return aResult

	func TurnedNumbersAndTheirUnicodes()
		return Association([ TurnedNumbers(), TurnedNumbersUnicodes() ])

	#-- Turnable chars

	func NumberOfTurnableUnicodes()
		nResult = len(TurnableUnicodes())
		return nResult

		func HowManyTurnableUnicodes()
			return NumberOfTurnableUnicodes()

		func HowManyTurnableUnicode()
			return NumberOfTurnableUnicodes()

	func TurnableUnicodes()
		return _anInvertibleCharsUnicodes

		#< @FunctionAlternativeForms

		func TurnableCharsUnicodes()
			return TurnableUnicodes()

		func ReversibleUnicodes()
			return TurnableUnicodes()

		func ReversibleCharsUnicodes()
			return TurnableUnicodes()

		func InversibleUnicodes()
			return TurnableUnicodes()

		func InversibleCharsUnicodes()
			return TurnableUnicodes()

		func RevertibleUnicodes()
			return TurnableUnicodes()

		func RevertibleCharsUnicodes()
			return TurnableUnicodes()

		func InvertibleUnicodes()
			return TurnableUnicodes()

		func InvertibleCharsUnicodes()
			return TurnableUnicodes()

		#>

	func TurnableUnicodesXT()
		aResult = Association([ TurnableUnicodes(), TurnableChars() ])
		return aResult

	func NumberOfTurnableChars()
		nResult = len(TurnableChars())
		return nResult

		func HowManyTurnableChars()
			return NumberOfTurnableChars()

		func HowManyTurnableChar()
			return NumberOfTurnableChars()

	func TurnableChars()
		return UnicodesToChars( TurnableUnicodes() )

		#< @FunctionAlternativeForms

		func ReversibleChars()
			return TurnableChars()

		func InversibleChars()
			return TurnableChars()

		func RevertibleChars()
			return TurnableChars()

		func InvertibleChars()
			return TurnableChars()

		#>

	func TurnableCharsXT()
		return _aTurnableCharsXT

		#< @FunctionAlternativeForms

		func ReversibleCharsXT()
			return TurnableCharsXT()

		func InversibleCharsXT()
			return TurnableCharsXT()

		func RevertibleCharsXT()
			return TurnableCharsXT()

		func InvertibleCharsXT()
			return TurnableCharsXT()

		#>

	#-- Turnable chars

	func NumberOfTurnedUnicodes()
		nResult = len(TurnedUnicodes())
		return nResult

		func HowManyTurnedUnicodes()
			return NumberOfTurnedUnicodes()

		func HowManyTurnedUnicode()
			return NumberOfTurnedUnicodes()

	func TurnedUnicodes()
		return _anTurnedCharsUnicodes

		#< @FunctionAlternativeForms

		func TurnedCharsUnicodes()
			return TurnedUnicodes()

		func ReversedUnicodes()
			return TurnedUnicodes()

		func ReversedCharsUnicodes()
			return TurnedUnicodes()

		func InversedUnicodes()
			return TurnedUnicodes()

		func InversedCharsUnicodes()
			return TurnedUnicodes()

		func RevertedUnicodes()
			return TurnedUnicodes()

		func RevertedCharsUnicodes()
			return TurnedUnicodes()

		func InvertedUnicodes()
			return TurnedUnicodes()

		func InvertedCharsUnicodes()
			return TurnedUnicodes()

		#>

	func NumberOfTurnedChars()
		nResult = len(TurnedChars())
		return nResult

		func HowManyTurnedChars()
			return NumberOfTurnedChars()

		func HowManyTurnedChar()
			return NumberOfTurnedChars()

	func TurnedChars()
		return UnicodesToChars( TurnedUnicodes() )

		#< @FunctionAlternativeForms

		func ReversedChars()
			return TurnedChars()

		func InversedChars()
			return TurnedChars()

		func RevertedChars()
			return TurnedChars()

		func InvertedChars()
			return TurnedChars()

		#>

	func TurnedCharsXT()
		oPairs = StzListOfPairsQ(_aInvertibleCharsXT)
		aResult = Association([ oPairs.SecondItems(), oPairs.FirstItems() ])
		return aResult

		#< @FunctionAlternativeForms

		func ReversedCharsXT()
			return TurnedCharsXT()

		func InversedCharsXT()
			return TurnedCharsXT()

		func RevertedCharsXT()
			return TurnedCharsXT()

		func InvertedCharsXT()
			return TurnedCharsXT()

		#>

	# Punctuation

	func GeneralPunctuationUnicodes()
		return _anGeneralPunctuationUnicodes
	
	func GeneralPunctuationChars()
		aResult = []
	
		for n in GeneralPunctuationUnicodes()
			aResult + UnicodeToChar(n)
		next
	
		return aResult
	
		func GeneralPunctuations()
			return GeneralPunctuationChars()

	func NumberOfGeneralPunctuationChars()
		return len( GeneralPunctuationUnicodes() )

		func NumberOfGeneralPunctuations()
			return NumberOfGeneralPunctuationChars()

		func HowManyGeneralPunctuationChars()
			return NumberOfGeneralPunctuationChars()

		func HowManyGeneralPunctuationChar()
			return NumberOfGeneralPunctuationChars()

	func SupplementalPunctuationUnicodes()
		return _anSupplementalPunctuationCodes
	
	func SupplementalPunctuationChars()
		aResult = []
	
		for n in SupplementalPunctuationUnicodes()
			aResult + UnicodeToChar(n)
		next
	
		return aResult
	
		func SupplementalPunctuations()
			return SupplementalPunctuationChars()
	
	func NumberOfSupplementalPunctuationChars()
		return len( SupplementalPunctuationUnicodes() )

		func NumberOfSupplementalPunctuations()
			return NumberOfSupplementalPunctuationChars()

		func HowManyupplementalPunctuationChars()
			return NumberOfSupplementalPunctuationChars()

		func HowManyupplementalPunctuationChar()
			return NumberOfSupplementalPunctuationChars()

	func PunctuationUnicodes()
		return _anPunctuationUnicodes
	
	func PunctuationChars()	# TODO: Review its content
			  	# Some punctuations are not present (".", ",", ";"...")
				# Read the note at the beginning of this file while
				# defining the content of the _anPunctuationUniCodes
				# global variable (needs to be completed!)

		aResult = []
	
		for n in PunctuationUnicodes()
			aResult + UnicodeToChar(n)
		next
	
		return aResult
	
		func Punctuations()
			return PunctuationChars()

	func NumberOfPunctuationChars()
		return len( PunctuationUnicodes() )

		func NumberOfPunctuations()
			return NumberOfPunctuationChars()

		func HowManyPunctuationChars()
			return NumberOfPunctuationChars()

		func HowManyPunctuationChar()
			return NumberOfPunctuationChars()

		func HowManyPunctuations()
			return NumberOfPunctuationChars()

		func HowManyPunctuation()
			return NumberOfPunctuationChars()

	# Arabic staff

	func Allah()
		return AllahAsChar()

	func AllahAsChar()
		return _cAllahAsChar

	func AllahAsString()
		return _cAllahAsString

	func Basmalah()
		return BasmalahAsChar()

	func BasmalahAsChar()
		return _cBasmalahAsChar

	func BasmalahAsString()
		return _cBasmalahAsString

	func Muhammed()
		return MuhammedAsChar()

	func MuhammedAsChar()
		return _cMuhammedAsChar

	func MuhammedAsString()
		return _cMuhammedAsString

	func SalatAlaMuhammed()
		return SalatAlaMuhammedAsChar()

	func SalatAlaMuhammedAsChar()
		return _cSalatAlaMuhammedAsChar

	func SalatAlaMuhammedAsString()
		return _cSalatAlMuhammedAsString

	func ArabicDhammah()
		return _cArabicDhammah

	func ArabicFat7ah()
		return _cArabicFat7ah

	func ArabicKasrah()
		return _cArabicKasrah

	func ArabicSukoon()
		return _cArabicSukoon

	func ArabicDoubleDhammah()
		return _cArabicDoubleDhammah

	func ArabicDoubleFat7ah()
		return _ArabicDoubleFat7ah

	func ArabicDoubleKasrah()
		return _ArabicDoubleKasrah

	func InvisibleUnicodes()
		return _anInvisibleUnicodes

	func InvisibleChars()
		return UnicodesToChars( InvisibleUnicodes() )

	func NumberOfCharsInUnicode()
		return _nNumberOfCharsInUnicode

		func HowManyCharsInUnicode()
			return NumberOfCharsInUnicode()

		func HowManyCharInUnicode()
			return NumberOfCharsInUnicode()

	  #---------------------#
	 #  SOME USEFUL CHARS  #
	#---------------------#

	func Heart()
		return "♥"

		func AHeart()
			return Heart()

		func TheHeart()
			return Heart()

	func Smile()
		return "😆"

		func ASmile()
			return Smile()

		func TheSmile()
			return Smile()

	func Handshake()
		return "🤝"

		func AHandshake()
			return Handshake()

		func TheHandshake()
			return Handshake()

	func Sun()
		return "🌞"

		func ASun()
			return Sun()

		func TheSun()
			return Sun()

	func Star()
		return "★"

		func AStar()
			return Star()

		func TheStar()
			return Star()

	func CheckMark()
		return "✓"

		func ACheckMark()
			return CheckMark()

		func TheCheckMark()
			return CheckMark()

		func Tick()
			return CheckMark()

			func ATick()
				return Tick()
	
			func TheTick()
				return Tick()

	func Dot()
		return "•"

		func ADot()
			return Dot()

		func TheDot()
			return Dot()

	func Flower()
		return "❀"

		func AFlower()
			return Flower()

		func TheFlower()
			return Flower()

	func Moon()
		return "🌔"

		func AMoon()
			return Moon()

		func TheMoon()
			return Moon()
