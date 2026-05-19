#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGINSERTER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String inserter subclass -- inserting       #
#                  substrings at positions or around matches.  #
#                  For aliases, use stzStringInserterXT.       #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringInserter

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringInserter! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   INSERTING BEFORE / AFTER A POSITION                #
	#======================================================#

	def InsertBefore(n, pcSubStr)
		nLen = @oString.NumberOfChars()
		if n < 1 or n > nLen + 1
			return
		ok
		if n = 1
			@oString.Update(pcSubStr + @oString.Content())
			return
		ok
		if n = nLen + 1
			@oString.Update(@oString.Content() + pcSubStr)
			return
		ok
		cLeft = @oString.Section(1, n - 1)
		cRight = @oString.Section(n, nLen)
		@oString.Update(cLeft + pcSubStr + cRight)

		def InsertBeforeQ(n, pcSubStr)
			This.InsertBefore(n, pcSubStr)
			return This

		def InsertBeforePosition(n, pcSubStr)
			This.InsertBefore(n, pcSubStr)

	def InsertAfter(n, pcSubStr)
		This.InsertBefore(n + 1, pcSubStr)

		def InsertAfterQ(n, pcSubStr)
			This.InsertAfter(n, pcSubStr)
			return This

		def InsertAfterPosition(n, pcSubStr)
			This.InsertAfter(n, pcSubStr)

	  #======================================================#
	 #   INSERTING BEFORE / AFTER ALL OCCURRENCES           #
	#======================================================#

	def InsertBeforeSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pResult = StzEngineStringInsertBeforeEachCS(pH, pcSubStr, pcNewSubStr, _bCase_)
		@oString.Update(StzEngineStringData(pResult))
		StzEngineStringFree(pResult)

		def InsertBeforeSubStringCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertBeforeSubString(pcSubStr, pcNewSubStr)
		This.InsertBeforeSubStringCS(pcSubStr, pcNewSubStr, 1)

	def InsertAfterSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pResult = StzEngineStringInsertAfterEachCS(pH, pcSubStr, pcNewSubStr, _bCase_)
		@oString.Update(StzEngineStringData(pResult))
		StzEngineStringFree(pResult)

		def InsertAfterSubStringCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertAfterSubString(pcSubStr, pcNewSubStr)
		This.InsertAfterSubStringCS(pcSubStr, pcNewSubStr, 1)

	  #======================================================#
	 #   INSERTING AFTER NTH OCCURRENCE                     #
	#======================================================#

	def InsertAfterNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		nPos = _oFinder_.FindNthCS(n, pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(nPos + StzLen(pcSubStr) - 1, pcNewSubStr)

		def InsertAfterNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertedAfterNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertAfterNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def InsertAfterNth(n, pcSubStr, pcNewSubStr)
		This.InsertAfterNthCS(n, pcSubStr, pcNewSubStr, 1)

		def InsertAfterNthQ(n, pcSubStr, pcNewSubStr)
			This.InsertAfterNth(n, pcSubStr, pcNewSubStr)
			return This

	def InsertedAfterNth(n, pcSubStr, pcNewSubStr)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertAfterNthQ(n, pcSubStr, pcNewSubStr)
		return _oCopy_.Content()

	  #======================================================#
	 #   INSERTING AFTER FIRST / LAST OCCURRENCE            #
	#======================================================#

	def InsertAfterFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		nPos = _oFinder_.FindFirstCS(pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(nPos + StzLen(pcSubStr) - 1, pcNewSubStr)

		def InsertAfterFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertAfterFirst(pcSubStr, pcNewSubStr)
		This.InsertAfterFirstCS(pcSubStr, pcNewSubStr, 1)

		def InsertAfterFirstQ(pcSubStr, pcNewSubStr)
			This.InsertAfterFirst(pcSubStr, pcNewSubStr)
			return This

	def InsertedAfterFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertAfterFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def InsertedAfterFirst(pcSubStr, pcNewSubStr)
		return This.InsertedAfterFirstCS(pcSubStr, pcNewSubStr, 1)

	#--

	def InsertAfterLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		nPos = _oFinder_.FindLastCS(pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(nPos + StzLen(pcSubStr) - 1, pcNewSubStr)

		def InsertAfterLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertAfterLast(pcSubStr, pcNewSubStr)
		This.InsertAfterLastCS(pcSubStr, pcNewSubStr, 1)

		def InsertAfterLastQ(pcSubStr, pcNewSubStr)
			This.InsertAfterLast(pcSubStr, pcNewSubStr)
			return This

	def InsertedAfterLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertAfterLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def InsertedAfterLast(pcSubStr, pcNewSubStr)
		return This.InsertedAfterLastCS(pcSubStr, pcNewSubStr, 1)

	  #======================================================#
	 #   INSERTING BEFORE NTH OCCURRENCE                    #
	#======================================================#

	def InsertBeforeNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		nPos = _oFinder_.FindNthCS(n, pcSubStr, pCaseSensitive)
		This.InsertBefore(nPos, pcNewSubStr)

		def InsertBeforeNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertedBeforeNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertBeforeNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def InsertBeforeNth(n, pcSubStr, pcNewSubStr)
		This.InsertBeforeNthCS(n, pcSubStr, pcNewSubStr, 1)

		def InsertBeforeNthQ(n, pcSubStr, pcNewSubStr)
			This.InsertBeforeNth(n, pcSubStr, pcNewSubStr)
			return This

	def InsertedBeforeNth(n, pcSubStr, pcNewSubStr)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertBeforeNthQ(n, pcSubStr, pcNewSubStr)
		return _oCopy_.Content()

	  #======================================================#
	 #   INSERTING BEFORE FIRST / LAST OCCURRENCE           #
	#======================================================#

	def InsertBeforeFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		nPos = _oFinder_.FindFirstCS(pcSubStr, pCaseSensitive)
		This.InsertBefore(nPos, pcNewSubStr)

		def InsertBeforeFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertBeforeFirst(pcSubStr, pcNewSubStr)
		This.InsertBeforeFirstCS(pcSubStr, pcNewSubStr, 1)

		def InsertBeforeFirstQ(pcSubStr, pcNewSubStr)
			This.InsertBeforeFirst(pcSubStr, pcNewSubStr)
			return This

	def InsertedBeforeFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertBeforeFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def InsertedBeforeFirst(pcSubStr, pcNewSubStr)
		return This.InsertedBeforeFirstCS(pcSubStr, pcNewSubStr, 1)

	#--

	def InsertBeforeLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		nPos = _oFinder_.FindLastCS(pcSubStr, pCaseSensitive)
		This.InsertBefore(nPos, pcNewSubStr)

		def InsertBeforeLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertBeforeLast(pcSubStr, pcNewSubStr)
		This.InsertBeforeLastCS(pcSubStr, pcNewSubStr, 1)

		def InsertBeforeLastQ(pcSubStr, pcNewSubStr)
			This.InsertBeforeLast(pcSubStr, pcNewSubStr)
			return This

	def InsertedBeforeLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertBeforeLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def InsertedBeforeLast(pcSubStr, pcNewSubStr)
		return This.InsertedBeforeLastCS(pcSubStr, pcNewSubStr, 1)

	  #======================================================#
	 #   INSERTING BETWEEN TWO POSITIONS                    #
	#======================================================#

	def InsertSubStringBetweenPositions(pcSubStr, n1, n2)
		if CheckingParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
			if isList(n2) and IsAndNamedParamList(n2)
				n2 = n2[2]
			ok
			if NOT (isNumber(n1) and isNumber(n2))
				StzRaise("Incorrect params types! n1 and n2 must be both numbers.")
			ok
		ok

		if n1 > n2
			nTemp = n1
			n1 = n2
			n2 = nTemp
		ok

		This.InsertAfter(n1, pcSubStr)

		def InsertBetween(pcSubStr, n1, n2)
			This.InsertSubStringBetweenPositions(pcSubStr, n1, n2)

		def InsertBetweenPositions(pcSubStr, n1, n2)
			This.InsertSubStringBetweenPositions(pcSubStr, n1, n2)

	  #======================================================#
	 #   INSERTING BETWEEN TWO SUBSTRINGS                   #
	#======================================================#

	def InsertSubStringBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		if CheckingParams()
			if NOT (isString(pcSubStr) and isString(pcSubStr1) and isString(pcSubStr2))
				StzRaise("Incorrect param types! pcSubStr, pcSubStr1, pcSubStr2 must be all strings.")
			ok
		ok

		if pcSubStr = "" or pcSubStr1 = "" or pcSubStr2 = ""
			return
		ok

		_oFinder_ = new stzStringFinder(@oString)
		aSections = _oFinder_.FindAnyBoundedByAsSectionsCS([pcSubStr1, pcSubStr2], pCaseSensitive)
		@oString.ReplaceSections(aSections, pcSubStr)

		def InsertBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			This.InsertSubStringBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

	def InsertSubStringBetweenSubStrings(pcSubStr, pcSubStr1, pcSubStr2)
		This.InsertSubStringBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, 1)

		def InsertBetweenSubStrings(pcSubStr, pcSubStr1, pcSubStr2)
			This.InsertSubStringBetweenSubStrings(pcSubStr, pcSubStr1, pcSubStr2)

	  #======================================================#
	 #   INSERTING AT MANY POSITIONS                        #
	#======================================================#

	def InsertAfterManyPositions(pcSubStr, panPos)
		if CheckingParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
			if NOT (isList(panPos) and @IsListOfNumbers(panPos))
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		aSorted = ring_reverse(sort(panPos))
		for n in aSorted
			This.InsertAfter(n, pcSubStr)
		next

		def InsertAfterManyPositionsQ(pcSubStr, panPos)
			This.InsertAfterManyPositions(pcSubStr, panPos)
			return This

	def InsertBeforeManyPositions(pcSubStr, panPos)
		if CheckingParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
			if NOT (isList(panPos) and @IsListOfNumbers(panPos))
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		aSorted = ring_reverse(sort(panPos))
		for n in aSorted
			This.InsertBefore(n, pcSubStr)
		next

		def InsertBeforeManyPositionsQ(pcSubStr, panPos)
			This.InsertBeforeManyPositions(pcSubStr, panPos)
			return This
