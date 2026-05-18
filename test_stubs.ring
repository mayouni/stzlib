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

class stzObject
