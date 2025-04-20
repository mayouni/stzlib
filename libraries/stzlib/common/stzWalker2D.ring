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

func Wk2D(panStart, panEnd, pStep)
	return new stzWalker2D(panStart, panEnd, pStep)

	func StzWalker2DQ(panStart, panEnd, pStep)
		return new stzWalker2D(panStart, panEnd, pStep)

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

	@aDirections = [] # [dirX, dirY] where 1 is forward, -1 is backward

	@pSteps    # Can be a number, a pair [xStep, yStep], or a list of pairs
	@bIsVariantSteps = FALSE
	@nCurrentStepIndex = 1  # For cycling through variable steps

	@aWalkables = []  # List of walkable positions as [x,y] pairs
	@aCurrPosition = [] # Current position as [x,y]
	@aWalkHistory = []  # Stores the history of walks

	  #-------------------------#
	 #   SETTING THE WALKER    #
	#-------------------------#

	def init(panStart, panEnd, pSteps)
		# Handle different parameter formats
		if isList(panStart) and len(panStart) = 2 and isNumber(panStart[1]) and isNumber(panStart[2])
			pnStartX = panStart[1]
			pnStartY = panStart[2]
		but isNumber(panStart) and isNumber(panEnd) and isNumber(pSteps) and isNumber(panStart)
			# Legacy-style init with separate coordinates
			pnStartX = panStart
			pnStartY = panEnd
			pnEndX = pSteps
			pnEndY = panStart
			pSteps = panEnd
			panEnd = [pnEndX, pnEndY]
			panStart = [pnStartX, pnStartY]
		but CheckingParams()
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

		# Extract coordinates after processing
		if isList(panStart) and len(panStart) = 2
			pnStartX = panStart[1]
			pnStartY = panStart[2]
		else
			StzRaise("Incorrect param type! panStart must be a pair of numbers.")
		ok

		if isList(panEnd) and len(panEnd) = 2
			pnEndX = panEnd[1]
			pnEndY = panEnd[2]
		else
			StzRaise("Incorrect param type! panEnd must be a pair of numbers.")
		ok

		# Validate coordinates
		if NOT (isNumber(pnStartX) and isNumber(pnStartY) and 
				isNumber(pnEndX) and isNumber(pnEndY))
			StzRaise("Incorrect param values! Start and end coordinates must be numbers.")
		ok

		# Store parameters
		@nStartX = pnStartX
		@nStartY = pnStartY
		@nEndX = pnEndX
		@nEndY = pnEndY

		# Determine directions for X and Y independently
		@aDirections = [
			@IF(@nStartX <= @nEndX, 1, -1),  # X direction (1 = forward, -1 = backward)
			@IF(@nStartY <= @nEndY, 1, -1)   # Y direction (1 = forward, -1 = backward)
		]

		# Process steps parameter
		This.ProcessSteps(pSteps)
		
		# Calculate walkable positions
		This.CalculateWalkables()
		
		# Set initial position
		@aCurrPosition = [@nStartX, @nStartY]
		
		# Initialize empty walk history
		@aWalkHistory = []

	def ProcessSteps(pSteps)
		if isNumber(pSteps)
			if pSteps <= 0
				StzRaise("Can't create the stzWalker2D object! Step size must be positive.")
			ok
			
			@pSteps = pSteps
			@bIsVariantSteps = FALSE
		
		but isList(pSteps)
			if len(pSteps) = 0
				StzRaise("Can't create the stzWalker2D object! Steps list cannot be empty.")
			ok
			
			# Check if the list is a single pair or a list of pairs
			if len(pSteps) = 2 and isNumber(pSteps[1]) and isNumber(pSteps[2])
				# It's a single [xStep, yStep] pair
				if pSteps[1] <= 0 or pSteps[2] <= 0
					StzRaise("Can't create the stzWalker2D object! Step values must be positive.")
				ok
				
				@pSteps = pSteps
				@bIsVariantSteps = FALSE
			else
				# It should be a list of step pairs
				for i = 1 to len(pSteps)
					if isList(pSteps[i]) and len(pSteps[i]) = 2 and 
					   isNumber(pSteps[i][1]) and isNumber(pSteps[i][2])
						if pSteps[i][1] <= 0 or pSteps[i][2] <= 0
							StzRaise("Can't create the stzWalker2D object! Step values must be positive.")
						ok
					but isNumber(pSteps[i])
						if pSteps[i] <= 0
							StzRaise("Can't create the stzWalker2D object! Step values must be positive.")
						ok
					else
						StzRaise("Can't create the stzWalker2D object! Each step must be a number or a pair [xStep, yStep].")
					ok
				next
				
				@pSteps = pSteps
				@bIsVariantSteps = TRUE
			ok
		else
			StzRaise("Incorrect param type! pSteps must be a number, a pair [xStep, yStep], or a list of such pairs.")
		ok

	def CalculateWalkables()
		# Reset walkables list
		@aWalkables = []
		
		# Get min/max bounds for iteration
		nMinX = min([@nStartX, @nEndX])
		nMaxX = max([@nStartX, @nEndX])
		nMinY = min([@nStartY, @nEndY])
		nMaxY = max([@nStartY, @nEndY])
		
		# Determine if we're using fixed or variable steps
		if NOT @bIsVariantSteps
			# Fixed step mode
			This.CalculateFixedStepWalkables(nMinX, nMaxX, nMinY, nMaxY)
		else
			# Variable step mode
			This.CalculateVariableStepWalkables(nMinX, nMaxX, nMinY, nMaxY)
		ok

	def CalculateFixedStepWalkables(nMinX, nMaxX, nMinY, nMaxY)
		# Determine step sizes for X and Y
		nStepX = 0
		nStepY = 0
		
		if isNumber(@pSteps)
			# Same step size for both dimensions
			nStepX = @pSteps
			nStepY = @pSteps
		else
			# Different step sizes for X and Y
			nStepX = @pSteps[1]
			nStepY = @pSteps[2]
		ok
		
		# Apply directional movement
		nDirX = @aDirections[1]
		nDirY = @aDirections[2]
		
		# Start from initial position
		nX = @nStartX
		nY = @nStartY
		
		# Generate grid of valid positions
		while (nDirX > 0 and nX <= @nEndX) or (nDirX < 0 and nX >= @nEndX)
			tempY = nY  # Reset Y for each X iteration
			
			while (nDirY > 0 and tempY <= @nEndY) or (nDirY < 0 and tempY >= @nEndY)
				# Add current position to walkables if within bounds
				if tempY >= nMinY and tempY <= nMaxY and nX >= nMinX and nX <= nMaxX
					@aWalkables + [nX, tempY]
				ok
				
				# Move Y according to step and direction
				tempY += nStepY * nDirY
			end
			
			# Move X according to step and direction
			nX += nStepX * nDirX
		end
		
		# Ensure the end position is included if it's not already
		if NOT This._ListContains(@aWalkables, [@nEndX, @nEndY])
			@aWalkables + [@nEndX, @nEndY]
		ok

	def CalculateVariableStepWalkables(nMinX, nMaxX, nMinY, nMaxY)
		# Start with initial position
		nX = @nStartX
		nY = @nStartY
		@aWalkables = [[@nStartX, @nStartY]]
		
		# Extract directions
		nDirX = @aDirections[1]
		nDirY = @aDirections[2]
		
		# Get the number of steps in the list
		nStepsCount = len(@pSteps)
		nCurrentStep = 1
		
		# Set a reasonable maximum to prevent infinite loops
		nMaxIterations = 10000
		nIterations = 0
		
		while nIterations < nMaxIterations
			nIterations++
			
			# Get the current step
			pCurrStep = @pSteps[nCurrentStep]
			
			# Apply step based on its type
			if isNumber(pCurrStep)
				# Same step size for both dimensions
				nStepX = pCurrStep * nDirX
				nStepY = pCurrStep * nDirY
			else
				# Different step sizes for X and Y
				nStepX = pCurrStep[1] * nDirX
				nStepY = pCurrStep[2] * nDirY
			ok
			
			# Calculate next position
			nNextX = nX + nStepX
			nNextY = nY + nStepY
			
			# Check if we've reached or passed the end in both dimensions
			bReachedOrPassedEndX = (nDirX > 0 and nNextX >= @nEndX) or (nDirX < 0 and nNextX <= @nEndX)
			bReachedOrPassedEndY = (nDirY > 0 and nNextY >= @nEndY) or (nDirY < 0 and nNextY <= @nEndY)
			
			if bReachedOrPassedEndX and bReachedOrPassedEndY
				# We've reached or passed the end position, add it and exit
				if NOT This._ListContains(@aWalkables, [@nEndX, @nEndY])
					@aWalkables + [@nEndX, @nEndY]
				ok
				exit
			ok
			
			# Check if next position is within bounds
			if nNextX >= nMinX and nNextX <= nMaxX and nNextY >= nMinY and nNextY <= nMaxY
				if NOT This._ListContains(@aWalkables, [nNextX, nNextY])
					@aWalkables + [nNextX, nNextY]
				ok
				
				# Update current position
				nX = nNextX
				nY = nNextY
			else
				# We've gone out of bounds, exit loop
				exit
			ok
			
			# Move to next step in the cycle
			nCurrentStep++
			if nCurrentStep > nStepsCount
				nCurrentStep = 1
			ok
		end
		
		# Safety check
		if nIterations >= nMaxIterations
			StzRaise("Maximum iterations reached when calculating walkable positions. Possible infinite loop.")
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
		if isList(nX) and len(nX) = 2
			nY = nX[2]
			nX = nX[1]
		ok
		
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

	def Directions()
		return @aDirections
		
		def Direction()
			cXDir = @IF(@aDirections[1] > 0, "forward", "backward")
			cYDir = @IF(@aDirections[2] > 0, "forward", "backward")
			return "X: " + cXDir + ", Y: " + cYDir
		
		def CurrentDirection()
			return This.Direction()

	  #-----------------------------------------------------#
	 #  POSITIONS, WALKED POSITIONS & UNWALKED POSITIONS   #
	#-----------------------------------------------------#

	def Positions()
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
		aAllPositions = This.Positions()
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

		def NumberOfUnwalkables()
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

		def WalkToFirstPosition()
			return This.WalkToFirst()

		def WalkToFirstWalkable()
			return This.WalkToFirst()

		def WalkToFirstWalkablePosition()
			return This.WalkToFirst()
			
		def WalkToStart()
			return This.WalkTo(@nStartX, @nStartY)

	def WalkToLast()
		aWalkables = This.Walkables()

		if len(aWalkables) = 0
			StzRaise("No walkable positions available!")
		ok

		return This.WalkTo(aWalkables[len(aWalkables)])

		def WalkToLastPosition()
			return This.WalkToLast()

		def WalkToLastWalkable()
			return This.WalkToLast()

		def WalkToLastWalkablePosition()
			return This.WalkToLast()
			
		def WalkToEnd()
			return This.WalkTo(@nEndX, @nEndY)

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
		aAllPositions = This.Positions()
		
		return (This._ListContains(aAllPositions, aPos) and NOT This.IsWalkable(aPos))

		def IsUnwalkablePosition(aPos)
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

	  #----------------------------#
	 #    WALKING IN SECTIONS     #
	#----------------------------#

	def WalkBetween(panStart, panEnd)

		if NOT ( isList(panStart) and isList(panEnd) and
			len(panStart) = 2 and len(panEnd) = 2 and
			isNumber(panStart[1]) and isNumber(panStart[2]) and
			isNumber(panEnd[1]) and isNumber(panEnd[2]) )

			StzRaise("Incorrect param types! Start and end must be [x,y] positions.")
		ok
    
		# Check if positions are walkable

		if NOT This.IsWalkable(panStart)
				StzRaise("Start position [" + panStart[1] + "," + panStart[2] + "] is not walkable.")
		ok

		if NOT This.IsWalkable(panEnd)
			StzRaise("End position [" + panEnd[1] + "," + panEnd[2] + "] is not walkable.")
		ok

		# Save current position to restore later if needed
		aSavedPosition = This.CurrentPosition()

		# Set current position to start point
		This.SetCurrentPosition(panStart[1], panStart[2])

		# Now walk to the end point
		aResult = This.WalkTo(panEnd[1], panEnd[2])

		# Restore original position
		This.SetCurrentPosition(aSavedPosition[1], aSavedPosition[2])

		return aResult

		def WalkBetweenPositions(panStart, panEnd)
		return This.WalkBetween(panStart, panEnd)

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
