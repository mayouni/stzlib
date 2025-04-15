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

	def init(pnStartX, pnStartY, pnEndX, pnEndY, pSteps)
		
		# Handle initialization with a list or hashlist
		if isList(pnStartX) and len(pnStartX) = 5
			pnStartY = pnStartX[2]
			pnEndX = pnStartX[3]
			pnEndY = pnStartX[4]
			pSteps = pnStartX[5]
			pnStartX = pnStartX[1]
		
		# Handle initialization with named parameters
		but isList(pnStartX) and 
		   (HasAttribute(pnStartX, :StartX) or HasAttribute(pnStartX, :StartAt))
			
			if HasAttribute(pnStartX, :StartX)
				pnStartX = pnStartX[:StartX]
				
			but HasAttribute(pnStartX, :StartAt) and 
			    isList(pnStartX[:StartAt]) and
			    len(pnStartX[:StartAt]) = 2
				
				pnStartY = pnStartX[:StartAt][2]
				pnStartX = pnStartX[:StartAt][1]
			ok
			
			if HasAttribute(pnStartX, :EndX)
				pnEndX = pnStartX[:EndX]
				
			but HasAttribute(pnStartX, :EndAt) and
			    isList(pnStartX[:EndAt]) and
			    len(pnStartX[:EndAt]) = 2
				
				pnEndY = pnStartX[:EndAt][2]
				pnEndX = pnStartX[:EndAt][1]
			ok
			
			if HasAttribute(pnStartX, :Steps)
				pSteps = pnStartX[:Steps]
			ok
		ok

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

		# Get step size
		nStep = @pSteps

		# Calculate the total number of steps needed
		nDeltaX = @nEndX - @nStartX
		nDeltaY = @nEndY - @nStartY

		# Determine the number of steps in each direction
		nStepsX = nDeltaX / nStep
		nStepsY = nDeltaY / nStep

		# Determine if we need to round up or down
		nStepsX = floor(nStepsX)
		nStepsY = floor(nStepsY)

		# Calculate step directions
		nStepDirX = sign(nDeltaX)
		nStepDirY = sign(nDeltaY)

		# Adjust zero steps to be non-negative for loop iteration
		if nStepsX < 0 nStepsX = 0 ok
		if nStepsY < 0 nStepsY = 0 ok

		# Check if we need to make a purely horizontal move first
		if abs(nStepsX) > abs(nStepsY)

			# Horizontal-first movement
			nX = @nStartX
			nY = @nStartY

			for i = 1 to abs(nStepsX)
				nX += nStep * nStepDirX
				@aWalkables + [nX, nY]
			next

			# Then vertical movement
			for i = 1 to abs(nStepsY)
				nY += nStep * nStepDirY
				@aWalkables + [nX, nY]
			next

		else
			# Vertical-first movement
			nX = @nStartX
			nY = @nStartY

			for i = 1 to abs(nStepsY)
				nY += nStep * nStepDirY
				@aWalkables + [nX, nY]
			next

			# Then horizontal movement
			for i = 1 to abs(nStepsX)
				nX += nStep * nStepDirX
				@aWalkables + [nX, nY]
			next
		ok

		# If we didn't hit the exact end position, add it
		if @aWalkables[len(@aWalkables)][1] != @nEndX or 
		   @aWalkables[len(@aWalkables)][2] != @nEndY
			
			@aWalkables + [@nEndX, @nEndY]
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

		# Calculate path until we reach the end position or max iterations
		while (nX != @nEndX or nY != @nEndY) and nIterations < nMaxIterations

			nIterations++

			# Get current step
			pCurrentStep = @pSteps[nStepIndex]

			# Process the step based on its type
			if isNumber(pCurrentStep)
				# Apply step in current direction
				nStepX = 0
				nStepY = 0

				if @cDirection = :Right
					nStepX = pCurrentStep
				but @cDirection = :Left
					nStepX = -pCurrentStep
				but @cDirection = :Down
					nStepY = pCurrentStep
				but @cDirection = :Up
					nStepY = -pCurrentStep
				but @cDirection = :UpRight
					nStepX = pCurrentStep
					nStepY = -pCurrentStep
				but @cDirection = :UpLeft
					nStepX = -pCurrentStep
					nStepY = -pCurrentStep
				but @cDirection = :DownRight
					nStepX = pCurrentStep
					nStepY = pCurrentStep
				but @cDirection = :DownLeft
					nStepX = -pCurrentStep
					nStepY = pCurrentStep
				ok

			but isList(pCurrentStep)
				nStepX = pCurrentStep[1]
				nStepY = pCurrentStep[2]
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
		return new stzWalker2D(@nStartX, @nStartY, @nEndX, @nEndY, @pSteps)

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
		
		for i = 1 to len(aAllPositions)
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
		
		for i = nCurrentIndex + 1 to len(aWalkables)
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

	def WalkBetween(pnStartX, pnStartY, pnEndX, pnEndY)
		
		if isList(pnStartX) and len(pnStartX) = 2
			pnStartY = pnStartX[2]
			pnStartX = pnStartX[1]
		ok
		
		if isList(pnEndX) and len(pnEndX) = 2
			pnEndY = pnEndX[2]
			pnEndX = pnEndX[1]
		ok
		
		if NOT This.IsWalkable([pnStartX, pnStartY])
			StzRaise("Can't walk between! The position [" + pnStartX + "," + pnStartY + "] is not walkable.")
		ok
		
		if NOT This.IsWalkable([pnEndX, pnEndY])
			StzRaise("Can't walk between! The position [" + pnEndX + "," + pnEndY + "] is not walkable.")
		ok
		
		aStart = [pnStartX, pnStartY]
		aEnd = [pnEndX, pnEndY]
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
		
		def WalkFromTo(pnStartX, pnStartY, pnEndX, pnEndY)
			return This.WalkBetween(pnStartX, pnStartY, pnEndX, pnEndY)

	  #-------------------------------#
	 #  FINDING POSITIONS BY INDEX   #
	#-------------------------------#

	def PositionAt(nIndex)
		aWalkables = This.Walkables()
		
		if nIndex < 1 or nIndex > len(aWalkables)
			StzRaise("Invalid position index! Index must be between 1 and " + len(aWalkables) + ".")
		ok
		
		return aWalkables[nIndex]
		
		def WalkableAt(nIndex)
			return This.PositionAt(nIndex)
			
		def WalkablePositionAt(nIndex)
			return This.PositionAt(nIndex)

	def IndexOf(nX, nY)
		
		if isList(nX) and len(nX) = 2
			nY = nX[2]
			nX = nX[1]
		ok
		
		aPos = [nX, nY]
		aWalkables = This.Walkables()
		
		return This._FindPositionIndex(aWalkables, aPos)
		
		def PositionIndexOf(nX, nY)
			return This.IndexOf(nX, nY)
			
		def WalkableIndexOf(nX, nY)
			return This.IndexOf(nX, nY)

	  #------------------------------#
	 #   CALCULATING DISTANCES      #
	#------------------------------#

	def DistanceBetween(nX1, nY1, nX2, nY2)

		if isList(nX1) and len(nX1) = 2
			nY1 = nX1[2]
			nX1 = nX1[1]
		ok

		if isList(nX2) and len(nX2) = 2
			nY2 = nX2[2]
			nX2 = nX2[1]
		ok
	
		# Euclidean distance
		return sqrt(pow(nX2 - nX1, 2) + pow(nY2 - nY1, 2))

		def Distance(nX1, nY1, nX2, nY2)
			return This.DistanceBetween(nX1, nY1, nX2, nY2)

	def ManhattanDistanceBetween(nX1, nY1, nX2, nY2)

		if isList(nX1) and len(nX1) = 2
			nY1 = nX1[2]
			nX1 = nX1[1]
		ok

		if isList(nX2) and len(nX2) = 2
			nY2 = nX2[2]
			nX2 = nX2[1]
		ok

		# Manhattan distance (sum of absolute differences)
		return abs(nX2 - nX1) + abs(nY2 - nY1)

		def ManhattanDistance(nX1, nY1, nX2, nY2)
			return This.ManhattanDistanceBetween(nX1, nY1, nX2, nY2)

	  #----------------------------#
	 #   NEIGHBORING POSITIONS    #
	#----------------------------#

	def NeighborsOf(nX, nY)

		if isList(nX) and len(nX) = 2
			nY = nX[2]
			nX = nX[1]
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

	  #----------------------------------#
	 #   PATH FINDING (SIMPLE A-STAR)   #
	#----------------------------------#

	def FindPathBetween(nX1, nY1, nX2, nY2)

 		# A* Search Algorithm

		# This implementation finds the shortest path between two walkable positions
		# using the A* search algorithm with Manhattan distance heuristic.

		# The algorithm works by:
		# 1. Maintaining an open set of positions to explore
		# 2. Using f_score = g_score + heuristic to prioritize which positions to explore
		# 3. Tracking the best known path to each position
		# 4. Reconstructing the optimal path once the goal is reached

		# Note: This A* implementation uses linear searches in lists which works
		# well for small grids. For large-scale pathfinding, consider implementing
		# a more efficient data structure like a priority queue and hashmap.

		if isList(nX1) and len(nX1) = 2
			nY1 = nX1[2]
			nX1 = nX1[1]
		ok
		
		if isList(nX2) and len(nX2) = 2
			nY2 = nX2[2]
			nX2 = nX2[1]
		ok
		
		# Check if positions are walkable
		if NOT This.IsWalkable([nX1, nY1])
			StzRaise("Can't find path! The start position [" + nX1 + "," + nY1 + "] is not walkable.")
		ok
		
		if NOT This.IsWalkable([nX2, nY2])
			StzRaise("Can't find path! The end position [" + nX2 + "," + nY2 + "] is not walkable.")
		ok
		
		# A* algorithm implementation
		aStart = [nX1, nY1]
		aGoal = [nX2, nY2]
		
		# Initialize the open and closed sets
		aOpenSet = [aStart]
		aClosedSet = []
		
		# g_score[node] is the cost of the best path from start to node
		aGScore = []
		aGScore + [aStart, 0]
		
		# f_score[node] = g_score[node] + heuristic(node, goal)
		aFScore = []
		aFScore + [aStart, This.ManhattanDistanceBetween(nX1, nY1, nX2, nY2)]
		
		# cameFrom[node] is the node immediately preceding it on the best path
		aCameFrom = []
		
		while len(aOpenSet) > 0
			# Get the node in openSet having the lowest fScore value
			nCurrentIndex = 1
			nLowestFScore = This._GetScoreFor(aFScore, aOpenSet[1])
			
			for i = 2 to len(aOpenSet)
				nScore = This._GetScoreFor(aFScore, aOpenSet[i])
				if nScore < nLowestFScore
					nLowestFScore = nScore
					nCurrentIndex = i
				ok
			next
			
			aCurrent = aOpenSet[nCurrentIndex]
			
			# If we reached the goal, reconstruct and return the path
			if aCurrent[1] = aGoal[1] and aCurrent[2] = aGoal[2]
				return This._ReconstructPath(aCameFrom, aCurrent)
			ok
			
			# Move current from open to closed set
			del(aOpenSet, nCurrentIndex)
			aClosedSet + aCurrent
			
			# Check each neighbor
			aNeighbors = This.NeighborsOf(aCurrent[1], aCurrent[2])
			
			for aNeighbor in aNeighbors
				# Skip if in closed set
				if This._ListContains(aClosedSet, aNeighbor)
					loop
				ok
				
				# Calculate tentative_gScore
				nTentativeGScore = This._GetScoreFor(aGScore, aCurrent) + 
								This.DistanceBetween(aCurrent[1], aCurrent[2], 
												   aNeighbor[1], aNeighbor[2])
				
				# If neighbor is not in openSet, discover it
				bIsInOpenSet = This._ListContains(aOpenSet, aNeighbor)
				if NOT bIsInOpenSet
					aOpenSet + aNeighbor
				ok
				
				# This path to neighbor is better than any previous one
				nNeighborGScore = This._GetScoreFor(aGScore, aNeighbor)
				if nTentativeGScore < nNeighborGScore or nNeighborGScore = 0
					# Record the best path
					This._UpdateCameFrom(aCameFrom, aNeighbor, aCurrent)
					This._UpdateScore(aGScore, aNeighbor, nTentativeGScore)
					
					nFScore = nTentativeGScore + 
							This.ManhattanDistanceBetween(aNeighbor[1], aNeighbor[2], nX2, nY2)
					This._UpdateScore(aFScore, aNeighbor, nFScore)
				ok
			next
		end
		
		# If we get here, no path was found
		return []
		
		def FindPath(nX1, nY1, nX2, nY2)
			return This.FindPathBetween(nX1, nY1, nX2, nY2)
	
	def _ReconstructPath(aCameFrom, aCurrent)
		aPath = [aCurrent]
		
		while This._HasCameFrom(aCameFrom, aCurrent)
			aCurrent = This._GetCameFrom(aCameFrom, aCurrent)
			aPath = [aCurrent] + aPath
		end
		
		return aPath
	
	def _GetScoreFor(aScoreList, aPos)
		for i = 1 to len(aScoreList) step 2
			if This._ArePositionsEqual(aScoreList[i], aPos)
				return aScoreList[i+1]
			ok
		next
		return 0  # Default score if not found
	
	def _UpdateScore(aScoreList, aPos, nScore)
		for i = 1 to len(aScoreList) step 2
			if This._ArePositionsEqual(aScoreList[i], aPos)
				aScoreList[i+1] = nScore
				return
			ok
		next
		aScoreList + [aPos, nScore]
	
	def _HasCameFrom(aCameFrom, aPos)
		for i = 1 to len(aCameFrom) step 2
			if This._ArePositionsEqual(aCameFrom[i], aPos)
				return TRUE
			ok
		next
		return FALSE
	
	def _GetCameFrom(aCameFrom, aPos)
		for i = 1 to len(aCameFrom) step 2
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
		if NOT (isList(aPos1) and len(aPos1) = 2 and isList(aPos2) and len(aPos2) = 2)
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
	
	def DrawPath()
		
		nMinX = min([@nStartX, @nEndX])
		nMaxX = max([@nStartX, @nEndX])
		nMinY = min([@nStartY, @nEndY])
		nMaxY = max([@nStartY, @nEndY])
		
		# Add some padding
		nPadding = 2
		nMinX = max([1, nMinX - nPadding])
		nMaxX = nMaxX + nPadding
		nMinY = max([1, nMinY - nPadding])
		nMaxY = nMaxY + nPadding
		
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
		for aPos in This.Walkables()
			nX = aPos[1]
			nY = aPos[2]
			if nX >= nMinX and nX <= nMaxX and nY >= nMinY and nY <= nMaxY
				aGrid[nY - nMinY + 1][nX - nMinX + 1] = "o"  # Walkable
			ok
		next
		
		# Mark current position
		nCurrX = @aCurrPosition[1]
		nCurrY = @aCurrPosition[2]
		if nCurrX >= nMinX and nCurrX <= nMaxX and nCurrY >= nMinY and nCurrY <= nMaxY
			aGrid[nCurrY - nMinY + 1][nCurrX - nMinX + 1] = "C"  # Current
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
		for y = 1 to len(aGrid)
			cRow = ""
			for x = 1 to len(aGrid[y])
				cRow += aGrid[y][x] + " "
			next
			cResult += cRow + nl
		next
		
		return cResult
		
		def ToString()
			return This.DrawPath()
			
		def Draw()
			return This.DrawPath()
