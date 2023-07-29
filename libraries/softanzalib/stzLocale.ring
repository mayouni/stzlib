#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - STZLOCALE			    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The class for managing locales in Softanza        #
#	Version		: V1.0 (2020-2022)				    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

/*
Nice article about locales:
https://docs.oracle.com/cd/E19253-01/817-2521/overview-39/index.html
*/

func StzLocaleQ(p)
	return new stzLocale(p)

func IsQLocale(p)

	if isObject(p) and classname(p) = "qlocale"
		return TRUE
	else
		return FALSE
	ok

	func IsQLocaleObject(p)
		return IsQLocale(p)

func QLocaleToStzLocale(oQLocale)
	return new stzLocale(oQLocale)

	func QLocaleObjectToStzLoclae(QLocale)

func StzLocaleToQLocale(oLocale)
	return oLocale.QLocaleObject()

	func StzLoclaeToQLocaleObject(oLocale)
		return StzLocaleToQLocale(oLocale)

func SystemLocale() # Returned as a string
	oQLocale = new QLocale("C")
	return oQLocale.system()

	func SystemLocaleAbbreviation()
		return SystemLocale()

func LocaleAbbreviationsXT()
	return _aLocaleAbbreviationsXT

func LocaleAbbreviations()
	aResult = []

	for acountry in LocaleAbbreviationsXT()
		for aLanguage in aCountry[2]
			for aLocale in aLanguage
				aResult + aLocale[2]
			next
		next
	next

	return aResult

func LocaleAbbreviationsAsString()
	return _cLocaleAbbreviations

	def LocaleAbbreviationsHostedInString()
		return LocaleAbbreviationsAsString()

func LanguagesAndTheirDefaultCountries()
	aResult = []
	for aLangInfo in LocaleLanguagesXT()
		aResult + [ aLangInfo[2], aLangInfo[5] ]
	next
	return aResult

func LanguagesforWhichDefaultCountryIs(cCountryCode)
	aResult = []
	cCountryName = StzCountryQ(cCountryCode).Name()
	for aLangInfo in LocaleLanguagesXT()
		if lower(aLangInfo[5]) = lower(cCountryName)
			aResult + aLangInfo[2]
		ok
	next
	return aResult

func ScriptsAndTheirDefaultLanguages()
	aResult = []
	for aScriptInfo in LocaleScriptsXT()
		aResult + [ aScriptInfo[2], DefaultLanguageForScript(aScriptInfo[2]) ]
	next
	return aResult

func ScriptsforWhichDefaultLanguageIs(cLangCode)
	aResult = []
	cLangName = StzLanguageQ(cLangCode).Name()
	for aScriptInfo in LocaleScriptsXT()
		if lower(aScriptInfo[4]) = lower(cLangName)
			aResult + aScriptInfo[2]
		ok
	next
	return aResult

func LocaleMeasurementSystems()
	return _aLocaleMeasurementsystems

func NamesOfDays()
	return NamesOfDaysIn(:English)

func NamesOfDaysIn(pcLangOrCountry)

	aResult = []
	if _(pcLangOrCountry).@.IsLanguageName()
		oQLocale = StzLocaleQ([ :Language = pcLangOrCountry ]).QLocaleObject()

	but _(pcLangOrCountry).@.IsCountryName()

		cAbbr = StzCountryQ(pcLangOrCountry).LanguageAbbreviation() + "_" +
			StzCountryQ(pcLangOrCountry).Abbreviation()

		oQLocale = new QLocale(cAbbr)
	else
		oQLocale = new QLocale("C")
	ok

	# Let's define the 1st of week in this locale

	cFirstDayInEnglish = StzLocaleQ(oQLocale).FirstDayOfWeek()

	aDaysInEnglish = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]
	n = find( aDaysInEnglish, cFirstDayInEnglish )

	# We need to get that 1st day in native language of the locale

	aDaysInLocaleLanguage = [ oQLocale.dayname(n, 0) ]

	# And then compose the days starting from that 1st day

	for i = n + 1 to 7
		aDaysInLocaleLanguage + oQLocale.dayname(i, 0)
	next

	for i = 1 to n - 1
		aDaysInLocaleLanguage + oQLocale.dayname(i, 0)
	next


	return aDaysInLocaleLanguage
	
func NamesOfMonths()
	return NamesOfMonthsIn(:English)

func NamesOfMonthsIn(pcLangOrCountry)
	
	aResult = []
	if _(pcLangOrCountry).@.IsLanguageName()
		oQLocale = StzLocaleQ([ :Language = pcLangOrCountry ]).QLocaleObject()

	but _(pcLangOrCountry).@.IsCountryName()

		cAbbr = StzCountryQ(pcLangOrCountry).LanguageAbbreviation() + "_" +
			StzCountryQ(pcLangOrCountry).Abbreviation()

		oQLocale = new QLocale(cAbbr)
	else
		oQLocale = new QLocale("C")
	ok

	for i = 1 to 12
		aResult + oQLocale.monthname(i, 0)
	next

	return aResult

class stzLocale from stzObject
	@oQLocale
	@cAbbreviation

	@cLangAbbreviation
	@cScriptAbbreviation
	@cCountryAbbreviation
	
	  #---------#
	 #  INIT   #
	#---------#

	/*
	Initializes the stzLocale object using one of these methods:

		* a QLocale object instanciated from Qt using new QLocale()

		* by providing a locale string like "ar_TN" and "ar_Arab_TN"
		  (dash"-" separator also accepted)

		* by providing a [ :Language = ..., :Script = ..., Country = ... ]
		  locale identification list

		* by specifying a C locale (by providing a "C" string)

		* by specifying a system locale (by providing a :System string)

		* by scpecifying a default locale (by providing a :Default string)
	*/

	def init(pLocale)

		if IsQLocaleObject(pLocale)
			@oQlocale = pLocale
	
		but IsString(pLocale)
			if pLocale = :System or pLocale = :SystemLocale
				@oQLocale = new QLocale("C")
				@cAbbreviation = "C"
				return

			but pLocale = :Default or pLocale = :DefaultLocale
				@oQLocale = new QLocale(DefaultLocaleAbbreviation())
				@cAbbreviation = @oQLocale.name()
				return

			else
				pLocale = StzStringQ(pLocale).
					ReplaceManyQ(["-","_"], "-").
					Content()

				@oQLocale = new QLocale(pLocale)
				@cAbbreviation = @oQLocale.name()
	
			ok

			pLocale = StzStringQ(pLocale).ReplaceQ("_", "-").Content()
			oLocale = new stzString(pLocale)

			if oLocale.ContainsOneOccurrence("-")
				
				aParts = oLocale.Split("-")
				oPart1 = StzStringQ(aParts[1])
				oPart2 = StzStringQ(aParts[2])

				if oPart1.IsLanguageAbbreviation()
					@cLangAbbreviation = aParts[1]

				but oPart1.IsScriptAbbreviation()
					@cScriptAbbreviation = aParts[1]
				ok

				if oPart2.IsScriptAbbreviation()
					@cScriptAbbreviation = aParts[2]

				but oPart2.IsCountryAbbreviation()
					@cCountryAbbreviation = aParts[2]
				ok

			but oLocale.ContainsNTimes(2, "-")
			    
				aParts =  oLocale.Split("-")
				oPart1 = StzStringQ(aParts[1])
				oPart2 = StzStringQ(aParts[2])
				oPart3 = StzStringQ(aParts[3])

				if oPart1.IsLanguageAbbreviation()
					@cLangAbbreviation = aParts[1]
				ok

				if oPart2.IsScriptAbbreviation()
					@cScriptAbbreviation = aParts[2]
				ok

				if oPart3.IsCountryAbbreviation()
					@cCountryAbbreviation = aParts[3]
				ok
			ok

		but IsList(pLocale)
			if NOT ( isList(pLocale) and StzListQ(pLocale).IsLocaleList() )
	
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
	
			@oQLocale = new QLocale(cAbbr)
			@cAbbreviation = @oQLocale.name()

			@cLangAbbreviation = cLangAbbr
			@cScriptAbbr = cScriptAbbr
			@cCountryAbbr = cCountryAbbr
		ok

	  #---------#
	 #  INFO   #
	#---------#

	# LOCALE QOBJECT

	def QLocaleObject()
		return @oQLocale

	# LOCALE ABBREVIATION

	def QtAbbreviation()
		return @oQLocale.name()

	def Abbreviation()
		return @cAbbreviation

	def Content()
		return This.Abbreviation()

	# A scpecific abbreviation notation for those who need it
	/* Returns the dash-separated language, script and country
	   (and possibly other BCP47 fields) of this locale as a string. */

	def bcp47Abbreviation()
		return @oQLocale.bcp47Name()

	  #---------------#
	 #    COUNTRY    #
	#---------------#
	
	def CountryQtNumber()
		return ""+ @oQLocale.country()

		def CountryNumber()
			return This.CountryQtNumber()

	def CountryAbbreviation()
		return This.CountryShortAbbreviation()
	
	def CountryShortAbbreviation()
		cCountryQtNumber = This.CountryQtNumber()

		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[1] = cCountryQtNumber
				return aCountryInfo[3]
			ok
		next

	def CountryLongAbbreviation()
		cCountryQtNumber = This.CountryQtNumber()

		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[1] = cCountryQtNumber
				return aCountryInfo[4]
			ok
		next

	def CountryPhoneCode()
		cCountry = This.CountryName()
		
		for aCountryInfo in LocaleCountriesXT()
			if lower(aCountryInfo[2]) = lower(cCountry)
				return aCountryInfo[5]
			ok
		next

	def CountryName()
		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[1] = This.CountryQtNumber()
				return aCountryInfo[2]
			ok
		next

		def Country()
			return This.CountryName()

	def CountryNativeName()
		return StzLocaleQ([ :Country = This.CountryName() ]).QLocaleObject().nativeCountryName()

	  #-------------#
	 #  LANGUAGE   #
	#-------------#

	def LanguageQtNumber()
		cLangName = This.LanguageName()

		for aLangInfo in LocaleLanguagesXT()
			if lower(aLangInfo[2]) = lower(cLangName)
				return aCountryInfo[1]
			ok
		next

		def LanguageNumber()
			return This.LanguageQtNumber()
 
	def LanguageName()
		/*
		When created, the locale object could contain one or many
		of these values:

			@cLangAbbreviation
			@cScriptAbbreviation
			@cCountryAbbreviation

		depending on how the user created it. For example:

			new stzLocale([ :Country = :Tunisia ])

		--> generates the following:

			@cLangAbbreviation	= NULL
			@cScriptAbbreviation	= NULL
			@cCountryAbbreviation	= "TN"

		In this particular case, when you need to retrieve the language
		of the current locale, for example, the @cLangAbbreviation would
		not help, because its null!

		This introduces the job done with the code hereafter...

		*/
		
		if @cLangAbbreviation = NULL
			if @cCountryAbbreviation != NULL
				for aCountryInfo in LocaleCountriesXT()
					if lower(aCountryInfo[3]) = lower( @cCountryAbbreviation )
						@cLangAbbreviation = aCountryInfo[6]
						exit
					ok
				next

			but @cScriptAbbreviation != NULL
				for aScriptInfo in LocaleScriptsXT()
					if lower(aScriptInfo[3]) = lower( @cScriptAbbreviation )
						@cLangAbbreviation = aScriptInfo[4]
						exit
					ok
				next
			ok
		ok

		# At this level, we are sure @cLangAbbreviation is not null,
		# so let's use it to get the language name!

		for aLangInfo in LocaleLanguagesXT()
			if lower(aLangInfo[3]) = lower(@cLangAbbreviation)
				return aLangInfo[2]
			ok
		next

		def Language()
			return This.LanguageName()
	
	def LanguageNativeName()
		return StzLocaleQ([ :Country = This.CountryName() ]).QLocaleObject().nativeLanguageName()


	def LanguageAbbreviation()
		return This.LanguageAbbreviation()
		
	def LanguageShortAbbreviation()
		return @cLangAbbreviation

	def LanguageLongAbbreviation()
		cLangNumber = This.LanguageNumber()
		for aLangInfo in LocaleLanguagesXT()
			if aLangInfo[1] = cLangNumber
				return aLangInfo[4]
			ok
		next

	  #-----------#
	 #  SCRIPT   #
	#-----------#

	def ScriptNumber()
		return ""+ @oQLocale.script()

		def ScriptCode()
			return This.ScriptNumber()

	def ScriptName()
		// TODO

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
		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[1] = This.CountryNumber()
				return StzStringQ(aCountryInfo[7]).ReplaceQ("_", " ").Capitalized()
			ok
		next

		def Currency()
			return This.CurrencyName()

	def CurrencyNativeName()
		return This.pvtCurrencyXT(:NativeName)

	def CurrencyAbbreviation()
		return This.pvtCurrencyXT(:ISOSymbol)

	def CurrencySymbol()
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

	  #---------#
	 #  TIME   #	# TODO :Should be used by default in
	#---------#	# formatting time in stzTime	

	def amText()
		return @oQLocale.amText()

	def pmText()
		return @oQLocale.pmText()

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
			:Long (0 in Qt)
			:Short (1 in Qt)
			:Narrow (2  in Qt)
		as defined in LocaleTimeFormatTypes()
		*/
		return @oQLocale.timeFormat( LocaleTimeFormatTypes()[ cType ])

	// Returns a stzTime object from the localised string cTime
	def ToStzTime(cTime)
		return new stzTime( @oQLocale.toTime_2(cTime, This.TimeFormat(:Short)) )
		/*
		TODO: Logical error. Returns a result that is insensitve to the locale
			o1 = new stzLocale("ru_RU") # Russian locale
			? o1.ToTimeAsString("05:08:34", :Long)

			Returns :
			5:08:34  Paris, Madrid (heure d’été)

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
		on :Default		cFormat = _cDefaultTimeFormat
		on :Long	cFormat = This.TimeFormat(:Long)
		on :Short	cFormat = This.TimeFormat(:Short)
		on :Narrow	cFormat = This.TimeFormat(:Narrow)
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
		n = ring_find( aDaysInEnglish, cFirstDayInEnglish )

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
		# Let's define the 1st of week in this locale
	
		cFirstDayInEnglish = This.FirstDayOfWeek()
		aDaysInEnglish = [ :monday, :tuesady, :wednesday, :thirsday, :friday, :saturday, :sunday ]
		n = ring_find( aDaysInEnglish, cFirstDayInEnglish )
	
		# We need to get that 1st day in native language of the locale
	
		aDaysInLocaleLanguage = [ @oQLocale.dayname(n, 0) ]
	
		# And then compose the days starting from that 1st day
	
		for i = n + 1 to 7
			aDaysInLocaleLanguage + @oQLocale.dayname(i, 0)
		next
	
		for i = 1 to n - 1
			aDaysInLocaleLanguage + @oQLocale.dayname(i, 0)
		next

		return aDaysInLocaleLanguage

	def NthDayOfWeek(n)
		/*
		FYI: read this discussion about the week having 5 days in Javaneese:
		https://bit.ly/2U5oTAh

		QLocale.firstDayOfWeek returns a number of week hosted in
		a pointer like this:
			0AF913F0
			Qt::DayOfWeek
			0
		--> to read the number we use the softanza function NumberInPointer()

		After that, we search for the day string inside the DefaultDaysOfWeek() list
		defined in the stzDate.ring file.
		*/
		
		//oQLocale = StzLocaleQ([ :Country = This.Country() ]).QLocaleObject()

		nNthDay = 0
		if 0 < n and n < 8
			nFirstDayOfWeek = NumberInPointer(@oQLocale.firstDayOfWeek())
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

		nFirst = ring_find( aDaysInEnglish, cFirstDay )
		
		oQLocale = new QLocale("en-US")
		return oQLocale.dayname(nFirst + n - 1, 1)

	def NthDayOfWeekNativeAbbreviation(n)
		return @oQLocale.dayname(n, 1)

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

		nFirst = ring_find( aDaysInEnglish, cFirstDay )
		
		oQLocale = new QLocale("en-US")
		return oQLocale.dayname(nFirst + n - 1, 2)

	def NthDayOfWeekNativeSymbol(n)
		return @oQLocale.dayname(n, 2)

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
	 #   MONTH   # TODO
	#-----------#


	  #----------------#
	 #  NUMBER FORM   #	# TODO: Should be used by default in
	#----------------#	# formatting numbers in stzNumber

	def DecimalPoint()
		return QCharToString(@oQLocale.decimalPoint())

	def Exponential()
		return QCharToString(@oQLocale.exponential())

	def GroupSeparator()
		return QCharToString(@oQLocale.groupSeparator())

	def NegativeSign()
		return QCharToString(@oQLocale.negativeSign())

	def PositiveSign()
		return QCharToString(@oQLocale.positiveSign())

	def Percent()
		return QCharToString(@oQLocale.percent())
	
	  #-----------------------#
	 #   STRING LOWER CASE   #
	#-----------------------#

	/*
	TODO: Check if these special cases documented by Unicode standard
	are already supported by Qt:
	--> http://unicode.org/Public/UNIDATA/SpecialCasing.txt
	*/

	def StringLowercased(pcStr)
		cResult = @oQLocale.toLower(pcStr)
		return cResult

		def ToLowercase(pcStr)
			return This.StringLowercased(pcStr)

	def CharLowercased(pcChar)
		if StringIsChar(pcChar)
			return This.StringLowercased(pcStr)
		ok

	def StringIsLowercased(pcStr)
		return This.StringLowercased(pcStr) = pcStr

		def StringIsLowercase(pcStr)
			return This.StringIsLowercased(pcStr)

	def CharIsLowercased(pcChar)
		if StringIsChar(pcChar)
			return This.StringIsLowercased(pcStr)
		ok

	  #-----------------------#
	 #   STRING UPPER CASE   #
	#-----------------------#
	# --? TODO: support the special cases documented in unicode here:
	# http://unicode.org/Public/UNIDATA/SpecialCasing.txt
	
	def StringUppercased(pcStr)
		cResult = QLocaleObject().toUPPER(pcStr)
		return cResult

		def ToUppercase(pcStr)
			return This.StringUppercased(pcStr)

	def CharUppercased(pcChar)
		if StringIsChar(pcChar)
			return This.StringUppercased(pcStr)
		ok

	def StringIsUppercased(pcStr)
		return This.StringUppercased(pcStr) = pcStr

		def StringIsUppercase(pcStr)
			return This.StringIsUppercased(pcStr)

	def CharIsUppercased(pcChar)
		if StringIsChar(pcChar)
			return This.StringIsUppercased(pcStr)
		ok

	  #-----------------------#
	 #   STRING TITLE CASE   #
	#-----------------------#

	def StringTitlecased(pcStr)
		if StzTextQ(pcStr).IsLatinScript()

			if This.Language() = :English

				# In english, every word is capitalized in its first letter
				# NOTE: we are implementing the simplified variant of title
				# case here (also knowan as start case).

				# TODO: Implement the various styles documented in this
				# Wikipedia article: https://en.wikipedia.org/wiki/Title_case

				# Example:

				# "in search of lost time" becomes
				# "In Search Of Lost Time"

				# TODO: Manage stop-words that we should'nt titlize, like "of" here.

				anWordsPositions = StzTextQ(pcStr).WordsPositions()

				oStr = new stzString(pcStr)
				cResult = ""
				for i = 1 to oStr.NumberOfChars()
					if Q(i).ExistsIn(ComputableForm(anWordsPositions))
						cResult += Q(oStr[i]).Uppercased()
					else
						cResult += oStr[i]
					ok
				next

			else // Including  This.Language() = :French

				# In french a title is capitalised at the beginning
				# of the sentence. See this example:

				# "à la recherche du temps perdu" becomes
				# "A la Recherche du temps perdu"

				cResult = This.ToUppercase( StzStringQ(pcStr)[1] ) +
					  This.ToLowercase( StzStringQ(pcStr).Section(2,:LastChar) )
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
		if StringIsChar(pcChar)
			return This.StringFoldcased(pcStr)
		ok

	def StringIsfoldcased(pcStr)
		return This.Stringfoldcased(pcStr) = pcStr

		def StringIsFoldcase(pcStr)
			return This.StringIsFoldcased(pcStr)

	def CharIsFoldcased(pcChar)
		if StringIsChar(pcChar)
			return This.StringIsFoldcased(pcStr)
		ok

	  #-------------------------#
	 #   STRING CAPITAL CASE   #
	#-------------------------#

	def StringCapitalcased(pcStr)

		# Lowercasing all the string first

		oStr = StzStringQ(pcStr).LowercaseQ()

		# Getting the positions of the words in the string
		# TODO: delegate the work to stzText when ready

		anPos = oStr.FindAll(" ")
		if len(anPos) = 0
			anPos = [1]

		else
			anPos = StzListOfNumbersQ(anPos).AddedToEach(1)
			ring_insert(anPos, 1, 1)
			anPos = ring_sort(anPos)
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
		return LocaleMeasurementSystems()[ "" + @oQLocale.measurementSystem() ]

	PRIVATE

	def pvtCurrencyXT(pcTypeOfSymbol)
		/*
		Reminder:
		_aLocaleCurrencyFormats = [
			[ "0", :ISOSymbol ], #  ISO-4217 code of the currency (in latin script)
			[ "1", :NativeSymbol ], # Native currency symbol (in native language)
			[ "2", :NativeName ] # User (complete) readable name of the currency (in native language)
		]
		*/
		switch pcTypeOfSymbol
		on :ISOSymbol
			return @oQLocale.currencySymbol(0)	#--> CurrencyAbbreviation() in Softanza

		on :NativeSymbol
			return @oQLocale.currencySymbol(1)	#--> CurrencySymbol() in Softanza

		on :NativeName
			return @oQLocale.currencySymbol(2)	#--> NativeName() In Softanza

		other
			StzRaise(stzLocaleError(:CanNotProvideCurrencySymbol))
		off
