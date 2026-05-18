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

func ring_copy(cStr, n)
	cResult = ""
	for i = 1 to n
		cResult += cStr
	next
	return cResult

func ring_substr2(cStr, cOld, cNew)
	# Simple replace all occurrences
	cResult = cStr
	nOldLen = len(cOld)
	nNewLen = len(cNew)
	nPos = substr(cResult, cOld)
	while nPos > 0
		cLeft = ""
		if nPos > 1
			cLeft = left(cResult, nPos - 1)
		ok
		cRight = ""
		if nPos + nOldLen - 1 < len(cResult)
			cRight = substr(cResult, nPos + nOldLen, len(cResult) - nPos - nOldLen + 1)
		ok
		cResult = cLeft + cNew + cRight
		nPos = substr(cResult, cOld)
	end
	return cResult

func ring_find(cStr, cChar)
	return substr(cStr, cChar)

func ring_reverse(aList)
	return ListReversed(aList)

func @split(cStr, cSep)
	aResult = []
	cCurrent = ""
	nSepLen = len(cSep)
	i = 1
	nLen = len(cStr)
	while i <= nLen
		if i + nSepLen - 1 <= nLen and substr(cStr, i, nSepLen) = cSep
			aResult + cCurrent
			cCurrent = ""
			i += nSepLen
		else
			cCurrent += substr(cStr, i, 1)
			i++
		ok
	end
	aResult + cCurrent
	return aResult

func @SplitCS(cStr, cSep, pCS)
	return @split(cStr, cSep)

func @ReplaceCS(cStr, cOld, cNew, pCS)
	return ring_substr2(cStr, cOld, cNew)

func @trim(cStr)
	return ring_trim(cStr)

func strcmp(s1, s2)
	n1 = len(s1)
	n2 = len(s2)
	nMin = n1
	if n2 < nMin nMin = n2 ok
	for i = 1 to nMin
		a1 = ascii(s1[i])
		a2 = ascii(s2[i])
		if a1 < a2 return -1 ok
		if a1 > a2 return 1 ok
	next
	if n1 < n2 return -1 ok
	if n1 > n2 return 1 ok
	return 0

func StringContainsCS(pcStr, pcSubStr, pCaseSensitive)
	bCase = @CaseSensitive(pCaseSensitive)
	if bCase
		return substr(pcStr, pcSubStr) > 0
	else
		return substr(lower(pcStr), lower(pcSubStr)) > 0
	ok

func IsOneOfTheseNamedParamsList(p, paNames)
	if NOT isList(p) return 0 ok
	if len(p) != 2 return 0 ok
	if NOT isString(p[1]) return 0 ok
	cName = lower(p[1])
	for cN in paNames
		if lower(cN) = cName
			return 1
		ok
	next
	return 0

NL = char(10)

class stzObject
