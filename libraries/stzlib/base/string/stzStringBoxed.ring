#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGBOXED              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String boxed display -- draws Unicode box   #
#                  borders around string content.               #
#                  Wraps stzString via composition.             #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzBoxedString(str)
	oStr = new stzStringBoxed(str)
	return oStr.Boxed()

	func BoxedString(str)
		return StzBoxedString(str)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringBoxed from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringBoxed! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	  #======================================================#
	 #   BOXED -- FULL STRING IN A BOX                      #
	#======================================================#

	def Boxed()
		cContent = @oString.Content()

		# Split into lines using engine
		oLines = new stzStringLines(@oString)
		nLines = oLines.NumberOfLines()

		# Find max line length (codepoint-aware)
		nMaxLen = 0
		for i = 1 to nLines
			cLine = oLines.NthLine(i)
			oLine = new stzString(cLine)
			nLen = oLine.NumberOfChars()
			if nLen > nMaxLen
				nMaxLen = nLen
			ok
		next

		# Build box using Unicode box-drawing chars
		cHBar = ""
		for i = 1 to nMaxLen + 2
			cHBar += "─"
		next

		cResult = "╭" + cHBar + "╮" + StzChar(10)

		for i = 1 to nLines
			cLine = oLines.NthLine(i)
			oLine = new stzString(cLine)
			nLen = oLine.NumberOfChars()
			cPad = ""
			for j = 1 to nMaxLen - nLen
				cPad += " "
			next
			cResult += "│ " + cLine + cPad + " │" + StzChar(10)
		next

		cResult += "╰" + cHBar + "╯"
		return cResult

	  #======================================================#
	 #   BOXED CHARS -- EACH CHAR IN ITS OWN CELL           #
	#======================================================#

	def BoxedChars()
		cContent = @oString.Content()
		if cContent = ""
			return This.Boxed()
		ok

		nLen = @oString.NumberOfChars()

		# Build middle line: │ c1 │ c2 │ c3 │
		cMiddle = "│ "
		for i = 1 to nLen
			cMiddle += @oString.NthChar(i) + " │"
			if i < nLen
				cMiddle += " "
			ok
		next

		# Build top/bottom lines with separators
		cTop = "╭"
		cBottom = "╰"
		for i = 1 to nLen
			cTop += "────"
			cBottom += "────"
			if i < nLen
				cTop += "┬"
				cBottom += "┴"
			ok
		next
		cTop += "╮"
		cBottom += "╯"

		return cTop + StzChar(10) + cMiddle + StzChar(10) + cBottom
