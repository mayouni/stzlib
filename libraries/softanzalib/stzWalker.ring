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

	@nStartPosition = 1
	@nEndPosition = @nStartPosition + 1
	@nStep = 1
	@cDirection = :Forward

	@nCurrentPosition

	  #-------------------------#
	 #   SETTING THE WALKER    #
	#-------------------------#

	def init(paWalkerOptions)
		# There are the two ways to initiate a stzWalker object:

		# -> by providing a list of params values. Example:
		# 	new stzWalker([ :mywalker, 1, 10, 3, :Backward ])

		# -> by providing a hashlist of named params. Example:
		# 	new stzWalker([
		# 		:Name = :myMalker,
		# 		:StartAt = 1,
		# 		:EndAt = 10,
		# 		:Step = 3,
		# 		:Direction = :Backward
		# ])

		if CheckParams()
			if NOT isList(paWalkerOptions) 
				StzRaise("Can't create the stzWalker object! paWalkerOptions must be a list.")
			ok
	
			if len(paWalkerOptions) = 0
				StzRaise("Can't create the stzWalker object! paWalkerOptions can't be an empty list.")
			ok

		ok

		nLenPositions = This.NumberOfPositions()

		nLenOptions = len(paWalkerOptions)
		if nLenOptions > 4
			StzRaise("Can't create the stzWalker object! paWalkerOptions list can't contain more then 4 items.")
		ok

		# Defalult values

		oOptList = new stzList(paWalkerOptions)

		if @IsHashList(pawalkerOptions) # First way of creating a stzWlker

			# Getting the starting at value

			temp = paWalkerOptions[ :StartingAt ]
			if isString(temp) and temp = ""
				temp = paWalkerOptions[ :StartAt ]

				if isString(temp) and temp = ""
					temp = paWalkerOptions[ :StartsAt ]

					if isString(temp) and temp = ""
						temp = paWalkerOptions[ :Start ]
					ok
				ok
			ok
			if isNumber(temp)
				@nStartPosition = temp
			ok

			# Getting the ending at value

			temp = paWalkerOptions[ :EndingAt ]

			if isString(temp) and temp = ""

				temp = paWalkerOptions[ :EndAt ]

				if isString(temp) and temp = ""

					temp = paWalkerOptions[ :EndsAt ]

					if isString(temp) and temp = ""

						temp = paWalkerOptions[ :End ]
					ok
				ok
			ok

			if isNumber(temp)
				@nEndPosition= temp
			ok

			# Getting the step value
			#TODO // Abstruct this feature in a function that looks for
			# a potential list of keys in a list

			temp = paWalkerOptions[ :Step ]
			if isString(temp) and temp = ""
				temp = paWalkerOptions[ :Steps ]

				if isString(temp) and temp = ""
					temp = paWalkerOptions[ :NStep ]

					if isString(temp) and temp = ""
						temp = paWalkerOptions[ :NSteps ]

						if isString(temp) and temp = ""
							temp = paWalkerOptions[ :Jump ]

							if isString(temp) and temp = ""
								temp = paWalkerOptions[ :NJump ]

								if isString(temp) and temp = ""
									temp = paWalkerOptions[ :Jumps ]

									if isString(temp) and temp = ""
										temp = paWalkerOptions[ :NJumps ]
									ok
								ok
							ok
						ok
					ok
				ok

			ok
			if isNumber(temp)
				@nStep = temp
			ok

			# Getting the direction value

			temp = paWalkerOptions[ :Direction ]
			if isString(temp) and temp != ""
				@cDirection = temp
			ok

		else # a list that it is not a hashlist

			# Second way of initaing a stzWalker

			if len(paWalkerOptions) = 3 and
			   isNumber(paWalkerOptions[1]) and # start position
			   isNumber(paWalkerOptions[2]) and # end position
			   isNumber(paWalkerOptions[3])     # step

				@nStartPosition = paWalkerOptions[1]
				@nEndPosition = paWalkerOptions[2]
				@nStep = paWalkerOptions[3]		

			else
				StzRaise("Can't create the stzWalker object! paWalkerOptions must be a list of 3 items or a hashlist of 4 pairs or less.")
			ok

		ok

		# Some logical checks

		if @nStartPosition <= 0 or @nEndPosition <= 0
			StzRaise("Can't create the stzWalker object!  @nStartPosition and @nEndPosition must be positive numbers.")
		ok

		if @nStartPosition = @nEndPosition
			StzRaise("Can't create the stzWalker object! @nStartPosition and @nEndPosition must be different.")
		ok

		if @nStep > @nEndPosition - @nStartPosition + 1
			StzRaise("Can't walk! The step is larger then the number of walkable items.")
		ok

		# Deducing the direction by comparing starting and ending positions

		@cDirection = :Forward
		if @nEndPosition > @nStartPosition
			@cDirection = :Backward
		ok

		# Getting the (default) current position

		if @cDirection = :Forward
			if @nStartPosition < @nEndPosition
				@nCurrentPosition = @nStartPosition
			else
				@nCurrentPosition = @nEndPosition
			ok

		else // :Backward
			if @nStartPosition < @nEndPosition
				@nCurrentPosition = @nEndPosition
			else
				@nCurrentPosition = @nStartPosition
			ok
		ok

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
		return @nStartPosition

		def StartingPosition()
			return This.StartPosition()

	def EndPosition()
		return @nEndPosition

		def EndingPosition()
			return This.EndPosition()

	def NStep() #NOTE: We can't use Step() because STEP is reserved by Ring
		return @nStep

		#< @FunctionAlternativeForms

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

		#--

		def Jump()
			return This.NStep()

		def NJump()
			return This.Nstep()

		def NumberOfJumpsPerStep()
			return This.NStep()

		def NumberOfJumpsInStep()
			return This.NStep()

		def NumberOfJumpsInAStep()
			return This.NStep()

		def JumpSize()
			return This.NStep()

		def SizeOfJump()
			return This.NStep()
			
		#>

	def CurrentPosition()
		return @nCurrentPosition

		def Position()
			return @nCurrentPosition

	  #-----------------------------------------------------#
	 #  POSITIONS, WALKED POSITIONS & UNWALKED POSITIONS   #
	#-----------------------------------------------------#

	def Positions()
		n1 = This.StartPosition()
		n2 = This.EndPosition()
		nStep = This.NStep()

		anResut = []

		if n1 < n2
			anResult = n1 : n2
		else
			for i = n2 to n1 step nStep
				anResult + i
			next
		ok

		return anResult

		def PositionsQ()
			return new stzList(This.Positions())

	def NumberOfPositions()
		return len( This.Positions() )

		#< @FunctionAlternativeForms

		def HowManyPositions()
			return This.NumberOfPositions()

		def CountPositions()
			return This.NumberOfPositions()

		#>

	def WalkablePositions()
		n1 = This.StartPosition()
		n2 = This.EndPosition()
		nStep = This.NStep()

		anResult = []

		if n1 = n2

			anResult = [ n1 ]

		but n1 < n2

			nStep = Abs(nStep)

			for i = n1 to n2 step nStep
				anResult + i
			next

		else
			nStep = -Abs(nStep)

			for i = n2 to n1 step nStep
				anResult + i
			next

		ok

		return anResult

		def WalkablePositionsQ()
			return new stzList(This.WalkedPositions())

		def Walkables()
			return This.WalkablePositions()

			def WalkablesQ()
				return This.WalkablePositionsQ()

	def NumberOfWalkablePositions()
		return len( ThisWalkedPositions() )

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
		return @cDirection

		def Direction()
			return @cDirection

	def SetWalkingDirection(pcDirection)
		if CheckParams()
			if isList(pcDirection) and StzStringq(pcDirection).IsForwardOrBackwardNamedParam()
			ok
		ok

		if NOT ( isString(pcDirection) and
			 Q(pcDirection).IsToNamedParam() and
			 Q(pcDirection).IsOneOfThese([ :Forward, :Backward ]) )

			StzRaise("Incorrect param!")

		ok

		@cDirection = pcDirection

		def SetDirection(pcDirection)
			This.SetWalkingDirection(pcDirection)

	def TurnAround()
		if @cDirection = :Forward
			@cDirection = :Backward
		else
			@cDirection = :Forward
		ok

		def InverseWalkingDirection()
			This.TurnAround()

		def InverseDirection()
			This.TurnAround()

		def Turn()
			This.TurnAround()

	def TurnForward()
		if @cDirection != :Forward
			@cDirection = :Forward
		ok

	def TurnBackward()
		if @cDirection != :Backward
			@cDirection = :Backward
		ok

	  #--------------#
	 #   WALKING    #
	#--------------#

	def Walk()
		anWalkables = This.Walkables()
		cDirection  = This.Direction()

		if cDirection = :Forward
			anResult = anWalkables

		else // backaward
			anResult = ring_reverse(anWalkables)
		ok

		@nCurrentPosition = anResult[ len(anResult) ]

		return anResult

	def WalkNSteps(n)
		if This.ShouldWalkForward()
			return This.WalkNStepsForward(n)

		but This.ShouldWalkBackward()
			return This.WalksNStepsBackward(n)

		ok

	  #---------------------#
	 #   WALKING Forward   #
	#---------------------#

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
