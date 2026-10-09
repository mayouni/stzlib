#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGBOUNDER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String bounder -- sections, ranges,         #
#                  between, bounding, and bounds checking.     #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringBounderXT.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Cuts a text by position or by its surroundings: sections, ranges, the text between two bounds, and tests of what bounds what.
#
# It is the cutting helper behind the Section, Between and IsBoundedBy methods of stzString, which
# builds one over itself; reach for it directly with new stzStringBounder(cText) or
# StzStringBounderQ(cText) when you only need the cutting. The reads (Section, Range, Between,
# FirstBetween, SectionBounds, IsBoundedBy...) return a text, a list or TRUE or FALSE and leave the
# held text alone; the ReplaceBetween and RemoveBetween verbs change the held text in place and keep
# the bounds, and the variants ending in IB (ReplaceBetweenIB, RemoveBetweenIB) take the bounds with
# them. Read the result with Content. Positions count characters from 1, not bytes, so Hebrew,
# Arabic and emoji text is cut where you expect. The rank of the Nth forms starts at 1. Pass a plain
# text, not a stzString object: an in-place edit through a bounder empties the stzString that was
# passed in. At the edges of a text, trust SectionBounds and FindSectionBoundsZZ over their IB
# forms.
#
#   receiver   o1 = new stzStringBounder("one [two] three [four] five")
#   example    ? o1.Section(5, 9)
#              #--> [two]
#              ? @@( o1.Between("[", "]") )
#              #--> [ "two", "four" ]
#              ? o1.NthBetween(2, "[", "]")
#              #--> four
#              o1.RemoveBetween("[", "]")
#              ? o1.Content()
#              #--> one [] three [] five
#              o2 = new stzStringBounder("שלום [עולם] יפה")
#              ? o2.FirstBetween("[", "]") = "עולם"
#              #--> 1
#              o3 = new stzStringBounder("a😀b😀c")
#              ? o3.Section(2, 4) = "😀b😀"
#              #--> 1
#   see        stzString, stzStringLeadTrail, stzStringFormatter
class stzStringBounder from stzObject

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a bounder over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to cut, or a stzString whose content is used, any other value
	#                     raises an error
	#   returns           nothing; the object is built
	#   note              pass a plain text and read the result with Content; stzString does it
	#                     safely by writing the bounder result back with Update
	#   warning           with a stzString argument, the first in-place edit (ReplaceBetween,
	#                     RemoveBetween and their kin) leaves the stzString you passed reading as an
	#                     empty text, while the reads (Section, Between, IsBoundedBy...) leave it
	#                     alone; the bounder itself keeps the right text
	#   see               Content, Section
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringBounder! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the text as it stands now, after the replacements and removals made so far.
	#
	#   returns    a text
	#   see        NumberOfChars, Section
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting an emoji or a Hebrew letter as one.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text holds no character at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfChars, Content
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     SECTION (SLICE)           #
	#===============================#

	def SectionCS(_n1_, _n2_, pCaseSensitive)

		_nLen_ = @oString.NumberOfChars()

		if CheckingParams()

			if isList(_n1_)
				_oN1_ = Q(_n1_)
				if IsOneOfTheseNamedParamsList(_n1_, [
					:From, :FromPosition, :Start, :FromStart,
					:StartingAt, :StartingAtPosition,
					:Between, :BetweenPosition ])
					_n1_ = _n1_[2]
				ok
			ok

			if isList(_n2_)
				_oN2_ = Q(_n2_)
				if IsOneOfTheseNamedParamsList(_n2_, [
					:To, :ToPosition, :End, :ToEnd,
					:Until, :UntilPosition, :UpTo, :UpToPosition, :And ])
					_n2_ = _n2_[2]
				ok
			ok

			if isString(_n1_)
				if _n1_ = :First or _n1_ = :FirstChar
					_n1_ = 1
				but _n1_ = :Last or _n1_ = :LastChar
					_n1_ = _nLen_
				else
					_oFinder_ = new stzStringFinder(@oString)
					_n1_ = _oFinder_.FindFirstCS(_n1_, pCaseSensitive)
				ok
			ok

			if isString(_n2_)
				if _n2_ = :End or _n2_ = :Last or _n2_ = :LastChar
					_n2_ = _nLen_
				but _n2_ = :First or _n2_ = :FirstChar
					_n2_ = 1
				else
					_nLen2_ = StzLen(_n2_)
					_oFinder_ = new stzStringFinder(@oString)
					_n2_ = _oFinder_.FindLastCS(_n2_, pCaseSensitive) + _nLen2_ - 1
				ok
			ok

			if NOT @BothAreNumbers(_n1_, _n2_)
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		if _n1_ > _n2_
			_nSwap_ = _n1_
			_n1_ = _n2_
			_n2_ = _nSwap_
		ok

		if NOT ( _n1_ >= 1 and _n1_ <= _nLen_ and _n2_ >= 1 and _n2_ <= _nLen_ )
			StzRaise("Indexes out of range! n1 and n2 must be inside the string.")
		ok

		return @oString.Section(_n1_, _n2_)

		def SectionCSQ(_n1_, _n2_, pCaseSensitive)
			return new stzStringBounder( This.SectionCS(_n1_, _n2_, pCaseSensitive) )

	# Returns the characters from one position to another, both included; the two positions may come in either order.
	#
	#   _n1_       the first position, counted in characters from 1, or a named :From = n, or a text
	#              to find (its first occurrence)
	#   _n2_       the last position, or a named :To = n, or a text to find (the end of its last
	#              occurrence)
	#   returns    a text; an error is raised when a position is below 1 or beyond the last
	#              character
	#   note       Section(9, 5) answers what Section(5, 9) does; :First and :Last stand for the
	#              first and last character
	#   see        Range, Sections, AntiSection
	def Section(_n1_, _n2_)
		return This.SectionCS(_n1_, _n2_, 1)

		def SectionQ(_n1_, _n2_)
			return new stzStringBounder(This.Section(_n1_, _n2_))

	  #===============================#
	 #     MULTIPLE SECTIONS         #
	#===============================#

	# Returns several sections at once, one text per [ start, end ] pair, in the order given.
	#
	#   _aSections_   a list of [ start, end ] pairs of positions
	#   returns       a list of texts
	#   note          the same call as stzString.Sections
	#   see           Section, AntiSection
	def Sections(_aSections_)
		return @oString.Sections(_aSections_)

	  #===============================#
	 #     ANTI-SECTION              #
	#===============================#

	# Returns what lies outside a section: the text before it and the text after it, leaving out an empty side.
	#
	#   _n1_       the first position of the section
	#   _n2_       the last position of the section
	#   returns    a list of one or two texts
	#   note       AntiSection(1, 4) answers only the text after position 4, because nothing lies
	#              before it
	#   see        Section, SectionBounds
	def AntiSection(_n1_, _n2_)
		_nLen_ = @oString.NumberOfChars()
		_acResult_ = []

		if _n1_ > 1
			_acResult_ + @oString.Section(1, _n1_ - 1)
		ok
		if _n2_ < _nLen_
			_acResult_ + @oString.Section(_n2_ + 1, _nLen_)
		ok

		return _acResult_

	  #===============================#
	 #     RANGE                     #
	#===============================#

	def RangeCS(_nStartPos_, nRange, pCaseSensitive)

		if CheckingParams()
			if NOT isNumber(nRange)
				StzRaise("Incorrect param type! nRange must be a number.")
			ok

			if isNumber(_nStartPos_)
				if _nStartPos_ < 0
					_nStartPos_ = @oString.NumberOfChars() + _nStartPos_ + 1
				ok
				if _nStartPos_ = 0 or nRange = 0
					return ""
				ok
			ok
		ok

		_cResult_ = ""

		if nRange > 0
			if CheckingParams() and isString(_nStartPos_)
				_oFinder_ = new stzStringFinder(@oString)
				_nStartPos_ = _oFinder_.FindFirstCS(_nStartPos_, pCaseSensitive)
			ok
			_cResult_ = This.SectionCS(_nStartPos_, _nStartPos_ + nRange - 1, pCaseSensitive)
		else
			_n1_ = _nStartPos_ + nRange + 1
			if _n1_ > 0
				_cResult_ = This.SectionCS(_n1_, _nStartPos_, pCaseSensitive)
			ok
		ok

		return _cResult_

		def RangeCSQ(_nStartPos_, nRange, pCaseSensitive)
			return new stzStringBounder( This.RangeCS(_nStartPos_, nRange, pCaseSensitive) )

	# Returns a run of characters from a position, backwards when the count is negative; a negative position counts from the end.
	#
	#   _nStartPos_   the position to start from, counted from 1, a negative one counted from the
	#                 end, or a text to find
	#   nRange        how many characters to take, a negative number takes them backwards ending at
	#                 the position
	#   returns       a text; empty when the number is 0
	#   note          Range(5, 5) and Range(9, -5) both answer the characters 5 to 9; a text start
	#                 finds its first occurrence
	#   see           Section
	def Range(_nStartPos_, nRange)
		return This.RangeCS(_nStartPos_, nRange, 1)

		def RangeQ(_nStartPos_, nRange)
			return new stzStringBounder( This.Range(_nStartPos_, nRange) )

	  #===============================#
	 #     BETWEEN                   #
	#===============================#

	def BetweenCS(pSubStrOrPos1, pSubStrOrPos2, pCaseSensitive)
		# Softanza semantics: Between() returns ALL matches (list)

		if CheckingParams()
			if isList(pSubStrOrPos2) and IsAndNamedParamList(pSubStrOrPos2)
				pSubStrOrPos2 = pSubStrOrPos2[2]
			ok
		ok

		if NOT ( @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2) or @BothAreNumbers(pSubStrOrPos1, pSubStrOrPos2) )
			StzRaise("Incorrect params types! pSubStrOrPos1 and pSubStrOrPos2 must be both strings or numbers.")
		ok

		if @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2)
			# Engine-backed: returns ALL substrings as null-delimited buffer
			_bBtwnCase_ = @CaseSensitive(pCaseSensitive)
			_pH_ = @oString.Engine()
			_pR_ = StzEngineStringBetweenAllCS(_pH_, pSubStrOrPos1, pSubStrOrPos2, _bBtwnCase_)
			if _pR_ = "" return [] ok
			_cBtwnJoined_ = StzEngineStringData(_pR_)
			StzEngineStringFree(_pR_)
			if _cBtwnJoined_ = ""
				return []
			ok
			return _SplitNullDelimited(_cBtwnJoined_)
		else
			# Positional: single section between two positions
			_n1_ = pSubStrOrPos1 + 1
			_n2_ = pSubStrOrPos2 - 1
			_cBtwnResult_ = @oString.Section(_n1_, _n2_)
			return [ _cBtwnResult_ ]
		ok

	# Returns the text found between every pair of an opening and a closing bound, or the single stretch between two positions.
	#
	#   pSubStrOrPos1   the opening text or the position before the stretch
	#   pSubStrOrPos2   the closing text or the position after the stretch, also accepted as :And =
	#                   text
	#   returns         a list of texts; an empty list when no pair is found
	#   note            the bounds are left out of each result; matching respects case, so
	#                   Between("ONE", "THREE") finds nothing in one two three; with two positions
	#                   the answer is a list of one text
	#   see             FirstBetween, LastBetween, NthBetween
	def Between(pSubStrOrPos1, pSubStrOrPos2)
		return This.BetweenCS(pSubStrOrPos1, pSubStrOrPos2, 1)

	  #=======================================#
	 #     FIRST BETWEEN (single result)     #
	#=======================================#

	def FirstBetweenCS(pSubStrOrPos1, pSubStrOrPos2, pCaseSensitive)

		if CheckingParams()
			if isList(pSubStrOrPos2) and IsAndNamedParamList(pSubStrOrPos2)
				pSubStrOrPos2 = pSubStrOrPos2[2]
			ok
		ok

		if NOT ( @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2) or @BothAreNumbers(pSubStrOrPos1, pSubStrOrPos2) )
			StzRaise("Incorrect params types! pSubStrOrPos1 and pSubStrOrPos2 must be both strings or numbers.")
		ok

		if @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2)
			# Engine-backed: returns FIRST match only
			_bFbCase_ = @CaseSensitive(pCaseSensitive)
			_pH_ = @oString.Engine()
			_pR_ = StzEngineStringBetweenFirstCS(_pH_, pSubStrOrPos1, pSubStrOrPos2, _bFbCase_)
			if _pR_ = "" return "" ok
			_cFbResult_ = StzEngineStringData(_pR_)
			StzEngineStringFree(_pR_)
			return _cFbResult_
		else
			_n1_ = pSubStrOrPos1 + 1
			_n2_ = pSubStrOrPos2 - 1
			return @oString.Section(_n1_, _n2_)
		ok

	# Returns the text between the first opening bound and its closing bound.
	#
	#   pSubStrOrPos1   the opening text or the position before the stretch
	#   pSubStrOrPos2   the closing text or the position after the stretch
	#   returns         a text; an empty text when no pair is found
	#   note            with two positions it answers the stretch between them, like Between
	#   see             Between, LastBetween, NthBetween
	def FirstBetween(pSubStrOrPos1, pSubStrOrPos2)
		return This.FirstBetweenCS(pSubStrOrPos1, pSubStrOrPos2, 1)

	  #=======================================#
	 #     LAST BETWEEN (single result)      #
	#=======================================#

	def LastBetweenCS(pSubStrOrPos1, pSubStrOrPos2, pCaseSensitive)

		if CheckingParams()
			if isList(pSubStrOrPos2) and IsAndNamedParamList(pSubStrOrPos2)
				pSubStrOrPos2 = pSubStrOrPos2[2]
			ok
		ok

		if NOT ( @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2) or @BothAreNumbers(pSubStrOrPos1, pSubStrOrPos2) )
			StzRaise("Incorrect params types! pSubStrOrPos1 and pSubStrOrPos2 must be both strings or numbers.")
		ok

		if @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2)
			# Engine-backed: returns LAST match only
			_pH_ = @oString.Engine()
			_pR_ = StzEngineStringBetweenLast(_pH_, pSubStrOrPos1, pSubStrOrPos2)
			if _pR_ = "" return "" ok
			_cLbResult_ = StzEngineStringData(_pR_)
			StzEngineStringFree(_pR_)
			return _cLbResult_
		else
			_n1_ = pSubStrOrPos1 + 1
			_n2_ = pSubStrOrPos2 - 1
			return @oString.Section(_n1_, _n2_)
		ok

	# Returns the text between the last opening bound and its closing bound.
	#
	#   pSubStrOrPos1   the opening text or the position before the stretch
	#   pSubStrOrPos2   the closing text or the position after the stretch
	#   returns         a text; an empty text when no pair is found
	#   note            with two positions it answers the stretch between them, like Between
	#   see             Between, FirstBetween, NthBetween
	def LastBetween(pSubStrOrPos1, pSubStrOrPos2)
		return This.LastBetweenCS(pSubStrOrPos1, pSubStrOrPos2, 1)

	  #=======================================#
	 #     NTH BETWEEN (single result)       #
	#=======================================#

	def NthBetweenCS(n, pSubStrOrPos1, pSubStrOrPos2, pCaseSensitive)

		if CheckingParams()
			if isList(pSubStrOrPos2) and IsAndNamedParamList(pSubStrOrPos2)
				pSubStrOrPos2 = pSubStrOrPos2[2]
			ok
		ok

		if NOT ( @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2) or @BothAreNumbers(pSubStrOrPos1, pSubStrOrPos2) )
			StzRaise("Incorrect params types! pSubStrOrPos1 and pSubStrOrPos2 must be both strings or numbers.")
		ok

		if @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2)
			# Engine-backed: returns NTH match only
			# Engine is 0-based for nth, Softanza is 1-based
			_pH_ = @oString.Engine()
			_pR_ = StzEngineStringBetweenNth(_pH_, pSubStrOrPos1, pSubStrOrPos2, n - 1)
			if _pR_ = "" return "" ok
			_cNbResult_ = StzEngineStringData(_pR_)
			StzEngineStringFree(_pR_)
			return _cNbResult_
		else
			_n1_ = pSubStrOrPos1 + 1
			_n2_ = pSubStrOrPos2 - 1
			return @oString.Section(_n1_, _n2_)
		ok

	# Returns the text between the nth pair of bounds, counting pairs from 1.
	#
	#   n               which pair, from 1
	#   pSubStrOrPos1   the opening text or the position before the stretch
	#   pSubStrOrPos2   the closing text or the position after the stretch
	#   returns         a text; an empty text when there is no nth pair or n is 0
	#   note            with two positions n is ignored and the stretch between them is answered
	#   see             Between, FirstBetween, LastBetween
	def NthBetween(n, pSubStrOrPos1, pSubStrOrPos2)
		return This.NthBetweenCS(n, pSubStrOrPos1, pSubStrOrPos2, 1)

	  #=============================================#
	 #     REPLACE BETWEEN (bounds preserved)      #
	#=============================================#

	# Replaces the text between every opening and closing bound, keeping the bounds, in place.
	#
	#   pcOpen          the opening bound
	#   pcClose         the closing bound
	#   pcReplacement   the text that takes the place of what lay between them
	#   returns         nothing; the text changes. Nothing happens when no pair is found
	#   note            ReplaceBetween("[", "]", "X") turns one [two] three [four] into one [X]
	#                   three [X]; the IB form of the same name replaces the bounds too
	#   see             ReplaceFirstBetween, RemoveBetween, Between
	#@ aka  Default: bounds are NOT included (Softanza convention) ReplaceBetween("[", "]", "X") on "[hello]" => "[X]" Engine replaces including bounds, so we wrap replacement
	def ReplaceBetween(pcOpen, pcClose, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceBetween(_pH_, pcOpen, pcClose, pcOpen + pcReplacement + pcClose)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	# Replaces the text between the first pair of bounds, keeping the bounds, in place.
	#
	#   pcOpen          the opening bound
	#   pcClose         the closing bound
	#   pcReplacement   the text that takes the place of what lay between them
	#   returns         nothing; the text changes. Nothing happens when no pair is found
	#   see             ReplaceBetween, ReplaceLastBetween, FirstBetween
	def ReplaceFirstBetween(pcOpen, pcClose, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceFirstBetween(_pH_, pcOpen, pcClose, pcOpen + pcReplacement + pcClose)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	# Replaces the text between the last pair of bounds, keeping the bounds, in place.
	#
	#   pcOpen          the opening bound
	#   pcClose         the closing bound
	#   pcReplacement   the text that takes the place of what lay between them
	#   returns         nothing; the text changes. Nothing happens when no pair is found
	#   see             ReplaceBetween, ReplaceFirstBetween, LastBetween
	def ReplaceLastBetween(pcOpen, pcClose, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceLastBetween(_pH_, pcOpen, pcClose, pcOpen + pcReplacement + pcClose)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	# Replaces the text between the nth pair of bounds, keeping the bounds, in place.
	#
	#   n               which pair, from 1
	#   pcOpen          the opening bound
	#   pcClose         the closing bound
	#   pcReplacement   the text that takes the place of what lay between them
	#   returns         nothing; the text changes. Nothing happens when there is no nth pair
	#   note            the rank starts at 1, like NthBetween
	#   see             ReplaceBetween, NthBetween, RemoveNthBetween
	def ReplaceNthBetween(n, pcOpen, pcClose, pcReplacement)
		_pH_ = @oString.Engine()
		# Engine is 0-based for nth
		_pR_ = StzEngineStringReplaceNthBetween(_pH_, pcOpen, pcClose, pcOpen + pcReplacement + pcClose, n - 1)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	  #=================================================#
	 #     REPLACE BETWEEN IB (bounds included)         #
	#=================================================#

	# IB: bounds ARE included in replacement
	# ReplaceBetweenIB("[", "]", "X") on "[hello]" => "X"

	def ReplaceBetweenIB(pcOpen, pcClose, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceBetween(_pH_, pcOpen, pcClose, pcReplacement)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	def ReplaceFirstBetweenIB(pcOpen, pcClose, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceFirstBetween(_pH_, pcOpen, pcClose, pcReplacement)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	def ReplaceLastBetweenIB(pcOpen, pcClose, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceLastBetween(_pH_, pcOpen, pcClose, pcReplacement)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	def ReplaceNthBetweenIB(n, pcOpen, pcClose, pcReplacement)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceNthBetween(_pH_, pcOpen, pcClose, pcReplacement, n - 1)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	  #=============================================#
	 #     REMOVE BETWEEN (bounds preserved)       #
	#=============================================#

	# Removes the text between every opening and closing bound, keeping the bounds, in place.
	#
	#   pcOpen     the opening bound
	#   pcClose    the closing bound
	#   returns    nothing; the text changes. Nothing happens when no pair is found
	#   note       one [two] three [four] becomes one [] three []; the IB form of the same name
	#              removes the bounds too
	#   see        RemoveFirstBetween, ReplaceBetween, Between
	#@ aka  Default: bounds are NOT included RemoveBetween("[", "]") on "[hello]" => "[]"
	def RemoveBetween(pcOpen, pcClose)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceBetween(_pH_, pcOpen, pcClose, pcOpen + pcClose)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	# Removes the text between the first pair of bounds, keeping the bounds, in place.
	#
	#   pcOpen     the opening bound
	#   pcClose    the closing bound
	#   returns    nothing; the text changes. Nothing happens when no pair is found
	#   see        RemoveBetween, RemoveLastBetween, FirstBetween
	def RemoveFirstBetween(pcOpen, pcClose)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceFirstBetween(_pH_, pcOpen, pcClose, pcOpen + pcClose)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	# Removes the text between the last pair of bounds, keeping the bounds, in place.
	#
	#   pcOpen     the opening bound
	#   pcClose    the closing bound
	#   returns    nothing; the text changes. Nothing happens when no pair is found
	#   see        RemoveBetween, RemoveFirstBetween, LastBetween
	def RemoveLastBetween(pcOpen, pcClose)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceLastBetween(_pH_, pcOpen, pcClose, pcOpen + pcClose)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	# Removes the text between the nth pair of bounds, keeping the bounds, in place.
	#
	#   n          which pair, from 1
	#   pcOpen     the opening bound
	#   pcClose    the closing bound
	#   returns    nothing; the text changes. Nothing happens when there is no nth pair
	#   note       the rank starts at 1, like NthBetween
	#   see        RemoveBetween, NthBetween, ReplaceNthBetween
	def RemoveNthBetween(n, pcOpen, pcClose)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceNthBetween(_pH_, pcOpen, pcClose, pcOpen + pcClose, n - 1)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	  #=================================================#
	 #     REMOVE BETWEEN IB (bounds included)          #
	#=================================================#

	# IB: bounds ARE removed too
	# RemoveBetweenIB("[", "]") on "[hello]" => ""

	def RemoveBetweenIB(pcOpen, pcClose)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringReplaceBetween(_pH_, pcOpen, pcClose, "")
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	def RemoveFirstBetweenIB(pcOpen, pcClose)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveFirstBetween(_pH_, pcOpen, pcClose)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	def RemoveLastBetweenIB(pcOpen, pcClose)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveLastBetween(_pH_, pcOpen, pcClose)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	def RemoveNthBetweenIB(n, pcOpen, pcClose)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveNthBetween(_pH_, pcOpen, pcClose, n - 1)
		if _pR_ != ""
			@oString.Update(StzEngineStringData(_pR_))
			StzEngineStringFree(_pR_)
		ok

	  #=======================================#
	 #     BETWEEN -- INCLUDING BOUNDS       #
	#=======================================#

	def BetweenCSIB(pSubStrOrPos1, pSubStrOrPos2, pCaseSensitive)
		if isNumber(pSubStrOrPos1) and isNumber(pSubStrOrPos2)
			return @oString.Section(pSubStrOrPos1, pSubStrOrPos2)
		ok

		_oFinder_ = new stzStringFinder(@oString)
		_n1_ = _oFinder_.FindFirstCS(pSubStrOrPos1, pCaseSensitive)
		_n2_ = _oFinder_.FindLastCS(pSubStrOrPos2, pCaseSensitive) + StzLen(pSubStrOrPos2) - 1
		return @oString.Section(_n1_, _n2_)

	def BetweenIB(pSubStrOrPos1, pSubStrOrPos2)
		return This.BetweenCSIB(pSubStrOrPos1, pSubStrOrPos2, 1)

	  #===============================#
	 #     SECTION BOUNDS            #
	#===============================#

	# Returns the positions of the characters just before and just after a section, as two [ start, end ] pairs.
	#
	#   _n1_             the first position of the section
	#   _n2_             the last position of the section
	#   _nCharsBefore_   how many characters to take before the section
	#   _nCharsAfter_    how many characters to take after it
	#   returns          a list of two pairs of numbers; a side with nothing to take is [ 0, 0 ]
	#   note             the counts are cut to what the text has, so asking for 5 before position 2
	#                    gives [ 1, 1 ]
	#   see              SectionBounds, FindSectionBoundsIBZZ
	def FindSectionBoundsZZ(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)

		if CheckingParams()
			if NOT @BothAreNumbers(_n1_, _n2_)
				StzRaise("Incorrect params types! Both n1 and n2 must be numbers.")
			ok
			if NOT @BothAreNumbers(_nCharsBefore_, _nCharsAfter_)
				StzRaise("Incorrect params types! Both nCharsBefore and nCharsAfter must be numbers.")
			ok
		ok

		if _nCharsBefore_ > _n1_
			_nCharsBefore_ = _n1_ - 1
		ok

		_nLen_ = @oString.NumberOfChars()
		if _nCharsAfter_ > _nLen_ - _n2_
			_nCharsAfter_ = _nLen_ - _n2_
		ok

		_anSectionBefore_ = [0, 0]
		if _nCharsBefore_ != 0
			_anSectionBefore_[1] = (_n1_ - _nCharsBefore_)
			_anSectionBefore_[2] = (_n1_ - 1)
		ok

		_anSectionAfter_ = [0, 0]
		if _nCharsAfter_ != 0
			_anSectionAfter_[1] = (_n2_ + 1)
			_anSectionAfter_[2] = (_n2_ + _nCharsAfter_)
		ok

		return [ _anSectionBefore_, _anSectionAfter_ ]

	# Returns the bound positions as FindSectionBoundsZZ does, moved one character inward so the section's edge characters are included.
	#
	#   _n1_             the first position of the section
	#   _n2_             the last position of the section
	#   _nCharsBefore_   how many characters to take before the section
	#   _nCharsAfter_    how many characters to take after it
	#   returns          a list of two pairs of numbers
	#   note             the non-IB form is the one to trust at the edges of the text
	#   warning          a side with no characters, which FindSectionBoundsZZ marks [ 0, 0 ],
	#                    becomes [ 1, 1 ] before and [ -1, -1 ] after, so it is no longer
	#                    recognisable as empty: for abcdefgh, FindSectionBoundsIBZZ(1, 8, 2, 2)
	#                    answers [ [ 1, 1 ], [ -1, -1 ] ]
	#   see              FindSectionBoundsZZ, SectionBounds
	def FindSectionBoundsIBZZ(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		_aSections_ = This.FindSectionBoundsZZ(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		_aSections_[1][1]++
		_aSections_[1][2]++
		_aSections_[2][1]--
		_aSections_[2][2]--
		return _aSections_

	# Returns the characters just before and just after a section, as a list of texts.
	#
	#   _n1_             the first position of the section
	#   _n2_             the last position of the section
	#   _nCharsBefore_   how many characters to take before the section
	#   _nCharsAfter_    how many characters to take after it
	#   returns          a list of texts; an empty side is left out
	#   note             SectionBounds(3, 5, 2, 2) on abcdefgh answers ab and fg; the counts are cut
	#                    to what the text has
	#   see              FindSectionBoundsZZ, AntiSection, Section
	def SectionBounds(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		_aSections_ = This.FindSectionBoundsZZ(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		return @oString.Sections(_aSections_)

	def SectionBoundsIB(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		_aSections_ = This.FindSectionBoundsIBZZ(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		return @oString.Sections(_aSections_)

	  #===============================#
	 #     IS BOUNDED BY             #
	#===============================#

	def IsBoundedByCS(pacBounds, pCaseSensitive)

		if isList(pacBounds) and IsPair(pacBounds) and
		   isList(pacBounds[2]) and IsPair(pacBounds[2])

			_oParam_ = new stzList(pacBounds[2])
			if _oParam_.IsInNamedParam()
				return This.IsBoundedByInCS(pacBounds[1], pacBounds[2], pCaseSensitive)
			but _oParam_.IsAndNamedParam()
				pacBounds[2] = pacBounds[2][2]
			ok
		ok

		if isString(pacBounds)
			_cBound1_ = pacBounds
			_cBound2_ = pacBounds

		but isList(pacBounds) and IsPairOfStrings(pacBounds)
			_cBound1_ = pacBounds[1]
			_cBound2_ = pacBounds[2]

		else
			StzRaise("Incorrect param type! pacBounds must be a string or a pair of strings.")
		ok

		_oFinder_ = new stzStringFinder(@oString)

		if _oFinder_.StartsWithCS(_cBound1_, pCaseSensitive) and
		   _oFinder_.EndsWithCS(_cBound2_, pCaseSensitive)
			return 1
		else
			return 0
		ok

	# TRUE if the text starts with the first bound and ends with the second, or with the same text at both ends.
	#
	#   pacBounds   a pair of texts [ start, end ], or one text used at both ends
	#   returns     TRUE or FALSE, as 1 or 0
	#   note        case matters; IsBoundedBy("[") is FALSE on [abc] because the end is not [
	#   see         IsBoundedByIn, SubStringIsBoundedBy, IsBoundOf
	def IsBoundedBy(pacBounds)
		return This.IsBoundedByCS(pacBounds, 1)

	  #============================================#
	 #     IS BOUNDED BY -- INSIDE A STRING       #
	#============================================#

	def IsBoundedByInCS(pacBounds, pIn, pCaseSensitive)

		if isString(pacBounds)
			_aTemp_ = []
			_aTemp_ + pacBounds + pacBounds
			pacBounds = _aTemp_
		ok

		if NOT ( isList(pacBounds) and IsPairOfStrings(pacBounds) )
			StzRaise("Incorrect param type! pacBounds must be a pair of strings.")
		ok

		if isList(pIn) and IsInOrInsideNamedParamList(pIn)
			pIn = pIn[2]
		ok

		if NOT isString(pIn)
			StzRaise("Incorrect param type! pIn must be a string.")
		ok

		_oStr_ = new stzStringBounder(pIn)
		_bResult_ = _oStr_.SubStringIsBoundedByCS(@oString.Content(), pacBounds, pCaseSensitive)

		return _bResult_

	# TRUE if the text, with the two bounds around it, occurs inside another text.
	#
	#   pacBounds   a pair of texts [ before, after ], or one text used on both sides
	#   pIn         the text to look into, also accepted as :In = text
	#   returns     TRUE or FALSE, as 1 or 0
	#   note        abc with ["<", ">"] in x <abc> y is TRUE, in x abc y FALSE
	#   see         IsBoundedBy, SubStringIsBoundedBy
	def IsBoundedByIn(pacBounds, pIn)
		return This.IsBoundedByInCS(pacBounds, pIn, 1)

	  #============================================#
	 #     SUBSTRING IS BOUNDED BY               #
	#============================================#

	def SubStringIsBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		if isString(pacBounds)
			_cBound1_ = pacBounds
			_cBound2_ = pacBounds
		but isList(pacBounds) and IsPairOfStrings(pacBounds)
			_cBound1_ = pacBounds[1]
			_cBound2_ = pacBounds[2]
		else
			StzRaise("Incorrect param type!")
		ok

		_cBounded_ = _cBound1_ + pcSubStr + _cBound2_
		_oFinder_ = new stzStringFinder(@oString)
		return _oFinder_.ContainsCS(_cBounded_, pCaseSensitive)

	# TRUE if the held text contains a substring right between the two bounds.
	#
	#   pcSubStr    the substring that must sit between the bounds
	#   pacBounds   a pair of texts [ before, after ], or one text used on both sides
	#   returns     TRUE or FALSE, as 1 or 0
	#   note        in x <abc> y, abc with ["<", ">"] is TRUE and with "<" alone FALSE
	#   see         IsBoundedByIn, SubStringIsBetween
	def SubStringIsBoundedBy(pcSubStr, pacBounds)
		return This.SubStringIsBoundedByCS(pcSubStr, pacBounds, 1)

	  #============================================#
	 #     SUBSTRING IS BETWEEN                   #
	#============================================#

	def SubStringIsBetweenCS(pcSubStr, p1, p2, pCaseSensitive)

		if NOT isString(pcSubStr)
			StzRaise("Incorrect param! pcSubStr must be a string.")
		ok

		if @BothAreNumbers(p1, p2)
			return This.SubStringIsBetweenPositionsCS(pcSubStr, p1, p2, pCaseSensitive)

		but @BothAreStrings(p1, p2)
			return This.SubStringIsBetweenSubStringsCS(pcSubStr, p1, p2, pCaseSensitive)

		else
			StzRaise("Incorrect params types! p1 and p2 must be both numbers or both strings.")
		ok

	# TRUE if a substring lies between two positions or between two texts of the held text.
	#
	#   pcSubStr   the substring to look for
	#   p1         the first position or text
	#   p2         the second position or text, both of the same kind
	#   returns    TRUE or FALSE, as 1 or 0
	#   warning    an error is raised when p1 and p2 are not both numbers or both texts
	#   see        SubStringIsBetweenPositions, SubStringIsBetweenSubStrings, SubStringIsBoundedBy
	def SubStringIsBetween(pcSubStr, p1, p2)
		return This.SubStringIsBetweenCS(pcSubStr, p1, p2, 1)

	  #============================================#
	 #     SUBSTRING IS BETWEEN POSITIONS         #
	#============================================#

	def SubStringIsBetweenPositionsCS(pcSubStr, _n1_, _n2_, pCaseSensitive)
		_cSection_ = @oString.Section(_n1_, _n2_)
		_oFinder_ = new stzStringFinder(_cSection_)
		return _oFinder_.ContainsCS(pcSubStr, pCaseSensitive)

	# TRUE if a substring occurs within the characters from one position to another.
	#
	#   pcSubStr   the substring to look for
	#   _n1_       the first position
	#   _n2_       the last position
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       in x <abc> y, abc is between positions 4 and 9 but not between 1 and 3
	#   see        SubStringIsBetween, Section
	def SubStringIsBetweenPositions(pcSubStr, _n1_, _n2_)
		return This.SubStringIsBetweenPositionsCS(pcSubStr, _n1_, _n2_, 1)

	  #============================================#
	 #     SUBSTRING IS BETWEEN SUBSTRINGS        #
	#============================================#

	def SubStringIsBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		if CheckingParams()
			if isList(pcSubStr1) and IsSubStringsNamedParamList(pcSubStr1)
				pcSubStr1 = pcSubStr1[2]
			ok
			if isList(pcSubStr2) and IsAndNamedParamList(pcSubStr2)
				pcSubStr2 = pcSubStr2[2]
			ok
		ok

		_oFinder_ = new stzStringFinder(@oString)

		_n1_ = _oFinder_.FindFirstCS(pcSubStr1, pCaseSensitive)
		_n2_ = _oFinder_.FindLastCS(pcSubStr2, pCaseSensitive)
		_bOk1_ = This.SubStringIsBetweenPositionsCS(pcSubStr, _n1_, _n2_, pCaseSensitive)

		_n1_ = _oFinder_.FindFirstCS(pcSubStr2, pCaseSensitive)
		_n2_ = _oFinder_.FindLastCS(pcSubStr1, pCaseSensitive)
		_bOk2_ = This.SubStringIsBetweenPositionsCS(pcSubStr, _n1_, _n2_, pCaseSensitive)

		return _bOk1_ or _bOk2_

	# TRUE if a substring occurs between the first occurrence of one text and the last occurrence of another, taken in either order.
	#
	#   pcSubStr    the substring to look for
	#   pcSubStr1   the first limit text, also accepted as :SubStrings = text
	#   pcSubStr2   the second limit text, also accepted as :And = text
	#   returns     TRUE or FALSE, as 1 or 0
	#   note        the two limits may come in either order: x with y and y with x give the same
	#               answer
	#   see         SubStringIsBetween, SubStringIsBetweenPositions
	def SubStringIsBetweenSubStrings(pcSubStr, pcSubStr1, pcSubStr2)
		return This.SubStringIsBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, 1)

	  #===============================#
	 #     IS BOUND OF              #
	#===============================#

	def IsBoundOfCS(pcSubStr, pcInStr, pCaseSensitive)

		if CheckingParams()
			if isList(pcInStr) and IsInNamedParamList(pcInStr)
				pcInStr = pcInStr[2]
			ok
			if NOT isString(pcInStr)
				StzRaise("Incorrect param type! pcInStr must be a string.")
			ok
		ok

		_cBounded_ = @oString.Content() + pcSubStr + @oString.Content()
		_oFinder_ = new stzStringFinder(pcInStr)
		return _oFinder_.ContainsCS(_cBounded_, pCaseSensitive)

	# TRUE if the held text stands on both sides of a substring inside another text.
	#
	#   pcSubStr   the substring that sits between the two copies of the held text
	#   pcInStr    the text to look into, also accepted as :In = text
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       with the held text << and the substring abc, x <<abc<< y is TRUE and x <<abc< y
	#              FALSE
	#   see        IsBoundedBy, SubStringIsBoundedBy
	def IsBoundOf(pcSubStr, pcInStr)
		return This.IsBoundOfCS(pcSubStr, pcInStr, 1)

	  #===============================#
	 #     CHAR AT                   #
	#===============================#

	# Returns the character at a position.
	#
	#   n          the position, counted in characters from 1
	#   returns    a text of one character; an error is raised when n is below 1 or beyond the last
	#              character
	#   see        FirstChar, LastChar, Section
	def Char(n)
		if n < 1 or n > @oString.NumberOfChars()
			StzRaise("Index out of range!")
		ok
		return @oString.NthChar(n)

	# Returns the first character.
	#
	#   returns    a text of one character; an error is raised on an empty text
	#   see        Char, LastChar
	def FirstChar()
		return This.Char(1)

	# Returns the last character.
	#
	#   returns    a text of one character; an error is raised on an empty text
	#   see        Char, FirstChar
	def LastChar()
		return This.Char(@oString.NumberOfChars())
