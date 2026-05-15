#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZSTRINGNUMBERS             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String numbers subclass -- extracting and   #
#                  working with numbers embedded in strings.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringNumbers from stzString

	  #===============================#
	 #     EXTRACT NUMBERS           #
	#===============================#

	def Numbers()
		cContent = This.Content()
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
		cContent = This.Content()
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
		cContent = This.Content()
		cResult = ""
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if NOT isDigit(c)
				cResult += c
			ok
		next

		This.Update(cResult)

		def RemoveNumbersQ()
			This.RemoveNumbers()
			return This

	def NumbersRemoved()
		oCopy = new stzStringNumbers(This.Content())
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

