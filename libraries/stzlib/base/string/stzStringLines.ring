#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGLINES             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String lines -- Wraps stzString via         #
#                  composition. Line-based operations:         #
#                  splitting, counting, unique, empty removal. #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringLines from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringLines! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     LINES                     #
	#===============================#

	def LinesCS(pCaseSensitive)
		return @SplitCS(@oString.Content(), NL, pCaseSensitive)

		def LinesCSQ(pCaseSensitive)
			return new stzList(This.LinesCS(pCaseSensitive))

	def Lines()
		return This.LinesCS(1)

		def LinesQ()
			return new stzList(This.Lines())

	  #===============================#
	 #     NUMBER OF LINES           #
	#===============================#

	def NumberOfLinesCS(pCaseSensitive)
		return StzEngineStringCountLines(@oString.Engine())

		def CountLinesCS(pCaseSensitive)
			return This.NumberOfLinesCS(pCaseSensitive)

		def HowManyLinesCS(pCaseSensitive)
			return This.NumberOfLinesCS(pCaseSensitive)

	def NumberOfLines()
		return StzEngineStringCountLines(@oString.Engine())

		def CountLines()
			return This.NumberOfLines()

		def HowManyLines()
			return This.NumberOfLines()

	  #===============================#
	 #     NTH LINE                  #
	#===============================#

	# The nth line of the string.
	def NthLine(n)
		pH = @oString.Engine()
		pR = StzEngineStringLineAt(pH, n)
		if pR != NULL
			_c_ = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			return _c_
		ok
		StzRaise("Index out of range!")

		def Line(n)
			return This.NthLine(n)

	def FirstLine()
		return This.NthLine(1)

	# The last line of the string.
	def LastLine()
		return This.NthLine(This.NumberOfLines())

	  #===============================#
	 #     UNIQUE LINES              #
	#===============================#

	# The unique lines of the string.
	def UniqueLinesCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		pH = @oString.Engine()
		pR = StzEngineStringUniqueLinesCS(pH, _bCase_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		if _c_ = ""
			return []
		ok
		return @SplitCS(_c_, NL, 1)

		def LinesCSU(pCaseSensitive)
			return This.UniqueLinesCS(pCaseSensitive)

	def UniqueLines()
		return This.UniqueLinesCS(1)

		def LinesU()
			return This.UniqueLines()

	  #===============================#
	 #     EMPTY LINES               #
	#===============================#

	def RemoveEmptyLines()
		pH = @oString.Engine()
		pR = StzEngineStringRemoveBlankLines(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveEmptyLinesQ()
			This.RemoveEmptyLines()
			return This

	def EmptyLinesRemoved()
		pH = @oString.Engine()
		pR = StzEngineStringRemoveBlankLines(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def NumberOfEmptyLines()
		return This.NumberOfLines() - len(This.EmptyLinesRemoved())

	def HasEmptyLines()
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		for i = 1 to _nLen_
			if trim(_acLines_[i]) = ""
				return 1
			ok
		next
		return 0

	  #===============================#
	 #     N FIRST / N LAST LINES    #
	#===============================#

	def NFirstLines(n)
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		_acResult_ = []

		_nLimit_ = n
		if _nLimit_ > _nLen_
			_nLimit_ = _nLen_
		ok

		for i = 1 to _nLimit_
			_acResult_ + _acLines_[i]
		next

		return _acResult_

	def NLastLines(n)
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		_acResult_ = []

		_nStart_ = _nLen_ - n + 1
		if _nStart_ < 1
			_nStart_ = 1
		ok

		for i = _nStart_ to _nLen_
			_acResult_ + _acLines_[i]
		next

		return _acResult_

	  #===============================#
	 #     LONGEST / SHORTEST LINE   #
	#===============================#

	def LongestLine()
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		if _nLen_ = 0
			return ""
		ok

		_cLongest_ = _acLines_[1]
		_nMax_ = StzLen(_cLongest_)

		for i = 2 to _nLen_
			_nLineLen_ = StzLen(_acLines_[i])
			if _nLineLen_ > _nMax_
				_nMax_ = _nLineLen_
				_cLongest_ = _acLines_[i]
			ok
		next

		return _cLongest_

	def ShortestLine()
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		if _nLen_ = 0
			return ""
		ok

		_cShortest_ = ""
		_nMin_ = 0
		_bFirst_ = 1

		for i = 1 to _nLen_
			_cLine_ = _acLines_[i]
			if trim(_cLine_) != ""
				_nLineLen_ = StzLen(_cLine_)
				if _bFirst_
					_cShortest_ = _cLine_
					_nMin_ = _nLineLen_
					_bFirst_ = 0
				but _nLineLen_ < _nMin_
					_nMin_ = _nLineLen_
					_cShortest_ = _cLine_
				ok
			ok
		next

		return _cShortest_

	  #===============================#
	 #     AVERAGE LINE LENGTH       #
	#===============================#

	def AverageLineLength()
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		if _nLen_ = 0
			return 0
		ok

		_nTotal_ = 0
		for i = 1 to _nLen_
			_nTotal_ += StzLen(_acLines_[i])
		next

		return _nTotal_ / _nLen_

	  #===============================#
	 #     SORT LINES                #
	#===============================#

	def SortLinesCS(pCaseSensitive)
		pH = @oString.Engine()
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pR = StzEngineStringSortLinesCS(pH, _bCase_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def SortLinesCSQ(pCaseSensitive)
			This.SortLinesCS(pCaseSensitive)
			return This

	def SortLines()
		return This.SortLinesCS(1)

		def SortLinesQ()
			This.SortLines()
			return This

	def LinesSortedCS(pCaseSensitive)
		pH = @oString.Engine()
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pR = StzEngineStringSortLinesCS(pH, _bCase_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def LinesSorted()
		return This.LinesSortedCS(1)

	  #===============================#
	 #     REVERSE LINES ORDER       #
	#===============================#

	def ReverseLinesOrder()
		pH = @oString.Engine()
		pR = StzEngineStringReverseLines(pH)
		@oString.Update(StzEngineStringData(pR))
		StzEngineStringFree(pR)

		def ReverseLinesOrderQ()
			This.ReverseLinesOrder()
			return This

	def LinesOrderReversed()
		_oCopy_ = new stzStringLines(@oString.Content())
		_oCopy_.ReverseLinesOrder()
		return _oCopy_.Content()

	  #===============================#
	 #     INDENT LINES              #
	#===============================#

	def IndentLines(n)
		pH = @oString.Engine()
		pR = StzEngineStringIndent(pH, n)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def IndentLinesQ(n)
			This.IndentLines(n)
			return This

	def LinesIndented(n)
		pH = @oString.Engine()
		pR = StzEngineStringIndent(pH, n)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     REMOVE DUPLICATE LINES    #
	#===============================#

	def RemoveDuplicateLinesCS(pCaseSensitive)
		pH = @oString.Engine()
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pR = StzEngineStringDeduplicateLinesCS(pH, _bCase_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveDuplicateLinesCSQ(pCaseSensitive)
			This.RemoveDuplicateLinesCS(pCaseSensitive)
			return This

	def RemoveDuplicateLines()
		return This.RemoveDuplicateLinesCS(1)

		def RemoveDuplicateLinesQ()
			This.RemoveDuplicateLines()
			return This

	def DuplicateLinesRemovedCS(pCaseSensitive)
		pH = @oString.Engine()
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pR = StzEngineStringDeduplicateLinesCS(pH, _bCase_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def DuplicateLinesRemoved()
		return This.DuplicateLinesRemovedCS(1)

	  #===============================#
	 #     LINES CONTAINING          #
	#===============================#

	def LineContainingCS(pcSubStr, pCaseSensitive)
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			if StringContainsCS(_acLines_[i], pcSubStr, pCaseSensitive)
				return _acLines_[i]
			ok
		next

		return ""

	# The lines containing the given substring.
	def LinesContainingCS(pcSubStr, pCaseSensitive)
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		_acResult_ = []

		for i = 1 to _nLen_
			if StringContainsCS(_acLines_[i], pcSubStr, pCaseSensitive)
				_acResult_ + _acLines_[i]
			ok
		next

		return _acResult_

	def LineContaining(pcSubStr)
		return This.LineContainingCS(pcSubStr, @CaseSensitive(1))

	def LinesContaining(pcSubStr)
		return This.LinesContainingCS(pcSubStr, @CaseSensitive(1))
