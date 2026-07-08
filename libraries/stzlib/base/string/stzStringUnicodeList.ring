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

func StzIsUnicode(n)
	if isNumber(n) and n >= 0 and n <= 1114111
		return 1
	else
		return 0
	ok

	func IsUnicode(n)
		return StzIsUnicode(n)


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
		nLen = len(aList)
		for i = 1 to nLen
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

	def NthUnicode(n)
		if n < 1 or n > len(@anUnicodes)
			StzRaise("Out of range!")
		ok
		return @anUnicodes[n]

	def Copy()
		return new stzStringUnicodeList(@anUnicodes)

	  #===============================#
	 #     CONVERSIONS              #
	#===============================#

	def Chars()
		aResult = []
		_nAnUnicodes6Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes6_ = 1 to _nAnUnicodes6Len_
			n = @anUnicodes[_iLoopAnUnicodes6_]
			aResult + StzChar(n)
		next
		return aResult

		def ToChars()
			return This.Chars()

	def ToString()
		cResult = ""
		_nAnUnicodes5Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes5_ = 1 to _nAnUnicodes5Len_
			n = @anUnicodes[_iLoopAnUnicodes5_]
			cResult += StzChar(n)
		next
		return cResult

		def String()
			return This.ToString()

	def UnicodesAndChars()
		aResult = []
		_nAnUnicodes4Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes4_ = 1 to _nAnUnicodes4Len_
			n = @anUnicodes[_iLoopAnUnicodes4_]
			aResult + [ n, StzChar(n) ]
		next
		return aResult

	def CharsAndUnicodes()
		aResult = []
		_nAnUnicodes3Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes3_ = 1 to _nAnUnicodes3Len_
			n = @anUnicodes[_iLoopAnUnicodes3_]
			aResult + [ StzChar(n), n ]
		next
		return aResult

	  #===============================#
	 #     CHECKING                 #
	#===============================#

	def IsEmpty()
		return len(@anUnicodes) = 0

	def Contains(nUnicode)
		_nAnUnicodes2Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes2_ = 1 to _nAnUnicodes2Len_
			n = @anUnicodes[_iLoopAnUnicodes2_]
			if n = nUnicode
				return 1
			ok
		next
		return 0

	  #===============================#
	 #     CLASSIFICATION           #
	#===============================#

	def AllAreLetters()
		# Build a string from these unicodes and check via engine
		cStr = This.ToString()
		if cStr = ""
			return 0
		ok
		pHandle = StzEngineString(cStr)
		nResult = StzEngineStringIsAlpha(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	def AllAreDigits()
		cStr = This.ToString()
		if cStr = ""
			return 0
		ok
		pHandle = StzEngineString(cStr)
		nResult = StzEngineStringIsDigit(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	def AllArePunctuation()
		cStr = This.ToString()
		if cStr = ""
			return 0
		ok
		pHandle = StzEngineString(cStr)
		nResult = StzEngineStringIsPunctuation(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	def AllAreSymbols()
		cStr = This.ToString()
		if cStr = ""
			return 0
		ok
		pHandle = StzEngineString(cStr)
		nResult = StzEngineStringIsSymbol(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	def AllAreMarks()
		cStr = This.ToString()
		if cStr = ""
			return 0
		ok
		pHandle = StzEngineString(cStr)
		nResult = StzEngineStringIsMark(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	def AllAreArabic()
		cStr = This.ToString()
		if cStr = ""
			return 0
		ok
		pHandle = StzEngineString(cStr)
		nResult = StzEngineStringIsArabic(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	def AllAreLatin()
		cStr = This.ToString()
		if cStr = ""
			return 0
		ok
		pHandle = StzEngineString(cStr)
		nResult = StzEngineStringIsLatin(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	def AllAreGreek()
		cStr = This.ToString()
		if cStr = ""
			return 0
		ok
		pHandle = StzEngineString(cStr)
		nResult = StzEngineStringIsGreek(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	def AllAreCyrillic()
		cStr = This.ToString()
		if cStr = ""
			return 0
		ok
		pHandle = StzEngineString(cStr)
		nResult = StzEngineStringIsCyrillic(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	def AllAreHebrew()
		cStr = This.ToString()
		if cStr = ""
			return 0
		ok
		pHandle = StzEngineString(cStr)
		nResult = StzEngineStringIsHebrew(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	  #===============================#
	 #     OPERATIONS               #
	#===============================#

	def Unique()
		aResult = []
		_nAnUnicodes1Len_ = len(@anUnicodes)
		for _iLoopAnUnicodes1_ = 1 to _nAnUnicodes1Len_
			n = @anUnicodes[_iLoopAnUnicodes1_]
			bFound = 0
			_nResult1Len_ = len(aResult)
			for _iLoopResult1_ = 1 to _nResult1Len_
				existing = aResult[_iLoopResult1_]
				if existing = n
					bFound = 1
					exit
				ok
			next
			if bFound = 0
				aResult + n
			ok
		next
		return aResult

	def Sorted()
		aResult = @anUnicodes
		nLen = len(aResult)
		for i = 1 to nLen - 1
			for j = 1 to nLen - i
				if aResult[j] > aResult[j+1]
					temp = aResult[j]
					aResult[j] = aResult[j+1]
					aResult[j+1] = temp
				ok
			next
		next
		return aResult

	def Reversed()
		aResult = []
		for i = len(@anUnicodes) to 1 step -1
			aResult + @anUnicodes[i]
		next
		return aResult
