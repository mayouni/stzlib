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
			nLen = len(pValue)
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

	# Uppercase / UppercaseQ / Lowercase / LowercaseQ: case-map.
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

	# JoinQ / Join: concatenate the chars into a single string,
	# wrapped in stzString for the Q form.
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

	def NumberOfChars()
		return len(@acChars)

		def Count()
			return len(@acChars)

		def Size()
			return len(@acChars)

		def Length()
			return len(@acChars)

	# Section(:From = pcA, :To = pcB) -- return the slice of chars
	# between the first occurrence of pcA and the first occurrence of
	# pcB (both inclusive). Also accepts numeric positions
	# Section(n1, n2). Returns a plain list of chars.
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

	def NthChar(n)
		if n < 1 or n > len(@acChars)
			StzRaise("Index out of range!")
		ok
		return @acChars[n]

	def Copy()
		return new stzStringCharList(@acChars)

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

	def Contains(cChar)
		nLen = len(@acChars)
		for i = 1 to nLen
			if @acChars[i] = cChar
				return 1
			ok
		next
		return 0

	def Find(cChar)
		anResult = []
		nLen = len(@acChars)
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
		nLen = len(@acChars)
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
		nLen = len(@acChars)
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

	def RemoveDuplicatesQ()
		_l_ = This.Content()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			_bSeen_ = FALSE
			_nRL_ = len(_aR_)
			for _j_ = 1 to _nRL_
				if _aR_[_j_] = _v_ _bSeen_ = TRUE exit ok
			next
			if NOT _bSeen_ _aR_ + _v_ ok
		next
		return new stzListOfChars(_aR_)

	def ToStzListOfStrings()
		return new stzList( This.Content() )

	def Are(p)
		return len(This.Content()) > 0

	# Boxify (delegates to the stzString cell renderer via concat).
	def Boxify()
		_o_ = new stzString(This._JoinedChars())
		return _o_._BoxRender([ :EachChar = TRUE ])

	def Box()
		return This.Boxify()

	def BoxDash()
		_o_ = new stzString(This._JoinedChars())
		return _o_._BoxRender([ :EachChar = TRUE, :Line = :Dashed ])

	def _JoinedChars()
		_l_ = This.Content()
		_nL_ = len(_l_)
		_c_ = ""
		for _i_ = 1 to _nL_
			if isString(_l_[_i_]) _c_ += _l_[_i_] ok
		next
		return _c_

