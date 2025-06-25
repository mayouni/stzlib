func stzWarning(pcWarning)
	switch pcWarning
	on :NotYetImplemented
		cWarningMsg = NL
		cWarningMsg += "	This feature is not yet implemented!" + NL

	off

	return cWarningMsg
