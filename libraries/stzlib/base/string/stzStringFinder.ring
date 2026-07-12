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


class stzStringFinder from stzObject

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

	# TRUE if the string contains ALL the given substrings.
	def ContainsTheseCS(pacSubStrings, pCaseSensitive)

		if NOT isList(pacSubStrings)
			StzRaise("Incorrect param type! pacSubStrings must be a list.")
		ok

		_nLen_ = len(pacSubStrings)
		for i = 1 to _nLen_
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
				_cPN_ = StzCaseFold(pcSubStr[1])
				if _cPN_ = "of" or _cPN_ = "ofsubstring"
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
		_nCount_ = StzEngineFindResultCount(pResult)
		if _nCount_ = 0
			StzEngineFindResultFree(pResult)
			return []
		ok
		_anResult_ = []
		for i = 1 to _nCount_
			_anResult_ + StzEngineFindResultGet(pResult, i)
		next
		StzEngineFindResultFree(pResult)
		return _anResult_

	def Find(pcSubStr)
		return This.FindCS(pcSubStr, 1)

	  #===============================#
	 #     FIND NTH                  #
	#===============================#

	def FindNthCS(_n_, pcSubstr, pCaseSensitive)

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

		if isString(_n_)
			_cNLowercased_ = StzCaseFold(_n_)
			if _cNLowercased_ = :First or _cNLowercased_ = :FirstOccurrence
				_n_ = 1

			but _cNLowercased_ = :Last or _cNLowercased_ = :LastOccurrence
				_n_ = This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

			else
				_n_ = 0
			ok
		ok

		# Direct engine call — single FFI instead of N iterated find-next
		pH = @oString.Engine()
		_nResult_ = StzEngineStringFindNthCS(pH, pcSubStr, _n_, pCaseSensitive)
		return _nResult_

	def FindNth(_n_, pcSubstr)
		return This.FindNthCS(_n_, pcSubstr, 1)

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
		_nResult_ = @oString._FindSubStr(pcSubStr, 1, _bCase_)

		return _nResult_

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
		_nResult_ = StzEngineStringFindLastCS(@oString.Engine(), pcSubStr, _bCase_)
		# Engine returns 1-based (INDEX_BASE=1), -1 for not found
		if _nResult_ > 0
			return _nResult_
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
		_aResult_ = []
		_nLen_ = len(pacSubStrings)
		for i = 1 to _nLen_
			_anPositions_ = This.FindCS(pacSubStrings[i], pCaseSensitive)
			_nPL_ = len(_anPositions_)
			for _j_ = 1 to _nPL_
				_aResult_ + _anPositions_[_j_]
			next
		next
		# Ascending insertion sort (the lists are small).
		_nRL_ = len(_aResult_)
		for i = 2 to _nRL_
			_nV_ = _aResult_[i]
			_j_ = i - 1
			while _j_ >= 1 and _aResult_[_j_] > _nV_
				_aResult_[_j_ + 1] = _aResult_[_j_]
				_j_--
			end
			_aResult_[_j_ + 1] = _nV_
		next
		return _aResult_

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
		_anFirstPos_ = This.FindCS(pcSubStr, pCaseSensitive)
		_nLen_ = len(_anFirstPos_)

		if _nLen_ = 0
			return []
		ok

		_aResult_ = []
		_nLenSubStr_ = StzLen(pcSubStr)

		for i = 1 to _nLen_
			_aResult_ + [ _anFirstPos_[i], _anFirstPos_[i] + _nLenSubStr_ - 1 ]
		next

		return _aResult_

	def FindAsSections(pcSubStr)
		return This.FindAsSectionsCS(pcSubStr, 1)

	  #=============================================#
	 #     FIND BETWEEN TWO BOUNDS AS SECTION      #
	#=============================================#

	# The [start, end] sections of the substrings between the two
	# bounds.
	def FindBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)

		_nLen1_ = StzLen(pcBound1)
		_n1_ = This.FindFirstCS(pcBound1, pCaseSensitive)
		if _n1_ = 0
			return [0, 0]
		ok
		_n1_ = _n1_ + _nLen1_

		_n2_ = This.FindLastCS(pcBound2, pCaseSensitive)
		if _n2_ = 0
			return [0, 0]
		ok
		_n2_ = _n2_ - 1

		if _n2_ < _n1_
			_nTemp_ = _n2_
			_n2_ = _n1_
			_n1_ = _nTemp_
		ok

		_aResult_ = [ _n1_, _n2_ ]
		return _aResult_

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

		_cBound1_ = pacBounds[1]
		_cBound2_ = pacBounds[2]

		_anPos1_ = This.FindCS(_cBound1_, pCaseSensitive)
		_anPos2_ = This.FindCS(_cBound2_, pCaseSensitive)

		_nLen1_ = StzLen(_cBound1_)

		_aResult_ = []

		# For each bound1 occurrence, find the next bound2 after it
		_nPos1Len_ = len(_anPos1_)
		for i = 1 to _nPos1Len_
			_nAfter_ = _anPos1_[i] + _nLen1_
			# Find the nearest bound2 that starts after bound1 ends
			_nPos2Len_ = len(_anPos2_)
			for _j_ = 1 to _nPos2Len_
				if _anPos2_[_j_] > _anPos1_[i] + _nLen1_ - 1
					_aResult_ + [ _nAfter_, _anPos2_[_j_] - 1 ]
					exit
				ok
			next
		next

		return _aResult_

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
		_cStr_ = @oString.Content()
		if _cStr_ = ""
			return []
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		pResult = StzEngineStringAllSubstringsCS(@oString.Engine(), _bCase_)
		_cJoined_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)

		return _SplitNullDelimited(_cJoined_)

	def SubStrings()
		return This.SubStringsCS(1)

	  #===============================#
	 #     FIND DUPLICATES           #
	#===============================#

	def DuplicatesCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringDuplicateSubstringsCS(pH, _bCase_)
		_cJoined_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		if _cJoined_ = ""
			return []
		ok
		return _SplitNullDelimited(_cJoined_)

	def Duplicates()
		return This.DuplicatesCS(1)

	# The [start, end] sections of the 2nd+ occurrences of
	# duplicated chars.
	# The [start, end] sections of the 2nd+ occurrences of
	# duplicated chars.
	def FindDuplicatesAsSectionsCS(pCaseSensitive)
		_acDuplicates_ = This.DuplicatesCS(pCaseSensitive)
		_nLen_ = len(_acDuplicates_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aSections_ = This.FindAsSectionsCS(_acDuplicates_[i], pCaseSensitive)
			# Remove first occurrence — keep only duplicates
			if len(_aSections_) > 1
				_nSectionsLen_ = len(_aSections_)
				for _j_ = 2 to _nSectionsLen_
					_aResult_ + _aSections_[_j_]
				next
			ok
		next

		# Sort by start position
		_nLenR_ = len(_aResult_)
		for i = 1 to _nLenR_ - 1
			for _j_ = 1 to _nLenR_ - i
				if _aResult_[_j_][1] > _aResult_[_j_+1][1]
					_temp_ = _aResult_[_j_]
					_aResult_[_j_] = _aResult_[_j_+1]
					_aResult_[_j_+1] = _temp_
				ok
			next
		next

		return _aResult_

	def FindDuplicatesAsSections()
		return This.FindDuplicatesAsSectionsCS(1)

	  #========================================#
	 #     FIND WITH CONDITION (FindW)        #
	#========================================#

	# The positions of the chars satisfying the W condition.
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
		_cLower_ = StzCaseFold(pcCondition)
		_oTmp_ = new stzStringFinder(_cLower_)
		if _oTmp_.Contains("@substring")
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

	# The position of the first occurrence of the given substring (0
	# if none).
	def IndexOfCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		return StzEngineStringFindFirstCS(pH, pcSubStr, _bCase_)

	def IndexOf(pcSubStr)
		return This.IndexOfCS(pcSubStr, 1)

	  #===============================#
	 #     FIND ALL CHAR             #
	#===============================#

	# The positions of every occurrence of the given char.
	def FindAllChar(pcChar)
		pH = @oString.Engine()
		pHChar = StzEngineString(pcChar)
		_nCp_ = StzEngineStringCharAt(pHChar, 1)
		StzEngineStringFree(pHChar)
		pResult = StzEngineStringFindChar(pH, _nCp_)
		_nCount_ = StzEngineFindResultCount(pResult)
		if _nCount_ = 0
			StzEngineFindResultFree(pResult)
			return []
		ok
		_anResult_ = []
		for i = 1 to _nCount_
			_anResult_ + StzEngineFindResultGet(pResult, i)
		next
		StzEngineFindResultFree(pResult)
		return _anResult_

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

	# TRUE if the string ends with ANY of the given suffixes.
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

	def BetweenNth(pcOpen, pcClose, _n_)
		pH = @oString.Engine()
		# Engine uses 0-based nth; Softanza uses 1-based
		pR = StzEngineStringBetweenNth(pH, pcOpen, pcClose, _n_ - 1)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     CHARS BETWEEN POSITIONS   #
	#===============================#

	def CharsBetween(nFrom, nTo)
		pH = @oString.Engine()
		pR = StzEngineStringCharsBetween(pH, nFrom, nTo)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     REGEX FIND               #
	#===============================#

	# Find the first match of the given regex pattern.
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

	# Find every match of the given regex pattern.
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

