func stzCountryError(pcError)
	_cErrorMsg_ = "in file stzCountry.ring:" + char(10)

	switch pcError
	on :UnsupportedCountryIdentifier
		_cErrorMsg_ += "   What : Can't create the stzCountry object!" + char(10)
		_cErrorMsg_ += "   Why  : String you provided doesn't help in identifying the country." + char(10)
		_cErrorMsg_ += "   Todo : Provide a string containing a country name, abbreviation, phone code, or even a default language name!"

	off

	return _cErrorMsg_ + char(10)
