#-------------------------------------------------------------------------#
# 		   SOFTANZA LIBRARY (V0.9) - STZWALKER2D	          #
# 	An accelerative library for Ring applications, and more!	  #
#-------------------------------------------------------------------------#
#									  #
# 	Description	: The class for creating 2D walkers in Softanza   #
#	Version		: V0.09 (2023-2025)				  #
#	Author		: Based on stzWalker by Mansour Ayouni	          #
#								          #
#-------------------------------------------------------------------------#

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func Wk2D(pnStartX, pnStartY, pnEndX, pnEndY, pSteps)
	return new stzWalker2D(pnStartX, pnStartY, pnEndX, pnEndY, pSteps)

	func StzWalker2DQ(pnStartX, pnStartY, pnEndX, pnEndY, pSteps)
		return new stzWalker2D(pnStartX, pnStartY, pnEndX, pnEndY, pSteps)

func IsWalker2D(pObject)
	if isObject(pObject) and classname(pObject) = "stzwalker2d"
		return TRUE
	else
		return FALSE
	ok

	func @IsWalker2D(pObject)
		return IsWalker2D(pObject)

  /////////////////
 ///   CLASS   ///
/////////////////

class stzWalker2D

	@nStartX
	@nStartY
	@nEndX
	@nEndY
	@pSteps    # Can be a number or a list of [xStep, yStep] pairs
	@bIsVariantSteps = FALSE

	@aWalkables = []  # List of walkable positions as [x,y] pairs
	@aCurrPosition = [] # Current position as [x,y]
	@aWalkHistory = []  # Stores the history of walks
	
	@cDirection = :Right  # Initial direction (:Right, :Left, :Up, :Down, :UpRight, :UpLeft, :DownRight, :DownLeft)
	@bAllowDiagonal = TRUE  # Whether diagonal movement is allowed

	  #-------------------------#
	 #   SETTING THE WALKER    #
	#-------------------------#

	def init(panStart, panEnd, pSteps)

		# Checking the params types

		if NOT (isList(panStart) and isList(panEnd))
			StzRaise("Incorrect param type! panStart and panEnd must be lists.")
		ok

		if NOT (isList(pSteps) or isNumber(pSteps))
			StzRaise("Incorrect param type! pSteps must be a number or a list.")
		ok

		if CheckingParams()
	
			if isList(panStart) and
			   StzListQ(panStart).IsOneOfTheseNamedParams([
				:Start, :StartAt, :StartsAt, :StartingAt,
				:StartFrom, :StartsFrom, :StartingFrom,
				:From, :FromPosition
			])
	
				panStart = panStart[2]
			ok
	
			if isList(panEnd) and
			   StzListQ(panEnd).IsOneOfTheseNamedParams([
				:End, :EndAt, :EndsAt, :EndingAt,
				:Stop, :StopAt, :StopsAt, :StoppingAt,
				:To, :ToPosition
			   ])
	
	 			panEnd = panEnd[2]
			ok
	
			if isList(pSteps) and
			   StzListQ(pSteps).IsOneOfTheseNamedParams([
				:Jump, :Step, :NStep, :Steps
			  ])
	
				pSteps = pSteps[2]
			ok
		ok

		# Chcking the params values

		if NOT ( len(panStart) = 2 and isNumber(panStart[1]) and isNumber(panStart[2]) )
			StzRaise("Incorrect param value! panStart must be a pair of numbers.")
		ok

		if NOT ( len(panEnd) = 2 and isNumber(panEnd[1]) and isNumber(panEnd[2]) )
			StzRaise("Incorrect param value! panEnd must be a pair of numbers.")
		ok

		if isList(pSteps) and NOT @IsListOfPairsOfNumbers(pSteps)
			StzRaise("Incorrect param value! pSteps must be a list of pairs of numbers.")
		ok

		# Getting the coordinates values

		pnStartX = panStart[1]
		pnStartY = panStart[2]

		pnEndX = panEnd[1]
		pnEndY = panEnd[2]

		# Some logical checks

		if pnStartX = pnEndX and pnStartY = pnEndY
			StzRaise("Can't create the stzWalker2D object! Start and end positions must be different.")
		ok
	
		# Store parameters
		@nStartX = pnStartX
		@nStartY = pnStartY
		@nEndX = pnEndX
		@nEndY = pnEndY
		@pSteps = pSteps
		
		# Set initial direction based on start and end positions
		@cDirection = This.DetermineInitialDirection()
		
		# Check step parameter
		if isNumber(pSteps)
			if pSteps <= 0
				StzRaise("Can't create the stzWalker2D object! Step size must be positive.")
			ok
			
			@bIsVariantSteps = FALSE
			
		but isList(pSteps)
			if len(pSteps) = 0
				StzRaise("Can't create the stzWalker2D object! Steps list cannot be empty.")
			ok
			
			# Check if each element is a valid step specification
			for i = 1 to len(pSteps)
				if NOT (isNumber(pSteps[i]) or (isList(pSteps[i]) and len(pSteps[i]) = 2))
					StzRaise("Can't create the stzWalker2D object! Each step must be a number or a pair [xStep, yStep].")
				ok
				
				if isList(pSteps[i])
					if NOT (isNumber(pSteps[i][1]) and isNumber(pSteps[i][2]))
						StzRaise("Can't create the stzWalker2D object! Step components must be numbers.")
					ok
				ok
			next
			
			@bIsVariantSteps = TRUE
			
		else
			StzRaise("Incorrect param type! pSteps must be a number or a list.")
		ok
		
		# Calculate walkable positions
		This.CalculateWalkables()
		
		# Set initial position
		@aCurrPosition = [@nStartX, @nStartY]
		
		# Initialize empty walk history
		@aWalkHistory = []

	def DetermineInitialDirection()

		# Calculate differences in x and y

		nDeltaX = @nEndX - @nStartX
		nDeltaY = @nEndY - @nStartY

		# Determine predominant direction

		if abs(nDeltaX) > abs(nDeltaY)

			# Horizontal movement predominates

			if nDeltaX > 0
				return :Right
			else
				return :Left
			ok

		else
			# Vertical movement predominates (or equal deltas, defaulting to vertical)

			if nDeltaY > 0
				return :Down
				# Assuming y increases downward (common in grids)
			else
				return :Up
			ok
		ok

	def CalculateWalkables()
	
		# Reset walkables list
		@aWalkables = []

		# Add starting position
		@aWalkables + [@nStartX, @nStartY]

		# For constant step size
		if NOT @bIsVariantSteps
			This.CalculateConstantStepWalkables()
		else
			This.CalculateVariantStepWalkables()
		ok

	def CalculateConstantStepWalkables()

		bInverse = FALSE

? @@([ [ @nStartX, @nStartY ], [ @nEndX, @nEndY ] ])

		if @nStartX > @nEndX or ( @nStartX = @nEndX and @nEndX < @nEndY )
			bInverse = TRUE
	
			Swap(@nStartX, @nEndX)
			Swap(@nStartY, @nEndY)

		ok
? @@([ [ @nStartX, @nStartY ], [ @nEndX, @nEndY ] ])
stop()

		# Get step size
		nStep = @pSteps

		# Calculate the total differences
		nDeltaX = @nEndX - @nStartX
		nDeltaY = @nEndY - @nStartY

		# Determine the number of steps in each direction
		nStepsX = floor(abs(nDeltaX) / nStep)
		nStepsY = floor(abs(nDeltaY) / nStep)

		# Calculate step directions
		nStepDirX = nDeltaX >= 0 ? 1 : -1
		nStepDirY = nDeltaY >= 0 ? 1 : -1

		# Reset walkables (start position already added in CalculateWalkables)
		@aWalkables = [[@nStartX, @nStartY]]

		# Horizontal-first or vertical-first based on predominant movement
		nX = @nStartX
		nY = @nStartY

		if abs(nDeltaX) >= abs(nDeltaY)
			# Horizontal movement first
			for i = 1 to nStepsX
				nX += nStep * nStepDirX
				@aWalkables + [nX, nY]
			next
			# Then vertical movement
			for i = 1 to nStepsY
				nY += nStep * nStepDirY
				@aWalkables + [nX, nY]
			next
		else
			# Vertical movement first
			for i = 1 to nStepsY
				nY += nStep * nStepDirY
				@aWalkables + [nX, nY]
			next
			# Then horizontal movement
			for i = 1 to nStepsX
				nX += nStep * nStepDirX
				@aWalkables + [nX, nY]
			next
		ok

		# Ensure the end position is included
		if @aWalkables[len(@aWalkables)][1] != @nEndX or 
		   @aWalkables[len(@aWalkables)][2] != @nEndY
			@aWalkables + [@nEndX, @nEndY]
		ok

		if bInverse
			@aWalkables = reverse(@aWalkables)
		ok

	def CalculateVariantStepWalkables()

		# Starting position
		nX = @nStartX
		nY = @nStartY

		# We'll need this to cycle through the steps
		nStepsCount = len(@pSteps)
		nStepIndex = 1

		# Maximum iterations to prevent infinite loops
		nMaxIterations = 1000
		nIterations = 0

		# Reset walkables (start position already added in CalculateWalkables)
		@aWalkables = [[@nStartX, @nStartY]]

		# Calculate path until we reach the end position or max iterations
		while (nX != @nEndX or nY != @nEndY) and nIterations < nMaxIterations

			nIterations++

			# Get current step
			pCurrentStep = @pSteps[nStepIndex]

			# Process the step based on its type
			if isNumber(pCurrentStep)
				# Apply step in current direction, adjusted for reverse path
				nStepX = 0
				nStepY = 0
				nDeltaX = @nEndX - nX
				nDeltaY = @nEndY - nY
				nStepDirX = @IF(nDeltaX >= 0, 1, -1)
				nStepDirY = @IF(nDeltaY >= 0, 1, -1)

				if abs(nDeltaX) >= abs(nDeltaY)
					nStepX = pCurrentStep * nStepDirX
				else
					nStepY = pCurrentStep * nStepDirY
				ok
			but isList(pCurrentStep)
				# For reverse paths, adjust step direction based on end position
				nStepX = pCurrentStep[1]
				nStepY = pCurrentStep[2]
				nDeltaX = @nEndX - nX
				nDeltaY = @nEndY - nY
				if nDeltaX < 0 nStepX = -nStepX ok
				if nDeltaY < 0 nStepY = -nStepY ok
			ok

			# Apply step
			nX += nStepX
			nY += nStepY

			# Add to walkables
			@aWalkables + [nX, nY]

			# Move to next step
			nStepIndex++
			if nStepIndex > nStepsCount
				nStepIndex = 1
			ok

			# Check if we've reached or passed the end position
			if This.HasReachedOrPassedEnd(nX, nY)
				@aWalkables[len(@aWalkables)] = [@nEndX, @nEndY]  # Force end position
				exit
			ok
		end

		# Safety check
		if nIterations >= nMaxIterations
			StzRaise("Maximum iterations reached when calculating walkable positions. Possible infinite loop.")
		ok

	def HasReachedOrPassedEnd(nX, nY)

		# Check if we've reached end position

		if nX = @nEndX and nY = @nEndY
			return TRUE
		ok

		# Check if we've passed end position in both directions
		# This ensures we don't prematurely detect "passing" when moving diagonally

		nDeltaX = @nEndX - @nStartX
		nDeltaY = @nEndY - @nStartY

		bPassedX = (nDeltaX > 0 and nX > @nEndX) or (nDeltaX < 0 and nX < @nEndX)
		bPassedY = (nDeltaY > 0 and nY > @nEndY) or (nDeltaY < 0 and nY < @nEndY)

		# Return true if we've passed the endpoint in the primary direction of movement

		if abs(nDeltaX) > abs(nDeltaY)
			return bPassedX
		else
			return bPassedY
		ok

	  #------------------#
	 #   GENERAL INFO   #
	#------------------#

	def Content()
		return This.WalkablePositions()

		def Value()
			return Content()

	def Copy()
		return new stzWalker2D([@nStartX, @nStartY], [@nEndX, @nEndY], @pSteps)

	def StartPosition()
		return [@nStartX, @nStartY]

		def StartingPosition()
			return This.StartPosition()

		def Start()
			return This.StartPosition()

		def StartX()
			return @nStartX
	
		def StartY()
			return @nStartY

	def EndPosition()
		return [@nEndX, @nEndY]

		def EndingPosition()
			return This.EndPosition()

		def Endd()
			return This.EndPosition()
	
		def EndX()
			return @nEndX
	
		def EndY()
			return @nEndY

	def Steps()
		return @pSteps

	def NStep()
		if @bIsVariantSteps
			return @pSteps
		else
			return @pSteps
		ok

		def StepSize()
			return This.NStep()

	def IsVariantSteps()
		return @bIsVariantSteps

		def HasVariantSteps()
			return This.IsVariantSteps()

	def CurrentPosition()
		return @aCurrPosition

		def Position()
			return This.CurrentPosition()

		def Current()
			return This.CurrentPosition()
	
		def CurrentX()
			return @aCurrPosition[1]

		def CurrentY()
			return @aCurrPosition[2]

	def SetCurrentPosition(nX, nY)
		if NOT This.IsWalkable([nX, nY])
			StzRaise("Can't set the current position! [" + nX + "," + nY + "] is not a walkable position.")
		ok

		@aCurrPosition = [nX, nY]
		return This

		def SetCurrent(nX, nY)
			return This.SetCurrentPosition(nX, nY)

		def SetPosition(nX, nY)
			return This.SetCurrentPosition(nX, nY)

	  #---------------------#
	 #  Direction methods  #
	#---------------------#

	def Direction()
		return @cDirection
		
		def CurrentDirection()
			return This.Direction()

	def SetDirection(cDirection)
		# Validate direction
		aValidDirections = [:Right, :Left, :Up, :Down, :UpRight, :UpLeft, :DownRight, :DownLeft]
		
		if NOT ring_find(aValidDirections, cDirection)
			StzRaise("Invalid direction! Must be one of: :Right, :Left, :Up, :Down, :UpRight, :UpLeft, :DownRight, :DownLeft")
		ok
		
		# If diagonal movement is not allowed, validate
		if NOT @bAllowDiagonal and This.IsDiagonalDirection(cDirection)
			StzRaise("Can't set diagonal direction! Diagonal movement is disabled.")
		ok
		
		@cDirection = cDirection
		
	def IsDiagonalDirection(cDirection)
		return (cDirection = :UpRight or cDirection = :UpLeft or 
		        cDirection = :DownRight or cDirection = :DownLeft)
	
	def SetAllowDiagonal(bAllow)
		@bAllowDiagonal = bAllow
		
		# If we're disabling diagonal movement and current direction is diagonal,
		# switch to the closest cardinal direction
		if NOT bAllow and This.IsDiagonalDirection(@cDirection)
			@cDirection = This.GetClosestCardinalDirection(@cDirection)
		ok
		
	def GetClosestCardinalDirection(cDiagonalDirection)
		if cDiagonalDirection = :UpRight
			return :Right
		but cDiagonalDirection = :UpLeft
			return :Left
		but cDiagonalDirection = :DownRight
			return :Right
		but cDiagonalDirection = :DownLeft
			return :Left
		else
			return cDiagonalDirection  # Already cardinal
		ok
		
	def ReverseDirection()
		if @cDirection = :Right
			@cDirection = :Left
		but @cDirection = :Left
			@cDirection = :Right
		but @cDirection = :Up
			@cDirection = :Down
		but @cDirection = :Down
			@cDirection = :Up
		but @cDirection = :UpRight
			@cDirection = :DownLeft
		but @cDirection = :UpLeft
			@cDirection = :DownRight
		but @cDirection = :DownRight
			@cDirection = :UpLeft
		but @cDirection = :DownLeft
			@cDirection = :UpRight
		ok
		
	def RotateDirectionClockwise()
		if @cDirection = :Right
			@cDirection = :Down
		but @cDirection = :Down
			@cDirection = :Left
		but @cDirection = :Left
			@cDirection = :Up
		but @cDirection = :Up
			@cDirection = :Right
		but @cDirection = :UpRight
			@cDirection = :DownRight
		but @cDirection = :DownRight
			@cDirection = :DownLeft
		but @cDirection = :DownLeft
			@cDirection = :UpLeft
		but @cDirection = :UpLeft
			@cDirection = :UpRight
		ok
		
	def RotateDirectionCounterClockwise()
		if @cDirection = :Right
			@cDirection = :Up
		but @cDirection = :Up
			@cDirection = :Left
		but @cDirection = :Left
			@cDirection = :Down
		but @cDirection = :Down
			@cDirection = :Right
		but @cDirection = :UpRight
			@cDirection = :UpLeft
		but @cDirection = :UpLeft
			@cDirection = :DownLeft
		but @cDirection = :DownLeft
			@cDirection = :DownRight
		but @cDirection = :DownRight
			@cDirection = :UpRight
		ok

	  #-----------------------------------------------------#
	 #  POSITIONS, WALKED POSITIONS & UNWALKED POSITIONS   #
	#-----------------------------------------------------#

	def AllPositionsInBoundary()
		# Create a list of all positions within the boundary rectangle
		aResult = []
		
		nMinX = min([@nStartX, @nEndX])
		nMaxX = max([@nStartX, @nEndX])
		nMinY = min([@nStartY, @nEndY])
		nMaxY = max([@nStartY, @nEndY])

		for nX = nMinX to nMaxX
			for nY = nMinY to nMaxY
				aResult + [nX, nY]
			next
		next
		
		return aResult
		
		def Positions()
			return This.AllPositionsInBoundary()

	def NumberOfPositions()
		nWidth = abs(@nEndX - @nStartX) + 1
		nHeight = abs(@nEndY - @nStartY) + 1
		return nWidth * nHeight

		def HowManyPositions()
			return This.NumberOfPositions()

		def CountPositions()
			return This.NumberOfPositions()

	def WalkablePositions()
		return @aWalkables

		def Walkables()
			return This.WalkablePositions()

	def NumberOfWalkablePositions()
		return len(This.WalkablePositions())

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

	def UnwalkablePositions()
		aAllPositions = This.AllPositionsInBoundary()
		aWalkables = This.WalkablePositions()
		aResult = []

		nLen = len(aAllPositions)

		for i = 1 to nLen
			if NOT This._ListContains(aWalkables, aAllPositions[i])
				aResult + aAllPositions[i]
			ok
		next
		
		return aResult

		def Unwalkables()
			return This.UnwalkablePositions()

	def NumberOfUnwalkablePositions()
		return len(This.UnwalkablePositions())

		def HowManyUnwalkablePositions()
			return This.NumberOfUnwalkablePositions()

		def CountUnwalkablePositions()
			return This.NumberOfUnwalkablePositions()

		def HowManyUnwalkables()
			return This.NumberOfUnwalkablePositions()

		def CountUnwalkables()
			return This.NumberOfUnwalkablePositions()

	  #--------------#
	 #   WALKING    #
	#--------------#

	def RemainingWalkables()
		aWalkables = This.Walkables()
		aCurrent = This.CurrentPosition()
		nCurrentIndex = This._FindPositionIndex(aWalkables, aCurrent)
		
		if nCurrentIndex = 0
			return []
		ok
		
		aResult = []
		nLen = len(aWalkables)

		for i = nCurrentIndex + 1 to nLen
			aResult + aWalkables[i]
		next
		
		return aResult

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

	def WalkInDirection(cDirection)
		# Save current direction
		cSavedDirection = @cDirection
		
		# Set new direction
		This.SetDirection(cDirection)
		
		# Walk one step
		aResult = This.WalkNSteps(1)
		
		# Restore direction if needed
		@cDirection = cSavedDirection
		
		return aResult
		
		def WalkTowards(cDirection)
			return This.WalkInDirection(cDirection)

	def WalkNSteps(n)

		if isList(n) and len(n) = 1
			n = n[1]
		ok

		if n <= 0
			StzRaise("Can't walk! Number of steps must be positive.")
		ok
		
		# Get remaining walkable positions
		aRemaining = This.RemainingWalkables()
		nLenRemaining = len(aRemaining)
		
		# Handle edge case
		if nLenRemaining = 0
			return [This.CurrentPosition()]
		ok
		
		if n > nLenRemaining
			n = nLenRemaining  # Walk as far as possible
		ok
		
		# Start with current position
		aWalks = [This.CurrentPosition()]
		
		# Add the next n positions
		for i = 1 to n
			aWalks + aRemaining[i]
		next
		
		# Update current position and history
		if len(aWalks) > 1
			@aCurrPosition = aWalks[len(aWalks)]
			@aWalkHistory + aWalks
		ok
		
		return aWalks
		
		def WalkN(n)
			return This.WalkNSteps(n)

	def WalkTo(nX, nY)
		
		if isList(nX) and len(nX) = 2
			nY = nX[2]
			nX = nX[1]
		ok
		
		if NOT This.IsWalkable([nX, nY])
			StzRaise("Can't walk! The position [" + nX + "," + nY + "] is not walkable.")
		ok
		
		aTarget = [nX, nY]
		aCurrent = This.CurrentPosition()
		aWalkables = This.Walkables()
		
		nCurrentIndex = This._FindPositionIndex(aWalkables, aCurrent)
		nTargetIndex = This._FindPositionIndex(aWalkables, aTarget)
		
		if nCurrentIndex = 0 or nTargetIndex = 0
			StzRaise("Position not found in walkable positions!")
		ok
		
		aResult = [aCurrent]
		
		if nCurrentIndex < nTargetIndex
			# Walk forward
			for i = nCurrentIndex + 1 to nTargetIndex
				aResult + aWalkables[i]
			next
		else
			# Walk backward
			for i = nCurrentIndex - 1 to nTargetIndex step -1
				aResult + aWalkables[i]
			next
		ok
		
		# Update current position and history
		@aCurrPosition = aResult[len(aResult)]
		@aWalkHistory + aResult
		
		return aResult
		
		def WalkToPosition(nX, nY)
			return This.WalkTo(nX, nY)

	def WalkToFirst()
		aWalkables = This.Walkables()

		if len(aWalkables) = 0
			StzRaise("No walkable positions available!")
		ok

		return This.WalkTo(aWalkables[1])

		#< @FunctionAlternativeForms

		def WalkToFirstPosition()
			return This.WalkToFirst()

		def WalkToFirstWalkable()
			return This.WalkToFirst()

		def WalkToFirstWalkablePosition()
			return This.WalkToFirst()
			
		def WalkToStart()
			return This.WalkTo(@nStartX, @nStartY)

		#>

	def WalkToLast()

		aWalkables = This.Walkables()

		if len(aWalkables) = 0
			StzRaise("No walkable positions available!")
		ok

		return This.WalkTo(aWalkables[len(aWalkables)])

		#< @FunctionAlternativeForms

		def WalkToLastPosition()
			return This.WalkToLast()

		def WalkToLastWalkable()
			return This.WalkToLast()

		def WalkToLastWalkablePosition()
			return This.WalkToLast()
			
		def WalkToEnd()
			return This.WalkTo(@nEndX, @nEndY)

		#>

	  #--------------------------------------#
	 #  CHECKING IF A POSITION IS WALKABLE  #
	#--------------------------------------#

	def IsWalkable(aPos)
		
		if isNumber(aPos) and isNumber(aPos)
			aPos = [aPos, aPos]
		ok
		
		if NOT (isList(aPos) and len(aPos) = 2)
			StzRaise("Incorrect param type! aPos must be a [x,y] position.")
		ok
		
		# Check if position exists in walkables
		return This._ListContains(@aWalkables, aPos)

		def IsWalkablePosition(aPos)
			return This.IsWalkable(aPos)

		def IsAWalkable(aPos)
			return This.IsWalkable(aPos)

		def ISAWalkablePosition(aPos)
			return This.IsWalkable(aPos)

	  #----------------------------------------#
	 #  CHECKING IF A POSITION IS UNWALKABLE  #
	#----------------------------------------#

	def IsUnwalkable(aPos)
		
		if isNumber(aPos) and isNumber(aPos)
			aPos = [aPos, aPos]
		ok
		
		if NOT (isList(aPos) and len(aPos) = 2)
			StzRaise("Incorrect param type! aPos must be a [x,y] position.")
		ok
		
		# Check if position exists in boundary but not in walkables
		aAllPositions = This.AllPositionsInBoundary()
		
		return (This._ListContains(aAllPositions, aPos) and NOT This.IsWalkable(aPos))

		def IsUnwalkablePosition(aPos)
			return This.IsUnwalkable(aPos)

		def IsAnUnwalkable(aPos)
			return This.IsUnwalkable(aPos)

		def IsAnUnwalkablePosition(aPos)
			return This.IsUnwalkable(aPos)

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
				if NOT This._ListContains(aResult, @aWalkHistory[i][j])
					aResult + @aWalkHistory[i][j]
				ok
			next
		next
		
		return aResult

	def NumberOfWalks()
		return len(This.Walks())

		def HowManyWalks()
			return This.NumberOfWalks()

		def CountWalks()
			return This.NumberOfWalks()

	def ResetHistory()
		@aWalkHistory = []
	
		def ClearHistory()
			return This.ResetHistory()

	def Reset()
		@aCurrPosition = [@nStartX, @nStartY]
		return This.ResetHistory()

		def Restart()
			return This.Reset()
	
		def ResetToStart()
			return This.Reset()

	  #------------------------------#
	 #  WALKING IN REVERSE / BACK   #
	#------------------------------#

	def WalkBackward()
		return This.WalkBackwardNSteps(1)

		def WalkBack()
			return This.WalkBackward()

	def WalkBackwardNSteps(n)

		if isList(n) and len(n) = 1
			n = n[1]
		ok

		if n <= 0
			StzRaise("Can't walk backward! Number of steps must be positive.")
		ok

		aWalkables = This.Walkables()
		aCurrent = This.CurrentPosition()
		nCurrentIndex = This._FindPositionIndex(aWalkables, aCurrent)

		if nCurrentIndex = 0
			StzRaise("Current position not found in walkable positions!")
		ok

		# Walk backward n steps or until the start is reached
		nStepsToWalk = min([n, nCurrentIndex - 1])

		if nStepsToWalk = 0
			return [aCurrent]  # Already at the beginning
		ok

		aResult = [aCurrent]

		for i = 1 to nStepsToWalk
			aResult + aWalkables[nCurrentIndex - i]
		next

		# Update current position and history
		@aCurrPosition = aResult[len(aResult)]
		@aWalkHistory + aResult

		return aResult

		def WalkBackN(n)
			return This.WalkBackwardNSteps(n)

	  #------------------------------#
	 #    RELATIVE WALKING UTILS    #
	#------------------------------#

	def WalkLeft()
		return This.WalkInDirection(:Left)

	def WalkRight()
		return This.WalkInDirection(:Right)

	def WalkUp()
		return This.WalkInDirection(:Up)

	def WalkDown()
		return This.WalkInDirection(:Down)

	def WalkUpRight()
		if NOT @bAllowDiagonal
			StzRaise("Can't walk diagonally! Diagonal movement is disabled.")
		ok
		return This.WalkInDirection(:UpRight)

	def WalkUpLeft()
		if NOT @bAllowDiagonal
			StzRaise("Can't walk diagonally! Diagonal movement is disabled.")
		ok
		return This.WalkInDirection(:UpLeft)

	def WalkDownRight()
		if NOT @bAllowDiagonal
			StzRaise("Can't walk diagonally! Diagonal movement is disabled.")
		ok
		return This.WalkInDirection(:DownRight)

	def WalkDownLeft()
		if NOT @bAllowDiagonal
			StzRaise("Can't walk diagonally! Diagonal movement is disabled.")
		ok
		return This.WalkInDirection(:DownLeft)

	  #----------------------------#
	 #    WALKING IN SECTIONS     #
	#----------------------------#

	def WalkBetween(panStart, panEnd)

		if NOT ( isList(panStart) and isList(panEnd) and
			 len(panStart) = 2 and len(panEnd) = 2 and
			 isNumber(panStart[1]) and isNumber(panStart[2]) and
			 isNumber(panEnd[1]) and isNumber(panEnd[2]) )

			StzRaise("Incorrect param type! panStart and panEnd must be both lists.")
		ok

		nStartX = panStart[1]
		nStartY = panStart[2]

		nEndX = panEnd[1]
		nEndY = panEnd[2]

		if NOT This.IsWalkable([nStartX, nStartY])
			StzRaise("Can't walk between! The position [" + nStartX + "," + nStartY + "] is not walkable.")
		ok
		
		if NOT This.IsWalkable([nEndX, nEndY])
			StzRaise("Can't walk between! The position [" + nEndX + "," + nEndY + "] is not walkable.")
		ok

		aStart = [nStartX, nStartY]
		aEnd = [nEndX, nEndY]
		aWalkables = This.Walkables()

		nStartIndex = This._FindPositionIndex(aWalkables, aStart)
		nEndIndex = This._FindPositionIndex(aWalkables, aEnd)

		if nStartIndex = 0 or nEndIndex = 0
			StzRaise("Position not found in walkable positions!")
		ok

		aResult = []

		if nStartIndex <= nEndIndex
			# Forward direction
			for i = nStartIndex to nEndIndex
				aResult + aWalkables[i]
			next
		else
			# Backward direction
			for i = nStartIndex to nEndIndex step -1
				aResult + aWalkables[i]
			next
		ok

		# Update current position and history
		@aCurrPosition = aResult[len(aResult)]
		@aWalkHistory + aResult
		
		return aResult

		def WalkFromTo(panStart, panEnd)
			return This.WalkBetween(panStart, panEnd)

	  #-------------------------------#
	 #  FINDING POSITIONS BY INDEX   #
	#-------------------------------#

	def PositionAt(nIndex)

		if NoT isNumber(nIndex)
			StzRaise("Incorrect param type! nIndex must be a number.")
		ok

		if nIndex = 0
			StzRaise("Incorrect param value! nIndex must not be equal to zero.")
		ok

		aWalkables = This.Walkables()
		
		if nIndex < 1 or nIndex > len(aWalkables)
			StzRaise("Invalid position index! Index must be between 1 and " + len(aWalkables) + ".")
		ok
	
		return aWalkables[nIndex]

		def WalkableAt(nIndex)
			return This.PositionAt(nIndex)
	
		def WalkablePositionAt(nIndex)
			return This.PositionAt(nIndex)

	  #------------------------------#
	 #   CALCULATING DISTANCES      #
	#------------------------------#

	def DistanceBetween(panPos1, panPos2)

		# Checking params

		if NOT ( isList(panPos1) and isList(panPos2) and
			 len(panPos1) = 2 and len(panPos2) = 2 and
			 isNumber(panPos1[1]) and isNumber(panPos1[2]) and
			 isNumber(panPos2[1]) and isNumber(panPos2[2]) )

			StzRaise("Incorrect param type! panPos1 and panPos2 must be both lists.")
		ok

		nX1 = panPos1[1]
		nY1 = panPos1[2]

		nX2 = panPos2[1]
		nY2 = panPos2[2]

		if ring_find([ nX1, nY1, nX2, nY2 ], 0) > 0
			StzRaise("Incorrect param value! Coordinate params must all be non zero numbers.")
		ok

		# Euclidean distance
		return sqrt(pow(nX2 - nX1, 2) + pow(nY2 - nY1, 2))

		def Distance(panPos1, panPos2)
			return This.DistanceBetween(panPos1, panPos2)

	def ManhattanDistanceBetween(panPos1, panPos2)

		# Checking params

		if NOT ( isList(panPos1) and isList(panPos2) and
			 len(panPos1) = 2 and len(panPos2) = 2 and
			 isNumber(panPos1[1]) and isNumber(panPos1[2]) and
			 isNumber(panPos2[1]) and isNumber(panPos2[2]) )

			StzRaise("Incorrect param type! panPos1 and panPos2 must be both lists.")
		ok

		nX1 = panPos1[1]
		nY1 = panPos1[2]

		nX2 = panPos2[1]
		nY2 = panPos2[2]

		if ring_find([ nX1, nY1, nX2, nY2 ], 0) > 0
			StzRaise("Incorrect param value! Coordinate params must all be non zero numbers.")
		ok

		# Manhattan distance (sum of absolute differences)
		return abs(nX2 - nX1) + abs(nY2 - nY1)

		def ManhattanDistance(panPos1, panPos2)
			return This.ManhattanDistanceBetween(panPos1, panPos2)

	  #----------------------------#
	 #   NEIGHBORING POSITIONS    #
	#----------------------------#

	def NeighborsOf(nX, nY)

		if NOT (isNumber(nX) and isNumber(nY))
			StzRaise("Incorrect param type! nX and nY must be numbers.")
		ok

		if nX = 0 or nY = 0
			StzRaise("Incorrect param value! nX and nY must be non zero numbers.")
		ok

		aNeighbors = []

		# Add cardinal directions (up, right, down, left)
		aCardinalDirections = [
			[nX, nY - 1],  # Up
			[nX + 1, nY],  # Right
			[nX, nY + 1],  # Down
			[nX - 1, nY]   # Left
		]

		for aPos in aCardinalDirections
			if This.IsWalkable(aPos)
				aNeighbors + aPos
			ok
		next

		# Add diagonal directions if allowed
		if @bAllowDiagonal
			aDiagonalDirections = [
				[nX + 1, nY - 1],  # Up-Right
				[nX - 1, nY - 1],  # Up-Left
				[nX + 1, nY + 1],  # Down-Right
				[nX - 1, nY + 1]   # Down-Left
			]
			
			for aPos in aDiagonalDirections
				if This.IsWalkable(aPos)
					aNeighbors + aPos
				ok
			next
		ok

		return aNeighbors

		def Neighbors(nX, nY)
			return This.NeighborsOf(nX, nY)
	
		def WalkableNeighborsOf(nX, nY)
			return This.NeighborsOf(nX, nY)
	
		def WalkableNeighbors(nX, nY)
			return This.NeighborsOf(nX, nY)

	def NumberOfNeighbors(nX, nY)
		return len(This.NeighborsOf(nX, nY))

		def HowManyNeighbors(nX, nY)
			return This.NumberOfNeighbors(nX, nY)
	
		def CountNeighbors(nX, nY)
			return This.NumberOfNeighbors(nX, nY)

	def _ReconstructPath(aCameFrom, aCurrent)
		aPath = [aCurrent]
		
		while This._HasCameFrom(aCameFrom, aCurrent)
			aCurrent = This._GetCameFrom(aCameFrom, aCurrent)
			aPath = [aCurrent] + aPath
		end
		
		return aPath

	def _GetScoreFor(aScoreList, aPos)

		nLen = len(aScoreList)

		for i = 1 to nLen step 2
			if This._ArePositionsEqual(aScoreList[i], aPos)
				return aScoreList[i+1]
			ok
		next

		return 0  # Default score if not found
	
	def _UpdateScore(aScoreList, aPos, nScore)

		nLen = len(aScoreList)

		for i = 1 to nLen step 2
			if This._ArePositionsEqual(aScoreList[i], aPos)
				aScoreList[i+1] = nScore
				return
			ok
		next

		aScoreList + [aPos, nScore]
	
	def _HasCameFrom(aCameFrom, aPos)

		nLen = len(aCameFrom)

		for i = 1 to nLen step 2
			if This._ArePositionsEqual(aCameFrom[i], aPos)
				return TRUE
			ok
		next

		return FALSE
	
	def _GetCameFrom(aCameFrom, aPos)

		nLen = len(aCameFrom)

		for i = 1 to nLen step 2
			if This._ArePositionsEqual(aCameFrom[i], aPos)
				return aCameFrom[i+1]
			ok
		next

		return []  # Empty position if not found
	
	def _UpdateCameFrom(aCameFrom, aPos, aFrom)

		for i = 1 to len(aCameFrom) step 2
			if This._ArePositionsEqual(aCameFrom[i], aPos)
				aCameFrom[i+1] = aFrom
				return
			ok
		next

		aCameFrom + [aPos, aFrom]

	def _ArePositionsEqual(aPos1, aPos2)

		if NOT ( isList(aPos1) and len(aPos1) = 2 and
			 isList(aPos2) and len(aPos2) = 2 and

			 isNumber(aPos1[1]) and isNumber(aPos1[2]) and
			 isNumber(aPos2[1]) and isNumber(aPos2[2]) )

			return FALSE
		ok

		return (aPos1[1] = aPos2[1] and aPos1[2] = aPos2[2])

	  #---------------------------#
	 #   HELPER METHODS          #
	#---------------------------#

	def _FindPositionIndex(aList, aPos)
		for i = 1 to len(aList)
			if aList[i][1] = aPos[1] and aList[i][2] = aPos[2]
				return i
			ok
		next
		return 0  # Not found

	def _ListContains(aList, aPos)
		return This._FindPositionIndex(aList, aPos) != 0

	  #---------------------------#
	 #    VISUALIZATION UTILS    #
	#---------------------------#

	def Show()
		? This.ToString()

		def ShowWalk()
			Show()

	def ToString()

		# Determine grid boundaries based on walkable positions
		nMinX = min([@nStartX, @nEndX])
		nMaxX = max([@nStartX, @nEndX])
		nMinY = min([@nStartY, @nEndY])
		nMaxY = max([@nStartY, @nEndY])

		# Create grid
		aGrid = []
		for y = nMinY to nMaxY
			aRow = []
			for x = nMinX to nMaxX
				aRow + "."  # Empty space
			next
			aGrid + aRow
		next

		# Mark walkable positions
		aWalkables = This.Walkables()
		nLen = len(aWalkables)

		for i = 1 to nLen
			nX = aWalkables[i][1]
			nY = aWalkables[i][2]
			if nX >= nMinX and nX <= nMaxX and nY >= nMinY and nY <= nMaxY
				aGrid[nY - nMinY + 1][nX - nMinX + 1] = "o"  # Walkable
			ok
		next

		# Mark current position
		nCurrX = @aCurrPosition[1]
		nCurrY = @aCurrPosition[2]
		if nCurrX >= nMinX and nCurrX <= nMaxX and nCurrY >= nMinY and nCurrY <= nMaxY
			aGrid[nCurrY - nMinY + 1][nCurrX - nMinX + 1] = "x"  # Current
		ok

		# Mark start and end positions
		if @nStartX >= nMinX and @nStartX <= nMaxX and @nStartY >= nMinY and @nStartY <= nMaxY
			aGrid[@nStartY - nMinY + 1][@nStartX - nMinX + 1] = "S"  # Start
		ok
		if @nEndX >= nMinX and @nEndX <= nMaxX and @nEndY >= nMinY and @nEndY <= nMaxY
			aGrid[@nEndY - nMinY + 1][@nEndX - nMinX + 1] = "E"  # End
		ok

		# Draw the grid
		cResult = ""
		nLen = len(aGrid)
		for y = 1 to nLen
			cRow = ""
			nLenTemp = len(aGrid[y])
			for x = 1 to nLenTemp
				cRow += aGrid[y][x] + " "
			next
			cResult += cRow + nl
		next

		return cResult


	def ShowXT()
		? This.ToStringXT()

		def ShowWalkXT()
			ShowXT()

	def ToStringXT()
