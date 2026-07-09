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

class stzStringUnicodeList from stzObject

	@anUnicodes

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

	def Content()
		return @anUnicodes

	def NumberOfItems()
		return len(@anUnicodes)

	def NthUnicode(_n_)
		if _n_ < 1 or _n_ > len(@anUnicodes)
			StzRaise("Out of range!")
		ok
		return @anUnicodes[_n_]

	def Copy()
		return new stzStringUnicodeList(@anUnicodes)

	  #===============================#
	 #     CONVERSIONS              #
	#===============================#

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

	def UnicodesAndChars()
		_aResult_ = []
		_nAnUnicodes4Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes4_ = 1 to _nAnUnicodes4Len_
			_n_ = @anUnicodes[_iLoopAnUnicodes4_]
			_aResult_ + [ _n_, StzChar(_n_) ]
		next
		return _aResult_

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

	def IsEmpty()
		return len(@anUnicodes) = 0

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

	def AllAreDigits()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsDigit(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	def AllArePunctuation()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsPunctuation(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	def AllAreSymbols()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsSymbol(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	def AllAreMarks()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsMark(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	def AllAreArabic()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsArabic(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	def AllAreLatin()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsLatin(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	def AllAreGreek()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsGreek(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

	def AllAreCyrillic()
		_cStr_ = This.ToString()
		if _cStr_ = ""
			return 0
		ok
		pHandle = StzEngineString(_cStr_)
		_nResult_ = StzEngineStringIsCyrillic(pHandle)
		StzEngineStringFree(pHandle)
		return _nResult_

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

	def Reversed()
		_aResult_ = []
		for i = len(@anUnicodes) to 1 step -1
			_aResult_ + @anUnicodes[i]
		next
		return _aResult_
