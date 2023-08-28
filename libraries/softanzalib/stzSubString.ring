

func StzSubStringCSQ( pcSubStr, pcStr, pCaseSensitive )
	return new stzSubStringCS(  pcSubStr, pcStr, pCaseSensitive )

class stzSubString
	@cSubStr
	@cStr

	def init( pcSubStr, pcStr )
		if isList(pcStr) and Q(pcStr).IsInOrInStringNamedParam()
			pcStr = pcStr[2]
		ok

		if NOT BothAreStrings(pcSubStr, pcStr)
			StzRaise("Incorrect param type! pcSubStr and pcStr must both be strings.")
		ok

		@cSubStr = pcSubStr
		@cStr = pcStr

	#--

	def SubString()
		return @cSubStr

		def SubStringQ()
			return new stzString(This.SubString())

		def Content()
			return This.SubString()

	def String()
		return @cStr

		def StringQ()
			return new stzString(This.String())

	#--

	def NumberOfOccurrenceCS(pCaseSensitive)
		nResult = This.StringQ().NumberOfOccurrenceCS(This.SubString(), pCaseSensitive)

	def NumberOfOccurrence()
		return This.NumberOfOccurrenceCS(:CaseSensitive = TRUE)

	#--

	def PositionsCS(pCaseSensitive)
		anResult = This.StringQ().FindAllCS(This.SubString())
		return anResult

	def Positions()
		return This.PositionsCS(:CaseSensitive = TRUE)

	#--

	def SectionsCS(pCaseSensitive)
		aResult = This.StringQ().FindAsSectionsCS(This.SubString(), pCaseSensitive)
		return aResult

		def PositionsAsSectionsCS(pCaseSensitive)
			return This.SectionsCS(pCaseSensitive)

	def Sections()
		return This.SectionsCS(pCaseSenstive)

		def PositionsAsSections()
			return This.Sections()

	#--

	def OccurrencesCS(anOccurrences, pCaseSensitive)
		if NOT (isList(anOccurrences) and Q(anOccurrences).IsListOfNumbers())
			StzRaise("Incorrect param type! anOccurrences must be a list of numbers.")
		ok

		anResult = []
		nLen = len(anOccurrences)

		oStr = This.StringQ()

		for i = 1 to nLen
			anResult = oStr.FindNthOccurrenceCS(anOccurrences[i], This.SubString(), pCaseSensitive)
		next

		return anResult

		def OccurrencesCSQ(anOccurrences, pCaseSensitive)
			return new stzOccurrencesCS(anOccurrences, This.SubString(), This.String(), pCaseSensitive)

	def Occurrences(anOccurrences)
		return This.OccurrencesCS(anOccurrences, pCaseSensitive)

		def OccurrencesQ(anOccurrences)
			return This.OccurrencesCSQ(anOccurrences, :CaseSensitive = TRUE)

	#--

	def NthPositionCS(n, pCaseSensitive)
		nResult = This.StringQ().FindNthCS(n, This.SubString(), pCaseSensitive)
		return nResult

	def NthPosition(n)
		return This.NthPositionCS(n, :CaseSensitive = TRUE)

	def FirstPositionCS(pCaseSensitive)
		nResult = This.StringQ().FindFirstCS(This.SubString(), pCaseSensitive)
		return nResult

	def FirstPosition(n)
		return This.FirstPositionCS(n, :CaseSensitive = TRUE)

	def LastPositionCS(pCaseSensitive)
		nResult = This.StringQ().FindLastCS(This.SubString(), pCaseSensitive)
		return nResult

	def LastPosition(n)
		return This.LastPositionCS(:CaseSensitive = TRUE)

	#--

	def IsBoundedByCS(pacBounds, pCaseSensitive)
		bResult = This.StringQ().ContainsSubStringBoundedByCSQ(This.SubString(), pacBounds, pCaseSensitive).Content()
		return bResult

	def IsBoundedBy(pacBounds)
		return This.IsBoundedByCS(pacBounds, :CaseSensitive = TRUE)

	#--

	def IsBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		bResult = This.StringQ().ContainsSubStringBetweenCSQ(This.SubString(), pcBound1, pcBound2, pCaseSensitive).Content()
		return bResult

	def IsBetween(pcBound1, pcBound2)
		return This.IsBetweenCS(pcBound1, pcBound2, :CaseSensitive = TRUE)

	#--

	def ReplacedWithCS(pcOtherSubStr, pCaseSensitive)
		cResult = This.StringQ().ReplaceCSQ(This.SubString(), pcOtherSubStr, pCaseSensitive).Content()
		return cResult

		def ReplacedCS(pcOtherSubStr, pCaseSensitive)
			if isList(pcOtherSubStr) and Q(pcOtherSubStr).IsWithOrByNamedParam()
				pcOtherSubStr = pcOtherSubStr[2]
			ok

			return This.ReplacedWithCS(pcOtherSubStr, pCaseSensitive)

	def ReplacedWith(pcOtherSubStr)
		return This.ReplacedWithCs(pcOtherSubStr, :CaseSensitive = TRUE)

		def Replaced(pcOtherSubStr)
			return This.ReplacedCS(pcOtherSubStr, :CaseSensitive = TRUE)
 
	#--

	def RemovedCS(pCaseSensitive)
		cResult = This.StringQ().RemoveCSQ(This.SubString(), pCaseSensitive).Content()
		return cResult

	def Removed()
		return This.RemovedCS(:CaseSensitive = TRUE)

	#--

	def UppercasedCS(pCaseSensitive)
		cResult = This.StringQ().UppercaseSubStringCSQ(This.SubString(), pCaseSensitive).Content()
		return cResult

	def Uppercased()
		return This.UppercasedCS(:CaseSensitive = TRUE)

	#--

	def LowercasedCS(pCaseSensitive)
		cResult = This.StringQ().LowercaseSubStringCSQ(This.SubString(), pCaseSensitive).Content()
		return cResult

	def Lowerercased()
		return This.LowercasedCS(:CaseSensitive = TRUE)

	#--

	def InsertedXT(paOptions)
		/*
		o1 = new stzString("99999999999")
		o1.SubStringQ("_").InsertedXT([ :After, :EachNChars = 3, :Going = :Backward ])
		? o1.Content()
		#--> 99_999_999_999
		*/

		cResult = This.StringQ().InsertXTQ( This.SubString(), paOptions ).Content()
		return cResult

	#--

	def InstertedBefore()

	def InsertedAfter()

	def InsertedAtPositions()
