

# Returns the softanza object related to the type of p
func StzQ(p)

	oResult = AFalseObject()

	if isString(p)
		oResult = new stzString(p)

	but isNumber(p)
		oResult = new stzNumber(p)

	but isList(p)
		oResult = new stzList(p)

	but isObject(p)
		oResult = new stzObject(p)
	ok

	return oResult

	func Q(p)
		return StzQ(p)

	func @Q(p)
		return StzQ(p)

	func The(p)
		return StzQ(p)

	func TheQ(p)
		return StzQ(p)

	func TQ(p)
		return StzQ(p)

func StzQH(p)
	#TODO // Review the code of all functions where loops are used
	# on the main object and modify it many times

	#~> // Use a copy on which the loop is used and then update
	# the main object in on UpdateWith() call

	if isglobal("_aHisto")
		_aHisto + p
	ok

	return StzQ(p)

# Global stub: history-tracking toggle. The full implementation will
# weave through each mutating method; for now we just declare the
# globals so callers don't R3.
func SetKeepingHistoryTo(bOn)
	# No-op stub.
	return

func SetKeepingHistoryToXT(bOn, pcMode)
	# No-op stub.
	return

	return StzQHHV(p) # tracing only the value (V)

	func QH(p)
		return StzQH(p)

	func StzQHHV(p)
		return StzQHH(p)

func StzQHH(p)
	SetKeepingTimeTo(1)
	SetKeepingHistoryToXT(1, :VTMS)

	return StzQ(p)

	func QHH(p)
		return StzQHH(p)

	func QHHVTMS(p) # Tracing Value, Type, Time and Size
		return StzQHH(p)

	func StzQHHVTMS(p)
		return StzQHH(p)

func StzQHHVT(p) # Tracing Value and Type
	SetKeepingTimeTo(1)
	SetKeepingHistoryToXT(1, :VT)

	return StzQ(p)

	func QHHVT(p)
		return StzQHHVT(p)

func StzQHHVM(p) # Tacing Value and Time
	SetKeepingTimeTo(1)
	SetKeepingHistoryToXT(1, :VM)

	return StzQ(p)

	func QHHVM(p)
		return StzQHHVM(p)

func StzQHHVS(p) # Tracing Value and Size
	SetKeepingTimeTo(1)
	SetKeepingHistoryToXT(1, :VS)

	return StzQ(p)

	func QHHVS(p)
		return StzQHHVS(p)

func StzQHHTM(p) # Tracing Type and Time
	SetKeepingTimeTo(1)
	SetKeepingHistoryToXT(1, :TM)

	return StzQ(p)

	func QHHTM(p)
		return StzQHHTM(p)

func StzQHHTS(p) # Tacing Type and Size
	SetKeepingTimeTo(1)
	SetKeepingHistoryToXT(1, :TS)

	return StzQ(p)

	func QHHTS(p)
		return StzQHHTS(p)

func StzQHHMS(p) # Tracing Time and Size
	SetKeepingTimeTo(1)
	SetKeepingHistoryToXT(1, :MS)

	return StzQ(p)

	func QHHMS(p)
		return StzQHHMS(p)

func StzQHHVTM(p) # Tracing Value, Type nad Time
	SetKeepingTimeTo(1)
	SetKeepingHistoryToXT(1, :TM)

	return StzQ(p)

	func QHHVTM(p)
		return StzQHHVTM(p)

func StzQHHVTS(p) # Tracing Value, Type and Size
	SetKeepingTimeTo(1)
	SetKeepingHistoryToXT(1, :VTS)

	return StzQ(p)

	func QHHVTS(p)
		return StzQHHVTS(p)

func StzQHHTMS(p) # Tracing Type, Time and Size
	SetKeepingTimeTo(1)
	SetKeepingHistoryToXT(1, :TMS)

	return StzQ(p)

	func QHHTMS(p)
		return StzQHHTMS(p)

#--

func StzW(cType, paMethodAndFilter)
	/* EXAMPLE
	? StzW(:Char, [ :Methods, :Where = 'Q(@Method).StartsWith("is")' ])
	*/

	if NOT ( isList(paMethodAndFilter) and len(paMethodAndFilter) = 2 and
		 isList(paMethodAndFilter[2]) and
		 Q(paMethodAndFilter[2]).IsWhereNamedParam() and
		 isString(paMethodAndFilter[2][2]) )

		StzRaise('Incorrect param type! paMethodAndFilter must be a pair of the form [ :Methods, :Where = "@Method..." ], for example.')
	ok

	aTempList = Stz(cType, paMethodAndFilter[1])
	cCondition = Q(paMethodAndFilter[2][2]).
			ReplaceCSQ("@Method", "@Item", 0).
			Content()

	aResult = QRT(aTempList, :stzListOfStrings).StringsW(ccondition)

	return aResult

func Stz(cType, pInfo)
	/* EXAMPLE
		? Stz(:Char, :Methods) #--> [ :Init, :Content, ... ]
	*/

	if isList(pInfo) and len(pInfo) = 2 and
		 isList(pInfo[2]) and
		 Q(pInfo[2]).IsWhereNamedParam() and
		 isString(pInfo[2][2])

		return stzW(cType, pInfo)
	ok

	cInfo = pInfo

	if NOT @BothAreStrings(cType, :And = cInfo)
		StzRaise("Incorrect params type! Botht cType and cInfo must be strings.")
	ok

	cClass = 'stz' + cType

	if NOT Q(cClass).IsStzClassName()
		StzRaise("Incorrect param! cType must be a valid softanza type.")
	ok

	oEmptyObject = Empty(cClass)

	switch cInfo
	on :Class
		return cClass

	on :ClassName
		return cClass

	on :Methods
		return methods(oEmptyObject)

	on :Attributes
		return attributes(oEmptyObject)

	other
		StzRaise("Unsupported information! Allowed values are :Methods and :Attributes.")
	off


# This function tries its best to infere a convenient type
# by analysing a value hosted in a string

func StzQQ(p)

	/* EXAMPLE 1

	? StzQQ("19")		# stzNumber
	#--> Note that this is a number in string:
	? StzQ("19").IsNumberInString() #--> TRUE

	EXAMPLE 2

	? StzQQ("[1, 2, 3]")	#--> stzListOfNumbers
	#--> Note that this is a list in string:
	? StzQ("[1, 2, 3]").IsListOfNumbersInString() #--> TRUE

	EXAMPLE 3

	? StzQQ(' [ "one", "two", "three" ] ')	#--> stzListOfStrings
	#--> Note that this is a list of strings in a string:
	? StzQ(' [ "one", "two", "three" ] ').IsListOfStringsInString #--> TRUE

	*/

	if isString(p)

		oParam = new stzString(p)

		if oParam.IsNumberInString()
			return new stzNumber(p)

		but oParam.IsListInString()
			return new stzList(StzL(p))

		but oParam.IsChar() or oParam.IsHexUnicode()
			return new stzChar(p)

		but StzIsDate(p)
			return new stzDate(p)

		ok

		return new stzText(p)

	but isList(p)

		oQTemp = StzQ(p)

		if oQTemp.IsListOfNumbers()
			return new stzListOfNumbers(p)

		but oQTemp.IsListOfChars()
			return new stzListOfChars(p)

		but oQTemp.IsListOfStrings()
			return new stzListOfStrings(p)

		but oQTemp.IsListOfHashLists()
			return new stzListOfHashLists(p)

		but oQTemp.IsListOfPairs()
			return new stzListOfPairs(p)

		but oQTemp.IsListOfLists()
			return new stzListOfLists(p)

		else
			return new stzList(p)
		ok

	else
		return StzQ(p)
	ok

	func QQ(p)
		return StzQQ(p)

#---

func StzN(p)
	if isNumber(p)
		return p

	but isString(p)

		oParam = StzQ(p)

		if oParam.IsNumberInString()
			return 0+ p

		but oParam.IsListInString()
			return len( StzQ(p).ToList() )

		else
			return StzQ(p).NumberOfChars()
		ok

	but isList(p)
		return len(p)

	but isObject(p)
		return len( StzQ(p).ObjectAttributes() )
	ok

	func N(p)
		return StzN(p)

	func StzNQ(p)
		return new stzNumber( StzN(p) )

	func NQ(p)
		return StzNQ(p)

	func QN(p)
		return StzNQ(p)

#---

func StzS(p)
	if isString(p)
		return p

	but isNumber(p)
		return ""+ p

	but isList(p)
		return StzQ(p).ToCode()

	but isObject(p)
		return StzLQ(p).ToCode()
	ok

	func S(p)
		return StzS(p)

	func StzSQ(p)
		return StzQ( StzS(p) )

	func SQ(p)
		return StzSQ(p)

	func QS(p)
		return StzSQ(p)


#---

func StzUCS(p, pCaseSensitive)
	/* EXAMPLE

	? StzU([ "a", 1, 2, 2, "a", "a", 3 ]) # Or Unique() or WithoutDuplicates()
	#--> [ "a", 1, 2, 3 ]

	*/

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type!")
		ok
	ok

	aResult = []
	nLen = len(p)
	for i = 1 to nLen
		bFound = 0
		nResLen = len(aResult)
		for j = 1 to nResLen
			if BothAreEqualCS(aResult[j], p[i], pCaseSensitive)
				bFound = 1
				exit
			ok
		next
		if NOT bFound
			aResult + p[i]
		ok
	next
	return aResult

	func UCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func StzWithoutDuplicatesCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func WithoutDuplicatesCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func WithoutDupplicatesCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func StzUniqueCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func UniqueCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func @UCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func @WithoutDuplicatesCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func @WithoutDupplicatesCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func @UniqueCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func StzUniqueItemsCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func UniqueItemsCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func @UniqueItemsCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func UniqueItemsInCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func @UniqueItemsInCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func StzToSetCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func ToSetCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)

	func @ToSetCS(p, pCaseSensitive)
		return StzUCS(p, pCaseSensitive)


func StzU(p)
	return StzUCS(p, 1)

	func U(p)
		return StzU(p)

	func StzWithoutDuplicates(p)
		return StzU(p)

	func WithoutDuplicates(p)
		return StzU(p)

	func WithoutDupplicates(p)
		return StzU(p)

	func StzUnique(p)
		return StzU(p)

	func Unique(p)
		return StzU(p)

	func @U(p)
		return StzU(p)

	func @WithoutDuplicates(p)
		return StzU(p)

	func @WithoutDupplicates(p)
		return StzU(p)

	func @Unique(p)
		return StzU(p)

	func StzUniqueItems(p)
		return StzU(p)

	func UniqueItems(p)
		return StzU(p)

	func @UniqueItems(p)
		return StzU(p)

	func UniqueItemsIn(p)
		return StzU(p)

	func @UniqueItemsIn(p)
		return StzU(p)

	func StzToSet(p)
		return StzU(p)

	func ToSet(p)
		return StzU(p)

	func @ToSet(p)
		return StzU(p)

#--

func StzL(p)

	if isList(p)
		return p

	but isString(p)

		aResult = []
		nLen = len(p)
		for i = 1 to nLen
			aResult + StzMid(p, i, 1)
		next
		return aResult

	but isObject(p)
		return StzObject(p).ObjectAttributesAndValues()

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + ""
		next

		return aResult

	else
		StzRaise("Incorrect param! Can't tranform param to list.")
	ok

	func L(p)
		return StzL(p)

	func StzLQ(p)
		return new stzList(StzL(p))

	func LQ(p)
		return StzLQ(p)

#---

func StzLN(p)

	if  IsPair(p) and
	    IsPair(p[1]) and IsPair(p[2]) and
	    isString(p[1][1]) and isString(p[2][1]) and
	    p[1][1] = :From and p[2][1] = :To and
	    isNumber(p[1][2]) and isNumber(p[2][2])

		return NumbersBetween(p[1][2], p[2][2])

	but isList(p)
		aResult = []
		nLen = len(p)
		for i = 1 to nLen
			if isNumber(p[i])
				aResult + p[i]
			ok
		next
		return aResult

	but isString(p) and StzQ(p).IsListInString()
		aResult = StzQ(p).ToListQ().OnlyNumbers()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + 0
		next
		return aResult
	ok

	func LN(p)
		return StzLN(p)

	func StzLNQ(p)
		return StzQ(StzLN(p))

	func LNQ(p)
		return StzLNQ(p)

	func QLN(p)
		return StzLNQ(p)

	func StzLoN(p)
		return StzLN(p)

	func LoN(p)
		return StzLN(p)

	func LoNQ(p)
		return StzLNQ(p)

#---

func StzLC(p)
	if isList(p)
		aResult = []
		nLen = len(p)
		for i = 1 to nLen
			if isString(p[i]) and len(p[i]) = 1
				aResult + p[i]
			ok
		next
		return aResult

	but isString(p) and StzQ(p).IsListInString()
		aResult = StzQ(p).ToListQ().OnlyChars()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + ""
		next
		return aResult

	ok

	func LC(p)
		return StzLC(p)

	func StzLCQ(p)
		return StzQ(StzLC(p))

	func LCQ(p)
		return StzLCQ(p)

	func QLC(p)
		return StzLCQ(p)

	func StzLoC(p)
		return StzLC(p)

	func LoC(p)
		return StzLC(p)

	func LoCQ(p)
		return StzLCQ(p)

#---

func StzLL(p)
	if isList(p)
		aResult = []
		nLen = len(p)
		for i = 1 to nLen
			if isList(p[i])
				aResult + p[i]
			ok
		next
		return aResult

	but isString(p) and StzQ(p).IsListInString()
		aResult = StzQ(p).ToListQ().OnlyLists()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + []
		next
		return aResult

	ok

	func LL(p)
		return StzLL(p)

	func StzLLQ(p)
		return StzQ(StzLL(p))

	func LLQ(p)
		return StzLLQ(p)

	func QLL(p)
		return StzLLQ(p)

	func StzLoL(p)
		return StzLL(p)

	func LoL(p)
		return StzLL(p)

	func LoLQ(p)
		return StzLLQ(p)

#---

func StzLS(p)
	if isList(p)
		aResult = []
		nLen = len(p)
		for i = 1 to nLen
			if isString(p[i])
				aResult + p[i]
			ok
		next
		return aResult

	but isString(p) and StzQ(p).IsListInString()
		aResult = StzQ(p).ToListQ().OnlyStrings()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + ""
		next
		return aResult

	ok

	func LS(p)
		return StzLS(p)

	func StzLSQ(p)
		return StzQ(StzLS(p))

	func LSQ(p)
		return StzLSQ(p)

	func QLS(p)
		return StzLSQ(p)

	func StzLoS(p)
		return StzLS(p)

	func LoS(p)
		return StzLS(p)

	func LoSQ(p)
		return StzLSQ(p)

#---

func StzWhere(cCode)
	if NOT isString(cCode)
		StzRaise("Incorrect param type! cCode must be a string.")
	ok

	aResult = [:Where, cCode]
	return aResult

	func W(cCode)
		return StzWhere(cCode)

	func Where(cCode)
		return StzWhere(cCode)

func StzWhereXT(cCode)
	if NOT isString(cCode)
		StzRaise("Incorrect param type! cCode must be a string.")
	ok

	aResult = [:WhereXT, cCode]
	return aResult

	func WXT(cCode)
		return StzWhereXT(cCode)

	func WhereXT(cCode)
		return StzWhereXT(cCode)

# Global Join() function. Mirrors stzList.Join() but works on raw
# Ring lists too -- callers like stzCCode use it on intermediate
# substring arrays without wrapping them first.

func Join(paList)
	if NOT isList(paList)
		StzRaise("Join: paList must be a list")
	ok
	cJoined = ""
	nLen = len(paList)
	for i = 1 to nLen
		if isString(paList[i])
			cJoined += paList[i]
		but isNumber(paList[i])
			cJoined += "" + paList[i]
		ok
	next
	return cJoined

# Global StzSubStr() -- thin alias for Ring's substr() with the
# (str, start, length) signature. Used by stzRegex.PartialMatchInfo
# and other engine-result formatters that build substring extracts
# from raw byte positions.

# Global stopwords status. The full stopwords feature lives in
# libraries/stzlib/max/string/stxStringStopWords.ring (extended
# layer); the simple status flag itself is base-layer territory so
# narrative tests in the base/test corpus can flip it without
# pulling in `max`.

_cStopWordsStatus = :MustNotBeRemoved

func StopWordsMustBeRemoved()
	_cStopWordsStatus = :MustBeRemoved

	func StopWordsMustNotBeRemoved()
		_cStopWordsStatus = :MustNotBeRemoved

func StopWordsStatus()
	return _cStopWordsStatus

func StzSubStr(cStr, nStart, nLen)
	if NOT isString(cStr)
		StzRaise("StzSubStr: cStr must be a string")
	ok
	if NOT (isNumber(nStart) and isNumber(nLen))
		StzRaise("StzSubStr: nStart and nLen must be numbers")
	ok
	if nLen <= 0 or nStart < 1
		return ""
	ok
	return substr(cStr, nStart, nLen)

	func JoinXT(paList, pcSep)
		if NOT isList(paList)
			StzRaise("JoinXT: paList must be a list")
		ok
		if NOT isString(pcSep)
			StzRaise("JoinXT: pcSep must be a string")
		ok
		cJoinedSep = ""
		nLn = len(paList)
		for i = 1 to nLn
			if isString(paList[i])
				cJoinedSep += paList[i]
			but isNumber(paList[i])
				cJoinedSep += "" + paList[i]
			ok
			if i < nLn
				cJoinedSep += pcSep
			ok
		next
		return cJoinedSep

# CenterText: pad cText so it occupies nWidth visible columns, with
# the text centered (extra space biased to the right when nWidth is
# even and the remainder is odd). Used by the pivot-table-show
# row-rendering helper.
func CenterText(cText, nWidth)
	if NOT (isString(cText) and isNumber(nWidth)) return cText ok
	if nWidth < 1 return "" ok
	nLen = len(cText)
	if nLen >= nWidth
		return left(cText, nWidth)
	ok
	nLeft = floor((nWidth - nLen) / 2)
	nRight = nWidth - nLen - nLeft
	cOut = ""
	for i = 1 to nLeft
		cOut += " "
	next
	cOut += cText
	for i = 1 to nRight
		cOut += " "
	next
	return cOut
