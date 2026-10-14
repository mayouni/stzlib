#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGLINES             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String lines -- Wraps stzString via         #
#                  composition. Line-based operations:         #
#                  splitting, counting, unique, empty removal. #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Works on a text line by line: counts, picks, sorts, reverses, deduplicates, indents and filters its lines.
#
# It is the line helper of stzString; build one with StzStringLinesQ (or new stzStringLines) over a
# multi-line text. Lines end at a line feed, and a final line feed makes one more, empty, last line.
# Each verb without an ending (SortLines, ReverseLinesOrder, IndentLines, RemoveDuplicateLines,
# RemoveEmptyLines) changes the held text in place and returns nothing (the Q form returns the
# helper so calls chain), and the matching form (EmptyLinesRemoved, LinesSorted, LinesOrderReversed,
# LinesIndented, DuplicateLinesRemoved) returns the new text and leaves the helper alone. Read the
# result with Content. Lengths count characters, so Hebrew, Arabic and emoji lines are measured as
# you read them. Pass a plain text, not a stzString object: editing through the helper empties the
# stzString that was passed in. NumberOfEmptyLines does not count blank lines today (it subtracts a
# text length from a line count): count the empty texts in Lines instead. A carriage return before a
# line feed stays at the end of its line.
#
#   receiver   o1 = StzStringLinesQ("pear" + char(10) + "fig" + char(10) + "apple")
#   example    ? o1.NumberOfLines()
#              #--> 3
#              ? o1.LongestLine()
#              #--> apple
#              ? @@( o1.NLastLines(2) )
#              #--> [ "fig", "apple" ]
#              o2 = StzStringLinesQ("שלום" + char(10) + "עולם יפה")
#              ? o2.LongestLine()
#              #--> עולם יפה
#   see        stzString, stzList, stzStringFinder
class stzStringLines from stzObject

	@oString

	# Builds a lines helper over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the multi-line text, or a stzString whose content is edited
	#   returns           nothing; the object is built
	#   note              pass a plain text and read the result with Content; lines end at a line
	#                     feed
	#   warning           with a stzString argument, the first in-place edit (ReverseLinesOrder,
	#                     SortLines, IndentLines...) leaves the stzString you passed reading as an
	#                     empty text, while the helper keeps the right one
	#   see               Content, Lines
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringLines! Parameter must be a string or stzString object.")
		ok

	# Returns the text as it stands now, after the in-place edits made so far.
	#
	#   returns    a text
	#   see        NumberOfChars, Lines
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting line feeds and counting a Hebrew letter or an emoji as one.
	#
	#   returns    a number
	#   see        Content, NumberOfLines
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text holds no character at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfChars, Content
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     LINES                     #
	#===============================#

	def LinesCS(pCaseSensitive)
		return @SplitCS(@oString.Content(), char(10), pCaseSensitive)

		def LinesCSQ(pCaseSensitive)
			return new stzList(This.LinesCS(pCaseSensitive))

	# Returns the lines of the text as a list of texts, cut at each line feed.
	#
	#   returns    a list of text; empty lines are kept as empty texts
	#   note       LinesQ returns a stzList for chaining
	#   warning    a carriage return before a line feed stays at the end of its line (a CRLF text
	#              keeps the CR); an empty text answers a list of one empty text although
	#              NumberOfLines answers 0; a final line feed makes a last empty line
	#   see        NumberOfLines, NthLine, UniqueLines
	def Lines()
		return This.LinesCS(1)

		def LinesQ()
			return new stzList(This.Lines())

	  #===============================#
	 #     NUMBER OF LINES           #
	#===============================#

	def NumberOfLinesCS(pCaseSensitive)
		return StzEngineStringCountLines(@oString.Engine())

		def CountLinesCS(pCaseSensitive)
			return This.NumberOfLinesCS(pCaseSensitive)

		def HowManyLinesCS(pCaseSensitive)
			return This.NumberOfLinesCS(pCaseSensitive)

	# Returns how many lines the text has, a final line feed counting one more empty line.
	#
	#   returns    a number; 0 for an empty text
	#   note       a\nb\n gives 3; CountLines and HowManyLines are the same call
	#   see        Lines, NthLine, NumberOfEmptyLines
	def NumberOfLines()
		return StzEngineStringCountLines(@oString.Engine())

		def CountLines()
			return This.NumberOfLines()

		def HowManyLines()
			return This.NumberOfLines()

	  #===============================#
	 #     NTH LINE                  #
	#===============================#

	# Returns the line at a position, counted from 1.
	#
	#   n          the 1-based position of the line
	#   returns    a text
	#   note       Line is the same call
	#   warning    a position of 0, a negative one, or past the last line raises error Index out of
	#              range!
	#   see        FirstLine, LastLine, Lines
	#@ aka  The nth line of the string.
	def NthLine(n)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringLineAt(_pH_, n)
		if _pR_ != ""
			_c_ = StzEngineStringData(_pR_)
			StzEngineStringFree(_pR_)
			return _c_
		ok
		StzRaise("Index out of range!")

		def Line(n)
			return This.NthLine(n)

	# Returns the first line of the text.
	#
	#   returns    a text
	#   note       an empty text gives an empty text
	#   see        LastLine, NthLine
	def FirstLine()
		return This.NthLine(1)

	# Returns the last line of the text.
	#
	#   returns    a text; an empty text when the text ends with a line feed
	#   note       a\nb\n gives an empty text, since that is the last line
	#   warning    an empty text raises error Index out of range!
	#   see        FirstLine, NthLine
	#@ aka  The last line of the string.
	def LastLine()
		return This.NthLine(This.NumberOfLines())

	  #===============================#
	 #     UNIQUE LINES              #
	#===============================#

	# The unique lines of the string.
	def UniqueLinesCS(pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)

		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringUniqueLinesCS(_pH_, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		if _c_ = ""
			return []
		ok
		return @SplitCS(_c_, char(10), 1)

		def LinesCSU(pCaseSensitive)
			return This.UniqueLinesCS(pCaseSensitive)

	# Returns the lines with each repeated line kept once, at its first place, in order.
	#
	#   returns    a list of text
	#   note       b A c B a keeps all five, and UniqueLinesCS(0) keeps b A c; empty lines count as
	#              a line like another
	#   see        RemoveDuplicateLines, Lines
	def UniqueLines()
		return This.UniqueLinesCS(1)

		def LinesU()
			return This.UniqueLines()

	  #===============================#
	 #     EMPTY LINES               #
	#===============================#

	# Deletes every blank line from the text, in place, a line holding only spaces counting as blank.
	#
	#   returns    nothing; the text changes. RemoveEmptyLinesQ returns the helper for chaining
	#   note       the remaining lines keep their order
	#   see        EmptyLinesRemoved, HasEmptyLines
	def RemoveEmptyLines()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveBlankLines(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveEmptyLinesQ()
			This.RemoveEmptyLines()
			return This

	# Returns the text with every blank line deleted, a line of spaces counting as blank, leaving the helper unchanged.
	#
	#   returns    a text
	#   note       the result is a text, not a list of lines
	#   see        RemoveEmptyLines, NumberOfEmptyLines
	def EmptyLinesRemoved()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveBlankLines(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Returns the line count minus the length in characters of the text left after blank lines are dropped, which is not a count of blank lines.
	#
	#   returns    a number, often negative
	#   note       count the empty texts in Lines instead
	#   warning    it subtracts the length of a text from a number of lines: a and b on two lines
	#              give -1, a and b with two empty lines and a final line feed give 2 for 3 empty
	#              lines, and xx then a final line feed gives 0 for 1
	#   see        HasEmptyLines, EmptyLinesRemoved
	def NumberOfEmptyLines()
		return This.NumberOfLines() - len(This.EmptyLinesRemoved())

	# TRUE if at least one line is empty or holds only spaces.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a final line feed makes a last empty line, so a\nb\n answers TRUE
	#   see        NumberOfEmptyLines, RemoveEmptyLines
	def HasEmptyLines()
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		for i = 1 to _nLen_
			if trim(_acLines_[i]) = ""
				return 1
			ok
		next
		return 0

	  #===============================#
	 #     N FIRST / N LAST LINES    #
	#===============================#

	# Returns the first n lines as a list of texts.
	#
	#   n          how many lines to take from the start
	#   returns    a list of text; fewer than n when the text has fewer lines; [ ] for 0 or a
	#              negative n
	#   note       empty lines count as lines
	#   see        NLastLines, FirstLine
	def NFirstLines(n)
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		_acResult_ = []

		_nLimit_ = n
		if _nLimit_ > _nLen_
			_nLimit_ = _nLen_
		ok

		for i = 1 to _nLimit_
			_acResult_ + _acLines_[i]
		next

		return _acResult_

	# Returns the last n lines as a list of texts.
	#
	#   n          how many lines to take from the end
	#   returns    a list of text, in text order; fewer than n when the text has fewer lines; [ ]
	#              for 0 or a negative n
	#   note       empty lines count as lines
	#   see        NFirstLines, LastLine
	def NLastLines(n)
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		_acResult_ = []

		_nStart_ = _nLen_ - n + 1
		if _nStart_ < 1
			_nStart_ = 1
		ok

		for i = _nStart_ to _nLen_
			_acResult_ + _acLines_[i]
		next

		return _acResult_

	  #===============================#
	 #     LONGEST / SHORTEST LINE   #
	#===============================#

	# Returns the line with the most characters, the first one when several tie.
	#
	#   returns    a text; an empty text for an empty text
	#   note       length counts characters, so a Hebrew or Arabic line is measured in letters
	#   see        ShortestLine, AverageLineLength
	def LongestLine()
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		if _nLen_ = 0
			return ""
		ok

		_cLongest_ = _acLines_[1]
		_nMax_ = StzLen(_cLongest_)

		for i = 2 to _nLen_
			_nLineLen_ = StzLen(_acLines_[i])
			if _nLineLen_ > _nMax_
				_nMax_ = _nLineLen_
				_cLongest_ = _acLines_[i]
			ok
		next

		return _cLongest_

	# Returns the line with the fewest characters among the lines that are not blank, the first one when several tie.
	#
	#   returns    a text; an empty text when every line is blank
	#   note       blank lines (empty or only spaces) never win; length counts characters
	#   see        LongestLine
	def ShortestLine()
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		if _nLen_ = 0
			return ""
		ok

		_cShortest_ = ""
		_nMin_ = 0
		_bFirst_ = 1

		for i = 1 to _nLen_
			_cLine_ = _acLines_[i]
			if trim(_cLine_) != ""
				_nLineLen_ = StzLen(_cLine_)
				if _bFirst_
					_cShortest_ = _cLine_
					_nMin_ = _nLineLen_
					_bFirst_ = 0
				but _nLineLen_ < _nMin_
					_nMin_ = _nLineLen_
					_cShortest_ = _cLine_
				ok
			ok
		next

		return _cShortest_

	  #===============================#
	 #     AVERAGE LINE LENGTH       #
	#===============================#

	# Returns the mean number of characters per line, blank lines included.
	#
	#   returns    a number; 0 for an empty text
	#   note       x then yy gives 1.5; Hebrew and emoji lines are counted in characters
	#   see        LongestLine, NumberOfLines
	def AverageLineLength()
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		if _nLen_ = 0
			return 0
		ok

		_nTotal_ = 0
		for i = 1 to _nLen_
			_nTotal_ += StzLen(_acLines_[i])
		next

		return _nTotal_ / _nLen_

	  #===============================#
	 #     SORT LINES                #
	#===============================#

	def SortLinesCS(pCaseSensitive)
		_pH_ = @oString.Engine()
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pR_ = StzEngineStringSortLinesCS(_pH_, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def SortLinesCSQ(pCaseSensitive)
			This.SortLinesCS(pCaseSensitive)
			return This

	# Sorts the lines of the text in place, in ascending order of code point, an upper-case letter before a lower-case one.
	#
	#   returns    nothing; the text changes. SortLinesQ returns the helper for chaining
	#   note       SortLinesCS(0) ignores case: b A c B a gives A a b B c
	#   see        LinesSorted, ReverseLinesOrder
	def SortLines()
		return This.SortLinesCS(1)

		def SortLinesQ()
			This.SortLines()
			return This

	def LinesSortedCS(pCaseSensitive)
		_pH_ = @oString.Engine()
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pR_ = StzEngineStringSortLinesCS(_pH_, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Returns the text with its lines sorted in ascending order of code point, leaving the helper unchanged.
	#
	#   returns    a text, lines joined by line feeds
	#   note       b A c B a gives A B a b c; LinesSortedCS(0) gives A a b B c
	#   see        SortLines
	def LinesSorted()
		return This.LinesSortedCS(1)

	  #===============================#
	 #     REVERSE LINES ORDER       #
	#===============================#

	# Reverses the order of the lines of the text, in place.
	#
	#   returns    nothing; the text changes. ReverseLinesOrderQ returns the helper for chaining
	#   note       c a b becomes b a c
	#   see        LinesOrderReversed, SortLines
	def ReverseLinesOrder()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReverseLines(_pH_)
		@oString.Update(StzEngineStringData(_pR_))
		StzEngineStringFree(_pR_)

		def ReverseLinesOrderQ()
			This.ReverseLinesOrder()
			return This

	# Returns the text with its lines in reverse order, leaving the helper unchanged.
	#
	#   returns    a text
	#   note       a😀b then 😀 then abcd gives abcd, 😀, a😀b
	#   see        ReverseLinesOrder
	def LinesOrderReversed()
		_oCopy_ = new stzStringLines(@oString.Content())
		_oCopy_.ReverseLinesOrder()
		return _oCopy_.Content()

	  #===============================#
	 #     INDENT LINES              #
	#===============================#

	# Puts the given number of spaces in front of every line, blank lines included, in place.
	#
	#   n          how many spaces to add to each line
	#   returns    nothing; the text changes. IndentLinesQ returns the helper for chaining
	#   note       applies to Hebrew and Arabic lines too
	#   see        LinesIndented, Lines
	def IndentLines(n)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringIndent(_pH_, n)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def IndentLinesQ(n)
			This.IndentLines(n)
			return This

	# Returns the text with the given number of spaces in front of every line, leaving the helper unchanged.
	#
	#   n          how many spaces to add to each line
	#   returns    a text
	#   note       a then b with 2 gives two spaces before each; a single line is indented too
	#   see        IndentLines
	def LinesIndented(n)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringIndent(_pH_, n)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     REMOVE DUPLICATE LINES    #
	#===============================#

	def RemoveDuplicateLinesCS(pCaseSensitive)
		_pH_ = @oString.Engine()
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pR_ = StzEngineStringDeduplicateLinesCS(_pH_, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveDuplicateLinesCSQ(pCaseSensitive)
			This.RemoveDuplicateLinesCS(pCaseSensitive)
			return This

	# Deletes every repeated line, keeping the first of each, in place.
	#
	#   returns    nothing; the text changes. RemoveDuplicateLinesQ returns the helper for chaining
	#   note       b a b then an empty line then c gives b a an empty line c;
	#              RemoveDuplicateLinesCS(0) ignores case
	#   see        DuplicateLinesRemoved, UniqueLines
	def RemoveDuplicateLines()
		return This.RemoveDuplicateLinesCS(1)

		def RemoveDuplicateLinesQ()
			This.RemoveDuplicateLines()
			return This

	def DuplicateLinesRemovedCS(pCaseSensitive)
		_pH_ = @oString.Engine()
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pR_ = StzEngineStringDeduplicateLinesCS(_pH_, _bCase_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Returns the text with every repeated line deleted, keeping the first of each, leaving the helper unchanged.
	#
	#   returns    a text
	#   note       b A c B a gives all five, and DuplicateLinesRemovedCS(0) gives b A c
	#   see        RemoveDuplicateLines, UniqueLines
	def DuplicateLinesRemoved()
		return This.DuplicateLinesRemovedCS(1)

	  #===============================#
	 #     LINES CONTAINING          #
	#===============================#

	def LineContainingCS(pcSubStr, pCaseSensitive)
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			if StringContainsCS(_acLines_[i], pcSubStr, pCaseSensitive)
				return _acLines_[i]
			ok
		next

		return ""

	# The lines containing the given substring.
	def LinesContainingCS(pcSubStr, pCaseSensitive)
		_acLines_ = This.Lines()
		_nLen_ = len(_acLines_)
		_acResult_ = []

		for i = 1 to _nLen_
			if StringContainsCS(_acLines_[i], pcSubStr, pCaseSensitive)
				_acResult_ + _acLines_[i]
			ok
		next

		return _acResult_

	# Returns the first line that holds the given fragment.
	#
	#   pcSubStr   the fragment to look for
	#   returns    a text; an empty text when no line holds it
	#   note       case counts: apple does not find Apple; LineContainingCS(sub, 0) ignores case
	#   see        LinesContaining, Lines
	def LineContaining(pcSubStr)
		return This.LineContainingCS(pcSubStr, @CaseSensitive(1))

	# Returns every line that holds the given fragment.
	#
	#   pcSubStr   the fragment to look for
	#   returns    a list of text; [ ] when none
	#   note       case counts: apple does not find Apple, while LinesContainingCS(sub, 0) does
	#   see        LineContaining, Lines
	def LinesContaining(pcSubStr)
		return This.LinesContainingCS(pcSubStr, @CaseSensitive(1))
