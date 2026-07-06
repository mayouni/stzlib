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

class stzStringText

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

	def Script()
		if This.NumberOfScripts() = 0
			StzRaise("Information about script is unavailable!")

		but This.NumberOfScripts() = 1
			return This.Scripts()[1]

		but This.NumberOfScripts() = 2 and StzFindFirst(This.Scripts(), :Common) > 0
			cResult = StzListQ(This.Scripts()).AllItemsExcept(:Common)[1]
			return cResult

		but This.NumberOfScripts() > 1
			cResult = :Hybrid

			if This.NumberOfScripts() <= 3
				oScripts = StzListQ(This.Scripts())
				oScripts - [ :Common, :Inherited ]
				cScript = oScripts[1]

				if StzListQ(This.Scripts()).EachItemExistsIn([ cScript, :Common, :Inherited ])
					cResult = cScript
				ok
			ok

			return cResult
		ok

	def Scripts()
		acResult = []
		aoStzChars = @oString.ToListOfStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			acResult + aoStzChars[i].Script()
		next

		acResult = U(acResult)
		return acResult

	def NumberOfScripts()
		return len(This.Scripts())

	def CountScripts()
		return len(This.Scripts())

	def NumberOfDistinctScripts()
		return len(This.Scripts())

	def ScriptIs(cScript)
		return This.Script() = cScript

	def ContainsScript(cScript)
		return StzFindFirst(This.Scripts(), cScript) > 0

	def ContainsArabicScript()
		return This.ContainsScript(:Arabic)

	def ContainsLatinScript()
		return This.ContainsScript(:Latin)

	def IsLatinScript()
		return This.ScriptIs(:Latin)

	def IsArabicScript()
		return This.ScriptIs(:Arabic)

	def IsHanScript()
		return This.ScriptIs(:Han)

	def IsHybridScript()
		return This.ScriptIs(:Hybrid)

	def IsCommonScript()
		return This.ScriptIs(:Common)

	def IsInheritedScript()
		return This.ScriptIs(:Inherited)

	  #------------------------------------------#
	 #     FILTERING TEXT BY SCRIPT             #
	#------------------------------------------#

	def OnlyScript(pcScript)
		# WF (anonymous function) instead of an eval()'d textual condition --
		# the function captures pcScript and calls the real stzChar method.
		acListOfChars = StzListQ(This.ToStzString().ToListOfChars()).ItemsWF(
			func c { return StzCharQ(c).Script() = pcScript } )
		cResult = StzListOfStringsQ(acListOfChars).ConcatenateQ().SimplifyQ().Content()
		return cResult

	def OnlyArabic()
		acListOfChars = StzListQ(This.ToStzString().ToListOfChars()).ItemsWF(
			func c { return StzCharQ(c).IsNeutral() or StzCharQ(c).IsSpace() or StzCharQ(c).IsArabic() } )
		cResult = StzListOfStringsQ(acListOfChars).ConcatenateQ().SimplifyQ().Content()
		return cResult

	def OnlyLatin()
		acListOfChars = StzListQ(This.ToStzString().ToListOfChars()).ItemsWF(
			func c { return StzCharQ(c).IsNeutral() or StzCharQ(c).IsSpace() or StzCharQ(c).IsLatin() } )
		cResult = StzListOfStringsQ(acListOfChars).ConcatenateQ().SimplifyQ().Content()
		return cResult

	  #===============================#
	 #     WORDS (Engine-backed)     #
	#===============================#

	def NumberOfWords()
		return StzEngineStringCountWords(This.Engine())

		def CountWords()
			return This.NumberOfWords()

		def HowManyWords()
			return This.NumberOfWords()

	def NthWord(n)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringNthWord(This.Engine(), n)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

		def Word(n)
			return This.NthWord(n)

	def FirstWord()
		pResult = StzEngineStringFirstWord(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def LastWord()
		pResult = StzEngineStringLastWord(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def Words()
		pResult = StzEngineStringExtractWords(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)

		if cResult = ""
			return []
		ok

		return StzStringQ(cResult).Split(" ")

		def WordsQ()
			return new stzList(This.Words())

	def UniqueWordsCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pResult = StzEngineStringUniqueWordsCS(This.Engine(), _bCase_)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)

		if cResult = ""
			return []
		ok

		return StzStringQ(cResult).Split(" ")

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

	def ContainsWordCS(pcWord, pCaseSensitive)
		if NOT isString(pcWord)
			StzRaise("Incorrect param type! pcWord must be a string.")
		ok

		_bCase_ = @CaseSensitive(pCaseSensitive)
		acWords = This.UniqueWordsCS(_bCase_)

		if _bCase_ = 1
			nLen = len(acWords)
			for i = 1 to nLen
				if acWords[i] = pcWord
					return 1
				ok
			next
		else
			cLower = StzCaseFold(pcWord)
			nLen = len(acWords)
			for i = 1 to nLen
				if StzCaseFold(acWords[i]) = cLower
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
		nLen = len(pacWords)
		for i = 1 to nLen
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
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def ReverseWordsQ()
			This.ReverseWords()
			return This

	def WordsReversed()
		pResult = StzEngineStringReverseWords(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def SortWordsCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pResult = StzEngineStringSortWordsCS(This.Engine(), _bCase_)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

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
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def WordsSorted()
		return This.WordsSortedCS(1)

	def ReverseEachWord()
		pResult = StzEngineStringReverseEachWord(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def ReverseEachWordQ()
			This.ReverseEachWord()
			return This

	def EachWordReversed()
		pResult = StzEngineStringReverseEachWord(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def RemoveNthWord(n)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringRemoveNthWord(This.Engine(), n)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def RemoveNthWordQ(n)
			This.RemoveNthWord(n)
			return This

	def NthWordRemoved(n)
		pResult = StzEngineStringRemoveNthWord(This.Engine(), n)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def InsertWordAt(n, pcWord)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringInsertWordAt(This.Engine(), n, pcWord)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def InsertWordAtQ(n, pcWord)
			This.InsertWordAt(n, pcWord)
			return This

	def SwapWords(n1, n2)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringSwapWords(This.Engine(), n1, n2)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def SwapWordsQ(n1, n2)
			This.SwapWords(n1, n2)
			return This

	def TruncateWords(n)
		pResult = StzEngineStringTruncateWords(This.Engine(), n)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def TruncateWordsQ(n)
			This.TruncateWords(n)
			return This

	def WordsTruncated(n)
		pResult = StzEngineStringTruncateWords(This.Engine(), n)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def RemoveDuplicateWords()
		pResult = StzEngineStringRemoveDuplicateWords(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def RemoveDuplicateWordsQ()
			This.RemoveDuplicateWords()
			return This

	def DuplicateWordsRemoved()
		pResult = StzEngineStringRemoveDuplicateWords(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def CountWordsMatching(pcPattern)
		return StzEngineStringCountWordsMatching(This.Engine(), pcPattern)

	  #------------------------------------------#
	 #     WORD FREQUENCY (Ring logic)          #
	#------------------------------------------#

	def NumberOfOccurrenceOfWordCS(pcWord, pCaseSensitive)
		acWords = This.Words()
		_bCase_ = @CaseSensitive(pCaseSensitive)
		nResult = 0
		nLen = len(acWords)

		if _bCase_ = 1
			for i = 1 to nLen
				if acWords[i] = pcWord
					nResult++
				ok
			next
		else
			cLower = StzCaseFold(pcWord)
			for i = 1 to nLen
				if StzCaseFold(acWords[i]) = cLower
					nResult++
				ok
			next
		ok

		return nResult

	def NumberOfOccurrenceOfWord(pcWord)
		return This.NumberOfOccurrenceOfWordCS(pcWord, 1)

		def NumberOfOccurrencesOfWord(pcWord)
			return This.NumberOfOccurrenceOfWord(pcWord)

	def WordFrequency(pcWord)
		n = This.NumberOfWords()
		if n = 0
			StzRaise("Can't compute WordFrequency()! Text contains no words.")
		ok
		return This.NumberOfOccurrenceOfWord(pcWord) / n

		def FrequencyOfWord(pcWord)
			return This.WordFrequency(pcWord)

	# Drain an engine word-frequency result into [[word, count], ...].
	def _DrainWordFreq(pRes)
		aOut = []
		n = StzEngineWordFreqCount(pRes)
		for i = 1 to n
			pW = StzEngineWordFreqWord(pRes, i)
			cW = StzEngineStringData(pW)
			StzEngineStringFree(pW)
			aOut + [ cW, StzEngineWordFreqNum(pRes, i) ]
		next
		StzEngineWordFreqFree(pRes)
		return aOut

	# [[word, count], ...] in first-appearance order. ENGINE-DIRECT, ONE pass.
	def WordsAndTheirCountsCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return This._DrainWordFreq( StzEngineStringWordFreq(This.Engine(), _bCase_, 0) )

	def WordsAndTheirCounts()
		return This.WordsAndTheirCountsCS(1)

	# The top-N most frequent words as [[word, count], ...], count descending
	# (ties by first appearance). ENGINE-DIRECT, ONE pass + partial rank.
	def MostFrequentWordsCS(n, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return This._DrainWordFreq( StzEngineStringWordFreq(This.Engine(), _bCase_, n) )

	def MostFrequentWords(n)
		return This.MostFrequentWordsCS(n, 1)

	def WordsAndTheirFrequencies()
		# ENGINE-DIRECT one-pass: was UniqueWords() then a full-text rescan PER
		# unique word (NumberOfOccurrenceOfWord), i.e. O(unique x length) --
		# quadratic on any real document. Now every word is counted in a single
		# hashmap pass; frequency = count / total. First-appearance order kept.
		aCounts = This.WordsAndTheirCounts()
		nTotal = This.NumberOfWords()
		if nTotal = 0 return [] ok
		aResult = []
		nLen = len(aCounts)
		for i = 1 to nLen
			aResult + [ aCounts[i][1], aCounts[i][2] / nTotal ]
		next
		return aResult

	def MostFrequentWord()
		aWordsFreqs = This.WordsAndTheirFrequencies()
		nLen = len(aWordsFreqs)
		if nLen = 0
			return ""
		ok

		cBest = aWordsFreqs[1][1]
		nBest = aWordsFreqs[1][2]

		for i = 2 to nLen
			if aWordsFreqs[i][2] > nBest
				nBest = aWordsFreqs[i][2]
				cBest = aWordsFreqs[i][1]
			ok
		next

		return cBest

	def LessFrequentWord()
		aWordsFreqs = This.WordsAndTheirFrequencies()
		nLen = len(aWordsFreqs)
		if nLen = 0
			return ""
		ok

		cBest = aWordsFreqs[1][1]
		nBest = aWordsFreqs[1][2]

		for i = 2 to nLen
			if aWordsFreqs[i][2] < nBest
				nBest = aWordsFreqs[i][2]
				cBest = aWordsFreqs[i][1]
			ok
		next

		return cBest

	def NMostFrequentWords(n)
		aWordsFreqs = This.WordsAndTheirFrequencies()
		nLen = len(aWordsFreqs)

		# Sort by frequency descending (simple selection sort)
		for i = 1 to nLen - 1
			nMaxIdx = i
			for j = i + 1 to nLen
				if aWordsFreqs[j][2] > aWordsFreqs[nMaxIdx][2]
					nMaxIdx = j
				ok
			next
			if nMaxIdx != i
				aTemp = aWordsFreqs[i]
				aWordsFreqs[i] = aWordsFreqs[nMaxIdx]
				aWordsFreqs[nMaxIdx] = aTemp
			ok
		next

		aResult = []
		nMax = n
		if nMax > nLen
			nMax = nLen
		ok
		for i = 1 to nMax
			aResult + aWordsFreqs[i][1]
		next

		return aResult

		def TopNFrequentWords(n)
			return This.NMostFrequentWords(n)

	  #------------------------------------------#
	 #     WORD POSITIONS (Ring logic)          #
	#------------------------------------------#

	def WordsPositions()
		acWordsU = This.UniqueWords()
		oTempStr = new stzString(This.Content())
		anResult = oTempStr.FindMany(acWordsU)
		return anResult

	def WordsAndTheirPositions()
		aResult = []
		acWords = This.UniqueWords()
		oStr = This.ToStzString()
		nLen = len(acWords)

		for i = 1 to nLen
			aResult + [ acWords[i], oStr.FindAllCS(acWords[i], 0) ]
		next

		return aResult

		def WordsZ()
			return This.WordsAndTheirPositions()

	  #------------------------------------------#
	 #     WORD SORTING CHECKS (Ring logic)     #
	#------------------------------------------#

	def WordsSortingOrder()
		cResult = :Unsorted

		if This.WordsAreSortedInAscending()
			cResult = :Ascending
		but This.WordsAreSortedInDescending()
			cResult = :Descending
		ok

		return cResult

	def WordsAreSorted()
		return This.WordsAreSortedInAscending() or This.WordsAreSortedInDescending()

	def WordsAreSortedInAscending()
		acWords = This.Words()
		nLen = len(acWords)
		if nLen <= 1
			return 1
		ok
		for i = 1 to nLen - 1
			if strcmp(acWords[i], acWords[i + 1]) > 0
				return 0
			ok
		next
		return 1

	def WordsAreSortedInDescending()
		acWords = This.Words()
		nLen = len(acWords)
		if nLen <= 1
			return 1
		ok
		for i = 1 to nLen - 1
			if strcmp(acWords[i], acWords[i + 1]) < 0
				return 0
			ok
		next
		return 1

	def WordsSortedInAscending()
		acResult = This.Words()
		return StzListOfStringsQ(acResult).SortedInAscending()

	def WordsSortedInDescending()
		acResult = This.Words()
		return StzListOfStringsQ(acResult).SortedInDescending()

	  #------------------------------------------#
	 #     WORD EXCLUSION (Ring logic)          #
	#------------------------------------------#

	def WordsExcept(pacWords)
		if NOT (isList(pacWords) and IsListOfStrings(pacWords))
			StzRaise("Incorrect param type!")
		ok

		acExclude = StzListOfStringsQ(pacWords).Lowercased()
		acWords = This.Words()
		aResult = []
		nLen = len(acWords)

		for i = 1 to nLen
			if StzFindFirst(acExclude, StzCaseFold(acWords[i])) = 0
				aResult + acWords[i]
			ok
		next

		return aResult

	  #===============================#
	 #     SENTENCES (Engine-backed) #
	#===============================#

	def NumberOfSentences()
		return StzEngineStringCountSentences(This.Engine())

		def CountSentences()
			return This.NumberOfSentences()

		def SentenceCount()
			return This.NumberOfSentences()

		def HowManySentences()
			return This.NumberOfSentences()

	def Sentences()
		cContent = This.Content()
		if cContent = ""
			return []
		ok

		aResult = []
		cSentence = ""
		acChars = @oString.Chars()
		nLen = len(acChars)
		cArabicQM = StzChar(1567) # Arabic question mark

		for i = 1 to nLen
			c = acChars[i]
			if c = "." or c = "!" or c = "?" or c = cArabicQM
				cSentence += c
				cTrimmed = trim(cSentence)
				if cTrimmed != ""
					aResult + cTrimmed
				ok
				cSentence = ""
			else
				cSentence += c
			ok
		next

		# Remaining text after last separator
		cTrimmed = trim(cSentence)
		if cTrimmed != ""
			aResult + cTrimmed
		ok

		return aResult

	def NthSentence(n)
		acSentences = This.Sentences()
		if n >= 1 and n <= len(acSentences)
			return acSentences[n]
		ok
		StzRaise("Index out of range!")

		def Sentence(n)
			return This.NthSentence(n)

	def FirstSentence()
		return This.NthSentence(1)

	def LastSentence()
		return This.NthSentence(len(This.Sentences()))

	  #===============================#
	 #     PARAGRAPHS (Engine-backed)#
	#===============================#

	def NumberOfParagraphs()
		return StzEngineStringCountParagraphs(This.Engine())

		def CountParagraphs()
			return This.NumberOfParagraphs()

		def HowManyParagraphs()
			return This.NumberOfParagraphs()

	def Paragraphs()
		cContent = This.Content()
		if cContent = ""
			return []
		ok

		# Split on double newlines (paragraph boundary)
		aRaw = StzStringQ(cContent).Split(NL + NL)
		aResult = []
		nLen = len(aRaw)

		for i = 1 to nLen
			cTrimmed = trim(aRaw[i])
			if cTrimmed != ""
				aResult + cTrimmed
			ok
		next

		return aResult

	def NthParagraph(n)
		acParas = This.Paragraphs()
		if n >= 1 and n <= len(acParas)
			return acParas[n]
		ok
		StzRaise("Index out of range!")

		def Paragraph(n)
			return This.NthParagraph(n)

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

	def NthLine(n)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringLineAt(This.Engine(), n)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

		def Line(n)
			return This.NthLine(n)

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
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

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
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def LinesDeduplicated()
		return This.LinesDeduplicatedCS(1)

	def RemoveBlankLines()
		pResult = StzEngineStringRemoveBlankLines(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

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
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

		def EmptyLinesRemoved()
			return This.BlankLinesRemoved()

	def NumberLines()
		pResult = StzEngineStringNumberLines(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def NumberLinesQ()
			This.NumberLines()
			return This

	def LinesNumbered()
		pResult = StzEngineStringNumberLines(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	  #===============================#
	 #     TEXT TRANSFORMS           #
	 #     (Engine-backed)           #
	#===============================#

	def Simplify()
		pResult = StzEngineStringSimplify(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def SimplifyQ()
			This.Simplify()
			return This

	def Simplified()
		pResult = StzEngineStringSimplify(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def CollapseSpaces()
		pResult = StzEngineStringCollapseSpaces(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def CollapseSpacesQ()
			This.CollapseSpaces()
			return This

	def SpacesCollapsed()
		pResult = StzEngineStringCollapseSpaces(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def NormalizeSpaces()
		pResult = StzEngineStringNormalizeSpaces(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def NormalizeSpacesQ()
			This.NormalizeSpaces()
			return This

	def SpacesNormalized()
		pResult = StzEngineStringNormalizeSpaces(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def ToSentenceCase()
		pResult = StzEngineStringToSentenceCase(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def ToSentenceCaseQ()
			This.ToSentenceCase()
			return This

	def SentenceCased()
		pResult = StzEngineStringToSentenceCase(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def Pluralize()
		pResult = StzEngineStringPluralize(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(cResult)

		def PluralizeQ()
			This.Pluralize()
			return This

	def Pluralized()
		pResult = StzEngineStringPluralize(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

	def ToSlug()
		pResult = StzEngineStringToSlug(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

		def Slugified()
			return This.ToSlug()

	def Abbreviate(nMaxLen)
		pResult = StzEngineStringAbbreviate(This.Engine(), nMaxLen)
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

		def Abbreviated(nMaxLen)
			return This.Abbreviate(nMaxLen)

	def Initials()
		pResult = StzEngineStringInitials(This.Engine())
		cResult = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return cResult

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


# stzText: narrative-text class. Thin subclass of stzStringText so
# tests that write 'new stzText("...")' resolve to the same behaviour.
class stzText from stzStringText

