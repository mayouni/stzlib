#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGDUPLICATES           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String duplicates -- Wraps stzString via    #
#                composition. Duplicate detection, consecutive #
#                char management, deduplication operations.    #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringDuplicates

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringDuplicates! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     DUPLICATE CHARS           #
	#===============================#

	def DuplicatedChars()
		pH = @oString.Engine()
		pR = StzEngineStringDuplicatedChars(pH)
		cDups = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _SplitNullDelimited(cDups)

	def HasDuplicatedChars()
		return len(This.DuplicatedChars()) > 0

	def NumberOfDuplicatedChars()
		return len(This.DuplicatedChars())

	  #===============================#
	 #     UNIQUE CHARS              #
	#===============================#

	def UniqueChars()
		pH = @oString.Engine()
		pR = StzEngineStringUniqueChars(pH)
		cUnique = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		if cUnique = ""
			return []
		ok
		# Split unique chars string into individual characters
		pU = StzEngineString(cUnique)
		pSplit = StzEngineStringCharsSplit(pU)
		cJoined = StzEngineStringData(pSplit)
		StzEngineStringFree(pSplit)
		StzEngineStringFree(pU)
		return _SplitNullDelimited(cJoined)

	def NumberOfUniqueChars()
		pH = @oString.Engine()
		return StzEngineStringCountUniqueChars(pH)

	  #===============================#
	 #     CONSECUTIVE CHARS         #
	#===============================#

	def HasConsecutiveDuplicates()
		acChars = @oString.Chars()
		nLen = len(acChars)
		if nLen < 2
			return 0
		ok

		for i = 2 to nLen
			if acChars[i] = acChars[i - 1]
				return 1
			ok
		next

		return 0

	def RemoveConsecutiveDuplicateChars()
		pH = @oString.Engine()
		pR = StzEngineStringRemoveConsecutiveDuplicates(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def RemoveConsecutiveDuplicateCharsQ()
			This.RemoveConsecutiveDuplicateChars()
			return This

	def ConsecutiveDuplicateCharsRemoved()
		pH = @oString.Engine()
		pR = StzEngineStringRemoveConsecutiveDuplicates(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     REMOVE ALL DUPLICATES     #
	#===============================#

	def RemoveAllDuplicateChars()
		pH = @oString.Engine()
		pR = StzEngineStringUniqueChars(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def RemoveAllDuplicateCharsQ()
			This.RemoveAllDuplicateChars()
			return This

	def AllDuplicateCharsRemoved()
		pH = @oString.Engine()
		pR = StzEngineStringUniqueChars(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     DEDUPLICATE SUBSTRINGS    #
	#===============================#

	def RemoveDuplicateSubStringCS(pcSubStr, pCaseSensitive)
		oFinder = new stzStringFinder(@oString)
		anPos = oFinder.FindCS(pcSubStr, pCaseSensitive)
		if len(anPos) <= 1
			return
		ok

		nLenSub = StzLen(pcSubStr)

		# Remove from end to start to preserve earlier positions
		for i = len(anPos) to 2 step -1
			nPos = anPos[i]
			@oString.RemoveSection(nPos, nPos + nLenSub - 1)
		next

		def RemoveDuplicateSubStringCSQ(pcSubStr, pCaseSensitive)
			This.RemoveDuplicateSubStringCS(pcSubStr, pCaseSensitive)
			return This

	def RemoveDuplicateSubString(pcSubStr)
		This.RemoveDuplicateSubStringCS(pcSubStr, 1)

		def RemoveDuplicateSubStringQ(pcSubStr)
			This.RemoveDuplicateSubString(pcSubStr)
			return This

	def DuplicateSubStringRemovedCS(pcSubStr, pCaseSensitive)
		oCopy = new stzStringDuplicates(@oString.Content())
		oCopy.RemoveDuplicateSubStringCS(pcSubStr, pCaseSensitive)
		return oCopy.Content()

	def DuplicateSubStringRemoved(pcSubStr)
		return This.DuplicateSubStringRemovedCS(pcSubStr, 1)
