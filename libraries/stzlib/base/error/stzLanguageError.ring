func stzLanguageError(pcError)
	_cErrorMsg_ = "in file stzLanguage.ring:" + NL

	switch pcError
	
	on :UnsupportedLanguageIdentifier
		_cErrorMsg_ += "   What : Can't create the language object!" + NL
		_cErrorMsg_ += "   Why  : The identifier you provided, as param, is not supported." + NL
		_cErrorMsg_ += "   Todo : Provide one of the supported options: a language name, abbreviation, or code, or a country name!"

	off

	return _cErrorMsg_ + NL
