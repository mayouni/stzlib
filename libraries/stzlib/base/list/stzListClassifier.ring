#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCLASSIFIER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List classifier subclass -- classification #
#                  and categorization of list items.           #
#                  For aliases, use stzListClassifierXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListClassifier

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
			StzRaise("Can't create stzListClassifier! Parameter must be a list or stzList object.")
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

	def Copy()
		return new stzListClassifier( @oList.Content() )

	def Classify()
		_pClList_ = @oList._EngineListFromContent()
		_pClResult_ = StzEngineListClassifyCS(_pClList_, 0)
		StzEngineListFree(_pClList_)

		_aClRaw_ = StzEngineContentFromList(_pClResult_)
		StzEngineListFree(_pClResult_)

		_nClLen_ = len(_aClRaw_)
		_aClResult_ = []
		_iCl_ = 1
		for _kCl_ = 1 to _nClLen_ / 2
			_cClKey_ = _aClRaw_[_iCl_]
			_cClPositions_ = _aClRaw_[_iCl_ + 1]
			_aClParts_ = StzSplit(_cClPositions_, ",")
			_anClPos_ = []
			_nClParts_ = len(_aClParts_)
			for _jCl_ = 1 to _nClParts_
				@AddItem(_anClPos_, 0 + _aClParts_[_jCl_])
			next
			@AddItem(_aClResult_, [_cClKey_, _anClPos_])
			_iCl_ += 2
		next
		return _aClResult_

		def ClassifyQ()
			return new stzList(This.Classify())

	def Classified()
		return This.Classify()

	def Classes()
		_aClsClassified_ = This.Classify()
		_nClsLen_ = len(_aClsClassified_)
		_aClsResult_ = []
		for _iCls_ = 1 to _nClsLen_
			@AddItem(_aClsResult_, _aClsClassified_[_iCls_][1])
		next
		return _aClsResult_

	def ClassifyBy(pcExpr)
		_pCbList_ = @oList._EngineListFromContent()
		_cCbMapExpr_ = "string(" + pcExpr + ")"
		_pCbMapped_ = StzEngineListMapExpr(_pCbList_, _cCbMapExpr_)
		StzEngineListFree(_pCbList_)

		_pCbResult_ = StzEngineListClassifyCS(_pCbMapped_, 1)
		StzEngineListFree(_pCbMapped_)

		_aCbRaw_ = StzEngineContentFromList(_pCbResult_)
		StzEngineListFree(_pCbResult_)

		_nCbLen_ = len(_aCbRaw_)
		_aCbResult_ = []
		_iCb_ = 1
		for _kCb_ = 1 to _nCbLen_ / 2
			_cCbKey_ = _aCbRaw_[_iCb_]
			_cCbPositions_ = _aCbRaw_[_iCb_ + 1]
			_aCbParts_ = StzSplit(_cCbPositions_, ",")
			_anCbPos_ = []
			_nCbParts_ = len(_aCbParts_)
			for _jCb_ = 1 to _nCbParts_
				@AddItem(_anCbPos_, 0 + _aCbParts_[_jCb_])
			next
			@AddItem(_aCbResult_, [_cCbKey_, _anCbPos_])
			_iCb_ += 2
		next
		return _aCbResult_

	def PartsCS(pCaseSensitive)
		return This.Classify()

	def Parts()
		return This.PartsCS(1)

	  #======================================================#
	 #   NUMBER OF CLASSES                                  #
	#======================================================#

	def NumberOfClasses()
		return len(This.Classes())

	  #======================================================#
	 #   FREQUENCY OF EACH ITEM                             #
	#======================================================#

	def Frequencies()
		_pFrList_ = @oList._EngineListFromContent()
		_pFrFreqs_ = StzEngineListFrequenciesCS(_pFrList_, 0)
		StzEngineListFree(_pFrList_)

		_aFrRaw_ = StzEngineContentFromList(_pFrFreqs_)
		StzEngineListFree(_pFrFreqs_)

		_nFrLen_ = len(_aFrRaw_)
		_aFrResult_ = []
		_iFr_ = 1
		for _kFr_ = 1 to _nFrLen_ / 2
			@AddItem(_aFrResult_, [_aFrRaw_[_iFr_], _aFrRaw_[_iFr_ + 1]])
			_iFr_ += 2
		next
		return _aFrResult_

	  #======================================================#
	 #   MOST / LEAST FREQUENT                              #
	#======================================================#

	def MostFrequent()
		_aMfFreqs_ = This.Frequencies()
		_nMfLen_ = len(_aMfFreqs_)
		if _nMfLen_ = 0
			return NULL
		ok
		_nMfMax_ = 0
		_cMfResult_ = ""
		for _iMf_ = 1 to _nMfLen_
			if _aMfFreqs_[_iMf_][2] > _nMfMax_
				_nMfMax_ = _aMfFreqs_[_iMf_][2]
				_cMfResult_ = _aMfFreqs_[_iMf_][1]
			ok
		next
		return _cMfResult_

	def LeastFrequent()
		_aLfFreqs_ = This.Frequencies()
		_nLfLen_ = len(_aLfFreqs_)
		if _nLfLen_ = 0
			return NULL
		ok
		_nLfMin_ = _aLfFreqs_[1][2]
		_cLfResult_ = _aLfFreqs_[1][1]
		for _iLf_ = 2 to _nLfLen_
			if _aLfFreqs_[_iLf_][2] < _nLfMin_
				_nLfMin_ = _aLfFreqs_[_iLf_][2]
				_cLfResult_ = _aLfFreqs_[_iLf_][1]
			ok
		next
		return _cLfResult_

	  #======================================================#
	 #   GROUP BY EXPRESSION                                #
	#======================================================#

	def GroupBy(pcExpr)
		return This.ClassifyBy(pcExpr)

		def GroupByQ(pcExpr)
			return new stzList(This.GroupBy(pcExpr))

	  #======================================================#
	 #   PARTITION INTO N GROUPS                            #
	#======================================================#

	def Partition(n)
		_aPartContent_ = This.Content()
		_nPartLen_ = len(_aPartContent_)
		_aPartResult_ = []
		_nPartGroupSize_ = ceil(_nPartLen_ / n)
		_nPartStart_ = 1
		for _iPart_ = 1 to n
			_aPartGroup_ = []
			_nPartEnd_ = _nPartStart_ + _nPartGroupSize_ - 1
			if _nPartEnd_ > _nPartLen_
				_nPartEnd_ = _nPartLen_
			ok
			for _jPart_ = _nPartStart_ to _nPartEnd_
				@AddItem(_aPartGroup_, _aPartContent_[_jPart_])
			next
			if len(_aPartGroup_) > 0
				@AddItem(_aPartResult_, _aPartGroup_)
			ok
			_nPartStart_ = _nPartEnd_ + 1
		next
		return _aPartResult_

		def PartitionQ(n)
			return new stzList(This.Partition(n))

	  #======================================================#
	 #   HISTOGRAM -- FREQUENCY AS PAIRS [VALUE, COUNT]     #
	#======================================================#

	def Histogram()
		return This.Frequencies()

		def HistogramQ()
			return new stzList(This.Histogram())

	  #======================================================#
	 #   ITEMS APPEARING EXACTLY N TIMES                    #
	#======================================================#

	def ItemsAppearingNTimes(n)
		_aIntFreqs_ = This.Frequencies()
		_nIntLen_ = len(_aIntFreqs_)
		_aIntResult_ = []
		for _iInt_ = 1 to _nIntLen_
			if _aIntFreqs_[_iInt_][2] = n
				@AddItem(_aIntResult_, _aIntFreqs_[_iInt_][1])
			ok
		next
		return _aIntResult_

		def ItemsWithFrequency(n)
			return This.ItemsAppearingNTimes(n)

	  #======================================================#
	 #   ITEMS APPEARING MORE/LESS THAN N TIMES             #
	#======================================================#

	def ItemsAppearingMoreThanNTimes(n)
		_aImtFreqs_ = This.Frequencies()
		_nImtLen_ = len(_aImtFreqs_)
		_aImtResult_ = []
		for _iImt_ = 1 to _nImtLen_
			if _aImtFreqs_[_iImt_][2] > n
				@AddItem(_aImtResult_, _aImtFreqs_[_iImt_][1])
			ok
		next
		return _aImtResult_

	def ItemsAppearingLessThanNTimes(n)
		_aIltFreqs_ = This.Frequencies()
		_nIltLen_ = len(_aIltFreqs_)
		_aIltResult_ = []
		for _iIlt_ = 1 to _nIltLen_
			if _aIltFreqs_[_iIlt_][2] < n
				@AddItem(_aIltResult_, _aIltFreqs_[_iIlt_][1])
			ok
		next
		return _aIltResult_

	  #======================================================#
	 #   FREQUENCY OF A SPECIFIC ITEM                       #
	#======================================================#

	def FrequencyOf(pItem)
		return @oList.CountCS(pItem, 1)

		def HowMany(pItem)
			return This.FrequencyOf(pItem)

	  #======================================================#
	 #   MODE -- MOST COMMON ITEMS (ALL TIES)               #
	#======================================================#

	def Mode()
		_aMdFreqs_ = This.Frequencies()
		_nMdLen_ = len(_aMdFreqs_)
		if _nMdLen_ = 0
			return []
		ok
		_nMdMax_ = 0
		for _iMd_ = 1 to _nMdLen_
			if _aMdFreqs_[_iMd_][2] > _nMdMax_
				_nMdMax_ = _aMdFreqs_[_iMd_][2]
			ok
		next
		_aMdResult_ = []
		for _jMd_ = 1 to _nMdLen_
			if _aMdFreqs_[_jMd_][2] = _nMdMax_
				@AddItem(_aMdResult_, _aMdFreqs_[_jMd_][1])
			ok
		next
		return _aMdResult_

	  #======================================================#
	 #   BISECTION -- SPLIT INTO HALVES                     #
	#======================================================#

	def Bisect()
		_aBsContent_ = This.Content()
		_nBsLen_ = len(_aBsContent_)
		_nBsMid_ = ceil(_nBsLen_ / 2)

		_aBsFirst_ = []
		for _iBs_ = 1 to _nBsMid_
			@AddItem(_aBsFirst_, _aBsContent_[_iBs_])
		next

		_aBsSecond_ = []
		for _jBs_ = _nBsMid_ + 1 to _nBsLen_
			@AddItem(_aBsSecond_, _aBsContent_[_jBs_])
		next

		return [_aBsFirst_, _aBsSecond_]

		def BisectQ()
			return new stzList(This.Bisect())

	def FirstHalf()
		return This.Bisect()[1]

		def FirstHalfQ()
			return new stzList(This.FirstHalf())

	def SecondHalf()
		return This.Bisect()[2]

		def SecondHalfQ()
			return new stzList(This.SecondHalf())

	  #======================================================#
	 #   PARTITION BY CONDITION                             #
	#======================================================#

	def PartitionW(pcCondition)
		_aPwContent_ = This.Content()
		_nPwLen_ = len(_aPwContent_)
		_aPwTrue_ = []
		_aPwFalse_ = []

		_cPwCode_ = StzCCodeToRingCode(pcCondition)

		for @i = 1 to _nPwLen_
			@item = _aPwContent_[@i]
			_cPwEval_ = StzStringReplace(_cPwCode_, "@item", @@(@item))
			_bPwResult_ = eval(_cPwEval_)
			if _bPwResult_
				@AddItem(_aPwTrue_, @item)
			else
				@AddItem(_aPwFalse_, @item)
			ok
		next

		return [_aPwTrue_, _aPwFalse_]

		def PartitionWQ(pcCondition)
			return new stzList(This.PartitionW(pcCondition))

		def PartitionWhere(pcCondition)
			return This.PartitionW(pcCondition)

		def SplitW(pcCondition)
			return This.PartitionW(pcCondition)

	  #======================================================#
	 #   CHUNK -- SPLIT INTO GROUPS OF SIZE N               #
	#======================================================#

	def Chunks(n)
		_pChList_ = @oList._EngineListFromContent()
		_pChResult_ = StzEngineListChunked(_pChList_, n)
		_aChResult_ = StzEngineContentFromList(_pChResult_)
		StzEngineListFree(_pChResult_)
		StzEngineListFree(_pChList_)
		return _aChResult_

		def ChunksQ(n)
			return new stzList(This.Chunks(n))

		def SplitToPartsOfNItems(n)
			return This.Chunks(n)
