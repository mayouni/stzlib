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

# Plans walks over a list: answers the positions to visit, forward, backward, in a zigzag, by a condition, by a step or between two positions.
#
# It is the walking helper of stzList, which builds one over itself for its WalkNForward,
# WalkNBackward, WalkW, WalkUntil, WalkWhile and WalkZigZag methods; build one with new
# stzListWalker when you only need the plan of a walk. It never changes the list, so a stzList
# passed in stays intact. Every Walk method answers positions counted from 1, in the order the walk
# visits them, never the items: read the items with the positions, or use the XT forms that take
# :WalkedItems. The condition methods (WalkW, WalkUntil, WalkWhen, WalkWhile) take a test written
# with @item for the current item. The positions of WalkBetween and WalkFromTo are not clipped to
# the list. A walk whose step is 0 (WalkNForward, WalkNBackward, WalkForthAndBack, WalkZigZag) never
# ends. AddWalker, Walkers and Walker raise error R24 today because the class never declares the
# attribute they read. WalkAccumulating is a plain map, not a running total.
#
#   receiver   o1 = new stzListWalker([ 5, 12, 7, 20, 3, 18, 9 ])
#   example    ? @@( o1.WalkNForward(3) )
#              #--> [ 1, 4, 7 ]
#              ? @@( o1.WalkNBackward(3) )
#              #--> [ 7, 4, 1 ]
#              ? @@( o1.WalkW("@item > 10") )
#              #--> [ 2, 4, 6 ]
#              ? @@( o1.WalkUntil("@item > 10") )
#              #--> [ 1, 2 ]
#              ? @@( o1.WalkWhile("@item < 10") )
#              #--> [ 1 ]
#              ? @@( o1.WalkZigZag(3) )
#              #--> [ 1, 4, 7, 7, 4, 1 ]
#              o2 = new stzListWalker([ "שלום", "😀", "x", "y" ])
#              ? @@( o2.WalkEveryNth(2) )
#              #--> [ 2, 4 ]
#   see        stzList, stzListGetter, stzWalker
class stzListWalker from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a walker over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to walk, or a stzList whose content is copied, any other value raises
	#                an error
	#   returns      nothing; the object is built
	#   note         the walker never changes the list or the stzList you passed in
	#   see          Content, WalkNForward
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

	# Returns the list the walker walks over.
	#
	#   returns    a list
	#   see        List, NumberOfItems
	def Content()
		return @oList.Content()

	# Returns the list the walker walks over.
	#
	#   returns    a list
	#   note       the same answer as Content
	#   see        Content, NumberOfItems
	def List()
		return @oList.List()

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

	  #==========================#
	 #  WALKING THE LIST ITEMS  #
	#==========================#

	# Raises error R24 today instead of registering a named walker for the list.
	#
	#   pcName     the name of the walker
	#   pnStart    the position to start from
	#   pnEnd      the position to stop at
	#   pnStep     the step between two positions
	#   returns    nothing
	#   note       a name that is already registered is meant to raise
	#              CanNotAddWalkerAlreadyExistant
	#   warning    it raises error R24 Using uninitialized variable: @awalkers on any list (tried on
	#              two lists), because the class reads the attribute @aWalkers without ever
	#              declaring or filling it
	#   see        Walkers, Walker
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

	# Raises error R24 today instead of answering the registered walkers.
	#
	#   returns    nothing
	#   warning    it raises error R24 Using uninitialized variable: @awalkers, because the class
	#              reads the attribute @aWalkers without ever declaring or filling it (tried on two
	#              lists)
	#   see        AddWalker, Walker
	def Walkers()
		return @aWalkers

	# Raises error R24 today instead of answering the walker registered under a name.
	#
	#   pcWalkerNamed   the name the walker was registered under
	#   returns         nothing
	#   note            WalkerQ is the same call
	#   warning         it raises error R24 Using uninitialized variable: @awalkers, as Walkers does
	#                   (tried on two lists)
	#   see             AddWalker, Walkers
	def Walker(pcWalkerNamed)
		return This.Walkers()[pcWalkerNamed]

		def WalkerQ(pcWalkerNamed)
			return This.Walker(pcWalkerNamed)

	  #==========================================#
	 #  WALKING THE LIST N ITEMS FORWARD        #
	#==========================================#

	# Returns the positions reached by stepping forward n items at a time from the first one.
	#
	#   n          the step between two positions
	#   returns    a list of positions
	#   note       the answer lists positions, not items: 7 items with n = 2 give 1, 3, 5, 7;
	#              WalkForwardNSteps is the same call
	#   warning    an n of 0 never ends, since the loop does not advance (read from the code, not
	#              run, because it would fill the memory)
	#   see        WalkNBackward, WalkEveryNth, WalkSkipping
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

	# Returns the positions reached by stepping backward n items at a time from the last one.
	#
	#   n          the step between two positions
	#   returns    a list of positions
	#   note       7 items with n = 3 give 7, 4, 1; WalkBackwardNSteps is the same call
	#   warning    an n of 0 never ends, as in WalkNForward (read from the code, not run)
	#   see        WalkNForward, WalkZigZag
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

	# Returns the positions from one to another, stepping by a given amount, forward or backward.
	#
	#   n1         the first position
	#   n2         the last position
	#   nStep      the size of each step, always positive
	#   returns    a list of positions
	#   note       a start larger than the end walks backward; the positions are not clipped to the
	#              list, so WalkBetween(1, 99, 3) on 7 items goes on to 97
	#   see        WalkFromTo, WalkNForward
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

	# Returns the positions reached going forward n at a time and then backward n at a time.
	#
	#   n          the step between two positions
	#   returns    a list of positions
	#   note       the forward walk ends where the backward walk begins, so that position appears
	#              twice: 7 items with n = 3 give 1, 4, 7, 7, 4, 1
	#   warning    an n of 0 never ends, as in WalkNForward (read from the code, not run)
	#   see        WalkZigZag, WalkNForward, WalkNBackward
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

	# Returns the positions of the items that satisfy a condition.
	#
	#   pcCondition   the test, written with @item for the current item, such as "@item > 10"
	#   returns       a list of positions
	#   note          on 5, 12, 7, 20, 3, 18, 9 the test "@item > 10" gives 2, 4, 6; PositionsWhere
	#                 is the same call
	#   see           WalkWhere, WalkUntil, WalkWhen
	#@ aka  Walk the list collecting where the W condition holds.
	def WalkW(pcCondition)
		return @oList.FindAllItemsW(pcCondition)

	  #==========================#
	 #  WALKING UNTIL           #
	#==========================#

	# Returns the positions from the first item up to and including the first one that satisfies a condition.
	#
	#   pcCondition   the test, written with @item, or a pair [ :Before, test ] to stop just before
	#                 the match
	#   returns       a list of positions
	#   note          when nothing satisfies the test every position is returned; on 5, 12, 7, 20,
	#                 3, 18, 9 the test "@item > 10" gives 1, 2, and the :Before form gives 1
	#   see           WalkWhen, WalkWhile, WalkW
	#@ aka  Walk the items UNTIL the given condition holds.
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

	# Returns the positions of the items that satisfy a condition.
	#
	#   pcCondition   the test, written with @item for the current item
	#   returns       a list of positions
	#   note          the same call as WalkW
	#   see           WalkW, WalkWhen
	#@ aka  Walk the list collecting where the condition holds.
	def WalkWhere(pcCondition)
		return @oList.FindAllItemsW(pcCondition)


	  #==========================#
	 #  WALKING WHEN            #
	#==========================#

	# Returns the positions from the first item that satisfies a condition to the end of the list.
	#
	#   pcCondition   the test, written with @item for the current item
	#   returns       a list of positions
	#   note          nothing satisfying the test gives [ ]; on 5, 12, 7, 20, 3, 18, 9 the test
	#                 "@item > 10" gives 2 to 7
	#   see           WalkUntil, WalkWhile, WalkW
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

	# Returns the positions from the first item as long as every item satisfies a condition.
	#
	#   pcCondition   the test, written with @item for the current item
	#   returns       a list of positions
	#   note          the walk stops before the first item that fails the test and gives [ ] when
	#                 the first item fails; on 5, 12, 7 the test "@item < 10" gives 1
	#   see           WalkUntil, WalkWhen
	#@ aka  Walk the items WHILE the given condition holds.
	def WalkWhile(pcCondition)
		_pWwList_ = @oList._EngineListFromContent()
		if _pWwList_ = "" return [] ok

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

	# Returns the positions going forward by a step to the end and then back by the same step.
	#
	#   nStep      the step between two positions
	#   returns    a list of positions
	#   note       when the step lands exactly on the last position that position appears twice: 7
	#              items with step 2 give 1, 3, 5, 7, 7, 5, 3, 1, and 6 items give 1, 3, 5, 6, 4, 2
	#   warning    a step of 0 never ends, since the loop does not advance (read from the code, not
	#              run)
	#   see        WalkForthAndBack, WalkNForward
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

	# Returns the positions n, 2n, 3n and so on.
	#
	#   n          the step between two positions
	#   returns    a list of positions
	#   note       the first position is not included unless n is 1; an n of 0 gives [ ]; WalkEach
	#              is the same call
	#   see        WalkNForward, WalkSkipping
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

	# Returns every position from one to another, forward or backward.
	#
	#   nFrom      the first position
	#   nTo        the last position
	#   returns    a list of positions
	#   note       a start larger than the end walks backward; the positions are not clipped to the
	#              list, so WalkFromTo(0, 9) on 7 items answers 0 to 9
	#   see        WalkBetween, WalkNForward
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

	# Returns the positions reached by skipping n items between two visited ones.
	#
	#   n          how many items to skip each time
	#   returns    a list of positions
	#   note       it starts at position 1, and skipping 1 visits 1, 3, 5, 7; WalkSkip is the same
	#              call
	#   see        WalkNForward, WalkEveryNth
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

	# Returns the result of an expression applied to each item, in order, with no running total.
	#
	#   pcExpr     the expression of the current item, written with @item, such as "@item * 2"
	#   returns    a list of the results
	#   note       the name suggests an accumulation but the call is a plain map: "@item * 2" on 5,
	#              12, 7 gives 10, 24, 14, and "@item" gives the list itself; WalkAccumulate is the
	#              same call
	#   see        WalkW, Content
	def WalkAccumulating(pcExpr)
		return @oList.Map(pcExpr)

		def WalkAccumulate(pcExpr)
			return This.WalkAccumulating(pcExpr)
