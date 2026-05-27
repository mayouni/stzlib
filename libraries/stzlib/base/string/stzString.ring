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
		for i = 0 to nCount - 1
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
			This.Update(_cAlContent_ + copy(cFillChar, _nAlPad_))
		but cDirection = :Right or cDirection = :right
			This.Update(copy(cFillChar, _nAlPad_) + _cAlContent_)
		else
			_nAlLeft_ = floor(_nAlPad_ / 2)
			_nAlRight_ = _nAlPad_ - _nAlLeft_
			This.Update(copy(cFillChar, _nAlLeft_) + _cAlContent_ + copy(cFillChar, _nAlRight_))
		ok

		def AlignXTQ(nWidth, cFillChar, cDirection)
			This.AlignXT(nWidth, cFillChar, cDirection)
			return This

	  #============================#
	 #   UNIQUE CHARS             #
	#============================#

	def CharsU()
		_aCuChars_ = This.Chars()
		_aCuResult_ = []
		_nCuLen_ = len(_aCuChars_)
		for _iCu_ = 1 to _nCuLen_
			_bCuFound_ = 0
			_nCuRLen_ = len(_aCuResult_)
			for _jCu_ = 1 to _nCuRLen_
				if _aCuResult_[_jCu_] = _aCuChars_[_iCu_]
					_bCuFound_ = 1
					exit
				ok
			next
			if _bCuFound_ = 0
				_aCuResult_ + _aCuChars_[_iCu_]
			ok
		next
		return _aCuResult_

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
	 #   DUPLICATED SUBSTRINGS    #
	#============================#

	def Duplicates()
		_oDup_ = new stzStringDuplicates(This)
		return _oDup_.DuplicatedChars()
