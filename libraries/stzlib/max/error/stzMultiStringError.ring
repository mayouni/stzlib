
func stzMultilingualStringError(pcError)

	cErrorMsg = "in file stzMultilingualStringError.ring:" + char(10)

	switch pcError
	on :UnsupportedLanguageNameOrAbbreviation
		cErrorMsg += "   What : Unsupported language name or abbreviation!" + char(10)
		cErrorMsg += "   Why  : Provided string is not a well-formed language name or abbreviation." + char(10)
		cErrorMsg += "   Todo : Provided a well-formed language name or abbreviation as defined in LocaleLanguagesXT()."

	off

	return cErrorMsg + char(10)
