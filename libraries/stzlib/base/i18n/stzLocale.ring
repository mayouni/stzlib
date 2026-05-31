#----------------------------------------------------------------#
#            SOFTANZA LIBRARY (V0.9) - STZLOCALE                 #
#        An accelerative library for Ring applications           #
#----------------------------------------------------------------#
#                                                                #
#  Description	: The class for managing locales in Softanza     #
#  Version      : V0.9 (2020-2025)                               #
#  Author       : Mansour Ayouni (kalidianow@gmail.com)          #
#                                                                #
#----------------------------------------------------------------#

/*
Nice article about locales:
https://docs.oracle.com/cd/E19253-01/817-2521/overview-39/index.html
*/

$aDaysOfWeek = [
	[ "1", :Monday ],
	[ "2", :Tuesday ],
	[ "3", :Wednesday ],
	[ "4", :Thursday ],
	[ "5", :Friday ],
	[ "6", :Saturday ],
	[ "7", :Sunday ]
]

# â”€â”€ Locale helper data tables â”€â”€

$_aDayNamesPerLang = [
	[:english,    ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]],
	[:french,     ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]],
	[:arabic,     ["اÙ„اثÙ†ÙŠÙ†", "اÙ„ثÙ„اثاء", "اÙ„أربعاء", "اÙ„خÙ…ÙŠس", "اÙ„جÙ…عة", "اÙ„سبت", "اÙ„أحد"]],
	[:spanish,    ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado", "Domingo"]],
	[:german,     ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]],
	[:portuguese, ["Segunda-feira", "Terca-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sabado", "Domingo"]],
	[:italian,    ["Lunedi", "Martedi", "Mercoledi", "Giovedi", "Venerdi", "Sabato", "Domenica"]],
	[:russian,    ["Ponedelnik", "Vtornik", "Sreda", "Chetverg", "Pyatnitsa", "Subbota", "Voskresenie"]],
	[:turkish,    ["Pazartesi", "Sali", "Carsamba", "Persembe", "Cuma", "Cumartesi", "Pazar"]],
	[:dutch,      ["Maandag", "Dinsdag", "Woensdag", "Donderdag", "Vrijdag", "Zaterdag", "Zondag"]]
]

$_aMonthNamesPerLang = [
	[:english,    ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]],
	[:french,     ["Janvier", "Fevrier", "Mars", "Avril", "Mai", "Juin", "Juillet", "Aout", "Septembre", "Octobre", "Novembre", "Decembre"]],
	[:arabic,     ["Yanayir", "Fibrayir", "Maris", "Abril", "Mayu", "Yunyu", "Yulyu", "Aghustus", "Sibtambir", "Uktubar", "Nufambir", "Disambir"]],
	[:spanish,    ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]],
	[:german,     ["Januar", "Februar", "Marz", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]],
	[:portuguese, ["Janeiro", "Fevereiro", "Marco", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]],
	[:italian,    ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"]],
	[:russian,    ["Yanvar", "Fevral", "Mart", "Aprel", "May", "Iyun", "Iyul", "Avgust", "Sentyabr", "Oktyabr", "Noyabr", "Dekabr"]],
	[:turkish,    ["Ocak", "Subat", "Mart", "Nisan", "Mayis", "Haziran", "Temmuz", "Agustos", "Eylul", "Ekim", "Kasim", "Aralik"]],
	[:dutch,      ["Januari", "Februari", "Maart", "April", "Mei", "Juni", "Juli", "Augustus", "September", "Oktober", "November", "December"]]
]

$_aCurrencyISOData = [
	[:Afghan_afghani, "AFN", "Af"],
	[:Albanian_lek, "ALL", "L"],
	[:Algerian_dinar, "DZD", "DA"],
	[:Argentine_peso, "ARS", "$"],
	[:Armenian_dram, "AMD", "AMD"],
	[:Australian_dollar, "AUD", "A$"],
	[:Azerbaijani_manat, "AZN", "AZN"],
	[:Bahamian_dollar, "BSD", "B$"],
	[:Bahraini_dinar, "BHD", "BD"],
	[:Bangladeshi_taka, "BDT", "Tk"],
	[:Barbados_dollar, "BBD", "Bds$"],
	[:Belarusian_ruble, "BYN", "Br"],
	[:Belize_dollar, "BZD", "BZ$"],
	[:Bermudian_dollar, "BMD", "BD$"],
	[:Bhutanese_ngultrum, "BTN", "Nu"],
	[:Bolivian_boliviano, "BOB", "Bs"],
	[:Bosnia_and_Herzegovina_convertible_mark, "BAM", "KM"],
	[:Botswana_pula, "BWP", "P"],
	[:Brazilian_real, "BRL", "R$"],
	[:Brunei_dollar, "BND", "B$"],
	[:Bulgarian_lev, "BGN", "Ð»Ð²"],
	[:Cambodian_riel, "KHR", "KHR"],
	[:Canadian_dollar, "CAD", "C$"],
	[:Cape_Verdean_escudo, "CVE", "Esc"],
	[:Chilean_peso, "CLP", "CL$"],
	[:Chinese_yuan, "CNY", "CN¥"],
	[:Colombian_peso, "COP", "COL$"],
	[:Comorian_franc, "KMF", "CF"],
	[:Costa_Rican_colon, "CRC", "CRC"],
	[:Croatian_kuna, "HRK", "kn"],
	[:Cuban_peso, "CUP", "$MN"],
	[:Czech_koruna, "CZK", "Kc"],
	[:Danish_krone, "DKK", "kr"],
	[:Dominican_peso, "DOP", "RD$"],
	[:Eastern_Caribbean_dollar, "XCD", "EC$"],
	[:Egyptian_pound, "EGP", "EGP"],
	[:Eritrean_nakfa, "ERN", "Nfk"],
	[:Ethiopian_birr, "ETB", "Br"],
	[:Euro, "EUR", "EUR"],
	[:Fijian_dollar, "FJD", "FJ$"],
	[:Gambian_dalasi, "GMD", "D"],
	[:Georgian_lari, "GEL", "GEL"],
	[:Ghanaian_cedi, "GHS", "GHS"],
	[:Guatemalan_quetzal, "GTQ", "Q"],
	[:Guinean_franc, "GNF", "FG"],
	[:Guyanese_dollar, "GYD", "G$"],
	[:Haitian_gourde, "HTG", "G"],
	[:Honduran_lempira, "HNL", "L"],
	[:Hong_Kong_dollar, "HKD", "HK$"],
	[:Hungarian_forint, "HUF", "Ft"],
	[:Icelandic_krona, "ISK", "kr"],
	[:Indian_rupee, "INR", "Rs"],
	[:Indonesian_rupiah, "IDR", "Rp"],
	[:Iranian_rial, "IRR", "IRR"],
	[:Iraqi_dinar, "IQD", "IQD"],
	[:Israeli_new_shekel, "ILS", "ILS"],
	[:Jamaican_dollar, "JMD", "J$"],
	[:Japanese_yen, "JPY", "JP¥"],
	[:Jordanian_dinar, "JOD", "JD"],
	[:Kazakhstani_tenge, "KZT", "KZT"],
	[:Kenyan_shilling, "KES", "KSh"],
	[:Kuwaiti_dinar, "KWD", "KD"],
	[:Kyrgyzstani_som, "KGS", "KGS"],
	[:Lao_kip, "LAK", "LAK"],
	[:Lebanese_pound, "LBP", "LBP"],
	[:Liberian_dollar, "LRD", "L$"],
	[:Libyan_dinar, "LYD", "LD"],
	[:Macanese_pataca, "MOP", "MOP$"],
	[:Malagasy_ariary, "MGA", "Ar"],
	[:Malawian_kwacha, "MWK", "MK"],
	[:Malaysian_ringgit, "MYR", "RM"],
	[:Maldivian_rufiyaa, "MVR", "Rf"],
	[:Mauritanian_ouguiya, "MRU", "UM"],
	[:Mauritian_rupee, "MUR", "Rs"],
	[:Mexican_peso, "MXN", "Mex$"],
	[:Moldovan_leu, "MDL", "MDL"],
	[:Mongolian_tugrik, "MNT", "MNT"],
	[:Moroccan_dirham, "MAD", "MAD"],
	[:Mozambican_metical, "MZN", "MT"],
	[:Myanmar_kyat, "MMK", "K"],
	[:Namibian_dollar, "NAD", "N$"],
	[:Nepalese_rupee, "NPR", "NRs"],
	[:New_Zealand_dollar, "NZD", "NZ$"],
	[:Nicaraguan_cordoba, "NIO", "C$"],
	[:Nigerian_naira, "NGN", "NGN"],
	[:North_Korean_won, "KPW", "KPW"],
	[:Norwegian_krone, "NOK", "kr"],
	[:Omani_rial, "OMR", "OMR"],
	[:Pakistani_rupee, "PKR", "Rs"],
	[:Panamanian_balboa, "PAB", "B/."],
	[:Papua_New_Guinean_kina, "PGK", "K"],
	[:Paraguayan_guarani, "PYG", "Gs"],
	[:Peruvian_sol, "PEN", "S/."],
	[:Philippine_peso, "PHP", "PHP"],
	[:Polish_zloty, "PLN", "zl"],
	[:Pound_sterling, "GBP", "GBP"],
	[:Qatari_riyal, "QAR", "QR"],
	[:Romanian_leu, "RON", "lei"],
	[:Russian_ruble, "RUB", "RUB"],
	[:Rwandan_franc, "RWF", "RF"],
	[:Saint_Helena_pound, "SHP", "SHP"],
	[:Samoan_tala, "WST", "WS$"],
	[:Saudi_riyal, "SAR", "SR"],
	[:Serbian_dinar, "RSD", "din."],
	[:Seychellois_rupee, "SCR", "SRe"],
	[:Sierra_Leonean_leone, "SLL", "Le"],
	[:Singapore_dollar, "SGD", "S$"],
	[:Solomon_Islands_dollar, "SBD", "SI$"],
	[:Somali_shilling, "SOS", "Sh"],
	[:South_African_rand, "ZAR", "R"],
	[:South_Korean_won, "KRW", "KRW"],
	[:Sri_Lankan_rupee, "LKR", "Rs"],
	[:Sudanese_pound, "SDG", "SDG"],
	[:Surinamese_dollar, "SRD", "SRD"],
	[:Swazi_lilangeni, "SZL", "E"],
	[:Swedish_krona, "SEK", "kr"],
	[:Swiss_franc, "CHF", "CHF"],
	[:Syrian_pound, "SYP", "SYP"],
	[:New_Taiwan_dollar, "TWD", "NT$"],
	[:Tajikistani_somoni, "TJS", "SM"],
	[:Tanzanian_shilling, "TZS", "TSh"],
	[:Thai_baht, "THB", "THB"],
	[:Tongan_pa_anga, "TOP", "T$"],
	[:Trinidad_and_Tobago_dollar, "TTD", "TT$"],
	[:Tunisian_dinar, "TND", "DT"],
	[:Turkish_lira, "TRY", "TL"],
	[:Turkmenistan_manat, "TMT", "T"],
	[:Ugandan_shilling, "UGX", "USh"],
	[:Ukrainian_hryvnia, "UAH", "UAH"],
	[:UAE_dirham, "AED", "AED"],
	[:United_States_Dollar, "USD", "$"],
	[:Uruguayan_peso, "UYU", "$U"],
	[:Uzbekistani_som, "UZS", "UZS"],
	[:Vanuatu_vatu, "VUV", "VT"],
	[:Venezuelan_bolivar, "VEF", "Bs.F"],
	[:Vietnamese_dong, "VND", "VND"],
	[:West_African_CFA_franc, "XOF", "CFA"],
	[:Central_African_CFA_franc, "XAF", "FCFA"],
	[:CFP_franc, "XPF", "F"],
	[:Yemeni_rial, "YER", "YER"],
	[:Zambian_kwacha, "ZMW", "ZK"],
	[:Zimbabwean_dollar, "ZWL", "Z$"],
	[:Antarctic_dollar, "AAD", "$"]
]

# â”€â”€ Pure Ring locale helper functions â”€â”€

func _LocaleLangCodeFromAbbr(cLocaleAbbr)
	cLocaleAbbr = StzReplace(cLocaleAbbr, "-", "_")
	nPos = StzFind(cLocaleAbbr, "_")
	if nPos > 0
		return StzLower(StzLeft(cLocaleAbbr, nPos - 1))
	ok
	return StzLower(cLocaleAbbr)

func _LocaleCountryCodeFromAbbr(cLocaleAbbr)
	cLocaleAbbr = StzReplace(cLocaleAbbr, "-", "_")
	nPos = StzFind(cLocaleAbbr, "_")
	if nPos > 0
		cRest = StzMid(cLocaleAbbr, nPos + 1, StzLen(cLocaleAbbr))
		nPos2 = StzFind(cRest, "_")
		if nPos2 > 0
			return StzUpper(StzMid(cRest, nPos2 + 1, StzLen(cRest)))
		ok
		if StzLen(cRest) <= 3 and isalpha(StzLeft(cRest, 1))
			return StzUpper(cRest)
		ok
	ok
	return ""

func _LocaleNormalizeAbbr(cInput)
	if cInput = NULL or cInput = "" or cInput = "C"
		return "C"
	ok
	cInput = StzReplace(cInput, "-", "_")
	nPos = StzFind(cInput, "_")
	if nPos > 0
		cLang = StzLower(StzLeft(cInput, nPos - 1))
		cRest = StzUpper(StzMid(cInput, nPos + 1, StzLen(cInput)))
		return cLang + "_" + cRest
	ok
	cLang = StzLower(cInput)
	nLen = len($aLocaleLanguagesXT)
	for i = 1 to nLen
		if StzLower($aLocaleLanguagesXT[i][3]) = cLang
			if $aLocaleLanguagesXT[i][5] != NULL
				cCountryName = $aLocaleLanguagesXT[i][5]
				nLen2 = len(_aLocaleCountriesXT)
				for j = 1 to nLen2
					if StzLower(_aLocaleCountriesXT[j][2]) = StzLower(cCountryName)
						return cLang + "_" + _aLocaleCountriesXT[j][3]
					ok
				next
			ok
			return cLang
		ok
	next
	return cInput

func _LocaleCountryNumber(cCountryCode)
	cCode = StzUpper(cCountryCode)
	nLen = len(_aLocaleCountriesXT)
	for i = 1 to nLen
		if StzUpper(_aLocaleCountriesXT[i][3]) = cCode
			return _aLocaleCountriesXT[i][1]
		ok
	next
	return "0"

func _LocaleQtScriptNumber(cScriptCode)
	nLen = len(_aLocaleScriptsXT)
	for i = 1 to nLen
		if StzUpper(_aLocaleScriptsXT[i][3]) = StzUpper(cScriptCode)
			return _aLocaleScriptsXT[i][1]
		ok
	next
	return "0"

func _LocaleFirstDayNumber(cLocaleAbbr)
	cCountry = StzUpper(_LocaleCountryCodeFromAbbr(cLocaleAbbr))
	aSatFirst = ["AF", "IR"]
	aSunFirst = ["US", "CA", "JP", "CN", "IL", "KR", "TW", "PH", "BR", "IN",
	             "CO", "MX", "AU", "NZ", "SG", "ZA", "GT", "HN", "SV", "NI",
	             "DO", "HT", "PR", "BS", "JM", "TT", "BB", "LC", "VC", "GD",
	             "AG", "DM", "KN", "BZ", "GY", "PA", "PE", "PY", "VE"]
	for c in aSatFirst
		if cCountry = c return 6 ok
	next
	for c in aSunFirst
		if cCountry = c return 7 ok
	next
	return 1

func _LocaleDecimalPointChar(cLocaleAbbr)
	cLang = _LocaleLangCodeFromAbbr(cLocaleAbbr)
	aCommaDec = ["fr", "de", "es", "pt", "it", "nl", "ru", "pl", "cs", "sk",
	             "sv", "fi", "da", "nb", "nn", "ro", "hu", "hr", "sr", "sl",
	             "bg", "uk", "be", "el", "tr", "vi", "id", "ca", "gl", "eu"]
	for c in aCommaDec
		if cLang = c return "," ok
	next
	return "."

func _LocaleGroupSepChar(cLocaleAbbr)
	cLang = _LocaleLangCodeFromAbbr(cLocaleAbbr)
	aSpaceGroup = ["fr", "sv", "fi", "pl", "cs", "sk", "nb", "nn", "da",
	               "ru", "uk", "be", "bg"]
	for c in aSpaceGroup
		if cLang = c return " " ok
	next
	aPeriodGroup = ["de", "es", "pt", "it", "nl", "ro", "hu", "hr", "sr",
	                "sl", "el", "tr", "vi", "id", "ca", "gl", "eu"]
	for c in aPeriodGroup
		if cLang = c return "." ok
	next
	return ","

func _LocaleMeasurementSysNum(cLocaleAbbr)
	cCountry = StzUpper(_LocaleCountryCodeFromAbbr(cLocaleAbbr))
	if cCountry = "US" or cCountry = "LR" or cCountry = "MM"
		return "1"
	ok
	if cCountry = "GB"
		return "2"
	ok
	return "0"

func _LocaleTimeFormatStr(cLocaleAbbr, nType)
	cCountry = StzUpper(_LocaleCountryCodeFromAbbr(cLocaleAbbr))
	cLang = _LocaleLangCodeFromAbbr(cLocaleAbbr)
	if nType = 1 or nType = 2
		if cCountry = "US" or (cLang = "en" and cCountry = "")
			return "h:mm AP"
		ok
		return "HH:mm"
	ok
	if cCountry = "US" or (cLang = "en" and cCountry = "")
		return "h:mm:ss AP t"
	ok
	return "HH:mm:ss t"

func _CurrencyISOCode(cCurrencyName)
	cName = StzLower(cCurrencyName)
	nLen = len($_aCurrencyISOData)
	for i = 1 to nLen
		if StzLower($_aCurrencyISOData[i][1]) = cName
			return $_aCurrencyISOData[i][2]
		ok
	next
	return ""

func _CurrencyNativeSymbol(cCurrencyName)
	cName = StzLower(cCurrencyName)
	nLen = len($_aCurrencyISOData)
	for i = 1 to nLen
		if StzLower($_aCurrencyISOData[i][1]) = cName
			return $_aCurrencyISOData[i][3]
		ok
	next
	return ""

func _DayNameInLang(cLangName, nDay)
	cLang = StzLower(cLangName)
	nLen = len($_aDayNamesPerLang)
	for i = 1 to nLen
		if StzLower($_aDayNamesPerLang[i][1]) = cLang
			if nDay >= 1 and nDay <= 7
				return $_aDayNamesPerLang[i][2][nDay]
			ok
		ok
	next
	if nDay >= 1 and nDay <= 7
		return $_aDayNamesPerLang[1][2][nDay]
	ok
	return ""

func _DayAbbrInLang(cLangName, nDay)
	cFullName = _DayNameInLang(cLangName, nDay)
	if StzLen(cFullName) >= 3
		return StzLeft(cFullName, 3)
	ok
	return cFullName

func _DaySymbolInLang(cLangName, nDay)
	cFullName = _DayNameInLang(cLangName, nDay)
	if StzLen(cFullName) >= 1
		return StzLeft(cFullName, 1)
	ok
	return ""

func _MonthNameInLang(cLangName, nMonth)
	cLang = StzLower(cLangName)
	nLen = len($_aMonthNamesPerLang)
	for i = 1 to nLen
		if StzLower($_aMonthNamesPerLang[i][1]) = cLang
			if nMonth >= 1 and nMonth <= 12
				return $_aMonthNamesPerLang[i][2][nMonth]
			ok
		ok
	next
	if nMonth >= 1 and nMonth <= 12
		return $_aMonthNamesPerLang[1][2][nMonth]
	ok
	return ""

func _LangNameFromCode(cLangCode)
	cCode = StzLower(cLangCode)
	nLen = len($aLocaleLanguagesXT)
	for i = 1 to nLen
		if StzLower($aLocaleLanguagesXT[i][3]) = cCode
			return $aLocaleLanguagesXT[i][2]
		ok
	next
	return :english

func _LangNativeNameFromCode(cLangCode)
	cCode = StzLower(cLangCode)
	nLen = len($aLocaleLanguagesXT)
	for i = 1 to nLen
		if StzLower($aLocaleLanguagesXT[i][3]) = cCode
			return $aLocaleLanguagesXT[i][6]
		ok
	next
	return ""

# â”€â”€ Top-level functions â”€â”€

func StzSystemLocale()
	return "C"

	func SystemLocale()
		return StzSystemLocale()

	func StzSystemLocaleAbbreviation()
		return StzSystemLocale()

	func SystemLocaleAbbreviation()
		return StzSystemLocale()

func StzDefaultDaysOfWeek()
	return $aDaysOfWeek

	func DefaultDaysOfWeek()
		return StzDefaultDaysOfWeek()

func StzLocaleQ(p)
	return new stzLocale(p)

#-- ENGINE-BACKED LOCALE FUNCTIONS --

func StzFormatNumber(nValue, nDecimals)
	return StzEngineLocaleFormatNumber(nValue, nDecimals)

func StzEngineMonthName(nMonth)
	return StzEngineLocaleMonthName(nMonth)

func StzEngineMonthAbbr(nMonth)
	return StzEngineLocaleMonthAbbr(nMonth)

func StzEngineDayName(nDay)
	return StzEngineLocaleDayName(nDay)

func StzEngineDayAbbr(nDay)
	return StzEngineLocaleDayAbbr(nDay)

func StzLocaleToTitlecase(cStr)
	return StzEngineLocaleToTitlecase(cStr)

func StzLocaleAbbreviationsXT()
	return _aLocaleAbbreviationsXT

	func LocaleAbbreviationsXT()
		return StzLocaleAbbreviationsXT()

func StzLocaleAbbreviations()
	aResult = []

	for acountry in StzLocaleAbbreviationsXT()
		for aLanguage in aCountry[2]
			for aLocale in aLanguage
				aResult + aLocale[2]
			next
		next
	next

	return aResult

	func LocaleAbbreviations()
		return StzLocaleAbbreviations()

func StzLocaleAbbreviationsAsString()
	return _cLocaleAbbreviations

	func LocaleAbbreviationsAsString()
		return StzLocaleAbbreviationsAsString()

	func LocaleAbbreviationsHostedInString()
		return StzLocaleAbbreviationsAsString()

func StzLanguagesAndTheirDefaultCountries()
	aResult = []
	for aLangInfo in LocaleLanguagesXT()
		aResult + [ aLangInfo[2], aLangInfo[5] ]
	next
	return aResult

	func LanguagesAndTheirDefaultCountries()
		return StzLanguagesAndTheirDefaultCountries()

func StzLanguagesforWhichDefaultCountryIs(cCountryCode)
	aResult = []
	cCountryName = StzCountryQ(cCountryCode).Name()
	for aLangInfo in LocaleLanguagesXT()
		if StzLower(aLangInfo[5]) = StzLower(cCountryName)
			aResult + aLangInfo[2]
		ok
	next
	return aResult

	func LanguagesforWhichDefaultCountryIs(cCountryCode)
		return StzLanguagesforWhichDefaultCountryIs(cCountryCode)

func StzScriptsAndTheirDefaultLanguages()
	aResult = []
	for aScriptInfo in LocaleScriptsXT()
		aResult + [ aScriptInfo[2], DefaultLanguageForScript(aScriptInfo[2]) ]
	next
	return aResult

	func ScriptsAndTheirDefaultLanguages()
		return StzScriptsAndTheirDefaultLanguages()

func StzScriptsforWhichDefaultLanguageIs(cLangCode)
	aResult = []
	cLangName = StzLanguageQ(cLangCode).Name()
	for aScriptInfo in LocaleScriptsXT()
		if StzLower(aScriptInfo[4]) = StzLower(cLangName)
			aResult + aScriptInfo[2]
		ok
	next
	return aResult

	func ScriptsforWhichDefaultLanguageIs(cLangCode)
		return StzScriptsforWhichDefaultLanguageIs(cLangCode)

func StzLocaleMeasurementSystems()
	return _aLocaleMeasurementsystems

	func LocaleMeasurementSystems()
		return StzLocaleMeasurementSystems()

func StzNamesOfDays()
	return StzNamesOfDaysIn(:English)

	func NamesOfDays()
		return StzNamesOfDays()

func StzNamesOfDaysIn(pcLangOrCountry)

	aResult = []
	cLangName = :english

	if _(pcLangOrCountry).Q.IsLanguageName()
		cLangName = pcLangOrCountry
		oLocale = StzLocaleQ([ :Language = pcLangOrCountry ])

	but _(pcLangOrCountry).Q.IsCountryName()
		cLangName = StzCountryQ(pcLangOrCountry).Language()
		oLocale = StzLocaleQ([ :Country = pcLangOrCountry ])
	else
		oLocale = StzLocaleQ("C")
	ok

	cFirstDayInEnglish = oLocale.FirstDayOfWeek()

	aDaysInEnglish = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]
	n = find( aDaysInEnglish, cFirstDayInEnglish )

	aDaysInLocaleLanguage = [ _DayNameInLang(cLangName, n) ]

	for i = n + 1 to 7
		aDaysInLocaleLanguage + _DayNameInLang(cLangName, i)
	next

	for i = 1 to n - 1
		aDaysInLocaleLanguage + _DayNameInLang(cLangName, i)
	next

	return aDaysInLocaleLanguage

	func NamesOfDaysIn(pcLangOrCountry)
		return StzNamesOfDaysIn(pcLangOrCountry)

func StzNamesOfMonths()
	return StzNamesOfMonthsIn(:English)

	func NamesOfMonths()
		return StzNamesOfMonths()

func StzNamesOfMonthsIn(pcLangOrCountry)
	oLang = new stzString(pcLangOrCountry)
	aResult = []
	cLangName = :english

	if oLang.IsLanguageName()
		cLangName = pcLangOrCountry

	but oLang.IsCountryName()
		cLangName = StzCountryQ(pcLangOrCountry).Language()
	ok

	for i = 1 to 12
		aResult + _MonthNameInLang(cLangName, i)
	next

	return aResult

	func NamesOfMonthsIn(pcLangOrCountry)
		return StzNamesOfMonthsIn(pcLangOrCountry)

class stzLocale from stzObject
	@cAbbreviation
	@cLangAbbreviation
	@cScriptAbbreviation
	@cCountryAbbreviation

	  #---------#
	 #  INIT   #
	#---------#

	/*
	Initializes the stzLocale object using one of these methods:

		* by providing a locale string like "ar_TN" and "ar_Arab_TN"
		  (dash"-" separator also accepted)

		* by providing a [ :Language = ..., :Script = ..., Country = ... ]
		  locale identification list

		* by specifying a C locale (by providing a "C" string)

		* by specifying a system locale (by providing a :System string)

		* by scpecifying a default locale (by providing a :Default string)

		* bu providing a country name as a string
	*/

	def init(pLocale)

		if IsString(pLocale)
			if pLocale = :System or pLocale = :SystemLocale
				@cAbbreviation = "C"
				return

			but pLocale = :Default or pLocale = :DefaultLocale
				@cAbbreviation = _LocaleNormalizeAbbr(DefaultLocaleAbbreviation())
				return

			but StzStringQ(pLocale).IsCountryName()
				This.Init([ :Country = pLocale ])
				return

			but StzStringQ(pLocale).IsLanguageName()
				This.Init([ :Language = pLocale ])
				return

			else
				pLocale = StzReplace(pLocale, "_", "-")

				@cAbbreviation = _LocaleNormalizeAbbr(pLocale)

			ok

			pLocale = StzReplace(pLocale, "_", "-")
			oLocale = new stzString(pLocale)

			if oLocale.ContainsOneOccurrence("-")

				aParts = oLocale.Split("-")
				if StzStringQ(aParts[1]).IsLanguageAbbreviation()
					@cLangAbbreviation = aParts[1]

				but StzStringQ(aParts[1]).IsScriptAbbreviation()
					@cScriptAbbreviation = aParts[1]
				ok

				if StzStringQ(aParts[2]).IsScriptAbbreviation()
					@cScriptAbbreviation = aParts[2]

				but StzStringQ(aParts[2]).IsCountryAbbreviation()
					@cCountryAbbreviation = aParts[2]
				ok

			but oLocale.ContainsNTimes(2, "-")

				aParts =  oLocale.Split("-")
				if StzStringQ(aParts[1]).IsLanguageAbbreviation()
					@cLangAbbreviation = aParts[1]
				ok

				if StzStringQ(aParts[2]).IsScriptAbbreviation()
					@cScriptAbbreviation = aParts[2]
				ok

				if StzStringQ(aParts[3]).IsCountryAbbreviation()
					@cCountryAbbreviation = aParts[3]
				ok
			ok

		but IsList(pLocale)
			if NOT ( isList(pLocale) and IsLocaleList(pLocale) )

				StzRaise("Can't create the stzLocale object!")
			ok

			cLangName    = pLocale[ :Language ]
			cScriptName  = pLocale[ :Script   ]
			cCountryName = pLocale[ :Country  ]

			cLangAbbr    = NULL
			cScriptAbbr  = NULL
			cCountryAbbr = NULL

			if cLangName != NULL and StzStringQ(cLangName).IsLanguageName()
				cLangAbbr = StzLanguageQ(cLangName).Abbreviation()
			ok

			if cScriptName != NULL and StzStringQ(cScriptName).IsScriptName()
				cScriptAbbr = StzScriptQ(cScriptName).Abbreviation()
			ok

			if cCountryName != NULL and StzStringQ(cCountryName).IsCountryName()
				cCountryAbbr = StzCountryQ(cCountryName).Abbreviation()
			ok

			cAbbr = ""

			if AllOfTheseAreNotNull([ cLangAbbr, cScriptAbbr, cCountryAbbr ])
				cAbbr = cLangAbbr + "-" + cScriptAbbr + "-" + cCountryAbbr

			but cLangAbbr != NULL and BothAreNull(cScriptAbbr, cCountryAbbr)
				cAbbr = cLangAbbr

			but cScriptAbbr != NULL and BothAreNull(cLangAbbr, cCountryAbbr)
				cLangAbbr = StzScriptQ(cScriptAbbr).DefaultLanguageAbbreviation()
				cAbbr = cLangAbbr + "-" + cScriptAbbr

			but cCountryAbbr != NULL and BothAreNull(cLangAbbr, cScriptAbbr)
				cLangAbbr = StzCountryQ(cCountryAbbr).LanguageAbbreviation()
				cAbbr = cLangAbbr + "-" + cCountryAbbr

			but BothAreNotNull(cLangAbbr, cScriptAbbr) and cCountryAbbr = NULL
				cAbbr = cLangAbbr + "-" + cScriptAbbr

			but BothAreNotNull(cLangAbbr, cCountryAbbr) and cScriptAbbr = NULL
				cAbbr = cLangAbbr + "-" + cCountryAbbr

			but cLangAbbr = NULL and BothAreNotNull(cScriptAbbr, cCountryAbbr)
				cLangAbbr = StzCountryQ(cCountryAbbr).LanguageAbbreviation()
				cAbbr = cLangAbbr + "-" + cScriptAbbr + "-" + cCountryAbbr

			ok

			@cAbbreviation = _LocaleNormalizeAbbr(cAbbr)

			@cLangAbbreviation = cLangAbbr
			@cScriptAbbr = cScriptAbbr
			@cCountryAbbr = cCountryAbbr
		ok

	  #---------#
	 #  INFO   #
	#---------#

	# LOCALE ABBREVIATION

	def Abbreviation()
		return @cAbbreviation

	def Content()
		return This.Abbreviation()

		def Value()
			return Content()

	def bcp47Abbreviation()
		return StzReplace(@cAbbreviation, "_", "-")

	  #---------------#
	 #    COUNTRY    #
	#---------------#

	def CountryNumber()
		cCode = _LocaleCountryCodeFromAbbr(@cAbbreviation)
		if cCode != ""
			return _LocaleCountryNumber(cCode)
		ok
		return "0"

	def CountryAbbreviation()
		return This.CountryShortAbbreviation()

	def CountryShortAbbreviation()
		cCountryQtNumber = This.CountryNumber()

		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[1] = cCountryQtNumber
				return aCountryInfo[3]
			ok
		next

	def CountryLongAbbreviation()
		cCountryQtNumber = This.CountryNumber()

		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[1] = cCountryQtNumber
				return aCountryInfo[4]
			ok
		next

	def CountryPhoneCode()
		cCountry = This.CountryName()

		for aCountryInfo in LocaleCountriesXT()
			if StzLower(aCountryInfo[2]) = StzLower(cCountry)
				return aCountryInfo[5]
			ok
		next

	def CountryName()
		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[1] = This.CountryNumber()
				return aCountryInfo[2]
			ok
		next

		def Country()
			return This.CountryName()

	def CountryNativeName()
		return This.CountryName()

	  #-------------#
	 #  LANGUAGE   #
	#-------------#

	def LanguageNumber()
		cLangName = This.LanguageName()

		for aLangInfo in LocaleLanguagesXT()
			if StzLower(aLangInfo[2]) = StzLower(cLangName)
				return aLangInfo[1]
			ok
		next

	def LanguageName()
		cCountry = This.CountryName()
		if cCountry != ""
			return StzCountryQ(This.CountryName()).Language()
		ok

		def Language()
			return This.LanguageName()

		#-- @Misspelled

		def Langauge()
			return This.LanguageName()

	def LanguageNativeName()
		cLangCode = _LocaleLangCodeFromAbbr(@cAbbreviation)
		cNative = _LangNativeNameFromCode(cLangCode)
		if cNative != ""
			return cNative
		ok
		return This.LanguageName()


	def LanguageAbbreviation()
		return StzLanguageQ(This.Language()).Abbreviation()

	def LanguageShortAbbreviation()
		return StzLanguageQ(This.Language()).ShortAbbreviation()

	def LanguageLongAbbreviation()
		return StzLanguageQ(This.Language()).LongAbbreviation()

	  #-----------#
	 #  SCRIPT   #
	#-----------#

	def ScriptNumber()
		if @cScriptAbbreviation != NULL and @cScriptAbbreviation != ""
			return _LocaleQtScriptNumber(@cScriptAbbreviation)
		ok
		cLang = This.LanguageName()
		for aScriptInfo in LocaleScriptsXT()
			if StzLower(aScriptInfo[4]) = StzLower(cLang)
				return aScriptInfo[1]
			ok
		next
		return "0"

		def ScriptCode()
			return This.ScriptNumber()

	def ScriptName()
		return StzScriptQ(This.ScriptNumber()).Name()

	def Script()
		return This.ScriptName()

	def ScriptAbbreviation()
		cScriptNumber = This.ScriptNumber()
		for aScriptInfo in LocaleScriptsXT()
			if aScriptInfo[1] = cScriptNumber
				return aScriptInfo[3]
			ok
		next

	  #--------------#
	 #   CURRENCY   #
	#--------------#

	def CurrencyName()
		nLen = len(_aLocaleCountriesXT)
		cNumber = This.CountryNumber()

		for i = 1 to nLen

			if _aLocaleCountriesXT[i][1] = cNumber
				cTemp = StzReplace(_aLocaleCountriesXT[i][7], "_", " ")
				cResult = StzUpper(StzLeft(cTemp, 1)) + StzMid(cTemp, 2, StzLen(cTemp))
				return cResult
			ok
		next

		def Currency()
			return This.CurrencyName()

	def CurrencyNativeName()
		return This.pvtCurrencyXT(:NativeName)

	def CurrencyAbbreviation()
		return This.pvtCurrencyXT(:ISOSymbol)

	def CurrencyISOSymbol()
		return This.pvtCurrencyXT(:ISOSymbol)

	def CurrencySymbol()
		return This.pvtCurrencyXT(:NativeSymbol)

		def CurrencyNativeSymbol()
			return This.pvtCurrencyXT(:NativeSymbol)

	def CurrencyFractionalUnit()
		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[1] = This.CountryNumber()
				return aCountryInfo[8]
			ok
		next

		def CurrencyFraction()
			return This.CurrencyFractionalUnit()

	def CurrencyBase()
		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[1] = This.CountryNumber()
				return aCountryInfo[9]
			ok
		next

	def CurrencyInfo()
		aResult = [
			:Name = This.CurrencyName(),
			:NativeName = This.CurrencyNativeName(),

			:Abbreviation = This.CurrencyAbbreviation(),

			:Symbol = This.CurrencySymbol(),
			:NativeSymbol = This.CurrencyNativeSymbol(),
			:ISOSymbol = This.CurrencyISOSymbol(),

			:FractionalUnit = This.CurrencyFractionalUnit(),
			:Fraction = This.CurrencyFractionalUnit(),

			:Base = This.CurrencyBase()
		]

		return aResult

	def CurrencyXT(pcInfo)
		return This.CurrencyInfo()[StzLower(pcInfo)]

	  #-----------------------------#
	 #  LOCALISED TIME MANAGEMENT  #	#TODO :Should be used by default in
	#-----------------------------#		# formatting time in stzTime

	def amText()
		return StzEngineLocaleAMText()

	def pmText()
		return StzEngineLocalePMText()

	def TimeShortFormat()
		return This.TimeFormat(:Short)
		# You can get the list of supported types by using LocaleTimeFormatTypes()

	def TimeLongFormat()
		return This.TimeFormat(:Long)

	def TimeNarrowFormat()
		return This.TimeFormat(:Narrow)

	def TimeFormat(cType)
		/*
		cType can be:
			:Long (0)
			:Short (1)
			:Narrow (2)
		as defined in LocaleTimeFormatTypes()
		*/
		nType = LocaleTimeFormatTypes()[ cType ]
		return _LocaleTimeFormatStr(@cAbbreviation, nType)

	// Returns a stzTime object from the localised string cTime
	def ToStzTime(cTime)
		return new stzTime(cTime)
		/*
		TODO: Logical error. Returns a result that is insensitve to the locale
			o1 = new stzLocale("ru_RU") # Russian locale
			? o1.ToTimeAsString("05:08:34", :Long)

			Returns :
			5:08:34  Paris, Madrid (heure d'ete)

			This is sensitive to the system local on my machine ("fr_FR")
			and not to the russian locale!

		*/

	def ToTimeAsString(cTime, cFormat)
		/*
		cTime string should contain a time string conforming to the locale
		otherwise the method returns NULL

		To see what cFormat should contain, read the comments for the
		stzTime.ToString() method in stzTime class.
		*/
		switch cFormat
		on :Default		cFormat = $cDefaultTimeFormat
		on :Long		cFormat = This.TimeFormat(:Long)
		on :Short		cFormat = This.TimeFormat(:Short)
		on :Narrow		cFormat = This.TimeFormat(:Narrow)
		off

		return This.ToStzTime(cTime).ToString(:Default)
		#       --------v-----------	       ---v---
		#         stzTime object              "hh:mm:ss"

	def ToTimeAsLongString(cTime)
		return This.ToTimeAsString(cTime, :Long)

	def ToTimeAsShortString(cTime)
		return This.ToTimeAsString(cTime, :Short)

	def ToTimeAsNarrowString(cTime)
		return This.ToTimeAsString(cTime, :Narrow)

	  #---------#
	 #   DAY   #
	#---------#

	def DaysOfWeek()	# In english

		# Let's define the 1st of week in this locale

		cFirstDayInEnglish = This.FirstDayOfWeek()
		aDaysInEnglish = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]
		n = StzFind( aDaysInEnglish, cFirstDayInEnglish )

		# We need to get that 1st day in native language of the locale

		aResult = [ cFirstDayInEnglish ]

		# And then compose the days starting from that 1st day

		for i = n + 1 to 7

			aResult + aDaysInEnglish[i]
		next

		for i = 1 to n - 1
			aResult + aDaysInEnglish[i]
		next

		return aResult

	#---

	def NativeDaysOfWeek()
		cFirstDayInEnglish = This.FirstDayOfWeek()
		aDaysInEnglish = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]
		n = StzFind( aDaysInEnglish, cFirstDayInEnglish )

		cLang = This.LanguageName()

		aDaysInLocaleLanguage = [ _DayNameInLang(cLang, n) ]

		for i = n + 1 to 7
			aDaysInLocaleLanguage + _DayNameInLang(cLang, i)
		next

		for i = 1 to n - 1
			aDaysInLocaleLanguage + _DayNameInLang(cLang, i)
		next

		return aDaysInLocaleLanguage

	def NthDayOfWeek(n)
		/*
		FYI: read this discussion about the week having 5 days in Javaneese:
		https://bit.ly/2U5oTAh
		*/

		nNthDay = 0
		if 0 < n and n < 8
			nFirstDayOfWeek = _LocaleFirstDayNumber(@cAbbreviation)
			nTemp = nFirstDayOfWeek + (n-1)

			if n != 1
				for i = nFirstDayOfWeek to nTemp

					nNthDay++
					if nNthDay = 8
						nNthDay = 1
					ok
				next
				nNthDay--
			else
				nNthDay = nFirstDayOfWeek + n - 1
			ok

			return DefaultDaysOfWeek()[""+ nNthDay ]
		else
			StzRaise(stzLocaleError(:CanNotDefineNthDayOfWeek))
		ok

	def FirstDayOfWeek()
		return This.NthDayOfWeek(1)

	def LastDayOfWeek()
		return This.NthDayOfWeek(7)

	def NthNativeDayOfWeek(n)
		return This.NativeDaysOfWeek()[n]

		def NativeNthDayOfWeek(n)
			return This.NthNativeDayOfWeek(n)

	def FirstNativeDayOfWeek()
		return This.NthNativeDayOfWeek(1)

		def NativeFirstDayOfWeek()
			return This.FirstNativeDayOfWeek()

	def LastNativeDayOfWeek()
		return This.NthNativeDayOfWeek(7)

		def NativeLastDayOfWeek()
			return This.LastNativeDayOfWeek()

	#---

	def NthDayOfWeekAbbreviation(n)
		cFirstDay = This.FirstDayOfWeek()
		aDaysInEnglish = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]

		nFirst = StzFind( aDaysInEnglish, cFirstDay )

		nDay = nFirst + n - 1
		if nDay > 7 nDay = nDay - 7 ok
		return _DayAbbrInLang(:english, nDay)

	def NthDayOfWeekNativeAbbreviation(n)
		cLang = This.LanguageName()
		return _DayAbbrInLang(cLang, n)

		def NativeNthDayOfWeekAbbreviation(n)
			return This.NthDayOfWeekNativeAbbreviation(n)

	def FirstDayOfWeekAbbreviation()
		return This.NthDayOfWeekAbbreviation(1)

	def FirstNativeDayOfWeekAbbreviation()
		return This.NthDayOfWeekNativeAbbreviation(1)

		def NativeFirstDayOfWeekAbbreviation()
			return This.FirstNativeDayOfWeekAbbreviation()

	def LastDayOfWeekAbbreviation()
		return This.NthDayOfWeekAbbreviation(7)

	def LastNativeDayOfWeekAbbreviation()
		return This.NthDayOfWeekNativeAbbreviation(7)

		def NativeLastDayOfWeekAbbreviation()
			return This.LastNativeDayOfWeekAbbreviation()

	#---

	// Day symbols are a narrow form (usually one letter) used
	// when you need to enumerate weekdays

	def NthDayOfWeekSymbol(n)
		cFirstDay = This.FirstDayOfWeek()
		aDaysInEnglish = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]

		nFirst = StzFind( aDaysInEnglish, cFirstDay )

		nDay = nFirst + n - 1
		if nDay > 7 nDay = nDay - 7 ok
		return _DaySymbolInLang(:english, nDay)

	def NthDayOfWeekNativeSymbol(n)
		cLang = This.LanguageName()
		return _DaySymbolInLang(cLang, n)

		def NativeNthDayOfWeekSymbol(n)
			return This.NthDayOfWeekNativeSymbol(n)

	def FirstDayOfWeekSymbol()
		return This.NthDayOfWeekSymbol(1)

	def FirstDayOfWeekNativeSymbol()
		return This.NthDayOfWeekNativeSymbol(1)

		def NativeFirstDayOfWeekSymbol()
			return This.FirstDayOfWeekNativeSymbol()

	def LastDayOfWeekSymbol()
		return This.NthDayOfWeekSymbol(7)

	def LastDayOfWeekNativeSymbol()
		return This.NthDayOfWeekNativeSymbol(7)

		def NativeLastDayOfWeekSymbol()
			return This.LastDayOfWeekNativeSymbol()

	  #-----------#
	 #   MONTH   #TODO
	#-----------#


	  #----------------#
	 #  NUMBER FORM   #	#TODO: Should be used by default in
	#----------------#	# formatting numbers in stzNumber

	def DecimalPoint()
		return _LocaleDecimalPointChar(@cAbbreviation)

	def Exponential()
		return "e"

	def GroupSeparator()
		return _LocaleGroupSepChar(@cAbbreviation)

		def GroupSeperator()
			return This.GroupSeparator()

	def NegativeSign()
		return "-"

	def PositiveSign()
		return "+"

	def Percent()
		return "%"

	  #-----------------------#
	 #   STRING LOWER CASE   #
	#-----------------------#

	/*
	TODO: Check if these special cases documented by Unicode standard
	are already supported by the engine:
	--> http://unicode.org/Public/UNIDATA/SpecialCasing.txt
	*/

	def StringLowercased(pcStr)
		cResult = StzEngineLocaleToLower(pcStr)
		return cResult

		def ToLowercase(pcStr)
			return This.StringLowercased(pcStr)

	def CharLowercased(pcChar)
		if @IsChar(pcChar)
			return This.StringLowercased(pcChar)
		ok

	def StringIsLowercased(pcStr)
		return This.StringLowercased(pcStr) = pcStr

		def StringIsLowercase(pcStr)
			return This.StringIsLowercased(pcStr)

	def CharIsLowercased(pcChar)
		if @IsChar(pcChar)
			return This.StringIsLowercased(pcChar)
		ok

	  #-----------------------#
	 #   STRING UPPER CASE   #
	#-----------------------#
	# --? TODO: support the special cases documented in unicode here:
	# http://unicode.org/Public/UNIDATA/SpecialCasing.txt

	def StringUppercased(pcStr)
		cResult = StzEngineLocaleToUpper(pcStr)
		return cResult

		def ToUppercase(pcStr)
			return This.StringUppercased(pcStr)

	def CharUppercased(pcChar)
		if @IsChar(pcChar)
			return This.StringUppercased(pcChar)
		ok

	def StringIsUppercased(pcStr)
		return This.StringUppercased(pcStr) = pcStr

		def StringIsUppercase(pcStr)
			return This.StringIsUppercased(pcStr)

	def CharIsUppercased(pcChar)
		if @IsChar(pcChar)
			return This.StringIsUppercased(pcChar)
		ok

	  #-----------------------#
	 #   STRING TITLE CASE   #
	#-----------------------#

	def StringTitlecased(pcStr)
		if StzTextQ(pcStr).IsLatinScript()

			if This.Language() = :English

				# In english, every word is capitalized in its first letter
				#NOTE: we are implementing the simplified variant of titlecase
				# (also knowan as start case).

				#TODO: Implement the various styles documented in this
				# Wikipedia article: https://en.wikipedia.org/wiki/Title_case

				# Example:

				# "in search of lost time" becomes
				# "In Search Of Lost Time"

				return This.StringCapitalised(pcStr)

			else // Including  This.Language() = :French

				# In french a title is capitalised at the beginning
				# of the sentence. See this example:

				# "a la recherche du temps perdu" becomes
				# "A la Recherche du temps perdu"

				oStr = new stzString(pcStr)
				nLen = oStr.NumberOfChars()
				cResult = This.ToUppercase( oStr.Char(1) ) +
					  This.ToLowercase( oStr.Section(2,nLen) )
			ok

			return cResult
		ok

		def ToTitleCase(pcStr)
			return StringTitlecased(pcStr)

	def StringIsTitlecased(pcStr)
		return This.StringTitlecased(pcStr) = pcStr

		def StringIsTitlecase(pcStr)
			return This.StringIsTitlecased(pcStr)

	  #----------------------#
	 #   STRING FOLD CASE   #
	#----------------------#

	def StringFoldcased(pcStr)
		// TODO

		def ToFoldcase(pcStr)
			return This.StringFoldcased(pcStr)

	def CharFoldcased(pcChar)
		if @IsChar(pcChar)
			return This.StringFoldcased(pcChar)
		ok

	def StringIsfoldcased(pcStr)
		return This.Stringfoldcased(pcStr) = pcStr

		def StringIsFoldcase(pcStr)
			return This.StringIsFoldcased(pcStr)

	def CharIsFoldcased(pcChar)
		if @IsChar(pcChar)
			return This.StringIsFoldcased(pcChar)
		ok

	  #-------------------------#
	 #   STRING CAPITAL CASE   #
	#-------------------------#

	def StringCapitalcased(pcStr)

		# Lowercasing all the string first

		oStr = StzStringQ(pcStr).LowercaseQ()

		# Getting the positions of the words in the string
		#TODO: delegate the work to stzText when ready

		anPos = oStr.FindAll(" ")
		if len(anPos) = 0
			anPos = [1]

		else
			anPos = StzListOfNumbersQ(anPos).AddedToEach(1)
			ring_insert(anPos, 1, 1)
			anPos = new stzList(anPos).Sorted()
		ok

		nLen = len(anPos)

		//for n in anPos
		for i = 1 to nLen
			cCapitalizedChar = oStr.CharAtPositionQ(anPos[i]).Uppercased()
			oStr.ReplaceCharAtPosition(anPos[i], cCapitalizedChar)
		next

		return oStr.Content()

		#< @FunctionAlternativeFormForms

		def toCapitalcase(pcStr)
			return This.StringCapitalcased(pcStr)

		def StringCapitalised(pcStr)
			return This.StringCapitalcased(pcStr)

		def StringCapitalized(pcStr)
			return This.StringCapitalcased(pcStr)

		#>

	def StringIsCapitalised(pcStr)
		return This.StringCapitalised(pcStr) = pcStr

		def StringIsCapitalized(pcStr)
			return This.StringIsCapitalised(pcStr)

		def StringIsCapitalcased(pcStr)
			return This.StringIsCapitalised(pcStr)

		def StringIsCapitalcase(pcStr)
			return This.StringIsCapitalised(pcStr)

	  #-----------------------#
	 #  MEASUREMENT SYSTEM   #
	#-----------------------#

	def MeasurementSystem()
		return StzLocaleMeasurementSystems()[ _LocaleMeasurementSysNum(@cAbbreviation) ]

	PRIVATE

	def pvtCurrencyXT(pcTypeOfSymbol)
		cCurrencyName = ""
		nLen = len(_aLocaleCountriesXT)
		cNumber = This.CountryNumber()
		for i = 1 to nLen
			if _aLocaleCountriesXT[i][1] = cNumber
				cCurrencyName = _aLocaleCountriesXT[i][7]
				exit
			ok
		next

		switch pcTypeOfSymbol
		on :ISOSymbol
			return _CurrencyISOCode(cCurrencyName)

		on :NativeSymbol
			return _CurrencyNativeSymbol(cCurrencyName)

		on :NativeName
			cResult = StzReplace(cCurrencyName, "_", " ")
			return cResult

		other
			StzRaise(stzLocaleError(:CanNotProvideCurrencySymbol))
		off
