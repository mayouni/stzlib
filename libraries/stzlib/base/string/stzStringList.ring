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

	func ConcatXT(acListOfStr, _cSep_)
		return StzConcatenateXT(acListOfStr, _cSep_)

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

class stzStringList from stzObject

	@acContent = []

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Build the string-list object from the given list of strings.
	def init(paList)
		if NOT isList(paList)
			StzRaise("Can't create stzStringList! Parameter must be a list of strings.")
		ok

		_nLen_ = len(paList)
		for i = 1 to _nLen_
			if NOT isString(paList[i])
				StzRaise("Can't create stzStringList! All items must be strings.")
			ok
			@acContent + paList[i]
		next

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# (Doc()/Ask()/AskFor()/ExplainMethod() are inherited from stzObject.)

	def Content()
		return @acContent

	# A new stzStringList with the same strings.
	def Copy()
		return new stzStringList(@acContent)

	# How many strings the list holds.
	def NumberOfStrings()
		return len(@acContent)

		def Size()
			return This.NumberOfStrings()

	  #===============================#
	 #     NTH STRING ACCESS         #
	#===============================#

	# The string at position n.
	def NthString(n)
		return @acContent[n]

		def String(n)
			return This.NthString(n)

	# The first string of the list.
	def FirstString()
		return @acContent[1]

	# The last string of the list.
	def LastString()
		return @acContent[len(@acContent)]

	  #===============================#
	 #     ADD / REMOVE              #
	#===============================#

	# Add the given string at the end of the list (mutating).
	def Add(pcStr)
		if NOT isString(pcStr)
			StzRaise("Incorrect param type! pcStr must be a string.")
		ok
		@acContent + pcStr

		def AddQ(pcStr)
			This.Add(pcStr)
			return This

	# Insert the given string at the start of the list (mutating).
	def Prepend(pcStr)
		if NOT isString(pcStr)
			StzRaise("Incorrect param type! pcStr must be a string.")
		ok
		insert(@acContent, 0, pcStr)

		def PrependQ(pcStr)
			This.Prepend(pcStr)
			return This

	# Remove the string at position n (mutating).
	def RemoveAt(n)
		del(@acContent, n)

		def RemoveAtQ(n)
			This.RemoveAt(n)
			return This

	# Replace the string at position n with the given one (mutating).
	def ReplaceAt(n, pcNewStr)
		@acContent[n] = pcNewStr

		def ReplaceAtQ(n, pcNewStr)
			This.ReplaceAt(n, pcNewStr)
			return This

	# Replace the whole content with the given list of strings
	# (mutating; the single update point).
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

	# All the strings concatenated into one string.
	def Concat()
		# Engine-backed: build result by concatenating
		# engine handles pairwise

		_nLen_ = len(@acContent)
		if _nLen_ = 0
			return ""
		ok

		if _nLen_ = 1
			return @acContent[1]
		ok

		pResult = StzEngineString(@acContent[1])
		for i = 2 to _nLen_
			pOther = StzEngineString(@acContent[i])
			pNew = StzEngineStringConcat(pResult, pOther)
			StzEngineStringFree(pResult)
			StzEngineStringFree(pOther)
			pResult = pNew
		next

		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

		def Concatenated()
			return This.Concat()

	  #------------------------------------------------------#
	 #   CONCATENATION WITH SEPARATOR                       #
	#------------------------------------------------------#

	# The strings concatenated with the given separator between them.
	def ConcatUsing(pcSep)
		_nLen_ = len(@acContent)
		if _nLen_ = 0
			return ""
		ok

		_cResult_ = ""
		for i = 1 to _nLen_
			if i > 1
				_cResult_ += pcSep
			ok
			_cResult_ += @acContent[i]
		next
		return _cResult_

		def ConcatenatedUsing(pcSep)
			return This.ConcatUsing(pcSep)

	  #------------------------------------------------------#
	 #   CONCATENATION -- EXTENDED                          #
	#------------------------------------------------------#

	def ConcatXT(p)
		if isString(p)
			return This.ConcatUsing(p)

		but isList(p)
			_oList_ = new stzList(p)
			if _oList_.IsUsingNamedParam()
				return This.ConcatUsing(p[2])
			ok
		ok

		return This.Concat()

		def ConcatenatedXT(p)
			return This.ConcatXT(p)

	  #======================================================#
	 #   CONTAINS (engine-backed)                           #
	#======================================================#

	# TRUE if one of the strings equals pcStr.
	def ContainsCS(pcStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		_nLen_ = len(@acContent)
		if _bCase_
			for i = 1 to _nLen_
				if @acContent[i] = pcStr
					return 1
				ok
			next
		else
			_cTarget_ = StzCaseFold(pcStr)
			for i = 1 to _nLen_
				if StzCaseFold(@acContent[i]) = _cTarget_
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

		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			pH = StzEngineString(@acContent[i])
			_nFound_ = StzEngineStringContainsCS(pH, pcSubStr, _bCase_)
			StzEngineStringFree(pH)
			if _nFound_
				return 1
			ok
		next
		return 0

	def ContainsSubString(pcSubStr)
		return This.ContainsSubStringCS(pcSubStr, 1)

	  #======================================================#
	 #   FIND (engine-backed equality)                      #
	#======================================================#

	# The positions of every string equal to pcStr, as a list.
	def FindCS(pcStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		_anResult_ = []
		_nLen_ = len(@acContent)

		if _bCase_
			# Case-sensitive: direct string comparison (no FFI needed)
			for i = 1 to _nLen_
				if @acContent[i] = pcStr
					_anResult_ + i
				ok
			next
		else
			# Case-insensitive: use engine casefold comparison
			_cTarget_ = StzCaseFold(pcStr)
			for i = 1 to _nLen_
				if StzCaseFold(@acContent[i]) = _cTarget_
					_anResult_ + i
				ok
			next
		ok
		return _anResult_

	def Find(pcStr)
		return This.FindCS(pcStr, 1)

	# The position of the first string equal to pcStr (0 if none).
	def FindFirst(pcStr)
		_anAll_ = This.Find(pcStr)
		if len(_anAll_) > 0
			return _anAll_[1]
		ok
		return 0

	# The position of the last string equal to pcStr (0 if none).
	def FindLast(pcStr)
		_anAll_ = This.Find(pcStr)
		_nLen_ = len(_anAll_)
		if _nLen_ > 0
			return _anAll_[_nLen_]
		ok
		return 0

	  #======================================================#
	 #   SORT (engine-backed compare)                       #
	#======================================================#

	# Sort the strings in ascending order in place (mutating).
	def SortInAscendingCS(pCaseSensitive)
		# Engine-backed O(n log n) sort via null-delimited items
		_nLen_ = len(@acContent)
		if _nLen_ < 2
			return
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		# Join items with null bytes
		_cJoined_ = ""
		for i = 1 to _nLen_
			if i > 1
				_cJoined_ += StzChar(0)
			ok
			_cJoined_ += @acContent[i]
		next

		# Sort via engine
		pH = StzEngineString(_cJoined_)
		pR = StzEngineStringSortNullItemsCS(pH, _bCase_)
		_cSorted_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)

		@acContent = _SplitNullDelimited(_cSorted_)

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

	# An ascending-sorted copy; the original is unchanged.
	def SortedInAscendingCS(pCaseSensitive)
		_oCopy_ = This.Copy()
		_oCopy_.SortInAscendingCS(pCaseSensitive)
		return _oCopy_.Content()

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

	# Sort the strings in descending order in place (mutating).
	def SortInDescending()
		This.SortInAscending()
		This.Reverse()

		def SortInDescendingQ()
			This.SortInDescending()
			return This

		def SortDown()
			This.SortInDescending()

	# A descending-sorted copy; the original is unchanged.
	def SortedInDescending()
		_oCopy_ = This.Copy()
		_oCopy_.SortInDescending()
		return _oCopy_.Content()

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

	# Reverse the order of the strings in place (mutating).
	def Reverse()
		# Use ring_reverse -- bare `reverse(...)` resolves
		# case-insensitively to this class's own Reverse() (0 params)
		# and raises R20. Same shadow family as Insert/Add/Abs/Swap.
		@acContent = ring_reverse(@acContent)

		def ReverseQ()
			This.Reverse()
			return This

	# The strings in reverse order, as a Ring list; the original is unchanged.
	def Reversed()
		return ring_reverse(@acContent)

	  #======================================================#
	 #   UNIQUE (remove duplicates, engine-backed)          #
	#======================================================#

	def UniqueCS(pCaseSensitive)
		# Engine-backed O(n) dedup via null-delimited items
		_nLen_ = len(@acContent)
		if _nLen_ < 2
			return
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		# Join items with null bytes
		_cJoined_ = ""
		for i = 1 to _nLen_
			if i > 1
				_cJoined_ += StzChar(0)
			ok
			_cJoined_ += @acContent[i]
		next

		# Unique via engine (hashmap-based O(n))
		pH = StzEngineString(_cJoined_)
		pR = StzEngineStringUniqueNullItemsCS(pH, _bCase_)
		_cUnique_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)

		@acContent = _SplitNullDelimited(_cUnique_)

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
		_oCopy_ = This.Copy()
		_oCopy_.Unique()
		return _oCopy_.Content()

		def WithoutDuplicates()
			return This.UniqueItems()

	  #======================================================#
	 #   FILTER -- strings containing a substring           #
	#======================================================#

	def FilterCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		_acResult_ = []
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			pH = StzEngineString(@acContent[i])
			_nFound_ = StzEngineStringContainsCS(pH, pcSubStr, _bCase_)
			StzEngineStringFree(pH)
			if _nFound_
				_acResult_ + @acContent[i]
			ok
		next
		return _acResult_

	def Filter(pcSubStr)
		return This.FilterCS(pcSubStr, 1)

	  #------------------------------------------------------#
	 #   FILTER BY STARTS-WITH / ENDS-WITH                  #
	#------------------------------------------------------#

	def FilterByStartsWithCS(pcPrefix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		_acResult_ = []
		_nLen_ = len(@acContent)
		_nPrefixLen_ = StzLen(pcPrefix)
		if _bCase_
			for i = 1 to _nLen_
				if StzLeft(@acContent[i], _nPrefixLen_) = pcPrefix
					_acResult_ + @acContent[i]
				ok
			next
		else
			_cPrefix_ = StzCaseFold(pcPrefix)
			_nFoldLen_ = StzLen(_cPrefix_)
			for i = 1 to _nLen_
				if StzLeft(StzCaseFold(@acContent[i]), _nFoldLen_) = _cPrefix_
					_acResult_ + @acContent[i]
				ok
			next
		ok
		return _acResult_

	def FilterByStartsWith(pcPrefix)
		return This.FilterByStartsWithCS(pcPrefix, 1)

	def FilterByEndsWithCS(pcSuffix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		_acResult_ = []
		_nLen_ = len(@acContent)
		_nSuffixLen_ = StzLen(pcSuffix)
		if _bCase_
			for i = 1 to _nLen_
				if StzRight(@acContent[i], _nSuffixLen_) = pcSuffix
					_acResult_ + @acContent[i]
				ok
			next
		else
			_cSuffix_ = StzCaseFold(pcSuffix)
			_nFoldLen_ = StzLen(_cSuffix_)
			for i = 1 to _nLen_
				if StzRight(StzCaseFold(@acContent[i]), _nFoldLen_) = _cSuffix_
					_acResult_ + @acContent[i]
				ok
			next
		ok
		return _acResult_

	def FilterByEndsWith(pcSuffix)
		return This.FilterByEndsWithCS(pcSuffix, 1)

	  #======================================================#
	 #   CASE OPERATIONS (engine-backed)                    #
	#======================================================#

	# Uppercase every string in place (mutating).
	def ToUpper()
		_acResult_ = []
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_acResult_ + StzUpper(@acContent[i])
		next
		@acContent = _acResult_

		def ToUpperQ()
			This.ToUpper()
			return This

	# A copy with every string uppercased; the original is unchanged.
	def Uppercased()
		_oCopy_ = This.Copy()
		_oCopy_.ToUpper()
		return _oCopy_.Content()

	# Lowercase every string in place (mutating).
	def ToLower()
		_acResult_ = []
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_acResult_ + StzLower(@acContent[i])
		next
		@acContent = _acResult_

		def ToLowerQ()
			This.ToLower()
			return This

	# A copy with every string lowercased; the original is unchanged.
	def Lowercased()
		_oCopy_ = This.Copy()
		_oCopy_.ToLower()
		return _oCopy_.Content()

	  #======================================================#
	 #   SIMILARITY (engine-backed Jaro / JaroWinkler)      #
	#======================================================#

	def MostSimilarTo(pcTarget)
		# Returns the string from the list most similar to pcTarget
		# Uses engine JaroWinkler for best results

		_nLen_ = len(@acContent)
		if _nLen_ = 0
			return ""
		ok

		_nBestScore_ = -1
		_nBestIdx_ = 1

		pTarget = StzEngineString(pcTarget)

		for i = 1 to _nLen_
			pHandle = StzEngineString(@acContent[i])
			_nScore_ = StzEngineStringJaroWinkler(pHandle, pTarget)
			StzEngineStringFree(pHandle)

			if _nScore_ > _nBestScore_
				_nBestScore_ = _nScore_
				_nBestIdx_ = i
			ok
		next

		StzEngineStringFree(pTarget)
		return @acContent[_nBestIdx_]

	def SimilarToCS(pcTarget, nThreshold, pCaseSensitive)
		# Returns all strings with JaroWinkler score >= nThreshold
		# nThreshold is 0..1000 (engine returns integer scaled)

		_acResult_ = []
		_nLen_ = len(@acContent)

		pTarget = StzEngineString(pcTarget)

		for i = 1 to _nLen_
			pHandle = StzEngineString(@acContent[i])
			_nScore_ = StzEngineStringJaroWinkler(pHandle, pTarget)
			StzEngineStringFree(pHandle)
			if _nScore_ >= nThreshold
				_acResult_ + @acContent[i]
			ok
		next

		StzEngineStringFree(pTarget)
		return _acResult_

	def SimilarTo(pcTarget, nThreshold)
		return This.SimilarToCS(pcTarget, nThreshold, 1)

	  #======================================================#
	 #   CONVERSION                                         #
	#======================================================#

	# The strings joined with newlines, as one string.
	def ToString()
		return This.ConcatUsing(NL)

	# Each string wrapped as a stzString object, as a list.
	def ToListOfStzStrings()
		_aResult_ = []
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_aResult_ + new stzString(@acContent[i])
		next
		return _aResult_

	# The strings as a stzList object.
	def ToStzList()
		return new stzList(@acContent)

	  #======================================================#
	 #   SPLIT EACH STRING                                  #
	#======================================================#

	# Split each string on the given separator.
	def Split(_cSep_)
		if isList(_cSep_) and len(_cSep_) = 2 and isString(_cSep_[1]) and
		   (StzCaseFold(_cSep_[1]) = "using" or StzCaseFold(_cSep_[1]) = "with" or StzCaseFold(_cSep_[1]) = "by")
			_cSep_ = _cSep_[2]
		ok

		_aResult_ = []
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_oStr_ = new stzString(@acContent[i])
			_aResult_ + _oStr_.Split(_cSep_)
		next
		return _aResult_

	  #======================================================#
	 #   TRIM EACH STRING                                   #
	#======================================================#

	# Trim the spaces around each string in place (mutating).
	def Trim()
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_oStr_ = new stzString(@acContent[i])
			@acContent[i] = _oStr_.Trimmed()
		next

		def TrimQ()
			This.Trim()
			return This

	# A copy with each string trimmed; the original is unchanged.
	def Trimmed()
		_oCopy_ = This.Copy()
		_oCopy_.Trim()
		return _oCopy_.Content()

	  #======================================================#
	 #   REGEX MATCHING                                     #
	#======================================================#

	# The strings matching the given regex pattern.
	def Matches(pcRegexPatt)
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			if rx(pcRegexPatt).Match(@acContent[i]) = 0
				return 0
			ok
		next
		return 1

	  #======================================================#
	 #   TYPE IDENTITY                                      #
	#======================================================#

	# Always TRUE: the object IS a stzStringList.
	def IsStzStringList()
		return 1

	# The Softanza type symbol: :stzStringList.
	def stzType()
		return :stzStringList

		# The lowercase class name: "stzstringlist".
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

	# All the strings concatenated, no separator.
	def Concatenate()
		return This.ConcatenateXT("")

	# The strings with their spaces removed, as data.
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

	# Remove the spaces inside each string (mutating).
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

	# The substrings of each string (playful alias).
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

	# The strings satisfying the given W expression.
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
	 #  STRING-LIST SELECTION (lexical)                 #
	#==================================================#
	# Lexical (non-semantic) selection over a list of fragments -- substring
	# membership and word-length ranking -- so chains like
	# Q(text).WordsQ().ThatContain("ing").Longest() read naturally. These are
	# STRING ops (any list of strings has them). MEANING-based selection
	# (MostSimilarByMeaning, ThatAre by sentiment) lives on stzListOfTexts, the
	# list-of-texts domain -- because that is natural processing, not a string op.

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

	# The string with the MOST words.
	def Longest()
		return This._ByWordCount(TRUE)

	# The string with the FEWEST words.
	def Shortest()
		return This._ByWordCount(FALSE)
