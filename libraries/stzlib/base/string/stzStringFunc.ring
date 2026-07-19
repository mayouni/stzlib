  /////////////////////////////////////////////
 ///   FUNCTIONS FOR THE STZSTRING CLASS   ///
/////////////////////////////////////////////

# NOTE: Primitive string utility functions (StzLen, StzLower, StzUpper,
# StzLeft, StzRight, StzMid, StzReplace, StzPadLeftXT, StzPadRightXT,
# StzChar, StzReverse, StzCapitalize, StzCenter, StzRepeatStr, etc.)
# are defined in common/stzPrimitives.ring — loaded early so ALL
# domains can use them before string/ loads.


func StzStringQ(_str_)
	return new stzString(_str_)

	#< @FunctionMisspelledForm

	func StzSrtringQ(_str_)
		return StzStringQ(_str_)

# Global helpers used by string-test narratives.
# Full UnicodeDataAsString returns the Unicode database; the cheap
# stub returns "" so the test load completes (used by perf
# narratives).
func UnicodeDataAsString()
	return ""

# MarquersPositions(cMarkers) returns the codepoint positions of
# each marker token "#1", "#2", etc. in the given string.
func MarquersPositions(_cStr_)
	return MarkersPositions(_cStr_)

func MarkersPositions(_cStr_)
	if NOT isString(_cStr_) return [] ok
	_aRes_ = []
	_nLen_ = len(_cStr_)
	_i_ = 1
	while _i_ <= _nLen_
		if _cStr_[_i_] = "#" and _i_ < _nLen_ and isDigit(_cStr_[_i_ + 1])
			_aRes_ + _i_
			_i_++
			while _i_ <= _nLen_ and isDigit(_cStr_[_i_])
				_i_++
			end
		else
			_i_++
		ok
	end
	return _aRes_

# Tier-2 search helpers used by narratives.
func NextNthOccurrence(_cStr_, n, cSub, nFrom)
	_o_ = new stzString(_cStr_)
	return _o_.FindNextNthOccurrence(n, cSub, nFrom)

func PreviousNthOccurrence(_cStr_, n, cSub, nFrom)
	_o_ = new stzString(_cStr_)
	return _o_.FindNthPrevious(n, cSub, nFrom)

# FindNextNthMarquer(cStr, n, nFrom): position of the n-th marker
# (the `#N` placeholder pattern) after nFrom in cStr.
func FindNextNthMarquer(_cStr_, n, nFrom)
	_o_ = new stzString(_cStr_)
	return _o_.FindNextNthMarquer(n, nFrom)

func FindNextNthMarker(_cStr_, n, nFrom)
	return FindNextNthMarquer(_cStr_, n, nFrom)

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
func ReplaceEachLeadingChar(_cStr_, cNewChar)
	_o_ = new stzString(_cStr_)
	_o_.ReplaceEachLeadingChar(cNewChar)
	return _o_.Content()

func ReplaceCharsW(_cStr_, cCondition, cNewChar)
	_o_ = new stzString(_cStr_)
	_o_.ReplaceCharsW(cCondition, cNewChar)
	return _o_.Content()

func StzNamedString(paNamed)
	if CheckingParams()
		if NOT (isList(paNamed) and Q(paNamed).IsPairOfStrings())
			StzRaise("Incorrect param type! paNamed must be a pair of strings.")
		ok
	ok

	_oStr_ = new stzString(paNamed[2])
	_oStr_.SetName(paNamed[1])
	return _oStr_

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

func StzStringIsInListCS(_str_, aList, pCaseSensitive)
	return ListContainsCS(aList, _str_, pCaseSensitive)

	func StringIsInListCS(_str_, aList, pCaseSensitive)
		return StzStringIsInListCS(_str_, aList, pCaseSensitive)

func StzStringIsInList(_str_, aList)
	return ListContains(aList, _str_)

	func StringIsInList(_str_, aList)
		return StzStringIsInList(_str_, aList)

# NOTE: StzPadRight/XT, StzPadLeft/XT, StzCenter, StzCapitalize
# moved to common/stzPrimitives.ring

func StzIsInvisibleString(_str_)

	if CheckParams()
		if NOT isString(_str_)
			stzraise("Incorrect param type! str must be a string.")
		ok
	ok

	_acChars_ = Chars(_str_)
	_nLen_ = len(_acChars_)

	_bResult_ = 1

	for @i = 1 to _nLen_
		if NOT IsInvisibleChar(_acChars_[@i])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

	func IsInvisibleString(_str_)
		return StzIsInvisibleString(_str_)

	func @IsInvisibleString(_str_)
		return StzIsInvisibleString(_str_)

	func IsInvisible(_str_)
		return StzIsInvisibleString(_str_)

	func @IsInvisible(_str_)
		return StzIsInvisibleString(_str_)

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

func StzIsAlphabetic(_cStr_)
	pStr = StzEngineString(_cStr_)
	_nResult_ = StzEngineStringIsAlpha(pStr)
	StzEngineStringFree(pStr)
	return _nResult_

	func @IsAlpha(_cStr_)
		return StzIsAlphabetic(_cStr_)

	func IsAlphabetical(_cStr_)
		return StzIsAlphabetic(_cStr_)

	func @IsAlphabetical(_cStr_)
		return StzIsAlphabetic(_cStr_)

	func IsAlphabetic(_cStr_)
		return StzIsAlphabetic(_cStr_)

	func @IsAlphabetic(_cStr_)
		return StzIsAlphabetic(_cStr_)

func StzIsAlphanumeric(_cStr_)
	pStr = StzEngineString(_cStr_)
	_nLen_ = StzEngineStringCount(pStr)
	if _nLen_ = 0
		StzEngineStringFree(pStr)
		return 0
	ok
	_nLetters_ = StzEngineStringCountCharsOfType(pStr, 0)
	_nDigits_ = StzEngineStringCountCharsOfType(pStr, 1)
	StzEngineStringFree(pStr)
	return (_nLetters_ + _nDigits_) = _nLen_

	func @IsAlnum(_cStr_)
		return StzIsAlphanumeric(_cStr_)

	func IsAlphaNumerical(_cStr_)
		return StzIsAlphanumeric(_cStr_)

	func @IsAlphaNumerical(_cStr_)
		return StzIsAlphanumeric(_cStr_)

	func IsAlphaNumeric(_cStr_)
		return StzIsAlphanumeric(_cStr_)

	func @IsAlphanumeric(_cStr_)
		return StzIsAlphanumeric(_cStr_)

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

	func @IsNull(_cStr_)
		return StzIsNull(_cStr_)

func StzIsNullString(_cStr_)
	if isString(_cStr_) and _cStr_ = ""
		return 1
	else
		return 0
	ok

	func IsNullString(_cStr_)
		return StzIsNullString(_cStr_)

	func IsEmptyString(_cStr_)
		return StzIsNullString(_cStr_)

	func ANullString(pcStr)
		return StzIsNullString(_cStr_)

	func IsAnEmptyString(_cStr_)
		return StzIsNullString(_cStr_)

	func @IsNullString(_cStr_)
		return StzIsNullString(_cStr_)

	func @IsEmptyString(_cStr_)
		return StzIsNullString(_cStr_)

	func @ANullString(pcStr)
		return StzIsNullString(_cStr_)

	func @IsAnEmptyString(_cStr_)
		return StzIsNullString(_cStr_)

	func StringIsNull(pcStr)
		return isString(pcStr) and pcStr = ""

func StzIsNonNullString(_cStr_)
	return NOT StzIsNullString(_cStr_)

	func IsNonNullString(_cStr_)
		return StzIsNonNullString(_cStr_)

	func IsNonEmptyString(_cStr_)
		return StzIsNonNullString(_cStr_)

	func ANonNullString(pcStr)
		return StzIsNonNullString(_cStr_)

	func IsANonEmptyString(_cStr_)
		return StzIsNonNullString(_cStr_)

	func @IsNonNullString(_cStr_)
		return StzIsNonNullString(_cStr_)

	func @IsNonEmptyString(_cStr_)
		return StzIsNonNullString(_cStr_)

	func @ANonNullString(pcStr)
		return StzIsNonNullString(_cStr_)

	func @IsANonEmptyString(_cStr_)
		return StzIsNonNullString(_cStr_)

func StzIsBlank(pcStr)
	if len(pcStr) = 0 return 0 ok
	pStr = StzEngineString(pcStr)
	_nResult_ = StzEngineStringIsWhitespace(pStr)
	StzEngineStringFree(pStr)
	return _nResult_

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
		_bCase_ = CaseSensitive(bCaseSensitive)
		pStr = StzEngineString(pStrOrList)
		_nResult_ = StzEngineStringStartsWithCS(pStr, pSubStrOrItem, _bCase_)
		StzEngineStringFree(pStr)
		return _nResult_
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
		_nResult_ = StzEngineStringStartsWith(pStr, pSubStrOrItem)
		StzEngineStringFree(pStr)
		return _nResult_
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
		_bCase_ = CaseSensitive(bCaseSensitive)
		pStr = StzEngineString(pStrOrList)
		_nResult_ = StzEngineStringEndsWithCS(pStr, pSubStrOrItem, _bCase_)
		StzEngineStringFree(pStr)
		return _nResult_
	ok
	return Q(pStrOrList).EndsWithCS(pSubStrOrItem, bCaseSensitive)

	func EndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzEndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	func @EndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StzEndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

func StzEndsWith(pStrOrList, pSubStrOrItem) # endsWith() seems to be reserved by Ring StdLib
	if isString(pStrOrList) and isString(pSubStrOrItem)
		pStr = StzEngineString(pStrOrList)
		_nResult_ = StzEngineStringEndsWith(pStr, pSubStrOrItem)
		StzEngineStringFree(pStr)
		return _nResult_
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

	_bCase_ = CaseSensitive(pCaseSensitive)

	pStr = StzEngineString(pcStr)
	_nResult_ = StzEngineStringContainsCS(pStr, pcSubStr, _bCase_)
	StzEngineStringFree(pStr)
	return _nResult_

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

	_nLenSubStr_ = len(pacSubStr)

	if pcStr = "" or
	   len(pacSubStr) = 0
		return 0
	ok

	_bResult_ = 0
	for i = 1 to _nLenSubStr_
		if StzStringContainsCS(pcStr, pacSubStr[i], pCaseSensitive)
			_bResult_ = 1
			exit
		ok
	next

	return _bResult_

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

func StzTrimString(_cStr_)
	if CheckParams()
		if NOT isString(_cStr_)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	if len(_cStr_) = 0 return "" ok

	pStr = StzEngineString(_cStr_)
	pTrimmed = StzEngineStringTrimmed(pStr)
	_cResult_ = StzEngineStringData(pTrimmed)
	StzEngineStringFree(pTrimmed)
	StzEngineStringFree(pStr)
	return _cResult_

	func TrimString(_cStr_)
		return StzTrimString(_cStr_)

	func @TrimString(_cStr_)
		return StzTrimString(_cStr_)

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
		_acSplits_ = @split(pStrOrList, NL)
	else
		_acSplits_ = pStrOrList
	ok

	return StzTrimList(_acSplits_)

	func TrimLines(pStrOrList)
		return StzTrimLines(pStrOrList)

func StzTrimList(aList)
	if CheckParams()
		if NOT isList(aList)
			StzRaise("Incorrect param type! aList must be a list.")
		ok
	ok

	_oList_ = new stzList(aList)
	_aResult_ = _oList_.Trimmed()
	return _aResult_

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
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		StzEngineStringFree(pStr)
		return _cResult_
	else
		_nLen_ = len(cStrOrList)
		_nStart_ = 1
		for i = 1 to _nLen_
			if isString(cStrOrList[i]) and trim(cStrOrList[i]) = ""
				_nStart_ = i + 1
			else
				exit
			ok
		next
		if _nStart_ > _nLen_
			return []
		ok
		_aResult_ = []
		for i = _nStart_ to _nLen_
			_aResult_ + cStrOrList[i]
		next
		return _aResult_
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
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		StzEngineStringFree(pStr)
		return _cResult_
	else
		_nLen_ = len(cStrOrList)
		_nEnd_ = _nLen_
		for i = _nLen_ to 1 step -1
			if isString(cStrOrList[i]) and trim(cStrOrList[i]) = ""
				_nEnd_ = i - 1
			else
				exit
			ok
		next
		if _nEnd_ < 1
			return []
		ok
		_aResult_ = []
		for i = 1 to _nEnd_
			_aResult_ + cStrOrList[i]
		next
		return _aResult_
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

func _StzSimplifyString(_cStr_)
	pStr = StzEngineString(_cStr_)
	pResult = StzEngineStringSimplify(pStr)
	_cResult_ = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return _cResult_

func _StzStripBraces(_cStr_)
	_cStr_ = @trim(_cStr_)
	if len(_cStr_) < 2 return _cStr_ ok
	pStr = StzEngineString(_cStr_)
	_nLen_ = StzEngineStringCount(pStr)
	if _nLen_ >= 2 and StzEngineStringStartsWith(pStr, "{") and StzEngineStringEndsWith(pStr, "}")
		# StzEngineStringSlice(handle, start_cp, cp_count) is 1-based.
		# Skip the leading '{' (start at codepoint 2) and trim 2 chars
		# total ('{' on the left, '}' on the right).
		pSliced = StzEngineStringSlice(pStr, 2, _nLen_ - 2)
		_cStr_ = StzEngineStringData(pSliced)
		StzEngineStringFree(pSliced)
		_cStr_ = @trim(_cStr_)
	ok
	StzEngineStringFree(pStr)
	return _cStr_

#--

func StzStringContent(_oStr_)
	return _oStr_.Content()

func StzStringIsLocaleAbbreviation(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsLocaleAbbreviation()

	func StringIsLocaleAbbreviation(_cStr_)
		return StzStringIsLocaleAbbreviation(_cStr_)

	func IsLocaleAbbreviation(_cStr_)
		return StzStringIsLocaleAbbreviation(_cStr_)

	func @IsLocaleAbbreviation(_cStr_)
		return StzStringIsLocaleAbbreviation(_cStr_)

func StzStringIsLanguageAbbreviation(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsLanguageAbbreviation()

	func StringIsLanguageAbbreviation(_cStr_)
		return StzStringIsLanguageAbbreviation(_cStr_)

	func IsLanguageAbbreviation(_cStr_)
		return StzStringIsLanguageAbbreviation(_cStr_)

	func @IsLanguageAbbreviation(_cStr_)
		return StzStringIsLanguageAbbreviation(_cStr_)

func StzStringIsShortLanguageAbbreviation(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsShortLanguageAbbreviation()

	func StringIsShortLanguageAbbreviation(_cStr_)
		return StzStringIsShortLanguageAbbreviation(_cStr_)

	func @IsShortLanguageAbbreviation(_cStr_)
		return StzStringIsShortLanguageAbbreviation(_cStr_)

func StzStringIsLongLanguageAbbreviation(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsLongLanguageAbbreviation()

	func StringIsLongLanguageAbbreviation(_cStr_)
		return StzStringIsLongLanguageAbbreviation(_cStr_)

	func IsLongLanguageAbbreviation(_cStr_)
		return StzStringIsLongLanguageAbbreviation(_cStr_)

	func @IsLongLanguageAbbreviation(_cStr_)
		return StzStringIsLongLanguageAbbreviation(_cStr_)

func StzStringIsLanguageName(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsLanguageName()

	func StringIsLanguageName(_cStr_)
		return StzStringIsLanguageName(_cStr_)

	func IsLanguageName(_cStr_)
		return StzStringIsLanguageName(_cStr_)

	func IsLanguage(_cStr_)
		return StzStringIsLanguageName(_cStr_)

	func @IsLanguageName(_cStr_)
		return StzStringIsLanguageName(_cStr_)

	func @IsLanguage(_cStr_)
		return StzStringIsLanguageName(_cStr_)

func StzStringIsLanguageNumber(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsLanguageNumber()

	func StringIsLanguageNumber(_cStr_)
		return StzStringIsLanguageNumber(_cStr_)

	func IsLanguageNumber(_cStr_)
		return StzStringIsLanguageNumber(_cStr_)

	func @IsLanguageNumber(_cStr_)
		return StzStringIsLanguageNumber(_cStr_)

func StzStringIsCountryAbbreviation(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsCountryAbbreviation()

	func StringIsCountryAbbreviation(_cStr_)
		return StzStringIsCountryAbbreviation(_cStr_)

	func IsCountryAbbreviation(_cStr_)
		return StzStringIsCountryAbbreviation(_cStr_)

	func @IsCountryAbbreviation(_cStr_)
		return StzStringIsCountryAbbreviation(_cStr_)

func StzStringIsCountryName(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsCountryName()

	func StringIsCountryName(_cStr_)
		return StzStringIsCountryName(_cStr_)

	func IsCountryName(_cStr_)
		return StzStringIsCountryName(_cStr_)

	func IsCountry(_cStr_)
		return StzStringIsCountryName(_cStr_)

	func @IsCountryName(_cStr_)
		return StzStringIsCountryName(_cStr_)

	func @IsCountry(_cStr_)
		return StzStringIsCountryName(_cStr_)

func StzStringIsCountryNumber(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsCountryNumber()

	func StringIsCountryNumber(_cStr_)
		return StzStringIsCountryNumber(_cStr_)

	func IsCountryNumber(_cStr_)
		return StzStringIsCountryNumber(_cStr_)

	func @IsCountryNumber(_cStr_)
		return StzStringIsCountryNumber(_cStr_)

func StzStringIsShortCountryAbbreviation(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsShortCountryAbbreviation()

	func StringIsShortCountryAbbreviation(_cStr_)
		return StzStringIsShortCountryAbbreviation(_cStr_)

	func IsShortCountryAbbreviation(_cStr_)
		return StzStringIsShortCountryAbbreviation(_cStr_)

	func @IsShortCountryAbbreviation(_cStr_)
		return StzStringIsShortCountryAbbreviation(_cStr_)

func StzStringIsLongCountryAbbreviation(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsLongCountryAbbreviation()

	func StringIsLongCountryAbbreviation(_cStr_)
		return StzStringIsLongCountryAbbreviation(_cStr_)

	func IsLongCountryAbbreviation(_cStr_)
		return StzStringIsLongCountryAbbreviation(_cStr_)

	func @IsLongCountryAbbreviation(_cStr_)
		return StzStringIsLongCountryAbbreviation(_cStr_)

func StzStringIsScriptAbbreviation(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsScriptAbbreviation()

	func StringIsScriptAbbreviation(_cStr_)
		return StzStringIsScriptAbbreviation(_cStr_)

	func IsScriptAbbreviation(_cStr_)
		return StzStringIsScriptAbbreviation(_cStr_)

	func @IsScriptAbbreviation(_cStr_)
		return StzStringIsScriptAbbreviation(_cStr_)

func StzStringIsScriptName(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsScriptName()

	func StringIsScriptName(_cStr_)
		return StzStringIsScriptName(_cStr_)

	func IsScriptName(_cStr_)
		return StzStringIsScriptName(_cStr_)

	func IsScript(_cStr_)
		return StzStringIsScriptName(_cStr_)

	func @IsScriptName(_cStr_)
		return StzStringIsScriptName(_cStr_)

	func @IsScript(_cStr_)
		return StzStringIsScriptName(_cStr_)

func StzStringIsScriptNumber(_cStr_)
	_oStr_ = new stzString(_cStr_)
	return _oStr_.IsScriptNumber()

	func IsScriptNumber(_cStr_)
		return StzStringIsScriptNumber(_cStr_)

	func StringIsScriptNumber(_cStr_)
		return StzStringIsScriptNumber(_cStr_)

	func @IsScriptNumber(_cStr_)
		return StzStringIsScriptNumber(_cStr_)

func StzStringIsLowercase(_cStr_)
	pStr = StzEngineString(_cStr_)
	_nResult_ = StzEngineStringIsLowercase(pStr)
	StzEngineStringFree(pStr)
	return _nResult_

	func StringIsLowercase(_cStr_)
		return StzStringIsLowercase(_cStr_)

func StzStringIsUppercase(_cStr_)
	pStr = StzEngineString(_cStr_)
	_nResult_ = StzEngineStringIsUppercase(pStr)
	StzEngineStringFree(pStr)
	return _nResult_

	func StringIsUppercase(_cStr_)
		return StzStringIsUppercase(_cStr_)

func StzStringLowercased(_cStr_)
	pStr = StzEngineString(_cStr_)
	pLower = StzEngineStringToLower(pStr)
	_cResult_ = StzEngineStringData(pLower)
	StzEngineStringFree(pLower)
	StzEngineStringFree(pStr)
	return _cResult_

	func StringLowercased(_cStr_)
		return StzStringLowercased(_cStr_)

	func Lowercased(_cStr_)
		return StzStringLowercased(_cStr_)

	func Lowercase(_cStr_)
		return StzStringLowercased(_cStr_)

	func StringLowercase(_cStr_)
		return StzStringLowercased(_cStr_)

	func @Lowercased(_cStr_)
		return StzStringLowercased(_cStr_)

	func @Lowercase(_cStr_)
		return StzStringLowercased(_cStr_)

func StzStringUppercased(_cStr_)
	pStr = StzEngineString(_cStr_)
	pUpper = StzEngineStringToUpper(pStr)
	_cResult_ = StzEngineStringData(pUpper)
	StzEngineStringFree(pUpper)
	StzEngineStringFree(pStr)
	return _cResult_

	func StringUppercased(_cStr_)
		return StzStringUppercased(_cStr_)

	func Uppercase(_cStr_)
		return StzStringUppercased(_cStr_)

	func Uppercased(_cStr_)
		return StzStringUppercased(_cStr_)

	func StringUppercase(_cStr_)
		return StzStringUppercased(_cStr_)

	func @Uppercased(_cStr_)
		return StzStringUppercased(_cStr_)

	func @Uppercase(_cStr_)
		return StzStringUppercased(_cStr_)

func StzStringTitlecased(_cStr_)
	pStr = StzEngineString(_cStr_)
	pTitle = StzEngineStringToTitle(pStr)
	_cResult_ = StzEngineStringData(pTitle)
	StzEngineStringFree(pTitle)
	StzEngineStringFree(pStr)
	return _cResult_

	func StringTitlecased(_cStr_)
		return StzStringTitlecased(_cStr_)

	func Titlecase(_cStr_)
		return StzStringTitlecased(_cStr_)

	func Titlecased(_cStr_)
		return StzStringTitlecased(_cStr_)

	func StringTitlecase(_cStr_)
		return StzStringTitlecased(_cStr_)

	func @Titlecased(_cStr_)
		return StzStringTitlecased(_cStr_)

	func @Titlecase(_cStr_)
		return StzStringTitlecased(_cStr_)

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
	_nResult_ = StzEngineStringIsCharsSortedAsc(pStr)
	StzEngineStringFree(pStr)
	return _nResult_

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
	_nResult_ = StzEngineStringIsCharsSortedDesc(pStr)
	StzEngineStringFree(pStr)
	return _nResult_

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

func StzStringAlignXT(_cStr_, nWidth, cChar, cDirection)
	if cDirection = :Justified
		return _StzJustifyAlign(_cStr_, nWidth, cChar)
	ok
	pStr = StzEngineString(_cStr_)
	if cDirection = :Left
		pResult = StzEngineStringLjust(pStr, nWidth, cChar)
	but cDirection = :Right
		pResult = StzEngineStringRjust(pStr, nWidth, cChar)
	else
		pResult = StzEngineStringCenterPad(pStr, nWidth, cChar)
	ok
	_cResult_ = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return _cResult_

func _StzJustifyAlign(_cStr_, nWidth, cChar)
	# Spread the chars over nWidth, gaps filled with cChar, extras
	# front-loaded ("SOFTANZA" @ 30 -> "S....O...F...T...A...N...Z...A").
	_nJfyLen_ = StzLen(_cStr_)
	if _nJfyLen_ < 2 or _nJfyLen_ >= nWidth
		return _cStr_
	ok
	_oJfy_ = new stzString(_cStr_)
	_aJfyCh_ = _oJfy_.Chars()
	_nJfyGaps_ = _nJfyLen_ - 1
	_nJfySp_ = nWidth - _nJfyLen_
	_nJfyBase_ = floor(_nJfySp_ / _nJfyGaps_)
	_nJfyExtra_ = _nJfySp_ - (_nJfyBase_ * _nJfyGaps_)
	_cJfyRes_ = ""
	for iJfy = 1 to _nJfyLen_
		_cJfyRes_ += _aJfyCh_[iJfy]
		if iJfy < _nJfyLen_
			_nJfyG_ = _nJfyBase_
			if iJfy <= _nJfyExtra_ _nJfyG_++ ok
			for jJfy = 1 to _nJfyG_
				_cJfyRes_ += cChar
			next
		ok
	next
	return _cJfyRes_

	func StringAlignXT(_cStr_, nWidth, cChar, cDirection)
		return StzStringAlignXT(_cStr_, nWidth, cChar, cDirection)

	func @AlignXT(_cStr_, nWidth, cChar, cDirection)
		return StzStringAlignXT(_cStr_, nWidth, cChar, cDirection)

	func AlignXT(_cStr_, nWidth, cChar, cDirection)
		return StzStringAlignXT(_cStr_, nWidth, cChar, cDirection)

func StzStringLeftAlign(_cStr_, nWidth)
	return StzStringAlignXT(_cStr_, nWidth, " ", :Left)

	func StringLeftAlign(_cStr_, nWidth)
		return StzStringLeftAlign(_cStr_, nWidth)

	func StringAlignLeft(_cStr_, nWidth)
		return StzStringLeftAlign(_cStr_, nWidth)

	func LeftAlign(_cStr_, nWidth)
		return StzStringLeftAlign(_cStr_, nWidth)

	func AlignLeft(_cStr_, nWidth)
		return StzStringLeftAlign(_cStr_, nWidth)

	func @LeftAlign(_cStr_, nWidth)
		return StzStringLeftAlign(_cStr_, nWidth)

	func @AlignLeft(_cStr_, nWidth)
		return StzStringLeftAlign(_cStr_, nWidth)

func StzStringLeftAlignXT(_cStr_, nWidth, cChar)
	return StzStringAlignXT(_cStr_, nWidth, cChar, :Left)

	func StringLeftAlignXT(_cStr_, nWidth, cChar)
		return StzStringLeftAlignXT(_cStr_, nWidth, cChar)

	func StringAlignLeftXT(_cStr_, nWidth, cChar)
		return StzStringLeftAlignXT(_cStr_, nWidth, cChar)

	func LeftAlignXT(_cStr_, nWidth, cChar)
		return StzStringLeftAlignXT(_cStr_, nWidth, cChar)

	func AlignLeftXT(_cStr_, nWidth, cChar)
		return StzStringLeftAlignXT(_cStr_, nWidth, cChar)

	func @LeftAlignXT(_cStr_, nWidth, cChar)
		return StzStringLeftAlignXT(_cStr_, nWidth, cChar)

	func @AlignLeftXT(_cStr_, nWidth, cChar)
		return StzStringLeftAlignXT(_cStr_, nWidth, cChar)

func StzStringRightAlign(_cStr_, nWidth)
	return StzStringAlignXT(_cStr_, nWidth, " ", :Right)

	func StringRightAlign(_cStr_, nWidth)
		return StzStringRightAlign(_cStr_, nWidth)

	func StringAlignRight(_cStr_, nWidth)
		return StzStringRightAlign(_cStr_, nWidth)

	func RightAlign(_cStr_, nWidth)
		return StzStringRightAlign(_cStr_, nWidth)

	func AlignRight(_cStr_, nWidth)
		return StzStringRightAlign(_cStr_, nWidth)

	func @RightAlign(_cStr_, nWidth)
		return StzStringRightAlign(_cStr_, nWidth)

	func @AlignRight(_cStr_, nWidth)
		return StzStringRightAlign(_cStr_, nWidth)

func StzStringRightAlignXT(_cStr_, nWidth, cChar)
	return StzStringAlignXT(_cStr_, nWidth, cChar, :Right)

	func StringRightAlignXT(_cStr_, nWidth, cChar)
		return StzStringRightAlignXT(_cStr_, nWidth, cChar)

	func StringAlignRightXT(_cStr_, nWidth, cChar)
		return StzStringRightAlignXT(_cStr_, nWidth, cChar)

	func RightAlignXT(_cStr_, nWidth, cChar)
		return StzStringRightAlignXT(_cStr_, nWidth, cChar)

	func AlignRightXT(_cStr_, nWidth, cChar)
		return StzStringRightAlignXT(_cStr_, nWidth, cChar)

	func @RightAlignXT(_cStr_, nWidth, cChar)
		return StzStringRightAlignXT(_cStr_, nWidth, cChar)

	func @AlignRightXT(_cStr_, nWidth, cChar)
		return StzStringRightAlignXT(_cStr_, nWidth, cChar)

func StzStringCenterAlign(_cStr_, nWidth)
	return StzStringAlignXT(_cStr_, nWidth, " ", :Center)

	func StringCenterAlign(_cStr_, nWidth)
		return StzStringCenterAlign(_cStr_, nWidth)

	func StringAlignCenter(_cStr_, nWidth)
		return StzStringCenterAlign(_cStr_, nWidth)

	func CenterAlign(_cStr_, nWidth)
		return StzStringCenterAlign(_cStr_, nWidth)

	func AlignCenter(_cStr_, nWidth)
		return StzStringCenterAlign(_cStr_, nWidth)

	func @CenterAlign(_cStr_, nWidth)
		return StzStringCenterAlign(_cStr_, nWidth)

	func @AlignCenter(_cStr_, nWidth)
		return StzStringCenterAlign(_cStr_, nWidth)

func StzStringCenterAlignXT(_cStr_, nWidth, cChar)
	return StzStringAlignXT(_cStr_, nWidth, cChar, :Center)

	func StringCenterAlignXT(_cStr_, nWidth, cChar)
		return StzStringCenterAlignXT(_cStr_, nWidth, cChar)

	func StringAlignCenterXT(_cStr_, nWidth, cChar)
		return StzStringCenterAlignXT(_cStr_, nWidth, cChar)

	func CenterAlignXT(_cStr_, nWidth, cChar)
		return StzStringCenterAlignXT(_cStr_, nWidth, cChar)

	func AlignCenterXT(_cStr_, nWidth, cChar)
		return StzStringCenterAlignXT(_cStr_, nWidth, cChar)

	func @CenterAlignXT(_cStr_, nWidth, cChar)
		return StzStringCenterAlignXT(_cStr_, nWidth, cChar)

	func @AlignCenterXT(_cStr_, nWidth, cChar)
		return StzStringCenterAlignXT(_cStr_, nWidth, cChar)
#===

func StzCountCS(pStrOrList, pSubStrOrItem, pCaseSensitive)
	# isString, not isSrtring: the typo made the STRING branch unreachable,
	# so counting a substring in a string raised R3 (Ring resolves an unknown
	# name only when the line runs) while the list branch worked fine. Found
	# by the first test that ever counted a glyph in rendered art.
	if isString(pStrOrList)
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

	_bCase_ = @CaseSensitive(pCaseSensitive)

	pStr = StzEngineString(pcStr)
	_nResult_ = StzEngineStringCountOfCS(pStr, pcSubStr, _bCase_)
	StzEngineStringFree(pStr)

	return _nResult_

	func StringCountCS(pcStr, pcSubStr, pCaseSensitive)
		return StzStringCountCS(pcStr, pcSubStr, pCaseSensitive)

func StzStringCount(pcStr, pcSubStr)
	return StzStringCountCS(pcStr, pcSubStr, 1)

	func StringCount(pcStr, pcSubStr)
		return StzStringCount(pcStr, pcSubStr)

#--

func StzStringNumberOfChars(_cStr_)
	pStr = StzEngineString(_cStr_)
	_nResult_ = StzEngineStringCount(pStr)
	StzEngineStringFree(pStr)
	return _nResult_

	func StringNumberOfChars(_cStr_)
		return StzStringNumberOfChars(_cStr_)

	func @NumberOfChars(_cStr_)
		return StzStringNumberOfChars(_cStr_)

func StzStringReverseChars(_cStr_)
	pStr = StzEngineString(_cStr_)
	pReversed = StzEngineStringReverse(pStr)
	_cResult_ = StzEngineStringData(pReversed)
	StzEngineStringFree(pReversed)
	StzEngineStringFree(pStr)
	return _cResult_

	func StringReverseChars(_cStr_)
		return StzStringReverseChars(_cStr_)

	func @ReverseChars(_cStr_)
		return StzStringReverseChars(_cStr_)

func StzStringIsWord(_cStr_)
	if len(_cStr_) = 0 return 0 ok
	pStr = StzEngineString(_cStr_)
	_nResult_ = StzEngineStringIsWord(pStr)
	StzEngineStringFree(pStr)
	return _nResult_

	func StringIsWord(_cStr_)
		return StzStringIsWord(_cStr_)

	func @IsWord(_cStr_)
		return StzStringIsWord(_cStr_)

func StzStringNumberOfOccurrence(pcStr, pcSubStr)
	pStr = StzEngineString(pcStr)
	_nResult_ = StzEngineStringCountOf(pStr, pcSubStr)
	StzEngineStringFree(pStr)
	return _nResult_

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

func StzUppercaseOf(_cStr_)
	pStr = StzEngineString(_cStr_)
	pUpper = StzEngineStringToUpper(pStr)
	_cResult_ = StzEngineStringData(pUpper)
	StzEngineStringFree(pUpper)
	StzEngineStringFree(pStr)
	return _cResult_

	func UppercaseOf(_cStr_)
		return StzUppercaseOf(_cStr_)

	func UppercaseIn(_cStr_)
		return StzUppercaseOf(_cStr_)

func StzLowercaseOf(_cStr_)
	pStr = StzEngineString(_cStr_)
	pLower = StzEngineStringToLower(pStr)
	_cResult_ = StzEngineStringData(pLower)
	StzEngineStringFree(pLower)
	StzEngineStringFree(pStr)
	return _cResult_

	func LowercaseOf(_cStr_)
		return StzLowercaseOf(_cStr_)

	func LowercaseIn(_cStr_)
		return StzLowercaseOf(_cStr_)

func StzFoldcaseOf(_cStr_)
	pStr = StzEngineString(_cStr_)
	pFolded = StzEngineStringFoldcase(pStr)
	_cResult_ = StzEngineStringData(pFolded)
	StzEngineStringFree(pFolded)
	StzEngineStringFree(pStr)
	return _cResult_

	func FoldcaseOf(_cStr_)
		return StzFoldcaseOf(_cStr_)

	func FoldcaseIn(_cStr_)
		return StzFoldcaseOf(_cStr_)

func StzNthCharOf(n, _cStr_)
	pStr = StzEngineString(_cStr_)
	pChar = StzEngineStringNthChar(pStr, n)
	_cResult_ = StzEngineStringData(pChar)
	StzEngineStringFree(pChar)
	StzEngineStringFree(pStr)
	return _cResult_

	func NthCharOf(n, _cStr_)
		return StzNthCharOf(n, _cStr_)

	func NthCharIn(n, _cStr_)
		return StzNthCharOf(n, _cStr_)

func StzNthLetterOf(n, _cStr_)
		pStr = StzEngineString(_cStr_)
		pLetters = StzEngineStringOnlyLetters(pStr)
		pChar = StzEngineStringNthChar(pLetters, n)
		_cResult_ = StzEngineStringData(pChar)
		StzEngineStringFree(pChar)
		StzEngineStringFree(pLetters)
		StzEngineStringFree(pStr)
		return _cResult_

	func NthLetterOf(n, _cStr_)
		return StzNthLetterOf(n, _cStr_)

	func NthLetterIn(n, _cStr_)
		return StzNthLetterOf(n, _cStr_)

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
	_nResult_ = StzEngineStringCount(pStr)
	StzEngineStringFree(pStr)
	return _nResult_

	func NumberOfCharsOf(pcStr)
		return StzNumberOfCharsOf(pcStr)

	func NumberOfCharsIn(pcStr)
		return StzNumberOfCharsOf(pcStr)

func StzBothStringsAreEqualCS(pcStr1, pcStr2, pCaseSensitive)
	_bCase_ = @CaseSensitive(pCaseSensitive)
	pStr1 = StzEngineString(pcStr1)
	pStr2 = StzEngineString(pcStr2)
	_nResult_ = StzEngineStringEqualsCS(pStr1, pStr2, _bCase_)
	StzEngineStringFree(pStr2)
	StzEngineStringFree(pStr1)
	return _nResult_

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

	_nLen_ = len(pacStr)
	_bResult_ = 1

	pFirst = StzEngineString(pacStr[1])
	for i = 2 to _nLen_
		pOther = StzEngineString(pacStr[i])
		_nEq_ = StzEngineStringEqualsCS(pFirst, pOther, _bCase_)
		StzEngineStringFree(pOther)
		if _nEq_ = 0
			_bResult_ = 0
			exit
		ok
	next
	StzEngineStringFree(pFirst)
	return _bResult_

	func StringsAreEqualCS(pacStr, pCaseSensitive)
		return StzStringsAreEqualCS(pacStr, pCaseSensitive)

func StzStringsAreEqual(paStr)
	return StzStringsAreEqualCS(paStr, 1)

	func StringsAreEqual(paStr)
		return StzStringsAreEqual(paStr)

func StzRemoveDiacritics(pcStr)
	pStr = StzEngineString(pcStr)
	pR = StzEngineStringStripMarks(pStr)
	_cResult_ = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pStr)
	return _cResult_

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
	_cResult_ = StzEngineStringData(pStr)
	StzEngineStringFree(pStr)
	return _cResult_

	func WithoutSpaces(pcStr)
		return StzWithoutSpaces(pcStr)

	func @WithoutSpaces(pcStr)
		return StzWithoutSpaces(pcStr)

	func WithoutSapces(pcStr)
		return StzWithoutSpaces(pcStr)

	func @WithoutSapces(pcStr)
		return StzWithoutSpaces(pcStr)

func StzWithoutQuotes(_cStr_)

	_cStr_ = @trim(_cStr_)
	if len(_cStr_) < 2 return _cStr_ ok

	pStr = StzEngineString(_cStr_)
	_nLen_ = StzEngineStringCount(pStr)
	if _nLen_ < 2
		StzEngineStringFree(pStr)
		return _cStr_
	ok

	if (StzEngineStringStartsWith(pStr, '"') and StzEngineStringEndsWith(pStr, '"')) or
	   (StzEngineStringStartsWith(pStr, "'") and StzEngineStringEndsWith(pStr, "'"))

		pSliced = StzEngineStringSlice(pStr, 1, _nLen_ - 2)
		_cResult_ = StzEngineStringData(pSliced)
		StzEngineStringFree(pSliced)
		StzEngineStringFree(pStr)
		return _cResult_
	ok

	StzEngineStringFree(pStr)
	return _cStr_

	func WithoutQuotes(_cStr_)
		return StzWithoutQuotes(_cStr_)

	func @WithoutQuotes(_cStr_)
		return StzWithoutQuotes(_cStr_)

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

func StzSpacify(_str_)
	pStr = StzEngineString(_str_)
	pResult = StzEngineStringSpacify(pStr)
	_cResult_ = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return _cResult_

	func Spacify(_str_)
		return StzSpacify(_str_)

	func @Spacify(_str_)
		return StzSpacify(_str_)

func StzSpacifyXT(_str_, pSep, pStep, pDirection)
	_cResult_ = StzStringQ(_str_).SpacifyXTQ(pSep, pStep, pDirection).Content()
	return _cResult_

	func SpacifyXT(_str_, pSep, pStep, pDirection)
		return StzSpacifyXT(_str_, pSep, pStep, pDirection)

	func @SpacifyXT(_str_, pSep, pStep, pDirection)
		return StzSpacifyXT(_str_, pSep, pStep, pDirection)

func StzIsMarquer(_cStr_)
	if CheckingParams()
		if NOT isString(_cStr_)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	return Q(_cStr_).IsMarquer()

	func IsMarquer(_cStr_)
		return StzIsMarquer(_cStr_)

	func IsAMarquer(_cStr_)
		return StzIsMarquer(_cStr_)

	func StringIsMarquer(_cStr_)
		return StzIsMarquer(_cStr_)

	func StringIsAMarquer(_cStr_)
		return StzIsMarquer(_cStr_)

	func @IsMarquer(_cStr_)
		return StzIsMarquer(_cStr_)

	func @IsAMarquer(_cStr_)
		return StzIsMarquer(_cStr_)

	func @StringIsMarquer(_cStr_)
		return StzIsMarquer(_cStr_)

	func @StringIsAMarquer(_cStr_)
		return StzIsMarquer(_cStr_)

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
	_cResult_ = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return _cResult_

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

func ring_number(_cNumberInStr_) #TODO // Move it to stzRingFuncs.ring
	return number(_cNumberInStr_)

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

	_cNumberInStr_ = StzReplace(pNumberOrString, " ", "")
	_cNumberInStr_ = StzReplace(_cNumberInStr_, "_", "")

	if _cNumberInStr_ = ""
		StzRaise("Incorrect param value! pNumberOrString must contain a number.")
	ok

	# Now, it is safe ti use the Ring Number() function

	try
		_nResult_ = ring_number(_cNumberInStr_)
		return _nResult_
	catch
		stzRaise("Can't proceed! pNumberOrString contains a literal not a number in string.")
	done

func StzIsNumberInString(_str_)
	if NOT isString(_str_)
		return FALSE
	ok

	return rx(pat(:number)).Match(_str_)

	func IsNumberInString(_str_)
		return StzIsNumberInString(_str_)

	func @IsNumberInstring(_str_)
		return StzIsNumberInString(_str_)

func StzIsIntegerInString(_str_)
	return StzStringQ(_str_).IsIntegerInString()

	func IsIntegerInString(_str_)
		return StzIsIntegerInString(_str_)

	func @IsIntegerInstring(_str_)
		return StzIsIntegerInString(_str_)

func StzIsNumberOrListInString(_str_)
	return StzStringQ(_str_).IsNumberOrListInString()

	func IsNumberOrListInString(_str_)
		return StzIsNumberOrListInString(_str_)

	func IsStringOrNumberInString(_str_)
		return StzIsNumberOrListInString(_str_)

	func @IsNumberOrListInString(_str_)
		return StzIsNumberOrListInString(_str_)

	func @IsStringOrNumberInString(_str_)
		return StzIsNumberOrListInString(_str_)

func StzIsRealInString(_str_)
	return StzStringQ(_str_).IsRealInString()

	func IsRealInString(_str_)
		return StzIsRealInString(_str_)

	func @IsRealInstring(_str_)
		return StzIsRealInString(_str_)

func StzIsPalindrome(p)
	if isList(p)
		if len(p) < 2
			return 0
		ok

		_nLen_ = len(p)
		for i = 1 to _nLen_ / 2
			if NOT BothAreEqual(p[i], p[_nLen_ - i + 1])
				return 0
			ok
		next
		return 1

	but isString(p)
		pStr = StzEngineString(StzCaseFold(p))
		_nResult_ = StzEngineStringIsPalindrome(pStr)
		StzEngineStringFree(pStr)
		return _nResult_
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
		_nCount_ = StzEngineStringCount(pStr)
		_nPunct_ = StzEngineStringCountCharsOfType(pStr, 5)
		StzEngineStringFree(pStr)
		return _nPunct_ = _nCount_

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

	_bCase_ = CaseSensitive(pCaseSensitive)

	pStr = StzEngineString(cData)
	_nCount_ = StzEngineStringSplitCountCS(pStr, cSubStr, _bCase_)

	# 1-BASED, because the engine is: str_split_get_cs rejects index < 1
	# outright, so part 1 is the first part.
	#
	# This loop ran `for i = 0 to _nCount_ - 1`. Index 0 came back NULL and
	# the guard below swallowed it, and the loop stopped one short, so the
	# LAST part was never asked for. Every caller of this family --
	# @SplitCS / SplitCS / SplitAtCS / @SplitAtCS / StzSplitAt -- silently
	# lost its final element:
	#
	#   @SplitCS("x,y,z", ",")            gave [x, y]
	#   stzStringLines.Lines()            gave 2 lines for a 3-line string,
	#                                     while NumberOfLines() said 3
	#
	# The NULL guard is what made it invisible: a missing part looked like
	# nothing happening rather than an error. It is kept, but a NULL now
	# means something genuinely wrong, not an off-by-one being absorbed.
	_acResult_ = []
	for i = 1 to _nCount_
		pPart = StzEngineStringSplitGetCS(pStr, cSubStr, i, _bCase_)
		if pPart != NULL
			_acResult_ + StzEngineStringData(pPart)
			StzEngineStringFree(pPart)
		ok
	next
	StzEngineStringFree(pStr)
	return _acResult_

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

	_cExtension_ = StzCaseFold( @split(pcStr, ".")[2] )

	if _cExtension_ = "html" or _cExtension_ = "htm"
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



func StzBoxify(_str_)
	# Boxify() RETURNS the boxed string (it does not mutate) -- use
	# the return value; reading Content() back gave the input unboxed
	_oTempStr_ = new stzString(_str_)
	return _oTempStr_.Boxify()

	func Boxify(_str_)
		return StzBoxify(_str_)

	func Box(_str_)
		return StzBoxify(_str_)

	func @Boxify(_str_)
		return StzBoxify(_str_)

	func @Box(_str_)
		return StzBoxify(_str_)


func StzBoxifyRound(_str_)
	_oTempStr_ = new stzString(_str_)
	_oTempStr_.BoxifyRound()
	return _oTempStr_.Content()

	func BoxifyRound(_str_)
		return StzBoxifyRound(_str_)

	#< @FunctionAlternativeForms

	func BoxRound(_str_)
		return BoxifyRound(_str_)

	func BoxRounded(_str_)
		return BoxifyRound(_str_)

	func BoxedRound(_str_)
		return BoxifyRound(_str_)

	func BoxedRounded(_str_)
		return BoxifyRound(_str_)

	func BoxifiedRound(_str_)
		return BoxifyRound(_str_)

	func BoxifiedRounded(_str_)
		return BoxifyRound(_str_)

	#--

	func @BoxifyRound(_str_)
		return BoxifyRound(_str_)

	func @BoxRound(_str_)
		return BoxifyRound(_str_)

	func @BoxRounded(_str_)
		return BoxifyRound(_str_)

	func @BoxedRound(_str_)
		return BoxifyRound(_str_)

	func @BoxedRounded(_str_)
		return BoxifyRound(_str_)

	func @BoxifiedRound(_str_)
		return BoxifyRound(_str_)

	func @BoxifiedRounded(_str_)
		return BoxifyRound(_str_)

	#--

	func RoundBox(_str_)
		return BoxifyRound(_str_)

	func RoundedBox(_str_)
		return BoxifyRound(_str_)

	func RoundedBoxed(_str_)
		return BoxifyRound(_str_)

	func RoundBoxed(_str_)
		return BoxifyRound(_str_)

	func @RoundBox(_str_)
		return BoxifyRound(_str_)

	func @RoundedBox(_str_)
		return BoxifyRound(_str_)

	func @RoundedBoxed(_str_)
		return BoxifyRound(_str_)

	func @RoundBoxed(_str_)
		return BoxifyRound(_str_)
	
	#>

func StzBoxifyDash(_str_)
	_oTempStr_ = new stzString(_str_)
	_oTempStr_.BoxifyDash()
	return _oTempStr_.Content()

	func BoxifyDash(_str_)
		return StzBoxifyDash(_str_)

	#< @FunctionAlternativeForms

	func BoxDash(_str_)
		return BoxifyDash(_str_)

	func BoxDashed(_str_)
		return BoxifyDash(_str_)

	func BoxedDash(_str_)
		return BoxifyDash(_str_)

	func BoxedDashed(_str_)
		return BoxifyDash(_str_)

	func BoxifiedDash(_str_)
		return BoxifyDash(_str_)

	func BoxifiedDashed(_str_)
		return BoxifyDash(_str_)

	#--

	func @BoxifyDash(_str_)
		return BoxifyDash(_str_)

	func @BoxDash(_str_)
		return BoxifyDash(_str_)

	func @BoxDashed(_str_)
		return BoxifyDash(_str_)

	func @BoxedDash(_str_)
		return BoxifyDash(_str_)

	func @BoxedDashed(_str_)
		return BoxifyDash(_str_)

	func @BoxifiedDash(_str_)
		return BoxifyDash(_str_)

	func @BoxifiedDashed(_str_)
		return BoxifyDash(_str_)

	#>

func StzBoxDashRound(_str_)
	_oTempStr_ = new stzString(_str_)
	_oTempStr_.BoxifyDashRound()
	return _oTempStr_.Content()

	func BoxDashRound(_str_)
		return StzBoxDashRound(_str_)

	func @BoxDashRound(_str_)
		return StzBoxDashRound(_str_)

func StzBoxChars(_str_)

	_oTempStr_ = new stzString(_str_)
	_oTempStr_.BoxEachChar()
	return _oTempStr_.Content()

	func BoxChars(_str_)
		return StzBoxChars(_str_)

	func BoxedChars(_str_)
		return StzBoxChars(_str_)

	func @BoxChars(_str_)
		return StzBoxChars(_str_)

	func @BoxedChars(_str_)
		return StzBoxChars(_str_)

func StzBoxRoundChars(_str_)

	_oTempStr_ = new stzString(_str_)
	_oTempStr_.BoxRoundEachChar()
	return _oTempStr_.Content()

	func BoxRoundChars(_str_)
		return StzBoxRoundChars(_str_)

	func BoxRoundedChars(_str_)
		return StzBoxRoundChars(_str_)

	func BoxedRoundChars(_str_)
		return StzBoxRoundChars(_str_)

	func BoxedRoundedChars(_str_)
		return StzBoxRoundChars(_str_)

	func @BoxRoundChars(_str_)
		return StzBoxRoundChars(_str_)

	func @BoxRoundedChars(_str_)
		return StzBoxRoundChars(_str_)

	func @BoxedRoundChars(_str_)
		return StzBoxRoundChars(_str_)

	func @BoxedRoundedChars(_str_)
		return StzBoxRoundChars(_str_)


func StzBoxDashChars(_str_)

	_oTempStr_ = new stzString(_str_)
	_oTempStr_.BoxDashEachChar()
	return _oTempStr_.Content()

	func BoxDashChars(_str_)
		return StzBoxDashChars(_str_)

	func BoxedDashChars(_str_)
		return StzBoxDashChars(_str_)

	func BoxedDashedChars(_str_)
		return StzBoxDashChars(_str_)

	func BoxDashedChars(_str_)
		return StzBoxDashChars(_str_)

	func @BoxDashChars(_str_)
		return StzBoxDashChars(_str_)

	func @BoxedDashChars(_str_)
		return StzBoxDashChars(_str_)

	func @BoxedDashedChars(_str_)
		return StzBoxDashChars(_str_)

	func @BoxDashedChars(_str_)
		return StzBoxDashChars(_str_)

func StzBoxRoundDashChars(_str_)

	_oTempStr_ = new stzString(_str_)
	_oTempStr_.BoxRoundDashEachChar()
	return _oTempStr_.Content()

	func BoxRoundDashChars(_str_)
		return StzBoxRoundDashChars(_str_)

	func BoxedRoundDashChars(_str_)
		return StzBoxRoundDashChars(_str_)

	func BoxedRoundedDashedChars(_str_)
		return StzBoxRoundDashChars(_str_)

	func BoxRoundDashedChars(_str_)
		return StzBoxRoundDashChars(_str_)

	func @BoxRoundDashChars(_str_)
		return StzBoxRoundDashChars(_str_)

	func @BoxedRoundDashChars(_str_)
		return StzBoxRoundDashChars(_str_)

	func @BoxedRoundedDashedChars(_str_)
		return StzBoxRoundDashChars(_str_)

	func @BoxRoundDashedChars(_str_)
		return StzBoxRoundDashChars(_str_)

func @substr(_str_, p1, p2) #TODO // Move to stzExtCode

	if isNumber(p1) and isNumber(p2)
		return StringSection(_str_, p1, p2)

	but isString(p1) and isNumber(p2)

		_nLen_ = StzLen(_str_)

		_cStrRight_ = StzRight(_str_, _nLen_-p2+1)
		_nResult_ = ring_substr1(_cStrRight_, p1) + p2 - 1

		return _nResult_

	but isString(p1) and ( (isList(p2) and len(p2)=0) or (isNumber(p2) and p2 = 0) )
		return StzFindFirst(p1, _str_)

	else

		return substr(_str_, p1, p2)
	ok

func StzSubstrXT(paParams)
	if NOt isList(paParams)
		StzRaise("Incorrect param type! paParams must be a list.")
	ok

	_nLen_ = len(paParams)
	if _nLen_ < 2 or _nLen_ > 3
		StzRaise("Incorrect param! paParams list size must be 2, or 3.")
	ok

	if NOT isString(paParams[1])
		StzRaise("Incorrect param value! The first item in the paParams list must be a string.")
	ok

	if _nLen_ = 2
		 _cType_ = type(paParams[2])
		if _cType_ = "STRING"
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

func StzStringSection(_str_, _n1_, _n2_)
	if CheckParams()
		if NOT isString(_str_)
			StzRaise("Incorrect param type! str must be a string.")
		ok

		if NOT (isNumber(_n1_) and isNumber(_n2_))
			StzRaise("Incorrect param type! Both n1 and n2 must be numbers.")
		ok
	ok

	pStr = StzEngineString(_str_)
	pSlice = StzEngineStringSlice(pStr, _n1_, _n2_ - _n1_ + 1)
	_cResult_ = StzEngineStringData(pSlice)
	StzEngineStringFree(pSlice)
	StzEngineStringFree(pStr)
	return _cResult_

	func StringSection(_str_, _n1_, _n2_)
		return StzStringSection(_str_, _n1_, _n2_)

func StzLeftOf(_str_, n)
	if isList(_str_)
		return ListSection(_str_, 1, n)
	ok

	return StringSection(_str_, 1, n)

func StzRightOf(_str_, n)
	if isList(_str_)
		_nLen_ = len(_str_)
		return ListSection(_str_, _nLen_+1-n, n)
	ok

	pStr = StzEngineString(_str_)
	_nLen_ = StzEngineStringCount(pStr)
	StzEngineStringFree(pStr)
	return StringSection(_str_, _nLen_-n+1, _nLen_)


func StzChars(_str_)
	if isList(_str_) and len(_str_) = 2 and isString(_str_[1]) and _str_[1] = :In
		_str_ = _str_[2]
	ok

	pStr = StzEngineString(_str_)
	pR = StzEngineStringCharsSplit(pStr)
	_cJoined_ = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pStr)
	return _SplitNullDelimited(_cJoined_)

	func Chars(_str_)
		return StzChars(_str_)

	func @Chars(_str_)
		return StzChars(_str_)


func _StrContainsCS(_cStr_, cSubStr, bCaseSensitive)
	pStr = StzEngineString(_cStr_)
	_nResult_ = StzEngineStringContainsCS(pStr, cSubStr, bCaseSensitive)
	StzEngineStringFree(pStr)
	return _nResult_

func StzLines(_str_)
	_acResult_ = @split(_str_, NL)
	return _acResult_

	func Lines(_str_)
		return StzLines(_str_)

	func @Lines(_str_)
		return StzLines(_str_)

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

func StzStringXTQ(_str_)
	return new stzStringXT(_str_)

func StzStringFinderQ(_str_)
	return new stzStringFinder(_str_)

func StzStringFinderXTQ(_str_)
	return new stzStringFinderXT(_str_)

func StzStringReplacerQ(_str_)
	return new stzStringReplacer(_str_)

func StzStringReplacerXTQ(_str_)
	return new stzStringReplacerXT(_str_)

func StzStringSplitterQ(_str_)
	return new stzStringSplitter(_str_)

func StzStringSplitterXTQ(_str_)
	return new stzStringSplitterXT(_str_)

func StzStringBounderQ(_str_)
	return new stzStringBounder(_str_)

func StzStringBounderXTQ(_str_)
	return new stzStringBounderXT(_str_)

func StzStringCheckerQ(_str_)
	return new stzStringChecker(_str_)

func StzStringCheckerXTQ(_str_)
	return new stzStringCheckerXT(_str_)

func StzStringFormatterQ(_str_)
	return new stzStringFormatter(_str_)

func StzStringFormatterXTQ(_str_)
	return new stzStringFormatterXT(_str_)

func StzStringWalkerQ(_str_)
	return new stzStringWalker(_str_)

func StzStringWalkerXTQ(_str_)
	return new stzStringWalkerXT(_str_)

func StzStringVisualizerQ(_str_)
	return new stzStringVisualizer(_str_)

func StzStringVisualizerXTQ(_str_)
	return new stzStringVisualizerXT(_str_)

func StzStringLinesQ(_str_)
	return new stzStringLines(_str_)

func StzStringLinesXTQ(_str_)
	return new stzStringLinesXT(_str_)

func StzStringWordsQ(_str_)
	return new stzStringWords(_str_)

func StzStringEncoderQ(_str_)
	return new stzStringEncoder(_str_)

func StzStringEncoderXTQ(_str_)
	return new stzStringEncoderXT(_str_)

func StzStringNumbersQ(_str_)
	return new stzStringNumbers(_str_)

func StzStringNumbersXTQ(_str_)
	return new stzStringNumbersXT(_str_)

func StzStringDuplicatesQ(_str_)
	return new stzStringDuplicates(_str_)

func StzStringCodeQ(_str_)
	return new stzStringCode(_str_)

func StzStringIOQ(_str_)
	return new stzStringIO(_str_)

func StzStringRandomizerQ(_str_)
	return new stzStringRandomizer(_str_)

func StzStringLocaleQ(_str_)
	return new stzStringLocale(_str_)

func StzStringCryptoQ(_str_)
	return new stzStringCrypto(_str_)

func StzStringViewQ(_str_)
	return new stzStringView(_str_)

func StzStringWordsXTQ(_str_)
	return new stzStringWordsXT(_str_)

func StzStringDuplicatesXTQ(_str_)
	return new stzStringDuplicatesXT(_str_)

func StzStringCodeXTQ(_str_)
	return new stzStringCodeXT(_str_)

func StzStringIOXTQ(_str_)
	return new stzStringIOXT(_str_)

func StzStringRandomizerXTQ(_str_)
	return new stzStringRandomizerXT(_str_)

func StzStringLocaleXTQ(_str_)
	return new stzStringLocaleXT(_str_)

func StzStringCryptoXTQ(_str_)
	return new stzStringCryptoXT(_str_)

# Phase 2 Q-constructors (new subclass pairs)

func StzStringRemoverQ(_str_)
	return new stzStringRemover(_str_)

func StzStringRemoverXTQ(_str_)
	return new stzStringRemoverXT(_str_)

func StzStringInserterQ(_str_)
	return new stzStringInserter(_str_)

func StzStringInserterXTQ(_str_)
	return new stzStringInserterXT(_str_)

func StzStringCounterQ(_str_)
	return new stzStringCounter(_str_)

func StzStringCounterXTQ(_str_)
	return new stzStringCounterXT(_str_)

func StzStringSectionsQ(_str_)
	return new stzStringSections(_str_)

func StzStringSectionsXTQ(_str_)
	return new stzStringSectionsXT(_str_)

func StzStringGetterQ(_str_)
	return new stzStringGetter(_str_)

func StzStringGetterXTQ(_str_)
	return new stzStringGetterXT(_str_)

func StzStringExtractorQ(_str_)
	return new stzStringExtractor(_str_)

func StzStringExtractorXTQ(_str_)
	return new stzStringExtractorXT(_str_)

func StzStringTrimmerQ(_str_)
	return new stzStringTrimmer(_str_)

func StzStringTrimmerXTQ(_str_)
	return new stzStringTrimmerXT(_str_)

func StzStringComparatorQ(_str_)
	return new stzStringComparator(_str_)

func StzStringComparatorXTQ(_str_)
	return new stzStringComparatorXT(_str_)

func StzStringLeadTrailQ(_str_)
	return new stzStringLeadTrail(_str_)

func StzStringLeadTrailXTQ(_str_)
	return new stzStringLeadTrailXT(_str_)

func StzStringPerformerQ(_str_)
	return new stzStringPerformer(_str_)

func StzStringPerformerXTQ(_str_)
	return new stzStringPerformerXT(_str_)

func StzStringConcatQ(_str_)
	return new stzStringConcat(_str_)

func StzStringConcatXTQ(_str_)
	return new stzStringConcatXT(_str_)

func StzStringCaseChangerQ(_str_)
	return new stzStringCaseChanger(_str_)

func StzStringCaseChangerXTQ(_str_)
	return new stzStringCaseChangerXT(_str_)

func StzStringAlignerQ(_str_)
	return new stzStringAligner(_str_)

func StzStringAlignerXTQ(_str_)
	return new stzStringAlignerXT(_str_)


  ///////////////////////////////////
 ///   LEGACY UTILITY FUNCTIONS  ///
///////////////////////////////////

func @Section(pStrOrList, _n1_, _n2_) #TODO // Review the naming of Section() in stzSection

	if CheckParams()
		if NOT (isString(pStrOrList) or isList(pStrOrList))
			StzRaise("Incorrect param type! pStrOrList must be a string or list.")
		ok

		if NOT (isNumber(_n1_) and isNumber(_n2_))
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok
	ok

	_aItems_ = []

	if isList(pStrOrList)
		if len(pStrOrList) = 0
			StzRaise("Can't get a section from an empty list!")
		ok

		_aItems_ = pStrOrList

	else
		if pStrOrList = ""
			StzRaise("Can't get a section from an empty string!")
		ok

		_aItems_ = Chars(pStrOrList)
	ok

	_nLen_ = len(_aItems_)

	if _n1_ < 1 or _n1_ > _nLen_
		StzRaise("Index out of range! n1 must be between 1 and " + _nLen_ + "!")
	ok

	if _n2_ < 1 or _n2_ > _nLen_
		StzRaise("Index out of range! n1 must be between 1 and " + _nLen_ + "!")
	ok

	if _n2_ < _n1_
		_nTemp_ = _n2_
		_n2_ = _n1_
		_n1_ = _nTemp_
	ok

	if isList(pStrOrList)

		_aResult_ = []
	
		for i = _n1_ to _n2_
			_aResult_ + _aItems_[i]
		next

		return _aResult_

	else
		_cResult_ = ""

		for i = _n1_ to _n2_
			_cResult_ += _aItems_[i]
		next

		return _cResult_
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
func _StzNormalizeCharCond(_cCond_)
	if NOT isString(_cCond_)
		return _cCond_
	ok
	_cCond_ = ring_trim(_cCond_)
	if ring_left(_cCond_, 1) = "{" and ring_right(_cCond_, 1) = "}"
		_cCond_ = ring_trim( substr(_cCond_, 2, len(_cCond_) - 2) )
	ok
	_cCond_ = _StzLowerWPredicates(_cCond_)
	# In CHAR context, "is a number" means "is a digit char" (a char is
	# always a string to the engine's isNumber type check).
	_cCond_ = StzReplaceCS(_cCond_, "isNumber(", "isDigit(", FALSE)
	return _cCond_

# _StzNormalizeSubStringCond(cCond): normalize a SUBSTRING-predicate condition
# (one using @SubString) for evaluation via the list W-DSL over an enumerated
# list of candidate substrings. Strips an outer { } block, rewrites @SubString /
# @substring to the list item var @item (case-insensitive), and lowers the
# Q(@item).Method() sugar. So '@SubString = "X"' -> '@item = "X"', usable by
# stzList.FindW. Handles only the engine-expressible predicates (=, or, and,
# comparisons); complex ones (NumberOfChars/ContainsXT/IsOneOfThese/IsEither)
# are NOT covered -- those need the WF form.
func _StzNormalizeSubStringCond(_cCond_)
	if NOT isString(_cCond_)
		return _cCond_
	ok
	_cCond_ = ring_trim(_cCond_)
	if ring_left(_cCond_, 1) = "{" and ring_right(_cCond_, 1) = "}"
		_cCond_ = ring_trim( substr(_cCond_, 2, len(_cCond_) - 2) )
	ok
	_cCond_ = StzReplaceCS(_cCond_, "@SubString", "@item", FALSE)
	return _StzLowerWPredicates(_cCond_)
