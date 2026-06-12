#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGCODE              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String code -- Wraps stzString via          #
#                  composition. Detecting and working with     #
#                  code snippets in strings (Ring code,        #
#                  functions, classes).                        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringCode

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringCode! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     RING CODE DETECTION       #
	#===============================#

	def IsRingCode()
		cContent = StzCaseFold(@oString.Content())
		acKeywords = [
			"func", "class", "def", "if", "but", "else", "ok",
			"for", "next", "while", "end", "switch", "off",
			"return", "load", "see", "give", "new", "try",
			"catch", "done"
		]

		nLen = len(acKeywords)
		for i = 1 to nLen
			oFinder = new stzStringFinder(cContent)
			if oFinder.Contains(acKeywords[i])
				return 1
			ok
		next
		return 0

	def IsRingFunction()
		cTrimmed = trim(@oString.Content())
		return StzLeft(StzCaseFold(cTrimmed), 5) = "func "

	def IsRingClass()
		cTrimmed = trim(@oString.Content())
		return StzLeft(StzCaseFold(cTrimmed), 6) = "class "

	  #===============================#
	 #     CODE EXECUTION            #
	#===============================#

	def Execute()
		eval(@oString.Content())

	def ExecuteAndReturn()
		cCode = "_result_ = " + @oString.Content()
		eval(cCode)
		return _result_

	  #===============================#
	 #     CODE STRUCTURE            #
	#===============================#

	def ContainsFunctions()
		oFinder = new stzStringFinder(StzCaseFold(@oString.Content()))
		return oFinder.Contains("func ")

	def ContainsClasses()
		oFinder = new stzStringFinder(StzCaseFold(@oString.Content()))
		return oFinder.Contains("class ")

	def NumberOfFunctions()
		cContent = StzCaseFold(@oString.Content())
		acLines = split(cContent, nl)
		nCount = 0
		nLen = len(acLines)

		for i = 1 to nLen
			cLine = trim(acLines[i])
			if StzLeft(cLine, 5) = "func "
				nCount++
			ok
		next

		return nCount

	def NumberOfClasses()
		cContent = StzCaseFold(@oString.Content())
		acLines = split(cContent, nl)
		nCount = 0
		nLen = len(acLines)

		for i = 1 to nLen
			cLine = trim(acLines[i])
			if StzLeft(cLine, 6) = "class "
				nCount++
			ok
		next

		return nCount

	def FunctionNames()
		cContent = @oString.Content()
		acLines = split(cContent, nl)
		acNames = []
		nLen = len(acLines)

		for i = 1 to nLen
			cLine = trim(acLines[i])
			cLineLow = StzCaseFold(cLine)
			if StzLeft(cLineLow, 5) = "func "
				oLine = new stzString(cLine)
				cRest = oLine.Section(6, StzLen(cLine))
				cRest = trim(cRest)
				# Extract the function name (first word)
				cName = ""
				oRest = new stzString(cRest)
				acRestChars = oRest.Chars()
				nRestLen = len(acRestChars)
				for j = 1 to nRestLen
					c = acRestChars[j]
					if c = " " or c = "(" or c = nl
						exit
					ok
					cName += c
				next
				if StzLen(cName) > 0
					acNames + cName
				ok
			ok
		next

		return acNames

	def ClassNames()
		cContent = @oString.Content()
		acLines = split(cContent, nl)
		acNames = []
		nLen = len(acLines)

		for i = 1 to nLen
			cLine = trim(acLines[i])
			cLineLow = StzCaseFold(cLine)
			if StzLeft(cLineLow, 6) = "class "
				oLine = new stzString(cLine)
				cRest = oLine.Section(7, StzLen(cLine))
				cRest = trim(cRest)
				# Extract the class name (first word)
				cName = ""
				oRest = new stzString(cRest)
				acRestChars = oRest.Chars()
				nRestLen = len(acRestChars)
				for j = 1 to nRestLen
					c = acRestChars[j]
					if c = " " or c = nl
						exit
					ok
					cName += c
				next
				if StzLen(cName) > 0
					acNames + cName
				ok
			ok
		next

		return acNames

	  #===============================#
	 #     LINE ANALYSIS             #
	#===============================#

	def IsComment()
		cTrimmed = trim(@oString.Content())
		if StzLeft(cTrimmed, 1) = "#"
			return 1
		ok
		if StzLeft(cTrimmed, 2) = "//"
			return 1
		ok
		return 0

	def IsBlankLine()
		cTrimmed = trim(@oString.Content())
		return StzLen(cTrimmed) = 0

	def ContainsComments()
		oFinder = new stzStringFinder(@oString)
		if oFinder.Contains("#")
			return 1
		ok
		if oFinder.Contains("//")
			return 1
		ok
		return 0

	def LinesOfCode()
		cContent = @oString.Content()
		acLines = split(cContent, nl)
		nCount = 0
		nLen = len(acLines)

		for i = 1 to nLen
			cLine = trim(acLines[i])
			# Skip blank lines
			if StzLen(cLine) = 0
				loop
			ok
			# Skip comment lines
			if StzLeft(cLine, 1) = "#"
				loop
			ok
			if StzLeft(cLine, 2) = "//"
				loop
			ok
			nCount++
		next

		return nCount
