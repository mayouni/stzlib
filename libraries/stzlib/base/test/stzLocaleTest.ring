load "../stzbase.ring"

/*---

pr()

oQLocale = new QLocale("C")
? oQLocale.toLower("RING")
#--> "ring"

pf()
# Executed in almost 0 second(s) in Ring 1.18 in Ring 1.2
# Executed in 0.03 second(s) in Ring 1.18 in Ring 1.18

/*---

pr()

o1 = new stzLocale("de-DE")
? o1.Abbreviation()
#--> de_DE

pf()

/*--- #TODO Replace with SetCurrentLocale()

pr()

SetDefaultLocale("ar-TN")
? DefaultLocale() #--> ar-TN

pf()

/*---

pr()

StzLocaleQ([ :Country = :Tunisia ]) {
	? Abbreviation()	#--> ar_TN
	? CountryName()		#--> tunisia
}

pf()
# Executed in 0.01 second(s) in Ring 1.18 in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.18 in Ring 1.18

/*---

profon()

StzCountryQ(:palau) {
	? Name()				#--> palau
	? LocaleAbbreviation() 	#--> "en-PW"
}

proff()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.18

/*--- Qt

pr()

o1 = new QLocale("ja-PW")
? o1.country() #--> 108

? StzCountryQ("108").Name() #--> japan

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ("ja-JP") {
	? CountryName()		#--> japan
	? LanguageName()	#--> japanese
}

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ("en-PW") {
	? CountryName()		#--> palau
	? LanguageName()	#--> english
}

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- #TODO ERROR: returns NULL!

pr()

StzLocaleQ([ :Country = :palau ]) {
	? CountryName()	# !--> palau
}

pf()

/*---

pr()

StzLocaleQ("ar-TN") {
	? CountryName()		#--> tunisia
	? LanguageName()	#--> arabic
}

StzLocaleQ("fr-TN") {
	? CountryName()		#--> tunisia
	? LanguageName()	#--> french
}

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*----

pr()

StzLocaleQ("ps-AF") {
	? CountryName()		#--> afghanistan
	? LanguageName()	#--> pashto
}

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*----

pr()

o1 = new stzString("chinese yuan")
? o1.Capitalised()
#--> Chinese Yuan

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pf()

StzLocaleQ("zh-CN") {		
	? CountryName()				#--> china
	? LanguageName()			#--> literary_chinese
	? Currency()				#--> Chinese Yuan
	? CurrencyAbbreviation()	#--> CNY
}

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.18

/*---

pr()

StzCountryQ("china") {
	? country()					#--> china
	? abbreviation()			#--> CN

	? longAbbreviation()		#--> CHN
	# or AbbreviationXT()

	? LocaleAbbreviation()

	? Currency()				#--> chinese_yuan
	? CurrencyAbbreviation()	#--> CNY
}

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.18

/*---- #TODO

pr()

? StzLocaleQ("sm-WS").CountryName() #--> NULL! (see why)

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*----

pr()

StzCountryQ(:american_samoa) {
	? Name()					#--> american_samoa
	? Language()				#--> samaon

	? LanguageAbbreviation()	#--> "sm"
	? Abbreviation()			#--> "AS"

	? LocaleAbbreviation()		#--> "en-AS"
}

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---- #TODO

pr()

? StzLocaleQ("sm-AS").Abbreviation()	#--> "C" but should be "sm_AS"
? StzLocaleQ([ :Country = :american_samoa ]).Abbreviation()	#--> "C" but should "sm_AS"

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*----

pr()

StzLocaleQ("en_AS") {
	? Abbreviation()	#--> en_AS
	? CountryName()		#--> american_samoa
	? LanguageName()	#--> english
}

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---- #TODO Qt ERROR

pr()

oQLocale = new QLocale("cmn-CN")
? oQLocale.name()	# Should return China locale but returns C Locale

#--> This induces stzLocale in error:

? StzLocaleQ("cmn_CN").CountryName()	# returns NULL but should return China!

#--> TODO: Verify this bug for all the other locales (see next code)

pf()

/*---- #TODO

pr()

// Check the name of China in country names!
? StzLocaleQ([ :Language = :Chinese ]).CountryName() #-->NULL ! Todo: Why?
? StzLocaleQ([ :Country = :China ]).CountryName() #-->NULL ! Todo: Why?

? StzCountryQ(:China).Language() #--> Chinese

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

# All these return the abbreviation ru_RU

? StzLocaleQ([ :Language = :Russian, :Script = :Latin, :Country = :Russia ]).Abbreviation()
? StzLocaleQ([ :Language = :Russian ]).Abbreviation()
? StzLocaleQ([ :Country = :Russia ]).Abbreviation()
? StzLocaleQ([ :Language = :Russian, :Script = :Latin ]).Abbreviation()
? StzLocaleQ([ :Language = :Russian, :Country = :Russia ]).Abbreviation()
? StzLocaleQ([ :Script = :Latin, :Country = :Russia ]).Abbreviation()

#--> ru_RU

pf()
# Executed in 0.09 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ([ :Country = :Iran ]) {
	? Abbreviation()			 				#--> fa_IR
	? NthDayOfWeek(1)			 				#--> saturday
	? NativeNthDayOfWeek(1) + NL		 		#--> شنبه

	? NthDayOfWeekAbbreviation(1)		 		#--> Sat
	? NativeNthDayOfWeekAbbreviation(1) + NL 	#--> دوشنبه

	? NthDayOfWeekSymbol(1)			 			#--> S
	? NativeNthDayOfWeekSymbol(1)		 		#--> د
}

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.07 second(s) in Ring 1.18

/*---

pr()

StzLocaleQ([ :Language = :Persian ]) {
	? Abbreviation()			 				#--> fa_IR
	? NthDayOfWeek(1)						 	#--> saturday
	? NativeNthDayOfWeek(1) + NL		 		#--> شنبه

	? NthDayOfWeekAbbreviation(1)		 		#--> Sat
	? NativeNthDayOfWeekAbbreviation(1) + NL 	#--> دوشنبه

	? NthDayOfWeekSymbol(1)			 			#--> S
	? NativeNthDayOfWeekSymbol(1)		 		#--> د
}

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ([ :Script = :Arabic ]) {
	? Abbreviation()			 				#--> ar_EG
	? NthDayOfWeek(1)			 				#--> saturday
	? NativeNthDayOfWeek(1) + NL		 		#--> السبت

	? NthDayOfWeekAbbreviation(1)		 		#--> Sat
	? NativeNthDayOfWeekAbbreviation(1) + NL 	#--> الاثنين

	? NthDayOfWeekSymbol(1)			 			#--> S
	? NativeNthDayOfWeekSymbol(1)		 		#--> ن
}

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ([ :Language = :russian, :Country = :Russia ]) {
	? Abbreviation()			 				#--> ru_RU
	? NthDayOfWeek(1)							#--> monday
	? NativeNthDayOfWeek(1) + NL		 		#--> понедельник

	? NthDayOfWeekAbbreviation(1)		 		#--> Mon
	? NativeNthDayOfWeekAbbreviation(1) + NL 	#--> пн

	? NthDayOfWeekSymbol(1)			 			#--> M
	? NativeNthDayOfWeekSymbol(1)		 		#--> пн
}

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ([ :Language = :russian, :Script = :latin ]) {
	? Abbreviation()			 				#--> ru_RU
	? NthDayOfWeek(1)			 				#--> monday
	? NativeNthDayOfWeek(1) + NL		 		#--> понедельник

	? NthDayOfWeekAbbreviation(1)		 		#--> Mon
	? NativeNthDayOfWeekAbbreviation(1) + NL 	#--> пн

	? NthDayOfWeekSymbol(1)			 			#--> M
	? NativeNthDayOfWeekSymbol(1)		 		#--> пн
}

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ([ :Script = :Latin, :Country = :Russia ]) {
	? Abbreviation()			 				#--> ru_RU		
	? NthDayOfWeek(1)			 				#--> monday
	? NativeNthDayOfWeek(1) + NL		 		#--> понедельник

	? NthDayOfWeekAbbreviation(1)		 		#--> Mon
	? NativeNthDayOfWeekAbbreviation(1) + NL 	#--> пн

	? NthDayOfWeekSymbol(1)			 			#--> M
	? NativeNthDayOfWeekSymbol(1)		 		#--> пн
}

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*----

pr()

? Q("ar_arab_tn").ContainsNTimes(2,"_")	#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*----

pr()

? StzLocaleQ([ :Country = :Tunisia ]).NthDayOfWeek(3)		# tuesday
? StzLocaleQ([ :Country = :Tunisia ]).NthNativeDayOfWeek(3)	# الأربعاء

? StzLocaleQ("ar-TN").NthDayOfWeek(3)		# tuesday
? StzLocaleQ("ar-TN").NthNativeDayOfWeek(3)	# الأربعاء

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*----

pr()

? StzLocaleQ("ar-TN").DaysOfWeek()
#-->
'
monday
tuesady
wednesday
thirsday
friday
saturday
sunday
'
? StzLocaleQ("ar-TN").NativeDaysOfWeek()
#-->
'
الاثنين
الثلاثاء
الأربعاء
الخميس
الجمعة
السبت
الأحد
'

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*----

pr()

? NamesOfDaysIn(:Tunisia)
#-->
'
الاثنين
الثلاثاء
الأربعاء
الخميس
الجمعة
السبت
الأحد
'

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*----

pr()

? NamesOfMonthsIn(:Algeria)
#-->
'
جانفي
فيفري
مارس
أفريل
ماي
جوان
جويلية
أوت
سبتمبر
أكتوبر
نوفمبر
ديسمبر
'

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*----

pr()

? NamesOfDaysIn(:Persian)
#o--> [ "شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنجشنبه", "جمعه" ]

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*----

pr()

? NamesOfDaysIn(:Japanese)  # Or ...In(:Japan)
#--> [ "日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日" ]


? Association([ NamesOfDaysIn(:English), NamesOfDaysIn(:Japanese) ])
#-->
'
[
	[ "Sunday", "日曜日" ],
	[ "Monday", "月曜日" ],
	[ "Tuesday", "火曜日" ],
	[ "Wednesday", "水曜日" ],
	[ "Thursday", "木曜日" ],
	[ "Friday", "金曜日" ],
	[ "Saturday", "土曜日" ]
]
'

pf()
# Executed in 0.042 second(s) in Ring 1.23

/*----

pr()

? NamesOfMonthsIn(:Japanese) # Or ...In(:Japan)
#--> [ "1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月" ]

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.08 second(s) in Ring 1.18

/*---- #TODO #ERROR returns english names!

pr()

? NamesOfDaysIn(:Chinese)

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---- #TODO

pr()

#TODO Add these based on the Qt implementation below
//DayNativeName()
//DayNativeShortAbbreviation()
//DayNativeNarrowAbbreviation()
//MonthNativeName()
//MonthNativeShortAbbreviation()
//MonthNativeNarrowAbbreviation()
#--> Imagine shoret aliaises, and a general DayNativeXT(:Name or :Month, :Format)

o1 = new Qlocale("fr_FR")
? o1.dayname(1,0)	# 0: Long format		1: Short format		2: Narrow format
#--> lundi

? o1.dayname(1,1)
#--> lun.

? o1.dayname(1,2)
#--> L

// This type is used when you need to enumerate months or weekdays.
// Usually standalone names are represented in singular forms with capitalized first letter.

? o1.monthname(1,0) #--> janvier
? o1.monthname(1,2) #--> J

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*----

pr()

o1 = new stzLocale([ :Language = :Spanish, :Country = :Spain ])
? o1.Abbreviation()	#--> es_ES

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*----

pr()

o1 = new stzLocale("ar-TN")
? o1.Abbreviation()	#--> ar_TN

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

? IsLanguageAbbreviation("")	#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

? StzListQ([ :Country = :Tunisia ]).IsLocaleList()		#--> TRUE
? StzLocaleQ([ :Country = :Tunisia ]).Abbreviation()	#--> ar_TN

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ([ :Language = :French ]) {
	? Country()
	#--> france

	? ToTitlecase("in search of lost time")
	#--> In search of lost time
}

pf()
# Executed in 0.14 second(s) in Ring 1.23
# Executed in 0.78 second(s) in Ring 1.18

/*---

pr()

StzLocaleQ([ :Language = :English ]) {
	? Country()
	#--> united_states

	? ToTitlecase("in search of lost time")
	#--> In Search Of Lost Time
}

pf()
# Executed in 0.15 second(s) in Ring 1.23
# Executed in 0.78 second(s) in Ring 1.18

/*---

pr()

StzStringQ("tunisian dinar") {
	TitlecaseInLocale("fr-FR")
	? Content()
	#--> Tunisian dinar

	TitlecaseInLocale("en-US")
	? Content()
	#--> Tunisian Dinar
}

pf()

/*---

pr()

StzLocaleQ([ :Country = :Qatar ]) {

	? CurrencyName()			#--> Qatari Riyal
	? CurrencyNativeName()		#--> ريال قطري
	? CurrencySymbol()			#--> ر.ق.‏
	? CurrencyAbbreviation()	#--> QAR
	? CurrencyFraction()		#--> Dirham
	? CurrencyBase()			#--> 100

}

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

? StzStringQ("ar").IsLanguageAbbreviation()
#--> TRUE

? IsLanguageAbbreviation("ar")
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

? StzLocaleQ("ar_eg").CountryPhoneCode()
#--> "+20"

? StzLocaleQ([ :Country = :Niger ]).CountryPhoneCode()
#--> +227

? StzLocaleQ(:Niger).CountryPhoneCode()
#--> +227

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ("tn") {
	? Abbreviation()				#--> tn_ZA
	? CountryNumber()				#--> 195
	? CountryName()					#--> south_africa
	? CountryNativeName()			#--> iNingizimu Afrika
	? CountryShortAbbreviation()	#--> ZA
	? CountryLongAbbreviation()		#--> ZAF
}

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

? StzLocaleQ([ :Country = :South_Africa, :Language = :tswana ]).CountryNativeName()
#--> iNingizimu Afrika

? StzLocaleQ([ :Country = :South_Africa, :Language = :tswana ]).LanguageNativeName()
#--> isiZulu

pf()
# Executed in 0.06 second(s) in Ring 1.23

/*---

pr()

? StzLocaleQ("ar_Arab").CountryName()			#--> egypt
? StzLocaleQ("ar_Arab").CountryNativeName()		#--> مصر
? StzLocaleQ("ar_Arab").LanguageName()			#--> arabic
? StzLocaleQ("ar_Arab").LanguageNativeName()	#--> العربية

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ("tn_ZA") {
	? CountryName()			#--> south_africa
	? CountryNativeName()	#--> iNingizimu Afrika
	? LanguageName()		#--> tswana
	? LanguageNativeName()	#--> isiZulu
}

pf()
# Executed in 0.04 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ("ar_TN") {
	? CountryName()		#--> tunisia
	? CountryNativeName()	#--> تونس
	? LanguageName()	#--> arabic
	? LanguageNativeName()	#--> العربية
}

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ("fa_IR") {
	? CountryName()			#--> iran
	? CountryNativeName()	#--> ايران
	? LanguageName()		#--> persian
	? LanguageNativeName()	#--> فارسی
}

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ("ru_RU") {
	? CountryName()			#--> russia
	? CountryNativeName()	#--> Россия
	? LanguageName()		#--> russian
	? LanguageNativeName()	#--> русский
}

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*---

pr()

StzLocaleQ("en_US") {
	? CountryName()			#--> united_states
	? CountryNativeName()	#--> United States
	? LanguageName()		#--> english
	? LanguageNativeName()	#--> American English
}

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*---

pr()

? StzLocaleQ([ :Country = :south_africa ]).CountryNativeName()
#--> iNingizimu Afrika

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

? StzLocaleQ([ :Country = :Tunisia ]).CountryNumber()
#--> "216"

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

o1 = new stzLocale("fr_FR")
? o1.ToUppercase("tunis") #--> TUNIS
? o1.ToLowercase("tunis") #--> tunis
? o1.ToTitlecase("tunis") #--> Tunis

pf()
# Executed in 0.04 second(s) in Ring 1.23

/*--- #TODO Add these features

pr()

? DefaultLocaleSeparator()				
? UnifiyLocaleAbbreviationSeparator("ar_TN-tun")	

pf()

/*---

pr()

o1 = new stzTime("05:08:34")
? o1.ToStringXT(:Long) # Or ToLong()
#--> 05:08:34.000

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- #TODO check error

pr()

# Testing the conversion of time to string

o1 = new stzLocale("ru_RU")
? o1.CountryName()			#--> russia
? o1.CountryNativeName()	#--> Россия
? o1.CurrencyFraction()		#--> Kopek

? o1.amText() #--> AM
? o1.MeasurementSystem() #--> metricsytem

? o1.ToTimeAsString("05:08:34", :Default) #TODO //Check why it returns an error!
#-->  Invalid time provided!

? o1.ToStzTime("05:08:34").ToStringXT(:Long) #TODO //Check why it returns nothing!
	# returns 5:08:34  Paris, Madrid (heure d’été)
	# Which is not correct because this is influenced by
	# the system locale on my machine (french) and not
	# the locale we defined ("en_US")

# "hh:mm:sss.zzz"

pf()

/*=== Currency

pr()

o1 = new stzLocale("iran")

? o1.CurrencySymbol()		#--> ریال
? o1.CurrencySymbol()		#--> ریال
? o1.CurrencyISOSymbol() 	#--> IRR

? o1.CurrencyNativeName()	#--> ریال ایران
? o1.CurrencyName()			#--> Iranian Rial
? o1.CurrencyFraction()		#--> Rial
? o1.CurrencyBase()			#--> 100

? @@NL( o1.CurrencyInfo() )
#-->
'
[
	[ "name", "Iranian Rial" ],
	[ "nativename", "ریال ایران" ],
	[ "abbreviation", "IRR" ],
	[ "symbol", "ریال" ],
	[ "nativesymbol", "ریال" ],
	[ "isosymbol", "IRR" ],
	[ "fractionalunit", "Rial" ],
	[ "fraction", "Rial" ],
	[ "base", 100 ]
]
'

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

o1 = new stzLocale("ar_TN")
? o1.Currency()
#--> Tunisian Dinar

? o1.CurrencyXT(:NativeName) #--> دينار تونسي
? o1.CurrencyXT(:Fraction)	 #--> Millime

? @@NL( o1.CurrencyInfo() )
#-->
'
[
	[ "name", "Tunisian Dinar" ],
	[ "nativename", "دينار تونسي" ],
	[ "abbreviation", "TND" ],
	[ "symbol", "د.ت.‏" ],
	[ "nativesymbol", "د.ت.‏" ],
	[ "isosymbol", "TND" ],
	[ "fractionalunit", "Millime" ],
	[ "fraction", "Millime" ],
	[ "base", 1000 ]
]
'

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

o1 = new stzLocale("ru_RU")
? @@NL( o1.CurrencyInfo() )
#-->
'
[
	[ "name", "Russian Ruble" ],
	[ "nativename", "российский рубль" ],
	[ "abbreviation", "RUB" ],
	[ "symbol", "₽" ],
	[ "nativesymbol", "₽" ],
	[ "isosymbol", "RUB" ],
	[ "fractionalunit", "Kopek" ],
	[ "fraction", "Kopek" ],
	[ "base", 100 ]
]
'

? o1.CurrencyXT(:Name)			#--> Russian Ruble
? o1.CurrencyXT(:ISOSymbol)		#--> RUB
? o1.CurrencyXT(:NativeSymbol)	#--> ₽
? o1.CurrencyXT(:NativeName)	#--> российский рубль

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*---

pr()

? @@NL( LanguagesAndTheirDefaultCountries() )
#-->
'
[
	[ "c", "" ],
	[ "abkhazian", "abkhazia" ],
	[ "oromo", "ethiopia" ],
	[ "afar", "ethiopia" ],
	[ "afrikaans", "south_africa" ],
	[ "albanian", "albania" ],
	[ "amharic", "ethiopia" ],
	[ "arabic", "egypt" ],
	[ "armenian", "armenia" ],
	[ "assamese", "india" ],
	[ "aymara", "bolivia" ],
	[ "azerbaijani", "azerbaijan" ],
	[ "bashkir", "russia" ],
	[ "basque", "spain" ],
	[ "bengali", "bangladesh" ],
	[ "dzongkha", "bhutan" ],
	[ "bislama", "vanuatu" ],
	[ "breton", "france" ],
	[ "bulgarian", "bulgaria" ],
	[ "burmese", "myanmar" ],
	[ "belarusian", "belarus" ],
	[ "khmer", "cambodia" ],
	[ "catalan", "spain" ],
	[ "chinese", "china" ],
	[ "corsican", "france" ],
	[ "croatian", "croatia" ],
	[ "czech", "czech_republic" ],
	[ "danish", "denmark" ],
	[ "dutch", "netherlands" ],
	[ "english", "united_states" ],
	[ "esperanto", "united_kingdom" ],
	[ "estonian", "estonia" ],
	[ "faroese", "faroe_islands" ],
	[ "fijian", "fiji" ],
	[ "finnish", "finland" ],
	[ "french", "france" ],
	[ "western_frisian", "netherlands" ],
	[ "gaelic", "united_kingdom" ],
	[ "galician", "spain" ],
	[ "georgian", "georgia" ],
	[ "german", "germany" ],
	[ "greek", "greece" ],
	[ "greenlandic", "greenland" ],
	[ "guarani", "paraguay" ],
	[ "gujarati", "india" ],
	[ "hausa", "nigeria" ],
	[ "hebrew", "israel" ],
	[ "hindi", "india" ],
	[ "hungarian", "hungary" ],
	[ "icelandic", "iceland" ],
	[ "indonesian", "world" ],
	[ "interlingua", "" ],
	[ "interlingue", "norway" ],
	[ "inuktitut", "canada" ],
	[ "inupiak", "united_states" ],
	[ "irish", "ireland" ],
	[ "italian", "italy" ],
	[ "japanese", "japan" ],
	[ "javanese", "indonesia" ],
	[ "kannada", "india" ],
	[ "kashmiri", "india" ],
	[ "kazakh", "kazakhstan" ],
	[ "kinyarwanda", "rwanda" ],
	[ "kirghiz", "kyrgyzstan" ],
	[ "korean", "south_korea" ],
	[ "kurdish", "turkey" ],
	[ "rundi", "burundi" ],
	[ "lao", "laos" ],
	[ "latin", "italy" ],
	[ "latvian", "latvia" ],
	[ "lingala", "congo_kinshasa" ],
	[ "lithuanian", "lithuania" ],
	[ "macedonian", "macedonia" ],
	[ "malagasy", "madagascar" ],
	[ "malay", "malaysia" ],
	[ "malayalam", "india" ],
	[ "maltese", "malta" ],
	[ "maori", "new_zealand" ],
	[ "marathi", "india" ],
	[ "marshallese", "marshall_islands" ],
	[ "mongolian", "mongolia" ],
	[ "nauruan", "nauru" ],
	[ "nepali", "nepal" ],
	[ "norwegian_bokmal", "norway" ],
	[ "occitan", "france" ],
	[ "oriya", "india" ],
	[ "pashto", "afghanistan" ],
	[ "persian", "iran" ],
	[ "polish", "poland" ],
	[ "portuguese", "brazil" ],
	[ "punjabi", "india" ],
	[ "quechua", "peru" ],
	[ "romansh", "switzerland" ],
	[ "romanian", "romania" ],
	[ "russian", "russia" ],
	[ "samoan", "samoa" ],
	[ "sango", "central_african_republic" ],
	[ "sanskrit", "india" ],
	[ "serbian", "serbia" ],
	[ "ossetic", "georgia" ],
	[ "southern_sotho", "south_africa" ],
	[ "tswana", "south_africa" ],
	[ "shona", "zimbabwe" ],
	[ "sindhi", "pakistan" ],
	[ "sinhala", "sri_lanka" ],
	[ "swati", "south_africa" ],
	[ "slovak", "slovakia" ],
	[ "slovenian", "slovenia" ],
	[ "somali", "somalia" ],
	[ "spanish", "spain" ],
	[ "sundanese", "indonesia" ],
	[ "swahili", "tanzania" ],
	[ "swedish", "sweden" ],
	[ "sardinian", "italy" ],
	[ "tajik", "tajikistan" ],
	[ "tamil", "india" ],
	[ "tatar", "russia" ],
	[ "telugu", "india" ],
	[ "thai", "thailand" ],
	[ "tibetan", "china" ],
	[ "tigrinya", "ethiopia" ],
	[ "tongan", "tonga" ],
	[ "tsonga", "south_africa" ],
	[ "turkish", "turkey" ],
	[ "turkmen", "turkmenistan" ],
	[ "tahitian", "french_polynesia" ],
	[ "uighur", "china" ],
	[ "ukrainian", "ukraine" ],
	[ "urdu", "pakistan" ],
	[ "uzbek", "uzbekistan" ],
	[ "vietnamese", "vietnam" ],
	[ "volapuk", "" ],
	[ "welsh", "united_kingdom" ],
	[ "wolof", "senegal" ],
	[ "xhosa", "south_africa" ],
	[ "yiddish", "bosnia_and_herzegowina" ],
	[ "yoruba", "nigeria" ],
	[ "zhuang", "china" ],
	[ "zulu", "south_africa" ],
	[ "norwegian_nynorsk", "norway" ],
	[ "bosnian", "bosnia_and_herzegowina" ],
	[ "divehi", "maldives" ],
	[ "manx", "isle_of_man" ],
	[ "cornish", "united_kingdom" ],
	[ "akan", "ghana" ],
	[ "konkani", "india" ],
	[ "ga", "ghana" ],
	[ "igbo", "nigeria" ],
	[ "kamba", "kenya" ],
	[ "syriac", "iraq" ],
	[ "blin", "sudan" ],
	[ "geez", "eritrea" ],
	[ "koro", "china" ],
	[ "sidamo", "ethiopia" ],
	[ "atsam", "nigeria" ],
	[ "tigre", "ethiopia" ],
	[ "jju", "nigeria" ],
	[ "friulian", "italy" ],
	[ "venda", "south_africa" ],
	[ "ewe", "ghana" ],
	[ "walamo", "ethiopia" ],
	[ "hawaiian", "united_states_of_america" ],
	[ "tyap", "nigeria" ],
	[ "nyanja", "malawi" ],
	[ "filipino", "philippines" ],
	[ "swiss_german", "switzerland" ],
	[ "sichuan_yi", "china" ],
	[ "kpelle", "liberia" ],
	[ "low_german", "germany" ],
	[ "south_ndebele", "south_africa" ],
	[ "northern_sotho", "south_africa" ],
	[ "northern_sami", "norway" ],
	[ "taroko", "taiwan" ],
	[ "gusii", "kenya" ],
	[ "taita", "kenya" ],
	[ "fulah", "senegal" ],
	[ "kikuyu", "kenya" ],
	[ "samburu", "kenya" ],
	[ "sena", "zimbabwe" ],
	[ "north_ndebele", "zimbabwe" ],
	[ "rombo", "tanzania" ],
	[ "tachelhit", "morocco" ],
	[ "kabyle", "algeria" ],
	[ "nyankole", "uganda" ],
	[ "bena", "tanzania" ],
	[ "vunjo", "tanzania" ],
	[ "bambara", "mali" ],
	[ "embu", "kenya" ],
	[ "cherokee", "united_states_of_america" ],
	[ "mauritian", "mauritius" ],
	[ "makonde", "tanzania" ],
	[ "langi", "uganda" ],
	[ "ganda", "uganda" ],
	[ "bemba", "zambia" ],
	[ "kabuverdianu", "cape_verde" ],
	[ "meru", "kenya" ],
	[ "kalenjin", "kenya" ],
	[ "nama", "namibia" ],
	[ "machame", "tanzania" ],
	[ "colognian", "germany" ],
	[ "masai", "kenya" ],
	[ "soga", "uganda" ],
	[ "luyia", "kenya" ],
	[ "asu", "tanzania" ],
	[ "teso", "kenya" ],
	[ "saho", "eritrea" ],
	[ "koyra_chiini", "mali" ],
	[ "rwa", "tanzania" ],
	[ "luo", "kenya" ],
	[ "chiga", "uganda" ],
	[ "standard_morocco_tamazight", "morocco" ],
	[ "koyraboro_senni", "mali" ],
	[ "shambala", "tanzania" ],
	[ "bodo", "bangladesh" ],
	[ "avaric", "azerbaijan" ],
	[ "chamorro", "guam" ],
	[ "chechen", "russia" ],
	[ "church", "italy" ],
	[ "chuvash", "russia" ],
	[ "cree", "canada" ],
	[ "haitian", "haiti" ],
	[ "herero", "namibia" ],
	[ "hiri_motu", "papua_new_guinea" ],
	[ "kanuri", "nigeria" ],
	[ "komi", "russia" ],
	[ "kongo", "congo_kinshasa" ],
	[ "kwanyama", "angola" ],
	[ "limburgish", "netherlands" ],
	[ "luba_katanga", "congo_kinshasa" ],
	[ "luxembourgish", "luxembourg" ],
	[ "navaho", "united_states_of_america" ],
	[ "ndonga", "namibia" ],
	[ "ojibwa", "canada" ],
	[ "pali", "india" ],
	[ "walloon", "belgium" ],
	[ "aghem", "cameroon" ],
	[ "basaa", "cameroon" ],
	[ "zarma", "niger" ],
	[ "duala", "cameroon" ],
	[ "jola_fonyi", "senegal" ],
	[ "ewondo", "cameroon" ],
	[ "bafia", "cameroon" ],
	[ "makhuwa_meetto", "mozambique" ],
	[ "mundang", "chad" ],
	[ "kwasio", "cameroon" ],
	[ "coptic", "egypt" ],
	[ "sakha", "russia" ],
	[ "sangu", "tanzania" ],
	[ "tasawaq", "niger" ],
	[ "vai", "liberia" ],
	[ "walser", "switzerland" ],
	[ "yangben", "cameroon" ],
	[ "avestan", "afghanistan" ],
	[ "ngomba", "cameroon" ],
	[ "kako", "cameroon" ],
	[ "meta", "cameroon" ],
	[ "ngiemboon", "cameroon" ],
	[ "aragonese", "spain" ],
	[ "akkadian", "irak" ],
	[ "ancient_egyptian", "egypt" ],
	[ "ancient_greek", "greece" ],
	[ "aramaic", "syria" ],
	[ "balinese", "indonesia" ],
	[ "bamun", "cameroon" ],
	[ "batak_toba", "indonesia" ],
	[ "buginese", "indonesia" ],
	[ "chakma", "bangladesh" ],
	[ "dogri", "india" ],
	[ "gothic", "germany" ],
	[ "ingush", "russia" ],
	[ "mandingo", "guinea" ],
	[ "manipuri", "india" ],
	[ "old_irish", "ireland" ],
	[ "old_norse", "norway" ],
	[ "old_persian", "iran" ],
	[ "pahlavi", "iran" ],
	[ "phoenician", "lebanon" ],
	[ "santali", "india" ],
	[ "saurashtra", "india" ],
	[ "tai_dam", "vietnam" ],
	[ "tai_nua", "china" ],
	[ "ugaritic", "syria" ],
	[ "akoose", "cameroon" ],
	[ "lakota", "united_states_of_america" ],
	[ "standard_moroccan_tamazight", "morocco" ],
	[ "mapuche", "chile" ],
	[ "central_kurdish", "turkey" ],
	[ "lower_sorbian", "germany" ],
	[ "upper_sorbian", "germany" ],
	[ "kenyang", "cameroon" ],
	[ "mohawk", "canada" ],
	[ "nko", "guinea" ],
	[ "prussian", "germany" ],
	[ "kiche", "guatemala" ],
	[ "southern_sami", "norway" ],
	[ "lule_sami", "norway" ],
	[ "inari_sami", "finland" ],
	[ "skolt_sami", "finland" ],
	[ "warlpiri", "australia" ],
	[ "mende", "sierra_leone" ],
	[ "maithili", "india" ],
	[ "american_sign_language", "united_states" ],
	[ "bhojpuri", "india" ],
	[ "literary_chinese", "china" ],
	[ "mazanderani", "iran" ],
	[ "newari", "nepal" ],
	[ "northern_luri", "iran" ],
	[ "palauan", "northern_mariana_islands" ],
	[ "papiamento", "bonaire" ],
	[ "tokelauan", "tokelau" ],
	[ "tok_pisin", "papua_new_guinea" ],
	[ "tuvaluan", "tuvalu" ],
	[ "cantonese", "china" ],
	[ "osage", "united_states_of_america" ],
	[ "ido", "finland" ],
	[ "lojban", "" ],
	[ "sicilian", "italy" ],
	[ "southern_kurdish", "iran" ],
	[ "western_balochi", "pakistan" ],
	[ "cebuano", "philippines" ],
	[ "erzya", "russia" ],
	[ "chickasaw", "united_states_of_america" ],
	[ "muscogee", "united_states_of_america" ],
	[ "silesian", "poland" ]
]
'

? @@NL(LanguagesForWhichDefaultCountryIs(:France))
#-->
'
[
	"breton",
	"corsican",
	"french",
	"occitan"
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

? @@NL( CountriesAndTheirDefaultLanguages() )
"-->
'
[
	[ "afghanistan", "persian" ],
	[ "albania", "albanian" ],
	[ "algeria", "arabic" ],
	[ "american_samoa", "samoan" ],
	[ "andorra", "catalan" ],
	[ "angola", "portuguese" ],
	[ "anguilla", "english" ],
	[ "antarctica", "russian" ],
	[ "antigua_and_barbuda", "???" ],
	[ "argentina", "spanish" ],
	[ "armenia", "armenian" ],
	[ "aruba", "papiamento" ],
	[ "australia", "english" ],
	[ "austria", "german" ],
	[ "azerbaijan", "azerbaijani" ],
	[ "bahamas", "???" ],
	[ "bahrain", "arabic" ],
	[ "bangladesh", "bengali" ],
	[ "barbados", "english" ],
	[ "belarus", "russian" ],
	[ "belgium", "dutch" ],
	[ "belize", "english" ],
	[ "benin", "french" ],
	[ "bermuda", "english" ],
	[ "bhutan", "dzongkha" ],
	[ "bolivia", "spanish" ],
	[ "bosnia_and_herzegowina", "bosnian" ],
	[ "botswana", "english" ],
	[ "bouvet_island", "norwegian" ],
	[ "brazil", "portuguese" ],
	[ "british_indian_ocean_territory", "english" ],
	[ "brunei", "malay" ],
	[ "bulgaria", "bulgarian" ],
	[ "burkina_faso", "french" ],
	[ "burundi", "rundi" ],
	[ "cambodia", "khmer" ],
	[ "cameroon", "english" ],
	[ "canada", "english" ],
	[ "cape_verde", "english" ],
	[ "cayman_islands", "english" ],
	[ "central_african_republic", "french" ],
	[ "chad", "french" ],
	[ "chile", "spanish" ],
	[ "china", "chinese" ],
	[ "christmas_island", "english" ],
	[ "cocos_islands", "malay" ],
	[ "colombia", "spanish" ],
	[ "comoros", "arabic" ],
	[ "congo_kinshasa", "french" ],
	[ "congo_brazzaville", "french" ],
	[ "cook_islands", "english" ],
	[ "costa_rica", "spanish" ],
	[ "cote_d_ivoire", "french" ],
	[ "croatia", "croatian" ],
	[ "cuba", "spanish" ],
	[ "cyprus", "greek" ],
	[ "czech_republic", "greek?" ],
	[ "denmark", "danish" ],
	[ "djibouti", "french" ],
	[ "dominica", "english" ],
	[ "dominican_republic", "spanish" ],
	[ "timor_leste", "spanish" ],
	[ "ecuador", "spanish" ],
	[ "egypt", "arabic" ],
	[ "el_salvador", "spanish" ],
	[ "equatorial_guinea", "spanish" ],
	[ "eritrea", "tigrinya" ],
	[ "estonia", "estonia" ],
	[ "ethiopia", "english" ],
	[ "falkland_islands", "english" ],
	[ "faroe_islands", "faroese" ],
	[ "fiji", "english" ],
	[ "finland", "finnish" ],
	[ "france", "french" ],
	[ "guernsey", "english" ],
	[ "french_guiana", "french" ],
	[ "french_polynesia", "french" ],
	[ "french_southern_territories", "french" ],
	[ "gabon", "french" ],
	[ "gambia", "french" ],
	[ "georgia", "georgian" ],
	[ "germany", "german" ],
	[ "ghana", "english" ],
	[ "gibraltar", "english" ],
	[ "greece", "greek" ],
	[ "greenland", "greenlandic" ],
	[ "grenada", "english" ],
	[ "guadeloupe", "french" ],
	[ "guam", "chamorro" ],
	[ "guatemala", "spanish" ],
	[ "guinea", "french" ],
	[ "guinea_bissau", "portuguese" ],
	[ "guyana", "english" ],
	[ "haiti", "french" ],
	[ "heard_and_mcdonald_islands", "english" ],
	[ "honduras", "spanish" ],
	[ "hong_kong", "english" ],
	[ "hungary", "hungarian" ],
	[ "iceland", "icelandic" ],
	[ "india", "hindi" ],
	[ "indonesia", "indonesian" ],
	[ "iran", "persian" ],
	[ "iraq", "arabic" ],
	[ "ireland", "english" ],
	[ "israel", "hebrew" ],
	[ "italy", "italian" ],
	[ "jamaica", "english" ],
	[ "japan", "japanese" ],
	[ "jordan", "arabic" ],
	[ "kazakhstan", "kazakh" ],
	[ "kenya", "english" ],
	[ "kiribati", "english" ],
	[ "north_korea", "korean" ],
	[ "south_korea", "korean" ],
	[ "kuwait", "arabic" ],
	[ "kyrgyzstan", "russian" ],
	[ "laos", "lao" ],
	[ "latvia", "latvian" ],
	[ "lebanon", "arabic" ],
	[ "lesotho", "english" ],
	[ "liberia", "liberia" ],
	[ "libya", "arabic" ],
	[ "liechtenstein", "german" ],
	[ "lithuania", "lithuanian" ],
	[ "luxembourg", "luxembourgish" ],
	[ "macau", "cantonese" ],
	[ "macedonia", "macedonian" ],
	[ "madagascar", "french" ],
	[ "malawi", "english" ],
	[ "malaysia", "malay" ],
	[ "maldives", "sinhala" ],
	[ "mali", "french" ],
	[ "malta", "maltese" ],
	[ "marshall_islands", "marshallese" ],
	[ "martinique", "french" ],
	[ "mauritania", "arabic" ],
	[ "mauritius", "english" ],
	[ "mayotte", "french" ],
	[ "mexico", "spanish" ],
	[ "micronesia", "spanish" ],
	[ "moldova", "romanian" ],
	[ "monaco", "french" ],
	[ "mongolia", "mongolian" ],
	[ "montserrat", "english" ],
	[ "morocco", "arabic" ],
	[ "mozambique", "portuguese" ],
	[ "myanmar", "portuguese" ],
	[ "namibia", "english" ],
	[ "nauru", "nauruan" ],
	[ "nepal", "nepali" ],
	[ "netherlands", "dutch" ],
	[ "curacao", "dutch" ],
	[ "new_caledonia", "french" ],
	[ "new_zealand", "english" ],
	[ "nicaragua", "spanish" ],
	[ "niger", "french" ],
	[ "nigeria", "english" ],
	[ "niue", "english" ],
	[ "norfolk_island", "english" ],
	[ "northern_mariana_islands", "chamorro" ],
	[ "norway", "norwegian_bokmal" ],
	[ "oman", "arabic" ],
	[ "pakistan", "punjabi" ],
	[ "palau", "palauan" ],
	[ "palestine", "arabic" ],
	[ "panama", "spanish" ],
	[ "papua_new_guinea", "tok_pisin" ],
	[ "paraguay", "spanish" ],
	[ "peru", "spanish" ],
	[ "philippines", "filipino" ],
	[ "pitcairn", "english" ],
	[ "poland", "polish" ],
	[ "portugal", "portuguese" ],
	[ "puerto_rico", "spanish" ],
	[ "qatar", "arabic" ],
	[ "reunion", "french" ],
	[ "romania", "romanian" ],
	[ "russia", "russian" ],
	[ "rwanda", "kinyarwanda" ],
	[ "saint_kitts_and_nevis", "sinhala" ],
	[ "saint_lucia", "sinhala" ],
	[ "saint_vincent_and_the_grenadines", "sinhala" ],
	[ "samoa", "samoan" ],
	[ "san_marino", "italian" ],
	[ "sao_tome_and_principe", "portugese" ],
	[ "saudi_arabia", "arabic" ],
	[ "senegal", "french" ],
	[ "seychelles", "english" ],
	[ "sierra_leone", "english" ],
	[ "singapore", "malay" ],
	[ "slovakia", "slovak" ],
	[ "slovenia", "slovenian" ],
	[ "solomon_islands", "english" ],
	[ "somalia", "somali" ],
	[ "south_africa", "zulu" ],
	[
		"south_georgia_and_south_sandwich_islands",
		"english"
	],
	[ "spain", "spanish" ],
	[ "sri_lanka", "sinhala" ],
	[ "saint_helena", "english" ],
	[ "saint_pierre_and_miquelon", "french" ],
	[ "sudan", "arabic" ],
	[ "suriname", "dutch" ],
	[
		"svalbard_and_jan_mayen_islands",
		"norwegian_bokmal"
	],
	[ "eswatini", "swiss_german" ],
	[ "sweden", "swedish" ],
	[ "switzerland", "german" ],
	[ "syria", "arabic" ],
	[ "taiwan", "mandarin" ],
	[ "tajikistan", "tajik" ],
	[ "tanzania", "swahili" ],
	[ "thailand", "thai" ],
	[ "togo", "french" ],
	[ "tokelau", "tokelauan" ],
	[ "tonga", "tongan" ],
	[ "trinidad_and_tobago", "english" ],
	[ "tunisia", "arabic" ],
	[ "turkey", "turkish" ],
	[ "turkmenistan", "turkmen" ],
	[ "turks_and_caicos_islands", "english" ],
	[ "tuvalu", "tuvaluan" ],
	[ "uganda", "english" ],
	[ "ukraine", "ukrainian" ],
	[ "united_arab_emirates", "arabic" ],
	[ "united_kingdom", "english" ],
	[ "united_states", "english" ],
	[
		"united_states_minor_outlying_islands",
		"english"
	],
	[ "uruguay", "spanish" ],
	[ "uzbekistan", "uzbek" ],
	[ "vanuatu", "bislama" ],
	[ "vatican", "italian" ],
	[ "venezuela", "spanish" ],
	[ "vietnam", "vietnamese" ],
	[ "british_virgin_islands", "english" ],
	[ "united_states_virgin_islands", "english" ],
	[ "wallis_and_futuna_islands", "french" ],
	[ "western_sahara", "arabic" ],
	[ "yemen", "arabic" ],
	[ "canary_islands", "spanish" ],
	[ "zambia", "bemba" ],
	[ "zimbabwe", "shona" ],
	[ "clipperton_island", "french" ],
	[ "montenegro", "serbian" ],
	[ "serbia", "serbian" ],
	[ "saint_barthelemy", "french" ],
	[ "saint_martin", "dutch" ],
	[ "ascension_island", "english" ],
	[ "aland_islands", "swedish" ],
	[ "diego_garcia", "french" ],
	[ "ceuta_and_melilla", "arabic" ],
	[ "isle_of_man", "manx" ],
	[ "jersey", "french" ],
	[ "tristan_da_cunha", "english" ],
	[ "south_sudan", "english" ],
	[ "bonaire", "papiamento" ],
	[ "sint_maarten", "french" ],
	[ "kosovo", "albanian" ],
	[ "outlying_oceania", "malay" ],
	[ "scottland", "scottish_gaelic" ],
	[ "england", "english" ],
	[ "wales", "welsh" ],
	[ "norther_ireland", "irish" ]
]
'

? @@NL( CountriesforWhichDefaultLanguageIs(:Arabic) )
#-->
'
[
	"algeria",
	"bahrain",
	"comoros",
	"egypt",
	"iraq",
	"jordan",
	"kuwait",
	"lebanon",
	"libya",
	"mauritania",
	"morocco",
	"oman",
	"palestine",
	"qatar",
	"saudi_arabia",
	"sudan",
	"syria",
	"tunisia",
	"united_arab_emirates",
	"western_sahara",
	"yemen",
	"ceuta_and_melilla"
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

? @@NL( ScriptsAndTheirDefaultLanguages() )
#-->
'
[
	[ "common", "undefined" ],
	[ "arabic", "arabic" ],
	[ "cyrillic", "russian" ],
	[ "deseret", "english" ],
	[ "gurmukhi", "punjabi" ],
	[ "simplified_han", "mandarin" ],
	[ "traditional_han", "mandarin" ],
	[ "latin", "english" ],
	[ "mongolian", "mongolian" ],
	[ "tifinagh", "standard_morocco_tamazight" ],
	[ "armenian", "armenian" ],
	[ "bengali", "bengali" ],
	[ "cherokee", "cherokee" ],
	[ "devanagari", "bhojpuri" ],
	[ "ethiopic", "oromo" ],
	[ "georgian", "georgian" ],
	[ "greek", "ancient_greek" ],
	[ "gujarati", "gujarati" ],
	[ "hebrew", "hebrew" ],
	[ "japanese", "japanese" ],
	[ "khmer", "khmer" ],
	[ "kannada", "kannada" ],
	[ "korean", "korean" ],
	[ "lao", "lao" ],
	[ "malayalam", "malayalam" ],
	[ "myanmar", "burmese" ],
	[ "oriya", "oriya" ],
	[ "tamil", "tamil" ],
	[ "telugu", "telugu" ],
	[ "thaana", "divehi" ],
	[ "thai", "thai" ],
	[ "tibetan", "tibetan" ],
	[ "sinhala", "sinhala" ],
	[ "syriac", "syriac" ],
	[ "yi", "sichuan_yi" ],
	[ "vai", "vai" ],
	[ "avestan", "avestan" ],
	[ "balinese", "balinese" ],
	[ "bamum", "bamun" ],
	[ "batak", "batak_toba" ],
	[ "bopomofo", "literary_chinese" ],
	[ "brahmi", "sanskrit" ],
	[ "buginese", "buginese" ],
	[ "buhid", "" ],
	[ "canadian_aboriginal", "cree" ],
	[ "carian", "undefined" ],
	[ "chakma", "chakma" ],
	[ "cham", "undefined" ],
	[ "coptic", "coptic" ],
	[ "cypriot", "undefined" ],
	[ "egyptian_hieroglyphs", "ancient_egyptian" ],
	[ "fraser", "undefined" ],
	[ "glagolitic", "undefined" ],
	[ "gothic", "gothic" ],
	[ "han", "undefined" ],
	[ "hangul", "undefined" ],
	[ "hanunoo", "undefined" ],
	[ "imperial_aramaic", "undefined" ],
	[ "inscriptional_pahlavi", "undefined" ],
	[ "inscriptional_parthian", "undefined" ],
	[ "javanese", "javanese" ],
	[ "kaithi", "undefined" ],
	[ "katakana", "undefined" ],
	[ "kayah_li", "undefined" ],
	[ "kharoshthi", "undefined" ],
	[ "lanna", "undefined" ],
	[ "lepcha", "undefined" ],
	[ "limbu", "undefined" ],
	[ "linear_b", "ancient_greek" ],
	[ "lycian", "undefined" ],
	[ "lydian", "undefined" ],
	[ "mandaean", "undefined" ],
	[ "meitei_mayek", "manipuri" ],
	[ "meroitic_hieroglyphs", "undefined" ],
	[ "meroitic_cursive", "undefined" ],
	[ "nko", "nko" ],
	[ "new_tai_lue", "undefined" ],
	[ "ogham", "old_irish" ],
	[ "ol_chiki", "santali" ],
	[ "old_italic", "undefined" ],
	[ "old_persian", "old_persian" ],
	[ "old_south_arabian", "undefined" ],
	[ "orkhon", "undefined" ],
	[ "osmanya", "somali" ],
	[ "phags_pa", "literary_chinese" ],
	[ "phoenician", "phoenician" ],
	[ "pollard_phonetic", "undefined" ],
	[ "rejang", "undefined" ],
	[ "runic", "german" ],
	[ "samaritan", "aramaic" ],
	[ "saurashtra", "saurashtra" ],
	[ "sharada", "sanskrit" ],
	[ "shavian", "english" ],
	[ "sora_sompeng", "undefined" ],
	[ "cuneiform", "akkadian" ],
	[ "sundanese", "sundanese" ],
	[ "syloti_nagri", "undefined" ],
	[ "tagalog", "filipino" ],
	[ "tagbanwa", "undefined" ],
	[ "tai_le", "tai_nua" ],
	[ "tai_viet", "tai_dam" ],
	[ "takri", "dogri" ],
	[ "ugaritic", "ugaritic" ],
	[ "braille", "undefined" ],
	[ "hiragana", "undefined" ],
	[ "caucasian_albanian", "undefined" ],
	[ "bassa_vah", "undefined" ],
	[ "duployan", "french" ],
	[ "elbasan", "albanian" ],
	[ "grantha", "sanskrit" ],
	[ "pahawh_hmong", "undefined" ],
	[ "khojki", "sindhi" ],
	[ "linear_a", "undefined" ],
	[ "mahajani", "hindi" ],
	[ "manichaean", "persian" ],
	[ "mende_kikakui", "undefined" ],
	[ "modi", "marathi" ],
	[ "mro", "undefined" ],
	[ "old_north_arabian", "undefined" ],
	[ "nabataean", "aramaic" ],
	[ "palmyrene", "aramaic" ],
	[ "pau_cin_hau", "undefined" ],
	[ "old_permic", "komi" ],
	[ "psalter_pahlavi", "pahlavi" ],
	[ "siddham", "sanskrit" ],
	[ "khudawadi", "sindhi" ],
	[ "tirhuta", "maithili" ],
	[ "varang_kshiti", "undefined" ],
	[ "ahom", "undefined" ],
	[ "anatolian_hieroglyphs", "undefined" ],
	[ "hatran", "undefined" ],
	[ "multani", "undefined" ],
	[ "old_hungarian", "undefined" ],
	[ "sign_writing", "undefined" ],
	[ "adlam", "fulah" ],
	[ "bhaiksuki", "undefined" ],
	[ "marchen", "undefined" ],
	[ "newa", "newari" ],
	[ "osage", "osage" ],
	[ "tangut", "undefined" ],
	[ "han_with_bopomofo", "literary_chinese" ],
	[ "jamo", "undefined" ]
]
'

? @@NL( ScriptsforWhichDefaultLanguageIs("mongolian") )
#--> [ "mongolian" ]

pf()
# Executed in 0.07 second(s) in Ring 1.23

/*---

pr()

# Defining a locale from two or three parameters
o1 = new stzLocale([ :Language = "french", :Country = "Mali" ])
? o1.Country() 		#--> mali
? o1.Langauge()		#--> french
? o1.Script() + NL	#--> latin

o1 = new stzLocale([ :Language = "ara", :Script = "arabic" ])
? o1.Country()		#--> egypt
? o1.Langauge()		#--> arabic
? o1.Script() + NL	#--> arabic

o1 = new stzLocale([ :Country = "brazil", :Script = "latin" ])
? o1.Country()		#--> brazil
? o1.Langauge()		#--> portuguese
? o1.Script() + NL	#--> latin

o1 = new stzLocale([ :Country = "Spain", :Language = "Spanish", :Script = "latin" ])
? o1.Country()		#--> spain
? o1.Langauge()		#--> spanish
? o1.Script()		#--> latin

pf()
# Executed in 0.12 second(s) in Ring 1.23

/*--

pr()

o1 = new stzLocale("pt_Latn_BR")
? o1.Abbreviation()	#--> pt_BR
? o1.language()		#--> portuguese				
? o1.Script()		#--> latin
? o1.Country()		#--> brazil

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

o1 = new stzLocale([ :Language = "portuguese", :Script = "Latn", :Country = "BR" ])
? o1.Abbreviation()		#--> pt_BR
? o1.LanguageName()		#--> portuguese
? o1.CountryName()		#--> brazil
? o1.CountryNumber() 	#--> 30

pf()
# Executed in 0.04 second(s) in Ring 1.23

/*---

pr()

# Defining a locale from just a language

o1 = new stzLocale([ :Language = "romanian" ])
# Or simply: o1 = new stzLocale("romanian")

? o1.QtAbbreviation()		#--> ro_RO
? o1.Abbreviation() + NL	#--> ro_RO

? o1.LanguageNumber()		#--> 95
? o1.LanguageName() + NL	#--> romanian

? o1.CountryNumber()		#--> 177
? o1.CountryName()			#--> romania

pf()
# Executed in 0.04 second(s) in Ring 1.23

/*---

pr()

#  Defining a locale from just a country

o1 = new stzLocale([ :Country = "Niger" ])
# Or simply: o1 = new stzLocale(:Niger)

? o1.Abbreviation()	#--> fr_NE
? o1.LanguageName()	#--> french
? o1.CountryName()	#--> niger

pf()
# Executed in 0.04 second(s) in Ring 1.23

/*--- #TODO fix logical error

pr()

# Defining a locale from just a script

? DefaultLanguageForScript(:Mongolian)
#--> mongolian

o1 = new stzLocale([ :Script = "Mongolian" ])

? o1.Abbreviation()	#--> returned mn_CN but should be mn_MN
? o1.LanguageName()	#--> mongolian
? o1.CountryName()	#--> returned china but should be mongolia

# If we provide :Mongolian without specifying it is a script,
# then Softanza captures it as a language and thus returns
# more precise output like this:

o1 = new stzLocale(:Mongolian)

? o1.Abbreviation()	#--> mn_MN
? o1.LanguageName()	#--> mongolian
? o1.CountryName()	#--> mongolia

pf()
# Executed in 0.05 second(s) in Ring 1.23

/*---

pr()

? CountryNumber("tunisia")
#--> 216

? SystemLocale()
#--> fr_FR (on my machine, could be different for you)

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

? @@( CountriesforWhichDefaultLanguageIs(:russian) )
# Gives [ :antarctica, :antarctica, :kyrgyzstan, :russia ]

? @@( ScriptsforWhichDefaultLanguageIs(:aramaic) )
# Gives [ :samaritan, :nabataean, :palmyrene ]

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

? @@NL( ScriptsAndTheirDefaultLanguages() )
#-->
'
[
	[ "common", "undefined" ],
	[ "arabic", "arabic" ],
	[ "cyrillic", "russian" ],
	[ "deseret", "english" ],
	[ "gurmukhi", "punjabi" ],
	[ "simplified_han", "mandarin" ],
	[ "traditional_han", "mandarin" ],
	[ "latin", "english" ],
	[ "mongolian", "mongolian" ],
	[ "tifinagh", "standard_morocco_tamazight" ],
	[ "armenian", "armenian" ],
	[ "bengali", "bengali" ],
	[ "cherokee", "cherokee" ],
	[ "devanagari", "bhojpuri" ],
	[ "ethiopic", "oromo" ],
	[ "georgian", "georgian" ],
	[ "greek", "ancient_greek" ],
	[ "gujarati", "gujarati" ],
	[ "hebrew", "hebrew" ],
	[ "japanese", "japanese" ],
	[ "khmer", "khmer" ],
	[ "kannada", "kannada" ],
	[ "korean", "korean" ],
	[ "lao", "lao" ],
	[ "malayalam", "malayalam" ],
	[ "myanmar", "burmese" ],
	[ "oriya", "oriya" ],
	[ "tamil", "tamil" ],
	[ "telugu", "telugu" ],
	[ "thaana", "divehi" ],
	[ "thai", "thai" ],
	[ "tibetan", "tibetan" ],
	[ "sinhala", "sinhala" ],
	[ "syriac", "syriac" ],
	[ "yi", "sichuan_yi" ],
	[ "vai", "vai" ],
	[ "avestan", "avestan" ],
	[ "balinese", "balinese" ],
	[ "bamum", "bamun" ],
	[ "batak", "batak_toba" ],
	[ "bopomofo", "literary_chinese" ],
	[ "brahmi", "sanskrit" ],
	[ "buginese", "buginese" ],
	[ "buhid", "" ],
	[ "canadian_aboriginal", "cree" ],
	[ "carian", "undefined" ],
	[ "chakma", "chakma" ],
	[ "cham", "undefined" ],
	[ "coptic", "coptic" ],
	[ "cypriot", "undefined" ],
	[ "egyptian_hieroglyphs", "ancient_egyptian" ],
	[ "fraser", "undefined" ],
	[ "glagolitic", "undefined" ],
	[ "gothic", "gothic" ],
	[ "han", "undefined" ],
	[ "hangul", "undefined" ],
	[ "hanunoo", "undefined" ],
	[ "imperial_aramaic", "undefined" ],
	[ "inscriptional_pahlavi", "undefined" ],
	[ "inscriptional_parthian", "undefined" ],
	[ "javanese", "javanese" ],
	[ "kaithi", "undefined" ],
	[ "katakana", "undefined" ],
	[ "kayah_li", "undefined" ],
	[ "kharoshthi", "undefined" ],
	[ "lanna", "undefined" ],
	[ "lepcha", "undefined" ],
	[ "limbu", "undefined" ],
	[ "linear_b", "ancient_greek" ],
	[ "lycian", "undefined" ],
	[ "lydian", "undefined" ],
	[ "mandaean", "undefined" ],
	[ "meitei_mayek", "manipuri" ],
	[ "meroitic_hieroglyphs", "undefined" ],
	[ "meroitic_cursive", "undefined" ],
	[ "nko", "nko" ],
	[ "new_tai_lue", "undefined" ],
	[ "ogham", "old_irish" ],
	[ "ol_chiki", "santali" ],
	[ "old_italic", "undefined" ],
	[ "old_persian", "old_persian" ],
	[ "old_south_arabian", "undefined" ],
	[ "orkhon", "undefined" ],
	[ "osmanya", "somali" ],
	[ "phags_pa", "literary_chinese" ],
	[ "phoenician", "phoenician" ],
	[ "pollard_phonetic", "undefined" ],
	[ "rejang", "undefined" ],
	[ "runic", "german" ],
	[ "samaritan", "aramaic" ],
	[ "saurashtra", "saurashtra" ],
	[ "sharada", "sanskrit" ],
	[ "shavian", "english" ],
	[ "sora_sompeng", "undefined" ],
	[ "cuneiform", "akkadian" ],
	[ "sundanese", "sundanese" ],
	[ "syloti_nagri", "undefined" ],
	[ "tagalog", "filipino" ],
	[ "tagbanwa", "undefined" ],
	[ "tai_le", "tai_nua" ],
	[ "tai_viet", "tai_dam" ],
	[ "takri", "dogri" ],
	[ "ugaritic", "ugaritic" ],
	[ "braille", "undefined" ],
	[ "hiragana", "undefined" ],
	[ "caucasian_albanian", "undefined" ],
	[ "bassa_vah", "undefined" ],
	[ "duployan", "french" ],
	[ "elbasan", "albanian" ],
	[ "grantha", "sanskrit" ],
	[ "pahawh_hmong", "undefined" ],
	[ "khojki", "sindhi" ],
	[ "linear_a", "undefined" ],
	[ "mahajani", "hindi" ],
	[ "manichaean", "persian" ],
	[ "mende_kikakui", "undefined" ],
	[ "modi", "marathi" ],
	[ "mro", "undefined" ],
	[ "old_north_arabian", "undefined" ],
	[ "nabataean", "aramaic" ],
	[ "palmyrene", "aramaic" ],
	[ "pau_cin_hau", "undefined" ],
	[ "old_permic", "komi" ],
	[ "psalter_pahlavi", "pahlavi" ],
	[ "siddham", "sanskrit" ],
	[ "khudawadi", "sindhi" ],
	[ "tirhuta", "maithili" ],
	[ "varang_kshiti", "undefined" ],
	[ "ahom", "undefined" ],
	[ "anatolian_hieroglyphs", "undefined" ],
	[ "hatran", "undefined" ],
	[ "multani", "undefined" ],
	[ "old_hungarian", "undefined" ],
	[ "sign_writing", "undefined" ],
	[ "adlam", "fulah" ],
	[ "bhaiksuki", "undefined" ],
	[ "marchen", "undefined" ],
	[ "newa", "newari" ],
	[ "osage", "osage" ],
	[ "tangut", "undefined" ],
	[ "han_with_bopomofo", "literary_chinese" ],
	[ "jamo", "undefined" ]
]
'

? @@NL( ScriptsforWhichDefaultLanguageIs(:english) )
#--> [ "deseret", "latin", "shavian" ]

pf()
# Executed in 0.13 second(s) in Ring 1.23

/*---

pr()

o1 = new stzString("2")
? o1.IsScriptName() #--> FALSE
? o1.IsScriptAbbreviation() #--> FALSE

? o1.IsScriptNumber() #--> TRUE
? StzScriptQ("2").Name() #--> cyrillic
? Script("2") #--> cyrillic

? Country("216")
#--> tunisia

? Language("أم")
#--> arabic

pf()
# Executed in 0.06 second(s) in Ring 1.23

/*---

pr()

? SystemLocale()
#--> fr_FR

o1 = new stzLocale([ :Language = "arabic", :Country = "tunisia" ])
? o1.LanguageName()
#--> arabic

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*---

pr()

? IsLocaleAbbreviation("ar_tn")
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

o1 = new stzLocale("fr")
? o1.LanguageName() #--> french
? o1.CountryName()	#--> france
? o1.ScriptName()	#--> latin

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

o1 = new stzLocale("es")
? o1.LanguageName() #--> spanish

? o1.LanguageAbbreviation() #--> es
? o1.bcp47Abbreviation() #--> es
? StzStringQ("es_ES").IsLocaleAbbreviation() #--> TRUE

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*---

pr()

o1 = new stzLocale(:C)
? o1.LanguageName() #--> ""

o1 = new stzLocale(:system)
? o1.LanguageName() #--> ""

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

o1 = new stzLocale("fr_FR")
# Or o1 = new stzLocale([:Country = "france", :Language = "french"])

? o1.LanguageName() #--> french
? o1.bcp47Abbreviation() #--> fr
? o1.FirstDayOfWeek() #--> monday
? o1.CurrencyName() #--> Euro

pf()
# Executed in 0.04 second(s) in Ring 1.23

/*---

pr()

o1 = new stzLocale("en-US")
? o1.Abbreviation() #--> en_US
? o1.QtAbbreviation() #--> en_US
? o1.Country() #--> united_states

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

// Testing time formats
o1 = new stzLocale("en-Latn-US")
? o1.Abbreviation() #--> en_US
? o1.TimeShortFormat() #--> h:mm AP
? o1.TimeLongFormat() #--> h:mm:ss AP t
? o1.TimeNarrowFormat() #--> h:mm AP

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

? QLocaleToStzLocale( new QLocale("ru_RU") ).Country()
#--> russia

pf()

/*---

pr()

? @@NL( DefaultDaysOfWeek() ) + NL
#-->
'
[
	[ "1", "monday" ],
	[ "2", "tuesday" ],
	[ "3", "wednesday" ],
	[ "4", "thursday" ],
	[ "5", "friday" ],
	[ "6", "saturday" ],
	[ "7", "sunday" ]
]
'

// Testing the nth day of week
o1 = new stzLocale("en_US")

? o1.Country() #--> united_states
? o1.Abbreviation() #--> en_US
? o1.FirstDayOfWeek() + NL #--> sunday

? o1.NthDayOfWeek(1) + NL #--> sunday

? @@( o1.DaysOfWeek() )
#--> [ "sunday", "monday", "tuesady", "wednesday", "thirsday", "friday", "saturday" ]

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*---

pr()

o1 = new stzLocale("en_US")
? o1.ToLowercase("FDMLj") #--> fdmlj
? o1.ToUPPERcase("FDMLj") #--> FDMLJ

? o1.amText() #--> AM
? o1.pmText() #--> PM

? o1.DecimalPoint() #--> "."
? o1.Exponential()	#--> e
? o1.GroupSeparator() #--> ","

? o1.NegativeSign() #--> "-"
? o1.PositiveSign() #--> "+"
? o1.Percent()		#--> "%"

? o1.GroupSeparator() #--> ","

pf()
# Executed in 0.02 second(s) in Ring 1.23
