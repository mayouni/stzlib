#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGWORDS             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String words -- Wraps stzString via         #
#                  composition. Word extraction, counting,     #
#                  unique words, word-level ops.               #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringWords from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringWords! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     WORDS                     #
	#===============================#

	def Words()
		pH = @oString.Engine()
		pR = StzEngineStringWordsSplit(pH)
		_cJoined_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _SplitNullDelimited(_cJoined_)

		def WordsQ()
			return new stzList(This.Words())

	  #===============================#
	 #     NUMBER OF WORDS           #
	#===============================#

	def NumberOfWords()
		return StzEngineStringCountWords(@oString.Engine())

		def CountWords()
			return This.NumberOfWords()

		def HowManyWords()
			return This.NumberOfWords()

	  #===============================#
	 #     NTH WORD                  #
	#===============================#

	def NthWord(_n_)
		pH = @oString.Engine()
		pR = StzEngineStringNthWord(pH, _n_)
		if pR != NULL
			_c_ = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			return _c_
		ok
		StzRaise("Index out of range!")

		def Word(_n_)
			return This.NthWord(_n_)

	def FirstWord()
		return This.NthWord(1)

	def LastWord()
		return This.NthWord(This.NumberOfWords())

	  #===============================#
	 #     FIRST/LAST N WORDS       #
	#===============================#

	def NFirstWords(_n_)
		_acWords_ = This.Words()
		_nTotal_ = len(_acWords_)
		if _n_ > _nTotal_
			_n_ = _nTotal_
		ok

		_acResult_ = []
		for i = 1 to _n_
			_acResult_ + _acWords_[i]
		next
		return _acResult_

	def NLastWords(_n_)
		_acWords_ = This.Words()
		_nTotal_ = len(_acWords_)
		if _n_ > _nTotal_
			_n_ = _nTotal_
		ok

		_acResult_ = []
		_nStart_ = _nTotal_ - _n_ + 1
		for i = _nStart_ to _nTotal_
			_acResult_ + _acWords_[i]
		next
		return _acResult_

	  #===============================#
	 #     WORD AT POSITION          #
	#===============================#

	def WordAtPosition(_n_)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)

		if _n_ < 1 or _n_ > _nLen_
			StzRaise("Position out of range!")
		ok

		_nWordIndex_ = 0
		_bInWord_ = 0
		_cWord_ = ""

		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			_bIsSpace_ = (_c_ = " " or _c_ = StzChar(9) or _c_ = StzChar(10) or _c_ = StzChar(13))

			if NOT _bIsSpace_
				if NOT _bInWord_
					_nWordIndex_++
					_bInWord_ = 1
					_cWord_ = ""
				ok
				_cWord_ += _c_
			else
				if _bInWord_
					_bInWord_ = 0
				ok
			ok

			if i = _n_
				if _bIsSpace_
					return ""
				else
					# Finish reading the rest of this word
					for j = i + 1 to _nLen_
						_cNext_ = _acChars_[j]
						if _cNext_ = " " or _cNext_ = StzChar(9) or _cNext_ = StzChar(10) or _cNext_ = StzChar(13)
							exit
						ok
						_cWord_ += _cNext_
					next
					return _cWord_
				ok
			ok
		next

		return ""

	  #===============================#
	 #     UNIQUE WORDS              #
	#===============================#

	def UniqueWordsCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringUniqueWordsCS(pH, _bCase_)
		_cResult_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)

		if _cResult_ = ""
			return []
		ok

		return split(_cResult_, " ")

	def UniqueWords()
		return This.UniqueWordsCS(1)

		def WordsU()
			return This.UniqueWords()

	  #===============================#
	 #     LONGEST / SHORTEST WORD   #
	#===============================#

	def LongestWord()
		_acWords_ = This.Words()
		_nTotal_ = len(_acWords_)
		if _nTotal_ = 0
			return ""
		ok

		_cLongest_ = _acWords_[1]
		for i = 2 to _nTotal_
			if StzLen(_acWords_[i]) > StzLen(_cLongest_)
				_cLongest_ = _acWords_[i]
			ok
		next
		return _cLongest_

	def ShortestWord()
		_acWords_ = This.Words()
		_nTotal_ = len(_acWords_)
		if _nTotal_ = 0
			return ""
		ok

		_cShortest_ = _acWords_[1]
		for i = 2 to _nTotal_
			if StzLen(_acWords_[i]) < StzLen(_cShortest_)
				_cShortest_ = _acWords_[i]
			ok
		next
		return _cShortest_

	def AverageWordLength()
		_acWords_ = This.Words()
		_nTotal_ = len(_acWords_)
		if _nTotal_ = 0
			return 0
		ok

		_nSum_ = 0
		for i = 1 to _nTotal_
			_nSum_ += StzLen(_acWords_[i])
		next
		return _nSum_ / _nTotal_

	  #===============================#
	 #     WORD FREQUENCIES          #
	#===============================#

	def WordFrequencies()
		_acWords_ = This.Words()
		_nTotal_ = len(_acWords_)
		_acUnique_ = []
		_anCounts_ = []

		for i = 1 to _nTotal_
			_cLow_ = StzCaseFold(_acWords_[i])
			_bFound_ = 0
			_nULen_ = len(_acUnique_)
			for j = 1 to _nULen_
				if StzCaseFold(_acUnique_[j]) = _cLow_
					_anCounts_[j] = _anCounts_[j] + 1
					_bFound_ = 1
					exit
				ok
			next
			if NOT _bFound_
				_acUnique_ + _acWords_[i]
				_anCounts_ + 1
			ok
		next

		_aResult_ = []
		_nULen_ = len(_acUnique_)
		for i = 1 to _nULen_
			_aResult_ + [_acUnique_[i], _anCounts_[i]]
		next
		return _aResult_

	def MostFrequentWord()
		_aFreqs_ = This.WordFrequencies()
		_nFLen_ = len(_aFreqs_)
		if _nFLen_ = 0
			return ""
		ok

		_cBest_ = _aFreqs_[1][1]
		_nBest_ = _aFreqs_[1][2]
		for i = 2 to _nFLen_
			if _aFreqs_[i][2] > _nBest_
				_nBest_ = _aFreqs_[i][2]
				_cBest_ = _aFreqs_[i][1]
			ok
		next
		return _cBest_

	  #===============================#
	 #     WORD EXISTS               #
	#===============================#

	def ContainsWordCS(pcWord, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_acWords_ = This.Words()
		_nLen_ = len(_acWords_)

		for i = 1 to _nLen_
			if _bCase_
				if _acWords_[i] = pcWord
					return 1
				ok
			else
				if StzCaseFold(_acWords_[i]) = StzCaseFold(pcWord)
					return 1
				ok
			ok
		next
		return 0

	def ContainsWord(pcWord)
		return This.ContainsWordCS(pcWord, 1)

	  #===============================#
	 #     REPLACE WORD              #
	#===============================#

	def ReplaceWordCS(pcOldWord, pcNewWord, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_acWords_ = This.Words()
		_nLen_ = len(_acWords_)
		_acResult_ = []

		for i = 1 to _nLen_
			if _bCase_
				if _acWords_[i] = pcOldWord
					_acResult_ + pcNewWord
				else
					_acResult_ + _acWords_[i]
				ok
			else
				if StzCaseFold(_acWords_[i]) = StzCaseFold(pcOldWord)
					_acResult_ + pcNewWord
				else
					_acResult_ + _acWords_[i]
				ok
			ok
		next

		_cResult_ = ""
		_nResLen_ = len(_acResult_)
		for i = 1 to _nResLen_
			if i > 1
				_cResult_ += " "
			ok
			_cResult_ += _acResult_[i]
		next

		@oString.Update(_cResult_)

		def ReplaceWordCSQ(pcOldWord, pcNewWord, pCaseSensitive)
			This.ReplaceWordCS(pcOldWord, pcNewWord, pCaseSensitive)
			return This

	def ReplaceWord(pcOldWord, pcNewWord)
		This.ReplaceWordCS(pcOldWord, pcNewWord, 1)

		def ReplaceWordQ(pcOldWord, pcNewWord)
			This.ReplaceWord(pcOldWord, pcNewWord)
			return This

	  #===============================#
	 #     REMOVE WORD               #
	#===============================#

	def RemoveWordCS(pcWord, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_acWords_ = This.Words()
		_nLen_ = len(_acWords_)
		_acResult_ = []

		for i = 1 to _nLen_
			if _bCase_
				if _acWords_[i] != pcWord
					_acResult_ + _acWords_[i]
				ok
			else
				if StzCaseFold(_acWords_[i]) != StzCaseFold(pcWord)
					_acResult_ + _acWords_[i]
				ok
			ok
		next

		_cResult_ = ""
		_nResLen_ = len(_acResult_)
		for i = 1 to _nResLen_
			if i > 1
				_cResult_ += " "
			ok
			_cResult_ += _acResult_[i]
		next

		@oString.Update(_cResult_)

		def RemoveWordCSQ(pcWord, pCaseSensitive)
			This.RemoveWordCS(pcWord, pCaseSensitive)
			return This

	def RemoveWord(pcWord)
		This.RemoveWordCS(pcWord, 1)

		def RemoveWordQ(pcWord)
			This.RemoveWord(pcWord)
			return This
