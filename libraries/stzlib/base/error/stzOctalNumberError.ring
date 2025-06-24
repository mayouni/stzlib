func stzOctalNumberError(pcError)
	cErrorMsg = "in file stzOctalNumber.ring:" + NL
	switch pcError

	on :CanNotCreateOctalNumber
		cErrorMsg += "   What : Can't create the octal number." + NL
		cErrorMsg += "   Why  : The value you provided is not in correct octal form." + NL
		cErrorMsg += "   Todo : Provide an octal number in a STRING formed of octal digits (0 to 7) and preceeded by the small letter o."

	off

	return cErrorMsg + NL
