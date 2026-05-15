#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGDUPLICATES           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String duplicates subclass -- duplicate      #
#                  detection, consecutive char management,      #
#                  deduplication operations.                     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringDuplicatesQ(str)
	return new stzStringDuplicates(str)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringDuplicates from stzString

	  #===============================#
	 #     DUPLICATE CHARS           #
	#===============================#

	def DuplicatedChars()
		acAll = []
		acDups = []
		cContent = This.Content()
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

	  #===============================#
	 #     CONSECUTIVE CHARS         #
	#===============================#

	def RemoveConsecutiveDuplicateChars()
		cContent = This.Content()
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

		This.Update(cResult)

		def RemoveConsecutiveDuplicateCharsQ()
			This.RemoveConsecutiveDuplicateChars()
			return This

	def ConsecutiveDuplicateCharsRemoved()
		oCopy = new stzStringDuplicates(This.Content())
		oCopy.RemoveConsecutiveDuplicateChars()
		return oCopy.Content()

	  #===============================#
	 #     DEDUPLICATE SUBSTRINGS    #
	#===============================#

	def RemoveDuplicateSubStringCS(pcSubStr, pCaseSensitive)
		oFinder = StzStringFinderQ(This.Content())
		anPos = oFinder.FindCS(pcSubStr, pCaseSensitive)
		if len(anPos) <= 1
			return
		ok

		nLenSub = Q(pcSubStr).NumberOfChars()
		cContent = This.Content()

		for i = len(anPos) to 2 step -1
			nPos = anPos[i]
			cBefore = substr(cContent, 1, nPos - 1)
			cAfter = ""
			if nPos + nLenSub <= len(cContent)
				cAfter = substr(cContent, nPos + nLenSub)
			ok
			cContent = cBefore + cAfter
		next

		This.Update(cContent)

	def RemoveDuplicateSubString(pcSubStr)
		This.RemoveDuplicateSubStringCS(pcSubStr, 1)

