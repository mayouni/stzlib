
/*
	TODO 1:

		In _aLocaleCountriesXT, and for the following country:
			:Caribbean_Netherlands
	
		check if it already exists under another name, or it doesn't and should be added.

	TODO 2:

		Not all items in _aLocaleCountriesXT are actually countries!

		Example --> :European_Union

		Make a list called _aWorldRegions for example and put them there...

		Also, create a list called _aContinents and link every country to its continent!

	Source of emoji flags: https://unicode.org/emoji/charts/full-emoji-list.html#country-flag

*/

_aLocaleCountriesXT = [
	#    1		   2				        3			4		    5		       6		    7						 8		  9	            10
	# QtNumber	 Name 				ShortAbbreviation 	LongAbbreviation	PhoneCode	DefaultLanguage 	Currency 				CurrencyFractionalUnit CurrencyBase,	EmojiFlag

	[ "1", 		:Afghanistan, 			"AF", 			"AFG", 			"+93", 		:persian, 		:Afghan_afghani, 			"Pul", 			100, 		"🇦🇫" 		],
	[ "2", 		:Albania, 			"AL", 			"ALB", 			"+355", 	:albanian, 		:Albanian_lek, 				"Qindarkë", 		100, 		"🇦🇱" 		],
	[ "3", 		:Algeria, 			"DZ", 			"DZA", 			"+213", 	:arabic, 		:Algerian_dinar, 			"Santeem", 		100,		"🇩🇿"		],
	[ "4", 		:American_Samoa,		"AS", 			"ASM", 			"+1-684", 	:samoan, 		:United_States_Dollar, 			"Cent", 		100,		"🇦🇸"		],
	[ "5", 		:Andorra, 			"AD", 			"AND", 			"+376", 	:catalan, 		:Euro, 					"Cent", 		100,		"🇦🇩" 		],
	[ "6", 		:Angola, 			"AO", 			"AGO", 			"+244", 	:portuguese, 		:Angolan_kwanza, 			"Cêntimo", 		100,		"🇦🇴" 		],
	[ "7", 		:Anguilla, 			"AI", 			"AIA", 			"+1264", 	:english, 		:Eastern_Caribbean_dollar, 		"Cent", 		100,		"🇦🇮" 		],
	[ "8", 		:Antarctica, 			"AQ", 			"ATA", 			"+672", 	:russian, 		:Antarctic_dollar, 			"Cent", 		100,		"🇦🇶" 		],
	[ "9", 		:Antigua_And_Barbuda, 		"AG", 			"ATG", 			"+1-268", 	"???",			:Eastern_Caribbean_dollar, 		"Cent", 		100, 		"🇦🇬" 		],
	[ "10", 	:Argentina, 			"AR", 			"ARG", 			"+54", 		:spanish, 		:Argentine_peso, 			"Centavo", 		100,		"🇦🇷"		], #TODO: check spellin :Argentine_peso or :Argentina_peso
	[ "11", 	:Armenia, 			"AM", 			"ARM", 			"+374", 	:armenian, 		:Armenian_dram, 			"Luma", 		100,		"🇦🇲" 		],
	[ "12", 	:Aruba, 			"AW", 			"ABW", 			"+297", 	:papiamento, 		:Aruban_florin, 			"Cent", 		100,		"🇦🇼"		], #TODO: Check Guilder or Florin
	[ "13", 	:Australia, 			"AU", 			"AUS", 			"+61", 		:english, 		:Australian_dollar, 			"Cent", 		100,		"🇦🇺"		],
	[ "14", 	:Austria, 			"AT", 			"AUT", 			"+43", 		:german, 		:Euro, 					"Cent", 		100,		"🇦🇹"		],
	[ "15", 	:Azerbaijan, 			"AZ", 			"AZE", 			"+994", 	:azerbaijani, 		:Azerbaijani_manat, 			"Qəpik", 		100,		"🇦🇿"		],
	[ "16", 	:Bahamas, 			"BS", 			"BHS", 			"+1-242", 	"???", 			:Bahamian_dollar, 			"Cent", 		100,		"🇧🇸"		],
	[ "17", 	:Bahrain, 			"BH", 			"BHR", 			"+973", 	:arabic, 		:Bahraini_dinar, 			"Fils", 		1000,		"🇧🇭"		],
	[ "18", 	:Bangladesh, 			"BD", 			"BGD", 			"+880", 	:bengali, 		:Bangladeshi_taka, 			"Poisha",		100,		"🇧🇩"		],
	[ "19", 	:Barbados, 			"BB", 			"BRB", 			"+1-246", 	:english, 		:Barbados_dollar, 			"Cent", 		100,		"🇧🇧"		],
	[ "20", 	:Belarus, 			"BY", 			"BLR", 			"+375", 	:russian, 		:Belarusian_ruble, 			"Kapyeyka", 		100,		"🇧🇾"		],
	[ "21", 	:Belgium, 			"BE", 			"BEL", 			"+32", 		:dutch, 		:Euro, 					"Cent", 		100,		"🇧🇪"		],
	[ "22", 	:Belize, 			"BZ", 			"BLZ", 			"+501", 	:english, 		:Belize_dollar, 			"Cent", 		100,		"🇧🇿"		], 
	[ "23", 	:Benin, 			"BJ", 			"BEN", 			"+229", 	:french, 		:West_African_CFA_franc, 		"Centime", 		100,		"🇧🇯"		],
	[ "24", 	:Bermuda, 			"BM", 			"BMU", 			"+1-441", 	:english, 		:Bermudian_dollar, 			"Cent", 		100,		"🇧🇲"		],
	[ "25", 	:Bhutan, 			"BT", 			"BTN", 			"+975", 	:dzongkha, 		:Bhutanese_ngultrum, 			"Chetrum", 		100,		"🇧🇹"		],

	[ "26", 	:Bolivia, 			"BO", 			"BOL", 			"+591", 	:spanish, 		:Bolivian_boliviano, 			"Centavo", 		100,		"🇧🇴"		],
	[ "27", 	:Bosnia_And_Herzegowina, 	"BA", 			"BIH", 			"+387", 	:bosnian, 		:Bosnia_and_Herzegovina_convertible_mark, "Fening", 		100,		"🇧🇦"		],
	[ "28", 	:Botswana, 			"BW", 			"BWA", 			"+267", 	:english, 		:Botswana_pula, 			"Thebe", 		100,		"🇧🇼"		],
	[ "29", 	:Bouvet_Island, 		"BV", 			"BVT", 			"+???", 	:norwegian,		:Norwegian_krone, 			"Øre", 			100, 		"🇧🇻"		],
	[ "30", 	:Brazil, 			"BR", 			"BRA", 			"+55", 		:portuguese, 		:Brazilian_real, 			"Centavo",		100,		"🇧🇷"		],
	[ "31", 	:British_Indian_Ocean_Territory,"IO", 			"IOT", 			"+246", 	:english, 		:United_States_dollar, 			"Cent", 		100,		"🇮🇴"		],
	[ "32", 	:Brunei, 			"BN", 			"BRN", 			"+673", 	:malay, 		:Brunei_dollar, 			"Sen", 			100,		"🇧🇳"		],
	[ "33", 	:Bulgaria, 			"BG", 			"BGR", 			"+359", 	:bulgarian,		:Bulgarian_lev, 			"Stotinka", 		100,		"🇧🇬"		],
	[ "34", 	:Burkina_Faso, 			"BF", 			"BFA", 			"+226", 	:french, 		:West_African_CFA_franc, 		"Centime", 		100, 		"🇧🇫"		],
	[ "35", 	:Burundi, 			"BI", 			"BDI", 			"+257", 	:rundi, 		:Burundian_franc, 			"Centime", 		100,		"🇧🇮"		],
	[ "36", 	:Cambodia, 			"KH", 			"KHM", 			"+855", 	:khmer, 		:Cambodian_riel,			"Sen", 			100,		"🇰🇭"		],
	[ "37", 	:Cameroon, 			"CM", 			"CMR", 			"+237", 	:english, 		:Central_African_CFA_franc, 		"Centime", 		100,		"🇨🇲"		],
	[ "38", 	:Canada, 			"CA", 			"CAN", 			"+1", 		:english, 		:Canadian_dollar, 			"Cent", 		100,		"🇨🇦"		], # Same phone code as :United_States_Of_America
	[ "39", 	:Cape_Verde, 			"CV", 			"CPV", 			"+238", 	:english, 		:Cape_Verdean_escudo, 			"Centavo", 		100,		"🇨🇻"		],
	[ "40", 	:Cayman_Islands, 		"KY", 			"CYM", 			"+1-345", 	:english, 		:Cayman_Islands_dollar, 		"Cent" , 		100,		"🇰🇾"		],
	[ "41", 	:Central_African_Republic, 	"CF", 			"CAF", 			"+236", 	:french, 		:Central_African_CFA_franc, 		"Centime", 		100,		"🇨🇫"		],
	[ "42", 	:Chad, 				"TD", 			"TCD", 			"+235", 	:french,		:Central_African_CFA_franc, 		"Centime", 		100,		"🇹🇩"		],
	[ "43", 	:Chile, 			"CL", 			"CHL", 			"+56", 		:spanish, 		:Chilean_peso, 				"Centavo", 		10,		"🇨🇱"		],
	[ "44", 	:China, 			"CN", 			"CHN", 			"+86", 		:chinese, 		:Chinese_yuan, 				"Jiao", 		10,		"🇨🇳"		], # In unicode the language is called mandarin
	[ "45", 	:Christmas_Island, 		"CX", 			"CXR", 			"+61", 		:english, 		:Australian_dollar, 			"Cent", 		100, 		"🇨🇽"		], # Same phone code as :Cocos_Islands
	[ "46", 	:Cocos_Islands, 		"CC", 			"CCK", 			"+61", 		:malay, 		:Australian_dollar, 			"Cent", 		100, 		"🇨🇨"		],
	[ "47", 	:Colombia, 			"CO", 			"COL", 			"+57", 		:spanish, 		:Colombian_peso, 			"Centavo", 		100,		"🇨🇴"		],
	[ "48", 	:Comoros, 			"KM", 			"KOM", 			"+269", 	:arabic, 		:Comorian_franc, 			"Centime", 		100,		"🇰🇲"		],
	[ "49", 	:Congo_Kinshasa, 		"CD", 			"COD", 			"+243", 	:french, 		:Congolese_franc, 			"Centime", 		100,		"🇨🇩"		], # Democratic Republic of the Congo
	[ "50", 	:Congo_Brazzaville, 		"CG",			"COG", 			"+242", 	:french, 		:Central_African_CFA_franc, 		"Centime", 		100, 		"🇨🇬"		], # Republic of the Congo

	[ "51", 	:Cook_Islands, 			"CK", 			"COK", 			"+682", 	:english, 		:Cook_Islands_dollar, 			"Cent", 		100,		"🇨🇰"		],
	[ "52", 	:Costa_Rica, 			"CR", 			"CRI", 			"+506", 	:spanish, 		:Costa_Rican_colon, 			"Céntimo", 		100,		"🇨🇷"		],
	[ "53", 	:Cote_d_ivoire, 		"CI", 			"CIV", 			"+225", 	:french, 		:West_African_CFA_franc, 		"Centime", 		100, 		"🇨🇮"		], # Ivory_Coast côte_d_ivoire
	[ "54", 	:Croatia, 			"HR", 			"HRV", 			"+385", 	:croatian, 		:Croatian_kuna, 			"Lipa", 		100, 		"🇭🇷"		],
	[ "55", 	:Cuba, 				"CU", 			"CUB", 			"+53", 		:spanish, 		:Cuban_peso , 				"Centavo", 		100,		"🇨🇺"		],
	[ "56", 	:Cyprus, 			"CY", 			"CYP", 			"+357", 	:greek, 		:Euro, 					"Cent", 		100, 		"🇨🇾"		],
	[ "57", 	:Czech_Republic, 		"CZ", 			"CZE", 			"+420", 	"greek?", 		:Czech_koruna, 				"Haléř" , 		100,		"🇨🇿" 		], # Also called Czechia
	[ "58", 	:Denmark, 			"DK", 			"DNK", 			"+45", 		:danish, 		:Danish_krone, 				"Øre", 			100, 		"🇩🇰"		],
	[ "59", 	:Djibouti, 			"DJ", 			"DJI", 			"+253", 	:french, 		:Djiboutian_franc, 			"Centime", 		100, 		"🇩🇯"		],
	[ "60", 	:Dominica, 			"DM", 			"DMA", 			"+1-767", 	:english, 		:Eastern_Caribbean_dollar, 		"Cent", 		100,		"🇩🇲"		],
	[ "61", 	:Dominican_Republic, 		"DO", 			"DOM", 			"+1-809", 	:spanish, 		:Dominican_peso, 			"Centavo" , 		100,		"🇩🇴"		], # Also +1-829 and +1-849
	[ "62", 	:Timor_Leste, 			"TL", 			"TLS", 			"+670", 	:spanish, 		:United_States_dollar, 			"Cent", 		100,		"🇹🇱"		], # Previously called :East_Timor
	[ "63", 	:Ecuador, 			"EC", 			"ECU", 			"+593", 	:spanish,		:United_States_dollar, 			"Cent", 		100,		"🇪🇨"		],
	[ "64", 	:Egypt, 			"EG", 			"EGY", 			"+20", 		:arabic, 		:Egyptian_pound, 			"Piastre", 		100,		"🇪🇬"		],
	[ "65", 	:El_Salvador, 			"SV", 			"SLV", 			"+503", 	:spanish, 		:El_Selvador_colon, 			"Cent", 		100_000_000,	"🇸🇻"		], #TODO: 100_000_000? check it!
	[ "66", 	:Equatorial_Guinea, 		"GN", 			"GNQ", 			"+240", 	:spanish, 		:Central_African_CFA_franc, 		"Centime", 		100,		"🇬🇶"		],
	[ "67", 	:Eritrea,			"ER", 			"ERI", 			"+291", 	:tigrinya,		:Eritrean_nakfa, 			"Cent" , 		100,		"🇪🇷"		],
	[ "68", 	:Estonia, 			"EE", 			"EST", 			"+372", 	:estonia, 		:Euro, 					"Cent",			100,		"🇪🇪"		], #TODO: check default language (:estonia or :estonian)
	[ "69", 	:Ethiopia, 			"ET", 			"ETH", 			"+251", 	:english, 		:Ethiopian_birr, 			"Santim", 		100,		"🇪🇹"		],
	[ "70", 	:Falkland_Islands, 		"FK", 			"FLK", 			"+500", 	:english, 		:Falkland_Islands_pound, 		"Penny", 		100,		"🇫🇰"		],
	[ "71", 	:Faroe_Islands, 		"FO", 			"FRO", 			"+298", 	:faroese, 		:Faroese_krona, 			"Oyra", 		100,	 	"🇫🇴"		],
	[ "72", 	:Fiji, 				"FJ", 			"FJI", 			"+679", 	:english, 		:Fijian_dollar , 			"Cent", 		100,		"🇫🇯"		],
	[ "73", 	:Finland, 			"FI", 			"FIN", 			"+358", 	:finnish, 		:Euro, 					"Sentti",		100,		"🇫🇮"		], #TODO: Check sentti or cent
	[ "74", 	:France, 			"FR", 			"FRA", 			"+33", 		:french, 		:Euro, 					"Cent", 		100,		"🇫🇷"		],
	[ "75", 	:Guernsey, 			"GG", 			"GGY", 			"+44-1481", 	:english, 		:Guernsey_pound, 			"Penny", 		100, 		"🇬🇬"		],

	[ "76", 	:French_Guiana, 		"GF", 			"GUF", 			"+594", 	:french, 		:Euro, 					"Cent", 		100,		"🇬🇫"		],
	[ "77", 	:French_Polynesia, 		"PF", 			"PYF", 			"+689", 	:french, 		:CFP_franc, 				"Centime", 		100, 		"🇵🇫"		],
	[ "78", 	:French_Southern_Territories,	"TF", 			"ATF", 			"+???", 	:french, 		:Euro, 					"Cent", 		100, 		"🇹🇫"		],
	[ "79", 	:Gabon, 			"GA", 			"GAB", 			"+241", 	:french, 		:Central_African_CFA_franc, 		"Centime" , 		100,		"🇬🇦"		],
	[ "80", 	:Gambia, 			"GM", 			"GMB", 			"+220", 	:french, 		:Gambian_dalasi, 			"Butut", 		100, 		"🇬🇲"		],
	[ "81", 	:Georgia, 			"GE", 			"GEO", 			"+995", 	:georgian, 		:Georgian_lari, 			"Tetri", 		100, 		"🇬🇪"		],
	[ "82", 	:Germany, 			"DE", 			"DEU", 			"+49", 		:german, 		:Euro, 					"Cent", 		100,		"🇩🇪"		],
	[ "83", 	:Ghana, 			"GH", 			"GHA", 			"+233", 	:english, 		:Ghanaian_cedi, 			"Pesewa", 		100, 		"🇬🇭"		],
	[ "84", 	:Gibraltar, 			"GI", 			"GIB", 			"+350", 	:english, 		:Gibraltar_pound, 			"Penny", 		100,		"🇬🇮"		],
	[ "85", 	:Greece, 			"GR", 			"GRC", 			"+30", 		:greek, 		:Euro, 					"Cent", 		100, 		"🇬🇷"		],
	[ "86", 	:Greenland, 			"GL", 			"GRL", 			"+299", 	:greenlandic, 		:Danish_krone, 				"Øre", 			100,  		"🇬🇱"		],
	[ "87", 	:Grenada, 			"GD", 			"GRD", 			"+1-473", 	:english, 		:Eastern_Caribbean_dollar, 		"Cent", 		100,		"🇬🇩"		],
	[ "88", 	:Guadeloupe, 			"GP", 			"GLP", 			"+590", 	:french, 		:Euro, 					"Cent", 		100,		"🇬🇵"		],
	[ "89", 	:Guam, 				"GU", 			"GUM", 			"+1-671", 	:chamorro, 		:United_States_dollar, 			"Cent", 		100,		"🇬🇺"		],
	[ "90", 	:Guatemala, 			"GT", 			"GTM", 			"+502", 	:spanish, 		:Guatemalan_quetzal, 			"Centavo", 		100,		"🇬🇹"		],
	[ "91", 	:Guinea, 			"GN", 			"GIN", 			"+224", 	:french, 		:Guinean_franc, 			"Centime", 		100,		"🇬🇳"		],
	[ "92", 	:Guinea_Bissau, 		"GW", 			"GNB", 			"+245", 	:portuguese, 		:West_African_CFA_franc, 		"Centime", 		100, 		"🇬🇼"		],
	[ "93", 	:Guyana, 			"GY", 			"GUY", 			"+592", 	:english, 		:Guyanese_dollar, 			"Cent", 		100,		"🇬🇾"		],
	[ "94", 	:Haiti, 			"HT", 			"HTI", 			"+509", 	:french, 		:Haitian_gourde, 			"Centime", 		100,		"🇭🇹"		],
	[ "95", 	:Heard_And_McDonald_Islands, 	"HM", 			"HMD", 			"+672", 	:english, 		:Australian_dollar, 			"Cent", 		100,		"🇭🇲"		], # Same phone code as :Antartica
	[ "96", 	:Honduras, 			"HN", 			"HND", 			"+504", 	:spanish, 		:Honduran_lempira, 			"Centavo", 		100,		"🇭🇳"		],
	[ "97", 	:Hong_Kong, 			"HK", 			"HKG", 			"+852", 	:english, 		:Hong_Kong_dollar, 			"Cent",			100,		"🇭🇰"		],
	[ "98", 	:Hungary, 			"HU", 			"HUN", 			"+36", 		:hungarian, 		:Hungarian_forint, 			"Fillér", 		100,		"🇭🇺"		],
	[ "99", 	:Iceland, 			"IS", 			"ISL", 			"+354", 	:icelandic, 		:Icelandic_krona, 			"Eyrir", 		100,		"🇮🇸"		],
	[ "100",	:India, 			"IN", 			"IND", 			"+91", 		:hindi, 		:Indian_rupee , 			"Paisa", 		100,		"🇮🇳"		],

	[ "101",	:Indonesia, 			"ID", 			"IDN", 			"+62", 		:indonesian, 		:Indonesian_rupiah, 			"Sen", 			100,		"🇮🇩"		],
	[ "102",	:Iran, 				"IR", 			"IRN", 			"+98", 		:persian, 		:Iranian_rial, 				"Rial", 		100,		"🇮🇷"		],
	[ "103", 	:Iraq, 				"IQ", 			"IRQ", 			"+964", 	:arabic, 		:Iraqi_dinar, 				"Fils", 		1000,		"🇮🇶"		],
	[ "104", 	:Ireland, 			"IE", 			"IRL", 			"+353", 	:english, 		:Euro, 					"Cent", 		100,		"🇮🇪"		],
	[ "105",	:Israel, 			"IL", 			"ISR", 			"+972", 	:hebrew, 		:Israeli_new_shekel, 			"Agora", 		100,		"🇮🇱"		],
	[ "106", 	:Italy, 			"IT", 			"ITA", 			"+39", 		:italian, 		:Euro,					"Cent", 		100,		"🇮🇹"		],
	[ "107", 	:Jamaica, 			"JM", 			"JAM", 			"+1-876", 	:english, 		:Jamaican_dollar, 			"Cent", 		100,		"🇯🇲"		],
	[ "108",	:Japan, 			"JP", 			"JPN", 			"+81", 		:japanese, 		:Japanese_yen, 				"Sen", 			100,		"🇯🇵"		],
	[ "109", 	:Jordan, 			"JO", 			"JOR", 			"+962", 	:arabic, 		:Jordanian_dinar, 			"Piastre", 		100,		"🇯🇴"		],
	[ "110",	:Kazakhstan, 			"KZ", 			"KAZ", 			"+7", 		:kazakh, 		:Kazakhstani_tenge, 			"Tıyn", 		100,		"🇰🇿"		],
	[ "111",	:Kenya, 			"KE", 			"KEN", 			"+254", 	:english, 		:Kenyan_shilling, 			"Cent" , 		100, 		"🇰🇪"		],
	[ "112", 	:Kiribati, 			"KI", 			"KIR", 			"+686", 	:english, 		:Kiribati_dollar, 			"Cent", 		100,		"🇰🇮"		],
	[ "113", 	:North_Korea, 			"KP", 			"PRK", 			"+850", 	:korean, 		:North_Korean_won, 			"Chon", 		100,		"🇰🇵"		],
	[ "114", 	:South_Korea, 			"KR", 			"KOR", 			"+82", 		:korean, 		:South_Korean_won, 			"Jeon", 		100,		"🇰🇷"		],
	[ "115",	:Kuwait, 			"KW", 			"KWT", 			"+965", 	:arabic, 		:Kuwaiti_dinar, 			"Fils", 		1000,		"🇰🇼"		],
	[ "116", 	:Kyrgyzstan, 			"KG", 			"KGZ", 			"+996", 	:russian, 		:Kyrgyzstani_som, 			"Tyiyn", 		100,		"🇰🇬"		],
	[ "117", 	:Laos, 				"LA", 			"LAO", 			"+856", 	:lao, 			:Lao_kip, 				"Att", 			100,		"🇱🇦"		],
	[ "118", 	:Latvia, 			"LV", 			"LVA", 			"+371", 	:latvian, 		:Euro, 					"Cent", 		100,		"🇱🇻"		],
	[ "119", 	:Lebanon, 			"LB", 			"LBN", 			"+961", 	:arabic, 		:Lebanese_pound, 			"Piastre", 		100,		"🇱🇧"		],
	[ "120", 	:Lesotho, 			"LS", 			"LSO", 			"+266", 	:english, 		:Lesotho_loti, 				"Sente" , 		100,		"🇱🇸"		],
	[ "121", 	:Liberia, 			"LR", 			"LBR", 			"+231", 	:liberia, 		:Liberian_dollar, 			"Cent", 		100,		"🇱🇷"		],
	[ "122", 	:Libya, 			"LY", 			"LBY", 			"+218", 	:arabic, 		:Libyan_dinar, 				"Dirham", 		1000,		"🇱🇾"		],
	[ "123", 	:Liechtenstein, 		"LI", 			"LIE", 			"+423", 	:german, 		:Swiss_franc, 				"Rappen", 		100, 		"🇱🇮"		],
	[ "124", 	:Lithuania, 			"LT", 			"LTU", 			"+370", 	:lithuanian, 		:Euro, 					"Cent", 		100,		"🇱🇹"		],
	[ "125", 	:Luxembourg, 			"LU", 			"LYX", 			"+352", 	:luxembourgish, 	:Euro, 					"Cent" , 		100, 		"🇱🇺"		],
	[ "126", 	:Macau, 			"MO", 			"MAC", 			"+853", 	:cantonese, 		:Macanese_pataca, 			"Avo", 			100,		"🇲🇴"		],
	[ "127", 	:Macedonia, 			"MK", 			"MKD", 			"+389", 	:macedonian, 		:Macedonian_denar, 			"Deni", 		100,		"🇲🇰"		],
	[ "128", 	:Madagascar, 			"MG", 			"MDG", 			"+261", 	:french, 		:Malagasy_ariary, 			"Iraimbilanja", 	5,		"🇲🇬"		],
	[ "129",	:Malawi, 			"MW", 			"MWI", 			"+265", 	:english, 		:Malawian_kwacha, 			"Tambala", 		100,		"🇲🇼"		],
	[ "130",	:Malaysia, 			"MY", 			"MYS", 			"+60", 		:malay, 		:Malaysian_ringgit, 			"Sen", 			100,		"🇲🇾"		],
	[ "131", 	:Maldives, 			"MV", 			"MDV", 			"+960", 	:sinhala, 		:Maldivian_rufiyaa, 			"Laari", 		100,		"🇲🇻"		],
	[ "132", 	:Mali, 				"ML", 			"MLI", 			"+223", 	:french, 		:West_African_CFA_franc, 		"Centime", 		100, 		"🇲🇱"		],
	[ "133", 	:Malta, 			"MT", 			"MLT", 			"+356", 	:maltese, 		:Euro, 					"Cent", 		100,		"🇲🇹"		],
	[ "134", 	:Marshall_Islands, 		"MH", 			"MHL", 			"+692", 	:marshallese, 		:United_States_dollar, 			"Cent", 		100,		"🇲🇭"		],
	[ "135", 	:Martinique, 			"MQ", 			"MTQ", 			"+596", 	:french, 		"???",					"???",			100,		"🇲🇶"		],
	[ "136", 	:Mauritania, 			"MR", 			"MRT", 			"+222", 	:arabic,		 :Mauritanian_ouguiya, 			"Khoums", 		5,		"🇲🇷"		],
	[ "137", 	:Mauritius, 			"MU", 			"MUS", 			"+230", 	:english,		 :Mauritian_rupee, 			"Cent", 		100, 		"🇲🇺"		],
	[ "138", 	:Mayotte, 			"YT", 			"MYT", 			"+262", 	:french, 		"???",					"???", 			100,		"🇾🇹"		],
	[ "139",	:Mexico, 			"MX", 			"MEX", 			"+52", 		:spanish, 		:Mexican_peso, 				"Centavo", 		100,		"🇲🇽"		],
	[ "140", 	:Micronesia, 			"FM", 			"FSM", 			"+691", 	:spanish, 		:United_States_dollar, 			"Cent", 		100,		"🇫🇲"		],
	[ "141", 	:Moldova, 			"MD", 			"MDA", 			"+373", 	:romanian, 		:Moldovan_leu, 				"Ban", 			100,		"🇲🇩"		],
	[ "142", 	:Monaco, 			"MC", 			"MDA", 			"+377", 	:french, 		:Euro, 					"Cent", 		100,		"🇲🇨"		],
	[ "143", 	:Mongolia, 			"MN", 			"MNG", 			"+976", 	:mongolian, 		:Mongolian_togrog, 			"Möngö", 		100,		"🇲🇳"		],
	[ "144", 	:Montserrat, 			"MS", 			"MSR", 			"+1-664", 	:english, 		:Eastern_Caribbean_dollar, 		"Cent", 		100,		"🇲🇸"		],
	[ "145", 	:Morocco, 			"MA", 			"MAR", 			"+212", 	:arabic, 		:Moroccan_dirham, 			"Centime", 		100,		"🇲🇦"		],
	[ "146", 	:Mozambique, 			"MZ", 			"MOZ", 			"+258", 	:portuguese, 		:Mozambican_metical, 			"Centavo", 		100,		"🇲🇿"		],
	[ "147", 	:Myanmar, 			"MM", 			"MMR", 			"+95", 		:portuguese, 		:Burmese_kyat, 				"Pya", 			100,		"🇲🇲"		],
	[ "148",	:Namibia, 			"NA", 			"NAM", 			"+264", 	:english, 		:Namibian_dollar, 			"Cent", 		100,		"🇳🇦"		],
	[ "149", 	:Nauru, 			"NR", 			"NRU", 			"+674", 	:nauruan, 		:Australian_dollar, 			"Cent" , 		100,		"🇳🇷"		],
	[ "150",	:Nepal, 			"NP", 			"NPL", 			"+977", 	:nepali, 		:Nepalese_rupee, 			"Paisa", 		100,		"🇳🇵"		],

	[ "151", 	:Netherlands, 			"NL", 			"NLD", 			"+31", 		:dutch, 		:Euro, 					"Cent", 		100,		"🇳🇱"		],
	[ "152", 	:Curacao, 			"CW", 			"CUW", 			"+599", 	:dutch, 		:Netherlands_Antillean_guilder, 	"Cent", 		100,		"🇨🇼"		],
	[ "153", 	:New_Caledonia,			"NC", 			"NCL", 			"+687", 	:french, 		:CFP_franc, 				"Centime", 		100,		"🇳🇨"		],
	[ "154",	:New_Zealand, 			"NZ", 			"NZL", 			"+64", 		:english, 		:New_Zealand_dollar, 			"Cent", 		100,		"🇳🇿"		],
	[ "155", 	:Nicaragua, 			"NI", 			"NIC", 			"+505", 	:spanish, 		:Nicaraguan_cordoba, 			"Centavo", 		100,		"🇳🇮"		],
	[ "156", 	:Niger, 			"NE", 			"NER",			"+227", 	:french,		:West_African_CFA_franc, 		"Centime", 		100,		"🇳🇪"		],
	[ "157", 	:Nigeria, 			"NG", 			"NGA", 			"+234", 	:english, 		:Nigerian_naira, 			"Kobo", 		100,		"🇳🇬"		],
	[ "158", 	:Niue, 				"NU", 			"NIU", 			"+683", 	:english, 		:Niue_dollar, 				"Cent", 		100,		"🇳🇺"		],
	[ "159", 	:Norfolk_Island, 		"NF", 			"NFK", 			"+672", 	:english, 		:Australian_dollar, 			"Cent", 		100,		"🇳🇫"		],
	[ "160", 	:Northern_Mariana_Islands, 	"MP", 			"MNP", 			"+1-670", 	:chamorro,		:United_States_dollar, 			"Cent", 		100,		"🇲🇵"		],
	[ "161",	:Norway, 			"NO", 			"NOR", 			"+47", 		:norwegian_bokmal, 	:Norwegian_krone, 			"Øre", 			100,		"🇳🇴"		],
	[ "162",	:Oman, 				"OM", 			"OMN", 			"+968", 	:arabic, 		:Omani_rial, 				"Baisa", 		100,		"🇴🇲"		],
	[ "163",	:Pakistan, 			"PK", 			"PAK", 			"+92", 		:punjabi, 		:Pakistani_rupee, 			"Paisa", 		100,		"🇵🇰"		],
	[ "164", 	:Palau, 			"PW", 			"PLW", 			"+680", 	:palauan, 		:United_States_dollar, 			"Cent", 		100,		"🇵🇼"		],
	[ "165", 	:Palestine, 			"PS", 			"PSE", 			"+970", 	:arabic, 		:Israeli_new_shekel, 			"Agora", 		100,		"🇵🇸"		],
	# Called in unicode :Palestinian_Territories, but for Softanza, it's Palestine!

	[ "166", 	:Panama, 			"PA", 			"PAN", 			"+507", 	:spanish, 		:Panamanian_balboa, 			"Centésimo", 		100,		"🇵🇦"		],
	[ "167", 	:Papua_New_Guinea, 		"PG", 			"PNG", 			"+675", 	:tok_pisin, 		:Papua_New_Guinean_kina, 		"Toea", 		100,		"🇵🇬"		],
	[ "168", 	:Paraguay, 			"PY", 			"PRY", 			"+595", 	:spanish, 		:Paraguayan_guarani, 			"Céntimo", 		100,		"🇵🇾"		],
	[ "169",	:Peru, 				"PE", 			"PER", 			"+51", 		:spanish, 		:Peruvian_sol, 				"Céntimo", 		100,		"🇵🇪"		],
	[ "170",	:Philippines, 			"PH", 			"PHL", 			"+63", 		:filipino, 		:Philippine_peso, 			"Sentimo", 		100,		"🇵🇭"		],
	[ "171", 	:Pitcairn, 			"PN", 			"PCN", 			"+64", 		:english, 		:Pitcairn_Islands_dollar, 		"Cent", 		100,		"🇵🇳"		],
	[ "172",	:Poland, 			"PL", 			"POL", 			"+48", 		:polish, 		:Polish_zloty, 				"Grosz", 		100,		"🇵🇱"		],
	[ "173", 	:Portugal, 			"PT", 			"PRT", 			"+351", 	:portuguese, 		:Euro, 					"Cent", 		100,		"🇵🇹"		],
	[ "174", 	:Puerto_Rico, 			"PR", 			"PRI", 			"+1-787", 	:spanish, 		:United_States_dollar, 			"Cent", 		100,		"🇵🇷"		], # also +1-939
	[ "175",	:Qatar, 			"QA", 			"QAT", 			"+974", 	:arabic, 		:Qatari_riyal, 				"Dirham", 		100,		"🇶🇦"		],

	[ "176", 	:Reunion, 			"RE", 			"REU", 			"+262", 	:french, 		:Euro, 					"Cent", 		100,		"🇷🇪"		],
	[ "177",	:Romania, 			"RO", 			"ROU", 			"+40", 		:romanian, 		:Romanian_leu, 				"Ban", 			100,		"🇷🇴"		],
	[ "178",	:Russia, 			"RU", 			"RUS", 			"+7", 		:russian, 		:Russian_ruble, 			"Kopek", 		100,		"🇷🇺"		],
	[ "179", 	:Rwanda, 			"RW", 			"RWA", 			"+250", 	:kinyarwanda, 		:Rwandan_franc, 			"Centime", 		100,		"🇷🇼"		],
	[ "180", 	:Saint_Kitts_And_Nevis, 	"KN", 			"KNA", 			"+1-869", 	:sinhala, 		:Eastern_Caribbean_dollar, 		"Cent", 		100,		"🇰🇳"		],
	[ "181", 	:Saint_Lucia, 			"LC", 			"LCA", 			"+1-758", 	:sinhala, 		:Eastern_Caribbean_dollar, 		"Cent", 		100,		"🇱🇨"		],
	[ "182",     :Saint_Vincent_And_The_Grenadines, "VC",			"VCT", 			"+1-784", 	:sinhala, 		:Eastern_Caribbean_dollar, 		"Cent", 		100,		"🇻🇨"		],
	[ "183", 	:Samoa, 			"WS", 			"WSM", 			"+685", 	:samoan, 		:Samoan_tala, 				"Sene", 		100,		"🇼🇸"		],
	[ "184", 	:San_Marino, 			"SM", 			"SMR", 			"+378", 	:italian, 		:Euro, 					"Cent", 		100,		"🇸🇲"		],
	[ "185", 	:Sao_Tome_And_Principe, 	"ST", 			"STP", 			"+239", 	:portugese, 		:Sao_Tome_and_Principe_dobra, 		"Cêntimo", 		100,		"🇸🇹"		],
	[ "186",	:Saudi_Arabia, 			"SA", 			"SAU", 			"+966", 	:arabic, 		:Saudi_riyal, 				"Halala", 		100,		"🇸🇦"		],
	[ "187", 	:Senegal, 			"SN", 			"SEN", 			"+221", 	:french, 		:West_African_CFA_franc, 		"Centime", 		100,		"🇸🇳"		],
	[ "188",	:Seychelles, 			"SC", 			"SYC", 			"+248", 	:english, 		:Seychellois_rupee, 			"Cent", 		100,		"🇸🇨"		],
	[ "189", 	:Sierra_Leone, 			"SL", 			"SLE", 			"+232", 	:english, 		:Sierra_Leonean_leone, 			"Cent", 		100,		"🇸🇱"		],
	[ "190",	:Singapore, 			"SG", 			"SGP", 			"+65", 		:malay, 		:Singapore_dollar, 			"Cent", 		100,		"🇸🇬"		],
	[ "191", 	:Slovakia, 			"SK", 			"SVK", 			"+421", 	:slovak, 		:Euro, 					"Cent", 		100,		"🇸🇰"		],
	[ "192", 	:Slovenia, 			"SI", 			"SVN", 			"+386", 	:slovenian, 		:Euro, 					"Cent", 		100,		"🇸🇮"		],
	[ "193",	:Solomon_Islands, 		"SB", 			"SLB", 			"+677", 	:english, 		:Solomon_Islands_dollar, 		"Cent", 		100,		"🇸🇧"		],
	[ "194",	:Somalia, 			"SO", 			"SOM", 			"+252", 	:somali, 		:Somali_shilling, 			"Cent" , 		100,		"🇸🇴"		],
	[ "195",	:South_Africa, 			"ZA", 			"ZAF", 			"+27", 		:zulu, 			:South_African_rand, 			"Cent", 		100,		"🇿🇦"		],
	[ "196", 	:South_Georgia_And_South_Sandwich_Islands, "GS", 	"SGS", 			"+500", 	:english, 		"???",					"???",			100,		"🇬🇸"		],
	[ "197", 	:Spain, 			"ES", 			"ESP", 			"+34", 		:spanish, 		:Euro, 					"Cent", 		100,		"🇪🇸"		],
	[ "198",	:Sri_Lanka, 			"LK", 			"LKA", 			"+94", 		:sinhala, 		:Sri_Lankan_rupee, 			"Cent", 		100,		"🇱🇰"		],
	[ "199", 	:Saint_Helena, 			"SH", 			"SHN", 			"+290", 	:english, 		:Saint_Helena_pound, 			"Pence", 		100,		"🇸🇭"		],
	[ "200", 	:Saint_Pierre_And_Miquelon,  	"PM", 			"SPM", 			"+508", 	:french, 		:Euro, 					"Cent", 		100,		"🇵🇲"		],

	[ "201", 	:Sudan, 			"SD", 			"SDN", 			"+249", 	:arabic, 		:Sudanese_pound, 			"Piastre", 		100,		"🇸🇩"		],
	[ "202", 	:Suriname, 			"SR", 			"SUR", 			"+597", 	:dutch, 		:Surinamese_dollar, 			"Cent", 		100,		"🇸🇷"		],
	[ "203", 	:Svalbard_And_Jan_Mayen_Islands,"SJ", 			"SJM", 			"+47", 		:norwegian_bokmal, 	:krone, 				"Øre", 			100,		"🇸🇯"		], # I'm not quiet sure, may be norwegian_nynorsk
	[ "204", 	:Eswatini, 			"SZ", 			"SWZ", 			"+268", 	:swiss_german, 		:Lilangeni, 				"Cent", 		100,		"🇸🇿"		], # Formelly called :Swaziland
	[ "205",	:Sweden, 			"SE", 			"SWE", 			"+46", 		:swedish, 		:Swedish_krona, 			"Öre", 			100,		"🇸🇪"		],
	[ "206",	:Switzerland, 			"CH", 			"CHE", 			"+41", 		:german, 		:Swiss_franc, 				"Centime", 		100,		"🇨🇭"		],
	[ "207",	:Syria, 			"SY", 			"SYR", 			"+963", 	:arabic, 		:Syrian_pound, 				"Piastre", 		100,		"🇸🇾"		],
	[ "208",	:Taiwan, 			"TW", 			"TWN", 			"+886", 	:mandarin, 		:New_Taiwan_dollar, 			"Cent", 		100,		"🇹🇼"		],
	[ "209", 	:Tajikistan, 			"TJ", 			"TJK", 			"+992", 	:tajik, 		:Tajikistani_somoni, 			"Diram", 		100,		"🇹🇯"		],
	[ "210", 	:Tanzania, 			"TZ", 			"TZA", 			"+255", 	:swahili, 		:Tanzanian_shilling, 			"Cent", 		100,		"🇹🇿"		],
	[ "211",	:Thailand, 			"TH", 			"THA", 			"+66", 		:thai, 			:Thai_baht, 				"Satang", 		100,		"🇹🇭"		],
	[ "212", 	:Togo, 				"TG", 			"TGO", 			"+228",		:french, 		:West_African_CFA_franc, 		"Centime", 		100,		"🇹🇬"		],
	[ "213", 	:Tokelau, 			"TK", 			"TKL", 			"+690", 	:tokelauan, 		:New_Zealand_dollar, 			"Cent", 		100,		"🇹🇰"		],
	[ "214", 	:Tonga, 			"TO", 			"TON", 			"+676", 	:tongan, 		:Tongan_paanga, 			"Seniti", 		100,		"🇹🇴"		],
	[ "215",	:Trinidad_And_Tobago, 		"TT", 			"TTO",		 	"+1-868", 	:english, 		:Trinidad_and_Tobago_dollar, 		"Cent", 		100,		"🇹🇹"		],
	[ "216", 	:Tunisia, 			"TN", 			"TUN", 			"+216", 	:arabic, 		:Tunisian_dinar, 			"Millime", 		1000,		"🇹🇳"		],
	[ "217",	:Turkey, 			"TR", 			"TUR", 			"+90", 		:turkish, 		:Turkish_lira, 				"Kuruş", 		100,		"🇹🇷"		],
	[ "218", 	:Turkmenistan, 			"TM", 			"TKM", 			"+993", 	:turkmen, 		:Turkmenistan_manat, 			"Tennesi", 		100,		"🇹🇱"		],
	[ "219", 	:Turks_And_Caicos_Islands, 	"TC", 			"TCA", 			"+1-649", 	:english, 		:United_States_dollar, 			"Cent", 		100,		"🇹🇨"		],
	[ "220", 	:Tuvalu, 			"TV", 			"TUV", 			"+688", 	:tuvaluan, 		:Tuvaluan_dollar, 			"Cent", 		100,		"🇹🇻"		],
	[ "221", 	:Uganda, 			"UG", 			"UGA", 			"+256", 	:english, 		:Ugandan_shilling, 			"???",			100,		"🇺🇬"		],
	[ "222",	:Ukraine, 			"UA", 			"UKR", 			"+380", 	:ukrainian, 		:Ukrainian_hryvnia, 			"Kopiyka", 		100,		"🇺🇦"		],
	[ "223", 	:United_Arab_Emirates, 		"AE", 			"ARE", 			"+971", 	:arabic, 		:United_Arab_Emirates_dirham, 		"Fils", 		100,		"🇦🇪" 		],
	[ "224",	:United_Kingdom, 		"GB", 			"GBR", 			"+44", 		:english, 		:British_pound, 			"Penny", 		100,		"🇬🇧"		],
	[ "225",	:United_States, 		"US", 			"USA", 			"+1", 		:english, 		:United_States_dollar, 			"Cent", 		100,		"🇺🇸"		], # Same as phone code of :Canada

	[ "226", 	:United_States_Minor_Outlying_Islands, "UM", 		"UMI", 			"+246", 	:english, 		"???",					"???",			100,		"🇺🇲"		],
	[ "227",	:Uruguay, 			"UY", 			"URY", 			"+598", 	:spanish, 		:Uruguayan_peso, 			"Centésimo", 		100,		"🇺🇾"		],
	[ "228",	:Uzbekistan, 			"UZ", 			"UZB", 			"+998", 	:uzbek, 		:Uzbekistani_som, 			"Tiyin" , 		100,		"🇺🇿"		],
	[ "229", 	:Vanuatu, 			"VU", 			"VUT", 			"+678", 	:bislama, 		:Vanuatu_vatu, 				"???",			100,		"🇻🇺"		],
	[ "230", 	:Vatican, 			"VA", 			"VAT", 			"+379", 	:italian, 		:Euro, 					"Cent", 		100,		"🇻🇦"		],
	[ "231",	:Venezuela, 			"VE", 			"VEN", 			"+58", 		:spanish, 		:Venezuelan_bolivar_soberano, 		"Céntimo", 		100,		"🇻🇪"		],
	[ "232",	:Vietnam, 			"VN", 			"VNM", 			"+84", 		:vietnamese, 		:Vietnamese_dong, 			"Hào", 			10,		"🇻🇳"		],
	[ "233", 	:British_Virgin_Islands, 	"VG", 			"VGB", 			"+1-284", 	:english, 		:United_States_dollar, 			"Cent", 		100,		"🇻🇬"		],
	[ "234", 	:United_States_Virgin_Islands, 	"VI", 			"VIR", 			"+1-340", 	:english, 		:United_States_dollar, 			"Cent", 		100,		"🇻🇮"		],
	[ "235", 	:Wallis_And_Futuna_Islands, 	"WF", 			"WLF", 			"+681", 	:french, 		:CFP_franc, 				"Centime", 		100,		"🇼🇫"		],
	[ "236", 	:Western_Sahara, 		"EH", 			"ESH", 			"+212", 	:arabic, 		:Sahrawi_peseta, 			"Centime", 		100,		"🇪🇭"		],
	[ "237",	:Yemen, 			"YE", 			"YEM", 			"+967", 	:arabic, 		:Yemeni_rial, 				"Fils", 		100,		"🇾🇪"		],
	[ "238", 	:Canary_Islands, 		"IC", 			"???",			"+???",		:spanish, 		:Euro, 					"Cent", 		100,		"🇮🇨"		],
	[ "239", 	:Zambia, 			"ZM", 			"ZMB", 			"+260", 	:bemba, 		:Zambian_kwacha, 			"Ngwee", 		100,		"🇿🇲"		],
	[ "240",	:Zimbabwe, 			"ZW", 			"ZWE", 			"+263", 	:shona, 		:RTGS_dollar, 				"???", 			100,		"🇿🇼"		],
	[ "241", 	:Clipperton_Island, 		"CP", 			"CPT", 			"???",		:french, 		:Euro, 					"Cent", 		100,		"🇨🇵"		], # In other source PF and PYF
	[ "242", 	:Montenegro, 			"ME", 			"MNE", 			"+382", 	:serbian, 		:Euro, 					"Cent", 		100,		"🇲🇪"		],
	[ "243",	:Serbia, 			"RS", 			"SRB", 			"+381", 	:serbian, 		:Serbian_dinar, 			"Para", 		100,		"🇷🇸"		],
	[ "244", 	:Saint_Barthelemy, 		"BL", 			"BLM", 			"+590", 	:french, 		:Euro, 					"Cent", 		100,		"🇧🇱"		], # Same phone code as :Saint_Martin
	[ "245", 	:Saint_Martin, 			"MF", 			"MAF", 			"+590", 	:dutch, 		:Netherlands_Antillean_guilder, 	"Cent", 		100,		"🇲🇫"		],
	//[ "246", 	:Latin_America, 		NULL, 			NULL, 			NULL, 		:spanish, 		NULL,					NULL,			NULL,		NULL		], # Exists in Qt but removed because it isn't a country
	[ "247", 	:Ascension_Island, 		"AC", 			"ASC", 			"+247", 	:english, 		:Saint_Helena_pound, 			"Penny", 		100,		"🇦🇨" 		],
	[ "248", 	:Aland_Islands, 		"AX", 			"ALA", 			"+358", 	:swedish, 		:Euro, 					"Cent", 		100,		"🇦🇽"		],
	[ "249", 	:Diego_Garcia, 			"DG", 			"DGA", 			"+246", 	:french, 		:United_States_dollar, 			"Cent", 		100,		"🇩🇬"		],
	[ "250", 	:Ceuta_And_Melilla, 		"EA", 			"???",			"+???",		:arabic,		:Euro, 					"Cent", 		100,		"🇪🇦"		],

	[ "251", 	:Isle_Of_Man, 			"IM", 			"IMN", 			"+44", 		:manx, 			:Manx_pound, 				"Penny", 		100,		"🇮🇲"		],
	[ "252", 	:Jersey, 			"JE", 			"JEY", 			"+44-1534", 	:french, 		:Jersey_pound, 				"Penny", 		100,		"🇯🇪"		],
	[ "253", 	:Tristan_Da_Cunha, 		"TA", 			"TAA", 			"+???",		:english, 		:Saint_Helena_pound,  			"Penny", 		100,		"🇹🇦"		],
	[ "254", 	:South_Sudan, 			"SS", 			"SSD", 			"+211", 	:english, 		:South_Sudanese_pound,  		"Penny", 		100,		"🇸🇸"		],
	[ "255", 	:Bonaire, 			"BQ", 			"BES", 			"+599", 	:papiamento, 		:United_States_dollar, 			"Cent" , 		100,		""		], # dutch is the official language
	[ "256", 	:Sint_Maarten, 			"SX", 			"SXM", 			"+590", 	:french, 		:Netherlands_Antillean_guilder, 	"Cent" , 		100,		"🇸🇽"		],
	[ "257", 	:Kosovo, 			"XK", 			"XKX", 			"+383", 	:albanian, 		:Euro, 					"Cent", 		100,		"🇽🇰"		],
	//[ "258", 	:European_Union, 		"EU", 			"???",			NULL,		:english, 		:Euro, 					"Cent", 		100,		"🇪🇺"		], # Exists in Qt but removed because it isn't a country
	[ "259", 	:Outlying_Oceania, 		"UM", 			"UMI", 			"???",		:malay, 		:Australian_dollar, 			"Cent", 		100,		""		],
	[ "260",	:Scottland,			"SC",			"SCT",			"+44",		:scottish_gaelic,	:Pound,					"Penny", 		100,		NULL		], # Emoji flag unavailable for this country
	[ NULL,		:England,			"EN",			"ENG",			"+44",		:english,		:Pound,					"Penny", 		100,		NULL		], # Idem. Doesn't exist in Qt (and Unicode) but we add it because some people consider it a country
	[ NULL,		:Wales,				"WLS",			"WS",			"+44",		:welsh,			:Pound,					"Penny", 		100,		NULL		], # Idem
	[ NuLL,		:Norther_Ireland,		"NIR",			"NI",			"+44",		:irish,			:Pound,					"Penny",		100,		NULL		]  # Check: norther or northern?
	//[ NULL,	:United_nations,		NULL,			NULL,			NULL,		NULL,			NULL,					NULL,			NULL,		"🇺🇳"		]  # Exists in Qt but removed because it isn't a country

]

func LocaleCountriesXT()
	return _aLocaleCountriesXT

	func CountriesXT()
		return LocaleCountriesXT()

func LocaleCountries()
	aResult = []
	
	for aCountry in LocaleCountriesXT()
		aResult + aCountry[2]
	next

	return aResult

	func Countries()
		return LocaleCountries()

func CountriesAndTheirDefaultLanguages()
	aResult = []
	for aCountryInfo in LocaleCountriesXT()
		aResult + [ aCountryInfo[2], aCountryInfo[6] ]
	next
	return aResult

func CountriesforWhichDefaultLanguageIs(cLangCode)
	aResult = []
	cLangName = StzLanguageQ(cLangCode).Name()
	for aCountryInfo in LocaleCountriesXT()
		if lower(aCountryInfo[6]) = lower(cLangName)
			aResult + aCountryInfo[2]
		ok
	next
	return aResult

func StzCountryQ(pcCountryIdentifier)
	return new stzCountry(pcCountryIdentifier)

class stzCountry
	@aCountryInfo

	def init(pcCountryIdentifier)	# Can be: code, name, abbreviation, phone code, defaultlanguage, or a locale abbreviation
		oStr = new stzString(pcCountryIdentifier)

		if oStr.IsCountryCode()
			for aCountryInfo in LocaleCountriesXT()
				if lower(aCountryInfo[1]) = lower(pcCountryIdentifier)

					@aCountryInfo = aCountryInfo
					exit
				ok
			next
	
		but oStr.IsCountryAbbreviation()
			for aCountryInfo in LocaleCountriesXT()
				if lower(aCountryInfo[3])  = lower(pcCountryIdentifier) OR
				   lower(aCountryInfo[4])  = lower(pcCountryIdentifier)
	
					@aCountryInfo = aCountryInfo
					exit
				ok
			next
	
		but oStr.IsCountryName()
			for aCountryInfo in LocaleCountriesXT()
				if lower(aCountryInfo[2]) = lower(pcCountryIdentifier)

					@aCountryInfo = aCountryInfo
					exit
				ok
			next
	
		but oStr.IsLanguageName()

			cCountryNumber = StzLanguageQ(pcCountryIdentifier).DefaultCountryNumber()
		
			//cCountryCode = DefaultCountryCodeForLanguage(pcCountryIdentifier)

			for aCountryInfo in LocaleCountriesXT()
				if lower(aCountryInfo[1]) = lower(cCountryNumber)

					@aCountryInfo = aCountryInfo
					exit
				ok
			next

		but oStr.IsCountryPhoneCode()
			cCountryPhoneCode = oStr.Content()

			for aCountryInfo in LocaleCountriesXT()
				if lower(aCountryInfo[5]) = lower(cCountryPhoneCode)

					@aCountryInfo = aCountryInfo
					exit
				ok
			next

		but oStr.IsLocaleAbbreviation()
			// TODO

		else
			StzRaise(stzCountryError(:UnsupportedCountryIdentifier))
		ok

	def QtNumber()
		return @aCountryInfo[1]

		def Number()
			return This.QtNumber()

	def Name()
		return @aCountryInfo[2]

		def Country()
			return This.Name()
	
		def Content()
			return This.Name()

		def Value()
			return Content()
	
	def NativeName()
		return StzLocale([ :Country = This.Country() ]).CountryNativeName()


	def Abbreviation()
		return This.ShortAbbreviation()

	def ShortAbbreviation()
		return @aCountryInfo[3]

	def LongAbbreviation()
		return @aCountryInfo[4]

	def LocaleAbbreviation()
		return LocaleAbbreviationsXT()[ This.Country() ][1][1][2]

	def PhoneCode()
		return @aCountryInfo[5]

	def DefaultLanguageQtNumber()

		cLanguage = This.DefaultLanguage()

		for aLanguageInfo in LocaleLanguagesXT()
			if aLanguageInfo[2] = cLanguage
				return aLanguageInfo[1]
			ok
		next

		def DefaultLanguageNumber()
			return This.DefaultLanguageQtNumber()

		def LanguageQtNumber()
			return This.DefaultLanguageQtNumber()

		def LanguageNumber()
			return This.DefaultLanguageQtNumber()

	def DefaultLanguageAbbreviation()
		return StzLanguageQ(This.Language()).Abbreviation()

		def LanguageAbbreviation()
			return This.DefaultLanguageAbbreviation()

	def DefaultLanguage()
		return @aCountryInfo[6]

		def DefaultLanguageName()
			return This.DefaultLanguage()

		def Language()
			return This.DefaultLanguage()

		def LanguageName()
			return This.DefaultLanguage()

	def LanguageNativeName()
		return StzLocaleQ([ :Country = This.Name() ]).LanguageNativeName()

		def DefaultLanguageNativeName()
			return This.LanguageNativeName()

	def Languages()
		aResult = []
		for aLangInfo in LocaleLanguagesXT()
			if lower(aLangInfo[5]) = lower(This.Country())
				aResult + aLangInfo[2]
			ok
		next

		return aResult

		def LanguagesNames()
			return This.Languages()

	def LanguagesAbbreviations()
		aResult = []

		for aLangInfo in LocaleLanguagesXT()
			if lower(aLangInfo[5]) = lower(This.Country())
				aResult + aLangInfo[3]
			ok
		next

		return aResult

	def Script()
		/* NOTE:
		We can't rely on stzLanguage class here, as we did for Language()
		method, because the Script information is locale-speciefic.
		*/
		
		//return StzLocaleQ([ :Country = This.Name() ]).Script()

		cLanguage = This.DefaultLanguage()

		for aScriptInfo in LocaleScriptsXT()
			if aScriptInfo[2] = cLanguage
				return aScriptInfo[2]
			ok
		next

		def ScriptName()
			return This.Script()

	def ScriptQtNumber()
		cLanguage = This.DefaultLanguage()

		for aScriptInfo in LocaleScriptsXT()
			if aScriptInfo[2] = cLanguage
				return aScriptInfo[1]
			ok
		next

		def ScriptNumber()
			return This.ScriptQtNumber()

	def Currency()
		return @aCountryInfo[7]

		def CurrencyName()
			return This.Currency()

	def CurrencyNativeName()
		return StzLocaleQ([ :Country = This.Country() ]).CurrencyNativeName()

	def CurrencySymbol()
		return StzLocaleQ([ :Country = This.Country() ]).CurrencySymbol()

	def CurrencyAbbreviation()
		return StzLocaleQ([ :Country = This.Country() ]).CurrencyAbbreviation()

	def CurrencyFractionalUnit()
		return  @aCountryInfo[8]

		def CurrencyFraction()
			return This.CurrencyFractionalUnit()

	def CurrencyBase()
		return @aCountryInfo[9]

	def CurrencyEmojiFlag()
		return @aCountryInfo[10]
