#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTBOUNDER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List bounder subclass -- sections, slices,  #
#                  bounds checking, bounded-by operations.      #
#                  For aliases, use stzListBounderXT.           #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Answers questions about the ends of a list: its bounds, its middle, a section or range of it, and whether positions and values stay within limits.
#
# It is the bounds helper of stzList, which builds one over itself for its SectionXT, IsBoundedByCS,
# Bounds, BoundsUpToNItems and RemoveBoundsCS methods; build one with new stzListBounder when you
# only need the ends. It works on its own copy, so a stzList passed in is never changed, and you
# read the result of an in-place verb (RemoveBounds, ClampTo) with Content. Bounds are the first and
# last items: IsBoundedBy compares them with a pair [ open, close ], and BoundsRemoved returns the
# list without them when they match. Positions count from 1. Section raises when a position falls
# outside the list, where stzListGetter.Section clips; NFirstItems and NLastItems clip to the list.
# AreBoundsOf raises error R14 today, because the stzString method it calls does not exist. Hebrew,
# Arabic and emoji items work as bounds like any other value.
#
#   receiver   o1 = new stzListBounder([ "<", "a", "b", "c", ">" ])
#   example    ? @@( o1.Bounds() )
#              #--> [ "<", ">" ]
#              ? o1.IsBoundedBy([ "<", ">" ])
#              #--> 1
#              ? @@( o1.Middle() )
#              #--> [ "a", "b", "c" ]
#              ? @@( o1.BoundsRemoved([ "<", ">" ]) )
#              #--> [ "a", "b", "c" ]
#              ? @@( o1.Section(2, 4) )
#              #--> [ "a", "b", "c" ]
#              ? @@( o1.BoundsUpToNItems(2) )
#              #--> [ [ "<", "a" ], [ "c", ">" ] ]
#              o2 = new stzListBounder([ "«", "שלום", "»" ])
#              ? o2.IsBoundedBy([ "«", "»" ])
#              #--> 1
#   see        stzList, stzListGetter, stzListExtractor
class stzListBounder from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a bounder over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to inspect, or a stzList whose content is copied, any other value
	#                raises an error
	#   returns      nothing; the object is built
	#   note         the bounder works on its own copy: removing bounds never changes the list or
	#                the stzList you passed in, so read the result with Content
	#   see          Content, Bounds
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListBounder! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list as it stands now, after the bounds removed so far.
	#
	#   returns    a list
	#   see        NumberOfItems, BoundsRemoved
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

	  #==========================================#
	 #  GETTING A SECTION (SLICE) OF THE LIST   #
	#==========================================#

	def SectionCS(_n1_, _n2_, pCaseSensitive)

		_aScContent_ = This.Content()
		_nScLen_ = len(_aScContent_)

		if CheckingParams()

			if isList(_n1_) and IsFromNamedParamList(_n1_)
				_n1_ = _n1_[2]
			ok

			if isList(_n2_) and IsToNamedParamList(_n2_)
				_n2_ = _n2_[2]
			ok

			if isString(_n1_)
				if StzFindFirst(_n1_, [ :First, :FirstItem ]) > 0
					_n1_ = 1
				but StzFindFirst(_n1_, [ :Last, :LastItem ]) > 0
					_n1_ = _nScLen_
				ok
			ok

			if isString(_n2_)
				if StzFindFirst(_n2_, [ :End, :Last, :LastItem, :EndOfList ]) > 0
					_n2_ = _nScLen_
				but StzFindFirst(_n2_, [ :First, :FirstItem ]) > 0
					_n2_ = 1
				ok
			ok

			if NOT (isNumber(_n1_) and isNumber(_n2_))
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		if NOT ( ( _n1_ >= 1 and _n1_ <= _nScLen_ ) and
			 ( _n2_ >= 1 and _n2_ <= _nScLen_ ) )

			StzRaise("Indexes out of range! n1 and n2 must be inside the list.")
		ok

		if _n2_ < _n1_
			_nScTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nScTemp_
		ok

		# Engine fast path
		_pBsList_ = @oList._EngineListFromContent()
		if _pBsList_ != ""
			_pBsResult_ = StzEngineListSection(_pBsList_, _n1_, _n2_)
			StzEngineListFree(_pBsList_)
			if _pBsResult_ != ""
				_aBsResult_ = @oList._ContentFromEngineList(_pBsResult_)
				StzEngineListFree(_pBsResult_)
				return _aBsResult_
			ok
		ok

		_aScFallback_ = []
		for _iSc_ = _n1_ to _n2_
			@AddItem(_aScFallback_, _aScContent_[_iSc_])
		next

		return _aScFallback_

		def SectionCSQ(_n1_, _n2_, pCaseSensitive)
			return new stzList( This.SectionCS(_n1_, _n2_, pCaseSensitive) )

	# Returns the items from one position to another, both included.
	#
	#   _n1_       the first position, or a pair such as [ :From, 2 ] or the word :First
	#   _n2_       the last position, or a pair such as [ :To, 3 ] or the word :Last
	#   returns    a list
	#   note       a start larger than the end is swapped with it, so Section(4, 2) answers the same
	#              as Section(2, 4); SectionCS, SectionXT and the Q forms also exist, SectionXT
	#              counting a negative position back from the end
	#   warning    a position outside the list raises Indexes out of range! n1 and n2 must be inside
	#              the list, where the same call of stzListGetter clips to the list
	#   see        Range, Sections, NFirstItems
	def Section(_n1_, _n2_)
		return This.SectionCS(_n1_, _n2_, 1)

		def SectionQ(_n1_, _n2_)
			return new stzList(This.Section(_n1_, _n2_))

	  #-------------------------------------------------#
	 #  GETTING A SECTION -- XT (inverted = reversed)  #
	#-------------------------------------------------#

	def SectionXT(_n1_, _n2_)
		_aSxContent_ = This.Content()
		_nSxLen_ = len(_aSxContent_)

		# XT: a negative endpoint counts back from the end (-1 = last item).
		if _n1_ < 0
			_n1_ = _nSxLen_ + _n1_ + 1
		ok
		if _n2_ < 0
			_n2_ = _nSxLen_ + _n2_ + 1
		ok

		if _n1_ < 1 or _n1_ > _nSxLen_ or _n2_ < 1 or _n2_ > _nSxLen_
			StzRaise("Indexes out of range!")
		ok

		_aSxResult_ = []

		if _n1_ <= _n2_
			for _iSx_ = _n1_ to _n2_
				@AddItem(_aSxResult_, _aSxContent_[_iSx_])
			next
		else
			for _jSx_ = _n1_ to _n2_ step -1
				@AddItem(_aSxResult_, _aSxContent_[_jSx_])
			next
		ok

		return _aSxResult_

		def SectionXTQ(_n1_, _n2_)
			return new stzList(This.SectionXT(_n1_, _n2_))

	  #===========================================#
	 #  GETTING MANY SECTIONS                   #
	#===========================================#

	# Returns several sections of the list in one call, one list of items per section.
	#
	#   paSections   the sections to read, each [ first, last ]
	#   returns      a list of lists
	#   note         ManySections is the same call; SectionsQ returns a stzList
	#   warning      a section outside the list raises the error of Section
	#   see          Section
	def Sections(paSections)
		_nSsLen_ = len(paSections)
		_aSsResult_ = []

		for _iSs_ = 1 to _nSsLen_
			_aSsSection_ = paSections[_iSs_]
			_aSsItems_ = This.Section(_aSsSection_[1], _aSsSection_[2])
			@AddItem(_aSsResult_, _aSsItems_)
		next

		return _aSsResult_

		def SectionsQ(paSections)
			return new stzList(This.Sections(paSections))

		def ManySections(paSections)
			return This.Sections(paSections)

	  #===========================================================#
	 #  CHECKING IF THE 2 ITEMS ARE BOUNDS OF A SUBSTRING        #
	#===========================================================#

	def AreBoundsOfCS(pcSubStr, pIn, pCaseSensitive)

		if CheckingParams() = 1

			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok

			if NOT ( This.IsPair() or This.IsListOfPairs() )
				StzRaise("Can't check bounds! List must be a pair or a list of pairs.")
			ok

			if isList(pIn) and IsInNamedParamList(pIn)
				pIn = pIn[2]
			ok

			if NOT isString(pIn)
				StzRaise("Incorrect param type! pIn must be a string.")
			ok

		ok

		_aAbContent_ = This.Content()
		_nAbLen_ = len(_aAbContent_)

		_oAbSubStr_ = new stzString(pcSubStr)
		_bAbResult_ = 0

		if This.IsListOfPairs()
			_bAbResult_ = 1

			for _iAb_ = 1 to _nAbLen_
				_bAbResult_ = _oAbSubStr_.IsBoundedByIn(_aAbContent_[_iAb_], pIn)
				if _bAbResult_ = 0
					exit
				ok
			next
		else
			_bAbResult_ = _oAbSubStr_.IsBoundedByIn(_aAbContent_, pIn)
		ok

		return _bAbResult_

	# Raises error R14 today instead of telling whether the list's two items are the bounds of a text.
	#
	#   pIn        the text to look in
	#   returns    nothing
	#   note       the case-flag form AreBoundsOfCS raises the same error
	#   warning    it raises error R14 Calling Method without definition: isboundedbyin, because the
	#              stzString method it calls does not exist; tried on a pair of bounds, on a list of
	#              pairs and with the case flag; a list that is neither a pair nor a list of pairs
	#              raises Can't check bounds! List must be a pair or a list of pairs instead
	#   see        IsBoundedBy
	def AreBoundsOf(pItem, pIn)
		return This.AreBoundsOfCS(pItem, pIn, 1)

	  #----------------------------------------------------------#
	 #  CHECKING IF THE LIST IS BOUNDED BY THE GIVEN TWO ITEMS  #
	#----------------------------------------------------------#

	def IsBoundedByCS(paBounds, pCaseSensitive)
		# len()=2 inlined instead of IsPair(): the class inherits a 0-arg
		# IsPair method that would shadow the global func here (-> R20).
		if isList(paBounds) and len(paBounds) = 2
			_pIbItem1_ = paBounds[1]
			_pIbItem2_ = paBounds[2]
		else
			_pIbItem1_ = paBounds
			_pIbItem2_ = paBounds
		ok

		if @oList.FirstItemQ().IsEqualToCS(_pIbItem1_, pCaseSensitive) and
		   @oList.LastItemQ().IsEqualToCS(_pIbItem2_, pCaseSensitive)

			return 1
		else
			return 0
		ok

	# TRUE if the first item of the list equals the first bound and its last item equals the second.
	#
	#   paBounds   the pair of bounds [ open, close ], or one value used for both ends
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       case counts: IsBoundedByCS(paBounds, 0) ignores it; on an empty list it raises
	#              Index outside the list! instead of answering FALSE
	#   see        Bounds, RemoveBounds
	def IsBoundedBy(paBounds)
		return This.IsBoundedByCS(paBounds, 1)

	  #--------------------------------------------#
	 #  GETTING BOUNDS OF THE LIST UP TO N ITEMS  #
	#--------------------------------------------#

	# Returns the first n items and the last n items of the list, as a pair of lists.
	#
	#   _n_        how many items to take at each end
	#   returns    a pair, [ first n items, last n items ]
	#   note       with n = 1 each end is the item itself and not a list of one; an n larger than
	#              the list gives the whole list at both ends
	#   see        Bounds, NFirstItems
	def BoundsUpToNItems(_n_)
		_aBuFirst_ = This.NFirstItems(_n_)
		_aBuLast_  = This.NLastItems(_n_)

		if len(_aBuFirst_) = 1
			_aBuFirst_ = _aBuFirst_[1]
		ok

		if len(_aBuLast_) = 1
			_aBuLast_ = _aBuLast_[1]
		ok

		return [ _aBuFirst_, _aBuLast_ ]

	# Returns the first item and the last item of the list as a pair.
	#
	#   returns    a pair, [ first item, last item ]
	#   note       a list of one item answers that item twice
	#   see        BoundsUpToNItems, IsBoundedBy
	def Bounds()
		return This.BoundsUpToNItems(1)

	  #=====================================#
	 #     REMOVING BOUNDS               #
	#=====================================#

	def RemoveBoundsCS(paBounds, pCaseSensitive)
		if This.IsBoundedByCS(paBounds, pCaseSensitive)
			@oList.RemoveFirstItem()
			@oList.RemoveLastItem()
		ok

		def RemoveBoundsCSQ(paBounds, pCaseSensitive)
			This.RemoveBoundsCS(paBounds, pCaseSensitive)
			return This

	# Deletes the first and the last items if they equal the given bounds, in place.
	#
	#   paBounds   the pair of bounds [ open, close ], or one value used for both ends
	#   returns    nothing; the content changes. RemoveBoundsQ returns the bounder for chaining
	#   note       when the list is not bounded by them nothing happens and nothing is said;
	#              RemoveBoundsCS(paBounds, 0) ignores case
	#   see        BoundsRemoved, IsBoundedBy, Middle
	def RemoveBounds(paBounds)
		This.RemoveBoundsCS(paBounds, 1)

		def RemoveBoundsQ(paBounds)
			This.RemoveBounds(paBounds)
			return This

	# Returns the list without its first and last items if they equal the given bounds, leaving the bounder as it was.
	#
	#   paBounds   the pair of bounds [ open, close ], or one value used for both ends
	#   returns    a list
	#   note       the list comes back whole when it is not bounded by them
	#   see        RemoveBounds, Middle
	#@ aka  A copy of the list with the given bounds removed; the original is unchanged.
	def BoundsRemoved(paBounds)
		_oBrCopy_ = new stzListBounder(@oList.Content())
		_aBrResult_ = _oBrCopy_.RemoveBoundsQ(paBounds).Content()
		return _aBrResult_

	  #==============================#
	 #  IS PAIR / IS LIST OF PAIRS  #
	#==============================#

	# TRUE if the list holds exactly two items.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        IsListOfPairs, Bounds
	def IsPair()
		return This.NumberOfItems() = 2

	# TRUE if every item of the list is itself a list of two items.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       an empty list answers TRUE
	#   see        IsPair, Sections
	def IsListOfPairs()
		_aIlpContent_ = This.Content()
		_nIlpLen_ = len(_aIlpContent_)

		for _iIlp_ = 1 to _nIlpLen_
			if NOT (isList(_aIlpContent_[_iIlp_]) and len(_aIlpContent_[_iIlp_]) = 2)
				return 0
			ok
		next

		return 1

	  #=======================================#
	 #     GETTING THE MIDDLE OF THE LIST    #
	#=======================================#

	# Returns the items between the first and the last one.
	#
	#   returns    a list
	#   note       a list of fewer than 3 items answers [ ]; WithoutBounds is the same call
	#   see        Bounds, BoundsRemoved
	def Middle()
		_aMdContent_ = This.Content()
		_nMdLen_ = len(_aMdContent_)

		if _nMdLen_ < 3
			return []
		ok

		_aMdResult_ = []
		for _iMd_ = 2 to _nMdLen_ - 1
			@AddItem(_aMdResult_, _aMdContent_[_iMd_])
		next

		return _aMdResult_

		def WithoutBounds()
			return This.Middle()

	  #=======================================#
	 #     RANGE (START, COUNT)              #
	#=======================================#

	# Returns a run of items given its first position and how many items it holds.
	#
	#   nStart     the first position
	#   nCount     how many items to take
	#   returns    a list
	#   note       a count that runs past the end is cut at the end of the list and a count of 0
	#              gives [ ]; a start of 0 raises error R2 Array Access (Index out of range); RangeQ
	#              returns a stzList
	#   see        Section, NFirstItems
	def Range(nStart, nCount)
		_aRgContent_ = This.Content()
		_nRgLen_ = len(_aRgContent_)
		_aRgResult_ = []

		_nRgEnd_ = nStart + nCount - 1
		if _nRgEnd_ > _nRgLen_
			_nRgEnd_ = _nRgLen_
		ok

		for _iRg_ = nStart to _nRgEnd_
			@AddItem(_aRgResult_, _aRgContent_[_iRg_])
		next

		return _aRgResult_

		def RangeQ(nStart, nCount)
			return new stzList(This.Range(nStart, nCount))

	  #==========================================#
	 #     CLAMPED TO MIN/MAX VALUES            #
	#==========================================#

	# Returns the list with each number held between a minimum and a maximum, other items untouched.
	#
	#   nMin       the smallest value allowed
	#   nMax       the largest value allowed
	#   returns    a list
	#   note       texts and sublists pass through unchanged; [ 5, 12, 7 ] clamped to 6 and 10 gives
	#              [ 6, 10, 7 ]; the bounder is left as it was
	#   see        ClampTo, IsWithinBounds
	def ClampedTo(nMin, nMax)
		_aClContent_ = This.Content()
		_nClLen_ = len(_aClContent_)
		_aClResult_ = []

		for _iCl_ = 1 to _nClLen_
			if isNumber(_aClContent_[_iCl_])
				_nClN_ = _aClContent_[_iCl_]
				if _nClN_ < nMin
					_nClN_ = nMin
				ok
				if _nClN_ > nMax
					_nClN_ = nMax
				ok
				@AddItem(_aClResult_, _nClN_)
			else
				@AddItem(_aClResult_, _aClContent_[_iCl_])
			ok
		next

		return _aClResult_

	# Holds each number of the list between a minimum and a maximum, in place.
	#
	#   nMin       the smallest value allowed
	#   nMax       the largest value allowed
	#   returns    nothing; the content changes. ClampToQ returns the bounder for chaining
	#   note       texts and sublists are left as they are
	#   see        ClampedTo, IsWithinBounds
	def ClampTo(nMin, nMax)
		@oList.Update(This.ClampedTo(nMin, nMax))

		def ClampToQ(nMin, nMax)
			This.ClampTo(nMin, nMax)
			return This

	  #==========================================#
	 #     CHECK IF POSITION IS WITHIN BOUNDS   #
	#==========================================#

	# TRUE if a position falls inside the list, from 1 to the number of items.
	#
	#   _n_        the position to test
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       it tests a position and not a value, despite its name; PositionExists and
	#              HasPosition are the same call
	#   see        Section, NumberOfItems
	def IsWithinBounds(_n_)
		if _n_ >= 1 and _n_ <= This.NumberOfItems()
			return 1
		else
			return 0
		ok

		def PositionExists(_n_)
			return This.IsWithinBounds(_n_)

		def HasPosition(_n_)
			return This.IsWithinBounds(_n_)

	  #=======================================#
	 #     FIRST N AND LAST N ITEMS          #
	#=======================================#

	# Returns the first n items, in their order.
	#
	#   _n_        how many items to take from the start
	#   returns    a list
	#   note       an n larger than the list gives the whole list and 0 gives [ ], where the same
	#              call of stzListGetter raises error R2; FirstNItems and Take are the same call
	#   see        NLastItems, Section
	def NFirstItems(_n_)
		_aNfContent_ = This.Content()
		_nNfLen_ = len(_aNfContent_)
		_aNfResult_ = []

		if _n_ > _nNfLen_
			_n_ = _nNfLen_
		ok

		for _iNf_ = 1 to _n_
			@AddItem(_aNfResult_, _aNfContent_[_iNf_])
		next

		return _aNfResult_

		def FirstNItems(_n_)
			return This.NFirstItems(_n_)

		def Take(_n_)
			return This.NFirstItems(_n_)

	# Returns the last n items, in their order.
	#
	#   _n_        how many items to take from the end
	#   returns    a list
	#   note       an n larger than the list gives the whole list and 0 gives [ ], where the same
	#              call of stzListGetter raises error R2; LastNItems and TakeLast are the same call
	#   see        NFirstItems, Section
	def NLastItems(_n_)
		_aNlContent_ = This.Content()
		_nNlLen_ = len(_aNlContent_)
		_aNlResult_ = []

		if _n_ > _nNlLen_
			_n_ = _nNlLen_
		ok

		_nNlStart_ = _nNlLen_ - _n_ + 1
		for _iNl_ = _nNlStart_ to _nNlLen_
			@AddItem(_aNlResult_, _aNlContent_[_iNl_])
		next

		return _aNlResult_

		def LastNItems(_n_)
			return This.NLastItems(_n_)

		def TakeLast(_n_)
			return This.NLastItems(_n_)

	  #=======================================#
	 #     ITEMS BETWEEN TWO POSITIONS       #
	#=======================================#

	def ItemsBetweenPositions(_n1_, _n2_)
		return This.Section(_n1_, _n2_)

		def Between(_n1_, _n2_)
			return This.ItemsBetweenPositions(_n1_, _n2_)
