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
# 0 to ignore case. Found today: SplitAtSubStrings cuts at a literal <<<SEP>>> in the text, and a splitter built
# from a stzString object reads an empty text once that string is appended to.
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
		_aPartP_ = This._PartitionPieces(pcSep, pCaseSensitive, 0)
		if _aPartP_[1] = 0
			return [ This.Content(), "", "" ]
		ok
		return [ _aPartP_[2], _aPartP_[3], _aPartP_[4] ]

	# Cuts the text into the part before the first occurrence of a separator, the separator and the part after.
	#
	#   pcSep      the separator, matched as a literal text; an empty separator never matches
	#   returns    a list of three texts that joins back to the original; the whole text, an empty
	#              text and an empty text when the separator is absent
	#   note       key=value=more at = gives key, = and value=more; with the separator at the very
	#              start or end, the part on that side is an empty text; the separator is matched
	#              by characters, so Hebrew, accented and emoji separators cut where they should
	#   see        RPartition, PartitionAfter, PartitionCS
	def Partition(pcSep)
		_nPartCase_ = 1
		return This.PartitionCS(pcSep, _nPartCase_)

	def PartitionAfterCS(pcSep, pCaseSensitive)
		_aPartAfterP_ = This._PartitionPieces(pcSep, pCaseSensitive, 0)
		if _aPartAfterP_[1] = 0
			return [ This.Content(), "" ]
		ok
		return [ _aPartAfterP_[2] + _aPartAfterP_[3], _aPartAfterP_[4] ]

	# Cuts the text in two just behind the first occurrence of a separator, which stays on the first part.
	#
	#   pcSep      the separator, matched as a literal text; an empty separator never matches
	#   returns    a list of two texts that joins back to the original; the whole text and an empty
	#              text when the separator is absent
	#   note       key=value=more at = gives key= and value=more; the second part is an empty text
	#              when the separator ends the text
	#   see        Partition, RPartitionAfter, PartitionAfterCS
	def PartitionAfter(pcSep)
		_nPartAfterCase_ = 1
		return This.PartitionAfterCS(pcSep, _nPartAfterCase_)

	def RPartitionCS(pcSep, pCaseSensitive)
		_aRPartP_ = This._PartitionPieces(pcSep, pCaseSensitive, 1)
		if _aRPartP_[1] = 0
			return [ "", "", This.Content() ]
		ok
		return [ _aRPartP_[2], _aRPartP_[3], _aRPartP_[4] ]

	# Cuts the text into the part before the last occurrence of a separator, the separator and the part after.
	#
	#   pcSep      the separator, matched as a literal text; an empty separator never matches
	#   returns    a list of three texts that joins back to the original; an empty text, an empty
	#              text and the whole text when the separator is absent
	#   note       key=value=more at = gives key=value, = and more; aaa at aa cuts at the last
	#              occurrence, which starts at the second a, giving a, aa and an empty text
	#   see        Partition, RPartitionAfter, RPartitionCS
	def RPartition(pcSep)
		_nRPartCase_ = 1
		return This.RPartitionCS(pcSep, _nRPartCase_)

	def RPartitionAfterCS(pcSep, pCaseSensitive)
		_aRPartAfterP_ = This._PartitionPieces(pcSep, pCaseSensitive, 1)
		if _aRPartAfterP_[1] = 0
			return [ "", This.Content() ]
		ok
		return [ _aRPartAfterP_[2] + _aRPartAfterP_[3], _aRPartAfterP_[4] ]

	# Cuts the text in two just behind the last occurrence of a separator, which stays on the first part.
	#
	#   pcSep      the separator, matched as a literal text; an empty separator never matches
	#   returns    a list of two texts that joins back to the original; an empty text and the whole
	#              text when the separator is absent
	#   note       key=value=more at = gives key=value= and more
	#   see        RPartition, PartitionAfter, RPartitionAfterCS
	def RPartitionAfter(pcSep)
		_nRPartAfterCase_ = 1
		return This.RPartitionAfterCS(pcSep, _nRPartAfterCase_)

	# Finds the first or the last occurrence of a separator and returns the three pieces around it.
	#
	#   pcSep            the separator; anything but a text raises
	#   pCaseSensitive   1 to match the case, 0 to ignore it
	#   nLast            0 for the first occurrence, 1 for the last
	#   returns          [ 1, before, separator, after ] when found, [ 0, "", "", "" ] when absent,
	#                    when the text is empty or when the separator is empty; the separator is the
	#                    text's own spelling of it
	#   note             the engine's partition entries return ONE piece per call (not a buffer of
	#                    pieces), so the cut is rebuilt from the piece before and the piece after
	def _PartitionPieces(pcSep, pCaseSensitive, nLast)
		if NOT isString(pcSep)
			StzRaise("Incorrect param type! The separator must be a string.")
			return [ 0, "", "", "" ]
		ok

		_bPpCase_ = @CaseSensitive(pCaseSensitive)
		_pPpH_ = @oString.Engine()
		_nPpSize_ = StzEngineStringSize(_pPpH_)
		if _nPpSize_ = 0 or ring_len(pcSep) = 0
			return [ 0, "", "", "" ]
		ok

		_cPpBefore_ = ""
		_cPpAfter_ = ""

		if nLast = 0
			# The piece before is the whole text when the separator is absent
			_pPpB_ = StzEngineStringPartitionCS(_pPpH_, pcSep, _bPpCase_)
			_cPpBefore_ = StzEngineStringData(_pPpB_)
			StzEngineStringFree(_pPpB_)
			if ring_len(_cPpBefore_) >= _nPpSize_
				return [ 0, "", "", "" ]
			ok
			_pPpA_ = StzEngineStringPartitionAfterCS(_pPpH_, pcSep, _bPpCase_)
			_cPpAfter_ = StzEngineStringData(_pPpA_)
			StzEngineStringFree(_pPpA_)
		else
			# The piece after is the whole text when the separator is absent
			_pPpA_ = StzEngineStringRpartitionAfterCS(_pPpH_, pcSep, _bPpCase_)
			_cPpAfter_ = StzEngineStringData(_pPpA_)
			StzEngineStringFree(_pPpA_)
			if ring_len(_cPpAfter_) >= _nPpSize_
				return [ 0, "", "", "" ]
			ok
			_pPpB_ = StzEngineStringRpartitionCS(_pPpH_, pcSep, _bPpCase_)
			_cPpBefore_ = StzEngineStringData(_pPpB_)
			StzEngineStringFree(_pPpB_)
		ok

		_cPpSep_ = pcSep
		if _bPpCase_ = 0
			# The engine cut on byte offsets it found on codepoint boundaries, so a byte slice is safe here
			_cPpSep_ = substr(@oString.Content(), ring_len(_cPpBefore_) + 1, ring_len(pcSep))
		ok

		return [ 1, _cPpBefore_, _cPpSep_, _cPpAfter_ ]

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
