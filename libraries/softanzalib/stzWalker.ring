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

func JumpsATime(n)
	return [ :JumpsATime , n ]

func TakingJumps(n)
	return [ :TakingJumps , n ]

func TakingNEqualJumps(n)
	return [ :TakingNEqualJumps , n ]

func InNRandomJumps(n)
	return [ :InJumps , n ]

func NMoreJumpsATime(n)
	return [ :NMoreJumpsATime , n ]

func FellowingJumps(paJumps)
	return [ :FellowingJumps , paJumps ]

func FellowingRandomJumps(paJumps)
	return [ :FellowingRandomJumps , paJumps ]

func WhileWalking(cWalker)
	return cWalker

  /////////////////
 ///   CLASS   ///
/////////////////

class stzWalker from stzList

	@nStart = 1
	@nEnd = @nStart + 1
	@nJump = 1

	@nCurrentPos

	  #-------------------------#
	 #   SETTING THE WALKER    #
	#-------------------------#

	def init(pnStart, pnEnd, pnJump)
		# There are the two ways to initiate a stzWalker object:

		# -> by providing a list of params values. Example:
		# 	new stzWalker([ 1, 10, 3 ])

		# -> by providing a hashlist of named params. Example:
		# 	new stzWalker([
		# 		:StartAt = 1,
		# 		:EndAt = 10,
		# 		:Step = 3
		# ])

		if CheckParams() #TODO // Should be CheckNamedParams()...

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

			if isList(pnJump) and
			   StzListQ(pnJump).IsOneOfTheseNamedParams([
				:Jump, :Step, :NStep
			  ])
	
				pnJump = pnJump[2]
			ok
		ok

		if NOT @AreNumbers([ pnStart, pnEnd, pnJump ])
			StzRaise("Incorrect params types! pnStart, pnEnd, and pnJump must all be numbers.")
		ok	

		# Some logical checks

		if pnStart <= 0 or pnEnd <= 0
			StzRaise("Can't create the stzWalker object!  pnStart and pnEnd must be positive numbers.")
		ok

		if pnStart = pnEnd
			StzRaise("Can't create the stzWalker object! pnStart and pnEnd must be different.")
		ok

		if NOT pnJump > 0
			StzRaise("Can't create the stzWalker object! pnJump must be strictly positive number.")
		ok

		if pnJump > abs(pnEnd - pnStart) + 1
			StzRaise("Can't walk! The step is larger then the number of walkable positions.")
		ok

		# Setting the object attributes

		@nStart = pnStart
		@nEnd = pnEnd
		@nJump = pnJump	

		# Setting the (default) current position

		@nCurrentPos = @nStart


	  #------------------#
	 #   GENERAL INFO   #
	#------------------#

	def Content()
		return This.WalkedPositions()

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

	def Jump() #NOTE: We can't use Step() because STEP is reserved by Ring
		return @nJump

		#< @FunctionAlternativeForms

		def NStep()
			return This.Jump()

		def NumberOfPositionsPerJump()
			return This.Jump()

		def NumberOfPositionsPerStep()
			return This.Jump()

		def NumberOfPositionsInAStep()
			return This.Jump()

		def NumberOfPositionsInAJump()
			return This.Jump()

		#--

		def HowManyPositionsPerJump()
			return This.Jump()

		def HowManyPositionsPerStep()
			return This.Jump()

		def HowManyPositionsInAStep()
			return This.Jump()

		def HowManyPositionsInAJump()
			return This.Jump()

		#>

	def CurrentPosition()
		return @nCurrentPos

		def Position()
			return @nCurrentPos

		def Current()
			return @nCurrentPos

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

	def WalkablePositions()
		anResult = []
		if @nStart < @nEnd
			for i = @nStart to @nEnd step @nJump
				anResult + i
			next

		else // backaward

			for i = @nStart to @nEnd step -@nJump
				anResult + i
			next
			anResult = ring_reverse(anResult)
		ok

		return anResult

		def WalkablePositionsQ()
			return new stzList(This.WalkedPositions())

		def Walkables()
			return This.WalkablePositions()

			def WalkablesQ()
				return This.WalkablePositionsQ()

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

		def NumberOfJumps()
			return This.NumberOfWalkablePositions()

		def CountJumps()
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

	def IsWalkablePosition(n)
		if ring_find( This.WalkablePositions(), n) > 0
			return TRUE

		else
			return FALSE
		ok

		def IsWalkable(n)
			return This.IsWalkablePosition(n)

	def IsUnwalkablePosition(n)
		if ring_find( This.UnwalkablePositions(), n) > 0
			return TRUE

		else
			return FALSE
		ok

		def IsUnwalkable(n)
			return This.IsUnwalkablePosition(n)

	  #-----------------------#
	 #   WALKING DIRECTION   #
	#-----------------------#

	def WalkingDirection()
		if @nStart < @nEnd
			return :Forward
		else
			return :Backward
		ok

		def Direction()
			return This.WalkingDirection()

	def SetWalkingDirection(pcDirection)
		if CheckParams()
			if isList(pcDirection) and StzStringQ(pcDirection).IsForwardOrBackwardNamedParam()
			ok
		ok

		if pcDirection = :Forward
			if @nStart < @nEnd
				# do nothing, already :Forward
			else
				# Swipe between start and end positions

				nTemp = @nStart
				@nStart = @nEnd
				@nEnd = nTemp
				
			ok

		else // pcDirection = :Backward
			if @nStart > @nEnd
				# Do nothing, already :Barckward

			else
				# Swipe netween start and end positions

				nTemp = @nStart
				@nStart = @nEnd
				@nEnd = nTemp
			ok
		ok

		def SetDirection(pcDirection)
			This.SetWalkingDirection(pcDirection)

	def TurnAround()

		if This.Direction() = :Forward
			This.SetDirection(:Backward)
		else
			This.SetDirection(:Forward)
		ok

		def InverseWalkingDirection()
			This.TurnAround()

		def InverseDirection()
			This.TurnAround()

		def Turn()
			This.TurnAround()

	def TurnForward()
		This.SetDirection(:Forward)

	def TurnBackward()
		This.SetDirection(:Backward)

	  #--------------#
	 #   WALKING    #
	#--------------#

	def RemainingWalkables()
		anWalkables = This.Walkables()
		nCurrent = ring_find( anWalkables, This.CurrentPosition() )

		anResult = []
		nLen = len(anWalkables)

		if This.Direction() = :Forward
			if nCurrent < nLen
				for i = nCurrent + 1 to nLen
					anResult + anWalkables[i]
				next
			ok
		else

			if nCurrent > 1
				for i = 1 to nCurrent - 1
					anResult + anWalkables[i]
				next
			ok
		ok

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
		nSteps = This.NumberOfRemainingWalkables()
		if nSteps = 0
			StzRaise("Can't walk! No more walkable positions.")
		ok

		return This.WalkNSteps( nSteps + 1 )

	def WalkNSteps(n)
		anRemaining = This.RemainingWalkables()
		nLenRemaining = len(anRemaining)

		if n > nLenRemaining
			StzRaise("Can't walk! n exceeds the number of remaining walkable positions.")
		ok

		anWalks = [ This.CurrentPosition() ]
		
		if This.Direction() = :Backward
			anRemaining = ring_reverse(anRemaining)
		ok

		for i = 1 to n
			anWalks + anRemaining[i]
		next

		@nCurrentPos = anWalks[len(anWalks)]

		return anWalks

		#< @FunctionAlternativeForms

		def NSteps(n)
			return This.WalkNSteps(n)

		def WalkNJumps(n)
			return This.WalkNSteps(n)

		def NJumps(n)
			return This.WalkNSteps(n)
		#>

	def NthWalkablePosition(n)
		if CheckParams()
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

		return This.WalkablePositions()[n]

		def NthWalkable(n)
			return This.NthWalkablePosition(n)

	def FirstWalkablePosition()
		return This.NthWalkablePosition(1)

	def LastWalkablePosition()
		return This.NthWalkablePosition(This.NumberOfWalkables())

	def NthStep(n)
		if CheckParams()
			if isString(n)
				if n = :First
					n = 1
				but n = :Last
					n = This.NumberOfSteps()
				ok
			ok

			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

		ok
		return This.Walkables()[n]

		def NthJump(n)
			return This.NthStep()

	def FirstStep()
		return This.NthStep(1)

	def LastStep()
		return This.NthStep(This.NumberOfSteps())

	def HasNext()
		if This.Direction() = :Forward

			if This.CurrentPosition() < This.LastStep()
				return TRUE
			else
				return FALSE
			ok

		elese // Direction = :Backward
			if This.CurrentPosition() > This.LastStep()
				return TRUE
			else
				return FALSE
			ok
		ok

		def CanWalk()
			return This.HasNext()

		def HasNextStep()
			return This.HasNext()

		def HasNextJump()
			return This.HasNext()
		
	  #---------------------#
	 #   WALKING FORWARD   #
	#---------------------#

	def WalkForward()
		if This.Direction() = :Forward
			return This.Walk()

		else
			This.SetDirection(:Backward)
			return This.Walk()
		ok

		def Forward()
			return This.WalkForward()

	def WalkN(n)
		if This.Direction() = :Forward
			return This.WalkNForward(n)
		else
			return This.WalkNBackward(n)
		ok

		def JumpN(n)
			return This.WalkN(n)

	def WalkNJumpsForward(n)
		if This.Direction() = :Forward
			return This.WalkNJumps(n)

		else
			This.SetDirection(:Backward)
			return This.WalkNJumps(n)
		ok

		#< @FunctionAlternativeForms

		def WalkForwardNJumps()
			return This.WalkNJumpsForward(n)

		def WalkNForward(n)
			return This.WalkNJumpsForward(n)

		def WalkForwardN(n)
			return This.WalkNJumpsForward(n)

		#--

		def WalkNStepsForward(n)
			return This.WalkNJumpsForward(n)

		def WalkForwardNSteps()
			return This.WalkNJumpsForward(n)

		#==

		def NJumpsForward(n)
			return This.WalkNJumpsForward(n)

		def ForwardNJumps()
			return This.WalkNJumpsForward(n)

		def NForward(n)
			return This.WalkNJumpsForward(n)

		def ForwardN(n)
			return This.WalkNJumpsForward(n)

		#--

		def NStepsForward(n)
			return This.WalkNJumpsForward(n)

		def ForwardNSteps()
			return This.WalkNJumpsForward(n)

		#>

	  #----------------------#
	 #   WALKING BACKWARD   #
	#----------------------#

	def WalkBackward()
		if This.Direction() = :Backward
			return This.Walk()

		else
			This.SetDirection(:Backward)
			return This.Walk()
		ok

		def Backward()
			return This.WalkBackward()

	def WalkNJumpsBackward(n)
		if This.Direction() = :Backward
			return This.WalkNJumps(n)

		else
			This.SetDirection(:Backward)
			return This.WalkNJumps(n)
		ok

		#< @FunctionAlternativeForms

		def WalkBackwardNJumps()
			return This.WalkNJumpsBackward(n)

		def WalkNBackward(n)
			return This.WalkNJumpsBackward(n)

		def WalkBackwardN(n)
			return This.WalkNJumpsBackward(n)

		#--

		def WalkNStepsBackward(n)
			return This.WalkNJumpsBackward(n)

		def WalkBackwardNSteps()
			return This.WalkNJumpsBackward(n)

		#==

		def NJumpsBackward(n)
			return This.WalkNJumpsBackward(n)

		def BackwardNJumps()
			return This.WalkNJumpsBackward(n)

		def NBackward(n)
			return This.WalkNJumpsBackward(n)

		def BackwardN(n)
			return This.WalkNJumpsBackward(n)

		#--

		def NStepsBackward(n)
			return This.WalkNJumpsBackward(n)

		def BackwardNSteps()
			return This.WalkNJumpsBackward(n)

		#>

	  #-----------#
	 #   MISC.   #
	#-----------#

	def ToStzList()
		return new stzList( This.WalkedPositions() )
