#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTBOUNDER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List bounder subclass -- sections, slices,  #
#                  bounds checking, bounded-by operations.      #
#                  For aliases, use stzListBounderXT.           #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListBounder from stzObject

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
			StzRaise("Can't create stzListBounder! Parameter must be a list or stzList object.")
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

	  #==========================================#
	 #  GETTING A SECTION (SLICE) OF THE LIST   #
	#==========================================#

	def SectionCS(_n1_, _n2_, pCaseSensitive)

		_aScContent_ = This.Content()
		_nScLen_ = len(_aScContent_)

		if CheckingParams()

			if isList(_n1_) and IsFromNamedParamList(_n1_)
				_n1_ = _n1_[2]
			ok

			if isList(_n2_) and IsToNamedParamList(_n2_)
				_n2_ = _n2_[2]
			ok

			if isString(_n1_)
				if StzFindFirst([ :First, :FirstItem ], _n1_) > 0
					_n1_ = 1
				but StzFindFirst([ :Last, :LastItem ], _n1_) > 0
					_n1_ = _nScLen_
				ok
			ok

			if isString(_n2_)
				if StzFindFirst([ :End, :Last, :LastItem, :EndOfList ], _n2_) > 0
					_n2_ = _nScLen_
				but StzFindFirst([ :First, :FirstItem ], _n2_) > 0
					_n2_ = 1
				ok
			ok

			if NOT (isNumber(_n1_) and isNumber(_n2_))
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		if NOT ( ( _n1_ >= 1 and _n1_ <= _nScLen_ ) and
			 ( _n2_ >= 1 and _n2_ <= _nScLen_ ) )

			StzRaise("Indexes out of range! n1 and n2 must be inside the list.")
		ok

		if _n2_ < _n1_
			_nScTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nScTemp_
		ok

		# Engine fast path
		_pBsList_ = @oList._EngineListFromContent()
		if _pBsList_ != NULL
			_pBsResult_ = StzEngineListSection(_pBsList_, _n1_, _n2_)
			StzEngineListFree(_pBsList_)
			if _pBsResult_ != NULL
				_aBsResult_ = @oList._ContentFromEngineList(_pBsResult_)
				StzEngineListFree(_pBsResult_)
				return _aBsResult_
			ok
		ok

		_aScFallback_ = []
		for _iSc_ = _n1_ to _n2_
			@AddItem(_aScFallback_, _aScContent_[_iSc_])
		next

		return _aScFallback_

		def SectionCSQ(_n1_, _n2_, pCaseSensitive)
			return new stzList( This.SectionCS(_n1_, _n2_, pCaseSensitive) )

	def Section(_n1_, _n2_)
		return This.SectionCS(_n1_, _n2_, 1)

		def SectionQ(_n1_, _n2_)
			return new stzList(This.Section(_n1_, _n2_))

	  #-------------------------------------------------#
	 #  GETTING A SECTION -- XT (inverted = reversed)  #
	#-------------------------------------------------#

	def SectionXT(_n1_, _n2_)
		_aSxContent_ = This.Content()
		_nSxLen_ = len(_aSxContent_)

		# XT: a negative endpoint counts back from the end (-1 = last item).
		if _n1_ < 0
			_n1_ = _nSxLen_ + _n1_ + 1
		ok
		if _n2_ < 0
			_n2_ = _nSxLen_ + _n2_ + 1
		ok

		if _n1_ < 1 or _n1_ > _nSxLen_ or _n2_ < 1 or _n2_ > _nSxLen_
			StzRaise("Indexes out of range!")
		ok

		_aSxResult_ = []

		if _n1_ <= _n2_
			for _iSx_ = _n1_ to _n2_
				@AddItem(_aSxResult_, _aSxContent_[_iSx_])
			next
		else
			for _jSx_ = _n1_ to _n2_ step -1
				@AddItem(_aSxResult_, _aSxContent_[_jSx_])
			next
		ok

		return _aSxResult_

		def SectionXTQ(_n1_, _n2_)
			return new stzList(This.SectionXT(_n1_, _n2_))

	  #===========================================#
	 #  GETTING MANY SECTIONS                   #
	#===========================================#

	def Sections(paSections)
		_nSsLen_ = len(paSections)
		_aSsResult_ = []

		for _iSs_ = 1 to _nSsLen_
			_aSsSection_ = paSections[_iSs_]
			_aSsItems_ = This.Section(_aSsSection_[1], _aSsSection_[2])
			@AddItem(_aSsResult_, _aSsItems_)
		next

		return _aSsResult_

		def SectionsQ(paSections)
			return new stzList(This.Sections(paSections))

		def ManySections(paSections)
			return This.Sections(paSections)

	  #===========================================================#
	 #  CHECKING IF THE 2 ITEMS ARE BOUNDS OF A SUBSTRING        #
	#===========================================================#

	def AreBoundsOfCS(pcSubStr, pIn, pCaseSensitive)

		if CheckingParams() = 1

			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok

			if NOT ( This.IsPair() or This.IsListOfPairs() )
				StzRaise("Can't check bounds! List must be a pair or a list of pairs.")
			ok

			if isList(pIn) and IsInNamedParamList(pIn)
				pIn = pIn[2]
			ok

			if NOT isString(pIn)
				StzRaise("Incorrect param type! pIn must be a string.")
			ok

		ok

		_aAbContent_ = This.Content()
		_nAbLen_ = len(_aAbContent_)

		_oAbSubStr_ = new stzString(pcSubStr)
		_bAbResult_ = 0

		if This.IsListOfPairs()
			_bAbResult_ = 1

			for _iAb_ = 1 to _nAbLen_
				_bAbResult_ = _oAbSubStr_.IsBoundedByIn(_aAbContent_[_iAb_], pIn)
				if _bAbResult_ = 0
					exit
				ok
			next
		else
			_bAbResult_ = _oAbSubStr_.IsBoundedByIn(_aAbContent_, pIn)
		ok

		return _bAbResult_

	def AreBoundsOf(pItem, pIn)
		return This.AreBoundsOfCS(pItem, pIn, 1)

	  #----------------------------------------------------------#
	 #  CHECKING IF THE LIST IS BOUNDED BY THE GIVEN TWO ITEMS  #
	#----------------------------------------------------------#

	def IsBoundedByCS(paBounds, pCaseSensitive)
		# len()=2 inlined instead of IsPair(): the class inherits a 0-arg
		# IsPair method that would shadow the global func here (-> R20).
		if isList(paBounds) and len(paBounds) = 2
			_pIbItem1_ = paBounds[1]
			_pIbItem2_ = paBounds[2]
		else
			_pIbItem1_ = paBounds
			_pIbItem2_ = paBounds
		ok

		if @oList.FirstItemQ().IsEqualToCS(_pIbItem1_, pCaseSensitive) and
		   @oList.LastItemQ().IsEqualToCS(_pIbItem2_, pCaseSensitive)

			return 1
		else
			return 0
		ok

	def IsBoundedBy(paBounds)
		return This.IsBoundedByCS(paBounds, 1)

	  #--------------------------------------------#
	 #  GETTING BOUNDS OF THE LIST UP TO N ITEMS  #
	#--------------------------------------------#

	def BoundsUpToNItems(_n_)
		_aBuFirst_ = This.NFirstItems(_n_)
		_aBuLast_  = This.NLastItems(_n_)

		if len(_aBuFirst_) = 1
			_aBuFirst_ = _aBuFirst_[1]
		ok

		if len(_aBuLast_) = 1
			_aBuLast_ = _aBuLast_[1]
		ok

		return [ _aBuFirst_, _aBuLast_ ]

	def Bounds()
		return This.BoundsUpToNItems(1)

	  #=====================================#
	 #     REMOVING BOUNDS               #
	#=====================================#

	def RemoveBoundsCS(paBounds, pCaseSensitive)
		if This.IsBoundedByCS(paBounds, pCaseSensitive)
			@oList.RemoveFirstItem()
			@oList.RemoveLastItem()
		ok

		def RemoveBoundsCSQ(paBounds, pCaseSensitive)
			This.RemoveBoundsCS(paBounds, pCaseSensitive)
			return This

	def RemoveBounds(paBounds)
		This.RemoveBoundsCS(paBounds, 1)

		def RemoveBoundsQ(paBounds)
			This.RemoveBounds(paBounds)
			return This

	def BoundsRemoved(paBounds)
		_oBrCopy_ = new stzListBounder(@oList.Content())
		_aBrResult_ = _oBrCopy_.RemoveBoundsQ(paBounds).Content()
		return _aBrResult_

	  #==============================#
	 #  IS PAIR / IS LIST OF PAIRS  #
	#==============================#

	def IsPair()
		return This.NumberOfItems() = 2

	def IsListOfPairs()
		_aIlpContent_ = This.Content()
		_nIlpLen_ = len(_aIlpContent_)

		for _iIlp_ = 1 to _nIlpLen_
			if NOT (isList(_aIlpContent_[_iIlp_]) and len(_aIlpContent_[_iIlp_]) = 2)
				return 0
			ok
		next

		return 1

	  #=======================================#
	 #     GETTING THE MIDDLE OF THE LIST    #
	#=======================================#

	def Middle()
		_aMdContent_ = This.Content()
		_nMdLen_ = len(_aMdContent_)

		if _nMdLen_ < 3
			return []
		ok

		_aMdResult_ = []
		for _iMd_ = 2 to _nMdLen_ - 1
			@AddItem(_aMdResult_, _aMdContent_[_iMd_])
		next

		return _aMdResult_

		def WithoutBounds()
			return This.Middle()

	  #=======================================#
	 #     RANGE (START, COUNT)              #
	#=======================================#

	def Range(nStart, nCount)
		_aRgContent_ = This.Content()
		_nRgLen_ = len(_aRgContent_)
		_aRgResult_ = []

		_nRgEnd_ = nStart + nCount - 1
		if _nRgEnd_ > _nRgLen_
			_nRgEnd_ = _nRgLen_
		ok

		for _iRg_ = nStart to _nRgEnd_
			@AddItem(_aRgResult_, _aRgContent_[_iRg_])
		next

		return _aRgResult_

		def RangeQ(nStart, nCount)
			return new stzList(This.Range(nStart, nCount))

	  #==========================================#
	 #     CLAMPED TO MIN/MAX VALUES            #
	#==========================================#

	def ClampedTo(nMin, nMax)
		_aClContent_ = This.Content()
		_nClLen_ = len(_aClContent_)
		_aClResult_ = []

		for _iCl_ = 1 to _nClLen_
			if isNumber(_aClContent_[_iCl_])
				_nClN_ = _aClContent_[_iCl_]
				if _nClN_ < nMin
					_nClN_ = nMin
				ok
				if _nClN_ > nMax
					_nClN_ = nMax
				ok
				@AddItem(_aClResult_, _nClN_)
			else
				@AddItem(_aClResult_, _aClContent_[_iCl_])
			ok
		next

		return _aClResult_

	def ClampTo(nMin, nMax)
		@oList.Update(This.ClampedTo(nMin, nMax))

		def ClampToQ(nMin, nMax)
			This.ClampTo(nMin, nMax)
			return This

	  #==========================================#
	 #     CHECK IF POSITION IS WITHIN BOUNDS   #
	#==========================================#

	def IsWithinBounds(_n_)
		if _n_ >= 1 and _n_ <= This.NumberOfItems()
			return 1
		else
			return 0
		ok

		def PositionExists(_n_)
			return This.IsWithinBounds(_n_)

		def HasPosition(_n_)
			return This.IsWithinBounds(_n_)

	  #=======================================#
	 #     FIRST N AND LAST N ITEMS          #
	#=======================================#

	def NFirstItems(_n_)
		_aNfContent_ = This.Content()
		_nNfLen_ = len(_aNfContent_)
		_aNfResult_ = []

		if _n_ > _nNfLen_
			_n_ = _nNfLen_
		ok

		for _iNf_ = 1 to _n_
			@AddItem(_aNfResult_, _aNfContent_[_iNf_])
		next

		return _aNfResult_

		def FirstNItems(_n_)
			return This.NFirstItems(_n_)

		def Take(_n_)
			return This.NFirstItems(_n_)

	def NLastItems(_n_)
		_aNlContent_ = This.Content()
		_nNlLen_ = len(_aNlContent_)
		_aNlResult_ = []

		if _n_ > _nNlLen_
			_n_ = _nNlLen_
		ok

		_nNlStart_ = _nNlLen_ - _n_ + 1
		for _iNl_ = _nNlStart_ to _nNlLen_
			@AddItem(_aNlResult_, _aNlContent_[_iNl_])
		next

		return _aNlResult_

		def LastNItems(_n_)
			return This.NLastItems(_n_)

		def TakeLast(_n_)
			return This.NLastItems(_n_)

	  #=======================================#
	 #     ITEMS BETWEEN TWO POSITIONS       #
	#=======================================#

	def ItemsBetweenPositions(_n1_, _n2_)
		return This.Section(_n1_, _n2_)

		def Between(_n1_, _n2_)
			return This.ItemsBetweenPositions(_n1_, _n2_)
