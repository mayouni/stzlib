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


class stzStringGetter from stzObject

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

	def NthChar(_n_)
		return @oString.NthChar(_n_)

		def CharAt(_n_)
			return This.NthChar(_n_)

		def CharAtPosition(_n_)
			return This.NthChar(_n_)

	  #======================================================#
	 #   FIRST / LAST / MIDDLE CHAR                         #
	#======================================================#

	def FirstChar()
		return This.NthChar(1)

	def LastChar()
		return This.NthChar(@oString.NumberOfChars())

	def MiddleChar()
		_n_ = ceil(@oString.NumberOfChars() / 2)
		return This.NthChar(_n_)

	  #======================================================#
	 #   N FIRST / N LAST CHARS                             #
	#======================================================#

	def NFirstChars(_n_)
		return @oString.Section(1, _n_)

		def NFirstCharsQ(_n_)
			return StzStringQ(This.NFirstChars(_n_))

	def NLastChars(_n_)
		_nLen_ = @oString.NumberOfChars()
		return @oString.Section(_nLen_ - _n_ + 1, _nLen_)

		def NLastCharsQ(_n_)
			return StzStringQ(This.NLastChars(_n_))

	  #======================================================#
	 #   N LEFT / N RIGHT CHARS                             #
	#======================================================#

	def NLeftChars(_n_)
		if @oString.IsLeftToRight()
			return This.NFirstChars(_n_)
		else
			return This.NLastChars(_n_)
		ok

		def NLeftCharsQ(_n_)
			return StzStringQ(This.NLeftChars(_n_))

		def NLeftCharsAsString(_n_)
			return This.NLeftChars(_n_)

		def NLeftCharsAsStringQ(_n_)
			return StzStringQ(This.NLeftChars(_n_))

	def NRightChars(_n_)
		if @oString.IsLeftToRight()
			return This.NLastChars(_n_)
		else
			return This.NFirstChars(_n_)
		ok

		def NRightCharsQ(_n_)
			return StzStringQ(This.NRightChars(_n_))

		def NRightCharsAsString(_n_)
			return This.NRightChars(_n_)

		def NRightCharsAsStringQ(_n_)
			return StzStringQ(This.NRightChars(_n_))

	  #======================================================#
	 #   ALL CHARS AS LIST                                  #
	#======================================================#

	def Chars()
		return @oString.Chars()

	  #======================================================#
	 #   UNIQUE CHARS                                       #
	#======================================================#

	def UniqueCharsCS(pCaseSensitive)
		_aChars_ = This.Chars()
		return UCS(_aChars_, pCaseSensitive)

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

	def CharNgrams(_n_)
		pH = @oString.Engine()
		pR = StzEngineStringCharNgrams(pH, _n_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		if _c_ = ""
			return []
		ok
		# Engine returns pipe-delimited ngrams: "ab|bc|cd"
		return @Split(_c_, "|")

	  #======================================================#
	 #   WORD N-GRAMS                                       #
	#======================================================#

	def WordNgrams(_n_)
		pH = @oString.Engine()
		pR = StzEngineStringWordNgrams(pH, _n_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		if _c_ = ""
			return []
		ok
		# Engine returns pipe-delimited ngrams: "the quick|quick brown"
		return @Split(_c_, "|")

	  #======================================================#
	 #   BYTES PER CHAR                                     #
	#======================================================#

	def BytesPerChar()
		pH = @oString.Engine()
		pR = StzEngineStringBytesPerChar(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_
