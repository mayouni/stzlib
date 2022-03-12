func stzLocaleError(pcError)
	cErrorMsg = "in file stzLocale.ring:" + NL

	switch pcError
	on :CanNotSetNumberOptions
		cErrorMsg += "   What : Can't set the locale number option!" + NL
		cErrorMsg += "   Why  : The option you provided is not supported." + NL
		cErrorMsg += "   Todo : Provide one of the supported options in _aLocaleNumberOptions."

	on :CanNotDefineNthDayOfWeek
		cErrorMsg += "   What : Can't define the nth day of week!" + NL
		cErrorMsg += "   Why  : The number of day you provided is out of range." + NL
		cErrorMsg += "   Todo : Provide a number between 1 and 7 and it'll be fine ;)"

	on :UnsupportedLanguageCode
		cErrorMsg += "   What : Can't recognize the language code you provided!" + NL
		cErrorMsg += "   Why  : String you provided is not a supported language code (number, name, or abbreviation)." + NL
		cErrorMsg += "   Todo : Provide a string containing a valid language number, name, or abbreviation, as defined in LocaleLanguagesXT()."

	on :UnsupportedCountryCode
		cErrorMsg += "   What : Can't recognize the country code you provided!" + NL
		cErrorMsg += "   Why  : String you provided is not a supported country code (number, name, or abbreviation)." + NL
		cErrorMsg += "   Todo : Provide a string containing a valid country number, name, or abbreviation, as defined in LocaleLanguagesXT()."

	on :UnsupportedCountryName
		cErrorMsg += "   What : Can't recognize the country name you provided!" + NL
		cErrorMsg += "   Why  : String you provided is not a supported country name." + NL
		cErrorMsg += "   Todo : Provide a string containing a valid country name as defined in LocaleCountriesXT()."

	on :UnsupportedScriptCode
		cErrorMsg += "   What : Can't recognize the script you provided!" + NL
		cErrorMsg += "   Why  : String you provided is not a supported script code." + NL
		cErrorMsg += "   Todo : Provide a string containing a valid script code as defined in LocaleScriptsXT() : number, name, or abbreviation."

	on :UnsupportedLanguageAbbreviation
		cErrorMsg += "   What : Can't recognize the language abbreviation you provided!" + NL
		cErrorMsg += "   Why  : String you provided is not a supported language abbreviation." + NL
		cErrorMsg += "   Todo : Provide a string containing a valid language abbreviation as defined in LanguageAbbreviations()."

	on :UnsupportedLanguageNumber
		cErrorMsg += "   What : Can't recognize the language number you provided!" + NL
		cErrorMsg += "   Why  : String you provided is not a supported language number." + NL
		cErrorMsg += "   Todo : Provide a string containing a valid language number as defined in LanguageNumbers()."

	on :UnsupportedCountryAbbreviation
		cErrorMsg += "   What : Can't recognize the country abbreviation you provided!" + NL
		cErrorMsg += "   Why  : String you provided is not a supported country abbreviation." + NL
		cErrorMsg += "   Todo : Provide a string containing a valid country abbreviation as defined in CountryAbbreviations()."

	on :CanNotProvideCurrencySymbol
		cErrorMsg += "   What : Can't provide you with a convenient formatting for currency in this locale!" + NL
		cErrorMsg += "   Why  : String you provided is not a supported currency format." + NL
		cErrorMsg += "   Todo : Provide a string containing a valid formatting as defined in LocaleCurrencyFormats(): :ISOSymbol, :NativeSymbol, or :NativeName."

	on :UnsupportedLocaleSeparator
		cErrorMsg += "   What : Can't recognize the locale abbreviation separator you provided!" + NL
		cErrorMsg += "   Why  : String you provided is not a supported abbreviation locale separator." + NL
		cErrorMsg += "   Todo : Provide a string containing '-' or '_' and it will be fine ;)"

	off

	return cErrorMsg + NL
