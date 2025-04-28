
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

	@nRows = 0
	@nCols = 0
	@nCurrentRow = 1
	@nCurrentCol = 1
	@nWrapMode = :NoWrap # :Wrap, :NoWrap
	@cDirection = :Forward # :Forward, :Backward, :Left, :Right, :Up, :Down
	
	def init(pArg)
		if isList(pArg) and len(pArg) = 2
			# Initialize with number of rows and columns
			@nRows = pArg[1]
			@nCols = pArg[2]
			
		elseif isObject(pArg) and classname(pArg) = "stzGrid"
			# Copy constructor
			@nRows = pArg.NumberOfRows()
			@nCols = pArg.NumberOfColumns()
			@nCurrentRow = pArg.CurrentRow()
			@nCurrentCol = pArg.CurrentColumn()
			@nWrapMode = pArg.WrapMode()
			@cDirection = pArg.Direction()
			
		else
			stzRaise("Incorrect param type! You must provide [nRows, nCols] or a stzGrid object.")
		ok
		
		# Initialize position to (1,1)
		@nCurrentRow = 1
		@nCurrentCol = 1
	
	#-- INFORMATION METHODS
	
	def Size()
		return [@nRows, @nCols]
		
	def NumberOfRows()
		return @nRows
		
	def NumberOfColumns()
		return @nCols
		
	def TotalNumberOfCells()
		return @nRows * @nCols
		
	def CurrentPosition()
		return [@nCurrentRow, @nCurrentCol]
		
	def CurrentRow()
		return @nCurrentRow
		
	def CurrentColumn()
		return @nCurrentCol
		
	def IsValidPosition(nRow, nCol)
		if nRow >= 1 and nRow <= @nRows and
		   nCol >= 1 and nCol <= @nCols
			return TRUE
		else
			return FALSE
		ok
		
	def IsCurrentPositionValid()
		return IsValidPosition(@nCurrentRow, @nCurrentCol)
		
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
			return self
		else
			stzRaise("Invalid direction! Valid options are: :forward, :backward, :left, :right, :up, :down")
		ok
		
	def WrapMode()
		return @nWrapMode
		
	def SetWrapMode(cWrapMode)
		cWrapMode = lower(cWrapMode)
		
		if cWrapMode = :wrap
			@nWrapMode = :Wrap
			return self
		but cWrapMode = :nowrap
			@nWrapMode = :NoWrap
			return self
		else
			stzRaise("Invalid wrap mode! Valid options are: :wrap, :nowrap")
		ok
		
	def EnableWrapping()
		@nWrapMode = :Wrap
		return self
		
	def DisableWrapping()
		@nWrapMode = :NoWrap
		return self
		
	#-- MOVEMENT METHODS
	
	def GoTo(nRow, nCol)
		if IsValidPosition(nRow, nCol)
			@nCurrentRow = nRow
			@nCurrentCol = nCol
			return self
		else
			stzRaise("Invalid position! Row must be between 1 and " + @nRows + 
			         ", and column between 1 and " + @nCols + ".")
		ok
		
	def GoToFirstPosition()
		return GoTo(1, 1)
		
	def GoToLastPosition()
		return GoTo(@nRows, @nCols)
		
	def GoToNextPosition()
		if @cDirection = :forward
			return MoveForward()
		but @cDirection = :backward
			return MoveBackward()
		but @cDirection = :left
			return MoveLeft()
		but @cDirection = :right
			return MoveRight()
		but @cDirection = :up
			return MoveUp()
		but @cDirection = :down
			return MoveDown()
		ok
		
	def GoToPreviousPosition()
		if @cDirection = :forward
			return MoveBackward()
		but @cDirection = :backward
			return MoveForward()
		but @cDirection = :left
			return MoveRight()
		but @cDirection = :right
			return MoveLeft()
		but @cDirection = :up
			return MoveDown()
		but @cDirection = :down
			return MoveUp()
		ok
		
	def MoveBy(nRowOffset, nColOffset)
		nNewRow = @nCurrentRow + nRowOffset
		nNewCol = @nCurrentCol + nColOffset
		
		if @nWrapMode = :Wrap
			if nNewRow < 1
				nNewRow = @nRows - ((abs(nNewRow) % @nRows))
				if nNewRow = 0
					nNewRow = @nRows
				ok
			elseif nNewRow > @nRows
				nNewRow = ((nNewRow - 1) % @nRows) + 1
			ok
			
			if nNewCol < 1
				nNewCol = @nCols - ((abs(nNewCol) % @nCols))
				if nNewCol = 0
					nNewCol = @nCols
				ok
			elseif nNewCol > @nCols
				nNewCol = ((nNewCol - 1) % @nCols) + 1
			ok
			
			@nCurrentRow = nNewRow
			@nCurrentCol = nNewCol
			return self
			
		else # :NoWrap
			if IsValidPosition(nNewRow, nNewCol)
				@nCurrentRow = nNewRow
				@nCurrentCol = nNewCol
				return self
			else
				return NULL
			ok
		ok
		
	def MoveForward()
		@cDirection = :Forward
		
		nNewCol = @nCurrentCol + 1
		if nNewCol <= @nCols
			@nCurrentCol = nNewCol
			return self
		else
			nNewRow = @nCurrentRow + 1
			
			if @nWrapMode = :Wrap
				if nNewRow > @nRows
					@nCurrentRow = 1
				else
					@nCurrentRow = nNewRow
				ok
				@nCurrentCol = 1
				return self
				
			else # :NoWrap
				if nNewRow <= @nRows
					@nCurrentRow = nNewRow
					@nCurrentCol = 1
					return self
				else
					return NULL # Reached the end of grid
				ok
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
			
			if @nWrapMode = :Wrap
				if nNewRow < 1
					@nCurrentRow = @nRows
				else
					@nCurrentRow = nNewRow
				ok
				@nCurrentCol = @nCols
				return self
				
			else # :NoWrap
				if nNewRow >= 1
					@nCurrentRow = nNewRow
					@nCurrentCol = @nCols
					return self
				else
					return NULL # Reached the beginning of grid
				ok
			ok
		ok
		
	def MoveRight()
		@cDirection = :Right
		
		nNewCol = @nCurrentCol + 1
		
		if @nWrapMode = :Wrap
			if nNewCol > @nCols
				@nCurrentCol = 1
			else
				@nCurrentCol = nNewCol
			ok
			return self
			
		else # :NoWrap
			if nNewCol <= @nCols
				@nCurrentCol = nNewCol
				return self
			else
				return NULL # Can't move further right
			ok
		ok
		
	def MoveLeft()
		@cDirection = :Left
		
		nNewCol = @nCurrentCol - 1
		
		if @nWrapMode = :Wrap
			if nNewCol < 1
				@nCurrentCol = @nCols
			else
				@nCurrentCol = nNewCol
			ok
			return self
			
		else # :NoWrap
			if nNewCol >= 1
				@nCurrentCol = nNewCol
				return self
			else
				return NULL # Can't move further left
			ok
		ok
		
	def MoveUp()
		@cDirection = :Up
		
		nNewRow = @nCurrentRow - 1
		
		if @nWrapMode = :Wrap
			if nNewRow < 1
				@nCurrentRow = @nRows
			else
				@nCurrentRow = nNewRow
			ok
			return self
			
		else # :NoWrap
			if nNewRow >= 1
				@nCurrentRow = nNewRow
				return self
			else
				return NULL # Can't move further up
			ok
		ok
		
	def MoveDown()
		@cDirection = :Down
		
		nNewRow = @nCurrentRow + 1
		
		if @nWrapMode = :Wrap
			if nNewRow > @nRows
				@nCurrentRow = 1
			else
				@nCurrentRow = nNewRow
			ok
			return self
			
		else # :NoWrap
			if nNewRow <= @nRows
				@nCurrentRow = nNewRow
				return self
			else
				return NULL # Can't move further down
			ok
		ok
		
	#-- TRAVERSAL METHODS
	
	def Positions()
		aResult = []
		
		for i = 1 to @nRows
			for j = 1 to @nCols
				add(aResult, [i, j])
			next
		next
		
		return aResult
		
	def ForEachPosition(pCode)
		for i = 1 to @nRows
			for j = 1 to @nCols
				@nCurrentRow = i
				@nCurrentCol = j
				call pCode(i, j)
			next
		next
		return self
		
	def TraverseInDirection(cDirection, pCode)
		oTemp = new stzGrid([@nRows, @nCols])
		oTemp.GoTo(@nCurrentRow, @nCurrentCol)
		oTemp.SetDirection(cDirection)
		oTemp.SetWrapMode(@nWrapMode)
		
		while TRUE
			nRow = oTemp.CurrentRow()
			nCol = oTemp.CurrentColumn()
			
			call pCode(nRow, nCol)
			
			# Try to move to next position
			oNext = oTemp.GoToNextPosition()
			if oNext = NULL
				# Reached the boundary in NoWrap mode
				exit
			ok
			
			# Detect if we've completed a full cycle in Wrap mode
			if @nWrapMode = :Wrap and
			   nRow = oTemp.CurrentRow() and nCol = oTemp.CurrentColumn()
				exit
			ok
		end
		
		return self
		
	#-- NEIGHBORS & RELATIVE POSITIONS
	
	def Neighbors()
		aResult = []
		
		# Check each of the 8 neighbors
		aDirections = [ [-1,-1], [-1,0], [-1,1], 
		                [0,-1],          [0,1],
		                [1,-1],  [1,0],  [1,1] ]
		
		for aDir in aDirections
			nRow = @nCurrentRow + aDir[1]
			nCol = @nCurrentCol + aDir[2]
			
			if IsValidPosition(nRow, nCol)
				add(aResult, [nRow, nCol])
			ok
		next
		
		return aResult
		
	def AdjacentNeighbors()
		aResult = []
		
		# Check the 4 adjacent neighbors (no diagonals)
		aDirections = [ [0,-1], [-1,0], [1,0], [0,1] ]
		
		for aDir in aDirections
			nRow = @nCurrentRow + aDir[1]
			nCol = @nCurrentCol + aDir[2]
			
			if IsValidPosition(nRow, nCol)
				add(aResult, [nRow, nCol])
			ok
		next
		
		return aResult
		
	def PositionAbove()
		nRow = @nCurrentRow - 1
		nCol = @nCurrentCol
		
		if IsValidPosition(nRow, nCol)
			return [nRow, nCol]
		else
			return NULL
		ok
		
	def PositionBelow()
		nRow = @nCurrentRow + 1
		nCol = @nCurrentCol
		
		if IsValidPosition(nRow, nCol)
			return [nRow, nCol]
		else
			return NULL
		ok
		
	def PositionToLeft()
		nRow = @nCurrentRow
		nCol = @nCurrentCol - 1
		
		if IsValidPosition(nRow, nCol)
			return [nRow, nCol]
		else
			return NULL
		ok
		
	def PositionToRight()
		nRow = @nCurrentRow
		nCol = @nCurrentCol + 1
		
		if IsValidPosition(nRow, nCol)
			return [nRow, nCol]
		else
			return NULL
		ok
		
	def DistanceTo(nRow, nCol)
		# Manhattan distance (L1 norm)
		return abs(@nCurrentRow - nRow) + abs(@nCurrentCol - nCol)
		
	def EuclideanDistanceTo(nRow, nCol)
		# Euclidean distance (L2 norm)
		nDeltaRow = @nCurrentRow - nRow
		nDeltaCol = @nCurrentCol - nCol
		return sqrt(nDeltaRow * nDeltaRow + nDeltaCol * nDeltaCol)
		
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
		cResult += "─╯"
		
		return cResult
