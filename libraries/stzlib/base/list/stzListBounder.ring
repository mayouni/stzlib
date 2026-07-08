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

	def SectionCS(n1, n2, pCaseSensitive)

		_aScContent_ = This.Content()
		_nScLen_ = len(_aScContent_)

		if CheckingParams()

			if isList(n1) and IsFromNamedParamList(n1)
				n1 = n1[2]
			ok

			if isList(n2) and IsToNamedParamList(n2)
				n2 = n2[2]
			ok

			if isString(n1)
				if StzFindFirst([ :First, :FirstItem ], n1) > 0
					n1 = 1
				but StzFindFirst([ :Last, :LastItem ], n1) > 0
					n1 = _nScLen_
				ok
			ok

			if isString(n2)
				if StzFindFirst([ :End, :Last, :LastItem, :EndOfList ], n2) > 0
					n2 = _nScLen_
				but StzFindFirst([ :First, :FirstItem ], n2) > 0
					n2 = 1
				ok
			ok

			if NOT (isNumber(n1) and isNumber(n2))
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		if NOT ( ( n1 >= 1 and n1 <= _nScLen_ ) and
			 ( n2 >= 1 and n2 <= _nScLen_ ) )

			StzRaise("Indexes out of range! n1 and n2 must be inside the list.")
		ok

		if n2 < n1
			_nScTemp_ = n1
			n1 = n2
			n2 = _nScTemp_
		ok

		# Engine fast path
		_pBsList_ = @oList._EngineListFromContent()
		if _pBsList_ != NULL
			_pBsResult_ = StzEngineListSection(_pBsList_, n1, n2)
			StzEngineListFree(_pBsList_)
			if _pBsResult_ != NULL
				_aBsResult_ = @oList._ContentFromEngineList(_pBsResult_)
				StzEngineListFree(_pBsResult_)
				return _aBsResult_
			ok
		ok

		_aScFallback_ = []
		for _iSc_ = n1 to n2
			@AddItem(_aScFallback_, _aScContent_[_iSc_])
		next

		return _aScFallback_

		def SectionCSQ(n1, n2, pCaseSensitive)
			return new stzList( This.SectionCS(n1, n2, pCaseSensitive) )

	def Section(n1, n2)
		return This.SectionCS(n1, n2, 1)

		def SectionQ(n1, n2)
			return new stzList(This.Section(n1, n2))

	  #-------------------------------------------------#
	 #  GETTING A SECTION -- XT (inverted = reversed)  #
	#-------------------------------------------------#

	def SectionXT(n1, n2)
		_aSxContent_ = This.Content()
		_nSxLen_ = len(_aSxContent_)

		# XT: a negative endpoint counts back from the end (-1 = last item).
		if n1 < 0
			n1 = _nSxLen_ + n1 + 1
		ok
		if n2 < 0
			n2 = _nSxLen_ + n2 + 1
		ok

		if n1 < 1 or n1 > _nSxLen_ or n2 < 1 or n2 > _nSxLen_
			StzRaise("Indexes out of range!")
		ok

		_aSxResult_ = []

		if n1 <= n2
			for _iSx_ = n1 to n2
				@AddItem(_aSxResult_, _aSxContent_[_iSx_])
			next
		else
			for _jSx_ = n1 to n2 step -1
				@AddItem(_aSxResult_, _aSxContent_[_jSx_])
			next
		ok

		return _aSxResult_

		def SectionXTQ(n1, n2)
			return new stzList(This.SectionXT(n1, n2))

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

	def BoundsUpToNItems(n)
		_aBuFirst_ = This.NFirstItems(n)
		_aBuLast_  = This.NLastItems(n)

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

	def IsWithinBounds(n)
		if n >= 1 and n <= This.NumberOfItems()
			return 1
		else
			return 0
		ok

		def PositionExists(n)
			return This.IsWithinBounds(n)

		def HasPosition(n)
			return This.IsWithinBounds(n)

	  #=======================================#
	 #     FIRST N AND LAST N ITEMS          #
	#=======================================#

	def NFirstItems(n)
		_aNfContent_ = This.Content()
		_nNfLen_ = len(_aNfContent_)
		_aNfResult_ = []

		if n > _nNfLen_
			n = _nNfLen_
		ok

		for _iNf_ = 1 to n
			@AddItem(_aNfResult_, _aNfContent_[_iNf_])
		next

		return _aNfResult_

		def FirstNItems(n)
			return This.NFirstItems(n)

		def Take(n)
			return This.NFirstItems(n)

	def NLastItems(n)
		_aNlContent_ = This.Content()
		_nNlLen_ = len(_aNlContent_)
		_aNlResult_ = []

		if n > _nNlLen_
			n = _nNlLen_
		ok

		_nNlStart_ = _nNlLen_ - n + 1
		for _iNl_ = _nNlStart_ to _nNlLen_
			@AddItem(_aNlResult_, _aNlContent_[_iNl_])
		next

		return _aNlResult_

		def LastNItems(n)
			return This.NLastItems(n)

		def TakeLast(n)
			return This.NLastItems(n)

	  #=======================================#
	 #     ITEMS BETWEEN TWO POSITIONS       #
	#=======================================#

	def ItemsBetweenPositions(n1, n2)
		return This.Section(n1, n2)

		def Between(n1, n2)
			return This.ItemsBetweenPositions(n1, n2)
