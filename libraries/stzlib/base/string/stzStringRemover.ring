#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGREMOVER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String remover subclass -- removing         #
#                  substrings by value, position, or section.   #
#                  For aliases, use stzStringRemoverXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringRemover

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringRemover! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   REMOVING ALL OCCURRENCES OF A GIVEN SUBSTRING      #
	#======================================================#

	def RemoveCS(pcSubStr, pCaseSensitive)
		new stzStringReplacer(@oString).ReplaceCS(pcSubStr, "", pCaseSensitive)

		def RemoveCSQ(pcSubStr, pCaseSensitive)
			This.RemoveCS(pcSubStr, pCaseSensitive)
			return This

		def RemoveAllCS(pcSubStr, pCaseSensitive)
			This.RemoveCS(pcSubStr, pCaseSensitive)

			def RemoveAllCSQ(pcSubStr, pCaseSensitive)
				return This.RemoveCSQ(pcSubStr, pCaseSensitive)

	def Remove(pcSubStr)
		This.RemoveCS(pcSubStr, 1)

		def RemoveQ(pcSubStr)
			This.Remove(pcSubStr)
			return This

		def RemoveAll(pcSubStr)
			This.Remove(pcSubStr)

			def RemoveAllQ(pcSubStr)
				return This.RemoveQ(pcSubStr)

	def RemovedCS(pcSubStr, pCaseSensitive)
		cResult = new stzStringRemover(@oString.Content()).RemoveCSQ(pcSubStr, pCaseSensitive).Content()
		return cResult

	def Removed(pcSubStr)
		return This.RemovedCS(pcSubStr, 1)

	  #======================================================#
	 #   REMOVING NTH OCCURRENCE OF A GIVEN SUBSTRING       #
	#======================================================#

	def RemoveNthCS(n, pcSubStr, pCaseSensitive)
		new stzStringReplacer(@oString).ReplaceNthCS(n, pcSubStr, "", pCaseSensitive)

		def RemoveNthCSQ(n, pcSubStr, pCaseSensitive)
			This.RemoveNthCS(n, pcSubStr, pCaseSensitive)
			return This

	def RemoveNth(n, pcSubStr)
		This.RemoveNthCS(n, pcSubStr, 1)

		def RemoveNthQ(n, pcSubStr)
			This.RemoveNth(n, pcSubStr)
			return This

	def NthRemovedCS(n, pcSubStr, pCaseSensitive)
		return new stzStringRemover(@oString.Content()).RemoveNthCSQ(n, pcSubStr, pCaseSensitive).Content()

	def NthRemoved(n, pcSubStr)
		return This.NthRemovedCS(n, pcSubStr, 1)

	  #======================================================#
	 #   REMOVING FIRST / LAST OCCURRENCE                   #
	#======================================================#

	def RemoveFirstCS(pcSubStr, pCaseSensitive)
		This.RemoveNthCS(1, pcSubStr, pCaseSensitive)

		def RemoveFirstCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFirstCS(pcSubStr, pCaseSensitive)
			return This

	def RemoveFirst(pcSubStr)
		This.RemoveFirstCS(pcSubStr, 1)

		def RemoveFirstQ(pcSubStr)
			This.RemoveFirst(pcSubStr)
			return This

	def FirstRemovedCS(pcSubStr, pCaseSensitive)
		return new stzStringRemover(@oString.Content()).RemoveFirstCSQ(pcSubStr, pCaseSensitive).Content()

	def FirstRemoved(pcSubStr)
		return This.FirstRemovedCS(pcSubStr, 1)

	#--

	def RemoveLastCS(pcSubStr, pCaseSensitive)
		new stzStringReplacer(@oString).ReplaceLastCS(pcSubStr, "", pCaseSensitive)

		def RemoveLastCSQ(pcSubStr, pCaseSensitive)
			This.RemoveLastCS(pcSubStr, pCaseSensitive)
			return This

	def RemoveLast(pcSubStr)
		This.RemoveLastCS(pcSubStr, 1)

		def RemoveLastQ(pcSubStr)
			This.RemoveLast(pcSubStr)
			return This

	def LastRemovedCS(pcSubStr, pCaseSensitive)
		return new stzStringRemover(@oString.Content()).RemoveLastCSQ(pcSubStr, pCaseSensitive).Content()

	def LastRemoved(pcSubStr)
		return This.LastRemovedCS(pcSubStr, 1)

	  #======================================================#
	 #   REMOVING AT A GIVEN POSITION                       #
	#======================================================#

	def RemoveAtPositionCS(n, pcSubStr, pCaseSensitive)
		nLen = len(pcSubStr)
		This.RemoveSection(n, n + nLen - 1)

	def RemoveAtPosition(n, pcSubStr)
		This.RemoveAtPositionCS(n, pcSubStr, 1)

	  #======================================================#
	 #   REMOVING A SECTION                                 #
	#======================================================#

	def RemoveSection(n1, n2)
		cLeft = @oString.Section(1, n1 - 1)
		cRight = ""
		if n2 < @oString.NumberOfChars()
			cRight = @oString.Section(n2 + 1, @oString.NumberOfChars())
		ok
		@oString.Update(cLeft + cRight)

		def RemoveSectionQ(n1, n2)
			This.RemoveSection(n1, n2)
			return This

	def SectionRemoved(n1, n2)
		return new stzStringRemover(@oString.Content()).RemoveSectionQ(n1, n2).Content()

	  #======================================================#
	 #   REMOVING A RANGE (POSITION + N CHARS)              #
	#======================================================#

	def RemoveRange(nStart, nRange)
		This.RemoveSection(nStart, nStart + nRange - 1)

		def RemoveRangeQ(nStart, nRange)
			This.RemoveRange(nStart, nRange)
			return This

	def RangeRemoved(nStart, nRange)
		return new stzStringRemover(@oString.Content()).RemoveRangeQ(nStart, nRange).Content()

	  #======================================================#
	 #   REMOVING WITH CONDITION                            #
	#======================================================#

	def RemoveW(pcCondition)
		# TODO: requires monolith method extraction
		# anPos = This.FindW(pcCondition)
		anPos = @oString.FindW(pcCondition)
		for i = len(anPos) to 1 step -1
			This.RemoveSection(anPos[i], anPos[i])
		next

		def RemoveWQ(pcCondition)
			This.RemoveW(pcCondition)
			return This

	def RemovedW(pcCondition)
		return new stzStringRemover(@oString.Content()).RemoveWQ(pcCondition).Content()

	  #======================================================#
	 #   REMOVING MANY SUBSTRINGS AT ONCE                   #
	#======================================================#

	def RemoveManyCS(pacSubStr, pCaseSensitive)
		if CheckParams()
			if NOT (isList(pacSubStr) and @IsListOfStrings(pacSubStr))
				StzRaise("Incorrect param type! pacSubStr must be a list of strings.")
			ok
		ok

		_acSubStr_ = U(pacSubStr)
		_nLen_ = len(_acSubStr_)
		_oCopy_ = new stzStringRemover(@oString.Content())

		for @i = 1 to _nLen_
			_oCopy_.RemoveAllCS(_acSubstr_[@i], pCaseSensitive)
		next

		This.UpdateWith(_oCopy_.Content())

		def RemoveManyCSQ(pacSubStr, pCaseSensitive)
			This.RemoveManyCS(pacSubStr, pCaseSensitive)
			return This

		def RemoveAllOfTheseCS(pacSubStr, pCaseSensitive)
			This.RemoveManyCS(pacSubStr, pCaseSensitive)

		def RemoveTheseCS(pacSubStr, pCaseSensitive)
			This.RemoveManyCS(pacSubStr, pCaseSensitive)

	def ManyRemovedCS(pacSubStr, pCaseSensitive)
		return new stzStringRemover(@oString.Content()).RemoveManyCSQ(pacSubStr, pCaseSensitive).Content()

	#--

	def RemoveMany(pacSubStr)
		for cSubstr in pacSubstr
			This.RemoveAll(cSubstr)
		next

		def RemoveManyQ(pacSubStr)
			This.RemoveMany(pacSubStr)
			return This

		def RemoveAllOfThese(pacSubStr)
			This.RemoveMany(pacSubStr)

		def RemoveThese(pacSubStr)
			This.RemoveMany(pacSubStr)

	def ManyRemoved(pacSubStr)
		return new stzStringRemover(@oString.Content()).RemoveManyQ(pacSubStr).Content()

		def TheseRemoved(pacSubStr)
			return This.ManyRemoved(pacSubStr)

	  #===========================================================#
	 #   REMOVING ALL SUBSTRINGS EXCEPT THOSE PROVIDED           #
	#===========================================================#

	def RemoveSubStringsExceptCS(pacSubStr, pCaseSensitive)
		# TODO: requires monolith method extraction
		# acAll = This.SubStringsCS(pCaseSensitive)
		acAll = @oString.SubStringsCS(pCaseSensitive)
		_nLen_ = len(acAll)

		for @i = 1 to _nLen_
			bFound = 0
			for @j = 1 to len(pacSubStr)
				if BothStringsAreEqualCS(acAll[@i], pacSubStr[@j], pCaseSensitive)
					bFound = 1
					exit
				ok
			next
			if NOT bFound
				This.RemoveCS(acAll[@i], pCaseSensitive)
			ok
		next

		def RemoveAllExceptCS(pacSubStr, pCaseSensitive)
			This.RemoveSubStringsExceptCS(pacSubStr, pCaseSensitive)

		def RemoveAllButCS(pacSubStr, pCaseSensitive)
			This.RemoveSubStringsExceptCS(pacSubStr, pCaseSensitive)

	def RemoveSubStringsExcept(pacSubStr)
		This.RemoveSubStringsExceptCS(pacSubStr, 1)

		def RemoveAllExcept(pacSubStr)
			This.RemoveSubStringsExcept(pacSubStr)

		def RemoveAllBut(pacSubStr)
			This.RemoveSubStringsExcept(pacSubStr)

	  #======================================================#
	 #   REMOVING BETWEEN TWO SUBSTRINGS                    #
	#======================================================#

	def RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		# TODO: requires monolith method extraction
		# aSection = This.FindAnyBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)
		aSection = @oString.FindAnyBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)
		This.RemoveSection(aSection[1], aSection[2])

		def RemoveAnyBetweenCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			return This

		def RemoveBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)

	def AnyBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)
		return new stzStringRemover(@oString.Content()).RemoveAnyBetweenCSQ(pcBound1, pcBound2, pCaseSensitive).Content()

	#--

	def RemoveAnyBetween(pcBound1, pcBound2)
		This.RemoveAnyBetweenCS(pcBound1, pcBound2, 1)

		def RemoveAnyBetweenQ(pcBound1, pcBound2)
			This.RemoveAnyBetween(pcBound1, pcBound2)
			return This

		def RemoveBetween(pcBound1, pcBound2)
			This.RemoveAnyBetween(pcBound1, pcBound2)

	def AnyBetweenRemoved(pcBound1, pcBound2)
		return new stzStringRemover(@oString.Content()).RemoveAnyBetweenQ(pcBound1, pcBound2).Content()

		def BetweenRemoved(pcBound1, pcBound2)
			return This.AnyBetweenRemoved(pcBound1, pcBound2)

	  #-----------------------------------------------------------#
	 #   REMOVING BETWEEN TWO SUBSTRINGS -- INCLUDING BOUNDS     #
	#-----------------------------------------------------------#

	def RemoveAnyBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)

		# TODO: requires monolith method extraction
		# aSection = This.FindAnyBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)
		aSection = @oString.FindAnyBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)

		if isList(pcBound2) and IsAndNamedParamList(pcBound2)
			pcBound2 = pcBound2[2]
		ok

		nLen1 = len(pcBound1)
		nLen2 = len(pcBound2)

		aSection[1] = aSection[1] - nLen1
		aSection[2] = aSection[2] + nLen2

		This.RemoveSection(aSection[1], aSection[2])

		def RemoveAnyBetweenCSIBQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)
			return This

		def RemoveBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)

	def AnyBetweenRemovedCSIB(pcBound1, pcBound2, pCaseSensitive)
		return new stzStringRemover(@oString.Content()).RemoveAnyBetweenCSIBQ(pcBound1, pcBound2, pCaseSensitive).Content()

	#--

	def RemoveAnyBetweenIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenCSIB(pcBound1, pcBound2, 1)

		def RemoveAnyBetweenIBQ(pcBound1, pcBound2)
			This.RemoveAnyBetweenIB(pcBound1, pcBound2)
			return This

		def RemoveBetweenIB(pcBound1, pcBound2)
			This.RemoveAnyBetweenIB(pcBound1, pcBound2)

	def AnyBetweenRemovedIB(pcBound1, pcBound2)
		return new stzStringRemover(@oString.Content()).RemoveAnyBetweenIBQ(pcBound1, pcBound2).Content()

	  #======================================================#
	 #   REMOVING DUPLICATES                                #
	#======================================================#

	def RemoveDuplicatesCS(pCaseSensitive)
		# TODO: requires monolith method extraction
		# aSections = This.FindDuplicatesAsSectionsCS(pCaseSensitive)
		aSections = @oString.FindDuplicatesAsSectionsCS(pCaseSensitive)
		# TODO: requires monolith method extraction
		# _cResult_ = This.Copy().RemoveSections(aSections)
		_cResult_ = new stzStringRemover(@oString.Content()).RemoveSections(aSections)
		This.UpdateWith(_cResult_)

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

	def DuplicatesRemovedCS(pCaseSensitive)
		return new stzStringRemover(@oString.Content()).RemoveDuplicatesCSQ(pCaseSensitive).Content()

		def WithoutDuplicatesCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

	#--

	def RemoveDuplicates()
		This.RemoveDuplicatesCS(1)

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This

	def DuplicatesRemoved()
		return new stzStringRemover(@oString.Content()).RemoveDuplicatesQ().Content()

		def WithoutDuplicates()
			return This.DuplicatesRemoved()

	  #======================================================#
	 #   REMOVING SUBSTRING FROM LEFT / RIGHT               #
	#======================================================#

	def RemoveFromLeftCS(pcSubStr, pCaseSensitive)
		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		nLenSubStr = len(pcSubStr)

		# TODO: requires monolith method extraction
		# if This.NLeftCharsAsStringQ(nLenSubStr).IsEqualToCS(pcSubStr, pCaseSensitive)
		if @oString.NLeftCharsAsStringQ(nLenSubStr).IsEqualToCS(pcSubStr, pCaseSensitive)
			if @oString.IsLeftToRight()
				n1 = 1
				n2 = nLenSubStr
			else
				nLenStr = @oString.NumberOfChars()
				n1 = nLenStr - nLenSubStr + 1
				n2 = nLenStr
			ok
			This.RemoveSection(n1, n2)
		ok

		def RemoveFromLeftCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromLeftCS(pcSubStr, pCaseSensitive)
			return This

	def RemovedFromLeftCS(pcSubStr, pCaseSensitive)
		return new stzStringRemover(@oString.Content()).RemoveFromLeftCSQ(pcSubStr, pCaseSensitive).Content()

	#--

	def RemoveFromLeft(pcSubStr)
		This.RemoveFromLeftCS(pcSubStr, 1)

		def RemoveFromLeftQ(pcSubStr)
			This.RemoveFromLeft(pcSubStr)
			return This

	def RemovedFromLeft(pcSubStr)
		return new stzStringRemover(@oString.Content()).RemoveFromLeftQ(pcSubStr).Content()

	#--

	def RemoveFromRightCS(pcSubStr, pCaseSensitive)
		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		nLenSubStr = len(pcSubStr)

		# TODO: requires monolith method extraction
		# if This.NRightCharsAsStringQ(nLenSubStr).IsEqualToCS(pcSubStr, pCaseSensitive)
		if @oString.NRightCharsAsStringQ(nLenSubStr).IsEqualToCS(pcSubStr, pCaseSensitive)
			if @oString.IsRightToLeft()
				n1 = 1
				n2 = nLenSubStr
			else
				nLenStr = @oString.NumberOfChars()
				n1 = nLenStr - nLenSubStr + 1
				n2 = nLenStr
			ok
			This.RemoveSection(n1, n2)
		ok

		def RemoveFromRightCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromRightCS(pcSubStr, pCaseSensitive)
			return This

	def RemovedFromRightCS(pcSubStr, pCaseSensitive)
		return new stzStringRemover(@oString.Content()).RemoveFromRightCSQ(pcSubStr, pCaseSensitive).Content()

	#--

	def RemoveFromRight(pcSubStr)
		This.RemoveFromRightCS(pcSubStr, 1)

		def RemoveFromRightQ(pcSubStr)
			This.RemoveFromRight(pcSubStr)
			return This

	def RemovedFromRight(pcSubStr)
		return new stzStringRemover(@oString.Content()).RemoveFromRightQ(pcSubStr).Content()

	  #======================================================#
	 #   REMOVING SPACES                                    #
	#======================================================#

	def RemoveSpaces()
		This.RemoveAll(" ")

		def RemoveSpacesQ()
			This.RemoveSpaces()
			return This

		def RemoveAllSpaces()
			This.RemoveSpaces()

	def SpacesRemoved()
		return new stzStringRemover(@oString.Content()).RemoveSpacesQ().Content()

	#--

	def RemoveLeadingSpaces()
		# TODO: requires monolith method extraction
		# This.TrimStart()
		@oString.TrimStart()

		def RemoveLeadingSpacesQ()
			This.RemoveLeadingSpaces()
			return This

	def LeadingSpacesRemoved()
		return new stzStringRemover(@oString.Content()).RemoveLeadingSpacesQ().Content()

	#--

	def RemoveTrailingSpaces()
		# TODO: requires monolith method extraction
		# This.TrimEnd()
		@oString.TrimEnd()

		def RemoveTrailingSpacesQ()
			This.RemoveTrailingSpaces()
			return This

	def TrailingSpacesRemoved()
		return new stzStringRemover(@oString.Content()).RemoveTrailingSpacesQ().Content()

	#--

	def RemoveLeftSpaces()
		# TODO: requires monolith method extraction
		# This.TrimLeft()
		@oString.TrimLeft()

		def RemoveLeftSpacesQ()
			This.RemoveLeftSpaces()
			return This

	def LeftSpacesRemoved()
		return new stzStringRemover(@oString.Content()).RemoveLeftSpacesQ().Content()

	#--

	def RemoveRightSpaces()
		# TODO: requires monolith method extraction
		# This.TrimRight()
		@oString.TrimRight()

		def RemoveRightSpacesQ()
			This.RemoveRightSpaces()
			return This

	def RightSpacesRemoved()
		return new stzStringRemover(@oString.Content()).RemoveRightSpacesQ().Content()

	  #======================================================#
	 #   REMOVING N-FIRST / N-LAST OCCURRENCES              #
	#======================================================#

	def RemoveNFirstOccurrencesCS(n, pcSubStr, pCaseSensitive)
		anPos = new stzStringFinder(@oString).FindCS(pcSubStr, pCaseSensitive)
		if len(anPos) < n
			n = len(anPos)
		ok
		nLenSubStr = len(pcSubStr)
		for i = n to 1 step -1
			This.RemoveSection(anPos[i], anPos[i] + nLenSubStr - 1)
		next

		def RemoveNFirstOccurrencesCSQ(n, pcSubStr, pCaseSensitive)
			This.RemoveNFirstOccurrencesCS(n, pcSubStr, pCaseSensitive)
			return This

	def RemoveNFirstOccurrences(n, pcSubStr)
		This.RemoveNFirstOccurrencesCS(n, pcSubStr, 1)

	#--

	def RemoveNLastOccurrencesCS(n, pcSubStr, pCaseSensitive)
		anPos = new stzStringFinder(@oString).FindCS(pcSubStr, pCaseSensitive)
		nLen = len(anPos)
		if nLen < n
			n = nLen
		ok
		nLenSubStr = len(pcSubStr)
		for i = nLen to nLen - n + 1 step -1
			This.RemoveSection(anPos[i], anPos[i] + nLenSubStr - 1)
		next

		def RemoveNLastOccurrencesCSQ(n, pcSubStr, pCaseSensitive)
			This.RemoveNLastOccurrencesCS(n, pcSubStr, pCaseSensitive)
			return This

	def RemoveNLastOccurrences(n, pcSubStr)
		This.RemoveNLastOccurrencesCS(n, pcSubStr, 1)

	  #======================================================#
	 #   REMOVING CHAR AT POSITION                          #
	#======================================================#

	def RemoveCharAt(n)
		This.RemoveSection(n, n)

		def RemoveCharAtQ(n)
			This.RemoveCharAt(n)
			return This

	def CharRemovedAt(n)
		return new stzStringRemover(@oString.Content()).RemoveCharAtQ(n).Content()

	  #======================================================#
	 #   REMOVING CHARS AT MULTIPLE POSITIONS               #
	#======================================================#

	def RemoveCharsAtPositions(panPos)
		aSorted = sort(panPos)
		for i = len(aSorted) to 1 step -1
			This.RemoveCharAt(aSorted[i])
		next

		def RemoveCharsAtPositionsQ(panPos)
			This.RemoveCharsAtPositions(panPos)
			return This

	def CharsRemovedAtPositions(panPos)
		return new stzStringRemover(@oString.Content()).RemoveCharsAtPositionsQ(panPos).Content()
