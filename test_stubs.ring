# Stub functions needed by stzString
$aStzLibConfig = []

func CheckingParams()
	return 0

func CheckParams()
	return 0

func StzRaise(cMsg)
	? "ERROR: " + cMsg

func @CaseSensitive(p)
	if isList(p) and len(p) = 2 and isString(p[1])
		return p[2]
	ok
	return p

func IsWithOrByOrUsingNamedParamList(p)
	return 0

func IsPairOfStrings(p)
	return isList(p) and len(p) = 2 and isString(p[1]) and isString(p[2])

func @TraceObjectHistory(obj)
	return

func @IsListOfStrings(lst)
	nLen = len(lst)
	for i = 1 to nLen
		if NOT isString(lst[i])
			return 0
		ok
	next
	return 1

func IsListOfNumbers(lst)
	nLen = len(lst)
	for i = 1 to nLen
		if NOT isNumber(lst[i])
			return 0
		ok
	next
	return 1

func IsListOfStrings(lst)
	return @IsListOfStrings(lst)

func IsOfNamedParamList(p)
	return 0

func IsCaseSensitiveNamedParamList(p)
	return 0

func @BothAreNumbers(a, b)
	return isNumber(a) and isNumber(b)

func @BothAreStrings(a, b)
	return isString(a) and isString(b)

func @IsNumberOrString(p)
	return isNumber(p) or isString(p)

func @IsNumberOrChar(p)
	return isNumber(p) or (isString(p) and len(p) = 1)

func ring_sort(aList)
	# Simple bubble sort for small lists
	nLen = len(aList)
	for i = 1 to nLen - 1
		for j = 1 to nLen - i
			if aList[j] > aList[j+1]
				temp = aList[j]
				aList[j] = aList[j+1]
				aList[j+1] = temp
			ok
		next
	next
	return aList

func U(aList)
	# Unique: remove duplicates
	aResult = []
	for item in aList
		bFound = 0
		for existing in aResult
			if existing = item
				bFound = 1
				exit
			ok
		next
		if bFound = 0
			aResult + item
		ok
	next
	return aResult

func BothStringsAreEqualCS(str1, str2, pCaseSensitive)
	_bCase_ = @CaseSensitive(pCaseSensitive)
	if _bCase_
		return str1 = str2
	else
		return lower(str1) = lower(str2)
	ok

func BothStringsAreEqual(str1, str2)
	return BothStringsAreEqualCS(str1, str2, 1)

func StzStringQ(cStr)
	return new stzString(cStr)

func ListReversed(aList)
	aResult = []
	for i = len(aList) to 1 step -1
		aResult + aList[i]
	next
	return aResult

func IsAndNamedParamList(p)
	return 0

func ring_trim(cStr)
	return ring_ltrim(ring_rtrim(cStr))

func ring_ltrim(cStr)
	nLen = len(cStr)
	nStart = 1
	for i = 1 to nLen
		if cStr[i] = " " or cStr[i] = char(9) or cStr[i] = char(10) or cStr[i] = char(13)
			nStart = i + 1
		else
			exit
		ok
	next
	if nStart > nLen
		return ""
	ok
	return substr(cStr, nStart, nLen - nStart + 1)

func ring_rtrim(cStr)
	nLen = len(cStr)
	nEnd = nLen
	for i = nLen to 1 step -1
		if cStr[i] = " " or cStr[i] = char(9) or cStr[i] = char(10) or cStr[i] = char(13)
			nEnd = i - 1
		else
			exit
		ok
	next
	if nEnd < 1
		return ""
	ok
	return substr(cStr, 1, nEnd)

class stzObject
