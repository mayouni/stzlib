#------------------------------------------------------
#
# Project : Softanza
# File    : stzTile.ring
# Author  : Mansour Ayouni (2025)
#
# Description : A Cellal construct for navigating
# Tile-like objects (1-indexed)
#
#------------------------------------------------------

func StzTileQ(panColRow)
	return new stzTile(panColRow)

	func StzTile(panColRow)
		return new stzTile(panColRow)

Class stzTile From stzObject

	# The stzTile class is a square-based counterpart of stzGrid.


	@nRows
	@nCols

	@nCurrentRow
	@nCurrentCol

	@cDirection = :Forward # :Forward, :Backward, :Left, :Right, :Up, :Down

	@aObstacles = []
	@aPath = []
	@cObstacleChar = "█" // "■"
	@cPathChar = "○"
	@cFocusChar = "●"
	@cCurrentChar = "♥"
	@cEmptyChar = " "
	@cNeighborChar = "N"

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

		# Initialize Cell to (1,1)

		@nCurrentRow = 1
		@nCurrentCol = 1
	
	#-- INFORMATION METHODS

	def Size()
		return @nCols * @nRows

		def NumberOfCells()
			return This.Size()

	def SizeXT()
		return [ @nCols, @nRows ]

	def NumberOfColumns()
		return @nCols
	
	def NumberOfRows()
		return @nRows
		
	def CurrentCell()
		return [ @nCurrentCol, @nCurrentRow ]

		def Cell()
			return This.CurrentCell()

		def CurrentPosition()
			return This.CurrentCell()

		def Position()
			return This.CurrentCell()

	def CurrentColumn()
		return @nCurrentCol

	def CurrentRow()
		return @nCurrentRow
		
	def IsValidCell(nCol, nRow)

		if nCol >= 1 and nCol <= @nCols and
		   nRow >= 1 and nRow <= @nRows

			return TRUE
		else
			return FALSE
		ok

		def IsValidPosition(nCol, nRow)
			return This.IsValidCell(nCol, nRow)

	def IsCurrentCellValid() # For debugging purposes
		return IsValidCell( @nCurrentCol, @nCurrentRow)
		
		def IsCurrentPositionValid()
			return This.IsCurrentCellValid()

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
	
	def MoveToCell(nCol, nRow)
		if NOT IsValidCell(nCol, nRow)
			StzRaise("Can't move! The provided Cell is not valid.")
		ok

		if NOT IsObstacle(nCol, nRow)
			@nCurrentCol = nCol
			@nCurrentRow = nRow
		ok

		def Moveto(nCol, nRow)
			This.MoveToCell(nCol, nRow)
		
	def MoveToFirstCell()
		This.MoveToCell(1, 1)

	def MoveToLastCell()
		This.MoveToCell(@nCols, @nRows)

		def MoveToLast()
			This.MoveToCell(@nCols, @nRows)

		def MoveLast()
			This.MoveToCell(@nCols, @nRows)

	def MoveToNextCell()

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

		def MoveToNext()
			This.MoveToNextCell()

		def MoveNext()
			This.MoveToNextCell()

	def MoveToPreviousCell()
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

		def MoveToPrevious()
			This.MoveToPreviousCell()

		def MovePrevious()
			This.MoveToPreviousCell()

	def MoveBy(nCols, nRows)

		nNewCols = @nCurrentCol + nCols
		nNewRows = @nCurrentRow + nRows
		

		if NOT IsValidCell(nNewCols, nNewRows)
			StzRaise("Can't move! The provided Cell is not valid.")
		ok

		if NOT IsObstacle(nNewCols, nNewRows)
			@nCurrentRow = nNewRows
			@nCurrentCol = nNewCols
		ok

		def MoveByNColsNRows(nCols, nRows)
			This.MoveBy(nCols, nRows)

		def MoveFor(nCols, nRows)
			This.MoveBy(nCols, nRows)

		def MoveForNColsNRows(nCols, nRows)
			This.MoveBy(nCols, nRows)

	def MoveN(n)

		if @cDirection = :Forward
			This.MoveForwardN(n)

		else // :Backward
			This.MoveBackwardN(n)

		ok
		
		def MoveNCells(n)
			This.MoveN(n)

	def Move()
		This.MoveN(1)

	def MoveForwardN(n)

		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		@cDirection = :Forward
		nNewCol = @nCurrentCol + n

		nTempCol = @nCurrentCol
		nTempRow = @nCurrentRow

		if nNewCol <= @nCols
			nTempCol  = nNewCol
		else
			nNewRow = @nCurrentRow + n

			if nNewRow <= @nRows
				nTempRow = nNewRow
				nTempCol = 1
			ok

		ok
		
		if NOT IsObstacle(nTempCol, nTempRow)
			@nCurrentCol = nTempCol
			@nCurrentRow = nTempRow
		ok

		def MoveForwardNCells(n)
			This.MoveForwardN(n)

	def MoveForward()
		This.MoveForwardN(1)

	def MoveBackwardN(n)
		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		@cDirection = :Backward
		nNewCol = @nCurrentCol - n

		nTempCol = @nCurrentCol
		nTempRow = @nCurrentRow

		if nNewCol >= 1
			nTempCol = nNewCol
		else
			nNewRow = @nCurrentRow - n
			
			if nNewRow >= 1
				nTempRow = nNewRow
				nTempCol = @nCols

			ok
		ok

		if NOT IsObstacle(nTempCol, nTempRow)
			@nCurrentCol = nTempCol
			@nCurrentRow = nTempRow
		ok

		def MoveBackwardNCells(n)
			This.MoveBackwardN(n)

	def MoveBackward()
		This.MoveBackwardN(1)

	def MoveRightN(n)

		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		@cDirection = :Right
		nNewCol = @nCurrentCol + n
		
		if nNewCol <= @nCols and NOT IsObstacle(nNewCol, @nCurrentRow)
			@nCurrentCol = nNewCol
		ok

		def MoveRightNCells(n)
			This.MoveRightN(n)

	def MoveRight()
		This.MoveRightN(1)

	def MoveLeftN(n)

		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		@cDirection = :Left
		nNewCol = @nCurrentCol - n
	
		if nNewCol >= 1 and NOT IsObstacle(nNewCol, @nCurrentRow)
			@nCurrentCol = nNewCol
		ok

		def MoveLeftNCells(n)
			This.MoveLeftN(n)

	def MoveLeft()
		This.MoveLeftN(1)

	def MoveUpN(n)

		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		@cDirection = :Up
		nNewRow = @nCurrentRow - n
		
		if nNewRow >= 1 and NOt IsObstacle(@nCurrentCol, nNewRow)
			@nCurrentRow = nNewRow
		ok

		def MoveUpNCells(n)
			This.MoveUpN(n)

	def MoveUp()
		This.MoveUpN(1)

	def MoveDownN(n)

		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		@cDirection = :Down
		nNewRow = @nCurrentRow + n
		
		if nNewRow <= @nRows and NOT IsObstacle(@nCurrentCol, nNewRow)
			@nCurrentRow = nNewRow
		ok

		def MoveDownNCells(n)
			This.MoveDownN(n)

	def MoveDown()
		This.MoveDownN(1)

	#-- TRAVERSAL METHODS
	
	def Cells()
		aResult = []
		
		for i = 1 to @nCols
			for j = 1 to @nRows
				aResult +  [i, j]
			next
		next
		
		return aResult

	def ForEachCell(pCode)
		for i = 1 to @nRows
			for j = 1 to @nCols
				@nCurrentRow = i
				@nCurrentCol = j
				call pCode(i, j)
			next
		next
		
	def TraverseInDirection(cDirection, pCode)
		oTemp = new stzTile([@nCols, @nRows])
		oTemp.MoveTo(@nCurrentCol, @nCurrentRow)
		oTemp.SetDirection(cDirection)
		
		while TRUE
			nRow = oTemp.CurrentRow()
			nCol = oTemp.CurrentColumn()
			
			call pCode(nCol, nRow)
			
			# Try to move to next Cell
			oNext = oTemp.MoveToNextCell()
			if oNext = NULL
				# Reached the boundary in NoWrap mode
				exit
			ok
			
		end
		
	#-- NEIGHBORS & RELATIVE CellS

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
			
			if IsValidCell(nCol, nRow)
				aResult +  [nCol, nRow]
			ok
		next
		
		return aResult
		
		def AdjacentCells()
			return This.Neighbors()
		
		def AdjacentNeighbors()
			return This.Neighbors()

	def PaintNeighbors()
		This.PaintCells(This.Neighbors(), @cNeighborChar)

	def CellUp()

		nCol = @nCurrentCol
		nRow = @nCurrentRow - 1
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell above the current Cell!")
		ok

	def CellUpLeft()

		nCol = @nCurrentCol - 1
		nRow = @nCurrentRow - 1
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell above the current Cell!")
		ok

	def CellUpRight()

		nCol = @nCurrentCol + 1
		nRow = @nCurrentRow - 1
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell above the current Cell!")
		ok

	def CellDown()

		nCol = @nCurrentCol
		nRow = @nCurrentRow + 1
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell below the current Cell!")
		ok

	def CellDownLeft()

		nCol = @nCurrentCol - 1
		nRow = @nCurrentRow + 1
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell below the current Cell!")
		ok

	def CellDownRight()

		nCol = @nCurrentCol + 1
		nRow = @nCurrentRow + 1
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell below the current Cell!")
		ok

	def CellToLeft()

		nCol = @nCurrentCol - 1
		nRow = @nCurrentRow
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell to the left of the current Cell!")
		ok

	def CellToRight()

		nCol = @nCurrentCol + 1
		nRow = @nCurrentRow
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell to the right of the current Cell!")
		ok

	def DistanceTo(nCol, nRow)
		# Manhattan distance (L1 norm)
		nResult = abs(@nCurrentCol - nCol) + abs(@nCurrentRow - nRow)
		return nResult
		
		def DistanceToCell(nCol, nRow)
			return This.DistanceTo(nCol, nRow)

		def ManhattanDistanceTo(nCol, nRow)
			return This.DistanceTo(nCol, nRow)

		def ManhattanDistanceToCell(nCol, nRow)
			return This.DistanceTo(nCol, nRow)

	def EuclideanDistanceTo(nCol, nRow)
    		# Euclidean distance (L2 norm)

		nDeltaCol = nCol - @nCurrentCol
		nDeltaRow = nRow - @nCurrentRow

		# Calculate using Pythagorean theorem
		nResult = ring_sqrt( nDeltaCol * nDeltaCol + nDeltaRow * nDeltaRow )

		return nResult

		def EuclideanDistanceToCell(nCol, nRow)
			return This.EuclideanDistanceTo(nCol, nRow)

		def EucDistanceTo(nCol, nRow)
			return This.EuclideanDistanceTo(nCol, nRow)

		def EucDistTo(nCol, nRow)
			return This.EuclideanDistanceTo(nCol, nRow)
	
	#-- N-Cell RELATIVE Cell METHODS
	
	def NextNthCell(n)
		# Save current Cell
		nOldCol = @nCurrentCol
		nOldRow = @nCurrentRow
		cOldDirection = @cDirection
		
		# Move n steps in current direction
		This.MoveNCells(n)
		
		# Get the resulting Cell
		nCol = @nCurrentCol
		nRow = @nCurrentRow
		
		# Restore original Cell
		@nCurrentCol = nOldCol
		@nCurrentRow = nOldRow
		@cDirection = cOldDirection
		
		# Return the calculated Cell
		return [nCol, nRow]
	
	def PreviousNthCell(n)
		# Save current Cell
		nOldCol = @nCurrentCol
		nOldRow = @nCurrentRow
		cOldDirection = @cDirection
		
		# Move n steps in reverse direction
		for i = 1 to n
			This.MoveToPreviousCell()
		next
		
		# Get the resulting Cell
		nCol = @nCurrentCol
		nRow = @nCurrentRow
		
		# Restore original Cell
		@nCurrentCol = nOldCol
		@nCurrentRow = nOldRow
		@cDirection = cOldDirection
		
		# Return the calculated Cell
		return [nCol, nRow]

	
	def NthCellUp(n)
		nCol = @nCurrentCol
		nRow = @nCurrentRow - n
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell " + n + " Cells above the current Cell!")
		ok
	
	def NthCellDown(n)
		nCol = @nCurrentCol
		nRow = @nCurrentRow + n
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell " + n + " Cells below the current Cell!")
		ok
	
	def NthCellLeft(n)
		nCol = @nCurrentCol - n
		nRow = @nCurrentRow
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell " + n + " Cells to the left of the current Cell!")
		ok
	
	def NthCellRight(n)
		nCol = @nCurrentCol + n
		nRow = @nCurrentRow
		
		if IsValidCell(nCol, nRow)
			return [nCol, nRow]
		else
			StzRaise("No valid Cell " + n + " Cells to the right of the current Cell!")
		ok

	#-- OBSTACLES MANAGEMENT
	
	def AddObstacle(nCol, nRow)
		if NOT IsValidCell(nCol, nRow)
			stzRaise("Invalid Cell for obstacle!")
		ok
		
		if NOT This.IsObstacle(nCol, nRow)
			@aObstacles + [nCol, nRow]
		ok
		
	def AddObstacles(aCells)
		for i = 1 to len(aCells)
			if isList(aCells[i]) and len(aCells[i]) = 2
				This.AddObstacle(aCells[i][1], aCells[i][2])
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

		def AddPathCells(panColRow)
			This.AddPath(panColRow)

	def AddPathCell(nCol, nRow)
		if NOT IsValidCell(nCol, nRow)
			stzRaise("Invalid Cell for path Cell!")
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
			stzRaise("Current Cell character must be a single character!")
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
		
		# Validate Cells

		if NOT IsValidCell(nStartCol, nStartRow)
			StzRaise("Invalid start Cell!")
		ok
		
		if NOT IsValidCell(nEndCol, nEndRow)
			StzRaise("Invalid end Cell!")
		ok
		
		# Check if start or end is an obstacle

		if This.IsObstacle(nStartCol, nStartRow)
			stzRaise("Start Cell is an obstacle!")
		ok
		
		if This.IsObstacle(nEndCol, nEndRow)
			stzRaise("End Cell is an obstacle!")
		ok
		
		# Initialize data structures

		aOpenSet = []          # Cells to be evaluated
		aClosedSet = []        # Cells already evaluated
		aCameFrom = []         # Map to reconstruct path
		aGScore = []           # Cost from start to current Cell
		aFScore = []           # Estimated total cost from start to goal through current Cell
		
		# Initialize with start Cell

		aOpenSet + [nStartCol, nStartRow]
		
		# Initialize gScore with infinity for all Cells

		for i = 1 to @nRows
			for j = 1 to @nCols
				aGScore + [[j, i], 999999]
				aFScore + [[j, i], 999999]
			next
		next
		
		# Set scores for start Cell

		This.SetScoreAt(aGScore, nStartCol, nStartRow, 0)
		This.SetScoreAt(aFScore, nStartCol, nStartRow, This.HeuristicCost([nStartCol, nStartRow], [nEndCol, nEndRow]))
		
		# Main loop

		while len(aOpenSet) > 0

			# Get Cell with lowest fScore

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

		# Validate Cells

		if NOT IsValidCell(nStartCol, nStartRow)
			stzRaise("Invalid start Cell!")
		ok
		
		if NOT IsValidCell(nEndCol, nEndRow)
			stzRaise("Invalid end Cell!")
		ok
		
		# Clear existing path

		This.ClearPath()
		
		# Start from start Cell

		This.AddPathCell(nStartCol, nStartRow)
		
		# Current Cell

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
			
			This.AddPathCell(nCurrentCol, nCurrentRow)
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
				
				# Remove first Cell to avoid duplication

				if len(aPartialPath) > 0
					del(aPartialPath, 1)
				ok
				
				# Add the rest of the path

				for i = 1 to len(aPartialPath)
					This.AddPathCell(aPartialPath[i][1], aPartialPath[i][2])
				next
				
				return @aPath
			ok
			
			This.AddPathCell(nCurrentCol, nCurrentRow)
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
		
		# Start from start Cell

		This.AddPathCell(nStartCol, nStartRow)
		
		# Current Cell

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
			
			This.AddPathCell(nCurrentCol, nCurrentRow)
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
				
				# Remove first Cell to avoid duplication

				nLenPartial = len(aPartialPath)

				if nLenPartial > 0
					del(aPartialPath, 1)
				ok
				
				# Add the rest of the path

				for i = 1 to nLenPartial
					This.AddPathCell(aPartialPath[i][1], aPartialPath[i][2])
				next
				
				return @aPath
			ok
			
			This.AddPathCell(nCurrentCol, nCurrentRow)
		end
		
		return @aPath

	def SpiralPath(panStartCell, nRings)
		# Creates a spiral path starting from the given Cell

		if CheckParams()

			if NOT (isList(panStartCell) and IsPairOfNumbers(panStartCell))
				StzRaise("Incorrect param type! panStartCell must be a pair of numbers.")
			ok

			if isList(nRings) and StzListQ(nRings).IsRingsNamedParam()
				nRings = nRings[2]
			ok

			if NOT isNumber(nRings)
				StzRaise("Incorrect param type! nRings must be a number.")
			ok
		ok
		
		nStartCol = panStartCell[1]
		nStartRow = panStartCell[2]

		# Validate Cells
		if NOT IsValidCell(nStartCol, nStartRow)
			stzRaise("Invalid start Cell!")
		ok
		
		# Clear existing path
		This.ClearPath()
		
		# Start from start Cell
		This.AddPathCell(nStartCol, nStartRow)
		
		# Define directions: right, down, left, up
		aDirections = [[1,0], [0,1], [-1,0], [0,-1]]
		nDirIndex = 0
		
		# Current Cell
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
			if NOT IsValidCell(nCurrentCol, nCurrentRow)
				exit
			ok
			
			# Check for obstacle
			if This.IsObstacle(nCurrentCol, nCurrentRow)
				# Skip this Cell
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
			This.AddPathCell(nCurrentCol, nCurrentRow)
			
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

		# Validate Cells
		if NOT IsValidCell(nStartCol, nStartRow)
			stzRaise("Invalid start Cell!")
		ok
		
		if NOT IsValidCell(nEndCol, nEndRow)
			stzRaise("Invalid end Cell!")
		ok
		
		# Clear existing path
		This.ClearPath()
	
		# Start from start Cell
		This.AddPathCell(nStartCol, nStartRow)
		
		# Current Cell
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
				if NOT IsValidCell(nCurrentCol, nCurrentRow)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(nCurrentCol, nCurrentRow)
					# Try to go around obstacle
					if IsValidCell(nCurrentCol + 1, nCurrentRow) and NOT This.IsObstacle(nCurrentCol + 1, nCurrentRow)
						nCurrentCol++
					but IsValidCell(nCurrentCol - 1, nCurrentRow) and NOT This.IsObstacle(nCurrentCol - 1, nCurrentRow)
						nCurrentCol--
					else
						# Can't find a way around, use A* for the rest
						aPartialPath = This.ShortestPath(nCurrentCol, nCurrentRow - nDirRow, nEndCol, nEndRow)
						
						# Remove first Cell to avoid duplication
						if len(aPartialPath) > 0
							del(aPartialPath, 1)
						ok
						
						# Add the rest of the path
						for i = 1 to len(aPartialPath)
							This.AddPathCell(aPartialPath[i][1], aPartialPath[i][2])
						next
						
						return @aPath
					ok
				ok
				
				This.AddPathCell(nCurrentCol, nCurrentRow)
				
				# Zig-zag horizontally
				nZigZag++
				if nZigZag >= nZigZagWidth
					nZigZag = 0
					
					# Move horizontally in zigzag pattern
					nHorizontalSteps = @IF(lZigZagRight, 1, -1)
					
					for i = 1 to 2  # Move 2 steps horizontally
						nCurrentCol += nHorizontalSteps
						
						# Check if we're still in bounds
						if NOT IsValidCell(nCurrentCol, nCurrentRow)
							exit
						ok
						
						# Check for obstacle
						if This.IsObstacle(nCurrentCol, nCurrentRow)
							nCurrentCol -= nHorizontalSteps
							exit
						ok
						
						This.AddPathCell(nCurrentCol, nCurrentRow)
					next
					
					lZigZagRight = NOT lZigZagRight
				ok
			end
			
			# Final horizontal movement to reach end Cell
			while nCurrentCol != nEndCol
				if nCurrentCol < nEndCol
					nCurrentCol++
				else
					nCurrentCol--
				ok
				
				# Check if we're still in bounds
				if NOT IsValidCell(nCurrentCol, nCurrentRow)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(nCurrentCol, nCurrentRow)
					# Can't find a way around, use A* for the rest
					aPartialPath = This.ShortestPath(nCurrentCol - @IF(nCurrentCol > nEndCol, 1, -1), nCurrentRow, nEndCol, nEndRow)
					
					# Remove first Cell to avoid duplication
					if len(aPartialPath) > 0
						del(aPartialPath, 1)
					ok
					
					# Add the rest of the path
					for i = 1 to len(aPartialPath)
						This.AddPathCell(aPartialPath[i][1], aPartialPath[i][2])
					next
					
					return @aPath
				ok
				
				This.AddPathCell(nCurrentCol, nCurrentRow)
			end
		else

			# Horizontal zig-zag
			nZigZag = 0
			lZigZagDown = TRUE
			
			while nCurrentCol != nEndCol
				# Move horizontally
				nCurrentCol += nDirCol
				
				# Check if we're still in bounds
				if NOT IsValidCell(nCurrentCol, nCurrentRow)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(nCurrentCol, nCurrentRow)
					# Try to go around obstacle
					if IsValidCell(nCurrentCol, nCurrentRow + 1) and NOT This.IsObstacle(nCurrentCol, nCurrentRow + 1)
						nCurrentRow++
					but IsValidCell(nCurrentCol, nCurrentRow - 1) and NOT This.IsObstacle(nCurrentCol, nCurrentRow - 1)
						nCurrentRow--
					else
						# Can't find a way around, use A* for the rest
						aPartialPath = This.ShortestPath(nCurrentCol - nDirCol, nCurrentRow, nEndCol, nEndRow)
						
						# Remove first Cell to avoid duplication
						if len(aPartialPath) > 0
							del(aPartialPath, 1)
						ok
						
						# Add the rest of the path
						for i = 1 to len(aPartialPath)
							This.AddPathCell(aPartialPath[i][1], aPartialPath[i][2])
						next
						
						return @aPath
					ok

				ok
				
				This.AddPathCell(nCurrentCol, nCurrentRow)
				
				# Zig-zag vertically
				nZigZag++
				if nZigZag >= nZigZagWidth
					nZigZag = 0
					
					# Move vertically in zigzag pattern
					nVerticalSteps = @if(lZigZagDown, 1, -1)
					
					for i = 1 to 2  # Move 2 steps vertically
						nCurrentRow += nVerticalSteps
						
						# Check if we're still in bounds
						if NOT IsValidCell(nCurrentCol, nCurrentRow)
							exit
						ok
						
						# Check for obstacle
						if This.IsObstacle(nCurrentCol, nCurrentRow)
							nCurrentRow -= nVerticalSteps
							exit
						ok
						
						This.AddPathCell(nCurrentCol, nCurrentRow)
					next
					
					lZigZagDown = NOT lZigZagDown
				ok
			end
			
			# Final vertical movement to reach end Cell
			while nCurrentRow != nEndRow
				if nCurrentRow < nEndRow
					nCurrentRow++
				else
					nCurrentRow--
				ok
				
				# Check if we're still in bounds
				if NOT IsValidCell(nCurrentCol, nCurrentRow)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(nCurrentCol, nCurrentRow)
					# Can't find a way around, use A* for the rest
					aPartialPath = This.ShortestPath(nCurrentCol, nCurrentRow - @IF(nCurrentRow > nEndRow, 1, -1), nEndCol, nEndRow)
					
					# Remove first Cell to avoid duplication
					if len(aPartialPath) > 0
						del(aPartialPath, 1)
					ok
					
					# Add the rest of the path
					for i = 1 to len(aPartialPath)
						This.AddPathCell(aPartialPath[i][1], aPartialPath[i][2])
					next
					
					return @aPath
				ok
				
				This.AddPathCell(nCurrentCol, nCurrentRow)
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


	def PaintCell(nCol, nRow, cChar)
		This.PaintCells([ [nCol, nRow] ], cChar)

	def PaintCells(aCells, cChar)
		# Temporarily draw Cells with the specified character
		
		if NOT (isString(cChar) and IsChar(cChar))
			stzRaise("Cell character must be a single character!")
		ok
		
		# Store current path
		aOldPath = @aPath
		
		# Clear path and add Cells
		This.ClearPath()
		
		for i = 1 to len(aCells)
			if isList(aCells[i]) and len(aCells[i]) = 2
				nCol = aCells[i][1]
				nRow = aCells[i][2]
				
				if IsValidCell(nCol, nRow)
					This.AddPathCell(nCol, nRow)
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

		# Store current Tile state
		aOldPath = @aPath

		# Create a temporary Tile with empty cells
		aTile = list(@nRows)

		for y = 1 to @nRows

			aTile[y] = list(@nCols)

			for x = 1 to @nCols
				aTile[y][x] = @cEmptyChar
			next
		next

		# Add obstacles to the Tile
		if @bShowObstacles
			for i = 1 to len(@aObstacles)
				nObsCol = @aObstacles[i][1]
				nObsRow = @aObstacles[i][2]

				if IsValidCell(nObsCol, nObsRow)
					aTile[nObsRow][nObsCol] = @cObstacleChar
				ok
			next
		ok

		# Add all regions to the Tile
		for i = 1 to nLen
			aRegion = aRegions[i]
			cChar = acChars[i]

			for j = 1 to len(aRegion)
				nCol = aRegion[j][1]
				nRow = aRegion[j][2]

				if IsValidCell(nCol, nRow)
					# Skip if it's an obstacle
					if NOT This.IsObstacle(nCol, nRow)
						aTile[nRow][nCol] = cChar
					ok
				ok
			next
		next

		# Display the Tile with all regions
		This.DisplayCustomTile(aTile)

		# Restore original path
		@aPath = aOldPath


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

		# Store current Tile state
		aOldPath = @aPath

		# Create a temporary Tile with empty cells
		aTile = list(@nRows)

		for y = 1 to @nRows
			aTile[y] = list(@nCols)
			for x = 1 to @nCols
				aTile[y][x] = @cEmptyChar
			next
		next

		# Add obstacles to the Tile
		nLenObstacles = len(@aObstacles)

		if @bShowObstacles

			for i = 1 to nLenObstacles
				nObsCol = @aObstacles[i][1]
				nObsRow = @aObstacles[i][2]

				if IsValidCell(nObsCol, nObsRow)
					aTile[nObsRow][nObsCol] = @cObstacleChar
				ok
			next

		ok

		# Add all regions to the Tile
		for i = 1 to nLen
			aRegion = aRegions[i]
			cChar = acChars[i]
			nLenRegion = len(aRegion)

			for j = 1 to nLenRegion
				nCol = aRegion[j][1]
				nRow = aRegion[j][2]

				if IsValidCell(nCol, nRow)
					# Skip if it's an obstacle
					if NOT This.IsObstacle(nCol, nRow)
						aTile[nRow][nCol] = cChar
					ok
				ok
			next
		next

		# Display the Tile with all regions
		This.DisplayCustomTile(aTile)

		# Restore original path
		@aPath = aOldPath

	def DisplayCustomTile(aCustomTile)
		# Display a custom Tile without changing the internal Tile state

		cResult = ""

		# Add X-axis labels if requested

		if @bShowCoordinates
			cResult += "    " # Space for alignment with the Tile

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
			# Add Y indicator for current Cell - resetting at multiples of 10

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
				cResult += ""+ aCustomTile[y][x] + " "
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
			
			if IsValidCell(nNewCol, nNewRow) and NOT This.IsObstacle(nNewCol, nNewRow)
				aNeighbors + [nNewCol, nNewRow]
			ok
		next
		
		return aNeighbors

		def WalkableNeighborsOfCell(nCol, nRow)
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

		# Add end Cell

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
		# Perform flood fill from start Cell, ignoring obstacles
		# Returns a list of all reachable Cells
		
		aResult = []
		aQueue = []
		aVisited = []
		
		# Add start Cell to queue
		aQueue + [nStartCol, nStartRow]
		aVisited + [nStartCol, nStartRow]
		
		while len(aQueue) > 0
			# Get next Cell from queue
			nCol = aQueue[1][1]
			nRow = aQueue[1][2]
			del(aQueue, 1)
			
			# Add to result
			aResult + [nCol, nRow]
			
			# Check all 4 adjacent Cells
			aDirections = [[0,1], [1,0], [0,-1], [-1,0]]
			nLen = len(aDirections)

			for i = 1 to nLen
				nNewCol = nCol + aDirections[i][1]
				nNewRow = nRow + aDirections[i][2]
				
				# Check if valid Cell that is not an obstacle and not visited
				if IsValidCell(nNewCol, nNewRow) and 
				   NOT This.IsObstacle(nNewCol, nNewRow) and
				   NOT This.IsInList(aVisited, nNewCol, nNewRow)
					
					# Add to queue and mark as visited
					aQueue + [nNewCol, nNewRow]
					aVisited + [nNewCol, nNewRow]
				ok
			next
		end
		
		return aResult
	
	def AreConnected(panCell1, panCell2)
		# Check if two Cells are connected (can reach each other without hitting obstacles)
		
		if CheckParams()
			if NOT (isList(panCell1) and IsPairOfNumbers(panCell1) and
				isList(panCell2) and IsPairOfNumbers(panCell2))

				StzRaise("Incorrect param type! panCell1 and panCell2 must be both pairs of numbers.")
			ok
		ok

		nCol1 = panCell1[1]
		nRow1 = panCell1[2]

		nCol2 = panCell2[1]
		nRow2 = panCell2[2]

		# Quick check for invalid Cells
		if NOT IsValidCell(nCol1, nRow1) or NOT IsValidCell(nCol2, nRow2)
			return FALSE
		ok
		
		# Check if either Cell is an obstacle
		if This.IsObstacle(nCol1, nRow1) or This.IsObstacle(nCol2, nRow2)
			return FALSE
		ok
		
		# Do flood fill from first Cell
		aReachable = This.FloodFill(nCol1, nRow1)
		
		# Check if second Cell is in the reachable list
		return This.IsInList(aReachable, nCol2, nRow2)
	
	def ConnectedRegions()
		# Find all connected regions separated by obstacles
		# Returns a list of lists, each containing the Cells in a region
		
		aRegions = []
		
		# Check each Cell
		for y = 1 to @nRows
			for x = 1 to @nCols
				# Skip if obstacle
				if This.IsObstacle(x, y)
					loop
				ok
				
				# Flood fill from this Cell
				aRegion = This.FloodFill(x, y)
				
				# Add region to list
				aRegions + aRegion
				
			next
		next
		
		return aRegions
	
	#-- RANDOM MAZE GENERATION
	
	def RandomMaze(nObstacleDensity)
		# Generate a random maze with the given obstacle density (0-100%)
		# 0% = no obstacles, 100% = completely blocked (except current Cell)
		
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
				# Skip current Cell
				if x = @nCurrentCol and y = @nCurrentRow
					loop
				ok
				
				# Add obstacle with probability based on density
				if random(100) < nObstacleDensity
					This.AddObstacle(x, y)
				ok
			next
		next

		def Maze()
			This.RandomMaze()
	
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
		
		# Store path Cells
		aPathCells = @aPath
		
		# Add random obstacles avoiding the path
		for y = 1 to @nRows
			for x = 1 to @nCols
				# Skip if on path
				if This.IsInList(aPathCells, x, y)
					loop
				ok
				
				# Add obstacle with 30% probability
				if random(100) < 30
					This.AddObstacle(x, y)
				ok
			next
		next
	
	#-- VISUALIZING THE Tile
	
	def Show()
		? This.ToString()


def ToString()
    # Create an empty tile grid
    aCells = list(@nRows)
    
    for y = 1 to @nRows
        aCells[y] = list(@nCols)
        for x = 1 to @nCols
            aCells[y][x] = @cEmptyChar
        next
    next
    
    # Add Obstacles (obstacles)
    if @bShowObstacles
        nLen = len(@aObstacles)
        for i = 1 to nLen
            nObstacleCol = @aObstacles[i][1]
            nObstacleRow = @aObstacles[i][2]
            
            if IsValidPosition(nObstacleCol, nObstacleRow)
                aCells[nObstacleRow][nObstacleCol] = @cObstacleChar
            ok
        next
    ok
    
    # Add path
    if @bShowPath and len(@aPath) > 0
        for i = 1 to len(@aPath)
            nPathCol = @aPath[i][1]
            nPathRow = @aPath[i][2]
            
            if IsValidPosition(nPathCol, nPathRow)
                if NOT This.IsObstacle(nPathCol, nPathRow)
                    if i = 1
                        aCells[nPathRow][nPathCol] = @cFocusChar
                    else
                        aCells[nPathRow][nPathCol] = @cPathChar
                    ok
                ok
            ok
        next
    ok
    
    # Mark current cell position
    if IsValidPosition(@nCurrentCol, @nCurrentRow)
        aCells[@nCurrentRow][@nCurrentCol] = @cCurrentChar
    ok
    
    # Convert tile grid to string representation
    cResult = ""
    
    # Add X-axis labels if requested
    if @bShowCoordinates
        cResult += "    " # Space for alignment
        for x = 1 to @nCols
            if x % 10 = 0
                cResult += "0   "
            else
                cResult += ""+ (x % 10) + "   "
            ok
        next
        cResult += NL()
    ok
    
    # Top border with corner
    cResult += "  ╭"
    for x = 1 to @nCols
        cResult += "───"
        if x < @nCols
            cResult += "┬"
        ok
    next
    cResult += "╮" + NL()
    
    # Rows with cells
    for y = 1 to @nRows
        # Y-axis label
        if @bShowCoordinates
            if y % 10 = 0
                yLabel = "0"
            else
                yLabel = ""+ (y % 10)
            ok
        else
            yLabel = " "
        ok
        
        # Row with cell content
        cResult += yLabel + " │"
        for x = 1 to @nCols
            cResult += " " + aCells[y][x] + " "
            if x < @nCols
                cResult += "│"
            ok
        next
        cResult += "│" + NL()
        
        # Horizontal line between rows
        if y < @nRows
            cResult += "  ├"
            for x = 1 to @nCols
                cResult += "───"
                if x < @nCols
                    cResult += "┼"
                ok
            next
            cResult += "┤" + NL()
        ok
    next
    
    # Bottom border
    cResult += "  ╰"
    for x = 1 to @nCols
        cResult += "───"
        if x < @nCols
            cResult += "┴"
        ok
    next
    cResult += "╯" + NL()
    
    return cResult

	def Legend()

		# Create a legend string with all relevant information

		cResult = "Tile: " + @nCols + "x" + @nRows + " | "
		cResult += "Current: " + @cCurrentChar + " | "

		if @bShowObstacles
			cResult += "Obstacles: " + @cObstacleChar + " | "
		ok

		if @bShowPath
			cResult += "Path: " + @cPathChar + " | "
		ok

		return cResult
