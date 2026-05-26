# Stub functions needed by stzString
# This file also handles portable DLL discovery so test files
# don't need hardcoded absolute paths.

$aStzLibConfig = []

# --- Auto-load DLLs at load time ---
# Ring compiles functions first, so _stzFindDll() is callable here.
$cStzStringLib = _stzFindDll("stz_string.dll")
if $cStzStringLib != ""
	$pStzStringHandle = LoadLib($cStzStringLib)
else
	? "WARNING: stz_string.dll not found! Engine functions will fail."
ok

$cStzUnicodeLib = _stzFindDll("stz_unicode.dll")
if $cStzUnicodeLib != ""
	$pStzUnicodeHandle = LoadLib($cStzUnicodeLib)
else
	? "WARNING: stz_unicode.dll not found! Unicode engine functions will fail."
ok

# --- DLL Discovery ---
# Searches upward from currentdir() for the engine DLL.
# Works regardless of where the test is run from, as long as
# the working directory is somewhere inside the stzlib tree.

func _stzFindDll(cDllName)
	cDir = currentdir()
	# Normalize to forward slashes
	nLen = len(cDir)
	cNorm = ""
	for i = 1 to nLen
		if cDir[i] = "\"
			cNorm += "/"
		else
			cNorm += cDir[i]
		ok
	next
	cDir = cNorm

	# Try up to 10 parent levels
	for depth = 1 to 10
		cTry = cDir + "/engine/zig-out/bin/" + cDllName
		if fexists(cTry)
			return cTry
		ok
		# Also try with backslashes (Windows)
		cTryWin = ""
		for k = 1 to len(cTry)
			if cTry[k] = "/"
				cTryWin += "\"
			else
				cTryWin += cTry[k]
			ok
		next
		if fexists(cTryWin)
			return cTryWin
		ok
		# Go up one level
		nLast = 0
		for j = len(cDir) to 1 step -1
			if cDir[j] = "/"
				nLast = j
				exit
			ok
		next
		if nLast < 2
			exit
		ok
		cDir = left(cDir, nLast - 1)
	next
	return ""

func _SplitNullDelimited(cJoined)
	if cJoined = ""
		return []
	ok
	acResult = []
	cCurrent = ""
	nLen = len(cJoined)
	for i = 1 to nLen
		c = substr(cJoined, i, 1)
		if ascii(c) = 0
			if cCurrent != ""
				acResult + cCurrent
				cCurrent = ""
			ok
		else
			cCurrent += c
		ok
	next
	if cCurrent != ""
		acResult + cCurrent
	ok
	return acResult

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
		return StzCaseFold(str1) = StzCaseFold(str2)
	ok

func BothStringsAreEqual(str1, str2)
	return BothStringsAreEqualCS(str1, str2, 1)

func Q(p)
	if isString(p)
		return new stzString(p)
	ok
	return p

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
	return StzReplace(cStr, cOld, cNew)

func ring_find(p, pItem)
	return StzFind(p, pItem)

func StzReplace(cStr, cOld, cNew)
	pH = StzEngineString(cStr)
	StzEngineStringReplace(pH, cOld, cNew)
	cResult = StzEngineStringData(pH)
	StzEngineStringFree(pH)
	return cResult

func StzFind(p, pItem)
	if isString(p)
		pH = StzEngineString(p)
		nPos = StzEngineStringFindNth(pH, pItem, 1)
		StzEngineStringFree(pH)
		if nPos < 0
			return 0
		ok
		return nPos
	ok
	if isList(p)
		for i = 1 to len(p)
			if p[i] = pItem
				return i
			ok
		next
		return 0
	ok
	return 0

func isDigit(c)
	if NOT isString(c) return 0 ok
	if len(c) != 1 return 0 ok
	n = ascii(c)
	return n >= 48 and n <= 57

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

func split(cStr, cSep)
	return @split(cStr, cSep)

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
		return substr(StzCaseFold(pcStr), StzCaseFold(pcSubStr)) > 0
	ok

func IsOneOfTheseNamedParamsList(p, paNames)
	if NOT isList(p) return 0 ok
	if len(p) != 2 return 0 ok
	if NOT isString(p[1]) return 0 ok
	cName = StzCaseFold(p[1])
	for cN in paNames
		if StzCaseFold(cN) = cName
			return 1
		ok
	next
	return 0

NL = char(10)

# --- Unicode-aware wrapper functions (engine-backed, simple API) ---

func StzUpper(cStr)
	pH = StzEngineString(cStr)
	pR = StzEngineStringToUpper(pH)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

func StzLower(cStr)
	pH = StzEngineString(cStr)
	pR = StzEngineStringToLower(pH)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

func StzTitle(cStr)
	pH = StzEngineString(cStr)
	pR = StzEngineStringToTitle(pH)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

func StzCaseFold(cStr)
	return StzEngineUnicodeCaseFold(cStr)

func StzLen(cStr)
	if isList(cStr)
		return len(cStr)
	ok
	pH = StzEngineString(cStr)
	n = StzEngineStringCount(pH)
	StzEngineStringFree(pH)
	return n

func StzChar(nCodepoint)
	return StzEngineUnicodeEncode(nCodepoint)

func StzReverse(cStr)
	pH = StzEngineString(cStr)
	pR = StzEngineStringReverse(pH)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

func StzIsUpper(cStr)
	pH = StzEngineString(cStr)
	n = StzEngineStringIsUppercase(pH)
	StzEngineStringFree(pH)
	return n

func StzIsLower(cStr)
	pH = StzEngineString(cStr)
	n = StzEngineStringIsLowercase(pH)
	StzEngineStringFree(pH)
	return n

func StzIsAlpha(cStr)
	pH = StzEngineString(cStr)
	n = StzEngineStringIsAlpha(pH)
	StzEngineStringFree(pH)
	return n

func StzIsDigit(cStr)
	pH = StzEngineString(cStr)
	n = StzEngineStringIsDigit(pH)
	StzEngineStringFree(pH)
	return n

func StzLeft(cStr, n)
	pH = StzEngineString(cStr)
	pR = StzEngineStringLeft(pH, n)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

func StzRight(cStr, n)
	pH = StzEngineString(cStr)
	pR = StzEngineStringRight(pH, n)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

func StzMid(cStr, nStart, nLen)
	pH = StzEngineString(cStr)
	pR = StzEngineStringMid(pH, nStart - 1, nLen)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

func StzPadLeft(cStr, nWidth, cPadChar)
	nLen = len(cStr)
	for i = 1 to nWidth - nLen
		cStr = cPadChar + cStr
	next
	return cStr

func StzPadLeftXT(text, width, c)
	cStr = "" + text
	nLen = len(cStr)
	for i = 1 to width - nLen
		cStr = c + cStr
	next
	return cStr

func StzPadRight(cStr, nWidth, cPadChar)
	nLen = len(cStr)
	for i = 1 to nWidth - nLen
		cStr = cStr + cPadChar
	next
	return cStr

func StzPadRightXT(text, width, c)
	cStr = "" + text
	nLen = len(cStr)
	for i = 1 to width - nLen
		cStr = cStr + c
	next
	return cStr

class stzObject
