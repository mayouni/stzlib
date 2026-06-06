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
		_nPos_ = substr(_cTxt_, pcSub)
		if _nPos_ = 0 return [] ok
		_nLenSub_ = ring_len(pcSub)
		_cBefore_ = left(_cTxt_, _nPos_ - 1)
		_cAfter_  = substr(_cTxt_, _nPos_ + _nLenSub_)
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
		if ring_len(_cBefore_) > _nBefore_ _cBefore_ = right(_cBefore_, _nBefore_) ok
		if ring_len(_cAfter_)  > _nAfter_  _cAfter_  = left(_cAfter_, _nAfter_)    ok
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
		if ring_len(_cBefore_) > nBefore _cBefore_ = right(_cBefore_, nBefore) ok
		if ring_len(_cAfter_)  > nAfter  _cAfter_  = left(_cAfter_, nAfter)   ok
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

	def Section(n1, n2)
		nLen = This.NumberOfChars()
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
		_nLen_ = ring_len(_cStr_)
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
			_cBefore_ = substr(_cStr_, 1, n1 - 1)
		ok
		_cAfter_ = ""
		if n2 < _nLen_
			_cAfter_ = substr(_cStr_, n2 + 1)
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
	def ContainsXT(pVal)
		if isString(pVal)
			return This.Contains(pVal)
		but isList(pVal)
			_nVal1Len_ = ring_len(pVal)
			for _iLoopVal1_ = 1 to _nVal1Len_
				_xCxItem_ = pVal[_iLoopVal1_]
				if isString(_xCxItem_) and This.Contains(_xCxItem_)
					return 1
				ok
			next
			return 0
		ok
		return 0

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
		if ring_len(_cStr_) <= n
			return _cStr_
		ok
		return substr(_cStr_, 1, n - 3) + "..."

		def Shortened()
			return This.ShortenedN(30)

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
		_nSubLen_ = ring_len(pcSubStr)
		_cOut_ = ""
		_nPos_ = 1
		_iRep_ = 1
		_nFound_ = substr(_cTxt_, pcSubStr, _nPos_)
		while _nFound_ > 0
			_cOut_ += substr(_cTxt_, _nPos_, _nFound_ - _nPos_)
			_cOut_ += paReplacements[_iRep_]
			_iRep_++
			if _iRep_ > _nRepLen_ _iRep_ = 1 ok
			_nPos_ = _nFound_ + _nSubLen_
			_nFound_ = substr(_cTxt_, pcSubStr, _nPos_)
		end
		_cOut_ += substr(_cTxt_, _nPos_)
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
		_nOpenLen_ = ring_len(_aOpen_)
		_nCloseLen_ = ring_len(_aClose_)
		_nStart_ = substr(_cTxt_, _aOpen_)
		while _nStart_ > 0
			_nInsideStart_ = _nStart_ + _nOpenLen_
			_nEnd_ = substr(_cTxt_, _aClose_, _nInsideStart_)
			if _nEnd_ = 0 exit ok
			_cBefore_ = left(_cTxt_, _nInsideStart_ - 1)
			_cAfter_  = substr(_cTxt_, _nEnd_)
			_cTxt_ = _cBefore_ + pcNew + _cAfter_
			_nStart_ = substr(_cTxt_, _aOpen_, _nInsideStart_ + ring_len(pcNew))
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
		_nOpenLen_ = ring_len(_aOpen_)
		_nWhatLen_ = ring_len(pcWhat)
		_nStart_ = substr(_cTxt_, _aOpen_)
		while _nStart_ > 0
			_nInsideStart_ = _nStart_ + _nOpenLen_
			_nEnd_ = substr(_cTxt_, _aClose_, _nInsideStart_)
			if _nEnd_ = 0 exit ok
			# Look for pcWhat strictly inside [_nInsideStart_, _nEnd_-1]
			_nWFound_ = substr(_cTxt_, pcWhat, _nInsideStart_)
			while _nWFound_ > 0 and _nWFound_ < _nEnd_
				_cBefore_ = left(_cTxt_, _nWFound_ - 1)
				_cAfter_  = substr(_cTxt_, _nWFound_ + _nWhatLen_)
				_cTxt_ = _cBefore_ + pcNew + _cAfter_
				_nEnd_ += ring_len(pcNew) - _nWhatLen_
				_nWFound_ = substr(_cTxt_, pcWhat, _nWFound_ + ring_len(pcNew))
			end
			# Move past this bounded section so we don't re-match.
			_nStart_ = substr(_cTxt_, _aOpen_, _nEnd_ + ring_len(_aClose_))
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
			_nOpenLenIB_ = ring_len(_aOpenIB_)
			_nCloseLenIB_ = ring_len(_aCloseIB_)
			_nStartIB_ = substr(_cTxtIB_, _aOpenIB_)
			while _nStartIB_ > 0
				_nInsideIB_ = _nStartIB_ + _nOpenLenIB_
				_nEndIB_ = substr(_cTxtIB_, _aCloseIB_, _nInsideIB_)
				if _nEndIB_ = 0 exit ok
				_cInsideIB_ = substr(_cTxtIB_, _nInsideIB_, _nEndIB_ - _nInsideIB_)
				if substr(_cInsideIB_, pcWhat) > 0
					_cBeforeIB_ = left(_cTxtIB_, _nStartIB_ - 1)
					_cAfterIB_  = substr(_cTxtIB_, _nEndIB_ + _nCloseLenIB_)
					_cTxtIB_ = _cBeforeIB_ + pcNew + _cAfterIB_
					_nStartIB_ = substr(_cTxtIB_, _aOpenIB_, _nStartIB_ + ring_len(pcNew))
				else
					_nStartIB_ = substr(_cTxtIB_, _aOpenIB_, _nEndIB_ + _nCloseLenIB_)
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
		_nOldLen_ = ring_len(pcOld)
		if n < 1 or n + _nOldLen_ - 1 > ring_len(_cTxt_) return ok
		if substr(_cTxt_, n, _nOldLen_) != pcOld return ok
		_cBefore_ = left(_cTxt_, n - 1)
		_cAfter_  = substr(_cTxt_, n + _nOldLen_)
		This.Update(_cBefore_ + pcNew + _cAfter_)

		def ReplaceSubStringAtPositionQ(n, pcOld, pcNew)
			This.ReplaceSubStringAtPosition(n, pcOld, pcNew)
			return This

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
				_aPos_ = _xAnchorV_ + []
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
				_nStart_ = substr(_cTxt_, _aOpen_)
				while _nStart_ > 0
					_nEnd_ = substr(_cTxt_, _aClose_, _nStart_ + ring_len(_aOpen_))
					if _nEnd_ = 0 exit ok
					_cBefore_ = left(_cTxt_, _nStart_ - 1)
					_cAfter_  = substr(_cTxt_, _nEnd_ + ring_len(_aClose_))
					_cTxt_ = _cBefore_ + _aOpen_ + _pWith_ + _aClose_ + _cAfter_
					_nStart_ = substr(_cTxt_, _aOpen_, _nStart_ + ring_len(_aOpen_ + _pWith_ + _aClose_))
				end
				This.Update(_cTxt_)
				return
			ok
		ok

		StzRaise("ReplaceXT: unsupported argument shape.")

		def ReplaceXTQ(p1, p2, p3)
			This.ReplaceXT(p1, p2, p3)
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
		_cTxt_ = This.Content()
		_nLen_ = ring_len(_cTxt_)
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
				_cOut_ = _cTxt_[_i_] + _cOut_
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
				_cOut_ += _cTxt_[_i_]
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
		StzEngineStringInsertCp(@pEngine, n, pcSubStr)

		def InsertBeforeQ(n, pcSubStr)
			This.InsertBefore(n, pcSubStr)
			return This

		def InsertBeforePosition(n, pcSubStr)
			This.InsertBefore(n, pcSubStr)

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
		_nLenTxt_ = ring_len(_cTxt_)
		_nLenCh_ = ring_len(pcChar)
		_n_ = 0
		while _n_ + _nLenCh_ <= _nLenTxt_ and
		      substr(_cTxt_, _n_ + 1, _nLenCh_) = pcChar
			_n_ += _nLenCh_
		end
		if _n_ > 0
			This.Update(substr(_cTxt_, _n_ + 1))
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
		_nLenTxt_ = ring_len(_cTxt_)
		_nLenCh_ = ring_len(pcChar)
		_n_ = 0
		while _n_ + _nLenCh_ <= _nLenTxt_ and
		      substr(_cTxt_, _nLenTxt_ - _n_ - _nLenCh_ + 1, _nLenCh_) = pcChar
			_n_ += _nLenCh_
		end
		if _n_ > 0
			This.Update(substr(_cTxt_, 1, _nLenTxt_ - _n_))
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

		def ContainsEither(paSubStr)
			return This.ContainsOneOfThese(paSubStr)

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
		_nLen_ = ring_len(_cTxt_)
		_aRes_ = []
		for _i_ = 1 to _nLen_
			for _j_ = _i_ to _nLen_
				_aRes_ + substr(_cTxt_, _i_, _j_ - _i_ + 1)
			next
		next
		return _aRes_

	def NumberOfSubStrings()
		_n_ = ring_len(This.Content())
		return (_n_ * (_n_ + 1)) / 2

	def SubStringsCS(pCaseSensitive)
		_cTxt_ = This.Content()
		_nLen_ = ring_len(_cTxt_)
		_aRes_ = []
		_bCase_ = (pCaseSensitive = 1)
		for _i_ = 1 to _nLen_
			for _j_ = _i_ to _nLen_
				_s_ = substr(_cTxt_, _i_, _j_ - _i_ + 1)
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

	# Aliases: StartsWithOneOfThese{,CS} mirror the Softanza
	# universal naming when a list-of-candidates phrasing reads
	# more naturally than "Any".

	def StartsWithOneOfTheseCS(pcPrefixes, pCaseSensitive)
		return This.StartsWithAnyCS(pcPrefixes, pCaseSensitive)

	def StartsWithOneOfThese(pcPrefixes)
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

		def FindBetweenAsSections(pcBound1, pcBound2)
			return This.FindBetweenAsSectionCS(pcBound1, pcBound2, 1)

	# --- FindBoundedByAsSections ---

	def FindBoundedByAsSectionsCS(pacBounds, pCaseSensitive)
		_oFbbasFinder_ = new stzStringFinder(This)
		return _oFbbasFinder_.FindBoundedByAsSectionsCS(pacBounds, pCaseSensitive)

	def FindBoundedByAsSections(pacBounds)
		return This.FindBoundedByAsSectionsCS(pacBounds, 1)

		def FindAnyBoundedByAsSections(pacBounds)
			return This.FindBoundedByAsSections(pacBounds)

		def FindAnyBoundedBy(pacBounds)
			return This.BoundedBy(pacBounds)

		# Inclusive-bounds variant: return sections that include the
		# bounds themselves (so [startOfOpen .. endOfClose]).
		def FindAnyBoundedByIB(pacBounds)
			return This.FindSubStringsBoundedByIBZZ(pacBounds)

		def FindBoundedByIB(pacBounds)
			return This.FindSubStringsBoundedByIBZZ(pacBounds)

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
		_oSbSplitter_ = new stzStringSplitter(This)
		return _oSbSplitter_.SplitBeforeCS(pcSubStr, pCaseSensitive)

	def SplitBefore(pcSubStr)
		return This.SplitBeforeCS(pcSubStr, 1)

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
		_bFstCase_ = @CaseSensitive(pCaseSensitive)
		return This._FindSubStr(pcSubStr, nStartAt, _bFstCase_)

	def FindFirstST(pcSubStr, nStartAt)
		return This.FindFirstSTCS(pcSubStr, nStartAt, 1)

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
