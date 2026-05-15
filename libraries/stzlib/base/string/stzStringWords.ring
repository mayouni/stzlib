#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGWORDS             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String words subclass -- word extraction,   #
#                  counting, unique words, word-level ops.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringWordsQ(str)
	return new stzStringWords(str)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringWords from stzString

	  #===============================#
	 #     WORDS                     #
	#===============================#

	def Words()
		acResult = []
		cContent = This.Content()
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

