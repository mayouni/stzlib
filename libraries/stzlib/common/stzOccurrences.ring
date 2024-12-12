
func StzOccurrenceQ(panOccurr, pcSubStr, pcStr)
	return new stzOccurrences(panOccurr, pcSubStr, pcStr)

class stzOccurrences
	@anOccurrences
	@cSubStr
	@cStr

	def init(panOccurr, pcSubStr, pcStr)
		if isList(pcSubStr) and Q(pcSubStr).IsOfOrOfSubStringNamedParam()
			pcSubStr = pcSubStr[2]
		ok

		if isList(pcStr) and Q(pcStr).IsInOrInStringNamedParam()
			pcStr = pcStr[2]
		ok

		@anOccurrences = panOccurr
		@pcSubStr = pcSubStr
		@pcStr = pcStr

	def Occurrences()
		return @anOccurrences

		def Content()
			return This.Occurrences()

		def Value()
			return Content()

	def SubString()
		return @cSubStr

		def SubStringQ()
			return new stzString(This.SubString())

	def String()
		return @cStr

		def StringQ()
			return new stzString(This.String())

	#--

	def RemovedCS(pCaseSensitive)
		cResult = This.StringQ().
				RemoveSubStringAtPositionsCSQ(
					This.Occurrences, This.SubString(), pCaseSensitive).
				Content()

		return cResult

	def Removed()
		return This.RemovedCS(_TRUE_)


	#--

	def ReplacedWithCS()

	def Uppercased()

	def Lowercased()
