func stzLocaleError(pcError)
	_cErrorMsg_ = "in file stzLocale.ring:" + NL

	switch pcError
	on :CanNotSetNumberOptions
		_cErrorMsg_ += "   What : Can't set the locale number option!" + NL
		_cErrorMsg_ += "   Why  : The option you provided is not supported." + NL
		_cErrorMsg_ += "   Todo : Provide one of the supported options in _aLocaleNumberOptions."

	on :CanNotDefineNthDayOfWeek
		_cErrorMsg_ += "   What : Can't define the nth day of week!" + NL
		_cErrorMsg_ += "   Why  : The number of day you provided is out of range." + NL
		_cErrorMsg_ += "   Todo : Provide a number between 1 and 7 and it'll be fine ;)"

	on :UnsupportedLanguageCode
		_cErrorMsg_ += "   What : Can't recognize the language code you provided!" + NL
		_cErrorMsg_ += "   Why  : String you provided is not a supported language code (number, name, or abbreviation)." + NL
		_cErrorMsg_ += "   Todo : Provide a string containing a valid language number, name, or abbreviation, as defined in LocaleLanguagesXT()."

	on :UnsupportedCountryCode
		_cErrorMsg_ += "   What : Can't recognize the country code you provided!" + NL
		_cErrorMsg_ += "   Why  : String you provided is not a supported country code (number, name, or abbreviation)." + NL
		_cErrorMsg_ += "   Todo : Provide a string containing a valid country number, name, or abbreviation, as defined in LocaleLanguagesXT()."

	on :UnsupportedCountryName
		_cErrorMsg_ += "   What : Can't recognize the country name you provided!" + NL
		_cErrorMsg_ += "   Why  : String you provided is not a supported country name." + NL
		_cErrorMsg_ += "   Todo : Provide a string containing a valid country name as defined in LocaleCountriesXT()."

	on :UnsupportedScriptCode
		_cErrorMsg_ += "   What : Can't recognize the script you provided!" + NL
		_cErrorMsg_ += "   Why  : String you provided is not a supported script code." + NL
		_cErrorMsg_ += "   Todo : Provide a string containing a valid script code as defined in LocaleScriptsXT() : number, name, or abbreviation."

	on :UnsupportedLanguageAbbreviation
		_cErrorMsg_ += "   What : Can't recognize the language abbreviation you provided!" + NL
		_cErrorMsg_ += "   Why  : String you provided is not a supported language abbreviation." + NL
		_cErrorMsg_ += "   Todo : Provide a string containing a valid language abbreviation as defined in LanguageAbbreviations()."

	on :UnsupportedLanguageNumber
		_cErrorMsg_ += "   What : Can't recognize the language number you provided!" + NL
		_cErrorMsg_ += "   Why  : String you provided is not a supported language number." + NL
		_cErrorMsg_ += "   Todo : Provide a string containing a valid language number as defined in LanguageNumbers()."

	on :UnsupportedCountryAbbreviation
		_cErrorMsg_ += "   What : Can't recognize the country abbreviation you provided!" + NL
		_cErrorMsg_ += "   Why  : String you provided is not a supported country abbreviation." + NL
		_cErrorMsg_ += "   Todo : Provide a string containing a valid country abbreviation as defined in CountryAbbreviations()."

	on :CanNotProvideCurrencySymbol
		_cErrorMsg_ += "   What : Can't provide you with a convenient formatting for currency in this locale!" + NL
		_cErrorMsg_ += "   Why  : String you provided is not a supported currency format." + NL
		_cErrorMsg_ += "   Todo : Provide a string containing a valid formatting as defined in LocaleCurrencyFormats(): :ISOSymbol, :NativeSymbol, or :NativeName."

	on :UnsupportedLocaleSeparator
		_cErrorMsg_ += "   What : Can't recognize the locale abbreviation separator you provided!" + NL
		_cErrorMsg_ += "   Why  : String you provided is not a supported abbreviation locale separator." + NL
		_cErrorMsg_ += "   Todo : Provide a string containing '-' or '_' and it will be fine ;)"

	off

	return _cErrorMsg_ + NL
