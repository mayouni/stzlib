#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGREMOVER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String remover subclass -- removing         #
#                  substrings by value, position, or section.   #
#                  For aliases, use stzStringRemoverXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringRemover from stzString

	  #======================================================#
	 #   REMOVING ALL OCCURRENCES OF A GIVEN SUBSTRING      #
	#======================================================#

	def RemoveCS(pcSubStr, pCaseSensitive)
		This.ReplaceCS(pcSubStr, "", pCaseSensitive)

		def RemoveCSQ(pcSubStr, pCaseSensitive)
			This.RemoveCS(pcSubStr, pCaseSensitive)
			return This

	def Remove(pcSubStr)
		This.RemoveCS(pcSubStr, 1)

	def RemovedCS(pcSubStr, pCaseSensitive)
		cResult = This.Copy().RemoveCSQ(pcSubStr, pCaseSensitive).Content()
		return cResult

	def Removed(pcSubStr)
		return This.RemovedCS(pcSubStr, 1)

	  #======================================================#
	 #   REMOVING NTH OCCURRENCE OF A GIVEN SUBSTRING       #
	#======================================================#

	def RemoveNthCS(n, pcSubStr, pCaseSensitive)
		This.ReplaceNthCS(n, pcSubStr, "", pCaseSensitive)

	def RemoveNth(n, pcSubStr)
		This.RemoveNthCS(n, pcSubStr, 1)

	  #======================================================#
	 #   REMOVING FIRST / LAST OCCURRENCE                   #
	#======================================================#

	def RemoveFirstCS(pcSubStr, pCaseSensitive)
		This.RemoveNthCS(1, pcSubStr, pCaseSensitive)

	def RemoveFirst(pcSubStr)
		This.RemoveFirstCS(pcSubStr, 1)

	def RemoveLastCS(pcSubStr, pCaseSensitive)
		This.ReplaceLastCS(pcSubStr, "", pCaseSensitive)

	def RemoveLast(pcSubStr)
		This.RemoveLastCS(pcSubStr, 1)

	  #======================================================#
	 #   REMOVING AT A GIVEN POSITION                       #
	#======================================================#

	def RemoveAtPositionCS(n, pcSubStr, pCaseSensitive)
		nLen = StzStringQ(pcSubStr).NumberOfChars()
		This.RemoveSection(n, n + nLen - 1)

	def RemoveAtPosition(n, pcSubStr)
		This.RemoveAtPositionCS(n, pcSubStr, 1)

	  #======================================================#
	 #   REMOVING A SECTION                                 #
	#======================================================#

	def RemoveSection(n1, n2)
		cLeft = This.Section(1, n1 - 1)
		cRight = ""
		if n2 < This.NumberOfChars()
			cRight = This.Section(n2 + 1, This.NumberOfChars())
		ok
		This.Update(cLeft + cRight)

	  #======================================================#
	 #   REMOVING WITH CONDITION                            #
	#======================================================#

	def RemoveW(pcCondition)
		anPos = This.FindW(pcCondition)
		# Remove from end to start to preserve positions
		for i = len(anPos) to 1 step -1
			This.RemoveSection(anPos[i], anPos[i])
		next
