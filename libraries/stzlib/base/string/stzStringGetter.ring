#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGGETTER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String getter -- accessing individual       #
#                  chars and char groups.                      #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringGetterXT.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringGetter

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringGetter! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   ACCESSING NTH CHAR                                 #
	#======================================================#

	def NthChar(n)
		return @oString.NthChar(n)

		def CharAt(n)
			return This.NthChar(n)

		def CharAtPosition(n)
			return This.NthChar(n)

	  #======================================================#
	 #   FIRST / LAST / MIDDLE CHAR                         #
	#======================================================#

	def FirstChar()
		return This.NthChar(1)

	def LastChar()
		return This.NthChar(@oString.NumberOfChars())

	def MiddleChar()
		n = ceil(@oString.NumberOfChars() / 2)
		return This.NthChar(n)

	  #======================================================#
	 #   N FIRST / N LAST CHARS                             #
	#======================================================#

	def NFirstChars(n)
		return @oString.Section(1, n)

		def NFirstCharsQ(n)
			return StzStringQ(This.NFirstChars(n))

	def NLastChars(n)
		nLen = @oString.NumberOfChars()
		return @oString.Section(nLen - n + 1, nLen)

		def NLastCharsQ(n)
			return StzStringQ(This.NLastChars(n))

	  #======================================================#
	 #   N LEFT / N RIGHT CHARS                             #
	#======================================================#

	def NLeftChars(n)
		if @oString.IsLeftToRight()
			return This.NFirstChars(n)
		else
			return This.NLastChars(n)
		ok

		def NLeftCharsQ(n)
			return StzStringQ(This.NLeftChars(n))

		def NLeftCharsAsString(n)
			return This.NLeftChars(n)

		def NLeftCharsAsStringQ(n)
			return StzStringQ(This.NLeftChars(n))

	def NRightChars(n)
		if @oString.IsLeftToRight()
			return This.NLastChars(n)
		else
			return This.NFirstChars(n)
		ok

		def NRightCharsQ(n)
			return StzStringQ(This.NRightChars(n))

		def NRightCharsAsString(n)
			return This.NRightChars(n)

		def NRightCharsAsStringQ(n)
			return StzStringQ(This.NRightChars(n))

	  #======================================================#
	 #   ALL CHARS AS LIST                                  #
	#======================================================#

	def Chars()
		return @oString.Chars()

	  #======================================================#
	 #   UNIQUE CHARS                                       #
	#======================================================#

	def UniqueCharsCS(pCaseSensitive)
		aChars = This.Chars()
		return UCS(aChars, pCaseSensitive)

	def UniqueChars()
		return This.UniqueCharsCS(1)

	  #======================================================#
	 #   SECTION / RANGE ACCESS                             #
	#======================================================#

	def Section(n1, n2)
		return @oString.Section(n1, n2)

	def Range(nStart, nRange)
		return @oString.Range(nStart, nRange)

	  #======================================================#
	 #   CHAR N-GRAMS                                       #
	#======================================================#

	def CharNgrams(n)
		pH = @oString.Engine()
		pR = StzEngineStringCharNgrams(pH, n)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		if c = ""
			return []
		ok
		# Engine returns pipe-delimited ngrams: "ab|bc|cd"
		return @Split(c, "|")

	  #======================================================#
	 #   WORD N-GRAMS                                       #
	#======================================================#

	def WordNgrams(n)
		pH = @oString.Engine()
		pR = StzEngineStringWordNgrams(pH, n)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		if c = ""
			return []
		ok
		# Engine returns pipe-delimited ngrams: "the quick|quick brown"
		return @Split(c, "|")

	  #======================================================#
	 #   BYTES PER CHAR                                     #
	#======================================================#

	def BytesPerChar()
		pH = @oString.Engine()
		pR = StzEngineStringBytesPerChar(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c
