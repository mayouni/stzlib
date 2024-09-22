func stzTextStreamError(pcError)
	cErrorMsg = "in file stzTextStream.ring:" + NL

	switch pcError

	on :UnsupportedStreamStatus
		cErrorMsg += "   What : Can't set the stream to the satus you provided." + NL
		cErrorMsg += "   Why  : The status you provided is not supported." + NL
		cErrorMsg += "   Todo : Check the list of supported statuses using SupportedStreamStatuses()."

	off

	return cErrorMsg + NL

func SupportedStreamStatuses()
	return _acSupportedStreamStatuses
