#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTLEADTRAIL           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List lead/trail subclass -- repeated       #
#                  leading and trailing item operations.       #
#                  For aliases, use stzListLeadTrailXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Examines and trims the repeated items at the beginning and at the end of a list, and tests what a list starts or ends with.
#
# A run is two or more equal items in a row at an end of the list; a single item is not a run. Build
# one with new stzListLeadTrail(aList) or over a stzList object; it keeps its own copy, so what you
# passed in is not changed, and Content gives the trimmed list. The remove methods keep one item of
# the run, never none. Every comparison is case-sensitive; the CS forms (RepeatedLeadingItemsCS,
# RemoveRepeatedTrailingItemsCS, StartsWithCS ...) take 0 to ignore case, and they honour it.
#
#   receiver   o1 = new stzListLeadTrail([ "a", "a", "b", "c", "c", "c" ])
#   example    ? @@( o1.RepeatedLeadingItems() )
#              #--> [ "a", "a" ]
#              ? o1.NumberOfRepeatedTrailingItems()
#              #--> 3
#              o1.RemoveRepeatedLeadingAndTrailingItems()
#              ? @@( o1.Content() )
#              #--> [ "a", "b", "c" ]
#              ? o1.StartsWith("a")
#              #--> 1
#   see        stzList, stzListTrimmer, stzListDuplicates
class stzListLeadTrail from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a lead-and-trail helper over a list or over a stzList object, working on its own copy, so the list passed in is never changed.
	#
	#   pListOrObj   a list, or a stzList object, whose beginning and end are examined
	#   returns      nothing; the object is built
	#   warning      any other kind of value raises "Can't create stzListLeadTrail! Parameter must
	#                be a list or stzList object."
	#   see          Content
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListLeadTrail! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the items the helper holds, after any removal made through it.
	#
	#   returns    a list
	#   see        NumberOfItems
	def Content()
		return @oList.Content()

	# Returns how many items the list holds now.
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

	# TRUE if the list starts with a repeated run of the same item.
	def HasRepeatedLeadingItemsCS(pCaseSensitive)
		_aLead_ = This.RepeatedLeadingItemsCS(pCaseSensitive)
		if len(_aLead_) > 0
			return 1
		else
			return 0
		ok

	# TRUE if the list begins with a run of two or more equal items, compared case-sensitively.
	#
	#   returns    TRUE or FALSE
	#   note       HasRepeatedLeadingItemsCS(0) ignores case: a a A counts as a run
	#   see        HasRepeatedLeadingItemsCS, RepeatedLeadingItems
	def HasRepeatedLeadingItems()
		return This.HasRepeatedLeadingItemsCS(1)

	# The repeated run at the START of the list, as a list.
	def RepeatedLeadingItemsCS(pCaseSensitive)
		_pLtList = @oList._EngineListFromContent()
		if _pLtList != ""
			_nCsLt = 1
			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				_nCsLt = pCaseSensitive[2]
			but isNumber(pCaseSensitive)
				_nCsLt = pCaseSensitive
			ok
			_nCount = StzEngineListLeadingCountCS(_pLtList, _nCsLt)
			StzEngineListFree(_pLtList)
			if _nCount < 2
				return []
			ok
			_aContent_ = This.Content()
			_aResult_ = []
			for i = 1 to _nCount
				_aResult_ + _aContent_[i]
			next
			return _aResult_
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		if _nLen_ < 2
			return []
		ok
		_aResult_ = []
		_firstItem_ = _aContent_[1]
		for i = 1 to _nLen_
			if BothAreEqualCS(_aContent_[i], _firstItem_, pCaseSensitive)
				_aResult_ + _aContent_[i]
			else
				exit
			ok
		next
		if len(_aResult_) < 2
			return []
		ok
		return _aResult_

	# Returns the run of equal items that opens the list, all of them; [ ] when the list does not open with a run of two or more.
	#
	#   returns    a list; [ ] when there is no run
	#   note       a single first item is not a run; RepeatedLeadingItemsCS(0) ignores case, so a a
	#              A gives all three
	#   see        RepeatedLeadingItem, NumberOfRepeatedLeadingItems
	def RepeatedLeadingItems()
		return This.RepeatedLeadingItemsCS(1)

	# The item repeated at the start of the list.
	def RepeatedLeadingItemCS(pCaseSensitive)
		_aLead_ = This.RepeatedLeadingItemsCS(pCaseSensitive)
		if len(_aLead_) > 0
			return _aLead_[1]
		else
			return ""
		ok

	# Returns the item that opens the list in a run of two or more, or an empty text when none does.
	#
	#   returns    an item; "" when the list opens with no run
	#   note       "" is also what a list of empty texts would answer, so test
	#              HasRepeatedLeadingItems first
	#   see        RepeatedLeadingItems
	def RepeatedLeadingItem()
		return This.RepeatedLeadingItemCS(1)

	# How long the repeated run at the start of the list is.
	def NumberOfRepeatedLeadingItemsCS(pCaseSensitive)
		return len(This.RepeatedLeadingItemsCS(pCaseSensitive))

	# Returns how long the run of equal items at the start of the list is; 0 when there is none.
	#
	#   returns    a number
	#   note       a run of 1 is not counted: a b c answers 0, not 1
	#   see        RepeatedLeadingItems
	def NumberOfRepeatedLeadingItems()
		return This.NumberOfRepeatedLeadingItemsCS(1)

	# TRUE if the list ends with a repeated run of the same item.
	def HasRepeatedTrailingItemsCS(pCaseSensitive)
		_aTrail_ = This.RepeatedTrailingItemsCS(pCaseSensitive)
		if len(_aTrail_) > 0
			return 1
		else
			return 0
		ok

	# TRUE if the list ends with a run of two or more equal items, compared case-sensitively.
	#
	#   returns    TRUE or FALSE
	#   note       HasRepeatedTrailingItemsCS(0) ignores case: c c C counts as a run
	#   see        HasRepeatedTrailingItemsCS, RepeatedTrailingItems
	def HasRepeatedTrailingItems()
		return This.HasRepeatedTrailingItemsCS(1)

	# The repeated run at the END of the list, as a list.
	def RepeatedTrailingItemsCS(pCaseSensitive)
		_pLtList2 = @oList._EngineListFromContent()
		if _pLtList2 != ""
			_nCsLt2 = 1
			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				_nCsLt2 = pCaseSensitive[2]
			but isNumber(pCaseSensitive)
				_nCsLt2 = pCaseSensitive
			ok
			_nCount2 = StzEngineListTrailingCountCS(_pLtList2, _nCsLt2)
			StzEngineListFree(_pLtList2)
			if _nCount2 < 2
				return []
			ok
			_aContent_ = This.Content()
			_nLen_ = len(_aContent_)
			_aResult_ = []
			for i = _nLen_ - _nCount2 + 1 to _nLen_
				_aResult_ + _aContent_[i]
			next
			return _aResult_
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		if _nLen_ < 2
			return []
		ok
		_aResult_ = []
		_lastItem_ = _aContent_[_nLen_]
		for i = _nLen_ to 1 step -1
			if BothAreEqualCS(_aContent_[i], _lastItem_, pCaseSensitive)
				_aResult_ + _aContent_[i]
			else
				exit
			ok
		next
		if len(_aResult_) < 2
			return []
		ok
		return ListReversed(_aResult_)

	# Returns the run of equal items that closes the list, all of them; [ ] when the list does not end with a run of two or more.
	#
	#   returns    a list; [ ] when there is no run
	#   note       a single last item is not a run; RepeatedTrailingItemsCS(0) ignores case
	#   see        RepeatedTrailingItem, NumberOfRepeatedTrailingItems
	def RepeatedTrailingItems()
		return This.RepeatedTrailingItemsCS(1)

	# The item repeated at the end of the list.
	def RepeatedTrailingItemCS(pCaseSensitive)
		_aTrail_ = This.RepeatedTrailingItemsCS(pCaseSensitive)
		if len(_aTrail_) > 0
			return _aTrail_[1]
		else
			return ""
		ok

	# Returns the item whose repeated run closes the list, the case counting.
	#
	#   returns    an item; an empty text when the list ends with no repeated run
	#   see        RepeatedTrailingItemCS, RepeatedLeadingItem, NumberOfRepeatedTrailingItems
	def RepeatedTrailingItem()
		return This.RepeatedTrailingItemCS(1)

	# How long the repeated run at the end of the list is.
	def NumberOfRepeatedTrailingItemsCS(pCaseSensitive)
		return len(This.RepeatedTrailingItemsCS(pCaseSensitive))

	# Returns how long the repeated run that closes the list is, the case counting.
	#
	#   returns    a number, the length of the run RepeatedTrailingItems answers
	#   see        NumberOfRepeatedTrailingItemsCS, NumberOfRepeatedLeadingItems
	def NumberOfRepeatedTrailingItems()
		return This.NumberOfRepeatedTrailingItemsCS(1)

	def RemoveRepeatedLeadingItemsCS(pCaseSensitive)
		_pLtRm = @oList._EngineListFromContent()
		if _pLtRm != ""
			_nCsLtRm = 1
			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				_nCsLtRm = pCaseSensitive[2]
			but isNumber(pCaseSensitive)
				_nCsLtRm = pCaseSensitive
			ok
			StzEngineListRemoveLeadingCS(_pLtRm, _nCsLtRm)
			@oList.UpdateWith(@oList._ContentFromEngineList(_pLtRm))
			StzEngineListFree(_pLtRm)
			return
		ok

		_aLead_ = This.RepeatedLeadingItemsCS(pCaseSensitive)
		_nToRemove_ = len(_aLead_) - 1
		if _nToRemove_ > 0
			@oList.RemoveSection(1, _nToRemove_)
		ok

	# Shortens the run of equal items at the start of the list to one item, in place.
	#
	#   returns    nothing; use RemoveRepeatedLeadingItemsQ to chain
	#   note       the run stays one item, not none: 1 1 1 2 becomes 1 2; the list given to init is
	#              untouched
	#   see        RepeatedLeadingItemsRemoved, RemoveRepeatedTrailingItems
	def RemoveRepeatedLeadingItems()
		This.RemoveRepeatedLeadingItemsCS(1)

	def RemoveRepeatedTrailingItemsCS(pCaseSensitive)
		_pLtRm2 = @oList._EngineListFromContent()
		if _pLtRm2 != ""
			_nCsLtRm2 = 1
			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				_nCsLtRm2 = pCaseSensitive[2]
			but isNumber(pCaseSensitive)
				_nCsLtRm2 = pCaseSensitive
			ok
			StzEngineListRemoveTrailingCS(_pLtRm2, _nCsLtRm2)
			@oList.UpdateWith(@oList._ContentFromEngineList(_pLtRm2))
			StzEngineListFree(_pLtRm2)
			return
		ok

		_aTrail_ = This.RepeatedTrailingItemsCS(pCaseSensitive)
		_nToRemove_ = len(_aTrail_) - 1
		_nLen_ = This.NumberOfItems()
		if _nToRemove_ > 0
			@oList.RemoveSection(_nLen_ - _nToRemove_ + 1, _nLen_)
		ok

	# Shortens the run of equal items at the end of the list to one item, in place.
	#
	#   returns    nothing; use RemoveRepeatedTrailingItemsQ to chain
	#   note       the run stays one item, not none: 3 3 3 becomes 3
	#   see        RepeatedTrailingItemsRemoved, RemoveRepeatedLeadingItems
	def RemoveRepeatedTrailingItems()
		This.RemoveRepeatedTrailingItemsCS(1)

	def RemoveRepeatedLeadingAndTrailingItemsCS(pCaseSensitive)
		This.RemoveRepeatedLeadingItemsCS(pCaseSensitive)
		This.RemoveRepeatedTrailingItemsCS(pCaseSensitive)

		def RemoveRepeatedLeadingAndTrailingItemsCSQ(pCaseSensitive)
			This.RemoveRepeatedLeadingAndTrailingItemsCS(pCaseSensitive)
			return This

	# Shortens both the opening run and the closing run to one item each, in place.
	#
	#   returns    nothing; use RemoveRepeatedLeadingAndTrailingItemsQ to chain
	#   note       a list made only of one repeated item, 4 4 4, ends up as 4
	#   see        RemoveRepeatedLeadingItems, RemoveRepeatedTrailingItems
	def RemoveRepeatedLeadingAndTrailingItems()
		This.RemoveRepeatedLeadingAndTrailingItemsCS(1)

		def RemoveRepeatedLeadingAndTrailingItemsQ()
			This.RemoveRepeatedLeadingAndTrailingItems()
			return This

	  #======================================================#
	 #   Q VARIANTS FOR REMOVE LEADING/TRAILING             #
	#======================================================#

	def RemoveRepeatedLeadingItemsCSQ(pCaseSensitive)
		This.RemoveRepeatedLeadingItemsCS(pCaseSensitive)
		return This

	def RemoveRepeatedLeadingItemsQ()
		This.RemoveRepeatedLeadingItems()
		return This

	def RemoveRepeatedTrailingItemsCSQ(pCaseSensitive)
		This.RemoveRepeatedTrailingItemsCS(pCaseSensitive)
		return This

	def RemoveRepeatedTrailingItemsQ()
		This.RemoveRepeatedTrailingItems()
		return This

	  #======================================================#
	 #   PASSIVE FORMS                                      #
	#======================================================#

	def RepeatedLeadingItemsRemovedCS(pCaseSensitive)
		# Was @oList.Copy().RemoveRepeatedLeadingItemsCSQ -- not on core stzList
		_o = new stzListLeadTrail(@oList.Content())
		_o.RemoveRepeatedLeadingItemsCS(pCaseSensitive)
		return _o.Content()

	# Returns a copy of the list with the opening run shortened to one item, leaving the object unchanged.
	#
	#   returns    a list
	#   see        RemoveRepeatedLeadingItems
	def RepeatedLeadingItemsRemoved()
		return This.RepeatedLeadingItemsRemovedCS(1)

	def RepeatedTrailingItemsRemovedCS(pCaseSensitive)
		# Was @oList.Copy().RemoveRepeatedTrailingItemsCSQ -- not on core stzList
		_o = new stzListLeadTrail(@oList.Content())
		_o.RemoveRepeatedTrailingItemsCS(pCaseSensitive)
		return _o.Content()

	# Returns a copy of the list with the closing run shortened to one item, leaving the object unchanged.
	#
	#   returns    a list
	#   see        RemoveRepeatedTrailingItems
	def RepeatedTrailingItemsRemoved()
		return This.RepeatedTrailingItemsRemovedCS(1)

	  #======================================================#
	 #   STARTS WITH / ENDS WITH                            #
	#======================================================#

	def StartsWithCS(pItem, pCaseSensitive)
		# Single-value first-item compare: O(1) in Ring, so no engine
		# round-trip (the value-handle/list-handle live in separate
		# per-module handle tables and don't cross). The prefix-LIST
		# variant (StartsWithListCS) is what's worth engine-backing.
		if This.NumberOfItems() = 0
			return 0
		ok
		_nCsSw = 1
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			_nCsSw = pCaseSensitive[2]
		but isNumber(pCaseSensitive)
			_nCsSw = pCaseSensitive
		ok
		if BothAreEqualCS(@oList.List()[1], pItem, _nCsSw)
			return 1
		ok
		return 0

	# TRUE if the first item equals the given item, compared case-sensitively.
	#
	#   pItem      the item expected first
	#   returns    TRUE or FALSE; FALSE for an empty list
	#   note       StartsWithCS(pItem, 0) ignores case
	#   see        EndsWith, StartsWithCS
	def StartsWith(pItem)
		return This.StartsWithCS(pItem, 1)

	def EndsWithCS(pItem, pCaseSensitive)
		if This.NumberOfItems() = 0
			return 0
		ok
		_nCsEw = 1
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			_nCsEw = pCaseSensitive[2]
		but isNumber(pCaseSensitive)
			_nCsEw = pCaseSensitive
		ok
		_nLen_ = This.NumberOfItems()
		if BothAreEqualCS(@oList.List()[_nLen_], pItem, _nCsEw)
			return 1
		ok
		return 0

	# TRUE if the last item equals the given item, compared case-sensitively.
	#
	#   pItem      the item expected last
	#   returns    TRUE or FALSE; FALSE for an empty list
	#   note       EndsWithCS(pItem, 0) ignores case
	#   see        StartsWith, EndsWithCS
	def EndsWith(pItem)
		return This.EndsWithCS(pItem, 1)
