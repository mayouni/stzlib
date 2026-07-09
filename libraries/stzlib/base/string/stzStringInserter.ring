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


class stzStringInserter from stzObject

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

	def InsertBefore(_n_, pcSubStr)
		_nLen_ = @oString.NumberOfChars()
		if _n_ < 1 or _n_ > _nLen_ + 1
			return
		ok
		if _n_ = 1
			@oString.Update(pcSubStr + @oString.Content())
			return
		ok
		if _n_ = _nLen_ + 1
			@oString.Update(@oString.Content() + pcSubStr)
			return
		ok
		_cLeft_ = @oString.Section(1, _n_ - 1)
		_cRight_ = @oString.Section(_n_, _nLen_)
		@oString.Update(_cLeft_ + pcSubStr + _cRight_)

		def InsertBeforeQ(_n_, pcSubStr)
			This.InsertBefore(_n_, pcSubStr)
			return This

		def InsertBeforePosition(_n_, pcSubStr)
			This.InsertBefore(_n_, pcSubStr)

	def InsertAfter(_n_, pcSubStr)
		This.InsertBefore(_n_ + 1, pcSubStr)

		def InsertAfterQ(_n_, pcSubStr)
			This.InsertAfter(_n_, pcSubStr)
			return This

		def InsertAfterPosition(_n_, pcSubStr)
			This.InsertAfter(_n_, pcSubStr)

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

	def InsertAfterNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_nPos_ = _oFinder_.FindNthCS(_n_, pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(_nPos_ + StzLen(pcSubStr) - 1, pcNewSubStr)

		def InsertAfterNthCSQ(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertedAfterNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertAfterNthCSQ(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def InsertAfterNth(_n_, pcSubStr, pcNewSubStr)
		This.InsertAfterNthCS(_n_, pcSubStr, pcNewSubStr, 1)

		def InsertAfterNthQ(_n_, pcSubStr, pcNewSubStr)
			This.InsertAfterNth(_n_, pcSubStr, pcNewSubStr)
			return This

	def InsertedAfterNth(_n_, pcSubStr, pcNewSubStr)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertAfterNthQ(_n_, pcSubStr, pcNewSubStr)
		return _oCopy_.Content()

	  #======================================================#
	 #   INSERTING AFTER FIRST / LAST OCCURRENCE            #
	#======================================================#

	def InsertAfterFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_nPos_ = _oFinder_.FindFirstCS(pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(_nPos_ + StzLen(pcSubStr) - 1, pcNewSubStr)

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
		_nPos_ = _oFinder_.FindLastCS(pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(_nPos_ + StzLen(pcSubStr) - 1, pcNewSubStr)

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

	def InsertBeforeNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_nPos_ = _oFinder_.FindNthCS(_n_, pcSubStr, pCaseSensitive)
		This.InsertBefore(_nPos_, pcNewSubStr)

		def InsertBeforeNthCSQ(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertedBeforeNthCS(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertBeforeNthCSQ(_n_, pcSubStr, pcNewSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def InsertBeforeNth(_n_, pcSubStr, pcNewSubStr)
		This.InsertBeforeNthCS(_n_, pcSubStr, pcNewSubStr, 1)

		def InsertBeforeNthQ(_n_, pcSubStr, pcNewSubStr)
			This.InsertBeforeNth(_n_, pcSubStr, pcNewSubStr)
			return This

	def InsertedBeforeNth(_n_, pcSubStr, pcNewSubStr)
		_oCopy_ = new stzStringInserter(@oString.Content())
		_oCopy_.InsertBeforeNthQ(_n_, pcSubStr, pcNewSubStr)
		return _oCopy_.Content()

	  #======================================================#
	 #   INSERTING BEFORE FIRST / LAST OCCURRENCE           #
	#======================================================#

	def InsertBeforeFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_nPos_ = _oFinder_.FindFirstCS(pcSubStr, pCaseSensitive)
		This.InsertBefore(_nPos_, pcNewSubStr)

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
		_nPos_ = _oFinder_.FindLastCS(pcSubStr, pCaseSensitive)
		This.InsertBefore(_nPos_, pcNewSubStr)

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

	def InsertSubStringBetweenPositions(pcSubStr, _n1_, _n2_)
		if CheckingParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
			if isList(_n2_) and IsAndNamedParamList(_n2_)
				_n2_ = _n2_[2]
			ok
			if NOT (isNumber(_n1_) and isNumber(_n2_))
				StzRaise("Incorrect params types! n1 and n2 must be both numbers.")
			ok
		ok

		if _n1_ > _n2_
			_nTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nTemp_
		ok

		This.InsertAfter(_n1_, pcSubStr)

		def InsertBetween(pcSubStr, _n1_, _n2_)
			This.InsertSubStringBetweenPositions(pcSubStr, _n1_, _n2_)

		def InsertBetweenPositions(pcSubStr, _n1_, _n2_)
			This.InsertSubStringBetweenPositions(pcSubStr, _n1_, _n2_)

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
		_aSections_ = _oFinder_.FindAnyBoundedByAsSectionsCS([pcSubStr1, pcSubStr2], pCaseSensitive)
		@oString.ReplaceSections(_aSections_, pcSubStr)

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

		_aSorted_ = new stzList(panPos).SortedInDescending()
		_nSorted2Len_ = len(_aSorted_)
		for _iLoopSorted2_ = 1 to _nSorted2Len_
			_n_ = _aSorted_[_iLoopSorted2_]
			This.InsertAfter(_n_, pcSubStr)
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

		_aSorted_ = new stzList(panPos).SortedInDescending()
		_nSorted1Len_ = len(_aSorted_)
		for _iLoopSorted1_ = 1 to _nSorted1Len_
			_n_ = _aSorted_[_iLoopSorted1_]
			This.InsertBefore(_n_, pcSubStr)
		next

		def InsertBeforeManyPositionsQ(pcSubStr, panPos)
			This.InsertBeforeManyPositions(pcSubStr, panPos)
			return This
