#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSTRINGFINDER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String finder -- finding, containing,       #
#                  counting, and positioning operations.        #
#                  Wraps stzString via composition.             #
#                  For aliases, use stzStringFinderXT.          #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringFinder

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringFinder! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     CONTAINS                  #
	#===============================#

	def ContainsCS(pcSubStr, pCaseSensitive)

		if isList(pcSubStr)
			return This.ContainsTheseCS(pcSubStr, pCaseSensitive)
		ok

		if NOT isString(pcSubStr)
			stzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		if pcSubStr = ""
			return 0
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringContainsCS(@oString.Engine(), pcSubStr, _bCase_)

	def Contains(pcSubStr)
		return This.ContainsCS(pcSubStr, 1)

	  #===============================#
	 #     CONTAINS THESE            #
	#===============================#

	def ContainsTheseCS(pacSubStrings, pCaseSensitive)

		if NOT isList(pacSubStrings)
			StzRaise("Incorrect param type! pacSubStrings must be a list.")
		ok

		nLen = len(pacSubStrings)
		for i = 1 to nLen
			if NOT This.ContainsCS(pacSubStrings[i], pCaseSensitive)
				return FALSE
			ok
		next
		return TRUE

	def ContainsThese(pacSubStrings)
		return This.ContainsTheseCS(pacSubStrings, 1)

	  #===============================#
	 #     FIND ALL                  #
	#===============================#

	def FindCS(pcSubStr, pCaseSensitive)

		if CheckingParams()

			if isList(pcSubStr) and @IsListOfStrings(pcSubStr)
				return This.FindManyCS(pcSubStr, pCaseSensitive)
			ok

			if isList(pcSubStr) and len(pcSubStr) = 2 and isString(pcSubStr[1])
				cPN = lower(pcSubStr[1])
				if cPN = "of" or cPN = "ofsubstring"
					pcSubStr = pcSubStr[2]
				ok
			ok

			if NOT isString(pcSubStr)
				stzRaise("Incorrect param type! pcSubStr must be a string.")
			ok

		ok

		if pcSubStr = ""
			return []
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		# Bulk find via Engine: one call returns all positions
		pResult = StzEngineStringFindAllCS(@oString.Engine(), pcSubStr, _bCase_)

		nCount = StzEngineFindResultCount(pResult)
		if nCount = 0
			StzEngineFindResultFree(pResult)
			return []
		ok

		anResult = []
		for i = 0 to nCount - 1
			# Engine returns 1-based positions (INDEX_BASE=1)
			anResult + StzEngineFindResultGet(pResult, i)
		next
		StzEngineFindResultFree(pResult)

		return anResult

	def Find(pcSubStr)
		return This.FindCS(pcSubStr, 1)

	  #===============================#
	 #     FIND NTH                  #
	#===============================#

	def FindNthCS(n, pcSubstr, pCaseSensitive)

		if isList(pcSubStr) and IsOfNamedParamList(pcSubStr)
			pcSubStr = pcSubStr[2]
		ok

		if NOT isString(pcSubStr)
			stzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
			StzRaise("Incorrect param type! pCaseSensitive must be a boolean (1 or 0).")
		ok

		if NOT This.ContainsCS(pcSubStr, pCaseSensitive)
			return 0
		ok

		if isString(n)
			cNLowercased = lower(n)
			if cNLowercased = :First or cNLowercased = :FirstOccurrence
				n = 1

			but cNLowercased = :Last or cNLowercased = :LastOccurrence
				n = This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

			else
				n = 0
			ok
		ok

		nResult = 0

		nPos = 1
		for i = 1 to n

			nResult = @oString._FindSubStr(pcSubStr, nPos, pCaseSensitive)

			if nResult = 0
				exit
			ok

			nPos = nResult + 1
		next

		return nResult

	def FindNth(n, pcSubstr)
		return This.FindNthCS(n, pcSubstr, 1)

	  #===============================#
	 #     FIND FIRST                #
	#===============================#

	def FindFirstCS(pcSubStr, pCaseSensitive)

		if CheckParams()
			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok
		ok

		if pcSubStr = ""
			return 0
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		nResult = @oString._FindSubStr(pcSubStr, 1, _bCase_)

		return nResult

	def FindFirst(pcSubstr)
		return This.FindFirstCS(pcSubstr, 1)

	  #===============================#
	 #     FIND LAST                 #
	#===============================#

	def FindLastCS(pcSubStr, pCaseSensitive)

		if isList(pcSubStr) and IsOfNamedParamList(pcSubStr)
			pcSubStr = pcSubStr[2]
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		nResult = StzEngineStringLastIndexOfCS(@oString.Engine(), pcSubStr, _bCase_)
		# Engine returns 1-based (INDEX_BASE=1), -1 for not found
		if nResult > 0
			return nResult
		else
			return 0
		ok

	def FindLast(pcSubStr)
		return This.FindLastCS(pcSubStr, 1)

	  #===============================#
	 #     NUMBER OF OCCURRENCES     #
	#===============================#

	def NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringCountOfCS(@oString.Engine(), pcSubStr, _bCase_)

	def NumberOfOccurrence(pcSubStr)
		return This.NumberOfOccurrenceCS(pcSubStr, 1)

	  #===============================#
	 #     FIND MANY                 #
	#===============================#

	def FindManyCS(pacSubStrings, pCaseSensitive)
		if NOT isList(pacSubStrings)
			StzRaise("Incorrect param type! pacSubStrings must be a list.")
		ok

		aResult = []
		nLen = len(pacSubStrings)
		for i = 1 to nLen
			anPositions = This.FindCS(pacSubStrings[i], pCaseSensitive)
			if len(anPositions) > 0
				aResult + [ pacSubStrings[i], anPositions ]
			ok
		next
		return aResult

	def FindMany(pacSubStrings)
		return This.FindManyCS(pacSubStrings, 1)

	  #===============================#
	 #     STARTS WITH / ENDS WITH   #
	#===============================#

	def StartsWithCS(pcSubStr, pCaseSensitive)
		if pcSubStr = ""
			return 0
		ok
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringStartsWithCS(@oString.Engine(), pcSubStr, _bCase_)

	def StartsWith(pcSubStr)
		return This.StartsWithCS(pcSubStr, 1)

	def EndsWithCS(pcSubStr, pCaseSensitive)
		if pcSubStr = ""
			return 0
		ok
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringEndsWithCS(@oString.Engine(), pcSubStr, _bCase_)

	def EndsWith(pcSubStr)
		return This.EndsWithCS(pcSubStr, 1)

	  #===============================#
	 #     FIND AS SECTIONS          #
	#===============================#

	def FindAsSectionsCS(pcSubStr, pCaseSensitive)
		anFirstPos = This.FindCS(pcSubStr, pCaseSensitive)
		nLen = len(anFirstPos)

		if nLen = 0
			return []
		ok

		aResult = []
		nLenSubStr = len(pcSubStr)

		for i = 1 to nLen
			aResult + [ anFirstPos[i], anFirstPos[i] + nLenSubStr - 1 ]
		next

		return aResult

	def FindAsSections(pcSubStr)
		return This.FindAsSectionsCS(pcSubStr, 1)

	  #=============================================#
	 #     FIND BETWEEN TWO BOUNDS AS SECTION      #
	#=============================================#

	def FindBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)

		nLen1 = len(pcBound1)
		n1 = This.FindFirstCS(pcBound1, pCaseSensitive)
		if n1 = 0
			return [0, 0]
		ok
		n1 = n1 + nLen1

		n2 = This.FindLastCS(pcBound2, pCaseSensitive)
		if n2 = 0
			return [0, 0]
		ok
		n2 = n2 - 1

		if n2 < n1
			nTemp = n2
			n2 = n1
			n1 = nTemp
		ok

		aResult = [ n1, n2 ]
		return aResult

		def FindAnyBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)
			return This.FindBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)

	def FindBetweenAsSection(pcBound1, pcBound2)
		return This.FindBetweenAsSectionCS(pcBound1, pcBound2, 1)

		def FindAnyBetweenAsSection(pcBound1, pcBound2)
			return This.FindBetweenAsSection(pcBound1, pcBound2)

	  #=================================================#
	 #     FIND BOUNDED BY PAIR AS SECTIONS             #
	#=================================================#

	def FindBoundedByAsSectionsCS(pacBounds, pCaseSensitive)
		# pacBounds is a pair [cBound1, cBound2]
		if NOT (isList(pacBounds) and len(pacBounds) = 2)
			StzRaise("Incorrect param! pacBounds must be a pair of strings.")
		ok

		cBound1 = pacBounds[1]
		cBound2 = pacBounds[2]

		anPos1 = This.FindCS(cBound1, pCaseSensitive)
		anPos2 = This.FindCS(cBound2, pCaseSensitive)

		nLen1 = len(cBound1)

		aResult = []

		# For each bound1 occurrence, find the next bound2 after it
		for i = 1 to len(anPos1)
			nAfter = anPos1[i] + nLen1
			# Find the nearest bound2 that starts after bound1 ends
			for j = 1 to len(anPos2)
				if anPos2[j] > anPos1[i] + nLen1 - 1
					aResult + [ nAfter, anPos2[j] - 1 ]
					exit
				ok
			next
		next

		return aResult

		def FindAnyBoundedByAsSectionsCS(pacBounds, pCaseSensitive)
			return This.FindBoundedByAsSectionsCS(pacBounds, pCaseSensitive)

	def FindBoundedByAsSections(pacBounds)
		return This.FindBoundedByAsSectionsCS(pacBounds, 1)

		def FindAnyBoundedByAsSections(pacBounds)
			return This.FindBoundedByAsSections(pacBounds)

	  #===============================#
	 #     SUBSTRINGS                #
	#===============================#

	def SubStringsCS(pCaseSensitive)
		cStr = @oString.Content()
		if cStr = ""
			return []
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		pResult = StzEngineStringAllSubstringsCS(@oString.Engine(), _bCase_)
		cJoined = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)

		if cJoined = ""
			return []
		ok

		acResult = []
		cDelim = char(0)
		cRest = cJoined

		while true
			nPos = substr(cRest, cDelim)
			if nPos = 0
				if len(cRest) > 0
					acResult + cRest
				ok
				exit
			ok
			acResult + left(cRest, nPos - 1)
			cRest = substr(cRest, nPos + 1)
		end

		return acResult

	def SubStrings()
		return This.SubStringsCS(1)

	  #===============================#
	 #     FIND DUPLICATES           #
	#===============================#

	def DuplicatesCS(pCaseSensitive)
		cStr = @oString.Content()
		if cStr = ""
			return []
		ok

		acResult = []
		nLen = len(cStr)

		for i = 1 to nLen
			for j = i to nLen
				cSubStr = substr(cStr, i, j - i + 1)

				# Check if already collected (case-sensitive or not)
				bAlready = 0
				for k = 1 to len(acResult)
					if BothStringsAreEqualCS(acResult[k], cSubStr, pCaseSensitive)
						bAlready = 1
						exit
					ok
				next

				if NOT bAlready
					# Check if it appears more than once
					if This.NumberOfOccurrenceCS(cSubStr, pCaseSensitive) > 1
						acResult + cSubStr
					ok
				ok
			next
		next

		return acResult

	def Duplicates()
		return This.DuplicatesCS(1)

	def FindDuplicatesAsSectionsCS(pCaseSensitive)
		acDuplicates = This.DuplicatesCS(pCaseSensitive)
		nLen = len(acDuplicates)

		aResult = []

		for i = 1 to nLen
			aSections = This.FindAsSectionsCS(acDuplicates[i], pCaseSensitive)
			# Remove first occurrence — keep only duplicates
			if len(aSections) > 1
				for j = 2 to len(aSections)
					aResult + aSections[j]
				next
			ok
		next

		# Sort by start position
		nLenR = len(aResult)
		for i = 1 to nLenR - 1
			for j = 1 to nLenR - i
				if aResult[j][1] > aResult[j+1][1]
					temp = aResult[j]
					aResult[j] = aResult[j+1]
					aResult[j+1] = temp
				ok
			next
		next

		return aResult

	def FindDuplicatesAsSections()
		return This.FindDuplicatesAsSectionsCS(1)

	  #========================================#
	 #     FIND WITH CONDITION (FindW)        #
	#========================================#

	def FindCharsWCS(pcCondition, pCaseSensitive)
		# Evaluates pcCondition for each char, replacing @char with the char value
		# Returns positions (1-based) where condition is true
		# Ring eval() does NOT return values -- must assign inside eval string

		cStr = @oString.Content()
		nLen = len(cStr)
		anResult = []

		for i = 1 to nLen
			@char = cStr[i]
			_stzFindW_result_ = 0
			eval("_stzFindW_result_ = (" + pcCondition + ")")
			if _stzFindW_result_ = 1
				anResult + i
			ok
		next

		return anResult

	def FindCharsW(pcCondition)
		return This.FindCharsWCS(pcCondition, 1)

	def FindWCS(pcCondition, pCaseSensitive)
		# Dispatch: @char -> FindCharsWCS
		cLower = lower(pcCondition)
		if substr(cLower, "@char") > 0
			return This.FindCharsWCS(pcCondition, pCaseSensitive)
		ok

		# Default: character-level find
		return This.FindCharsWCS(pcCondition, pCaseSensitive)

	def FindW(pcCondition)
		return This.FindWCS(pcCondition, 1)
