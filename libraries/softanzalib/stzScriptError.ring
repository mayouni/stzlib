func stzScriptError(pcError)
	cErrorMsg = "in file stzScript.ring:" + NL

	switch pcError
	
	on :UnsupportedScriptIdentifier
		cErrorMsg += "   What : Can't create the script object!" + NL
		cErrorMsg += "   Why  : The identifier you provided, as param, is not supported." + NL
		cErrorMsg += "   Todo : Provide one of the supported options: a script name, abbreviation, or code!"
	off

	return cErrorMsg + NL
