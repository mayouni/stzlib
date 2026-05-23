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
		nLen = This.NumberOfItems()
		anResult = []

		i = 1
		while i <= nLen
			anResult + i
			i += n
		end

		return anResult

		def WalkForwardNSteps(n)
			return This.WalkNForward(n)

	  #==========================================#
	 #  WALKING THE LIST N ITEMS BACKWARD       #
	#==========================================#

	def WalkNBackward(n)
		nLen = This.NumberOfItems()
		anResult = []

		i = nLen
		while i >= 1
			anResult + i
			i -= n
		end

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
		return @oList.FindAllItemsW(pcCondition)

	  #==========================#
	 #  WALKING UNTIL           #
	#==========================#

	def WalkUntil(pcCondition)
		pList = @oList._EngineListFromContent()
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
		pList = @oList._EngineListFromContent()
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
		bForward = 1
		i = 1

		while i >= 1 and i <= nLen
			anResult + i
			if bForward
				i += nStep
				if i > nLen
					i = nLen
					bForward = 0
				ok
			else
				i -= nStep
				if i < 1
					exit
				ok
			ok
		end

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

		i = 1
		while i <= nLen
			anResult + i
			i += (n + 1)
		end

		return anResult

		def WalkSkip(n)
			return This.WalkSkipping(n)

	  #=================================#
	 #  WALK WITH CUSTOM ACCUMULATOR   #
	#=================================#

	def WalkAccumulating(pcExpr)
		return @oList.Map(pcExpr)

		def WalkAccumulate(pcExpr)
			return This.WalkAccumulating(pcExpr)
