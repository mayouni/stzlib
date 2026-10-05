#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLIST (CORE)              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List core class -- init, content access,    #
#                  item retrieval, counting, updating, adding. #
#                  For full fluency (aliases), use stzListXT.  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Holds a list of items of any type and finds, sorts, edits, groups and compares them.
#
# A stzList wraps a Ring list so that every operation on it has one name that reads like the
# sentence it stands for: Find, Remove, Replace, Section, Sorted. Active forms change the list in
# place (Sort), passive forms return a changed copy (Sorted), and the Q forms return the object so
# calls chain. Reach for it before writing a loop over a list.
#
#   receiver   o1 = new stzList([ "a", "b", "c", "b" ])
#   example    ? @@( o1.Find("b") )
#              #--> [ 2, 4 ]
#   see        stzString, stzListOfNumbers, stzHashList
class stzList from stzObject
	@aContent = []

	# Engine-residency (see _ENGINE_RESIDENCY_PLAN.md). @aContent is ALWAYS
	# the source of truth; @pEngineGen is a generation token into the engine-
	# side residency cache (0 = no cached handle). The cache OWNS and bounds
	# the marshalled engine handle (FIFO eviction over item/entry caps) so a
	# cached handle never leaks despite Ring having no object destructors.
	# On a cache miss (evicted) _Engine() simply re-marshals from @aContent.
	@pEngineGen = 0

	@aWalkers = []

	These
	_Those_

	  #--------------#
	 #     INIT     #
	#--------------#

	# Builds the stzList from a Ring list.
	#
	#   returns    the new stzList
	#@ aka  Build the list object from the given Ring list.
	def init(paList)

		if CheckingParams()

			if NOT isList(paList)
				StzRaise("Can't create the stzList object! paList must be a list.")
			ok
		ok

		This._SetContent(paList)
		These = This
		_Those_ = This

		StartObjectTime()
		TraceObjectHistory(This)

	# Returns the list as a stzDeepList, for path-based work on nested items.
	#
	#   returns    a stzDeepList
	#   see        Paths
	#@ aka  -- Deep (nested) list view: promotes to stzDeepList for the path-based deep API (DeepFind / Paths / ItemAtPath / ...). Kept modular -- the deep operations live in the stzDeepList subclass, not here.
	def DeepList()
		return new stzDeepList(This.Content())

		# Returns the list as a stzDeepList.
		#
		#   returns    a stzDeepList
		#   see        DeepList
		def AsDeepList()
			return This.DeepList()

	  #---------------------#
	 #     CONSTRAINTS     #
	#---------------------#

	//def MustBe(pcIsMethod)
	//def CanNotBe(pcIsMethod)

	  #-----------------------------------#
	 #  GETTING THE CONTENT OF THE LIST  #
	#-----------------------------------#

	def ContentCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT (pCaseSensitive = 0 or pCaseSensitive = 1)
			StzRaise("Incorrect param type! pCaseSensitive must be 1 (1) or 0 (0).")
		ok

		_aResult_ = []

		if pCaseSensitive = 1
			_aResult_ = @aContent

		else
			_aResult_ = This.WithoutDuplicationCS(0)

		ok

		return _aResult_

		def ContentCSQ(pCaseSensitive)
			return new stzList(This.Content())

	def Content()
		return This._Content()

		def ContentQ()
			return new stzList(This.Content())

	  #--------------------------------------------------------#
	 #  GETTING THE CONTENT OF THE LIST WITHOUT DUPPLICATION  #
	#--------------------------------------------------------#

	def ContentCSU(pCaseSensitive)
		return This.WithoutDuplicationCS(0)

		def ContentCSUQ(pCaseSensitive)
			return new stzList(This.ContentU())

	def ContentU()
		return This.WithoutDuplication()

		def ContentUQ()
			return new stzList(This.ContentU())

	  #------------------------------#
	 #  GETTING A COPY OF THE LIST  #
	#------------------------------#

	# Returns a new stzList with the same items, so the copy can change without touching this one.
	#
	#   returns    a new stzList
	#   example    o2 = o1.Copy()
	#              o2.Add("z")
	#              ? @@( o1.Content() )
	#              #--> [ "a", "b", "c", "b" ]
	#              ? @@( o2.Content() )
	#              #--> [ "a", "b", "c", "b", "z" ]
	def Copy()
		return new stzList( This.List() )

	def ReversedCopy()
		return This.ReverseQ()

	  #-------------------------------------------#
	 #  GETTING THE NUMBER OF ITEMS OF THE LIST  #
	#-------------------------------------------#

	def NumberOfItemsCS(pCaseSensitive)
		_nResult_ = len( This.ContentCS(pCaseSensitive) )
		return _nResult_

		def NumberOfItemsCSQ(pCaseSensitive)
			return new stzNumber( This.NumberOfItemsCS(pCaseSensitive) )

		# TRUE if the count of items equals the last value the library remembers, the B form of a count test.
		#
		#   pCaseSensitive   1 to compare with case, 0 to ignore it
		#   returns          TRUE or FALSE
		#   see              NumberOfItems
		def NumberOfItemsCSB(pCaseSensitive)
			if This.NumberOfItemsCS(pCaseSensitive) = LastValue()
				return 1
			else
				return 0
			ok

			def NumberOfItemsCSBQ(pCaseSensitive)
				if This.NumberOfItemsCSB(pCaseSensitive)
					return This
				else
					return AFalseObject()
				ok

	# Returns how many items the list holds.
	#
	#   returns    a number
	#   see        Count, IsEmpty
	#   example    ? o1.NumberOfItems()
	#              #--> 4
	def NumberOfItems()
		_nResult_ = len(@aContent)
		return _nResult_

		def NumberOfItemsQ()
			return new stzNumber( This.NumberOfItems() )

		# TRUE if the count of items equals the last value the library remembers, the B form of a count test.
		#
		#   returns    TRUE or FALSE
		#   see        NumberOfItems
		def NumberOfItemsB()
			if This.NumberOfItems() = LastValue()
				return 1
			else
				return 0
			ok

			def NumberOfItemsBQ()
				if This.NumberOfItemsB()
					return This
				else
					return AFalseObject()
				ok

	  #--------------------------------------------------------------#
	 #  GETTING THE NUMBER OF ITEMS OF THE LIST -- U/Extended FORM  #
	#--------------------------------------------------------------#

	def NumberOfItemsU()
		return len( Q(This.Content()).WithoutDuplicates() )

		def NumberOfItemsUQ()
			return new stzNumber(This.NumberOfItemsU())

	  #-----------------------------#
	 #  GETTING THE LIST OF ITEMS  #
	#-----------------------------#

	def Items()
		return This.Content()

		def ItemsQ()
			return This

	  #------------------------------------#
	 #  GETTING THE NTH ITEM IN THE LIST  #
	#------------------------------------#

	# Returns the item at position n.
	#
	#   _n_        a position from 1 to the number of items; a negative position counts from the
	#              end; "first" and "last" are accepted
	#   returns    the item, of any type
	#   warning    a position beyond the end raises an error
	#   see        Section, Find
	#   example    ? o1.Item(3)
	#              #--> c
	#              ? o1.Item(-1)
	#              #--> b
	def Item(_n_)

		if CheckingParams()

			if isString(_n_)
				if _n_ = "first"
					_n_ = 1

				but _n_ = "last"
					_n_ = This.NumberOfItems()

				ok
			ok

			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n should be a number.")
			ok
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _n_ > _nLen_
			StzRaise("Index outside the list!" + char(10) +
			 "Trying to access position " + _n_ + " in a list of "  + _nLen_ + " items!")
		but _n_ < 0
			_n_ = _nLen_ + _n_ + 1
		ok

		return @aContent[_n_]

		def ItemQ(_n_)
			return Q(This.Item(_n_))

		#@ aka  item at position, element at, get by index, the nth one
		def NthItem(_n_)
			return This.Item(_n_)

			def NthItemQ(_n_)
				return This.ItemQ(_n_)

		def ItemAtPosition(_n_)
			return This.Item(_n_)

		def ItemAt(_n_)
			return This.Item(_n_)

	  #--------------------------------------#
	 #  GETTING THE FIRST ITEM IN THE LIST  #
	#--------------------------------------#

	# Returns the item at position 1.
	#
	#   returns    the item
	#   see        LastItem, NthItem
	#@ aka  head, front, first element, the top, beginning item
	def FirstItem()
		return This.NthItem(1)

		def FirstItemQ()
			return Q(This.FirstItem())

	  #-------------------------------------#
	 #  GETTING THE LAST ITEM IN THE LIST  #
	#-------------------------------------#

	# Returns the item at the last position.
	#
	#   returns    the item
	#   see        FirstItem, NthItem
	#@ aka  tail, back, last element, the end, final item
	def LastItem()
		return This.NthItem( This.NumberOfItems() )

		def LastItemQ()
			return Q(This.LastItem())

	  #------------------------------------------------#
	 #  GETTING THE FIRST AND LAST ITEMS IN THE LIST  #
	#------------------------------------------------#

	# Returns the first and the last items as a pair.
	#
	#   returns    a pair [ first, last ]
	#   see        LastAndFirstItems
	def FirstAndLastItems()
		_aResult_ = [ This.FirstItem(), This.LastItem() ]
		return _aResult_

	# Returns the last and the first items as a pair.
	#
	#   returns    a pair [ last, first ]
	#   see        FirstAndLastItems
	def LastAndFirstItems()
		_aResult_ = [ This.LastItem(), FirstItem() ]
		return _aResult_

	  #--------------------------------------------#
	 #  GETTING THE CENTRAL POSITION IN THE LIST  #
	#--------------------------------------------#

	# Returns the position at the middle of the list; for an even count, the upper of the two middle positions.
	#
	#   returns    a number
	#   see        CentralItem
	def CentralPosition()
		_oTemp_ = new stzNumber( (This.NumberOfItems()/2) )
		_n_ = _oTemp_.IntegerPartValue()
		return _n_

		def CentralItemPosition()
			return This.CentralPosition()

	  #----------------------------------------#
	 #  GETTING THE CENTRAL ITEM IN THE LIST  #
	#----------------------------------------#

	# Returns the item at the central position.
	#
	#   returns    the item
	#   see        CentralPosition
	def CentralItem()
		return This[CentralPosition()]

		def CentralItemQ()
			return Q(This.CentralItem())

	  #---------------------------------------------#
	 #  CHECKING IF THE STRING HAS A CENTRAL ITEM  #
	#---------------------------------------------#

	# TRUE if the count of items is odd, so that one item stands in the middle.
	#
	#   returns    TRUE or FALSE
	#   see        CentralItem
	def HasCentralItem()
		return This.NumberOfItemsQ().IsNotEven()

		def ContainsCentralItem()
			return This.HasCentralItem()

	  #-------------------------------------#
	 #  GETTING THE LIST OF N FIRST ITEMS  #
	#-------------------------------------#

	# Returns the first n items, or the whole list when n is larger.
	#
	#   _n_        how many items
	#   returns    a list of items
	#   see        FirstNItems
	def NFirstItems(_n_)
		_aContent_ = This.Content()
		_aResult_ = []

		for _i_ = 1 to _n_
			_aResult_ + _aContent_[_i_]
		next

		return _aResult_

		def NFirstItemsQ(_n_)
			return NFirstItemsQRT(_n_, :stzList)

		def NFirstItemsQRT(_n_, pcReturnType)
			if isList(pcReturnType) and
			   Q(pcReturnType).IsReturnedAsNamedParam()

				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NFirstItems(_n_) )

			on :stzListOfStrings
				return new stzListOfStrings( This.NFirstItems(_n_) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NFirstItems(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

	  #------------------------------------#
	 #  GETTING THE LIST OF N LAST ITEMS  #
	#------------------------------------#

	# Returns the last n items, or the whole list when n is larger.
	#
	#   _n_        how many items
	#   returns    a list of items
	#   see        LastNItems
	def NLastItems(_n_)
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_n1_ = _nLen_ - _n_ + 1
		_n2_ = _nLen_

		_aResult_ = []

		for _i_ = _n1_ to _n2_
			_aResult_ + _aContent_[_i_]
		next

		return _aResult_

		def NLastItemsQ(_n_)
			return NLastItemsQRT(_n_, :stzList)

		def NLastItemsQRT(_n_, pcReturnType)
			if isList(pcReturnType) and
			   Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NLastItems(_n_) )

			on :stzListOfStrings
				return new stzListOfStrings( This.NLastItems(_n_) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NLastItems(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

	  #-------------------------------------------------#
	 #  GETTING NEXT/PREVIOUS N ITEMS FROM A POSITION  #
	#-------------------------------------------------#

	# Returns the n items that follow a given position.
	#
	#   _n_        how many items
	#   returns    a list of items
	#   see        NextNthOccurrence
	def NextNItems(_n_, pnStartingAt)

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if isList(pnStartingAt) and IsStartingAtOrStartingAtPositionNamedParamList(pnStartingAt)
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if pnStartingAt = :First or pnStartingAt = :FirstItem
				pnStartingAt = 1

			but pnStartingAt = :Last or pnStartingAt = :LastItem
				pnStartingAt = This.NumberOfItems()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			StzRaise("Incorrect param type! pnStartingAt must be a number.")
		ok

		if pnStartingAt < 0
			pnStartingAt = This.NumberOfItems() - Abs(pnStartingAt) + 1
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		# The n items AFTER the starting position (exclusive), matching
		# the string-side NextNChars(:StartingAt) semantics.
		_n1_ = pnStartingAt + 1
		_n2_ = pnStartingAt + _n_
		if _n2_ > _nLen_
			_n2_ = _nLen_
		ok

		_aResult_ = []
		for _i_ = _n1_ to _n2_
			_aResult_ + _aContent_[_i_]
		next

		return _aResult_

	  #--------------------#
	 #      UPDATING      #
	#--------------------#

	# Replaces the whole content by the given list, in place.
	#
	#   returns    nothing; the list changes
	#   see        UpdateWith
	#@ aka  Replace the whole content with the given list (mutating; the enforcement guard sits at _SetContent, the single update point).
	def Update(paNewList)
		if CheckingParams() = 1
			if isList(paNewList) and IsWithOrByOrUsingNamedParamList(paNewList)
				paNewList = paNewList[2]
			ok

			if NOT isList(paNewList)
				StzRaise("Incorrect param type! paNewList must be a list.")
			ok
		ok

		This._SetContent(paNewList)

		if _bInHistoryUpdate = 0
			@TraceObjectHistory(This)
		ok

		def UpdateQ(paNewList)
			This.Update(paNewList)
			return This

		# Replaces the whole content by the given list, in place.
		#
		#   returns    nothing; the list changes
		#   see        Update
		#@ aka  Same as Update: replace the whole content (mutating).
		def UpdateWith(paNewList)
			This.Update(paNewList)

			def UpdateWithQ(paNewList)
				return This.UpdateQ(paNewList)

		# Replaces the whole content by the given list, in place.
		#
		#   returns    nothing; the list changes
		#   see        Update
		#@ aka  Same as Update: replace the whole content (mutating).
		def UpdateBy(paNewList)
			This.Update(paNewList)

			def UpdateByQ(paNewList)
				return This.UpdateQ(paNewList)

	# Returns the given list, the content the list would take with Update; the list is unchanged.
	#
	#   returns    a list of items
	#   see        Update
	#@ aka  The value the list would be updated to (the passive twin of Update).
	def Updated(paNewList)
		return paNewList

		def UpdatedWith(paNewList)
			return This.Updated(paNewList)

		def UpdatedBy(paNewList)
			return This.Updated(paNewList)

	  #----------------------#
	 #     ADDING ITEMS     #
	#----------------------#

	# Appends the item at the end, in place.
	#
	#   returns    nothing; the list changes
	#   see        AddItems
	#@ aka  append, push, add element, put at the end
	#@ aka  Add the given item at the end of the list (mutating).
	def AddItem(pItem)
		_aCopy_ = This.Content()
		_aCopy_ + pItem
		This.UpdateWith(_aCopy_)

		def AddItemQ(pItem)
			This.AddItem(pItem)
			return This

		# Appends the item at the end of the list, in place.
		#
		#   pItem      the item to add
		#   returns    nothing; the list changes. AddQ returns the object for chaining
		#   see        Append, Extend, InsertBefore
		#   example    o1.Add("z")
		#              ? @@( o1.Content() )
		#              #--> [ "a", "b", "c", "b", "z" ]
		#@ aka  append, push, add to the end, put at the back
		def Add(pItem)
			This.AddItem(pItem)

			def AddQ(pItem)
				This.Add(pItem)
				return This

		# Appends the item at the end of the list, in place, as Add does.
		#
		#   pItem      the item to append
		#   returns    nothing; the list changes. AppendQ returns the object for chaining
		#   see        Add
		#   example    o1.Append("e")
		#              ? @@( o1.Content() )
		#              #--> [ "a", "b", "c", "b", "e" ]
		#@ aka  Same as AddItem: append the item at the end (mutating).
		def Append(pItem)
			if isList(pItem) and IsWithOrUsingOrByNamedParamList(pItem)
				pItem = pItem[2]
			ok

			This.AddItem(pItem)

			def AppendQ(pItem)
				This.Append(pItem)
				return This

	# Returns a copy with the item appended; the list is unchanged.
	#
	#   returns    a list of items
	#   see        AddItem
	#@ aka  A copy of the list with the item appended; the original is unchanged.
	def ItemAdded(pItem)
		_aResult_ = This.Copy().AddItemQ(pItem).Content()
		return _aResult_

		def Added(pItem)
			return This.ItemAdded(pItem)

	# Returns a copy with each of the given items appended; the list is unchanged.
	#
	#   returns    a list of items
	#   see        AddItems
	#@ aka  A copy with each item of paItems appended; the original is unchanged.
	def ManyAdded(paItems)
		# Non-mutating: append each item of paItems to a copy.
		_aResult_ = This.Copy().AddManyQ(paItems).Content()
		return _aResult_

	  #-----------------------------------#
	 #  MERGING WITH ANOTHER LIST        #
	#-----------------------------------#

	# Appends the items of the other list to the list, in place.
	#
	#   returns    nothing; the list changes
	#   see        MergedWith
	def MergeWith(paOtherList)
		_nLen_ = len(paOtherList)
		for _i_ = 1 to _nLen_
			This.Add(paOtherList[_i_])
		next

		def MergeWithQ(paOtherList)
			This.MergeWith(paOtherList)
			return This

	# Returns the items of the list followed by those of the other; the list is unchanged.
	#
	#   returns    a list of items
	#   see        MergeWith
	def MergedWith(paOtherList)
		_aResult_ = This.Content()
		_nLen_ = len(paOtherList)
		for _i_ = 1 to _nLen_
			_aResult_ + paOtherList[_i_]
		next
		return _aResult_

	  #-----------------------------------------------------------#
	 #  ADDING AN ITEM AT A GIVEN POSITION --> INSERT OR EXTEND  #
	#-----------------------------------------------------------#

	# Inserts the item before position n, in place.
	#
	#   _n_        the position to insert before
	#   returns    nothing; the list changes
	#   see        InsertAt
	def AddItemAt(_n_, pItem)

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if _n_ <= This.NumberOfItems()
			This.InsertAt(_n_, pItem)

		else
			This.ExtendToPositionXT(_n_ - 1, :With = "")
			This.Add(pItem)
		ok

		def AddItemAtQ(_n_, pItem)
			This.AddItemAt(_n_, pItem)
			return This

	  #-----------------------------------------#
	 #  ADDING MANY ITEMS TO THE LIST          #
	#-----------------------------------------#

	def AddMany(paItems)
		if NOT isList(paItems)
			StzRaise("Incorrect param type! paItems must be a list.")
		ok

		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			This.AddItem(paItems[_i_])
		next

		def AddManyQ(paItems)
			This.AddMany(paItems)
			return This

		# Appends each of the given items at the end, in place.
		#
		#   returns    nothing; the list changes
		#   see        AddItem
		def AddItems(paItems)
			This.AddMany(paItems)

	  #-------------------#
	 #     IS EMPTY      #
	#-------------------#

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfItems
	#   example    ? o1.IsEmpty()
	#              #--> FALSE
	#              o1 = new stzList([])
	#              ? o1.IsEmpty()
	#              #--> TRUE
	#@ aka  empty, blank, has no items, nothing in it, contains nothing
	#@ aka  TRUE if the list has no items.
	def IsEmpty()
		return This.NumberOfItems() = 0

	# TRUE if the list holds at least one item.
	#
	#   returns    TRUE or FALSE
	#   see        IsEmpty
	#@ aka  TRUE if the list has at least one item.
	def IsNotEmpty()
		return NOT This.IsEmpty()

	  #------------------------------------------#
	 #  NAMED-PARAM CHECKS (needed by Q() calls) #
	#------------------------------------------#

	# TRUE if the list is a named param: a pair whose first item is a keyword and whose second is its value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	#@ aka  Generic: checks if this list is a named param (2-item, first is keyword)
	def IsNamedParam()
		return StzIsNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :And, such as :And = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	# --- Methods with existing global functions ---
	def IsAndNamedParam()
		return StzIsAndNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :At, such as :At = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAtNamedParam()
		return StzIsAtNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :At or :AtPosition, such as :At = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAtOrAtPositionNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["at", "atposition"])

	# TRUE if the list is a pair whose first item is the keyword :AtPosition, such as :AtPosition = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "atposition")

	# TRUE if the list is a pair whose first item is the keyword :Between, such as :Between = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweenNamedParam()
		return StzIsBetweenNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :By, such as :By = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsByNamedParam()
		return StzIsByNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :CaseSensitive, such as :CaseSensitive = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsCaseSensitiveNamedParam()
		return StzIsCaseSensitiveNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :Direction or :Going, such as :Direction = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsDirectionOrGoingNamedParam()
		return StzIsDirectionOrGoingNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :EqualTo, such as :EqualTo = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsEqualToNamedParam()
		return StzIsEqualToNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :From, such as :From = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsFromNamedParam()
		return StzIsFromNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :In, such as :In = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsInNamedParam()
		return StzIsInNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :Nor, such as :Nor = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsNorNamedParam()
		return StzIsNorNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :Of, such as :Of = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsOfNamedParam()
		return StzIsOfNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :Of or :OfSubString, such as :Of = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsOfOrOfSubStringNamedParam()
		return StzIsOfOrOfSubStringNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :Position, such as :Position = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsPositionNamedParam()
		return StzIsPositionNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :Position or :Positions, such as :Position = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsPositionOrPositionsNamedParam()
		return StzIsPositionOrPositionsNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :ReturnedAs, such as :ReturnedAs = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsReturnedAsNamedParam()
		return StzIsReturnedAsNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :StartingAt, such as :StartingAt = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsStartingAtNamedParam()
		return StzIsStartingAtNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :StoppingAt, such as :StoppingAt = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsStoppingAtNamedParam()
		return StzIsStoppingAtNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :To, such as :To = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsToNamedParam()
		return StzIsToNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :Using or :With or :By, such as :Using = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsUsingOrWithOrByNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["using", "with", "by"])

	# TRUE if the list is a pair whose first item is the keyword :Where, such as :Where = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsWhereNamedParam()
		return StzIsWhereNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :With, such as :With = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsWithNamedParam()
		return StzIsWithNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :With or :By, such as :With = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsWithOrByNamedParam()
		return StzIsWithOrByNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :With or :By or :Using, such as :With = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsWithOrByOrUsingNamedParam()
		return StzIsWithOrByOrUsingNamedParamList(This.Content())

	# TRUE if the list is a pair whose first item is the keyword :AndcColNamed, such as :AndcColNamed = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	# --- Methods without existing global functions (keyword-based) ---
	def IsAndcColNamedNamedParam()
		return StzIsThisNamedParam(This.Content(), "andccolnamed")

	# TRUE if the list is a pair whose first item is the keyword :AndcCol, such as :AndcCol = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndcColNamedParam()
		return StzIsThisNamedParam(This.Content(), "andccol")

	# TRUE if the list is a pair whose first item is the keyword :AndColAt, such as :AndColAt = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndColAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolat")

	# TRUE if the list is a pair whose first item is the keyword :AndColAtPosition, such as :AndColAtPosition = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndColAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolatposition")

	# TRUE if the list is a pair whose first item is the keyword :AndColumnAt, such as :AndColumnAt = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndColumnAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolumnat")

	# TRUE if the list is a pair whose first item is the keyword :AndColumnAtPosition, such as :AndColumnAtPosition = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndColumnAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolumnatposition")

	# TRUE if the list is a pair whose first item is the keyword :AndColumnNamed, such as :AndColumnNamed = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndColumnNamedNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolumnnamed")

	# TRUE if the list is a pair whose first item is the keyword :AndColumn, such as :AndColumn = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndColumnNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolumn")

	# TRUE if the list is a pair whose first item is the keyword :AndPosition, such as :AndPosition = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "andposition")

	# TRUE if the list is a pair whose first item is the keyword :AndReturning, such as :AndReturning = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndReturningNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["andreturning", "andreturnas", "andreturnedas"])

	# TRUE if the list is a pair whose first item is the keyword :AndReturningNth, such as :AndReturningNth = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndReturningNthNamedParam()
		return StzIsThisNamedParam(This.Content(), "andreturningnth")

	# TRUE if the list is a pair whose first item is the keyword :AndReturn, such as :AndReturn = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndReturnNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["andreturn", "andreturnas", "andreturnedas", "andreturnitas"])

	# TRUE if the list is a pair whose first item is the keyword :AndReturnNth, such as :AndReturnNth = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndReturnNthNamedParam()
		return StzIsThisNamedParam(This.Content(), "andreturnnth")

	# TRUE if the list is a pair whose first item is the keyword :AndRowAt, such as :AndRowAt = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndRowAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "androwat")

	# TRUE if the list is a pair whose first item is the keyword :AndRowAtPosition, such as :AndRowAtPosition = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndRowAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "androwatposition")

	# TRUE if the list is a pair whose first item is the keyword :AndRow, such as :AndRow = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAndRowNamedParam()
		return StzIsThisNamedParam(This.Content(), "androw")

	# TRUE if the list is a pair whose first item is the keyword :BetweencCol, such as :BetweencCol = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweencColNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweenccol")

	# TRUE if the list is a pair whose first item is the keyword :BetweenColAt, such as :BetweenColAt = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweenColAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweencolat")

	# TRUE if the list is a pair whose first item is the keyword :BetweenColAtPosition, such as :BetweenColAtPosition = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweenColAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweencolatposition")

	# TRUE if the list is a pair whose first item is the keyword :BetweenColumnAt, such as :BetweenColumnAt = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweenColumnAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweencolumnat")

	# TRUE if the list is a pair whose first item is the keyword :BetweenColumnAtPosition, such as :BetweenColumnAtPosition = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweenColumnAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweencolumnatposition")

	# TRUE if the list is a pair whose first item is the keyword :BetweenColumn, such as :BetweenColumn = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweenColumnNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweencolumn")

	# TRUE if the list is a pair whose first item is the keyword :BetweenPosition, such as :BetweenPosition = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweenPositionNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["betweenposition", "betweenpositions"])

	# TRUE if the list is a pair whose first item is the keyword :BetweenPositions, such as :BetweenPositions = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweenPositionsNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweenpositions")

	# TRUE if the list is a pair whose first item is the keyword :BetweenRowAt, such as :BetweenRowAt = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweenRowAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweenrowat")

	# TRUE if the list is a pair whose first item is the keyword :BetweenRowAtPosition, such as :BetweenRowAtPosition = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweenRowAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweenrowatposition")

	# TRUE if the list is a pair whose first item is the keyword :BetweenRow, such as :BetweenRow = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsBetweenRowNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweenrow")

	# TRUE if the list is a pair whose first item is the keyword :ByCol or :ByColNumber, such as :ByCol = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsByColOrByColNumberNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["bycol", "bycolnumber"])

	# TRUE if the list is a pair whose first item is the keyword :By or :Using or :With, such as :By = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsByOrUsingOrWithNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["by", "using", "with"])

	# TRUE if the list is a pair whose first item is the keyword :By or :With or :Using, such as :By = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsByOrWithOrUsingNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["by", "with", "using"])

	# TRUE if the list is a pair whose first item is the keyword :ByRow, such as :ByRow = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsByRowNamedParam()
		return StzIsThisNamedParam(This.Content(), "byrow")

	# TRUE if the list is a pair whose first item is the keyword :Coming, such as :Coming = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsComingNamedParam()
		return StzIsThisNamedParam(This.Content(), "coming")

	# TRUE if the list is a pair whose first item is the keyword :From or :Of, such as :From = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsFromOrOfNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["from", "of"])

	# TRUE if the list is a pair whose first item is the keyword :FromPosition, such as :FromPosition = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsFromPositionNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["fromposition", "from"])

	# TRUE if the list is a pair whose first item is the keyword :InA, such as :InA = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsInANamedParam()
		return StzIsThisNamedParam(This.Content(), "ina")

	# TRUE if the list is a pair whose first item is the keyword :In or :InList, such as :In = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsInOrInListNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["in", "inlist"])

	# TRUE if the list is a pair whose first item is the keyword :In or :InString, such as :In = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsInOrInStringNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["in", "instring"])

	# TRUE if the list is a pair whose first item is the keyword :OfSize, such as :OfSize = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsOfSizeNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["ofsize", "size"])

	# TRUE if the list is a pair whose first item is the keyword :Returning, such as :Returning = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsReturningNamedParam()
		return StzIsThisNamedParam(This.Content(), "returning")

	# TRUE if the list is a pair whose first item is the keyword :ReturningNth, such as :ReturningNth = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsReturningNthNamedParam()
		return StzIsThisNamedParam(This.Content(), "returningnth")

	# TRUE if the list is a pair whose first item is the keyword :Return, such as :Return = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsReturnNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["return", "returnas", "returnedas", "returnitas"])

	# TRUE if the list is a pair whose first item is the keyword :ReturnNth, such as :ReturnNth = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsReturnNthNamedParam()
		return StzIsThisNamedParam(This.Content(), "returnnth")

	# TRUE if the list is a pair whose first item is the keyword :Seed, such as :Seed = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsSeedNamedParam()
		return StzIsThisNamedParam(This.Content(), "seed")

	# TRUE if the list is a pair whose first item is the keyword :Size, such as :Size = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsSizeNamedParam()
		return StzIsThisNamedParam(This.Content(), "size")

	# TRUE if the list is a pair whose first item is the keyword :To or :Of, such as :To = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsToOrOfNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["to", "of"])

	# TRUE if the list is a pair whose first item is the keyword :ToPosition, such as :ToPosition = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsToPositionNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["toposition", "to"])

	def IsToOrToPosition()
		return This.IsToPositionNamedParam()

		def IsToPositionOrTo()
			return This.IsToPositionNamedParam()

	# AllItemsAreEqualCS: TRUE iff every item in the list equals
	# every other item (i.e. all items collapse to a single value).
	# Case-sensitivity applies only when items are strings.
	def AllItemsAreEqualCS(pCaseSensitive)
		_pList_ = This._EngineListFromContent()
		_nResult_ = StzEngineListAllItemsEqualCS(_pList_, pCaseSensitive)
		StzEngineListFree(_pList_)
		return _nResult_

		# TRUE if only one distinct value occurs among the items.
		#
		#   returns    TRUE or FALSE
		#   see        ItemsAreEqualTo
		def AllItemsAreEqual()
			return This.AllItemsAreEqualCS(1)

		def AllAreEqualCS(pCaseSensitive)
			return This.AllItemsAreEqualCS(pCaseSensitive)

		# TRUE if only one distinct value occurs among the items.
		#
		#   returns    TRUE or FALSE
		#   see        AllItemsAreEqual
		def AllAreEqual()
			return This.AllItemsAreEqualCS(1)

	# TRUE if the list is a pair whose first item is the keyword :WithRow, such as :WithRow = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsWithRowNamedParam()
		return StzIsThisNamedParam(This.Content(), "withrow")

	  #====================#
	 #  SHOWING THE LIST  #
	#====================#

	# Returns the list as a string in its computable @@ form.
	#
	#   returns    a string
	#   see        ToString, Show
	#   example    ? o1.Stringified()
	#              #--> [ "a", "b", "c", "b" ]
	#@ aka  The list rendered as a computable string (the @@ form).
	def Stringified()
		return @@(This.Content())

		def ToCode()
			return This.Stringified()

	# Returns the items as one string, one item per line.
	#
	#   returns    a string; an item that is neither text nor a number is written in its @@ form
	#   see        Join, Stringified
	#   example    ? o1.ToString()
	#              #--> a
	#              #--> b
	#              #--> c
	#              #--> b
	#@ aka  ToString: a plain display form -- the items rendered one per line (monolith semantics: ToStringXT(:ConcatenatedUsing = NL)). Overrides the stzObject default so a stzList stringifies to its content, not to an "@noname" object handle.
	def ToString()
		_aTsContent_ = This.Content()
		_nTsLen_ = len(_aTsContent_)
		_cTsRes_ = ""
		for _iTs_ = 1 to _nTsLen_
			if _iTs_ > 1
				_cTsRes_ = _cTsRes_ + nl
			ok
			_xTs_ = _aTsContent_[_iTs_]
			if isString(_xTs_)
				_cTsRes_ = _cTsRes_ + _xTs_
			but isNumber(_xTs_)
				_cTsRes_ = _cTsRes_ + ("" + _xTs_)
			else
				_cTsRes_ = _cTsRes_ + @@(_xTs_)
			ok
		next
		return _cTsRes_

		def ToStringQ()
			return new stzString(This.ToString())

	# Prints the list in its computable @@ form.
	#
	#   returns    nothing; the list is printed
	#   see        ShowShort, Stringified
	#   example    o1.Show()
	#              #--> [ "a", "b", "c", "b" ]
	#@ aka  Print the list to stdout in its computable @@ form.
	def Show()
		? @@( This.Content() )

	# Prints an abbreviated form of the list: its first three items, then "...", then its last three.
	#
	#   returns    nothing; the list is printed
	#   note       a list of six items or fewer is printed whole
	#   see        Show
	#   example    o1 = new stzList([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ])
	#              o1.ShowShort()
	#              #--> [ 1, 2, 3, "...", 10, 11, 12 ]
	#@ aka  Print an abbreviated form of the list (first items ... last items).
	def ShowShort()
		? @@S( This.Content() )

	# Prints the abbreviated form of the list, with n items at each end.
	#
	#   _n_        how many items to show at each end
	#   returns    nothing; the form is printed
	#   see        Show
	#@ aka  Print the abbreviated form showing n items at each end.
	def ShowShortN(_n_)
		? ComputableShortFormXT( This.Content(), _n_ )

	def ShowShortXT(nItems)
		# nItems may be a number (symmetric N first + N last)
		# or a 2-list [nHead, nTail] for asymmetric short form.
		? ComputableShortFormXT( This.Content(), nItems )

	  #-----------------------------#
	 #  CLASS NAME                 #
	#-----------------------------#

	# Returns the class name in lowercase, "stzlist".
	#
	#   returns    a string
	#@ aka  The lowercase class name: "stzlist".
	def ClassName()
		return "stzlist"

	# Returns the Softanza type symbol of the object, always :stzList.
	#
	#   returns    the symbol :stzList, which prints as stzlist
	#   example    ? o1.StzType()
	#              #--> stzlist
	#@ aka  The Softanza type symbol: :stzList.
	def StzType()
		return :stzList

	  #=============================================#
	 #  REPLACE DELEGATIONS (via stzListReplacer)  #
	#=============================================#

	def ReplaceCS(pItem, pNewItem, pCaseSensitive)
		_oRpl_ = new stzListReplacer(This)
		_oRpl_.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRpl_.Content())

	# Replaces every occurrence of the item by the new item, in place.
	#
	#   pItem      the item to replace
	#   pNewItem   the item to put instead
	#   returns    nothing; the list changes
	#   see        ReplaceAt, ReplaceByMany, ReplaceManyByMany
	#   example    o1.Replace("b", "B")
	#              ? @@( o1.Content() )
	#              #--> [ "a", "B", "c", "B" ]
	def Replace(pItem, pNewItem)
		This.ReplaceCS(pItem, pNewItem, 1)

	def ReplaceNthCS(_n_, pItem, pNewItem, pCaseSensitive)
		_oRplN_ = new stzListReplacer(This)
		_oRplN_.ReplaceNthOccurrenceCS(_n_, pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRplN_.Content())

	# Replaces the nth occurrence of the item by a new item, in place.
	#
	#   _n_        which occurrence
	#   returns    nothing; the list changes
	#   see        ReplaceFirst
	def ReplaceNth(_n_, pItem, pNewItem)
		This.ReplaceNthCS(_n_, pItem, pNewItem, 1)

	# Occurrence-replace delegation, accepting the named-param call
	# form ReplaceNthOccurrence(n, :Of = item, :With = newItem).

	def ReplaceNthOccurrenceCS(_n_, pItem, pNewItem, pCaseSensitive)
		if isList(pItem) and len(pItem) = 2 and isString(pItem[1]) and
		   (pItem[1] = :of or pItem[1] = :Of or pItem[1] = :For or pItem[1] = :for)
			pItem = pItem[2]
		ok
		if isList(pNewItem) and len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or
		    pNewItem[1] = :By or pNewItem[1] = :using or pNewItem[1] = :Using)
			pNewItem = pNewItem[2]
		ok
		_oRplNO_ = new stzListReplacer(This)
		_oRplNO_.ReplaceNthOccurrenceCS(_n_, pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRplNO_.Content())

	# Replaces the nth occurrence of the item by a new item, in place.
	#
	#   _n_        which occurrence
	#   returns    nothing; the list changes
	#   see        ReplaceNth
	def ReplaceNthOccurrence(_n_, pItem, pNewItem)
		This.ReplaceNthOccurrenceCS(_n_, pItem, pNewItem, 1)

	# Replace the nth occurrence of an item counting backward from a
	# given position. Named form:
	#   ReplacePreviousNthOccurrence(n, :Of=item, :By=new, :StartingAt=p)

	def ReplacePreviousNthOccurrenceCS(_n_, pItem, pNewItem, pnStartingAt, pCaseSensitive)
		if isList(pItem) and ring_len(pItem) = 2 and isString(pItem[1]) and
		   (pItem[1] = :of or pItem[1] = :Of)
			pItem = pItem[2]
		ok
		if isList(pNewItem) and ring_len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or
		    pNewItem[1] = :By or pNewItem[1] = :using or pNewItem[1] = :Using)
			pNewItem = pNewItem[2]
		ok
		if isList(pnStartingAt) and ring_len(pnStartingAt) = 2 and isString(pnStartingAt[1]) and
		   (pnStartingAt[1] = :startingat or pnStartingAt[1] = :StartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		_oRpvSec_ = This.SectionQ(1, pnStartingAt)
		_anRpvPos_ = _oRpvSec_.FindAllCS(pItem, pCaseSensitive)
		_nRpvPos_ = _anRpvPos_[ ring_len(_anRpvPos_) - _n_ + 1 ]
		This.ReplaceAt(_nRpvPos_, pNewItem)

	# Replaces the nth occurrence of the item before a given position by a new item, in place.
	#
	#   _n_        which occurrence, counted backwards
	#   returns    nothing; the list changes
	#   see        ReplaceNextNthOccurrence
	def ReplacePreviousNthOccurrence(_n_, pItem, pNewItem, pnStartingAt)
		This.ReplacePreviousNthOccurrenceCS(_n_, pItem, pNewItem, pnStartingAt, 1)

	# Plural "ST" forms: panList holds INDICES into the list of an
	# item's previous/next occurrences (relative to :StartingAt). E.g.
	# panList=[3,1] picks the 3rd and 1st previous occurrence. The
	# rationale (from the monolith): anAllPos[panList[i]].

	def FindPreviousNthOccurrencesCS(panList, pItem, pnStartingAt, pCaseSensitive)
		if isList(pItem) and ring_len(pItem) = 2 and isString(pItem[1]) and
		   (pItem[1] = :of or pItem[1] = :Of)
			pItem = pItem[2]
		ok
		if isList(pnStartingAt) and ring_len(pnStartingAt) = 2 and isString(pnStartingAt[1]) and
		   (pnStartingAt[1] = :startingat or pnStartingAt[1] = :StartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		_oFpnSec_ = This.SectionQ(1, pnStartingAt - 1)
		_anFpnAll_ = _oFpnSec_.FindAllCS(pItem, pCaseSensitive)
		_anFpnRes_ = []
		_nFpnL_ = ring_len(panList)
		for iFpn = 1 to _nFpnL_
			_anFpnRes_ + _anFpnAll_[ panList[iFpn] ]
		next
		return _anFpnRes_

	# Returns the positions of the given ranks of next occurrences of the item after a given position.
	#
	#   panList    the ranks of the occurrences wanted
	#   returns    a list of positions
	#   see        FindNextNth
	def FindNextNthOccurrencesCS(panList, pItem, pnStartingAt, pCaseSensitive)
		if isList(pItem) and ring_len(pItem) = 2 and isString(pItem[1]) and
		   (pItem[1] = :of or pItem[1] = :Of)
			pItem = pItem[2]
		ok
		if isList(pnStartingAt) and ring_len(pnStartingAt) = 2 and isString(pnStartingAt[1]) and
		   (pnStartingAt[1] = :startingat or pnStartingAt[1] = :StartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		_oFnnSec_ = This.SectionQ(pnStartingAt + 1, This.NumberOfItems())
		_anFnnRel_ = _oFnnSec_.FindAllCS(pItem, pCaseSensitive)
		_anFnnAll_ = []
		_nFnnRel_ = ring_len(_anFnnRel_)
		for iFnn = 1 to _nFnnRel_
			_anFnnAll_ + ( _anFnnRel_[iFnn] + pnStartingAt )
		next
		_anFnnRes_ = []
		_nFnnL_ = ring_len(panList)
		for iFnn = 1 to _nFnnL_
			_anFnnRes_ + _anFnnAll_[ panList[iFnn] ]
		next
		return _anFnnRes_

	def ReplacePreviousNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)
		if isList(pNewItem) and ring_len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or pNewItem[1] = :By)
			pNewItem = pNewItem[2]
		ok
		_anRpnPos_ = This.FindPreviousNthOccurrencesCS(panList, pItem, pnStartingAt, 1)
		This.ReplaceItemsAtPositions(_anRpnPos_, pNewItem)

		# Replaces the given ranks of occurrences of the item before a position by a new item, in place.
		#
		#   panList    the ranks of the occurrences to replace
		#   returns    nothing; the list changes
		#   see        ReplacePreviousNthOccurrence
		def ReplacePreviousNthOccurrences(panList, pItem, pNewItem, pnStartingAt)
			This.ReplacePreviousNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)

	# Replaces the given ranks of occurrences of the item after a position by a new item, in place.
	#
	#   panList    the ranks of the occurrences to replace
	#   returns    nothing; the list changes
	#   see        ReplaceNextNthOccurrence
	def ReplaceNextNthOccurrences(panList, pItem, pNewItem, pnStartingAt)
		if isList(pNewItem) and ring_len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or pNewItem[1] = :By)
			pNewItem = pNewItem[2]
		ok
		_anRnnPos_ = This.FindNextNthOccurrencesCS(panList, pItem, pnStartingAt, 1)
		This.ReplaceItemsAtPositions(_anRnnPos_, pNewItem)

		def ReplaceNextNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrences(panList, pItem, pNewItem, pnStartingAt)

	# Returns a copy with the given ranks of next occurrences of the item after a position replaced; the list is unchanged.
	#
	#   panList    the ranks of the occurrences to replace
	#   returns    a list of items
	#   see        ReplaceNextNthOccurrences
	#@ aka  Passive (non-mutating) forms: return a fresh content list.
	def NextNthOccurrencesReplaced(panList, pItem, pNewItem, pnStartingAt)
		_oNnrCopy_ = This.Copy()
		_oNnrCopy_.ReplaceNextNthOccurrences(panList, pItem, pNewItem, pnStartingAt)
		return _oNnrCopy_.Content()

	# Returns a copy with the given ranks of previous occurrences of the item before a position replaced; the list is unchanged.
	#
	#   panList    the ranks of the occurrences to replace
	#   returns    a list of items
	#   see        ReplacePreviousNthOccurrences
	def PreviousNthOccurrencesReplaced(panList, pItem, pNewItem, pnStartingAt)
		_oPnrCopy_ = This.Copy()
		_oPnrCopy_.ReplacePreviousNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)
		return _oPnrCopy_.Content()

	# Replaces every item by one new item, in place; :With = item is accepted.
	#
	#   pNewItem   the item that every position receives
	#   returns    nothing; the list changes
	#   see        ReplaceAtPositions
	#@ aka  Replace every item by a single new one: ReplaceAllItems(:With = newItem) or ReplaceAllItems(newItem).
	def ReplaceAllItems(pNewItem)
		if isList(pNewItem) and len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or pNewItem[1] = :By)
			pNewItem = pNewItem[2]
		ok
		_oRplAI_ = new stzListReplacer(This)
		_oRplAI_.ReplaceAllItems(pNewItem)
		This._SetContent(_oRplAI_.Content())

		def ReplaceAllItemsQ(pNewItem)
			This.ReplaceAllItems(pNewItem)
			return This

	def ReplaceFirstCS(pItem, pNewItem, pCaseSensitive)
		_oRplF_ = new stzListReplacer(This)
		_oRplF_.ReplaceFirstOccurrenceCS(pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRplF_.Content())

	# Replaces the first occurrence of the item by a new item, in place.
	#
	#   returns    nothing; the list changes
	#   see        ReplaceLast, ReplaceNth
	def ReplaceFirst(pItem, pNewItem)
		This.ReplaceFirstCS(pItem, pNewItem, 1)

	def ReplaceLastCS(pItem, pNewItem, pCaseSensitive)
		_oRplL_ = new stzListReplacer(This)
		_oRplL_.ReplaceLastOccurrenceCS(pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRplL_.Content())

	# Replaces the last occurrence of the item by a new item, in place.
	#
	#   returns    nothing; the list changes
	#   see        ReplaceFirst
	def ReplaceLast(pItem, pNewItem)
		This.ReplaceLastCS(pItem, pNewItem, 1)

	def ReplaceManyByManyCS(paItems, paNewItems, pCaseSensitive)
		_oRplM_ = new stzListReplacer(This)
		_oRplM_.ReplaceManyByManyCS(paItems, paNewItems, pCaseSensitive)
		This._SetContent(_oRplM_.Content())

	# Replaces each of several items by the item at the same place in a second list, in place.
	#
	#   paItems      the items to replace
	#   paNewItems   the replacements, in the same order
	#   returns      nothing; the list changes
	#   see          Replace, ReplaceByMany
	#   example      o1.ReplaceManyByMany([ "a", "b" ], [ "1", "2" ])
	#                ? @@( o1.Content() )
	#                #--> [ "1", "2", "c", "2" ]
	def ReplaceManyByMany(paItems, paNewItems)
		This.ReplaceManyByManyCS(paItems, paNewItems, 1)

	def ReplaceManyByManyXT(paItems, paNewItems)
		_oRplMxt_ = new stzListReplacer(This)
		_oRplMxt_.ReplaceManyByManyXT(paItems, paNewItems)
		This._SetContent(_oRplMxt_.Content())

	# Replaces the items from position n1 to position n2 by one new item, in place.
	#
	#   _n1_       the first position of the section
	#   _n2_       the last position of the section
	#   pNewItem   the item that takes its place
	#   returns    nothing; the list changes
	#   see        Section, ReplaceAt
	#   example    o1.ReplaceSection(2, 3, "Z")
	#              ? @@( o1.Content() )
	#              #--> [ "a", "Z", "b" ]
	def ReplaceSection(_n1_, _n2_, pNewItem)
		_oRpS_ = new stzListReplacer(This)
		_oRpS_.ReplaceSection(_n1_, _n2_, pNewItem)
		This._SetContent(_oRpS_.Content())

		def ReplaceSectionQ(_n1_, _n2_, pNewItem)
			This.ReplaceSection(_n1_, _n2_, pNewItem)
			return This

	# Replaces the items from one position to another by the new items, in place.
	#
	#   _n1_       the position of the first item
	#   _n2_       the position of the last item
	#   returns    nothing; the list changes
	#   see        ReplaceSection
	def ReplaceSectionByMany(_n1_, _n2_, paNewItems)
		_oRpSM_ = new stzListReplacer(This)
		_oRpSM_.ReplaceSectionByMany(_n1_, _n2_, paNewItems)
		This._SetContent(_oRpSM_.Content())

		def ReplaceSectionByManyQ(_n1_, _n2_, paNewItems)
			This.ReplaceSectionByMany(_n1_, _n2_, paNewItems)
			return This

	# Replaces the item at position n by the new item, in place.
	#
	#   _n_        the position, or a list of positions
	#   pNewItem   the item to put there; :With = item is accepted
	#   returns    nothing; the list changes
	#   see        Replace, ReplaceSection
	#   example    o1.ReplaceAt(2, "X")
	#              ? @@( o1.Content() )
	#              #--> [ "a", "X", "c", "b" ]
	#@ aka  Positional replace: swap whatever lives at position n with pNewItem. Mirrors AddItemAt / InsertAt / RemoveAt naming.
	def ReplaceAt(_n_, pNewItem)
		if isList(pNewItem) and len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :by or pNewItem[1] = :By or pNewItem[1] = :with or
		    pNewItem[1] = :With or pNewItem[1] = :using or pNewItem[1] = :Using)
			pNewItem = pNewItem[2]
		ok
		# A LIST of positions replaces each of those positions (ReplaceAnyAt).
		if isList(_n_)
			_nRaLen_ = len(_n_)
			for _iRa_ = 1 to _nRaLen_
				if _n_[_iRa_] >= 1 and _n_[_iRa_] <= len(@aContent)
					This._InvalidateEngine()   # in-place @aContent mutation below
					@aContent[ _n_[_iRa_] ] = pNewItem
				ok
			next
			return
		ok
		if _n_ >= 1 and _n_ <= len(@aContent)
			This._InvalidateEngine()   # in-place @aContent mutation below
			@aContent[_n_] = pNewItem
		ok

		def ReplaceAtQ(_n_, pNewItem)
			This.ReplaceAt(_n_, pNewItem)
			return This

		# Replaces the item at position n by a new item, in place.
		#
		#   _n_        the position
		#   returns    nothing; the list changes
		#   see        ReplaceItemAtPosition
		def UpdateAt(_n_, pNewItem)
			This.ReplaceAt(_n_, pNewItem)

		# Replaces the item at position n by a new item, in place.
		#
		#   _n_        the position
		#   returns    nothing; the list changes
		#   see        ReplaceItemAtPosition
		def SetItemAt(_n_, pNewItem)
			This.ReplaceAt(_n_, pNewItem)

		# Replaces the item at position n by a new item, in place.
		#
		#   _n_        the position
		#   returns    nothing; the list changes
		#   see        ReplaceItemAtPosition
		def ReplaceAnyItemAt(_n_, pNewItem)
			This.ReplaceAt(_n_, pNewItem)

		# Replaces the item at position n by a new item, in place.
		#
		#   _n_        the position
		#   returns    nothing; the list changes
		#   see        ReplaceAnyItemAt
		def ReplaceItemAtPosition(_n_, pNewItem)
			This.ReplaceAt(_n_, pNewItem)

	  #=============================================#
	 #  POSITIONAL REPLACE DELEGATIONS (Replacer)  #
	#=============================================#

	# Replaces the items at the given positions by a new item, in place.
	#
	#   returns    nothing; the list changes
	#   see        ReplaceAtPositions
	def ReplaceAnyItemAtPositions(panPos, pNewItem)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceAnyItemAtPositions(panPos, pNewItem)
		This._SetContent(_o_.Content())

		# Replaces every item at the given positions by the new item, in place.
		#
		#   returns    nothing; the list changes
		#   see        ReplaceItemsAtPositions
		def ReplaceAnyItemsAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

		# Replaces every item at the given positions by the new item, in place.
		#
		#   returns    nothing; the list changes
		#   see        ReplaceAnyItemsAtPositions
		def ReplaceItemsAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

		# Replaces the items at the given positions by a new item, in place.
		#
		#   returns    nothing; the list changes
		#   see        ReplaceItemsAtPositions
		def ReplaceAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

	# Replaces the given item by a new item at each of the given positions where it stands, in place.
	#
	#   returns    nothing; the list changes
	#   see        ReplaceItemsAtPositions
	def ReplaceThisItemAtPositions(panPos, pItem, pNewItem)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceThisItemAtPositions(panPos, pItem, pNewItem)
		This._SetContent(_o_.Content())

	# Replaces the given item by a new item at position n, in place, when the item stands there.
	#
	#   _n_        the position
	#   returns    nothing; the list changes
	#   see        ReplaceItemAtPositions
	def ReplaceThisItemAt(_n_, pItem, pNewItem)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceThisItemAt(_n_, pItem, pNewItem)
		This._SetContent(_o_.Content())

	# Replaces, at the given positions, the items that are among the given ones by the new item, in place.
	#
	#   returns    nothing; the list changes
	#   see        ReplaceItemsAtPositions
	def ReplaceTheseItemsAtPositions(panPos, paItems, pNewItem)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceTheseItemsAtPositions(panPos, paItems, pNewItem)
		This._SetContent(_o_.Content())

	def ReplaceMany(paItems, pNewItem)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceMany(paItems, pNewItem)
		This._SetContent(_o_.Content())

	# Replaces each occurrence of the item by the items of a list in turn, in place.
	#
	#   pItem        the item to replace
	#   paNewItems   the replacements, used one per occurrence
	#   returns      nothing; the list changes
	#   see          Replace, ReplaceManyByMany
	#   example      o1.ReplaceByMany("b", [ "1", "2" ])
	#                ? @@( o1.Content() )
	#                #--> [ "a", "1", "c", "2" ]
	def ReplaceByMany(pItem, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceByMany(pItem, paNewItems)
		This._SetContent(_o_.Content())

	def ReplaceByManyXT(pItem, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceByManyXT(pItem, paNewItems)
		This._SetContent(_o_.Content())

		# Replaces the occurrences of the item by the new items, one by one, in place.
		#
		#   returns    nothing; the list changes
		#   see        ReplaceOccurrencesByMany
		def ReplaceItemByManyXT(pItem, paNewItems)
			This.ReplaceByManyXT(pItem, paNewItems)

	# Replaces the items at the given positions by the new items, one by one, in place.
	#
	#   returns    nothing; the list changes
	#   see        ReplaceItemAtPositionsByMany
	def ReplaceOccurrencesByMany(panPos, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceOccurrencesByMany(panPos, paNewItems)
		This._SetContent(_o_.Content())

	# Replace the chosen occurrences cycling through the given
	# replacements (mutating).
	def ReplaceOccurrencesByManyXT(panPos, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceOccurrencesByManyXT(panPos, paNewItems)
		This._SetContent(_o_.Content())

	# Replaces the given item, where it stands at the given positions, by the new items, in place.
	#
	#   pItem      the item that must stand at each position
	#   returns    nothing; the list changes
	#   see        ReplaceItemAtPositions
	def ReplaceItemAtPositionsByMany(panPos, pItem, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceItemAtPositionsByMany(panPos, pItem, paNewItems)
		This._SetContent(_o_.Content())

	def ReplaceItemAtPositionsByManyXT(panPos, pItem, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceItemAtPositionsByManyXT(panPos, pItem, paNewItems)
		This._SetContent(_o_.Content())

	# Replaces, at the given positions, the items that are among the given ones by the new items, one by one, in place.
	#
	#   returns    nothing; the list changes
	#   see        ReplaceOccurrencesByMany
	def ReplaceTheseItemsAtPositionsByMany(panPos, paItems, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceTheseItemsAtPositionsByMany(panPos, paItems, paNewItems)
		This._SetContent(_o_.Content())

	def ReplaceTheseItemsAtPositionsByManyXT(panPos, paItems, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceTheseItemsAtPositionsByManyXT(panPos, paItems, paNewItems)
		This._SetContent(_o_.Content())

	# Replaces the items at the given positions by the new items, one by one, in place.
	#
	#   returns    nothing; the list changes
	#   see        ReplaceOccurrencesByMany
	def ReplaceAnyItemAtPositionsByMany(panPos, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceAnyItemAtPositionsByMany(panPos, paNewItems)
		This._SetContent(_o_.Content())

		# Replaces the items at the given positions by the new items, one by one, in place.
		#
		#   returns    nothing; the list changes
		#   see        ReplaceOccurrencesByMany
		def ReplaceAnyItemsAtPositionsByMany(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByMany(panPos, paNewItems)

	def ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)
		This._SetContent(_o_.Content())

		def ReplaceAnyItemsAtPositionsByManyXT(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)

		# Replaces the items at the given positions by the new items, one by one, in place.
		#
		#   returns    nothing; the list changes
		#   see        ReplaceOccurrencesByMany
		def ReplaceAtByManyXT(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)



	def ReplaceW(pWhere, pBy)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceW(pWhere, pBy)
		This._SetContent(_o_.Content())

		# Replaces the items that meet the W condition by the new value, in place.
		#
		#   pWhere     the W condition
		#   pBy        the value that takes their place
		#   returns    nothing; the list changes
		#   see        FindW
		def ReplaceItemsW(pWhere, pBy)
			This.ReplaceW(pWhere, pBy)

	# Replaces the nth occurrence of the item after a given position by a new item, in place.
	#
	#   _n_        which occurrence, counted from the starting position
	#   returns    nothing; the list changes
	#   see        ReplaceNth
	def ReplaceNextNthOccurrence(_n_, pItem, pNewItem, pnStartingAt)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceNextNthOccurrence(_n_, pItem, pNewItem, pnStartingAt)
		This._SetContent(_o_.Content())

		def ReplaceNextNthOccurrenceST(_n_, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrence(_n_, pItem, pNewItem, pnStartingAt)

		# Replaces the nth occurrence of the item after a given position by a new item, in place.
		#
		#   _n_        which occurrence, counted from the starting position
		#   returns    nothing; the list changes
		#   see        ReplaceNextNthOccurrence
		def ReplaceNthNextOccurrenceST(_n_, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrence(_n_, pItem, pNewItem, pnStartingAt)

	  #=============================================#
	 #  STRINGIFY DELEGATION (via stzListStringify) #
	#=============================================#

	# Turns every item into text, in place; a list item becomes its written form.
	#
	#   returns    nothing; the list changes
	#   see        StringifyAndReplace
	def Stringify()
		_oStfy_ = new stzListStringify(This)
		_oStfy_.Stringify()
		This._SetContent(_oStfy_.Content())

		def StringifyQ()
			This.Stringify()
			return This

	# Returns the list written as text in its computable form, such as "[ 1, 2 ]".
	#
	#   returns    a string
	#   see        ToListInAStringInShortForm
	#@ aka  ToListInAString: the content rendered as a "[ ... ]" string (computable form). Delegates to stzListStringify, like the rest of this section.
	def ToListInAString()
		_oTlasStfy_ = new stzListStringify(This)
		return _oTlasStfy_.ToListInAString()

	# Returns the list written as text in its short form.
	#
	#   returns    a string
	#   see        ToListInAString
	def ToListInAStringInShortForm()
		_oTlsfStfy_ = new stzListStringify(This)
		return _oTlsfStfy_.ToListInAStringInShortForm()

		def ToListInShortForm()
			return This.ToListInAStringInShortForm()

	# Turns every item into text, then replaces a text by another inside each, in place.
	#
	#   pSubStr    the text to replace
	#   pWith      the text that takes its place
	#   returns    nothing; the list changes
	#   see        Stringify
	#@ aka  StringifyAndReplace: Stringify the content, then replace every occurrence of pItem with the supplied value (pWith). pWith accepts the :With named-param form or a bare string. StringifyAndReplaceQ(item, with) returns This. XT variant is just an alias for the moment -- the original Softanza distinguished "internal-staff" semantics, but they collapse to the same engine path here.
	def StringifyAndReplace(pSubStr, pWith)
		# Stringify every item, then SUBSTRING-replace pSubStr with pWith in
		# each (monolith semantics: the params are substrings, not whole
		# items). The replace itself is the engine-backed, UTF-8-safe
		# StzReplace -- so e.g. the comma inside a stringified sublist is
		# rewritten, not just items that equal the needle.
		if isList(pWith) and len(pWith) = 2 and isString(pWith[1])
			pWith = pWith[2]
		ok
		This.Stringify()
		_aData_ = @aContent
		_nLen_ = len(_aData_)
		for _i_ = 1 to _nLen_
			if isString(_aData_[_i_])
				_aData_[_i_] = StzReplace(_aData_[_i_], pSubStr, pWith)
			ok
		next
		This._SetContent(_aData_)

		def StringifyAndReplaceQ(pItem, pWith)
			This.StringifyAndReplace(pItem, pWith)
			return This

		def StringifyAndReplaceXT(pItem, pWith)
			This.StringifyAndReplace(pItem, pWith)

		def StringifyAndReplaceXTQ(pItem, pWith)
			This.StringifyAndReplace(pItem, pWith)
			return This

	# Turns every item into lowercase text, in place.
	#
	#   returns    nothing; the list changes
	#   see        StringifyUppercase
	#@ aka  StringifyLowercase / StringifyUppercase / StringifyAndLower / StringifyAndUpper -- Stringify then map case. Used by misc narrative tests that need a uniform-case string list.
	def StringifyLowercase()
		This.Stringify()
		_aData_ = @aContent
		_nLen_ = len(_aData_)
		for _i_ = 1 to _nLen_
			if isString(_aData_[_i_])
				_aData_[_i_] = lower(_aData_[_i_])
			ok
		next
		This._SetContent(_aData_)

		# Turns every item into lowercase text, in place.
		#
		#   returns    nothing; the list changes
		#   see        StringifyAndUpper
		def StringifyAndLower()
			This.StringifyLowercase()

		def StringifyAndLowerQ()
			This.StringifyLowercase()
			return This

	# Turns every item into uppercase text, in place.
	#
	#   returns    nothing; the list changes
	#   see        StringifyLowercase
	def StringifyUppercase()
		This.Stringify()
		_aData_ = @aContent
		_nLen_ = len(_aData_)
		for _i_ = 1 to _nLen_
			if isString(_aData_[_i_])
				_aData_[_i_] = upper(_aData_[_i_])
			ok
		next
		This._SetContent(_aData_)

		# Turns every item into uppercase text, in place.
		#
		#   returns    nothing; the list changes
		#   see        StringifyAndLower
		def StringifyAndUpper()
			This.StringifyUppercase()

		def StringifyAndUpperQ()
			This.StringifyUppercase()
			return This

	# Turns every item into lowercase text, then replaces a text by another inside each, in place.
	#
	#   pWith      the text that takes its place
	#   returns    nothing; the list changes
	#   see        StringifyAndReplace
	#@ aka  StringifyLowercaseAndReplace / StringifyUppercaseAndReplace -- stringify + lower (or upper) every string item, THEN replace every occurrence of pItem with pWith. XT variant is alias.
	def StringifyLowercaseAndReplace(pItem, pWith)
		if isList(pWith) and len(pWith) = 2 and isString(pWith[1])
			pWith = pWith[2]
		ok
		This.StringifyLowercase()
		_aData_ = @aContent
		_nLen_ = len(_aData_)
		for _i_ = 1 to _nLen_
			if isString(_aData_[_i_])
				_aData_[_i_] = StzReplace(_aData_[_i_], pItem, pWith)
			ok
		next
		This._SetContent(_aData_)

		def StringifyLowercaseAndReplaceQ(pItem, pWith)
			This.StringifyLowercaseAndReplace(pItem, pWith)
			return This

		def StringifyLowercaseAndReplaceXT(pItem, pWith)
			This.StringifyLowercaseAndReplace(pItem, pWith)

		def StringifyLowercaseAndReplaceXTQ(pItem, pWith)
			This.StringifyLowercaseAndReplace(pItem, pWith)
			return This

	# Turns every item into uppercase text, then replaces a text by another inside each, in place.
	#
	#   pWith      the text that takes its place
	#   returns    nothing; the list changes
	#   see        StringifyLowercaseAndReplace
	def StringifyUppercaseAndReplace(pItem, pWith)
		if isList(pWith) and len(pWith) = 2 and isString(pWith[1])
			pWith = pWith[2]
		ok
		This.StringifyUppercase()
		_aData_ = @aContent
		_nLen_ = len(_aData_)
		for _i_ = 1 to _nLen_
			if isString(_aData_[_i_])
				_aData_[_i_] = StzReplace(_aData_[_i_], pItem, pWith)
			ok
		next
		This._SetContent(_aData_)

		def StringifyUppercaseAndReplaceQ(pItem, pWith)
			This.StringifyUppercaseAndReplace(pItem, pWith)
			return This

		def StringifyUppercaseAndReplaceXT(pItem, pWith)
			This.StringifyUppercaseAndReplace(pItem, pWith)

		def StringifyUppercaseAndReplaceXTQ(pItem, pWith)
			This.StringifyUppercaseAndReplace(pItem, pWith)
			return This

	  #=================================================#
	 #  CONTAINS DELEGATIONS (via stzListComparator)    #
	#=================================================#

	def ContainsOneOfTheseCS(paItems, pCaseSensitive)
		_oCmpCont_ = new stzListComparator(This)
		return _oCmpCont_.ContainsOneOfTheseCS(paItems, pCaseSensitive)

	# TRUE if the list holds at least one of the given items.
	#
	#   paItems    the items to look for
	#   returns    TRUE or FALSE
	#   see        Contains
	#   example    ? o1.ContainsOneOfThese([ "x", "c" ])
	#              #--> TRUE
	#              ? o1.ContainsOneOfThese([ "x", "y" ])
	#              #--> FALSE
	def ContainsOneOfThese(paItems)
		return This.ContainsOneOfTheseCS(paItems, 1)

		# TRUE if at least one of the two given items occurs.
		#
		#   pItem1     the first item
		#   pItem2     the second item
		#   returns    TRUE or FALSE
		#   see        ContainsBoth
		def ContainsEither(pItem1, pItem2)
			# XOR: TRUE when EXACTLY ONE of the two items is present
			# (:or names the second). For "contains any of a list", use
			# ContainsOneOfThese(paItems).
			return This.ContainsEitherCS(pItem1, pItem2, 1)

		def ContainsEitherCS(pItem1, pItem2, pCaseSensitive)
			if isList(pItem2) and IsOrNamedParamList(pItem2)
				pItem2 = pItem2[2]
			ok
			_b1_ = This.ContainsCS(pItem1, pCaseSensitive)
			_b2_ = This.ContainsCS(pItem2, pCaseSensitive)
			if (_b1_ = 1 and _b2_ = 0) or (_b1_ = 0 and _b2_ = 1)
				return 1
			else
				return 0
			ok

	def ContainsAllOfTheseCS(paItems, pCaseSensitive)
		_oCmpAll_ = new stzListComparator(This)
		return _oCmpAll_.ContainsAllOfTheseCS(paItems, pCaseSensitive)

	# TRUE if every one of the given items occurs in the list.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsEach, ContainsThese
	def ContainsAllOfThese(paItems)
		return This.ContainsAllOfTheseCS(paItems, 1)

	  #================================================#
	 #  CHECKER DELEGATIONS (via stzListChecker)       #
	#================================================#

	# TRUE if every item is of the given type, such as "number".
	#
	#   returns    TRUE or FALSE
	#   see        IsListOf
	def AllItemsAreOfType(pcType)
		_oChkType_ = new stzListChecker(This)
		return _oChkType_.AllItemsAreOfType(pcType)

		def EachItemIsA(pcType)
			return This.AllItemsAreOfType(pcType)

		def EachItemIs(pcType)
			return This.AllItemsAreOfType(pcType)

	# TRUE if some item is an empty string.
	#
	#   returns    TRUE or FALSE
	#   see        FindEmptyStrings
	def ContainsEmptyStrings()
		_aEsContent_ = @aContent
		_nEsLen_ = len(_aEsContent_)
		for _iEs_ = 1 to _nEsLen_
			if isString(_aEsContent_[_iEs_]) and _aEsContent_[_iEs_] = ""
				return 1
			ok
		next
		return 0

	# Returns the positions of the items that are empty strings.
	#
	#   returns    a list of positions
	#   see        ContainsEmptyStrings
	def FindEmptyStrings()
		_pFesList_ = This._EngineListFromContent()
		if _pFesList_ = ""
			return []
		ok
		_pFesResult_ = StzEngineListFindEmptyStrings(_pFesList_)
		StzEngineListFree(_pFesList_)
		if _pFesResult_ = ""
			return []
		ok
		_aFesOut_ = StzEngineListContentToRingList(_pFesResult_)
		StzEngineListFree(_pFesResult_)
		return _aFesOut_

	# Returns how many items are empty strings.
	#
	#   returns    a number
	#   see        FindEmptyStrings
	def CountEmptyStrings()
		_pCesList_ = This._EngineListFromContent()
		if _pCesList_ = ""
			return 0
		ok
		_nCesCount_ = StzEngineListCountEmptyStrings(_pCesList_)
		StzEngineListFree(_pCesList_)
		return _nCesCount_

	# Replaces every empty string by a new item, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveEmptyStrings
	def ReplaceEmptyStrings(pNewItem)
		if CheckParams()
			if isList(pNewItem) and len(pNewItem) = 2 and
			   isString(pNewItem[1]) and pNewItem[1] = :With
				pNewItem = pNewItem[2]
			ok
		ok

		_aResContent_ = @aContent
		_nResLen_ = len(_aResContent_)
		for _iRes_ = 1 to _nResLen_
			if isString(_aResContent_[_iRes_]) and _aResContent_[_iRes_] = ""
				_aResContent_[_iRes_] = pNewItem
			ok
		next
		This._SetContent(_aResContent_)

	# Removes the items that are empty strings, in place.
	#
	#   returns    nothing; the list changes
	#   see        ContainsEmptyStrings
	def RemoveEmptyStrings()
		_anRmesPos_ = This.FindEmptyStrings()
		_nRmesLen_ = len(_anRmesPos_)
		if _nRmesLen_ = 0 return ok
		# Remove from end to preserve indices
		for _iRmes_ = _nRmesLen_ to 1 step -1
			This._InvalidateEngine()   # in-place @aContent mutation below
			ring_remove(@aContent, _anRmesPos_[_iRmes_])
		next

	  #=========================================#
	 #  ENGINE-BACKED OPERATIONS (Zig engine)  #
	#=========================================#

	#-- Builds an engine list handle from @aContent.
	#   Returns a C pointer to a StzList, or NULL on failure.

	def _EngineListFromContent()
		return StzEngineMarshalList(@aContent)

	#-- Reads engine list contents back into a Ring list

	def _ContentFromEngineList(_pList_)
		return StzEngineListContentToRingList(_pList_)

	  #-----------------------------------------------------#
	 #  ENGINE-RESIDENCY CACHE ACCESS (Model A + keystone) #
	#-----------------------------------------------------#
	#
	#  @aContent is ALWAYS the source of truth. @pEngineGen indexes the
	#  bounded engine-side residency cache, which OWNS the marshalled handle.
	#  On a cache miss (evicted under pressure) _Engine() re-marshals from
	#  @aContent. This is what makes residency safe without object destructors.

	#-- Canonical content getter (Model A: @aContent is never stale).
	def _Content()
		return @aContent

	#-- Ring-side setter: @aContent becomes truth; drop any cached handle.
	def _SetContent(paRing)
		# Enforced per-object constraints guard the single update point
		This._NNLGuardUpdate(paRing)
		@aContent = paRing
		This._InvalidateEngine()
		return This

	#-- Live engine handle id for the current content. Reuses the warm cached
	#   handle if still resident; otherwise marshals once and registers it.
	def _Engine()
		if @pEngineGen != 0
			_hEng_ = StzEngineListCacheGet(@pEngineGen)
			if _hEng_ != 0
				return _hEng_
			ok
			@pEngineGen = 0   # was evicted under cache pressure
		ok
		_hEng_ = StzEngineMarshalList(@aContent)
		@pEngineGen = StzEngineListCacheRegister(_hEng_)
		return _hEng_

	#-- Drop the cached handle (engine frees it + releases its handle slot).
	#   Called by every write so the cache can never go stale.
	def _InvalidateEngine()
		if @pEngineGen != 0
			StzEngineListCacheInvalidate(@pEngineGen)
			@pEngineGen = 0
		ok
		return This

	#-- Adopt an engine result handle as the new content: materialize @aContent
	#   (Model A truth) and keep the handle warm in the cache. Used by ops that
	#   RETURN a new handle which becomes the content (dedup/flatten/merge).
	def _AdoptEngine(pHandle)
		This._InvalidateEngine()
		@aContent = StzEngineListContentToRingList(pHandle)
		@pEngineGen = StzEngineListCacheRegister(pHandle)
		return This

	#-- Resync @aContent after an engine op mutated the cached handle in place
	#   (e.g. sort/reverse). Keeps the cache warm (gen unchanged).
	def _RefreshFromEngine()
		if @pEngineGen != 0
			_hEng_ = StzEngineListCacheGet(@pEngineGen)
			if _hEng_ != 0
				@aContent = StzEngineListContentToRingList(_hEng_)
			ok
		ok
		return This

	  #------------------------------#
	 #  SORTING (engine-backed)     #
	#------------------------------#

	def SortCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_pList_ = This._Engine()
		if _pList_ = "" return ok

		StzEngineListSortCS(_pList_, pCaseSensitive)
		This._RefreshFromEngine()

		def SortCSQ(pCaseSensitive)
			This.SortCS(pCaseSensitive)
			return This

	# Sorts the items by a key expression, in place.
	#
	#   returns    nothing; the list changes
	#   see        SortInAscending
	#@ aka  -- Sort by a key expression (engine-backed via the W DSL).
	def SortBy(pcExpr)
		pcExpr = _StzStripBraces(pcExpr)
		_pList_ = This._Engine()
		StzEngineListSortByExpr(_pList_, pcExpr, 1)
		This._RefreshFromEngine()

		def SortByQ(pcExpr)
			This.SortBy(pcExpr)
			return This

	# Sorts the items by the key expression, from the greatest to the least, in place.
	#
	#   returns    nothing; the list changes
	#   see        SortBy
	#@ aka  Sort the items by the given expression, descending (mutating).
	def SortByDescending(pcExpr)
		pcExpr = _StzStripBraces(pcExpr)
		_pList_ = This._Engine()
		StzEngineListSortByExpr(_pList_, pcExpr, 0)
		This._RefreshFromEngine()

	# Returns a copy sorted by the key expression; the list is unchanged.
	#
	#   returns    a list of items
	#   see        SortBy
	#@ aka  -- non-mutating: return the sorted-by-key copy
	def SortedBy(pcExpr)
		_oSb_ = new stzList(This.Content())
		_oSb_.SortBy(pcExpr)
		return _oSb_.Content()

	# Sorts the items from the least to the greatest, in place.
	#
	#   returns    nothing; the list changes
	#   see        SortDown
	#@ aka  Same as Sort: ascending, in place (mutating).
	def SortUp()
		This.Sort()

		def SortUpQ()
			This.Sort()
			return This

	# Sorts the items from the greatest to the least, in place.
	#
	#   returns    nothing; the list changes
	#   see        SortInDescending, SortUp
	#@ aka  Same as SortInDescending: descending, in place (mutating).
	def SortDown()
		This.SortInDescending()

		def SortDownQ()
			This.SortInDescending()
			return This

	# Sorts the items in ascending order, in place.
	#
	#   returns    nothing; the list changes
	#   see        Sorted, SortInAscending
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              o1.Sort()
	#              ? @@( o1.Content() )
	#              #--> [ 1, 1, 3, 4, 5 ]
	#@ aka  order, arrange, rank, ascending, smallest to largest
	#@ aka  Sort the items in ascending order in place (mutating). For a copy, use Sorted.
	def Sort()
		This.SortCS(1)

		def SortQ()
			This.Sort()
			return This

		# Sorts the items in ascending order, in place, as Sort does.
		#
		#   returns    nothing; the list changes
		#   see        Sort, Sorted
		#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
		#              o1.SortInAscending()
		#              ? @@( o1.Content() )
		#              #--> [ 1, 1, 3, 4, 5 ]
		#@ aka  Word-order aliases used by narrative tests.
		def SortInAscending()
			This.Sort()

		def SortInAscendingQ()
			This.Sort()
			return This

		# Sorts the items from the least to the greatest, in place.
		#
		#   returns    nothing; the list changes
		#   see        SortUp
		def SortAscending()
			This.Sort()

		def SortAscendingQ()
			This.Sort()
			return This

	def SortedCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_pList_ = This._EngineListFromContent()
		if _pList_ = "" return [] ok

		StzEngineListSortCS(_pList_, pCaseSensitive)
		_aResult_ = StzEngineListContentToRingList(_pList_)
		StzEngineListFree(_pList_)
		return _aResult_

	# Returns a copy of the list sorted in ascending order; the list is unchanged.
	#
	#   returns    a list
	#   see        Sort, SortedInDescending, IsSortedInAscending
	#   example    ? @@( o1.Sorted() )
	#              #--> [ "a", "b", "b", "c" ]
	#@ aka  An ascending-sorted copy of the list; the original is unchanged.
	def Sorted()
		return This.SortedCS(1)

	def SortInDescendingCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_pList_ = This._Engine()
		if _pList_ = "" return ok

		StzEngineListSortDescendingCS(_pList_, pCaseSensitive)
		This._RefreshFromEngine()

		def SortInDescendingCSQ(pCaseSensitive)
			This.SortInDescendingCS(pCaseSensitive)
			return This

	# Sorts the items in descending order, in place.
	#
	#   returns    nothing; the list changes
	#   see        SortedInDescending, Sort
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              o1.SortInDescending()
	#              ? @@( o1.Content() )
	#              #--> [ 5, 4, 3, 1, 1 ]
	#@ aka  Sort the items in descending order in place (mutating). For a copy, use SortedInDescending.
	def SortInDescending()
		This.SortInDescendingCS(1)

		def SortInDescendingQ()
			This.SortInDescending()
			return This

	# A descending-sorted copy of the list; the original is unchanged.
	def SortedInDescendingCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_pList_ = This._EngineListFromContent()
		if _pList_ = "" return [] ok

		StzEngineListSortDescendingCS(_pList_, pCaseSensitive)
		_aResult_ = StzEngineListContentToRingList(_pList_)
		StzEngineListFree(_pList_)
		return _aResult_

	# Returns a copy of the list sorted in descending order; the list is unchanged.
	#
	#   returns    a list
	#   see        Sorted, IsSortedInDescending
	#   example    ? @@( o1.SortedInDescending() )
	#              #--> [ "c", "b", "b", "a" ]
	def SortedInDescending()
		return This.SortedInDescendingCS(1)

	  #------------------------------#
	 #  REVERSING (engine-backed)   #
	#------------------------------#

	# Reverses the order of the items, in place.
	#
	#   returns    nothing; the list changes. ReverseQ returns the object for chaining
	#   see        Reversed
	#   example    o1.Reverse()
	#              ? @@( o1.Content() )
	#              #--> [ "b", "c", "b", "a" ]
	#@ aka  flip, backwards, invert order, last to first
	#@ aka  Reverse the order of the items in place (mutating). For a copy, use Reversed.
	def Reverse()
		_pList_ = This._Engine()
		if _pList_ = "" return ok

		StzEngineListReverse(_pList_)
		This._RefreshFromEngine()

		def ReverseQ()
			This.Reverse()
			return This

	# Returns a copy of the list in reverse order; the list is unchanged.
	#
	#   returns    a list
	#   see        Reverse
	#   example    ? @@( o1.Reversed() )
	#              #--> [ "b", "c", "b", "a" ]
	#@ aka  A reversed copy of the list; the original is unchanged.
	def Reversed()
		_pList_ = This._EngineListFromContent()
		if _pList_ = "" return [] ok

		StzEngineListReverse(_pList_)
		_aResult_ = StzEngineListContentToRingList(_pList_)
		StzEngineListFree(_pList_)
		return _aResult_

		def ItemsReversed()
			return This.Reversed()

	# Non-mutating sorted copies (the SortInAscending/Descending family
	# mutates; these return a fresh list).
	def SortedInAscending()
		return This.Sorted()

		def ItemsSortedInAscending()
			return This.SortedInAscending()

	# Returns every item except those equal to the given one.
	#
	#   p          the item to leave out
	#   returns    a list of items
	#   see        RemoveAll
	#@ aka  Every item except those equal to p (p may be a single item).
	def AllItemsExcept(p)
		_aResult_ = []
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			# content compare so a list-valued p is matched (raw != can't
			# compare sub-lists -> would wrongly keep an equal list item).
			if NOT BothAreEqualCS(@aContent[_i_], p, 1)
				_aResult_ + @aContent[_i_]
			ok
		next
		return _aResult_

		def ItemsExcept(p)
			return This.AllItemsExcept(p)

	# Returns the first n items, or the whole list when n is larger.
	#
	#   _n_        how many items
	#   returns    a list of items
	#   see        LastNItems
	#@ aka  First n items (clamped to the list length; n<=0 -> empty).
	def FirstNItems(_n_)
		if NOT isNumber(_n_) or _n_ <= 0
			return []
		ok
		if _n_ > len(@aContent)
			_n_ = len(@aContent)
		ok
		_aResult_ = []
		for _i_ = 1 to _n_
			_aResult_ + @aContent[_i_]
		next
		return _aResult_

	# Returns the depth of nesting; a flat list has one level.
	#
	#   returns    a number
	#   see        Paths
	#@ aka  Max nesting depth (a flat list is 1 level).
	def NumberOfLevels()
		return This._DepthOf(@aContent)

		def NestingDepth()
			return This.NumberOfLevels()

	def _DepthOf(_aList_)
		_nMax_ = 1
		_nLen_ = len(_aList_)
		for _i_ = 1 to _nLen_
			if isList(_aList_[_i_])
				_nD_ = 1 + This._DepthOf(_aList_[_i_])
				if _nD_ > _nMax_
					_nMax_ = _nD_
				ok
			ok
		next
		return _nMax_

	# TRUE if two adjacent items are equal.
	#
	#   returns    TRUE or FALSE
	#   see        FindDupSecutiveItems
	#@ aka  TRUE if any two adjacent items are equal.
	def ContainsDupSecutiveItems()
		_nLen_ = len(@aContent)
		for _i_ = 2 to _nLen_
			if @aContent[_i_] = @aContent[_i_ - 1]
				return 1
			ok
		next
		return 0

		def ContainsConsecutiveDuplicates()
			return This.ContainsDupSecutiveItems()

	# Returns a copy without any occurrence of the given items; the list is unchanged.
	#
	#   returns    a list of items
	#   see        ItemRemoved
	#@ aka  A fresh copy with every occurrence of any item in paItems removed.
	def ManyRemoved(paItems)
		if NOT isList(paItems)
			paItems = [ paItems ]
		ok
		_aResult_ = []
		_nLen_ = len(@aContent)
		_nP_ = len(paItems)
		for _i_ = 1 to _nLen_
			_bRemove_ = 0
			for _j_ = 1 to _nP_
				if BothAreEqualCS(@aContent[_i_], paItems[_j_], 1)
					_bRemove_ = 1
					exit
				ok
			next
			if NOT _bRemove_
				_aResult_ + @aContent[_i_]
			ok
		next
		return _aResult_

	# TRUE if the items appear in the other list in the same relative order.
	#
	#   returns    TRUE or FALSE
	#   see        IsReverseOf
	#@ aka  TRUE if this list's items appear inside paOther in the same relative order (i.e. this list is an order-preserving subsequence of paOther).
	def ItemsHaveSameOrderAs(paOther)
		if NOT isList(paOther)
			return 0
		ok
		_nThis_ = len(@aContent)
		_nOther_ = len(paOther)
		_nIdx_ = 1
		for _i_ = 1 to _nOther_
			if _nIdx_ <= _nThis_ and paOther[_i_] = @aContent[_nIdx_]
				_nIdx_++
			ok
		next
		return _nIdx_ > _nThis_

	  #----------------------------------------------#
	 #  FINDING ITEMS (engine-backed, first match)  #
	#----------------------------------------------#

	# Note: Find() = ALL occurrences is defined later via
	# FindAllOccurrencesCS at line ~1668, with aliases
	# FindAll, FindFirst, FindLast, FindNth.
	# This method provides a fast single-result engine path.

	def _FindFirstEngine(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_pList_ = This._Engine()
		if _pList_ = "" return 0 ok

		_nResult_ = 0
		if isString(pItem)
			_nResult_ = StzEngineListFindStringCS(_pList_, pItem, pCaseSensitive)
		else
			# Non-string items (lists, numbers): go through the engine-backed
			# FindAllOccurrencesCS so Contains stays CONSISTENT with Find and
			# compares list items by content (the old raw `=` loop silently
			# missed sub-list items -> Contains disagreed with Find).
			_anFfe_ = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
			if ring_len(_anFfe_) > 0
				_nResult_ = _anFfe_[1]
			ok
		ok

		return _nResult_

	  #----------------------------------------------#
	 #  CONTAINS (engine-backed)                    #
	#----------------------------------------------#

	def ContainsCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		return This._FindFirstEngine(pItem, pCaseSensitive) > 0

	# TRUE if the list holds the given item.
	#
	#   pItem      the item to look for
	#   returns    TRUE or FALSE
	#   note       case-sensitive: ContainsCS takes the flag
	#   see        Find, ContainsOneOfThese
	#   example    ? o1.Contains("c")
	#              #--> TRUE
	#              ? o1.Contains("z")
	#              #--> FALSE
	#@ aka  includes, has, is in, member of, present, holds
	#@ aka  TRUE if the list contains the given item.
	def Contains(pItem)
		return This.ContainsCS(pItem, 1)

	  #------------------------------------------------------#
	 #  REMOVE DUPLICATES / UNIQUE (engine-backed)          #
	#------------------------------------------------------#

	def RemoveDuplicatesCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_pList_ = This._Engine()
		if _pList_ = "" return ok

		pUnique = StzEngineListUniqueCS(_pList_, pCaseSensitive)
		if pUnique != ""
			This._AdoptEngine(pUnique)   # frees old cache (_pList_), adopts pUnique
		ok

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

	# Removes the repeated occurrences of every item, keeping the first of each, in place.
	#
	#   returns    nothing; the list changes
	#   see        WithoutDuplication, DuplicatedItems
	#   example    o1.RemoveDuplicates()
	#              ? @@( o1.Content() )
	#              #--> [ "a", "b", "c" ]
	#@ aka  unique, distinct, dedupe, remove repeats, deduplicate, drop duplicates
	def RemoveDuplicates()
		This.RemoveDuplicatesCS(1)

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This

	#-- Immutable / past-tense aliases for the dedup operation.
	#   DuplicatesRemoved() returns the deduped list value without
	#   mutating This (equivalent to WithoutDuplication, ported from
	#   archive line 41406). Used by stzHashList.UniqueValues().

	def DuplicatesRemovedCS(pCaseSensitive)
		return This.WithoutDuplicationCS(pCaseSensitive)

	# Returns a copy of the list without its repeated items, keeping the first of each; the list is unchanged.
	#
	#   returns    a list
	#   see        RemoveDuplicates, WithoutDuplication
	#   example    ? @@( o1.DuplicatesRemoved() )
	#              #--> [ "a", "b", "c" ]
	def DuplicatesRemoved()
		return This.WithoutDuplicationCS(1)

	def ToStzListOfCharsQ()
		if NOT @IsListOfChars(@aContent)
			StzRaise("Can't cast the list into a stzListOfChars object! The list must be a list of chars.")
		ok

		_oResult_ = StzListOfCharsQ(@aContent)
		return _oResult_
				
	# ToSet / ToSetQ / ToSetOfItems: set-style aliases that return
	# the deduplicated list. Routed through the existing engine-backed
	# DuplicatesRemoved so the heavy lifting stays on the Zig side.

	def ToSet()
		return This.DuplicatesRemoved()

		def ToSetQ()
			return new stzList( This.ToSet() )

		def ToSetOfItems()
			return This.ToSet()

		def ToSetOfItemsQ()
			return new stzList( This.ToSet() )

	def WithoutDuplicationCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_pList_ = This._Engine()
		if _pList_ = "" return @aContent ok

		pUnique = StzEngineListUniqueCS(_pList_, pCaseSensitive)
		_aResult_ = @aContent
		if pUnique != ""
			_aResult_ = StzEngineListContentToRingList(pUnique)
			StzEngineListFree(pUnique)
		ok
		return _aResult_

	# Returns a copy of the list with every item once, in order of first appearance; the list is unchanged.
	#
	#   returns    a list
	#   see        RemoveDuplicates
	#   example    ? @@( o1.WithoutDuplication() )
	#              #--> [ "a", "b", "c" ]
	def WithoutDuplication()
		return This.WithoutDuplicationCS(1)

		def Unique()
			return This.WithoutDuplication()

		def UniqueCS(pCaseSensitive)
			return This.WithoutDuplicationCS(pCaseSensitive)

	  #--------------------------------------#
	 #  DUPLICATE DETECTION (delegates to   #
	 #  stzListDuplicates)                  #
	#--------------------------------------#

	# TRUE if some item occurs more than once in the list.
	def ContainsDuplicatedItemsCS(pCaseSensitive)
		_oDupChk_ = new stzListDuplicates(This)
		return _oDupChk_.HasDuplicatesCS(pCaseSensitive)

	# TRUE if some item occurs more than once.
	#
	#   returns    TRUE or FALSE
	#   see        DuplicatedItems, NumberOfDuplicates
	#   example    ? o1.ContainsDuplicatedItems()
	#              #--> TRUE
	def ContainsDuplicatedItems()
		return This.ContainsDuplicatedItemsCS(1)

		# TRUE if some item occurs more than once in the list.
		def HasDuplicates()
			return This.ContainsDuplicatedItems()

		def HasDuplicatesCS(pCaseSensitive)
			return This.ContainsDuplicatedItemsCS(pCaseSensitive)

		def ContainsDuplicates()
			return This.ContainsDuplicatedItems()

	def DuplicatedItemsCS(pCaseSensitive)
		_oDupItm_ = new stzListDuplicates(This)
		return _oDupItm_.DuplicatedItemsCS(pCaseSensitive)

	# Returns the items that occur more than once, each listed once.
	#
	#   returns    a list of items
	#   see        FindDuplicates, NumberOfDuplicates, ContainsDuplicatedItems
	#   example    ? @@( o1.DuplicatedItems() )
	#              #--> [ "b" ]
	#@ aka  repeated items, doubles, occur twice, duplicates
	#@ aka  The items that occur more than once in the list.
	def DuplicatedItems()
		return This.DuplicatedItemsCS(1)

	# How many duplicated items the list holds.
	def NumberOfDuplicatedItemsCS(pCaseSensitive)
		return len(This.DuplicatedItemsCS(pCaseSensitive))

	# Returns how many distinct items occur more than once.
	#
	#   returns    a number
	#   see        NumberOfNonDuplicatedItems
	def NumberOfDuplicatedItems()
		return This.NumberOfDuplicatedItemsCS(1)

		# Returns how many repeated occurrences the list holds, counting every one after the first.
		#
		#   returns    a number
		#   note       it counts occurrences, not distinct duplicated items: [ a, a, a ] gives 2
		#   see        DuplicatedItems, FindDuplicates
		#   example    ? o1.NumberOfDuplicates()
		#              #--> 1
		#@ aka  NumberOfDuplicates counts the duplicate OCCURRENCES (every 2nd+ appearance), not the number of distinct duplicated items. For [ "A","B","2","A","A","B",2,2,"." ] that is 4 (A twice, B once, 2 once). NumberOfDuplicatedItems (distinct) would be 3.
		def NumberOfDuplicates()
			return This.NumberOfDuplicatesCS(1)

		def NumberOfDuplications()
			return This.NumberOfDuplicates()

	# Returns the positions of every repeated occurrence, leaving out the first occurrence of each item.
	#
	#   returns    a list of numbers
	#   see        DuplicatedItems, NumberOfDuplicates
	#   example    ? @@( o1.FindDuplicates() )
	#              #--> [ 4 ]
	#@ aka  The position of every 2nd+ occurrence of each duplicated item.
	def FindDuplicates()
		# Positions of each item's 2nd+ occurrence (case-sensitive).
		# Engine path: O(n) hashing in Zig + correct on nested-list items
		# (Ring's `=` can't compare sublists, so the old O(n^2) loop
		# silently returned [] for them). Ring loop kept as a fallback
		# when the content can't be marshalled into an engine list.
		_pFdList_ = This._Engine()
		if _pFdList_ != ""
			_aFdRes_ = StzEngineListFindDuplicatesCS(_pFdList_, 1)
			return _aFdRes_
		ok
		_aRes_ = []
		_aData_ = This.Content()
		_nDataLen_ = len(_aData_)
		_aSeen_ = []
		for _i_ = 1 to _nDataLen_
			_x_ = _aData_[_i_]
			_bDup_ = 0
			_nSeenLen_ = len(_aSeen_)
			for _j_ = 1 to _nSeenLen_
				if _aSeen_[_j_] = _x_
					_bDup_ = 1
					exit
				ok
			next
			if _bDup_
				_aRes_ + _i_
			else
				_aSeen_ + _x_
			ok
		next
		return _aRes_

		# Same as FindDuplicates.
		def FindDuplications()
			return This.FindDuplicates()

		def FindDuplicatedItems()
			return This.FindDuplicates()

		def FindDuplicatesQ()
			return new stzList( This.FindDuplicates() )

	# FindDuplicatesXT: positions of ALL occurrences of items that have
	# duplicates (i.e. include the first occurrence too, not just the
	# 2nd+ that FindDuplicates returns). Delegates to the CS core, which
	# stringifies items first -- so "2" (string) and 2 (number) are kept
	# distinct instead of being conflated by Ring's coercing `=`.
	def FindDuplicatesXT()
		return This.FindDuplicatesCSXT(1)

		def FindDuplicationsXT()
			return This.FindDuplicatesXT()

		# Z-suffix Softanza convention: each duplicated item paired with
		# the positions of its DUPLICATE occurrences (first one excluded).
		def DuplicatesZ()
			return This.DuplicatesCSZ(1)

		# Returns each duplicated item with the positions of its repeats.
		#
		#   returns    a list of [ item, positions ] pairs
		#   see        DuplicatesZ
		def DuplicateItemsZ()
			return This.DuplicatesCSZ(1)

		def DuplicationsZ()
			return This.DuplicatesCSZ(1)

		def DuplicatedItemsZ()
			return This.DuplicatesCSZ(1)

	# Returns the position n places after a given position.
	#
	#   _n_        how many places to move forward
	#   returns    a number
	#   see        FindPreviousNthItem
	#@ aka  FindNextNthItem(n, :StartingAt = pos): the POSITION of the n-th item AFTER pos (pos+n). Find* returns the position (0 if out of range); the NextNthItem accessor returns the item there. :StartingAt accepts the bare integer or the named-param form.
	def FindNextNthItem(_n_, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		_nIdx_ = pnStartingAt + _n_
		if _nIdx_ < 1 or _nIdx_ > This.NumberOfItems()
			return 0
		ok
		return _nIdx_

		# Returns the nth item after a given position.
		#
		#   _n_        how many places to move forward
		#   returns    the item
		#   see        PreviousNthItem
		#@ aka  The nth item after the given position.
		def NextNthItem(_n_, pnStartingAt)
			_nP_ = This.FindNextNthItem(_n_, pnStartingAt)
			if _nP_ = 0 return "" ok
			return This.Content()[_nP_]

	# Returns the position n places back from a given position, that position included in the count.
	#
	#   _n_        how many places to move back
	#   returns    a number
	#   see        FindNextNthItem
	#@ aka  FindPreviousNthItem(n, :StartingAt = pos): the POSITION of the n-th item counting BACK from pos inclusive (pos-n+1).
	def FindPreviousNthItem(_n_, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		_nIdx_ = pnStartingAt - _n_ + 1
		if _nIdx_ < 1 or _nIdx_ > This.NumberOfItems()
			return 0
		ok
		return _nIdx_

		# Returns the nth item before a given position.
		#
		#   _n_        how many places to move back
		#   returns    the item
		#   see        NextNthItem
		#@ aka  The nth item before the given position.
		def PreviousNthItem(_n_, pnStartingAt)
			_nP_ = This.FindPreviousNthItem(_n_, pnStartingAt)
			if _nP_ = 0 return "" ok
			return This.Content()[_nP_]

	# Duplicates() / DuplicateItems() / Duplications(): the duplicated
	# items themselves (returning DuplicatedItems). The XYZ-Z forms
	# above return positions; these return values.
	def Duplicates()
		return This.DuplicatedItems()

	def Duplications()
		return This.DuplicatedItems()

	  #-----------------------------------------------#
	 #  DUPLICATES OF A SPECIFIC ITEM / STRING       #
	#-----------------------------------------------#
	# "...OfString" is the historical name (these came from the
	# list-of-strings API) but they work for any item type. The
	# "duplicates" of an item are its 2nd-and-later occurrences --
	# the first one is the original, the rest are the copies.

	def FindDuplicatesOfStringCS(pItem, pCaseSensitive)
		_anFdosAll_ = This.FindAllCS(pItem, pCaseSensitive)
		_nFdosLen_ = len(_anFdosAll_)
		if _nFdosLen_ <= 1 return [] ok
		_anFdosRes_ = []
		for _iFdos_ = 2 to _nFdosLen_
			_anFdosRes_ + _anFdosAll_[_iFdos_]
		next
		return _anFdosRes_

	# Returns the positions of the repeats of a string item.
	#
	#   pItem      the string to look for
	#   returns    a list of positions
	#   see        FindDuplicates
	def FindDuplicatesOfString(pItem)
		return This.FindDuplicatesOfStringCS(pItem, 1)

		def FindDuplicatesOfItemCS(pItem, pCaseSensitive)
			return This.FindDuplicatesOfStringCS(pItem, pCaseSensitive)

		# Returns the positions of the repeats of the item, leaving out its first occurrence.
		#
		#   returns    a list of positions
		#   see        FindDuplicationsOf
		def FindDuplicatesOfItem(pItem)
			return This.FindDuplicatesOfStringCS(pItem, 1)

	# Same set of positions, but exposed under the "Duplications" name and
	# accepting the :CS = TRUE|FALSE named param for the case dial.
	def FindDuplicationsOfItemCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok
		return This.FindDuplicatesOfStringCS(pItem, pCaseSensitive)

		# Returns the positions of the repeats of the item, leaving out its first occurrence.
		#
		#   returns    a list of positions
		#   see        FindDuplicationsOf
		def FindDuplicationsOfItem(pItem)
			return This.FindDuplicatesOfStringCS(pItem, 1)

		# Returns the positions of the repeats of the item, leaving out its first occurrence.
		#
		#   returns    a list of positions
		#   see        FindDuplicationsOfItem
		def FindDuplicationsOf(pItem)
			return This.FindDuplicatesOfStringCS(pItem, 1)

	def NumberOfDuplicatesOfStringCS(pItem, pCaseSensitive)
		return len(This.FindDuplicatesOfStringCS(pItem, pCaseSensitive))

	# Returns how many repeats of the string occur beyond its first occurrence.
	#
	#   pItem      the string to count
	#   returns    a number
	#   see        FindDuplicatesOfString
	def NumberOfDuplicatesOfString(pItem)
		return This.NumberOfDuplicatesOfStringCS(pItem, 1)

		def NumberOfDuplicatesOfItemCS(pItem, pCaseSensitive)
			return This.NumberOfDuplicatesOfStringCS(pItem, pCaseSensitive)

		# Returns how many repeats of the item occur beyond its first occurrence.
		#
		#   returns    a number
		#   see        FindDuplicatesOfItem
		def NumberOfDuplicatesOfItem(pItem)
			return This.NumberOfDuplicatesOfStringCS(pItem, 1)

	def StringIsDuplicatedNTimesCS(pItem, _n_, pCaseSensitive)
		return This.NumberOfDuplicatesOfStringCS(pItem, pCaseSensitive) = _n_

	# TRUE if the string repeats exactly n times after its first occurrence.
	#
	#   pItem      the string to count
	#   _n_        how many repeats
	#   returns    TRUE or FALSE
	#   see        FindDuplicatedString
	def StringIsDuplicatedNTimes(pItem, _n_)
		return This.StringIsDuplicatedNTimesCS(pItem, _n_, 1)

		def ItemIsDuplicatedNTimesCS(pItem, _n_, pCaseSensitive)
			return This.StringIsDuplicatedNTimesCS(pItem, _n_, pCaseSensitive)

		# TRUE if the item repeats exactly n times after its first occurrence.
		#
		#   _n_        how many repeats
		#   returns    TRUE or FALSE
		#   see        NumberOfDuplicatesOfItem
		def ItemIsDuplicatedNTimes(pItem, _n_)
			return This.StringIsDuplicatedNTimesCS(pItem, _n_, 1)

	# ALL positions of an item -- but only when it actually IS duplicated
	# (appears more than once); a non-duplicated item yields the empty list.
	def FindDuplicatedStringCS(pItem, pCaseSensitive)
		_anFdsAll_ = This.FindAllCS(pItem, pCaseSensitive)
		if len(_anFdsAll_) <= 1 return [] ok
		return _anFdsAll_

	# Returns the positions of every occurrence of a string that occurs more than once.
	#
	#   pItem      the string to look for
	#   returns    a list of positions
	#   see        FindDuplicatesOfString
	def FindDuplicatedString(pItem)
		return This.FindDuplicatedStringCS(pItem, 1)

		def FindDuplicatedItemCS(pItem, pCaseSensitive)
			return This.FindDuplicatedStringCS(pItem, pCaseSensitive)

		# Returns the positions of every occurrence of an item that occurs more than once.
		#
		#   returns    a list of positions
		#   see        FindDuplicationsOf
		def FindDuplicatedItem(pItem)
			return This.FindDuplicatedStringCS(pItem, 1)

	def ContainsDuplicatedStringCS(pItem, pCaseSensitive)
		return len(This.FindAllCS(pItem, pCaseSensitive)) > 1

	# TRUE if the string occurs more than once.
	#
	#   pItem      the string to look for
	#   returns    TRUE or FALSE
	#   see        FindDuplicatedString
	def ContainsDuplicatedString(pItem)
		return This.ContainsDuplicatedStringCS(pItem, 1)

		def ContainsDuplicatedItemCS(pItem, pCaseSensitive)
			return This.ContainsDuplicatedStringCS(pItem, pCaseSensitive)

		# TRUE if the item occurs more than once.
		#
		#   returns    TRUE or FALSE
		#   see        FindDuplicatedItem
		def ContainsDuplicatedItem(pItem)
			return This.ContainsDuplicatedStringCS(pItem, 1)

	# The distinct items that have duplicates, and how many such items there are.
	def DuplicatedStringsCS(pCaseSensitive)
		return This.DuplicatesCS(pCaseSensitive)

	def DuplicatedStrings()
		return This.Duplicates()

	def NumberOfDuplicatedStringsCS(pCaseSensitive)
		return len(This.DuplicatesCS(pCaseSensitive))

	# Returns how many distinct strings occur more than once.
	#
	#   returns    a number
	#   see        NumberOfDuplicatedItems
	def NumberOfDuplicatedStrings()
		return len(This.Duplicates())

	  #--------------------------------------#
	 #  FLATTEN (engine-backed)             #
	#--------------------------------------#

	#-- FindSubList / ContainsSubList: locate the contiguous
	#   occurrences of a sub-list inside the list.

	def FindSubListCS(paSubList, pCaseSensitive)
		if NOT (isList(paSubList) and len(paSubList) >= 1)
			return []
		ok
		_nFsbLen_ = len(paSubList)
		_nFsbN_ = len(@aContent)
		_anFsbR_ = []
		_bFsbCase_ = @CaseSensitive(pCaseSensitive)
		_iFsb_ = 1
		while _iFsb_ <= _nFsbN_ - _nFsbLen_ + 1
			_bFsbMatch_ = 1
			for _kFsb_ = 1 to _nFsbLen_
				_xA_ = @aContent[_iFsb_ + _kFsb_ - 1]
				_xB_ = paSubList[_kFsb_]
				if NOT _bFsbCase_ and isString(_xA_) and isString(_xB_)
					if lower(_xA_) != lower(_xB_)
						_bFsbMatch_ = 0
						exit
					ok
				but _xA_ != _xB_
					_bFsbMatch_ = 0
					exit
				ok
			next
			if _bFsbMatch_
				_anFsbR_ + _iFsb_
				_iFsb_ += _nFsbLen_
			else
				_iFsb_++
			ok
		end
		return _anFsbR_

	# Returns the positions where the given sublist starts.
	#
	#   paSubList   the run of items to look for
	#   returns     a list of positions
	#   see         ContainsSubList
	def FindSubList(paSubList)
		return This.FindSubListCS(paSubList, 1)

		def FindTheseContiguousItems(paSubList)
			return This.FindSubList(paSubList)

		def FindTheseAdjacentItems(paSubList)
			return This.FindSubList(paSubList)

	# TRUE if the given sublist occurs in the list as a consecutive
	# run of items.
	def ContainsSubListCS(paSubList, pCaseSensitive)
		return len(This.FindSubListCS(paSubList, pCaseSensitive)) > 0

	# TRUE if the given run of items occurs in the list.
	#
	#   paSubList   the run of items to look for
	#   returns     TRUE or FALSE
	#   see         FindSubList
	def ContainsSubList(paSubList)
		return This.ContainsSubListCS(paSubList, 1)

	# Flattens the list by one level, in place.
	#
	#   returns    nothing; the list changes
	#   see        Merged, Flatten
	#@ aka  -- Merge: flatten ONE level only. For each item: if it's a list, spread its items; otherwise keep as-is. Distinct from Flatten() which fully recurses. Port from archive line 37074; used by stzHashList.Items() to coalesce list-of-lists values.
	def Merge()
		_pList_ = This._Engine()
		pRes = StzEngineListFlattenToDepth(_pList_, 1)		#-- one-level flatten
		This._AdoptEngine(pRes)   # frees old cache (_pList_), adopts pRes

		def MergeQ()
			This.Merge()
			return This

	# Returns a copy flattened by one level; the list is unchanged.
	#
	#   returns    a list of items
	#   see        Merge, Flattened
	#@ aka  A copy flattened by ONE level: sublists spread out, other items kept as they are.
	def Merged()
		_oMdTmp_ = new stzList(@aContent)
		_oMdTmp_.Merge()
		return _oMdTmp_.Content()

	# Flattens a nested list to a single level, in place.
	#
	#   returns    nothing; the list changes
	#   see        Flattened, Merge
	#@ aka  unnest, merge levels, single level, ungroup, collapse nesting
	#@ aka  Flatten the nested list to a single level in place (mutating). For a copy, use Flattened.
	def Flatten()
		_pList_ = This._Engine()
		if _pList_ = "" return ok

		pFlat = StzEngineListFlatten(_pList_)
		if pFlat != ""
			This._AdoptEngine(pFlat)   # frees old cache (_pList_), adopts pFlat
		ok
		# if pFlat = NULL, _pList_ stays as the cache (not freed)

		def FlattenQ()
			This.Flatten()
			return This

	# Returns a copy of the list with every nested list opened out; the list is unchanged.
	#
	#   returns    a flat list
	#   example    o1 = new stzList([ [ 1, 2 ], [ 3, [ 4 ] ] ])
	#              ? @@( o1.Flattened() )
	#              #--> [ 1, 2, 3, 4 ]
	#@ aka  A fully-flattened copy of the nested list; the original is unchanged.
	def Flattened()
		_pList_ = This._Engine()
		if _pList_ = "" return [] ok

		pFlat = StzEngineListFlatten(_pList_)
		_aResult_ = []
		if pFlat != ""
			_aResult_ = StzEngineListContentToRingList(pFlat)
			StzEngineListFree(pFlat)
		ok
		return _aResult_

	  #-------------------------------------------#
	 #  EQUALITY CHECK (set-based, engine-backed) #
	#-------------------------------------------#

	def IsEqualToCS(paOtherList, pCaseSensitive)
		# Set-based equality: same items regardless of order
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT isList(paOtherList)
			return 0
		ok

		if len(@aContent) != len(paOtherList)
			return 0
		ok

		# Use mutual subset check (A subset B AND B subset A)
		_pEqList1_ = This._Engine()
		if _pEqList1_ = "" return 0 ok

		_oEqOther_ = new stzList(paOtherList)
		_pEqList2_ = _oEqOther_._EngineListFromContent()
		if _pEqList2_ = ""
			return 0
		ok

		_nAsubB_ = StzEngineListIsSubsetCS(_pEqList1_, _pEqList2_, pCaseSensitive)
		_nBsubA_ = StzEngineListIsSubsetCS(_pEqList2_, _pEqList1_, pCaseSensitive)
		StzEngineListFree(_pEqList2_)

		return _nAsubB_ and _nBsubA_

	# TRUE if the list holds the same items as the given list, in any order, each item as many times.
	#
	#   paOtherList   the list to compare with
	#   returns       TRUE or FALSE
	#   note          order does not matter: IsStrictlyEqualTo also compares the positions
	#   see           IsStrictlyEqualTo
	#   example       ? o1.IsEqualTo([ "c", "b", "a", "b" ])
	#                 #--> TRUE
	#                 ? o1.IsEqualTo([ "a", "b", "c" ])
	#                 #--> FALSE
	def IsEqualTo(paOtherList)
		return This.IsEqualToCS(paOtherList, 1)

	  #------------------------------------------------#
	 #  STRICT EQUALITY (same items + same positions)  #
	#------------------------------------------------#

	def IsStrictlyEqualToCS(paOtherList, pCaseSensitive)
		# Positional equality: same items at same positions
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT isList(paOtherList)
			return 0
		ok

		_pSeList1_ = This._Engine()
		if _pSeList1_ = "" return 0 ok

		_oSeOther_ = new stzList(paOtherList)
		_pSeList2_ = _oSeOther_._EngineListFromContent()
		if _pSeList2_ = ""
			return 0
		ok

		_nSeResult_ = StzEngineListEqualsCS(_pSeList1_, _pSeList2_, pCaseSensitive)
		StzEngineListFree(_pSeList2_)

		return _nSeResult_

	# TRUE if the list holds the same items at the same positions as the given list.
	#
	#   paOtherList   the list to compare with
	#   returns       TRUE or FALSE
	#   see           IsEqualTo
	#   example       ? o1.IsStrictlyEqualTo([ "a", "b", "c", "b" ])
	#                 #--> TRUE
	#                 ? o1.IsStrictlyEqualTo([ "a", "b", "b", "c" ])
	#                 #--> FALSE
	def IsStrictlyEqualTo(paOtherList)
		return This.IsStrictlyEqualToCS(paOtherList, 1)

		def IsIdenticalTo(paOtherList)
			return This.IsStrictlyEqualTo(paOtherList)

		def IsEqualToXT(paOtherList)
			return This.IsStrictlyEqualTo(paOtherList)

		def IsIdenticalToCS(paOtherList, pCaseSensitive)
			return This.IsStrictlyEqualToCS(paOtherList, pCaseSensitive)

		def IsEqualToCSXT(paOtherList, pCaseSensitive)
			return This.IsStrictlyEqualToCS(paOtherList, pCaseSensitive)

	  #---------------------------------------------------#
	 #  STARTS WITH / ENDS WITH (engine-backed)           #
	#---------------------------------------------------#

	def StartsWithCS(paItems, pCaseSensitive)
		_pSwList_ = This._Engine()
		_pSwPrefix_ = StzEngineMarshalList(paItems)
		_nSwResult_ = StzEngineListStartsWithListCS(_pSwList_, _pSwPrefix_, pCaseSensitive)
		StzEngineListFree(_pSwPrefix_)
		return _nSwResult_

	# TRUE if the list begins with the given items, in order.
	#
	#   paItems    the items it should begin with
	#   returns    TRUE or FALSE
	#   see        EndsWith
	#   example    ? o1.StartsWith([ "a", "b" ])
	#              #--> TRUE
	#              ? o1.StartsWith([ "b" ])
	#              #--> FALSE
	def StartsWith(paItems)
		return This.StartsWithCS(paItems, 1)

	def EndsWithCS(paItems, pCaseSensitive)
		_pEwList_ = This._Engine()
		_pEwSuffix_ = StzEngineMarshalList(paItems)
		_nEwResult_ = StzEngineListEndsWithListCS(_pEwList_, _pEwSuffix_, pCaseSensitive)
		StzEngineListFree(_pEwSuffix_)
		return _nEwResult_

	# TRUE if the list ends with the given items, in order.
	#
	#   paItems    the items it should end with
	#   returns    TRUE or FALSE
	#   see        StartsWith
	#   example    ? o1.EndsWith([ "c", "b" ])
	#              #--> TRUE
	#              ? o1.EndsWith([ "c" ])
	#              #--> FALSE
	def EndsWith(paItems)
		return This.EndsWithCS(paItems, 1)

	  #---------------------------------------------------#
	 #  EXPRESSION-BACKED OPERATIONS (engine bytecode)    #
	#---------------------------------------------------#

	# Returns the list of the results of an expression applied to every item.
	#
	#   pcExpr     the expression, as text, where @item stands for the current item
	#   returns    a list of the results, one per item
	#   see        Filter, Perform
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? @@( o1.Map("2*@item") )
	#              #--> [ 6, 2, 8, 2, 10 ]
	def Map(pcExpr)
		_pList_ = This._Engine()
		if _pList_ = "" return [] ok

		pcExpr = _StzStripBraces(pcExpr)
		pResult = StzEngineListMapExpr(_pList_, pcExpr)
		_aResult_ = StzEngineListContentToRingList(pResult)

		StzEngineListFree(pResult)
		return _aResult_

		def MapQ(pcExpr)
			return new stzList(This.Map(pcExpr))

	# Returns the items for which an expression is true.
	#
	#   pcExpr     the condition, as text, where @item stands for the current item
	#   returns    a list of the items that pass
	#   see        Map
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? @@( o1.Filter("@item > 2") )
	#              #--> [ 3, 4, 5 ]
	#@ aka  keep where, select, subset, matching items, pick out
	def Filter(pcExpr)
		_pList_ = This._Engine()
		if _pList_ = "" return [] ok

		pcExpr = _StzStripBraces(pcExpr)
		pResult = StzEngineListFilterExpr(_pList_, pcExpr)
		_aResult_ = StzEngineListContentToRingList(pResult)

		StzEngineListFree(pResult)
		return _aResult_

		def FilterQ(pcExpr)
			return new stzList(This.Filter(pcExpr))

		def FilterW(pcExpr)
			return This.Filter(pcExpr)

	# Returns the sum of the numbers of the list.
	#
	#   returns    a number
	#   see        Sum, Product
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? o1.Reduce()
	#              #--> 14
	#@ aka  Reduce(): 0-arg auto-concat / auto-sum. - All-string items: concatenate. - All-number items: sum. - Mixed: concatenate stringified items.
	def Reduce()
		_l_ = This.List()
		_nL_ = len(_l_)
		_bAllStr_ = 1
		_bAllNum_ = 1
		for _i_ = 1 to _nL_
			if NOT isString(_l_[_i_]) _bAllStr_ = 0 ok
			if NOT isNumber(_l_[_i_]) _bAllNum_ = 0 ok
		next
		if _bAllNum_
			_s_ = 0
			for _i_ = 1 to _nL_
				_s_ += _l_[_i_]
			next
			return _s_
		ok
		_c_ = ""
		for _i_ = 1 to _nL_
			_c_ += "" + _l_[_i_]
		next
		return _c_

	def ReduceXT(pcExpr, pInitValue)
		# The expression uses @accumulator and @item. The bridge builds the
		# init value and extracts the result scalar INSIDE stz_list.dll, so no
		# StzValue handle crosses the stz_list<->stz_value DLL boundary (which
		# previously panicked on the init handle). Returns a plain number.
		_pList_ = This._Engine()
		if _pList_ = "" return 0 ok

		pcExpr = _StzStripBraces(pcExpr)
		_result_ = StzEngineListReduceExpr(_pList_, pcExpr, pInitValue)

		return _result_

	# Reduces the items to one value with an expression, starting from the first item instead of an initial value.
	#
	#   returns    the reduced value
	#   see        Reduce
	def ReduceNoInit(pcExpr)
		_pList_ = This._Engine()
		if _pList_ = "" return 0 ok

		pcExpr = _StzStripBraces(pcExpr)
		_result_ = StzEngineListReduceExprNoInit(_pList_, pcExpr)

		return _result_

	def CountW(pcCondition)
		_pList_ = This._Engine()
		if _pList_ = "" return 0 ok

		pcCondition = _StzStripBraces(pcCondition)
		_nResult_ = StzEngineListCountW(_pList_, pcCondition)

		return _nResult_

		def CountWhere(pcCondition)
			return This.CountW(pcCondition)

		def NumberOfItemsW(pcCondition)
			return This.CountW(pcCondition)

		def CountItemsW(pcCondition)
			return This.CountW(pcCondition)

		def HowManyItemsW(pcCondition)
			return This.CountW(pcCondition)


	  #-------------------------------------------#
	 #  SORTING ORDER CHECK                      #
	#-------------------------------------------#

	# TRUE if the items are sorted, ascending or descending.
	#
	#   returns    TRUE or FALSE
	#   see        SortingOrder
	def IsSorted()
		return This.IsSortedInAscending() or This.IsSortedInDescending()

	# TRUE if the items are in ascending order.
	#
	#   returns    TRUE or FALSE
	#   see        IsSortedInDescending, SortingOrder, Sort
	#   example    ? o1.IsSortedInAscending()
	#              #--> FALSE
	#              o1 = new stzList([ 1, 2, 2, 5 ])
	#              ? o1.IsSortedInAscending()
	#              #--> TRUE
	def IsSortedInAscending()
		return _ListSortingOrder(@aContent) = :Ascending

	# TRUE if the items are in descending order.
	#
	#   returns    TRUE or FALSE
	#   see        IsSortedInAscending, SortingOrder
	#   example    o1 = new stzList([ 5, 3, 3, 1 ])
	#              ? o1.IsSortedInDescending()
	#              #--> TRUE
	#              ? o1.IsSortedInAscending()
	#              #--> FALSE
	def IsSortedInDescending()
		return _ListSortingOrder(@aContent) = :Descending

	# Returns the order the items are in: :Ascending, :Descending or unsorted.
	#
	#   returns    a symbol, which prints in lowercase
	#   see        IsSortedInAscending, IsSortedInDescending
	#   example    ? o1.SortingOrder()
	#              #--> unsorted
	#              o1 = new stzList([ 1, 2, 3 ])
	#              ? o1.SortingOrder()
	#              #--> ascending
	#@ aka  The sorting order of the items (:Ascending, :Descending, ...).
	def SortingOrder()
		return _ListSortingOrder(@aContent)

	# TRUE if both lists are sorted the same way, ascending or descending.
	#
	#   returns    TRUE or FALSE
	#   see        SortingOrder
	#@ aka  TRUE if the given list is sorted the same way as this one.
	def HasSameSortingOrderAs(paOther)
		return This.SortingOrder() = _ListSortingOrder(paOther)

	# TRUE if both lists hold the same items, in any order.
	#
	#   returns    TRUE or FALSE
	#   see        IsEqualTo
	#@ aka  HasSameContentAs: order-independent equality check. Two lists have the same content iff each is a permutation of the other -- same length, and every item in A appears (with the same multiplicity) in B. Walk-and-mark, O(N*M) -- fine for narrative test sizes; lift to a hash-based approach when called on large lists in real code paths.
	def HasSameContentAs(paOther)
		if NOT isList(paOther)
			return 0
		ok
		_aData_ = This.Content()
		_nLen_ = len(_aData_)
		if _nLen_ != len(paOther)
			return 0
		ok
		# Manual copy. Ring's `list + []` appends [] as a new element
		# instead of concatenating, so it cannot be used to clone.
		_aOther_ = []
		_nCpL_ = len(paOther)
		for _iCp_ = 1 to _nCpL_
			_aOther_ + paOther[_iCp_]
		next
		for _i_ = 1 to _nLen_
			_x_ = _aData_[_i_]
			_bFound_ = 0
			_nOLen_ = len(_aOther_)
			for _j_ = 1 to _nOLen_
				# content compare so nested-list items match (Ring's raw `=`
				# can't compare sub-lists)
				if BothAreEqualCS(_aOther_[_j_], _x_, 1)
					del(_aOther_, _j_)
					_bFound_ = 1
					exit
				ok
			next
			if NOT _bFound_
				return 0
			ok
		next
		return 1

		def IsEquivalentTo(paOther)
			return This.HasSameContentAs(paOther)

		def SameContentAs(paOther)
			return This.HasSameContentAs(paOther)

	  #-------------------------------------------#
	 #  TYPE-CHECKING METHODS                    #
	#-------------------------------------------#

	# TRUE if every item is a [ key, value ] pair.
	#
	#   returns    TRUE or FALSE
	#   see        Pairs
	#@ aka  TRUE if every item is a [key, value] pair (a hash list).
	def IsHashList()
		# One implementation, in the global (stzHashList.ring): same shape
		# check, but the key-uniqueness scan goes to the engine once the
		# list is big enough that the pairwise Ring scan would cliff.
		# @aContent passes by reference, so this costs no copy.

		return @IsHashList(@aContent)

		def IsAHashList()
			return This.IsHashList()

		# TRUE if some item is not a [ key, value ] pair.
		#
		#   returns    TRUE or FALSE
		#   see        IsHashList
		#@ aka  TRUE if the list is NOT a hash list.
		def IsNotHashList()
			return NOT This.IsHashList()

	# Views the list as a stzHashList, reading each item as a [ key, value ] pair.
	#
	#   returns    a stzHashList
	#   see        ToStzTable
	#@ aka  -- ToStzHashList: view this list (a hashlist / list of [key,value] pairs, e.g. [ :a = 1, :b = 2 ]) as a stzHashList, so you can chain KeysQ(), ValuesQ(), etc. The stzHashList ctor normalizes a list of pairs.
	def ToStzHashList()
		return new stzHashList(This.Content())

		def ToHashList()
			return This.ToStzHashList()

		def ToStzHashListQ()
			return This.ToStzHashList()

	# TRUE if the list holds exactly two items.
	#
	#   returns    TRUE or FALSE
	#   see        IsSingle
	def IsPair()
		return len(@aContent) = 2

		def IsAPair()
			return This.IsPair()

	# TRUE if the list is not empty and every item is a string.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfNumbers
	#@ aka  TRUE if the list is non-empty and every item is a string.
	def IsListOfStrings()
		if len(@aContent) = 0 return 0 ok   # empty is NOT a list-of-strings (monolith semantics)
		_pList_ = This._EngineListFromContent()
		_nResult_ = StzEngineListIsAllStrings(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def IsAListOfStrings()
			return This.IsListOfStrings()

		# :Texts is a TYPE trait, and every string is readable as a
		# text -- so "are these texts?" is "are these strings?". (The
		# per-item IsText() on stzObject asks a different question:
		# whether the value IS an stzText, which no plain string is.)
		def IsListOfTexts()
			return This.IsListOfStrings()

		def IsAListOfTexts()
			return This.IsListOfStrings()

	# TRUE if every item is a text in uppercase.
	#
	#   returns    TRUE or FALSE; FALSE for an empty list or when an item is not text
	#   see        IsLowercase, Uppercased
	#   example    ? o1.IsUppercase()
	#              #--> FALSE
	#              o1 = new stzList([ "A", "B" ])
	#              ? o1.IsUppercase()
	#              #--> TRUE
	#@ aka  TRUE when EVERY item is a string AND uppercase.
	def IsUppercase()
		_nLen_ = len(@aContent)
		if _nLen_ = 0
			return 0
		ok
		for i = 1 to _nLen_
			if NOT isString(@aContent[i])
				return 0
			ok
			if @aContent[i] != StzUpper(@aContent[i])
				return 0
			ok
		next
		return 1

		def AllItemsAreUppercase()
			return This.IsUppercase()

	# TRUE if every item is a text in lowercase.
	#
	#   returns    TRUE or FALSE; FALSE for an empty list or when an item is not text
	#   see        IsUppercase, Lowercased
	#   example    ? o1.IsLowercase()
	#              #--> TRUE
	#              o1 = new stzList([ "a", "B" ])
	#              ? o1.IsLowercase()
	#              #--> FALSE
	def IsLowercase()
		_nLen_ = len(@aContent)
		if _nLen_ = 0
			return 0
		ok
		for i = 1 to _nLen_
			if NOT isString(@aContent[i])
				return 0
			ok
			if @aContent[i] != StzLower(@aContent[i])
				return 0
			ok
		next
		return 1

		def AllItemsAreLowercase()
			return This.IsLowercase()

	# TRUE if the list is not empty and every item is a number.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfStrings
	#@ aka  TRUE if the list is non-empty and every item is a number.
	def IsListOfNumbers()
		if len(@aContent) = 0 return 0 ok   # empty is NOT a list-of-numbers (monolith semantics)
		_pList_ = This._EngineListFromContent()
		_nResult_ = StzEngineListIsAllNumbers(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def IsAListOfNumbers()
			return This.IsListOfNumbers()

	# TRUE if every item is a single character.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfStrings
	#@ aka  TRUE if every item is a single char.
	def IsListOfChars()
		return @IsListOfChars(@aContent)

		def IsAListOfChars()
			return This.IsListOfChars()

	# TRUE if every item is of the given kind, such as :Numbers or :Strings.
	#
	#   pType      the kind, as a symbol or a text
	#   returns    TRUE or FALSE
	#   see        IsListOfNumbers, IsListOfStrings
	#@ aka  Polymorphic membership test: IsListOf(:Numbers/:Strings/:Chars/ :Lists/:StzNumbers/:StzStrings/:ListsOfNumbers/:PairsOfNumbers).
	def IsListOf(pType)
		_cType_ = StzLower("" + pType)
		switch _cType_
		on "numbers"
			return This.IsListOfNumbers()
		on "number"
			return This.IsListOfNumbers()
		on "strings"
			return This.IsListOfStrings()
		on "string"
			return This.IsListOfStrings()
		on "chars"
			return This.IsListOfChars()
		on "char"
			return This.IsListOfChars()
		on "lists"
			return This.IsListOfLists()
		on "stznumbers"
			return This._AllItemsHaveStzType("stznumber")
		on "stzstrings"
			return This._AllItemsHaveStzType("stzstring")
		on "listsofnumbers"
			return This._AllItemsAreNumberLists(0)
		on "listofnumbers"
			return This._AllItemsAreNumberLists(0)
		on "pairsofnumbers"
			return This._AllItemsAreNumberLists(1)
		on "pairofnumbers"
			return This._AllItemsAreNumberLists(1)
		on "listofstrings"
			return This._AllItemsAreStringLists()
		on "listsofstrings"
			return This._AllItemsAreStringLists()
		on "listofstznumbers"
			return This._AllItemsAreStzTypeLists("stznumber")
		on "listsofstznumbers"
			return This._AllItemsAreStzTypeLists("stznumber")
		on "listofstzstrings"
			return This._AllItemsAreStzTypeLists("stzstring")
		on "listsofstzstrings"
			return This._AllItemsAreStzTypeLists("stzstring")
		other
			return 0
		off

		def IsAListOf(pType)
			return This.IsListOf(pType)

	# All items are stz objects whose StzType() matches (e.g. stznumber).
	def _AllItemsHaveStzType(cStzType)
		_nLen_ = len(@aContent)
		if _nLen_ = 0
			return 0
		ok
		for _i_ = 1 to _nLen_
			if NOT isObject(@aContent[_i_])
				return 0
			ok
			if StzLower("" + @aContent[_i_].StzType()) != StzLower(cStzType)
				return 0
			ok
		next
		return 1

	# All items are lists of numbers (optionally each a 2-element pair).
	def _AllItemsAreNumberLists(bPairsOnly)
		_nLen_ = len(@aContent)
		if _nLen_ = 0
			return 0
		ok
		for _i_ = 1 to _nLen_
			_it_ = @aContent[_i_]
			if NOT isList(_it_)
				return 0
			ok
			if bPairsOnly and len(_it_) != 2
				return 0
			ok
			_m_ = len(_it_)
			for _j_ = 1 to _m_
				if NOT isNumber(_it_[_j_])
					return 0
				ok
			next
		next
		return 1

	# All items are lists of strings.
	def _AllItemsAreStringLists()
		_nLen_ = len(@aContent)
		if _nLen_ = 0 return 0 ok
		for _i_ = 1 to _nLen_
			_it_ = @aContent[_i_]
			if NOT isList(_it_) return 0 ok
			_m_ = len(_it_)
			for _j_ = 1 to _m_
				if NOT isString(_it_[_j_]) return 0 ok
			next
		next
		return 1

	# All items are lists whose items are stz objects of the given stztype.
	def _AllItemsAreStzTypeLists(cStzType)
		_nLen_ = len(@aContent)
		if _nLen_ = 0 return 0 ok
		for _i_ = 1 to _nLen_
			_it_ = @aContent[_i_]
			if NOT isList(_it_) return 0 ok
			_m_ = len(_it_)
			for _j_ = 1 to _m_
				if NOT isObject(_it_[_j_]) return 0 ok
				if StzLower("" + _it_[_j_].StzType()) != StzLower(cStzType) return 0 ok
			next
		next
		return 1

	# TRUE if every item is a list; an empty list counts as TRUE.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfStrings
	#@ aka  TRUE if every item is a list (vacuously TRUE when empty).
	def IsListOfLists()
		if len(@aContent) = 0 return 1 ok		#-- vacuously true (engine returns 0 on empty)
		_pList_ = This._EngineListFromContent()
		_nResult_ = StzEngineListIsAllLists(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def IsAListOfLists()
			return This.IsListOfLists()

		def AllItemsAreLists()
			return This.IsListOfLists()

		def ContainsOnlyLists()
			return This.IsListOfLists()

	# TRUE if every item is a list and every item of those lists is a number.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfNumbers
	#@ aka  IsListOfListsOfNumbers: each top-level item must be a list, and each inner item must be a number.
	def IsListOfListsOfNumbers()
		_nIllonLen_ = len(@aContent)
		if _nIllonLen_ = 0
			return 0
		ok
		for _iIllon_ = 1 to _nIllonLen_
			if NOT isList(@aContent[_iIllon_])
				return 0
			ok
			_nIllonInner_ = len(@aContent[_iIllon_])
			for _jIllon_ = 1 to _nIllonInner_
				if NOT isNumber(@aContent[_iIllon_][_jIllon_])
					return 0
				ok
			next
		next
		return 1

		def IsAListOfListsOfNumbers()
			return This.IsListOfListsOfNumbers()

	# TRUE if every item is a list and all those lists have the same size.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfLists
	#@ aka  TRUE if every item is a list and all the sublists have the same size.
	def IsListOfListsOfSameSize()
		_pList_ = This._EngineListFromContent()
		_nResult_ = StzEngineListIsAllListsSameSize(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def ItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

		def AllItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

	# TRUE if the list holds exactly two items and both are numbers.
	#
	#   returns    TRUE or FALSE
	#   see        IsPairOfStrings
	#@ aka  TRUE if the list is exactly a pair of two numbers.
	def IsPairOfNumbers()
		if len(@aContent) = 2 and isNumber(@aContent[1]) and isNumber(@aContent[2])
			return 1
		else
			return 0
		ok

		def IsAPairOfNumbers()
			return This.IsPairOfNumbers()

	# TRUE if every item is a pair; an empty list counts as TRUE.
	#
	#   returns    TRUE or FALSE
	#   see        IsPair
	#@ aka  TRUE if every item is a pair (vacuously TRUE when empty).
	def IsListOfPairs()
		if len(@aContent) = 0 return 1 ok		#-- vacuously true (engine returns 0 on empty)
		_pList_ = This._EngineListFromContent()
		_nResult_ = StzEngineListIsAllPairs(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def IsAListOfPairs()
			return This.IsListOfPairs()

	# TRUE if the items are numbers in ascending order that follow each other, such as [ 3, 4, 5 ].
	#
	#   returns    TRUE or FALSE
	#@ aka  True iff the list of numbers is sorted ascending with consecutive values (e.g. [3,4,5] -> TRUE, [3,5,6] -> FALSE).
	def IsContiguous()
		_nLen_ = len(@aContent)
		if _nLen_ < 2
			return 1
		ok
		for _i_ = 1 to _nLen_
			if NOT isNumber(@aContent[_i_])
				return 0
			ok
		next
		for _i_ = 2 to _nLen_
			if @aContent[_i_] != @aContent[_i_-1] + 1
				return 0
			ok
		next
		return 1

		def AreContiguous()
			return This.IsContiguous()

	# TRUE if every item is a pair of numbers.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfPairs
	def IsListOfPairsOfNumbers()
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			p = @aContent[_i_]
			if NOT (isList(p) and len(p) = 2 and isNumber(p[1]) and isNumber(p[2]))
				return 0
			ok
		next
		return 1

		def IsAListOfPairsOfNumbers()
			return This.IsListOfPairsOfNumbers()

	# TRUE if every item is a pair of strings.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfPairs
	def IsListOfPairsOfStrings()
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			p = @aContent[_i_]
			if NOT (isList(p) and len(p) = 2 and isString(p[1]) and isString(p[2]))
				return 0
			ok
		next
		return 1

		def IsAListOfPairsOfStrings()
			return This.IsListOfPairsOfStrings()

	# TRUE if no item occurs twice, so that the list is a set.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsNoDuplicates
	#@ aka  TRUE if all the items are unique (the list is a set).
	def IsSet()
		# Engine-backed: a set == all items unique. The engine's all-unique
		# compares by content (UTF-8 + nested-list correct), so it matches
		# Softanza's "no duplicates" exactly -- including sub-list items, which
		# the old raw `=` loop could not compare. Ring fallback otherwise.
		_pSetList_ = This._EngineListFromContent()
		if _pSetList_ != ""
			_nSet_ = StzEngineListAllUniqueCS(_pSetList_, 1)
			StzEngineListFree(_pSetList_)
			return _nSet_
		ok
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			for _j_ = _i_ + 1 to _nLen_
				if @aContent[_i_] = @aContent[_j_]
					return 0
				ok
			next
		next
		return 1

		def IsASet()
			return This.IsSet()

	  #=============================================#
	 #  ESSENTIAL METHODS FOR SUBMODULE SUPPORT    #
	#=============================================#

	  #-- List() alias

	# The raw Ring list content (same as Content).
	def List()
		return This.Content()

		def ListQ()
			return This

	  #-- Section: extract items between two positions

	def SectionCS(_n1_, _n2_, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_nLen_ = This.NumberOfItems()

		if CheckingParams()
			_n1_ = This._SectionResolveBound(_n1_, 1)
			_n2_ = This._SectionResolveBound(_n2_, 0)

			# :@ mirrors the partner index (Section(3,:@)==Section(3,3));
			# :@ on both sides spans the whole list.
			if _n1_ = :@ and _n2_ = :@
				_n1_ = 1
				_n2_ = _nLen_
			but _n1_ = :@ and isNumber(_n2_)
				_n1_ = _n2_
			but _n2_ = :@ and isNumber(_n1_)
				_n2_ = _n1_
			ok

			if NOT @BothAreNumbers(_n1_, _n2_)
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		if (_n1_ < 1 or _n1_ > _nLen_) or (_n2_ < 1 or _n2_ > _nLen_)
			StzRaise("Indexes out of range!")
		ok

		if _n2_ < _n1_
			_nTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nTemp_
		ok

		_aContent_ = This.Content()
		_aResult_ = []
		for _i_ = _n1_ to _n2_
			_aResult_ + _aContent_[_i_]
		next

		return _aResult_

		def SectionCSQ(_n1_, _n2_, pCaseSensitive)
			return new stzList(This.SectionCS(_n1_, _n2_, pCaseSensitive))

	# Resolve one Section() boundary to a numeric position. Accepts a number;
	# the named anchors :First(Item)/:Last(Item)/:End/:EndOfList; a value present
	# in the list (a FROM bound -> its first occurrence, a TO bound -> its last);
	# the named-param wrappers [:From,x]/[:To,x]; and [:NthToLast(Item),k] ->
	# NumberOfItems()-k. The :@ mirror token is returned unchanged for the caller.
	def _SectionResolveBound(px, pbFrom)
		_nLen_ = This.NumberOfItems()
		if isNumber(px)
			return px
		but isString(px)
			if px = :First or px = :FirstItem
				return 1
			but px = :Last or px = :LastItem or px = :End or px = :EndOfList
				return _nLen_
			but px = :@
				return px
			else
				if pbFrom
					return This.FindFirst(px)
				else
					return This.FindLast(px)
				ok
			ok
		but isList(px) and len(px) = 2 and isString(px[1])
			_k_ = px[1]
			if _k_ = :From or _k_ = :To
				return This._SectionResolveBound(px[2], pbFrom)
			but _k_ = :NthToLast or _k_ = :NthToLastItem
				return _nLen_ - px[2]
			but _k_ = :Nth or _k_ = :NthItem or _k_ = :NthFirst or _k_ = :NthFirstItem
				return px[2]
			ok
		ok
		return px

	# Returns the items from position n1 to position n2, both included.
	#
	#   _n1_       the first position
	#   _n2_       the last position
	#   returns    a list of the items of that section
	#   see        Range, RemoveSection, Sections
	#   example    ? @@( o1.Section(2, 3) )
	#              #--> [ "b", "c" ]
	def Section(_n1_, _n2_)
		return This.SectionCS(_n1_, _n2_, 1)

		def SectionQ(_n1_, _n2_)
			return new stzList(This.Section(_n1_, _n2_))

	# Returns a number of items from a start position.
	#
	#   pnStart    the first position, or :First or :Last
	#   pnRange    how many items to take
	#   returns    a list of the items taken
	#   see        Section
	#   example    ? @@( o1.Range(2, 2) )
	#              #--> [ "b", "c" ]
	#@ aka  -- Range: extract items from a start position for a given count
	def Range(pnStart, pnRange)
		if CheckingParams()
			if isString(pnStart)
				if pnStart = :First or pnStart = :FirstItem
					pnStart = 1
				but pnStart = :Last or pnStart = :LastItem
					pnStart = This.NumberOfItems()
				ok
			ok
		ok

		if pnStart < 0
			pnStart = This.NumberOfItems() + pnStart + 1
		ok

		if pnStart = 0 or pnRange = 0
			return []
		ok

		if pnRange > 0
			return This.Section(pnStart, pnStart + pnRange - 1)
		else
			_n1_ = pnStart + pnRange + 1
			if _n1_ > 0
				return This.Section(_n1_, pnStart)
			ok
			return []
		ok

		def RangeQ(pnStart, pnRange)
			return new stzList(This.Range(pnStart, pnRange))

	  #-- RangeXT: like Range but the start may be negative (counts from the
	  #-- end); delegates to SectionXT, which also normalizes negative bounds.

	def RangeXT(pnStart, pnRange)
		if NOT (isNumber(pnStart) and isNumber(pnRange))
			StzRaise("Incorrect param types! pnStart and pnRange must be both numbers.")
		ok
		if pnRange < 0
			StzRaise("Incorrect param value! pnRange must be positive.")
		ok
		if pnStart < 0
			pnStart = This.NumberOfItems() + pnStart + 1
		ok
		_aRxSec_ = RangeToSection(pnStart, pnRange)
		return This.SectionXT(_aRxSec_[1], _aRxSec_[2])

		def RangeXTQ(pnStart, pnRange)
			return new stzList(This.RangeXT(pnStart, pnRange))

	# Inserts the item before position n, in place.
	#
	#   _n_        the position to insert before
	#   returns    nothing; the list changes
	#   see        InsertBefore, AddItemAt
	#@ aka  -- InsertAt: insert an item at a given position
	def InsertAt(_n_, pItem)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_, [ :Position, :ItemAt, :ItemAtPosition ])
			_n_ = _n_[2]
		ok

		_aContent_ = @aContent
		ring_insert(_aContent_, _n_, pItem)
		This.UpdateWith(_aContent_)

		# Inserts the item before position n, in place.
		#
		#   _n_        the position to insert before
		#   pItem      the item to insert
		#   returns    nothing; the list changes
		#   see        InsertAfter, Add
		#   example    o1.InsertBefore(2, "X")
		#              ? @@( o1.Content() )
		#              #--> [ "a", "X", "b", "c", "b" ]
		def InsertBefore(_n_, pItem)
			This.InsertAt(_n_, pItem)

		def InsertAtQ(_n_, pItem)
			This.InsertAt(_n_, pItem)
			return This

	# Removes the item at position n, in place.
	#
	#   _n_        the position to remove
	#   returns    nothing; the list changes
	#   see        RemoveNthItem
	#@ aka  -- RemoveItemAtPosition: remove item at a specific position
	def RemoveItemAtPosition(_n_)
		if isString(_n_)
			if StzFindFirst(_n_, [:First, :FirstPosition, :FirstItem]) > 0
				_n_ = 1
			but StzFindFirst(_n_, [:Last, :LastPosition, :LastItem]) > 0
				_n_ = This.NumberOfItems()
			ok
		ok

		if NOT (isNumber(_n_) and _n_ != 0)
			StzRaise("Incorrect param! n must be a number different from zero.")
		ok

		if _n_ <= This.NumberOfItems()
			_aContent_ = This.Content()
			ring_del(_aContent_, _n_)
			This.UpdateWith(_aContent_)
		ok

		def RemoveItemAtPositionQ(_n_)
			This.RemoveItemAtPosition(_n_)
			return This

		# Removes the item at position n, in place.
		#
		#   _n_        the position of the item to remove
		#   returns    nothing; the list changes
		#   see        Remove, RemoveSection
		#   example    o1.RemoveAt(2)
		#              ? @@( o1.Content() )
		#              #--> [ "a", "c", "b" ]
		def RemoveAt(_n_)
			This.RemoveItemAtPosition(_n_)

	# Removes the items at the given positions, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveNthItem
	#@ aka  -- RemoveItemsAtPositions: remove items at multiple positions
	def RemoveItemsAtPositions(panPos)
		if NOT isList(panPos)
			StzRaise("Incorrect param type! panPos must be a list.")
		ok

		_oChain_ = new stzList(panPos)

		panSorted = _oChain_.Sorted()
		_nLen_ = len(panSorted)

		for _i_ = _nLen_ to 1 step -1
			This.RemoveItemAtPosition(panSorted[_i_])
		next

		def RemoveItemsAtPositionsQ(panPos)
			This.RemoveItemsAtPositions(panPos)
			return This

		# Removes the items at the given positions, in place.
		#
		#   returns    nothing; the list changes
		#   see        RemoveItemsAtPositions
		def RemoveItemsAtThesePositions(panPos)
			This.RemoveItemsAtPositions(panPos)

		def RemoveItemsAtThesePositionsQ(panPos)
			This.RemoveItemsAtPositions(panPos)
			return This

	# Removes the items from position n1 to position n2, both included, in place.
	#
	#   _n1_       the first position of the section
	#   _n2_       the last position of the section
	#   returns    nothing; the list changes
	#   see        Section, RemoveAt
	#   example    o1.RemoveSection(2, 3)
	#              ? @@( o1.Content() )
	#              #--> [ "a", "b" ]
	#@ aka  -- RemoveSection: remove items between two positions
	def RemoveSection(_n1_, _n2_)
		_nLen_ = This.NumberOfItems()

		if CheckingParams()
			if isString(_n1_)
				if StzFindFirst(_n1_, [:First, :FirstPosition, :FirstItem]) > 0
					_n1_ = 1
				ok
			ok

			if isString(_n2_)
				if StzFindFirst(_n2_, [:Last, :LastPosition, :LastItem]) > 0
					_n2_ = _nLen_
				ok
			ok

			if NOT @BothAreNumbers(_n1_, _n2_)
				StzRaise("Incorrect param type! n1 and n2 must be numbers.")
			ok

			if _n2_ < _n1_
				_nTemp_ = _n1_
				_n1_ = _n2_
				_n2_ = _nTemp_
			ok
		ok

		if _nLen_ = 0
			return
		ok

		if _n1_ = 1 and _n2_ = _nLen_
			This.UpdateWith([])
			return
		ok

		if _n1_ = _n2_
			This.RemoveItemAtPosition(_n1_)
			return
		ok

		_aContent_ = This.Content()
		_aResult_ = []

		for _i_ = 1 to _n1_ - 1
			_aResult_ + _aContent_[_i_]
		next

		for _i_ = _n2_ + 1 to _nLen_
			_aResult_ + _aContent_[_i_]
		next

		This.UpdateWith(_aResult_)

		def RemoveSectionQ(_n1_, _n2_)
			This.RemoveSection(_n1_, _n2_)
			return This

	  #-- RemoveW / RemoveW: drop items where the eval'd predicate
	  #   is TRUE. Forwards to stzListRemover.RemoveW. The XT variant
	  #   is alias (the underlying remover handles both shapes).

	def RemoveW(pcCondition)
		_oRwRemover_ = new stzListRemover(This)
		_oRwRemover_.RemoveW(pcCondition)
		This._SetContent(_oRwRemover_.Content())

		def RemoveWQ(pcCondition)
			_StzHistoOpen(This.Content())
			This.RemoveW(pcCondition)
			_StzHistoAdd(This.Content())
			return This



	# Removes the items that are a single space, in place.
	#
	#   returns    nothing; the list changes
	#   example    o1 = new stzList([ "a", " ", "b" ])
	#              o1.RemoveSpaces()
	#              ? @@( o1.Content() )
	#              #--> [ "a", "b" ]
	#@ aka  RemoveSpaces / RemoveSpacesQ: drop every " " item (string-space) from the content. Engine-aware: only removes string-typed " ".
	def RemoveSpaces()
		_aOut_ = []
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			if NOT (isString(@aContent[_i_]) and @aContent[_i_] = " ")
				_aOut_ + @aContent[_i_]
			ok
		next
		This._SetContent(_aOut_)

		def RemoveSpacesQ()
			_StzHistoOpen(This.Content())
			This.RemoveSpaces()
			_StzHistoAdd(This.Content())
			return This

	# Removes the later repeats of every item, keeping the first occurrence, in place.
	#
	#   returns    nothing; the list changes
	#   see        UniqueItems
	#@ aka  RemoveDuplicatedItems / Q: in-place dedup. Order-preserving: keeps the first occurrence of each unique value.
	def RemoveDuplicatedItems()
		_aSeen_ = []
		_aOut_ = []
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			_x_ = @aContent[_i_]
			_bDup_ = 0
			_nSL_ = len(_aSeen_)
			for _j_ = 1 to _nSL_
				if _aSeen_[_j_] = _x_ _bDup_ = 1 exit ok
			next
			if NOT _bDup_
				_aSeen_ + _x_
				_aOut_ + _x_
			ok
		next
		This._SetContent(_aOut_)

		def RemoveDuplicatedItemsQ()
			_StzHistoOpen(This.Content())
			This.RemoveDuplicatedItems()
			_StzHistoAdd(This.Content())
			return This

	# TRUE if the list is the other list read backwards, item by item.
	#
	#   returns    TRUE or FALSE
	#   see        Reversed
	#@ aka  IsReverseOf(paOther): TRUE iff @aContent is the reverse of paOther (deep-equal item-by-item).
	def IsReverseOf(paOther)
		if NOT isList(paOther) return 0 ok
		_nLen_ = len(@aContent)
		if _nLen_ != len(paOther) return 0 ok
		for _i_ = 1 to _nLen_
			if @aContent[_i_] != paOther[_nLen_ - _i_ + 1]
				return 0
			ok
		next
		return 1

	# Removes the first item, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveLastItem, Pop
	#@ aka  -- RemoveFirstItem / RemoveLastItem
	def RemoveFirstItem()
		This.RemoveItemAtPosition(1)

		def RemoveFirstItemQ()
			This.RemoveFirstItem()
			return This

	# Removes the last item, in place.
	#
	#   returns    nothing; the list changes
	#   see        Pop
	def RemoveLastItem()
		This.RemoveItemAtPosition(This.NumberOfItems())

		def RemoveLastItemQ()
			This.RemoveLastItem()
			return This

	# Removes the first and the last items, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveFirstItem
	def RemoveFirstAndLastItems()
		This.RemoveFirstItem()
		This.RemoveLastItem()

		def RemoveFirstAndLastItemsQ()
			This.RemoveFirstAndLastItems()
			return This

	# Removes a run of items from a position, in place; a negative count runs backwards.
	#
	#   _nStart_   the position of the first item to remove
	#   nRange     how many items to remove
	#   returns    nothing; the list changes
	#   see        RemoveSection
	#@ aka  -- RemoveRange: remove items from start for a count
	def RemoveRange(_nStart_, nRange)
		if nRange > 0
			This.RemoveSection(_nStart_, _nStart_ + nRange - 1)
		but nRange < 0
			_n1_ = _nStart_ + nRange + 1
			if _n1_ > 0
				This.RemoveSection(_n1_, _nStart_)
			ok
		ok

	# Empties the list, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveFirstItem
	#@ aka  -- RemoveAllItems
	def RemoveAllItems()
		This.UpdateWith([])

	  #-- FindAllOccurrencesCS: find all positions of an item

	def FindAllOccurrencesCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok

		if len(@aContent) = 0
			return []
		ok

		# Engine path for string items
		if isString(pItem)
			_pFaoList_ = This._Engine()
			if _pFaoList_ = ""
				return []
			ok
			_pFaoResult_ = StzEngineListFindAllStringCS(_pFaoList_, pItem, pCaseSensitive)
			if _pFaoResult_ = ""
				return []
			ok
			_aFaoOut_ = StzEngineListContentToRingList(_pFaoResult_)
			StzEngineListFree(_pFaoResult_)
			return _aFaoOut_
		ok

		# Engine/Ring path for number items -- delegate to the proven
		# global helper used by stzListFinder. The previous direct call
		# to StzEngineListFindAllCS+StzEngineValueNewInt returned empty
		# for all-number lists (bug found via M-S2 regression test).
		if isNumber(pItem)
			# Integer needle: engine dense find (scans the i64 array directly;
			# needle passed as a plain number so no cross-module value handle).
			if floor(pItem) = pItem
				_pFaiH_ = This._Engine()
				if _pFaiH_ != ""
					_anFai_ = StzEngineListFindAllInt(_pFaiH_, pItem)
					if isList(_anFai_)
						return _anFai_
					ok
				ok
			ok
			# Float needle (or fallback): the proven Ring helper.
			_anFaoNumResult_ = @FindAllCS_NbrOrStr( @aContent, pItem, pCaseSensitive )
			if isList(_anFaoNumResult_)
				return _anFaoNumResult_
			ok
			return []
		ok

		# LIST needle: native engine value-find. The needle is marshalled as
		# item[0] of a holder list, so the engine compares it structurally
		# (valueEqlCS) against each item -- O(n) with no per-item stringify.
		# (The old Ring stringify-and-compare fallback -- @@() on every item --
		# was O(n) allocations and ~16s at a million items; it is retired now
		# that the engine's native stzValue compare handles nested lists.)
		if isList(pItem)
			_pFaoHost_ = This._Engine()
			if _pFaoHost_ = "" return [] ok
			_pFaoHolder_ = StzEngineMarshalList([ pItem ])
			if _pFaoHolder_ = ""
				return []
			ok
			_anFaoOut_ = StzEngineListFindAllHeldCS(_pFaoHost_, _pFaoHolder_, pCaseSensitive)
			StzEngineListFree(_pFaoHolder_)
			if NOT isList(_anFaoOut_) return [] ok
			return _anFaoOut_
		ok

		# OBJECT needle (rare): objects are not engine stzValues, so compare
		# by object name among the OBJECT items only (no whole-list stringify).
		_aFaoContent_ = This.Content()
		_nFaoLen_ = len(_aFaoContent_)
		_cFaoItem_ = ""
		if isObject(pItem) and @IsStzObject(pItem) and pItem.IsNamed()
			_cFaoItem_ = pItem.ObjectName()
		else
			_cFaoItem_ = Q(pItem).Stringified()
		ok
		_anFaoResult_ = []
		for _iFao3_ = 1 to _nFaoLen_
			_xFao_ = _aFaoContent_[_iFao3_]
			if isObject(_xFao_)
				_cCurFao_ = ""
				if @IsStzObject(_xFao_) and _xFao_.IsNamed()
					_cCurFao_ = _xFao_.ObjectName()
				else
					_cCurFao_ = @@(_xFao_)
				ok
				if _cCurFao_ = _cFaoItem_
					_anFaoResult_ + _iFao3_
				ok
			ok
		next
		return _anFaoResult_

		# Find the given item: the positions of EVERY occurrence, as a
		# list (engine-backed).
		#@ aka  locate, search, where is, positions of
		def FindCS(pItem, pCaseSensitive)
			return This.FindAllOccurrencesCS(pItem, pCaseSensitive)

		# Returns the positions of every occurrence of the item, as a list of numbers.
		#
		#   pItem      the item to look for, of any type
		#   returns    a list of numbers; [ ] when the item is absent
		#   note       case-sensitive: FindCS takes the flag
		#   see        FindFirst, FindLast, FindNth, Contains
		#   example    ? @@( o1.Find("b") )
		#              #--> [ 2, 4 ]
		#              ? @@( o1.Find("z") )
		#              #--> [ ]
		def Find(pItem)
			if isList(pItem) and len(pItem) = 2 and isString(pItem[1]) and
			   (pItem[1] = :Item or pItem[1] = :item)
				pItem = pItem[2]
			ok
			return This.FindAllOccurrencesCS(pItem, 1)

		def FindAllCS(pItem, pCaseSensitive)
			return This.FindAllOccurrencesCS(pItem, pCaseSensitive)

		# Returns the positions of every occurrence of the item, as Find does.
		#
		#   pItem      the item to look for
		#   returns    a list of numbers; [ ] when the item is absent
		#   see        Find
		#   example    ? @@( o1.FindAll("b") )
		#              #--> [ 2, 4 ]
		def FindAll(pItem)
			return This.FindAllOccurrencesCS(pItem, 1)

		# Returns the positions of every occurrence of the item.
		#
		#   returns    a list of positions
		#   see        FindItem
		def FindAllOccurrences(pItem)
			return This.FindAllOccurrencesCS(pItem, 1)

	# LastNItemsQRT(n, pcType): the last n items wrapped per pcType.
	# pcType examples: :stzList, :stzListOfStrings, :stzListOfNumbers.
	# Returns an object wrapping the last-n slice so callers can
	# chain .AddedToEach() etc. without first wrapping themselves.
	def LastNItemsQRT(_n_, pcType)
		_l_ = This.List()
		_nL_ = len(_l_)
		if _n_ < 1 return new stzList([]) ok
		if _n_ > _nL_ _n_ = _nL_ ok
		_a_ = []
		for _i_ = _nL_ - _n_ + 1 to _nL_
			_a_ + _l_[_i_]
		next
		# Wrap the slice so callers can chain methods.
		if isString(pcType)
			_kw_ = lower(pcType)
			if ring_left(_kw_, 1) = ":" _kw_ = StzMidToEnd(_kw_, 2) ok
			if _kw_ = "stzlistofstrings" return new stzListOfStrings(_a_) ok
		ok
		return new stzList(_a_)

	# Returns the last n items, or the whole list when n is larger.
	#
	#   _n_        how many items
	#   returns    a list of items
	#   see        FirstNItems
	def LastNItems(_n_)
		_o_ = This.LastNItemsQRT(_n_, :stzList)
		if isObject(_o_) return _o_.List() ok
		return _o_

	# Returns a copy where n is added to every number item; the list is unchanged.
	#
	#   _n_        the number to add
	#   returns    a list of items
	#   see        MultipliedByEach
	#@ aka  AddedToEach(n): add n to every numeric item; return a new list.
	def AddedToEach(_n_)
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isNumber(_v_)
				_aR_ + (_v_ + _n_)
			else
				_aR_ + _v_
			ok
		next
		return _aR_

	# Adds n to every number item, in place.
	#
	#   _n_        the number to add
	#   returns    nothing; the list changes
	#   see        AddedToEach
	def AddToEach(_n_)
		_l_ = This.List()
		_nL_ = len(_l_)
		for _i_ = 1 to _nL_
			if isNumber(_l_[_i_]) _l_[_i_] = _l_[_i_] + _n_ ok
		next
		This._SetContent(_l_)

	def LastNItemsQ(_n_)
		return new stzList( This.LastNItems(_n_) )

	# Returns each run of equal consecutive items as a list.
	#
	#   returns    a list of lists
	#   see        RepeatedLeadingItems
	#@ aka  SectionsOfSameItems(): group consecutive equal items into runs. "AABBCCAA" -> [["A","A"], ["B","B"], ["C","C"], ["A","A"]]
	def SectionsOfSameItems()
		# Groups the SAME items together across the whole list
		# (first-seen order), not just adjacent runs:
		# [ONE, TWO, TWO, ONE] -> [[ONE, ONE], [TWO, TWO]].
		_l_ = This.List()
		_nL_ = len(_l_)
		_aVals_ = []
		_aRes_ = []
		for _i_ = 1 to _nL_
			_nAt_ = ring_find(_aVals_, _l_[_i_])
			if _nAt_ = 0
				_aVals_ + _l_[_i_]
				_aRes_ + [ _l_[_i_] ]
			else
				_aRes_[_nAt_] + _l_[_i_]
			ok
		next
		return _aRes_

	# Returns the positions of the item inside any of the given sections.
	#
	#   returns    a list of positions
	#   see        FindItem
	#@ aka  FindInSections(pItem, aSections): absolute-position occurrences of pItem inside any of the given sections.
	def FindInSections(pItem, _aSections_)
		_aRes_ = []
		if NOT isList(_aSections_) return _aRes_ ok
		_aAll_ = This.FindAllOccurrencesCS(pItem, 1)
		_nP_ = len(_aAll_)
		_nS_ = len(_aSections_)
		for _i_ = 1 to _nP_
			_pos_ = _aAll_[_i_]
			for _j_ = 1 to _nS_
				_s_ = _aSections_[_j_]
				if isList(_s_) and len(_s_) >= 2 and isNumber(_s_[1]) and isNumber(_s_[2]) and
				   _pos_ >= _s_[1] and _pos_ <= _s_[2]
					_aRes_ + _pos_
					exit
				ok
			next
		next
		return _aRes_

	# Returns how many times the item occurs inside the given sections.
	#
	#   returns    a number
	#   see        FindInSections
	def CountInSections(pItem, _aSections_)
		return len(This.FindInSections(pItem, _aSections_))

	def NumberOfOccurrencesInSections(pItem, _aSections_)
		return This.CountInSections(pItem, _aSections_)

	# Returns the hexadecimal code points of every character of every string item.
	#
	#   returns    a list of lists of code points, such as "U+0061"
	#   see        StzUnicodes
	#@ aka  HexUnicodes(): hex code-points of every char of every string-item.
	def HexUnicodes()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				_o_ = new stzString(_v_)
				_aR_ + _o_.HexUnicodes()
			ok
		next
		return _aR_

	# Returns the items of the list that also occur in the given list, each once, in this list's order.
	#
	#   pNamedWith   the other list, or :With = list
	#   returns      a list
	#   see          UnionWith
	#   example      ? @@( o1.CommonItems([ "b", "z", "a" ]) )
	#                #--> [ "a", "b" ]
	#@ aka  CommonItems(:With = otherList): items present in both lists.
	def CommonItems(pNamedWith)
		# Accept CommonItems(:With = list) or a direct list argument.
		_other_ = pNamedWith
		if isList(pNamedWith) and len(pNamedWith) = 2 and
		   isString(pNamedWith[1]) and lower(pNamedWith[1]) = "with"
			_other_ = pNamedWith[2]
		ok
		if NOT isList(_other_) return [] ok
		# CommonItems is the SET intersection: This's items that also appear
		# in _other_, in This's order, each once (duplicates in the host
		# appear once per its narrative doc). The engine's IntersectionCS
		# already does exactly that -- host order + first-occurrence dedup --
		# in ONE O(n+m) hash pass. (The old path called the multiset
		# CommonItemsCS and then a UNIQUE pass in Ring that was O(k^2) and
		# effectively hung at ~1,000,000 shared items.)
		_pCiA_ = This._EngineListFromContent()
		_pCiB_ = StzEngineMarshalList(_other_)
		if _pCiA_ != "" and _pCiB_ != ""
			_pCiR_ = StzEngineListIntersectionCS(_pCiA_, _pCiB_, 1)
			_aR_ = StzEngineListContentToRingList(_pCiR_)
			StzEngineListFree(_pCiR_)
			StzEngineListFree(_pCiA_)
			StzEngineListFree(_pCiB_)
			return _aR_
		ok
		if _pCiA_ != "" StzEngineListFree(_pCiA_) ok
		if _pCiB_ != "" StzEngineListFree(_pCiB_) ok

		# Fallback (non-marshalable content): O(n*m) membership test with a
		# first-occurrence dedup folded into the same pass.
		_a_ = This.List()
		_nL_ = len(_a_)
		_nB_ = len(_other_)
		_aU_ = []
		for _i_ = 1 to _nL_
			_v_ = _a_[_i_]
			_bIn_ = 0
			for _j_ = 1 to _nB_
				if BothAreEqualCS(_v_, _other_[_j_], 1) _bIn_ = 1 exit ok
			next
			if _bIn_
				_bSeen_ = 0
				_nUL_ = len(_aU_)
				for _k_ = 1 to _nUL_
					if BothAreEqualCS(_v_, _aU_[_k_], 1) _bSeen_ = 1 exit ok
				next
				if NOT _bSeen_ _aU_ + _v_ ok
			ok
		next
		return _aU_

	# Returns the n items that come before the first occurrence of the anchor item.
	#
	#   pcAnchor   the item to count back from
	#   _n_        how many items
	#   returns    a list of items
	#   see        NextNItemsAfter
	#@ aka  PreviousNItems: two shapes -- PreviousNItems(n, :StartingAt/:StartingAtPosition = p): the n items strictly BEFORE position p; PreviousNItems(pcAnchor, n): the n items before the anchor item.
	def PreviousNItems(pcAnchor, _n_)
		_l_ = This.List()
		_nL_ = len(_l_)
		_pos_ = 0
		if isNumber(pcAnchor) and isList(_n_) and len(_n_) = 2 and
		   isString(_n_[1]) and
		   (lower(_n_[1]) = "startingat" or lower(_n_[1]) = "startingatposition")
			_pos_ = _n_[2]
			_n_ = pcAnchor
		else
			for _i_ = 1 to _nL_
				if _l_[_i_] = pcAnchor _pos_ = _i_ exit ok
			next
		ok
		if _pos_ <= 1 return [] ok
		_start_ = _pos_ - _n_
		if _start_ < 1 _start_ = 1 ok
		_aR_ = []
		for _i_ = _start_ to _pos_ - 1
			_aR_ + _l_[_i_]
		next
		return _aR_

	# Returns a copy where every text item has its spaces removed; the list is unchanged.
	#
	#   returns    a list of items
	#@ aka  SpacesRemoved (non-mutating): every string item stripped of spaces.
	def SpacesRemoved()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				# Engine-backed replace (Unicode-safe).
				_aR_ + StzReplace(_v_, " ", "")
			else
				_aR_ + _v_
			ok
		next
		return _aR_

	def WithoutSpaces()
		return This.SpacesRemoved()

	def WithoutSapces()
		return This.SpacesRemoved()

	# Returns the string items that contain another string item of the list.
	#
	#   returns    a list of strings
	#   see        FindSubList
	#@ aka  Substrongs/Substrinks (deliberate Softanza wordplay): the string items that CONTAIN another item of the list, and the ones that are CONTAINED IN another item (case-sensitive, engine-backed find).
	def SubStrongs()
		_aSbg_ = This.Content()
		_nSbg_ = ring_len(_aSbg_)
		_aSbgRes_ = []
		for _iSbg_ = 1 to _nSbg_
			if NOT isString(_aSbg_[_iSbg_]) loop ok
			for _jSbg_ = 1 to _nSbg_
				if _iSbg_ != _jSbg_ and isString(_aSbg_[_jSbg_]) and
				   _aSbg_[_iSbg_] != _aSbg_[_jSbg_] and
				   StzFindFirst(_aSbg_[_jSbg_], _aSbg_[_iSbg_]) > 0
					# i is a SubStrong when it CONTAINS j -- so j is the
					# NEEDLE and i the haystack. The two calls here and in
					# SubStrinks were transposed, so each method returned
					# the other's answer.
					_aSbgRes_ + _aSbg_[_iSbg_]
					exit
				ok
			next
		next
		return _aSbgRes_

	# Returns the string items contained in another string item of the list.
	#
	#   returns    a list of strings
	#   see        SubStrongs
	def SubStrinks()
		_aSbk_ = This.Content()
		_nSbk_ = ring_len(_aSbk_)
		_aSbkRes_ = []
		for _iSbk_ = 1 to _nSbk_
			if NOT isString(_aSbk_[_iSbk_]) loop ok
			for _jSbk_ = 1 to _nSbk_
				if _iSbk_ != _jSbk_ and isString(_aSbk_[_jSbk_]) and
				   _aSbk_[_iSbk_] != _aSbk_[_jSbk_] and
				   StzFindFirst(_aSbk_[_iSbk_], _aSbk_[_jSbk_]) > 0
					# ...and i is a SubStrink when it is CONTAINED IN j:
					# i is the needle, j the haystack. The mirror.
					_aSbkRes_ + _aSbk_[_iSbk_]
					exit
				ok
			next
		next
		return _aSbkRes_

	def ConcatenateXT(p1)
		_sep_ = ""
		if isString(p1)
			_sep_ = p1
		but isList(p1) and len(p1) = 2 and isString(p1[1]) and
		   (lower(p1[1]) = "using" or lower(p1[1]) = "with" or lower(p1[1]) = "by")
			_sep_ = p1[2]
		ok
		_l_ = This.List()
		_nL_ = len(_l_)
		_c_ = ""
		for _i_ = 1 to _nL_
			if NOT isString(_l_[_i_]) loop ok
			if _i_ > 1 _c_ += _sep_ ok
			_c_ += _l_[_i_]
		next
		return _c_

	# Returns the scalar items joined into one string, with no separator.
	#
	#   returns    a string
	#   see        Concatenated
	def Concatenate()
		return This.ConcatenateXT("")

	# Returns the scalar items joined into one string, with no separator.
	#
	#   returns    a string
	#   see        Concatenate
	def Concatenated()
		return This.ConcatenateXT("")

	# NumbrifyQ / NumbrifiedQ: coerce string-items to numbers and
	# return the list wrapped. Test pattern: a CharsQ() walk that
	# then wants per-char numeric values.
	def NumbrifyQ()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				_aR_ + (0 + _v_)
			but isNumber(_v_)
				_aR_ + _v_
			ok
		next
		return new stzList(_aR_)

	def NumbrifiedQ()
		return This.NumbrifyQ()

	/*
		The collective question: does EVERY item satisfy this
		descriptor? Two forms, and the list form is the interesting one.

			Q([ 2, 4, 8 ]).Are(:Numbers)                       #--> 1
			Q([ 2, 4, 8 ]).Are([ :Even, :Positive, :Numbers ]) #--> 1
			Q([ "ONE", "TWO" ]).Are([ :Uppercase, :Latin, :Strings ])
			Q([ "你好", "亲" ]).Are([ :HanScript, :Texts ])

		A LIST OF DESCRIPTORS READS CONJUNCTIVELY -- every descriptor
		must hold for every item. By convention the last names the TYPE
		and the earlier ones are traits, but nothing here depends on
		that: [ :Uppercase, :Strings ] is simply Are(:Uppercase) AND
		Are(:Strings), which is why a one-element list behaves exactly
		like the scalar it contains.

		RESOLVING ONE DESCRIPTOR is a ladder, tried in order:
		  1. This.IsListOf<Desc>()      -- a collective answer exists
		  2. Q(item).Is<Desc>()         -- the item's own predicate
		  3. Q(item).Is<Singular>()     -- ...under its singular name
		  4. StzCharQ(item).Is<Sing>()  -- read as a CHAR (:Punctuation)
		and an unresolvable descriptor RAISES rather than answering 0 --
		"no predicate can judge this" and "every item failed" are
		different facts, and a collective check that conflates them
		would report a clean pass as a clean failure.

		The ladder asks ring_methods() what exists instead of calling
		and catching: a caught raise poisons the next string-to-number
		coercion in this VM, so exception-driven dispatch would leave a
		trap behind for whatever ran next.
	*/
	# TRUE if every item is of the given kind, such as :Strings or :Numbers.
	#
	#   p          a kind such as :Strings, :Numbers, :Uppercase, or a list of kinds that must all
	#              hold
	#   returns    TRUE or FALSE; FALSE for an empty list
	#   see        IsUppercase, IsLowercase
	#   example    ? o1.Are(:Strings)
	#              #--> TRUE
	#              ? o1.Are(:Numbers)
	#              #--> FALSE
	def Are(p)
		_l_ = This.List()
		if len(_l_) = 0
			return 0
		ok

		if isList(p)
			if len(p) = 0
				return 0
			ok
			_nAreD_ = len(p)
			for _iAreD_ = 1 to _nAreD_
				if NOT This.Are(p[_iAreD_])
					return 0
				ok
			next
			return 1
		ok

		_cAreD_ = StzLower("" + p)

		# 1. a collective predicate, when the list itself knows
		_cAreM_ = "islistof" + _cAreD_
		if StzFindFirst(_cAreM_, ring_methods(This)) > 0
			eval("_bAre_ = This." + _cAreM_ + "()")
			return _bAre_
		ok

		# 2-4. otherwise every item answers for itself
		_cAreSing_ = Singular(_cAreD_)
		_nAre_ = len(_l_)
		for _iAre_ = 1 to _nAre_
			if NOT This._AreItemIs(_l_[_iAre_], _cAreD_, _cAreSing_)
				return 0
			ok
		next
		return 1

	def _AreItemIs(pItem, pcDesc, pcSing)
		_oAreIt_ = Q(pItem)
		_aAreM_ = ring_methods(_oAreIt_)

		if StzFindFirst("is" + pcDesc, _aAreM_) > 0
			eval("_bAreOne_ = _oAreIt_.Is" + pcDesc + "()")
			return _bAreOne_
		ok
		if StzFindFirst("is" + pcSing, _aAreM_) > 0
			eval("_bAreOne_ = _oAreIt_.Is" + pcSing + "()")
			return _bAreOne_
		ok

		# a char-only trait (:Punctuation) read through the char face
		if isString(pItem) and StzLen(pItem) = 1
			_oAreCh_ = StzCharQ(pItem)
			_aAreCM_ = ring_methods(_oAreCh_)
			if StzFindFirst("is" + pcSing, _aAreCM_) > 0
				eval("_bAreOne_ = _oAreCh_.Is" + pcSing + "()")
				return _bAreOne_
			ok
		ok

		stzraise("stzList.Are(): nothing can judge '" + pcDesc + "' -- " +
			"no IsListOf" + pcDesc + "() on the list, and no Is" + pcDesc +
			"() / Is" + pcSing + "() on the item. Answering 0 here would " +
			"report an unanswerable question as a failed one.")

	# Returns the positions of the items that are a single space.
	#
	#   returns    a list of positions
	#   see        FindEmptyStrings
	def FindSpaces()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			if isString(_l_[_i_]) and _l_[_i_] = " " _aR_ + _i_ ok
		next
		return _aR_

	# Answers TRUE: the content is a list, not a string.
	#
	#   returns    TRUE
	def IsNotAString()
		return NOT isString(This.List())

	# Answers FALSE: the content of a stzList is a list, not a string.
	#
	#   returns    FALSE
	def IsAString()
		return isString(This.List())

	# Answers TRUE: the content of a stzList is a list.
	#
	#   returns    TRUE
	#   see        IsAString
	#@ aka  A LIST SAYS SO. stzObject answers 0 to all three of IsANumber(), IsAString() and IsAList(), expecting each class to override the one that is true of it -- stzString and stzNumber do, and this class overrode IsAString (above) but never IsAList.
	def IsAList()
		return isList(This.List())

	# TRUE if the other value is a list too.
	#
	#   p          the value to compare with
	#   returns    TRUE or FALSE
	#   see        IsList
	#@ aka  SAME SHAPE, SAME OMISSION. stzObject.HasSameTypeAs(p) answers isObject(p), and each wrapper overrides it to test the type it WRAPS -- stzNumber asks isNumber, stzString asks isString. stzList never asked isList, so comparing a stzList to a plain list said "different type", and IsStrictlyEqualTo() -- the conjunction of same type, same content and same order -- could never be true for the one compar
	def HasSameTypeAs(p)
		return isList(p)

	# TRUE if the content is not in lowercase.
	#
	#   returns    TRUE or FALSE
	#   see        Lowercase
	def IsNotInLowercase()
		_l_ = This.List()
		_nL_ = len(_l_)
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_) and _v_ != lower(_v_) return 1 ok
		next
		return 0

	# TRUE if every text item is in lowercase.
	#
	#   returns    TRUE or FALSE
	#   see        IsNotInLowercase
	def IsInLowercase()
		return NOT This.IsNotInLowercase()

	# TRUE if the item does not occur in the list.
	#
	#   p          the item to look for
	#   returns    TRUE or FALSE
	#   see        Contains
	def DoesNotContain(p)
		_l_ = This.List()
		_nL_ = len(_l_)
		for _i_ = 1 to _nL_
			if _l_[_i_] = p return 0 ok
		next
		return 1

	# Returns how many items are a single character.
	#
	#   returns    a number
	#   note       it counts single-character items, not the characters inside longer texts
	#   see        Chars
	#   example    o1 = new stzList([ "a", "bb", "c" ])
	#              ? o1.NumberOfChars()
	#              #--> 2
	def NumberOfChars()
		# Number of single-character ITEMS in the list (canonical, per
		# the monolith: len(Chars())). Not the total length of strings.
		return ring_len(This.Chars())

	def NumberOfCharsQ()
		# Char-count of every string item summed; wrap in stzNumber.
		_l_ = This.List()
		_nL_ = len(_l_)
		_n_ = 0
		for _i_ = 1 to _nL_
			if isString(_l_[_i_]) _n_ += len(_l_[_i_]) ok
		next
		return new stzNumber(_n_)

	# TRUE if every item of the list occurs in the other list.
	#
	#   pOther     the list to look in
	#   returns    TRUE or FALSE
	#   see        IsIncludedIn
	def AreIncludedIn(pOther)
		return This.EachItemExistsInCS(pOther, 1)  # plural = subset (every item of mine exists in pOther)

	# Returns the positions of the items that are objects.
	#
	#   returns    a list of numbers; [ ] when no item is an object
	#   see        Types
	#   example    ? @@( o1.FindObjects() )
	#              #--> [ ]
	#@ aka  FindObjects([pcExpr]): 0-arg = positions of every object item; 1-arg = ItemsWhere(pcExpr).
	def FindObjects()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			if isObject(_l_[_i_]) _aR_ + _i_ ok
		next
		return _aR_

	def ObjectsZ()
		# [ [name, [positions...]], ... ] grouped by object name in
		# first-seen order (@noname objects grouped together).
		_l_ = This.List()
		_nL_ = len(_l_)
		_acOzNames_ = []
		_aOzRes_ = []
		for _i_ = 1 to _nL_
			if NOT isObject(_l_[_i_]) loop ok
			_cOzN_ = "@noname"
			try
				_cOzN_ = _l_[_i_].ObjectName()
			catch
			done
			if NOT isString(_cOzN_) _cOzN_ = "@noname" ok
			_nOzAt_ = ring_find(_acOzNames_, _cOzN_)
			if _nOzAt_ = 0
				_acOzNames_ + _cOzN_
				_aOzRes_ + [ _cOzN_, [ _i_ ] ]
			else
				_aOzRes_[_nOzAt_][2] + _i_
			ok
		next
		return _aOzRes_

	def ObjectsZZ()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			if isObject(_l_[_i_]) _aR_ + [ _i_, _i_ ] ok
		next
		return _aR_

	# Returns the list as a stzTable, one row per item.
	#
	#   returns    a stzTable
	#   see        ToStzHashList
	#@ aka  The list turned into a stzTable object (rows; per the stzTable contract, the first row may carry the column names).
	def ToStzTable()
		return new stzTable(This.Content())

	# Returns each of the named objects with its position.
	#
	#   pacNames   the names of the objects to look for
	#   returns    a list of [ name, positions ] pairs
	#   see        FindNamedObjects
	def TheseObjectsZ(pacNames)
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		if NOT isList(pacNames) return _aR_ ok
		_nP_ = len(pacNames)
		for _j_ = 1 to _nP_
			_target_ = pacNames[_j_]
			if NOT isString(_target_) loop ok
			_kw_ = _target_
			if ring_left(_kw_, 1) = ":" _kw_ = StzMidToEnd(_kw_, 2) ok
			_kw_ = lower(_kw_)
			_aPos_ = []
			for _i_ = 1 to _nL_
				_v_ = _l_[_i_]
				if isObject(_v_)
					try
						_n_ = _v_.ObjectName()
						if isString(_n_) and lower(_n_) = _kw_
							_aPos_ + _i_
						ok
					catch
					done
				ok
			next
			if len(_aPos_) > 0 _aR_ + [ _kw_, _aPos_ ] ok
		next
		return _aR_

	def FindStzObjects()
		return This.FindObjects()

	# Returns the positions of the items that are Q objects.
	#
	#   returns    a list of positions
	#   see        FindStzObjects
	def FindQObjects()
		return []

	# Returns the positions of the items that are not Softanza objects.
	#
	#   returns    a list of positions
	#   see        FindStzObjects
	def FindNonStzObjects()
		return []

	# Returns the variable names of the items that are named objects.
	#
	#   returns    a list of names
	#   see        FindNamedObjects
	def ObjectsVarNames()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isObject(_v_)
				try
					_aR_ + _v_.ObjectName()
				catch
					_aR_ + ""
				done
			ok
		next
		return _aR_

	# Returns how many items are objects with a name.
	#
	#   returns    a number
	#   see        FindNamedObjects
	def NumberOfNamedObjects()
		return len(This.FindNamedObjects())

	# Returns how many items are objects without a name.
	#
	#   returns    a number
	#   see        NumberOfNamedObjects
	def NumberOfUnnamedObjects()
		return len(This.FindUnnamedObjects())

	# Returns how many items are objects.
	#
	#   returns    a number
	#   see        Objects
	def NumberOfObjects()
		return len(This.FindObjects())

	# Returns how many items are Softanza objects.
	#
	#   returns    a number
	#   see        NumberOfNonStzObjects
	def NumberOfStzObjects()
		return len(This.FindObjects())

	# Returns how many items are Q objects.
	#
	#   returns    a number
	#   see        FindQObjects
	def NumberOfQObjects()
		return 0

	# Returns how many items are not Softanza objects.
	#
	#   returns    a number
	#   see        NumberOfStzObjects
	def NumberOfNonStzObjects()
		return 0

	def ObjectsVarNamesU()
		_a_ = This.ObjectsVarNames()
		_nL_ = len(_a_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _a_[_i_]
			_bSeen_ = 0
			_nRL_ = len(_aR_)
			for _j_ = 1 to _nRL_
				if _aR_[_j_] = _v_ _bSeen_ = 1 exit ok
			next
			if NOT _bSeen_ _aR_ + _v_ ok
		next
		return _aR_

	# Returns how many distinct named objects the list holds.
	#
	#   returns    a number
	#   see        NumberOfNamedObjects
	def NumberOfUniqueNamedObjects()
		return len(This.ObjectsVarNamesU())

	def NamedObjects()
		return This.ObjectsVarNames()

	def UnamedObjects()
		return This.ObjectsVarNamesU()

	def UnnamedObjects()
		return This.FindUnnamedObjects()

	def TrimQ()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				_aR_ + ring_trim(_v_)
			else
				_aR_ + _v_
			ok
		next
		This._SetContent(_aR_)
		return This

	# Returns each string item split at the separator, as a list of lists.
	#
	#   pNamedUsing   the separator, or :Using = separator
	#   returns       a list of lists
	#   see           SplittedAt
	def StringsSplitted(pNamedUsing)
		_sep_ = " "
		if isList(pNamedUsing) and len(pNamedUsing) = 2 and isString(pNamedUsing[1]) and
		   lower(pNamedUsing[1]) = "using"
			_sep_ = pNamedUsing[2]
		but isString(pNamedUsing)
			_sep_ = pNamedUsing
		ok
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				_oS_ = new stzString(_v_)
				_aR_ + _oS_.Split(_sep_)
			else
				_aR_ + _v_
			ok
		next
		return _aR_

	# Returns each named object item with its variable name.
	#
	#   returns    a list of [ object, name ] pairs
	#   see        ObjectsVarNames
	def ObjectsAndTheirVarNames()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isObject(_v_)
				try
					_aR_ + [ _v_, _v_.ObjectName() ]
				catch
					_aR_ + [ _v_, "" ]
				done
			ok
		next
		return _aR_

	# Returns the positions of the items that are objects without a name.
	#
	#   returns    a list of positions
	#   see        FindNamedObjects
	def FindUnnamedObjects()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isObject(_v_)
				_bNamed_ = 0
				try
					_n_ = _v_.ObjectName()
					if isString(_n_) and _n_ != "" and _n_ != "@noname"
						_bNamed_ = 1
					ok
				catch
				done
				if NOT _bNamed_ _aR_ + _i_ ok
			ok
		next
		return _aR_

	# Returns the positions of the items that are objects with a name.
	#
	#   returns    a list of positions
	#   see        FindUnnamedObjects
	def FindNamedObjects()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isObject(_v_)
				try
					_n_ = _v_.ObjectName()
					if isString(_n_) and _n_ != "" and _n_ != "@noname"
						_aR_ + _i_
					ok
				catch
				done
			ok
		next
		return _aR_

	# Returns the positions where the given object occurs among the items.
	#
	#   pObj       the object to look for
	#   returns    a list of positions
	#   see        FindItem
	def FindObject(pObj)
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		# A string names the object: FindObject(:oGreeting) -> the
		# positions of objects carrying that name.
		if isString(pObj)
			_cFoN_ = lower(pObj)
			for _i_ = 1 to _nL_
				if NOT isObject(_l_[_i_]) loop ok
				_cFoV_ = ""
				try
					_cFoV_ = _l_[_i_].ObjectName()
				catch
				done
				if isString(_cFoV_) and lower(_cFoV_) = _cFoN_
					_aR_ + _i_
				ok
			next
			return _aR_
		ok
		for _i_ = 1 to _nL_
			if _l_[_i_] = pObj _aR_ + _i_ ok
		next
		return _aR_

	# Returns each object item with its position.
	#
	#   returns    a list of [ object, position ] pairs
	#   see        FindObject
	def ObjectsAndTheirPositions()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			if isObject(_l_[_i_]) _aR_ + [ _l_[_i_], _i_ ] ok
		next
		return _aR_

	def StringsW(pcExpr)
		# Filter to string items matching pcExpr.
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if NOT isString(_v_) loop ok
			@string = _v_
			@item = _v_
			@i = _i_
			_b_ = 0
			try
				eval("_b_ = " + pcExpr)
			catch
				_b_ = 0
			done
			if _b_ _aR_ + _v_ ok
		next
		return _aR_

	# Returns the items that meet the expression, where @item stands for each.
	#
	#   returns    a list of items
	#   see        FindW
	def ItemsWhere(pcExpr)
		if NOT isString(pcExpr) return [] ok
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			@item = _l_[_i_]
			@Item = @item
			@i = _i_
			@position = _i_
			_b_ = 0
			try
				eval("_b_ = " + pcExpr)
			catch
				_b_ = 0
			done
			if _b_ _aR_ + _l_[_i_] ok
		next
		return _aR_

	# Inserts the item after each of the given positions, in place.
	#
	#   panPositions   the positions to insert after
	#   returns        nothing; the list changes
	#   see            InsertBeforePositions
	def InsertAfterPositions(panPositions, pItem)
		if NOT isList(panPositions) return ok
		_aSorted_ = _ListCopy(panPositions)
		_nL_ = len(_aSorted_)
		# Sort descending so earlier inserts stay valid.
		for _i_ = 2 to _nL_
			_v_ = _aSorted_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aSorted_[_j_] < _v_
				_aSorted_[_j_ + 1] = _aSorted_[_j_]; _j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		# ring_insert places AT the position, so AFTER p means p + 1.
		# No trailing insert after the FINAL item (block #941).
		for _i_ = 1 to _nL_
			_p_ = _aSorted_[_i_]
			if isNumber(_p_) and _p_ >= 1 and _p_ < len(@aContent)
				This._InvalidateEngine()   # in-place @aContent mutation below
				ring_insert(@aContent, (_p_ + 1), pItem)
			ok
		next

	# Replaces the items at the given positions by the new items, one by one, in place.
	#
	#   _anPos_     the positions to replace
	#   paNewList   the new items, one per position
	#   returns     nothing; the list changes
	#   see         ReplaceOccurrencesByMany
	def ReplaceItemsAtPositionsByMany(_anPos_, paNewList)
		if NOT (isList(_anPos_) and isList(paNewList)) return ok
		# Flatten :And.
		_aNew_ = []
		_nNL_ = len(paNewList)
		for _i_ = 1 to _nNL_
			_v_ = paNewList[_i_]
			if isList(_v_) and len(_v_) = 2 and isString(_v_[1]) and
			   (lower(_v_[1]) = "and" or lower(_v_[1]) = "with")
				_aNew_ + _v_[2]
			else
				_aNew_ + _v_
			ok
		next
		_nPL_ = len(_anPos_)
		_nAL_ = len(_aNew_)
		_nMax_ = _nPL_
		if _nAL_ < _nMax_ _nMax_ = _nAL_ ok
		_l_ = This.List()
		_nLL_ = len(_l_)
		for _i_ = 1 to _nMax_
			_p_ = _anPos_[_i_]
			if isNumber(_p_) and _p_ >= 1 and _p_ <= _nLL_
				_l_[_p_] = _aNew_[_i_]
			ok
		next
		This._SetContent(_l_)


	# TRUE if every item of the list occurs in the other list.
	#
	#   pOther     the list to look in
	#   returns    TRUE or FALSE
	#   see        AreIncludedIn
	def IsIncludedIn(pOther)
		if NOT isList(pOther) return 0 ok
		_pList_ = This._EngineListFromContent()
		pOth = StzEngineMarshalList(pOther)
		_nResult_ = This.IsContainedInCS(pOther, 1)  # singular = whole-list-as-element (ExistsIn); AreIncludedIn = subset
		StzEngineListFree(_pList_)
		StzEngineListFree(pOth)
		return _nResult_

	# Returns how many items equal the first one, from the start.
	#
	#   returns    a number
	#   see        LeadingItems
	def NumberOfLeadingItems()
		_nLen_ = len(@aContent)
		if _nLen_ <= 1 return _nLen_ ok		#-- engine reports 0 for n<2
		_pList_ = This._EngineListFromContent()
		_nResult_ = StzEngineListLeadingCountCS(_pList_, 1)
		StzEngineListFree(_pList_)
		#-- engine returns 0 when the first item isn't repeated (run length 1);
		#-- our contract counts the first item itself, so map 0 -> 1.
		if _nResult_ = 0 return 1 ok
		return _nResult_

	# Returns how many items equal the last one, from the end.
	#
	#   returns    a number
	#   see        HasTrailingItems
	def NumberOfTrailingItems()
		_nLen_ = len(@aContent)
		if _nLen_ <= 1 return _nLen_ ok		#-- engine reports 0 for n<2
		_pList_ = This._EngineListFromContent()
		_nResult_ = StzEngineListTrailingCountCS(_pList_, 1)
		StzEngineListFree(_pList_)
		if _nResult_ = 0 return 1 ok
		return _nResult_

	# Replaces the run of leading items equal to the first by a new item, in place.
	#
	#   p1         the new item
	#   returns    nothing; the list changes
	#   see        ReplaceTrailingItems
	def ReplaceLeadingItems(p1)
		_new_ = p1
		if isList(p1) and len(p1) = 2 and isString(p1[1]) and
		   (lower(p1[1]) = "with" or lower(p1[1]) = "by")
			_new_ = p1[2]
		ok
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ = 0 return ok
		_first_ = _l_[1]
		for _i_ = 1 to _nL_
			if _l_[_i_] = _first_ _l_[_i_] = _new_ else exit ok
		next
		This._SetContent(_l_)

	# Replaces the run of trailing items equal to the last by a new item, in place.
	#
	#   p1         the new item
	#   returns    nothing; the list changes
	#   see        ReplaceLeadingItems
	def ReplaceTrailingItems(p1)
		_new_ = p1
		if isList(p1) and len(p1) = 2 and isString(p1[1]) and
		   (lower(p1[1]) = "with" or lower(p1[1]) = "by")
			_new_ = p1[2]
		ok
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ = 0 return ok
		_last_ = _l_[_nL_]
		for _i_ = _nL_ to 1 step -1
			if _l_[_i_] = _last_ _l_[_i_] = _new_ else exit ok
		next
		This._SetContent(_l_)

	# Replaces the run of leading items and the run of trailing items by a new item, in place.
	#
	#   p1         the new item
	#   returns    nothing; the list changes
	#   see        ReplaceLeadingItems
	def ReplaceLeadingAndTrailingItems(p1)
		This.ReplaceLeadingItems(p1)
		This.ReplaceTrailingItems(p1)

	# Returns the run of items equal to the first one.
	#
	#   returns    a list of items
	#   see        RepeatedLeadingItems
	def LeadingItems()
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ = 0 return [] ok
		_aR_ = []
		for _i_ = 1 to _nL_
			if _l_[_i_] = _l_[1] _aR_ + _l_[_i_] else exit ok
		next
		return _aR_

	# Returns the run of items equal to the last one.
	#
	#   returns    a list of items
	#   see        LeadingItems
	def TrailingItems()
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ = 0 return [] ok
		_aR_ = []
		for _i_ = _nL_ to 1 step -1
			if _l_[_i_] = _l_[_nL_] _aR_ + _l_[_i_] else exit ok
		next
		return _aR_

	# TRUE if the first two items are equal.
	#
	#   returns    TRUE or FALSE
	#   see        LeadingItems
	def HasLeadingItems()
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ < 2 return 0 ok
		return _l_[1] = _l_[2]

	# TRUE if the last two items are equal.
	#
	#   returns    TRUE or FALSE
	#   see        LeadingItems
	def HasTrailingItems()
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ < 2 return 0 ok
		return _l_[_nL_] = _l_[_nL_ - 1]

	# Returns every pair of items, taken in order, as two-item lists.
	#
	#   returns    a list of two-item lists
	def Combinations()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_ - 1
			for _j_ = _i_ + 1 to _nL_
				_aR_ + [ _l_[_i_], _l_[_j_] ]
			next
		next
		return _aR_

	# TRUE if the list is a pair whose first item is the keyword :AtChars, such as :AtChars = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsAtCharsNamedParam()
		_l_ = This.List()
		if len(_l_) != 2 return 0 ok
		if NOT isString(_l_[1]) return 0 ok
		_kw_ = lower(_l_[1])
		if ring_left(_kw_, 1) = ":" _kw_ = StzMidToEnd(_kw_, 2) ok
		return _kw_ = "atchars"

	# TRUE if the list is a named param whose name is one of the given names.
	#
	#   pacNames   the names to compare with, as a list of text
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsOneOfTheseNamedParams(pacNames)
		if NOT isList(pacNames) return 0 ok
		_l_ = This.List()
		if len(_l_) != 2 return 0 ok
		if NOT isString(_l_[1]) return 0 ok
		_kw_ = lower(_l_[1])
		if ring_left(_kw_, 1) = ":" _kw_ = StzMidToEnd(_kw_, 2) ok
		_nNL_ = len(pacNames)
		for _iN_ = 1 to _nNL_
			if NOT isString(pacNames[_iN_]) loop ok
			_target_ = lower(pacNames[_iN_])
			if ring_left(_target_, 1) = ":" _target_ = StzMidToEnd(_target_, 2) ok
			if _kw_ = _target_ return 1 ok
		next
		return 0

	# TRUE if the list is a pair whose first item is the keyword :Step, such as :Step = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsStepNamedParam()
		_l_ = This.List()
		return len(_l_) = 2 and isString(_l_[1]) and lower(_l_[1]) = "step"

	# TRUE if the list is a pair whose first item is the keyword :IsBoundedBy, such as :IsBoundedBy = value.
	#
	#   returns    TRUE or FALSE
	#   see        IsNamedParam
	def IsIsBoundedByNamedParam()
		_l_ = This.List()
		return len(_l_) = 2 and isString(_l_[1]) and
		       (lower(_l_[1]) = "isboundedby" or lower(_l_[1]) = "boundedby")

	# Returns each distinct item with how many times it occurs.
	#
	#   returns    a list of [ item, count ] pairs
	#   see        Frequencies
	def ItemsAndTheirNumberOfOccurrence()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aRes_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			_bSeen_ = 0
			_nRL_ = len(_aRes_)
			for _j_ = 1 to _nRL_
				if _aRes_[_j_][1] = _v_ _aRes_[_j_][2] = _aRes_[_j_][2] + 1 _bSeen_ = 1 exit ok
			next
			if NOT _bSeen_ _aRes_ + [ _v_, 1 ] ok
		next
		return _aRes_

	def HowManyST(pItem, pStartingAt)
		_nFrom_ = 1
		if isList(pStartingAt) and len(pStartingAt) = 2 and isString(pStartingAt[1]) and
		   lower(pStartingAt[1]) = "startingat"
			_nFrom_ = pStartingAt[2]
		but isNumber(pStartingAt)
			_nFrom_ = pStartingAt
		ok
		_l_ = This.List()
		_nL_ = len(_l_)
		_n_ = 0
		for _i_ = _nFrom_ to _nL_
			if BothAreEqualCS(_l_[_i_], pItem, 1) _n_++ ok
		next
		return _n_

	def NumberOfOccurrenceST(pItem, pStartingAt)
		return This.HowManyST(pItem, pStartingAt)

	def CountST(pItem, pStartingAt)
		return This.HowManyST(pItem, pStartingAt)

	# Returns the parts of the list that lie around each occurrence of the item.
	#
	#   returns    a list of lists
	#   see        SplitAtPosition
	def SplitAround(pItem)
		_l_ = This.List()
		_nL_ = len(_l_)
		_aRes_ = []
		_grp_ = []
		for _i_ = 1 to _nL_
			if BothAreEqualCS(_l_[_i_], pItem, 1)
				_aRes_ + _grp_
				_grp_ = []
			else
				_grp_ + _l_[_i_]
			ok
		next
		_aRes_ + _grp_
		return _aRes_

	# Returns each given character with all the positions where it occurs.
	#
	#   pacChars   the characters to look for
	#   returns    a list of [ character, positions ] pairs
	#   see        TheseItemsZ
	#@ aka  TheseCharsZ([chars]): each char grouped with ALL its positions in the list -- [ [c, [positions]], ... ].
	def TheseCharsZ(pacChars)
		if NOT isList(pacChars) return [] ok
		_l_ = This.List()
		_nL_ = ring_len(_l_)
		_nP_ = ring_len(pacChars)
		_aR_ = []
		for _j_ = 1 to _nP_
			_aPos_ = []
			for _i_ = 1 to _nL_
				if _l_[_i_] = pacChars[_j_] _aPos_ + _i_ ok
			next
			_aR_ + [ pacChars[_j_], _aPos_ ]
		next
		return _aR_

	# Returns the n items that follow the first occurrence of the anchor item.
	#
	#   pcAnchor   the item to count from
	#   _n_        how many items
	#   returns    a list of items
	#   see        NextNItems
	def NextNItemsAfter(pcAnchor, _n_)
		_l_ = This.List()
		_nL_ = len(_l_)
		_pos_ = 0
		for _i_ = 1 to _nL_
			if _l_[_i_] = pcAnchor _pos_ = _i_ exit ok
		next
		if _pos_ = 0 or _pos_ >= _nL_ return [] ok
		_end_ = _pos_ + _n_
		if _end_ > _nL_ _end_ = _nL_ ok
		_aR_ = []
		for _i_ = _pos_ + 1 to _end_
			_aR_ + _l_[_i_]
		next
		return _aR_

	  #-- NumberOfOccurrenceCS: count occurrences

	# How many times the given item occurs in the list.
	def NumberOfOccurrenceCS(pItem, pCaseSensitive)
		return len(This.FindAllOccurrencesCS(pItem, pCaseSensitive))

		def NumberOfOccurrencesCS(pItem, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pItem, pCaseSensitive)

		# Returns how many times the item occurs in the list.
		#
		#   pItem      the item to count
		#   returns    a number
		#   see        Count
		#   example    ? o1.NumberOfOccurrence("b")
		#              #--> 2
		def NumberOfOccurrence(pItem)
			return This.NumberOfOccurrenceCS(pItem, 1)

		# Returns how many times the item occurs in the list.
		#
		#   pItem      the item to count
		#   returns    a number
		#   see        Count, NumberOfOccurrence
		#   example    ? o1.NumberOfOccurrences("b")
		#              #--> 2
		def NumberOfOccurrences(pItem)
			return This.NumberOfOccurrenceCS(pItem, 1)

		def CountCS(pItem, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pItem, pCaseSensitive)

		# Returns how many times the item occurs in the list.
		#
		#   pItem      the item to count
		#   returns    a number
		#   see        NumberOfOccurrence, Find
		#   example    ? o1.Count("b")
		#              #--> 2
		#              ? o1.Count("z")
		#              #--> 0
		def Count(pItem)
			return This.NumberOfOccurrenceCS(pItem, 1)

	  #-- FindNthOccurrenceCS: find nth occurrence

	def FindNthOccurrenceCS(_n_, pItem, pCaseSensitive)
		if CheckingParams()
			if isString(_n_)
				if _n_ = :First or _n_ = :FirstOccurrence
					_n_ = 1
				but _n_ = :Last or _n_ = :LastOccurrence
					_n_ = This.NumberOfOccurrenceCS(pItem, pCaseSensitive)
				ok
			ok

			if isList(pItem) and IsOfNamedParamList(pItem)
				pItem = pItem[2]
			ok

			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				pCaseSensitive = pCaseSensitive[2]
			ok
		ok

		_anPositions_ = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
		_nLen_ = len(_anPositions_)

		if _n_ < 1 or _n_ > _nLen_
			return 0
		ok

		return _anPositions_[_n_]

		def FindNthCS(_n_, pItem, pCaseSensitive)
			return This.FindNthOccurrenceCS(_n_, pItem, pCaseSensitive)

		def NthOccurrenceCS(_n_, pItem, pCaseSensitive)
			return This.FindNthOccurrenceCS(_n_, pItem, pCaseSensitive)

	# Returns the position of the nth occurrence of the item.
	#
	#   _n_        which occurrence, counting from 1
	#   pItem      the item to look for
	#   returns    a number; 0 when there are fewer than n occurrences
	#   see        Find, FindFirst, FindLast
	#   example    ? o1.FindNth(2, "b")
	#              #--> 4
	#              ? o1.FindNth(3, "b")
	#              #--> 0
	#@ aka  Case-insensitive word-order aliases used by narrative tests. (Cannot live inside FindNthOccurrenceCS as nested defs because they take a different arity -- top-level methods instead.)
	def FindNth(_n_, pItem)
		return This.FindNthOccurrenceCS(_n_, pItem, 1)

		# Returns the position of the nth occurrence of the item, as FindNth does.
		#
		#   _n_        which occurrence, counting from 1
		#   pItem      the item to look for
		#   returns    a number; 0 when there are fewer than n
		#   see        FindNth
		#   example    ? o1.FindNthOccurrence(2, "b")
		#              #--> 4
		def FindNthOccurrence(_n_, pItem)
			return This.FindNthOccurrenceCS(_n_, pItem, 1)

	# Returns each run of consecutive number items as a [ start, end ] pair.
	#
	#   returns    a list of [ start, end ] pairs
	#   see        FindNumbers
	#@ aka  FindNumbersAsSections: scan content, return [[startPos,endPos],...] for each contiguous run of numeric items. Each section endpoint is a 1-based position in the original list. Single-number runs are returned as [pos, pos] (degenerate section).
	def FindNumbersAsSections()
		_aRes_ = []
		_aData_ = This.Content()
		_nLen_ = len(_aData_)
		_nStart_ = 0
		for _i_ = 1 to _nLen_
			if isNumber(_aData_[_i_])
				if _nStart_ = 0 _nStart_ = _i_ ok
			else
				if _nStart_ > 0
					_aRes_ + [ _nStart_, _i_ - 1 ]
					_nStart_ = 0
				ok
			ok
		next
		if _nStart_ > 0
			_aRes_ + [ _nStart_, _nLen_ ]
		ok
		return _aRes_

		def FindNumbersZZ()
			return This.FindNumbersAsSections()

		def NumbersAsSections()
			return This.FindNumbersAsSections()

	  #-- FindFirstOccurrenceCS / FindLastOccurrenceCS

	# The position of the FIRST occurrence of the item (0 if none).
	def FindFirstOccurrenceCS(pItem, pCaseSensitive)
		return This.FindNthOccurrenceCS(1, pItem, pCaseSensitive)

		def FindFirstCS(pItem, pCaseSensitive)
			return This.FindFirstOccurrenceCS(pItem, pCaseSensitive)

		# Returns the position of the first occurrence of the item.
		#
		#   pItem      the item to look for
		#   returns    a number; 0 when the item is absent
		#   see        Find, FindLast, FindNth
		#   example    ? o1.FindFirst("b")
		#              #--> 2
		#              ? o1.FindFirst("z")
		#              #--> 0
		def FindFirst(pItem)
			return This.FindFirstOccurrenceCS(pItem, 1)

	# Returns the position of the last occurrence of the item.
	#
	#   returns    a number
	#   see        FindFirstOccurrence
	def FindLastOccurrenceCS(pItem, pCaseSensitive)
		_anAll_ = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
		_nLen_ = len(_anAll_)
		if _nLen_ = 0
			return 0
		ok
		return _anAll_[_nLen_]

		def FindLastCS(pItem, pCaseSensitive)
			return This.FindLastOccurrenceCS(pItem, pCaseSensitive)

		# Returns the position of the last occurrence of the item.
		#
		#   pItem      the item to look for
		#   returns    a number; 0 when the item is absent
		#   see        FindFirst, Find
		#   example    ? o1.FindLast("b")
		#              #--> 4
		#              ? o1.FindLast("z")
		#              #--> 0
		def FindLast(pItem)
			return This.FindLastOccurrenceCS(pItem, 1)

	  #-- FindManyCS: find multiple items at once

	def FindManyCS(paItems, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_anResult_ = []
		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			_anPos_ = This.FindAllOccurrencesCS(paItems[_i_], pCaseSensitive)
			_nPosLen_ = len(_anPos_)
			for _j_ = 1 to _nPosLen_
				_anResult_ + _anPos_[_j_]
			next
		next

		# Ring 1.26 parser dislikes `new X(...).Sorted()` chaining
		# (raises R13 "Object is required" at the dot). Bind to a
		# local first.
		_oFmcsTmp_ = new stzList(_anResult_)
		return _oFmcsTmp_.Sorted()

		def FindMany(paItems)
			return This.FindManyCS(paItems, 1)

		# Fluent (Q) form: same result wrapped in a stzList so the
		# caller can pipe it through `/`, `Sorted()`, etc.
		def FindManyCSQ(paItems, pCaseSensitive)
			return new stzList(This.FindManyCS(paItems, pCaseSensitive))

		def FindManyQ(paItems)
			return new stzList(This.FindMany(paItems))

	  #-- ContainsManyCS: check if list contains multiple items

	def ContainsManyCS(paItems, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			if NOT This.ContainsCS(paItems[_i_], pCaseSensitive)
				return 0
			ok
		next

		return 1

		def ContainsMany(paItems)
			return This.ContainsManyCS(paItems, 1)

		# TRUE if every one of the given items occurs in the list.
		#
		#   returns    TRUE or FALSE
		#   see        ContainsAllOfThese
		def ContainsThese(paItems)
			return This.ContainsManyCS(paItems, 1)

		# TRUE if every one of the given items occurs in the list.
		#
		#   returns    TRUE or FALSE
		#   see        ContainsAllOfThese
		def ContainsEach(paItems)
			return This.ContainsManyCS(paItems, 1)

		# TRUE if every one of the given items occurs in the list.
		#
		#   returns    TRUE or FALSE
		#   see        ContainsAllOfThese
		def ContainsAll(paItems)
			return This.ContainsManyCS(paItems, 1)

		def ContainsTheseCS(paItems, pCaseSensitive)
			return This.ContainsManyCS(paItems, pCaseSensitive)

		def ContainsEachCS(paItems, pCaseSensitive)
			return This.ContainsManyCS(paItems, pCaseSensitive)

		def ContainsAllCS(paItems, pCaseSensitive)
			return This.ContainsManyCS(paItems, pCaseSensitive)

	  #-- RemoveAllCS: remove all occurrences of an item

	def RemoveAllCS(pItem, pCaseSensitive)
		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok

		_anPos_ = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
		_nLenPos_ = len(_anPos_)

		for _i_ = _nLenPos_ to 1 step -1
			This.RemoveItemAtPosition(_anPos_[_i_])
		next

		def RemoveAllCSQ(pItem, pCaseSensitive)
			This.RemoveAllCS(pItem, pCaseSensitive)
			return This

		# Removes every occurrence of the item, in place.
		#
		#   pItem      the item to remove
		#   returns    nothing; the list changes
		#   see        Remove, RemoveAt
		#   example    o1.RemoveAll("b")
		#              ? @@( o1.Content() )
		#              #--> [ "a", "c" ]
		def RemoveAll(pItem)
			This.RemoveAllCS(pItem, 1)

	  #-- FindW: find items matching a condition (eval-based)

	def FindAllItemsWCS(pcCondition, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		return This.FindAllItemsW(pcCondition)

		def FindWCS(pcCondition, pCaseSensitive)
			return This.FindAllItemsWCS(pcCondition, pCaseSensitive)

		def FindAllWCS(pcCondition, pCaseSensitive)
			return This.FindAllItemsWCS(pcCondition, pCaseSensitive)

	# Returns the positions of the items that meet the W condition.
	#
	#   returns    a list of positions
	#   see        FindW, CheckW
	def FindAllItemsW(pcCondition)
		#-- W is the single performant + expressive engine DSL (no eval).
		#-- It accepts the basic keywords (@item, @string, @i, This[@i+1]/
		#-- This[@i-1]) AND the expressive navigation keywords (@NextItem,
		#-- @PreviousItem, @NextNumber, ...): those are transpiled to the
		#-- This[@i +/- k] index form, then the scan is bounded to the
		#-- "executable section" so neighbour indices stay in range. The old
		#-- WXT form is gone -- W now does everything it did. Conditions that
		#-- need real Ring logic (calling methods, your own funcs) use the WF
		#-- family (FindWF/ItemsWF/CheckWF/...), not a textual condition.

		#-- Accept the :Where = '...' named-param form as well as a bare string.
		if isList(pcCondition) and IsWhereNamedParamList(pcCondition)
			pcCondition = pcCondition[2]
		ok

		_nLen_ = This.NumberOfItems()
		if _nLen_ = 0 return [] ok

		#-- Transpile the expressive navigation keywords (@NextItem -> This[@i+1],
		#-- etc.) only when present, so the simple path stays free of parse cost.
		#-- Using a navigation keyword also opts in to executable-section
		#-- bounding below (so neighbour access never steps out of range);
		#-- raw This[@i+k] index math stays unbounded (you own the bounds).
		_bNavKeyword_ = 0
		if ring_len( StzFindCS("@Next", pcCondition, 1) ) > 0 or
		   ring_len( StzFindCS("@Previous", pcCondition, 1) ) > 0
			pcCondition = StzCCodeQ(pcCondition).Transpiled()
			_bNavKeyword_ = 1
		ok

		pcCondition = _StzStripBraces(pcCondition)

		#-- Lower any Softanza Q(EXPR).Method(...) predicate to engine DSL so
		#-- conditions like Q(This[@i+1]).IsDoubleOf(This[@i-1]) evaluate.
		if ring_len( StzFindCS("Q(", pcCondition, 1) ) > 0
			pcCondition = _StzLowerWPredicates(pcCondition)
		ok

		#-- Executable-section bounds: keep neighbour indices in range (e.g. a
		#-- +1 look-ahead excludes the last position, which has no successor).
		#-- Applied only when an expressive navigation keyword was used.
		_nStart_ = 1
		_nEnd_ = _nLen_
		if _bNavKeyword_ and ring_len( StzFindCS("@i", pcCondition, 1) ) > 0
			_anSec_ = StzCCodeQ("{ " + pcCondition + " }").ExecutableSection()
			_nStart_ = _anSec_[1]
			_nEnd_   = _anSec_[2]

			if isString(_nEnd_)
				_nEnd_ = _nLen_
			but isNumber(_nEnd_) and _nEnd_ < 0
				_nEnd_ += _nLen_
			ok
			if isString(_nStart_)
				_nStart_ = 1
			ok
			if _nStart_ < 1 _nStart_ = 1 ok
			if _nEnd_ > _nLen_ _nEnd_ = _nLen_ ok
		ok

		_pList_ = This._Engine()
		if _pList_ = "" return [] ok
		# Engine returns a ready list of 1-based positions (built Zig-side).
		_anAll_ = StzEngineListFindAllW(_pList_, pcCondition)

		#-- Fast path: no bounding needed.
		if _nStart_ = 1 and _nEnd_ = _nLen_
			return _anAll_
		ok

		_anResult_ = []
		_nA_ = len(_anAll_)
		for _i_ = 1 to _nA_
			p = _anAll_[_i_]
			if p >= _nStart_ and p <= _nEnd_
				_anResult_ + p
			ok
		next
		return _anResult_

		def FindW(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def FindAllW(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def FindAllItemsWhere(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def FindWhere(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def ItemsPositionsW(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def ItemsAndTheirPositionsW(pcCondition)
			return _StzGroupItemsAtPos(This.Content(), This.FindAllItemsW(pcCondition))


		def PositionsW(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def PositionsWhere(pcCondition)
			return This.FindAllItemsW(pcCondition)

	#-- FindAllItemsW: the "extended" W scan. Unlike the plain W form, it
	#-- accepts the expressive Softanza keywords (@NextItem, @PreviousItem,
	#-- @NextNumber, ...) and the Q(EXPR).Method(...) predicate form. The
	#-- condition is transpiled to the basic This[@i+1]/This[@i-1] indexing
	#-- and any Q(...) predicate is lowered to engine DSL; the scan is then
	#-- bounded to the "executable section" so navigation indices stay in
	#-- range (e.g. with @NextItem the last position is excluded, since it
	#-- has no successor). Returns the matching 1-based POSITIONS.



	  #-- WF: anonymous-function constraints (full Ring power, no eval)

	def FindWF(pFunc)
		return _StzFindWF(This.Content(), pFunc)

		def FindAllWF(pFunc)
			return This.FindWF(pFunc)

		def PositionsWF(pFunc)
			return This.FindWF(pFunc)

	def CheckWF(pFunc)
		return _StzCheckWF(This.Content(), pFunc)

		def AllItemsWF(pFunc)
			return This.CheckWF(pFunc)

	# TRUE if every item meets the W condition.
	#
	#   returns    TRUE or FALSE
	#   see        FindW, FindAllItemsW
	#@ aka  -- CheckW: all items satisfy a W (DSL) condition. CheckW is the same -- now that the DSL is engine-backed (the perf/expressiveness split is gone).
	def CheckW(pcCondition)
		return ring_len(This.FindAllItemsW(pcCondition)) = This.NumberOfItems()

	#-- AllItemsVerifyW: readable alias of CheckW ("do ALL items verify ...?").
	#   Ring's NULL is the empty string, but the W-engine doesn't know the NULL
	#   token, so '@item != NULL' is normalized to '@item != ""' first -- making
	#   the idiomatic non-null-string check work.
	def AllItemsVerifyW(pcCondition)
		_cAivCond_ = StzReplace(pcCondition, " NULL", ' ""')
		return This.CheckW(_cAivCond_)

		def AllItemsVerify(pcCondition)
			return This.AllItemsVerifyW(pcCondition)

		def EachItemVerifiesW(pcCondition)
			return This.AllItemsVerifyW(pcCondition)


	# TRUE if the items at the given positions all meet the W condition.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsItemsAtW
	#@ aka  -- the items at panPos all satisfy a W (DSL) condition
	def CheckItemsAtW(panPos, pcCondition)
		return _StzAllIn(panPos, This.FindAllItemsW(pcCondition))

	#-- WF variants: the items at panPos all satisfy an anonymous function
	def CheckItemsAtWF(panPos, pFunc)
		return _StzCheckItemsAtWF(This.Content(), panPos, pFunc)

		def CheckOnWF(panPos, pFunc)
			return This.CheckItemsAtWF(panPos, pFunc)

	def CountWF(pFunc)
		return ring_len(This.FindWF(pFunc))

	def ItemsWF(pFunc)
		return This.ItemsAtPositions(This.FindWF(pFunc))

		def FilterWF(pFunc)
			return This.ItemsWF(pFunc)

		def ExtractWF(pFunc)
			return This.ItemsWF(pFunc)

		def StringsWF(pFunc)
			return This.ItemsWF(pFunc)

	def ContainsWF(pFunc)
		return This.CountWF(pFunc) > 0

	def NumberOfItemsWF(pFunc)
		return This.CountWF(pFunc)

		def HowManyItemsWF(pFunc)
			return This.CountWF(pFunc)

	def ItemsPositionsWF(pFunc)
		return This.FindWF(pFunc)

	def ItemsAndTheirPositionsWF(pFunc)
		return _StzGroupItemsAtPos(This.Content(), This.FindWF(pFunc))

	# Returns how many distinct items the named function gives.
	#
	#   pFunc      the name of a function applied to each item
	#   returns    a number
	#   see        NumberOfUniqueItemsW
	def CountUniqueItemsWF(pFunc)
		return ring_len(_StzUniqueItems(This.ItemsWF(pFunc)))

		def NumberOfUniqueItemsWF(pFunc)
			return This.CountUniqueItemsWF(pFunc)

	def UniqueItemsWF(pFunc)
		return _StzUniqueItems(This.ItemsWF(pFunc))

	#-- W-DSL twin: the unique items matching a W condition.
	def UniqueItemsW(pcCondition)
		return _StzUniqueItems(This.ItemsW(pcCondition))

	#-- the n-th / first / last item matching the function
	def NthItemWF(_n_, pFunc)
		_aWf_ = This.ItemsWF(pFunc)
		if _n_ >= 1 and _n_ <= ring_len(_aWf_) return _aWf_[_n_] ok
		return ""

	def FirstItemWF(pFunc)
		_aWf_ = This.ItemsWF(pFunc)
		if ring_len(_aWf_) > 0 return _aWf_[1] ok
		return ""

	def LastItemWF(pFunc)
		_aWf_ = This.ItemsWF(pFunc)
		if ring_len(_aWf_) > 0 return _aWf_[ ring_len(_aWf_) ] ok
		return ""

	#-- WF mutators / transforms (full Ring power, no eval)

	def RemoveWF(pFunc)
		This._SetContent(_StzRemoveWF(This.Content(), pFunc))

		def RemoveWFQ(pFunc)
			This.RemoveWF(pFunc)
			return This

	def ReplaceWF(pFunc, pNewItem)
		This._SetContent(_StzReplaceWF(This.Content(), pFunc, pNewItem))

	def MapWF(pFunc)
		return _StzMapWF(This.Content(), pFunc)

		def YieldWF(pFunc)
			return This.MapWF(pFunc)

	def InsertAfterWF(pFunc, pItem)
		This._SetContent(_StzInsertAfterWF(This.Content(), pFunc, pItem))

	def InsertBeforeWF(pFunc, pItem)
		This._SetContent(_StzInsertBeforeWF(This.Content(), pFunc, pItem))

	#-- PerformWF(condFunc, actionFunc): transform each matching item with
	#-- actionFunc; others unchanged. The eval-free form of PerformW(:if,:do).
	def PerformWF(pCondFunc, pActionFunc)
		This._SetContent(_StzPerformWF(This.Content(), pCondFunc, pActionFunc))

		def PerformWFQ(pCondFunc, pActionFunc)
			This.PerformWF(pCondFunc, pActionFunc)
			return This

	# Returns the items that stand at the given places, in the order given.
	#
	#   returns    a list of items
	#   see        NthItem
	#@ aka  -- FindW: the extended (expressive) where-scan. Returns the matching -- POSITIONS (use ItemsW for the items at those positions). It accepts -- @NextItem/@PreviousItem/... and the Q(EXPR).Method(...) predicate form.
	def ItemsAtPositions(panPos)
		if NOT isList(panPos)
			StzRaise("Incorrect param type! panPos must be a list.")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(panPos)
		_aResult_ = []

		for _i_ = 1 to _nLen_
			_aResult_ + _aContent_[panPos[_i_]]
		next

		return _aResult_

		def ItemsAtPositionsQ(panPos)
			return new stzList(This.ItemsAtPositions(panPos))

		def ItemsAt(panPos)
			return This.ItemsAtPositions(panPos)

	  #-- ExtendToPositionXT: extend list to a given position

	def ExtendToPositionXT(_n_, pWith)
		if isList(pWith) and IsWithOrByOrUsingNamedParamList(pWith)
			pWith = pWith[2]
		ok

		_nLen_ = This.NumberOfItems()
		if _n_ > _nLen_
			for _i_ = _nLen_ + 1 to _n_
				This.AddItem(pWith)
			next
		ok

		# Extends the list up to position n by adding the given item, in place.
		#
		#   _n_        the position to reach
		#   pWith      the item used to fill
		#   returns    nothing; the list changes
		#   see        ExtendToWith
		def ExtendToPositionWith(_n_, pWith)
			This.ExtendToPositionXT(_n_, pWith)

	# Pads the list up to position n, with 0 for a list of numbers and an empty text otherwise, in place.
	#
	#   _n_        the length to reach
	#   returns    nothing; the list changes. ExtendToXT chooses the padding item
	#   see        Extend
	#   example    o1.ExtendTo(6)
	#              ? @@( o1.Content() )
	#              #--> [ "a", "b", "c", "b", "", "" ]
	#@ aka  Sugar aliases over ExtendToPositionXT: the same operation but using the more natural "ExtendTo" / "Extend" naming. Default filler is the empty string.
	def ExtendTo(_n_)
		# Type-aware padding: 0 for an all-number list, "" otherwise
		# (ExtendToPosition decides). Use ExtendToXT(n, :With=v) to choose.
		This.ExtendToPosition(_n_)

		def ExtendToQ(_n_)
			This.ExtendTo(_n_)
			return This

		# Extends the list up to position n by adding the given item, in place.
		#
		#   _n_        the position to reach
		#   pWith      the item used to fill
		#   returns    nothing; the list changes
		#   see        ExtendToPosition
		def ExtendToWith(_n_, pWith)
			This.ExtendToPositionXT(_n_, pWith)

	# DifferenceWithXT: structured diff against another list.
	# Returns [ :added = [...], :removed = [...], :modified = [...] ].
	# Items in This but not in other are :added (from This's POV);
	# items in other but not in This are :removed; :modified is left
	# empty by this base form (used by stzGraph._CompareEdges where
	# edge identity is value-equality).

	def DifferenceWithXT(paOther)
		# :added and :removed are the two asymmetric differences, which the
		# engine computes with a HASH SET in O(n+m) -- and it keeps duplicates
		# (it walks every item of a, not the distinct values), which is the
		# documented contract here: DifferenceWith([:a,:c]) on [a,b,b,c,b] is
		# [ "b", "b", "b" ], test 636.
		#
		# The Ring loops below called ring_find -- a LINEAR scan of the other
		# list -- once per item, so this was O(n x m): 100k against 50k took
		# 17.64s, and doubling the input quadrupled it.

		_aDwAdded_ = []
		_aDwRemoved_ = []

		_pDwA_ = This._EngineListFromContent()
		_pDwB_ = StzEngineMarshalList(paOther)

		if _pDwA_ != "" and _pDwB_ != ""
			_pDwAdd_ = StzEngineListDifferenceCS(_pDwA_, _pDwB_, 1)
			_pDwRem_ = StzEngineListDifferenceCS(_pDwB_, _pDwA_, 1)

			_aDwAdded_ = StzEngineListContentToRingList(_pDwAdd_)
			_aDwRemoved_ = StzEngineListContentToRingList(_pDwRem_)

			StzEngineListFree(_pDwAdd_)
			StzEngineListFree(_pDwRem_)
			StzEngineListFree(_pDwA_)
			StzEngineListFree(_pDwB_)

			return [
				:added = _aDwAdded_,
				:removed = _aDwRemoved_,
				:modified = []
			]
		ok

		# Fallback for content the engine cannot marshal -- same semantics.
		_nDwLen_ = len(@aContent)
		for _iDw_ = 1 to _nDwLen_
			if ring_find(paOther, @aContent[_iDw_]) = 0
				_aDwAdded_ + @aContent[_iDw_]
			ok
		next
		_nDwOLen_ = len(paOther)
		for _iDw_ = 1 to _nDwOLen_
			if ring_find(@aContent, paOther[_iDw_]) = 0
				_aDwRemoved_ + paOther[_iDw_]
			ok
		next
		return [
			:added = _aDwAdded_,
			:removed = _aDwRemoved_,
			:modified = []
		]

		# Returns the items found in only one of the two lists.
		#
		#   returns    a list of items
		#   see        DiffWith, DifferentItemsWith
		def DifferenceWith(paOther)
			_aDwx_ = This.DifferenceWithXT(paOther)
			# Plain form: return only the symmetric difference items
			# (added + removed) without the modified bucket.
			_aDwRes_ = []
			_a_aDwx_added1_ = _aDwx_[:added]
			_n_aDwx_added1Len_ = len(_a_aDwx_added1_)
			for _iLoop_aDwx_added1_ = 1 to _n_aDwx_added1Len_
				_xDw_ = _a_aDwx_added1_[_iLoop_aDwx_added1_]
				_aDwRes_ + _xDw_
			next
			_a_aDwx_removed1_ = _aDwx_[:removed]
			_n_aDwx_removed1Len_ = len(_a_aDwx_removed1_)
			for _iLoop_aDwx_removed1_ = 1 to _n_aDwx_removed1Len_
				_xDw_ = _a_aDwx_removed1_[_iLoop_aDwx_removed1_]
				_aDwRes_ + _xDw_
			next
			return _aDwRes_

	# Cuts the list down to its first n items, in place.
	#
	#   _n_        how many items to keep
	#   returns    nothing; the list changes
	#   see        Shrink
	#@ aka  Shrink: truncate the list to the first n items (in place).
	def ShrinkTo(_n_)
		_nShLen_ = len(@aContent)
		if _n_ < 0
			_n_ = 0
		ok
		if _n_ >= _nShLen_
			return
		ok
		_aShNew_ = []
		for _iSh_ = 1 to _n_
			_aShNew_ + @aContent[_iSh_]
		next
		This._SetContent(_aShNew_)

		def ShrinkToQ(_n_)
			This.ShrinkTo(_n_)
			return This

		# Cuts the list down to its first n items, in place.
		#
		#   _n_        how many items to keep
		#   returns    nothing; the list changes
		#   see        TrimToSize
		def TruncateTo(_n_)
			This.ShrinkTo(_n_)

		# Keeps only the first n items, in place.
		#
		#   _n_        how many items to keep
		#   returns    nothing; the list changes
		#   see        Shrink
		def KeepFirst(_n_)
			This.ShrinkTo(_n_)

	# ExtendXT: named-param Extend DSL used by narrative tests.
	# Supported forms:
	#   ExtendXT( :List, :With = [...] )           -- append items
	#   ExtendXT( :List, :ToPosition = n )         -- pad to length n
	#   ExtendXT( :ToPosition = n, :With = x )     -- pad to n with x
	#   ExtendXT( :ToPosition = n, :WithItemsIn = [...] ) -- cycle items
	#   ExtendXT( :To = n, :WithItemsIn = [...] )  -- :To alias
	#   ExtendXT( :ToPosition = n, :ByItemsRepeated )    -- cycle self
	def ExtendXT(p1, p2)
		_nTo_ = 0
		_xWith_ = ""
		_xWithItemsIn_ = ""
		_bRepeat_ = 0

		_aArgs_ = [ p1, p2 ]
		for _i_ = 1 to 2
			_a_ = _aArgs_[_i_]
			if isList(_a_) and len(_a_) = 2 and isString(_a_[1])
				_k_ = _a_[1]
				if _k_ = :WithItemsIn
					_xWithItemsIn_ = _a_[2]
				but _k_ = :With
					_xWith_ = _a_[2]
				but _k_ = :ToPosition or _k_ = :To
					_nTo_ = _a_[2]
				ok
			but _a_ = :ByItemsRepeated
				_bRepeat_ = 1
			ok
		next

		if _nTo_ > 0
			if _xWithItemsIn_ != ""
				# distribute/cycle the supplied pool into the new slots
				return This.ExtendToWithItemsIn(_nTo_, _xWithItemsIn_)
			but _xWith_ != ""
				return This.ExtendToWith(_nTo_, _xWith_)
			but _bRepeat_
				_aSrc_ = This.Copy().Content()
				_nSrcLen_ = len(_aSrc_)
				if _nSrcLen_ = 0 return ok
				while len(@aContent) < _nTo_
					This._InvalidateEngine()   # in-place @aContent mutation below
					@aContent + _aSrc_[ ((len(@aContent)) % _nSrcLen_) + 1 ]
				end
				return
			else
				return This.ExtendTo(_nTo_)
			ok
		but _xWith_ != ""
			return This.Extend(_xWith_)
		ok

		def ExtendXTQ(p1, p2)
			This.ExtendXT(p1, p2)
			return This

	# Appends an item, or every item of a list, at the end of the list, in place.
	#
	#   pWith      an item, or a list whose items are appended one by one
	#   returns    nothing; the list changes. ExtendQ returns the object for chaining
	#   see        Add, ExtendTo
	#   example    o1.Extend([ "x", "y" ])
	#              ? @@( o1.Content() )
	#              #--> [ "a", "b", "c", "b", "x", "y" ]
	def Extend(pWith)
		# Append a single element (or a list of elements) to the list.
		if isList(pWith)
			_nWith1Len_ = len(pWith)
			for _iLoopWith1_ = 1 to _nWith1Len_
				_xExWi_ = pWith[_iLoopWith1_]
				This.AddItem(_xExWi_)
			next
		else
			This.AddItem(pWith)
		ok

		def ExtendQ(pWith)
			This.Extend(pWith)
			return This

		# Appends the item at the end, in place.
		#
		#   pWith      the item to append
		#   returns    nothing; the list changes
		#   see        AddItem
		def ExtendWith(pWith)
			This.Extend(pWith)

	# Replaces every item by the result of an expression applied to it, in place.
	#
	#   pcAction   the expression, as text, where @item stands for the current item
	#   returns    nothing; the list changes
	#   see        Map
	#   example    o1.Perform("@item + @item")
	#              ? @@( o1.Content() )
	#              #--> [ "aa", "bb", "cc", "bb" ]
	#@ aka  -- Perform: execute code on each item
	def Perform(pcAction)
		This._SetContent(This.Map(pcAction))

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	# Runs the action on the items at the given positions.
	#
	#   panPos     the positions to act on
	#   pcAction   the expression to run for each item
	#   returns    nothing; the items may change
	#   see        PerformAtW
	#@ aka  -- PerformOn: execute code on specific positions
	def PerformOn(panPos, pcAction)
		pcAction = _StzStripBraces(pcAction)
		_nLen_ = len(panPos)
		_pList_ = This._EngineListFromContent()
		if _pList_ = "" return ok

		pResult = StzEngineListMapExpr(_pList_, pcAction)
		_aNew_ = StzEngineListContentToRingList(pResult)

		for _i_ = 1 to _nLen_
			_nPos_ = panPos[_i_]
			if _nPos_ >= 1 and _nPos_ <= len(@aContent)
				This._InvalidateEngine()   # in-place @aContent mutation below
				@aContent[_nPos_] = _aNew_[_nPos_]
			ok
		next

		StzEngineListFree(pResult)
		StzEngineListFree(_pList_)

	  #-- Yield: execute code on each item and collect results

	def Yield(pcYielder)
		return This.Map(pcYielder)

		def YieldQ(pcYielder)
			return new stzList(This.Yield(pcYielder))

	# Returns the smallest number of the list.
	#
	#   returns    a number; 0 for an empty list
	#   see        Max, Sum
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? o1.Min()
	#              #--> 1
	#@ aka  smallest, minimum, lowest, least
	#@ aka  -- Min / Max for numeric lists
	def Min()
		if len(@aContent) = 0
			return 0
		ok

		# Engine-backed O(n) min
		_pList_ = This._EngineListFromContent()
		_nResult_ = StzEngineListMin(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def Smallest()
			return This.Min()

		def Lowest()
			return This.Min()

	# Returns the greatest number of the list.
	#
	#   returns    a number; 0 for an empty list
	#   see        Min, Sum, Mean
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? o1.Max()
	#              #--> 5
	#@ aka  largest, maximum, highest, biggest, greatest
	def Max()
		if len(@aContent) = 0
			return 0
		ok

		# Engine-backed O(n) max
		_pList_ = This._EngineListFromContent()
		_nResult_ = StzEngineListMax(_pList_)
		StzEngineListFree(_pList_)
		return _nResult_

		def Greatest()
			return This.Max()

		def Largest()
			return This.Max()

		def Highest()
			return This.Max()

	# Returns the sum of the numbers of the list.
	#
	#   returns    a number; 0 for an empty list
	#   see        Mean, Max
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? o1.Sum()
	#              #--> 14
	#@ aka  total, add up, aggregate, sum of the numbers
	#@ aka  -- Sum / Product / Mean (engine-backed)
	def Sum()
		if len(@aContent) = 0 return 0 ok
		_pSmList_ = This._Engine()
		_nSmResult_ = StzEngineListSum(_pSmList_)
		return _nSmResult_

	# Returns the product of the numbers of the list.
	#
	#   returns    a number
	#   see        Sum, Reduce
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? o1.Product()
	#              #--> 60
	#@ aka  multiply all, times all together, multiplied product
	def Product()
		if len(@aContent) = 0 return 0 ok
		_pPrList_ = This._Engine()
		_nPrResult_ = StzEngineListProduct(_pPrList_)
		return _nPrResult_

	# Returns the arithmetic mean of the numbers of the list.
	#
	#   returns    a number; 0 for an empty list
	#   see        Median, Sum, Max
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? o1.Mean()
	#              #--> 2.80
	def Mean()
		if len(@aContent) = 0 return 0 ok
		_pMnList_ = This._Engine()
		_nMnResult_ = StzEngineListMean(_pMnList_)
		return _nMnResult_

		#@ aka  mean, avg, typical value, arithmetic mean
		def Average()
			return This.Mean()

	# Returns the sample variance of the numbers of the list, dividing by n - 1.
	#
	#   returns    a number
	#   see        Stddev, Mean
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? o1.Variance()
	#              #--> 3.20
	#@ aka  spread, dispersion, sample variance
	#@ aka  -- Variance / StdDev (engine-backed)
	def Variance()
		# FIXED 2026-07-25: Variance() here returned the POPULATION variance while
		# stzDataSet returned the sample one, so the same data gave two answers
		# depending on which class you held. The divisor now comes from one place
		# in the engine (stats.varianceDivisor).
		if len(@aContent) = 0 return 0 ok
		_pVarList_ = This._Engine()
		_nVarResult_ = StzEngineListVariance(_pVarList_)
		return _nVarResult_

		# Returns the sample variance of the numbers in the list.
		#
		#   returns    a number
		#   see        VariancePopulation
		def VarianceSample()
			if len(@aContent) = 0 return 0 ok
			_pVsList_ = This._Engine()
			return StzEngineListVarianceSample(_pVsList_)

		# Returns the population variance of the numbers in the list.
		#
		#   returns    a number
		#   see        VarianceSample
		def VariancePopulation()
			if len(@aContent) = 0 return 0 ok
			_pVpList_ = This._Engine()
			return StzEngineListVariancePopulation(_pVpList_)

	# Returns the sample standard deviation of the numbers of the list.
	#
	#   returns    a number: the square root of Variance
	#   see        Variance, Mean
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? o1.Stddev()
	#              #--> 1.79
	def Stddev()
		if len(@aContent) = 0 return 0 ok
		_pSdList_ = This._Engine()
		_nSdResult_ = StzEngineListStddev(_pSdList_)
		return _nSdResult_

		def StandardDeviation()
			return This.Stddev()

		# Returns the sample standard deviation of the numbers in the list.
		#
		#   returns    a number
		#   see        StddevPopulation
		def StddevSample()
			if len(@aContent) = 0 return 0 ok
			_pSsList_ = This._Engine()
			return StzEngineListStddevSample(_pSsList_)

		# Returns the population standard deviation of the numbers in the list.
		#
		#   returns    a number
		#   see        VariancePopulation
		def StddevPopulation()
			if len(@aContent) = 0 return 0 ok
			_pSpList_ = This._Engine()
			return StzEngineListStddevPopulation(_pSpList_)

			def StandardDeviationSample()
				return This.StddevSample()

			def StandardDeviationPopulation()
				return This.StddevPopulation()

	# Returns the median of the numbers of the list.
	#
	#   returns    a number; 0 for an empty list
	#   see        Mean, Max
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? o1.Median()
	#              #--> 3
	#@ aka  middle value, midpoint, the median
	#@ aka  -- Median / Nth Smallest / Nth Largest (engine-backed)
	def Median()
		if len(@aContent) = 0 return 0 ok
		_pMdList_ = This._Engine()
		_nMdResult_ = StzEngineListMedian(_pMdList_)
		return _nMdResult_

	# Returns the nth smallest distinct value.
	#
	#   _n_        the rank, 1 for the smallest
	#   returns    the value
	#   see        NthLargest
	def NthSmallest(_n_)
		# The n-th smallest DISTINCT value (dedup, then ascending rank),
		# matching the monolith. (The engine NthSmallest ranks with
		# duplicates; dedup first so [3,3,7,8,8,10] -> 3rd smallest = 8.)
		if len(@aContent) = 0 return 0 ok
		_oNs_ = This.Copy()
		_oNs_.RemoveDuplicates()
		return _oNs_.Sorted()[_n_]

	# Returns the nth largest distinct value.
	#
	#   _n_        the rank, 1 for the largest
	#   returns    the value
	#   see        NthSmallest
	def NthLargest(_n_)
		if len(@aContent) = 0 return 0 ok
		_oNl_ = This.Copy()
		_oNl_.RemoveDuplicates()
		return _oNl_.SortedInDescending()[_n_]

	# Turns the content into n copies of the whole list, nested, in place.
	#
	#   _n_        how many copies
	#   returns    nothing; the list changes
	#   see        ExtendToWithItemsRepeated
	#@ aka  -- Repeat (engine-backed)
	def Repeat(_n_)
		if CheckParams()
			if isList(_n_) and len(_n_) = 2 and
			   isNumber(_n_[1]) and isString(_n_[2]) and
			   (_n_[2] = :NTimes or _n_[2] = :Times)

				_n_ = _n_[1]
			ok
		ok

		# Mutating, nesting (in place): [1,2].Repeat(3) -> [ [1,2], [1,2], [1,2] ].
		_aRptContent_ = This.Content()
		_aRptRes_ = []
		for _iRpt_ = 1 to _n_
			_aRptRes_ + _aRptContent_
		next
		This._SetContent(_aRptRes_)

		def RepeatQ(_n_)
			This.Repeat(_n_)
			return This

	# Returns a list that holds this list n times, nested.
	#
	#   _n_        how many times; n or n :Times is accepted
	#   returns    a list of n copies of the list
	#   note       it nests: for the flat repetition use MultiplyBy
	#   example    ? @@( o1.Repeated(2) )
	#              #--> [ [ "a", "b", "c", "b" ], [ "a", "b", "c", "b" ] ]
	def Repeated(_n_)
		if CheckParams()
			if isList(_n_) and len(_n_) = 2 and
			   isNumber(_n_[1]) and isString(_n_[2]) and
			   _n_[2] = :Times

				_n_ = _n_[1]
			ok
		ok

		# Repeating a list yields a list CONTAINING that list n times (NESTED):
		# [1,2].Repeated(3) -> [ [1,2], [1,2], [1,2] ]. (The flat concatenation
		# is the (*) operator's job: o1 * 3 -> [1,2,1,2,1,2].)
		_aRpdContent_ = This.Content()
		_aRpdOut_ = []
		for _iRpd_ = 1 to _n_
			_aRpdOut_ + _aRpdContent_
		next
		return _aRpdOut_

		def RepeatedNTimes(_n_)
			return This.Repeated(_n_)

		def RepeatNTimes(_n_)
			return This.Repeated(_n_)

	# Splits the list at a position into the items before it and the items from it.
	#
	#   _n_        the position where the second part starts
	#   returns    a list of two lists
	#   see        SplitBeforePositions
	#   example    ? @@( o1.SplitAt(2) )
	#              #--> [ [ "a" ], [ "b", "c", "b" ] ]
	#@ aka  -- SplitAt (engine-backed)
	def SplitAt(_n_)
		# The engine's stz_list_split_at takes the cut positions as an ENGINE
		# LIST handle (0-based cut indices), NOT a bare integer -- passing the
		# integer made the bridge read a bogus handle and the engine returned
		# NULL (so SplitAt silently fell back to [[],[]]). Build a 1-element
		# positions list at the 0-based cut (n-1) for the 1-based SplitAt(n).
		_pSaList_ = This._EngineListFromContent()
		if _pSaList_ = "" return [[], []] ok
		_pSaPos_ = (new stzList([ _n_ - 1 ]))._EngineListFromContent()
		_pSaResult_ = StzEngineListSplitAt(_pSaList_, _pSaPos_)
		StzEngineListFree(_pSaList_)
		if _pSaPos_ != "" StzEngineListFree(_pSaPos_) ok
		if _pSaResult_ = "" return [[], []] ok
		_aSaOut_ = StzEngineListContentToRingList(_pSaResult_)
		StzEngineListFree(_pSaResult_)
		return _aSaOut_

	# Returns the rank of each item in sorted order, equal items sharing the lowest rank.
	#
	#   returns    a list of numbers
	#   see        SortedBy
	#@ aka  -- Ranked (engine-backed)
	def Ranked()
		_pRkList_ = This._EngineListFromContent()
		if _pRkList_ = "" return [] ok
		_pRkResult_ = StzEngineListRanked(_pRkList_)
		StzEngineListFree(_pRkList_)
		if _pRkResult_ = "" return [] ok
		_aRkOut_ = StzEngineListContentToRingList(_pRkResult_)
		StzEngineListFree(_pRkResult_)
		return _aRkOut_

	# Returns the items joined into one string with the separator between them.
	#
	#   pcSep      the text put between two items
	#   returns    a string
	#   see        ToString
	#   example    ? o1.Join("-")
	#              #--> a-b-c-b
	#@ aka  concatenate, glue together, merge into one string
	#@ aka  -- Join (engine-backed)
	def Join(pcSep)
		_pJnList_ = This._EngineListFromContent()
		if _pJnList_ = "" return "" ok
		_cJnResult_ = StzEngineListJoin(_pJnList_, pcSep)
		StzEngineListFree(_pJnList_)
		return _cJnResult_

		def Joined(pcSep)
			return This.Join(pcSep)

	  #=========================================#
	 #  ADDITIONAL TYPE CHECKING METHODS       #
	#=========================================#

	# TRUE if every item is a hash list.
	#
	#   returns    TRUE or FALSE
	#   see        IsHashList
	def IsListOfHashLists()
		_aIlhContent_ = This.Content()
		_nIlhLen_ = len(_aIlhContent_)
		if _nIlhLen_ = 0
			return 0
		ok

		for _iIlh_ = 1 to _nIlhLen_
			if NOT isList(_aIlhContent_[_iIlh_])
				return 0
			ok
			_oIlhTemp_ = new stzList(_aIlhContent_[_iIlh_])
			if NOT _oIlhTemp_.IsHashList()
				return 0
			ok
		next

		return 1

	# TRUE if every item of the list is one of the given values.
	#
	#   returns    TRUE or FALSE
	#   see        IsMadeOf
	def IsMadeOfSome(paValues)
		_pList_ = This._EngineListFromContent()
		pVals = StzEngineMarshalList(paValues)
		_nResult_ = StzEngineListIsSubsetCS(_pList_, pVals, 1)
		StzEngineListFree(_pList_)
		StzEngineListFree(pVals)
		return _nResult_

	# TRUE if the list holds exactly two items and both are strings.
	#
	#   returns    TRUE or FALSE
	#   see        IsPairOfNumbers
	def IsPairOfStrings()
		_aIpContent_ = This.Content()
		if len(_aIpContent_) != 2
			return 0
		ok
		return isString(_aIpContent_[1]) and isString(_aIpContent_[2])

	  #=============================================#
	 #  DELEGATIONS TO DOMAIN SUBMODULES           #
	#=============================================#

	  #-----------------------------#
	 #  FINDER DELEGATIONS         #
	#-----------------------------#

	# The positions of the items DIFFERENT from the given item.
	def AntiFindCS(pItem, pCaseSensitive)
		_oAfFinder_ = new stzListFinder(This)
		return _oAfFinder_.AntiFindCS(pItem, pCaseSensitive)

	# Returns the positions of the items that differ from the given item.
	#
	#   returns    a list of positions
	#   see        FindItem
	def AntiFind(pItem)
		return This.AntiFindCS(pItem, 1)

	# The [start, end] sections of the runs of items DIFFERENT from
	# the given item.
	def AntiFindAsSectionsCS(pItem, pCaseSensitive)
		_oAfsaFinder_ = new stzListFinder(This)
		return _oAfsaFinder_.AntiFindAsSectionsCS(pItem, pCaseSensitive)

	# Returns the stretches of items that differ from the given item, as [ start, end ] pairs.
	#
	#   returns    a list of [ start, end ] pairs
	#   see        AntiFind
	def AntiFindAsSections(pItem)
		return This.AntiFindAsSectionsCS(pItem, 1)

		# Z-suffix: same as AntiFindAsSections.
		def AntiFindZZ(pItem)
			return This.AntiFindAsSections(pItem)

		def AntiFindAsSectionsZZ(pItem)
			return This.AntiFindAsSections(pItem)

		def AntiFindZZCS(pItem, pCaseSensitive)
			return This.AntiFindAsSectionsCS(pItem, pCaseSensitive)

	# Returns the positions that are not among the given ones.
	#
	#   _anPos_    the positions to leave out
	#   returns    a list of positions
	#   see        FindAntiSections
	def AntiPositions(_anPos_)
		_oApFinder_ = new stzListFinder(This)
		return _oApFinder_.AntiPositions(_anPos_)

	# AntiPositionsZZ: the complement of anPos as [start, end] sections.
	# Walks 1..NumberOfItems, grouping consecutive positions not in anPos.
	def AntiPositionsZZ(_anPos_)
		_aRes_ = []
		_nLen_ = This.NumberOfItems()
		_aIn_ = _anPos_
		_nStart_ = 0
		for _i_ = 1 to _nLen_
			_bInPos_ = 0
			_nIL_ = len(_aIn_)
			for _j_ = 1 to _nIL_
				if _aIn_[_j_] = _i_ _bInPos_ = 1 exit ok
			next
			if NOT _bInPos_
				if _nStart_ = 0 _nStart_ = _i_ ok
			else
				if _nStart_ > 0
					_aRes_ + [ _nStart_, _i_ - 1 ]
					_nStart_ = 0
				ok
			ok
		next
		if _nStart_ > 0
			_aRes_ + [ _nStart_, _nLen_ ]
		ok
		return _aRes_

	def FindNOccurrencesCS(_n_, pItem, pCaseSensitive)
		_oFnoFinder_ = new stzListFinder(This)
		return _oFnoFinder_.FindNOccurrencesCS(_n_, pItem, pCaseSensitive)

	# Returns the positions of the first n occurrences of the item.
	#
	#   _n_        how many occurrences
	#   returns    a list of positions
	#   see        FindGivenOccurrences
	#@ aka  The positions of the first n occurrences of the given item.
	def FindNOccurrences(_n_, pItem)
		return This.FindNOccurrencesCS(_n_, pItem, 1)

	# FindFirstCS/FindFirst/FindLastCS/FindLast already defined above as aliases

	def FindGivenOccurrencesCS(panOccurrences, pItem, pCaseSensitive)
		_oFgoFinder_ = new stzListFinder(This)
		return _oFgoFinder_.FindGivenOccurrencesCS(panOccurrences, pItem, pCaseSensitive)

	# Returns the positions of the given occurrences of the item, counted from 1.
	#
	#   panOccurrences   the ranks of the occurrences wanted
	#   returns          a list of positions
	#   see              FindNOccurrences
	def FindGivenOccurrences(panOccurrences, pItem)
		return This.FindGivenOccurrencesCS(panOccurrences, pItem, 1)

	def FindAllExceptFirstCS(pItem, pCaseSensitive)
		_oFaefFinder_ = new stzListFinder(This)
		return _oFaefFinder_.FindAllExceptFirstCS(pItem, pCaseSensitive)

	# Returns the positions of every occurrence of the item but the first.
	#
	#   returns    a list of positions
	#   see        FindAllExceptLast
	#@ aka  The positions of every occurrence of the item EXCEPT the first.
	def FindAllExceptFirst(pItem)
		return This.FindAllExceptFirstCS(pItem, 1)

	def FindAllExceptLastCS(pItem, pCaseSensitive)
		_oFaelFinder_ = new stzListFinder(This)
		return _oFaelFinder_.FindAllExceptLastCS(pItem, pCaseSensitive)

	# Returns the positions of every occurrence of the item but the last.
	#
	#   returns    a list of positions
	#   see        FindAllExceptFirst
	#@ aka  The positions of every occurrence of the item EXCEPT the last.
	def FindAllExceptLast(pItem)
		return This.FindAllExceptLastCS(pItem, 1)

	def FindNextNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)
		_oFnnoFinder_ = new stzListFinder(This)
		return _oFnnoFinder_.FindNextNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)

	# Returns the position of the nth occurrence of the item after a given position; 0 when there is none.
	#
	#   _n_        which occurrence, counted from the starting position
	#   returns    a number
	#   see        FindNextNth
	#@ aka  The position of the nth occurrence of the item AFTER the given position (0 when there is none).
	def FindNextNthOccurrence(_n_, pItem, pnStartingAt)
		return This.FindNextNthOccurrenceCS(_n_, pItem, pnStartingAt, 1)

	def FindNextOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		_oFnoFinder2_ = new stzListFinder(This)
		return _oFnoFinder2_.FindNextOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	# Returns the position of the next occurrence of the item after a given position; 0 when there is none.
	#
	#   returns    a number
	#   see        FindPreviousOccurrence
	#@ aka  The position of the next occurrence of the item after the given position (0 when there is none).
	def FindNextOccurrence(pItem, pnStartingAt)
		return This.FindNextOccurrenceCS(pItem, pnStartingAt, 1)

	# Returns the position of the next occurrence of the item after the given position.
	#
	#   pItem          the item to look for
	#   pnStartingAt   the position to start after; :StartingAt = n is accepted
	#   returns        a number; 0 when there is none
	#   see            FindPrevious, FindNth
	#   example        ? o1.FindNext("b", 2)
	#                  #--> 4
	#                  ? o1.FindNext("b", 4)
	#                  #--> 0
	#@ aka  FindNext: convenience wrapper used by narrative tests. Accepts either FindNext(item, n) or FindNext(item, :StartingAt = n).
	def FindNext(pItem, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		return This.FindNextOccurrenceCS(pItem, pnStartingAt, 1)

		def FindNextCS(pItem, pnStartingAt, pCaseSensitive)
			if isList(pnStartingAt) and len(pnStartingAt) = 2
				pnStartingAt = pnStartingAt[2]
			ok
			return This.FindNextOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	# Returns the position of the nearest occurrence of the item before the given position.
	#
	#   pItem          the item to look for
	#   pnStartingAt   the position to look before; :StartingAt = n is accepted
	#   returns        a number; 0 when there is none
	#   see            FindNext
	#   example        ? o1.FindPrevious("b", 4)
	#                  #--> 2
	#                  ? o1.FindPrevious("b", 2)
	#                  #--> 0
	#@ aka  The position of the nearest occurrence of the item BEFORE the given position (0 when there is none).
	def FindPrevious(pItem, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, 1)

		def FindPreviousCS(pItem, pnStartingAt, pCaseSensitive)
			if isList(pnStartingAt) and len(pnStartingAt) = 2
				pnStartingAt = pnStartingAt[2]
			ok
			return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	# Returns the position of the nth occurrence of the item, counting backward from a position.
	#
	#   _n_            which occurrence, counting from 1
	#   pItem          the item to look for
	#   pnStartingAt   the position to start from
	#   returns        a number; 0 when there are fewer than n
	#   see            FindPrevious, FindNth
	#   example        ? o1.FindNthPrevious(1, "b", 4)
	#                  #--> 2
	#                  ? o1.FindNthPrevious(2, "b", 4)
	#                  #--> 0
	#@ aka  FindNthPrevious(n, pItem, pnStartingAt): word-order alias over FindPreviousNthOccurrence -- find the Nth occurrence of pItem walking backwards from pnStartingAt. Accepts :StartingAt = n.
	def FindNthPrevious(_n_, pItem, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		return This.FindPreviousNthOccurrenceCS(_n_, pItem, pnStartingAt, 1)

		def FindNthPreviousCS(_n_, pItem, pnStartingAt, pCaseSensitive)
			if isList(pnStartingAt) and len(pnStartingAt) = 2
				pnStartingAt = pnStartingAt[2]
			ok
			return This.FindPreviousNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)

	# Returns the position of the nth occurrence of the item after a given position; 0 when there is none.
	#
	#   _n_        which occurrence, counted from the starting position
	#   returns    a number
	#   see        FindNextNth
	#@ aka  FindNthNext(n, pItem, pnStartingAt): symmetric forward variant.
	def FindNthNext(_n_, pItem, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		return This.FindNextNthOccurrenceCS(_n_, pItem, pnStartingAt, 1)

		def FindNthNextCS(_n_, pItem, pnStartingAt, pCaseSensitive)
			if isList(pnStartingAt) and len(pnStartingAt) = 2
				pnStartingAt = pnStartingAt[2]
			ok
			return This.FindNextNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)

	def FindPreviousNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)
		_oFpnoFinder_ = new stzListFinder(This)
		return _oFpnoFinder_.FindPreviousNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)

	# Returns the position of the nth occurrence of the item before a given position; 0 when there is none.
	#
	#   _n_        which occurrence, counted backwards from the starting position
	#   returns    a number
	#   see        FindPreviousNth
	#@ aka  The position of the nth occurrence of the item BEFORE the given position (0 when there is none).
	def FindPreviousNthOccurrence(_n_, pItem, pnStartingAt)
		return This.FindPreviousNthOccurrenceCS(_n_, pItem, pnStartingAt, 1)

	def FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		_oFpoFinder_ = new stzListFinder(This)
		return _oFpoFinder_.FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	# Returns the position of the nearest occurrence of the item before a given position; 0 when there is none.
	#
	#   returns    a number
	#   see        FindNextOccurrence
	#@ aka  The position of the nearest occurrence of the item before the given position (0 when there is none).
	def FindPreviousOccurrence(pItem, pnStartingAt)
		return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, 1)

	# Returns the position of the nth occurrence of the item after a given position; 0 when there is none.
	#
	#   _n_        which occurrence, counted from the starting position
	#   returns    a number
	#   see        FindNextNth
	#@ aka  -- Missing name-variants for the next/previous occurrence family -- (delegating to stzListFinder; strictly-after / strictly-before).
	def FindNthNextOccurrence(_n_, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindNthNextOccurrence(_n_, pItem, pnStartingAt)

	# Returns the position of the nth occurrence of the item after a given position; 0 when there is none.
	#
	#   _n_        which occurrence, counted from the starting position
	#   returns    a number
	#   see        FindPreviousNth, FindNthNext
	#@ aka  The position of the nth occurrence of the item after the given position.
	def FindNextNth(_n_, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindNextNth(_n_, pItem, pnStartingAt)

	# Returns the positions of every occurrence of the item after a given position.
	#
	#   returns    a list of positions
	#   see        FindNextNth
	#@ aka  The positions of ALL the occurrences after the given position.
	def FindNextOccurrences(pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindNextOccurrences(pItem, pnStartingAt)

		def FindNextOccurrencesST(pItem, pnStartingAt)
			return This.FindNextOccurrences(pItem, pnStartingAt)

	# Returns the positions of the nth next occurrence of the item, for each of the given ranks.
	#
	#   panN       the ranks of the occurrences wanted
	#   returns    a list of positions
	#   see        FindNextNth
	def FindNextNthOccurrencesST(panN, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindNextNthOccurrencesST(panN, pItem, pnStartingAt)

	# Returns the positions of every occurrence of the item before a given position.
	#
	#   returns    a list of positions
	#   see        FindPreviousOccurrence
	#@ aka  The positions of ALL the occurrences before the given position.
	def FindPreviousOccurrences(pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindPreviousOccurrences(pItem, pnStartingAt)

		def FindPreviousOccurrencesST(pItem, pnStartingAt)
			return This.FindPreviousOccurrences(pItem, pnStartingAt)

	# Returns the positions of the given ranks of previous occurrences of the item before a given position.
	#
	#   panN       the ranks of the occurrences wanted
	#   returns    a list of positions
	#   see        FindPreviousNth
	def FindPreviousNthOccurrences(panN, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindPreviousNthOccurrences(panN, pItem, pnStartingAt)

	# Returns the position of the first occurrence of the item after a given position.
	#
	#   returns    a number; 0 when none
	#   see        FindNextOccurrence
	#@ aka  The position of the first occurrence after the given position.
	def FindFirstNext(pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindFirstNext(pItem, pnStartingAt)

	# Returns the position of the first occurrence of the item before a given position, scanning backwards.
	#
	#   returns    a number; 0 when none
	#   see        FindPreviousOccurrence
	#@ aka  The position of the first occurrence before the given position (scanning backward).
	def FindFirstPrevious(pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindFirstPrevious(pItem, pnStartingAt)

	# Returns the positions of every occurrence of the item.
	#
	#   returns    a list of positions
	#   see        FindFirst, FindLast
	#@ aka  index of, position of, locate, where is, at what index
	#@ aka  The positions of every occurrence of the item (the Find contract).
	def FindItem(pItem)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindItem(pItem)

	# Returns the position of the nth occurrence of the item before a given position; 0 when there is none.
	#
	#   _n_        which occurrence, counted backwards from the starting position
	#   returns    a number
	#   see        FindNextNth
	#@ aka  The position of the nth occurrence before the given position.
	def FindPreviousNth(_n_, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindPreviousNth(_n_, pItem, pnStartingAt)

	# Returns the position of the nth occurrence of the item after a given position; 0 when there is none.
	#
	#   _n_        which occurrence, counted from the starting position
	#   returns    a number
	#   see        FindNextNth
	#@ aka  The position of the nth occurrence after the given position.
	def NthNextOccurrence(_n_, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.NthNextOccurrence(_n_, pItem, pnStartingAt)

	# Returns the position of the nth occurrence of the item after a given position; 0 when there is none.
	#
	#   _n_        which occurrence, counted from the starting position
	#   returns    a number
	#   see        FindNextNth
	#@ aka  The position of the nth occurrence after the given position.
	def NextNthOccurrence(_n_, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.NextNthOccurrence(_n_, pItem, pnStartingAt)

	  #=========================================================#
	 #  SMALLEST/LARGEST POSITIONS, ITEMS-WITH-POSITIONS, etc. #
	#=========================================================#

	# Returns the positions of the smallest value.
	#
	#   returns    a list of positions
	#   see        FindLargest
	def FindSmallest()
		return This.Find(This.Smallest())

		# Returns how many times the smallest value occurs.
		#
		#   returns    a number
		#   see        FindSmallest
		def NumberOfSmallest()
			return ring_len(This.FindSmallest())

		# Returns how many times the smallest value occurs.
		#
		#   returns    a number
		#   see        FindSmallest
		def NumberOfOccurrencesOfSmallestItem()
			return ring_len(This.FindSmallest())

	# Returns the positions of the largest value.
	#
	#   returns    a list of positions
	#   see        FindSmallest
	def FindLargest()
		return This.Find(This.Largest())

		# Returns how many times the largest value occurs.
		#
		#   returns    a number
		#   see        FindLargest
		def NumberOfLargest()
			return ring_len(This.FindLargest())

		# Returns how many times the largest value occurs.
		#
		#   returns    a number
		#   see        NumberOfLargest
		def NumberOfOccurrencesOfLargestItem()
			return ring_len(This.FindLargest())

	# Returns every distinct item with the positions where it occurs.
	#
	#   returns    a list of [ item, list of positions ] pairs, in order of first appearance
	#   see        Find, Classify
	#   example    ? @@( o1.FindItems() )
	#              #--> [ [ "a", [ 1 ] ], [ "b", [ 2, 4 ] ], [ "c", [ 3 ] ] ]
	#@ aka  -- [[item, [positions...]], ...] in first-appearance order
	def FindItems()
		return _StzItemsWithPositions(This.Content())

		def ItemsZ()
			return This.FindItems()

	# Returns each distinct item with its count, in order of first appearance, comparing by type as well as by value.
	#
	#   returns    a list of [ item, count ] pairs
	#   see        Frequencies
	#@ aka  -- [[item, count], ...] in first-appearance order (type-sensitive)
	def ItemsCount()
		return _StzItemsCount(This.Content())

	  #-------------------------------------------#
	 #  CONSECUTIVE-DUPLICATE ITEMS              #
	#-------------------------------------------#

	def FindDupSecutiveItemsCS(pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return _StzFindDupSecutive(This.Content(), pCaseSensitive)

	# Returns the positions of the items that repeat the one before them.
	#
	#   returns    a list of positions
	#   see        DupSecutiveItems
	#@ aka  The positions of the items that repeat consecutively.
	def FindDupSecutiveItems()
		return _StzFindDupSecutive(This.Content(), 1)

	# The items that repeat in consecutive runs (dup-secutive:
	# duplicated AND consecutive).
	def DupSecutiveItemsCS(pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return _StzDupSecutiveValues(This.Content(), pCaseSensitive)

	# Returns the items that occur twice or more in a row.
	#
	#   returns    a list of items
	#   see        FindDupSecutiveItems
	def DupSecutiveItems()
		return _StzDupSecutiveValues(This.Content(), 1)

	def FindThisDupSecutiveItemCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return _StzFindThisDupSecutive(This.Content(), pItem, pCaseSensitive)

	# Returns the positions where the given item repeats the one before it.
	#
	#   returns    a list of positions
	#   see        FindDupSecutiveItems
	#@ aka  The positions where the GIVEN item repeats consecutively.
	def FindThisDupSecutiveItem(pItem)
		return _StzFindThisDupSecutive(This.Content(), pItem, 1)

	def DupSecutiveItemsCSZ(pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return _StzDupSecutiveItemsZ(This.Content(), pCaseSensitive)

	def DupSecutiveItemsZ()
		return _StzDupSecutiveItemsZ(This.Content(), 1)

	# Returns the run of the given item that repeats directly, with its positions.
	#
	#   pItem      the item to look for
	#   returns    a list [ item, positions ]
	#   see        DupSecutiveItems
	#@ aka  The consecutive-duplicate run of the given item, along with its positions.
	def DupSecutiveItemCSZ(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return [ pItem, _StzFindThisDupSecutive(This.Content(), pItem, pCaseSensitive) ]

	# Returns the given item with the positions where it repeats the one before it.
	#
	#   pItem      the item to look for
	#   returns    a list [ item, positions ]
	#   see        DupSecutiveItems
	def DupSecutiveItemZ(pItem)
		return This.DupSecutiveItemCSZ(pItem, 1)

	# Collapse every consecutive-duplicate run to a single item (mutating).
	def RemoveDupSecutiveItemsCS(pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		This._SetContent(_StzRemoveDupSecutive(This.Content(), pCaseSensitive))

		def RemoveDupSecutiveItemsCSQ(pCaseSensitive)
			This.RemoveDupSecutiveItemsCS(pCaseSensitive)
			return This

	# Removes the items that repeat the one before them, in place.
	#
	#   returns    nothing; the list changes
	#   see        DupSecutiveItems
	def RemoveDupSecutiveItems()
		This.RemoveDupSecutiveItemsCS(1)

	# Collapse the consecutive-duplicate runs of the GIVEN item (mutating).
	def RemoveDupSecutiveItemCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		This._SetContent(_StzRemoveThisDupSecutive(This.Content(), pItem, pCaseSensitive))

	# Removes the repeats of the given item that follow it directly, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveDuplicatedItems
	def RemoveDupSecutiveItem(pItem)
		This.RemoveDupSecutiveItemCS(pItem, 1)

	# Returns the positions of the nth smallest value.
	#
	#   _n_        the rank, 1 for the smallest
	#   returns    a list of positions
	#   see        NthSmallest
	#@ aka  The position(s) of the nth smallest item.
	def FindNthSmallest(_n_)
		return This.Find(This.NthSmallest(_n_))

	# Returns the positions of the nth largest value.
	#
	#   _n_        the rank, 1 for the largest
	#   returns    a list of positions
	#   see        NthLargest
	#@ aka  The position(s) of the nth largest item.
	def FindNthLargest(_n_)
		return This.Find(This.NthLargest(_n_))

	# Returns each run of consecutive string or list items as a [ start, end ] pair.
	#
	#   returns    a list of [ start, end ] pairs
	#   see        FindNumbersAsSections
	#@ aka  -- contiguous runs of strings / lists as [start,end] sections
	def FindStringsAsSections()
		return _StzFindTypeRuns(This.Content(), "string")

		def FindStringsZZ()
			return This.FindStringsAsSections()

	# Returns each run of consecutive list items as a [ start, end ] pair.
	#
	#   returns    a list of [ start, end ] pairs
	#   see        FindNumbersAsSections
	#@ aka  The [start, end] runs of consecutive LIST items.
	def FindListsAsSections()
		return _StzFindTypeRuns(This.Content(), "list")

		def FindListsZZ()
			return This.FindListsAsSections()

	# Returns each run of consecutive object items as a [ start, end ] pair.
	#
	#   returns    a list of [ start, end ] pairs
	#   see        FindNumbersAsSections
	#@ aka  The [start, end] runs of consecutive OBJECT items.
	def FindObjectsAsSections()
		return _StzFindTypeRuns(This.Content(), "object")

		def FindObjectsZZ()
			return This.FindObjectsAsSections()

	# Returns the position of the first item equal to the given one, by type as well as by value.
	#
	#   returns    a number; 0 when absent
	#   see        FindItem
	#@ aka  -- first position type-sensitively equal to pItem ("2" != 2 != [2])
	def FindFirstOccurrence(pItem)
		return _StzFindFirstTyped(This.Content(), pItem)

	#-- positions of items NOT in paItems
	def FindAllExcept(paItems)
		return _StzFindAllExcept(This.Content(), paItems)

		def FindItemsOtherThan(paItems)
			return This.FindAllExcept(paItems)

	#-- "Origins" = the position of the FIRST occurrence of each
	#-- duplicated item (monolith authoritative semantics).
	def FindDuplicatesOrigins()
		return This.FindFirstDuplicates()

		def FindDuplicationsOrigins()
			return This.FindDuplicatesOrigins()

	  #=========================================================#
	 #  REMOVE FAMILY (occurrences / except / runs / dups)     #
	#=========================================================#

	# Removes every occurrence of the item, in place.
	#
	#   pItem      the item to remove
	#   returns    nothing; the list changes
	#   see        RemoveAll, RemoveAt, RemoveSection
	#   example    o1.Remove("b")
	#              ? @@( o1.Content() )
	#              #--> [ "a", "c" ]
	def Remove(pItem)
		This.RemoveAllCS(pItem, 1)

	def RemoveMany(paItems)
		_nLen_ = ring_len(paItems)
		for _i_ = 1 to _nLen_
			This.RemoveAllCS(paItems[_i_], 1)
		next

		# Removes every occurrence of each of the given items, in place.
		#
		#   returns    nothing; the list changes
		#   see        RemoveItemsOtherThan
		def RemoveTheseItems(paItems)
			This.RemoveMany(paItems)

	#-- keep only items that are members of paItems (drop everything else)
	def RemoveAllExcept(paItems)
		_items_ = paItems
		if NOT isList(paItems)
			_items_ = [ paItems ]
		ok
		This._SetContent(_StzKeepMembers(This.Content(), _items_))

		# Removes every item that is not among the given ones, in place.
		#
		#   returns    nothing; the list changes
		#   see        RemoveTheseItems
		def RemoveItemsOtherThan(paItems)
			This.RemoveAllExcept(paItems)

	# Removes the given occurrences of the item, counted from 1, in place.
	#
	#   panOcc     the ranks of the occurrences to remove
	#   returns    nothing; the list changes
	#   see        RemoveNth
	#@ aka  -- remove the panOcc-th occurrences of pItem (by occurrence index)
	def RemoveOccurrences(panOcc, pItem)
		_pos_ = This.FindAllCS(pItem, 1)
		This._SetContent(_StzRemoveAtPositions(This.Content(), _StzPickPositions(panOcc, _pos_)))

	# Removes the given item from the start of the list, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveAnyItemFromEnd
	def RemoveAnyItemFromStart(pItem)
		This._SetContent(_StzRemoveLeadingRun(This.Content(), pItem))

	# Removes the given item from the end of the list, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveAnyItemFromStart
	def RemoveAnyItemFromEnd(pItem)
		This._SetContent(_StzRemoveTrailingRun(This.Content(), pItem))

	# Removes the items that occur only once, in place.
	#
	#   returns    nothing; the list changes
	#   see        NonDuplicatedItems
	def RemoveNonDuplicates()
		This._SetContent(_StzRemoveNonDuplicates(This.Content()))

	# Removes the nth occurrence of the item, in place.
	#
	#   _n_        which occurrence
	#   returns    nothing; the list changes
	#   see        RemoveNth
	#@ aka  -- remove the n-th occurrence of pItem
	def RemoveThisNthItem(_n_, pItem)
		_pos_ = This.FindAllCS(pItem, 1)
		if _n_ >= 1 and ring_len(_pos_) >= _n_
			This._SetContent(_StzRemoveAtPositions(This.Content(), [ _pos_[_n_] ]))
		ok

		# Removes the nth occurrence of the item, in place.
		#
		#   _n_        which occurrence
		#   returns    nothing; the list changes
		#   see        RemoveFirst
		def RemoveNth(_n_, pItem)
			This.RemoveThisNthItem(_n_, pItem)

	# Removes the nth occurrence of the item after a given position, in place.
	#
	#   _n_        which occurrence, counted from the starting position
	#   returns    nothing; the list changes
	#   see        RemovePreviousNthOccurrence
	#@ aka  -- occurrence removal relative to a position (Next strictly after, -- Previous strictly before; the Nth index is forward into that run)
	def RemoveNextNthOccurrence(_n_, pItem, pnStartingAt)
		_p_ = This.FindNthNextOccurrence(_n_, pItem, pnStartingAt)
		if _p_ > 0
			This._SetContent(_StzRemoveAtPositions(This.Content(), [ _p_ ]))
		ok

	# Removes the given ranks of occurrences of the item after a position, in place.
	#
	#   panN       the ranks of the occurrences to remove
	#   returns    nothing; the list changes
	#   see        RemoveNextNthOccurrence
	def RemoveNextNthOccurrences(panN, pItem, pnStartingAt)
		_ps_ = This.FindNextNthOccurrencesST(panN, pItem, pnStartingAt)
		This._SetContent(_StzRemoveAtPositions(This.Content(), _ps_))

		# Returns a copy without the given ranks of next occurrences of the item after a position; the list is unchanged.
		#
		#   panN       the ranks of the occurrences to remove
		#   returns    a list of items
		#   see        RemoveNextNthOccurrences
		def NextNthOccurrencesRemoved(panN, pItem, pnStartingAt)
			_ps_ = This.FindNextNthOccurrencesST(panN, pItem, pnStartingAt)
			return _StzRemoveAtPositions(This.Content(), _ps_)

	# Removes the nth occurrence of the item before a given position, in place.
	#
	#   _n_        which occurrence, counted backwards
	#   returns    nothing; the list changes
	#   see        RemoveNextNthOccurrence
	def RemovePreviousNthOccurrence(_n_, pItem, pnStartingAt)
		_ps_ = This.FindPreviousNthOccurrences([ _n_ ], pItem, pnStartingAt)
		if ring_len(_ps_) > 0
			This._SetContent(_StzRemoveAtPositions(This.Content(), [ _ps_[1] ]))
		ok

	# Removes the given ranks of occurrences of the item before a position, in place.
	#
	#   panN       the ranks of the occurrences to remove
	#   returns    nothing; the list changes
	#   see        RemovePreviousNthOccurrence
	def RemovePreviousNthOccurrences(panN, pItem, pnStartingAt)
		_ps_ = This.FindPreviousNthOccurrences(panN, pItem, pnStartingAt)
		This._SetContent(_StzRemoveAtPositions(This.Content(), _ps_))

		# Returns a copy without the given ranks of previous occurrences of the item before a position; the list is unchanged.
		#
		#   panN       the ranks of the occurrences to remove
		#   returns    a list of items
		#   see        RemovePreviousNthOccurrences
		def PreviousNthOccurrencesRemoved(panN, pItem, pnStartingAt)
			_ps_ = This.FindPreviousNthOccurrences(panN, pItem, pnStartingAt)
			return _StzRemoveAtPositions(This.Content(), _ps_)

	# Removes the first occurrence of the item, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveNth, RemoveLast
	#@ aka  -- remove the first occurrence of pItem
	def RemoveFirst(pItem)
		This.RemoveThisNthItem(1, pItem)

		# Removes the first occurrence of the item, in place.
		#
		#   returns    nothing; the list changes
		#   see        RemoveFirst
		def RemoveThisFirstItem(pItem)
			This.RemoveFirst(pItem)

	def RemoveThisFirstItemCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		_pos_ = This.FindAllCS(pItem, pCaseSensitive)
		if ring_len(_pos_) > 0
			This._SetContent(_StzRemoveAtPositions(This.Content(), [ _pos_[1] ]))
		ok

	# Removes the item at position n, in place; :First and :Last are accepted.
	#
	#   _n_        the position to remove
	#   returns    nothing; the list changes
	#   see        RemoveItemAtPosition
	#@ aka  -- remove the item at position n; accepts :First / :Last
	def RemoveNthItem(_n_)
		if isString(_n_)
			if _n_ = :Last or _n_ = :LastItem
				_n_ = This.NumberOfItems()
			but _n_ = :First or _n_ = :FirstItem
				_n_ = 1
			ok
		ok
		This.RemoveItemAtPosition(_n_)

	  #=========================================================#
	 #  CONTAINS predicates (no / both / each / only-one / by-type) #
	#=========================================================#

	# TRUE if the item does not occur in the list.
	#
	#   returns    TRUE or FALSE
	#   see        Contains
	def ContainsNo(pItem)
		return NOT This.Contains(pItem)

	# TRUE if both of the given items occur in the list.
	#
	#   p1         the first item
	#   p2         the second item
	#   returns    TRUE or FALSE
	#   see        ContainsEach
	def ContainsBoth(p1, p2)
		return This.Contains(p1) and This.Contains(p2)

	def ContainsEachOneOfThese(paItems)
		return This.ContainsEach(paItems)

	# TRUE if exactly one distinct item among the given ones occurs in the list.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsOneOfThese
	#@ aka  -- TRUE iff exactly ONE distinct member of paItems is present
	def ContainsOnlyOneOfThese(paItems)
		return _StzCountMembersPresent(This.Content(), paItems) = 1

	# TRUE if no item is an object.
	#
	#   returns    TRUE or FALSE
	#   see        Objects
	def ContainsNoObjects()
		return NOT _StzContainsType(This.Content(), "object")

	# TRUE if at least one item is an object.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsNoObjects
	def ContainsObjects()
		return _StzContainsType(This.Content(), "object")

	# TRUE if at least one item is a list.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsNoObjects
	def ContainsOneOrMoreLists()
		return _StzContainsType(This.Content(), "list")

		def ContainsLists()
			return This.ContainsOneOrMoreLists()

	# TRUE if no item is a number.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsNoStrings
	def ContainsNoNumbers()
		return NOT _StzContainsType(This.Content(), "number")

	# TRUE if no item is a string.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsNoNumbers
	def ContainsNoStrings()
		return NOT _StzContainsType(This.Content(), "string")

	  #=========================================================#
	 #  SINGLES (1-elem lists) and PAIRS (2-elem lists)        #
	#=========================================================#

	# TRUE if the list holds exactly one item.
	#
	#   returns    TRUE or FALSE
	#   see        IsPair
	def IsSingle()
		return ring_len(@aContent) = 1

	# Returns the positions of the items that are lists of one item.
	#
	#   returns    a list of positions
	#   see        Singles
	def FindSingles()
		return _StzFindListsOfLen(This.Content(), 1)

	# Returns the items that are lists of one item.
	#
	#   returns    a list of one-item lists
	#   see        FindSingles
	def Singles()
		return _StzItemsAtPos(This.Content(), This.FindSingles())

	def SinglesU()
		return _StzUniqueItems(This.Singles())

	def SinglesZ()
		return _StzGroupItemsAtPos(This.Content(), This.FindSingles())

	# TRUE if at least one item is a list of one item.
	#
	#   returns    TRUE or FALSE
	#   see        FindSingles
	def ContainsSingles()
		return ring_len(This.FindSingles()) > 0

	# Returns each item wrapped in a one-item list.
	#
	#   returns    a list of one-item lists
	#   see        Pairified
	def Singlified()
		return _StzSinglified(This.Content())

	# Returns the positions of the items that are pairs, lists of two items.
	#
	#   returns    a list of positions
	#   see        Pairs
	def FindPairs()
		return _StzFindListsOfLen(This.Content(), 2)

	# Returns the items that are pairs, lists of two items.
	#
	#   returns    a list of pairs
	#   see        Pairs
	def ItemsThatArePairs()
		return _StzItemsAtPos(This.Content(), This.FindPairs())

	def PairsU()
		return _StzUniqueItems(This.ItemsThatArePairs())

	def PairsZ()
		return _StzGroupItemsAtPos(This.Content(), This.FindPairs())

	# TRUE if at least one item is a pair, a list of two items.
	#
	#   returns    TRUE or FALSE
	#   see        FindPairs
	def ContainsPairs()
		return ring_len(This.FindPairs()) > 0

	# Returns each item as the first of a two-item list whose second item is empty.
	#
	#   returns    a list of two-item lists
	#   see        Singlified
	def Pairified()
		return _StzPairified(This.Content())

	  #=========================================================#
	 #  ITEMS / THESE-ITEMS family                             #
	#=========================================================#

	# Returns each given item with the positions where it occurs, empty lists included.
	#
	#   returns    a list of [ item, positions ] pairs
	#   see        FindTheseItems
	#@ aka  -- [[item,[positions]],...] for each given item (includes empties)
	def TheseItemsZ(paItems)
		return _StzTheseItemsZ(This.Content(), paItems)

	# Returns the distinct items that occur at least n times.
	#
	#   _n_        the number of occurrences
	#   returns    a list of items
	#   see        ItemsAppearingNTimes
	#@ aka  -- distinct items by occurrence count (>= n by default)
	def ItemsOccurringNTimes(_n_)
		return _StzItemsByCountOp(This.Content(), _n_, "ge")

		def ItemsOccuringNTimes(_n_)
			return This.ItemsOccurringNTimes(_n_)

		def ItemsOccurringNTimesOrMore(_n_)
			return This.ItemsOccurringNTimes(_n_)

	# Returns the distinct items that occur exactly n times.
	#
	#   _n_        the number of occurrences
	#   returns    a list of items
	#   see        ItemsAppearingNTimes
	def ItemsOccurringExactlyNTimes(_n_)
		return _StzItemsByCountOp(This.Content(), _n_, "eq")

		def ItemsOccuringExactlyNTimes(_n_)
			return This.ItemsOccurringExactlyNTimes(_n_)

	# Returns the distinct items that occur fewer than n times.
	#
	#   _n_        the number of occurrences
	#   returns    a list of items
	#   see        ItemsOccurringNTimes
	def ItemsOccurringLessThanNTimes(_n_)
		return _StzItemsByCountOp(This.Content(), _n_, "lt")

	# Returns the distinct items that occur n times or fewer.
	#
	#   _n_        the number of occurrences
	#   returns    a list of items
	#   see        ItemsOccurringNTimes
	def ItemsOccurringNTimesOrLess(_n_)
		return _StzItemsByCountOp(This.Content(), _n_, "le")

	# Returns the distinct items that occur more than n times.
	#
	#   _n_        the number of occurrences
	#   returns    a list of items
	#   see        ItemsAppearingNTimes
	def ItemsOccurringMoreThanNTimes(_n_)
		return _StzItemsByCountOp(This.Content(), _n_, "gt")

	# TRUE if every item has the same type.
	#
	#   returns    TRUE or FALSE
	#   see        UniqueTypes
	def ItemsHaveSameType()
		return _StzAllSameType(This.Content())

		def AllItemsHaveSameType()
			return This.ItemsHaveSameType()

	# TRUE if every item is an empty list.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfEmptyLists
	def ItemsAreEmptyLists()
		return _StzAllEmptyLists(This.Content())

	def ItemsAreEqualToCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return _StzAllEqualCS(This.Content(), pItem, pCaseSensitive)

	# TRUE if every item equals the given value.
	#
	#   returns    TRUE or FALSE
	#   see        AllItemsAreEqual
	def ItemsAreEqualTo(pItem)
		return _StzAllEqualTyped(This.Content(), pItem)

		def ContainsOnly(pItem)
			# Route type symbols (:Number, :Numbers, :Strings, ...) through the
			# type-check; otherwise fall back to value equality.
			return This.AllItemsAre(pItem)

		def ContainsOnlyCS(pItem, pCaseSensitive)
			return This.ItemsAreEqualToCS(pItem, pCaseSensitive)

	# TRUE if every item meets the W condition.
	#
	#   returns    TRUE or FALSE
	#   see        CheckW
	#@ aka  -- all items satisfy a W-condition
	def ItemsHaveXT(pcCondition)
		return ring_len(This.FindAllItemsW(pcCondition)) = This.NumberOfItems()

		def AllItemsHaveXT(pcCondition)
			return This.ItemsHaveXT(pcCondition)

	#-- positions matching a W-condition (+ grouped form)


	  #=========================================================#
	 #  INSERT after/before many positions / by W-condition    #
	#=========================================================#

	# Inserts the item after each of the given positions, in place.
	#
	#   returns    nothing; the list changes
	#   see        InsertAfterPositions
	def InsertAfterManyPositions(panPos, pItem)
		This._SetContent(_StzInsertAfterPositions(This.Content(), panPos, pItem))

	# Inserts the item before each of the given positions, in place.
	#
	#   returns    nothing; the list changes
	#   see        InsertBeforePositions
	def InsertBeforeManyPositions(panPos, pItem)
		This._SetContent(_StzInsertBeforePositions(This.Content(), panPos, pItem))

	#-- insert pItem after/before each item matching a W-condition (:Where ok)


	# CountItemsW/CountW already defined above

	  #-----------------------------#
	 #  COUNTER DELEGATIONS        #
	#-----------------------------#

	# Returns how many distinct items meet the W condition.
	#
	#   pCondition   the W condition
	#   returns      a number
	#   see          NumberOfUniqueNamedObjects
	#@ aka  How many unique items satisfy the given W condition.
	def NumberOfUniqueItemsW(pCondition)
		_oNuiwCounter_ = new stzListCounter(This)
		return _oNuiwCounter_.NumberOfUniqueItemsW(pCondition)



	def InsertAfterW(pcCondition, pNewItem)
		_oIawCounter_ = new stzListCounter(This)
		_oIawCounter_.InsertAfterW(pcCondition, pNewItem)
		This.UpdateWith(_oIawCounter_.Content())

	def InsertBeforeW(pcCondition, pNewItem)
		_oIbwCounter_ = new stzListCounter(This)
		_oIbwCounter_.InsertBeforeW(pcCondition, pNewItem)
		This.UpdateWith(_oIbwCounter_.Content())

	  #-----------------------------#
	 #  SPLITTER DELEGATIONS       #
	#-----------------------------#

	# Raises error R14 today instead of splitting the list with the given options.
	#
	#   p          the item or the options to split with
	#   returns    nothing today
	#   warning    known defect: the call raises error R14 today, because it calls a method that is
	#              not defined
	#   see        SplittedAt
	#@ aka  SplitAt already defined in core
	def SplitXT(p)
		_oSxtSplitter_ = new stzListSplits(This)
		return _oSxtSplitter_.SplitXT(p)

	# Raises error R14 today instead of returning the parts split with the given options.
	#
	#   p          the item or the options to split with
	#   returns    nothing today
	#   warning    known defect: the call raises error R14 today, because it calls a method that is
	#              not defined
	#   see        SplittedAt
	#@ aka  Split with the given item-or-options param; the parts, as data.
	def SplittedXT(p)
		_oSdxtSplitter_ = new stzListSplits(This)
		return _oSdxtSplitter_.SplittedXT(p)

	# Raises error R14 today instead of returning the sections of the parts.
	#
	#   p          the item or the options to split with
	#   returns    nothing today
	#   warning    known defect: the call raises error R14 today, because it calls a method that is
	#              not defined
	#   see        SplittedAt
	#@ aka  Split with the given item-or-options param; the [start, end] sections of the parts.
	def SplitAsSectionsXT(p)
		_oSasxtSplitter_ = new stzListSplits(This)
		return _oSasxtSplitter_.SplitAsSectionsXT(p)

	# Raises error R14 today instead of returning the sections of the parts.
	#
	#   p          the item or the options to split with
	#   returns    nothing today
	#   warning    known defect: the call raises error R14 today, because it calls a method that is
	#              not defined
	#   see        SplittedAt
	#@ aka  The [start, end] sections of the parts, as data (XT options form).
	def SplittedAsSectionsXT(p)
		_oSdasxtSplitter_ = new stzListSplits(This)
		return _oSdasxtSplitter_.SplittedAsSectionsXT(p)

	# Leaves the list unchanged today instead of splitting it at an item or position.
	#
	#   pItemOrPos   the item or the position to split at
	#   returns      nothing today
	#   warning      known defect: the call computes the parts on a copy and drops them; use the
	#                Splitted forms
	#   see          SplittedAtPosition
	#@ aka  Split the list at the given item (or position): the parts.
	def SplitCS(pItemOrPos, pCaseSensitive)
		_oScsSplitter_ = new stzListSplits(This)
		return _oScsSplitter_.SplitCS(pItemOrPos, pCaseSensitive)

	# Splits the list at the given positions, in place; the items at those positions are dropped.
	#
	#   returns    nothing; the list becomes the list of parts
	#   see        SplitAfterPositions
	#@ aka  SplitAtPositions MUTATES the content into the list of parts; the items AT the positions are DROPPED (split "at", not "before").
	def SplitAtPositions(panPos)
		if NOT isList(panPos) return [ This.Content() ] ok
		_aSap_ = This.Content()
		_nSapL_ = ring_len(_aSap_)
		_nSapPL_ = ring_len(panPos)
		_aSapParts_ = []
		_aSapCur_ = []
		for _iSap_ = 1 to _nSapL_
			_bSapAnchor_ = 0
			for _jSap_ = 1 to _nSapPL_
				if panPos[_jSap_] = _iSap_
					_bSapAnchor_ = 1
					exit
				ok
			next
			if _bSapAnchor_
				if ring_len(_aSapCur_) > 0 _aSapParts_ + _aSapCur_ ok
				_aSapCur_ = []
			else
				_aSapCur_ + _aSap_[_iSap_]
			ok
		next
		if ring_len(_aSapCur_) > 0 _aSapParts_ + _aSapCur_ ok
		This.Update(_aSapParts_)
		return _aSapParts_

	# Returns the list cut at the given positions; the list is unchanged.
	#
	#   returns    a list of lists
	#   see        SplitAtPositions
	#@ aka  The parts of the list split at the given positions.
	def SplittedAtPositions(panPos)
		_oSdapSplitter_ = new stzListSplits(This)
		return _oSdapSplitter_.SplittedAtPositions(panPos)

	def SplitAtPositionsZZ(panPos)
		_oSapzzSplitter_ = new stzListSplits(This)
		return _oSapzzSplitter_.SplitAtPositionsZZ(panPos)

	def SplittedAtPositionsZZ(panPos)
		_oSdapzzSplitter_ = new stzListSplits(This)
		return _oSdapzzSplitter_.SplittedAtPositionsZZ(panPos)

	# Leaves the list unchanged today instead of splitting it at a position.
	#
	#   _n_        the position to split at
	#   returns    nothing today
	#   warning    known defect: the call computes the parts on a copy and drops them;
	#              SplittedAtPosition returns them
	#   see        SplittedAtPosition
	#@ aka  Split the list at the given position: the parts.
	def SplitAtPosition(_n_)
		_oSaposSplitter_ = new stzListSplits(This)
		return _oSaposSplitter_.SplitAtPosition(_n_)

	# Returns the list cut at the given position into two parts; the list is unchanged.
	#
	#   _n_        the position to cut at
	#   returns    a list of two lists
	#   see        SplittedBeforePosition
	#@ aka  The parts of the list split at the given position.
	def SplittedAtPosition(_n_)
		_oSdaposSplitter_ = new stzListSplits(This)
		return _oSdaposSplitter_.SplittedAtPosition(_n_)

	def SplitAtPositionZZ(_n_)
		_oSapozzSplitter_ = new stzListSplits(This)
		return _oSapozzSplitter_.SplitAtPositionZZ(_n_)

	def SplittedAtPositionZZ(_n_)
		_oSdapozzSplitter_ = new stzListSplits(This)
		return _oSdapozzSplitter_.SplittedAtPositionZZ(_n_)

	def SplitAtCS(pItem, pCaseSensitive)
		_oSacsSplitter_ = new stzListSplits(This)
		return _oSacsSplitter_.SplitAtCS(pItem, pCaseSensitive)

	def SplittedAtCS(pItem, pCaseSensitive)
		_oSdacsSplitter_ = new stzListSplits(This)
		return _oSdacsSplitter_.SplittedAtCS(pItem, pCaseSensitive)

	# Returns the parts of the list cut at each occurrence of the item, the item itself not kept.
	#
	#   returns    a list of lists
	#   see        SplitAtPositions
	#@ aka  The parts of the list split at each occurrence of the given item (the item itself is not kept in the parts).
	def SplittedAt(pItem)
		return This.SplittedAtCS(pItem, 1)

	def SplitAtCSZZ(pItem, pCaseSensitive)
		_oSacszzSplitter_ = new stzListSplits(This)
		return _oSacszzSplitter_.SplitAtCSZZ(pItem, pCaseSensitive)

	def SplitAtZZ(pItem)
		return This.SplitAtCSZZ(pItem, 1)

	def SplittedAtCSZZ(pItem, pCaseSensitive)
		_oSdacszzSplitter_ = new stzListSplits(This)
		return _oSdacszzSplitter_.SplittedAtCSZZ(pItem, pCaseSensitive)

	def SplittedAtZZ(pItem)
		return This.SplittedAtCSZZ(pItem, 1)

	# Leaves the list unchanged today instead of splitting it before a position.
	#
	#   _n_        the position to split before
	#   returns    nothing today
	#   warning    known defect: the call computes the parts on a copy and drops them;
	#              SplittedBeforePosition returns them
	#   see        SplittedBeforePosition
	#@ aka  Split the list before the given position: the parts.
	def SplitBeforePosition(_n_)
		_oSbpSplitter_ = new stzListSplits(This)
		return _oSbpSplitter_.SplitBeforePosition(_n_)

	# Returns the list cut before the given position into two parts; the list is unchanged.
	#
	#   _n_        the position to cut before
	#   returns    a list of two lists
	#   see        SplittedAtPosition, SplittedAfterPosition
	#@ aka  The parts of the list split before the given position.
	def SplittedBeforePosition(_n_)
		_oSdbpSplitter_ = new stzListSplits(This)
		return _oSdbpSplitter_.SplittedBeforePosition(_n_)

	def SplitBeforeCS(pItem, pCaseSensitive)
		_oSbcsSplitter_ = new stzListSplits(This)
		return _oSbcsSplitter_.SplitBeforeCS(pItem, pCaseSensitive)

	# Splits the list before each occurrence of the item, but a known defect makes the call do nothing today.
	#
	#   pItem      the item that opens each part
	#   returns    nothing today
	#   warning    known defect: the call changes nothing and returns nothing, because it splits a
	#              copy of the list; SplitAt and SplitBeforePositions work
	#   see        SplitAt, SplitBeforePositions
	#@ aka  Split the list before each occurrence of the item: each occurrence starts a new part.
	def SplitBefore(pItem)
		return This.SplitBeforeCS(pItem, 1)

	# Leaves the list unchanged today instead of splitting it after a position.
	#
	#   _n_        the position to split after
	#   returns    nothing today
	#   warning    known defect: the call computes the parts on a copy and drops them;
	#              SplittedAfterPosition returns them
	#   see        SplittedAfterPosition
	#@ aka  Split the list after the given position: the parts.
	def SplitAfterPosition(_n_)
		_oSafpSplitter_ = new stzListSplits(This)
		return _oSafpSplitter_.SplitAfterPosition(_n_)

	# Returns the list cut after the given position into two parts; the list is unchanged.
	#
	#   _n_        the position to cut after
	#   returns    a list of two lists
	#   see        SplittedAtPosition
	#@ aka  The parts of the list split after the given position.
	def SplittedAfterPosition(_n_)
		_oSdafpSplitter_ = new stzListSplits(This)
		return _oSdafpSplitter_.SplittedAfterPosition(_n_)

	def SplitAfterCS(pItem, pCaseSensitive)
		_oSafcsSplitter_ = new stzListSplits(This)
		return _oSafcsSplitter_.SplitAfterCS(pItem, pCaseSensitive)

	# Splits the list after each occurrence of the item, but a known defect makes the call do nothing today.
	#
	#   pItem      the item that closes each part
	#   returns    nothing today
	#   warning    known defect: the call changes nothing and returns nothing, because it splits a
	#              copy of the list; SplitAt and SplitBeforePositions work
	#   see        SplitAt, SplitBeforePositions
	#@ aka  Split the list after each occurrence of the item: each occurrence closes its part.
	def SplitAfter(pItem)
		return This.SplitAfterCS(pItem, 1)

	# Leaves the list unchanged today instead of splitting it into n parts.
	#
	#   _n_        the number of parts
	#   returns    nothing today
	#   warning    known defect: the call computes the parts on a copy and drops them;
	#              SplittedToNParts returns them
	#   see        SplittedToNParts
	#@ aka  divide, chunk, break into parts, portions
	#@ aka  Split the list into n (near-)equal parts.
	def SplitToNParts(_n_)
		_oStnpSplitter_ = new stzListSplits(This)
		return _oStnpSplitter_.SplitToNParts(_n_)

		def SplitToNPartsQ(_n_)
			return new stzList( This.SplitToNParts(_n_) )

	# Returns the list divided into n parts of near-equal size; the list is unchanged.
	#
	#   _n_        the number of parts
	#   returns    a list of lists
	#   see        SplittedToPartsOfNItems
	#@ aka  The n (near-)equal parts of the list, as data.
	def SplittedToNParts(_n_)
		_oSdtnpSplitter_ = new stzListSplits(This)
		return _oSdtnpSplitter_.SplittedToNParts(_n_)

	# Splits the list into parts of n items each, in place.
	#
	#   _n_        the number of items in each part
	#   returns    nothing; the list becomes the list of parts
	#   see        SplittedToPartsOfNItems
	#@ aka  Split the list into parts of n items each.
	def SplitToPartsOfNItems(_n_)
		# Mutator: delegating to new stzListSplits(This) would mutate a COPY of
		# This (Ring copies objects passed to a constructor), so the change was
		# lost. Write back through This itself using the returning form.
		This.UpdateWith( This.SplittedToPartsOfNItems(_n_) )

		# Splits the list into parts of n items each, in place.
		#
		#   _n_        the number of items in each part
		#   returns    nothing; the list becomes the list of parts
		#   see        SplittedToPartsOfNItems
		def SplitToPartsOf(_n_)
			This.SplitToPartsOfNItems(_n_)

	# Returns the list cut into parts of n items each; the list is unchanged.
	#
	#   _n_        the number of items in each part
	#   returns    a list of lists
	#   see        SplittedToNParts, Chunks
	def SplittedToPartsOfNItems(_n_)
		_oSdtponiSplitter_ = new stzListSplits(This)
		return _oSdtponiSplitter_.SplittedToPartsOfNItems(_n_)

		def SplittedToPartsOf(_n_)
			return This.SplittedToPartsOfNItems(_n_)

	# Leaves the list unchanged today instead of splitting it every few items.
	#
	#   nPace      how many items in each part
	#   _nStart_   the position to start from
	#   returns    nothing today
	#   warning    known defect: the call computes the parts on a copy and drops them;
	#              SplittedAtPacer returns them
	#   see        SplittedAtPacer
	def SplitAtPacer(nPace, _nStart_)
		_oSapcrSplitter_ = new stzListSplits(This)
		return _oSapcrSplitter_.SplitAtPacer(nPace, _nStart_)

	# Returns the list cut into parts of a fixed number of items, from a position; the list is unchanged.
	#
	#   nPace      how many items in each part
	#   _nStart_   the position to start from
	#   returns    a list of lists
	#   see        SplitAtPacer
	def SplittedAtPacer(nPace, _nStart_)
		_oSdapcrSplitter_ = new stzListSplits(This)
		return _oSdapcrSplitter_.SplittedAtPacer(nPace, _nStart_)

	# Splits the list at the items that meet the W condition, in place; the items that match are dropped.
	#
	#   returns    nothing; the list becomes the list of parts
	#   see        SplittedW
	#@ aka  SplitW MUTATES the content into the list of parts (the matching items are dropped; SplittedW is the passive twin).
	def SplitW(pcCondition)
		return This.SplitAtPositions( This.FindW(pcCondition) )

	# Returns the list cut at the items that meet the W condition; the list is unchanged.
	#
	#   returns    a list of lists
	#   see        SplitW
	def SplittedW(pcCondition)
		_oSdwSplitter_ = new stzListSplits(This)
		return _oSdwSplitter_.SplittedW(pcCondition)




	  #-------------------------------#
	 #  LEAD/TRAIL DELEGATIONS       #
	#-------------------------------#

	def HasRepeatedLeadingItemsCS(pCaseSensitive)
		_oHrliLt_ = new stzListLeadTrail(This)
		return _oHrliLt_.HasRepeatedLeadingItemsCS(pCaseSensitive)

	# TRUE if the first item is repeated right after itself.
	#
	#   returns    TRUE or FALSE
	#   see        RepeatedLeadingItems
	def HasRepeatedLeadingItems()
		return This.HasRepeatedLeadingItemsCS(1)

	def RepeatedLeadingItemsCS(pCaseSensitive)
		_oRliLt_ = new stzListLeadTrail(This)
		return _oRliLt_.RepeatedLeadingItemsCS(pCaseSensitive)

	# Returns the run of equal items at the start of the list.
	#
	#   returns    a list of items
	#   see        SectionsOfSameItems
	def RepeatedLeadingItems()
		return This.RepeatedLeadingItemsCS(1)

	def RepeatedLeadingItemCS(pCaseSensitive)
		_oRlicLt_ = new stzListLeadTrail(This)
		return _oRlicLt_.RepeatedLeadingItemCS(pCaseSensitive)

	# Leaves nothing today instead of returning the item that repeats at the start.
	#
	#   returns    nothing today
	#   warning    known defect: the call returns an empty string whatever the list holds;
	#              RepeatedLeadingItems returns the run
	#   see        RepeatedLeadingItems
	def RepeatedLeadingItem()
		return This.RepeatedLeadingItemCS(1)

	def NumberOfRepeatedLeadingItemsCS(pCaseSensitive)
		_oNrliLt_ = new stzListLeadTrail(This)
		return _oNrliLt_.NumberOfRepeatedLeadingItemsCS(pCaseSensitive)

	# Returns how many items follow the first one and equal it.
	#
	#   returns    a number
	#   see        RepeatedLeadingItems
	def NumberOfRepeatedLeadingItems()
		return This.NumberOfRepeatedLeadingItemsCS(1)

	def HasRepeatedTrailingItemsCS(pCaseSensitive)
		_oHrtiLt_ = new stzListLeadTrail(This)
		return _oHrtiLt_.HasRepeatedTrailingItemsCS(pCaseSensitive)

	# TRUE if the last item is repeated right before itself.
	#
	#   returns    TRUE or FALSE
	#   see        RepeatedTrailingItems
	def HasRepeatedTrailingItems()
		return This.HasRepeatedTrailingItemsCS(1)

	def RepeatedTrailingItemsCS(pCaseSensitive)
		_oRtiLt_ = new stzListLeadTrail(This)
		return _oRtiLt_.RepeatedTrailingItemsCS(pCaseSensitive)

	# Returns the run of items equal to the last one.
	#
	#   returns    a list of items
	#   see        TrailingItems
	def RepeatedTrailingItems()
		return This.RepeatedTrailingItemsCS(1)

	# The item repeated at the end of the list.
	def RepeatedTrailingItemCS(pCaseSensitive)
		_oRticLt_ = new stzListLeadTrail(This)
		return _oRticLt_.RepeatedTrailingItemCS(pCaseSensitive)

	# Raises error R14 today instead of returning the item that repeats at the end.
	#
	#   returns    nothing today
	#   warning    known defect: the call raises error R14 today, because it calls a method that is
	#              not defined
	#   see        RepeatedTrailingItems
	def RepeatedTrailingItem()
		return This.RepeatedTrailingItemCS(1)

	# How long the repeated run at the end of the list is.
	def NumberOfRepeatedTrailingItemsCS(pCaseSensitive)
		_oNrtiLt_ = new stzListLeadTrail(This)
		return _oNrtiLt_.NumberOfRepeatedTrailingItemsCS(pCaseSensitive)

	# Raises error R14 today instead of returning how many items before the last equal it.
	#
	#   returns    nothing today
	#   warning    known defect: the call raises error R14 today, because it calls a method that is
	#              not defined
	#   see        NumberOfRepeatedLeadingItems
	def NumberOfRepeatedTrailingItems()
		return This.NumberOfRepeatedTrailingItemsCS(1)

	  #-------------------------------#
	 #  EXTRACTOR DELEGATIONS        #
	#-------------------------------#

	# Remove the occurrences of the given item and RETURN them
	# (extract = remove + return).
	def ExtractCS(pItem, pCaseSensitive)
		_oEcsExt_ = new stzListExtractor(This)
		_oEcsExt_.ExtractCS(pItem, pCaseSensitive)
		This.UpdateWith(_oEcsExt_.Content())
		return pItem

	# Extract each of the given items: removed AND returned.
	def ExtractManyCS(paItems, pCaseSensitive)
		_oEmcsExt_ = new stzListExtractor(This)
		_oEmcsExt_.ExtractManyCS(paItems, pCaseSensitive)
		This.UpdateWith(_oEmcsExt_.Content())
		return paItems

	def ExtractMany(paItems)
		return This.ExtractManyCS(paItems, 1)

	# Empties the list and returns everything that was in it.
	#
	#   returns    a list of items
	#   see        Extract
	#@ aka  Empty the list, returning everything that was in it.
	def ExtractAll()
		_aContent_ = This.Content()
		_oEaExt_ = new stzListExtractor(This)
		_oEaExt_.ExtractAll()
		This.UpdateWith(_oEaExt_.Content())
		return _aContent_

	# Removes the item at position n and returns it.
	#
	#   _n_        the position to remove
	#   returns    the removed item
	#   see        ExtractAt
	#@ aka  Remove the nth item and return it.
	def ExtractNth(_n_)
		_oEnExt_ = new stzListExtractor(This)
		_oEnExt_.ExtractNth(_n_)
		This.UpdateWith(_oEnExt_.Content())
		return This.Content()[_n_]

	# Removes the first occurrence of the item and returns it.
	#
	#   returns    the removed item
	#   see        RemoveFirst
	#@ aka  Remove the FIRST occurrence of the item and return it.
	def ExtractFirst(pItem)
		# Extract = remove the FIRST occurrence of pItem from the list and
		# return it (the destructive sibling of FindFirst).
		return This.ExtractFirstCS(pItem, 1)

	# Removes the last occurrence of the item and returns it.
	#
	#   returns    the removed item
	#   see        ExtractFirst
	#@ aka  Remove the LAST occurrence of the item and return it.
	def ExtractLast(pItem)
		# Remove the LAST occurrence of pItem and return it.
		return This.ExtractLastCS(pItem, 1)

	# Removes the items from one position to another, and returns them.
	#
	#   _n1_       the position of the first item
	#   _n2_       the position of the last item
	#   returns    a list of the removed items
	#   see        RemoveSection, Section
	#@ aka  Remove the items at positions n1..n2 and return them.
	def ExtractSection(_n1_, _n2_)
		# Capture the section BEFORE removing it (afterwards the list is shorter,
		# so This.Section(n1,n2) would go out of range).
		_aEsSection_ = This.Section(_n1_, _n2_)
		_oEsExt_ = new stzListExtractor(This)
		_oEsExt_.ExtractSection(_n1_, _n2_)
		This.UpdateWith(_oEsExt_.Content())
		return _aEsSection_

	# Removes a run of items from a position and returns them.
	#
	#   pnStart    the position of the first item
	#   pnRange    how many items
	#   returns    a list of the removed items
	#   see        ExtractSection
	#@ aka  Remove nRange items starting at nStart and return them.
	def ExtractRange(pnStart, pnRange)
		# Capture the range BEFORE removing it (same as ExtractSection).
		_aErRange_ = This.Range(pnStart, pnRange)
		_oErExt_ = new stzListExtractor(This)
		_oErExt_.ExtractRange(pnStart, pnRange)
		This.UpdateWith(_oErExt_.Content())
		return _aErRange_

	# Remove every item satisfying the W condition and return them.
	def ExtractW(pcCondition)
		# Remove every item matching the W-condition and RETURN them all
		# (find the matching positions, collect the items, then drop them).
		_anPos_ = This.FindW(pcCondition)
		_aResult_ = This.ItemsAtPositions(_anPos_)
		This.RemoveItemsAtPositions(_anPos_)
		return _aResult_

		def ExtractWQ(pcCondition)
			return new stzList( This.ExtractW(pcCondition) )

	# Remove the nth occurrence of the item and return it.
	def ExtractNthOccurrenceCS(_n_, pItem, pCaseSensitive)
		# Remove the nth occurrence of pItem and RETURN it (the extracted
		# value), per the monolith's authoritative Extract semantics.
		_nPos_ = This.FindNthOccurrenceCS(_n_, pItem, pCaseSensitive)
		This.RemoveItemAtPosition(_nPos_)
		return pItem

	# Removes the nth occurrence of the item and returns it.
	#
	#   _n_        which occurrence
	#   returns    the removed item
	#   see        ExtractFirst
	def ExtractNthOccurrence(_n_, pItem)
		return This.ExtractNthOccurrenceCS(_n_, pItem, 1)

	# Remove the first occurrence of the item and return it.
	def ExtractFirstOccurrenceCS(pItem, pCaseSensitive)
		_oEfocsExt_ = new stzListExtractor(This)
		_oEfocsExt_.ExtractFirstOccurrenceCS(pItem, pCaseSensitive)
		This.UpdateWith(_oEfocsExt_.Content())
		return This.FirstOccurrenceCS(pItem, pCaseSensitive)

	# Raises error R14 today instead of removing the first occurrence of the item and returning it.
	#
	#   returns    nothing today
	#   warning    known defect: the call raises error R14 today, because it calls
	#              FirstOccurrenceCS, which is not defined; ExtractFirst works
	#   see        ExtractFirst
	def ExtractFirstOccurrence(pItem)
		return This.ExtractFirstOccurrenceCS(pItem, 1)

	# Remove the last occurrence of the item and return it.
	def ExtractLastOccurrenceCS(pItem, pCaseSensitive)
		_oElocsExt_ = new stzListExtractor(This)
		_oElocsExt_.ExtractLastOccurrenceCS(pItem, pCaseSensitive)
		This.UpdateWith(_oElocsExt_.Content())
		return This.LastOccurrenceCS(pItem, pCaseSensitive)

	# Raises error R14 today instead of removing the last occurrence of the item and returning it.
	#
	#   returns    nothing today
	#   warning    known defect: the call raises error R14 today, because it calls LastOccurrenceCS,
	#              which is not defined; ExtractLast works
	#   see        ExtractLast
	def ExtractLastOccurrence(pItem)
		return This.ExtractLastOccurrenceCS(pItem, 1)

	# Remove the duplicated occurrences and return them.
	def ExtractDuplicatesCS(pCaseSensitive)
		_oEdcsExt_ = new stzListExtractor(This)
		_oEdcsExt_.ExtractDuplicatesCS(pCaseSensitive)
		This.UpdateWith(_oEdcsExt_.Content())
		return This.DuplicatesCS(pCaseSensitive)

	# Removes the repeats of duplicated items, in place, but answers an empty list instead of the removed items.
	#
	#   returns    an empty list today
	#   warning    known defect: the repeats are removed from the list but the call returns [ ]
	#              instead of them
	#   see        RemoveDuplicatedItems
	def ExtractDuplicates()
		return This.ExtractDuplicatesCS(1)

	# Removes the string items and returns them.
	#
	#   returns    a list of strings
	#   see        ExtractNumbers
	#@ aka  Remove and return all the STRING items.
	def ExtractStrings()
		_oEsExt2_ = new stzListExtractor(This)
		_oEsExt2_.ExtractStrings()
		This.UpdateWith(_oEsExt2_.Content())
		return This.OnlyStrings()

	# Removes the number items and returns them.
	#
	#   returns    a list of numbers
	#   see        ExtractStrings
	#@ aka  Remove and return all the NUMBER items.
	def ExtractNumbers()
		_oEnExt2_ = new stzListExtractor(This)
		_oEnExt2_.ExtractNumbers()
		This.UpdateWith(_oEnExt2_.Content())
		return This.OnlyNumbers()

	# Removes the list items and returns them.
	#
	#   returns    a list of lists
	#   see        ExtractNumbers
	#@ aka  Remove and return all the LIST items.
	def ExtractLists()
		_oElExt2_ = new stzListExtractor(This)
		_oElExt2_.ExtractLists()
		This.UpdateWith(_oElExt2_.Content())
		return This.OnlyLists()

	# Removes the last item and returns it.
	#
	#   returns    the removed item
	#   see        RemoveLastItem
	#@ aka  Remove the LAST item and return it.
	def Pop()
		_nPopLen_ = This.NumberOfItems()
		if _nPopLen_ = 0
			return ""
		ok
		_pPopItem_ = This.Item(_nPopLen_)
		This.RemoveLastItem()
		return _pPopItem_

	# Removes the first item and returns it.
	#
	#   returns    the removed item
	#   see        Pop
	#@ aka  Remove the FIRST item and return it.
	def PopFirst()
		if This.NumberOfItems() = 0
			return ""
		ok
		_pPfItem_ = This.Item(1)
		This.RemoveFirstItem()
		return _pPfItem_

	# Removes the first n items and returns them.
	#
	#   _n_        how many items
	#   returns    a list of the removed items
	#   see        TakeLast
	#@ aka  pop first items, grab, draw from the front
	#@ aka  Remove the first n items and return them.
	def Take(_n_)
		_oTkExt_ = new stzListExtractor(This)
		_aTkResult_ = _oTkExt_.Take(_n_)
		This.UpdateWith(_oTkExt_.Content())
		return _aTkResult_

	# Removes the last n items and returns them.
	#
	#   _n_        how many items
	#   returns    a list of the removed items
	#   see        Take
	#@ aka  Remove the last n items and return them.
	def TakeLast(_n_)
		_oTlExt_ = new stzListExtractor(This)
		_aTlResult_ = _oTlExt_.TakeLast(_n_)
		This.UpdateWith(_oTlExt_.Content())
		return _aTlResult_

	  #-------------------------------#
	 #  TRIMMER DELEGATIONS          #
	#-------------------------------#

	def TrimCS(pCaseSensitive)
		_oTcsTr_ = new stzListTrimmer(This)
		_oTcsTr_.TrimCS(pCaseSensitive)
		This.UpdateWith(_oTcsTr_.Content())

	def TrimmedCS(pCaseSensitive)
		_oTdcsTr_ = new stzListTrimmer(This)
		return _oTdcsTr_.TrimmedCS(pCaseSensitive)

	# Removes the empty items at both ends of the list, in place.
	#
	#   returns    nothing; the list changes
	#   example    o1 = new stzList([ "", "a", "" ])
	#              o1.Trim()
	#              ? @@( o1.Content() )
	#              #--> [ "a" ]
	def Trim()
		This.TrimCS(1)

	# Returns a copy of the list without the empty items at both ends; the list is unchanged.
	#
	#   returns    a list
	#   see        Trim
	#   example    o1 = new stzList([ "", "a", "" ])
	#              ? @@( o1.Trimmed() )
	#              #--> [ "a" ]
	def Trimmed()
		return This.TrimmedCS(1)

	def TrimLeftCS(pCaseSensitive)
		_oTlcsTr_ = new stzListTrimmer(This)
		_oTlcsTr_.TrimLeftCS(pCaseSensitive)
		This.UpdateWith(_oTlcsTr_.Content())

	# Removes the empty items (0, an empty string, an empty list) from the start, in place; the last item is always kept.
	#
	#   returns    nothing; the list changes
	#   see        TrimRight, Trim
	def TrimLeft()
		This.TrimLeftCS(1)

	# Returns a copy without the empty items at its start; the list is unchanged.
	#
	#   returns    a list of items
	#   see        TrimLeft
	def TrimmedLeft()
		return This.TrimmedCS(1)

	def TrimRightCS(pCaseSensitive)
		_oTrcsTr_ = new stzListTrimmer(This)
		_oTrcsTr_.TrimRightCS(pCaseSensitive)
		This.UpdateWith(_oTrcsTr_.Content())

	# Removes the empty items (0, an empty string, an empty list) from the end, in place; the first item is always kept.
	#
	#   returns    nothing; the list changes
	#   see        TrimLeft, Trim
	def TrimRight()
		This.TrimRightCS(1)

	# Returns a copy without the empty items at its end; the list is unchanged.
	#
	#   returns    a list of items
	#   see        TrimRight
	#@ aka  A copy with the trailing empty run trimmed; the original is unchanged.
	def TrimmedRight()
		_oTdrTr_ = new stzListTrimmer(This)
		return _oTdrTr_.TrimmedRight()

	# Remove the runs of the given item from BOTH ends (mutating).
	def TrimItemCS(pItem, pCaseSensitive)
		_oTicsTr_ = new stzListTrimmer(This)
		_oTicsTr_.TrimItemCS(pItem, pCaseSensitive)
		This.UpdateWith(_oTicsTr_.Content())

	# Removes the runs of the given item from both ends of the list, in place.
	#
	#   returns    nothing; the list changes
	#   see        TrimLeft
	def TrimItem(pItem)
		This.TrimItemCS(pItem, 1)

	# Remove the run of the given item from the START (mutating).
	def TrimItemFromLeftCS(pItem, pCaseSensitive)
		_oTiflcsTr_ = new stzListTrimmer(This)
		_oTiflcsTr_.TrimItemFromLeftCS(pItem, pCaseSensitive)
		This.UpdateWith(_oTiflcsTr_.Content())

	# Removes the run of the given item from the start of the list, in place.
	#
	#   returns    nothing; the list changes
	#   see        TrimItemFromRight
	def TrimItemFromLeft(pItem)
		This.TrimItemFromLeftCS(pItem, 1)

	# Remove the run of the given item from the END (mutating).
	def TrimItemFromRightCS(pItem, pCaseSensitive)
		_oTifrcsTr_ = new stzListTrimmer(This)
		_oTifrcsTr_.TrimItemFromRightCS(pItem, pCaseSensitive)
		This.UpdateWith(_oTifrcsTr_.Content())

	# Removes the run of the given item from the end of the list, in place.
	#
	#   returns    nothing; the list changes
	#   see        TrimItemFromLeft
	def TrimItemFromRight(pItem)
		This.TrimItemFromRightCS(pItem, 1)

	# Removes the empty items, in place.
	#
	#   returns    nothing; the list changes
	#   see        Compacted
	def Compact()
		_oCpTr_ = new stzListTrimmer(This)
		_oCpTr_.Compact()
		This.UpdateWith(_oCpTr_.Content())

	# Returns a copy without the empty items; the list is unchanged.
	#
	#   returns    a list of items
	#   see        Compact
	def Compacted()
		_oCpdTr_ = new stzListTrimmer(This)
		return _oCpdTr_.Compacted()

	# Squeezes the list, in place, through its trimmer.
	#
	#   returns    nothing; the list changes
	#   see        Squeezed
	def Squeeze()
		_oSqTr_ = new stzListTrimmer(This)
		_oSqTr_.Squeeze()
		This.UpdateWith(_oSqTr_.Content())

	# Returns the list squeezed through its trimmer; the list is unchanged.
	#
	#   returns    a list of items
	#   see        Squeeze
	def Squeezed()
		_oSqdTr_ = new stzListTrimmer(This)
		return _oSqdTr_.Squeezed()

	# Removes the empty items, in place.
	#
	#   returns    nothing; the list changes
	#   see        NullsStripped
	#@ aka  Remove the null items from the list (mutating).
	def StripNulls()
		_oSnTr_ = new stzListTrimmer(This)
		_oSnTr_.StripNulls()
		This.UpdateWith(_oSnTr_.Content())

	# Returns a copy without the empty items; the list is unchanged.
	#
	#   returns    a list of items
	#   see        StripNulls
	def NullsStripped()
		_oNsTr_ = new stzListTrimmer(This)
		return _oNsTr_.NullsStripped()

	# Cuts the list down to its first n items, in place.
	#
	#   _n_        how many items to keep
	#   returns    nothing; the list changes
	#   see        TrimmedToSize
	#@ aka  Cut the list down to its first n items (mutating).
	def TrimToSize(_n_)
		_oTtsTr_ = new stzListTrimmer(This)
		_oTtsTr_.TrimToSize(_n_)
		This.UpdateWith(_oTtsTr_.Content())

	# Returns the first n items; the list is unchanged.
	#
	#   _n_        how many items to keep
	#   returns    a list of items
	#   see        TrimToSize
	def TrimmedToSize(_n_)
		_oTdtsTr_ = new stzListTrimmer(This)
		return _oTdtsTr_.TrimmedToSize(_n_)

	def TrimW(pcCondition)
		_oTwTr_ = new stzListTrimmer(This)
		_oTwTr_.TrimW(pcCondition)
		This.UpdateWith(_oTwTr_.Content())

	def TrimmedW(pcCondition)
		_oTdwTr_ = new stzListTrimmer(This)
		return _oTdwTr_.TrimmedW(pcCondition)

	  #-------------------------------#
	 #  GETTER DELEGATIONS           #
	#-------------------------------#

	def UniqueItemsCS(pCaseSensitive)
		_oUicsGt_ = new stzListGetter(This)
		return _oUicsGt_.UniqueItemsCS(pCaseSensitive)

	# Returns each distinct item once, in order of first appearance.
	#
	#   returns    a list of items
	#   see        Classes
	def UniqueItems()
		return This.UniqueItemsCS(1)

	# Returns one item picked at random.
	#
	#   returns    the item
	#   see        NRandomItems
	def RandomItem()
		_oRiGt_ = new stzListGetter(This)
		return _oRiGt_.RandomItem()

	# Returns n items picked at random from the list.
	#
	#   _n_        how many items
	#   returns    a list of n items
	#   see        RandomItem, Shuffled
	def NRandomItems(_n_)
		_oNriGt_ = new stzListGetter(This)
		return _oNriGt_.NRandomItems(_n_)

	#-- rnd* : terse random helpers (the "give me some random cards" idiom).
	#   rndItems() returns a random NUMBER of random items; rndNItems(n) a
	#   fixed n. The rndRemove* forms are the MUTATING counterparts -- they
	#   drop random items from the list in place and return This for chaining.

	def rndNItems(_n_)
		return This.NRandomItems(_n_)

		def RandomNItems(_n_)
			return This.NRandomItems(_n_)

	# Returns some of the items, picked at random.
	#
	#   returns    a list of items
	#   see        NRandomItems
	#@ aka  The items of the list, in random order.
	def rndItems()
		_nRiN_ = This.NumberOfItems()
		if _nRiN_ = 0 return [] ok
		_nRiK_ = StzEngineRandomInt(0, _nRiN_ - 1) + 1
		return This.NRandomItems(_nRiK_)

		def RandomItems()
			return This.rndItems()

	# Removes n items chosen at random, in place.
	#
	#   _n_        how many items
	#   returns    the list itself
	#   see        rndRemoveItems
	#@ aka  Remove n randomly-chosen items (mutating).
	def rndRemoveNItems(_n_)
		_nRrN_ = This.NumberOfItems()
		if _n_ <= 0 or _nRrN_ = 0 return This ok
		if _n_ > _nRrN_ _n_ = _nRrN_ ok
		#-- shuffle the positions 1.._nRrN_ and remove the first n of them
		_anRrIdx_ = 1 : _nRrN_
		for _iRr_ = _nRrN_ to 2 step -1
			_jRr_ = StzEngineRandomInt(0, _iRr_ - 1) + 1
			_xRr_ = _anRrIdx_[_iRr_]
			_anRrIdx_[_iRr_] = _anRrIdx_[_jRr_]
			_anRrIdx_[_jRr_] = _xRr_
		next
		_anRrPick_ = []
		for _kRr_ = 1 to _n_
			_anRrPick_ + _anRrIdx_[_kRr_]
		next
		This.RemoveItemsAtPositions(_anRrPick_)
		return This

		def rndRemoveNItemsQ(_n_)
			return This.rndRemoveNItems(_n_)

		def RandomRemoveNItems(_n_)
			return This.rndRemoveNItems(_n_)

	# Removes randomly chosen items, in place.
	#
	#   returns    the list itself
	#   see        RemoveItems
	#@ aka  Remove randomly-chosen items (mutating).
	def rndRemoveItems()
		_nRr2N_ = This.NumberOfItems()
		if _nRr2N_ = 0 return This ok
		_nRr2K_ = StzEngineRandomInt(0, _nRr2N_ - 1) + 1
		return This.rndRemoveNItems(_nRr2K_)

		def rndRemoveItemsQ()
			return This.rndRemoveItems()

		def RandomRemoveItems()
			return This.rndRemoveItems()

	# Returns the items from one position to another, both included.
	#
	#   _n1_       the position of the first item
	#   _n2_       the position of the last item
	#   returns    a list of items
	#   see        Section
	def ItemsBetween(_n1_, _n2_)
		_oIbGt_ = new stzListGetter(This)
		return _oIbGt_.ItemsBetween(_n1_, _n2_)

	# Returns every nth item, starting with the nth.
	#
	#   _n_        the step between the items kept
	#   returns    a list of items
	#   see        WalkNForward
	def EveryNthItem(_n_)
		_oEniGt_ = new stzListGetter(This)
		return _oEniGt_.EveryNthItem(_n_)

	# Returns the first n items.
	#
	#   _n_        how many items
	#   returns    a list of items
	#   see        NFirstItems
	def Head(_n_)
		_oHdGt_ = new stzListGetter(This)
		return _oHdGt_.Head(_n_)

	# Returns the last n items.
	#
	#   _n_        how many items
	#   returns    a list of items
	#   see        Head
	def Tail(_n_)
		_oTlGt_ = new stzListGetter(This)
		return _oTlGt_.Tail(_n_)

	# Returns the items that are strings.
	#
	#   returns    a list of strings
	#   see        Strings, OnlyNumbers
	def OnlyStrings()
		_oOsGt_ = new stzListGetter(This)
		return _oOsGt_.OnlyStrings()

		def OnlyStringsQ()
			return new stzList( This.OnlyStrings() )

	# Returns the items that are numbers.
	#
	#   returns    a list of numbers
	#   see        Numbers, OnlyStrings
	def OnlyNumbers()
		_oOnGt_ = new stzListGetter(This)
		return _oOnGt_.OnlyNumbers()

		def OnlyNumbersQ()
			return new stzList( This.OnlyNumbers() )

	# Returns the items that are lists.
	#
	#   returns    a list of lists
	#   see        Lists
	def OnlyLists()
		_oOlGt_ = new stzListGetter(This)
		return _oOlGt_.OnlyLists()

		def OnlyListsQ()
			return new stzList( This.OnlyLists() )

	# Returns the items that are single characters.
	#
	#   returns    a list of characters
	#   see        OnlyStrings
	def OnlyChars()
		_oOcGt_ = new stzListGetter(This)
		return _oOcGt_.OnlyChars()

		def OnlyCharsQ()
			return new stzList( This.OnlyChars() )

	# Returns the items that are themselves pairs, lists of two items.
	#
	#   returns    a list of pairs
	#   see        FindPairs
	#@ aka  -- Pairs(): the items of the list that are themselves pairs (2-element -- lists). For the sliding/consecutive grouping use Pairify()/ToPairs().
	def Pairs()
		return _StzItemsAtPos(This.Content(), This.FindPairs())

	# Returns the sliding pairs of consecutive items, such as [ [ 1, 2 ], [ 2, 3 ] ].
	#
	#   returns    a list of two-item lists
	#   see        Pairified
	#@ aka  -- Pairify()/ToPairs(): group the list into consecutive (sliding) pairs, -- e.g. [1,2,3,4] -> [[1,2],[2,3],[3,4]].
	def Pairify()
		_oPrGt_ = new stzListGetter(This)
		return _oPrGt_.Pairs()

		def ToPairs()
			return This.Pairify()

	# Returns the sliding triplets of consecutive items, such as [ [ 1, 2, 3 ], [ 2, 3, 4 ] ].
	#
	#   returns    a list of three-item lists
	#   see        Pairify
	def Triplets()
		_oTrGt_ = new stzListGetter(This)
		return _oTrGt_.Triplets()

	# Returns every run of n consecutive items, moving one place at a time.
	#
	#   _n_        the size of the window
	#   returns    a list of lists
	#   see        Chunks
	def SlidingWindow(_n_)
		_oSwGt_ = new stzListGetter(This)
		return _oSwGt_.SlidingWindow(_n_)

	  #-------------------------------#
	 #  WALKER DELEGATIONS           #
	#-------------------------------#

	# Registers a named walker over the list.
	#
	#   p1         the name of the walker
	#   p2         where it starts
	#   p3         where it stops
	#   p4         its step
	#   returns    nothing; the walker is stored
	#   see        Walk
	#@ aka  -- AddWalker: register a NAMED walker over this list. The 4 args may be -- given positionally (name, start, end, step) OR as named pairs / -- function-style helpers in any order: -- AddWalker(:Named=:W, :StartingAt=1, :EndingAt=10, :NStep=2) -- AddWalker(Named(:W), StartingAt(1), EndingAt(10), NStepsATime(2)) -- AddWalker(:W, 6, 10, [:NStepsATime, 3]) -- AddWalker(Named(:W), StartingAt(1), EndingA
	def AddWalker(p1, p2, p3, p4)
		_cAwName_ = ""
		_nAwStart_ = 1
		_nAwEnd_ = This.NumberOfItems()
		_nAwStep_ = 1
		_nAwMoves_ = 0
		_cAwMode_ = :Step

		_aAwArgs_ = [ p1, p2, p3, p4 ]
		_nAwPos_ = 0
		for _iAw_ = 1 to 4
			_a_ = _aAwArgs_[_iAw_]
			if isList(_a_) and len(_a_) = 2 and isString(_a_[1])
				_k_ = lower(_a_[1])
				_v_ = _a_[2]
				if _k_ = "named" or _k_ = "name"
					_cAwName_ = _v_
				but _k_ = "startingat"
					_nAwStart_ = _v_
				but _k_ = "endingat"
					_nAwEnd_ = _v_
				but _k_ = "nstep" or _k_ = "nstepsatime"
					_nAwStep_ = _v_ _cAwMode_ = :Step
				but _k_ = "nequalmoves"
					_nAwMoves_ = _v_ _cAwMode_ = :EqualMoves
				ok
			but isString(_a_) or isNumber(_a_)
				_nAwPos_++
				if _nAwPos_ = 1
					_cAwName_ = _a_
				but _nAwPos_ = 2
					_nAwStart_ = _a_
				but _nAwPos_ = 3
					_nAwEnd_ = _a_
				but _nAwPos_ = 4
					_nAwStep_ = _a_
				ok
			ok
		next

		@aWalkers + [ _cAwName_, [ _nAwStart_, _nAwEnd_, _nAwStep_, _cAwMode_, _nAwMoves_ ] ]

	# Returns the named walkers attached to the list.
	#
	#   returns    a list of walkers
	#   see        AddWalker
	#@ aka  The named walkers attached to this list.
	def Walkers()
		return @aWalkers

	#-- resolve a walker name from a bare name or a [:By/:Named/..., name] pair
	def _ResolveWalkerName(pName)
		if isList(pName) and len(pName) = 2 and isString(pName[1])
			return pName[2]
		ok
		return pName

	def _WalkerDef(pName)
		_cWd_ = This._ResolveWalkerName(pName)
		_nWd_ = len(@aWalkers)
		for _iWd_ = 1 to _nWd_
			if @aWalkers[_iWd_][1] = _cWd_
				return @aWalkers[_iWd_][2]
			ok
		next
		return ""

	# Returns the positions that the given walker visited.
	#
	#   pBy        the name of the walker
	#   returns    a list of positions
	#   see        WalkedItems
	#@ aka  The positions visited by the given walker.
	def WalkedPositions(pBy)
		_aWp_ = This._WalkerDef(pBy)
		if _aWp_ = "" return [] ok
		_nStart_ = _aWp_[1]
		_nEnd_   = _aWp_[2]
		_nStep_  = _aWp_[3]
		_cMode_  = _aWp_[4]
		_nMoves_ = _aWp_[5]
		_nLen_   = This.NumberOfItems()
		if _nEnd_ > _nLen_ _nEnd_ = _nLen_ ok
		if _nStart_ < 1 _nStart_ = 1 ok

		_anRes_ = []
		if _cMode_ = :EqualMoves and _nMoves_ > 1
			for _iEm_ = 0 to _nMoves_ - 1
				_p_ = _nStart_ + floor( _iEm_ * (_nEnd_ - _nStart_) / (_nMoves_ - 1) )
				_anRes_ + _p_
			next
		else
			_iSt_ = _nStart_
			while _iSt_ <= _nEnd_
				_anRes_ + _iSt_
				_iSt_ += _nStep_
			end
		ok
		return _anRes_

	# Returns the items that the given walker visited.
	#
	#   pBy        the name of the walker
	#   returns    a list of items
	#   see        WalkedPositions
	#@ aka  The items visited by the given walker.
	def WalkedItems(pBy)
		return This.ItemsAtPositions( This.WalkedPositions(pBy) )

	# Returns how many items the given walker visited.
	#
	#   pBy        the name of the walker
	#   returns    a number
	#   see        WalkedItems
	#@ aka  How many items the given walker visited.
	def NumberOfWalkedItems(pBy)
		return len( This.WalkedPositions(pBy) )

	# Returns the last position the given walker reached.
	#
	#   pBy        the name of the walker
	#   returns    a number
	#   see        WalkedLastItem
	#@ aka  The last position the given walker reached.
	def WalkedLastPosition(pBy)
		_anWlp_ = This.WalkedPositions(pBy)
		if len(_anWlp_) = 0 return 0 ok
		return _anWlp_[ len(_anWlp_) ]

	# Returns the item at the last position the given walker reached.
	#
	#   pBy        the name of the walker
	#   returns    the item
	#   see        WalkedLastPosition
	#@ aka  The item at the walker's last position.
	def WalkedLastItem(pBy)
		_nWli_ = This.WalkedLastPosition(pBy)
		if _nWli_ = 0 return "" ok
		return This.Item(_nWli_)

	# Returns the yielder applied to each item that the named walker visits.
	#
	#   pcYielder   the expression that makes each value
	#   pWalker     the name of the walker
	#   returns     a list of values
	#   see         Walk
	#@ aka  -- YieldWhileWalking: project each item the named walker visits through an -- engine W-DSL yielder (e.g. '@item * 2', 'Q(@item).Upper()'). Eval-free -- and engine-backed (stz_list_map_expr). For arbitrary Ring logic -- (ring_type, upper, StringContains, ...) use YieldWhileWalkingWF.
	def YieldWhileWalking(pcYielder, pWalker)
		_aYwSub_ = This.ItemsAtPositions( This.WalkedPositions(pWalker) )
		_oYwSub_ = new stzList(_aYwSub_)
		return _oYwSub_.Yield(pcYielder)

	#-- WF form: project the walked items through a Ring anonymous function
	#-- (full Ring power, eval-free).
	def YieldWhileWalkingWF(pFunc, pWalker)
		_aYwfSub_ = This.ItemsAtPositions( This.WalkedPositions(pWalker) )
		_oYwfSub_ = new stzList(_aYwfSub_)
		return _oYwfSub_.MapWF(pFunc)

	# Returns positions from the first, stepping n at a time.
	#
	#   _n_        the step
	#   returns    a list of positions
	#   see        WalkBetween
	def WalkNForward(_n_)
		_oWnfWk_ = new stzListWalker(This)
		return _oWnfWk_.WalkNForward(_n_)

	# Returns the positions walked backwards from the last, n at a time.
	#
	#   _n_        the step
	#   returns    a list of positions
	#   see        WalkNForward
	def WalkNBackward(_n_)
		_oWnbWk_ = new stzListWalker(This)
		return _oWnbWk_.WalkNBackward(_n_)

	# Walk the inclusive range n1..n2 (descending if n1 > n2). The IB
	# form takes a return type (:WalkedPositions default / :WalkedItems).

	def WalkBetweenIB(_n1_, _n2_, pReturn)
		_anWbPos_ = _n1_ : _n2_
		_cWbRet_ = pReturn
		if isList(pReturn) and ring_len(pReturn) = 2 and isString(pReturn[1])
			_cWbRet_ = pReturn[2]
		ok
		if _cWbRet_ = :WalkedItems or _cWbRet_ = :Items
			return This.ItemsAtPositions(_anWbPos_)
		ok
		return _anWbPos_

	# Returns the positions from one position to another, as a walk.
	#
	#   _n1_       the position to start from
	#   _n2_       the position to stop at
	#   returns    a list of positions
	#   see        Walk
	def WalkBetween(_n1_, _n2_)
		return This.WalkBetweenIB(_n1_, _n2_, :WalkedPositions)

	# Walk forward 1..n then back n-1..1.

	def WalkForthAndBackXT(pReturn)
		_nWfLen_ = This.NumberOfItems()
		_anWfPos_ = []
		for iWf = 1 to _nWfLen_
			_anWfPos_ + iWf
		next
		for iWf = _nWfLen_ - 1 to 1 step -1
			_anWfPos_ + iWf
		next
		_cWfRet_ = pReturn
		if isList(pReturn) and ring_len(pReturn) = 2 and isString(pReturn[1])
			_cWfRet_ = pReturn[2]
		ok
		if _cWfRet_ = :WalkedItems or _cWfRet_ = :Items
			return This.ItemsAtPositions(_anWfPos_)
		ok
		return _anWfPos_

	# Returns the positions walked from the first to the last and back to the first.
	#
	#   returns    a list of positions
	#   see        WalkBackAndForth
	def WalkForthAndBack()
		return This.WalkForthAndBackXT(:WalkedPositions)

	# Returns the positions walked from the first up to and including the first occurrence of the item.
	#
	#   returns    a list of positions
	#   see        WalkUntil
	#@ aka  Walk forward up to and including the first occurrence of pItem.
	def WalkUntilItem(pItem)
		_nWuiPos_ = This.FindFirst(pItem)
		if _nWuiPos_ > 0
			return 1 : _nWuiPos_
		ok
		return []

	# Returns the positions of the items that meet the W condition.
	#
	#   returns    a list of positions
	#   see        WalkWhen
	def WalkW(pcCondition)
		_oWwWk_ = new stzListWalker(This)
		return _oWwWk_.WalkW(pcCondition)

	# Returns the positions walked from the first until an item meets the condition, that one included.
	#
	#   returns    a list of positions
	#   see        WalkBetween
	def WalkUntil(pcCondition)
		_oWuWk_ = new stzListWalker(This)
		return _oWuWk_.WalkUntil(pcCondition)

	# Returns the positions walked from the first while the items meet the condition.
	#
	#   returns    a list of positions
	#   see        WalkWhen
	def WalkWhile(pcCondition)
		_oWwhWk_ = new stzListWalker(This)
		return _oWwhWk_.WalkWhile(pcCondition)

	# Returns the positions walked forwards by step, then backwards over those skipped.
	#
	#   _nStep_    the step
	#   returns    a list of positions
	#   see        WalkBackAndForth
	def WalkZigZag(_nStep_)
		_oWzzWk_ = new stzListWalker(This)
		return _oWzzWk_.WalkZigZag(_nStep_)

	# Returns the positions n, 2n, 3n and so on.
	#
	#   _n_        the step
	#   returns    a list of positions
	#   see        WalkNForward
	def WalkEveryNth(_n_)
		_oWenWk_ = new stzListWalker(This)
		return _oWenWk_.WalkEveryNth(_n_)

	# Returns the positions from one position to another, both included.
	#
	#   nFrom      the position to start from
	#   nTo        the position to stop at
	#   returns    a list of positions
	#   see        WalkBetween
	#@ aka  PositionsWhere already defined above as alias of FindAllItemsW
	def WalkFromTo(nFrom, nTo)
		_oWftWk_ = new stzListWalker(This)
		return _oWftWk_.WalkFromTo(nFrom, nTo)

	# Returns the positions walked forwards, skipping n items between each.
	#
	#   _n_        how many items to skip
	#   returns    a list of positions
	#   see        WalkEveryNth
	def WalkSkipping(_n_)
		_oWsWk_ = new stzListWalker(This)
		return _oWsWk_.WalkSkipping(_n_)

	# Returns the running result of the expression over the items.
	#
	#   returns    a list of values
	#   see        Walk
	def WalkAccumulating(pcExpr)
		_oWaWk_ = new stzListWalker(This)
		return _oWaWk_.WalkAccumulating(pcExpr)

	# Returns the positions of the items that meet the W condition.
	#
	#   returns    a list of positions
	#   see        WalkW
	def WalkWhere(pcCondition)
		_oWhWk_ = new stzListWalker(This)
		return _oWhWk_.WalkWhere(pcCondition)


	# Returns the positions walked from the first item that meets the condition to the end.
	#
	#   returns    a list of positions
	#   see        WalkWhile
	#@ aka  The When-walk over the items (see stzListWalker), driven by the given condition.
	def WalkWhen(pcCondition)
		_oWnWk_ = new stzListWalker(This)
		return _oWnWk_.WalkWhen(pcCondition)

	# The When-walk with explicit direction and return selection
	# (see stzListWalker).
	def WalkWhenXT(pcCondition, pcDirection, pReturn)
		_oWnxWk_ = new stzListWalker(This)
		return _oWnxWk_.WalkWhenXT(pcCondition, pcDirection, pReturn)

	# The Until-walk with explicit direction and return selection
	# (see stzListWalker).
	def WalkUntilXT(pcCondition, pcDirection, pReturn)
		_oWuxWk_ = new stzListWalker(This)
		return _oWuxWk_.WalkUntilXT(pcCondition, pcDirection, pReturn)

	# The While-walk with explicit direction and return selection
	# (see stzListWalker).
	def WalkWhileXT(pcCondition, pcDirection, pReturn)
		_oWwxWk_ = new stzListWalker(This)
		return _oWwxWk_.WalkWhileXT(pcCondition, pcDirection, pReturn)

	  #-------------------------------#
	 #  MOVER DELEGATIONS            #
	#-------------------------------#

	# Moves the item at one position to another position, in place.
	#
	#   _n1_       the position to take the item from
	#   _n2_       the position to put it at
	#   returns    nothing; the list changes
	#   see        SwapItems
	#@ aka  Move / Swap accept the named-param spellings Move(:ItemFromPosition = a, :To = b), Swap(:Positions = a, :And = b), and the value form Swap(item1, :And = item2).
	def Move(_n1_, _n2_)
		if isList(_n1_) and len(_n1_) = 2 and isString(_n1_[1]) and
		   (lower(_n1_[1]) = "itemfromposition" or lower(_n1_[1]) = "fromposition" or
		    lower(_n1_[1]) = "from") and isNumber(_n1_[2])
			_n1_ = _n1_[2]
		ok
		if isList(_n2_) and len(_n2_) = 2 and isString(_n2_[1]) and
		   (lower(_n2_[1]) = "to" or lower(_n2_[1]) = "toposition") and isNumber(_n2_[2])
			_n2_ = _n2_[2]
		ok
		_oMvMvr_ = new stzListMover(This)
		_oMvMvr_.Move(_n1_, _n2_)
		This.UpdateWith(_oMvMvr_.Content())

	# Exchanges the items at the two given positions, in place.
	#
	#   _n1_       the first position
	#   _n2_       the second position
	#   returns    nothing; the list changes
	#   example    o1.Swap(1, 3)
	#              ? @@( o1.Content() )
	#              #--> [ "c", "b", "a", "b" ]
	#@ aka  exchange, swap positions, interchange two items
	#@ aka  Exchange the items at the two given positions (mutating).
	def Swap(_n1_, _n2_)
		# THE NAME OF THE PAIR DOES NOT DECIDE ANYTHING -- the VALUE does.
		#
		# This recognised exactly :Positions/:Position on the left and :And on
		# the right, so Swap( :Items = 2, :AndItem = 3 ) matched neither: both
		# arguments stayed two-element lists, reached stzListMover.Swap as
		# lists, and the call did nothing at all. Silently -- a swap that does
		# not swap looks like a list that was already in order.
		#
		# Every spelling a caller has reached for means the same two things:
		# a NUMBER is a position, anything else is an item to be located. So
		# the pair is unwrapped whatever it is called, and the value is read
		# after.
		if isList(_n1_) and len(_n1_) = 2 and isString(_n1_[1])
			_n1_ = _n1_[2]
		ok
		if isList(_n2_) and len(_n2_) = 2 and isString(_n2_[1])
			_n2_ = _n2_[2]
		ok

		# Values, not positions: find where each one sits.
		if NOT isNumber(_n1_) or NOT isNumber(_n2_)
			_nSw1_ = This.FindFirst(_n1_)
			_nSw2_ = This.FindFirst(_n2_)
			if _nSw1_ < 1 or _nSw2_ < 1 return ok
			_n1_ = _nSw1_
			_n2_ = _nSw2_
		ok
		_oSwMvr_ = new stzListMover(This)
		_oSwMvr_.Swap(_n1_, _n2_)
		This.UpdateWith(_oSwMvr_.Content())

	# Moves the item at position n to the start, in place.
	#
	#   _n_        the position of the item
	#   returns    nothing; the list changes
	#   see        MoveToEnd
	#@ aka  Move the item at position n to the START of the list (mutating).
	def MoveToStart(_n_)
		_oMtsMvr_ = new stzListMover(This)
		_oMtsMvr_.MoveToStart(_n_)
		This.UpdateWith(_oMtsMvr_.Content())

	# Moves the item at position n to the end, in place.
	#
	#   _n_        the position of the item
	#   returns    nothing; the list changes
	#   see        MoveToStart
	#@ aka  Move the item at position n to the END of the list (mutating).
	def MoveToEnd(_n_)
		_oMteMvr_ = new stzListMover(This)
		_oMteMvr_.MoveToEnd(_n_)
		This.UpdateWith(_oMteMvr_.Content())

	# Swaps the first and the last items, in place.
	#
	#   returns    nothing; the list changes
	#   see        SwapItems
	def SwapFirstAndLast()
		_oSfalMvr_ = new stzListMover(This)
		_oSfalMvr_.SwapFirstAndLast()
		This.UpdateWith(_oSfalMvr_.Content())

	# Move the items at the given positions to position nTo
	# (mutating).
	def MoveMany(panPositions, nTo)
		_oMmMvr_ = new stzListMover(This)
		_oMmMvr_.MoveMany(panPositions, nTo)
		This.UpdateWith(_oMmMvr_.Content())

	# Moves the items n places to the left, in place, the first ones coming round to the end.
	#
	#   _n_        how many places to rotate
	#   returns    nothing; the list changes
	#   see        RotatedLeft
	def RotateLeft(_n_)
		_oRlMvr_ = new stzListMover(This)
		_oRlMvr_.RotateLeft(_n_)
		This.UpdateWith(_oRlMvr_.Content())

	# Returns a copy with the items moved n places to the left, the first ones coming round to the end.
	#
	#   _n_        how many places to rotate
	#   returns    a list of items
	#   see        RotatedRight
	def RotatedLeft(_n_)
		_oRdlMvr_ = new stzListMover(This)
		return _oRdlMvr_.RotatedLeft(_n_)

	# Moves the items n places to the right, in place, the last ones coming round to the start.
	#
	#   _n_        how many places to rotate
	#   returns    nothing; the list changes
	#   see        RotatedRight
	def RotateRight(_n_)
		_oRrMvr_ = new stzListMover(This)
		_oRrMvr_.RotateRight(_n_)
		This.UpdateWith(_oRrMvr_.Content())

	# Returns a copy with the items moved n places to the right, the last ones coming round to the start.
	#
	#   _n_        how many places to rotate
	#   returns    a list of items
	#   see        RotatedLeft
	def RotatedRight(_n_)
		_oRdrMvr_ = new stzListMover(This)
		return _oRdrMvr_.RotatedRight(_n_)

	# Puts the items in random order, in place.
	#
	#   returns    nothing; the list changes
	#   see        Shuffled
	def Shuffle()
		_oShMvr_ = new stzListMover(This)
		_oShMvr_.Shuffle()
		This.UpdateWith(_oShMvr_.Content())

	# Returns a copy with the items in random order; the list is unchanged.
	#
	#   returns    a list of items
	#   see        Randomize
	#@ aka  randomize, mix, scramble, random order, jumble
	def Shuffled()
		_oShdMvr_ = new stzListMover(This)
		return _oShdMvr_.Shuffled()

	# Moves the first occurrence of the item to the start, in place.
	#
	#   returns    nothing; the list changes
	#   see        MoveItemToEnd
	def MoveItemToStart(pItem)
		_oMitsMvr_ = new stzListMover(This)
		_oMitsMvr_.MoveItemToStart(pItem)
		This.UpdateWith(_oMitsMvr_.Content())

	# Moves the first occurrence of the item to the end, in place.
	#
	#   returns    nothing; the list changes
	#   see        MoveItemToStart
	def MoveItemToEnd(pItem)
		_oMiteMvr_ = new stzListMover(This)
		_oMiteMvr_.MoveItemToEnd(pItem)
		This.UpdateWith(_oMiteMvr_.Content())

	  #-------------------------------#
	 #  SECTIONS DELEGATIONS         #
	#-------------------------------#

	def SectionCSZ(_n1_, _n2_, pCaseSensitive)
		_oScszSec_ = new stzListSections(This)
		return _oScszSec_.SectionCSZ(_n1_, _n2_, pCaseSensitive)

	def SectionZ(_n1_, _n2_)
		return This.SectionCSZ(_n1_, _n2_, 1)

	def SectionCSZZ(_n1_, _n2_, pCaseSensitive)
		_oScszzSec_ = new stzListSections(This)
		return _oScszzSec_.SectionCSZZ(_n1_, _n2_, pCaseSensitive)

	def SectionZZ(_n1_, _n2_)
		return This.SectionCSZZ(_n1_, _n2_, 1)

	# Returns the given sections of the list, each as a list of items.
	#
	#   paSections   a list of sections, each [ start, end ]
	#   returns      a list of lists
	#   see          Section, SplitBeforePositions
	#   example      ? @@( o1.Sections([ [ 1, 2 ], [ 3, 4 ] ]) )
	#                #--> [ [ "a", "b" ], [ "c", "b" ] ]
	def Sections(paSections)
		_oSsSec_ = new stzListSections(This)
		return _oSsSec_.Sections(paSections)

	# Returns the sections outside one section, as [ start, end ] pairs.
	#
	#   _n1_       the position of the first item
	#   _n2_       the position of the last item
	#   returns    a list of [ start, end ] pairs
	#   see        FindAntiSections
	def FindAntiSection(_n1_, _n2_)
		_oFasSec_ = new stzListSections(This)
		return _oFasSec_.FindAntiSection(_n1_, _n2_)

	# Raises error R19 today instead of returning the items outside one section.
	#
	#   _n1_       the position of the first item
	#   _n2_       the position of the last item
	#   returns    nothing today
	#   warning    known defect: the call raises error R19 today, because it passes too few
	#              arguments to the code behind it
	#   see        FindAntiSection
	def AntiSection(_n1_, _n2_)
		_oAsSec_ = new stzListSections(This)
		return _oAsSec_.AntiSection(_n1_, _n2_)

	def FindAntiSectionIB(_n1_, _n2_)
		_oFasibSec_ = new stzListSections(This)
		return _oFasibSec_.FindAntiSectionIB(_n1_, _n2_)

	def AntiSectionIB(_n1_, _n2_)
		_oAsibSec_ = new stzListSections(This)
		return _oAsibSec_.AntiSectionIB(_n1_, _n2_)

	# Returns the sections that lie outside the given sections, as [ start, end ] pairs.
	#
	#   returns    a list of [ start, end ] pairs
	#   see        AntiSections
	#@ aka  The [start, end] sections OUTSIDE the given sections.
	def FindAntiSections(paSections)
		if isList(paSections) and StzLen(paSections) = 2 and
		   isString(paSections[1]) and StzCaseFold(paSections[1]) = "of"
			paSections = paSections[2]
		ok

		# Adjust sections from 1-based to 0-based for engine
		_aFasAdj_ = []
		for _iFas_ = 1 to StzLen(paSections)
			_aFasPair_ = paSections[_iFas_]
			_nFasS_ = _aFasPair_[1] - 1
			_nFasE_ = _aFasPair_[2] - 1
			@AddItem(_aFasAdj_, [ _nFasS_, _nFasE_ ])
		next

		_pFasList_ = StzEngineMarshalList(This.Content())
		_pFasSecs_ = StzEngineMarshalList(_aFasAdj_)
		_pFasResult_ = StzEngineListAntiSections(_pFasList_, _pFasSecs_)
		_aFasRaw_ = StzEngineListContentToRingList(_pFasResult_)
		StzEngineListFree(_pFasResult_)
		StzEngineListFree(_pFasSecs_)
		StzEngineListFree(_pFasList_)

		# Adjust result pairs from 0-based back to 1-based
		_aFasResult_ = []
		for _jFas_ = 1 to StzLen(_aFasRaw_)
			_aFasPairR_ = _aFasRaw_[_jFas_]
			_nFasR1_ = _aFasPairR_[1] + 1
			_nFasR2_ = _aFasPairR_[2] + 1
			@AddItem(_aFasResult_, [ _nFasR1_, _nFasR2_ ])
		next
		return _aFasResult_

	# Returns the items that lie outside the given sections.
	#
	#   returns    a list of lists, one per stretch between the sections
	#   see        FindAntiSections, Sections
	#@ aka  The items lying outside the given sections.
	def AntiSections(paSections)
		if isList(paSections) and StzLen(paSections) = 2 and
		   isString(paSections[1]) and StzCaseFold(paSections[1]) = "of"
			paSections = paSections[2]
		ok

		_aAsSections_ = This.FindAntiSections(paSections)
		_aAsResult_ = []
		for _iAs_ = 1 to StzLen(_aAsSections_)
			_aAsPair_ = _aAsSections_[_iAs_]
			@AddItem(_aAsResult_, This.Section(_aAsPair_[1], _aAsPair_[2]))
		next
		return _aAsResult_

	# The sections outside the given ones, bounds INCLUDED (IB).
	def FindAntiSectionsIB(paSections)
		if isList(paSections) and StzLen(paSections) = 2 and
		   isString(paSections[1]) and StzCaseFold(paSections[1]) = "of"
			paSections = paSections[2]
		ok

		# IB = Including Bounds: anti-section boundaries overlap with
		# the original section boundaries by 1 position on each side.
		# E.g. sections [3,5],[7,8] on 10 items:
		#   non-IB: [1,2],[6,6],[9,10]
		#   IB:     [1,3],[5,7],[8,10]

		# Sort sections for correct boundary computation
		_aFasibSorted_ = []
		for _iFasibS_ = 1 to StzLen(paSections)
			@AddItem(_aFasibSorted_, paSections[_iFasibS_])
		next

		_nFasibLen_ = StzLen(_aFasibSorted_)
		_aFasibResult_ = []
		_nFasibN1_ = 1

		for _iFasib_ = 1 to _nFasibLen_
			_aFasibPair_ = _aFasibSorted_[_iFasib_]
			if _aFasibPair_[1] > _nFasibN1_
				_nFasibN2_ = _aFasibPair_[1]
				@AddItem(_aFasibResult_, [ _nFasibN1_, _nFasibN2_ ])
			ok
			if _iFasib_ < _nFasibLen_
				_nFasibN1_ = _aFasibPair_[2]
			ok
		next

		_nFasibLast_ = _aFasibSorted_[_nFasibLen_][2]
		if _nFasibLast_ < This.NumberOfItems()
			@AddItem(_aFasibResult_, [ _nFasibLast_, This.NumberOfItems() ])
		ok

		return _aFasibResult_

	# The items outside the given sections, bounds included (IB).
	def AntiSectionsIB(paSections)
		if isList(paSections) and StzLen(paSections) = 2 and
		   isString(paSections[1]) and StzCaseFold(paSections[1]) = "of"
			paSections = paSections[2]
		ok

		_aAsibSections_ = This.FindAntiSectionsIB(paSections)
		_aAsibResult_ = []
		for _iAsib_ = 1 to StzLen(_aAsibSections_)
			_aAsibPair_ = _aAsibSections_[_iAsib_]
			@AddItem(_aAsibResult_, This.Section(_aAsibPair_[1], _aAsibPair_[2]))
		next
		return _aAsibResult_

	# Returns the run of items of each given range, one list per range.
	#
	#   paRanges   the ranges, each [ start, end ]
	#   returns    a list with one entry per range
	#   see        AntiRanges, Sections
	def Ranges(paRanges)
		_oRgsSec_ = new stzListSections(This)
		return _oRgsSec_.Ranges(paRanges)

	# Returns the runs of items that lie outside the given ranges.
	#
	#   paRanges   the ranges, each [ start, end ]
	#   returns    a list of lists
	#   see        Ranges
	def AntiRanges(paRanges)
		_oArgsSec_ = new stzListSections(This)
		return _oArgsSec_.AntiRanges(paRanges)

	# Raises error R14 today instead of returning the ranges and the runs outside them.
	#
	#   paRanges   the ranges, each [ start, end ]
	#   returns    nothing today
	#   warning    known defect: the call raises error R14 today, because it calls
	#              SectionsAndAntiSections, which is not defined
	#   see        Ranges
	def RangesAndAntiRanges(paRanges)
		_oRaarSec_ = new stzListSections(This)
		return _oRaarSec_.RangesAndAntiRanges(paRanges)

	def AntiRangesIB(paRanges)
		_oAribSec_ = new stzListSections(This)
		return _oAribSec_.AntiRangesIB(paRanges)

	def RangesAndAntiRangesIB(paRanges)
		_oRaaribSec_ = new stzListSections(This)
		return _oRaaribSec_.RangesAndAntiRangesIB(paRanges)

	  #-------------------------------#
	 #  CLASSIFIER DELEGATIONS       #
	#-------------------------------#

	# Groups the positions of the items by item, one [ item, positions ] pair per distinct item.
	#
	#   returns    a list of [ item, list of positions ] pairs, in order of first appearance
	#   see        Mode, MostFrequent, NumberOfClasses
	#   example    ? @@( o1.Classify() )
	#              #--> [ [ "a", [ 1 ] ], [ "b", [ 2, 4 ] ], [ "c", [ 3 ] ] ]
	def Classify()
		_oCfClf_ = new stzListClassifier(This)
		return _oCfClf_.Classify()

	# Returns each distinct item with the positions where it occurs.
	#
	#   returns    a list of [ item, positions ] pairs
	#   see        Classify
	def Classified()
		_oCfdClf_ = new stzListClassifier(This)
		return _oCfdClf_.Classified()

	# Returns the distinct items, each standing as a class of the list.
	#
	#   returns    a list of items
	#   see        Classify, Klass
	def Classes()
		_oClsClf_ = new stzListClassifier(This)
		return _oClsClf_.Classes()

	# Returns the classes of a list of number lists, each written in short form as "min:max".
	#
	#   returns    a list of classes
	#   see        ClassifySF
	#@ aka  Short-form classification for lists of (contiguous) number-lists: each list-class key is rendered as "min:max" (e.g. "1:5").
	def ClassesSF()
		_aCsfC_ = This.Classes()
		_aCsfR_ = []
		_nCsfL_ = ring_len(_aCsfC_)
		for iCsf = 1 to _nCsfL_
			_aCsfR_ + _StzListKeyToShortForm(_aCsfC_[iCsf])
		next
		return _aCsfR_

	# Returns the classification of the items, with each class written in short form.
	#
	#   returns    a list of [ class, items ] pairs
	#   see        ClassesSF
	#@ aka  The classification of the items, in short form.
	def ClassifySF()
		_aClsfC_ = This.Classify()
		_aClsfR_ = []
		_nClsfL_ = ring_len(_aClsfC_)
		for iClsf = 1 to _nClsfL_
			_aClsfR_ + [ _StzListKeyToShortForm(_aClsfC_[iClsf][1]), _aClsfC_[iClsf][2] ]
		next
		return _aClsfR_

		def ClassifiedSF()
			return This.ClassifySF()

	# Returns the positions of the items that belong to the class given in short form.
	#
	#   pcShortForm   the class, in short form such as "1:5"
	#   returns       a list of positions
	#   see           Klass
	#@ aka  The members of the given class, short-form access.
	def KlassSF(pcShortForm)
		_aKsfC_ = This.ClassifySF()
		_nKsfL_ = ring_len(_aKsfC_)
		for iKsf = 1 to _nKsfL_
			if _aKsfC_[iKsf][1] = pcShortForm
				return _aKsfC_[iKsf][2]
			ok
		next
		return []

	# Groups the positions of the items by the value the expression gives for each.
	#
	#   returns    a list of [ value, positions ] pairs
	#   see        Classify
	def ClassifyBy(pcExpr)
		_oCbClf_ = new stzListClassifier(This)
		return _oCbClf_.ClassifyBy(pcExpr)

	# Returns how many different items the list holds.
	#
	#   returns    a number
	#   see        Classify, NumberOfItems
	#   example    ? o1.NumberOfClasses()
	#              #--> 3
	def NumberOfClasses()
		_oNcClf_ = new stzListClassifier(This)
		return _oNcClf_.NumberOfClasses()

	# Returns each distinct item with how many times it occurs.
	#
	#   returns    a list of [ item, count ] pairs
	#   see        FrequencyOf
	def Frequencies()
		_oFqClf_ = new stzListClassifier(This)
		return _oFqClf_.Frequencies()

	# Returns the item that occurs most often.
	#
	#   returns    an item
	#   see        Mode
	#   example    ? o1.MostFrequent()
	#              #--> b
	def MostFrequent()
		_oMfClf_ = new stzListClassifier(This)
		return _oMfClf_.MostFrequent()

	# Returns the item that occurs the fewest times.
	#
	#   returns    the item
	#   see        MostFrequent
	def LeastFrequent()
		_oLfClf_ = new stzListClassifier(This)
		return _oLfClf_.LeastFrequent()

	# Groups the positions of the items by the value of an expression.
	#
	#   pcExpr     the expression, as text, where @item stands for the current item
	#   returns    a list of [ value as text, positions ] pairs, in order of first appearance
	#   note       it groups the positions, not the items
	#   see        Classify
	#   example    o1 = new stzList([ 3, 1, 4, 1, 5 ])
	#              ? @@( o1.GroupBy("@item % 2") )
	#              #--> [ [ "1", [ 1, 2, 4, 5 ] ], [ "0", [ 3 ] ] ]
	def GroupBy(pcExpr)
		_oGbClf_ = new stzListClassifier(This)
		return _oGbClf_.GroupBy(pcExpr)

	# Returns each distinct item with how many times it occurs.
	#
	#   returns    a list of [ item, count ] pairs
	#   see        Frequencies
	def Histogram()
		_oHgClf_ = new stzListClassifier(This)
		return _oHgClf_.Histogram()

	# Returns the distinct items that occur exactly n times.
	#
	#   _n_        the number of occurrences
	#   returns    a list of items
	#   see        ItemsOccurringNTimes
	def ItemsAppearingNTimes(_n_)
		_oIantClf_ = new stzListClassifier(This)
		return _oIantClf_.ItemsAppearingNTimes(_n_)

	# Returns the distinct items that occur more than n times.
	#
	#   _n_        the number of occurrences
	#   returns    a list of items
	#   see        ItemsAppearingNTimes
	def ItemsAppearingMoreThanNTimes(_n_)
		_oIamtntClf_ = new stzListClassifier(This)
		return _oIamtntClf_.ItemsAppearingMoreThanNTimes(_n_)

	# Returns the distinct items that occur fewer than n times; today each comes back as text.
	#
	#   _n_        the number of occurrences
	#   returns    a list of strings
	#   warning    known defect: numbers come back as text, such as "3" for 3
	#   see        ItemsAppearingNTimes
	def ItemsAppearingLessThanNTimes(_n_)
		_oIaltntClf_ = new stzListClassifier(This)
		return _oIaltntClf_.ItemsAppearingLessThanNTimes(_n_)

	# Returns how many times the item occurs.
	#
	#   returns    a number
	#   see        Frequencies
	def FrequencyOf(pItem)
		_oFoClf_ = new stzListClassifier(This)
		return _oFoClf_.FrequencyOf(pItem)

	# Returns the items that occur most often.
	#
	#   returns    a list of items, more than one when they tie
	#   see        MostFrequent, Classify
	#   example    ? @@( o1.Mode() )
	#              #--> [ "b" ]
	def Mode()
		_oMdClf_ = new stzListClassifier(This)
		return _oMdClf_.Mode()

	# Returns the list cut into its two halves.
	#
	#   returns    a list of two lists
	#   see        Halves
	def Bisect()
		_oBsClf_ = new stzListClassifier(This)
		return _oBsClf_.Bisect()

	# Returns the first floor(n/2) items.
	#
	#   returns    a list of items
	#   see        SecondHalf
	#@ aka  The first floor(n/2) items of the list.
	def FirstHalf()
		# Authoritative Softanza split: the FIRST half is the floor(n/2)
		# leading items (the middle item of an odd list goes to neither
		# plain half -- use FirstHalfXT/SecondHalfXT to include it).
		return This.Section(1, floor(This.NumberOfItems() / 2))

	# Returns the items from position floor(n/2)+1 on; the longer half when the count is odd.
	#
	#   returns    a list of items
	#   see        FirstHalf
	#@ aka  The items from floor(n/2)+1 on (the longer half when odd).
	def SecondHalf()
		# The SECOND half is everything from floor(n/2)+1 onward -- so for
		# an odd list it carries the middle item (mirror of FirstHalf).
		_nLen_ = This.NumberOfItems()
		return This.Section(floor(_nLen_ / 2) + 1, _nLen_)

	# Splits the items into those that meet the W condition and those that do not.
	#
	#   returns    a list of two lists
	#   see        FindW
	def PartitionW(pcCondition)
		_oPwClf_ = new stzListClassifier(This)
		return _oPwClf_.PartitionW(pcCondition)

	# Returns the list cut into parts of n items each, the last part taking what remains.
	#
	#   _n_        the number of items in each part
	#   returns    a list of lists
	#   see        SplittedToPartsOfNItems
	def Chunks(_n_)
		_oChClf_ = new stzListClassifier(This)
		return _oChClf_.Chunks(_n_)

	  #-------------------------------#
	 #  RANDOM DELEGATIONS           #
	#-------------------------------#

	# Returns a position picked at random.
	#
	#   returns    a number
	#   see        RandomItem
	def RandomPosition()
		_oRpRnd_ = new stzListRandom(This)
		return _oRpRnd_.RandomPosition()

		def ARandomPosition()
			return This.RandomPosition()

		def APosition()
			return This.RandomPosition()

		def AnyPosition()
			return This.RandomPosition()

	# Returns a random [ start, end ] pair of positions within the list.
	#
	#   returns    a pair [ start, end ]
	#   see        RandomPosition
	#@ aka  A random [start, end] pair within the list's positions.
	def RandomSection()
		# Return a random [start, end] pair within 1..N.
		_nRsN_ = len(@aContent)
		if _nRsN_ = 0
			return [ 0, 0 ]
		ok
		_nRsA_ = ARandomNumberBetween(1, _nRsN_)
		_nRsB_ = ARandomNumberBetween(1, _nRsN_)
		if _nRsA_ > _nRsB_
			_nRsT_ = _nRsA_
			_nRsA_ = _nRsB_
			_nRsB_ = _nRsT_
		ok
		return [ _nRsA_, _nRsB_ ]

		def ARandomSection()
			return This.RandomSection()

		def ASection()
			return This.RandomSection()

		def AnySection()
			return This.RandomSection()

	# Returns a position picked at random, after position n.
	#
	#   _n_        the position to stay after
	#   returns    a number
	#   see        RandomPositionLessThan
	def RandomPositionGreaterThan(_n_)
		_oRpgtRnd_ = new stzListRandom(This)
		return _oRpgtRnd_.RandomPositionGreaterThan(_n_)

	# Returns a position picked at random, before position n.
	#
	#   _n_        the position to stay before
	#   returns    a number
	#   see        RandomPositionGreaterThan
	def RandomPositionLessThan(_n_)
		_oRpltRnd_ = new stzListRandom(This)
		return _oRpltRnd_.RandomPositionLessThan(_n_)

	def RandomPositionExcept(_n_)
		_oRpeRnd_ = new stzListRandom(This)
		return _oRpeRnd_.RandomPositionExcept(_n_)

	# Returns a position picked at random, outside the given positions.
	#
	#   returns    a number
	#   see        RandomPosition
	def RandomPositionExceptPositions(panPos)
		_oRpepRnd_ = new stzListRandom(This)
		return _oRpepRnd_.RandomPositionExceptPositions(panPos)

	# Returns n positions picked at random.
	#
	#   _n_        how many positions
	#   returns    a list of positions
	#   see        NRandomItems
	def NRandomPositions(_n_)
		_oNrpRnd_ = new stzListRandom(This)
		return _oNrpRnd_.NRandomPositions(_n_)

	def RandomItemExceptCS(pItem, pCaseSensitive)
		_oRiecsRnd_ = new stzListRandom(This)
		return _oRiecsRnd_.RandomItemExceptCS(pItem, pCaseSensitive)

	def RandomItemExcept(pItem)
		return This.RandomItemExceptCS(pItem, 1)

	# Returns an item picked at random, leaving out the item at the given position.
	#
	#   _n_        the position to leave out
	#   returns    the item
	#   see        RandomItem
	def RandomItemExceptPosition(_n_)
		_oRiepRnd_ = new stzListRandom(This)
		return _oRiepRnd_.RandomItemExceptPosition(_n_)

	# Shuffles the items into a random order, in place.
	#
	#   returns    nothing; the list changes
	#   see        Shuffled
	def Randomize()
		_oRzRnd_ = new stzListRandom(This)
		_oRzRnd_.Randomize()
		This.UpdateWith(_oRzRnd_.Content())

	# Returns a copy with the items in random order; the list is unchanged.
	#
	#   returns    a list of items
	#   see        Randomize
	def Randomized()
		_oRzdRnd_ = new stzListRandom(This)
		return _oRzdRnd_.Randomized()

	# Shuffles the number items among their own places, in place.
	#
	#   returns    nothing; the list changes
	#   see        Randomize
	def RandomizeNumbers()
		_oRznRnd_ = new stzListRandom(This)
		_oRznRnd_.RandomizeNumbers()
		This.UpdateWith(_oRznRnd_.Content())

		# Shuffles the number items among their own places, in place.
		#
		#   returns    nothing; the list changes
		#   see        RandomizeNumbers
		def RandomiseNumbers()
			This.RandomizeNumbers()

		# Shuffles the number items among their own places, in place.
		#
		#   returns    nothing; the list changes
		#   see        RandomizeNumbers
		def ShuffleNumbers()
			This.RandomizeNumbers()

	# Shuffles the string items among their own places, in place.
	#
	#   returns    nothing; the list changes
	#   see        RandomizeNumbers
	def RandomizeStrings()
		_oRzsStr_ = new stzListRandom(This)
		_oRzsStr_.RandomizeStrings()
		This.UpdateWith(_oRzsStr_.Content())

		# Shuffles the string items among their own places, in place.
		#
		#   returns    nothing; the list changes
		#   see        RandomizeStrings
		def RandomiseStrings()
			This.RandomizeStrings()

		# Shuffles the string items among their own places, in place.
		#
		#   returns    nothing; the list changes
		#   see        RandomizeStrings
		def ShuffleStrings()
			This.RandomizeStrings()

	# Shuffles the items between two positions, in place.
	#
	#   _n1_       the position of the first item
	#   _n2_       the position of the last item
	#   returns    nothing; the list changes
	#   see        Randomize
	def RandomizeSection(_n1_, _n2_)
		_oRzsRnd_ = new stzListRandom(This)
		_oRzsRnd_.RandomizeSection(_n1_, _n2_)
		This.UpdateWith(_oRzsRnd_.Content())

	# Returns a copy with the items between two positions shuffled; the list is unchanged.
	#
	#   _n1_       the position of the first item
	#   _n2_       the position of the last item
	#   returns    a list of items
	#   see        RandomizeSection
	def SectionRandomized(_n1_, _n2_)
		_oSrRnd_ = new stzListRandom(This)
		return _oSrRnd_.SectionRandomized(_n1_, _n2_)

	  #-------------------------------#
	 #  PERFORMER DELEGATIONS        #
	#-------------------------------#

	# Perform/PerformOn/Yield already defined in core

	def PerformW(pcCondition, pcAction)
		_oPwPrf_ = new stzListPerformer(This)
		_oPwPrf_.PerformW(pcCondition, pcAction)
		This.UpdateWith(_oPwPrf_.Content())

	# Applies the action to the items at the given positions that meet the condition.
	#
	#   panPos        the positions to look at
	#   pcCondition   the W condition
	#   pcAction      the expression to run for each item
	#   returns       nothing; the items may change
	#   see           YieldAtW
	def PerformAtW(panPos, pcCondition, pcAction)
		_oPawPrf_ = new stzListPerformer(This)
		_oPawPrf_.PerformAtW(panPos, pcCondition, pcAction)
		This.UpdateWith(_oPawPrf_.Content())

	# Returns the yielder applied to the items at the given positions.
	#
	#   panPos      the positions to look at
	#   pcYielder   the expression that makes each value
	#   returns     a list of values
	#   see         YieldAtW
	def YieldOn(panPos, pcYielder)
		_oYoPrf_ = new stzListPerformer(This)
		return _oYoPrf_.YieldOn(panPos, pcYielder)

	def YieldW(pcCondition, pcYielder)
		_oYwPrf_ = new stzListPerformer(This)
		return _oYwPrf_.YieldW(pcCondition, pcYielder)

	#-- YieldXT: positional / conditional yielder. The yielder is "@item"
	#-- (or "@char") -- the value at each visited position. The window is
	#-- given by named options:
	#--   :FromPosition = a, :To = b   -> positions a..b inclusive (b may be
	#--                                    negative, counting from the end).
	#--   :StartingAt = a, :Until = c  -> from a onward, stop BEFORE the first
	#--                                    item satisfying the W-condition c.
	#--   :StartingAt = a, :UntilXT = c-> same, but INCLUDE that stop item.
	def YieldXT(pcYielder, p2, p3)
		_nLen_ = This.NumberOfItems()
		_aC_ = This.Content()

		_nFrom_ = 0 _nTo_ = 0 _bRange_ = 0
		_nStart_ = 0 _cUntil_ = "" _bUntil_ = 0 _bInc_ = 0

		_aOpts_ = [ p2, p3 ]
		for _iYo_ = 1 to 2
			_p_ = _aOpts_[_iYo_]
			if isList(_p_) and len(_p_) = 2 and isString(_p_[1])
				_k_ = lower(_p_[1])
				_v_ = _p_[2]
				if _k_ = "fromposition"
					_nFrom_ = _v_ _bRange_ = 1
				but _k_ = "to"
					_nTo_ = _v_ _bRange_ = 1
				but _k_ = "startingat"
					_nStart_ = _v_
				but _k_ = "until"
					_cUntil_ = _v_ _bUntil_ = 1 _bInc_ = 0
				but _k_ = "untilxt"
					_cUntil_ = _v_ _bUntil_ = 1 _bInc_ = 1
				ok
			ok
		next

		_aRes_ = []

		if _bRange_
			_a_ = _nFrom_
			_b_ = _nTo_
			if _b_ < 0 _b_ = _nLen_ + _b_ + 1 ok
			if _a_ < 1 _a_ = 1 ok
			if _b_ > _nLen_ _b_ = _nLen_ ok
			for _i_ = _a_ to _b_
				_aRes_ + _aC_[_i_]
			next
			return _aRes_
		ok

		if _bUntil_
			if _nStart_ < 1 _nStart_ = 1 ok
			for _i_ = _nStart_ to _nLen_
				# does aC[_i_] satisfy the until-condition?
				_oOne_ = new stzList([ _aC_[_i_] ])
				_bHit_ = ( len(_oOne_.FindAllItemsW(_cUntil_)) > 0 )
				if _bHit_
					if _bInc_ _aRes_ + _aC_[_i_] ok
					exit
				ok
				_aRes_ + _aC_[_i_]
			next
			return _aRes_
		ok

		# no window -> yield every item
		return _aC_

	# Returns the yielder applied to the items at the given positions that meet the condition.
	#
	#   panPos        the positions to look at
	#   pcCondition   the W condition
	#   pcYielder     the expression that makes each value
	#   returns       a list of values
	#   see           YieldW
	#@ aka  YieldW(pcCondition, pcYielder): the @item-syntax form of YieldW -- for items matching pcCondition, yield the value of pcYielder. Engine-backed via YieldW (no eval).
	def YieldAtW(panPos, pcCondition, pcYielder)
		_oYawSub_ = This.ItemsAtPositionsQ(panPos)
		return _oYawSub_.YieldW(pcCondition, pcYielder)


	# ItemsW / ItemsW / ItemsWXTQ: filter the list by an evaluated
	# Ring expression where @item is the loop variable. Returns the
	# items for which the expression is truthy. ItemsWXTQ wraps the
	# result in stzList for fluent chains.
	def ItemsW(pcCondition)
		#-- items at the positions matching the condition (engine W DSL; any
		#-- Q(...) predicate is lowered to engine DSL inside FindAllItemsW).
		return This.ItemsAtPositions(This.FindAllItemsW(pcCondition))

		#-- XT form: the items at the positions found by the extended scan
		#-- (supports @NextItem/... and Q(EXPR).Method(...)).

		def ItemsWQ(pcCondition)
			return new stzList( This.ItemsW(pcCondition) )


		def Where(pcCondition)
			return This.ItemsW(pcCondition)

	# Runs the action on every item and its position, in place.
	#
	#   returns    nothing; the items may change
	#   see        PerformOn
	def PerformOnEachItemAndItsPosition(pcAction)
		_oPoeiapPrf_ = new stzListPerformer(This)
		_oPoeiapPrf_.PerformOnEachItemAndItsPosition(pcAction)
		This.UpdateWith(_oPoeiapPrf_.Content())

	# Returns the yielder applied to each item.
	#
	#   pcYielder   the expression that makes each value
	#   returns     a list of values
	#   see         YieldAtW
	def YieldPairs(pcYielder)
		_oYpPrf_ = new stzListPerformer(This)
		return _oYpPrf_.YieldPairs(pcYielder)

	  #-------------------------------#
	 #  MERGER DELEGATIONS           #
	#-------------------------------#

	# Returns the items paired with those of the other list; a missing partner becomes an empty string.
	#
	#   returns    a list of [ item, other item ] pairs
	#   see        ZippedWith
	def AssociateWith(paOtherList)
		_oAwMrg_ = new stzListMerger(This)
		return _oAwMrg_.AssociateWith(paOtherList)

	# Returns the items paired with those of the other list; a missing partner becomes an empty string.
	#
	#   returns    a list of [ item, other item ] pairs
	#   see        AssociateWith
	def AssociatedWith(paOtherList)
		_oAdwMrg_ = new stzListMerger(This)
		return _oAdwMrg_.AssociatedWith(paOtherList)

	# Merge the given lists into this one (mutating).
	def MergeWithMany(paLists)
		_oMwmMrg_ = new stzListMerger(This)
		_oMwmMrg_.MergeWithMany(paLists)
		This.UpdateWith(_oMwmMrg_.Content())

	def MergedWithMany(paLists)
		_oMdwmMrg_ = new stzListMerger(This)
		return _oMdwmMrg_.MergedWithMany(paLists)

	# Interleaves the items of the other list with its own, in place.
	#
	#   returns    nothing; the list changes
	#   see        InterleavedWith
	#@ aka  Interleave the given list's items with this one's (mutating).
	def InterleaveWith(paOtherList)
		_oIwMrg_ = new stzListMerger(This)
		_oIwMrg_.InterleaveWith(paOtherList)
		This.UpdateWith(_oIwMrg_.Content())

	# Returns the items of both lists interleaved, one from each in turn; the list is unchanged.
	#
	#   returns    a list of items
	#   see        InterleaveWith
	def InterleavedWith(paOtherList)
		_oIdwMrg_ = new stzListMerger(This)
		return _oIdwMrg_.InterleavedWith(paOtherList)

	# Returns the items paired with those of the other list, up to the shorter one.
	#
	#   returns    a list of [ item, other item ] pairs
	#   see        ZippedWith
	def ZipWith(paOtherList)
		_oZwMrg_ = new stzListMerger(This)
		return _oZwMrg_.ZipWith(paOtherList)

	# Returns the items paired with those of the other list, up to the shorter one.
	#
	#   returns    a list of [ item, other item ] pairs
	#   see        Zipped
	def ZippedWith(paOtherList)
		_oZdwMrg_ = new stzListMerger(This)
		return _oZdwMrg_.ZippedWith(paOtherList)

	# Returns the first items and the second items of the pairs as two lists; the list is unchanged.
	#
	#   returns    a list of two lists
	#   see        Unzipped
	def Unzip()
		_oUzMrg_ = new stzListMerger(This)
		return _oUzMrg_.Unzip()

	# Returns the first items and the second items of the pairs as two lists.
	#
	#   returns    a list of two lists
	#   see        Unzip
	def Unzipped()
		_oUzdMrg_ = new stzListMerger(This)
		return _oUzdMrg_.Unzipped()

	# Puts the items of the other list in front of the list, in place.
	#
	#   returns    nothing; the list changes
	#   see        PrependedWith
	#@ aka  Put the given list's items in front (mutating).
	def PrependWith(paOtherList)
		_oPwMrg_ = new stzListMerger(This)
		_oPwMrg_.PrependWith(paOtherList)
		This.UpdateWith(_oPwMrg_.Content())

	# Returns the items of the other list followed by those of the list; the list is unchanged.
	#
	#   returns    a list of items
	#   see        MergedWith
	def PrependedWith(paOtherList)
		_oPdwMrg_ = new stzListMerger(This)
		return _oPdwMrg_.PrependedWith(paOtherList)

	# Returns the items of the list that the other list does not hold.
	#
	#   returns    a list of items
	#   see        DifferentItemsWith, DifferenceWith
	def DiffWith(paOtherList)
		_oDwMrg_ = new stzListMerger(This)
		return _oDwMrg_.DiffWith(paOtherList)

	# Returns the items present in both lists.
	#
	#   returns    a list of items
	#   see        CommonItemsWith, UnionWith, DiffWith
	#@ aka  Set-ops fetch the engine RESULT HANDLE from the merger (a number, no list copy) and unmarshal ONCE here -- one Ring method-return copy instead of two (merger return + this return).
	def IntersectWith(paOtherList)
		_pIsw_ = (new stzListMerger(This))._IntersectHandle(paOtherList)
		_aIsw_ = StzEngineListContentToRingList(_pIsw_)
		StzEngineListFree(_pIsw_)
		return _aIsw_

	# Returns the items of both lists, each once; the list is unchanged.
	#
	#   paOtherList   the list to merge in
	#   returns       a list, in order of first appearance
	#   see           CommonItems
	#   example       ? @@( o1.UnionWith([ "b", "z" ]) )
	#                 #--> [ "a", "b", "c", "z" ]
	#                 ? @@( o1.Content() )
	#                 #--> [ "a", "b", "c", "b" ]
	#@ aka  Keep the UNION with the given list -- set semantics (mutating).
	def UnionWith(paOtherList)
		_pUw_ = (new stzListMerger(This))._UnionHandle(paOtherList)
		_aUw_ = StzEngineListContentToRingList(_pUw_)
		StzEngineListFree(_pUw_)
		return _aUw_

	  #-------------------------------#
	 #  INSERTER DELEGATIONS         #
	#-------------------------------#

	# AreBoundsOfXT(pcSub, :In = host): TRUE if This (as [open,close])
	# bounds pcSub somewhere in host.
	def AreBoundsOfXT(pcSub, pNamedIn)
		if NOT (isString(pcSub) and isList(pNamedIn) and len(pNamedIn) = 2 and
		        isString(pNamedIn[1]) and lower(pNamedIn[1]) = "in" and
		        isString(pNamedIn[2]))
			return 0
		ok
		_l_ = This.List()
		if len(_l_) != 2 or NOT (isString(_l_[1]) and isString(_l_[2]))
			return 0
		ok
		_cOpen_ = _l_[1]; _cClose_ = _l_[2]
		_o_ = new stzString(pNamedIn[2])
		_aSec_ = _o_.FindBoundedByAsSections([ _cOpen_, _cClose_ ])
		_nL_ = len(_aSec_)
		for _i_ = 1 to _nL_
			_s_ = _aSec_[_i_]
			if isList(_s_) and len(_s_) = 2
				_cMid_ = _o_._EngineSlice(pNamedIn[2], _s_[1], _s_[2] - _s_[1] + 1)
				if StzFindFirst(pcSub, _cMid_) > 0 return 1 ok
			ok
		next
		return 0

	# Inserts the item before a position, in place, but one place too early today.
	#
	#   pWhere     the position, or [ :Before, n ] or [ :After, n ]
	#   returns    nothing; the list changes
	#   warning    known defect: Insert(item, n) puts the item at position n-1, and raises an error
	#              for n = 1 or past the end; InsertBefore(n, item) puts it at n
	#   see        InsertBefore, InsertAfter
	#@ aka  put at position, add at, place into, inject at index
	def Insert(pItem, pWhere)
		_oIIns_ = new stzListInserter(This)
		_oIIns_.Insert(pItem, pWhere)
		This.UpdateWith(_oIIns_.Content())

	# Inserts the item before position n, in place.
	#
	#   _n_        the position to insert before
	#   returns    nothing; the list changes
	#   see        InsertAfterPosition
	def InsertBeforePosition(_n_, pItem)
		_oIbpIns_ = new stzListInserter(This)
		_oIbpIns_.InsertBeforePosition(_n_, pItem)
		This.UpdateWith(_oIbpIns_.Content())

	# Inserts the item after position n, in place.
	#
	#   _n_        the position to insert after
	#   returns    nothing; the list changes
	#   see        InsertBeforePosition
	def InsertAfterPosition(_n_, pItem)
		_oIapIns_ = new stzListInserter(This)
		_oIapIns_.InsertAfterPosition(_n_, pItem)
		This.UpdateWith(_oIapIns_.Content())

	# Inserts the item before each of the given positions, in place.
	#
	#   panPositions   the positions to insert before
	#   returns        nothing; the list changes
	#   see            InsertAfterPositions, InsertBefore
	#@ aka  Insert the item before EACH of the given positions (mutating).
	def InsertBeforePositions(panPositions, pItem)
		if NOT isList(panPositions) return ok
		_aIbpSorted_ = _ListCopy(panPositions)
		_nIbpL_ = len(_aIbpSorted_)
		# Sort descending so earlier inserts stay valid.
		for _iIbp_ = 2 to _nIbpL_
			_vIbp_ = _aIbpSorted_[_iIbp_]
			_jIbp_ = _iIbp_ - 1
			while _jIbp_ >= 1 and _aIbpSorted_[_jIbp_] < _vIbp_
				_aIbpSorted_[_jIbp_ + 1] = _aIbpSorted_[_jIbp_]
				_jIbp_--
			end
			_aIbpSorted_[_jIbp_ + 1] = _vIbp_
		next
		# ring_insert places AT the position = right before the old
		# p-th item.
		for _iIbp_ = 1 to _nIbpL_
			_pIbp_ = _aIbpSorted_[_iIbp_]
			if isNumber(_pIbp_) and _pIbp_ >= 1 and _pIbp_ <= len(@aContent)
				This._InvalidateEngine()
				ring_insert(@aContent, _pIbp_, pItem)
			ok
		next

	  #-------------------------------#
	 #  BOUNDER DELEGATIONS          #
	#-------------------------------#

	def SectionXT(_n1_, _n2_)
		_oSxtBnd_ = new stzListBounder(This)
		return _oSxtBnd_.SectionXT(_n1_, _n2_)

	def AreBoundsOfCS(pcSubStr, pIn, pCaseSensitive)
		_oAbocsBnd_ = new stzListBounder(This)
		return _oAbocsBnd_.AreBoundsOfCS(pcSubStr, pIn, pCaseSensitive)

	# TRUE if the list holds the bounds of the given item inside the other list.
	#
	#   pItem      the item to test
	#   pIn        the pair, or the list of pairs, of bounds
	#   returns    TRUE or FALSE
	#   see        IsBoundedBy
	def AreBoundsOf(pItem, pIn)
		return This.AreBoundsOfCS(pItem, pIn, 1)

	def IsBoundedByCS(paBounds, pCaseSensitive)
		_oIbbcsBnd_ = new stzListBounder(This)
		return _oIbbcsBnd_.IsBoundedByCS(paBounds, pCaseSensitive)

	# TRUE if the list begins and ends with the given pair of items.
	#
	#   paBounds   the two items, [ first, last ]
	#   returns    TRUE or FALSE
	#   see        Bounds
	#   example    o1 = new stzList([ "<", "a", ">" ])
	#              ? o1.IsBoundedBy([ "<", ">" ])
	#              #--> TRUE
	def IsBoundedBy(paBounds)
		return This.IsBoundedByCS(paBounds, 1)

	# Returns the first n items and the last n items as two lists.
	#
	#   _n_        how many items on each side
	#   returns    a list of two lists
	#   see        Bounds
	def BoundsUpToNItems(_n_)
		_oButniBnd_ = new stzListBounder(This)
		return _oButniBnd_.BoundsUpToNItems(_n_)

	# Returns the first and the last items of the list.
	#
	#   returns    a list of two items
	#   see        IsBoundedBy
	#   example    ? @@( o1.Bounds() )
	#              #--> [ "a", "b" ]
	def Bounds()
		_oBsBnd_ = new stzListBounder(This)
		return _oBsBnd_.Bounds()

	# Remove the given bounds from the ends of the list (mutating).
	def RemoveBoundsCS(paBounds, pCaseSensitive)
		_oRbcsBnd_ = new stzListBounder(This)
		_oRbcsBnd_.RemoveBoundsCS(paBounds, pCaseSensitive)
		This.UpdateWith(_oRbcsBnd_.Content())

	# Removes the two given bounds from the ends of the list, in place.
	#
	#   paBounds   the pair of bounds, [ first, last ]
	#   returns    nothing; the list changes
	#   see        BoundsRemoved
	def RemoveBounds(paBounds)
		This.RemoveBoundsCS(paBounds, 1)

	# Returns a copy without the two bounds at its ends; the list is unchanged.
	#
	#   paBounds   the pair of bounds, [ first, last ]
	#   returns    a list of items
	#   see        RemoveBounds
	def BoundsRemoved(paBounds)
		_oBrBnd_ = new stzListBounder(This)
		return _oBrBnd_.BoundsRemoved(paBounds)

	# Returns the items between the first and the last.
	#
	#   returns    a list of items
	#   see        FirstAndLastItems
	def Middle()
		_oMdBnd_ = new stzListBounder(This)
		return _oMdBnd_.Middle()

	# Returns a copy where every number is kept between a minimum and a maximum; the list is unchanged.
	#
	#   nMin       the lowest value allowed
	#   _nMax_     the highest value allowed
	#   returns    a list of items
	#   see        ClampTo
	def ClampedTo(nMin, _nMax_)
		_oCtBnd_ = new stzListBounder(This)
		return _oCtBnd_.ClampedTo(nMin, _nMax_)

	# Brings every number between a minimum and a maximum, in place.
	#
	#   nMin       the lowest value allowed
	#   _nMax_     the highest value allowed
	#   returns    nothing; the list changes
	#   see        ClampedTo
	def ClampTo(nMin, _nMax_)
		_oCltBnd_ = new stzListBounder(This)
		_oCltBnd_.ClampTo(nMin, _nMax_)
		This.UpdateWith(_oCltBnd_.Content())

	# TRUE if the position lies within the list.
	#
	#   _n_        the position to test
	#   returns    TRUE or FALSE
	#   see        NumberOfItems
	def IsWithinBounds(_n_)
		_oIwbBnd_ = new stzListBounder(This)
		return _oIwbBnd_.IsWithinBounds(_n_)

	# Returns the items from one position to another, both included.
	#
	#   _n1_       the position of the first item
	#   _n2_       the position of the last item
	#   returns    a list of items
	#   see        Section
	def ItemsBetweenPositions(_n1_, _n2_)
		_oIbpBnd_ = new stzListBounder(This)
		return _oIbpBnd_.ItemsBetweenPositions(_n1_, _n2_)

	  #-------------------------------#
	 #  EACH-ITEM-IS-EITHER MINI-DSL #
	#-------------------------------#

	# TRUE if every item meets one of two descriptions, each a predicate such as :Even and a type such as :Number.
	#
	#   p1         the first predicate, or a list of predicates
	#   p2         [ :Or, second predicate ], or the second description
	#   p3         the type the items must have, such as :Number
	#   returns    TRUE or FALSE
	#@ aka  -- AllItemsAreEither / EachItemIsEither[A/An]: a symbol-DSL predicate that returns TRUE iff every item satisfies the LEFT side OR the RIGHT side. Accepted argument forms:
	def AllItemsAreEither(p1, p2, p3)
		_aEieSpec_ = This._EieResolve(p1, p2, p3)
		if _aEieSpec_ = ""
			return 0
		ok
		_cEieLT_ = _aEieSpec_[1]
		_aEieLP_ = _aEieSpec_[2]
		_cEieRT_ = _aEieSpec_[3]
		_aEieRP_ = _aEieSpec_[4]
		_nEieN_ = This.NumberOfItems()
		for _iEie_ = 1 to _nEieN_
			_xEieItem_ = @aContent[_iEie_]
			if NOT ( This._EieCheck(_xEieItem_, _cEieLT_, _aEieLP_) or
			         This._EieCheck(_xEieItem_, _cEieRT_, _aEieRP_) )
				return 0
			ok
		next
		return 1

		def EachItemIsEither(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

		def EachItemIsEitherA(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

		def EachItemIsEitherAn(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

		def ItemsAreEither(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

		def AllItemsHaveEither(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

		def ItemsHaveEither(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

	#-- Internal: parse the three params into (leftType, leftPreds,
	#   rightType, rightPreds). Returns NULL on malformed input.

	def _EieResolve(p1, p2, p3)
		_cLT_ = ""  _aLP_ = []
		_cRT_ = ""  _aRP_ = []

		# Form A: p2 = [ "Or", X ] -- shared-type DSL
		if isList(p2) and len(p2) = 2 and isString(p2[1]) and lower(p2[1]) = "or"
			if NOT isString(p3)
				return ""
			ok
			_cLT_ = p3
			_cRT_ = p3
			if isString(p1)
				_aLP_ + p1
			but isList(p1)
				_nP11Len_ = len(p1)
				for _iLoopP11_ = 1 to _nP11Len_
					_s_ = p1[_iLoopP11_]
					_aLP_ + _s_
				next
			else
				return ""
			ok
			_aRP_ + p2[2]
			return [ _cLT_, _aLP_, _cRT_, _aRP_ ]
		ok

		# Form B/C: p2 must be the bare :Or marker
		if NOT (isString(p2) and lower(p2) = "or")
			return ""
		ok

		# Resolve each side
		_aL_ = This._EieResolveSide(p1)
		if _aL_ = "" return "" ok
		_cLT_ = _aL_[1]  _aLP_ = _aL_[2]

		_aR_ = This._EieResolveSide(p3)
		if _aR_ = "" return "" ok
		_cRT_ = _aR_[1]  _aRP_ = _aR_[2]

		# Borrow type if one side is predicate-only
		if _cLT_ = "" _cLT_ = _cRT_ ok
		if _cRT_ = "" _cRT_ = _cLT_ ok
		if _cLT_ = "" return "" ok

		return [ _cLT_, _aLP_, _cRT_, _aRP_ ]

	def _EieResolveSide(pSide)
		_aTypes_ = [ "number", "string", "list", "object" ]
		_cT_ = ""  _aP_ = []
		if isString(pSide)
			if ring_find(_aTypes_, lower(pSide)) > 0
				_cT_ = pSide
			else
				_aP_ + pSide
			ok
		but isList(pSide) and len(pSide) > 0
			# Last item is the type
			_cLast_ = pSide[len(pSide)]
			if NOT isString(_cLast_)
				return ""
			ok
			if ring_find(_aTypes_, lower(_cLast_)) > 0
				_cT_ = _cLast_
				_nSideLen_ = len(pSide)
				for _i_ = 1 to _nSideLen_ - 1
					_aP_ + pSide[_i_]
				next
			else
				# No explicit type -- treat all as predicates
				_nSidePredsLen_ = len(pSide)
				for _iPreds_ = 1 to _nSidePredsLen_
					_aP_ + pSide[_iPreds_]
				next
			ok
		else
			return ""
		ok
		return [ _cT_, _aP_ ]

	def _EieCheck(pItem, pcType, paPreds)
		if pcType = ""
			return 0
		ok
		_bTypeOk_ = 0
		switch lower(pcType)
		on "number"
			_bTypeOk_ = isNumber(pItem)
		on "string"
			_bTypeOk_ = isString(pItem)
		on "list"
			_bTypeOk_ = isList(pItem)
		on "object"
			_bTypeOk_ = isObject(pItem)
		off
		if NOT _bTypeOk_
			return 0
		ok
		# All predicates must pass
		_nPreds1Len_ = len(paPreds)
		for _iLoopPreds1_ = 1 to _nPreds1Len_
			_cPred_ = paPreds[_iLoopPreds1_]
			if NOT isString(_cPred_)
				return 0
			ok
			# Skip type-name re-mentions
			if lower(_cPred_) = lower(pcType)
				loop
			ok
			_xEieI_ = pItem
			_bEieR_ = 0
			try
				eval('_bEieR_ = Stz' + pcType + 'Q(_xEieI_).Is' + _cPred_ + '()')
			catch
				return 0
			done
			if NOT _bEieR_
				return 0
			ok
		next
		return 1

	  #-------------------------------#
	 #  FLATTENER DELEGATIONS        #
	#-------------------------------#

	# Flatten/Flattened already exist in core

	  #-------------------------------#
	 #  PATHS DELEGATIONS            #
	#-------------------------------#

	# stzListPaths has only 3 methods - minimal, skip for now

	#-- DeepRemove / DeepRemoveMany: walk the nested list structure
	#   and drop any item that matches pItem / any item in paItems.
	#   Recurses into nested lists. Ported from archive line 16144;
	#   simpler implementation here -- pure structural walk, no
	#   @@()-stringification round-trip.

	# DeepContains / DeepContainsCS: does the (nested) list contain
	# pItem at any depth? Recursive walk. Complements DeepRemove.

	def DeepContainsCS(pItem, pCaseSensitive)
		return This._DeepContainsCS(@aContent, pItem, pCaseSensitive)

	# TRUE if the item occurs at any depth of a nested list.
	#
	#   returns    TRUE or FALSE
	#   see        Contains, DeepFind
	def DeepContains(pItem)
		return This.DeepContainsCS(pItem, 1)

		def DeeplyContains(pItem)
			return This.DeepContains(pItem)

	# Returns the path to every occurrence of the item, at any depth of nested lists.
	#
	#   pItem      the item to look for
	#   returns    a list of paths, each a list of positions from the top down
	#   see        Find, DeepReplace
	#   example    o1 = new stzList([ "a", [ "b", "a" ] ])
	#              ? @@( o1.DeepFind("a") )
	#              #--> [ [ 1 ], [ 2, 2 ] ]
	#@ aka  Deep find: the index-path to every (nested) occurrence of pItem. Engine-backed via the stzDeepList wrapper (stz_list_deep_find).
	def DeepFind(pItem)
		_oDfDl_ = This.DeepList()
		return _oDfDl_.DeepFind(pItem)

		def DeepFindAll(pItem)
			return This.DeepFind(pItem)

		def DeepFindCS(pItem, pCaseSensitive)
			return This.DeepFind(pItem)

	# Returns the index path of every item of a nested list, depth first.
	#
	#   returns    a list of index paths, each a list of positions
	#   see        DeepList
	#@ aka  Paths(): the index-path to every node (containers AND leaves) of the nested list, in depth-first order. Documented Softanza feature whose wiring was dropped in the split; engine-backed (stz_list_deep_paths) -- same all-node format as the reference GeneratePaths() in stzListPaths.
	def Paths()
		_oPthDl_ = This.DeepList()
		return _oPthDl_.Paths()

		def AllPaths()
			return This.Paths()

	# Returns every list item at any depth, parents before their children.
	#
	#   returns    a list of lists
	#   see        Paths
	#@ aka  Every list-valued item at any depth (depth-first pre-order). Objects are excluded (isList is false for them). E.g. ListsAtAnyLevel.
	def DeepLists()
		return _StzCollectDeepLists(@aContent)

		# Returns every sublist at any depth of nesting.
		#
		#   returns    a list of lists
		#   see        DeepLists
		#@ aka  Every sublist at ANY nesting depth.
		def ListsAtAnyLevel()
			return _StzCollectDeepLists(@aContent)

	# Replaces the content by the given list, and returns the new content.
	#
	#   pItems     the list that becomes the content, or an item to append
	#   returns    a list of items
	#   see        Update
	#@ aka  FilledWith(pItems): replace the wrapped list with pItems, then return its content. Used for the 'start from an empty list and fill it with these items' fluent shape.
	def FilledWith(pItems)
		if isList(pItems)
			This._SetContent(pItems)
		else
			This._InvalidateEngine()   # in-place @aContent mutation below
			@aContent + pItems
		ok
		return @aContent

		def FilledWithQ(pItems)
			This.FilledWith(pItems)
			return This

	# DeepReplace: recursive replace -- walk nested lists and
	# substitute every occurrence of pOld with pNew. The recursion
	# enters every list sublist; non-list items are compared with
	# Ring's = (deep-equal for lists, value-equal for scalars).

	def DeepReplaceCS(pOld, pNew, pCaseSensitive)
		if isList(pNew) and ring_len(pNew) = 2 and isString(pNew[1]) and
		   (pNew[1] = :by or pNew[1] = :By or pNew[1] = :with or pNew[1] = :With)
			pNew = pNew[2]
		ok
		This._SetContent(This._DeepReplaceCS(@aContent, pOld, pNew, pCaseSensitive))

		def DeepReplaceCSQ(pOld, pNew, pCaseSensitive)
			This.DeepReplaceCS(pOld, pNew, pCaseSensitive)
			return This

	# Replaces every occurrence of the item, at any depth of nested lists, in place.
	#
	#   pOld       the item to replace
	#   pNew       the item to put instead; :By = item is accepted
	#   returns    nothing; the list changes
	#   see        DeepFind, Replace
	#   example    o1 = new stzList([ "a", [ "b", "a" ] ])
	#              o1.DeepReplace("a", :By = "X")
	#              ? @@( o1.Content() )
	#              #--> [ "X", [ "b", "X" ] ]
	def DeepReplace(pOld, pNew)
		This.DeepReplaceCS(pOld, pNew, 1)

		def DeepReplaceQ(pOld, pNew)
			This.DeepReplace(pOld, pNew)
			return This

		# Replaces the item by a new one at any depth of a nested list, in place.
		#
		#   pOld       the item to replace
		#   pNew       the item that takes its place
		#   returns    nothing; the list changes
		#   see        DeepRemove
		def DeeplyReplace(pOld, pNew)
			This.DeepReplace(pOld, pNew)

	def _DeepReplaceCS(paList, pOld, pNew, pCaseSensitive)
		_bDrCase_ = @CaseSensitive(pCaseSensitive)
		_aDrOut_ = []
		_nDrLen_ = len(paList)
		for _iDr_ = 1 to _nDrLen_
			_xDrIt_ = paList[_iDr_]
			if isList(_xDrIt_)
				_aDrOut_ + This._DeepReplaceCS(_xDrIt_, pOld, pNew, pCaseSensitive)
			else
				if _bDrCase_
					if _xDrIt_ = pOld
						_aDrOut_ + pNew
					else
						_aDrOut_ + _xDrIt_
					ok
				else
					if isString(_xDrIt_) and isString(pOld) and
					   lower(_xDrIt_) = lower(pOld)
						_aDrOut_ + pNew
					but _xDrIt_ = pOld
						_aDrOut_ + pNew
					else
						_aDrOut_ + _xDrIt_
					ok
				ok
			ok
		next
		return _aDrOut_

	def _DeepContainsCS(paList, pItem, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nList2Len_ = len(paList)
		for _iLoopList2_ = 1 to _nList2Len_
			_xItem_ = paList[_iLoopList2_]
			if isList(_xItem_)
				if This._DeepContainsCS(_xItem_, pItem, pCaseSensitive)
					return 1
				ok
			else
				if _bCase_
					if _xItem_ = pItem
						return 1
					ok
				else
					if isString(_xItem_) and isString(pItem)
						if lower(_xItem_) = lower(pItem)
							return 1
						ok
					but _xItem_ = pItem
						return 1
					ok
				ok
			ok
		next
		return 0

	# Removes every occurrence of the item at any depth of a nested list, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveAll
	#@ aka  Remove every occurrence of the item at ANY depth of the nested list (mutating).
	def DeepRemove(pItem)
		This._SetContent(This._DeepFilterCS(@aContent, [pItem], 1))
		

		def DeepRemoveQ(pItem)
			This.DeepRemove(pItem)
			return This

		def DeepRemoveCS(pItem, pCaseSensitive)
			This._SetContent(This._DeepFilterCS(@aContent, [pItem], pCaseSensitive))
			

	# DeepRemove applied to each item of the given list (mutating).
	def DeepRemoveMany(paItems)
		if NOT isList(paItems)
			StzRaise("DeepRemoveMany: paItems must be a list")
		ok
		This._SetContent(This._DeepFilterCS(@aContent, paItems, 1))
		

		def DeepRemoveManyQ(paItems)
			This.DeepRemoveMany(paItems)
			return This

		def DeepRemoveManyCS(paItems, pCaseSensitive)
			if NOT isList(paItems)
				StzRaise("DeepRemoveManyCS: paItems must be a list")
			ok
			This._SetContent(This._DeepFilterCS(@aContent, paItems, pCaseSensitive))
			

	# Returns a copy with the item removed at any depth; the list is unchanged.
	#
	#   returns    a list of items
	#   see        DeepRemove
	#@ aka  A copy with the item removed at ANY depth; the original is unchanged.
	def DeepRemoved(pItem)
		_oDrTmp_ = new stzList(@aContent)
		_oDrTmp_.DeepRemove(pItem)
		return _oDrTmp_.Content()

	# Returns a copy with each of the given items removed at any depth; the list is unchanged.
	#
	#   returns    a list of items
	#   see        DeepRemoved
	#@ aka  A copy with each given item removed at any depth.
	def ManyDeepRemoved(paItems)
		_oMdrTmp_ = new stzList(@aContent)
		_oMdrTmp_.DeepRemoveMany(paItems)
		return _oMdrTmp_.Content()

	#-- Helper: case-sensitive deep filter. Returns a NEW list with
	#   anything matching paRemove removed at any nesting depth.
	def _DeepFilterCS(paList, paRemove, pCaseSensitive)
		_aDfR_ = []
		_bDfCase_ = @CaseSensitive(pCaseSensitive)
		_nList1Len_ = len(paList)
		for _iLoopList1_ = 1 to _nList1Len_
			_xDfItem_ = paList[_iLoopList1_]
			if isList(_xDfItem_)
				_aDfR_ + This._DeepFilterCS(_xDfItem_, paRemove, pCaseSensitive)
			else
				_bDfDrop_ = 0
				_nRemove1Len_ = len(paRemove)
				for _iLoopRemove1_ = 1 to _nRemove1Len_
					_xDfRm_ = paRemove[_iLoopRemove1_]
					if _bDfCase_
						if _xDfItem_ = _xDfRm_
							_bDfDrop_ = 1
							exit
						ok
					else
						if isString(_xDfItem_) and isString(_xDfRm_)
							if lower(_xDfItem_) = lower(_xDfRm_)
								_bDfDrop_ = 1
								exit
							ok
						but _xDfItem_ = _xDfRm_
							_bDfDrop_ = 1
							exit
						ok
					ok
				next
				if NOT _bDfDrop_
					_aDfR_ + _xDfItem_
				ok
			ok
		next
		return _aDfR_

	# Returns the Unicode codepoint of every item that is a character.
	#
	#   returns    a list: a number stays a number, a character gives its codepoint, a longer text
	#              gives the list of its codepoints
	#   example    o1 = new stzList([ "a", "bb", "c" ])
	#              ? @@( o1.Unicodes() )
	#              #--> [ 97, [ 98, 98 ], 99 ]
	#@ aka  The Unicode codepoint of each character-string item in the list.
	def Unicodes()
		return This._UnicodesOf(@aContent)

	# Recursive codepoint mapping (monolith semantics):
	#  - a number is echoed as-is
	#  - a single-codepoint string -> its scalar codepoint
	#  - a multi-codepoint string  -> the SUBLIST of its codepoints
	#  - a nested list             -> recurse, preserving structure
	# (StzCharToUnicode is single-char only, so multi-char strings go via
	#  the engine-backed stzString.Unicodes; empties/objects add nothing.)
	def _UnicodesOf(paList)
		_aRes_ = []
		_nUcLen_ = len(paList)
		for _iUc_ = 1 to _nUcLen_
			_xUc_ = paList[_iUc_]
			if isNumber(_xUc_)
				_aRes_ + _xUc_
			but isString(_xUc_)
				if StzLen(_xUc_) = 1
					_aRes_ + StzCharToUnicode(_xUc_)
				but StzLen(_xUc_) > 1
					_aRes_ + StzStringQ(_xUc_).Unicodes()
				ok
			but isList(_xUc_)
				_aRes_ + This._UnicodesOf(_xUc_)
			ok
		next
		return _aRes_

	# Returns the Unicode name of every item, when the items are characters.
	#
	#   returns    a list of names
	#   warning    it raises an error when the list is not a list of characters
	#   example    ? @@( o1.Names() )
	#              #--> [ "LATIN SMALL LETTER A", "LATIN SMALL LETTER B", "LATIN SMALL LETTER C", "LATIN SMALL LETTER B" ]
	#@ aka  The names of the items (char names for chars, object names for objects).
	def Names()
		if @IsListOfChars(This.Content())
			return This.ToStzListOfCharsQ().Names()
		else
			StzRaise("Can't proceed! In order to return names, the list must be a list of chars.")
		ok

	# Sorts the items from the greatest to the least, in place.
	#
	#   _n_        the key position, ignored for a flat list
	#   returns    nothing; the list changes
	#   see        SortDown
	#@ aka  SortOnDown / SortedOnDown for stzList: when the list is flat (numbers / strings), forwards to descending sort on the whole list. When the list is a list-of-lists, forwards to the stzListOfLists.SortOnDown(n) which sorts on column n.
	def SortOnDown(_n_)
		if This.IsListOfLists()
			_oLol_ = new stzListOfLists(@aContent)
			_oLol_.SortOnDown(_n_)
			This._SetContent(_oLol_.Content())
		else
			This.SortInDescending()
		ok

		def SortOnDownQ(_n_)
			This.SortOnDown(_n_)
			return This

		# Returns a copy sorted from the greatest to the least; the list is unchanged.
		#
		#   _n_        the key position, ignored for a flat list
		#   returns    a list of items
		#   see        SortOnDown
		#@ aka  A descending-sorted copy; the original is unchanged.
		def SortedOnDown(_n_)
			_oLolc_ = This.Copy()
			_oLolc_.SortOnDown(_n_)
			return _oLolc_.Content()

	# TRUE if every item is a number or a string.
	#
	#   returns    TRUE or FALSE
	#   see        IsMadeOfSome
	#@ aka  IsMadeOf*: predicates that answer "is every item one of the listed types?". Used by the narrative tests for mixed-content guards. The Or/And variants are synonyms -- both mean 'every item is in {numbers, strings}'.
	def IsMadeOfNumbersOrStrings()
		_nImnsLen_ = len(@aContent)
		for _iImns_ = 1 to _nImnsLen_
			if NOT (isNumber(@aContent[_iImns_]) or isString(@aContent[_iImns_]))
				return 0
			ok
		next
		return 1

		def IsMadeOfNumbersAndStrings()
			return This.IsMadeOfNumbersOrStrings()

	# TRUE if the list is not empty and every item is a number.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfNumbers
	#@ aka  Same as IsListOfNumbers.
	def IsMadeOfNumbers()
		return This.IsListOfNumbers()		#-- engine-backed (StzEngineListIsAllNumbers)

	# TRUE if the list is not empty and every item is a string.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfStrings
	#@ aka  Same as IsListOfStrings.
	def IsMadeOfStrings()
		return This.IsListOfStrings()		#-- engine-backed (StzEngineListIsAllStrings)

	# Returns the type of every item: "NUMBER", "STRING", "LIST" or "OBJECT".
	#
	#   returns    a list of type names, one per item
	#   see        FindObjects
	#   example    o1 = new stzList([ 1, "a", [ 2 ] ])
	#              ? @@( o1.Types() )
	#              #--> [ "NUMBER", "STRING", "LIST" ]
	#@ aka  Types(): map ring_type over the items, return the list of type tags. "STRING", "NUMBER", "LIST", "OBJECT". Used by the RepeatedInAPair narrative tests on stzObject.
	def Types()
		_aT_ = []
		_nTl_ = len(@aContent)
		for _iT_ = 1 to _nTl_
			_aT_ + ring_type(@aContent[_iT_])
		next
		return _aT_

		def TypesQ()
			return new stzList( This.Types() )

	# Returns the distinct item types, in order of first appearance.
	#
	#   returns    a list of type names, such as "STRING"
	#   see        Types
	#@ aka  -- Unique list of the item types (Types() with duplicates removed)
	def UniqueTypes()
		_oTypes_ = new stzList( This.Types() )
		return _oTypes_.Unique()

		def TypesU()
			return This.UniqueTypes()

		def UniqueTypesQ()
			return new stzList( This.UniqueTypes() )

	# Returns each item with its type name, in order.
	#
	#   returns    a list of [ item, type ] pairs
	#   see        UniqueTypes
	#@ aka  -- ItemsAndTheirTypes: each item paired with its type name, in order. -- e.g. [ 1, "A", [2] ] -> [ [1,"NUMBER"], ["A","STRING"], [[2],"LIST"] ].
	def ItemsAndTheirTypes()
		_aItt_ = []
		_nIttLen_ = len(@aContent)
		for _iItt_ = 1 to _nIttLen_
			_aItt_ + [ @aContent[_iItt_], ring_type(@aContent[_iItt_]) ]
		next
		return _aItt_

		def ItemsAndTheirTypesQ()
			return new stzList( This.ItemsAndTheirTypes() )

	# Returns each item type with the [ start, end ] runs where it occurs.
	#
	#   returns    a list of [ type, sections ] pairs
	#   see        UniqueTypes
	#@ aka  -- TypesAndTheirSections (alias TypesZZ): group the list into maximal -- runs of one type, then collect, per distinct type, the [start,end] -- position ranges of its runs. e.g. [1,2,"A",3] -> -- [ ["NUMBER",[[1,2],[4,4]]], ["STRING",[[3,3]]] ].
	def TypesAndTheirSections()
		_nTtsLen_ = len(@aContent)
		if _nTtsLen_ = 0 return [] ok

		# 1) maximal same-type runs as [type, start, end]
		_aTtsRuns_ = []
		_cTtsCur_ = ring_type(@aContent[1])
		_nTtsStart_ = 1
		for _iTts_ = 2 to _nTtsLen_
			_cTtsT_ = ring_type(@aContent[_iTts_])
			if _cTtsT_ != _cTtsCur_
				_aTtsRuns_ + [ _cTtsCur_, _nTtsStart_, _iTts_ - 1 ]
				_cTtsCur_ = _cTtsT_
				_nTtsStart_ = _iTts_
			ok
		next
		_aTtsRuns_ + [ _cTtsCur_, _nTtsStart_, _nTtsLen_ ]

		# 2) fold runs by type, preserving first-appearance order
		_aTtsRes_ = []
		_nTtsRuns_ = len(_aTtsRuns_)
		for _iTts2_ = 1 to _nTtsRuns_
			_cTtsTy_ = _aTtsRuns_[_iTts2_][1]
			_aTtsSec_ = [ _aTtsRuns_[_iTts2_][2], _aTtsRuns_[_iTts2_][3] ]
			_nTtsFound_ = 0
			_nTtsResLen_ = len(_aTtsRes_)
			for _iTts3_ = 1 to _nTtsResLen_
				if _aTtsRes_[_iTts3_][1] = _cTtsTy_
					_aTtsRes_[_iTts3_][2] + _aTtsSec_
					_nTtsFound_ = 1
					exit
				ok
			next
			if _nTtsFound_ = 0
				_aTtsRes_ + [ _cTtsTy_, [ _aTtsSec_ ] ]
			ok
		next
		return _aTtsRes_

		def TypesAndTheirSectionsQ()
			return new stzList( This.TypesAndTheirSections() )

		def TypesZZ()
			return This.TypesAndTheirSections()

	# Returns the items that are not numbers.
	#
	#   returns    a list of items
	#   see        OnlyNumbers
	#@ aka  -- The items that are NOT numbers (engine DSL)
	def NonNumbers()
		return This.ItemsW('{ not isNumber(@item) }')

		def NonNumbersQ()
			return new stzList( This.NonNumbers() )

	# Returns a copy without the numeric zeros; the list is unchanged.
	#
	#   returns    a list of items
	#   see        RemoveZeros
	#@ aka  -- A copy of the list with every numeric 0 removed (non-mutating)
	def ZerosRemoved()
		return This.ItemsW('{ not isNumber(@item) or @item != 0 }')

		def ZerosRemovedQ()
			return new stzList( This.ZerosRemoved() )

	# Returns the item n places before the last one, so 1 gives the item just before it.
	#
	#   _n_        how far back to count
	#   returns    the item
	#   see        NthItem
	#@ aka  -- The nth item counted from the end: NthToLast(1) is the item -- before the last, NthToLast(2) the one before it, and so on.
	def NthToLast(_n_)
		return @aContent[ ring_len(@aContent) - _n_ ]

	# Cuts the list down to its first n items, in place.
	#
	#   p          n, or :ToPosition = n
	#   returns    the list itself
	#   see        ShrinkTo
	#@ aka  -- Shrink the list down to its first n items (mutating). -- Accepts Shrink(n) or the named form Shrink(:ToPosition = n).
	def Shrink(p)
		_n_ = p
		if isList(p) and ring_len(p) = 2
			_n_ = p[2]
		ok
		This._SetContent(This.Section(1, _n_))
		return This

		def ShrinkQ(p)
			This.Shrink(p)
			return This

	# Swaps the items at two positions, in place.
	#
	#   p1         the first position
	#   p2         the second position
	#   returns    the list itself
	#   see        Move
	#@ aka  -- Swap two items by position (mutating). Accepts SwapItems(n1, n2) -- or the named form SwapItems(:AtPositions = n1, :And = n2).
	def SwapItems(p1, p2)
		_n1_ = p1
		_n2_ = p2
		if isList(p1) and ring_len(p1) = 2
			_n1_ = p1[2]
		ok
		if isList(p2) and ring_len(p2) = 2
			_n2_ = p2[2]
		ok
		This.Swap(_n1_, _n2_)
		return This

		def SwapItemsQ(p1, p2)
			This.SwapItems(p1, p2)
			return This

	# TRUE if the list holds two items and both are numbers.
	#
	#   returns    TRUE or FALSE
	#@ aka  -- A two-item list whose both items share a given type.
	def BothAreNumbers()
		if This.NumberOfItems() = 2 and
		   isNumber(This.Item(1)) and isNumber(This.Item(2))
			return 1
		else
			return 0
		ok

		def ContainsTwoNumbers()
			return This.BothAreNumbers()

		def Contains2Numbers()
			return This.BothAreNumbers()

	# TRUE if the list is a pair whose two items are strings.
	#
	#   returns    TRUE or FALSE
	#   see        BothAreLists
	#@ aka  For a PAIR: TRUE if both items are strings.
	def BothAreStrings()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and isString(This.Item(2))
			return 1
		else
			return 0
		ok

		def ContainsTwoStrings()
			return This.BothAreStrings()

		def Contains2Strings()
			return This.BothAreStrings()

	# TRUE if the list is a pair whose two items are lists.
	#
	#   returns    TRUE or FALSE
	#   see        BothAreStrings
	#@ aka  For a PAIR: TRUE if both items are lists.
	def BothAreLists()
		if This.NumberOfItems() = 2 and
		   isList(This.Item(1)) and isList(This.Item(2))
			return 1
		else
			return 0
		ok

		def ContainsTwoLists()
			return This.BothAreLists()

		def Contains2Lists()
			return This.BothAreLists()

	# TRUE if the list is a pair whose two items are objects.
	#
	#   returns    TRUE or FALSE
	#   see        BothAreLists
	#@ aka  For a PAIR: TRUE if both items are objects.
	def BothAreObjects()
		if This.NumberOfItems() = 2 and
		   isObject(This.Item(1)) and isObject(This.Item(2))
			return 1
		else
			return 0
		ok

		def ContainsTwoObjects()
			return This.BothAreObjects()

		def Contains2Objects()
			return This.BothAreObjects()

	#-- IsMadeOf family: "the list consists of these items".
	#-- IsMadeOf / IsMadeOfThese  -> contains ALL the given items.

	def IsMadeOf(paItems)
		return This.ContainsMany(paItems)

		def IsMadeOfThese(paItems)
			return This.ContainsMany(paItems)

	#-- IsMadeOfItem  -> every item equals the given one.

	def IsMadeOfItem(pItem)
		return This.ItemsAreEqualTo(pItem)

		# TRUE if the list is made of the given item only.
		def IsMadeOfThisItem(pItem)
			return This.ItemsAreEqualTo(pItem)

		# TRUE if every item is of the given type, such as "string".
		#
		#   pItem      the type name, as text
		#   returns    TRUE or FALSE
		#   see        AllItemsAreOfType
		#@ aka  TRUE if every item is of the given type.
		def AllItemsAre(pItem)
			if isString(pItem) and
			   (@IsRingOrStzType(pItem) or
			    @IsRingTypePlural(pItem) or @IsStzTypePlural(pItem))

				return This.AllItemsAreOfType(pItem)
			ok

			return This.ItemsAreEqualTo(pItem)

	#-- IsMadeOfOneOfThese  -> contains at least one of the given items.

	def IsMadeOfOneOfThese(paItems)
		return This.ContainsOneOfThese(paItems)

		# TRUE if every item is one of the given values.
		def IsMadeOfAnyOfThese(paItems)
			return This.ContainsOneOfThese(paItems)

	#-- ContainsSome / IsMadeOfSome  -> contains some (one or more) of them.

	def ContainsSomeCS(paItems, pCaseSensitive)
		if isString(paItems)
			paItems = [ paItems ]
		ok
		_bResult_ = 0
		_nLen_ = ring_len(paItems)
		for _i_ = 1 to _nLen_
			if This.ContainsCS(paItems[_i_], pCaseSensitive)
				_bResult_ = 1
				exit
			ok
		next
		return _bResult_

		# TRUE if at least one of the given items occurs in the list.
		#
		#   returns    TRUE or FALSE
		#   see        ContainsNoneOfThese
		def ContainsSome(paItems)
			return This.ContainsSomeCS(paItems, 1)

		# TRUE if every item of the list is one of the given items.
		#
		#   returns    TRUE or FALSE
		#   see        IsMadeOfSome
		def IsMadeOfSomeOfThese(paItems)
			return This.ContainsSomeCS(paItems, 1)

		# TRUE if every item of the list is one of the given items.
		#
		#   returns    TRUE or FALSE
		#   see        IsMadeOfSome
		def IsMadeOfOneOrMoreOfThese(paItems)
			return This.ContainsSomeCS(paItems, 1)

		# TRUE if every item of the list is one of the given items.
		#
		#   returns    TRUE or FALSE
		#   see        IsMadeOfSome
		def IsMadeOfOneOrMoreOf(paItems)
			return This.ContainsSomeCS(paItems, 1)

	# TRUE if every item is a list and all the lists have the same size.
	#
	#   returns    TRUE or FALSE
	#   see        IsMadeOfUniformLists
	#@ aka  -- IsMadeOfUniformLists -> all items are lists with the same size.
	def ContainsOnlyListsWithSameNumberOfItems()
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		if _nLen_ = 0
			return 0
		ok
		if NOT isList(_aContent_[1])
			return 0
		ok
		_nLenFirst_ = ring_len(_aContent_[1])
		_bResult_ = 1
		for _i_ = 2 to _nLen_
			if NOT ( isList(_aContent_[_i_]) and ring_len(_aContent_[_i_]) = _nLenFirst_ )
				_bResult_ = 0
				exit
			ok
		next
		return _bResult_

		def IsMadeOfUniformLists()
			return This.ContainsOnlyListsWithSameNumberOfItems()

		def IsMadeOfUniSizeLists()
			return This.ContainsOnlyListsWithSameNumberOfItems()

		def ContainsOnlyUniSizeLists()
			return This.ContainsOnlyListsWithSameNumberOfItems()

	#-- Thin aliases over existing methods (restored from the monolith).

	# Bounds of an item: for each occurrence of pItem, the up-to-N
	# items immediately before and after it. pUpTo is a number (same
	# count both sides) or a [before, after] pair. Accepts the named
	# form BoundsOf(item, :UpToNItems = n). (Bounds() no-arg already
	# exists, so the parametered form lives under BoundsCS/BoundsOf.)

	def BoundsCS(pItem, pUpTo, pCaseSensitive)
		if isList(pItem) and len(pItem) = 2 and isString(pItem[1]) and StzLower(pItem[1]) = "of"
			pItem = pItem[2]
		ok
		if isList(pUpTo) and len(pUpTo) = 2 and isString(pUpTo[1])
			pUpTo = pUpTo[2]
		ok
		_nLenList_ = ring_len(@aContent)
		_anPos_ = This.FindCS(pItem, pCaseSensitive)
		_nLenPos_ = ring_len(_anPos_)
		if isNumber(pUpTo)
			_nLenBound1_ = pUpTo
			_nLenBound2_ = pUpTo
		else
			_nLenBound1_ = pUpTo[1]
			_nLenBound2_ = pUpTo[2]
		ok
		_aResult_ = []
		for _i_ = 1 to _nLenPos_
			_aBounds_ = []
			if _anPos_[_i_] - _nLenBound1_ > 0
				_aBounds_ + This.Section(_anPos_[_i_] - _nLenBound1_, _anPos_[_i_] - 1)
			else
				_aBounds_ + []
			ok
			if _nLenList_ - _anPos_[_i_] >= _nLenBound2_
				_aBounds_ + This.Section(_anPos_[_i_] + 1, _anPos_[_i_] + _nLenBound2_)
			else
				_aBounds_ + []
			ok
			_aResult_ + _aBounds_
		next
		return _aResult_

	# Returns, for each occurrence of the item, the n items before it and the n after it, as [ before, after ].
	#
	#   pItem      the item to look around
	#   pUpTo      how many items on each side; :UpToNItems = n is accepted
	#   returns    a list of [ before, after ] pairs, one per occurrence; a side without room for n
	#              items comes out empty
	#   see        Bounds, Section
	#   example    o1 = new stzList([ "*", "a", "b", "c", "*", "d", "e" ])
	#              ? @@( o1.BoundsOf("*", 2) )
	#              #--> [ [ [ ], [ "a", "b" ] ], [ [ "b", "c" ], [ "d", "e" ] ] ]
	def BoundsOf(pItem, pUpTo)
		return This.BoundsCS(pItem, pUpTo, 1)

		# Returns, for each occurrence of the item, the items found on its two sides, up to n of them.
		#
		#   pUpTo      how many items to take on each side
		#   returns    a list
		#   see        BoundsOf
		def NBoundsOf(pItem, pUpTo)
			return This.BoundsCS(pItem, pUpTo, 1)


	def DupOrigins()
		return This.Duplicates()

	def FindItemsW(pCondition)
		return This.FindAllItemsW(pCondition)

	# The first n items, in the requested return type (QRT).
	def FirstNItemsQRT(_n_, pcReturnType)
		return This.NFirstItemsQRT(_n_, pcReturnType)

	def HowManyDuplicates()
		return This.NumberOfDuplicates()

	def Index()
		return This.FindItems()

	# Takes every occurrence of the item out of the list, in place, and returns the item.
	#
	#   pItem      the item to extract
	#   returns    the item that was taken out
	#   see        Remove
	#   example    ? o1.Extract("b")
	#              #--> b
	#              ? @@( o1.Content() )
	#              #--> [ "a", "c" ]
	def Extract(pItem)
		return This.ExtractCS(pItem, 1)

	# Same as Are: TRUE if every item is of the given type.
	def ItemsAre(p)
		return This.Are(p)

	# Returns the positions of the items that belong to the given class.
	#
	#   pcClass    the class, as an item of the list
	#   returns    a list of positions
	#   see        Classes, Classify
	#@ aka  The members of the given class (from Classify).
	def Klass(pcClass)
		return This.Classify()[pcClass]

	def NumberOfDuplicatesOf(pItem)
		return This.NumberOfOccurrence(pItem)

	def OnlyWhere(pcCondition)
		return This.ItemsW(pcCondition)

		def OnlyWhereW(pcCondition)
			return This.ItemsW(pcCondition)


	def RemoveCS(pItem, pCaseSensitive)
		This.RemoveAllCS(pItem, pCaseSensitive)

		# Removes the first occurrence of the item, with the case rule given, in place.
		#
		#   returns    nothing; the list changes
		#   see        RemoveFirst
		def RemoveItemCS(pItem, pCaseSensitive)
			This.RemoveAllCS(pItem, pCaseSensitive)

	def NumberOfOccurrenceW(pCondition)
		return This.CountItemsW(pCondition)

		def NumberOfOccurrencesW(pCondition)
			return This.CountItemsW(pCondition)



	#-- True if at least one item satisfies the W condition.

	def ContainsW(pcCondition)
		return ring_len(This.FindAllItemsW(pcCondition)) > 0

		def ContainsAtLeastOneW(pcCondition)
			return This.ContainsW(pcCondition)

	#-- Every section that starts at an occurrence of pItem1 and ends at
	#-- a later occurrence of pItem2. Accepts SectionsBetween(a, :And = b).

	def SectionsBetweenCS(pItem1, pItem2, pCaseSensitive)
		if isList(pItem2) and ring_len(pItem2) = 2 and isString(pItem2[1]) and
		   (pItem2[1] = :and or pItem2[1] = :And)
			pItem2 = pItem2[2]
		ok
		_anSbPos1_ = This.FindAllCS(pItem1, pCaseSensitive)
		_anSbPos2_ = This.FindAllCS(pItem2, pCaseSensitive)
		_anSbPairs_ = []
		_nSb1_ = ring_len(_anSbPos1_)
		_nSb2_ = ring_len(_anSbPos2_)
		for iSb = 1 to _nSb1_
			for jSb = 1 to _nSb2_
				if _anSbPos1_[iSb] < _anSbPos2_[jSb]
					_anSbPairs_ + [ _anSbPos1_[iSb], _anSbPos2_[jSb] ]
				ok
			next
		next
		return This.Sections(_anSbPairs_)

	# Returns the runs of items that lie between the two given items.
	#
	#   pItem1     the item that opens a run
	#   pItem2     the item that closes a run
	#   returns    a list of lists
	#   see        Sections
	def SectionsBetween(pItem1, pItem2)
		return This.SectionsBetweenCS(pItem1, pItem2, 1)

		def SectionsBetweenItems(pItem1, pItem2)
			return This.SectionsBetween(pItem1, pItem2)

	#-- Distribute this list's items over a list of "beneficiaries",
	#-- returning [beneficiary, [its items]] pairs. The plain form splits
	#-- as evenly as possible (remainder to the first ones); the XT form
	#-- takes an explicit per-beneficiary share via :Using = [n1, n2, ...].

	def DistributeOverXT(acBeneficiaryItems, _anShareOfEachItem_)
		if isList(_anShareOfEachItem_) and ring_len(_anShareOfEachItem_) = 2 and
		   isString(_anShareOfEachItem_[1]) and
		   (_anShareOfEachItem_[1] = :using or _anShareOfEachItem_[1] = :Using)
			_anShareOfEachItem_ = _anShareOfEachItem_[2]
		ok
		if NOT ( isList(acBeneficiaryItems) and ring_len(acBeneficiaryItems) > 0 )
			StzRaise("Can't distribute the items of the main list over the items of the provided list!")
		ok
		_nDoSum_ = 0
		_nDoSL_ = ring_len(_anShareOfEachItem_)
		for kDo = 1 to _nDoSL_
			_nDoSum_ += _anShareOfEachItem_[kDo]
		next
		if NOT _nDoSum_ = This.NumberOfItems()
			StzRaise("Can't distribute the items of the main list over the items of the provided list!")
		ok
		_aDoResult_ = []
		_nDoLen_ = ring_len(acBeneficiaryItems)
		_nDo1_ = 1
		for iDo = 1 to _nDoLen_
			_cDoBenef_ = acBeneficiaryItems[iDo]
			_nDoRange_ = _anShareOfEachItem_[iDo]
			_nDo2_ = _nDo1_ + _nDoRange_ - 1
			_aDoShare_ = []
			for jDo = _nDo1_ to _nDo2_
				_aDoShare_ + @aContent[jDo]
			next
			_aDoResult_ + [ _cDoBenef_, _aDoShare_ ]
			_nDo1_ = _nDo2_ + 1
		next
		return _aDoResult_

	# Shares the items out among the given beneficiaries in consecutive blocks, as [ beneficiary, items ] pairs.
	#
	#   acBeneficiaryItems   the beneficiaries that receive the items
	#   returns              a list of [ beneficiary, items ] pairs
	#@ aka  Distribute the items over the given beneficiaries, round-robin.
	def DistributeOver(acBeneficiaryItems)
		_nDoLenList_ = This.NumberOfItems()
		_nDoLenBenef_ = ring_len(acBeneficiaryItems)
		_anDoShare_ = []
		if _nDoLenBenef_ >= _nDoLenList_
			for iDo = 1 to _nDoLenList_
				_anDoShare_ + 1
			next
		else
			_nDoN_ = floor( _nDoLenList_ / _nDoLenBenef_ )
			for iDo = 1 to _nDoLenBenef_
				_anDoShare_ + _nDoN_
			next
			_nDoRest_ = _nDoLenList_ - ( _nDoN_ * _nDoLenBenef_ )
			if _nDoRest_ > 0
				for iDo = 1 to _nDoRest_
					_anDoShare_[iDo]++
				next
			ok
		ok
		return This.DistributeOverXT(acBeneficiaryItems, _anDoShare_)

	# Returns a copy without any occurrence of the item; the list is unchanged.
	#
	#   returns    a list of items
	#   see        ManyRemoved
	#@ aka  -- A copy with all occurrences of an item removed (non-mutating).
	def ItemRemoved(pItem)
		_oIrCopy_ = This.Copy()
		_oIrCopy_.RemoveAllCS(pItem, 1)
		return _oIrCopy_.Content()

		def AllOccurrencesOfThisItemRemoved(pItem)
			return This.ItemRemoved(pItem)

	#-- A copy with the items matching a W condition removed (engine DSL).

	def ItemRemovedW(pcCondition)
		_anIrwMatch_ = This.FindAllItemsW(pcCondition)
		_aIrwC_ = This.Content()
		_nIrwLen_ = ring_len(_aIrwC_)
		_aIrwRes_ = []
		for iIrw = 1 to _nIrwLen_
			_bIrwIn_ = 0
			_nIrwM_ = ring_len(_anIrwMatch_)
			for jIrw = 1 to _nIrwM_
				if _anIrwMatch_[jIrw] = iIrw
					_bIrwIn_ = 1
					exit
				ok
			next
			if _bIrwIn_ = 0
				_aIrwRes_ + _aIrwC_[iIrw]
			ok
		next
		return _aIrwRes_

	# TRUE if every given position holds an item that meets the W condition.
	#
	#   returns    TRUE or FALSE
	#   see        CheckItemsAtW
	#@ aka  -- True if EVERY given position holds an item matching a W condition.
	def ContainsItemsAtW(panPos, pcCondition)
		_anCiwMatch_ = This.FindAllItemsW(pcCondition)
		_nCiwP_ = ring_len(panPos)
		for iCiw = 1 to _nCiwP_
			_bCiwIn_ = 0
			_nCiwM_ = ring_len(_anCiwMatch_)
			for jCiw = 1 to _nCiwM_
				if _anCiwMatch_[jCiw] = panPos[iCiw]
					_bCiwIn_ = 1
					exit
				ok
			next
			if _bCiwIn_ = 0
				return 0
			ok
		next
		return 1

		def ContainsAtW(panPos, pcCondition)
			return This.ContainsItemsAtW(panPos, pcCondition)

	#-- EachContains: every item (string or sub-list) contains pItem.

	def EachContainsCS(pItem, pCaseSensitive)
		_bResult_ = 1
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		for _i_ = 1 to _nLen_
			if NOT ( isList(_aContent_[_i_]) or isString(_aContent_[_i_]) )
				_bResult_ = 0
				exit
			else
				_oEcItm_ = Q(_aContent_[_i_])
				_bResult_ = _oEcItm_.ContainsCS(pItem, pCaseSensitive)
				if _bResult_ = 0
					exit
				ok
			ok
		next
		return _bResult_

		# TRUE if every item contains the given item.
		#
		#   returns    TRUE or FALSE
		#   see        Contains
		def EachContains(pItem)
			return This.EachContainsCS(pItem, 1)

		def EachItemContainsCS(pItem, pCaseSensitive)
			return This.EachContainsCS(pItem, pCaseSensitive)

		# TRUE if every item contains the given item.
		#
		#   returns    TRUE or FALSE
		#   see        EachContains
		def EachItemContains(pItem)
			return This.EachContainsCS(pItem, 1)

	#-- EachContainsThese: every item contains all the given items.

	def EachContainsTheseCS(paItems, pCaseSensitive)
		_bResult_ = 1
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		for _i_ = 1 to _nLen_
			if NOT ( isList(_aContent_[_i_]) or isString(_aContent_[_i_]) )
				_bResult_ = 0
				exit
			else
				_oEctItm_ = Q(_aContent_[_i_])
				_bResult_ = _oEctItm_.ContainsTheseCS(paItems, pCaseSensitive)
				if _bResult_ = 0
					exit
				ok
			ok
		next
		return _bResult_

		# TRUE if every item contains all the given items.
		#
		#   returns    TRUE or FALSE
		#   see        EachContains
		def EachContainsThese(paItems)
			return This.EachContainsTheseCS(paItems, 1)

	#-- Intersection (method form): items shared with another list.
	#-- Routes to the existing CommonItems(:With = ...).

	def Intersection(pNamedWith)
		return This.CommonItems(pNamedWith)

	# Returns the items that both lists hold.
	#
	#   returns    a list of items
	#   see        IntersectWith, DiffWith
	#@ aka  The items shared with the given list.
	def CommonItemsWith(paOtherList)
		return This.CommonItems([ :With, paOtherList ])

		# Returns the items present in both lists.
		#
		#   returns    a list of items
		#   see        IntersectWith, CommonItemsWith
		#@ aka  The items shared with the given list (pairwise intersection).
		def IntersectionWith(paOtherList)
			return This.CommonItems([ :With, paOtherList ])

		def Common(paOtherList)
			return This.CommonItemsWith(paOtherList)

	#-- Symmetric difference: (this items not in other) ++ (other items not
	#-- in this). Engine-faithful element compare via BothAreEqualCS.

	def DifferentItemsWithCS(paOtherList, pCaseSensitive)
		# Symmetric difference, engine-backed and consistent with the rest
		# of Softanza: it is (this \ other) ++ (other \ this), each side the
		# engine's asymmetric difference (same primitive stzListComparator's
		# SymmetricDifference uses). Order = this-side items first, then
		# other-side items -- the documented Softanza order (test 632).
		_pDiwA_ = This._EngineListFromContent()
		_pDiwB_ = StzEngineMarshalList(paOtherList)
		if _pDiwA_ != "" and _pDiwB_ != ""
			_pDiwD1_ = StzEngineListDifferenceCS(_pDiwA_, _pDiwB_, pCaseSensitive)
			_pDiwD2_ = StzEngineListDifferenceCS(_pDiwB_, _pDiwA_, pCaseSensitive)
			_aDiwR_ = StzEngineListContentToRingList(_pDiwD1_)
			_aDiwT_ = StzEngineListContentToRingList(_pDiwD2_)
			_nDiwT_ = ring_len(_aDiwT_)
			for _iDiw_ = 1 to _nDiwT_
				_aDiwR_ + _aDiwT_[_iDiw_]
			next
			StzEngineListFree(_pDiwD1_)
			StzEngineListFree(_pDiwD2_)
			StzEngineListFree(_pDiwA_)
			StzEngineListFree(_pDiwB_)
			return _aDiwR_
		ok
		# Fallback (non-marshalable content): same symmetric semantics.
		_aDiwR_ = []
		_aDiwThis_ = This.Content()
		_nDiw1_ = ring_len(_aDiwThis_)
		_nDiwO_ = ring_len(paOtherList)
		for iDiw = 1 to _nDiw1_
			_bDiwIn_ = 0
			for jDiw = 1 to _nDiwO_
				if BothAreEqualCS(_aDiwThis_[iDiw], paOtherList[jDiw], pCaseSensitive)
					_bDiwIn_ = 1
					exit
				ok
			next
			if _bDiwIn_ = 0
				_aDiwR_ + _aDiwThis_[iDiw]
			ok
		next
		for jDiw = 1 to _nDiwO_
			_bDiwIn_ = 0
			for iDiw = 1 to _nDiw1_
				if BothAreEqualCS(paOtherList[jDiw], _aDiwThis_[iDiw], pCaseSensitive)
					_bDiwIn_ = 1
					exit
				ok
			next
			if _bDiwIn_ = 0
				_aDiwR_ + paOtherList[jDiw]
			ok
		next
		return _aDiwR_

	# Returns the items found in only one of the two lists.
	#
	#   returns    a list of items
	#   see        DiffWith, CommonItemsWith
	def DifferentItemsWith(paOtherList)
		return This.DifferentItemsWithCS(paOtherList, 1)

		def Diff(paOtherList)
			return This.DifferentItemsWith(paOtherList)

	#-- Same items as another list, regardless of order/count (set equality).

	def ContainsSameItemsAsCS(paOtherList, pCaseSensitive)
		if NOT This.EachItemExistsInCS(paOtherList, pCaseSensitive)
			return 0
		ok
		_oCsiOther_ = new stzList(paOtherList)
		return _oCsiOther_.EachItemExistsInCS(This.Content(), pCaseSensitive)

	# TRUE if both lists hold the same items.
	#
	#   returns    TRUE or FALSE
	#   see        HasSameContentAs
	def ContainsSameItemsAs(paOtherList)
		return This.ContainsSameItemsAsCS(paOtherList, 1)

	#-- IsContainedIn(p): this list, taken as a single value, is an
	#-- element of p (NOT element-wise -- that is AreContainedIn).

	def IsContainedInCS(p, pCaseSensitive)
		if NOT ( isString(p) or isList(p) )
			return 0
		ok
		_oCip_ = Q(p)
		_anPos_ = _oCip_.FindAllCS(This.Content(), pCaseSensitive)
		if ring_len(_anPos_) > 0
			return 1
		else
			return 0
		ok

		# TRUE if every item of the list occurs in the given list.
		#
		#   p          the list to look in
		#   returns    TRUE or FALSE
		#   see        AreContainedIn
		def IsContainedIn(p)
			return This.IsContainedInCS(p, 1)

		def ExistsInCS(p, pCaseSensitive)
			return This.IsContainedInCS(p, pCaseSensitive)

		# TRUE if every item of the list occurs in the given list.
		#
		#   p          the list to look in
		#   returns    TRUE or FALSE
		#   see        IsContainedIn
		def ExistsIn(p)
			return This.IsContainedInCS(p, 1)

		def IsIncludedInCS(p, pCaseSensitive)
			return This.IsContainedInCS(p, pCaseSensitive)

	#-- AreContainedIn / ExistIn: every item of this list also exists
	#-- somewhere in the other list (element-wise membership).

	def EachItemExistsInCS(paOtherList, pCaseSensitive)
		_bResult_ = 1
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		_nOther_ = ring_len(paOtherList)
		for _k = 1 to _nLen_
			_bFound_ = 0
			for _j = 1 to _nOther_
				if BothAreEqualCS(_aContent_[_k], paOtherList[_j], pCaseSensitive)
					_bFound_ = 1
					exit
				ok
			next
			if _bFound_ = 0
				_bResult_ = 0
				exit
			ok
		next
		return _bResult_

		# TRUE if every item of the list occurs in the other list.
		#
		#   returns    TRUE or FALSE
		#   see        IsContainedIn
		def EachItemExistsIn(paOtherList)
			return This.EachItemExistsInCS(paOtherList, 1)

		# TRUE if every item of the list occurs in the other list.
		#
		#   returns    TRUE or FALSE
		#   see        ExistsIn
		def ExistIn(paOtherList)
			return This.EachItemExistsInCS(paOtherList, 1)

		# TRUE if every item of the list occurs in the other list.
		#
		#   returns    TRUE or FALSE
		#   see        IsContainedIn
		def AreContainedIn(paOtherList)
			return This.EachItemExistsInCS(paOtherList, 1)

	#-- HasSameNumberOfItemsAs: same length as another list.

	def HasSameNumberOfItemsAsCS(paOtherList, pCaseSensitive)
		if ring_len(paOtherList) = This.NumberOfItems()
			return 1
		else
			return 0
		ok

		# TRUE if both lists hold the same number of items.
		#
		#   returns    TRUE or FALSE
		#   see        HasMoreNumberOfItems
		def HasSameNumberOfItemsAs(paOtherList)
			return This.HasSameNumberOfItemsAsCS(paOtherList, 1)

		# TRUE if both lists hold the same number of items.
		#
		#   returns    TRUE or FALSE
		#   see        HasSameNumberOfItemsAs
		def HasSameSizeAs(paOtherList)
			return This.HasSameNumberOfItemsAsCS(paOtherList, 1)

		# TRUE if both lists hold the same number of items.
		#
		#   returns    TRUE or FALSE
		#   see        HasSameSizeAs
		def HasSameWidthAs(paOtherList)
			return This.HasSameNumberOfItemsAsCS(paOtherList, 1)

	# TRUE if none of the given items occurs in the list.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsOneOfThese
	#@ aka  -- Negative form of ContainsOneOfThese.
	def ContainsNoOneOfThese(paItems)
		return NOT This.ContainsOneOfThese(paItems)

		# TRUE if none of the given items occurs in the list.
		#
		#   returns    TRUE or FALSE
		#   see        ContainsSome
		def ContainsNoneOfThese(paItems)
			return NOT This.ContainsOneOfThese(paItems)

		# TRUE if none of the given items occurs in the list.
		#
		#   returns    TRUE or FALSE
		#   see        ContainsSome
		def ContainsNoItemOfThese(paItems)
			return NOT This.ContainsOneOfThese(paItems)

	#-- HowMany: number of items (alias of NumberOfItems).

	def HowManyItems()
		return This.NumberOfItems()

	#-- HowMany(item): how many times the item occurs in the list.

	def HowMany(pItem)
		return This.NumberOfOccurrence(pItem)

	# Returns the items that are objects.
	#
	#   returns    a list of the object items
	#   see        Strings, Lists, Numbers
	#@ aka  -- Objects: the items that are objects.
	def Objects()
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if isObject(_aContent_[_i_])
				_aResult_ + _aContent_[_i_]
			ok
		next
		return _aResult_

		def OnlyObjects()
			return This.Objects()

	# Returns the items that are numbers or strings, leaving out lists and objects.
	#
	#   returns    a list of items
	#   see        OnlyNumbers, OnlyStrings
	#@ aka  -- NumbersAndStrings: the scalar items (numbers or strings). -- The Z form pairs each with its 1-based position.
	def NumbersAndStrings()
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if isNumber(_aContent_[_i_]) or isString(_aContent_[_i_])
				_aResult_ + _aContent_[_i_]
			ok
		next
		return _aResult_

		def StringsAndNumbers()
			return This.NumbersAndStrings()

	def NumbersAndStringsZ()
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if isNumber(_aContent_[_i_]) or isString(_aContent_[_i_])
				_aResult_ + [ _aContent_[_i_], _i_ ]
			ok
		next
		return _aResult_

		def StringsAndNumbersZ()
			return This.NumbersAndStringsZ()

	# Returns a copy of the list with every text item in lowercase; the list is unchanged.
	#
	#   returns    a list; items that are not text pass through
	#   see        Uppercased
	#   example    o1 = new stzList([ "A", "b", 7 ])
	#              ? @@( o1.Lowercased() )
	#              #--> [ "a", "b", 7 ]
	#@ aka  -- A copy with every string item lower/upper-cased (UTF-8 via the -- engine-backed StzLower/StzUpper); non-string items pass through.
	def Lowercased()
		_aLcC_ = This.Content()
		_nLcL_ = ring_len(_aLcC_)
		_aLcR_ = []
		for iLc = 1 to _nLcL_
			if isString(_aLcC_[iLc])
				_aLcR_ + StzLower(_aLcC_[iLc])
			else
				_aLcR_ + _aLcC_[iLc]
			ok
		next
		return _aLcR_

		def StringsLowercased()
			return This.Lowercased()

	# Returns a copy of the list with every text item in uppercase; the list is unchanged.
	#
	#   returns    a list; items that are not text pass through
	#   see        Lowercased, UppercaseQ
	#   example    ? @@( o1.Uppercased() )
	#              #--> [ "A", "B", "C", "B" ]
	#@ aka  A copy with every string item uppercased; the original is unchanged.
	def Uppercased()
		_aUcC_ = This.Content()
		_nUcL_ = ring_len(_aUcC_)
		_aUcR_ = []
		for iUc = 1 to _nUcL_
			if isString(_aUcC_[iUc])
				_aUcR_ + StzUpper(_aUcC_[iUc])
			else
				_aUcR_ + _aUcC_[iUc]
			ok
		next
		return _aUcR_

		def StringsUppercased()
			return This.Uppercased()

	#-- VizFind: a visual map of where a char occurs -- the list rendered
	#-- as code, with a "^"/"-" marker line underneath. (Chars only, as the
	#-- markers align to single columns; generalising is a TODO.)

	def VizFindAllOccurrencesCS(pItem, pCaseSensitive)
		return This.VizFindCS(pItem, pCaseSensitive)

	# Returns the list written as text for display, with every occurrence of the item marked.
	#
	#   returns    a string
	#   see        VizFindAll
	def VizFindAllOccurrences(pItem)
		return This.VizFindAllOccurrencesCS(pItem, 1)

		# Returns a picture of where the item occurs: the list as code, with a ^ under each occurrence.
		#
		#   pItem      the item to look for
		#   returns    a string of two lines
		#   see        Find
		#   example    ? o1.VizFind("b")
		#              #--> [ "a", "b", "c", "b" ]
		#              #-->  -------^---------^---
		def VizFind(pItem)
			return This.VizFindCS(pItem, 1)

		# A visual map of where the item occurs: the list rendered as
		# code with ^ marks.
		def VizFindCS(pItem, pCaseSensitive)
			# Base form: code + a single unlabelled marker row, wrapped.
			# Shallow: only top-level occurrences are marked (see VizDeepFind).
			_cCode_ = This._VizCodeStr()
			_cMark_ = This._VizMarkerLine(pItem, [], _cCode_, pCaseSensitive, 0)
			return This._VizWrap(_cCode_, [ [ "", _cMark_, "" ] ], This._VizWidth())

		# Returns the list written as text.
		#
		#   returns    a string
		#   see        ToListInAString
		def VizFindAll(pItem)
			return This.VizFindCS(pItem, 1)

	#-- _VizCodeStr / _VizMarkerLine: shared helpers for the Viz family.
	#-- The marker line aligns to the COLUMNS of the rendered code string:
	#-- "^" under each occurrence of pItem, "." under each occurrence of any
	#-- item in paOthers, "-" everywhere else. Works for ANY string value,
	#-- not only single chars (long values just span more columns).
	def _VizCodeStr()
		_oVfc_ = new stzString(This.ToCode())
		return _oVfc_.Simplified()

	#-- Default wrap width: long renderings are split into lines this wide,
	#-- each with its marker row(s) underneath.
	def _VizWidth()
		return DefaultVizWidth()

	def _VizMarkerLine(pItem, paOthers, pcCode, pCaseSensitive, bDeep)
		# Depth filter: a SHALLOW viz (bDeep=0) marks only TOP-LEVEL occurrences
		# (bracket depth 1); a DEEP viz (bDeep=1) marks occurrences at any depth.
		_oVfm_ = new stzString(pcCode)
		_aVfmDepth_ = This._VizDepthMap(pcCode)
		_nVfmLen_ = StzLen(pcCode)

		# One marker cell per code column. The opening "[" (col 1) keeps a blank
		# under it; the rest default to "-". OTHERS are painted first so MINE
		# overrides on overlap.
		_aVfmCell_ = [ " " ]
		for _iVfmC_ = 2 to _nVfmLen_
			_aVfmCell_ + "-"
		next

		_nVfmO_ = len(paOthers)
		for _iVfmO_ = 1 to _nVfmO_
			This._VizPaint(_aVfmCell_, _oVfm_, paOthers[_iVfmO_], pCaseSensitive, _aVfmDepth_, bDeep, ".")
		next
		This._VizPaint(_aVfmCell_, _oVfm_, pItem, pCaseSensitive, _aVfmDepth_, bDeep, "^")

		_cVfmRes_ = ""
		for _iVfmJ_ = 1 to _nVfmLen_
			_cVfmRes_ += _aVfmCell_[_iVfmJ_]
		next
		return _cVfmRes_

	#-- _VizPaint: paint one searched value's matches into the marker cells.
	#-- A SCALAR value gets a single mark at the value's content (start + 1); a
	#-- LIST value -- being wider -- is UNDERLINED across its whole footprint
	#-- (start .. start + width - 1). The depth of each match's START decides
	#-- shallow (depth 1) vs deep visibility.
	def _VizPaint(paCell, poStr, pValue, pCaseSensitive, paDepth, bDeep, pcSym)
		_cVpVal_ = @@(pValue)
		_anVpPos_ = poStr.FindAllCS(_cVpVal_, pCaseSensitive)
		_nVpValLen_ = StzLen(_cVpVal_)
		_bVpSpan_ = isList(pValue)
		_nVpCells_ = len(paCell)
		_nVpN_ = len(_anVpPos_)
		for _iVp_ = 1 to _nVpN_
			_pVp_ = _anVpPos_[_iVp_]
			if bDeep = 1 or paDepth[_pVp_] = 1
				if _bVpSpan_
					for _kVp_ = _pVp_ to _pVp_ + _nVpValLen_ - 1
						if _kVp_ >= 1 and _kVp_ <= _nVpCells_
							paCell[_kVp_] = pcSym
						ok
					next
				else
					_kVp_ = _pVp_ + 1
					if _kVp_ >= 1 and _kVp_ <= _nVpCells_
						paCell[_kVp_] = pcSym
					ok
				ok
			ok
		next

	#-- _VizDepthMap: structural bracket-nesting depth at each codepoint of the
	#-- rendered code -- brackets inside "..." string values are ignored. Depth 1
	#-- = a top-level item; depth >= 2 = nested inside a sub-list. Lets the Viz
	#-- markers tell shallow occurrences from deep ones.
	def _VizDepthMap(pcCode)
		_oDmStr_ = new stzString(pcCode)
		_aDmChars_ = _oDmStr_.Chars()
		_nDmLen_ = len(_aDmChars_)
		_aDmDepth_ = []
		_nDmD_ = 0
		_bDmInStr_ = 0
		for _iDm_ = 1 to _nDmLen_
			_aDmDepth_ + _nDmD_
			_cDmCh_ = _aDmChars_[_iDm_]
			if _cDmCh_ = '"'
				_bDmInStr_ = 1 - _bDmInStr_
			but _bDmInStr_ = 0
				if _cDmCh_ = "["
					_nDmD_++
				but _cDmCh_ = "]"
					_nDmD_--
				ok
			ok
		next
		return _aDmDepth_

	#-- _VizWrap: render <code> with one or more marker rows beneath it,
	#-- WRAPPING to nWidth columns. Each row is [ cLabel, cMarker, cSuffix ];
	#-- the marker is column-aligned to the code (padded to its length) and
	#-- the suffix (e.g. a "(count)") is appended only after the LAST window.
	#-- An empty line separates wrapped blocks (none after the last block).
	def _VizWrap(pcCode, paRows, nWidth)
		_nLen_ = StzLen(pcCode)
		_oVwCode_ = new stzString(pcCode)

		# pad each marker to the code length so windows line up, and track the
		# widest row LABEL: the marker lines carry that label as a prefix, so the
		# code line must be indented by the same width or the "^" carets drift
		# right of the items they point at.
		_aPad_ = []
		_nVwR_ = len(paRows)
		_nLblW_ = 0
		for _rVw_ = 1 to _nVwR_
			_cM_ = paRows[_rVw_][2]
			_nM_ = StzLen(_cM_)
			for _pVw_ = _nM_ + 1 to _nLen_
				_cM_ += "-"
			next
			_aPad_ + [ paRows[_rVw_][1], _cM_, paRows[_rVw_][3] ]
			_nLW_ = StzLen(paRows[_rVw_][1])
			if _nLW_ > _nLblW_ _nLblW_ = _nLW_ ok
		next

		# right-justify every label to the common width (so the markers -- and the
		# " : " separators -- all start at the same column), and build the matching
		# indent for the code line above them.
		_cVwIndent_ = ""
		for _iVwI_ = 1 to _nLblW_ _cVwIndent_ += " " next
		for _rVwL_ = 1 to _nVwR_
			_cL_ = _aPad_[_rVwL_][1]
			_cLpad_ = ""
			for _pLp_ = StzLen(_cL_) + 1 to _nLblW_
				_cLpad_ += " "
			next
			_aPad_[_rVwL_][1] = _cLpad_ + _cL_
		next

		_cRes_ = ""
		_nStart_ = 1
		_bFirst_ = 1
		while _nStart_ <= _nLen_
			_nEnd_ = _nStart_ + nWidth - 1
			if _nEnd_ > _nLen_ _nEnd_ = _nLen_ ok
			_bLastWin_ = ( _nEnd_ = _nLen_ )

			if NOT _bFirst_ _cRes_ += (char(10) + char(10)) ok
			_bFirst_ = 0

			_cRes_ += _cVwIndent_ + _oVwCode_.Section(_nStart_, _nEnd_)
			for _rVw2_ = 1 to _nVwR_
				_oVwM_ = new stzString(_aPad_[_rVw2_][2])
				_cSeg_ = _oVwM_.Section(_nStart_, _nEnd_)
				_cRes_ += char(10) + _aPad_[_rVw2_][1] + _cSeg_
				if _bLastWin_
					_cRes_ += _aPad_[_rVw2_][3]
				ok
			next
			_nStart_ = _nEnd_ + 1
		end
		return _cRes_

	#-- VizFindXT: like VizFind, plus a "<item> :" label and a "(count)" tally.
	def VizFindXT(pItem)
		return This.VizFindXTCS(pItem, 1)

	def VizFindXTCS(pItem, pCaseSensitive)
		_cCode_ = This._VizCodeStr()
		_cMark_ = This._VizMarkerLine(pItem, [], _cCode_, pCaseSensitive, 0)
		# (count) = the SHALLOW count -- exactly what Find returns (top-level
		# items), so it matches the number of "^" carets drawn.
		_nCount_ = len( This.FindAllCS(pItem, pCaseSensitive) )
		_aRow_ = [ [ @@(pItem) + " : ", _cMark_, " (" + _nCount_ + ")" ] ]
		return This._VizWrap(_cCode_, _aRow_, This._VizWidth())

	#-- VizDeepFind* : like VizFind*, but the markers ALSO cover occurrences
	#-- nested inside sub-lists (any bracket depth), not just top-level ones.
	#-- The "(count)" is the total occurrences, same as the deep markers.
	def VizDeepFindCS(pItem, pCaseSensitive)
		_cCode_ = This._VizCodeStr()
		_cMark_ = This._VizMarkerLine(pItem, [], _cCode_, pCaseSensitive, 1)
		return This._VizWrap(_cCode_, [ [ "", _cMark_, "" ] ], This._VizWidth())

	# Returns the list written as text for display, with the occurrences of the item marked at any depth.
	#
	#   returns    a string
	#   see        VizFindAll
	def VizDeepFind(pItem)
		return This.VizDeepFindCS(pItem, 1)

		# Returns the list written as text for display, with every occurrence of the item marked at any depth.
		#
		#   returns    a string
		#   see        VizFindAll
		def VizDeepFindAll(pItem)
			return This.VizDeepFindCS(pItem, 1)

	def VizDeepFindXTCS(pItem, pCaseSensitive)
		_cCode_ = This._VizCodeStr()
		_cMark_ = This._VizMarkerLine(pItem, [], _cCode_, pCaseSensitive, 1)
		_oVdxCnt_ = new stzString(_cCode_)
		_nCount_ = len( _oVdxCnt_.FindAllCS(@@(pItem), pCaseSensitive) )
		_aRow_ = [ [ @@(pItem) + " : ", _cMark_, " (" + _nCount_ + ")" ] ]
		return This._VizWrap(_cCode_, _aRow_, This._VizWidth())

	def VizDeepFindXT(pItem)
		return This.VizDeepFindXTCS(pItem, 1)

	#-- VizFindMany: one labelled marker row per searched item. Each row marks
	#-- "^" for its own item and "." for the other searched items.
	def VizFindMany(paItems)
		return This.VizFindManyCS(paItems, 1)

	def VizFindManyCS(paItems, pCaseSensitive)
		if NOT isList(paItems)
			StzRaise("Can't proceed! paItems must be a list.")
		ok
		_cCode_ = This._VizCodeStr()
		_aRows_ = []
		_nN_ = len(paItems)
		for iM = 1 to _nN_
			_aOthers_ = []
			for jM = 1 to _nN_
				if jM != iM _aOthers_ + paItems[jM] ok
			next
			_cMark_ = This._VizMarkerLine(paItems[iM], _aOthers_, _cCode_, pCaseSensitive, 0)
			_aRows_ + [ @@(paItems[iM]) + " : ", _cMark_, "" ]
		next
		return This._VizWrap(_cCode_, _aRows_, This._VizWidth())

	#-- VizFindManyXT: VizFindMany plus a "(count)" tally on each row.
	def VizFindManyXT(paItems)
		return This.VizFindManyXTCS(paItems, 1)

	def VizFindManyXTCS(paItems, pCaseSensitive)
		if NOT isList(paItems)
			StzRaise("Can't proceed! paItems must be a list.")
		ok
		_cCode_ = This._VizCodeStr()
		_aRows_ = []
		_nN_ = len(paItems)
		for iMx = 1 to _nN_
			_aOthers_ = []
			for jMx = 1 to _nN_
				if jMx != iMx _aOthers_ + paItems[jMx] ok
			next
			_cMark_ = This._VizMarkerLine(paItems[iMx], _aOthers_, _cCode_, pCaseSensitive, 0)
			# shallow count = what Find returns (top-level items), matching the carets
			_nCount_ = len( This.FindAllCS(paItems[iMx], pCaseSensitive) )
			_aRows_ + [ @@(paItems[iMx]) + " : ", _cMark_, " (" + _nCount_ + ")" ]
		next
		return This._VizWrap(_cCode_, _aRows_, This._VizWidth())

	# Returns the items that are numbers.
	#
	#   returns    a list of numbers
	#   see        Chars
	#   example    o1 = new stzList([ "a", 1, "b", 2 ])
	#              ? @@( o1.Numbers() )
	#              #--> [ 1, 2 ]
	#@ aka  -- Type-filter family: Xs() = items of type X, XsZ() = [item,pos] -- pairs, NumberOfXs() = count. Char = single-codepoint string -- (StzLen=1); Letter = a single ASCII letter.
	def Numbers()
		_aTfC_ = This.Content()
		_nTfL_ = ring_len(_aTfC_)
		_aTfR_ = []
		for iTf = 1 to _nTfL_
			if isNumber(_aTfC_[iTf])
				_aTfR_ + _aTfC_[iTf]
			ok
		next
		return _aTfR_

		def NumbersZ()
			_aTfC_ = This.Content()
			_nTfL_ = ring_len(_aTfC_)
			_aTfR_ = []
			for iTf = 1 to _nTfL_
				if isNumber(_aTfC_[iTf])
					_aTfR_ + [ _aTfC_[iTf], iTf ]
				ok
			next
			return _aTfR_

		# Returns how many items are numbers.
		#
		#   returns    a number
		#   see        NumberOfStrings
		#@ aka  How many NUMBER items the list holds.
		def NumberOfNumbers()
			return ring_len(This.Numbers())

	# Returns the items that are strings.
	#
	#   returns    a list of strings
	#   see        Objects, Lists, OnlyStrings
	#@ aka  Only the STRING items of the list.
	def Strings()
		_aTfC_ = This.Content()
		_nTfL_ = ring_len(_aTfC_)
		_aTfR_ = []
		for iTf = 1 to _nTfL_
			if isString(_aTfC_[iTf])
				_aTfR_ + _aTfC_[iTf]
			ok
		next
		return _aTfR_

		def StringsZ()
			_aTfC_ = This.Content()
			_nTfL_ = ring_len(_aTfC_)
			_aTfR_ = []
			for iTf = 1 to _nTfL_
				if isString(_aTfC_[iTf])
					_aTfR_ + [ _aTfC_[iTf], iTf ]
				ok
			next
			return _aTfR_

		# Returns how many items are strings.
		#
		#   returns    a number
		#   see        NumberOfLists, Strings
		#@ aka  How many STRING items the list holds.
		def NumberOfStrings()
			return ring_len(This.Strings())

	# Returns the items that are a single character.
	#
	#   returns    a list of those items
	#   see        NumberOfChars
	#   example    o1 = new stzList([ "a", "bb", "c" ])
	#              ? @@( o1.Chars() )
	#              #--> [ "a", "c" ]
	#@ aka  Only the CHAR items of the list.
	def Chars()
		_aTfC_ = This.Content()
		_nTfL_ = ring_len(_aTfC_)
		_aTfR_ = []
		for iTf = 1 to _nTfL_
			if isString(_aTfC_[iTf]) and StzLen(_aTfC_[iTf]) = 1
				_aTfR_ + _aTfC_[iTf]
			ok
		next
		return _aTfR_

		def CharsZ()
			_aTfC_ = This.Content()
			_nTfL_ = ring_len(_aTfC_)
			_aTfR_ = []
			for iTf = 1 to _nTfL_
				if isString(_aTfC_[iTf]) and StzLen(_aTfC_[iTf]) = 1
					_aTfR_ + [ _aTfC_[iTf], iTf ]
				ok
			next
			return _aTfR_

	# Returns the items that are a single ASCII letter.
	#
	#   returns    a list of letters
	#   see        Numbers, Strings
	#@ aka  Only the LETTER items of the list.
	def Letters()
		_aTfC_ = This.Content()
		_nTfL_ = ring_len(_aTfC_)
		_aTfR_ = []
		for iTf = 1 to _nTfL_
			_xTf = _aTfC_[iTf]
			if isString(_xTf) and ring_len(_xTf) = 1
				_nTfA = ascii(_xTf)
				if (_nTfA >= 97 and _nTfA <= 122) or (_nTfA >= 65 and _nTfA <= 90)
					_aTfR_ + _xTf
				ok
			ok
		next
		return _aTfR_

		def LettersZ()
			_aTfC_ = This.Content()
			_nTfL_ = ring_len(_aTfC_)
			_aTfR_ = []
			for iTf = 1 to _nTfL_
				_xTf = _aTfC_[iTf]
				if isString(_xTf) and ring_len(_xTf) = 1
					_nTfA = ascii(_xTf)
					if (_nTfA >= 97 and _nTfA <= 122) or (_nTfA >= 65 and _nTfA <= 90)
						_aTfR_ + [ _xTf, iTf ]
					ok
				ok
			next
			return _aTfR_

		# Returns how many items are a single ASCII letter.
		#
		#   returns    a number
		#   see        Letters
		#@ aka  How many LETTER items the list holds.
		def NumberOfLetters()
			return ring_len(This.Letters())

	# Returns the items that are lists.
	#
	#   returns    a list of lists
	#   see        Strings, Objects
	#@ aka  Only the LIST items of the list.
	def Lists()
		_aTfC_ = This.Content()
		_nTfL_ = ring_len(_aTfC_)
		_aTfR_ = []
		for iTf = 1 to _nTfL_
			if isList(_aTfC_[iTf])
				_aTfR_ + _aTfC_[iTf]
			ok
		next
		return _aTfR_

		def ListsZ()
			_aTfC_ = This.Content()
			_nTfL_ = ring_len(_aTfC_)
			_aTfR_ = []
			for iTf = 1 to _nTfL_
				if isList(_aTfC_[iTf])
					_aTfR_ + [ _aTfC_[iTf], iTf ]
				ok
			next
			return _aTfR_

		# Returns how many items are lists.
		#
		#   returns    a number
		#   see        NumberOfStrings
		#@ aka  How many LIST items the list holds.
		def NumberOfLists()
			return ring_len(This.Lists())

	# Returns how many items are a [ key, value ] pair.
	#
	#   returns    a number; 0 for a list that holds no pair
	#   see        NumberOfItems
	#   example    o1 = new stzList([ [ "x", 1 ], [ "y", 2 ] ])
	#              ? o1.NumberOfPairs()
	#              #--> 2
	#              ? o1.NumberOfItems()
	#              #--> 2
	#@ aka  How many pairs the list holds.
	def NumberOfPairs()
		return ring_len(This.Pairs())

	# Extends the list up to position n, in place; a list already that long is left as it is.
	#
	#   _n_        the position to reach
	#   returns    nothing; the list changes
	#   see        ExtendToWith
	#@ aka  -- Extend the list up to position n. ExtendToPosition pads with 0 -- (number lists) or "" ; the WithItemsIn/Repeated forms pad by -- cycling through a given list (or the list's own items).
	def ExtendToPosition(_n_)
		_nLen_ = This.NumberOfItems()
		_aContent_ = This.Content()
		if _n_ > _nLen_
			_value_ = ""
			if This.IsListOfNumbers()
				_value_ = 0
			ok
			_nExtend_ = _n_ - _nLen_
			for _i_ = 1 to _nExtend_
				_aContent_ + _value_
			next
		ok
		This.UpdateWith(_aContent_)

	# Extends the list up to position n by adding the given items in turn, in place.
	#
	#   _n_        the position to reach
	#   paItems    the items used to fill, in turn
	#   returns    nothing; the list changes
	#   see        ExtendToWithItemsIn
	#@ aka  Extend the list to position n by cycling the given items (mutating).
	def ExtendToPositionWithItemsIn(_n_, paItems)
		_nLen_ = ring_len(paItems)
		# fill (target - CURRENT length) slots; cycle the pool (length nLen)
		_nTemp_ = _n_ - This.NumberOfItems()
		_aTemp_ = []
		if _nTemp_ > 0
			_j_ = 0
			for _i_ = 1 to _nTemp_
				_j_++
				if _j_ > _nLen_
					_j_ = 1
				ok
				_aTemp_ + paItems[_j_]
			next
		ok
		This.ExtendWith(_aTemp_)

		# Extends the list up to position n by adding the given items in turn, in place.
		#
		#   _n_        the position to reach
		#   paItems    the items used to fill, in turn
		#   returns    nothing; the list changes
		#   see        ExtendToWith
		def ExtendToWithItemsIn(_n_, paItems)
			This.ExtendToPositionWithItemsIn(_n_, paItems)

	# Extends the list up to position n by repeating its own items, in place.
	#
	#   _n_        the position to reach
	#   returns    nothing; the list changes
	#   see        ExtendToWithItemsRepeated
	#@ aka  Extend to position n by cycling the list's own items (mutating).
	def ExtendToPositionWithItemsRepeated(_n_)
		This.ExtendToPositionWithItemsIn(_n_, This.List())

		# Extends the list up to position n by repeating its own items, in place.
		#
		#   _n_        the position to reach
		#   returns    nothing; the list changes
		#   see        ExtendToWith
		def ExtendToWithItemsRepeated(_n_)
			This.ExtendToPositionWithItemsRepeated(_n_)

		# Extends the list up to position n by repeating its own items, in place.
		#
		#   _n_        the position to reach
		#   returns    nothing; the list changes
		#   see        ExtendToWithItemsRepeated
		def ExtendToByRepeatingItems(_n_)
			This.ExtendToPositionWithItemsRepeated(_n_)

	# TRUE if the list has more items than the other list.
	#
	#   returns    TRUE or FALSE
	#   see        HasLessNumberOfItems
	#@ aka  -- Size comparison with another list. Accept the named form -- IsLarger(:Than = otherList) or the raw list.
	def HasMoreNumberOfItems(paOtherList)
		if isList(paOtherList) and ring_len(paOtherList) = 2 and isString(paOtherList[1]) and
		   (paOtherList[1] = :Than or paOtherList[1] = :than)
			paOtherList = paOtherList[2]
		ok
		if This.NumberOfItems() > ring_len(paOtherList)
			return 1
		else
			return 0
		ok

		def IsLarger(paOtherList)
			return This.HasMoreNumberOfItems(paOtherList)

		def IsLargerThan(paOtherList)
			return This.HasMoreNumberOfItems(paOtherList)

		def HasMoreItems(paOtherList)
			return This.HasMoreNumberOfItems(paOtherList)

	# TRUE if the list has fewer items than the other list.
	#
	#   returns    TRUE or FALSE
	#   see        HasMoreNumberOfItems
	#@ aka  TRUE if this list has fewer items than the given one.
	def HasLessNumberOfItems(paOtherList)
		if isList(paOtherList) and ring_len(paOtherList) = 2 and isString(paOtherList[1]) and
		   (paOtherList[1] = :Than or paOtherList[1] = :than)
			paOtherList = paOtherList[2]
		ok
		if This.NumberOfItems() < ring_len(paOtherList)
			return 1
		else
			return 0
		ok

		def IsSmaller(paOtherList)
			return This.HasLessNumberOfItems(paOtherList)

		def IsSmallerThan(paOtherList)
			return This.HasLessNumberOfItems(paOtherList)

		def HasLessItems(paOtherList)
			return This.HasLessNumberOfItems(paOtherList)

		def HasFewerItems(paOtherList)
			return This.HasLessNumberOfItems(paOtherList)

	# TRUE if every item is an empty list.
	#
	#   returns    TRUE or FALSE
	#   see        ItemsAreEmptyLists
	#@ aka  -- IsListOfEmptyLists: every item is an empty list.
	def IsListOfEmptyLists()
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		_bResult_ = 1
		for _i_ = 1 to _nLen_
			if NOT isList(_aContent_[_i_])
				_bResult_ = 0
				exit
			ok
			if NOT ring_len(_aContent_[_i_]) = 0
				_bResult_ = 0
				exit
			ok
		next
		return _bResult_

		def AllItemsAreEmptyLists()
			return This.IsListOfEmptyLists()

		def ContainsOnlyEmptyLists()
			return This.IsListOfEmptyLists()

	#-- First-occurrence positions of the items that are duplicated
	#-- ("duplicate origins"). Built engine-first: the duplicated VALUES
	#-- come from the engine-backed DuplicatedItemsCS, and each value's
	#-- first position from the engine-backed FindFirstCS -- avoiding the
	#-- monolith's O(n^2) StzFind loop (whose arg order is ambiguous now).

	def FindFirstDuplicatesCS(pCaseSensitive)
		_aDups_ = This.DuplicatedItemsCS(pCaseSensitive)
		_aRes_ = []
		_nLen_ = ring_len(_aDups_)
		for _i_ = 1 to _nLen_
			_aRes_ + This.FindFirstCS(_aDups_[_i_], pCaseSensitive)
		next
		return ring_sort(_aRes_)

		# Returns the position of the first occurrence of each duplicated item.
		#
		#   returns    a list of positions
		#   see        FindDupOrigins
		def FindFirstDuplicates()
			return This.FindFirstDuplicatesCS(1)

		# Returns the position of the first occurrence of each duplicated item.
		#
		#   returns    a list of positions
		#   see        FindDupOrigins
		def FindFirstDuplicatedItems()
			return This.FindFirstDuplicatesCS(1)

		# Returns the position of the first occurrence of each duplicated item.
		#
		#   returns    a list of positions
		#   see        FindDupOrigins
		def FindFirstOccurrenceOfEachDuplicatedItem()
			return This.FindFirstDuplicatesCS(1)

		# Returns the positions of the first occurrence of each item that is duplicated.
		#
		#   returns    a list of positions
		#   see        RemoveDupOrigins
		def FindDupOrigins()
			return This.FindFirstDuplicatesCS(1)

	# Removes the first occurrence of each duplicated item, in place.
	#
	#   returns    nothing; the list changes
	#   see        FindDupOrigins
	#@ aka  -- Remove the first occurrence of each duplicated item (mutating).
	def RemoveDupOrigins()
		This.RemoveItemsAtPositions( This.FindFirstDuplicates() )

		# Removes the first occurrence of each duplicated item, in place.
		#
		#   returns    nothing; the list changes
		#   see        RemoveDupOrigins
		def RemoveDuplicatesOrigins()
			This.RemoveDupOrigins()

	  #=====================================#
	 #   OPERATOR OVERLOADING              #
	#=====================================#
	# Applies a Ring operator to the list and a value; + appends the value.
	#
	#   pOp        the operator, as text
	#   pValue     the right-hand value
	#   returns    the result of the operator
	#@ aka  stzList supports the natural Ring operator-overload set so narrative tests can write things like
	def operator(pOp, pValue)

		# Softanza operator rules (NON-mutating -- the object is never
		# changed; every branch returns a fresh value):
		#   RHS raw            -> raw result
		#   RHS Q(...) object  -> chainable stz object
		#   These()/TheseQ()   -> operand list applied item-by-item
		#   Obj()/ObjQ()/O()   -> operand stz object added/removed AS the
		#                         object itself (not unwrapped)
		# The Q/These/Obj forms are flagged by globals set in stzFuncs.

		if pOp = "+"

			if isList(pValue)
				if _bTheseQ
					_bTheseQ = 0
					return new stzList( This.ManyAdded(pValue) )
				but _bThese
					_bThese = 0
					return This.ManyAdded(pValue)
				else
					return This.ItemAdded(pValue)
				ok

			but @IsStzObject(pValue)
				if _bAsObject
					_bAsObject = 0
					return This.ItemAdded(pValue)
				but _bAsObjectQ
					_bAsObjectQ = 0
					return new stzList( This.ItemAdded(pValue) )
				but _bTheseQ
					_bTheseQ = 0
					return new stzList( This.ManyAdded(pValue.Content()) )
				but _bThese
					_bThese = 0
					return This.ManyAdded(pValue.Content())
				else
					_vOpVal_ = pValue.Content()
					if @IsStzNumber(pValue)
						_vOpVal_ = pValue.NumericValue()
					ok
					return new stzList( This.ItemAdded(_vOpVal_) )
				ok

			else
				return This.ItemAdded(pValue)
			ok

		but pOp = "-"

			if isList(pValue)
				if _bTheseQ
					_bTheseQ = 0
					return new stzList( This.ManyRemoved(pValue) )
				but _bThese
					_bThese = 0
					return This.ManyRemoved(pValue)
				else
					return This.ItemRemoved(pValue)
				ok

			but @IsStzlist(pValue)
				if _bAsObject
					_bAsObject = 0
					return This.ItemRemoved(pValue)
				but _bAsObjectQ
					_bAsObjectQ = 0
					return new stzList( This.ItemRemoved(pValue) )
				but _bTheseQ
					_bTheseQ = 0
					return new stzList( This.ManyRemoved(pValue.Content()) )
				but _bThese
					_bThese = 0
					return This.ManyRemoved(pValue.Content())
				else
					return new stzList( This.ItemRemoved(pValue.Content()) )
				ok

			but @IsStzObject(pValue)
				if _bAsObject
					_bAsObject = 0
					return This.ItemRemoved(pValue)
				but _bAsObjectQ
					_bAsObjectQ = 0
					return new stzList( This.ItemRemoved(pValue) )
				ok
				_vOpVal_ = pValue.Content()
				if @IsStzNumber(pValue)
					_vOpVal_ = pValue.NumericValue()
				ok
				return new stzList( This.ItemRemoved(_vOpVal_) )

			else
				return This.ItemRemoved(pValue)
			ok

		but pOp = "*"
			# (*) dispatches on the RHS type. Q-elevation rule: a RAW rhs returns
			# a raw list; a Q()-wrapped / stz-object rhs returns a chainable
			# stzList with the SAME content. NON-mutating.
			#   number  -> repeat the list N times, FLAT  ([1,2]*3 -> [1,2,1,2,1,2])
			#   string  -> append the suffix to each item  (["a","b"]*"!" -> ["a!","b!"])
			#   list    -> pair each item with the whole rhs list (zip-broadcast)
			_bMulElevate_ = 0
			_vMulRhs_ = pValue
			if @IsStzObject(pValue)
				_bMulElevate_ = 1
				if @IsStzNumber(pValue)
					_vMulRhs_ = pValue.NumericValue()
				else
					_vMulRhs_ = pValue.Content()
				ok
			ok

			_aMulRes_ = []
			_nMulLen_ = len(@aContent)

			if isNumber(_vMulRhs_)
				_nMul_ = floor(_vMulRhs_)
				if _nMul_ < 0 _nMul_ = 0 ok
				for _iMul_ = 1 to _nMul_
					for _jMul_ = 1 to _nMulLen_
						_aMulRes_ + @aContent[_jMul_]
					next
				next

			but isString(_vMulRhs_)
				for _jMul_ = 1 to _nMulLen_
					if isString(@aContent[_jMul_])
						_aMulRes_ + (@aContent[_jMul_] + _vMulRhs_)
					else
						_aMulRes_ + @aContent[_jMul_]
					ok
				next

			but isList(_vMulRhs_)
				for _jMul_ = 1 to _nMulLen_
					_aMulRes_ + [ @aContent[_jMul_], _vMulRhs_ ]
				next

			else
				StzRaise("operator *: rhs must be a number, string, list, or Q(...) of these.")
			ok

			if _bMulElevate_
				return new stzList(_aMulRes_)
			ok
			return _aMulRes_

		but pOp = "/"
			# Divide the list into pValue parts of as-equal-as-possible size
			# (the documented "/ n -> n parts" contract: [1..6] / 3 ->
			# [[1,2],[3,4],[5,6]]). The remainder is front-loaded -- the first
			# (len mod n) parts get one extra item (numpy array_split
			# convention). This is SplitToNParts; chunk-by-SIZE lives in
			# SplitToPartsOfNItems. Q-elevation rule: a RAW number returns a
			# raw list of lists; a Q(number) / numeric stz-object returns a
			# chainable stzList object with the SAME content.
			_bDivElevate_ = 0
			if isNumber(pValue)
				_nParts_ = pValue
			but @IsStzObject(pValue)
				_vDiv_ = pValue.Content()
				if @IsStzNumber(pValue)
					_vDiv_ = pValue.NumericValue()
				ok
				if NOT isNumber(_vDiv_)
					StzRaise("operator /: rhs object must hold a number.")
				ok
				_nParts_ = _vDiv_
				_bDivElevate_ = 1
			else
				StzRaise("operator /: rhs must be a positive number or Q(number).")
			ok
			if _nParts_ < 1
				StzRaise("operator /: rhs must be a positive number.")
			ok
			_nParts_ = floor(_nParts_)
			_aGroups_ = []
			_nCntLen_ = len(@aContent)
			_nBase_ = floor(_nCntLen_ / _nParts_)
			_nRem_ = _nCntLen_ % _nParts_
			_iCur_ = 1
			for _iP_ = 1 to _nParts_
				_nSz_ = _nBase_
				if _iP_ <= _nRem_
					_nSz_ = _nSz_ + 1
				ok
				if _nSz_ = 0
					loop
				ok
				_aGroup_ = []
				_iEnd_ = _iCur_ + _nSz_ - 1
				for _jCh_ = _iCur_ to _iEnd_
					_aGroup_ + @aContent[_jCh_]
				next
				_aGroups_ + _aGroup_
				_iCur_ = _iEnd_ + 1
			next
			if _bDivElevate_
				return new stzList(_aGroups_)
			ok
			return _aGroups_

		but pOp = "[]"
			# Bracket indexing: a numeric key reads the item at that
			# position (Nth, 1-based, negatives count from the end);
			# any other key returns the positions where it occurs
			# (FindAll). Mirrors the stzString o1[n] / o1["x"] idiom.
			if isNumber(pValue)
				return This.Item(pValue)
			else
				return This.FindAll(pValue)
			ok

		ok

		# Value equality: Q(list) = otherlist routes to IsEqualTo (only when the
		# RHS is a list, so non-list comparisons keep their prior behavior).
		if pOp = "=" and isList(pValue)
			return This.IsEqualTo(pValue)
		ok
		if (pOp = "!=" or pOp = "<>") and isList(pValue)
			return NOT This.IsEqualTo(pValue)
		ok

		StzRaise("operator: unsupported operator '" + pOp + "' on stzList.")


	#========================================================#
	#  BATCH-1 RESTORE: duplicate / non-duplicate family,    #
	#  Index, ItemsOccurring, NListify, Halves (from the     #
	#  monolith -- split-dropped, authoritative semantics).  #
	#========================================================#

	def DuplicatesCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return []
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = [ _acStr_[1] ]
		_anPos_ = [ [] ]

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_anPos_ + [ _i_ ]
			else
				_anPos_[ _n_ ] + _i_
			ok
		next

		_aResult_ = []
		_nLen_ = len(_acSeen_)

		for _i_ = 1 to _nLen_
			if len(_anPos_[_i_]) > 1
				_aResult_ + _aContent_[_anPos_[_i_][1]]
			ok
		next

		return _aResult_

	def DuplicatesCSZ(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return []
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = [ _acStr_[1] ]
		_anPos_ = [ [] ]

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_anPos_ + [ _i_ ]
			else
				_anPos_[ _n_ ] + _i_
			ok
		next

		_aResult_ = []
		_nLen_ = len(_acSeen_)

		for _i_ = 1 to _nLen_
			del(_anPos_[_i_], 1)
			if len(_anPos_[_i_]) > 0
				_aResult_ + [ _aContent_[_anPos_[_i_][1]], _anPos_[_i_] ]
			ok
		next

		return _aResult_

	def DuplicatesCSXTZ(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return []
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = []
		_anSeen_ = []
		_anPos_ = []
		_aResult_ = []

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_anSeen_ + _i_
				_aResult_ + [ _aContent_[_i_], [_i_] ]
			else
				if StzFindFirst(_anPos_, _anSeen_[_n_]) = 0
					_anPos_ + _anSeen_[_n_]
				ok
				_anPos_ + _i_
				_aResult_[_n_][2] + _i_
			ok
		next

		return _aResult_

	def DuplicatesXTZ()
		return This.DuplicatesCSXTZ(1)

	def FindDuplicatesCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return []
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = []
		_anPos_ = []

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
			else
				_anPos_ + _i_
			ok
		next

		return _anPos_

	def FindDuplicatesCSXT(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return []
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = []
		_anSeen_ = []
		_anPos_ = []

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_anSeen_ + _i_
			else
				if StzFindFirst(_anPos_, _anSeen_[_n_]) = 0
					_anPos_ + _anSeen_[_n_]
				ok
				_anPos_ + _i_
			ok
		next

		_anPos_ = ring_sort(_anPos_)
		return _anPos_

	def NumberOfDuplicatesCS(pCaseSensitive)
		return len( This.FindDuplicatesCS(pCaseSensitive) )

	def ContainsNoDuplicatesCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		return len( This.FindDuplicatesCS(pCaseSensitive) ) = 0

	# TRUE if no item occurs twice.
	#
	#   returns    TRUE or FALSE
	#   see        ContainsDuplicates
	def ContainsNoDuplicates()
		return This.ContainsNoDuplicatesCS(1)

	def ContainsNoDuplications()
		return This.ContainsNoDuplicates()

	def NoItemsAreDuplicatedCS(pCaseSensitive)
		return This.ContainsNoDuplicatesCS(pCaseSensitive)

	def NoItemsAreDuplicated()
		return This.ContainsNoDuplicates()

	#-- NON-DUPLICATED ITEMS

	# TRUE if at least one item occurs exactly once.
	def ContainsNonDuplicatedItemsCS(pCaseSensitive)
		_anPos_ = This.FindDuplicatesCSXT(pCaseSensitive)
		_nLen_ = This.NumberOfItems()
		if NOT Q(_anPos_).IsEqualTo(1:_nLen_)
			return 1
		else
			return 0
		ok

	# TRUE if some item occurs only once.
	#
	#   returns    TRUE or FALSE
	#   see        NonDuplicatedItems
	def ContainsNonDuplicatedItems()
		return This.ContainsNonDuplicatedItemsCS(1)

	def ContainsItemsThatAreNotDuplicatedCS(pCaseSensitive)
		return This.ContainsNonDuplicatedItemsCS(pCaseSensitive)

	def ContainsItemsNonDuplicated()
		return This.ContainsNonDuplicatedItems()

	def ContainsAtLeastOneNonDuplicatedItem()
		return This.ContainsNonDuplicatedItems()

	def NonDuplicatedItemsCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return 0
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = []
		_acResult_ = []
		_anPos_ = []

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_acResult_ + _acStr_[_i_]
				_anPos_ + _i_
			else
				_nPos_ = StzFindFirst(_acResult_, _acStr_[_i_])
				if _nPos_ > 0
					ring_del(_acResult_, _nPos_)
					ring_del(_anPos_, _nPos_)
				ok
			ok
		next

		_aResult_ = []
		_nLen_ = len(_anPos_)
		for _i_ = 1 to _nLen_
			_aResult_ + _aContent_[_anPos_[_i_]]
		next

		return _aResult_

	# Returns the items that occur only once.
	#
	#   returns    a list of items
	#   see        FindNonDuplicatedItems
	def NonDuplicatedItems()
		return This.NonDuplicatedItemsCS(1)

	def NumberOfNonDuplicatedItemsCS(pCaseSensitive)
		return len(This.NonDuplicatedItemsCS(pCaseSensitive))

	# Returns how many items occur only once.
	#
	#   returns    a number
	#   see        NonDuplicatedItems
	def NumberOfNonDuplicatedItems()
		return This.NumberOfNonDuplicatedItemsCS(1)

	def FindNonDuplicatedItemsCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return 0
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = []
		_acResult_ = []
		_anResult_ = []

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_acResult_ + _acStr_[_i_]
				_anResult_ + _i_
			else
				_nPos_ = StzFindFirst(_acResult_, _acStr_[_i_])
				if _nPos_ > 0
					ring_del(_acResult_, _nPos_)
					ring_del(_anResult_, _nPos_)
				ok
			ok
		next

		return _anResult_

	# Returns the positions of the items that occur only once.
	#
	#   returns    a list of positions
	#   see        FindDuplicates
	def FindNonDuplicatedItems()
		return This.FindNonDuplicatedItemsCS(1)

	def NonDuplicatedItemsAndTheirPositionsCS(pCaseSensitive)
		_aNonDuplicated_ = This.NonDuplicatedItemsCS(pCaseSensitive)
		_nLen_ = len(_aNonDuplicated_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			_nPos_ = This.FindFirstCS(_aNonDuplicated_[_i_], pCaseSensitive)
			_aResult_ + [ _aNonDuplicated_[_i_], _nPos_ ]
		next
		return _aResult_

	# Returns each item that occurs once with its position.
	#
	#   returns    a list of [ item, position ] pairs
	#   see        NonDuplicatedItems
	def NonDuplicatedItemsAndTheirPositions()
		return This.NonDuplicatedItemsAndTheirPositionsCS(1)

	def NonDuplicatedItemsZ()
		return This.NonDuplicatedItemsAndTheirPositions()

	#-- INDEX (positions of each item)

	def FindItemsCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aList_ = @aContent

		if pCaseSensitive = 0
			_aList_ = This.Lowercased()
		ok

		_nLenList_ = len(_aList_)

		if _nLenList_ = 0
			return []
		ok

		_acListStringified_ = []
		for _i_ = 1 to _nLenList_
			_acListStringified_ + @@(_aList_[_i_])
		next

		_aResult_ = []
		_acSeen_ = []
		for _i_ = 1 to _nLenList_
			if StzFindFirst(_acSeen_, _acListStringified_[_i_])
				loop
			ok

			_anPos_ = []
			for _j_ = 1 to _nLenList_
				if _acListStringified_[_i_] = _acListStringified_[_j_]
					_anPos_ + _j_
				ok
			next

			_aResult_ + [ _aList_[_i_], _anPos_ ]
			_acSeen_ + _acListStringified_[_i_]
		next

		return _aResult_

	def IndexCS(pCaseSensitive)
		return This.FindItemsCS(pCaseSensitive)

	#-- ITEMS OCCURRING N TIMES (case-sensitive dial)

	def ItemsOccurringNTimesCS(_n_, pCaseSensitive)
		_aIndex_ = This.IndexCS(pCaseSensitive)
		_nLen_ = len(_aIndex_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if len(_aIndex_[_i_][2]) >= _n_
				_aResult_ + _aIndex_[_i_][1]
			ok
		next
		return _aResult_

	def ItemsOccuringNTimesCS(_n_, pCaseSensitive)
		return This.ItemsOccurringNTimesCS(_n_, pCaseSensitive)

	# Turns every item into the first of a list of n items, padded with empty strings, in place.
	#
	#   _n_        the size of each new list
	#   returns    nothing; the list changes
	#   see        NListified
	#@ aka  -- N-LISTIFY (pad each item into an n-element sublist)
	def NListify(_n_)
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aResult_ = []

		for _i_ = 1 to _nLen_
			_aList_ = []
			if NOT isList(_aContent_[_i_])
				_aList_ + _aContent_[_i_]
				if _n_ > 1
					for _j_ = 1 to _n_-1
						_aList_ + ""
					next
				ok
			else
				_nLenList_ = len(_aContent_[_i_])
				if _n_ = _nLenList_
					_aList_ = _aContent_[_i_]
				but _n_ > _nLenList_
					_aList_ = _aContent_[_i_]
					for _j_ = 1 to _n_ - _nLenList_
						_aList_ + ""
					next
				but _n_ < _nLenList_
					for _j_ = 1 to _n_
						_aList_ + _aContent_[_i_][_j_]
					next
				ok
			ok
			_aResult_ + _aList_
		next

		This.UpdateWith(_aResult_)

	def NListifyQ(_n_)
		This.NListify(_n_)
		return This

	# Returns each item as the first of a list of n items, padded with empty strings; the list is unchanged.
	#
	#   _n_        the size of each new list
	#   returns    a list of lists
	#   see        Pairified
	def NListified(_n_)
		return This.Copy().NListifyQ(_n_).Content()

	#-- IsAPairQ (alias of IsPairQ)

	def IsPairQ()
		if This.IsPair()
			#-- Pass back a whole-object guard so a chained .Where(cond) binds
			#-- @pair to the WHOLE pair (@pair[1]/@pair[2] are its elements),
			#-- not item-by-item. A non-pair yields a stzFalseObject (Where->0).
			return new stzObjectGuard(This, :Pair)
		else
			return StzFalseObjectQ()
		ok

	def IsAPairQ()
		return This.IsPairQ()

	#-- HALVES family (XT = include the middle item on the first half)

	def FirstHalfXT()
		_nPos_ = ceil(This.NumberOfItems() / 2)
		return This.Section(1, _nPos_)

	def SecondHalfXT()
		_nLen_ = This.NumberOfItems()
		_nPos_ = ceil(_nLen_ / 2) + 1
		return This.Section(_nPos_, _nLen_)

	# Returns the first half with the position where it starts.
	#
	#   returns    a pair [ half, position ]
	#   see        FirstHalf
	def FirstHalfAndPosition()
		return [ This.FirstHalf(), 1 ]

	# Returns the first half with its section, as [ start, end ].
	#
	#   returns    a pair [ half, [ start, end ] ]
	#   see        FirstHalf
	def FirstHalfAndSection()
		return [ This.FirstHalf(), [1, floor(This.NumberOfItems() / 2)] ]

	def FirstHalfAndPositionXT()
		return [ This.FirstHalfXT(), 1 ]

	def FirstHalfAndSectionXT()
		return [ This.FirstHalfXT(), [1, ceil(This.NumberOfItems() / 2)] ]

	# Returns the second half with the position where it starts.
	#
	#   returns    a pair [ half, position ]
	#   see        SecondHalf
	def SecondHalfAndPosition()
		_nLen_ = This.NumberOfItems()
		_nPos_ = floor(_nLen_ / 2) + 1
		return [ This.SecondHalf(), _nPos_ ]

	# Returns the second half with its section, as [ start, end ].
	#
	#   returns    a pair [ half, [ start, end ] ]
	#   see        SecondHalf
	def SecondHalfAndSection()
		_nLen_ = This.NumberOfItems()
		_nPos_ = floor(_nLen_ / 2) + 1
		return [ This.SecondHalf(), [ _nPos_, _nLen_ ] ]

	def SecondHalfAndPositionXT()
		_nLen_ = This.NumberOfItems()
		_nPos_ = ceil(_nLen_ / 2) + 1
		return [ This.SecondHalfXT(), _nPos_ ]

	def SecondHalfAndSectionXT()
		_nLen_ = This.NumberOfItems()
		_nPos_ = ceil(_nLen_ / 2) + 1
		return [ This.SecondHalfXT(), [ _nPos_, _nLen_ ] ]

	def FirstHalfAndItsPosition()
		return This.FirstHalfAndPosition()

	def FirstHalfAndItsSection()
		return This.FirstHalfAndSection()

	def FirstHalfAndItsPositionXT()
		return This.FirstHalfAndPositionXT()

	def FirstHalfAndItsSectionXT()
		return This.FirstHalfAndSectionXT()

	def SecondHalfAndItsPosition()
		return This.SecondHalfAndPosition()

	def SecondHalfAndItsSection()
		return This.SecondHalfAndSection()

	def SecondHalfAndItsPositionXT()
		return This.SecondHalfAndPositionXT()

	def SecondHalfAndItsSectionXT()
		return This.SecondHalfAndSectionXT()

	# Returns the list cut into its two halves.
	#
	#   returns    a list of two lists
	#   see        FirstHalf, SecondHalf, Bisect
	def Halves()
		_acResult_ = []
		_acResult_ + This.FirstHalf() + This.SecondHalf()
		return _acResult_

	def HalvesXT()
		_acResult_ = []
		_acResult_ + This.FirstHalfXT() + This.SecondHalfXT()
		return _acResult_

	# Returns each half with the position where it starts.
	#
	#   returns    a list of two [ half, position ] pairs
	#   see        Halves
	def HalvesAndPositions()
		return [ This.FirstHalfAndPosition(), This.SecondHalfAndPosition() ]

	def HalvesAndPositionsXT()
		return [ This.FirstHalfAndPositionXT(), This.SecondHalfAndPositionXT() ]

	# Returns each half with its section, as [ start, end ].
	#
	#   returns    a list of two [ half, [ start, end ] ] pairs
	#   see        Halves
	def HalvesAndSections()
		return [ This.FirstHalfAndSection(), This.SecondHalfAndSection() ]

	def HalvesAndSectionsXT()
		return [ This.FirstHalfAndSectionXT(), This.SecondHalfAndSectionXT() ]

	#========================================================#
	#  BATCH-2 RESTORE: Extract family (split-dropped).      #
	#  Extract = "remove from the list AND return what was   #
	#  removed" -- the destructive counterpart of Find.      #
	#========================================================#

	# Removes the item at position n and returns it.
	#
	#   _n_        the position to remove
	#   returns    the removed item
	#   see        ExtractNth
	def ExtractAt(_n_)
		_TempItem_ = This.ItemAt(_n_)
		This.RemoveAt(_n_)
		return _TempItem_

	def ExtractFirstCS(pItem, pCaseSensitive)
		return This.ExtractNthOccurrenceCS(1, pItem, pCaseSensitive)

	def ExtractLastCS(pItem, pCaseSensitive)
		_nLast_ = This.NumberOfOccurrencesCS(pItem, pCaseSensitive)
		return This.ExtractNthOccurrenceCS(_nLast_, pItem, pCaseSensitive)


	def FindNextSTCS(pItem, _nStart_, pCaseSensitive)
		return This.FindNextOccurrenceCS(pItem, _nStart_, pCaseSensitive)

	def FindPreviousSTCS(pItem, pnStartingAt, pCaseSensitive)
		return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	def ExtractNextSTCS(pItem, pnStartingAt, pCaseSensitive)
		if isList(pnStartingAt) and IsStartingAtNamedParamList(pnStartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		_nPos_ = This.FindNextSTCS(pItem, pnStartingAt, pCaseSensitive)
		if _nPos_ = 0
			return
		ok
		This.RemoveItemAtPosition(_nPos_)
		return pItem

	def ExtractNextST(item, pnStartingAt)
		return This.ExtractNextSTCS(item, pnStartingAt, 1)

	def ExtractNext(pItem, pnStartingAt)
		return This.ExtractNextST(pItem, pnStartingAt)

	def ExtractNextCS(pItem, pnStartingAt, pCaseSensitive)
		return This.ExtractNextSTCS(pItem, pnStartingAt, pCaseSensitive)

	def ExtractPreviousSTCS(pItem, pnStartingAt, pCaseSensitive)
		if isList(pnStartingAt) and IsStartingAtNamedParamList(pnStartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		_nPos_ = This.FindPreviousSTCS(pItem, pnStartingAt, pCaseSensitive)
		if _nPos_ = 0
			return
		ok
		This.RemoveItemAtPosition(_nPos_)
		return pItem

	def ExtractPreviousST(item, pnStartingAt)
		return This.ExtractPreviousSTCS(item, pnStartingAt, 1)

	def ExtractPrevious(pItem, pnStartingAt)
		return This.ExtractPreviousST(pItem, pnStartingAt)

	def ExtractPreviousCS(pItem, pnStartingAt, pCaseSensitive)
		return This.ExtractPreviousSTCS(pItem, pnStartingAt, pCaseSensitive)

	#========================================================#
	#  BATCH-3 RESTORE: IsNeither, HasSameContent,           #
	#  ToListInString(+ShortForm)/ToCodeQ, FirstList,        #
	#  AllItemsAreEqualTo (split-dropped / new).             #
	#========================================================#

	# TRUE if the list equals neither of the two given lists.
	#
	#   paList1    the first list
	#   paList2    the second list
	#   returns    TRUE or FALSE
	#   see        IsEither
	def IsNeither(paList1, paList2)
		return This.IsNeitherCS(paList1, paList2, 1)

	def IsNeitherCS(paList1, paList2, pCaseSensitive)
		if isList(paList1) and IsEqualToNamedParamList(paList1)
			paList1 = paList1[2]
		ok
		if isList(paList2) and IsNorNamedParamList(paList2)
			paList2 = paList2[2]
		ok

		_bEqualToList1_ = This.IsEqualToCS(paList1, pCaseSensitive)
		_bEqualToList2_ = This.IsEqualToCS(paList2, pCaseSensitive)

		if NOT _bEqualToList1_ and NOT _bEqualToList2_
			return 1
		else
			return 0
		ok

	# TRUE if both lists hold the same items, in any order, counting repeats.
	#
	#   returns    TRUE or FALSE
	#   see        HasSameContentAs
	#@ aka  -- HasSameContent: order-INsensitive content equality (a multiset -- comparison). Same items, any order, optionally case-folded.
	def HasSameContent(paOtherList)
		return This.HasSameContentCS(paOtherList, 1)

	def HasSameContentCS(paOtherList, pCaseSensitive)
		if isList(paOtherList) and IsAsNamedParamList(paOtherList)
			paOtherList = paOtherList[2]
		ok
		if isList(pCaseSensitive) and len(pCaseSensitive) = 2 and isString(pCaseSensitive[1])
			pCaseSensitive = pCaseSensitive[2]
		ok
		if NOT isList(paOtherList)
			return 0
		ok

		if pCaseSensitive = 1
			return This.HasSameContentAs(paOtherList)
		ok

		# Case-insensitive: compare lowercased, stringified multisets.
		_aThis_ = This.Content()
		_n1_ = len(_aThis_)
		_n2_ = len(paOtherList)
		if _n1_ != _n2_
			return 0
		ok
		_ac1_ = []
		for _i_ = 1 to _n1_
			_ac1_ + StzLower("" + _aThis_[_i_])
		next
		_ac2_ = []
		for _i_ = 1 to _n2_
			_ac2_ + StzLower("" + paOtherList[_i_])
		next
		_ac1_ = ring_sort(_ac1_)
		_ac2_ = ring_sort(_ac2_)
		for _i_ = 1 to _n1_
			if NOT _ac1_[_i_] = _ac2_[_i_]
				return 0
			ok
		next
		return 1

	#-- Rendering the list back to its Ring source-code string.

	def ToCodeQ()
		return new stzString(This.ToCode())

	def ToListInString()
		return This.ToCode()

	def ToListInStringInShortForm()
		# Compress a contiguous integer list into its "a:b" range form,
		# e.g. [ 4, 5, 6, 7, 8 ] -> "4:8". Falls back to the full code
		# string for non-contiguous / non-numeric lists.
		return This.ToListInAStringInShortForm()

	# Returns the position of the first item that is a list; 0 when there is none.
	#
	#   returns    a number
	#   see        FirstList
	#@ aka  -- First sublist (item that is itself a list) and its position.
	def FindFirstList()
		_aC_ = This.Content()
		_n_ = len(_aC_)
		for _i_ = 1 to _n_
			if isList(_aC_[_i_])
				return _i_
			ok
		next
		return 0

	# Returns the first item that is a list.
	#
	#   returns    the list
	#   see        FindFirstList
	def FirstList()
		_nPos_ = This.FindFirstList()
		if _nPos_ = 0
			return []
		ok
		_aC_ = This.Content()
		return _aC_[_nPos_]

	#-- AllItemsAreEqualTo: every item equals pItem (content-compare, so
	#-- sublists match too).

	def AllItemsAreEqualToCS(pItem, pCaseSensitive)
		_aC_ = This.Content()
		_n_ = len(_aC_)
		if _n_ = 0
			return 0
		ok
		for _i_ = 1 to _n_
			if NOT BothAreEqualCS(_aC_[_i_], pItem, pCaseSensitive)
				return 0
			ok
		next
		return 1

	# TRUE if every item equals the given value.
	#
	#   returns    TRUE or FALSE
	#   see        AllItemsAreEqual
	def AllItemsAreEqualTo(pItem)
		return This.AllItemsAreEqualToCS(pItem, 1)

	#========================================================#
	#  BATCH-4 RESTORE: number/non-number filters, occurrence #
	#  counts, ItemsAndTheirPositions (split-dropped).        #
	#========================================================#

	# Returns the positions of the items that are numbers.
	#
	#   returns    a list of positions
	#   see        OnlyNumbers
	#@ aka  The positions of the NUMBER items.
	def FindNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if isNumber(_aContent_[_i_])
				_aResult_ + _i_
			ok
		next
		return _aResult_

	# Returns the positions of the items that are not numbers.
	#
	#   returns    a list of positions
	#   see        FindNumbers
	#@ aka  The positions of the non-number items.
	def FindNonNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if NOT isNumber(_aContent_[_i_])
				_aResult_ + _i_
			ok
		next
		return _aResult_

	# Removes the items that are numbers, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveNonNumbers
	#@ aka  Remove all the number items (mutating).
	def RemoveNumbers()
		This.RemoveItemsAtPositions( This.FindNumbers() )

		# Removes every item that is a number, in place.
		#
		#   returns    nothing; the list changes
		#   see        RemoveNumbers
		def RemoveOnlyNumbers()
			This.RemoveNumbers()

		# Removes every number, keeping the items that are not numbers, in place.
		#
		#   returns    nothing; the list changes
		#   see        RemoveNonNumbers
		def RemoveAllExceptNonNumbers()
			This.RemoveNumbers()

	# Removes every item that is not a number, in place.
	#
	#   returns    nothing; the list changes
	#   see        RemoveNumbers
	#@ aka  Remove every non-number item (mutating).
	def RemoveNonNumbers()
		This.RemoveItemsAtPositions( This.FindNonNumbers() )

		# Removes every item that is not a number, in place.
		#
		#   returns    nothing; the list changes
		#   see        RemoveNonNumbers
		def RemoveOnlyNonNumbers()
			This.RemoveNonNumbers()

		# Removes every item that is not a number, in place.
		#
		#   returns    nothing; the list changes
		#   see        RemoveNonNumbers
		def RemoveAllExceptNumbers()
			This.RemoveNonNumbers()

	def OnlyNonNumbers()
		return This.NonNumbers()

	def ItemsAndTheirPositions()
		return This.FindItems()

	#-- Occurrence counts: each distinct item paired with how many times
	#-- it appears.

	def NumberOfOccurrenceOfItemsCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_aList_ = @aContent
		if pCaseSensitive = 0
			_aList_ = This.Lowercased()
		ok

		_nLenList_ = len(_aList_)
		if _nLenList_ = 0
			return []
		ok

		_aItems_ = This.WithoutDuplicationCS(pCaseSensitive)
		_nLenItems_ = len(_aItems_)

		_aResult_ = []
		for _i_ = 1 to _nLenItems_
			_n_ = 0
			for _j_ = 1 to _nLenList_
				if ring_type(_aItems_[_i_]) = ring_type(_aList_[_j_]) and
				   _aItems_[_i_] = _aList_[_j_]
					_n_++
				ok
			next
			_aResult_ + [ _aItems_[_i_], _n_ ]
		next

		return _aResult_

	# Returns each distinct item with how many times it occurs.
	#
	#   returns    a list of [ item, count ] pairs
	#   see        Frequencies
	def NumberOfOccurrenceOfItems()
		return This.NumberOfOccurrenceOfItemsCS(1)

		def NumberOfOccurrenceOfEachItem()
			return This.NumberOfOccurrenceOfItems()

	#========================================================#
	#  BATCH-5 RESTORE: IsListOfNumbersAndPairsOfNumbers,    #
	#  Split(ted)ToPartsOfNItemsXT / After / Before          #
	#  Positions, (Find)PreviousNthOccurrence.               #
	#========================================================#

	# TRUE if every item is a number or a pair of numbers.
	#
	#   returns    TRUE or FALSE
	#   see        IsListOfNumbers
	def IsListOfNumbersAndPairsOfNumbers()
		# Each item must be a number, or a 2-element list of two numbers.
		# (Pair check inlined: the class also has a 0-arg IsPairOfNumbers
		# method, which would shadow the global func form inside the class.)
		_aC_ = This.Content()
		_n_ = len(_aC_)
		for _i_ = 1 to _n_
			_x_ = _aC_[_i_]
			if isNumber(_x_)
				loop
			ok
			if isList(_x_) and len(_x_) = 2 and isNumber(_x_[1]) and isNumber(_x_[2])
				loop
			ok
			return 0
		next
		return 1

	#-- Splitting into parts (mutating Split*, fluent Split*Q, and
	#-- non-mutating Splitted* that return a fresh list of parts).

	def SplitToPartsOfNItemsXT(_n_)
		_aSections_ = StzSplitterQ(This.NumberOfItems()).SplitToPartsOfNItemsXT(_n_)
		This.UpdateWith( This.Sections(_aSections_) )

	def SplitToPartsOfNItemsXTQ(_n_)
		This.SplitToPartsOfNItemsXT(_n_)
		return This

	# The parts of n items each, as data; the original is unchanged.
	def SplittedToPartsOfNItemsXT(_n_)
		return This.Copy().SplitToPartsOfNItemsXTQ(_n_).Content()

	# Splits the list into parts after each of the given positions, in place.
	#
	#   returns    nothing; the list becomes the list of parts
	#   see        SplitAtPositions
	#@ aka  Split the list after EACH of the given positions.
	def SplitAfterPositions(panPos)
		_aSections_ = StzSplitterQ(This.NumberOfItems()).SplitAfterPositions(panPos)
		This.UpdateWith( This.Sections(_aSections_) )

	def SplitAfterPositionsQ(panPos)
		This.SplitAfterPositions(panPos)
		return This

	# Returns the list cut after each of the given positions; the list is unchanged.
	#
	#   returns    a list of lists
	#   see        SplitAfterPositions
	#@ aka  The parts split after the given positions, as data.
	def SplittedAfterPositions(panPos)
		return This.Copy().SplitAfterPositionsQ(panPos).Content()

	# Splits the list before each of the given positions, in place.
	#
	#   panPos     the positions to split before
	#   returns    nothing; the list becomes a list of sections
	#   see        SplitAt
	#   example    o1.SplitBeforePositions([ 2, 4 ])
	#              ? @@( o1.Content() )
	#              #--> [ [ "a" ], [ "b", "c" ], [ "b" ] ]
	#@ aka  Split the list before EACH of the given positions.
	def SplitBeforePositions(panPos)
		_aSections_ = StzSplitterQ(This.NumberOfItems()).SplitBeforePositions(panPos)
		This.UpdateWith( This.Sections(_aSections_) )

	def SplitBeforePositionsQ(panPos)
		This.SplitBeforePositions(panPos)
		return This

	# Returns the list cut before each of the given positions; the list is unchanged.
	#
	#   returns    a list of lists
	#   see        SplittedAfterPositions
	#@ aka  The parts split before the given positions, as data.
	def SplittedBeforePositions(panPos)
		return This.Copy().SplitBeforePositionsQ(panPos).Content()

	#-- Nth previous occurrence (scanning backward from a start position).

	def FindNthPreviousOccurrenceCS(_n_, pItem, _nStart_, pCaseSensitive)
		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok
		if isList(_nStart_) and IsStartingAtNamedParamList(_nStart_)
			_nStart_ = _nStart_[2]
		ok
		if isString(_nStart_) and ( _nStart_ = :Last or _nStart_ = :LastItem )
			_nStart_ = This.NumberOfItems()
		ok
		if isString(_n_)
			if _n_ = :First or _n_ = :FirstOccurrence
				_n_ = 1
			but _n_ = :Last or _n_ = :LastOccurrence
				_n_ = This.SectionQ(1, _nStart_).NumberOfOccurrenceCS(pItem, pCaseSensitive)
			ok
		ok

		_nLen_ = This.NumberOfItems()

		if _nStart_ = 1
			return 0
		ok
		if _nStart_ < 0 or _nStart_ > _nLen_
			return 0
		ok
		if NOT This.ContainsCS(pItem, pCaseSensitive)
			return 0
		ok
		if This.SectionQ(1, _nStart_ - 1).NumberOfOccurrenceCS(pItem, pCaseSensitive) < _n_
			return 0
		ok

		_bCase_ = CaseSensitive(pCaseSensitive)
		# Current FindPreviousCS is exclusive (strictly before nPos), so we
		# seed nPos with nStart itself to count the occurrence at nStart-1.
		_nPos_ = _nStart_
		_nFound_ = 0
		_i_ = 0

		while 1
			_i_++
			if _i_ > _nLen_
				exit
			ok
			_nPos_ = This.FindPreviousCS(pItem, _nPos_, _bCase_)
			if _nPos_ = 0
				exit
			else
				_nFound_++
				if _nFound_ = _n_
					return _nPos_
				ok
			ok
		end

		return 0

	# Returns the position of the nth occurrence of the item before a given position; 0 when there is none.
	#
	#   _n_        which occurrence, counted backwards
	#   _nStart_   the position to count back from
	#   returns    a number
	#   see        FindPreviousNth
	def FindNthPreviousOccurrence(_n_, pItem, _nStart_)
		return This.FindNthPreviousOccurrenceCS(_n_, pItem, _nStart_, 1)

	def PreviousNthOccurrenceCS(_n_, pItem, _nStart_, pCaseSensitive)
		return This.FindNthPreviousOccurrenceCS(_n_, pItem, _nStart_, pCaseSensitive)

	def PreviousNthOccurrence(_n_, pItem, _nStart_)
		return This.FindNthPreviousOccurrence(_n_, pItem, _nStart_)

	#-- Remove a matching opening/closing bound pair (e.g. "{" ... "}").
	#-- TheseBoundsRemoved returns a fresh list; RemoveTheseBounds mutates.

	def RemoveTheseBoundsCS(pBound1, pBound2, pCaseSensitive)
		if This.IsBoundedByCS([ pBound1, pBound2 ], pCaseSensitive)
			This.RemoveFirstItem()
			This.RemoveLastItem()
		ok

	# Removes the two given bounds from the ends of the list, in place, when both are there.
	#
	#   returns    nothing; the list changes
	#   see        TheseBoundsRemoved
	def RemoveTheseBounds(pBound1, pBound2)
		This.RemoveTheseBoundsCS(pBound1, pBound2, 1)

	def RemoveTheseBoundsQ(pBound1, pBound2)
		This.RemoveTheseBounds(pBound1, pBound2)
		return This

	# Returns a copy without the two given bounds at its ends; the list is unchanged.
	#
	#   returns    a list of items
	#   see        RemoveTheseBounds
	#@ aka  A copy with the two given bounds removed from the ends.
	def TheseBoundsRemoved(pBound1, pBound2)
		return This.Copy().RemoveTheseBoundsQ(pBound1, pBound2).Content()

	#========================================================#
	#  BATCH-8 RESTORE: MultiplyBy, ExtendToXT, TypesXT,     #
	#  FindStzNumbers, ReplaceThisAt (split-dropped).        #
	#========================================================#

	# Replaces the list by a list that holds it n times, nested, in place.
	#
	#   p          how many times the list is repeated
	#   returns    nothing; the list changes
	#   see        Repeated
	#   example    o1.MultiplyBy(2)
	#              ? @@( o1.Content() )
	#              #--> [ [ "a", "b", "c", "b" ], [ "a", "b", "c", "b" ] ]
	#@ aka  Multiply the list by the given factor (number: tile; list: pairwise).
	def MultiplyBy(p)
		switch ring_type(p)
		on "NUMBER"
			if p = 0
				_aResult_ = []
			but p = 1
				_aResult_ = @aContent
			else
				_aResult_ = []
				for _i_ = 1 to p
					_aResult_ + @aContent
				next
			ok
			This.Update( _aResult_ )

		on "STRING"
			_nLen_ = len(@aContent)
			for _i_ = 1 to _nLen_
				if isString(@aContent[_i_])
					@aContent[_i_] += p
				ok
			next

		on "LIST"
			# Pair each item with the given list:
			# [ "V1","V2" ] * [ 1,2 ] -> [ [ "V1",[1,2] ], [ "V2",[1,2] ] ]
			_nLen_ = len(@aContent)
			for _i_ = 1 to _nLen_
				item = @aContent[_i_]
				This._InvalidateEngine()   # in-place @aContent mutation below
				@aContent[_i_] = [ item, p ]
			next

		other
			StzRaise("Can't multiply the list by an object!")
		off

	def ExtendToXT(_n_, pValue)
		This.ExtendToPositionWith(_n_, pValue)

	def TypesXT()
		return This.ListQ().AssociatedWith( This.Types() )

	# Returns the positions of the items that are stzNumber objects.
	#
	#   returns    a list of positions
	#   see        FindStzLists
	#@ aka  The positions of the stzNumber OBJECT items.
	def FindStzNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_anResult_ = []
		for _i_ = 1 to _nLen_
			if @IsStzNumber(_aContent_[_i_])
				_anResult_ + _i_
			ok
		next
		return _anResult_

	# Replaces the given item by a new item at position n, in place, when the item stands there.
	#
	#   _n_        the position
	#   returns    nothing; the list changes
	#   see        ReplaceThisItemAt
	def ReplaceThisAt(_n_, pItem, pNewItem)
		This.ReplaceThisItemAt(_n_, pItem, pNewItem)

	# Replaces the item at a position by a new item, in place.
	#
	#   pPos       the position
	#   returns    nothing; the list changes
	#   see        ReplaceAnyItemAt
	def ReplaceAnyAt(pPos, pNewItem)
		This.ReplaceAt(pPos, pNewItem)

	# Returns the positions of the items that are stzString objects.
	#
	#   returns    a list of positions
	#   see        FindStzLists
	#@ aka  -- Positions of items that are stz objects of a given kind.
	def FindStzStrings()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_anResult_ = []
		for _i_ = 1 to _nLen_
			if @IsStzString(_aContent_[_i_])
				_anResult_ + _i_
			ok
		next
		return _anResult_

	# Returns the positions of the items that are stzList objects.
	#
	#   returns    a list of positions
	#   see        FindStzNumbers
	#@ aka  The positions of the stzList OBJECT items.
	def FindStzLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_anResult_ = []
		for _i_ = 1 to _nLen_
			if @IsStzList(_aContent_[_i_])
				_anResult_ + _i_
			ok
		next
		return _anResult_

	# Returns the content as a stzListOfStrings, for chaining string operations such as joining.
	#
	#   returns    a stzListOfStrings
	#@ aka  -- Convert to a stzListOfStrings (for string-oriented chaining like -- ConcatenatedUsing / Joined). Needed by the ..Q() chain idioms.
	def ToStzListOfStrings()
		return new stzListOfStrings(This.Content())

	# Returns a copy of the list with the item inserted after position n; the list is unchanged.
	#
	#   pnPos      the position to insert after; :ItemAtPosition = n is accepted
	#   pItem      the item to insert
	#   returns    a list
	#   see        InsertBefore
	#   example    ? @@( o1.InsertAfter(2, "X") )
	#              #--> [ "a", "X", "b", "c", "b" ]
	#              ? @@( o1.Content() )
	#              #--> [ "a", "b", "c", "b" ]
	#@ aka  -- InsertAfter(:ItemAtPosition = n, item): NON-mutating -- returns the -- would-be list with item inserted after position n, leaving This as-is -- (use InsertAfterPosition for the mutating form).
	def InsertAfter(pnPos, pItem)
		if isList(pnPos) and len(pnPos) = 2 and isString(pnPos[1])
			pnPos = pnPos[2]
		ok
		_oIaCopy_ = This.Copy()
		_oIaCopy_.InsertAfterPosition(pnPos, pItem)
		return _oIaCopy_.Content()

	# Puts every text item in uppercase, in place, and returns the object so the call can chain.
	#
	#   returns    the object itself
	#   see        Uppercased
	#   example    o1.UppercaseQ()
	#              ? @@( o1.Content() )
	#              #--> [ "A", "B", "C", "B" ]
	#@ aka  -- UppercaseQ: uppercase every string item in place, return This for -- chaining (mirrors LowercaseQ; relies on Uppercased).
	def UppercaseQ()
		_StzHistoOpen(This.Content())
		This.UpdateWith( This.Uppercased() )
		_StzHistoAdd(This.Content())
		return This

		# Lowercases every string item, in place, and returns the list for chaining.
		#
		#   returns    the list itself
		#   see        Lowercase
		#@ aka  Lowercase every string item, chainable.
		def LowercaseQ()
			_StzHistoOpen(This.Content())
			This.UpdateWith( This.Lowercased() )
			_StzHistoAdd(This.Content())
			return This

	#========================================================#
	#  DiffXTT family: structural diff (added / removed /    #
	#  modified) between this list and another. Restored     #
	#  from the monolith (split-dropped).                    #
	#========================================================#

	# Returns the items of the other list that the list does not hold.
	#
	#   returns    a list of items
	#   see        RemovedItemsComparedToCS
	def AddedItemsComparedToCS(paOtherList, pCaseSensitive)
		if NOT isList(paOtherList)
			StzRaise("Incorrect param type! paOtherList must be a list.")
		ok
		# Added = items in the OTHER list absent here = other \ this.
		# Engine-backed (stz_list_difference_cs) so the op is available to
		# any language binding, not just Ring.
		_pAic_ = This._EngineListFromContent()
		_pBic_ = StzEngineMarshalList(paOtherList)
		if _pAic_ != "" and _pBic_ != ""
			_pDic_ = StzEngineListDifferenceCS(_pBic_, _pAic_, pCaseSensitive)
			_aResult_ = StzEngineListContentToRingList(_pDic_)
			StzEngineListFree(_pDic_)
			StzEngineListFree(_pAic_)
			StzEngineListFree(_pBic_)
			return _aResult_
		ok
		# Fallback (non-marshalable content, e.g. objects)
		_aResult_ = []
		_nLen_ = len(paOtherList)
		for _i_ = 1 to _nLen_
			if NOT This.ContainsCS(paOtherList[_i_], pCaseSensitive)
				_aResult_ + paOtherList[_i_]
			ok
		next
		return _aResult_

	# Returns the items of the list that the other list does not hold.
	#
	#   returns    a list of items
	#   see        AddedItemsComparedToCS
	def RemovedItemsComparedToCS(paOtherList, pCaseSensitive)
		if NOT isList(paOtherList)
			StzRaise("Incorrect param type! paOtherList must be a list.")
		ok
		# Removed = items here absent from the OTHER list = this \ other.
		_pAric_ = This._EngineListFromContent()
		_pBric_ = StzEngineMarshalList(paOtherList)
		if _pAric_ != "" and _pBric_ != ""
			_pDric_ = StzEngineListDifferenceCS(_pAric_, _pBric_, pCaseSensitive)
			_aResult_ = StzEngineListContentToRingList(_pDric_)
			StzEngineListFree(_pDric_)
			StzEngineListFree(_pAric_)
			StzEngineListFree(_pBric_)
			return _aResult_
		ok
		# Fallback (non-marshalable content)
		_aResult_ = []
		_oOtherList_ = new stzList(paOtherList)
		_nLen_ = This.NumberOfItems()
		_aContent_ = This.Content()
		for _i_ = 1 to _nLen_
			if NOT _oOtherList_.ContainsCS(_aContent_[_i_], pCaseSensitive)
				_aResult_ + _aContent_[_i_]
			ok
		next
		return _aResult_

	# Returns the [ old, new ] pairs of items that changed against the other list, matched by overlap.
	#
	#   returns    a list of [ old, new ] pairs
	#   see        AddedItemsComparedToCS
	def ModifiedItemsComparedToCSXT(paOtherList, pCaseSensitive)
		if NOT isList(paOtherList)
			StzRaise("Incorrect param type! paOtherList must be a list.")
		ok

		# "Modified" item pairing (substring overlap for strings, element
		# overlap for sublists) is the real data algorithm here -- run it in
		# the Zig engine (stz_list_modified_items_cs) so every binding gets
		# it. Returns [ old, new ] pairs, nested structure preserved.
		_pAmi_ = This._EngineListFromContent()
		_pBmi_ = StzEngineMarshalList(paOtherList)
		if _pAmi_ != "" and _pBmi_ != ""
			_pMmi_ = StzEngineListModifiedItemsCS(_pAmi_, _pBmi_, pCaseSensitive)
			_aResult_ = StzEngineListContentToRingList(_pMmi_)
			StzEngineListFree(_pMmi_)
			StzEngineListFree(_pAmi_)
			StzEngineListFree(_pBmi_)
			return _aResult_
		ok

		# Fallback (non-marshalable content): same semantics in Ring.
		_aResult_ = []
		_aThisListU_ = @UniqueCS(This.Content(), pCaseSensitive)
		_aoThisListU_ = @Objectify(_aThisListU_)
		_aFiltered = []
		for _k = 1 to len(paOtherList)
			_bInThis = 0
			for _j = 1 to len(_aThisListU_)
				if BothAreEqualCS(paOtherList[_k], _aThisListU_[_j], pCaseSensitive)
					_bInThis = 1
					exit
				ok
			next
			if _bInThis = 0
				_aFiltered + paOtherList[_k]
			ok
		next
		_aOtherListU_ = @UniqueCS(_aFiltered, pCaseSensitive)
		_aoOtherListU_ = @Objectify(_aOtherListU_)
		_nLenThis_ = len(_aThisListU_)
		_nLenOther_ = len(_aOtherListU_)
		for _i_ = 1 to _nLenThis_
			if isString(_aThisListU_[_i_])
				for _j_ = 1 to _nLenOther_
					if isString(_aOtherListU_[_j_])
						if _aoThisListU_[_i_].ContainsCS(_aOtherListU_[_j_], pCaseSensitive) or
						   _aoOtherListU_[_j_].ContainsCS(_aThisListU_[_i_], pCaseSensitive)
							_aResult_ + [ _aThisListU_[_i_], _aOtherListU_[_j_] ]
						ok
					ok
				next
			but isList(_aThisListU_[_i_])
				for _j_ = 1 to _nLenOther_
					if isList(_aOtherListU_[_j_])
						if _aoThisListU_[_i_].ContainsOneOfTheseCS(_aOtherListU_[_j_], pCaseSensitive) or
						   _aoOtherListU_[_j_].ContainsOneOfTheseCS(_aThisListU_[_i_], pCaseSensitive)
							_aResult_ + [ _aThisListU_[_i_], _aOtherListU_[_j_] ]
						ok
					ok
				next
			ok
		next
		return _aResult_

	def DifferentItemsWithCSXTT(paOtherList, pCaseSensitive)
		_aAddedItems_ = This.AddedItemsComparedToCS(paOtherList, pCaseSensitive)
		_aRemovedItems_ = This.RemovedItemsComparedToCS(paOtherList, pCaseSensitive)
		_aModifiedItems_ = This.ModifiedItemsComparedToCSXT(paOtherList, pCaseSensitive)
		_nLen_ = len(_aModifiedItems_)

		_oAdded_ = new stzList(_aAddedItems_)
		_oRemoved_ = new stzList(_aRemovedItems_)

		for _i_ = 1 to _nLen_
			_oRemoved_.Remove(_aModifiedItems_[_i_][1])
			_oAdded_.RemoveAll(_aModifiedItems_[_i_][2])
		next

		return [
			[ "added", _oAdded_.Content() ],
			[ "removed", _oRemoved_.Content() ],
			[ "modified", _aModifiedItems_ ]
		]

	def DifferentItemsWithXTT(paOtherList)
		return This.DifferentItemsWithCSXTT(paOtherList, 1)

	def DiffXTT(paOtherList)
		return This.DifferentItemsWithXTT(paOtherList)

		def DiffXT(paOtherList)
			return This.DiffXTT(paOtherList)

	# Wraps each item in a Q object, in place, so that object methods can be called on it.
	#
	#   returns    nothing; the list changes
	#   see        Objectified
	#@ aka  -- Objectify: wrap each item in a Q() stz object (so per-item stz -- methods like ContainsCS can be called). Needed by DiffXTT's -- similarity matching.
	def Objectify()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			_aResult_ + Q(_aContent_[_i_])
		next
		This.UpdateWith(_aResult_)

	def ObjectifyQ()
		This.Objectify()
		return This

	# Returns each item wrapped as a Q object; the list is unchanged.
	#
	#   returns    a list of objects
	#   see        Objectify
	def Objectified()
		return This.Copy().ObjectifyQ().Content()

	# TRUE if the two lists are equal when letter case and tiny numeric differences are ignored.
	#
	#   returns    TRUE or FALSE
	#   see        IsEqualTo
	#@ aka  -- IsQuietEqualTo: approximate equality. Exact-equal (engine-backed -- IsEqualTo) OR the length-difference ratio is below the tunable -- QuietEqualityRatio (default 0.09; SetQuietEqualityRatio to change). -- No element loop here -- the content compare is the engine's job.
	def IsQuietEqualTo(paOtherList)
		if isList(paOtherList) and IsToNamedParamList(paOtherList)
			paOtherList = paOtherList[2]
		ok
		if This.IsEqualTo(paOtherList)
			return 1
		ok
		_nDif_ = abs(This.NumberOfItems() - len(paOtherList))
		_n_ = _nDif_ / This.NumberOfItems()
		if _n_ < QuietEqualityRatio()
			return 1
		ok
		return 0

	#-- Deep "contains" combinators. The heavy work is DeepContainsCS
	#-- (engine-backed: stringify the whole list + StzFind). These just
	#-- loop over the small QUERY list, not the data -- so no data-loop.

	def DeepContainsManyCS(paItems, pCaseSensitive)
		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			if NOT This.DeepContainsCS(paItems[_i_], pCaseSensitive)
				return 0
			ok
		next
		return 1

	def DeepContainsMany(paItems)
		return This.DeepContainsManyCS(paItems, 1)

		# TRUE if every one of the given items occurs at any depth of a nested list.
		#
		#   returns    TRUE or FALSE
		#   see        DeepContains
		def DeepContainsThese(paItems)
			return This.DeepContainsManyCS(paItems, 1)

	def DeepContainsBothCS(pItem1, pItem2, pCaseSensitive)
		if isList(pItem2) and IsAndNamedParamList(pItem2)
			pItem2 = pItem2[2]
		ok
		return This.DeepContainsManyCS([ pItem1, pItem2 ], pCaseSensitive)

	# TRUE if both items occur at any depth of a nested list.
	#
	#   pItem1     the first item
	#   pItem2     the second item
	#   returns    TRUE or FALSE
	#   see        DeepContains
	def DeepContainsBoth(pItem1, pItem2)
		return This.DeepContainsBothCS(pItem1, pItem2, 1)

	def DeepContainsOneOfTheseCS(paItems, pCaseSensitive)
		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			if This.DeepContainsCS(paItems[_i_], pCaseSensitive)
				return 1
			ok
		next
		return 0

	# TRUE if at least one of the given items occurs at any depth of a nested list.
	#
	#   returns    TRUE or FALSE
	#   see        DeepContains
	def DeepContainsOneOfThese(paItems)
		return This.DeepContainsOneOfTheseCS(paItems, 1)

	def DeepContainsNOfTheseCS(_n_, paItems, pCaseSensitive)
		_v_ = 0
		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			if This.DeepContainsCS(paItems[_i_], pCaseSensitive)
				_v_++
				if _v_ = _n_
					return 1
				ok
			ok
		next
		return 0

	# TRUE if at least n of the given items occur at any depth of a nested list.
	#
	#   _n_        how many of them must occur
	#   returns    TRUE or FALSE
	#   see        DeepContains
	def DeepContainsNOfThese(_n_, paItems)
		return This.DeepContainsNOfTheseCS(_n_, paItems, 1)

	#========================================================#
	#  Locale-shaped list predicates (i18n). Thin orchestra- #
	#  tion over the established per-string locale lookups.   #
	#========================================================#

	# Returns each item as a stzString; every item must be a string.
	#
	#   returns    a list of stzString objects
	#   see        ToStzListOfStrings
	def ToListOfStzStrings()
		if NOT This.IsListOfStrings()
			StzRaise("Can't proceed! All items must be strings.")
		ok
		_acContent_ = This.Content()
		_nLen_ = len(_acContent_)
		_aoResult_ = []
		for _i_ = 1 to _nLen_
			_aoResult_ + new stzString(_acContent_[_i_])
		next
		return _aoResult_

	# TRUE if every item is a language abbreviation, such as "en".
	#
	#   returns    TRUE or FALSE
	#   see        IsLocaleList
	def AreLanguageAbbreviations()
		if NOT @IsListOfStrings(@aContent)
			return 0
		ok
		_nLen_ = len(@aContent)
		_aoStzStr_ = This.ToListOfStzStrings()
		for _i_ = 1 to _nLen_
			if NOT _aoStzStr_[_i_].IsLanguageAbbreviation()
				return 0
			ok
		next
		return 1

	# TRUE if the list holds one locale name, such as "default" or "system".
	#
	#   returns    TRUE or FALSE
	#   see        AreLanguageAbbreviations
	def IsLocaleList()
		_nLen_ = len(@aContent)

		if _nLen_ = 1 and isString(@aContent[1]) and
		   StzFindFirst([ :Default, :DefaultLocale, :System, :SystemLocale, "c", "C", :CLocale ], @aContent[1]) > 0
			return 1
		ok

		if _nLen_ > 3
			return 0
		ok
		if NOT This.IsHashList()
			return 0
		ok

		_acKeys_ = []
		for _i_ = 1 to _nLen_
			_acKeys_ + @aContent[_i_][1]
		next
		_bLanguage_ = StzFindFirst("language", _acKeys_)
		_bScript_ = StzFindFirst("script", _acKeys_)
		_bCountry_ = StzFindFirst("country", _acKeys_)
		if _bLanguage_ = 0 and _bScript_ = 0 and _bCountry_ = 0
			return 0
		ok

		_cLanguage_ = @aContent[ :Language ]
		_cScript_   = @aContent[ :Script   ]
		_cCountry_  = @aContent[ :Country  ]
		if NOT ( isString(_cLanguage_) and isString(_cScript_) and isString(_cCountry_) )
			return 0
		ok
		if _cLanguage_ = "" and _cScript_ = "" and _cCountry_ = ""
			return 0
		ok
		if _cLanguage_ != "" and NOT StzStringQ(_cLanguage_).IsLanguageIdentifier()
			return 0
		ok
		if _cScript_ != "" and NOT StzStringQ(_cScript_).IsScriptIdentifier()
			return 0
		ok
		if _cCountry_ != "" and NOT StzStringQ(_cCountry_).IsCountryIdentifier()
			return 0
		ok
		return 1

	# TRUE if the list is a hash list whose values are all strings, one per language.
	#
	#   returns    TRUE or FALSE
	#   see        IsHashList
	def IsMultilingualString()
		if NOT This.IsHashlist()
			return 0
		ok
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			if NOT isString(@aContent[_i_][2])
				return 0
			ok
		next
		_aoKeys_ = []
		for _i_ = 1 to _nLen_
			_aoKeys_ + StzStringQ(@aContent[_i_][1])
		next
		for _i_ = 1 to _nLen_
			if NOT _aoKeys_[_i_].IsLanguageNameOrAbbreviation()
				return 0
			ok
		next
		return 1

	# Replaces the run of repeated leading items by a new item, in place.
	#
	#   returns    nothing; the list changes
	#   see        ReplaceLeadingItems
	#@ aka  -- Replace the run of repeated LEADING items with a given value -- (:with names it). Delegates to ReplaceLeadingItems.
	def ReplaceRepeatedLeadingItem(pItem)
		if isList(pItem) and IsWithNamedParamList(pItem)
			pItem = pItem[2]
		ok
		This.ReplaceLeadingItems(pItem)

	#========================================================#
	#  WALK family (split-dropped): back-and-forth + N-step  #
	#  + progressive-N-step traversals. These generate index #
	#  sequences (arithmetic); ItemsAt does the gather.      #
	#========================================================#

	# Returns the positions walked from the last to the first and back to the last.
	#
	#   returns    a list of positions
	#   see        WalkForthAndBack
	def WalkBackAndForth()
		return This.WalkBackAndForthXT(:Return = :WalkedPositions)

	def WalkBackAndForthXT(pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		_nLen_ = This.NumberOfItems()
		_anPos_ = _nLen_ : 1
		for _i_ = 2 to _nLen_
			_anPos_ + _i_
		next
		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)
		but pReturn = :WalkedPositions
			return _anPos_
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]
		else
			return _anPos_
		ok

	# Returns the positions walked n at a time forwards, in the form the second argument asks for.
	#
	#   _n_        the step
	#   pReturn    what to return, positions or items
	#   returns    a list of positions
	#   see        WalkNForward
	#@ aka  -- N-step (every nth item)
	def WalkNItemsForwardXT(_n_, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		_anPos_ = []
		_nLen_ = This.NumberOfItems()
		for _i_ = 1 to _nLen_ step _n_
			_anPos_ + _i_
		next
		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)
		but pReturn = :WalkedPositions
			return _anPos_
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]
		else
			return _anPos_
		ok

	# Returns the positions walked n at a time backwards, in the form the second argument asks for.
	#
	#   _n_        the step
	#   pReturn    what to return, positions or items
	#   returns    a list of positions
	#   see        WalkNBackward
	def WalkNItemsBackwardXT(_n_, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		_anPos_ = []
		for _i_ = This.NumberOfItems() to 1 step -_n_
			_anPos_ + _i_
		next
		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)
		but pReturn = :WalkedPositions
			return _anPos_
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]
		else
			return _anPos_
		ok

	def WalkNForwardXT(_n_, pReturn)
		return This.WalkNItemsForwardXT(_n_, pReturn)

	def WalkNBackwardXT(_n_, pReturn)
		return This.WalkNItemsBackwardXT(_n_, pReturn)

	#-- Progressive N-step (gap grows by n each step)

	def WalkNProgressiveItemsForwardXT(_n_, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		_nLen_ = This.NumberOfItems()
		_anPos_ = []
		if _n_ < 0
			StzRaise("Can't proceed. n must be positive!")
		but _n_ = 0
			_anPos_ = [1]
		else
			_anPos_ = [1]
			_nStep_ = 1
			_i_ = 0
			while _nStep_ <= _nLen_
				_i_++
				_nStep_ += (_n_ * _i_)
				if _nStep_ <= _nLen_
					_anPos_ + _nStep_
				ok
			end
		ok
		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)
		but pReturn = :WalkedPositions
			return _anPos_
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]
		else
			return _anPos_
		ok

	def WalkNProgressiveItemsBackwardXT(_n_, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		_nLen_ = This.NumberOfItems()
		_anPos_ = []
		if _n_ < 0
			StzRaise("Can't proceed. n must be positive!")
		but _n_ = 0
			_anPos_ = [ _nLen_ ]
		else
			_anPos_ = [ _nLen_ ]
			_nStep_ = _nLen_
			_i_ = 0
			while _nStep_ > 0
				_i_++
				_nStep_ -= (_n_ * _i_)
				if _nStep_ > 0
					_anPos_ + _nStep_
				ok
			end
		ok
		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)
		but pReturn = :WalkedPositions
			return _anPos_
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]
		else
			return _anPos_
		ok

	# Returns the positions walked forwards with a growing step.
	#
	#   _n_        the first step
	#   returns    a list of positions
	#   see        WalkNProgressiveItemsBackward
	def WalkNProgressiveItemsForward(_n_)
		return This.WalkNProgressiveItemsForwardXT(_n_, :Return = :WalkedPositions)

	# Returns the positions walked backwards with a growing step.
	#
	#   _n_        the first step
	#   returns    a list of positions
	#   see        WalkNProgressiveItemsForward
	def WalkNProgressiveItemsBackward(_n_)
		return This.WalkNProgressiveItemsBackwardXT(_n_, :Return = :WalkedPositions)

	def WalkNMoreForward(_n_)
		return This.WalkNProgressiveItemsForward(_n_)

	def WalkNMoreForwardXT(_n_, pReturn)
		return This.WalkNProgressiveItemsForwardXT(_n_, pReturn)

	def WalkNMoreBackward(_n_)
		return This.WalkNProgressiveItemsBackward(_n_)

	def WalkNMoreBackwardXT(_n_, pReturn)
		return This.WalkNProgressiveItemsBackwardXT(_n_, pReturn)

	#========================================================#
	#  WALK zigzag + start/end family (split-dropped).       #
	#========================================================#

	def WalkNItemsForwardNItemsBackwardXT(pnForward, pnBackward, pReturn)

		# Checking params

		if NOT Q([pnForward, pnBackward]).BothAreNumbers()
			StzRaise("Incorrect param type! Both pnForward and pnBackward must be numbers.")
		ok

		if isList(pReturn) and
		   IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])

			pReturn = pReturn[2]
		ok

		if NOT ( isString(pReturn) and

			 StzFindFirst(pReturn, [
				:WalkedPositions, :WalkedItems,
				:LastPosition, :LastWalkedPosition,
				:LastItem, :LastWalkedItem,
				:Default
			]) > 0 )

			StzRaise("Incorrect param! pReturn must be a string. Allowed values are " +
				 ":WalkedPositions, :WalkedItems, :LastWalkedPosition, :LastWalkedItem, and :Default." )
		ok

		if pReturn = :Default
			pReturn = :WalkedPositions
		ok

		# Doing the job

		_aList_ = This.List()
		_nLen_ = len(_aList_)

		if pnForward = pnBackward
			return []
		ok

		if pnBackward > pnForward
			_nStart_ = pnBackward - pnForward + 1
		else
			_nStart_ = 1
		ok

		_i_ = _nStart_
		_anPos_ = [ _i_ ]

		while (_i_ + pnForward) >= 1 and (_i_ + pnForward) <= _nLen_ and
		      (_i_ + pnForward - pnBackward) >= 1 and (_i_ + pnForward - pnBackward) <= _nLen_

			_i_ = _i_ + pnForward
			_anPos_ + _i_

			_i_ = _i_ - pnBackward
			_anPos_ + _i_

		end

		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)

		but pReturn = :WalkedPositions
			return _anPos_

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]

		else
			return _anPos_
		end
	
	# Returns the positions walked n items forwards, then n items backwards.
	#
	#   pnForward    how many items forward
	#   pnBackward   how many items back
	#   returns      a list of positions
	#   see          WalkNItemsBackwardNItemsForward
		#< @FunctionAlternativeForm
	def WalkNItemsForwardNItemsBackward(pnForward, pnBackward)
		return This.WalkNItemsForwardNItemsBackwardXT(pnForward, pnBackward, :Return = :WalkedPositions)

		#< @FunctionAlternativeForm


	def WalkNItemsBackwardNItemsForwardXT(pnBackward, pnForward, pReturn)

		# Checking params

		if NOT Q([pnBackward, pnForward]).BothAreNumbers()
			StzRaise("Incorrect param type! Both pnForward and pnBackward must be numbers.")
		ok

		if isList(pReturn) and
		   IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])

			pReturn = pReturn[2]
		ok

		if NOT ( isString(pReturn) and

			 StzFindFirst(pReturn, [
				:WalkedPositions, :WalkedItems,
				:LastPosition, :LastWalkedPosition,
				:LastItem, :LastWalkedItem,
				:Default
			]) > 0 )

			StzRaise("Incorrect param! pReturn must be a string. Allowed values are " +
				 ":WalkedPositions, :WalkedItems, :LastWalkedPosition, :LastWalkedItem, and :Default." )
		ok

		if pReturn = :Default
			pReturn = :WalkedPositions
		ok

		# Doing the job

		_aList_ = This.List()
		_nLen_ = len(_aList_)

		if pnForward = pnBackward
			return []
		ok

		if pnForward > pnBackward
			_nStart_ = _nLen_ - pnBackward
		else
			_nStart_ = _nLen_
		ok

		_i_ = _nStart_
		_anPos_ = [ _nStart_ ]

		while ( (_i_ - pnBackward) >= 1 and (_i_ - pnBackward) <= _nLen_ ) and
		      ( (_i_ - pnBackward + pnForward) >= 1 and (_i_ - pnBackward + pnForward) <= _nLen_ )

			_i_ = _i_ - pnBackward
			_anPos_ + _i_

			_i_ = _i_ + pnForward
			_anPos_ + _i_

		end

		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)

		but pReturn = :WalkedPositions
			return _anPos_

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]

		else
			return _anPos_
		end

	# Returns the positions walked n items backwards, then n items forwards.
	#
	#   pnBackward   how many items back
	#   pnForward    how many items forward
	#   returns      a list of positions
	#   see          WalkNItemsForwardNItemsBackward
		#< @FunctionAlternativeForm
	def WalkNItemsBackwardNItemsForward(pnBackward, pnForward)
		return This.WalkNItemsBackwardNItemsForwardXT(pnBackward, pnForward, :Return = :WalkedPositions)

		#< @FunctionAlternativeForm


	def WalkNItemsFromStartNItemsFromEndXT(pnFromStart, pnFromEnd, pReturn)

		# Checking params

		if NOT Q([pnFromStart, pnFromEnd]).BothAreNumbers()
			StzRaise("Incorrect param type! Both pnFromStart and pnFromEnd must be numbers.")
		ok

		if isList(pReturn) and
		   IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])

			pReturn = pReturn[2]
		ok

		if NOT ( isString(pReturn) and

			 StzFindFirst(pReturn, [
				:WalkedPositions, :WalkedItems,
				:LastPosition, :LastWalkedPosition,
				:LastItem, :LastWalkedItem,
				:Default
			]) > 0 )

			StzRaise("Incorrect param! pReturn must be a string. Allowed values are " +
				 ":WalkedPositions, :WalkedItems, :LastWalkedPosition, :LastWalkedItem, and :Default." )
		ok

		if pReturn = :Default
			pReturn = :WalkedPositions
		ok

		# Doing the job

		_aList_ = This.List()
		_nLen_ = len(_aList_)

		_anPos_ = [ 1 ]

		for _i_ = 1 to _nLen_
			_nPosFromStart_ = _i_ + pnFromStart
			_nPosFromEnd_   = _nLen_ - _i_ - pnFromEnd + 1

			if _nPosFromEnd_ >= _nPosFromStart_
				_anPos_ + _nPosFromStart_
				if _nPosFromEnd_ != _nPosFromStart_
					_anPos_ + _nPosFromEnd_
				ok
			ok
		next

		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)

		but pReturn = :WalkedPositions
			return _anPos_

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]

		else
			return _anPos_
		end
	
	# Returns the positions walked from the start and from the end, the given number of items each way.
	#
	#   nFromStart   how many items from the start
	#   nFromEnd     how many items from the end
	#   returns      a list of positions
	#   see          WalkNItemsFromEndNItemsFromStart
		#< @FunctionAlternativeForm
	def WalkNItemsFromStartNItemsFromEnd(nFromStart, nFromEnd)
		return This.WalkNItemsFromStartNItemsFromEndXT(nFromStart, nFromEnd, :Return = :WalkedPositions)

		#< @FunctionAlternativeForm


	def WalkNItemsFromEndNItemsFromStartXT(pnFromEnd, pnFromStart, pReturn)

		# Checking params

		if NOT Q([ pnFromEnd, pnFromStart ]).BothAreNumbers()
			StzRaise("Incorrect param type! Both pnFromStart and pnFromEnd must be numbers.")
		ok

		if isList(pReturn) and
		   IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])

			pReturn = pReturn[2]
		ok

		if NOT ( isString(pReturn) and

			 StzFindFirst(pReturn, [
				:WalkedPositions, :WalkedItems,
				:LastPosition, :LastWalkedPosition,
				:LastItem, :LastWalkedItem,
				:Default
			]) > 0 )

			StzRaise("Incorrect param! pReturn must be a string. Allowed values are " +
				 ":WalkedPositions, :WalkedItems, :LastWalkedPosition, :LastWalkedItem, and :Default." )
		ok

		if pReturn = :Default
			pReturn = :WalkedPositions
		ok

		# Doing the job

		_aList_ = This.List()
		_nLen_ = len(_aList_)

		_anPos_ = [ _nLen_ ]

		for _i_ = _nLen_ to 1 step -1

			_nPosFromEnd_   = _i_ - pnFromEnd
			_nPosFromStart_ = _nLen_ - _i_ + 1

			if _nPosFromEnd_ >= _nPosFromStart_
				_anPos_ + _nPosFromEnd_
				
				if _nPosFromStart_ != _nPosFromEnd_
					_anPos_ + _nPosFromStart_
				ok
			ok
		next

		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)

		but pReturn = :WalkedPositions
			return _anPos_

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]

		else
			return _anPos_
		end

	# Returns the positions walked from the end and from the start, the given number of items each way.
	#
	#   pnFromEnd     how many items from the end
	#   pnFromStart   how many items from the start
	#   returns       a list of positions
	#   see           WalkNItemsFromStartNItemsFromEnd
		#< @FunctionAlternativeForm
	def WalkNItemsFromEndNItemsFromStart(pnFromEnd, pnFromStart)
		return This.WalkNItemsFromEndNItemsFromStartXT(pnFromEnd, pnFromStart, :Return = :WalkedPositions)

		#< @FunctionAlternativeForm


		def WalkForwardBackward(pnForward, pnBackward)
			return This.WalkNITemsForwardNItemsBackward(pnForward, pnBackward)

		#>


		def WalkForwardBackwardXT(pnForward, pnBackward, pReturn)
			return This.WalkNITemsForwardNItemsBackwardXT(pnForward, pnBackward, pReturn)

		#>

	  #------------------------------------------------#
	 #  WALKING N ITEMS FORWARD AND N ITEMS BACKWARD  #
	#------------------------------------------------#


		def WalkBackwardForward(pnForward, pnBackward)
			return This.WalkNItemsBackwardNItemsForward(pnForward, pnBackward)

		#>


		def WalkBackwardForwardXT(pnBackward, pnForward, pReturn)
			return This.WalkNItemsBackwardNItemsForwardXT(pnBackward, pnForward, pReturn)

		#>

	  #===================================================#
	 #  WALKING N STEPS FROM START AND N STEPS FROM END  #
	#===================================================#


		def WalkNStartNEnd(pnFromStart, pnFromEnd)
			return This.WalkNITemsFromStartNItemsFromEnd(pnFromStart, pnFromEnd)


		def WalkNStartNEndXT(pnFromStart, pnFromEnd, pReturn)
			return This.WalkNITemsFromStartNItemsFromEndXT(pnFromStart, pnFromEnd, pReturn)


		def WalkNEndNStart(pnFromStart, pnFromEnd)
			return This.WalkNItemsFromEndNItemsFromStart(pnFromStart, pnFromEnd)


		def WalkNEndNStartXT(pnFromEnd, pnFromStart, pReturn)
			return This.WalkNItemsFromEndNItemsFromStartXT(pnFromEnd, pnFromStart, pReturn)


