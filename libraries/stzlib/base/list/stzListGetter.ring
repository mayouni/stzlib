#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTGETTER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List getter subclass -- content access,    #
#                  nth/first/last items, N-first/N-last.      #
#                  For aliases, use stzListGetterXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListGetter from stzObject

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
			StzRaise("Can't create stzListGetter! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oList.Content()

	def List()
		return @oList.List()

	def NumberOfItems()
		return @oList.NumberOfItems()

	def IsEmpty()
		return @oList.IsEmpty()

	def ContentCS(pCaseSensitive)
		return This.List()

	def NthItem(_n_)
		if CheckingParams()
			if isList(_n_) and IsOneOfTheseNamedParamsList(_n_, [:At, :AtPosition, :ItemAt])
				_n_ = _n_[2]
			ok
		ok
		return This.List()[_n_]

	def FirstItem()
		return This.NthItem(1)

	def LastItem()
		return This.NthItem(This.NumberOfItems())

	def CentralItem()
		_nCiN_ = ceil(This.NumberOfItems() / 2)
		return This.NthItem(_nCiN_)

	def NFirstItems(_n_)
		_aNfResult_ = []
		for _iNf_ = 1 to _n_
			_aNfResult_ + This.List()[_iNf_]
		next
		return _aNfResult_

		def NFirstItemsQ(_n_)
			return new stzList(This.NFirstItems(_n_))

	def NLastItems(_n_)
		_nNlLen_ = This.NumberOfItems()
		_aNlResult_ = []
		for _iNl_ = _nNlLen_ - _n_ + 1 to _nNlLen_
			_aNlResult_ + This.List()[_iNl_]
		next
		return _aNlResult_

		def NLastItemsQ(_n_)
			return new stzList(This.NLastItems(_n_))

	  #======================================================#
	 #   ITEMS AT POSITIONS                                 #
	#======================================================#

	def ItemsAtPositions(panPositions)
		_aIapResult_ = []
		_nIapLen_ = len(panPositions)
		for _iIap_ = 1 to _nIapLen_
			_aIapResult_ + This.List()[panPositions[_iIap_]]
		next
		return _aIapResult_

		def ItemsAt(panPositions)
			return This.ItemsAtPositions(panPositions)

	  #======================================================#
	 #   SECTION / RANGE                                    #
	#======================================================#

	def Section(_n1_, _n2_)
		_nScLen_ = This.NumberOfItems()
		if _n1_ < 1 _n1_ = 1 ok
		if _n2_ > _nScLen_ _n2_ = _nScLen_ ok
		if _n1_ > _n2_
			_nScTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nScTemp_
		ok
		_pScList_ = @oList._EngineListFromContent()
		if _pScList_ != NULL
			_pScResult_ = StzEngineListSection(_pScList_, _n1_, _n2_)
			if _pScResult_ != NULL
				_aScResult_ = @oList._ContentFromEngineList(_pScResult_)
				StzEngineListFree(_pScResult_)
				StzEngineListFree(_pScList_)
				return _aScResult_
			ok
			StzEngineListFree(_pScList_)
		ok
		_aScFallback_ = []
		for _iSc_ = _n1_ to _n2_
			_aScFallback_ + This.List()[_iSc_]
		next
		return _aScFallback_

	def Range(pnStart, pnRange)
		return This.Section(pnStart, pnStart + pnRange - 1)

	  #======================================================#
	 #   UNIQUE ITEMS                                       #
	#======================================================#

	# The unique items of the list, in first-seen order.
	def UniqueItemsCS(pCaseSensitive)
		_pUiList_ = @oList._EngineListFromContent()
		_pUiResult_ = StzEngineListUniqueCS(_pUiList_, pCaseSensitive)
		_aUiResult_ = StzEngineListContentToRingList(_pUiResult_)
		StzEngineListFree(_pUiResult_)
		StzEngineListFree(_pUiList_)
		return _aUiResult_

	def UniqueItems()
		return This.UniqueItemsCS(1)

	  #======================================================#
	 #   RANDOM ITEM                                        #
	#======================================================#

	# One item picked at random.
	def RandomItem()
		_nRdN_ = random(This.NumberOfItems() - 1) + 1
		return This.NthItem(_nRdN_)

	# n items picked at random.
	def NRandomItems(_n_)
		_pNriList_ = @oList._EngineListFromContent()
		if _pNriList_ != NULL
			_pNriResult_ = StzEngineListRandomItems(_pNriList_, _n_)
			if _pNriResult_ != NULL
				_aNriResult_ = @oList._ContentFromEngineList(_pNriResult_)
				StzEngineListFree(_pNriResult_)
				StzEngineListFree(_pNriList_)
				return _aNriResult_
			ok
			StzEngineListFree(_pNriList_)
		ok
		_aNriContent_ = This.Content()
		_nNriLen_ = len(_aNriContent_)
		if _n_ >= _nNriLen_
			_aNriAll_ = []
			for _iNri_ = 1 to _nNriLen_
				_aNriAll_ + _aNriContent_[_iNri_]
			next
			return _aNriAll_
		ok
		_anNriIdx_ = 1 : _nNriLen_
		for _iNri2_ = _nNriLen_ to 2 step -1
			_jNri_ = random(_iNri2_ - 1) + 1
			_nNriTmp_ = _anNriIdx_[_iNri2_]
			_anNriIdx_[_iNri2_] = _anNriIdx_[_jNri_]
			_anNriIdx_[_jNri_] = _nNriTmp_
		next
		_aNriPick_ = []
		for _kNri_ = 1 to _n_
			_aNriPick_ + _aNriContent_[_anNriIdx_[_kNri_]]
		next
		return _aNriPick_

	  #======================================================#
	 #   ITEMS BETWEEN TWO POSITIONS                        #
	#======================================================#

	def ItemsBetween(_n1_, _n2_)
		return This.Section(_n1_, _n2_)

		def ItemsBetweenQ(_n1_, _n2_)
			return new stzList(This.ItemsBetween(_n1_, _n2_))

	  #======================================================#
	 #   EVERY NTH ITEM                                     #
	#======================================================#

	# Every nth item of the list (n, 2n, 3n, ...).
	def EveryNthItem(_n_)
		_aEniContent_ = This.Content()
		_nEniLen_ = len(_aEniContent_)
		_aEniResult_ = []
		for _iEni_ = _n_ to _nEniLen_ step _n_
			_aEniResult_ + _aEniContent_[_iEni_]
		next
		return _aEniResult_

		def EveryNthItemQ(_n_)
			return new stzList(This.EveryNthItem(_n_))

		def EveryNth(_n_)
			return This.EveryNthItem(_n_)

	  #======================================================#
	 #   HEAD / TAIL                                        #
	#======================================================#

	# The first n items of the list.
	def Head(_n_)
		return This.NFirstItems(_n_)

		def HeadQ(_n_)
			return new stzList(This.Head(_n_))

	# The last n items of the list.
	def Tail(_n_)
		return This.NLastItems(_n_)

		def TailQ(_n_)
			return new stzList(This.Tail(_n_))

	  #======================================================#
	 #   ITEMS OF TYPE                                      #
	#======================================================#

	# Only the STRING items of the list.
	def OnlyStrings()
		_aOsContent_ = This.Content()
		_nOsLen_ = len(_aOsContent_)
		_aOsResult_ = []
		for _iOs_ = 1 to _nOsLen_
			if isString(_aOsContent_[_iOs_])
				_aOsResult_ + _aOsContent_[_iOs_]
			ok
		next
		return _aOsResult_

	# Only the NUMBER items of the list.
	def OnlyNumbers()
		_aOnContent_ = This.Content()
		_nOnLen_ = len(_aOnContent_)
		_aOnResult_ = []
		for _iOn_ = 1 to _nOnLen_
			if isNumber(_aOnContent_[_iOn_])
				_aOnResult_ + _aOnContent_[_iOn_]
			ok
		next
		return _aOnResult_

	# Only the LIST items of the list.
	def OnlyLists()
		_aOlContent_ = This.Content()
		_nOlLen_ = len(_aOlContent_)
		_aOlResult_ = []
		for _iOl_ = 1 to _nOlLen_
			if isList(_aOlContent_[_iOl_])
				_aOlResult_ + _aOlContent_[_iOl_]
			ok
		next
		return _aOlResult_

	# Only the CHAR items of the list.
	def OnlyChars()
		_aOcContent_ = This.Content()
		_nOcLen_ = len(_aOcContent_)
		_aOcResult_ = []
		for _iOc_ = 1 to _nOcLen_
			if isString(_aOcContent_[_iOc_]) and len(_aOcContent_[_iOc_]) = 1
				_aOcResult_ + _aOcContent_[_iOc_]
			ok
		next
		return _aOcResult_

	  #======================================================#
	 #   PAIRS / TRIPLETS / WINDOWS                         #
	#======================================================#

	def Pairs()
		_aPrContent_ = This.Content()
		_nPrLen_ = len(_aPrContent_)
		_aPrResult_ = []
		for _iPr_ = 1 to _nPrLen_ - 1
			_aPrResult_ + [_aPrContent_[_iPr_], _aPrContent_[_iPr_ + 1]]
		next
		return _aPrResult_

		def PairsQ()
			return new stzList(This.Pairs())

	def Triplets()
		_aTrContent_ = This.Content()
		_nTrLen_ = len(_aTrContent_)
		_aTrResult_ = []
		for _iTr_ = 1 to _nTrLen_ - 2
			_aTrResult_ + [_aTrContent_[_iTr_], _aTrContent_[_iTr_ + 1], _aTrContent_[_iTr_ + 2]]
		next
		return _aTrResult_

		def TripletsQ()
			return new stzList(This.Triplets())

	def SlidingWindow(_n_)
		_pSwList_ = StzEngineMarshalList(@oList.Content())
		_pSwResult_ = StzEngineListSlidingWindow(_pSwList_, _n_)
		_aSwResult_ = StzEngineListContentToRingList(_pSwResult_)
		StzEngineListFree(_pSwResult_)
		StzEngineListFree(_pSwList_)
		return _aSwResult_

		def SlidingWindowQ(_n_)
			return new stzList(This.SlidingWindow(_n_))
