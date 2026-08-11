func stzHexNumberError(pcError)
	_cErrorMsg_ = "in file stzHexNumber.ring:" + char(10)

	switch pcError

	on :CanNotCreateHexNumber
		_cErrorMsg_ += "   What : Can't create the hex number." + char(10)
		_cErrorMsg_ += "   Why  : The value you provided is not in correct hex form." + char(10)
		_cErrorMsg_ += '   Todo : Provide a hex number in a string prefixed by "' + HexPrefix() +
			     '" and containing only hex characters (from 0 to 9 and from A to F).'

	off

	return _cErrorMsg_ + char(10)
