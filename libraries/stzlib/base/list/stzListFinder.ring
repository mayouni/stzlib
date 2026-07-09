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

class stzListFinder from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

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

	def Content()
		return @oList.Content()

	def NumberOfItems()
		return @oList.NumberOfItems()

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
			if _pFaoList_ != NULL
				_pFaoResult_ = StzEngineListFindAllStringCS(_pFaoList_, pItem, pCaseSensitive)
				StzEngineListFree(_pFaoList_)
				if _pFaoResult_ != NULL
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

	#-- WITHOUT CASESENSITIVITY

	def FindAllOccurrences(pItem)
		_aResult_ = This.FindAllOccurrencesCS(pItem, 1)
		return _aResult_

		def FindAllOccurrencesQ(pItem)
			return This.FindAllOccurrencesQRT(pItem, :stzList)

		def FindAllOccurrencesQRT(pItem, pcReturnType)
			return This.FindAllOccurrencesCSQRT(pItem, 1, pcReturnType)

		def FindAll(pItem)
			return This.FindAllOccurrences(pItem)

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

	def AntiFindAsSections(pItem)
		return This.AntiFindAsSectionsCS(pItem, 1)

		def AntiFindZZ(pItem)
			return This.AntiFindAsSections(pItem)

	  #-----------------------------------------------------------------#
	 #  GETTING THE ANTI-POSITIONS OF THE GIVEN POSITIONS IN THE LIST  #
	#-----------------------------------------------------------------#

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

	def FindAllExceptLast(pItem)
		return This.FindAllExceptLastCS(pItem, 1)

	  #=============================================#
	 #  NUMBER OF OCCURRENCES OF AN ITEM          #
	#=============================================#

	def NumberOfOccurrenceCS(pItem, pCaseSensitive)
		return len( This.FindAllCS(pItem, pCaseSensitive) )

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

	def FindNextNthOccurrence(n, pItem, pnStartingAt)
		return This.FindNextNthOccurrenceCS(n, pItem, pnStartingAt, 1)

	  #=====================================#
	 #  FINDING NEXT OCCURRENCE           #
	#=====================================#

	def FindNextOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		return This.FindNextNthOccurrenceCS(1, pItem, pnStartingAt, pCaseSensitive)

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

	def FindPreviousNthOccurrence(n, pItem, pnStartingAt)
		return This.FindPreviousNthOccurrenceCS(n, pItem, pnStartingAt, 1)

	  #========================================#
	 #  FINDING PREVIOUS OCCURRENCE          #
	#========================================#

	def FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		return This.FindPreviousNthOccurrenceCS(1, pItem, pnStartingAt, pCaseSensitive)

	def FindPreviousOccurrence(pItem, pnStartingAt)
		return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, 1)

	  #=====================================#
	 #  COUNTING ITEMS UNDER A CONDITION  #
	#=====================================#

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
			if _pCtList != NULL
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

	def FindNextOccurrences(pItem, pnStartingAt)
		return This.FindNextOccurrencesCS(pItem, pnStartingAt, 1)

		def FindNextOccurrencesST(pItem, pnStartingAt)
			return This.FindNextOccurrences(pItem, pnStartingAt)

	def FindPreviousOccurrencesCS(pItem, pnStartingAt, pCaseSensitive)
		return This._FnBefore(This._FnVal(pItem), This._FnVal(pnStartingAt), pCaseSensitive)

	def FindPreviousOccurrences(pItem, pnStartingAt)
		return This.FindPreviousOccurrencesCS(pItem, pnStartingAt, 1)

		def FindPreviousOccurrencesST(pItem, pnStartingAt)
			return This.FindPreviousOccurrences(pItem, pnStartingAt)

	#-- the n-th occurrence after a position (forward; handles :Of/:StartingAt)
	def FindNthNextOccurrence(n, pItem, pnStartingAt)
		_a_ = This._FnAfter(This._FnVal(pItem), This._FnVal(pnStartingAt), 1)
		if n >= 1 and n <= len(_a_) return _a_[n] ok
		return 0

		def FindNextNth(n, pItem, pnStartingAt)
			return This.FindNthNextOccurrence(n, pItem, pnStartingAt)

	def FindNext(pItem, pnStartingAt)
		return This.FindNthNextOccurrence(1, pItem, pnStartingAt)

		def FindFirstNext(pItem, pnStartingAt)
			return This.FindNext(pItem, pnStartingAt)

	#-- nearest occurrence before a position (and its forward-indexed nth)
	def FindPrevious(pItem, pnStartingAt)
		_a_ = This._FnBefore(This._FnVal(pItem), This._FnVal(pnStartingAt), 1)
		if len(_a_) > 0 return _a_[ len(_a_) ] ok
		return 0

		def FindFirstPrevious(pItem, pnStartingAt)
			return This.FindPrevious(pItem, pnStartingAt)

	#-- the listed nths (forward index) after / before a position
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
