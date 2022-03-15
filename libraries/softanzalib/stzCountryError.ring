func stzCountryError(pcError)
	cErrorMsg = "in file stzCountry.ring:" + NL

	switch pcError
	on :UnsupportedCountryIdentifier
		cErrorMsg += "   What : Can't create the stzCountry object!" + NL
		cErrorMsg += "   Why  : String you provided doesn't help in identifying the country." + NL
		cErrorMsg += "   Todo : Provide a string containing a country name, abbreviation, phone code, or even a default language name!"

	off

	return cErrorMsg + NL
