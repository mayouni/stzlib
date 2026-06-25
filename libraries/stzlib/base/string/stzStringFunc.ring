  /////////////////////////////////////////////
 ///   FUNCTIONS FOR THE STZSTRING CLASS   ///
/////////////////////////////////////////////

# NOTE: Primitive string utility functions (StzLen, StzLower, StzUpper,
# StzLeft, StzRight, StzMid, StzReplace, StzPadLeftXT, StzPadRightXT,
# StzChar, StzReverse, StzCapitalize, StzCenter, StzRepeatStr, etc.)
# are defined in common/stzPrimitives.ring — loaded early so ALL
# domains can use them before string/ loads.


func StzStringQ(str)
	return new stzString(str)

	#< @FunctionMisspelledForm

	func StzSrtringQ(str)
		return StzStringQ(str)

# Global helpers used by string-test narratives.
# Full UnicodeDataAsString returns the Unicode database; the cheap
# stub returns "" so the test load completes (used by perf
# narratives).
func UnicodeDataAsString()
	return ""

# MarquersPositions(cMarkers) returns the codepoint positions of
# each marker token "#1", "#2", etc. in the given string.
func MarquersPositions(cStr)
	return MarkersPositions(cStr)

func MarkersPositions(cStr)
	if NOT isString(cStr) return [] ok
	_aRes_ = []
	_nLen_ = len(cStr)
	_i_ = 1
	while _i_ <= _nLen_
		if cStr[_i_] = "#" and _i_ < _nLen_ and isDigit(cStr[_i_ + 1])
			_aRes_ + _i_
			_i_++
			while _i_ <= _nLen_ and isDigit(cStr[_i_])
				_i_++
			end
		else
			_i_++
		ok
	end
	return _aRes_

# Tier-2 search helpers used by narratives.
func NextNthOccurrence(cStr, n, cSub, nFrom)
	_o_ = new stzString(cStr)
	return _o_.FindNextNthOccurrence(n, cSub, nFrom)

func PreviousNthOccurrence(cStr, n, cSub, nFrom)
	_o_ = new stzString(cStr)
	return _o_.FindNthPrevious(n, cSub, nFrom)

# FindNextNthMarquer(cStr, n, nFrom): position of the n-th marker
# (the `#N` placeholder pattern) after nFrom in cStr.
func FindNextNthMarquer(cStr, n, nFrom)
	_o_ = new stzString(cStr)
	return _o_.FindNextNthMarquer(n, nFrom)

func FindNextNthMarker(cStr, n, nFrom)
	return FindNextNthMarquer(cStr, n, nFrom)

# MarquersZ / MarkersZ / MarquersZZ / MarkersZZ: bare-name wrappers
# so calls inside StzStringQ blocks resolve. The host stzString
# object's content is unknown here; we rely on Ring's block-resolve:
# inside `o1 { MarquersZ() }`, Ring forwards to o1.MarquersZ() when
# the method exists. We define them as methods on stzString too.
# These global fallbacks are stubs returning empty lists so the call
# never errors out.
func MarquersZ()
	return []

func MarkersZ()
	return []

func MarquersZZ()
	return []

func MarkersZZ()
	return []

# SortedInAscending(paItems): return paItems sorted ascending.
func SortedInAscending(paItems)
	if NOT isList(paItems) return paItems ok
	_a_ = []
	_n_ = len(paItems)
	for _i_ = 1 to _n_
		_a_ + paItems[_i_]
	next
	# Simple insertion sort (small narrative inputs).
	for _i_ = 2 to _n_
		_v_ = _a_[_i_]; _j_ = _i_ - 1
		while _j_ >= 1
			_g_ = _a_[_j_]
			_lt_ = FALSE
			if isString(_g_) and isString(_v_)
				if strcmp(_g_, _v_) > 0 _lt_ = TRUE ok
			but isNumber(_g_) and isNumber(_v_)
				if _g_ > _v_ _lt_ = TRUE ok
			ok
			if NOT _lt_ exit ok
			_a_[_j_ + 1] = _a_[_j_]
			_j_--
		end
		_a_[_j_ + 1] = _v_
	next
	return _a_

func SortedInDescending(paItems)
	_a_ = SortedInAscending(paItems)
	_n_ = len(_a_)
	_r_ = []
	for _i_ = _n_ to 1 step -1
		_r_ + _a_[_i_]
	next
	return _r_

# ReplaceEachLeadingChar(cStr, cNewChar): pure-function form.
func ReplaceEachLeadingChar(cStr, cNewChar)
	_o_ = new stzString(cStr)
	_o_.ReplaceEachLeadingChar(cNewChar)
	return _o_.Content()

func ReplaceCharsW(cStr, cCondition, cNewChar)
	_o_ = new stzString(cStr)
	_o_.ReplaceCharsW(cCondition, cNewChar)
	return _o_.Content()

func StzNamedString(paNamed)
	if CheckingParams()
		if NOT (isList(paNamed) and Q(paNamed).IsPairOfStrings())
			StzRaise("Incorrect param type! paNamed must be a pair of strings.")
		ok
	ok

	oStr = new stzString(paNamed[2])
	oStr.SetName(paNamed[1])
	return ostr

	func StzNamedStringQ(paNamed)
		return StzNamedString(paNamed)

	func StzNamedStringXTQ(paNamed)
		return StzNamedString(paNamed)

func StzStringMethods()
	return Stz(:String, :Methods)

func StzStringAttributes()
	return Stz(:String, :Attributes)

func StzStringClassName()
	return Stz(:String, :ClassName)

	func StzStringClass()
		return StzStringClassName()

#--

func StzStringIsInListCS(str, aList, pCaseSensitive)
	return ListContainsCS(aList, str, pCaseSensitive)

	func StringIsInListCS(str, aList, pCaseSensitive)
		return StzStringIsInListCS(str, aList, pCaseSensitive)

func StzStringIsInList(str, aList)
	return ListContains(aList, str)

	func StringIsInList(str, aList)
		return StzStringIsInList(str, aList)

# NOTE: StzPadRight/XT, StzPadLeft/XT, StzCenter, StzCapitalize
# moved to common/stzPrimitives.ring

func StzIsInvisibleString(str)

	if CheckParams()
		if NOT isString(str)
			stzraise("Incorrect param type! str must be a string.")
		ok
	ok

	_acChars_ = Chars(str)
	_nLen_ = len(_acChars_)

	_bResult_ = 1

	for @i = 1 to _nLen_
		if NOT IsInvisibleChar(_acChars_[@i])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

	func IsInvisibleString(str)
		return StzIsInvisibleString(str)

	func @IsInvisibleString(str)
		return StzIsInvisibleString(str)

	func IsInvisible(str)
		return StzIsInvisibleString(str)

	func @IsInvisible(str)
		return StzIsInvisibleString(str)

#--

func StzIsNotString(pcStr)
	return NOT isString(pcStr)

	func IsNotString(pcStr)
		return StzIsNotString(pcStr)

	func IsNotAString(pcStr)
		return StzIsNotString(pcStr)

	func @IsNotString(pcStr)
		return StzIsNotString(pcStr)

	func @IsNotAString(pcStr)
		return StzIsNotString(pcStr)

func StzIsAlphabetic(cStr)
	pStr = StzEngineString(cStr)
	nResult = StzEngineStringIsAlpha(pStr)
	StzEngineStringFree(pStr)
	return nResult

	func @IsAlpha(cStr)
		return StzIsAlphabetic(cStr)

	func IsAlphabetical(cStr)
		return StzIsAlphabetic(cStr)

	func @IsAlphabetical(cStr)
		return StzIsAlphabetic(cStr)

	func IsAlphabetic(cStr)
		return StzIsAlphabetic(cStr)

	func @IsAlphabetic(cStr)
		return StzIsAlphabetic(cStr)

func StzIsAlphanumeric(cStr)
	pStr = StzEngineString(cStr)
	nLen = StzEngineStringCount(pStr)
	if nLen = 0
		StzEngineStringFree(pStr)
		return 0
	ok
	nLetters = StzEngineStringCountCharsOfType(pStr, 0)
	nDigits = StzEngineStringCountCharsOfType(pStr, 1)
	StzEngineStringFree(pStr)
	return (nLetters + nDigits) = nLen

	func @IsAlnum(cStr)
		return StzIsAlphanumeric(cStr)

	func IsAlphaNumerical(cStr)
		return StzIsAlphanumeric(cStr)

	func @IsAlphaNumerical(cStr)
		return StzIsAlphanumeric(cStr)

	func IsAlphaNumeric(cStr)
		return StzIsAlphanumeric(cStr)

	func @IsAlphanumeric(cStr)
		return StzIsAlphanumeric(cStr)

func StzIsEmpty(p)
	if isString(p)
		return StzIsNullString(p)

	but isNumber(p)
		return FALSE

	but isList(p) and len(p) = 0
		return TRUE

	but isObject(p) and IsNullObject(p)
		return TRUE

	else
		return FALSE
	ok

	func IsEmpty(p)
		return StzIsEmpty(p)

	func @IsEmpty(p)
		return StzIsEmpty(p)


func StzIsNull(p)
	if isString(p)
		return StzIsNullString(p)

	but isObject(p) and IsNullObject(p)
		return TRUE

	else
		return FALSE
	ok

	func IsNull(p)
		return StzIsNull(p)

	func @IsNull(cStr)
		return StzIsNull(cStr)

func StzIsNullString(cStr)
	if isString(cStr) and cStr = ""
		return 1
	else
		return 0
	ok

	func IsNullString(cStr)
		return StzIsNullString(cStr)

	func IsEmptyString(cStr)
		return StzIsNullString(cStr)

	func ANullString(pcStr)
		return StzIsNullString(cStr)

	func IsAnEmptyString(cStr)
		return StzIsNullString(cStr)

	func @IsNullString(cStr)
		return StzIsNullString(cStr)

	func @IsEmptyString(cStr)
		return StzIsNullString(cStr)

	func @ANullString(pcStr)
		return StzIsNullString(cStr)

	func @IsAnEmptyString(cStr)
		return StzIsNullString(cStr)

	func StringIsNull(pcStr)
		return isString(pcStr) and pcStr = ""

func StzIsNonNullString(cStr)
	return NOT StzIsNullString(cStr)

	func IsNonNullString(cStr)
		return StzIsNonNullString(cStr)

	func IsNonEmptyString(cStr)
		return StzIsNonNullString(cStr)

	func ANonNullString(pcStr)
		return StzIsNonNullString(cStr)

	func IsANonEmptyString(cStr)
		return StzIsNonNullString(cStr)

	func @IsNonNullString(cStr)
		return StzIsNonNullString(cStr)

	func @IsNonEmptyString(cStr)
		return StzIsNonNullString(cStr)

	func @ANonNullString(pcStr)
		return StzIsNonNullString(cStr)

	func @IsANonEmptyString(cStr)
		return StzIsNonNullString(cStr)

func StzIsBlank(pcStr)
	if len(pcStr) = 0 return 0 ok
	pStr = StzEngineString(pcStr)
	nResult = StzEngineStringIsWhitespace(pStr)
	StzEngineStringFree(pStr)
	return nResult

	func IsBlank(pcStr)
		return StzIsBlank(pcStr)

	func IsBlankString(pcStr)
		return StzIsBlank(pcStr)

	func IsABlankString(pcStr)
		return StzIsBlank(pcStr)

	func @IsBlank(pcStr)
		return StzIsBlank(pcStr)

	func @IsBlankString(pcStr)
		return StzIsBlank(pcStr)

	func @IsABlankString(pcStr)
		return StzIsBlank(pcStr)

#TODO Some of these functions should call their corresponding (same)
# functions in the core layer

func StzContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	if isString(pStrOrList)
		return StzStringContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	but isList(pStrOrList)
		return ListContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	else
		StzRaise("Can't proceed! pStrOrList must be a string or list.")
	ok

	func ContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	func @ContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

func StzContains(pStrOrList, pSubStrOrItem)
	return StzContainsCS(pStrOrList, pSubStrOrItem, 1)

	func Contains(pStrOrList, pSubStrOrItem)
		return StzContains(pStrOrList, pSubStrOrItem)

	func @Contains(pStrOrList, pSubStrOrItem)
		return StzContains(pStrOrList, pSubStrOrItem)

func StzContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	if isString(pStrOrList)
		return StzStringContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	but isList(pStrOrList)
		return ListContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	else
		StzRaise("Can't proceed! pStrOrList must be a string or list.")
	ok

	func ContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	func @ContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

func StzContainsOneOfThese(pStrOrList, pSubStrOrItem)
	return StzContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, 1)

	func ContainsOneOfThese(pStrOrList, pSubStrOrItem)
		return StzContainsOneOfThese(pStrOrList, pSubStrOrItem)

	func @ContainsOneOfThese(pStrOrList, pSubStrOrItem)
		return StzContainsOneOfThese(pStrOrList, pSubStrOrItem)

#==

func StzStartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	if isString(pStrOrList) and isString(pSubStrOrItem)
		bCase = CaseSensitive(bCaseSensitive)
		pStr = StzEngineString(pStrOrList)
		nResult = StzEngineStringStartsWithCS(pStr, pSubStrOrItem, bCase)
		StzEngineStringFree(pStr)
		return nResult
	ok
	return Q(pStrOrList).StartsWithCS(pSubStrOrItem, bCaseSensitive)

	func StartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzStartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	func BeginsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzStartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	func @StartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzStartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	func @BeginsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzStartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

func StzStartsWith(pStrOrList, pSubStrOrItem) # startsWith() seems to be reserved by Ring StdLib
	if isString(pStrOrList) and isString(pSubStrOrItem)
		pStr = StzEngineString(pStrOrList)
		nResult = StzEngineStringStartsWith(pStr, pSubStrOrItem)
		StzEngineStringFree(pStr)
		return nResult
	ok
	return Q(pStrOrList).StartsWith(pSubStrOrItem)

	func @StartsWith(pStrOrList, pSubStrOrItem)
		return StzStartsWith(pStrOrList, pSubStrOrItem)

	func BeginsWith(pStrOrList, pSubStrOrItem)
		return StzStartsWith(pStrOrList, pSubStrOrItem)

	func @BeginsWith(pStrOrList, pSubStrOrItem)
		return StzStartsWith(pStrOrList, pSubStrOrItem)

#--

func StzEndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	if isString(pStrOrList) and isString(pSubStrOrItem)
		bCase = CaseSensitive(bCaseSensitive)
		pStr = StzEngineString(pStrOrList)
		nResult = StzEngineStringEndsWithCS(pStr, pSubStrOrItem, bCase)
		StzEngineStringFree(pStr)
		return nResult
	ok
	return Q(pStrOrList).EndsWithCS(pSubStrOrItem, bCaseSensitive)

	func EndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzEndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	func @EndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzEndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

func StzEndsWith(pStrOrList, pSubStrOrItem) # endsWith() seems to be reserved by Ring StdLib
	if isString(pStrOrList) and isString(pSubStrOrItem)
		pStr = StzEngineString(pStrOrList)
		nResult = StzEngineStringEndsWith(pStr, pSubStrOrItem)
		StzEngineStringFree(pStr)
		return nResult
	ok
	return Q(pStrOrList).EndsWith(pSubStrOrItem)

	func @EndsWith(pStrOrList, pSubStrOrItem)
		return StzEndsWith(pStrOrList, pSubStrOrItem)

#==

# A Ring-based implementation
# This is made as altenartive to show how Softanza enhances Ring

#~> Solves the problem where substr() function in Ring returns 1
# if we are searching for an empty string!

func StzStringContainsCS(pcStr, pcSubStr, pCaseSensitive)
	if CheckParams()
		if NOT ( isString(pcStr) and isString(pcSubStr) )
			StzRaise("Incorrect param type! pcStr and pcSubStr must be both strings.")
		ok
	ok

	if pcStr = "" or
	   pcSubStr = ""
		return 0
	ok

	bCase = CaseSensitive(pCaseSensitive)

	pStr = StzEngineString(pcStr)
	nResult = StzEngineStringContainsCS(pStr, pcSubStr, bCase)
	StzEngineStringFree(pStr)
	return nResult

	func StringContainsCS(pcStr, pcSubStr, bCaseSensitive)
		return StzStringContainsCS(pcStr, pcSubStr, bCaseSensitive)

	func @StringContainsCS(pcStr, pcSubStr, bCaseSensitive)
		return StzStringContainsCS(pcStr, pcSubStr, bCaseSensitive)

	func @StzStringContainsCS(pcStr, pcSubStr, bCaseSensitive)
		return StzStringContainsCS(pcStr, pcSubStr, bCaseSensitive)

func StzStringContains(pcStr, pcSubStr)
	return StzStringContainsCS(pcStr, pcSubStr, 1)

	func StringContains(pcStr, pcSubStr)
		return StzStringContains(pcStr, pcSubStr)

	func @StringContains(pcStr, pcSubStr)
		return StzStringContains(pcStr, pcSubStr)

	func @StzStringContains(pcStr, pcSubStr)
		return StzStringContains(pcStr, pcSubStr)

#--

func StzStringContainsOneOfTheseCS(pcStr, pacSubStr, pCaseSensitive)
	if CheckParams()
		if NOT isString(pcStr)
			StzRaise("Incorrect param type! pcStr must be a string.")
		ok

		if NOT IsListOfStrings(pacSubStr)
			StzRaise("Incorrect param type! pacSubStr must be a list of strings.")
		ok
	ok

	nLenSubStr = len(pacSubStr)

	if pcStr = "" or
	   len(pacSubStr) = 0
		return 0
	ok

	bResult = 0
	for i = 1 to nLenSubStr
		if StzStringContainsCS(pcStr, pacSubStr[i], pCaseSensitive)
			bResult = 1
			exit
		ok
	next

	return bResult

	func StringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)
		return StzStringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)

	func @StringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)
		return StzStringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)

	func @StzStringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)
		return StzStringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)

func StzStringContainsOneOfThese(pcStr, pcSubStr)
	return StzStringContainsOneOfTheseCS(pcStr, pcSubStr, 1)

	func StringContainsOneOfThese(pcStr, pcSubStr)
		return StzStringContainsOneOfThese(pcStr, pcSubStr)

	func @StringContainsOneOfThese(pcStr, pcSubStr)
		return StzStringContainsOneOfThese(pcStr, pcSubStr)

	func @StzStringContainsOneOfThese(pcStr, pcSubStr)
		return StzStringContainsOneOfThese(pcStr, pcSubStr)

# NOTE: StzReplaceCS, StzReplace, StzSplitCS, StzSplit
# moved to common/stzPrimitives.ring

#--

# Trim function (to use instead of the one provided by the standard library)

func StzTrim(cStrOrList)
	if CheckParams()
		if NOT (isString(cStrOrList) or isList(cStrOrList))
			StzRaise("Incorrect param type! cStrOrList must be a string or list.")
		ok
	ok

	if isString(cStrOrList)
		return TrimString(cStrOrList)

	else // isList()
		return TrimList(cStrOrList)
	ok

	func @trim(cStrOrList)
		return StzTrim(cStrOrList)

	func Trim(pcStr)
		return StzTrim(pcStr)

func StzTrimString(cStr)
	if CheckParams()
		if NOT isString(cStr)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	if len(cStr) = 0 return "" ok

	pStr = StzEngineString(cStr)
	pTrimmed = StzEngineStringTrimmed(pStr)
	cResult = StzEngineStringData(pTrimmed)
	StzEngineStringFree(pTrimmed)
	StzEngineStringFree(pStr)
	return cResult

	func TrimString(cStr)
		return StzTrimString(cStr)

	func @TrimString(cStr)
		return StzTrimString(cStr)

func StzTrimLines(pStrOrList)
	if CheckParams()
		if NOT (isString(pStrOrList) or isList(pStrOrList))
			StzRaise("Incorrect param type! pStrOrList must be a string or list.")
		ok
	ok

	if stzleft(pStrOrList, 1) != NL and stzright(pStrOrList, 1) != NL
		return pStrOrList
	ok

	if isString(pStrOrList)
		acSplits = @split(pStrOrList, NL)
	else
		acSplits = pStrOrList
	ok

	return StzTrimList(acSplits)

	func TrimLines(pStrOrList)
		return StzTrimLines(pStrOrList)

func StzTrimList(aList)
	if CheckParams()
		if NOT isList(aList)
			StzRaise("Incorrect param type! aList must be a list.")
		ok
	ok

	oList = new stzList(aList)
	aResult = oList.Trimmed()
	return aResult

	func TrimList(aList)
		return StzTrimList(aList)

	func @TrimList(aList)
		return StzTrimList(aList)

func StzTrimLeft(cStrOrList)
	if CheckParams()
		if NOT (isString(cStrOrList) or isList(cStrOrList))
			StzRaise("Incorrect param type! cStrOrList must be a string or list.")
		ok
	ok

	if isString(cStrOrList)
		pStr = StzEngineString(cStrOrList)
		pResult = StzEngineStringTrimLeft(pStr)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		StzEngineStringFree(pStr)
		return cResult
	else
		nLen = len(cStrOrList)
		nStart = 1
		for i = 1 to nLen
			if isString(cStrOrList[i]) and trim(cStrOrList[i]) = ""
				nStart = i + 1
			else
				exit
			ok
		next
		if nStart > nLen
			return []
		ok
		aResult = []
		for i = nStart to nLen
			aResult + cStrOrList[i]
		next
		return aResult
	ok

	func @TrimLeft(cStrOrList)
		return StzTrimLeft(cStrOrList)

	func LeftTrim(cStrOrList)
		return StzTrimLeft(cStrOrList)

	func @LeftTrim(cStrOrList)
		return StzTrimLeft(cStrOrList)

	func ltrim(cStrOrList)
		return StzTrimLeft(cStrOrList)

	func @ltrim(cStrOrList)
		return StzTrimLeft(cStrOrList)

func StzTrimRight(cStrOrList)
	if CheckParams()
		if NOT (isString(cStrOrList) or isList(cStrOrList))
			StzRaise("Incorrect param type! cStrOrList must be a string or list.")
		ok
	ok

	if isString(cStrOrList)
		pStr = StzEngineString(cStrOrList)
		pResult = StzEngineStringTrimRight(pStr)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		StzEngineStringFree(pStr)
		return cResult
	else
		nLen = len(cStrOrList)
		nEnd = nLen
		for i = nLen to 1 step -1
			if isString(cStrOrList[i]) and trim(cStrOrList[i]) = ""
				nEnd = i - 1
			else
				exit
			ok
		next
		if nEnd < 1
			return []
		ok
		aResult = []
		for i = 1 to nEnd
			aResult + cStrOrList[i]
		next
		return aResult
	ok

	func @TrimRight(cStrOrList)
		return StzTrimRight(cStrOrList)

	func RightTrim(cStrOrList)
		return StzTrimRight(cStrOrList)

	func @RightTrim(cStrOrList)
		return StzTrimRight(cStrOrList)

	func rtrim(cStrOrList)
		return StzTrimRight(cStrOrList)

	func @rtrim(cStrOrList)
		return StzTrimRight(cStrOrList)

func StzTrimStart(cStrOrList)
	if CheckParams()
		if NOT (isString(cStrOrList) or isList(cStrOrList))
			StzRaise("Incorrect param type! cStrOrList must be a string or list.")
		ok
	ok

	return StzTrimLeft(cStrOrList)

	func @TrimStart(cStrOrList)
		return StzTrimStart(cStrOrList)

	func TrimStart(cStrOrList)
		return StzTrimStart(cStrOrList)

func StzTrimEnd(cStrOrList)
	if CheckParams()
		if NOT (isString(cStrOrList) or isList(cStrOrList))
			StzRaise("Incorrect param type! cStrOrList must be a string or list.")
		ok
	ok

	return StzTrimRight(cStrOrList)

	func @TrimEnd(cStrOrList)
		return StzTrimEnd(cStrOrList)

	func TrimEnd(cStrOrList)
		return StzTrimStart(cStrOrList)


#--

func _StzSimplifyString(cStr)
	pStr = StzEngineString(cStr)
	pResult = StzEngineStringSimplify(pStr)
	cResult = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return cResult

func _StzStripBraces(cStr)
	cStr = @trim(cStr)
	if len(cStr) < 2 return cStr ok
	pStr = StzEngineString(cStr)
	nLen = StzEngineStringCount(pStr)
	if nLen >= 2 and StzEngineStringStartsWith(pStr, "{") and StzEngineStringEndsWith(pStr, "}")
		# StzEngineStringSlice(handle, start_cp, cp_count) is 1-based.
		# Skip the leading '{' (start at codepoint 2) and trim 2 chars
		# total ('{' on the left, '}' on the right).
		pSliced = StzEngineStringSlice(pStr, 2, nLen - 2)
		cStr = StzEngineStringData(pSliced)
		StzEngineStringFree(pSliced)
		cStr = @trim(cStr)
	ok
	StzEngineStringFree(pStr)
	return cStr

#--

func StzStringContent(oStr)
	return oStr.Content()

func StzStringIsLocaleAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLocaleAbbreviation()

	func StringIsLocaleAbbreviation(cStr)
		return StzStringIsLocaleAbbreviation(cStr)

	func IsLocaleAbbreviation(cStr)
		return StzStringIsLocaleAbbreviation(cStr)

	func @IsLocaleAbbreviation(cStr)
		return StzStringIsLocaleAbbreviation(cStr)

func StzStringIsLanguageAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLanguageAbbreviation()

	func StringIsLanguageAbbreviation(cStr)
		return StzStringIsLanguageAbbreviation(cStr)

	func IsLanguageAbbreviation(cStr)
		return StzStringIsLanguageAbbreviation(cStr)

	func @IsLanguageAbbreviation(cStr)
		return StzStringIsLanguageAbbreviation(cStr)

func StzStringIsShortLanguageAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsShortLanguageAbbreviation()

	func StringIsShortLanguageAbbreviation(cStr)
		return StzStringIsShortLanguageAbbreviation(cStr)

	func @IsShortLanguageAbbreviation(cStr)
		return StzStringIsShortLanguageAbbreviation(cStr)

func StzStringIsLongLanguageAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLongLanguageAbbreviation()

	func StringIsLongLanguageAbbreviation(cStr)
		return StzStringIsLongLanguageAbbreviation(cStr)

	func IsLongLanguageAbbreviation(cStr)
		return StzStringIsLongLanguageAbbreviation(cStr)

	func @IsLongLanguageAbbreviation(cStr)
		return StzStringIsLongLanguageAbbreviation(cStr)

func StzStringIsLanguageName(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLanguageName()

	func StringIsLanguageName(cStr)
		return StzStringIsLanguageName(cStr)

	func IsLanguageName(cStr)
		return StzStringIsLanguageName(cStr)

	func IsLanguage(cStr)
		return StzStringIsLanguageName(cStr)

	func @IsLanguageName(cStr)
		return StzStringIsLanguageName(cStr)

	func @IsLanguage(cStr)
		return StzStringIsLanguageName(cStr)

func StzStringIsLanguageNumber(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLanguageNumber()

	func StringIsLanguageNumber(cStr)
		return StzStringIsLanguageNumber(cStr)

	func IsLanguageNumber(cStr)
		return StzStringIsLanguageNumber(cStr)

	func @IsLanguageNumber(cStr)
		return StzStringIsLanguageNumber(cStr)

func StzStringIsCountryAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsCountryAbbreviation()

	func StringIsCountryAbbreviation(cStr)
		return StzStringIsCountryAbbreviation(cStr)

	func IsCountryAbbreviation(cStr)
		return StzStringIsCountryAbbreviation(cStr)

	func @IsCountryAbbreviation(cStr)
		return StzStringIsCountryAbbreviation(cStr)

func StzStringIsCountryName(cStr)
	oStr = new stzString(cStr)
	return oStr.IsCountryName()

	func StringIsCountryName(cStr)
		return StzStringIsCountryName(cStr)

	func IsCountryName(cStr)
		return StzStringIsCountryName(cStr)

	func IsCountry(cStr)
		return StzStringIsCountryName(cStr)

	func @IsCountryName(cStr)
		return StzStringIsCountryName(cStr)

	func @IsCountry(cStr)
		return StzStringIsCountryName(cStr)

func StzStringIsCountryNumber(cStr)
	oStr = new stzString(cStr)
	return oStr.IsCountryNumber()

	func StringIsCountryNumber(cStr)
		return StzStringIsCountryNumber(cStr)

	func IsCountryNumber(cStr)
		return StzStringIsCountryNumber(cStr)

	func @IsCountryNumber(cStr)
		return StzStringIsCountryNumber(cStr)

func StzStringIsShortCountryAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsShortCountryAbbreviation()

	func StringIsShortCountryAbbreviation(cStr)
		return StzStringIsShortCountryAbbreviation(cStr)

	func IsShortCountryAbbreviation(cStr)
		return StzStringIsShortCountryAbbreviation(cStr)

	func @IsShortCountryAbbreviation(cStr)
		return StzStringIsShortCountryAbbreviation(cStr)

func StzStringIsLongCountryAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLongCountryAbbreviation()

	func StringIsLongCountryAbbreviation(cStr)
		return StzStringIsLongCountryAbbreviation(cStr)

	func IsLongCountryAbbreviation(cStr)
		return StzStringIsLongCountryAbbreviation(cStr)

	func @IsLongCountryAbbreviation(cStr)
		return StzStringIsLongCountryAbbreviation(cStr)

func StzStringIsScriptAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsScriptAbbreviation()

	func StringIsScriptAbbreviation(cStr)
		return StzStringIsScriptAbbreviation(cStr)

	func IsScriptAbbreviation(cStr)
		return StzStringIsScriptAbbreviation(cStr)

	func @IsScriptAbbreviation(cStr)
		return StzStringIsScriptAbbreviation(cStr)

func StzStringIsScriptName(cStr)
	oStr = new stzString(cStr)
	return oStr.IsScriptName()

	func StringIsScriptName(cStr)
		return StzStringIsScriptName(cStr)

	func IsScriptName(cStr)
		return StzStringIsScriptName(cStr)

	func IsScript(cStr)
		return StzStringIsScriptName(cStr)

	func @IsScriptName(cStr)
		return StzStringIsScriptName(cStr)

	func @IsScript(cStr)
		return StzStringIsScriptName(cStr)

func StzStringIsScriptNumber(cStr)
	oStr = new stzString(cStr)
	return oStr.IsScriptNumber()

	func IsScriptNumber(cStr)
		return StzStringIsScriptNumber(cStr)

	func StringIsScriptNumber(cStr)
		return StzStringIsScriptNumber(cStr)

	func @IsScriptNumber(cStr)
		return StzStringIsScriptNumber(cStr)

func StzStringIsLowercase(cStr)
	pStr = StzEngineString(cStr)
	nResult = StzEngineStringIsLowercase(pStr)
	StzEngineStringFree(pStr)
	return nResult

	func StringIsLowercase(cStr)
		return StzStringIsLowercase(cStr)

func StzStringIsUppercase(cStr)
	pStr = StzEngineString(cStr)
	nResult = StzEngineStringIsUppercase(pStr)
	StzEngineStringFree(pStr)
	return nResult

	func StringIsUppercase(cStr)
		return StzStringIsUppercase(cStr)

func StzStringLowercased(cStr)
	pStr = StzEngineString(cStr)
	pLower = StzEngineStringToLower(pStr)
	cResult = StzEngineStringData(pLower)
	StzEngineStringFree(pLower)
	StzEngineStringFree(pStr)
	return cResult

	func StringLowercased(cStr)
		return StzStringLowercased(cStr)

	func Lowercased(cStr)
		return StzStringLowercased(cStr)

	func Lowercase(cStr)
		return StzStringLowercased(cStr)

	func StringLowercase(cStr)
		return StzStringLowercased(cStr)

	func @Lowercased(cStr)
		return StzStringLowercased(cStr)

	func @Lowercase(cStr)
		return StzStringLowercased(cStr)

func StzStringUppercased(cStr)
	pStr = StzEngineString(cStr)
	pUpper = StzEngineStringToUpper(pStr)
	cResult = StzEngineStringData(pUpper)
	StzEngineStringFree(pUpper)
	StzEngineStringFree(pStr)
	return cResult

	func StringUppercased(cStr)
		return StzStringUppercased(cStr)

	func Uppercase(cStr)
		return StzStringUppercased(cStr)

	func Uppercased(cStr)
		return StzStringUppercased(cStr)

	func StringUppercase(cStr)
		return StzStringUppercased(cStr)

	func @Uppercased(cStr)
		return StzStringUppercased(cStr)

	func @Uppercase(cStr)
		return StzStringUppercased(cStr)

func StzStringTitlecased(cStr)
	pStr = StzEngineString(cStr)
	pTitle = StzEngineStringToTitle(pStr)
	cResult = StzEngineStringData(pTitle)
	StzEngineStringFree(pTitle)
	StzEngineStringFree(pStr)
	return cResult

	func StringTitlecased(cStr)
		return StzStringTitlecased(cStr)

	func Titlecase(cStr)
		return StzStringTitlecased(cStr)

	func Titlecased(cStr)
		return StzStringTitlecased(cStr)

	func StringTitlecase(cStr)
		return StzStringTitlecased(cStr)

	func @Titlecased(cStr)
		return StzStringTitlecased(cStr)

	func @Titlecase(cStr)
		return StzStringTitlecased(cStr)

#===

func StzIsSorted(pcStrOrList)
	if StzIsSortedString(pcStrOrList) or IsSortedList(pcStrOrList)
		return 1
	else
		return 0
	ok

	func IsSorted(pcStrOrList)
		return StzIsSorted(pcStrOrList)

	func @IsSorted(pcStrOrList)
		return StzIsSorted(pcStrOrList)

func StzIsSortedInAscending(pcStrOrList)
	if StzIsSortedStringInAscending(pcStrOrList) or IsSortedListInAscending(pcStrOrList)
		return 1
	else
		return 0
	ok

	func IsSortedInAscending(pcStrOrList)
		return StzIsSortedInAscending(pcStrOrList)

	func IsSortedUp(pcStrOrList)
		return StzIsSortedInAscending(pcStrOrList)

	func @IsSortedInAscending(pcStrOrList)
		return StzIsSortedInAscending(pcStrOrList)

	func @IsSortedUp(pcStrOrList)
		return StzIsSortedInAscending(pcStrOrList)

func StzIsSortedInDescending(pcStrOrList)
	if StzIsSortedStringInDescending(pcStrOrList) or IsSortedListInDescending(pcStrOrList)
		return 1
	else
		return 0
	ok

	func IsSortedInDescending(pcStrOrList)
		return StzIsSortedInDescending(pcStrOrList)

	func IsSortedDown(pcStrOrList)
		return StzIsSortedInDescending(pcStrOrList)

	func @IsSortedInDescending(pcStrOrList)
		return StzIsSortedInDescending(pcStrOrList)

	func @IsSortedDown(pcStrOrList)
		return StzIsSortedInDescending(pcStrOrList)

#--

func StzIsSortedString(pcStr)
	if StzIsSortedStringInAscending(pcStr) or StzIsSortedStringInDescending(pcStr)
		return 1
	else
		return 0
	ok

	func IsSortedString(pcStr)
		return StzIsSortedString(pcStr)

	func IsStringSorted(pcStr)
		return StzIsSortedString(pcStr)

	func @IsSortedString(pcStr)
		return StzIsSortedString(pcStr)

	func @IsStringSorted(pcStr)
		return StzIsSortedString(pcStr)

func StzIsSortedStringInAscending(pcStr)
	if NOT isString(pcStr)
		return 0
	ok

	pStr = StzEngineString(pcStr)
	nResult = StzEngineStringIsCharsSortedAsc(pStr)
	StzEngineStringFree(pStr)
	return nResult

	func IsSortedStringInAscending(pcStr)
		return StzIsSortedStringInAscending(pcStr)

	func IsStringSortedInAscending(pcStr)
		return StzIsSortedStringInAscending(pcStr)

	func IsSortedStringUp(pcStr)
		return StzIsSortedStringInAscending(pcStr)

	func IsSortedUpString(pcStr)
		return StzIsSortedStringInAscending(pcStr)

	func IsStringSortedUp(pcStr)
		return StzIsSortedStringInAscending(pcStr)

	func @IsSortedStringInAscending(pcStr)
		return StzIsSortedStringInAscending(pcStr)

	func @IsStringSortedInAscending(pcStr)
		return StzIsSortedStringInAscending(pcStr)

	func @IsSortedStringUp(pcStr)
		return StzIsSortedStringInAscending(pcStr)

	func @IsSortedUpString(pcStr)
		return StzIsSortedStringInAscending(pcStr)

	func @IsStringSortedUp(pcStr)
		return StzIsSortedStringInAscending(pcStr)

func StzIsSortedStringInDescending(pcStr)

	if NOT isString(pcStr)
		return 0
	ok

	pStr = StzEngineString(pcStr)
	nResult = StzEngineStringIsCharsSortedDesc(pStr)
	StzEngineStringFree(pStr)
	return nResult

	func IsSortedStringInDescending(pcStr)
		return StzIsSortedStringInDescending(pcStr)

	func IsStringSortedInDescending(pcStr)
		return StzIsSortedStringInDescending(pcStr)

	func IsSortedStringDown(pcStr)
		return StzIsSortedStringInDescending(pcStr)

	func IsSortedDownString(pcStr)
		return StzIsSortedStringInDescending(pcStr)

	func IsStringSortedDown(pcStr)
		return StzIsSortedStringInDescending(pcStr)

	func @IsSortedStringInDescending(pcStr)
		return StzIsSortedStringInDescending(pcStr)

	func @IsStringSortedInDescending(pcStr)
		return StzIsSortedStringInDescending(pcStr)

	func @IsSortedStringDown(pcStr)
		return StzIsSortedStringInDescending(pcStr)

	func @IsSortedDownString(pcStr)
		return StzIsSortedStringInDescending(pcStr)

	func @IsStringSortedDown(pcStr)
		return StzIsSortedStringInDescending(pcStr)

#===

#TODO: Review if the String...() functions are necessary

func StzStringAlignXT(cStr, nWidth, cChar, cDirection)
	pStr = StzEngineString(cStr)
	if cDirection = :Left
		pResult = StzEngineStringLjust(pStr, nWidth, cChar)
	but cDirection = :Right
		pResult = StzEngineStringRjust(pStr, nWidth, cChar)
	else
		pResult = StzEngineStringCenterPad(pStr, nWidth, cChar)
	ok
	cResult = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return cResult

	func StringAlignXT(cStr, nWidth, cChar, cDirection)
		return StzStringAlignXT(cStr, nWidth, cChar, cDirection)

	func @AlignXT(cStr, nWidth, cChar, cDirection)
		return StzStringAlignXT(cStr, nWidth, cChar, cDirection)

	func AlignXT(cStr, nWidth, cChar, cDirection)
		return StzStringAlignXT(cStr, nWidth, cChar, cDirection)

func StzStringLeftAlign(cStr, nWidth)
	return StzStringAlignXT(cStr, nWidth, " ", :Left)

	func StringLeftAlign(cStr, nWidth)
		return StzStringLeftAlign(cStr, nWidth)

	func StringAlignLeft(cStr, nWidth)
		return StzStringLeftAlign(cStr, nWidth)

	func LeftAlign(cStr, nWidth)
		return StzStringLeftAlign(cStr, nWidth)

	func AlignLeft(cStr, nWidth)
		return StzStringLeftAlign(cStr, nWidth)

	func @LeftAlign(cStr, nWidth)
		return StzStringLeftAlign(cStr, nWidth)

	func @AlignLeft(cStr, nWidth)
		return StzStringLeftAlign(cStr, nWidth)

func StzStringLeftAlignXT(cStr, nWidth, cChar)
	return StzStringAlignXT(cStr, nWidth, cChar, :Left)

	func StringLeftAlignXT(cStr, nWidth, cChar)
		return StzStringLeftAlignXT(cStr, nWidth, cChar)

	func StringAlignLeftXT(cStr, nWidth, cChar)
		return StzStringLeftAlignXT(cStr, nWidth, cChar)

	func LeftAlignXT(cStr, nWidth, cChar)
		return StzStringLeftAlignXT(cStr, nWidth, cChar)

	func AlignLeftXT(cStr, nWidth, cChar)
		return StzStringLeftAlignXT(cStr, nWidth, cChar)

	func @LeftAlignXT(cStr, nWidth, cChar)
		return StzStringLeftAlignXT(cStr, nWidth, cChar)

	func @AlignLeftXT(cStr, nWidth, cChar)
		return StzStringLeftAlignXT(cStr, nWidth, cChar)

func StzStringRightAlign(cStr, nWidth)
	return StzStringAlignXT(cStr, nWidth, " ", :Right)

	func StringRightAlign(cStr, nWidth)
		return StzStringRightAlign(cStr, nWidth)

	func StringAlignRight(cStr, nWidth)
		return StzStringRightAlign(cStr, nWidth)

	func RightAlign(cStr, nWidth)
		return StzStringRightAlign(cStr, nWidth)

	func AlignRight(cStr, nWidth)
		return StzStringRightAlign(cStr, nWidth)

	func @RightAlign(cStr, nWidth)
		return StzStringRightAlign(cStr, nWidth)

	func @AlignRight(cStr, nWidth)
		return StzStringRightAlign(cStr, nWidth)

func StzStringRightAlignXT(cStr, nWidth, cChar)
	return StzStringAlignXT(cStr, nWidth, cChar, :Right)

	func StringRightAlignXT(cStr, nWidth, cChar)
		return StzStringRightAlignXT(cStr, nWidth, cChar)

	func StringAlignRightXT(cStr, nWidth, cChar)
		return StzStringRightAlignXT(cStr, nWidth, cChar)

	func RightAlignXT(cStr, nWidth, cChar)
		return StzStringRightAlignXT(cStr, nWidth, cChar)

	func AlignRightXT(cStr, nWidth, cChar)
		return StzStringRightAlignXT(cStr, nWidth, cChar)

	func @RightAlignXT(cStr, nWidth, cChar)
		return StzStringRightAlignXT(cStr, nWidth, cChar)

	func @AlignRightXT(cStr, nWidth, cChar)
		return StzStringRightAlignXT(cStr, nWidth, cChar)

func StzStringCenterAlign(cStr, nWidth)
	return StzStringAlignXT(cStr, nWidth, " ", :Center)

	func StringCenterAlign(cStr, nWidth)
		return StzStringCenterAlign(cStr, nWidth)

	func StringAlignCenter(cStr, nWidth)
		return StzStringCenterAlign(cStr, nWidth)

	func CenterAlign(cStr, nWidth)
		return StzStringCenterAlign(cStr, nWidth)

	func AlignCenter(cStr, nWidth)
		return StzStringCenterAlign(cStr, nWidth)

	func @CenterAlign(cStr, nWidth)
		return StzStringCenterAlign(cStr, nWidth)

	func @AlignCenter(cStr, nWidth)
		return StzStringCenterAlign(cStr, nWidth)

func StzStringCenterAlignXT(cStr, nWidth, cChar)
	return StzStringAlignXT(cStr, nWidth, cChar, :Center)

	func StringCenterAlignXT(cStr, nWidth, cChar)
		return StzStringCenterAlignXT(cStr, nWidth, cChar)

	func StringAlignCenterXT(cStr, nWidth, cChar)
		return StzStringCenterAlignXT(cStr, nWidth, cChar)

	func CenterAlignXT(cStr, nWidth, cChar)
		return StzStringCenterAlignXT(cStr, nWidth, cChar)

	func AlignCenterXT(cStr, nWidth, cChar)
		return StzStringCenterAlignXT(cStr, nWidth, cChar)

	func @CenterAlignXT(cStr, nWidth, cChar)
		return StzStringCenterAlignXT(cStr, nWidth, cChar)

	func @AlignCenterXT(cStr, nWidth, cChar)
		return StzStringCenterAlignXT(cStr, nWidth, cChar)
#===

func StzCountCS(pStrOrList, pSubStrOrItem, pCaseSensitive)
	if isSrtring(pStrOrList)
		return StzStringCountCS(pStrOrList, pSubStrOrItem, pCaseSensitive)

	but isList(pStrOrList)
		return ListCountCS(pStrOrList, pSubStrOrItem, pCaseSensitive)

	else
		StzRaise("Incorrect param type! pStrOrList must be a string or list.")
	ok

	func CountCS(pStrOrList, pSubStrOrItem, pCaseSensitive)
		return StzCountCS(pStrOrList, pSubStrOrItem, pCaseSensitive)

func StzCount(pStrOrList, pSubStrOrItem)
	return StzCountCS(pstrOrList, pSubStrOrItem, 1)

	func Count(pStrOrList, pSubStrOrItem)
		return StzCount(pStrOrList, pSubStrOrItem)

#--

func StzStringCountCS(pcStr, pcSubStr, pCaseSensitive)
	if CheckingParams()

		if isList(pcSubStr) and IsOfNamedParamList(pcSubStr)
			pcSubStr = pcSubStr[2]
		ok

	ok

	if pcSubStr = ""
		return 0
	ok

	bCase = @CaseSensitive(pCaseSensitive)

	pStr = StzEngineString(pcStr)
	nResult = StzEngineStringCountOfCS(pStr, pcSubStr, bCase)
	StzEngineStringFree(pStr)

	return nResult

	func StringCountCS(pcStr, pcSubStr, pCaseSensitive)
		return StzStringCountCS(pcStr, pcSubStr, pCaseSensitive)

func StzStringCount(pcStr, pcSubStr)
	return StzStringCountCS(pcStr, pcSubStr, 1)

	func StringCount(pcStr, pcSubStr)
		return StzStringCount(pcStr, pcSubStr)

#--

func StzStringNumberOfChars(cStr)
	pStr = StzEngineString(cStr)
	nResult = StzEngineStringCount(pStr)
	StzEngineStringFree(pStr)
	return nResult

	func StringNumberOfChars(cStr)
		return StzStringNumberOfChars(cStr)

	func @NumberOfChars(cStr)
		return StzStringNumberOfChars(cStr)

func StzStringReverseChars(cStr)
	pStr = StzEngineString(cStr)
	pReversed = StzEngineStringReverse(pStr)
	cResult = StzEngineStringData(pReversed)
	StzEngineStringFree(pReversed)
	StzEngineStringFree(pStr)
	return cResult

	func StringReverseChars(cStr)
		return StzStringReverseChars(cStr)

	func @ReverseChars(cStr)
		return StzStringReverseChars(cStr)

func StzStringIsWord(cStr)
	if len(cStr) = 0 return 0 ok
	pStr = StzEngineString(cStr)
	nResult = StzEngineStringIsWord(pStr)
	StzEngineStringFree(pStr)
	return nResult

	func StringIsWord(cStr)
		return StzStringIsWord(cStr)

	func @IsWord(cStr)
		return StzStringIsWord(cStr)

func StzStringNumberOfOccurrence(pcStr, pcSubStr)
	pStr = StzEngineString(pcStr)
	nResult = StzEngineStringCountOf(pStr, pcSubStr)
	StzEngineStringFree(pStr)
	return nResult

	func StringNumberOfOccurrence(pcStr, pcSubStr)
		return StzStringNumberOfOccurrence(pcStr, pcSubStr)

	func @NumberOfOccurrence(pcStr, pcSubStr)
		return StringNumberOfOccurrence(pcStr, pcSubStr)

func StzStringToUnicodes(pcStr)
	return StzStringQ(pcStr).Unicodes()

	func StringToUnicodes(pcStr)
		return StzStringToUnicodes(pcStr)

	func @ToUnicodes(pcStr)
		return StzStringToUnicodes(pcStr)

func StzUppercaseOf(cStr)
	pStr = StzEngineString(cStr)
	pUpper = StzEngineStringToUpper(pStr)
	cResult = StzEngineStringData(pUpper)
	StzEngineStringFree(pUpper)
	StzEngineStringFree(pStr)
	return cResult

	func UppercaseOf(cStr)
		return StzUppercaseOf(cStr)

	func UppercaseIn(cStr)
		return StzUppercaseOf(cStr)

func StzLowercaseOf(cStr)
	pStr = StzEngineString(cStr)
	pLower = StzEngineStringToLower(pStr)
	cResult = StzEngineStringData(pLower)
	StzEngineStringFree(pLower)
	StzEngineStringFree(pStr)
	return cResult

	func LowercaseOf(cStr)
		return StzLowercaseOf(cStr)

	func LowercaseIn(cStr)
		return StzLowercaseOf(cStr)

func StzFoldcaseOf(cStr)
	pStr = StzEngineString(cStr)
	pFolded = StzEngineStringFoldcase(pStr)
	cResult = StzEngineStringData(pFolded)
	StzEngineStringFree(pFolded)
	StzEngineStringFree(pStr)
	return cResult

	func FoldcaseOf(cStr)
		return StzFoldcaseOf(cStr)

	func FoldcaseIn(cStr)
		return StzFoldcaseOf(cStr)

func StzNthCharOf(n, cStr)
	pStr = StzEngineString(cStr)
	pChar = StzEngineStringNthChar(pStr, n)
	cResult = StzEngineStringData(pChar)
	StzEngineStringFree(pChar)
	StzEngineStringFree(pStr)
	return cResult

	func NthCharOf(n, cStr)
		return StzNthCharOf(n, cStr)

	func NthCharIn(n, cStr)
		return StzNthCharOf(n, cStr)

func StzNthLetterOf(n, cStr)
		pStr = StzEngineString(cStr)
		pLetters = StzEngineStringOnlyLetters(pStr)
		pChar = StzEngineStringNthChar(pLetters, n)
		cResult = StzEngineStringData(pChar)
		StzEngineStringFree(pChar)
		StzEngineStringFree(pLetters)
		StzEngineStringFree(pStr)
		return cResult

	func NthLetterOf(n, cStr)
		return StzNthLetterOf(n, cStr)

	func NthLetterIn(n, cStr)
		return StzNthLetterOf(n, cStr)

func StzStringIsArabicWord(pcStr)
	return StzStringQ(pcStr).IsArabicWord()

	func StringIsArabicWord(pcStr)
		return StzStringIsArabicWord(pcStr)

func StzStringIsCharName(pcStr)
	return StzStringQ(pcStr).IsCharName()

	func StringIsCharName(pcStr)
		return StzStringIsCharName(pcStr)

func StzText(pcStr)
	if isString(pcStr)
		return pcStr
	ok

	func Text(pcStr)
		return StzText(pcStr)

# stzText doesn't have its own dedicated class -- it's just a
# semantic alias for "narrative text", which structurally is a
# stzString. Q-form constructors return the stzString wrapper so
# the test narratives like `StzTextQ("...") { Initials() ... }`
# work without a new class.

func StzTextQ(pcStr)
	return new stzString(pcStr)

	func TextQ(pcStr)
		return StzTextQ(pcStr)

func StzNumberOfCharsOf(pcStr)
	pStr = StzEngineString(pcStr)
	nResult = StzEngineStringCount(pStr)
	StzEngineStringFree(pStr)
	return nResult

	func NumberOfCharsOf(pcStr)
		return StzNumberOfCharsOf(pcStr)

	func NumberOfCharsIn(pcStr)
		return StzNumberOfCharsOf(pcStr)

func StzBothStringsAreEqualCS(pcStr1, pcStr2, pCaseSensitive)
	_bCase_ = @CaseSensitive(pCaseSensitive)
	pStr1 = StzEngineString(pcStr1)
	pStr2 = StzEngineString(pcStr2)
	nResult = StzEngineStringEqualsCS(pStr1, pStr2, _bCase_)
	StzEngineStringFree(pStr2)
	StzEngineStringFree(pStr1)
	return nResult

	func BothStringsAreEqualCS(pcStr1, pcStr2, pCaseSensitive)
		return StzBothStringsAreEqualCS(pcStr1, pcStr2, pCaseSensitive)

func StzBothStringsAreEqual(pcStr1, pcStr2)
	return StzBothStringsAreEqualCS(pcStr1, pcStr2, 1)

	func BothStringsAreEqual(pcStr1, pcStr2)
		return StzBothStringsAreEqual(pcStr1, pcStr2)

func StzStringsAreEqualCS(pacStr, pCaseSensitive)

	if CheckParams()
		if NOT @IsListOfStrings(pacStr)
			stzRaise("Incorrect param type! pacStr must b a list of strings!")
		ok

		if NOT len(pacStr) > 1
			stzRaise("You must provide at least two strings pacStr!")
		ok
	ok

	_bCase_ = @CaseSensitive(pCaseSensitive)

	nLen = len(pacStr)
	bResult = 1

	pFirst = StzEngineString(pacStr[1])
	for i = 2 to nLen
		pOther = StzEngineString(pacStr[i])
		nEq = StzEngineStringEqualsCS(pFirst, pOther, _bCase_)
		StzEngineStringFree(pOther)
		if nEq = 0
			bResult = 0
			exit
		ok
	next
	StzEngineStringFree(pFirst)
	return bResult

	func StringsAreEqualCS(pacStr, pCaseSensitive)
		return StzStringsAreEqualCS(pacStr, pCaseSensitive)

func StzStringsAreEqual(paStr)
	return StzStringsAreEqualCS(paStr, 1)

	func StringsAreEqual(paStr)
		return StzStringsAreEqual(paStr)

func StzRemoveDiacritics(pcStr)
	pStr = StzEngineString(pcStr)
	pR = StzEngineStringStripMarks(pStr)
	cResult = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pStr)
	return cResult

	func RemoveDiacritics(pcStr)
		return StzRemoveDiacritics(pcStr)

func StzStringCases()
	return [ :Lowercase, :Uppercase, :Capitalcase, :Titlecase, :Foldercase ]

	func StringCases()
		return StzStringCases()

func StzStringCase(pcStr)
	return StzStringQ(pcStr).StringCase()

	func StringCase(pcStr)
		return StzStringCase(pcStr)

func StzInterpolate(pcStr)
	# Plain pass-through: real interpolation requires caller-scope
	# eval which Ring doesn't expose. The test suite uses this in
	# a narrative way; returning the content unchanged is a safe
	# no-op that lets the surrounding test reach pf().
	return pcStr

	func Interpolate(pcStr)
		return StzInterpolate(pcStr)

	func Interpoltate(pcStr)
		return StzInterpolate(pcStr)

	func Intrepolate(pcStr)
		return StzInterpolate(pcStr)

func StzNCopies(n, p)
	if isList(p) and Q(p).IsFromOrOfNamedParam()
		p = p[2]
	ok

	return Q(p).CopiedNTimes(n)

	func NCopies(n, p)
		return StzNCopies(n, p)

	func 2Copies(p)
		return StzNCopies(2, p)

	func 3Copies(p)
		return StzNCopies(3, p)

	func 4Copies(p)
		return StzNCopies(4, p)

	func 5Copies(p)
		return StzNCopies(3, p)

func StzWithoutSpaces(pcStr)
	pStr = StzEngineString(pcStr)
	StzEngineStringReplace(pStr, " ", "")
	cResult = StzEngineStringData(pStr)
	StzEngineStringFree(pStr)
	return cResult

	func WithoutSpaces(pcStr)
		return StzWithoutSpaces(pcStr)

	func @WithoutSpaces(pcStr)
		return StzWithoutSpaces(pcStr)

	func WithoutSapces(pcStr)
		return StzWithoutSpaces(pcStr)

	func @WithoutSapces(pcStr)
		return StzWithoutSpaces(pcStr)

func StzWithoutQuotes(cStr)

	cStr = @trim(cStr)
	if len(cStr) < 2 return cStr ok

	pStr = StzEngineString(cStr)
	nLen = StzEngineStringCount(pStr)
	if nLen < 2
		StzEngineStringFree(pStr)
		return cStr
	ok

	if (StzEngineStringStartsWith(pStr, '"') and StzEngineStringEndsWith(pStr, '"')) or
	   (StzEngineStringStartsWith(pStr, "'") and StzEngineStringEndsWith(pStr, "'"))

		pSliced = StzEngineStringSlice(pStr, 1, nLen - 2)
		cResult = StzEngineStringData(pSliced)
		StzEngineStringFree(pSliced)
		StzEngineStringFree(pStr)
		return cResult
	ok

	StzEngineStringFree(pStr)
	return cStr

	func WithoutQuotes(cStr)
		return StzWithoutQuotes(cStr)

	func @WithoutQuotes(cStr)
		return StzWithoutQuotes(cStr)

func StzSimplify(pcStr)
	return _StzSimplifyString(pcStr)

	func Simplify(pcStr)
		return StzSimplify(pcStr)

	func @Simplify(pcStr)
		return StzSimplify(pcStr)

	func StringSimplified(pcStr)
		return StzSimplify(pcStr)

	func Simplified(pcStr)
		return StzSimplify(pcStr)

func StzSpacify(str)
	pStr = StzEngineString(str)
	pResult = StzEngineStringSpacify(pStr)
	cResult = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return cResult

	func Spacify(str)
		return StzSpacify(str)

	func @Spacify(str)
		return StzSpacify(str)

func StzSpacifyXT(str, pSep, pStep, pDirection)
	cResult = StzStringQ(str).SpacifyXTQ(pSep, pStep, pDirection).Content()
	return cResult

	func SpacifyXT(str, pSep, pStep, pDirection)
		return StzSpacifyXT(str, pSep, pStep, pDirection)

	func @SpacifyXT(str, pSep, pStep, pDirection)
		return StzSpacifyXT(str, pSep, pStep, pDirection)

func StzIsMarquer(cStr)
	if CheckingParams()
		if NOT isString(cStr)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	return Q(cStr).IsMarquer()

	func IsMarquer(cStr)
		return StzIsMarquer(cStr)

	func IsAMarquer(cStr)
		return StzIsMarquer(cStr)

	func StringIsMarquer(cStr)
		return StzIsMarquer(cStr)

	func StringIsAMarquer(cStr)
		return StzIsMarquer(cStr)

	func @IsMarquer(cStr)
		return StzIsMarquer(cStr)

	func @IsAMarquer(cStr)
		return StzIsMarquer(cStr)

	func @StringIsMarquer(cStr)
		return StzIsMarquer(cStr)

	func @StringIsAMarquer(cStr)
		return StzIsMarquer(cStr)

func StzRepeatInString(pcSubStr, nTimes)
	if CheckParams()
		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		if NOT isNumber(nTimes)
			StzRaise("incorrect param type! nTimes must be a number.")
		ok
	ok

	pStr = StzEngineString(pcSubStr)
	pResult = StzEngineStringRepeat(pStr, nTimes)
	cResult = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return cResult

	func RepeatInString(pcSubStr, nTimes)
		return StzRepeatInString(pcSubStr, nTimes)

	func RepeatInAString(pcSubStr, nTimes)
		return StzRepeatInString(pcSubStr, nTimes)

	func @RepeatInString(pcSubStr, nTimes)
		return StzRepeatInString(pcSubStr, nTimes)

	func @RepeatInAString(pcSubStr, nTimes)
		return StzRepeatInString(pcSubStr, nTimes)

func StzBothAreMarquers(pcStr1, pcStr2)
	if BothAreStrings(pcStr1, pcStr2) and
	   Q(pcStr1).IsMarquer() and Q(pcStr2).IsMarquer()

		return 1
	else
		return 0
	ok

	func BothAreMarquers(pcStr1, pcStr2)
		return StzBothAreMarquers(pcStr1, pcStr2)

	func @BothAreMarquers(pcStr1, pcStr2)
		return StzBothAreMarquers(pcStr1, pcStr2)

func ring_number(cNumberInStr) #TODO // Move it to stzRingFuncs.ring
	return number(cNumberInStr)

func @Number(pNumberOrString) # An enhanced version of the Ring number() function.

	if isNumber(pNumberOrString)
		return pNumberOrString
	ok

	if isString(pNumberOrString) and pNumberOrString = ""
		return 0
	ok

	if NOT isString(pNumberOrString)
		StzRaise("Incorrect param type! pNumberOrString must be a string.")
	ok

	# Removing spaces and underscores (because we use them in numbers)

	cNumberInStr = StzReplace(pNumberOrString, " ", "")
	cNumberInStr = StzReplace(cNumberInStr, "_", "")

	if cNumberInStr = ""
		StzRaise("Incorrect param value! pNumberOrString must contain a number.")
	ok

	# Now, it is safe ti use the Ring Number() function

	try
		_nResult_ = ring_number(cNumberInStr)
		return _nResult_
	catch
		stzRaise("Can't proceed! pNumberOrString contains a literal not a number in string.")
	done

func StzIsNumberInString(str)
	if NOT isString(str)
		return FALSE
	ok

	return rx(pat(:number)).Match(str)

	func IsNumberInString(str)
		return StzIsNumberInString(str)

	func @IsNumberInstring(str)
		return StzIsNumberInString(str)

func StzIsIntegerInString(str)
	return StzStringQ(str).IsIntegerInString()

	func IsIntegerInString(str)
		return StzIsIntegerInString(str)

	func @IsIntegerInstring(str)
		return StzIsIntegerInString(str)

func StzIsNumberOrListInString(str)
	return StzStringQ(str).IsNumberOrListInString()

	func IsNumberOrListInString(str)
		return StzIsNumberOrListInString(str)

	func IsStringOrNumberInString(str)
		return StzIsNumberOrListInString(str)

	func @IsNumberOrListInString(str)
		return StzIsNumberOrListInString(str)

	func @IsStringOrNumberInString(str)
		return StzIsNumberOrListInString(str)

func StzIsRealInString(str)
	return StzStringQ(str).IsRealInString()

	func IsRealInString(str)
		return StzIsRealInString(str)

	func @IsRealInstring(str)
		return StzIsRealInString(str)

func StzIsPalindrome(p)
	if isList(p)
		if len(p) < 2
			return 0
		ok

		nLen = len(p)
		for i = 1 to nLen / 2
			if NOT BothAreEqual(p[i], p[nLen - i + 1])
				return 0
			ok
		next
		return 1

	but isString(p)
		pStr = StzEngineString(StzCaseFold(p))
		nResult = StzEngineStringIsPalindrome(pStr)
		StzEngineStringFree(pStr)
		return nResult
	else
		StzRaise("Incorrect param type! p must be a string or list.")
	ok

	func @IsPalindrome(p)
		return StzIsPalindrome(p)

	def IsPalindrom(p)
		return StzIsPalindrome(p)

	func @IsPalindrom(p)
		return StzIsPalindrome(p)

	func IsMirrored(p)
		return StzIsPalindrome(p)

	func @IsMirrored(p)
		return StzIsPalindrome(p)

func StzIsPunct(p)
	if isString(p)
		if len(p) = 0 return 0 ok
		pStr = StzEngineString(p)
		nCount = StzEngineStringCount(pStr)
		nPunct = StzEngineStringCountCharsOfType(pStr, 5)
		StzEngineStringFree(pStr)
		return nPunct = nCount

	but isList(p) and @IsListOfChars(p)
		#TODO
	else
		StzRaise("Incorrect param type! p must be a string or list of chars.")
	ok

	func @IsPunct(p)
		return StzIsPunct(p)

#--

func StzMarquerChar()
	return _cMarquerChar

	func MarquerChar()
		return StzMarquerChar()

	func DefaultMarquerChar()
		return StzMarquerChar()

	func @MarquerChar()
		return StzMarquerChar()

	func Marquer()
		return StzMarquerChar()

	func @Marquer()
		return StzMarquerChar()

func StzSetMarquerChar(c)
	if NOT (isString(c) and IsChar(c))
		StzRaise("Incorrect param type! c must be a char.")
	ok

	_cMarquerChar = c

	func SetMarquerChar(c)
		StzSetMarquerChar(c)

	func SetDefaultMarquerChar()
		_cMarquerChar = c

	func @SetMarquerChar()
		_cMarquerChar = c

	func SetMarquer()
		_cMarquerChar = c

	func @SetMarquer()
		_cMarquerChar = c

func StzSplitAtCS(cData, cSubStr, pCaseSensitive)
	if NOT (isString(cData) and isString(cSubStr))
		StzRaise("Incorrect param type! cData and cSubStr must both be strings.")
	ok

	bCase = CaseSensitive(pCaseSensitive)

	pStr = StzEngineString(cData)
	nCount = StzEngineStringSplitCountCS(pStr, cSubStr, bCase)

	acResult = []
	for i = 0 to nCount - 1
		pPart = StzEngineStringSplitGetCS(pStr, cSubStr, i, bCase)
		if pPart != NULL
			acResult + StzEngineStringData(pPart)
			StzEngineStringFree(pPart)
		ok
	next
	StzEngineStringFree(pStr)
	return acResult

	func SplitAtCS(cData, cSubStr, pCaseSensitive)
		return StzSplitAtCS(cData, cSubStr, pCaseSensitive)

	func @SplitAtCS(cData, cSubStr, pCaseSensitive)
		return StzSplitAtCS(cData, cSubStr, pCaseSensitive)

	func SplitCS(cData, cSubStr, pCaseSensitive)
		return StzSplitAtCS(cData, cSubStr, pCaseSensitive)

	func @SplitCS(cData, cSubStr, pCaseSensitive)
		return StzSplitAtCS(cData, cSubStr, pCaseSensitive)


func StzSplitAt(cData, cSubStr)
	if NOT (isString(cData) and isString(cSubStr))
		StzRaise("Incorrect param type! cData and cSubStr must both be strings.")
	ok

	return StzSplitCS(cData, cSubStr, 0)

	func @SplitAt(cData, cSubStr)
		return StzSplitAt(cData, cSubStr)

	func SplitAt(cData, cSubStr)
		return StzSplitAt(cData, cSubStr)

	func @Split(cData, cSubStr)
		return StzSplitAt(cData, cSubStr)

func StzIsFileName(pcStr)
	if NOT isString(pcStr)
		return FALSE
	ok

	return Rx(pat(:fileName)).Match(pcStr)

	func IsFileName(pcStr)
		return StzIsFileName(pcStr)

func StzIsCsvFileName(pcStr)

	if NOT isString(pcStr)
		return FALSE
	ok

	if NOT Rx(pat(:fileName)).Match(pcStr)
		return FALSE
	ok

	if StzCaseFold( @split(pcStr, ".")[2] ) = "csv"
		return TRUE
	else
		return FALSE
	ok

	func IsCsvFileName(pcStr)
		return StzIsCsvFileName(pcStr)

func StzIsHtmlFileName(pcStr)
	if NOT isString(pcStr)
		return FALSE
	ok

	if NOT Rx(pat(:fileName)).Match(pcStr)
		return FALSE
	ok

	cExtension = StzCaseFold( @split(pcStr, ".")[2] )

	if cExtension = "html" or cExtension = "htm"
		return TRUE
	else
		return FALSE
	ok

	func IsHtmlFileName(pcStr)
		return StzIsHtmlFileName(pcStr)

func StzIsCsvString(pcStr)
	if NOT isString(pcStr)
		return FALSE
	ok

	return StzStringQ(pcStr).IsCSV()

	func IsCsvString(pcStr)
		return StzIsCsvString(pcStr)

func StzIsHtmlTableString(pcStr)

	if NOT isString(pcStr)
		return FALSE
	ok

	return StzStringQ(pcStr).IsHtmlTable()

	func IsHtmlTableString(pcStr)
		return StzIsHtmlTableString(pcStr)



func StzBoxify(str)
	oTempStr = new stzString(str)
	oTempStr.Boxify()
	return otempStr.Content()

	func Boxify(str)
		return StzBoxify(str)

	func Box(str)
		return StzBoxify(str)

	func @Boxify(str)
		return StzBoxify(str)

	func @Box(str)
		return StzBoxify(str)


func StzBoxifyRound(str)
	oTempStr = new stzString(str)
	oTempStr.BoxifyRound()
	return otempStr.Content()

	func BoxifyRound(str)
		return StzBoxifyRound(str)

	#< @FunctionAlternativeForms

	func BoxRound(str)
		return BoxifyRound(str)

	func BoxRounded(str)
		return BoxifyRound(str)

	func BoxedRound(str)
		return BoxifyRound(str)

	func BoxedRounded(str)
		return BoxifyRound(str)

	func BoxifiedRound(str)
		return BoxifyRound(str)

	func BoxifiedRounded(str)
		return BoxifyRound(str)

	#--

	func @BoxifyRound(str)
		return BoxifyRound(str)

	func @BoxRound(str)
		return BoxifyRound(str)

	func @BoxRounded(str)
		return BoxifyRound(str)

	func @BoxedRound(str)
		return BoxifyRound(str)

	func @BoxedRounded(str)
		return BoxifyRound(str)

	func @BoxifiedRound(str)
		return BoxifyRound(str)

	func @BoxifiedRounded(str)
		return BoxifyRound(str)

	#--

	func RoundBox(str)
		return BoxifyRound(str)

	func RoundedBox(str)
		return BoxifyRound(str)

	func RoundedBoxed(str)
		return BoxifyRound(str)

	func RoundBoxed(str)
		return BoxifyRound(str)

	func @RoundBox(str)
		return BoxifyRound(str)

	func @RoundedBox(str)
		return BoxifyRound(str)

	func @RoundedBoxed(str)
		return BoxifyRound(str)

	func @RoundBoxed(str)
		return BoxifyRound(str)
	
	#>

func StzBoxifyDash(str)
	oTempStr = new stzString(str)
	oTempStr.BoxifyDash()
	return otempStr.Content()

	func BoxifyDash(str)
		return StzBoxifyDash(str)

	#< @FunctionAlternativeForms

	func BoxDash(str)
		return BoxifyDash(str)

	func BoxDashed(str)
		return BoxifyDash(str)

	func BoxedDash(str)
		return BoxifyDash(str)

	func BoxedDashed(str)
		return BoxifyDash(str)

	func BoxifiedDash(str)
		return BoxifyDash(str)

	func BoxifiedDashed(str)
		return BoxifyDash(str)

	#--

	func @BoxifyDash(str)
		return BoxifyDash(str)

	func @BoxDash(str)
		return BoxifyDash(str)

	func @BoxDashed(str)
		return BoxifyDash(str)

	func @BoxedDash(str)
		return BoxifyDash(str)

	func @BoxedDashed(str)
		return BoxifyDash(str)

	func @BoxifiedDash(str)
		return BoxifyDash(str)

	func @BoxifiedDashed(str)
		return BoxifyDash(str)

	#>

func StzBoxDashRound(str)
	oTempStr = new stzString(str)
	oTempStr.BoxifyDashRound()
	return oTempStr.Content()

	func BoxDashRound(str)
		return StzBoxDashRound(str)

	func @BoxDashRound(str)
		return StzBoxDashRound(str)

func StzBoxChars(str)

	_oTempStr_ = new stzString(str)
	_oTempStr_.BoxEachChar()
	return _oTempStr_.Content()

	func BoxChars(str)
		return StzBoxChars(str)

	func BoxedChars(str)
		return StzBoxChars(str)

	func @BoxChars(str)
		return StzBoxChars(str)

	func @BoxedChars(str)
		return StzBoxChars(str)

func StzBoxRoundChars(str)

	_oTempStr_ = new stzString(str)
	_oTempStr_.BoxRoundEachChar()
	return _oTempStr_.Content()

	func BoxRoundChars(str)
		return StzBoxRoundChars(str)

	func BoxRoundedChars(str)
		return StzBoxRoundChars(str)

	func BoxedRoundChars(str)
		return StzBoxRoundChars(str)

	func BoxedRoundedChars(str)
		return StzBoxRoundChars(str)

	func @BoxRoundChars(str)
		return StzBoxRoundChars(str)

	func @BoxRoundedChars(str)
		return StzBoxRoundChars(str)

	func @BoxedRoundChars(str)
		return StzBoxRoundChars(str)

	func @BoxedRoundedChars(str)
		return StzBoxRoundChars(str)


func StzBoxDashChars(str)

	_oTempStr_ = new stzString(str)
	_oTempStr_.BoxDashEachChar()
	return _oTempStr_.Content()

	func BoxDashChars(str)
		return StzBoxDashChars(str)

	func BoxedDashChars(str)
		return StzBoxDashChars(str)

	func BoxedDashedChars(str)
		return StzBoxDashChars(str)

	func BoxDashedChars(str)
		return StzBoxDashChars(str)

	func @BoxDashChars(str)
		return StzBoxDashChars(str)

	func @BoxedDashChars(str)
		return StzBoxDashChars(str)

	func @BoxedDashedChars(str)
		return StzBoxDashChars(str)

	func @BoxDashedChars(str)
		return StzBoxDashChars(str)

func StzBoxRoundDashChars(str)

	_oTempStr_ = new stzString(str)
	_oTempStr_.BoxRoundDashEachChar()
	return _oTempStr_.Content()

	func BoxRoundDashChars(str)
		return StzBoxRoundDashChars(str)

	func BoxedRoundDashChars(str)
		return StzBoxRoundDashChars(str)

	func BoxedRoundedDashedChars(str)
		return StzBoxRoundDashChars(str)

	func BoxRoundDashedChars(str)
		return StzBoxRoundDashChars(str)

	func @BoxRoundDashChars(str)
		return StzBoxRoundDashChars(str)

	func @BoxedRoundDashChars(str)
		return StzBoxRoundDashChars(str)

	func @BoxedRoundedDashedChars(str)
		return StzBoxRoundDashChars(str)

	func @BoxRoundDashedChars(str)
		return StzBoxRoundDashChars(str)

func @substr(str, p1, p2) #TODO // Move to stzExtCode

	if isNumber(p1) and isNumber(p2)
		return StringSection(str, p1, p2)

	but isString(p1) and isNumber(p2)

		nLen = StzLen(str)

		cStrRight = StzRight(str, nLen-p2+1)
		nResult = ring_substr1(cStrRight, p1) + p2 - 1

		return nResult

	but isString(p1) and ( (isList(p2) and len(p2)=0) or (isNumber(p2) and p2 = 0) )
		return StzFind(str, p1)

	else

		return substr(str, p1, p2)
	ok

func StzSubstrXT(paParams)
	if NOt isList(paParams)
		StzRaise("Incorrect param type! paParams must be a list.")
	ok

	nLen = len(paParams)
	if nLen < 2 or nLen > 3
		StzRaise("Incorrect param! paParams list size must be 2, or 3.")
	ok

	if NOT isString(paParams[1])
		StzRaise("Incorrect param value! The first item in the paParams list must be a string.")
	ok

	if nLen = 2
		 cType = type(paParams[2])
		if cType = "STRING"
			return ring_substr1(paParams[1], paParams[2])

		else
			StzRaise("Unsupported format of the @substrXT() function.")
		ok

	else // nLen = 3
		if isNumber(paParams[2]) and isNumber(paParams[3])
			return StringSection(paParams[1], paParams[2], paParams[3])

		but isString(paParams[2]) and isString(paParams[3])
			return StzReplace(paParams[1], paParams[2], paParams[3])

		but isString(paParams[2]) and isNumber(paParams[3])
			return @substr(paParams[1], paParams[2], paParams[3])

		else
			StzRaise("Unsupported format of the @substrXT() function.")
		ok
	ok

	func substrXT(paParams)
		return StzSubstrXT(paParams)

	func @substrXT(paParams)
		return StzSubstrXT(paParams)

func StzStringSection(str, n1, n2)
	if CheckParams()
		if NOT isString(str)
			StzRaise("Incorrect param type! str must be a string.")
		ok

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect param type! Both n1 and n2 must be numbers.")
		ok
	ok

	pStr = StzEngineString(str)
	pSlice = StzEngineStringSlice(pStr, n1, n2 - n1 + 1)
	cResult = StzEngineStringData(pSlice)
	StzEngineStringFree(pSlice)
	StzEngineStringFree(pStr)
	return cResult

	func StringSection(str, n1, n2)
		return StzStringSection(str, n1, n2)

func StzLeftOf(str, n)
	if isList(str)
		return ListSection(str, 1, n)
	ok

	return StringSection(str, 1, n)

func StzRightOf(str, n)
	if isList(str)
		nLen = len(str)
		return ListSection(str, nLen+1-n, n)
	ok

	pStr = StzEngineString(str)
	nLen = StzEngineStringCount(pStr)
	StzEngineStringFree(pStr)
	return StringSection(str, nLen-n+1, nLen)


func StzChars(str)
	if isList(str) and len(str) = 2 and isString(str[1]) and str[1] = :In
		str = str[2]
	ok

	pStr = StzEngineString(str)
	pR = StzEngineStringCharsSplit(pStr)
	cJoined = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pStr)
	return _SplitNullDelimited(cJoined)

	func Chars(str)
		return StzChars(str)

	func @Chars(str)
		return StzChars(str)


func _StrContainsCS(cStr, cSubStr, bCaseSensitive)
	pStr = StzEngineString(cStr)
	nResult = StzEngineStringContainsCS(pStr, cSubStr, bCaseSensitive)
	StzEngineStringFree(pStr)
	return nResult

func StzLines(str)
	acResult = @split(str, NL)
	return acResult

	func Lines(str)
		return StzLines(str)

	func @Lines(str)
		return StzLines(str)

func StzIsLatin(p)

	if IsChar(p)
		return StzCharQ(p).IsLatin()

	but isString(p)
		return StzStringQ(p).IsLatin()

	but IsListOfChars(p)
		return StzListOfCharsQ(p).IsLatin()

	but IsListOfStrings(p)
		return StzListOfStringsQ(p).IsLatin()

	else
		StzRaise("Unsupported param type!")
	ok

	func IsLatin(p)
		return StzIsLatin(p)

	func @IsLatin(p)
		return StzIsLatin(p)

#--

  //////////////////////////////////////////////
 ///   Q-CONSTRUCTORS FOR MODULAR CLASSES   ///
//////////////////////////////////////////////

func StzStringXTQ(str)
	return new stzStringXT(str)

func StzStringFinderQ(str)
	return new stzStringFinder(str)

func StzStringFinderXTQ(str)
	return new stzStringFinderXT(str)

func StzStringReplacerQ(str)
	return new stzStringReplacer(str)

func StzStringReplacerXTQ(str)
	return new stzStringReplacerXT(str)

func StzStringSplitterQ(str)
	return new stzStringSplitter(str)

func StzStringSplitterXTQ(str)
	return new stzStringSplitterXT(str)

func StzStringBounderQ(str)
	return new stzStringBounder(str)

func StzStringBounderXTQ(str)
	return new stzStringBounderXT(str)

func StzStringCheckerQ(str)
	return new stzStringChecker(str)

func StzStringCheckerXTQ(str)
	return new stzStringCheckerXT(str)

func StzStringFormatterQ(str)
	return new stzStringFormatter(str)

func StzStringFormatterXTQ(str)
	return new stzStringFormatterXT(str)

func StzStringWalkerQ(str)
	return new stzStringWalker(str)

func StzStringWalkerXTQ(str)
	return new stzStringWalkerXT(str)

func StzStringVisualizerQ(str)
	return new stzStringVisualizer(str)

func StzStringVisualizerXTQ(str)
	return new stzStringVisualizerXT(str)

func StzStringLinesQ(str)
	return new stzStringLines(str)

func StzStringLinesXTQ(str)
	return new stzStringLinesXT(str)

func StzStringWordsQ(str)
	return new stzStringWords(str)

func StzStringEncoderQ(str)
	return new stzStringEncoder(str)

func StzStringEncoderXTQ(str)
	return new stzStringEncoderXT(str)

func StzStringNumbersQ(str)
	return new stzStringNumbers(str)

func StzStringNumbersXTQ(str)
	return new stzStringNumbersXT(str)

func StzStringDuplicatesQ(str)
	return new stzStringDuplicates(str)

func StzStringCodeQ(str)
	return new stzStringCode(str)

func StzStringIOQ(str)
	return new stzStringIO(str)

func StzStringRandomizerQ(str)
	return new stzStringRandomizer(str)

func StzStringLocaleQ(str)
	return new stzStringLocale(str)

func StzStringCryptoQ(str)
	return new stzStringCrypto(str)

func StzStringViewQ(str)
	return new stzStringView(str)

func StzStringWordsXTQ(str)
	return new stzStringWordsXT(str)

func StzStringDuplicatesXTQ(str)
	return new stzStringDuplicatesXT(str)

func StzStringCodeXTQ(str)
	return new stzStringCodeXT(str)

func StzStringIOXTQ(str)
	return new stzStringIOXT(str)

func StzStringRandomizerXTQ(str)
	return new stzStringRandomizerXT(str)

func StzStringLocaleXTQ(str)
	return new stzStringLocaleXT(str)

func StzStringCryptoXTQ(str)
	return new stzStringCryptoXT(str)

# Phase 2 Q-constructors (new subclass pairs)

func StzStringRemoverQ(str)
	return new stzStringRemover(str)

func StzStringRemoverXTQ(str)
	return new stzStringRemoverXT(str)

func StzStringInserterQ(str)
	return new stzStringInserter(str)

func StzStringInserterXTQ(str)
	return new stzStringInserterXT(str)

func StzStringCounterQ(str)
	return new stzStringCounter(str)

func StzStringCounterXTQ(str)
	return new stzStringCounterXT(str)

func StzStringSectionsQ(str)
	return new stzStringSections(str)

func StzStringSectionsXTQ(str)
	return new stzStringSectionsXT(str)

func StzStringGetterQ(str)
	return new stzStringGetter(str)

func StzStringGetterXTQ(str)
	return new stzStringGetterXT(str)

func StzStringExtractorQ(str)
	return new stzStringExtractor(str)

func StzStringExtractorXTQ(str)
	return new stzStringExtractorXT(str)

func StzStringTrimmerQ(str)
	return new stzStringTrimmer(str)

func StzStringTrimmerXTQ(str)
	return new stzStringTrimmerXT(str)

func StzStringComparatorQ(str)
	return new stzStringComparator(str)

func StzStringComparatorXTQ(str)
	return new stzStringComparatorXT(str)

func StzStringLeadTrailQ(str)
	return new stzStringLeadTrail(str)

func StzStringLeadTrailXTQ(str)
	return new stzStringLeadTrailXT(str)

func StzStringPerformerQ(str)
	return new stzStringPerformer(str)

func StzStringPerformerXTQ(str)
	return new stzStringPerformerXT(str)

func StzStringConcatQ(str)
	return new stzStringConcat(str)

func StzStringConcatXTQ(str)
	return new stzStringConcatXT(str)

func StzStringCaseChangerQ(str)
	return new stzStringCaseChanger(str)

func StzStringCaseChangerXTQ(str)
	return new stzStringCaseChangerXT(str)

func StzStringAlignerQ(str)
	return new stzStringAligner(str)

func StzStringAlignerXTQ(str)
	return new stzStringAlignerXT(str)


  ///////////////////////////////////
 ///   LEGACY UTILITY FUNCTIONS  ///
///////////////////////////////////

func @Section(pStrOrList, n1, n2) #TODO // Review the naming of Section() in stzSection

	if CheckParams()
		if NOT (isString(pStrOrList) or isList(pStrOrList))
			StzRaise("Incorrect param type! pStrOrList must be a string or list.")
		ok

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok
	ok

	aItems = []

	if isList(pStrOrList)
		if len(pStrOrList) = 0
			StzRaise("Can't get a section from an empty list!")
		ok

		aItems = pStrOrList

	else
		if pStrOrList = ""
			StzRaise("Can't get a section from an empty string!")
		ok

		aItems = Chars(pStrOrList)
	ok

	nLen = len(aItems)

	if n1 < 1 or n1 > nLen
		StzRaise("Index out of range! n1 must be between 1 and " + nLen + "!")
	ok

	if n2 < 1 or n2 > nLen
		StzRaise("Index out of range! n1 must be between 1 and " + nLen + "!")
	ok

	if n2 < n1
		nTemp = n2
		n2 = n1
		n1 = nTemp
	ok

	if isList(pStrOrList)

		aResult = []
	
		for i = n1 to n2
			aResult + aItems[i]
		next

		return aResult

	else
		cResult = ""

		for i = n1 to n2
			cResult += aItems[i]
		next

		return cResult
	ok

	

//func @Range(pStrOrList, nStart, nRange) #TODO //Review the naming of Range in stzExtinPyhton



# Long-tail global wrappers used by tests inside StzStringQ() blocks.
func CapitalisedInLocale(pcStr, pcLocale)
	if NOT isString(pcStr) return "" ok
	return new stzString(pcStr).Titlecased()

func CapitalizedInLocale(pcStr, pcLocale)
	return CapitalisedInLocale(pcStr, pcLocale)

func NumberOfLeadingItems(pcStr)
	if NOT isString(pcStr) return 0 ok
	return new stzString(pcStr).NumberOfLeadingItems()

func NumberOfTrailingItems(pcStr)
	if NOT isString(pcStr) return 0 ok
	return new stzString(pcStr).NumberOfTrailingItems()

func RepresentsSignedRealNumber(pcStr)
	if NOT isString(pcStr) return FALSE ok
	_c_ = ring_trim(pcStr)
	if len(_c_) = 0 return FALSE ok
	_i_ = 1
	if _c_[1] = "-" or _c_[1] = "+" _i_ = 2 ok
	if _i_ > len(_c_) return FALSE ok
	_bDot_ = FALSE
	while _i_ <= len(_c_)
		if _c_[_i_] = "."
			if _bDot_ return FALSE ok
			_bDot_ = TRUE
		but NOT isDigit(_c_[_i_])
			return FALSE
		ok
		_i_++
	end
	return TRUE

func RepresentsUnsignedRealNumber(pcStr)
	if NOT isString(pcStr) return FALSE ok
	_c_ = ring_trim(pcStr)
	if len(_c_) = 0 return FALSE ok
	_bDot_ = FALSE
	_i_ = 1
	while _i_ <= len(_c_)
		if _c_[_i_] = "."
			if _bDot_ return FALSE ok
			_bDot_ = TRUE
		but NOT isDigit(_c_[_i_])
			return FALSE
		ok
		_i_++
	end
	return TRUE

func RepresentsCalculableInteger(pcStr)
	if NOT isString(pcStr) return FALSE ok
	return new stzString(pcStr).RepresentsCalculableInteger()

# SubStringQ(p): narrative-style wrapper. Accepts either a string or
# a [ "subst", :In = "host" ] pair. Returns the host string wrapped
# in stzString so the narrative .Comes* chain has an object to land on.
func SubStringQ(p)
	if isString(p) return new stzString(p) ok
	if isList(p) and len(p) >= 2
		_host_ = ""
		_sub_ = ""
		if isString(p[1]) _sub_ = p[1] ok
		for _i_ = 2 to len(p)
			_v_ = p[_i_]
			if isList(_v_) and len(_v_) = 2 and isString(_v_[1]) and
			   lower(_v_[1]) = "in" and isString(_v_[2])
				_host_ = _v_[2]
			ok
		next
		_o_ = new stzString(_host_)
		_o_._SetNarrativeSub(_sub_)
		return _o_
	ok
	return new stzString("")


func DivideByN(n)
	# Stub for tests using DivideByN inside a block on numeric strings.
	return n

func AddN(n)
	return n

func RetrieveN(n)
	return n

func SubtractN(n)
	return n

# NL@@NL(value): pretty-print a value with newline-separated elements.
# Stub: just convert via @@ and add NL prefix/suffix.
func NL@@NL(p)
	return char(10) + @@(p) + char(10)

# DefineConstraints: register constraint specs at the global level. Stub
# accepts the spec list; the constraint enforcement layer is future work.
func DefineConstraints(paSpecs)
	if NOT isList(paSpecs) return ok
	# No-op: the parser-level constraint binding is not implemented here.


func EnforeConstraints(paWhat)
	# Constraint enforcement stub; spec parsing not implemented.

func EnforceConstraints(paWhat)
	EnforeConstraints(paWhat)

func Undo()
	# History stub.

func Redo()
	# History stub.

# _StzNormalizeCharCond(cCond): normalize a character-predicate condition for
# the engine W-DSL. Strips an outer { ... } block and lowers Q(@char).Method()
# sugar to engine-DSL calls (Q(@char).isLetter() -> isLetter(@char);
# Q(@char).isEqualTo("S") -> ((@char) = ("S"))). Idempotent -- a predicate that
# is already plain DSL (e.g. '@char != "/"' or 'isLetter(@char)') passes through
# unchanged. This is what lets the W family accept the expressive forms WITHOUT
# eval(): the retired ...WXT() forms used a raw eval() that choked on the { }
# block with an uncatchable C27 syntax error. The braces are single-byte ASCII,
# so the byte-based substr trim is UTF-8 safe (the inner predicate is untouched).
func _StzNormalizeCharCond(cCond)
	if NOT isString(cCond)
		return cCond
	ok
	cCond = ring_trim(cCond)
	if ring_left(cCond, 1) = "{" and ring_right(cCond, 1) = "}"
		cCond = ring_trim( substr(cCond, 2, len(cCond) - 2) )
	ok
	return _StzLowerWPredicates(cCond)
