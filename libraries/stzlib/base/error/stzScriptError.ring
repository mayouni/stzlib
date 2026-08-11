func stzScriptError(pcError)
	_cErrorMsg_ = "in file stzScript.ring:" + char(10)

	switch pcError
	
	on :UnsupportedScriptIdentifier
		_cErrorMsg_ += "   What : Can't create the script object!" + char(10)
		_cErrorMsg_ += "   Why  : The identifier you provided, as param, is not supported." + char(10)
		_cErrorMsg_ += "   Todo : Provide one of the supported options: a script name, abbreviation, or code!"
	off

	return _cErrorMsg_ + char(10)
