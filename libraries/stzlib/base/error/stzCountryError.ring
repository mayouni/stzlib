func stzCountryError(pcError)
	_cErrorMsg_ = "in file stzCountry.ring:" + NL

	switch pcError
	on :UnsupportedCountryIdentifier
		_cErrorMsg_ += "   What : Can't create the stzCountry object!" + NL
		_cErrorMsg_ += "   Why  : String you provided doesn't help in identifying the country." + NL
		_cErrorMsg_ += "   Todo : Provide a string containing a country name, abbreviation, phone code, or even a default language name!"

	off

	return _cErrorMsg_ + NL
