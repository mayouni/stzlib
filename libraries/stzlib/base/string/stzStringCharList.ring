#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCHARLIST           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Manages a list of single-char strings.      #
#                  For bulk operations, joins chars into a      #
#                  temp stzString and delegates to the Zig      #
#                  engine.                                      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringCharListQ(p)
	return new stzStringCharList(p)

func StzAreChars(pacChars)
	if CheckingParams()
		if NOT isList(pacChars)
			StzRaise("Incorrect param type! pacChars must be a list.")
		ok
	ok

	_nLen_ = len(pacChars)
	for i = 1 to _nLen_
		if NOT ( isString(pacChars[i]) and @IsChar(pacChars[i]) )
			return 0
		ok
	next
	return 1

	func AreChars(pacChars)
		return StzAreChars(pacChars)

	func @AreChars(pacChars)
		return StzAreChars(pacChars)

func StzAreBothChars(p1, p2)
	return StzAreChars([ p1, p2 ])

	func AreBothChars(p1, p2)
		return StzAreBothChars(p1, p2)

	func BothAreChars(p1, p2)
		return StzAreBothChars(p1, p2)

	func @AreBothChars(p1, p2)
		return StzAreBothChars(p1, p2)

	func @BothAreChars(p1, p2)
		return StzAreBothChars(p1, p2)

func StzAreLetters(pacLetters)
	if CheckingParams()
		if NOT isList(pacLetters)
			StzRaise("Incorrect param type! pacLetters must be a list.")
		ok
	ok

	_nLen_ = len(pacLetters)
	for i = 1 to _nLen_
		if NOT ( isString(pacLetters[i]) and @IsLetter(pacLetters[i]) )
			return 0
		ok
	next
	return 1

	func AreLetters(pacLetters)
		return StzAreLetters(pacLetters)

	func @AreLetters(pacLetters)
		return StzAreLetters(pacLetters)

func StzAreBothLetters(p1, p2)
	return StzAreLetters([ p1, p2 ])

	func AreBothLetters(p1, p2)
		return StzAreBothLetters(p1, p2)

	func BothAreLetters(p1, p2)
		return StzAreBothLetters(p1, p2)

	func @AreBothLetters(p1, p2)
		return StzAreBothLetters(p1, p2)

	func @BothAreLetters(p1, p2)
		return StzAreBothLetters(p1, p2)

func StzCharsBetween(c1, _c2_)
	if CheckingParams()
		if isList(_c2_) and len(_c2_) = 2 and isString(_c2_[1]) and _c2_[1] = "and"
			_c2_ = _c2_[2]
		ok

		if NOT @BothAreChars(c1, _c2_)
			StzRaise("Incorrect param type!")
		ok
	ok

	_nUnicode1_ = Unicode(c1)
	_nUnicode2_ = Unicode(_c2_)

	_nStep_ = 1
	if _nUnicode1_ > _nUnicode2_
		_nStep_ = -1
	ok

	_acResult_ = []
	for i = _nUnicode1_ to _nUnicode2_ step _nStep_
		_acResult_ + StzCharQ(i).Content()
	next

	return _acResult_

	func CharsBetween(c1, _c2_)
		return StzCharsBetween(c1, _c2_)

func StzNumberOfCharsBetween(c1, _c2_)
	if CheckingParams()
		if NOT @BothAreChars(c1, _c2_)
			StzRaise("Incorrect param type!")
		ok
	ok

	_nUnicode1_ = Unicode(c1)
	_nUnicode2_ = Unicode(_c2_)

	return Abs(_nUnicode2_ - _nUnicode1_) + 1

	func NumberOfCharsBetween(c1, _c2_)
		return StzNumberOfCharsBetween(c1, _c2_)

func StzCharsToUnicodes(paList)
	return StzStringCharListQ(paList).Unicodes()

	func CharsToUnicodes(paList)
		return StzCharsToUnicodes(paList)


func CharsNames(acChars)
	_anUnicodes_ = Unicodes(acChars)
	_nLen_ = len(_anUnicodes_)
	_acResult_ = []

	for i = 1 to _nLen_
		_acResult_ + CharName(_anUnicodes_[i])
	next

	return _acResult_

	func @CharsNames(acChars)
		return CharsNames(acChars)

	func StzCharsNames(acChars)
		return CharsNames(acChars)

	func @StzCharsNames(acChars)
		return CharsNames(acChars)

func StzListOfChars(paList)
	if @IsListOfChars(paList)
		return paList
	ok

	func ListOfChars(paList)
		return StzListOfChars(paList)

func StzListOfCharsQ(paList)
	return new stzStringCharList(paList)

	func ListOfCharsQ(paList)
		return StzListOfCharsQ(paList)

func StzListOfLetters(paList)
	if @IsListOfLetters(paList)
		return StzStringCharListQ(paList).Uppercased()
	ok

	func ListOfLetters(paList)
		return StzListOfLetters(paList)

	func UnicodesNames(anUnicodes)
		_nLen_ = len(anUnicodes)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			_aResult_ + StzCharNameByUnicode(anUnicodes[_i_])
		next
		return _aResult_


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListOfChars from stzStringCharList

# Holds a text as a list of single characters, so that each character can be sorted, reversed, looked up or named on its own.
#
# Build it with a text, with a list of single characters or with a list of Unicode code points; the
# class stzListOfChars is the same class under another name, and StzStringCharListQ(p) builds one in
# a chain. A Hebrew letter, an Arabic letter, an accented letter and an emoji are one item each,
# because the text is split into characters and not into bytes. Verbs such as Reverse and ToUpper
# change the list in place and return nothing, and the forms that end in -ed (Reversed, Uppercased)
# return a new list and leave the object alone. Unique and the sort methods return their result as
# ONE joined text inside a one-item list today, not as a list of single characters;
# RemoveDuplicatesQ and Reversed are the ones to use for a proper list.
#
#   receiver   o1 = new stzStringCharList("hello")
#   example    ? o1.Join()
#              #--> hello
#              ? @@( o1.Find("l") )
#              #--> [ 3, 4 ]
#              o2 = new stzStringCharList("שלום")
#              ? @@( o2.Reversed() )
#              #--> [ "ם", "ו", "ל", "ש" ]
#              o3 = new stzStringCharList("a😀b")
#              ? @@( o3.Unicodes() )
#              #--> [ 97, 128512, 98 ]
#   see        stzString, stzList, stzListOfNumbers
class stzStringCharList from stzObject

	@acChars = []

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds the list from a text, from a list of single characters, or from a list of Unicode code points.
	#
	#   pValue     a text (split into its characters), a list of single characters (kept as given),
	#              or a list of code point numbers (each turned into its character)
	#   returns    nothing; the object is built
	#   note       stzListOfChars is the same class under another name
	#   see        Content, Unicodes
	def init(pValue)

		if isString(pValue)
			# Auto-split a string into its chars via the engine
			pHandle = StzEngineString(pValue)
			pSplit = StzEngineStringCharsSplit(pHandle)
			_cJoined_ = StzEngineStringData(pSplit)
			StzEngineStringFree(pSplit)
			StzEngineStringFree(pHandle)

			@acChars = _SplitNullDelimited(_cJoined_)

		but isList(pValue) and @IsListOfNumbers(pValue)
			# List of unicode codepoints
			_nLen_ = len(pValue)
			for i = 1 to _nLen_
				@acChars + StzCharQ(pValue[i]).Content()
			next

		but isList(pValue) and @IsListOfChars(pValue)
			@acChars = pValue

		else
			StzRaise("Can't create stzStringCharList! pValue must be a string, a list of chars, or a list of unicode numbers.")
		ok

	  #===============================#
	 #   CONTENT ACCESS              #
	#===============================#

	# Returns the list of single characters held by the object.
	#
	#   returns    a list of text, one character per item
	#   note       ToList and Chars return the same list
	#   see        Join, Unicodes
	def Content()
		return @acChars

		# Returns the held characters as a plain list, one single-character text per item.
		#
		#   returns    a list of text
		#   note       same answer as Content, under a name that says the type
		#   see        Content, Join
		def ToList()
			return @acChars

		# Returns the held characters as a plain list, one single-character text per item.
		#
		#   returns    a list of text
		#   note       same answer as Content, under the name used when a text is split into
		#              characters
		#   see        Content, Join
		def Chars()
			return @acChars

	# Returns the official Unicode name of each character, in order.
	#
	#   returns    a list of text, one name per character
	#   note       the space is named SPACE and the emoji 😀 is GRINNING FACE
	#   see        Unicodes, NthCharUnicode
	def Names()
		_acResult_ = []
		_anUnicodes_ = This.Unicodes()
		_nLen_ = len(_anUnicodes_)

		for i = 1 to _nLen_
			_acResult_ + StzCharNameByUnicode(_anUnicodes_[i])
		next

		return _acResult_

	# RemoveSpaces / RemoveSpacesQ: drop every " " char from the list.
	def RemoveSpaces()
		_aOut_ = []
		_nLen_ = len(@acChars)
		for _i_ = 1 to _nLen_
			if @acChars[_i_] != " "
				_aOut_ + @acChars[_i_]
			ok
		next
		@acChars = _aOut_

		def RemoveSpacesQ()
			_StzHistoOpen(This.Content())
			This.RemoveSpaces()
			_StzHistoAdd(This.Content())
			return This

	# Changes every character to its capital form, in place, leaving the other characters as they are.
	#
	#   returns    nothing; the list changes. UppercaseQ returns the object for chaining
	#   note       works on accented letters too: é becomes É; Hebrew has no capitals and stays as
	#              it is
	#   see        Lowercase, ToUpper, Uppercased
	#@ aka  Uppercase / UppercaseQ / Lowercase / LowercaseQ: case-map.
	def Uppercase()
		_nLen_ = len(@acChars)
		for _i_ = 1 to _nLen_
			if isString(@acChars[_i_])
				# StzUpper is codepoint-aware; upper() is byte-oriented and
				# left multibyte chars (accented letters) unchanged.
				@acChars[_i_] = StzUpper(@acChars[_i_])
			ok
		next

		def UppercaseQ()
			_StzHistoOpen(This.Content())
			This.Uppercase()
			_StzHistoAdd(This.Content())
			return This

	# Changes every character to its small form, in place, leaving the other characters as they are.
	#
	#   returns    nothing; the list changes. LowercaseQ returns the object for chaining
	#   see        Uppercase, ToLower, Lowercased
	def Lowercase()
		_nLen_ = len(@acChars)
		for _i_ = 1 to _nLen_
			if isString(@acChars[_i_])
				# StzLower is codepoint-aware (see Uppercase).
				@acChars[_i_] = StzLower(@acChars[_i_])
			ok
		next

		def LowercaseQ()
			This.Lowercase()
			return This

	# Returns the characters glued together into one text, leaving the list unchanged.
	#
	#   returns    a text; JoinQ returns it as a stzString
	#   see        Concatenated, Content
	#@ aka  JoinQ / Join: concatenate the chars into a single string, wrapped in stzString for the Q form.
	def Join()
		_cOut_ = ""
		_nLen_ = len(@acChars)
		for _i_ = 1 to _nLen_
			_cOut_ += @acChars[_i_]
		next
		return _cOut_

		def JoinQ()
			_cJq_ = This.Join()
			_StzHistoAdd(_cJq_)
			return new stzString( _cJq_ )

	# Returns how many characters the list holds.
	#
	#   returns    a number
	#   note       an emoji counts as one character
	#   see        Count, Unicodes
	def NumberOfChars()
		return len(@acChars)

		# Returns how many characters the list holds.
		#
		#   returns    a number
		#   note       same answer as NumberOfChars
		#   see        NumberOfChars, Size
		def Count()
			return len(@acChars)

		# Returns how many characters the list holds.
		#
		#   returns    a number
		#   note       same answer as NumberOfChars
		#   see        NumberOfChars, Length
		def Size()
			return len(@acChars)

		# Returns how many characters the list holds.
		#
		#   returns    a number
		#   note       same answer as NumberOfChars
		#   see        NumberOfChars, Size
		def Length()
			return len(@acChars)

	# Returns the characters between two positions, both included, as a list.
	#
	#   p1         the start: a position, or a pair such as [ :From, "e" ] naming the first
	#              occurrence of a character
	#   p2         the end: a position, or a pair such as [ :To, "l" ] naming the first occurrence
	#              of a character
	#   returns    a list of text; an empty list when the start is after the end
	#   note       a position below 1 is moved to 1 and a position past the end is moved to the last
	#              one; a character that is not found gives an empty list as end
	#   see        NthChar, Find
	#@ aka  Section(:From = pcA, :To = pcB) -- return the slice of chars between the first occurrence of pcA and the first occurrence of pcB (both inclusive). Also accepts numeric positions Section(n1, n2). Returns a plain list of chars.
	def Section(p1, p2)
		_nLen_ = len(@acChars)
		_n1_ = p1; _n2_ = p2
		if isList(p1) and len(p1) = 2 and isString(p1[1]) and
		   lower(p1[1]) = "from"
			_vF_ = p1[2]
			if isString(_vF_)
				_n1_ = 0
				for _i_ = 1 to _nLen_
					if @acChars[_i_] = _vF_ _n1_ = _i_ exit ok
				next
			else
				_n1_ = _vF_
			ok
		ok
		if isList(p2) and len(p2) = 2 and isString(p2[1]) and
		   lower(p2[1]) = "to"
			_vT_ = p2[2]
			if isString(_vT_)
				_n2_ = 0
				for _i_ = 1 to _nLen_
					if @acChars[_i_] = _vT_ _n2_ = _i_ exit ok
				next
			else
				_n2_ = _vT_
			ok
		ok
		if NOT (isNumber(_n1_) and isNumber(_n2_)) return [] ok
		if _n1_ < 1 _n1_ = 1 ok
		if _n2_ > _nLen_ _n2_ = _nLen_ ok
		if _n1_ > _n2_ return [] ok
		_aRes_ = []
		for _i_ = _n1_ to _n2_
			_aRes_ + @acChars[_i_]
		next
		return _aRes_

	# Returns the character at the given position, counted from 1.
	#
	#   n          the position of the character, counted from 1
	#   returns    a text of one character
	#   see        Section, NthCharUnicode
	def NthChar(n)
		if n < 1 or n > len(@acChars)
			StzRaise("Index out of range!")
		ok
		return @acChars[n]

	# Returns a new, independent list holding the same characters.
	#
	#   returns    a stzStringCharList
	#   note       changing the copy does not change the original
	#   see        Content, ToStzListOfStrings
	def Copy()
		return new stzStringCharList(@acChars)

	# Returns the characters glued together into one text, leaving the list unchanged.
	#
	#   returns    a text
	#   note       same answer as Join
	#   see        Join, Content
	def Concatenated()
		_cResult_ = ""
		_nLen_ = len(@acChars)
		for i = 1 to _nLen_
			_cResult_ += @acChars[i]
		next
		return _cResult_

	  #===============================#
	 #   CONTAINS / FIND             #
	#===============================#

	# TRUE if the given character is in the list.
	#
	#   cChar      the character to look for
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       case counts: l is not L
	#   see        Find, NumberOfUniqueChars
	def Contains(cChar)
		_nLen_ = len(@acChars)
		for i = 1 to _nLen_
			if @acChars[i] = cChar
				return 1
			ok
		next
		return 0

	# Returns the positions at which the given character occurs, in order.
	#
	#   cChar      the character to look for
	#   returns    a list of numbers; an empty list when the character is absent
	#   see        Contains, Section
	def Find(cChar)
		_anResult_ = []
		_nLen_ = len(@acChars)
		for i = 1 to _nLen_
			if @acChars[i] = cChar
				_anResult_ + i
			ok
		next
		return _anResult_

	  #===============================#
	 #   UNIQUE CHARS (ENGINE)       #
	#===============================#

	# Returns the distinct characters, each kept at its first occurrence, but joined in one text inside a one-item list.
	#
	#   returns    a list holding one text
	#   note       NumberOfUniqueChars counts correctly; RemoveDuplicatesQ returns a proper list of
	#              single characters
	#   warning    the answer is not split into single characters: hello gives [ "helo" ], not [
	#              "h", "e", "l", "o" ], and the same happens for Hebrew, emoji and a list given as
	#              input; the engine hands back one text and the splitting finds no separator in it
	#   see        NumberOfUniqueChars, RemoveDuplicatesQ
	def Unique()
		_cStr_ = This.Concatenated()
		pHandle = StzEngineString(_cStr_)
		pUniq = StzEngineStringUniqueChars(pHandle)
		_cJoined_ = StzEngineStringData(pUniq)
		StzEngineStringFree(pUniq)
		StzEngineStringFree(pHandle)

		if _cJoined_ = ""
			return []
		ok

		return _SplitNullDelimited(_cJoined_)

	# Returns how many different characters the list holds.
	#
	#   returns    a number
	#   note       hello gives 4
	#   see        Unique, NumberOfChars
	def NumberOfUniqueChars()
		_cStr_ = This.Concatenated()
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringUniqueCharsCount(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	  #===============================#
	 #   SORT (ENGINE)               #
	#===============================#

	# Reorders the characters in ascending code point order, in place, but leaves them joined in one item.
	#
	#   returns    nothing; the list changes
	#   note       Sort does the same
	#   warning    the list then holds ONE item, the whole sorted text, so NumberOfChars answers 1
	#              afterwards: hello becomes [ "ehllo" ] and not [ "e", "h", "l", "l", "o" ]; the
	#              engine hands back one text and the splitting finds no separator in it
	#   see        SortDesc, SortedAsc, Sort
	def SortAsc()
		_cStr_ = This.Concatenated()
		pHandle = StzEngineString(_cStr_)
		pSorted = StzEngineStringSortCharsAsc(pHandle)
		_cJoined_ = StzEngineStringData(pSorted)
		StzEngineStringFree(pSorted)
		StzEngineStringFree(pHandle)

		if _cJoined_ = ""
			@acChars = []
			return
		ok

		@acChars = _SplitNullDelimited(_cJoined_)

	# Returns the characters in ascending code point order, as a one-item list, leaving the object unchanged.
	#
	#   returns    a list holding one text
	#   note       the same defect as SortAsc
	#   warning    the answer is one text inside a list: hello gives [ "ehllo" ], not a list of
	#              single characters
	#   see        SortAsc, SortedDesc
	def SortedAsc()
		_oCopy_ = This.Copy()
		_oCopy_.SortAsc()
		return _oCopy_.Content()

	# Reorders the characters in descending code point order, in place, but leaves them joined in one item.
	#
	#   returns    nothing; the list changes
	#   note       the same defect as SortAsc
	#   warning    the list then holds ONE item, the whole sorted text: hello becomes [ "ollhe" ]
	#              and not [ "o", "l", "l", "h", "e" ]; the engine hands back one text and the
	#              splitting finds no separator in it
	#   see        SortAsc, SortedDesc
	def SortDesc()
		_cStr_ = This.Concatenated()
		pHandle = StzEngineString(_cStr_)
		pSorted = StzEngineStringSortCharsDesc(pHandle)
		_cJoined_ = StzEngineStringData(pSorted)
		StzEngineStringFree(pSorted)
		StzEngineStringFree(pHandle)

		if _cJoined_ = ""
			@acChars = []
			return
		ok

		@acChars = _SplitNullDelimited(_cJoined_)

	# Returns the characters in descending code point order, as a one-item list, leaving the object unchanged.
	#
	#   returns    a list holding one text
	#   note       the same defect as SortAsc
	#   warning    the answer is one text inside a list: hello gives [ "ollhe" ], not a list of
	#              single characters
	#   see        SortDesc, SortedAsc
	def SortedDesc()
		_oCopy_ = This.Copy()
		_oCopy_.SortDesc()
		return _oCopy_.Content()

	# Reorders the characters in ascending code point order, in place, but leaves them joined in one item.
	#
	#   returns    nothing; the list changes
	#   note       it calls SortAsc
	#   warning    the list then holds ONE item, the whole sorted text, exactly as SortAsc does
	#   see        SortAsc, SortDesc
	def Sort()
		This.SortAsc()

	def Sorted()
		return This.SortedAsc()

	  #===============================#
	 #   REVERSE                     #
	#===============================#

	# Turns the list around, in place, so that the last character comes first.
	#
	#   returns    nothing; the list changes
	#   note       Hebrew, Arabic and emoji characters stay whole
	#   see        Reversed, Join
	def Reverse()
		_nLen_ = len(@acChars)
		_acNew_ = []
		for i = _nLen_ to 1 step -1
			_acNew_ + @acChars[i]
		next
		@acChars = _acNew_

	# Returns the characters in the opposite order as a list, leaving the object unchanged.
	#
	#   returns    a list of text
	#   note       a😀b😀 gives 😀, b, 😀, a
	#   see        Reverse, Join
	def Reversed()
		_oCopy_ = This.Copy()
		_oCopy_.Reverse()
		return _oCopy_.Content()

	  #===============================#
	 #   CASE CHANGE                 #
	#===============================#

	# Changes every character to its capital form, in place, by converting the whole text at once.
	#
	#   returns    nothing; the list changes
	#   note       the result is split again into single characters, so the list keeps its length
	#   see        ToLower, Uppercase, Uppercased
	def ToUpper()
		_cStr_ = This.Concatenated()
		_cUpper_ = StzUpper(_cStr_)
		pHandle = StzEngineString(_cUpper_)
		pSplit = StzEngineStringCharsSplit(pHandle)
		_cJoined_ = StzEngineStringData(pSplit)
		StzEngineStringFree(pSplit)
		StzEngineStringFree(pHandle)

		if _cJoined_ = ""
			@acChars = []
			return
		ok

		@acChars = _SplitNullDelimited(_cJoined_)

	# Returns the characters in their capital form as a list, leaving the object unchanged.
	#
	#   returns    a list of text
	#   see        ToUpper, Lowercased
	def Uppercased()
		_oCopy_ = This.Copy()
		_oCopy_.ToUpper()
		return _oCopy_.Content()

	# Changes every character to its small form, in place, by converting the whole text at once.
	#
	#   returns    nothing; the list changes
	#   note       the result is split again into single characters, so the list keeps its length
	#   see        ToUpper, Lowercase, Lowercased
	def ToLower()
		_cStr_ = This.Concatenated()
		_cLower_ = StzLower(_cStr_)
		pHandle = StzEngineString(_cLower_)
		pSplit = StzEngineStringCharsSplit(pHandle)
		_cJoined_ = StzEngineStringData(pSplit)
		StzEngineStringFree(pSplit)
		StzEngineStringFree(pHandle)

		if _cJoined_ = ""
			@acChars = []
			return
		ok

		@acChars = _SplitNullDelimited(_cJoined_)

	# Returns the characters in their small form as a list, leaving the object unchanged.
	#
	#   returns    a list of text
	#   see        ToLower, Uppercased
	def Lowercased()
		_oCopy_ = This.Copy()
		_oCopy_.ToLower()
		return _oCopy_.Content()

	  #===============================#
	 #   UNICODES (ENGINE)           #
	#===============================#

	# Returns the Unicode code point of each character, in order.
	#
	#   returns    a list of numbers
	#   note       the emoji 😀 is 128512 and the Hebrew letter ש is 1513
	#   see        NthCharUnicode, Names
	def Unicodes()
		_nLen_ = len(@acChars)
		_anResult_ = []
		for i = 1 to _nLen_
			_anResult_ + StzEngineCharUnicode(@acChars[i])
		next
		return _anResult_

		# The RETURN-TYPE routing twin, the house form used by
		# stzHashList.KeysQRT, stzNumber.MultiplesUntilQRT and the rest:
		# the caller names the Softanza class the answer should arrive as.
		#
		# Written because a test already chained
		# .UnicodesQRT(:stzListOfNumbers).Sum() and there was nothing there.
		def UnicodesQRT(pcReturnType)

			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT ( isString(pcReturnType) and Q(pcReturnType).IsStzType() )
				StzRaise("Incorrect param! pcReturnType must be a string containing the name of a Softanza class.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Unicodes() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Unicodes() )

			other
				StzRaise("Unsupported return type! Use :stzList or :stzListOfNumbers.")
			off

	# Returns the Unicode code point of the character at the given position.
	#
	#   n          the position of the character, counted from 1
	#   returns    a number
	#   see        Unicodes, NthChar
	def NthCharUnicode(n)
		return StzEngineCharUnicode(This.NthChar(n))

	  #===============================#
	 #   CHAR CLASSIFICATION         #
	#===============================#

	# TRUE if the character at the given position is a letter, of any script.
	#
	#   n          the position of the character, counted from 1
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        IsDigitAt, IsUpperAt
	def IsLetterAt(n)
		_nUnicode_ = This.NthCharUnicode(n)
		return StzEngineCharIsLetter(_nUnicode_) = 1

	# TRUE if the character at the given position is a digit.
	#
	#   n          the position of the character, counted from 1
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        IsLetterAt, IsLowerAt
	def IsDigitAt(n)
		_nUnicode_ = This.NthCharUnicode(n)
		return StzEngineCharIsDigit(_nUnicode_) = 1

	# TRUE if the character at the given position is a capital letter.
	#
	#   n          the position of the character, counted from 1
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a letter of a script without capitals, such as Hebrew, answers FALSE
	#   see        IsLowerAt, IsLetterAt
	def IsUpperAt(n)
		_nUnicode_ = This.NthCharUnicode(n)
		return StzEngineCharIsUpper(_nUnicode_) = 1

	# TRUE if the character at the given position is a small letter.
	#
	#   n          the position of the character, counted from 1
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a letter of a script without capitals, such as Hebrew, answers FALSE
	#   see        IsUpperAt, IsLetterAt
	def IsLowerAt(n)
		_nUnicode_ = This.NthCharUnicode(n)
		return StzEngineCharIsLower(_nUnicode_) = 1

	  #===============================#
	 #   UPDATE                      #
	#===============================#

	# Replaces the whole content with the given list of characters.
	#
	#   paNewChars   a list of single characters, or a pair [ :With, list ]
	#   returns      nothing; the list changes
	#   see          Content, init
	def Update(paNewChars)
		if CheckingParams()
			if isList(paNewChars) and Q(paNewChars).IsWithOrByOrUsingNamedParam()
				paNewChars = paNewChars[2]
			ok

			if NOT @IsListOfChars(paNewChars)
				StzRaise("Incorrect param type! paNewChars must be a list of chars.")
			ok
		ok

		@acChars = paNewChars

	# _SplitNullDelimited() is provided globally by stzStringFunc.ring

	#-------#
	# MISC. #
	#-------#

	# Long-tail aliases used by Q("...").CharsQ() chains.
	def NumbrifyQ()
		_l_ = This.Content()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				_aR_ + (0 + _v_)
			but isNumber(_v_)
				_aR_ + _v_
			ok
		next
		return new stzList(_aR_)

	def NumbrifiedQ()
		return This.NumbrifyQ()

	def NumberifiedQ()
		return This.NumbrifyQ()

	def NumberifyQ()
		return This.NumbrifyQ()

	# Returns a new list holding the characters without their repeats, first occurrences kept, and leaves the object unchanged.
	#
	#   returns    a stzListOfChars
	#   note       unlike Unique it answers a proper list of single characters: x, y, x, x gives x,
	#              y
	#   see        Unique, NumberOfUniqueChars
	def RemoveDuplicatesQ()
		_l_ = This.Content()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			_bSeen_ = 0
			_nRL_ = len(_aR_)
			for _j_ = 1 to _nRL_
				if _aR_[_j_] = _v_ _bSeen_ = 1 exit ok
			next
			if NOT _bSeen_ _aR_ + _v_ ok
		next
		return new stzListOfChars(_aR_)

	# Returns the characters wrapped in a stzList, one single-character text per item.
	#
	#   returns    a stzList
	#   see        Content, Copy
	def ToStzListOfStrings()
		return new stzList( This.Content() )

	# Returns the characters drawn as a table of boxed cells on one row.
	#
	#   returns    a text of three lines made of box-drawing characters
	#   note       meant for display; the cell borders are not ASCII
	#   see        BoxDash, Join
	#@ aka  (the Are(p) stub was removed 2026-07-10: it answered TRUE for any non-empty list; the repaired stzList.Are is inherited instead)
	def Boxify()
		_o_ = new stzString(This._JoinedChars())
		return _o_._BoxRender([ :EachChar = 1 ])

	def Box()
		return This.Boxify()

	# Returns the characters drawn as a table of boxed cells on one row, with dashed borders.
	#
	#   returns    a text of three lines made of box-drawing characters
	#   note       meant for display; the cell borders are not ASCII
	#   see        Boxify, Join
	def BoxDash()
		_o_ = new stzString(This._JoinedChars())
		return _o_._BoxRender([ :EachChar = 1, :Line = :Dashed ])

	def _JoinedChars()
		_l_ = This.Content()
		_nL_ = len(_l_)
		_c_ = ""
		for _i_ = 1 to _nL_
			if isString(_l_[_i_]) _c_ += _l_[_i_] ok
		next
		return _c_

