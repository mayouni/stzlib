#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCOUNTER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String counter subclass -- counting         #
#                  occurrences of substrings and chars.         #
#                  For aliases, use stzStringCounterXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCounter from stzString

	  #======================================================#
	 #   COUNTING OCCURRENCES OF A SUBSTRING                #
	#======================================================#

	def NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		anPos = This.FindAllCS(pcSubStr, pCaseSensitive)
		return len(anPos)

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
			return @NumberOfChars(This.Content())
		else
			return len(This.UniqueCharsCS(0))
		ok

	def NumberOfChars()
		return This.NumberOfCharsCS(1)

	  #======================================================#
	 #   NUMBER OF CHARS WITH CONDITION                     #
	#======================================================#

	def NumberOfCharsWCS(pcCondition, pCaseSensitive)
		anPos = This.FindCharsWCS(pcCondition, pCaseSensitive)
		return len(anPos)

	def NumberOfCharsW(pcCondition)
		return This.NumberOfCharsWCS(pcCondition, 1)

	  #======================================================#
	 #   NUMBER OF LINES                                    #
	#======================================================#

	def NumberOfLinesCS(pCaseSensitive)
		return len(This.LinesCS(pCaseSensitive))

		def HowManyLinesCS(pCaseSensitive)
			return This.NumberOfLinesCS(pCaseSensitive)

		def CountLinesCS(pCaseSensitive)
			return This.NumberOfLinesCS(pCaseSensitive)

	def NumberOfLines()
		return This.NumberOfLinesCS(1)

		def HowManyLines()
			return This.NumberOfLines()

		def CountLines()
			return This.NumberOfLines()

	  #======================================================#
	 #   NUMBER OF SUBSTRINGS                               #
	#======================================================#

	def NumberOfSubStringsCS(pCaseSensitive)
		if This.IsEmpty()
			return 0
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)

		if _bCase_ = 1
			n = This.NumberOfChars()
			return n * (n + 1) / 2
		else
			acSubStrCS = This.SubStringsCS(0)
			return len(acSubStrCS)
		ok

		def HowManySubStringsCS(pCaseSensitive)
			return This.NumberOfSubStringsCS(pCaseSensitive)

	def NumberOfSubStrings()
		return This.NumberOfSubStringsCS(1)

		def HowManySubStrings()
			return This.NumberOfSubStrings()

	  #======================================================#
	 #   NUMBER OF DUPLICATES                               #
	#======================================================#

	def NumberOfDuplicatesCS(pCaseSensitive)
		return len(This.DuplicatesCS(pCaseSensitive))

		def HowManyDuplicatesCS(pCaseSensitive)
			return This.NumberOfDuplicatesCS(pCaseSensitive)

	def NumberOfDuplicates()
		return This.NumberOfDuplicatesCS(1)

		def HowManyDuplicates()
			return This.NumberOfDuplicates()

	  #======================================================#
	 #   COUNT BETWEEN TWO POSITIONS                        #
	#======================================================#

	def CountBetweenCS(pcSubStr, n1, n2, pCaseSensitive)
		cSection = This.Section(n1, n2)
		return StzStringQ(cSection).CountCS(pcSubStr, pCaseSensitive)

	def CountBetween(pcSubStr, n1, n2)
		return This.CountBetweenCS(pcSubStr, n1, n2, 1)
