

func StzSubStringCSQ( pcSubStr, pcStr, pCaseSensitive )
	return new stzSubStringCS(  pcSubStr, pcStr, pCaseSensitive )

class stzSubStringCS
	@cSubStr
	@cStr
	@pCaseSensitive

	def init( pcSubStr, pcStr, pCaseSensitive )
		if isList(pcStr) and Q(pcStr).IsInOrInStringNamedParam()
			pcStr = pcStr[2]
		ok

		if NOT BothAreStrings(pcSubStr, pcStr)
			StzRaise("Incorrect param type! pcSubStr and pcStr must both be strings.")
		ok

		@cSubStr = pcSubStr
		@cStr = pcStr
		@pCaseSensitive = pCaseSensitive

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

	def CaseSensitive()
		return @pCaseSensitive

	#--

	def NumberOfChars()
		return This.SubStringQ().NumberOfChars()

		def Size()
			return This.NumberOfChars()

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

		def Occurrences()
			return This.Positions()

	#--

	def SectionsCS(pCaseSensitive)
		aResult = This.StringQ().FindAsSectionsCS(This.SubString(), pCaseSensitive)
		return aResult

		def PositionsAsSectionsCS(pCaseSensitive)
			return This.SectionsCS(pCaseSensitive)

	def Sections()
		return This.SectionsCS(:CaseSenstive = TRUE)

		def PositionsAsSections()
			return This.Sections()

	#--

	def OccurrencesXTCS(anOccurrences, pCaseSensitive)
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

	def OccurrencesXT(anOccurrences)
		return This.OccurrencesXTCS(anOccurrences, :CaseSensitive = TRUE)

		def OccurrencesXTQ(anOccurrences)
			return This.OccurrencesXTCSQ(anOccurrences, :CaseSensitive = TRUE)

	#--

	def NthPositionCS(n, pCaseSensitive)
		nResult = This.StringQ().FindNthCS(n, This.SubString(), pCaseSensitive)
		return nResult

	def NthPosition(n)
		return This.NthPositionCS(n, :CaseSensitive = TRUE)

	def FirstPositionCS(pCaseSensitive)
		nResult = This.StringQ().FindFirstCS(This.SubString(), pCaseSensitive)
		return nResult

	def FirstPosition()
		return This.FirstPositionCS(:CaseSensitive = TRUE)

	def LastPositionCS(pCaseSensitive)
		nResult = This.StringQ().FindLastCS(This.SubString(), pCaseSensitive)
		return nResult

	def LastPosition()
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

	def UppercasedInLocaleCS(pLocale, pCaseSensitive)
		cResult = This.StringQ().UppercaseSubStringInLocaleCSQ(This.SubString(), pLocale, pCaseSensitive).Content()
		return cResult

	def UppercasedInLocale()
		return This.UppercasedInLocaleCS(pLocale, :CaseSensitive = TRUE)

	#--

	def LowercasedCS(pCaseSensitive)
		cResult = This.StringQ().LowercaseSubStringCSQ(This.SubString(), pCaseSensitive).Content()
		return cResult

	def Lowercased()
		return This.LowercasedCS(:CaseSensitive = TRUE)

	#--

	def LowercasedInLocaleCS(pLocale, pCaseSensitive)
		cResult = This.StringQ().LowercaseSubStringInLocaleCSQ(This.SubString(), pLocale, pCaseSensitive).Content()
		return cResult

	def LowercasedInLocale()
		return This.LowercasedInLocaleCS(pLocale, :CaseSensitive = TRUE)

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

	#==

	def InstertedBeforeCS(p, pCaseSensitive)
		cResult = This.StringQ().InsertBeforeCSQ(p, This.SubString(), pCaseSensitive)
		return cResult

		def InsertedAtCS(p, pCaseSensitive)
			return This.InstertedBeforeCS(p, pCaseSensitive)

	def InsertedBefore(p)
		return This.InsertedBeforeCS(p, :CaseSensitive = TRUE)

		def InsertedBAt(p)
			return This.InsertedBefore(p)

	#--

	def InsertedBeforePosition(n)
		cResult = This.StringQ().InsertBeofrePositionQ(n, This.SubString()).Content()
		return cResult

		def InsertedAtPosition(n)
			return This.InsertedBeforePosition(n)

	def InsertedBeforePositions(anPos)
		cResult = This.StringQ().InsertBeofrePositionsQ(anPos, This.SubString()).Content()
		return cResult

		def InsertedAtPositions(anPos)
			return This.InsertedBeforePositions(anPos)

		def InsertedBeforeManyPositions(anPos)
			return This.InsertedBeforePositions(anPos)

		def InsertedAtManyPositions(anPos)
			return This.InsertedBeforePositions(anPos)

	#--

	def InsertedBeforeSubStringCS(pcSubStr, pCaseSensitive)
		cResult = This.StringQ().InsertBeforeSubStringCSQ(pcSubStr, This.SubString(), pCaseSensitive).Content()
		return cResult

	def InsertedBeforeSubString(pcSubStr)
		return This.InsertedBeforeSubStringCS(pcSubStr, :CaseSensitive = TRUE)

	#--

	def InsertedBeforeSubStringsCS(pacSubStrings, pCaseSensitive)
		cResult = This.StringQ().InsertBeforeSubStringsCSQ(pacSubStrings, This.SubString(), pCaseSensitive).Content()
		return cResult

		def InsertedBeforeManySubStringsCS(pacSubStrings, pCaseSensitive)
			return This.InsertedBeforeSubStringsCS(pacSubStrings, pCaseSensitive)

	def InsertedBeforeSubStrings(pacSubStrings)
		return This.InsertedBeforeSubStringsCS(pacSubStrings, :CaseSensitive = TRUE)

		def InsertedBeforeManySubStrings(pacSubStrings)
			return This.InsertedBeforeSubStrings(pacSubStrings)

	def InsertedBeforeW(pcCondition)
		cResult = This.String().InsertBeforeWQ(pcCondition, This.SubString()).Content()
		return cResult

		def InsertedAtW(pcCondition)
			return This.InsertedBeforeW(pcCondition)

	#==

	def InstertedAfterCS(p, pCaseSensitive)
		cResult = This.StringQ().InsertAfterCSQ(p, This.SubString(), pCaseSensitive)
		return cResult

	def InsertedAfter(p)
		return This.InsertedAfterCS(p, :CaseSensitive = TRUE)

	#--

	def InsertedAfterPosition(n)
		cResult = This.StringQ().InsertBeofrePositionQ(n, This.SubString()).Content()
		return cResult

	def InsertedAfterPositions(anPos)
		cResult = This.StringQ().InsertBeofrePositionsQ(anPos, This.SubString()).Content()
		return cResult

		def InsertedAfterManyPositions(anPos)
			return This.InsertedAfterPositions(anPos)

	#--

	def InsertedAfterSubStringCS(pcSubStr, pCaseSensitive)
		cResult = This.StringQ().InsertAfterSubStringCSQ(pcSubStr, This.SubString(), pCaseSensitive).Content()
		return cResult

	def InsertedAfterSubString(pcSubStr)
		return This.InsertedAfterSubStringCS(pcSubStr, :CaseSensitive = TRUE)

	#--

	def InsertedAfterSubStringsCS(pacSubStrings, pCaseSensitive)
		cResult = This.StringQ().InsertAfterSubStringsCSQ(pacSubStrings, This.SubString(), pCaseSensitive).Content()
		return cResult

		def InsertedAfterManySubStringsCS(pacSubStrings, pCaseSensitive)
			return This.InsertedAfterSubStringsCS(pacSubStrings, pCaseSensitive)

	def InsertedAfterSubStrings(pacSubStrings)
		return This.InsertedAfterSubStringsCS(pacSubStrings, :CaseSensitive = TRUE)

		def InsertedAfterManySubStrings(pacSubStrings)
			return This.InsertedAfterSubStrings(pacSubStrings)

	def InsertedAfterW(pcCondition)
		cResult = This.String().InsertBeforeWQ(pcCondition, This.SubString()).Content()
		return cResult
