#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGINSERTER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String inserter subclass -- inserting       #
#                  substrings at positions or around matches.   #
#                  For aliases, use stzStringInserterXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringInserter from stzString

	  #======================================================#
	 #   INSERTING BEFORE / AFTER A POSITION                #
	#======================================================#

	def InsertBefore(n, pcSubStr)
		if n = 1
			This.Update(pcSubStr + This.Content())
			return
		ok
		cLeft = This.Section(1, n - 1)
		cRight = This.Section(n, This.NumberOfChars())
		This.Update(cLeft + pcSubStr + cRight)

		def InsertBeforeQ(n, pcSubStr)
			This.InsertBefore(n, pcSubStr)
			return This

	def InsertAfter(n, pcSubStr)
		This.InsertBefore(n + 1, pcSubStr)

		def InsertAfterQ(n, pcSubStr)
			This.InsertAfter(n, pcSubStr)
			return This

	  #======================================================#
	 #   INSERTING BEFORE / AFTER A SUBSTRING               #
	#======================================================#

	def InsertBeforeSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		anPos = This.FindAllCS(pcSubStr, pCaseSensitive)
		nLen = len(anPos)
		nShift = 0
		nNewLen = StzStringQ(pcNewSubStr).NumberOfChars()
		for i = 1 to nLen
			This.InsertBefore(anPos[i] + nShift, pcNewSubStr)
			nShift += nNewLen
		next

	def InsertBeforeSubString(pcSubStr, pcNewSubStr)
		This.InsertBeforeSubStringCS(pcSubStr, pcNewSubStr, 1)

	def InsertAfterSubStringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		anPos = This.FindAllCS(pcSubStr, pCaseSensitive)
		nSubLen = StzStringQ(pcSubStr).NumberOfChars()
		nLen = len(anPos)
		nShift = 0
		nNewLen = StzStringQ(pcNewSubStr).NumberOfChars()
		for i = 1 to nLen
			This.InsertAfter(anPos[i] + nSubLen - 1 + nShift, pcNewSubStr)
			nShift += nNewLen
		next

	def InsertAfterSubString(pcSubStr, pcNewSubStr)
		This.InsertAfterSubStringCS(pcSubStr, pcNewSubStr, 1)
