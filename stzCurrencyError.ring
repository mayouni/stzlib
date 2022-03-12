func stzCurrencyError(pcError)
	cErrorMsg = "in file stzCurrency.ring:" + NL

	switch pcError
	
	on :UnsupportedCurrencyIdentifier
		cErrorMsg += "   What : Can't create the currency object!" + NL
		cErrorMsg += "   Why  : The identifier you provided, as param, is not supported." + NL
		cErrorMsg += "   Todo : Provide one of the supported options: a country name, or a currency name, symbol name, or symbol char!"
	off

	return cErrorMsg + NL
