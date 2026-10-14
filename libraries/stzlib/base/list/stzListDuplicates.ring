#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTDUPLICATES          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List duplicates subclass -- finding,        #
#                  removing, counting duplicates.               #
#                  For aliases, use stzListDuplicatesXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Finds, counts and removes the repeated items of a list: positions of the repeats, items that repeat, items that never do, and the most repeated one.
#
# It is the repeats helper of stzList, which builds one over itself for its
# ContainsDuplicatedItemsCS and DuplicatedItemsCS methods; build one with new stzListDuplicates when
# you need the rest. It works on its own copy, so a stzList passed in is never changed, and you read
# the result of an in-place verb (RemoveDuplicates) with Content. A repeat is an occurrence after
# the first one of its item, so the first occurrence is never a duplicate: on a b a c b a d the
# repeats sit at positions 3, 5 and 6, and NumberOfDuplicates is 3. Every question has a CS form
# taking 1 to compare with case and 0 to ignore it. ItemsDuplicatedNTimes and MostDuplicatedItem
# give the items back as texts, so the number 3 is "3". RemoveNthDuplicate does nothing today.
# Hebrew, Arabic and emoji items repeat like any other text.
#
#   receiver   o1 = new stzListDuplicates([ "a", "b", "a", "c", "b", "a", "d" ])
#   example    ? @@( o1.FindDuplicates() )
#              #--> [ 3, 5, 6 ]
#              ? @@( o1.DuplicatedItems() )
#              #--> [ "a", "b" ]
#              ? @@( o1.NonDuplicatedItems() )
#              #--> [ "c", "d" ]
#              ? o1.MostDuplicatedItem()
#              #--> a
#              ? @@( o1.WithoutDuplication() )
#              #--> [ "a", "b", "c", "d" ]
#              o2 = new stzListDuplicates([ "a", "A", "b", "a" ])
#              ? @@( o2.FindDuplicatesCS(0) )
#              #--> [ 2, 4 ]
#              o3 = new stzListDuplicates([ "שלום", "😀", "שלום" ])
#              ? @@( o3.FindDuplicates() )
#              #--> [ 3 ]
#   see        stzList, stzListClassifier, stzListRemover
class stzListDuplicates from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a duplicates finder over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to inspect, or a stzList whose content is copied, any other value
	#                raises an error
	#   returns      nothing; the object is built
	#   note         the helper works on its own copy: editing it never changes the list or the
	#                stzList you passed in, so read the result with Content
	#   see          Content, FindDuplicates
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListDuplicates! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list as it stands now, after the in-place edits made so far.
	#
	#   returns    a list
	#   see        List, WithoutDuplication
	def Content()
		return @oList.Content()

	# Returns how many items the list holds.
	#
	#   returns    a number
	#   see        Content, NumberOfDuplicates
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfItems, Content
	def IsEmpty()
		return @oList.IsEmpty()

	# Returns a new duplicates finder over a copy of the list.
	#
	#   returns    a stzListDuplicates
	#   note       editing the copy leaves this finder alone
	#   see        Content, WithoutDuplication
	def Copy()
		return new stzListDuplicates( @oList.Content() )

	# Replaces the list held by the finder with another list.
	#
	#   paNewContent   the list that becomes the content
	#   returns        nothing; the content changes
	#   see            Content, RemoveDuplicates
	def UpdateWith(paNewContent)
		@oList.UpdateWith(paNewContent)

	# Returns the list as it stands now.
	#
	#   returns    a list
	#   note       the same answer as Content, as a copy: editing the answer does not edit the
	#              finder
	#   see        Content, UpdateWith
	def List()
		return @oList.List()

	# Deletes the item at a position, counting from 1, in place.
	#
	#   n          the position to delete, from 1
	#   returns    nothing; the content changes
	#   note       a position past the end deletes nothing
	#   see        RemoveDuplicates, UpdateWith
	def RemoveItemAtPosition(n)
		@oList.RemoveItemAtPosition(n)

	# Returns the positions of every occurrence of an item.
	#
	#   pItem            the item to look for
	#   pCaseSensitive   1 to match with case, 0 to ignore it
	#   returns          a list of numbers, [ ] when the item is absent
	#   note             the flag is required here, since there is no plain FindAll on this class
	#   see              FindDuplicates, FindDuplicatesOf
	def FindAllCS(pItem, pCaseSensitive)
		return @oList.FindAllCS(pItem, pCaseSensitive)

	  #===============================#
	 #  FINDING DUPLICATED ITEMS    #
	#===============================#

	def FindDuplicatesCS(pCaseSensitive)
		_pFdList_ = @oList._EngineListFromContent()
		# Engine returns a ready list of 1-based positions (built Zig-side).
		_anFdResult_ = StzEngineListFindDuplicatesCS(_pFdList_, pCaseSensitive)
		StzEngineListFree(_pFdList_)
		return _anFdResult_

	# Returns the positions of the repeats, that is of every occurrence after the first one of its item.
	#
	#   returns    a list of numbers, [ ] when no item repeats
	#   note       on a b a c b a d it answers 3, 5 and 6; case counts, and FindDuplicatesCS(0) also
	#              treats a and A as one item
	#   see        DuplicatedItems, NumberOfDuplicates, FindNonDuplicatedItems
	def FindDuplicates()
		return This.FindDuplicatesCS(1)

	  #===============================#
	 #  DUPLICATED ITEMS            #
	#===============================#

	def DuplicatedItemsCS(pCaseSensitive)
		# The DISTINCT values that occur more than once, in their order
		# of first appearance. FindDuplicatesCS gives 2nd+ occurrence
		# positions (engine-backed); we map each back to the value's
		# FIRST position (engine-backed FindFirstCS), dedupe by that
		# position (so nested-list items work without Ring's broken `=`),
		# then return the values at the sorted first positions.
		_anDiPos_ = This.FindDuplicatesCS(pCaseSensitive)
		_aDiContent_ = This.Content()
		_nDiLen_ = len(_anDiPos_)

		_aFirstPos_ = []
		for _iDi_ = 1 to _nDiLen_
			_nFp_ = @oList.FindFirstCS(_aDiContent_[_anDiPos_[_iDi_]], pCaseSensitive)
			_bSeen_ = 0
			_nSeenLen_ = len(_aFirstPos_)
			for _jDi_ = 1 to _nSeenLen_
				if _aFirstPos_[_jDi_] = _nFp_
					_bSeen_ = 1
					exit
				ok
			next
			if _bSeen_ = 0
				_aFirstPos_ + _nFp_
			ok
		next

		_aFirstPos_ = ring_sort(_aFirstPos_)

		_aDiResult_ = []
		_nResLen_ = len(_aFirstPos_)
		for _kDi_ = 1 to _nResLen_
			@AddItem(_aDiResult_, _aDiContent_[_aFirstPos_[_kDi_]])
		next

		return _aDiResult_

	# Returns the distinct items that occur more than once, in order of first appearance.
	#
	#   returns    a list
	#   note       each item is listed once however often it repeats; case counts, and
	#              DuplicatedItemsCS(0) also treats a and A as one item
	#   see        FindDuplicates, ItemsDuplicatedNTimes, NonDuplicatedItems
	def DuplicatedItems()
		return This.DuplicatedItemsCS(1)

	  #=====================================#
	 #  REMOVING DUPLICATES               #
	#=====================================#

	def RemoveDuplicatesCS(pCaseSensitive)
		# Engine-backed deduplication
		_pRdList_ = @oList._EngineListFromContent()
		StzEngineListRemoveDuplicatesCS(_pRdList_, pCaseSensitive)
		This.UpdateWith(@oList._ContentFromEngineList(_pRdList_))
		StzEngineListFree(_pRdList_)

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

	# Deletes every repeat from the list, keeping the first occurrence of each item, in place.
	#
	#   returns    nothing; the content changes. RemoveDuplicatesQ returns the finder for chaining
	#   note       case counts; RemoveDuplicatesCS(0) also treats a and A as one item
	#   see        WithoutDuplication, UniqueItems, FindDuplicates
	def RemoveDuplicates()
		This.RemoveDuplicatesCS(1)

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This

	  #=====================================#
	 #  WITHOUT DUPLICATION               #
	#=====================================#

	def WithoutDuplicationCS(pCaseSensitive)
		_aResult_ = This.Copy().RemoveDuplicatesCSQ(pCaseSensitive).Content()
		return _aResult_

	# Returns the list with every repeat left out, keeping the first occurrence of each item.
	#
	#   returns    a list
	#   note       the finder is left as it was; WithoutDuplicates is the same call, and
	#              WithoutDuplicationCS(0) also treats a and A as one item
	#   see        RemoveDuplicates, UniqueItems
	def WithoutDuplication()
		return This.WithoutDuplicationCS(1)

		def WithoutDuplicates()
			return This.WithoutDuplication()

	  #=================================#
	 #  HAS DUPLICATES                #
	#=================================#

	def HasDuplicatesCS(pCaseSensitive)
		_anPos_ = This.FindDuplicatesCS(pCaseSensitive)
		return len(_anPos_) > 0

	# TRUE if at least one item occurs more than once.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       ContainsDuplicates and ContainsDuplicatedItems are the same call;
	#              HasDuplicatesCS(0) ignores case
	#   see        NumberOfDuplicates, DuplicatedItems
	def HasDuplicates()
		return This.HasDuplicatesCS(1)

		def ContainsDuplicates()
			return This.HasDuplicates()

		def ContainsDuplicatedItems()
			return This.HasDuplicates()

		def ContainsDuplicatedItemsCS(pCaseSensitive)
			return This.HasDuplicatesCS(pCaseSensitive)

	  #========================================#
	 #  NUMBER OF DUPLICATES                 #
	#========================================#

	def NumberOfDuplicatesCS(pCaseSensitive)
		return len(This.FindDuplicatesCS(pCaseSensitive))

	# Returns how many repeats the list holds, counting every occurrence after the first of each item.
	#
	#   returns    a number
	#   note       a b a c b a d holds 3, not 2 duplicated items; NumberOfDuplicatesCS(0) ignores
	#              case
	#   see        FindDuplicates, HasDuplicates
	def NumberOfDuplicates()
		return This.NumberOfDuplicatesCS(1)

	  #=================================================#
	 #  FINDING DUPLICATES OF A SPECIFIC ITEM          #
	#=================================================#

	def FindDuplicatesOfCS(pItem, pCaseSensitive)
		_anFdoPos_ = This.FindAllCS(pItem, pCaseSensitive)
		_nFdoLen_ = len(_anFdoPos_)

		if _nFdoLen_ <= 1
			return []
		ok

		_aFdoResult_ = []
		for _iFdo_ = 2 to _nFdoLen_
			@AddItem(_aFdoResult_, _anFdoPos_[_iFdo_])
		next

		return _aFdoResult_

	# Returns the positions of the repeats of one item, leaving out its first occurrence.
	#
	#   pItem      the item to look for
	#   returns    a list of numbers, [ ] when the item occurs once or not at all
	#   note       on a b a c b a d it answers 3 and 6 for a; FindDuplicatesOfCS(pItem, 0) ignores
	#              case
	#   see        FindDuplicates, FindAllCS
	def FindDuplicatesOf(pItem)
		return This.FindDuplicatesOfCS(pItem, 1)

	  #=================================================#
	 #  UNIQUE ITEMS (WITHOUT DUPLICATES)              #
	#=================================================#

	def UniqueItemsCS(pCaseSensitive)
		return This.WithoutDuplicationCS(pCaseSensitive)

	# Returns the list with every repeat left out, keeping the first occurrence of each item.
	#
	#   returns    a list
	#   note       Unique is the same call, and UniqueItemsCS(0) also treats a and A as one item;
	#              not the same as NonDuplicatedItems, which drops the repeated items altogether
	#   see        WithoutDuplication, NonDuplicatedItems
	def UniqueItems()
		return This.UniqueItemsCS(1)

		def Unique()
			return This.UniqueItems()

	  #========================================#
	 #  FINDING NON DUPLICATED ITEMS         #
	#========================================#

	def FindNonDuplicatedItemsCS(pCaseSensitive)
		_pFndList_ = @oList._EngineListFromContent()
		# Engine returns a ready list of 1-based positions (built Zig-side).
		_anFndResult_ = StzEngineListFindNonDuplicatedCS(_pFndList_, pCaseSensitive)
		StzEngineListFree(_pFndList_)
		return _anFndResult_

	# Returns the positions of the items that occur exactly once.
	#
	#   returns    a list of numbers, [ ] when every item repeats
	#   note       FindNonDuplicatedItemsCS(0) ignores case, so a b A B a gives [ ]
	#   see        NonDuplicatedItems, FindDuplicates
	def FindNonDuplicatedItems()
		return This.FindNonDuplicatedItemsCS(1)

	  #========================================#
	 #  NON DUPLICATED ITEMS                 #
	#========================================#

	def NonDuplicatedItemsCS(pCaseSensitive)
		_anNdiPos_ = This.FindNonDuplicatedItemsCS(pCaseSensitive)
		_aNdiContent_ = This.Content()
		_nNdiLen_ = len(_anNdiPos_)
		_aNdiResult_ = []
		for _iNdi_ = 1 to _nNdiLen_
			@AddItem(_aNdiResult_, _aNdiContent_[_anNdiPos_[_iNdi_]])
		next
		return _aNdiResult_

	# Returns the items that occur exactly once, in their order.
	#
	#   returns    a list
	#   note       NonDuplicatedItemsCS(0) ignores case
	#   see        FindNonDuplicatedItems, DuplicatedItems, UniqueItems
	def NonDuplicatedItems()
		return This.NonDuplicatedItemsCS(1)

	  #========================================#
	 #  ITEMS DUPLICATED EXACTLY N TIMES     #
	#========================================#

	def ItemsDuplicatedNTimesCS(n, pCaseSensitive)
		_pIdnList_ = @oList._EngineListFromContent()
		_pIdnFreqs_ = StzEngineListFrequenciesCS(_pIdnList_, pCaseSensitive)
		StzEngineListFree(_pIdnList_)

		_aIdnRaw_ = StzEngineListContentToRingList(_pIdnFreqs_)
		StzEngineListFree(_pIdnFreqs_)

		_nIdnLen_ = len(_aIdnRaw_)
		_aIdnResult_ = []
		_iIdn_ = 1
		for _kIdn_ = 1 to _nIdnLen_ / 2
			_cIdnKey_ = _aIdnRaw_[_iIdn_]
			_nIdnCount_ = _aIdnRaw_[_iIdn_ + 1]
			if _nIdnCount_ = n
				@AddItem(_aIdnResult_, _cIdnKey_)
			ok
			_iIdn_ += 2
		next
		return _aIdnResult_

	# Returns the distinct items that occur exactly n times in all.
	#
	#   n          the exact number of occurrences
	#   returns    a list, the items written as texts
	#   note       the items come back as texts, so the number 3 is "3"; n = 1 gives the items that
	#              never repeat; ItemsDuplicatedNTimesCS(n, 0) ignores case
	#   see        DuplicatedItems, MostDuplicatedItem
	def ItemsDuplicatedNTimes(n)
		return This.ItemsDuplicatedNTimesCS(n, 1)

	  #========================================#
	 #  MOST DUPLICATED ITEM                 #
	#========================================#

	def MostDuplicatedItemCS(pCaseSensitive)
		_pMdiList_ = @oList._EngineListFromContent()
		_pMdiFreqs_ = StzEngineListFrequenciesCS(_pMdiList_, pCaseSensitive)
		StzEngineListFree(_pMdiList_)

		_aMdiRaw_ = StzEngineListContentToRingList(_pMdiFreqs_)
		StzEngineListFree(_pMdiFreqs_)

		_nMdiLen_ = len(_aMdiRaw_)
		_nMdiMax_ = 0
		_cMdiResult_ = ""
		_iMdi_ = 1
		for _kMdi_ = 1 to _nMdiLen_ / 2
			_cMdiKey_ = _aMdiRaw_[_iMdi_]
			_nMdiCount_ = _aMdiRaw_[_iMdi_ + 1]
			if _nMdiCount_ > _nMdiMax_
				_nMdiMax_ = _nMdiCount_
				_cMdiResult_ = _cMdiKey_
			ok
			_iMdi_ += 2
		next
		return _cMdiResult_

	# Returns the item that occurs most often.
	#
	#   returns    the item, written as a text, or an empty text for an empty list
	#   note       with a tie it answers the one that appeared first; the number 3 comes back as the
	#              text "3"; MostDuplicatedItemCS(0) ignores case
	#   see        ItemsDuplicatedNTimes, DuplicatedItems
	def MostDuplicatedItem()
		return This.MostDuplicatedItemCS(1)

	  #========================================#
	 #  REMOVE NTH DUPLICATE                 #
	#========================================#

	def RemoveNthDuplicateCS(n, pItem, pCaseSensitive)
		_anPos_ = This.FindDuplicatesOfCS(pItem, pCaseSensitive)
		if n >= 1 and n <= len(_anPos_)
			ring_remove(This.List(), _anPos_[n])
		ok

		def RemoveNthDuplicateCSQ(n, pItem, pCaseSensitive)
			This.RemoveNthDuplicateCS(n, pItem, pCaseSensitive)
			return This

	# Leaves the list unchanged today, though it is meant to delete the nth repeat of an item.
	#
	#   n          which repeat to delete, counting from 1
	#   pItem      the item whose repeat goes
	#   returns    nothing
	#   note       RemoveNthDuplicateCS(n, pItem, 0) does nothing either; use RemoveItemAtPosition
	#              with a position from FindDuplicatesOf
	#   warning    it does nothing: the list is unchanged on a b a c b a d for the first repeat of
	#              a, again on a second call, and with an n past the last repeat, because the delete
	#              is made on a copy of the list that List returns
	#   see        RemoveDuplicates, FindDuplicatesOf
	def RemoveNthDuplicate(n, pItem)
		This.RemoveNthDuplicateCS(n, pItem, 1)
