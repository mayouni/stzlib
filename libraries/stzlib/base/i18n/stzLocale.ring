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

# -- Locale helper data tables --

$_aDayNamesPerLang = [
	[:english,    ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]],
	[:french,     ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]],
	[:arabic,     ["الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت", "الأحد"]],
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

# Globals lifted ABOVE the first func -- Ring otherwise silently
# never assigns when declared below a func/class.
$cStzDefaultLocale = "en-US"

# Pure Ring locale helper functions

# Default-locale accessors used by narrative tests.
func DefaultLocaleAbbreviation()
	return $cStzDefaultLocale

func DefaultLocale()
	return $cStzDefaultLocale

func CurrentLocale()
	return $cStzDefaultLocale

func SetDefaultLocale(pcLocaleAbbr)
	$cStzDefaultLocale = pcLocaleAbbr

func SetCurrentLocale(pcLocaleAbbr)
	$cStzDefaultLocale = pcLocaleAbbr

func _LocaleLangCodeFromAbbr(_cLocaleAbbr_)
	_cLocaleAbbr_ = StzReplace(_cLocaleAbbr_, "-", "_")
	_nPos_ = StzFindFirst(_cLocaleAbbr_, "_")
	if _nPos_ > 0
		return StzLower(StzLeft(_cLocaleAbbr_, _nPos_ - 1))
	ok
	return StzLower(_cLocaleAbbr_)

func _LocaleCountryCodeFromAbbr(_cLocaleAbbr_)
	_cLocaleAbbr_ = StzReplace(_cLocaleAbbr_, "-", "_")
	_nPos_ = StzFindFirst(_cLocaleAbbr_, "_")
	if _nPos_ > 0
		_cRest_ = StzMid(_cLocaleAbbr_, _nPos_ + 1, StzLen(_cLocaleAbbr_))
		_nPos2_ = StzFindFirst(_cRest_, "_")
		if _nPos2_ > 0
			return StzUpper(StzMid(_cRest_, _nPos2_ + 1, StzLen(_cRest_)))
		ok
		if StzLen(_cRest_) <= 3 and isalpha(StzLeft(_cRest_, 1))
			return StzUpper(_cRest_)
		ok
	ok
	return ""

func _LocaleNormalizeAbbr(_cInput_)
	if _cInput_ = NULL or _cInput_ = "" or _cInput_ = "C"
		return "C"
	ok
	_cInput_ = StzReplace(_cInput_, "-", "_")
	_nPos_ = StzFindFirst(_cInput_, "_")
	if _nPos_ > 0
		_cLang_ = StzLower(StzLeft(_cInput_, _nPos_ - 1))
		_cRest_ = StzUpper(StzMid(_cInput_, _nPos_ + 1, StzLen(_cInput_)))
		return _cLang_ + "_" + _cRest_
	ok
	_cLang_ = StzLower(_cInput_)
	_nLen_ = len($aLocaleLanguagesXT)
	for i = 1 to _nLen_
		if StzLower($aLocaleLanguagesXT[i][3]) = _cLang_
			if $aLocaleLanguagesXT[i][5] != NULL
				_cCountryName_ = $aLocaleLanguagesXT[i][5]
				_nLen2_ = len(_aLocaleCountriesXT)
				for j = 1 to _nLen2_
					if StzLower(_aLocaleCountriesXT[j][2]) = StzLower(_cCountryName_)
						return _cLang_ + "_" + _aLocaleCountriesXT[j][3]
					ok
				next
			ok
			return _cLang_
		ok
	next
	return _cInput_

func _LocaleCountryNumber(cCountryCode)
	_cCode_ = StzUpper(cCountryCode)
	_nLen_ = len(_aLocaleCountriesXT)
	for i = 1 to _nLen_
		if StzUpper(_aLocaleCountriesXT[i][3]) = _cCode_
			return _aLocaleCountriesXT[i][1]
		ok
	next
	return "0"

func _LocaleQtScriptNumber(cScriptCode)
	_nLen_ = len(_aLocaleScriptsXT)
	for i = 1 to _nLen_
		if StzUpper(_aLocaleScriptsXT[i][3]) = StzUpper(cScriptCode)
			return _aLocaleScriptsXT[i][1]
		ok
	next
	return "0"

func _LocaleFirstDayNumber(_cLocaleAbbr_)
	_cCountry_ = StzUpper(_LocaleCountryCodeFromAbbr(_cLocaleAbbr_))
	_aSatFirst_ = ["AF", "IR"]
	_aSunFirst_ = ["US", "CA", "JP", "CN", "IL", "KR", "TW", "PH", "BR", "IN",
	             "CO", "MX", "AU", "NZ", "SG", "ZA", "GT", "HN", "SV", "NI",
	             "DO", "HT", "PR", "BS", "JM", "TT", "BB", "LC", "VC", "GD",
	             "AG", "DM", "KN", "BZ", "GY", "PA", "PE", "PY", "VE"]
	_nSatFirst1Len_ = len(_aSatFirst_)
	for _iLoopSatFirst1_ = 1 to _nSatFirst1Len_
		_c_ = _aSatFirst_[_iLoopSatFirst1_]
		if _cCountry_ = _c_ return 6 ok
	next
	_nSunFirst1Len_ = len(_aSunFirst_)
	for _iLoopSunFirst1_ = 1 to _nSunFirst1Len_
		_c_ = _aSunFirst_[_iLoopSunFirst1_]
		if _cCountry_ = _c_ return 7 ok
	next
	return 1

func _LocaleDecimalPointChar(_cLocaleAbbr_)
	_cLang_ = _LocaleLangCodeFromAbbr(_cLocaleAbbr_)
	_aCommaDec_ = ["fr", "de", "es", "pt", "it", "nl", "ru", "pl", "cs", "sk",
	             "sv", "fi", "da", "nb", "nn", "ro", "hu", "hr", "sr", "sl",
	             "bg", "uk", "be", "el", "tr", "vi", "id", "ca", "gl", "eu"]
	_nCommaDec1Len_ = len(_aCommaDec_)
	for _iLoopCommaDec1_ = 1 to _nCommaDec1Len_
		_c_ = _aCommaDec_[_iLoopCommaDec1_]
		if _cLang_ = _c_ return "," ok
	next
	return "."

func _LocaleGroupSepChar(_cLocaleAbbr_)
	_cLang_ = _LocaleLangCodeFromAbbr(_cLocaleAbbr_)
	_aSpaceGroup_ = ["fr", "sv", "fi", "pl", "cs", "sk", "nb", "nn", "da",
	               "ru", "uk", "be", "bg"]
	_nSpaceGroup1Len_ = len(_aSpaceGroup_)
	for _iLoopSpaceGroup1_ = 1 to _nSpaceGroup1Len_
		_c_ = _aSpaceGroup_[_iLoopSpaceGroup1_]
		if _cLang_ = _c_ return " " ok
	next
	_aPeriodGroup_ = ["de", "es", "pt", "it", "nl", "ro", "hu", "hr", "sr",
	                "sl", "el", "tr", "vi", "id", "ca", "gl", "eu"]
	_nPeriodGroup1Len_ = len(_aPeriodGroup_)
	for _iLoopPeriodGroup1_ = 1 to _nPeriodGroup1Len_
		_c_ = _aPeriodGroup_[_iLoopPeriodGroup1_]
		if _cLang_ = _c_ return "." ok
	next
	return ","

func _LocaleMeasurementSysNum(_cLocaleAbbr_)
	_cCountry_ = StzUpper(_LocaleCountryCodeFromAbbr(_cLocaleAbbr_))
	if _cCountry_ = "US" or _cCountry_ = "LR" or _cCountry_ = "MM"
		return "1"
	ok
	if _cCountry_ = "GB"
		return "2"
	ok
	return "0"

func _LocaleTimeFormatStr(_cLocaleAbbr_, _nType_)
	_cCountry_ = StzUpper(_LocaleCountryCodeFromAbbr(_cLocaleAbbr_))
	_cLang_ = _LocaleLangCodeFromAbbr(_cLocaleAbbr_)
	if _nType_ = 1 or _nType_ = 2
		if _cCountry_ = "US" or (_cLang_ = "en" and _cCountry_ = "")
			return "h:mm AP"
		ok
		return "HH:mm"
	ok
	if _cCountry_ = "US" or (_cLang_ = "en" and _cCountry_ = "")
		return "h:mm:ss AP t"
	ok
	return "HH:mm:ss t"

func _CurrencyISOCode(_cCurrencyName_)
	_cName_ = StzLower(_cCurrencyName_)
	_nLen_ = len($_aCurrencyISOData)
	for i = 1 to _nLen_
		if StzLower($_aCurrencyISOData[i][1]) = _cName_
			return $_aCurrencyISOData[i][2]
		ok
	next
	return ""

func _CurrencyNativeSymbol(_cCurrencyName_)
	_cName_ = StzLower(_cCurrencyName_)
	_nLen_ = len($_aCurrencyISOData)
	for i = 1 to _nLen_
		if StzLower($_aCurrencyISOData[i][1]) = _cName_
			return $_aCurrencyISOData[i][3]
		ok
	next
	return ""

func _DayNameInLang(_cLangName_, _nDay_)
	_cLang_ = StzLower(_cLangName_)
	_nLen_ = len($_aDayNamesPerLang)
	for i = 1 to _nLen_
		if StzLower($_aDayNamesPerLang[i][1]) = _cLang_
			if _nDay_ >= 1 and _nDay_ <= 7
				return $_aDayNamesPerLang[i][2][_nDay_]
			ok
		ok
	next
	if _nDay_ >= 1 and _nDay_ <= 7
		return $_aDayNamesPerLang[1][2][_nDay_]
	ok
	return ""

func _DayAbbrInLang(_cLangName_, _nDay_)
	_cFullName_ = _DayNameInLang(_cLangName_, _nDay_)
	if StzLen(_cFullName_) >= 3
		return StzLeft(_cFullName_, 3)
	ok
	return _cFullName_

func _DaySymbolInLang(_cLangName_, _nDay_)
	_cFullName_ = _DayNameInLang(_cLangName_, _nDay_)
	if StzLen(_cFullName_) >= 1
		return StzLeft(_cFullName_, 1)
	ok
	return ""

func _MonthNameInLang(_cLangName_, nMonth)
	_cLang_ = StzLower(_cLangName_)
	_nLen_ = len($_aMonthNamesPerLang)
	for i = 1 to _nLen_
		if StzLower($_aMonthNamesPerLang[i][1]) = _cLang_
			if nMonth >= 1 and nMonth <= 12
				return $_aMonthNamesPerLang[i][2][nMonth]
			ok
		ok
	next
	if nMonth >= 1 and nMonth <= 12
		return $_aMonthNamesPerLang[1][2][nMonth]
	ok
	return ""

func _LangNameFromCode(_cLangCode_)
	_cCode_ = StzLower(_cLangCode_)
	_nLen_ = len($aLocaleLanguagesXT)
	for i = 1 to _nLen_
		if StzLower($aLocaleLanguagesXT[i][3]) = _cCode_
			return $aLocaleLanguagesXT[i][2]
		ok
	next
	return :english

func _LangNativeNameFromCode(_cLangCode_)
	_cCode_ = StzLower(_cLangCode_)
	_nLen_ = len($aLocaleLanguagesXT)
	for i = 1 to _nLen_
		if StzLower($aLocaleLanguagesXT[i][3]) = _cCode_
			return $aLocaleLanguagesXT[i][6]
		ok
	next
	return ""

# -- Top-level functions --

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

func StzEngineDayName(_nDay_)
	return StzEngineLocaleDayName(_nDay_)

func StzEngineDayAbbr(_nDay_)
	return StzEngineLocaleDayAbbr(_nDay_)

func StzLocaleToTitlecase(cStr)
	return StzEngineLocaleToTitlecase(cStr)

func StzLocaleAbbreviationsXT()
	return _aLocaleAbbreviationsXT

	func LocaleAbbreviationsXT()
		return StzLocaleAbbreviationsXT()

func StzLocaleAbbreviations()
	_aResult_ = []

	_aStzLocaleAbbreviationsXT1_ = StzLocaleAbbreviationsXT()
	_nStzLocaleAbbreviationsXT1Len_ = len(_aStzLocaleAbbreviationsXT1_)
	for _iLoopStzLocaleAbbreviationsXT1_ = 1 to _nStzLocaleAbbreviationsXT1Len_
		_acountry_ = _aStzLocaleAbbreviationsXT1_[_iLoopStzLocaleAbbreviationsXT1_]
		_aCountry21_ = _acountry_[2]
		_nCountry21Len_ = len(_aCountry21_)
		for _iLoopCountry21_ = 1 to _nCountry21Len_
			_aLanguage_ = _aCountry21_[_iLoopCountry21_]
			_nLanguage1Len_ = len(_aLanguage_)
			for _iLoopLanguage1_ = 1 to _nLanguage1Len_
				_aLocale_ = _aLanguage_[_iLoopLanguage1_]
				_aResult_ + _aLocale_[2]
			next
		next
	next

	return _aResult_

	func LocaleAbbreviations()
		return StzLocaleAbbreviations()

func StzLocaleAbbreviationsAsString()
	return _cLocaleAbbreviations

	func LocaleAbbreviationsAsString()
		return StzLocaleAbbreviationsAsString()

	func LocaleAbbreviationsHostedInString()
		return StzLocaleAbbreviationsAsString()

func StzLanguagesAndTheirDefaultCountries()
	_aResult_ = []
	_aLocaleLanguagesXT3_ = LocaleLanguagesXT()
	_nLocaleLanguagesXT3Len_ = len(_aLocaleLanguagesXT3_)
	for _iLoopLocaleLanguagesXT3_ = 1 to _nLocaleLanguagesXT3Len_
		_aLangInfo_ = _aLocaleLanguagesXT3_[_iLoopLocaleLanguagesXT3_]
		_aResult_ + [ _aLangInfo_[2], _aLangInfo_[5] ]
	next
	return _aResult_

	func LanguagesAndTheirDefaultCountries()
		return StzLanguagesAndTheirDefaultCountries()

func StzLanguagesforWhichDefaultCountryIs(cCountryCode)
	_aResult_ = []
	_cCountryName_ = StzCountryQ(cCountryCode).Name()
	_aLocaleLanguagesXT2_ = LocaleLanguagesXT()
	_nLocaleLanguagesXT2Len_ = len(_aLocaleLanguagesXT2_)
	for _iLoopLocaleLanguagesXT2_ = 1 to _nLocaleLanguagesXT2Len_
		_aLangInfo_ = _aLocaleLanguagesXT2_[_iLoopLocaleLanguagesXT2_]
		if StzLower(_aLangInfo_[5]) = StzLower(_cCountryName_)
			_aResult_ + _aLangInfo_[2]
		ok
	next
	return _aResult_

	func LanguagesforWhichDefaultCountryIs(cCountryCode)
		return StzLanguagesforWhichDefaultCountryIs(cCountryCode)

func StzScriptsAndTheirDefaultLanguages()
	_aResult_ = []
	_aLocaleScriptsXT4_ = LocaleScriptsXT()
	_nLocaleScriptsXT4Len_ = len(_aLocaleScriptsXT4_)
	for _iLoopLocaleScriptsXT4_ = 1 to _nLocaleScriptsXT4Len_
		_aScriptInfo_ = _aLocaleScriptsXT4_[_iLoopLocaleScriptsXT4_]
		_aResult_ + [ _aScriptInfo_[2], DefaultLanguageForScript(_aScriptInfo_[2]) ]
	next
	return _aResult_

	func ScriptsAndTheirDefaultLanguages()
		return StzScriptsAndTheirDefaultLanguages()

func StzScriptsforWhichDefaultLanguageIs(_cLangCode_)
	_aResult_ = []
	_cLangName_ = StzLanguageQ(_cLangCode_).Name()
	_aLocaleScriptsXT3_ = LocaleScriptsXT()
	_nLocaleScriptsXT3Len_ = len(_aLocaleScriptsXT3_)
	for _iLoopLocaleScriptsXT3_ = 1 to _nLocaleScriptsXT3Len_
		_aScriptInfo_ = _aLocaleScriptsXT3_[_iLoopLocaleScriptsXT3_]
		if StzLower(_aScriptInfo_[4]) = StzLower(_cLangName_)
			_aResult_ + _aScriptInfo_[2]
		ok
	next
	return _aResult_

	func ScriptsforWhichDefaultLanguageIs(_cLangCode_)
		return StzScriptsforWhichDefaultLanguageIs(_cLangCode_)

func StzLocaleMeasurementSystems()
	return _aLocaleMeasurementsystems

	func LocaleMeasurementSystems()
		return StzLocaleMeasurementSystems()

func StzNamesOfDays()
	return StzNamesOfDaysIn(:English)

	func NamesOfDays()
		return StzNamesOfDays()

func StzNamesOfDaysIn(pcLangOrCountry)

	_aResult_ = []
	_cLangName_ = :english

	if _(pcLangOrCountry).Q.IsLanguageName()
		_cLangName_ = pcLangOrCountry
		_oLocale_ = StzLocaleQ([ :Language = pcLangOrCountry ])

	but _(pcLangOrCountry).Q.IsCountryName()
		_cLangName_ = StzCountryQ(pcLangOrCountry).Language()
		_oLocale_ = StzLocaleQ([ :Country = pcLangOrCountry ])
	else
		_oLocale_ = StzLocaleQ("C")
	ok

	_cFirstDayInEnglish_ = _oLocale_.FirstDayOfWeek()

	_aDaysInEnglish_ = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]
	_n_ = find( _aDaysInEnglish_, _cFirstDayInEnglish_ )

	_aDaysInLocaleLanguage_ = [ _DayNameInLang(_cLangName_, _n_) ]

	for i = _n_ + 1 to 7
		_aDaysInLocaleLanguage_ + _DayNameInLang(_cLangName_, i)
	next

	for i = 1 to _n_ - 1
		_aDaysInLocaleLanguage_ + _DayNameInLang(_cLangName_, i)
	next

	return _aDaysInLocaleLanguage_

	func NamesOfDaysIn(pcLangOrCountry)
		return StzNamesOfDaysIn(pcLangOrCountry)

func StzNamesOfMonths()
	return StzNamesOfMonthsIn(:English)

	func NamesOfMonths()
		return StzNamesOfMonths()

func StzNamesOfMonthsIn(pcLangOrCountry)
	_oLang_ = new stzString(pcLangOrCountry)
	_aResult_ = []
	_cLangName_ = :english

	if _oLang_.IsLanguageName()
		_cLangName_ = pcLangOrCountry

	but _oLang_.IsCountryName()
		_cLangName_ = StzCountryQ(pcLangOrCountry).Language()
	ok

	for i = 1 to 12
		_aResult_ + _MonthNameInLang(_cLangName_, i)
	next

	return _aResult_

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

		* by specifying a _c_ locale (by providing a "C" string)

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
			_oLocale_ = new stzString(pLocale)

			if _oLocale_.ContainsOneOccurrence("-")

				_aParts_ = _oLocale_.Split("-")
				if StzStringQ(_aParts_[1]).IsLanguageAbbreviation()
					@cLangAbbreviation = _aParts_[1]

				but StzStringQ(_aParts_[1]).IsScriptAbbreviation()
					@cScriptAbbreviation = _aParts_[1]
				ok

				if StzStringQ(_aParts_[2]).IsScriptAbbreviation()
					@cScriptAbbreviation = _aParts_[2]

				but StzStringQ(_aParts_[2]).IsCountryAbbreviation()
					@cCountryAbbreviation = _aParts_[2]
				ok

			but _oLocale_.ContainsNTimes(2, "-")

				_aParts_ =  _oLocale_.Split("-")
				if StzStringQ(_aParts_[1]).IsLanguageAbbreviation()
					@cLangAbbreviation = _aParts_[1]
				ok

				if StzStringQ(_aParts_[2]).IsScriptAbbreviation()
					@cScriptAbbreviation = _aParts_[2]
				ok

				if StzStringQ(_aParts_[3]).IsCountryAbbreviation()
					@cCountryAbbreviation = _aParts_[3]
				ok
			ok

		but IsList(pLocale)
			if NOT ( isList(pLocale) and IsLocaleList(pLocale) )

				StzRaise("Can't create the stzLocale object!")
			ok

			_cLangName_    = pLocale[ :Language ]
			_cScriptName_  = pLocale[ :Script   ]
			_cCountryName_ = pLocale[ :Country  ]

			_cLangAbbr_    = NULL
			_cScriptAbbr_  = NULL
			_cCountryAbbr_ = NULL

			if _cLangName_ != NULL and StzStringQ(_cLangName_).IsLanguageName()
				_cLangAbbr_ = StzLanguageQ(_cLangName_).Abbreviation()
			ok

			if _cScriptName_ != NULL and StzStringQ(_cScriptName_).IsScriptName()
				_cScriptAbbr_ = StzScriptQ(_cScriptName_).Abbreviation()
			ok

			if _cCountryName_ != NULL and StzStringQ(_cCountryName_).IsCountryName()
				_cCountryAbbr_ = StzCountryQ(_cCountryName_).Abbreviation()
			ok

			_cAbbr_ = ""

			if AllOfTheseAreNotNull([ _cLangAbbr_, _cScriptAbbr_, _cCountryAbbr_ ])
				_cAbbr_ = _cLangAbbr_ + "-" + _cScriptAbbr_ + "-" + _cCountryAbbr_

			but _cLangAbbr_ != NULL and BothAreNull(_cScriptAbbr_, _cCountryAbbr_)
				_cAbbr_ = _cLangAbbr_

			but _cScriptAbbr_ != NULL and BothAreNull(_cLangAbbr_, _cCountryAbbr_)
				_cLangAbbr_ = StzScriptQ(_cScriptAbbr_).DefaultLanguageAbbreviation()
				_cAbbr_ = _cLangAbbr_ + "-" + _cScriptAbbr_

			but _cCountryAbbr_ != NULL and BothAreNull(_cLangAbbr_, _cScriptAbbr_)
				_cLangAbbr_ = StzCountryQ(_cCountryAbbr_).LanguageAbbreviation()
				_cAbbr_ = _cLangAbbr_ + "-" + _cCountryAbbr_

			but BothAreNotNull(_cLangAbbr_, _cScriptAbbr_) and _cCountryAbbr_ = NULL
				_cAbbr_ = _cLangAbbr_ + "-" + _cScriptAbbr_

			but BothAreNotNull(_cLangAbbr_, _cCountryAbbr_) and _cScriptAbbr_ = NULL
				_cAbbr_ = _cLangAbbr_ + "-" + _cCountryAbbr_

			but _cLangAbbr_ = NULL and BothAreNotNull(_cScriptAbbr_, _cCountryAbbr_)
				_cLangAbbr_ = StzCountryQ(_cCountryAbbr_).LanguageAbbreviation()
				_cAbbr_ = _cLangAbbr_ + "-" + _cScriptAbbr_ + "-" + _cCountryAbbr_

			ok

			@cAbbreviation = _LocaleNormalizeAbbr(_cAbbr_)

			@cLangAbbreviation = _cLangAbbr_
			@cScriptAbbr = _cScriptAbbr_
			@cCountryAbbr = _cCountryAbbr_
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
		_cCode_ = _LocaleCountryCodeFromAbbr(@cAbbreviation)
		if _cCode_ != ""
			return _LocaleCountryNumber(_cCode_)
		ok
		return "0"

	def CountryAbbreviation()
		return This.CountryShortAbbreviation()

	def CountryShortAbbreviation()
		_cCountryQtNumber_ = This.CountryNumber()

		_aLocaleCountriesXT6_ = LocaleCountriesXT()
		_nLocaleCountriesXT6Len_ = len(_aLocaleCountriesXT6_)
		for _iLoopLocaleCountriesXT6_ = 1 to _nLocaleCountriesXT6Len_
			_aCountryInfo_ = _aLocaleCountriesXT6_[_iLoopLocaleCountriesXT6_]
			if _aCountryInfo_[1] = _cCountryQtNumber_
				return _aCountryInfo_[3]
			ok
		next

	def CountryLongAbbreviation()
		_cCountryQtNumber_ = This.CountryNumber()

		_aLocaleCountriesXT5_ = LocaleCountriesXT()
		_nLocaleCountriesXT5Len_ = len(_aLocaleCountriesXT5_)
		for _iLoopLocaleCountriesXT5_ = 1 to _nLocaleCountriesXT5Len_
			_aCountryInfo_ = _aLocaleCountriesXT5_[_iLoopLocaleCountriesXT5_]
			if _aCountryInfo_[1] = _cCountryQtNumber_
				return _aCountryInfo_[4]
			ok
		next

	def CountryPhoneCode()
		_cCountry_ = This.CountryName()

		_aLocaleCountriesXT4_ = LocaleCountriesXT()
		_nLocaleCountriesXT4Len_ = len(_aLocaleCountriesXT4_)
		for _iLoopLocaleCountriesXT4_ = 1 to _nLocaleCountriesXT4Len_
			_aCountryInfo_ = _aLocaleCountriesXT4_[_iLoopLocaleCountriesXT4_]
			if StzLower(_aCountryInfo_[2]) = StzLower(_cCountry_)
				return _aCountryInfo_[5]
			ok
		next

	def CountryName()
		_aLocaleCountriesXT3_ = LocaleCountriesXT()
		_nLocaleCountriesXT3Len_ = len(_aLocaleCountriesXT3_)
		for _iLoopLocaleCountriesXT3_ = 1 to _nLocaleCountriesXT3Len_
			_aCountryInfo_ = _aLocaleCountriesXT3_[_iLoopLocaleCountriesXT3_]
			if _aCountryInfo_[1] = This.CountryNumber()
				return _aCountryInfo_[2]
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
		_cLangName_ = This.LanguageName()

		_aLocaleLanguagesXT1_ = LocaleLanguagesXT()
		_nLocaleLanguagesXT1Len_ = len(_aLocaleLanguagesXT1_)
		for _iLoopLocaleLanguagesXT1_ = 1 to _nLocaleLanguagesXT1Len_
			_aLangInfo_ = _aLocaleLanguagesXT1_[_iLoopLocaleLanguagesXT1_]
			if StzLower(_aLangInfo_[2]) = StzLower(_cLangName_)
				return _aLangInfo_[1]
			ok
		next

	def LanguageName()
		_cCountry_ = This.CountryName()
		if _cCountry_ != ""
			return StzCountryQ(This.CountryName()).Language()
		ok

		def Language()
			return This.LanguageName()

		#-- @Misspelled

		def Langauge()
			return This.LanguageName()

	def LanguageNativeName()
		_cLangCode_ = _LocaleLangCodeFromAbbr(@cAbbreviation)
		_cNative_ = _LangNativeNameFromCode(_cLangCode_)
		if _cNative_ != ""
			return _cNative_
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
		_cLang_ = This.LanguageName()
		_aLocaleScriptsXT2_ = LocaleScriptsXT()
		_nLocaleScriptsXT2Len_ = len(_aLocaleScriptsXT2_)
		for _iLoopLocaleScriptsXT2_ = 1 to _nLocaleScriptsXT2Len_
			_aScriptInfo_ = _aLocaleScriptsXT2_[_iLoopLocaleScriptsXT2_]
			if StzLower(_aScriptInfo_[4]) = StzLower(_cLang_)
				return _aScriptInfo_[1]
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
		_cScriptNumber_ = This.ScriptNumber()
		_aLocaleScriptsXT1_ = LocaleScriptsXT()
		_nLocaleScriptsXT1Len_ = len(_aLocaleScriptsXT1_)
		for _iLoopLocaleScriptsXT1_ = 1 to _nLocaleScriptsXT1Len_
			_aScriptInfo_ = _aLocaleScriptsXT1_[_iLoopLocaleScriptsXT1_]
			if _aScriptInfo_[1] = _cScriptNumber_
				return _aScriptInfo_[3]
			ok
		next

	  #--------------#
	 #   CURRENCY   #
	#--------------#

	def CurrencyName()
		_nLen_ = len(_aLocaleCountriesXT)
		_cNumber_ = This.CountryNumber()

		for i = 1 to _nLen_

			if _aLocaleCountriesXT[i][1] = _cNumber_
				_cTemp_ = StzReplace(_aLocaleCountriesXT[i][7], "_", " ")
				_cResult_ = StzUpper(StzLeft(_cTemp_, 1)) + StzMid(_cTemp_, 2, StzLen(_cTemp_))
				return _cResult_
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
		_aLocaleCountriesXT2_ = LocaleCountriesXT()
		_nLocaleCountriesXT2Len_ = len(_aLocaleCountriesXT2_)
		for _iLoopLocaleCountriesXT2_ = 1 to _nLocaleCountriesXT2Len_
			_aCountryInfo_ = _aLocaleCountriesXT2_[_iLoopLocaleCountriesXT2_]
			if _aCountryInfo_[1] = This.CountryNumber()
				return _aCountryInfo_[8]
			ok
		next

		def CurrencyFraction()
			return This.CurrencyFractionalUnit()

	def CurrencyBase()
		_aLocaleCountriesXT1_ = LocaleCountriesXT()
		_nLocaleCountriesXT1Len_ = len(_aLocaleCountriesXT1_)
		for _iLoopLocaleCountriesXT1_ = 1 to _nLocaleCountriesXT1Len_
			_aCountryInfo_ = _aLocaleCountriesXT1_[_iLoopLocaleCountriesXT1_]
			if _aCountryInfo_[1] = This.CountryNumber()
				return _aCountryInfo_[9]
			ok
		next

	def CurrencyInfo()
		_aResult_ = [
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

		return _aResult_

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
		_nType_ = LocaleTimeFormatTypes()[ cType ]
		return _LocaleTimeFormatStr(@cAbbreviation, _nType_)

	// Returns a stzTime object from the localised string cTime
	def ToStzTime(cTime)
		return new stzTime(cTime)
		/*
		TODO: Logical error. Returns a result that is insensitve to the locale
			_o1_ = new stzLocale("ru_RU") # Russian locale
			? _o1_.ToTimeAsString("05:08:34", :Long)

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

		_cFirstDayInEnglish_ = This.FirstDayOfWeek()
		_aDaysInEnglish_ = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]
		_n_ = StzFindFirst( _aDaysInEnglish_, _cFirstDayInEnglish_ )

		# We need to get that 1st day in native language of the locale

		_aResult_ = [ _cFirstDayInEnglish_ ]

		# And then compose the days starting from that 1st day

		for i = _n_ + 1 to 7

			_aResult_ + _aDaysInEnglish_[i]
		next

		for i = 1 to _n_ - 1
			_aResult_ + _aDaysInEnglish_[i]
		next

		return _aResult_

	#---

	def NativeDaysOfWeek()
		_cFirstDayInEnglish_ = This.FirstDayOfWeek()
		_aDaysInEnglish_ = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]
		_n_ = StzFindFirst( _aDaysInEnglish_, _cFirstDayInEnglish_ )

		_cLang_ = This.LanguageName()

		_aDaysInLocaleLanguage_ = [ _DayNameInLang(_cLang_, _n_) ]

		for i = _n_ + 1 to 7
			_aDaysInLocaleLanguage_ + _DayNameInLang(_cLang_, i)
		next

		for i = 1 to _n_ - 1
			_aDaysInLocaleLanguage_ + _DayNameInLang(_cLang_, i)
		next

		return _aDaysInLocaleLanguage_

	def NthDayOfWeek(_n_)
		/*
		FYI: read this discussion about the week having 5 days in Javaneese:
		https://bit.ly/2U5oTAh
		*/

		_nNthDay_ = 0
		if 0 < _n_ and _n_ < 8
			_nFirstDayOfWeek_ = _LocaleFirstDayNumber(@cAbbreviation)
			_nTemp_ = _nFirstDayOfWeek_ + (_n_-1)

			if _n_ != 1
				for i = _nFirstDayOfWeek_ to _nTemp_

					_nNthDay_++
					if _nNthDay_ = 8
						_nNthDay_ = 1
					ok
				next
				_nNthDay_--
			else
				_nNthDay_ = _nFirstDayOfWeek_ + _n_ - 1
			ok

			return DefaultDaysOfWeek()[""+ _nNthDay_ ]
		else
			StzRaise(stzLocaleError(:CanNotDefineNthDayOfWeek))
		ok

	def FirstDayOfWeek()
		return This.NthDayOfWeek(1)

	def LastDayOfWeek()
		return This.NthDayOfWeek(7)

	def NthNativeDayOfWeek(_n_)
		return This.NativeDaysOfWeek()[_n_]

		def NativeNthDayOfWeek(_n_)
			return This.NthNativeDayOfWeek(_n_)

	def FirstNativeDayOfWeek()
		return This.NthNativeDayOfWeek(1)

		def NativeFirstDayOfWeek()
			return This.FirstNativeDayOfWeek()

	def LastNativeDayOfWeek()
		return This.NthNativeDayOfWeek(7)

		def NativeLastDayOfWeek()
			return This.LastNativeDayOfWeek()

	#---

	def NthDayOfWeekAbbreviation(_n_)
		_cFirstDay_ = This.FirstDayOfWeek()
		_aDaysInEnglish_ = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]

		_nFirst_ = StzFindFirst( _aDaysInEnglish_, _cFirstDay_ )

		_nDay_ = _nFirst_ + _n_ - 1
		if _nDay_ > 7 _nDay_ = _nDay_ - 7 ok
		return _DayAbbrInLang(:english, _nDay_)

	def NthDayOfWeekNativeAbbreviation(_n_)
		_cLang_ = This.LanguageName()
		return _DayAbbrInLang(_cLang_, _n_)

		def NativeNthDayOfWeekAbbreviation(_n_)
			return This.NthDayOfWeekNativeAbbreviation(_n_)

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

	def NthDayOfWeekSymbol(_n_)
		_cFirstDay_ = This.FirstDayOfWeek()
		_aDaysInEnglish_ = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]

		_nFirst_ = StzFindFirst( _aDaysInEnglish_, _cFirstDay_ )

		_nDay_ = _nFirst_ + _n_ - 1
		if _nDay_ > 7 _nDay_ = _nDay_ - 7 ok
		return _DaySymbolInLang(:english, _nDay_)

	def NthDayOfWeekNativeSymbol(_n_)
		_cLang_ = This.LanguageName()
		return _DaySymbolInLang(_cLang_, _n_)

		def NativeNthDayOfWeekSymbol(_n_)
			return This.NthDayOfWeekNativeSymbol(_n_)

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
		_cResult_ = StzEngineLocaleToLower(pcStr)
		return _cResult_

		def ToLowercase(pcStr)
			return This.StringLowercased(pcStr)

		def Lowercase(pcStr)
			return This.StringLowercased(pcStr)

		def Lower(pcStr)
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
		_cResult_ = StzEngineLocaleToUpper(pcStr)
		return _cResult_

		def ToUppercase(pcStr)
			return This.StringUppercased(pcStr)

		def Uppercase(pcStr)
			return This.StringUppercased(pcStr)

		def Upper(pcStr)
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

				_oStr_ = new stzString(pcStr)
				_nLen_ = _oStr_.NumberOfChars()
				_cResult_ = This.ToUppercase( _oStr_.Char(1) ) +
					  This.ToLowercase( _oStr_.Section(2,_nLen_) )
			ok

			return _cResult_
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

		_oStr_ = StzStringQ(pcStr).LowercaseQ()

		# Getting the positions of the words in the string
		#TODO: delegate the work to stzText when ready

		_anPos_ = _oStr_.FindAll(" ")
		if len(_anPos_) = 0
			_anPos_ = [1]

		else
			_anPos_ = StzListOfNumbersQ(_anPos_).AddedToEach(1)
			ring_insert(_anPos_, 1, 1)
			_oChain_ = new stzList(_anPos_)
			_anPos_ = _oChain_.Sorted()
		ok

		_nLen_ = len(_anPos_)

		//for n in anPos
		for i = 1 to _nLen_
			_cCapitalizedChar_ = _oStr_.CharAtPositionQ(_anPos_[i]).Uppercased()
			_oStr_.ReplaceCharAtPosition(_anPos_[i], _cCapitalizedChar_)
		next

		return _oStr_.Content()

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
		_cCurrencyName_ = ""
		_nLen_ = len(_aLocaleCountriesXT)
		_cNumber_ = This.CountryNumber()
		for i = 1 to _nLen_
			if _aLocaleCountriesXT[i][1] = _cNumber_
				_cCurrencyName_ = _aLocaleCountriesXT[i][7]
				exit
			ok
		next

		switch pcTypeOfSymbol
		on :ISOSymbol
			return _CurrencyISOCode(_cCurrencyName_)

		on :NativeSymbol
			return _CurrencyNativeSymbol(_cCurrencyName_)

		on :NativeName
			_cResult_ = StzReplace(_cCurrencyName_, "_", " ")
			return _cResult_

		other
			StzRaise(stzLocaleError(:CanNotProvideCurrencySymbol))
		off
