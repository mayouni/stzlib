#-------------------------------------------------------------------------#
# 		   SOFTANZA LIBRARY (V0.9) - STZWALKER		          #
# 	An accelerative library for Ring applications, and more!	  #
#-------------------------------------------------------------------------#
#									  #
# 	Description	: The class for creating walkers in Softanza      #
#	Version		: V1.0 (2020-2024)				  #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		  #
#									          #
#-------------------------------------------------------------------------#

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func Wk(pnStart, pnEnd, pSteps)
	if isList(pnStart) and isList(pnEnd)
		return new stzWalker2D(pnStart, pnEnd, pSteps)
	else
		return new stzWalker(pnStart, pnEnd, pSteps)
	ok

	func StzWalkerQ(pnStart, pnEnd, pSteps)
		return new stzWalker(pnStart, pnEnd, pSteps)

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
	@Steps   # Can be a number or a list of numbers
	@bIsVariantSteps = _FALSE_  # TRUE if steps vary, FALSE if constant step

	@anWalkables = []
	@nCurrentPos
	@aWalkHistory = []  # Stores the history of walks as separate lists
	
	# New attribute for direction
	@cDirection  # :Forward or :Backward

	  #-------------------------#
	 #   SETTING THE WALKER    #
	#-------------------------#

	def init(pnStart, pnEnd, pSteps)

	# There are the two ways to initiate a stzWalker object:

	# -> by providing a list of params values. Example:
	# 	new stzWalker([ 1, 10, 3 ])

	# -> by providing a hashlist of named params. Example:
	# 	new stzWalker([
	# 		:StartAt = 1,
	# 		:EndAt = 10,
	# 		:Step = 3
	# ])

		if CheckingParams()
	
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
	
			if isList(pSteps) and
			   StzListQ(pSteps).IsOneOfTheseNamedParams([
				:Jump, :Step, :NStep, :Steps
			  ])
	
				pSteps = pSteps[2]
			ok
		ok

		# Early checks of positions

		if pnStart = 0 or pnEnd = 0
			StzRaise("Incorrect param type! Start and end positions must not be zeros.")
		ok

		if pnStart = pnEnd
			StzRaise("Can't create the stzWalker object! pnStart and pnEnd must be different.")
		ok
	
		# Set initial direction based on start and end positions
	
		if pnStart < pnEnd
			@cDirection = :Forward
		else
			@cDirection = :Backward
		ok
	
		# Setting the object attributes
	
		@nStart = pnStart
		@nEnd = pnEnd
		@Steps = pSteps
	
		# Check if steps is a number or a list of numbers
	
		if isNumber(pSteps)
	
			if pSteps = 0
				StzRaise("Can't create the stzWalker object! The step number must not be equal to zero.")
			ok
		
			if pSteps < 0
				StzRaise("Can't create the stzWalker object! The step number must not be negative.")
			ok
		
			if @nStart < @nEnd and pSteps < 0
				StzRaise("Can't create the stzWalker object! The step number must not be negative when the walker is gooing forward.")
			ok
		
			if abs(pSteps) > abs(@nStart - @nEnd)
				StzRaise("Can't create the stzWalker object! The specified step number exceeds the allowed walking range.")
			ok
		
		        @bIsVariantSteps = FALSE
	        
	        	# No need for step sign validation here - we'll handle that
	        	# in the calculation methods by inverting steps for backward walkers
	        
		but isList(pSteps)
			if len(pSteps) = 2 and pSteps[1] + pSteps[2] = 0
				StzRaise("Can't create the stzWalker object! The two steps must not be opposite numbers.")
			ok
		
		        @bIsVariantSteps = TRUE
		        
		        if len(pSteps) = 0
		            StzRaise("Can't create the stzWalker object! pSteps list cannot be empty.")
		        ok
		        
		        # Check if all elements are non-zero numbers
		        if NOT @AreNonZeroNumbers(pSteps)
		            StzRaise("Can't create the stzWalker object! All steps in the list must be non-zero numbers.")
		        ok
		        
		        # Checking for constant difference
		        # If the list has mixed sign numbers or has only 2 elements with different signs, 
		        # we treat it as variant steps
	
			if HaveSameDifference(pSteps) and NOT StzListOfNumbersQ(@Steps).ContainsPositiveAndNegativeNumbers()
				@bIsVariantSteps = FALSE
				@Steps = pSteps[1]  # Use first step as they're all the same
			ok
		else
			StzRaise("Incorrect param type! pSteps must be a number or a list of numbers.")
		ok
	
		# Populate walkable positions
	
		@anWalkables = []
	
		if @bIsVariantSteps
	
			# Check if we have mixed positive/negative steps - use specialized calculation
	
			if StzListOfNumbersQ(@Steps).ContainsPositiveAndNegativeNumbers()
				This.CalculateVariantWalkablesXT()
			else
				This.CalculateVariantWalkables()
		        ok
	
		else
			This.CalculateConstantWalkables()
		ok
	
		@nCurrentPos = @nStart
		@aWalkHistory = []  # Initialize empty walk history

	def CalculateConstantWalkables()

		@anWalkables = [ @nStart ]

		# Get the natural direction and current position

		bForwardNaturalDirection = (@nStart < @nEnd)
		nCurrentPos = @nStart

		# Determine how to apply the step based on direction

		nStep = @Steps

		# For backward direction, ensure step has the right sign

		if !bForwardNaturalDirection and nStep > 0
			nStep = -nStep

		but bForwardNaturalDirection and nStep < 0
			nStep = -nStep  # Ensure step is positive for forward direction
		ok

		# Add safety counter to prevent infinite loops

		nMaxIterations = abs(@nEnd - @nStart) * 2
		nIteration = 0

		# Calculate next position

		nNextPos = nCurrentPos + nStep

		# Continue adding positions while within bounds

		while ((bForwardNaturalDirection and nNextPos <= @nEnd) or 
			(!bForwardNaturalDirection and nNextPos >= @nEnd)) and
			nIteration < nMaxIterations

			nIteration++
			@anWalkables + nNextPos
			nCurrentPos = nNextPos
			nNextPos = nCurrentPos + nStep

		end

		# Safety check

		if nIteration >= nMaxIterations
			StzRaise("Can't create the walker object! Maximum iterations reached when calculating constant walkables. Possible infinite loop detected.")
		ok

	def CalculateVariantWalkables()

		# Start with the initial position

		@anWalkables = [ @nStart ]
		nCurrentPos = @nStart

		# Determine natural direction of the walk

		bForwardNaturalDirection = (@nStart < @nEnd)

		# Apply sign correction to steps for backward direction

		anSteps = []

		if bForwardNaturalDirection
			anSteps = @Steps

		else
			# For backward direction, negate positive steps

			nLen = len(@Steps)

			for i = 1 to nLen
				if @Steps[i] > 0
					anSteps + -@Steps[i]
				else
					anSteps + @Steps[i]
				ok
			next
		ok
    
		# Steps index management

		nStepIndex = 1
   		nNumSteps = len(anSteps)

		# Path tracking for error reporting

		aPath = [ nCurrentPos ]
		aAppliedSteps = []

		# Maximum number of iterations to prevent infinite loops

		nMaxIterations = 1000
		nIteration = 0

		while nIteration < nMaxIterations

			nIteration++

			# Get current step and remember it for error reporting

			nStep = anSteps[nStepIndex]
			aAppliedSteps + nStep

			# Calculate next position

			nNextPos = nCurrentPos + nStep

			# Check if we've reached or passed the end boundary

			if (bForwardNaturalDirection and nNextPos > @nEnd) or
			   (!bForwardNaturalDirection and nNextPos < @nEnd)

				exit  # Stop calculation when we go beyond the endpoint
			ok

			# Add valid position to walkables and update tracking

			@anWalkables + nNextPos
			nCurrentPos = nNextPos
			aPath + nCurrentPos

			# Move to next step in the list, cycling if necessary

			nStepIndex++

			if nStepIndex > nNumSteps
				nStepIndex = 1
			ok

			# Check if we've reached the end position exactly

			if nCurrentPos = @nEnd
				exit
			ok
		end

		# Safety check

		if nIteration >= nMaxIterations
			StzRaise("Exceeded maximum iterations when calculating walkable positions. Possible infinite loop detected.")
		ok
		

	def CalculateVariantWalkablesXT()
	# Dedicated only to steps containing positive and negative numbers

		# Start with the initial position

		@anWalkables = [ @nStart ]
		nCurrentPos = @nStart

		# Start and end values for convenience

		nStart = @nStart
		nEnd = @nEnd
		anSteps = @Steps
    
		# Determine natural direction

		bForwardNaturalDirection = (nStart < nEnd)

		# Track path and steps for error reporting

		aPath = [ nCurrentPos ]
		aAppliedSteps = []

		# Process steps in sequence with boundary checking

		nStepIndex = 1
		nLenSteps = len(anSteps)
		nMaxIterations = 1000  # Safety limit
		nIteration = 0
    
		while nIteration < nMaxIterations

			nIteration++

			# Get next step - don't add to applied steps list yet
			nStep = anSteps[nStepIndex]

			# Calculate next position
			nNextPos = nCurrentPos + nStep

			# Now add the step to applied steps
			aAppliedSteps + nStep
        
			# Check boundary constraints

			if (bForwardNaturalDirection and nNextPos < nStart) or
			   (!bForwardNaturalDirection and nNextPos > nStart)

				# Boundary violation - raise error with detailed path information

				cErrorPath = @@(aPath)
				cStepsPath = @@(aAppliedSteps)

				StzRaise("Can't initiate the walker! Trying to walk to position " + nNextPos + 
					 " in the path " + cErrorPath + " after applying these steps " + cStepsPath)
			ok

			# If we hit the ending boundary but didn't violate it

			if (bForwardNaturalDirection and nNextPos > nEnd) or
			   (!bForwardNaturalDirection and nNextPos < nEnd)

				exit  # Stop calculation when we go beyond the endpoint
			ok

			# Add valid position to walkables and update tracking

			@anWalkables + nNextPos
			nCurrentPos = nNextPos
			aPath + nCurrentPos

			# Check if we've reached the end position

			if nCurrentPos = nEnd
				exit
			ok

			# Move to next step

			nStepIndex++

			if nStepIndex > nLenSteps
				nStepIndex = 1
			ok
		end

		# Safety check

		if nIteration >= nMaxIterations
			StzRaise("Exceeded maximum iterations when calculating walkable positions for mixed steps.")
		ok

	  #------------------#
	 #   GENERAL INFO   #
	#------------------#

	def Content()
		return This.WalkablePositions()

		def Value()
			return Content()

	def Copy()
		return new stzWalker( @nStart, @nEnd, @Steps )

	def StartPosition()
		return @nStart

		def StartingPosition()
			return @nStart

		def Start()
			return @nStart

	def EndPosition()
		return @nEnd

		def EndingPosition()
			return @nEnd

		def Endd()
			return @nEnd

	def Steps()
		return @Steps

		def Stepp()

	def NStep() # NOTE: We can't use Step() because STEP is reserved by Ring
		if @bIsVariantSteps
			return @Steps
		else
			return @Steps
		ok

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

	def IsVariantSteps()
		return @bIsVariantSteps

		def HasVariantSteps()
			return This.IsVariantSteps()

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

	  #---------------------#
	 #  Direction methods  #
	#---------------------#

	def Direction()
		return @cDirection
		
		def CurrentDirection()
			return This.Direction()

	def SetDirection(cDirection)
		if cDirection != :Forward and cDirection != :Backward
			StzRaise("Invalid direction! Must be :Forward or :Backward.")
		ok
		
		@cDirection = cDirection
		return This
		
	def ReverseDirection()
		if @cDirection = :Forward
			@cDirection = :Backward
		else
			@cDirection = :Forward
		ok
		
		return This
		
	def IsMovingForward()
		return (@cDirection = :Forward)
		
	def IsMovingBackward()
		return (@cDirection = :Backward)

	  #-----------------------------------------------------#
	 #  POSITIONS, WALKED POSITIONS & UNWALKED POSITIONS   #
	#-----------------------------------------------------#

	def Positions()

		anResult = []

		if @nStart < @nEnd
			anResult = @nStart : @nEnd
		else
			anResult = @nStart : @nEnd : -1
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

		# If we have mixed positive/negative steps, use specialized implementation

		if @bIsVariantSteps and StzListOfNumbersQ(@Steps).ContainsPositiveAndNegativeNumbers()
			return This.RemainingWalkablesMixed()
		ok

		# Original implementation

		anWalkables = This.Walkables()
		nCurrent = ring_find(anWalkables, This.CurrentPosition())

		if nCurrent = 0
			return []
		ok

		anResult = []
		nLen = len(anWalkables)

		if This.IsMovingForward()

			if anWalkables[1] < anWalkables[nLen]  # Ascending order
				for i = nCurrent + 1 to nLen
					anResult + anWalkables[i]
				next

			else  # Descending order
				for i = nCurrent - 1 to 1 step -1
					anResult + anWalkables[i]
				next
			ok

		else  # Moving backward

			if anWalkables[1] < anWalkables[nLen]  # Ascending order

				for i = nCurrent - 1 to 1 step -1
					anResult + anWalkables[i]
				next

			else  # Descending order

				for i = nCurrent + 1 to nLen
					anResult + anWalkables[i]
				next
			ok
		ok

		return anResult

	def RemainingWalkablesMixed()

		anWalkables = This.Walkables()
		nCurrentPos = This.CurrentPosition()
		nCurrentIndex = ring_find(anWalkables, nCurrentPos)

		if nCurrentIndex = 0
			return []
		ok

		anResult = []
		nLen = len(anWalkables)

		# With mixed steps, we follow the walkables array order

		for i = nCurrentIndex + 1 to nLen
			anResult + anWalkables[i]
		next

		return anResult


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

	def Reset()
		This.SetCurrentPosition(@anWalkables[1])

		def Restart()
			This.Reset()

	def Walk()
		return This.WalkNSteps(1)

	def WalkForward()

		cPrevDirection = @cDirection
		@cDirection = :Forward
		anResult = This.WalkNSteps(1)

		return anResult

	def WalkBackward()

		# Save current position
		nCurrentPos = @nCurrentPos

		# Set direction to backward
		@cDirection = :Backward

		# Find current position in walkables array
		anWalkables = This.Walkables()
		nCurrentIndex = ring_find(anWalkables, nCurrentPos)

		# Check if there's a position before the current one
		if nCurrentIndex <= 1
			StzRaise("Can't walk backward! Already at the beginning of walkable positions.")
		ok

		# The previous position is the one before current in the walkables array
		nPreviousPos = anWalkables[nCurrentIndex - 1]

		# Create result array with current and previous positions
		anResult = [ nCurrentPos, nPreviousPos ]

		# Update current position
		@nCurrentPos = nPreviousPos

		# Add this walk operation to history
		@aWalkHistory + anResult

		return anResult

	def WalkNSteps(n)

		# For mixed steps (positive and negative), use a different implementation

		if @bIsVariantSteps and StzListOfNumbersQ(@Steps).ContainsPositiveAndNegativeNumbers()
			return This.WalkNStepsMixed(n)
		ok

		# Get remaining walkable positions in the current direction

		_anRemaining_ = This.RemainingWalkables()
		_nLenRemaining_ = len(_anRemaining_)

		# Start with the current position

		_anWalks_ = [ @nCurrentPos ]

		# Handle edge cases

		if n <= 0
			StzRaise("Can't walk! Number of steps must be positive.")
		ok

		if n > _nLenRemaining_
			# Instead of raising an error, we walk to the last possible position
			n = _nLenRemaining_
		ok
    
		# Perform the walk

		for i = 1 to n
			_anWalks_ + _anRemaining_[i]
		next

		# Update current position and history

		if len(_anWalks_) > 1
			@nCurrentPos = _anWalks_[len(_anWalks_)]
			@aWalkHistory + _anWalks_
		ok

		return _anWalks_

	def WalkN(n)
		return This.WalkNSteps(n)

	def WalkNStepsMixed(n)

		anWalkables = This.Walkables()
		nCurrentPos = This.CurrentPosition()
		nCurrentIndex = ring_find(anWalkables, nCurrentPos)

		if nCurrentIndex = 0
			StzRaise("Current position not found in walkable positions!")
		ok

		anWalks = [ nCurrentPos ]
		nRemaining = len(anWalkables) - nCurrentIndex

		# Check if we have enough remaining walkable positions

		if n > nRemaining
			# Instead of raising an error, just walk as far as possible
			n = nRemaining
		ok

		# Perform the walk

		for i = 1 to n
			anWalks + anWalkables[nCurrentIndex + i]
		next

		# Update state

		if len(anWalks) > 1
			@nCurrentPos = anWalks[len(anWalks)]
			@aWalkHistory + anWalks
		ok

		return anWalks

	def WalkNForward(n)

		# Save current direction and position

		cPrevDirection = @cDirection
		nCurrentPos = @nCurrentPos

		# Set direction to forward

		@cDirection = :Forward

		# Find current position in walkables array

		anWalkables = This.Walkables()
		nCurrentIndex = ring_find(anWalkables, nCurrentPos)

		if nCurrentIndex = 0
			StzRaise("Current position not found in walkable positions!")
		ok

		# Get remaining walkables based on natural direction of the walkables

		anResult = [ nCurrentPos ]

		# Check if the walkables are in ascending or descending order

		bAscending = (len(anWalkables) >= 2 and anWalkables[1] < anWalkables[2])

		# In a forward walk:
		# - If walkables are ascending, we move forward in the array (higher indices)
		# - If walkables are descending, we move backward in the array (lower indices)

		if bAscending

			# Move forward in array (to higher indices)
			nAvailable = len(anWalkables) - nCurrentIndex

			if n > nAvailable
				n = nAvailable  # Walk as far as possible
			ok

			for i = 1 to n
				anResult + anWalkables[nCurrentIndex + i]
			next

		else
			# Move backward in array (to lower indices)
			nAvailable = nCurrentIndex - 1

			if n > nAvailable
				n = nAvailable  # Walk as far as possible
			ok

			for i = 1 to n
				anResult + anWalkables[nCurrentIndex - i]
			next
		ok

		# Update current position

		if len(anResult) > 1
			@nCurrentPos = anResult[len(anResult)]
		ok

		# Add this walk operation to history

		@aWalkHistory + anResult

		return anResult
    
	def WalkNStepsForward(n)
		return This.WalkNForward(n)

	def WalkNBackward(n)

		# Save current direction and position

		cPrevDirection = @cDirection
		nCurrentPos = @nCurrentPos

		# Set direction to backward

		@cDirection = :Backward

		# Find current position in walkables array

		anWalkables = This.Walkables()
		nCurrentIndex = ring_find(anWalkables, nCurrentPos)

		if nCurrentIndex = 0
			StzRaise("Current position not found in walkable positions!")
		ok

		# Get remaining walkables based on natural direction of the walkables

		anResult = [ nCurrentPos ]

		# Check if the walkables are in ascending or descending order

		bAscending = (len(anWalkables) >= 2 and anWalkables[1] < anWalkables[2])

		# In a backward walk:
		# - If walkables are ascending, we move backward in the array (lower indices)
		# - If walkables are descending, we move forward in the array (higher indices)

		if bAscending

			# Move backward in array (to lower indices)

			nAvailable = nCurrentIndex - 1

			if n > nAvailable
				n = nAvailable  # Walk as far as possible
			ok

			for i = 1 to n
				anResult + anWalkables[nCurrentIndex - i]
			next

		else
			# Move forward in array (to higher indices)

			nAvailable = len(anWalkables) - nCurrentIndex

			if n > nAvailable
				n = nAvailable  # Walk as far as possible
			ok

			for i = 1 to n
				anResult + anWalkables[nCurrentIndex + i]
			next
		ok

		# Update current position

		if len(anResult) > 1
			@nCurrentPos = anResult[len(anResult)]
		ok

		# Add this walk operation to history

		@aWalkHistory + anResult

		return anResult


	def WalkNStepsBackward(n)
		return This.WalkNBackward(n)

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

	def CanWalk()
		return len(This.RemainingWalkables()) > 0

		def HasNext()
			return This.CanWalk()

		def HasNextStep()
			return This.CanWalk()

	  #-----------------------------#
	 #  WALKING TO GIVEN POSITION  #
	#-----------------------------#

	def WalkTo(n)

		if NOT isNumber(n)
			stzraise("Incorrect param type! n must be a number.")
		ok

		if NOT ring_find(This.Walkables(), n)
			stzraise("Can't walk! The position provided is not walkable.")
		ok

		return This.WalkBetween(This.CurrentPosition(), n)

		def WalkToPosition(n)
			return This.WalkTo(n)

	def WalkToFirst()
		return This.WalkTo(This.FirstWalkablePosition())

		def WalkToFirstPosition()
			return This.WalkTofirst()

		def WalkToFirstWalkable()
			return This.WalkTofirst()

		def WalkToFirstWalkablePosition()
			return This.WalkToFirst()

	def WalkToLast()
		return This.WalkTo(This.LastWalkablePosition())

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
		return This.WalkBetween(n, This.CurrentPosition())

		def WalkFromPosition(n)
			return This.WalkFrom(n)

	def WalkFromFirst()
		anResult = This.WalkFrom(This.FirstWalkable())
		return anResult

		def WalkFromFirstPosition()
			return This.WalkFromFirst()

		def WalkFromStart()
			return This.WalkFromFirst()

	def WalkFromLast()
		anResult = This.WalkFrom(This.LastWalkable())
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

		if ring_find(This.Walkables(), n) > 0
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

		if ring_find(This.Unwalkables(), n) > 0
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

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect param type! n1 and n2 must be numbers.")
		ok

		if NOT This.AreWalkables([n1, n2])

			_cTemp_ = "position"

			if n2 - n1 > 1
				_cTemp_ += "s"
			ok

			StzRaise("Can't walk! The " + _cTemp_ + " provided is not walkable.")
		ok

		anResult = []
		anWalkables = This.Walkables()
		nPos1 = ring_find(anWalkables, n1)
		nPos2 = ring_find(anWalkables, n2)

		# Update direction based on the walk direction

		if nPos1 < nPos2

			@cDirection = :Forward

			for i = nPos1 to nPos2
				anResult + anWalkables[i]
			next

		else
			@cDirection = :Backward

			for i = nPos1 to nPos2 step -1
				anResult + anWalkables[i]
			next
		ok

		@nCurrentPos = anResult[len(anResult)]

		# Add this walk operation to history

		@aWalkHistory + anResult

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
		return @aWalkHistory

		def WalkingHistory()
			return This.Walks()

		def WalkHistory()
			return This.Walks()

		def History()
			return This.Walks()

	def WalkedPositions()
		aResult = []
		
		# Flatten the walk history to get all positions walked

		nLen = len(@aWalkHistory)

		for i = 1 to nLen
			nLen2 = len(@aWalkHistory[i])

			for j = 1 to nLen2
				if ring_find(aResult, @aWalkHistory[i][j]) = 0
					aResult + @aWalkHistory[i][j]
				ok
			next
		next
		
		# Sort the positions

		aResult = This._SortPositions(aResult)
		
		return aResult

	def _SortPositions(aPos)

		# Sort the positions based on their order in walkables

		aWalkables = This.Walkables()
		nLen = len(aWalkables)

		aSorted = []

		for i = 1 to nLen
			if ring_find(aPos, aWalkables[i]) > 0
				aSorted + aWalkables[i]
			ok
		next
		
		return aSorted

	def NumberOfWalks()
		return len(This.Walks())

		def HowManyWalks()
			return This.NumberOfWalks()

		def CountWalks()
			return This.NumberOfWalks()

		def SizeOfWalkingHistory()
			return This.NumberOfWalks()

		def SizeOfWalkHistory()
			return This.NumberOfWalks()

		def NumberOfWalkedPositions()
			return len(This.WalkedPositions())

		def CountWalkedPositions()
			return This.NumberOfWalkedPositions()

	def NthWalk(n)

		if n > len(@aWalkHistory) or n < 1
			StzRaise("Invalid walk index! n must be between 1 and " + len(@aWalkHistory))
		ok
		
		return @aWalkHistory[n]

		def NthWalkedPosition(n)
			return This.WalkedPositions()[n]

	def FirstWalk()

		if len(@aWalkHistory) = 0
			return []
		ok
		
		return This.NthWalk(1)

	def LastWalk()
		if len(@aWalkHistory) = 0
			return []
		ok
		
		return This.NthWalk(len(@aWalkHistory))

	  #---------------------#
	 #  CHECKING BOUNDARY  #
	#---------------------#

	def CheckBoundary(n)
	# Checks if a position respects the walker boundaries

		# Determine boundary violation based on natural direction

		bForwardNaturalDirection = (@nStart < @nEnd)

		if bForwardNaturalDirection

			# In a forward walk (start < end)

			if n < @nStart
				return [ _FALSE_, "Position " + n + " goes before the start boundary (" + @nStart + ")" ]

			but n > @nEnd
				return [ _TRUE_, "Position " + n + " goes beyond the end boundary (" + @nEnd + "), ignoring" ]

			else
				return [ _TRUE_, "" ]  # Valid position
			ok

		else
			# In a backward walk (start > end)

			if n > @nStart
				return [ _FALSE_, "Position " + n + " goes before the start boundary (" + @nStart + ")" ]

			but n < @nEnd
				return [ _TRUE_, "Position " + n + " goes beyond the end boundary (" + @nEnd + "), ignoring" ]
			else
				return [ _TRUE_, "" ]  # Valid position
			ok

		ok

	# Simplified and unified utility method for detecting
	# boundary violations during calculations

	def IsValidNextStep(nCurrentPos, nStep)

		nNextPos = nCurrentPos + nStep
		aCheck = This.CheckBoundary(nNextPos)

		if aCheck[1] = _FALSE_
			# Don't silently skip - raise the error
			StzRaise(aCheck[2])
		ok

		# Check if we've gone beyond the end (but not violated)

		if ((@nStart < @nEnd and nNextPos > @nEnd) or 
		   (@nStart > @nEnd and nNextPos < @nEnd))

			# This is a valid but end-exceeding position

			return [ _TRUE_, nNextPos, _TRUE_ ]
			# Third element indicates "beyond end"
		ok

		# Valid position within boundaries

		return [ _TRUE_, nNextPos, _FALSE_ ]
		# Third element indicates "within boundaries"

	  #-----------#
	 #   MISC.   #
	#-----------#

	def ToStzList()
		return new stzList(This.WalkedPositions())
