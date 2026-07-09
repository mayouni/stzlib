#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGDUPLICATES           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String duplicates -- Wraps stzString via    #
#                composition. Duplicate detection, consecutive #
#                char management, deduplication operations.    #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringDuplicates from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringDuplicates! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     DUPLICATE CHARS           #
	#===============================#

	def DuplicatedChars()
		pH = @oString.Engine()
		pR = StzEngineStringDuplicatedChars(pH)
		_cDups_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _SplitNullDelimited(_cDups_)

	def HasDuplicatedChars()
		return len(This.DuplicatedChars()) > 0

	def NumberOfDuplicatedChars()
		return len(This.DuplicatedChars())

	  #===============================#
	 #     UNIQUE CHARS              #
	#===============================#

	def UniqueChars()
		pH = @oString.Engine()
		pR = StzEngineStringUniqueChars(pH)
		_cUnique_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		if _cUnique_ = ""
			return []
		ok
		# Split unique chars string into individual characters
		pU = StzEngineString(_cUnique_)
		pSplit = StzEngineStringCharsSplit(pU)
		_cJoined_ = StzEngineStringData(pSplit)
		StzEngineStringFree(pSplit)
		StzEngineStringFree(pU)
		return _SplitNullDelimited(_cJoined_)

	def NumberOfUniqueChars()
		pH = @oString.Engine()
		return StzEngineStringCountUniqueChars(pH)

	  #===============================#
	 #     CONSECUTIVE CHARS         #
	#===============================#

	def HasConsecutiveDuplicates()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		if _nLen_ < 2
			return 0
		ok

		for i = 2 to _nLen_
			if _acChars_[i] = _acChars_[i - 1]
				return 1
			ok
		next

		return 0

	def RemoveConsecutiveDuplicateChars()
		pH = @oString.Engine()
		pR = StzEngineStringRemoveConsecutiveDuplicates(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveConsecutiveDuplicateCharsQ()
			This.RemoveConsecutiveDuplicateChars()
			return This

	def ConsecutiveDuplicateCharsRemoved()
		pH = @oString.Engine()
		pR = StzEngineStringRemoveConsecutiveDuplicates(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     REMOVE ALL DUPLICATES     #
	#===============================#

	def RemoveAllDuplicateChars()
		pH = @oString.Engine()
		pR = StzEngineStringUniqueChars(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveAllDuplicateCharsQ()
			This.RemoveAllDuplicateChars()
			return This

	def AllDuplicateCharsRemoved()
		pH = @oString.Engine()
		pR = StzEngineStringUniqueChars(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     DEDUPLICATE SUBSTRINGS    #
	#===============================#

	def RemoveDuplicateSubStringCS(pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(pcSubStr, pCaseSensitive)
		if len(_anPos_) <= 1
			return
		ok

		_nLenSub_ = StzLen(pcSubStr)

		# Remove from end to start to preserve earlier positions
		for i = len(_anPos_) to 2 step -1
			_nPos_ = _anPos_[i]
			@oString.RemoveSection(_nPos_, _nPos_ + _nLenSub_ - 1)
		next

		def RemoveDuplicateSubStringCSQ(pcSubStr, pCaseSensitive)
			This.RemoveDuplicateSubStringCS(pcSubStr, pCaseSensitive)
			return This

	def RemoveDuplicateSubString(pcSubStr)
		This.RemoveDuplicateSubStringCS(pcSubStr, 1)

		def RemoveDuplicateSubStringQ(pcSubStr)
			This.RemoveDuplicateSubString(pcSubStr)
			return This

	def DuplicateSubStringRemovedCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringDuplicates(@oString.Content())
		_oCopy_.RemoveDuplicateSubStringCS(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def DuplicateSubStringRemoved(pcSubStr)
		return This.DuplicateSubStringRemovedCS(pcSubStr, 1)
