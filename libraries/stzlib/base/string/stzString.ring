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

	def LastChar()
		return This.NthChar(This.NumberOfChars())

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
		if NOT isString(pcNewSubStr)
			StzRaise("ReplaceSection: pcNewSubStr must be a string")
		ok
		_cStr_ = This.Content()
		_nLen_ = len(_cStr_)
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
		nLen = len(aSections)
		for i = 1 to nLen
			n1 = aSections[i][1]
			n2 = aSections[i][2]
			if n1 >= 1 and n2 >= n1 and n2 <= nCharCount
				acResult + This.Section(n1, n2)
			ok
		next
		return acResult

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
			for _item_ in paList
				if isString(_item_) and _item_ = _s_
					return 1
				ok
			next
		else
			_sl_ = lower(_s_)
			for _item_ in paList
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
		if nStart >= len(_cFull_)
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
		_nNcaLen_ = len(_cNcaStr_)
		_nNcaSubLen_ = len(pcSubStr)
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

	def Numbers()
		_acResult_ = []
		_acChars_ = This.Chars()
		_nLen_ = len(_acChars_)
		_cCurrentNum_ = ""
		_bInNumber_ = 0
		_nLenCurrentNum_ = 0
		_nLenTemp_ = 0

		for i = 1 to _nLen_
			_nLenCurrentNum_ = len(_cCurrentNum_)
			if ring_find([ "0","1","2","3","4","5","6","7","8","9" ], _acChars_[i]) > 0 or
			   (_acChars_[i] = "." and _nLenCurrentNum_ > 0) or
			   (_acChars_[i] = "-" and _nLenCurrentNum_ = 0)

				_cCurrentNum_ += _acChars_[i]
				_bInNumber_ = 1
			else
				if _bInNumber_
					_nLenTemp_ = len(_acResult_)
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
			_nLen_ = len(_acResult_)
			if _nLen_ > 0 and _acResult_[_nLen_] = "-"
				_acResult_[_nLen_] = "-" + _cCurrentNum_
			else
				_acResult_ + _cCurrentNum_
			ok
		ok

		return _acResult_

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
		if len(_cEwanStr_) = 0
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
		if len(_cSwanStr_) = 0
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
		nLen = len(aSections)
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
		nLen = len(aSections)
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
		return len(This.DuplicatedSubStringsCS(pCaseSensitive)) > 0

	def ContainsDuplicatedSubStrings()
		return This.ContainsDuplicatedSubStringsCS(1)

	def DuplicatedSubStringsCS(pCaseSensitive)
		_oDsDup_ = new stzStringDuplicates(This)
		return _oDsDup_.DuplicatedChars()

	def DuplicatedSubStrings()
		return This.DuplicatedSubStringsCS(1)

	def NumberOfDuplicatesCS(pCaseSensitive)
		return len(This.DuplicatedSubStringsCS(pCaseSensitive))

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
			_nBxLen_ = len(paBoxOptions)
			for _iBx_ = 1 to _nBxLen_
				if isList(paBoxOptions[_iBx_]) and len(paBoxOptions[_iBx_]) = 2
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

	def Unicodes()
		_aUcChars_ = This.Chars()
		_aUcResult_ = []
		_nUcLen_ = len(_aUcChars_)
		for _iUc_ = 1 to _nUcLen_
			_aUcResult_ + StzCharToUnicode(_aUcChars_[_iUc_])
		next
		return _aUcResult_

	def CharsAndUnicodes()
		_aCauChars_ = This.Chars()
		_aCauResult_ = []
		_nCauLen_ = len(_aCauChars_)
		for _iCau_ = 1 to _nCauLen_
			_aCauResult_ + [ _aCauChars_[_iCau_], StzCharToUnicode(_aCauChars_[_iCau_]) ]
		next
		return _aCauResult_

		def UnicodePerChar()
			return This.CharsAndUnicodes()

	def CharsAndUnicodesU()
		_aCauuChars_ = This.CharsU()
		_aCauuResult_ = []
		_nCauuLen_ = len(_aCauuChars_)
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

	def RemoveLastChar()
		_cRlcContent_ = This.Content()
		_nRlcLen_ = StzLen(_cRlcContent_)
		if _nRlcLen_ > 0
			This.Update(StzLeft(_cRlcContent_, _nRlcLen_ - 1))
		ok

	def RemoveFirstAndLastChars()
		This.RemoveFirstChar()
		This.RemoveLastChar()

		def RemoveFirstAndLastCharsQ()
			This.RemoveFirstAndLastChars()
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
		_nRtbLen_ = len(_aRtbPos_)
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
		if NOT (isList(pacBounds) and len(pacBounds) = 2)
			StzRaise("BoundedByCS: pacBounds must be a 2-list [ open, close ]")
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
		if isList(paNewSubStr) and len(paNewSubStr) > 0
			if isString(paNewSubStr[1]) and
			   (paNewSubStr[1] = :by or paNewSubStr[1] = :with or paNewSubStr[1] = :By or paNewSubStr[1] = :With)
				paNewSubStr = paNewSubStr[2]
			ok
		ok

		_nRmbmLen_ = len(paSubStr)
		_nRmbmNewLen_ = len(paNewSubStr)

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
		if isList(paNewSubStr) and len(paNewSubStr) > 0
			if isString(paNewSubStr[1]) and
			   (paNewSubStr[1] = :by or paNewSubStr[1] = :with or paNewSubStr[1] = :By or paNewSubStr[1] = :With)
				paNewSubStr = paNewSubStr[2]
			ok
		ok

		_nRmbmxtLen_ = len(paSubStr)
		_nRmbmxtNewLen_ = len(paNewSubStr)

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
		_oFasFinder_ = new stzStringFinder(This)
		return _oFasFinder_.FindAsSectionsCS(pcSubStr, pCaseSensitive)

	def FindAsSections(pcSubStr)
		return This.FindAsSectionsCS(pcSubStr, 1)

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

	def RemoveMany(pacSubStrings)
		This.RemoveManyCS(pacSubStrings, 1)

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
		for _aInCi_ in LocaleCountriesXT()
			if lower(_aInCi_[2]) = lower(_cInName_)
				return 1
			ok
		next
		return 0

	def IsCountryAbbreviation()
		if This.IsEmpty() return 0 ok
		_cInAbbr_ = This.String()
		for _aInCi_ in LocaleCountriesXT()
			if upper(_aInCi_[3]) = upper(_cInAbbr_) or
			   upper(_aInCi_[4]) = upper(_cInAbbr_)
				return 1
			ok
		next
		return 0

	def IsCountryNumber()
		if This.IsEmpty() return 0 ok
		_cInNum_ = This.String()
		for _aInCi_ in LocaleCountriesXT()
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
		for _aInCi_ in LocaleCountriesXT()
			if _aInCi_[5] = _cInPc_
				return 1
			ok
		next
		return 0

	def IsLanguageName()
		if This.IsEmpty() return 0 ok
		_cInLn_ = This.String()
		for _aInLi_ in LocaleLanguagesXT()
			if lower(_aInLi_[2]) = lower(_cInLn_)
				return 1
			ok
		next
		return 0

	def IsLanguageNumber()
		if This.IsEmpty() return 0 ok
		_cInLnm_ = This.String()
		for _aInLi_ in LocaleLanguagesXT()
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
		for _aInLi_ in LocaleLanguagesXT()
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
		for _aInCx_ in CurrenciesXT()
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
		for _aInSi_ in LocaleScriptsXT()
			if lower(_aInSi_[2]) = _cInSn_
				return 1
			ok
		next
		return 0

	def IsScriptCode()
		if This.IsEmpty() return 0 ok
		_cInScode_ = This.String()
		for _aInSi_ in LocaleScriptsXT()
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
		for _aInSi_ in LocaleScriptsXT()
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

	def SubStringsCS(pCaseSensitive)
		_oSsFinder_ = new stzStringFinder(This)
		return _oSsFinder_.SubStringsCS(pCaseSensitive)

	def SubStrings()
		return This.SubStringsCS(1)

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

	# --- FindBoundedByAsSections ---

	def FindBoundedByAsSectionsCS(pacBounds, pCaseSensitive)
		_oFbbasFinder_ = new stzStringFinder(This)
		return _oFbbasFinder_.FindBoundedByAsSectionsCS(pacBounds, pCaseSensitive)

	def FindBoundedByAsSections(pacBounds)
		return This.FindBoundedByAsSectionsCS(pacBounds, 1)

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

	#-- RemoveThisTrailingChar: strip repeated trailing occurrences
	#   of a single given char. "abc!!" + RemoveThisTrailingChar("!")
	#   -> "abc". Ported from the legacy monolithic archive
	#   (~line 27306-27389); standalone byte-level implementation that
	#   avoids cascading dependencies on FindRepeatedTrailingChars*.

	def RemoveThisTrailingChar(c)
		if NOT isString(c)
			StzRaise("RemoveThisTrailingChar: c must be a string")
		ok
		if len(c) = 0
			return
		ok
		_cStr_ = This.Content()
		_nLen_ = len(_cStr_)
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
		if len(c) = 0
			return
		ok
		_cStr_ = This.Content()
		while len(_cStr_) > 0 and left(_cStr_, 1) = c
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
