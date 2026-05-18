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


class stzStringLines

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

	def NthLine(n)
		pH = @oString.Engine()
		pR = StzEngineStringLineAt(pH, n)
		if pR != NULL
			c = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			return c
		ok
		StzRaise("Index out of range!")

		def Line(n)
			return This.NthLine(n)

	def FirstLine()
		return This.NthLine(1)

	def LastLine()
		return This.NthLine(This.NumberOfLines())

	  #===============================#
	 #     UNIQUE LINES              #
	#===============================#

	def UniqueLinesCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		if _bCase_ = 1
			# Engine-backed O(n) hashmap deduplication
			pH = @oString.Engine()
			pR = StzEngineStringUniqueLines(pH)
			c = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			if c = ""
				return []
			ok
			return @SplitCS(c, NL, 1)
		ok

		# Case-insensitive: Ring-side with casefold comparison
		acLines = This.LinesCS(pCaseSensitive)
		acResult = []
		nLen = len(acLines)

		for i = 1 to nLen
			bFound = 0
			nResLen = len(acResult)
			for j = 1 to nResLen
				if StzCaseFold(acResult[j]) = StzCaseFold(acLines[i])
					bFound = 1
					exit
				ok
			next
			if NOT bFound
				acResult + acLines[i]
			ok
		next

		return acResult

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
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def RemoveEmptyLinesQ()
			This.RemoveEmptyLines()
			return This

	def EmptyLinesRemoved()
		pH = @oString.Engine()
		pR = StzEngineStringRemoveBlankLines(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	def NumberOfEmptyLines()
		return This.NumberOfLines() - len(This.EmptyLinesRemoved())

	def HasEmptyLines()
		acLines = This.Lines()
		nLen = len(acLines)
		for i = 1 to nLen
			if trim(acLines[i]) = ""
				return 1
			ok
		next
		return 0

	  #===============================#
	 #     N FIRST / N LAST LINES    #
	#===============================#

	def NFirstLines(n)
		acLines = This.Lines()
		nLen = len(acLines)
		acResult = []

		nLimit = n
		if nLimit > nLen
			nLimit = nLen
		ok

		for i = 1 to nLimit
			acResult + acLines[i]
		next

		return acResult

	def NLastLines(n)
		acLines = This.Lines()
		nLen = len(acLines)
		acResult = []

		nStart = nLen - n + 1
		if nStart < 1
			nStart = 1
		ok

		for i = nStart to nLen
			acResult + acLines[i]
		next

		return acResult

	  #===============================#
	 #     LONGEST / SHORTEST LINE   #
	#===============================#

	def LongestLine()
		acLines = This.Lines()
		nLen = len(acLines)
		if nLen = 0
			return ""
		ok

		cLongest = acLines[1]
		nMax = StzLen(cLongest)

		for i = 2 to nLen
			nLineLen = StzLen(acLines[i])
			if nLineLen > nMax
				nMax = nLineLen
				cLongest = acLines[i]
			ok
		next

		return cLongest

	def ShortestLine()
		acLines = This.Lines()
		nLen = len(acLines)
		if nLen = 0
			return ""
		ok

		cShortest = ""
		nMin = 0
		bFirst = 1

		for i = 1 to nLen
			cLine = acLines[i]
			if trim(cLine) != ""
				nLineLen = StzLen(cLine)
				if bFirst
					cShortest = cLine
					nMin = nLineLen
					bFirst = 0
				but nLineLen < nMin
					nMin = nLineLen
					cShortest = cLine
				ok
			ok
		next

		return cShortest

	  #===============================#
	 #     AVERAGE LINE LENGTH       #
	#===============================#

	def AverageLineLength()
		acLines = This.Lines()
		nLen = len(acLines)
		if nLen = 0
			return 0
		ok

		nTotal = 0
		for i = 1 to nLen
			nTotal += StzLen(acLines[i])
		next

		return nTotal / nLen

	  #===============================#
	 #     SORT LINES                #
	#===============================#

	def SortLines()
		pH = @oString.Engine()
		pR = StzEngineStringSortLines(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def SortLinesQ()
			This.SortLines()
			return This

	def LinesSorted()
		pH = @oString.Engine()
		pR = StzEngineStringSortLines(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     REVERSE LINES ORDER       #
	#===============================#

	def ReverseLinesOrder()
		acLines = This.Lines()
		nLen = len(acLines)

		cResult = ""
		for i = nLen to 1 step -1
			if i < nLen
				cResult += NL
			ok
			cResult += acLines[i]
		next

		@oString.Update(cResult)

		def ReverseLinesOrderQ()
			This.ReverseLinesOrder()
			return This

	def LinesOrderReversed()
		oCopy = new stzStringLines(@oString.Content())
		oCopy.ReverseLinesOrder()
		return oCopy.Content()

	  #===============================#
	 #     INDENT LINES              #
	#===============================#

	def IndentLines(n)
		pH = @oString.Engine()
		pR = StzEngineStringIndent(pH, n)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def IndentLinesQ(n)
			This.IndentLines(n)
			return This

	def LinesIndented(n)
		pH = @oString.Engine()
		pR = StzEngineStringIndent(pH, n)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     REMOVE DUPLICATE LINES    #
	#===============================#

	def RemoveDuplicateLines()
		pH = @oString.Engine()
		pR = StzEngineStringDeduplicateLines(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def RemoveDuplicateLinesQ()
			This.RemoveDuplicateLines()
			return This

	def DuplicateLinesRemoved()
		pH = @oString.Engine()
		pR = StzEngineStringDeduplicateLines(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     LINES CONTAINING          #
	#===============================#

	def LineContainingCS(pcSubStr, pCaseSensitive)
		acLines = This.Lines()
		nLen = len(acLines)

		for i = 1 to nLen
			if StringContainsCS(acLines[i], pcSubStr, pCaseSensitive)
				return acLines[i]
			ok
		next

		return ""

	def LinesContainingCS(pcSubStr, pCaseSensitive)
		acLines = This.Lines()
		nLen = len(acLines)
		acResult = []

		for i = 1 to nLen
			if StringContainsCS(acLines[i], pcSubStr, pCaseSensitive)
				acResult + acLines[i]
			ok
		next

		return acResult

	def LineContaining(pcSubStr)
		return This.LineContainingCS(pcSubStr, @CaseSensitive(1))

	def LinesContaining(pcSubStr)
		return This.LinesContainingCS(pcSubStr, @CaseSensitive(1))
