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

	@anStartPos	# start positon as a [x,y] pair
	@anEndPos	# end position as a [x,y] pair

	@cDirection	# :forward or :backward

	@Steps		# Can be a number or a list of numbers

	@aWalkables = []	# List of walkable positions as [x,y] pairs
	@aCurrPosition = []	# Current position as [x,y]
	@aWalkHistory = []	# Stores the history of walks

	  #-------------------------#
	 #   SETTING THE WALKER    #
	#-------------------------#

	def init(panStart, panEnd, pSteps)

		if CheckingParams()

			if isList(panStart) and
			   StzListQ(panStart).IsOneOfTheseNamedParams([
				:Start, :StartAt, :StartsAt, :StartingAt,
				:StartFrom, :StartsFrom, :StartingFrom,
				:From, :FromPosition
			])
				panStart = panStart[2]
			ok

			if NOT ( isList(panStart) and len(panStart) = 2 and
				 isNumber(panStart[1]) and isNumber(panStart[2]) )

				StzRaise("Incorrect param type! panStart must be a pair of numbers.")
			ok

			if isList(panEnd) and
			   StzListQ(panEnd).IsOneOfTheseNamedParams([
				:End, :EndAt, :EndsAt, :EndingAt,
				:Stop, :StopAt, :StopsAt, :StoppingAt,
				:To, :ToPosition
			   ])
				panEnd = panEnd[2]
			ok

			if NOT ( isList(panEnd) and len(panEnd) = 2 and
				 isNumber(panEnd[1]) and isNumber(panEnd[2]) )

				StzRaise("Incorrect param type! panEnd must be a pair of numbers.")
			ok

			if isList(pSteps) and
			   StzListQ(pSteps).IsOneOfTheseNamedParams([
				:Jump, :Step, :NStep, :Steps
			  ])
				pSteps = pSteps[2]
			ok

			if NOT (isNumber(pSteps) or IsListOfNumbers(pSteps))
				StzRaise("Incorrect param type! pSteps must be a number or list of numbers.")
			ok
		ok

		# Handle different parameter formats

		@anStartPos = panStart
		@anEndPos = panEnd
		@Steps = pSteps


		# Early check if 0s in positions

		if ring_find(@anStartPos, 0) > 0 or ring_find(@anEndPos, 0) > 0
			StzRaise("Incorrect param type! Start and end positions must not contain zeros.")
		ok

		if @anStartPos[1] = @anEndPos[1] and @anStartPos[2] = @anEndPos[2]
			StzRaise("Can't create the stzWalker object! pnStart and pnEnd must be different.")
		ok

		# Calculate direction

		if @anStartPos[1] * @anStartPos[2] < @anEndPos[1] * @anEndPos[2]
			@cDirection = :Forward
		else
			@cDirection = :Backward
		ok

		# Early check of the steps

		anTempSteps = []

		if isNumber(@Steps)
			if @Steps = 0
				StzRaise("Incorrect param value! @Steps must be non zero.")
			ok

			anTempSteps + @Steps

		else

			if ring_find(@Steps, 0)
				StzRaise("Incorrect param value! @Steps list must not contain a zero.")
			ok

			anTempSteps = @Steps
		ok

		nSum = Sum(anTempSteps)

		if ( @cDirection = :Forward and nSum < 0 and
		   @anStartPos[1] <= abs(nSum) ) OR

		   ( @cDirection = :Backward and nSum > 0 and
		    @anEndPos[1] <= nSum )

			StzRaise("Incorrect param value! @Steps is attempting to walk out before the first position.")

		ok

		# Calculate walkable positions
		@aWalkables = This.CalculateWalkables()
		
		# Set initial position
		@aCurrPosition = @anStartPos
		
		# Initialize empty walk history
		@aWalkHistory = []

	  #-------------------------#
	 #  CALCULATING WALKABLES  #
	#-------------------------#

	def CalculateWalkables()
		aResult = []

		# If start point and end point are the same ~> no walkables!
		if @anStartPos[1] = @anEndPos[1] and @anStartPos[2] = @anEndPos[2]
			return [@anStartPos]  # Return just the start position
		ok

		# If direction is backward, use separate method
		if @cDirection = :Backward
			return This.CalculateWalkablesBackward()
		ok

		# Determine the grid bounds - the area that contains both start and end

		nMinX = min([ @anStartPos[1], @anEndPos[1] ])
		nMaxX = max([ @anStartPos[1], @anEndPos[1] ])
		nMinY = min([ @anStartPos[2], @anEndPos[2] ])
		nMaxY = max([ @anStartPos[2], @anEndPos[2] ])

		# Generate all positions in the grid
		aAllPos = []

		for j = nMinY to nMaxY
			for i = nMinX to nMaxX
				aAllPos + [ i, j ]
			next
		next

		# Find start position in the list
		oStzList = new stzList(aAllPos)
		n1 = oStzList.FindFirst(@anStartPos)
		n2 = len(aAllPos)

		# Check if pSteps is a number or a list

		if isNumber(@Steps)

			for i = n1 to n2 step @Steps
				aResult + aAllPos[i]
			next

		else

			# Use cyclic list of steps
			currentStep = 1
			i = n1

			while i <= n2

				aResult + aAllPos[i]
	
				# Get the current step from the list
				stepSize = @Steps[currentStep]
	
				# Move to next position
				i += stepSize
	
				# Move to next step in the cycle
				currentStep++
				if currentStep > len(@Steps)
					currentStep = 1
				ok
			end
		ok

		return aResult

	#---

	def CalculateWalkablesBackward()
		aResult = []

		# If start point and end point are the same ~> no walkables!
		if @anStartPos[1] = @anEndPos[1] and @anStartPos[2] = @anEndPos[2]
			return [@anStartPos]  # Return just the start position
		ok

		# Determine the grid bounds - the area that contains both start and end
		nMinX = min([@anStartPos[1], @anEndPos[1]])
		nMaxX = max([@anStartPos[1], @anEndPos[1]])
		nMinY = min([@anStartPos[2], @anEndPos[2]])
		nMaxY = max([@anStartPos[2], @anEndPos[2]])

		# Generate all positions in the grid (in a logical order for a backward walk)
		aAllPos = []

		# Fill the grid by rows (Y first, then X)
		for j = nMaxY to nMinY step -1
			for i = nMaxX to nMinX step -1
				aAllPos + [ i, j ]
			next
		next

		# Find the positions in the list
		oStzList = new stzList(aAllPos)
		n1 = oStzList.FindFirst(@anStartPos)

		if n1 = 0  # If start position not found, return empty list
			return []
		ok

		# Check if pSteps is a number or a list
		if isNumber(@Steps)
			nMaxSteps = len(aAllPos) - n1 + 1
			for i = n1 to len(aAllPos) step @Steps
				aResult + aAllPos[i]
			next
		else
			# Use cyclic list of steps
			currentStep = 1
			i = n1

			while i <= len(aAllPos)
				aResult + aAllPos[i]

				# Get the current step from the list
				stepSize = @Steps[currentStep]

				# Move to next position
				i += stepSize

				# Move to next step in the cycle
				currentStep++
				if currentStep > len(@Steps)
					currentStep = 1
				ok
			end
		ok

		return aResult

	  #------------------#
	 #   GENERAL INFO   #
	#------------------#

	def Content()
		return This.WalkablePositions()

		def Value()
			return Content()

	def Copy()
		return new stzWalker2D(@anStartPos, @anEndPos, @Steps)

	def StartPosition()
		return @anStartPos

		def StartingPosition()
			return This.StartPosition()

		def Start()
			return This.StartPosition()

	def EndPosition()
		return @anEndPos

		def EndingPosition()
			return This.EndPosition()

		def Endd()
			return This.EndPosition()

	def Steps()
		return @Steps

	def CurrentPosition()
		return @aCurrPosition

	def SetCurrentPosition(pnX, pnY)

		if NOT This.IsWalkable(pnX, pnY)
			StzRaise("Incorrect params! [ " + pnX + ", " + pnY + " ] do not correspond to a walkable position.")
		ok

		@aCurrPosition = [ pnX, pnY ]

	  #---------------------#
	 #  Getting Direction  #
	#---------------------#

	def Direction()
		return @cDirection

		def CurrentDirection()
			return This.Direction()

	  #-----------------------------------------------------#
	 #  POSITIONS, WALKED POSITIONS & UNWALKED POSITIONS   #
	#-----------------------------------------------------#

	def Positions()

		aResult = []

		# If direction is backward, swap the positions pairs

		if @cDirection = :Backward

			_anTemp_ = @anStartPos
			@anStartPos = @anEndPos
			@anEndPos = _anTemp_

		ok

		nX1 = @anStartPos[1]
		nY1 = @anStartPos[2]
		nX2 = @anEndPos[1]
		nY2 = @anEndPos[2]

		# Generate all positions in a list

		aAllPos = []

		for j = 1 to nY2
			for i = 1 to nX2
				aAllPos + [i,j]
			next
		next

		# Find the start position in the list

		oStzList = new stzList(aAllPos)
		n1 = oStzList.FindFirst(@anStartPos)
		n2 = len(aAllPos)

		# Construct the walker positions

		for i = n1 to n2
			aResult + aAllPos[i]
		next

		return aResult

	def NumberOfPositions()
		return len(This.Positions())

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
		aResult = StzListQ(This.Positions()).RemoveManyQ(This.Walkables()).Content()
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

		# Setting the walk on current position

		aResult = []
		aResult + This.CurrentPosition()

		# Handle edge case

		if nLenRemaining = 0
			return aResult
		ok
		
		if n > nLenRemaining
			n = nLenRemaining  # Walk as far as possible
		ok
		
		# Add the next n positions
		for i = 1 to n
			aResult + aRemaining[i]
		next
		
		# Update current position and history
		if len(aResult) > 1
			@aCurrPosition = aResult[len(aResult)]
			@aWalkHistory + aResult
		ok
		
		return aResult
		
		def WalkN(n)
			return This.WalkNSteps(n)

	def WalkTo(pnX, pnY)

		if NOT This.IsWalkable(pnX, pnY)
			StzRaise("Can't walk! The position [" + pnX + "," + pnY + "] is not walkable.")
		ok
		
		aTarget = [pnX, pnY]
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
		
		def WalkToPosition(pnX, pnY)
			return This.WalkTo(pnX, pnY)

	def WalkToFirst()
		aWalkables = This.Walkables()

		if len(aWalkables) = 0
			StzRaise("No walkable positions available!")
		ok

		aPos = aWalkables[1]
		return This.WalkTo(aPos[1], aPos[2])

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

		aPos = aWalkables[len(aWalkables)]
		return This.WalkTo(aPos[1], aPos[2])

		def WalkToLastPosition()
			return This.WalkToLast()

		def WalkToLastWalkable()
			return This.WalkToLast()

		def WalkToLastWalkablePosition()
			return This.WalkToLast()
			
		def WalkToEnd()
			return This.WalkToLast()

	  #--------------------------------------#
	 #  CHECKING IF A POSITION IS WALKABLE  #
	#--------------------------------------#

	def IsWalkable(pnX, pnY)
		if CheckParams()
			if not (isNumber(pnX) and isNumber(pnY))
				StzRaise("Incorrect prams types! pnX and pnY must be both numbers.")
			ok
		ok

		# Check if position exists in walkables
		return This._ListContains(@aWalkables, [pnX, pnY])

		def IsWalkablePosition(pnX, pnY)
			return This.IsWalkable(pnX, pnY)

	  #----------------------------------------#
	 #  CHECKING IF A POSITION IS UNWALKABLE  #
	#----------------------------------------#

	def IsUnwalkable(pnX, pnY)

		if NOT (isNumber(pnX) and isNumber(pnY))
			StzRaise("Incorrect params types! pnX and pnY must be both numbers.")
		ok
		
		# Check if position exists in boundary but not in walkables
		aAllPositions = This.Positions()
		
		return (This._ListContains(aAllPositions, [pnX, pnY]) and NOT This.IsWalkable(pnX, pnY))

		def IsUnwalkablePosition(pnX, pnY)
			return This.IsUnwalkable(pnX, pnY)

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
		@aCurrPosition = [@anStartPos[1], @anStartPos[2]]
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

		if NOT This.IsWalkable(panStart[1], panStart[2])
				StzRaise("Can't walk between the positions! Start position [" + panStart[1] + "," + panStart[2] + "] is not walkable.")
		ok

		if NOT This.IsWalkable(panEnd[1], panEnd[2])
			StzRaise("Can't walk between the positions! End position [" + panEnd[1] + "," + panEnd[2] + "] is not walkable.")
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

	  #---------------------------------#
	 #  VISUALIZING THE GRID AND WALK  #
	#---------------------------------#

	def Show()
		? This.ToString()

	def ToString()

		# Calculate the actual grid bounds we need to display

		nMinX = 1 # Always start from 1
		nMaxX = max([@anStartPos[1], @anEndPos[1]])
		nMinY = 1 # Always start from 1
		nMaxY = max([@anStartPos[2], @anEndPos[2]])
	
		# Determine grid size based on the boundaries

		nGridWidth = nMaxX - nMinX + 1
		nGridHeight = nMaxY - nMinY + 1
	
		# Create an empty grid filled with "."

		aGrid = newlist(nGridHeight, nGridWidth)
		for y = 1 to nGridHeight
			for x = 1 to nGridWidth
				aGrid[y][x] = "."
			next
		next
	
		# Mark walkable positions with "o"

		nLen = len(@aWalkables)
		for i = 1 to nLen
			nPosX = @aWalkables[i][1] - nMinX + 1
			nPosY = @aWalkables[i][2] - nMinY + 1
			aGrid[nPosY][nPosX] = "o"
		next
	
		# Mark start and end positions (these override
		# any walkable markers)

		nStartX = @anStartPos[1] - nMinX + 1
		nStartY = @anStartPos[2] - nMinY + 1
		nEndX = @anEndPos[1] - nMinX + 1
		nEndY = @anEndPos[2] - nMinY + 1

		aGrid[nStartY][nStartX] = "S"
		aGrid[nEndY][nEndX] = "E"
	
		# Mark current position with "x" (this overrides
		# any other marker)

		nCurrX = @aCurrPosition[1] - nMinX + 1
		nCurrY = @aCurrPosition[2] - nMinY + 1

		aGrid[nCurrY][nCurrX] = "x"
	
		# Convert grid to string representation

		sResult = ""
	
		# Add X-axis labels

		sResult += "    "
		for x = nMinX to nMaxX
			sResult += ""+ (x % 10) + "  "
		next
		sResult += NL
	
		# Add top border with rounded corners with
		# indicator for current X position

		sResult += "  ╭"
		for x = 1 to nGridWidth
			if x = nCurrX
				sResult += "─v─"
			else
				sResult += "───"
			ok
		next
		sResult += "╮" + NL
	
		# Add rows with Y-axis labels and borders

		for y = 1 to nGridHeight
			# Add Y indicator for current position
			if y = nCurrY
				sResult += ""+ (y % 10) + " >"
			else
				sResult += ""+ (y % 10) + " │"
			ok
			
			for x = 1 to nGridWidth
				sResult += " " + aGrid[y][x] + " "
			next
			sResult += "│" + NL
		next
	
		# Add bottom border with rounded corners

		sResult += "  ╰"
		for x = 1 to nGridWidth
			sResult += "───"
		next
		sResult += "╯"
	
		return sResult

		def Stringified()
			return This.ToString()

		def Stringify()
			return This.ToString()

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
