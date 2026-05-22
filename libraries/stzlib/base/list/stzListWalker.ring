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

class stzListWalker from stzList

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
		nLen = This.NumberOfItems()
		anResult = []

		_iWf = 1
		for _kWf = 1 to nLen
			if _iWf > nLen exit ok
			anResult + _iWf
			_iWf += n
		next

		return anResult

		def WalkForwardNSteps(n)
			return This.WalkNForward(n)

	  #==========================================#
	 #  WALKING THE LIST N ITEMS BACKWARD       #
	#==========================================#

	def WalkNBackward(n)
		nLen = This.NumberOfItems()
		anResult = []

		_iWb = nLen
		for _kWb = 1 to nLen
			if _iWb < 1 exit ok
			anResult + _iWb
			_iWb -= n
		next

		return anResult

		def WalkBackwardNSteps(n)
			return This.WalkNBackward(n)

	  #=========================#
	 #  WALKING BETWEEN        #
	#=========================#

	def WalkBetween(n1, n2, nStep)
		anResult = []

		if n1 <= n2
			for i = n1 to n2 step nStep
				anResult + i
			next
		else
			for i = n1 to n2 step -nStep
				anResult + i
			next
		ok

		return anResult

	  #===================================#
	 #  WALKING FORTH AND BACK          #
	#===================================#

	def WalkForthAndBack(n)
		anForward = This.WalkNForward(n)
		anBackward = This.WalkNBackward(n)

		aResult = anForward
		nLen = len(anBackward)
		for i = 1 to nLen
			aResult + anBackward[i]
		next

		return aResult

	  #=========================#
	 #  WALKING WHERE          #
	#=========================#

	def WalkW(pcCondition)
		return This.FindAllItemsW(pcCondition)

	  #==========================#
	 #  WALKING UNTIL           #
	#==========================#

	def WalkUntil(pcCondition)
		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		pcCondition = _StzStripBraces(pcCondition)
		nFirst = StzEngineListFindW(pList, pcCondition)
		StzEngineListFree(pList)

		if nFirst = 0
			nLen = This.NumberOfItems()
			anResult = []
			for i = 1 to nLen
				anResult + i
			next
			return anResult
		ok

		anResult = []
		for i = 1 to nFirst - 1
			anResult + i
		next
		return anResult

	  #==========================#
	 #  WALKING WHILE           #
	#==========================#

	def WalkWhile(pcCondition)
		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		cNegated = "not (" + _StzStripBraces(pcCondition) + ")"
		nFirst = StzEngineListFindW(pList, cNegated)
		StzEngineListFree(pList)

		if nFirst = 0
			nLen = This.NumberOfItems()
			anResult = []
			for i = 1 to nLen
				anResult + i
			next
			return anResult
		ok

		anResult = []
		for i = 1 to nFirst - 1
			anResult + i
		next
		return anResult

	  #=================================#
	 #  WALKING IN ZIGZAG PATTERN      #
	#=================================#

	def WalkZigZag(nStep)
		nLen = This.NumberOfItems()
		anResult = []
		_bZzFwd = 1
		_iZz = 1

		for _kZz = 1 to nLen * 2
			if _iZz < 1 or _iZz > nLen exit ok
			anResult + _iZz
			if _bZzFwd
				_iZz += nStep
				if _iZz > nLen
					_iZz = nLen
					_bZzFwd = 0
				ok
			else
				_iZz -= nStep
				if _iZz < 1
					exit
				ok
			ok
		next

		return anResult

	  #==================================#
	 #  WALKING EVERY NTH POSITION      #
	#==================================#

	def WalkEveryNth(n)
		nLen = This.NumberOfItems()
		anResult = []

		for i = n to nLen step n
			anResult + i
		next

		return anResult

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
		anResult = []
		if nFrom <= nTo
			for i = nFrom to nTo
				anResult + i
			next
		else
			for i = nFrom to nTo step -1
				anResult + i
			next
		ok
		return anResult

	  #==============================#
	 #  WALK SKIPPING N ITEMS       #
	#==============================#

	def WalkSkipping(n)
		nLen = This.NumberOfItems()
		anResult = []

		_iWs = 1
		for _kWs = 1 to nLen
			if _iWs > nLen exit ok
			anResult + _iWs
			_iWs += (n + 1)
		next

		return anResult

		def WalkSkip(n)
			return This.WalkSkipping(n)

	  #=================================#
	 #  WALK WITH CUSTOM ACCUMULATOR   #
	#=================================#

	def WalkAccumulating(pcExpr)
		return This.Map(pcExpr)

		def WalkAccumulate(pcExpr)
			return This.WalkAccumulating(pcExpr)
