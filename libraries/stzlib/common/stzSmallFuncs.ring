

# Returns the softanza object related to the type of p
func Q(p)

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


	func The(p)
		return Q(p)

	func TheQ(p)
		return Q(p)

func QH(p)
	#TODO // Review the code of all functions where loops are used
	# on the main object and modify it many times

	#~> // Use a copy on which the loop is used and then update
	# the main object in on UpdateWith() call

	SetKeepingHistoryTo(_TRUE_)
	_aHisto + p

	return Q(p)

	return QHHV(p) # tracing only the value (V)
		return QHH(p)

func QHH(p)
	SetKeepingTimeTo(_TRUE_)
	SetKeepingHistoryToXT(_TRUE_, :VTMS)

	return Q(p)

	func QHHVTMS(p) # Tracing Value, Type, Time and Size
		return QHH(p)

func QHHVT(p) # Tracing Value and Type
	SetKeepingTimeTo(_TRUE_)
	SetKeepingHistoryToXT(_TRUE_, :VT)

	return Q(p)

func QHHVM(p) # Tacing Value and Time
	SetKeepingTimeTo(_TRUE_)
	SetKeepingHistoryToXT(_TRUE_, :VM)

	return Q(p)

func QHHVS(p) # Tracing Value and Size
	SetKeepingTimeTo(_TRUE_)
	SetKeepingHistoryToXT(_TRUE_, :VS)

	return Q(p)

func QHHTM(p) # Tracing Type and Time
	SetKeepingTimeTo(_TRUE_)
	SetKeepingHistoryToXT(_TRUE_, :TM)

	return Q(p)

func QHHTS(p) # Tacing Type and Size
	SetKeepingTimeTo(_TRUE_)
	SetKeepingHistoryToXT(_TRUE_, :TS)

	return Q(p)

func QHHMS(p) # Tracing Time and Size
	SetKeepingTimeTo(_TRUE_)
	SetKeepingHistoryToXT(_TRUE_, :MS)

	return Q(p)

func QHHVTM(p) # Tracing Value, Type nad Time
	SetKeepingTimeTo(_TRUE_)
	SetKeepingHistoryToXT(_TRUE_, :TM)

	return Q(p)

func QHHVTS(p) # Tracing Value, Type and Size
	SetKeepingTimeTo(_TRUE_)
	SetKeepingHistoryToXT(_TRUE_, :VTS)

	return Q(p)

func QHHTMS(p) # Tracing Type, Time and Size
	SetKeepingTimeTo(_TRUE_)
	SetKeepingHistoryToXT(_TRUE_, :TMS)

	return Q(p)

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
			ReplaceCSQ("@Method", "@Item", _FALSE_).
			Content()
	
	aResult = QR(aTempList, :stzListOfStrings).StringsW(ccondition)

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

#--

func QM(p)
	obj = Q(p)
	SetMainObject(obj)
	return obj

func QR(p, pcType)
	if NOT isString(pcType)
		StzRaise("Invalid param type! pcType should be a string containing the name of a softanza class.")
	ok

	if Q(pcType).IsStzClassName()
		cCode = "oResult = new " + pcType + '(' + @@(p) + ')'

		eval(cCode)

		return oResult
	else
		StzRaise("Unsupported Softanza type!")
	ok

# This function tries its best to infere a convenient type
# by analysing a value hosted in a string

func QQ(p)

	/* EXAMPLE 1

	? QQ("19")		# stzNumber
	#--> Note that this is a number in string:
	? Q("19").IsNumberInString() #--> _TRUE_

	EXAMPLE 2

	? QQ("[1, 2, 3]")	#--> stzListOfNumbers
	#--> Note that this is a list in string:
	? Q("[1, 2, 3]").IsListOfNumbersInString() #--> _TRUE_

	EXAMPLE 3

	? QQ(' [ "one", "two", "three" ] ')	#--> stzListOfStrings
	#--> Note that this is a list of strings in a string:
	? Q(' [ "one", "two", "three" ] ').IsListOfStringsInString #--> _TRUE_

	*/

	if isString(p)

		oParam = Q(p)

		if oParam.IsNumberInString()
			return new stzNumber(p)

		but oParam.IsListInString() #TODO // check Q(' "A" : "C" ').IsListInString()
			return new stzList(p)
			#TODO // check new stzList("[1, 2, 3]")

		but oParam.IsChar() or oParam.IsHexUnicode()
			return new stzChar(p)

		else
			return new stzString(p)

		ok

	but isList(p)

		oQTemp = Q(p)

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
		return Q(p)
	ok

#---

func N(p)
	if isNumber(p)
		return p

	but isString(p)

		oParam = Q(p)

		if oParam.IsNumberInString()
			return 0+ p

		but oParam.IsListInString()
			return len( Q(p).ToList() )

		else
			return Q(p).NumberOfChars()
		ok

	but isList(p)
		return len(p)

	but isObject(p)
		return len( Q(p).ObjectAttributes() )
	ok

	func NQ(p)
		return new stzNumber( N(p) )

		func QN(p)
			return NQ(p)

#---

func S(p)
	if isString(p)
		return p

	but isNumber(p)
		return ""+ p

	but isList(p)
		return Q(p).ToCode()

	but isObject(p)
		return LQ(p).ToCode()
	ok

	func SQ(p)
		return Q( S(p) )

		func QS(p)
			return SQ(p)


#---

func U(p)
	/* EXAMPLE

	? U([ "♥", 1, 2, 2, "♥", "♥", 3 ]) # Or Unique() or WithoutDuplicates()
	#--> [ "♥", 1, 2, 3 ]
	
	*/

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type!")
		ok
	ok

	result = StzListQ(p).WithoutDuplicates()
	return result

	func WithoutDuplicates(p)
		return U(p)

	func WithoutDupplicates(p)
		return U(p)

	func Unique(p)
		return U(p)

	func @U(p)
		return U(p)

	func @WithoutDuplicates(p)
		return U(p)

	func @WithoutDupplicates(p)
		return U(p)

	func @Unique(p)
		return U(p)

	func UniqueItems(p)
		return U(p)

	func @UniqueItems(p)
		return U(p)

	func UniqueItemsIn(p)
		return U(p)

	func @UniqueItemsIn(p)
		return U(p)

	func ToSet(p)
		return U(p)

	func @ToSet(p)
		return U(p)

#--

func L(p)

	if isList(p)
		return p

	but isString(p)

		return StzStringQ(p).ToList()

	but isObject(p)
		return StzObject(p).ObjectAttributesAndValues()

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + _NULL_
		next

		return aResult

	else
		StzRaise("Incorrect param! Can't tranform param to list.")
	ok

	func LQ(p)
		return new stzList(L(p))

#---

func LN(p)

	if  IsPair(p) and
	    IsPair(p[1]) and IsPair(p[2]) and
	    isString(p[1][1]) and isString(p[2][1]) and
	    p[1][1] = :From and p[2][1] = :To and
	    isNumber(p[1][2]) and isNumber(p[2][2])

		return NumbersBetween(p[1][2], p[2][2])

	but isList(p)
		return StzListQ(p).OnlyNumbers()

	but isString(p) and Q(p).IsListInString()
		aResult = Q(p).ToListQ().OnlyNumbers()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + 0
		next
		return aResult
	ok

	func LNQ(p)
		return Q(LN(p))

		func QLN(p)
			return LNQ(p)

	func LoN(p)
		return LN(p)

		func LoNQ(p)
			return LNQ(p)

#---

func LC(p)
	if isList(p)
		return StzListQ(p).OnlyChars()

	but isString(p) and Q(p).IsListInString()
		aResult = Q(p).ToListQ().OnlyChars()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + ""
		next
		return aResult

	ok

	func LCQ(p)
		return Q(LC(p))

		func QLC(p)
			return LCQ(p)

	func LoC(p)
		return LC(p)

		func LoCQ(p)
			return LCQ(p)

#---

func LL(p)
	if isList(p)
		return StzListQ(p).OnlyLists()

	but isString(p) and Q(p).IsListInString()
		aResult = Q(p).ToListQ().OnlyLists()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + []
		next
		return aResult

	ok

	func LLQ(p)
		return Q(LL(p))

		func QLL(p)
			return LLQ(p)

	func LoL(p)
		return LL(p)

		func LoLQ(p)
			return LLQ(p)

#---

func LS(p)
	if isList(p)
		return StzListQ(p).OnlyStrings()

	but isString(p) and Q(p).IsListInString()
		aResult = Q(p).ToListQ().OnlyStrings()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + ""
		next
		return aResult

	ok

	func LSQ(p)
		return Q(LS(p))

		func QLS(p)
			return LSQ(p)

	func LoS(p)
		return LS(p)

		func LoSQ(p)
			return LSQ(p)

#---

func W(cCode)
	if NOT isString(cCode)
		StzRaise("Incorrect param type! cCode must be a string.")
	ok

	aResult = [:Where, cCode]
	return aResult

	func Where(cCode)
		return W(cCode)

func WXT(cCode)
	if NOT isString(cCode)
		StzRaise("Incorrect param type! cCode must be a string.")
	ok

	aResult = [:WhereXT, cCode]
	return aResult

	func WhereXT(cCode)
		return WXT(cCode)
