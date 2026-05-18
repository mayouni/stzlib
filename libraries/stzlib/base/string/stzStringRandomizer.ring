#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGRANDOMIZER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String randomizer -- Wraps stzString via     #
#                  composition. Shuffling, random char/substring #
#                  extraction, random generation operations.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringRandomizer

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringRandomizer! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     SHUFFLE                   #
	#===============================#

	def Shuffle()
		cContent = @oString.Content()
		nLen = len(cContent)
		acChars = []

		for i = 1 to nLen
			acChars + substr(cContent, i, 1)
		next

		for i = nLen to 2 step -1
			j = random(i - 1) + 1
			cTemp = acChars[i]
			acChars[i] = acChars[j]
			acChars[j] = cTemp
		next

		cResult = ""
		for i = 1 to nLen
			cResult += acChars[i]
		next

		@oString.Update(cResult)

		def ShuffleQ()
			This.Shuffle()
			return This

	def Shuffled()
		oCopy = new stzStringRandomizer(@oString.Content())
		oCopy.Shuffle()
		return oCopy.Content()

	  #===============================#
	 #     RANDOM CHAR               #
	#===============================#

	def RandomChar()
		nLen = @oString.NumberOfChars()
		if nLen = 0
			return ""
		ok
		n = random(nLen - 1) + 1
		return substr(@oString.Content(), n, 1)

	def RandomChars(n)
		acResult = []
		for i = 1 to n
			acResult + This.RandomChar()
		next
		return acResult

	def NRandomChars(n)
		# Returns n unique random chars (no duplicates)
		cContent = @oString.Content()
		nLen = len(cContent)

		# Build list of unique chars in the string
		acUnique = []
		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if ring_find(acUnique, c) = 0
				acUnique + c
			ok
		next

		nAvailable = len(acUnique)
		if n > nAvailable
			n = nAvailable
		ok

		# Shuffle unique chars and take first n
		for i = nAvailable to 2 step -1
			j = random(i - 1) + 1
			cTemp = acUnique[i]
			acUnique[i] = acUnique[j]
			acUnique[j] = cTemp
		next

		acResult = []
		for i = 1 to n
			acResult + acUnique[i]
		next

		return acResult

	  #===============================#
	 #     RANDOM SECTION            #
	#===============================#

	def RandomSection(nLen)
		nMax = @oString.NumberOfChars()
		if nLen > nMax
			nLen = nMax
		ok
		if nLen <= 0
			return ""
		ok

		nStart = random(nMax - nLen) + 1
		return substr(@oString.Content(), nStart, nLen)

		def RandomSubString(nLen)
			return This.RandomSection(nLen)

	  #===============================#
	 #     RANDOM WORD               #
	#===============================#

	def RandomWord()
		cContent = @oString.Content()
		acWords = split(cContent, " ")
		nLen = len(acWords)
		if nLen = 0
			return ""
		ok
		n = random(nLen - 1) + 1
		return acWords[n]

	  #===============================#
	 #     SHUFFLE WORDS             #
	#===============================#

	def ShuffleWords()
		cContent = @oString.Content()
		acWords = split(cContent, " ")
		nLen = len(acWords)

		for i = nLen to 2 step -1
			j = random(i - 1) + 1
			cTemp = acWords[i]
			acWords[i] = acWords[j]
			acWords[j] = cTemp
		next

		cResult = ""
		for i = 1 to nLen
			if i > 1
				cResult += " "
			ok
			cResult += acWords[i]
		next

		@oString.Update(cResult)

		def ShuffleWordsQ()
			This.ShuffleWords()
			return This

	def WordsShuffled()
		oCopy = new stzStringRandomizer(@oString.Content())
		oCopy.ShuffleWords()
		return oCopy.Content()

	  #===============================#
	 #     RANDOM CASE               #
	#===============================#

	def RandomCase()
		cContent = @oString.Content()
		nLen = len(cContent)
		cResult = ""

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if random(1) = 1
				cResult += upper(c)
			else
				cResult += lower(c)
			ok
		next

		@oString.Update(cResult)

		def RandomCaseQ()
			This.RandomCase()
			return This

	def RandomCased()
		oCopy = new stzStringRandomizer(@oString.Content())
		oCopy.RandomCase()
		return oCopy.Content()

	  #===============================#
	 #     RANDOM INSERT             #
	#===============================#

	def RandomInsert(cStr)
		cContent = @oString.Content()
		nLen = len(cContent)
		nPos = random(nLen) + 1

		if nPos > nLen
			@oString.Update(cContent + cStr)
		else
			cBefore = substr(cContent, 1, nPos - 1)
			cAfter = substr(cContent, nPos)
			@oString.Update(cBefore + cStr + cAfter)
		ok

	  #===============================#
	 #     RANDOM REMOVE             #
	#===============================#

	def RandomRemove(n)
		cContent = @oString.Content()
		nLen = len(cContent)
		if n >= nLen
			@oString.Update("")
			return
		ok

		# Build list of char indices
		anIndices = []
		for i = 1 to nLen
			anIndices + i
		next

		# Pick n random indices to remove (shuffle and take first n)
		for i = nLen to 2 step -1
			j = random(i - 1) + 1
			nTemp = anIndices[i]
			anIndices[i] = anIndices[j]
			anIndices[j] = nTemp
		next

		# Collect indices to remove
		anRemove = []
		for i = 1 to n
			anRemove + anIndices[i]
		next

		# Build result keeping chars not in remove list
		cResult = ""
		for i = 1 to nLen
			if ring_find(anRemove, i) = 0
				cResult += substr(cContent, i, 1)
			ok
		next

		@oString.Update(cResult)
