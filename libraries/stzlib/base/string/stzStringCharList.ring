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

	nLen = len(pacChars)
	for i = 1 to nLen
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

	nLen = len(pacLetters)
	for i = 1 to nLen
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

func StzCharsBetween(c1, c2)
	if CheckingParams()
		if isList(c2) and len(c2) = 2 and isString(c2[1]) and c2[1] = "and"
			c2 = c2[2]
		ok

		if NOT @BothAreChars(c1, c2)
			StzRaise("Incorrect param type!")
		ok
	ok

	nUnicode1 = Unicode(c1)
	nUnicode2 = Unicode(c2)

	nStep = 1
	if nUnicode1 > nUnicode2
		nStep = -1
	ok

	acResult = []
	for i = nUnicode1 to nUnicode2 step nStep
		acResult + StzCharQ(i).Content()
	next

	return acResult

	func CharsBetween(c1, c2)
		return StzCharsBetween(c1, c2)

func StzNumberOfCharsBetween(c1, c2)
	if CheckingParams()
		if NOT @BothAreChars(c1, c2)
			StzRaise("Incorrect param type!")
		ok
	ok

	nUnicode1 = Unicode(c1)
	nUnicode2 = Unicode(c2)

	return Abs(nUnicode2 - nUnicode1) + 1

	func NumberOfCharsBetween(c1, c2)
		return StzNumberOfCharsBetween(c1, c2)

func StzCharsToUnicodes(paList)
	return StzStringCharListQ(paList).Unicodes()

	func CharsToUnicodes(paList)
		return StzCharsToUnicodes(paList)

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


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCharList

	@acChars = []

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pValue)

		if isString(pValue)
			# Auto-split a string into its chars via the engine
			pHandle = StzEngineString(pValue)
			pSplit = StzEngineStringCharsSplit(pHandle)
			cJoined = StzEngineStringData(pSplit)
			StzEngineStringFree(pSplit)
			StzEngineStringFree(pHandle)

			@acChars = _SplitNullDelimited(cJoined)

		but isList(pValue) and Q(pValue).IsListOfNumbers()
			# List of unicode codepoints
			nLen = ring_len(pValue)
			for i = 1 to nLen
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

	def Content()
		return @acChars

		def ToList()
			return @acChars

		def Chars()
			return @acChars

	# RemoveSpaces / RemoveSpacesQ: drop every " " char from the list.
	def RemoveSpaces()
		_aOut_ = []
		_nLen_ = ring_len(@acChars)
		for _i_ = 1 to _nLen_
			if @acChars[_i_] != " "
				_aOut_ + @acChars[_i_]
			ok
		next
		@acChars = _aOut_

		def RemoveSpacesQ()
			This.RemoveSpaces()
			return This

	# Uppercase / UppercaseQ / Lowercase / LowercaseQ: case-map.
	def Uppercase()
		_nLen_ = ring_len(@acChars)
		for _i_ = 1 to _nLen_
			if isString(@acChars[_i_])
				@acChars[_i_] = upper(@acChars[_i_])
			ok
		next

		def UppercaseQ()
			This.Uppercase()
			return This

	def Lowercase()
		_nLen_ = ring_len(@acChars)
		for _i_ = 1 to _nLen_
			if isString(@acChars[_i_])
				@acChars[_i_] = lower(@acChars[_i_])
			ok
		next

		def LowercaseQ()
			This.Lowercase()
			return This

	# JoinQ / Join: concatenate the chars into a single string,
	# wrapped in stzString for the Q form.
	def Join()
		_cOut_ = ""
		_nLen_ = ring_len(@acChars)
		for _i_ = 1 to _nLen_
			_cOut_ += @acChars[_i_]
		next
		return _cOut_

		def JoinQ()
			return new stzString( This.Join() )

	def NumberOfChars()
		return ring_len(@acChars)

		def Len()
			return ring_len(@acChars)

		def Length()
			return ring_len(@acChars)

	# Section(:From = pcA, :To = pcB) -- return the slice of chars
	# between the first occurrence of pcA and the first occurrence of
	# pcB (both inclusive). Also accepts numeric positions
	# Section(n1, n2). Returns a plain list of chars.
	def Section(p1, p2)
		_nLen_ = ring_len(@acChars)
		_n1_ = p1; _n2_ = p2
		if isList(p1) and ring_len(p1) = 2 and isString(p1[1]) and
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
		if isList(p2) and ring_len(p2) = 2 and isString(p2[1]) and
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

	def NthChar(n)
		if n < 1 or n > ring_len(@acChars)
			StzRaise("Index out of range!")
		ok
		return @acChars[n]

	def Copy()
		return new stzStringCharList(@acChars)

	def Concatenated()
		cResult = ""
		nLen = ring_len(@acChars)
		for i = 1 to nLen
			cResult += @acChars[i]
		next
		return cResult

	  #===============================#
	 #   CONTAINS / FIND             #
	#===============================#

	def Contains(cChar)
		nLen = ring_len(@acChars)
		for i = 1 to nLen
			if @acChars[i] = cChar
				return 1
			ok
		next
		return 0

	def Find(cChar)
		anResult = []
		nLen = ring_len(@acChars)
		for i = 1 to nLen
			if @acChars[i] = cChar
				anResult + i
			ok
		next
		return anResult

	  #===============================#
	 #   UNIQUE CHARS (ENGINE)       #
	#===============================#

	def Unique()
		cStr = This.Concatenated()
		pHandle = StzEngineString(cStr)
		pUniq = StzEngineStringUniqueChars(pHandle)
		cJoined = StzEngineStringData(pUniq)
		StzEngineStringFree(pUniq)
		StzEngineStringFree(pHandle)

		if cJoined = ""
			return []
		ok

		return _SplitNullDelimited(cJoined)

	def NumberOfUniqueChars()
		cStr = This.Concatenated()
		pHandle = StzEngineString(cStr)
		nResult = StzEngineStringUniqueCharsCount(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	  #===============================#
	 #   SORT (ENGINE)               #
	#===============================#

	def SortAsc()
		cStr = This.Concatenated()
		pHandle = StzEngineString(cStr)
		pSorted = StzEngineStringSortCharsAsc(pHandle)
		cJoined = StzEngineStringData(pSorted)
		StzEngineStringFree(pSorted)
		StzEngineStringFree(pHandle)

		if cJoined = ""
			@acChars = []
			return
		ok

		@acChars = _SplitNullDelimited(cJoined)

	def SortedAsc()
		oCopy = This.Copy()
		oCopy.SortAsc()
		return oCopy.Content()

	def SortDesc()
		cStr = This.Concatenated()
		pHandle = StzEngineString(cStr)
		pSorted = StzEngineStringSortCharsDesc(pHandle)
		cJoined = StzEngineStringData(pSorted)
		StzEngineStringFree(pSorted)
		StzEngineStringFree(pHandle)

		if cJoined = ""
			@acChars = []
			return
		ok

		@acChars = _SplitNullDelimited(cJoined)

	def SortedDesc()
		oCopy = This.Copy()
		oCopy.SortDesc()
		return oCopy.Content()

	def Sort()
		This.SortAsc()

	def Sorted()
		return This.SortedAsc()

	  #===============================#
	 #   REVERSE                     #
	#===============================#

	def Reverse()
		nLen = ring_len(@acChars)
		acNew = []
		for i = nLen to 1 step -1
			acNew + @acChars[i]
		next
		@acChars = acNew

	def Reversed()
		oCopy = This.Copy()
		oCopy.Reverse()
		return oCopy.Content()

	  #===============================#
	 #   CASE CHANGE                 #
	#===============================#

	def ToUpper()
		cStr = This.Concatenated()
		cUpper = StzUpper(cStr)
		pHandle = StzEngineString(cUpper)
		pSplit = StzEngineStringCharsSplit(pHandle)
		cJoined = StzEngineStringData(pSplit)
		StzEngineStringFree(pSplit)
		StzEngineStringFree(pHandle)

		if cJoined = ""
			@acChars = []
			return
		ok

		@acChars = _SplitNullDelimited(cJoined)

	def Uppercased()
		oCopy = This.Copy()
		oCopy.ToUpper()
		return oCopy.Content()

	def ToLower()
		cStr = This.Concatenated()
		cLower = StzLower(cStr)
		pHandle = StzEngineString(cLower)
		pSplit = StzEngineStringCharsSplit(pHandle)
		cJoined = StzEngineStringData(pSplit)
		StzEngineStringFree(pSplit)
		StzEngineStringFree(pHandle)

		if cJoined = ""
			@acChars = []
			return
		ok

		@acChars = _SplitNullDelimited(cJoined)

	def Lowercased()
		oCopy = This.Copy()
		oCopy.ToLower()
		return oCopy.Content()

	  #===============================#
	 #   UNICODES (ENGINE)           #
	#===============================#

	def Unicodes()
		nLen = ring_len(@acChars)
		anResult = []
		for i = 1 to nLen
			anResult + StzEngineCharUnicode(@acChars[i])
		next
		return anResult

	def NthCharUnicode(n)
		return StzEngineCharUnicode(This.NthChar(n))

	  #===============================#
	 #   CHAR CLASSIFICATION         #
	#===============================#

	def IsLetterAt(n)
		nUnicode = This.NthCharUnicode(n)
		return StzEngineCharIsLetter(nUnicode) = 1

	def IsDigitAt(n)
		nUnicode = This.NthCharUnicode(n)
		return StzEngineCharIsDigit(nUnicode) = 1

	def IsUpperAt(n)
		nUnicode = This.NthCharUnicode(n)
		return StzEngineCharIsUpper(nUnicode) = 1

	def IsLowerAt(n)
		nUnicode = This.NthCharUnicode(n)
		return StzEngineCharIsLower(nUnicode) = 1

	  #===============================#
	 #   UPDATE                      #
	#===============================#

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

  /////////////////////////////
 ///   ALIAS CLASS HOST    ///
/////////////////////////////

# stzListOfChars -- alias the rest of the library + every narrative
# test reaches for. It IS-A stzStringCharList; constructor accepts:
#   - a list of single-char strings:   new stzListOfChars(["a","b"])
#   - a list of unicode codepoints:    new stzListOfChars([945,946])
#     (auto-converted via StzChar(n) per item)
# Falls back to the parent constructor for string-with-content and
# other shapes the parent already supports.
class stzListOfChars from stzStringCharList

	def init(pValue)
		if isList(pValue)
			_nLen_ = ring_len(pValue)
			# If all items are numbers, convert to chars via StzChar.
			# Otherwise hand off to the parent init unchanged.
			if _nLen_ > 0
				_bAllNum_ = TRUE
				for _i_ = 1 to _nLen_
					if NOT isNumber(pValue[_i_])
						_bAllNum_ = FALSE
						exit
					ok
				next
				if _bAllNum_
					_aChars_ = []
					for _i_ = 1 to _nLen_
						_aChars_ + StzChar(pValue[_i_])
					next
					pValue = _aChars_
				ok
			ok
		ok
		super.init(pValue)
