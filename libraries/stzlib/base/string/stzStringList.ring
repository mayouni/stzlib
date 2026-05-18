#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGLIST              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List of strings -- manages a Ring list of   #
#                  strings with operations like concat, sort,  #
#                  find, filter, unique, reverse, and more.    #
#                  Uses the Zig engine for per-string ops      #
#                  (contains, compare, case, similarity).      #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringListQ(paList)
	return new stzStringList(paList)

func Concatenate(pacListOfStr)
	return ConcatenateXT(pacListOfStr, "")

func ConcatenateXT(pacListOfStr, pcSep)
	if CheckingParams()
		if isList(pcSep) and len(pcSep) = 2 and isString(pcSep[1]) and
		   (lower(pcSep[1]) = "with" or lower(pcSep[1]) = "using")
			pcSep = pcSep[2]
		ok

		if NOT (isList(pacListOfStr) and IsListOfStrings(pacListOfStr))
			StzRaise("Incorrect param type! pacListOfStr must be a list of strings.")
		ok

		if NOT isString(pcSep)
			StzRaise("Incorrect param type! pcSep must be a string.")
		ok
	ok

	_nLen_ = len(pacListOfStr)
	_cResult_ = ""
	for @i = 1 to _nLen_
		if @i > 1
			_cResult_ += pcSep
		ok
		_cResult_ += pacListOfStr[@i]
	next

	return _cResult_

	func ConcatXT(acListOfStr, cSep)
		return ConcatenateXT(acListOfStr, cSep)

func ListOfStrings(paList)
	if @IsListOfStrings(paList)
		return paList
	ok


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringList

	@acContent = []

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(paList)
		if NOT isList(paList)
			StzRaise("Can't create stzStringList! Parameter must be a list of strings.")
		ok

		nLen = len(paList)
		for i = 1 to nLen
			if NOT isString(paList[i])
				StzRaise("Can't create stzStringList! All items must be strings.")
			ok
			@acContent + paList[i]
		next

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @acContent

	def Copy()
		return new stzStringList(@acContent)

	def NumberOfStrings()
		return len(@acContent)

		def Size()
			return This.NumberOfStrings()

	  #===============================#
	 #     NTH STRING ACCESS         #
	#===============================#

	def NthString(n)
		return @acContent[n]

		def String(n)
			return This.NthString(n)

	def FirstString()
		return @acContent[1]

	def LastString()
		return @acContent[len(@acContent)]

	  #===============================#
	 #     ADD / REMOVE              #
	#===============================#

	def Add(pcStr)
		if NOT isString(pcStr)
			StzRaise("Incorrect param type! pcStr must be a string.")
		ok
		@acContent + pcStr

		def AddQ(pcStr)
			This.Add(pcStr)
			return This

	def Prepend(pcStr)
		if NOT isString(pcStr)
			StzRaise("Incorrect param type! pcStr must be a string.")
		ok
		insert(@acContent, 0, pcStr)

		def PrependQ(pcStr)
			This.Prepend(pcStr)
			return This

	def RemoveAt(n)
		del(@acContent, n)

		def RemoveAtQ(n)
			This.RemoveAt(n)
			return This

	def ReplaceAt(n, pcNewStr)
		@acContent[n] = pcNewStr

		def ReplaceAtQ(n, pcNewStr)
			This.ReplaceAt(n, pcNewStr)
			return This

	def Update(paNewList)
		if isList(paNewList) and @IsListOfStrings(paNewList)
			@acContent = paNewList
		else
			StzRaise("Parameter must be a list of strings!")
		ok

		def UpdateQ(paNewList)
			This.Update(paNewList)
			return This

	  #======================================================#
	 #   CONCATENATION                                      #
	#======================================================#

	def Concat()
		# Engine-backed: build result by concatenating
		# engine handles pairwise

		nLen = len(@acContent)
		if nLen = 0
			return ""
		ok

		if nLen = 1
			return @acContent[1]
		ok

		pResult = StzEngineString(@acContent[1])
		for i = 2 to nLen
			pOther = StzEngineString(@acContent[i])
			pNew = StzEngineStringConcat(pResult, pOther)
			StzEngineStringFree(pResult)
			StzEngineStringFree(pOther)
			pResult = pNew
		next

		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

		def Concatenated()
			return This.Concat()

	  #------------------------------------------------------#
	 #   CONCATENATION WITH SEPARATOR                       #
	#------------------------------------------------------#

	def ConcatUsing(pcSep)
		nLen = len(@acContent)
		if nLen = 0
			return ""
		ok

		cResult = ""
		for i = 1 to nLen
			if i > 1
				cResult += pcSep
			ok
			cResult += @acContent[i]
		next
		return cResult

		def ConcatenatedUsing(pcSep)
			return This.ConcatUsing(pcSep)

	  #------------------------------------------------------#
	 #   CONCATENATION -- EXTENDED                          #
	#------------------------------------------------------#

	def ConcatXT(p)
		if isString(p)
			return This.ConcatUsing(p)

		but isList(p)
			oList = new stzList(p)
			if oList.IsUsingNamedParam()
				return This.ConcatUsing(p[2])
			ok
		ok

		return This.Concat()

		def ConcatenatedXT(p)
			return This.ConcatXT(p)

	  #======================================================#
	 #   CONTAINS (engine-backed)                           #
	#======================================================#

	def ContainsCS(pcStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		nLen = len(@acContent)
		for i = 1 to nLen
			pHandle = StzEngineString(@acContent[i])
			pTarget = StzEngineString(pcStr)
			if _bCase_
				bFound = StzEngineStringEquals(pHandle, pTarget)
			else
				bFound = StzEngineStringEqualsCI(pHandle, pTarget)
			ok
			StzEngineStringFree(pHandle)
			StzEngineStringFree(pTarget)
			if bFound
				return 1
			ok
		next
		return 0

	def Contains(pcStr)
		return This.ContainsCS(pcStr, 1)

	  #------------------------------------------------------#
	 #   CONTAINS SUBSTRING IN ANY STRING                   #
	#------------------------------------------------------#

	def ContainsSubStringCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		nLen = len(@acContent)
		for i = 1 to nLen
			pHandle = StzEngineString(@acContent[i])
			bFound = StzEngineStringContainsCS(pHandle, pcSubStr, _bCase_)
			StzEngineStringFree(pHandle)
			if bFound
				return 1
			ok
		next
		return 0

	def ContainsSubString(pcSubStr)
		return This.ContainsSubStringCS(pcSubStr, 1)

	  #======================================================#
	 #   FIND (engine-backed equality)                      #
	#======================================================#

	def FindCS(pcStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		anResult = []
		nLen = len(@acContent)
		for i = 1 to nLen
			pHandle = StzEngineString(@acContent[i])
			pTarget = StzEngineString(pcStr)
			if _bCase_
				bFound = StzEngineStringEquals(pHandle, pTarget)
			else
				bFound = StzEngineStringEqualsCI(pHandle, pTarget)
			ok
			StzEngineStringFree(pHandle)
			StzEngineStringFree(pTarget)
			if bFound
				anResult + i
			ok
		next
		return anResult

	def Find(pcStr)
		return This.FindCS(pcStr, 1)

	def FindFirst(pcStr)
		anAll = This.Find(pcStr)
		if len(anAll) > 0
			return anAll[1]
		ok
		return 0

	def FindLast(pcStr)
		anAll = This.Find(pcStr)
		nLen = len(anAll)
		if nLen > 0
			return anAll[nLen]
		ok
		return 0

	  #======================================================#
	 #   SORT (engine-backed compare)                       #
	#======================================================#

	def SortInAscending()
		# Insertion sort using engine Compare

		nLen = len(@acContent)
		for i = 2 to nLen
			cKey = @acContent[i]
			j = i - 1

			pKey = StzEngineString(cKey)
			bContinue = 1

			while j >= 1 and bContinue
				pJ = StzEngineString(@acContent[j])
				nCmp = StzEngineStringCompare(pJ, pKey)
				StzEngineStringFree(pJ)

				if nCmp > 0
					@acContent[j + 1] = @acContent[j]
					j -= 1
				else
					bContinue = 0
				ok
			end

			StzEngineStringFree(pKey)
			@acContent[j + 1] = cKey
		next

		def SortInAscendingQ()
			This.SortInAscending()
			return This

		def SortUp()
			This.SortInAscending()

	def SortedInAscending()
		oCopy = This.Copy()
		oCopy.SortInAscending()
		return oCopy.Content()

		def SortedUp()
			return This.SortedInAscending()

	  #------------------------------------------------------#
	 #   SORT DESCENDING                                    #
	#------------------------------------------------------#

	def SortInDescending()
		This.SortInAscending()
		This.Reverse()

		def SortInDescendingQ()
			This.SortInDescending()
			return This

		def SortDown()
			This.SortInDescending()

	def SortedInDescending()
		oCopy = This.Copy()
		oCopy.SortInDescending()
		return oCopy.Content()

		def SortedDown()
			return This.SortedInDescending()

	  #======================================================#
	 #   REVERSE                                            #
	#======================================================#

	def Reverse()
		@acContent = reverse(@acContent)

		def ReverseQ()
			This.Reverse()
			return This

	def Reversed()
		return reverse(@acContent)

	  #======================================================#
	 #   UNIQUE (remove duplicates, engine-backed)          #
	#======================================================#

	def Unique()
		acResult = []
		nLen = len(@acContent)

		for i = 1 to nLen
			bDup = 0
			nResLen = len(acResult)
			pI = StzEngineString(@acContent[i])

			for j = 1 to nResLen
				pJ = StzEngineString(acResult[j])
				if StzEngineStringEquals(pI, pJ)
					bDup = 1
					StzEngineStringFree(pJ)
					exit
				ok
				StzEngineStringFree(pJ)
			next

			StzEngineStringFree(pI)

			if NOT bDup
				acResult + @acContent[i]
			ok
		next

		@acContent = acResult

		def UniqueQ()
			This.Unique()
			return This

		def RemoveDuplicates()
			This.Unique()

	def UniqueItems()
		oCopy = This.Copy()
		oCopy.Unique()
		return oCopy.Content()

		def WithoutDuplicates()
			return This.UniqueItems()

	  #======================================================#
	 #   FILTER -- strings containing a substring           #
	#======================================================#

	def FilterCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		acResult = []
		nLen = len(@acContent)
		for i = 1 to nLen
			pHandle = StzEngineString(@acContent[i])
			if StzEngineStringContainsCS(pHandle, pcSubStr, _bCase_)
				acResult + @acContent[i]
			ok
			StzEngineStringFree(pHandle)
		next
		return acResult

	def Filter(pcSubStr)
		return This.FilterCS(pcSubStr, 1)

	  #------------------------------------------------------#
	 #   FILTER BY STARTS-WITH / ENDS-WITH                  #
	#------------------------------------------------------#

	def FilterByStartsWithCS(pcPrefix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		acResult = []
		nLen = len(@acContent)
		for i = 1 to nLen
			pHandle = StzEngineString(@acContent[i])
			if _bCase_
				bMatch = StzEngineStringStartsWith(pHandle, pcPrefix)
			else
				bMatch = StzEngineStringStartsWithCI(pHandle, pcPrefix)
			ok
			StzEngineStringFree(pHandle)
			if bMatch
				acResult + @acContent[i]
			ok
		next
		return acResult

	def FilterByStartsWith(pcPrefix)
		return This.FilterByStartsWithCS(pcPrefix, 1)

	def FilterByEndsWithCS(pcSuffix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		acResult = []
		nLen = len(@acContent)
		for i = 1 to nLen
			pHandle = StzEngineString(@acContent[i])
			if _bCase_
				bMatch = StzEngineStringEndsWith(pHandle, pcSuffix)
			else
				bMatch = StzEngineStringEndsWithCI(pHandle, pcSuffix)
			ok
			StzEngineStringFree(pHandle)
			if bMatch
				acResult + @acContent[i]
			ok
		next
		return acResult

	def FilterByEndsWith(pcSuffix)
		return This.FilterByEndsWithCS(pcSuffix, 1)

	  #======================================================#
	 #   CASE OPERATIONS (engine-backed)                    #
	#======================================================#

	def ToUpper()
		acResult = []
		nLen = len(@acContent)
		for i = 1 to nLen
			pHandle = StzEngineString(@acContent[i])
			pUpper = StzEngineStringToUpper(pHandle)
			acResult + StzEngineStringData(pUpper)
			StzEngineStringFree(pUpper)
			StzEngineStringFree(pHandle)
		next
		@acContent = acResult

		def ToUpperQ()
			This.ToUpper()
			return This

	def Uppercased()
		oCopy = This.Copy()
		oCopy.ToUpper()
		return oCopy.Content()

	def ToLower()
		acResult = []
		nLen = len(@acContent)
		for i = 1 to nLen
			pHandle = StzEngineString(@acContent[i])
			pLower = StzEngineStringToLower(pHandle)
			acResult + StzEngineStringData(pLower)
			StzEngineStringFree(pLower)
			StzEngineStringFree(pHandle)
		next
		@acContent = acResult

		def ToLowerQ()
			This.ToLower()
			return This

	def Lowercased()
		oCopy = This.Copy()
		oCopy.ToLower()
		return oCopy.Content()

	  #======================================================#
	 #   SIMILARITY (engine-backed Jaro / JaroWinkler)      #
	#======================================================#

	def MostSimilarTo(pcTarget)
		# Returns the string from the list most similar to pcTarget
		# Uses engine JaroWinkler for best results

		nLen = len(@acContent)
		if nLen = 0
			return ""
		ok

		nBestScore = -1
		nBestIdx = 1

		pTarget = StzEngineString(pcTarget)

		for i = 1 to nLen
			pHandle = StzEngineString(@acContent[i])
			nScore = StzEngineStringJaroWinkler(pHandle, pTarget)
			StzEngineStringFree(pHandle)

			if nScore > nBestScore
				nBestScore = nScore
				nBestIdx = i
			ok
		next

		StzEngineStringFree(pTarget)
		return @acContent[nBestIdx]

	def SimilarToCS(pcTarget, nThreshold, pCaseSensitive)
		# Returns all strings with JaroWinkler score >= nThreshold
		# nThreshold is 0..1000 (engine returns integer scaled)

		acResult = []
		nLen = len(@acContent)

		pTarget = StzEngineString(pcTarget)

		for i = 1 to nLen
			pHandle = StzEngineString(@acContent[i])
			nScore = StzEngineStringJaroWinkler(pHandle, pTarget)
			StzEngineStringFree(pHandle)
			if nScore >= nThreshold
				acResult + @acContent[i]
			ok
		next

		StzEngineStringFree(pTarget)
		return acResult

	def SimilarTo(pcTarget, nThreshold)
		return This.SimilarToCS(pcTarget, nThreshold, 1)

	  #======================================================#
	 #   CONVERSION                                         #
	#======================================================#

	def ToString()
		return This.ConcatUsing(NL)

	def ToListOfStzStrings()
		aResult = []
		nLen = len(@acContent)
		for i = 1 to nLen
			aResult + new stzString(@acContent[i])
		next
		return aResult

	def ToStzList()
		return new stzList(@acContent)

	  #======================================================#
	 #   SPLIT EACH STRING                                  #
	#======================================================#

	def Split(cSep)
		if isList(cSep) and len(cSep) = 2 and isString(cSep[1]) and
		   (lower(cSep[1]) = "using" or lower(cSep[1]) = "with" or lower(cSep[1]) = "by")
			cSep = cSep[2]
		ok

		aResult = []
		nLen = len(@acContent)
		for i = 1 to nLen
			oStr = new stzString(@acContent[i])
			aResult + oStr.Split(cSep)
		next
		return aResult

	  #======================================================#
	 #   TRIM EACH STRING                                   #
	#======================================================#

	def Trim()
		nLen = len(@acContent)
		for i = 1 to nLen
			oStr = new stzString(@acContent[i])
			@acContent[i] = oStr.Trimmed()
		next

		def TrimQ()
			This.Trim()
			return This

	def Trimmed()
		oCopy = This.Copy()
		oCopy.Trim()
		return oCopy.Content()

	  #======================================================#
	 #   REGEX MATCHING                                     #
	#======================================================#

	def Matches(pcRegexPatt)
		nLen = len(@acContent)
		for i = 1 to nLen
			if rx(pcRegexPatt).Match(@acContent[i]) = 0
				return 0
			ok
		next
		return 1

	  #======================================================#
	 #   TYPE IDENTITY                                      #
	#======================================================#

	def IsStzStringList()
		return 1

	def stzType()
		return :stzStringList

		def ClassName()
			return This.stzType()
