func stzLanguageError(pcError)
	cErrorMsg = "in file stzLanguage.ring:" + NL

	switch pcError
	
	on :UnsupportedLanguageIdentifier
		cErrorMsg += "   What : Can't create the language object!" + NL
		cErrorMsg += "   Why  : The identifier you provided, as param, is not supported." + NL
		cErrorMsg += "   Todo : Provide one of the supported options: a language name, abbreviation, or code, or a country name!"

	off

	return cErrorMsg + NL
