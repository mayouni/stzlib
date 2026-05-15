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

	def NumberOfOccurrence(pcSubStr)
		return This.NumberOfOccurrenceCS(pcSubStr, 1)

	  #======================================================#
	 #   COUNTING CHARS WITH CONDITION                      #
	#======================================================#

	def NumberOfCharsW(pcCondition)
		anPos = This.FindCharsW(pcCondition)
		return len(anPos)

	  #======================================================#
	 #   COUNT (SHORT FORM)                                 #
	#======================================================#

	def CountCS(pcSubStr, pCaseSensitive)
		return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

	def Count(pcSubStr)
		return This.CountCS(pcSubStr, 1)
