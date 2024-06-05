func With(p)
	return [ :With, p ]

func Named(c)
	return c

func StartingAt(n)
	return n

func EndingAt(n)
	return n

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

class stzWalker from stzList
	@cName
	@nStartPosition
	@nEndPosition
	@nStep	#--> Number of positions walked in one step

	@anWalkedPositions = []

	@cWalkedDirection

	def init(paWalkerOptions)
		This.SetWalker(paWalkerOptions)

	  #-------------------------#
	 #   SETTING THE WALKER    #
	#-------------------------#

	def SetWalker(paWalkerOptions)


		if NOT ( isList(paWalkerOptions) and

			 ( Q(paWalkerOptions).IsEmpty() or
			   Q(paWalkerOptions).IsMadeOfSome([
				:Name, :StartingAt, :EndingAt,
				:Step, :Direction ]) ) )

			StzRaise("Can not create stzWalker object! Incorrect param format.")
		ok

		# Defalult values

		@cName = :Walker0

		cName = paWalkerOptions[ :Name ]
		if isString( cName ) and cName != NULL
			@cName = cName
		ok
		
		@nStartPosition = 1

		nStart = paWalkerOptions[ :StartingAt ]
		if isNumber(nStart) and nStart > 0
			@nStartPosition = nStart
		ok

		@nEndPosition = @nStartPosition + 1

		nEnd = paWalkerOptions[ :EndingAt ]
		if isNumber(nEnd) and nEnd > @nStartPosition
			@nEndPosition = nEnd
		ok

		@nStep = 1

		nStep = paWalkerOptions[ :Step ]
		if isNumber(nStep) and Q(nStep).IsBetween(1, @nEndPosition - 1)
			@nStep = nStep
		ok

		@cWalkingDirection = :Forward

		cDirection = paWalkerOptions[ :Direction ]
		if cDirection = :Backward
			@cWalkingdirection = :Backward
		ok

		# Computing walked positions

		for i = @nStartPosition to @nEndPosition step @nStep
			@anWalkedPositions + i
		next

		def ResetWalker(paWalkerOptions)

	  #------------------#
	 #   GENERAL INFO   #
	#------------------#

	def Content()
		return @anWalkedPositions

		def Value()
			return Content()

	def Name()
		return @cName

	def Copy()
		return new stzWalker( This.Content() )

	  #-----------------------------------------------------#
	 #  POSITIONS, WALKED POSITIONS & UNWALKED POSITIONS   #
	#-----------------------------------------------------#

	def Positions()
		n1 = This.StartPosition()
		n2 = This.EndPosition()

		aResult = n1 : n2

		return aResult

	def NumberOfPositions()
		return len( This.Positions() )

	def WalkedPositions()
		return This.Content()

	def NumberOfWalkedPositions()
		return len( This.WalkedPositions() )

	def UnwalkedPositions()
		oCopy = This.ToStzList()
		oCopy - This.WalkedPositions()

		return oCopy.Content()

	def NumberOfUnwalkedPositions()
		return len( This.UnwalkedPositions() )

	def IsWalkedPosition(n)
		if ring_find( This.WalkedPositions(), n) > 0
			return TRUE

		else
			return FALSE
		ok

	def IsNotWalkedPosition(n)
		if ring_find( This.UnwalkedPositions(), n) > 0
			return TRUE

		else
			return FALSE
		ok

	  #-----------------------#
	 #   WALKING DIRECTION   #
	#-----------------------#

	def SetWalkingDirection(pcDirection)
		
		if NOT ( isString(pcDirection) and
			 Q(pcDirection).IsToNamedParam() and
			 Q(pcDirection).IsOneOfThese([ :Forward, :Backward ]) )

			StzRaise("Incorrect param!")

		ok

		@cWalkingDirection = pcDirection

	def WalkingDirection()
		return @cWalkingDirection

	def TurnAround()
		if This.TalkingDirection() = :Forward
			This.SetTalkingDirection(:To = :Backward)
		else
			This.SetTalkingDirection(:To = :Forward)
		ok

		def InverseWalkingDirection()
			This.TurnAround()

	def ShouldWalkForward()
		return This.WalkingDirection() = :Forward

	def ShouldWalkBackward()
		return This.WalkingDirection() = :Backward

	  #-------------#
	 #   WALKING   #
	#-------------#

	def StartPosition()
		return @nStartPosition

	def EndPosition()
		return @nEndPosition

	def NStep() #NOTE: We can't use Step() because STEP is reserved by Ring
		return @nStep

		def NumberOfPositionsPerStep()
			return This.NStep()

		def NumberOfPositionsInStep()
			return This.NStep()

		def NumberOfPositionsInAStep()
			return This.NStep()

		def StepSize()
			return This.NStep()

		def SizeOfStep()
			return This.NStep()

	  #--------------#
	 #   WALKING    #
	#--------------#

	def Walk()
		if This.ShouldWalkForward()
			return This.WalkForward()

		but This.ShouldWalkBackward()
			return This.WalksBackward()

		ok

	def WalkNSteps(n)
		if This.ShouldWalkForward()
			return This.WalkNStepsForward(n)

		but This.ShouldWalkBackward()
			return This.WalksNStepsBackward(n)

		ok

	  #----------------------#
	 #   WALKING Forward   #
	#----------------------#

	def WalkForward()
		return This.WalkNStepsForward( This.Jump() )

	def WalkNStepsForward(n)
		///

		def WalkForwardNSteps()

		def WalkNForward(n)

		def WalkForwardN(n)

	  #----------------------#
	 #   WALKING BACKWARD   #
	#----------------------#


	  #-----------#
	 #   STEPS   #
	#-----------#

	def Steps()
		/*
		StzWalkerQ([ :StartingAt = 1, :EndingAt = 8, :Step = 2 ]) {
			? WalkedPositions()
			#--> [ 1, 3, 5, 8, 10 ]

			? Steps()
			#--> [ 1:3, 3:5, 5:8, 8:10 ]
		}

		*/

	def NthStep(n)
		if CheckParams()
			if isString(n)
				if Q(n) = :First
					n = 1
	
				but Q(:Last)
					n = This.NumberOfSteps()
				ok
			ok
	
			if NOT ( isNumber(n) and n <= This.NumberOfSteps() )
				StzRaise("Incorrect param!")
			ok
		ok

		return This.Steps()[n]

	  #-----------#
	 #   MISC.   #
	#-----------#

	def ToStzList()
		return new stzList( This.WalkedPositions() )
