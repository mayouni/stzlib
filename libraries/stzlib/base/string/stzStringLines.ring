#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGLINES             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String lines subclass -- line-based          #
#                  operations: splitting into lines, counting,  #
#                  unique lines, empty line removal.             #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringLinesQ(str)
	return new stzStringLines(str)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringLines from stzString

	  #===============================#
	 #     LINES                     #
	#===============================#

	def LinesCS(pCaseSensitive)
		return @SplitCS(This.Content(), NL, pCaseSensitive)

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

		This.Update(cResult)

		def RemoveEmptyLinesQ()
			This.RemoveEmptyLines()
			return This

	def EmptyLinesRemoved()
		oCopy = new stzStringLines(This.Content())
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

