#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGSECTIONS           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String sections -- Wraps stzString via      #
#                  composition. Extracting sections and ranges #
#                  from strings.                               #
#                  For aliases, use stzStringSectionsXT.       #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Cuts sections out of a text by position: reads a section or a range, lists what lies outside, and removes sections.
#
# Build one with new stzStringSections("text"). A section is a pair of positions, start and end,
# both included; a range is a start and a length. Positions count from 1 in characters, so Hebrew,
# Arabic and emoji are cut by letter. The readers (Section, Range, Sections, AntiSections) raise for
# positions outside the text, while the removals clip them. The in-place removals have passive twins
# that return the text (SectionRemoved, SectionsRemoved, RangeRemoved). Do not pass a stzString
# object you still need: the first in-place removal empties it. A length of 0 and SectionBetween for
# close positions go wrong, and RemoveSections needs its pairs in ascending order; see the warnings.
#
#   receiver   o1 = new stzStringSections("abcdefghij")
#   example    ? o1.Section(2, 4)
#              #--> bcd
#              ? o1.Range(3, 3)
#              #--> cde
#              ? @@( o1.AntiSections([ [ 3, 4 ] ]) )
#              #--> [ "ab", "efghij" ]
#              ? o1.SectionRemoved(3, 5)
#              #--> abfghij
#   see        stzString, stzListSections, stzStringExtractor
class stzStringSections from stzObject

	@oString

	# Builds a section reader over a text or over a stzString object, to cut sections out of it by position.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, whose sections are read or removed
	#   returns           nothing; the object is built
	#   note              any other kind of value raises "Can't create stzStringSections! Parameter
	#                     must be a string or stzString object."
	#   warning           Given a stzString object, the first in-place removal (RemoveSection,
	#                     RemoveSections, RemoveRange) leaves that stzString EMPTY while the reader
	#                     holds the result; the readers and the passive forms do not. Pass the text,
	#                     os.Content(), to be safe
	#   see               Section, RemoveSection
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringSections! Parameter must be a string or stzString object.")
		ok

	# Returns the text the reader holds, after any in-place removal.
	#
	#   returns    a text
	#   see        NumberOfChars
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

	  #======================================================#
	 #   SECTION (SLICE)                                    #
	#======================================================#

	def SectionCS(_n1_, _n2_, pCaseSensitive)
		if CheckingParams()
			if isList(_n1_) and IsOneOfTheseNamedParamsList(_n1_, [:From, :FromPosition, :StartingAt])
				_n1_ = _n1_[2]
			ok
			if isList(_n2_) and IsOneOfTheseNamedParamsList(_n2_, [:To, :ToPosition, :Until])
				_n2_ = _n2_[2]
			ok
		ok
		return @oString.Section(_n1_, _n2_)

	# Returns the characters from one position to another, both included, as a text.
	#
	#   _n1_       the first position, from 1, or [ :From, n ]
	#   _n2_       the last position, from 1, or [ :To, n ]
	#   returns    a text
	#   note       a position outside the text raises "Indexes out of range!", where the removal
	#              methods clip it; a start after the end is swapped, so Section(4, 2) equals
	#              Section(2, 4)
	#   see        Range, Sections, SectionRemoved
	def Section(_n1_, _n2_)
		return This.SectionCS(_n1_, _n2_, 1)

	  #======================================================#
	 #   RANGE                                              #
	#======================================================#

	# Returns a run of characters given by its start and its length, as a text.
	#
	#   pnStart    the first position, from 1
	#   pnRange    how many characters
	#   returns    a text
	#   note       a run past the end raises "Indexes out of range!"
	#   warning    Range(2, 0), a length of 0, answers "ab" for "abcdefghij" instead of an empty
	#              text: it asks Section for the reversed pair 2 to 1, which is swapped
	#   see        Section, RangeRemoved
	def Range(pnStart, pnRange)
		return This.Section(pnStart, pnStart + pnRange - 1)

	  #======================================================#
	 #   MULTIPLE SECTIONS                                  #
	#======================================================#

	# Returns several sections at once, one text per [ start, end ] pair, in the order given.
	#
	#   paSections   a list of [ start, end ] pairs
	#   returns      a list of texts
	#   note         each pair is read as for Section
	#   see          Section, AntiSections
	def Sections(paSections)
		_aResult_ = []
		_nLen_ = len(paSections)
		for i = 1 to _nLen_
			_aResult_ + This.Section(paSections[i][1], paSections[i][2])
		next
		return _aResult_

	  #======================================================#
	 #   ANTI-SECTIONS                                      #
	#======================================================#

	# Returns the stretches of text that lie outside the given sections, in order.
	#
	#   paSections   a list of [ start, end ] pairs, covered whatever their order or overlap
	#   returns      a list of texts; [ ] when the sections cover everything
	#   note         AntiSections([ [3,4] ]) on "abcdefghij" gives "ab" and "efghij"; a pair given
	#                backwards is swapped; no sections give the whole text as one piece
	#   see          Sections, RemoveSections
	def AntiSections(paSections)
		_nLen_ = @oString.NumberOfChars()
		_aCovered_ = []
		_nSLen_ = len(paSections)
		for i = 1 to _nSLen_
			_n1_ = paSections[i][1]
			_n2_ = paSections[i][2]
			if _n1_ > _n2_
				_temp_ = _n1_
				_n1_ = _n2_
				_n2_ = _temp_
			ok
			for j = _n1_ to _n2_
				_aCovered_ + j
			next
		next

		_aResult_ = []
		_nStart_ = 0
		for i = 1 to _nLen_
			_bCovered_ = 0
			_nCoveredLen_ = len(_aCovered_)
			for k = 1 to _nCoveredLen_
				if _aCovered_[k] = i
					_bCovered_ = 1
					exit
				ok
			next
			if _bCovered_ = 0
				if _nStart_ = 0
					_nStart_ = i
				ok
			else
				if _nStart_ > 0
					_aResult_ + This.Section(_nStart_, i - 1)
					_nStart_ = 0
				ok
			ok
		next
		if _nStart_ > 0
			_aResult_ + This.Section(_nStart_, _nLen_)
		ok
		return _aResult_

	  #======================================================#
	 #   SECTION BETWEEN POSITIONS                          #
	#======================================================#

	# Returns the text strictly between two positions, but a wrong piece when they are one apart or equal.
	#
	#   _n1_       the position before the stretch
	#   _n2_       the position after it
	#   returns    a text
	#   warning    Returns the wrong text when the positions are one apart or equal:
	#              SectionBetween(2, 3) on "abcdefghij" answers "bc" and SectionBetween(2, 2)
	#              answers "abc", instead of an empty text, because it asks Section for the reversed
	#              pair 3 to 2 or 3 to 1, which is swapped; it is right when the positions are two
	#              or more apart: (2, 6) gives "cde"
	#   see        Section
	def SectionBetween(_n1_, _n2_)
		return This.Section(_n1_ + 1, _n2_ - 1)

	  #======================================================#
	 #   REMOVE SECTION                                     #
	#======================================================#

	# Removes the characters from one position to another, both included, in place.
	#
	#   _n1_       the first position
	#   _n2_       the last position
	#   returns    nothing; use RemoveSectionQ to chain
	#   note       positions outside the text are clipped to it (0 counts as 1, 99 as the length)
	#              and a start after the end is swapped, unlike Section which raises
	#   see        SectionRemoved, RemoveRange
	def RemoveSection(_n1_, _n2_)
		_nLen_ = @oString.NumberOfChars()
		if _n1_ < 1 _n1_ = 1 ok
		if _n2_ > _nLen_ _n2_ = _nLen_ ok
		if _n1_ > _n2_
			_temp_ = _n1_
			_n1_ = _n2_
			_n2_ = _temp_
		ok
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRemoveRange(_pH_, _n1_, _n2_ - _n1_ + 1)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RemoveSectionQ(_n1_, _n2_)
			This.RemoveSection(_n1_, _n2_)
			return This

	# Returns the text without the characters from one position to another, leaving the reader unchanged.
	#
	#   _n1_       the first position
	#   _n2_       the last position
	#   returns    a text
	#   note       clips out-of-range positions, like RemoveSection
	#   see        RemoveSection
	def SectionRemoved(_n1_, _n2_)
		_oCopy_ = new stzStringSections(@oString.Content())
		return _oCopy_.RemoveSectionQ(_n1_, _n2_).Content()

	  #======================================================#
	 #   REMOVE MANY SECTIONS                               #
	#======================================================#

	# Removes several sections, in place, one [ start, end ] pair after the other from the last pair to the first.
	#
	#   paSections   a list of [ start, end ] pairs, in ascending order
	#   returns      nothing; use RemoveSectionsQ to chain
	#   warning      The pairs must be in ascending order of position: [ [7,8], [2,3] ] on
	#                "0123456789" gives "034567" instead of "034589", because each removal shifts
	#                the positions of the ones after it and the order is not checked or sorted
	#   see          SectionsRemoved, RemoveSection
	def RemoveSections(paSections)
		_nLen_ = len(paSections)
		for i = _nLen_ to 1 step -1
			This.RemoveSection(paSections[i][1], paSections[i][2])
		next

		def RemoveSectionsQ(paSections)
			This.RemoveSections(paSections)
			return This

	# Returns the text without several sections, leaving the reader unchanged.
	#
	#   paSections   a list of [ start, end ] pairs, in ascending order
	#   returns      a text
	#   warning      The same order requirement: [ [7,8], [2,3] ] gives the wrong text
	#   see          RemoveSections
	def SectionsRemoved(paSections)
		_oCopy_ = new stzStringSections(@oString.Content())
		return _oCopy_.RemoveSectionsQ(paSections).Content()

	  #======================================================#
	 #   REMOVE RANGE                                       #
	#======================================================#

	# Removes a run of characters given by its start and its length, in place.
	#
	#   pnStart    the first position, from 1
	#   pnRange    how many characters
	#   returns    nothing; use RemoveRangeQ to chain
	#   note       a length of 0 removes two characters, the one at the start and the one before it,
	#              instead of none: RemoveRange(5, 0) on "0123456789" gives "01256789"; a run past
	#              the end is clipped
	#   see        RangeRemoved, RemoveSection
	def RemoveRange(pnStart, pnRange)
		This.RemoveSection(pnStart, pnStart + pnRange - 1)

		def RemoveRangeQ(pnStart, pnRange)
			This.RemoveRange(pnStart, pnRange)
			return This

	# Returns the text without a run of characters given by its start and its length, leaving the reader unchanged.
	#
	#   pnStart    the first position, from 1
	#   pnRange    how many characters
	#   returns    a text
	#   note       "abcdefghij" with 2 and 3 gives "aefghij"
	#   see        RemoveRange
	def RangeRemoved(pnStart, pnRange)
		_oCopy_ = new stzStringSections(@oString.Content())
		return _oCopy_.RemoveRangeQ(pnStart, pnRange).Content()
