#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSECTIONS            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List sections subclass -- section/slice     #
#                  retrieval, anti-sections, ranges, and        #
#                  section-based operations.                    #
#                  For aliases, use stzListSectionsXT.          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Cuts sections out of a list by positions or by start and length, and returns the parts outside a section.
#
# Build one with new stzListSections(aList) or over a stzList object; it keeps its own copy. A
# section is named by its first and last positions (Section), a range by its start and length
# (Range, Ranges); an anti-section is whatever lies outside. Positions count from 1; negative ones
# count from the end, and out-of-range ones are clipped, not refused. Section answers a flat list,
# Range answers a list wrapped one level deeper. Two aliases, ManyRanges and RangesOtherThan, raise
# errors today.
#
#   receiver   o1 = new stzListSections([ "a", "b", "c", "d", "e", "f", "g" ])
#   example    ? @@( o1.Section(2, 4) )
#              #--> [ "b", "c", "d" ]
#              ? @@( o1.Section(-3, -1) )
#              #--> [ "e", "f", "g" ]
#              ? @@( o1.AntiSection(2, 3) )
#              #--> [ [ "a" ], [ "d", "e", "f", "g" ] ]
#              ? @@( o1.Range(2, 3) )
#              #--> [ [ "b", "c", "d" ] ]
#   see        stzList, stzListGetter, stzSection
class stzListSections from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a section reader over a list or over a stzList object, working on its own copy, so the list passed in is never changed.
	#
	#   pListOrObj   a list, or a stzList object, whose sections are read
	#   returns      nothing; the object is built
	#   warning      any other kind of value raises "Can't create stzListSections! Parameter must be
	#                a list or stzList object."
	#   see          Content
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListSections! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the items the reader holds.
	#
	#   returns    a list
	#   see        Section
	def Content()
		return @oList.Content()

	# Returns how many items the list holds.
	#
	#   returns    a number
	#   see        Content
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfItems
	def IsEmpty()
		return @oList.IsEmpty()

	  #================================================#
	 #    GETTING A SECTION (OR SLICE) OF THE LIST    #
	#================================================#

	def SectionCS(_n1_, _n2_, pCaseSensitive)

		_nScLen_ = This.NumberOfItems()

		if CheckingParams()

			if isList(_n1_) and
			   IsOneOfTheseNamedParamsList(_n1_, [
					:From, :FromPosition, :FromItemAt, :FromItemAtPosition,
					:StartingAt, :StartingAtPosition,
					:StartingAtItemAt, :StartingAtItemAtPosition,
					:Between, :BetweenPosition, :BetweenCharAt,
					:BetweenItemAtPosition,
					:BetweenPositions, :BetweenItemsAtPosition
					])

				_n1_ = _n1_[2]
			ok

			if isList(_n2_) and
			   IsOneOfTheseNamedParamsList(_n2_, [
					:To, :ToPosition, :ToItemAt, :ToItemAtPosition,
					:Until, :UntilPosition, :UntilItemAt, :UntilItemAtPosition,
					:UpTo, :UpToPosition, :UpToItemAt, :UpToItemAtPosition,
					:And,
					:StartingAt, :StartingAtPosition, :StartingAtItemAt, :StartingAtItemAtPosition
					])

				_n2_ = _n2_[2]
			ok

			if isString(_n1_) and (_n1_ = :First or _n1_ = :FirstItem or
			   _n1_ = :Start or _n1_ = :StartOfList)
				_n1_ = 1
			ok

			if isString(_n2_) and (_n2_ = :Last or _n2_ = :LastItem or
			   _n2_ = :End or _n2_ = :EndOfList)
				_n2_ = _nScLen_
			ok

			if NOT (isNumber(_n1_) and isNumber(_n2_))
				StzRaise("Incorrect param types! n1 and n2 must be numbers.")
			ok
		ok

		if _n1_ < 0
			_n1_ = _nScLen_ + _n1_ + 1
		ok

		if _n2_ < 0
			_n2_ = _nScLen_ + _n2_ + 1
		ok

		if _n1_ = 0
			_n1_ = 1
		ok

		if _n2_ = 0
			_n2_ = 1
		ok

		if _n1_ > _nScLen_
			_n1_ = _nScLen_
		ok

		if _n2_ > _nScLen_
			_n2_ = _nScLen_
		ok

		if _n1_ > _n2_
			_nScTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nScTemp_
		ok

		_pScList_ = @oList._EngineListFromContent()
		_pScSection_ = StzEngineListSection(_pScList_, _n1_, _n2_)
		if _pScSection_ != ""
			_aScResult_ = StzEngineListContentToRingList(_pScSection_)
			StzEngineListFree(_pScSection_)
		else
			_aScResult_ = []
		ok
		StzEngineListFree(_pScList_)
		return _aScResult_

		def SectionCSQ(_n1_, _n2_, pCaseSensitive)
			return new stzList( This.SectionCS(_n1_, _n2_, pCaseSensitive) )

		def SliceCS(_n1_, _n2_, pCaseSensitive)
			return This.SectionCS(_n1_, _n2_, pCaseSensitive)

			def SliceCSQ(_n1_, _n2_, pCaseSensitive)
				return This.SectionCSQ(_n1_, _n2_, pCaseSensitive)

	# Returns the items from one position to another, both included, as a flat list.
	#
	#   _n1_       the first position, from 1
	#   _n2_       the last position, from 1, in the same forms, [ :To, 3 ] included
	#   returns    a list; [ ] for an empty list
	#   note       positions are forgiving: past the end they are clipped (Section(5, 99) on 7 items
	#              gives items 5 to 7), 0 is read as 1, and a start after the end is swapped, so
	#              Section(4, 2) equals Section(2, 4)
	#   see        Sections, Range, AntiSection
	#@ aka  -- WITHOUT CASESENSITIVITY
	def Section(_n1_, _n2_)
		return This.SectionCS(_n1_, _n2_, 1)

		def SectionQ(_n1_, _n2_)
			return new stzList(This.Section(_n1_, _n2_))

		def Slice(_n1_, _n2_)
			return This.Section(_n1_, _n2_)

			def SliceQ(_n1_, _n2_)
				return new stzList(This.Slice(_n1_, _n2_))

	  #------------------------------------------------------------#
	 #   GETTING A SECTION (OR SLICE) OF THE LIST -- Z/EXTENDED   #
	#------------------------------------------------------------#

	def SectionCSZ(_n1_, _n2_, pCaseSensitive)
		if CheckingParams()
			if isString(_n1_) and (_n1_ = :Start or _n1_ = :StartOfList)
				_n1_ = 1
			ok

			if NOT isNumber(_n1_)
				StzRaise("Incorrect param type! n1 must be a number.")
			ok
		ok

		_aSczResult_ = [ This.SectionCS(_n1_, _n2_, pCaseSensitive), _n1_ ]
		return _aSczResult_

		def SliceCSZ(_n1_, _n2_, pCaseSensitive)
			return This.SectionCSZ(_n1_, _n2_, pCaseSensitive)

	def SectionZ(_n1_, _n2_)
		return This.SectionCSZ(_n1_, _n2_, 1)

		def SliceZ(_n1_, _n2_)
			return SectionZ(_n1_, _n2_)

	  #------------------------------------------------------------#
	 #   GETTING A SECTION (OR SLICE) OF THE LIST -- ZZ/EXTENDED  #
	#------------------------------------------------------------#

	def SectionCSZZ(_n1_, _n2_, pCaseSensitive)
		if CheckingParams()
			if isString(_n1_) and (_n1_ = :Start or _n1_ = :StartOfList)
				_n1_ = 1
			ok

			if NOT isNumber(_n1_)
				StzRaise("Incorrect param type! n1 must be a number.")
			ok
		ok

		_aSczzResult_ = [ This.SectionCS(_n1_, _n2_, pCaseSensitive), [_n1_, _n2_] ]
		return _aSczzResult_

		def SliceCSZZ(_n1_, _n2_, pCaseSensitive)
			return This.SectionCSZZ(_n1_, _n2_, pCaseSensitive)

	def SectionZZ(_n1_, _n2_)
		return This.SectionCSZZ(_n1_, _n2_, 1)

		def SliceZZ(_n1_, _n2_)
			return This.SectionZZ(_n1_, _n2_)

	  #======================================#
	 #   GETTING MANY SECTIONS (SLICES)     #
	#======================================#

	# Returns several sections at once, one list per pair of positions, in the order given.
	#
	#   paSections   a list of [ start, end ] pairs, each read as for Section
	#   returns      a list of lists
	#   see          Section, Ranges
	def Sections(paSections)
		_aSsResult_ = []
		_nSsLen_ = len(paSections)

		for _iSs_ = 1 to _nSsLen_
			@AddItem(_aSsResult_, This.Section(paSections[_iSs_][1], paSections[_iSs_][2]))
		next

		return _aSsResult_

		def SectionsQ(paSections)
			return new stzList( This.Sections(paSections) )

		def Slices(paSections)
			return This.Sections(paSections)

			def SlicesQ(paSections)
				return This.SectionsQ(paSections)

		def ManySections(paSections)
			return This.Sections(paSections)

	  #========================================================#
	 #   FINDING THE ANTI-SECTION(S) OF GIVEN SECTION(S)      #
	#========================================================#

	# Returns the positions that lie outside a section, as one or two [ start, end ] pairs.
	#
	#   _n1_       the first position of the section
	#   _n2_       its last position, both numbers
	#   returns    a list of pairs; [ ] when the section covers the whole list
	#   note       FindAntiSection(2, 3) on 7 items gives [ [1,1], [4,7] ]
	#   see        AntiSection, Section
	def FindAntiSection(_n1_, _n2_)
		if NOT ( isNumber(_n1_) and isNumber(_n2_) )
			StzRaise("Incorrect param types! n1 and n2 must be both Numbers.")
		ok

		return @oList.FindAntiSections([ [_n1_, _n2_ ] ])

		def FindAntiSectionZZ(_n1_, _n2_)
			return This.FindAntiSection(_n1_, _n2_)

		def AntiSectionZZ(_n1_, _n2_)
			return This.FindAntiSection(_n1_, _n2_)

	# Returns the items that lie outside a section, as one list for the part before it and one for the part after it.
	#
	#   _n1_       the first position of the section
	#   _n2_       its last position, both numbers
	#   returns    a list of one or two lists; [ ] when the section covers the whole list
	#   note       a section that starts at 1 or ends at the last position leaves only one list
	#   see        FindAntiSection, Section
	def AntiSection(_n1_, _n2_)
		_aAsSecs_ = This.FindAntiSection(_n1_, _n2_)
		_aAsResult_ = []
		_nAsLen_ = len(_aAsSecs_)
		for _iAs_ = 1 to _nAsLen_
			_aAsResult_ + This.Section(_aAsSecs_[_iAs_][1], _aAsSecs_[_iAs_][2])
		next
		return _aAsResult_

		def AntiSectionQ(paSections)
			return new stzList( This.AntiSection(paSections) )

	  #------------------------------------------------------------#
	 #   FINDING THE ANTI-SECTIONS -- INCLUDING BOUNDS            #
	#------------------------------------------------------------#

	def FindAntiSectionIB(_n1_, _n2_)
		if NOT ( isNumber(_n1_) and isNumber(_n2_) )
			StzRaise("Incorrect param types! n1 and n2 must be both Numbers.")
		ok

		return @oList.FindAntiSectionsIB([ [_n1_, _n2_ ] ])

		def FindAntiSectionIBZZ(_n1_, _n2_)
			return This.FindAntiSectionIB(_n1_, _n2_)

		def AntiSectionIBZZ(_n1_, _n2_)
			return This.FindAntiSectionIB(_n1_, _n2_)

	def AntiSectionIB(_n1_, _n2_)
		_aAsiResult_ = This.Section( This.FindAntiSectionIB(_n1_, _n2_) )
		return _aAsiResult_

		def AntiSectionIBQ(paSections)
			return new stzList( This.AntiSectionIB(paSections) )

	  #===================================#
	 #    GETTING A RANGE OF THE LIST    #
	#===================================#

	# Returns the section of a given length starting at a position, wrapped in a list; a negative length counts backwards from the start.
	#
	#   pnStart    the first position, from 1
	#   pnRange    how many items, or minus that many going backwards
	#   returns    a list holding one list of items; "" when the start or the length is 0
	#   note       the answer is one list deeper than Section's: Range(2, 3) on a to g gives [ [
	#              "b","c","d" ] ], and RangeXT gives the flat list; a length past the end is
	#              clipped; an empty list answers [ [ ] ]
	#   see        RangeXT, Section, Ranges
	def Range(pnStart, pnRange)

		if CheckingParams()
			if isString(pnStart)
				if pnStart = :First or pnStart = :FirstChar
					pnStart = 1
				but pnStart = :Last or pnStart = :LastChar
					pnStart = This.NumberOfItems()
				ok
			ok

			if NOT Q([pnStart, pnRange]).BothAreNumbers()
				StzRaise("Incorrect param type! pnStart and pnRange must be both numbers.")
			ok
		ok

		if pnStart < 0
			pnStart = This.NumberOfItems() + pnStart + 1
		ok

		if pnStart = 0 or pnRange = 0
			return ""
		ok

		_aRgResult_ = []

		if pnRange > 0
			@AddItem(_aRgResult_, This.Section( pnStart, pnStart + pnRange -1 ))
		else
			_nRgN1_ = pnStart + pnRange + 1
			if _nRgN1_ > 0
				@AddItem(_aRgResult_, This.Section( _nRgN1_, pnStart ))
			ok
		ok

		return _aRgResult_

		def RangeQ(pnStart, pnRange)
			return new stzList( This.Range(pnStart, pnRange) )

	  #--------------------------------------#
	 #  GETTING THE RANGE -- eXTended form  #
	#--------------------------------------#

	def RangeXT(pnStart, pnRange)
		if NOT (isNumber(pnStart) and isNumber(pnRange))
			StzRaise("Incorrect param types! pnStart and pnRange must be both numbers.")
		ok

		if NOT pnRange >= 0
			StzRaise("Incorrect param value! pnRange must be positive.")
		ok

		if pnStart < 0
			pnStart = @oList.NumberOfItems() + pnStart + 1
		ok

		_aRxSection_ = @RangeToSection(pnStart, pnRange)
		_aRxResult_ = @oList.SectionXT(_aRxSection_[1], _aRxSection_[2])

		return _aRxResult_

	  #------------------------------------#
	 #   GETTING MANY RANGES OF THE LIST  #
	#------------------------------------#

	# Returns several ranges at once, one answer of Range for each [ start, length ] pair.
	#
	#   paRanges   a list of [ start, length ] pairs
	#   returns    a list of the lists Range returns
	#   note       each range stays wrapped in its own list, as Range does
	#   see        Range, Sections
	def Ranges(paRanges)
		_aRgsResult_ = []

		_nRanges1Len_ = len(paRanges)
		for _iLoopRanges1_ = 1 to _nRanges1Len_
			_aRgsRange_ = paRanges[_iLoopRanges1_]
			@AddItem(_aRgsResult_, This.Range( _aRgsRange_[1], _aRgsRange_[2] ))
		next

		return _aRgsResult_

		# Returns several ranges at once, the same as Ranges.
		#
		#   paSections   a list of [ start, length ] pairs
		#   returns      nothing today: it raises error R24
		#   note         the alias passes paRanges on but its own parameter is named paSections
		#   warning      Raises error R24 "Using uninitialized variable: paranges" today instead of
		#                the ranges; use Ranges
		#   see          Ranges
		def ManyRanges(paSections)
			return This.Ranges(paRanges)

	  #--------------------------------------------------------#
	 #   GETTING THE ANTI-RANGES OF A GIVEN SET OF SECTIONS   #
	#--------------------------------------------------------#

	# Returns the parts of the list that lie outside the given ranges, each part as a list.
	#
	#   paRanges   a list of [ start, length ] pairs
	#   returns    a list of lists
	#   note       AntiRanges([ [2,2] ]) on a to g leaves a and d to g
	#   see        RangesAndAntiRanges, AntiSection
	def AntiRanges(paRanges)
		_aArSections_ = RangesToSections(paRanges)
		_aArResult_ = @oList.AntiSections(_aArSections_)

		return _aArResult_

		# Returns the parts of the list that lie outside the given ranges, the same as AntiRanges.
		#
		#   paRanges   a list of [ start, length ] pairs
		#   returns    nothing today: it raises error R19
		#   note       the alias calls AntiRanges without the ranges it was given
		#   warning    Raises error R19 "Calling function with less number of parameters" today
		#              instead of the parts outside the ranges; use AntiRanges
		#   see        AntiRanges
		def RangesOtherThan(paRanges)
			return This.AntiRanges()

		def AntiRangesQ(paRanges)
			return new stzList( This.AntiRanges(paRanges) )

	# Returns the whole list cut into the given ranges and the parts between them, in list order.
	#
	#   paRanges   a list of [ start, length ] pairs
	#   returns    a list of lists
	#   note       RangesAndAntiRanges([ [2,2] ]) on a to g gives a, then b c, then d to g
	#   see        AntiRanges, Ranges
	def RangesAndAntiRanges(paRanges)
		_aRarSections_ = RangesToSections(paRanges)
		_aRarResult_ = @oList.SectionsAndAntiSections(_aRarSections_)
		return _aRarResult_

		def RangesAndAntiRangesQ(paRanges)
			return new stzList( This.RangesAndAntiRanges(paRanges) )

		def AllRangesIncluding(paRanges)
			return This.RangesAndAntiRanges(paRanges)

	  #---------------------------------------------------------------------------#
	 #   GETTING THE ANTI-RANGES -- INCLUDING BOUNDS                              #
	#---------------------------------------------------------------------------#

	def AntiRangesIB(paRanges)
		_aAribSections_ = RangesToSections(paRanges)
		_aAribResult_ = @oList.AntiSectionsIB(_aAribSections_)

		return _aAribResult_

		def RangesOtherThanIB(paRanges)
			return This.AntiRangesIB()

		def AntiRangesIBQ(paRanges)
			return new stzList( This.AntiRangesIB(paRanges) )

	def RangesAndAntiRangesIB(paRanges)
		_aRaribSections_ = RangesToSections(paRanges)
		_aRaribResult_ = @oList.SectionsAndAntiSectionsIB(_aRaribSections_)
		return _aRaribResult_

		def RangesAndAntiRangesIBQ(paRanges)
			return new stzList( This.RangesAndAntiRangesIB(paRanges) )

		def AllRangesIncludingIB(paRanges)
			return This.RangesAndAntiRangesIB(paRanges)
