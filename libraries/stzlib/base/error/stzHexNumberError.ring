func stzHexNumberError(pcError)
	_cErrorMsg_ = "in file stzHexNumber.ring:" + NL

	switch pcError

	on :CanNotCreateHexNumber
		_cErrorMsg_ += "   What : Can't create the hex number." + NL
		_cErrorMsg_ += "   Why  : The value you provided is not in correct hex form." + NL
		_cErrorMsg_ += '   Todo : Provide a hex number in a string prefixed by "' + HexPrefix() +
			     '" and containing only hex characters (from 0 to 9 and from A to F).'

	off

	return _cErrorMsg_ + NL
