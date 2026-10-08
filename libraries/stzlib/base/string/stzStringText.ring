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
_cParagraphSeparator = char(10)
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

# Answers questions about a text as prose: its words, sentences, paragraphs and lines, its writing systems, and common clean-ups.
#
# stzString builds one of these to answer Script, Words and the other text-level questions; build
# one directly with a text, or use stzText, which inherits from it and adds meaning-level methods.
# Words, sentences and lines follow the Unicode rules, so Hebrew, Arabic, Chinese and emoji text is
# segmented where a reader would expect. Verbs such as ReverseWords and Simplify change the held
# text in place and return nothing (the Q form returns the object so calls chain), and the past-
# tense form (WordsReversed, Simplified) returns the new text and leaves the object alone. Pass a
# plain text, not a stzString: the first edit made through the object empties the stzString that was
# passed in. Known defects today: UniqueWords keeps the punctuation stuck to a word, so ContainsWord
# misses it; ReverseEachWord and EachWordReversed break any non-ASCII word; OnlyScript, OnlyArabic
# and OnlyLatin raise errors; ToSentenceCase capitalizes only the first letter.
#
#   receiver   o1 = new stzStringText("the quick brown fox jumps over the lazy dog")
#   example    ? o1.NumberOfWords()
#              #--> 9
#              ? o1.WordsReversed()
#              #--> dog lazy the over jumps fox brown quick the
#              o2 = new stzStringText("שלום עולם")
#              ? o2.WordsReversed()
#              #--> עולם שלום
#              ? o2.Script()
#              #--> hebrew
#              o3 = new stzStringText("Hello 😀 world مرحبا")
#              ? o3.Script()
#              #--> hybrid
#              ? o3.NumberOfWords()
#              #--> 3
#   see        stzText, stzString, stzStringChecker
class stzStringText from stzObject

	@oString
	@cLanguage

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a text object from a string or from a stzString, ready to be asked about its words, sentences, lines and scripts.
	#
	#   pStrOrStzStrObj   the text, or a stzString whose content is used
	#   returns           nothing; the object is built
	#   note              pass a plain text and read the result with Content; stzText inherits from
	#                     this class and adds meaning-level methods
	#   warning           with a stzString argument, the first edit made through the text object
	#                     (Update, ReverseWords...) leaves the stzString you passed reading as an
	#                     empty text, while the text object keeps the right text (two datasets)
	#   see               Content, Copy
	#@ aka  Build the text object from a string or a stzString.
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

	# Returns the whole text as one string.
	#
	#   returns    a text
	#   see        Copy, Chars
	#@ aka  (Doc()/Ask()/AskFor()/ExplainMethod() are inherited from stzObject -- the common ground for every Softanza object.)
	def Content()
		return @oString.Content()

	def Text()
		return This.Content()

	# Returns how many characters the text holds, counting an emoji or a Hebrew letter as one.
	#
	#   returns    a number
	#   note       Hello followed by a blank and an emoji gives 7
	#   see        NumberOfChars2, Chars
	#@ aka  How many chars the text holds.
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text is empty.
	def IsEmpty()
		return @oString.IsEmpty()

	# Returns a new, independent text object with the same content.
	#
	#   returns    a stzStringText
	#   note       changing the copy does not change the original
	#   see        Content, ToStzString
	#@ aka  A new stzStringText with the same content.
	def Copy()
		return new stzStringText(This.Content())

	# Returns the same text wrapped as a stzString, for the character-level methods.
	#
	#   returns    a stzString
	#   see        Copy, Content
	#@ aka  The text wrapped as a stzString object.
	def ToStzString()
		return new stzString(This.Content())

	# Returns the handle of the engine string that holds the text.
	#
	#   returns    a number, the engine handle
	#   note       an internal handle for engine calls, not the text
	#   see        Content
	#@ aka  The engine handle of the underlying string.
	def Engine()
		return @oString.Engine()

	# Replaces the whole text by a new one.
	#
	#   pcStr      the new text, or a pair [ :With, text ]
	#   returns    nothing; the text changes
	#   see        UpdateWith, Content
	#@ aka  Replace the content with the given string (mutating).
	def Update(pcStr)
		if isList(pcStr) and IsWithOrByOrUsingNamedParamList(pcStr)
			pcStr = pcStr[2]
		ok
		@oString.Update(pcStr)

		# Replaces the whole text by a new one.
		#
		#   pcStr      the new text, or a pair [ :With, text ]
		#   returns    nothing; the text changes
		#   note       same effect as Update
		#   see        Update, Content
		#@ aka  Same as Update: replace the content (mutating).
		def UpdateWith(pcStr)
			This.Update(pcStr)

	  #===============================#
	 #     LANGUAGE                   #
	#===============================#

	# Records the working language of the text, for the callers that ask for it.
	#
	#   pcLanguage   the language name, such as English
	#   returns      nothing; the language is stored
	#   note         the text itself is not analysed differently: nothing in this class reads the
	#                language
	#   see          Language
	#@ aka  Set the working language of the text.
	def SetLanguage(pcLanguage)
		@cLanguage = pcLanguage

	# Returns the language set with SetLanguage.
	#
	#   returns    the language given, or NULL when none was set
	#   see        SetLanguage
	def Language()
		return @cLanguage

	  #===============================#
	 #     SCRIPT                    #
	#===============================#

	# Returns the dominant writing system of the text, such as latin, arabic or hebrew.
	#
	#   returns    a lower-case text; hybrid when several scripts are mixed
	#   note       digits and punctuation count as common, which is ignored when one real script is
	#              present: 12345 gives common, Hello 😀 world مرحبا gives hybrid
	#   warning    an empty text raises an error (Information about script is unavailable)
	#   see        Scripts, ScriptIs, ContainsScript
	#@ aka  The (dominant) script of the string.
	def Script()
		if This.NumberOfScripts() = 0
			StzRaise("Information about script is unavailable!")

		but This.NumberOfScripts() = 1
			return This.Scripts()[1]

		but This.NumberOfScripts() = 2 and StzFindFirst(:Common, This.Scripts()) > 0
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

	# Returns the writing systems used by the text, in order of first appearance.
	#
	#   returns    a list of lower-case text
	#   note       the blank counts as common: the Hebrew text שלום עולם gives hebrew, common
	#   see        Script, NumberOfScripts, ContainsScript
	#@ aka  The scripts used in the string.
	def Scripts()
		# One engine pass over the codepoints.
		#
		# This used to build a stzChar OBJECT for every character just to ask
		# each one its script -- the wrap-to-validate pattern at character
		# granularity. 139ms per call on a 200-char string, and because Ring
		# has no destructors, enough repeated calls exhausted object
		# allocation outright: "Can not create char object!".
		#
		# The engine mirrors _CharScriptCode branch for branch, ORDER
		# included, so the answer is unchanged -- common before latin, the
		# combining marks and Arabic diacritics still `inherited`, and the
		# names still first-appearance ordered. Deliberately NOT the engine's
		# own 8-script classifier, which would have collapsed hangul,
		# hiragana, katakana, armenian and gujarati into one bucket.

		return StzEngineStringScriptNamesList(@oString.Engine())

	# Returns how many different writing systems the text uses.
	#
	#   returns    a number
	#   note       blanks and punctuation count as one more script, common
	#   see        Scripts, CountScripts
	#@ aka  How many scripts the string uses.
	def NumberOfScripts()
		return len(This.Scripts())

	# Returns how many different writing systems the text uses.
	#
	#   returns    a number
	#   note       same answer as NumberOfScripts
	#   see        NumberOfScripts, Scripts
	#@ aka  How many scripts the text uses.
	def CountScripts()
		return len(This.Scripts())

	# Returns how many different writing systems the text uses.
	#
	#   returns    a number
	#   note       same answer as NumberOfScripts
	#   see        NumberOfScripts, Scripts
	#@ aka  How many distinct scripts the text uses.
	def NumberOfDistinctScripts()
		return len(This.Scripts())

	# TRUE if the dominant writing system of the text is the given one.
	#
	#   _cScript_   the script name, such as :Latin, :Hebrew or :Hybrid
	#   returns     TRUE or FALSE, as 1 or 0
	#   see         Script, ContainsScript
	#@ aka  TRUE if the text's dominant script is the given one.
	def ScriptIs(_cScript_)
		return This.Script() = _cScript_

	# TRUE if at least one character of the text belongs to the given writing system.
	#
	#   _cScript_   the script name, such as :Arabic
	#   returns     TRUE or FALSE, as 1 or 0
	#   see         ScriptIs, Scripts
	#@ aka  TRUE if the text uses the given script.
	def ContainsScript(_cScript_)
		return StzFindFirst(_cScript_, This.Scripts()) > 0

	# TRUE if the text contains Arabic-script content.
	def ContainsArabicScript()
		return This.ContainsScript(:Arabic)

	# TRUE if the text contains Latin-script content.
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

	# Raises error R24 today instead of returning the part of the text written in a given script.
	#
	#   pcScript   the script name to keep
	#   returns    nothing; it raises an error
	#   note       read the characters with ToStzString().Chars() and keep the ones you want
	#              meanwhile
	#   warning    raises Using uninitialized variable pcscript for :Latin, :Hebrew and :Arabic
	#              alike: the anonymous function it builds does not see its own parameter
	#   see        OnlyLatin, OnlyArabic, Script
	def OnlyScript(pcScript)
		# WF (anonymous function) instead of an eval()'d textual condition --
		# the function captures pcScript and calls the real stzChar method.
		_acListOfChars_ = StzListQ(This.ToStzString().ToListOfChars()).ItemsWF(
			func c { return StzCharQ(c).Script() = pcScript } )
		_cResult_ = StzListOfStringsQ(_acListOfChars_).ConcatenateQ().SimplifyQ().Content()
		return _cResult_

	# Raises error R14 today instead of returning the Arabic-script part of the text.
	#
	#   returns    nothing; it raises an error
	#   note       read the characters with ToStzString().Chars() and keep the ones you want
	#              meanwhile
	#   warning    raises Calling Method without definition: concatenateq on a Latin text and on an
	#              Arabic text alike
	#   see        OnlyLatin, OnlyScript, ContainsScript
	def OnlyArabic()
		_acListOfChars_ = StzListQ(This.ToStzString().ToListOfChars()).ItemsWF(
			func c { return StzCharQ(c).IsNeutral() or StzCharQ(c).IsSpace() or StzCharQ(c).IsArabic() } )
		_cResult_ = StzListOfStringsQ(_acListOfChars_).ConcatenateQ().SimplifyQ().Content()
		return _cResult_

	# Raises error R14 today instead of returning the Latin-script part of the text.
	#
	#   returns    nothing; it raises an error
	#   note       read the characters with ToStzString().Chars() and keep the ones you want
	#              meanwhile
	#   warning    raises Calling Method without definition: concatenateq on a Latin text and on a
	#              mixed text alike
	#   see        OnlyArabic, OnlyScript, ContainsScript
	def OnlyLatin()
		_acListOfChars_ = StzListQ(This.ToStzString().ToListOfChars()).ItemsWF(
			func c { return StzCharQ(c).IsNeutral() or StzCharQ(c).IsSpace() or StzCharQ(c).IsLatin() } )
		_cResult_ = StzListOfStringsQ(_acListOfChars_).ConcatenateQ().SimplifyQ().Content()
		return _cResult_

	  #===============================#
	 #     WORDS (Engine-backed)     #
	#===============================#

	# Returns how many words the text holds, by the Unicode word rules.
	#
	#   returns    a number
	#   note       punctuation and emoji are not words; each Chinese character is one word
	#   see        Words, NumberOfUniqueWords
	#@ aka  How many words the text holds.
	def NumberOfWords()
		return StzEngineStringCountWords(This.Engine())

		def CountWords()
			return This.NumberOfWords()

		def HowManyWords()
			return This.NumberOfWords()

	# Returns the word at the given rank, counted from 1.
	#
	#   _n_        the rank of the word, counted from 1
	#   returns    a text; an empty text when the rank is outside the text
	#   note       the second word of the quick brown fox is quick
	#   see        FirstWord, LastWord, Words
	#@ aka  The nth word of the text.
	def NthWord(_n_)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringNthWord(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

		def Word(_n_)
			return This.NthWord(_n_)

	# Returns the first word of the text.
	#
	#   returns    a text; an empty text when there is no word
	#   see        LastWord, NthWord
	#@ aka  The first word of the string.
	def FirstWord()
		pResult = StzEngineStringFirstWord(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Returns the last word of the text.
	#
	#   returns    a text; an empty text when there is no word
	#   see        FirstWord, NthWord
	#@ aka  The last word of the string.
	def LastWord()
		pResult = StzEngineStringLastWord(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Returns the words of the text, in order, as a list.
	#
	#   returns    a list of text; an empty list when there is no word
	#   note       punctuation is dropped: Hello world. gives Hello, world; WordsQ returns it as a
	#              stzList, WordsU keeps each word once and WordsZ pairs each word with its
	#              positions
	#   see        NumberOfWords, UniqueWords, WordsAndTheirPositions
	#@ aka  The words of the text, as a list (engine-extracted).
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

	# Returns each distinct word once, in order of first appearance, with the punctuation stuck to it.
	#
	#   returns    a list of text
	#   note       UniqueWordsCS(0) merges words that differ only by case
	#   warning    the words keep their neighbouring punctuation, so Hello world. Bye world, ok
	#              gives world. and world, as two different words, where Words gives world;
	#              ContainsWord, ContainsEachWord and NumberOfUniqueWords read this list and are
	#              wrong for the words that touch a punctuation mark
	#   see        Words, NumberOfUniqueWords, ContainsWord
	def UniqueWords()
		return This.UniqueWordsCS(1)

		def SetOfWords()
			return This.UniqueWords()

		def WordsU()
			return This.UniqueWords()

	# Returns how many different words the text holds.
	#
	#   returns    a number
	#   note       the quick brown fox jumps over the lazy dog gives 8
	#   warning    counts the words with their stuck punctuation, as UniqueWords does: world. and
	#              world, are two
	#   see        UniqueWords, NumberOfWords
	#@ aka  How many distinct words the text holds.
	def NumberOfUniqueWords()
		return len(This.UniqueWords())

	  #------------------------------------------#
	 #     WORD CHECKS                          #
	#------------------------------------------#

	# TRUE if the text is a single word.
	def IsWord()
		if @oString.IsEmpty()
			return 0
		ok
		_pH_ = @oString.Engine()
		return StzEngineStringIsWord(_pH_)

	# TRUE if the text is a single Arabic-script word.
	def IsArabicWord()
		if This.IsWord() and This.ScriptIs(:Arabic)
			return 1
		else
			return 0
		ok

	# TRUE if the text is a single Latin-script word.
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

	# TRUE if the given word occurs as a whole word in the text.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a part of a word is not a word: fo is not found in fox; ContainsWordCS("FOX", 0)
	#              ignores case
	#   warning    a word followed by a punctuation mark is not found: ContainsWord("world") is
	#              FALSE on Hello world. Bye, and ContainsWord("بالعالم") is FALSE on an Arabic
	#              sentence where that word is followed by a full stop; a non-text argument raises
	#              an error
	#   see        ContainsEachWord, NumberOfOccurrenceOfWord, Words
	def ContainsWord(pcWord)
		return This.ContainsWordCS(pcWord, 1)

		# TRUE if the text contains NONE of the given words.
		def ContainsNoWord(pcWord)
			return NOT This.ContainsWord(pcWord)

	# TRUE if the text contains EVERY one of the given words.
	def ContainsEachWordCS(pacWords, pCaseSensitive)
		_nLen_ = len(pacWords)
		for i = 1 to _nLen_
			if NOT This.ContainsWordCS(pacWords[i], pCaseSensitive)
				return 0
			ok
		next
		return 1

	# TRUE if every word of the given list occurs as a whole word in the text.
	#
	#   pacWords   the list of words that must all be present
	#   returns    TRUE or FALSE, as 1 or 0
	#   warning    it uses ContainsWord, so a word followed by a punctuation mark is not found
	#   see        ContainsWord, Words
	def ContainsEachWord(pacWords)
		return This.ContainsEachWordCS(pacWords, 1)

	  #------------------------------------------#
	 #     WORD TRANSFORMS (Engine-backed)      #
	#------------------------------------------#

	# Reverses the order of the words, in place, and joins them with single blanks.
	#
	#   returns    nothing; the text changes. ReverseWordsQ returns the object for chaining
	#   note       the quick brown fox gives fox brown quick the, and one two three with extra
	#              blanks gives three two one
	#   see        WordsReversed, ReverseEachWord
	#@ aka  Reverse the ORDER of the words in place (mutating).
	def ReverseWords()
		pResult = StzEngineStringReverseWords(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def ReverseWordsQ()
			This.ReverseWords()
			return This

	# Returns the text with the order of its words reversed, leaving the object unchanged.
	#
	#   returns    a text
	#   note       Hebrew and Arabic words keep their letters: שלום עולם gives עולם שלום
	#   see        ReverseWords, EachWordReversed
	#@ aka  The words in reverse order, as a copy.
	def WordsReversed()
		pResult = StzEngineStringReverseWords(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Sort the words in place (mutating).
	def SortWordsCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pResult = StzEngineStringSortWordsCS(This.Engine(), _bCase_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def SortWordsCSQ(pCaseSensitive)
			This.SortWordsCS(pCaseSensitive)
			return This

	# Sorts the words alphabetically, in place, with capitals first.
	#
	#   returns    nothing; the text changes. SortWordsQ returns the object for chaining
	#   note       the order is by code point: The the THE cat Cat gives Cat THE The cat the, and
	#              SortWordsCS(0) ignores case and gives cat Cat The the THE
	#   see        WordsSorted, ReverseWords
	def SortWords()
		This.SortWordsCS(1)

		def SortWordsQ()
			This.SortWords()
			return This

	# The words sorted, as a copy; the original is unchanged.
	def WordsSortedCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pResult = StzEngineStringSortWordsCS(This.Engine(), _bCase_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Returns the words sorted alphabetically as one text, leaving the object unchanged.
	#
	#   returns    a text
	#   note       WordsSortedInAscending returns the same words as a list
	#   see        SortWords, WordsSortedInAscending
	def WordsSorted()
		return This.WordsSortedCS(1)

	# Corrupts any non-ASCII word today: it reverses the bytes of each word, in place, and the text ends up empty.
	#
	#   returns    nothing; the text changes
	#   note       reverse the letters of a Hebrew or Arabic word with stzStringCharList.Reversed
	#              meanwhile
	#   warning    on שלום עולם, on a😀 b and on été vert the text reads as empty afterwards, because
	#              a reversed byte sequence is not valid text; ASCII words are reversed correctly
	#              (the quick gives eht kciuq)
	#   see        EachWordReversed, ReverseWords
	#@ aka  Reverse the CHARS of each word in place (mutating).
	def ReverseEachWord()
		pResult = StzEngineStringReverseEachWord(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def ReverseEachWordQ()
			This.ReverseEachWord()
			return This

	# Returns the text with the bytes of each word reversed, which is only right for ASCII words.
	#
	#   returns    a text; garbled bytes for a word with non-ASCII characters
	#   note       same defect as ReverseEachWord
	#   warning    Hebrew, Arabic, emoji and accented words come back as unreadable bytes: été vert
	#              gives garbage followed by trev, while the quick gives eht kciuq
	#   see        ReverseEachWord, WordsReversed
	#@ aka  Each word with its chars reversed, as a copy.
	def EachWordReversed()
		pResult = StzEngineStringReverseEachWord(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Deletes the word at the given rank, in place.
	#
	#   _n_        the rank of the word, counted from 1
	#   returns    nothing; the text changes. RemoveNthWordQ returns the object for chaining
	#   note       the quick brown fox with 2 gives the brown fox
	#   see        NthWordRemoved, InsertWordAt, TruncateWords
	#@ aka  Remove the nth word (mutating).
	def RemoveNthWord(_n_)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringRemoveNthWord(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def RemoveNthWordQ(_n_)
			This.RemoveNthWord(_n_)
			return This

	# Returns the text without the word at the given rank, leaving the object unchanged.
	#
	#   _n_        the rank of the word, counted from 1
	#   returns    a text
	#   see        RemoveNthWord, WordsTruncated
	#@ aka  A copy with the nth word removed.
	def NthWordRemoved(_n_)
		pResult = StzEngineStringRemoveNthWord(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Inserts a word so that it takes the given rank, in place.
	#
	#   _n_        the rank the new word takes, counted from 1, 0 meaning the start
	#   pcWord     the word to insert
	#   returns    nothing; the text changes. InsertWordAtQ returns the object for chaining
	#   note       Hello world with 2 and x gives Hello x world
	#   see        RemoveNthWord, SwapWords
	#@ aka  Insert the given word at word-position n (mutating).
	def InsertWordAt(_n_, pcWord)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringInsertWordAt(This.Engine(), _n_, pcWord)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def InsertWordAtQ(_n_, pcWord)
			This.InsertWordAt(_n_, pcWord)
			return This

	# Exchanges two words, given by their ranks, in place.
	#
	#   n1         the rank of the first word, counted from 1
	#   n2         the rank of the second word
	#   returns    nothing; the text changes. SwapWordsQ returns the object for chaining
	#   note       the words are joined by single blanks afterwards
	#   see        InsertWordAt, ReverseWords
	#@ aka  Exchange the words at the two given word-positions (mutating).
	def SwapWords(n1, n2)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringSwapWords(This.Engine(), n1, n2)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def SwapWordsQ(n1, n2)
			This.SwapWords(n1, n2)
			return This

	# Keeps only the first words, in place.
	#
	#   _n_        how many words to keep
	#   returns    nothing; the text changes. TruncateWordsQ returns the object for chaining
	#   note       the quick brown fox with 3 gives the quick brown
	#   see        WordsTruncated, RemoveNthWord
	#@ aka  Keep only the first n words (mutating).
	def TruncateWords(_n_)
		pResult = StzEngineStringTruncateWords(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def TruncateWordsQ(_n_)
			This.TruncateWords(_n_)
			return This

	# Returns the first words of the text, leaving the object unchanged.
	#
	#   _n_        how many words to keep
	#   returns    a text
	#   see        TruncateWords, NthWordRemoved
	#@ aka  A copy keeping only the first n words.
	def WordsTruncated(_n_)
		pResult = StzEngineStringTruncateWords(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Deletes the words that already appeared earlier, keeping the first of each, in place.
	#
	#   returns    nothing; the text changes. RemoveDuplicateWordsQ returns the object for chaining
	#   note       case counts: The the THE stay three words
	#   see        DuplicateWordsRemoved, UniqueWords
	#@ aka  Remove the repeated words, keeping first occurrences (mutating).
	def RemoveDuplicateWords()
		pResult = StzEngineStringRemoveDuplicateWords(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def RemoveDuplicateWordsQ()
			This.RemoveDuplicateWords()
			return This

	# Returns the text with each repeated word kept once, leaving the object unchanged.
	#
	#   returns    a text
	#   note       the quick brown fox jumps over the lazy dog loses its second the
	#   see        RemoveDuplicateWords, UniqueWords
	#@ aka  A copy with the repeated words removed.
	def DuplicateWordsRemoved()
		pResult = StzEngineStringRemoveDuplicateWords(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Returns how many words in the text are exactly the given text.
	#
	#   pcPattern   the text a word must equal, case counted, taken as it is written and not as a
	#               regular expression
	#   returns     a number
	#   note        a word stuck to a punctuation mark only matches with it
	#   warning     the pattern is compared with the blank-separated pieces of the text, punctuation
	#               included, and is not a regular expression or a wildcard: on Hello, World! hello
	#               again the pattern hello counts 1, Hello, counts 1 and [a-z]+, H* and ^again$
	#               count 0
	#   see         NumberOfOccurrenceOfWord, ContainsWord
	#@ aka  How many words match the given pattern.
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

	# Returns how many times the given word occurs as a whole word.
	#
	#   returns    a number
	#   note       punctuation next to the word does not matter, and a part of a word does not
	#              count: he is 0 in the quick brown fox jumps over the lazy dog, and the is 2;
	#              NumberOfOccurrenceOfWordCS("THE", 0) ignores case
	#   see        WordFrequency, ContainsWord, WordsAndTheirCounts
	def NumberOfOccurrenceOfWord(pcWord)
		return This.NumberOfOccurrenceOfWordCS(pcWord, 1)

		def NumberOfOccurrencesOfWord(pcWord)
			return This.NumberOfOccurrenceOfWord(pcWord)

	# Returns the share of the words of the text that are the given word, as a fraction between 0 and 1.
	#
	#   pcWord     the word whose share is wanted
	#   returns    a number such as 0.22 for the in the quick brown fox jumps over the lazy dog
	#   note       an absent word gives 0
	#   warning    raises an error on a text with no word; it returns one number for the word asked
	#              and does not pair every word with its frequency, which is
	#              WordsAndTheirFrequencies
	#   see        NumberOfOccurrenceOfWord, WordsAndTheirFrequencies
	#@ aka  Each word paired with its frequency.
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

	# Returns each distinct word with the number of times it occurs, in order of first appearance.
	#
	#   returns    a list of [ word, count ] pairs
	#   note       punctuation is dropped, and case counts: The the THE gives three entries,
	#              WordsAndTheirCountsCS(0) gives The with 3
	#   see        MostFrequentWords, WordsAndTheirFrequencies, UniqueWords
	def WordsAndTheirCounts()
		return This.WordsAndTheirCountsCS(1)

	# The top-N most frequent words as [[word, count], ...], count descending
	# (ties by first appearance). ENGINE-DIRECT, ONE pass + partial rank.
	def MostFrequentWordsCS(_n_, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return This._DrainWordFreq( StzEngineStringWordFreq(This.Engine(), _bCase_, _n_) )

	# Returns the most frequent words with their counts, the highest count first.
	#
	#   _n_        how many words to return
	#   returns    a list of [ word, count ] pairs, at most as many as asked
	#   note       the quick brown fox jumps over the lazy dog with 2 gives the with 2 and quick
	#              with 1
	#   see        MostFrequentWord, NMostFrequentWords, WordsAndTheirCounts
	def MostFrequentWords(_n_)
		return This.MostFrequentWordsCS(_n_, 1)

	# Returns each distinct word with its share of all the words, in order of first appearance.
	#
	#   returns    a list of [ word, fraction ] pairs; an empty list when there is no word
	#   note       the shares add up to 1
	#   see        WordFrequency, WordsAndTheirCounts
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

	# Returns the word that occurs most often, the first one met in case of a tie.
	#
	#   returns    a text; an empty text when there is no word
	#   note       case counts: The the THE gives The
	#   see        LessFrequentWord, MostFrequentWords
	#@ aka  The word that occurs most often in the string.
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

	# Returns the word that occurs least often, the first one met in case of a tie.
	#
	#   returns    a text; an empty text when there is no word
	#   note       in the quick brown fox jumps over the lazy dog every word but the occurs once, so
	#              it gives quick
	#   see        MostFrequentWord, WordsAndTheirCounts
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

	# Returns the most frequent words, without their counts, the highest count first.
	#
	#   _n_        how many words to return
	#   returns    a list of text, at most as many as asked
	#   note       the quick brown fox jumps over the lazy dog with 2 gives the and quick
	#   see        MostFrequentWords, MostFrequentWord
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

	# Returns the start positions of every occurrence of every word, as one flat list in text order.
	#
	#   returns    a list of numbers
	#   note       the quick brown fox jumps over the lazy dog gives 1, 5, 11, 17, 21, 27, 32, 36,
	#              41
	#   see        WordsAndTheirPositions, Words
	def WordsPositions()
		_acWordsU_ = This.UniqueWords()
		_oTempStr_ = new stzString(This.Content())
		_anResult_ = _oTempStr_.FindMany(_acWordsU_)
		return _anResult_

	# Returns each distinct word with the start positions of all its occurrences.
	#
	#   returns    a list of [ word, positions ] pairs
	#   note       positions count characters, and the positions of a word are found without regard
	#              to case
	#   see        WordsPositions, Words
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

	# Returns the order in which the words already come: ascending, descending or unsorted.
	#
	#   returns    a lower-case text: ascending, descending or unsorted
	#   note       the comparison is by code point, capitals first; apple banana cherry gives
	#              ascending
	#   see        WordsAreSorted, SortWords
	def WordsSortingOrder()
		_cResult_ = :Unsorted

		if This.WordsAreSortedInAscending()
			_cResult_ = :Ascending
		but This.WordsAreSortedInDescending()
			_cResult_ = :Descending
		ok

		return _cResult_

	# TRUE if the words are already in ascending or in descending order.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       one word or none counts as sorted
	#   see        WordsSortingOrder, WordsAreSortedInAscending
	def WordsAreSorted()
		return This.WordsAreSortedInAscending() or This.WordsAreSortedInDescending()

	# TRUE if each word comes before or equals the next, by code point.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       apple banana cherry answers TRUE; a capital comes before every small letter
	#   see        WordsAreSortedInDescending, WordsSortingOrder
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

	# TRUE if each word comes after or equals the next, by code point.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       cherry banana apple answers TRUE
	#   see        WordsAreSortedInAscending, WordsSortingOrder
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

	# Returns the words sorted from the smallest to the largest, as a list, leaving the text unchanged.
	#
	#   returns    a list of text
	#   note       repeated words are kept
	#   see        WordsSortedInDescending, WordsSorted
	def WordsSortedInAscending()
		_acResult_ = This.Words()
		return StzListOfStringsQ(_acResult_).SortedInAscending()

	# Returns the words sorted from the largest to the smallest, as a list, leaving the text unchanged.
	#
	#   returns    a list of text
	#   note       repeated words are kept
	#   see        WordsSortedInAscending, WordsSorted
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
			if StzFindFirst(StzCaseFold(_acWords_[i]), _acExclude_) = 0
				_aResult_ + _acWords_[i]
			ok
		next

		return _aResult_

	  #===============================#
	 #     SENTENCES (Engine-backed) #
	#===============================#

	# Returns how many sentences the text holds, by the Unicode sentence rules.
	#
	#   returns    a number
	#   note       a full stop followed by a lower-case letter does not end a sentence
	#   see        Sentences, NumberOfParagraphs
	#@ aka  How many sentences the string holds.
	def NumberOfSentences()
		return StzEngineStringCountSentences(This.Engine())

		def CountSentences()
			return This.NumberOfSentences()

		def SentenceCount()
			return This.NumberOfSentences()

		def HowManySentences()
			return This.NumberOfSentences()

	# Returns the sentences of the text, in order, as a list.
	#
	#   returns    a list of text; an empty list when the text is empty
	#   note       a line break also ends a sentence; Hello there. How are you? Fine! gives three
	#   see        NumberOfSentences, NthSentence
	#@ aka  The sentences of the text, as a list.
	def Sentences()
		# Route through the engine's UAX#29 SentenceIter -- the same seam
		# NumberOfSentences() beside it already uses, and the same one
		# stzString.Sentences() uses.
		#
		# This used to be a hand-rolled character loop that broke on EVERY
		# '.', '!', '?' or Arabic question mark. It therefore disagreed with
		# its own NumberOfSentences() on most real text, and the TEXT layer
		# -- the one whose whole job is sentence-level meaning -- segmented
		# worse than the plain string class:
		#
		#   "Wow!!!! Yes."                     count 2, list 5
		#   "Dr. Smith arrived. He was late."  count 2, list 3
		#   "Visit example.com now."           count 1, list 2
		#   "Hmm... Yes."                      count 2, list 4
		#
		# UAX#29 keeps a RUN of terminators together (SB8a/SB9/SB10), and the
		# engine additionally suppresses a break after a known abbreviation or
		# initial. Ellipses and emphatic punctuation are ordinary in real
		# text, so every sentence-level analytic above this -- sentiment per
		# sentence, summaries, readability -- was being fed fragments.
		#
		# It also walked Chars(), exploding the whole text into a Ring list of
		# one-character strings before doing any work.

		return StzEngineStringSentencesList(This.Engine())

	# Returns the sentence at the given rank, counted from 1.
	#
	#   _n_        the rank of the sentence, counted from 1
	#   returns    a text
	#   see        FirstSentence, LastSentence, Sentences
	#@ aka  The nth sentence of the text.
	def NthSentence(_n_)
		_acSentences_ = This.Sentences()
		if _n_ >= 1 and _n_ <= len(_acSentences_)
			return _acSentences_[_n_]
		ok
		StzRaise("Index out of range!")

		def Sentence(_n_)
			return This.NthSentence(_n_)

	# Returns the first sentence of the text.
	#
	#   returns    a text; an empty text raises an error
	#   note       Hello there. How are you? Fine! gives Hello there.
	#   see        LastSentence, NthSentence
	#@ aka  The first sentence of the text.
	def FirstSentence()
		return This.NthSentence(1)

	# Returns the last sentence of the text.
	#
	#   returns    a text; an empty text raises an error
	#   see        FirstSentence, NthSentence
	#@ aka  The last sentence of the text.
	def LastSentence()
		return This.NthSentence(len(This.Sentences()))

	  #===============================#
	 #     PARAGRAPHS (Engine-backed)#
	#===============================#

	# Returns how many paragraphs the text holds, a paragraph being cut off by an empty line.
	#
	#   returns    a number
	#   note       a line holding only blanks does not cut a paragraph
	#   see        Paragraphs, NumberOfLines
	#@ aka  How many paragraphs the string holds.
	def NumberOfParagraphs()
		return StzEngineStringCountParagraphs(This.Engine())

		def CountParagraphs()
			return This.NumberOfParagraphs()

		def HowManyParagraphs()
			return This.NumberOfParagraphs()

	# Returns the paragraphs of the text, trimmed, as a list.
	#
	#   returns    a list of text; an empty list when the text is empty
	#   note       the text is cut at each empty line, so line breaks stay inside a paragraph
	#   see        NumberOfParagraphs, NthParagraph
	#@ aka  The paragraphs of the string, as a list.
	def Paragraphs()
		_cContent_ = This.Content()
		if _cContent_ = ""
			return []
		ok

		# Split on double newlines (paragraph boundary)
		_aRaw_ = StzStringQ(_cContent_).Split(char(10) + char(10))
		_aResult_ = []
		_nLen_ = len(_aRaw_)

		for i = 1 to _nLen_
			_cTrimmed_ = trim(_aRaw_[i])
			if _cTrimmed_ != ""
				_aResult_ + _cTrimmed_
			ok
		next

		return _aResult_

	# Returns the paragraph at the given rank, counted from 1.
	#
	#   _n_        the rank of the paragraph, counted from 1
	#   returns    a text
	#   see        FirstParagraph, LastParagraph, Paragraphs
	#@ aka  The nth paragraph of the string.
	def NthParagraph(_n_)
		_acParas_ = This.Paragraphs()
		if _n_ >= 1 and _n_ <= len(_acParas_)
			return _acParas_[_n_]
		ok
		StzRaise("Index out of range!")

		def Paragraph(_n_)
			return This.NthParagraph(_n_)

	# Returns the first paragraph of the text.
	#
	#   returns    a text; an empty text raises an error
	#   see        LastParagraph, NthParagraph
	def FirstParagraph()
		return This.NthParagraph(1)

	# Returns the last paragraph of the text.
	#
	#   returns    a text; an empty text raises an error
	#   see        FirstParagraph, NthParagraph
	#@ aka  The last paragraph of the text.
	def LastParagraph()
		return This.NthParagraph(len(This.Paragraphs()))

	  #===============================#
	 #     LINES (Engine-backed)     #
	#===============================#

	# Returns how many lines the text holds.
	#
	#   returns    a number
	#   note       a final line break counts as one more, empty, line: hello, world and a line break
	#              give 3
	#   see        Lines, NumberOfParagraphs
	#@ aka  How many lines the text holds.
	def NumberOfLines()
		return StzEngineStringCountLines(This.Engine())

		def CountLines()
			return This.NumberOfLines()

		def HowManyLines()
			return This.NumberOfLines()

	# Returns the lines of the text, in order, as a list.
	#
	#   returns    a list of text; the empty text gives one empty line
	#   note       empty lines are kept
	#   see        NumberOfLines, NthLine
	#@ aka  The lines of the text, as a list.
	def Lines()
		return @SplitCS(@oString.Content(), char(10), 1)

	# Returns the line at the given rank, counted from 1.
	#
	#   _n_        the rank of the line, counted from 1
	#   returns    a text; an empty text when the rank is outside the text
	#   see        FirstLine, LastLine, Lines
	#@ aka  The nth line of the text.
	def NthLine(_n_)
		# Engine uses INDEX_BASE=1, no manual adjustment needed
		pResult = StzEngineStringLineAt(This.Engine(), _n_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

		def Line(_n_)
			return This.NthLine(_n_)

	# Returns the first line of the text.
	#
	#   returns    a text
	#   see        LastLine, NthLine
	#@ aka  The first line of the text.
	def FirstLine()
		return This.NthLine(1)

	# Returns the last line of the text.
	#
	#   returns    a text; empty when the text ends with a line break
	#   see        FirstLine, NthLine
	#@ aka  The last line of the text.
	def LastLine()
		return This.NthLine(This.NumberOfLines())

	  #------------------------------------------#
	 #     LINE TRANSFORMS (Engine-backed)      #
	#------------------------------------------#

	# Remove the repeated lines, keeping first occurrences
	# (mutating).
	def DeduplicateLinesCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pResult = StzEngineStringDeduplicateLinesCS(This.Engine(), _bCase_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def DeduplicateLinesCSQ(pCaseSensitive)
			This.DeduplicateLinesCS(pCaseSensitive)
			return This

	# Deletes the lines that already appeared earlier, keeping the first of each, in place.
	#
	#   returns    nothing; the text changes. DeduplicateLinesQ returns the object for chaining
	#   note       case counts by default: one, One, one, two keeps one, One, two, and
	#              DeduplicateLinesCS(0) keeps one, two
	#   see        LinesDeduplicated, RemoveBlankLines
	def DeduplicateLines()
		return This.DeduplicateLinesCS(1)

		def DeduplicateLinesQ()
			This.DeduplicateLines()
			return This

	# A copy with the repeated lines removed.
	def LinesDeduplicatedCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pResult = StzEngineStringDeduplicateLinesCS(This.Engine(), _bCase_)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Returns the text with each repeated line kept once, leaving the object unchanged.
	#
	#   returns    a text
	#   note       LinesDeduplicatedCS(0) ignores case
	#   see        DeduplicateLines, BlankLinesRemoved
	def LinesDeduplicated()
		return This.LinesDeduplicatedCS(1)

	# Deletes the empty lines and the lines holding only blanks, in place.
	#
	#   returns    nothing; the text changes. RemoveBlankLinesQ returns the object for chaining
	#   note       the other lines keep their text and their order
	#   see        BlankLinesRemoved, DeduplicateLines
	#@ aka  Remove the blank lines (mutating).
	def RemoveBlankLines()
		pResult = StzEngineStringRemoveBlankLines(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def RemoveBlankLinesQ()
			This.RemoveBlankLines()
			return This

		# Deletes the empty lines and the lines holding only blanks, in place.
		#
		#   returns    nothing; the text changes. RemoveEmptyLinesQ returns the object for chaining
		#   note       same effect as RemoveBlankLines
		#   see        RemoveBlankLines, BlankLinesRemoved
		def RemoveEmptyLines()
			This.RemoveBlankLines()

		def RemoveEmptyLinesQ()
			This.RemoveBlankLines()
			return This

	# Returns the text without its empty and blank-only lines, leaving the object unchanged.
	#
	#   returns    a text
	#   see        RemoveBlankLines, LinesDeduplicated
	#@ aka  A copy with the blank lines removed.
	def BlankLinesRemoved()
		pResult = StzEngineStringRemoveBlankLines(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

		def EmptyLinesRemoved()
			return This.BlankLinesRemoved()

	# Puts the line number and a colon in front of every line, in place.
	#
	#   returns    nothing; the text changes. NumberLinesQ returns the object for chaining
	#   note       empty lines are numbered too: the first line becomes 1: followed by the line
	#   see        LinesNumbered, Lines
	#@ aka  Prefix each line with its number (mutating).
	def NumberLines()
		pResult = StzEngineStringNumberLines(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def NumberLinesQ()
			This.NumberLines()
			return This

	# Returns the text with every line prefixed by its number and a colon, leaving the object unchanged.
	#
	#   returns    a text
	#   see        NumberLines, Lines
	#@ aka  A copy with each line prefixed by its number.
	def LinesNumbered()
		pResult = StzEngineStringNumberLines(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	  #===============================#
	 #     TEXT TRANSFORMS           #
	 #     (Engine-backed)           #
	#===============================#

	# Collapses every run of blanks, tabs and line breaks into one blank and trims the ends, in place.
	#
	#   returns    nothing; the text changes. SimplifyQ returns the object for chaining
	#   note       line breaks go too: a, two tabs, b, two line breaks, c, two blanks and d gives a
	#              b c d
	#   see        Simplified, NormalizeSpaces, CollapseSpaces
	#@ aka  Collapse the whitespace runs to single spaces (mutating).
	def Simplify()
		pResult = StzEngineStringSimplify(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		def SimplifyQ()
			This.Simplify()
			return This

	# Returns the text with every run of blanks, tabs and line breaks collapsed into one blank and the ends trimmed, leaving the object unchanged.
	#
	#   returns    a text
	#   see        Simplify, SpacesNormalized
	#@ aka  A copy with the whitespace runs collapsed to single spaces.
	def Simplified()
		pResult = StzEngineStringSimplify(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Collapses every run of blanks, tabs and line breaks into one blank and trims the ends, in place.
	#
	#   returns    nothing; the text changes. CollapseSpacesQ returns the object for chaining
	#   note       line breaks go too, as with Simplify; two blanks, too, three blanks and many give
	#              too many
	#   see        SpacesCollapsed, Simplify, NormalizeSpaces
	#@ aka  Collapse the space runs to single spaces (mutating, engine-backed).
	def CollapseSpaces()
		pResult = StzEngineStringCollapseSpaces(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		# Collapse the space runs, chainable.
		def CollapseSpacesQ()
			This.CollapseSpaces()
			return This

	# Returns the text with every run of blanks, tabs and line breaks collapsed into one blank and the ends trimmed, leaving the object unchanged.
	#
	#   returns    a text
	#   see        CollapseSpaces, SpacesNormalized
	#@ aka  A copy with the space runs collapsed; the original is unchanged.
	def SpacesCollapsed()
		pResult = StzEngineStringCollapseSpaces(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Collapses the runs of blanks and tabs into one blank and trims the ends, keeping the line breaks, in place.
	#
	#   returns    nothing; the text changes. NormalizeSpacesQ returns the object for chaining
	#   note       a, tabs, b, two line breaks, c, two blanks, d gives a b, the two line breaks, c d
	#   see        SpacesNormalized, Simplify, CollapseSpaces
	#@ aka  Normalize the whitespace (trim + collapse) in place (mutating).
	def NormalizeSpaces()
		pResult = StzEngineStringNormalizeSpaces(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		# Normalize the whitespace, chainable.
		def NormalizeSpacesQ()
			This.NormalizeSpaces()
			return This

	# Returns a copy where each run of blanks or tabs is one blank and the ends are trimmed, line breaks kept.
	#
	#   returns    a text
	#   see        NormalizeSpaces, Simplified
	#@ aka  A copy with the whitespace normalized; the original is unchanged.
	def SpacesNormalized()
		pResult = StzEngineStringNormalizeSpaces(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Capitalizes the first letter of the text, in place.
	#
	#   returns    nothing; the text changes. ToSentenceCaseQ returns the object for chaining
	#   note       the sentences it works on are the ones cut by the Unicode rules, which do not cut
	#              before a lower-case letter
	#   warning    the letters that start the later sentences stay as they are in the cases tried:
	#              one. two. three. gives One. two. three., hello world. this is it! and so on? yes
	#              gives Hello world. this is it! and so on? yes, and it works! really? yes. gives
	#              It works! really? yes.
	#   see        SentenceCased, Sentences
	#@ aka  Sentence-case the text (each sentence's first letter capitalized) -- mutating.
	def ToSentenceCase()
		pResult = StzEngineStringToSentenceCase(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		# Sentence-case the text, chainable.
		def ToSentenceCaseQ()
			This.ToSentenceCase()
			return This

	# Returns the text with its first letter capitalized, leaving the object unchanged.
	#
	#   returns    a text
	#   warning    the later sentences are not capitalized in the cases tried, as with
	#              ToSentenceCase
	#   see        ToSentenceCase, Sentences
	#@ aka  A sentence-cased copy; the original is unchanged.
	def SentenceCased()
		pResult = StzEngineStringToSentenceCase(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Turns the text into its English plural, in place, as if it were one word.
	#
	#   returns    nothing; the text changes. PluralizeQ returns the object for chaining
	#   note       only regular English rules: city gives cities, box gives boxes, dog gives dogs,
	#              but child gives childs; a non-English word just receives an s
	#   see        Pluralized, Simplify
	#@ aka  Pluralize the (English) word in place (mutating).
	def Pluralize()
		pResult = StzEngineStringPluralize(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		This.Update(_cResult_)

		# Pluralize the word, chainable.
		def PluralizeQ()
			This.Pluralize()
			return This

	# Returns the English plural of the text, leaving the object unchanged.
	#
	#   returns    a text
	#   note       the plural applies to the end of the text: the quick brown fox jumps over the
	#              lazy dog gives a text ending in dogs
	#   see        Pluralize, ToSlug
	#@ aka  The pluralized form, as a copy; the original is unchanged.
	def Pluralized()
		pResult = StzEngineStringPluralize(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Returns the text as a URL slug: lower case, words joined by hyphens, and only ASCII letters and digits kept.
	#
	#   returns    a text
	#   note       Hello, World! gives hello-world
	#   warning    non-ASCII letters are dropped and not transliterated: Ça va très bien gives a-va-
	#              trs-bien, and Hebrew or Arabic text gives an empty text
	#   see        Initials, Simplified
	#@ aka  The string turned into a URL slug (lowercase, hyphens).
	def ToSlug()
		pResult = StzEngineStringToSlug(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

		def Slugified()
			return This.ToSlug()

	# Returns the text cut so that it fits the given length, ending in three dots, and does not change the text.
	#
	#   nMaxLen    the greatest length of the result, in characters
	#   returns    a text, at most nMaxLen characters long, the three dots included
	#   note       the quick brown fox jumps over the lazy dog with 10 gives the qui...; Hebrew is
	#              cut by characters
	#   warning    despite what its older description said, it does not change the object: read the
	#              answer, and call Update with it to keep it
	#   see        ToSlug, WordsTruncated
	#@ aka  Abbreviate the text in place (mutating).
	def Abbreviate(nMaxLen)
		pResult = StzEngineStringAbbreviate(This.Engine(), nMaxLen)
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

		# An abbreviated copy; the original is unchanged.
		def Abbreviated(nMaxLen)
			return This.Abbreviate(nMaxLen)

	# Returns the first letter of every word, joined in one text.
	#
	#   returns    a text
	#   note       the quick brown fox jumps over the lazy dog gives tqbfjotld and keeps the case;
	#              an emoji counts as a word here
	#   see        Words, ToSlug
	#@ aka  The initial letter of each word.
	def Initials()
		pResult = StzEngineStringInitials(This.Engine())
		_cResult_ = StzEngineStringData(pResult)
		StzEngineStringFree(pResult)
		return _cResult_

	# Returns the text with its accents and other combining marks taken off, leaving the object unchanged.
	#
	#   returns    a text
	#   note       Café déjà vu, Ça gives Cafe deja vu, Ca
	#   see        RemoveDiacritics, Chars
	#@ aka  Delegate-thin wrappers so stzText/stzStringText consumers can reach common stzString helpers without juggling .ToStzString().
	def DiacriticsRemoved()
		return @oString.DiacriticsRemoved()

	# Takes the accents and other combining marks off the text, in place.
	#
	#   returns    nothing; the text changes
	#   note       Café déjà vu, Ça becomes Cafe deja vu, Ca
	#   see        DiacriticsRemoved, Chars
	#@ aka  Remove the diacritics (accents) in place (mutating).
	def RemoveDiacritics()
		@oString.RemoveDiacritics()

	# Changes the whole text to lower case, in place.
	#
	#   returns    nothing; the text changes
	#   see        Uppercase, Simplify
	#@ aka  Lowercase the text in place (mutating).
	def Lowercase()
		return @oString.Lowercase()

	# Changes the whole text to capitals, in place.
	#
	#   returns    nothing; the text changes
	#   note       Hello world becomes HELLO WORLD; scripts without capitals are left as they are
	#   see        Lowercase, SentenceCased
	#@ aka  Uppercase the text in place (mutating).
	def Uppercase()
		return @oString.Uppercase()

	# Returns the characters of the text, in order, as a list.
	#
	#   returns    a list of text, one character per item
	#   note       an emoji or a Hebrew letter is one item
	#   see        NumberOfChars, Words
	#@ aka  The chars of the text, as a list.
	def Chars()
		return @oString.Chars()

	# Returns how many characters the text holds, counting an emoji or a Hebrew letter as one.
	#
	#   returns    a number
	#   note       same answer as NumberOfChars
	#   see        NumberOfChars, Chars
	#@ aka  Engine twin of NumberOfChars (codepoint count).
	def NumberOfChars2()
		return @oString.NumberOfChars()

# NOTE: class stzText moved to base/natural/stzText.ring -- it is now the
# text-meaning DOMAIN class (still 'from stzStringText', so a superset).

