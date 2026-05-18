#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCOUNTER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String counter -- counting occurrences      #
#                  of substrings and chars.                     #
#                  Wraps stzString via composition.             #
#                  For aliases, use stzStringCounterXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCounter

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
			StzRaise("Can't create stzStringCounter! Parameter must be a string or stzString object.")
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
	 #   COUNTING OCCURRENCES OF A SUBSTRING                #
	#======================================================#

	def NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		if _bCase_
			return StzEngineStringCountOf(@oString.Engine(), pcSubStr)
		ok
		# Case-insensitive: use Engine CI function
		return StzEngineStringCountOfCI(@oString.Engine(), pcSubStr)

		def NumberOfOccurrencesCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

	def NumberOfOccurrence(pcSubStr)
		return This.NumberOfOccurrenceCS(pcSubStr, 1)

		def NumberOfOccurrences(pcSubStr)
			return This.NumberOfOccurrence(pcSubStr)

	  #======================================================#
	 #   COUNT (SHORT FORM)                                 #
	#======================================================#

	def CountCS(pcSubStr, pCaseSensitive)
		return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

		def CountSubStringCS(pcSubStr, pCaseSensitive)
			return This.CountCS(pcSubStr, pCaseSensitive)

	def Count(pcSubStr)
		return This.CountCS(pcSubStr, 1)

		def CountSubString(pcSubStr)
			return This.Count(pcSubStr)

	  #======================================================#
	 #   NUMBER OF CHARS                                    #
	#======================================================#

	def NumberOfCharsCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		if _bCase_ = 1
			return StzEngineStringCount(@oString.Engine())
		else
			oGetter = new stzStringGetter(@oString)
			return len(oGetter.UniqueCharsCS(0))
		ok

	  #======================================================#
	 #   NUMBER OF SUBSTRINGS                               #
	#======================================================#

	def NumberOfSubStringsCS(pCaseSensitive)
		if @oString.IsEmpty()
			return 0
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		if _bCase_ = 1
			n = @oString.NumberOfChars()
			return n * (n + 1) / 2
		else
			# Case-insensitive count via engine
			return StzEngineStringSubstringsCount(@oString.Engine())
		ok

		def HowManySubStringsCS(pCaseSensitive)
			return This.NumberOfSubStringsCS(pCaseSensitive)

	def NumberOfSubStrings()
		return This.NumberOfSubStringsCS(1)

		def HowManySubStrings()
			return This.NumberOfSubStrings()

	  #======================================================#
	 #   COUNT BETWEEN TWO POSITIONS                        #
	#======================================================#

	def CountBetweenCS(pcSubStr, n1, n2, pCaseSensitive)
		cSection = @oString.Section(n1, n2)
		return StringNumberOfOccurrenceCS(cSection, pcSubStr, pCaseSensitive)

	def CountBetween(pcSubStr, n1, n2)
		return This.CountBetweenCS(pcSubStr, n1, n2, 1)
