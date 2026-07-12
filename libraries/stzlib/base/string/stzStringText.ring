#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGTEXT             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String text -- Wraps stzString via          #
#                  composition. Higher-level text processing:   #
#                  words, sentences, paragraphs, lines,        #
#                  language/script detection, text transforms.  #
#                  Engine-accelerated where available.          #
#                  For aliases, use stxStringText.              #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

  ///////////////////
 ///   GLOBALS   ///
///////////////////

_cSentenceSeparator = "."
_cParagraphSeparator = NL
_cDefaultLanguage = :English

_cWordIdentificationMode = :Quick	# or :Strict

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzSentenceSeparator()
	return _cSentenceSeparator

	func SentenceSeparator()
		return StzSentenceSeparator()

func StzParagraphSeparator()
	return _cParagraphSeparator

	func ParagraphSeparator()
		return StzParagraphSeparator()

func StzDefaultLanguage()
	return _cDefaultLanguage

	func DefaultLanguage()
		return StzDefaultLanguage()

func StzStringTextQ(pcStr)
	return new stzStringText(pcStr)

func IsStzStringText(p)
	return IsObject(p) and classname(p) = "stzstringtext"

func StzWordIdentificationMode()
	return _cWordIdentificationMode

	func WordIdentificationMode()
		return StzWordIdentificationMode()

func StzIdentifyWordsInQuickMode()
	_cWordIdentificationMode = :Quick

	func IdentifyWordsInQuickMode()
		StzIdentifyWordsInQuickMode()

func StzIdentifyWordsInStrictMode()
	_cWordIdentificationMode = :Strict

	func IdentifyWordsInStrictMode()
		StzIdentifyWordsInStrictMode()

  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringText from stzObject

	@oString
	@cLanguage

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringText! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# (Doc()/Ask()/AskFor()/ExplainMethod() are inherited from stzObject -- the
	# common ground for every Softanza object.)

	def Content()
		return @oString.Content()

	def Text()
		return This.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	def Copy()
		return new stzStringText(This.Content())

	def ToStzString()
		return new stzString(This.Content())

	def Engine()
		return @oString.Engine()

	def Update(pcStr)
		if isList(pcStr) and IsWithOrByOrUsingNamedParamList(pcStr)
			pcStr = pcStr[2]
		ok
		@oString.Update(pcStr)

		def UpdateWith(pcStr)
			This.Update(pcStr)

	  #===============================#
	 #     LANGUAGE                   #
	#===============================#

	def SetLanguage(pcLanguage)
		@cLanguage = pcLanguage

	def Language()
		return @cLanguage

	  #===============================#
	 #     SCRIPT                    #
	#===============================#

	# The (dominant) script of the string.
	def Script()
		if This.NumberOfScripts() = 0
			StzRaise("Information about script is unavailable!")

		but This.NumberOfScripts() = 1
			return This.Scripts()[1]

		but This.NumberOfScripts() = 2 and StzFindFirst(This.Scripts(), :Common) > 0
			_cResult_ = StzListQ(This.Scripts()).AllItemsExcept(:Common)[1]
			return _cResult_

		but This.NumberOfScripts() > 1
			_cResult_ = :Hybrid

			if This.NumberOfScripts() <= 3
				_oScripts_ = StzListQ(This.Scripts())
				_oScripts_ - [ :Common, :Inherited ]
				_cScript_ = _oScripts_[1]

				if StzListQ(This.Scripts()).EachItemExistsIn([ _cScript_, :Common, :Inherited ])
					_cResult_ = _cScript_
				ok
			ok

			return _cResult_
		ok

	# The scripts used in the string.
	def Scripts()
		_acResult_ = []
		_aoStzChars_ = @oString.ToListOfStzChars()
		_nLen_ = len(_aoStzChars_)

		for i = 1 to _nLen_
			_acResult_ + _aoStzChars_[i].Script()
		next

		_acResult_ = U(_acResult_)
		return _acResult_

	# How many scripts the string uses.
	def NumberOfScripts()
		return len(This.Scripts())

	def CountScripts()
		return len(This.Scripts())

	def NumberOfDistinctScripts()
		return len(This.Scripts())

	def ScriptIs(_cScript_)
		return This.Script() = _cScript_

	def ContainsScript(_cScript_)
		return StzFindFirst(This.Scripts(), _cScript_) > 0

	def ContainsArabicScript()
		return This.ContainsScript(:Arabic)

	def ContainsLatinScript()
		return This.ContainsScript(:Latin)

	# TRUE if the string is written in the Latin script.
	def IsLatinScript()
		return This.ScriptIs(:Latin)

	# TRUE if the string is written in the Arabic script.
	def IsArabicScript()
		return This.ScriptIs(:Arabic)

	# TRUE if the string is written in the Han script.
	def IsHanScript()
		return This.ScriptIs(:Han)

	# TRUE if the string mixes several scripts.
	def IsHybridScript()
		return This.ScriptIs(:Hybrid)

	# TRUE if the chars belong to the Common script.
	def IsCommonScript()
		return This.ScriptIs(:Common)

	# TRUE if the chars belong to the Inherited script.
	def IsInheritedScript()
		return This.ScriptIs(:Inherited)

	  #------------------------------------------#
	 #     FILTERING TEXT BY SCRIPT             #
	#------------------------------------------#

	def OnlyScript(pcScript)
		# WF (anonymous function) instead of an eval()'d textual condition --
		# the function captures pcScript and calls the real stzChar method.
		_acListOfChars_ = StzListQ(This.ToStzString().ToListOfChars()).ItemsWF(
			func c { return StzCharQ(c).Script() = pcScript } )
		_cResult_ = StzListOfStringsQ(_acListOfChars_).ConcatenateQ().SimplifyQ().Content()
		return _cResult_

	def OnlyArabic()
		_acListOfChars_ = StzListQ(This.ToStzString().ToListOfChars()).ItemsWF(
			func c { return StzCharQ(c).IsNeutral() or StzCharQ(c).IsSpace() or StzCharQ(c).IsArabic() } )
		_cResult_ = StzListOfStringsQ(_acListOfChars_).ConcatenateQ().SimplifyQ().Content()
		return _cResult_

	def OnlyLatin()
		_acListOfChars_ = StzListQ(This.ToStzString().ToListOfChars()).ItemsWF(
			func c { return StzCharQ(c).IsNeutral() or StzCharQ(c).IsSpace() or StzCharQ(c).IsLatin() } )
		_cResult_ = StzListOfStringsQ(_acListOfChars_).ConcatenateQ().SimplifyQ().Content()
		return _cResult_

	  #===============================#
	 #     WORDS (Engine-backed)     #
	#===============================#

	def NumberOfWords()
		return StzEngineStringCountWords(This.Engine())

		def CountWords()
			return This.NumberOfWords()

		def HowManyWords()
			return This.NumberOfWords()

	def NthWord(_n_)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringNthWord(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

		def Word(_n_)
			return This.NthWord(_n_)

	# The first word of the string.
	def FirstWord()
		pResult = StzEngineStringFirstWord(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# The last word of the string.
	def LastWord()
		pResult = StzEngineStringLastWord(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def Words()
		pResult = StzEngineStringExtractWords(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)

		if _cResult_ = ""
			return []
		ok

		return StzStringQ(_cResult_).Split(" ")

		def WordsQ()
			return new stzList(This.Words())

	# The unique words of the string.
	def UniqueWordsCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pResult = StzEngineStringUniqueWordsCS(This.Engine(), _bCase_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)

		if _cResult_ = ""
			return []
		ok

		return StzStringQ(_cResult_).Split(" ")

	def UniqueWords()
		return This.UniqueWordsCS(1)

		def SetOfWords()
			return This.UniqueWords()

		def WordsU()
			return This.UniqueWords()

	def NumberOfUniqueWords()
		return len(This.UniqueWords())

	  #------------------------------------------#
	 #     WORD CHECKS                          #
	#------------------------------------------#

	def IsWord()
		if @oString.IsEmpty()
			return 0
		ok
		pH = @oString.Engine()
		return StzEngineStringIsWord(pH)

	def IsArabicWord()
		if This.IsWord() and This.ScriptIs(:Arabic)
			return 1
		else
			return 0
		ok

	def IsLatinWord()
		if This.IsWord() and This.ScriptIs(:Latin)
			return 1
		else
			return 0
		ok

	# TRUE if the string contains the given WORD (word-boundary
	# aware).
	def ContainsWordCS(pcWord, pCaseSensitive)
		if NOT isString(pcWord)
			StzRaise("Incorrect param type! pcWord must be a string.")
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		_acWords_ = This.UniqueWordsCS(_bCase_)

		if _bCase_ = 1
			_nLen_ = len(_acWords_)
			for i = 1 to _nLen_
				if _acWords_[i] = pcWord
					return 1
				ok
			next
		else
			_cLower_ = StzCaseFold(pcWord)
			_nLen_ = len(_acWords_)
			for i = 1 to _nLen_
				if StzCaseFold(_acWords_[i]) = _cLower_
					return 1
				ok
			next
		ok
		return 0

	def ContainsWord(pcWord)
		return This.ContainsWordCS(pcWord, 1)

		def ContainsNoWord(pcWord)
			return NOT This.ContainsWord(pcWord)

	def ContainsEachWordCS(pacWords, pCaseSensitive)
		_nLen_ = len(pacWords)
		for i = 1 to _nLen_
			if NOT This.ContainsWordCS(pacWords[i], pCaseSensitive)
				return 0
			ok
		next
		return 1

	def ContainsEachWord(pacWords)
		return This.ContainsEachWordCS(pacWords, 1)

	  #------------------------------------------#
	 #     WORD TRANSFORMS (Engine-backed)      #
	#------------------------------------------#

	def ReverseWords()
		pResult = StzEngineStringReverseWords(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def ReverseWordsQ()
			This.ReverseWords()
			return This

	def WordsReversed()
		pResult = StzEngineStringReverseWords(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def SortWordsCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pResult = StzEngineStringSortWordsCS(This.Engine(), _bCase_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def SortWordsCSQ(pCaseSensitive)
			This.SortWordsCS(pCaseSensitive)
			return This

	def SortWords()
		This.SortWordsCS(1)

		def SortWordsQ()
			This.SortWords()
			return This

	def WordsSortedCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pResult = StzEngineStringSortWordsCS(This.Engine(), _bCase_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def WordsSorted()
		return This.WordsSortedCS(1)

	def ReverseEachWord()
		pResult = StzEngineStringReverseEachWord(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def ReverseEachWordQ()
			This.ReverseEachWord()
			return This

	def EachWordReversed()
		pResult = StzEngineStringReverseEachWord(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def RemoveNthWord(_n_)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringRemoveNthWord(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def RemoveNthWordQ(_n_)
			This.RemoveNthWord(_n_)
			return This

	def NthWordRemoved(_n_)
		pResult = StzEngineStringRemoveNthWord(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def InsertWordAt(_n_, pcWord)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringInsertWordAt(This.Engine(), _n_, pcWord)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def InsertWordAtQ(_n_, pcWord)
			This.InsertWordAt(_n_, pcWord)
			return This

	def SwapWords(n1, n2)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringSwapWords(This.Engine(), n1, n2)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def SwapWordsQ(n1, n2)
			This.SwapWords(n1, n2)
			return This

	def TruncateWords(_n_)
		pResult = StzEngineStringTruncateWords(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def TruncateWordsQ(_n_)
			This.TruncateWords(_n_)
			return This

	def WordsTruncated(_n_)
		pResult = StzEngineStringTruncateWords(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def RemoveDuplicateWords()
		pResult = StzEngineStringRemoveDuplicateWords(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def RemoveDuplicateWordsQ()
			This.RemoveDuplicateWords()
			return This

	def DuplicateWordsRemoved()
		pResult = StzEngineStringRemoveDuplicateWords(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def CountWordsMatching(pcPattern)
		return StzEngineStringCountWordsMatching(This.Engine(), pcPattern)

	  #------------------------------------------#
	 #     WORD FREQUENCY (Ring logic)          #
	#------------------------------------------#

	def NumberOfOccurrenceOfWordCS(pcWord, pCaseSensitive)
		# ENGINE-DIRECT one-pass whole-word count. Was Words() (materialize
		# EVERY word into a Ring list) + a Ring compare loop -- O(n) alloc + O(n)
		# compares per call. Now a single engine scan, no materialization.
		if NOT isString(pcWord) return 0 ok
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringCountWordCS(This.Engine(), pcWord, _bCase_)

	def NumberOfOccurrenceOfWord(pcWord)
		return This.NumberOfOccurrenceOfWordCS(pcWord, 1)

		def NumberOfOccurrencesOfWord(pcWord)
			return This.NumberOfOccurrenceOfWord(pcWord)

	# Each word paired with its frequency.
	def WordFrequency(pcWord)
		_n_ = This.NumberOfWords()
		if _n_ = 0
			StzRaise("Can't compute WordFrequency()! Text contains no words.")
		ok
		return This.NumberOfOccurrenceOfWord(pcWord) / _n_

		def FrequencyOfWord(pcWord)
			return This.WordFrequency(pcWord)

	# Drain an engine word-frequency result into [[word, count], ...].
	def _DrainWordFreq(pRes)
		_aOut_ = []
		_n_ = StzEngineWordFreqCount(pRes)
		for i = 1 to _n_
			pW = StzEngineWordFreqWord(pRes, i)
			_cW_ = StzEngineStringData(pW)
			StzEngineStringFree(pW)
			_aOut_ + [ _cW_, StzEngineWordFreqNum(pRes, i) ]
		next
		StzEngineWordFreqFree(pRes)
		return _aOut_

	# [[word, count], ...] in first-appearance order. ENGINE-DIRECT, ONE pass.
	def WordsAndTheirCountsCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return This._DrainWordFreq( StzEngineStringWordFreq(This.Engine(), _bCase_, 0) )

	def WordsAndTheirCounts()
		return This.WordsAndTheirCountsCS(1)

	# The top-N most frequent words as [[word, count], ...], count descending
	# (ties by first appearance). ENGINE-DIRECT, ONE pass + partial rank.
	def MostFrequentWordsCS(_n_, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return This._DrainWordFreq( StzEngineStringWordFreq(This.Engine(), _bCase_, _n_) )

	def MostFrequentWords(_n_)
		return This.MostFrequentWordsCS(_n_, 1)

	def WordsAndTheirFrequencies()
		# ENGINE-DIRECT one-pass: was UniqueWords() then a full-text rescan PER
		# unique word (NumberOfOccurrenceOfWord), i.e. O(unique x length) --
		# quadratic on any real document. Now every word is counted in a single
		# hashmap pass; frequency = count / total. First-appearance order kept.
		_aCounts_ = This.WordsAndTheirCounts()
		_nTotal_ = This.NumberOfWords()
		if _nTotal_ = 0 return [] ok
		_aResult_ = []
		_nLen_ = len(_aCounts_)
		for i = 1 to _nLen_
			_aResult_ + [ _aCounts_[i][1], _aCounts_[i][2] / _nTotal_ ]
		next
		return _aResult_

	# The word that occurs most often in the string.
	def MostFrequentWord()
		_aWordsFreqs_ = This.WordsAndTheirFrequencies()
		_nLen_ = len(_aWordsFreqs_)
		if _nLen_ = 0
			return ""
		ok

		_cBest_ = _aWordsFreqs_[1][1]
		_nBest_ = _aWordsFreqs_[1][2]

		for i = 2 to _nLen_
			if _aWordsFreqs_[i][2] > _nBest_
				_nBest_ = _aWordsFreqs_[i][2]
				_cBest_ = _aWordsFreqs_[i][1]
			ok
		next

		return _cBest_

	def LessFrequentWord()
		_aWordsFreqs_ = This.WordsAndTheirFrequencies()
		_nLen_ = len(_aWordsFreqs_)
		if _nLen_ = 0
			return ""
		ok

		_cBest_ = _aWordsFreqs_[1][1]
		_nBest_ = _aWordsFreqs_[1][2]

		for i = 2 to _nLen_
			if _aWordsFreqs_[i][2] < _nBest_
				_nBest_ = _aWordsFreqs_[i][2]
				_cBest_ = _aWordsFreqs_[i][1]
			ok
		next

		return _cBest_

	def NMostFrequentWords(_n_)
		_aWordsFreqs_ = This.WordsAndTheirFrequencies()
		_nLen_ = len(_aWordsFreqs_)

		# Sort by frequency descending (simple selection sort)
		for i = 1 to _nLen_ - 1
			_nMaxIdx_ = i
			for j = i + 1 to _nLen_
				if _aWordsFreqs_[j][2] > _aWordsFreqs_[_nMaxIdx_][2]
					_nMaxIdx_ = j
				ok
			next
			if _nMaxIdx_ != i
				_aTemp_ = _aWordsFreqs_[i]
				_aWordsFreqs_[i] = _aWordsFreqs_[_nMaxIdx_]
				_aWordsFreqs_[_nMaxIdx_] = _aTemp_
			ok
		next

		_aResult_ = []
		_nMax_ = _n_
		if _nMax_ > _nLen_
			_nMax_ = _nLen_
		ok
		for i = 1 to _nMax_
			_aResult_ + _aWordsFreqs_[i][1]
		next

		return _aResult_

		def TopNFrequentWords(_n_)
			return This.NMostFrequentWords(_n_)

	  #------------------------------------------#
	 #     WORD POSITIONS (Ring logic)          #
	#------------------------------------------#

	def WordsPositions()
		_acWordsU_ = This.UniqueWords()
		_oTempStr_ = new stzString(This.Content())
		_anResult_ = _oTempStr_.FindMany(_acWordsU_)
		return _anResult_

	def WordsAndTheirPositions()
		_aResult_ = []
		_acWords_ = This.UniqueWords()
		_oStr_ = This.ToStzString()
		_nLen_ = len(_acWords_)

		for i = 1 to _nLen_
			_aResult_ + [ _acWords_[i], _oStr_.FindAllCS(_acWords_[i], 0) ]
		next

		return _aResult_

		def WordsZ()
			return This.WordsAndTheirPositions()

	  #------------------------------------------#
	 #     WORD SORTING CHECKS (Ring logic)     #
	#------------------------------------------#

	def WordsSortingOrder()
		_cResult_ = :Unsorted

		if This.WordsAreSortedInAscending()
			_cResult_ = :Ascending
		but This.WordsAreSortedInDescending()
			_cResult_ = :Descending
		ok

		return _cResult_

	def WordsAreSorted()
		return This.WordsAreSortedInAscending() or This.WordsAreSortedInDescending()

	def WordsAreSortedInAscending()
		_acWords_ = This.Words()
		_nLen_ = len(_acWords_)
		if _nLen_ <= 1
			return 1
		ok
		for i = 1 to _nLen_ - 1
			if strcmp(_acWords_[i], _acWords_[i + 1]) > 0
				return 0
			ok
		next
		return 1

	def WordsAreSortedInDescending()
		_acWords_ = This.Words()
		_nLen_ = len(_acWords_)
		if _nLen_ <= 1
			return 1
		ok
		for i = 1 to _nLen_ - 1
			if strcmp(_acWords_[i], _acWords_[i + 1]) < 0
				return 0
			ok
		next
		return 1

	def WordsSortedInAscending()
		_acResult_ = This.Words()
		return StzListOfStringsQ(_acResult_).SortedInAscending()

	def WordsSortedInDescending()
		_acResult_ = This.Words()
		return StzListOfStringsQ(_acResult_).SortedInDescending()

	  #------------------------------------------#
	 #     WORD EXCLUSION (Ring logic)          #
	#------------------------------------------#

	def WordsExcept(pacWords)
		if NOT (isList(pacWords) and IsListOfStrings(pacWords))
			StzRaise("Incorrect param type!")
		ok

		_acExclude_ = StzListOfStringsQ(pacWords).Lowercased()
		_acWords_ = This.Words()
		_aResult_ = []
		_nLen_ = len(_acWords_)

		for i = 1 to _nLen_
			if StzFindFirst(_acExclude_, StzCaseFold(_acWords_[i])) = 0
				_aResult_ + _acWords_[i]
			ok
		next

		return _aResult_

	  #===============================#
	 #     SENTENCES (Engine-backed) #
	#===============================#

	# How many sentences the string holds.
	def NumberOfSentences()
		return StzEngineStringCountSentences(This.Engine())

		def CountSentences()
			return This.NumberOfSentences()

		def SentenceCount()
			return This.NumberOfSentences()

		def HowManySentences()
			return This.NumberOfSentences()

	def Sentences()
		_cContent_ = This.Content()
		if _cContent_ = ""
			return []
		ok

		_aResult_ = []
		_cSentence_ = ""
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_cArabicQM_ = StzChar(1567) # Arabic question mark

		for i = 1 to _nLen_
			c = _acChars_[i]
			if c = "." or c = "!" or c = "?" or c = _cArabicQM_
				_cSentence_ += c
				_cTrimmed_ = trim(_cSentence_)
				if _cTrimmed_ != ""
					_aResult_ + _cTrimmed_
				ok
				_cSentence_ = ""
			else
				_cSentence_ += c
			ok
		next

		# Remaining text after last separator
		_cTrimmed_ = trim(_cSentence_)
		if _cTrimmed_ != ""
			_aResult_ + _cTrimmed_
		ok

		return _aResult_

	def NthSentence(_n_)
		_acSentences_ = This.Sentences()
		if _n_ >= 1 and _n_ <= len(_acSentences_)
			return _acSentences_[_n_]
		ok
		StzRaise("Index out of range!")

		def Sentence(_n_)
			return This.NthSentence(_n_)

	def FirstSentence()
		return This.NthSentence(1)

	def LastSentence()
		return This.NthSentence(len(This.Sentences()))

	  #===============================#
	 #     PARAGRAPHS (Engine-backed)#
	#===============================#

	# How many paragraphs the string holds.
	def NumberOfParagraphs()
		return StzEngineStringCountParagraphs(This.Engine())

		def CountParagraphs()
			return This.NumberOfParagraphs()

		def HowManyParagraphs()
			return This.NumberOfParagraphs()

	# The paragraphs of the string, as a list.
	def Paragraphs()
		_cContent_ = This.Content()
		if _cContent_ = ""
			return []
		ok

		# Split on double newlines (paragraph boundary)
		_aRaw_ = StzStringQ(_cContent_).Split(NL + NL)
		_aResult_ = []
		_nLen_ = len(_aRaw_)

		for i = 1 to _nLen_
			_cTrimmed_ = trim(_aRaw_[i])
			if _cTrimmed_ != ""
				_aResult_ + _cTrimmed_
			ok
		next

		return _aResult_

	# The nth paragraph of the string.
	def NthParagraph(_n_)
		_acParas_ = This.Paragraphs()
		if _n_ >= 1 and _n_ <= len(_acParas_)
			return _acParas_[_n_]
		ok
		StzRaise("Index out of range!")

		def Paragraph(_n_)
			return This.NthParagraph(_n_)

	def FirstParagraph()
		return This.NthParagraph(1)

	def LastParagraph()
		return This.NthParagraph(len(This.Paragraphs()))

	  #===============================#
	 #     LINES (Engine-backed)     #
	#===============================#

	def NumberOfLines()
		return StzEngineStringCountLines(This.Engine())

		def CountLines()
			return This.NumberOfLines()

		def HowManyLines()
			return This.NumberOfLines()

	def Lines()
		return @SplitCS(@oString.Content(), NL, 1)

	def NthLine(_n_)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringLineAt(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

		def Line(_n_)
			return This.NthLine(_n_)

	def FirstLine()
		return This.NthLine(1)

	def LastLine()
		return This.NthLine(This.NumberOfLines())

	  #------------------------------------------#
	 #     LINE TRANSFORMS (Engine-backed)      #
	#------------------------------------------#

	def DeduplicateLinesCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pResult = StzEngineStringDeduplicateLinesCS(This.Engine(), _bCase_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def DeduplicateLinesCSQ(pCaseSensitive)
			This.DeduplicateLinesCS(pCaseSensitive)
			return This

	def DeduplicateLines()
		return This.DeduplicateLinesCS(1)

		def DeduplicateLinesQ()
			This.DeduplicateLines()
			return This

	def LinesDeduplicatedCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pResult = StzEngineStringDeduplicateLinesCS(This.Engine(), _bCase_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def LinesDeduplicated()
		return This.LinesDeduplicatedCS(1)

	def RemoveBlankLines()
		pResult = StzEngineStringRemoveBlankLines(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def RemoveBlankLinesQ()
			This.RemoveBlankLines()
			return This

		def RemoveEmptyLines()
			This.RemoveBlankLines()

		def RemoveEmptyLinesQ()
			This.RemoveBlankLines()
			return This

	def BlankLinesRemoved()
		pResult = StzEngineStringRemoveBlankLines(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

		def EmptyLinesRemoved()
			return This.BlankLinesRemoved()

	def NumberLines()
		pResult = StzEngineStringNumberLines(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def NumberLinesQ()
			This.NumberLines()
			return This

	def LinesNumbered()
		pResult = StzEngineStringNumberLines(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	  #===============================#
	 #     TEXT TRANSFORMS           #
	 #     (Engine-backed)           #
	#===============================#

	def Simplify()
		pResult = StzEngineStringSimplify(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def SimplifyQ()
			This.Simplify()
			return This

	def Simplified()
		pResult = StzEngineStringSimplify(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def CollapseSpaces()
		pResult = StzEngineStringCollapseSpaces(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def CollapseSpacesQ()
			This.CollapseSpaces()
			return This

	def SpacesCollapsed()
		pResult = StzEngineStringCollapseSpaces(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def NormalizeSpaces()
		pResult = StzEngineStringNormalizeSpaces(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def NormalizeSpacesQ()
			This.NormalizeSpaces()
			return This

	def SpacesNormalized()
		pResult = StzEngineStringNormalizeSpaces(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def ToSentenceCase()
		pResult = StzEngineStringToSentenceCase(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def ToSentenceCaseQ()
			This.ToSentenceCase()
			return This

	def SentenceCased()
		pResult = StzEngineStringToSentenceCase(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	def Pluralize()
		pResult = StzEngineStringPluralize(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def PluralizeQ()
			This.Pluralize()
			return This

	def Pluralized()
		pResult = StzEngineStringPluralize(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# The string turned into a URL slug (lowercase, hyphens).
	def ToSlug()
		pResult = StzEngineStringToSlug(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

		def Slugified()
			return This.ToSlug()

	def Abbreviate(nMaxLen)
		pResult = StzEngineStringAbbreviate(This.Engine(), nMaxLen)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

		def Abbreviated(nMaxLen)
			return This.Abbreviate(nMaxLen)

	# The initial letter of each word.
	def Initials()
		pResult = StzEngineStringInitials(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Delegate-thin wrappers so stzText/stzStringText consumers can
	# reach common stzString helpers without juggling .ToStzString().
	def DiacriticsRemoved()
		return @oString.DiacriticsRemoved()

	def RemoveDiacritics()
		@oString.RemoveDiacritics()

	def Lowercase()
		return @oString.Lowercase()

	def Uppercase()
		return @oString.Uppercase()

	def Chars()
		return @oString.Chars()

	def NumberOfChars2()
		return @oString.NumberOfChars()

# NOTE: class stzText moved to base/natural/stzText.ring -- it is now the
# text-meaning DOMAIN class (still 'from stzStringText', so a superset).

