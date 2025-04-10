#-------------------------------------------------------------------------#
# 		   SOFTANZA LIBRARY (V1.0) - STZSTRING		          #
# 	An accelerative library for Ring applications, and more!	  #
#-------------------------------------------------------------------------#
#									  #
# 	Description	: The class for creating walkers in Softanza      #
#	Version		: V1.0 (2020-2024)				  #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		  #
#								          #
#-------------------------------------------------------------------------#

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func With(p)
	return [ :With, p ]

func Named(c)
	return c

func WhileWalking(cWalker)
	return cWalker

func IsWalker(pObject)
	if isObject(pObject) and classname(pObject) = "stzwalker"
		return _TRUE_
	else
		return _FALSE_
	ok

	func @IsWalker(pObject)
		return IsWalker(pObject)

  /////////////////
 ///   CLASS   ///
/////////////////

class stzWalker

	@nStart
	@nEnd
	@nStep

	@anWalkables = []
	@nCurrentPos

	@anWalks = []

	  #-------------------------#
	 #   SETTING THE WALKER    #
	#-------------------------#

	def init(pnStart, pnEnd, pnStep)
		# There are the two ways to initiate a stzWalker object:

		# -> by providing a list of params values. Example:
		# 	new stzWalker([ 1, 10, 3 ])

		# -> by providing a hashlist of named params. Example:
		# 	new stzWalker([
		# 		:StartAt = 1,
		# 		:EndAt = 10,
		# 		:Step = 3
		# ])

		if CheckingParams() #TODO // Should be CheckNamedParams()...

			if isList(pnStart) and
			   StzListQ(pnStart).IsOneOfTheseNamedParams([
				:Start, :StartAt, :StartsAt, :StartingAt,
				:StartFrom, :StartsFrom, :StartingFrom,

				:From, :FromPosition
			   ])

				pnStart = pnStart[2]
			ok

			if isList(pnEnd) and
			   StzListQ(pnEnd).IsOneOfTheseNamedParams([
				:End, :EndAt, :EndsAt, :EndingAt,
				:Stop, :StopAt, :StopsAt, :StoppingAt,

				:To, :ToPosition
			   ])

				pnEnd = pnEnd[2]
			ok

			if isList(pnStep) and
			   StzListQ(pnStep).IsOneOfTheseNamedParams([
				:Jump, :Step, :NStep
			  ])
	
				pnStep = pnStep[2]
			ok
		ok

		if NOT @AreNumbers([ pnStart, pnEnd, pnStep ])
			StzRaise("Incorrect params types! pnStart, pnEnd, and pnStep must all be numbers.")
		ok	

		# Some logical checks

		if pnStart = pnEnd
			StzRaise("Can't create the stzWalker object! pnStart and pnEnd must be different.")
		ok

		if NOT pnStep > 0
			StzRaise("Can't create the stzWalker object! pnStep must be strictly positive number.")
		ok

		if pnStep > abs(pnEnd - pnStart) + 1
			StzRaise("Can't walk! The step is larger then the number of walkable positions.")
		ok

		# Setting the object attributes

		@nStart = pnStart
		@nEnd = pnEnd
		@nStep = pnStep	

		@anWalkables = []
		if @nStart < @nEnd
			for i = @nStart to @nEnd step @nStep
				@anWalkables + i
			next
		else
			for i = @nStart to @nEnd step -@nStep
				@anWalkables + i
			next
		ok

		@nCurrentPos = pnStart

	  #------------------#
	 #   GENERAL INFO   #
	#------------------#

	def Content()
		return This.WalkablePositions()

		def Value()
			return Content()

	def Copy()
		return new stzWalker( This.Content() )

	def StartPosition()
		return @nStart

		def StartingPosition()
			return This.StartPosition()

	def EndPosition()
		return @nEnd

		def EndingPosition()
			return This.EndPosition()

	def NStep() #NOTE: We can't use Step() because STEP is reserved by Ring
		return @nStep

		#< @FunctionAlternativeForms

		def NumberOfPositionsPerStep()
			return This.NStep()

		def NumberOfPositionsInAStep()
			return This.NStep()

		#--

		def HowManyPositionsPerStep()
			return This.NStep()

		def HowManyPositionsInAStep()
			return This.NStep()

		#>

	def CurrentPosition()
		return @nCurrentPos

		def Position()
			return @nCurrentPos

		def Current()
			return @nCurrentPos

	def SetCurrentPosition(n)
		if ring_find(This.Walkables(), n) = 0
			StzRaise("Can't set the current position! n must be a walkable position.")
		ok

		@nCurrentPos = n

		def SetCurrent(n)
			SetCurrentPosition(n)

	  #-----------------------------------------------------#
	 #  POSITIONS, WALKED POSITIONS & UNWALKED POSITIONS   #
	#-----------------------------------------------------#

	def Positions()

		anResult = []

		if @nStart < @nEnd
			anResult = @nStart : @nEnd
		else
			nResult = @nEnd : @nStart
		ok

		return anResult

		def PositionsQ()
			return new stzList(This.Positions())

	def NumberOfPositions()
		nResult = 0

		if @nStart < @nEnd
			nResult = @nEnd - @nStart + 1
		else
			nResult = @nStart - @nEnd + 1
		ok

		return nResult

		#< @FunctionAlternativeForms

		def HowManyPositions()
			return This.NumberOfPositions()

		def CountPositions()
			return This.NumberOfPositions()

		#>

	def NumberOfWalkablePositions()
		return len( This.WalkablePositions() )

		#< @FunctionAlternativeForms

		def HowManyWalkablePositions()
			return This.NumberOfWalkablePositions()

		def CountWalkablePositions()
			return This.NumberOfWalkablePositions()

		def NumberOfWalkables()
			return This.NumberOfWalkablePositions()

		def HowManyWalkables()
			return This.NumberOfWalkablePositions()

		def CountWalkables()
			return This.NumberOfWalkablePositions()

		#--

		def NumberOfSteps()
			return This.NumberOfWalkablePositions()

		def HowManySteps()
			return This.NumberOfWalkablePositions()

		def CountSteps()
			return This.NumberOfWalkablePositions()

		#>

	def UnwalkablePositions()
		anResult = This.PositionsQ().ManyRemoved( This.WalkablePositions() )
		return anResult

		def Unwalkables()
			return This.UnwalkablePositions()

	def NumberOfUnwalkablePositions()
		return len( This.UnwalkablePositions() )

		#< @FunctionAlternativeForms

		def HowManyUnwalkablePositions()
			return This.NumberOfUnwalkablePositions()

		def CountUnwalkablePositions()
			return This.NumberOfUnwalkablePositions()

		def HowManyUnwalkables()
			return This.NumberOfUnwalkablePositions()

		def CountUnwalkables()
			return This.NumberOfUnwalkablePositions()

		#>

	  #--------------#
	 #   WALKING    #
	#--------------#

	def RemainingWalkables()
		anWalkables = This.Walkables()
		nCurrent = ring_find( anWalkables, This.CurrentPosition() )

		anResult = []
		nLen = len(anWalkables)

		for i = nCurrent + 1 to nLen
			anResult + anWalkables[i]
		next

		return anResult

		def Remaining()
			return This.RemainingWalkables()

	def NumberOfRemainingWalkables()
		return len(This.RemainingWalkables())

		def HowManyRemainingWalkables()
			return This.NumberOfRemainingWalkables()

		def CountRemainingWalkables()
			return This.NumberOfRemainingWalkables()

		def HowManyRemaining()
			return This.NumberOfRemainingWalkables()

		def CountRemaining()
			return This.NumberOfRemainingWalkables()

	def Walk()
		return This.WalkNSteps(1)

	def WalkNSteps(n)
		anRemaining = This.RemainingWalkables()
		nLenRemaining = len(anRemaining)

		if n > nLenRemaining
			StzRaise("Can't walk! No more walkable positions.")
		ok

		anWalks = [ This.CurrentPosition() ]

		for i = 1 to n
			anWalks + anRemaining[i]
		next

		@anWalks + anWalks
		@nCurrentPos = anWalks[len(anWalks)]

		return anWalks

		#< @FunctionAlternativeForms

		def NSteps(n)
			return This.WalkNSteps(n)

		def WalkN(n)
			return This.WalkNSteps(n)

		#>

	def Walkables()
		return @anWalkables

		def WalkablePositions()
			return This.Walkables()

	def NthWalkablePosition(n)
		if CheckingParams()
			if isString(n)
				if n = :First
					n = 1
				but n = :Last
					n = This.NumberOfWalkables()
				ok
			ok

			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

		ok

		return @anwalkables[n]

		#< @FunctionAlternativeForms

		def NthWalkable(n)
			return This.NthWalkablePosition(n)

		def NthStep(n)
			return This.NthWalkablePosition(n)

		#>

	def FirstWalkablePosition()
		return This.NthWalkablePosition(1)

		#< @FunctionAlternativeForms

		def FirstWalkable()
			return This.FirstWalkablePosition()

		def FirstStep()
			return This.FirstWalkablePosition()

		#>

	def LastWalkablePosition()
		return This.NthWalkablePosition(This.NumberOfWalkables())

		#< @FunctionAlternativeForms

		def LastWalkable()
			return This.LastWalkablePosition()

		def LastStep()
			return This.LastWalkablePosition()

		#>

	def HasNext()
		if This.CurrentPosition() < This.LastStep()
				return _TRUE_
			else
				return _FALSE_
			ok

		def HasNextStep()
			return This.HasNext()

	  #-----------------------------#
	 #  WALKING TO GIVEN POSITION  #
	#-----------------------------#

	def WalkTo(n)
		return This.WalkBetween( This.CurrentPosition(), n)

		def WalkToPosition(n)
			return This.WalkTo(n)


	def WalkToFirst()
		return This.WalkTo( This.FirstWalkablePosition() )

		def WalkToFirstPosition()
			return This.WalkTofirst()

		def WalkToFirstWalkable()
			return This.WalkTofirst()

		def WalkToFirstWalkablePosition()
			return This.WalkToFirst()

	def WalkToLast()
		return This.WalkTo( This.LastWalkablePosition() )

		def WalkToLastPosition()
			return This.WalkToLast()

		def WalkToLastWalkable()
			return This.WalkToLast()

		def WalkToLastWalkablePosition()
			return This.WalkToLast()

	  #---------------------------------#
	 #  WALKING FROM A GIVEN POSITION  #
	#---------------------------------#

	def WalkFrom(n)
		return This.WalkBetween( n, This.CurrentPosition())

		def WalkFromPosition(n)
			return This.WalkFrom(n)

	def WalkFromFirst()
		anResult = This.WalkFrom( This.FirstWalkable() )
		return anResult

		def WalkFromFirstPosition()
			return This.WalkFromFirst()

		def WalkFromStart()
			return This.WalkFromFirst()

	def WalkFromLast()
		anResult = This.WalkFrom( This.LastWalkable() )
		return anResult

		def WalkFromLastPosition()
			return This.WalkFromLast()

		def WalkFromEnd()
			return This.WalkFromLast()

	  #--------------------------------------#
	 #  CHECKING IF A POSITION IS WALKABLE  #
	#--------------------------------------#

	def IsWalkable(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		if ring_find( This.Walkables(), n) > 0
			return _TRUE_
		else
			return _FALSE_
		ok

		#< @FunctionAlternativeForms

		def IsWalkablePosition(n)
			return This.IsWalkable(n)

		def IsAWalkable(n)
			return This.IsWalkable(n)

		def ISAWalkablePosition(n)
			return This.IsWalkable(n)

		#>

	def AreWalkables(anPos)
		if CheckingParams()
			if NOT @IsListOfNumbers(anPos)
				StzRaise("Incorrect param type! anPos must be a list of numbers.")
			ok
		ok

		anWalkables = This.Walkables()

		anPos = U(anPos)
		nLen = len(anPos)
		bResult = _TRUE_

		for i = 1 to nLen
			if ring_find(anWalkables, anPos[i]) = 0
				bResult = _FALSE_
				exit
			ok
		next

		return bResult

		def AreWalkablePositions(anPos)
			return This.AreWalkables(anPos)

	  #----------------------------------------#
	 #  CHECKING IF A POSITION IS UNWALKABLE  #
	#----------------------------------------#

	def IsUnwalkable(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		if ring_find( This.Unwalkables(), n) > 0
			return _TRUE_
		else
			return _FALSE_
		ok

		#< @FunctionAlternativeForms

		def IsUnwalkablePosition(n)
			return This.IsUnwalkable(n)

		def IsAnUnwalkable(n)
			return This.IsUnwalkable(n)

		def IsAnUnwalkablePosition(n)
			return This.IsUnwalkable(n)

		#>

	def AreUnwalkables(anPos)
		if CheckingParams()
			if NOT @IsListOfNumbers(anPos)
				StzRaise("Incorrect param type! anPos must be a list of numbers.")
			ok
		ok

		anUnwalkables = This.Unwalkables()

		anPos = U(anPos)
		nLen = len(anPos)
		bResult = _TRUE_

		for i = 1 to nLen
			if ring_reverse(anUnwalkables, anPos[i]) = 0
				bResult = _FALSE_
				exit
			ok
		next

		return bResult

	  #---------------------------------------------#
	 #  WALKING FROM A GIVEN POSITION TO AN OTHER  #
	#---------------------------------------------#

	def WalkBetween(n1, n2)
		if CheckingParams()
			if isList(n2) and StzListQ(n3).IsAndNamedParam()
				n2 = n2[2]
			ok

			if NOT (isNumber(n1) and isNumber(n2))
				StzRaise("Incorrect param type! n1 and n2 must be numbers.")
			ok
		ok

		if NOT This.AreWalkables([ n1, n2 ])
			StzRaise("Can't walk! The position(s) provided must be walkable.")
		ok

		anResult = []

		if n1 < n2
			for i = n1 to n2 step @nStep
				anResult + i
			next

		else
			for i = n1 to n2 step -@nStep
				anResult + i
			next

		ok

		@anWalks + anResult
		@nCurrentPos = anResult[ len(anResult) ]

		return anResult

		#< @FunctionAlternativeForms

		def WalkBetweenPositions(n1, n2)
			return This.WalkBetween(n1, n2)

		def WalkFromTo(n1, n2)
			return This.WalkBetween(n1, n2)

		#>

	  #--------------------------------#
	 #  GETTING THE HISTORY OF WALKS  #
	#--------------------------------#

	def Walks()
		return @anWalks

		def WalkingHistory()
			return @anWalks

		def WalkHistory()
			return @anWalks

		def History()
			return @anWalks

	def NumberOfWalks()
		return len(@anWalks)

		def HowManyWalks()
			return len(@anWalks)

		def CountWalks()
			return len(@anWalks)

		def SizeOfWalkingHistory()
			return len(@anWalks)

		def SizeOfWalkHistory()
			return len(@anWalks)

	def RemoveWalks()
		@anWalks = []

		def RemoveWalkingHistory()
			@anWalks = []

		def RemoveWalkHistory()
			@anWalks = []

	def NthWalk(n)
		return @anWalks[n]

	def FirstWalk()
		return @anWalks[1]

	def LastWalk()
		return @anWalks[len(@anWalks)]

	  #-----------#
	 #   MISC.   #
	#-----------#

	def ToStzList()
		return new stzList( This.WalkedPositions() )
