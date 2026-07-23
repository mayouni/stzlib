
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

func StzRepeatStr(_cStr_, nCount)
	_cSrResult_ = ""
	for _iSr_ = 1 to nCount
		_cSrResult_ += _cStr_
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

func StzUpper(_cStr_)
	if NOT isString(_cStr_)
		_cStr_ = "" + _cStr_
	ok
	# Unicode SpecialCasing (ß->SS, ﬄ->FFL, ...) is now done ENGINE-SIDE in
	# stz_unicode_to_upper_str, so no Ring-side ß scan/patch is needed.
	pH = StzEngineString(_cStr_)
	pR = StzEngineStringToUpper(pH)
	_c_ = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return _c_

// Group similar strings by edit (Levenshtein) distance -- fuzzy dedup, typo
// grouping, near-duplicate detection. Greedy "leader" clustering ENGINE-SIDE:
// each string joins the FIRST cluster whose representative is within nThreshold
// edits, else starts a new one. Returns [[member, ...], ...]. cs default 1.
func StzClusterByEditDistance(paStrings, nThreshold)
	return StzClusterByEditDistanceCS(paStrings, nThreshold, 1)

func StzClusterByEditDistanceCS(paStrings, nThreshold, pCaseSensitive)
	if NOT isList(paStrings) or len(paStrings) = 0
		return []
	ok
	_nLen_ = len(paStrings)
	_cPacked_ = ""
	for i = 1 to _nLen_
		_cPacked_ += ("" + paStrings[i])
		if i < _nLen_ _cPacked_ += char(0) ok
	next
	pH = StzEngineString(_cPacked_)
	pRes = StzEngineStringEditCluster(pH, nThreshold, pCaseSensitive)
	_anIDs_ = []
	_nC_ = StzEngineFindResultCount(pRes)
	for i = 1 to _nC_
		_anIDs_ + StzEngineFindResultGet(pRes, i)
	next
	StzEngineFindResultFree(pRes)
	StzEngineStringFree(pH)
	_aClusters_ = []
	for i = 1 to _nLen_
		_nCid_ = _anIDs_[i]
		while len(_aClusters_) < _nCid_
			_aClusters_ + []
		end
		_aClusters_[_nCid_] + paStrings[i]
	next
	return _aClusters_

// TF-IDF keyword extraction across a document corpus. For each document,
// returns its top-N keywords ranked by tf(term)*ln(Ndocs/df(term)) -- terms
// that are frequent in THIS doc but rare across the corpus. Keyword extraction,
// search relevance, summarization, tag suggestion. Returns [[kw,...] per doc].
# nTop <= 0 -> all terms. cs default 1 (case-sensitive).
func StzTFIDFKeywords(paDocs, nTop)
	return StzTFIDFKeywordsCS(paDocs, nTop, 1)

func StzTFIDFKeywordsCS(paDocs, nTop, pCaseSensitive)
	if NOT isList(paDocs) or len(paDocs) = 0
		return []
	ok
	_nLen_ = len(paDocs)
	_cPacked_ = ""
	for i = 1 to _nLen_
		_cPacked_ += ("" + paDocs[i])
		if i < _nLen_ _cPacked_ += char(0) ok
	next
	pH = StzEngineString(_cPacked_)
	pRes = StzEngineStringTFIDFKeywords(pH, nTop, pCaseSensitive)
	_cOut_ = StzEngineStringData(pRes)
	StzEngineStringFree(pRes)
	StzEngineStringFree(pH)
	# Unpack: documents are separated by char(1), keywords within a doc by
	# char(0). Split doc-by-doc (there are exactly nLen of them).
	_aResult_ = []
	_aDocChunks_ = str2list( StzReplace(_cOut_, char(1), char(10)) )
	for i = 1 to _nLen_
		if i <= len(_aDocChunks_) and _aDocChunks_[i] != ""
			_aResult_ + str2list( StzReplace(_aDocChunks_[i], char(0), char(10)) )
		else
			_aResult_ + []
		ok
	next
	return _aResult_

func StzLower(_cStr_)
	if NOT isString(_cStr_)
		_cStr_ = "" + _cStr_
	ok
	pH = StzEngineString(_cStr_)
	pR = StzEngineStringToLower(pH)
	_c_ = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return _c_

func StzTitle(_cStr_)
	if NOT isString(_cStr_)
		_cStr_ = "" + _cStr_
	ok
	pH = StzEngineString(_cStr_)
	pR = StzEngineStringToTitle(pH)
	_c_ = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return _c_

func StzCaseFold(_cStr_)
	if NOT isString(_cStr_)
		_cStr_ = "" + _cStr_
	ok
	return StzEngineUnicodeCaseFold(_cStr_)

#-- Number parse (engine-backed): leading numeric token -> number, else 0

func StzNumber(_cStr_)
	if isNumber(_cStr_)
		return _cStr_
	ok
	if NOT isString(_cStr_)
		_cStr_ = "" + _cStr_
	ok
	pH = StzEngineString(_cStr_)
	_n_ = StzEngineStringToNumber(pH)
	StzEngineStringFree(pH)
	return _n_

#-- Length (codepoint count, not byte count)

func StzLen(_cStr_)
	if isList(_cStr_)
		return len(_cStr_)
	ok
	pH = StzEngineString(_cStr_)
	_n_ = StzEngineStringCount(pH)
	StzEngineStringFree(pH)
	return _n_

#-- Codepoint count, without constructing a stz object to ask for it.
#
#   Q(x).NumberOfChars() builds a whole stzString (a full copy of x) just
#   to return a number the engine already knows -- ~30x the cost of asking
#   directly. This is the same question, asked directly.
#
#   Strings take the engine fast path. Anything else defers to the object,
#   because NumberOfChars() does NOT mean "codepoints" everywhere: on a
#   list it counts the single-character ITEMS (len(Chars())), which is a
#   different number from StzLen()'s item count. Deferring keeps every
#   non-string caller exactly as it was.

func StzNumberOfChars(p)
	if isString(p)
		return StzLen(p)
	ok

	return Q(p).NumberOfChars()

#-- Split null-delimited engine output into Ring list
#   Used to parse engine functions that return items separated by \0

func _SplitNullDelimited(cJoined)
	if cJoined = ""
		return []
	ok
	_acResult_ = []
	# NUL-delimited BYTE buffer whose segments are UTF-8 chars (possibly
	# multibyte). Walk byte positions and cut each segment with a single
	# byte-range substr(). The old code used StzMid(cJoined, i, 1) -- a
	# CODEPOINT slice indexed by a BYTE counter -- which dropped trailing
	# multibyte chars and returned "" on multibyte; char-by-char accumulation
	# of a multibyte segment then also tripped an R31 GC error. Extracting the
	# whole byte range at once avoids both.
	_nLen_ = len(cJoined)
	_nStart_ = 1
	for i = 1 to _nLen_
		if ascii(substr(cJoined, i, 1)) = 0
			if i > _nStart_
				_acResult_ + substr(cJoined, _nStart_, i - _nStart_)
			ok
			_nStart_ = i + 1
		ok
	next
	if _nLen_ >= _nStart_
		_acResult_ + substr(cJoined, _nStart_, _nLen_ - _nStart_ + 1)
	ok
	return _acResult_

#-- Parse comma-separated numbers from engine output into Ring list
#   Used for engine functions returning positions as "2,5,8" etc.

func _ParseCSVNumbers(cCSV)
	if cCSV = ""
		return []
	ok
	_anPcsvResult_ = []
	_cPcsvCurrent_ = ""
	_nPcsvLen_ = len(cCSV)
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

#-- Codepoint of the first character (inverse of StzChar). Unicode-aware
#   replacement for byte-only Ring ascii() when the char may be multi-byte.

func StzCodepoint(cChar)
	if NOT isString(cChar) or cChar = "" return 0 ok
	pH = StzEngineString(cChar)
	_n_ = StzEngineStringCharAt(pH, 1)
	StzEngineStringFree(pH)
	return _n_

#-- String reverse (codepoint-aware, not byte-reverse)

func StzReverse(_cStr_)
	pH = StzEngineString(_cStr_)
	pR = StzEngineStringReverse(pH)
	_c_ = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return _c_

#-- Type checking (Unicode-aware)

func StzIsUpper(_cStr_)
	pH = StzEngineString(_cStr_)
	_n_ = StzEngineStringIsUppercase(pH)
	StzEngineStringFree(pH)
	return _n_

func StzIsLower(_cStr_)
	pH = StzEngineString(_cStr_)
	_n_ = StzEngineStringIsLowercase(pH)
	StzEngineStringFree(pH)
	return _n_

func StzIsAlpha(_cStr_)
	pH = StzEngineString(_cStr_)
	_n_ = StzEngineStringIsAlpha(pH)
	StzEngineStringFree(pH)
	return _n_

func StzIsDigit(_cStr_)
	pH = StzEngineString(_cStr_)
	_n_ = StzEngineStringIsDigit(pH)
	StzEngineStringFree(pH)
	return _n_

#-- Substring extraction (codepoint-aware)
#
# These MUST call the engine's *Cp (codepoint) slice family, never the bare
# byte family. StzEngineStringLeft/Right/Mid take BYTE offsets and lengths; a
# codepoint index handed to them slices mid-character, so the engine's utf-8
# validation returns "" -- or, when the bytes happen to land on a boundary,
# a SILENTLY TRUNCATED string (verified 2026-07-23: StzLeft("cafe"+accent, 4)
# = "", StzMidToEnd("a-"+arabic, 3) = half the characters). ASCII always
# passed, which is exactly why it hid for so long.
#
# The engine's str_left_cp / str_right_cp / str_mid_cp take INDEX_BASE=1
# positions and codepoint counts, clamp a negative/zero count to 0, and clamp
# an over-long count to the end -- so they cannot panic and need no arithmetic
# here. (StzEngineStringLeft(x, -1) DID panic: its bridge casts the count to
# usize with @intFromFloat, and -1 is out of bounds for an unsigned int.)

func StzLeft(_cStr_, _n_)
	if NOT isString(_cStr_) _cStr_ = "" + _cStr_ ok
	if NOT isNumber(_n_) return "" ok
	if _n_ <= 0 return "" ok
	pH = StzEngineString(_cStr_)
	pR = StzEngineStringLeftCp(pH, _n_)
	_c_ = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return _c_

func StzRight(_cStr_, _n_)
	if NOT isString(_cStr_) _cStr_ = "" + _cStr_ ok
	if NOT isNumber(_n_) return "" ok
	if _n_ <= 0 return "" ok
	pH = StzEngineString(_cStr_)
	pR = StzEngineStringRightCp(pH, _n_)
	_c_ = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return _c_

func StzMid(_cStr_, _nStart_, _nLen_)
	# Defensive bounds: Ring's substr returns "" silently on degenerate
	# inputs; match that lenient behaviour rather than raising.
	if NOT isString(_cStr_) _cStr_ = "" + _cStr_ ok
	if NOT (isNumber(_nStart_) and isNumber(_nLen_)) return "" ok
	if _nLen_ <= 0 return "" ok
	if _nStart_ < 1 _nStart_ = 1 ok
	pH = StzEngineString(_cStr_)
	# 1-BASED start (the Cp family is INDEX_BASE-based; the byte family was
	# 0-based, hence the old `_nStart_ - 1`). Over-long counts self-clamp.
	pR = StzEngineStringMidCp(pH, _nStart_, _nLen_)
	_c_ = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return _c_

	# @-prefixed alias (stzMatrex.ParsePattern and friends call @StzMid;
	# only the bare StzMid existed, so the class crashed at construction
	# with R3 "Calling Function without definition: @stzmid").
	func @StzMid(_cStr_, _nStart_, _nLen_)
		return StzMid(_cStr_, _nStart_, _nLen_)

# StzMidToEnd(cStr, nStart): codepoint-correct equivalent of
# Ring's `substr(cStr, nStart)`. One handle-reuse round (count +
# slice) instead of a StzMid + separate StzLen.
func StzMidToEnd(_cStr_, _nStart_)
	if NOT isString(_cStr_) _cStr_ = "" + _cStr_ ok
	if NOT isNumber(_nStart_) return "" ok
	if _nStart_ < 1 _nStart_ = 1 ok
	pH = StzEngineString(_cStr_)
	_nCount_ = StzEngineStringCount(pH)      # CODEPOINTS, matching the Cp slice
	if _nStart_ > _nCount_
		StzEngineStringFree(pH)
		return ""
	ok
	pR = StzEngineStringMidCp(pH, _nStart_, _nCount_ - _nStart_ + 1)
	_c_ = StzEngineStringData(pR)
	StzEngineStringFree(pR)
	StzEngineStringFree(pH)
	return _c_

  #------------------------------------------------------#
 #  PADDING, CENTERING, CAPITALIZING                    #
#------------------------------------------------------#

func StzPadRight(cText, nWidth)
	return StzPadRightXT(cText, nWidth, " ")

	func PadRight(cText, nWidth)
		return StzPadRight(cText, nWidth)

func StzPadRightXT(text, width, _c_)
	pStr = StzEngineString("" + text)
	pResult = StzEngineStringLjust(pStr, width, _c_)
	_cResult_ = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return _cResult_

	func PadRightXT(text, width, _c_)
		return StzPadRightXT(text, width, _c_)

func StzPadLeft(cText, nWidth)
	return StzPadLeftXT(cText, nWidth, " ")

	func PadLeft(cText, nWidth)
		return StzPadLeft(cText, nWidth)

func StzPadLeftXT(text, width, _c_)
	pStr = StzEngineString("" + text)
	pResult = StzEngineStringRjust(pStr, width, _c_)
	_cResult_ = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return _cResult_

	func PadLeftXT(text, width, _c_)
		return StzPadLeftXT(text, width, _c_)

func StzCenter(text, width)
	pStr = StzEngineString("" + text)
	pResult = StzEngineStringCenterPad(pStr, width, " ")
	_cResult_ = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return _cResult_

	func Center(text, width)
		return StzCenter(text, width)

func StzCapitalize(str)
	if len(str) = 0 return str ok
	pStr = StzEngineString(str)
	pResult = StzEngineStringCapitalizeFirst(pStr)
	_cResult_ = StzEngineStringData(pResult)
	StzEngineStringFree(pResult)
	StzEngineStringFree(pStr)
	return _cResult_

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

func StzReplaceCS(_cStr_, cSubStr, cNewSubStr, bCaseSensitive)
	if CheckParams()
		if NOT ( isString(_cStr_) and isString(cSubStr) and isString(cNewSubStr) )
			StzRaise("Incorrect params types! cStr, cSubStr, and cNewSubStr must all be strings.")
		ok
	ok

	if _cStr_ = "" or cSubStr = ''
		return _cStr_
	ok

	_bCase_ = CaseSensitive(bCaseSensitive)

	# Use Engine for codepoint-safe replace
	pStr = StzEngineString(_cStr_)
	StzEngineStringReplaceCS(pStr, cSubStr, cNewSubStr, _bCase_)

	_cResult_ = StzEngineStringData(pStr)
	StzEngineStringFree(pStr)
	return _cResult_

	#< @FunctionAlternativeForms

	func @ReplaceCS(_cStr_, cSubStr, cNewSubStr, bCaseSensitive)
		return StzReplaceCS(_cStr_, cSubStr, cNewSubStr, bCaseSensitive)

	func ReplaceCS(str, cSubStr, cNewSubStr, bCaseSensitive)
		return StzReplaceCS(_cStr_, cSubStr, cNewSubStr, bCaseSensitive)

	#>

func StzReplace(_cStr_, cSubStr, cNewSubStr)
	return StzReplaceCS(_cStr_, cSubStr, cNewSubStr, 1)

	func @Replace(_cStr_, cSubStr, cNewSubStr)
		return StzReplace(_cStr_, cSubStr, cNewSubStr)

	func Replace(_cStr_, cSubStr, cNewSubStr)
		return StzReplace(_cStr_, cSubStr, cNewSubStr)

  #------------------------------------------------------#
 #  SPLIT (delegates to Core layer StkSplit)            #
#------------------------------------------------------#

func StzSplitCS(_cStr_, cSubStr, bCaseSensitive)
	return StkSplitCS(_cStr_, cSubStr, bCaseSensitive)

func StzSplit(_cStr_, cSubStr)
	return StkSplit(_cStr_, cSubStr)


#-- Global _ListCopy helper (was previously only a method on stzString).
func _ListCopy(paList)
	if NOT isList(paList) return paList ok
	_aR_ = []
	_nL_ = len(paList)
	for _i_ = 1 to _nL_
		_aR_ + paList[_i_]
	next
	return _aR_
