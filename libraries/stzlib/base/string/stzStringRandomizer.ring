#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGRANDOMIZER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String randomizer -- Wraps stzString via    #
#                  composition. Shuffling, random char/substr  #
#                  extraction, random generation operations.   #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringRandomizer from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringRandomizer! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     SHUFFLE                   #
	#===============================#

	def Shuffle()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)

		for i = _nLen_ to 2 step -1
			_j_ = random(i - 1) + 1
			_cTemp_ = _acChars_[i]
			_acChars_[i] = _acChars_[_j_]
			_acChars_[_j_] = _cTemp_
		next

		_cResult_ = ""
		for i = 1 to _nLen_
			_cResult_ += _acChars_[i]
		next

		@oString.Update(_cResult_)

		def ShuffleQ()
			This.Shuffle()
			return This

	def Shuffled()
		_oCopy_ = new stzStringRandomizer(@oString.Content())
		_oCopy_.Shuffle()
		return _oCopy_.Content()

	  #===============================#
	 #     RANDOM CHAR               #
	#===============================#

	def RandomChar()
		_nLen_ = @oString.NumberOfChars()
		if _nLen_ = 0
			return ""
		ok
		_n_ = random(_nLen_ - 1) + 1
		return @oString.NthChar(_n_)

	def RandomChars(_n_)
		_acResult_ = []
		for i = 1 to _n_
			_acResult_ + This.RandomChar()
		next
		return _acResult_

	def NRandomChars(_n_)
		# Returns n unique random chars (no duplicates)
		_acChars_ = @oString.Chars()

		# Build list of unique chars in the string
		_acUnique_ = []
		_nLen_ = len(_acChars_)
		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			if StzFindFirst(_acUnique_, _c_) = 0
				_acUnique_ + _c_
			ok
		next

		_nAvailable_ = len(_acUnique_)
		if _n_ > _nAvailable_
			_n_ = _nAvailable_
		ok

		# Shuffle unique chars and take first n
		for i = _nAvailable_ to 2 step -1
			_j_ = random(i - 1) + 1
			_cTemp_ = _acUnique_[i]
			_acUnique_[i] = _acUnique_[_j_]
			_acUnique_[_j_] = _cTemp_
		next

		_acResult_ = []
		for i = 1 to _n_
			_acResult_ + _acUnique_[i]
		next

		return _acResult_

	  #===============================#
	 #     RANDOM SECTION            #
	#===============================#

	def RandomSection(_nLen_)
		_nMax_ = @oString.NumberOfChars()
		if _nLen_ > _nMax_
			_nLen_ = _nMax_
		ok
		if _nLen_ <= 0
			return ""
		ok

		_nStart_ = random(_nMax_ - _nLen_) + 1
		return @oString.Section(_nStart_, _nStart_ + _nLen_ - 1)

		def RandomSubString(_nLen_)
			return This.RandomSection(_nLen_)

	  #===============================#
	 #     RANDOM WORD               #
	#===============================#

	def RandomWord()
		_cContent_ = @oString.Content()
		_acWords_ = split(_cContent_, " ")
		_nLen_ = len(_acWords_)
		if _nLen_ = 0
			return ""
		ok
		_n_ = random(_nLen_ - 1) + 1
		return _acWords_[_n_]

	  #===============================#
	 #     SHUFFLE WORDS             #
	#===============================#

	def ShuffleWords()
		_cContent_ = @oString.Content()
		_acWords_ = split(_cContent_, " ")
		_nLen_ = len(_acWords_)

		for i = _nLen_ to 2 step -1
			_j_ = random(i - 1) + 1
			_cTemp_ = _acWords_[i]
			_acWords_[i] = _acWords_[_j_]
			_acWords_[_j_] = _cTemp_
		next

		_cResult_ = ""
		for i = 1 to _nLen_
			if i > 1
				_cResult_ += " "
			ok
			_cResult_ += _acWords_[i]
		next

		@oString.Update(_cResult_)

		def ShuffleWordsQ()
			This.ShuffleWords()
			return This

	def WordsShuffled()
		_oCopy_ = new stzStringRandomizer(@oString.Content())
		_oCopy_.ShuffleWords()
		return _oCopy_.Content()

	  #===============================#
	 #     RANDOM CASE               #
	#===============================#

	def RandomCase()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_cResult_ = ""

		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			if random(1) = 1
				_cResult_ += StzUpper(_c_)
			else
				_cResult_ += StzLower(_c_)
			ok
		next

		@oString.Update(_cResult_)

		def RandomCaseQ()
			This.RandomCase()
			return This

	def RandomCased()
		_oCopy_ = new stzStringRandomizer(@oString.Content())
		_oCopy_.RandomCase()
		return _oCopy_.Content()

	  #===============================#
	 #     RANDOM INSERT             #
	#===============================#

	def RandomInsert(cStr)
		_nLen_ = @oString.NumberOfChars()
		_nPos_ = random(_nLen_) + 1

		if _nPos_ > _nLen_
			@oString.Update(@oString.Content() + cStr)
		else
			_oInserter_ = new stzStringInserter(@oString)
			_oInserter_.InsertBefore(_nPos_, cStr)
		ok

	  #===============================#
	 #     RANDOM REMOVE             #
	#===============================#

	def RandomRemove(_n_)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		if _n_ >= _nLen_
			@oString.Update("")
			return
		ok

		# Build list of char indices
		_anIndices_ = []
		for i = 1 to _nLen_
			_anIndices_ + i
		next

		# Pick n random indices to remove (shuffle and take first n)
		for i = _nLen_ to 2 step -1
			_j_ = random(i - 1) + 1
			_nTemp_ = _anIndices_[i]
			_anIndices_[i] = _anIndices_[_j_]
			_anIndices_[_j_] = _nTemp_
		next

		# Collect indices to remove
		_anRemove_ = []
		for i = 1 to _n_
			_anRemove_ + _anIndices_[i]
		next

		# Build result keeping chars not in remove list
		_cResult_ = ""
		for i = 1 to _nLen_
			if StzFindFirst(_anRemove_, i) = 0
				_cResult_ += _acChars_[i]
			ok
		next

		@oString.Update(_cResult_)
