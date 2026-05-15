#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGEXTRACTOR          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String extractor subclass -- extract        #
#                  (remove and return) sections and matches.    #
#                  For aliases, use stzStringExtractorXT.       #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringExtractor from stzString

	  #======================================================#
	 #   EXTRACTING A SECTION                               #
	#======================================================#

	def ExtractSection(n1, n2)
		cResult = This.Section(n1, n2)
		This.RemoveSection(n1, n2)
		return cResult

	  #======================================================#
	 #   EXTRACTING A RANGE                                 #
	#======================================================#

	def ExtractRange(pnStart, pnRange)
		return This.ExtractSection(pnStart, pnStart + pnRange - 1)

	  #======================================================#
	 #   EXTRACTING FIRST / LAST OCCURRENCE                 #
	#======================================================#

	def ExtractFirst(pcSubStr)
		n = This.FindFirst(pcSubStr)
		if n = 0
			return ""
		ok
		nLen = StzStringQ(pcSubStr).NumberOfChars()
		return This.ExtractSection(n, n + nLen - 1)

	def ExtractLast(pcSubStr)
		n = This.FindLast(pcSubStr)
		if n = 0
			return ""
		ok
		nLen = StzStringQ(pcSubStr).NumberOfChars()
		return This.ExtractSection(n, n + nLen - 1)
