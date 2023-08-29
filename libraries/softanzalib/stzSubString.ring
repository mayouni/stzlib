

func StzSubStringQ( pcSubStr, pcStr )
	return new stzSubString(  pcSubStr, pcStr )

class stzSubString from stzSubStringCS
	@cSubStr
	@cStr
	@pCaseSensitive

	def init( pcSubStr, pcStr )
		if isList(pcStr) and Q(pcStr).IsInOrInStringNamedParam()
			pcStr = pcStr[2]
		ok

		if NOT BothAreStrings(pcSubStr, pcStr)
			StzRaise("Incorrect param type! pcSubStr and pcStr must both be strings.")
		ok

		@cSubStr = pcSubStr
		@cStr = pcStr
		@pCaseSensitive = TRUE
