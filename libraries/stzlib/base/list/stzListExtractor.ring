#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTEXTRACTOR           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List extractor subclass -- extract (remove #
#                  and return) items by value, position, or   #
#                  condition. For aliases, use                 #
#                  stzListExtractorXT.                          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Takes items out of a list and hands them back: by position, by section, by occurrence, the repeats, or all the texts, numbers or sublists.
#
# It is the extracting helper of stzList, which builds one over itself for its Extract, ExtractAll,
# ExtractNth, ExtractSection and ExtractRange methods; build one with new stzListExtractor when you
# only need to take things out. It works on its own copy, so a stzList passed in is never changed,
# and what is left is read with Content. Every Extract method does two things at once: it removes
# the items from the held list and returns them, the items that were taken out being the answer.
# Extract(pItem) removes every occurrence, while ExtractNthOccurrence, ExtractFirstOccurrence and
# ExtractLastOccurrence remove just one. A position outside the list raises (ExtractNth,
# ExtractFirst, ExtractLast, ExtractSection, ExtractRange, Take, TakeLast), except the occurrence
# methods, which answer an empty text when there is no such occurrence. Positions count from 1; the
# CS forms take 0 to ignore case. Hebrew, Arabic and emoji items are extracted like any other text.
#
#   receiver   o1 = new stzListExtractor([ "a", "b", "c", "b", "d", "e" ])
#   example    ? o1.ExtractNth(3)
#              #--> c
#              ? @@( o1.Content() )
#              #--> [ "a", "b", "b", "d", "e" ]
#              ? @@( o1.ExtractSection(2, 3) )
#              #--> [ "b", "b" ]
#              ? @@( o1.Content() )
#              #--> [ "a", "d", "e" ]
#              o2 = new stzListExtractor([ "a", "b", "a", "c", "b", "a" ])
#              ? @@( o2.ExtractDuplicates() )
#              #--> [ "a", "b", "a" ]
#              ? @@( o2.Content() )
#              #--> [ "a", "b", "c" ]
#              o3 = new stzListExtractor([ 1, "a", [ 1, 2 ], 2, "שלום" ])
#              ? @@( o3.ExtractStrings() )
#              #--> [ "a", "שלום" ]
#   see        stzList, stzListRemover, stzListGetter
class stzListExtractor from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds an extractor over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to take items out of, or a stzList whose content is copied, any other
	#                value raises an error
	#   returns      nothing; the object is built
	#   note         the extractor works on its own copy: taking items out never changes the list or
	#                the stzList you passed in, so read what is left with Content
	#   see          Content, ExtractFirst
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListExtractor! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the items still in the list, after the extractions made so far.
	#
	#   returns    a list
	#   see        List, ExtractAll
	def Content()
		return @oList.Content()

	# Returns the items still in the list, after the extractions made so far.
	#
	#   returns    a list
	#   note       the same answer as Content
	#   see        Content, NumberOfItems
	def List()
		return @oList.List()

	# Returns how many items are still in the list.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if no item is left in the list.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfItems, Content
	def IsEmpty()
		return @oList.IsEmpty()

	def ExtractCS(pItem, pCaseSensitive)
		if NOT @oList.ContainsCS(pItem, pCaseSensitive)
			StzRaise("Can't extract the item! It does not exist in the list.")
		ok
		@oList.RemoveCS(pItem, pCaseSensitive)
		return pItem

	# Takes an item out of the list and returns it, removing every occurrence of it.
	#
	#   pItem      the item to take out
	#   returns    the item that was taken out
	#   note       case counts: ExtractCS(pItem, 0) ignores case; ExtractMany(paItems) does the same
	#              for several items and returns the list it was given
	#   warning    an item that is absent raises Can't extract the item! It does not exist in the
	#              list; it removes all the occurrences and not just one: a b c b d e loses both b
	#   see        ExtractNthOccurrence, ExtractFirstOccurrence, ExtractNth
	def Extract(pItem)
		return This.ExtractCS(pItem, 1)

	def ExtractManyCS(paItems, pCaseSensitive)
		_anPos_ = @oList.FindManyCS(paItems, pCaseSensitive)
		@oList.RemoveItemsAtPositions(_anPos_)
		return paItems

	def ExtractMany(paItems)
		return This.ExtractManyCS(paItems, 1)

	# Takes every item out of the list and returns them, leaving it empty.
	#
	#   returns    a list, the items that were in the list
	#   see        Take, Content
	def ExtractAll()
		_aResult_ = This.Content()
		@oList.RemoveAllItems()
		return _aResult_

	# Takes out the item at a position, counting from 1, and returns it.
	#
	#   n          the position of the item to take out
	#   returns    the item that was taken out
	#   note       the list closes up over the gap
	#   warning    a position outside the list raises Index outside the list! naming the position
	#              and the size
	#   see        ExtractFirst, ExtractLast, ExtractSection
	def ExtractNth(n)
		# Was `ring_remove(This.List(), n)` -- This.List() returns a list
		# value, not a mutable reference into @oList.@aContent, so the
		# removal didn't persist. Use the proper @oList.RemoveItemAtPosition
		# which goes through UpdateWith and persists.
		pItem = @oList.NthItem(n)
		@oList.RemoveItemAtPosition(n)
		return pItem

	# Takes out the first item of the list and returns it.
	#
	#   returns    the item that was taken out
	#   note       PopFirst is the same call
	#   warning    on an empty list it raises Index outside the list!
	#   see        ExtractLast, ExtractNth
	def ExtractFirst()
		return This.ExtractNth(1)

	# Takes out the last item of the list and returns it.
	#
	#   returns    the item that was taken out
	#   note       Pop is the same call
	#   warning    on an empty list it raises Index outside the list!
	#   see        ExtractFirst, ExtractNth
	def ExtractLast()
		return This.ExtractNth(This.NumberOfItems())

	# Takes out the items from one position to another, both included, and returns them.
	#
	#   n1         the first position
	#   n2         the last position
	#   returns    a list, the items that were taken out
	#   note       the items that stay close up over the gap
	#   warning    a position outside the list raises Indexes out of range!, where Section of
	#              stzListGetter would clip
	#   see        ExtractRange, Take, ExtractNth
	def ExtractSection(n1, n2)
		_aResult_ = @oList.Section(n1, n2)
		@oList.RemoveSection(n1, n2)
		return _aResult_

	# Takes out a run of items given its first position and how many items it holds, and returns them.
	#
	#   pnStart    the first position
	#   pnRange    how many items to take out
	#   returns    a list, the items that were taken out
	#   warning    a run that goes past the end raises Indexes out of range! (ExtractRange(2, 9) on
	#              three items) instead of being cut at the end
	#   see        ExtractSection, Take
	def ExtractRange(pnStart, pnRange)
		_aResult_ = @oList.Range(pnStart, pnRange)
		@oList.RemoveRange(pnStart, pnRange)
		return _aResult_

	def ExtractW(pcCondition)
		_anPos_ = @oList.FindW(pcCondition)
		_aResult_ = @oList.ItemsAtPositions(_anPos_)
		@oList.RemoveItemsAtPositions(_anPos_)
		return _aResult_

	  #======================================================#
	 #   EXTRACT NTH OCCURRENCE                             #
	#======================================================#

	def ExtractNthOccurrenceCS(n, pItem, pCaseSensitive)
		_nPos_ = @oList.FindNthCS(n, pItem, pCaseSensitive)
		if _nPos_ = 0
			return ""
		ok
		return This.ExtractNth(_nPos_)

	# Takes out the nth occurrence of an item, leaving its other occurrences, and returns it.
	#
	#   n          which occurrence to take out, counting from 1
	#   pItem      the item to look for
	#   returns    the item that was taken out, or an empty text when there is no nth occurrence
	#   note       an empty text from a missing occurrence cannot be told from an item that is an
	#              empty text; ExtractNthOccurrenceCS(n, pItem, 0) ignores case and returns the item
	#              as it is spelt in the list
	#   see        ExtractFirstOccurrence, ExtractLastOccurrence, Extract
	def ExtractNthOccurrence(n, pItem)
		return This.ExtractNthOccurrenceCS(n, pItem, 1)

	  #======================================================#
	 #   EXTRACT FIRST / LAST OCCURRENCE                    #
	#======================================================#

	def ExtractFirstOccurrenceCS(pItem, pCaseSensitive)
		return This.ExtractNthOccurrenceCS(1, pItem, pCaseSensitive)

	# Takes out the first occurrence of an item, leaving the others, and returns it.
	#
	#   pItem      the item to look for
	#   returns    the item that was taken out, or an empty text when it is absent
	#   note       ExtractFirstOccurrenceCS(pItem, 0) ignores case and returns the item as it is
	#              spelt in the list
	#   see        ExtractLastOccurrence, ExtractNthOccurrence
	def ExtractFirstOccurrence(pItem)
		return This.ExtractFirstOccurrenceCS(pItem, 1)

	def ExtractLastOccurrenceCS(pItem, pCaseSensitive)
		_nPos_ = @oList.FindLastCS(pItem, pCaseSensitive)
		if _nPos_ = 0
			return ""
		ok
		return This.ExtractNth(_nPos_)

	# Takes out the last occurrence of an item, leaving the others, and returns it.
	#
	#   pItem      the item to look for
	#   returns    the item that was taken out, or an empty text when it is absent
	#   note       ExtractLastOccurrenceCS(pItem, 0) ignores case and returns the item as it is
	#              spelt in the list
	#   see        ExtractFirstOccurrence, ExtractNthOccurrence
	def ExtractLastOccurrence(pItem)
		return This.ExtractLastOccurrenceCS(pItem, 1)

	  #======================================================#
	 #   EXTRACT DUPLICATES                                 #
	#======================================================#

	def ExtractDuplicatesCS(pCaseSensitive)
		_pEdList_ = @oList._EngineListFromContent()
		# Engine returns a ready list of 1-based positions (built Zig-side).
		_anEdDupPos_ = StzEngineListFindDuplicatesCS(_pEdList_, pCaseSensitive)
		StzEngineListFree(_pEdList_)

		_nEdLen_ = len(_anEdDupPos_)
		if _nEdLen_ = 0
			return []
		ok

		_aEdContent_ = This.Content()
		_aEdDups_ = []
		for _jEd_ = 1 to _nEdLen_
			@AddItem(_aEdDups_, _aEdContent_[_anEdDupPos_[_jEd_]])
		next

		for _kEd_ = _nEdLen_ to 1 step -1
			@oList.RemoveItemAtPosition(_anEdDupPos_[_kEd_])
		next

		return _aEdDups_

	# Takes out every repeat, that is each occurrence after the first of its item, and returns them.
	#
	#   returns    a list, the repeats that were taken out; [ ] when nothing repeats
	#   note       the first occurrence of each item stays: a b a c b a gives a b a and leaves a b
	#              c; case counts, and ExtractDuplicatesCS(0) also treats a and A as one item
	#   see        ExtractNthOccurrence, Extract
	def ExtractDuplicates()
		return This.ExtractDuplicatesCS(1)

	  #======================================================#
	 #   EXTRACT ITEMS OF TYPE                              #
	#======================================================#

	# Takes out every item that is a text and returns them, in their order.
	#
	#   returns    a list, the texts that were taken out
	#   note       the other items stay in their order
	#   see        ExtractNumbers, ExtractLists
	def ExtractStrings()
		# Collect forward to preserve order, then remove in reverse pass
		# to keep indices valid. `ring_remove(This.List(), ...)` was a
		# no-op (List() returns a copy), and ListReversed wasnt defined.
		_aEsContent_ = This.Content()
		_nEsLen_ = len(_aEsContent_)
		_aEsResult_ = []
		_anEsPos_ = []
		for _iEs_ = 1 to _nEsLen_
			if isString(_aEsContent_[_iEs_])
				@AddItem(_aEsResult_, _aEsContent_[_iEs_])
				@AddItem(_anEsPos_, _iEs_)
			ok
		next
		for _jEs_ = len(_anEsPos_) to 1 step -1
			@oList.RemoveItemAtPosition(_anEsPos_[_jEs_])
		next
		return _aEsResult_

	# Takes out every item that is a number and returns them, in their order.
	#
	#   returns    a list, the numbers that were taken out
	#   note       the other items stay in their order
	#   see        ExtractStrings, ExtractLists
	def ExtractNumbers()
		_aEnContent_ = This.Content()
		_nEnLen_ = len(_aEnContent_)
		_aEnResult_ = []
		_anEnPos_ = []
		for _iEn_ = 1 to _nEnLen_
			if isNumber(_aEnContent_[_iEn_])
				@AddItem(_aEnResult_, _aEnContent_[_iEn_])
				@AddItem(_anEnPos_, _iEn_)
			ok
		next
		for _jEn_ = len(_anEnPos_) to 1 step -1
			@oList.RemoveItemAtPosition(_anEnPos_[_jEn_])
		next
		return _aEnResult_

	# Takes out every item that is a list and returns them, in their order.
	#
	#   returns    a list, the sublists that were taken out
	#   note       the other items stay in their order
	#   see        ExtractStrings, ExtractNumbers
	def ExtractLists()
		_aElContent_ = This.Content()
		_nElLen_ = len(_aElContent_)
		_aElResult_ = []
		_anElPos_ = []
		for _iEl_ = 1 to _nElLen_
			if isList(_aElContent_[_iEl_])
				@AddItem(_aElResult_, _aElContent_[_iEl_])
				@AddItem(_anElPos_, _iEl_)
			ok
		next
		for _jEl_ = len(_anElPos_) to 1 step -1
			@oList.RemoveItemAtPosition(_anElPos_[_jEl_])
		next
		return _aElResult_

	  #======================================================#
	 #   POP -- EXTRACT LAST (STACK STYLE)                  #
	#======================================================#

	def Pop()
		return This.ExtractLast()

	def PopFirst()
		return This.ExtractFirst()

	  #======================================================#
	 #   TAKE -- EXTRACT N FROM START                       #
	#======================================================#

	# Takes out the first n items and returns them.
	#
	#   n          how many items to take from the start
	#   returns    a list, the items that were taken out
	#   note       an n of 0 or larger than the list raises Indexes out of range!
	#   see        TakeLast, ExtractSection
	def Take(n)
		return This.ExtractSection(1, n)

	# Takes out the last n items and returns them.
	#
	#   n          how many items to take from the end
	#   returns    a list, the items that were taken out
	#   note       an n of 0 or larger than the list raises Indexes out of range!
	#   see        Take, ExtractSection
	def TakeLast(n)
		_nLen_ = This.NumberOfItems()
		return This.ExtractSection(_nLen_ - n + 1, _nLen_)
