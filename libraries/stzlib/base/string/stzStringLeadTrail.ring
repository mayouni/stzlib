#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGLEADTRAIL          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String lead/trail subclass -- repeated      #
#                  leading and trailing char operations.        #
#                  For aliases, use stzStringLeadTrailXT.       #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringLeadTrail from stzString

	  #======================================================#
	 #   REPEATED LEADING CHARS                             #
	#======================================================#

	def HasRepeatedLeadingCharsCS(pCaseSensitive)
		return len(This.RepeatedLeadingCharsCS(pCaseSensitive)) > 1

	def HasRepeatedLeadingChars()
		return This.HasRepeatedLeadingCharsCS(1)

	def RepeatedLeadingCharsCS(pCaseSensitive)
		cStr = This.Content()
		nLen = This.NumberOfChars()
		if nLen < 2
			return ""
		ok
		cFirst = cStr[1]
		cResult = cFirst
		for i = 2 to nLen
			if cStr[i] = cFirst
				cResult += cStr[i]
			else
				exit
			ok
		next
		if len(cResult) < 2
			return ""
		ok
		return cResult

	def RepeatedLeadingChars()
		return This.RepeatedLeadingCharsCS(1)

	def RepeatedLeadingChar()
		cLead = This.RepeatedLeadingChars()
		if len(cLead) > 0
			return cLead[1]
		else
			return ""
		ok

	def NumberOfRepeatedLeadingChars()
		return len(This.RepeatedLeadingChars())

	  #======================================================#
	 #   REPEATED TRAILING CHARS                            #
	#======================================================#

	def HasRepeatedTrailingCharsCS(pCaseSensitive)
		return len(This.RepeatedTrailingCharsCS(pCaseSensitive)) > 1

	def HasRepeatedTrailingChars()
		return This.HasRepeatedTrailingCharsCS(1)

	def RepeatedTrailingCharsCS(pCaseSensitive)
		cStr = This.Content()
		nLen = This.NumberOfChars()
		if nLen < 2
			return ""
		ok
		cLast = cStr[nLen]
		cResult = cLast
		for i = nLen - 1 to 1 step -1
			if cStr[i] = cLast
				cResult = cStr[i] + cResult
			else
				exit
			ok
		next
		if len(cResult) < 2
			return ""
		ok
		return cResult

	def RepeatedTrailingChars()
		return This.RepeatedTrailingCharsCS(1)

	  #======================================================#
	 #   REMOVING REPEATED LEADING / TRAILING CHARS         #
	#======================================================#

	def RemoveRepeatedLeadingChars()
		cLead = This.RepeatedLeadingChars()
		nToRemove = len(cLead) - 1
		if nToRemove > 0
			This.RemoveSection(1, nToRemove)
		ok

	def RemoveRepeatedTrailingChars()
		cTrail = This.RepeatedTrailingChars()
		nToRemove = len(cTrail) - 1
		nLen = This.NumberOfChars()
		if nToRemove > 0
			This.RemoveSection(nLen - nToRemove + 1, nLen)
		ok
