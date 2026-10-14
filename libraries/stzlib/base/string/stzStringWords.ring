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


# Treats a text as a list of words: lists, counts and ranks them, finds the longest, and replaces or removes a word.
#
# Build one with new stzStringWords("text"). Words, NumberOfWords, NthWord, NFirstWords, NLastWords
# and the length and frequency readers cut words by Unicode word rules, so punctuation is dropped,
# "well-known" is two words and an emoji is none; UniqueWords and WordAtPosition cut at spaces only
# and keep punctuation, so the two families can disagree on the same text. WordFrequencies and
# MostFrequentWord fold case. ReplaceWord and RemoveWord change the text held, but rebuild it from
# the words, which drops all punctuation and extra spaces: use stzString.ReplaceCS when the text
# must stay as it is. Do not pass a stzString object you still need.
#
#   receiver   o1 = new stzStringWords("The quick brown fox, the lazy dog. THE end")
#   example    ? @@( o1.Words() )
#              #--> [ "The", "quick", "brown", "fox", "the", "lazy", "dog", "THE", "end" ]
#              ? o1.NumberOfWords()
#              #--> 9
#              ? @@( o1.WordFrequencies()[1] )
#              #--> [ "The", 3 ]
#              ? o1.LongestWord()
#              #--> quick
#              ? o1.ContainsWord("fox")
#              #--> 1
#   see        stzString, stzWordStream, stzStringGetter
class stzStringWords from stzObject

	@oString

	# Builds a words helper over a text or over a stzString object, to list, count, rank and replace its words.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, whose words are read
	#   returns           nothing; the object is built
	#   note              any other kind of value raises "Can't create stzStringWords! Parameter
	#                     must be a string or stzString object."
	#   warning           Given a stzString object, the first in-place edit (ReplaceWord,
	#                     RemoveWord) leaves that stzString EMPTY while the helper holds the result;
	#                     the readers do not. Pass the text, os.Content(), to be safe
	#   see               Words, NumberOfWords
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringWords! Parameter must be a string or stzString object.")
		ok

	# Returns the text the helper holds, after any ReplaceWord or RemoveWord.
	#
	#   returns    a text
	#   see        Words
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting letters and not bytes.
	#
	#   returns    a number
	#   see        NumberOfWords
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text is empty.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     WORDS                     #
	#===============================#

	# Returns the words of the text in order, split by Unicode word rules, so punctuation is left out.
	#
	#   returns    a list of texts; [ ] for an empty text
	#   note       "fox," gives fox; "well-known" gives well and known; an emoji is not a word;
	#              Hebrew and Arabic words come whole; WordsQ answers a stzList
	#   see        NumberOfWords, UniqueWords
	def Words()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringWordsSplit(_pH_)
		_cJoined_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _SplitNullDelimited(_cJoined_)

		def WordsQ()
			return new stzList(This.Words())

	  #===============================#
	 #     NUMBER OF WORDS           #
	#===============================#

	# Returns how many words the text holds, by the same rules as Words.
	#
	#   returns    a number
	#   note       CountWords and HowManyWords are the same method
	#   see        Words
	def NumberOfWords()
		return StzEngineStringCountWords(@oString.Engine())

		def CountWords()
			return This.NumberOfWords()

		def HowManyWords()
			return This.NumberOfWords()

	  #===============================#
	 #     NTH WORD                  #
	#===============================#

	# Returns the word at a position in the list of words, counted from 1.
	#
	#   _n_        the word number, from 1
	#   returns    a text
	#   note       Word is the same method
	#   warning    position 0 or past the last word answers an empty text and raises nothing
	#   see        FirstWord, LastWord, WordAtPosition
	def NthWord(_n_)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringNthWord(_pH_, _n_)
		if _pR_ != ""
			_c_ = StzEngineStringData(_pR_)
			StzEngineStringFree(_pR_)
			return _c_
		ok
		StzRaise("Index out of range!")

		def Word(_n_)
			return This.NthWord(_n_)

	# Returns the first word of the text.
	#
	#   returns    a text; "" for an empty text
	#   see        LastWord, NthWord
	def FirstWord()
		return This.NthWord(1)

	# Returns the last word of the text.
	#
	#   returns    a text; "" for an empty text
	#   see        FirstWord
	def LastWord()
		return This.NthWord(This.NumberOfWords())

	  #===============================#
	 #     FIRST/LAST N WORDS       #
	#===============================#

	# Returns the first n words as a list.
	#
	#   _n_        how many words to take
	#   returns    a list of texts; all the words when n is larger
	#   note       n of 0 gives [ ]
	#   see        NLastWords, Words
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

	# Returns the last n words as a list, in text order.
	#
	#   _n_        how many words to take
	#   returns    a list of texts; all the words when n is larger
	#   note       n of 0 gives [ ]
	#   see        NFirstWords
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

	# Returns the word that contains a character position, or an empty text if that position is a space.
	#
	#   _n_        the character position, from 1
	#   returns    a text
	#   note       words here are cut at white space only, so it answers "fox," with its comma where
	#              Words gives fox; a position outside the text raises "Position out of range!"
	#   see        NthWord
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
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringUniqueWordsCS(_pH_, _bCase_)
		_cResult_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)

		if _cResult_ = ""
			return []
		ok

		return split(_cResult_, " ")

	# Returns the different words once each, in order of first appearance, comparing case-sensitively.
	#
	#   returns    a list of texts
	#   note       it cuts at spaces only, unlike Words: "fox," stays with its comma and an emoji
	#              counts as a word; UniqueWordsCS(0) folds case; WordsU is the same method
	#   see        UniqueWordsCS, Words
	def UniqueWords()
		return This.UniqueWordsCS(1)

		def WordsU()
			return This.UniqueWords()

	  #===============================#
	 #     LONGEST / SHORTEST WORD   #
	#===============================#

	# Returns the longest word by characters; the first one when several tie.
	#
	#   returns    a text; "" for an empty text
	#   see        ShortestWord
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

	# Returns the shortest word by characters; the first one when several tie.
	#
	#   returns    a text; "" for an empty text
	#   see        LongestWord
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

	# Returns the mean number of characters per word.
	#
	#   returns    a number; 0 for an empty text
	#   note       "שלום עולם שלום ب ب" gives 2.8
	#   see        LongestWord
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

	# Returns each different word with how many times it occurs, ignoring case, as [ word, count ] pairs.
	#
	#   returns    a list of pairs, in order of first appearance
	#   note       the case is folded: The, the and THE count as one word, written as it first
	#              appeared
	#   see        MostFrequentWord, UniqueWords
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

	# Returns the word that occurs most often, ignoring case; the first one when several tie.
	#
	#   returns    a text; "" for an empty text
	#   see        WordFrequencies
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

	# TRUE if the text has the given word as a whole word, case-sensitively.
	#
	#   pcWord     the word to look for
	#   returns    TRUE or FALSE
	#   note       ContainsWordCS(w, 0) ignores case; "qui" in "quick" is FALSE and "fox," with its
	#              comma is FALSE
	#   see        ContainsWordCS
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

	# Replaces every occurrence of a word by another, case-sensitively, in place.
	#
	#   pcOldWord   the word to replace
	#   pcNewWord   the word to put
	#   returns     nothing; use ReplaceWordQ to chain
	#   note        ReplaceWordCS(old, new, 0) ignores case
	#   warning     The text is rebuilt from its words, so all punctuation is lost and the spaces
	#               are reset to single ones, even when nothing is replaced: ReplaceWord("zzz", "x")
	#               on "Hello, world! It is 5.5 o clock." leaves "Hello world It is 5.5 o clock"
	#   see         RemoveWord, ReplaceWordCS
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

	# Removes every occurrence of a word, case-sensitively, in place.
	#
	#   pcWord     the word to remove
	#   returns    nothing; use RemoveWordQ to chain
	#   note       RemoveWordCS(word, 0) ignores case
	#   warning    The text is rebuilt from its words, so all punctuation is lost and the spaces are
	#              reset to single ones, even when nothing is removed
	#   see        ReplaceWord, RemoveWordCS
	def RemoveWord(pcWord)
		This.RemoveWordCS(pcWord, 1)

		def RemoveWordQ(pcWord)
			This.RemoveWord(pcWord)
			return This
