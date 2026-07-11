

# Returns the softanza object related to the type of p
func StzQ(p)

	_oResult_ = AFalseObject()

	if isString(p)
		_oResult_ = new stzString(p)

	but isNumber(p)
		_oResult_ = new stzNumber(p)

	but isList(p)
		_oResult_ = new stzList(p)

	but isObject(p)
		_oResult_ = new stzObject(p)
	ok

	return _oResult_

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

func StzQC(p)
	if isObject(p)
		# an stz object: clone THROUGH the content -- a fresh object
		# gets a fresh engine handle
		_vQc_ = p.Content()
		if isList(_vQc_)
			_aQc_ = _vQc_    # Ring copies lists on assignment
			return StzQ(_aQc_)
		ok
		return StzQ(_vQc_)
	ok
	if isList(p)
		_aQc_ = p            # Ring copies lists on assignment
		return StzQ(_aQc_)
	ok
	# numbers and strings are copied by Ring naturally
	return StzQ(p)

	func QC(p)
		return StzQC(p)

	func @QC(p)
		return StzQC(p)

func StzQH(p)
	#TODO // Review the code of all functions where loops are used
	# on the main object and modify it many times

	#~> // Use a copy on which the loop is used and then update
	# the main object in on UpdateWith() call

	# Turn history-keeping ON; the first history-aware fluent op opens
	# the stream with its pre-op (initial) value, and every such op
	# appends its result (see _StzHistoOpen / _StzHistoAdd).
	StzKeepHistoryON()

	return StzQ(p)

# History snapshots at the PUBLIC fluent-op boundary (per-op values,
# not the internal per-step Updates). _StzHistoOpen records the pre-op
# value once per stream (History() consumes and clears the stream);
# _StzHistoAdd records each op's result.
func _StzHistoOpen(v)
	if StzKeepingHistory() = 1 and len(_aHisto) = 0
		_aHisto + v
	ok

func _StzHistoAdd(v)
	if StzKeepingHistory() = 1
		_aHisto + v
	ok

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

	_aTempList_ = Stz(cType, paMethodAndFilter[1])
	_cCondition_ = Q(paMethodAndFilter[2][2]).
			ReplaceCSQ("@Method", "@Item", 0).
			Content()

	_aResult_ = QRT(_aTempList_, :stzListOfStrings).StringsW(_cCondition_)

	return _aResult_

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

	_cInfo_ = pInfo

	if NOT @BothAreStrings(cType, :And = _cInfo_)
		StzRaise("Incorrect params type! Botht cType and cInfo must be strings.")
	ok

	_cClass_ = 'stz' + cType

	if NOT Q(_cClass_).IsStzClassName()
		StzRaise("Incorrect param! cType must be a valid softanza type.")
	ok

	_oEmptyObject_ = Empty(_cClass_)

	switch _cInfo_
	on :Class
		return _cClass_

	on :ClassName
		return _cClass_

	on :Methods
		return methods(_oEmptyObject_)

	on :Attributes
		return attributes(_oEmptyObject_)

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

		_oParam_ = new stzString(p)

		# QQ elevates a string to its most-specific STRING-FAMILY type. A single
		# char is one -> stzChar, checked FIRST: "3" is a single char, so QQ("3")
		# is stzChar (NOT stzNumber -- converting "3" the STRING to 3 the NUMBER is
		# a coercion, StzN()/ToStzNumber()'s job, not a Q-elevation).
		if _oParam_.IsChar() or _oParam_.IsHexUnicode()
			return new stzChar(p)

		# NOTE: these two still COERCE to non-string types (stzNumber / stzList),
		# which strictly should be stzNumberInString / stzListInString -- but those
		# classes don't exist yet. Kept as-is (option 1) until they land; then a
		# multi-char "19" -> stzNumberInString, "[1,2,3]" -> stzListInString.
		but _oParam_.IsNumberInString()
			return new stzNumber(p)

		but _oParam_.IsListInString()
			return new stzList(StzL(p))

		but StzIsDate(p)
			return new stzDate(p)

		ok

		# stzText hasn't been ported yet -- fall back to stzString so
		# narrative chains like QQ("Ⓜ").IsCircledNumber() still resolve
		# on the string surface.
		return new stzString(p)

	but isList(p)

		_oQTemp_ = StzQ(p)

		# QQ = the FIRST LOGICAL secondary type. A list of chars is a list of
		# STRINGS here (chars are single-char strings) -> stzListOfStrings; the
		# more specific stzListOfChars is QQQ's job, not QQ's.
		if _oQTemp_.IsListOfNumbers()
			return new stzListOfNumbers(p)

		but _oQTemp_.IsListOfStrings()
			return new stzListOfStrings(p)

		but _oQTemp_.IsListOfHashLists()
			return new stzListOfHashLists(p)

		but _oQTemp_.IsListOfPairs()
			return new stzListOfPairs(p)

		but _oQTemp_.IsListOfLists()
			return new stzListOfLists(p)

		else
			return new stzList(p)
		ok

	else
		return StzQ(p)
	ok

	func QQ(p)
		return StzQQ(p)

# QQQ = the MOST SPECIFIC type the content maps to. Past QQ's stzListOfStrings,
# a list resolves further by what the items ACTUALLY are -- today the reliably
# structurally-detectable refinement is chars -> stzListOfChars (a proper
# IsListOfDates/Bytes/Words/Regex predicate would extend this). For non-lists it
# falls back to StzQQ (whose string branch already detects char/date/number).
# NOTE: for SOLID code where the content could be ambiguous, prefer the explicit
# QRT(p, :stzExactType) over relying on QQQ's auto-detection.
func StzQQQ(p)
	if isList(p)

		_oQTemp_ = StzQ(p)

		if _oQTemp_.IsListOfNumbers()
			return new stzListOfNumbers(p)

		but _oQTemp_.IsListOfChars()
			return new stzListOfChars(p)

		but _oQTemp_.IsListOfStrings()
			return new stzListOfStrings(p)

		but _oQTemp_.IsListOfHashLists()
			return new stzListOfHashLists(p)

		but _oQTemp_.IsListOfPairs()
			return new stzListOfPairs(p)

		but _oQTemp_.IsListOfLists()
			return new stzListOfLists(p)

		else
			return new stzList(p)
		ok

	else
		return StzQQ(p)
	ok

	func QQQ(p)
		return StzQQQ(p)

#---

func StzN(p)
	if isNumber(p)
		return p

	but isString(p)

		_oParam_ = StzQ(p)

		if _oParam_.IsNumberInString()
			return 0+ p

		but _oParam_.IsListInString()
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

	_aResult_ = []
	_nLen_ = len(p)
	for _i_ = 1 to _nLen_
		_bFound_ = 0
		_nResLen_ = len(_aResult_)
		for j = 1 to _nResLen_
			if BothAreEqualCS(_aResult_[j], p[_i_], pCaseSensitive)
				_bFound_ = 1
				exit
			ok
		next
		if NOT _bFound_
			_aResult_ + p[_i_]
		ok
	next
	return _aResult_

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

		# 1. A range expression like  "A" : "E"  /  "v1" : "v3"  /  1.02 : 1.05
		#    (eval-free, codepoint- and decimal-aware).

		_aRange_ = StzParseRange(p)
		if isList(_aRange_)
			return _aRange_
		ok

		# 2. A Ring list literal written inside the string, e.g. "[ 1, 2, 3 ]"

		if StzStringQ(p).IsListInString()
			return StzStringQ(p).ToList()
		ok

		# 3. Fallback: split the string into its characters (codepoint-safe)

		_aResult_ = []
		_nLen_ = StzLen(p)
		for _i_ = 1 to _nLen_
			_aResult_ + StzMid(p, _i_, 1)
		next
		return _aResult_

	but isObject(p)
		return StzObject(p).ObjectAttributesAndValues()

	but isNumber(p)
		_aResult_ = []
		for _i_ = 1 to p
			_aResult_ + ""
		next

		return _aResult_

	else
		StzRaise("Incorrect param! Can't tranform param to list.")
	ok

	func L(p)
		return StzL(p)

	func StzLQ(p)
		return new stzList(StzL(p))

	func LQ(p)
		return StzLQ(p)

#--- RANGE EXPRESSION PARSER (eval-free) for L() / StzL()

# Expands a textual range "lhs : rhs" into the list it denotes. Returns
# NULL (not a list) when the string is not a recognizable range, so the
# caller can fall through to its other interpretations. Supports:
#   "A" : "E"          -> codepoint char range  [ "A", "B", "C", "D", "E" ]
#   "v1" : "v3"        -> numbered tokens        [ "v1", "v2", "v3" ]   (any prefix, incl. multibyte)
#   1 : 5              -> integer range
#   1.02 : 1.05        -> real range at the endpoints' decimal granularity
# It is codepoint-correct (multibyte prefixes/chars preserved) and never
# uses Ring's byte-oriented substr on the inner content.

func StzParseRange(pcStr)

	_cStr_ = ring_trim(pcStr)
	_nLen_ = ring_len(_cStr_)
	if _nLen_ = 0
		return NULL
	ok

	# Locate the top-level ':' separator (not inside a double-quoted token).
	# ':' and '"' are ASCII single bytes, and every byte of a multibyte
	# UTF-8 char is >= 0x80, so a raw byte scan is safe here.

	_nColon_ = 0
	_bInQuote_ = 0
	for _i_ = 1 to _nLen_
		_c_ = _cStr_[_i_]
		if _c_ = '"'
			if _bInQuote_ = 0 _bInQuote_ = 1 else _bInQuote_ = 0 ok
		but _c_ = ':' and _bInQuote_ = 0
			_nColon_ = _i_
			exit
		ok
	next

	if _nColon_ = 0
		return NULL
	ok

	_cLhs_ = ring_trim( ring_left(_cStr_, _nColon_ - 1) )
	_cRhs_ = ring_trim( ring_right(_cStr_, _nLen_ - _nColon_) )

	if ring_len(_cLhs_) = 0 or ring_len(_cRhs_) = 0
		return NULL
	ok

	_bLhsQuoted_ = _IsQuotedToken(_cLhs_)
	_bRhsQuoted_ = _IsQuotedToken(_cRhs_)

	# --- Both sides are quoted string tokens ---

	if _bLhsQuoted_ and _bRhsQuoted_

		_cA_ = _Unquote(_cLhs_)
		_cB_ = _Unquote(_cRhs_)

		# Single codepoint on each side -> char range
		if StzLen(_cA_) = 1 and StzLen(_cB_) = 1
			return StzCharsBetween(_cA_, _cB_)
		ok

		# Numbered tokens: shared prefix + trailing integer
		_aA_ = _SplitTrailingDigits(_cA_)
		_aB_ = _SplitTrailingDigits(_cB_)
		if _aA_[2] != "" and _aB_[2] != "" and _aA_[1] = _aB_[1]
			_anNums_ = NumbersBetween(0 + _aA_[2], 0 + _aB_[2])
			_aResult_ = []
			_nN_ = len(_anNums_)
			for _i_ = 1 to _nN_
				_aResult_ + ( _aA_[1] + _anNums_[_i_] )
			next
			return _aResult_
		ok

		return NULL
	ok

	# --- Both sides are unquoted -> numeric range ---

	if (not _bLhsQuoted_) and (not _bRhsQuoted_) and
	   _IsNumericToken(_cLhs_) and _IsNumericToken(_cRhs_)

		_nDec_ = Max([ _DecimalsOf(_cLhs_), _DecimalsOf(_cRhs_) ])

		if _nDec_ = 0
			return NumbersBetween(0 + _cLhs_, 0 + _cRhs_)
		ok

		_nFactor_ = pow(10, _nDec_)
		_nStart_ = floor( (0 + _cLhs_) * _nFactor_ + 0.5 )
		if (0 + _cLhs_) < 0
			_nStart_ = ceil( (0 + _cLhs_) * _nFactor_ - 0.5 )
		ok
		_nEnd_ = floor( (0 + _cRhs_) * _nFactor_ + 0.5 )
		if (0 + _cRhs_) < 0
			_nEnd_ = ceil( (0 + _cRhs_) * _nFactor_ - 0.5 )
		ok

		_nStep_ = 1
		if _nStart_ > _nEnd_ _nStep_ = -1 ok

		_aResult_ = []
		for _k_ = _nStart_ to _nEnd_ step _nStep_
			_aResult_ + ( _k_ / _nFactor_ )
		next
		return _aResult_
	ok

	return NULL

#--- range-parser local helpers

func _IsQuotedToken(_c_)
	n = ring_len(_c_)
	if n >= 2 and _c_[1] = '"' and _c_[n] = '"'
		return TRUE
	ok
	return FALSE

func _Unquote(_c_)
	n = ring_len(_c_)
	if n >= 2 and _c_[1] = '"' and _c_[n] = '"'
		return ring_substr2(_c_, 2, n - 2)   # n-2 inner bytes between the ASCII quotes; multibyte kept intact
	ok
	return _c_

# Returns [ prefix, trailingDigitsAsString ]. Digits are ASCII so a
# backward byte scan stops cleanly at the first non-digit byte, leaving
# any multibyte prefix untouched.
func _SplitTrailingDigits(_c_)
	n = ring_len(_c_)
	_nCut_ = n
	while _nCut_ >= 1
		_k_ = ascii(_c_[_nCut_])
		if _k_ >= 48 and _k_ <= 57   # ASCII '0'..'9'
			_nCut_--
		else
			exit
		ok
	end
	if _nCut_ = n
		return [ _c_, "" ]
	ok
	_cPrefix_ = ""
	if _nCut_ >= 1 _cPrefix_ = ring_left(_c_, _nCut_) ok
	_cDigits_ = ring_right(_c_, n - _nCut_)
	return [ _cPrefix_, _cDigits_ ]

func _IsNumericToken(_c_)
	n = ring_len(_c_)
	if n = 0 return FALSE ok
	_i_ = 1
	if _c_[1] = "-" or _c_[1] = "+"
		_i_ = 2
	ok
	if _i_ > n return FALSE ok
	_bDigitSeen_ = FALSE
	_bDotSeen_ = FALSE
	while _i_ <= n
		_k_ = ascii(_c_[_i_])
		if _k_ >= 48 and _k_ <= 57   # ASCII '0'..'9'
			_bDigitSeen_ = TRUE
		but _k_ = 46               # ASCII '.'
			if _bDotSeen_ return FALSE ok
			_bDotSeen_ = TRUE
		else
			return FALSE
		ok
		_i_++
	end
	return _bDigitSeen_

func _DecimalsOf(_c_)
	_nDot_ = ring_substr1(_c_, ".")
	if _nDot_ = 0
		return 0
	ok
	return ring_len(_c_) - _nDot_

#---

func StzLN(p)

	if  IsPair(p) and
	    IsPair(p[1]) and IsPair(p[2]) and
	    isString(p[1][1]) and isString(p[2][1]) and
	    p[1][1] = :From and p[2][1] = :To and
	    isNumber(p[1][2]) and isNumber(p[2][2])

		return NumbersBetween(p[1][2], p[2][2])

	but isList(p)
		_aResult_ = []
		_nLen_ = len(p)
		for _i_ = 1 to _nLen_
			if isNumber(p[_i_])
				_aResult_ + p[_i_]
			ok
		next
		return _aResult_

	but isString(p) and StzQ(p).IsListInString()
		_aResult_ = StzQ(p).ToListQ().OnlyNumbers()
		return _aResult_

	but isNumber(p)
		_aResult_ = []
		for _i_ = 1 to p
			_aResult_ + 0
		next
		return _aResult_
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
		_aResult_ = []
		_nLen_ = len(p)
		for _i_ = 1 to _nLen_
			if isString(p[_i_]) and len(p[_i_]) = 1
				_aResult_ + p[_i_]
			ok
		next
		return _aResult_

	but isString(p) and StzQ(p).IsListInString()
		_aResult_ = StzQ(p).ToListQ().OnlyChars()
		return _aResult_

	but isNumber(p)
		_aResult_ = []
		for _i_ = 1 to p
			_aResult_ + ""
		next
		return _aResult_

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
		_aResult_ = []
		_nLen_ = len(p)
		for _i_ = 1 to _nLen_
			if isList(p[_i_])
				_aResult_ + p[_i_]
			ok
		next
		return _aResult_

	but isString(p) and StzQ(p).IsListInString()
		_aResult_ = StzQ(p).ToListQ().OnlyLists()
		return _aResult_

	but isNumber(p)
		_aResult_ = []
		for _i_ = 1 to p
			_aResult_ + []
		next
		return _aResult_

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
		_aResult_ = []
		_nLen_ = len(p)
		for _i_ = 1 to _nLen_
			if isString(p[_i_])
				_aResult_ + p[_i_]
			ok
		next
		return _aResult_

	but isString(p) and StzQ(p).IsListInString()
		_aResult_ = StzQ(p).ToListQ().OnlyStrings()
		return _aResult_

	but isNumber(p)
		_aResult_ = []
		for _i_ = 1 to p
			_aResult_ + ""
		next
		return _aResult_

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

	_aResult_ = [:Where, cCode]
	return _aResult_

	func W(cCode)
		return StzWhere(cCode)

	func Where(cCode)
		return StzWhere(cCode)

func StzWhereXT(cCode)
	if NOT isString(cCode)
		StzRaise("Incorrect param type! cCode must be a string.")
	ok

	_aResult_ = [:WhereXT, cCode]
	return _aResult_

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
	_cJoined_ = ""
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
		if isString(paList[_i_])
			_cJoined_ += paList[_i_]
		but isNumber(paList[_i_])
			_cJoined_ += "" + paList[_i_]
		ok
	next
	return _cJoined_

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

func StzSubStr(_cStr_, _nStart_, _nLen_)
	if NOT isString(_cStr_)
		StzRaise("StzSubStr: cStr must be a string")
	ok
	if NOT (isNumber(_nStart_) and isNumber(_nLen_))
		StzRaise("StzSubStr: nStart and nLen must be numbers")
	ok
	if _nLen_ <= 0 or _nStart_ < 1
		return ""
	ok
	return StzMid(_cStr_, _nStart_, _nLen_)

	func JoinXT(paList, pcSep)
		if NOT isList(paList)
			StzRaise("JoinXT: paList must be a list")
		ok
		if NOT isString(pcSep)
			StzRaise("JoinXT: pcSep must be a string")
		ok
		_cJoinedSep_ = ""
		_nLn_ = len(paList)
		for _i_ = 1 to _nLn_
			if isString(paList[_i_])
				_cJoinedSep_ += paList[_i_]
			but isNumber(paList[_i_])
				_cJoinedSep_ += "" + paList[_i_]
			ok
			if _i_ < _nLn_
				_cJoinedSep_ += pcSep
			ok
		next
		return _cJoinedSep_

# CenterText: pad cText so it occupies nWidth visible columns, with
# the text centered (extra space biased to the right when nWidth is
# even and the remainder is odd). Used by the pivot-table-show
# row-rendering helper.
func CenterText(cText, nWidth)
	if NOT (isString(cText) and isNumber(nWidth)) return cText ok
	if nWidth < 1 return "" ok
	# Visible columns = codepoint count, not bytes; byte len()/left() over-
	# counted and could split a multibyte char ('café' is 4 cols, 5 bytes).
	_nLen_ = StzLen(cText)
	if _nLen_ >= nWidth
		return StzLeft(cText, nWidth)
	ok
	_nLeft_ = floor((nWidth - _nLen_) / 2)
	_nRight_ = nWidth - _nLen_ - _nLeft_
	_cOut_ = ""
	for _i_ = 1 to _nLeft_
		_cOut_ += " "
	next
	_cOut_ += cText
	for _i_ = 1 to _nRight_
		_cOut_ += " "
	next
	return _cOut_
