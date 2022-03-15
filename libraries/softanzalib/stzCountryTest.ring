load "stzlib.ring"

#? _(:Iran).Q(:Country).Languages()

? StzCountryQ(:Iran).Languages()
? StzCountryQ(:Iran).LanguagesAbbreviations()
/*-------------------

_(:Egypt).IsA(:Country)
_(:Arabic).IsA(:Language)
_(:Arabic).IsThe(:DefaultLanguage).Of(:Egypt)

/*-------------------

? StzCountryQ("germany").Language()

/*-------------------

//? CountriesAndTheirDefaultLanguages()
? CountriesforWhichDefaultLanguageIs(:english)
/*-------------------

# You can create a country by specifying one of these information:
# name, short or long abbreviation, phone code, or even its default language!

# All these create the country Egypt and return its name

? StzCountryQ(:Egypt).Name()
? StzCountryQ(:EGY).Name()
? StzCountryQ(:EG).Name()

? StzCountryQ("64").Name()	# 64 is the ISO country code of Egypt
? StzCountryQ("+20").Name()	# +20 is the international phone code of Egypt

? StzCountryQ(:Arabic).Name()	# Because Arabic is default language of Egypt!

/*-------------------

# More conveniently, these information are accessible directly like this:

StzCountryQ(:Egypt) {

	? QtNumber()
	? Country()
	? Name()
	? NativeName()
	? Content()
	
	? Abbreviation()
	? ShortAbbreviation()
	? LongAbbreviation()
	
	? PhoneCode()
	
	? DefaultLanguageQtNumber()
	? LanguageQtNumber()
	? DefaultLanguage()
	? DefaultLanguageName()
	? Language()
	? LanguageName()
	? LanguageNativeName()
	? DefaultLanguageNativeName()
				
	? Script()
	? ScriptName()
	? ScriptQtNumber()
			
	? Currency()
	? CurrencyNativeName()
 	? CurrencySymbol()
	? CurrencyAbbreviation()
	? CurrencyFractionalUnit()
	? CurrencyFraction()
	? CurrencyBase()
	? CurrencyEmojiFlag()
}



