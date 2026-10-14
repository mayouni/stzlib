#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSPLITS              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List splits subclass -- split operations.   #
#                  Engine-backed via stz_list_split_* C ABI.   #
#                  For aliases, use stzListSplitsXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Cuts a list into parts: at an item, at positions, before or after one, into n parts, into parts of n items, by a condition or at a pace.
#
# It is the cutting helper of stzList, which builds one over itself for its Split, SplitXT,
# SplittedXT, SplittedAsSectionsXT and SplittedAtPositions methods; build one with new stzListSplits
# when you only need to cut. It works on its own copy, so a stzList passed in is never changed. The
# answer is a list of parts, each part a list. Unlike the split of a text, a cut item is not thrown
# away: it is kept and starts the next part, and a cut at position 1 or past the end adds no empty
# part. A verb (Split, SplitAt, SplitBefore ...) cuts the held list in place and returns nothing, so
# read Content afterwards, its Q form returning the splitter for chaining; the Splitted forms return
# the parts and leave the splitter alone. SplitXT and SplittedXT take the options in one argument (a
# position, a list of positions, or a pair such as [ :After, 3 ] or [ :ToNParts, 3 ]), and
# SplittedAsSectionsXT answers the [ first, last ] positions of the parts. A number is always read
# as a position, never as an item, so a list of numbers cannot be cut at one of its items.
# SplitAfter with an item cuts only after its last occurrence. A pace of 0 in SplitAtPacer never
# ends.
#
#   receiver   o1 = new stzListSplits([ "a", "b", "-", "c", "d", "-", "e" ])
#   example    ? @@( o1.SplittedAt("-") )
#              #--> [ [ "a", "b" ], [ "-", "c", "d" ], [ "-", "e" ] ]
#              ? @@( o1.SplittedAfterPosition(3) )
#              #--> [ [ "a", "b", "-" ], [ "c", "d", "-", "e" ] ]
#              o2 = new stzListSplits([ 1, 2, 3, 4, 5, 6, 7 ])
#              ? @@( o2.SplittedToNParts(3) )
#              #--> [ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7 ] ]
#              ? @@( o2.SplittedToPartsOfNItems(3) )
#              #--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7 ] ]
#              ? @@( o2.SplittedW("@item % 3 = 0") )
#              #--> [ [ 1, 2 ], [ 3, 4, 5 ], [ 6, 7 ] ]
#              o2.SplitAtPositions([ 3, 6 ])
#              ? @@( o2.Content() )
#              #--> [ [ 1, 2 ], [ 3, 4, 5 ], [ 6, 7 ] ]
#              o3 = new stzListSplits([ "שלום", "x", "😀", "x", "y" ])
#              ? @@( o3.SplittedAt("x") )
#              #--> [ [ "שלום" ], [ "x", "😀" ], [ "x", "y" ] ]
#   see        stzList, stzListMerger, stzListGetter
class stzListSplits from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a splitter over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to cut, or a stzList whose content is copied, any other value raises
	#                an error
	#   returns      nothing; the object is built
	#   note         the splitter works on its own copy and never changes the list or the stzList
	#                you passed in
	#   see          Content, SplittedAt
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListSplits! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list as it stands now, which is a list of parts after an in-place split.
	#
	#   returns    a list
	#   see        NumberOfItems, SplittedAt
	def Content()
		return @oList.Content()

	# Returns how many items the list holds.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfItems, Content
	def IsEmpty()
		return @oList.IsEmpty()

	  #========================================#
	 #    SPLITTING : THE GENERIC FUNCTION    #
	#========================================#

	def SplitCS(pItemOrPos, pCaseSensitive)

		if isList(pItemOrPos)

			if len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and
			   ( pItemOrPos[1] = :At or
			     pItemOrPos[1] = :AtPosition )

				return This.SplitAtCS(pItemOrPos[2], pCaseSensitive)
			ok

			if len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and
			   ( pItemOrPos[1] = :Before or
			     pItemOrPos[1] = :BeforePosition )

				return This.SplitBeforeCS(pItemOrPos[2], pCaseSensitive)
			ok

			if len(pItemOrPos) = 2 and isString(pItemOrPos[1]) and
			   ( pItemOrPos[1] = :After or
			     pItemOrPos[1] = :AfterPosition )

				return This.SplitAfterCS(pItemOrPos[2], pCaseSensitive)
			ok

		ok

		return This.SplitAtCS(pItemOrPos, pCaseSensitive)

	# Cuts the list into parts at an item or a position, in place, so the content becomes a list of parts.
	#
	#   pItemOrPos   an item to cut at, a position, or a pair such as [ :After, 3 ] or [ :Before, 3
	#                ]
	#   returns      nothing; the content changes. SplitQ returns the splitter for chaining
	#   note         the cut item starts the next part and is kept, and an item that is absent
	#                leaves one part holding everything
	#   warning      a number is always read as a position, never as an item: Split(30) on 10 20 30
	#                40 50 cuts nothing and answers one part, even though 30 is an item; the call
	#                changes the content and returns an empty text, so print Content afterwards; a
	#                second call on the cut list works on its parts and wraps them again
	#   see          SplitAt, SplitBefore, SplitAfter, SplittedAt
	#@ aka  -- WITHOUT CASESENSITIVITY
	def Split(pItemOrPos)
		return This.SplitCS(pItemOrPos, 1)

		def SplitQ(pItemOrPos)
			This.Split(pItemOrPos)
			return This

	  #=====================================================#
	 #  SPLITTING AT POSITIONS -- THE FOUNDATIONAL METHOD  #
	#=====================================================#

	# Cuts the list so that a new part starts at each given position, in place.
	#
	#   panPos     the positions where a new part starts, each from 1
	#   returns    nothing; the content changes. SplitAtPositionsQ returns the splitter for chaining
	#   note       position 1 and positions past the end are ignored, and positions given in any
	#              order or twice are cut once, so [ 4, 2 ] on 1 to 5 gives the parts [ 1 ], [ 2, 3
	#              ] and [ 4, 5 ]; an empty list of positions gives one part
	#   see        SplittedAtPositions, SplitAtPosition
	def SplitAtPositions(panPos)
		# Engine-backed: marshal list + positions, call split_at
		# INDEX_BASE=1: convert 1-based positions to 0-based for engine
		_aSapAdj_ = []
		_nPanPosLen_2 = len(panPos)
		for _iSap_ = 1 to _nPanPosLen_2
			_aSapAdj_ + (panPos[_iSap_] - 1)
		next

		_pSapList_ = StzEngineMarshalList(@oList.Content())
		_pSapPos_ = StzEngineMarshalList(_aSapAdj_)
		_pSapResult_ = StzEngineListSplitAt(_pSapList_, _pSapPos_)
		_aSapResult_ = StzEngineListContentToRingList(_pSapResult_)
		StzEngineListFree(_pSapResult_)
		StzEngineListFree(_pSapPos_)
		StzEngineListFree(_pSapList_)

		@oList.UpdateWith(_aSapResult_)

		def SplitAtPositionsQ(panPos)
			This.SplitAtPositions(panPos)
			return This

		# Cuts the list so that a new part starts at each given position, in place.
		#
		#   panPos     the positions where a new part starts, each from 1
		#   returns    nothing; the content changes
		#   note       the same call as SplitAtPositions
		#   see        SplitAtPositions, SplittedAtPositions
		def SplitAtThesePositions(panPos)
			This.SplitAtPositions(panPos)

			def SplitAtThesePositionsQ(panPos)
				This.SplitAtThesePositions(panPos)
				return This

	# Returns the list cut into parts, a new part starting at each given position, leaving the splitter as it was.
	#
	#   panPos     the positions where a new part starts, each from 1
	#   returns    a list of lists
	#   note       position 1 and positions past the end are ignored; [ 3, 6 ] on a b - c d - e
	#              gives the parts [ a, b ], [ -, c, d ] and [ -, e ]
	#   see        SplitAtPositions, SplittedAt
	def SplittedAtPositions(panPos)
		# INDEX_BASE=1: convert to 0-based for engine
		_aSadAdj_ = []
		_nPanPosLen_ = len(panPos)
		for _iSad_ = 1 to _nPanPosLen_
			_aSadAdj_ + (panPos[_iSad_] - 1)
		next

		_pSadList_ = StzEngineMarshalList(@oList.Content())
		_pSadPos_ = StzEngineMarshalList(_aSadAdj_)
		_pSadResult_ = StzEngineListSplitAt(_pSadList_, _pSadPos_)
		_aSadResult_ = StzEngineListContentToRingList(_pSadResult_)
		StzEngineListFree(_pSadResult_)
		StzEngineListFree(_pSadPos_)
		StzEngineListFree(_pSadList_)

		return _aSadResult_

		def SplittedAtThesePositions(panPos)
			return This.SplittedAtPositions(panPos)

	  #======================================#
	 #  SPLITTING BEFORE A GIVEN POSITION   #
	#======================================#

	# Cuts the list in two just before a position, in place.
	#
	#   _n_        the position that starts the second part, from 1
	#   returns    nothing; the content changes. SplitBeforePositionQ returns the splitter for
	#              chaining
	#   note       a position below 2 or past the end leaves one part
	#   see        SplittedBeforePosition, SplitAfterPosition
	def SplitBeforePosition(_n_)
		# Engine-backed: stz_list_split_before
		_pSbpList_ = StzEngineMarshalList(@oList.Content())
		_pSbpResult_ = StzEngineListSplitBefore(_pSbpList_, _n_)
		_aSbpResult_ = StzEngineListContentToRingList(_pSbpResult_)
		StzEngineListFree(_pSbpResult_)
		StzEngineListFree(_pSbpList_)

		@oList.UpdateWith(_aSbpResult_)

		def SplitBeforePositionQ(_n_)
			This.SplitBeforePosition(_n_)
			return This

	# Returns the list cut in two just before a position, leaving the splitter as it was.
	#
	#   _n_        the position that starts the second part, from 1
	#   returns    a list of two lists
	#   note       a position below 2 or past the end gives one part
	#   see        SplitBeforePosition, SplittedAfterPosition
	def SplittedBeforePosition(_n_)
		_pSbdList_ = StzEngineMarshalList(@oList.Content())
		_pSbdResult_ = StzEngineListSplitBefore(_pSbdList_, _n_)
		_aSbdResult_ = StzEngineListContentToRingList(_pSbdResult_)
		StzEngineListFree(_pSbdResult_)
		StzEngineListFree(_pSbdList_)

		return _aSbdResult_

	  #===================================#
	 #  SPLITTING BEFORE A GIVEN ITEM    #
	#===================================#

	def SplitBeforeCS(pItem, pCaseSensitive)
		if isNumber(pItem)
			This.SplitBeforePosition(pItem)
		else
			_anSbcPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
			if len(_anSbcPos_) > 0
				This.SplitAtPositions(_anSbcPos_)
			ok
		ok

		def SplitBeforeCSQ(pItem, pCaseSensitive)
			This.SplitBeforeCS(pItem, pCaseSensitive)
			return This

	# Cuts the list just before each occurrence of an item, in place, keeping the item at the start of its part.
	#
	#   pItem      the item to cut before
	#   returns    nothing; the content changes. SplitBeforeQ returns the splitter for chaining
	#   note       an absent item leaves the list flat, as it was, where SplitAt wraps it as one
	#              part; SplitBeforeCS(pItem, 0) ignores case
	#   see        SplitAfter, SplitAt, SplitBeforePosition
	def SplitBefore(pItem)
		return This.SplitBeforeCS(pItem, 1)

		def SplitBeforeQ(pItem)
			This.SplitBefore(pItem)
			return This

	  #=====================================#
	 #  SPLITTING AFTER A GIVEN POSITION   #
	#=====================================#

	# Cuts the list in two just after a position, in place.
	#
	#   _n_        the position that ends the first part, from 1
	#   returns    nothing; the content changes. SplitAfterPositionQ returns the splitter for
	#              chaining
	#   note       a position at or past the last item leaves one part
	#   see        SplittedAfterPosition, SplitBeforePosition
	def SplitAfterPosition(_n_)
		# Engine-backed: stz_list_split_after
		_pSfpList_ = StzEngineMarshalList(@oList.Content())
		_pSfpResult_ = StzEngineListSplitAfter(_pSfpList_, _n_)
		_aSfpResult_ = StzEngineListContentToRingList(_pSfpResult_)
		StzEngineListFree(_pSfpResult_)
		StzEngineListFree(_pSfpList_)

		@oList.UpdateWith(_aSfpResult_)

		def SplitAfterPositionQ(_n_)
			This.SplitAfterPosition(_n_)
			return This

	# Returns the list cut in two just after a position, leaving the splitter as it was.
	#
	#   _n_        the position that ends the first part, from 1
	#   returns    a list of two lists
	#   note       a position at or past the last item gives one part
	#   see        SplitAfterPosition, SplittedBeforePosition
	def SplittedAfterPosition(_n_)
		_pSfdList_ = StzEngineMarshalList(@oList.Content())
		_pSfdResult_ = StzEngineListSplitAfter(_pSfdList_, _n_)
		_aSfdResult_ = StzEngineListContentToRingList(_pSfdResult_)
		StzEngineListFree(_pSfdResult_)
		StzEngineListFree(_pSfdList_)

		return _aSfdResult_

	  #=================================#
	 #  SPLITTING AFTER A GIVEN ITEM   #
	#=================================#

	def SplitAfterCS(pItem, pCaseSensitive)
		if isNumber(pItem)
			This.SplitAfterPosition(pItem)
		else
			_anSacPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
			if len(_anSacPos_) > 0
				# Split after the last occurrence found
				This.SplitAfterPosition(_anSacPos_[len(_anSacPos_)])
			ok
		ok

		def SplitAfterCSQ(pItem, pCaseSensitive)
			This.SplitAfterCS(pItem, pCaseSensitive)
			return This

	# Cuts the list just after the LAST occurrence of an item, in place, so it makes two parts at most.
	#
	#   pItem      the item to cut after
	#   returns    nothing; the content changes. SplitAfterQ returns the splitter for chaining
	#   note       unlike SplitBefore it does not cut at every occurrence: a b - c d - e cut after -
	#              gives the parts [ a, b, -, c, d, - ] and [ e ]; SplitAfterCS(pItem, 0) ignores
	#              case; an absent item leaves the list as it was
	#   see        SplitBefore, SplitAfterPosition
	def SplitAfter(pItem)
		return This.SplitAfterCS(pItem, 1)

		def SplitAfterQ(pItem)
			This.SplitAfter(pItem)
			return This

	  #==================================#
	 #  SPLITTING AT A GIVEN POSITION   #
	#==================================#

	# Cuts the list in two just before a position, in place.
	#
	#   _n_        the position that starts the second part, from 1
	#   returns    nothing; the content changes. SplitAtPositionQ returns the splitter for chaining
	#   note       the same cut as SplitBeforePosition
	#   see        SplitBeforePosition, SplitAtPositions
	def SplitAtPosition(_n_)
		# "Split at position N" = split before position N
		This.SplitBeforePosition(_n_)

		def SplitAtPositionQ(_n_)
			This.SplitAtPosition(_n_)
			return This

	def SplittedAtPosition(_n_)
		return This.SplittedBeforePosition(_n_)

	  #================================#
	 #  SPLITTING AT A GIVEN ITEM     #
	#================================#

	def SplitAtCS(pItem, pCaseSensitive)
		if isNumber(pItem)
			This.SplitAtPosition(pItem)
		else
			_anSatPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
			This.SplitAtPositions(_anSatPos_)
		ok

		def SplitAtCSQ(pItem, pCaseSensitive)
			This.SplitAtCS(pItem, pCaseSensitive)
			return This

	# Cuts the list at each occurrence of an item, in place, so the item starts a new part and is kept.
	#
	#   pItem      the item to cut at
	#   returns    nothing; the content changes. SplitAtQ returns the splitter for chaining
	#   note       a b - c d - e cut at - gives the parts [ a, b ], [ -, c, d ] and [ -, e ]; an
	#              absent item gives one part holding everything, where SplitBefore leaves the list
	#              flat; SplitAtCS(pItem, 0) ignores case
	#   see        SplittedAt, SplitBefore, SplitAfter
	def SplitAt(pItem)
		return This.SplitAtCS(pItem, 1)

		def SplitAtQ(pItem)
			This.SplitAt(pItem)
			return This

	def SplittedAtCS(pItem, pCaseSensitive)
		if isNumber(pItem)
			return This.SplittedAtPosition(pItem)
		ok
		_anSadcPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		return This.SplittedAtPositions(_anSadcPos_)

	# Returns the list cut at each occurrence of an item, leaving the splitter as it was.
	#
	#   pItem      the item to cut at
	#   returns    a list of lists
	#   note       the item starts the next part and is kept; SplittedAtCS(pItem, 0) ignores case,
	#              so X and x both cut
	#   see        SplitAt, SplittedAtPositions
	def SplittedAt(pItem)
		return This.SplittedAtCS(pItem, 1)

	  #==============================#
	 #  SPLITTING TO N EQUAL PARTS  #
	#==============================#

	# Cuts the list into n consecutive parts of nearly equal size, in place.
	#
	#   _n_        how many parts to make
	#   returns    nothing; the content changes. SplitToNPartsQ returns the splitter for chaining
	#   note       7 items in 3 parts give 3, 2 and 2 items, the extra items going to the first
	#              parts; an n larger than the count gives one part per item, and 0 gives [ ]
	#   see        SplittedToNParts, SplitToPartsOfNItems
	def SplitToNParts(_n_)
		# Mutator form: divide into n parts (see SplittedToNParts).
		@oList.UpdateWith( This.SplittedToNParts(_n_) )

		def SplitToNPartsQ(_n_)
			This.SplitToNParts(_n_)
			return This

	# Returns the list cut into n consecutive parts of nearly equal size, leaving the splitter as it was.
	#
	#   _n_        how many parts to make
	#   returns    a list of lists
	#   note       7 items in 3 parts give 3, 2 and 2 items; an n larger than the count gives one
	#              part per item, and 0 or an empty list gives [ ]
	#   see        SplitToNParts, SplittedToPartsOfNItems
	def SplittedToNParts(_n_)
		# Divide the list into n parts of as-equal-as-possible size: the
		# documented "/ n -> n parts" contract ([1..6] -> [[1,2],[3,4],[5,6]],
		# 3 items / 3 -> [[a],[b],[c]]). The remainder is front-loaded -- the
		# first (len mod n) parts get one extra item (numpy array_split
		# convention). This is distinct from SplittedToPartsOfNItems, which
		# chunks by a fixed SIZE. The old ceil-chunk approximation produced
		# the wrong count when n was close to len (e.g. 7 items / 5).
		_nSndLen_ = This.NumberOfItems()
		if _n_ <= 0 or _nSndLen_ = 0
			return []
		ok
		_n_ = floor(_n_)
		_aSrc_ = @oList.Content()
		_aSndResult_ = []
		_nBase_ = floor(_nSndLen_ / _n_)
		_nRem_ = _nSndLen_ % _n_
		_iCur_ = 1
		for _iSp_ = 1 to _n_
			_nSz_ = _nBase_
			if _iSp_ <= _nRem_
				_nSz_ = _nSz_ + 1
			ok
			if _nSz_ = 0
				loop
			ok
			_aPart_ = []
			_iEnd_ = _iCur_ + _nSz_ - 1
			for _jSp_ = _iCur_ to _iEnd_
				_aPart_ + _aSrc_[_jSp_]
			next
			_aSndResult_ + _aPart_
			_iCur_ = _iEnd_ + 1
		next

		return _aSndResult_

	  #=================================#
	 #  SPLITTING TO PARTS OF N ITEMS  #
	#=================================#

	# Cuts the list into consecutive parts of n items each, the last one possibly shorter, in place.
	#
	#   _n_        how many items each part holds
	#   returns    nothing; the content changes. SplitToPartsOfNItemsQ returns the splitter for
	#              chaining
	#   note       7 items in parts of 3 give 3, 3 and 1 items; 0 gives [ ]
	#   see        SplittedToPartsOfNItems, SplitToNParts
	def SplitToPartsOfNItems(_n_)
		# Engine-backed: stz_list_split_to_parts_of_n
		_pSpnList_ = StzEngineMarshalList(@oList.Content())
		_pSpnResult_ = StzEngineListSplitToPartsOfN(_pSpnList_, _n_)
		_aSpnResult_ = StzEngineListContentToRingList(_pSpnResult_)
		StzEngineListFree(_pSpnResult_)
		StzEngineListFree(_pSpnList_)

		@oList.UpdateWith(_aSpnResult_)

		def SplitToPartsOfNItemsQ(_n_)
			This.SplitToPartsOfNItems(_n_)
			return This

		# Cuts the list into consecutive parts of n items each, the last one possibly shorter, in place.
		#
		#   _n_        how many items each part holds
		#   returns    nothing; the content changes
		#   note       the same call as SplitToPartsOfNItems
		#   see        SplitToPartsOfNItems, SplittedToPartsOfNItems
		def SplitToPartsOf(_n_)
			This.SplitToPartsOfNItems(_n_)

			def SplitToPartsOfQ(_n_)
				This.SplitToPartsOf(_n_)
				return This

	# Returns the list cut into consecutive parts of n items each, leaving the splitter as it was.
	#
	#   _n_        how many items each part holds
	#   returns    a list of lists
	#   note       7 items in parts of 3 give 3, 3 and 1 items; 0 gives [ ]; SplittedToPartsOf is
	#              the same call
	#   see        SplitToPartsOfNItems, SplittedToNParts
	def SplittedToPartsOfNItems(_n_)
		_pSpdList_ = StzEngineMarshalList(@oList.Content())
		_pSpdResult_ = StzEngineListSplitToPartsOfN(_pSpdList_, _n_)
		_aSpdResult_ = StzEngineListContentToRingList(_pSpdResult_)
		StzEngineListFree(_pSpdResult_)
		StzEngineListFree(_pSpdList_)

		return _aSpdResult_

		def SplittedToPartsOf(_n_)
			return This.SplittedToPartsOfNItems(_n_)

	  #===============================#
	 #  SPLITTING USING A CONDITION  #
	#===============================#

	def SplitW(pcCondition)
		_anSwPos_ = @oList.FindW(pcCondition)
		This.SplitAtPositions(_anSwPos_)

		def SplitWQ(pcCondition)
			This.SplitW(pcCondition)
			return This

	# Returns the list cut just before each item that satisfies a condition, leaving the splitter as it was.
	#
	#   pcCondition   the test, written with @item for the current item, such as "@item % 3 = 0"
	#   returns       a list of lists
	#   note          the item that satisfies the test starts the next part and is kept; 1 to 7 with
	#                 "@item % 3 = 0" gives the parts [ 1, 2 ], [ 3, 4, 5 ] and [ 6, 7 ]; SplitW
	#                 cuts in place
	#   see           SplittedAt, SplittedAtPositions
	def SplittedW(pcCondition)
		_anSwdPos_ = @oList.FindW(pcCondition)
		return This.SplittedAtPositions(_anSwdPos_)

	# SplitW / SplittedW -- narrative-test aliases over the W form.



	# SplitAtW(pcCondition) -- split AT the positions where the
	# predicate is true (i.e. the matching elements become break
	# points). Same semantics as SplitW; aliased here for the
	# "SplitAt+W" spelling.
	def SplitAtW(pcCondition)
		This.SplitW(pcCondition)

		def SplitAtWQ(pcCondition)
			This.SplitAtW(pcCondition)
			return This

	  #===================================#
	 #  SPLITTING USING A GIVEN PACER    #
	#===================================#

	# Cuts the list at a start position and then every given number of positions after it, in place.
	#
	#   nPace      the distance between two cuts
	#   nStart     the first position where a part starts
	#   returns    nothing; the content changes. SplitAtPacerQ returns the splitter for chaining
	#   note       1 to 7 with pace 3 from 3 gives the parts [ 1, 2 ], [ 3, 4, 5 ] and [ 6, 7 ]
	#   warning    a pace of 0 never ends: the code adds positions in a loop that does not advance
	#              (read from the code, not run, since it would fill the memory)
	#   see        SplittedAtPacer, SplitAtPositions
	def SplitAtPacer(nPace, nStart)
		# Generate positions at the given pace
		_anPcrPos_ = []
		_nPcrLen_ = This.NumberOfItems()
		_iPcr_ = nStart
		while _iPcr_ <= _nPcrLen_
			_anPcrPos_ + _iPcr_
			_iPcr_ = _iPcr_ + nPace
		end

		This.SplitAtPositions(_anPcrPos_)

		def SplitAtPacerQ(nPace, nStart)
			This.SplitAtPacer(nPace, nStart)
			return This

	# Returns the list cut at a start position and then every given number of positions after it, leaving the splitter as it was.
	#
	#   nPace      the distance between two cuts
	#   nStart     the first position where a part starts
	#   returns    a list of lists
	#   note       1 to 7 with pace 2 from 2 gives the parts [ 1 ], [ 2, 3 ], [ 4, 5 ] and [ 6, 7 ]
	#   warning    a pace of 0 never ends, as in SplitAtPacer (read from the code, not run)
	#   see        SplitAtPacer, SplittedAtPositions
	def SplittedAtPacer(nPace, nStart)
		_anSdpcrPos_ = []
		_nSdpcrLen_ = This.NumberOfItems()
		_iSdpcr_ = nStart
		while _iSdpcr_ <= _nSdpcrLen_
			_anSdpcrPos_ + _iSdpcr_
			_iSdpcr_ = _iSdpcr_ + nPace
		end

		return This.SplittedAtPositions(_anSdpcrPos_)

	# SplitAtCSZZ(pItem, pCaseSensitive): each split-section as [start, end].
	def SplitAtCSZZ(pItem, pCaseSensitive)
		_l_ = @oList.List()
		_nL_ = len(_l_)
		_aPos_ = []
		for _i_ = 1 to _nL_
			if BothAreEqualCS(_l_[_i_], pItem, pCaseSensitive) _aPos_ + _i_ ok
		next
		_aR_ = []
		_nPL_ = len(_aPos_)
		_prev_ = 0
		for _i_ = 1 to _nPL_
			_aR_ + [ _prev_ + 1, _aPos_[_i_] - 1 ]
			_prev_ = _aPos_[_i_]
		next
		_aR_ + [ _prev_ + 1, _nL_ ]
		return _aR_

	  #=====================================================#
	 #  SPLITTING WITH OPTIONS -- THE XT FORMS             #
	#=====================================================#

	# Turns the options of an XT form into [ kind, argument ].
	#   kind  "before" : the argument lists the positions where a new part starts
	#         "after"  : the argument lists the positions after which a new part starts
	#         "at"     : the argument lists the positions where a new part starts, as "before" does
	#         "parts"  : the argument is the number of parts
	#         "size"   : the argument is the number of items in each part
	def _XTResolve(p)
		_vXrKey_ = ""
		_vXrArg_ = ""
		_bXrNamed_ = 0
		if isList(p) and len(p) = 2 and isString(p[1])
			_vXrKey_ = lower(p[1])
			_vXrArg_ = p[2]
			_bXrNamed_ = 1
		ok

		if _bXrNamed_
			_aXrNames_ = [
				[ "at", "before" ], [ "atposition", "before" ], [ "atthisposition", "before" ],
				[ "atpositions", "at" ], [ "atthesepositions", "at" ], [ "atmanypositions", "at" ],
				[ "before", "before" ], [ "beforeposition", "before" ], [ "beforethisposition", "before" ],
				[ "beforepositions", "before" ], [ "beforethesepositions", "before" ],
				[ "beforemanypositions", "before" ],
				[ "after", "after" ], [ "afterposition", "after" ], [ "afterthisposition", "after" ],
				[ "afterpositions", "after" ], [ "afterthesepositions", "after" ],
				[ "aftermanypositions", "after" ],
				[ "tonparts", "parts" ], [ "topartsofnitems", "size" ], [ "topartsofexactlynitems", "size" ]
			]
			_nXrNames_ = len(_aXrNames_)
			for _iXr_ = 1 to _nXrNames_
				if _aXrNames_[_iXr_][1] = _vXrKey_
					_cXrKind_ = _aXrNames_[_iXr_][2]
					if _cXrKind_ = "parts" or _cXrKind_ = "size"
						return [ _cXrKind_, _vXrArg_ ]
					ok
					_aXrList_ = []
					if isNumber(_vXrArg_)
						_aXrList_ + _vXrArg_
					but isList(_vXrArg_)
						_aXrList_ = _vXrArg_
					else
						return [ "at", [] ]
					ok
					return [ _cXrKind_, _aXrList_ ]
				ok
			next
		ok

		if isNumber(p)
			return [ "before", [ p ] ]
		ok

		_bXrNums_ = isList(p) and len(p) > 0
		if _bXrNums_
			_nXrP_ = len(p)
			for _iXr_ = 1 to _nXrP_
				if NOT isNumber(p[_iXr_])
					_bXrNums_ = 0
					exit
				ok
			next
		ok
		if _bXrNums_
			return [ "at", p ]
		ok

		return [ "at", @oList.FindAllCS(p, 1) ]

	# Orders positions ascending, without repeats and without those outside nMin to nMax.
	def _XTSortedPositions(panPos, nMin, nMax)
		_anXsOut_ = []
		_nXsLen_ = len(panPos)
		for _iXs_ = 1 to _nXsLen_
			_nXsPos_ = panPos[_iXs_]
			if _nXsPos_ >= nMin and _nXsPos_ <= nMax and find(_anXsOut_, _nXsPos_) = 0
				_nXsAt_ = len(_anXsOut_) + 1
				while _nXsAt_ > 1 and _anXsOut_[_nXsAt_ - 1] > _nXsPos_
					_nXsAt_ = _nXsAt_ - 1
				end
				ring_insert(_anXsOut_, _nXsAt_, _nXsPos_)
			ok
		next
		return _anXsOut_

	# Returns the parts the options cut the list into; the list is unchanged.
	#
	#   p          the split options, in the forms SplitXT takes
	#   returns    a list of lists, one per part
	#   see        SplitXT, SplittedAsSectionsXT
	def SplittedXT(p)
		_aXtPlan_ = This._XTResolve(p)
		_cXtKind_ = _aXtPlan_[1]
		_vXtArg_ = _aXtPlan_[2]
		if _cXtKind_ = "before"
			return @oList.SplittedBeforePositions(_vXtArg_)
		but _cXtKind_ = "after"
			return @oList.SplittedAfterPositions(_vXtArg_)
		but _cXtKind_ = "parts"
			return This.SplittedToNParts(_vXtArg_)
		but _cXtKind_ = "size"
			return This.SplittedToPartsOfNItems(_vXtArg_)
		ok
		return This.SplittedAtPositions(_vXtArg_)

	# Cuts the list into the parts the options give, in place.
	def SplitXT(p)
		@oList.UpdateWith( This.SplittedXT(p) )

		def SplitXTQ(p)
			This.SplitXT(p)
			return This

	# Returns the [ first, last ] position pair of each part the options give; the list is unchanged.
	#
	#   p          the split options, in the forms SplitXT takes
	#   returns    a list of [ first, last ] pairs
	#   see        SplittedXT, SplitAsSectionsXT
	def SplittedAsSectionsXT(p)
		_aSxPlan_ = This._XTResolve(p)
		_cSxKind_ = _aSxPlan_[1]
		_vSxArg_ = _aSxPlan_[2]
		_nSxLen_ = This.NumberOfItems()
		_aSxOut_ = []

		if _cSxKind_ = "parts" or _cSxKind_ = "size"
			_aSxParts_ = This.SplittedXT(p)
			_nSxParts_ = len(_aSxParts_)
			_nSxFrom_ = 1
			for _iSx_ = 1 to _nSxParts_
				_nSxTo_ = _nSxFrom_ + len(_aSxParts_[_iSx_]) - 1
				_aSxOut_ + [ _nSxFrom_, _nSxTo_ ]
				_nSxFrom_ = _nSxTo_ + 1
			next
			return _aSxOut_
		ok

		# "before" and "at" (the engine cuts before the position, keeping its item) and "after":
		# a part starts at each position, or just past it
		_anSxStarts_ = []
		_nSxArg_ = len(_vSxArg_)
		for _iSx_ = 1 to _nSxArg_
			if _cSxKind_ = "after"
				_anSxStarts_ + (_vSxArg_[_iSx_] + 1)
			else
				_anSxStarts_ + _vSxArg_[_iSx_]
			ok
		next
		_anSxStarts_ = This._XTSortedPositions(_anSxStarts_, 2, _nSxLen_)
		_nSxStarts_ = len(_anSxStarts_)
		_nSxFrom_ = 1
		for _iSx_ = 1 to _nSxStarts_
			_aSxOut_ + [ _nSxFrom_, _anSxStarts_[_iSx_] - 1 ]
			_nSxFrom_ = _anSxStarts_[_iSx_]
		next
		if _nSxLen_ > 0
			_aSxOut_ + [ _nSxFrom_, _nSxLen_ ]
		ok
		return _aSxOut_

	# Returns the [ first, last ] position pair of each part the options give; the list is unchanged.
	def SplitAsSectionsXT(p)
		return This.SplittedAsSectionsXT(p)
