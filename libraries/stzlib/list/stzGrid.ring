#------------------------------------------------------
#
# Project : Softanza
# File    : stzgrid.ring
# Author  : Mansour Ayouni (2025)
#
# Description : A positional construct for navigating
# grid-like objects (1-indexed)
#
#------------------------------------------------------

func StzGridQ(panColRow)
	return new stzGrid(panColRow)

	func StzGrid(panColRow)
		return new stzGrid(panColRow)

Class stzGrid From stzObject
	/*
	The stzGrid class is a positional construct for navigating
	# grid-like objects. It doesn't host data itself but provides
	# ways to move in grid-like structures in various directions:
	# forward, backward, up, down, left, right.

	The grid is one-based, meaning positions start from (1,1)
	at the top-left corner.
	*/

	@nRows
	@nCols

	@nCurrentRow
	@nCurrentCol

	@cDirection = :Forward # :Forward, :Backward, :Left, :Right, :Up, :Down

	@aObstacles = []
	@aPath = []
	@cObstacleChar = "■"
	@cPathChar = "○" // "●"

	@cCurrentChar = "x"
	@cEmptyChar = "."
	@cNeighborChar = "N"

	@cRightChar = "x"
	@cLeftChar = "x"
	@cUpChar = "x"
	@cDownChar = "x"

	@bShowCoordinates = TRUE
	@bShowObstacles = TRUE
	@bShowPath = TRUE


	def init(panColRow)

		if NOT (isList(panColRow) and len(panColRow) = 2 and
			isNumber(panColRow[1]) and isNumber(panColRow[2]) )

			stzRaise("Incorrect param type! panColRow must be a pair of numbers.")
		ok
		
		@nCols = panColRow[1]
		@nRows = panColRow[2]

		# Initialize position to (1,1)

		@nCurrentRow = 1
		@nCurrentCol = 1
	
	#-- INFORMATION METHODS

	def Size()
		return @nCols * @nRows

		def NumberOfNodes()
			return This.Size()

	def SizeXT()
		return [ @nCols, @nRows ]

	def NumberOfColumns()
		return @nCols
	
	def NumberOfRows()
		return @nRows
		
	def CurrentPosition()
		return [ @nCurrentCol, @nCurrentRow ]

		def Position()
			return This.CurrentPosition()

	def CurrentColumn()
		return @nCurrentCol

	def CurrentRow()
		return @nCurrentRow
		
	def IsValidPosition(nCol, nRow)

		if nCol >= 1 and nCol <= @nCols and
		   nRow >= 1 and nRow <= @nRows

			return TRUE
		else
			return FALSE
		ok

	def IsCurrentPositionValid() # For debugging purposes
		return IsValidPosition( @nCurrentCol, @nCurrentRow)
		
	#-- CONFIGURATION
	
	def Direction()
		return @cDirection
		
	def SetDirection(cDirection)
		cDirection = lower(cDirection)
		
		if cDirection = :forward or 
		   cDirection = :backward or 
		   cDirection = :left or 
		   cDirection = :right or 
		   cDirection = :up or 
		   cDirection = :down
			@cDirection = cDirection

		else
			stzRaise("Invalid direction! Valid options are: :forward, :backward, :left, :right, :up, :down")
		ok

		
	#-- MOVEMENT METHODS
	
	def MoveToNode(nCol, nRow)
		if IsValidPosition(nCol, nRow)
			@nCurrentCol = nCol
			@nCurrentRow = nRow

		else
			stzRaise("Invalid position! Column must be between 1 and " + @nCols + 
			         ", and row between 1 and " + @nRows + ".")
		ok

		def Moveto(nCol, nRow)
			This.MoveToNode(nCol, nRow)
		
	def MoveToFirstNode()
		This.MoveToNode(1, 1)
		
		def MovetoFirstPosition()
			This.MoveToNode(1, 1)

	def MoveToLastNode()
		This.MoveTo(@nCols, @nRows)
		
		def MovetoLastPosition()
			This.MoveTo(@nCols, @nRows)

	def MoveToNextNode()

		if @cDirection = :forward
			This.MoveForward()

		but @cDirection = :backward
			This.MoveBackward()

		but @cDirection = :left
			This.MoveLeft()

		but @cDirection = :right
			This.MoveRight()

		but @cDirection = :up
			This.MoveUp()

		but @cDirection = :down
			This.MoveDown()

		ok

		def MoveToNextPosition()
			This.MoveToNextNode()

	def MoveToPreviousNode()
		if @cDirection = :forward
			This.MoveBackward()

		but @cDirection = :backward
			This.MoveForward()

		but @cDirection = :left
			This.MoveRight()

		but @cDirection = :right
			This.MoveLeft()

		but @cDirection = :up
			This.MoveDown()

		but @cDirection = :down
			This.MoveUp()

		ok
		
		def MoveToPreviousPosition()
			This.MoveToPreviousNode()

	def Move(nCols, nRows)

		nNewCols = @nCurrentCol + nCols
		nNewRows = @nCurrentRow + nRows
		

		if IsValidPosition(nNewCols, nNewRows)
			@nCurrentRow = nNewRows
			@nCurrentCol = nNewCols
		ok
		
		def MoveBy(nCols, nRows)
			This.Move(nCols, nRows)

		def MoveByNColsNRows(nCols, nRows)
			This.Move(nCols, nRows)

	def MoveForward()
		@cDirection = :Forward
		
		nNewCol = @nCurrentCol + 1
		if nNewCol <= @nCols
			@nCurrentCol = nNewCol

		else
			nNewRow = @nCurrentRow + 1

			if nNewRow <= @nRows
				@nCurrentRow = nNewRow
				@nCurrentCol = 1
			ok

		ok
		
	def MoveBackward()
		@cDirection = :Backward
		
		nNewCol = @nCurrentCol - 1
		if nNewCol >= 1
			@nCurrentCol = nNewCol
			return self
		else
			nNewRow = @nCurrentRow - 1
			
			if nNewRow >= 1
				@nCurrentRow = nNewRow
				@nCurrentCol = @nCols

			ok

		ok
		
	def MoveRight()
		@cDirection = :Right
		
		nNewCol = @nCurrentCol + 1
		
		if nNewCol <= @nCols
			@nCurrentCol = nNewCol
		ok
		
	def MoveLeft()
		@cDirection = :Left
		
		nNewCol = @nCurrentCol - 1
	
		if nNewCol >= 1
			@nCurrentCol = nNewCol
		ok
		
	def MoveUp()
		@cDirection = :Up
		
		nNewRow = @nCurrentRow - 1
		
		if nNewRow >= 1
			@nCurrentRow = nNewRow
		ok
		
	def MoveDown()
		@cDirection = :Down
		
		nNewRow = @nCurrentRow + 1
		
		if nNewRow <= @nRows
			@nCurrentRow = nNewRow
		ok
		
	#-- TRAVERSAL METHODS
	
	def Nodes()
		aResult = []
		
		for i = 1 to @nCols
			for j = 1 to @nRows
				aResult +  [i, j]
			next
		next
		
		return aResult
		
		def Positions()
			return This.Positions()

	def ForEachPosition(pCode)
		for i = 1 to @nRows
			for j = 1 to @nCols
				@nCurrentRow = i
				@nCurrentCol = j
				call pCode(i, j)
			next
		next
		
	def TraverseInDirection(cDirection, pCode)
		oTemp = new stzGrid([@nCols, @nRows])
		oTemp.MoveTo(@nCurrentCol, @nCurrentRow)
		oTemp.SetDirection(cDirection)
		
		while TRUE
			nRow = oTemp.CurrentRow()
			nCol = oTemp.CurrentColumn()
			
			call pCode(nCol, nRow)
			
			# Try to move to next position
			oNext = oTemp.MoveToNextPosition()
			if oNext = NULL
				# Reached the boundary in NoWrap mode
				exit
			ok
			
		end
		
	#-- NEIGHBORS & RELATIVE POSITIONS

	def Neighbors()
		aResult = []
		
		# Check each of the 8 neighbors

		aDirections = [
			[-1,-1], [-1,0], [-1,1], 
		      	[0,-1],          [0,1],
		     	[1,-1],  [1,0],  [1,1]
		]
		
		nLen = len(aDirections)

		for i = 1 to nLen
			nRow = @nCurrentRow + aDirections[i][1]
			nCol = @nCurrentCol + aDirections[i][2]
			
			if IsValidPosition(nCol, nRow)
				aResult +  [nCol, nRow]
			ok
		next
		
		return aResult
		
		def AdjacentNodes()
			return This.Neighbors()
		
		def AdjacentNeighbors()
			return This.Neighbors()

		def AdjacentPositions()
			return This.Neighbors()
def PaintNeighbors()
	This.PaintNodes(This.Neighbors(), @cNeighborChar)

	def NodeAbove()

		nCol = @nCurrentCol
		nRow = @nCurrentRow - 1
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position above the current position!")
		ok

		def PositionAbove()
			return This.NodeAbove()

	def NodeAboveLeft()

		nCol = @nCurrentCol - 1
		nRow = @nCurrentRow - 1
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position above the current position!")
		ok

		def PositionAboveLeft()
			return This.NodeAboveLeft()

	def NodeAboveRight()

		nCol = @nCurrentCol + 1
		nRow = @nCurrentRow - 1
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position above the current position!")
		ok

		def PositionAboveRight()
			return This.NodeAboveRight()

	def NodeBelow()

		nCol = @nCurrentCol
		nRow = @nCurrentRow + 1
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position below the current position!")
		ok
		
		def PositionBelow()
			return This.NodeBelow()

	def NodeBelowLeft()

		nCol = @nCurrentCol - 1
		nRow = @nCurrentRow + 1
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position below the current position!")
		ok

		def PositionBelowLeft()
			return This.NodeBelowLeft()

	def NodeBelowRight()

		nCol = @nCurrentCol + 1
		nRow = @nCurrentRow + 1
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position below the current position!")
		ok

		def PositionBelowRight()
			return This.NodeBelowRight()

	def NodeToLeft()

		nCol = @nCurrentCol - 1
		nRow = @nCurrentRow
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position to the left of the current position!")
		ok
		
		def PositionToLeft()
			return This.NodeToLeft()

	def NodeToRight()

		nCol = @nCurrentCol + 1
		nRow = @nCurrentRow
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position to the right of the current position!")
		ok
		
		def PositionToRight()
			return This.NodeToRight()

	def DistanceTo(nCol, nRow)
		# Manhattan distance (L1 norm)
		nResult = abs(@nCurrentCol - nCol) + abs(@nCurrentRow - nRow)
		return nResult
		
		def DistanceToNode(nCol, nRow)
			return This.DistanceTo(nCol, nRow)

		def ManhattanDistanceTo(nCol, nRow)
			return This.DistanceTo(nCol, nRow)

		def ManhattanDistanceToNode(nCol, nRow)
			return This.DistanceTo(nCol, nRow)

	def EuclideanDistanceTo(nCol, nRow)
    		# Euclidean distance (L2 norm)

		nDeltaCol = nCol - @nCurrentCol
		nDeltaRow = nRow - @nCurrentRow

		# Calculate using Pythagorean theorem
		nResult = ring_sqrt( nDeltaCol * nDeltaCol + nDeltaRow * nDeltaRow )

		return nResult

		def EuclideanDistanceToNode(nCol, nRow)
			return This.EuclideanDistanceTo(nCol, nRow)

		def EucDistanceTo(nCol, nRow)
			return This.EuclideanDistanceTo(nCol, nRow)

		def EucDistTo(nCol, nRow)
			return This.EuclideanDistanceTo(nCol, nRow)

	#-- ENHANCED N-NODE MOVEMENT METHODS
	
	def MoveNNodes(n)
		for i = 1 to n
			This.MoveToNextNode()
		next
		
		def MoveNPositions(n)
			This.MoveNNodes(n)
	
	def MoveForwardNNodes(n)
		oldDirection = @cDirection
		@cDirection = :Forward
		
		for i = 1 to n
			This.MoveForward()
		next
		
		@cDirection = oldDirection
		
		def MoveForwardNPositions(n)
			This.MoveForwardNNodes(n)
	
	def MoveBackwardNNodes(n)
		oldDirection = @cDirection
		@cDirection = :Backward
		
		for i = 1 to n
			This.MoveBackward()
		next
		
		@cDirection = oldDirection
		
		def MoveBackwardNPositions(n)
			This.MoveBackwardNNodes(n)
	
	def MoveLeftNNodes(n)
		oldDirection = @cDirection
		@cDirection = :Left
		
		for i = 1 to n
			This.MoveLeft()
		next
		
		@cDirection = oldDirection
		
		def MoveLeftNPositions(n)
			This.MoveLeftNNodes(n)
	
	def MoveRightNNodes(n)
		oldDirection = @cDirection
		@cDirection = :Right
		
		for i = 1 to n
			This.MoveRight()
		next
		
		@cDirection = oldDirection
		
		def MoveRightNPositions(n)
			This.MoveRightNNodes(n)
	
	def MoveUpNNodes(n)
		oldDirection = @cDirection
		@cDirection = :Up
		
		for i = 1 to n
			This.MoveUp()
		next
		
		@cDirection = oldDirection
		
		def MoveUpNPositions(n)
			This.MoveUpNNodes(n)
	
	def MoveDownNNodes(n)
		oldDirection = @cDirection
		@cDirection = :Down
		
		for i = 1 to n
			This.MoveDown()
		next
		
		@cDirection = oldDirection
		
		def MoveDownNPositions(n)
			This.MoveDownNNodes(n)
	
	def MoveToNextNthNode(n)
		This.MoveNNodes(n)
		
		def MoveToNextNthPosition(n)
			This.MoveToNextNthNode(n)
	
	def MoveToPreviousNthNode(n)
		for i = 1 to n
			This.MoveToPreviousNode()
		next
		
		def MoveToPreviousNthPosition(n)
			This.MoveToPreviousNthNode(n)
	
	#-- ENHANCED N-NODE RELATIVE POSITION METHODS
	
	def NextNthNode(n)
		# Save current position
		nOldCol = @nCurrentCol
		nOldRow = @nCurrentRow
		cOldDirection = @cDirection
		
		# Move n steps in current direction
		This.MoveNNodes(n)
		
		# Get the resulting position
		nCol = @nCurrentCol
		nRow = @nCurrentRow
		
		# Restore original position
		@nCurrentCol = nOldCol
		@nCurrentRow = nOldRow
		@cDirection = cOldDirection
		
		# Return the calculated position
		return [nCol, nRow]
		
		def NextNthPosition(n)
			return This.NextNthNode(n)
	
	def PreviousNthNode(n)
		# Save current position
		nOldCol = @nCurrentCol
		nOldRow = @nCurrentRow
		cOldDirection = @cDirection
		
		# Move n steps in reverse direction
		for i = 1 to n
			This.MoveToPreviousNode()
		next
		
		# Get the resulting position
		nCol = @nCurrentCol
		nRow = @nCurrentRow
		
		# Restore original position
		@nCurrentCol = nOldCol
		@nCurrentRow = nOldRow
		@cDirection = cOldDirection
		
		# Return the calculated position
		return [nCol, nRow]
		
		def PreviousNthPosition(n)
			return This.PreviousNthNode(n)
	
	def NthNodeAbove(n)
		nCol = @nCurrentCol
		nRow = @nCurrentRow - n
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position " + n + " nodes above the current position!")
		ok
		
		def NthPositionAbove(n)
			return This.NthNodeAbove(n)
	
	def NthNodeBelow(n)
		nCol = @nCurrentCol
		nRow = @nCurrentRow + n
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position " + n + " nodes below the current position!")
		ok
		
		def NthPositionBelow(n)
			return This.NthNodeBelow(n)
	
	def NthNodeToLeft(n)
		nCol = @nCurrentCol - n
		nRow = @nCurrentRow
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position " + n + " nodes to the left of the current position!")
		ok
		
		def NthPositionToLeft(n)
			return This.NthNodeToLeft(n)
	
	def NthNodeToRight(n)
		nCol = @nCurrentCol + n
		nRow = @nCurrentRow
		
		if IsValidPosition(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid position " + n + " nodes to the right of the current position!")
		ok
		
		def NthPositionToRight(n)
			return This.NthNodeToRight(n)
	
	#-- MOVEMENT TO NTH NODE IN SPECIFIC DIRECTION
	
	def MoveToNthNodeAbove(n)
		nCol = @nCurrentCol
		nRow = @nCurrentRow - n
		
		if IsValidPosition(nCol, nRow)
			@nCurrentRow = nRow
		else
			StzRaise("No valid position " + n + " nodes above the current position!")
		ok
		
		def MoveToNthPositionAbove(n)
			This.MoveToNthNodeAbove(n)
	
	def MoveToNthNodeBelow(n)
		nCol = @nCurrentCol
		nRow = @nCurrentRow + n
		
		if IsValidPosition(nCol, nRow)
			@nCurrentRow = nRow
		else
			StzRaise("No valid position " + n + " nodes below the current position!")
		ok
		
		def MoveToNthPositionBelow(n)
			This.MoveToNthNodeBelow(n)
	
	def MoveToNthNodeToLeft(n)
		nCol = @nCurrentCol - n
		nRow = @nCurrentRow
		
		if IsValidPosition(nCol, nRow)
			@nCurrentCol = nCol
		else
			StzRaise("No valid position " + n + " nodes to the left of the current position!")
		ok
		
		def MoveToNthPositionToLeft(n)
			This.MoveToNthNodeToLeft(n)
	
	def MoveToNthNodeToRight(n)
		nCol = @nCurrentCol + n
		nRow = @nCurrentRow
		
		if IsValidPosition(nCol, nRow)
			@nCurrentCol = nCol
		else
			StzRaise("No valid position " + n + " nodes to the right of the current position!")
		ok
		
		def MoveToNthPositionToRight(n)
			This.MoveToNthNodeToRight(n)

#----------------------------

	#-- OBSTACLES MANAGEMENT
	
	def AddObstacle(nCol, nRow)
		if NOT IsValidPosition(nCol, nRow)
			stzRaise("Invalid position for obstacle!")
		ok
		
		if NOT This.IsObstacle(nCol, nRow)
			@aObstacles + [nCol, nRow]
		ok
		
	def AddObstacles(aPositions)
		for i = 1 to len(aPositions)
			if isList(aPositions[i]) and len(aPositions[i]) = 2
				This.AddObstacle(aPositions[i][1], aPositions[i][2])
			ok
		next
		
	def RemoveObstacle(nCol, nRow)
		for i = 1 to len(@aObstacles)
			if @aObstacles[i][1] = nCol and @aObstacles[i][2] = nRow
				del(@aObstacles, i)
				return
			ok
		next
		
	def ClearObstacles()
		@aObstacles = []
		
		def RemoveObstacles()
			@aObstacles = []

	def IsObstacle(nCol, nRow)
		for i = 1 to len(@aObstacles)
			if @aObstacles[i][1] = nCol and @aObstacles[i][2] = nRow
				return TRUE
			ok
		next
		return FALSE

	def AreObstacles(panColRow)
		if CheckParams(panColRow)
			if NOT (isList(panColRow) and IsListOfPairsOfNumbers(panColRow))
				StzRaise("Incorrect param type! panColrow must be a list of pairs of numbers.")
			ok
		ok

		nLen = len(panColRow)
		bResult = TRUE

		for i = 1 to nLen
			if NOT This.IsObstacle(panColRow[1], panColRow[2])
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def SetObstacleChar(cChar)
		if isString(cChar) and @IsChar(cChar)
			@cObstacleChar = cChar
		else
			stzRaise("Obstacle character must be a single character!")
		ok
		
	def ObstacleChar()
		return @cObstacleChar
		
	def Obstacles()
		return @aObstacles
	
	#-- PATH MANAGEMENT

	def AddPath(panColRow)

		if CheckParams()
			if NOT isList(panColRow) and IsListOfPairsOfNumbers(panColRow)
				StzRaise("Incorrect param type! panColRow must be a list of pairs of numbers.")
			ok
		ok

		nLen = len(panColRow)

		for i = 1 to nLen
			@aPath + [ panColRow[i][1], panColRow[i][2] ]
		next

		def AddPathNodes(panColRow)
			This.AddPath(panColRow)

	def AddPathNode(nCol, nRow)
		if NOT IsValidPosition(nCol, nRow)
			stzRaise("Invalid position for path node!")
		ok
		
		@aPath + [nCol, nRow]
		
	def ClearPath()
		@aPath = []
		
		def RemovePath()
			@aPath = []

	def Path()
		return @aPath
		
	def PathLength()
		return len(@aPath)
		
		def PathLen()
			return len(@aPath)

	def SetPathChar(cChar)
		if isString(cChar) and IsChar(cChar)
			@cPathChar = cChar
		else
			stzRaise("Path character must be a single character!")
		ok
		
	def PathChar()
		return @cPathChar
		
	def SetCurrentChar(cChar)
		if isString(cChar) and IsChar(cChar)
			@cCurrentChar = cChar
		else
			stzRaise("Current position character must be a single character!")
		ok
		
	def CurrentChar()
		return @cCurrentChar
		
	def SetEmptyChar(cChar)
		if isString(cChar) and IsChar(cChar)
			@cEmptyChar = cChar
		else
			stzRaise("Empty cell character must be a single character!")
		ok
		
	def EmptyChar()
		return @cEmptyChar
		
	#-- VISUALIZATION CONTROLS
	
	def ShowCoordinates(lShow)
		@bShowCoordinates = lShow
		
	def ShowObstacles(lShow)
		@bShowObstacles = lShow
		
	def ShowPath(lShow)
		@bShowPath = lShow
			
	#-- PATH FINDING ALGORITHMS

	def ShortestPath(panStart, panEnd)
		# Implementation of A* algorithm for path finding

		if CheckParams()
			if NOT (isList(panStart) and IsPairOfNumbers(panStart) and
				isList(panEnd) and IsPairOfNumbers(panEnd))

				StzRaise("Incorrect param type! panStart and panEnd must be pairs of numbers.")

			ok
		ok

		nStartCol = panStart[1]
		nStartRow = panStart[2]
		nEndCol = panEnd[1]
		nEndRow = panEnd[2]
		
		# Validate positions

		if NOT IsValidPosition(nStartCol, nStartRow)
			StzRaise("Invalid start position!")
		ok
		
		if NOT IsValidPosition(nEndCol, nEndRow)
			StzRaise("Invalid end position!")
		ok
		
		# Check if start or end is an obstacle

		if This.IsObstacle(nStartCol, nStartRow)
			stzRaise("Start position is an obstacle!")
		ok
		
		if This.IsObstacle(nEndCol, nEndRow)
			stzRaise("End position is an obstacle!")
		ok
		
		# Initialize data structures

		aOpenSet = []          # Nodes to be evaluated
		aClosedSet = []        # Nodes already evaluated
		aCameFrom = []         # Map to reconstruct path
		aGScore = []           # Cost from start to current node
		aFScore = []           # Estimated total cost from start to goal through current node
		
		# Initialize with start position

		aOpenSet + [nStartCol, nStartRow]
		
		# Initialize gScore with infinity for all positions

		for i = 1 to @nRows
			for j = 1 to @nCols
				aGScore + [[j, i], 999999]
				aFScore + [[j, i], 999999]
			next
		next
		
		# Set scores for start position

		This.SetScoreAt(aGScore, nStartCol, nStartRow, 0)
		This.SetScoreAt(aFScore, nStartCol, nStartRow, This.HeuristicCost([nStartCol, nStartRow], [nEndCol, nEndRow]))
		
		# Main loop

		while len(aOpenSet) > 0

			# Get node with lowest fScore

			nCurrentIdx = This.LowestFScore(aOpenSet, aFScore)
			nCurrentCol = aOpenSet[nCurrentIdx][1]
			nCurrentRow = aOpenSet[nCurrentIdx][2]
			
			# Check if we reached the goal

			if nCurrentCol = nEndCol and nCurrentRow = nEndRow
				# Reconstruct path
				@aPath = This.ReconstructPath(aCameFrom, nCurrentCol, nCurrentRow)
				return @aPath
			ok
			
			# Remove current from open set and add to closed set

			del(aOpenSet, nCurrentIdx)
			aClosedSet + [nCurrentCol, nCurrentRow]
			
			# Check all neighbors

			aNeighbors = This.WalkableNeighbors(nCurrentCol, nCurrentRow)
			
			for i = 1 to len(aNeighbors)
				nNeighborCol = aNeighbors[i][1]
				nNeighborRow = aNeighbors[i][2]
				
				# Skip if neighbor is in closed set

				if This.IsInList(aClosedSet, nNeighborCol, nNeighborRow)
					loop
				ok
				
				# Calculate tentative gScore

				nTentativeGScore = This.GetScoreAt(aGScore, nCurrentCol, nCurrentRow) + 1
				
				# Check if neighbor is not in open set

				if NOT This.IsInList(aOpenSet, nNeighborCol, nNeighborRow)
					aOpenSet + [nNeighborCol, nNeighborRow]

				but nTentativeGScore >= This.GetScoreAt(aGScore, nNeighborCol, nNeighborRow)
					# Not a better path
					loop
				ok
				
				# This path is better, record it

				aCameFrom = This.SetCameFrom(aCameFrom, nNeighborCol, nNeighborRow, nCurrentCol, nCurrentRow)
				This.SetScoreAt(aGScore, nNeighborCol, nNeighborRow, nTentativeGScore)
				This.SetScoreAt(aFScore, nNeighborCol, nNeighborRow, 
					nTentativeGScore + This.HeuristicCost([nNeighborCol, nNeighborRow], [nEndCol, nEndRow]))
			next
		end
		
		# No path found

		return []

	def ManhattanPathXT(panStart, panEnd, cOption)
		if chekParams()
			if NOT isString(cOption)
				StzRaise("Incorrect param type! cOption must be a string.")
			ok
		ok

		if cOption = :HorizontalFirst or cOption = :Horizontal
			return This.ManhattanPath(panStart, panEnd)

		but cOption = :VerticalFirst or cOption = :Vertical
			return This.ManhattanPathVerticalFirst(panStart, panEnd)

		else
			StzRaise("Incorrect param value! cOption must be either :VerticalFirst or :HorizontalFirst.")
		ok

	def ManhattanPath(panStart, panEnd)
		# Creates a Manhattan path (horizontal then vertical)

		if CheckParams()
			if NOT (isList(panStart) and IsPairOfNumbers(panStart) and
				isList(panEnd) and IsPairOfNumbers(panEnd))

				StzRaise("Incorrect param type! panStart and panEnd must be pairs of numbers.")

			ok
		ok

		nStartCol = panStart[1]
		nStartRow = panStart[2]
		nEndCol = panEnd[1]
		nEndRow = panEnd[2]

		# Validate positions

		if NOT IsValidPosition(nStartCol, nStartRow)
			stzRaise("Invalid start position!")
		ok
		
		if NOT IsValidPosition(nEndCol, nEndRow)
			stzRaise("Invalid end position!")
		ok
		
		# Clear existing path

		This.ClearPath()
		
		# Start from start position

		This.AddPathNode(nStartCol, nStartRow)
		
		# Current position

		nCurrentCol = nStartCol
		nCurrentRow = nStartRow
		
		# First move horizontally

		while nCurrentCol != nEndCol

			if nCurrentCol < nEndCol
				nCurrentCol++
			else
				nCurrentCol--
			ok
			
			# Check for obstacle

			if This.IsObstacle(nCurrentCol, nCurrentRow)

				# Try going around by moving vertically first
				return This.FindManhattanPathVerticalFirst(nStartCol, nStartRow, nEndCol, nEndRow)
			ok
			
			This.AddPathNode(nCurrentCol, nCurrentRow)
		end
		
		# Then move vertically

		while nCurrentRow != nEndRow
			if nCurrentRow < nEndRow
				nCurrentRow++
			else
				nCurrentRow--
			ok
			
			# Check for obstacle

			if This.IsObstacle(nCurrentCol, nCurrentRow)

				# If we hit an obstacle, use A* algorithm for the rest of the path

				aPartialPath = This.ShortestPath(nCurrentCol, nCurrentRow - @IF(nCurrentRow > nEndRow, 1, -1), nEndCol, nEndRow)
				
				# Remove first node to avoid duplication

				if len(aPartialPath) > 0
					del(aPartialPath, 1)
				ok
				
				# Add the rest of the path

				for i = 1 to len(aPartialPath)
					This.AddPathNode(aPartialPath[i][1], aPartialPath[i][2])
				next
				
				return @aPath
			ok
			
			This.AddPathNode(nCurrentCol, nCurrentRow)
		end
		
		return @aPath

		def ManhattanPathHorizontalFirst(panStart, panEnd)
			return This.ManhattanPath(panStart, panEnd)

	def ManhattanPathVerticalFirst(panStart, panEnd)
		# Creates a Manhattan path (vertical then horizontal)

		if CheckParams()
			if NOT (isList(panStart) and IsPairOfNumbers(panStart) and
				isList(panEnd) and IsPairOfNumbers(panEnd))

				StzRaise("Incorrect param type! panStart and panEnd must be pairs of numbers.")

			ok
		ok

		nStartCol = panStart[1]
		nStartRow = panStart[2]
		nEndCol = panEnd[1]
		nEndRow = panEnd[2]
		
		# Clear existing path

		This.ClearPath()
		
		# Start from start position

		This.AddPathNode(nStartCol, nStartRow)
		
		# Current position

		nCurrentCol = nStartCol
		nCurrentRow = nStartRow
		
		# First move vertically

		while nCurrentRow != nEndRow

			if nCurrentRow < nEndRow
				nCurrentRow++
			else
				nCurrentRow--
			ok
			
			# Check for obstacle

			if This.IsObstacle(nCurrentCol, nCurrentRow)

				# Try using A* algorithm for the entire path
				return This.ShortestPath(nStartCol, nStartRow, nEndCol, nEndRow)
			ok
			
			This.AddPathNode(nCurrentCol, nCurrentRow)
		end
		
		# Then move horizontally

		while nCurrentCol != nEndCol

			if nCurrentCol < nEndCol
				nCurrentCol++
			else
				nCurrentCol--
			ok
			
			# Check for obstacle

			if This.IsObstacle(nCurrentCol, nCurrentRow)

				# If we hit an obstacle, use A* algorithm for the rest of the path
				aPartialPath = This.ShortestPath(nCurrentCol - @IF(nCurrentCol > nEndCol, 1, -1), nCurrentRow, nEndCol, nEndRow)
				
				# Remove first node to avoid duplication

				nLenPartial = len(aPartialPath)

				if nLenPartial > 0
					del(aPartialPath, 1)
				ok
				
				# Add the rest of the path

				for i = 1 to nLenPartial
					This.AddPathNode(aPartialPath[i][1], aPartialPath[i][2])
				next
				
				return @aPath
			ok
			
			This.AddPathNode(nCurrentCol, nCurrentRow)
		end
		
		return @aPath

	def SpiralPath(panStartNode, nRings)
		# Creates a spiral path starting from the given position

		if CheckParams()

			if NOT (isList(panStartNode) and IsPairOfNumbers(panStartNode))
				StzRaise("Incorrect param type! panStartNode must be a pair of numbers.")
			ok

			if isList(nRings) and StzListQ(nRings).IsRingsNamedParam()
				nRings = nRings[2]
			ok

			if NOT isNumber(nRings)
				StzRaise("Incorrect param type! nRings must be a number.")
			ok
		ok
		
		nStartCol = panStartNode[1]
		nStartRow = panStartNode[2]

		# Validate positions
		if NOT IsValidPosition(nStartCol, nStartRow)
			stzRaise("Invalid start position!")
		ok
		
		# Clear existing path
		This.ClearPath()
		
		# Start from start position
		This.AddPathNode(nStartCol, nStartRow)
		
		# Define directions: right, down, left, up
		aDirections = [[1,0], [0,1], [-1,0], [0,-1]]
		nDirIndex = 0
		
		# Current position
		nCurrentCol = nStartCol
		nCurrentRow = nStartRow
		
		# Spiral parameters
		nSteps = 1
		nStepCount = 0
		nTurnCount = 0
		
		# Create spiral path
		for i = 1 to nRings * 8  # Maximum number of steps in a spiral with nRings
			# Move in current direction
			nCurrentCol += aDirections[nDirIndex + 1][1]
			nCurrentRow += aDirections[nDirIndex + 1][2]
			
			# Check if we're still in bounds
			if NOT IsValidPosition(nCurrentCol, nCurrentRow)
				exit
			ok
			
			# Check for obstacle
			if This.IsObstacle(nCurrentCol, nCurrentRow)
				# Skip this position
				nCurrentCol -= aDirections[nDirIndex + 1][1]
				nCurrentRow -= aDirections[nDirIndex + 1][2]
				
				# Try turning
				nDirIndex = (nDirIndex + 1) % 4
				nTurnCount++
				
				# If we've tried all directions, stop
				if nTurnCount >= 4
					exit
				ok
				
				loop
			ok
			
			# Add to path
			This.AddPathNode(nCurrentCol, nCurrentRow)
			
			# Reset turn count
			nTurnCount = 0
			
			# Increment step count
			nStepCount++
			
			# Check if we need to turn
			if nStepCount = nSteps
				nStepCount = 0
				nDirIndex = (nDirIndex + 1) % 4
				
				# Increase steps every 2 turns
				if nDirIndex % 2 = 0
					nSteps++
				ok
			ok
		next
		
		return @aPath

	def ZigZagPath(panStart, panEnd, nZigZagWidth)
		# Creates a zig-zag path from start to end with the specified width

		if CheckParams()
			if NOT (isList(panStart) and IsPairOfNumbers(panStart) and
				isList(panEnd) and IsPairOfNumbers(panEnd))

				StzRaise("Incorrect param type! panStart and panEnd must be pairs of numbers.")

			ok

			if isList(nZigZagWidth) and StzListQ(nZigZagWidth).IsWidthNamedParam()
				nZigZagWidth = nZigZagWidth[2]
			ok

			if NOT isNumber(nZigZagWidth)
				StzRaise("Incorrect param type! nZigZagWidth must be a number.")
			ok
		ok

		nStartCol = panStart[1]
		nStartRow = panStart[2]
		nEndCol = panEnd[1]
		nEndRow = panEnd[2]

		# Validate positions
		if NOT IsValidPosition(nStartCol, nStartRow)
			stzRaise("Invalid start position!")
		ok
		
		if NOT IsValidPosition(nEndCol, nEndRow)
			stzRaise("Invalid end position!")
		ok
		
		# Clear existing path
		This.ClearPath()
	
		# Start from start position
		This.AddPathNode(nStartCol, nStartRow)
		
		# Current position
		nCurrentCol = nStartCol
		nCurrentRow = nStartRow
		
		# Calculate direction
		nDirCol = sign(nEndCol - nStartCol)
		nDirRow = sign(nEndRow - nStartRow)
		
		# Default to horizontal if no clear direction
		if nDirCol = 0 and nDirRow = 0
			return [nStartCol, nStartRow]
		ok
		
		# Use dominant direction for zig-zag
		lVerticalDominant = (abs(nEndRow - nStartRow) > abs(nEndCol - nStartCol))
		
		if lVerticalDominant

			# Vertical zig-zag
			nZigZag = 0
			lZigZagRight = TRUE
			
			while nCurrentRow != nEndRow
				# Move vertically
				nCurrentRow += nDirRow
				
				# Check if we're still in bounds
				if NOT IsValidPosition(nCurrentCol, nCurrentRow)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(nCurrentCol, nCurrentRow)
					# Try to go around obstacle
					if IsValidPosition(nCurrentCol + 1, nCurrentRow) and NOT This.IsObstacle(nCurrentCol + 1, nCurrentRow)
						nCurrentCol++
					but IsValidPosition(nCurrentCol - 1, nCurrentRow) and NOT This.IsObstacle(nCurrentCol - 1, nCurrentRow)
						nCurrentCol--
					else
						# Can't find a way around, use A* for the rest
						aPartialPath = This.ShortestPath(nCurrentCol, nCurrentRow - nDirRow, nEndCol, nEndRow)
						
						# Remove first node to avoid duplication
						if len(aPartialPath) > 0
							del(aPartialPath, 1)
						ok
						
						# Add the rest of the path
						for i = 1 to len(aPartialPath)
							This.AddPathNode(aPartialPath[i][1], aPartialPath[i][2])
						next
						
						return @aPath
					ok
				ok
				
				This.AddPathNode(nCurrentCol, nCurrentRow)
				
				# Zig-zag horizontally
				nZigZag++
				if nZigZag >= nZigZagWidth
					nZigZag = 0
					
					# Move horizontally in zigzag pattern
					nHorizontalSteps = @IF(lZigZagRight, 1, -1)
					
					for i = 1 to 2  # Move 2 steps horizontally
						nCurrentCol += nHorizontalSteps
						
						# Check if we're still in bounds
						if NOT IsValidPosition(nCurrentCol, nCurrentRow)
							exit
						ok
						
						# Check for obstacle
						if This.IsObstacle(nCurrentCol, nCurrentRow)
							nCurrentCol -= nHorizontalSteps
							exit
						ok
						
						This.AddPathNode(nCurrentCol, nCurrentRow)
					next
					
					lZigZagRight = NOT lZigZagRight
				ok
			end
			
			# Final horizontal movement to reach end position
			while nCurrentCol != nEndCol
				if nCurrentCol < nEndCol
					nCurrentCol++
				else
					nCurrentCol--
				ok
				
				# Check if we're still in bounds
				if NOT IsValidPosition(nCurrentCol, nCurrentRow)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(nCurrentCol, nCurrentRow)
					# Can't find a way around, use A* for the rest
					aPartialPath = This.ShortestPath(nCurrentCol - @IF(nCurrentCol > nEndCol, 1, -1), nCurrentRow, nEndCol, nEndRow)
					
					# Remove first node to avoid duplication
					if len(aPartialPath) > 0
						del(aPartialPath, 1)
					ok
					
					# Add the rest of the path
					for i = 1 to len(aPartialPath)
						This.AddPathNode(aPartialPath[i][1], aPartialPath[i][2])
					next
					
					return @aPath
				ok
				
				This.AddPathNode(nCurrentCol, nCurrentRow)
			end
		else

			# Horizontal zig-zag
			nZigZag = 0
			lZigZagDown = TRUE
			
			while nCurrentCol != nEndCol
				# Move horizontally
				nCurrentCol += nDirCol
				
				# Check if we're still in bounds
				if NOT IsValidPosition(nCurrentCol, nCurrentRow)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(nCurrentCol, nCurrentRow)
					# Try to go around obstacle
					if IsValidPosition(nCurrentCol, nCurrentRow + 1) and NOT This.IsObstacle(nCurrentCol, nCurrentRow + 1)
						nCurrentRow++
					but IsValidPosition(nCurrentCol, nCurrentRow - 1) and NOT This.IsObstacle(nCurrentCol, nCurrentRow - 1)
						nCurrentRow--
					else
						# Can't find a way around, use A* for the rest
						aPartialPath = This.ShortestPath(nCurrentCol - nDirCol, nCurrentRow, nEndCol, nEndRow)
						
						# Remove first node to avoid duplication
						if len(aPartialPath) > 0
							del(aPartialPath, 1)
						ok
						
						# Add the rest of the path
						for i = 1 to len(aPartialPath)
							This.AddPathNode(aPartialPath[i][1], aPartialPath[i][2])
						next
						
						return @aPath
					ok

				ok
				
				This.AddPathNode(nCurrentCol, nCurrentRow)
				
				# Zig-zag vertically
				nZigZag++
				if nZigZag >= nZigZagWidth
					nZigZag = 0
					
					# Move vertically in zigzag pattern
					nVerticalSteps = @if(lZigZagDown, 1, -1)
					
					for i = 1 to 2  # Move 2 steps vertically
						nCurrentRow += nVerticalSteps
						
						# Check if we're still in bounds
						if NOT IsValidPosition(nCurrentCol, nCurrentRow)
							exit
						ok
						
						# Check for obstacle
						if This.IsObstacle(nCurrentCol, nCurrentRow)
							nCurrentRow -= nVerticalSteps
							exit
						ok
						
						This.AddPathNode(nCurrentCol, nCurrentRow)
					next
					
					lZigZagDown = NOT lZigZagDown
				ok
			end
			
			# Final vertical movement to reach end position
			while nCurrentRow != nEndRow
				if nCurrentRow < nEndRow
					nCurrentRow++
				else
					nCurrentRow--
				ok
				
				# Check if we're still in bounds
				if NOT IsValidPosition(nCurrentCol, nCurrentRow)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(nCurrentCol, nCurrentRow)
					# Can't find a way around, use A* for the rest
					aPartialPath = This.ShortestPath(nCurrentCol, nCurrentRow - @IF(nCurrentRow > nEndRow, 1, -1), nEndCol, nEndRow)
					
					# Remove first node to avoid duplication
					if len(aPartialPath) > 0
						del(aPartialPath, 1)
					ok
					
					# Add the rest of the path
					for i = 1 to len(aPartialPath)
						This.AddPathNode(aPartialPath[i][1], aPartialPath[i][2])
					next
					
					return @aPath
				ok
				
				This.AddPathNode(nCurrentCol, nCurrentRow)
			end
		ok
		
		return @aPath


def DrawPath(aPathToUse, cCustomChar)
    # Store the original path character
    cOriginalPathChar = @cPathChar
    
    # Set custom path character if provided
    if cCustomChar != NULL
        @cPathChar = cCustomChar
    ok
    
    # Store the original path
    aOriginalPath = @aPath
    
    # Use the provided path if given
    if aPathToUse != NULL
        @aPath = aPathToUse
    ok
    
    # Instead of calling This.Show() directly, return the string representation
    cResult = This.ToString()
    
    # Restore original path character and path
    @cPathChar = cOriginalPathChar
    @aPath = aOriginalPath
    
    # Print the result instead of calling Show()
    ? cResult
    
    return cResult
end

	def PaintNode(nCol, nRow, cChar)
		This.PaintNodes([ [nCol, nRow] ], cChar)

	def PaintNodes(aNodes, cChar)
		# Temporarily draw nodes with the specified character
		
		if NOT (isString(cChar) and IsChar(cChar))
			stzRaise("Node character must be a single character!")
		ok
		
		# Store current path
		aOldPath = @aPath
		
		# Clear path and add nodes
		This.ClearPath()
		
		for i = 1 to len(aNodes)
			if isList(aNodes[i]) and len(aNodes[i]) = 2
				nCol = aNodes[i][1]
				nRow = aNodes[i][2]
				
				if IsValidPosition(nCol, nRow)
					This.AddPathNode(nCol, nRow)
				ok
			ok
		next
		
		# Draw with the specified character
		This.DrawPath(@aPath, cChar)
		
		# Restore original path
		@aPath = aOldPath

def PaintRegions()
    # Paint multiple regions with different characters
    aRegions = This.ConnectedRegions()
    nLen = len(aRegions)
    acChars = []
    
    for i = 1 to nLen
        # Use modulo 10 to restart numbering at 0 when it reaches 10
        acChars + (""+ (i % 10))
    next
    
    # Store current grid state
    aOldPath = @aPath
    
    # Create a temporary grid with empty cells
    aGrid = list(@nRows)
    for y = 1 to @nRows
        aGrid[y] = list(@nCols)
        for x = 1 to @nCols
            aGrid[y][x] = @cEmptyChar
        next
    next
    
    # Add obstacles to the grid
    if @bShowObstacles
        for i = 1 to len(@aObstacles)
            nObsCol = @aObstacles[i][1]
            nObsRow = @aObstacles[i][2]
            
            if IsValidPosition(nObsCol, nObsRow)
                aGrid[nObsRow][nObsCol] = @cObstacleChar
            ok
        next
    ok
    
    # Add all regions to the grid
    for i = 1 to nLen
        aRegion = aRegions[i]
        cChar = acChars[i]
        
        for j = 1 to len(aRegion)
            nCol = aRegion[j][1]
            nRow = aRegion[j][2]
            
            if IsValidPosition(nCol, nRow)
                # Skip if it's an obstacle
                if NOT This.IsObstacle(nCol, nRow)
                    aGrid[nRow][nCol] = cChar
                ok
            ok
        next
    next
    
    # Display the grid with all regions
    This.DisplayCustomGrid(aGrid)
    
    # Restore original path
    @aPath = aOldPath
end

def PaintRegionsXT(pacChars)
    # Paint multiple regions with custom characters
    # pacChars: List of characters to use for each region (optional)
    
    if CheckParams()
	if NOT (isList(pacChars) and IsListOfChars(pacChars))
		StzRaise("Incorrect param type! pacChars must be a list of chars.")
	ok
    ok

    aRegions = This.ConnectedRegions()
    nLen = len(aRegions)
    acChars = []
    
    nLenChars = len(pacChars)

    # Use provided characters or generate them
    if isList(pacChars) and nLenChars > 0
        # Use provided characters (cycling if needed)
        for i = 1 to nLen
            cChar = pacChars[(i-1) % nLenChars + 1]
            
            # Ensure each character is a single character

            
            acChars + cChar
        next
    else
        # Generate default characters (numbers 0-9 cycling)
        for i = 1 to nLen
            acChars + (""+ (i % 10))
        next
    ok
    
    # Store current grid state
    aOldPath = @aPath
    
    # Create a temporary grid with empty cells
    aGrid = list(@nRows)
    for y = 1 to @nRows
        aGrid[y] = list(@nCols)
        for x = 1 to @nCols
            aGrid[y][x] = @cEmptyChar
        next
    next
    
    # Add obstacles to the grid
    nLenObstacles = len(@aObstacles)

    if @bShowObstacles
        for i = 1 to nLenObstacles
            nObsCol = @aObstacles[i][1]
            nObsRow = @aObstacles[i][2]
            
            if IsValidPosition(nObsCol, nObsRow)
                aGrid[nObsRow][nObsCol] = @cObstacleChar
            ok
        next
    ok
    
    # Add all regions to the grid
    for i = 1 to nLen
        aRegion = aRegions[i]
        cChar = acChars[i]
        nLenRegion = len(aRegion)

        for j = 1 to nLenRegion
            nCol = aRegion[j][1]
            nRow = aRegion[j][2]
            
            if IsValidPosition(nCol, nRow)
                # Skip if it's an obstacle
                if NOT This.IsObstacle(nCol, nRow)
                    aGrid[nRow][nCol] = cChar
                ok
            ok
        next
    next
    
    # Display the grid with all regions
    This.DisplayCustomGrid(aGrid)
    
    # Restore original path
    @aPath = aOldPath

def DisplayCustomGrid(aCustomGrid)
    # Display a custom grid without changing the internal grid state
    
    cResult = ""
    
    # Add X-axis labels if requested
    if @bShowCoordinates
        cResult += "    " # Space for alignment with the grid
        for x = 1 to @nCols
            if x % 10 = 0
                cResult += "0 "
            else
                cResult += ""+ (x % 10) + " "
            ok
        next
        cResult += NL()
    ok
    
    # Add top border with rounded corners
    cResult += "  ╭"
    for x = 1 to @nCols
        if x = @nCurrentCol
            cResult += "─v─"
        else
            cResult += "──"
        ok
    next
    cResult += "╮" + NL()
    
    # Add rows with Y-axis labels and borders
    for y = 1 to @nRows
        # Add Y indicator for current position - resetting at multiples of 10
        if @bShowCoordinates
            if y % 10 = 0
                yLabel = "0"
            else
                yLabel = ""+ (y % 10)
            ok
        else
            yLabel = " "
        ok
        
        if y = @nCurrentRow
            cResult += yLabel + " > "
        else
            cResult += yLabel + " │ "
        ok
        
        for x = 1 to @nCols
            cResult += ""+ aCustomGrid[y][x] + " "
        next
        cResult += "│" + NL()
    next
    
    # Add bottom border with rounded corners
    cResult += "  ╰"
    for x = 1 to @nCols
        cResult += "──"
    next
    cResult += "─╯" + NL()
    
    ? cResult


	#-- HELPER FUNCTIONS FOR PATHFINDING

	def HeuristicCost(panStart, panEnd)

		if CheckParams()
			if NOT (isList(panStart) and IsPairOfNumbers(panStart) and
				isList(panEnd) and IsPairOfNumbers(panEnd))

				StzRaise("Incorrect param type! panStart and panEnd must be pairs of numbers.")

			ok
		ok

		nStartCol = panStart[1]
		nStartRow = panStart[2]
		nEndCol = panEnd[1]
		nEndRow = panEnd[2]

		# Manhattan distance heuristic
		return abs(nStartCol - nEndCol) + abs(nStartRow - nEndRow)

	def WalkableNeighbors(nCol, nRow)

		if CheckParams()
			if NOT (isNumber(nCol) and isNumber(nRow))
				StzRaise("Incorrect param type! nCol and nRow must be numbers.")
			ok
		ok

		# Get all valid neighbors that are not obstacles
		aNeighbors = []
		
		# Check all 4 directions (up, right, down, left)
		aDirections = [[-1,0], [0,1], [1,0], [0,-1]]
		
		for i = 1 to len(aDirections)
			nNewCol = nCol + aDirections[i][1]
			nNewRow = nRow + aDirections[i][2]
			
			if IsValidPosition(nNewCol, nNewRow) and NOT This.IsObstacle(nNewCol, nNewRow)
				aNeighbors + [nNewCol, nNewRow]
			ok
		next
		
		return aNeighbors

		def WalkableNeighborsOfNode(nCol, nRow)
			return This.WalkableNeighbors(nCol, nRow)

		def WalkableNeighborsOf(nCol, nRow)
			return This.WalkableNeighbors(nCol, nRow)
		
	def IsInList(aList, nCol, nRow)

		if CheckParams()
			if NOT isList(aList)
				StzRaise("Incorrect param type! aList must be a list.")
			ok

			if NOT (isNumber(nCol) and isNumber(nRow))
				StzRaise("Incorrect param type! nRow and nCol must be both numbers.")
			ok
		ok

		nLen = len(aList)

		for i = 1 to nLen
			if aList[i][1] = nCol and aList[i][2] = nRow
				return TRUE
			ok
		next
		return FALSE

	def LowestFScore(aOpenSet, aFScore)

		nLowestIdx = 1
		nLowestScore = This.GetScoreAt(aFScore, aOpenSet[1][1], aOpenSet[1][2])
		
		nLen = len(aOpenSet)

		for i = 2 to nLen
			nScore = This.GetScoreAt(aFScore, aOpenSet[i][1], aOpenSet[i][2])
			if nScore < nLowestScore
				nLowestScore = nScore
				nLowestIdx = i
			ok
		next
		
		return nLowestIdx

	def GetScoreAt(aScores, nCol, nRow)

		nLen = len(aScores)

		for i = 1 to nLen
			if aScores[i][1][1] = nCol and aScores[i][1][2] = nRow
				return aScores[i][2]
			ok
		next
		return 999999  # Default to infinity

	def SetScoreAt(aScores, nCol, nRow, nScore)

		nLen = len(aScores)

		for i = 1 to nLen
			if aScores[i][1][1] = nCol and aScores[i][1][2] = nRow
				aScores[i][2] = nScore
				return aScores
			ok
		next
		
		# If not found, add it
		aScores + [[nCol, nRow], nScore]
		return aScores

	def SetCameFrom(aCameFrom, nCol, nRow, nFromCol, nFromRow)

		nLen = len(aCameFrom)

		for i = 1 to nLen
			if aCameFrom[i][1][1] = nCol and aCameFrom[i][1][2] = nRow
				aCameFrom[i][2] = [nFromCol, nFromRow]
				return aCameFrom
			ok
		next
		
		# If not found, add it
		aCameFrom + [[nCol, nRow], [nFromCol, nFromRow]]
		return aCameFrom

	def GetCameFrom(aCameFrom, nCol, nRow)

		nLen = len(aCameFrom)

		for i = 1 to nLen
			if aCameFrom[i][1][1] = nCol and aCameFrom[i][1][2] = nRow
				return aCameFrom[i][2]
			ok
		next
		return NULL

def ReconstructPath(aCameFrom, nEndCol, nEndRow)
    aPath = []
    nCurrentCol = nEndCol
    nCurrentRow = nEndRow
    
    # Add end position
    aPath + [nCurrentCol, nCurrentRow]
    
    # Trace back the path
    while TRUE
        aPrev = This.GetCameFrom(aCameFrom, nCurrentCol, nCurrentRow)
        
        if aPrev = NULL
            exit
        ok
        
        nCurrentCol = aPrev[1]
        nCurrentRow = aPrev[2]
        
        # Add to path (at the beginning)
        insert(aPath, 1, [nCurrentCol, nCurrentRow])
    end

    return aPath
	
	#-- PATH COMPLEXITY ANALYSIS

	def PathComplexity()
		# Analyze path complexity based on number of turns and direction changes
		
		nLen = len(@aPath)
		
		if nLen <= 2
			return 0  # Straight line or single point
		ok
		
		nTurns = 0
		nLastDirX = 0
		nLastDirY = 0
		
		for i = 2 to nLen
			nDirX = @aPath[i][1] - @aPath[i-1][1]
			nDirY = @aPath[i][2] - @aPath[i-1][2]
			
			# First direction, just store it
			if i = 2
				nLastDirX = nDirX
				nLastDirY = nDirY
				loop
			ok
			
			# Direction changed, count as a turn
			if nDirX != nLastDirX or nDirY != nLastDirY
				nTurns++
				nLastDirX = nDirX
				nLastDirY = nDirY
			ok
		next
		
		return nTurns
	
	def PathEfficiency()
		# Calculate path efficiency compared to direct distance
		
		nLen = len(@aPath)

		if nLen < 2
			return 100  # Perfect efficiency for single point
		ok
		
		nStart = @aPath[1]
		nEnd = @aPath[nLen]
		
		# Calculate direct Manhattan distance
		nDirectDist = abs(nStart[1] - nEnd[1]) + abs(nStart[2] - nEnd[2])
		
		# Calculate efficiency
		nEfficiency = (nDirectDist / (nLen - 1)) * 100
		
		# Cap at 100%
		if nEfficiency > 100
			return 100
		else
			return nEfficiency
		ok
	
	#-- REGION MANAGEMENT
	
	def FloodFill(nStartCol, nStartRow)
		# Perform flood fill from start position, ignoring obstacles
		# Returns a list of all reachable positions
		
		aResult = []
		aQueue = []
		aVisited = []
		
		# Add start position to queue
		aQueue + [nStartCol, nStartRow]
		aVisited + [nStartCol, nStartRow]
		
		while len(aQueue) > 0
			# Get next position from queue
			nCol = aQueue[1][1]
			nRow = aQueue[1][2]
			del(aQueue, 1)
			
			# Add to result
			aResult + [nCol, nRow]
			
			# Check all 4 adjacent positions
			aDirections = [[0,1], [1,0], [0,-1], [-1,0]]
			nLen = len(aDirections)

			for i = 1 to nLen
				nNewCol = nCol + aDirections[i][1]
				nNewRow = nRow + aDirections[i][2]
				
				# Check if valid position that is not an obstacle and not visited
				if IsValidPosition(nNewCol, nNewRow) and 
				   NOT This.IsObstacle(nNewCol, nNewRow) and
				   NOT This.IsInList(aVisited, nNewCol, nNewRow)
					
					# Add to queue 		// and mark as visited
					aQueue + [nNewCol, nNewRow]
					aVisited + [nNewCol, nNewRow]
				ok
			next
		end
		
		return aResult
	
	def AreConnected(panNode1, panNode2)
		# Check if two positions are connected (can reach each other without hitting obstacles)
		
		if CheckParams()
			if NOT (isList(panNode1) and IsPairOfNumbers(panNode1) and
				isList(panNode2) and IsPairOfNumbers(panNode2))

				StzRaise("Incorrect param type! panNode1 and panNode2 must be both pairs of numbers.")
			ok
		ok

		nCol1 = panNode1[1]
		nRow1 = panNode1[2]

		nCol2 = panNode2[1]
		nRow2 = panNode2[2]

		# Quick check for invalid positions
		if NOT IsValidPosition(nCol1, nRow1) or NOT IsValidPosition(nCol2, nRow2)
			return FALSE
		ok
		
		# Check if either position is an obstacle
		if This.IsObstacle(nCol1, nRow1) or This.IsObstacle(nCol2, nRow2)
			return FALSE
		ok
		
		# Do flood fill from first position
		aReachable = This.FloodFill(nCol1, nRow1)
		
		# Check if second position is in the reachable list
		return This.IsInList(aReachable, nCol2, nRow2)
	
	def ConnectedRegions()
		# Find all connected regions separated by obstacles
		# Returns a list of lists, each containing the positions in a region
		
		aRegions = []
		
		# Check each position
		for y = 1 to @nRows
			for x = 1 to @nCols
				# Skip if obstacle
				if This.IsObstacle(x, y)
					loop
				ok
				
				# Flood fill from this position
				aRegion = This.FloodFill(x, y)
				
				# Add region to list
				aRegions + aRegion
				
			next
		next
		
		return aRegions
	
	#-- RANDOM MAZE GENERATION
	
	def RandomMaze(nObstacleDensity)
		# Generate a random maze with the given obstacle density (0-100%)
		# 0% = no obstacles, 100% = completely blocked (except current position)
		
		# Clear obstacles
		This.ClearObstacles()
		
		# Cap density
		if nObstacleDensity < 0
			nObstacleDensity = 0
		ok
		
		if nObstacleDensity > 90
			nObstacleDensity = 90  # Max 90% to ensure some paths exist
		ok
		
		# Add random obstacles
		for y = 1 to @nRows
			for x = 1 to @nCols
				# Skip current position
				if x = @nCurrentCol and y = @nCurrentRow
					loop
				ok
				
				# Add obstacle with probability based on density
				if random(100) < nObstacleDensity
					This.AddObstacle(x, y)
				ok
			next
		next
	
	def MazeWithPath(panStart, panEnd)
		# Generate a maze with a guaranteed path between start and end

		if CheckParams()
			if NOT (isList(panStart) and IsPairOfNumbers(panStart) and
				isList(panEnd) and IsPairOfNumbers(panEnd))

				StzRaise("Incorrect param type! panStart and panEnd must be pairs of numbers.")

			ok
		ok

		nStartCol = panStart[1]
		nStartRow = panStart[2]
		nEndCol = panEnd[1]
		nEndRow = panEnd[2]
	
		# Clear obstacles
		This.ClearObstacles()
		
		# Create a path first
		This.ClearPath()
		This.MoveTo(nStartCol, nStartRow)
		This.ShortestPath([nStartCol, nStartRow], [nEndCol, nEndRow])
		
		# Store path positions
		aPathPositions = @aPath
		
		# Add random obstacles avoiding the path
		for y = 1 to @nRows
			for x = 1 to @nCols
				# Skip if on path
				if This.IsInList(aPathPositions, x, y)
					loop
				ok
				
				# Add obstacle with 30% probability
				if random(100) < 30
					This.AddObstacle(x, y)
				ok
			next
		next
	
	#-- VISUALIZING THE GRID
	
	def Show()
		? This.ToString()


def ToString()
    # Create an empty grid
    aGrid = list(@nRows)
    for y = 1 to @nRows
        aGrid[y] = list(@nCols)
        for x = 1 to @nCols
            aGrid[y][x] = @cEmptyChar
        next
    next
    
    # Add obstacles
    if @bShowObstacles
        for i = 1 to len(@aObstacles)
            nObsCol = @aObstacles[i][1]
            nObsRow = @aObstacles[i][2]
            
            if IsValidPosition(nObsCol, nObsRow)
                aGrid[nObsRow][nObsCol] = @cObstacleChar
            ok
        next
    ok
    
    # Add path
    if @bShowPath and len(@aPath) > 0
        # Mark ALL path nodes with the path character
        for i = 1 to len(@aPath)
            nPathCol = @aPath[i][1]
            nPathRow = @aPath[i][2]
            
            if IsValidPosition(nPathCol, nPathRow)
                # Skip if it's an obstacle
                if NOT This.IsObstacle(nPathCol, nPathRow)
                    aGrid[nPathRow][nPathCol] = @cPathChar
                ok
            ok
        next
    ok
    
    # Mark current position with direction character or current char
    if IsValidPosition(@nCurrentCol, @nCurrentRow)
        # Use the appropriate direction character based on current direction
        if @cDirection = :Right
            aGrid[@nCurrentRow][@nCurrentCol] = @cRightChar
        but @cDirection = :Left
            aGrid[@nCurrentRow][@nCurrentCol] = @cLeftChar
        but @cDirection = :Up
            aGrid[@nCurrentRow][@nCurrentCol] = @cUpChar
        but @cDirection = :Down
            aGrid[@nCurrentRow][@nCurrentCol] = @cDownChar
        else
            # Default to current char for other directions
            aGrid[@nCurrentRow][@nCurrentCol] = @cCurrentChar
        ok
    ok
    
    # Remaining code remains the same...
		
		# Convert grid to string representation
		cResult = ""
		
		# Add X-axis labels if requested
		if @bShowCoordinates
			cResult += "    " # Space for alignment with the grid
			for x = 1 to @nCols
				if x % 10 = 0
					cResult += "0 "
				else
					cResult += ""+ (x % 10) + " "
				ok
			next
			cResult += NL()
		ok
		
		# Add top border with rounded corners and indicator for current X position
		cResult += "  ╭"
		for x = 1 to @nCols
			if x = @nCurrentCol
				cResult += "─v─"
			else
				cResult += "──"
			ok
		next
		cResult += "╮" + NL()
		
		# Add rows with Y-axis labels and borders
		for y = 1 to @nRows
			# Add Y indicator for current position - resetting at multiples of 10
			if @bShowCoordinates
				if y % 10 = 0
					yLabel = "0"
				else
					yLabel = ""+ (y % 10)
				ok
			else
				yLabel = " "
			ok
			
			if y = @nCurrentRow
				cResult += yLabel + " > "
			else
				cResult += yLabel + " │ "
			ok
			
			for x = 1 to @nCols
				cResult += ""+ aGrid[y][x] + " "
			next
			cResult += "│" + NL()
		next
		
		# Add bottom border with rounded corners
		cResult += "  ╰"
		for x = 1 to @nCols
			cResult += "──"
		next
		cResult += "─╯" + NL()
		
		return cResult

	def Legend()
		# Create a legend string with all relevant information
		cResult = "Grid: " + @nCols + "x" + @nRows + " | "
		cResult += "Current: " + @cCurrentChar + " | "
		
		if @bShowObstacles
			cResult += "Obstacles: " + @cObstacleChar + " | "
		ok
		
		if @bShowPath
			cResult += "Path: " + @cPathChar + " | "
		ok
		
		# Add movement indicators

		cResult += "Direction: " + @cDirection + NL

		cResult += "Movement: "
		cResult += "Right(" + @cRightChar + ") "
		cResult += "Left(" + @cLeftChar + ") "
		cResult += "Up(" + @cUpChar + ") "
		cResult += "Down(" + @cDownChar + ")"
		
		return cResult
	
