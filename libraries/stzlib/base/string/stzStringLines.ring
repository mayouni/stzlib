#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGLINES             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String lines -- Wraps stzString via          #
#                  composition. Line-based operations:           #
#                  splitting, counting, unique, empty removal.  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

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
		return len(This.LinesCS(pCaseSensitive))

		def CountLinesCS(pCaseSensitive)
			return This.NumberOfLinesCS(pCaseSensitive)

		def HowManyLinesCS(pCaseSensitive)
			return This.NumberOfLinesCS(pCaseSensitive)

	def NumberOfLines()
		return This.NumberOfLinesCS(1)

		def CountLines()
			return This.NumberOfLines()

		def HowManyLines()
			return This.NumberOfLines()

	  #===============================#
	 #     NTH LINE                  #
	#===============================#

	def NthLine(n)
		acLines = This.Lines()
		if n >= 1 and n <= len(acLines)
			return acLines[n]
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
		acLines = This.LinesCS(pCaseSensitive)
		acResult = []
		nLen = len(acLines)

		for i = 1 to nLen
			bFound = 0
			nResLen = len(acResult)
			for j = 1 to nResLen
				if pCaseSensitive
					if acResult[j] = acLines[i]
						bFound = 1
						exit
					ok
				else
					if lower(acResult[j]) = lower(acLines[i])
						bFound = 1
						exit
					ok
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
		acLines = This.Lines()
		acResult = []
		nLen = len(acLines)

		for i = 1 to nLen
			if trim(acLines[i]) != ""
				acResult + acLines[i]
			ok
		next

		cResult = ""
		nResLen = len(acResult)
		for i = 1 to nResLen
			if i > 1
				cResult += NL
			ok
			cResult += acResult[i]
		next

		@oString.Update(cResult)

		def RemoveEmptyLinesQ()
			This.RemoveEmptyLines()
			return This

	def EmptyLinesRemoved()
		oCopy = new stzStringLines(@oString.Content())
		oCopy.RemoveEmptyLines()
		return oCopy.Content()

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
		nMax = len(cLongest)

		for i = 2 to nLen
			nLineLen = len(acLines[i])
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
				nLineLen = len(cLine)
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
			nTotal += len(acLines[i])
		next

		return nTotal / nLen

	  #===============================#
	 #     SORT LINES                #
	#===============================#

	def SortLines()
		acLines = This.Lines()
		nLen = len(acLines)

		# Bubble sort
		for i = 1 to nLen - 1
			for j = 1 to nLen - i
				if acLines[j] > acLines[j + 1]
					cTemp = acLines[j]
					acLines[j] = acLines[j + 1]
					acLines[j + 1] = cTemp
				ok
			next
		next

		cResult = ""
		for i = 1 to nLen
			if i > 1
				cResult += NL
			ok
			cResult += acLines[i]
		next

		@oString.Update(cResult)

		def SortLinesQ()
			This.SortLines()
			return This

	def LinesSorted()
		oCopy = new stzStringLines(@oString.Content())
		oCopy.SortLines()
		return oCopy.Content()

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
		acLines = This.Lines()
		nLen = len(acLines)

		cSpaces = ""
		for s = 1 to n
			cSpaces += " "
		next

		cResult = ""
		for i = 1 to nLen
			if i > 1
				cResult += NL
			ok
			cResult += cSpaces + acLines[i]
		next

		@oString.Update(cResult)

		def IndentLinesQ(n)
			This.IndentLines(n)
			return This

	def LinesIndented(n)
		oCopy = new stzStringLines(@oString.Content())
		oCopy.IndentLines(n)
		return oCopy.Content()

	  #===============================#
	 #     REMOVE DUPLICATE LINES    #
	#===============================#

	def RemoveDuplicateLines()
		acLines = This.Lines()
		nLen = len(acLines)
		acResult = []

		for i = 1 to nLen
			bFound = 0
			nResLen = len(acResult)
			for j = 1 to nResLen
				if acResult[j] = acLines[i]
					bFound = 1
					exit
				ok
			next
			if NOT bFound
				acResult + acLines[i]
			ok
		next

		cResult = ""
		nResLen = len(acResult)
		for i = 1 to nResLen
			if i > 1
				cResult += NL
			ok
			cResult += acResult[i]
		next

		@oString.Update(cResult)

		def RemoveDuplicateLinesQ()
			This.RemoveDuplicateLines()
			return This

	def DuplicateLinesRemoved()
		oCopy = new stzStringLines(@oString.Content())
		oCopy.RemoveDuplicateLines()
		return oCopy.Content()

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
