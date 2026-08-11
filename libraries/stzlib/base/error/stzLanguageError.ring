func stzLanguageError(pcError)
	_cErrorMsg_ = "in file stzLanguage.ring:" + char(10)

	switch pcError
	
	on :UnsupportedLanguageIdentifier
		_cErrorMsg_ += "   What : Can't create the language object!" + char(10)
		_cErrorMsg_ += "   Why  : The identifier you provided, as param, is not supported." + char(10)
		_cErrorMsg_ += "   Todo : Provide one of the supported options: a language name, abbreviation, or code, or a country name!"

	off

	return _cErrorMsg_ + char(10)
