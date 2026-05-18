#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZSTRINGNUMBERS             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String numbers -- Wraps stzString via       #
#                  composition. Extracting and working with    #
#                  numbers embedded in strings.                #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringNumbers

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringNumbers! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     EXTRACT NUMBERS           #
	#===============================#

	def Numbers()
		cContent = @oString.Content()
		nLen = len(cContent)
		anResult = []
		cNum = ""

		for i = 1 to nLen
			c = substr(cContent, i, 1)

			if isDigit(c)
				cNum += c

			but (c = "-" or c = "+") and cNum = ""
				cNext = ""
				if i + 1 <= nLen
					cNext = substr(cContent, i + 1, 1)
				ok
				if isDigit(cNext)
					cNum = c
				ok

			but c = "." and cNum != ""
				cNext = ""
				if i + 1 <= nLen
					cNext = substr(cContent, i + 1, 1)
				ok
				if isDigit(cNext)
					cNum += c
				else
					anResult + (0 + cNum)
					cNum = ""
				ok

			else
				if cNum != "" and cNum != "-" and cNum != "+"
					anResult + (0 + cNum)
				ok
				cNum = ""
			ok
		next

		if cNum != "" and cNum != "-" and cNum != "+"
			anResult + (0 + cNum)
		ok

		return anResult

		def NumbersQ()
			return new stzList(This.Numbers())

		def ExtractNumbers()
			return This.Numbers()

	  #===============================#
	 #     NUMBER COUNT              #
	#===============================#

	def NumberOfNumbers()
		return len(This.Numbers())

		def CountNumbers()
			return This.NumberOfNumbers()

		def HowManyNumbers()
			return This.NumberOfNumbers()

	  #===============================#
	 #     CONTAINS NUMBERS          #
	#===============================#

	def ContainsNumbers()
		return This.NumberOfNumbers() > 0

	def ContainsOnlyNumbers()
		cContent = @oString.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if NOT isDigit(c) and c != "." and c != "-" and c != "+"
				return 0
			ok
		next
		return 1

	  #===============================#
	 #     REMOVE NUMBERS            #
	#===============================#

	def RemoveNumbers()
		cContent = @oString.Content()
		cResult = ""
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if NOT isDigit(c)
				cResult += c
			ok
		next

		@oString.Update(cResult)

		def RemoveNumbersQ()
			This.RemoveNumbers()
			return This

	def NumbersRemoved()
		oCopy = new stzStringNumbers(@oString.Content())
		oCopy.RemoveNumbers()
		return oCopy.Content()

	  #===============================#
	 #     SUM / STATS               #
	#===============================#

	def SumOfNumbers()
		anNums = This.Numbers()
		nSum = 0
		nLen = len(anNums)
		for i = 1 to nLen
			nSum += anNums[i]
		next
		return nSum

	  #===============================#
	 #     MAX / MIN / AVERAGE       #
	#===============================#

	def MaxNumber()
		anNums = This.Numbers()
		nLen = len(anNums)
		if nLen = 0
			StzRaise("No numbers found in the string!")
		ok

		nMax = anNums[1]
		for i = 2 to nLen
			if anNums[i] > nMax
				nMax = anNums[i]
			ok
		next
		return nMax

	def MinNumber()
		anNums = This.Numbers()
		nLen = len(anNums)
		if nLen = 0
			StzRaise("No numbers found in the string!")
		ok

		nMin = anNums[1]
		for i = 2 to nLen
			if anNums[i] < nMin
				nMin = anNums[i]
			ok
		next
		return nMin

	def AverageOfNumbers()
		anNums = This.Numbers()
		nLen = len(anNums)
		if nLen = 0
			StzRaise("No numbers found in the string!")
		ok

		nSum = 0
		for i = 1 to nLen
			nSum += anNums[i]
		next
		return nSum / nLen

	  #===============================#
	 #     NTH / FIRST / LAST       #
	#===============================#

	def NthNumber(n)
		anNums = This.Numbers()
		if n >= 1 and n <= len(anNums)
			return anNums[n]
		ok
		StzRaise("Index out of range!")

	def FirstNumber()
		return This.NthNumber(1)

	def LastNumber()
		return This.NthNumber(This.NumberOfNumbers())

	  #===============================#
	 #     REPLACE NUMBERS           #
	#===============================#

	def ReplaceNumbers(nNewValue)
		cContent = @oString.Content()
		cResult = ""
		nLen = len(cContent)
		cNewStr = "" + nNewValue
		bInNum = 0

		for i = 1 to nLen
			c = substr(cContent, i, 1)

			if isDigit(c)
				if NOT bInNum
					cResult += cNewStr
					bInNum = 1
				ok
			else
				bInNum = 0
				cResult += c
			ok
		next

		@oString.Update(cResult)

		def ReplaceNumbersQ(nNewValue)
			This.ReplaceNumbers(nNewValue)
			return This

	def NumbersReplaced(nNewValue)
		oCopy = new stzStringNumbers(@oString.Content())
		oCopy.ReplaceNumbers(nNewValue)
		return oCopy.Content()

	  #===============================#
	 #     NUMBERS AS STRINGS        #
	#===============================#

	def NumbersAsStrings()
		anNums = This.Numbers()
		acResult = []
		nLen = len(anNums)

		for i = 1 to nLen
			acResult + ("" + anNums[i])
		next

		return acResult

	  #===============================#
	 #     POSITIONS OF NUMBERS      #
	#===============================#

	def PositionsOfNumbers()
		cContent = @oString.Content()
		nLen = len(cContent)
		anPositions = []
		bInNum = 0

		for i = 1 to nLen
			c = substr(cContent, i, 1)

			if isDigit(c)
				if NOT bInNum
					anPositions + i
					bInNum = 1
				ok
			else
				bInNum = 0
			ok
		next

		return anPositions
