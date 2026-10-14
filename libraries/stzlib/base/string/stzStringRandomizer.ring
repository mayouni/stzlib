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


# Shuffles a text and draws from it at random: characters, words, sections, random case, random removal.
#
# Build one with new stzStringRandomizer("text"). The drawing methods (RandomChar, RandomChars,
# NRandomChars, RandomSection, RandomWord) only read; the in-place verbs (Shuffle, ShuffleWords,
# RandomCase, RandomRemove) change the text held and have passive twins that return a changed copy
# (Shuffled, WordsShuffled, RandomCased). The randomness is the engine's random integer, so no two
# calls need agree; what stays fixed is what a result is made of, its length and its letters. Do not
# pass a stzString object you still need: the first in-place edit empties it. RandomInsert empties
# the text in most calls today.
#
#   receiver   o1 = new stzStringRandomizer("hello world")
#   example    ? len(o1.Shuffled())
#              #--> 11
#              ? lower(o1.RandomCased())
#              #--> hello world
#              ? len(o1.RandomChars(4))
#              #--> 4
#              ? len(o1.RandomSection(5))
#              #--> 5
#   see        stzString, stzListRandomizer
class stzStringRandomizer from stzObject

	@oString

	# Builds a randomizer over a text or over a stzString object, to shuffle it or draw characters, words and sections from it at random.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, to shuffle or draw from
	#   returns           nothing; the object is built
	#   note              any other kind of value raises "Can't create stzStringRandomizer!
	#                     Parameter must be a string or stzString object."
	#   warning           Given a stzString object, the first in-place edit (Shuffle, ShuffleWords,
	#                     RandomCase, RandomInsert, RandomRemove) leaves that stzString EMPTY while
	#                     the randomizer holds the result; the drawing methods and the passive forms
	#                     do not. Pass the text, os.Content(), to be safe
	#   see               Shuffled, RandomChar
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringRandomizer! Parameter must be a string or stzString object.")
		ok

	# Returns the text the randomizer holds, after any in-place edit.
	#
	#   returns    a text
	#   see        Shuffled
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting letters and not bytes.
	#
	#   returns    a number
	#   see        Content
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text is empty.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     SHUFFLE                   #
	#===============================#

	# Rearranges the characters of the text in a random order, in place.
	#
	#   returns    nothing; use ShuffleQ to chain
	#   note       the characters are the same and so is the length; each call gives another order
	#   see        Shuffled, ShuffleWords
	def Shuffle()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)

		for i = _nLen_ to 2 step -1
			_j_ = StzEngineRandomInt(0, i - 1) + 1
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

	# Returns the characters of the text in a random order, leaving the randomizer unchanged.
	#
	#   returns    a text of the same length and letters
	#   note       Hebrew, Arabic and emoji move as whole letters
	#   see        Shuffle
	def Shuffled()
		_oCopy_ = new stzStringRandomizer(@oString.Content())
		_oCopy_.Shuffle()
		return _oCopy_.Content()

	  #===============================#
	 #     RANDOM CHAR               #
	#===============================#

	# Returns one character of the text chosen at random.
	#
	#   returns    a one-character text; "" for an empty text
	#   see        RandomChars, NRandomChars
	def RandomChar()
		_nLen_ = @oString.NumberOfChars()
		if _nLen_ = 0
			return ""
		ok
		_n_ = StzEngineRandomInt(0, _nLen_ - 1) + 1
		return @oString.NthChar(_n_)

	# Returns n characters drawn at random, each draw independent, so a character can come up again.
	#
	#   _n_        how many draws
	#   returns    a list of n one-character texts; [ ] when n is 0 or below
	#   note       on an empty text it answers n empty texts
	#   see        NRandomChars, RandomChar
	def RandomChars(_n_)
		_acResult_ = []
		for i = 1 to _n_
			_acResult_ + This.RandomChar()
		next
		return _acResult_

	# Returns up to n different characters of the text, chosen at random, with no character twice.
	#
	#   _n_        how many distinct characters to take
	#   returns    a list of at most n one-character texts
	#   note       it draws from the DIFFERENT characters of the text, so "hello world" offers 8,
	#              and n above that returns all 8 in random order; 0 or below gives [ ]
	#   see        RandomChars
	def NRandomChars(_n_)
		# Returns n unique random chars (no duplicates)
		_acChars_ = @oString.Chars()

		# Build list of unique chars in the string
		_acUnique_ = []
		_nLen_ = len(_acChars_)
		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			if StzFindFirst(_c_, _acUnique_) = 0
				_acUnique_ + _c_
			ok
		next

		_nAvailable_ = len(_acUnique_)
		if _n_ > _nAvailable_
			_n_ = _nAvailable_
		ok

		# Shuffle unique chars and take first n
		for i = _nAvailable_ to 2 step -1
			_j_ = StzEngineRandomInt(0, i - 1) + 1
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

	# Returns a run of n consecutive characters starting at a random place.
	#
	#   _nLen_     how many characters the run holds
	#   returns    a text of n characters; shorter than n when the text is shorter, "" for n of 0 or
	#              below
	#   note       RandomSubString is the same method
	#   see        RandomChar
	def RandomSection(_nLen_)
		_nMax_ = @oString.NumberOfChars()
		if _nLen_ > _nMax_
			_nLen_ = _nMax_
		ok
		if _nLen_ <= 0
			return ""
		ok

		_nStart_ = StzEngineRandomInt(0, _nMax_ - _nLen_) + 1
		return @oString.Section(_nStart_, _nStart_ + _nLen_ - 1)

		def RandomSubString(_nLen_)
			return This.RandomSection(_nLen_)

	  #===============================#
	 #     RANDOM WORD               #
	#===============================#

	# Returns one word of the text chosen at random, words being separated by spaces.
	#
	#   returns    a text; "" for an empty text
	#   see        ShuffleWords, RandomChar
	def RandomWord()
		_cContent_ = @oString.Content()
		_acWords_ = split(_cContent_, " ")
		_nLen_ = len(_acWords_)
		if _nLen_ = 0
			return ""
		ok
		_n_ = StzEngineRandomInt(0, _nLen_ - 1) + 1
		return _acWords_[_n_]

	  #===============================#
	 #     SHUFFLE WORDS             #
	#===============================#

	# Rearranges the words of the text in a random order, in place, rejoining them with single spaces.
	#
	#   returns    nothing; use ShuffleWordsQ to chain
	#   note       repeated spaces are lost: "a  b" becomes "b a" or "a b"
	#   see        WordsShuffled, Shuffle
	def ShuffleWords()
		_cContent_ = @oString.Content()
		_acWords_ = split(_cContent_, " ")
		_nLen_ = len(_acWords_)

		for i = _nLen_ to 2 step -1
			_j_ = StzEngineRandomInt(0, i - 1) + 1
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

	# Returns the text with its words in a random order, leaving the randomizer unchanged.
	#
	#   returns    a text
	#   see        ShuffleWords
	def WordsShuffled()
		_oCopy_ = new stzStringRandomizer(@oString.Content())
		_oCopy_.ShuffleWords()
		return _oCopy_.Content()

	  #===============================#
	 #     RANDOM CASE               #
	#===============================#

	# Changes each letter to capital or small by chance, in place.
	#
	#   returns    nothing; use RandomCaseQ to chain
	#   note       scripts without case, such as Hebrew and Arabic, are unchanged
	#   see        RandomCased
	def RandomCase()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_cResult_ = ""

		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			if StzEngineRandomInt(0, 1) = 1
				_cResult_ += StzUpper(_c_)
			else
				_cResult_ += StzLower(_c_)
			ok
		next

		@oString.Update(_cResult_)

		def RandomCaseQ()
			This.RandomCase()
			return This

	# Returns the text with each letter randomly capital or small, leaving the randomizer unchanged.
	#
	#   returns    a text
	#   note       lowering the answer gives back the lowercase text
	#   see        RandomCase
	def RandomCased()
		_oCopy_ = new stzStringRandomizer(@oString.Content())
		_oCopy_.RandomCase()
		return _oCopy_.Content()

	  #===============================#
	 #     RANDOM INSERT             #
	#===============================#

	# Empties the text in most calls today instead of inserting a text at a random place.
	#
	#   cStr       the text to insert
	#   returns    nothing: the text is usually left empty
	#   warning    Empties the text instead of inserting whenever the random place falls inside it:
	#              on "hello" with "XY", 6 calls of 8 left "" and the other 2 gave "helloXY", where
	#              the place was the end; the insertion goes through a stzStringInserter built on
	#              the object itself
	#   see        RandomRemove
	def RandomInsert(cStr)
		_nLen_ = @oString.NumberOfChars()
		_nPos_ = StzEngineRandomInt(0, _nLen_) + 1

		if _nPos_ > _nLen_
			@oString.Update(@oString.Content() + cStr)
		else
			_oInserter_ = new stzStringInserter(@oString)
			_oInserter_.InsertBefore(_nPos_, cStr)
		ok

	  #===============================#
	 #     RANDOM REMOVE             #
	#===============================#

	# Removes n characters chosen at random, in place.
	#
	#   _n_        how many characters to remove
	#   returns    nothing
	#   note       n at or above the length empties the text; 0 or a negative n changes nothing
	#   see        RandomInsert
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
			_j_ = StzEngineRandomInt(0, i - 1) + 1
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
			if StzFindFirst(i, _anRemove_) = 0
				_cResult_ += _acChars_[i]
			ok
		next

		@oString.Update(_cResult_)
