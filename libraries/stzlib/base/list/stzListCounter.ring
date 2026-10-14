#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCOUNTER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List counter subclass -- conditional        #
#                  counting (W/WXT), conditional insert.       #
#                  For aliases, use stzListCounterXT.           #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Counts the items of a list: by condition, by type, by value, and empty or not, and inserts around the items that meet a condition.
#
# Build one with new stzListCounter(aList) or over a stzList object; it keeps its own copy, so what
# you passed in is never changed. A condition is written in the W notation, a text in braces where
# @item stands for the item under test, such as '{ @item > 5 }'. Count compares texts case-
# sensitively; CountCS takes a 0 or 1 flag. The insertion methods InsertAfterW and InsertBeforeW
# change the list the counter holds. The question forms HowManyItemsW, HowManyUniqueItemsW and the
# alias InsertAfterWhere raise error R24 today; see their warnings.
#
#   receiver   o1 = new stzListCounter([ 5, "a", "A", 12, "", "שלום", 12 ])
#   example    ? o1.CountNumbers()
#              #--> 3
#              ? o1.Count(12)
#              #--> 2
#              ? o1.CountItemsW('{ isNumber(@item) and @item > 6 }')
#              #--> 2
#              ? o1.CountEmptyItems()
#              #--> 1
#   see        stzList, stzListInserter, stzListOfStrings
class stzListCounter from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a counter over a list or over a stzList object, working on its own copy, so the list passed in is never changed.
	#
	#   pListOrObj   a list, or a stzList object, whose items are counted
	#   returns      nothing; the object is built
	#   warning      any other kind of value raises "Can't create stzListCounter! Parameter must be
	#                a list or stzList object."
	#   see          Content
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListCounter! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the items the counter holds, after any insertion made through it.
	#
	#   returns    a list
	#   see        NumberOfItems
	def Content()
		return @oList.Content()

	# Returns how many items the list holds.
	#
	#   returns    a number
	#   see        CountItemsW, Content
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfItems
	def IsEmpty()
		return @oList.IsEmpty()

	  #--------------------------------------------------#
	 #     COUNTING ITEMS VERIFYING A GIVEN CONDITION   #
	#==================================================#

	# Returns how many items satisfy a condition written in the W notation, where @item stands for the item under test.
	#
	#   pCondition   the condition as text in braces, such as '{ isNumber(@item) and @item > 6 }'
	#   returns      a number
	#   see          CountIf, NumberOfUniqueItemsW
	def CountItemsW(pCondition)
		_aItems_ = @oList.FindW(pCondition)
		_nResult_ = len(_aItems_)
		return _nResult_

		def CountW(pCondition)
			return This.CountItemsW(pCondition)

		def NumberOfOccurrencesW(pCondition)
			return This.CountItemsW(pCondition)

		def NumberOfItemsW(pCondition)
			return This.CountItemsW(pCondition)

		# Returns how many items satisfy a W condition, under the question form of CountItemsW.
		#
		#   pcCondition   the condition as text in braces, such as '{ isNumber(@item) }'
		#   returns       nothing today: it raises error R24
		#   note          the alias passes pCondition on but its own parameter is named pcCondition
		#   warning       Raises error R24 "Using uninitialized variable: pcondition" today instead
		#                 of returning the count; use CountItemsW, CountW or NumberOfItemsW
		#   see           CountItemsW
		def HowManyItemsW(pcCondition)
			return This.CountItemsW(pCondition)

	# Returns how many different items, each counted once, satisfy a W condition.
	#
	#   pCondition   the condition as text in braces, where @item stands for the item under test
	#   returns      a number
	#   note         in [ 5, "a", 12, "a", 12 ] the numbers give 2, not 3
	#   see          HowManyUniqueItemsW, CountItemsW
	def NumberOfUniqueItemsW(pCondition)
		return len( @oList.UniqueItemsW(pCondition) )

		def CountUniqueItemsW(pCondition)
			return This.NumberOfUniqueItemsW(pCondition)

		def CountItemsUW(pCondition)
			return This.NumberOfUniqueItemsW(pCondition)

		# Returns how many different items satisfy a W condition, under the question form of NumberOfUniqueItemsW.
		#
		#   pcCondition   the condition as text in braces, such as '{ isString(@item) }'
		#   returns       nothing today: it raises error R24
		#   note          the alias passes pCondition on but its own parameter is named pcCondition
		#   warning       Raises error R24 "Using uninitialized variable: pcondition" today instead
		#                 of returning the count; use NumberOfUniqueItemsW or CountUniqueItemsW
		#   see           NumberOfUniqueItemsW
		def HowManyUniqueItemsW(pcCondition)
			return This.NumberOfUniqueItemsW(pCondition)

	  #------------------------------------------------------------#
	 #     COUNTING ITEMS VERIFYING A GIVEN CONDITION -- XTended  #
	#------------------------------------------------------------#










	  #--------------------------------------------------------------------#
	 #  INSERTING ITEM AFTER OR BEFORE ITEMS VERIFYING A GIVEN CONDITION  #
	#====================================================================#

	# Inserts a new item right after every item that satisfies a W condition, changing the list held by the counter.
	#
	#   pcCondition   the W condition as text in braces, such as '{ @item > 5 }'
	#   pNewItem      the item to insert after each match
	#   returns       nothing; the counter now holds the longer list
	#   note          no item matching leaves the list as it was; the list given to init is
	#                 untouched
	#   see           InsertBeforeW, Content
	def InsertAfterW( pcCondition, pNewItem )
		_anPos_ = @oList.FindItemsW(pcCondition)
		@oList.InsertAfterManyPositions( _anPos_, pNewItem )

		def InsertAfterWQ( pcCondition, pNewItem )
			This.InsertAfterW( pCondition, pNewItem )
			return This

		# Inserts a new item right after every item that satisfies a W condition, under the name Where.
		#
		#   pcCondition   the W condition as text in braces
		#   pNewItem      the item to insert after each match
		#   returns       nothing today: it raises error R24 and the list is not changed
		#   note          the alias passes pCondition on but its own parameter is named pcCondition
		#   warning       Raises error R24 "Using uninitialized variable: pcondition" today instead
		#                 of inserting after each match; InsertAfterWQ fails the same way; use
		#                 InsertAfterW
		#   see           InsertAfterW
		def InsertAfterWhere(pcCondition, pNewItem)
			This.InsertAfterW(pCondition, pNewItem)

	# Inserts a new item right before every item that satisfies a W condition, changing the list held by the counter.
	#
	#   pcCondition   the W condition as text in braces, such as '{ @item > 5 }'
	#   pNewItem      the item to insert before each match
	#   returns       nothing; the counter now holds the longer list
	#   see           InsertAfterW, InsertAtW
	def InsertBeforeW(pcCondition, pNewItem)
		_anPos_ = @oList.FindItemsW(pcCondition)
		@oList.InsertBeforeManyPositions(_anPos_, pNewItem)

		def InsertBeforeWQ(pcCondition, pNewItem)
			This.InsertBeforeW(pcCondition, pNewItem)
			return This

		# Inserts a new item right before every item that satisfies a W condition, the same as InsertBeforeW.
		#
		#   pcCondition   the W condition as text in braces
		#   pNewItem      the item to insert at each match
		#   returns       nothing
		#   see           InsertBeforeW
		def InsertAtW(pcCondition, pNewItem)
			This.InsertBeforeW(pcCondition, pNewItem)

	  #------------------------------------------------------------------------------------#
	 #  INSERTING ITEM AFTER OR BEFORE ITEMS VERIFYING A GIVEN CONDITION -- WXT/EXTENDED  #
	#------------------------------------------------------------------------------------#







	  #======================================================#
	 #   COUNT ITEMS OF SPECIFIC TYPE                       #
	#======================================================#

	# Returns how many items of the list are texts.
	#
	#   returns    a number
	#   note       an empty text counts as a text
	#   see        CountNumbers, CountLists
	def CountStrings()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_nCount_ = 0
		for i = 1 to _nLen_
			if isString(_aContent_[i])
				_nCount_++
			ok
		next
		return _nCount_

		def NumberOfStrings()
			return This.CountStrings()

	# Returns how many items of the list are numbers.
	#
	#   returns    a number
	#   see        CountStrings, CountLists
	def CountNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_nCount_ = 0
		for i = 1 to _nLen_
			if isNumber(_aContent_[i])
				_nCount_++
			ok
		next
		return _nCount_

		def NumberOfNumbers()
			return This.CountNumbers()

	# Returns how many items of the list are themselves lists.
	#
	#   returns    a number
	#   note       only the top level is looked at, a sublist counts once whatever it holds
	#   see        CountStrings, CountNumbers
	def CountLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_nCount_ = 0
		for i = 1 to _nLen_
			if isList(_aContent_[i])
				_nCount_++
			ok
		next
		return _nCount_

		def NumberOfLists()
			return This.CountLists()

	  #======================================================#
	 #   COUNT OCCURRENCES OF A SPECIFIC ITEM               #
	#======================================================#

	def CountCS(pItem, pCaseSensitive)
		if isString(pItem)
			_pCntList = @oList._EngineListFromContent()
			if _pCntList != ""
				_nCntResult = StzEngineListCountStringCS(_pCntList, pItem, pCaseSensitive)
				StzEngineListFree(_pCntList)
				return _nCntResult
			ok
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_nCount_ = 0
		for i = 1 to _nLen_
			if BothAreEqualCS(_aContent_[i], pItem, pCaseSensitive)
				_nCount_++
			ok
		next
		return _nCount_

		def NumberOfOccurrencesOfCS(pItem, pCaseSensitive)
			return This.CountCS(pItem, pCaseSensitive)

	# Returns how many times an item occurs in the list, case-sensitively for texts; sublists are compared by content.
	#
	#   pItem      the item to count: a text, a number or a list
	#   returns    a number
	#   note       CountCS(pItem, 0) ignores case: "A" counts "a" and "A" alike
	#   see        CountCS, CountItemsW
	def Count(pItem)
		return This.CountCS(pItem, 1)

		def NumberOfOccurrencesOf(pItem)
			return This.Count(pItem)

	  #======================================================#
	 #   COUNT ITEMS SATISFYING A PREDICATE                 #
	#======================================================#

	def CountIf(pcCondition)
		return This.CountItemsW(pcCondition)

		def HowManyIf(pcCondition)
			return This.CountIf(pcCondition)

	  #======================================================#
	 #   COUNT EMPTY / NON-EMPTY ITEMS                      #
	#======================================================#

	# Returns how many items are the empty text.
	#
	#   returns    a number
	#   note       an empty sublist or the number 0 is not an empty item
	#   see        CountNonEmptyItems
	def CountEmptyItems()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_nCount_ = 0
		for i = 1 to _nLen_
			if isString(_aContent_[i]) and _aContent_[i] = ""
				_nCount_++
			ok
		next
		return _nCount_

		def NumberOfEmptyItems()
			return This.CountEmptyItems()

	# Returns how many items are anything but the empty text.
	#
	#   returns    a number
	#   see        CountEmptyItems
	def CountNonEmptyItems()
		return This.NumberOfItems() - This.CountEmptyItems()

		def NumberOfNonEmptyItems()
			return This.CountNonEmptyItems()
