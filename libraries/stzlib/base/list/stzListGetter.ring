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

class stzListGetter

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

	def NthItem(n)
		if CheckingParams()
			if isList(n) and IsOneOfTheseNamedParamsList(n, [:At, :AtPosition, :ItemAt])
				n = n[2]
			ok
		ok
		return This.List()[n]

	def FirstItem()
		return This.NthItem(1)

	def LastItem()
		return This.NthItem(This.NumberOfItems())

	def CentralItem()
		_nCiN_ = ceil(This.NumberOfItems() / 2)
		return This.NthItem(_nCiN_)

	def NFirstItems(n)
		_aNfResult_ = []
		for _iNf_ = 1 to n
			@AddItem(_aNfResult_, This.List()[_iNf_])
		next
		return _aNfResult_

		def NFirstItemsQ(n)
			return new stzList(This.NFirstItems(n))

	def NLastItems(n)
		_nNlLen_ = This.NumberOfItems()
		_aNlResult_ = []
		for _iNl_ = _nNlLen_ - n + 1 to _nNlLen_
			@AddItem(_aNlResult_, This.List()[_iNl_])
		next
		return _aNlResult_

		def NLastItemsQ(n)
			return new stzList(This.NLastItems(n))

	  #======================================================#
	 #   ITEMS AT POSITIONS                                 #
	#======================================================#

	def ItemsAtPositions(panPositions)
		_aIapResult_ = []
		_nIapLen_ = ring_len(panPositions)
		for _iIap_ = 1 to _nIapLen_
			@AddItem(_aIapResult_, This.List()[panPositions[_iIap_]])
		next
		return _aIapResult_

		def ItemsAt(panPositions)
			return This.ItemsAtPositions(panPositions)

	  #======================================================#
	 #   SECTION / RANGE                                    #
	#======================================================#

	def Section(n1, n2)
		_nScLen_ = This.NumberOfItems()
		if n1 < 1 n1 = 1 ok
		if n2 > _nScLen_ n2 = _nScLen_ ok
		if n1 > n2
			_nScTemp_ = n1
			n1 = n2
			n2 = _nScTemp_
		ok
		_pScList_ = @oList._EngineListFromContent()
		if _pScList_ != NULL
			_pScResult_ = StzEngineListSection(_pScList_, n1, n2)
			if _pScResult_ != NULL
				_aScResult_ = @oList._ContentFromEngineList(_pScResult_)
				StzEngineListFree(_pScResult_)
				StzEngineListFree(_pScList_)
				return _aScResult_
			ok
			StzEngineListFree(_pScList_)
		ok
		_aScFallback_ = []
		for _iSc_ = n1 to n2
			@AddItem(_aScFallback_, This.List()[_iSc_])
		next
		return _aScFallback_

	def Range(pnStart, pnRange)
		return This.Section(pnStart, pnStart + pnRange - 1)

	  #======================================================#
	 #   UNIQUE ITEMS                                       #
	#======================================================#

	def UniqueItemsCS(pCaseSensitive)
		_pUiList_ = @oList._EngineListFromContent()
		_pUiResult_ = StzEngineListUniqueCS(_pUiList_, pCaseSensitive)
		_aUiResult_ = StzEngineContentFromList(_pUiResult_)
		StzEngineListFree(_pUiResult_)
		StzEngineListFree(_pUiList_)
		return _aUiResult_

	def UniqueItems()
		return This.UniqueItemsCS(1)

	  #======================================================#
	 #   RANDOM ITEM                                        #
	#======================================================#

	def RandomItem()
		_nRdN_ = random(This.NumberOfItems() - 1) + 1
		return This.NthItem(_nRdN_)

	def NRandomItems(n)
		_pNriList_ = @oList._EngineListFromContent()
		if _pNriList_ != NULL
			_pNriResult_ = StzEngineListRandomItems(_pNriList_, n)
			if _pNriResult_ != NULL
				_aNriResult_ = @oList._ContentFromEngineList(_pNriResult_)
				StzEngineListFree(_pNriResult_)
				StzEngineListFree(_pNriList_)
				return _aNriResult_
			ok
			StzEngineListFree(_pNriList_)
		ok
		_aNriContent_ = This.Content()
		_nNriLen_ = ring_len(_aNriContent_)
		if n >= _nNriLen_
			_aNriAll_ = []
			for _iNri_ = 1 to _nNriLen_
				@AddItem(_aNriAll_, _aNriContent_[_iNri_])
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
		for _kNri_ = 1 to n
			@AddItem(_aNriPick_, _aNriContent_[_anNriIdx_[_kNri_]])
		next
		return _aNriPick_

	  #======================================================#
	 #   ITEMS BETWEEN TWO POSITIONS                        #
	#======================================================#

	def ItemsBetween(n1, n2)
		return This.Section(n1, n2)

		def ItemsBetweenQ(n1, n2)
			return new stzList(This.ItemsBetween(n1, n2))

	  #======================================================#
	 #   EVERY NTH ITEM                                     #
	#======================================================#

	def EveryNthItem(n)
		_aEniContent_ = This.Content()
		_nEniLen_ = ring_len(_aEniContent_)
		_aEniResult_ = []
		for _iEni_ = n to _nEniLen_ step n
			@AddItem(_aEniResult_, _aEniContent_[_iEni_])
		next
		return _aEniResult_

		def EveryNthItemQ(n)
			return new stzList(This.EveryNthItem(n))

		def EveryNth(n)
			return This.EveryNthItem(n)

	  #======================================================#
	 #   HEAD / TAIL                                        #
	#======================================================#

	def Head(n)
		return This.NFirstItems(n)

		def HeadQ(n)
			return new stzList(This.Head(n))

	def Tail(n)
		return This.NLastItems(n)

		def TailQ(n)
			return new stzList(This.Tail(n))

	  #======================================================#
	 #   ITEMS OF TYPE                                      #
	#======================================================#

	def OnlyStrings()
		_aOsContent_ = This.Content()
		_nOsLen_ = ring_len(_aOsContent_)
		_aOsResult_ = []
		for _iOs_ = 1 to _nOsLen_
			if isString(_aOsContent_[_iOs_])
				@AddItem(_aOsResult_, _aOsContent_[_iOs_])
			ok
		next
		return _aOsResult_

	def OnlyNumbers()
		_aOnContent_ = This.Content()
		_nOnLen_ = ring_len(_aOnContent_)
		_aOnResult_ = []
		for _iOn_ = 1 to _nOnLen_
			if isNumber(_aOnContent_[_iOn_])
				@AddItem(_aOnResult_, _aOnContent_[_iOn_])
			ok
		next
		return _aOnResult_

	def OnlyLists()
		_aOlContent_ = This.Content()
		_nOlLen_ = ring_len(_aOlContent_)
		_aOlResult_ = []
		for _iOl_ = 1 to _nOlLen_
			if isList(_aOlContent_[_iOl_])
				@AddItem(_aOlResult_, _aOlContent_[_iOl_])
			ok
		next
		return _aOlResult_

	def OnlyChars()
		_aOcContent_ = This.Content()
		_nOcLen_ = ring_len(_aOcContent_)
		_aOcResult_ = []
		for _iOc_ = 1 to _nOcLen_
			if isString(_aOcContent_[_iOc_]) and ring_len(_aOcContent_[_iOc_]) = 1
				@AddItem(_aOcResult_, _aOcContent_[_iOc_])
			ok
		next
		return _aOcResult_

	  #======================================================#
	 #   PAIRS / TRIPLETS / WINDOWS                         #
	#======================================================#

	def Pairs()
		_aPrContent_ = This.Content()
		_nPrLen_ = ring_len(_aPrContent_)
		_aPrResult_ = []
		for _iPr_ = 1 to _nPrLen_ - 1
			@AddItem(_aPrResult_, [_aPrContent_[_iPr_], _aPrContent_[_iPr_ + 1]])
		next
		return _aPrResult_

		def PairsQ()
			return new stzList(This.Pairs())

	def Triplets()
		_aTrContent_ = This.Content()
		_nTrLen_ = ring_len(_aTrContent_)
		_aTrResult_ = []
		for _iTr_ = 1 to _nTrLen_ - 2
			@AddItem(_aTrResult_, [_aTrContent_[_iTr_], _aTrContent_[_iTr_ + 1], _aTrContent_[_iTr_ + 2]])
		next
		return _aTrResult_

		def TripletsQ()
			return new stzList(This.Triplets())

	def SlidingWindow(n)
		_pSwList_ = StzEngineMarshalList(@oList.Content())
		_pSwResult_ = StzEngineListSlidingWindow(_pSwList_, n)
		_aSwResult_ = StzEngineContentFromList(_pSwResult_)
		StzEngineListFree(_pSwResult_)
		StzEngineListFree(_pSwList_)
		return _aSwResult_

		def SlidingWindowQ(n)
			return new stzList(This.SlidingWindow(n))
