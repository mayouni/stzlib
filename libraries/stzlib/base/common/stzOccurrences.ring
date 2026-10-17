
func StzOccurrenceQ(panOccurr, pcSubStr, pcStr)
	return new stzOccurrences(panOccurr, pcSubStr, pcStr)

# Carries the positions where a substring occurs in a string, and cuts, replaces or recases the text at them.
#
# The object holds three things: the positions (codepoint positions, counted from 1), the substring that
# was searched and the string it was searched in. Removed, ReplacedWithCS, Uppercased and Lowercased each
# answer a NEW text and leave the object unchanged. A position counts only where the text really holds the
# substring (a stale position is skipped, so nothing is cut at the wrong place), and positions that
# overlap are taken left to right without overlap, the way Remove and Replace of stzString treat
# "aa" in "aaaa". An empty substring has nothing to act on: the string comes back unchanged.
#
#   receiver   o1 = new stzOccurrences([ 2, 4 ], "an", "banana")
#   example    ? o1.Removed()
#              #--> ba
#              ? o1.Uppercased()
#              #--> bANANa
#   see        stzString, stzItem
class stzOccurrences from stzObject
	@anOccurrences
	@cSubStr
	@cStr

	# Stores the positions where a substring occurs in a string, together with the substring and the string.
	#
	#   panOccurr   the positions found, as a list of numbers
	#   pcSubStr    the substring that was searched, or the named form :Of = '...'
	#   pcStr       the string that was searched, or the named form :In = '...'
	#   returns     nothing; the object is built
	#   note        checked with plain texts and with the :Of and :In named forms; SubString and
	#               String answer the two texts afterwards
	#   see         Occurrences
	def init(panOccurr, pcSubStr, pcStr)
		if isList(pcSubStr) and Q(pcSubStr).IsOfOrOfSubStringNamedParam()
			pcSubStr = pcSubStr[2]
		ok

		if isList(pcStr) and Q(pcStr).IsInOrInStringNamedParam()
			pcStr = pcStr[2]
		ok

		@anOccurrences = panOccurr
		@cSubStr = pcSubStr
		@cStr = pcStr

	# Returns the list of positions given at construction, unchanged.
	#
	#   returns    a list of numbers
	#   see        SubString, String
	def Occurrences()
		return @anOccurrences

		def Content()
			return This.Occurrences()

		# Returns the list of positions given at construction, as the call with the other name does.
		#
		#   returns    a list of numbers
		#   see        Occurrences
		def Value()
			return Content()

	# Returns the substring that was searched, as given at construction.
	#
	#   returns    a text; the plain text even when the object was built with the named form :Of = '...'
	#   see        String, init
	def SubString()
		return @cSubStr

		def SubStringQ()
			return new stzString(This.SubString())

	# Returns the string that was searched, as given at construction.
	#
	#   returns    a text; the plain text even when the object was built with the named form :In = '...'
	#   see        SubString, init
	def String()
		return @cStr

		def StringQ()
			return new stzString(This.String())

	#--

	# Returns the positions that really hold the substring, left to right and without overlap.
	#
	#   pCaseSensitive   1 to compare the text at a position to the substring letter by letter, 0 to
	#                    ignore case
	#   returns          a sorted list of positions: numbers inside the string, listed once, whose text
	#                    equals the substring, each starting after the end of the previous one
	#   note             an empty substring has no hit; a position that does not fit is skipped
	#   see              Occurrences
	def ValidOccurrencesCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_aHits_ = []
		_nSubLen_ = StzLen(@cSubStr)
		if _nSubLen_ = 0 or NOT isList(@anOccurrences)
			return _aHits_
		ok

		_nStrLen_ = StzLen(@cStr)
		_aNums_ = []
		_nAll_ = ring_len(@anOccurrences)
		for _i_ = 1 to _nAll_
			if isNumber(@anOccurrences[_i_])
				_aNums_ + @anOccurrences[_i_]
			ok
		next
		_aNums_ = sort(_aNums_)

		_cWanted_ = @cSubStr
		if NOT _bCase_
			_cWanted_ = StzLower(@cSubStr)
		ok

		_nFree_ = 1
		_nNums_ = ring_len(_aNums_)
		for _i_ = 1 to _nNums_
			_nPos_ = _aNums_[_i_]
			if _nPos_ < _nFree_ or _nPos_ != floor(_nPos_) or _nPos_ + _nSubLen_ - 1 > _nStrLen_
				loop
			ok
			_cSeg_ = StzMid(@cStr, _nPos_, _nSubLen_)
			if NOT _bCase_
				_cSeg_ = StzLower(_cSeg_)
			ok
			if strcmp(_cSeg_, _cWanted_) = 0
				_aHits_ + _nPos_
				_nFree_ = _nPos_ + _nSubLen_
			ok
		next

		return _aHits_

	# Returns the string with the text at each hit changed: dropped, replaced, upper-cased or lower-cased.
	#
	#   paHits     the positions to act on, as ValidOccurrencesCS answers them
	#   pcMode     "remove", "replace", "upper" or "lower"
	#   pcNew      the text put instead, used by the mode "replace" only
	#   returns    a text; the characters between the hits are copied as they are
	#   see        ValidOccurrencesCS
	def RebuiltWith(paHits, pcMode, pcNew)
		_nSubLen_ = StzLen(@cSubStr)
		_cOut_ = ""
		_nCursor_ = 1
		_nHits_ = ring_len(paHits)
		for _i_ = 1 to _nHits_
			_nPos_ = paHits[_i_]
			if _nPos_ > _nCursor_
				_cOut_ = _cOut_ + StzMid(@cStr, _nCursor_, _nPos_ - _nCursor_)
			ok
			_cSeg_ = StzMid(@cStr, _nPos_, _nSubLen_)
			if strcmp(pcMode, "replace") = 0
				_cOut_ = _cOut_ + pcNew
			but strcmp(pcMode, "upper") = 0
				_cOut_ = _cOut_ + StzUpper(_cSeg_)
			but strcmp(pcMode, "lower") = 0
				_cOut_ = _cOut_ + StzLower(_cSeg_)
			ok
			_nCursor_ = _nPos_ + _nSubLen_
		next
		_cOut_ = _cOut_ + StzMidToEnd(@cStr, _nCursor_)
		return _cOut_

	# Returns the string with the substring cut out at every occurrence, the case flag deciding what matches.
	#
	#   pCaseSensitive   1 to cut only where the text equals the substring letter by letter, 0 to
	#                    ignore case
	#   returns          a new text; the object and its string are unchanged. With no occurrence, or an
	#                    empty substring, it is the string itself
	#   note             overlapping positions are cut left to right without overlap: "aa" at 1, 2 and
	#                    3 in "aaaa" leaves an empty text, as Remove("aa") does on the string
	#   see              Removed, ReplacedWithCS
	def RemovedCS(pCaseSensitive)
		return This.RebuiltWith(This.ValidOccurrencesCS(pCaseSensitive), "remove", "")

	# Returns the string with the substring cut out at every occurrence, matching letter by letter.
	#
	#   returns    a new text; the object and its string are unchanged
	#   example    o1 = new stzOccurrences([ 2, 4 ], "an", "banana")
	#              ? o1.Removed()
	#              #--> ba
	#   see        RemovedCS
	def Removed()
		_nCs_ = 1
		return This.RemovedCS(_nCs_)

	# Returns the string with the text at every occurrence put instead by another, the case flag deciding what matches.
	#
	#   pcNew            the text to put instead; :With = text and :By = text are accepted
	#   pCaseSensitive   1 to replace only where the text equals the substring letter by letter, 0 to
	#                    ignore case
	#   returns          a new text; the object and its string are unchanged
	#   note             overlapping positions are taken left to right without overlap
	#   example          o1 = new stzOccurrences([ 2, 4 ], "an", "banana")
	#                    ? o1.ReplacedWithCS("XY", 1)
	#                    #--> bXYXYa
	#   see              ReplacedWith, RemovedCS
	def ReplacedWithCS(pcNew, pCaseSensitive)
		if isList(pcNew) and ring_len(pcNew) = 2 and isString(pcNew[1]) and
		   (strcmp(StzLower(pcNew[1]), "with") = 0 or strcmp(StzLower(pcNew[1]), "by") = 0)
			pcNew = pcNew[2]
		ok
		if NOT isString(pcNew)
			StzRaise("Incorrect param type! pcNew must be a string.")
		ok
		return This.RebuiltWith(This.ValidOccurrencesCS(pCaseSensitive), "replace", pcNew)

	# Returns the string with the text at every occurrence put instead by another, matching letter by letter.
	#
	#   pcNew      the text to put instead; :With = text and :By = text are accepted
	#   returns    a new text; the object and its string are unchanged
	#   see        ReplacedWithCS
	def ReplacedWith(pcNew)
		_nCs_ = 1
		return This.ReplacedWithCS(pcNew, _nCs_)

	# Returns the string with the text at every occurrence in capitals and the rest unchanged.
	#
	#   returns    a new text; the object and its string are unchanged. The capitals follow the
	#              Unicode rules, so an accented letter is capitalised and a German sharp s becomes SS
	#   note       a position whose text differs from the substring only by case still counts
	#   example    o1 = new stzOccurrences([ 2, 4 ], "an", "banana")
	#              ? o1.Uppercased()
	#              #--> bANANa
	#   see        Lowercased
	def Uppercased()
		_nCs_ = 0
		return This.RebuiltWith(This.ValidOccurrencesCS(_nCs_), "upper", "")

	# Returns the string with the text at every occurrence in small letters and the rest unchanged.
	#
	#   returns    a new text; the object and its string are unchanged
	#   note       a position whose text differs from the substring only by case still counts
	#   example    o1 = new stzOccurrences([ 2, 4 ], "AN", "bANANa")
	#              ? o1.Lowercased()
	#              #--> banana
	#   see        Uppercased
	def Lowercased()
		_nCs_ = 0
		return This.RebuiltWith(This.ValidOccurrencesCS(_nCs_), "lower", "")
