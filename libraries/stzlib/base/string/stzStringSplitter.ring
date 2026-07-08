#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGSPLITTER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String splitter -- splitting operations     #
#                  at positions, substrings, sections,         #
#                  before/after/around.                        #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringSplitterXT.       #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringSplitter from stzObject

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringSplitter! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #====================================#
	 #     SPLIT -- MAIN ENTRY POINT      #
	#====================================#

	def SplitCS(pSubStrOrPos, pCaseSensitive)

		if isList(pSubStrOrPos) and len(pSubStrOrPos) = 2 and isString(pSubStrOrPos[1])
			cParamName = StzCaseFold(pSubStrOrPos[1])

			if cParamName = "with" or cParamName = "by" or cParamName = "using"
				return This.SplitAtCS(pSubStrOrPos[2], pCaseSensitive)

			but cParamName = "at"
				return This.SplitAtCS(pSubStrOrPos[2], pCaseSensitive)

			but cParamName = "atposition"
				return This.SplitAtPosition(pSubStrOrPos[2])

			but cParamName = "atpositions"
				return This.SplitAtPositions(pSubStrOrPos[2])

			but cParamName = "before"
				return This.SplitBeforeCS(pSubStrOrPos[2], pCaseSensitive)

			but cParamName = "after"
				return This.SplitAfterCS(pSubStrOrPos[2], pCaseSensitive)

			but cParamName = "around"
				return This.SplitAroundCS(pSubStrOrPos[2], pCaseSensitive)

			ok
		ok

		return This.SplitAtCS(pSubStrOrPos, pCaseSensitive)

	def SplittedCS(pSubStrOrPos, pCaseSensitive)
		return This.SplitCS(pSubStrOrPos, pCaseSensitive)

	def Split(pSubStrOrPos)
		return This.SplitCS(pSubStrOrPos, 1)

	def Splitted(pSubStrOrPos)
		return This.Split(pSubStrOrPos)

	  #================================#
	 #     SPLIT AT -- DISPATCHER     #
	#================================#

	def SplitAtCS(pSubStrOrPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pSubStrOrPos)
			return This.SplitAtSubStringCS(pSubStrOrPos, pCaseSensitive)

		but isNumber(pSubStrOrPos)
			return This.SplitAtPosition(pSubStrOrPos)

		but isList(pSubStrOrPos) and IsListOfNumbers(pSubStrOrPos)
			return This.SplitAtPositions(pSubStrOrPos)

		but isList(pSubStrOrPos) and IsListOfStrings(pSubStrOrPos)
			return This.SplitAtSubStringsCS(pSubStrOrPos, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pSubStrOrPos must be position(s) or string(s).")
		ok

	def SplitAt(pSubStrOrPos)
		return This.SplitAtCS(pSubStrOrPos, 1)

	  #=================================#
	 #     SPLIT AT SUBSTRING          #
	#=================================#

	def SplitAtSubStringCS(pcSubStr, pCaseSensitive)
		if CheckingParams()

			if This.IsEmpty()
				return []
			ok

			if isList(pcSubStr) and IsListOfStrings(pcSubStr)
				return This.SplitAtSubStringsCS(pcSubStr, pCaseSensitive)
			ok

			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok

		ok

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		return @oString._SplitByStrCS(pcSubStr, pCaseSensitive)

	def SplitAtSubString(pcSubStr)
		return This.SplitAtSubStringCS(pcSubStr, 1)

	  #===================================#
	 #     SPLIT AT MULTIPLE SUBSTRINGS  #
	#===================================#

	def SplitAtSubStringsCS(pacSubStrings, pCaseSensitive)
		if NOT isList(pacSubStrings)
			StzRaise("Incorrect param type! pacSubStrings must be a list.")
		ok

		cResult = This.Content()
		cSep = "<<<SEP>>>"

		nLen = len(pacSubStrings)
		for i = 1 to nLen
			cResult = @ReplaceCS(cResult, pacSubStrings[i], cSep, pCaseSensitive)
		next

		return @SplitCS(cResult, cSep, 1)

	def SplitAtSubStrings(pacSubStrings)
		return This.SplitAtSubStringsCS(pacSubStrings, 1)

	  #===============================#
	 #     SPLIT AT POSITION         #
	#===============================#

	def SplitAtPosition(n)

		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if NOT ( n >= 1 and n <= This.NumberOfChars() )
			return [ This.Content() ]
		ok

		# Split at position n: [1..n-1] and [n+1..end]
		# (position n itself is excluded -- it's the split point)
		_nSapLen_ = This.NumberOfChars()
		_aSapResult_ = []

		if n > 1
			add(_aSapResult_, @oString.Section(1, n - 1))
		ok
		if n < _nSapLen_
			add(_aSapResult_, @oString.Section(n + 1, _nSapLen_))
		ok

		return _aSapResult_

	  #=================================#
	 #     SPLIT AT POSITIONS          #
	#=================================#

	def SplitAtPositions(anPos)

		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and IsListOfNumbers(anPos) )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		# Split at multiple positions (each position is excluded)
		_anSapsorted_ = sort(anPos)
		_nSapLen_ = This.NumberOfChars()
		_aSapResult_ = []
		_nSapPrev_ = 1

		_n_anSapsortedLen_ = len(_anSapsorted_)
		for _iSap_ = 1 to _n_anSapsortedLen_
			_nSapPos_ = _anSapsorted_[_iSap_]
			if _nSapPos_ >= _nSapPrev_ and _nSapPos_ <= _nSapLen_
				if _nSapPos_ > _nSapPrev_
					add(_aSapResult_, @oString.Section(_nSapPrev_, _nSapPos_ - 1))
				ok
				_nSapPrev_ = _nSapPos_ + 1
			ok
		next

		if _nSapPrev_ <= _nSapLen_
			add(_aSapResult_, @oString.Section(_nSapPrev_, _nSapLen_))
		ok

		return _aSapResult_

	  #===============================#
	 #     SPLIT BEFORE              #
	#===============================#

	def SplitBeforeCS(pSubStrOrPos, pCaseSensitive)

		if isNumber(pSubStrOrPos)
			return This.SplitBeforePosition(pSubStrOrPos)
		ok

		if isString(pSubStrOrPos)
			return This.SplitBeforeSubStringCS(pSubStrOrPos, pCaseSensitive)
		ok

		StzRaise("Incorrect param type!")

	def SplitBefore(pSubStrOrPos)
		return This.SplitBeforeCS(pSubStrOrPos, 1)

	def SplitBeforePosition(n)
		if This.IsEmpty()
			return []
		ok

		if n <= 1 or n > This.NumberOfChars()
			return [ This.Content() ]
		ok

		cPart1 = @oString.Section(1, n - 1)
		cPart2 = @oString.Section(n, @oString.NumberOfChars())

		return [ cPart1, cPart2 ]

	def SplitBeforeSubStringCS(pcSubStr, pCaseSensitive)
		oFinder = new stzStringFinder(@oString)
		anPos = oFinder.FindCS(pcSubStr, pCaseSensitive)
		if len(anPos) = 0
			return [ This.Content() ]
		ok
		return This.SplitBeforePositions(anPos)

	def SplitBeforeSubString(pcSubStr)
		return This.SplitBeforeSubStringCS(pcSubStr, 1)

	def SplitBeforePositions(anPos)
		if This.IsEmpty()
			return []
		ok

		# Split before each position: segments end at pos-1, next starts at pos
		_anSbpSorted_ = sort(anPos)
		_nSbpLen_ = This.NumberOfChars()
		_aSbpResult_ = []
		_nSbpPrev_ = 1

		_n_anSbpSortedLen_ = len(_anSbpSorted_)
		for _iSbp_ = 1 to _n_anSbpSortedLen_
			_nSbpPos_ = _anSbpSorted_[_iSbp_]
			if _nSbpPos_ > _nSbpPrev_ and _nSbpPos_ <= _nSbpLen_
				add(_aSbpResult_, @oString.Section(_nSbpPrev_, _nSbpPos_ - 1))
				_nSbpPrev_ = _nSbpPos_
			ok
		next

		if _nSbpPrev_ <= _nSbpLen_
			add(_aSbpResult_, @oString.Section(_nSbpPrev_, _nSbpLen_))
		ok

		return _aSbpResult_

	  #==============================#
	 #     SPLIT AFTER              #
	#==============================#

	def SplitAfterCS(pSubStrOrPos, pCaseSensitive)

		if isNumber(pSubStrOrPos)
			return This.SplitAfterPosition(pSubStrOrPos)
		ok

		if isString(pSubStrOrPos)
			return This.SplitAfterSubStringCS(pSubStrOrPos, pCaseSensitive)
		ok

		StzRaise("Incorrect param type!")

	def SplitAfter(pSubStrOrPos)
		return This.SplitAfterCS(pSubStrOrPos, 1)

	def SplitAfterPosition(n)
		if This.IsEmpty()
			return []
		ok

		if n < 1 or n >= This.NumberOfChars()
			return [ This.Content() ]
		ok

		cPart1 = @oString.Section(1, n)
		cPart2 = @oString.Section(n + 1, @oString.NumberOfChars())

		return [ cPart1, cPart2 ]

	def SplitAfterSubStringCS(pcSubStr, pCaseSensitive)
		oFinder = new stzStringFinder(@oString)
		anPos = oFinder.FindCS(pcSubStr, pCaseSensitive)
		if len(anPos) = 0
			return [ This.Content() ]
		ok

		nLenSub = StzLen(pcSubStr)
		anAfterPos = []
		_nAnPos1Len_ = len(anPos)
		for _iLoopAnPos1_ = 1 to _nAnPos1Len_
			nPos = anPos[_iLoopAnPos1_]
			anAfterPos + (nPos + nLenSub - 1)
		next

		return This.SplitAfterPositions(anAfterPos)

	def SplitAfterSubString(pcSubStr)
		return This.SplitAfterSubStringCS(pcSubStr, 1)

	def SplitAfterPositions(anPos)
		if This.IsEmpty()
			return []
		ok

		# Split after each position: segments end at pos, next starts at pos+1
		_anSapSorted_ = sort(anPos)
		_nSapLen_ = This.NumberOfChars()
		_aSapResult_ = []
		_nSapPrev_ = 1

		_n_anSapSortedLen_ = len(_anSapSorted_)
		for _iSap_ = 1 to _n_anSapSortedLen_
			_nSapPos_ = _anSapSorted_[_iSap_]
			if _nSapPos_ >= _nSapPrev_ and _nSapPos_ <= _nSapLen_
				add(_aSapResult_, @oString.Section(_nSapPrev_, _nSapPos_))
				_nSapPrev_ = _nSapPos_ + 1
			ok
		next

		if _nSapPrev_ <= _nSapLen_
			add(_aSapResult_, @oString.Section(_nSapPrev_, _nSapLen_))
		ok

		return _aSapResult_

	  #======================================================#
	 #   PARTITION (split into [before, sep, after])         #
	#======================================================#

	def PartitionCS(pcSep, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringPartitionCS(pH, pcSep, _bCase_)
		cResult = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _SplitNullDelimited(cResult)

	def Partition(pcSep)
		return This.PartitionCS(pcSep, 1)

	def PartitionAfterCS(pcSep, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringPartitionAfterCS(pH, pcSep, _bCase_)
		cResult = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _SplitNullDelimited(cResult)

	def PartitionAfter(pcSep)
		return This.PartitionAfterCS(pcSep, 1)

	def RPartitionCS(pcSep, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringRpartitionCS(pH, pcSep, _bCase_)
		cResult = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _SplitNullDelimited(cResult)

	def RPartition(pcSep)
		return This.RPartitionCS(pcSep, 1)

	def RPartitionAfterCS(pcSep, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringRpartitionAfterCS(pH, pcSep, _bCase_)
		cResult = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _SplitNullDelimited(cResult)

	def RPartitionAfter(pcSep)
		return This.RPartitionAfterCS(pcSep, 1)

	  #==============================#
	 #     REGEX SPLIT              #
	#==============================#

	def SplitByRegex(pcPattern)
		pH = @oString.Engine()
		_nSbrCount_ = StzEngineStringRegexSplitCount(pH, pcPattern, 0)
		if _nSbrCount_ <= 0
			return [ @oString.Content() ]
		ok
		_acSbrResult_ = []
		for _iSbr_ = 1 to _nSbrCount_
			_acSbrResult_ + StzEngineStringRegexSplitGet(pH, pcPattern, 0, _iSbr_)
		next
		return _acSbrResult_

		def SplitRegex(pcPattern)
			return This.SplitByRegex(pcPattern)

	def SplitByRegexCS(pcPattern, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nFlags_ = 0
		if _bCase_ = 0
			_nFlags_ = 1
		ok
		pH = @oString.Engine()
		_nSbrcsCount_ = StzEngineStringRegexSplitCount(pH, pcPattern, _nFlags_)
		if _nSbrcsCount_ <= 0
			return [ @oString.Content() ]
		ok
		_acSbrcsResult_ = []
		for _iSbrcs_ = 1 to _nSbrcsCount_
			_acSbrcsResult_ + StzEngineStringRegexSplitGet(pH, pcPattern, _nFlags_, _iSbrcs_)
		next
		return _acSbrcsResult_

		def SplitRegexCS(pcPattern, pCaseSensitive)
			return This.SplitByRegexCS(pcPattern, pCaseSensitive)
