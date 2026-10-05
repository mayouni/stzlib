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
	# MONDAY-FIRST, always. Rotating to the locale's own first day is
	# NativeDaysOfWeek()'s job, not this table's.
	#
	# These are NATIVE names, so they are written in the language's own script.
	# Russian read "Ponedelnik" and Arabic's months "Yanayir" -- Latin
	# transliterations sitting in a column called native. The Latin-script
	# languages had their diacritics stripped for the same reason.
	[:english,    ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]],
	[:french,     ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]],
	[:arabic,     ["الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت", "الأحد"]],
	[:persian,    ["دوشنبه", "سه‌شنبه", "چهارشنبه", "پنج‌شنبه", "جمعه", "شنبه", "یکشنبه"]],
	[:spanish,    ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]],
	[:german,     ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]],
	[:portuguese, ["Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado", "Domingo"]],
	[:italian,    ["Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato", "Domenica"]],
	[:russian,    ["понедельник", "вторник", "среда", "четверг", "пятница", "суббота", "воскресенье"]],
	[:turkish,    ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]],
	[:dutch,      ["Maandag", "Dinsdag", "Woensdag", "Donderdag", "Vrijdag", "Zaterdag", "Zondag"]]
]

$_aMonthNamesPerLang = [
	[:english,    ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]],
	[:french,     ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]],
	[:arabic,     ["يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو", "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"]],
	[:persian,    ["ژانویه", "فوریه", "مارس", "آوریل", "مه", "ژوئن", "ژوئیه", "اوت", "سپتامبر", "اکتبر", "نوامبر", "دسامبر"]],
	[:spanish,    ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]],
	[:german,     ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]],
	[:portuguese, ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]],
	[:italian,    ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"]],
	[:russian,    ["январь", "февраль", "март", "апрель", "май", "июнь", "июль", "август", "сентябрь", "октябрь", "ноябрь", "декабрь"]],
	[:turkish,    ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]],
	[:dutch,      ["Januari", "Februari", "Maart", "April", "Mei", "Juni", "Juli", "Augustus", "September", "Oktober", "November", "December"]]
]

# $_aCurrencyISOData lived here: 143 rows of [name, ISO code, symbol]. It moved
# into the engine (locale plan L1) -- see engine/src/locale_data.zig, generated
# and committed, and _CurrencyISOCode / _CurrencyNativeSymbol below, which now
# ask for it instead of carrying it.

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
	_nPos_ = StzFindFirst("_", _cLocaleAbbr_)
	if _nPos_ > 0
		return StzLower(StzLeft(_cLocaleAbbr_, _nPos_ - 1))
	ok
	return StzLower(_cLocaleAbbr_)

func _LocaleCountryCodeFromAbbr(_cLocaleAbbr_)
	_cLocaleAbbr_ = StzReplace(_cLocaleAbbr_, "-", "_")
	_nPos_ = StzFindFirst("_", _cLocaleAbbr_)
	if _nPos_ > 0
		_cRest_ = StzMid(_cLocaleAbbr_, _nPos_ + 1, StzLen(_cLocaleAbbr_))
		_nPos2_ = StzFindFirst("_", _cRest_)
		if _nPos2_ > 0
			return StzUpper(StzMid(_cRest_, _nPos2_ + 1, StzLen(_cRest_)))
		ok
		if StzLen(_cRest_) <= 3 and isalpha(StzLeft(_cRest_, 1))
			return StzUpper(_cRest_)
		ok
	ok
	return ""

# A LANGUAGE'S DEFAULT SCRIPT IS THE ONE ITS OWN NAME IS WRITTEN IN.
#
# The scripts table's fourth column is DefaultLanguage -- "for this SCRIPT,
# which language". ScriptNumber() read it BACKWARDS, scanning for the first
# script whose default language matched, and answering that. For French the
# first hit is Duployan, a shorthand system, so a plain French locale claimed
# to be written in stenography. The reverse of a many-to-one mapping is not a
# function, and this is what asking for it anyway produces.
#
# There is no language->script column to consult, and adding one means
# authoring 322 rows by hand. There is no need: every language row already
# carries its NATIVE NAME, and the engine can tell which script a character
# belongs to. Francais is latin, Русский is cyrillic, العربية is arabic --
# the answer is in the data already, spelled in the alphabet itself.
#
# Answers "" when it cannot tell, leaving the caller to fall back.
func _LocaleDefaultScriptNumberForLang(pcLangName)
	_cLangN_ = StzLower("" + pcLangName)
	_cNative_ = ""

	_nLenL_ = len($aLocaleLanguagesXT)
	for i = 1 to _nLenL_
		if StzLower("" + $aLocaleLanguagesXT[i][2]) = _cLangN_
			_cNative_ = "" + $aLocaleLanguagesXT[i][6]
			exit
		ok
	next

	if _cNative_ = ""
		return ""
	ok

	# The first LETTER, not the first character -- a native name can open
	# with a quote or a bracket, which belongs to no script.
	_cScriptName_ = ""
	_nLenN_ = StzLen(_cNative_)
	if _nLenN_ > 8
		_nLenN_ = 8
	ok
	for i = 1 to _nLenN_
		_cCh_ = StzNthChar(_cNative_, i)
		if _cCh_ = " " or _cCh_ = "-" or _cCh_ = "'"
			loop
		ok
		_cS_ = StzCharScript(_cCh_)
		if _cS_ != "" and StzLower("" + _cS_) != "common"
			_cScriptName_ = StzLower("" + _cS_)
			exit
		ok
	next

	if _cScriptName_ = ""
		return ""
	ok

	_aScr_ = LocaleScriptsXT()
	_nLenS_ = len(_aScr_)
	for i = 1 to _nLenS_
		if StzLower("" + _aScr_[i][2]) = _cScriptName_
			return _aScr_[i][1]
		ok
	next
	return ""

# The country a language belongs to by default, as a code -- "ru" -> "RU",
# "ar" -> "EG". Answers "" when the language names no country.
func _LocaleDefaultCountryCodeForLang(_cLang_)
	_cLang_ = StzLower(_cLang_)
	_nLen_ = len($aLocaleLanguagesXT)
	for i = 1 to _nLen_
		if StzLower($aLocaleLanguagesXT[i][3]) = _cLang_
			if $aLocaleLanguagesXT[i][5] = ""
				return ""
			ok
			_cCountryName_ = $aLocaleLanguagesXT[i][5]
			_nLen2_ = len(_aLocaleCountriesXT)
			for j = 1 to _nLen2_
				if StzLower(_aLocaleCountriesXT[j][2]) = StzLower(_cCountryName_)
					return _aLocaleCountriesXT[j][3]
				ok
			next
			return ""
		ok
	next
	return ""

# THE ABBREVIATION IS lang_COUNTRY. A SCRIPT SUBTAG IS NOT PART OF IT.
#
# This used to lowercase the first subtag and UPPERCASE everything after it,
# so a script rode along and shouted: "en-Latn-US" became "en_LATN_US",
# "pt_Latn_BR" became "pt_LATN_BR", and [ :Language = :russian,
# :Script = :latin ] became "ru_LATN" -- a string with no country in it at
# all, from which CountryNumber() could read nothing.
#
# The script is not lost by dropping it here: it is carried on
# @cScriptAbbreviation and answered by Script(), which is where a caller asks
# for it. What the abbreviation is FOR is the lang_COUNTRY identity that
# CountryNumber(), the currency lookups and the day-name tables all key on.
#
# When no country subtag is given, the language's default country supplies
# one -- ru -> ru_RU, ar -> ar_EG -- which is what the no-subtag path already
# did, and there is no reason for "ru" and "ru-Latn" to answer differently.
func _LocaleNormalizeAbbr(_cInput_)
	if _cInput_ = "" or _cInput_ = "C"
		return "C"
	ok

	_cIn_ = StzReplace("" + _cInput_, "-", "_")
	_acParts_ = StzSplit(_cIn_, "_")
	_nParts_ = len(_acParts_)
	if _nParts_ = 0
		return "C"
	ok

	_cLang_ = StzLower(_acParts_[1])
	_cCountry_ = ""

	# A 4-letter subtag is a SCRIPT (Latn, Arab, Cyrl); 2 or 3 characters is
	# a country (US, BR, EG). Anything else is left alone.
	for i = 2 to _nParts_
		_cPart_ = _acParts_[i]
		_nLenP_ = StzLen(_cPart_)
		if _nLenP_ = 4
			loop
		ok
		if _nLenP_ >= 2 and _nLenP_ <= 3
			_cCountry_ = StzUpper(_cPart_)
		ok
	next

	if _cCountry_ = ""
		_cCountry_ = _LocaleDefaultCountryCodeForLang(_cLang_)
	ok

	if _cCountry_ = ""
		return _cLang_
	ok

	return _cLang_ + "_" + _cCountry_

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
	# Saturday-first, per CLDR's firstDay territories. This listed AF and IR
	# only, so every Arab country fell through to the Monday default and
	# ar_EG opened its week on a Monday.
	_aSatFirst_ = ["AE", "AF", "BH", "DJ", "DZ", "EG", "IQ", "IR", "JO",
	               "KW", "LY", "OM", "QA", "SA", "SD", "SY", "YE"]
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

# THE ENGINE OWNS THE CURRENCY TABLE (locale plan, L1).
#
# These two walked $_aCurrencyISOData row by row in Ring. The rows now live in
# engine/src/locale_data.zig, generated offline by tools/gen_locale_tables.py
# and committed -- the same shape utf8proc_data.c has. A table with two owners
# is a table with two answers, so the Ring copy is gone rather than kept in
# step.
#
# The engine answers "" for a name it does not carry, and that survives the
# crossing unchanged: an unknown currency has no symbol, and inventing one is
# how 36 rows came to answer their own ISO code in the first place.
func _CurrencyISOCode(_cCurrencyName_)
	return StzEngineLocaleCurrencyIso("" + _cCurrencyName_)

func _CurrencyNativeSymbol(_cCurrencyName_)
	return StzEngineLocaleCurrencySymbol("" + _cCurrencyName_)

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
	# "" for a code this table does not carry, matching the native-name sibling
	# below. It used to answer :english, which is a guess wearing the clothes of
	# an answer -- and it left the caller no way to try anything else.
	return ""

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

	_aDaysInEnglish_ = [ :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday ]
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

# Holds a locale such as fr-FR and answers its country, language, script, currency, week days, time patterns and number symbols.
#
# A stzLocale is a locale code kept as text with an underscore (fr_FR). Build it from a code, a
# language name, a country name, a hash of parts, :System or :Default; the library's own tables then
# answer the facts: CountryName, LanguageName, CurrencyInfo, the first day of the week (monday for
# fr-FR, sunday for en-US, saturday for ar-EG), time patterns, DecimalPoint and GroupSeparator. The
# week methods come in three faces, English, native (the locale's own language) and the abbreviation
# and one-letter symbol of each, all counted from the locale's first day. A locale the tables do not
# know answers empty text. Known gaps today, each carried as a warning on its method: the case
# conversions change only the ASCII letters and ignore the locale; the title-case and capital-case
# methods and the ToTimeAs methods raise; the fold-case methods answer nothing; the script of most
# locales comes out as common; and day names exist only for ten languages, the others answer
# English.
#
#   receiver   o1 = new stzLocale("fr-FR")
#   example    ? o1.CountryName()
#              #--> france
#   see        stzCountry, stzLanguage, stzScript, stzTime
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

	# Builds the locale from a code such as fr-FR or ar_Arab_TN, a language or country name, a hash of parts, :System or :Default.
	#
	#   pLocale    a locale code with - or _ between its parts, a language name such as French, a
	#              country name such as France, [ :Language = ..., :Script = ..., :Country = ... ],
	#              :System or :Default
	#   returns    nothing; the object is built
	#   note       a language code alone completes to its default country (fr gives fr_FR); :System
	#              gives the C locale and :Default gives the library's default locale (en_US when
	#              probed); the code is stored with an underscore
	#   warning    a code the library does not know (xx-YY) is kept as given and every lookup
	#              answers empty text; a hash with none of the three keys raises Can't create the
	#              stzLocale object!; a number builds an empty locale without an error
	#   see        StzLocaleQ
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

			_cLangAbbr_    = ""
			_cScriptAbbr_  = ""
			_cCountryAbbr_ = ""

			if _cLangName_ != "" and StzStringQ(_cLangName_).IsLanguageName()
				_cLangAbbr_ = StzLanguageQ(_cLangName_).Abbreviation()
			ok

			if _cScriptName_ != "" and StzStringQ(_cScriptName_).IsScriptName()
				_cScriptAbbr_ = StzScriptQ(_cScriptName_).Abbreviation()
			ok

			if _cCountryName_ != "" and StzStringQ(_cCountryName_).IsCountryName()
				_cCountryAbbr_ = StzCountryQ(_cCountryName_).Abbreviation()
			ok

			_cAbbr_ = ""

			if AllOfTheseAreNotNull([ _cLangAbbr_, _cScriptAbbr_, _cCountryAbbr_ ])
				_cAbbr_ = _cLangAbbr_ + "-" + _cScriptAbbr_ + "-" + _cCountryAbbr_

			but _cLangAbbr_ != "" and BothAreNull(_cScriptAbbr_, _cCountryAbbr_)
				_cAbbr_ = _cLangAbbr_

			but _cScriptAbbr_ != "" and BothAreNull(_cLangAbbr_, _cCountryAbbr_)
				_cLangAbbr_ = StzScriptQ(_cScriptAbbr_).DefaultLanguageAbbreviation()
				_cAbbr_ = _cLangAbbr_ + "-" + _cScriptAbbr_

			but _cCountryAbbr_ != "" and BothAreNull(_cLangAbbr_, _cScriptAbbr_)
				_cLangAbbr_ = StzCountryQ(_cCountryAbbr_).LanguageAbbreviation()
				_cAbbr_ = _cLangAbbr_ + "-" + _cCountryAbbr_

			but BothAreNotNull(_cLangAbbr_, _cScriptAbbr_) and _cCountryAbbr_ = ""
				_cAbbr_ = _cLangAbbr_ + "-" + _cScriptAbbr_

			but BothAreNotNull(_cLangAbbr_, _cCountryAbbr_) and _cScriptAbbr_ = ""
				_cAbbr_ = _cLangAbbr_ + "-" + _cCountryAbbr_

			but _cLangAbbr_ = "" and BothAreNotNull(_cScriptAbbr_, _cCountryAbbr_)
				_cLangAbbr_ = StzCountryQ(_cCountryAbbr_).LanguageAbbreviation()
				_cAbbr_ = _cLangAbbr_ + "-" + _cScriptAbbr_ + "-" + _cCountryAbbr_

			ok

			@cAbbreviation = _LocaleNormalizeAbbr(_cAbbr_)

			# @cScriptAbbreviation / @cCountryAbbreviation -- the names the rest
			# of the class READS. These two lines wrote @cScriptAbbr and
			# @cCountryAbbr, which are written here and read nowhere, so a
			# locale built from a list silently lost its script and country
			# and every consumer fell back to the language default. The string
			# branch above sets the right names; only this branch did not.
			@cLangAbbreviation = _cLangAbbr_
			@cScriptAbbreviation = _cScriptAbbr_
			@cCountryAbbreviation = _cCountryAbbr_
		ok

	  #---------#
	 #  INFO   #
	#---------#

	# Returns the locale code as normalised text, with an underscore, such as fr_FR.
	#
	#   returns    a string such as fr_FR
	#   note       the Content form answers the same
	#   see        bcp47Abbreviation, Content
	#@ aka  LOCALE ABBREVIATION
	def Abbreviation()
		return @cAbbreviation

	def Content()
		return This.Abbreviation()

		# Returns the locale code as normalised text, such as fr_FR.
		#
		#   returns    a string such as fr_FR
		#   see        Abbreviation
		def Value()
			return Content()

	# Returns the locale code with a hyphen between its parts, the BCP 47 spelling, such as fr-FR.
	#
	#   returns    a string such as fr-FR
	#   see        Abbreviation
	def bcp47Abbreviation()
		return StzReplace(@cAbbreviation, "_", "-")

	  #---------------#
	 #    COUNTRY    #
	#---------------#

	# Returns the library's number for the locale's country, as text; 0 when the country is not known.
	#
	#   returns    a string of digits such as 74, or 0
	#   note       the number belongs to the library's own country table
	#   see        CountryName, CountryShortAbbreviation
	def CountryNumber()
		_cCode_ = _LocaleCountryCodeFromAbbr(@cAbbreviation)
		if _cCode_ != ""
			return _LocaleCountryNumber(_cCode_)
		ok
		return "0"

	def CountryAbbreviation()
		return This.CountryShortAbbreviation()

	# Returns the two-letter country code, such as FR or US.
	#
	#   returns    a string of two letters
	#   note       empty when the country is not known; the CountryAbbreviation form answers the
	#              same
	#   see        CountryLongAbbreviation, CountryName
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

	# Returns the three-letter country code, such as FRA or USA.
	#
	#   returns    a string of three letters
	#   note       empty when the country is not known
	#   see        CountryShortAbbreviation
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

	# Returns the international dialling code of the country, with its plus sign, such as +33.
	#
	#   returns    a string such as +33
	#   note       empty when the country is not known
	#   see        CountryName
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

	# Returns the English name of the country in lowercase, with underscores for spaces, such as united_states.
	#
	#   returns    a string such as france
	#   note       empty when the country is not known; the CountryNativeName form gives the same
	#              English name, not a native one
	#   see        CountryNumber, LanguageName
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

	# Returns the library's number for the locale's language, as text.
	#
	#   returns    a string of digits such as 37
	#   note       the number belongs to the library's own language table
	#   see        LanguageName
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

	# Returns the English name of the locale's language in lowercase, such as french.
	#
	#   returns    a string such as french
	#   note       taken from the language code, and from the country when the code names no
	#              language; empty for an unknown locale
	#   see        LanguageNativeName, CountryName
	#@ aka  THE LANGUAGE COMES FROM THE LANGUAGE CODE.
	def LanguageName()
		if @cLangAbbreviation != ""
			_cFromCode_ = _LangNameFromCode(@cLangAbbreviation)
			if _cFromCode_ != ""
				return _cFromCode_
			ok
		ok

		_cCountry_ = This.CountryName()
		if _cCountry_ != ""
			return StzCountryQ(_cCountry_).Language()
		ok

		return ""

		def Language()
			return This.LanguageName()

		#-- @Misspelled

		def Langauge()
			return This.LanguageName()

	# Returns the name of the language written in that language, such as Français.
	#
	#   returns    a string such as Français
	#   note       falls back to the English name when no native name is known
	#   see        LanguageName
	def LanguageNativeName()
		_cLangCode_ = _LocaleLangCodeFromAbbr(@cAbbreviation)
		_cNative_ = _LangNativeNameFromCode(_cLangCode_)
		if _cNative_ != ""
			return _cNative_
		ok
		return This.LanguageName()


	# Returns the language code of the locale, such as fr.
	#
	#   returns    a string such as fr
	#   see        LanguageShortAbbreviation, LanguageLongAbbreviation
	def LanguageAbbreviation()
		return StzLanguageQ(This.Language()).Abbreviation()

	# Returns the two-letter language code of the locale, such as fr.
	#
	#   returns    a string of two letters
	#   see        LanguageLongAbbreviation
	def LanguageShortAbbreviation()
		return StzLanguageQ(This.Language()).ShortAbbreviation()

	# Returns the three-letter language code of the locale, such as fra.
	#
	#   returns    a string of three letters
	#   see        LanguageShortAbbreviation
	def LanguageLongAbbreviation()
		return StzLanguageQ(This.Language()).LongAbbreviation()

	  #-----------#
	 #  SCRIPT   #
	#-----------#

	# Returns the library's number for the locale's script, as text, but answers 0 (common) for most locales today.
	#
	#   returns    a string of digits; 0 means common
	#   note       the ScriptCode form answers the same
	#   warning    answers 0, the common script, for a locale written without a script, so fr-FR,
	#              en-US, ar-EG, ja-JP and ru-RU all give common instead of Latin, Arabic or
	#              Cyrillic; a script written in the code (ar_Arab_TN gives 1) or a locale built
	#              from a country name (France gives Latin) is honoured
	#   see        ScriptName, ScriptAbbreviation
	def ScriptNumber()
		if @cScriptAbbreviation != "" and @cScriptAbbreviation != ""
			return _LocaleQtScriptNumber(@cScriptAbbreviation)
		ok
		_cLang_ = This.LanguageName()

		# The language's own name tells us its alphabet -- see
		# _LocaleDefaultScriptNumberForLang. Tried FIRST, because the scan
		# below reads the scripts table's DefaultLanguage column backwards
		# and answers Duployan for French.
		_cByName_ = _LocaleDefaultScriptNumberForLang(_cLang_)
		if _cByName_ != ""
			return _cByName_
		ok

		# Last resort, for a language whose native name reveals nothing.
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

	# Returns the English name of the locale's script in lowercase, but answers common for most locales today.
	#
	#   returns    a string such as common or arabic
	#   note       follows ScriptNumber; the Script form answers the same
	#   warning    answers common for a locale written without a script, so fr-FR and ar-EG give
	#              common instead of latin and arabic; ar_Arab_TN gives arabic
	#   see        ScriptNumber, ScriptAbbreviation
	def ScriptName()
		return StzScriptQ(This.ScriptNumber()).Name()

	def Script()
		return This.ScriptName()

	# Returns the four-letter script code, such as Latn or Arab, but answers Zyyy (common) for most locales today.
	#
	#   returns    a string such as Zyyy or Arab
	#   note       follows ScriptNumber
	#   warning    answers Zyyy for a locale written without a script, so fr-FR gives Zyyy instead
	#              of Latn
	#   see        ScriptName, ScriptNumber
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

	# Returns the English name of the country's currency with only its first letter capitalised, such as Euro.
	#
	#   returns    a string such as United states dollar
	#   note       empty when the country is not known; the Currency form answers the same
	#   see        CurrencyNativeName, CurrencyInfo
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

	# Returns the currency name in lowercase with spaces, such as euro or united states dollar.
	#
	#   returns    a string such as euro
	#   note       still the English name: the library holds no native currency names
	#   see        CurrencyName
	def CurrencyNativeName()
		return This.pvtCurrencyXT(:NativeName)

	# Returns the three-letter ISO code of the country's currency, such as EUR.
	#
	#   returns    a string of three letters
	#   note       empty when the country is not known
	#   see        CurrencyISOSymbol, CurrencySymbol
	def CurrencyAbbreviation()
		return This.pvtCurrencyXT(:ISOSymbol)

	# Returns the three-letter ISO code of the country's currency, such as USD.
	#
	#   returns    a string of three letters
	#   see        CurrencyAbbreviation
	def CurrencyISOSymbol()
		return This.pvtCurrencyXT(:ISOSymbol)

	# Returns the currency sign of the country, such as the euro sign or $.
	#
	#   returns    a string such as $
	#   note       the CurrencyNativeSymbol form answers the same
	#   see        CurrencyISOSymbol, CurrencyInfo
	def CurrencySymbol()
		return This.pvtCurrencyXT(:NativeSymbol)

		# Returns the currency sign as written in the country, such as the euro sign or £.
		#
		#   returns    a string such as £
		#   note       the same sign as CurrencySymbol
		#   see        CurrencySymbol
		def CurrencyNativeSymbol()
			return This.pvtCurrencyXT(:NativeSymbol)

	# Returns the name of the currency's subunit, such as Cent, Sen or Piastre.
	#
	#   returns    a string such as Cent
	#   note       empty when the country is not known; the CurrencyFraction form answers the same
	#   see        CurrencyBase
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

	# Returns how many subunits make one unit of the currency, such as 100.
	#
	#   returns    a number
	#   note       empty text when the country is not known
	#   see        CurrencyFractionalUnit
	def CurrencyBase()
		_aLocaleCountriesXT1_ = LocaleCountriesXT()
		_nLocaleCountriesXT1Len_ = len(_aLocaleCountriesXT1_)
		for _iLoopLocaleCountriesXT1_ = 1 to _nLocaleCountriesXT1Len_
			_aCountryInfo_ = _aLocaleCountriesXT1_[_iLoopLocaleCountriesXT1_]
			if _aCountryInfo_[1] = This.CountryNumber()
				return _aCountryInfo_[9]
			ok
		next

	# Returns the currency facts as one hash: name, native name, abbreviation, symbols, fractional unit and base.
	#
	#   returns    a hash with the keys name, nativename, abbreviation, symbol, nativesymbol,
	#              isosymbol, fractionalunit, fraction and base
	#   note       every value is empty text for an unknown country
	#   see        CurrencyName, CurrencyBase
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
	# Returns the text that marks the morning in a 12-hour time, AM.
	#
	#   returns    a string, AM
	#   note       takes nothing from the locale: fr-FR and en-US both answer AM
	#   see        pmText, TimeShortFormat
	#-----------------------------#		# formatting time in stzTime
	#@ aka  LOCALISED TIME MANAGEMENT # #TODO :Should be used by default in
	def amText()
		return StzEngineLocaleAMText()

	# Returns the text that marks the afternoon in a 12-hour time, PM.
	#
	#   returns    a string, PM
	#   note       takes nothing from the locale: fr-FR and en-US both answer PM
	#   see        amText
	def pmText()
		return StzEngineLocalePMText()

	# Returns the locale's short time pattern, such as HH:mm or h:mm AP.
	#
	#   returns    a pattern as text
	#   note       24-hour for fr-FR, 12-hour with AP for en-US
	#   see        TimeLongFormat, TimeFormat
	def TimeShortFormat()
		return This.TimeFormat(:Short)
	# Returns the locale's long time pattern, with seconds and a zone mark, such as HH:mm:ss t.
	#
	#   returns    a pattern as text
	#   note       24-hour for fr-FR, 12-hour with AP for en-US
	#   see        TimeShortFormat, TimeFormat
	#@ aka  You can get the list of supported types by using LocaleTimeFormatTypes()
	def TimeLongFormat()
		return This.TimeFormat(:Long)

	# Returns the locale's narrow time pattern, such as HH:mm or h:mm AP.
	#
	#   returns    a pattern as text
	#   note       the same as the short pattern in the locales tried
	#   see        TimeShortFormat, TimeFormat
	def TimeNarrowFormat()
		return This.TimeFormat(:Narrow)

	# Returns the locale's time pattern of one kind: long, short or narrow.
	#
	#   cType      the kind of pattern: :Long, :Short or :Narrow
	#   returns    a pattern as text
	#   note       an unknown kind answers the long pattern
	#   see        TimeShortFormat, TimeLongFormat
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
	# Returns a stzTime object made from a time text such as 14:30:00.
	#
	#   cTime      the time text, as hh:mm:ss
	#   returns    a stzTime
	#   note       ignores the locale: the same object comes back for every locale
	#   see        ToTimeAsString
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

	# Raises error R20 today instead of returning the time text written in a chosen format.
	#
	#   cTime      the time text, as hh:mm:ss
	#   cFormat    the format to use: :Default, :Long, :Short or :Narrow
	#   returns    nothing today; the call raises
	#   note       the other ToTimeAs methods call this one and raise the same way
	#   warning    raises R20 (extra number of parameters) on every call: the body calls the stzTime
	#              ToString method with an argument it does not take
	#   see        ToStzTime, TimeFormat
	def ToTimeAsString(cTime, cFormat)
		/*
		cTime string should contain a time string conforming to the locale
		otherwise the method returns ""

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
	# Raises error R20 today instead of returning the time text in the long format.
	#
	#   cTime      the time text, as hh:mm:ss
	#   returns    nothing today; the call raises
	#   warning    raises R20 because ToTimeAsString raises
	#   see        ToTimeAsString, TimeLongFormat
	#@ aka  --------v----------- ---v--- stzTime object "hh:mm:ss"
	def ToTimeAsLongString(cTime)
		return This.ToTimeAsString(cTime, :Long)

	# Raises error R20 today instead of returning the time text in the short format.
	#
	#   cTime      the time text, as hh:mm:ss
	#   returns    nothing today; the call raises
	#   warning    raises R20 because ToTimeAsString raises
	#   see        ToTimeAsString, TimeShortFormat
	def ToTimeAsShortString(cTime)
		return This.ToTimeAsString(cTime, :Short)

	# Raises error R20 today instead of returning the time text in the narrow format.
	#
	#   cTime      the time text, as hh:mm:ss
	#   returns    nothing today; the call raises
	#   warning    raises R20 because ToTimeAsString raises
	#   see        ToTimeAsString, TimeNarrowFormat
	def ToTimeAsNarrowString(cTime)
		return This.ToTimeAsString(cTime, :Narrow)

	  #---------#
	 #   DAY   #
	#---------#

	# Returns the seven English day names, in lowercase, starting from the locale's first day of the week.
	#
	#   returns    a list of seven strings
	#   note       fr-FR starts on monday, en-US on sunday, ar-EG on saturday
	#   see        NativeDaysOfWeek, FirstDayOfWeek
	def DaysOfWeek()	# In english

		# Let's define the 1st of week in this locale

		_cFirstDayInEnglish_ = This.FirstDayOfWeek()
		_aDaysInEnglish_ = [ :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday ]
		_n_ = StzFindFirst(_cFirstDayInEnglish_, _aDaysInEnglish_)

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

	# Returns the seven day names in the locale's language, starting from its first day of the week.
	#
	#   returns    a list of seven strings
	#   note       English names come back for a language the library has no day names for
	#              (Japanese, Chinese, Hindi, Swahili); French, German, Spanish, Italian,
	#              Portuguese, Russian, Turkish, Arabic, Persian and Dutch have them
	#   see        DaysOfWeek, NthNativeDayOfWeek
	#---
	def NativeDaysOfWeek()
		_cFirstDayInEnglish_ = This.FirstDayOfWeek()
		_aDaysInEnglish_ = [ :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday ]
		_n_ = StzFindFirst(_cFirstDayInEnglish_, _aDaysInEnglish_)

		_cLang_ = This.LanguageName()

		_aDaysInLocaleLanguage_ = [ _DayNameInLang(_cLang_, _n_) ]

		for i = _n_ + 1 to 7
			_aDaysInLocaleLanguage_ + _DayNameInLang(_cLang_, i)
		next

		for i = 1 to _n_ - 1
			_aDaysInLocaleLanguage_ + _DayNameInLang(_cLang_, i)
		next

		return _aDaysInLocaleLanguage_

	# Returns the English name of the nth day of the locale's week, in lowercase, counting from its first day.
	#
	#   _n_        the position in the week, from 1 to 7
	#   returns    a string such as tuesday
	#   note       day 1 is monday for fr-FR and saturday for ar-EG
	#   warning    raises an error for a position outside 1 to 7, and that error is R3 because the
	#              library function that builds the message does not exist
	#   see        FirstDayOfWeek, NthNativeDayOfWeek
	def NthDayOfWeek(_n_)
		/*
		FYI: read this discussion about the week having 5 days in Javaneese:
		https://bit.ly/2U5oTAh
		*/

		# THIS COUNTED ITERATIONS, NOT DAYS.
		#
		# The loop below ran from the first day to first + n - 1 and incremented
		# a counter that started at zero, so it answered n - 1 no matter which
		# day the week began on. Only n = 1 was right, and only because it took
		# the else branch and skipped the loop entirely.
		#
		# For ar_EG -- Saturday first -- day 2 came back monday and day 3
		# tuesday, where the week actually runs Sat, Sun, Mon. The English face
		# and the native face named DIFFERENT days at the same index, which is
		# how this surfaced: NativeDaysOfWeek() had always rotated correctly.
		#
		# One rotation, shared with the abbreviation and symbol faces.
		if 0 < _n_ and _n_ < 8
			return DefaultDaysOfWeek()[ "" + This._NthWeekdayIndex(_n_) ]
		else
			StzRaise(stzLocaleError(:CanNotDefineNthDayOfWeek))
		ok

	# Returns the English name of the first day of the locale's week, in lowercase.
	#
	#   returns    a string such as monday
	#   note       monday for fr-FR, sunday for en-US, saturday for ar-EG
	#   see        LastDayOfWeek, NthDayOfWeek
	def FirstDayOfWeek()
		return This.NthDayOfWeek(1)

	# Returns the English name of the last day of the locale's week, in lowercase.
	#
	#   returns    a string such as sunday
	#   note       sunday for fr-FR, saturday for en-US
	#   see        FirstDayOfWeek
	def LastDayOfWeek()
		return This.NthDayOfWeek(7)

	# Returns the nth day name of the locale's week in its own language, counting from its first day.
	#
	#   _n_        the position in the week, from 1 to 7
	#   returns    a string such as Mardi
	#   note       English when the library has no day names for the language
	#   see        NativeDaysOfWeek, NthDayOfWeek
	def NthNativeDayOfWeek(_n_)
		return This.NativeDaysOfWeek()[_n_]

		def NativeNthDayOfWeek(_n_)
			return This.NthNativeDayOfWeek(_n_)

	# Returns the name of the first day of the locale's week in its own language.
	#
	#   returns    a string such as Lundi
	#   note       English when the library has no day names for the language
	#   see        LastNativeDayOfWeek, NthNativeDayOfWeek
	def FirstNativeDayOfWeek()
		return This.NthNativeDayOfWeek(1)

		def NativeFirstDayOfWeek()
			return This.FirstNativeDayOfWeek()

	# Returns the name of the last day of the locale's week in its own language.
	#
	#   returns    a string such as Dimanche
	#   note       English when the library has no day names for the language
	#   see        FirstNativeDayOfWeek
	def LastNativeDayOfWeek()
		return This.NthNativeDayOfWeek(7)

		def NativeLastDayOfWeek()
			return This.LastNativeDayOfWeek()

	# Returns the three-letter English abbreviation of the nth day of the locale's week, such as Tue.
	#
	#   _n_        the position in the week, from 1 to 7
	#   returns    a string of three letters
	#   note       counted from the locale's first day
	#   see        NthDayOfWeekNativeAbbreviation, NthDayOfWeek
	#---
	def NthDayOfWeekAbbreviation(_n_)
		_cFirstDay_ = This.FirstDayOfWeek()
		_aDaysInEnglish_ = [ :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday ]

		_nFirst_ = StzFindFirst(_cFirstDay_, _aDaysInEnglish_)

		_nDay_ = _nFirst_ + _n_ - 1
		if _nDay_ > 7 _nDay_ = _nDay_ - 7 ok
		return _DayAbbrInLang(:english, _nDay_)

	# Returns the abbreviation, in the locale's language, of the nth day of its week, such as Mar for Mardi.
	#
	#   _n_        the position in the week, from 1 to 7
	#   returns    a short string
	#   note       English abbreviations when the library has no day names for the language
	#   see        NthDayOfWeekAbbreviation, NthNativeDayOfWeek
	#@ aka  ROTATED TO THE LOCALE'S OWN FIRST DAY, like every sibling here.
	def NthDayOfWeekNativeAbbreviation(_n_)
		_cLang_ = This.LanguageName()
		return _DayAbbrInLang(_cLang_, This._NthWeekdayIndex(_n_))

		def NativeNthDayOfWeekAbbreviation(_n_)
			return This.NthDayOfWeekNativeAbbreviation(_n_)

	# Returns the three-letter English abbreviation of the first day of the locale's week.
	#
	#   returns    a string such as Mon
	#   see        LastDayOfWeekAbbreviation, NthDayOfWeekAbbreviation
	def FirstDayOfWeekAbbreviation()
		return This.NthDayOfWeekAbbreviation(1)

	# Returns the abbreviation, in the locale's language, of the first day of its week, such as Lun.
	#
	#   returns    a short string
	#   note       English when the library has no day names for the language
	#   see        LastNativeDayOfWeekAbbreviation
	def FirstNativeDayOfWeekAbbreviation()
		return This.NthDayOfWeekNativeAbbreviation(1)

		def NativeFirstDayOfWeekAbbreviation()
			return This.FirstNativeDayOfWeekAbbreviation()

	# Returns the three-letter English abbreviation of the last day of the locale's week.
	#
	#   returns    a string such as Sun
	#   see        FirstDayOfWeekAbbreviation
	def LastDayOfWeekAbbreviation()
		return This.NthDayOfWeekAbbreviation(7)

	# Returns the abbreviation, in the locale's language, of the last day of its week, such as Dim.
	#
	#   returns    a short string
	#   note       English when the library has no day names for the language
	#   see        FirstNativeDayOfWeekAbbreviation
	def LastNativeDayOfWeekAbbreviation()
		return This.NthDayOfWeekNativeAbbreviation(7)

		# Returns the abbreviation, in the locale's language, of the last day of its week, such as Dim.
		#
		#   returns    a short string
		#   note       the same as the other spelling
		#   see        LastNativeDayOfWeekAbbreviation
		def NativeLastDayOfWeekAbbreviation()
			return This.LastNativeDayOfWeekAbbreviation()

	#---

	// Day symbols are a narrow form (usually one letter) used
	// when you need to enumerate weekdays

	# Returns the one-letter English symbol of the nth day of the locale's week, such as T for tuesday.
	#
	#   _n_        the position in the week, from 1 to 7
	#   returns    a string of one letter
	#   note       counted from the locale's first day
	#   see        NthDayOfWeekNativeSymbol, NthDayOfWeekAbbreviation
	def NthDayOfWeekSymbol(_n_)
		_cFirstDay_ = This.FirstDayOfWeek()
		_aDaysInEnglish_ = [ :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday ]

		_nFirst_ = StzFindFirst(_cFirstDay_, _aDaysInEnglish_)

		_nDay_ = _nFirst_ + _n_ - 1
		if _nDay_ > 7 _nDay_ = _nDay_ - 7 ok
		return _DaySymbolInLang(:english, _nDay_)

	# Returns the narrow symbol, in the locale's language, of the nth day of its week, such as M for Mardi.
	#
	#   _n_        the position in the week, from 1 to 7
	#   returns    a string of one letter
	#   note       English symbols when the library has no day names for the language
	#   see        NthDayOfWeekSymbol, NthNativeDayOfWeek
	def NthDayOfWeekNativeSymbol(_n_)
		_cLang_ = This.LanguageName()
		return _DaySymbolInLang(_cLang_, This._NthWeekdayIndex(_n_))

	# The Monday-first index of this locale's Nth day. One place, because the
	# same rotation was open-coded in four methods and omitted from two.
	#
	# Reads _LocaleFirstDayNumber directly rather than asking FirstDayOfWeek():
	# that is NthDayOfWeek(1), which now comes through here, and the round trip
	# is an infinite recursion.
	def _NthWeekdayIndex(_n_)
		_nFirst_ = _LocaleFirstDayNumber(@cAbbreviation)
		if _nFirst_ < 1 or _nFirst_ > 7
			_nFirst_ = 1
		ok
		_nDay_ = _nFirst_ + _n_ - 1
		if _nDay_ > 7
			_nDay_ = _nDay_ - 7
		ok
		return _nDay_

		def NativeNthDayOfWeekSymbol(_n_)
			return This.NthDayOfWeekNativeSymbol(_n_)

	# Returns the one-letter English symbol of the first day of the locale's week.
	#
	#   returns    a string of one letter
	#   see        LastDayOfWeekSymbol, NthDayOfWeekSymbol
	def FirstDayOfWeekSymbol()
		return This.NthDayOfWeekSymbol(1)

	# Returns the narrow symbol, in the locale's language, of the first day of its week, such as L for Lundi.
	#
	#   returns    a string of one letter
	#   note       English when the library has no day names for the language
	#   see        LastDayOfWeekNativeSymbol
	def FirstDayOfWeekNativeSymbol()
		return This.NthDayOfWeekNativeSymbol(1)

		def NativeFirstDayOfWeekSymbol()
			return This.FirstDayOfWeekNativeSymbol()

	# Returns the one-letter English symbol of the last day of the locale's week.
	#
	#   returns    a string of one letter
	#   see        FirstDayOfWeekSymbol
	def LastDayOfWeekSymbol()
		return This.NthDayOfWeekSymbol(7)

	# Returns the narrow symbol, in the locale's language, of the last day of its week, such as D for Dimanche.
	#
	#   returns    a string of one letter
	#   note       English when the library has no day names for the language
	#   see        FirstDayOfWeekNativeSymbol
	def LastDayOfWeekNativeSymbol()
		return This.NthDayOfWeekNativeSymbol(7)

		def NativeLastDayOfWeekSymbol()
			return This.LastDayOfWeekNativeSymbol()

	  #-----------#
	 #   MONTH   #TODO
	#-----------#


	  #----------------#
	# Returns the character that separates the whole part from the decimals, such as , for fr-FR and . for en-US.
	#
	#   returns    a one-character string
	#   note       the character comes from the locale's number conventions
	#   see        GroupSeparator, Percent
	#----------------#	# formatting numbers in stzNumber
	#@ aka  NUMBER FORM # #TODO: Should be used by default in
	def DecimalPoint()
		return _LocaleDecimalPointChar(@cAbbreviation)

	# Returns the letter that introduces the exponent in scientific notation, e.
	#
	#   returns    the string e
	#   note       the same for every locale
	#   see        DecimalPoint
	def Exponential()
		return "e"

	# Returns the character that groups thousands, such as a space for fr-FR, a comma for en-US and a dot for de-DE.
	#
	#   returns    a one-character string
	#   note       the GroupSeperator form answers the same
	#   see        DecimalPoint
	def GroupSeparator()
		return _LocaleGroupSepChar(@cAbbreviation)

		def GroupSeperator()
			return This.GroupSeparator()

	# Returns the sign written before a negative number, -.
	#
	#   returns    the string -
	#   note       the same for every locale
	#   see        PositiveSign
	def NegativeSign()
		return "-"

	# Returns the sign written before a positive number, +.
	#
	#   returns    the string +
	#   note       the same for every locale
	#   see        NegativeSign
	def PositiveSign()
		return "+"

	# Returns the percent sign, %.
	#
	#   returns    the string %
	#   note       the same for every locale
	#   see        DecimalPoint
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

	# Returns the text with its ASCII capital letters turned to lowercase; accented and non-Latin capitals are not changed today.
	#
	#   pcStr      the text to convert
	#   returns    the text, lowercased
	#   note       the ToLowercase, Lowercase and Lower forms answer the same
	#   warning    the locale has no effect and only A to Z change, so É stays É and Turkish I gives
	#              i; a number as argument stops the Ring process without a message, and a list
	#              answers empty text
	#   see        StringUppercased, CharLowercased
	def StringLowercased(pcStr)
		_cResult_ = StzEngineLocaleToLower(pcStr)
		return _cResult_

		def ToLowercase(pcStr)
			return This.StringLowercased(pcStr)

		def Lowercase(pcStr)
			return This.StringLowercased(pcStr)

		def Lower(pcStr)
			return This.StringLowercased(pcStr)

	# Returns one character turned to lowercase when it is an ASCII capital letter, and empty text when the argument is not one character.
	#
	#   pcChar     the character to convert
	#   returns    a one-character string; empty when not a single character
	#   warning    only A to Z change, so É stays É
	#   see        StringLowercased, CharIsLowercased
	def CharLowercased(pcChar)
		if @IsChar(pcChar)
			return This.StringLowercased(pcChar)
		ok

	# TRUE if lowercasing the text changes nothing, so it holds no ASCII capital letter.
	#
	#   pcStr      the text to test
	#   returns    TRUE or FALSE
	#   note       the StringIsLowercase form answers the same
	#   warning    accented capitals are not noticed: École answers TRUE, ÉCOLE answers FALSE only
	#              because of its ASCII letters
	#   see        StringLowercased, StringIsUppercased
	def StringIsLowercased(pcStr)
		return This.StringLowercased(pcStr) = pcStr

		def StringIsLowercase(pcStr)
			return This.StringIsLowercased(pcStr)

	# TRUE if lowercasing the character changes nothing, so digits and symbols answer TRUE.
	#
	#   pcChar     the character to test
	#   returns    TRUE or FALSE; nothing when the argument is not one character
	#   see        StringIsLowercased, CharIsUppercased
	def CharIsLowercased(pcChar)
		if @IsChar(pcChar)
			return This.StringIsLowercased(pcChar)
		ok

	  #-----------------------#
	 #   STRING UPPER CASE   #
	#-----------------------#
	# Returns the text with its ASCII small letters turned to capitals; accented and non-Latin letters are not changed today.
	#
	#   pcStr      the text to convert
	#   returns    the text, uppercased
	#   note       the ToUppercase, Uppercase and Upper forms answer the same
	#   warning    the locale has no effect and only a to z change, so école gives éCOLE, straße
	#              gives STRAßE and Turkish i gives I; a number as argument stops the Ring process
	#              without a message
	#   see        StringLowercased, CharUppercased
	#@ aka  --? TODO: support the special cases documented in unicode here: http://unicode.org/Public/UNIDATA/SpecialCasing.txt
	def StringUppercased(pcStr)
		_cResult_ = StzEngineLocaleToUpper(pcStr)
		return _cResult_

		def ToUppercase(pcStr)
			return This.StringUppercased(pcStr)

		def Uppercase(pcStr)
			return This.StringUppercased(pcStr)

		def Upper(pcStr)
			return This.StringUppercased(pcStr)

	# Returns one character turned to a capital when it is an ASCII small letter, and empty text when the argument is not one character.
	#
	#   pcChar     the character to convert
	#   returns    a one-character string; empty when not a single character
	#   warning    only a to z change, so é stays é
	#   see        StringUppercased, CharIsUppercased
	def CharUppercased(pcChar)
		if @IsChar(pcChar)
			return This.StringUppercased(pcChar)
		ok

	# TRUE if uppercasing the text changes nothing, so it holds no ASCII small letter.
	#
	#   pcStr      the text to test
	#   returns    TRUE or FALSE
	#   note       the StringIsUppercase form answers the same
	#   warning    an empty text answers TRUE
	#   see        StringUppercased, StringIsLowercased
	def StringIsUppercased(pcStr)
		return This.StringUppercased(pcStr) = pcStr

		def StringIsUppercase(pcStr)
			return This.StringIsUppercased(pcStr)

	# TRUE if uppercasing the character changes nothing, so digits and symbols answer TRUE.
	#
	#   pcChar     the character to test
	#   returns    TRUE or FALSE; nothing when the argument is not one character
	#   see        StringIsUppercased, CharIsLowercased
	def CharIsUppercased(pcChar)
		if @IsChar(pcChar)
			return This.StringIsUppercased(pcChar)
		ok

	  #-----------------------#
	 #   STRING TITLE CASE   #
	#-----------------------#

	# Raises error R14 today instead of returning the text in title case.
	#
	#   pcStr      the text to convert
	#   returns    nothing today; the call raises
	#   note       the ToTitleCase form raises the same way
	#   warning    raises R14 on every call: for English it goes through StringCapitalcased, which
	#              calls the missing method CharAtPositionQ, and for other Latin-script languages it
	#              calls the missing method Char
	#   see        StringCapitalcased, StringUppercased
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

		# Raises error R14 today instead of returning the text in title case.
		#
		#   pcStr      the text to convert
		#   returns    nothing today; the call raises
		#   note       the intended result is In Search Of Lost Time for English
		#   warning    raises R14 on every call, through StringTitlecased
		#   see        StringTitlecased, StringCapitalcased
		def ToTitleCase(pcStr)
			return StringTitlecased(pcStr)

	# Raises error R14 today instead of telling whether the text is already in title case.
	#
	#   pcStr      the text to test
	#   returns    nothing today; the call raises
	#   warning    raises R14 on every call, through StringTitlecased
	#   see        StringTitlecased
	def StringIsTitlecased(pcStr)
		return This.StringTitlecased(pcStr) = pcStr

		def StringIsTitlecase(pcStr)
			return This.StringIsTitlecased(pcStr)

	  #----------------------#
	 #   STRING FOLD CASE   #
	#----------------------#

	# Returns nothing today, because its body is an unwritten TODO instead of case folding.
	#
	#   pcStr      the text to fold
	#   returns    nothing today
	#   note       the intended result is the Unicode case-folded text
	#   warning    the body is empty, so every call answers empty text; the ToFoldcase form answers
	#              the same
	#   see        StringLowercased, StringIsfoldcased
	def StringFoldcased(pcStr)
		// TODO

		def ToFoldcase(pcStr)
			return This.StringFoldcased(pcStr)

	# Returns nothing today instead of the case-folded character, because StringFoldcased is not written.
	#
	#   pcChar     the character to fold
	#   returns    empty text; nothing when the argument is not one character
	#   warning    answers empty text for every character, because StringFoldcased does
	#   see        StringFoldcased
	def CharFoldcased(pcChar)
		if @IsChar(pcChar)
			return This.StringFoldcased(pcChar)
		ok

	# TRUE if the text is empty today, because the folding it compares with answers empty text for every input.
	#
	#   pcStr      the text to test
	#   returns    TRUE or FALSE
	#   note       the StringIsFoldcase form answers the same
	#   warning    answers FALSE for any non-empty text, and TRUE for an empty one, because it
	#              compares the text with an empty fold
	#   see        StringFoldcased
	def StringIsfoldcased(pcStr)
		return This.Stringfoldcased(pcStr) = pcStr

		def StringIsFoldcase(pcStr)
			return This.StringIsFoldcased(pcStr)

	# Returns FALSE today for any character, because StringFoldcased answers empty text.
	#
	#   pcChar     the character to test
	#   returns    FALSE; nothing when the argument is not one character
	#   warning    answers FALSE for every character, because StringFoldcased is not written
	#   see        StringIsfoldcased
	def CharIsFoldcased(pcChar)
		if @IsChar(pcChar)
			return This.StringIsFoldcased(pcChar)
		ok

	  #-------------------------#
	 #   STRING CAPITAL CASE   #
	#-------------------------#

	# Raises error R14 today instead of returning the text with the first letter of every word capitalised.
	#
	#   pcStr      the text to convert
	#   returns    nothing today; the call raises
	#   note       the StringCapitalised, StringCapitalized and toCapitalcase forms raise the same
	#              way
	#   warning    raises R14 on every call: the body calls the missing method CharAtPositionQ on a
	#              stzString
	#   see        StringTitlecased, StringUppercased
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

	# Raises error R14 today instead of telling whether every word of the text starts with a capital.
	#
	#   pcStr      the text to test
	#   returns    nothing today; the call raises
	#   note       the StringIsCapitalized, StringIsCapitalcased and StringIsCapitalcase forms raise
	#              the same way
	#   warning    raises R14 on every call, through StringCapitalcased
	#   see        StringCapitalcased
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

	# Returns the name of the measurement system the locale uses, such as metric or imperial, as library text.
	#
	#   returns    a string such as metricsytem, imperialussystem or imperialuksystem
	#   note       the metric name is spelled metricsytem as shipped; en-US gives imperialussystem
	#              and en-GB imperialuksystem
	#   see        CountryName, DecimalPoint
	def MeasurementSystem()
		return StzLocaleMeasurementSystems()[ _LocaleMeasurementSysNum(@cAbbreviation) ]

	PRIVATE

	# Returns one piece of currency text for the locale's country: its ISO code, native symbol or native name.
	#
	#   pcTypeOfSymbol   which piece: :ISOSymbol, :NativeSymbol or :NativeName
	#   returns          the piece of text asked for
	#   note             the public Currency methods call it; status internal
	#   warning          raises an error for any other kind; private, so a call from outside the
	#                    class raises R26
	#   see              CurrencyISOSymbol, CurrencyNativeSymbol
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
