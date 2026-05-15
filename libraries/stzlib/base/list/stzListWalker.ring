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
			if isList(pcName) and StzListQ(pcName).IsNameOrNamedNamedParam()
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
		aContent = This.Content()
		nLen = len(aContent)
		anResult = []

		for @i = 1 to nLen
			@item = aContent[@i]
			cCode = 'bOk = (' + pcCondition + ')'
			eval(cCode)
			if bOk
				anResult + @i
			ok
		next

		return anResult

	  #==========================#
	 #  WALKING UNTIL           #
	#==========================#

	def WalkUntil(pcCondition)
		aContent = This.Content()
		nLen = len(aContent)
		anResult = []

		for @i = 1 to nLen
			@item = aContent[@i]
			cCode = 'bOk = (' + pcCondition + ')'
			eval(cCode)
			if bOk
				exit
			ok
			anResult + @i
		next

		return anResult

	  #==========================#
	 #  WALKING WHILE           #
	#==========================#

	def WalkWhile(pcCondition)
		aContent = This.Content()
		nLen = len(aContent)
		anResult = []

		for @i = 1 to nLen
			@item = aContent[@i]
			cCode = 'bOk = (' + pcCondition + ')'
			eval(cCode)
			if NOT bOk
				exit
			ok
			anResult + @i
		next

		return anResult
