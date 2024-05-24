load "stzlib.ring"

/*-------------

pron()

oQLocale = new QLocale("C")
? oQLocale.toLower("RING")
#--> "ring"

proff()
# Executed in 0.03 second(s)

/*---------------

o1 = new stzLocale("de-DE")
? o1.Abbreviation()

/*---------------

SetDefaultLocale("ar-TN")
? DefaultLocale() #--> ar-TN

/*---------------

StzLocaleQ([ :Country = :Ttunisia ]) {
	? Abbreviation()	#--> ar_TN
	? CountryName()		# !--> tunisia
}

/*---------------

StzCountryQ(:palau) {
	? Name()		#--> palau

	? LocaleAbbreviation() #--> "en-PW"
}

/*---------------

o1 = new QLocale("ja-PW")
? o1.country() #--> 108

? StzCountryQ("108").Name() #--> japan

/*---------------

StzLocaleQ("ja-JP") {
	? CountryName()		#--> japan
	? LanguageName()	#--> japanese
}

/*---------------

StzLocaleQ("en-PW") {
	? CountryName()		#--> palau
	? LanguageName()	#--> english
}

/*--------------- ERROR: returns NULL!

StzLocaleQ([ :Country = :palau ]) {
	? CountryName()	# !--> palau
}

/*---------------

StzLocaleQ("fr-TN") {
	? CountryName()		#--> tunisia
	? LanguageName()	#--> arabic
}

/*----------------

StzLocaleQ("ps-AF") {
	? CountryName()		#--> afghanistan
	? LanguageName()	#--> pashto
}

/*----------------

pron()

o1 = new stzString("chinese yuan")
? o1.Capitalised()
#--> Chinese Yuan

proff()

/*---------------
*/

pron()

StzLocaleQ("zh-CN") {		
	? CountryName()			#--> china
	? LanguageName()		#--> literary_chinese
	? Currency()			#--> Chinese Yuan
	? CurrencyAbbreviation()	#--> CNY
}

proff()

/*----------------

? StzLocaleQ("sm-WS").CountryName() #--> NULL! (see why)

/*----------------

StzCountryQ(:american_samoa) {
	? Name()			#--> american_samoa
	? Language()			#--> samaon

	? LanguageAbbreviation()	#--> "sm"
	? Abbreviation()		#--> "AS"

	? LocaleAbbreviation()		#--> "en-AS"
}

/*----------------

? StzLocaleQ("sm-AS").Abbreviation()	#--> "C" but !--> "sm_AS"
//? StzLocaleQ([ :Country = :american_samoa ]).Abbreviation()	#--> "C" but !--> "sm_AS"

/*----------------

StzLocaleQ("en_AS") {
	? Abbreviation()
	? CountryName()
	? LanguageName()
}
/*---------------- Qt ERROR

oQLocale = new QLocale("cmn-CN")
? oQLocale.name()	# Should return China locale but returns C Locale

--> This induces stzLocale in error:

? StzLocaleQ("cmn_CN").CountryName()	# returns NULL but should return China!

--> TODO: Verify this bug for all the other locales (see next code)

/*----------------
*
// Check the name of China in country names!
? StzLocaleQ([ :Language = :Chinese ]).CountryName() #--> NULL ! Todo: Why?
? StzLocaleQ([ :Country = :China ]).CountryName() #--> NULL ! Todo: Why?
? StzCountryQ(:China).Language() #--> Chinese

/*----------------------

# All these return the abbreviation ru_RU

? StzLocaleQ([ :Language = :Russian, :Script = :Latin, :Country = :Russia ]).Abbreviation()
? StzLocaleQ([ :Language = :Russian ]).Abbreviation()
? StzLocaleQ([ :Script = :Latin ]).Abbreviation()
? StzLocaleQ([ :Country = :Russia ]).Abbreviation()
? StzLocaleQ([ :Language = :Russian, :Script = :Latin ]).Abbreviation()
? StzLocaleQ([ :Language = :Russian, :Country = :Russia ]).Abbreviation()
? StzLocaleQ([ :Script = :Latin, :Country = :Russia ]).Abbreviation()

/*----------------------

pron()

StzLocaleQ([ :Country = :Iran ]) {
	? Abbreviation()			 #--> fa_IR
	? NthDayOfWeek(1)			 #--> saturday
	? NativeNthDayOfWeek(1) + NL		 #--> شنبه

	? NthDayOfWeekAbbreviation(1)		 #--> Sat
	? NativeNthDayOfWeekAbbreviation(1) + NL #--> دوشنبه

	? NthDayOfWeekSymbol(1)			 #--> S
	? NativeNthDayOfWeekSymbol(1)		 #--> د
}

proff()
# Executed in 0.07 second(s)

/*----------------------

StzLocaleQ([ :Language = :Persian ]) {
	? Abbreviation()			 #--> fa_IR
	? NthDayOfWeek(1)			 #--> saturday
	? NativeNthDayOfWeek(1) + NL		 #--> شنبه

	? NthDayOfWeekAbbreviation(1)		 #--> Sat
	? NativeNthDayOfWeekAbbreviation(1) + NL #--> دوشنبه

	? NthDayOfWeekSymbol(1)			 #--> S
	? NativeNthDayOfWeekSymbol(1)		 #--> د
}

/*----------------------

StzLocaleQ([ :Script = :Arabic ]) {
	? Abbreviation()			 #--> ar_EG
	? NthDayOfWeek(1)			 #--> saturday
	? NativeNthDayOfWeek(1) + NL		 #--> السبت

	? NthDayOfWeekAbbreviation(1)		 #--> Sat
	? NativeNthDayOfWeekAbbreviation(1) + NL #--> الاثنين

	? NthDayOfWeekSymbol(1)			 #--> S
	? NativeNthDayOfWeekSymbol(1)		 #--> ن
}

/*----------------------

StzLocaleQ([ :Language = :russian, :Country = :Russia ]) {
	? Abbreviation()			 #--> ru_RU
	? NthDayOfWeek(1)			 #--> monday
	? NativeNthDayOfWeek(1) + NL		 #--> понедельник

	? NthDayOfWeekAbbreviation(1)		 #--> Mon
	? NativeNthDayOfWeekAbbreviation(1) + NL #--> пн

	? NthDayOfWeekSymbol(1)			 #--> M
	? NativeNthDayOfWeekSymbol(1)		 #--> пн
}

/*----------------------

StzLocaleQ([ :Language = :russian, :Script = :latin ]) {
	? Abbreviation()			 #--> ru_RU
	? NthDayOfWeek(1)			 #--> monday
	? NativeNthDayOfWeek(1) + NL		 #--> понедельник

	? NthDayOfWeekAbbreviation(1)		 #--> Mon
	? NativeNthDayOfWeekAbbreviation(1) + NL #--> пн

	? NthDayOfWeekSymbol(1)			 #--> M
	? NativeNthDayOfWeekSymbol(1)		 #--> пн
}

/*----------------------

StzLocaleQ([ :Script = :Latin, :Country = :Russia ]) {
	? Abbreviation()			 #--> ru_RU		
	? NthDayOfWeek(1)			 #--> monday
	? NativeNthDayOfWeek(1) + NL		 #--> понедельник

	? NthDayOfWeekAbbreviation(1)		 #--> Mon
	? NativeNthDayOfWeekAbbreviation(1) + NL #--> пн

	? NthDayOfWeekSymbol(1)			 #--> M
	? NativeNthDayOfWeekSymbol(1)		 #--> пн
}

/*-----------------------

? Q("ar_arab_tn").ContainsNTimes(2,"_")	#--> TRUE

/*-----------------------

? StzLocaleQ([ :Country = :Tunisia ]).NthDayOfWeek(3)		# tuesday
? StzLocaleQ([ :Country = :Tunisia ]).NthNativeDayOfWeek(3)	# الأربعاء

? StzLocaleQ("ar-TN").NthDayOfWeek(3)		# tuesday
? StzLocaleQ("ar-TN").NthNativeDayOfWeek(3)	# الأربعاء

/*-----------------------

? StzLocaleQ("ar-TN").DaysOfWeek()
? StzLocaleQ("ar-TN").NativeDaysOfWeek()

/*-----------------------

? NamesOfDaysIn(:Tunisia)

/*-----------------------

? NamesOfMonthsIn(:Algeria)

/*-----------------------

? NamesOfDaysIn(:Persian)
#--> [ "شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنجشنبه", "جمعه" ]

/*-----------------------

? NamesOfDaysIn(:Japanese)  # Or ...In(:Japan)
#--> [ "日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日" ]

/*-----------------------

pron()

? NamesOfMonthsIn(:Japanese) # Or ...In(:Japan)
#--> [ "1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月" ]

proff()
# Executed in 0.08 second(s)

/*----------------------- ///// TEST: returns english names!

? NamesOfDaysIn(:Chinese)

/*-----------------------

//DayNativeName()
//DayNativeShortAbbreviation()
//DayNativeNarrowAbbreviation()

o1 = new Qlocale("fr_FR")
? o1.dayname(1,0)	# 0: Long forma		1: Short format		2: Narrow format
? o1.dayname(1,1)
? o1.dayname(1,2)

// This type is used when you need to enumerate months or weekdays.
// Usually standalone names are represented in singular forms with capitalized first letter.

? o1.monthname(1,0)	//////////////////////////////// TODO
? o1.monthname(1,2)

/*--------------

o1 = new stzLocale([ :Language = :Spanish, :Country = :Spain ])
? o1.Abbreviation()	#--> es_ES

/*--------------

o1 = new stzLocale("ar-TN")
? o1.Abbreviation()	#--> ar_TN

/*-------------

? StringIsLanguageAbbreviation("")	#--> FALSE

/*-------------

? StzListQ([ :Country = :Tunisia ]).IsLocaleList()	#--> TRUE
? StzLocaleQ([ :Country = :Tunisia ]).Abbreviation()	#--> ar_TN


/*-------------//// functional error //// (Is it an error really?)

pron()

StzLocaleQ([ :Language = :French ]) {
	? Country()
	#--> france

	? ToTitlecase("in search of lost time")
	#--> In search of lost time
}

proff()
# Executed in 0.78 second(s)

/*-------------//// TODO: Check error ////
*/
pron()

StzLocaleQ([ :Language = :English ]) {
	? Country()
	#--> united_states

	? ToTitlecase("in search of lost time")
	#--> In search of lost time
}

proff()
# Executed in 0.78 second(s)

/*-------------//// functional error ////

StzStringQ("tunisian dinar") {
	TitlecaseInLocale("fr-FR")
	? Content()			#--> Tunisian dinar

	TitlecaseInLocale("en-US")	# !--> Tunisian Dinar
	? Content()
}

/*-------------
*/
StzLocaleQ([ :Country = :Qatar ]) {

	? CurrencyName()		#--> Qatari Riyal
	? CurrencyNativeName()		#--> ريال قطري
	? CurrencySymbol()		#--> ر.ق.‏
	? CurrencyAbbreviation()	#--> QAR
	? CurrencyFraction()		#--> Dirham
	? CurrencyBase()		#--> 100

}

/*-------------

? StzStringQ(:Ar).IsLanguageAbbreviation()	#--> TRUE

/*-------------

? StzLocaleQ("ar_eg").CountryPhoneCode()	#--> "+20"

/*------------- ///// RETURNS NULL --> FIX //////

StzLocaleQ("tn") {
	? Abbreviation()
	? CountryNumber()
	? CountryName()
	? CountryNativeName()
	? CountryShortAbbreviation()
	? CountryLongAbbreviation()
}

/*-------------

? StzLocaleQ([ :Country = :South_Africa, :Language = :tswana ]).CountryNativeName()
? StzLocaleQ([ :Country = :South_Africa, :Language = :tswana ]).LanguageNativeName()

/*-------------

? StzLocaleQ("ar_Arab").CountryName()		#--> egypt
? StzLocaleQ("ar_Arab").CountryNativeName()	#--> مصر
StzLocaleQ("ar_Arab").LanguageName()		#--> arabic
? StzLocaleQ("ar_Arab").LanguageNativeName()	#--> العربية

/*-------------

StzLocaleQ("tn_ZA") {
	? CountryName()		#--> south_africa
	? CountryNativeName()	#--> iNingizimu Afrika
	? LanguageName()	#--> tswana
	? LanguageNativeName()	#--> isiZulu
}

/*-------------

StzLocaleQ("ar_TN") {
	? CountryName()		#--> tunisia
	? CountryNativeName()	#--> تونس
	? LanguageName()	#--> arabic
	? LanguageNativeName()	#--> العربية
}

/*-------------

StzLocaleQ("fa_IR") {
	? CountryName()		#--> iran
	? CountryNativeName()	#--> ايران
	? LanguageName()	#--> persian
	? LanguageNativeName()	#--> فارسی
}
/*-------------

StzLocaleQ("ru_RU") {
	? CountryName()		#--> russia
	? CountryNativeName()	#--> Россия
	? LanguageName()	#--> russian
	? LanguageNativeName()	#--> русский
}

/*-------------

StzLocaleQ("en_US") {
	? CountryName()		#--> united_states
	? CountryNativeName()	#--> United States
	? LanguageName()	#--> english
	? LanguageNativeName()	#--> American English
}

/*-------------

? StzLocaleQ([ :Country = :south_africa ]).CountryNativeName()	#--> iNingizimu Afrika

/*-------------

? StzLocaleQ([ :Country = :Tunisia ]).CountryNumber()	#--> "216"

/*-------------/////

o1 = new stzLocale("fr_FR")
? o1.ToUppercase("tunis") #--> TUNIS
? o1.ToLowercase("tunis") #--> tunis
? o1.ToTitlecase("tunis") #--> Tunis

/*-------------

? DefaultLocaleSeparator()				
? UnifiyLocaleAbbreviationSeparator("ar_TN-tun")	

/*-------------

// Testing the conversion of time to string
o1 = new stzLocale("ru_RU")
? o1.CountryName()
? o1.CountryNativeName()
? o1.CurrencyFraction()
/*
? o1.amText()
? o1.MeasurementSystem()
? o1.ToTimeAsString("05:08:34", :Default)

#? o1.ToStzTime("05:08:34").ToString(o1.TimeFormat(:Long))
	# returns 5:08:34  Paris, Madrid (heure d’été)
	# Which is not correct because this is influenced by
	# the system locale on my machine (french) and not
	# the locale we defined ("en_US")

# "hh:mm:sss.zzz"

/*-------------

// Testing currency
o1 = new stzLocale("iran")

? o1.CurrencySymbol()
? o1.CurrencyNativeName()
? o1.CurrencyName()
? o1.CurrencyFraction()
? o1.CurrencyBase()

oHash = new stzHashList( o1.CurrencyInfo() )
? oHash.Show()

? o1.CurrencyISOSymbol() + NL

? o1.CurrencyNativeSymbol()
? o1.CurrencyNativeName()

/*-------------

o1 = new stzLocale("ar_TN")
? o1.CurrencyXT(:ISOSymbol)
? o1.CurrencyXT(:NativeSymbol)
? o1.CurrencyXT(:NativeName) + NL

o1 = new stzLocale("ru_RU")
? o1.CurrencyXT(:ISOSymbol)
? o1.CurrencyXT(:NativeSymbol)
? o1.CurrencyXT(:NativeName)

/*-------------

o1 = new stzHashList( LanguagesAndTheirDefaultCountries() )
? o1.Show()

? LanguagesForWhichDefaultCountryIs("fr")

/*-------------

o1 = new stzHashList( CountriesAndTheirDefaultLanguages() )
? o1.Show()

? CountriesforWhichDefaultLanguageIs("arabic")

/*-------------

o1 = new stzHashList( ScriptsAndTheirDefaultLanguages() )
? o1.Show()

? ScriptsforWhichDefaultLanguageIs("mongolian")

/*-------------

// Defining a locale from two or three parameters
#o1 = new stzLocale([ :Language = "french", :Country = "Mali" ])
#o1 = new stzLocale([ :Language = "ara", :Script = "arabic" ])
#o1 = new stzLocale([ :Country = "brazil", :Script = "latin" ])
#o1 = new stzLocale([ :Country = "Spain", :Language = "Spanish", :Script = "latin" ])
 o1 = new stzLocale("pt_Latn_BR")
? o1.Abbreviation()
? o1.language()
? o1.Script()
? o1.Country()

/*-------------

o1 = new stzLocale([ :Language = "pt", :Script = "Latn", :Country = "BR" ])
? o1.Abbreviation()
? o1.LanguageName()
? o1.CountryName()
? o1.CountryNumber() + NL

/*-------------

// Defining a locale from just a language
o1 = new stzLocale([ :Language = "romanian" ])
o1 = new stzLocale("ro")

? o1.QtAbbreviation()
? o1.Abbreviation() + NL

? o1.LanguageNumber()
? o1.LanguageName() + NL

? o1.CountryNumber()
? o1.CountryName()

/*-------------

// Defining a locale from just a country
o1 = new stzLocale([ :Country = "Niger" ])
? o1.Abbreviation()
? o1.LanguageName()
? o1.CountryName() + NL

/*-------------

// Defining a locale from just a script
o1 = new stzLocale([ :Script = "Mongolian" ])
? o1.Abbreviation()
? o1.LanguageName()
? o1.CountryName()

/*-------------

? GetCountryNumber("tunisia")

? SystemLocale() + NL # Gives fr_FR

? CountriesforWhichDefaultLanguageIs(:russian)
# Gives [ :antarctica, :antarctica, :kyrgyzstan, :russia ]

? ScriptsforWhichDefaultLanguageIs(:aramaic)
# Gives [ :samaritan, :nabataean, :palmyrene ]

/*-------------

o1 = new stzHashList( ScriptsAndTheirDefaultLanguages() )
? o1.Show()

/*
? ScriptsforWhichDefaultLanguageIs(:english)

/*-------------

o1 = new stzString("2")
? o1.IsScriptName()
? o1.IsScriptAbbreviation()
? o1.IsScriptNumber()

/*-------------

? SystemLocale()

o1 = new stzLocale([ :Language = "arabic", :Country = "tunisia" ])
? o1.LanguageName()

/*-------------

? StringIsLocaleAbbreviation("ar_tn")

/*-------------

o1 = new stzLocale("fr")
? o1.LanguageName()
? o1.CountryName()
? o1.ScriptName()

/*-------------

o1 = new stzLocale("es")
? o1.LanguageName()

? o1.LanguageAbbreviation()
? o1.bcp47Abbreviation()
? StzStringQ("es_ES").IsLocaleAbbreviation()

/*-------------

o1 = new stzLocale(:C)
? o1.LanguageName()

o1 = new stzLocale(:system)
? o1.LanguageName()

/*-------------

o1 = new stzLocale("fr_FR")
//o1 = new stzLocale([:Country = "fr", :Language = "fr"])
? o1.LanguageName()
? o1.bcp47Abbreviation()
? o1.FirstDayOfWeek()
? o1.CurrencyName()

/*-------------

// Getting abbreviation with the default separator
SetDefaultSeparatorForLocales("_")

o1 = new stzLocale("en-US")
? o1.Abbreviation()
? o1.QtAbbreviation()
? o1.Country()

/*-------------

// Testing time formats
o1 = new stzLocale("en-Latn-US")
? o1.Abbreviation()
? o1.TimeShortFormat()
? o1.TimeLongFormat()
? o1.TimeNarrowFormat() + NL

/*-------------

? QLocaleToStzLocale( new QLocale("ru_RU") ).Country()

/*-------------

//? DefaultDaysOfWeek()
// Testing the nth day of week
o1 = new stzLocale("en_US")

? o1.Country()
? o1.Abbreviation()
? o1.FirstDayOfWeek() + NL

? o1.NthDayOfWeek(1) + NL

? o1.DaysOfWeek()

/*-------------

o1 = new stzLocale("en_US")
? o1.ToLowercase("FDMLj")
? o1.ToUPPERcase("FDMLj")

? o1.amText()
? o1.pmText()

? o1.DecimalPoint()
? o1.Exponential()
? o1.GroupSeparator()

? o1.NegativeSign()
? o1.PositiveSign()
? o1.Percent()

? o1.GroupSeparator()

/*-------------

_aLocaleNumberOptions = [
	:Default = 0,
	:OmitGroupSeparator = 1,
	:RejectGroupSeparator = 2,
	:OmitLeadingZeroInExponent = 4,
	:RejectLeadingZeroInExponent = 8,
	:IncludeTrailingZeroesAfterDot = 16,
	:RejectTrailingZeroesAfterDot = 32
]

o1 {


? ""
	? firstDayOfWeek() # ??
	/*
	"1" = :Monday,
	"2" = :Tuesady,
	"3" = :Wednesday,
	"4" = :Thursday,
	"5" = :Friday,
	"6" = :Saturday,
	"7" = :Sunday
	*/

//	? measurementSystem()
	/*
	"0" = :MetricSystem,
	"1" = :ImperialUSSystem,
	"2" = :ImperialUKSystem,
	"3" = :ImperialSystem
	*/

//	? numberOptions()


//	? toUPPERcase("Πόλη")
//	? toLowercase("ABC")

//	? textDirection()
	/*
	"0" = :LeftToright
	"1" = :rightToLeft
	"2" = :Automatic
	*/

//	obj = new stzListOfStrings( uiLanguages() )
//	? obj.Content()

//	? system().name()

	//? o1.weekdays() # !!! returns nothing!

//	? zerodigit().unicode()
	# shall change from QChar to QString in Qt 6...

//}

/*-------------

StzLocaleQ("en_GB") {
	? Separator()		#--> "_"
	SetSeparator("-")
	? Abbreviation()	#--> "en-GB"
}
