func stzCurrencyError(pcError)
	_cErrorMsg_ = "in file stzCurrency.ring:" + NL

	switch pcError
	
	on :UnsupportedCurrencyIdentifier
		_cErrorMsg_ += "   What : Can't create the currency object!" + NL
		_cErrorMsg_ += "   Why  : The identifier you provided, as param, is not supported." + NL
		_cErrorMsg_ += "   Todo : Provide one of the supported options: a country name, or a currency name, symbol name, or symbol char!"
	off

	return _cErrorMsg_ + NL
