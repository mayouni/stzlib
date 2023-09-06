

  #-------------#
 #  FUNCTIONS  #
#-------------#

func StzSubStringCSQ( pcSubStr, pcStr, pCaseSensitive )
	return new stzSubStringCS( pcSubStr, pcStr, pCaseSensitive )

func StzSubStringQ( pcSubStr, pcStr )
	return new stzSubString(  pcSubStr, pcStr )

#== SubString

func SubStringCSQ(pcSubStr, pCaseSensitive)

	if isList(pcSubStr) and Q(pcSubStr).IsPair() and
	   isString(pcSubStr[1]) and Q(pcSubStr[2]).IsInOrInStringNamedParam()

		return SubStringInCSQ(pcSubStr[1], pcSubStr[2][2], pCaseSensitive)
	ok

	return new stzString(pcSubStr)

	func SubStringCS(pcSubStr, pCaseSensitive)
		return SubStringCSQ(pcSubStr, pCaseSensitive)

	func TheSubStringCSQ(pcSubStr, pCaseSensitive)
		return SubStringCSQ(pcSubStr, pCaseSensitive)

func SubStringQ(pcSubStr)
	return SubStringCSQ(pcSubStr, :CaseSensitive)

	# NOTE: can nor add SubString() because it is seems to be reserved by Ring!

	func TheSubStringQ(pcSubStr)
		return SubStringQ(pcSubStr)

	func TheSubString(pcSubStr)
		return  SubStringQ(pcSubStr)

func TheSubStringInCSQ( pcSubstr, pcInStr, pCaseSensitive )
	if isList(pcInStr) and Q(pcInStr).IsInOrInStringNamedParam()
		pcInStr = pcInStr[2]
	ok

	return new stzSubStringCS( pcSubStr, pcInStr, pCaseSensitive )

	func SubStringInCSQ(pcSubstr, pcInStr, pCaseSensitive)
		return TheSubStringInCSQ( pcSubstr, pcInStr, pCaseSensitive )

	func SubStringInCS(pcSubStr, pcInStr, pCaseSensitive)
		return TheSubStringInCSQ( pcSubstr, pcInStr, pCaseSensitive )

	func TheSubStringInCS(pcSubStr, pcInStr, pCaseSensitive)
		return TheSubStringInCSQ( pcSubstr, pcInStr, pCaseSensitive )

func TheSubStringInQ( pcSubstr, pcInStr )
	return TheSubStringInCSQ(pcSubStr, pcInStr, :CaseSensitive)

	func SubStringInQ(pcSubStr, pcInStr)
		return TheSubStringInQ( pcSubstr, pcInStr )

	func SubStringIn(pcSubStr, pcInStr)
		return TheSubStringInQ( pcSubstr, pcInStr )

	func TheSubStringIn(pcSubStr, pcInStr)
		return TheSubStringInQ( pcSubstr, pcInStr )

#--

func ASubStringCS(pcStr, pCaseSensitive)
	if isList(pcStr) and Q(pcStr).IsInOrInStringNamedParam()
		pcStr = pcStr[2]
	ok

	acSubStr = Q(pcStr).SubStringsCS(pCaseSensitive)
	nLen = len(acSubStr)
	n = ANumberBetween(1, nLen)
	oResult = new stzSubStringCS(acSubStr[n], pcStr, pCaseSensitive)
	return oResult

func ASubString(pcStr)
	return ASubStringCS(pcStr, :CaseSensitive = TRUE)

#--

func SomeSubStringsCS(pcStr, pCaseSensitive)
	if isList(pcStr) and Q(pcStr).IsInOrInStringNamedParam()
		pcStr = pcStr[2]
	ok

	aSections = Q(pcStr).SubStringsAsSectionsCS(pCaseSensitive)
	nLen = len(aSections)
	anRandom = 3NumbersBetween(1, nLen)

	aSections = Q(aSections).ItemsAtPositions(anRandom)
	oResult = new stzListOfSubStringsCS(aSections, pcStr, pCaseSensitive)
	return oResult

func SomeSubStrings(pcStr)
	return SomeSubStringsCS(pcStr, :CaseSensitive = TRUE)

#== Word

func WordCSQ(pcSubStr, pCaseSensitive)

	if isList(pcSubStr) and Q(pcSubStr).IsPair() and
	   isString(pcSubStr[1]) and Q(pcSubStr[2]).IsInOrInStringNamedParam()

		return WordInCSQ(pcSubStr[1], pcSubStr[2][2], pCaseSensitive)
	ok

	return new stzString(pcSubStr)

	func WordCS(pcSubStr, pCaseSensitive)
		return WordCSQ(pcSubStr, pCaseSensitive)

	func TheWordCSQ(pcSubStr, pCaseSensitive)
		return WordCSQ(pcSubStr, pCaseSensitive)

func WordQ(pcSubStr)
	return WordCSQ(pcSubStr, :CaseSensitive)

	func Word(pcSubStr)

	func TheWordQ(pcSubStr)
		return WordQ(pcSubStr)

	func TheWord(pcSubStr)
		return WordQ(pcSubStr)

func TheWordInCSQ( pcSubstr, pcInStr, pCaseSensitive )
	if isList(pcInStr) and Q(pcInStr).IsInOrInStringNamedParam()
		pcInStr = pcInStr[2]
	ok

	if NOT Q(pcInStr).SubStringIsWordCS(pcSubStr, pCaseSensitive)
		StzRaise("Incorrect type! pcSubStr must be a word in the string pcInStr.")
	ok

	return new stzSubStringCS( pcSubStr, pcInStr, pCaseSensitive )

	func WordInCSQ(pcSubstr, pcInStr, pCaseSensitive)
		return TheWordInCSQ( pcSubstr, pcInStr, pCaseSensitive )

	func WordInCS(pcSubStr, pcInStr, pCaseSensitive)
		return TheWordInCSQ( pcSubstr, pcInStr, pCaseSensitive )

	func TheWordInCS(pcSubStr, pcInStr, pCaseSensitive)
		return TheWordInCSQ( pcSubstr, pcInStr, pCaseSensitive )

func TheWordInQ( pcSubstr, pcInStr )
	return TheWordInCSQ(pcSubStr, pcInStr, :CaseSensitive)

	func WordInQ(pcSubStr, pcInStr)
		return TheWordInQ( pcSubstr, pcInStr )

	func WordIn(pcSubStr, pcInStr)
		return TheWordInQ( pcSubstr, pcInStr )

	func TheWordIn(pcSubStr, pcInStr)
		return TheWordInQ( pcSubstr, pcInStr )

#--

func AWordCS(pcStr, pCaseSensitive)
	if isList(pcStr) and Q(pcStr).IsInOrInStringNamedParam()
		pcStr = pcStr[2]
	ok

	acSubStr = Q(pcStr).WordsCS(pCaseSensitive)
	nLen = len(acSubStr)
	n = ANumberBetween(1, nLen)
	oResult = new stzSubStringCS(acSubStr[n], pcStr, pCaseSensitive)
	return oResult

func AWord(pcStr)
	return AWordCS(pcStr, :CaseSensitive = TRUE)

#--

func SomeWordsCS(pcStr, pCaseSensitive)
	if isList(pcStr) and Q(pcStr).IsInOrInStringNamedParam()
		pcStr = pcStr[2]
	ok

	aSections = Q(pcStr).WordsAsSectionsCS(pCaseSensitive)
	nLen = len(aSections)
	anRandom = 3NumbersBetween(1, nLen)

	aSections = Q(aSections).ItemsAtPositions(anRandom)
	oResult = new stzListOfSubStringsCS(aSections, pcStr, pCaseSensitive)
	return oResult

func SomeWords(pcStr)
	return SomeWordsCS(pcStr, :CaseSensitive = TRUE)


  #-----------#
 #  CLASSES  #
#-----------#

class stzListOfSubstringsCS
	@acSubStr
	@aSections
	@cStr
	@pCaseSensitive

	def init(paSections, pcStr, pCaseSensitive)
		if NOT isList(paSections) and Q(paSections).IsListOfPairsOfNumbers()
			StzRaise("Incorrect param type! paSections must be a list of pairs of numbers.")
		ok

		if isList(pcStr) and Q(pcStr).IsInOrInStringNamedParam()
			pcStr = pcStr[2]
		ok

		if NOT isString(pcStr)
			StzRaise("Incorrect param type! pcStr must be a string.")
		ok

		@acSubStr = Q(pcStr).Sections(paSections)
		@aSections = paSections
		@cStr = pcStr
		@pCaseSensitive = pCaseSensitive

	def SubStrings()
		return 	@acSubStr

		def SubStringsQ()
			return new stzList(This.SubStrings())

		def SubStringsQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList(This.SubStrings())
			on :stzListOfStrings
				return new stzListOfStrings(This.SubStrings())
			on :stzPair
				return new stzListOfPairs(This.SubStrings())
			other
				StzRaise("Unsupported return type!")
			off

	def Sections()
		return @aSections

		def SectionQ()
			return new stzList(This.Sections())

		def SectionsQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList(This.Sections())
			on :stzListOfPairs
				return new stzListOfPairs(This.Sections())
			other
				StzRaise("Unsupported return type!")
			off

	def String()
		return @cStr

		def StringQ()
			return new stzString(This.String())

	def CaseSensitive()
		return @pCaseSensitive

	def Uppercased()
		acResult = This.StringQ().SectionsUppercased(This.Sections())
		return acResult

	def Lowercased()
		acResult = This.StringQ().SectionsLowercased(This.Sections())
		return acResult

class stzListOfSubStrings from stzListOfSubStringsCS
	@acSubStr
	@cStr
	@pCaseSensitive

class stzSubStrings from stzListOfStrings

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

	def OccurrencesCSXT(anOccurrences, pCaseSensitive)
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
		return This.OccurrencesCSXT(anOccurrences, :CaseSensitive = TRUE)

		def OccurrencesXTQ(anOccurrences)
			return This.OccurrencesCSXTQ(anOccurrences, :CaseSensitive = TRUE)

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
		bResult = This.StringQ().ContainsSubStringBoundedByCS(This.SubString(), pacBounds, pCaseSensitive)
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

	def BoundedByCS(pacBounds, pCaseSensitive)
		bResult = This.StringQ().BoundSubStringByCSQ(This.SubString(), pacBounds, pCaseSensitive).Content()
		return bResult

	def BoundedBy(pacBounds)
		return This.BoundedByCS(pacBounds, :CaseSensitive = TRUE)

	#--

	def ReplacedWithCS(pcOtherSubStr, pCaseSensitive)
		cResult = This.StringQ().ReplaceCSQ(This.SubString(), pcOtherSubStr, pCaseSensitive).Content()
		return cResult

		def ReplacedCS(pcOtherSubStr, pCaseSensitive)
			return This.ReplacedWithCS(pcOtherSubStr, pCaseSensitive)

		def ReplacedByCS(pcOtherSubStr, pCaseSensitive)
			return This.ReplacedWithCS(pcOtherSubStr, pCaseSensitive)

	def ReplacedWith(pcOtherSubStr)
		return This.ReplacedWithCs(pcOtherSubStr, :CaseSensitive = TRUE)

		def Replaced(pcOtherSubStr)
			return This.ReplacedWith(pcOtherSubStr)
 
		def ReplacedBy(pcOtherSubStr)
			return This.ReplacedWith(pcOtherSubStr)

	#--

	def RemovedCS(pCaseSensitive)
		cResult = This.StringQ().RemoveCSQ(This.SubString(), pCaseSensitive).Content()
		return cResult

	def Removed()
		return This.RemovedCS(:CaseSensitive = TRUE)

	#--

	def IsLowercased()
		if This.SubStringQ().IsLowercased() and
		   This.StringQ().Contains(This.SubString())

			return TRUE
		else
			return FALSE
		ok

		def IsInLowercase()
			return This.IsLowercased()

	def IsUppercased()
		if This.SubStringQ().IsUppercased() and
		   This.StringQ().Contains(This.SubString())

			return TRUE
		else
			return FALSE
		ok

		def IsInUppercase()
			return This.IsUppercased()
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
		cResult = This.StringQ().InsertBeforeWQ(pcCondition, This.SubString()).Content()
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
		cResult = This.StringQ().InsertBeforeWQ(pcCondition, This.SubString()).Content()
		return cResult
