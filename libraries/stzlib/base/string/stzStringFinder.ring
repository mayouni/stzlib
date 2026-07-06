#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSTRINGFINDER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String finder -- finding, containing,       #
#                  counting, and positioning operations.       #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringFinderXT.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


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
				cPN = StzCaseFold(pcSubStr[1])
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

		# Bulk find via Engine: one call returns all positions as a result
		# handle, drained here. (A Zig-side newlist/retlist bulk return was
		# tried but loses the list through deep Ring call chains -- a VM-level
		# fragility; the drain is correct and findall is Ring-list-bound
		# anyway, so bulk gave no real gain here.)
		pResult = StzEngineStringFindCS(@oString.Engine(), pcSubStr, _bCase_)
		nCount = StzEngineFindResultCount(pResult)
		if nCount = 0
			StzEngineFindResultFree(pResult)
			return []
		ok
		anResult = []
		for i = 1 to nCount
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
			cNLowercased = StzCaseFold(n)
			if cNLowercased = :First or cNLowercased = :FirstOccurrence
				n = 1

			but cNLowercased = :Last or cNLowercased = :LastOccurrence
				n = This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

			else
				n = 0
			ok
		ok

		# Direct engine call — single FFI instead of N iterated find-next
		pH = @oString.Engine()
		nResult = StzEngineStringFindNthCS(pH, pcSubStr, n, pCaseSensitive)
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
		nResult = StzEngineStringFindLastCS(@oString.Engine(), pcSubStr, _bCase_)
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

		# Per the original monolith: the FLAT, ascending-sorted list of
		# every substring's positions (the grouped [sub, positions]
		# shape is the Z-family's job).
		aResult = []
		nLen = len(pacSubStrings)
		for i = 1 to nLen
			anPositions = This.FindCS(pacSubStrings[i], pCaseSensitive)
			nPL = len(anPositions)
			for j = 1 to nPL
				aResult + anPositions[j]
			next
		next
		# Ascending insertion sort (the lists are small).
		nRL = len(aResult)
		for i = 2 to nRL
			nV = aResult[i]
			j = i - 1
			while j >= 1 and aResult[j] > nV
				aResult[j + 1] = aResult[j]
				j--
			end
			aResult[j + 1] = nV
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
		nLenSubStr = StzLen(pcSubStr)

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

		nLen1 = StzLen(pcBound1)
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

		nLen1 = StzLen(cBound1)

		aResult = []

		# For each bound1 occurrence, find the next bound2 after it
		_nPos1Len_ = len(anPos1)
		for i = 1 to _nPos1Len_
			nAfter = anPos1[i] + nLen1
			# Find the nearest bound2 that starts after bound1 ends
			_nPos2Len_ = len(anPos2)
			for j = 1 to _nPos2Len_
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

		return _SplitNullDelimited(cJoined)

	def SubStrings()
		return This.SubStringsCS(1)

	  #===============================#
	 #     FIND DUPLICATES           #
	#===============================#

	def DuplicatesCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringDuplicateSubstringsCS(pH, _bCase_)
		cJoined = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		if cJoined = ""
			return []
		ok
		return _SplitNullDelimited(cJoined)

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
				_nSectionsLen_ = len(aSections)
				for j = 2 to _nSectionsLen_
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
		# Engine-backed: evaluates expression per character. Normalize first so
		# the expressive forms (a { ... } block and Q(@char).Method() sugar) are
		# accepted WITHOUT eval() -- this is the W path that replaced the retired
		# ...WXT() raw-eval forms. Idempotent for plain-DSL predicates.
		pcCondition = _StzNormalizeCharCond(pcCondition)
		_cFcwResult_ = StzEngineStringFindCharsW(@oString.Content(), pcCondition)
		return _ParseCSVNumbers(_cFcwResult_)

	def FindCharsW(pcCondition)
		return This.FindCharsWCS(pcCondition, 1)

	def FindWCS(pcCondition, pCaseSensitive)
		# Dispatch: @substring -> substring-level W; @char (or default) -> char-level.
		cLower = StzCaseFold(pcCondition)
		oTmp = new stzStringFinder(cLower)
		if oTmp.Contains("@substring")
			return This.FindSubStringsWCS(pcCondition, pCaseSensitive)
		ok
		return This.FindCharsWCS(pcCondition, pCaseSensitive)

	# FindSubStringsWCS: the START positions of every SUBSTRING satisfying an
	# @substring W-predicate. Enumerates all substrings (with their start pos),
	# rewrites @substring -> @item (via _StzNormalizeSubStringCond) and filters
	# with the list W-DSL, then maps the matching indices back to positions.
	def FindSubStringsWCS(pcCondition, pCaseSensitive)
		_cNorm_ = _StzNormalizeSubStringCond(pcCondition)
		_nN_ = @oString.NumberOfChars()
		if _nN_ = 0 return [] ok
		# ENGINE-BACKED enumeration: SubStrings() returns every substring in
		# the same (i,j) order this loop used, without the O(n^2) per-Section
		# engine round-trips. Positions are reconstructed by the same nested
		# counter (pure Ring arithmetic, no round-trips).
		_aSubs_ = @oString.SubStrings()
		_aPos_ = []
		for _iSsw_ = 1 to _nN_
			for _jSsw_ = _iSsw_ to _nN_
				_aPos_ + _iSsw_
			next
		next
		_oLssw_ = new stzList(_aSubs_)
		_aIdx_ = _oLssw_.FindW(_cNorm_)
		_aRes_ = []
		_nM_ = len(_aIdx_)
		for _kSsw_ = 1 to _nM_
			_pSsw_ = _aPos_[ _aIdx_[_kSsw_] ]
			if ring_find(_aRes_, _pSsw_) = 0
				_aRes_ + _pSsw_
			ok
		next
		return _aRes_

	def FindW(pcCondition)
		return This.FindWCS(pcCondition, 1)

	  #===============================#
	 #     INDEX OF (CS)             #
	#===============================#

	def IndexOfCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		return StzEngineStringFindFirstCS(pH, pcSubStr, _bCase_)

	def IndexOf(pcSubStr)
		return This.IndexOfCS(pcSubStr, 1)

	  #===============================#
	 #     FIND ALL CHAR             #
	#===============================#

	def FindAllChar(pcChar)
		pH = @oString.Engine()
		pHChar = StzEngineString(pcChar)
		nCp = StzEngineStringCharAt(pHChar, 1)
		StzEngineStringFree(pHChar)
		pResult = StzEngineStringFindChar(pH, nCp)
		nCount = StzEngineFindResultCount(pResult)
		if nCount = 0
			StzEngineFindResultFree(pResult)
			return []
		ok
		anResult = []
		for i = 1 to nCount
			anResult + StzEngineFindResultGet(pResult, i)
		next
		StzEngineFindResultFree(pResult)
		return anResult

	  #===============================#
	 #     STARTS/ENDS WITH ANY      #
	#===============================#

	def StartsWithAnyCS(pcPrefixes, pCaseSensitive)
		# Delegate per-prefix to the engine-backed StartsWithCS (codepoint +
		# case-correct). The old byte-oriented substr()/lower() compare failed
		# case-insensitively on multibyte (E-acute vs e-acute).
		if NOT isList(pcPrefixes) return 0 ok
		_nL_ = len(pcPrefixes)
		for _i_ = 1 to _nL_
			_s_ = pcPrefixes[_i_]
			if isString(_s_) and _s_ != "" and @oString.StartsWithCS(_s_, pCaseSensitive)
				return 1
			ok
		next
		return 0

	def StartsWithAny(pcPrefixes)
		return This.StartsWithAnyCS(pcPrefixes, 1)

	def EndsWithAnyCS(pcSuffixes, pCaseSensitive)
		# Delegate per-suffix to the engine-backed EndsWithCS (codepoint +
		# case-correct). The old byte-oriented tail extraction
		# (StzMidToEnd by a byte position) + lower() was wrong on multibyte
		# even case-sensitively ('café'.EndsWithAny(['fé']) returned 0).
		if NOT isList(pcSuffixes) return 0 ok
		_nL_ = len(pcSuffixes)
		for _i_ = 1 to _nL_
			_s_ = pcSuffixes[_i_]
			if isString(_s_) and _s_ != "" and @oString.EndsWithCS(_s_, pCaseSensitive)
				return 1
			ok
		next
		return 0

	def EndsWithAny(pcSuffixes)
		return This.EndsWithAnyCS(pcSuffixes, 1)

	  #===============================#
	 #     BETWEEN NTH               #
	#===============================#

	def BetweenNth(pcOpen, pcClose, n)
		pH = @oString.Engine()
		# Engine uses 0-based nth; Softanza uses 1-based
		pR = StzEngineStringBetweenNth(pH, pcOpen, pcClose, n - 1)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     CHARS BETWEEN POSITIONS   #
	#===============================#

	def CharsBetween(nFrom, nTo)
		pH = @oString.Engine()
		pR = StzEngineStringCharsBetween(pH, nFrom, nTo)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     REGEX FIND               #
	#===============================#

	def FindFirstRegex(pcPattern)
		pH = @oString.Engine()
		return StzEngineStringRegexFindFirst(pH, pcPattern, 0)

		def FindRegex(pcPattern)
			return This.FindFirstRegex(pcPattern)

	def FindFirstRegexCS(pcPattern, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nFlags_ = 0
		if _bCase_ = 0
			_nFlags_ = 1
		ok
		pH = @oString.Engine()
		return StzEngineStringRegexFindFirst(pH, pcPattern, _nFlags_)

		def FindRegexCS(pcPattern, pCaseSensitive)
			return This.FindFirstRegexCS(pcPattern, pCaseSensitive)

	def FindAllRegex(pcPattern)
		pH = @oString.Engine()
		pResult = StzEngineStringRegexFindAll(pH, pcPattern, 0)
		if pResult = NULL
			return []
		ok
		_nFarCount_ = StzEngineFindResultCount(pResult)
		_anFarResult_ = []
		for _iFar_ = 1 to _nFarCount_
			_anFarResult_ + StzEngineFindResultGet(pResult, _iFar_)
		next
		StzEngineFindResultFree(pResult)
		return _anFarResult_

		def FindAllRegexMatches(pcPattern)
			return This.FindAllRegex(pcPattern)

	def FindAllRegexCS(pcPattern, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nFlags_ = 0
		if _bCase_ = 0
			_nFlags_ = 1
		ok
		pH = @oString.Engine()
		pResult = StzEngineStringRegexFindAll(pH, pcPattern, _nFlags_)
		if pResult = NULL
			return []
		ok
		_nFarcsCount_ = StzEngineFindResultCount(pResult)
		_anFarcsResult_ = []
		for _iFarcs_ = 1 to _nFarcsCount_
			_anFarcsResult_ + StzEngineFindResultGet(pResult, _iFarcs_)
		next
		StzEngineFindResultFree(pResult)
		return _anFarcsResult_

		def FindAllRegexMatchesCS(pcPattern, pCaseSensitive)
			return This.FindAllRegexCS(pcPattern, pCaseSensitive)

