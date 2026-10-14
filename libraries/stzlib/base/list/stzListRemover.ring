#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTREMOVER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List remover subclass -- removing items,    #
#                  positions, sections, conditions.             #
#                  For aliases, use stzListRemoverXT.           #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Deletes items from a list: every occurrence of an item, the nth or the first or the last, the item at a position, a section, or several positions at once.
#
# It is the removing helper of stzList, which builds one over itself for its RemoveW method; build
# one with new stzListRemover when you only need to delete. It works on its own copy, so a stzList
# passed in is never changed, and you read the result with Content. A verb (RemoveAll,
# RemoveFirstItem, RemoveSection ...) edits the held list in place and returns nothing, its Q form
# returning the remover for chaining; the past-tense forms (AllOccurrencesRemoved, NthItemRemoved,
# FirstItemRemoved, LastItemRemoved) return an edited copy and leave the remover alone. Positions
# count from 1. Items are matched whole and with case; the CS forms take 0 to ignore case. Three
# limits found today: a negative position given to RemoveItemAtPosition (and so to RemoveAt,
# RemoveAtPosition and RemoveNthItem) kills the Ring process, RemoveLastItem raises on an empty
# list, and a position listed twice in RemoveItemsAtPositions deletes two different items.
#
#   receiver   o1 = new stzListRemover([ "a", "b", "a", "c", "a" ])
#   example    ? @@( o1.AllOccurrencesRemoved("a") )
#              #--> [ "b", "c" ]
#              ? @@( o1.NthItemRemoved(2) )
#              #--> [ "a", "a", "c", "a" ]
#              o1.RemoveNthOccurrence(2, "a")
#              ? @@( o1.Content() )
#              #--> [ "a", "b", "c", "a" ]
#              o1.RemoveSection(2, 3)
#              ? @@( o1.Content() )
#              #--> [ "a", "a" ]
#              o2 = new stzListRemover([ "שלום", "😀", "שלום", "x" ])
#              o2.RemoveAll("שלום")
#              ? @@( o2.Content() )
#              #--> [ "😀", "x" ]
#   see        stzList, stzListExtractor, stzListDuplicates
class stzListRemover from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a remover over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to edit, or a stzList whose content is copied, any other value raises
	#                an error
	#   returns      nothing; the object is built
	#   note         the remover works on its own copy: editing it never changes the list or the
	#                stzList you passed in, so read the result with Content
	#   see          Content, RemoveAll
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListRemover! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list as it stands now, after the removals made so far.
	#
	#   returns    a list
	#   see        NumberOfItems, AllOccurrencesRemoved
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

	  #=========================================================#
	 #   REMOVING ALL OCCURRENCES OF A GIVEN ITEM IN THE LIST  #
	#=========================================================#

	def RemoveAllCS(pItem, pCaseSensitive)
		if CheckingParams()
			if isList(pItem) and IsOfNamedParamList(pItem)
				pItem = pItem[2]
			ok
		ok

		# Engine fast path via string-direct variant (sidesteps the
		# cross-DLL handle-table issue).
		if isString(pItem)
			_pRmList_ = @oList._EngineListFromContent()
			if _pRmList_ != ""
				_nRmCs_ = 1
				if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
					_nRmCs_ = pCaseSensitive[2]
				but isNumber(pCaseSensitive)
					_nRmCs_ = pCaseSensitive
				ok
				StzEngineListRemoveAllStringCS(_pRmList_, pItem, _nRmCs_)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pRmList_))
				StzEngineListFree(_pRmList_)
				return
			ok
		ok

		# Fallback for non-string types
		_anRmPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_nRmLenPos_ = len(_anRmPos_)

		_oRmCopy_ = @oList.Copy()

		for _iRm_ = _nRmLenPos_ to 1 step -1
			_oRmCopy_.RemoveItemAtPosition(_anRmPos_[_iRm_])
		next

		@oList.UpdateWith(_oRmCopy_.Content())

		def RemoveAllCSQ(pItem, pCaseSensitive)
			This.RemoveAllCS(pItem, pCaseSensitive)
			return This

		def RemoveCS(pItem, pCaseSensitive)
			This.RemoveAllCS(pItem, pCaseSensitive)

	# Deletes every occurrence of an item from the list, in place.
	#
	#   pItem      the item to delete, a text, a number or a sublist
	#   returns    nothing; the content changes. RemoveAllQ returns the remover for chaining
	#   note       case counts; RemoveAllCS(pItem, 0) ignores case; a number never matches the same
	#              digits written as a text, so removing 1 keeps "1"
	#   see        AllOccurrencesRemoved, RemoveFirstOccurrence, RemoveNthOccurrence
	#@ aka  -- WITHOUT CASESENSITIVITY
	def RemoveAll(pItem)
		This.RemoveAllCS(pItem, 1)

		def RemoveAllQ(pItem)
			This.RemoveAll(pItem)
			return This

		# Deletes every occurrence of an item from the list, in place.
		#
		#   pItem      the item to delete, a text, a number or a sublist
		#   returns    nothing; the content changes. RemoveQ returns the remover for chaining
		#   note       the same call as RemoveAll
		#   see        RemoveAll, RemoveFirstOccurrence
		def Remove(pItem)
			if isList(pItem) and IsEachNamedParamList(pItem)
				pItem = pItem[2]
			ok
			This.RemoveAll(pItem)

	# Returns the list without any occurrence of an item, leaving the remover as it was.
	#
	#   pItem      the item to leave out
	#   returns    a list
	#   see        RemoveAll, NthItemRemoved
	def AllOccurrencesRemoved(pItem)
		# Was @oList.Copy().RemoveAllQ(pItem) but RemoveAllQ isnt on core stzList
		_o = new stzListRemover(@oList.Content())
		_o.RemoveAll(pItem)
		return _o.Content()

	  #--------------------------------------------------#
	 #   REMOVING AN ITEM BY SPECIFYING ITS POSITION    #
	#--------------------------------------------------#

	# Deletes the item at a position, counting from 1, in place.
	#
	#   _n_        the position to delete, from 1
	#   returns    nothing; the content changes. RemoveItemAtPositionQ returns the remover for
	#              chaining
	#   note       RemoveAt, RemoveAtPosition and RemoveNthItem are the same call
	#   warning    a position past the end deletes nothing and says nothing; 0 raises Incorrect
	#              param! n must be a number different from zero; a negative position kills the
	#              whole Ring process with panic: integer part of floating point value out of bounds
	#              in stz_list.dll (RemoveItemAtPosition(-1) on a b c, and (-2) on 10 20)
	#   see        RemoveFirstItem, RemoveLastItem, RemoveItemsAtPositions, NthItemRemoved
	def RemoveItemAtPosition(_n_)

		if isString(_n_)
			if StzFindFirst(_n_, [ :First, :FirstPosition, :FirstItem ]) > 0
				_n_ = 1
			but StzFindFirst(_n_, [ :Last, :LastPosition, :LastItem ]) > 0
				_n_ = This.NumberOfItems()
			ok
		ok

		if NOT (isNumber(_n_) and _n_ != 0 )
			StzRaise("Incorrect param! n must be a number different from zero.")
		ok

		if _n_ <= This.NumberOfItems()
			_pRipList_ = @oList._EngineListFromContent()
			if _pRipList_ != ""
				StzEngineListRemove(_pRipList_, _n_)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pRipList_))
				StzEngineListFree(_pRipList_)
				return
			ok

			_aRipContent_ = This.Content()
			ring_del( _aRipContent_, _n_ )
			@oList.UpdateWith(_aRipContent_)
		ok

		def RemoveItemAtPositionQ(_n_)
			This.RemoveItemAtPosition(_n_)
			return This

		# Deletes the item at a position, counting from 1, in place.
		#
		#   _n_        the position to delete, from 1
		#   returns    nothing; the content changes
		#   note       the same call as RemoveItemAtPosition, so the same warnings: a negative
		#              position kills the Ring process
		#   see        RemoveItemAtPosition, RemoveAtPositions
		def RemoveAt(_n_)
			This.RemoveItemAtPosition(_n_)

		# Deletes the item at a position, counting from 1, in place.
		#
		#   _n_        the position to delete, from 1
		#   returns    nothing; the content changes
		#   note       the same call as RemoveItemAtPosition, so the same warnings: a negative
		#              position kills the Ring process
		#   see        RemoveItemAtPosition, RemoveAtPositions
		def RemoveAtPosition(_n_)
			This.RemoveItemAtPosition(_n_)

		# Deletes the item at a position, counting from 1, in place.
		#
		#   _n_        the position to delete, from 1
		#   returns    nothing; the content changes
		#   note       the same call as RemoveItemAtPosition, so the same warnings: a negative
		#              position kills the Ring process
		#   see        RemoveItemAtPosition, NthItemRemoved
		def RemoveNthItem(_n_)
			This.RemoveItemAtPosition(_n_)

	# Returns the list without the item at a position, leaving the remover as it was.
	#
	#   _n_        the position to leave out, from 1
	#   returns    a list
	#   note       a position past the end leaves the list whole
	#   see        RemoveItemAtPosition, FirstItemRemoved
	def NthItemRemoved(_n_)
		_aNirResult_ = @oList.Copy().RemoveItemAtPositionQ(_n_).Content()
		return _aNirResult_

	  #--------------------------------------#
	 #    REMOVING FIRST ITEM IN THE LIST   #
	#--------------------------------------#

	# Deletes the first item of the list, in place.
	#
	#   returns    nothing; the content changes. RemoveFirstItemQ returns the remover for chaining
	#   note       on an empty list nothing happens
	#   see        FirstItemRemoved, RemoveLastItem, RemoveFirstAndLastItems
	def RemoveFirstItem()
		This.RemoveItemAtPosition(1)

		def RemoveFirstItemQ()
			This.RemoveFirstItem()
			return This

	# Returns the list without its first item, leaving the remover as it was.
	#
	#   returns    a list
	#   see        RemoveFirstItem, LastItemRemoved
	def FirstItemRemoved()
		_aFirResult_ = @oList.Copy().RemoveFirstItemQ().Content()
		return _aFirResult_

	  #-------------------------------------#
	 #    REMOVING LAST ITEM IN THE LIST   #
	#-------------------------------------#

	# Deletes the last item of the list, in place.
	#
	#   returns    nothing; the content changes. RemoveLastItemQ returns the remover for chaining
	#   note       RemoveFirstItem on an empty list is silent
	#   warning    on an empty list it raises Incorrect param! n must be a number different from
	#              zero, because it asks for position 0
	#   see        LastItemRemoved, RemoveFirstItem, RemoveFirstAndLastItems
	def RemoveLastItem()
		This.RemoveItemAtPosition( This.NumberOfItems() )

		def RemoveLastItemQ()
			This.RemoveLastItem()
			return This

	# Returns the list without its last item, leaving the remover as it was.
	#
	#   returns    a list
	#   note       on an empty list it raises the same error as RemoveLastItem
	#   see        RemoveLastItem, FirstItemRemoved
	def LastItemRemoved()
		_aLirResult_ = @oList.Copy().RemoveLastItemQ().Content()
		return _aLirResult_

	  #----------------------------------#
	 #   REMOVING FIRST AND LAST ITEMS  #
	#----------------------------------#

	# Deletes both ends of the list, in place.
	#
	#   returns    nothing; the content changes. RemoveFirstAndLastItemsQ returns the remover for
	#              chaining
	#   warning    on a list of one item it raises Incorrect param! n must be a number different
	#              from zero, because the first removal leaves nothing for the second; a list of two
	#              items becomes [ ]
	#   see        RemoveFirstItem, RemoveLastItem, RemoveSection
	def RemoveFirstAndLastItems()
		This.RemoveFirstItem()
		This.RemoveLastItem()

		def RemoveFirstAndLastItemsQ()
			This.RemoveFirstAndLastItems()
			return This

	  #----------------------------------------------------#
	 #   REMOVING MANY ITEMS AT THE SAME TIME             #
	#----------------------------------------------------#

	def RemoveManyCS(paItems, pCaseSensitive)
		_nRmcLen_ = len(paItems)
		for _iRmc_ = 1 to _nRmcLen_
			This.RemoveAllCS(paItems[_iRmc_], pCaseSensitive)
		next

		def RemoveManyCSQ(paItems, pCaseSensitive)
			This.RemoveManyCS(paItems, pCaseSensitive)
			return This

	def RemoveMany(paItems)
		This.RemoveManyCS(paItems, 1)

		def RemoveManyQ(paItems)
			This.RemoveMany(paItems)
			return This

	  #----------------------------------------------#
	 #   REMOVING MANY ITEMS BY THEIR POSITIONS     #
	#----------------------------------------------#

	# Deletes the items at several positions in one call, in place.
	#
	#   panPositions   the positions to delete, each from 1, in any order
	#   returns        nothing; the content changes. RemoveItemsAtPositionsQ returns the remover for
	#                  chaining
	#   note           the positions are taken from the last to the first, so they all refer to the
	#                  original list
	#   warning        a position listed twice deletes two different items: [ 2, 2 ] on a b c leaves
	#                  a, because the second 2 is read after the first deletion; a position past the
	#                  end is ignored
	#   see            RemoveItemAtPosition, RemoveSection
	def RemoveItemsAtPositions(panPositions)

		if CheckingParams()
			if NOT isList(panPositions)
				StzRaise("Incorrect param type! panPositions must be a list of numbers.")
			ok
		ok

		_oChain_ = new stzList(panPositions)

		panPositions = _oChain_.Sorted()
		_nRiapLen_ = len(panPositions)

		for _iRiap_ = _nRiapLen_ to 1 step -1
			This.RemoveItemAtPosition(panPositions[_iRiap_])
		next

		def RemoveItemsAtPositionsQ(panPositions)
			This.RemoveItemsAtPositions(panPositions)
			return This

		# Deletes the items at several positions in one call, in place.
		#
		#   panPositions   the positions to delete, each from 1, in any order
		#   returns        nothing; the content changes
		#   note           the same call as RemoveItemsAtPositions
		#   warning        a position listed twice deletes two different items, as in
		#                  RemoveItemsAtPositions
		#   see            RemoveItemsAtPositions, RemoveSection
		def RemoveAtPositions(panPositions)
			This.RemoveItemsAtPositions(panPositions)

	  #------------------------------------------#
	 #   REMOVING A SECTION OF ITEMS            #
	#------------------------------------------#

	# Deletes the items from one position to another, both included, in place.
	#
	#   n1         the first position to delete
	#   n2         the last position to delete
	#   returns    nothing; the content changes. RemoveSectionQ returns the remover for chaining
	#   note       a start below 1 becomes 1 and an end past the list becomes the last position, but
	#              a start larger than the end deletes nothing: RemoveSection(4, 2) leaves the list
	#              whole
	#   see        RemoveItemsAtPositions, RemoveAllItems
	def RemoveSection(n1, n2)
		_nRsLen_ = This.NumberOfItems()
		if n1 < 1 { n1 = 1 }
		if n2 > _nRsLen_ { n2 = _nRsLen_ }

		_anRsPositions_ = []
		for _iRs_ = n1 to n2
			@AddItem(_anRsPositions_, _iRs_)
		next

		This.RemoveItemsAtPositions(_anRsPositions_)

		def RemoveSectionQ(n1, n2)
			This.RemoveSection(n1, n2)
			return This

	  #-----------------------------------------#
	 #   REMOVING ALL ITEMS IN THE LIST        #
	#-----------------------------------------#

	# Empties the list, in place.
	#
	#   returns    nothing; the list becomes [ ]. RemoveAllItemsQ returns the remover for chaining
	#   see        Clear, RemoveAll
	def RemoveAllItems()
		@oList.UpdateWith([])

		def RemoveAllItemsQ()
			This.RemoveAllItems()
			return This

		# Empties the list, in place.
		#
		#   returns    nothing; the list becomes [ ]
		#   note       the same call as RemoveAllItems
		#   see        RemoveAllItems, RemoveAll
		def Clear()
			This.RemoveAllItems()

	  #----------------------------------------------#
	 #   REMOVING ITEMS UNDER A GIVEN CONDITION     #
	#----------------------------------------------#

	def RemoveW(pcCondition)

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		_anRwPositions_ = @oList.FindAllItemsW(pcCondition)
		This.RemoveItemsAtPositions(_anRwPositions_)

		def RemoveWQ(pcCondition)
			This.RemoveW(pcCondition)
			return This

	  #------------------------------------#
	 #   REMOVING NTH OCCURRENCE         #
	#------------------------------------#

	def RemoveNthOccurrenceCS(_n_, pItem, pCaseSensitive)
		_nRnoPos_ = @oList.FindNthCS(_n_, pItem, pCaseSensitive)
		if _nRnoPos_ > 0
			This.RemoveItemAtPosition(_nRnoPos_)
		ok

		def RemoveNthOccurrenceCSQ(_n_, pItem, pCaseSensitive)
			This.RemoveNthOccurrenceCS(_n_, pItem, pCaseSensitive)
			return This

	# Deletes the nth occurrence of an item, leaving its other occurrences, in place.
	#
	#   _n_        which occurrence to delete, counting from 1
	#   pItem      the item to look for
	#   returns    nothing; the content changes. RemoveNthOccurrenceCSQ returns the remover for
	#              chaining
	#   note       an n larger than the number of occurrences deletes nothing;
	#              RemoveNthOccurrenceCS(n, pItem, 0) ignores case
	#   see        RemoveFirstOccurrence, RemoveLastOccurrence, RemoveAll
	def RemoveNthOccurrence(_n_, pItem)
		This.RemoveNthOccurrenceCS(_n_, pItem, 1)

	  #--------------------------------------------#
	 #   REMOVING FIRST OCCURRENCE OF AN ITEM    #
	#--------------------------------------------#

	def RemoveFirstOccurrenceCS(pItem, pCaseSensitive)
		This.RemoveNthOccurrenceCS(1, pItem, pCaseSensitive)

	# Deletes only the first occurrence of an item, in place.
	#
	#   pItem      the item to look for
	#   returns    nothing; the content changes
	#   note       an item that is absent deletes nothing; RemoveFirstOccurrenceCS(pItem, 0) ignores
	#              case
	#   see        RemoveLastOccurrence, RemoveNthOccurrence, RemoveAll
	def RemoveFirstOccurrence(pItem)
		This.RemoveFirstOccurrenceCS(pItem, 1)

	  #-------------------------------------------#
	 #   REMOVING LAST OCCURRENCE OF AN ITEM    #
	#-------------------------------------------#

	def RemoveLastOccurrenceCS(pItem, pCaseSensitive)
		_anRloPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_nRloLen_ = len(_anRloPos_)
		if _nRloLen_ > 0
			This.RemoveItemAtPosition(_anRloPos_[_nRloLen_])
		ok

	# Deletes only the last occurrence of an item, in place.
	#
	#   pItem      the item to look for
	#   returns    nothing; the content changes
	#   note       an item that is absent deletes nothing; RemoveLastOccurrenceCS(pItem, 0) ignores
	#              case
	#   see        RemoveFirstOccurrence, RemoveNthOccurrence, RemoveAll
	def RemoveLastOccurrence(pItem)
		This.RemoveLastOccurrenceCS(pItem, 1)
