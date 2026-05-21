#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTFINDER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List finder subclass -- finding items,      #
#                  positions, anti-positions, occurrences.      #
#                  For aliases, use stzListFinderXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListFinder from stzList

	  #======================================#
	 #  FINDING ALL OCCURRENCES OF AN ITEM  #
	#======================================#

	def FindAllOccurrencesCS(pItem, pCaseSensitive)

		if CheckingParams()

			if isList(pItem) and IsOfNamedParamList(pItem)
				pItem = pItem[2]
			ok

			if isObject(pItem) and NOT @IsNamedObject(pItem)
				StzRaise("Can't find an unnamed object!")
			ok

			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				pCaseSensitive = pCaseSensitive[2]
			ok

		ok

		aContent = This.Content()
		nLen = len(aContent)

		if EarlyCheck()
			if nLen = 0
				return []
			ok
		ok

		anResult = @FindAllCS_NbrOrStr( aContent, pItem, pCaseSensitive)

		if isList(anResult) and len(anResult) > 0
			return anResult

		else
			cItem = ""
			if isList(pItem)
				cItem = @@(pItem)

			but isObject(pItem) and @IsStzObject(pItem) and pItem.IsNamed()
				cItem = pItem.ObjectName()

			else
				cItem = Q(pItem).Stringified()

			ok

			aRawContent = This.Content()
			_nLenRaw = len(aRawContent)
			acContent = []
			for _k = 1 to _nLenRaw
				acContent + ("" + aRawContent[_k])
			next
			nLen = len(acContent)

			if pCaseSensitive = 0
				cItem = StzLower(cItem)

				for i = 1 to nLen
					if NOT ring_isLower(acContent[i])
						acContent[i] = StzLower(acContent[i])
					ok
				next
			ok

			anResult = []

			for i = 1 to nLen
				if acContent[i] = cItem
					anResult + i
				ok
			next

			return anResult
		ok

		def FindAllOccurrencesCSQ(pItem, pCaseSensitive)
			return This.FindAllOccurrencesCSQRT(pItem, pCaseSensitive, :stzList)

		def FindAllOccurrencesCSQRT(pItem, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType, [ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllCS(pItem, pCaseSensitive) )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllCS(pItem, pCaseSensitive) )
			other
				StzRaise("Unsupported type!")
			off

		def FindAllCS(pItem, pCaseSensitive)
			return This.FindAllOccurrencesCS(pItem, pCaseSensitive)

		def FindCS(pItem, pCaseSensitive)
			if isList(pItem) and IsItemNamedParamList(pItem)
				pItem = pItem[2]
			ok
			return This.FindAllOccurrencesCS(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindAllOccurrences(pItem)
		aResult = This.FindAllOccurrencesCS(pItem, 1)
		return aResult

		def FindAllOccurrencesQ(pItem)
			return This.FindAllOccurrencesQRT(pItem, :stzList)

		def FindAllOccurrencesQRT(pItem, pcReturnType)
			return This.FindAllOccurrencesCSQRT(pItem, 1, pcReturnType)

		def FindAll(pItem)
			return This.FindAllOccurrences(pItem)

		def Find(pItem)
			if isList(pItem) and IsItemNamedParamList(pItem)
				pItem = pItem[2]
			ok
			return This.FindAllOccurrences(pItem)

	  #====================================================#
	 #  FINDING POSITIONS WHERE THE ITEM DOES NOT EXIST   #
	#====================================================#

	def AntiFindCS(pItem, pCaseSensitive)
		anPos = This.FindAllCS(pItem, pCaseSensitive)
		anResult = Q(1:This.NumberOfItems()) - These(anPos)
		return anResult

	def AntiFind(pItem)
		return This.AntiFindCS(pItem, 1)

	  #--------------------------------------------------#
	 #  FINDING SECTIONS WHERE THE ITEM DOES NOT EXIST  #
	#--------------------------------------------------#

	def AntiFindAsSectionsCS(pItem, pCaseSensitive)
		anPos = This.FindCS(pItem, pCaseSensitive)
		aResult = StzListQ(1:This.NumberOfItems()).AntiPositionsZZ(anPos)
		return aResult

		def AntiFindCSZZ(pItem, pCaseSensitive)
			return This.AntiFindAsSectionsCS(pItem, pCaseSensitive)

	def AntiFindAsSections(pItem)
		return This.AntiFindAsSectionsCS(pItem, 1)

		def AntiFindZZ(pItem)
			return This.AntiFindAsSections(pItem)

	  #-----------------------------------------------------------------#
	 #  GETTING THE ANTI-POSITIONS OF THE GIVEN POSITIONS IN THE LIST  #
	#-----------------------------------------------------------------#

	def AntiPositions(anPos)

		if CheckingParams()
			if isList(anPos) and IsOfNamedParamList(anPos)
				anPos = anPos[2]
			ok

			if NOT isList(anPos)
				Stzraise("Incorrect param type! anPos must be a list of numbers.")
			ok
		ok

		nTotal = len(@aContent)
		nPosLen = len(anPos)

		aMarked = []
		for _k = 1 to nTotal
			aMarked + 0
		next
		for i = 1 to nPosLen
			n = anPos[i]
			if n >= 1 and n <= nTotal
				aMarked[n] = 1
			ok
		next

		anResult = []
		for i = 1 to nTotal
			if aMarked[i] != 1
				anResult + i
			ok
		next

		return anResult

	  #=================================================#
	 #    FINDING N OCCURRENCES OF AN ITEM             #
	#=================================================#

	def FindNOccurrencesCS(n, pItem, pCaseSensitive)

		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok

		anAllPositions = This.FindAllCS(pItem, pCaseSensitive)

		if n > len(anAllPositions)
			return anAllPositions
		ok

		aResult = []
		for i = 1 to n
			aResult + anAllPositions[i]
		next

		return aResult

	def FindNOccurrences(n, pItem)
		return This.FindNOccurrencesCS(n, pItem, 1)

	  #==================================================#
	 #  FINDING FIRST OCCURRENCE OF AN ITEM IN THE LIST #
	#==================================================#

	def FindFirstCS(pItem, pCaseSensitive)
		anPos = This.FindAllCS(pItem, pCaseSensitive)
		if len(anPos) > 0
			return anPos[1]
		else
			return 0
		ok

	def FindFirst(pItem)
		return This.FindFirstCS(pItem, 1)

	  #=================================================#
	 #  FINDING LAST OCCURRENCE OF AN ITEM IN THE LIST #
	#=================================================#

	def FindLastCS(pItem, pCaseSensitive)
		anPos = This.FindAllCS(pItem, pCaseSensitive)
		nLen = len(anPos)
		if nLen > 0
			return anPos[nLen]
		else
			return 0
		ok

	def FindLast(pItem)
		return This.FindLastCS(pItem, 1)

	  #=============================================#
	 #   FINDING NTH OCCURRENCE OF AN ITEM        #
	#=============================================#

	def FindNthCS(n, pItem, pCaseSensitive)

		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok

		anPos = This.FindAllCS(pItem, pCaseSensitive)
		nLen = len(anPos)

		if n > nLen or n < 1
			return 0
		ok

		return anPos[n]

	def FindNth(n, pItem)
		return This.FindNthCS(n, pItem, 1)

	  #=============================================#
	 #   FINDING GIVEN OCCURRENCES OF AN ITEM     #
	#=============================================#

	def FindGivenOccurrencesCS(panOccurrences, pItem, pCaseSensitive)

		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok

		anPos = This.FindAllCS(pItem, pCaseSensitive)
		nLenPos = len(anPos)
		nLenOcc = len(panOccurrences)

		anResult = []
		for i = 1 to nLenOcc
			n = panOccurrences[i]
			if n >= 1 and n <= nLenPos
				anResult + anPos[n]
			ok
		next

		return anResult

	def FindGivenOccurrences(panOccurrences, pItem)
		return This.FindGivenOccurrencesCS(panOccurrences, pItem, 1)

	  #============================================#
	 #   FINDING THE OCCURRENCES OF MANY ITEMS   #
	#============================================#

	def FindManyCS(paItems, pCaseSensitive)
		nLen = len(paItems)
		anResult = []

		for i = 1 to nLen
			anPos = This.FindAllCS(paItems[i], pCaseSensitive)
			nLenPos = len(anPos)
			for j = 1 to nLenPos
				anResult + anPos[j]
			next
		next

		anResult = new stzList(anResult).Sorted()
		return anResult

	def FindMany(paItems)
		return This.FindManyCS(paItems, 1)

	  #===============================================#
	 #  FINDING ALL EXCEPT FIRST OCCURRENCE         #
	#===============================================#

	def FindAllExceptFirstCS(pItem, pCaseSensitive)
		anPos = This.FindAllCS(pItem, pCaseSensitive)
		nLen = len(anPos)

		if nLen <= 1
			return []
		ok

		aResult = []
		for i = 2 to nLen
			aResult + anPos[i]
		next

		return aResult

	def FindAllExceptFirst(pItem)
		return This.FindAllExceptFirstCS(pItem, 1)

	  #==============================================#
	 #  FINDING ALL EXCEPT LAST OCCURRENCE         #
	#==============================================#

	def FindAllExceptLastCS(pItem, pCaseSensitive)
		anPos = This.FindAllCS(pItem, pCaseSensitive)
		nLen = len(anPos)

		if nLen <= 1
			return []
		ok

		aResult = []
		for i = 1 to nLen - 1
			aResult + anPos[i]
		next

		return aResult

	def FindAllExceptLast(pItem)
		return This.FindAllExceptLastCS(pItem, 1)

	  #=============================================#
	 #  NUMBER OF OCCURRENCES OF AN ITEM          #
	#=============================================#

	def NumberOfOccurrenceCS(pItem, pCaseSensitive)
		return len( This.FindAllCS(pItem, pCaseSensitive) )

	def NumberOfOccurrence(pItem)
		return This.NumberOfOccurrenceCS(pItem, 1)

	  #=====================================#
	 #  FINDING NEXT NTH OCCURRENCE       #
	#=====================================#

	def FindNextNthOccurrenceCS(n, pItem, pnStartingAt, pCaseSensitive)

		if isList(pnStartingAt) and IsStartingAtNamedParamList(pnStartingAt)
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if pnStartingAt = :First or pnStartingAt = :FirstItem
				pnStartingAt = 1
			but pnStartingAt = :Last or pnStartingAt = :LastItem
				pnStartingAt = This.NumberOfItems()
			ok
		ok

		anPos = This.FindAllCS(pItem, pCaseSensitive)
		nLen = len(anPos)

		nCount = 0
		for i = 1 to nLen
			if anPos[i] > pnStartingAt
				nCount++
				if nCount = n
					return anPos[i]
				ok
			ok
		next

		return 0

	def FindNextNthOccurrence(n, pItem, pnStartingAt)
		return This.FindNextNthOccurrenceCS(n, pItem, pnStartingAt, 1)

	  #=====================================#
	 #  FINDING NEXT OCCURRENCE           #
	#=====================================#

	def FindNextOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		return This.FindNextNthOccurrenceCS(1, pItem, pnStartingAt, pCaseSensitive)

	def FindNextOccurrence(pItem, pnStartingAt)
		return This.FindNextOccurrenceCS(pItem, pnStartingAt, 1)

	  #========================================#
	 #  FINDING PREVIOUS NTH OCCURRENCE      #
	#========================================#

	def FindPreviousNthOccurrenceCS(n, pItem, pnStartingAt, pCaseSensitive)

		if isList(pnStartingAt) and IsStartingAtNamedParamList(pnStartingAt)
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if pnStartingAt = :First or pnStartingAt = :FirstItem
				pnStartingAt = 1
			but pnStartingAt = :Last or pnStartingAt = :LastItem
				pnStartingAt = This.NumberOfItems()
			ok
		ok

		anPos = This.FindAllCS(pItem, pCaseSensitive)
		nLen = len(anPos)

		nCount = 0
		for i = nLen to 1 step -1
			if anPos[i] < pnStartingAt
				nCount++
				if nCount = n
					return anPos[i]
				ok
			ok
		next

		return 0

	def FindPreviousNthOccurrence(n, pItem, pnStartingAt)
		return This.FindPreviousNthOccurrenceCS(n, pItem, pnStartingAt, 1)

	  #========================================#
	 #  FINDING PREVIOUS OCCURRENCE          #
	#========================================#

	def FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		return This.FindPreviousNthOccurrenceCS(1, pItem, pnStartingAt, pCaseSensitive)

	def FindPreviousOccurrence(pItem, pnStartingAt)
		return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, 1)

	  #=====================================#
	 #  COUNTING ITEMS UNDER A CONDITION  #
	#=====================================#

	def CountItemsW(pcCondition)

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		return This.CountW(pcCondition)

	  #==============================#
	 #  CONTAINS                    #
	#==============================#

	def ContainsCS(pItem, pCaseSensitive)
		nLen = len(This.FindAllCS(pItem, pCaseSensitive))
		if nLen > 0
			return 1
		else
			return 0
		ok

	def Contains(pItem)
		return This.ContainsCS(pItem, 1)

	def ContainsManyCS(paItems, pCaseSensitive)
		nLen = len(paItems)
		for i = 1 to nLen
			if NOT This.ContainsCS(paItems[i], pCaseSensitive)
				return 0
			ok
		next
		return 1

	def ContainsMany(paItems)
		return This.ContainsManyCS(paItems, 1)
