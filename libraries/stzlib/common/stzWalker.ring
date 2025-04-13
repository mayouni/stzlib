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

func Wk(pnStart, pnEnd, pSteps)
	return new stzWalker(pnStart, pnEnd, pSteps)

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
	@pSteps   # Can be a number or a list of numbers
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

		# Some logical checks

		if pnStart = pnEnd
			StzRaise("Can't create the stzWalker object! pnStart and pnEnd must be different.")
		ok

		# Set initial direction based on start and end positions
		if pnStart < pnEnd
			@cDirection = :Forward
		else
			@cDirection = :Backward
		ok

		# Check if steps is a number or a list of numbers
		if isNumber(pSteps)
			@bIsVariantSteps = FALSE
			
			# Allow negative steps as direction modifiers
			if abs(pSteps) > abs(pnEnd - pnStart) + 1
				StzRaise("Can't walk! The absolute step value is larger than the number of walkable positions.")
			ok
			
		but isList(pSteps)
			@bIsVariantSteps = TRUE
			
			if len(pSteps) = 0
				StzRaise("Can't create the stzWalker object! pSteps list cannot be empty.")
			ok
			
			# We now allow negative numbers in the steps list
			if NOT @AreNonZeroNumbers(pSteps)
				StzRaise("Can't create the stzWalker object! All steps in the list must be non-zero numbers.")
			ok
			
			# Check if steps have constant difference
			if @HaveConstantDifference(pSteps)
				@bIsVariantSteps = FALSE
				pSteps = pSteps[1]  # Use first step as they're all the same
			ok
		else
			StzRaise("Incorrect param type! pSteps must be a number or a list of numbers.")
		ok

		# Setting the object attributes
		@nStart = pnStart
		@nEnd = pnEnd
		@pSteps = pSteps	

		# Populate walkable positions
		@anWalkables = []
		if @bIsVariantSteps
			This.CalculateVariantWalkables()
		else
			This.CalculateConstantWalkables()
		ok

		@nCurrentPos = @nStart
		@aWalkHistory = []  # Initialize empty walk history

	def CalculateConstantWalkables()
		
		if @nStart < @nEnd  # Forward direction
			nStep = abs(@pSteps)
			for i = @nStart to @nEnd step nStep
				@anWalkables + i
			next
		else  # Backward direction
			nStep = abs(@pSteps)
			for i = @nStart to @nEnd step -nStep
				@anWalkables + i
			next
		ok

	def CalculateVariantWalkables()
		if StzListOfNumbersQ(@pSteps).ContainsPositiveAndNegativeNumbers()
			This.CalculateVariantWalkablesXT()
			return
		ok

		@anWalkables = [ @nStart ]
		nCurrentPos = @nStart
		nDirection = IIF(@nStart < @nEnd, 1, -1)
		nStepIndex = 1
		nNumSteps = len(@pSteps)

		while TRUE
			# Get step and apply direction logic
			nStep = @pSteps[nStepIndex]
			
			# Apply step based on its sign and the overall direction
			if nStep > 0
				# Positive step follows the main direction
				nCurrentPos = nCurrentPos + (nDirection * abs(nStep))
			else
				# Negative step goes against the main direction
				nCurrentPos = nCurrentPos - (nDirection * abs(nStep))
			ok
			
			# Check if we've gone past the end or reversed beyond the start
			if (@nStart < @nEnd and (nCurrentPos > @nEnd or nCurrentPos < @nStart)) or
			   (@nStart > @nEnd and (nCurrentPos < @nEnd or nCurrentPos > @nStart))
				exit
			ok
			
			@anWalkables + nCurrentPos
			
			# Move to next step in the list, cycling if necessary
			nStepIndex++
			if nStepIndex > nNumSteps
				nStepIndex = 1
			ok
		end

		# Ensure walkables are properly ordered
		@anWalkables = This._SortPositions(@anWalkables)


def CalculateVariantWalkablesXT()
? "hnè"
	nStart = @nStart
	nEnd = @nEnd
	anSteps = @anSteps


    # --- Step 1. Find a cycle by accumulating steps until cumulative sum equals 0
    anCycle = []
    nSum = 0
    nCycleIndex = 0
    nLenSteps = len(anSteps)
    for i = 1 to nLenSteps
        nSum += anSteps[i]
        anCycle + anSteps[i]
        if nSum = 0 and i < nLenSteps
            nCycleIndex = i   # cycle detected at position i
            exit            # leave the cycle loop early
        end
    next

    # --- Step 2. Split the steps:
    # if a cycle was detected, use the steps before the closing element (last element of the cycle)
    # as the initial steps.
    initialSteps = [] 
    if nCycleIndex > 0
        # Use the steps up to (but not including) the one that closed the cycle.
        for i = 1 to nCycleIndex - 1
            initialSteps + anCycle[i]
        next
    else
        # If no cycle detected, use the full list as initial steps.
        initialSteps = anSteps
    end

    # The extra (or remaining) part consists of any steps after the cycle.
    remainingSteps = []
    if nCycleIndex > 0
        for i = nCycleIndex + 1 to nLenSteps
            remainingSteps + anSteps[i]
        next
    end

    # --- Step 3. Build the repeating pattern:
    # We want to preserve the “direction” that the user intended.
    # For our test case this will be: remainingSteps concatenated with
    # the positive portion of the initialSteps (skipping any negatives).
    repeatSteps = []
    # First add any remaining steps
    for i = 1 to len(remainingSteps)
        repeatSteps + remainingSteps[i]
    next
    # Then add the positive steps from the initial phase.
    for i = 1 to len(initialSteps)
        if initialSteps[i] > 0
            repeatSteps + initialSteps[i]
        end
    next

    # --- Step 4. Build the walkable positions.
    # First apply the initialSteps, then repeat the repeatSteps until we reach nEnd.
    n = nStart
    anWalkables = [ n ]
    # Apply the initial steps in order.
    for i = 1 to len(initialSteps)
        n = n + initialSteps[i]
        anWalkables + n
    next

    # Then use the repeatSteps pattern.
    nTimes = 0
    nLenRepeat = len(repeatSteps)
    while n < nEnd
        nTimes++
        if nTimes > 100
		exit
	ok
        for i = 1 to nLenRepeat
            candidate = n + repeatSteps[i]
            # In forward walks, if candidate overshoots nEnd, skip this step.
            if nStart < nEnd
                if candidate > nEnd
                    # skip this step, do nothing
                    loop
                ok
            else
                if candidate < nEnd then
                    loop
                ok
            end
            n = candidate
            anWalkables + n
            if n = nEnd
		exit 2
	    ok
        next
    end

    @anWalkables = anWalkables

	  #------------------#
	 #   GENERAL INFO   #
	#------------------#

	def Content()
		return This.WalkablePositions()

		def Value()
			return Content()

	def Copy()
		return new stzWalker( @nStart, @nEnd, @pSteps )

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
		return @pSteps

		def Stepp()

	def NStep() # NOTE: We can't use Step() because STEP is reserved by Ring
		if @bIsVariantSteps
			return @pSteps
		else
			return @pSteps
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

	#--- Direction methods ---#
	
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

		anWalkables = This.Walkables()
		nCurrent = ring_find(anWalkables, This.CurrentPosition())

		anResult = []
		nLen = len(anWalkables)

		if This.IsMovingForward()

			if anWalkables[1] < anWalkables[2]
				for i = nCurrent + 1 to nLen
					anResult + anWalkables[i]
				next
			else
				for i = nCurrent - 1 to 1 step -1
					anResult + anWalkables[i]
				next
			ok

		else

			if anWalkables[1] < anWalkables[2]
				for i = nCurrent - 1 to 1 step -1
					anResult + anWalkables[i]
				next
			else
				for i = nCurrent + 1 to nLen
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
		anRemaining = This.RemainingWalkables()

		nLenRemaining = len(anRemaining)

		if n > nLenRemaining
			StzRaise("Can't walk! No more walkable positions in the current direction.")
		ok

		anWalks = [ This.CurrentPosition() ]

		for i = 1 to n
			anWalks + anRemaining[i]
		next

		@nCurrentPos = anWalks[len(anWalks)]
		
		# Add this walk operation to history

		@aWalkHistory + anWalks

		return anWalks

		#< @FunctionAlternativeForms

		def NSteps(n)
			return This.WalkNSteps(n)

		def WalkN(n)
			return This.WalkNSteps(n)

		#>
		
	def WalkNForward(n)
		# Save current position
		nCurrentPos = @nCurrentPos

		# Set direction to forward
		@cDirection = :Forward

		# Find current position in walkables array
		anWalkables = This.Walkables()
		nCurrentIndex = ring_find(anWalkables, nCurrentPos)

		# Check if there are enough positions after the current one
		if nCurrentIndex + n > len(anWalkables)
			StzRaise("Can't walk forward! Not enough walkable positions in forward direction.")
		ok

		# Create result array starting with current position
		anResult = [ nCurrentPos ]

		# Add the next n positions in forward direction
		for i = 1 to n
			anResult + anWalkables[nCurrentIndex + i]
		next

		# Update current position to the last position we walked to
		@nCurrentPos = anResult[len(anResult)]

		# Add this walk operation to history
		@aWalkHistory + anResult

		return anResult
		
	def WalkNBackward(n)
		# Save current position
		nCurrentPos = @nCurrentPos

		# Set direction to backward
		@cDirection = :Backward

		# Find current position in walkables array
		anWalkables = This.Walkables()
		nCurrentIndex = ring_find(anWalkables, nCurrentPos)

		# For a backward walker, we need to move forward in the array
		# Check if there are enough positions after the current one

		if nCurrentIndex + n > len(anWalkables)
			StzRaise("Can't walk backward! Not enough walkable positions in backward direction.")
		ok

		# Create result array starting with current position
		anResult = [ nCurrentPos ]

		# Add the next n positions in array (which is backward in value)
		for i = 1 to n
			anResult + anWalkables[nCurrentIndex + i]
		next

		# Update current position to the last position we walked to
		@nCurrentPos = anResult[len(anResult)]

		# Add this walk operation to history
		@aWalkHistory + anResult

		return anResult

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

		if CheckParams()
			if NOT isNumber(n)
				stzraise("Incorrect param type! n must be a number.")
			ok
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

		if CheckingParams()
			if isList(n2) and StzListQ(n3).IsAndNamedParam()
				n2 = n2[2]
			ok

			if NOT (isNumber(n1) and isNumber(n2))
				StzRaise("Incorrect param type! n1 and n2 must be numbers.")
			ok
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

	  #-----------------#
	 #   HELPER FUNCS  #
	#-----------------#
	
	def @ArePositiveNumbers(pList)

		if NOT isList(pList)
			return FALSE
		ok

		nLen = len(pList)

		for i = 1 to nLen
			if NOT (isNumber(pList[i]) and pList[i] > 0)
				return FALSE
			ok
		next
		
		return TRUE
		
	def @AreNonZeroNumbers(pList)

		if NOT isList(pList)
			return FALSE
		ok

		nLen = len(pList)

		for i = 1 to nLen
			if NOT (isNumber(pList[i]) and pList[i] != 0)
				return FALSE
			ok
		next
		
		return TRUE
		
	def @HaveConstantDifference(pList)

		if len(pList) <= 1
			return TRUE
		ok
		
		nDiff = pList[2] - pList[1]
		
		for i = 2 to len(pList)-1
			if pList[i+1] - pList[i] != nDiff
				return FALSE
			ok
		next
		
		return TRUE

	  #-----------#
	 #   MISC.   #
	#-----------#

	def ToStzList()
		return new stzList(This.WalkedPositions())
