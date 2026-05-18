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

class stzStringLeadTrail

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringLeadTrail! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   REPEATED LEADING CHARS                             #
	#======================================================#

	def HasRepeatedLeadingCharsCS(pCaseSensitive)
		return len(This.RepeatedLeadingCharsCS(pCaseSensitive)) > 1

	def HasRepeatedLeadingChars()
		return This.HasRepeatedLeadingCharsCS(1)

	def RepeatedLeadingCharsCS(pCaseSensitive)
		cStr = @oString.Content()
		nLen = @oString.NumberOfChars()
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

	def LeadingChar()
		if @oString.NumberOfChars() > 0
			return @oString.Content()[1]
		ok
		return ""

	  #======================================================#
	 #   REPEATED TRAILING CHARS                            #
	#======================================================#

	def HasRepeatedTrailingCharsCS(pCaseSensitive)
		return len(This.RepeatedTrailingCharsCS(pCaseSensitive)) > 1

	def HasRepeatedTrailingChars()
		return This.HasRepeatedTrailingCharsCS(1)

	def RepeatedTrailingCharsCS(pCaseSensitive)
		cStr = @oString.Content()
		nLen = @oString.NumberOfChars()
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

	def RepeatedTrailingChar()
		cTrail = This.RepeatedTrailingChars()
		if len(cTrail) > 0
			return cTrail[len(cTrail)]
		else
			return ""
		ok

	def NumberOfRepeatedTrailingChars()
		return len(This.RepeatedTrailingChars())

	def TrailingChar()
		nLen = @oString.NumberOfChars()
		if nLen > 0
			return @oString.Content()[nLen]
		ok
		return ""

	  #======================================================#
	 #   REMOVING REPEATED LEADING / TRAILING CHARS         #
	#======================================================#

	def RemoveRepeatedLeadingChars()
		cLead = This.RepeatedLeadingChars()
		nToRemove = len(cLead) - 1
		if nToRemove > 0
			@oString.RemoveSection(1, nToRemove)
		ok

		def RemoveRepeatedLeadingCharsQ()
			This.RemoveRepeatedLeadingChars()
			return This

	def RepeatedLeadingCharsRemoved()
		_oCopy_ = new stzStringLeadTrail(@oString.Content())
		_oCopy_.RemoveRepeatedLeadingCharsQ()
		return _oCopy_.Content()

	#--

	def RemoveRepeatedTrailingChars()
		cTrail = This.RepeatedTrailingChars()
		nToRemove = len(cTrail) - 1
		nLen = @oString.NumberOfChars()
		if nToRemove > 0
			@oString.RemoveSection(nLen - nToRemove + 1, nLen)
		ok

		def RemoveRepeatedTrailingCharsQ()
			This.RemoveRepeatedTrailingChars()
			return This

	def RepeatedTrailingCharsRemoved()
		_oCopy_ = new stzStringLeadTrail(@oString.Content())
		_oCopy_.RemoveRepeatedTrailingCharsQ()
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING A SPECIFIC LEADING / TRAILING CHAR        #
	#======================================================#

	def RemoveThisLeadingCharCS(c, pCaseSensitive)
		cStr = @oString.Content()
		nLen = len(cStr)
		nStart = 1
		for i = 1 to nLen
			if BothStringsAreEqualCS(cStr[i], c, pCaseSensitive)
				nStart = i + 1
			else
				exit
			ok
		next
		if nStart > nLen
			@oString.Update("")
		else
			@oString.Update(StzStringQ(cStr).Section(nStart, nLen))
		ok

		def RemoveThisLeadingCharCSQ(c, pCaseSensitive)
			This.RemoveThisLeadingCharCS(c, pCaseSensitive)
			return This

		def RemoveLeadingCharCS(c, pCaseSensitive)
			This.RemoveThisLeadingCharCS(c, pCaseSensitive)

	def RemoveThisLeadingChar(c)
		This.RemoveThisLeadingCharCS(c, 1)

		def RemoveLeadingChar(c)
			This.RemoveThisLeadingChar(c)

	#--

	def RemoveThisTrailingCharCS(c, pCaseSensitive)
		cStr = @oString.Content()
		nLen = len(cStr)
		nEnd = nLen
		for i = nLen to 1 step -1
			if BothStringsAreEqualCS(cStr[i], c, pCaseSensitive)
				nEnd = i - 1
			else
				exit
			ok
		next
		if nEnd < 1
			@oString.Update("")
		else
			@oString.Update(StzStringQ(cStr).Section(1, nEnd))
		ok

		def RemoveThisTrailingCharCSQ(c, pCaseSensitive)
			This.RemoveThisTrailingCharCS(c, pCaseSensitive)
			return This

		def RemoveTrailingCharCS(c, pCaseSensitive)
			This.RemoveThisTrailingCharCS(c, pCaseSensitive)

	def RemoveThisTrailingChar(c)
		This.RemoveThisTrailingCharCS(c, 1)

		def RemoveTrailingChar(c)
			This.RemoveThisTrailingChar(c)

	  #======================================================#
	 #   REMOVING LEADING AND TRAILING AT ONCE              #
	#======================================================#

	def RemoveThisLeadingAndTrailingCharCS(c, pCaseSensitive)
		This.RemoveThisLeadingCharCS(c, pCaseSensitive)
		This.RemoveThisTrailingCharCS(c, pCaseSensitive)

		def RemoveThisLeadingAndTrailingCharCSQ(c, pCaseSensitive)
			This.RemoveThisLeadingAndTrailingCharCS(c, pCaseSensitive)
			return This

	def RemoveThisLeadingAndTrailingChar(c)
		This.RemoveThisLeadingAndTrailingCharCS(c, 1)

		def RemoveThisLeadingAndTrailingCharQ(c)
			This.RemoveThisLeadingAndTrailingChar(c)
			return This

	  #======================================================#
	 #   CHECKING STARTS WITH / ENDS WITH                   #
	#======================================================#

	def StartsWithCS(pcSubStr, pCaseSensitive)
		nLen = len(pcSubStr)
		if nLen > @oString.NumberOfChars()
			return 0
		ok
		cLeft = @oString.NLeftChars(nLen)
		return BothStringsAreEqualCS(cLeft, pcSubStr, pCaseSensitive)

	def StartsWith(pcSubStr)
		return This.StartsWithCS(pcSubStr, 1)

	def EndsWithCS(pcSubStr, pCaseSensitive)
		nLen = len(pcSubStr)
		if nLen > @oString.NumberOfChars()
			return 0
		ok
		cRight = @oString.NRightChars(nLen)
		return BothStringsAreEqualCS(cRight, pcSubStr, pCaseSensitive)

	def EndsWith(pcSubStr)
		return This.EndsWithCS(pcSubStr, 1)

	  #======================================================#
	 #   REMOVING FROM START / END                          #
	#======================================================#

	def RemoveFromStartCS(pcSubStr, pCaseSensitive)
		if This.StartsWithCS(pcSubStr, pCaseSensitive)
			pH = @oString.Engine()
			pR = StzEngineStringRemovePrefix(pH, pcSubStr)
			c = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			@oString.Update(c)
		ok

		def RemoveFromStartCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromStartCS(pcSubStr, pCaseSensitive)
			return This

	def RemoveFromStart(pcSubStr)
		This.RemoveFromStartCS(pcSubStr, 1)

		def RemoveFromStartQ(pcSubStr)
			This.RemoveFromStart(pcSubStr)
			return This

	def RemovedFromStartCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringLeadTrail(@oString.Content())
		_oCopy_.RemoveFromStartCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def RemovedFromStart(pcSubStr)
		return This.RemovedFromStartCS(pcSubStr, 1)

	#--

	def RemoveFromEndCS(pcSubStr, pCaseSensitive)
		if This.EndsWithCS(pcSubStr, pCaseSensitive)
			pH = @oString.Engine()
			pR = StzEngineStringRemoveSuffix(pH, pcSubStr)
			c = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			@oString.Update(c)
		ok

		def RemoveFromEndCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromEndCS(pcSubStr, pCaseSensitive)
			return This

	def RemoveFromEnd(pcSubStr)
		This.RemoveFromEndCS(pcSubStr, 1)

		def RemoveFromEndQ(pcSubStr)
			This.RemoveFromEnd(pcSubStr)
			return This

	def RemovedFromEndCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringLeadTrail(@oString.Content())
		_oCopy_.RemoveFromEndCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def RemovedFromEnd(pcSubStr)
		return This.RemovedFromEndCS(pcSubStr, 1)
