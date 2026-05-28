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

	def FindFirstCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringFindFirstCS(@pEngine, pcSubStr, _bCase_)

	def FindFirst(pcSubStr)
		return StzEngineStringFindFirstCS(@pEngine, pcSubStr, 1)

	def NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		if _bCase_
			return StzEngineStringCountOf(@pEngine, pcSubStr)
		else
			return StzEngineStringCountOfCI(@pEngine, pcSubStr)
		ok

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

		def ReplaceAllCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceCS(pcSubStr, pcNewSubStr, pCaseSensitive)

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
		_nIbLen_ = This.NumberOfChars()
		if n < 1 or n > _nIbLen_ + 1
			return
		ok
		if n = 1
			This.Update(pcSubStr + This.Content())
			return
		ok
		if n = _nIbLen_ + 1
			This.Update(This.Content() + pcSubStr)
			return
		ok
		_cIbLeft_ = This.Section(1, n - 1)
		_cIbRight_ = This.Section(n, _nIbLen_)
		This.Update(_cIbLeft_ + pcSubStr + _cIbRight_)

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
		return This._SplitByStr(NL)

	def NumberOfLines()
		return len(This.Lines())

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
