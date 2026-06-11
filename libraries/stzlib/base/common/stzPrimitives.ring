
# stzPrimitives.ring — Engine-backed primitive string utility functions
#
# These functions are used across ALL Softanza domains (number, object,
# datetime, list, table, etc.) and must be available BEFORE any domain
# module loads. They are loaded right after stzRingLibs.ring (which
# provides the engine DLLs) and after stzFuncs.ring (which provides
# CheckParams, CaseSensitive, StzRaise).
#
# Every function here delegates to the Zig engine for Unicode-correct
# behavior. Ring builtins (upper/lower/len/substr/left/right) are
# byte-oriented and break on multibyte UTF-8 — these replace them.

  #------------------------------------------------------#
 #  UNICODE-AWARE WRAPPERS (engine-backed, simple API)  #
#------------------------------------------------------#

#-- String repetition (pure Ring, no engine needed)

func StzRepeatStr(cStr, nCount)
	_cSrResult_ = ""
	for _iSr_ = 1 to nCount
		_cSrResult_ += cStr
	next
	return _cSrResult_

#-- Case conversion (Unicode-aware, replaces ASCII-only Ring upper()/lower())
#
# Engine-boundary safety: the Zig engine functions assume a Ring string
# on input. Passing a number or list directly causes a silent native
# crash (the process exits with no recoverable error, even inside
# try/catch). These wrappers coerce non-string input to its decimal
# string form so caller code that does e.g. StzLower(1234) gets a
# usable answer instead of a hard exit.

func StzUpper(cStr)
	if NOT isString(cStr)
		cStr = "" + cStr
	ok
	pH = StzEngineString(cStr)
	pR = StzEngineStringToUpper(pH)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

func StzLower(cStr)
	if NOT isString(cStr)
		cStr = "" + cStr
	ok
	pH = StzEngineString(cStr)
	pR = StzEngineStringToLower(pH)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

func StzTitle(cStr)
	if NOT isString(cStr)
		cStr = "" + cStr
	ok
	pH = StzEngineString(cStr)
	pR = StzEngineStringToTitle(pH)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

func StzCaseFold(cStr)
	if NOT isString(cStr)
		cStr = "" + cStr
	ok
	return StzEngineUnicodeCaseFold(cStr)

#-- Length (codepoint count, not byte count)

func StzLen(cStr)
	if isList(cStr)
		return len(cStr)
	ok
	pH = StzEngineString(cStr)
	n = StzEngineStringCount(pH)
	StzEngineStringFree(pH)
	return n

#-- Split null-delimited engine output into Ring list
#   Used to parse engine functions that return items separated by \0

func _SplitNullDelimited(cJoined)
	if cJoined = ""
		return []
	ok
	acResult = []
	cCurrent = ""
	nLen = len(cJoined)
	for i = 1 to nLen
		c = StzMid(cJoined, i, 1)
		# Multi-byte (UTF-8) chars are never NULL; ascii() would fail
		# on them, so skip the NULL test for any non-single-byte char.
		if len(c) = 1 and ascii(c) = 0
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

#-- Parse comma-separated numbers from engine output into Ring list
#   Used for engine functions returning positions as "2,5,8" etc.

func _ParseCSVNumbers(cCSV)
	if cCSV = ""
		return []
	ok
	_anPcsvResult_ = []
	_cPcsvCurrent_ = ""
	_nPcsvLen_ = ring_len(cCSV)
	for _iPcsv_ = 1 to _nPcsvLen_
		_cPcsvChar_ = cCSV[_iPcsv_]
		if _cPcsvChar_ = ","
			if _cPcsvCurrent_ != ""
				_anPcsvResult_ + (0 + _cPcsvCurrent_)
				_cPcsvCurrent_ = ""
			ok
		else
			_cPcsvCurrent_ += _cPcsvChar_
		ok
	next
	if _cPcsvCurrent_ != ""
		_anPcsvResult_ + (0 + _cPcsvCurrent_)
	ok
	return _anPcsvResult_

#-- Character from codepoint (UTF-8 encoded, replaces byte-only Ring char())

func StzChar(nCodepoint)
	return StzEngineUnicodeEncode(nCodepoint)

#-- String reverse (codepoint-aware, not byte-reverse)

func StzReverse(cStr)
	pH = StzEngineString(cStr)
	pR = StzEngineStringReverse(pH)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

#-- Type checking (Unicode-aware)

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

#-- Substring extraction (codepoint-aware)

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

# StzMidToEnd(cStr, nStart): codepoint-correct equivalent of
# Ring's `substr(cStr, nStart)`. One handle-reuse round (count +
# slice) instead of a StzMid + separate StzLen.
func StzMidToEnd(cStr, nStart)
	if NOT isString(cStr) cStr = "" + cStr ok
	pH = StzEngineString(cStr)
	nLen = StzEngineStringCount(pH)
	if nStart < 1 nStart = 1 ok
	if nStart > nLen
		StzEngineStringFree(pH)
		return ""
	ok
	pR = StzEngineStringMid(pH, nStart - 1, nLen - nStart + 1)
	c = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return c

  #------------------------------------------------------#
 #  PADDING, CENTERING, CAPITALIZING                    #
#------------------------------------------------------#

func StzPadRight(cText, nWidth)
	return StzPadRightXT(cText, nWidth, " ")

	func PadRight(cText, nWidth)
		return StzPadRight(cText, nWidth)

func StzPadRightXT(text, width, c)
	pStr = StzEngineString("" + text)
	pResult = StzEngineStringLjust(pStr, width, c)
	cResult = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return cResult

	func PadRightXT(text, width, c)
		return StzPadRightXT(text, width, c)

func StzPadLeft(cText, nWidth)
	return StzPadLeftXT(cText, nWidth, " ")

	func PadLeft(cText, nWidth)
		return StzPadLeft(cText, nWidth)

func StzPadLeftXT(text, width, c)
	pStr = StzEngineString("" + text)
	pResult = StzEngineStringRjust(pStr, width, c)
	cResult = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return cResult

	func PadLeftXT(text, width, c)
		return StzPadLeftXT(text, width, c)

func StzCenter(text, width)
	pStr = StzEngineString("" + text)
	pResult = StzEngineStringCenterPad(pStr, width, " ")
	cResult = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return cResult

	func Center(text, width)
		return StzCenter(text, width)

func StzCapitalize(str)
	if len(str) = 0 return str ok
	pStr = StzEngineString(str)
	pResult = StzEngineStringCapitalizeFirst(pStr)
	cResult = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return cResult

	func Capitalize(str)
		return StzCapitalize(str)

	func Capitalise(str)
		return StzCapitalize(str)

	func @Capitalize(str)
		return StzCapitalize(str)

	func @Capitalise(str)
		return StzCapitalize(str)

  #------------------------------------------------------#
 #  REPLACE (engine-backed, Unicode-safe)               #
#------------------------------------------------------#

func StzReplaceCS(cStr, cSubStr, cNewSubStr, bCaseSensitive)
	if CheckParams()
		if NOT ( isString(cStr) and isString(cSubStr) and isString(cNewSubStr) )
			StzRaise("Incorrect params types! cStr, cSubStr, and cNewSubStr must all be strings.")
		ok
	ok

	if cStr = "" or cSubStr = ''
		return cStr
	ok

	bCase = CaseSensitive(bCaseSensitive)

	# Use Engine for codepoint-safe replace
	pStr = StzEngineString(cStr)
	StzEngineStringReplaceCS(pStr, cSubStr, cNewSubStr, bCase)

	cResult = StzEngineStringData(pStr)
	StzEngineStringFree(pStr)
	return cResult

	#< @FunctionAlternativeForms

	func @ReplaceCS(cStr, cSubStr, cNewSubStr, bCaseSensitive)
		return StzReplaceCS(cStr, cSubStr, cNewSubStr, bCaseSensitive)

	func ReplaceCS(str, cSubStr, cNewSubStr, bCaseSensitive)
		return StzReplaceCS(cStr, cSubStr, cNewSubStr, bCaseSensitive)

	#>

func StzReplace(cStr, cSubStr, cNewSubStr)
	return StzReplaceCS(cStr, cSubStr, cNewSubStr, 1)

	func @Replace(cStr, cSubStr, cNewSubStr)
		return StzReplace(cStr, cSubStr, cNewSubStr)

	func Replace(cStr, cSubStr, cNewSubStr)
		return StzReplace(cStr, cSubStr, cNewSubStr)

  #------------------------------------------------------#
 #  SPLIT (delegates to Core layer StkSplit)            #
#------------------------------------------------------#

func StzSplitCS(cStr, cSubStr, bCaseSensitive)
	return StkSplitCS(cStr, cSubStr, bCaseSensitive)

func StzSplit(cStr, cSubStr)
	return StkSplit(cStr, cSubStr)


#-- Global _ListCopy helper (was previously only a method on stzString).
func _ListCopy(paList)
	if NOT isList(paList) return paList ok
	_aR_ = []
	_nL_ = ring_len(paList)
	for _i_ = 1 to _nL_
		_aR_ + paList[_i_]
	next
	return _aR_
