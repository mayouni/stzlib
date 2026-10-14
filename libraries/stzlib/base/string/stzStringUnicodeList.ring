#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGUNICODELIST        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Unicode list -- manages a list of Unicode   #
#                  codepoints, converts to/from chars/strings. #
#                  Uses engine char functions.                  #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringUnicodeListQ(aList)
	return new stzStringUnicodeList(aList)

func StzUnicodesToChars(anUnicodes)
	return StzStringUnicodeListQ(anUnicodes).Chars()

	func UnicodesToChars(anUnicodes)
		return StzUnicodesToChars(anUnicodes)

func StzUnicodesToString(anUnicodes)
	return StzStringUnicodeListQ(anUnicodes).ToString()

	func UnicodesToString(anUnicodes)
		return StzUnicodesToString(anUnicodes)

func StzIsUnicode(_n_)
	if isNumber(_n_) and _n_ >= 0 and _n_ <= 1114111
		return 1
	else
		return 0
	ok

	func IsUnicode(_n_)
		return StzIsUnicode(_n_)


  /////////////////
 ///   CLASS   ///
/////////////////

# Holds a list of Unicode code points and turns it into characters, text and per-script checks.
#
# Reach for it when you hold numbers such as 1513 and want the text, or hold a text's code points
# and want to ask whether they are all letters, digits, symbols or in one script. It is built with
# StzStringUnicodeListQ(aList); stzString does not hand one out. The list is validated at birth:
# every item must be a number from 0 to 1114111. The AllAre... checks build the text of the code
# points and ask the engine, so one check on a long list costs a string build; they answer FALSE for
# an empty list. Sorted, Unique and Reversed return new lists and never change the one held.
#
#   receiver   o1 = StzStringUnicodeListQ([ 72, 105 ])
#   example    ? o1.ToString()
#              #--> Hi
#              ? @@( o1.UnicodesAndChars() )
#              #--> [ [ 72, "H" ], [ 105, "i" ] ]
#              o2 = StzStringUnicodeListQ([ 1513, 1500, 1493, 1501 ])
#              ? o2.ToString()
#              #--> שלום
#              ? o2.AllAreHebrew()
#              #--> 1
#              o3 = StzStringUnicodeListQ([ 128512, 97, 128512 ])
#              ? @@( o3.Chars() )
#              #--> [ "😀", "a", "😀" ]
#   see        stzString, StzChar, stzChar
class stzStringUnicodeList from stzObject

	@anUnicodes

	# Builds a list of Unicode code points, checking that every item is a number from 0 to 1114111.
	#
	#   aList      the list of code point numbers
	#   returns    nothing; the object is built
	#   note       the object keeps the list as given; stzString does not build one, so reach it
	#              with StzStringUnicodeListQ(aList) or new stzStringUnicodeList(aList)
	#   see        Content, StzStringUnicodeListQ
	def init(aList)
		if NOT isList(aList)
			StzRaise("Can't create stzStringUnicodeList! Parameter must be a list.")
		ok

		# Validate: all items must be numbers in unicode range
		_nLen_ = len(aList)
		for i = 1 to _nLen_
			if NOT isNumber(aList[i])
				StzRaise("Can't create stzStringUnicodeList! All items must be numbers.")
			ok
			if aList[i] < 0 or aList[i] > 1114111
				StzRaise("Can't create stzStringUnicodeList! Unicode values must be 0-1114111.")
			ok
		next

		@anUnicodes = aList

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list of code points held, in the order given.
	#
	#   returns    a list of numbers
	#   see        NumberOfItems, Chars
	def Content()
		return @anUnicodes

	# Returns how many code points the list holds, repeated ones counted each time.
	#
	#   returns    a number
	#   see        Content, Unique
	def NumberOfItems()
		return len(@anUnicodes)

	# Returns the code point at a position.
	#
	#   _n_        the 1-based position of the code point
	#   returns    a number
	#   note       position 2 of the codes of Hello gives 101
	#   warning    a position below 1 or past the end raises the error Out of range!
	#   see        Content, Contains
	def NthUnicode(_n_)
		if _n_ < 1 or _n_ > len(@anUnicodes)
			StzRaise("Out of range!")
		ok
		return @anUnicodes[_n_]

	# Returns a second list object holding the same code points.
	#
	#   returns    a stzStringUnicodeList
	#   see        Content
	def Copy()
		return new stzStringUnicodeList(@anUnicodes)

	  #===============================#
	 #     CONVERSIONS              #
	#===============================#

	# Returns each code point as the character it stands for, in a list of texts.
	#
	#   returns    a list of texts, one character each; empty for an empty list
	#   note       the Hebrew code points 1513 1500 give the letters shin and lamed one by one; an
	#              emoji stays one item
	#   see        ToString, UnicodesAndChars
	def Chars()
		_aResult_ = []
		_nAnUnicodes6Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes6_ = 1 to _nAnUnicodes6Len_
			_n_ = @anUnicodes[_iLoopAnUnicodes6_]
			_aResult_ + StzChar(_n_)
		next
		return _aResult_

		def ToChars()
			return This.Chars()

	# Returns the characters of all the code points joined into one text.
	#
	#   returns    a text; empty for an empty list
	#   note       String is the same call; the Arabic code points 1605 1585 1581 1576 1575 give the
	#              word marhaba
	#   see        Chars
	def ToString()
		_cResult_ = ""
		_nAnUnicodes5Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes5_ = 1 to _nAnUnicodes5Len_
			_n_ = @anUnicodes[_iLoopAnUnicodes5_]
			_cResult_ += StzChar(_n_)
		next
		return _cResult_

		def String()
			return This.ToString()

	# Returns each code point paired with its character.
	#
	#   returns    a list of [ code point, character ] pairs
	#   note       72 pairs with H
	#   see        CharsAndUnicodes, Chars
	def UnicodesAndChars()
		_aResult_ = []
		_nAnUnicodes4Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes4_ = 1 to _nAnUnicodes4Len_
			_n_ = @anUnicodes[_iLoopAnUnicodes4_]
			_aResult_ + [ _n_, StzChar(_n_) ]
		next
		return _aResult_

	# Returns each character paired with its code point.
	#
	#   returns    a list of [ character, code point ] pairs
	#   note       H pairs with 72
	#   see        UnicodesAndChars, Chars
	def CharsAndUnicodes()
		_aResult_ = []
		_nAnUnicodes3Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes3_ = 1 to _nAnUnicodes3Len_
			_n_ = @anUnicodes[_iLoopAnUnicodes3_]
			_aResult_ + [ StzChar(_n_), _n_ ]
		next
		return _aResult_

	  #===============================#
	 #     CHECKING                 #
	#===============================#

	# TRUE if the list holds no code point.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfItems
	def IsEmpty()
		return len(@anUnicodes) = 0

	# TRUE if a code point is in the list.
	#
	#   nUnicode   the code point number to look for
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NthUnicode, Unique
	def Contains(nUnicode)
		_nAnUnicodes2Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes2_ = 1 to _nAnUnicodes2Len_
			_n_ = @anUnicodes[_iLoopAnUnicodes2_]
			if _n_ = nUnicode
				return 1
			ok
		next
		return 0

	  #===============================#
	 #     CLASSIFICATION           #
	#===============================#

	# TRUE if the characters of the code points are all letters, in any script.
	#
	#   returns    TRUE or FALSE, as 1 or 0; FALSE for an empty list
	#   note       Hebrew and Arabic letters count; Hi! is FALSE because of the sign
	#   see        AllAreDigits, AllAreLatin
	def AllAreLetters()
		# Build a string from these unicodes and check via engine
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsAlpha(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	# TRUE if the characters of the code points are all digits, in any script.
	#
	#   returns    TRUE or FALSE, as 1 or 0; FALSE for an empty list
	#   note       the Arabic-Indic digits 1634 and 1635 count
	#   see        AllAreLetters
	def AllAreDigits()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsDigit(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	# TRUE if the characters of the code points are all punctuation marks.
	#
	#   returns    TRUE or FALSE, as 1 or 0; FALSE for an empty list
	#   note       ! , . are punctuation while $ + < are symbols
	#   see        AllAreSymbols
	def AllArePunctuation()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsPunctuation(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	# TRUE if the characters of the code points are all symbols, such as signs, currency marks and emoji.
	#
	#   returns    TRUE or FALSE, as 1 or 0; FALSE for an empty list
	#   note       the emoji 128512 and the euro sign 8364 are symbols
	#   see        AllArePunctuation
	def AllAreSymbols()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsSymbol(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	# TRUE if the characters of the code points are all combining marks.
	#
	#   returns    TRUE or FALSE, as 1 or 0; FALSE for an empty list
	#   note       the accents 769 and 768 are marks
	#   see        AllAreLetters
	def AllAreMarks()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsMark(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	# TRUE if the characters of the code points are all in the Arabic script.
	#
	#   returns    TRUE or FALSE, as 1 or 0; FALSE for an empty list
	#   note       Arabic-Indic digits count as Arabic
	#   see        AllAreHebrew, AllAreLatin
	def AllAreArabic()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsArabic(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	# TRUE if the characters of the code points are all Latin letters.
	#
	#   returns    TRUE or FALSE, as 1 or 0; FALSE for an empty list or a mix with another script
	#   note       Hello is TRUE, Hi followed by a Hebrew letter is FALSE
	#   see        AllAreGreek, AllAreArabic
	def AllAreLatin()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsLatin(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	# TRUE if the characters of the code points are all in the Greek script.
	#
	#   returns    TRUE or FALSE, as 1 or 0; FALSE for an empty list
	#   note       945 946 947 give alpha beta gamma and TRUE
	#   see        AllAreLatin, AllAreCyrillic
	def AllAreGreek()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsGreek(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	# TRUE if the characters of the code points are all in the Cyrillic script.
	#
	#   returns    TRUE or FALSE, as 1 or 0; FALSE for an empty list
	#   note       1055 1088 1080 give three Cyrillic letters and TRUE
	#   see        AllAreGreek, AllAreLatin
	def AllAreCyrillic()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsCyrillic(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	# TRUE if the characters of the code points are all in the Hebrew script.
	#
	#   returns    TRUE or FALSE, as 1 or 0; FALSE for an empty list or a mix with another script
	#   note       the code points of shalom give TRUE; adding an Arabic letter gives FALSE
	#   see        AllAreArabic, AllAreLatin
	def AllAreHebrew()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsHebrew(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	  #===============================#
	 #     OPERATIONS               #
	#===============================#

	# Returns the code points with repeats dropped, keeping the first occurrence of each.
	#
	#   returns    a list of numbers
	#   note       the list held is not changed; 72 101 108 108 111 gives 72 101 108 111
	#   see        Sorted, NumberOfItems
	def Unique()
		_aResult_ = []
		_nAnUnicodes1Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes1_ = 1 to _nAnUnicodes1Len_
			_n_ = @anUnicodes[_iLoopAnUnicodes1_]
			_bFound_ = 0
			_nResult1Len_ = len(_aResult_)
			for _iLoopResult1_ = 1 to _nResult1Len_
				_existing_ = _aResult_[_iLoopResult1_]
				if _existing_ = _n_
					_bFound_ = 1
					exit
				ok
			next
			if _bFound_ = 0
				_aResult_ + _n_
			ok
		next
		return _aResult_

	# Returns the code points in ascending order.
	#
	#   returns    a list of numbers
	#   note       the list held is not changed; the emoji 128512 sorts after a
	#   see        Reversed, Unique
	def Sorted()
		_aResult_ = @anUnicodes
		_nLen_ = len(_aResult_)
		for i = 1 to _nLen_ - 1
			for j = 1 to _nLen_ - i
				if _aResult_[j] > _aResult_[j+1]
					_temp_ = _aResult_[j]
					_aResult_[j] = _aResult_[j+1]
					_aResult_[j+1] = _temp_
				ok
			next
		next
		return _aResult_

	# Returns the code points in the opposite order.
	#
	#   returns    a list of numbers
	#   note       the list held is not changed
	#   see        Sorted, ToString
	def Reversed()
		_aResult_ = []
		for i = len(@anUnicodes) to 1 step -1
			_aResult_ + @anUnicodes[i]
		next
		return _aResult_
