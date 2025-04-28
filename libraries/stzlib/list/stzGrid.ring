
# Project : Softanza
# File    : stzgrid.ring
# Author  : Mansour Ayouni (2025)
#
# Description : A positional construct for navigating
# grid-like objects (1-indexed)
#
#------------------------------------------------------

func StzGrid(pArg)
	return new stzGrid(pArg)

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

	def SizeXY()
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
	
	def GoToNode(nCol, nRow)
		if IsValidPosition(nCol, nRow)
			@nCurrentCol = nCol
			@nCurrentRow = nRow

		else
			stzRaise("Invalid position! Column must be between 1 and " + @nCols + 
			         ", and row between 1 and " + @nRows + ".")
		ok

		def Goto(nCol, nRow)
			This.GoToNode(nCol, nRow)
		
	def GoToFirstNode()
		This.GoToNode(1, 1)
		
		def GotoFirstPosition()
			This.GoToNode(1, 1)

	def GoToLastNode()
		This.GoTo(@nCols, @nRows)
		
		def GotoLastPosition()
			This.GoTo(@nCols, @nRows)

	def GoToNextNode()

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

		def GoToNextPosition()
			This.GoToNextNode()

	def GoToPreviousNode()
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
		
		def GoToPreviousPosition()
			This.GoToPreviousNode()

	def Move(nCols, nRows)

		nNewCols = @nCurrentCol + nCols
		nNewRows = @nCurrentRow + nRows
		

		if IsValidPosition(nNewRow, nNewCol)
			@nCurrentRow = nNewRow
			@nCurrentCol = nNewCol
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
		oTemp.GoTo(@nCurrentCol, @nCurrentRow)
		oTemp.SetDirection(cDirection)
		
		while TRUE
			nRow = oTemp.CurrentRow()
			nCol = oTemp.CurrentColumn()
			
			call pCode(nCol, nRow)
			
			# Try to move to next position
			oNext = oTemp.GoToNextPosition()
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

	def EuclideanDistanceTo(nCol, nRow)
		# Euclidean distance (L2 norm)

		nDeltaCol = @nCurrentCol - nCol
		nDeltaRow = @nCurrentRow - nRow
		
		nResult =  sqrt(nDeltaRow * nDeltaRow + nDeltaCol * nDeltaCol)
		
		def EuclideanDistanceToNode(nCol, nRow)
			return This.EuclideanDistanceTo(nCol, nRow)

		def EucDistanceTo(nCol, nRow)
			return This.EuclideanDistanceTo(nCol, nRow)

		def EucDistTo(nCol, nRow)
			return This.EuclideanDistanceTo(nCol, nRow)

	#-- VISUALIZATION METHODS
	
	def Show()
		? This.ToString()
		
	def ToString()
		# Create an empty grid filled with "."
		aGrid = list(@nRows)
		for y = 1 to @nRows
			aGrid[y] = list(@nCols)
			for x = 1 to @nCols
				aGrid[y][x] = "."
			next
		next
		
		# Mark current position with "x"
		if IsValidPosition(@nCurrentRow, @nCurrentCol)
			aGrid[@nCurrentRow][@nCurrentCol] = "x"
		ok
		
		# Convert grid to string representation
		cResult = ""
		
		# Add X-axis labels
		cResult += "    " # Space for alignment with the grid
		for x = 1 to @nCols
			cResult += ""+ x + " "
		next
		cResult += NL()
		
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
			# Add Y indicator for current position
			if y = @nCurrentRow
				cResult += ""+ y + " > "
			else
				cResult += ""+ y + " │ "
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
		cResult += "─╯" + NL
		
		return cResult
