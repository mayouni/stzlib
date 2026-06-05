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

		nLen = ring_len(paList)
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
		return ring_len(@acContent)

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
		return @acContent[ring_len(@acContent)]

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

		nLen = ring_len(@acContent)
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
		nLen = ring_len(@acContent)
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

		nLen = ring_len(@acContent)
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

		nLen = ring_len(@acContent)
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
		nLen = ring_len(@acContent)

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
		if ring_len(anAll) > 0
			return anAll[1]
		ok
		return 0

	def FindLast(pcStr)
		anAll = This.Find(pcStr)
		nLen = ring_len(anAll)
		if nLen > 0
			return anAll[nLen]
		ok
		return 0

	  #======================================================#
	 #   SORT (engine-backed compare)                       #
	#======================================================#

	def SortInAscendingCS(pCaseSensitive)
		# Engine-backed O(n log n) sort via null-delimited items
		nLen = ring_len(@acContent)
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
		_aData_ = This.Content() + []
		_nLen_ = ring_len(_aData_)
		if _nLen_ < 2 return ok
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
		nLen = ring_len(@acContent)
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
		nLen = ring_len(@acContent)
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
		nLen = ring_len(@acContent)
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
		nLen = ring_len(@acContent)
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
		nLen = ring_len(@acContent)
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
		nLen = ring_len(@acContent)
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

		nLen = ring_len(@acContent)
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
		nLen = ring_len(@acContent)

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
		nLen = ring_len(@acContent)
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
		if isList(cSep) and ring_len(cSep) = 2 and isString(cSep[1]) and
		   (StzCaseFold(cSep[1]) = "using" or StzCaseFold(cSep[1]) = "with" or StzCaseFold(cSep[1]) = "by")
			cSep = cSep[2]
		ok

		aResult = []
		nLen = ring_len(@acContent)
		for i = 1 to nLen
			oStr = new stzString(@acContent[i])
			aResult + oStr.Split(cSep)
		next
		return aResult

	  #======================================================#
	 #   TRIM EACH STRING                                   #
	#======================================================#

	def Trim()
		nLen = ring_len(@acContent)
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
		nLen = ring_len(@acContent)
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
