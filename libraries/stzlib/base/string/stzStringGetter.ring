#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGGETTER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String getter -- accessing individual       #
#                  chars and char groups.                      #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringGetterXT.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Reads a text without changing it: a character by position, the first, last or middle, the n first or last, the characters, n-grams.
#
# Build one with new stzStringGetter("text"); it only reads, so a stzString passed in is never
# emptied. Positions count from 1 and in characters, so Hebrew, Arabic and emoji are read by letter.
# NFirstChars and NLastChars refuse a count outside the text, while NthChar forgives position 0 and
# a position past the end. CharNgrams and WordNgrams answer the runs of n characters or n words.
# BytesPerChar answers a text such as "1 4 2". NLeftChars and NRightChars should swap sides for
# right-to-left text and do not today, because the direction test answers TRUE for it.
#
#   receiver   o1 = new stzStringGetter("hello World")
#   example    ? o1.NthChar(2)
#              #--> e
#              ? o1.NLastChars(3)
#              #--> rld
#              ? @@( o1.CharNgrams(3) )
#              #--> [ "hel", "ell", "llo", "lo ", "o W", " Wo", "Wor", "orl", "rld" ]
#              o2 = new stzStringGetter("a😀ب")
#              ? o2.BytesPerChar()
#              #--> 1 4 2
#   see        stzString, stzStringSections, stzStringWords
class stzStringGetter from stzObject

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a getter over a text or over a stzString object, to read characters and pieces of it without changing it.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, to read from
	#   returns           nothing; the object is built
	#   warning           any other kind of value raises "Can't create stzStringGetter! Parameter
	#                     must be a string or stzString object."; the getter only reads, so a
	#                     stzString passed in is never emptied
	#   see               NthChar, Chars
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringGetter! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the text the getter holds.
	#
	#   returns    a text
	#   see        NumberOfChars
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting letters and not bytes.
	#
	#   returns    a number
	#   see        BytesPerChar
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text is empty.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   ACCESSING NTH CHAR                                 #
	#======================================================#

	# Returns the character at a position, counted from 1, as a one-character text.
	#
	#   _n_        the position, from 1
	#   returns    a one-character text
	#   note       "e" is the 2nd of "hello World"
	#   warning    position 0 answers the first character and a position past the end answers an
	#              empty text, with no error; CharAt and CharAtPosition are the same method
	#   see        FirstChar, LastChar
	def NthChar(_n_)
		return @oString.NthChar(_n_)

		def CharAt(_n_)
			return This.NthChar(_n_)

		def CharAtPosition(_n_)
			return This.NthChar(_n_)

	  #======================================================#
	 #   FIRST / LAST / MIDDLE CHAR                         #
	#======================================================#

	# Returns the first character of the text.
	#
	#   returns    a one-character text; "" for an empty text
	#   see        LastChar, NthChar
	def FirstChar()
		return This.NthChar(1)

	# Returns the last character of the text.
	#
	#   returns    a one-character text; "" for an empty text
	#   note       "ם" is one character
	#   see        FirstChar
	def LastChar()
		return This.NthChar(@oString.NumberOfChars())

	# Returns the character in the middle of the text, the left one when the length is even.
	#
	#   returns    a one-character text; "" for an empty text
	#   note       "hello World" gives a space, "ab" gives a, "a😀ب" gives 😀
	#   see        NthChar
	def MiddleChar()
		_n_ = ceil(@oString.NumberOfChars() / 2)
		return This.NthChar(_n_)

	  #======================================================#
	 #   N FIRST / N LAST CHARS                             #
	#======================================================#

	# Returns the first n characters of the text as a text.
	#
	#   _n_        how many characters to take, from 1 to the length
	#   returns    a text
	#   note       the Hebrew "שלום עולם" gives "שלו" for 3
	#   warning    n of 0, below 0 or above the length raises "Indexes out of range!", and so does
	#              an empty text; NFirstCharsQ answers a stzString
	#   see        NLastChars, NLeftChars
	def NFirstChars(_n_)
		return @oString.Section(1, _n_)

		def NFirstCharsQ(_n_)
			return StzStringQ(This.NFirstChars(_n_))

	# Returns the last n characters of the text as a text.
	#
	#   _n_        how many characters to take, from 1 to the length
	#   returns    a text
	#   warning    n of 0, below 0 or above the length raises "Indexes out of range!"; NLastCharsQ
	#              answers a stzString
	#   see        NFirstChars, NRightChars
	def NLastChars(_n_)
		_nLen_ = @oString.NumberOfChars()
		return @oString.Section(_nLen_ - _n_ + 1, _nLen_)

		def NLastCharsQ(_n_)
			return StzStringQ(This.NLastChars(_n_))

	  #======================================================#
	 #   N LEFT / N RIGHT CHARS                             #
	#======================================================#

	# Returns the n characters at the left end of the text: the first ones for a left-to-right text, the last ones for a right-to-left text.
	#
	#   _n_        how many characters to take, from 1 to the length
	#   returns    a text
	#   note       NLeftCharsAsString is the same method
	#   warning    Never takes the right-to-left branch today: the direction test answers TRUE for
	#              Hebrew and Arabic, so NLeftChars(3) of "مرحبا بالعالم" gives its first three
	#              letters, the same as NFirstChars
	#   see        NRightChars, NFirstChars
	def NLeftChars(_n_)
		if @oString.IsLeftToRight()
			return This.NFirstChars(_n_)
		else
			return This.NLastChars(_n_)
		ok

		def NLeftCharsQ(_n_)
			return StzStringQ(This.NLeftChars(_n_))

		def NLeftCharsAsString(_n_)
			return This.NLeftChars(_n_)

		def NLeftCharsAsStringQ(_n_)
			return StzStringQ(This.NLeftChars(_n_))

	# Returns the n characters at the right end of the text: the last ones for a left-to-right text, the first ones for a right-to-left text.
	#
	#   _n_        how many characters to take, from 1 to the length
	#   returns    a text
	#   note       NRightCharsAsString is the same method
	#   warning    Same as NLeftChars: Hebrew and Arabic are treated as left-to-right, so it gives
	#              their last letters
	#   see        NLeftChars, NLastChars
	def NRightChars(_n_)
		if @oString.IsLeftToRight()
			return This.NLastChars(_n_)
		else
			return This.NFirstChars(_n_)
		ok

		def NRightCharsQ(_n_)
			return StzStringQ(This.NRightChars(_n_))

		def NRightCharsAsString(_n_)
			return This.NRightChars(_n_)

		def NRightCharsAsStringQ(_n_)
			return StzStringQ(This.NRightChars(_n_))

	  #======================================================#
	 #   ALL CHARS AS LIST                                  #
	#======================================================#

	# Returns the characters of the text as a list of one-character texts.
	#
	#   returns    a list of texts
	#   note       "a😀ب" gives three items, the emoji and the Arabic letter each one
	#   see        UniqueChars, BytesPerChar
	def Chars()
		return @oString.Chars()

	  #======================================================#
	 #   UNIQUE CHARS                                       #
	#======================================================#

	def UniqueCharsCS(pCaseSensitive)
		_aChars_ = This.Chars()
		return UCS(_aChars_, pCaseSensitive)

	# Returns the different characters of the text, each once, in the order of their first appearance, comparing case-sensitively.
	#
	#   returns    a list of texts
	#   note       UniqueCharsCS(0) folds case: "aAbB" gives a and b
	#   see        Chars
	def UniqueChars()
		return This.UniqueCharsCS(1)

	  #======================================================#
	 #   SECTION / RANGE ACCESS                             #
	#======================================================#

	# Returns the characters from one position to another, both included, as a text.
	#
	#   n1         the first position, from 1
	#   n2         the last position, from 1
	#   returns    a text
	#   note       "ell" for 2 to 4 of "hello World"; it is the stzString method
	#   see        Range, NFirstChars
	def Section(n1, n2)
		return @oString.Section(n1, n2)

	# Returns a run of characters given by its start and its length, as a text.
	#
	#   nStart     the first position, from 1
	#   nRange     how many characters
	#   returns    a text
	#   note       "ello" for 2 and 4 of "hello World"
	#   see        Section
	def Range(nStart, nRange)
		return @oString.Range(nStart, nRange)

	  #======================================================#
	 #   CHAR N-GRAMS                                       #
	#======================================================#

	# Returns every run of n consecutive characters of the text, as a list of texts.
	#
	#   _n_        the size of each run, in characters
	#   returns    a list of texts; [ ] for an empty text or an n above the length
	#   note       "hello" with 2 gives he, el, ll, lo
	#   warning    A text that contains a pipe character is cut wrongly, because the engine answer
	#              is split on that character: "a" + pipe + "b" with n = 1 answers a, two empty
	#              texts, b
	#   see        WordNgrams, Chars
	def CharNgrams(_n_)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringCharNgrams(_pH_, _n_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		if _c_ = ""
			return []
		ok
		# Engine returns pipe-delimited ngrams: "ab|bc|cd"
		return @Split(_c_, "|")

	  #======================================================#
	 #   WORD N-GRAMS                                       #
	#======================================================#

	# Returns every run of n consecutive words of the text, as a list of texts.
	#
	#   _n_        how many words in each run
	#   returns    a list of texts; [ ] when n is above the number of words
	#   note       "the quick brown fox" with 2 gives "the quick", "quick brown", "brown fox"
	#   see        CharNgrams
	def WordNgrams(_n_)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringWordNgrams(_pH_, _n_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		if _c_ = ""
			return []
		ok
		# Engine returns pipe-delimited ngrams: "the quick|quick brown"
		return @Split(_c_, "|")

	  #======================================================#
	 #   BYTES PER CHAR                                     #
	#======================================================#

	# Returns how many bytes each character takes in UTF-8, as one text of numbers separated by spaces.
	#
	#   returns    a text such as "1 4 2", not a list
	#   note       "a😀ب" gives "1 4 2"; "שלום עולם" gives "2 2 2 2 1 2 2 2 2"; an empty text gives
	#              ""
	#   see        Chars, NumberOfChars
	def BytesPerChar()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringBytesPerChar(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_
