#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCOUNTER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String counter -- counting occurrences      #
#                  of substrings and chars.                    #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringCounterXT.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringCounter from stzObject

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
		return StzEngineStringCountOfCS(@oString.Engine(), pcSubStr, _bCase_)

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

	  #======================================================#
	 #   COUNT ANY CHAR (count occurrences of any char       #
	 #   in a given set)                                     #
	#======================================================#

	def CountAnyChar(pcChars)
		pH = @oString.Engine()
		return StzEngineStringCountAnyChar(pH, pcChars)

	  #======================================================#
	 #   COUNT LEADING / TRAILING CHAR                      #
	#======================================================#

	def CountLeadingChar(pcChar)
		pH = @oString.Engine()
		pHChar = StzEngineString(pcChar)
		nCp = StzEngineStringCharAt(pHChar, 1)
		StzEngineStringFree(pHChar)
		return StzEngineStringCountLeadingChar(pH, nCp)

	def CountTrailingChar(pcChar)
		pH = @oString.Engine()
		pHChar = StzEngineString(pcChar)
		nCp = StzEngineStringCharAt(pHChar, 1)
		StzEngineStringFree(pHChar)
		return StzEngineStringCountTrailingChar(pH, nCp)

	  #======================================================#
	 #   COUNT BETWEEN MARKERS                              #
	#======================================================#

	def CountBetweenMarkers(pcOpenMarker, pcCloseMarker)
		pH = @oString.Engine()
		return StzEngineStringCountBetween(pH, pcOpenMarker, pcCloseMarker)

	  #======================================================#
	 #   GRAPHEME COUNT                                     #
	#======================================================#

	def GraphemeCount()
		pH = @oString.Engine()
		return StzEngineStringGraphemeCount(pH)

	  #======================================================#
	 #   SCRIPT-SPECIFIC COUNTS                             #
	#======================================================#

	def CountMarks()
		pH = @oString.Engine()
		return StzEngineStringCountMarks(pH)

	def CountControls()
		pH = @oString.Engine()
		return StzEngineStringCountControls(pH)

	def CountCjk()
		pH = @oString.Engine()
		return StzEngineStringCountCjk(pH)

	def CountCyrillic()
		pH = @oString.Engine()
		return StzEngineStringCountCyrillic(pH)

	def CountHebrew()
		pH = @oString.Engine()
		return StzEngineStringCountHebrew(pH)

	def CountDevanagari()
		pH = @oString.Engine()
		return StzEngineStringCountDevanagari(pH)

	def CountThai()
		pH = @oString.Engine()
		return StzEngineStringCountThai(pH)

	  #======================================================#
	 #   OVERLAPPING OCCURRENCES                             #
	#======================================================#

	def CountOverlappingCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		return StzEngineStringCountOverlapping(pH, pcSubStr)

	def CountOverlapping(pcSubStr)
		return This.CountOverlappingCS(pcSubStr, 1)

	  #======================================================#
	 #   REGEX MATCH COUNT                                  #
	#======================================================#

	def CountRegex(pcPattern)
		pH = @oString.Engine()
		return StzEngineStringRegexCount(pH, pcPattern, 0)

		def NumberOfRegexMatches(pcPattern)
			return This.CountRegex(pcPattern)

	def CountRegexCS(pcPattern, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nFlags_ = 0
		if _bCase_ = 0
			_nFlags_ = 1
		ok
		pH = @oString.Engine()
		return StzEngineStringRegexCount(pH, pcPattern, _nFlags_)

		def NumberOfRegexMatchesCS(pcPattern, pCaseSensitive)
			return This.CountRegexCS(pcPattern, pCaseSensitive)

	  #======================================================#
	 #   COUNT CHARS MATCHING EXPRESSION                    #
	#======================================================#

	def CountCharsW(pcExpr)
		return StzEngineStringCountCharsW(@oString.Content(), pcExpr)

		def CountCharsWhere(pcExpr)
			return This.CountCharsW(pcExpr)

		def NumberOfCharsW(pcExpr)
			return This.CountCharsW(pcExpr)

