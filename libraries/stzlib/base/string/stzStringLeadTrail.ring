#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGLEADTRAIL          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String lead/trail subclass -- repeated      #
#                  leading and trailing char operations.       #
#                  For aliases, use stzStringLeadTrailXT.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringLeadTrail from stzObject

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
		return StzLen(This.RepeatedLeadingCharsCS(pCaseSensitive)) > 1

	def HasRepeatedLeadingChars()
		return This.HasRepeatedLeadingCharsCS(1)

	def RepeatedLeadingCharsCS(pCaseSensitive)
		acChars = @oString.Chars()
		nLen = len(acChars)
		if nLen < 2
			return ""
		ok
		cFirst = acChars[1]
		cResult = cFirst
		for i = 2 to nLen
			if acChars[i] = cFirst
				cResult += acChars[i]
			else
				exit
			ok
		next
		nResultChars = StzLen(cResult)
		if nResultChars < 2
			return ""
		ok
		return cResult

	def RepeatedLeadingChars()
		return This.RepeatedLeadingCharsCS(1)

	def RepeatedLeadingChar()
		cLead = This.RepeatedLeadingChars()
		if StzLen(cLead) > 0
			return @oString.NthChar(1)
		else
			return ""
		ok

	def NumberOfRepeatedLeadingChars()
		return StzLen(This.RepeatedLeadingChars())

	def LeadingChar()
		if @oString.NumberOfChars() > 0
			return @oString.NthChar(1)
		ok
		return ""

	  #======================================================#
	 #   REPEATED TRAILING CHARS                            #
	#======================================================#

	def HasRepeatedTrailingCharsCS(pCaseSensitive)
		return StzLen(This.RepeatedTrailingCharsCS(pCaseSensitive)) > 1

	def HasRepeatedTrailingChars()
		return This.HasRepeatedTrailingCharsCS(1)

	def RepeatedTrailingCharsCS(pCaseSensitive)
		acChars = @oString.Chars()
		nLen = len(acChars)
		if nLen < 2
			return ""
		ok
		cLast = acChars[nLen]
		cResult = cLast
		for i = nLen - 1 to 1 step -1
			if acChars[i] = cLast
				cResult = acChars[i] + cResult
			else
				exit
			ok
		next
		nResultChars = StzLen(cResult)
		if nResultChars < 2
			return ""
		ok
		return cResult

	def RepeatedTrailingChars()
		return This.RepeatedTrailingCharsCS(1)

	def RepeatedTrailingChar()
		cTrail = This.RepeatedTrailingChars()
		nTrailLen = StzLen(cTrail)
		if nTrailLen > 0
			return @oString.NthChar(@oString.NumberOfChars())
		else
			return ""
		ok

	def NumberOfRepeatedTrailingChars()
		return StzLen(This.RepeatedTrailingChars())

	def TrailingChar()
		nLen = @oString.NumberOfChars()
		if nLen > 0
			return @oString.NthChar(nLen)
		ok
		return ""

	  #======================================================#
	 #   REMOVING REPEATED LEADING / TRAILING CHARS         #
	#======================================================#

	def RemoveRepeatedLeadingChars()
		cLead = This.RepeatedLeadingChars()
		nToRemove = StzLen(cLead) - 1
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
		nToRemove = StzLen(cTrail) - 1
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
		acChars = @oString.Chars()
		nLen = len(acChars)
		nStart = 1
		for i = 1 to nLen
			if BothStringsAreEqualCS(acChars[i], c, pCaseSensitive)
				nStart = i + 1
			else
				exit
			ok
		next
		if nStart > nLen
			@oString.Update("")
		else
			@oString.Update(@oString.Section(nStart, nLen))
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
		acChars = @oString.Chars()
		nLen = len(acChars)
		nEnd = nLen
		for i = nLen to 1 step -1
			if BothStringsAreEqualCS(acChars[i], c, pCaseSensitive)
				nEnd = i - 1
			else
				exit
			ok
		next
		if nEnd < 1
			@oString.Update("")
		else
			@oString.Update(@oString.Section(1, nEnd))
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
		nLen = StzLen(pcSubStr)
		if nLen > @oString.NumberOfChars()
			return 0
		ok
		cLeft = @oString.NLeftChars(nLen)
		return BothStringsAreEqualCS(cLeft, pcSubStr, pCaseSensitive)

	def StartsWith(pcSubStr)
		return This.StartsWithCS(pcSubStr, 1)

	def EndsWithCS(pcSubStr, pCaseSensitive)
		nLen = StzLen(pcSubStr)
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

	  #======================================================#
	 #   ENSURE PREFIX / SUFFIX                             #
	#======================================================#

	def EnsurePrefixCS(pcPrefix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringEnsurePrefixCS(pH, pcPrefix, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def EnsurePrefixCSQ(pcPrefix, pCaseSensitive)
			This.EnsurePrefixCS(pcPrefix, pCaseSensitive)
			return This

	def EnsurePrefix(pcPrefix)
		This.EnsurePrefixCS(pcPrefix, 1)

		def EnsurePrefixQ(pcPrefix)
			This.EnsurePrefix(pcPrefix)
			return This

	def PrefixEnsuredCS(pcPrefix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringEnsurePrefixCS(pH, pcPrefix, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	def PrefixEnsured(pcPrefix)
		return This.PrefixEnsuredCS(pcPrefix, 1)

	def EnsureSuffixCS(pcSuffix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringEnsureSuffixCS(pH, pcSuffix, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def EnsureSuffixCSQ(pcSuffix, pCaseSensitive)
			This.EnsureSuffixCS(pcSuffix, pCaseSensitive)
			return This

	def EnsureSuffix(pcSuffix)
		This.EnsureSuffixCS(pcSuffix, 1)

		def EnsureSuffixQ(pcSuffix)
			This.EnsureSuffix(pcSuffix)
			return This

	def SuffixEnsuredCS(pcSuffix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringEnsureSuffixCS(pH, pcSuffix, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	def SuffixEnsured(pcSuffix)
		return This.SuffixEnsuredCS(pcSuffix, 1)

	def RemoveRepeatedLeadingCharsCS(pCaseSensitive)
		@oString.RemoveLeadingChars()

	def RemoveRepeatedTrailingCharsCS(pCaseSensitive)
		@oString.RemoveTrailingChars()
