#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTREPLACER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List replacer subclass -- replacing items,  #
#                  sections, ranges, occurrences.               #
#                  For aliases, use stzListReplacerXT.          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Changes the items of a list in place: one item, every occurrence of a value, a section, or a chosen set of positions.
#
# Reach for it when you need to rewrite part of a list and keep the object: the methods act on the
# held list and return nothing, so read the result with Content. Replace by value
# (ReplaceAllOccurrences, ReplaceFirstOccurrence, ReplaceNthOccurrence), by position
# (ReplaceAnyItemAtPosition, ReplaceAnyItemAtPositions), by section (ReplaceSection puts one item,
# ReplaceSectionByMany splices several) or by a condition (ReplaceItemsW). The ...ByMany forms take
# a list of replacements: used in order, or round-robin in the XT forms. Text is compared with case,
# and a position outside the list is skipped without an error. AllOccurrencesReplaced is the one
# method that leaves the object alone and returns a changed copy.
#
#   receiver   o1 = new stzListReplacer([1, 2, 3, 2, 1])
#   example    o1.ReplaceAllOccurrences(2, 9)
#              ? @@( o1.Content() )
#              #--> [ 1, 9, 3, 9, 1 ]
#              o1.ReplaceFirstOccurrence(1, 0)
#              ? @@( o1.Content() )
#              #--> [ 0, 9, 3, 9, 1 ]
#              o1.ReplaceSectionByMany(2, 4, [7, 8])
#              ? @@( o1.Content() )
#              #--> [ 0, 7, 8, 1 ]
#   see        stzList, stzListFinder
class stzListReplacer from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a replacer over a list or over a stzList object; anything else raises an error.
	#
	#   pListOrObj   a list, or a stzList object, whose items will be changed
	#   returns      nothing; the object is built
	#   note         a list is wrapped in a new stzList; the error text is Can't create
	#                stzListReplacer! Parameter must be a list or stzList object.
	#   see          Content, NumberOfItems
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListReplacer! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list as it stands after the changes made so far.
	#
	#   returns    a list
	#   see        NumberOfItems, AllOccurrencesReplaced
	def Content()
		return @oList.Content()

	# Returns how many items the list has.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfItems()
		return @oList.NumberOfItems()

	# Returns TRUE if the list has no item.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfItems
	def IsEmpty()
		return @oList.IsEmpty()

	  #=========================================#
	 #   REPLACING ALL ITEMS WITH A NEW ITEM   #
	#=========================================#

	# Sets every item of the list to the new item, whatever it was.
	#
	#   pNewItem   the item every position receives
	#   returns    nothing; the list is changed in place
	#   note       ["a","b"] with "x" gives ["x","x"]
	#   see        ReplaceAllOccurrences, ReplaceAnyItemAtPositions
	def ReplaceAllItems(pNewItem)

		_nLen_ = This.NumberOfItems()
		_aContent_ = This.Content()

		for @i = 1 to _nLen_
			_aContent_[@i] = pNewItem
		next

		@oList.UpdateWith(_aContent_)

		def ReplaceAllItemsQ(pNewItem)
			This.ReplaceAllItems(pNewItem)
			return This

	  #-------------------------------------------#
	 #   REPLACING ALL OCCURRENCES OF AN ITEM    #
	#-------------------------------------------#

	def ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)

		if CheckingParams()
			if isList(pItem) and IsOfNamedParamList(pItem)
				pItem = pItem[2]
			ok
		ok

		# Engine fast path via string-direct variant (sidesteps the
		# cross-DLL handle-table issue: the engine creates the StzValue
		# inside stz_list.dll, so no cross-DLL handle lookup is needed).
		if isString(pItem) and isString(pNewItem)
			_pRpAll_ = @oList._EngineListFromContent()
			if _pRpAll_ != ""
				_nRpCs_ = 1
				if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
					_nRpCs_ = pCaseSensitive[2]
				but isNumber(pCaseSensitive)
					_nRpCs_ = pCaseSensitive
				ok
				StzEngineListReplaceAllStringCS(_pRpAll_, pItem, pNewItem, _nRpCs_)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pRpAll_))
				StzEngineListFree(_pRpAll_)
				return
			ok
		ok

		# Fallback for non-string types
		_anRpPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_nRpLen_ = len(_anRpPos_)

		for _iRp_ = 1 to _nRpLen_
			This.ReplaceAnyItemAtPositionCS(_anRpPos_[_iRp_], pNewItem, pCaseSensitive)
		next

		def ReplaceAllOccurrencesCSQ(pItem, pNewItem, pCaseSensitive)
			This.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)
			return This

		def ReplaceAllCS(pItem, pNewItem, pCaseSensitive)
			This.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)

		def ReplaceCS(pItem, pNewItem, pCaseSensitive)
			if isList(pItem) and IsEachNamedParamList(pItem)
				pItem = pItem[2]
			ok
			This.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)

	# Swaps every item equal to pItem for the new item; text is compared with case.
	#
	#   pItem      the item to look for
	#   pNewItem   the item put in its place
	#   returns    nothing; the list is changed in place
	#   note       ["a","b","a","A"] with "a" -> "z" gives ["z","b","z","A"], and a list item such
	#              as [1] can be replaced by a list [7,8]
	#   see        ReplaceFirstOccurrence, ReplaceLastOccurrence, AllOccurrencesReplaced
	#@ aka  -- WITHOUT CASESENSITIVITY
	def ReplaceAllOccurrences(pItem, pNewItem)
		This.ReplaceAllOccurrencesCS(pItem, pNewItem, 1)

		def ReplaceAllOccurrencesQ(pItem, pNewItem)
			This.ReplaceAllOccurrences(pItem, pNewItem)
			return This

		# Swaps every item equal to pItem for the new item; text is compared with case.
		#
		#   pItem      the item to look for
		#   pNewItem   the item put in its place
		#   returns    nothing; the list is changed in place
		#   note       it does what ReplaceAllOccurrences does
		#   see        ReplaceAllOccurrences, ReplaceFirstOccurrence
		def ReplaceAll(pItem, pNewItem)
			This.ReplaceAllOccurrences(pItem, pNewItem)

		# Swaps every item equal to pItem for the new item; pItem can be written :Each = item.
		#
		#   pItem      the item to look for, or :Each = item
		#   pNewItem   the item put in its place
		#   returns    nothing; the list is changed in place
		#   note       text is compared with case
		#   see        ReplaceAllOccurrences, ReplaceFirstOccurrence
		def Replace(pItem, pNewItem)
			if isList(pItem) and IsEachNamedParamList(pItem)
				pItem = pItem[2]
			ok
			This.ReplaceAllOccurrences(pItem, pNewItem)

	def AllOccurrencesReplacedCS(pItem, pNewItem, pCaseSensitive)
		# Was @oList.Copy().ReplaceAllOccurrencesCSQ -- not on core stzList
		_o = new stzListReplacer(@oList.Content())
		_o.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)
		return _o.Content()

	# Returns a copy of the list with every item equal to pItem swapped for the new item, leaving the object unchanged.
	#
	#   pItem      the item to look for
	#   pNewItem   the item put in its place
	#   returns    a list
	#   note       unlike ReplaceAllOccurrences, Content still shows the old list afterwards
	#   see        ReplaceAllOccurrences, Content
	def AllOccurrencesReplaced(pItem, pNewItem)
		return This.AllOccurrencesReplacedCS(pItem, pNewItem, 1)

	  #==================================================#
	 #   REPLACING ANY ITEM AT A GIVEN POSITION         #
	#==================================================#

	def ReplaceAnyItemAtPositionCS(n, pNewItem, pCaseSensitive)
		# Engine fast path for strings via the new SetString variant
		# (string-direct, no cross-DLL handle lookup).
		if isString(pNewItem)
			_pRapList_ = @oList._EngineListFromContent()
			if _pRapList_ != ""
				StzEngineListSetString(_pRapList_, n, pNewItem)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pRapList_))
				StzEngineListFree(_pRapList_)
				return
			ok
		ok

		# Fallback: direct Ring assignment
		_aRapContent_ = This.Content()
		if n >= 1 and n <= len(_aRapContent_)
			_aRapContent_[n] = pNewItem
			@oList.UpdateWith(_aRapContent_)
		ok

		def ReplaceAnyItemAtPositionCSQ(n, pNewItem, pCaseSensitive)
			This.ReplaceAnyItemAtPositionCS(n, pNewItem, pCaseSensitive)
			return This

	# Puts the new item at position n, whatever is there; a position outside the list changes nothing.
	#
	#   n          the position, counted from 1
	#   pNewItem   the item to put there
	#   returns    nothing; the list is changed in place
	#   note       no error is raised for a position such as 9 on a five-item list
	#   see        ReplaceThisItemAt, ReplaceAnyItemAtPositions
	def ReplaceAnyItemAtPosition(n, pNewItem)
		This.ReplaceAnyItemAtPositionCS(n, pNewItem, 1)

		def ReplaceAnyItemAtPositionQ(n, pNewItem)
			This.ReplaceAnyItemAtPosition(n, pNewItem)
			return This

		# Puts the new item at position n, whatever is there; a position outside the list changes nothing.
		#
		#   n          the position, counted from 1
		#   pNewItem   the item to put there
		#   returns    nothing; the list is changed in place
		#   note       it does what ReplaceAnyItemAtPosition does
		#   see        ReplaceAnyItemAtPosition, ReplaceAt
		def ReplaceItemAtPosition(n, pNewItem)
			This.ReplaceAnyItemAtPosition(n, pNewItem)

		# Puts the new item at position n, whatever is there; a position outside the list changes nothing.
		#
		#   n          the position, counted from 1
		#   pNewItem   the item to put there
		#   returns    nothing; the list is changed in place
		#   note       it does what ReplaceAnyItemAtPosition does
		#   see        ReplaceAnyItemAtPosition, ReplaceAnyItemAt
		def ReplaceAt(n, pNewItem)
			This.ReplaceAnyItemAtPosition(n, pNewItem)

	  #============================================#
	 #   REPLACING NTH OCCURRENCE OF AN ITEM     #
	#============================================#

	def ReplaceNthOccurrenceCS(n, pItem, pNewItem, pCaseSensitive)
		_nRnoPos_ = @oList.FindNthCS(n, pItem, pCaseSensitive)
		if _nRnoPos_ > 0
			This.ReplaceAnyItemAtPosition(_nRnoPos_, pNewItem)
		ok

		def ReplaceNthOccurrenceCSQ(n, pItem, pNewItem, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pItem, pNewItem, pCaseSensitive)
			return This

	# Swaps the n-th item equal to pItem for the new item, counting from the start; text is compared with case.
	#
	#   n          which occurrence, counted from 1
	#   pItem      the item to look for
	#   pNewItem   the item put in its place
	#   returns    nothing; the list is changed in place
	#   note       when there are fewer than n occurrences nothing changes
	#   see        ReplaceFirstOccurrence, ReplaceLastOccurrence, ReplaceNextNthOccurrence
	def ReplaceNthOccurrence(n, pItem, pNewItem)
		This.ReplaceNthOccurrenceCS(n, pItem, pNewItem, 1)

		def ReplaceNthOccurrenceQ(n, pItem, pNewItem)
			This.ReplaceNthOccurrence(n, pItem, pNewItem)
			return This

	  #================================================#
	 #   REPLACING FIRST OCCURRENCE OF AN ITEM        #
	#================================================#

	def ReplaceFirstOccurrenceCS(pItem, pNewItem, pCaseSensitive)
		This.ReplaceNthOccurrenceCS(1, pItem, pNewItem, pCaseSensitive)

		def ReplaceFirstOccurrenceCSQ(pItem, pNewItem, pCaseSensitive)
			This.ReplaceFirstOccurrenceCS(pItem, pNewItem, pCaseSensitive)
			return This

	# Swaps the first item equal to pItem for the new item; text is compared with case.
	#
	#   pItem      the item to look for
	#   pNewItem   the item put in its place
	#   returns    nothing; the list is changed in place
	#   note       when pItem is absent nothing changes
	#   see        ReplaceLastOccurrence, ReplaceNthOccurrence, ReplaceAllOccurrences
	def ReplaceFirstOccurrence(pItem, pNewItem)
		This.ReplaceFirstOccurrenceCS(pItem, pNewItem, 1)

		def ReplaceFirstOccurrenceQ(pItem, pNewItem)
			This.ReplaceFirstOccurrence(pItem, pNewItem)
			return This

	  #================================================#
	 #   REPLACING LAST OCCURRENCE OF AN ITEM         #
	#================================================#

	def ReplaceLastOccurrenceCS(pItem, pNewItem, pCaseSensitive)
		_anRloPos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_nRloLen_ = len(_anRloPos_)
		if _nRloLen_ > 0
			This.ReplaceAnyItemAtPosition(_anRloPos_[_nRloLen_], pNewItem)
		ok

		def ReplaceLastOccurrenceCSQ(pItem, pNewItem, pCaseSensitive)
			This.ReplaceLastOccurrenceCS(pItem, pNewItem, pCaseSensitive)
			return This

	# Swaps the last item equal to pItem for the new item; text is compared with case.
	#
	#   pItem      the item to look for
	#   pNewItem   the item put in its place
	#   returns    nothing; the list is changed in place
	#   note       when pItem is absent nothing changes
	#   see        ReplaceFirstOccurrence, ReplaceNthOccurrence, ReplaceAllOccurrences
	def ReplaceLastOccurrence(pItem, pNewItem)
		This.ReplaceLastOccurrenceCS(pItem, pNewItem, 1)

		def ReplaceLastOccurrenceQ(pItem, pNewItem)
			This.ReplaceLastOccurrence(pItem, pNewItem)
			return This

	  #=====================================#
	 #   REPLACING MANY ITEMS AT ONCE     #
	#=====================================#

	def ReplaceManyCS(paItems, pNewItem, pCaseSensitive)
		pNewItem = This._RpVal(pNewItem)		#-- strip :By/:With
		_nRmLen_ = len(paItems)
		for _iRm_ = 1 to _nRmLen_
			This.ReplaceAllOccurrencesCS(paItems[_iRm_], pNewItem, pCaseSensitive)
		next

		def ReplaceManyCSQ(paItems, pNewItem, pCaseSensitive)
			This.ReplaceManyCS(paItems, pNewItem, pCaseSensitive)
			return This

	def ReplaceMany(paItems, pNewItem)
		This.ReplaceManyCS(paItems, pNewItem, 1)

		def ReplaceManyQ(paItems, pNewItem)
			This.ReplaceMany(paItems, pNewItem)
			return This

	  #============================================#
	 #   REPLACING A SECTION OF ITEMS            #
	#============================================#

	# Cuts the items from position n1 to n2 and puts ONE new item in their place, even when that item is a list.
	#
	#   n1         the first position of the section
	#   n2         the last position of the section
	#   pNewItem   the single item that takes the section place, or :By = item
	#   returns    nothing; the list is changed in place
	#   note       [1,2,3,2,1] with positions 2 to 4 and [7,8] gives [1,[7,8],1]; n1 below 1 is read
	#              as 1 and n2 past the end as the last position
	#   see        ReplaceSectionByMany, ReplaceAnyItemAtPositions
	#@ aka  -- ReplaceSection: the section [n1..n2] is replaced by ONE new item -- -- if that item is a list, it is inserted as a SINGLE element. This is -- the canonical Softanza semantics (see ReplaceSectionByMany to splice).
	def ReplaceSection(n1, n2, pNewItem)
		if isList(pNewItem) and len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (lower(pNewItem[1]) = "by" or lower(pNewItem[1]) = "with")
			pNewItem = pNewItem[2]
		ok

		_aRsContent_ = This.Content()
		_nRsLen_ = len(_aRsContent_)
		if n1 < 1 { n1 = 1 }
		if n2 > _nRsLen_ { n2 = _nRsLen_ }

		_aRsResult_ = []
		for _iRsPre_ = 1 to n1 - 1
			@AddItem(_aRsResult_, _aRsContent_[_iRsPre_])
		next

		@AddItem(_aRsResult_, pNewItem)

		for _iRsPost_ = n2 + 1 to _nRsLen_
			@AddItem(_aRsResult_, _aRsContent_[_iRsPost_])
		next

		@oList.UpdateWith(_aRsResult_)

		def ReplaceSectionQ(n1, n2, pNewItem)
			This.ReplaceSection(n1, n2, pNewItem)
			return This

	#-- ReplaceSectionByMany: the section [n1..n2] is replaced by SPLICING
	#-- the items of paNewItems in place (flattened one level into the list).
	def ReplaceSectionByManyCS(n1, n2, paNewItems, pCaseSensitive)
		if isList(paNewItems) and len(paNewItems) = 2 and isString(paNewItems[1]) and
		   (lower(paNewItems[1]) = "by" or lower(paNewItems[1]) = "with")
			paNewItems = paNewItems[2]
		ok

		_aRsContent_ = This.Content()
		_nRsLen_ = len(_aRsContent_)
		if n1 < 1 { n1 = 1 }
		if n2 > _nRsLen_ { n2 = _nRsLen_ }

		_aRsResult_ = []
		for _iRsPre_ = 1 to n1 - 1
			@AddItem(_aRsResult_, _aRsContent_[_iRsPre_])
		next

		_nRsNewLen_ = len(paNewItems)
		for _iRsNew_ = 1 to _nRsNewLen_
			@AddItem(_aRsResult_, paNewItems[_iRsNew_])
		next

		for _iRsPost_ = n2 + 1 to _nRsLen_
			@AddItem(_aRsResult_, _aRsContent_[_iRsPost_])
		next

		@oList.UpdateWith(_aRsResult_)

	# Cuts the items from position n1 to n2 and splices the given items in their place, one level flat.
	#
	#   n1           the first position of the section
	#   n2           the last position of the section
	#   paNewItems   the items to splice in, or :By = list
	#   returns      nothing; the list is changed in place
	#   note         [1,2,3,2,1] with positions 2 to 4 and [7,8] gives [1,7,8,1]; n1 below 1 is read
	#                as 1 and n2 past the end as the last position
	#   see          ReplaceSection, ReplaceManyByMany
	def ReplaceSectionByMany(n1, n2, paNewItems)
		This.ReplaceSectionByManyCS(n1, n2, paNewItems, 1)

		def ReplaceSectionByManyQ(n1, n2, paNewItems)
			This.ReplaceSectionByMany(n1, n2, paNewItems)
			return This

	#-- Back-compat alias: the old ReplaceSectionCS spliced; keep that as the
	#-- by-many CS variant so any existing caller is unaffected.
	def ReplaceSectionCS(n1, n2, paNewItems, pCaseSensitive)
		This.ReplaceSectionByManyCS(n1, n2, paNewItems, pCaseSensitive)

	  #============================================#
	 #   REPLACING MANY ITEMS BY MANY             #
	#============================================#

	def ReplaceManyByManyCS(paItems, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)

		if NOT (isList(paItems) and isList(paNewItems))
			return
		ok

		_nRmbmItemsLen_ = len(paItems)
		_nRmbmNewLen_ = len(paNewItems)
		if _nRmbmItemsLen_ = 0 or _nRmbmNewLen_ = 0
			return
		ok

		# Non-XT contract: distinct 1-to-1 -- needle[i] -> replacement[i],
		# replacing ALL occurrences of that needle. Sizes must match.
		if _nRmbmItemsLen_ != _nRmbmNewLen_
			StzRaise("Incorrect values! paItems and paNewItems must have the same size.")
		ok

		for _iRmbm_ = 1 to _nRmbmItemsLen_
			This.ReplaceAllOccurrencesCS(paItems[_iRmbm_], paNewItems[_iRmbm_], pCaseSensitive)
		next

		def ReplaceManyByManyCSQ(paItems, paNewItems, pCaseSensitive)
			This.ReplaceManyByManyCS(paItems, paNewItems, pCaseSensitive)
			return This

	# Swaps each item of paItems for the item at the same place in paNewItems, everywhere in the list.
	#
	#   paItems      the items to look for
	#   paNewItems   the items that replace them, one for one
	#   returns      nothing; the list is changed in place
	#   note         the two lists must have the same size, otherwise the error Incorrect values!
	#                paItems and paNewItems must have the same size. is raised; an empty list on
	#                either side does nothing
	#   see          ReplaceAllOccurrences, ReplaceByMany
	def ReplaceManyByMany(paItems, paNewItems)
		This.ReplaceManyByManyCS(paItems, paNewItems, 1)

		def ReplaceManyByManyQ(paItems, paNewItems)
			This.ReplaceManyByMany(paItems, paNewItems)
			return This

	def ReplaceManyByManyCSXT(paItems, paNewItems, pCaseSensitive)
		# XT version: if paNewItems is shorter, it cycles; if longer, it truncates
		if isList(paNewItems) and len(paNewItems) > 0
			if isString(paNewItems[1]) and
			   (paNewItems[1] = :by or paNewItems[1] = :with or paNewItems[1] = :By or paNewItems[1] = :With)
				paNewItems = paNewItems[2]
			ok
		ok

		_nRmbmxtItemsLen_ = len(paItems)
		_nRmbmxtNewLen_ = len(paNewItems)

		if _nRmbmxtItemsLen_ = 0 or _nRmbmxtNewLen_ = 0
			return
		ok

		# Walk once, collect matched positions in occurrence order.
		_aRmbmxtContent_ = This.Content()
		_nRmbmxtLen_ = len(_aRmbmxtContent_)
		_anRmbmxtPos_ = []
		for _iRmbmxt_ = 1 to _nRmbmxtLen_
			if This._RpIn(_aRmbmxtContent_[_iRmbmxt_], paItems, pCaseSensitive)
				_anRmbmxtPos_ + _iRmbmxt_
			ok
		next

		_nRmbmxtMatched_ = len(_anRmbmxtPos_)
		if _nRmbmxtMatched_ = 0
			return
		ok

		# XT: cycle the palette across ALL matched occurrences, in order.
		for _iRmbmxt2_ = 1 to _nRmbmxtMatched_
			_nRmbmxtIdx_ = ((_iRmbmxt2_ - 1) % _nRmbmxtNewLen_) + 1
			_aRmbmxtContent_[ _anRmbmxtPos_[_iRmbmxt2_] ] = paNewItems[_nRmbmxtIdx_]
		next

		@oList.UpdateWith(_aRmbmxtContent_)

	def ReplaceManyByManyXT(paItems, paNewItems)
		This.ReplaceManyByManyCSXT(paItems, paNewItems, 1)

	  #====================================================#
	 #   POSITIONAL REPLACERS (ported from the monolith)  #
	#====================================================#

	#-- strip a :By / :With / :Using named-param wrapper
	def _RpVal(p)
		if isList(p) and len(p) = 2 and isString(p[1])
			_c_ = lower(p[1])
			if _c_ = "by" or _c_ = "with" or _c_ = "using"
				return p[2]
			ok
		ok
		return p

	#-- value equality honoring case-sensitivity (UTF-8 safe via the engine)
	def _RpEq(pA, pB, pCaseSensitive)
		if isString(pA) and isString(pB) and pCaseSensitive = 0
			return StzLower(pA) = StzLower(pB)
		ok
		return pA = pB

	def _RpIn(pVal, paItems, pCaseSensitive)
		_m_ = len(paItems)
		for _k_ = 1 to _m_
			if This._RpEq(pVal, paItems[_k_], pCaseSensitive)
				return 1
			ok
		next
		return 0

	# Puts the new item at every given position; positions outside the list are skipped.
	#
	#   panPos     the positions, counted from 1
	#   pNewItem   the item to put there, or :With = item
	#   returns    nothing; the list is changed in place
	#   note       [1,2,3,2,1] with [1,9] and 0 gives [0,2,3,2,1]
	#   see        ReplaceAnyItemAtPosition, ReplaceThisItemAtPositions
	#@ aka  -- Set whatever lives at each of panPos to pNewItem.
	def ReplaceAnyItemAtPositions(panPos, pNewItem)
		pNewItem = This._RpVal(pNewItem)
		_a_ = This.Content()
		_n_ = len(_a_)
		_np_ = len(panPos)
		for _i_ = 1 to _np_
			_p_ = panPos[_i_]
			if _p_ >= 1 and _p_ <= _n_
				_a_[_p_] = pNewItem
			ok
		next
		@oList.UpdateWith(_a_)

		# Puts the new item at every given position; positions outside the list are skipped.
		#
		#   panPos     the positions, counted from 1
		#   pNewItem   the item to put there, or :With = item
		#   returns    nothing; the list is changed in place
		#   note       it does what ReplaceAnyItemAtPositions does
		#   see        ReplaceAnyItemAtPositions, ReplaceAtPositions
		def ReplaceAnyItemsAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

		# Puts the new item at every given position; positions outside the list are skipped.
		#
		#   panPos     the positions, counted from 1
		#   pNewItem   the item to put there, or :With = item
		#   returns    nothing; the list is changed in place
		#   note       it does what ReplaceAnyItemAtPositions does
		#   see        ReplaceAnyItemAtPositions, ReplaceAtPositions
		def ReplaceItemsAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

		# Puts the new item at every given position; positions outside the list are skipped.
		#
		#   panPos     the positions, counted from 1
		#   pNewItem   the item to put there, or :With = item
		#   returns    nothing; the list is changed in place
		#   note       it does what ReplaceAnyItemAtPositions does
		#   see        ReplaceAnyItemAtPositions, ReplaceItemsAtPositions
		def ReplaceAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

	# Puts the new item at position n, whatever is there.
	#
	#   n          the position, counted from 1
	#   pNewItem   the item to put there
	#   returns    nothing; the list is changed in place
	#   note       it is ReplaceAnyItemAtPositions with one position
	#   see        ReplaceAnyItemAtPosition, ReplaceAnyItemAtPositions
	#@ aka  -- Set the single position n to pNewItem (named-param aware).
	def ReplaceAnyItemAt(n, pNewItem)
		This.ReplaceAnyItemAtPositions([ n ], pNewItem)

	#-- At each of panPos, replace ONLY if the item there equals pItem.
	def ReplaceThisItemAtPositionsCS(panPos, pItem, pNewItem, pCaseSensitive)
		pNewItem = This._RpVal(pNewItem)
		_a_ = This.Content()
		_n_ = len(_a_)
		_np_ = len(panPos)
		for _i_ = 1 to _np_
			_p_ = panPos[_i_]
			if _p_ >= 1 and _p_ <= _n_ and This._RpEq(_a_[_p_], pItem, pCaseSensitive)
				_a_[_p_] = pNewItem
			ok
		next
		@oList.UpdateWith(_a_)

	# Puts the new item at the given positions, but only where the item now there equals pItem.
	#
	#   panPos     the positions to examine, counted from 1
	#   pItem      the item that must be there
	#   pNewItem   the item to put there, or :With = item
	#   returns    nothing; the list is changed in place
	#   note       text is compared with case; [1,2,3,2,1] with [1,2,3], 2 and 0 gives [1,0,3,2,1]
	#   see        ReplaceTheseItemsAtPositions, ReplaceAnyItemAtPositions
	def ReplaceThisItemAtPositions(panPos, pItem, pNewItem)
		This.ReplaceThisItemAtPositionsCS(panPos, pItem, pNewItem, 1)

	def ReplaceThisItemAtCS(n, pItem, pNewItem, pCaseSensitive)
		This.ReplaceThisItemAtPositionsCS([ n ], pItem, pNewItem, pCaseSensitive)

	# Puts the new item at position n, but only if the item now there equals pItem.
	#
	#   n          the position, counted from 1
	#   pItem      the item that must be there
	#   pNewItem   the item to put there
	#   returns    nothing; the list is changed in place
	#   note       at a position holding another item nothing changes
	#   see        ReplaceThisItemAtPositions, ReplaceAnyItemAt
	def ReplaceThisItemAt(n, pItem, pNewItem)
		This.ReplaceThisItemAtCS(n, pItem, pNewItem, 1)

	#-- At each of panPos, replace if the item there is a member of paItems.
	def ReplaceTheseItemsAtPositionsCS(panPos, paItems, pNewItem, pCaseSensitive)
		pNewItem = This._RpVal(pNewItem)
		_a_ = This.Content()
		_n_ = len(_a_)
		_np_ = len(panPos)
		for _i_ = 1 to _np_
			_p_ = panPos[_i_]
			if _p_ >= 1 and _p_ <= _n_ and This._RpIn(_a_[_p_], paItems, pCaseSensitive)
				_a_[_p_] = pNewItem
			ok
		next
		@oList.UpdateWith(_a_)

	# Puts the new item at the given positions, but only where the item now there is one of paItems.
	#
	#   panPos     the positions to examine, counted from 1
	#   paItems    the items that may be replaced
	#   pNewItem   the item to put there, or :With = item
	#   returns    nothing; the list is changed in place
	#   note       text is compared with case; [1,2,3,2,1] with [1,2,3,4], [2,3] and 0 gives
	#              [1,0,0,0,1]
	#   see        ReplaceThisItemAtPositions, ReplaceAnyItemAtPositions
	def ReplaceTheseItemsAtPositions(panPos, paItems, pNewItem)
		This.ReplaceTheseItemsAtPositionsCS(panPos, paItems, pNewItem, 1)

	#-- Replace the k-th occurrence of pItem with paNewItems[k] (in order).
	def ReplaceByManyCS(pItem, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_pos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_np_ = len(_pos_)
		_nn_ = len(paNewItems)
		_a_ = This.Content()
		for _i_ = 1 to _np_
			if _i_ <= _nn_
				_a_[ _pos_[_i_] ] = paNewItems[_i_]
			ok
		next
		@oList.UpdateWith(_a_)

	# Swaps the occurrences of pItem, in order, for the items of paNewItems, one each; extra occurrences are left alone.
	#
	#   pItem        the item to look for
	#   paNewItems   the replacements, used in order
	#   returns      nothing; the list is changed in place
	#   note         [1,2,3,2,1] with 2 and [7,8] gives [1,7,3,8,1] and with [7] gives [1,7,3,2,1]
	#   see          ReplaceItemByManyXT, ReplaceManyByMany, ReplaceOccurrencesByMany
	def ReplaceByMany(pItem, paNewItems)
		This.ReplaceByManyCS(pItem, paNewItems, 1)

	#-- Cycling variant: paNewItems is reused round-robin across occurrences.
	def ReplaceByManyCSXT(pItem, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_pos_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_np_ = len(_pos_)
		_nn_ = len(paNewItems)
		if _nn_ = 0 return ok
		_a_ = This.Content()
		for _i_ = 1 to _np_
			_idx_ = ((_i_ - 1) % _nn_) + 1
			_a_[ _pos_[_i_] ] = paNewItems[_idx_]
		next
		@oList.UpdateWith(_a_)

	def ReplaceByManyXT(pItem, paNewItems)
		This.ReplaceByManyCSXT(pItem, paNewItems, 1)

		# Swaps the occurrences of pItem, in order, for the items of paNewItems, starting over when they run out.
		#
		#   pItem        the item to look for
		#   paNewItems   the replacements, reused round-robin
		#   returns      nothing; the list is changed in place
		#   note         [1,2,3,2,1] with 2 and [7] gives [1,7,3,7,1]; with 1 and [7,8,9] gives
		#                [7,2,3,2,8]
		#   see          ReplaceByMany, ReplaceAtByManyXT
		def ReplaceItemByManyXT(pItem, paNewItems)
			This.ReplaceByManyXT(pItem, paNewItems)

	# Puts the items of paNewItems, in order, at the given positions; surplus positions are left alone.
	#
	#   panPos       the positions, counted from 1
	#   paNewItems   the items, one per position
	#   returns      nothing; the list is changed in place
	#   note         [1,2,3,2,1] with [1,3,5] and [7,8] gives [7,2,8,2,1]
	#   see          ReplaceByMany, ReplaceAnyItemAtPositionsByMany
	#@ aka  -- Replace items at the GIVEN positions with paNewItems consumed in order.
	def ReplaceOccurrencesByMany(panPos, paNewItems)
		_a_ = This.Content()
		_n_ = len(_a_)
		_np_ = len(panPos)
		_nn_ = len(paNewItems)
		for _i_ = 1 to _np_
			if _i_ <= _nn_ and panPos[_i_] >= 1 and panPos[_i_] <= _n_
				_a_[ panPos[_i_] ] = paNewItems[_i_]
			ok
		next
		@oList.UpdateWith(_a_)

	#-- Cycling variant.
	def ReplaceOccurrencesByManyXT(panPos, paNewItems)
		_a_ = This.Content()
		_n_ = len(_a_)
		_np_ = len(panPos)
		_nn_ = len(paNewItems)
		if _nn_ = 0 return ok
		for _i_ = 1 to _np_
			if panPos[_i_] >= 1 and panPos[_i_] <= _n_
				_idx_ = ((_i_ - 1) % _nn_) + 1
				_a_[ panPos[_i_] ] = paNewItems[_idx_]
			ok
		next
		@oList.UpdateWith(_a_)

	  #=========================================================#
	 #  POSITIONS x VALUE-FILTER x MANY (distribute / cycle)   #
	#=========================================================#

	def _RpHas(paList, pVal)
		_n_ = len(paList)
		for _k_ = 1 to _n_
			if paList[_k_] = pVal return 1 ok
		next
		return 0

	def _RpDedup(paList)
		_res_ = []
		_n_ = len(paList)
		for _k_ = 1 to _n_
			if NOT This._RpHas(_res_, paList[_k_])
				_res_ + paList[_k_]
			ok
		next
		return _res_

	def _RpCycle(paItems, nWanted)
		_res_ = []
		_n_ = len(paItems)
		if _n_ = 0 return _res_ ok
		for _k_ = 1 to nWanted
			_res_ + paItems[ ((_k_ - 1) % _n_) + 1 ]
		next
		return _res_

	#-- positions of panPos that hold pItem, kept in panPos order (intersection)
	def _RpPosWithItem(panPos, pItem, pCaseSensitive)
		_anItem_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_res_ = []
		_np_ = len(panPos)
		for _i_ = 1 to _np_
			if This._RpHas(_anItem_, panPos[_i_]) and NOT This._RpHas(_res_, panPos[_i_])
				_res_ + panPos[_i_]
			ok
		next
		return _res_

	#-- At the panPos that hold pItem, replace the k-th such with paNewItems[k].
	def ReplaceItemAtPositionsByManyCS(panPos, pItem, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_anPos_ = This._RpPosWithItem(panPos, pItem, pCaseSensitive)
		_nLen_ = len(_anPos_)
		_nNew_ = len(paNewItems)
		_a_ = This.Content()
		for _i_ = 1 to _nLen_
			if _i_ <= _nNew_
				_a_[ _anPos_[_i_] ] = paNewItems[_i_]
			ok
		next
		@oList.UpdateWith(_a_)

	# Puts the items of paNewItems, in order, at those given positions that hold pItem; surplus positions are left alone.
	#
	#   panPos       the positions to examine, counted from 1
	#   pItem        the item that must be there
	#   paNewItems   the replacements, used in order
	#   returns      nothing; the list is changed in place
	#   note         [1,2,3,2,1] with [2,4,5], 2 and [7,8] gives [1,7,3,8,1]
	#   see          ReplaceTheseItemsAtPositionsByMany, ReplaceByMany
	def ReplaceItemAtPositionsByMany(panPos, pItem, paNewItems)
		This.ReplaceItemAtPositionsByManyCS(panPos, pItem, paNewItems, 1)

	#-- XT: cycle (deduplicated) paNewItems across the matched positions.
	def ReplaceItemAtPositionsByManyCSXT(panPos, pItem, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_anPos_ = This._RpPosWithItem(panPos, pItem, pCaseSensitive)
		_nLen_ = len(_anPos_)
		if _nLen_ = 0 return ok
		if len(paNewItems) != _nLen_
			paNewItems = This._RpDedup(paNewItems)
		ok
		_cyc_ = This._RpCycle(paNewItems, _nLen_)
		_a_ = This.Content()
		for _i_ = 1 to _nLen_
			_a_[ _anPos_[_i_] ] = _cyc_[_i_]
		next
		@oList.UpdateWith(_a_)

	def ReplaceItemAtPositionsByManyXT(panPos, pItem, paNewItems)
		This.ReplaceItemAtPositionsByManyCSXT(panPos, pItem, paNewItems, 1)

	#-- These items: apply the per-item position-replace for each item in turn.
	def ReplaceTheseItemsAtPositionsByManyCS(panPos, paItems, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_nI_ = len(paItems)
		for _i_ = 1 to _nI_
			This.ReplaceItemAtPositionsByManyCS(panPos, paItems[_i_], paNewItems, pCaseSensitive)
		next

	# Does ReplaceItemAtPositionsByMany for each item of paItems in turn, each time giving paNewItems from their start.
	#
	#   panPos       the positions to examine, counted from 1
	#   paItems      the items that may be replaced
	#   paNewItems   the replacements, restarted for each item
	#   returns      nothing; the list is changed in place
	#   note         [1,2,3,2,1] with [1,2,3,4,5], [1,3] and [7,8,9] gives [7,2,7,2,8]
	#   see          ReplaceItemAtPositionsByMany, ReplaceAnyItemAtPositionsByMany
	def ReplaceTheseItemsAtPositionsByMany(panPos, paItems, paNewItems)
		This.ReplaceTheseItemsAtPositionsByManyCS(panPos, paItems, paNewItems, 1)

	def ReplaceTheseItemsAtPositionsByManyCSXT(panPos, paItems, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_nI_ = len(paItems)
		for _i_ = 1 to _nI_
			This.ReplaceItemAtPositionsByManyCSXT(panPos, paItems[_i_], paNewItems, pCaseSensitive)
		next

	def ReplaceTheseItemsAtPositionsByManyXT(panPos, paItems, paNewItems)
		This.ReplaceTheseItemsAtPositionsByManyCSXT(panPos, paItems, paNewItems, 1)

	#-- Any item: zip positions <-> news (no value filter), truncating to shorter.
	def ReplaceAnyItemAtPositionsByManyCS(panPos, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_nMin_ = len(panPos)
		if len(paNewItems) < _nMin_  _nMin_ = len(paNewItems)  ok
		_a_ = This.Content()
		_n_ = len(_a_)
		for _i_ = 1 to _nMin_
			if panPos[_i_] >= 1 and panPos[_i_] <= _n_
				_a_[ panPos[_i_] ] = paNewItems[_i_]
			ok
		next
		@oList.UpdateWith(_a_)

	# Puts the items of paNewItems at the given positions in order, whatever is there, stopping at the shorter of the two lists.
	#
	#   panPos       the positions, counted from 1
	#   paNewItems   the items, one per position
	#   returns      nothing; the list is changed in place
	#   note         [1,2,3,2,1] with [1,3,5] and [7,8] gives [7,2,8,2,1]
	#   see          ReplaceOccurrencesByMany, ReplaceAtByManyXT
	def ReplaceAnyItemAtPositionsByMany(panPos, paNewItems)
		This.ReplaceAnyItemAtPositionsByManyCS(panPos, paNewItems, 1)

		# Puts the items of paNewItems at the given positions in order, whatever is there, stopping at the shorter of the two lists.
		#
		#   panPos       the positions, counted from 1
		#   paNewItems   the items, one per position
		#   returns      nothing; the list is changed in place
		#   note         it does what ReplaceAnyItemAtPositionsByMany does
		#   see          ReplaceAnyItemAtPositionsByMany, ReplaceOccurrencesByMany
		def ReplaceAnyItemsAtPositionsByMany(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByMany(panPos, paNewItems)

	#-- XT: cycle news across ALL given positions.
	def ReplaceAnyItemAtPositionsByManyCSXT(panPos, paNewItems, pCaseSensitive)
		paNewItems = This._RpVal(paNewItems)
		_np_ = len(panPos)
		if _np_ = 0 or len(paNewItems) = 0 return ok
		_cyc_ = This._RpCycle(paNewItems, _np_)
		_a_ = This.Content()
		_n_ = len(_a_)
		for _i_ = 1 to _np_
			if panPos[_i_] >= 1 and panPos[_i_] <= _n_
				_a_[ panPos[_i_] ] = _cyc_[_i_]
			ok
		next
		@oList.UpdateWith(_a_)

	def ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)
		This.ReplaceAnyItemAtPositionsByManyCSXT(panPos, paNewItems, 1)

		def ReplaceAnyItemsAtPositionsByManyXT(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)

		# Puts the items of paNewItems at the given positions in order, starting over when they run out, whatever is there.
		#
		#   panPos       the positions, counted from 1
		#   paNewItems   the items, reused round-robin
		#   returns      nothing; the list is changed in place
		#   note         [1,2,3,2,1] with [1,2,3,4] and [7,8] gives [7,8,7,8,1]
		#   see          ReplaceAnyItemAtPositionsByMany, ReplaceItemByManyXT
		def ReplaceAtByManyXT(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)

	  #==================================================#
	 #  W-EXPRESSION + NEXT-NTH-OCCURRENCE REPLACERS    #
	#==================================================#

	#-- unwrap ANY 2-element named-param ([:keyword, value] -> value)
	def _RpNamed(p)
		if isList(p) and len(p) = 2 and isString(p[1])
			return p[2]
		ok
		return p

	#-- Replace every item matching the :Where boolean expr with the :By value.
	#-- Matching positions come from the engine-backed FindAllW (@item placeholder).
	def ReplaceW(pWhere, pBy)
		_cond_ = This._RpNamed(pWhere)
		_val_  = This._RpNamed(pBy)
		_pos_  = @oList.FindAllW(_cond_)
		This.ReplaceAnyItemAtPositions(_pos_, _val_)

		# Swaps every item that satisfies a condition written with @item for a new value.
		#
		#   pWhere     the condition, such as '@item > 1', or :Where = condition
		#   pBy        the value put in place, or :By = value
		#   returns    nothing; the list is changed in place
		#   note       [1,2,3,2,1] with '@item > 1' and 0 gives [1,0,0,0,1]
		#   see        ReplaceAllOccurrences, ReplaceAnyItemAtPositions
		def ReplaceItemsW(pWhere, pBy)
			This.ReplaceW(pWhere, pBy)

	#-- Replace the n-th occurrence of pItem at or after position pnStartingAt.
	def ReplaceNextNthOccurrenceCS(n, pItem, pNewItem, pnStartingAt, pCaseSensitive)
		pItem        = This._RpNamed(pItem)
		pNewItem     = This._RpNamed(pNewItem)
		pnStartingAt = This._RpNamed(pnStartingAt)
		_all_ = @oList.FindAllCS(pItem, pCaseSensitive)
		_na_  = len(_all_)
		_cnt_ = 0
		_target_ = 0
		for _i_ = 1 to _na_
			if _all_[_i_] >= pnStartingAt
				_cnt_++
				if _cnt_ = n
					_target_ = _all_[_i_]
					exit
				ok
			ok
		next
		if _target_ > 0
			_a_ = This.Content()
			_a_[_target_] = pNewItem
			@oList.UpdateWith(_a_)
		ok

	# Swaps the n-th item equal to pItem found at or after position pnStartingAt; text is compared with case.
	#
	#   n              which occurrence after the start, counted from 1
	#   pItem          the item to look for
	#   pNewItem       the item put in its place
	#   pnStartingAt   the position where the search begins
	#   returns        nothing; the list is changed in place
	#   note           [1,2,3,2,1] with 1, 2, 9 and 3 gives [1,2,3,9,1] because the 2 at position 2
	#                  lies before the start
	#   see            ReplaceNthOccurrence, ReplaceFirstOccurrence
	def ReplaceNextNthOccurrence(n, pItem, pNewItem, pnStartingAt)
		This.ReplaceNextNthOccurrenceCS(n, pItem, pNewItem, pnStartingAt, 1)

		def ReplaceNextNthOccurrenceST(n, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrence(n, pItem, pNewItem, pnStartingAt)

		# Swaps the n-th item equal to pItem found at or after position pnStartingAt; text is compared with case.
		#
		#   n              which occurrence after the start, counted from 1
		#   pItem          the item to look for
		#   pNewItem       the item put in its place
		#   pnStartingAt   the position where the search begins
		#   returns        nothing; the list is changed in place
		#   note           it does what ReplaceNextNthOccurrence does
		#   see            ReplaceNextNthOccurrence, ReplaceNthOccurrence
		def ReplaceNthNextOccurrenceST(n, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrence(n, pItem, pNewItem, pnStartingAt)
