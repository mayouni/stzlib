#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGINSERTER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String inserter subclass -- inserting       #
#                  substrings at positions or around matches.   #
#                  For aliases, use stzStringInserterXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringInserter from stzString

	  #======================================================#
	 #   INSERTING BEFORE / AFTER A POSITION                #
	#======================================================#

	def InsertBefore(n, pcSubStr)
		if n = 1
			This.Update(pcSubStr + This.Content())
			return
		ok
		cLeft = This.Section(1, n - 1)
		cRight = This.Section(n, This.NumberOfChars())
		This.Update(cLeft + pcSubStr + cRight)

		def InsertBeforeQ(n, pcSubStr)
			This.InsertBefore(n, pcSubStr)
			return This

		def InsertBeforePosition(n, pcSubStr)
			This.InsertBefore(n, pcSubStr)

	def InsertAfter(n, pcSubStr)
		This.InsertBefore(n + 1, pcSubStr)

		def InsertAfterQ(n, pcSubStr)
			This.InsertAfter(n, pcSubStr)
			return This

		def InsertAfterPosition(n, pcSubStr)
			This.InsertAfter(n, pcSubStr)

	  #======================================================#
	 #   INSERTING BEFORE / AFTER ALL OCCURRENCES           #
	#======================================================#

	def InsertBeforeSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		anPos = This.FindAllCS(pcSubStr, pCaseSensitive)
		nLen = len(anPos)
		nShift = 0
		nNewLen = StzStringQ(pcNewSubStr).NumberOfChars()
		for i = 1 to nLen
			This.InsertBefore(anPos[i] + nShift, pcNewSubStr)
			nShift += nNewLen
		next

		def InsertBeforeSubStringCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertBeforeSubString(pcSubStr, pcNewSubStr)
		This.InsertBeforeSubStringCS(pcSubStr, pcNewSubStr, 1)

	def InsertAfterSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		anPos = This.FindAllCS(pcSubStr, pCaseSensitive)
		nSubLen = StzStringQ(pcSubStr).NumberOfChars()
		nLen = len(anPos)
		nShift = 0
		nNewLen = StzStringQ(pcNewSubStr).NumberOfChars()
		for i = 1 to nLen
			This.InsertAfter(anPos[i] + nSubLen - 1 + nShift, pcNewSubStr)
			nShift += nNewLen
		next

		def InsertAfterSubStringCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertAfterSubString(pcSubStr, pcNewSubStr)
		This.InsertAfterSubStringCS(pcSubStr, pcNewSubStr, 1)

	  #======================================================#
	 #   INSERTING AFTER NTH OCCURRENCE                     #
	#======================================================#

	def InsertAfterNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		nPos = This.FindNthCS(n, pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(nPos, pcNewSubStr)

		def InsertAfterNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertedAfterNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		return This.Copy().InsertAfterNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive).Content()

	def InsertAfterNth(n, pcSubStr, pcNewSubStr)
		This.InsertAfterNthCS(n, pcSubStr, pcNewSubStr, 1)

		def InsertAfterNthQ(n, pcSubStr, pcNewSubStr)
			This.InsertAfterNth(n, pcSubStr, pcNewSubStr)
			return This

	def InsertedAfterNth(n, pcSubStr, pcNewSubStr)
		return This.Copy().InsertAfterNthQ(n, pcSubStr, pcNewSubStr).Content()

	  #======================================================#
	 #   INSERTING AFTER FIRST / LAST OCCURRENCE            #
	#======================================================#

	def InsertAfterFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		nPos = This.FindFirstCS(pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(nPos, pcNewSubStr)

		def InsertAfterFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertAfterFirst(pcSubStr, pcNewSubStr)
		This.InsertAfterFirstCS(pcSubStr, pcNewSubStr, 1)

		def InsertAfterFirstQ(pcSubStr, pcNewSubStr)
			This.InsertAfterFirst(pcSubStr, pcNewSubStr)
			return This

	def InsertedAfterFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		return This.Copy().InsertAfterFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive).Content()

	def InsertedAfterFirst(pcSubStr, pcNewSubStr)
		return This.InsertedAfterFirstCS(pcSubStr, pcNewSubStr, 1)

	#--

	def InsertAfterLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		nPos = This.FindLastCS(pcSubStr, pCaseSensitive)
		This.InsertAfterPosition(nPos, pcNewSubStr)

		def InsertAfterLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertAfterLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertAfterLast(pcSubStr, pcNewSubStr)
		This.InsertAfterLastCS(pcSubStr, pcNewSubStr, 1)

		def InsertAfterLastQ(pcSubStr, pcNewSubStr)
			This.InsertAfterLast(pcSubStr, pcNewSubStr)
			return This

	def InsertedAfterLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		return This.Copy().InsertAfterLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive).Content()

	def InsertedAfterLast(pcSubStr, pcNewSubStr)
		return This.InsertedAfterLastCS(pcSubStr, pcNewSubStr, 1)

	  #======================================================#
	 #   INSERTING BEFORE NTH OCCURRENCE                    #
	#======================================================#

	def InsertBeforeNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		nPos = This.FindNthCS(n, pcSubStr, pCaseSensitive)
		This.InsertBefore(nPos, pcNewSubStr)

		def InsertBeforeNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertedBeforeNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		return This.Copy().InsertBeforeNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive).Content()

	def InsertBeforeNth(n, pcSubStr, pcNewSubStr)
		This.InsertBeforeNthCS(n, pcSubStr, pcNewSubStr, 1)

		def InsertBeforeNthQ(n, pcSubStr, pcNewSubStr)
			This.InsertBeforeNth(n, pcSubStr, pcNewSubStr)
			return This

	def InsertedBeforeNth(n, pcSubStr, pcNewSubStr)
		return This.Copy().InsertBeforeNthQ(n, pcSubStr, pcNewSubStr).Content()

	  #======================================================#
	 #   INSERTING BEFORE FIRST / LAST OCCURRENCE           #
	#======================================================#

	def InsertBeforeFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		nPos = This.FindFirstCS(pcSubStr, pCaseSensitive)
		This.InsertBefore(nPos, pcNewSubStr)

		def InsertBeforeFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertBeforeFirst(pcSubStr, pcNewSubStr)
		This.InsertBeforeFirstCS(pcSubStr, pcNewSubStr, 1)

		def InsertBeforeFirstQ(pcSubStr, pcNewSubStr)
			This.InsertBeforeFirst(pcSubStr, pcNewSubStr)
			return This

	def InsertedBeforeFirstCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		return This.Copy().InsertBeforeFirstCSQ(pcSubStr, pcNewSubStr, pCaseSensitive).Content()

	def InsertedBeforeFirst(pcSubStr, pcNewSubStr)
		return This.InsertedBeforeFirstCS(pcSubStr, pcNewSubStr, 1)

	#--

	def InsertBeforeLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		nPos = This.FindLastCS(pcSubStr, pCaseSensitive)
		This.InsertBefore(nPos, pcNewSubStr)

		def InsertBeforeLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.InsertBeforeLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This

	def InsertBeforeLast(pcSubStr, pcNewSubStr)
		This.InsertBeforeLastCS(pcSubStr, pcNewSubStr, 1)

		def InsertBeforeLastQ(pcSubStr, pcNewSubStr)
			This.InsertBeforeLast(pcSubStr, pcNewSubStr)
			return This

	def InsertedBeforeLastCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		return This.Copy().InsertBeforeLastCSQ(pcSubStr, pcNewSubStr, pCaseSensitive).Content()

	def InsertedBeforeLast(pcSubStr, pcNewSubStr)
		return This.InsertedBeforeLastCS(pcSubStr, pcNewSubStr, 1)

	  #======================================================#
	 #   INSERTING BETWEEN TWO POSITIONS                    #
	#======================================================#

	def InsertSubStringBetweenPositions(pcSubStr, n1, n2)
		if CheckingParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
			if isList(n2) and IsAndNamedParamList(n2)
				n2 = n2[2]
			ok
			if NOT (isNumber(n1) and isNumber(n2))
				StzRaise("Incorrect params types! n1 and n2 must be both numbers.")
			ok
		ok

		if n1 > n2
			nTemp = n1
			n1 = n2
			n2 = nTemp
		ok

		This.InsertAfter(n1, pcSubStr)

		def InsertBetween(pcSubStr, n1, n2)
			This.InsertSubStringBetweenPositions(pcSubStr, n1, n2)

		def InsertBetweenPositions(pcSubStr, n1, n2)
			This.InsertSubStringBetweenPositions(pcSubStr, n1, n2)

	  #======================================================#
	 #   INSERTING BETWEEN TWO SUBSTRINGS                   #
	#======================================================#

	def InsertSubStringBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		if CheckingParams()
			if NOT (isString(pcSubStr) and isString(pcSubStr1) and isString(pcSubStr2))
				StzRaise("Incorrect param types! pcSubStr, pcSubStr1, pcSubStr2 must be all strings.")
			ok
		ok

		if pcSubStr = "" or pcSubStr1 = "" or pcSubStr2 = ""
			return
		ok

		aSections = This.FindAnyBoundedByAsSectionsCS([pcSubStr1, pcSubStr2], pCaseSensitive)
		This.ReplaceSections(aSections, pcSubStr)

		def InsertBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			This.InsertSubStringBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

	def InsertSubStringBetweenSubStrings(pcSubStr, pcSubStr1, pcSubStr2)
		This.InsertSubStringBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, 1)

		def InsertBetweenSubStrings(pcSubStr, pcSubStr1, pcSubStr2)
			This.InsertSubStringBetweenSubStrings(pcSubStr, pcSubStr1, pcSubStr2)

	  #======================================================#
	 #   INSERTING AT MANY POSITIONS                        #
	#======================================================#

	def InsertAfterManyPositions(pcSubStr, panPos)
		if CheckingParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
			if NOT (isList(panPos) and @IsListOfNumbers(panPos))
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		aSorted = StzListQ(panPos).SortedInDescending()
		for n in aSorted
			This.InsertAfter(n, pcSubStr)
		next

		def InsertAfterManyPositionsQ(pcSubStr, panPos)
			This.InsertAfterManyPositions(pcSubStr, panPos)
			return This

	def InsertBeforeManyPositions(pcSubStr, panPos)
		if CheckingParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
			if NOT (isList(panPos) and @IsListOfNumbers(panPos))
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		aSorted = StzListQ(panPos).SortedInDescending()
		for n in aSorted
			This.InsertBefore(n, pcSubStr)
		next

		def InsertBeforeManyPositionsQ(pcSubStr, panPos)
			This.InsertBeforeManyPositions(pcSubStr, panPos)
			return This
