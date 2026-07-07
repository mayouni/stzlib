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

func StzConcatenate(pacListOfStr)
	return StzConcatenateXT(pacListOfStr, "")

	func Concatenate(pacListOfStr)
		return StzConcatenate(pacListOfStr)

func StzConcatenateXT(pacListOfStr, pcSep)
	if CheckingParams()
		if isList(pcSep) and len(pcSep) = 2 and isString(pcSep[1]) and
		   (StzCaseFold(pcSep[1]) = "with" or StzCaseFold(pcSep[1]) = "using")
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

	func ConcatenateXT(pacListOfStr, pcSep)
		return StzConcatenateXT(pacListOfStr, pcSep)

	func ConcatXT(acListOfStr, cSep)
		return StzConcatenateXT(acListOfStr, cSep)

func StzListOfStrings(paList)
	if @IsListOfStrings(paList)
		return paList
	ok

	func ListOfStrings(paList)
		return StzListOfStrings(paList)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListOfstrings from stzStringList

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
		if _bCase_
			for i = 1 to nLen
				if @acContent[i] = pcStr
					return 1
				ok
			next
		else
			cTarget = StzCaseFold(pcStr)
			for i = 1 to nLen
				if StzCaseFold(@acContent[i]) = cTarget
					return 1
				ok
			next
		ok
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
			pH = StzEngineString(@acContent[i])
			nFound = StzEngineStringContainsCS(pH, pcSubStr, _bCase_)
			StzEngineStringFree(pH)
			if nFound
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

		if _bCase_
			# Case-sensitive: direct string comparison (no FFI needed)
			for i = 1 to nLen
				if @acContent[i] = pcStr
					anResult + i
				ok
			next
		else
			# Case-insensitive: use engine casefold comparison
			cTarget = StzCaseFold(pcStr)
			for i = 1 to nLen
				if StzCaseFold(@acContent[i]) = cTarget
					anResult + i
				ok
			next
		ok
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

	def SortInAscendingCS(pCaseSensitive)
		# Engine-backed O(n log n) sort via null-delimited items
		nLen = len(@acContent)
		if nLen < 2
			return
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		# Join items with null bytes
		cJoined = ""
		for i = 1 to nLen
			if i > 1
				cJoined += StzChar(0)
			ok
			cJoined += @acContent[i]
		next

		# Sort via engine
		pH = StzEngineString(cJoined)
		pR = StzEngineStringSortNullItemsCS(pH, _bCase_)
		cSorted = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)

		@acContent = _SplitNullDelimited(cSorted)

		def SortInAscendingCSQ(pCaseSensitive)
			This.SortInAscendingCS(pCaseSensitive)
			return This

	def SortInAscending()
		This.SortInAscendingCS(1)

		def SortInAscendingQ()
			This.SortInAscending()
			return This

		def SortUp()
			This.SortInAscending()

	def SortedInAscendingCS(pCaseSensitive)
		oCopy = This.Copy()
		oCopy.SortInAscendingCS(pCaseSensitive)
		return oCopy.Content()

	def SortedInAscending()
		return This.SortedInAscendingCS(1)

		# Sorted() shorthand -- default ascending case-sensitive sort,
		# used by narrative one-liners like `o.Sorted()` that don't
		# distinguish direction.
		def Sorted()
			return This.SortedInAscendingCS(1)

		def SortedUp()
			return This.SortedInAscending()

	# WithoutSpaces / WithoutSapces (Softanza intentionally accepts
	# the misspelled form): return the content with every space removed
	# from each string item.
	def WithoutSpaces()
		_aRes_ = []
		_nLen_ = len(@acContent)
		for _i_ = 1 to _nLen_
			_s_ = @acContent[_i_]
			_cClean_ = ""
			_nSLen_ = len(_s_)
			for _j_ = 1 to _nSLen_
				if _s_[_j_] != " " _cClean_ += _s_[_j_] ok
			next
			_aRes_ + _cClean_
		next
		return _aRes_

		def WithoutSapces()
			return This.WithoutSpaces()

		def TrimAll()
			return This.WithoutSpaces()

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

	  #------------------------------------------------------#
	 #   SORT BY EXPRESSION                                 #
	#------------------------------------------------------#

	# SortBy(cExpr): sort by an eval'd expression where @string
	# aliases the per-item string. Pre-compute keys once, then
	# insertion-sort over (key, value) pairs.
	def SortBy(pcExpr)
		# NOTE: `This.Content() + []` does NOT copy -- Ring's `+`
		# appends the empty list as a nested element, which then
		# sorts to the front (its key len([]) = 0). Build a real
		# shallow copy with a loop instead.
		_aSrc_ = This.Content()
		_nLen_ = len(_aSrc_)
		if _nLen_ < 2 return ok
		_aData_ = []
		for _i_ = 1 to _nLen_
			_aData_ + _aSrc_[_i_]
		next
		_aKeys_ = list(_nLen_)
		for _i_ = 1 to _nLen_
			@string = _aData_[_i_]
			eval("_key_ = " + pcExpr)
			_aKeys_[_i_] = _key_
		next
		for _i_ = 2 to _nLen_
			_curKey_ = _aKeys_[_i_]
			_curVal_ = _aData_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1 and _aKeys_[_j_] > _curKey_
				_aKeys_[_j_ + 1] = _aKeys_[_j_]
				_aData_[_j_ + 1] = _aData_[_j_]
				_j_--
			end
			_aKeys_[_j_ + 1] = _curKey_
			_aData_[_j_ + 1] = _curVal_
		next
		@acContent = _aData_

		def SortByQ(pcExpr)
			This.SortBy(pcExpr)
			return This

		def SortedDown()
			return This.SortedInDescending()

	  #======================================================#
	 #   REVERSE                                            #
	#======================================================#

	def Reverse()
		# Use ring_reverse -- bare `reverse(...)` resolves
		# case-insensitively to this class's own Reverse() (0 params)
		# and raises R20. Same shadow family as Insert/Add/Abs/Swap.
		@acContent = ring_reverse(@acContent)

		def ReverseQ()
			This.Reverse()
			return This

	def Reversed()
		return ring_reverse(@acContent)

	  #======================================================#
	 #   UNIQUE (remove duplicates, engine-backed)          #
	#======================================================#

	def UniqueCS(pCaseSensitive)
		# Engine-backed O(n) dedup via null-delimited items
		nLen = len(@acContent)
		if nLen < 2
			return
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		# Join items with null bytes
		cJoined = ""
		for i = 1 to nLen
			if i > 1
				cJoined += StzChar(0)
			ok
			cJoined += @acContent[i]
		next

		# Unique via engine (hashmap-based O(n))
		pH = StzEngineString(cJoined)
		pR = StzEngineStringUniqueNullItemsCS(pH, _bCase_)
		cUnique = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)

		@acContent = _SplitNullDelimited(cUnique)

		def UniqueCSQ(pCaseSensitive)
			This.UniqueCS(pCaseSensitive)
			return This

	def Unique()
		This.UniqueCS(1)

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
			pH = StzEngineString(@acContent[i])
			nFound = StzEngineStringContainsCS(pH, pcSubStr, _bCase_)
			StzEngineStringFree(pH)
			if nFound
				acResult + @acContent[i]
			ok
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
		nPrefixLen = StzLen(pcPrefix)
		if _bCase_
			for i = 1 to nLen
				if StzLeft(@acContent[i], nPrefixLen) = pcPrefix
					acResult + @acContent[i]
				ok
			next
		else
			cPrefix = StzCaseFold(pcPrefix)
			nFoldLen = StzLen(cPrefix)
			for i = 1 to nLen
				if StzLeft(StzCaseFold(@acContent[i]), nFoldLen) = cPrefix
					acResult + @acContent[i]
				ok
			next
		ok
		return acResult

	def FilterByStartsWith(pcPrefix)
		return This.FilterByStartsWithCS(pcPrefix, 1)

	def FilterByEndsWithCS(pcSuffix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		acResult = []
		nLen = len(@acContent)
		nSuffixLen = StzLen(pcSuffix)
		if _bCase_
			for i = 1 to nLen
				if StzRight(@acContent[i], nSuffixLen) = pcSuffix
					acResult + @acContent[i]
				ok
			next
		else
			cSuffix = StzCaseFold(pcSuffix)
			nFoldLen = StzLen(cSuffix)
			for i = 1 to nLen
				if StzRight(StzCaseFold(@acContent[i]), nFoldLen) = cSuffix
					acResult + @acContent[i]
				ok
			next
		ok
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
			acResult + StzUpper(@acContent[i])
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
			acResult + StzLower(@acContent[i])
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
		   (StzCaseFold(cSep[1]) = "using" or StzCaseFold(cSep[1]) = "with" or StzCaseFold(cSep[1]) = "by")
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

	# Long-tail methods needed by the test suite.
	def ConcatenateXT(p)
		_sep_ = ""
		if isString(p)
			_sep_ = p
		but isList(p) and len(p) = 2 and isString(p[1])
			_kw_ = lower(p[1])
			if _kw_ = "using" or _kw_ = "with" or _kw_ = "by"
				_sep_ = p[2]
			ok
		ok
		_l_ = @acContent
		_nL_ = len(_l_)
		_c_ = ""
		for _i_ = 1 to _nL_
			if NOT isString(_l_[_i_]) loop ok
			if _i_ > 1 _c_ += _sep_ ok
			_c_ += _l_[_i_]
		next
		return _c_

	def Concatenate()
		return This.ConcatenateXT("")

	def SpacesRemoved()
		_l_ = @acContent
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				_o_ = new stzString(_v_)
				_o_.RemoveSpaces()
				_aR_ + _o_.Content()
			else
				_aR_ + _v_
			ok
		next
		return _aR_

	def ConcatenateUsing(pcSep)
		return This.ConcatenateXT(pcSep)

	def RemoveSpaces()
		@acContent = This.SpacesRemoved()

		def RemoveSpacesQ()
			This.RemoveSpaces()
			return This

	# Substrongs/Substrinks (deliberate Softanza wordplay): the strings
	# that CONTAIN another item of the list, and the ones that are
	# CONTAINED IN another item (case-sensitive, engine-backed find).
	def SubStrongs()
		_aSbg_ = @acContent
		_nSbg_ = ring_len(_aSbg_)
		_aSbgRes_ = []
		for _iSbg_ = 1 to _nSbg_
			for _jSbg_ = 1 to _nSbg_
				if _iSbg_ != _jSbg_ and _aSbg_[_iSbg_] != _aSbg_[_jSbg_] and
				   StzFindFirst(_aSbg_[_iSbg_], _aSbg_[_jSbg_]) > 0
					_aSbgRes_ + _aSbg_[_iSbg_]
					exit
				ok
			next
		next
		return _aSbgRes_

	def SubStrinks()
		_aSbk_ = @acContent
		_nSbk_ = ring_len(_aSbk_)
		_aSbkRes_ = []
		for _iSbk_ = 1 to _nSbk_
			for _jSbk_ = 1 to _nSbk_
				if _iSbk_ != _jSbk_ and _aSbk_[_iSbk_] != _aSbk_[_jSbk_] and
				   StzFindFirst(_aSbk_[_jSbk_], _aSbk_[_iSbk_]) > 0
					_aSbkRes_ + _aSbk_[_iSbk_]
					exit
				ok
			next
		next
		return _aSbkRes_

	def StringsW(pcExpr)
		_l_ = @acContent
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if NOT isString(_v_) loop ok
			@string = _v_
			@item = _v_
			@i = _i_
			_b_ = FALSE
			try
				eval("_b_ = " + pcExpr)
			catch
				_b_ = FALSE
			done
			if _b_ _aR_ + _v_ ok
		next
		return _aR_

	#-- Joined / JoinedUsing: readable aliases of Concatenated /
	#-- ConcatenatedUsing (used by ..Q() chain idioms on lists).

	def Joined()
		return This.Concatenated()

	def JoinedUsing(pcSep)
		return This.ConcatenatedUsing(pcSep)

	  #==================================================#
	 #  TEXT-LIST ANALYSIS (for WordsQ / SentencesQ)    #
	#==================================================#
	# Composable text operations on a list of fragments (sentences or words), so
	# fluent chains read naturally: Q(text).SentencesQ().MostSimilarTo(query),
	# .ThatAre(:Positive), .ThatContain("word"), .Longest(). Each fragment is
	# scored via a throwaway stzString, so all the engine-backed NLP applies.

	# The fragment most similar to pcQuery by WORD OVERLAP (bag-of-words cosine) --
	# the right notion for sentences/documents. (The inherited MostSimilarTo() uses
	# Jaro-Winkler CHARACTER similarity, better for fuzzy word/typo matching.)
	def MostSimilarByMeaning(pcQuery)
		if NOT isString(pcQuery) return "" ok
		_nMsN_ = len(@acContent)
		if _nMsN_ = 0 return "" ok
		_cMsBest_ = ""
		_nMsBest_ = -1
		for _iMs_ = 1 to _nMsN_
			_oMs_ = new stzString(@acContent[_iMs_])
			_nMsSim_ = _oMs_.CosineSimilarityWith(pcQuery)
			if _nMsSim_ > _nMsBest_
				_nMsBest_ = _nMsSim_
				_cMsBest_ = @acContent[_iMs_]
			ok
		next
		return _cMsBest_

		def MostSimilarByMeaningQ(pcQuery)
			return new stzString(This.MostSimilarByMeaning(pcQuery))

	# Fragments whose sentiment label matches "positive"/"negative"/"neutral".
	def ThatAre(pcPolarity)
		if NOT isString(pcPolarity) return [] ok
		_cTaWant_ = lower(pcPolarity)
		_aTaOut_ = []
		_nTaN_ = len(@acContent)
		for _iTa_ = 1 to _nTaN_
			_oTa_ = new stzString(@acContent[_iTa_])
			if _oTa_.Sentiment() = _cTaWant_
				_aTaOut_ + @acContent[_iTa_]
			ok
		next
		return _aTaOut_

		def ThatAreQ(pcPolarity)
			return new stzListOfStrings(This.ThatAre(pcPolarity))

	# Fragments that contain pcSub (engine-backed, codepoint-safe).
	def ThatContain(pcSub)
		if NOT isString(pcSub) return [] ok
		_aTcOut_ = []
		_nTcN_ = len(@acContent)
		for _iTc_ = 1 to _nTcN_
			_oTc_ = new stzString(@acContent[_iTc_])
			if _oTc_.Contains(pcSub)
				_aTcOut_ + @acContent[_iTc_]
			ok
		next
		return _aTcOut_

		def ThatContainQ(pcSub)
			return new stzListOfStrings(This.ThatContain(pcSub))

	# The fragment with the most / fewest words (ties -> first).
	def _ByWordCount(bLongest)
		_nBwN_ = len(@acContent)
		if _nBwN_ = 0 return "" ok
		_cBwBest_ = @acContent[1]
		_oBw1_ = new stzString(_cBwBest_)
		_nBwBest_ = _oBw1_.NumberOfWords()
		for _iBw_ = 2 to _nBwN_
			_oBw_ = new stzString(@acContent[_iBw_])
			_nBwW_ = _oBw_.NumberOfWords()
			if (bLongest and _nBwW_ > _nBwBest_) or (NOT bLongest and _nBwW_ < _nBwBest_)
				_nBwBest_ = _nBwW_
				_cBwBest_ = @acContent[_iBw_]
			ok
		next
		return _cBwBest_

	def Longest()
		return This._ByWordCount(TRUE)

	def Shortest()
		return This._ByWordCount(FALSE)
