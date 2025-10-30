
$cCurrentLanguage = "en"

$aLocaleLanguagesXT = [
	#     1		 2				3		       4		      5			     6
	#  QtNumber 	Name 			ShortAbbreviation 	LongAbbreviation 	DefaultCountry		     NativeName

	[ "1", 		:c, 			"c", 			"c", 			NULL, 				"C" 			],
	[ "2", 		:abkhazian, 		"ab", 			"abk", 			:abkhazia,			"Аҧсуа"			],

	#NOTE //that Abkhazia is not figuring in the official ISO list of countries
	[ "3", 		:oromo, 		"om", 			"orm", 			:ethiopia, 			"Afaan Oromoo" 		],
	[ "4", 		:afar, 			"aa", 			"aar", 			:ethiopia,			"Qafar af"		],
	[ "5", 		:afrikaans, 		"af", 			"afr", 			:south_africa, 			"Afrikaans" 		],
	[ "6", 		:albanian, 		"sq", 			"sqi", 			:albania, 			"Shqip" 		],
	[ "7", 		:amharic, 		"am", 			"amh", 			:ethiopia, 			"አማርኛ" 			], #WARNING// "አማርኛ" is not empty, just Ring NotePad can't display it!
	[ "8", 		:arabic, 		"ar", 			"ara", 			:egypt, 			"العربية" 		],
	[ "9", 		:armenian, 		"hy", 			"arm", 			:armenia, 			"Հայերեն" 		],
	[ "10",	 	:assamese, 		"as", 			"asm", 			:india, 			"অসমীয়া" 			],
	[ "11",	 	:aymara, 		"ay", 			"aym", 			:bolivia,  			"Aymar aru" 		],
	[ "12",	 	:azerbaijani, 		"az", 			"aze", 			:azerbaijan, 			"Azərbaycan dili" 	],
	[ "13",	 	:bashkir, 		"ba", 			"bak", 			:russia, 			"Башҡорт теле" 		],
	[ "14",	 	:basque, 		"eu", 			"eus", 			:spain, 			"Euskara" 		],
	[ "15",	 	:bengali, 		"bn", 			"ben", 			:bangladesh, 			"বাংলা" 			],
	[ "16",		:dzongkha, 		"dz", 			"dzo", 			:bhutan, 			"རྫོང་ཁ" 		],
	# "17" 	--> Bihari language --> Obsolete : no locale data available for it in Qt
	[ "18", 	:bislama, 		"bi", 			"bis", 			:vanuatu,			"Bislama" 		],
	[ "19", 	:breton, 		"br", 			"bre", 			:france, 			"Brezhoneg" 		],
	[ "20", 	:bulgarian, 		"bg", 			"bul", 			:bulgaria, 			"Български" 		],
	[ "21", 	:burmese, 		"my", 			"bur", 			:myanmar, 			"မြန်မာစာ" 		],
	[ "22", 	:belarusian, 		"be", 			"bel", 			:belarus, 			"Беларуская" 		],
	[ "23", 	:khmer, 		"km", 			"khm", 			:cambodia, 			"ភាសាខ្មែរ" 		],
	[ "24", 	:catalan, 		"ca", 			"cat", 			:spain, 			"Català" 		],
	[ "25", 	:chinese, 		"cmn", 			"cmn", 			:china, 			"官話" 			], # Mandarin Chinese
	[ "26", 	:corsican, 		"co", 			"cos", 			:france, 			"Corsu" 		],
	[ "27", 	:croatian, 		"hr", 			"hrv", 			:croatia, 			"Hrvatski" 		],
	[ "28", 	:czech, 		"cs", 			"cze", 			:czech_republic, 		"Čeština" 		],
	[ "29", 	:danish, 		"da", 			"dan", 			:denmark, 			"Dansk" 		],
	[ "30", 	:dutch, 		"nl", 			"dut", 			:netherlands, 			"Nederlands" 		],
	[ "31", 	:english, 		"en", 			"eng", 			:united_states, 		"English" 		], # LongAbbreviation corrected to "eng"
	[ "32", 	:esperanto, 		"epo", 			"epo", 			:united_kingdom,		"Esperanto" 		],
	[ "33", 	:estonian, 		"et", 			"est", 			:estonia, 			"Eesti" 		],
	[ "34", 	:faroese, 		"fo", 			"fao", 			:faroe_islands, 		"Føroyskt" 		],
	[ "35", 	:fijian, 		"fj", 			"fij", 			:fiji, 				"Na Vosa Vakaviti" 	],
	[ "36", 	:finnish, 		"fi", 			"fin", 			:finland, 			"Suomi" 		],
	[ "37", 	:french, 		"fr", 			"fra", 			:france, 			"Français" 		], # LongAbbreviation corrected to "fra"
	[ "38", 	:western_frisian, 	"fri", 			"fri", 			:netherlands, 			"Frysk" 		],
	[ "39", 	:gaelic, 		"gd", 			"gd", 			:united_kingdom, 		"Gàidhlig" 		], # Scottish Gaelic
	[ "40", 	:galician, 		"gl", 			"glg", 			:spain, 			"Galego" 		],
	[ "41", 	:georgian, 		"ka", 			"geo", 			:georgia, 			"ქართული" 		],
	[ "42", 	:german, 		"de", 			"ger", 			:germany, 			"Deutsch" 		],
	[ "43", 	:greek, 		"el", 			"gre", 			:greece, 			"Ελληνικά" 		],
	[ "44", 	:greenlandic, 		"kl", 			"kal", 			:greenland, 			"Kalaallisut" 		],
	[ "45", 	:guarani, 		"gn", 			"gug", 			:paraguay, 			"Avañe’ẽ" 		],
	[ "46", 	:gujarati, 		"gu", 			"guj", 			:india, 			"ગુજરાતી" 			],
	[ "47", 	:hausa, 		"ha", 			"hau", 			:nigeria, 			"هَوُسَ" 		],
	[ "48", 	:hebrew, 		"he", 			"heb", 			:israel, 			"עברית" 		],
	[ "49", 	:hindi, 		"hi", 			"hin", 			:india, 			"हिन्दी" 			],
	[ "50", 	:hungarian, 		"hu", 			"hun", 			:hungary, 			"Magyar" 		],
	[ "51", 	:icelandic, 		"is", 			"ice", 			:iceland, 			"Íslenska" 		],
	[ "52", 	:indonesian, 		"id", 			"ind", 			:world, 			"Bahasa Indonesia" 	],
	[ "53", 	:interlingua, 		"ia", 			"ina", 			NULL, 				"Interlingua" 		],
	[ "54", 	:interlingue, 		"ie", 			"ile", 			:norway,			"Interlingue" 		],
	[ "55", 	:inuktitut, 		"iu", 			"iku", 			:canada, 			"ᐃᓄᒃᑎᑐᑦ" 			], #WARNING// "ᐃᓄᒃᑎᑐᑦ" is not empty, just Ring NotePAd can't display it!
	[ "56", 	:inupiak, 		"ipk", 			"ipk", 			:united_states, 		"Iñupiaq" 		], # Changed country to :united_states
	[ "57", 	:irish, 		"ga", 			"gle", 			:ireland, 			"Gaeilge" 		],
	[ "58", 	:italian, 		"it", 			"ita", 			:italy, 			"Italiano" 		],
	[ "59", 	:japanese, 		"ja", 			"jpn", 			:japan, 			"日本語" 		],
	[ "60", 	:javanese, 		"jv", 			"jav", 			:indonesia, 			"Basa Jawa" 		],
	[ "61", 	:kannada, 		"kn", 			"kan", 			:india, 			"ಕನ್ನಡ" 			],
	[ "62", 	:kashmiri, 		"ks", 			"kas", 			:india, 			"کٲشُر" 			],
	[ "63", 	:kazakh, 		"kk", 			"kaz", 			:kazakhstan, 			"Қазақ тілі" 		],
	[ "64", 	:kinyarwanda, 		"rw", 			"kin", 			:rwanda, 			"Kinyarwanda" 		],
	[ "65", 	:kirghiz, 		"ky", 			"kir", 			:kyrgyzstan, 			"Кыргызча" 		],
	[ "66", 	:korean, 		"ko", 			"kor", 			:south_korea, 			"한국어" 		],
	[ "67", 	:kurdish, 		"ku", 			"kur", 			:turkey, 			"Kurdî" 		],
	[ "68", 	:rundi, 		"rn", 			"run", 			:burundi, 			"Kirundi" 		],
	[ "69", 	:lao, 			"lo", 			"lao", 			:laos, 				"ພາສາລາວ" 		],
	[ "70", 	:latin, 		"la", 			"lat", 			:italy, 			"Latine" 		],
	[ "71", 	:latvian, 		"lv", 			"lav", 			:latvia, 			"Latviešu" 		],
	[ "72", 	:lingala, 		"ln", 			"lin", 			:congo_kinshasa, 		"Lingála" 		],
	[ "73", 	:lithuanian, 		"lt", 			"lit", 			:lithuania, 			"Lietuvių" 		],
	[ "74", 	:macedonian, 		"mk", 			"mac", 			:macedonia, 			"Македонски" 		],
	[ "75", 	:malagasy, 		"mg", 			"mlg", 			:madagascar, 			"Malagasy" 		],
	[ "76", 	:malay, 		"ms", 			"may", 			:malaysia, 			"Bahasa Melayu" 	],
	[ "77", 	:malayalam, 		"ml", 			"mal", 			:india, 			"മലയാളം" 		],
	[ "78", 	:maltese, 		"mt", 			"mlt", 			:malta, 			"Malti" 		],
	[ "79", 	:maori, 		"mi", 			"mao", 			:new_zealand, 			"Māori" 		],
	[ "80", 	:marathi, 		"mr", 			"mar", 			:india, 			"मराठी" 			],
	[ "81", 	:marshallese, 		"mh", 			"mah", 			:marshall_islands, 		"Kajin M̧ajeļ" 		],
	[ "82", 	:mongolian, 		"mn",			"mon", 			:mongolia, 			"Монгол" 		],
	[ "83", 	:nauruan, 		"na", 			"nau", 			:nauru, 			"Dorerin Naoero" 	],
	[ "84", 	:nepali, 		"ne", 			"nep", 			:nepal, 			"नेपाली" 			],
	[ "85", 	:norwegian_bokmal, 	"nb", 			"nob", 			:norway, 			"Norsk bokmål" 		],
	[ "86", 	:occitan, 		"oc", 			"oci", 			:france, 			"Occitan" 		],
	[ "87", 	:oriya, 		"or", 			"ori", 			:india, 			"ଓଡ଼ିଆ" 			],
	[ "88", 	:pashto, 		"ps", 			"pus", 			:afghanistan, 			"پښتو" 			],
	[ "89", 	:persian, 		"fa", 			"per", 			:iran, 				"فارسی" 		],
	[ "90", 	:polish, 		"pl", 			"pol", 			:poland, 			"Polski" 		],
	[ "91", 	:portuguese, 		"pt", 			"por", 			:brazil, 			"Português" 		],
	[ "92", 	:punjabi, 		"pa", 			"pan", 			:india, 			"ਪੰਜਾਬੀ" 			],
	[ "93", 	:quechua, 		"qu", 			"que", 			:peru, 				"Runa Simi" 		],
	[ "94", 	:romansh, 		"rm", 			"roh", 			:switzerland, 			"Rumantsch" 		],
	[ "95", 	:romanian, 		"ro", 			"rum", 			:romania, 			"Română" 		],
	[ "96", 	:russian, 		"ru", 			"rus", 			:russia, 			"Русский" 		],
	[ "97", 	:samoan, 		"sm", 			"smo", 			:samoa, 			"Gagana Sāmoa" 		],
	[ "98", 	:sango, 		"sg", 			"sag", 			:central_african_republic, 	"Sängö" 		],
	[ "99", 	:sanskrit, 		"sa", 			"san", 			:india, 			"संस्कृतम्" 			],
	[ "100", 	:serbian, 		"sr", 			"srp", 			:serbia, 			"Српски" 		],
	[ "101", 	:ossetic, 		"os", 			"oss", 			:georgia, 			"Ирон" 			],
	[ "102", 	:southern_sotho,	"sot", 			"sot", 			:south_africa, 			"Sesotho" 		],
	[ "103", 	:tswana, 		"tn", 			"tsn", 			:south_africa, 			"Setswana" 		],
	[ "104", 	:shona, 		"sn", 			"sna", 			:zimbabwe, 			"chiShona" 		],
	[ "105", 	:sindhi, 		"sd", 			"snd", 			:pakistan, 			"سنڌي" 			],
	[ "106", 	:sinhala, 		"si", 			"sin", 			:sri_lanka, 			"සිංහල" 			],
	[ "107", 	:swati, 		"ss", 			"ssw", 			:south_africa, 			"SiSwati" 		],
	[ "108", 	:slovak, 		"sk", 			"slo", 			:slovakia, 			"Slovenčina" 		],
	[ "109", 	:slovenian, 		"sl", 			"slv", 			:slovenia, 			"Slovenščina" 		],
	[ "110", 	:somali, 		"so", 			"som", 			:somalia, 			"Soomaali" 		],
	[ "111", 	:spanish, 		"es",			"spa", 			:spain, 			"Español" 		],
	[ "112", 	:sundanese, 		"sun", 			"sun", 			:indonesia, 			"Basa Sunda" 		],
	[ "113", 	:swahili, 		"sw", 			"swa", 			:tanzania, 			"Kiswahili" 		], # called also :kiswahili
	[ "114", 	:swedish, 		"sv", 			"swe", 			:sweden, 			"Svenska" 		],
	[ "115", 	:sardinian, 		"sc", 			"srd", 			:italy, 			"Sardu" 		],
	[ "116", 	:tajik, 		"tg", 			"tgk", 			:tajikistan, 			"Тоҷикӣ" 		],
	[ "117", 	:tamil, 		"ta", 			"tam", 			:india, 			"தமிழ்" 			],
	[ "118", 	:tatar, 		"tt", 			"tat", 			:russia, 			"Татарча" 		],
	[ "119", 	:telugu, 		"te", 			"tel", 			:india, 			"తెలుగు" 		],
	[ "120", 	:thai, 			"th", 			"tha", 			:thailand, 			"ไทย" 			],
	[ "121", 	:tibetan, 		"bo", 			"tib", 			:china, 			"བོད་སྐད་" 		],
	[ "122", 	:tigrinya, 		"ti", 			"tir", 			:ethiopia, 			"ትግርኛ" 			],
	[ "123", 	:tongan, 		"to", 			"ton", 			:tonga, 			"lea faka-Tonga" 	],
	[ "124", 	:tsonga, 		"ts", 			"tso", 			:south_africa, 			"Xitsonga" 		],
	[ "125", 	:turkish, 		"tr", 			"tur", 			:turkey, 			"Türkçe" 		],
	[ "126", 	:turkmen, 		"tk", 			"tuk", 			:turkmenistan, 			"Türkmen dili" 		],
	[ "127", 	:tahitian, 		"ty", 			"tah", 			:french_polynesia, 		"Reo Tahiti" 		],
	[ "128", 	:uighur, 		"ug", 			"uig", 			:china, 			"ئۇيغۇرچە" 		],
	[ "129", 	:ukrainian, 		"uk", 			"ukr", 			:ukraine, 			"Українська" 		],
	[ "130", 	:urdu, 			"ur", 			"urd", 			:pakistan, 			"اردو" 			],
	[ "131", 	:uzbek, 		"uz", 			"uzb", 			:uzbekistan, 			"Oʻzbekcha" 		],
	[ "132", 	:vietnamese, 		"vi", 			"vie", 			:vietnam, 			"Tiếng Việt" 		],
	[ "133", 	:volapuk, 		"vo", 			"vol", 			NULL, 				"Volapük" 		],
	[ "134", 	:welsh, 		"cy", 			"wel", 			:united_kingdom, 		"Cymraeg" 		],
	[ "135", 	:wolof, 		"wo", 			"wol", 			:senegal, 			"Wolof" 		],
	[ "136", 	:xhosa, 		"xh", 			"xho", 			:south_africa, 			"isiXhosa" 		],
	[ "137", 	:yiddish, 		"yi", 			"yid", 			:bosnia_and_herzegowina, 	"ייִדיש" 		],
	[ "138", 	:yoruba, 		"yo", 			"yor", 			:nigeria, 			"Èdè Yorùbá" 		],
	[ "139", 	:zhuang, 		"za", 			"zha", 			:china, 			"Cuengh" 		],
	[ "140", 	:zulu, 			"zu", 			"zul", 			:south_africa, 			"isiZulu" 		],
	[ "141", 	:norwegian_nynorsk, 	"nn", 			"nno", 			:norway, 			"Nynorsk" 		],
	[ "142", 	:bosnian, 		"bs", 			"bos", 			:bosnia_and_herzegowina, 	"Bosanski" 		],
	[ "143", 	:divehi, 		"dv", 			"div", 			:maldives, 			"ދިވެހި" 			],
	[ "144", 	:manx, 			"gv", 			"glv", 			:isle_of_man, 			"Gaelg" 		],
	[ "145", 	:cornish, 		"kw", 			"cor", 			:united_kingdom, 		"Kernewek" 		],
	[ "146", 	:akan, 			"ak", 			"aka", 			:ghana, 			"Akan" 			],
	[ "147", 	:konkani, 		"kok", 			"kok", 			:india, 			"कोंकणी" 			],
	[ "148", 	:ga, 			"gaa", 			"gaa", 			:ghana, 			"Ga" 			],
	[ "149", 	:igbo, 			"ig", 			"ibo", 			:nigeria, 			"Asụsụ Igbo" 		],
	[ "150", 	:kamba, 		"kam", 			"kam", 			:kenya, 			"Kikamba" 		], # also :tanzania
	[ "151", 	:syriac, 		"syr", 			"syr", 			:iraq, 				"ܣܘܪܝܝܐ" 			],    #WARNING// "ብሊና" is not empty, just Ring NotePAd can't display it!
	[ "152", 	:blin, 			"byn", 			"byn", 			:sudan, 			"ብሊና" 			], #Idem
	[ "153", 	:geez, 			"gez", 			"gez", 			:eritrea, 			"ግዕዝ" 			],
	[ "154", 	:koro, 			"jkr", 			"jkr", 			:china, 			"Koro" 			],
	[ "155", 	:sidamo, 		"sid", 			"sid", 			:ethiopia, 			"Sidaamu Afo" 		],
	[ "156", 	:atsam, 		"cch", 			"cch", 			:nigeria, 			"Atsam" 		],
	[ "157", 	:tigre, 		"tig", 			"tig", 			:ethiopia, 			"ትግረ" 			], #WARNING// "ትግረ" is not empty, just Ring NotePAd can't display it!
	[ "158", 	:jju, 			"kaj", 			"kaj", 			:nigeria, 			"Jju" 			],
	[ "159", 	:friulian, 		"fur", 			"fur", 			:italy, 			"Furlan" 		],
	[ "160", 	:venda, 		"ve", 			"ven", 			:south_africa, 			"Tshivenḓa" 		],
	[ "161", 	:ewe, 			"ee", 			"ewe", 			:ghana, 			"Èʋegbe" 		],
	[ "162", 	:walamo, 		"wal", 			"wal", 			:ethiopia, 			"Wolayttatto Doonaa" 	],
	[ "163", 	:hawaiian, 		"haw", 			"haw", 			:united_states, 		"ʻŌlelo Hawaiʻi" 	], # Changed country to :united_states
	[ "164", 	:tyap, 			"kcg", 			"kcg", 			:nigeria, 			"Tyap" 			],
	[ "165", 	:nyanja, 		"ny", 			"nya", 			:malawi, 			"Chichewa" 		],
	[ "166", 	:filipino, 		"fil", 			"fil", 			:philippines, 			"Filipino" 		],
	[ "167", 	:swiss_german, 		"gsw", 			"gsw", 			:switzerland, 			"Schwiizerdütsch" 	],
	[ "168", 	:sichuan_yi, 		"iii", 			"iii", 			:china, 			"ꆈꌠ꒿" 			],
	[ "169", 	:kpelle, 		"kpe", 			"kpe", 			:liberia, 			"Kpelle" 		],
	[ "170", 	:low_german, 		"nds", 			"nds", 			:germany, 			"Plattdüütsch" 		],
	[ "171", 	:south_ndebele, 	"nbl", 			"nbl", 			:south_africa, 			"isiNdebele" 		],
	[ "172", 	:northern_sotho, 	"nso", 			"nso", 			:south_africa, 			"Sesotho sa Leboa" 	],
	[ "173", 	:northern_sami, 	"se", 			"sme", 			:norway, 			"Davvisámegiella" 	],
	[ "174", 	:taroko, 		"trv", 			"trv", 			:taiwan, 			"Truku" 		],
	[ "175", 	:gusii, 		"guz", 			"guz", 			:kenya, 			"Ekegusii" 		],
	[ "176", 	:taita, 		"dav", 			"dav", 			:kenya, 			"Kidavida" 		],
	[ "177", 	:fulah, 		"ff", 			"ful", 			:senegal,  			"Fulfulde" 		],
	[ "178", 	:kikuyu, 		"ki", 			"kik", 			:kenya, 			"Gikuyu" 		],
	[ "179", 	:samburu, 		"saq", 			"saq", 			:kenya, 			"Samburu" 		],
	[ "180", 	:sena, 			"seh", 			"seh", 			:zimbabwe, 			"Sena" 			],
	[ "181", 	:north_ndebele, 	"nd", 			"nde", 			:zimbabwe, 			"isiNdebele" 		],
	[ "182", 	:rombo, 		"rof", 			"rof", 			:tanzania,  			"Kirombo" 		],
	[ "183", 	:tachelhit, 		"shi", 			"shi", 			:morocco, 			"ⵜⴰⵛⵍⵃⵉⵜ" 		], # also called :shilha language
	[ "184", 	:kabyle, 		"kab", 			"kab", 			:algeria, 			"Taqbaylit" 		],
	[ "185", 	:nyankole, 		"nyn", 			"nyn", 			:uganda, 			"Runyankole" 		],
	[ "186", 	:bena, 			"bez", 			"bez", 			:tanzania, 			"Kibena" 		],
	[ "187", 	:vunjo, 		"vun", 			"vun", 			:tanzania, 			"Kivunjo" 		],
	[ "188", 	:bambara, 		"bm", 			"bam", 			:mali, 				"Bamanankan" 		],
	[ "189", 	:embu, 			"ebu", 			"ebu", 			:kenya, 			"Kiembu" 		],
	[ "190", 	:cherokee, 		"chr", 			"chr", 			:united_states, 		"ᏣᎳᎩ" 			], # Changed country to :united_states
	[ "191", 	:mauritian, 		"mfe", 			"mfe", 			:mauritius, 			"Kreol Morisien" 	],
	[ "192", 	:makonde, 		"kde", 			"kde", 			:tanzania, 			"Chimakonde" 		],
	[ "193", 	:langi, 		"lag", 			"lag", 			:uganda, 			"Engala" 		],
	[ "194", 	:ganda, 		"lg", 			"lug", 			:uganda, 			"Luganda" 		],
	[ "195", 	:bemba,			"bem", 			"bem", 			:zambia, 			"Ichibemba" 		],

	[ "196", 	:kabuverdianu, 		"kea", 			"kea", 			:cape_verde, 			"Kabuverdianu" 		],
	[ "197", 	:meru, 			"mer", 			"mer", 			:kenya, 			"Kimeru" 		],
	[ "198", 	:kalenjin, 		"niq", 			"niq", 			:kenya, 			"Kalenjin" 		],
	[ "199", 	:nama, 			"nmx", 			"nmx", 			:namibia, 			"Khoekhoegowab" 	],
	[ "200", 	:machame, 		"jmc", 			"jmc", 			:tanzania, 			"Kimachame" 		],
	[ "201", 	:colognian, 		"ksh", 			"ksh", 			:germany, 			"Kölsch" 		],
	[ "202", 	:masai, 		"mas", 			"mas", 			:kenya, 			"Maa" 			],
	[ "203", 	:soga, 			"xog", 			"xog", 			:uganda, 			"Lusoga" 		],
	[ "204", 	:luyia, 		"luy", 			"luy", 			:kenya, 			"Luluhya" 		],
	[ "205", 	:asu, 			"asu", 			"asu", 			:tanzania, 			"Kiasu" 		],
	[ "206", 	:teso, 			"teo", 			"teo", 			:kenya, 			"Ateso" 		],
	[ "207", 	:saho, 			"ssy", 			"ssy", 			:eritrea, 			"Saho" 			],
	[ "208", 	:koyra_chiini, 		"khq", 			"khq", 			:mali, 				"Koyra Chiini" 		],
	[ "209", 	:rwa, 			"rwk", 			"rwk", 			:tanzania,  			"Kirwa" 		],
	[ "210", 	:luo, 			"luo", 			"luo", 			:kenya, 			"Dholuo" 		],
	[ "211", 	:chiga, 		"cgg", 			"cgg", 			:uganda, 			"Rukiga"		],
	[ "212", 	:standard_morocco_tamazight, "zgh", 		"zgh", 			:morocco,			"ⵜⴰⵎⴰⵣⵉⵖⵜ" 		],

	[ "213", 	:koyraboro_senni, 	"ses", 			"ses", 			:mali, 				"Koyraboro Senni" 	],
	[ "214", 	:shambala, 		"ksb", 			"ksb", 			:tanzania, 			"Kishambala" 		],
	[ "215",	:bodo, 			"brx", 			"brx", 			:bangladesh, 			"बड़ो" 			],
	[ "216", 	:avaric, 		"av", 			"ava", 			:azerbaijan, 			"Авар мацӀ" 		],
	[ "217", 	:chamorro, 		"ch", 			"cha", 			:guam, 				"Chamoru" 		],
	[ "218", 	:chechen, 		"ce", 			"che", 			:russia, 			"Нохчийн мотт" 		],
	[ "219", 	:church, 		"cu", 			"chu", 			:italy, 			"Словѣ́ньскъ ѩзыкъ" 	],
	[ "220", 	:chuvash, 		"cv", 			"chv", 			:russia, 			"Чӑвашла" 		],
	[ "221", 	:cree, 			"cr", 			"cre", 			:canada, 			"Nēhiyawēwin" 		],
	[ "222", 	:haitian, 		"ht", 			"hat", 			:haiti, 			"Kreyòl ayisyen" 	],
	[ "223", 	:herero, 		"hz", 			"hez", 			:namibia, 			"Otjiherero" 		],
	[ "224", 	:hiri_motu, 		"ho", 			"hmo", 			:papua_new_guinea, 		"Hiri Motu" 		],
	[ "225", 	:kanuri, 		"kr", 			"kaw", 			:nigeria, 			"Kanuri" 		],
	[ "226", 	:komi, 			"kv", 			"kom", 			:russia, 			"Коми кыв" 		],
	[ "227", 	:kongo, 		"kg", 			"kon", 			:congo_kinshasa, 		"Kikongo" 		],
	[ "228", 	:kwanyama, 		"kj", 			"kua", 			:angola, 			"Oshikwanyama" 		],
	[ "229", 	:limburgish, 		"li", 			"lim", 			:netherlands, 			"Limburgs" 		],
	[ "230", 	:luba_katanga, 		"lu", 			"lub", 			:congo_kinshasa, 		"Tshiluba" 		],
	[ "231", 	:luxembourgish, 	"lb", 			"ltz", 			:luxembourg, 			"Lëtzebuergesch" 	],
	[ "232", 	:navaho, 		"nv", 			"nav", 			:united_states, 		"Diné bizaad" 		], # Changed country to :united_states
	[ "233", 	:ndonga, 		"ng", 			"ndo", 			:namibia, 			"Oshindonga" 		],

	[ "234", 	:ojibwa, 		"oj", 			"oji", 			:canada, 			"Anishinaabemowin" 	], # Corrected codes to Ojibwa (oj, oji)
	[ "235", 	:pali, 			"pi", 			"pli", 			:india, 			"पाळि" 			],
	[ "236", 	:walloon, 		"wa", 			"wln", 			:belgium, 			"Walon" 		],
	[ "237", 	:aghem, 		"agq", 			"agq", 			:cameroon, 			"Aghem" 		],
	[ "238", 	:basaa, 		"bat", 			"bat", 			:cameroon, 			"Basaá" 		],
	[ "239", 	:zarma, 		"dje", 			"dje", 			:niger, 			"Zarmaciine" 		],
	[ "240", 	:duala, 		"dua", 			"dua", 			:cameroon, 			"Duala" 		],
	[ "241", 	:jola_fonyi, 		"dyo", 			"dyo", 			:senegal, 			"Joola-Fonyi" 		],
	[ "242", 	:ewondo, 		"ewo", 			"ewo", 			:cameroon, 			"Ewondo" 		],
	[ "243", 	:bafia, 		"ksf", 			"ksf", 			:cameroon, 			"Ksf" 			],
	[ "244", 	:makhuwa_meetto, 	"vmk", 			"vmk", 			:mozambique, 			"Makhuwa-Meetto" 	],
	[ "245", 	:mundang, 		"mua", 			"mua", 			:chad, 				"Mundara" 		],
	[ "246", 	:kwasio, 		"gyi", 			"gyi", 			:cameroon, 			"Kwassio" 		],
	[ "247", 	:coptic, 		"cop", 			"cop", 			:egypt, 			"ⲧⲙⲉⲧⲣⲉⲙⲛ̀ⲭⲏⲙⲓ" 		],
	[ "248", 	:sakha, 		"sah", 			"sah", 			:russia, 			"Саха тыла" 		],
	[ "249", 	:sangu, 		"sbp", 			"sbp", 			:tanzania, 			"Ishisangu" 		], # This is Sangu for Tanzania.
						   								   	  				   # There is also Sangu for Gabon (snq)
	[ "251", 	:tasawaq, 		"twq", 			"twq", 			:niger, 			"Tasawaq" 		],
	[ "252", 	:vai, 			"vai", 			"vai", 			:liberia, 			"Vai" 			],
	[ "253", 	:walser, 		"wae", 			"wae", 			:switzerland, 			"Walser" 		],
	[ "254", 	:yangben, 		"yav", 			"yav", 			:cameroon, 			"Yangben" 		],
	[ "255", 	:avestan, 		"ae", 			"ave", 			:afghanistan, 			"Upastawakaēna" 	],
	[ "257", 	:ngomba, 		"jgo", 			"jgo", 			:cameroon, 			"Nda'a" 		],
	[ "258", 	:kako, 			"kkj", 			"kkj", 			:cameroon, 			"Kako" 			],
	[ "259", 	:meta, 			"mgo", 			"mgo", 			:cameroon, 			"Metaʼ" 		],
	[ "260", 	:ngiemboon, 		"nnh", 			"nnh", 			:cameroon, 			"Ngiemboon" 		],
	[ "261", 	:aragonese, 		"an", 			"arg", 			:spain, 			"Aragonés" 		],
	[ "262", 	:akkadian, 		"akk", 			"akk", 			:irak, 				"lišānum akkadītum" 	],
	[ "263", 	:ancient_egyptian, 	"egy", 			"egy", 			:egypt, 			"r n km.t" 		],
	[ "264", 	:ancient_greek, 	"grc", 			"grc", 			:greece, 			"Ἑλληνική" 		],
	[ "265", 	:aramaic, 		"arc", 			"arc", 			:syria, 			"ܐܪܡܝܐ" 			],
	[ "266", 	:balinese, 		"bal", 			"bal", 			:indonesia, 			"Basa Bali" 		],
	[ "267", 	:bamun, 		"bax", 			"bax", 			:cameroon, 			"Shüpamom" 		],
	[ "268", 	:batak_toba, 		"bbc", 			"bbc", 			:indonesia, 			"Batak Toba" 		],
	[ "269", 	:buginese, 		"bug", 			"bug", 			:indonesia, 			"Basa Ugi" 		],
	[ "272", 	:chakma, 		"ccp", 			"ccp", 			:bangladesh, 			"𑄌𑄋𑄴𑄟𑄳𑄦" 		],
	[ "275", 	:dogri, 		"doi", 			"doi", 			:india, 			"डोगरी" 			],

	[ "279", 	:gothic, 		"got", 			"got", 			:germany, 			"Gutisk" 		],
	[ "281", 	:ingush, 		"inh", 			"inh", 			:russia,  			"ГӀалгӀай" 		],
	[ "289", 	:mandingo, 		"mnk", 			"mnk", 			:guinea, 			"Manding" 		],
	[ "290", 	:manipuri, 		"mni", 			"mni", 			:india, 			"ꯃꯤꯇꯩ ꯂꯣꯟ" 		],
	[ "293", 	:old_irish, 		"sga", 			"sga", 			:ireland, 			"Goídelc" 		],
	[ "294", 	:old_norse, 		"non", 			"non", 			:norway, 			"Dǫnsk tunga" 		],
	[ "295", 	:old_persian, 		"peo", 			"peo", 			:iran, 				"𐎠𐎼𐎹" 			],
	[ "297", 	:pahlavi, 		"pal", 			"pal", 			:iran, 				"Pahlavi" 		],
	[ "299", 	:phoenician, 		"phn", 			"phn", 			:lebanon, 			"𐤃𐤁𐤓𐤉𐤌 𐤊𐤍𐤏𐤍𐤉𐤌" 		],
	[ "304", 	:santali, 		"sat", 			"sat", 			:india,				"ᱥᱟᱱᱛᱟᱲᱤ" 			], #WARNING// "ᱥᱟᱱᱛᱟᱲᱤ" is not empty, just Ring NotePAd can't display it!
	[ "305", 	:saurashtra, 		"saz", 			"saz", 			:india, 			"𑠰𑠙𑠾𑠷𑠬𑠙𑠴𑠡𑠯" 		],
	[ "309", 	:tai_dam, 		"blt", 			"blt", 			:vietnam, 			"ꪁꪫꪷ ꪎꪳ" 		],
	[ "310", 	:tai_nua, 		"tdd", 			"tdd", 			:china, 			"傣ᦺᦓᧈ" 			],
	[ "311", 	:ugaritic, 		"uga", 			"uga", 			:syria, 			"𐎜𐎂𐎗𐎚𐎊" 		],
	[ "312", 	:akoose, 		"bqz", 			"bqz", 			:cameroon, 			"Akoose" 		],
	[ "313", 	:lakota, 		"lkt", 			"lkt", 			:united_states, 		"Lakȟóta" 		], # Changed country to :united_states
	# Removed Row 314 (Duplicate of Row 212)
	[ "315", 	:mapuche, 		"arn", 			"arn", 			:chile, 			"Mapudungun" 		],
	[ "316", 	:central_kurdish, 	"ku", 			"kur", 			:turkey, 			"کوردیی ناوەندی" 	],
	[ "317", 	:lower_sorbian, 	"dsb", 			"dsb", 			:germany, 			"Dolnoserbski" 		],
	[ "318", 	:upper_sorbian, 	"hsb", 			"hsb", 			:germany, 			"Hornjoserbsce" 	],
	[ "319", 	:kenyang, 		"ken", 			"ken", 			:cameroon, 			"Kenyang" 		],

	[ "320", 	:mohawk, 		"moh", 			"moh", 			:canada, 			"Kanienʼkéha" 		],
	[ "321", 	:nko, 			"nqo", 			"nqo", 			:guinea, 			"ߒߞߏ" 			],
	[ "322", 	:prussian, 		"prg", 			"prg", 			:germany,			"Prūsiskan" 		],
	[ "323", 	:kiche, 		"quc", 			"quc", 			:guatemala, 			"K'iche'" 		],
	[ "324", 	:southern_sami, 	"sma", 			"sma", 			:norway, 			"Åarjelsaemien" 	],
	[ "325", 	:lule_sami, 		"smj", 			"smj", 			:norway, 			"Julevsáme" 		],
	[ "326", 	:inari_sami, 		"smn", 			"smn", 			:finland, 			"Anarâškielâ" 		],
	[ "327", 	:skolt_sami, 		"sms", 			"sms", 			:finland, 			"Sääʹmǩiõll" 		],
	[ "328", 	:warlpiri, 		"wbp", 			"wbp", 			:australia, 			"Warlpiri" 		],
	[ "330", 	:mende, 		"men", 			"men", 			:sierra_leone, 			"Mende yia" 		],
	[ "339", 	:maithili, 		"mai", 			"mai", 			:india, 			"मैथिली" 			],
	[ "341", 	:american_sign_language, "ase", 		"ase", 			:united_states, 		"ASL" 			],
	[ "343", 	:bhojpuri, 		"bho", 			"bho", 			:india, 			"भोजपुरी" 			],
	[ "345", 	:literary_chinese, 	"zh", 			"chi", 			:china, 			"文言" 			],
	[ "346", 	:mazanderani, 		"mzn", 			"mzn", 			:iran, 				"مازِرونی" 		],
	[ "348", 	:newari, 		"new", 			"new", 			:nepal, 			"नेपाल भाषा" 		],
	[ "349", 	:northern_luri,	 	"bqi", 			"bqi", 			:iran, 				"لۊری شومالی" 		],
	[ "350", 	:palauan, 		"pau", 			"pau", 			:northern_mariana_islands, 	"Tekoi er a Belau" 	],
	[ "351", 	:papiamento, 		"pap", 			"pap", 			:bonaire,  			"Papiamentu" 		],
	[ "353", 	:tokelauan, 		"tkl", 			"tkl", 			:tokelau, 			"Gagana Tokelau" 	],
	[ "354", 	:tok_pisin, 		"tpi", 			"tpi", 			:papua_new_guinea, 		"Tok Pisin" 		],
	[ "355", 	:tuvaluan, 		"tvl", 			"tvl", 			:tuvalu, 			"Te Gagana Tuvalu" 	],
	[ "357", 	:cantonese, 		"zh", 			"yue", 			:china, 			"廣州話" 		],
	[ "358", 	:osage, 		"osa", 			"osa", 			:united_states, 		"Wažaže zhe" 		], # Changed country to :united_states

	[ "360", 	:ido, 			"io", 			"ido",			:finland, 			"Ido" 			],
	[ "361", 	:lojban, 		"jbo", 			"jbo", 			NULL, 				"Lojban" 		],
	[ "362", 	:sicilian, 		"scn", 			"scn", 			:italy, 			"Sicilianu" 		],
	[ "363", 	:southern_kurdish, 	"sdh", 			"sdh", 			:iran, 				"کوردیی خوارگ" 		], # :Northern_Kurdish (kmr)
	[ "364", 	:western_balochi, 	"bgn", 			"bgn", 			:pakistan, 			"بلوچی" 		],
	[ "365", 	:cebuano, 		"ceb", 			"ceb", 			:philippines, 			"Cebuano" 		],
	[ "366", 	:erzya, 		"myv", 			"myv", 			:russia, 			"Эрзянь Кель" 		],
	[ "367", 	:chickasaw, 		"cic", 			"cic", 			:united_states, 		"Chikashshanompa’" 	], # Changed country to :united_states
	[ "368", 	:muscogee, 		"mus", 			"mus", 			:united_states, 		"Mvskoke" 		], # Changed country to :united_states
	[ "369", 	:silesian, 		"szl", 			"szl", 			:poland, 			"Ślōnskŏ gŏdka" 	]

]

func CurrentLanguage()
	return StzLanguageQ($cCurrentLanguage).Name()

func SetCurrentLanguage(cLang)
	if NOT IsLanguage(cLang)
		StzRaise("Incorrect param type! cLang must be a valid language identifier.")
	ok

	$cCurrentLanguage = StzLanguageQ(cLang).ShortAbreviation()

func DefaultLanguageForScript(cScript)
		return StzScriptQ(cScript).DefaultLangauge()

func DefaultLanguageForCountry(cCountry)
	return StzCountryQ(cCountry).DefaultLangauge()

func LocaleLanguagesXT()
	return $aLocaleLanguagesXT

	func LanguagesXT()
		return LocaleLanguagesXT()

func LocaleLanguages()
	aResult = []

	for aLangInfo in LocaleLanguagesXT()
		aResult + aLangInfo[2]
	next

	return aResult

func NumberOfLanguages()
	return len($aLocaleLanguagesXT)

	func HowManyLanguages()
		return NumberOfLanguages()

func LocaleLanguageNumbers()
	aResult = []
	for aLine in LocaleLanguagesXT()
		aResult + aLine[1]
	next
	return aResult

	func LocaleLanguageCodes()
		return LocaleLanguageNumbers()

func StzLanguageQ(pcLangIdentifier)
	return new stzLanguage(pcLangIdentifier)

class stzLanguage
	
	#NOTE// the class have a @aLanguageInfo@ attribute in PRIVATE section
	# We put it there, because we use it just for initializing the object.
	#--> it does not necesarilay contain all the information the class
	# could provide about the langauge.

	def init(pcLangIdentifier)
		oStr = new stzString(pcLangIdentifier)

		if oStr.IsLanguageCode()
			for aLangInfo in LocaleLanguagesXT()
				if lower(aLangInfo[1]) = lower(pcLangIdentifier)

					@aLanguageInfo@ = aLangInfo
					exit
				ok
			next

		but oStr.IsLanguageName()

			for aLangInfo in LocaleLanguagesXT()
				if lower(aLangInfo[2]) = lower(pcLangIdentifier)

					@aLanguageInfo@ = aLangInfo
					exit
				ok
			next

		but oStr.IsLanguageAbbreviation()
			for aLangInfo in LocaleLanguagesXT()
				if lower(aLangInfo[3]) = lower(pcLangIdentifier) or
				   lower(aLangInfo[4]) = lower(pcLangIdentifier)

					@aLanguageInfo@ = aLangInfo
					exit
				ok
			next

		but oStr.IsCountryName()

			for aLangInfo in LocaleLanguagesXT()
				if lower(aLangInfo[5]) = lower(pcLangIdentifier)

					@aLanguageInfo@ = aLangInfo
					exit
				ok
			next

		but oStr.IsLocaleAbbreviation()
			// TODO
			stzraise("Feature not yet implemented!")

		else
			StzRaise(stzLanguageError(:UnsupportedLanguageIdentifier))
		ok

	def Content()
		return @aLanguageInfo@[2]

		def Value()
			return Content()

	def QtNumber()
		return @aLanguageInfo@[1]

		def Number()
			return This.QtNumber()

	def Name()
		return @aLanguageInfo@[2]

		def Language()
			return This.Name()

		#-- @Misspelled

		def Langauge()
			return This.Name()

	def NativeName()
		return @aLanguageInfo@[6]

	def Abbreviation()
		return This.ShortAbbreviation()

	def ShortAbbreviation()
		return @aLanguageInfo@[3]

	def LongAbbreviation()
		return @aLanguageInfo@[4]

	def DefaultCountry()
		return @aLanguageInfo@[5]

		def DefaultCountryName()
			return This.DefaultCountry()

		def Country()
			return This.DefaultCountry()

		def CountryName()
			return This.DefaultCountry()

	def DefaultCountryQtNumber()
		/* We could solve it expressively like this:

		return StzCountryQ(This.DefaultCountry()).QtNumber()

		But the following is more performant...
		*/

		cCountry = This.DefaultCountry()

		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[2] = cCountry
				return aCountryInfo[1]
			ok
		next

		def DefaultCountryNumber()
			return This.DefaultCountryQtNumber()

	def DefaultCountryLocaleAbbreviation()
		return LocaleAbbreviationsXT()[ This.DefaultCountry() ][1][1][2]

		def CountryLocaleAbbreviation()
			return This.DefaultCountryLocaleAbbreviation()

	def DefaultScript()

		/* We could solve it expressively like this:

		return StzCountryQ(This.DefaultCountry()).Script()

		But the following is more performant...
		*/

		cLanguage = This.Language()

		for aScriptInfo in LocaleScriptsXT()
			if aScriptInfo[4] = cLanguage
				return aScriptInfo[2]
			ok
		next
		
		def DefaultScriptName()
			return This.DefaultScript()

		def Script()
			return This.DefaultScript()

		def ScriptName()
			return This.DefaultScript()

	def DefaultScriptQtNumber()
		/* We could solve it expressively like this:

		return StzCountryQ(This.DefaultCountry()).ScriptQtNumber()

		But the following is more performant...
		*/

		cThisLanguage = This.Language()

		for aScriptInfo in LocaleScriptsXT()
			if aScriptInfo[4] = cThisLanguage
				return aScriptInfo[1]
			ok
		next

		def DefaultScriptNumber()
			return This.DefaultScriptNumber()

	def Scripts()
		
		aResult = []

		cThisLanguage = This.Language()

		for aScriptInfo in LocaleScriptsXT()
			if aScriptInfo[4] = cThisLanguage
				aResult + lower(aScriptInfo[2])
			ok
		next

		return aResult

		def ScriptsNames()
			return This.Scripts()

	def ScriptsAbbreviations()
		aResult = []

		cThisLanguage = This.Language()

		for aScriptInfo in LocaleScriptsXT()
			if aScriptInfo[4] = cThisLanguage
				aResult + lower(aScriptInfo[3])
			ok
		next

		return aResult		

	PRIVATE

	@aLanguageInfo@
