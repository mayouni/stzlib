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
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		if _nLen_ < 2
			return ""
		ok
		_cFirst_ = _acChars_[1]
		_cResult_ = _cFirst_
		for i = 2 to _nLen_
			if _acChars_[i] = _cFirst_
				_cResult_ += _acChars_[i]
			else
				exit
			ok
		next
		_nResultChars_ = StzLen(_cResult_)
		if _nResultChars_ < 2
			return ""
		ok
		return _cResult_

	def RepeatedLeadingChars()
		return This.RepeatedLeadingCharsCS(1)

	def RepeatedLeadingChar()
		_cLead_ = This.RepeatedLeadingChars()
		if StzLen(_cLead_) > 0
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
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		if _nLen_ < 2
			return ""
		ok
		_cLast_ = _acChars_[_nLen_]
		_cResult_ = _cLast_
		for i = _nLen_ - 1 to 1 step -1
			if _acChars_[i] = _cLast_
				_cResult_ = _acChars_[i] + _cResult_
			else
				exit
			ok
		next
		_nResultChars_ = StzLen(_cResult_)
		if _nResultChars_ < 2
			return ""
		ok
		return _cResult_

	def RepeatedTrailingChars()
		return This.RepeatedTrailingCharsCS(1)

	def RepeatedTrailingChar()
		_cTrail_ = This.RepeatedTrailingChars()
		_nTrailLen_ = StzLen(_cTrail_)
		if _nTrailLen_ > 0
			return @oString.NthChar(@oString.NumberOfChars())
		else
			return ""
		ok

	def NumberOfRepeatedTrailingChars()
		return StzLen(This.RepeatedTrailingChars())

	def TrailingChar()
		_nLen_ = @oString.NumberOfChars()
		if _nLen_ > 0
			return @oString.NthChar(_nLen_)
		ok
		return ""

	  #======================================================#
	 #   REMOVING REPEATED LEADING / TRAILING CHARS         #
	#======================================================#

	def RemoveRepeatedLeadingChars()
		_cLead_ = This.RepeatedLeadingChars()
		_nToRemove_ = StzLen(_cLead_) - 1
		if _nToRemove_ > 0
			@oString.RemoveSection(1, _nToRemove_)
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
		_cTrail_ = This.RepeatedTrailingChars()
		_nToRemove_ = StzLen(_cTrail_) - 1
		_nLen_ = @oString.NumberOfChars()
		if _nToRemove_ > 0
			@oString.RemoveSection(_nLen_ - _nToRemove_ + 1, _nLen_)
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

	def RemoveThisLeadingCharCS(_c_, pCaseSensitive)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_nStart_ = 1
		for i = 1 to _nLen_
			if BothStringsAreEqualCS(_acChars_[i], _c_, pCaseSensitive)
				_nStart_ = i + 1
			else
				exit
			ok
		next
		if _nStart_ > _nLen_
			@oString.Update("")
		else
			@oString.Update(@oString.Section(_nStart_, _nLen_))
		ok

		def RemoveThisLeadingCharCSQ(_c_, pCaseSensitive)
			This.RemoveThisLeadingCharCS(_c_, pCaseSensitive)
			return This

		def RemoveLeadingCharCS(_c_, pCaseSensitive)
			This.RemoveThisLeadingCharCS(_c_, pCaseSensitive)

	def RemoveThisLeadingChar(_c_)
		This.RemoveThisLeadingCharCS(_c_, 1)

		def RemoveLeadingChar(_c_)
			This.RemoveThisLeadingChar(_c_)

	#--

	def RemoveThisTrailingCharCS(_c_, pCaseSensitive)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_nEnd_ = _nLen_
		for i = _nLen_ to 1 step -1
			if BothStringsAreEqualCS(_acChars_[i], _c_, pCaseSensitive)
				_nEnd_ = i - 1
			else
				exit
			ok
		next
		if _nEnd_ < 1
			@oString.Update("")
		else
			@oString.Update(@oString.Section(1, _nEnd_))
		ok

		def RemoveThisTrailingCharCSQ(_c_, pCaseSensitive)
			This.RemoveThisTrailingCharCS(_c_, pCaseSensitive)
			return This

		def RemoveTrailingCharCS(_c_, pCaseSensitive)
			This.RemoveThisTrailingCharCS(_c_, pCaseSensitive)

	def RemoveThisTrailingChar(_c_)
		This.RemoveThisTrailingCharCS(_c_, 1)

		def RemoveTrailingChar(_c_)
			This.RemoveThisTrailingChar(_c_)

	  #======================================================#
	 #   REMOVING LEADING AND TRAILING AT ONCE              #
	#======================================================#

	def RemoveThisLeadingAndTrailingCharCS(_c_, pCaseSensitive)
		This.RemoveThisLeadingCharCS(_c_, pCaseSensitive)
		This.RemoveThisTrailingCharCS(_c_, pCaseSensitive)

		def RemoveThisLeadingAndTrailingCharCSQ(_c_, pCaseSensitive)
			This.RemoveThisLeadingAndTrailingCharCS(_c_, pCaseSensitive)
			return This

	def RemoveThisLeadingAndTrailingChar(_c_)
		This.RemoveThisLeadingAndTrailingCharCS(_c_, 1)

		def RemoveThisLeadingAndTrailingCharQ(_c_)
			This.RemoveThisLeadingAndTrailingChar(_c_)
			return This

	  #======================================================#
	 #   CHECKING STARTS WITH / ENDS WITH                   #
	#======================================================#

	def StartsWithCS(pcSubStr, pCaseSensitive)
		_nLen_ = StzLen(pcSubStr)
		if _nLen_ > @oString.NumberOfChars()
			return 0
		ok
		_cLeft_ = @oString.NLeftChars(_nLen_)
		return BothStringsAreEqualCS(_cLeft_, pcSubStr, pCaseSensitive)

	def StartsWith(pcSubStr)
		return This.StartsWithCS(pcSubStr, 1)

	def EndsWithCS(pcSubStr, pCaseSensitive)
		_nLen_ = StzLen(pcSubStr)
		if _nLen_ > @oString.NumberOfChars()
			return 0
		ok
		_cRight_ = @oString.NRightChars(_nLen_)
		return BothStringsAreEqualCS(_cRight_, pcSubStr, pCaseSensitive)

	def EndsWith(pcSubStr)
		return This.EndsWithCS(pcSubStr, 1)

	  #======================================================#
	 #   REMOVING FROM START / END                          #
	#======================================================#

	def RemoveFromStartCS(pcSubStr, pCaseSensitive)
		if This.StartsWithCS(pcSubStr, pCaseSensitive)
			pH = @oString.Engine()
			pR = StzEngineStringRemovePrefix(pH, pcSubStr)
			_c_ = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			@oString.Update(_c_)
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
			_c_ = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			@oString.Update(_c_)
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
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

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
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def PrefixEnsured(pcPrefix)
		return This.PrefixEnsuredCS(pcPrefix, 1)

	def EnsureSuffixCS(pcSuffix, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringEnsureSuffixCS(pH, pcSuffix, _bCase_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

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
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def SuffixEnsured(pcSuffix)
		return This.SuffixEnsuredCS(pcSuffix, 1)

	def RemoveRepeatedLeadingCharsCS(pCaseSensitive)
		@oString.RemoveLeadingChars()

	def RemoveRepeatedTrailingCharsCS(pCaseSensitive)
		@oString.RemoveTrailingChars()
