#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGDUPLICATES           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String duplicates -- Wraps stzString via     #
#                  composition. Duplicate detection, consecutive #
#                  char management, deduplication operations.    #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

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
		acAll = []
		acDups = []
		cContent = @oString.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if ring_find(acAll, c) > 0
				if ring_find(acDups, c) = 0
					acDups + c
				ok
			else
				acAll + c
			ok
		next

		return acDups

	def HasDuplicatedChars()
		return len(This.DuplicatedChars()) > 0

	def NumberOfDuplicatedChars()
		return len(This.DuplicatedChars())

	  #===============================#
	 #     UNIQUE CHARS              #
	#===============================#

	def UniqueChars()
		cContent = @oString.Content()
		nLen = len(cContent)
		acUnique = []

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if ring_find(acUnique, c) = 0
				acUnique + c
			ok
		next

		return acUnique

	def NumberOfUniqueChars()
		return len(This.UniqueChars())

	  #===============================#
	 #     CONSECUTIVE CHARS         #
	#===============================#

	def HasConsecutiveDuplicates()
		cContent = @oString.Content()
		nLen = len(cContent)
		if nLen < 2
			return 0
		ok

		for i = 2 to nLen
			if substr(cContent, i, 1) = substr(cContent, i - 1, 1)
				return 1
			ok
		next

		return 0

	def RemoveConsecutiveDuplicateChars()
		cContent = @oString.Content()
		nLen = len(cContent)
		if nLen = 0
			return
		ok

		cResult = substr(cContent, 1, 1)
		for i = 2 to nLen
			c = substr(cContent, i, 1)
			cPrev = substr(cContent, i - 1, 1)
			if c != cPrev
				cResult += c
			ok
		next

		@oString.Update(cResult)

		def RemoveConsecutiveDuplicateCharsQ()
			This.RemoveConsecutiveDuplicateChars()
			return This

	def ConsecutiveDuplicateCharsRemoved()
		oCopy = new stzStringDuplicates(@oString.Content())
		oCopy.RemoveConsecutiveDuplicateChars()
		return oCopy.Content()

	  #===============================#
	 #     REMOVE ALL DUPLICATES     #
	#===============================#

	def RemoveAllDuplicateChars()
		cContent = @oString.Content()
		nLen = len(cContent)
		acSeen = []
		cResult = ""

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if ring_find(acSeen, c) = 0
				acSeen + c
				cResult += c
			ok
		next

		@oString.Update(cResult)

		def RemoveAllDuplicateCharsQ()
			This.RemoveAllDuplicateChars()
			return This

	def AllDuplicateCharsRemoved()
		oCopy = new stzStringDuplicates(@oString.Content())
		oCopy.RemoveAllDuplicateChars()
		return oCopy.Content()

	  #===============================#
	 #     DEDUPLICATE SUBSTRINGS    #
	#===============================#

	def RemoveDuplicateSubStringCS(pcSubStr, pCaseSensitive)
		oFinder = new stzStringFinder(@oString)
		anPos = oFinder.FindCS(pcSubStr, pCaseSensitive)
		if len(anPos) <= 1
			return
		ok

		nLenSub = Q(pcSubStr).NumberOfChars()
		cContent = @oString.Content()

		for i = len(anPos) to 2 step -1
			nPos = anPos[i]
			cBefore = substr(cContent, 1, nPos - 1)
			cAfter = ""
			if nPos + nLenSub <= len(cContent)
				cAfter = substr(cContent, nPos + nLenSub)
			ok
			cContent = cBefore + cAfter
		next

		@oString.Update(cContent)

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
