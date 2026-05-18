#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGWORDS             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String words -- Wraps stzString via          #
#                  composition. Word extraction, counting,      #
#                  unique words, word-level ops.                 #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringWords

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringWords! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     WORDS                     #
	#===============================#

	def Words()
		acResult = []
		cContent = @oString.Content()
		cWord = ""
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if c = " " or c = char(9) or c = char(10) or c = char(13)
				if cWord != ""
					acResult + cWord
					cWord = ""
				ok
			else
				cWord += c
			ok
		next

		if cWord != ""
			acResult + cWord
		ok

		return acResult

		def WordsQ()
			return new stzList(This.Words())

	  #===============================#
	 #     NUMBER OF WORDS           #
	#===============================#

	def NumberOfWords()
		return len(This.Words())

		def CountWords()
			return This.NumberOfWords()

		def HowManyWords()
			return This.NumberOfWords()

	  #===============================#
	 #     NTH WORD                  #
	#===============================#

	def NthWord(n)
		acWords = This.Words()
		if n >= 1 and n <= len(acWords)
			return acWords[n]
		ok
		StzRaise("Index out of range!")

		def Word(n)
			return This.NthWord(n)

	def FirstWord()
		return This.NthWord(1)

	def LastWord()
		return This.NthWord(This.NumberOfWords())

	  #===============================#
	 #     FIRST/LAST N WORDS       #
	#===============================#

	def NFirstWords(n)
		acWords = This.Words()
		nTotal = len(acWords)
		if n > nTotal
			n = nTotal
		ok

		acResult = []
		for i = 1 to n
			acResult + acWords[i]
		next
		return acResult

	def NLastWords(n)
		acWords = This.Words()
		nTotal = len(acWords)
		if n > nTotal
			n = nTotal
		ok

		acResult = []
		nStart = nTotal - n + 1
		for i = nStart to nTotal
			acResult + acWords[i]
		next
		return acResult

	  #===============================#
	 #     WORD AT POSITION          #
	#===============================#

	def WordAtPosition(n)
		cContent = @oString.Content()
		nLen = len(cContent)

		if n < 1 or n > nLen
			StzRaise("Position out of range!")
		ok

		nWordIndex = 0
		bInWord = 0
		cWord = ""

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			bIsSpace = (c = " " or c = char(9) or c = char(10) or c = char(13))

			if NOT bIsSpace
				if NOT bInWord
					nWordIndex++
					bInWord = 1
					cWord = ""
				ok
				cWord += c
			else
				if bInWord
					bInWord = 0
				ok
			ok

			if i = n
				if bIsSpace
					return ""
				else
					# Finish reading the rest of this word
					for j = i + 1 to nLen
						cNext = substr(cContent, j, 1)
						if cNext = " " or cNext = char(9) or cNext = char(10) or cNext = char(13)
							exit
						ok
						cWord += cNext
					next
					return cWord
				ok
			ok
		next

		return ""

	  #===============================#
	 #     UNIQUE WORDS              #
	#===============================#

	def UniqueWords()
		acWords = This.Words()
		acResult = []
		nLen = len(acWords)

		for i = 1 to nLen
			bFound = 0
			nResLen = len(acResult)
			for j = 1 to nResLen
				if lower(acResult[j]) = lower(acWords[i])
					bFound = 1
					exit
				ok
			next
			if NOT bFound
				acResult + acWords[i]
			ok
		next

		return acResult

		def WordsU()
			return This.UniqueWords()

	  #===============================#
	 #     LONGEST / SHORTEST WORD   #
	#===============================#

	def LongestWord()
		acWords = This.Words()
		nTotal = len(acWords)
		if nTotal = 0
			return ""
		ok

		cLongest = acWords[1]
		for i = 2 to nTotal
			if len(acWords[i]) > len(cLongest)
				cLongest = acWords[i]
			ok
		next
		return cLongest

	def ShortestWord()
		acWords = This.Words()
		nTotal = len(acWords)
		if nTotal = 0
			return ""
		ok

		cShortest = acWords[1]
		for i = 2 to nTotal
			if len(acWords[i]) < len(cShortest)
				cShortest = acWords[i]
			ok
		next
		return cShortest

	def AverageWordLength()
		acWords = This.Words()
		nTotal = len(acWords)
		if nTotal = 0
			return 0
		ok

		nSum = 0
		for i = 1 to nTotal
			nSum += len(acWords[i])
		next
		return nSum / nTotal

	  #===============================#
	 #     WORD FREQUENCIES          #
	#===============================#

	def WordFrequencies()
		acWords = This.Words()
		nTotal = len(acWords)
		acUnique = []
		anCounts = []

		for i = 1 to nTotal
			cLow = lower(acWords[i])
			bFound = 0
			nULen = len(acUnique)
			for j = 1 to nULen
				if lower(acUnique[j]) = cLow
					anCounts[j] = anCounts[j] + 1
					bFound = 1
					exit
				ok
			next
			if NOT bFound
				acUnique + acWords[i]
				anCounts + 1
			ok
		next

		aResult = []
		nULen = len(acUnique)
		for i = 1 to nULen
			aResult + [acUnique[i], anCounts[i]]
		next
		return aResult

	def MostFrequentWord()
		aFreqs = This.WordFrequencies()
		nFLen = len(aFreqs)
		if nFLen = 0
			return ""
		ok

		cBest = aFreqs[1][1]
		nBest = aFreqs[1][2]
		for i = 2 to nFLen
			if aFreqs[i][2] > nBest
				nBest = aFreqs[i][2]
				cBest = aFreqs[i][1]
			ok
		next
		return cBest

	  #===============================#
	 #     WORD EXISTS               #
	#===============================#

	def ContainsWordCS(pcWord, pCaseSensitive)
		bCase = @CaseSensitive(pCaseSensitive)
		acWords = This.Words()
		nLen = len(acWords)

		for i = 1 to nLen
			if bCase
				if acWords[i] = pcWord
					return 1
				ok
			else
				if lower(acWords[i]) = lower(pcWord)
					return 1
				ok
			ok
		next
		return 0

	def ContainsWord(pcWord)
		return This.ContainsWordCS(pcWord, 1)

	  #===============================#
	 #     REPLACE WORD              #
	#===============================#

	def ReplaceWordCS(pcOldWord, pcNewWord, pCaseSensitive)
		bCase = @CaseSensitive(pCaseSensitive)
		acWords = This.Words()
		nLen = len(acWords)
		acResult = []

		for i = 1 to nLen
			if bCase
				if acWords[i] = pcOldWord
					acResult + pcNewWord
				else
					acResult + acWords[i]
				ok
			else
				if lower(acWords[i]) = lower(pcOldWord)
					acResult + pcNewWord
				else
					acResult + acWords[i]
				ok
			ok
		next

		cResult = ""
		nResLen = len(acResult)
		for i = 1 to nResLen
			if i > 1
				cResult += " "
			ok
			cResult += acResult[i]
		next

		@oString.Update(cResult)

		def ReplaceWordCSQ(pcOldWord, pcNewWord, pCaseSensitive)
			This.ReplaceWordCS(pcOldWord, pcNewWord, pCaseSensitive)
			return This

	def ReplaceWord(pcOldWord, pcNewWord)
		This.ReplaceWordCS(pcOldWord, pcNewWord, 1)

		def ReplaceWordQ(pcOldWord, pcNewWord)
			This.ReplaceWord(pcOldWord, pcNewWord)
			return This

	  #===============================#
	 #     REMOVE WORD               #
	#===============================#

	def RemoveWordCS(pcWord, pCaseSensitive)
		bCase = @CaseSensitive(pCaseSensitive)
		acWords = This.Words()
		nLen = len(acWords)
		acResult = []

		for i = 1 to nLen
			if bCase
				if acWords[i] != pcWord
					acResult + acWords[i]
				ok
			else
				if lower(acWords[i]) != lower(pcWord)
					acResult + acWords[i]
				ok
			ok
		next

		cResult = ""
		nResLen = len(acResult)
		for i = 1 to nResLen
			if i > 1
				cResult += " "
			ok
			cResult += acResult[i]
		next

		@oString.Update(cResult)

		def RemoveWordCSQ(pcWord, pCaseSensitive)
			This.RemoveWordCS(pcWord, pCaseSensitive)
			return This

	def RemoveWord(pcWord)
		This.RemoveWordCS(pcWord, 1)

		def RemoveWordQ(pcWord)
			This.RemoveWord(pcWord)
			return This
