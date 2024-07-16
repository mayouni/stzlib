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

	@cName = :Walker0
	@nStartPosition = 1
	@nEndPosition = @nStartPosition + 1
	@nStep = 1
	@cDirection = :Forward

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
				StzRaise("Incorrect param type! paWalkerOptions must be a list.")
			ok
	
			if len(paWalkerOptions) = 0
				StzRaise("Incorrect param value! paWalkerOptions can't be an empty list.")
			ok

		ok

		nLenPositions = This.NumberOfPositions()

		nLenOptions = len(paWalkerOptions)
		if nLenOptions > 5
			StzRaise("Incorrect number of params! paWalkerOptions list can't contain more then 5 items.")
		ok

		# Defalult values

		oOptList = new stzList(paWalkerOptions)

		if @IsHashList(pawalkerOptions) # First way of creating a stzWlker

			# Getting the walker name

			temp = paWalkerOptions[ :Name ]
			if isString(temp) and temp != ""
				@cName = temp
			ok

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
	
			temp = paWalkerOptions[ :Step ]
			if isString(temp) and temp = ""
				temp = paWalkerOptions[ :Steps ]

				if isString(temp) and temp = ""
					temp = paWalkerOptions[ :NStgep ]

					if isString(temp) and temp = ""
						temp = paWalkerOptions[ :NSteps ]
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

			if len(paWalkerOptions) = 5 and
			   isString(paWalkerOptions[1]) and # walker name
			   isNumber(paWalkerOptions[2]) and # start position
			   isNumber(paWalkerOptions[3]) and # end position
			   isNumber(paWalkerOptions[4]) and # step
			   isString(paWalkerOptions[5])     # direction

				@cName = paWalkerOptions[1]
				@nStartPosition = paWalkerOptions[2]
				@nEndPosition = paWalkerOptions[3]
				@nStep = paWalkerOptions[4]
				@cDirection = paWalkerOptions[5]		

			else
				StzRaise("Incorrect format! paWalkerOptions must be a list of 5 items or a hashlist of 5 or less pairs.")
			ok

		ok

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
		nStep = This.NStep()

		anResult = []

		if n1 = n2

			anResult = [ n1 ]

		but n1 < n2
			anResult = n1 : n2

		else
			for i = n1 to n2 step nStep
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

	def WalkedPositions()
		return This.Content()

	def NumberOfWalkedPositions()
		return len( This.WalkedPositions() )

		#< @FunctionAlternativeForms

		def HowManyWalkedPositions()
			return This.NumberOfWalkedPositions()

		def CountWalkedPositions()
			return This.NumberOfWalkedPositions()

		#>

	def UnwalkedPositions()
		anResult = This.PositionsQ().ManyRemoved( This.WalkedPositions() )
		return anResult

	def NumberOfUnwalkedPositions()
		return len( This.UnwalkedPositions() )

		#< @FunctionAlternativeForms

		def HowManyUnwalkedPositions()
			return This.NumberOfUnwalkedPositions()

		def CountUnwalkedPositions()
			return This.NumberOfUnwalkedPositions()

		#>

	def IsWalkedPosition(n)
		if ring_find( This.WalkedPositions(), n) > 0
			return TRUE

		else
			return FALSE
		ok

	def IsUnwalkedPosition(n)
		if ring_find( This.UnwalkedPositions(), n) > 0
			return TRUE

		else
			return FALSE
		ok

		def IsNotWalkedPosition(n)
			return This.IsUnwalkedPosition(n)

	  #-----------------------#
	 #   WALKING DIRECTION   #
	#-----------------------#

	def SetWalkingDirection(pcDirection)
		if CheckParams()
			if isList(pcDirection) and StzStringq(pcDirection).IsForwardOrBackwardNamedParam()

		ok

		if NOT ( isString(pcDirection) and
			 Q(pcDirection).IsToNamedParam() and
			 Q(pcDirection).IsOneOfThese([ :Forward, :Backward ]) )

			StzRaise("Incorrect param!")

		ok

		@cDirection = pcDirection

	def WalkingDirection()
		return @cDirection

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

		#>

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
