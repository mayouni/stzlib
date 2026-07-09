func stzOctalNumberError(pcError)
	_cErrorMsg_ = "in file stzOctalNumber.ring:" + NL
	switch pcError

	on :CanNotCreateOctalNumber
		_cErrorMsg_ += "   What : Can't create the octal number." + NL
		_cErrorMsg_ += "   Why  : The value you provided is not in correct octal form." + NL
		_cErrorMsg_ += "   Todo : Provide an octal number in a STRING formed of octal digits (0 to 7) and preceeded by the small letter o."

	off

	return _cErrorMsg_ + NL
