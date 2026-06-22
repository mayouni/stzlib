#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTWALKER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List walker subclass -- walking/traversing  #
#                  items with various strategies.               #
#                  For aliases, use stzListWalkerXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListWalker

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
			StzRaise("Can't create stzListWalker! Parameter must be a list or stzList object.")
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

	  #==========================#
	 #  WALKING THE LIST ITEMS  #
	#==========================#

	def AddWalker(pcName, pnStart, pnEnd, pnStep)

		if CheckingParams()
			if isList(pcName) and IsNameOrNamedNamedParamList(pcName)
				pcName = pcName[2]
			ok

			if NOT isString(pcName)
				StzRaise("Incorrect param type! pcName must be a string.")
			ok
		ok

		_aWalkers_ = This.Walkers()
		_nLenWalkers_ = len(_aWalkers_)

		_bNewName_ = 1

		for i = 1 to _nLenWalkers_
			if _aWalkers_[i][1] = pcName
				_bNewName_ = 0
				exit
			ok
		next

		if NOT _bNewName_
			StzRaise(stzListError(:CanNotAddWalkerAlreadyExistant))
		else
			_oWalker_ = new stzWalker(pnStart, pnEnd, pnStep)
			@aWalkers + [ pcName, _oWalker_ ]
		ok

	def Walkers()
		return @aWalkers

	def Walker(pcWalkerNamed)
		return This.Walkers()[pcWalkerNamed]

		def WalkerQ(pcWalkerNamed)
			return This.Walker(pcWalkerNamed)

	  #==========================================#
	 #  WALKING THE LIST N ITEMS FORWARD        #
	#==========================================#

	def WalkNForward(n)
		_nWnfLen_ = This.NumberOfItems()
		_anWnfResult_ = []

		_iWnf_ = 1
		while _iWnf_ <= _nWnfLen_
			@AddItem(_anWnfResult_, _iWnf_)
			_iWnf_ += n
		end

		return _anWnfResult_

		def WalkForwardNSteps(n)
			return This.WalkNForward(n)

	  #==========================================#
	 #  WALKING THE LIST N ITEMS BACKWARD       #
	#==========================================#

	def WalkNBackward(n)
		_nWnbLen_ = This.NumberOfItems()
		_anWnbResult_ = []

		_iWnb_ = _nWnbLen_
		while _iWnb_ >= 1
			@AddItem(_anWnbResult_, _iWnb_)
			_iWnb_ -= n
		end

		return _anWnbResult_

		def WalkBackwardNSteps(n)
			return This.WalkNBackward(n)

	  #=========================#
	 #  WALKING BETWEEN        #
	#=========================#

	def WalkBetween(n1, n2, nStep)
		_anWbResult_ = []

		if n1 <= n2
			for _iWb_ = n1 to n2 step nStep
				@AddItem(_anWbResult_, _iWb_)
			next
		else
			for _jWb_ = n1 to n2 step -nStep
				@AddItem(_anWbResult_, _jWb_)
			next
		ok

		return _anWbResult_

	  #===================================#
	 #  WALKING FORTH AND BACK          #
	#===================================#

	def WalkForthAndBack(n)
		_anWfbFwd_ = This.WalkNForward(n)
		_anWfbBwd_ = This.WalkNBackward(n)

		_aWfbResult_ = _anWfbFwd_
		_nWfbLen_ = len(_anWfbBwd_)
		for _iWfb_ = 1 to _nWfbLen_
			@AddItem(_aWfbResult_, _anWfbBwd_[_iWfb_])
		next

		return _aWfbResult_

	  #=========================#
	 #  WALKING WHERE          #
	#=========================#

	def WalkW(pcCondition)
		return @oList.FindAllItemsW(pcCondition)

	  #==========================#
	 #  WALKING UNTIL           #
	#==========================#

	def WalkUntil(pcCondition)
		# Walk forward up to AND INCLUDING the first position where the
		# condition holds. WalkUntil(:Before = cond) stops just before it.
		_bWuBefore_ = 0
		if isList(pcCondition) and len(pcCondition) = 2 and isString(pcCondition[1]) and
		   (pcCondition[1] = :Before or pcCondition[1] = :before)
			_bWuBefore_ = 1
			pcCondition = pcCondition[2]
		ok

		_anWuMatch_ = @oList.FindAllItemsW(pcCondition)
		_nWuLen_ = This.NumberOfItems()

		_anWuResult_ = []
		if len(_anWuMatch_) = 0
			for _iWu_ = 1 to _nWuLen_
				@AddItem(_anWuResult_, _iWu_)
			next
			return _anWuResult_
		ok

		_nWuLast_ = _anWuMatch_[1]
		if _bWuBefore_
			_nWuLast_ = _nWuLast_ - 1
		ok
		for _jWu_ = 1 to _nWuLast_
			@AddItem(_anWuResult_, _jWu_)
		next
		return _anWuResult_

	#-- Directional / return-type walking helpers (engine-backed via
	#-- FindAllItemsW). pcDirection: :Forward (default) / :Backward.
	#-- pReturn: :WalkedPositions (default) / :WalkedItems.

	def _WalkDir_(pcDirection)
		if isList(pcDirection) and len(pcDirection) = 2 and isString(pcDirection[1])
			pcDirection = pcDirection[2]
		ok
		if pcDirection = :Backward or pcDirection = :Backwards or pcDirection = :Back or pcDirection = :Reverse
			return :Backward
		ok
		return :Forward

	def _WalkRet_(pReturn)
		if isList(pReturn) and len(pReturn) = 2 and isString(pReturn[1])
			pReturn = pReturn[2]
		ok
		if pReturn = :WalkedItems or pReturn = :WalkedItem or pReturn = :Items or
		   pReturn = :LastWalkedItem or pReturn = :LastItem
			return :WalkedItems
		ok
		return :WalkedPositions

	def _WalkOut_(panPos, pReturn)
		if This._WalkRet_(pReturn) = :WalkedItems
			_aWoC_ = @oList.Content()
			_aWoR_ = []
			_nWoL_ = len(panPos)
			for _iWo_ = 1 to _nWoL_
				@AddItem(_aWoR_, _aWoC_[ panPos[_iWo_] ])
			next
			return _aWoR_
		ok
		return panPos

	def _WalkInSet_(n, panSet)
		_nWiL_ = len(panSet)
		for _iWi_ = 1 to _nWiL_
			if panSet[_iWi_] = n
				return 1
			ok
		next
		return 0

	  #==========================#
	 #  WALKING WHERE           #
	#==========================#

	def WalkWhere(pcCondition)
		return @oList.FindAllItemsW(pcCondition)


	  #==========================#
	 #  WALKING WHEN            #
	#==========================#

	def WalkWhen(pcCondition)
		_anWnMatch_ = @oList.FindAllItemsW(pcCondition)
		if len(_anWnMatch_) = 0
			return []
		ok
		_nWnFirst_ = _anWnMatch_[1]
		_nWnLen_ = This.NumberOfItems()
		_anWnRes_ = []
		for _iWn_ = _nWnFirst_ to _nWnLen_
			@AddItem(_anWnRes_, _iWn_)
		next
		return _anWnRes_

	def WalkWhenXT(pcCondition, pcDirection, pReturn)
		_anWnMatch_ = @oList.FindAllItemsW(pcCondition)
		if len(_anWnMatch_) = 0
			return []
		ok
		_nWnFirst_ = _anWnMatch_[1]
		_nWnLen_ = This.NumberOfItems()
		_anWnPos_ = []
		if This._WalkDir_(pcDirection) = :Backward
			for _iWn_ = _nWnFirst_ to 1 step -1
				@AddItem(_anWnPos_, _iWn_)
			next
		else
			for _iWn_ = _nWnFirst_ to _nWnLen_
				@AddItem(_anWnPos_, _iWn_)
			next
		ok
		return This._WalkOut_(_anWnPos_, pReturn)

	def WalkUntilXT(pcCondition, pcDirection, pReturn)
		_bWuxBefore_ = 0
		if isList(pcCondition) and len(pcCondition) = 2 and isString(pcCondition[1]) and
		   (pcCondition[1] = :Before or pcCondition[1] = :before)
			_bWuxBefore_ = 1
			pcCondition = pcCondition[2]
		ok
		_anWuxMatch_ = @oList.FindAllItemsW(pcCondition)
		_nWuxLen_ = This.NumberOfItems()
		_anWuxPos_ = []
		if This._WalkDir_(pcDirection) = :Backward
			_nWuxFirst_ = 0
			for _iWux_ = _nWuxLen_ to 1 step -1
				if This._WalkInSet_(_iWux_, _anWuxMatch_)
					_nWuxFirst_ = _iWux_
					exit
				ok
			next
			if _nWuxFirst_ = 0
				for _iWux_ = _nWuxLen_ to 1 step -1
					@AddItem(_anWuxPos_, _iWux_)
				next
			else
				_nWuxStart_ = _nWuxFirst_
				if _bWuxBefore_
					_nWuxStart_ = _nWuxFirst_ + 1
				ok
				for _iWux_ = _nWuxLen_ to _nWuxStart_ step -1
					@AddItem(_anWuxPos_, _iWux_)
				next
			ok
		else
			_nWuxFirst_ = 0
			for _iWux_ = 1 to _nWuxLen_
				if This._WalkInSet_(_iWux_, _anWuxMatch_)
					_nWuxFirst_ = _iWux_
					exit
				ok
			next
			if _nWuxFirst_ = 0
				for _iWux_ = 1 to _nWuxLen_
					@AddItem(_anWuxPos_, _iWux_)
				next
			else
				_nWuxLast_ = _nWuxFirst_
				if _bWuxBefore_
					_nWuxLast_ = _nWuxFirst_ - 1
				ok
				for _iWux_ = 1 to _nWuxLast_
					@AddItem(_anWuxPos_, _iWux_)
				next
			ok
		ok
		return This._WalkOut_(_anWuxPos_, pReturn)

	def WalkWhileXT(pcCondition, pcDirection, pReturn)
		_anWwxMatch_ = @oList.FindAllItemsW(pcCondition)
		_nWwxLen_ = This.NumberOfItems()
		_anWwxPos_ = []
		if This._WalkDir_(pcDirection) = :Backward
			_iWwx_ = _nWwxLen_
			while _iWwx_ >= 1 and This._WalkInSet_(_iWwx_, _anWwxMatch_)
				@AddItem(_anWwxPos_, _iWwx_)
				_iWwx_ = _iWwx_ - 1
			end
		else
			_iWwx_ = 1
			while _iWwx_ <= _nWwxLen_ and This._WalkInSet_(_iWwx_, _anWwxMatch_)
				@AddItem(_anWwxPos_, _iWwx_)
				_iWwx_ = _iWwx_ + 1
			end
		ok
		return This._WalkOut_(_anWwxPos_, pReturn)

	  #==========================#
	 #  WALKING WHILE           #
	#==========================#

	def WalkWhile(pcCondition)
		_pWwList_ = @oList._EngineListFromContent()
		if _pWwList_ = NULL return [] ok

		_cWwNegated_ = "not (" + _StzStripBraces(pcCondition) + ")"
		_nWwFirst_ = StzEngineListFindW(_pWwList_, _cWwNegated_)
		StzEngineListFree(_pWwList_)

		if _nWwFirst_ = 0
			_nWwLen_ = This.NumberOfItems()
			_anWwResult_ = []
			for _iWw_ = 1 to _nWwLen_
				@AddItem(_anWwResult_, _iWw_)
			next
			return _anWwResult_
		ok

		_anWwResult2_ = []
		for _jWw_ = 1 to _nWwFirst_ - 1
			@AddItem(_anWwResult2_, _jWw_)
		next
		return _anWwResult2_

	  #=================================#
	 #  WALKING IN ZIGZAG PATTERN      #
	#=================================#

	def WalkZigZag(nStep)
		_nWzLen_ = This.NumberOfItems()
		_anWzResult_ = []
		_bWzForward_ = 1
		_iWz_ = 1

		while _iWz_ >= 1 and _iWz_ <= _nWzLen_
			@AddItem(_anWzResult_, _iWz_)
			if _bWzForward_
				_iWz_ += nStep
				if _iWz_ > _nWzLen_
					_iWz_ = _nWzLen_
					_bWzForward_ = 0
				ok
			else
				_iWz_ -= nStep
				if _iWz_ < 1
					exit
				ok
			ok
		end

		return _anWzResult_

	  #==================================#
	 #  WALKING EVERY NTH POSITION      #
	#==================================#

	def WalkEveryNth(n)
		_nWenLen_ = This.NumberOfItems()
		_anWenResult_ = []

		for _iWen_ = n to _nWenLen_ step n
			@AddItem(_anWenResult_, _iWen_)
		next

		return _anWenResult_

		def WalkEach(n)
			return This.WalkEveryNth(n)

	  #======================================#
	 #  POSITIONS WHERE CONDITION IS TRUE   #
	#======================================#

	def PositionsWhere(pcCondition)
		return This.WalkW(pcCondition)

		def PositionsW(pcCondition)
			return This.PositionsWhere(pcCondition)

	  #==============================#
	 #  WALK BETWEEN TWO VALUES     #
	#==============================#

	def WalkFromTo(nFrom, nTo)
		_anWftResult_ = []
		if nFrom <= nTo
			for _iWft_ = nFrom to nTo
				@AddItem(_anWftResult_, _iWft_)
			next
		else
			for _jWft_ = nFrom to nTo step -1
				@AddItem(_anWftResult_, _jWft_)
			next
		ok
		return _anWftResult_

	  #==============================#
	 #  WALK SKIPPING N ITEMS       #
	#==============================#

	def WalkSkipping(n)
		_nWskLen_ = This.NumberOfItems()
		_anWskResult_ = []

		_iWsk_ = 1
		while _iWsk_ <= _nWskLen_
			@AddItem(_anWskResult_, _iWsk_)
			_iWsk_ += (n + 1)
		end

		return _anWskResult_

		def WalkSkip(n)
			return This.WalkSkipping(n)

	  #=================================#
	 #  WALK WITH CUSTOM ACCUMULATOR   #
	#=================================#

	def WalkAccumulating(pcExpr)
		return @oList.Map(pcExpr)

		def WalkAccumulate(pcExpr)
			return This.WalkAccumulating(pcExpr)
