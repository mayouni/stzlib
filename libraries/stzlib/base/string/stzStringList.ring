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

# Gives stzStringList its other name: the class that holds a list of strings.
#
# An empty subclass: every method is stzStringList's, and new stzListOfStrings([ ... ]) builds the
# same kind of object as new stzStringList([ ... ]).
#
#   receiver   o1 = new stzListOfStrings([ "ab", "cd", "ab" ])
#   example    ? o1.NumberOfStrings()
#              #--> 3
#   see        stzStringList, stzList
class stzListOfstrings from stzStringList

# Holds a list of strings and answers questions about it: find, count, sort, filter, replace, split and change case.
#
# Reach for it when the strings of a list are the subject and a stzList is more than you need. It
# checks at birth that every item is a string, and the per-string work goes to the engine. Methods
# such as Add, SortInAscending, Unique, ToUpper and Trim change the list in place; the Sorted,
# Uppercased and Trimmed forms return a plain Ring list and leave it alone. Search methods come in a
# case-sensitive form and a CS form that takes a flag, as in FindCS(pcStr, 0).
#
#   receiver   o1 = new stzStringList([ "ab", "cd", "ab" ])
#   example    ? @@( o1.Find("ab") )
#              #--> [ 1, 3 ]
#   see        stzListOfstrings, stzList, stzString
class stzStringList from stzObject

	@acContent = []

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds the string list from a Ring list whose items are all strings, and raises for anything else.
	#
	#   paList     the list of strings to hold
	#   returns    nothing; builds the object
	#   note       a non-list raises "Can't create stzStringList!", and so does one item that is not
	#              a string
	#   see        Update, Content
	#@ aka  Build the string-list object from the given list of strings.
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

	# Returns the strings held, as a plain Ring list.
	#
	#   returns    a list of strings
	#   see        Copy, ToStzList
	#@ aka  (Doc()/Ask()/AskFor()/ExplainMethod() are inherited from stzObject.)
	def Content()
		return @acContent

	# Returns a new stzStringList holding the same strings, so changing the copy leaves the original alone.
	#
	#   returns    a stzStringList object
	#   see        Content
	#@ aka  A new stzStringList with the same strings.
	def Copy()
		return new stzStringList(@acContent)

	# Returns how many strings the list holds.
	#
	#   returns    a number
	#@ aka  How many strings the list holds.
	def NumberOfStrings()
		return len(@acContent)

		def Size()
			return This.NumberOfStrings()

	  #===============================#
	 #     NTH STRING ACCESS         #
	#===============================#

	# Returns the string at position n; it raises R2 when n is 0 or past the end.
	#
	#   n          the position, 1 is the first
	#   returns    a string
	#   see        FirstString, LastString
	#@ aka  The string at position n.
	def NthString(n)
		return @acContent[n]

		def String(n)
			return This.NthString(n)

	# Returns the first string of the list; it raises R2 on an empty list.
	#
	#   returns    a string
	#   see        LastString, NthString
	#@ aka  The first string of the list.
	def FirstString()
		return @acContent[1]

	# Returns the last string of the list; it raises R2 on an empty list.
	#
	#   returns    a string
	#   see        FirstString, NthString
	#@ aka  The last string of the list.
	def LastString()
		return @acContent[len(@acContent)]

	  #===============================#
	 #     ADD / REMOVE              #
	#===============================#

	# Appends the string at the end of the list, in place; it raises for a value that is not a string.
	#
	#   pcStr      the string to append
	#   returns    nothing; the list changes
	#   see        Prepend
	#@ aka  Add the given string at the end of the list (mutating).
	def Add(pcStr)
		if NOT isString(pcStr)
			StzRaise("Incorrect param type! pcStr must be a string.")
		ok
		@acContent + pcStr

		def AddQ(pcStr)
			This.Add(pcStr)
			return This

	# Puts the string at the start of the list, in place; it raises for a value that is not a string.
	#
	#   pcStr      the string to put first
	#   returns    nothing; the list changes
	#   see        Add
	#@ aka  Insert the given string at the start of the list (mutating).
	def Prepend(pcStr)
		if NOT isString(pcStr)
			StzRaise("Incorrect param type! pcStr must be a string.")
		ok
		insert(@acContent, 0, pcStr)

		def PrependQ(pcStr)
			This.Prepend(pcStr)
			return This

	# Removes the string at position n, in place; it raises "error in range" when n is out of range.
	#
	#   n          the position of the string to remove
	#   returns    nothing; the list changes
	#   note       RemoveStringAtPosition does the same but ignores a bad position silently
	#   see        RemoveStringAtPosition
	#@ aka  Remove the string at position n (mutating).
	def RemoveAt(n)
		del(@acContent, n)

		def RemoveAtQ(n)
			This.RemoveAt(n)
			return This

	# Replaces the string at position n with the new one, in place; it raises R2 when n is 0 or past the end.
	#
	#   n          the position of the string to replace
	#   pcNewStr   the string that takes its place
	#   returns    nothing; the list changes
	#   see        ReplaceString
	#@ aka  Replace the string at position n with the given one (mutating).
	def ReplaceAt(n, pcNewStr)
		@acContent[n] = pcNewStr

		def ReplaceAtQ(n, pcNewStr)
			This.ReplaceAt(n, pcNewStr)
			return This

	# Replaces the whole content with a new list of strings, in place; it raises unless every item is a string.
	#
	#   paNewList   the new strings, all of them text
	#   returns     nothing; the list changes
	#   see         Content
	#@ aka  Replace the whole content with the given list of strings (mutating; the single update point).
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

	# Returns all the strings joined end to end, with nothing between them, as one string.
	#
	#   returns    a string
	#   see        ConcatUsing, Concatenate
	#@ aka  All the strings concatenated into one string.
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

	# Returns all the strings joined as one string, with the separator between each two.
	#
	#   pcSep      the text put between the strings
	#   returns    a string
	#   note       an empty list answers an empty string
	#   see        Concat
	#@ aka  The strings concatenated with the given separator between them.
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

	# TRUE if one string of the list equals the given string as a whole, case-sensitive.
	#
	#   pcStr      the string to look for, matched against whole items
	#   returns    TRUE or FALSE
	#   note       Contains("") is FALSE unless an item is empty
	#   see        ContainsCS, ContainsSubString
	def Contains(pcStr)
		return This.ContainsCS(pcStr, 1)

	  #------------------------------------------------------#
	 #   CONTAINS SUBSTRING IN ANY STRING                   #
	#------------------------------------------------------#

	def ContainsSubStringCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_pH_ = StzEngineString(@acContent[i])
			_nFound_ = StzEngineStringContainsCS(_pH_, pcSubStr, _bCase_)
			StzEngineStringFree(_pH_)
			if _nFound_
				return 1
			ok
		next
		return 0

	# TRUE if the text occurs inside at least one string of the list, case-sensitive.
	#
	#   returns    TRUE or FALSE
	#   see        Contains, ContainsSubstringInEachString
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

	# Returns the positions of every string equal to the given one, case-sensitive.
	#
	#   pcStr      the string to look for, matched against whole items
	#   returns    a list of numbers; an empty list when none match
	#   see        FindCS, FindFirst, FindLast
	def Find(pcStr)
		return This.FindCS(pcStr, 1)

	# Returns the position of the first string equal to the given one, or 0 when none is.
	#
	#   pcStr      the string to look for, matched against whole items
	#   returns    a number
	#   see        FindLast, Find
	#@ aka  The position of the first string equal to pcStr (0 if none).
	def FindFirst(pcStr)
		_anAll_ = This.Find(pcStr)
		if len(_anAll_) > 0
			return _anAll_[1]
		ok
		return 0

	# Returns the position of the last string equal to the given one, or 0 when none is.
	#
	#   pcStr      the string to look for, matched against whole items
	#   returns    a number
	#   see        FindFirst, Find
	#@ aka  The position of the last string equal to pcStr (0 if none).
	def FindLast(pcStr)
		_anAll_ = This.Find(pcStr)
		_nLen_ = len(_anAll_)
		if _nLen_ > 0
			return _anAll_[_nLen_]
		ok
		return 0

	  #======================================================#
	 #   THE VOCABULARY THE TESTS ALREADY SPEAK             #
	#======================================================#
	#
	# Twenty-odd methods below were called by this topic's tests and had never
	# been written -- FindStringCS, RemoveAll, NumberOfOccurrence, Move and the
	# rest. They surfaced only after nine test files were repaired: an
	# extraction had left each file's opening `StzListOfStringsQ([...]) {` line
	# stranded inside its comment header, so the file could not compile and
	# nothing inside it ever ran. A file that does not run hides every gap it
	# would have found.
	#
	# The SHAPES are taken from the call sites, not invented: FindStringCS
	# answers a LIST of positions (the tests print `[ ]` and `[4]`),
	# FindNthOccurrenceCS answers a single position, NumberOfOccurrence counts
	# whole-string matches while NumberOfOccurrenceOfSubString counts
	# substrings across every string.

	# --- FINDING ------------------------------------------------------

	# Every position holding pcStr. The plain-name twin of FindCS.
	def FindStringCS(pcStr, pCaseSensitive)
		return This.FindCS(pcStr, pCaseSensitive)

		def FindStringQCS(pcStr, pCaseSensitive)
			return new stzList( This.FindStringCS(pcStr, pCaseSensitive) )

	# Returns the positions of every string equal to the given one, as the plain form does.
	#
	#   pcStr      the string to look for, matched against whole items
	#   returns    a list of numbers; an empty list when none match
	#   see        Find
	def FindString(pcStr)
		return This.FindCS(pcStr, 1)

	def FindFirstCS(pcStr, pCaseSensitive)
		_an_ = This.FindCS(pcStr, pCaseSensitive)
		if len(_an_) > 0
			return _an_[1]
		ok
		return 0

	def FindLastCS(pcStr, pCaseSensitive)
		_an_ = This.FindCS(pcStr, pCaseSensitive)
		_n_ = len(_an_)
		if _n_ > 0
			return _an_[_n_]
		ok
		return 0

	# The position of the Nth string equal to pcStr, or 0 when there are
	# fewer than N of them.
	def FindNthOccurrenceCS(n, pcStr, pCaseSensitive)
		if NOT isNumber(n) or n < 1
			return 0
		ok
		_an_ = This.FindCS(pcStr, pCaseSensitive)
		if len(_an_) >= n
			return _an_[n]
		ok
		return 0

		# Returns the position of the nth string equal to the given one, or 0 when fewer than n are.
		#
		#   n          which occurrence, 1 is the first
		#   pcStr      the string to look for
		#   returns    a number
		#   see        Find, FindFirst
		def FindNthOccurrence(n, pcStr)
			return This.FindNthOccurrenceCS(n, pcStr, 1)

	# --- COUNTING -----------------------------------------------------

	# How many strings EQUAL pcStr.
	def NumberOfOccurrenceCS(pcStr, pCaseSensitive)
		return len( This.FindCS(pcStr, pCaseSensitive) )

		# Returns how many strings of the list equal the given one as a whole, case-sensitive.
		#
		#   pcStr      the string to count, matched against whole items
		#   returns    a number
		#   see        NumberOfOccurrenceOfSubString
		def NumberOfOccurrence(pcStr)
			return This.NumberOfOccurrenceCS(pcStr, 1)

		# Returns how many strings of the list equal the given one as a whole, case-sensitive.
		#
		#   pcStr      the string to count, matched against whole items
		#   returns    a number
		#   see        NumberOfOccurrenceOfSubString
		def NumberOfOccurrences(pcStr)
			return This.NumberOfOccurrenceCS(pcStr, 1)

	# How many times pcSubStr occurs INSIDE the strings, summed over all of
	# them -- a different question from the one above, and the reason both
	# names exist.
	def NumberOfOccurrenceOfSubStringCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nTotal_ = 0
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_nTotal_ += len( StzFindCS(pcSubStr, @acContent[i], _bCase_) )
		next
		return _nTotal_

		# Returns how many times the text occurs inside the strings, summed over all of them.
		#
		#   returns    a number
		#   note       Hello, world, hello, World hold four o's
		#   see        NumberOfOccurrence
		def NumberOfOccurrenceOfSubString(pcSubStr)
			return This.NumberOfOccurrenceOfSubStringCS(pcSubStr, 1)

	# --- DUPLICATES ---------------------------------------------------

	# The strings that appear more than once, each named ONCE and in the
	# order of their first appearance.
	def DuplicatedStringsCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_acSeen_ = []
		_acDup_ = []
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_cKey_ = @acContent[i]
			if NOT _bCase_
				_cKey_ = StzCaseFold(_cKey_)
			ok
			if StzFindFirst(_cKey_, _acSeen_) > 0
				if StzFindFirst(_cKey_, _acDup_) = 0
					_acDup_ + _cKey_
				ok
			else
				_acSeen_ + _cKey_
			ok
		next
		return _acDup_

		# Returns each string that appears more than once, named once, in the order of its first appearance.
		#
		#   returns    a list of strings
		#   note       the CS form with the flag 0 answers the folded lowercase spelling, not the
		#              original
		#   see        UniqueItems, Unique
		def DuplicatedStrings()
			return This.DuplicatedStringsCS(1)

	# --- REMOVING -----------------------------------------------------

	# Every string equal to pcStr goes. Walks BACKWARDS: removing forwards
	# shifts the positions still to be visited, which is how this kind of
	# loop silently skips a neighbouring duplicate.
	def RemoveAllCS(pcStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_cTarget_ = pcStr
		if NOT _bCase_
			_cTarget_ = StzCaseFold(pcStr)
		ok
		for i = len(@acContent) to 1 step -1
			_cItem_ = @acContent[i]
			if NOT _bCase_
				_cItem_ = StzCaseFold(_cItem_)
			ok
			if _cItem_ = _cTarget_
				del(@acContent, i)
			ok
		next

		def RemoveAllCSQ(pcStr, pCaseSensitive)
			This.RemoveAllCS(pcStr, pCaseSensitive)
			return This

	# Removes every string equal to the given one, in place, case-sensitive.
	#
	#   pcStr      the string to remove, matched against whole items
	#   returns    nothing; the list changes
	#   see        RemoveFirst, RemoveMany
	def RemoveAll(pcStr)
		This.RemoveAllCS(pcStr, 1)

		def RemoveAllQ(pcStr)
			This.RemoveAll(pcStr)
			return This

	# Only the FIRST one goes.
	def RemoveFirstCS(pcStr, pCaseSensitive)
		_n_ = This.FindFirstCS(pcStr, pCaseSensitive)
		if _n_ > 0
			del(@acContent, _n_)
		ok

		def RemoveFirstCSQ(pcStr, pCaseSensitive)
			This.RemoveFirstCS(pcStr, pCaseSensitive)
			return This

	# Removes only the first string equal to the given one, in place, case-sensitive.
	#
	#   pcStr      the string to remove, matched against whole items
	#   returns    nothing; the list changes
	#   see        RemoveAll
	def RemoveFirst(pcStr)
		This.RemoveFirstCS(pcStr, 1)

		def RemoveFirstQ(pcStr)
			This.RemoveFirst(pcStr)
			return This

	# Removes the first string, whatever it is, in place; an empty list stays empty.
	#
	#   returns    nothing; the list changes
	#   see        RemoveLastString
	#@ aka  No argument: drop whatever sits first, whatever it is.
	def RemoveFirstString()
		if len(@acContent) > 0
			del(@acContent, 1)
		ok

		def RemoveFirstStringQ()
			This.RemoveFirstString()
			return This

	# Removes the last string, whatever it is, in place; an empty list stays empty.
	#
	#   returns    nothing; the list changes
	#   see        RemoveFirstString
	def RemoveLastString()
		if len(@acContent) > 0
			del(@acContent, len(@acContent))
		ok

		def RemoveLastStringQ()
			This.RemoveLastString()
			return This

	def RemoveNthOccurrenceCS(n, pcStr, pCaseSensitive)
		_nPos_ = This.FindNthOccurrenceCS(n, pcStr, pCaseSensitive)
		if _nPos_ > 0
			del(@acContent, _nPos_)
		ok

		# Removes the nth string equal to the given one, in place; nothing happens when fewer than n are.
		#
		#   n          which occurrence, 1 is the first
		#   pcStr      the string to remove
		#   returns    nothing; the list changes
		#   see        RemoveFirst
		def RemoveNthOccurrence(n, pcStr)
			This.RemoveNthOccurrenceCS(n, pcStr, 1)

		def RemoveNthOccurrenceQ(n, pcStr)
			This.RemoveNthOccurrence(n, pcStr)
			return This

	# Removes the string at position n, in place; a position out of range is ignored silently.
	#
	#   n          the position of the string to remove
	#   returns    nothing; the list changes
	#   see        RemoveAt
	def RemoveStringAtPosition(n)
		if isNumber(n) and n >= 1 and n <= len(@acContent)
			del(@acContent, n)
		ok

		# Removes the string at position n, in place; a position out of range is ignored silently.
		#
		#   n          the position of the string to remove
		#   returns    nothing; the list changes
		#   see        RemoveAt
		#@ aka  The test file says it plainly: "RemoveNthString(3) # or RemoveStringAtPosition(3)". Both spellings, one implementation.
		def RemoveNthString(n)
			This.RemoveStringAtPosition(n)

		def RemoveNthStringQ(n)
			This.RemoveStringAtPosition(n)
			return This

		def RemoveStringAtPositionQ(n)
			This.RemoveStringAtPosition(n)
			return This

	# Removes the strings at all the given positions in one go, in place; positions out of range are ignored.
	#
	#   panPositions   the positions of the strings to remove, read against the original list
	#   returns        nothing; the list changes
	#   note           the positions may come in any order
	#   see            RemoveAt
	#@ aka  Positions are read against the ORIGINAL list, so they are sorted and applied from the back. Taking them in the order given would make each removal shift the ones after it.
	def RemoveStringsAtThesePositions(panPositions)
		if NOT isList(panPositions)
			return
		ok
		_an_ = ring_sort(panPositions)
		for i = len(_an_) to 1 step -1
			_p_ = _an_[i]
			if isNumber(_p_) and _p_ >= 1 and _p_ <= len(@acContent)
				del(@acContent, _p_)
			ok
		next

		def RemoveStringsAtThesePositionsQ(panPositions)
			This.RemoveStringsAtThesePositions(panPositions)
			return This

	# Removes every string equal to any string of the given list, in place, case-sensitive.
	#
	#   pacStrings   the strings to remove
	#   returns      nothing; the list changes
	#   see          RemoveAll
	def RemoveMany(pacStrings)
		if NOT isList(pacStrings)
			return
		ok
		_nLen_ = len(pacStrings)
		for i = 1 to _nLen_
			if isString(pacStrings[i])
				This.RemoveAll(pacStrings[i])
			ok
		next

		def RemoveManyQ(pacStrings)
			This.RemoveMany(pacStrings)
			return This

	# Removes the strings that are empty, in place; a string of spaces is not empty and stays.
	#
	#   returns    nothing; the list changes
	#   see        RemoveSpaces
	#@ aka  An empty string is "", not a string of spaces -- RemoveSpaces() above is the one that judges whitespace.
	def RemoveEmptyStrings()
		for i = len(@acContent) to 1 step -1
			if @acContent[i] = ""
				del(@acContent, i)
			ok
		next

		def RemoveEmptyStringsQ()
			This.RemoveEmptyStrings()
			return This

	# --- REPLACING ----------------------------------------------------

	# Every string equal to pcOld becomes pcNew.
	def ReplaceStringCS(pcOld, pcNew, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_cTarget_ = pcOld
		if NOT _bCase_
			_cTarget_ = StzCaseFold(pcOld)
		ok
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_cItem_ = @acContent[i]
			if NOT _bCase_
				_cItem_ = StzCaseFold(_cItem_)
			ok
			if _cItem_ = _cTarget_
				@acContent[i] = pcNew
			ok
		next

		def ReplaceStringCSQ(pcOld, pcNew, pCaseSensitive)
			This.ReplaceStringCS(pcOld, pcNew, pCaseSensitive)
			return This

	# Turns every string equal to the old one into the new one, in place; only whole strings match.
	#
	#   returns    nothing; the list changes
	#   note       to change a part of each string, use stzString methods on the items
	#   see        ReplaceAt, ReplaceManyOneByOne
	def ReplaceString(pcOld, pcNew)
		This.ReplaceStringCS(pcOld, pcNew, 1)

		def ReplaceStringQ(pcOld, pcNew)
			This.ReplaceString(pcOld, pcNew)
			return This

	# ONE BY ONE, pairwise: the first old becomes the first new, the second
	# the second, and so on. Not "replace all of these with all of those" --
	# the name is the contract, and the call site reads
	# ([ "b","d","f" ], :With = [ "1","2","3" ]).
	#
	# The two lists must be the same length; a mismatch replaces nothing
	# rather than guessing which pairing was meant.
	def ReplaceManyOneByOneCS(pacOld, pacNew, pCaseSensitive)
		if isList(pacNew) and len(pacNew) = 2 and isString(pacNew[1])
			# :With = [ ... ]
			pacNew = pacNew[2]
		ok
		if NOT (isList(pacOld) and isList(pacNew))
			return
		ok
		if len(pacOld) != len(pacNew)
			return
		ok

		_nLen_ = len(pacOld)
		for i = 1 to _nLen_
			This.ReplaceStringCS(pacOld[i], pacNew[i], pCaseSensitive)
		next

		def ReplaceManyOneByOneCSQ(pacOld, pacNew, pCaseSensitive)
			This.ReplaceManyOneByOneCS(pacOld, pacNew, pCaseSensitive)
			return This

	# Replaces the old strings by the new ones pairwise, the first by the first, in place; unequal lengths change nothing.
	#
	#   pacOld     the strings to replace
	#   pacNew     the strings that replace them, one for each old one, or :With = list
	#   returns    nothing; the list changes
	#   see        ReplaceString
	def ReplaceManyOneByOne(pacOld, pacNew)
		This.ReplaceManyOneByOneCS(pacOld, pacNew, 1)

		def ReplaceManyOneByOneQ(pacOld, pacNew)
			This.ReplaceManyOneByOne(pacOld, pacNew)
			return This

	# Takes the string at one position and puts it at another, the others closing up; a bad position changes nothing.
	#
	#   pFrom      the position to take the string from, or :StringAtPosition = n
	#   pTo        the position to put it at, or :ToPosition = n
	#   returns    nothing; the list changes
	#   note       on a b c d, Move(1, 3) gives b c a d
	#   see        Swap
	# --- MOVING -------------------------------------------------------
	#@ aka  Take the string at one position and put it at another, the rest closing up behind it.
	def Move(pFrom, pTo)
		_nFrom_ = This._PositionArg(pFrom)
		_nTo_   = This._PositionArg(pTo)
		_nLen_  = len(@acContent)

		if _nFrom_ < 1 or _nFrom_ > _nLen_ or _nTo_ < 1 or _nTo_ > _nLen_
			return
		ok
		if _nFrom_ = _nTo_
			return
		ok

		_cItem_ = @acContent[_nFrom_]
		del(@acContent, _nFrom_)
		# insert() places AFTER the given index, so landing on position n
		# means inserting after n-1.
		insert(@acContent, _nTo_ - 1, _cItem_)

		def MoveQ(pFrom, pTo)
			This.Move(pFrom, pTo)
			return This

	# Exchanges the strings at two positions, in place, every other string staying where it was; a bad position changes nothing.
	#
	#   pFirst     the first position, or :BetweenString = n
	#   pSecond    the second position, or :AndString = n
	#   returns    nothing; the list changes
	#   see        Move
	#@ aka  Exchange the strings at two positions. Unlike Move(), nothing shifts: the two trade places and every other string stays where it was.
	def Swap(pFirst, pSecond)
		_n1_ = This._PositionArg(pFirst)
		_n2_ = This._PositionArg(pSecond)
		_nLen_ = len(@acContent)

		if _n1_ < 1 or _n1_ > _nLen_ or _n2_ < 1 or _n2_ > _nLen_
			return
		ok
		if _n1_ = _n2_
			return
		ok

		_cTmp_ = @acContent[_n1_]
		@acContent[_n1_] = @acContent[_n2_]
		@acContent[_n2_] = _cTmp_

		def SwapQ(pFirst, pSecond)
			This.Swap(pFirst, pSecond)
			return This

	# Every position holding pcStr -- the same answer as FindCS, under the
	# name the tests reach for. Without it the call fell through to a GLOBAL
	# FindAll of a different arity and died R19, an error that named the
	# parameter count of a function nobody meant to call.
	def FindAllCS(pcStr, pCaseSensitive)
		return This.FindCS(pcStr, pCaseSensitive)

	# Returns the positions of every string equal to the given one, as the plain form does.
	#
	#   pcStr      the string to look for, matched against whole items
	#   returns    a list of numbers; an empty list when none match
	#   see        Find
	def FindAll(pcStr)
		return This.FindCS(pcStr, 1)

	# Returns one verdict per string, ascending, descending or unsorted, for the order of that string's own words.
	#
	#   returns    a list of strings
	#   note       a string of fewer than two words is ascending
	#   see        WordsOfEachStringAreSortedInAscending
	#@ aka  One verdict per string: how ITS OWN words are ordered.
	def WordsSortingOrders()
		_aResult_ = []
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_oOne_ = new stzStringList([ @acContent[i] ])
			if _oOne_.WordsOfEachStringAreSortedInAscending()
				_aResult_ + :Ascending
			but _oOne_.WordsOfEachStringAreSortedInDescending()
				_aResult_ + :Descending
			else
				_aResult_ + :Unsorted
			ok
		next
		return _aResult_

		def WordsSortingOrdersQ()
			return new stzList( This.WordsSortingOrders() )

	# Returns how many strings have their own words in ascending order, a one-word string included.
	#
	#   returns    a number
	#   see        WordsSortingOrders
	#@ aka  How many strings fall in each verdict. Counted from the one list above so the three can never disagree with it, or with each other -- they sum to NumberOfStrings() by construction.
	def NumberOfStringsWhereWordsAreSortedInAscending()
		return This._CountWordsOrder(:Ascending)

	# Returns how many strings have their own words in descending order; a one-word string counts as ascending instead.
	#
	#   returns    a number
	#   see        WordsSortingOrders
	def NumberOfStringsWhereWordsAreSortedInDescending()
		return This._CountWordsOrder(:Descending)

	# Returns how many strings have their own words in neither ascending nor descending order.
	#
	#   returns    a number
	#   see        WordsSortingOrders
	def NumberOfStringsWhereWordsAreUnsorted()
		return This._CountWordsOrder(:Unsorted)

	def _CountWordsOrder(pcOrder)
		_a_ = This.WordsSortingOrders()
		_n_ = 0
		_nLen_ = len(_a_)
		for i = 1 to _nLen_
			if _a_[i] = pcOrder
				_n_++
			ok
		next
		return _n_

	# A position given bare, or as the value half of a named pair.
	def _PositionArg(p)
		if isNumber(p)
			return p
		ok
		if isList(p) and len(p) = 2 and isNumber(p[2])
			return p[2]
		ok
		return 0

	# TRUE if every string is uppercase; an empty list answers FALSE.
	#
	#   returns    TRUE or FALSE
	#   see        IsLowercase
	# --- PREDICATES ---------------------------------------------------
	#@ aka  TRUE when EVERY string is uppercase. An empty list answers FALSE: there is no string in it that is uppercase, and answering TRUE for "all of nothing" reads as a claim about content that is not there.
	def IsUppercase()
		_nLen_ = len(@acContent)
		if _nLen_ = 0
			return 0
		ok
		for i = 1 to _nLen_
			if @acContent[i] != StzUpper(@acContent[i])
				return 0
			ok
		next
		return 1


	# TRUE if every string is lowercase, a string with no letters counting as lowercase; an empty list answers FALSE.
	#
	#   returns    TRUE or FALSE
	#   see        IsUppercase
	def IsLowercase()
		_nLen_ = len(@acContent)
		if _nLen_ = 0
			return 0
		ok
		for i = 1 to _nLen_
			if @acContent[i] != StzLower(@acContent[i])
				return 0
			ok
		next
		return 1


	# TRUE when the substring is in EVERY string -- not merely in one of
	# them, which is what ContainsSubString() above answers.
	def ContainsSubstringInEachStringCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nLen_ = len(@acContent)
		if _nLen_ = 0
			return 0
		ok
		for i = 1 to _nLen_
			if len( StzFindCS(pcSubStr, @acContent[i], _bCase_) ) = 0
				return 0
			ok
		next
		return 1

		# TRUE if the text occurs inside every string of the list, case-sensitive; an empty list answers FALSE.
		#
		#   returns    TRUE or FALSE
		#   see        ContainsSubString
		def ContainsSubstringInEachString(pcSubStr)
			return This.ContainsSubstringInEachStringCS(pcSubStr, 1)

	# TRUE if the words inside each string are in ascending order, read per string; an empty list answers FALSE.
	#
	#   returns    TRUE or FALSE
	#   note       a one-word string is in order both ways
	#   see        WordsSortingOrders, SortInAscending
	#@ aka  TRUE when the WORDS INSIDE each string are in order -- read per string, not across the list. "ali ben salah" is ascending on its own; whether the next string sorts after it is a different question, which IsSortedInAscending() answers.
	def WordsOfEachStringAreSortedInAscending()
		return This._WordsOfEachStringAreSorted(1)

		def WordsOfEachStringSortedInAscending()
			return This.WordsOfEachStringAreSortedInAscending()

	# TRUE if the words inside each string are in descending order, read per string; an empty list answers FALSE.
	#
	#   returns    TRUE or FALSE
	#   note       a one-word string is in order both ways
	#   see        WordsSortingOrders, SortInDescending
	def WordsOfEachStringAreSortedInDescending()
		return This._WordsOfEachStringAreSorted(0)

		def WordsOfEachStringSortedInDescending()
			return This.WordsOfEachStringAreSortedInDescending()

	def _WordsOfEachStringAreSorted(pbAscending)
		_nLen_ = len(@acContent)
		if _nLen_ = 0
			return 0
		ok

		for i = 1 to _nLen_
			_acWords_ = StzSplit(ring_trim(@acContent[i]), " ")
			_acW_ = []
			_nW_ = len(_acWords_)
			for j = 1 to _nW_
				if _acWords_[j] != ""
					_acW_ + _acWords_[j]
				ok
			next

			# Sorted by the SAME engine sort the class sorts with, then
			# compared -- rather than comparing pairs with < and >, which
			# Ring coerces to numbers (R41) and which would answer nonsense
			# for words.
			_nn_ = len(_acW_)
			if _nn_ < 2
				loop
			ok

			_oW_ = new stzStringList(_acW_)
			if pbAscending
				_oW_.SortInAscending()
			else
				_oW_.SortInDescending()
			ok
			_acSorted_ = _oW_.Content()

			for j = 1 to _nn_
				if _acSorted_[j] != _acW_[j]
					return 0
				ok
			next
		next
		return 1

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
		_pH_ = StzEngineString(_cJoined_)
		_pR_ = StzEngineStringSortNullItemsCS(_pH_, _bCase_)
		_cSorted_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(_pH_)

		@acContent = _SplitNullDelimited(_cSorted_)

		def SortInAscendingCSQ(pCaseSensitive)
			This.SortInAscendingCS(pCaseSensitive)
			return This

	# Sorts the strings in ascending order, in place, case-sensitive: capitals come before lowercase letters.
	#
	#   returns    nothing; the list changes
	#   see        SortedInAscending, SortInDescending
	def SortInAscending()
		This.SortInAscendingCS(1)

		def SortInAscendingQ()
			This.SortInAscending()
			return This

		# Sorts the strings in ascending order, in place, as the plain form does.
		#
		#   returns    nothing; the list changes
		#   see        SortInAscending
		def SortUp()
			This.SortInAscending()

	# An ascending-sorted copy; the original is unchanged.
	def SortedInAscendingCS(pCaseSensitive)
		_oCopy_ = This.Copy()
		_oCopy_.SortInAscendingCS(pCaseSensitive)
		return _oCopy_.Content()

	# Returns the strings in ascending order as a plain list, case-sensitive; the list itself is unchanged.
	#
	#   returns    a list of strings
	#   see        SortInAscending
	def SortedInAscending()
		return This.SortedInAscendingCS(1)

		# Returns the strings in ascending order as a plain list, case-sensitive; the list itself is unchanged.
		#
		#   returns    a list of strings
		#   see        SortedInAscending
		#@ aka  Sorted() shorthand -- default ascending case-sensitive sort, used by narrative one-liners like `o.Sorted()` that don't distinguish direction.
		def Sorted()
			return This.SortedInAscendingCS(1)

		def SortedUp()
			return This.SortedInAscending()

	# Returns the strings with every space char removed from each, as a plain list; the list is unchanged.
	#
	#   returns    a list of strings
	#   note       only the space char goes; a tab stays
	#   see        RemoveSpaces, SpacesRemoved
	#@ aka  WithoutSpaces / WithoutSapces (Softanza intentionally accepts the misspelled form): return the content with every space removed from each string item.
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

	# Sorts the strings in descending order, in place, case-sensitive: lowercase letters come before capitals.
	#
	#   returns    nothing; the list changes
	#   see        SortedInDescending, SortInAscending
	#@ aka  Sort the strings in descending order in place (mutating).
	def SortInDescending()
		This.SortInAscending()
		This.Reverse()

		def SortInDescendingQ()
			This.SortInDescending()
			return This

		# Sorts the strings in descending order, in place, as the plain form does.
		#
		#   returns    nothing; the list changes
		#   see        SortInDescending
		def SortDown()
			This.SortInDescending()

	# Returns the strings in descending order as a plain list, case-sensitive; the list itself is unchanged.
	#
	#   returns    a list of strings
	#   see        SortInDescending
	#@ aka  A descending-sorted copy; the original is unchanged.
	def SortedInDescending()
		_oCopy_ = This.Copy()
		_oCopy_.SortInDescending()
		return _oCopy_.Content()

	  #------------------------------------------------------#
	 #   SORT BY EXPRESSION                                 #
	#------------------------------------------------------#

	# Sorts the strings in place by a numeric key computed from each one, such as its length; a text key raises.
	#
	#   pcExpr     a Ring expression that gives a number, with @string standing for the current
	#              string
	#   returns    nothing; the list changes
	#   note       the sort is stable
	#   warning    known defect: @item is not defined here and raises R24, and a key that is text
	#              raises R41 because keys are compared with a greater-than, so only numeric keys
	#              such as len(@string) work
	#   see        SortInAscending
	#@ aka  SortBy(cExpr): sort by an eval'd expression where @string aliases the per-item string. Pre-compute keys once, then insertion-sort over (key, value) pairs.
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

	# Reverses the order of the strings, in place.
	#
	#   returns    nothing; the list changes
	#   see        Reversed
	#@ aka  Reverse the order of the strings in place (mutating).
	def Reverse()
		# Use ring_reverse -- bare `reverse(...)` resolves
		# case-insensitively to this class's own Reverse() (0 params)
		# and raises R20. Same shadow family as Insert/Add/Abs/Swap.
		@acContent = ring_reverse(@acContent)

		def ReverseQ()
			This.Reverse()
			return This

	# Returns the strings in reverse order as a plain list; the list itself is unchanged.
	#
	#   returns    a list of strings
	#   see        Reverse
	#@ aka  The strings in reverse order, as a Ring list; the original is unchanged.
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
		_pH_ = StzEngineString(_cJoined_)
		_pR_ = StzEngineStringUniqueNullItemsCS(_pH_, _bCase_)
		_cUnique_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(_pH_)

		@acContent = _SplitNullDelimited(_cUnique_)

		def UniqueCSQ(pCaseSensitive)
			This.UniqueCS(pCaseSensitive)
			return This

	# Removes repeated strings, in place, keeping the first of each in its place; case-sensitive.
	#
	#   returns    nothing; the list changes
	#   see        UniqueItems, RemoveDuplicates
	def Unique()
		This.UniqueCS(1)

		def UniqueQ()
			This.Unique()
			return This

		# Removes repeated strings, in place, keeping the first of each in its place; case-sensitive.
		#
		#   returns    nothing; the list changes
		#   see        Unique
		def RemoveDuplicates()
			This.Unique()

	# Returns the strings without repeats as a plain list, the first of each kept in place; the list is unchanged.
	#
	#   returns    a list of strings
	#   see        Unique
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
			_pH_ = StzEngineString(@acContent[i])
			_nFound_ = StzEngineStringContainsCS(_pH_, pcSubStr, _bCase_)
			StzEngineStringFree(_pH_)
			if _nFound_
				_acResult_ + @acContent[i]
			ok
		next
		return _acResult_

	# Returns the strings that contain the text, case-sensitive, as a plain list; the list is unchanged.
	#
	#   returns    a list of strings
	#   see        FilterCS, ThatContain
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

	# Returns the strings that begin with the prefix, case-sensitive, as a plain list; the list is unchanged.
	#
	#   pcPrefix   the text the strings must begin with
	#   returns    a list of strings
	#   see        FilterByEndsWith
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

	# Returns the strings that end with the suffix, case-sensitive, as a plain list; the list is unchanged.
	#
	#   returns    a list of strings
	#   see        FilterByStartsWith
	def FilterByEndsWith(pcSuffix)
		return This.FilterByEndsWithCS(pcSuffix, 1)

	  #======================================================#
	 #   CASE OPERATIONS (engine-backed)                    #
	#======================================================#

	# Turns every string to uppercase, in place.
	#
	#   returns    nothing; the list changes
	#   see        Uppercased, ToLower
	#@ aka  Uppercase every string in place (mutating).
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

	# Returns the strings in uppercase as a plain list; the list itself is unchanged.
	#
	#   returns    a list of strings
	#   see        ToUpper
	#@ aka  A copy with every string uppercased; the original is unchanged.
	def Uppercased()
		_oCopy_ = This.Copy()
		_oCopy_.ToUpper()
		return _oCopy_.Content()

	# Turns every string to lowercase, in place.
	#
	#   returns    nothing; the list changes
	#   see        Lowercased, ToUpper
	#@ aka  Lowercase every string in place (mutating).
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

	# Returns the strings in lowercase as a plain list; the list itself is unchanged.
	#
	#   returns    a list of strings
	#   see        ToLower
	#@ aka  A copy with every string lowercased; the original is unchanged.
	def Lowercased()
		_oCopy_ = This.Copy()
		_oCopy_.ToLower()
		return _oCopy_.Content()

	  #======================================================#
	 #   SIMILARITY (engine-backed Jaro / JaroWinkler)      #
	#======================================================#

	# Returns the string closest to the target by the engine's Jaro-Winkler score, the first on a tie; an empty list answers an empty string.
	#
	#   pcTarget   the text to compare each string with
	#   returns    a string
	#   see        SimilarTo
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

	# Returns the strings whose Jaro-Winkler score against the target is at least the threshold, on the engine's 0 to 1000 scale.
	#
	#   pcTarget     the text to compare each string with
	#   nThreshold   the lowest score kept, from 0 to 1000
	#   returns      a list of strings
	#   note         a threshold of 800 keeps banana for the target banan; a fraction such as 0.8
	#                keeps most strings
	#   see          MostSimilarTo
	def SimilarTo(pcTarget, nThreshold)
		return This.SimilarToCS(pcTarget, nThreshold, 1)

	  #======================================================#
	 #   CONVERSION                                         #
	#======================================================#

	# Returns the strings joined with newlines as one string.
	#
	#   returns    a string
	#   see        Concat, ConcatUsing
	#@ aka  The strings joined with newlines, as one string.
	def ToString()
		return This.ConcatUsing(char(10))

	# Returns each string wrapped in a stzString object, as a list of objects.
	#
	#   returns    a list of stzString objects
	#   see        ToStzList
	#@ aka  Each string wrapped as a stzString object, as a list.
	def ToListOfStzStrings()
		_aResult_ = []
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_aResult_ + new stzString(@acContent[i])
		next
		return _aResult_

	# Returns the strings as a stzList object.
	#
	#   returns    a stzList object
	#   see        Content, ToListOfStzStrings
	#@ aka  The strings as a stzList object.
	def ToStzList()
		return new stzList(@acContent)

	  #======================================================#
	 #   SPLIT EACH STRING                                  #
	#======================================================#

	# Splits each string on the separator and returns the parts of each, a list of lists; the list is unchanged.
	#
	#   _cSep_     the separator text, or :Using = text
	#   returns    a list of lists of strings
	#   note       the separator itself is dropped
	#   see        stzString
	#@ aka  Split each string on the given separator.
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

	# Trims the leading and trailing spaces of every string, in place.
	#
	#   returns    nothing; the list changes
	#   see        Trimmed
	#@ aka  Trim the spaces around each string in place (mutating).
	def Trim()
		_nLen_ = len(@acContent)
		for i = 1 to _nLen_
			_oStr_ = new stzString(@acContent[i])
			@acContent[i] = _oStr_.Trimmed()
		next

		def TrimQ()
			This.Trim()
			return This

	# Returns the strings trimmed of leading and trailing spaces, as a plain list; the list is unchanged.
	#
	#   returns    a list of strings
	#   see        Trim
	#@ aka  A copy with each string trimmed; the original is unchanged.
	def Trimmed()
		_oCopy_ = This.Copy()
		_oCopy_.Trim()
		return _oCopy_.Content()

	  #======================================================#
	 #   REGEX MATCHING                                     #
	#======================================================#

	# TRUE if every string matches the pattern as a whole, so "a." matches ab and "a" does not; an empty list is TRUE.
	#
	#   pcRegexPatt   the regular expression, matched against each whole string
	#   returns       TRUE or FALSE
	#   warning       known defect: the old comment says it returns the strings that match, but it
	#                 answers one verdict for the whole list
	#   see           StringsW
	#@ aka  The strings matching the given regex pattern.
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

	# Answers TRUE every time: the object is a stzStringList.
	#
	#   returns    TRUE
	#   see        stzType
	#@ aka  Always TRUE: the object IS a stzStringList.
	def IsStzStringList()
		return 1

	# Returns the type name of the object as a lowercase string, stzstringlist.
	#
	#   returns    a string
	#   see        IsStzStringList
	#@ aka  The Softanza type symbol: :stzStringList.
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

	# Returns all the strings joined end to end, with nothing between them, as one string.
	#
	#   returns    a string
	#   see        Concat
	#@ aka  All the strings concatenated, no separator.
	def Concatenate()
		return This.ConcatenateXT("")

	# Returns the strings with their spaces removed as a plain list; the list is unchanged.
	#
	#   returns    a list of strings
	#   see        RemoveSpaces, WithoutSpaces
	#@ aka  The strings with their spaces removed, as data.
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

	# Removes the spaces inside every string, in place.
	#
	#   returns    nothing; the list changes
	#   see        SpacesRemoved
	#@ aka  Remove the spaces inside each string (mutating).
	def RemoveSpaces()
		@acContent = This.SpacesRemoved()

		def RemoveSpacesQ()
			This.RemoveSpaces()
			return This

	# Returns the strings that contain another, different string of the list, one entry per such string.
	#
	#   returns    a list of strings
	#   note       in sea, seashell, shell, ocean, only seashell contains another item
	#   see        SubStrinks
	#@ aka  Substrongs/Substrinks (deliberate Softanza wordplay): the strings that CONTAIN another item of the list, and the ones that are CONTAINED IN another item (case-sensitive, engine-backed find).
	def SubStrongs()
		_aSbg_ = @acContent
		_nSbg_ = ring_len(_aSbg_)
		_aSbgRes_ = []
		for _iSbg_ = 1 to _nSbg_
			for _jSbg_ = 1 to _nSbg_
				if _iSbg_ != _jSbg_ and _aSbg_[_iSbg_] != _aSbg_[_jSbg_] and
				   StzFindFirst(_aSbg_[_jSbg_], _aSbg_[_iSbg_]) > 0
					# i is a SubStrong when it CONTAINS j -- j is the
					# NEEDLE, i the haystack. Transposed with SubStrinks
					# below, so each returned the other's answer.
					_aSbgRes_ + _aSbg_[_iSbg_]
					exit
				ok
			next
		next
		return _aSbgRes_

	# Returns the strings that sit inside another, different string of the list, repeats included.
	#
	#   returns    a list of strings
	#   note       in sea, seashell, shell, ocean, sea the answer is sea, shell, sea
	#   see        SubStrongs
	#@ aka  The items CONTAINED IN another item of the list -- the mirror of SubStrongs, not an alias of it (the old comment said "the substrings of each string", which describes neither).
	def SubStrinks()
		_aSbk_ = @acContent
		_nSbk_ = ring_len(_aSbk_)
		_aSbkRes_ = []
		for _iSbk_ = 1 to _nSbk_
			for _jSbk_ = 1 to _nSbk_
				if _iSbk_ != _jSbk_ and _aSbk_[_iSbk_] != _aSbk_[_jSbk_] and
				   StzFindFirst(_aSbk_[_iSbk_], _aSbk_[_jSbk_]) > 0
					# i is a SubStrink when it is CONTAINED IN j: i is
					# the needle, j the haystack.
					_aSbkRes_ + _aSbk_[_iSbk_]
					exit
				ok
			next
		next
		return _aSbkRes_

	# Returns the strings for which the condition is true; an error inside the condition counts as false.
	#
	#   pcExpr     a Ring condition, with @string or @item for the current string and @i for its
	#              position
	#   returns    a list of strings
	#   note       StringsW("len(@string) = 2") keeps the two-char strings
	#   see        Yield, Filter
	#@ aka  The strings satisfying the given W expression.
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
			_b_ = 0
			try
				eval("_b_ = " + pcExpr)
			catch
				_b_ = 0
			done
			if _b_ _aR_ + _v_ ok
		next
		return _aR_

	# Returns the condition's verdict for every string, 1 or 0, so it lines up with the list position by position.
	#
	#   pcExpr     a Ring condition, with @string or @item for the current string and @i for its
	#              position
	#   returns    a list of 1 and 0
	#   see        StringsW
	#@ aka  The condition's verdict for EVERY string, in order -- 1 or 0 each.
	def Yield(pcExpr)
		_l_ = @acContent
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if NOT isString(_v_)
				_aR_ + 0
				loop
			ok
			@string = _v_
			@item = _v_
			@i = _i_
			_b_ = 0
			try
				eval("_b_ = " + pcExpr)
			catch
				_b_ = 0
			done
			if _b_
				_aR_ + 1
			else
				_aR_ + 0
			ok
		next
		return _aR_

		def YieldQ(pcExpr)
			return new stzList( This.Yield(pcExpr) )

	#-- Joined / JoinedUsing: readable aliases of Concatenated /
	#-- ConcatenatedUsing (used by ..Q() chain idioms on lists).

	def Joined()
		return This.Concatenated()

	def JoinedUsing(pcSep)
		return This.ConcatenatedUsing(pcSep)

	  #==================================================#
	 #  STRING-LIST SELECTION (lexical)                 #
	#==================================================#
	# Returns the strings that contain the text, case-sensitive, as a plain list; a non-string argument answers an empty list.
	#
	#   returns    a list of strings
	#   see        Filter
	#@ aka  Lexical (non-semantic) selection over a list of fragments -- substring membership and word-length ranking -- so chains like Q(text).WordsQ().ThatContain("ing").Longest() read naturally. These are STRING ops (any list of strings has them). MEANING-based selection (MostSimilarByMeaning, ThatAre by sentiment) lives on stzListOfTexts, the list-of-texts domain -- because that is natural processing, not
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

	# Returns the string with the most words, the first on a tie; an empty list answers an empty string.
	#
	#   returns    a string
	#   note       it counts words, not chars
	#   see        Shortest
	#@ aka  The string with the MOST words.
	def Longest()
		return This._ByWordCount(1)

	# Returns the string with the fewest words, the first on a tie; an empty list answers an empty string.
	#
	#   returns    a string
	#   note       it counts words, not chars
	#   see        Longest
	#@ aka  The string with the FEWEST words.
	def Shortest()
		return This._ByWordCount(0)
