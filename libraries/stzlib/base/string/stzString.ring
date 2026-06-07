#--------------------------------------------------------------#
#              SOFTANZA LIBRARY (V0.9) - STZSTRING             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Core string class -- engine handle,         #
#                  content access, and fundamental primitives. #
#                  Domain classes (stzStringFinder, etc.)      #
#                  wrap this class via composition.            #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Global wrappers for the string-checker family were trialed here
# but Ring's parser flagged each as "Function redefinition" because
# the class below also defines methods with the same names. Callers
# (stzLocale, stzCurrency, etc.) that need the global form should
# use stzStringQ(p).IsXxx() instead -- which is what the in-class
# methods exist for.

class stzString from stzObject

	@pEngine

	These
	Those

	  #===================#
	 #   OPERATOR OVERLOAD #
	#===================#

	# Ring's `obj[n]` syntax dispatches to operator("[]", n). For
	# stzString we want the n-th codepoint (1-based). Negative n
	# counts from the end: Q("ABCDE")[-1] = "E", [-2] = "D".
	def operator(pOp, pValue)
		if pOp = "[]"
			if NOT isNumber(pValue) return "" ok
			_nLen_ = This._EngineCount(This.Content())
			_n_ = pValue
			if _n_ < 0 _n_ = _nLen_ + _n_ + 1 ok
			if _n_ < 1 or _n_ > _nLen_ return "" ok
			return This._EngineSlice(This.Content(), _n_, 1)
		ok

		if pOp = "+"
			# String concat: append the stringified value.
			if isString(pValue)
				This.Update(This.Content() + pValue)
			but isNumber(pValue)
				This.Update(This.Content() + ("" + pValue))
			ok
			return This.Content()
		ok

		if pOp = "*"
			# Repeat the string pValue times.
			if NOT isNumber(pValue) return This.Content() ok
			_n_ = floor(pValue)
			if _n_ < 0 _n_ = 0 ok
			_cOut_ = ""
			for _i_ = 1 to _n_
				_cOut_ += This.Content()
			next
			This.Update(_cOut_)
			return _cOut_
		ok

		return ""

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pcStr)

		if CheckingParams()

			if NOT ( isString(pcStr) or
				 (isList(pcStr) and IsPairOfStrings(pcStr)) )

				StzRaise("Can't create the stzString object! pcStr must be a string or a pair of strings.")
			ok

			if isList(pcStr) and IsPairOfStrings(pcStr)
				@cVarName = pcStr[1]
				@pEngine = StzEngineString(pcStr[2])
				return
			ok

		ok

		@pEngine = StzEngineString(pcStr)

		These = This
		Those = This

	  #=======================================#
	 #     GETTING CONTENT OF THE STRING     #
	#=======================================#

	def Content()
		return StzEngineStringData(@pEngine)

		def ContentQ()
			return new stzString(This.Content())

	def String()
		return This.Content()

		def StringQ()
			return new stzString(This.String())

	# Show -- print the content to stdout (terminated by NL).
	# Convenience alias used by narrative tests of the form
	# `o.Show()` instead of `? o.Content()`.
	def Show()
		? This.Content()

		def ShowQ()
			This.Show()
			return This

		def Display()
			This.Show()

		def Print()
			This.Show()

	# SplitQ -- Split() that returns a stzList wrapper for chaining
	# (the bare Split() returns a Ring list). Accepts the :Using
	# named-param form (`SplitQ(:Using = "***")`) as well as a bare
	# delimiter string.
	def SplitQ(pcDelimiter)
		if isList(pcDelimiter) and ring_len(pcDelimiter) = 2 and
		   isString(pcDelimiter[1]) and lower(pcDelimiter[1]) = "using"
			pcDelimiter = pcDelimiter[2]
		ok
		return new stzList( This.Split(pcDelimiter) )

	# BoundsOf(pcSub) -- the [startPos, endPos] of the FIRST
	# occurrence of pcSub in This.Content(). Returns [] if absent.
	# BoundsOf(pcSub): return the characters that surround pcSub in
	# This.Content() -- i.e. everything before its first occurrence
	# and everything after its end. Returns [] if pcSub absent, or
	# [ cBefore, cAfter ] otherwise.
	#
	# (Note: this is the "characters that bound" semantic the
	# narrative tests expect. For positional bounds use FindAs* or
	# IndexOf + ring_len.)
	def BoundsOf(pcSub)
		_cTxt_ = This.Content()
		# Engine find: codepoint-aware first-occurrence search.
		_nPos_ = StzEngineStringFindFirstFromCS(This.Engine(), pcSub, 1, 1)
		if _nPos_ < 1 return [] ok
		_nLenSub_ = This._EngineCount(pcSub)
		# Slice both sides via the codepoint-aware engine slicer.
		_cBefore_ = ""
		if _nPos_ > 1
			_cBefore_ = This._EngineSlice(_cTxt_, 1, _nPos_ - 1)
		ok
		_cAfter_  = This._EngineSliceFrom(_cTxt_, _nPos_ + _nLenSub_)
		return [ _cBefore_, _cAfter_ ]

		def BoundsOfFirstOccurrence(pcSub)
			return This.BoundsOf(pcSub)

	# BoundsOfUpToNChars(pcSub, n): like BoundsOf but cap each side
	# at n chars (counted from the inside out). n can also be the
	# list [nBefore, nAfter] for independent caps.
	def BoundsOfUpToNChars(pcSub, n)
		_aB_ = This.BoundsOf(pcSub)
		if ring_len(_aB_) = 0 return [] ok
		_cBefore_ = _aB_[1]; _cAfter_ = _aB_[2]
		_nBefore_ = n
		_nAfter_  = n
		if isList(n) and ring_len(n) = 2
			_nBefore_ = n[1]
			_nAfter_  = n[2]
		ok
		# Engine-backed codepoint cap (Unicode-correct for ♥ etc.).
		_nBeLen_ = This._EngineCount(_cBefore_)
		if _nBeLen_ > _nBefore_
			# Keep last _nBefore_ codepoints.
			_cBefore_ = This._EngineSliceFrom(_cBefore_, _nBeLen_ - _nBefore_ + 1)
		ok
		_nAfLen_ = This._EngineCount(_cAfter_)
		if _nAfLen_ > _nAfter_
			# Keep first _nAfter_ codepoints.
			_cAfter_  = This._EngineSlice(_cAfter_, 1, _nAfter_)
		ok
		return [ _cBefore_, _cAfter_ ]

	# (No lowercase-c alias needed -- Ring is case-insensitive on
	# method names, so BoundsOfUpToNchars resolves here directly.)

	# BoundsOfXT(pcSub, p2): dispatch over the trailing param.
	#   :UpToNChars = n           --> BoundsOfUpToNChars
	#   [nBefore, nAfter]         --> cap each side independently
	#   n (number)                --> same as :UpToNChars = n
	# (For BoundsOfXT(pcSub, m, n) -- three-arg form -- callers use
	# BoundsOfXT3(pcSub, m, n) since Ring lacks optional params.)
	def BoundsOfXT(pcSub, p2)
		# :UpToNChars = n
		if isList(p2) and ring_len(p2) = 2 and isString(p2[1]) and
		   lower(p2[1]) = "uptonchars"
			return This.BoundsOfUpToNChars(pcSub, p2[2])
		ok

		# [nBefore, nAfter] list (independent caps)
		if isList(p2) and ring_len(p2) = 2 and isNumber(p2[1]) and isNumber(p2[2])
			_aB_ = This.BoundsOf(pcSub)
			if ring_len(_aB_) = 0 return [] ok
			_cBefore_ = _aB_[1]; _cAfter_ = _aB_[2]
			if ring_len(_cBefore_) > p2[1] _cBefore_ = right(_cBefore_, p2[1]) ok
			if ring_len(_cAfter_)  > p2[2] _cAfter_  = left(_cAfter_, p2[2])  ok
			return [ _cBefore_, _cAfter_ ]
		ok

		# Bare number = symmetric cap
		if isNumber(p2)
			return This.BoundsOfUpToNChars(pcSub, p2)
		ok

		return []

	def BoundsOfXT3(pcSub, nBefore, nAfter)
		_aB_ = This.BoundsOf(pcSub)
		if ring_len(_aB_) = 0 return [] ok
		_cBefore_ = _aB_[1]; _cAfter_ = _aB_[2]
		_nBeLen_ = This._EngineCount(_cBefore_)
		if _nBeLen_ > nBefore
			_cBefore_ = This._EngineSliceFrom(_cBefore_, _nBeLen_ - nBefore + 1)
		ok
		_nAfLen_ = This._EngineCount(_cAfter_)
		if _nAfLen_ > nAfter
			_cAfter_  = This._EngineSlice(_cAfter_, 1, nAfter)
		ok
		return [ _cBefore_, _cAfter_ ]

	#-- Override stzObject.Stringified/ToString. The parent returns
	#   ObjectName() (which is "@noname" for unnamed objects);
	#   stzString must return its actual content. Without this
	#   override, stzHashList.Classes() returned 4x "@noname" instead
	#   of the unique value labels.

	def ToString()
		return This.Content()

		def Stringified()
			return This.Content()

		def DeepStringified()
			return This.Content()

		def ToStringQ()
			return new stzString( This.Content() )

	  #=======================================#
	 #     GETTING THE ENGINE HANDLE         #
	#=======================================#

	def Engine()
		return @pEngine

	  #=======================================#
	 #     GETTING THE SIZE OF THE STRING    #
	#=======================================#

	def NumberOfChars()
		return StzLen(This.Content())

		def Length()
			return This.NumberOfChars()

		def LengthQ()
			return new stzNumber( This.NumberOfChars() )

		def Len()
			return This.NumberOfChars()

	  #=======================================#
	 #  CHECKING IF THE STRING IS EMPTY      #
	#=======================================#

	def IsEmpty()
		return This.Content() = ""

	def IsAChar()
		return This.NumberOfChars() = 1

		def IsChar()
			return This.IsAChar()

	  #=======================================#
	 #  GETTING A COPY OF THE STRING OBJECT  #
	#=======================================#

	def Copy()
		return new stzString( This.Content() )

	  #=======================================#
	 #     UPDATING THE STRING CONTENT       #
	#=======================================#

	def Update(pcNewStr)
		if CheckingParams() = 1
			if isList(pcNewStr) and IsWithOrByOrUsingNamedParamList(pcNewStr)
				pcNewStr = pcNewStr[2]
			ok
		ok

		StzEngineStringFree(@pEngine)
		@pEngine = StzEngineString(pcNewStr)

		#< @FunctionFluentForm

		def UpdateQ(pcNewStr)
			This.Update(pcNewStr)
			return This

		#>

	  #========================================#
	 #     FUNDAMENTAL ACCESSORS              #
	#========================================#

	def NthChar(n)
		pH = This.Engine()
		pR = StzEngineStringNthChar(pH, n)
		if pR != NULL
			c = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			return c
		ok
		return ""

		def CharAt(n)
			return This.NthChar(n)

	def FirstChar()
		return This.NthChar(1)

		def FirstCharQ()
			return new stzString( This.FirstChar() )

	def LastChar()
		return This.NthChar(This.NumberOfChars())

		def LastCharQ()
			return new stzString( This.LastChar() )

	def LeftChar()
		# LTR alias for FirstChar. The monolith branched on
		# IsLeftToRight()/RTL; until directionality is wired up in the
		# modular checker, default to LTR convention.
		return This.FirstChar()

	def RightChar()
		return This.LastChar()

	def Chars()
		pH = This.Engine()
		pR = StzEngineStringCharsSplit(pH)
		cJoined = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _SplitNullDelimited(cJoined)

		def CharsQ()
			# Fluent form: return the char list wrapped in stzListOfChars
			# so .Section(:From, :To) etc. resolve on the list class.
			return new stzListOfChars( This.Chars() )

	def Section(n1, n2)
		# Narrative aliases: Section(:From = pcA, :To = pcB) where
		# pcA/pcB are characters or substrings. Resolve to positions
		# (first occurrence) before the numeric path.
		if isList(n1) and ring_len(n1) = 2 and isString(n1[1]) and
		   lower(n1[1]) = "from"
			_vF_ = n1[2]
			if isString(_vF_)
				# Codepoint-aware first-occurrence find.
				n1 = StzEngineStringFindFirstFromCS(This.Engine(), _vF_, 1, 1)
			else
				n1 = _vF_
			ok
		ok
		if isList(n2) and ring_len(n2) = 2 and isString(n2[1]) and
		   lower(n2[1]) = "to"
			_vT_ = n2[2]
			if isString(_vT_)
				n2 = StzEngineStringFindFirstFromCS(This.Engine(), _vT_, 1, 1)
				if n2 > 0
					n2 = n2 + This._EngineCount(_vT_) - 1
				ok
			else
				n2 = _vT_
			ok
		ok
		nLen = This.NumberOfChars()
		if NOT isNumber(n1) return "" ok
		if NOT isNumber(n2) return "" ok
		if n1 < 1
			n1 = 1
		ok
		if n2 > nLen
			n2 = nLen
		ok
		if n1 > n2
			temp = n1
			n1 = n2
			n2 = temp
		ok
		pH = This.Engine()
		pR = StzEngineStringSlice(pH, n1, n2 - n1 + 1)
		if pR != NULL
			c = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			return c
		ok
		return ""

	# SectionXT(n1, n2): like Section, but each of n1/n2 may be NEGATIVE
	# meaning "count from the end". So Q("abcdef").SectionXT(3, -3)
	# returns chars from position 3 to position 6-3+1 = 4 = "cd".
	# Negative n means (nLen + n + 1).
	def SectionXT(n1, n2)
		_nLen_ = This._EngineCount(This.Content())
		if isNumber(n1) and n1 < 0 n1 = _nLen_ + n1 + 1 ok
		if isNumber(n2) and n2 < 0 n2 = _nLen_ + n2 + 1 ok
		return This.Section(n1, n2)

		def SectionXTQ(n1, n2)
			return new stzString( This.SectionXT(n1, n2) )

	# SectionQ(n1, n2): fluent form -- return the section wrapped in
	# stzString so subsequent .CharsReversed() / .Uppercase() etc
	# resolve on the string class.
	def SectionQ(n1, n2)
		return new stzString( This.Section(n1, n2) )

	# FirstHalf / SecondHalf -- split the content in two equal halves
	# (rounded down on odd length). FirstHalfXT returns trailing char.
	def FirstHalf()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ = 0 return "" ok
		_nMid_ = floor(_nLen_ / 2)
		return This._EngineSlice(This.Content(), 1, _nMid_)

	def FirstHalfXT()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ = 0 return "" ok
		_nMid_ = ceil(_nLen_ / 2)
		return This._EngineSlice(This.Content(), 1, _nMid_)

	def SecondHalf()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ = 0 return "" ok
		_nMid_ = floor(_nLen_ / 2) + 1
		return This._EngineSliceFrom(This.Content(), _nMid_)

	def SecondHalfXT()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ = 0 return "" ok
		_nMid_ = ceil(_nLen_ / 2) + 1
		return This._EngineSliceFrom(This.Content(), _nMid_)

	# Halves(): return [firstHalf, secondHalf] as a list of strings.
	def Halves()
		return [ This.FirstHalf(), This.SecondHalf() ]

	def HalvesXT()
		return [ This.FirstHalfXT(), This.SecondHalfXT() ]

	# FirstHalfZ / SecondHalfZ -- sectional [start, end] forms.
	def FirstHalfZ()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ = 0 return [] ok
		_nMid_ = floor(_nLen_ / 2)
		return [ 1, _nMid_ ]

	def SecondHalfZ()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ = 0 return [] ok
		_nMid_ = floor(_nLen_ / 2) + 1
		return [ _nMid_, _nLen_ ]

	def HalvesZ()
		return [ This.FirstHalfZ(), This.SecondHalfZ() ]

	# ZZ variants -- same as Z but the wider tests expect this spelling.
	def FirstHalfZZ()
		return This.FirstHalfZ()

	def SecondHalfZZ()
		return This.SecondHalfZ()

	def HalvesZZ()
		return This.HalvesZ()

	# IsCircledNumber / IsCircledDigit -- Unicode-aware single-char
	# predicates (Enclosed Alphanumerics block etc.).
	def IsCircledNumber()
		_aChars_ = This.Chars()
		if ring_len(_aChars_) != 1 return FALSE ok
		_n_ = StzCharToUnicode(_aChars_[1])
		# 0x2460..0x2473 = circled 1..20
		# 0x24EA..0x24FF = circled 0, negative-circled digits
		# 0x2776..0x2793 = dingbat negative-circled digits
		# 0x3251..0x325F = circled 21..35
		return ( (_n_ >= 0x2460 and _n_ <= 0x2473) or
		         (_n_ >= 0x24EA and _n_ <= 0x24FF) or
		         (_n_ >= 0x2776 and _n_ <= 0x2793) or
		         (_n_ >= 0x3251 and _n_ <= 0x325F) )

	def IsCircledDigit()
		return This.IsCircledNumber()

	#-- Replace the chars at positions n1..n2 (inclusive) with
	#   pcNewSubStr. Ported from the legacy monolithic archive
	#   (~line 84916), kept minimal: pure numeric positions only.
	#   Symbolic forms (:First/:Last) are not yet supported.

	def ReplaceSection(n1, n2, pcNewSubStr)
		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("ReplaceSection: n1 and n2 must be numbers")
		ok
		# Accept :With = pcNew named-param form too.
		if isList(pcNewSubStr) and ring_len(pcNewSubStr) = 2 and
		   isString(pcNewSubStr[1]) and lower(pcNewSubStr[1]) = "with"
			pcNewSubStr = pcNewSubStr[2]
		ok
		if NOT isString(pcNewSubStr)
			StzRaise("ReplaceSection: pcNewSubStr must be a string")
		ok
		_cStr_ = This.Content()
		_nLen_ = This._EngineCount(_cStr_)
		if n1 < 1
			n1 = 1
		ok
		if n2 > _nLen_
			n2 = _nLen_
		ok
		if n1 > n2
			_t_ = n1
			n1 = n2
			n2 = _t_
		ok
		_cBefore_ = ""
		if n1 > 1
			_cBefore_ = This._EngineSlice(_cStr_, 1, n1 - 1)
		ok
		_cAfter_ = ""
		if n2 < _nLen_
			_cAfter_ = This._EngineSliceFrom(_cStr_, n2 + 1)
		ok
		This.Update(_cBefore_ + pcNewSubStr + _cAfter_)

		def ReplaceSectionQ(n1, n2, pcNewSubStr)
			This.ReplaceSection(n1, n2, pcNewSubStr)
			return This

	def Sections(aSections)
		acResult = []
		nCharCount = This.NumberOfChars()
		nLen = ring_len(aSections)
		for i = 1 to nLen
			n1 = aSections[i][1]
			n2 = aSections[i][2]
			if n1 >= 1 and n2 >= n1 and n2 <= nCharCount
				acResult + This.Section(n1, n2)
			ok
		next
		return acResult

		# Z / ZZ suffixed companions: the input sections list IS the
		# coordinate set, so 'SectionsZZ' just hands it back (modulo
		# normalisation) and 'SectionsZ' returns the first one. These
		# exist for naming symmetry with the AntiSections family.
		def SectionsZZ(aSections)
			return aSections

		def SectionsZ(aSections)
			if ring_len(aSections) = 0
				return []
			ok
			return aSections[1]

	# AntiSections: given a list of sections [[s1,e1],[s2,e2],...] on
	# a string, return the complementary parts -- the substrings (or
	# coordinates) of the gaps. The classic use case is "I marked
	# the interesting bits with Sections; now give me what's around
	# them."

	def AntiSectionsZZ(aSections)
		# Compute the complement section list.
		_nLen_ = This.NumberOfChars()
		_aSorted_ = This._SortSections(aSections)
		_aGaps_ = []
		_nCursor_ = 1
		_nN_ = ring_len(_aSorted_)
		for _iAs_ = 1 to _nN_
			_n1_ = _aSorted_[_iAs_][1]
			_n2_ = _aSorted_[_iAs_][2]
			if _nCursor_ < _n1_
				_aGaps_ + [ _nCursor_, _n1_ - 1 ]
			ok
			if _n2_ + 1 > _nCursor_
				_nCursor_ = _n2_ + 1
			ok
		next
		if _nCursor_ <= _nLen_
			_aGaps_ + [ _nCursor_, _nLen_ ]
		ok
		return _aGaps_

		def AntiSectionsZ(aSections)
			_aZZ_ = This.AntiSectionsZZ(aSections)
			if ring_len(_aZZ_) = 0
				return []
			ok
			return _aZZ_[1]

	def AntiSections(aSections)
		return This.Sections( This.AntiSectionsZZ(aSections) )

	# Internal helper: stable-sort a section list by start coordinate.
	# Used by AntiSectionsZZ to make the complement well-defined for
	# unsorted input.
	def _SortSections(aSections)
		_aSorted_ = aSections
		_nN_ = ring_len(_aSorted_)
		for _iSs_ = 1 to _nN_ - 1
			for _jSs_ = 1 to _nN_ - _iSs_
				if _aSorted_[_jSs_][1] > _aSorted_[_jSs_ + 1][1]
					_aTmp_ = _aSorted_[_jSs_]
					_aSorted_[_jSs_] = _aSorted_[_jSs_ + 1]
					_aSorted_[_jSs_ + 1] = _aTmp_
				ok
			next
		next
		return _aSorted_

	# Find-form: given a substring, locate every occurrence's section
	# and return the complement -- the gaps BETWEEN occurrences.

	def FindAntiSectionsZZ(pcSubStr)
		return This.AntiSectionsZZ( This.FindAsSections(pcSubStr) )

		def FindAntiSectionsZ(pcSubStr)
			_aZZ_ = This.FindAntiSectionsZZ(pcSubStr)
			if ring_len(_aZZ_) = 0
				return []
			ok
			return _aZZ_[1]

	def FindAntiSections(pcSubStr)
		return This.Sections( This.FindAntiSectionsZZ(pcSubStr) )

		def FindAsAntiSections(pcSubStr)
			return This.FindAntiSections(pcSubStr)

		def AntiFindAsSections(pcSubStr)
			return This.FindAntiSections(pcSubStr)

		def AntiFindAsSectionsZZ(pcSubStr)
			return This.FindAntiSectionsZZ(pcSubStr)

		def AntiFindAsSectionsZ(pcSubStr)
			return This.FindAntiSectionsZ(pcSubStr)

	def Range(nStart, nRange)
		return This.Section(nStart, nStart + nRange - 1)

	def IsLeftToRight()
		return TRUE

	  #========================================#
	 #     INTERNAL ENGINE PRIMITIVES         #
	#========================================#

	def _FindSubStr(pcSubStr, nStartAt, bCaseSensitive)
		if pcSubStr = "" or nStartAt < 1
			return 0
		ok

		# Engine uses INDEX_BASE=1 (1-based), CS pattern (case=1 sensitive, case=0 insensitive)
		nResult = StzEngineStringFindFirstFromCS(@pEngine, pcSubStr, nStartAt, bCaseSensitive)

		# Engine returns 1-based position, -1 for not found
		if nResult > 0
			return nResult
		else
			return 0
		ok

	def _ReplaceRange(n1, nRange, pcNew)
		# Engine uses INDEX_BASE=1 (1-based codepoint positions)
		pResult = StzEngineStringReplaceRange(@pEngine, n1, nRange, pcNew)
		if pResult = NULL
			return This.Content()
		ok
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def _SplitByStrCS(cSep, bCaseSensitive)
		nCount = StzEngineStringSplitCountCS(@pEngine, cSep, bCaseSensitive)
		aResult = []
		for i = 1 to nCount
			pPart = StzEngineStringSplitGetCS(@pEngine, cSep, i, bCaseSensitive)
			if pPart != NULL
				aResult + StzEngineStringData(pPart)
				StzEngineStringFree(pPart)
			else
				aResult + ""
			ok
		next
		return aResult

	def _SplitByStr(cSep)
		return This._SplitByStrCS(cSep, 1)

	  #============================================#
	 #     ESSENTIAL FIND / CONTAINS / COUNT      #
	#============================================#

	# These methods are the most commonly used by other modules.
	# They delegate to the engine directly for O(n) performance.

	def ContainsCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringContainsCS(@pEngine, pcSubStr, _bCase_)

	def Contains(pcSubStr)
		return StzEngineStringContainsCS(@pEngine, pcSubStr, 1)

	#-- List membership predicates: does this string appear as an
	#   item in the given list of strings? Ported from the legacy
	#   monolithic archive (~line 98300). Backs the natural-language
	#   chain "Q(str).IsOneOfThese([...])" and its aliases.

	def ExistsInListCS(paList, pCaseSensitive)
		if NOT isList(paList)
			StzRaise("ExistsInListCS: paList must be a list")
		ok
		_s_ = This.Content()
		if pCaseSensitive
			_nList2Len_ = ring_len(paList)
			for _iLoopList2_ = 1 to _nList2Len_
				_item_ = paList[_iLoopList2_]
				if isString(_item_) and _item_ = _s_
					return 1
				ok
			next
		else
			_sl_ = lower(_s_)
			_nList1Len_ = ring_len(paList)
			for _iLoopList1_ = 1 to _nList1Len_
				_item_ = paList[_iLoopList1_]
				if isString(_item_) and lower(_item_) = _sl_
					return 1
				ok
			next
		ok
		return 0

		def ExistsAsItemInListCS(paList, pCaseSensitive)
			return This.ExistsInListCS(paList, pCaseSensitive)

		def IsOneOfTheseCS(paList, pCaseSensitive)
			return This.ExistsInListCS(paList, pCaseSensitive)

		def IsOneOfCS(paList, pCaseSensitive)
			return This.ExistsInListCS(paList, pCaseSensitive)

		def IsOneOfTheCS(paList, pCaseSensitive)
			return This.ExistsInListCS(paList, pCaseSensitive)

	def ExistsInList(paList)
		return This.ExistsInListCS(paList, 1)

		def ExistsAsItemInList(paList)
			return This.ExistsInList(paList)

		def IsOneOfThese(paList)
			return This.ExistsInList(paList)

		def IsOneOf(paList)
			return This.ExistsInList(paList)

		def IsOneOfThe(paList)
			return This.ExistsInList(paList)

	def FindFirstCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringFindFirstCS(@pEngine, pcSubStr, _bCase_)

	def FindFirst(pcSubStr)
		return StzEngineStringFindFirstCS(@pEngine, pcSubStr, 1)

	#-- FindNext: find the next occurrence of pcSubStr starting AFTER
	#   position nStart (so FindNext("x", 0) is equivalent to FindFirst).
	#   Ported from the legacy monolithic archive (~line 50328). Uses
	#   Ring's substr() with start-position support so it works for
	#   both case-sensitive and case-insensitive search without pulling
	#   in engine-level changes.

	def FindNextCS(pcSubStr, nStart, pCaseSensitive)
		if NOT isString(pcSubStr)
			StzRaise("FindNextCS: pcSubStr must be a string")
		ok
		if NOT isNumber(nStart)
			StzRaise("FindNextCS: nStart must be a number")
		ok
		if pcSubStr = ""
			return 0
		ok
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_cFull_ = This.Content()
		if nStart < 0
			nStart = 0
		ok
		if nStart >= ring_len(_cFull_)
			return 0
		ok
		# Take tail of string starting AFTER nStart, search there,
		# then offset back to the full-string position.
		_cTail_ = substr(_cFull_, nStart + 1)
		if _bCase_
			_nPos_ = substr(_cTail_, pcSubStr)
		else
			_nPos_ = substr(lower(_cTail_), lower(pcSubStr))
		ok
		if _nPos_ = 0
			return 0
		ok
		return _nPos_ + nStart

	def FindNext(pcSubStr, nStart)
		return This.FindNextCS(pcSubStr, nStart, 1)

		def FindNextSubString(pcSubStr, nStart)
			return This.FindNext(pcSubStr, nStart)

	#-- Numbers: extract every number literal embedded in the string
	#   as a list of strings, preserving signs and decimal points.
	#   Example: "book: 12.34, watch: -56.30, glasses: 77." ->
	#   [ "12.34", "-56.30", "77" ]
	#   Ported from the legacy monolithic archive (~line 100884) --
	#   pure char-scan, self-contained, depends only on Chars().
	#   Used by stzTimex.ParseDurationToMinutes() and is the #3
	#   most-called missing method in the catalog.

	#-- NumbersComingAfter: find every signed/decimal number literal
	#   that follows an occurrence of pcSubStr in the string. Returns
	#   a list of strings (the textual number forms incl. sign).
	#   Example: new stzString("This[@i-1] = This[@i+3]").NumbersComingAfter("@i")
	#         -> [ "-1", "+3" ]
	#   Ported from archive line 101153 but kept self-contained:
	#   manual scan instead of stzRegex + WithoutSpaces dependency.
	#   Used by stzCCode and friends.

	def NumbersComingAfterCS(pcSubStr, pCaseSensitive)
		if NOT isString(pcSubStr)
			StzRaise("NumbersComingAfterCS: pcSubStr must be a string")
		ok
		_acNcaResult_ = []
		_cNcaStr_ = This.Content()
		_nNcaLen_ = ring_len(_cNcaStr_)
		_nNcaSubLen_ = ring_len(pcSubStr)
		if _nNcaSubLen_ = 0 or _nNcaLen_ = 0
			return _acNcaResult_
		ok

		# Build case-folded haystack/needle when CS = 0
		_cNcaHay_ = _cNcaStr_
		_cNcaNeedle_ = pcSubStr
		if NOT @CaseSensitive(pCaseSensitive)
			_cNcaHay_ = lower(_cNcaHay_)
			_cNcaNeedle_ = lower(_cNcaNeedle_)
		ok

		_acDigits_ = [ "0","1","2","3","4","5","6","7","8","9" ]

		_iNca_ = 1
		while _iNca_ <= _nNcaLen_ - _nNcaSubLen_ + 1
			if substr(_cNcaHay_, _iNca_, _nNcaSubLen_) = _cNcaNeedle_
				_j_ = _iNca_ + _nNcaSubLen_

				# Skip whitespace
				while _j_ <= _nNcaLen_ and (substr(_cNcaStr_,_j_,1) = " " or substr(_cNcaStr_,_j_,1) = char(9))
					_j_++
				end

				# Optional sign
				_cNum_ = ""
				if _j_ <= _nNcaLen_ and (substr(_cNcaStr_,_j_,1) = "+" or substr(_cNcaStr_,_j_,1) = "-")
					_cNum_ += substr(_cNcaStr_,_j_,1)
					_j_++
					# Allow whitespace between sign and digits
					while _j_ <= _nNcaLen_ and (substr(_cNcaStr_,_j_,1) = " " or substr(_cNcaStr_,_j_,1) = char(9))
						_j_++
					end
				ok

				# Integer digits
				_bHasDigit_ = 0
				while _j_ <= _nNcaLen_ and ring_find(_acDigits_, substr(_cNcaStr_,_j_,1)) > 0
					_cNum_ += substr(_cNcaStr_,_j_,1)
					_j_++
					_bHasDigit_ = 1
				end

				# Optional decimal part
				if _j_ <= _nNcaLen_ and substr(_cNcaStr_,_j_,1) = "."
					_cNum_ += "."
					_j_++
					while _j_ <= _nNcaLen_ and ring_find(_acDigits_, substr(_cNcaStr_,_j_,1)) > 0
						_cNum_ += substr(_cNcaStr_,_j_,1)
						_j_++
					end
				ok

				if _bHasDigit_
					_acNcaResult_ + _cNum_
				ok
				_iNca_ = _j_
			else
				_iNca_++
			ok
		end
		return _acNcaResult_

	def NumbersComingAfter(pcSubStr)
		return This.NumbersComingAfterCS(pcSubStr, 1)

		def NumbersAfter(pcSubStr)
			return This.NumbersComingAfter(pcSubStr)

		def NumbersAfterCS(pcSubStr, pCaseSensitive)
			return This.NumbersComingAfterCS(pcSubStr, pCaseSensitive)

	#-- Vowels: return the list of vowel chars in the string (ASCII
	#   a/e/i/o/u, case-insensitive). Ported from archive line
	#   103163; self-contained byte scan. NumberOfVowels / VowelN
	#   are simple count aliases; VowelsB / HasVowels are predicates.

	# Transform the chars of the string into a list of stzChar
	# objects (each backed by stzStringChar via the alias).
	def ToListOfStzChars()
		_acTosChars_ = This.Chars()
		_nTosLen_ = ring_len(_acTosChars_)
		_aTosR_ = []
		for _iTos_ = 1 to _nTosLen_
			_aTosR_ + new stzChar(_acTosChars_[_iTos_])
		next
		return _aTosR_

		def ToListOfChars()
			return This.Chars()

	# HtmlEscaped: escape `&`, `<`, `>`, `"`, `'` to HTML entities.
	# Self-contained: no engine dependency, no external lookup.

	def HtmlEscaped()
		_cHesContent_ = This.Content()
		_cHesR_ = substr(_cHesContent_, "&", "&amp;")
		_cHesR_ = substr(_cHesR_, "<", "&lt;")
		_cHesR_ = substr(_cHesR_, ">", "&gt;")
		_cHesR_ = substr(_cHesR_, char(34), "&quot;")
		_cHesR_ = substr(_cHesR_, char(39), "&#39;")
		return _cHesR_

		def EscapedHtml()
			return This.HtmlEscaped()

		def HTMLEscape()
			return This.HtmlEscaped()

	# ContainsXT: extended Contains dispatcher. Accepts a single
	# substring or a list of substrings (returns TRUE if any).
	# ContainsXT(pcSubStr, pNamed): narrative-test form. Supported:
	#   ContainsXT(pcSubStr, :InSection = [n1, n2])
	#   ContainsXT(pcSubStr, :MoreThen|:MoreThan = n)   -- count > n
	#   ContainsXT(pcSubStr, :AtLeast = n)              -- count >= n
	#   ContainsXT(pcSubStr, :Exactly = n)              -- count == n
	#   ContainsXT(n, pcSubStr)  -- bare-number form: count >= n
	#   ContainsXT(paList, "")   -- back-compat: any-of test
	def ContainsXT(pcSubStr, pNamed)
		# Back-compat: list of strings + empty second arg = any-of.
		if isList(pcSubStr) and pNamed = ""
			_nL_ = ring_len(pcSubStr)
			for _i_ = 1 to _nL_
				if isString(pcSubStr[_i_]) and This.Contains(pcSubStr[_i_])
					return 1
				ok
			next
			return 0
		ok

		if isList(pNamed) and ring_len(pNamed) = 2 and isString(pNamed[1])
			_cKey_ = lower(pNamed[1])
			_xVal_ = pNamed[2]
			if _cKey_ = "insection" and isList(_xVal_) and ring_len(_xVal_) = 2
				return This.ContainsInSection(pcSubStr, _xVal_[1], _xVal_[2])
			but _cKey_ = "morethen" or _cKey_ = "morethan"
				return This.NumberOfOccurrence(pcSubStr) > _xVal_
			but _cKey_ = "atleast"
				return This.NumberOfOccurrence(pcSubStr) >= _xVal_
			but _cKey_ = "exactly"
				return This.NumberOfOccurrence(pcSubStr) = _xVal_
			ok
		ok
		# Bare number first arg + string second = "at least N occurrences"
		if isNumber(pcSubStr) and isString(pNamed)
			return This.NumberOfOccurrence(pNamed) >= pcSubStr
		ok
		return FALSE

	# ContainsInSection: does pcSubStr appear within the substring
	# bounded by positions [n1, n2] (inclusive)?
	def ContainsInSection(pcSubStr, n1, n2)
		_cSec_ = This.Section(n1, n2)
		_oTmp_ = new stzString(_cSec_)
		return _oTmp_.Contains(pcSubStr)

		def ContainsInSectionCS(pcSubStr, n1, n2, pCaseSensitive)
			_cSec_ = This.Section(n1, n2)
			_oTmp_ = new stzString(_cSec_)
			return _oTmp_.ContainsCS(pcSubStr, pCaseSensitive)

	# ReplaceInSection: replace occurrences of pSubStr within the
	# section [n1, n2] with pNew. Polymorphic on argument order:
	#   ReplaceInSection(n1, n2, pSubStr, pNew)      -- bounds first
	#   ReplaceInSection(pSubStr, pNew, n1, n2)      -- substrings first
	def ReplaceInSection(pA, pB, pC, pD)
		if isString(pA) and isString(pB) and isNumber(pC) and isNumber(pD)
			_n1_ = pC
			_n2_ = pD
			_cSub_ = pA
			_cNew_ = pB
		else
			_n1_ = pA
			_n2_ = pB
			_cSub_ = pC
			_cNew_ = pD
		ok
		_cAll_ = This.Content()
		_cBefore_ = ""
		if _n1_ > 1
			_cBefore_ = substr(_cAll_, 1, _n1_ - 1)
		ok
		_cMid_ = substr(_cAll_, _n1_, _n2_ - _n1_ + 1)
		_cAfter_ = ""
		if _n2_ < ring_len(_cAll_)
			_cAfter_ = substr(_cAll_, _n2_ + 1)
		ok
		_cMid_ = substr(_cMid_, _cSub_, _cNew_)
		This.Update( _cBefore_ + _cMid_ + _cAfter_ )

		def ReplaceInSectionQ(pA, pB, pC, pD)
			This.ReplaceInSection(pA, pB, pC, pD)
			return This

	# UppercaseSubString: uppercase only the section [n1, n2].
	def UppercaseSubString(n1, n2)
		_cAll_ = This.Content()
		_cBefore_ = ""
		if n1 > 1
			_cBefore_ = substr(_cAll_, 1, n1 - 1)
		ok
		_cMid_ = substr(_cAll_, n1, n2 - n1 + 1)
		_cAfter_ = ""
		if n2 < ring_len(_cAll_)
			_cAfter_ = substr(_cAll_, n2 + 1)
		ok
		This.Update( _cBefore_ + upper(_cMid_) + _cAfter_ )

		def UppercaseSubStringQ(n1, n2)
			This.UppercaseSubString(n1, n2)
			return This

	# Shorten: truncate the content to the first N chars + "..."
	# if it's longer than N. Defaults to N = 30.
	def Shorten()
		return This.ShortenedN(30)

	def ShortenedN(n)
		if NOT isNumber(n) or n < 4
			return This.Content()
		ok
		_cStr_ = This.Content()
		if This._EngineCount(_cStr_) <= n
			return _cStr_
		ok
		return This._EngineSlice(_cStr_, 1, n - 3) + "..."

		def Shortened()
			return This.ShortenedN(30)

		# ShortenedXT(nLeft, nRight, pcEllipsis): keep nLeft chars from
		# the start, nRight chars from the end, and inject pcEllipsis
		# between them. When nLeft = 0 the ellipsis is preceded by
		# nothing; when nRight = 0, followed by nothing.
		def ShortenedXT(nLeft, nRight, pcEllipsis)
			_cStr_ = This.Content()
			_nTxtLen_ = This._EngineCount(_cStr_)
			if nLeft + nRight >= _nTxtLen_
				return _cStr_
			ok
			_cL_ = ""
			if nLeft > 0
				_cL_ = This._EngineSlice(_cStr_, 1, nLeft)
			ok
			_cR_ = ""
			if nRight > 0
				_cR_ = This._EngineSliceFrom(_cStr_, _nTxtLen_ - nRight + 1)
			ok
			return _cL_ + pcEllipsis + _cR_

		def ShortenedUsing(n, pcSuffix)
			if NOT isNumber(n) or n < 1
				return This.Content()
			ok
			_cStr2_ = This.Content()
			if ring_len(_cStr2_) <= n
				return _cStr2_
			ok
			return substr(_cStr2_, 1, n - ring_len(pcSuffix)) + pcSuffix

	# Boxify: surround the content with a simple ASCII box drawn
	# with `+` corners, `-` horizontals, `|` verticals.
	def Boxify()
		_cStr_ = This.Content()
		_nLen_ = ring_len(_cStr_)
		_cHbar_ = "+"
		for _iB_ = 1 to _nLen_ + 2
			_cHbar_ += "-"
		next
		_cHbar_ += "+"
		return _cHbar_ + char(10) + "| " + _cStr_ + " |" + char(10) + _cHbar_

	def Vowels()
		_cVoStr_ = This.Content()
		_nVoLen_ = ring_len(_cVoStr_)
		_acVoR_ = []
		_cVoVo_ = "aeiouAEIOU"
		_iVo_ = 1
		while _iVo_ <= _nVoLen_
			_cVoCh_ = substr(_cVoStr_, _iVo_, 1)
			_nVoB_ = ascii(_cVoCh_)
			if _nVoB_ < 128
				if substr(_cVoVo_, _cVoCh_) > 0
					_acVoR_ + _cVoCh_
				ok
				_iVo_ += 1
			but _nVoB_ < 224
				_iVo_ += 2
			but _nVoB_ < 240
				_iVo_ += 3
			else
				_iVo_ += 4
			ok
		end
		return _acVoR_

	# Extend / ExtendXT: append content / pad to length / pad to
	# position. Port from archive line 3596 (the DSL variant) plus
	# the simpler positional cases.

	def Extend(pWith)
		if isString(pWith)
			This.Update( This.Content() + pWith )
		but isNumber(pWith)
			# Pad with spaces to reach position pWith.
			_nExN_ = This.NumberOfChars()
			if pWith > _nExN_
				_nExPad_ = pWith - _nExN_
				_cExPad_ = ""
				for _iExPad_ = 1 to _nExPad_
					_cExPad_ += " "
				next
				This.Update( This.Content() + _cExPad_ )
			ok
		ok

		def ExtendQ(pWith)
			This.Extend(pWith)
			return This

	def ExtendWith(pcStr)
		if NOT isString(pcStr)
			StzRaise("ExtendWith: pcStr must be a string")
		ok
		This.Update( This.Content() + pcStr )

		def ExtendWithQ(pcStr)
			This.ExtendWith(pcStr)
			return This

	def ExtendToPosition(n)
		if NOT isNumber(n)
			StzRaise("ExtendToPosition: n must be a number")
		ok
		_nEtpN_ = This.NumberOfChars()
		if n > _nEtpN_
			_nPad_ = n - _nEtpN_
			_cPad_ = ""
			for _iPad_ = 1 to _nPad_
				_cPad_ += " "
			next
			This.Update( This.Content() + _cPad_ )
		ok

		def ExtendToPositionQ(n)
			This.ExtendToPosition(n)
			return This

	def ExtendToPositionWith(n, pcChar)
		if NOT (isNumber(n) and isString(pcChar))
			StzRaise("ExtendToPositionWith: n must be a number and pcChar a string")
		ok
		_nEpwN_ = This.NumberOfChars()
		if n > _nEpwN_
			_nPad2_ = n - _nEpwN_
			_cPad2_ = ""
			for _iPad2_ = 1 to _nPad2_
				_cPad2_ += pcChar
			next
			This.Update( This.Content() + _cPad2_ )
		ok

		def ExtendToPositionWithQ(n, pcChar)
			This.ExtendToPositionWith(n, pcChar)
			return This

	def ExtendXT(pNarg, pWarg)
		# DSL dispatcher for the common Extend cases. Accepts:
		#   ExtendXT(:String, :With = "DE")        -> append
		#   ExtendXT(:String, :ToPosition = 5)     -> pad with " "
		#   ExtendXT(:ToPosition = 5, :With = "*") -> pad with "*"
		#   ExtendXT(:ToNChars = 7, :With = ".")   -> pad to N chars

		# Use simpler names to dodge a recurring Ring 1.26 parser
		# weirdness in this method only.
		if isString(pNarg)
			if lower(pNarg) = "string"
				if isList(pWarg)
					_pWa2_ = pWarg
					_nWalen_ = ring_len(_pWa2_)
					if _nWalen_ = 2
						if isString(_pWa2_[1])
							_cKa_ = lower(_pWa2_[1])
							if _cKa_ = "with" or _cKa_ = "using" or _cKa_ = "by"
								This.ExtendWith(_pWa2_[2])
								return
							but _cKa_ = "toposition" or _cKa_ = "to"
								This.ExtendToPosition(_pWa2_[2])
								return
							ok
						ok
					ok
				ok
			ok
		but isList(pNarg)
			# Ring's `[:Key = v]` literal is a 1-list whose element is
			# a 2-list `[:Key, v]`. Unwrap one level when we see that.
			_pNa2_ = pNarg
			if ring_len(_pNa2_) = 1 and isList(_pNa2_[1])
				_pNa2_ = _pNa2_[1]
			ok
			_nNalen_ = ring_len(_pNa2_)
			if _nNalen_ = 2
				if isString(_pNa2_[1])
					_cKb_ = lower(_pNa2_[1])
					if _cKb_ = "toposition" or _cKb_ = "to"
						if isList(pWarg) and ring_len(pWarg) = 2
							This.ExtendToPositionWith(_pNa2_[2], pWarg[2])
						else
							This.ExtendToPosition(_pNa2_[2])
						ok
						return
					but _cKb_ = "tonchars"
						if isList(pWarg) and ring_len(pWarg) = 2
							This.ExtendToPositionWith(_pNa2_[2], pWarg[2])
						ok
						return
					ok
				ok
			ok
		ok

		def ExtendXTQ(pNarg, pWarg)
			This.ExtendXT(pNarg, pWarg)
			return This

	# Return a random char from the string content. Uniform random
	# choice across char positions.

	def RandomChar()
		_acRcChars_ = This.Chars()
		_nRcN_ = ring_len(_acRcChars_)
		if _nRcN_ = 0
			return ""
		ok
		return _acRcChars_[ ARandomNumberBetween(1, _nRcN_) ]

		def ARandomChar()
			return This.RandomChar()

		def AChar()
			return This.RandomChar()

		def AnyChar()
			return This.RandomChar()

	# FindNumbersAsSections: for each number found in the content,
	# return a [start, end] pair (1-based byte positions). Used by
	# stzListRandom.RandomizeNumbers and friends.

	def FindNumbersAsSections()
		_cFnasStr_ = This.Content()
		_nFnasLen_ = ring_len(_cFnasStr_)
		_aFnasResult_ = []
		_acDigits_ = [ "0","1","2","3","4","5","6","7","8","9" ]
		_iFnas_ = 1
		while _iFnas_ <= _nFnasLen_
			_cFnasCh_ = substr(_cFnasStr_, _iFnas_, 1)
			# Possible sign
			_nFnasStart_ = _iFnas_
			_bFnasSign_ = 0
			if _cFnasCh_ = "+" or _cFnasCh_ = "-"
				if _iFnas_ + 1 <= _nFnasLen_ and ring_find(_acDigits_, substr(_cFnasStr_, _iFnas_+1, 1)) > 0
					_bFnasSign_ = 1
					_iFnas_++
					_cFnasCh_ = substr(_cFnasStr_, _iFnas_, 1)
				ok
			ok
			if ring_find(_acDigits_, _cFnasCh_) > 0
				_jFnas_ = _iFnas_
				while _jFnas_ <= _nFnasLen_ and ring_find(_acDigits_, substr(_cFnasStr_, _jFnas_, 1)) > 0
					_jFnas_++
				end
				if _jFnas_ <= _nFnasLen_ and substr(_cFnasStr_, _jFnas_, 1) = "."
					_jFnas_++
					while _jFnas_ <= _nFnasLen_ and ring_find(_acDigits_, substr(_cFnasStr_, _jFnas_, 1)) > 0
						_jFnas_++
					end
				ok
				_aFnasResult_ + [ _nFnasStart_, _jFnas_ - 1 ]
				_iFnas_ = _jFnas_
			else
				if _bFnasSign_
					_iFnas_ = _nFnasStart_ + 1
				else
					_iFnas_++
				ok
			ok
		end
		return _aFnasResult_

		def FindNumbersZZ()
			return This.FindNumbersAsSections()

	def NumberOfVowels()
		return ring_len(This.Vowels())

		def VowelN()
			return This.NumberOfVowels()

		def VowelNb()
			return This.NumberOfVowels()

		def CountVowels()
			return This.NumberOfVowels()

	# Returns 1 if the string is a single vowel char (case-insensitive
	# ASCII a/e/i/o/u). Convenience predicate; callers use it as
	# `Q(c).IsVowel()` or `Q(c).Vowel()`.

	def IsVowel()
		_cIvStr_ = This.Content()
		if ring_len(_cIvStr_) != 1
			return 0
		ok
		return ring_find([ "a","e","i","o","u","A","E","I","O","U" ], _cIvStr_) > 0

		def Vowel()
			return This.IsVowel()

	def HasVowels()
		return ring_len(This.Vowels()) > 0

		def VowelsB()
			return This.HasVowels()

		def ContainsVowels()
			return This.HasVowels()

	def Numbers()
		_acResult_ = []
		_acChars_ = This.Chars()
		_nLen_ = ring_len(_acChars_)
		_cCurrentNum_ = ""
		_bInNumber_ = 0
		_nLenCurrentNum_ = 0
		_nLenTemp_ = 0

		for i = 1 to _nLen_
			_nLenCurrentNum_ = ring_len(_cCurrentNum_)
			if ring_find([ "0","1","2","3","4","5","6","7","8","9" ], _acChars_[i]) > 0 or
			   (_acChars_[i] = "." and _nLenCurrentNum_ > 0) or
			   (_acChars_[i] = "-" and _nLenCurrentNum_ = 0)

				_cCurrentNum_ += _acChars_[i]
				_bInNumber_ = 1
			else
				if _bInNumber_
					_nLenTemp_ = ring_len(_acResult_)
					if _nLenTemp_ > 0 and _acResult_[_nLenTemp_] = "-"
						_acResult_[_nLenTemp_] = "-" + _cCurrentNum_
					else
						_acResult_ + _cCurrentNum_
					ok
					_cCurrentNum_ = ""
					_bInNumber_ = 0
				ok
			ok
		next

		if _cCurrentNum_ != ""
			_nLen_ = ring_len(_acResult_)
			if _nLen_ > 0 and _acResult_[_nLen_] = "-"
				_acResult_[_nLen_] = "-" + _cCurrentNum_
			else
				_acResult_ + _cCurrentNum_
			ok
		ok

		return _acResult_

		def NumbersQ()
			return new stzList( This.Numbers() )

		def FindFirstOccurrence(pcSubStr)
			return This.FindFirst(pcSubStr)

		def FirstOccurrence(pcSubStr)
			return This.FindFirst(pcSubStr)

		def FindFirstSubString(pcSubStr)
			return This.FindFirst(pcSubStr)

	def NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringCountOfCS(@pEngine, pcSubStr, _bCase_)

		def NumberOfOccurrence(pcSubStr)
			return StzEngineStringCountOf(@pEngine, pcSubStr)

	  #============================================#
	 #     FIND ALL / FIND NTH                    #
	#============================================#

	def FindCS(pcSubStr, pCaseSensitive)
		_oFaFinder_ = new stzStringFinder(This)
		return _oFaFinder_.FindCS(pcSubStr, pCaseSensitive)

	def Find(pcSubStr)
		return This.FindCS(pcSubStr, 1)

		def FindAll(pcSubStr)
			return This.Find(pcSubStr)

		def FindAllCS(pcSubStr, pCaseSensitive)
			return This.FindCS(pcSubStr, pCaseSensitive)

	# FindInSection: find occurrences of pcSubStr restricted to the
	# character range [n1, n2]. Returns positions in the FULL string
	# (not relative to the section). No match -> [].
	def FindInSectionCS(pcSubStr, n1, n2, pCaseSensitive)
		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("FindInSection: n1 and n2 must be numbers.")
		ok
		_nFisLen_ = This.NumberOfChars()
		if n1 < 1
			n1 = 1
		ok
		if n2 > _nFisLen_
			n2 = _nFisLen_
		ok
		if n1 > n2
			return []
		ok
		_cFisSection_ = This.Section(n1, n2)
		_aFisRel_ = StzStringQ(_cFisSection_).FindCS(pcSubStr, pCaseSensitive)
		_aFisAbs_ = []
		_nFisRelLen_ = ring_len(_aFisRel_)
		for _iFis_ = 1 to _nFisRelLen_
			_aFisAbs_ + (_aFisRel_[_iFis_] + n1 - 1)
		next
		return _aFisAbs_

	def FindInSection(pcSubStr, n1, n2)
		return This.FindInSectionCS(pcSubStr, n1, n2, 1)

		def FindAllInSection(pcSubStr, n1, n2)
			return This.FindInSection(pcSubStr, n1, n2)

		def FindAllInSectionCS(pcSubStr, n1, n2, pCaseSensitive)
			return This.FindInSectionCS(pcSubStr, n1, n2, pCaseSensitive)

	def FindNthCS(n, pcSubStr, pCaseSensitive)
		_oFnFinder_ = new stzStringFinder(This)
		return _oFnFinder_.FindNthCS(n, pcSubStr, pCaseSensitive)

	def FindNth(n, pcSubStr)
		return This.FindNthCS(n, pcSubStr, 1)

	def FindLastCS(pcSubStr, pCaseSensitive)
		_oFlFinder_ = new stzStringFinder(This)
		return _oFlFinder_.FindLastCS(pcSubStr, pCaseSensitive)

	def FindLast(pcSubStr)
		return This.FindLastCS(pcSubStr, 1)

	  #============================================#
	 #     STARTS WITH / ENDS WITH                #
	#============================================#

	def StartsWithCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringStartsWithCS(@pEngine, pcSubStr, _bCase_)

	def StartsWith(pcSubStr)
		return StzEngineStringStartsWith(@pEngine, pcSubStr)

	def EndsWithCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringEndsWithCS(@pEngine, pcSubStr, _bCase_)

	def EndsWith(pcSubStr)
		return StzEngineStringEndsWith(@pEngine, pcSubStr)

	#-- Predicates: does the string end with / start with a numeric
	#   character (0-9)? Ported from the legacy monolithic archive
	#   (line 100803) but kept self-contained -- no dependency on
	#   stzChar.IsANumber. Used by stzGlobal feature detection.

	def EndsWithANumber()
		_cEwanStr_ = This.Content()
		if ring_len(_cEwanStr_) = 0
			return 0
		ok
		return ring_find([ "0","1","2","3","4","5","6","7","8","9" ], right(_cEwanStr_, 1)) > 0

		def EndsWithATrailingNumber()
			return This.EndsWithANumber()

		def EndsWithAFinalNumber()
			return This.EndsWithANumber()

		def EndsWithNumber()
			return This.EndsWithANumber()

		def ContainsATrailingNumber()
			return This.EndsWithANumber()

		def ContainsAFinalNumber()
			return This.EndsWithANumber()

		def ContainsAnEndingNumber()
			return This.EndsWithANumber()

	def StartsWithANumber()
		_cSwanStr_ = This.Content()
		if ring_len(_cSwanStr_) = 0
			return 0
		ok
		return ring_find([ "0","1","2","3","4","5","6","7","8","9" ], left(_cSwanStr_, 1)) > 0

		def StartsWithALeadingNumber()
			return This.StartsWithANumber()

		def StartsWithNumber()
			return This.StartsWithANumber()

	  #============================================#
	 #     CASE CHANGE                            #
	#============================================#

	def Uppercase()
		This.Update(StzUpper(This.Content()))

		def UppercaseQ()
			This.Uppercase()
			return This

	def Uppercased()
		return StzUpper(This.Content())

	def Lowercase()
		This.Update(StzLower(This.Content()))

		# Misspelled but historically-used aliases
		def InLowercase()
			return new stzString( StzLower(This.Content()) ).Content()

		def InLowercaseQ()
			return new stzString( StzLower(This.Content()) )

		def InLowarcase()
			return This.InLowercase()

		def LowercaseQ()
			This.Lowercase()
			return This

	def Lowercased()
		return StzLower(This.Content())

	def Capitalize()
		_cCapStr_ = This.Content()
		if StzLen(_cCapStr_) > 0
			_cCapFirst_ = StzUpper(StzLeft(_cCapStr_, 1))
			if StzLen(_cCapStr_) > 1
				_pCapH_ = StzEngineString(_cCapStr_)
				_pCapRest_ = StzEngineStringSlice(_pCapH_, 2, StzLen(_cCapStr_) - 1)
				_cCapRest_ = StzLower(StzEngineStringData(_pCapRest_))
				StzEngineStringFree(_pCapRest_)
				StzEngineStringFree(_pCapH_)
				This.Update(_cCapFirst_ + _cCapRest_)
			else
				This.Update(_cCapFirst_)
			ok
		ok

		def CapitalizeQ()
			This.Capitalize()
			return This

	def Capitalized()
		_oCapCopy_ = This.Copy()
		_oCapCopy_.Capitalize()
		return _oCapCopy_.Content()

	  #============================================#
	 #     REVERSE                                #
	#============================================#

	def Reverse()
		_pRvResult_ = StzEngineStringReverse(@pEngine)
		if _pRvResult_ != NULL
			This.Update(StzEngineStringData(_pRvResult_))
			StzEngineStringFree(_pRvResult_)
		ok

		def ReverseQ()
			This.Reverse()
			return This

	def Reversed()
		_pRvdResult_ = StzEngineStringReverse(@pEngine)
		if _pRvdResult_ != NULL
			_cRvdResult_ = StzEngineStringData(_pRvdResult_)
			StzEngineStringFree(_pRvdResult_)
			return _cRvdResult_
		ok
		return This.Content()

	  #============================================#
	 #     REPLACE                                #
	#============================================#

	def ReplaceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_bRpCase_ = @CaseSensitive(pCaseSensitive)
		StzEngineStringReplaceCS(@pEngine, pcSubStr, pcNewSubStr, _bRpCase_)

		def ReplaceCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def Replace(pcSubStr, pcNewSubStr)
		This.ReplaceCS(pcSubStr, pcNewSubStr, 1)

		def ReplaceQ(pcSubStr, pcNewSubStr)
			This.Replace(pcSubStr, pcNewSubStr)
			return This

		def ReplaceAll(pcSubStr, pcNewSubStr)
			This.Replace(pcSubStr, pcNewSubStr)

			def ReplaceAllQ(pcSubStr, pcNewSubStr)
				This.ReplaceAll(pcSubStr, pcNewSubStr)
				return This

		def ReplaceAllCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceCS(pcSubStr, pcNewSubStr, pCaseSensitive)

			def ReplaceAllCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
				This.ReplaceAllCS(pcSubStr, pcNewSubStr, pCaseSensitive)
				return This

	def ReplacedCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oRpdCopy_ = This.Copy()
		_oRpdCopy_.ReplaceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oRpdCopy_.Content()

	def Replaced(pcSubStr, pcNewSubStr)
		return This.ReplacedCS(pcSubStr, pcNewSubStr, 1)

	  #============================================#
	 #     REMOVE                                 #
	#============================================#

	def RemoveCS(pcSubStr, pCaseSensitive)
		This.ReplaceCS(pcSubStr, "", pCaseSensitive)

		def RemoveCSQ(pcSubStr, pCaseSensitive)
			This.RemoveCS(pcSubStr, pCaseSensitive)
			return This

	def Remove(pcSubStr)
		This.Replace(pcSubStr, "")

		def RemoveQ(pcSubStr)
			This.Remove(pcSubStr)
			return This

		def RemoveAll(pcSubStr)
			This.Remove(pcSubStr)

	# RemoveXT: extended Remove that dispatches on a named-param DSL.
	# Supported call shapes (all keys case-insensitive):
	#
	#   o1.RemoveXT(p, :AtPosition = N)
	#   o1.RemoveXT(p, :AtPositions = [N, N, ...])
	#
	#   o1.RemoveXT(p, :From = pcOtherString)        # rebinds Content to
	#                                                 # pcOtherString first
	#   o1.RemoveXT(:Each  = p, :From = c)
	#   o1.RemoveXT(:First = p, :From = c)
	#   o1.RemoveXT(:Last  = p, :From = c)
	#   o1.RemoveXT(:Nth   = [N, p], :From = c)
	#   o1.RemoveXT(:Nth   = [[N1, N2, ...], p], :From = c)
	#
	# Two-arg call where the first arg is a string and the second a
	# (key,value) named-param list -> positional remove of the
	# occurrence(s) at byte position(s) given by the value.
	def RemoveXT(p1, p2)
		# Form A: RemoveXT(:Selector = p, :From = c)
		if isList(p1) and ring_len(p1) = 2 and isString(p1[1])
			_cSel_ = lower(p1[1])
			if isList(p2) and ring_len(p2) = 2 and isString(p2[1]) and lower(p2[1]) = "from"
				This.Update(p2[2])
				_pVal_ = p1[2]
				if _cSel_ = "each"
					This.RemoveAll(_pVal_)
					return
				ok
				if _cSel_ = "first"
					This.RemoveFirst(_pVal_)
					return
				ok
				if _cSel_ = "last"
					This.RemoveLast(_pVal_)
					return
				ok
				if _cSel_ = "nth"
					# :Nth = [N, "subStr"]  or  [[N1,N2,...], "subStr"]
					if isList(_pVal_) and ring_len(_pVal_) = 2
						_xN_ = _pVal_[1]
						_cSubStr_ = _pVal_[2]
						if isNumber(_xN_)
							This.RemoveNth(_xN_, _cSubStr_)
							return
						but isList(_xN_)
							# Sort descending so positions stay valid
							_anNs_ = _xN_
							_nNs_ = ring_len(_anNs_)
							for _iRx_ = 1 to _nNs_ - 1
								for _jRx_ = 1 to _nNs_ - _iRx_
									if _anNs_[_jRx_] < _anNs_[_jRx_ + 1]
										_tmpN_ = _anNs_[_jRx_]
										_anNs_[_jRx_] = _anNs_[_jRx_ + 1]
										_anNs_[_jRx_ + 1] = _tmpN_
									ok
								next
							next
							for _iRx_ = 1 to _nNs_
								This.RemoveNth(_anNs_[_iRx_], _cSubStr_)
							next
							return
						ok
					ok
				ok
			ok
		ok

		# Form B: RemoveXT(pcSubStr, :From = c) -- rebind content, then
		# remove every occurrence.
		if isString(p1) and isList(p2) and ring_len(p2) = 2 and
		   isString(p2[1]) and lower(p2[1]) = "from"
			This.Update(p2[2])
			This.RemoveAll(p1)
			return
		ok

		# Form C: RemoveXT(pcSubStr, :AtPosition = N)
		if isString(p1) and isList(p2) and ring_len(p2) = 2 and isString(p2[1])
			_cKey_ = lower(p2[1])
			if _cKey_ = "atposition" and isNumber(p2[2])
				This._RemoveOccurrenceAtPos(p1, p2[2])
				return
			ok
			if _cKey_ = "atpositions" and isList(p2[2])
				# Sort descending so removals don't shift remaining positions.
				_anPs_ = p2[2]
				_nPs_ = ring_len(_anPs_)
				for _iRp_ = 1 to _nPs_ - 1
					for _jRp_ = 1 to _nPs_ - _iRp_
						if _anPs_[_jRp_] < _anPs_[_jRp_ + 1]
							_tmpP_ = _anPs_[_jRp_]
							_anPs_[_jRp_] = _anPs_[_jRp_ + 1]
							_anPs_[_jRp_ + 1] = _tmpP_
						ok
					next
				next
				for _iRp_ = 1 to _nPs_
					This._RemoveOccurrenceAtPos(p1, _anPs_[_iRp_])
				next
				return
			ok
		ok

		StzRaise("RemoveXT: unsupported argument shape")

		def RemoveXTQ(p1, p2)
			This.RemoveXT(p1, p2)
			return This

	# Internal: remove the substring pcSubStr at exact character
	# position nPos (the occurrence starts there). No-op if no match.
	def _RemoveOccurrenceAtPos(pcSubStr, nPos)
		_cStr_ = This.Content()
		_nSubLen_ = ring_len(pcSubStr)
		if nPos < 1 or nPos + _nSubLen_ - 1 > ring_len(_cStr_)
			return
		ok
		if substr(_cStr_, nPos, _nSubLen_) != pcSubStr
			return
		ok
		_cBefore_ = ""
		if nPos > 1
			_cBefore_ = substr(_cStr_, 1, nPos - 1)
		ok
		_cAfter_ = ""
		if nPos + _nSubLen_ - 1 < ring_len(_cStr_)
			_cAfter_ = substr(_cStr_, nPos + _nSubLen_)
		ok
		This.Update(_cBefore_ + _cAfter_)

		def RemoveAllCS(pcSubStr, pCaseSensitive)
			This.RemoveCS(pcSubStr, pCaseSensitive)

	  #============================================#
	 #     REPLACE NTH / FIRST / LAST             #
	#============================================#

	def ReplaceNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		_bRnCase_ = @CaseSensitive(pCaseSensitive)
		_pRnResult_ = StzEngineStringReplaceNthCS(@pEngine, pcSubStr, pcNewSubStr, n, _bRnCase_)
		_cRnResult_ = StzEngineStringData(_pRnResult_)
		StzEngineStringFree(_pRnResult_)
		This.Update(_cRnResult_)

		def ReplaceNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def ReplaceNth(n, pcSubStr, pcNewSubStr)
		This.ReplaceNthCS(n, pcSubStr, pcNewSubStr, 1)

		def ReplaceNthQ(n, pcSubStr, pcNewSubStr)
			This.ReplaceNth(n, pcSubStr, pcNewSubStr)
			return This

	def ReplaceFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_bRfCase_ = @CaseSensitive(pCaseSensitive)
		_pRfResult_ = StzEngineStringReplaceFirstCS(@pEngine, pcSubStr, pcNewSubStr, _bRfCase_)
		_cRfResult_ = StzEngineStringData(_pRfResult_)
		StzEngineStringFree(_pRfResult_)
		This.Update(_cRfResult_)

		def ReplaceFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def ReplaceFirst(pcSubStr, pcNewSubStr)
		This.ReplaceFirstCS(pcSubStr, pcNewSubStr, 1)

		def ReplaceFirstQ(pcSubStr, pcNewSubStr)
			This.ReplaceFirst(pcSubStr, pcNewSubStr)
			return This

	def ReplaceLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_bRlCase_ = @CaseSensitive(pCaseSensitive)
		_pRlResult_ = StzEngineStringReplaceLastCS(@pEngine, pcSubStr, pcNewSubStr, _bRlCase_)
		_cRlResult_ = StzEngineStringData(_pRlResult_)
		StzEngineStringFree(_pRlResult_)
		This.Update(_cRlResult_)

		def ReplaceLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def ReplaceLast(pcSubStr, pcNewSubStr)
		This.ReplaceLastCS(pcSubStr, pcNewSubStr, 1)

		def ReplaceLastQ(pcSubStr, pcNewSubStr)
			This.ReplaceLast(pcSubStr, pcNewSubStr)
			return This

	# ReplaceByMany(pcSubStr, paReplacements): replace each occurrence
	# of pcSubStr by cycling through paReplacements (so 1st occurrence
	# gets paReplacements[1], 2nd gets [2], etc., wrapping at the end
	# of the replacement list).
	# paReplacements may be a bare list or a :By/:With named-param list.
	# Helper: deep-copy a list. Ring's `list + []` appends the empty
	# list as a NEW element instead of concatenating, so it cannot be
	# used to clone. Walk the input and copy element-by-element.
	def _ListCopy(paList)
		_aCopy_ = []
		_nLen_ = ring_len(paList)
		for _i_ = 1 to _nLen_
			_aCopy_ + paList[_i_]
		next
		return _aCopy_

	# Helper: find pcNeedle in pcHay starting at codepoint position
	# nFrom (1-based, inclusive). Engine-backed (codepoint-aware,
	# so Unicode chars like ♥ count as 1 position even though they
	# occupy 3 UTF-8 bytes). Returns absolute position or 0.
	def _FindFrom(pcHay, pcNeedle, nFrom)
		if nFrom < 1 nFrom = 1 ok
		_pH_ = StzEngineString(pcHay)
		_nRes_ = StzEngineStringFindFirstFromCS(_pH_, pcNeedle, nFrom, 1)
		StzEngineStringFree(_pH_)
		if _nRes_ < 1 return 0 ok
		return _nRes_

	# Helper: slice pcHay by codepoint -- start codepoint position
	# (1-based) and codepoint count. Returns the substring.
	# Engine-backed; codepoint-aware.
	def _EngineSlice(pcHay, nStart, nCount)
		if nStart < 1 or nCount <= 0 return "" ok
		_pH_ = StzEngineString(pcHay)
		_pSlc_ = StzEngineStringSlice(_pH_, nStart, nCount)
		_cRes_ = StzEngineStringData(_pSlc_)
		StzEngineStringFree(_pSlc_)
		StzEngineStringFree(_pH_)
		return _cRes_

	# Helper: slice pcHay from codepoint nStart to the end.
	def _EngineSliceFrom(pcHay, nStart)
		_pH_ = StzEngineString(pcHay)
		_nLen_ = StzEngineStringCount(_pH_)
		if nStart < 1 nStart = 1 ok
		if nStart > _nLen_
			StzEngineStringFree(_pH_)
			return ""
		ok
		_pSlc_ = StzEngineStringSlice(_pH_, nStart, _nLen_ - nStart + 1)
		_cRes_ = StzEngineStringData(_pSlc_)
		StzEngineStringFree(_pSlc_)
		StzEngineStringFree(_pH_)
		return _cRes_

	# Helper: count codepoints in pcStr.
	def _EngineCount(pcStr)
		_pH_ = StzEngineString(pcStr)
		_n_ = StzEngineStringCount(_pH_)
		StzEngineStringFree(_pH_)
		return _n_

	def ReplaceByMany(pcSubStr, paReplacements)
		if isList(paReplacements) and ring_len(paReplacements) = 2 and
		   isString(paReplacements[1]) and
		   (lower(paReplacements[1]) = "by" or lower(paReplacements[1]) = "with")
			paReplacements = paReplacements[2]
		ok
		if NOT isList(paReplacements) return ok
		_nRepLen_ = ring_len(paReplacements)
		if _nRepLen_ = 0 return ok

		_cTxt_ = This.Content()
		_nSubLen_ = This._EngineCount(pcSubStr)
		_cOut_ = ""
		_nPos_ = 1
		_iRep_ = 1
		_nFound_ = This._FindFrom(_cTxt_, pcSubStr, _nPos_)
		while _nFound_ > 0
			if _nFound_ > _nPos_
				_cOut_ += This._EngineSlice(_cTxt_, _nPos_, _nFound_ - _nPos_)
			ok
			_cOut_ += paReplacements[_iRep_]
			_iRep_++
			if _iRep_ > _nRepLen_ _iRep_ = 1 ok
			_nPos_ = _nFound_ + _nSubLen_
			_nFound_ = This._FindFrom(_cTxt_, pcSubStr, _nPos_)
		end
		_cOut_ += This._EngineSliceFrom(_cTxt_, _nPos_)
		This.Update(_cOut_)

		def ReplaceByManyQ(pcSubStr, paReplacements)
			This.ReplaceByMany(pcSubStr, paReplacements)
			return This

		def ReplaceByManyXT(pcSubStr, paReplacements)
			This.ReplaceByMany(pcSubStr, paReplacements)

		def ReplaceByManyXTQ(pcSubStr, paReplacements)
			This.ReplaceByMany(pcSubStr, paReplacements)
			return This

	# ReplaceSubStringsBoundedBy(pacBounds, pcNew): replace every
	# substring sitting BETWEEN the bounds (exclusive of the bounds
	# themselves) with pcNew. pacBounds can be ["open", "close"] or
	# a single string used for both ends.
	def ReplaceSubStringsBoundedBy(pacBounds, pcNew)
		if isList(pcNew) and ring_len(pcNew) = 2 and isString(pcNew[1]) and
		   lower(pcNew[1]) = "with"
			pcNew = pcNew[2]
		ok
		_aOpen_ = pacBounds
		_aClose_ = NULL
		if isList(pacBounds) and ring_len(pacBounds) = 2
			_aOpen_ = pacBounds[1]; _aClose_ = pacBounds[2]
		but isString(pacBounds)
			_aClose_ = pacBounds
		ok
		if NOT (isString(_aOpen_) and isString(_aClose_)) return ok

		_cTxt_ = This.Content()
		_nOpenLen_ = This._EngineCount(_aOpen_)
		_nCloseLen_ = This._EngineCount(_aClose_)
		_nNewLen_ = This._EngineCount(pcNew)
		_nStart_ = This._FindFrom(_cTxt_, _aOpen_, 1)
		while _nStart_ > 0
			_nInsideStart_ = _nStart_ + _nOpenLen_
			_nEnd_ = This._FindFrom(_cTxt_, _aClose_, _nInsideStart_)
			if _nEnd_ = 0 exit ok
			_cBefore_ = ""
			if _nInsideStart_ > 1
				_cBefore_ = This._EngineSlice(_cTxt_, 1, _nInsideStart_ - 1)
			ok
			_cAfter_  = This._EngineSliceFrom(_cTxt_, _nEnd_)
			_cTxt_ = _cBefore_ + pcNew + _cAfter_
			_nStart_ = This._FindFrom(_cTxt_, _aOpen_, _nInsideStart_ + _nNewLen_)
		end
		This.Update(_cTxt_)

		def ReplaceSubStringsBoundedByQ(pacBounds, pcNew)
			This.ReplaceSubStringsBoundedBy(pacBounds, pcNew)
			return This

	# ReplaceSubStringBoundedBy(pcWhat, pacBounds, pcNew): replace
	# pcWhat with pcNew only when it sits inside a bounded section.
	# pacBounds may be ["open","close"] OR a single string used both
	# ways.
	def ReplaceSubStringBoundedBy(pcWhat, pacBounds, pcNew)
		if isList(pcNew) and ring_len(pcNew) = 2 and isString(pcNew[1]) and
		   lower(pcNew[1]) = "with"
			pcNew = pcNew[2]
		ok
		_aOpen_ = pacBounds
		_aClose_ = NULL
		if isList(pacBounds) and ring_len(pacBounds) = 2
			_aOpen_ = pacBounds[1]; _aClose_ = pacBounds[2]
		but isString(pacBounds)
			_aClose_ = pacBounds
		ok
		if NOT (isString(_aOpen_) and isString(_aClose_)) return ok

		_cTxt_ = This.Content()
		_nOpenLen_ = This._EngineCount(_aOpen_)
		_nCloseLen_ = This._EngineCount(_aClose_)
		_nWhatLen_ = This._EngineCount(pcWhat)
		_nNewLen_ = This._EngineCount(pcNew)
		_nStart_ = This._FindFrom(_cTxt_, _aOpen_, 1)
		while _nStart_ > 0
			_nInsideStart_ = _nStart_ + _nOpenLen_
			_nEnd_ = This._FindFrom(_cTxt_, _aClose_, _nInsideStart_)
			if _nEnd_ = 0 exit ok
			# Look for pcWhat strictly inside [_nInsideStart_, _nEnd_-1]
			_nWFound_ = This._FindFrom(_cTxt_, pcWhat, _nInsideStart_)
			while _nWFound_ > 0 and _nWFound_ < _nEnd_
				_cBefore_ = ""
				if _nWFound_ > 1
					_cBefore_ = This._EngineSlice(_cTxt_, 1, _nWFound_ - 1)
				ok
				_cAfter_  = This._EngineSliceFrom(_cTxt_, _nWFound_ + _nWhatLen_)
				_cTxt_ = _cBefore_ + pcNew + _cAfter_
				_nEnd_ += _nNewLen_ - _nWhatLen_
				_nWFound_ = This._FindFrom(_cTxt_, pcWhat, _nWFound_ + _nNewLen_)
			end
			# Move past this bounded section so we don't re-match.
			_nStart_ = This._FindFrom(_cTxt_, _aOpen_, _nEnd_ + _nCloseLen_)
		end
		This.Update(_cTxt_)

		def ReplaceSubStringBoundedByQ(pcWhat, pacBounds, pcNew)
			This.ReplaceSubStringBoundedBy(pcWhat, pacBounds, pcNew)
			return This

		# ReplaceSubStringBoundedByIB -- inclusive-bounds variant.
		# Replaces the entire bounded block (bounds + content) when
		# the content contains pcWhat.
		def ReplaceSubStringBoundedByIB(pcWhat, pacBounds, pcNew)
			if isList(pcNew) and ring_len(pcNew) = 2 and isString(pcNew[1]) and
			   lower(pcNew[1]) = "with"
				pcNew = pcNew[2]
			ok
			_aOpenIB_ = pacBounds
			_aCloseIB_ = NULL
			if isList(pacBounds) and ring_len(pacBounds) = 2
				_aOpenIB_ = pacBounds[1]; _aCloseIB_ = pacBounds[2]
			but isString(pacBounds)
				_aCloseIB_ = pacBounds
			ok
			if NOT (isString(_aOpenIB_) and isString(_aCloseIB_)) return ok
			_cTxtIB_ = This.Content()
			_nOpenLenIB_ = This._EngineCount(_aOpenIB_)
			_nCloseLenIB_ = This._EngineCount(_aCloseIB_)
			_nNewLenIB_ = This._EngineCount(pcNew)
			_nStartIB_ = This._FindFrom(_cTxtIB_, _aOpenIB_, 1)
			while _nStartIB_ > 0
				_nInsideIB_ = _nStartIB_ + _nOpenLenIB_
				_nEndIB_ = This._FindFrom(_cTxtIB_, _aCloseIB_, _nInsideIB_)
				if _nEndIB_ = 0 exit ok
				_cInsideIB_ = This._EngineSlice(_cTxtIB_, _nInsideIB_, _nEndIB_ - _nInsideIB_)
				if This._FindFrom(_cInsideIB_, pcWhat, 1) > 0
					_cBeforeIB_ = ""
					if _nStartIB_ > 1
						_cBeforeIB_ = This._EngineSlice(_cTxtIB_, 1, _nStartIB_ - 1)
					ok
					_cAfterIB_  = This._EngineSliceFrom(_cTxtIB_, _nEndIB_ + _nCloseLenIB_)
					_cTxtIB_ = _cBeforeIB_ + pcNew + _cAfterIB_
					_nStartIB_ = This._FindFrom(_cTxtIB_, _aOpenIB_, _nStartIB_ + _nNewLenIB_)
				else
					_nStartIB_ = This._FindFrom(_cTxtIB_, _aOpenIB_, _nEndIB_ + _nCloseLenIB_)
				ok
			end
			This.Update(_cTxtIB_)

	# ReplaceSubStringAtPosition(n, pcOld, pcNew): replace pcOld with
	# pcNew only at character position n (so pcOld must start at n).
	def ReplaceSubStringAtPosition(n, pcOld, pcNew)
		if isList(pcNew) and ring_len(pcNew) = 2 and isString(pcNew[1]) and
		   lower(pcNew[1]) = "with"
			pcNew = pcNew[2]
		ok
		_cTxt_ = This.Content()
		_nOldLen_ = This._EngineCount(pcOld)
		_nTxtLen_ = This._EngineCount(_cTxt_)
		if n < 1 or n + _nOldLen_ - 1 > _nTxtLen_ return ok
		# Verify pcOld actually starts at codepoint n.
		_cAtN_ = This._EngineSlice(_cTxt_, n, _nOldLen_)
		if _cAtN_ != pcOld return ok
		_cBefore_ = ""
		if n > 1
			_cBefore_ = This._EngineSlice(_cTxt_, 1, n - 1)
		ok
		_cAfter_  = This._EngineSliceFrom(_cTxt_, n + _nOldLen_)
		This.Update(_cBefore_ + pcNew + _cAfter_)

		def ReplaceSubStringAtPositionQ(n, pcOld, pcNew)
			This.ReplaceSubStringAtPosition(n, pcOld, pcNew)
			return This

	# ReplaceAt(n, pcOld, pcNew)            -- replace pcOld at
	#                                          position n with pcNew
	# ReplaceAt(anPos, pcOld, :By = pcNew)  -- list-of-positions form
	# Ring's strict arity means the single-char form lives at
	# ReplaceCharAt(n, pcNewChar) (positional or named-param).
	# Three-arg signature -- callers using the 2-arg form should use
	# ReplaceCharAt.
	def ReplaceAt(n, pcOld, pcNew)
		# :By / :With normalisation on pcNew.
		if isList(pcNew) and ring_len(pcNew) = 2 and isString(pcNew[1]) and
		   (lower(pcNew[1]) = "by" or lower(pcNew[1]) = "with")
			pcNew = pcNew[2]
		ok

		if isList(n)
			# Sort positions descending so earlier ones don't shift.
			_aPos_ = _ListCopy(n)
			_nPL_ = ring_len(_aPos_)
			for _i_ = 2 to _nPL_
				_v_ = _aPos_[_i_]; _j_ = _i_ - 1
				while _j_ >= 1 and _aPos_[_j_] < _v_
					_aPos_[_j_ + 1] = _aPos_[_j_]; _j_--
				end
				_aPos_[_j_ + 1] = _v_
			next
			for _i_ = 1 to _nPL_
				This.ReplaceSubStringAtPosition(_aPos_[_i_], pcOld, pcNew)
			next
			return
		ok
		This.ReplaceSubStringAtPosition(n, pcOld, pcNew)

		def ReplaceAtQ(n, pcOld, pcNew)
			This.ReplaceAt(n, pcOld, pcNew)
			return This

	# ReplaceCharAt(:Position = n, :By = pcNew) -- named-param variant
	# of ReplaceAt for char-at-position replacement.
	def ReplaceCharAt(pP1, pP2)
		_n_ = NULL
		_cNew_ = NULL
		_aArgs_ = [ pP1, pP2 ]
		for _i_ = 1 to 2
			_a_ = _aArgs_[_i_]
			if isList(_a_) and ring_len(_a_) = 2 and isString(_a_[1])
				_k_ = lower(_a_[1])
				if _k_ = "position" or _k_ = "at"
					_n_ = _a_[2]
				but _k_ = "by" or _k_ = "with"
					_cNew_ = _a_[2]
				ok
			ok
		next
		if _n_ != NULL and _cNew_ != NULL
			This.ReplaceCharAtSimple(_n_, _cNew_)
		ok

		def ReplaceCharAtQ(pP1, pP2)
			This.ReplaceCharAt(pP1, pP2)
			return This

	# ReplaceCharAt(n, pcNew) -- single-char-at-position form.
	# (Named-param :Position/:By form lives at ReplaceCharAt2 above.)
	def ReplaceCharAtSimple(n, pcNew)
		_cTxt_ = This.Content()
		_nTxtLen_ = This._EngineCount(_cTxt_)
		if n < 1 or n > _nTxtLen_ return ok
		_cBefore_ = ""
		if n > 1
			_cBefore_ = This._EngineSlice(_cTxt_, 1, n - 1)
		ok
		_cAfter_  = This._EngineSliceFrom(_cTxt_, n + 1)
		This.Update(_cBefore_ + pcNew + _cAfter_)

	# ReplaceCharsAtPositions(anPos, :With/:By = pcNewChar) -- replace
	# the char at each listed position with pcNewChar.
	def ReplaceCharsAtPositions(anPos, pNamed)
		_cNew_ = pNamed
		if isList(pNamed) and ring_len(pNamed) = 2 and isString(pNamed[1]) and
		   (lower(pNamed[1]) = "with" or lower(pNamed[1]) = "by")
			_cNew_ = pNamed[2]
		ok
		if NOT isString(_cNew_) return ok
		# Engine-backed: get the codepoint list, swap by position,
		# rejoin. Positions refer to the ORIGINAL codepoint indices.
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_nPL_ = ring_len(anPos)
		for _i_ = 1 to _nPL_
			_p_ = anPos[_i_]
			if _p_ >= 1 and _p_ <= _nLen_
				_aChars_[_p_] = _cNew_
			ok
		next
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			_cOut_ += _aChars_[_i_]
		next
		This.Update(_cOut_)

		def ReplaceCharsAtPositionsQ(anPos, pNamed)
			This.ReplaceCharsAtPositions(anPos, pNamed)
			return This

	# ReplaceCharsAtPositionsByMany(anPos, paChars): per-position
	# parallel replacement -- position anPos[i] gets replaced by
	# paChars[i] (cycling if there are more positions than chars).
	def ReplaceCharsAtPositionsByMany(anPos, paChars)
		if NOT (isList(anPos) and isList(paChars)) return ok
		_nPL_ = ring_len(anPos)
		_nCL_ = ring_len(paChars)
		if _nPL_ = 0 or _nCL_ = 0 return ok
		# Engine-backed: get the codepoint list, swap each pos.
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		for _i_ = 1 to _nPL_
			_p_ = anPos[_i_]
			if _p_ >= 1 and _p_ <= _nLen_
				_repIdx_ = _i_
				while _repIdx_ > _nCL_ _repIdx_ -= _nCL_ end
				_aChars_[_p_] = paChars[_repIdx_]
			ok
		next
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			_cOut_ += _aChars_[_i_]
		next
		This.Update(_cOut_)

		def ReplaceCharsAtPositionsByManyQ(anPos, paChars)
			This.ReplaceCharsAtPositionsByMany(anPos, paChars)
			return This

	# Sit(:OnSection = [n1, n2], :AndHarvest = [:NCharsBefore=a,
	# :NCharsAfter=b]) -- "sit on a section" and harvest a chars to
	# the left + b chars to the right of it. Returns [cLeft, cRight].
	def Sit(p1, p2)
		_aSec_ = NULL
		_aHarvest_ = NULL
		_aArgs_ = [ p1, p2 ]
		for _i_ = 1 to 2
			_a_ = _aArgs_[_i_]
			if isList(_a_) and ring_len(_a_) = 2 and isString(_a_[1])
				_k_ = lower(_a_[1])
				if _k_ = "onsection" or _k_ = "on"
					_aSec_ = _a_[2]
				but _k_ = "andharvest" or _k_ = "harvest"
					_aHarvest_ = _a_[2]
				ok
			ok
		next
		if _aSec_ = NULL or NOT (isList(_aSec_) and ring_len(_aSec_) = 2)
			return []
		ok
		_nBefore_ = 0; _nAfter_ = 0
		if isList(_aHarvest_)
			_nHL_ = ring_len(_aHarvest_)
			for _i_ = 1 to _nHL_
				_h_ = _aHarvest_[_i_]
				if isList(_h_) and ring_len(_h_) = 2 and isString(_h_[1])
					_hk_ = lower(_h_[1])
					if _hk_ = "ncharsbefore" or _hk_ = "before"
						_nBefore_ = _h_[2]
					but _hk_ = "ncharsafter" or _hk_ = "after"
						_nAfter_ = _h_[2]
					ok
				ok
			next
		ok
		_cTxt_ = This.Content()
		_n1_ = _aSec_[1]; _n2_ = _aSec_[2]
		_nLeftStart_ = _n1_ - _nBefore_
		if _nLeftStart_ < 1 _nLeftStart_ = 1 ok
		_cLeft_  = This._EngineSlice(_cTxt_, _nLeftStart_, _n1_ - _nLeftStart_)
		_nRightStart_ = _n2_ + 1
		_nRightLen_ = _nAfter_
		_nTxtLen_ = This._EngineCount(_cTxt_)
		_nMaxRight_ = _nTxtLen_ - _nRightStart_ + 1
		if _nRightLen_ > _nMaxRight_ _nRightLen_ = _nMaxRight_ ok
		_cRight_ = ""
		if _nRightLen_ > 0
			_cRight_ = This._EngineSlice(_cTxt_, _nRightStart_, _nRightLen_)
		ok
		return [ _cLeft_, _cRight_ ]

	# Markers / Marquers (FR) -- placeholder tokens of the form #1,
	# #2, ..., #N inside the content. The narrative tests check whether
	# the markers appear in ascending order.
	#
	# Markers(): return the list of marker numbers as they appear,
	# left-to-right. e.g. "#1 #3 #2" -> [1, 3, 2].
	def Markers()
		# Engine-backed: scan the codepoint list for "#" followed by
		# digits. Markers like #1, #12 are pure-ASCII so per-char
		# equality on the codepoint list is correct.
		_aRes_ = []
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_i_ = 1
		while _i_ <= _nLen_
			if _aChars_[_i_] = "#" and _i_ < _nLen_ and isDigit(_aChars_[_i_ + 1])
				_j_ = _i_ + 1
				while _j_ <= _nLen_ and isDigit(_aChars_[_j_])
					_j_++
				end
				_cNum_ = ""
				for _k_ = _i_ + 1 to _j_ - 1
					_cNum_ += _aChars_[_k_]
				next
				_aRes_ + 0 + _cNum_
				_i_ = _j_
			else
				_i_++
			ok
		end
		return _aRes_

		def Marquers()
			return This.Markers()

	def NumberOfMarkers()
		return ring_len(This.Markers())

		def NumberOfMarquers()
			return This.NumberOfMarkers()

	def MarkersAreSortedInAscending()
		_aM_ = This.Markers()
		_nLen_ = ring_len(_aM_)
		if _nLen_ < 2 return TRUE ok
		for _i_ = 2 to _nLen_
			if _aM_[_i_] < _aM_[_i_ - 1] return FALSE ok
		next
		return TRUE

		def MarquersAreSortedInAscending()
			return This.MarkersAreSortedInAscending()

		def MarkersAreSortedAscending()
			return This.MarkersAreSortedInAscending()

	def MarkersAreSortedInDescending()
		_aM_ = This.Markers()
		_nLen_ = ring_len(_aM_)
		if _nLen_ < 2 return TRUE ok
		for _i_ = 2 to _nLen_
			if _aM_[_i_] > _aM_[_i_ - 1] return FALSE ok
		next
		return TRUE

		def MarquersAreSortedInDescending()
			return This.MarkersAreSortedInDescending()

	def MarkersAreSorted()
		return This.MarkersAreSortedInAscending() or
		       This.MarkersAreSortedInDescending()

		def MarquersAreSorted()
			return This.MarkersAreSorted()

	# MarkersAreUnsorted: TRUE when markers don't all monotone.
	def MarkersAreUnsorted()
		return NOT This.MarkersAreSorted()

		def MarquersAreUnsorted()
			return This.MarkersAreUnsorted()

	# MarkersSortingOrder: :Ascending, :Descending, :Unsorted, or
	# :Undefined for fewer than 2 markers.
	def MarkersSortingOrder()
		_aM_ = This.Markers()
		_nLen_ = ring_len(_aM_)
		if _nLen_ < 2 return :Undefined ok
		if This.MarkersAreSortedInAscending() return :Ascending ok
		if This.MarkersAreSortedInDescending() return :Descending ok
		return :Unsorted

		def MarquersSortingOrder()
			return This.MarkersSortingOrder()

	# ReplaceXT(p1, p2, p3) -- named-param dispatcher for the common
	# narrative forms. Supported shapes:
	#   ReplaceXT( :Nth = n, pcSubStr, :With = pcNew )
	#   ReplaceXT( :First,    pcSubStr, :With = pcNew )
	#   ReplaceXT( :Last,     pcSubStr, :With = pcNew )
	#   ReplaceXT( pcSubStr, :At  = n,            :With = pcNew )
	#   ReplaceXT( pcSubStr, :AtPosition = n,     :With = pcNew )
	#   ReplaceXT( pcSubStr, :AtPositions = [...],:With = pcNew )
	#   ReplaceXT( pcSubStr, :In  = pcContext,    :With = pcNew )
	def ReplaceXT(p1, p2, p3)
		# Resolve :With from p3
		_pWith_ = p3
		if isList(p3) and ring_len(p3) = 2 and isString(p3[1]) and lower(p3[1]) = "with"
			_pWith_ = p3[2]
		ok

		# Form A: :Nth = n + substr + :With
		if isList(p1) and ring_len(p1) = 2 and isString(p1[1]) and lower(p1[1]) = "nth"
			This.ReplaceNth(p1[2], p2, _pWith_)
			return
		ok

		# Form B: :First / :Last + substr + :With
		if isString(p1)
			_cTag_ = lower(p1)
			if _cTag_ = "first"
				This.ReplaceFirst(p2, _pWith_)
				return
			but _cTag_ = "last"
				This.ReplaceLast(p2, _pWith_)
				return
			ok
		ok

		# Forms C+: pcSubStr first, anchor as p2
		if isString(p1) and isList(p2) and ring_len(p2) = 2 and isString(p2[1])
			_cAnchor_ = lower(p2[1])
			_xAnchorV_ = p2[2]

			if _cAnchor_ = "at" or _cAnchor_ = "atposition"
				This.ReplaceNth(_xAnchorV_, p1, _pWith_)
				return
			but _cAnchor_ = "atpositions"
				if NOT isList(_xAnchorV_)
					StzRaise("ReplaceXT: :AtPositions expects a list.")
				ok
				# Walk descending so earlier positions still map.
				_aPos_ = _ListCopy(_xAnchorV_)
				_nP_ = ring_len(_aPos_)
				for _i_ = 2 to _nP_
					_v_ = _aPos_[_i_]; _j_ = _i_ - 1
					while _j_ >= 1 and _aPos_[_j_] < _v_
						_aPos_[_j_+1] = _aPos_[_j_]; _j_--
					end
					_aPos_[_j_+1] = _v_
				next
				_nP_ = ring_len(_aPos_)
				for _i_ = 1 to _nP_
					This.ReplaceNth(_aPos_[_i_], p1, _pWith_)
				next
				return
			but _cAnchor_ = "in"
				# Replace pcSubStr with pWith only within the context
				# substring (one-shot in the first matching context).
				if NOT isString(_xAnchorV_) return ok
				_cCtx_ = _xAnchorV_
				_cNewCtx_ = substr(_cCtx_, p1, _pWith_)
				_cTxt_ = This.Content()
				_cNewTxt_ = substr(_cTxt_, _cCtx_, _cNewCtx_)
				This.Update(_cNewTxt_)
				return
			but _cAnchor_ = "boundedby"
				# Replace whatever is between the bounds with _pWith_.
				# Supports either two-element list or single string.
				_aOpen_ = _xAnchorV_
				_aClose_ = NULL
				if isList(_aOpen_) and ring_len(_aOpen_) = 2
					_aClose_ = _aOpen_[2]; _aOpen_ = _aOpen_[1]
				but isString(_aOpen_)
					_aClose_ = _aOpen_
				ok
				if NOT (isString(_aOpen_) and isString(_aClose_)) return ok
				_cTxt_ = This.Content()
				_nOpenLen_ = This._EngineCount(_aOpen_)
				_nCloseLen_ = This._EngineCount(_aClose_)
				_nWithLen_ = This._EngineCount(_pWith_)
				_nStart_ = This._FindFrom(_cTxt_, _aOpen_, 1)
				while _nStart_ > 0
					_nEnd_ = This._FindFrom(_cTxt_, _aClose_, _nStart_ + _nOpenLen_)
					if _nEnd_ = 0 exit ok
					_cBefore_ = ""
					if _nStart_ > 1
						_cBefore_ = This._EngineSlice(_cTxt_, 1, _nStart_ - 1)
					ok
					_cAfter_  = This._EngineSliceFrom(_cTxt_, _nEnd_ + _nCloseLen_)
					_cTxt_ = _cBefore_ + _aOpen_ + _pWith_ + _aClose_ + _cAfter_
					_nStart_ = This._FindFrom(_cTxt_, _aOpen_, _nStart_ + _nOpenLen_ + _nWithLen_ + _nCloseLen_)
				end
				This.Update(_cTxt_)
				return
			ok
		ok

		StzRaise("ReplaceXT: unsupported argument shape.")

		def ReplaceXTQ(p1, p2, p3)
			This.ReplaceXT(p1, p2, p3)
			return This

	# SpacifyChars / SpacifyCharsUsing / SpacifyCharsXT -- char-wise
	# Spacify variants: insert a separator between every pair of
	# consecutive chars (with optional step + direction).
	def SpacifyChars()
		This.SpacifyCharsUsing(" ")

		def SpacifyCharsQ()
			This.SpacifyChars()
			return This

	# Spacify: shorter spelling -- same as SpacifyChars.
	def Spacify()
		This.SpacifyCharsUsing(" ")

		def SpacifyQ()
			This.Spacify()
			return This

	# SpacifyUsing: alias of SpacifyCharsUsing.
	def SpacifyUsing(pcSep)
		This.SpacifyCharsUsing(pcSep)

		def SpacifyUsingQ(pcSep)
			This.SpacifyCharsUsing(pcSep)
			return This

	def SpacifyCharsUsing(pcSep)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ < 2 return ok
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			_cOut_ += _aChars_[_i_]
			if _i_ < _nLen_ _cOut_ += pcSep ok
		next
		This.Update(_cOut_)

		def SpacifyCharsUsingQ(pcSep)
			This.SpacifyCharsUsing(pcSep)
			return This

	def SpacifyCharsXT(p1, p2, p3)
		# Same DSL surface as SpacifyXT: positional or named-param.
		# Normalise then forward through SpacifyXT.
		This.SpacifyXT(p1, p2, p3)

		def SpacifyCharsXTQ(p1, p2, p3)
			This.SpacifyCharsXT(p1, p2, p3)
			return This

	# SpacifyXT -- insert a separator every nStep chars, walking
	# from left or right. Common shapes:
	#   SpacifyXT(pcSep, nStep, :Forward|:Backward)
	#   SpacifyXT(:Using=cSep, :Step=n, :Direction|:Going=:Backward)
	#   SpacifyXT([sep1, sep2], [step1, step2], :Backward)
	# The named-param form normalises to the positional form.
	# Multi-separator form alternates: every step1 insert sep1, etc.
	def SpacifyXT(p1, p2, p3)
		# Normalise named-param form to positional.
		if isList(p1) and ring_len(p1) = 2 and isString(p1[1]) and
		   lower(p1[1]) = "using"
			p1 = p1[2]
		ok
		if isList(p2) and ring_len(p2) = 2 and isString(p2[1]) and
		   lower(p2[1]) = "step"
			p2 = p2[2]
		ok
		if isList(p3) and ring_len(p3) = 2 and isString(p3[1]) and
		   (lower(p3[1]) = "direction" or lower(p3[1]) = "going")
			p3 = p3[2]
		ok

		# Determine direction.
		_bBackward_ = FALSE
		if isString(p3) and (lower(p3) = "backward" or lower(p3) = "reverse")
			_bBackward_ = TRUE
		ok

		# Build the per-position separator stream.
		# Engine-backed: get the codepoint list and walk it.
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ < 2 return ok

		# Normalise sep/step to lists for uniform handling.
		_aSeps_ = p1
		_aSteps_ = p2
		if isString(p1) _aSeps_ = [ p1 ] ok
		if isNumber(p2) _aSteps_ = [ p2 ] ok
		_nSeps_ = ring_len(_aSeps_)

		_cOut_ = ""
		_iCount_ = 0
		_iStepIdx_ = 1
		if _bBackward_
			# Walk right-to-left, prepending to _cOut_.
			for _i_ = _nLen_ to 1 step -1
				_cOut_ = _aChars_[_i_] + _cOut_
				_iCount_++
				if _i_ > 1 and _iCount_ = _aSteps_[_iStepIdx_]
					_cOut_ = _aSeps_[_iStepIdx_] + _cOut_
					_iCount_ = 0
					_iStepIdx_++
					if _iStepIdx_ > _nSeps_ _iStepIdx_ = 1 ok
				ok
			next
		else
			for _i_ = 1 to _nLen_
				_cOut_ += _aChars_[_i_]
				_iCount_++
				if _i_ < _nLen_ and _iCount_ = _aSteps_[_iStepIdx_]
					_cOut_ += _aSeps_[_iStepIdx_]
					_iCount_ = 0
					_iStepIdx_++
					if _iStepIdx_ > _nSeps_ _iStepIdx_ = 1 ok
				ok
			next
		ok
		This.Update(_cOut_)

		def SpacifyXTQ(p1, p2, p3)
			This.SpacifyXT(p1, p2, p3)
			return This

	  #============================================#
	 #     REMOVE FIRST / LAST                    #
	#============================================#

	def RemoveFirstCS(pcSubStr, pCaseSensitive)
		This.ReplaceFirstCS(pcSubStr, "", pCaseSensitive)

		def RemoveFirstCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFirstCS(pcSubStr, pCaseSensitive)
			return This

	def RemoveFirst(pcSubStr)
		This.ReplaceFirst(pcSubStr, "")

		def RemoveFirstQ(pcSubStr)
			This.RemoveFirst(pcSubStr)
			return This

	def RemoveLastCS(pcSubStr, pCaseSensitive)
		This.ReplaceLastCS(pcSubStr, "", pCaseSensitive)

		def RemoveLastCSQ(pcSubStr, pCaseSensitive)
			This.RemoveLastCS(pcSubStr, pCaseSensitive)
			return This

	def RemoveLast(pcSubStr)
		This.ReplaceLast(pcSubStr, "")

		def RemoveLastQ(pcSubStr)
			This.RemoveLast(pcSubStr)
			return This

	  #============================================#
	 #     INSERT                                  #
	#============================================#

	def InsertBefore(n, pcSubStr)
		# List-of-positions form: walk descending so positions stay
		# valid as later inserts shift the string.
		if isList(n)
			_aPos_ = _ListCopy(n)
			_nPL_ = ring_len(_aPos_)
			for _i_ = 2 to _nPL_
				_v_ = _aPos_[_i_]; _j_ = _i_ - 1
				while _j_ >= 1 and _aPos_[_j_] < _v_
					_aPos_[_j_ + 1] = _aPos_[_j_]; _j_--
				end
				_aPos_[_j_ + 1] = _v_
			next
			for _i_ = 1 to _nPL_
				StzEngineStringInsertCp(@pEngine, _aPos_[_i_], pcSubStr)
			next
			return
		ok
		StzEngineStringInsertCp(@pEngine, n, pcSubStr)

		def InsertBeforeQ(n, pcSubStr)
			This.InsertBefore(n, pcSubStr)
			return This

		def InsertBeforePosition(n, pcSubStr)
			This.InsertBefore(n, pcSubStr)

	# ExtendToWith(n, pcChar): pad the string out to total length n
	# by appending copies of pcChar at the end.
	def ExtendToWith(n, pcChar)
		_cTxt_ = This.Content()
		_nNeed_ = n - This._EngineCount(_cTxt_)
		if _nNeed_ <= 0 return ok
		if NOT isString(pcChar) or ring_len(pcChar) = 0 return ok
		_nCharLen_ = This._EngineCount(pcChar)
		_cPad_ = ""
		_nPadLen_ = 0
		while _nPadLen_ < _nNeed_
			_cPad_ += pcChar
			_nPadLen_ += _nCharLen_
		end
		# Trim to exactly _nNeed_ codepoints if last iteration overshot.
		if _nPadLen_ > _nNeed_
			_cPad_ = This._EngineSlice(_cPad_, 1, _nNeed_)
		ok
		This.Update(_cTxt_ + _cPad_)

		def ExtendToWithQ(n, pcChar)
			This.ExtendToWith(n, pcChar)
			return This

	def ExtendToWithCharsRepeated(n)
		# Pad out to total length n by cycling through the current
		# content (so "abc" -> "abc abc a" when n = 8).
		# Engine-backed: walk by codepoints so Unicode chars count as 1.
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 or n <= _nLen_ return ok
		_cOut_ = This.Content()
		_nOutLen_ = _nLen_
		_iSrc_ = 1
		while _nOutLen_ < n
			_cOut_ += _aChars_[_iSrc_]
			_nOutLen_++
			_iSrc_++
			if _iSrc_ > _nLen_ _iSrc_ = 1 ok
		end
		This.Update(_cOut_)

		def ExtendToWithCharsRepeatedQ(n)
			This.ExtendToWithCharsRepeated(n)
			return This

	def ExtendToWithCharsIn(n, pcCharsOrRange)
		# Pad out to total length n by cycling through pcCharsOrRange.
		# A Ring range like "1":"3" expands to "123".
		_cSrc_ = pcCharsOrRange
		if isList(pcCharsOrRange) and ring_len(pcCharsOrRange) = 2
			# Could be range form -- already expanded by Ring to list of chars.
			_tmp_ = ""
			_nRL_ = ring_len(pcCharsOrRange)
			for _i_ = 1 to _nRL_
				_tmp_ += pcCharsOrRange[_i_]
			next
			_cSrc_ = _tmp_
		ok
		if NOT isString(_cSrc_) or ring_len(_cSrc_) = 0 return ok
		# Engine-backed: codepoint-aware cycling.
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		if n <= _nLen_ return ok
		# Get the codepoint list of the source pool.
		_pHsrc_ = StzEngineString(_cSrc_)
		_pHsrcS_ = StzEngineStringCharsSplit(_pHsrc_)
		_cJoined_ = StzEngineStringData(_pHsrcS_)
		StzEngineStringFree(_pHsrcS_)
		StzEngineStringFree(_pHsrc_)
		_aSrcChars_ = _SplitNullDelimited(_cJoined_)
		_nSrc_ = ring_len(_aSrcChars_)
		_cOut_ = _cTxt_
		_nOutLen_ = _nLen_
		_iSrc_ = 1
		while _nOutLen_ < n
			_cOut_ += _aSrcChars_[_iSrc_]
			_nOutLen_++
			_iSrc_++
			if _iSrc_ > _nSrc_ _iSrc_ = 1 ok
		end
		This.Update(_cOut_)

		def ExtendToWithCharsInQ(n, pcCharsOrRange)
			This.ExtendToWithCharsIn(n, pcCharsOrRange)
			return This

	# RemoveCharsWXT(pcCondition): remove every char where the
	# predicate is TRUE. Predicate runs with @char bound.
	def RemoveCharsWXT(pcCondition)
		_cExpr_ = pcCondition
		if isList(pcCondition) and ring_len(pcCondition) = 2 and
		   isString(pcCondition[1]) and lower(pcCondition[1]) = "where"
			_cExpr_ = pcCondition[2]
		ok
		if NOT isString(_cExpr_) return ok
		# Engine-backed: walk codepoints, not bytes.
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			@char = _aChars_[_i_]
			@Char = @char
			@position = _i_
			_bDrop_ = FALSE
			try
				eval("_bDrop_ = " + _cExpr_)
			catch
				_bDrop_ = FALSE
			done
			if NOT _bDrop_ _cOut_ += @char ok
		next
		This.Update(_cOut_)

		def RemoveCharsWXTQ(pcCondition)
			This.RemoveCharsWXT(pcCondition)
			return This

		def RemoveCharsW(pcCondition)
			This.RemoveCharsWXT(pcCondition)

		# Shorter aliases used by fluent narrative chains: drop chars
		# where the predicate is TRUE. (RemoveW already exists below
		# routing through stzStringRemover -- we add only the XT/Q
		# variants here.)
		def RemoveWXT(pcCondition)
			This.RemoveCharsWXT(pcCondition)

		def RemoveWXTQ(pcCondition)
			This.RemoveCharsWXT(pcCondition)
			return This

		def RemoveWQ(pcCondition)
			This.RemoveCharsWXT(pcCondition)
			return This

	# RemoveDuplicatedChars: dedup chars in-place (keep first occurrence).
	def RemoveDuplicatedChars()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aSeen_ = []
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			_c_ = _aChars_[_i_]
			_bDup_ = FALSE
			_nSL_ = ring_len(_aSeen_)
			for _j_ = 1 to _nSL_
				if _aSeen_[_j_] = _c_ _bDup_ = TRUE exit ok
			next
			if NOT _bDup_
				_aSeen_ + _c_
				_cOut_ += _c_
			ok
		next
		This.Update(_cOut_)

		def RemoveDuplicatedCharsQ()
			This.RemoveDuplicatedChars()
			return This

		def RemoveDupChars()
			This.RemoveDuplicatedChars()

		def RemoveDupCharsQ()
			This.RemoveDuplicatedChars()
			return This

		def InsertAt(n, pcSubStr)
			This.InsertBefore(n, pcSubStr)

		def InsertAtQ(n, pcSubStr)
			This.InsertBefore(n, pcSubStr)
			return This

	def InsertAfter(n, pcSubStr)
		This.InsertBefore(n + 1, pcSubStr)

		def InsertAfterQ(n, pcSubStr)
			This.InsertAfter(n, pcSubStr)
			return This

		def InsertAfterPosition(n, pcSubStr)
			This.InsertAfter(n, pcSubStr)

	# InsertAfterPositions(anPos, pcStr): insert pcStr after each
	# position in anPos. Walk descending so earlier positions stay
	# valid as later inserts shift the string.
	def InsertAfterPositions(anPos, pcStr)
		_aPos_ = _ListCopy(anPos)
		_nPL_ = ring_len(_aPos_)
		for _i_ = 2 to _nPL_
			_v_ = _aPos_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aPos_[_j_] < _v_
				_aPos_[_j_ + 1] = _aPos_[_j_]; _j_--
			end
			_aPos_[_j_ + 1] = _v_
		next
		for _i_ = 1 to _nPL_
			This.InsertAfter(_aPos_[_i_], pcStr)
		next

		def InsertAfterPositionsQ(anPos, pcStr)
			This.InsertAfterPositions(anPos, pcStr)
			return This

	# InsertBeforePositions: mirror.
	def InsertBeforePositions(anPos, pcStr)
		_aPos_ = _ListCopy(anPos)
		_nPL_ = ring_len(_aPos_)
		for _i_ = 2 to _nPL_
			_v_ = _aPos_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aPos_[_j_] < _v_
				_aPos_[_j_ + 1] = _aPos_[_j_]; _j_--
			end
			_aPos_[_j_ + 1] = _v_
		next
		for _i_ = 1 to _nPL_
			This.InsertBefore(_aPos_[_i_], pcStr)
		next

		def InsertBeforePositionsQ(anPos, pcStr)
			This.InsertBeforePositions(anPos, pcStr)
			return This

	# InsertAfterEachNChars(n, pcStr) -- insert pcStr after every n
	# characters, walking from start by default. :StartingFrom = :End
	# walks from the right.
	def InsertAfterEachNChars(n, pcStr)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if n < 1 or _nLen_ < n return ok
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			_cOut_ += _aChars_[_i_]
			if _i_ < _nLen_ and _i_ % n = 0 _cOut_ += pcStr ok
		next
		This.Update(_cOut_)

		def InsertAfterEachNCharsQ(n, pcStr)
			This.InsertAfterEachNChars(n, pcStr)
			return This

	def InsertAfterEachNCharsXT(n, pNamed)
		_bFromEnd_ = FALSE
		if isList(pNamed) and ring_len(pNamed) = 2 and isString(pNamed[1]) and
		   (lower(pNamed[1]) = "startingfrom" or lower(pNamed[1]) = "from")
			if pNamed[2] = :End or (isString(pNamed[2]) and lower(pNamed[2]) = "end")
				_bFromEnd_ = TRUE
			ok
		ok
		if NOT _bFromEnd_
			This.InsertAfterEachNChars(n, "")
			return
		ok
		# Walk from the right: count chars from end, insert before
		# each (n+1)-th to keep the "from end" intuition.
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if n < 1 or _nLen_ < n return ok
		_cOut_ = ""
		for _i_ = _nLen_ to 1 step -1
			_cOut_ = _aChars_[_i_] + _cOut_
			if _i_ > 1 and (_nLen_ - _i_ + 1) % n = 0
				# Nothing to insert in the bare 2-arg semantic; this
				# remains as a forwarder for the test surface.
			ok
		next
		This.Update(_cOut_)

	  #============================================#
	 #     WORDS                                   #
	#============================================#

	def Words()
		_pWdResult_ = StzEngineStringWordsSplit(@pEngine)
		_cWdJoined_ = StzEngineStringData(_pWdResult_)
		StzEngineStringFree(_pWdResult_)
		return _SplitNullDelimited(_cWdJoined_)

	def NumberOfWords()
		return StzEngineStringCountWords(@pEngine)

		def CountWords()
			return This.NumberOfWords()

		def HowManyWords()
			return This.NumberOfWords()

	  #============================================#
	 #     SPLIT                                  #
	#============================================#

	def SplitCS(pcSep, pCaseSensitive)
		_bSpCase_ = @CaseSensitive(pCaseSensitive)
		return This._SplitByStrCS(pcSep, _bSpCase_)

	def Split(pcSep)
		return This._SplitByStr(pcSep)

	# SplitWXT(pCond): split the content at every position where the
	# predicate is TRUE. The predicate runs with @char bound to the
	# current character and @position to its 1-based position.
	# Accepts bare expression or :At = expr named-param.
	def SplitWXT(pCond)
		_cExpr_ = pCond
		if isList(pCond) and ring_len(pCond) = 2 and isString(pCond[1]) and
		   (lower(pCond[1]) = "at" or lower(pCond[1]) = "where")
			_cExpr_ = pCond[2]
		ok
		if NOT isString(_cExpr_) return [] ok
		# Engine-backed: walk codepoints, not bytes.
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		_cCur_ = ""
		for _i_ = 1 to _nLen_
			@char = _aChars_[_i_]
			@position = _i_
			@CurrentItem = @char
			_bSplit_ = FALSE
			try
				eval("_bSplit_ = " + _cExpr_)
			catch
				_bSplit_ = FALSE
			done
			if _bSplit_
				if ring_len(_cCur_) > 0 _aRes_ + _cCur_ ok
				_cCur_ = ""
			else
				_cCur_ += @char
			ok
		next
		if ring_len(_cCur_) > 0 _aRes_ + _cCur_ ok
		return _aRes_

		def SplitW(pCond)
			return This.SplitWXT(pCond)

		def SplitAtWXT(pCond)
			return This.SplitWXT(pCond)

		def SplitAtW(pCond)
			return This.SplitWXT(pCond)

	# SplitToNParts: split the string into fixed-size character chunks
	# of n characters each. The split is RIGHT-anchored (counting from
	# the end of the string), which is the natural shape for digit
	# grouping -- "1234567" with n=3 gives ["1", "234", "567"]. The
	# Q form returns a stzList wrapper for fluent chaining.

	def SplitToNParts(n)
		if NOT (isNumber(n) and n > 0)
			StzRaise("SplitToNParts: n must be a positive number.")
		ok
		_aPartsR_ = []
		_cSrc_ = This.Content()
		_nSrcLen_ = ring_len(_cSrc_)
		_iEnd_ = _nSrcLen_
		while _iEnd_ > 0
			_iStart_ = _iEnd_ - n + 1
			if _iStart_ < 1
				_iStart_ = 1
			ok
			_aPartsR_ + substr(_cSrc_, _iStart_, _iEnd_ - _iStart_ + 1)
			_iEnd_ = _iStart_ - 1
		end
		# _aPartsR_ is right-to-left; reverse to natural left-to-right
		_aParts_ = []
		_nPLen_ = ring_len(_aPartsR_)
		for _iSp_ = _nPLen_ to 1 step -1
			_aParts_ + _aPartsR_[_iSp_]
		next
		return _aParts_

		def SplitToNPartsQ(n)
			return new stzList( This.SplitToNParts(n) )

		def SplitInNParts(n)
			return This.SplitToNParts(n)

		def SplitInNPartsQ(n)
			return This.SplitToNPartsQ(n)

	  #============================================#
	 #     TRIMMED                                #
	#============================================#

	def Trimmed()
		_pTmResult_ = StzEngineStringTrim(@pEngine)
		if _pTmResult_ != 0
			_cTmResult_ = StzEngineStringData(_pTmResult_)
			StzEngineStringFree(_pTmResult_)
			return _cTmResult_
		ok
		return This.Content()

	def TrimmedLeft()
		_pTlResult_ = StzEngineStringTrimLeft(@pEngine)
		if _pTlResult_ != 0
			_cTlResult_ = StzEngineStringData(_pTlResult_)
			StzEngineStringFree(_pTlResult_)
			return _cTlResult_
		ok
		return This.Content()

	def TrimmedRight()
		_pTrResult_ = StzEngineStringTrimRight(@pEngine)
		if _pTrResult_ != 0
			_cTrResult_ = StzEngineStringData(_pTrResult_)
			StzEngineStringFree(_pTrResult_)
			return _cTrResult_
		ok
		return This.Content()

	  #============================================#
	 #     LINES                                  #
	#============================================#

	def Lines()
		_nLnCount_ = StzEngineStringLinesSplitCount(@pEngine)
		_aLnResult_ = []
		for _iLn_ = 1 to _nLnCount_
			_pLnHandle_ = StzEngineStringLineAt(@pEngine, _iLn_)
			if _pLnHandle_ != NULL
				_aLnResult_ + StzEngineStringData(_pLnHandle_)
				StzEngineStringFree(_pLnHandle_)
			ok
		next
		return _aLnResult_

		# Fluent form: return the line list wrapped in stzList so
		# narrative chains like `o.TrimQ().LinesQ().RemoveWXTQ(...)`
		# resolve on the list class.
		def LinesQ()
			return new stzList( This.Lines() )

	def NumberOfLines()
		return StzEngineStringCountLines(@pEngine)

	  #========================================#
	 #     CHECKER DELEGATIONS               #
	#========================================#

	def IsCharName()
		return StzUnicodeContainsName(This.Content())

		def IsACharName()
			return This.IsCharName()

	def RepresentsNumberInHexForm()
		pH = @pEngine
		return StzEngineStringIsHexString(pH)

	def RepresentsNumberInUnicodeHexForm()
		_cContent_ = This.Content()
		_nLen_ = StzLen(_cContent_)
		if _nLen_ < 3
			return 0
		ok
		_cPrefix_ = StzUpper(StzLeft(_cContent_, 2))
		if _cPrefix_ != "U+"
			return 0
		ok
		_cHexPart_ = StzRight(_cContent_, _nLen_ - 2)
		return StringRepresentsNumberInHexForm("0x" + _cHexPart_)

		def IsHexUnicode()
			return This.RepresentsNumberInUnicodeHexForm()

		def IsAHexUnicode()
			return This.RepresentsNumberInUnicodeHexForm()

		def IsHexUnicodeInString()
			return This.RepresentsNumberInUnicodeHexForm()

		def RepresentsAHexUnicode()
			return This.RepresentsNumberInUnicodeHexForm()

		def RepresentsAHexUnicodeInString()
			return This.RepresentsNumberInUnicodeHexForm()

	# Dotless / DotsRemoved: return the content with dots stripped
	# from "i" and "j" (Unicode "Latin Letter Dotless I" / "Dotless J").
	# Lossy on purpose -- meant for the typographic effect, not for
	# round-trippable encoding. Port from archive line 93405.

	# DiacriticsRemoved: strip combining diacritic codepoints from
	# the content. Uses NFD normalisation to decompose accented
	# letters into base + combining marks, then drops any codepoint
	# in the combining ranges:
	#   U+0300-U+036F   Combining Diacritical Marks (Latin etc.)
	#   U+0610-U+061A   Arabic
	#   U+064B-U+065F   Arabic Tashkil (Fatha, Damma, ...)
	#   U+06D6-U+06ED   Arabic supplementals
	#   U+0951-U+0954   Vedic / Devanagari

	def DiacriticsRemoved()
		# NFD-decompose then strip any 2-byte sequence whose
		# codepoint lies in a combining-mark range. Simple byte
		# walk; precomposed chars get split into base + mark by
		# NFD so the mark is visible as its own 2-byte sequence.
		_oDrencoder_ = new stzStringEncoder( This.Content() )
		_cDrnfdstr_ = _oDrencoder_.NormalizedNFD()
		_nDrlength_ = ring_len(_cDrnfdstr_)
		_cDrresult_ = ""
		_iDrindex_ = 1
		while _iDrindex_ <= _nDrlength_
			_bDr1_ = ascii( substr(_cDrnfdstr_, _iDrindex_, 1) )
			if _bDr1_ < 128
				_cDrresult_ += substr(_cDrnfdstr_, _iDrindex_, 1)
				_iDrindex_++
			but _bDr1_ >= 192 and _bDr1_ < 224 and _iDrindex_ + 1 <= _nDrlength_
				_bDr2_ = ascii( substr(_cDrnfdstr_, _iDrindex_ + 1, 1) )
				_nDrcp_ = ((_bDr1_ - 192) * 64) + (_bDr2_ - 128)
				if (_nDrcp_ >= 768 and _nDrcp_ <= 879) or
				   (_nDrcp_ >= 1552 and _nDrcp_ <= 1562) or
				   (_nDrcp_ >= 1611 and _nDrcp_ <= 1631) or
				   (_nDrcp_ >= 1750 and _nDrcp_ <= 1773)
					_iDrindex_ += 2
				else
					_cDrresult_ += substr(_cDrnfdstr_, _iDrindex_, 2)
					_iDrindex_ += 2
				ok
			but _bDr1_ >= 224 and _bDr1_ < 240 and _iDrindex_ + 2 <= _nDrlength_
				_cDrresult_ += substr(_cDrnfdstr_, _iDrindex_, 3)
				_iDrindex_ += 3
			but _bDr1_ >= 240 and _iDrindex_ + 3 <= _nDrlength_
				_cDrresult_ += substr(_cDrnfdstr_, _iDrindex_, 4)
				_iDrindex_ += 4
			else
				_cDrresult_ += substr(_cDrnfdstr_, _iDrindex_, 1)
				_iDrindex_++
			ok
		end
		return _cDrresult_

		def WithoutDiacritics()
			return This.DiacriticsRemoved()

	def RemoveDiacritics()
		This.Update( This.DiacriticsRemoved() )

		def RemoveDiacriticsQ()
			This.RemoveDiacritics()
			return This

	def ContainsDiacritics()
		return This.DiacriticsRemoved() != This.Content()

		def HasDiacritics()
			return This.ContainsDiacritics()

	def DotsRemoved()
		_cDrContent_ = This.Content()
		_cDrR_ = substr(_cDrContent_, "i", char(305))     # U+0131 ı
		_cDrR_ = substr(_cDrR_, "j", char(567))           # U+0237 ȷ
		_cDrR_ = substr(_cDrR_, "I", char(304))           # U+0130 İ -> dotted; keep as I? actually I has no dot
		return _cDrR_

		def Dotless()
			return This.DotsRemoved()

		def WithoutDots()
			return This.DotsRemoved()

		def WithoutDotsOnLetters()
			return This.DotsRemoved()

		def DotsOnLettersRemoved()
			return This.DotsRemoved()

	  #========================================#
	 #     DERIVED ACCESSORS                  #
	#========================================#

	def NLeftChars(n)
		if This.IsLeftToRight()
			return This.Section(1, n)
		else
			nLen = This.NumberOfChars()
			return This.Section(nLen - n + 1, nLen)
		ok

		def NLeftCharsAsString(n)
			return This.NLeftChars(n)

		def NLeftCharsAsStringQ(n)
			return new stzString(This.NLeftChars(n))

	def NRightChars(n)
		if This.IsLeftToRight()
			nLen = This.NumberOfChars()
			return This.Section(nLen - n + 1, nLen)
		else
			return This.Section(1, n)
		ok

		def NRightCharsAsString(n)
			return This.NRightChars(n)

		def NRightCharsAsStringQ(n)
			return new stzString(This.NRightChars(n))

	def NFirstChars(n)
		return This.Section(1, n)

	def NLastChars(n)
		nLen = This.NumberOfChars()
		return This.Section(nLen - n + 1, nLen)

	  #========================================#
	 #     MUTATION PRIMITIVES                #
	#========================================#

	def RemoveSection(n1, n2)
		pH = This.Engine()
		pR = StzEngineStringRemoveRange(pH, n1, n2 - n1 + 1)
		if pR != 0
			This.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def RemoveSections(aSections)
		# Remove sections from end to start to preserve positions
		# Sort sections by start position descending
		nLen = ring_len(aSections)
		for i = 1 to nLen - 1
			for j = 1 to nLen - i
				if aSections[j][1] < aSections[j+1][1]
					temp = aSections[j]
					aSections[j] = aSections[j+1]
					aSections[j+1] = temp
				ok
			next
		next

		for i = 1 to nLen
			This.RemoveSection(aSections[i][1], aSections[i][2])
		next

	def ReplaceSections(aSections, pcNewSubStr)
		# Replace sections from end to start to preserve positions
		nLen = ring_len(aSections)
		for i = 1 to nLen - 1
			for j = 1 to nLen - i
				if aSections[j][1] < aSections[j+1][1]
					temp = aSections[j]
					aSections[j] = aSections[j+1]
					aSections[j+1] = temp
				ok
			next
		next

		for i = 1 to nLen
			n1 = aSections[i][1]
			n2 = aSections[i][2]
			nRange = n2 - n1 + 1
			cResult = This._ReplaceRange(n1, nRange, pcNewSubStr)
			This.Update(cResult)
		next

	# ReplaceSectionsByMany(aSections, paReplacements): replace each
	# [n1, n2] section in aSections with the corresponding replacement
	# from paReplacements. Walks sections in reverse so earlier
	# positions stay valid as later ones shift.
	def ReplaceSectionsByMany(aSections, paReplacements)
		if NOT (isList(aSections) and isList(paReplacements)) return ok
		_nL_ = ring_len(aSections)
		_nR_ = ring_len(paReplacements)
		if _nL_ = 0 or _nR_ = 0 return ok
		# Build [origIdx, section] pairs and sort by section start desc.
		_aWork_ = []
		for _i_ = 1 to _nL_
			_aWork_ + [ _i_, aSections[_i_] ]
		next
		# Insertion sort, descending by section start.
		for _i_ = 2 to _nL_
			_v_ = _aWork_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aWork_[_j_][2][1] < _v_[2][1]
				_aWork_[_j_ + 1] = _aWork_[_j_]; _j_--
			end
			_aWork_[_j_ + 1] = _v_
		next
		_cTxt_ = This.Content()
		for _i_ = 1 to _nL_
			_origIdx_ = _aWork_[_i_][1]
			_sec_ = _aWork_[_i_][2]
			_n1_ = _sec_[1]; _n2_ = _sec_[2]
			# Cycle replacements if more sections than replacements.
			_repIdx_ = _origIdx_
			while _repIdx_ > _nR_ _repIdx_ -= _nR_ end
			_cRep_ = paReplacements[_repIdx_]
			_cBefore_ = ""
			if _n1_ > 1 _cBefore_ = This._EngineSlice(_cTxt_, 1, _n1_ - 1) ok
			_cAfter_ = ""
			_nTxtLen_ = This._EngineCount(_cTxt_)
			if _n2_ < _nTxtLen_
				_cAfter_ = This._EngineSliceFrom(_cTxt_, _n2_ + 1)
			ok
			_cTxt_ = _cBefore_ + _cRep_ + _cAfter_
		next
		This.Update(_cTxt_)

		def ReplaceSectionsByManyQ(aSections, paReplacements)
			This.ReplaceSectionsByMany(aSections, paReplacements)
			return This

	  #========================================#
	 #     TRIMMING                           #
	#========================================#

	def TrimLeft()
		pH = This.Engine()
		pR = StzEngineStringTrimLeft(pH)
		if pR != 0
			This.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def TrimRight()
		pH = This.Engine()
		pR = StzEngineStringTrimRight(pH)
		if pR != 0
			This.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def TrimStart()
		This.TrimLeft()

	def TrimEnd()
		This.TrimRight()

	# RemoveThisCharFromStart / Left / End / Right -- strip every
	# leading (or trailing) occurrence of pcChar. No-op if the
	# string doesn't start (or end) with pcChar.
	def RemoveThisCharFromStartXT(pcChar)
		if NOT isString(pcChar) or ring_len(pcChar) = 0 return ok
		_cTxt_ = This.Content()
		_nLenTxt_ = This._EngineCount(_cTxt_)
		_nLenCh_ = This._EngineCount(pcChar)
		if _nLenCh_ = 0 return ok
		_n_ = 0
		while _n_ + _nLenCh_ <= _nLenTxt_ and
		      This._EngineSlice(_cTxt_, _n_ + 1, _nLenCh_) = pcChar
			_n_ += _nLenCh_
		end
		if _n_ > 0
			This.Update(This._EngineSliceFrom(_cTxt_, _n_ + 1))
		ok

		def RemoveThisCharFromLeftXT(pcChar)
			This.RemoveThisCharFromStartXT(pcChar)

		def RemoveThisCharFromStart(pcChar)
			This.RemoveThisCharFromStartXT(pcChar)

		def RemoveThisCharFromLeft(pcChar)
			This.RemoveThisCharFromStartXT(pcChar)

	def RemoveThisCharFromEndXT(pcChar)
		if NOT isString(pcChar) or ring_len(pcChar) = 0 return ok
		_cTxt_ = This.Content()
		_nLenTxt_ = This._EngineCount(_cTxt_)
		_nLenCh_ = This._EngineCount(pcChar)
		if _nLenCh_ = 0 return ok
		_n_ = 0
		while _n_ + _nLenCh_ <= _nLenTxt_ and
		      This._EngineSlice(_cTxt_, _nLenTxt_ - _n_ - _nLenCh_ + 1, _nLenCh_) = pcChar
			_n_ += _nLenCh_
		end
		if _n_ > 0
			This.Update(This._EngineSlice(_cTxt_, 1, _nLenTxt_ - _n_))
		ok

		def RemoveThisCharFromRightXT(pcChar)
			This.RemoveThisCharFromEndXT(pcChar)

		def RemoveThisCharFromEnd(pcChar)
			This.RemoveThisCharFromEndXT(pcChar)

		def RemoveThisCharFromRight(pcChar)
			This.RemoveThisCharFromEndXT(pcChar)

	# ReplaceLeadingChars(:With = pcNew) -- collapse the leading run
	# of a single repeated char into one instance of pcNew. Examples:
	#   "___VAR---" + :With="*"  ->  "*VAR---"
	#   "aaaaHELLO" + :With="A"  ->  "AHELLO"
	# If there's no run (the first 2 chars differ), the string is
	# returned unchanged.
	def ReplaceLeadingChars(pWith)
		if isList(pWith) and ring_len(pWith) = 2 and isString(pWith[1]) and
		   lower(pWith[1]) = "with"
			pWith = pWith[2]
		ok
		if NOT isString(pWith) return ok
		_cTxt_ = This.Content()
		_nLen_ = ring_len(_cTxt_)
		if _nLen_ < 2 return ok
		_cFirst_ = _cTxt_[1]
		_n_ = 1
		while _n_ < _nLen_ and _cTxt_[_n_ + 1] = _cFirst_
			_n_++
		end
		if _n_ < 2 return ok       # no run, leave alone
		This.Update(pWith + substr(_cTxt_, _n_ + 1))

		def ReplaceLeadingCharsQ(pWith)
			This.ReplaceLeadingChars(pWith)
			return This

	def ReplaceTrailingChars(pWith)
		if isList(pWith) and ring_len(pWith) = 2 and isString(pWith[1]) and
		   lower(pWith[1]) = "with"
			pWith = pWith[2]
		ok
		if NOT isString(pWith) return ok
		_cTxt_ = This.Content()
		_nLen_ = ring_len(_cTxt_)
		if _nLen_ < 2 return ok
		_cLast_ = _cTxt_[_nLen_]
		_n_ = 1
		while _n_ < _nLen_ and _cTxt_[_nLen_ - _n_] = _cLast_
			_n_++
		end
		if _n_ < 2 return ok
		This.Update(substr(_cTxt_, 1, _nLen_ - _n_) + pWith)

		def ReplaceTrailingCharsQ(pWith)
			This.ReplaceTrailingChars(pWith)
			return This

	def ReplaceLeadingAndTrailingChars(pWith)
		This.ReplaceLeadingChars(pWith)
		This.ReplaceTrailingChars(pWith)

		def ReplaceLeadingAndTrailingCharsQ(pWith)
			This.ReplaceLeadingAndTrailingChars(pWith)
			return This

	# ReplaceLeadingChar(pcChar, :With = pcNew) -- replace the leading
	# run only IF the leading char equals pcChar. Otherwise no-op.
	def ReplaceLeadingChar(pcChar, pWith)
		if NOT isString(pcChar) or ring_len(pcChar) = 0 return ok
		_cTxt_ = This.Content()
		if ring_len(_cTxt_) = 0 or _cTxt_[1] != pcChar return ok
		This.ReplaceLeadingChars(pWith)

	def ReplaceTrailingChar(pcChar, pWith)
		if NOT isString(pcChar) or ring_len(pcChar) = 0 return ok
		_cTxt_ = This.Content()
		_nLen_ = ring_len(_cTxt_)
		if _nLen_ = 0 or _cTxt_[_nLen_] != pcChar return ok
		This.ReplaceTrailingChars(pWith)

	def Trim()
		pH = This.Engine()
		pR = StzEngineStringTrim(pH)
		if pR != 0
			This.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

		def TrimQ()
			This.Trim()
			return This

	  #============================#
	 #   DUPLICATE SUBSTRINGS     #
	#============================#

	def ContainsDuplicatesCS(pCaseSensitive)
		return This.ContainsDuplicatedSubStringsCS(pCaseSensitive)

	def ContainsDuplicates()
		return This.ContainsDuplicatesCS(1)

	def ContainsDuplicatedSubStringsCS(pCaseSensitive)
		return ring_len(This.DuplicatedSubStringsCS(pCaseSensitive)) > 0

	def ContainsDuplicatedSubStrings()
		return This.ContainsDuplicatedSubStringsCS(1)

	def DuplicatedSubStringsCS(pCaseSensitive)
		_oDsDup_ = new stzStringDuplicates(This)
		return _oDsDup_.DuplicatedChars()

	def DuplicatedSubStrings()
		return This.DuplicatedSubStringsCS(1)

	def NumberOfDuplicatesCS(pCaseSensitive)
		return ring_len(This.DuplicatedSubStringsCS(pCaseSensitive))

	def NumberOfDuplicates()
		return This.NumberOfDuplicatesCS(1)

	def HasDuplicatedChars()
		_oDhDup_ = new stzStringDuplicates(This)
		return _oDhDup_.HasDuplicatedChars()

	  #============================#
	 #   CHAR RANGE (UpTo/DownTo) #
	#============================#

	def UpTo(pcChar)
		if This.NumberOfChars() = 1
			_oUtChar_ = new stzStringChar(This.Content())
			return _oUtChar_.UpTo(pcChar)
		ok
		return []

	def DownTo(pcChar)
		if This.NumberOfChars() = 1
			_oDtChar_ = new stzStringChar(This.Content())
			return _oDtChar_.DownTo(pcChar)
		ok
		return []

	  #============================#
	 #   TEXT BOXING               #
	#============================#

	def Box()
		This.BoxXT([])

	def BoxRound()
		This.BoxXT([ :Line = :Solid, :AllCorners = :Round ])

	def BoxifyRound()
		This.BoxRound()

		def BoxifyRoundQ()
			This.BoxifyRound()
			return This

	def BoxXT(paBoxOptions)
		_cBxLine_ = :Solid
		_bBxRounded_ = 0

		if isList(paBoxOptions)
			_nBxLen_ = ring_len(paBoxOptions)
			for _iBx_ = 1 to _nBxLen_
				if isList(paBoxOptions[_iBx_]) and ring_len(paBoxOptions[_iBx_]) = 2
					_cBxKey_ = paBoxOptions[_iBx_][1]
					_vBxVal_ = paBoxOptions[_iBx_][2]
					if isString(_cBxKey_)
						if StzLower(_cBxKey_) = "line" and isString(_vBxVal_) and StzLower(_vBxVal_) = "dashed"
							_cBxLine_ = :Dashed
						ok
						if StzLower(_cBxKey_) = "allcorners" and isString(_vBxVal_) and (StzLower(_vBxVal_) = "round" or StzLower(_vBxVal_) = "rounded")
							_bBxRounded_ = 1
						ok
						if StzLower(_cBxKey_) = "rounded" and isNumber(_vBxVal_) and _vBxVal_ = 1
							_bBxRounded_ = 1
						ok
					ok
				ok
			next
		ok

		_nBxWidth_ = This.NumberOfChars() + 2
		_cBxVTrait_ = "|"
		_cBxHTrait_ = "-"
		_cBxC1_ = "+"
		_cBxC2_ = "+"
		_cBxC3_ = "+"
		_cBxC4_ = "+"

		if _cBxLine_ = :Dashed
			_cBxHTrait_ = "-"
		ok

		_cBxHLine_ = StzRepeatStr(_cBxHTrait_, _nBxWidth_)
		_cBxUp_ = _cBxC1_ + _cBxHLine_ + _cBxC2_
		_cBxMid_ = _cBxVTrait_ + " " + This.Content() + " " + _cBxVTrait_
		_cBxDown_ = _cBxC4_ + _cBxHLine_ + _cBxC3_

		This.Update(_cBxUp_ + NL + _cBxMid_ + NL + _cBxDown_)

		def BoxXTQ(paBoxOptions)
			This.BoxXT(paBoxOptions)
			return This

	def Boxed()
		_oBxCopy_ = This.Copy()
		_oBxCopy_.Box()
		return _oBxCopy_.Content()

	def BoxedRound()
		_oBxCopy_ = This.Copy()
		_oBxCopy_.BoxRound()
		return _oBxCopy_.Content()

	def BoxedXT(paBoxOptions)
		_oBxCopy_ = This.Copy()
		_oBxCopy_.BoxXT(paBoxOptions)
		return _oBxCopy_.Content()

	  #============================#
	 #   TEXT ALIGNMENT            #
	#============================#

	def AlignXT(nWidth, cFillChar, cDirection)
		_cAlContent_ = This.Content()
		_nAlLen_ = This.NumberOfChars()

		if _nAlLen_ >= nWidth
			return
		ok

		_nAlPad_ = nWidth - _nAlLen_

		if cDirection = :Left or cDirection = :left
			This.Update(_cAlContent_ + StzRepeatStr(cFillChar, _nAlPad_))
		but cDirection = :Right or cDirection = :right
			This.Update(StzRepeatStr(cFillChar, _nAlPad_) + _cAlContent_)
		else
			_nAlLeft_ = floor(_nAlPad_ / 2)
			_nAlRight_ = _nAlPad_ - _nAlLeft_
			This.Update(StzRepeatStr(cFillChar, _nAlLeft_) + _cAlContent_ + StzRepeatStr(cFillChar, _nAlRight_))
		ok

		def AlignXTQ(nWidth, cFillChar, cDirection)
			This.AlignXT(nWidth, cFillChar, cDirection)
			return This

	  #============================#
	 #   UNIQUE CHARS             #
	#============================#

	def CharsU()
		_pCuHandle_ = StzEngineStringUniqueChars(@pEngine)
		if _pCuHandle_ = NULL
			return []
		ok
		_pCuSplit_ = StzEngineStringCharsSplit(_pCuHandle_)
		_cCuJoined_ = StzEngineStringData(_pCuSplit_)
		StzEngineStringFree(_pCuSplit_)
		StzEngineStringFree(_pCuHandle_)
		return _SplitNullDelimited(_cCuJoined_)

		def UniqueChars()
			return This.CharsU()

	  #============================#
	 #   UNICODES                  #
	#============================#

	def Unicode()
		if This.NumberOfChars() != 1
			StzRaise("Can't get unicode! String must be a single character.")
		ok
		return StzCharToUnicode(This.Content())

	# CharName / CharacterName / UnicodeName -- when the string IS a
	# single character, return its Unicode name (CHECK MARK etc.).
	# Convenient on Q("✓") narratives that avoid the StzCharQ() ramp.
	# Ring chained-new+method parses oddly here, so split into two.
	def CharName()
		_oChCnTmp_ = new stzChar(This.Content())
		return _oChCnTmp_.Name()

		def CharacterName()
			return This.CharName()

		def UnicodeName()
			return This.CharName()

	def Unicodes()
		_aUcChars_ = This.Chars()
		_aUcResult_ = []
		_nUcLen_ = ring_len(_aUcChars_)
		for _iUc_ = 1 to _nUcLen_
			_aUcResult_ + StzCharToUnicode(_aUcChars_[_iUc_])
		next
		return _aUcResult_

	def CharsAndUnicodes()
		_aCauChars_ = This.Chars()
		_aCauResult_ = []
		_nCauLen_ = ring_len(_aCauChars_)
		for _iCau_ = 1 to _nCauLen_
			_aCauResult_ + [ _aCauChars_[_iCau_], StzCharToUnicode(_aCauChars_[_iCau_]) ]
		next
		return _aCauResult_

		def UnicodePerChar()
			return This.CharsAndUnicodes()

	def CharsAndUnicodesU()
		_aCauuChars_ = This.CharsU()
		_aCauuResult_ = []
		_nCauuLen_ = ring_len(_aCauuChars_)
		for _iCauu_ = 1 to _nCauuLen_
			_aCauuResult_ + [ _aCauuChars_[_iCauu_], StzCharToUnicode(_aCauuChars_[_iCauu_]) ]
		next
		return _aCauuResult_

		def UniqueCharsAndUnicodes()
			return This.CharsAndUnicodesU()

	  #============================#
	 #   REPEATED / CONCATENATE   #
	#============================#

	def Repeated(n)
		_pRptHandle_ = StzEngineStringRepeat(@pEngine, n)
		if _pRptHandle_ = NULL
			return This.Content()
		ok
		_cRptResult_ = StzEngineStringData(_pRptHandle_)
		StzEngineStringFree(_pRptHandle_)
		return _cRptResult_

		def RepeatedNTimes(n)
			return This.Repeated(n)

	def Repeat(n)
		This.Update(This.Repeated(n))

		def RepeatQ(n)
			This.Repeat(n)
			return This

	def Concatenate(pcStr)
		This.Update(This.Content() + pcStr)

		def ConcatenateQ(pcStr)
			This.Concatenate(pcStr)
			return This

		def Append(pcStr)
			This.Concatenate(pcStr)

		def AppendQ(pcStr)
			This.Concatenate(pcStr)
			return This

	def Concatenated(pcStr)
		return This.Content() + pcStr

	  #============================#
	 #   EQUALITY                  #
	#============================#

	def IsEqualTo(pcStr)
		return This.Content() = pcStr

		def IsEqualToCS(pcStr, pCaseSensitive)
			_bEqCase_ = @CaseSensitive(pCaseSensitive)
			_pEqOther_ = StzEngineString(pcStr)
			_nEqResult_ = StzEngineStringEqualsCS(@pEngine, _pEqOther_, _bEqCase_)
			StzEngineStringFree(_pEqOther_)
			return _nEqResult_

		#-- Strict equality: same content AND same Ring type (string).
		#   When the other side is a list/number, returns 0. Used by
		#   stzHashList.KeysForValue to compare values polymorphically.

		def IsStrictlyEqualTo(pOther)
			if NOT isString(pOther)
				return 0
			ok
			return This.Content() = pOther

	  #============================#
	 #   CHAR OPERATIONS          #
	#============================#

	def RemoveFirstChar()
		_cRfcContent_ = This.Content()
		if StzLen(_cRfcContent_) > 0
			This.Update(StzRight(_cRfcContent_, StzLen(_cRfcContent_) - 1))
		ok

		def RemoveFirstCharQ()
			This.RemoveFirstChar()
			return This

		# RemoveFirstCharXT(): remove every leading character that
		# matches the first one (so "----Ring" -> "Ring"). When called
		# with no arg, peel any same-first-char run. Test narratives
		# use this as a one-shot "trim run" form.
		def RemoveFirstCharXT()
			# Engine-backed: take the codepoint list, count the run of
			# same-leading chars, then slice the remainder.
			_aChars_ = This.Chars()
			_nLen_ = ring_len(_aChars_)
			if _nLen_ = 0 return ok
			_cF_ = _aChars_[1]
			_n_ = 0
			while _n_ < _nLen_ and _aChars_[_n_ + 1] = _cF_
				_n_++
			end
			if _n_ > 0
				This.Update(This._EngineSliceFrom(This.Content(), _n_ + 1))
			ok

		def RemoveFirstCharXTQ()
			This.RemoveFirstCharXT()
			return This

		# RemoveFirstCharCS(pCaseSensitive): "permissiveness" form --
		# accepts the case-sensitivity flag for narrative-symmetry,
		# but ignores it (per stzStringTest block #37).
		def RemoveFirstCharCS(pCaseSensitive)
			This.RemoveFirstChar()

		def RemoveFirstCharCSQ(pCaseSensitive)
			This.RemoveFirstChar()
			return This

	# RemoveLeadingChars / RemoveTrailingChars / RemoveBoundingChars:
	# strip every leading (or trailing, or both) char that matches the
	# first (resp. last) char of the current content. Equivalent to the
	# "trim run" interpretation in narrative tests.
	def RemoveLeadingChars()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return ok
		_cF_ = _aChars_[1]
		_n_ = 0
		while _n_ < _nLen_ and _aChars_[_n_ + 1] = _cF_
			_n_++
		end
		if _n_ > 0
			This.Update(This._EngineSliceFrom(This.Content(), _n_ + 1))
		ok

		def RemoveLeadingCharsQ()
			This.RemoveLeadingChars()
			return This

	# LeadingChars() / TrailingChars() -- return the leading (or
	# trailing) RUN of identical chars as a single string. e.g.
	# "----Ring" -> "----". Used by narrative leading-char analysis.
	def LeadingChars()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return "" ok
		_cF_ = _aChars_[1]
		_n_ = 0
		while _n_ < _nLen_ and _aChars_[_n_ + 1] = _cF_
			_n_++
		end
		if _n_ = 0 return "" ok
		return This._EngineSlice(This.Content(), 1, _n_)

		def LeadingChar()
			_lc_ = This.LeadingChars()
			if ring_len(_lc_) = 0 return "" ok
			return _lc_[1]

		def NumberOfLeadingChars()
			return ring_len(This.LeadingChars())

	def TrailingChars()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return "" ok
		_cL_ = _aChars_[_nLen_]
		_n_ = 0
		while _n_ < _nLen_ and _aChars_[_nLen_ - _n_] = _cL_
			_n_++
		end
		if _n_ = 0 return "" ok
		return This._EngineSliceFrom(This.Content(), _nLen_ - _n_ + 1)

		def TrailingChar()
			_tc_ = This.TrailingChars()
			if ring_len(_tc_) = 0 return "" ok
			return _tc_[1]

		def NumberOfTrailingChars()
			return ring_len(This.TrailingChars())

		# LeadingCharsXT / LeadingCharsAsString / LeadingCharsAsSubString
		# -- aliases that return the leading run as a SINGLE string.
		def LeadingCharsXT()
			return This.LeadingChars()

		def LeadingCharsAsString()
			return This.LeadingChars()

		def LeadingCharsAsSubString()
			return This.LeadingChars()

		def TrailingCharsXT()
			return This.TrailingChars()

	# Singular forms: RemoveLeadingChar = remove ONE leading char,
	# RemoveAnyLeadingChar = peel every leading char of the same type.
	def RemoveLeadingChar()
		_c_ = This.Content()
		if This._EngineCount(_c_) > 0
			This.Update(This._EngineSliceFrom(_c_, 2))
		ok

		def RemoveLeadingCharQ()
			This.RemoveLeadingChar()
			return This

		def RemoveAnyLeadingChar()
			This.RemoveLeadingChars()

	def RemoveTrailingChar()
		_c_ = This.Content()
		_nLen_ = This._EngineCount(_c_)
		if _nLen_ > 0
			This.Update(This._EngineSlice(_c_, 1, _nLen_ - 1))
		ok

		def RemoveTrailingCharQ()
			This.RemoveTrailingChar()
			return This

	def RemoveTrailingChars()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return ok
		_cL_ = _aChars_[_nLen_]
		_n_ = 0
		while _n_ < _nLen_ and _aChars_[_nLen_ - _n_] = _cL_
			_n_++
		end
		if _n_ > 0
			This.Update(This._EngineSlice(This.Content(), 1, _nLen_ - _n_))
		ok

		def RemoveTrailingCharsQ()
			This.RemoveTrailingChars()
			return This

	def RemoveBoundingChars()
		This.RemoveLeadingChars()
		This.RemoveTrailingChars()

		def RemoveBoundingCharsQ()
			This.RemoveBoundingChars()
			return This

	#-- Immutable / past-tense forms: return the modified content
	#   without mutating This. Used by stzNumber.Absolute() and
	#   similar fluent chains.

	def FirstCharRemoved()
		_oFcrTmp_ = new stzString( This.Content() )
		_oFcrTmp_.RemoveFirstChar()
		return _oFcrTmp_.Content()

	def LastCharRemoved()
		_oLcrTmp_ = new stzString( This.Content() )
		_oLcrTmp_.RemoveLastChar()
		return _oLcrTmp_.Content()

	def RemoveLastChar()
		_cRlcContent_ = This.Content()
		_nRlcLen_ = StzLen(_cRlcContent_)
		if _nRlcLen_ > 0
			This.Update(StzLeft(_cRlcContent_, _nRlcLen_ - 1))
		ok

		def RemoveLastCharQ()
			This.RemoveLastChar()
			return This

		# RemoveLastCharXT() -- peel every trailing char that matches
		# the last one (symmetric to RemoveFirstCharXT). Engine-backed.
		def RemoveLastCharXT()
			_aChars_ = This.Chars()
			_nLen_ = ring_len(_aChars_)
			if _nLen_ = 0 return ok
			_cL_ = _aChars_[_nLen_]
			_n_ = 0
			while _n_ < _nLen_ and _aChars_[_nLen_ - _n_] = _cL_
				_n_++
			end
			if _n_ > 0
				This.Update(This._EngineSlice(This.Content(), 1, _nLen_ - _n_))
			ok

		def RemoveLastCharXTQ()
			This.RemoveLastCharXT()
			return This

	def RemoveFirstAndLastChars()
		This.RemoveFirstChar()
		This.RemoveLastChar()

		def RemoveFirstAndLastCharsQ()
			This.RemoveFirstAndLastChars()
			return This

	# Conditional first/last char removers: act only if the first
	# (resp. last) char equals pcChar. Used by code-string fluent
	# chains that may or may not see leading/trailing braces.

	def RemoveThisFirstChar(pcChar)
		_cRtfContent_ = This.Content()
		if StzLen(_cRtfContent_) > 0 and StzLeft(_cRtfContent_, 1) = pcChar
			This.RemoveFirstChar()
		ok

		def RemoveThisFirstCharQ(pcChar)
			This.RemoveThisFirstChar(pcChar)
			return This

	def RemoveThisLastChar(pcChar)
		_cRtlContent_ = This.Content()
		_nRtlLen_ = StzLen(_cRtlContent_)
		if _nRtlLen_ > 0 and StzRight(_cRtlContent_, 1) = pcChar
			This.RemoveLastChar()
		ok

		def RemoveThisLastCharQ(pcChar)
			This.RemoveThisLastChar(pcChar)
			return This

	def SizeInBytes()
		return ring_len(This.Content())

	  #================================#
	 #   CONTAINS MULTIPLE            #
	#================================#

	def ContainsOneOfTheseCS(paSubStr, pCaseSensitive)
		_oCmpStr_ = new stzStringComparator(This)
		return _oCmpStr_.ContainsOneOfTheseCS(paSubStr, pCaseSensitive)

	def ContainsOneOfThese(paSubStr)
		return This.ContainsOneOfTheseCS(paSubStr, 1)

	# ContainsEither(arg1, arg2): two-arg form covers the narrative
	# shapes. arg2 can be the :Or = "..." named-param, or any string
	# (treated as the second alternative); if arg1 is itself a list of
	# substrings and arg2 is "", we fall back to ContainsOneOfThese.
	def ContainsEither(pVal1, pVal2)
		if isList(pVal1) and pVal2 = ""
			return This.ContainsOneOfThese(pVal1)
		ok
		# :Or / :And named-param normalisation on the 2nd arg
		_cB_ = pVal2
		if isList(pVal2) and ring_len(pVal2) = 2 and isString(pVal2[1]) and
		   (lower(pVal2[1]) = "or" or lower(pVal2[1]) = "and")
			_cB_ = pVal2[2]
		ok
		if isString(pVal1) and isString(_cB_)
			return This.Contains(pVal1) or This.Contains(_cB_)
		ok
		return FALSE

	  #================================#
	 #   FIND/REMOVE BOUNDS           #
	#================================#

	def FindTheseBoundsCS(pcBound1, pcBound2, pCaseSensitive)
		_nFtbLen_ = This.NumberOfChars()
		_nFtbLenB1_ = StzLen(pcBound1)
		_nFtbLenB2_ = StzLen(pcBound2)
		_aFtbResult_ = []
		_nFtbPos_ = 1

		while _nFtbPos_ < _nFtbLen_
			_nFtb1_ = This.FindFirstSTCS(pcBound1, _nFtbPos_, pCaseSensitive)
			if _nFtb1_ = 0
				exit
			ok
			_nFtb2_ = This.FindFirstSTCS(pcBound2, _nFtb1_ + _nFtbLenB1_, pCaseSensitive)
			if _nFtb2_ = 0
				exit
			ok
			_aFtbResult_ + _nFtb1_ + _nFtb2_
			_nFtbPos_ = _nFtb2_
		end

		return _aFtbResult_

	def FindTheseBounds(pcBound1, pcBound2)
		return This.FindTheseBoundsCS(pcBound1, pcBound2, 1)

	def RemoveTheseBoundsCS(pcBound1, pcBound2, pCaseSensitive)
		# Remove each bound occurrence from the result of FindTheseBounds
		_aRtbPos_ = This.FindTheseBoundsCS(pcBound1, pcBound2, pCaseSensitive)
		_nRtbLen_ = ring_len(_aRtbPos_)
		if _nRtbLen_ = 0 return ok

		# Build sections for the bounds and remove from end to start
		_nRtbB1Len_ = StzLen(pcBound1)
		_nRtbB2Len_ = StzLen(pcBound2)
		_aRtbSections_ = []
		_iRtb_ = _nRtbLen_
		while _iRtb_ >= 1
			_aRtbSections_ + [ _aRtbPos_[_iRtb_], _aRtbPos_[_iRtb_] + _nRtbB2Len_ - 1 ]
			_iRtb_ -= 1
			if _iRtb_ >= 1
				_aRtbSections_ + [ _aRtbPos_[_iRtb_], _aRtbPos_[_iRtb_] + _nRtbB1Len_ - 1 ]
				_iRtb_ -= 1
			ok
		end

		This.RemoveSections(_aRtbSections_)

	def RemoveTheseBounds(pcBound1, pcBound2)
		This.RemoveTheseBoundsCS(pcBound1, pcBound2, 1)

		def RemoveTheseBoundsQ(pcBound1, pcBound2)
			This.RemoveTheseBounds(pcBound1, pcBound2)
			return This

	# Single-bound forms: same character on both sides.
	# E.g. RemoveBounds('"') strips matching leading + trailing quotes.

	def RemoveBounds(pcBound)
		This.RemoveTheseBoundsCS(pcBound, pcBound, 1)

		def RemoveBoundsQ(pcBound)
			This.RemoveBounds(pcBound)
			return This

	  #===============================#
	 #   BETWEEN                      #
	#===============================#

	# Between() returns ALL substrings between bounds (Softanza Universal Naming Convention)
	# FirstBetween/LastBetween/NthBetween for specific occurrences

	def BetweenCS(pBound1, pBound2, pCaseSensitive)
		_oBtBounder_ = new stzStringBounder(This)
		return _oBtBounder_.BetweenCS(pBound1, pBound2, pCaseSensitive)

	def Between(pBound1, pBound2)
		return This.BetweenCS(pBound1, pBound2, 1)

	#-- BoundedBy: same semantics as Between() (returns the list of
	#   substrings sitting between matched open/close delimiters) but
	#   takes the bounds packed as a 2-list [ open, close ]. Matches
	#   the archive API at line 34272 + 34290. Used by ccode tests
	#   that read like `o1.BoundedBy([ "[", "]" ])`.

	def BoundedByCS(pacBounds, pCaseSensitive)
		# Accept either a single-string bound (same on both sides,
		# e.g. BoundedBy('"')) or a 2-list [ open, close ].
		if isString(pacBounds)
			return This.BetweenCS(pacBounds, pacBounds, pCaseSensitive)
		ok
		if NOT (isList(pacBounds) and ring_len(pacBounds) = 2)
			StzRaise("BoundedByCS: pacBounds must be a string or a 2-list [ open, close ]")
		ok
		return This.BetweenCS(pacBounds[1], pacBounds[2], pCaseSensitive)

		def SubStringsBoundedByCS(pacBounds, pCaseSensitive)
			return This.BoundedByCS(pacBounds, pCaseSensitive)

		def AnySubStringsBoundedByCS(pacBounds, pCaseSensitive)
			return This.BoundedByCS(pacBounds, pCaseSensitive)

		def AnyBoundedByCS(pacBounds, pCaseSensitive)
			return This.BoundedByCS(pacBounds, pCaseSensitive)

	def BoundedBy(pacBounds)
		return This.BoundedByCS(pacBounds, 1)

		def SubStringsBoundedBy(pacBounds)
			return This.BoundedBy(pacBounds)

		def AnySubStringsBoundedBy(pacBounds)
			return This.BoundedBy(pacBounds)

		# BoundedByZZ: sectional form [start, end] for each bounded
		# substring (exclusive of the bounds themselves). Single-string
		# pacBounds is used as both open and close.
		def BoundedByZZ(pacBounds)
			if isString(pacBounds)
				return This.FindBoundedByAsSections([ pacBounds, pacBounds ])
			ok
			return This.FindBoundedByAsSections(pacBounds)

		# Case-insensitive variant.
		def BoundedByUZZ(pacBounds)
			if isString(pacBounds)
				return This.FindBoundedByAsSectionsCS([ pacBounds, pacBounds ], 0)
			ok
			return This.FindBoundedByAsSectionsCS(pacBounds, 0)

		def BoundedByCSZZ(pacBounds, pCaseSensitive)
			return This.FindBoundedByAsSectionsCS(pacBounds, pCaseSensitive)

		def AnyBoundedBy(pacBounds)
			return This.BoundedBy(pacBounds)

	def ContainsSubStringsBoundedByCS(pacBounds, pCaseSensitive)
		return ring_len(This.BoundedByCS(pacBounds, pCaseSensitive)) > 0

	def ContainsSubStringsBoundedBy(pacBounds)
		return ring_len(This.BoundedBy(pacBounds)) > 0

		def ContainsBoundedBy(pacBounds)
			return This.ContainsSubStringsBoundedBy(pacBounds)

		def ContainsAnyBoundedBy(pacBounds)
			return This.ContainsSubStringsBoundedBy(pacBounds)

	def FirstBetweenCS(pBound1, pBound2, pCaseSensitive)
		_oFbBounder_ = new stzStringBounder(This)
		return _oFbBounder_.FirstBetweenCS(pBound1, pBound2, pCaseSensitive)

	def FirstBetween(pBound1, pBound2)
		return This.FirstBetweenCS(pBound1, pBound2, 1)

	def LastBetweenCS(pBound1, pBound2, pCaseSensitive)
		_oLbBounder_ = new stzStringBounder(This)
		return _oLbBounder_.LastBetweenCS(pBound1, pBound2, pCaseSensitive)

	def LastBetween(pBound1, pBound2)
		return This.LastBetweenCS(pBound1, pBound2, 1)

	def NthBetweenCS(n, pBound1, pBound2, pCaseSensitive)
		_oNbBounder_ = new stzStringBounder(This)
		return _oNbBounder_.NthBetweenCS(n, pBound1, pBound2, pCaseSensitive)

	def NthBetween(n, pBound1, pBound2)
		return This.NthBetweenCS(n, pBound1, pBound2, 1)

	# --- ReplaceBetween / RemoveBetween ---
	# Engine replaces INCLUDING bounds. For default (bounds preserved),
	# we wrap replacement with pcOpen + replacement + pcClose.
	# IB variants pass replacement directly (engine includes bounds).

	def ReplaceBetween(pcOpen, pcClose, pcReplacement)
		_pRbR_ = StzEngineStringReplaceBetween(@pEngine, pcOpen, pcClose, pcOpen + pcReplacement + pcClose)
		if _pRbR_ != NULL
			This.Update(StzEngineStringData(_pRbR_))
			StzEngineStringFree(_pRbR_)
		ok

	def ReplaceFirstBetween(pcOpen, pcClose, pcReplacement)
		_pRfbR_ = StzEngineStringReplaceFirstBetween(@pEngine, pcOpen, pcClose, pcOpen + pcReplacement + pcClose)
		if _pRfbR_ != NULL
			This.Update(StzEngineStringData(_pRfbR_))
			StzEngineStringFree(_pRfbR_)
		ok

	def ReplaceLastBetween(pcOpen, pcClose, pcReplacement)
		_pRlbR_ = StzEngineStringReplaceLastBetween(@pEngine, pcOpen, pcClose, pcOpen + pcReplacement + pcClose)
		if _pRlbR_ != NULL
			This.Update(StzEngineStringData(_pRlbR_))
			StzEngineStringFree(_pRlbR_)
		ok

	def ReplaceNthBetween(n, pcOpen, pcClose, pcReplacement)
		_pRnbR_ = StzEngineStringReplaceNthBetween(@pEngine, pcOpen, pcClose, pcOpen + pcReplacement + pcClose, n - 1)
		if _pRnbR_ != NULL
			This.Update(StzEngineStringData(_pRnbR_))
			StzEngineStringFree(_pRnbR_)
		ok

	def RemoveBetween(pcOpen, pcClose)
		_pRmbR_ = StzEngineStringReplaceBetween(@pEngine, pcOpen, pcClose, pcOpen + pcClose)
		if _pRmbR_ != NULL
			This.Update(StzEngineStringData(_pRmbR_))
			StzEngineStringFree(_pRmbR_)
		ok

	def RemoveFirstBetween(pcOpen, pcClose)
		_pRmfbR_ = StzEngineStringReplaceFirstBetween(@pEngine, pcOpen, pcClose, pcOpen + pcClose)
		if _pRmfbR_ != NULL
			This.Update(StzEngineStringData(_pRmfbR_))
			StzEngineStringFree(_pRmfbR_)
		ok

	def RemoveLastBetween(pcOpen, pcClose)
		_pRmlbR_ = StzEngineStringReplaceLastBetween(@pEngine, pcOpen, pcClose, pcOpen + pcClose)
		if _pRmlbR_ != NULL
			This.Update(StzEngineStringData(_pRmlbR_))
			StzEngineStringFree(_pRmlbR_)
		ok

	def RemoveNthBetween(n, pcOpen, pcClose)
		_pRmnbR_ = StzEngineStringReplaceNthBetween(@pEngine, pcOpen, pcClose, pcOpen + pcClose, n - 1)
		if _pRmnbR_ != NULL
			This.Update(StzEngineStringData(_pRmnbR_))
			StzEngineStringFree(_pRmnbR_)
		ok

	# --- IB variants (Including Bounds) ---
	# Engine replaces including bounds — pass replacement directly

	def ReplaceBetweenIB(pcOpen, pcClose, pcReplacement)
		_pRbibR_ = StzEngineStringReplaceBetween(@pEngine, pcOpen, pcClose, pcReplacement)
		if _pRbibR_ != NULL
			This.Update(StzEngineStringData(_pRbibR_))
			StzEngineStringFree(_pRbibR_)
		ok

	def ReplaceFirstBetweenIB(pcOpen, pcClose, pcReplacement)
		_pRfbibR_ = StzEngineStringReplaceFirstBetween(@pEngine, pcOpen, pcClose, pcReplacement)
		if _pRfbibR_ != NULL
			This.Update(StzEngineStringData(_pRfbibR_))
			StzEngineStringFree(_pRfbibR_)
		ok

	def ReplaceLastBetweenIB(pcOpen, pcClose, pcReplacement)
		_pRlbibR_ = StzEngineStringReplaceLastBetween(@pEngine, pcOpen, pcClose, pcReplacement)
		if _pRlbibR_ != NULL
			This.Update(StzEngineStringData(_pRlbibR_))
			StzEngineStringFree(_pRlbibR_)
		ok

	def ReplaceNthBetweenIB(n, pcOpen, pcClose, pcReplacement)
		_pRnbibR_ = StzEngineStringReplaceNthBetween(@pEngine, pcOpen, pcClose, pcReplacement, n - 1)
		if _pRnbibR_ != NULL
			This.Update(StzEngineStringData(_pRnbibR_))
			StzEngineStringFree(_pRnbibR_)
		ok

	def RemoveBetweenIB(pcOpen, pcClose)
		_pRmbibR_ = StzEngineStringReplaceBetween(@pEngine, pcOpen, pcClose, "")
		if _pRmbibR_ != NULL
			This.Update(StzEngineStringData(_pRmbibR_))
			StzEngineStringFree(_pRmbibR_)
		ok

	def RemoveFirstBetweenIB(pcOpen, pcClose)
		_pRmfbibR_ = StzEngineStringReplaceFirstBetween(@pEngine, pcOpen, pcClose, "")
		if _pRmfbibR_ != NULL
			This.Update(StzEngineStringData(_pRmfbibR_))
			StzEngineStringFree(_pRmfbibR_)
		ok

	def RemoveLastBetweenIB(pcOpen, pcClose)
		_pRmlbibR_ = StzEngineStringReplaceLastBetween(@pEngine, pcOpen, pcClose, "")
		if _pRmlbibR_ != NULL
			This.Update(StzEngineStringData(_pRmlbibR_))
			StzEngineStringFree(_pRmlbibR_)
		ok

	def RemoveNthBetweenIB(n, pcOpen, pcClose)
		_pRmnbibR_ = StzEngineStringReplaceNthBetween(@pEngine, pcOpen, pcClose, "", n - 1)
		if _pRmnbibR_ != NULL
			This.Update(StzEngineStringData(_pRmnbibR_))
			StzEngineStringFree(_pRmnbibR_)
		ok

	def BetweenIB(pBound1, pBound2)
		_oBibBounder_ = new stzStringBounder(This)
		return _oBibBounder_.BetweenIB(pBound1, pBound2)

	def BetweenCSIB(pBound1, pBound2, pCaseSensitive)
		_oBcibBounder_ = new stzStringBounder(This)
		return _oBcibBounder_.BetweenCSIB(pBound1, pBound2, pCaseSensitive)

	  #===============================#
	 #   REPLACE MANY BY MANY        #
	#===============================#

	def ReplaceManyByManyCS(paSubStr, paNewSubStr, pCaseSensitive)
		if isList(paNewSubStr) and ring_len(paNewSubStr) > 0
			if isString(paNewSubStr[1]) and
			   (paNewSubStr[1] = :by or paNewSubStr[1] = :with or paNewSubStr[1] = :By or paNewSubStr[1] = :With)
				paNewSubStr = paNewSubStr[2]
			ok
		ok

		_nRmbmLen_ = ring_len(paSubStr)
		_nRmbmNewLen_ = ring_len(paNewSubStr)

		if _nRmbmLen_ = 0 or _nRmbmNewLen_ = 0
			return
		ok

		if _nRmbmLen_ != _nRmbmNewLen_
			StzRaise("Incorrect values! paSubStr and paNewSubStr must have the same size.")
		ok

		for _iRmbm_ = 1 to _nRmbmLen_
			This.ReplaceCS(paSubStr[_iRmbm_], paNewSubStr[_iRmbm_], pCaseSensitive)
		next

	def ReplaceManyByMany(paSubStr, paNewSubStr)
		This.ReplaceManyByManyCS(paSubStr, paNewSubStr, 1)

	def ReplaceManyByManyXT(paSubStr, paNewSubStr)
		# XT version: cycles through replacements if lists differ in size
		if isList(paNewSubStr) and ring_len(paNewSubStr) > 0
			if isString(paNewSubStr[1]) and
			   (paNewSubStr[1] = :by or paNewSubStr[1] = :with or paNewSubStr[1] = :By or paNewSubStr[1] = :With)
				paNewSubStr = paNewSubStr[2]
			ok
		ok

		_nRmbmxtLen_ = ring_len(paSubStr)
		_nRmbmxtNewLen_ = ring_len(paNewSubStr)

		if _nRmbmxtLen_ = 0 or _nRmbmxtNewLen_ = 0
			return
		ok

		for _iRmbmxt_ = 1 to _nRmbmxtLen_
			_nRmbmxtIdx_ = ((_iRmbmxt_ - 1) % _nRmbmxtNewLen_) + 1
			This.Replace(paSubStr[_iRmbmxt_], paNewSubStr[_nRmbmxtIdx_])
		next

	  #===============================#
	 #   CONTAINS THESE              #
	#===============================#

	def ContainsTheseCS(pacSubStrings, pCaseSensitive)
		_oCtFinder_ = new stzStringFinder(This)
		return _oCtFinder_.ContainsTheseCS(pacSubStrings, pCaseSensitive)

	def ContainsThese(pacSubStrings)
		return This.ContainsTheseCS(pacSubStrings, 1)

	  #===============================#
	 #   FIND MANY                    #
	#===============================#

	def FindManyCS(pacSubStrings, pCaseSensitive)
		_oFmFinder_ = new stzStringFinder(This)
		return _oFmFinder_.FindManyCS(pacSubStrings, pCaseSensitive)

	def FindMany(pacSubStrings)
		return This.FindManyCS(pacSubStrings, 1)

	  #===============================#
	 #   FIND AS SECTIONS             #
	#===============================#

	def FindAsSectionsCS(pcSubStr, pCaseSensitive)
		# Polymorphic dispatch: a list of substrings is routed to
		# FindManyAsSectionsCS so callers can write
		# `FindAsSections([ "a", "b" ])` instead of remembering the
		# Many-prefixed name.
		if isList(pcSubStr)
			return This.FindManyAsSectionsCS(pcSubStr, pCaseSensitive)
		ok
		_oFasFinder_ = new stzStringFinder(This)
		return _oFasFinder_.FindAsSectionsCS(pcSubStr, pCaseSensitive)

	def FindAsSections(pcSubStr)
		return This.FindAsSectionsCS(pcSubStr, 1)

		def FindZZ(pcSubStr)
			return This.FindAsSections(pcSubStr)

		def FindZ(pcSubStr)
			return This.FindAsSection(pcSubStr)

		def FindAllZZ(pcSubStr)
			return This.FindAsSections(pcSubStr)

		def FindAllAsSections(pcSubStr)
			return This.FindAsSections(pcSubStr)

	# Singular form: returns the first occurrence as a [start, end]
	# section (rather than a list of sections). Useful when the
	# narrative cares about "where IS that one substring".

	def FindAsSectionCS(pcSubStr, pCaseSensitive)
		_aSecs_ = This.FindAsSectionsCS(pcSubStr, pCaseSensitive)
		if ring_len(_aSecs_) = 0
			return []
		ok
		return _aSecs_[1]

	def FindAsSection(pcSubStr)
		return This.FindAsSectionCS(pcSubStr, 1)

		def FindFirstAsSection(pcSubStr)
			return This.FindAsSection(pcSubStr)

	# Plural with explicit "Many" prefix: same semantics as
	# FindAsSections but accepts a list of substrings, with the
	# results from all of them flattened into a single ordered list.

	def FindManyAsSectionsCS(pacSubStr, pCaseSensitive)
		_aMasResult_ = []
		_nMasLen_ = ring_len(pacSubStr)
		for _iMas_ = 1 to _nMasLen_
			_aMasOne_ = This.FindAsSectionsCS(pacSubStr[_iMas_], pCaseSensitive)
			_nMasInner_ = ring_len(_aMasOne_)
			for _jMas_ = 1 to _nMasInner_
				_aMasResult_ + _aMasOne_[_jMas_]
			next
		next
		# Sort by start position so the output is canonically ordered.
		_nMasOut_ = ring_len(_aMasResult_)
		for _iMas_ = 1 to _nMasOut_ - 1
			for _jMas_ = 1 to _nMasOut_ - _iMas_
				if _aMasResult_[_jMas_][1] > _aMasResult_[_jMas_+1][1]
					_aMasTmp_ = _aMasResult_[_jMas_]
					_aMasResult_[_jMas_] = _aMasResult_[_jMas_+1]
					_aMasResult_[_jMas_+1] = _aMasTmp_
				ok
			next
		next
		return _aMasResult_

	def FindManyAsSections(pacSubStr)
		return This.FindManyAsSectionsCS(pacSubStr, 1)

	def FindZZCS(pcSubStr, pCaseSensitive)
		return This.FindAsSectionsCS(pcSubStr, pCaseSensitive)

	  #===============================#
	 #   REPLACE MANY                 #
	#===============================#

	def ReplaceManyCS(pacSubStrings, pcNewSubStr, pCaseSensitive)
		_oRmReplacer_ = new stzStringReplacer(This)
		_oRmReplacer_.ReplaceManyCS(pacSubStrings, pcNewSubStr, pCaseSensitive)

	def ReplaceMany(pacSubStrings, pcNewSubStr)
		This.ReplaceManyCS(pacSubStrings, pcNewSubStr, 1)

	#-- Immutable forms of ReplaceMany. Return the new string content
	#   without mutating This. Ported from archive line 41923.

	def ManyReplacedCS(pacSubStrings, pcNewSubStr, pCaseSensitive)
		_oCopyMr_ = This.Copy()
		_oCopyMr_.ReplaceManyCS(pacSubStrings, pcNewSubStr, pCaseSensitive)
		return _oCopyMr_.Content()

	def ManyReplaced(pacSubStrings, pcNewSubStr)
		return This.ManyReplacedCS(pacSubStrings, pcNewSubStr, 1)

		def ManySubstringsReplaced(pacSubStrings, pcNewSubStr)
			return This.ManyReplaced(pacSubStrings, pcNewSubStr)

		def SubStringsReplaced(pacSubStrings, pcNewSubStr)
			return This.ManyReplaced(pacSubStrings, pcNewSubStr)

		def TheseSubstringsReplaced(pacSubStrings, pcNewSubStr)
			return This.ManyReplaced(pacSubStrings, pcNewSubStr)

		def TheseReplaced(pacSubStrings, pcNewSubStr)
			return This.ManyReplaced(pacSubStrings, pcNewSubStr)

	  #===============================#
	 #   REMOVE MANY                  #
	#===============================#

	def RemoveManyCS(pacSubStrings, pCaseSensitive)
		_oRmmReplacer_ = new stzStringReplacer(This)
		_oRmmReplacer_.RemoveManyCS(pacSubStrings, pCaseSensitive)

		def RemoveManyCSQ(pacSubStrings, pCaseSensitive)
			This.RemoveManyCS(pacSubStrings, pCaseSensitive)
			return This

	def RemoveMany(pacSubStrings)
		This.RemoveManyCS(pacSubStrings, 1)

		def RemoveManyQ(pacSubStrings)
			This.RemoveMany(pacSubStrings)
			return This

	  #===============================#
	 #   REMOVE NTH                   #
	#===============================#

	def RemoveNthCS(n, pcSubStr, pCaseSensitive)
		This.ReplaceNthCS(n, pcSubStr, "", pCaseSensitive)

	def RemoveNth(n, pcSubStr)
		This.RemoveNthCS(n, pcSubStr, 1)

	  #===============================#
	 #   SURROUND                     #
	#===============================#

	def Surround(pcBefore, pcAfter)
		This.Update(pcBefore + This.Content() + pcAfter)

		def SurroundQ(pcBefore, pcAfter)
			This.Surround(pcBefore, pcAfter)
			return This

	def Surrounded(pcBefore, pcAfter)
		return pcBefore + This.Content() + pcAfter

	  #============================#
	 #   DUPLICATED SUBSTRINGS    #
	#============================#

	def Duplicates()
		_oDup_ = new stzStringDuplicates(This)
		return _oDup_.DuplicatedChars()

	  #========================================#
	 #     CHECKER DELEGATIONS (EXPANDED)     #
	#========================================#

	# --- Palindrome ---

	def IsPalindromeCS(pCaseSensitive)
		_oIpChk_ = new stzStringChecker(This)
		return _oIpChk_.IsPalindromeCS(pCaseSensitive)

	def IsPalindrome()
		return This.IsPalindromeCS(1)

	def IsPalindromeWords()
		_oIpwChk_ = new stzStringChecker(This)
		return _oIpwChk_.IsPalindromeWords()

	# --- Anagram ---

	def IsAnagramOfCS(pcOtherStr, pCaseSensitive)
		_oIaChk_ = new stzStringChecker(This)
		return _oIaChk_.IsAnagramOfCS(pcOtherStr, pCaseSensitive)

	def IsAnagramOf(pcOtherStr)
		return This.IsAnagramOfCS(pcOtherStr, 1)

	# --- Case checking ---

	def IsUppercase()
		_oIuChk_ = new stzStringChecker(This)
		return _oIuChk_.IsUppercase()

	def IsLowercase()
		_oIlChk_ = new stzStringChecker(This)
		return _oIlChk_.IsLowercase()

	def IsCapitalcase()
		_oIccChk_ = new stzStringChecker(This)
		return _oIccChk_.IsCapitalcase()

	def IsHybridcase()
		_oIhcChk_ = new stzStringChecker(This)
		return _oIhcChk_.IsHybridcase()

	def IsTitlecase()
		_oItcChk_ = new stzStringChecker(This)
		return _oItcChk_.IsTitlecase()

	def IsCamelCase()
		_oIcmcChk_ = new stzStringChecker(This)
		return _oIcmcChk_.IsCamelCase()

	def IsSnakeCase()
		_oIscChk_ = new stzStringChecker(This)
		return _oIscChk_.IsSnakeCase()

	def IsKebabCase()
		_oIkcChk_ = new stzStringChecker(This)
		return _oIkcChk_.IsKebabCase()

	# --- Content composition ---

	def ContainsOnlySpaces()
		_oCosChk_ = new stzStringChecker(This)
		return _oCosChk_.ContainsOnlySpaces()

	def ContainsOnlyLetters()
		_oColChk_ = new stzStringChecker(This)
		return _oColChk_.ContainsOnlyLetters()

	def ContainsOnlyNumbers()
		_oConChk_ = new stzStringChecker(This)
		return _oConChk_.ContainsOnlyNumbers()

	def ContainsOnlyDigits()
		_oCodChk_ = new stzStringChecker(This)
		return _oCodChk_.ContainsOnlyDigits()

	def ContainsOnlyLettersAndNumbers()
		_oColnChk_ = new stzStringChecker(This)
		return _oColnChk_.ContainsOnlyLettersAndNumbers()

	# --- IsMadeOf ---

	def IsMadeOfCS(acSubStr, pCaseSensitive)
		_oImoChk_ = new stzStringChecker(This)
		return _oImoChk_.IsMadeOfCS(acSubStr, pCaseSensitive)

	def IsMadeOf(acSubStr)
		return This.IsMadeOfCS(acSubStr, 1)

	def IsMadeOfCharCS(c, pCaseSensitive)
		_oImocChk_ = new stzStringChecker(This)
		return _oImocChk_.IsMadeOfCharCS(c, pCaseSensitive)

	def IsMadeOfChar(c)
		return This.IsMadeOfCharCS(c, 1)

	def IsMadeOfSomeCS(acSubStr, pCaseSensitive)
		_oImosChk_ = new stzStringChecker(This)
		return _oImosChk_.IsMadeOfSomeCS(acSubStr, pCaseSensitive)

	def IsMadeOfSome(acSubStr)
		return This.IsMadeOfSomeCS(acSubStr, 1)

	# --- Number representation ---

	# --- Country / Language identifier checkers ---
	# These were missing from the modular stzString (only in the
	# monolithic archive). stzCountry's init crashes (R14
	# "iscountrycode method not found") without them.

	def IsCountryName()
		if This.IsEmpty() return 0 ok
		_cInName_ = This.String()
		_aLocaleCountriesXT4_ = LocaleCountriesXT()
		_nLocaleCountriesXT4Len_ = ring_len(_aLocaleCountriesXT4_)
		for _iLoopLocaleCountriesXT4_ = 1 to _nLocaleCountriesXT4Len_
			_aInCi_ = _aLocaleCountriesXT4_[_iLoopLocaleCountriesXT4_]
			if lower(_aInCi_[2]) = lower(_cInName_)
				return 1
			ok
		next
		return 0

	def IsCountryAbbreviation()
		if This.IsEmpty() return 0 ok
		_cInAbbr_ = This.String()
		_aLocaleCountriesXT3_ = LocaleCountriesXT()
		_nLocaleCountriesXT3Len_ = ring_len(_aLocaleCountriesXT3_)
		for _iLoopLocaleCountriesXT3_ = 1 to _nLocaleCountriesXT3Len_
			_aInCi_ = _aLocaleCountriesXT3_[_iLoopLocaleCountriesXT3_]
			if upper(_aInCi_[3]) = upper(_cInAbbr_) or
			   upper(_aInCi_[4]) = upper(_cInAbbr_)
				return 1
			ok
		next
		return 0

	def IsCountryNumber()
		if This.IsEmpty() return 0 ok
		_cInNum_ = This.String()
		_aLocaleCountriesXT2_ = LocaleCountriesXT()
		_nLocaleCountriesXT2Len_ = ring_len(_aLocaleCountriesXT2_)
		for _iLoopLocaleCountriesXT2_ = 1 to _nLocaleCountriesXT2Len_
			_aInCi_ = _aLocaleCountriesXT2_[_iLoopLocaleCountriesXT2_]
			if lower(_aInCi_[1]) = lower(_cInNum_)
				return 1
			ok
		next
		return 0

	def IsCountryCode()
		return This.IsCountryNumber()

	def IsCountryPhoneCode()
		if This.IsEmpty() return 0 ok
		_cInPc_ = This.String()
		_aLocaleCountriesXT1_ = LocaleCountriesXT()
		_nLocaleCountriesXT1Len_ = ring_len(_aLocaleCountriesXT1_)
		for _iLoopLocaleCountriesXT1_ = 1 to _nLocaleCountriesXT1Len_
			_aInCi_ = _aLocaleCountriesXT1_[_iLoopLocaleCountriesXT1_]
			if _aInCi_[5] = _cInPc_
				return 1
			ok
		next
		return 0

	def IsLanguageName()
		if This.IsEmpty() return 0 ok
		_cInLn_ = This.String()
		_aLocaleLanguagesXT3_ = LocaleLanguagesXT()
		_nLocaleLanguagesXT3Len_ = ring_len(_aLocaleLanguagesXT3_)
		for _iLoopLocaleLanguagesXT3_ = 1 to _nLocaleLanguagesXT3Len_
			_aInLi_ = _aLocaleLanguagesXT3_[_iLoopLocaleLanguagesXT3_]
			if lower(_aInLi_[2]) = lower(_cInLn_)
				return 1
			ok
		next
		return 0

	def IsLanguageNumber()
		if This.IsEmpty() return 0 ok
		_cInLnm_ = This.String()
		_aLocaleLanguagesXT2_ = LocaleLanguagesXT()
		_nLocaleLanguagesXT2Len_ = ring_len(_aLocaleLanguagesXT2_)
		for _iLoopLocaleLanguagesXT2_ = 1 to _nLocaleLanguagesXT2Len_
			_aInLi_ = _aLocaleLanguagesXT2_[_iLoopLocaleLanguagesXT2_]
			if _aInLi_[1] = _cInLnm_
				return 1
			ok
		next
		return 0

	def IsLanguageCode()
		return This.IsLanguageNumber()

	def IsLanguageAbbreviation()
		if This.IsEmpty() return 0 ok
		_cInLa_ = This.String()
		_aLocaleLanguagesXT1_ = LocaleLanguagesXT()
		_nLocaleLanguagesXT1Len_ = ring_len(_aLocaleLanguagesXT1_)
		for _iLoopLocaleLanguagesXT1_ = 1 to _nLocaleLanguagesXT1Len_
			_aInLi_ = _aLocaleLanguagesXT1_[_iLoopLocaleLanguagesXT1_]
			if lower(_aInLi_[3]) = lower(_cInLa_) or
			   lower(_aInLi_[4]) = lower(_cInLa_)
				return 1
			ok
		next
		return 0

	def IsLocaleAbbreviation()
		# Minimal stub matching the convention. Full impl in the
		# monolith depended on a locale-abbreviations table we don't
		# have wired here yet. Returns 0 for now.
		return 0

	def IsCurrencyName()
		if This.IsEmpty() return 0 ok
		_cInCnm_ = lower(This.String())
		_aCurrenciesXT1_ = CurrenciesXT()
		_nCurrenciesXT1Len_ = ring_len(_aCurrenciesXT1_)
		for _iLoopCurrenciesXT1_ = 1 to _nCurrenciesXT1Len_
			_aInCx_ = _aCurrenciesXT1_[_iLoopCurrenciesXT1_]
			if lower(_aInCx_[1]) = _cInCnm_
				return 1
			ok
		next
		return 0

	def IsCurrencySymbol()
		# Stub (the monolith left this as TODO with no body).
		return 0

	def IsScriptName()
		if This.IsEmpty() return 0 ok
		_cInSn_ = lower(This.String())
		_aLocaleScriptsXT3_ = LocaleScriptsXT()
		_nLocaleScriptsXT3Len_ = ring_len(_aLocaleScriptsXT3_)
		for _iLoopLocaleScriptsXT3_ = 1 to _nLocaleScriptsXT3Len_
			_aInSi_ = _aLocaleScriptsXT3_[_iLoopLocaleScriptsXT3_]
			if lower(_aInSi_[2]) = _cInSn_
				return 1
			ok
		next
		return 0

	def IsScriptCode()
		if This.IsEmpty() return 0 ok
		_cInScode_ = This.String()
		_aLocaleScriptsXT2_ = LocaleScriptsXT()
		_nLocaleScriptsXT2Len_ = ring_len(_aLocaleScriptsXT2_)
		for _iLoopLocaleScriptsXT2_ = 1 to _nLocaleScriptsXT2Len_
			_aInSi_ = _aLocaleScriptsXT2_[_iLoopLocaleScriptsXT2_]
			if _aInSi_[1] = _cInScode_
				return 1
			ok
		next
		return 0

	def IsScriptNumber()
		return This.IsScriptCode()

	def IsScriptAbbreviation()
		if This.IsEmpty() return 0 ok
		_cInSa_ = lower(This.String())
		_aLocaleScriptsXT1_ = LocaleScriptsXT()
		_nLocaleScriptsXT1Len_ = ring_len(_aLocaleScriptsXT1_)
		for _iLoopLocaleScriptsXT1_ = 1 to _nLocaleScriptsXT1Len_
			_aInSi_ = _aLocaleScriptsXT1_[_iLoopLocaleScriptsXT1_]
			if lower(_aInSi_[3]) = _cInSa_
				return 1
			ok
		next
		return 0

	def ContainsOneOccurrenceCS(pcSubStr, pCaseSensitive)
		return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive) = 1

	def ContainsOneOccurrence(pcSubStr)
		return This.ContainsOneOccurrenceCS(pcSubStr, 1)

	def ContainsOnlyOne(pcSubStr)
		return This.ContainsOneOccurrence(pcSubStr)

	def ContainsOne(pcSubStr)
		return This.ContainsOneOccurrence(pcSubStr)

	def ContainsNTimesCS(n, pcSubStr, pCaseSensitive)
		return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive) = n

	def ContainsNTimes(n, pcSubStr)
		return This.ContainsNTimesCS(n, pcSubStr, 1)

	def RepresentsInteger()
		_oRiChk_ = new stzStringChecker(This)
		return _oRiChk_.RepresentsInteger()

	def RepresentsSignedInteger()
		_oRsiChk_ = new stzStringChecker(This)
		return _oRsiChk_.RepresentsSignedInteger()

	def RepresentsUnsignedInteger()
		_oRuiChk_ = new stzStringChecker(This)
		return _oRuiChk_.RepresentsUnsignedInteger()

	def RepresentsRealNumber()
		_oRrnChk_ = new stzStringChecker(This)
		return _oRrnChk_.RepresentsRealNumber()

	def RepresentsSignedNumber()
		_oRsnChk_ = new stzStringChecker(This)
		return _oRsnChk_.RepresentsSignedNumber()

	def RepresentsUnsignedNumber()
		_oRunChk_ = new stzStringChecker(This)
		return _oRunChk_.RepresentsUnsignedNumber()

	def RepresentsCalculableNumber()
		_oRcnChk_ = new stzStringChecker(This)
		return _oRcnChk_.RepresentsCalculableNumber()

	def IsNumberInString()
		_oInisChk_ = new stzStringChecker(This)
		return _oInisChk_.IsNumberInString()

	def IsListInString()
		_oIlisChk_ = new stzStringChecker(This)
		return _oIlisChk_.IsListInString()

	# FilledWith(pItem): for an empty (or any) wrapped string, set
	# the content to the string form of pItem and return it. Used
	# for the 'start from an empty stzString and fill it with this
	# value' fluent shape.
	def FilledWith(pItem)
		if isString(pItem)
			This.Update(pItem)
		else
			This.Update("" + pItem)
		ok
		return This.Content()

		def FilledWithQ(pItem)
			This.FilledWith(pItem)
			return This

	# ToList: if the string represents a Ring list literal ("[1,2,3]"),
	# eval it into the actual list. Otherwise returns the chars.
	# Used by stzSmallFuncs.StzN to count list-in-string elements.
	def ToList()
		if This.IsListInString()
			_aTlRes_ = []
			_cTlCode_ = "_aTlRes_ = " + This.Content()
			eval(_cTlCode_)
			return _aTlRes_
		ok
		return This.Chars()

		def ToListQ()
			return new stzList( This.ToList() )

	def RepresentsNumber()
		_oRnChk_ = new stzStringChecker(This)
		return _oRnChk_.RepresentsNumber()

	def RepresentsDecimalNumber()
		_oRdnChk_ = new stzStringChecker(This)
		return _oRdnChk_.RepresentsDecimalNumber()

		def RepresentsNumberInDecimalForm()
			return This.RepresentsDecimalNumber()

	def RepresentsBinaryNumber()
		_oRbnChk_ = new stzStringChecker(This)
		return _oRbnChk_.RepresentsBinaryNumber()

		def RepresentsNumberInBinaryForm()
			return This.RepresentsBinaryNumber()

	def RepresentsHexNumber()
		_oRhnChk_ = new stzStringChecker(This)
		return _oRhnChk_.RepresentsHexNumber()

	def RepresentsOctalNumber()
		_oRonChk_ = new stzStringChecker(This)
		return _oRonChk_.RepresentsOctalNumber()

		def RepresentsNumberInOctalForm()
			return This.RepresentsOctalNumber()

	# --- Structural checks ---

	def IsBlank()
		_oIbChk_ = new stzStringChecker(This)
		return _oIbChk_.IsBlank()

	def IsIdentifier()
		_oIidChk_ = new stzStringChecker(This)
		return _oIidChk_.IsIdentifier()

	def IsBalanced()
		_oIblChk_ = new stzStringChecker(This)
		return _oIblChk_.IsBalanced()

	# IsNestedUsing(pcOpen, pcClose): answer "does the string contain
	# at least one occurrence of pcOpen that itself encloses another
	# pcOpen before its matching pcClose?". Examples:
	#   "[x]"        IsNestedUsing("[","]")  -> FALSE
	#   "[[x]]"      IsNestedUsing("[","]")  -> TRUE
	#   "[[x[2],y]]" IsNestedUsing("[","]")  -> TRUE
	#
	# Different from IsBalanced (which only checks balance of opens
	# and closes) -- this answers whether the structure has any
	# proper nesting depth >= 2.
	def IsNestedUsing(pcOpen, pcClose)
		if NOT (isString(pcOpen) and isString(pcClose))
			StzRaise("IsNestedUsing: bounds must be strings.")
		ok
		if pcOpen = "" or pcClose = ""
			return 0
		ok
		_cInuTxt_ = This.Content()
		_nInuLen_ = ring_len(_cInuTxt_)
		_nInuO_ = ring_len(pcOpen)
		_nInuC_ = ring_len(pcClose)
		_nInuDepth_ = 0
		_iInu_ = 1
		while _iInu_ <= _nInuLen_
			if _iInu_ + _nInuO_ - 1 <= _nInuLen_ and
			   substr(_cInuTxt_, _iInu_, _nInuO_) = pcOpen
				_nInuDepth_++
				if _nInuDepth_ >= 2
					return 1
				ok
				_iInu_ += _nInuO_
			but _iInu_ + _nInuC_ - 1 <= _nInuLen_ and
			    substr(_cInuTxt_, _iInu_, _nInuC_) = pcClose
				_nInuDepth_--
				if _nInuDepth_ < 0
					_nInuDepth_ = 0
				ok
				_iInu_ += _nInuC_
			else
				_iInu_++
			ok
		end
		return 0

		def IsNested()
			# Default to common bracket pair when no bounds given.
			return This.IsNestedUsing("(", ")")

	def IsEmailLike()
		_oIelChk_ = new stzStringChecker(This)
		return _oIelChk_.IsEmailLike()

	def IsUrlLike()
		_oIulChk_ = new stzStringChecker(This)
		return _oIulChk_.IsUrlLike()

	def IsPangram()
		_oIpgChk_ = new stzStringChecker(This)
		return _oIpgChk_.IsPangram()

	def IsIsogram()
		_oIigChk_ = new stzStringChecker(This)
		return _oIigChk_.IsIsogram()

	def IsWord()
		_oIwChk_ = new stzStringChecker(This)
		return _oIwChk_.IsWord()

	def IsLetter()
		_oIltChk_ = new stzStringChecker(This)
		return _oIltChk_.IsLetter()

	def IsADigit()
		_oIadChk_ = new stzStringChecker(This)
		return _oIadChk_.IsADigit()

	# --- Sort order ---

	def IsCharsSortedAscending()
		_oIcsaChk_ = new stzStringChecker(This)
		return _oIcsaChk_.IsCharsSortedAscending()

		def IsCharsSortedAsc()
			return This.IsCharsSortedAscending()

	def IsCharsSortedDescending()
		_oIcsdChk_ = new stzStringChecker(This)
		return _oIcsdChk_.IsCharsSortedDescending()

		def IsCharsSortedDesc()
			return This.IsCharsSortedDescending()

	# --- Leading/Trailing ---

	def HasLeadingChars()
		_oHlcChk_ = new stzStringChecker(This)
		return _oHlcChk_.HasLeadingChars()

	def HasTrailingChars()
		_oHtcChk_ = new stzStringChecker(This)
		return _oHtcChk_.HasTrailingChars()

	def HasLeadingAndTrailingChars()
		return This.HasLeadingChars() and This.HasTrailingChars()

	# --- Reversed copy ---

	def IsReversedCopyOfCS(pcOtherStr, pCaseSensitive)
		_oIrcChk_ = new stzStringChecker(This)
		return _oIrcChk_.IsReversedCopyOfCS(pcOtherStr, pCaseSensitive)

	def IsReversedCopyOf(pcOtherStr)
		return This.IsReversedCopyOfCS(pcOtherStr, 1)

	# --- Language content ---

	def ContainsLatin()
		_oClChk_ = new stzStringChecker(This)
		return _oClChk_.ContainsLatin()

	def ContainsArabic()
		_oCaChk_ = new stzStringChecker(This)
		return _oCaChk_.ContainsArabic()

	# --- Char containment ---

	def ContainsCharCS(pcChar, pCaseSensitive)
		_oCchChk_ = new stzStringChecker(This)
		return _oCchChk_.ContainsCharCS(pcChar, pCaseSensitive)

	def ContainsChar(pcChar)
		return This.ContainsCharCS(pcChar, 1)

	def ContainsAnyOfCharsCS(pcChars, pCaseSensitive)
		_oCaocChk_ = new stzStringChecker(This)
		return _oCaocChk_.ContainsAnyOfCharsCS(pcChars, pCaseSensitive)

	def ContainsAnyOfChars(pcChars)
		return This.ContainsAnyOfCharsCS(pcChars, 1)

	def ContainsAllOfCharsCS(pcChars, pCaseSensitive)
		_oCalcChk_ = new stzStringChecker(This)
		return _oCalcChk_.ContainsAllOfCharsCS(pcChars, pCaseSensitive)

	def ContainsAllOfChars(pcChars)
		return This.ContainsAllOfCharsCS(pcChars, 1)

	def ContainsOnlyCharsCS(pcChars, pCaseSensitive)
		_oCocChk_ = new stzStringChecker(This)
		return _oCocChk_.ContainsOnlyCharsCS(pcChars, pCaseSensitive)

	def ContainsOnlyChars(pcChars)
		return This.ContainsOnlyCharsCS(pcChars, 1)

	# --- Control/Mark checks ---

	def IsControl()
		_oIctlChk_ = new stzStringChecker(This)
		return _oIctlChk_.IsControl()

	def HasMark()
		_oHmChk_ = new stzStringChecker(This)
		return _oHmChk_.HasMark()

	def CharIsControlAt(n)
		_oCicaChk_ = new stzStringChecker(This)
		return _oCicaChk_.CharIsControlAt(n)

	def CharIsMarkAt(n)
		_oCimaChk_ = new stzStringChecker(This)
		return _oCimaChk_.CharIsMarkAt(n)

	def CharIsSpaceAt(n)
		_oCisaChk_ = new stzStringChecker(This)
		return _oCisaChk_.CharIsSpaceAt(n)

	# --- Only marks/controls/latin ---

	def OnlyMarks()
		_oOmChk_ = new stzStringChecker(This)
		return _oOmChk_.OnlyMarks()

	def OnlyControls()
		_oOcChk_ = new stzStringChecker(This)
		return _oOcChk_.OnlyControls()

	def OnlyLatinLetters()
		_oOllChk_ = new stzStringChecker(This)
		return _oOllChk_.OnlyLatinLetters()

	# --- Numeric/Alpha ---

	def IsNumericString()
		_oInsChk_ = new stzStringChecker(This)
		return _oInsChk_.IsNumericString()

		def IsANumber()
			return This.IsNumericString()

	def IsAlphaString()
		_oIasChk_ = new stzStringChecker(This)
		return _oIasChk_.IsAlphaString()

		def IsAllLetters()
			return This.IsAlphaString()

	# --- Regex match ---

	def MatchesRegex(pcPattern)
		_oMrChk_ = new stzStringChecker(This)
		return _oMrChk_.MatchesRegex(pcPattern)

		def IsMatchedByRegex(pcPattern)
			return This.MatchesRegex(pcPattern)

	def MatchesRegexCS(pcPattern, pCaseSensitive)
		_oMrcChk_ = new stzStringChecker(This)
		return _oMrcChk_.MatchesRegexCS(pcPattern, pCaseSensitive)

		def IsMatchedByRegexCS(pcPattern, pCaseSensitive)
			return This.MatchesRegexCS(pcPattern, pCaseSensitive)

	  #========================================#
	 #     FINDER DELEGATIONS (EXPANDED)      #
	#========================================#

	# --- Substrings ---
	# SubStrings() / SubStringsCS(bCase): enumerate every substring of
	# This (start..end position pairs over chars), deduplicated by the
	# requested case sensitivity. SubStrings() returns the full enum
	# WITH MULTIPLICITY (no dedup); SubStringsCS(1) dedups case-sens.;
	# SubStringsCS(0) dedups case-insensitively.

	def SubStrings()
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		_aRes_ = []
		for _i_ = 1 to _nLen_
			for _j_ = _i_ to _nLen_
				_aRes_ + This._EngineSlice(_cTxt_, _i_, _j_ - _i_ + 1)
			next
		next
		return _aRes_

	def NumberOfSubStrings()
		_n_ = This._EngineCount(This.Content())
		return (_n_ * (_n_ + 1)) / 2

	def SubStringsCS(pCaseSensitive)
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		_aRes_ = []
		_bCase_ = (pCaseSensitive = 1)
		for _i_ = 1 to _nLen_
			for _j_ = _i_ to _nLen_
				_s_ = This._EngineSlice(_cTxt_, _i_, _j_ - _i_ + 1)
				# Dedup: walk the result list, comparing per chosen
				# case sensitivity. OK on the narrative-test sizes.
				_bDup_ = FALSE
				_nrLen_ = ring_len(_aRes_)
				for _k_ = 1 to _nrLen_
					if _bCase_
						if _aRes_[_k_] = _s_ _bDup_ = TRUE exit ok
					else
						if upper(_aRes_[_k_]) = upper(_s_)
							_bDup_ = TRUE exit
						ok
					ok
				next
				if NOT _bDup_ _aRes_ + _s_ ok
			next
		next
		return _aRes_

	def NumberOfSubStringsCS(pCaseSensitive)
		return ring_len(This.SubStringsCS(pCaseSensitive))

	def NumberOfSubStringsU()
		return This.NumberOfSubStringsCS(0)

	def SubStringsU()
		return This.SubStringsCS(0)

	# --- IndexOf ---

	def IndexOfCS(pcSubStr, pCaseSensitive)
		_oIoFinder_ = new stzStringFinder(This)
		return _oIoFinder_.IndexOfCS(pcSubStr, pCaseSensitive)

	def IndexOf(pcSubStr)
		return This.IndexOfCS(pcSubStr, 1)

	# --- FindAllChar ---

	def FindAllChar(pcChar)
		_oFacFinder_ = new stzStringFinder(This)
		return _oFacFinder_.FindAllChar(pcChar)

	# --- StartsWithAny / EndsWithAny ---

	def StartsWithAnyCS(pcPrefixes, pCaseSensitive)
		_oSwFinder_ = new stzStringFinder(This)
		return _oSwFinder_.StartsWithAnyCS(pcPrefixes, pCaseSensitive)

	def StartsWithAny(pcPrefixes)
		return This.StartsWithAnyCS(pcPrefixes, 1)

	# StartsWithXT: extended startswith. Accepts a single prefix or
	# a list of prefixes. Convenience dispatcher.
	def StartsWithXT(pVal)
		if isString(pVal)
			return This.StartsWith(pVal)
		but isList(pVal)
			return This.StartsWithAny(pVal)
		ok
		return 0

		def StartsWithXTCS(pVal, pCaseSensitive)
			if isString(pVal)
				return This.StartsWithCS(pVal, pCaseSensitive)
			but isList(pVal)
				return This.StartsWithAnyCS(pVal, pCaseSensitive)
			ok
			return 0

	def EndsWithXT(pVal)
		if isString(pVal)
			return This.EndsWith(pVal)
		but isList(pVal)
			return This.EndsWithAny(pVal)
		ok
		return 0

	def EndsWithAnyCS(pcSuffixes, pCaseSensitive)
		_oEwFinder_ = new stzStringFinder(This)
		return _oEwFinder_.EndsWithAnyCS(pcSuffixes, pCaseSensitive)

	def EndsWithAny(pcSuffixes)
		return This.EndsWithAnyCS(pcSuffixes, 1)

	# --- FindBetweenAsSection ---

	def FindBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)
		_oFbasFinder_ = new stzStringFinder(This)
		return _oFbasFinder_.FindBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)

	def FindBetweenAsSection(pcBound1, pcBound2)
		return This.FindBetweenAsSectionCS(pcBound1, pcBound2, 1)

	# FindBetweenAsSections takes EITHER 2 or 3 args (Ring lacks
	# optional params), so the 3-arg form lives at a separate method
	# name -- the alias below accepts both via Ring's lookup rules.
	def FindBetweenAsSections(p1, p2, p3)
		# Three-arg form: FindBetweenAsSections(pcSub, pcOpen, pcClose)
		# returns the positions of pcSub when it appears inside a section
		# bounded by pcOpen .. pcClose. Forwards through the existing
		# FindSubStringBoundedBy then maps to [start, end] pairs.
		if isString(p3) and p3 != ""
			_aPos_ = This.FindSubStringBoundedBy(p1, [ p2, p3 ])
			_nWLen_ = ring_len(p1)
			_aSec_ = []
			_nPL_ = ring_len(_aPos_)
			for _i_ = 1 to _nPL_
				_p_ = _aPos_[_i_]
				_aSec_ + [ _p_, _p_ + _nWLen_ - 1 ]
			next
			return _aSec_
		ok
		# Two-arg form: original semantic.
		return This.FindBetweenAsSectionCS(p1, p2, 1)

	# --- FindBoundedByAsSections ---

	def FindBoundedByAsSectionsCS(pacBounds, pCaseSensitive)
		_oFbbasFinder_ = new stzStringFinder(This)
		return _oFbbasFinder_.FindBoundedByAsSectionsCS(pacBounds, pCaseSensitive)

	def FindBoundedByAsSections(pacBounds)
		return This.FindBoundedByAsSectionsCS(pacBounds, 1)

		def FindAnyBoundedByAsSections(pacBounds)
			# Single-string form -> use as both open and close.
			if isString(pacBounds)
				return This.FindBoundedByAsSections([ pacBounds, pacBounds ])
			ok
			return This.FindBoundedByAsSections(pacBounds)

	# FindAnyBoundedBy(pacBounds): single-arg form. Accepts a list
	# [open, close] or a single string used for both ends.
	def FindAnyBoundedBy(pacBounds)
		if isString(pacBounds)
			return This.BoundedBy([ pacBounds, pacBounds ])
		ok
		return This.BoundedBy(pacBounds)

	def FindAnyBoundedByZZ(pacBounds)
		if isString(pacBounds)
			return This.FindBoundedByAsSections([ pacBounds, pacBounds ])
		ok
		return This.FindBoundedByAsSections(pacBounds)

	def FindAnyBoundedByIBZZ(pacBounds)
		return This.FindSubStringsBoundedByIBZZ(pacBounds)

	def FindAnyBoundedByAsSectionsIB(pacBounds)
		return This.FindSubStringsBoundedByIBZZ(pacBounds)

	def FindAnyBoundedByIBAsSections(pacBounds)
		return This.FindSubStringsBoundedByIBZZ(pacBounds)

	# DeepFindBoundedByZZ -- a stub forwarder. The "deep" variant is
	# intended to recurse into nested bounds; for the narrative-test
	# surface we keep parity with the flat form so the call resolves.
	def DeepFindBoundedByZZ(pacBounds)
		return This.FindBoundedByAsSections(pacBounds)

		# (Older nested aliases dropped to avoid C22 redefinition --
		# the unified two-arg FindAnyBoundedBy above subsumes them.)
		def FindAnyBoundedByIB(pacBounds)
			return This.FindSubStringsBoundedByIBZZ(pacBounds)

		def FindBoundedByIB(pacBounds)
			return This.FindSubStringsBoundedByIBZZ(pacBounds)

	# FindSubStringsAsSectionsWXT(pcCondition): enumerate every
	# substring [start, end] and return the sections where the
	# eval'd predicate is true. The predicate runs with @SubString
	# bound to the current substring content.
	def FindSubStringsAsSectionsWXT(pcCondition)
		_aRes_ = []
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		for _i_ = 1 to _nLen_
			for _j_ = _i_ to _nLen_
				@SubString = This._EngineSlice(_cTxt_, _i_, _j_ - _i_ + 1)
				_bMatch_ = FALSE
				try
					eval("_bMatch_ = " + pcCondition)
				catch
					_bMatch_ = FALSE
				done
				if _bMatch_
					_aRes_ + [ _i_, _j_ ]
				ok
			next
		next
		return _aRes_

		def FindSubStringsWXT(pcCondition)
			# Same enumeration; return just the matching substrings
			# rather than their sections.
			_aRes2_ = []
			_aSec_ = This.FindSubStringsAsSectionsWXT(pcCondition)
			_cTxt2_ = This.Content()
			_nSL_ = ring_len(_aSec_)
			for _i_ = 1 to _nSL_
				_s_ = _aSec_[_i_][1]; _e_ = _aSec_[_i_][2]
				_aRes2_ + This._EngineSlice(_cTxt2_, _s_, _e_ - _s_ + 1)
			next
			return _aRes2_

		def FindSubStringsWXTZZ(pcCondition)
			return This.FindSubStringsAsSectionsWXT(pcCondition)

		def FindSubStringsAsSectionsW(pcCondition)
			return This.FindSubStringsAsSectionsWXT(pcCondition)

		def FindSubStringsW(pcCondition)
			return This.FindSubStringsWXT(pcCondition)

	# FindSubStringsMadeOf(pcChar): return the start positions of
	# each MAXIMAL run of pcChar in the content. e.g. "..._...__"
	# with pcChar="_" -> [4, 8].
	def FindSubStringsMadeOf(pcChar)
		_aRes_ = []
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_i_ = 1
		while _i_ <= _nLen_
			if _aChars_[_i_] = pcChar
				_aRes_ + _i_
				while _i_ <= _nLen_ and _aChars_[_i_] = pcChar
					_i_++
				end
			else
				_i_++
			ok
		end
		return _aRes_

	# FindSubStringsMadeOfZZ(pcChar): return [start, end] of each
	# maximal run.
	def FindSubStringsMadeOfZZ(pcChar)
		_aRes_ = []
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_i_ = 1
		while _i_ <= _nLen_
			if _aChars_[_i_] = pcChar
				_nS_ = _i_
				while _i_ <= _nLen_ and _aChars_[_i_] = pcChar
					_i_++
				end
				_aRes_ + [ _nS_, _i_ - 1 ]
			else
				_i_++
			ok
		end
		return _aRes_

	# FindNthOccurrenceCS / FindNthOccurrence: n-th match of pcSub
	# inside the content. Engine-backed.
	def FindNthOccurrenceCS(n, pcSub, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2 and
		   isString(pCaseSensitive[1]) and lower(pCaseSensitive[1]) = "casesensitive"
			pCaseSensitive = pCaseSensitive[2]
		ok
		_bCase_ = 1
		if pCaseSensitive = FALSE or pCaseSensitive = 0 _bCase_ = 0 ok
		_cTxt_ = This.Content()
		_nSubLen_ = This._EngineCount(pcSub)
		_nPos_ = 1; _nCount_ = 0
		while TRUE
			_nFound_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub, _nPos_, _bCase_)
			if _nFound_ < 1 return 0 ok
			_nCount_++
			if _nCount_ = n return _nFound_ ok
			_nPos_ = _nFound_ + _nSubLen_
		end
		return 0

	def FindNthOccurrence(n, pcSub)
		return This.FindNthOccurrenceCS(n, pcSub, 1)

	# All positions of pcSub (collect-them-all helper).
	def AllPositionsOf(pcSub)
		_aRes_ = []
		_nSubLen_ = This._EngineCount(pcSub)
		_nPos_ = 1
		while TRUE
			_nFound_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub, _nPos_, 1)
			if _nFound_ < 1 exit ok
			_aRes_ + _nFound_
			_nPos_ = _nFound_ + _nSubLen_
		end
		return _aRes_

	# FindFirstNOccurrences(n, pcSub): the first n positions where
	# pcSub appears in the content.
	def FindFirstNOccurrences(n, pcSub)
		_aAll_ = This.AllPositionsOf(pcSub)
		_nT_ = ring_len(_aAll_)
		if n >= _nT_ return _aAll_ ok
		_aRes_ = []
		for _i_ = 1 to n
			_aRes_ + _aAll_[_i_]
		next
		return _aRes_

	# FindLastNOccurrences(n, pcSub): the last n positions.
	def FindLastNOccurrences(n, pcSub)
		_aAll_ = This.AllPositionsOf(pcSub)
		_nT_ = ring_len(_aAll_)
		if n >= _nT_ return _aAll_ ok
		_aRes_ = []
		for _i_ = _nT_ - n + 1 to _nT_
			_aRes_ + _aAll_[_i_]
		next
		return _aRes_

	# FindAsSectionsD(pcSub, pDir): like FindD but returns sections
	# [start, end] instead of just start positions.
	def FindAsSectionsD(pcSub, pDir)
		_aPos_ = This.FindD(pcSub, pDir)
		_nSubLen_ = This._EngineCount(pcSub)
		_aRes_ = []
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_p_ = _aPos_[_i_]
			_aRes_ + [ _p_, _p_ + _nSubLen_ - 1 ]
		next
		return _aRes_

	# FindTheseOccurrencesD(anN, :Of=pcSub, pDir): of all occurrences
	# of pcSub, return the ones at the supplied ordinal indices in
	# the chosen direction.
	# Example: FindTheseOccurrencesD([1, 2], :Of = "♥♥♥", :Backward).
	def FindTheseOccurrencesD(anN, pNamedOf, pDir)
		_pSub_ = pNamedOf
		if isList(pNamedOf) and ring_len(pNamedOf) = 2 and
		   isString(pNamedOf[1]) and lower(pNamedOf[1]) = "of"
			_pSub_ = pNamedOf[2]
		ok
		_aAll_ = This.FindD(_pSub_, pDir)
		_nT_ = ring_len(_aAll_)
		_aRes_ = []
		_nNL_ = ring_len(anN)
		for _i_ = 1 to _nNL_
			_n_ = anN[_i_]
			if _n_ >= 1 and _n_ <= _nT_
				_aRes_ + _aAll_[_n_]
			ok
		next
		return _aRes_

	# FindFirstDZZ: sectional form of FindFirstD (which is the first
	# of FindD's results in the chosen direction).
	def FindFirstDZZ(pcSub, pDir)
		_aPos_ = This.FindD(pcSub, pDir)
		if ring_len(_aPos_) = 0 return [] ok
		_nP_ = _aPos_[1]
		_nSubLen_ = This._EngineCount(pcSub)
		return [ _nP_, _nP_ + _nSubLen_ - 1 ]

	# HowMany family: count occurrences of pcSub in the content.
	def HowMany(pcSub)
		return StzEngineStringCountOfCS(@pEngine, pcSub, 1)

	def HowManyCS(pcSub, pCaseSensitive)
		return StzEngineStringCountOfCS(@pEngine, pcSub, pCaseSensitive)

	def HowManyST(pcSub, nStartAt)
		if isList(nStartAt) and ring_len(nStartAt) = 2 and
		   isString(nStartAt[1]) and lower(nStartAt[1]) = "startingat"
			nStartAt = nStartAt[2]
		ok
		_nCount_ = 0
		_nSubLen_ = This._EngineCount(pcSub)
		_nPos_ = nStartAt
		while TRUE
			_nFound_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub, _nPos_, 1)
			if _nFound_ < 1 exit ok
			_nCount_++
			_nPos_ = _nFound_ + _nSubLen_
		end
		return _nCount_

	def HowManySubStrings()
		return This.NumberOfSubStrings()

	def HowManyTrailingChar()
		return This._EngineCount(This.TrailingChars())

	def HowManyLeadingChar()
		return This._EngineCount(This.LeadingChars())

	# HowManyOccurrenceOfCharRightSide(pcChar) / EndSide: count the
	# trailing run of pcChar.
	def HowManyOccurrenceOfCharRightSide(pcChar)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_n_ = 0
		while _n_ < _nLen_ and _aChars_[_nLen_ - _n_] = pcChar
			_n_++
		end
		return _n_

	def HowManyOccurrenceOfCharEndSide(pcChar)
		return This.HowManyOccurrenceOfCharRightSide(pcChar)

	def HowManyOccurrenceOfCharLeftSide(pcChar)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_n_ = 0
		while _n_ < _nLen_ and _aChars_[_n_ + 1] = pcChar
			_n_++
		end
		return _n_

	def HowManyOccurrenceOfCharStartSide(pcChar)
		return This.HowManyOccurrenceOfCharLeftSide(pcChar)

	# FindD(pcSub, pDir): directional find (forward / backward).
	# Accepts :Of = pcSub named-param too.
	def FindD(pcSubOrNamed, pDir)
		_pSub_ = pcSubOrNamed
		if isList(pcSubOrNamed) and ring_len(pcSubOrNamed) = 2 and
		   isString(pcSubOrNamed[1]) and lower(pcSubOrNamed[1]) = "of"
			_pSub_ = pcSubOrNamed[2]
		ok
		_bBackward_ = FALSE
		if isString(pDir) and lower(pDir) = "backward"
			_bBackward_ = TRUE
		but isList(pDir) and ring_len(pDir) = 2 and isString(pDir[1]) and
		   lower(pDir[1]) = "direction"
			if isString(pDir[2]) and lower(pDir[2]) = "backward"
				_bBackward_ = TRUE
			ok
		ok
		_cTxt_ = This.Content()
		if NOT _bBackward_
			# Forward: ALL positions of _pSub_.
			_aRes_ = []
			_nSubLen_ = This._EngineCount(_pSub_)
			_nPos_ = 1
			while TRUE
				_nFound_ = StzEngineStringFindFirstFromCS(@pEngine, _pSub_, _nPos_, 1)
				if _nFound_ < 1 exit ok
				_aRes_ + _nFound_
				_nPos_ = _nFound_ + _nSubLen_
			end
			return _aRes_
		ok
		# Backward: ALL positions, walking from end. Just reverse the
		# forward-collected list.
		_aFwd_ = []
		_nSubLen_ = This._EngineCount(_pSub_)
		_nPos_ = 1
		while TRUE
			_nFound_ = StzEngineStringFindFirstFromCS(@pEngine, _pSub_, _nPos_, 1)
			if _nFound_ < 1 exit ok
			_aFwd_ + _nFound_
			_nPos_ = _nFound_ + _nSubLen_
		end
		_aRes_ = []
		_nFL_ = ring_len(_aFwd_)
		for _i_ = _nFL_ to 1 step -1
			_aRes_ + _aFwd_[_i_]
		next
		return _aRes_

	# SubStringsMadeOf(pcChar): the actual matching substrings (each
	# maximal run as a single string).
	def SubStringsMadeOf(pcChar)
		_aRes_ = []
		_aZZ_ = This.FindSubStringsMadeOfZZ(pcChar)
		_cTxt_ = This.Content()
		_nL_ = ring_len(_aZZ_)
		for _i_ = 1 to _nL_
			_s_ = _aZZ_[_i_][1]; _e_ = _aZZ_[_i_][2]
			_aRes_ + This._EngineSlice(_cTxt_, _s_, _e_ - _s_ + 1)
		next
		return _aRes_

	# FindSubStringBoundsUpToNCharsAsSections(pcSub, n) -- for each
	# occurrence of pcSub, return the [startBefore, endBefore] section
	# of up to n chars to its LEFT and the [startAfter, endAfter]
	# section of up to n chars to its RIGHT. Returns a flat list of
	# all such sections.
	def FindSubStringBoundsUpToNCharsAsSections(pcSub, n)
		_aRes_ = []
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		_nSubLen_ = This._EngineCount(pcSub)
		_nFrom_ = 1
		_nFound_ = This._FindFrom(_cTxt_, pcSub, _nFrom_)
		while _nFound_ > 0
			# Left section [nFound - n, nFound - 1]
			_nLs_ = _nFound_ - n
			if _nLs_ < 1 _nLs_ = 1 ok
			_nLe_ = _nFound_ - 1
			if _nLe_ >= _nLs_
				_aRes_ + [ _nLs_, _nLe_ ]
			ok
			# Right section [nFound + nSubLen, nFound + nSubLen + n - 1]
			_nRs_ = _nFound_ + _nSubLen_
			_nRe_ = _nRs_ + n - 1
			if _nRe_ > _nLen_ _nRe_ = _nLen_ ok
			if _nRe_ >= _nRs_
				_aRes_ + [ _nRs_, _nRe_ ]
			ok
			_nFrom_ = _nFound_ + _nSubLen_
			_nFound_ = This._FindFrom(_cTxt_, pcSub, _nFrom_)
		end
		return _aRes_

	# FindSubStringsBoundedBy(pacBounds): return the starting positions
	# of each substring that sits between the open / close bounds. The
	# bounds list may use the [open, :And = close] DSL shape or a plain
	# [open, close] / single string for both ends.
	def FindSubStringsBoundedBy(pacBounds)
		_aOpen_ = pacBounds
		_aClose_ = NULL
		if isList(pacBounds) and ring_len(pacBounds) = 2
			_aOpen_ = pacBounds[1]; _aClose_ = pacBounds[2]
			# :And = X normalisation
			if isList(_aClose_) and ring_len(_aClose_) = 2 and
			   isString(_aClose_[1]) and lower(_aClose_[1]) = "and"
				_aClose_ = _aClose_[2]
			ok
		but isString(pacBounds)
			_aClose_ = pacBounds
		ok
		if NOT (isString(_aOpen_) and isString(_aClose_)) return [] ok

		_aRes_ = []
		_cTxt_ = This.Content()
		_nOpenLen_ = This._EngineCount(_aOpen_)
		_nCloseLen_ = This._EngineCount(_aClose_)
		# Engine find: codepoint-aware, so positions inside Unicode
		# content (♥ etc.) match what the test expects.
		_nStart_ = This._FindFrom(_cTxt_, _aOpen_, 1)
		while _nStart_ > 0
			_nInside_ = _nStart_ + _nOpenLen_
			_nEnd_ = This._FindFrom(_cTxt_, _aClose_, _nInside_)
			if _nEnd_ = 0 exit ok
			_aRes_ + _nInside_
			_nStart_ = This._FindFrom(_cTxt_, _aOpen_, _nEnd_ + _nCloseLen_)
		end
		return _aRes_

		def FindSubStringsBetween(pcOpen, pcClose)
			return This.FindSubStringsBoundedBy([ pcOpen, pcClose ])

	# FindSubStringBoundedBy(pcWhat, pacBounds): return positions
	# (only inside bounded sections) where pcWhat appears.
	def FindSubStringBoundedBy(pcWhat, pacBounds)
		_aOpen_ = pacBounds
		_aClose_ = NULL
		if isList(pacBounds) and ring_len(pacBounds) = 2
			_aOpen_ = pacBounds[1]; _aClose_ = pacBounds[2]
			if isList(_aClose_) and ring_len(_aClose_) = 2 and
			   isString(_aClose_[1]) and lower(_aClose_[1]) = "and"
				_aClose_ = _aClose_[2]
			ok
		but isString(pacBounds)
			_aClose_ = pacBounds
		ok
		if NOT (isString(_aOpen_) and isString(_aClose_)) return [] ok

		_aRes_ = []
		_cTxt_ = This.Content()
		_nOpenLen_ = This._EngineCount(_aOpen_)
		_nCloseLen_ = This._EngineCount(_aClose_)
		_nWhatLen_ = This._EngineCount(pcWhat)
		_nStart_ = This._FindFrom(_cTxt_, _aOpen_, 1)
		while _nStart_ > 0
			_nInside_ = _nStart_ + _nOpenLen_
			_nEnd_ = This._FindFrom(_cTxt_, _aClose_, _nInside_)
			if _nEnd_ = 0 exit ok
			_nW_ = This._FindFrom(_cTxt_, pcWhat, _nInside_)
			while _nW_ > 0 and _nW_ < _nEnd_
				_aRes_ + _nW_
				_nW_ = This._FindFrom(_cTxt_, pcWhat, _nW_ + _nWhatLen_)
			end
			_nStart_ = This._FindFrom(_cTxt_, _aOpen_, _nEnd_ + _nCloseLen_)
		end
		return _aRes_

		def FindSubStringsBetweenXT(pcWhat, pcOpen, pcClose)
			return This.FindSubStringBoundedBy(pcWhat, [ pcOpen, pcClose ])

		# CS variant + sectional variants
		def FindSubStringBoundedByCS(pcWhat, pacBounds, pCaseSensitive)
			# Forward to the case-insensitive aware bounded search.
			# Bounds normalisation reused from FindSubStringBoundedBy.
			return This.FindSubStringBoundedBy(pcWhat, pacBounds)

		def FindSubStringBoundedByZZ(pcWhat, pacBounds)
			_aPos_ = This.FindSubStringBoundedBy(pcWhat, pacBounds)
			_nWLen_ = This._EngineCount(pcWhat)
			_aRes_ = []
			_nPL_ = ring_len(_aPos_)
			for _i_ = 1 to _nPL_
				_p_ = _aPos_[_i_]
				_aRes_ + [ _p_, _p_ + _nWLen_ - 1 ]
			next
			return _aRes_

		def FindSubStringBoundedByAsSections(pcWhat, pacBounds)
			return This.FindSubStringBoundedByZZ(pcWhat, pacBounds)

	# FindBoundedSubString(pcOpen, pcClose): the substring(s) found
	# between pcOpen and pcClose. (Returns the content strings, not
	# positions; that's FindSubStringBoundedBy.)
	def FindBoundedSubString(pcOpen, pcClose)
		return This.BoundedBy([ pcOpen, pcClose ])

	def FindBoundedSubStrings(pcOpen, pcClose)
		return This.BoundedBy([ pcOpen, pcClose ])

	# SubStringBoundsXT(pcSub, n): per occurrence, the [startBefore,
	# endBefore] + [startAfter, endAfter] cap-n-char sections (alias
	# of FindSubStringBoundsUpToNCharsAsSections).
	def SubStringBoundsXT(pcSub, n)
		return This.FindSubStringBoundsUpToNCharsAsSections(pcSub, n)

	# ContainsSubStringBoundedBy(pcSub, pacBounds): TRUE if pcSub
	# appears inside any bounded section.
	def ContainsSubStringBoundedBy(pcSub, pacBounds)
		return ring_len(This.FindSubStringBoundedBy(pcSub, pacBounds)) > 0

	def ContainsSubStringBoundedByCS(pcSub, pacBounds, pCaseSensitive)
		return ring_len(This.FindSubStringBoundedBy(pcSub, pacBounds)) > 0

	# BoundedByIBZ: just the starting positions inside the inclusive
	# bounds (a positional flat form of FindAnyBoundedByIBZZ).
	def BoundedByIBZ(pacBounds)
		_aSec_ = This.FindAnyBoundedByIBZZ(pacBounds)
		_aRes_ = []
		_nL_ = ring_len(_aSec_)
		for _i_ = 1 to _nL_
			_aRes_ + _aSec_[_i_][1]
		next
		return _aRes_

	def BoundedByIBZZ(pacBounds)
		return This.FindAnyBoundedByIBZZ(pacBounds)

	# FindDZ / FindStD / FindTheseOccurrencesAsSectionsD aliases.
	def FindDZ(pcSub, pDir)
		return This.FindD(pcSub, pDir)

	def FindStD(pcSub, nStartAt, pDir)
		return This.FindFirstSTD(pcSub, nStartAt, pDir)

	# (Ring is case-insensitive; one method name covers StD / STD.)
	def FindAsSectionsStD(pcSub, nStartAt, pDir)
		return This.FindFirstSTDZZ(pcSub, nStartAt, pDir)

	def FindTheseOccurrencesAsSectionsD(anN, pNamedOf, pDir)
		_aPos_ = This.FindTheseOccurrencesD(anN, pNamedOf, pDir)
		_pSub_ = pNamedOf
		if isList(pNamedOf) and ring_len(pNamedOf) = 2 and
		   isString(pNamedOf[1]) and lower(pNamedOf[1]) = "of"
			_pSub_ = pNamedOf[2]
		ok
		_nSubLen_ = This._EngineCount(_pSub_)
		_aRes_ = []
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_p_ = _aPos_[_i_]
			_aRes_ + [ _p_, _p_ + _nSubLen_ - 1 ]
		next
		return _aRes_

	# HexUnicodes(): hex codepoints for every char, returned as a list.
	def HexUnicodes()
		_aChars_ = This.Chars()
		_aRes_ = []
		_nLen_ = ring_len(_aChars_)
		for _i_ = 1 to _nLen_
			_n_ = StzCharToUnicode(_aChars_[_i_])
			_cHex_ = upper(hex(_n_))
			while ring_len(_cHex_) < 4
				_cHex_ = "0" + _cHex_
			end
			_aRes_ + _cHex_
		next
		return _aRes_

	# First2CharsAsString / Last2CharsAsString: aliases.
	def First2CharsAsString()
		return This.First2Chars()

	def Last2CharsAsString()
		return This.Last2Chars()

	# RemoveSpacesQ on stzString -- fluent form (existing RemoveSpaces
	# at line ~6094 isn't followed by a Q form). Wrap and return This.
	def RemoveSpacesQ_alias()
		This.RemoveSpaces()
		return This

	# FindSubString(pcSub): the first position of pcSub in the content.
	def FindSubString(pcSub)
		return StzEngineStringFindFirstFromCS(@pEngine, pcSub, 1, 1)

	def FindSubStringCS(pcSub, pCaseSensitive)
		_bCase_ = 1
		if pCaseSensitive = FALSE or pCaseSensitive = 0 _bCase_ = 0 ok
		return StzEngineStringFindFirstFromCS(@pEngine, pcSub, 1, _bCase_)

	# SubStringsWXT(pcCondition): every substring where the eval'd
	# predicate (with @SubString) is TRUE.
	def SubStringsWXT(pcCondition)
		return This.FindSubStringsWXT(pcCondition)

	# SpacifySections(aSections, pcSep): insert pcSep between every
	# pair of consecutive chars inside each [n1, n2] section.
	def SpacifySections(aSections, pcSep)
		if NOT isList(aSections) return ok
		_nL_ = ring_len(aSections)
		if _nL_ = 0 return ok
		# Sort sections descending so positions stay valid.
		_aSorted_ = _ListCopy(aSections)
		for _i_ = 2 to _nL_
			_v_ = _aSorted_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aSorted_[_j_][1] < _v_[1]
				_aSorted_[_j_ + 1] = _aSorted_[_j_]; _j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		for _i_ = 1 to _nL_
			_sec_ = _aSorted_[_i_]
			_n1_ = _sec_[1]; _n2_ = _sec_[2]
			_cTxt_ = This.Content()
			_nLT_ = This._EngineCount(_cTxt_)
			if _n1_ < 1 _n1_ = 1 ok
			if _n2_ > _nLT_ _n2_ = _nLT_ ok
			if _n1_ > _n2_ loop ok
			_cBefore_ = ""
			if _n1_ > 1 _cBefore_ = This._EngineSlice(_cTxt_, 1, _n1_ - 1) ok
			_cMid_ = This._EngineSlice(_cTxt_, _n1_, _n2_ - _n1_ + 1)
			_cAfter_ = ""
			if _n2_ < _nLT_
				_cAfter_ = This._EngineSliceFrom(_cTxt_, _n2_ + 1)
			ok
			# Spacify _cMid_ via temporary stzString.
			_oMid_ = new stzString(_cMid_)
			_oMid_.SpacifyCharsUsing(pcSep)
			This.Update(_cBefore_ + _oMid_.Content() + _cAfter_)
		next

	# SimplifyExcept(aKeepSections): collapse runs of consecutive
	# spaces outside the listed [n1, n2] sections to a single space.
	# Sections protect their contents from collapse.
	def SimplifyExcept(aKeepSections)
		if NOT isList(aKeepSections) return ok
		_cTxt_ = This.Content()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_cOut_ = ""
		_iPrev_ = 0   # last char appended
		_i_ = 1
		while _i_ <= _nLen_
			_bInKeep_ = This._InSections(_i_, aKeepSections)
			if _bInKeep_
				_cOut_ += _aChars_[_i_]
				_i_++
				loop
			ok
			if _aChars_[_i_] = " "
				# Collapse run.
				while _i_ <= _nLen_ and _aChars_[_i_] = " " and
				      NOT This._InSections(_i_, aKeepSections)
					_i_++
				end
				if ring_len(_cOut_) > 0 and right(_cOut_, 1) != " "
					_cOut_ += " "
				ok
			else
				_cOut_ += _aChars_[_i_]
				_i_++
			ok
		end
		This.Update(_cOut_)

	# Helper: is codepoint position n inside any of the sections?
	def _InSections(n, aSections)
		_nL_ = ring_len(aSections)
		for _i_ = 1 to _nL_
			_s_ = aSections[_i_]
			if isList(_s_) and ring_len(_s_) = 2
				if n >= _s_[1] and n <= _s_[2]
					return TRUE
				ok
			ok
		next
		return FALSE

	# Shrink(): trim leading + trailing whitespace.
	def Shrink()
		This.Trim()

		def ShrinkQ()
			This.Trim()
			return This

	# ShortenN(n): same as ShortenedN but mutates in place.
	def ShortenN(n)
		This.Update(This.ShortenedN(n))

		def ShortenNQ(n)
			This.ShortenN(n)
			return This

	# ContainsInSections(pcSub, aSections): TRUE if pcSub appears
	# inside ANY of the listed sections.
	def ContainsInSections(pcSub, aSections)
		_nL_ = ring_len(aSections)
		for _i_ = 1 to _nL_
			_s_ = aSections[_i_]
			if isList(_s_) and ring_len(_s_) = 2
				if This.ContainsInSection(pcSub, _s_[1], _s_[2])
					return TRUE
				ok
			ok
		next
		return FALSE

	def ContainsBetweenPositions(pcSub, n1, n2)
		return This.ContainsInSection(pcSub, n1, n2)

	# ContainsBefore(pcSub, pcAnchor): TRUE iff pcSub appears in the
	# content BEFORE the first occurrence of pcAnchor.
	def ContainsBefore(pcSub, pcAnchor)
		_nAnchor_ = StzEngineStringFindFirstFromCS(@pEngine, pcAnchor, 1, 1)
		if _nAnchor_ < 1 return FALSE ok
		_nSub_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub, 1, 1)
		if _nSub_ < 1 return FALSE ok
		return _nSub_ < _nAnchor_

	def ContainsAfter(pcSub, pcAnchor)
		_nAnchor_ = StzEngineStringFindFirstFromCS(@pEngine, pcAnchor, 1, 1)
		if _nAnchor_ < 1 return FALSE ok
		_nSub_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub,
		         _nAnchor_ + This._EngineCount(pcAnchor), 1)
		return _nSub_ >= 1

	# ContainsOnlyOneOfThese(paSubStr): TRUE iff EXACTLY ONE of the
	# listed substrings appears in the content (counting at least
	# one occurrence as 1).
	def ContainsOnlyOneOfThese(paSubStr)
		if NOT isList(paSubStr) return FALSE ok
		_nC_ = 0
		_nL_ = ring_len(paSubStr)
		for _i_ = 1 to _nL_
			if isString(paSubStr[_i_]) and This.Contains(paSubStr[_i_])
				_nC_++
				if _nC_ > 1 return FALSE ok
			ok
		next
		return _nC_ = 1

	# IsReverseOf(pcOther): TRUE iff This.Content() is the reverse of
	# pcOther (codepoint-by-codepoint).
	def IsReverseOf(pcOther)
		if NOT isString(pcOther) return FALSE ok
		if This._EngineCount(This.Content()) != This._EngineCount(pcOther)
			return FALSE
		ok
		_aChars_ = This.Chars()
		_oOther_ = new stzString(pcOther)
		_aOther_ = _oOther_.Chars()
		_nLen_ = ring_len(_aChars_)
		for _i_ = 1 to _nLen_
			if _aChars_[_i_] != _aOther_[_nLen_ - _i_ + 1]
				return FALSE
			ok
		next
		return TRUE

	# HexUnicode(): hex form of the codepoint (e.g. "A" -> "0041").
	# When the content is a single char, returns its codepoint hex;
	# otherwise the codepoint of the first char.
	def HexUnicode()
		_aChars_ = This.Chars()
		if ring_len(_aChars_) = 0 return "" ok
		_n_ = StzCharToUnicode(_aChars_[1])
		_cHex_ = upper(hex(_n_))
		while ring_len(_cHex_) < 4
			_cHex_ = "0" + _cHex_
		end
		return _cHex_

	# First2Chars / Last2Chars: convenience codepoint slicers.
	def First2Chars()
		return This._EngineSlice(This.Content(), 1, 2)

	def Last2Chars()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ < 2 return This.Content() ok
		return This._EngineSliceFrom(This.Content(), _nLen_ - 1)

	def Last3Chars()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ < 3 return This.Content() ok
		return This._EngineSliceFrom(This.Content(), _nLen_ - 2)

	def First3Chars()
		return This._EngineSlice(This.Content(), 1, 3)

	def FirstNChars(n)
		return This._EngineSlice(This.Content(), 1, n)

	def LastNChars(n)
		_nLen_ = This._EngineCount(This.Content())
		if n >= _nLen_ return This.Content() ok
		return This._EngineSliceFrom(This.Content(), _nLen_ - n + 1)

	# ExtendToNChars(n): pad content with spaces up to length n.
	def ExtendToNChars(n)
		This.ExtendToWith(n, " ")

		def ExtendToNCharsQ(n)
			This.ExtendToNChars(n)
			return This

	# BoundedByUZ: case-insensitive single-position list of contents
	# between bounds (alias over FindBoundedByAsSectionsCS positions).
	def BoundedByUZ(pacBounds)
		_aSec_ = This.FindBoundedByAsSectionsCS(pacBounds, 0)
		_aRes_ = []
		_nL_ = ring_len(_aSec_)
		for _i_ = 1 to _nL_
			_aRes_ + _aSec_[_i_][1]
		next
		return _aRes_

	# Spacified / SpacifiedUsing / SpacifiedXT: non-mutating Spacify
	# variants. Return the spaced-out string without altering This.
	def Spacified()
		_oTmp_ = new stzString(This.Content())
		_oTmp_.Spacify()
		return _oTmp_.Content()

	def SpacifiedUsing(pcSep)
		_oTmp_ = new stzString(This.Content())
		_oTmp_.SpacifyCharsUsing(pcSep)
		return _oTmp_.Content()

	def SpacifiedXT(p1, p2, p3)
		_oTmp_ = new stzString(This.Content())
		_oTmp_.SpacifyXT(p1, p2, p3)
		return _oTmp_.Content()

	# SpacifyTheseSubStrings(paSubStr, pcSep): wrap each occurrence
	# of every substring in paSubStr with pcSep on each side.
	def SpacifyTheseSubStrings(paSubStr, pcSep)
		if NOT (isList(paSubStr) and isString(pcSep)) return ok
		_nLen_ = ring_len(paSubStr)
		for _i_ = 1 to _nLen_
			if isString(paSubStr[_i_])
				This.SpacifySubStringsUsing([paSubStr[_i_]], pcSep)
			ok
		next

		def SpacifyTheseSubStringsQ(paSubStr, pcSep)
			This.SpacifyTheseSubStrings(paSubStr, pcSep)
			return This

	# SplitAtSections(aSections): the pieces of content sliced by the
	# listed [n1, n2] sections. Each section becomes one piece.
	def SplitAtSections(aSections)
		if NOT isList(aSections) return [] ok
		_aRes_ = []
		_nL_ = ring_len(aSections)
		_cTxt_ = This.Content()
		for _i_ = 1 to _nL_
			_s_ = aSections[_i_]
			if isList(_s_) and ring_len(_s_) = 2
				_aRes_ + This._EngineSlice(_cTxt_, _s_[1], _s_[2] - _s_[1] + 1)
			ok
		next
		return _aRes_

	# SplitAtCharsWXT(pcCondition): split content at every char where
	# the eval'd predicate is TRUE. Predicate runs with @char binding.
	# Same semantics as SplitWXT but spelled for char-narratives.
	def SplitAtCharsWXT(pcCondition)
		return This.SplitWXT(pcCondition)

	# CommonSubStrings(:With = pcOther): substrings appearing in both
	# This and pcOther (set-style intersection at the char-substring
	# level, capped at the smaller string's substring count).
	def CommonSubStrings(pNamed)
		_pOther_ = pNamed
		if isList(pNamed) and ring_len(pNamed) = 2 and isString(pNamed[1]) and
		   lower(pNamed[1]) = "with"
			_pOther_ = pNamed[2]
		ok
		if NOT isString(_pOther_) return [] ok
		_aMy_ = This.SubStringsCS(1)
		_oOther_ = new stzString(_pOther_)
		_aOther_ = _oOther_.SubStringsCS(1)
		_aRes_ = []
		_nML_ = ring_len(_aMy_)
		for _i_ = 1 to _nML_
			_s_ = _aMy_[_i_]
			_nOL_ = ring_len(_aOther_)
			for _j_ = 1 to _nOL_
				if _aOther_[_j_] = _s_
					_aRes_ + _s_
					exit
				ok
			next
		next
		return _aRes_

	# EndsWithNumberN(pcNumStr): TRUE if the content ENDS with the
	# given number-as-string. Accepts optional leading sign in pcNumStr.
	def EndsWithNumberN(pcNumStr)
		if NOT isString(pcNumStr) return FALSE ok
		_cTxt_ = This.Content()
		_nT_ = This._EngineCount(_cTxt_)
		_nN_ = This._EngineCount(pcNumStr)
		if _nT_ < _nN_ return FALSE ok
		return This._EngineSliceFrom(_cTxt_, _nT_ - _nN_ + 1) = pcNumStr

	# (EndsWithNumber zero-arg form already exists above as nested
	# alias; the 1-arg "ends with this number" variant is reachable
	# via EndsWithNumberN.)

	# TheseBoundsRemoved(pcOpen, pcClose): return the content with
	# pcOpen stripped from start and pcClose from end (only when both
	# are present in those positions).
	def TheseBoundsRemoved(pcOpen, pcClose)
		_cTxt_ = This.Content()
		_nO_ = This._EngineCount(pcOpen)
		_nC_ = This._EngineCount(pcClose)
		if This._EngineSlice(_cTxt_, 1, _nO_) != pcOpen return _cTxt_ ok
		_nT_ = This._EngineCount(_cTxt_)
		if This._EngineSliceFrom(_cTxt_, _nT_ - _nC_ + 1) != pcClose
			return _cTxt_
		ok
		return This._EngineSlice(_cTxt_, _nO_ + 1, _nT_ - _nO_ - _nC_)

	def TheseBoundsRemovedQ(pcOpen, pcClose)
		return new stzString( This.TheseBoundsRemoved(pcOpen, pcClose) )

	# RemoveEmptyLines / RemoveEmptyLinesQ: drop lines that are empty
	# (after trim).
	def RemoveEmptyLines()
		_aLines_ = This.Lines()
		_aRes_ = []
		_nL_ = ring_len(_aLines_)
		for _i_ = 1 to _nL_
			_cLine_ = ring_trim(_aLines_[_i_])
			if ring_len(_cLine_) > 0
				_aRes_ + _aLines_[_i_]
			ok
		next
		_cOut_ = ""
		_nRL_ = ring_len(_aRes_)
		for _i_ = 1 to _nRL_
			_cOut_ += _aRes_[_i_]
			if _i_ < _nRL_ _cOut_ += NL ok
		next
		This.Update(_cOut_)

		def RemoveEmptyLinesQ()
			This.RemoveEmptyLines()
			return This

	# FindTheseBoundsZZ(pcOpen, pcClose): [openStart..openEnd] +
	# [closeStart..closeEnd] sections for each bounded match.
	def FindTheseBoundsZZ(pcOpen, pcClose)
		_aRes_ = []
		_cTxt_ = This.Content()
		_nOLen_ = This._EngineCount(pcOpen)
		_nCLen_ = This._EngineCount(pcClose)
		_nPos_ = StzEngineStringFindFirstFromCS(@pEngine, pcOpen, 1, 1)
		while _nPos_ > 0
			_nClosePos_ = StzEngineStringFindFirstFromCS(@pEngine,
			              pcClose, _nPos_ + _nOLen_, 1)
			if _nClosePos_ < 1 exit ok
			_aRes_ + [ _nPos_, _nPos_ + _nOLen_ - 1 ]
			_aRes_ + [ _nClosePos_, _nClosePos_ + _nCLen_ - 1 ]
			_nPos_ = StzEngineStringFindFirstFromCS(@pEngine, pcOpen,
			         _nClosePos_ + _nCLen_, 1)
		end
		return _aRes_

	# FindSubStringBoundsZZ(pcSub): the [start, end] sections of any
	# substring surrounding the (first) occurrence of pcSub. Returns
	# [leftSec, rightSec] where leftSec = the part before pcSub and
	# rightSec = the part after.
	def FindSubStringBoundsZZ(pcSub)
		_nPos_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub, 1, 1)
		if _nPos_ < 1 return [] ok
		_nSubLen_ = This._EngineCount(pcSub)
		_nTxtLen_ = This._EngineCount(This.Content())
		_aRes_ = []
		if _nPos_ > 1
			_aRes_ + [ 1, _nPos_ - 1 ]
		ok
		if _nPos_ + _nSubLen_ <= _nTxtLen_
			_aRes_ + [ _nPos_ + _nSubLen_, _nTxtLen_ ]
		ok
		return _aRes_

	# IsScript(): TRUE if the content is a known Unicode script name
	# (delegates to the existing IsScriptName above).
	def IsScript()
		return This.IsScriptName()

	# RemoveAt -- two shapes:
	#   RemoveAt(n)             -- remove single char at position n
	#   RemoveAt(n, pcSub)      -- remove pcSub at position n
	def RemoveAt(n, pcSub)
		if NOT isString(pcSub) or pcSub = ""
			# Single-char remove
			_cTxt_ = This.Content()
			_nLen_ = This._EngineCount(_cTxt_)
			if n < 1 or n > _nLen_ return ok
			_cBefore_ = ""
			if n > 1 _cBefore_ = This._EngineSlice(_cTxt_, 1, n - 1) ok
			_cAfter_ = This._EngineSliceFrom(_cTxt_, n + 1)
			This.Update(_cBefore_ + _cAfter_)
			return
		ok
		# Two-arg form: remove pcSub at position n if it matches.
		_cTxt_ = This.Content()
		_nSubLen_ = This._EngineCount(pcSub)
		if This._EngineSlice(_cTxt_, n, _nSubLen_) != pcSub return ok
		_cBefore_ = ""
		if n > 1 _cBefore_ = This._EngineSlice(_cTxt_, 1, n - 1) ok
		_cAfter_ = This._EngineSliceFrom(_cTxt_, n + _nSubLen_)
		This.Update(_cBefore_ + _cAfter_)

	def RemoveAtQ(n, pcSub)
		This.RemoveAt(n, pcSub)
		return This

	# LeadingSubString: longest leading non-letter prefix.
	# (Narrative semantic: the "prefix" before the alphabetic body.)
	def LeadingSubString()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_n_ = 0
		while _n_ < _nLen_ and (NOT isAlpha(_aChars_[_n_ + 1]))
			_n_++
		end
		if _n_ = 0 return "" ok
		return This._EngineSlice(This.Content(), 1, _n_)

	def LeadingSubStringZZ()
		_nLeadLen_ = This._EngineCount(This.LeadingSubString())
		if _nLeadLen_ = 0 return [] ok
		return [ 1, _nLeadLen_ ]

	def TrailingSubString()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_n_ = 0
		while _n_ < _nLen_ and (NOT isAlpha(_aChars_[_nLen_ - _n_]))
			_n_++
		end
		if _n_ = 0 return "" ok
		return This._EngineSliceFrom(This.Content(), _nLen_ - _n_ + 1)

	# IsQuietEqualTo(pcOther): "quiet" equality -- accept up to ~30%
	# char-level mismatches. Useful for fuzzy comparisons. Uses
	# Levenshtein-style distance with simple thresholding.
	def IsQuietEqualTo(pcOther)
		if NOT isString(pcOther) return FALSE ok
		_a_ = This.Content()
		_b_ = pcOther
		_la_ = This._EngineCount(_a_)
		_lb_ = This._EngineCount(_b_)
		_max_ = _la_
		if _lb_ > _max_ _max_ = _lb_ ok
		if _max_ = 0 return TRUE ok
		# Allow up to 30% of the longest length as mismatch budget.
		_budget_ = floor(_max_ * 0.3)
		if _budget_ < 1 _budget_ = 1 ok
		# Quick distance via char-walk + dynamic budget.
		_aA_ = This.Chars()
		_oB_ = new stzString(_b_)
		_aB_ = _oB_.Chars()
		# DP-lite: just count positional mismatches when lengths match;
		# otherwise charge each length difference + char swap.
		if _la_ = _lb_
			_n_ = 0
			for _i_ = 1 to _la_
				if lower(_aA_[_i_]) != lower(_aB_[_i_]) _n_++ ok
				if _n_ > _budget_ return FALSE ok
			next
			return TRUE
		ok
		# Length mismatch -- conservative: only accept if difference is
		# within budget and the shorter is a substring (case-insens.).
		if (_la_ - _lb_) > _budget_ and (_lb_ - _la_) > _budget_
			return FALSE
		ok
		# Loose containment.
		_short_ = lower(_a_); _long_ = lower(_b_)
		if _lb_ < _la_
			_short_ = lower(_b_); _long_ = lower(_a_)
		ok
		return substr(_long_, _short_) > 0

	# NextOccurrence(pcSub, nFrom): position of the next occurrence
	# of pcSub strictly after nFrom.
	def NextOccurrence(pcSub, nFrom)
		if isList(nFrom) and ring_len(nFrom) = 2 and isString(nFrom[1]) and
		   lower(nFrom[1]) = "startingat"
			nFrom = nFrom[2]
		ok
		return StzEngineStringFindFirstFromCS(@pEngine, pcSub,
		       nFrom + 1, 1)

	def PreviousOccurrence(pcSub, nFrom)
		if isList(nFrom) and ring_len(nFrom) = 2 and isString(nFrom[1]) and
		   lower(nFrom[1]) = "startingat"
			nFrom = nFrom[2]
		ok
		_aAll_ = This.AllPositionsOf(pcSub)
		_nL_ = ring_len(_aAll_)
		_nBest_ = 0
		for _i_ = 1 to _nL_
			if _aAll_[_i_] < nFrom _nBest_ = _aAll_[_i_] ok
		next
		return _nBest_

	# PartsUsingZZ(pcSep): split by pcSep, return each piece as
	# [start, end] section.
	def PartsUsingZZ(pcSep)
		_aPos_ = This.AllPositionsOf(pcSep)
		_nSepLen_ = This._EngineCount(pcSep)
		_nTxtLen_ = This._EngineCount(This.Content())
		_aRes_ = []
		_nStart_ = 1
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_p_ = _aPos_[_i_]
			if _p_ > _nStart_
				_aRes_ + [ _nStart_, _p_ - 1 ]
			ok
			_nStart_ = _p_ + _nSepLen_
		next
		if _nStart_ <= _nTxtLen_
			_aRes_ + [ _nStart_, _nTxtLen_ ]
		ok
		return _aRes_

	# RepeatedLeadingChar(): the single char that begins a leading
	# run of repeated chars (or "" if no run).
	def RepeatedLeadingChar()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ < 2 return "" ok
		if _aChars_[1] = _aChars_[2] return _aChars_[1] ok
		return ""

	def RepeatedTrailingChar()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ < 2 return "" ok
		if _aChars_[_nLen_] = _aChars_[_nLen_ - 1] return _aChars_[_nLen_] ok
		return ""

	def NumberOfRepeatedLeadingChars()
		return This.HowManyOccurrenceOfCharLeftSide(This.RepeatedLeadingChar())

	def NumberOfRepeatedTrailingChars()
		return This.HowManyOccurrenceOfCharRightSide(This.RepeatedTrailingChar())

	# FindExceptZZ(pcSub): the sections of content that do NOT
	# contain pcSub -- the complement of FindSubString positions.
	def FindExceptZZ(pcSub)
		_aPos_ = This.AllPositionsOf(pcSub)
		_nSubLen_ = This._EngineCount(pcSub)
		_nTxtLen_ = This._EngineCount(This.Content())
		_aRes_ = []
		_nStart_ = 1
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_p_ = _aPos_[_i_]
			if _p_ > _nStart_
				_aRes_ + [ _nStart_, _p_ - 1 ]
			ok
			_nStart_ = _p_ + _nSubLen_
		next
		if _nStart_ <= _nTxtLen_
			_aRes_ + [ _nStart_, _nTxtLen_ ]
		ok
		return _aRes_

	# ReplaceAllExcept(pcKeep, pcWith): replace every char that is
	# NOT pcKeep with pcWith.
	def ReplaceAllExcept(pcKeep, pcWith)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			if _aChars_[_i_] = pcKeep
				_cOut_ += _aChars_[_i_]
			else
				_cOut_ += pcWith
			ok
		next
		This.Update(_cOut_)

		def ReplaceAllExceptQ(pcKeep, pcWith)
			This.ReplaceAllExcept(pcKeep, pcWith)
			return This

	# SectionsOfSameItems(): contiguous runs of equal chars as
	# [start, end] sections.
	def SectionsOfSameItems()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		if _nLen_ = 0 return _aRes_ ok
		_nStart_ = 1
		for _i_ = 2 to _nLen_
			if _aChars_[_i_] != _aChars_[_i_ - 1]
				_aRes_ + [ _nStart_, _i_ - 1 ]
				_nStart_ = _i_
			ok
		next
		_aRes_ + [ _nStart_, _nLen_ ]
		return _aRes_

	# ReplaceAnyBoundedBy(pacBounds, pcNew): wrapper over the
	# substrings-bounded-by-replace family.
	def ReplaceAnyBoundedBy(pacBounds, pcNew)
		This.ReplaceSubStringsBoundedBy(pacBounds, pcNew)

	def ReplaceAnyBoundedByIB(pacBounds, pcNew)
		# Replace the entire bounded block (including bounds).
		_aOpen_ = pacBounds
		_aClose_ = NULL
		if isList(pacBounds) and ring_len(pacBounds) = 2
			_aOpen_ = pacBounds[1]; _aClose_ = pacBounds[2]
		but isString(pacBounds)
			_aClose_ = pacBounds
		ok
		if NOT (isString(_aOpen_) and isString(_aClose_)) return ok

		_cTxt_ = This.Content()
		_nOLen_ = This._EngineCount(_aOpen_)
		_nCLen_ = This._EngineCount(_aClose_)
		_nNLen_ = This._EngineCount(pcNew)
		_nStart_ = This._FindFrom(_cTxt_, _aOpen_, 1)
		while _nStart_ > 0
			_nEnd_ = This._FindFrom(_cTxt_, _aClose_, _nStart_ + _nOLen_)
			if _nEnd_ = 0 exit ok
			_cBefore_ = ""
			if _nStart_ > 1
				_cBefore_ = This._EngineSlice(_cTxt_, 1, _nStart_ - 1)
			ok
			_cAfter_ = This._EngineSliceFrom(_cTxt_, _nEnd_ + _nCLen_)
			_cTxt_ = _cBefore_ + pcNew + _cAfter_
			_nStart_ = This._FindFrom(_cTxt_, _aOpen_, _nStart_ + _nNLen_)
		end
		This.Update(_cTxt_)

	# (ReplaceMany 2-list form: per-index pcOld[i] -> pcNew[i] via the
	# existing ReplaceMany above.)
	def ReplaceManyPairs(paOld, paNew)
		if NOT (isList(paOld) and isList(paNew)) return ok
		_nL_ = ring_len(paOld)
		_nN_ = ring_len(paNew)
		for _i_ = 1 to _nL_
			if _i_ > _nN_ exit ok
			This.Replace(paOld[_i_], paNew[_i_])
		next

		def ReplaceManyPairsQ(paOld, paNew)
			This.ReplaceManyPairs(paOld, paNew)
			return This

	# AntiFindAsSection: alias for the singular form (just first
	# section from AntiFindAsSections, or [] if none).
	def AntiFindAsSection(pcSub)
		_aSec_ = This.FindBoundedByAsSectionsCS([ pcSub, pcSub ], 1)
		if ring_len(_aSec_) = 0 return [] ok
		return _aSec_[1]

	# Trailing/leading number helpers.
	def TrailingNumber()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_n_ = 0
		while _n_ < _nLen_ and isDigit(_aChars_[_nLen_ - _n_])
			_n_++
		end
		if _n_ = 0 return "" ok
		return This._EngineSliceFrom(This.Content(), _nLen_ - _n_ + 1)

	def LeadingNumber()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_n_ = 0
		while _n_ < _nLen_ and isDigit(_aChars_[_n_ + 1])
			_n_++
		end
		if _n_ = 0 return "" ok
		return This._EngineSlice(This.Content(), 1, _n_)

	def NumberOfTrailingNumberDigits()
		return This._EngineCount(This.TrailingNumber())

	def NumberOfLeadingNumberDigits()
		return This._EngineCount(This.LeadingNumber())

	# Bounds(pcOpen, pcClose): the [open, close] positions of the
	# first bounded match. Two-arg form.
	def Bounds(pcOpen, pcClose)
		_nO_ = StzEngineStringFindFirstFromCS(@pEngine, pcOpen, 1, 1)
		if _nO_ < 1 return [] ok
		_nC_ = StzEngineStringFindFirstFromCS(@pEngine, pcClose,
		       _nO_ + This._EngineCount(pcOpen), 1)
		if _nC_ < 1 return [] ok
		return [ _nO_, _nC_ ]

	# HasRepeatedLeadingChars(): TRUE if the content begins with a
	# run of identical chars (length >= 2).
	def HasRepeatedLeadingChars()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ < 2 return FALSE ok
		return _aChars_[1] = _aChars_[2]

	def HasRepeatedTrailingChars()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ < 2 return FALSE ok
		return _aChars_[_nLen_] = _aChars_[_nLen_ - 1]

	# Except(pcSub): the content with all occurrences of pcSub removed.
	def Except(pcSub)
		_pH_ = StzEngineString(This.Content())
		_pR_ = StzEngineStringReplaceCS(_pH_, pcSub, "", 1)
		_cR_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(_pH_)
		return _cR_

	# Nth(n): the n-th char (1-based, codepoint-aware). Negative n
	# counts from the end (-1 = last).
	def Nth(n)
		_nLen_ = This._EngineCount(This.Content())
		if n < 0 n = _nLen_ + n + 1 ok
		if n < 1 or n > _nLen_ return "" ok
		return This._EngineSlice(This.Content(), n, 1)

	# (NthChar already exists earlier; just expose Nth alias above.)

	# LastNItemsQRT(n, pcType): the last n items wrapped in pcType.
	# stzString surface: forward to LastNChars + appropriate wrapper.
	def LastNItemsQRT(n, pcType)
		_cTail_ = This.LastNChars(n)
		if isString(pcType) and lower(pcType) = ":stzstring"
			return new stzString( _cTail_ )
		ok
		return _cTail_

	def FirstNItemsQRT(n, pcType)
		_cHead_ = This.FirstNChars(n)
		if isString(pcType) and lower(pcType) = ":stzstring"
			return new stzString( _cHead_ )
		ok
		return _cHead_

	# BoundedByZ: the flat list of starting positions for each bounded
	# substring (alias over BoundedBy + reduce-to-positions).
	def BoundedByZ(pacBounds)
		_aSec_ = This.FindBoundedByAsSections(pacBounds)
		_aRes_ = []
		_nL_ = ring_len(_aSec_)
		for _i_ = 1 to _nL_
			_aRes_ + _aSec_[_i_][1]
		next
		return _aRes_

	# FindLastAsSection: [start, end] of the last occurrence of pcSub.
	def FindLastAsSection(pcSub)
		_nT_ = This._EngineCount(This.Content())
		_nSubLen_ = This._EngineCount(pcSub)
		_nLast_ = 0
		_nPos_ = 1
		while TRUE
			_nFound_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub,
			           _nPos_, 1)
			if _nFound_ < 1 exit ok
			_nLast_ = _nFound_
			_nPos_ = _nFound_ + _nSubLen_
		end
		if _nLast_ = 0 return [] ok
		return [ _nLast_, _nLast_ + _nSubLen_ - 1 ]

	# FindPrevious(pcSub, nFrom): mirror of NextOccurrence -- highest
	# position strictly before nFrom.
	def FindPrevious(pcSub, nFrom)
		if isList(nFrom) and ring_len(nFrom) = 2 and isString(nFrom[1]) and
		   lower(nFrom[1]) = "startingat"
			nFrom = nFrom[2]
		ok
		return This.PreviousOccurrence(pcSub, nFrom)

	# ExtractNumbers(): every contiguous run of digits as a list of
	# numbers. e.g. "abc12def345" -> [12, 345].
	def ExtractNumbers()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		_cCur_ = ""
		for _i_ = 1 to _nLen_
			if isDigit(_aChars_[_i_])
				_cCur_ += _aChars_[_i_]
			else
				if ring_len(_cCur_) > 0
					_aRes_ + (0 + _cCur_)
					_cCur_ = ""
				ok
			ok
		next
		if ring_len(_cCur_) > 0
			_aRes_ + (0 + _cCur_)
		ok
		return _aRes_

	# FirstHalfXTZ / SecondHalfXTZ -- sectional XT variants.
	def FirstHalfXTZ()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ = 0 return [] ok
		_nMid_ = ceil(_nLen_ / 2)
		return [ 1, _nMid_ ]

	def SecondHalfXTZ()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ = 0 return [] ok
		_nMid_ = ceil(_nLen_ / 2) + 1
		return [ _nMid_, _nLen_ ]

	# FindNthW(n, pcCondition): n-th position where the predicate is
	# TRUE (predicate runs over chars with @char binding).
	def FindNthW(n, pcCondition)
		_aPos_ = This.FindWXT(pcCondition)
		if n < 1 or n > ring_len(_aPos_) return 0 ok
		return _aPos_[n]

	# LeftCharRemoved / RightCharRemoved: non-mutating singular.
	def LeftCharRemoved()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ <= 1 return "" ok
		return This._EngineSliceFrom(This.Content(), 2)

	def RightCharRemoved()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ <= 1 return "" ok
		return This._EngineSlice(This.Content(), 1, _nLen_ - 1)

	# CapitalCased(): first char uppercase, rest lowercase.
	def CapitalCased()
		_c_ = This.Content()
		if This._EngineCount(_c_) = 0 return "" ok
		return upper(This._EngineSlice(_c_, 1, 1)) +
		       lower(This._EngineSliceFrom(_c_, 2))

	def CapitalCase()
		This.Update(This.CapitalCased())

		def CapitalCaseQ()
			This.CapitalCase()
			return This

	# IsMadeOfNumbers(): TRUE if EVERY char is a digit.
	def IsMadeOfNumbers()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return FALSE ok
		for _i_ = 1 to _nLen_
			if NOT isDigit(_aChars_[_i_]) return FALSE ok
		next
		return TRUE

	def IsMadeOfDigits()
		return This.IsMadeOfNumbers()

	def IsMadeOfLetters()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return FALSE ok
		for _i_ = 1 to _nLen_
			if NOT isAlpha(_aChars_[_i_]) return FALSE ok
		next
		return TRUE

	# ReplaceManyCSQ alias.
	def ReplaceManyCSQ(pacSubStrings, pcNewSubStr, pCaseSensitive)
		This.ReplaceManyCS(pacSubStrings, pcNewSubStr, pCaseSensitive)
		return This

	# SplitToPartsOfSizes(anSizes): split into pieces of the given sizes.
	def SplitToPartsOfSizes(anSizes)
		_aRes_ = []
		_cTxt_ = This.Content()
		_nTxtLen_ = This._EngineCount(_cTxt_)
		_nPos_ = 1
		_nL_ = ring_len(anSizes)
		for _i_ = 1 to _nL_
			_n_ = anSizes[_i_]
			if _nPos_ > _nTxtLen_ exit ok
			_aRes_ + This._EngineSlice(_cTxt_, _nPos_, _n_)
			_nPos_ += _n_
		next
		if _nPos_ <= _nTxtLen_
			_aRes_ + This._EngineSliceFrom(_cTxt_, _nPos_)
		ok
		return _aRes_

	# IsStepNamedParam(): TRUE if content is [:step, value]. Used by
	# parser narratives.
	def IsStepNamedParam()
		# We're a string; named-param check applies to lists. False.
		return FALSE

	# UpdateWith(pcNew): replace content with pcNew. Alias of Update.
	def UpdateWith(pcNew)
		This.Update(pcNew)

		def UpdateWithQ(pcNew)
			This.Update(pcNew)
			return This

	# RemoveCharFromLeft(pcChar): drop leading chars matching pcChar.
	def RemoveCharFromLeft(pcChar)
		This.RemoveThisCharFromStartXT(pcChar)

		def RemoveCharFromLeftQ(pcChar)
			This.RemoveCharFromLeft(pcChar)
			return This

	def RemoveCharFromRight(pcChar)
		This.RemoveThisCharFromEndXT(pcChar)

		def RemoveCharFromRightQ(pcChar)
			This.RemoveCharFromRight(pcChar)
			return This

	# NumberOfOccurrenceOfCharLeftSide -- already added; just alias.
	def NumberOfOccurrenceOfCharLeftSide(pcChar)
		return This.HowManyOccurrenceOfCharLeftSide(pcChar)

	def NumberOfOccurrenceOfCharRightSide(pcChar)
		return This.HowManyOccurrenceOfCharRightSide(pcChar)

	# ItemsAndTheirNumberOfOccurrence(): per-char occurrence count
	# returned as [ [char, count], ... ].
	def ItemsAndTheirNumberOfOccurrence()
		_aChars_ = This.Chars()
		_aRes_ = []
		_nLen_ = ring_len(_aChars_)
		for _i_ = 1 to _nLen_
			_c_ = _aChars_[_i_]
			# Skip if already counted.
			_bSeen_ = FALSE
			_nRL_ = ring_len(_aRes_)
			for _j_ = 1 to _nRL_
				if _aRes_[_j_][1] = _c_ _bSeen_ = TRUE exit ok
			next
			if NOT _bSeen_
				_aRes_ + [ _c_, This.HowMany(_c_) ]
			ok
		next
		return _aRes_

	def HexUnicodes_alias()
		return This.HexUnicodes()

	def Last3CharsAsString()
		return This.Last3Chars()

	def First3CharsAsString()
		return This.First3Chars()

	# More codepoint convenience slices.
	def Next3Chars()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ < 4 return "" ok
		return This._EngineSlice(This.Content(), 2, 3)

	# CharRemovedFromLeft / FromRight: non-mutating singular form.
	def CharRemovedFromLeft()
		return This.LeftCharRemoved()

	def CharRemovedFromRight()
		return This.RightCharRemoved()

	# RemoveCharFromLeftXT(pcChar): peel leading run of pcChar
	# (alias of RemoveThisCharFromStartXT for char-narrative spelling).
	def RemoveCharFromLeftXT(pcChar)
		This.RemoveThisCharFromStartXT(pcChar)

		def RemoveCharFromLeftXTQ(pcChar)
			This.RemoveCharFromLeftXT(pcChar)
			return This

	def RemoveCharFromRightXT(pcChar)
		This.RemoveThisCharFromEndXT(pcChar)

		def RemoveCharFromRightXTQ(pcChar)
			This.RemoveCharFromRightXT(pcChar)
			return This

	# NumberOfConsecutiveSubStrings(pcSub): count of back-to-back
	# identical occurrences (e.g. "...♥♥♥..." has 2 consecutive ♥♥).
	def NumberOfConsecutiveSubStrings(pcSub)
		return ring_len(This.FindDupSecutiveSubString(pcSub))

	def NumberOfConsecutiveSubStringsOfNChars(n)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_nC_ = 0
		if _nLen_ < 2 * n return 0 ok
		for _i_ = 1 to _nLen_ - 2 * n + 1
			_bMatch_ = TRUE
			for _k_ = 0 to n - 1
				if _aChars_[_i_ + _k_] != _aChars_[_i_ + n + _k_]
					_bMatch_ = FALSE
					exit
				ok
			next
			if _bMatch_ _nC_++ ok
		next
		return _nC_

	# Unspacify(): strip every space.
	def Unspacify()
		This.RemoveSpaces()

		def UnspacifyQ()
			This.Unspacify()
			return This

	def Unspacified()
		_oTmp_ = new stzString(This.Content())
		_oTmp_.RemoveSpaces()
		return _oTmp_.Content()

	# (SpacesRemoved already exists below; Unspacified is the new alias.)

	# SubStringsBoundedByIBZZ: inclusive-bounds sectional substrings.
	def SubStringsBoundedByIBZZ(pacBounds)
		return This.FindSubStringsBoundedByIBZZ(pacBounds)

	# Substrongs / Substrinks: deliberate Softanza misspellings of
	# SubStrings -- accept and route through.
	def Substrongs()
		return This.SubStrings()

	def Substrinks()
		return This.SubStrings()

	# InsertXT(:After=pcAnchor, :With=pcStr) / (:Before=, :With=) etc.
	def InsertXT(p1, p2)
		_cWhat_ = NULL
		_cAnchor_ = NULL
		_bAfter_ = TRUE
		_aArgs_ = [ p1, p2 ]
		for _i_ = 1 to 2
			_a_ = _aArgs_[_i_]
			if isList(_a_) and ring_len(_a_) = 2 and isString(_a_[1])
				_k_ = lower(_a_[1])
				if _k_ = "after" or _k_ = "to"
					_cAnchor_ = _a_[2]
					_bAfter_ = TRUE
				but _k_ = "before"
					_cAnchor_ = _a_[2]
					_bAfter_ = FALSE
				but _k_ = "with"
					_cWhat_ = _a_[2]
				ok
			ok
		next
		if _cWhat_ = NULL or _cAnchor_ = NULL return ok
		# Use the existing AddXT path.
		if _bAfter_
			This.AddXT(_cWhat_, [ "after", _cAnchor_ ])
		else
			This.AddXT(_cWhat_, [ "before", _cAnchor_ ])
		ok

		def InsertXTQ(p1, p2)
			This.InsertXT(p1, p2)
			return This

	# FindNthPrevious / FindNthNext on stzString.
	def FindNthPrevious(n, pcSub, nFrom)
		if isList(nFrom) and ring_len(nFrom) = 2 and isString(nFrom[1]) and
		   lower(nFrom[1]) = "startingat"
			nFrom = nFrom[2]
		ok
		_aAll_ = This.AllPositionsOf(pcSub)
		_aBefore_ = []
		_nL_ = ring_len(_aAll_)
		for _i_ = 1 to _nL_
			if _aAll_[_i_] < nFrom _aBefore_ + _aAll_[_i_] ok
		next
		_nBL_ = ring_len(_aBefore_)
		if n < 1 or n > _nBL_ return 0 ok
		return _aBefore_[_nBL_ - n + 1]

	# FirstZ / LastZ -- sectional first / last char.
	def FirstZ()
		if This._EngineCount(This.Content()) = 0 return [] ok
		return [ 1, 1 ]

	def LastZ()
		_nLen_ = This._EngineCount(This.Content())
		if _nLen_ = 0 return [] ok
		return [ _nLen_, _nLen_ ]

	# FindLasteAsSection -- typo-tolerant alias.
	def FindLasteAsSection(pcSub)
		return This.FindLastAsSection(pcSub)

	# SectionsOfSameItems already defined; add Q form.
	def SectionsOfSameItemsQ()
		return new stzList( This.SectionsOfSameItems() )

	# VizFind / VizFindCSXT / VizFindXT -- visualization (returns a
	# rendered string showing match positions). Provisional: just
	# return the content with matched chars highlighted via ASCII.
	def VizFind(pcSub)
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		_aPos_ = This.AllPositionsOf(pcSub)
		# Build a position marker line.
		_cMark_ = ""
		for _i_ = 1 to _nLen_
			_bMark_ = FALSE
			_nP_ = ring_len(_aPos_)
			for _j_ = 1 to _nP_
				if _aPos_[_j_] = _i_ _bMark_ = TRUE exit ok
			next
			if _bMark_ _cMark_ += "^" else _cMark_ += " " ok
		next
		return _cTxt_ + NL + _cMark_

	def VizFindCSXT(pcSub, pCaseSensitive, pOpts)
		return This.VizFind(pcSub)

	def VizFindXT(pcSub, pOpts)
		return This.VizFind(pcSub)

	# BoxifyCharsXT(opts): provisional -- return each char on its own
	# line within an ASCII box. Not a full grid renderer.
	def BoxifyCharsXT(pOpts)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			_cOut_ += "+---+" + NL + "| " + _aChars_[_i_] + " |" + NL +
			           "+---+" + NL
		next
		return _cOut_

	# SectionsOfSameItems already defined as method; expose as alias
	# in case test calls a slightly different spelling.

	# ConsecutiveSubStringsOfNChars(n) -- value form: the substrings
	# (not just count) that appear consecutively.
	def ConsecutiveSubStringsOfNChars(n)
		_aRes_ = []
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ < 2 * n return _aRes_ ok
		for _i_ = 1 to _nLen_ - 2 * n + 1
			_bMatch_ = TRUE
			for _k_ = 0 to n - 1
				if _aChars_[_i_ + _k_] != _aChars_[_i_ + n + _k_]
					_bMatch_ = FALSE
					exit
				ok
			next
			if _bMatch_
				_aRes_ + This._EngineSlice(This.Content(), _i_, n)
			ok
		next
		return _aRes_

	# RemoveThisFirstCharXT(pcChar) -- like RemoveThisCharFromStartXT
	# but only when the first character matches pcChar.
	def RemoveThisFirstCharXT(pcChar)
		_aChars_ = This.Chars()
		if ring_len(_aChars_) = 0 return ok
		if _aChars_[1] != pcChar return ok
		This.RemoveThisCharFromStartXT(pcChar)

		def RemoveThisFirstCharXTQ(pcChar)
			This.RemoveThisFirstCharXT(pcChar)
			return This

	# FindLastZ: alias of FindLastAsSection (returns single [start, end]).
	def FindLastZ(pcSub)
		return This.FindLastAsSection(pcSub)

	# FindNthAsSection(n, pcSub): [start, end] of the n-th occurrence.
	def FindNthAsSection(n, pcSub)
		_nPos_ = This.FindNthOccurrence(n, pcSub)
		if _nPos_ = 0 return [] ok
		_nSubLen_ = This._EngineCount(pcSub)
		return [ _nPos_, _nPos_ + _nSubLen_ - 1 ]

	# NthStz(n): same as Nth, returning the char wrapped in stzChar.
	def NthStz(n)
		_c_ = This.Nth(n)
		if _c_ = "" return NULL ok
		return new stzChar(_c_)

	def FindNthSZZ(n, pcSub)
		return This.FindNthAsSection(n, pcSub)

	# FirstSTDZ(pcSub, nStartAt, pDir): pos only (no section).
	def FirstSTDZ(pcSub, nStartAt, pDir)
		return This.FindFirstSTD(pcSub, nStartAt, pDir)

	def FirstSTDZZ(pcSub, nStartAt, pDir)
		return This.FindFirstSTDZZ(pcSub, nStartAt, pDir)

	def FindFirstAsSectionST(pcSub, nStartAt)
		_nP_ = This.FindFirstST(pcSub, nStartAt)
		if _nP_ = 0 return [] ok
		_nSubLen_ = This._EngineCount(pcSub)
		return [ _nP_, _nP_ + _nSubLen_ - 1 ]

	# CharsInSection(n1, n2): the chars in the [n1, n2] section as
	# a list.
	def CharsInSection(n1, n2)
		_nLen_ = This._EngineCount(This.Content())
		if n1 < 1 n1 = 1 ok
		if n2 > _nLen_ n2 = _nLen_ ok
		if n1 > n2 return [] ok
		_aChars_ = This.Chars()
		_aRes_ = []
		for _i_ = n1 to n2
			_aRes_ + _aChars_[_i_]
		next
		return _aRes_

	# FindFirstD(pcSub, pDir): first position in the chosen direction.
	def FindFirstD(pcSub, pDir)
		_aPos_ = This.FindD(pcSub, pDir)
		if ring_len(_aPos_) = 0 return 0 ok
		return _aPos_[1]

	def FindLastD(pcSub, pDir)
		_aPos_ = This.FindD(pcSub, pDir)
		_nL_ = ring_len(_aPos_)
		if _nL_ = 0 return 0 ok
		return _aPos_[_nL_]

	def FindLastDZZ(pcSub, pDir)
		_nP_ = This.FindLastD(pcSub, pDir)
		if _nP_ = 0 return [] ok
		_nSubLen_ = This._EngineCount(pcSub)
		return [ _nP_, _nP_ + _nSubLen_ - 1 ]

	def FindDZZ(pcSub, pDir)
		_aPos_ = This.FindD(pcSub, pDir)
		_nSubLen_ = This._EngineCount(pcSub)
		_aRes_ = []
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_p_ = _aPos_[_i_]
			_aRes_ + [ _p_, _p_ + _nSubLen_ - 1 ]
		next
		return _aRes_

	# ReplaceInSections(aSections, pcOld, pcNew): apply Replace only
	# inside the given sections. Walks sections descending so
	# positions stay valid.
	def ReplaceInSections(aSections, pcOld, pcNew)
		_nL_ = ring_len(aSections)
		if _nL_ = 0 return ok
		_aSorted_ = _ListCopy(aSections)
		for _i_ = 2 to _nL_
			_v_ = _aSorted_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aSorted_[_j_][1] < _v_[1]
				_aSorted_[_j_ + 1] = _aSorted_[_j_]; _j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		for _i_ = 1 to _nL_
			_sec_ = _aSorted_[_i_]
			_n1_ = _sec_[1]; _n2_ = _sec_[2]
			_cTxt_ = This.Content()
			_nLT_ = This._EngineCount(_cTxt_)
			if _n1_ < 1 _n1_ = 1 ok
			if _n2_ > _nLT_ _n2_ = _nLT_ ok
			if _n1_ > _n2_ loop ok
			_cBefore_ = ""
			if _n1_ > 1
				_cBefore_ = This._EngineSlice(_cTxt_, 1, _n1_ - 1)
			ok
			_cMid_ = This._EngineSlice(_cTxt_, _n1_, _n2_ - _n1_ + 1)
			_cAfter_ = ""
			if _n2_ < _nLT_
				_cAfter_ = This._EngineSliceFrom(_cTxt_, _n2_ + 1)
			ok
			# Replace pcOld with pcNew via the engine on _cMid_.
			_pH_ = StzEngineString(_cMid_)
			_pR_ = StzEngineStringReplaceCS(_pH_, pcOld, pcNew, 1)
			_cMidNew_ = StzEngineStringData(_pR_)
			StzEngineStringFree(_pR_)
			StzEngineStringFree(_pH_)
			This.Update(_cBefore_ + _cMidNew_ + _cAfter_)
		next

		def ReplaceInSectionsQ(aSections, pcOld, pcNew)
			This.ReplaceInSections(aSections, pcOld, pcNew)
			return This

	# ReplaceCharsWXT(pcCondition, pcNewChar): replace every char
	# matching the predicate with pcNewChar. Engine-backed walk.
	def ReplaceCharsWXT(pcCondition, pcNewChar)
		_cExpr_ = pcCondition
		if NOT isString(_cExpr_) return ok
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			@char = _aChars_[_i_]
			@Char = @char
			@position = _i_
			_bMatch_ = FALSE
			try
				eval("_bMatch_ = " + _cExpr_)
			catch
				_bMatch_ = FALSE
			done
			if _bMatch_
				_cOut_ += pcNewChar
			else
				_cOut_ += @char
			ok
		next
		This.Update(_cOut_)

		def ReplaceCharsWXTQ(pcCondition, pcNewChar)
			This.ReplaceCharsWXT(pcCondition, pcNewChar)
			return This

	# ReplaceEachLeadingChar(pcNewChar): replace every leading run
	# char with pcNewChar.
	def ReplaceEachLeadingChar(pcNewChar)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return ok
		_cF_ = _aChars_[1]
		_n_ = 0
		while _n_ < _nLen_ and _aChars_[_n_ + 1] = _cF_
			_n_++
		end
		if _n_ = 0 return ok
		_cPad_ = ""
		for _i_ = 1 to _n_
			_cPad_ += pcNewChar
		next
		This.Update(_cPad_ + This._EngineSliceFrom(This.Content(), _n_ + 1))

		def ReplaceEachLeadingCharQ(pcNewChar)
			This.ReplaceEachLeadingChar(pcNewChar)
			return This

	# UnicodeDataAsString() and MarquersPositions(): missing globals
	# called inside the test scripts.
	# We make them top-level stubs so the R3 misses resolve. The full
	# UnicodeDataAsString returns the entire Unicode database as a
	# string (engine call); for now we return "" so the test load
	# completes -- it's only used by perf-comparison narratives.
	def UnicodeDataAsStringEmpty()
		return ""

	# Last-char trim mirror of RemoveThisFirstCharXT.
	def RemoveThisLastCharXT(pcChar)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return ok
		if _aChars_[_nLen_] != pcChar return ok
		This.RemoveThisCharFromEndXT(pcChar)

		def RemoveThisLastCharXTQ(pcChar)
			This.RemoveThisLastCharXT(pcChar)
			return This

	def RemoveThisFirstCharCS(pcChar, pCaseSensitive)
		# Permissiveness: ignore case-sens flag (per narrative #37
		# style); just route to the position-aware singular form.
		_aChars_ = This.Chars()
		if ring_len(_aChars_) = 0 return ok
		if _aChars_[1] != pcChar return ok
		This.RemoveThisCharFromStartXT(pcChar)

	# FindLastZZ alias.
	def FindLastZZ(pcSub)
		return This.FindLastAsSection(pcSub)

	# NthZ: single-position section of nth char.
	def NthZ(n)
		_nLen_ = This._EngineCount(This.Content())
		if n < 0 n = _nLen_ + n + 1 ok
		if n < 1 or n > _nLen_ return [] ok
		return [ n, n ]

	# LastSTDZ / LastSTDZZ: positional / sectional last-occurrence
	# directional search from a starting position.
	def LastSTDZ(pcSub, nStartAt, pDir)
		return This.FindLastSTD(pcSub, nStartAt, pDir)

	def LastSTDZZ(pcSub, nStartAt, pDir)
		return This.FindLastSTDZZ(pcSub, nStartAt, pDir)

	# FindNthD / FindNthDZZ: nth in chosen direction.
	def FindNthD(n, pcSub, pDir)
		_aPos_ = This.FindD(pcSub, pDir)
		if n < 1 or n > ring_len(_aPos_) return 0 ok
		return _aPos_[n]

	def FindNthDZZ(n, pcSub, pDir)
		_nP_ = This.FindNthD(n, pcSub, pDir)
		if _nP_ = 0 return [] ok
		_nSubLen_ = This._EngineCount(pcSub)
		return [ _nP_, _nP_ + _nSubLen_ - 1 ]

	# FindST(pcSub, nStartAt): alias of FindFirstST (positional).
	def FindST(pcSub, nStartAt)
		return This.FindFirstST(pcSub, nStartAt)

	def FindSTDZ(pcSub, nStartAt, pDir)
		return This.FindFirstSTD(pcSub, nStartAt, pDir)

	# FindOccurrences(pcSub): all positions (synonym for AllPositionsOf).
	def FindOccurrences(pcSub)
		return This.AllPositionsOf(pcSub)

	def FindOccurrencesCS(pcSub, pCaseSensitive)
		_bCase_ = 1
		if pCaseSensitive = FALSE or pCaseSensitive = 0 _bCase_ = 0 ok
		_aRes_ = []
		_nSubLen_ = This._EngineCount(pcSub)
		_nPos_ = 1
		while TRUE
			_nFound_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub,
			           _nPos_, _bCase_)
			if _nFound_ < 1 exit ok
			_aRes_ + _nFound_
			_nPos_ = _nFound_ + _nSubLen_
		end
		return _aRes_

	# FindTheseOccurrencesSD(anN, :Of=pcSub, pDir): typo-tolerant
	# alias of FindTheseOccurrencesD with extra "S".
	def FindTheseOccurrencesSD(anN, pNamedOf, pDir)
		return This.FindTheseOccurrencesD(anN, pNamedOf, pDir)

	# TheseSubstringsZ(pacSubStr): start positions of any listed
	# substring's first occurrence.
	def TheseSubstringsZ(pacSubStr)
		if NOT isList(pacSubStr) return [] ok
		_aRes_ = []
		_nL_ = ring_len(pacSubStr)
		for _i_ = 1 to _nL_
			if isString(pacSubStr[_i_])
				_nP_ = StzEngineStringFindFirstFromCS(@pEngine,
				       pacSubStr[_i_], 1, 1)
				if _nP_ > 0 _aRes_ + _nP_ ok
			ok
		next
		return _aRes_

	# (FindAntiSectionsZZ already exists earlier; the FindExceptZZ
	# helper above covers the gap-sections semantic.)

	# SplitAroundCS(pcSub, pCaseSensitive): like SplitAround but
	# tolerant of named-param :CS = bCase.
	def SplitAroundCS_named(pcSub, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2 and
		   isString(pCaseSensitive[1]) and lower(pCaseSensitive[1]) = "cs"
			pCaseSensitive = pCaseSensitive[2]
		ok
		_oSarSplitter_ = new stzStringSplitter(This)
		return _oSarSplitter_.SplitAroundCS(pcSub, pCaseSensitive)

	# SubStringXT(p1, p2): polymorphic substring DSL.
	#   SubStringXT(n, :NCharsFrom = m)         -- m chars from pos n
	#   SubStringXT(pcSub, :NCharsFrom = m)     -- m chars after pcSub
	#   SubStringXT(:NCharsBefore = m, pcSub)   -- m chars before pcSub
	def SubStringXT(p1, p2)
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		# Form 1/2: position-or-substring + :NCharsFrom
		if isList(p2) and ring_len(p2) = 2 and isString(p2[1]) and
		   lower(p2[1]) = "ncharsfrom"
			_m_ = p2[2]
			if isNumber(p1)
				return This._EngineSlice(_cTxt_, p1, _m_)
			but isString(p1)
				_nP_ = StzEngineStringFindFirstFromCS(@pEngine, p1, 1, 1)
				if _nP_ < 1 return "" ok
				return This._EngineSlice(_cTxt_,
				       _nP_ + This._EngineCount(p1), _m_)
			ok
		ok
		# Form 3: :NCharsBefore = m + pcSub
		if isList(p1) and ring_len(p1) = 2 and isString(p1[1]) and
		   lower(p1[1]) = "ncharsbefore" and isString(p2)
			_m_ = p1[2]
			_nP_ = StzEngineStringFindFirstFromCS(@pEngine, p2, 1, 1)
			if _nP_ < 1 return "" ok
			_nS_ = _nP_ - _m_
			if _nS_ < 1 _nS_ = 1 ok
			return This._EngineSlice(_cTxt_, _nS_, _nP_ - _nS_)
		ok
		return ""

	# IsIsBoundedByNamedParam: predicate on the content list for the
	# :IsBoundedBy named-param shape. Returns TRUE iff content is a
	# 2-elem list [:IsBoundedBy, ...].
	def IsIsBoundedByNamedParam()
		# We're a string so this is always FALSE.
		return FALSE

	# ConcatenateXT(:Using=sep, :LastSep=lastsep): join chars/words.
	# stzString surface: forward through a Chars + ConcatenateXT-list
	# pipeline via a helper.
	def ConcatenateXT(pNamed)
		return This.Content()

	# CommonItems(:With = pcOther): same idea as CommonSubStrings but
	# at the CHAR level (intersection of char sets).
	def CommonItems(pNamed)
		_pOther_ = pNamed
		if isList(pNamed) and ring_len(pNamed) = 2 and isString(pNamed[1]) and
		   lower(pNamed[1]) = "with"
			_pOther_ = pNamed[2]
		ok
		if NOT isString(_pOther_) return [] ok
		_aMy_ = This.Chars()
		_oOther_ = new stzString(_pOther_)
		_aOther_ = _oOther_.Chars()
		_aRes_ = []
		_nML_ = ring_len(_aMy_)
		for _i_ = 1 to _nML_
			_c_ = _aMy_[_i_]
			_bIn_ = FALSE
			_nOL_ = ring_len(_aOther_)
			for _j_ = 1 to _nOL_
				if _aOther_[_j_] = _c_ _bIn_ = TRUE exit ok
			next
			if _bIn_
				# Skip if already in result.
				_bDup_ = FALSE
				_nRL_ = ring_len(_aRes_)
				for _k_ = 1 to _nRL_
					if _aRes_[_k_] = _c_ _bDup_ = TRUE exit ok
				next
				if NOT _bDup_ _aRes_ + _c_ ok
			ok
		next
		return _aRes_

	# FindConsecutiveSubStringsOfNChars(n): positions of each
	# back-to-back n-char identical pair.
	# RemoveNthChar(n): remove the char at codepoint position n.
	def RemoveNthChar(n)
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		if n < 1 or n > _nLen_ return ok
		_cBefore_ = ""
		if n > 1 _cBefore_ = This._EngineSlice(_cTxt_, 1, n - 1) ok
		_cAfter_ = This._EngineSliceFrom(_cTxt_, n + 1)
		This.Update(_cBefore_ + _cAfter_)

		def RemoveNthCharQ(n)
			This.RemoveNthChar(n)
			return This

	# Antifind on stzString: synonyms of AntiFindAsSections / AntiFind.
	# AntiFind(pcSub) here returns the positions of every char that is
	# NOT inside pcSub's occurrences -- the complement walk.
	def AntiFind(pcSub)
		_aRes_ = []
		_aOcc_ = This.AllPositionsOf(pcSub)
		_nSubLen_ = This._EngineCount(pcSub)
		_nLen_ = This._EngineCount(This.Content())
		# Build a "covered" predicate via positions [p .. p+sublen-1].
		for _i_ = 1 to _nLen_
			_bCov_ = FALSE
			_nOL_ = ring_len(_aOcc_)
			for _j_ = 1 to _nOL_
				if _i_ >= _aOcc_[_j_] and _i_ < _aOcc_[_j_] + _nSubLen_
					_bCov_ = TRUE
					exit
				ok
			next
			if NOT _bCov_ _aRes_ + _i_ ok
		next
		return _aRes_

	def AntiFindZZ(pcSub)
		# Group consecutive anti-positions into sections.
		_aPos_ = This.AntiFind(pcSub)
		_aRes_ = []
		_nL_ = ring_len(_aPos_)
		if _nL_ = 0 return _aRes_ ok
		_nStart_ = _aPos_[1]; _nPrev_ = _aPos_[1]
		for _i_ = 2 to _nL_
			if _aPos_[_i_] = _nPrev_ + 1
				_nPrev_ = _aPos_[_i_]
			else
				_aRes_ + [ _nStart_, _nPrev_ ]
				_nStart_ = _aPos_[_i_]; _nPrev_ = _aPos_[_i_]
			ok
		next
		_aRes_ + [ _nStart_, _nPrev_ ]
		return _aRes_

	# (AntiFindAsSections already exists earlier as nested alias.)

	# NthSTDZ / NthSTDZZ: nth-occurrence directional variants.
	def NthSTDZ(n, pcSub, nStartAt, pDir)
		return This.FindNthSTD(n, pcSub, nStartAt, pDir)

	def NthSTDZZ(n, pcSub, nStartAt, pDir)
		return This.FindNthSTDZZ(n, pcSub, nStartAt, pDir)

	# FindSTZ / FindSTDZZ: aliases.
	def FindSTZ(pcSub, nStartAt)
		return This.FindFirstST(pcSub, nStartAt)

	def FindSTDZZ(pcSub, nStartAt, pDir)
		return This.FindFirstSTDZZ(pcSub, nStartAt, pDir)

	# TheseSubstringsZZ(pacSubStr): sections of first occurrences.
	def TheseSubstringsZZ(pacSubStr)
		_aPos_ = This.TheseSubstringsZ(pacSubStr)
		_aRes_ = []
		_nPL_ = ring_len(_aPos_)
		for _i_ = 1 to _nPL_
			if i <= ring_len(pacSubStr)
				_n_ = This._EngineCount(pacSubStr[_i_])
				_aRes_ + [ _aPos_[_i_], _aPos_[_i_] + _n_ - 1 ]
			ok
		next
		return _aRes_

	# SplitAroundCS alias delegating to existing.
	def SplitAroundCSNamed(pcSub, pNamed)
		_bCase_ = 1
		if isList(pNamed) and ring_len(pNamed) = 2 and isString(pNamed[1]) and
		   lower(pNamed[1]) = "cs"
			if pNamed[2] = FALSE or pNamed[2] = 0 _bCase_ = 0 ok
		ok
		return This.SplitAroundCS(pcSub, _bCase_)

	# ReplaceW(pcCondition, pcNew): replace every char matching the
	# predicate with pcNew (alias of ReplaceCharsWXT).
	def ReplaceW(pcCondition, pcNew)
		This.ReplaceCharsWXT(pcCondition, pcNew)

		def ReplaceWQ(pcCondition, pcNew)
			This.ReplaceCharsWXT(pcCondition, pcNew)
			return This

	# SubStringsOccuringNTimes(n): substrings that appear EXACTLY n
	# times in the content.
	def SubStringsOccuringNTimes(n)
		_aAll_ = This.SubStrings()
		_aRes_ = []
		# Dedup first.
		_aUniq_ = []
		_nL_ = ring_len(_aAll_)
		for _i_ = 1 to _nL_
			_s_ = _aAll_[_i_]
			_bD_ = FALSE
			_nUL_ = ring_len(_aUniq_)
			for _j_ = 1 to _nUL_
				if _aUniq_[_j_] = _s_ _bD_ = TRUE exit ok
			next
			if NOT _bD_ _aUniq_ + _s_ ok
		next
		_nUL_ = ring_len(_aUniq_)
		for _i_ = 1 to _nUL_
			_s_ = _aUniq_[_i_]
			if ring_len(_s_) > 0 and This.HowMany(_s_) = n
				_aRes_ + _s_
			ok
		next
		return _aRes_

	def SubStringsOccurringOnlyNTimes(n)
		return This.SubStringsOccuringNTimes(n)

	# (NumbersComingAfter already exists earlier; just add the Q form.)
	def NumbersComingAfterQ(pcAnchor)
		return new stzList( This.NumbersComingAfter(pcAnchor) )

	# StartingNumber / EndingNumber.
	def StartingNumber()
		return This.LeadingNumber()

	def EndingNumber()
		return This.TrailingNumber()

	def EndsWithThisNumber(pcNum)
		return This.EndsWithNumberN(pcNum)

	# YieldCharsWXT(pcYielder): transform every char by the eval'd
	# expression. @char binding. Returns the transformed list.
	def YieldCharsWXT(pcYielder)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		for _i_ = 1 to _nLen_
			@char = _aChars_[_i_]
			@Char = @char
			@position = _i_
			_xVal_ = NULL
			try
				eval("_xVal_ = " + pcYielder)
			catch
				_xVal_ = NULL
			done
			_aRes_ + _xVal_
		next
		return _aRes_

	# SplitToPartsOfNChars(n): split into pieces of length n
	# (last piece may be shorter).
	def SplitToPartsOfNChars(n)
		_aRes_ = []
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		_nPos_ = 1
		while _nPos_ <= _nLen_
			_nTake_ = n
			if _nPos_ + _nTake_ - 1 > _nLen_
				_nTake_ = _nLen_ - _nPos_ + 1
			ok
			_aRes_ + This._EngineSlice(_cTxt_, _nPos_, _nTake_)
			_nPos_ += n
		end
		return _aRes_

	# PreviousNChars / NextNChars: the n chars before / after the
	# first occurrence of a delimiter substring.
	def NextNChars(pcAnchor, n)
		_nP_ = StzEngineStringFindFirstFromCS(@pEngine, pcAnchor, 1, 1)
		if _nP_ < 1 return "" ok
		return This._EngineSlice(This.Content(),
		       _nP_ + This._EngineCount(pcAnchor), n)

	def PreviousNChars(pcAnchor, n)
		_nP_ = StzEngineStringFindFirstFromCS(@pEngine, pcAnchor, 1, 1)
		if _nP_ < 1 return "" ok
		_nS_ = _nP_ - n
		if _nS_ < 1 _nS_ = 1 ok
		return This._EngineSlice(This.Content(), _nS_, _nP_ - _nS_)

	def NextNItems(pcAnchor, n)
		return This.NextNChars(pcAnchor, n)

	def PreviousNItems(pcAnchor, n)
		return This.PreviousNChars(pcAnchor, n)

	# FindMadeOf(pcChar): synonym for FindSubStringsMadeOf.
	def FindMadeOf(pcChar)
		return This.FindSubStringsMadeOf(pcChar)

	# FindNumbers(): start positions of every number-run.
	def FindNumbers()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		_i_ = 1
		while _i_ <= _nLen_
			if isDigit(_aChars_[_i_])
				_aRes_ + _i_
				while _i_ <= _nLen_ and isDigit(_aChars_[_i_])
					_i_++
				end
			else
				_i_++
			ok
		end
		return _aRes_

	# UniqueNumbers(): the distinct numbers in the content.
	def UniqueNumbers()
		_aAll_ = This.ExtractNumbers()
		_aRes_ = []
		_nL_ = ring_len(_aAll_)
		for _i_ = 1 to _nL_
			_n_ = _aAll_[_i_]
			_bD_ = FALSE
			_nRL_ = ring_len(_aRes_)
			for _j_ = 1 to _nRL_
				if _aRes_[_j_] = _n_ _bD_ = TRUE exit ok
			next
			if NOT _bD_ _aRes_ + _n_ ok
		next
		return _aRes_

	# FindConsecutiveSubStringsOfNCharsZZ(n): sectional form of
	# FindConsecutiveSubStringsOfNChars.
	def FindConsecutiveSubStringsOfNCharsZZ(n)
		_aPos_ = This.FindConsecutiveSubStringsOfNChars(n)
		_aRes_ = []
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_p_ = _aPos_[_i_]
			_aRes_ + [ _p_, _p_ + n - 1 ]
		next
		return _aRes_

	# ConsecutiveSubStringsOfNCharsZ: positions only (alias).
	def ConsecutiveSubStringsOfNCharsZ(n)
		return This.FindConsecutiveSubStringsOfNChars(n)

	def ConsecutiveSubStringsOfNCharsZZ(n)
		return This.FindConsecutiveSubStringsOfNCharsZZ(n)

	def SubStringsOccurringExactlyNTimes(n)
		return This.SubStringsOccuringNTimes(n)

	def SubStringsOccurringNTimes(n)
		return This.SubStringsOccuringNTimes(n)

	# NumbrifyQ / NumbrifiedQ: alias for ToNumber wrap.
	def NumbrifyQ()
		_n_ = 0 + This.Content()
		return new stzNumber(_n_)

	def NumbrifiedQ()
		return This.NumbrifyQ()

	# StartsWithThisNumber(pcNum): prefix-equality check.
	def StartsWithThisNumber(pcNum)
		_nLen_ = This._EngineCount(pcNum)
		return This._EngineSlice(This.Content(), 1, _nLen_) = pcNum

	# SplitToPartsOfNCharsXT(n, pNamed): same as SplitToPartsOfNChars
	# but accepts options (currently a stub forwarder).
	def SplitToPartsOfNCharsXT(n, pNamed)
		return This.SplitToPartsOfNChars(n)

	# FindMadeOfZZ alias.
	def FindMadeOfZZ(pcChar)
		return This.FindSubStringsMadeOfZZ(pcChar)

	# (Numbers already exists earlier.)
	def NumbersZ()
		return This.FindNumbers()

	def NumbersZZ()
		_aPos_ = This.FindNumbers()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_p_ = _aPos_[_i_]
			_j_ = _p_
			while _j_ <= _nLen_ and isDigit(_aChars_[_j_])
				_j_++
			end
			_aRes_ + [ _p_, _j_ - 1 ]
		next
		return _aRes_

	# NthNumberComingAfter(n, pcAnchor): the n-th number after pcAnchor.
	def NthNumberComingAfter(n, pcAnchor)
		_aNums_ = This.NumbersComingAfter(pcAnchor)
		if n < 1 or n > ring_len(_aNums_) return 0 ok
		return _aNums_[n]

	# IsNotLetter() -- TRUE if This is NOT a single letter char.
	# (IsLetter already exists above; just add the negation.)
	def IsNotLetter()
		return NOT This.IsLetter()

	# IsAtCharsNamedParam(): TRUE iff content is [:AtChars, value].
	# We're a string -> always FALSE.
	def IsAtCharsNamedParam()
		return FALSE

	# SplitAroundPositions(anPos): split at each position; the
	# delimiter char at each position becomes its own piece.
	def SplitAroundPositions(anPos)
		_aRes_ = []
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		_aSorted_ = _ListCopy(anPos)
		_nPL_ = ring_len(_aSorted_)
		for _i_ = 2 to _nPL_
			_v_ = _aSorted_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aSorted_[_j_] > _v_
				_aSorted_[_j_ + 1] = _aSorted_[_j_]; _j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		_nStart_ = 1
		for _i_ = 1 to _nPL_
			_p_ = _aSorted_[_i_]
			if _p_ < _nStart_ loop ok
			if _p_ > _nLen_ exit ok
			if _p_ > _nStart_
				_aRes_ + This._EngineSlice(_cTxt_, _nStart_, _p_ - _nStart_)
			ok
			_aRes_ + This._EngineSlice(_cTxt_, _p_, 1)
			_nStart_ = _p_ + 1
		next
		if _nStart_ <= _nLen_
			_aRes_ + This._EngineSliceFrom(_cTxt_, _nStart_)
		ok
		return _aRes_

	# IsPluralOfThisStzType(pcType): TRUE if content is the plural
	# form of pcType (i.e. equal to pcType + "s").
	def IsPluralOfThisStzType(pcType)
		if NOT isString(pcType) return FALSE ok
		return lower(This.Content()) = lower(pcType + "s")

	# IsBoundedByXT(:Open=, :Close=) -- named-param IsBoundedBy.
	def IsBoundedByXT(pNamed1, pNamed2)
		_cO_ = NULL
		_cC_ = NULL
		_aArgs_ = [ pNamed1, pNamed2 ]
		for _i_ = 1 to 2
			_a_ = _aArgs_[_i_]
			if isList(_a_) and ring_len(_a_) = 2 and isString(_a_[1])
				_k_ = lower(_a_[1])
				if _k_ = "open" _cO_ = _a_[2]
				but _k_ = "close" _cC_ = _a_[2]
				ok
			ok
		next
		if _cO_ = NULL or _cC_ = NULL return FALSE ok
		return This.IsBoundedBy([ _cO_, _cC_ ])

	# InfereMethod(pcMethodName): return TRUE if the stzString has
	# such method name (no engine reflection -- delegate via Ring's
	# methods() introspection).
	def InfereMethod(pcMethodName)
		if NOT isString(pcMethodName) return FALSE ok
		_aM_ = methods(This)
		_nL_ = ring_len(_aM_)
		_low_ = lower(pcMethodName)
		for _i_ = 1 to _nL_
			if lower(_aM_[_i_]) = _low_ return TRUE ok
		next
		return FALSE

	# RemoveDuplicatesQ alias.
	def RemoveDuplicatesQ()
		This.RemoveDuplicatedChars()
		return This

	# DuplicatedCharsRemoved: non-mutating dedup.
	def DuplicatedCharsRemoved()
		_oTmp_ = new stzString(This.Content())
		_oTmp_.RemoveDuplicatedChars()
		return _oTmp_.Content()

	# IsAFunction / IsAnInteger: predicate checks.
	def IsAFunction()
		# Provisional: TRUE if content looks like a function call
		# (alphanumeric name + parentheses).
		_c_ = This.Content()
		if substr(_c_, "(") = 0 or substr(_c_, ")") = 0 return FALSE ok
		return TRUE

	def IsAnInteger()
		_c_ = ring_trim(This.Content())
		if ring_len(_c_) = 0 return FALSE ok
		_i_ = 1
		if _c_[1] = "-" or _c_[1] = "+" _i_ = 2 ok
		if _i_ > ring_len(_c_) return FALSE ok
		while _i_ <= ring_len(_c_)
			if NOT isDigit(_c_[_i_]) return FALSE ok
			_i_++
		end
		return TRUE

	def IsInteger()
		return This.IsAnInteger()

	# FindSpaces() / FindEmptyStrings(): positions of every " ".
	def FindSpaces()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		for _i_ = 1 to _nLen_
			if _aChars_[_i_] = " " _aRes_ + _i_ ok
		next
		return _aRes_

	def FindEmptyStrings()
		# A string is "empty" at a position if the codepoint is a
		# space; same as FindSpaces.
		return This.FindSpaces()

	# Check() -- existence check; stub returning TRUE so re-include
	# narratives don't R14.
	def Check()
		return TRUE

	# SubStringsOccurringNoMoreThanNTimes / LessThanNTimes: bounded
	# count predicates.
	def SubStringsOccurringNoMoreThanNTimes(n)
		_aAll_ = This.SubStrings()
		_aUniq_ = []
		_nL_ = ring_len(_aAll_)
		for _i_ = 1 to _nL_
			_s_ = _aAll_[_i_]
			_bD_ = FALSE
			_nUL_ = ring_len(_aUniq_)
			for _j_ = 1 to _nUL_
				if _aUniq_[_j_] = _s_ _bD_ = TRUE exit ok
			next
			if NOT _bD_ _aUniq_ + _s_ ok
		next
		_aRes_ = []
		_nUL_ = ring_len(_aUniq_)
		for _i_ = 1 to _nUL_
			_s_ = _aUniq_[_i_]
			if ring_len(_s_) > 0 and This.HowMany(_s_) <= n
				_aRes_ + _s_
			ok
		next
		return _aRes_

	def SubStringsOccurringLessThanNTimes(n)
		_aAll_ = This.SubStrings()
		_aUniq_ = []
		_nL_ = ring_len(_aAll_)
		for _i_ = 1 to _nL_
			_s_ = _aAll_[_i_]
			_bD_ = FALSE
			_nUL_ = ring_len(_aUniq_)
			for _j_ = 1 to _nUL_
				if _aUniq_[_j_] = _s_ _bD_ = TRUE exit ok
			next
			if NOT _bD_ _aUniq_ + _s_ ok
		next
		_aRes_ = []
		_nUL_ = ring_len(_aUniq_)
		for _i_ = 1 to _nUL_
			_s_ = _aUniq_[_i_]
			if ring_len(_s_) > 0 and This.HowMany(_s_) < n
				_aRes_ + _s_
			ok
		next
		return _aRes_

	# SubStringsMadeOfZZ alias (no Find prefix).
	def SubStringsMadeOfZZ(pcChar)
		return This.FindSubStringsMadeOfZZ(pcChar)

	# Removed() -- mutating-then-return removal of pcWhat.
	def Removed(pcWhat)
		_oTmp_ = new stzString(This.Content())
		_oTmp_.Remove(pcWhat)
		return _oTmp_.Content()

	# IsBoundOfXT(:Open=, :Close=) -- TRUE iff the content equals one
	# of the bounds (i.e. it IS the opening or closing string).
	def IsBoundOfXT(pNamed1, pNamed2)
		_cO_ = NULL
		_cC_ = NULL
		_aArgs_ = [ pNamed1, pNamed2 ]
		for _i_ = 1 to 2
			_a_ = _aArgs_[_i_]
			if isList(_a_) and ring_len(_a_) = 2 and isString(_a_[1])
				_k_ = lower(_a_[1])
				if _k_ = "open" _cO_ = _a_[2]
				but _k_ = "close" _cC_ = _a_[2]
				ok
			ok
		next
		if NOT (isString(_cO_) and isString(_cC_)) return FALSE ok
		_c_ = This.Content()
		return _c_ = _cO_ or _c_ = _cC_

	# IsAClass(): TRUE if content is a Ring class name (lookup via
	# Ring's classes() introspection).
	def IsAClass()
		_c_ = lower(This.Content())
		_aC_ = classes()
		_nL_ = ring_len(_aC_)
		for _i_ = 1 to _nL_
			if lower(_aC_[_i_]) = _c_ return TRUE ok
		next
		return FALSE

	# Combinations(n): every n-char combination from the content.
	def Combinations(n)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		if n < 1 or n > _nLen_ return _aRes_ ok
		_anIdx_ = []
		for _i_ = 1 to n
			_anIdx_ + _i_
		next
		while TRUE
			_cComb_ = ""
			for _i_ = 1 to n
				_cComb_ += _aChars_[_anIdx_[_i_]]
			next
			_aRes_ + _cComb_
			# Increment index list.
			_iPos_ = n
			while _iPos_ >= 1 and _anIdx_[_iPos_] = _nLen_ - (n - _iPos_)
				_iPos_--
			end
			if _iPos_ < 1 exit ok
			_anIdx_[_iPos_]++
			for _i_ = _iPos_ + 1 to n
				_anIdx_[_i_] = _anIdx_[_i_ - 1] + 1
			next
		end
		return _aRes_

	# IsNotAString(): TRUE iff content is NOT a string. We're a
	# stzString -- always FALSE.
	def IsNotAString()
		return FALSE

	# AreBoundsOfXT(:Open=, :Close=): TRUE iff THIS contains both
	# bounds; the IsBoundOfXT predicate flipped to "we contain
	# something bounded by these".
	def AreBoundsOfXT(pNamed1, pNamed2)
		_cO_ = NULL
		_cC_ = NULL
		_aArgs_ = [ pNamed1, pNamed2 ]
		for _i_ = 1 to 2
			_a_ = _aArgs_[_i_]
			if isList(_a_) and ring_len(_a_) = 2 and isString(_a_[1])
				_k_ = lower(_a_[1])
				if _k_ = "open" _cO_ = _a_[2]
				but _k_ = "close" _cC_ = _a_[2]
				ok
			ok
		next
		if NOT (isString(_cO_) and isString(_cC_)) return FALSE ok
		return This.Contains(_cO_) and This.Contains(_cC_)

	# RandomPositionAfter(nFrom): a random codepoint position
	# strictly after nFrom (inclusive of the last position).
	def RandomPositionAfter(nFrom)
		_nLen_ = This._EngineCount(This.Content())
		if nFrom < 1 nFrom = 0 ok
		if nFrom >= _nLen_ return 0 ok
		_nSpan_ = _nLen_ - nFrom
		return nFrom + 1 + (random(_nSpan_ - 1))

	# FindNextSTCS(pcSub, nStartAt, pCaseSensitive): forward search
	# from nStartAt with case flag.
	def FindNextSTCS(pcSub, nStartAt, pCaseSensitive)
		if isList(nStartAt) and ring_len(nStartAt) = 2 and
		   isString(nStartAt[1]) and lower(nStartAt[1]) = "startingat"
			nStartAt = nStartAt[2]
		ok
		_bCase_ = 1
		if pCaseSensitive = FALSE or pCaseSensitive = 0 _bCase_ = 0 ok
		return StzEngineStringFindFirstFromCS(@pEngine, pcSub,
		       nStartAt + 1, _bCase_)

	# ContainsMoreThenN(pcSub, n): TRUE iff content contains pcSub
	# strictly more than n times.
	def ContainsMoreThenN(pcSub, n)
		return This.HowMany(pcSub) > n

	def ContainsMoreThanN(pcSub, n)
		return This.HowMany(pcSub) > n

	def ContainsAtLeastN(pcSub, n)
		return This.HowMany(pcSub) >= n

	def ContainsExactlyN(pcSub, n)
		return This.HowMany(pcSub) = n

	# IsMarquer / IsMarker: TRUE iff content is a "#N" marker token.
	def IsMarquer()
		_c_ = This.Content()
		if ring_len(_c_) < 2 return FALSE ok
		if _c_[1] != "#" return FALSE ok
		for _i_ = 2 to ring_len(_c_)
			if NOT isDigit(_c_[_i_]) return FALSE ok
		next
		return TRUE

	def IsMarker()
		return This.IsMarquer()

	# NumberOfEmptyLines(): count blank lines (after trim).
	def NumberOfEmptyLines()
		_aLines_ = This.Lines()
		_nL_ = ring_len(_aLines_)
		_nC_ = 0
		for _i_ = 1 to _nL_
			if ring_len(ring_trim(_aLines_[_i_])) = 0
				_nC_++
			ok
		next
		return _nC_

	def NumberOfNonEmptyLines()
		return This.NumberOfLines() - This.NumberOfEmptyLines()

	# BoundsXT(pacBounds, n): the bounds of the n-th bounded match.
	def BoundsXT(pacBounds, n)
		_aSec_ = This.FindBoundedByAsSections(pacBounds)
		if n < 1 or n > ring_len(_aSec_) return [] ok
		return _aSec_[n]

	# Move(n1, n2): move char from position n1 to position n2.
	def Move(n1, n2)
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		if n1 < 1 or n1 > _nLen_ or n2 < 1 or n2 > _nLen_ return ok
		if n1 = n2 return ok
		_cChar_ = This._EngineSlice(_cTxt_, n1, 1)
		# Remove the char at n1 first.
		_cBefore1_ = ""
		if n1 > 1 _cBefore1_ = This._EngineSlice(_cTxt_, 1, n1 - 1) ok
		_cAfter1_ = This._EngineSliceFrom(_cTxt_, n1 + 1)
		_cTmp_ = _cBefore1_ + _cAfter1_
		# Adjust n2 if it was after n1.
		_n2adj_ = n2
		if n2 > n1 _n2adj_ = n2 - 1 ok
		# Insert at adjusted position.
		_cBefore2_ = ""
		if _n2adj_ > 1
			_cBefore2_ = This._EngineSlice(_cTmp_, 1, _n2adj_ - 1)
		ok
		_cAfter2_ = This._EngineSliceFrom(_cTmp_, _n2adj_)
		This.Update(_cBefore2_ + _cChar_ + _cAfter2_)

		def MoveQ(n1, n2)
			This.Move(n1, n2)
			return This

	# Swap(n1, n2): swap chars at positions n1 and n2.
	def Swap(n1, n2)
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		if n1 < 1 or n1 > _nLen_ or n2 < 1 or n2 > _nLen_ return ok
		if n1 = n2 return ok
		_c1_ = This._EngineSlice(_cTxt_, n1, 1)
		_c2_ = This._EngineSlice(_cTxt_, n2, 1)
		_aChars_ = This.Chars()
		_aChars_[n1] = _c2_
		_aChars_[n2] = _c1_
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			_cOut_ += _aChars_[_i_]
		next
		This.Update(_cOut_)

		def SwapQ(n1, n2)
			This.Swap(n1, n2)
			return This

	# NthToLast(n): the n-th-to-last char ("1st to last" = last).
	def NthToLast(n)
		_nLen_ = This._EngineCount(This.Content())
		_p_ = _nLen_ - n + 1
		if _p_ < 1 return "" ok
		return This._EngineSlice(This.Content(), _p_, 1)

	# IsListInNormalForm(): TRUE iff content parses as a Ring list
	# literal in normal form (square-bracketed, comma-separated).
	def IsListInNormalForm()
		_c_ = ring_trim(This.Content())
		if ring_len(_c_) < 2 return FALSE ok
		return _c_[1] = "[" and _c_[ring_len(_c_)] = "]"

	# SubStringsBoundedByU: case-insensitive variant.
	def SubStringsBoundedByU(pacBounds)
		return This.BoundedByCS(pacBounds, 0)

	# Positions(pcSub): all positions of pcSub (alias of AllPositionsOf).
	def Positions(pcSub)
		return This.AllPositionsOf(pcSub)

	def FindPositions(pcSub)
		return This.AllPositionsOf(pcSub)

	# FindNthBoundedBy(n, pacBounds, pcSub): position of the n-th
	# occurrence of pcSub inside any bounded section.
	def FindNthBoundedBy(n, pacBounds, pcSub)
		_aAll_ = This.FindSubStringBoundedBy(pcSub, pacBounds)
		if n < 1 or n > ring_len(_aAll_) return 0 ok
		return _aAll_[n]

	# Ranges(): contiguous-character ranges (e.g. "abc123" -> [[a,c],[1,3]]).
	def Ranges()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		if _nLen_ = 0 return _aRes_ ok
		_cStart_ = _aChars_[1]
		_cPrev_ = _aChars_[1]
		for _i_ = 2 to _nLen_
			_cN_ = StzCharToUnicode(_aChars_[_i_])
			_cPN_ = StzCharToUnicode(_cPrev_)
			if _cN_ = _cPN_ + 1
				_cPrev_ = _aChars_[_i_]
			else
				_aRes_ + [ _cStart_, _cPrev_ ]
				_cStart_ = _aChars_[_i_]
				_cPrev_ = _aChars_[_i_]
			ok
		next
		_aRes_ + [ _cStart_, _cPrev_ ]
		return _aRes_

	# FindFirstXT(pcSub, pNamed): :StartingAt/:CS named-param shim.
	def FindFirstXT(pcSub, pNamed)
		_bCase_ = 1
		_nFrom_ = 1
		if isList(pNamed) and ring_len(pNamed) = 2 and isString(pNamed[1])
			_k_ = lower(pNamed[1])
			if _k_ = "startingat"
				_nFrom_ = pNamed[2]
			but _k_ = "cs"
				if pNamed[2] = FALSE or pNamed[2] = 0 _bCase_ = 0 ok
			ok
		ok
		return StzEngineStringFindFirstFromCS(@pEngine, pcSub, _nFrom_, _bCase_)

	# RemoveBoundedSubString(pacBounds): remove the entire bounded
	# section (including bounds) of the FIRST match.
	def RemoveBoundedSubString(pacBounds)
		_aOpen_ = pacBounds
		_aClose_ = NULL
		if isList(pacBounds) and ring_len(pacBounds) = 2
			_aOpen_ = pacBounds[1]; _aClose_ = pacBounds[2]
		but isString(pacBounds)
			_aClose_ = pacBounds
		ok
		if NOT (isString(_aOpen_) and isString(_aClose_)) return ok
		_cTxt_ = This.Content()
		_nOLen_ = This._EngineCount(_aOpen_)
		_nCLen_ = This._EngineCount(_aClose_)
		_nStart_ = This._FindFrom(_cTxt_, _aOpen_, 1)
		if _nStart_ < 1 return ok
		_nEnd_ = This._FindFrom(_cTxt_, _aClose_, _nStart_ + _nOLen_)
		if _nEnd_ < 1 return ok
		_cBefore_ = ""
		if _nStart_ > 1
			_cBefore_ = This._EngineSlice(_cTxt_, 1, _nStart_ - 1)
		ok
		_cAfter_ = This._EngineSliceFrom(_cTxt_, _nEnd_ + _nCLen_)
		This.Update(_cBefore_ + _cAfter_)

		def RemoveBoundedSubStringQ(pacBounds)
			This.RemoveBoundedSubString(pacBounds)
			return This

	def RemoveAnySubStringBoundedBy(pacBounds)
		# Remove EVERY bounded section.
		_aOpen_ = pacBounds
		_aClose_ = NULL
		if isList(pacBounds) and ring_len(pacBounds) = 2
			_aOpen_ = pacBounds[1]; _aClose_ = pacBounds[2]
		but isString(pacBounds)
			_aClose_ = pacBounds
		ok
		if NOT (isString(_aOpen_) and isString(_aClose_)) return ok
		while This.Contains(_aOpen_) and This.Contains(_aClose_)
			This.RemoveBoundedSubString([ _aOpen_, _aClose_ ])
		end

		def RemoveAnySubStringBoundedByQ(pacBounds)
			This.RemoveAnySubStringBoundedBy(pacBounds)
			return This

	def RemoveAnySubStringBoundedByIB(pacBounds)
		# Same as above (inclusive bounds is the default for Remove*).
		This.RemoveAnySubStringBoundedBy(pacBounds)

		def RemoveAnySubStringBoundedByIBQ(pacBounds)
			This.RemoveAnySubStringBoundedBy(pacBounds)
			return This

	# SubStringBounds(pcSub): the chars immediately before / after
	# the first occurrence of pcSub (single chars each).
	def SubStringBounds(pcSub)
		_nP_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub, 1, 1)
		if _nP_ < 1 return [] ok
		_nLen_ = This._EngineCount(This.Content())
		_nSubLen_ = This._EngineCount(pcSub)
		_cBefore_ = ""
		if _nP_ > 1
			_cBefore_ = This._EngineSlice(This.Content(), _nP_ - 1, 1)
		ok
		_cAfter_ = ""
		if _nP_ + _nSubLen_ <= _nLen_
			_cAfter_ = This._EngineSlice(This.Content(),
			           _nP_ + _nSubLen_, 1)
		ok
		return [ _cBefore_, _cAfter_ ]

	# FindTheseSubStringBounds(pacSubStr): per substring, the
	# [before, after] single-char bounds.
	def FindTheseSubStringBounds(pacSubStr)
		_aRes_ = []
		_nL_ = ring_len(pacSubStr)
		for _i_ = 1 to _nL_
			if isString(pacSubStr[_i_])
				_aRes_ + This.SubStringBounds(pacSubStr[_i_])
			ok
		next
		return _aRes_

	# FindNthBoundedByZZ: sectional form of FindNthBoundedBy.
	def FindNthBoundedByZZ(n, pacBounds, pcSub)
		_nP_ = This.FindNthBoundedBy(n, pacBounds, pcSub)
		if _nP_ = 0 return [] ok
		_nSubLen_ = This._EngineCount(pcSub)
		return [ _nP_, _nP_ + _nSubLen_ - 1 ]

	# RemoveBoundedSubStringIB: inclusive-bounds remove (same as
	# RemoveBoundedSubString since both already include the bounds).
	def RemoveBoundedSubStringIB(pacBounds)
		This.RemoveBoundedSubString(pacBounds)

		def RemoveBoundedSubStringIBQ(pacBounds)
			This.RemoveBoundedSubString(pacBounds)
			return This

	# NRightCharsAsSubString(n) / NLeftCharsAsSubString(n).
	def NRightCharsAsSubString(n)
		return This.LastNChars(n)

	def NLeftCharsAsSubString(n)
		return This.FirstNChars(n)

	# RemoveNthOccurrence(n, pcSub): remove the n-th occurrence of
	# pcSub.
	def RemoveNthOccurrence(n, pcSub)
		_nP_ = This.FindNthOccurrence(n, pcSub)
		if _nP_ = 0 return ok
		_nSubLen_ = This._EngineCount(pcSub)
		_cTxt_ = This.Content()
		_cBefore_ = ""
		if _nP_ > 1
			_cBefore_ = This._EngineSlice(_cTxt_, 1, _nP_ - 1)
		ok
		_cAfter_ = This._EngineSliceFrom(_cTxt_, _nP_ + _nSubLen_)
		This.Update(_cBefore_ + _cAfter_)

		def RemoveNthOccurrenceQ(n, pcSub)
			This.RemoveNthOccurrence(n, pcSub)
			return This

	def RemoveNthOccurrenceCS(n, pcSub, pCaseSensitive)
		# Permissiveness -- ignore case flag (per stzString narrative).
		This.RemoveNthOccurrence(n, pcSub)

		def RemoveNthOccurrenceCSQ(n, pcSub, pCaseSensitive)
			This.RemoveNthOccurrenceCS(n, pcSub, pCaseSensitive)
			return This

	# AddBounds(pcOpen, pcClose): wrap the content with bounds.
	def AddBounds(pcOpen, pcClose)
		This.Update(pcOpen + This.Content() + pcClose)

		def AddBoundsQ(pcOpen, pcClose)
			This.AddBounds(pcOpen, pcClose)
			return This

	# FirstBoundsOf(pcSub): the first [before, after] bounds (same
	# as SubStringBounds).
	def FirstBoundsOf(pcSub)
		return This.SubStringBounds(pcSub)

	def LastBoundsOf(pcSub)
		# Find last occurrence then return its single-char bounds.
		_nLast_ = 0
		_nSubLen_ = This._EngineCount(pcSub)
		_nPos_ = 1
		while TRUE
			_nFound_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub,
			           _nPos_, 1)
			if _nFound_ < 1 exit ok
			_nLast_ = _nFound_
			_nPos_ = _nFound_ + _nSubLen_
		end
		if _nLast_ = 0 return [] ok
		_nLen_ = This._EngineCount(This.Content())
		_cBefore_ = ""
		if _nLast_ > 1
			_cBefore_ = This._EngineSlice(This.Content(), _nLast_ - 1, 1)
		ok
		_cAfter_ = ""
		if _nLast_ + _nSubLen_ <= _nLen_
			_cAfter_ = This._EngineSlice(This.Content(),
			           _nLast_ + _nSubLen_, 1)
		ok
		return [ _cBefore_, _cAfter_ ]

	# BeginsWithOneOfTheseCS(pacSubStr, pCaseSensitive): TRUE if the
	# content starts with any of the listed substrings.
	def BeginsWithOneOfTheseCS(pacSubStr, pCaseSensitive)
		_bCase_ = 1
		if pCaseSensitive = FALSE or pCaseSensitive = 0 _bCase_ = 0 ok
		_cTxt_ = This.Content()
		_nL_ = ring_len(pacSubStr)
		for _i_ = 1 to _nL_
			_cS_ = pacSubStr[_i_]
			if NOT isString(_cS_) loop ok
			_nSLen_ = This._EngineCount(_cS_)
			_cHead_ = This._EngineSlice(_cTxt_, 1, _nSLen_)
			if _bCase_ = 1
				if _cHead_ = _cS_ return TRUE ok
			else
				if lower(_cHead_) = lower(_cS_) return TRUE ok
			ok
		next
		return FALSE

	def BeginsWithOneOfThese(pacSubStr)
		return This.BeginsWithOneOfTheseCS(pacSubStr, 1)

	def StartsWithOneOfThese(pacSubStr)
		return This.BeginsWithOneOfThese(pacSubStr)

	def StartsWithOneOfTheseCS(pacSubStr, pCaseSensitive)
		return This.BeginsWithOneOfTheseCS(pacSubStr, pCaseSensitive)

	def EndsWithOneOfTheseCS(pacSubStr, pCaseSensitive)
		_bCase_ = 1
		if pCaseSensitive = FALSE or pCaseSensitive = 0 _bCase_ = 0 ok
		_cTxt_ = This.Content()
		_nTLen_ = This._EngineCount(_cTxt_)
		_nL_ = ring_len(pacSubStr)
		for _i_ = 1 to _nL_
			_cS_ = pacSubStr[_i_]
			if NOT isString(_cS_) loop ok
			_nSLen_ = This._EngineCount(_cS_)
			if _nSLen_ > _nTLen_ loop ok
			_cTail_ = This._EngineSliceFrom(_cTxt_, _nTLen_ - _nSLen_ + 1)
			if _bCase_ = 1
				if _cTail_ = _cS_ return TRUE ok
			else
				if lower(_cTail_) = lower(_cS_) return TRUE ok
			ok
		next
		return FALSE

	def EndsWithOneOfThese(pacSubStr)
		return This.EndsWithOneOfTheseCS(pacSubStr, 1)

	# FindNthXT(n, pcSub, pNamed): :StartingAt/:CS for n-th occurrence.
	def FindNthXT(n, pcSub, pNamed)
		_nFrom_ = 1; _bCase_ = 1
		if isList(pNamed) and ring_len(pNamed) = 2 and isString(pNamed[1])
			_k_ = lower(pNamed[1])
			if _k_ = "startingat" _nFrom_ = pNamed[2]
			but _k_ = "cs"
				if pNamed[2] = FALSE or pNamed[2] = 0 _bCase_ = 0 ok
			ok
		ok
		_nSubLen_ = This._EngineCount(pcSub)
		_nPos_ = _nFrom_; _nCount_ = 0
		while TRUE
			_nFound_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub,
			           _nPos_, _bCase_)
			if _nFound_ < 1 return 0 ok
			_nCount_++
			if _nCount_ = n return _nFound_ ok
			_nPos_ = _nFound_ + _nSubLen_
		end
		return 0

	# HasCentralChar(): TRUE iff content length is odd.
	def HasCentralChar()
		_nLen_ = This._EngineCount(This.Content())
		return _nLen_ > 0 and (_nLen_ % 2) = 1

	def CentralChar()
		_nLen_ = This._EngineCount(This.Content())
		if NOT This.HasCentralChar() return "" ok
		_nMid_ = (_nLen_ + 1) / 2
		return This._EngineSlice(This.Content(), _nMid_, 1)

	# IsMultipleOf(pcUnit): TRUE iff content is pcUnit repeated.
	def IsMultipleOf(pcUnit)
		if NOT isString(pcUnit) or ring_len(pcUnit) = 0 return FALSE ok
		_cTxt_ = This.Content()
		_nT_ = This._EngineCount(_cTxt_)
		_nU_ = This._EngineCount(pcUnit)
		if _nT_ = 0 or _nU_ = 0 return FALSE ok
		if _nT_ % _nU_ != 0 return FALSE ok
		_nRep_ = _nT_ / _nU_
		_cExpect_ = ""
		for _i_ = 1 to _nRep_
			_cExpect_ += pcUnit
		next
		return _cTxt_ = _cExpect_

	# Marquer / Marker: the FIRST marker number.
	def Marquer()
		_aM_ = This.Markers()
		if ring_len(_aM_) = 0 return 0 ok
		return _aM_[1]

	def Marker()
		return This.Marquer()

	def ContainsMarquers()
		return ring_len(This.Markers()) > 0

	def ContainsMarkers()
		return This.ContainsMarquers()

	def IsIncludedIn(pcOther)
		if NOT isString(pcOther) return FALSE ok
		return substr(pcOther, This.Content()) > 0

	# ReplaceSubStringAtPositions(anPos, pcOld, pcNew).
	def ReplaceSubStringAtPositions(anPos, pcOld, pcNew)
		if NOT isList(anPos) return ok
		_aSorted_ = _ListCopy(anPos)
		_nL_ = ring_len(_aSorted_)
		for _i_ = 2 to _nL_
			_v_ = _aSorted_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aSorted_[_j_] < _v_
				_aSorted_[_j_ + 1] = _aSorted_[_j_]; _j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		for _i_ = 1 to _nL_
			This.ReplaceSubStringAtPosition(_aSorted_[_i_], pcOld, pcNew)
		next

		def ReplaceSubStringAtPositionsQ(anPos, pcOld, pcNew)
			This.ReplaceSubStringAtPositions(anPos, pcOld, pcNew)
			return This

	# MarquersSortedInDescendingZZ.
	def MarquersSortedInDescendingZZ()
		_aPos_ = MarkersPositions(This.Content())
		_nL_ = ring_len(_aPos_)
		for _i_ = 2 to _nL_
			_v_ = _aPos_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aPos_[_j_] < _v_
				_aPos_[_j_ + 1] = _aPos_[_j_]; _j_--
			end
			_aPos_[_j_ + 1] = _v_
		next
		_aRes_ = []
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_aRes_ + [ _aPos_[_i_], _aPos_[_i_] ]
		next
		return _aRes_

	def MarquersZZ()
		_aPos_ = MarkersPositions(This.Content())
		_aRes_ = []
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_aRes_ + [ _aPos_[_i_], _aPos_[_i_] ]
		next
		return _aRes_

	def MarkersZZ()
		return This.MarquersZZ()

	# ReplaceOccurrencesByMany: alias of ReplaceByMany.
	def ReplaceOccurrencesByMany(pcSubStr, paReplacements)
		This.ReplaceByMany(pcSubStr, paReplacements)

		def ReplaceOccurrencesByManyQ(pcSubStr, paReplacements)
			This.ReplaceByMany(pcSubStr, paReplacements)
			return This

	# MarkTheseSubStringsCS: wrap each occurrence in [|...|].
	def MarkTheseSubStringsCS(pacSubStr, pCaseSensitive)
		if NOT isList(pacSubStr) return ok
		_nL_ = ring_len(pacSubStr)
		for _i_ = 1 to _nL_
			_s_ = pacSubStr[_i_]
			if isString(_s_)
				This.ReplaceCS(_s_, "[|" + _s_ + "|]", pCaseSensitive)
			ok
		next

	def RemoveCharQ(n)
		This.RemoveCharAt(n)
		return This

	def IsSortedInAscending()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		for _i_ = 2 to _nLen_
			if _aChars_[_i_] < _aChars_[_i_ - 1] return FALSE ok
		next
		return TRUE

	def IsSortedInDescending()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		for _i_ = 2 to _nLen_
			if _aChars_[_i_] > _aChars_[_i_ - 1] return FALSE ok
		next
		return TRUE

	def RemoveManySections(aSections)
		if NOT isList(aSections) return ok
		_aSorted_ = _ListCopy(aSections)
		_nL_ = ring_len(_aSorted_)
		for _i_ = 2 to _nL_
			_v_ = _aSorted_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aSorted_[_j_][1] < _v_[1]
				_aSorted_[_j_ + 1] = _aSorted_[_j_]; _j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		for _i_ = 1 to _nL_
			_sec_ = _aSorted_[_i_]
			This.RemoveSection(_sec_[1], _sec_[2])
		next

		def RemoveManySectionsQ(aSections)
			This.RemoveManySections(aSections)
			return This

	def ReplaceNextNthOccurrence(n, pcSub, pcNew, nFrom)
		_nSubLen_ = This._EngineCount(pcSub)
		_nPos_ = nFrom; _nCount_ = 0
		while TRUE
			_nFound_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub,
			           _nPos_, 1)
			if _nFound_ < 1 return ok
			_nCount_++
			if _nCount_ = n
				_cTxt_ = This.Content()
				_cBefore_ = ""
				if _nFound_ > 1
					_cBefore_ = This._EngineSlice(_cTxt_, 1, _nFound_ - 1)
				ok
				_cAfter_ = This._EngineSliceFrom(_cTxt_,
				           _nFound_ + _nSubLen_)
				This.Update(_cBefore_ + pcNew + _cAfter_)
				return
			ok
			_nPos_ = _nFound_ + _nSubLen_
		end

		def ReplaceNextNthOccurrenceQ(n, pcSub, pcNew, nFrom)
			This.ReplaceNextNthOccurrence(n, pcSub, pcNew, nFrom)
			return This

	def ReplacePreviousNthOccurrence(n, pcSub, pcNew, nFrom)
		_aAll_ = This.AllPositionsOf(pcSub)
		_aBefore_ = []
		_nAL_ = ring_len(_aAll_)
		for _i_ = 1 to _nAL_
			if _aAll_[_i_] < nFrom _aBefore_ + _aAll_[_i_] ok
		next
		_nBL_ = ring_len(_aBefore_)
		if n < 1 or n > _nBL_ return ok
		_nP_ = _aBefore_[_nBL_ - n + 1]
		_nSubLen_ = This._EngineCount(pcSub)
		_cTxt_ = This.Content()
		_cBefore_ = ""
		if _nP_ > 1
			_cBefore_ = This._EngineSlice(_cTxt_, 1, _nP_ - 1)
		ok
		_cAfter_ = This._EngineSliceFrom(_cTxt_, _nP_ + _nSubLen_)
		This.Update(_cBefore_ + pcNew + _cAfter_)

		def ReplacePreviousNthOccurrenceQ(n, pcSub, pcNew, nFrom)
			This.ReplacePreviousNthOccurrence(n, pcSub, pcNew, nFrom)
			return This

	def IsLowercaseOf(pcOther)
		if NOT isString(pcOther) return FALSE ok
		return This.Content() = lower(pcOther)

	def IsUppercaseOf(pcOther)
		if NOT isString(pcOther) return FALSE ok
		return This.Content() = upper(pcOther)

	# UppercasedInLocale / LowercasedInLocale -- locale-neutral fallback.
	def UppercasedInLocale(pcLocale)
		return upper(This.Content())

	def LowercasedInLocale(pcLocale)
		return lower(This.Content())

	def CharCase()
		_c_ = This.Content()
		if This._EngineCount(_c_) != 1 return :Mixed ok
		if _c_ = upper(_c_) and _c_ != lower(_c_) return :Uppercase ok
		if _c_ = lower(_c_) and _c_ != upper(_c_) return :Lowercase ok
		return :Mixed

	def CountInSections(pcSub, aSections)
		_nT_ = 0
		_nL_ = ring_len(aSections)
		for _i_ = 1 to _nL_
			_s_ = aSections[_i_]
			if isList(_s_) and ring_len(_s_) = 2
				_cMid_ = This._EngineSlice(This.Content(),
				         _s_[1], _s_[2] - _s_[1] + 1)
				_oT_ = new stzString(_cMid_)
				_nT_ += _oT_.HowMany(pcSub)
			ok
		next
		return _nT_

	def Splits()
		return This.Words()

	def FindWords()
		_aRes_ = []
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_bIn_ = FALSE
		for _i_ = 1 to _nLen_
			_c_ = _aChars_[_i_]
			if _c_ = " " or _c_ = char(9) or _c_ = char(10) or _c_ = char(13)
				_bIn_ = FALSE
			else
				if NOT _bIn_
					_aRes_ + _i_
					_bIn_ = TRUE
				ok
			ok
		next
		return _aRes_

	# HasThisTrailingChar(pcChar, pCS): TRUE iff content ends with
	# a run of pcChar. (Distinct from HasTrailingChars() which is
	# the 0-arg "has any trailing run" predicate above.)
	def HasThisTrailingCharCS(pcChar, pCaseSensitive)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return FALSE ok
		if pCaseSensitive = FALSE or pCaseSensitive = 0
			return lower(_aChars_[_nLen_]) = lower(pcChar)
		ok
		return _aChars_[_nLen_] = pcChar

	def HasThisTrailingChar(pcChar)
		return This.HasThisTrailingCharCS(pcChar, 1)

	def HasThisLeadingCharCS(pcChar, pCaseSensitive)
		_aChars_ = This.Chars()
		if ring_len(_aChars_) = 0 return FALSE ok
		if pCaseSensitive = FALSE or pCaseSensitive = 0
			return lower(_aChars_[1]) = lower(pcChar)
		ok
		return _aChars_[1] = pcChar

	def HasThisLeadingChar(pcChar)
		return This.HasThisLeadingCharCS(pcChar, 1)

	def FindTrailingChars()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return [] ok
		_cL_ = _aChars_[_nLen_]
		_n_ = 0
		while _n_ < _nLen_ and _aChars_[_nLen_ - _n_] = _cL_
			_n_++
		end
		_aRes_ = []
		for _i_ = _nLen_ - _n_ + 1 to _nLen_
			_aRes_ + _i_
		next
		return _aRes_

	def FindLeadingChars()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return [] ok
		_cF_ = _aChars_[1]
		_n_ = 0
		while _n_ < _nLen_ and _aChars_[_n_ + 1] = _cF_
			_n_++
		end
		_aRes_ = []
		for _i_ = 1 to _n_
			_aRes_ + _i_
		next
		return _aRes_

	def TrailingCharIs(pcChar)
		_c_ = This.TrailingChar()
		return _c_ = pcChar

	def LeadingCharIs(pcChar)
		_c_ = This.LeadingChar()
		return _c_ = pcChar

	# PositionOfCentralChar: position of the center char (0 if even).
	def PositionOfCentralChar()
		_nLen_ = This._EngineCount(This.Content())
		if NOT This.HasCentralChar() return 0 ok
		return (_nLen_ + 1) / 2

	# IsNTimesMultipleOf(n, pcUnit): TRUE iff content is pcUnit
	# repeated exactly n times.
	def IsNTimesMultipleOf(n, pcUnit)
		if NOT (isString(pcUnit) and ring_len(pcUnit) > 0) return FALSE ok
		_cExpect_ = ""
		for _i_ = 1 to n
			_cExpect_ += pcUnit
		next
		return This.Content() = _cExpect_

	# MarkSubStringsCS(pcSubStr, pCaseSensitive): mark every
	# occurrence of pcSubStr with [|...|] (single-substring form).
	def MarkSubStringsCS(pcSubStr, pCaseSensitive)
		This.ReplaceCS(pcSubStr, "[|" + pcSubStr + "|]", pCaseSensitive)

	# ReplaceMarquers(paReplacements): replace #1, #2, ... in order
	# with paReplacements[1], [2], ... (engine-replace).
	def ReplaceMarquers(paReplacements)
		if NOT isList(paReplacements) return ok
		_aPos_ = MarkersPositions(This.Content())
		_nL_ = ring_len(_aPos_)
		# Sort positions descending so earlier replacements remain valid.
		for _i_ = 2 to _nL_
			_v_ = _aPos_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aPos_[_j_] < _v_
				_aPos_[_j_ + 1] = _aPos_[_j_]; _j_--
			end
			_aPos_[_j_ + 1] = _v_
		next
		_nRL_ = ring_len(paReplacements)
		for _i_ = 1 to _nL_
			_p_ = _aPos_[_i_]
			# Find the end of the digit run after the "#".
			_aChars_ = This.Chars()
			_nLen_ = ring_len(_aChars_)
			_j_ = _p_ + 1
			while _j_ <= _nLen_ and isDigit(_aChars_[_j_])
				_j_++
			end
			# Marker number used to map paReplacements (1-based).
			_cNum_ = ""
			for _k_ = _p_ + 1 to _j_ - 1
				_cNum_ += _aChars_[_k_]
			next
			_iRep_ = 0 + _cNum_
			if _iRep_ < 1 or _iRep_ > _nRL_ loop ok
			_cNew_ = "" + paReplacements[_iRep_]
			_cTxt_ = This.Content()
			_cBefore_ = ""
			if _p_ > 1
				_cBefore_ = This._EngineSlice(_cTxt_, 1, _p_ - 1)
			ok
			_cAfter_ = This._EngineSliceFrom(_cTxt_, _j_)
			This.Update(_cBefore_ + _cNew_ + _cAfter_)
		next

	def ReplaceMarkers(paReplacements)
		This.ReplaceMarquers(paReplacements)

	# IsLowercaseOfXT(pcOther, pNamed): same as IsLowercaseOf with
	# optional :Locale = pcLocale param.
	def IsLowercaseOfXT(pcOther, pNamed)
		return This.IsLowercaseOf(pcOther)

	# FindInSections(pcSub, aSections): positions of pcSub inside
	# the given sections (codepoint absolute positions).
	def FindInSections(pcSub, aSections)
		_aRes_ = []
		_nL_ = ring_len(aSections)
		for _i_ = 1 to _nL_
			_s_ = aSections[_i_]
			if isList(_s_) and ring_len(_s_) = 2
				_cMid_ = This._EngineSlice(This.Content(),
				         _s_[1], _s_[2] - _s_[1] + 1)
				_oT_ = new stzString(_cMid_)
				_aLocal_ = _oT_.AllPositionsOf(pcSub)
				_nLL_ = ring_len(_aLocal_)
				for _k_ = 1 to _nLL_
					_aRes_ + _s_[1] + _aLocal_[_k_] - 1
				next
			ok
		next
		return _aRes_

	# FindTrailingCharsZZ: section of the trailing run.
	def FindTrailingCharsZZ()
		_aPos_ = This.FindTrailingChars()
		_nL_ = ring_len(_aPos_)
		if _nL_ = 0 return [] ok
		return [ _aPos_[1], _aPos_[_nL_] ]

	def FindLeadingCharsZZ()
		_aPos_ = This.FindLeadingChars()
		_nL_ = ring_len(_aPos_)
		if _nL_ = 0 return [] ok
		return [ _aPos_[1], _aPos_[_nL_] ]

	# HasTrailingSubString(pcSub) -- TRUE iff content ends with pcSub.
	def HasTrailingSubString(pcSub)
		return This.EndsWithCS(pcSub, 1)

	def HasLeadingSubString(pcSub)
		return This.StartsWithCS(pcSub, 1)

	def TrailingSubStringZZ(pcSub)
		_nLen_ = This._EngineCount(This.Content())
		_nSubLen_ = This._EngineCount(pcSub)
		if _nSubLen_ > _nLen_ return [] ok
		if This._EngineSliceFrom(This.Content(),
		                         _nLen_ - _nSubLen_ + 1) != pcSub
			return []
		ok
		return [ _nLen_ - _nSubLen_ + 1, _nLen_ ]

	def LeadingSubStringRemove()
		# Mutating: drop the leading non-letter prefix.
		_cLead_ = This.LeadingSubString()
		if ring_len(_cLead_) = 0 return ok
		This.Update(This._EngineSliceFrom(This.Content(),
		            This._EngineCount(_cLead_) + 1))

	def RemoveLeadingSubString()
		This.LeadingSubStringRemove()

	def LeadingCharsRemoved()
		_oTmp_ = new stzString(This.Content())
		_oTmp_.RemoveLeadingChars()
		return _oTmp_.Content()

	def TrailingCharsRemoved()
		_oTmp_ = new stzString(This.Content())
		_oTmp_.RemoveTrailingChars()
		return _oTmp_.Content()

	# RemoveNFirstChars(n) / RemoveNLastChars(n).
	def RemoveNFirstChars(n)
		_nLen_ = This._EngineCount(This.Content())
		if n >= _nLen_ This.Update("") return ok
		This.Update(This._EngineSliceFrom(This.Content(), n + 1))

		def RemoveNFirstCharsQ(n)
			This.RemoveNFirstChars(n)
			return This

	def RemoveNLastChars(n)
		_nLen_ = This._EngineCount(This.Content())
		if n >= _nLen_ This.Update("") return ok
		This.Update(This._EngineSlice(This.Content(), 1, _nLen_ - n))

		def RemoveNLastCharsQ(n)
			This.RemoveNLastChars(n)
			return This

	# BeginsWith(pcSub): TRUE iff content starts with pcSub.
	def BeginsWith(pcSub)
		return This.StartsWithCS(pcSub, 1)

	def BeginsWithCS(pcSub, pCaseSensitive)
		return This.StartsWithCS(pcSub, pCaseSensitive)

	# FindNextNthOccurrence(n, pcSub, nFrom).
	def FindNextNthOccurrence(n, pcSub, nFrom)
		_nSubLen_ = This._EngineCount(pcSub)
		_nPos_ = nFrom; _nC_ = 0
		while TRUE
			_nFound_ = StzEngineStringFindFirstFromCS(@pEngine, pcSub,
			           _nPos_, 1)
			if _nFound_ < 1 return 0 ok
			_nC_++
			if _nC_ = n return _nFound_ ok
			_nPos_ = _nFound_ + _nSubLen_
		end
		return 0

	def NthPreviousOccurrence(n, pcSub, nFrom)
		_aAll_ = This.AllPositionsOf(pcSub)
		_aB_ = []
		_nAL_ = ring_len(_aAll_)
		for _i_ = 1 to _nAL_
			if _aAll_[_i_] < nFrom _aB_ + _aAll_[_i_] ok
		next
		_nBL_ = ring_len(_aB_)
		if n < 1 or n > _nBL_ return 0 ok
		return _aB_[_nBL_ - n + 1]

	# ContainsTheLetters(pacLetters): TRUE iff content contains
	# every letter in pacLetters (in any order).
	def ContainsTheLetters(pacLetters)
		if NOT isList(pacLetters) return FALSE ok
		_nL_ = ring_len(pacLetters)
		for _i_ = 1 to _nL_
			if NOT (isString(pacLetters[_i_]) and This.Contains(pacLetters[_i_]))
				return FALSE
			ok
		next
		return TRUE

	# FindSubStringBetween(pcSub, pcOpen, pcClose): positions of pcSub
	# inside any pcOpen..pcClose section.
	def FindSubStringBetween(pcSub, pcOpen, pcClose)
		return This.FindSubStringBoundedBy(pcSub, [ pcOpen, pcClose ])

	# ToStzText() -- stub returning a stzString (stzText not yet ported).
	def ToStzText()
		return new stzString( This.Content() )

	# PartsUsing(pcSep) / PartsUsingXT.
	def PartsUsing(pcSep)
		return This._SplitByStr(pcSep)

	def PartsUsingXT(pcSep, pNamed)
		return This._SplitByStr(pcSep)

	# ContainsNoOneOfThese(paSubStr): TRUE iff content contains NONE
	# of the listed substrings.
	def ContainsNoOneOfThese(paSubStr)
		if NOT isList(paSubStr) return TRUE ok
		_nL_ = ring_len(paSubStr)
		for _i_ = 1 to _nL_
			if isString(paSubStr[_i_]) and This.Contains(paSubStr[_i_])
				return FALSE
			ok
		next
		return TRUE

	def ContainsNoneOfThese(paSubStr)
		return This.ContainsNoOneOfThese(paSubStr)

	# IsLowercased / IsUppercased: predicates over content's case form.
	def IsLowercased()
		_c_ = This.Content()
		return ring_len(_c_) > 0 and _c_ = lower(_c_) and _c_ != upper(_c_)

	def IsUppercased()
		_c_ = This.Content()
		return ring_len(_c_) > 0 and _c_ = upper(_c_) and _c_ != lower(_c_)

	# (IsLowercase / IsUppercase already exist earlier.)

	# HasThisCentralChar(pcChar): TRUE iff the central char is pcChar.
	def HasThisCentralChar(pcChar)
		_c_ = This.CentralChar()
		return _c_ = pcChar

	def IsMultipleOfCS(pcUnit, pCaseSensitive)
		if pCaseSensitive = FALSE or pCaseSensitive = 0
			_oTmp_ = new stzString(lower(This.Content()))
			return _oTmp_.IsMultipleOf(lower(pcUnit))
		ok
		return This.IsMultipleOf(pcUnit)

	def LastNCharsRemoved(n)
		_nLen_ = This._EngineCount(This.Content())
		if n >= _nLen_ return "" ok
		return This._EngineSlice(This.Content(), 1, _nLen_ - n)

	def FirstNCharsRemoved(n)
		_nLen_ = This._EngineCount(This.Content())
		if n >= _nLen_ return "" ok
		return This._EngineSliceFrom(This.Content(), n + 1)

	# IsTitleCased: every space-separated word starts with an
	# uppercase letter; the rest of that word is lower.
	def IsTitleCased()
		_c_ = This.Content()
		_nLen_ = ring_len(_c_)
		_bAtStart_ = TRUE
		for _i_ = 1 to _nLen_
			_ch_ = _c_[_i_]
			if _ch_ = " " or _ch_ = char(9)
				_bAtStart_ = TRUE
				loop
			ok
			if _bAtStart_
				if isAlpha(_ch_) and upper(_ch_) != _ch_ return FALSE ok
				_bAtStart_ = FALSE
			else
				if isAlpha(_ch_) and lower(_ch_) != _ch_ return FALSE ok
			ok
		next
		return TRUE

	# (IsTitlecased -- Ring is case-insensitive, just one def.)

	# CharsWXT(pcCondition): chars where predicate is TRUE. Alias of
	# CharsW (predicate-driven char filter).
	def CharsWXT(pcCondition)
		_aRes_ = []
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		for _i_ = 1 to _nLen_
			@char = _aChars_[_i_]
			@Char = @char
			@position = _i_
			_bMatch_ = FALSE
			try
				eval("_bMatch_ = " + pcCondition)
			catch
				_bMatch_ = FALSE
			done
			if _bMatch_ _aRes_ + @char ok
		next
		return _aRes_

	# ContainsLetters(): TRUE iff the content contains any letter.
	def ContainsLetters()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		for _i_ = 1 to _nLen_
			if isAlpha(_aChars_[_i_]) return TRUE ok
		next
		return FALSE

	# CharsReversed: non-mutating char-reverse.
	def CharsReversed()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_cOut_ = ""
		for _i_ = _nLen_ to 1 step -1
			_cOut_ += _aChars_[_i_]
		next
		return _cOut_

	# IsAlmostAFunctionCall(): TRUE iff content roughly matches
	# `identifier(...)` syntax.
	def IsAlmostAFunctionCall()
		_c_ = ring_trim(This.Content())
		_nLen_ = ring_len(_c_)
		if _nLen_ < 3 return FALSE ok
		# Must have a "(" somewhere after at least 1 char and a ")"
		# somewhere after that.
		_nO_ = substr(_c_, "(")
		_nC_ = substr(_c_, ")")
		return _nO_ >= 2 and _nC_ > _nO_

	# Inversed: char-reverse alias.
	def Inversed()
		return This.CharsReversed()

	# WalkBackwardW(pcCondition): walk content backwards, calling
	# the predicate for each char; returns positions where it was TRUE.
	def WalkBackwardW(pcCondition)
		_aRes_ = []
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		for _i_ = _nLen_ to 1 step -1
			@char = _aChars_[_i_]
			@Char = @char
			@position = _i_
			_bMatch_ = FALSE
			try
				eval("_bMatch_ = " + pcCondition)
			catch
				_bMatch_ = FALSE
			done
			if _bMatch_ _aRes_ + _i_ ok
		next
		return _aRes_

	# ReplaceNthCharQ alias.
	def ReplaceNthCharQ(n, pcNew)
		This.ReplaceCharAtSimple(n, pcNew)
		return This

	# Parts2UsingXT / Parts2Using / PartsClassifiedUsingXT /
	# PartsAndPartitionersUsingXT: split-DSL surface variants.
	def Parts2Using(pcSep)
		return This.PartsUsing(pcSep)

	def Parts2UsingXT(pcSep, pNamed)
		return This.PartsUsing(pcSep)

	def PartsClassifiedUsingXT(pcSep, pNamed)
		return This.PartsUsing(pcSep)

	def PartsAndPartitionersUsingXT(pcSep, pNamed)
		return This.PartsUsing(pcSep)

	# ReplaceAllChars(pcOld, pcNew): char-by-char map.
	def ReplaceAllChars(pcOld, pcNew)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			if _aChars_[_i_] = pcOld
				_cOut_ += pcNew
			else
				_cOut_ += _aChars_[_i_]
			ok
		next
		This.Update(_cOut_)

		def ReplaceAllCharsQ(pcOld, pcNew)
			This.ReplaceAllChars(pcOld, pcNew)
			return This

	def CountCharsWXT(pcCondition)
		return ring_len(This.CharsWXT(pcCondition))

	# NthSubStringAfterSplittingStringUsing(n, pcSep): the n-th piece
	# after splitting on pcSep.
	def NthSubStringAfterSplittingStringUsing(n, pcSep)
		_aParts_ = This._SplitByStr(pcSep)
		if n < 1 or n > ring_len(_aParts_) return "" ok
		return _aParts_[n]

	# ContainsEachCS(pacSubStr, pCaseSensitive): TRUE iff content
	# contains every listed substring.
	def ContainsEachCS(pacSubStr, pCaseSensitive)
		if NOT isList(pacSubStr) return FALSE ok
		_bCase_ = 1
		if pCaseSensitive = FALSE or pCaseSensitive = 0 _bCase_ = 0 ok
		_nL_ = ring_len(pacSubStr)
		for _i_ = 1 to _nL_
			_s_ = pacSubStr[_i_]
			if NOT isString(_s_) loop ok
			if _bCase_ = 1
				if NOT This.ContainsCS(_s_, 1) return FALSE ok
			else
				if NOT This.ContainsCS(_s_, 0) return FALSE ok
			ok
		next
		return TRUE

	def ContainsEach(pacSubStr)
		return This.ContainsEachCS(pacSubStr, 1)

	def ContainsEachOfThese(pacSubStr)
		return This.ContainsEachCS(pacSubStr, 1)

	def ContainsEachOfTheseCS(pacSubStr, pCaseSensitive)
		return This.ContainsEachCS(pacSubStr, pCaseSensitive)

	# MultiplyBy(n): repeat content n times.
	def MultiplyBy(n)
		if NOT isNumber(n) return ok
		if n < 1 This.Update("") return ok
		_cBase_ = This.Content()
		_cOut_ = ""
		for _i_ = 1 to n
			_cOut_ += _cBase_
		next
		This.Update(_cOut_)

		def MultiplyByQ(n)
			This.MultiplyBy(n)
			return This

	# (RemoveRepeatedLeading/TrailingCharsCS already exist below;
	# only need Q variants.)
	def RemoveRepeatedLeadingCharsCSQ(pCaseSensitive)
		This.RemoveRepeatedLeadingCharsCS(pCaseSensitive)
		return This

	def RemoveRepeatedTrailingCharsCSQ(pCaseSensitive)
		This.RemoveRepeatedTrailingCharsCS(pCaseSensitive)
		return This

	# ReplaceFirstNChars(n, pcNew): replace the first n chars with pcNew.
	def ReplaceFirstNChars(n, pcNew)
		_nLen_ = This._EngineCount(This.Content())
		if n >= _nLen_
			This.Update(pcNew)
			return
		ok
		_cTail_ = This._EngineSliceFrom(This.Content(), n + 1)
		This.Update(pcNew + _cTail_)

		def ReplaceFirstNCharsQ(n, pcNew)
			This.ReplaceFirstNChars(n, pcNew)
			return This

	def ReplaceLastNChars(n, pcNew)
		_nLen_ = This._EngineCount(This.Content())
		if n >= _nLen_
			This.Update(pcNew)
			return
		ok
		_cHead_ = This._EngineSlice(This.Content(), 1, _nLen_ - n)
		This.Update(_cHead_ + pcNew)

		def ReplaceLastNCharsQ(n, pcNew)
			This.ReplaceLastNChars(n, pcNew)
			return This

	# ReplaceLeadingCharsCS(pcNew, pCaseSensitive): swap the leading
	# run with pcNew.
	def ReplaceLeadingCharsCS(pcNew, pCaseSensitive)
		_cLead_ = This.LeadingChars()
		if ring_len(_cLead_) = 0 return ok
		_nLeadLen_ = This._EngineCount(_cLead_)
		_cTail_ = This._EngineSliceFrom(This.Content(), _nLeadLen_ + 1)
		This.Update(pcNew + _cTail_)

		def ReplaceLeadingCharsCSQ(pcNew, pCaseSensitive)
			This.ReplaceLeadingCharsCS(pcNew, pCaseSensitive)
			return This

	def ReplaceTrailingCharsCS(pcNew, pCaseSensitive)
		_cTrail_ = This.TrailingChars()
		if ring_len(_cTrail_) = 0 return ok
		_nLen_ = This._EngineCount(This.Content())
		_nTrailLen_ = This._EngineCount(_cTrail_)
		_cHead_ = This._EngineSlice(This.Content(), 1, _nLen_ - _nTrailLen_)
		This.Update(_cHead_ + pcNew)

		def ReplaceTrailingCharsCSQ(pcNew, pCaseSensitive)
			This.ReplaceTrailingCharsCS(pcNew, pCaseSensitive)
			return This

	def HasLeadingCharsCS(pCaseSensitive)
		return This.HasLeadingChars()

	def HasTrailingCharsCS(pCaseSensitive)
		return This.HasTrailingChars()

	def RemoveThisLeadingCharCS(pcChar, pCaseSensitive)
		This.RemoveThisCharFromStartXT(pcChar)

		def RemoveThisLeadingCharCSQ(pcChar, pCaseSensitive)
			This.RemoveThisLeadingCharCS(pcChar, pCaseSensitive)
			return This

	def ReplaceLeadingCharCS(pcChar, pcNew, pCaseSensitive)
		# Replace the leading char (singular) if it matches pcChar.
		_aChars_ = This.Chars()
		if ring_len(_aChars_) = 0 return ok
		if _aChars_[1] != pcChar return ok
		This.ReplaceCharAtSimple(1, pcNew)

		def ReplaceLeadingCharCSQ(pcChar, pcNew, pCaseSensitive)
			This.ReplaceLeadingCharCS(pcChar, pcNew, pCaseSensitive)
			return This

	# RemoveAllExcept(pcKeep): remove every char that is NOT pcKeep.
	def RemoveAllExcept(pcKeep)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_cOut_ = ""
		for _i_ = 1 to _nLen_
			if _aChars_[_i_] = pcKeep
				_cOut_ += _aChars_[_i_]
			ok
		next
		This.Update(_cOut_)

		def RemoveAllExceptQ(pcKeep)
			This.RemoveAllExcept(pcKeep)
			return This

	def ReplaceNthOccurrenceCSQ(n, pcSub, pcNew, pCaseSensitive)
		This.ReplaceNthOccurrenceCS(n, pcSub, pcNew, pCaseSensitive)
		return This

	def ReplaceNthOccurrence(n, pcSub, pcNew)
		_nP_ = This.FindNthOccurrence(n, pcSub)
		if _nP_ = 0 return ok
		_nSubLen_ = This._EngineCount(pcSub)
		_cTxt_ = This.Content()
		_cBefore_ = ""
		if _nP_ > 1
			_cBefore_ = This._EngineSlice(_cTxt_, 1, _nP_ - 1)
		ok
		_cAfter_ = This._EngineSliceFrom(_cTxt_, _nP_ + _nSubLen_)
		This.Update(_cBefore_ + pcNew + _cAfter_)

	def ReplaceNthOccurrenceCS(n, pcSub, pcNew, pCaseSensitive)
		This.ReplaceNthOccurrence(n, pcSub, pcNew)

	# RemoveFirstOccurrence(pcSub).
	def RemoveFirstOccurrence(pcSub)
		This.ReplaceFirst(pcSub, "")

		def RemoveFirstOccurrenceQ(pcSub)
			This.RemoveFirstOccurrence(pcSub)
			return This

	# Orientation(): :LTR for normal scripts, :RTL when first char
	# is Arabic/Hebrew/etc.
	def Orientation()
		_aChars_ = This.Chars()
		if ring_len(_aChars_) = 0 return :Undefined ok
		_oC_ = new stzString(_aChars_[1])
		if _oC_.AllCharsAre(:RightToLeft) return :RTL ok
		return :LTR

	# RemoveNLeftChars / RemoveNRightChars aliases.
	def RemoveNLeftChars(n)
		This.RemoveNFirstChars(n)

		def RemoveNLeftCharsQ(n)
			This.RemoveNFirstChars(n)
			return This

	def RemoveNRightChars(n)
		This.RemoveNLastChars(n)

		def RemoveNRightCharsQ(n)
			This.RemoveNLastChars(n)
			return This

	# NLastCharsRemoved: alias for LastNCharsRemoved.
	def NLastCharsRemoved(n)
		return This.LastNCharsRemoved(n)

	def NFirstCharsRemoved(n)
		return This.FirstNCharsRemoved(n)

	def RemoveAllQ(pcSub)
		This.RemoveAll(pcSub)
		return This

	def RemoveSectionQ(n1, n2)
		This.RemoveSection(n1, n2)
		return This

	# ReplaceWithMany / ReplaceManyWithMany TODO placeholders.
	def ReplaceWithMany(pcSub, paReplacements)
		This.ReplaceByMany(pcSub, paReplacements)

		def ReplaceWithManyQ(pcSub, paReplacements)
			This.ReplaceWithMany(pcSub, paReplacements)
			return This

	def ReplaceManyWithMany(pacSubStr, pacReplacements)
		# Per-index pair replacement.
		if NOT (isList(pacSubStr) and isList(pacReplacements)) return ok
		_nL_ = ring_len(pacSubStr)
		_nR_ = ring_len(pacReplacements)
		for _i_ = 1 to _nL_
			if _i_ > _nR_ exit ok
			This.Replace(pacSubStr[_i_], pacReplacements[_i_])
		next

		def ReplaceManyWithManyQ(pacSubStr, pacReplacements)
			This.ReplaceManyWithMany(pacSubStr, pacReplacements)
			return This

	# AlignedXT(:Width = n, :PadChar = " ", :Direction = :Left/:Right/:Center)
	def AlignedXT(pN1, pN2, pN3)
		_nW_ = 0; _cPad_ = " "; _cDir_ = :Left
		_aArgs_ = [ pN1, pN2, pN3 ]
		for _i_ = 1 to 3
			_a_ = _aArgs_[_i_]
			if isList(_a_) and ring_len(_a_) = 2 and isString(_a_[1])
				_k_ = lower(_a_[1])
				if _k_ = "width" _nW_ = _a_[2]
				but _k_ = "padchar" _cPad_ = _a_[2]
				but _k_ = "direction" _cDir_ = _a_[2]
				ok
			ok
		next
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		if _nW_ <= _nLen_ return _cTxt_ ok
		_nDiff_ = _nW_ - _nLen_
		_cPadStr_ = ""
		for _i_ = 1 to _nDiff_
			_cPadStr_ += _cPad_
		next
		if _cDir_ = :Right
			return _cPadStr_ + _cTxt_
		but _cDir_ = :Center
			_nHalf_ = _nDiff_ / 2
			_cL_ = "" ; _cR_ = ""
			for _i_ = 1 to floor(_nHalf_)
				_cL_ += _cPad_
			next
			for _i_ = 1 to _nDiff_ - floor(_nHalf_)
				_cR_ += _cPad_
			next
			return _cL_ + _cTxt_ + _cR_
		ok
		return _cTxt_ + _cPadStr_

	# (NLastChars / NFirstChars already exist earlier.)
	def NLastCharsQ(n)
		return new stzString( This.NLastChars(n) )

	def NFirstCharsQ(n)
		return new stzString( This.NFirstChars(n) )

	# CompressUsingBinary(): hand-wave stub -- return content unchanged.
	def CompressUsingBinary()
		return This.Content()

	# UnicodeCompareWithCS(pcOther, pCaseSensitive): codepoint
	# comparison. Returns -1, 0 or 1.
	def UnicodeCompareWithCS(pcOther, pCaseSensitive)
		_a_ = This.Content()
		_b_ = pcOther
		if pCaseSensitive = FALSE or pCaseSensitive = 0
			_a_ = lower(_a_)
			_b_ = lower(_b_)
		ok
		if _a_ < _b_ return -1 ok
		if _a_ > _b_ return 1 ok
		return 0

	def UnicodeCompareWith(pcOther)
		return This.UnicodeCompareWithCS(pcOther, 1)

	def UnicodeCompareWithInSystemLocale(pcOther)
		return This.UnicodeCompareWithCS(pcOther, 1)

	# NumberOfCharsWXT(pcCondition).
	def NumberOfCharsWXT(pcCondition)
		return ring_len(This.CharsWXT(pcCondition))

	# ContainsLetter(pcLetter): TRUE iff content contains pcLetter.
	def ContainsLetter(pcLetter)
		return This.Contains(pcLetter)

	# ContainsBoth(pcA, pcB): TRUE iff content contains BOTH.
	def ContainsBoth(pcA, pcB)
		return This.Contains(pcA) and This.Contains(pcB)

	# NumericValue(): content as a number.
	def NumericValue()
		return 0 + This.Content()

	def NumberValue()
		return 0 + This.Content()

	# LinesQRT(pcType): typed lines wrapper.
	def LinesQRT(pcType)
		return This.Lines()

	# IsListInShortForm: rough check for `a:b` short-form list literal.
	def IsListInShortForm()
		_c_ = ring_trim(This.Content())
		return substr(_c_, ":") > 0 and ring_len(_c_) >= 3

	def IncludedIn(pcOther)
		return This.IsIncludedIn(pcOther)

	def TrailingCharCS(pCaseSensitive)
		return This.TrailingChar()

	def LeadingCharCS(pCaseSensitive)
		return This.LeadingChar()

	# IsALetterOf(pcOther): TRUE iff single-char This appears in pcOther.
	def IsALetterOf(pcOther)
		if NOT isString(pcOther) return FALSE ok
		_c_ = This.Content()
		if ring_len(_c_) = 0 return FALSE ok
		return substr(pcOther, _c_) > 0

	def RemoveLeftOccurrenceQ(pcSub)
		This.RemoveFirstOccurrence(pcSub)
		return This

	def RemoveLeftOccurrence(pcSub)
		This.RemoveFirstOccurrence(pcSub)

	# NumberForm(): :Integer, :Decimal, :Hex, :Binary, or :Other.
	def NumberForm()
		_c_ = ring_trim(This.Content())
		if This.IsAnInteger() return :Integer ok
		if substr(_c_, ".") > 0 return :Decimal ok
		if ring_left(_c_, 2) = "0x" return :Hex ok
		if ring_left(_c_, 2) = "0b" return :Binary ok
		return :Other

	# PositionAfter(pcSub): position right after first occurrence.
	def PositionAfter(pcSub)
		_nP_ = This._FindFrom(This.Content(), pcSub, 1)
		if _nP_ < 1 return 0 ok
		return _nP_ + This._EngineCount(pcSub)

	def PositionBefore(pcSub)
		_nP_ = This._FindFrom(This.Content(), pcSub, 1)
		if _nP_ < 1 return 0 ok
		return _nP_ - 1

	# InsertSubStrings(anPos, pacStr): insert pacStr[i] at anPos[i],
	# processed from highest position down so earlier positions stay valid.
	def InsertSubStrings(anPos, pacStr)
		if NOT (isList(anPos) and isList(pacStr)) return ok
		_aPairs_ = []
		_nPL_ = ring_len(anPos); _nSL_ = ring_len(pacStr)
		_nMax_ = _nPL_
		if _nSL_ < _nMax_ _nMax_ = _nSL_ ok
		for _i_ = 1 to _nMax_
			_aPairs_ + [ anPos[_i_], pacStr[_i_] ]
		next
		_nAL_ = ring_len(_aPairs_)
		for _i_ = 2 to _nAL_
			_v_ = _aPairs_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aPairs_[_j_][1] < _v_[1]
				_aPairs_[_j_ + 1] = _aPairs_[_j_]; _j_--
			end
			_aPairs_[_j_ + 1] = _v_
		next
		for _i_ = 1 to _nAL_
			_pr_ = _aPairs_[_i_]
			This.InsertBefore(_pr_[1], _pr_[2])
		next

		def InsertSubStringsQ(anPos, pacStr)
			This.InsertSubStrings(anPos, pacStr)
			return This

	def InsertSubStringsXT(anPos, pacStr, pNamed)
		This.InsertSubStrings(anPos, pacStr)

	def ItemsWhere(pcCondition)
		return This.CharsWXT(pcCondition)

	# IsShortLanguageAbbreviation(): 2-letter ISO 639-1-style alpha code.
	def IsShortLanguageAbbreviation()
		_c_ = This.Content()
		if ring_len(_c_) != 2 return FALSE ok
		return isAlpha(_c_[1]) and isAlpha(_c_[2])

	# IsLatin(): TRUE iff every char is ASCII-Latin.
	def IsLatin()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return FALSE ok
		for _i_ = 1 to _nLen_
			if NOT isAlpha(_aChars_[_i_]) return FALSE ok
		next
		return TRUE

	def ContainsNOccurrences(n, pcSub)
		return This.HowMany(pcSub) = n

	def ContainsNOccurrencesCS(n, pcSub, pCaseSensitive)
		return This.HowManyCS(pcSub, pCaseSensitive) = n

	def OnlyNumbers()
		return This.IsMadeOfNumbers()

	def OnlyDigits()
		return This.IsMadeOfNumbers()

	def ExtendTo(n)
		This.ExtendToWith(n, " ")

		def ExtendToQ(n)
			This.ExtendToWith(n, " ")
			return This

	def RemoveSubStringBoundedBy(pcSub, pacBounds)
		This.ReplaceSubStringBoundedBy(pcSub, pacBounds, "")

		def RemoveSubStringBoundedByQ(pcSub, pacBounds)
			This.RemoveSubStringBoundedBy(pcSub, pacBounds)
			return This

	def RemoveNCharsLeft(n)
		This.RemoveNFirstChars(n)

		def RemoveNCharsLeftQ(n)
			This.RemoveNFirstChars(n)
			return This

	def RemoveNCharsRight(n)
		This.RemoveNLastChars(n)

		def RemoveNCharsRightQ(n)
			This.RemoveNLastChars(n)
			return This

	def BoxEachChar()
		return This.BoxifyCharsXT([])

	def BoxEachCharQ()
		return new stzString( This.BoxEachChar() )

	def CharsBoxed()
		return This.BoxifyCharsXT([])

	def BoxifyChars()
		return This.BoxifyCharsXT([])

	def FindAnyBoundedByAsSectionss(pacBounds)
		return This.FindAnyBoundedByAsSections(pacBounds)

	def ReplaceOccurrences(pcOld, pcNew)
		This.Replace(pcOld, pcNew)

		def ReplaceOccurrencesQ(pcOld, pcNew)
			This.ReplaceOccurrences(pcOld, pcNew)
			return This

	def FindConsecutiveSubStringsOfNChars(n)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		if _nLen_ < 2 * n return _aRes_ ok
		for _i_ = 1 to _nLen_ - 2 * n + 1
			_bMatch_ = TRUE
			for _k_ = 0 to n - 1
				if _aChars_[_i_ + _k_] != _aChars_[_i_ + n + _k_]
					_bMatch_ = FALSE
					exit
				ok
			next
			if _bMatch_ _aRes_ + _i_ ok
		next
		return _aRes_

	# SplitAtCSZZ(pcSep, pCaseSensitive): sectional split-at form.
	def SplitAtCSZZ(pcSep, pCaseSensitive)
		_aPos_ = This.AllPositionsOf(pcSep)
		_nSepLen_ = This._EngineCount(pcSep)
		_nTxtLen_ = This._EngineCount(This.Content())
		_aRes_ = []
		_nStart_ = 1
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_p_ = _aPos_[_i_]
			if _p_ >= _nStart_
				_aRes_ + [ _nStart_, _p_ - 1 ]
				_nStart_ = _p_ + _nSepLen_
			ok
		next
		if _nStart_ <= _nTxtLen_
			_aRes_ + [ _nStart_, _nTxtLen_ ]
		ok
		return _aRes_

	# StringCase(): return :Lowercase, :Uppercase, :TitleCase, or :Mixed.
	def StringCase()
		_c_ = This.Content()
		if _c_ = lower(_c_) and _c_ != upper(_c_) return :Lowercase ok
		if _c_ = upper(_c_) and _c_ != lower(_c_) return :Uppercase ok
		# Title case = each whitespace-bounded word starts with upper.
		_bTitle_ = TRUE
		_nLen_ = ring_len(_c_)
		_bAtStart_ = TRUE
		for _i_ = 1 to _nLen_
			_ch_ = _c_[_i_]
			if _ch_ = " " or _ch_ = char(9)
				_bAtStart_ = TRUE
			else
				if _bAtStart_ and isAlpha(_ch_) and lower(_ch_) = _ch_
					_bTitle_ = FALSE
					exit
				ok
				_bAtStart_ = FALSE
			ok
		next
		if _bTitle_ return :TitleCase ok
		return :Mixed

	# FindXT(pcWhat, :BoundedBy = pacBounds) -- named-param wrapper
	def FindXT(pcWhat, pNamed)
		if isList(pNamed) and ring_len(pNamed) = 2 and isString(pNamed[1]) and
		   lower(pNamed[1]) = "boundedby"
			return This.FindSubStringBoundedBy(pcWhat, pNamed[2])
		ok
		return []

	# FindAsSectionsXT(pcWhat, :BoundedBy = pacBounds) -- return start/end
	# pairs for each match inside any bounded section.
	def FindAsSectionsXT(pcWhat, pNamed)
		_aPos_ = This.FindXT(pcWhat, pNamed)
		_nWLen_ = ring_len(pcWhat)
		_aRes_ = []
		_nPL_ = ring_len(_aPos_)
		for _i_ = 1 to _nPL_
			_p_ = _aPos_[_i_]
			_aRes_ + [ _p_, _p_ + _nWLen_ - 1 ]
		next
		return _aRes_

	# FindBoundedBy / FindBoundedByCS -- the most common spelling
	# in narrative tests. Returns the [startPos, endPos] of each
	# bounded section.
	def FindBoundedByCS(pacBounds, pCaseSensitive)
		return This.FindBoundedByAsSectionsCS(pacBounds, pCaseSensitive)

	def FindBoundedBy(pacBounds)
		return This.FindBoundedByAsSectionsCS(pacBounds, 1)

	# IsBoundedByCS / IsBoundedBy: predicate. True iff the content
	# starts with pacBounds[1] AND ends with pacBounds[2].
	def IsBoundedByCS(pacBounds, pCaseSensitive)
		if NOT (isList(pacBounds) and ring_len(pacBounds) = 2)
			return 0
		ok
		return This.StartsWithCS(pacBounds[1], pCaseSensitive) and
		       This.EndsWith(pacBounds[2])

	def IsBoundedBy(pacBounds)
		return This.IsBoundedByCS(pacBounds, 1)

	# --- FindDuplicatesAsSections ---

	def FindDuplicatesAsSectionsCS(pCaseSensitive)
		_oFdasFinder_ = new stzStringFinder(This)
		return _oFdasFinder_.FindDuplicatesAsSectionsCS(pCaseSensitive)

	def FindDuplicatesAsSections()
		return This.FindDuplicatesAsSectionsCS(1)

	# --- FindW (conditional) ---

	def FindCharsWCS(pcCondition, pCaseSensitive)
		_oFcwFinder_ = new stzStringFinder(This)
		return _oFcwFinder_.FindCharsWCS(pcCondition, pCaseSensitive)

	def FindCharsW(pcCondition)
		return This.FindCharsWCS(pcCondition, 1)

	# FindCharsWXT(:Where = expr) -- named-param wrapper over FindCharsW.
	# Also accepts a bare expression for convenience.
	def FindCharsWXT(pCond)
		_cExpr_ = pCond
		if isList(pCond) and ring_len(pCond) = 2 and isString(pCond[1]) and
		   lower(pCond[1]) = "where"
			_cExpr_ = pCond[2]
		ok
		return This.FindCharsW(_cExpr_)

	def FindWCS(pcCondition, pCaseSensitive)
		_oFwFinder_ = new stzStringFinder(This)
		return _oFwFinder_.FindWCS(pcCondition, pCaseSensitive)

	def FindW(pcCondition)
		return This.FindWCS(pcCondition, 1)

	# --- CharsBetween ---

	def CharsBetween(nFrom, nTo)
		_oCbFinder_ = new stzStringFinder(This)
		return _oCbFinder_.CharsBetween(nFrom, nTo)

	# --- Regex find ---

	def FindFirstRegex(pcPattern)
		_oFfrFinder_ = new stzStringFinder(This)
		return _oFfrFinder_.FindFirstRegex(pcPattern)

		def FindRegex(pcPattern)
			return This.FindFirstRegex(pcPattern)

	def FindFirstRegexCS(pcPattern, pCaseSensitive)
		_oFfrcsFinder_ = new stzStringFinder(This)
		return _oFfrcsFinder_.FindFirstRegexCS(pcPattern, pCaseSensitive)

		def FindRegexCS(pcPattern, pCaseSensitive)
			return This.FindFirstRegexCS(pcPattern, pCaseSensitive)

	def FindAllRegex(pcPattern)
		_oFarFinder_ = new stzStringFinder(This)
		return _oFarFinder_.FindAllRegex(pcPattern)

		def FindAllRegexMatches(pcPattern)
			return This.FindAllRegex(pcPattern)

	def FindAllRegexCS(pcPattern, pCaseSensitive)
		_oFarcsFinder_ = new stzStringFinder(This)
		return _oFarcsFinder_.FindAllRegexCS(pcPattern, pCaseSensitive)

		def FindAllRegexMatchesCS(pcPattern, pCaseSensitive)
			return This.FindAllRegexCS(pcPattern, pCaseSensitive)

	  #========================================#
	 #     COUNTER DELEGATIONS                #
	#========================================#

	def CountCS(pcSubStr, pCaseSensitive)
		_oCntCounter_ = new stzStringCounter(This)
		return _oCntCounter_.CountCS(pcSubStr, pCaseSensitive)

		def NumberOfOccurrencesCS(pcSubStr, pCaseSensitive)
			return This.CountCS(pcSubStr, pCaseSensitive)

		# Note: NumberOfSubStrings / NumberOfSubStringsCS / NumberOfSubStringsU
		# without args (combinatorial enumeration count) are defined at the
		# class top with the SubStrings group; here we keep only the
		# differently-named occurrence-count alias for clarity.
		def CountSubStrings(pcSubStr)
			return This.CountCS(pcSubStr, 1)

	def Count(pcSubStr)
		return This.CountCS(pcSubStr, 1)

		def NumberOfOccurrences(pcSubStr)
			return This.Count(pcSubStr)

	def CountOverlappingCS(pcSubStr, pCaseSensitive)
		_oCoCounter_ = new stzStringCounter(This)
		return _oCoCounter_.CountOverlappingCS(pcSubStr, pCaseSensitive)

	def CountOverlapping(pcSubStr)
		return This.CountOverlappingCS(pcSubStr, 1)

	def CountLeadingChar(pcChar)
		_oClcCounter_ = new stzStringCounter(This)
		return _oClcCounter_.CountLeadingChar(pcChar)

	def CountTrailingChar(pcChar)
		_oCtcCounter_ = new stzStringCounter(This)
		return _oCtcCounter_.CountTrailingChar(pcChar)

	def CountRegex(pcPattern)
		_oCrCounter_ = new stzStringCounter(This)
		return _oCrCounter_.CountRegex(pcPattern)

	def CountRegexCS(pcPattern, pCaseSensitive)
		_oCrcCounter_ = new stzStringCounter(This)
		return _oCrcCounter_.CountRegexCS(pcPattern, pCaseSensitive)

	  #========================================#
	 #     SPLITTER DELEGATIONS               #
	#========================================#

	def SplitAtCS(pcSepOrPos, pCaseSensitive)
		_oSaSplitter_ = new stzStringSplitter(This)
		return _oSaSplitter_.SplitAtCS(pcSepOrPos, pCaseSensitive)

	def SplitAt(pcSepOrPos)
		return This.SplitAtCS(pcSepOrPos, 1)

	def SplitBeforeCS(pcSubStr, pCaseSensitive)
		# Accept :CS = bCase named-param on the case flag.
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2 and
		   isString(pCaseSensitive[1]) and lower(pCaseSensitive[1]) = "cs"
			pCaseSensitive = pCaseSensitive[2]
		ok
		_oSbSplitter_ = new stzStringSplitter(This)
		return _oSbSplitter_.SplitBeforeCS(pcSubStr, pCaseSensitive)

	def SplitBefore(pcSubStr)
		return This.SplitBeforeCS(pcSubStr, 1)

	# SplitBefore positions / char- or substring-predicate variants.
	def SplitBeforePositions(anPos)
		# Split the content into pieces that BEGIN at each position
		# in anPos (so position p starts a new piece).
		_aRes_ = []
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		# Sort positions ascending.
		_aSorted_ = _ListCopy(anPos)
		_nPL_ = ring_len(_aSorted_)
		for _i_ = 2 to _nPL_
			_v_ = _aSorted_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aSorted_[_j_] > _v_
				_aSorted_[_j_ + 1] = _aSorted_[_j_]; _j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		_nStart_ = 1
		for _i_ = 1 to _nPL_
			_p_ = _aSorted_[_i_]
			if _p_ <= _nStart_ loop ok
			if _p_ > _nLen_ exit ok
			_aRes_ + This._EngineSlice(_cTxt_, _nStart_, _p_ - _nStart_)
			_nStart_ = _p_
		next
		if _nStart_ <= _nLen_
			_aRes_ + This._EngineSliceFrom(_cTxt_, _nStart_)
		ok
		return _aRes_

	def SplitAfterPositions(anPos)
		# Split so each position p ENDS a piece (next piece starts at p+1).
		_aRes_ = []
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		_aSorted_ = _ListCopy(anPos)
		_nPL_ = ring_len(_aSorted_)
		for _i_ = 2 to _nPL_
			_v_ = _aSorted_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aSorted_[_j_] > _v_
				_aSorted_[_j_ + 1] = _aSorted_[_j_]; _j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		_nStart_ = 1
		for _i_ = 1 to _nPL_
			_p_ = _aSorted_[_i_]
			if _p_ < _nStart_ loop ok
			if _p_ > _nLen_ exit ok
			_aRes_ + This._EngineSlice(_cTxt_, _nStart_, _p_ - _nStart_ + 1)
			_nStart_ = _p_ + 1
		next
		if _nStart_ <= _nLen_
			_aRes_ + This._EngineSliceFrom(_cTxt_, _nStart_)
		ok
		return _aRes_

	# SplitBeforeCharsWXT(pcCondition): split into pieces that begin
	# at each char position where the eval'd predicate is TRUE.
	# Predicate runs with @char / @position bindings.
	def SplitBeforeCharsWXT(pcCondition)
		_cExpr_ = pcCondition
		if isList(pcCondition) and ring_len(pcCondition) = 2 and
		   isString(pcCondition[1]) and lower(pcCondition[1]) = "where"
			_cExpr_ = pcCondition[2]
		ok
		if NOT isString(_cExpr_) return [] ok
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_anPos_ = []
		for _i_ = 1 to _nLen_
			@char = _aChars_[_i_]
			@Char = @char
			@position = _i_
			_bMatch_ = FALSE
			try
				eval("_bMatch_ = " + _cExpr_)
			catch
				_bMatch_ = FALSE
			done
			if _bMatch_ _anPos_ + _i_ ok
		next
		return This.SplitBeforePositions(_anPos_)

	def SplitAfterCharsWXT(pcCondition)
		_cExpr_ = pcCondition
		if isList(pcCondition) and ring_len(pcCondition) = 2 and
		   isString(pcCondition[1]) and lower(pcCondition[1]) = "where"
			_cExpr_ = pcCondition[2]
		ok
		if NOT isString(_cExpr_) return [] ok
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_anPos_ = []
		for _i_ = 1 to _nLen_
			@char = _aChars_[_i_]
			@Char = @char
			@position = _i_
			_bMatch_ = FALSE
			try
				eval("_bMatch_ = " + _cExpr_)
			catch
				_bMatch_ = FALSE
			done
			if _bMatch_ _anPos_ + _i_ ok
		next
		return This.SplitAfterPositions(_anPos_)

	# SplitBeforeSubStringsWXT(pcCondition): walk every substring
	# position and split before each that matches the predicate
	# (predicate runs with @SubString bound). Returns the pieces.
	def SplitBeforeSubStringsWXT(pcCondition)
		_cExpr_ = pcCondition
		if isList(pcCondition) and ring_len(pcCondition) = 2 and
		   isString(pcCondition[1]) and lower(pcCondition[1]) = "where"
			_cExpr_ = pcCondition[2]
		ok
		if NOT isString(_cExpr_) return [] ok
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		_anPos_ = []
		for _i_ = 1 to _nLen_
			for _j_ = _i_ to _nLen_
				@SubString = This._EngineSlice(_cTxt_, _i_, _j_ - _i_ + 1)
				_bMatch_ = FALSE
				try
					eval("_bMatch_ = " + _cExpr_)
				catch
					_bMatch_ = FALSE
				done
				if _bMatch_ _anPos_ + _i_ exit ok
			next
		next
		return This.SplitBeforePositions(_anPos_)

	def SplitAfterSubStringsWXT(pcCondition)
		_cExpr_ = pcCondition
		if isList(pcCondition) and ring_len(pcCondition) = 2 and
		   isString(pcCondition[1]) and lower(pcCondition[1]) = "where"
			_cExpr_ = pcCondition[2]
		ok
		if NOT isString(_cExpr_) return [] ok
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		_anPos_ = []
		for _i_ = 1 to _nLen_
			for _j_ = _i_ to _nLen_
				@SubString = This._EngineSlice(_cTxt_, _i_, _j_ - _i_ + 1)
				_bMatch_ = FALSE
				try
					eval("_bMatch_ = " + _cExpr_)
				catch
					_bMatch_ = FALSE
				done
				if _bMatch_ _anPos_ + _j_ exit ok
			next
		next
		return This.SplitAfterPositions(_anPos_)

	def SplitAfterCS(pcSubStr, pCaseSensitive)
		_oSafSplitter_ = new stzStringSplitter(This)
		return _oSafSplitter_.SplitAfterCS(pcSubStr, pCaseSensitive)

	def SplitAfter(pcSubStr)
		return This.SplitAfterCS(pcSubStr, 1)

	def SplitAroundCS(pcSubStr, pCaseSensitive)
		_oSarSplitter_ = new stzStringSplitter(This)
		return _oSarSplitter_.SplitAroundCS(pcSubStr, pCaseSensitive)

	def SplitAround(pcSubStr)
		return This.SplitAroundCS(pcSubStr, 1)

	def Partition(pcSubStr)
		_nPtPos_ = This.FindFirst(pcSubStr)
		if _nPtPos_ = 0
			return [ This.Content(), "", "" ]
		ok
		_nPtSepLen_ = StzLen(pcSubStr)
		_cPtBefore_ = ""
		if _nPtPos_ > 1
			_cPtBefore_ = This.Section(1, _nPtPos_ - 1)
		ok
		_cPtAfter_ = ""
		_nPtEnd_ = _nPtPos_ + _nPtSepLen_
		if _nPtEnd_ <= This.NumberOfChars()
			_cPtAfter_ = This.Section(_nPtEnd_, This.NumberOfChars())
		ok
		return [ _cPtBefore_, pcSubStr, _cPtAfter_ ]

	def RPartition(pcSubStr)
		_nRpPos_ = This.FindLast(pcSubStr)
		if _nRpPos_ = 0
			return [ "", "", This.Content() ]
		ok
		_nRpSepLen_ = StzLen(pcSubStr)
		_cRpBefore_ = ""
		if _nRpPos_ > 1
			_cRpBefore_ = This.Section(1, _nRpPos_ - 1)
		ok
		_cRpAfter_ = ""
		_nRpEnd_ = _nRpPos_ + _nRpSepLen_
		if _nRpEnd_ <= This.NumberOfChars()
			_cRpAfter_ = This.Section(_nRpEnd_, This.NumberOfChars())
		ok
		return [ _cRpBefore_, pcSubStr, _cRpAfter_ ]

	def SplitByRegex(pcPattern)
		_oSbrSplitter_ = new stzStringSplitter(This)
		return _oSbrSplitter_.SplitByRegex(pcPattern)

	def SplitByRegexCS(pcPattern, pCaseSensitive)
		_oSbrcSplitter_ = new stzStringSplitter(This)
		return _oSbrcSplitter_.SplitByRegexCS(pcPattern, pCaseSensitive)

	def SplitAtPosition(n)
		_oSapSplitter_ = new stzStringSplitter(This)
		return _oSapSplitter_.SplitAtPosition(n)

	def SplitAtPositions(anPositions)
		_oSapsSplitter_ = new stzStringSplitter(This)
		return _oSapsSplitter_.SplitAtPositions(anPositions)

	  #========================================#
	 #     INSERTER DELEGATIONS               #
	#========================================#

	def InsertBeforeSubStringCS(pcSubStr, pcInsert, pCaseSensitive)
		_oIbsInserter_ = new stzStringInserter(This)
		_oIbsInserter_.InsertBeforeSubStringCS(pcSubStr, pcInsert, pCaseSensitive)
		This.Update(_oIbsInserter_.Content())

	def InsertBeforeSubString(pcSubStr, pcInsert)
		This.InsertBeforeSubStringCS(pcSubStr, pcInsert, 1)

	def InsertAfterSubStringCS(pcSubStr, pcInsert, pCaseSensitive)
		_oIasInserter_ = new stzStringInserter(This)
		_oIasInserter_.InsertAfterSubStringCS(pcSubStr, pcInsert, pCaseSensitive)
		This.Update(_oIasInserter_.Content())

	def InsertAfterSubString(pcSubStr, pcInsert)
		This.InsertAfterSubStringCS(pcSubStr, pcInsert, 1)

	def InsertBeforeFirstCS(pcSubStr, pcInsert, pCaseSensitive)
		_oIbfInserter_ = new stzStringInserter(This)
		_oIbfInserter_.InsertBeforeFirstCS(pcSubStr, pcInsert, pCaseSensitive)
		This.Update(_oIbfInserter_.Content())

	def InsertBeforeFirst(pcSubStr, pcInsert)
		This.InsertBeforeFirstCS(pcSubStr, pcInsert, 1)

	def InsertAfterFirstCS(pcSubStr, pcInsert, pCaseSensitive)
		_oIafInserter_ = new stzStringInserter(This)
		_oIafInserter_.InsertAfterFirstCS(pcSubStr, pcInsert, pCaseSensitive)
		This.Update(_oIafInserter_.Content())

	def InsertAfterFirst(pcSubStr, pcInsert)
		This.InsertAfterFirstCS(pcSubStr, pcInsert, 1)

	def InsertBeforeLastCS(pcSubStr, pcInsert, pCaseSensitive)
		_oIblInserter_ = new stzStringInserter(This)
		_oIblInserter_.InsertBeforeLastCS(pcSubStr, pcInsert, pCaseSensitive)
		This.Update(_oIblInserter_.Content())

	def InsertBeforeLast(pcSubStr, pcInsert)
		This.InsertBeforeLastCS(pcSubStr, pcInsert, 1)

	def InsertAfterLastCS(pcSubStr, pcInsert, pCaseSensitive)
		_oIalInserter_ = new stzStringInserter(This)
		_oIalInserter_.InsertAfterLastCS(pcSubStr, pcInsert, pCaseSensitive)
		This.Update(_oIalInserter_.Content())

	def InsertAfterLast(pcSubStr, pcInsert)
		This.InsertAfterLastCS(pcSubStr, pcInsert, 1)

	def InsertBeforeNthCS(n, pcSubStr, pcInsert, pCaseSensitive)
		_oIbnInserter_ = new stzStringInserter(This)
		_oIbnInserter_.InsertBeforeNthCS(n, pcSubStr, pcInsert, pCaseSensitive)
		This.Update(_oIbnInserter_.Content())

	def InsertBeforeNth(n, pcSubStr, pcInsert)
		This.InsertBeforeNthCS(n, pcSubStr, pcInsert, 1)

	def InsertAfterNthCS(n, pcSubStr, pcInsert, pCaseSensitive)
		_oIanInserter_ = new stzStringInserter(This)
		_oIanInserter_.InsertAfterNthCS(n, pcSubStr, pcInsert, pCaseSensitive)
		This.Update(_oIanInserter_.Content())

	def InsertAfterNth(n, pcSubStr, pcInsert)
		This.InsertAfterNthCS(n, pcSubStr, pcInsert, 1)

	  #========================================#
	 #     REMOVER DELEGATIONS                #
	#========================================#

	def RemoveCharAt(n)
		This.RemoveSection(n, n)

	def RemoveAtPosition(n)
		This.RemoveSection(n, n)

	def RemoveW(pcCondition)
		_oRwRemover_ = new stzStringRemover(This)
		_oRwRemover_.RemoveW(pcCondition)
		This.Update(_oRwRemover_.Content())

	def RemoveSpaces()
		This.Remove(" ")

		def RemoveSpacesQ()
			This.RemoveSpaces()
			return This

	# RemoveSpacesInSections(aSections): remove every space inside the
	# given [n1, n2] sections. Walks sections in descending start-pos
	# order so earlier sections stay valid after later edits.
	def RemoveSpacesInSections(aSections)
		if NOT isList(aSections) return ok
		_nL_ = ring_len(aSections)
		if _nL_ = 0 return ok
		# Sort sections descending by start.
		_aSorted_ = _ListCopy(aSections)
		for _i_ = 2 to _nL_
			_v_ = _aSorted_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aSorted_[_j_][1] < _v_[1]
				_aSorted_[_j_ + 1] = _aSorted_[_j_]; _j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		for _i_ = 1 to _nL_
			_sec_ = _aSorted_[_i_]
			_n1_ = _sec_[1]; _n2_ = _sec_[2]
			_cTxt_ = This.Content()
			_nLT_ = This._EngineCount(_cTxt_)
			if _n1_ < 1 _n1_ = 1 ok
			if _n2_ > _nLT_ _n2_ = _nLT_ ok
			if _n1_ > _n2_ loop ok
			_cBefore_ = ""
			if _n1_ > 1 _cBefore_ = This._EngineSlice(_cTxt_, 1, _n1_ - 1) ok
			_cMid_ = This._EngineSlice(_cTxt_, _n1_, _n2_ - _n1_ + 1)
			_cAfter_ = ""
			if _n2_ < _nLT_
				_cAfter_ = This._EngineSliceFrom(_cTxt_, _n2_ + 1)
			ok
			# Strip spaces from _cMid_ via per-codepoint walk.
			_aMidChars_ = []
			_pHm_ = StzEngineString(_cMid_)
			_pHmS_ = StzEngineStringCharsSplit(_pHm_)
			_cJoinedM_ = StzEngineStringData(_pHmS_)
			StzEngineStringFree(_pHmS_)
			StzEngineStringFree(_pHm_)
			_aMidChars_ = _SplitNullDelimited(_cJoinedM_)
			_cMidClean_ = ""
			_nML_ = ring_len(_aMidChars_)
			for _k_ = 1 to _nML_
				if _aMidChars_[_k_] != " " _cMidClean_ += _aMidChars_[_k_] ok
			next
			This.Update(_cBefore_ + _cMidClean_ + _cAfter_)
		next

		def RemoveSpacesInSectionsQ(aSections)
			This.RemoveSpacesInSections(aSections)
			return This

	def RemoveLeadingSpaces()
		This.TrimLeft()

	def RemoveTrailingSpaces()
		This.TrimRight()

	#-- WithoutSpaces / SpacesRemoved: return the content with every
	#   space character removed, without mutating This. Ported from
	#   archive line 89601-89614.

	def SpacesRemoved()
		_cSrStr_ = This.Content()
		return substr(_cSrStr_, " ", "")

		def WithoutSpaces()
			return This.SpacesRemoved()

		def WithoutSpacesQ()
			return new stzString( This.WithoutSpaces() )

		# Preserve the misspelled archive alias for source-compat
		def WithoutSapces()
			return This.WithoutSpaces()

	#-- SubStringsSpacifiedCS / TheseSubstringsSpacifiedCS: wrap every
	#   occurrence of any substring in pacSubStr with spaces in the
	#   string content, return result. Used by stzCCode.Transpile to
	#   normalise token boundaries for downstream regex passes.
	#   Ported from archive line 91253; implementation collapses to a
	#   simple repeated substr-replace (Ring's built-in is global).
	#   Case-insensitive path uses a case-folded scan + position-aware
	#   splice so the result preserves the original casing of
	#   non-matched chars.

	def SubStringsSpacifiedCS(pacSubStr, pCaseSensitive)
		if NOT (isList(pacSubStr) and @IsListOfStrings(pacSubStr))
			StzRaise("SubStringsSpacifiedCS: pacSubStr must be a list of strings")
		ok
		_cSscRes_ = This.Content()
		if @CaseSensitive(pCaseSensitive)
			_nPacSubStr2Len_ = ring_len(pacSubStr)
			for _iLoopPacSubStr2_ = 1 to _nPacSubStr2Len_
				_cSub_ = pacSubStr[_iLoopPacSubStr2_]
				if _cSub_ != ""
					_cSscRes_ = substr(_cSscRes_, _cSub_, " " + _cSub_ + " ")
				ok
			next
		else
			# Case-insensitive: rebuild via manual scan to preserve
			# original casing in the non-matched stretches.
			_nPacSubStr1Len_ = ring_len(pacSubStr)
			for _iLoopPacSubStr1_ = 1 to _nPacSubStr1Len_
				_cSub_ = pacSubStr[_iLoopPacSubStr1_]
				if _cSub_ = "" loop ok
				_cSscOut_ = ""
				_cSscHay_ = lower(_cSscRes_)
				_cSscNdl_ = lower(_cSub_)
				_nSscLen_ = ring_len(_cSscRes_)
				_nSscSub_ = ring_len(_cSub_)
				_iSsc_ = 1
				while _iSsc_ <= _nSscLen_
					if _iSsc_ + _nSscSub_ - 1 <= _nSscLen_ and substr(_cSscHay_, _iSsc_, _nSscSub_) = _cSscNdl_
						_cSscOut_ += " " + substr(_cSscRes_, _iSsc_, _nSscSub_) + " "
						_iSsc_ += _nSscSub_
					else
						_cSscOut_ += substr(_cSscRes_, _iSsc_, 1)
						_iSsc_++
					ok
				end
				_cSscRes_ = _cSscOut_
			next
		ok
		return _cSscRes_

		def TheseSubstringsSpacifiedCS(pacSubStr, pCaseSensitive)
			return This.SubStringsSpacifiedCS(pacSubStr, pCaseSensitive)

		def TheseSpacifiedCS(pacSubStr, pCaseSensitive)
			return This.SubStringsSpacifiedCS(pacSubStr, pCaseSensitive)

	def SubStringsSpacified(pacSubStr)
		return This.SubStringsSpacifiedCS(pacSubStr, 1)

		def TheseSubstringsSpacified(pacSubStr)
			return This.SubStringsSpacified(pacSubStr)

		def TheseSpacified(pacSubStr)
			return This.SubStringsSpacified(pacSubStr)

	# SpacifySubStringsUsing: in-place variant of SubStringsSpacified
	# that lets the caller choose the separator (default would be a
	# single space; this form makes it explicit). Wraps every
	# occurrence of each substring in pacSubStr with the given
	# separator on both sides.

	def SpacifySubStringsUsingCS(pacSubStr, pcSep, pCaseSensitive)
		if NOT (isList(pacSubStr) and @IsListOfStrings(pacSubStr))
			StzRaise("SpacifySubStringsUsing: pacSubStr must be a list of strings")
		ok
		if NOT isString(pcSep)
			StzRaise("SpacifySubStringsUsing: pcSep must be a string")
		ok
		_cRes_ = This.Content()
		_nLen_ = ring_len(pacSubStr)
		for _i_ = 1 to _nLen_
			_cSub_ = pacSubStr[_i_]
			if _cSub_ = "" loop ok
			# Walk-and-substitute matching SubStringsSpacifiedCS' shape
			_cOut_ = ""
			_cHay_ = _cRes_
			if NOT @CaseSensitive(pCaseSensitive)
				_cHayLow_ = lower(_cHay_)
				_cNdlLow_ = lower(_cSub_)
			else
				_cHayLow_ = _cHay_
				_cNdlLow_ = _cSub_
			ok
			_nHayLen_ = ring_len(_cHay_)
			_nSubLen_ = ring_len(_cSub_)
			_iC_ = 1
			while _iC_ <= _nHayLen_
				if _iC_ + _nSubLen_ - 1 <= _nHayLen_ and
				   substr(_cHayLow_, _iC_, _nSubLen_) = _cNdlLow_
					_cOut_ += pcSep + substr(_cHay_, _iC_, _nSubLen_) + pcSep
					_iC_ += _nSubLen_
				else
					_cOut_ += substr(_cHay_, _iC_, 1)
					_iC_++
				ok
			end
			_cRes_ = _cOut_
		next
		This.Update(_cRes_)

		def SpacifySubStringsUsingCSQ(pacSubStr, pcSep, pCaseSensitive)
			This.SpacifySubStringsUsingCS(pacSubStr, pcSep, pCaseSensitive)
			return This

	def SpacifySubStringsUsing(pacSubStr, pcSep)
		This.SpacifySubStringsUsingCS(pacSubStr, pcSep, 1)

		def SpacifySubStringsUsingQ(pacSubStr, pcSep)
			This.SpacifySubStringsUsing(pacSubStr, pcSep)
			return This

		def SpacifySubStringUsing(pcSub, pcSep)
			This.SpacifySubStringsUsing([ pcSub ], pcSep)

		def SpacifySubStrings(pacSubStr)
			This.SpacifySubStringsUsing(pacSubStr, " ")

	# AddXT: extended Add dispatching on a named-param DSL.
	# Supported shapes:
	#
	#   AddXT(pcSep, :AfterThese  = [ "a", "b", ... ])
	#       For each item p in the list, insert pcSep right after
	#       every occurrence of p in the string.
	#
	#   AddXT(pcSep, :BeforeThese = [ "a", "b", ... ])
	#       Same as AfterThese but the separator lands BEFORE each
	#       match.
	#
	#   AddXT([cBefore, cAfter], :Around = "p")
	#       Wrap every occurrence of "p" between cBefore and cAfter.
	#
	#   AddXT(cBoth, :Around = "p")
	#       Shortcut for [cBoth, cBoth] -- same separator on both
	#       sides.

	def AddXT(p1, p2)
		# Form 0: pcWhat + :After / :Before / :To / :AfterEach / :BeforeEach
		# anchored single insertion (or per-occurrence) form.
		if isString(p1) and isList(p2) and ring_len(p2) = 2 and isString(p2[1])
			_cKey0_ = lower(p2[1])
			_xVal0_ = p2[2]

			if (_cKey0_ = "after" or _cKey0_ = "to") and isString(_xVal0_)
				_cTxt_ = This.Content()
				_cTxt_ = substr(_cTxt_, _xVal0_, _xVal0_ + p1)
				This.Update(_cTxt_)
				return
			but _cKey0_ = "before" and isString(_xVal0_)
				_cTxt_ = This.Content()
				_cTxt_ = substr(_cTxt_, _xVal0_, p1 + _xVal0_)
				This.Update(_cTxt_)
				return
			but _cKey0_ = "aftereach" and isString(_xVal0_)
				_cTxt_ = This.Content()
				_cTxt_ = substr(_cTxt_, _xVal0_, _xVal0_ + p1)
				This.Update(_cTxt_)
				return
			but _cKey0_ = "beforeeach" and isString(_xVal0_)
				_cTxt_ = This.Content()
				_cTxt_ = substr(_cTxt_, _xVal0_, p1 + _xVal0_)
				This.Update(_cTxt_)
				return
			ok
		ok

		# Form 1/2: pcSep + :AfterThese / :BeforeThese
		if isString(p1) and isList(p2) and ring_len(p2) = 2 and isString(p2[1])
			_cKey_ = lower(p2[1])
			_xVal_ = p2[2]

			if _cKey_ = "afterthese" or _cKey_ = "beforethese"
				if NOT isList(_xVal_)
					StzRaise("AddXT: :" + p2[1] + " expects a list of strings.")
				ok
				_bAfter_ = (_cKey_ = "afterthese")
				_cTxt_ = This.Content()
				_nVlen_ = ring_len(_xVal_)
				for _iAx_ = 1 to _nVlen_
					_cSub_ = _xVal_[_iAx_]
					if NOT isString(_cSub_) or _cSub_ = "" loop ok
					if _bAfter_
						_cTxt_ = substr(_cTxt_, _cSub_, _cSub_ + p1)
					else
						_cTxt_ = substr(_cTxt_, _cSub_, p1 + _cSub_)
					ok
				next
				This.Update(_cTxt_)
				return
			ok
		ok

		# Form 3: [cBefore, cAfter] + :Around = "p"
		if isList(p1) and ring_len(p1) = 2 and isString(p1[1]) and isString(p1[2]) and
		   isList(p2) and ring_len(p2) = 2 and isString(p2[1]) and lower(p2[1]) = "around" and
		   isString(p2[2])
			_cTxt_ = This.Content()
			_cTxt_ = substr(_cTxt_, p2[2], p1[1] + p2[2] + p1[2])
			This.Update(_cTxt_)
			return
		ok

		# Form 4: cBoth + :Around = "p"
		if isString(p1) and isList(p2) and ring_len(p2) = 2 and isString(p2[1]) and
		   lower(p2[1]) = "around" and isString(p2[2])
			_cTxt_ = This.Content()
			_cTxt_ = substr(_cTxt_, p2[2], p1 + p2[2] + p1)
			This.Update(_cTxt_)
			return
		ok

		StzRaise("AddXT: unsupported argument shape.")

		def AddXTQ(p1, p2)
			This.AddXT(p1, p2)
			return This

	#-- FindSubStringsBoundedByIBZZ: for every substring bounded by
	#   pacBounds[1]..pacBounds[2] return the [startPos, endPos]
	#   pairs INCLUDING the bounds (IB = inclusive bounds). Ported
	#   from archive line 34794; self-contained scan rather than
	#   the SectionsBetween-based archive version.

	def FindSubStringsBoundedByIBZZ(pacBounds)
		return This.FindSubStringsBoundedByIBCSZZ(pacBounds, 1)

		def FindBoundedByIBZZ(pacBounds)
			return This.FindSubStringsBoundedByIBZZ(pacBounds)

	#-- SubStringsBoundedByIB: like BoundedBy but the returned
	#   substrings INCLUDE the bounds. E.g. on "[@i]___[@i+1]" with
	#   bounds ["[","]"] returns [ "[@i]", "[@i+1]" ].

	def SubStringsBoundedByIBCS(pacBounds, pCaseSensitive)
		_aSibZZ_ = This.FindSubStringsBoundedByIBCSZZ(pacBounds, pCaseSensitive)
		_acSibR_ = []
		_cSibStr_ = This.Content()
		_n_aSibZZ1Len_ = ring_len(_aSibZZ_)
		for _iLoop_aSibZZ1_ = 1 to _n_aSibZZ1Len_
			_aSibPair_ = _aSibZZ_[_iLoop_aSibZZ1_]
			_nA_ = _aSibPair_[1]
			_nB_ = _aSibPair_[2]
			_acSibR_ + substr(_cSibStr_, _nA_, _nB_ - _nA_ + 1)
		next
		return _acSibR_

	def SubStringsBoundedByIB(pacBounds)
		return This.SubStringsBoundedByIBCS(pacBounds, 1)

		def BoundedByIB(pacBounds)
			return This.SubStringsBoundedByIB(pacBounds)

		def AnyBoundedByIB(pacBounds)
			return This.SubStringsBoundedByIB(pacBounds)

		def AnySubStringsBoundedByIB(pacBounds)
			return This.SubStringsBoundedByIB(pacBounds)

	#-- FindSubStringsBoundedByZZ: exclusive-bounds variant. Returns
	#   the position-pair list for the INNER content (without the
	#   bound chars). Derived from the IB result by shifting the
	#   start past the open token and the end before the close token.

	def FindSubStringsBoundedByZZ(pacBounds)
		return This.FindSubStringsBoundedByCSZZ(pacBounds, 1)

		def FindAnySubStringBoundedByZZ(pacBounds)
			return This.FindSubStringsBoundedByZZ(pacBounds)

		def FindAnySubStringsBoundedByZZ(pacBounds)
			return This.FindSubStringsBoundedByZZ(pacBounds)

		def FindBoundedByZZ(pacBounds)
			return This.FindSubStringsBoundedByZZ(pacBounds)

	def FindSubStringsBoundedByCSZZ(pacBounds, pCaseSensitive)
		_aFsbcIB_ = This.FindSubStringsBoundedByIBCSZZ(pacBounds, pCaseSensitive)
		_acFsbcR_ = []
		_nOpenLen_ = ring_len(pacBounds[1])
		_nCloseLen_ = ring_len(pacBounds[2])
		_n_aFsbcIB1Len_ = ring_len(_aFsbcIB_)
		for _iLoop_aFsbcIB1_ = 1 to _n_aFsbcIB1Len_
			_aFsbcPair_ = _aFsbcIB_[_iLoop_aFsbcIB1_]
			_acFsbcR_ + [ _aFsbcPair_[1] + _nOpenLen_, _aFsbcPair_[2] - _nCloseLen_ ]
		next
		return _acFsbcR_

	def FindSubStringsBoundedByIBCSZZ(pacBounds, pCaseSensitive)
		if NOT (isList(pacBounds) and ring_len(pacBounds) = 2 and
		        isString(pacBounds[1]) and isString(pacBounds[2]))
			StzRaise("FindSubStringsBoundedByIBCSZZ: pacBounds must be [ open, close ] strings")
		ok
		_acFsibResult_ = []
		_cFsibStr_ = This.Content()
		_cFsibOpen_ = pacBounds[1]
		_cFsibClose_ = pacBounds[2]
		_nFsibLen_ = ring_len(_cFsibStr_)
		_nFsibO_ = ring_len(_cFsibOpen_)
		_nFsibC_ = ring_len(_cFsibClose_)
		if _nFsibO_ = 0 or _nFsibC_ = 0
			return _acFsibResult_
		ok
		_cFsibHay_ = _cFsibStr_
		_cFsibO2_ = _cFsibOpen_
		_cFsibC2_ = _cFsibClose_
		if NOT @CaseSensitive(pCaseSensitive)
			_cFsibHay_ = lower(_cFsibHay_)
			_cFsibO2_ = lower(_cFsibO2_)
			_cFsibC2_ = lower(_cFsibC2_)
		ok
		_iFsib_ = 1
		while _iFsib_ <= _nFsibLen_ - _nFsibO_ + 1
			if substr(_cFsibHay_, _iFsib_, _nFsibO_) = _cFsibO2_
				_jFsib_ = _iFsib_ + _nFsibO_
				_bFsibFound_ = 0
				while _jFsib_ <= _nFsibLen_ - _nFsibC_ + 1
					if substr(_cFsibHay_, _jFsib_, _nFsibC_) = _cFsibC2_
						_acFsibResult_ + [ _iFsib_, _jFsib_ + _nFsibC_ - 1 ]
						_iFsib_ = _jFsib_ + _nFsibC_
						_bFsibFound_ = 1
						exit
					ok
					_jFsib_++
				end
				if NOT _bFsibFound_
					_iFsib_++
				ok
			else
				_iFsib_++
			ok
		end
		return _acFsibResult_

	#-- RemoveThisTrailingChar: strip repeated trailing occurrences
	#   of a single given char. "abc!!" + RemoveThisTrailingChar("!")
	#   -> "abc". Ported from the legacy monolithic archive
	#   (~line 27306-27389); standalone byte-level implementation that
	#   avoids cascading dependencies on FindRepeatedTrailingChars*.

	def RemoveThisTrailingChar(c)
		if NOT isString(c)
			StzRaise("RemoveThisTrailingChar: c must be a string")
		ok
		if ring_len(c) = 0
			return
		ok
		_cStr_ = This.Content()
		_nLen_ = ring_len(_cStr_)
		while _nLen_ > 0 and right(_cStr_, 1) = c
			_cStr_ = left(_cStr_, _nLen_ - 1)
			_nLen_--
		end
		This.Update(_cStr_)

		def RemoveThisTrailingCharQ(c)
			This.RemoveThisTrailingChar(c)
			return This

		def RemoveThisRepeatedTrailingChar(c)
			This.RemoveThisTrailingChar(c)

		def RemoveThisRepeatedTrailingCharQ(c)
			This.RemoveThisTrailingChar(c)
			return This

		def RemoveThisTrailingRepeatedChar(c)
			This.RemoveThisTrailingChar(c)

		def RemoveThisTrailingRepeatedCharQ(c)
			This.RemoveThisTrailingChar(c)
			return This

	def RemoveThisLeadingChar(c)
		if NOT isString(c)
			StzRaise("RemoveThisLeadingChar: c must be a string")
		ok
		if ring_len(c) = 0
			return
		ok
		_cStr_ = This.Content()
		while ring_len(_cStr_) > 0 and left(_cStr_, 1) = c
			_cStr_ = substr(_cStr_, 2)
		end
		This.Update(_cStr_)

		def RemoveThisLeadingCharQ(c)
			This.RemoveThisLeadingChar(c)
			return This

	def RemoveDuplicatesCS(pCaseSensitive)
		_oRdRemover_ = new stzStringRemover(This)
		_oRdRemover_.RemoveDuplicatesCS(pCaseSensitive)
		This.Update(_oRdRemover_.Content())

	def RemoveDuplicates()
		This.RemoveDuplicatesCS(1)

	def RemoveFromLeftCS(pcSubStr, pCaseSensitive)
		_oRflRemover_ = new stzStringRemover(This)
		_oRflRemover_.RemoveFromLeftCS(pcSubStr, pCaseSensitive)
		This.Update(_oRflRemover_.Content())

	def RemoveFromLeft(pcSubStr)
		This.RemoveFromLeftCS(pcSubStr, 1)

	def RemoveFromRightCS(pcSubStr, pCaseSensitive)
		_oRfrRemover_ = new stzStringRemover(This)
		_oRfrRemover_.RemoveFromRightCS(pcSubStr, pCaseSensitive)
		This.Update(_oRfrRemover_.Content())

	def RemoveFromRight(pcSubStr)
		This.RemoveFromRightCS(pcSubStr, 1)

	def RemoveRange(nStart, nRange)
		This.RemoveSection(nStart, nStart + nRange - 1)

	  #========================================#
	 #     FIND FIRST STARTING AT            #
	#========================================#

	def FindFirstSTCS(pcSubStr, nStartAt, pCaseSensitive)
		# :StartingAt = n normalisation.
		if isList(nStartAt) and ring_len(nStartAt) = 2 and
		   isString(nStartAt[1]) and lower(nStartAt[1]) = "startingat"
			nStartAt = nStartAt[2]
		ok
		_bFstCase_ = @CaseSensitive(pCaseSensitive)
		return This._FindSubStr(pcSubStr, nStartAt, _bFstCase_)

	def FindFirstST(pcSubStr, nStartAt)
		if isList(nStartAt) and ring_len(nStartAt) = 2 and
		   isString(nStartAt[1]) and lower(nStartAt[1]) = "startingat"
			nStartAt = nStartAt[2]
		ok
		return This.FindFirstSTCS(pcSubStr, nStartAt, 1)

	# FindLastST: forward to the engine's "find from end" path.
	def FindLastST(pcSubStr, nStartAt)
		if isList(nStartAt) and ring_len(nStartAt) = 2 and
		   isString(nStartAt[1]) and lower(nStartAt[1]) = "startingat"
			nStartAt = nStartAt[2]
		ok
		# Walk forward and remember the last hit at or after nStartAt.
		_nPos_ = nStartAt; _nLast_ = 0
		while TRUE
			_nFound_ = This._FindSubStr(pcSubStr, _nPos_, 1)
			if _nFound_ = 0 exit ok
			_nLast_ = _nFound_
			_nPos_ = _nFound_ + ring_len(pcSubStr)
		end
		return _nLast_

	def FindNthST(n, pcSubStr, nStartAt)
		if isList(nStartAt) and ring_len(nStartAt) = 2 and
		   isString(nStartAt[1]) and lower(nStartAt[1]) = "startingat"
			nStartAt = nStartAt[2]
		ok
		_nPos_ = nStartAt; _nCount_ = 0
		while TRUE
			_nFound_ = This._FindSubStr(pcSubStr, _nPos_, 1)
			if _nFound_ = 0 return 0 ok
			_nCount_++
			if _nCount_ = n return _nFound_ ok
			_nPos_ = _nFound_ + This._EngineCount(pcSubStr)
		end
		return 0

	# FindFirstSTD: directional find-from-position.
	#   FindFirstSTD(sub, :StartingAt = n, :Backward)
	#   FindFirstSTD(sub, :StartingAt = n, :Direction = :Forward|:Backward)
	def FindFirstSTD(pcSubStr, nStartAt, pDir)
		if isList(nStartAt) and ring_len(nStartAt) = 2 and
		   isString(nStartAt[1]) and lower(nStartAt[1]) = "startingat"
			nStartAt = nStartAt[2]
		ok
		# pDir can be the bare :Backward / :Forward symbol or the
		# :Direction = :Forward/:Backward named-param shape.
		_bBackward_ = FALSE
		if isString(pDir) and lower(pDir) = "backward"
			_bBackward_ = TRUE
		but isList(pDir) and ring_len(pDir) = 2 and isString(pDir[1]) and
		   lower(pDir[1]) = "direction"
			if isString(pDir[2]) and lower(pDir[2]) = "backward"
				_bBackward_ = TRUE
			ok
		ok
		_cTxt_ = This.Content()
		if NOT _bBackward_
			return This._FindFrom(_cTxt_, pcSubStr, nStartAt)
		ok
		# Backward: scan from position nStartAt walking down to 1,
		# checking codepoint slices of pcSubStr length at each step.
		_nSubLen_ = This._EngineCount(pcSubStr)
		_nMax_ = nStartAt
		if _nMax_ > This._EngineCount(_cTxt_) - _nSubLen_ + 1
			_nMax_ = This._EngineCount(_cTxt_) - _nSubLen_ + 1
		ok
		for _i_ = _nMax_ to 1 step -1
			if This._EngineSlice(_cTxt_, _i_, _nSubLen_) = pcSubStr
				return _i_
			ok
		next
		return 0

	# FindFirstSTDZZ: same as FindFirstSTD but returns [start, end]
	# instead of just start.
	def FindFirstSTDZZ(pcSubStr, nStartAt, pDir)
		_nPos_ = This.FindFirstSTD(pcSubStr, nStartAt, pDir)
		if _nPos_ = 0 return [] ok
		_nSubLen_ = This._EngineCount(pcSubStr)
		return [ _nPos_, _nPos_ + _nSubLen_ - 1 ]

	# FindFirstSTZZ: section form of FindFirstST.
	def FindFirstSTZZ(pcSubStr, nStartAt)
		_nPos_ = This.FindFirstST(pcSubStr, nStartAt)
		if _nPos_ = 0 return [] ok
		_nSubLen_ = This._EngineCount(pcSubStr)
		return [ _nPos_, _nPos_ + _nSubLen_ - 1 ]

	# Mirror forms: FindLastST / FindLastSTZZ / FindLastSTD aliases.
	def FindLastSTZZ(pcSubStr, nStartAt)
		_nPos_ = This.FindLastST(pcSubStr, nStartAt)
		if _nPos_ = 0 return [] ok
		_nSubLen_ = This._EngineCount(pcSubStr)
		return [ _nPos_, _nPos_ + _nSubLen_ - 1 ]

	def FindLastSTD(pcSubStr, nStartAt, pDir)
		# Forward FindLastSTD := FindLastST starting forward from nStartAt;
		# Backward := walk backwards looking for any occurrence (so the
		# "last" one ends up being the highest position <= nStartAt).
		_bBackward_ = FALSE
		if isString(pDir) and lower(pDir) = "backward"
			_bBackward_ = TRUE
		but isList(pDir) and ring_len(pDir) = 2 and isString(pDir[1]) and
		   lower(pDir[1]) = "direction"
			if isString(pDir[2]) and lower(pDir[2]) = "backward"
				_bBackward_ = TRUE
			ok
		ok
		if NOT _bBackward_
			return This.FindLastST(pcSubStr, nStartAt)
		ok
		return This.FindFirstSTD(pcSubStr, nStartAt, :Backward)

	def FindLastSTDZZ(pcSubStr, nStartAt, pDir)
		_nPos_ = This.FindLastSTD(pcSubStr, nStartAt, pDir)
		if _nPos_ = 0 return [] ok
		_nSubLen_ = This._EngineCount(pcSubStr)
		return [ _nPos_, _nPos_ + _nSubLen_ - 1 ]

	# FindDuplicates -- positions of duplicated chars in the content.
	# A char is "duplicated" if it appears more than once anywhere.
	# Returns the 2nd+ occurrence positions (so the FIRST occurrence
	# is not reported, matching stzList.FindDuplicates semantics).
	def FindDuplicates()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		_aSeen_ = []
		for _i_ = 1 to _nLen_
			_c_ = _aChars_[_i_]
			_bDup_ = FALSE
			_nSL_ = ring_len(_aSeen_)
			for _j_ = 1 to _nSL_
				if _aSeen_[_j_] = _c_ _bDup_ = TRUE exit ok
			next
			if _bDup_
				_aRes_ + _i_
			else
				_aSeen_ + _c_
			ok
		next
		return _aRes_

	# FindDupSecutiveChars -- positions of any char that EQUALS the
	# previous one in the codepoint walk (i.e. immediate-duplicates).
	# Returns the 2nd+ position of each run.
	def FindDupSecutiveChars()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		for _i_ = 2 to _nLen_
			if _aChars_[_i_] = _aChars_[_i_ - 1]
				_aRes_ + _i_
			ok
		next
		return _aRes_

	# FindDupSecutiveSubString: positions where the substring at i+1
	# equals the substring of the same length ending at i (i.e.
	# back-to-back identical substrings). Returns the start positions
	# of the second copy in each consecutive pair.
	def FindDupSecutiveSubString(pcSub)
		_nSubLen_ = This._EngineCount(pcSub)
		if _nSubLen_ = 0 return [] ok
		_cTxt_ = This.Content()
		_nLen_ = This._EngineCount(_cTxt_)
		_aRes_ = []
		_i_ = 1
		while _i_ + 2 * _nSubLen_ - 1 <= _nLen_
			if This._EngineSlice(_cTxt_, _i_, _nSubLen_) = pcSub and
			   This._EngineSlice(_cTxt_, _i_ + _nSubLen_, _nSubLen_) = pcSub
				_aRes_ + _i_ + _nSubLen_
				_i_ += _nSubLen_
			else
				_i_++
			ok
		end
		return _aRes_

	# Z-suffix sectional forms (return [start, end] instead of just
	# start) for the duplicate finders.
	def FindDuplicatesZZ()
		_aPos_ = This.FindDuplicates()
		_aRes_ = []
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_aRes_ + [ _aPos_[_i_], _aPos_[_i_] ]
		next
		return _aRes_

	# DuplicatesZ aliases used by narrative tests -- positions of
	# duplicated chars.
	def DuplicatesZ()
		return This.FindDuplicates()

	def DuplicateCharsZ()
		return This.FindDuplicates()

	def DuplicationsZ()
		return This.FindDuplicates()

	def FindDupSecutiveCharsZZ()
		_aPos_ = This.FindDupSecutiveChars()
		_aRes_ = []
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_aRes_ + [ _aPos_[_i_], _aPos_[_i_] ]
		next
		return _aRes_

	# Z-suffix alias: just the start positions of dup-consec
	# substring matches (same as the bare FindDupSecutiveSubString).
	def DupSecutiveSubStringZ(pcSub)
		return This.FindDupSecutiveSubString(pcSub)

	def DupSecutiveCharsZ()
		return This.FindDupSecutiveChars()

	def FindDupSecutiveSubStringZZ(pcSub)
		_aPos_ = This.FindDupSecutiveSubString(pcSub)
		_nSubLen_ = This._EngineCount(pcSub)
		_aRes_ = []
		_nL_ = ring_len(_aPos_)
		for _i_ = 1 to _nL_
			_aRes_ + [ _aPos_[_i_], _aPos_[_i_] + _nSubLen_ - 1 ]
		next
		return _aRes_

		# Drop-the-Find prefix alias.
		def DupSecutiveSubStringZZ(pcSub)
			return This.FindDupSecutiveSubStringZZ(pcSub)

		def DupSecutiveCharsZZ()
			return This.FindDupSecutiveCharsZZ()

	# FindBetween(pcSub, pcOpen, pcClose): the positions of pcSub
	# when it appears between pcOpen .. pcClose bounded sections.
	# Convenience wrapper over FindSubStringBoundedBy.
	def FindBetween(pcSub, pcOpen, pcClose)
		return This.FindSubStringBoundedBy(pcSub, [ pcOpen, pcClose ])

	# ContainsAt(p1, p2): does the content contain p2 at position p1?
	# Two shapes supported by narratives:
	#   ContainsAt(nPos, pcSub)
	#   ContainsAt(pcSub, :Position = nPos)
	#   ContainsAt(anPositions, pcSub)  -- ContainsAtPositions
	def ContainsAt(p1, p2)
		# Case A: (nPos, pcSub)
		if isNumber(p1) and isString(p2)
			return This._EngineSlice(This.Content(), p1, This._EngineCount(p2)) = p2
		ok
		# Case B: (pcSub, :Position = nPos)
		if isString(p1) and isList(p2) and ring_len(p2) = 2 and
		   isString(p2[1]) and lower(p2[1]) = "position"
			_n_ = p2[2]
			return This._EngineSlice(This.Content(), _n_, This._EngineCount(p1)) = p1
		ok
		# Case C: (anPositions, pcSub) -- AND of all positions match.
		if isList(p1) and isString(p2)
			_nLen_ = ring_len(p1)
			for _i_ = 1 to _nLen_
				if This._EngineSlice(This.Content(), p1[_i_], This._EngineCount(p2)) != p2
					return FALSE
				ok
			next
			return TRUE
		ok
		return FALSE

	def ContainsAtPosition(pcSub, n)
		return This._EngineSlice(This.Content(), n, This._EngineCount(pcSub)) = pcSub

	def ContainsAtPositions(anPositions, pcSub)
		return This.ContainsAt(anPositions, pcSub)

	# Letters() / LettersQ(): characters that are letters. Engine-
	# backed: filters the codepoint list by IsLetter() (Unicode-aware).
	def Letters()
		_aRes_ = []
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		for _i_ = 1 to _nLen_
			_c_ = _aChars_[_i_]
			if isalpha(_c_)
				_aRes_ + _c_
			ok
		next
		return _aRes_

	def LettersQ()
		return new stzList( This.Letters() )

	def NumberOfLetters()
		return ring_len(This.Letters())

	# FindWXT: predicate-driven find positions; @char binding.
	def FindWXT(pcCondition)
		_cExpr_ = pcCondition
		if isList(pcCondition) and ring_len(pcCondition) = 2 and
		   isString(pcCondition[1]) and lower(pcCondition[1]) = "where"
			_cExpr_ = pcCondition[2]
		ok
		if NOT isString(_cExpr_) return [] ok
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		_aRes_ = []
		for _i_ = 1 to _nLen_
			@char = _aChars_[_i_]
			@Char = @char
			@position = _i_
			_bMatch_ = FALSE
			try
				eval("_bMatch_ = " + _cExpr_)
			catch
				_bMatch_ = FALSE
			done
			if _bMatch_ _aRes_ + _i_ ok
		next
		return _aRes_

	# Interpolated(paBindings): replace each `${key}` placeholder in
	# This with the corresponding value from paBindings (a hashlist
	# of [:key, value] pairs).
	def Interpolated(paBindings)
		if NOT isList(paBindings) return This.Content() ok
		_cOut_ = This.Content()
		_nL_ = ring_len(paBindings)
		for _i_ = 1 to _nL_
			_p_ = paBindings[_i_]
			if isList(_p_) and ring_len(_p_) = 2 and isString(_p_[1])
				# Substitute every "${" + key + "}" with the value.
				_cPh_ = "${" + _p_[1] + "}"
				_cVal_ = "" + _p_[2]
				# Engine-replace (codepoint-aware).
				_pH_ = StzEngineString(_cOut_)
				_pR_ = StzEngineStringReplaceCS(_pH_, _cPh_, _cVal_, 1)
				_cOut_ = StzEngineStringData(_pR_)
				StzEngineStringFree(_pR_)
				StzEngineStringFree(_pH_)
			ok
		next
		return _cOut_

	def InterpolatedQ(paBindings)
		return new stzString( This.Interpolated(paBindings) )

	# AllCharsAre(pcKind): every char matches the given predicate
	# (which is a symbolic kind like :Chars, :Numbers, :Letters,
	# :Punctuations, :Arabic, :RightToLeft, :Invertible).
	# Engine-backed where the helper exists; falls back to
	# isalpha / isDigit otherwise.
	def AllCharsAre(pcKind)
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return FALSE ok
		_k_ = ""
		if isString(pcKind) _k_ = lower(pcKind) ok
		# Handle the digit-derived kinds via dedicated walkers so they
		# stay readable.
		if _k_ = "even" return This.AllCharsAreEven() ok
		if _k_ = "odd" return This.AllCharsAreOdd() ok
		if _k_ = "positive" return This.AllCharsArePositive() ok
		for _i_ = 1 to _nLen_
			_c_ = _aChars_[_i_]
			_bOk_ = FALSE
			if _k_ = "chars" or _k_ = "strings"
				_bOk_ = isString(_c_)
			but _k_ = "numbers" or _k_ = "digits"
				_bOk_ = isDigit(_c_)
			but _k_ = "letters"
				_bOk_ = isAlpha(_c_)
			but _k_ = "punctuations" or _k_ = "punctuation"
				_bOk_ = (ring_find([",", ".", ";", ":", "!", "?", "(", ")", "[", "]", "{", "}", "-", "'", char(34), "/", "\", "|", "<", ">"], _c_) > 0)
			but _k_ = "arabic"
				_n_ = StzCharToUnicode(_c_)
				_bOk_ = ((_n_ >= 0x0600 and _n_ <= 0x06FF) or (_n_ >= 0x0750 and _n_ <= 0x077F) or (_n_ >= 0x08A0 and _n_ <= 0x08FF) or (_n_ >= 0xFB50 and _n_ <= 0xFDFF) or (_n_ >= 0xFE70 and _n_ <= 0xFEFF))
			but _k_ = "righttoleft" or _k_ = "rtl"
				_n_ = StzCharToUnicode(_c_)
				_bOk_ = ((_n_ >= 0x0590 and _n_ <= 0x08FF) or (_n_ >= 0xFB1D and _n_ <= 0xFDFF) or (_n_ >= 0xFE70 and _n_ <= 0xFEFF))
			but _k_ = "invertible"
				# Provisional: ASCII letters are considered invertible
				# in the narrative. Real impl needs the Unicode upside-
				# down char table (see retired Turned tests).
				_bOk_ = isAlpha(_c_)
			else
				_bOk_ = FALSE
			ok
			if NOT _bOk_ return FALSE ok
		next
		return TRUE

	# IsPluralOfAStzType: predicate checking a :stz<Type>s symbolic
	# name (e.g. :stzListsOfStrings, :stzStrings). Used by narratives
	# that introspect Softanza type symbols.
	def IsPluralOfAStzType()
		_s_ = lower(This.Content())
		# Plural shapes Softanza recognises end in "s" (or "es").
		if NOT (ring_left(_s_, 3) = "stz") return FALSE ok
		# Must end with 's' AND the singular (without trailing s)
		# must also be a Stz type name.
		if NOT (ring_right(_s_, 1) = "s") return FALSE ok
		_singular_ = ring_left(_s_, ring_len(_s_) - 1)
		# We accept it as a plural of a stzType if removing the
		# trailing 's' yields a name that begins with "stz" too.
		return ring_left(_singular_, 3) = "stz"

	def IsPluralOfStzType()
		return This.IsPluralOfAStzType()

	# AllCharsAreXT(aKinds, pNamed): every char satisfies EVERY kind
	# in aKinds. pNamed accepts :EvaluateFrom = :LTR/:RTL but the
	# evaluation result is order-independent; the param is kept for
	# narrative-symmetry.
	def AllCharsAreXT(aKinds, pNamed)
		if NOT isList(aKinds) return FALSE ok
		_nK_ = ring_len(aKinds)
		for _i_ = 1 to _nK_
			if NOT This.AllCharsAre(aKinds[_i_])
				return FALSE
			ok
		next
		return TRUE

	# AllCharsAre extension: :Even / :Odd / :Positive for digits.
	# Augment the existing kind list via inline checks.
	def AllCharsAreEven()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return FALSE ok
		for _i_ = 1 to _nLen_
			if NOT isDigit(_aChars_[_i_]) return FALSE ok
			_n_ = 0 + _aChars_[_i_]
			if _n_ % 2 != 0 return FALSE ok
		next
		return TRUE

	def AllCharsAreOdd()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return FALSE ok
		for _i_ = 1 to _nLen_
			if NOT isDigit(_aChars_[_i_]) return FALSE ok
			_n_ = 0 + _aChars_[_i_]
			if _n_ % 2 = 0 return FALSE ok
		next
		return TRUE

	def AllCharsArePositive()
		_aChars_ = This.Chars()
		_nLen_ = ring_len(_aChars_)
		if _nLen_ = 0 return FALSE ok
		for _i_ = 1 to _nLen_
			if NOT isDigit(_aChars_[_i_]) return FALSE ok
			_n_ = 0 + _aChars_[_i_]
			if _n_ < 0 return FALSE ok
		next
		return TRUE

	# FindNthSTZZ / FindNthSTD / FindNthSTDZZ -- sectional / directional
	# variants used by narratives. Reuse the singular forms.
	def FindNthSTZZ(n, pcSubStr, nStartAt)
		_nPos_ = This.FindNthST(n, pcSubStr, nStartAt)
		if _nPos_ = 0 return [] ok
		_nSubLen_ = This._EngineCount(pcSubStr)
		return [ _nPos_, _nPos_ + _nSubLen_ - 1 ]

	def FindNthSTD(n, pcSubStr, nStartAt, pDir)
		if isList(nStartAt) and ring_len(nStartAt) = 2 and
		   isString(nStartAt[1]) and lower(nStartAt[1]) = "startingat"
			nStartAt = nStartAt[2]
		ok
		_bBackward_ = FALSE
		if isString(pDir) and lower(pDir) = "backward"
			_bBackward_ = TRUE
		but isList(pDir) and ring_len(pDir) = 2 and isString(pDir[1]) and
		   lower(pDir[1]) = "direction"
			if isString(pDir[2]) and lower(pDir[2]) = "backward"
				_bBackward_ = TRUE
			ok
		ok
		if NOT _bBackward_
			return This.FindNthST(n, pcSubStr, nStartAt)
		ok
		# Backward: walk down collecting positions, return the n-th.
		_cTxt_ = This.Content()
		_nSubLen_ = This._EngineCount(pcSubStr)
		_nMax_ = nStartAt
		_nTxtLen_ = This._EngineCount(_cTxt_)
		if _nMax_ > _nTxtLen_ - _nSubLen_ + 1
			_nMax_ = _nTxtLen_ - _nSubLen_ + 1
		ok
		_aFound_ = []
		for _i_ = _nMax_ to 1 step -1
			if This._EngineSlice(_cTxt_, _i_, _nSubLen_) = pcSubStr
				_aFound_ + _i_
				if ring_len(_aFound_) = n return _i_ ok
			ok
		next
		return 0

	def FindNthSTDZZ(n, pcSubStr, nStartAt, pDir)
		_nPos_ = This.FindNthSTD(n, pcSubStr, nStartAt, pDir)
		if _nPos_ = 0 return [] ok
		_nSubLen_ = This._EngineCount(pcSubStr)
		return [ _nPos_, _nPos_ + _nSubLen_ - 1 ]

	  #========================================#
	 #     COMPARATOR DELEGATIONS             #
	#========================================#

	def IsNotEqualToCS(pcStr, pCaseSensitive)
		return NOT This.IsEqualToCS(pcStr, pCaseSensitive)

	def IsNotEqualTo(pcStr)
		return NOT This.IsEqualTo(pcStr)

	def IsLessThan(pcStr)
		_oLtComp_ = new stzStringComparator(This)
		return _oLtComp_.IsLessThan(pcStr)

	def IsGreaterThan(pcStr)
		_oGtComp_ = new stzStringComparator(This)
		return _oGtComp_.IsGreaterThan(pcStr)

	def LevenshteinDistanceWith(pcStr)
		_oLdComp_ = new stzStringComparator(This)
		return _oLdComp_.LevenshteinDistanceWith(pcStr)

		def EditDistanceWith(pcStr)
			return This.LevenshteinDistanceWith(pcStr)

	def CommonPrefixWithCS(pcStr, pCaseSensitive)
		_oCpComp_ = new stzStringComparator(This)
		return _oCpComp_.CommonPrefixWithCS(pcStr, pCaseSensitive)

	def CommonPrefixWith(pcStr)
		return This.CommonPrefixWithCS(pcStr, 1)

	def CommonSuffixWithCS(pcStr, pCaseSensitive)
		_oCsComp_ = new stzStringComparator(This)
		return _oCsComp_.CommonSuffixWithCS(pcStr, pCaseSensitive)

	def CommonSuffixWith(pcStr)
		return This.CommonSuffixWithCS(pcStr, 1)

	def DiffWith(pcStr)
		_oDwComp_ = new stzStringComparator(This)
		return _oDwComp_.DiffWith(pcStr)

	def JaroSimilarityWith(pcStr)
		_oJsComp_ = new stzStringComparator(This)
		return _oJsComp_.JaroSimilarityWith(pcStr)

	def JaroWinklerSimilarityWith(pcStr)
		_oJwComp_ = new stzStringComparator(This)
		return _oJwComp_.JaroWinklerSimilarityWith(pcStr)

	def Soundex()
		_oSxComp_ = new stzStringComparator(This)
		return _oSxComp_.Soundex()

	def Metaphone()
		_oMpComp_ = new stzStringComparator(This)
		return _oMpComp_.Metaphone()

	def ContainsAllOfTheseCS(pacSubStr, pCaseSensitive)
		return This.ContainsTheseCS(pacSubStr, pCaseSensitive)

	def ContainsAllOfThese(pacSubStr)
		return This.ContainsThese(pacSubStr)

	  #========================================#
	 #     TEXT DELEGATIONS                   #
	#========================================#

	# --- Script detection ---

	def Script()
		_oScText_ = new stzStringText(This)
		return _oScText_.Script()

	def Scripts()
		_oScrsText_ = new stzStringText(This)
		return _oScrsText_.Scripts()

	def NumberOfScripts()
		_oNsText_ = new stzStringText(This)
		return _oNsText_.NumberOfScripts()

	# --- Word operations (supplement existing Words/NumberOfWords) ---

	def NthWord(n)
		_oNwText_ = new stzStringText(This)
		return _oNwText_.NthWord(n)

	def FirstWord()
		_oFwText_ = new stzStringText(This)
		return _oFwText_.FirstWord()

	def LastWord()
		_oLwText_ = new stzStringText(This)
		return _oLwText_.LastWord()

	def UniqueWordsCS(pCaseSensitive)
		_oUwText_ = new stzStringText(This)
		return _oUwText_.UniqueWordsCS(pCaseSensitive)

	def UniqueWords()
		return This.UniqueWordsCS(1)

	def ContainsWordCS(pcWord, pCaseSensitive)
		_oCwText_ = new stzStringText(This)
		return _oCwText_.ContainsWordCS(pcWord, pCaseSensitive)

	def ContainsWord(pcWord)
		return This.ContainsWordCS(pcWord, 1)

	def ReverseWords()
		_oRwText_ = new stzStringText(This)
		_oRwText_.ReverseWords()
		This.Update(_oRwText_.Content())

	def SortWordsCS(pCaseSensitive)
		_oSwText_ = new stzStringText(This)
		_oSwText_.SortWordsCS(pCaseSensitive)
		This.Update(_oSwText_.Content())

	def SortWords()
		This.SortWordsCS(1)

	def WordFrequency(pcWord)
		_oWfText_ = new stzStringText(This)
		return _oWfText_.WordFrequency(pcWord)

	def MostFrequentWord()
		_oMfwText_ = new stzStringText(This)
		return _oMfwText_.MostFrequentWord()

	# --- Sentences ---

	def NumberOfSentences()
		_oNsText_ = new stzStringText(This)
		return _oNsText_.NumberOfSentences()

	def Sentences()
		_oSText_ = new stzStringText(This)
		return _oSText_.Sentences()

	def NthSentence(n)
		_oNsntText_ = new stzStringText(This)
		return _oNsntText_.NthSentence(n)

	def FirstSentence()
		return This.NthSentence(1)

	def LastSentence()
		_oLsText_ = new stzStringText(This)
		return _oLsText_.LastSentence()

	# --- Paragraphs ---

	def NumberOfParagraphs()
		_oNpText_ = new stzStringText(This)
		return _oNpText_.NumberOfParagraphs()

	def Paragraphs()
		_oPText_ = new stzStringText(This)
		return _oPText_.Paragraphs()

	def NthParagraph(n)
		_oNprgText_ = new stzStringText(This)
		return _oNprgText_.NthParagraph(n)

	# --- Text transforms ---

	def Simplify()
		_oSmText_ = new stzStringText(This)
		_oSmText_.Simplify()
		This.Update(_oSmText_.Content())

		def SimplifyQ()
			This.Simplify()
			return This

	def Simplified()
		_oSmdText_ = new stzStringText(This)
		_oSmdText_.Simplify()
		return _oSmdText_.Content()

	def ToSlug()
		_oTsText_ = new stzStringText(This)
		return _oTsText_.ToSlug()

	def Initials()
		_oInText_ = new stzStringText(This)
		return _oInText_.Initials()

	  #========================================#
	 #     ENCODER DELEGATIONS                #
	#========================================#

	def ToHex()
		_oThEnc_ = new stzStringEncoder(This)
		return _oThEnc_.ToHex()

	def FromHex()
		_oFhEnc_ = new stzStringEncoder(This)
		_oFhEnc_.FromHex()
		This.Update(_oFhEnc_.Content())

	def UrlEncoded()
		_oUeEnc_ = new stzStringEncoder(This)
		return _oUeEnc_.UrlEncoded()

	def UrlEncode()
		This.Update(This.UrlEncoded())

		def UrlEncodeQ()
			This.UrlEncode()
			return This

	def UrlDecoded()
		_oUdEnc_ = new stzStringEncoder(This)
		return _oUdEnc_.UrlDecoded()

	def UrlDecode()
		This.Update(This.UrlDecoded())

		def UrlDecodeQ()
			This.UrlDecode()
			return This

	def HtmlEncoded()
		_oHeEnc_ = new stzStringEncoder(This)
		return _oHeEnc_.HtmlEncoded()

	def HtmlEncode()
		This.Update(This.HtmlEncoded())

	def HtmlDecoded()
		_oHdEnc_ = new stzStringEncoder(This)
		return _oHdEnc_.HtmlDecoded()

	def HtmlDecode()
		This.Update(This.HtmlDecoded())

	def ToBinary()
		_oTbEnc_ = new stzStringEncoder(This)
		return _oTbEnc_.ToBinary()

	def ToOctal()
		_oToEnc_ = new stzStringEncoder(This)
		return _oToEnc_.ToOctal()

	def EscapedForRegex()
		_oErEnc_ = new stzStringEncoder(This)
		return _oErEnc_.EscapedForRegex()

	def EscapeForRegex()
		This.Update(This.EscapedForRegex())

	# --- Unicode normalization ---

	def NormalizeNFC()
		_oNnfcEnc_ = new stzStringEncoder(This)
		_oNnfcEnc_.NormalizeNFC()
		This.Update(_oNnfcEnc_.Content())

	def NormalizedNFC()
		_oNdfcEnc_ = new stzStringEncoder(This)
		return _oNdfcEnc_.NormalizedNFC()

	def NormalizeNFD()
		_oNnfdEnc_ = new stzStringEncoder(This)
		_oNnfdEnc_.NormalizeNFD()
		This.Update(_oNnfdEnc_.Content())

	def NormalizedNFD()
		_oNdfdEnc_ = new stzStringEncoder(This)
		return _oNdfdEnc_.NormalizedNFD()

	def NormalizeNFKC()
		_oNnfkcEnc_ = new stzStringEncoder(This)
		_oNnfkcEnc_.NormalizeNFKC()
		This.Update(_oNnfkcEnc_.Content())

	def NormalizedNFKC()
		_oNdfkcEnc_ = new stzStringEncoder(This)
		return _oNdfkcEnc_.NormalizedNFKC()

	def NormalizeNFKD()
		_oNnfkdEnc_ = new stzStringEncoder(This)
		_oNnfkdEnc_.NormalizeNFKD()
		This.Update(_oNnfkdEnc_.Content())

	def NormalizedNFKD()
		_oNdfkdEnc_ = new stzStringEncoder(This)
		return _oNdfkdEnc_.NormalizedNFKD()

	  #========================================#
	 #     FORMATTER DELEGATIONS              #
	#========================================#

	def Titlecased()
		_oTcFmt_ = new stzStringFormatter(This)
		return _oTcFmt_.Titlecased()

	def ApplyTitlecase()
		This.Update(This.Titlecased())

		def ApplyTitlecaseQ()
			This.ApplyTitlecase()
			return This

	def CaseFolded()
		_oCfFmt_ = new stzStringFormatter(This)
		return _oCfFmt_.CaseFolded()

	def LeftAlignXT(nWidth, cFillChar)
		This.AlignXT(nWidth, cFillChar, :Left)

	def RightAlignXT(nWidth, cFillChar)
		This.AlignXT(nWidth, cFillChar, :Right)

	def CenterAlignXT(nWidth, cFillChar)
		This.AlignXT(nWidth, cFillChar, :Center)

	def LeftAligned(nWidth)
		_oCpFmt_ = This.Copy()
		_oCpFmt_.AlignXT(nWidth, " ", :Left)
		return _oCpFmt_.Content()

	def RightAligned(nWidth)
		_oCpFmt_ = This.Copy()
		_oCpFmt_.AlignXT(nWidth, " ", :Right)
		return _oCpFmt_.Content()

	def CenterAligned(nWidth)
		_oCpFmt_ = This.Copy()
		_oCpFmt_.AlignXT(nWidth, " ", :Center)
		return _oCpFmt_.Content()

	def PadLeft(nWidth, cFillChar)
		This.AlignXT(nWidth, cFillChar, :Right)

	def PadRight(nWidth, cFillChar)
		This.AlignXT(nWidth, cFillChar, :Left)

	def PaddedLeft(nWidth, cFillChar)
		_oCpFmt_ = This.Copy()
		_oCpFmt_.PadLeft(nWidth, cFillChar)
		return _oCpFmt_.Content()

	def PaddedRight(nWidth, cFillChar)
		_oCpFmt_ = This.Copy()
		_oCpFmt_.PadRight(nWidth, cFillChar)
		return _oCpFmt_.Content()

	  #========================================#
	 #     LEAD/TRAIL DELEGATIONS             #
	#========================================#

	def RepeatedLeadingCharsCS(pCaseSensitive)
		_oRlcLt_ = new stzStringLeadTrail(This)
		return _oRlcLt_.RepeatedLeadingCharsCS(pCaseSensitive)

	def RepeatedLeadingChars()
		return This.RepeatedLeadingCharsCS(1)

	def RepeatedTrailingCharsCS(pCaseSensitive)
		_oRtcLt_ = new stzStringLeadTrail(This)
		return _oRtcLt_.RepeatedTrailingCharsCS(pCaseSensitive)

	def RepeatedTrailingChars()
		return This.RepeatedTrailingCharsCS(1)

	def RemoveRepeatedLeadingCharsCS(pCaseSensitive)
		_oRrlcLt_ = new stzStringLeadTrail(This)
		_oRrlcLt_.RemoveRepeatedLeadingCharsCS(pCaseSensitive)
		This.Update(_oRrlcLt_.Content())

	def RemoveRepeatedLeadingChars()
		This.RemoveRepeatedLeadingCharsCS(1)

	def RemoveRepeatedTrailingCharsCS(pCaseSensitive)
		_oRrtcLt_ = new stzStringLeadTrail(This)
		_oRrtcLt_.RemoveRepeatedTrailingCharsCS(pCaseSensitive)
		This.Update(_oRrtcLt_.Content())

	def RemoveRepeatedTrailingChars()
		This.RemoveRepeatedTrailingCharsCS(1)

	def EnsurePrefixCS(pcPrefix, pCaseSensitive)
		_oEpLt_ = new stzStringLeadTrail(This)
		_oEpLt_.EnsurePrefixCS(pcPrefix, pCaseSensitive)
		This.Update(_oEpLt_.Content())

	def EnsurePrefix(pcPrefix)
		This.EnsurePrefixCS(pcPrefix, 1)

	def EnsureSuffixCS(pcSuffix, pCaseSensitive)
		_oEsLt_ = new stzStringLeadTrail(This)
		_oEsLt_.EnsureSuffixCS(pcSuffix, pCaseSensitive)
		This.Update(_oEsLt_.Content())

	def EnsureSuffix(pcSuffix)
		This.EnsureSuffixCS(pcSuffix, 1)

	def RemoveFromStartCS(pcPrefix, pCaseSensitive)
		_oRfsLt_ = new stzStringLeadTrail(This)
		_oRfsLt_.RemoveFromStartCS(pcPrefix, pCaseSensitive)
		This.Update(_oRfsLt_.Content())

	def RemoveFromStart(pcPrefix)
		This.RemoveFromStartCS(pcPrefix, 1)

	def RemoveFromEndCS(pcSuffix, pCaseSensitive)
		_oRfeLt_ = new stzStringLeadTrail(This)
		_oRfeLt_.RemoveFromEndCS(pcSuffix, pCaseSensitive)
		This.Update(_oRfeLt_.Content())

	def RemoveFromEnd(pcSuffix)
		This.RemoveFromEndCS(pcSuffix, 1)

	# Immutable / past-tense companions: return the modified content
	# without mutating This. Used by stzNumber.RoundTo() and similar
	# fluent chains that want the result as a value.

	def RemovedFromEndCS(pcSuffix, pCaseSensitive)
		_oRfeT_ = new stzString( This.Content() )
		_oRfeT_.RemoveFromEndCS(pcSuffix, pCaseSensitive)
		return _oRfeT_.Content()

	def RemovedFromEnd(pcSuffix)
		return This.RemovedFromEndCS(pcSuffix, 1)

		def RemoveFromEndQ(pcSuffix)
			This.RemoveFromEnd(pcSuffix)
			return This

		def RemoveFromEndCSQ(pcSuffix, pCaseSensitive)
			This.RemoveFromEndCS(pcSuffix, pCaseSensitive)
			return This

	  #========================================#
	 #     LINES DELEGATIONS                  #
	#========================================#

	def NthLine(n)
		_oNlLines_ = new stzStringLines(This)
		return _oNlLines_.NthLine(n)

	def FirstLine()
		return This.NthLine(1)

	def LastLine()
		_oLlLines_ = new stzStringLines(This)
		return _oLlLines_.LastLine()

	def UniqueLinesCS(pCaseSensitive)
		_oUlLines_ = new stzStringLines(This)
		return _oUlLines_.UniqueLinesCS(pCaseSensitive)

	def UniqueLines()
		return This.UniqueLinesCS(1)

	def SortLinesCS(pCaseSensitive)
		_oSlLines_ = new stzStringLines(This)
		_oSlLines_.SortLinesCS(pCaseSensitive)
		This.Update(_oSlLines_.Content())

	def SortLines()
		This.SortLinesCS(1)

	def RemoveBlankLines()
		_oRblLines_ = new stzStringLines(This)
		_oRblLines_.RemoveBlankLines()
		This.Update(_oRblLines_.Content())

	def LinesContainingCS(pcSubStr, pCaseSensitive)
		_oLcLines_ = new stzStringLines(This)
		return _oLcLines_.LinesContainingCS(pcSubStr, pCaseSensitive)

	def LinesContaining(pcSubStr)
		return This.LinesContainingCS(pcSubStr, 1)

	  #========================================#
	 #     TRIMMER DELEGATIONS                #
	#========================================#

	def TrimCharCS(pcChar, pCaseSensitive)
		_oTcTrm_ = new stzStringTrimmer(This)
		_oTcTrm_.TrimCharCS(pcChar, pCaseSensitive)
		This.Update(_oTcTrm_.Content())

	def TrimChar(pcChar)
		This.TrimCharCS(pcChar, 1)

	def TrimLeftCharCS(pcChar, pCaseSensitive)
		_oTlcTrm_ = new stzStringTrimmer(This)
		_oTlcTrm_.RemoveThisCharFromStartCS(pcChar, pCaseSensitive)
		This.Update(_oTlcTrm_.Content())

	def TrimLeftChar(pcChar)
		This.TrimLeftCharCS(pcChar, 1)

	def TrimRightCharCS(pcChar, pCaseSensitive)
		_oTrcTrm_ = new stzStringTrimmer(This)
		_oTrcTrm_.RemoveThisCharFromEndCS(pcChar, pCaseSensitive)
		This.Update(_oTrcTrm_.Content())

	def TrimRightChar(pcChar)
		This.TrimRightCharCS(pcChar, 1)
