#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGSPLITTER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String splitter -- splitting operations     #
#                  at positions, substrings, sections,         #
#                  before/after/around.                        #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringSplitterXT.       #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Cuts a text into pieces at fragments, positions or regex matches, with or without keeping the separators.
#
# It is the splitting helper of stzString, which builds one over itself for its Split family; build
# one with new stzStringSplitter("text") when you only need to split. Split and SplitAt drop the
# separators, SplitBefore and SplitAfter keep them on the piece next to them, so joining the pieces
# gives the text back. A position names a character, not a byte, so Hebrew, Arabic and emoji text is
# cut where you expect, and a position split drops the character at that position. The CS forms take
# 0 to ignore case. Found today: Partition, PartitionAfter, RPartition and RPartitionAfter return a
# single piece because a NUL-separated engine buffer is cut at its first NUL; SplitAtSubStrings also
# cuts at a literal <<<SEP>>> in the text; and a splitter built from a stzString object reads an
# empty text once that string is appended to.
#
#   receiver   o1 = new stzStringSplitter("a,b,,c")
#   example    ? @@( o1.Split(",") )
#              #--> [ "a", "b", "", "c" ]
#              ? @@( o1.SplitAfter(",") )
#              #--> [ "a,", "b,", ",", "c" ]
#              o2 = new stzStringSplitter("שלום עולם, שלום")
#              ? @@( o2.Split(" ") )
#              #--> [ "שלום", "עולם,", "שלום" ]
#              o3 = new stzStringSplitter("a😀b😀c")
#              ? @@( o3.SplitAtPosition(2) )
#              #--> [ "a", "b😀c" ]
#   see        stzString, stzStringFinder, stzStringCounter
class stzStringSplitter from stzObject

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a splitter over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to split, or a stzString whose engine handle is shared
	#   returns           nothing; the object is built
	#   note              stzString builds one over itself for its Split family; build one yourself
	#                     with new stzStringSplitter("text")
	#   warning           a splitter built from a stzString object keeps the engine handle of that
	#                     object: after the original is appended to the splitter reads an empty
	#                     text, so build it after the edits
	#   see               Content, Split
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringSplitter! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the text being split.
	#
	#   returns    a text
	#   see        NumberOfChars, IsEmpty
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, a Hebrew letter or an emoji counting as one.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text holds no character at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #====================================#
	 #     SPLIT -- MAIN ENTRY POINT      #
	#====================================#

	def SplitCS(pSubStrOrPos, pCaseSensitive)

		if isList(pSubStrOrPos) and len(pSubStrOrPos) = 2 and isString(pSubStrOrPos[1])
			_cParamName_ = StzCaseFold(pSubStrOrPos[1])

			if _cParamName_ = "with" or _cParamName_ = "by" or _cParamName_ = "using"
				return This.SplitAtCS(pSubStrOrPos[2], pCaseSensitive)

			but _cParamName_ = "at"
				return This.SplitAtCS(pSubStrOrPos[2], pCaseSensitive)

			but _cParamName_ = "atposition"
				return This.SplitAtPosition(pSubStrOrPos[2])

			but _cParamName_ = "atpositions"
				return This.SplitAtPositions(pSubStrOrPos[2])

			but _cParamName_ = "before"
				return This.SplitBeforeCS(pSubStrOrPos[2], pCaseSensitive)

			but _cParamName_ = "after"
				return This.SplitAfterCS(pSubStrOrPos[2], pCaseSensitive)

			but _cParamName_ = "around"
				return This.SplitAroundCS(pSubStrOrPos[2], pCaseSensitive)

			ok
		ok

		return This.SplitAtCS(pSubStrOrPos, pCaseSensitive)

	def SplittedCS(pSubStrOrPos, pCaseSensitive)
		return This.SplitCS(pSubStrOrPos, pCaseSensitive)

	# Cuts the text at a fragment, at a position, at several of either, or as a named form such as [ :before, "," ].
	#
	#   pSubStrOrPos   a text, a position, a list of positions, a list of texts, or a pair [ :with
	#                  or :by or :using or :at or :atposition or :atpositions or :before or :after,
	#                  value ]
	#   returns        a list of texts; the separators are dropped, and an empty text gives [ ]
	#   note           Splitted is the same call; "a,b,,c" at "," gives a, b, an empty text and c;
	#                  the flag form SplitCS with 0 ignores case; the position form drops the
	#                  character at that position
	#   warning        the pair form :around raises R14 because SplitAroundCS does not exist in this
	#                  class
	#   see            SplitAt, SplitBefore, SplitAfter
	def Split(pSubStrOrPos)
		return This.SplitCS(pSubStrOrPos, 1)

	def Splitted(pSubStrOrPos)
		return This.Split(pSubStrOrPos)

	  #================================#
	 #     SPLIT AT -- DISPATCHER     #
	#================================#

	def SplitAtCS(pSubStrOrPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pSubStrOrPos)
			return This.SplitAtSubStringCS(pSubStrOrPos, pCaseSensitive)

		but isNumber(pSubStrOrPos)
			return This.SplitAtPosition(pSubStrOrPos)

		but isList(pSubStrOrPos) and IsListOfNumbers(pSubStrOrPos)
			return This.SplitAtPositions(pSubStrOrPos)

		but isList(pSubStrOrPos) and IsListOfStrings(pSubStrOrPos)
			return This.SplitAtSubStringsCS(pSubStrOrPos, pCaseSensitive)

		else
			StzRaise("Incorrect param type! pSubStrOrPos must be position(s) or string(s).")
		ok

	# Cuts the text at a fragment, at a position, at a list of positions or at a list of fragments, dropping the separators.
	#
	#   pSubStrOrPos   a text, a number, a list of numbers or a list of texts
	#   returns        a list of texts; an empty text gives [ ]
	#   note           a,b,,c at the list [ ",", "b" ] gives a, then three empty texts, then c
	#   warning        an empty list raises Incorrect param type
	#   see            Split, SplitAtSubString, SplitAtPosition
	def SplitAt(pSubStrOrPos)
		return This.SplitAtCS(pSubStrOrPos, 1)

	  #=================================#
	 #     SPLIT AT SUBSTRING          #
	#=================================#

	def SplitAtSubStringCS(pcSubStr, pCaseSensitive)
		if CheckingParams()

			if This.IsEmpty()
				return []
			ok

			if isList(pcSubStr) and IsListOfStrings(pcSubStr)
				return This.SplitAtSubStringsCS(pcSubStr, pCaseSensitive)
			ok

			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok

		ok

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		return @oString._SplitByStrCS(pcSubStr, pCaseSensitive)

	# Cuts the text at every occurrence of a fragment and drops the fragment.
	#
	#   pcSubStr   the fragment to cut at
	#   returns    a list of texts, with an empty text between two neighbouring separators; the
	#              whole text in a list when the fragment is absent
	#   note       one--two--three at -- gives one, two, three; SplitAtSubStringCS with 0 ignores
	#              case, so One AND two and Three at and gives three pieces
	#   see        SplitAtSubStrings, SplitBeforeSubString, SplitAfterSubString
	def SplitAtSubString(pcSubStr)
		return This.SplitAtSubStringCS(pcSubStr, 1)

	  #===================================#
	 #     SPLIT AT MULTIPLE SUBSTRINGS  #
	#===================================#

	def SplitAtSubStringsCS(pacSubStrings, pCaseSensitive)
		if NOT isList(pacSubStrings)
			StzRaise("Incorrect param type! pacSubStrings must be a list.")
		ok

		_cResult_ = This.Content()
		_cSep_ = "<<<SEP>>>"

		_nLen_ = len(pacSubStrings)
		for i = 1 to _nLen_
			_cResult_ = @ReplaceCS(_cResult_, pacSubStrings[i], _cSep_, pCaseSensitive)
		next

		return @SplitCS(_cResult_, _cSep_, 1)

	# Cuts the text at every occurrence of any fragment of a list and drops them.
	#
	#   pacSubStrings   the list of fragments to cut at
	#   returns         a list of texts
	#   note            a,b;c at , and ; gives a, b, c
	#   warning         a text that already contains the marker <<<SEP>>> is cut there too, because
	#                   the method replaces each fragment by that marker and splits on it
	#   see             SplitAtSubString, SplitAtPositions
	def SplitAtSubStrings(pacSubStrings)
		return This.SplitAtSubStringsCS(pacSubStrings, 1)

	  #===============================#
	 #     SPLIT AT POSITION         #
	#===============================#

	# Cuts the text in two around the character at a position, dropping that character.
	#
	#   n          the 1-based position of the character that is dropped
	#   returns    a list of one or two texts; the whole text in a list when the position is 0 or
	#              past the end
	#   note       a,b,,c at 3 gives a, and ,,c; position 1 gives only the rest; Hebrew and emoji
	#              text is cut by characters
	#   see        SplitAtPositions, SplitBeforePosition, SplitAfterPosition
	#@ aka  Split the string at the given position.
	def SplitAtPosition(n)

		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if NOT ( n >= 1 and n <= This.NumberOfChars() )
			return [ This.Content() ]
		ok

		# Split at position n: [1..n-1] and [n+1..end]
		# (position n itself is excluded -- it's the split point)
		_nSapLen_ = This.NumberOfChars()
		_aSapResult_ = []

		if n > 1
			_aSapResult_ + @oString.Section(1, n - 1)
		ok
		if n < _nSapLen_
			_aSapResult_ + @oString.Section(n + 1, _nSapLen_)
		ok

		return _aSapResult_

	  #=================================#
	 #     SPLIT AT POSITIONS          #
	#=================================#

	# Cuts the text around several characters, dropping each of them.
	#
	#   _anPos_    the list of 1-based positions, in any order
	#   returns    a list of texts
	#   note       a,b,,c at 2 and 4 gives a, b and ,c
	#   warning    an empty list raises Incorrect param type
	#   see        SplitAtPosition, SplitBeforePositions
	#@ aka  Split the string at the given positions.
	def SplitAtPositions(_anPos_)

		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(_anPos_) and IsListOfNumbers(_anPos_) )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		# Split at multiple positions (each position is excluded)
		_anSapsorted_ = sort(_anPos_)
		_nSapLen_ = This.NumberOfChars()
		_aSapResult_ = []
		_nSapPrev_ = 1

		_n_anSapsortedLen_ = len(_anSapsorted_)
		for _iSap_ = 1 to _n_anSapsortedLen_
			_nSapPos_ = _anSapsorted_[_iSap_]
			if _nSapPos_ >= _nSapPrev_ and _nSapPos_ <= _nSapLen_
				if _nSapPos_ > _nSapPrev_
					_aSapResult_ + @oString.Section(_nSapPrev_, _nSapPos_ - 1)
				ok
				_nSapPrev_ = _nSapPos_ + 1
			ok
		next

		if _nSapPrev_ <= _nSapLen_
			_aSapResult_ + @oString.Section(_nSapPrev_, _nSapLen_)
		ok

		return _aSapResult_

	  #===============================#
	 #     SPLIT BEFORE              #
	#===============================#

	def SplitBeforeCS(pSubStrOrPos, pCaseSensitive)

		if isNumber(pSubStrOrPos)
			return This.SplitBeforePosition(pSubStrOrPos)
		ok

		if isString(pSubStrOrPos)
			return This.SplitBeforeSubStringCS(pSubStrOrPos, pCaseSensitive)
		ok

		StzRaise("Incorrect param type!")

	# Cuts the text in front of every occurrence of a fragment, or in front of a position, keeping the separators.
	#
	#   pSubStrOrPos   a text, or a position
	#   returns        a list of texts that joins back to the original
	#   note           a,b,,c before "," gives a, then ,b then , then ,c
	#   warning        any other type raises Incorrect param type!
	#   see            SplitAfter, SplitAt
	def SplitBefore(pSubStrOrPos)
		return This.SplitBeforeCS(pSubStrOrPos, 1)

	# Cuts the text in two just in front of the character at a position.
	#
	#   n          the 1-based position of the first character of the second part
	#   returns    a list of two texts; the whole text in a list when the position is 1 or below, or
	#              past the end
	#   note       a,b,,c before 3 gives a, and b,,c
	#   warning    a text raises R41 Invalid numeric string
	#   see        SplitAfterPosition, SplitBeforePositions
	def SplitBeforePosition(n)
		if This.IsEmpty()
			return []
		ok

		if n <= 1 or n > This.NumberOfChars()
			return [ This.Content() ]
		ok

		_cPart1_ = @oString.Section(1, n - 1)
		_cPart2_ = @oString.Section(n, @oString.NumberOfChars())

		return [ _cPart1_, _cPart2_ ]

	def SplitBeforeSubStringCS(pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(pcSubStr, pCaseSensitive)
		if len(_anPos_) = 0
			return [ This.Content() ]
		ok
		return This.SplitBeforePositions(_anPos_)

	# Cuts the text in front of every occurrence of a fragment, keeping the fragments.
	#
	#   pcSubStr   the fragment to cut in front of
	#   returns    a list of texts; the whole text in a list when the fragment is absent
	#   note       a,b,,c before "," gives a, ,b, , and ,c; an emoji separator works
	#   see        SplitAfterSubString, SplitBefore
	def SplitBeforeSubString(pcSubStr)
		return This.SplitBeforeSubStringCS(pcSubStr, 1)

	# Cuts the text in front of each of several characters.
	#
	#   _anPos_    the list of 1-based positions, in any order
	#   returns    a list of texts that joins back to the original
	#   note       a,b,,c before 2 and 4 gives a, ,b and ,,c
	#   see        SplitBeforePosition, SplitAfterPositions
	def SplitBeforePositions(_anPos_)
		if This.IsEmpty()
			return []
		ok

		# Split before each position: segments end at pos-1, next starts at pos
		_anSbpSorted_ = sort(_anPos_)
		_nSbpLen_ = This.NumberOfChars()
		_aSbpResult_ = []
		_nSbpPrev_ = 1

		_n_anSbpSortedLen_ = len(_anSbpSorted_)
		for _iSbp_ = 1 to _n_anSbpSortedLen_
			_nSbpPos_ = _anSbpSorted_[_iSbp_]
			if _nSbpPos_ > _nSbpPrev_ and _nSbpPos_ <= _nSbpLen_
				_aSbpResult_ + @oString.Section(_nSbpPrev_, _nSbpPos_ - 1)
				_nSbpPrev_ = _nSbpPos_
			ok
		next

		if _nSbpPrev_ <= _nSbpLen_
			_aSbpResult_ + @oString.Section(_nSbpPrev_, _nSbpLen_)
		ok

		return _aSbpResult_

	  #==============================#
	 #     SPLIT AFTER              #
	#==============================#

	# Split the string after each occurrence of the separator (the
	# separator stays with its part).
	def SplitAfterCS(pSubStrOrPos, pCaseSensitive)

		if isNumber(pSubStrOrPos)
			return This.SplitAfterPosition(pSubStrOrPos)
		ok

		if isString(pSubStrOrPos)
			return This.SplitAfterSubStringCS(pSubStrOrPos, pCaseSensitive)
		ok

		StzRaise("Incorrect param type!")

	# Cuts the text behind every occurrence of a fragment, or behind a position, keeping the separators.
	#
	#   pSubStrOrPos   a text, or a position
	#   returns        a list of texts that joins back to the original
	#   note           a,b,,c after "," gives a, then b, then , then c
	#   warning        any other type raises Incorrect param type!
	#   see            SplitBefore, SplitAt
	def SplitAfter(pSubStrOrPos)
		return This.SplitAfterCS(pSubStrOrPos, 1)

	# Cuts the text in two just behind the character at a position.
	#
	#   n          the 1-based position of the last character of the first part
	#   returns    a list of two texts; the whole text in a list when the position is 0 or below, or
	#              at or past the last character
	#   note       a,b,,c after 3 gives a,b and ,,c
	#   see        SplitBeforePosition, SplitAfterPositions
	def SplitAfterPosition(n)
		if This.IsEmpty()
			return []
		ok

		if n < 1 or n >= This.NumberOfChars()
			return [ This.Content() ]
		ok

		_cPart1_ = @oString.Section(1, n)
		_cPart2_ = @oString.Section(n + 1, @oString.NumberOfChars())

		return [ _cPart1_, _cPart2_ ]

	def SplitAfterSubStringCS(pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(pcSubStr, pCaseSensitive)
		if len(_anPos_) = 0
			return [ This.Content() ]
		ok

		_nLenSub_ = StzLen(pcSubStr)
		_anAfterPos_ = []
		_nAnPos1Len_ = len(_anPos_)
		for _iLoopAnPos1_ = 1 to _nAnPos1Len_
			_nPos_ = _anPos_[_iLoopAnPos1_]
			_anAfterPos_ + (_nPos_ + _nLenSub_ - 1)
		next

		return This.SplitAfterPositions(_anAfterPos_)

	# Cuts the text behind every occurrence of a fragment, keeping the fragments.
	#
	#   pcSubStr   the fragment to cut behind
	#   returns    a list of texts; the whole text in a list when the fragment is absent
	#   note       a😀b😀c after the emoji gives a😀, b😀 and c
	#   see        SplitBeforeSubString, SplitAfter
	def SplitAfterSubString(pcSubStr)
		return This.SplitAfterSubStringCS(pcSubStr, 1)

	# Cuts the text behind each of several characters.
	#
	#   _anPos_    the list of 1-based positions, in any order
	#   returns    a list of texts that joins back to the original
	#   note       a,b,,c after 2 and 4 gives a,, b, and ,c
	#   see        SplitAfterPosition, SplitBeforePositions
	def SplitAfterPositions(_anPos_)
		if This.IsEmpty()
			return []
		ok

		# Split after each position: segments end at pos, next starts at pos+1
		_anSapSorted_ = sort(_anPos_)
		_nSapLen_ = This.NumberOfChars()
		_aSapResult_ = []
		_nSapPrev_ = 1

		_n_anSapSortedLen_ = len(_anSapSorted_)
		for _iSap_ = 1 to _n_anSapSortedLen_
			_nSapPos_ = _anSapSorted_[_iSap_]
			if _nSapPos_ >= _nSapPrev_ and _nSapPos_ <= _nSapLen_
				_aSapResult_ + @oString.Section(_nSapPrev_, _nSapPos_)
				_nSapPrev_ = _nSapPos_ + 1
			ok
		next

		if _nSapPrev_ <= _nSapLen_
			_aSapResult_ + @oString.Section(_nSapPrev_, _nSapLen_)
		ok

		return _aSapResult_

	  #======================================================#
	 #   PARTITION (split into [before, sep, after])         #
	#======================================================#

	def PartitionCS(pcSep, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringPartitionCS(_pH_, pcSep, _bCase_)
		_cResult_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _SplitNullDelimited(_cResult_)

	# Returns only the text before the first separator, in a one-item list, today instead of the cut into before, separator and after.
	#
	#   pcSep      the separator
	#   returns    a list with one text; the whole text in a list when the separator is absent
	#   note       use stzString.Partition
	#   warning    the engine hands back the three pieces in a buffer separated by NUL bytes and
	#              Ring reads only up to the first one, so key=value=more with = gives only key;
	#              confirmed with a-b, x=y=z, one two and a Hebrew text; stzString.Partition gives
	#              the real three-part cut
	#   see        RPartition, PartitionAfter
	def Partition(pcSep)
		return This.PartitionCS(pcSep, 1)

	def PartitionAfterCS(pcSep, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringPartitionAfterCS(_pH_, pcSep, _bCase_)
		_cResult_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _SplitNullDelimited(_cResult_)

	# Returns only the text behind the first separator, in a one-item list, today instead of the cut that keeps the separator on the first part.
	#
	#   pcSep      the separator
	#   returns    a list with one text; [ ] when the separator is absent
	#   note       use stzString.Partition
	#   warning    the NUL-separated engine buffer is read up to its first NUL, so key=value=more
	#              with = gives only value=more; confirmed with a-b, x=y=z and a Hebrew text
	#   see        Partition, RPartitionAfter
	def PartitionAfter(pcSep)
		return This.PartitionAfterCS(pcSep, 1)

	def RPartitionCS(pcSep, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRpartitionCS(_pH_, pcSep, _bCase_)
		_cResult_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _SplitNullDelimited(_cResult_)

	# Returns only the text before the last separator, in a one-item list, today instead of the cut into before, separator and after.
	#
	#   pcSep      the separator
	#   returns    a list with one text; [ ] when the separator is absent
	#   note       use stzString.RPartition
	#   warning    the NUL-separated engine buffer is read up to its first NUL, so key=value=more
	#              with = gives key=value; confirmed with x=y=z
	#   see        Partition, RPartitionAfter
	def RPartition(pcSep)
		return This.RPartitionCS(pcSep, 1)

	def RPartitionAfterCS(pcSep, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRpartitionAfterCS(_pH_, pcSep, _bCase_)
		_cResult_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _SplitNullDelimited(_cResult_)

	# Returns only the text behind the last separator, in a one-item list, today instead of the cut that keeps the separator on the first part.
	#
	#   pcSep      the separator
	#   returns    a list with one text; the whole text in a list when the separator is absent
	#   note       use stzString.RPartition
	#   warning    the NUL-separated engine buffer is read up to its first NUL, so key=value=more
	#              with = gives only more; confirmed with x=y=z and a Hebrew text
	#   see        RPartition, PartitionAfter
	def RPartitionAfter(pcSep)
		return This.RPartitionAfterCS(pcSep, 1)

	  #==============================#
	 #     REGEX SPLIT              #
	#==============================#

	# Cuts the text at every match of a regular expression and drops the matches.
	#
	#   pcPattern   the regular expression
	#   returns     a list of texts; the whole text in a list when nothing matches, and [ "" ] for
	#               an empty text
	#   note        SplitRegex is the same call; ,+ on a,b,,c gives a, b, c because the match takes
	#               both commas at once; [, ]+ on שלום עולם, שלום gives three words
	#   see         Split, SplitAtSubString
	#@ aka  Split the string on the matches of the given regex pattern.
	def SplitByRegex(pcPattern)
		_pH_ = @oString.Engine()
		_nSbrCount_ = StzEngineStringRegexSplitCount(_pH_, pcPattern, 0)
		if _nSbrCount_ <= 0
			return [ @oString.Content() ]
		ok
		_acSbrResult_ = []
		for _iSbr_ = 1 to _nSbrCount_
			_acSbrResult_ + StzEngineStringRegexSplitGet(_pH_, pcPattern, 0, _iSbr_)
		next
		return _acSbrResult_

		def SplitRegex(pcPattern)
			return This.SplitByRegex(pcPattern)

	def SplitByRegexCS(pcPattern, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nFlags_ = 0
		if _bCase_ = 0
			_nFlags_ = 1
		ok
		_pH_ = @oString.Engine()
		_nSbrcsCount_ = StzEngineStringRegexSplitCount(_pH_, pcPattern, _nFlags_)
		if _nSbrcsCount_ <= 0
			return [ @oString.Content() ]
		ok
		_acSbrcsResult_ = []
		for _iSbrcs_ = 1 to _nSbrcsCount_
			_acSbrcsResult_ + StzEngineStringRegexSplitGet(_pH_, pcPattern, _nFlags_, _iSbrcs_)
		next
		return _acSbrcsResult_

		def SplitRegexCS(pcPattern, pCaseSensitive)
			return This.SplitByRegexCS(pcPattern, pCaseSensitive)
