
func stzMultilingualStringError(pcError)

	cErrorMsg = "in file stzMultilingualStringError.ring:" + NL

	switch pcError
	on :UnsupportedLanguageNameOrAbbreviation
		cErrorMsg += "   What : Unsupported language name or abbreviation!" + NL
		cErrorMsg += "   Why  : Provided string is not a well-formed language name or abbreviation." + NL
		cErrorMsg += "   Todo : Provided a well-formed language name or abbreviation as defined in LocaleLanguagesXT()."

	off

	return cErrorMsg + NL
