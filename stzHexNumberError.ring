func stzHexNumberError(pcError)
	cErrorMsg = "in file stzHexNumber.ring:" + NL

	switch pcError

	on :CanNotCreateHexNumber
		cErrorMsg += "   What : Can't create the hex number." + NL
		cErrorMsg += "   Why  : The value you provided is not in correct hex form." + NL
		cErrorMsg += '   Todo : Provide a hex number in a string prefixed by "' + HexPrefix() +
			     '" and containing only hex characters (from 0 to 9 and from A to F).'

	off

	return cErrorMsg + NL
