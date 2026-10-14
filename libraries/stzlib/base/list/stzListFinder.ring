#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTFINDER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List finder subclass -- finding items,      #
#                  positions, anti-positions, occurrences.      #
#                  For aliases, use stzListFinderXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Finds where an item occurs in a list, as positions: all, first, last, nth, the ones that differ, or those before or after a position.
#
# It is the search helper of stzList, which builds one over itself for its Find methods; build one
# with new stzListFinder when you only need to search. It never edits the list, so a stzList passed
# in stays intact. Positions are 1-based, and an absent item answers 0 for the single-position verbs
# and [ ] for the list verbs. Items are matched whole: a text, a number or a sublist, and Hebrew,
# Arabic and emoji texts match as one item each. Case counts unless you call the CS form with 0. The
# Next verbs look strictly after a position and count ranks forward; FindPreviousNthOccurrence
# counts ranks backward from the position, while FindPreviousNthOccurrences counts them forward from
# the start. Found today: AntiFind and AntiFindAsSections answer a wrong list for an empty list, and
# CountItemsW raises R14.
#
#   receiver   o1 = new stzListFinder([ "a", "b", "a", "c", "a" ])
#   example    ? @@( o1.Find("a") )
#              #--> [ 1, 3, 5 ]
#              ? @@( o1.AntiFind("a") )
#              #--> [ 2, 4 ]
#              ? o1.FindNextOccurrence("a", 1)
#              #--> 3
#              o2 = new stzListFinder([ "שלום", "مرحبا", "😀", "שלום", "😀" ])
#              ? @@( o2.Find("😀") )
#              #--> [ 3, 5 ]
#   see        stzList, stzListOfNumbers, stzStringFinder
class stzListFinder from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a finder over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to search, or a stzList
	#   returns      nothing; the object is built
	#   note         finding never edits the list, so a stzList passed in stays intact; stzList
	#                builds one over itself for its find methods
	#   see          Content, Find
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListFinder! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list being searched.
	#
	#   returns    a list
	#   see        NumberOfItems, IsEmpty
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

	  #======================================#
	 #  FINDING ALL OCCURRENCES OF AN ITEM  #
	#======================================#

	def FindAllOccurrencesCS(pItem, pCaseSensitive)

		if CheckingParams()

			if isList(pItem) and IsOfNamedParamList(pItem)
				pItem = pItem[2]
			ok

			if isObject(pItem) and NOT @IsNamedObject(pItem)
				StzRaise("Can't find an unnamed object!")
			ok

			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				pCaseSensitive = pCaseSensitive[2]
			ok

		ok

		_aFaoContent_ = This.Content()
		_nFaoLen_ = len(_aFaoContent_)

		if EarlyCheck()
			if _nFaoLen_ = 0
				return []
			ok
		ok

		# Engine-backed fast path for string items
		if isString(pItem)
			_pFaoList_ = @oList._EngineListFromContent()
			if _pFaoList_ != ""
				_pFaoResult_ = StzEngineListFindAllStringCS(_pFaoList_, pItem, pCaseSensitive)
				StzEngineListFree(_pFaoList_)
				if _pFaoResult_ != ""
					_anFaoResult_ = @oList._ContentFromEngineList(_pFaoResult_)
					StzEngineListFree(_pFaoResult_)
					return _anFaoResult_
				else
					return []
				ok
			ok
		ok

		# Fallback for numbers and other types
		_anFaoResult2_ = @FindAllCS_NbrOrStr( _aFaoContent_, pItem, pCaseSensitive)

		if isList(_anFaoResult2_) and len(_anFaoResult2_) > 0
			return _anFaoResult2_

		else
			_cFaoItem_ = ""
			if isList(pItem)
				_cFaoItem_ = @@(pItem)

			but isObject(pItem) and @IsStzObject(pItem) and pItem.IsNamed()
				_cFaoItem_ = pItem.ObjectName()

			else
				_cFaoItem_ = Q(pItem).Stringified()

			ok

			_aFaoRawContent_ = This.Content()
			_nFaoLenRaw_ = len(_aFaoRawContent_)
			_acFaoContent_ = []
			for _kFao_ = 1 to _nFaoLenRaw_
				# Type-aware stringify (mirrors the needle above): a bare
				# "" + item throws R21 when the item is a list/object.
				_xFao_ = _aFaoRawContent_[_kFao_]
				if isList(_xFao_)
					@AddItem(_acFaoContent_, @@(_xFao_))
				but isObject(_xFao_) and @IsStzObject(_xFao_) and _xFao_.IsNamed()
					@AddItem(_acFaoContent_, _xFao_.ObjectName())
				else
					@AddItem(_acFaoContent_, Q(_xFao_).Stringified())
				ok
			next
			_nFaoLen2_ = len(_acFaoContent_)

			if pCaseSensitive = 0
				_cFaoItem_ = StzLower(_cFaoItem_)

				for _iFao_ = 1 to _nFaoLen2_
					if NOT ring_isLower(_acFaoContent_[_iFao_])
						_acFaoContent_[_iFao_] = StzLower(_acFaoContent_[_iFao_])
					ok
				next
			ok

			_anFaoResult3_ = []

			for _jFao_ = 1 to _nFaoLen2_
				if _acFaoContent_[_jFao_] = _cFaoItem_
					@AddItem(_anFaoResult3_, _jFao_)
				ok
			next

			return _anFaoResult3_
		ok

		def FindAllOccurrencesCSQ(pItem, pCaseSensitive)
			return This.FindAllOccurrencesCSQRT(pItem, pCaseSensitive, :stzList)

		def FindAllOccurrencesCSQRT(pItem, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType, [ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllCS(pItem, pCaseSensitive) )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllCS(pItem, pCaseSensitive) )
			other
				StzRaise("Unsupported type!")
			off

		def FindAllCS(pItem, pCaseSensitive)
			return This.FindAllOccurrencesCS(pItem, pCaseSensitive)

		def FindCS(pItem, pCaseSensitive)
			if isList(pItem) and IsItemNamedParamList(pItem)
				pItem = pItem[2]
			ok
			return This.FindAllOccurrencesCS(pItem, pCaseSensitive)

	# Returns the position of every item equal to the given one, as a list of numbers.
	#
	#   pItem      the item to look for: a text, a number, or a list
	#   returns    a list of 1-based positions; [ ] when the item is absent
	#   note       a b a c a d A with a gives [ 1, 3, 5 ], and FindAllOccurrencesCS(item, 0) also
	#              finds the A at 7; Find is the same call; texts in Hebrew, Arabic and emoji are
	#              matched whole
	#   see        Find, FindFirst, FindNth, AntiFind
	#@ aka  -- WITHOUT CASESENSITIVITY
	def FindAllOccurrences(pItem)
		_aResult_ = This.FindAllOccurrencesCS(pItem, 1)
		return _aResult_

		def FindAllOccurrencesQ(pItem)
			return This.FindAllOccurrencesQRT(pItem, :stzList)

		def FindAllOccurrencesQRT(pItem, pcReturnType)
			return This.FindAllOccurrencesCSQRT(pItem, 1, pcReturnType)

		def FindAll(pItem)
			return This.FindAllOccurrences(pItem)

		# Returns the position of every item equal to the given one, as a list of numbers.
		#
		#   pItem      the item to look for: a text, a number, or a list
		#   returns    a list of 1-based positions; [ ] when the item is absent
		#   note       a b a c a d A with a gives [ 1, 3, 5 ]; FindCS(item, 0) ignores case; a
		#              sublist such as [ 1, 2 ] is matched as a whole
		#   see        FindAllOccurrences, FindFirst, AntiFind
		def Find(pItem)
			if isList(pItem) and IsItemNamedParamList(pItem)
				pItem = pItem[2]
			ok
			return This.FindAllOccurrences(pItem)

	  #====================================================#
	 #  FINDING POSITIONS WHERE THE ITEM DOES NOT EXIST   #
	#====================================================#

	def AntiFindCS(pItem, pCaseSensitive)
		_anPos_ = This.FindAllCS(pItem, pCaseSensitive)
		_anResult_ = Q(1:This.NumberOfItems()) - These(_anPos_)
		return _anResult_

	# Returns the positions of the items that differ from the given one.
	#
	#   pItem      the item to avoid
	#   returns    a list of 1-based positions
	#   note       a b a c a d A without a gives [ 2, 4, 6, 7 ]; AntiFindCS(item, 0) ignores case
	#   warning    an empty list answers [ 1, 0 ] where [ ] is expected, because the positions are
	#              built as the range 1 to 0 (an empty list with a, and with b)
	#   see        Find, AntiFindAsSections, AntiPositions
	def AntiFind(pItem)
		return This.AntiFindCS(pItem, 1)

	  #--------------------------------------------------#
	 #  FINDING SECTIONS WHERE THE ITEM DOES NOT EXIST  #
	#--------------------------------------------------#

	def AntiFindAsSectionsCS(pItem, pCaseSensitive)
		_anPos_ = This.FindCS(pItem, pCaseSensitive)
		_aResult_ = StzListQ(1:This.NumberOfItems()).AntiPositionsZZ(_anPos_)
		return _aResult_

		def AntiFindCSZZ(pItem, pCaseSensitive)
			return This.AntiFindAsSectionsCS(pItem, pCaseSensitive)

	# Returns the runs of consecutive positions whose items differ from the given one, as [start, end] pairs.
	#
	#   pItem      the item to avoid
	#   returns    a list of [ number, number ] pairs; [ ] when every item matches
	#   note       a b a c a d A without a gives [ [ 2, 2 ], [ 4, 4 ], [ 6, 7 ] ]; AntiFindZZ is the
	#              same call
	#   warning    an empty list answers [ [ 1, 2 ] ] instead of [ ] (an empty list with a)
	#   see        AntiFind, Find
	def AntiFindAsSections(pItem)
		return This.AntiFindAsSectionsCS(pItem, 1)

		def AntiFindZZ(pItem)
			return This.AntiFindAsSections(pItem)

	  #-----------------------------------------------------------------#
	 #  GETTING THE ANTI-POSITIONS OF THE GIVEN POSITIONS IN THE LIST  #
	#-----------------------------------------------------------------#

	# Returns the positions of the list that are not in the given list of positions.
	#
	#   _anPos_    the list of positions to leave out
	#   returns    a list of 1-based positions, ascending
	#   note       a list of seven items with [ 2, 3 ] gives [ 1, 4, 5, 6, 7 ]; an empty list of
	#              positions gives every position
	#   see        AntiFind, Find
	def AntiPositions(_anPos_)

		if CheckingParams()
			if isList(_anPos_) and IsOfNamedParamList(_anPos_)
				_anPos_ = _anPos_[2]
			ok

			if NOT isList(_anPos_)
				Stzraise("Incorrect param type! anPos must be a list of numbers.")
			ok
		ok

		_nApTotal_ = len(@oList.Content())
		_nApPosLen_ = len(_anPos_)

		_aApMarked_ = []
		for _kAp_ = 1 to _nApTotal_
			@AddItem(_aApMarked_, 0)
		next
		for _iAp_ = 1 to _nApPosLen_
			_nApN_ = _anPos_[_iAp_]
			if _nApN_ >= 1 and _nApN_ <= _nApTotal_
				_aApMarked_[_nApN_] = 1
			ok
		next

		_anApResult_ = []
		for _jAp_ = 1 to _nApTotal_
			if _aApMarked_[_jAp_] != 1
				@AddItem(_anApResult_, _jAp_)
			ok
		next

		return _anApResult_

	  #=================================================#
	 #    FINDING N OCCURRENCES OF AN ITEM             #
	#=================================================#

	def FindNOccurrencesCS(n, pItem, pCaseSensitive)

		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok

		_anFnoAll_ = This.FindAllCS(pItem, pCaseSensitive)

		if n > len(_anFnoAll_)
			return _anFnoAll_
		ok

		_aFnoResult_ = []
		for _iFno_ = 1 to n
			@AddItem(_aFnoResult_, _anFnoAll_[_iFno_])
		next

		return _aFnoResult_

	# Returns the positions of the first n occurrences of an item.
	#
	#   n          how many occurrences to keep, counted from the start
	#   pItem      the item to look for
	#   returns    a list of positions, fewer than n when the item occurs fewer times; [ ] for 0
	#   note       a b a c a d A with 2 and a gives [ 1, 3 ]; with 9 it gives all three
	#   see        FindAllOccurrences, FindGivenOccurrences, FindFirst
	def FindNOccurrences(n, pItem)
		return This.FindNOccurrencesCS(n, pItem, 1)

	  #==================================================#
	 #  FINDING FIRST OCCURRENCE OF AN ITEM IN THE LIST #
	#==================================================#

	def FindFirstCS(pItem, pCaseSensitive)
		_anFfPos_ = This.FindAllCS(pItem, pCaseSensitive)
		if len(_anFfPos_) > 0
			return _anFfPos_[1]
		else
			return 0
		ok

	# Returns the position of the first occurrence of an item.
	#
	#   pItem      the item to look for
	#   returns    a number; 0 when the item is absent
	#   note       FindFirstCS(item, 0) ignores case
	#   see        FindLast, FindNth, Find
	def FindFirst(pItem)
		return This.FindFirstCS(pItem, 1)

	  #=================================================#
	 #  FINDING LAST OCCURRENCE OF AN ITEM IN THE LIST #
	#=================================================#

	def FindLastCS(pItem, pCaseSensitive)
		_anFlPos_ = This.FindAllCS(pItem, pCaseSensitive)
		_nFlLen_ = len(_anFlPos_)
		if _nFlLen_ > 0
			return _anFlPos_[_nFlLen_]
		else
			return 0
		ok

	# Returns the position of the last occurrence of an item.
	#
	#   pItem      the item to look for
	#   returns    a number; 0 when the item is absent
	#   note       FindLastCS(item, 0) ignores case; a b a c a d A with a gives 5
	#   see        FindFirst, FindNth
	def FindLast(pItem)
		return This.FindLastCS(pItem, 1)

	  #=============================================#
	 #   FINDING NTH OCCURRENCE OF AN ITEM        #
	#=============================================#

	def FindNthCS(n, pItem, pCaseSensitive)

		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok

		_anFnPos_ = This.FindAllCS(pItem, pCaseSensitive)
		_nFnLen_ = len(_anFnPos_)

		if n > _nFnLen_ or n < 1
			return 0
		ok

		return _anFnPos_[n]

	# Returns the position of the occurrence of an item that has the given rank, counted from 1.
	#
	#   n          the rank of the occurrence, 1 for the first
	#   pItem      the item to look for
	#   returns    a number; 0 when the rank is 0, negative or past the last occurrence
	#   note       a b a c a d A with rank 2 of a gives 3; FindNthCS(n, item, 0) ignores case
	#   see        FindFirst, FindLast, FindNOccurrences
	def FindNth(n, pItem)
		return This.FindNthCS(n, pItem, 1)

	  #=============================================#
	 #   FINDING GIVEN OCCURRENCES OF AN ITEM     #
	#=============================================#

	def FindGivenOccurrencesCS(panOccurrences, pItem, pCaseSensitive)

		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok

		_anFgoPos_ = This.FindAllCS(pItem, pCaseSensitive)
		_nFgoLenPos_ = len(_anFgoPos_)
		_nFgoLenOcc_ = len(panOccurrences)

		_anFgoResult_ = []
		for _iFgo_ = 1 to _nFgoLenOcc_
			_nFgoN_ = panOccurrences[_iFgo_]
			if _nFgoN_ >= 1 and _nFgoN_ <= _nFgoLenPos_
				@AddItem(_anFgoResult_, _anFgoPos_[_nFgoN_])
			ok
		next

		return _anFgoResult_

	# Returns the positions of the occurrences that have the listed ranks.
	#
	#   panOccurrences   the list of ranks wanted, 1 for the first
	#   pItem            the item to look for
	#   returns          a list of positions; ranks past the last occurrence are skipped
	#   note             a b a c a d A with ranks [ 1, 3 ] of a gives [ 1, 5 ]; with [ 3, 9 ] it
	#                    gives [ 5 ]
	#   see              FindNth, FindNOccurrences
	def FindGivenOccurrences(panOccurrences, pItem)
		return This.FindGivenOccurrencesCS(panOccurrences, pItem, 1)

	  #============================================#
	 #   FINDING THE OCCURRENCES OF MANY ITEMS   #
	#============================================#

	def FindManyCS(paItems, pCaseSensitive)
		_nFmLen = len(paItems)
		_aFmMerged = []

		for _iFm = 1 to _nFmLen
			_aFmPos = This.FindAllCS(paItems[_iFm], pCaseSensitive)
			_nFmPosLen = len(_aFmPos)
			for _jFm = 1 to _nFmPosLen
				_aFmMerged + _aFmPos[_jFm]
			next
		next

		_oTmp = new stzList(_aFmMerged)
		_aFmMerged = _oTmp.Sorted()
		return _aFmMerged

	def FindMany(paItems)
		return This.FindManyCS(paItems, 1)

	  #===============================================#
	 #  FINDING ALL EXCEPT FIRST OCCURRENCE         #
	#===============================================#

	def FindAllExceptFirstCS(pItem, pCaseSensitive)
		_anFefPos_ = This.FindAllCS(pItem, pCaseSensitive)
		_nFefLen_ = len(_anFefPos_)

		if _nFefLen_ <= 1
			return []
		ok

		_aFefResult_ = []
		for _iFef_ = 2 to _nFefLen_
			@AddItem(_aFefResult_, _anFefPos_[_iFef_])
		next

		return _aFefResult_

	# Returns the positions of every occurrence of an item except the first.
	#
	#   pItem      the item to look for
	#   returns    a list of positions; [ ] when the item occurs once or not at all
	#   note       a b a c a d A with a gives [ 3, 5 ]; FindAllExceptFirstCS(item, 0) ignores case
	#   see        FindAllExceptLast, Find
	def FindAllExceptFirst(pItem)
		return This.FindAllExceptFirstCS(pItem, 1)

	  #==============================================#
	 #  FINDING ALL EXCEPT LAST OCCURRENCE         #
	#==============================================#

	def FindAllExceptLastCS(pItem, pCaseSensitive)
		_anFelPos_ = This.FindAllCS(pItem, pCaseSensitive)
		_nFelLen_ = len(_anFelPos_)

		if _nFelLen_ <= 1
			return []
		ok

		_aFelResult_ = []
		for _iFel_ = 1 to _nFelLen_ - 1
			@AddItem(_aFelResult_, _anFelPos_[_iFel_])
		next

		return _aFelResult_

	# Returns the positions of every occurrence of an item except the last.
	#
	#   pItem      the item to look for
	#   returns    a list of positions; [ ] when the item occurs once or not at all
	#   note       a b a c a d A with a gives [ 1, 3 ]; FindAllExceptLastCS(item, 0) ignores case
	#   see        FindAllExceptFirst, Find
	def FindAllExceptLast(pItem)
		return This.FindAllExceptLastCS(pItem, 1)

	  #=============================================#
	 #  NUMBER OF OCCURRENCES OF AN ITEM          #
	#=============================================#

	def NumberOfOccurrenceCS(pItem, pCaseSensitive)
		return len( This.FindAllCS(pItem, pCaseSensitive) )

	# Returns how many times an item occurs in the list.
	#
	#   pItem      the item to count
	#   returns    a number; 0 when absent
	#   note       a b a c a d A with a gives 3, and 4 when case is ignored
	#              (NumberOfOccurrenceCS(item, 0))
	#   see        Find, Contains
	def NumberOfOccurrence(pItem)
		return This.NumberOfOccurrenceCS(pItem, 1)

	  #=====================================#
	 #  FINDING NEXT NTH OCCURRENCE       #
	#=====================================#

	def FindNextNthOccurrenceCS(n, pItem, pnStartingAt, pCaseSensitive)

		if isList(pItem) and len(pItem) = 2 and isString(pItem[1]) and lower(pItem[1]) = "of"
			pItem = pItem[2]
		ok

		if isList(pnStartingAt) and IsStartingAtNamedParamList(pnStartingAt)
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if pnStartingAt = :First or pnStartingAt = :FirstItem
				pnStartingAt = 1
			but pnStartingAt = :Last or pnStartingAt = :LastItem
				pnStartingAt = This.NumberOfItems()
			ok
		ok

		_anFnnoPos_ = This.FindAllCS(pItem, pCaseSensitive)
		_nFnnoLen_ = len(_anFnnoPos_)

		_nFnnoCount_ = 0
		for _iFnno_ = 1 to _nFnnoLen_
			if _anFnnoPos_[_iFnno_] > pnStartingAt
				_nFnnoCount_++
				if _nFnnoCount_ = n
					return _anFnnoPos_[_iFnno_]
				ok
			ok
		next

		return 0

	# Returns the position of the occurrence with the given rank among those lying after a position, counted forward.
	#
	#   n              the rank among the later occurrences, 1 for the nearest
	#   pItem          the item to look for
	#   pnStartingAt   the position after which to look, which is excluded
	#   returns        a number; 0 when there are fewer occurrences
	#   note           a b a c a d A from 2: rank 1 of a gives 3, rank 2 gives 5, rank 9 gives 0;
	#                  FindNextNthOccurrenceCS adds the case flag
	#   see            FindNextOccurrence, FindPreviousNthOccurrence
	def FindNextNthOccurrence(n, pItem, pnStartingAt)
		return This.FindNextNthOccurrenceCS(n, pItem, pnStartingAt, 1)

	  #=====================================#
	 #  FINDING NEXT OCCURRENCE           #
	#=====================================#

	def FindNextOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		return This.FindNextNthOccurrenceCS(1, pItem, pnStartingAt, pCaseSensitive)

	# Returns the position of the nearest occurrence of an item after a position.
	#
	#   pItem          the item to look for
	#   pnStartingAt   the position after which to look, which is excluded
	#   returns        a number; 0 when there is none
	#   note           a b a c a d A from 1 gives 3, from 5 gives 0, from 0 gives 1
	#   see            FindNextNthOccurrence, FindPreviousOccurrence, FindNext
	def FindNextOccurrence(pItem, pnStartingAt)
		return This.FindNextOccurrenceCS(pItem, pnStartingAt, 1)

	  #========================================#
	 #  FINDING PREVIOUS NTH OCCURRENCE      #
	#========================================#

	def FindPreviousNthOccurrenceCS(n, pItem, pnStartingAt, pCaseSensitive)

		if isList(pItem) and len(pItem) = 2 and isString(pItem[1]) and lower(pItem[1]) = "of"
			pItem = pItem[2]
		ok

		if isList(pnStartingAt) and IsStartingAtNamedParamList(pnStartingAt)
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if pnStartingAt = :First or pnStartingAt = :FirstItem
				pnStartingAt = 1
			but pnStartingAt = :Last or pnStartingAt = :LastItem
				pnStartingAt = This.NumberOfItems()
			ok
		ok

		_anFpnoPos_ = This.FindAllCS(pItem, pCaseSensitive)
		_nFpnoLen_ = len(_anFpnoPos_)

		_nFpnoCount_ = 0
		for _iFpno_ = _nFpnoLen_ to 1 step -1
			if _anFpnoPos_[_iFpno_] < pnStartingAt
				_nFpnoCount_++
				if _nFpnoCount_ = n
					return _anFpnoPos_[_iFpno_]
				ok
			ok
		next

		return 0

	# Returns the position of the occurrence with the given rank among those lying before a position, counted backward from the nearest.
	#
	#   n              the rank counting back from the position, 1 for the nearest
	#   pItem          the item to look for
	#   pnStartingAt   the position before which to look, which is excluded
	#   returns        a number; 0 when there are fewer occurrences
	#   note           a b a c a d A from 5: rank 1 of a gives 3, rank 2 gives 1, rank 9 gives 0;
	#                  unlike FindPreviousNthOccurrences, whose ranks count forward
	#   see            FindPreviousOccurrence, FindNextNthOccurrence, FindPreviousNthOccurrences
	def FindPreviousNthOccurrence(n, pItem, pnStartingAt)
		return This.FindPreviousNthOccurrenceCS(n, pItem, pnStartingAt, 1)

	  #========================================#
	 #  FINDING PREVIOUS OCCURRENCE          #
	#========================================#

	def FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		return This.FindPreviousNthOccurrenceCS(1, pItem, pnStartingAt, pCaseSensitive)

	# Returns the position of the nearest occurrence of an item before a position.
	#
	#   pItem          the item to look for
	#   pnStartingAt   the position before which to look, which is excluded
	#   returns        a number; 0 when there is none
	#   note           a b a c a d A from 5 gives 3, from 1 gives 0, from 8 gives 5
	#   see            FindPreviousNthOccurrence, FindNextOccurrence, FindPrevious
	def FindPreviousOccurrence(pItem, pnStartingAt)
		return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, 1)

	  #=====================================#
	 #  COUNTING ITEMS UNDER A CONDITION  #
	#=====================================#

	# Raises error R14 today instead of counting the items that satisfy a W condition.
	#
	#   pcCondition   the condition as text, such as @item = 'a'
	#   returns       nothing
	#   note          count with Find and its length, or use stzList
	#   warning       raises Calling Method without definition: countw for every condition (two
	#                 conditions tried), because the class it calls has no CountW
	#   see           NumberOfOccurrence, Find
	def CountItemsW(pcCondition)

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		return This.CountW(pcCondition)

	  #==============================#
	 #  CONTAINS                    #
	#==============================#

	def ContainsCS(pItem, pCaseSensitive)
		if isString(pItem)
			_pCtList = @oList._EngineListFromContent()
			if _pCtList != ""
				_nCtResult = StzEngineListContainsStringCS(_pCtList, pItem, pCaseSensitive)
				StzEngineListFree(_pCtList)
				return _nCtResult
			ok
		ok

		_nCtLen = len(This.FindAllCS(pItem, pCaseSensitive))
		if _nCtLen > 0
			return 1
		else
			return 0
		ok

	# TRUE if the list holds the given item.
	#
	#   pItem      the item to look for
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       ContainsCS(item, 0) ignores case: B is found in a b a c a d A only that way
	#   see        NumberOfOccurrence, Find
	def Contains(pItem)
		return This.ContainsCS(pItem, 1)

	def ContainsManyCS(paItems, pCaseSensitive)
		_nLen_ = len(paItems)
		for i = 1 to _nLen_
			if NOT This.ContainsCS(paItems[i], pCaseSensitive)
				return 0
			ok
		next
		return 1

	def ContainsMany(paItems)
		return This.ContainsManyCS(paItems, 1)

	  #=========================================================#
	 #  NEXT / PREVIOUS OCCURRENCE SEARCH (from a position)    #
	#=========================================================#

	def _FnVal(p)
		if isList(p) and len(p) = 2 and isString(p[1])
			return p[2]
		ok
		return p

	#-- positions of pItem strictly AFTER nStart (forward order)
	def _FnAfter(pItem, nStart, pCaseSensitive)
		_all_ = This.FindAllCS(pItem, pCaseSensitive)
		_res_ = []
		_n_ = len(_all_)
		for _i_ = 1 to _n_
			if _all_[_i_] > nStart
				_res_ + _all_[_i_]
			ok
		next
		return _res_

	#-- positions of pItem strictly BEFORE nStart (forward order)
	def _FnBefore(pItem, nStart, pCaseSensitive)
		_all_ = This.FindAllCS(pItem, pCaseSensitive)
		_res_ = []
		_n_ = len(_all_)
		for _i_ = 1 to _n_
			if _all_[_i_] < nStart
				_res_ + _all_[_i_]
			ok
		next
		return _res_

	#-- ALL occurrences after / before a position
	def FindNextOccurrencesCS(pItem, pnStartingAt, pCaseSensitive)
		return This._FnAfter(This._FnVal(pItem), This._FnVal(pnStartingAt), pCaseSensitive)

	# Returns the positions of every occurrence of an item after a position.
	#
	#   pItem          the item to look for
	#   pnStartingAt   the position after which to look, which is excluded
	#   returns        a list of positions in ascending order; [ ] when there is none
	#   note           a b a c a d A from 1 gives [ 3, 5 ]; FindNextOccurrencesST is the same call
	#   see            FindPreviousOccurrences, FindNextOccurrence
	def FindNextOccurrences(pItem, pnStartingAt)
		return This.FindNextOccurrencesCS(pItem, pnStartingAt, 1)

		def FindNextOccurrencesST(pItem, pnStartingAt)
			return This.FindNextOccurrences(pItem, pnStartingAt)

	def FindPreviousOccurrencesCS(pItem, pnStartingAt, pCaseSensitive)
		return This._FnBefore(This._FnVal(pItem), This._FnVal(pnStartingAt), pCaseSensitive)

	# Returns the positions of every occurrence of an item before a position.
	#
	#   pItem          the item to look for
	#   pnStartingAt   the position before which to look, which is excluded
	#   returns        a list of positions in ascending order; [ ] when there is none
	#   note           a b a c a d A from 5 gives [ 1, 3 ]; FindPreviousOccurrencesST is the same
	#                  call
	#   see            FindNextOccurrences, FindPreviousOccurrence
	def FindPreviousOccurrences(pItem, pnStartingAt)
		return This.FindPreviousOccurrencesCS(pItem, pnStartingAt, 1)

		def FindPreviousOccurrencesST(pItem, pnStartingAt)
			return This.FindPreviousOccurrences(pItem, pnStartingAt)

	# Returns the position of the occurrence with the given rank among those lying after a position, counted forward.
	#
	#   n              the rank among the later occurrences, 1 for the nearest
	#   pItem          the item to look for
	#   pnStartingAt   the position after which to look, which is excluded
	#   returns        a number; 0 when there are fewer occurrences
	#   note           the same answer as FindNextNthOccurrence: a b a c a d A from 1 with rank 2 of
	#                  a gives 5; FindNextNth is the same call
	#   see            FindNextNthOccurrence, FindNext
	#@ aka  -- the n-th occurrence after a position (forward; handles :Of/:StartingAt)
	def FindNthNextOccurrence(n, pItem, pnStartingAt)
		_a_ = This._FnAfter(This._FnVal(pItem), This._FnVal(pnStartingAt), 1)
		if n >= 1 and n <= len(_a_) return _a_[n] ok
		return 0

		def FindNextNth(n, pItem, pnStartingAt)
			return This.FindNthNextOccurrence(n, pItem, pnStartingAt)

	# Returns the position of the nearest occurrence of an item after a position.
	#
	#   pItem          the item to look for
	#   pnStartingAt   the position after which to look, which is excluded
	#   returns        a number; 0 when there is none
	#   note           the same answer as FindNextOccurrence: a b a c a d A from 1 gives 3;
	#                  FindFirstNext is the same call
	#   see            FindNextOccurrence, FindPrevious
	def FindNext(pItem, pnStartingAt)
		return This.FindNthNextOccurrence(1, pItem, pnStartingAt)

		def FindFirstNext(pItem, pnStartingAt)
			return This.FindNext(pItem, pnStartingAt)

	# Returns the position of the nearest occurrence of an item before a position.
	#
	#   pItem          the item to look for
	#   pnStartingAt   the position before which to look, which is excluded
	#   returns        a number; 0 when there is none
	#   note           the same answer as FindPreviousOccurrence: a b a c a d A from 5 gives 3;
	#                  FindFirstPrevious is the same call
	#   see            FindPreviousOccurrence, FindNext
	#@ aka  -- nearest occurrence before a position (and its forward-indexed nth)
	def FindPrevious(pItem, pnStartingAt)
		_a_ = This._FnBefore(This._FnVal(pItem), This._FnVal(pnStartingAt), 1)
		if len(_a_) > 0 return _a_[ len(_a_) ] ok
		return 0

		def FindFirstPrevious(pItem, pnStartingAt)
			return This.FindPrevious(pItem, pnStartingAt)

	# Returns the positions of the occurrences that have the listed ranks among those lying after a position.
	#
	#   panN           the list of ranks wanted, 1 for the nearest after the position
	#   pItem          the item to look for
	#   pnStartingAt   the position after which to look, which is excluded
	#   returns        a list of positions; ranks past the last occurrence are skipped
	#   note           a b a c a d A from 1 with ranks [ 1, 2 ] of a gives [ 3, 5 ]
	#   see            FindNextNthOccurrence, FindPreviousNthOccurrences
	#@ aka  -- the listed nths (forward index) after / before a position
	def FindNextNthOccurrencesST(panN, pItem, pnStartingAt)
		_a_ = This._FnAfter(This._FnVal(pItem), This._FnVal(pnStartingAt), 1)
		_res_ = []
		_nn_ = len(panN)
		for _i_ = 1 to _nn_
			if panN[_i_] >= 1 and panN[_i_] <= len(_a_)
				_res_ + _a_[ panN[_i_] ]
			ok
		next
		return _res_

	# Returns the positions of the occurrences with the listed ranks, counted from the list start, among those before a position.
	#
	#   panN           the list of ranks wanted, 1 for the first occurrence of the list
	#   pItem          the item to look for
	#   pnStartingAt   the position before which to look, which is excluded
	#   returns        a list of positions in forward order; ranks past the last occurrence are
	#                  skipped
	#   note           it has no case-flag form
	#   warning        the ranks count forward from the start, while FindPreviousNthOccurrence
	#                  counts backward from the position: a b a c a d A before 7 with ranks [ 1, 2 ]
	#                  of a gives [ 1, 3 ], where FindPreviousNthOccurrence(2, a, 7) gives 3
	#   see            FindPreviousNthOccurrence, FindNextNthOccurrencesST
	def FindPreviousNthOccurrences(panN, pItem, pnStartingAt)
		_a_ = This._FnBefore(This._FnVal(pItem), This._FnVal(pnStartingAt), 1)
		_res_ = []
		_nn_ = len(panN)
		for _i_ = 1 to _nn_
			if panN[_i_] >= 1 and panN[_i_] <= len(_a_)
				_res_ + _a_[ panN[_i_] ]
			ok
		next
		return _res_

	#-- FindItem: alias of Find (positions of the item)
	def FindItem(pItem)
		return This.Find(pItem)

	#-- bare (no "Find") aliases used by some narrations
	def NthNextOccurrence(n, pItem, pnStartingAt)
		return This.FindNthNextOccurrence(n, pItem, pnStartingAt)

	def NextNthOccurrence(n, pItem, pnStartingAt)
		return This.FindNthNextOccurrence(n, pItem, pnStartingAt)

	#-- FindPreviousNth: the n-th occurrence before a position, counted
	#-- backward (nearest first) -- delegates to the canonical search.
	def FindPreviousNth(n, pItem, pnStartingAt)
		return This.FindPreviousNthOccurrence(n, pItem, pnStartingAt)
