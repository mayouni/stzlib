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

class stzGrid From stzObject
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
	@nCurrentCol
	@nCurrentRow

	@cDirection = :Forward # :Forward, :Backward, :Left, :Right, :Up, :Down

	@aObstacles = []
	@aPath = []
	@cObstacleChar = "■"
	@cPathChar = "○"
	@cCurrentChar = "x"
	@cEmptyChar = "."
	@cNeighborChar = "N"

	@bShowCoordinates = TRUE
	@bShowObstacles = TRUE
	@bShowPath = TRUE

	# When set via ReplaceAll(:With = val), Content() materializes
	# a 2D list of the grid dimensions filled with this value.
	@xFillValue = NULL
	@bHasFillValue = 0

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

		def NumberOfCells()
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
			return [ @nCurrentCol, @nCurrentRow ]

		def CurrentNode()
			return [ @nCurrentCol, @nCurrentRow ]

		def CurrentCell()
			return [ @nCurrentCol, @nCurrentRow ]

	def CurrentColumn()
		return @nCurrentCol

	def CurrentRow()
		return @nCurrentRow
		
	def IsValidPosition(_nCol_, _nRow_)

		if _nCol_ >= 1 and _nCol_ <= @nCols and
		   _nRow_ >= 1 and _nRow_ <= @nRows

			return TRUE
		else
			return FALSE
		ok

		def IsValideNode(_nCol_, _nRow_)
			return This.IsValidPosition(_nCol_, _nRow_)

		def IsValidCell(_nCol_, _nRow_)
			return This.IsValidPosition(_nCol_, _nRow_)

	def IsCurrentPositionValid() # For debugging purposes
		return IsValidPosition( @nCurrentCol, @nCurrentRow)

		def IsCurrentNodeValid()
			return This.IsCurrentPositionValid()

		def IsCurrentCellValid()
			return This.IsCurrentPositionValid()

	#-- CONFIGURATION
	
	def Direction()
		return @cDirection
		
	def SetDirection(_cDirection_)
		_cDirection_ = StzLower(_cDirection_)
		
		if _cDirection_ = :forward or 
		   _cDirection_ = :backward or 
		   _cDirection_ = :left or 
		   _cDirection_ = :right or 
		   _cDirection_ = :up or 
		   _cDirection_ = :down
			@cDirection = _cDirection_

		else
			stzRaise("Invalid direction! Valid options are: :forward, :backward, :left, :right, :up, :down")
		ok

	def SetCurrentNode(_nCol_, _nRow_)
		if CheckParams()
			if NOT (isNumber(_nCol_) and isNumber(_nRow_))
				StzRaise("Incorrect param type! nCol and nRow must be both numbers.")
			ok
		ok

		if (_nCol_ < 1 or _nCol_ > @nCols) or (_nRow_ < 1 or _nRow_ > @nRows)
			stzRaise("Incorrect param value! nCol must be in the grid range of " + @nCols + " X " + @nRow + ".")
		ok

		@nCurrentCol = _nCol_
		@nCurrentRow = _nRow_

		def SetCurrentPosition(_nCol_, _nRow_)
			This.SetCurrentNode(_nCol_, _nRow_)

		def SetCurrenCell(_nCol_, _nRow_)
			This.SetCurrentNode(_nCol_, _nRow_)

	#-- MOVEMENT METHODS
	
	def MoveToNode(_nCol_, _nRow_)
		if NOT IsValidPosition(_nCol_, _nRow_)
			StzRaise("Can't move! The provided position is not valid.")
		ok

		if NOT IsObstacle(_nCol_, _nRow_)
			@nCurrentCol = _nCol_
			@nCurrentRow = _nRow_
		ok

		def Moveto(_nCol_, _nRow_)
			This.MoveToNode(_nCol_, _nRow_)

		def MoveToCell(_nCol_, _nRow_)
			This.MoveToNode(_nCol_, _nRow_)

	def MoveToFirstNode()
		This.MoveToNode(1, 1)
		
		def MovetoFirstPosition()
			This.MoveToNode(1, 1)

		def MoveToFirstCell()
			This.MoveToNode(1, 1)

	def MoveToLastNode()
		This.MoveToNode(@nCols, @nRows)
		
		def MovetoLastPosition()
			This.MoveToNode(@nCols, @nRows)

		def MoveToLast()
			This.MoveToNode(@nCols, @nRows)

		def MoveLast()
			This.MoveToNode(@nCols, @nRows)

		def MovetoLastCell()
			This.MoveToNode(@nCols, @nRows)

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

		else
			StzRaise("Can't move! Unsupported direction.")
		ok

		def MoveToNextPosition()
			This.MoveToNextNode()

		def MoveToNext()
			This.MoveToNextNode()

		def MoveNext()
			This.MoveToNextNode()

		def MoveToNextCell()
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

		else
			StzRaise("Can't move! Unsupported direction.")
		ok
		
		def MoveToPreviousPosition()
			This.MoveToPreviousNode()

		def MoveToPrevious()
			This.MoveToPreviousNode()

		def MovePrevious()
			This.MoveToPreviousNode()

		def MoveToPreviousCell()
			This.MoveToPreviousNode()

	#--

	def MoveToNthNode(n)
		if @cDirection = :forward
			This.MoveToNthNodeBackward()

		but @cDirection = :backward
			This.MoveToNthNodeForward()

		but @cDirection = :left
			This.MoveToNthNodeRight()

		but @cDirection = :right
			This.MoveMoveToNthNodeLeft()

		but @cDirection = :up
			This.MoveToNthNodeDown()

		but @cDirection = :down
			This.MoveToNthNodeUp()

		else
			StzRaise("Can't move! Unsupported direction.")
		ok

		def MoveToNthPosition(n)
			This.MoveToNthNode(n)

		def MoveToNthCell(n)
			This.MoveToNthNode(n)

	def MoveToNextNthNode(n)
		_aNode_ = This.NextNthNode(n)
		This.MoveToNode(_aNode_[1], _aNode_[2])

		def MoveToNthNextNode(n)
			This.MoveToNextNthNode(n)

		def MoveToNthNext(n)
			This.MoveToNextNthNode(n)

		def MoveToNextNth(n)
			This.MoveToNextNthNode(n)


		def MoveToNextNthPosition(n)
			This.MoveToNextNthNode(n)

		def MoveToNthNextPosition(n)
			This.MoveToNextNthNode(n)


		def MoveToNextNthCell(n)
			This.MoveToNextNthNode(n)

		def MoveToNthNextCell(n)
			This.MoveToNextNthNode(n)

	#--

	def MoveToPreviousNthNode(n)
		This.MoveToNode(This.PreviousNthNode(n))

		def MoveToNthPreviousNode(n)
			This.MoveToPreviousNthNode(n)

		def MoveToNthPrevious(n)
			This.MoveToPreviousNthNode(n)

		def MoveToPreviousNth(n)
			This.MoveToPreviousNthNode(n)


		def MoveToPreviousNthPosition(n)
			This.MoveToPreviousNthNode(n)

		def MoveToNthPreviousPosition(n)
			This.MoveToPreviousNthNode(n)


		def MoveToPreviousNthCell(n)
			This.MoveToPreviousNthNode(n)

		def MoveToNthPreviousCell(n)
			This.MoveToPreviousNthNode(n)

	#--

	def MoveBy(nCols, nRows)

		_nNewCols_ = @nCurrentCol + nCols
		_nNewRows_ = @nCurrentRow + nRows
		

		if NOT IsValidPosition(_nNewCols_, _nNewRows_)
			StzRaise("Can't move! The provided position is not valid.")
		ok

		if NOT IsObstacle(_nNewCols_, _nNewRows_)
			@nCurrentRow = _nNewRows_
			@nCurrentCol = _nNewCols_
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

		but @cDirection = :Backward
			This.MoveBackwardN(n)

		but @cDirection = :Up
			This.MoveUpN(n)

		but @cDirection = :Down
			This.MoveDownN(n)

		but @cDirection = :Left
			This.MoveLeftN(n)

		but @cDirection = :Right
			This.MoveRightN(n)

		else
			StzRaise("Can't move! Unsupported direction.")
		ok
		
		def MoveNNodes(n)
			This.MoveN(n)

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
		_nNewCol_ = @nCurrentCol + n

		_nTempCol_ = @nCurrentCol
		_nTempRow_ = @nCurrentRow

		if _nNewCol_ <= @nCols
			_nTempCol_  = _nNewCol_
		else
			_nNewRow_ = @nCurrentRow + n

			if _nNewRow_ <= @nRows
				_nTempRow_ = _nNewRow_
				_nTempCol_ = 1
			ok

		ok
		
		if NOT IsObstacle(_nTempCol_, _nTempRow_)
			@nCurrentCol = _nTempCol_
			@nCurrentRow = _nTempRow_
		ok

		def MoveForwardNNodes(n)
			This.MoveForwardN(n)

		def MoveNForward(n)
			This.MoveForwardN(n)

		def MoveNNodesForward(n)
			This.MoveForwardN(n)

		def MoveForwardNCells(n)
			This.MoveForwardN(n)

		def MoveNCellsForward(n)
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
		_nNewCol_ = @nCurrentCol - n

		_nTempCol_ = @nCurrentCol
		_nTempRow_ = @nCurrentRow

		if _nNewCol_ >= 1
			_nTempCol_ = _nNewCol_
		else
			_nNewRow_ = @nCurrentRow - n
			
			if _nNewRow_ >= 1
				_nTempRow_ = _nNewRow_
				_nTempCol_ = @nCols

			ok
		ok

		if NOT IsObstacle(_nTempCol_, _nTempRow_)
			@nCurrentCol = _nTempCol_
			@nCurrentRow = _nTempRow_
		ok

		def MoveBackwardNNodes(n)
			This.MoveBackwardN(n)

		def MoveNBackward(n)
			This.MoveBackwardN(n)

		def MoveNNodesBackward(n)
			This.MoveBackwardN(n)

		def MoveBackwardNCells(n)
			This.MoveBackwardN(n)

		def MoveNCellsBackward(n)
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
		_nNewCol_ = @nCurrentCol + n
		
		if _nNewCol_ <= @nCols and NOT IsObstacle(_nNewCol_, @nCurrentRow)
			@nCurrentCol = _nNewCol_
		ok

		def MoveRightNNodes(n)
			This.MoveRightN(n)

		def MoveNRight()
			This.MoveRightN(n)

		def MoveNNodesRight()
			This.MoveRightN(n)

		def MoveRightNCells(n)
			This.MoveRightN(n)

		def MoveNCellsRight()
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
		_nNewCol_ = @nCurrentCol - n
	
		if _nNewCol_ >= 1 and NOT IsObstacle(_nNewCol_, @nCurrentRow)
			@nCurrentCol = _nNewCol_
		ok

		def MoveLeftNNodes(n)
			This.MoveLeftN(n)

		def MoveNLeft()
			This.MoveLeftN(n)

		def MoveNNodesLeft()
			This.MoveLeftN(n)

		def MoveLeftNCells(n)
			This.MoveLeftN(n)

		def MoveNCellsLeft()
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
		_nNewRow_ = @nCurrentRow - n
		
		if _nNewRow_ >= 1 and NOt IsObstacle(@nCurrentCol, _nNewRow_)
			@nCurrentRow = _nNewRow_
		ok

		def MoveUpNNodes(n)
			This.MoveUpN(n)

		def MoveNUp()
			This.MoveUpN(n)

		def MoveNNodesUp()
			This.MoveUpN(n)

		def MoveUpNCells(n)
			This.MoveUpN(n)

		def MoveNCellsUp()
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
		_nNewRow_ = @nCurrentRow + n
		
		if _nNewRow_ <= @nRows and NOT IsObstacle(@nCurrentCol, _nNewRow_)
			@nCurrentRow = _nNewRow_
		ok

		def MoveDownNNodes(n)
			This.MoveDownN(n)

		def MoveNDown()
			This.MoveDownN(n)

		def MoveNNodesDown()
			This.MoveDownN(n)

		def MoveDownNCells(n)
			This.MoveDownN(n)

		def MoveNCellsDown()
			This.MoveDownN(n)

	def MoveDown()
		This.MoveDownN(1)

	#-- TRAVERSAL METHODS
	
	def Nodes()
		_aResult_ = []
		
		for i = 1 to @nCols
			for j = 1 to @nRows
				_aResult_ +  [i, j]
			next
		next
		
		return _aResult_
		
		def Positions()
			return This.Nodes()

		def Cells()
			return This.Nodes()
		
	#-- NEIGHBORS & RELATIVE POSITIONS

	def Neighbors()
		_aResult_ = []
		
		# Check each of the 8 neighbors

		_aDirections_ = [
			[-1,-1], [-1,0], [-1,1], 
		      	[0,-1],          [0,1],
		     	[1,-1],  [1,0],  [1,1]
		]
		
		_nLen_ = len(_aDirections_)

		for i = 1 to _nLen_
			_nRow_ = @nCurrentRow + _aDirections_[i][1]
			_nCol_ = @nCurrentCol + _aDirections_[i][2]

			if IsValidPosition(_nCol_, _nRow_)
				_aResult_ +  [_nCol_, _nRow_]
			ok
		next

		# Sort col-then-row for stable, position-ordered output.
		# Ring's `sort()` chokes on lists-of-lists; use a simple
		# pair-comparison sort. Matches the original narrative tests
		# which were written when the iteration was column-major.
		_nResultLen_2 = len(_aResult_)
		for _i_ = 1 to _nResultLen_2 - 1
			_nResultLen_ = len(_aResult_)
			for _j_ = _i_ + 1 to _nResultLen_
				if _aResult_[_i_][1] > _aResult_[_j_][1] or
				   (_aResult_[_i_][1] = _aResult_[_j_][1] and _aResult_[_i_][2] > _aResult_[_j_][2])
					_t_ = _aResult_[_i_]
					_aResult_[_i_] = _aResult_[_j_]
					_aResult_[_j_] = _t_
				ok
			next
		next
		return _aResult_

		def AdjacentNodes()
			return This.Neighbors()

		def AdjacentCells()
			return This.Neighbors()

		def AdjacentNeighbors()
			return This.Neighbors()

		def AdjacentPositions()
			return This.Neighbors()

	def ShowNeighbors()
		This.ShowNodes(This.Neighbors(), @cNeighborChar)

		def ShowAdjacent()
			This.PaintNeighbors()

		def ShowAdjacents()
			This.ShowNeighbors()

		def ShowAdjacentNodes()
			This.ShowNeighbors()

		def ShowAdjacentCells()
			This.ShowNeighbors()

	def NodeUp()

		_nCol_ = @nCurrentCol
		_nRow_ = @nCurrentRow - 1
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position above the current position!")
		ok

		def PositionUp()
			return This.NodeUp()

		def CellUp()
			return This.NodeUp()

		def NodeAbove()
			return This.NodeUp()

		def CellAbove()
			return This.NodeUp()

	def NodeUpLeft()

		_nCol_ = @nCurrentCol - 1
		_nRow_ = @nCurrentRow - 1
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position above the current position!")
		ok

		def PositionUpLeft()
			return This.NodeUpLeft()

		def CellUpLeft()
			return This.NodeUpLeft()

	def NodeUpRight()

		_nCol_ = @nCurrentCol + 1
		_nRow_ = @nCurrentRow - 1
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position above the current position!")
		ok

		def PositionUpRight()
			return This.NodeUpRight()

		def CellUpRight()
			return This.NodeUpRight()

	def NodeDown()

		_nCol_ = @nCurrentCol
		_nRow_ = @nCurrentRow + 1
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position below the current position!")
		ok
		
		def PositionDown()
			return This.NodeDown()

		def CellDown()
			return This.NodeDown()

		def NodeBelow()
			return This.NodeDown()

		def CellBelow()
			return This.NodeDown()

	def NodeDownLeft()

		_nCol_ = @nCurrentCol - 1
		_nRow_ = @nCurrentRow + 1
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position below the current position!")
		ok

		def PositionDownLeft()
			return This.NodeDownLeft()

		def CellDownLeft()
			return This.NodeDownLeft()

	def NodeDownRight()

		_nCol_ = @nCurrentCol + 1
		_nRow_ = @nCurrentRow + 1
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position below the current position!")
		ok

		def PositionDownRight()
			return This.NodeDownRight()

		def CellDownRight()
			return This.NodeDownRight()

	def NodeLeft()

		_nCol_ = @nCurrentCol - 1
		_nRow_ = @nCurrentRow
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position to the left of the current position!")
		ok
		
		def PositionLeft()
			return This.NodeLeft()

		def CellLeft()
			return This.NodeLeft()

	def NodeRight()

		_nCol_ = @nCurrentCol + 1
		_nRow_ = @nCurrentRow
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position to the right of the current position!")
		ok
		
		def PositionRight()
			return This.NodeRight()

		def CellRight()
			return This.NodeRight()

	def DistanceTo(_nCol_, _nRow_)
		# Manhattan distance (L1 norm)
		_nResult_ = abs(@nCurrentCol - _nCol_) + abs(@nCurrentRow - _nRow_)
		return _nResult_
		
		def DistanceToNode(_nCol_, _nRow_)
			return This.DistanceTo(_nCol_, _nRow_)

		def DistanceToCell(_nCol_, _nRow_)
			return This.DistanceTo(_nCol_, _nRow_)

		def ManhattanDistanceTo(_nCol_, _nRow_)
			return This.DistanceTo(_nCol_, _nRow_)

		def ManhattanDistanceToNode(_nCol_, _nRow_)
			return This.DistanceTo(_nCol_, _nRow_)

	def EuclideanDistanceTo(_nCol_, _nRow_)
    		# Euclidean distance (L2 norm)

		_nDeltaCol_ = _nCol_ - @nCurrentCol
		_nDeltaRow_ = _nRow_ - @nCurrentRow

		# Calculate using Pythagorean theorem
		_nResult_ = ring_sqrt( _nDeltaCol_ * _nDeltaCol_ + _nDeltaRow_ * _nDeltaRow_ )

		return _nResult_

		def EuclideanDistanceToNode(_nCol_, _nRow_)
			return This.EuclideanDistanceTo(_nCol_, _nRow_)

		def EuclideanDistanceToCell(_nCol_, _nRow_)
			return This.EuclideanDistanceTo(_nCol_, _nRow_)

		def EucDistanceTo(_nCol_, _nRow_)
			return This.EuclideanDistanceTo(_nCol_, _nRow_)

		def EucDistTo(_nCol_, _nRow_)
			return This.EuclideanDistanceTo(_nCol_, _nRow_)
	
	#-- N-NODE RELATIVE POSITION METHODS
	
	def NextNthNode(n)
		# Save current position
		_nOldCol_ = @nCurrentCol
		_nOldRow_ = @nCurrentRow
		_cOldDirection_ = @cDirection
		
		# Move n steps in current direction
		This.MoveNNodes(n)
		
		# Get the resulting position
		_nCol_ = @nCurrentCol
		_nRow_ = @nCurrentRow
		
		# Restore original position
		@nCurrentCol = _nOldCol_
		@nCurrentRow = _nOldRow_
		@cDirection = _cOldDirection_
		
		# Return the calculated position
		return [_nCol_, _nRow_]
		

		def NextNthPosition(n)
			return This.NextNthNode(n)

		def NextNthCell(n)
			return This.NextNthNode(n)

		def NthNextNode(n)
			return This.NextNthNode(n)

		def NthNextPosition(n)
			return This.NextNthNode(n)

		def NthNextCell(n)
			return This.NextNthNode(n)

	def PreviousNthNode(n)
		# Save current position
		_nOldCol_ = @nCurrentCol
		_nOldRow_ = @nCurrentRow
		_cOldDirection_ = @cDirection
		
		# Move n steps in reverse direction
		for i = 1 to n
			This.MoveToPreviousNode()
		next
		
		# Get the resulting position
		_nCol_ = @nCurrentCol
		_nRow_ = @nCurrentRow
		
		# Restore original position
		@nCurrentCol = _nOldCol_
		@nCurrentRow = _nOldRow_
		@cDirection = _cOldDirection_
		
		# Return the calculated position
		return [_nCol_, _nRow_]
		

		def PreviousNthPosition(n)
			return This.PreviousNthNode(n)

		def PreviousNthCell(n)
			return This.PreviousNthNode(n)

		def PreviousNextNode(n)
			return This.PreviousNthNode(n)

		def NthPreviousPosition(n)
			return This.PreviousNthNode(n)

		def NthPreviousCell(n)
			return This.PreviousNthNode(n)

	
	def NthNodeUp(n)
		_nCol_ = @nCurrentCol
		_nRow_ = @nCurrentRow - n
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position " + n + " nodes above the current position!")
		ok
		
		def NthPositionUp(n)
			return This.NthNodeUp(n)
	
		def NthCellUp(n)
			return This.NthNodeUp(n)

	def NthNodeDown(n)
		_nCol_ = @nCurrentCol
		_nRow_ = @nCurrentRow + n
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position " + n + " nodes below the current position!")
		ok
		
		def NthPositionDown(n)
			return This.NthNodeDown(n)

		def NthCellDown(n)
			return This.NthNodeDown(n)

	def NthNodeLeft(n)
		_nCol_ = @nCurrentCol - n
		_nRow_ = @nCurrentRow
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position " + n + " nodes to the left of the current position!")
		ok
		
		def NthPositionLeft(n)
			return This.NthNodeLeft(n)

		def NthCellLeft(n)
			return This.NthNodeLeft(n)

	def NthNodeRight(n)
		_nCol_ = @nCurrentCol + n
		_nRow_ = @nCurrentRow
		
		if IsValidPosition(_nCol_, _nRow_)
			return [_nCol_, _nRow_]
		else
			StzRaise("No valid position " + n + " nodes to the right of the current position!")
		ok
		
		def NthPositionRight(n)
			return This.NthNodeRight(n)

		def NthCellRight(n)
			return This.NthNodeRight(n)

	#-- OBSTACLES MANAGEMENT
	
	def AddObstacle(_nCol_, _nRow_)
		if NOT IsValidPosition(_nCol_, _nRow_)
			stzRaise("Invalid position for obstacle!")
		ok
		
		if NOT This.IsObstacle(_nCol_, _nRow_)
			@aObstacles + [_nCol_, _nRow_]
		ok
		
	def AddObstacles(aPositions)
		_nPositionsLen_ = len(aPositions)
		for i = 1 to _nPositionsLen_
			if isList(aPositions[i]) and len(aPositions[i]) = 2
				This.AddObstacle(aPositions[i][1], aPositions[i][2])
			ok
		next
		
	def RemoveObstacle(_nCol_, _nRow_)
		_nObstaclesLen_4 = len(@aObstacles)
		for i = 1 to _nObstaclesLen_4
			if @aObstacles[i][1] = _nCol_ and @aObstacles[i][2] = _nRow_
				del(@aObstacles, i)
				return
			ok
		next
		
	def ClearObstacles()
		@aObstacles = []
		
		def RemoveObstacles()
			@aObstacles = []

	def IsObstacle(_nCol_, _nRow_)
		_nObstaclesLen_3 = len(@aObstacles)
		for i = 1 to _nObstaclesLen_3
			if @aObstacles[i][1] = _nCol_ and @aObstacles[i][2] = _nRow_
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

		_nLen_ = len(panColRow)
		_bResult_ = TRUE

		for i = 1 to _nLen_
			if NOT This.IsObstacle(panColRow[1], panColRow[2])
				_bResult_ = FALSE
				exit
			ok
		next

		return _bResult_

	def SetObstacleChar(_cChar_)
		if isString(_cChar_) and @IsChar(_cChar_)
			@cObstacleChar = _cChar_
		else
			stzRaise("Obstacle character must be a single character!")
		ok

		def SetObstacleNode(_cChar_)
			This.SetObstacleChar(_cChar_)

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

		_nLen_ = len(panColRow)

		for i = 1 to _nLen_
			@aPath + [ panColRow[i][1], panColRow[i][2] ]
		next

		def AddPathNodes(panColRow)
			This.AddPath(panColRow)

		def AddPathCells(pancolRow)
			This.AddPath(panColRow)

	def AddPathNode(_nCol_, _nRow_)
		if NOT IsValidPosition(_nCol_, _nRow_)
			stzRaise("Invalid position for path node!")
		ok
		
		@aPath + [_nCol_, _nRow_]
		
		def AddPathCell(_nCol_, _nRow_)
			This.AddPathNode(_nCol_, _nRow_)

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

	def SetPathChar(_cChar_)
		if isString(_cChar_) and IsChar(_cChar_)
			@cPathChar = _cChar_
		else
			stzRaise("Path character must be a single character!")
		ok
		
	def PathChar()
		return @cPathChar
		
	def SetCurrentChar(_cChar_)
		if isString(_cChar_) and IsChar(_cChar_)
			@cCurrentChar = _cChar_
		else
			stzRaise("Current position character must be a single character!")
		ok
		
	def CurrentChar()
		return @cCurrentChar
		
	def SetEmptyChar(_cChar_)
		if isString(_cChar_) and IsChar(_cChar_)
			@cEmptyChar = _cChar_
		else
			stzRaise("Empty cell character must be a single character!")
		ok
		
	def EmptyChar()
		return @cEmptyChar
			
	#TODO // Add this method AddRandomPath()

	#-- PATH FINDING ALGORITHMS

	def ShortestPath(panStart, panEnd)
		# Implementation of A* algorithm for path finding

		if CheckParams()
			if NOT (isList(panStart) and IsPairOfNumbers(panStart) and
				isList(panEnd) and IsPairOfNumbers(panEnd))

				StzRaise("Incorrect param type! panStart and panEnd must be pairs of numbers.")

			ok
		ok

		_nStartCol_ = panStart[1]
		_nStartRow_ = panStart[2]
		_nEndCol_ = panEnd[1]
		_nEndRow_ = panEnd[2]
		
		# Validate positions

		if NOT IsValidPosition(_nStartCol_, _nStartRow_)
			StzRaise("Invalid start position!")
		ok
		
		if NOT IsValidPosition(_nEndCol_, _nEndRow_)
			StzRaise("Invalid end position!")
		ok
		
		# Check if start or end is an obstacle

		if This.IsObstacle(_nStartCol_, _nStartRow_)
			stzRaise("Start position is an obstacle!")
		ok
		
		if This.IsObstacle(_nEndCol_, _nEndRow_)
			stzRaise("End position is an obstacle!")
		ok
		
		# Initialize data structures

		_aOpenSet_ = []          # Nodes to be evaluated
		_aClosedSet_ = []        # Nodes already evaluated
		_aCameFrom_ = []         # Map to reconstruct path
		_aGScore_ = []           # Cost from start to current node
		_aFScore_ = []           # Estimated total cost from start to goal through current node
		
		# Initialize with start position

		_aOpenSet_ + [_nStartCol_, _nStartRow_]
		
		# Initialize gScore with infinity for all positions

		for i = 1 to @nRows
			for j = 1 to @nCols
				_aGScore_ + [[j, i], 999999]
				_aFScore_ + [[j, i], 999999]
			next
		next
		
		# Set scores for start position

		This.SetScoreAt(_aGScore_, _nStartCol_, _nStartRow_, 0)
		This.SetScoreAt(_aFScore_, _nStartCol_, _nStartRow_, This.HeuristicCost([_nStartCol_, _nStartRow_], [_nEndCol_, _nEndRow_]))
		
		# Main loop

		while len(_aOpenSet_) > 0

			# Get node with lowest fScore

			_nCurrentIdx_ = This.LowestFScore(_aOpenSet_, _aFScore_)
			_nCurrentCol_ = _aOpenSet_[_nCurrentIdx_][1]
			_nCurrentRow_ = _aOpenSet_[_nCurrentIdx_][2]
			
			# Check if we reached the goal

			if _nCurrentCol_ = _nEndCol_ and _nCurrentRow_ = _nEndRow_
				# Reconstruct path
				@aPath = This.ReconstructPath(_aCameFrom_, _nCurrentCol_, _nCurrentRow_)
				return @aPath
			ok
			
			# Remove current from open set and add to closed set

			del(_aOpenSet_, _nCurrentIdx_)
			_aClosedSet_ + [_nCurrentCol_, _nCurrentRow_]
			
			# Check all neighbors

			_aNeighbors_ = This.WalkableNeighbors(_nCurrentCol_, _nCurrentRow_)
			
			_nNeighborsLen_ = len(_aNeighbors_)
			for i = 1 to _nNeighborsLen_
				_nNeighborCol_ = _aNeighbors_[i][1]
				_nNeighborRow_ = _aNeighbors_[i][2]
				
				# Skip if neighbor is in closed set

				if This.IsInList(_aClosedSet_, _nNeighborCol_, _nNeighborRow_)
					loop
				ok
				
				# Calculate tentative gScore

				_nTentativeGScore_ = This.GetScoreAt(_aGScore_, _nCurrentCol_, _nCurrentRow_) + 1
				
				# Check if neighbor is not in open set

				if NOT This.IsInList(_aOpenSet_, _nNeighborCol_, _nNeighborRow_)
					_aOpenSet_ + [_nNeighborCol_, _nNeighborRow_]

				but _nTentativeGScore_ >= This.GetScoreAt(_aGScore_, _nNeighborCol_, _nNeighborRow_)
					# Not a better path
					loop
				ok
				
				# This path is better, record it

				_aCameFrom_ = This.SetCameFrom(_aCameFrom_, _nNeighborCol_, _nNeighborRow_, _nCurrentCol_, _nCurrentRow_)
				This.SetScoreAt(_aGScore_, _nNeighborCol_, _nNeighborRow_, _nTentativeGScore_)
				This.SetScoreAt(_aFScore_, _nNeighborCol_, _nNeighborRow_, 
					_nTentativeGScore_ + This.HeuristicCost([_nNeighborCol_, _nNeighborRow_], [_nEndCol_, _nEndRow_]))
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

		_nStartCol_ = panStart[1]
		_nStartRow_ = panStart[2]
		_nEndCol_ = panEnd[1]
		_nEndRow_ = panEnd[2]

		# Validate positions

		if NOT IsValidPosition(_nStartCol_, _nStartRow_)
			stzRaise("Invalid start position!")
		ok
		
		if NOT IsValidPosition(_nEndCol_, _nEndRow_)
			stzRaise("Invalid end position!")
		ok
		
		# Clear existing path

		This.ClearPath()
		
		# Start from start position

		This.AddPathNode(_nStartCol_, _nStartRow_)
		
		# Current position

		_nCurrentCol_ = _nStartCol_
		_nCurrentRow_ = _nStartRow_
		
		# First move horizontally

		while _nCurrentCol_ != _nEndCol_

			if _nCurrentCol_ < _nEndCol_
				_nCurrentCol_++
			else
				_nCurrentCol_--
			ok
			
			# Check for obstacle

			if This.IsObstacle(_nCurrentCol_, _nCurrentRow_)

				# Try going around by moving vertically first
				return This.FindManhattanPathVerticalFirst(_nStartCol_, _nStartRow_, _nEndCol_, _nEndRow_)
			ok
			
			This.AddPathNode(_nCurrentCol_, _nCurrentRow_)
		end
		
		# Then move vertically

		while _nCurrentRow_ != _nEndRow_
			if _nCurrentRow_ < _nEndRow_
				_nCurrentRow_++
			else
				_nCurrentRow_--
			ok
			
			# Check for obstacle

			if This.IsObstacle(_nCurrentCol_, _nCurrentRow_)

				# If we hit an obstacle, use A* algorithm for the rest of the path

				_aPartialPath_ = This.ShortestPath(_nCurrentCol_, _nCurrentRow_ - @IF(_nCurrentRow_ > _nEndRow_, 1, -1), _nEndCol_, _nEndRow_)
				
				# Remove first node to avoid duplication

				if len(_aPartialPath_) > 0
					del(_aPartialPath_, 1)
				ok
				
				# Add the rest of the path

				_nPartialPathLen_5 = len(_aPartialPath_)
				for i = 1 to _nPartialPathLen_5
					This.AddPathNode(_aPartialPath_[i][1], _aPartialPath_[i][2])
				next
				
				return @aPath
			ok
			
			This.AddPathNode(_nCurrentCol_, _nCurrentRow_)
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

		_nStartCol_ = panStart[1]
		_nStartRow_ = panStart[2]
		_nEndCol_ = panEnd[1]
		_nEndRow_ = panEnd[2]
		
		# Clear existing path

		This.ClearPath()
		
		# Start from start position

		This.AddPathNode(_nStartCol_, _nStartRow_)
		
		# Current position

		_nCurrentCol_ = _nStartCol_
		_nCurrentRow_ = _nStartRow_
		
		# First move vertically

		while _nCurrentRow_ != _nEndRow_

			if _nCurrentRow_ < _nEndRow_
				_nCurrentRow_++
			else
				_nCurrentRow_--
			ok
			
			# Check for obstacle

			if This.IsObstacle(_nCurrentCol_, _nCurrentRow_)

				# Try using A* algorithm for the entire path
				return This.ShortestPath(_nStartCol_, _nStartRow_, _nEndCol_, _nEndRow_)
			ok
			
			This.AddPathNode(_nCurrentCol_, _nCurrentRow_)
		end
		
		# Then move horizontally

		while _nCurrentCol_ != _nEndCol_

			if _nCurrentCol_ < _nEndCol_
				_nCurrentCol_++
			else
				_nCurrentCol_--
			ok
			
			# Check for obstacle

			if This.IsObstacle(_nCurrentCol_, _nCurrentRow_)

				# If we hit an obstacle, use A* algorithm for the rest of the path
				_aPartialPath_ = This.ShortestPath(_nCurrentCol_ - @IF(_nCurrentCol_ > _nEndCol_, 1, -1), _nCurrentRow_, _nEndCol_, _nEndRow_)
				
				# Remove first node to avoid duplication

				_nLenPartial_ = len(_aPartialPath_)

				if _nLenPartial_ > 0
					del(_aPartialPath_, 1)
				ok
				
				# Add the rest of the path

				for i = 1 to _nLenPartial_
					This.AddPathNode(_aPartialPath_[i][1], _aPartialPath_[i][2])
				next
				
				return @aPath
			ok
			
			This.AddPathNode(_nCurrentCol_, _nCurrentRow_)
		end
		
		return @aPath

	def SpiralPath(panStartNode, _nRings_)
		# Creates a spiral path starting from the given position

		if CheckParams()

			if NOT (isList(panStartNode) and IsPairOfNumbers(panStartNode))
				StzRaise("Incorrect param type! panStartNode must be a pair of numbers.")
			ok

			if isList(_nRings_) and IsRingsNamedParamList(_nRings_)
				_nRings_ = _nRings_[2]
			ok

			if NOT isNumber(_nRings_)
				StzRaise("Incorrect param type! nRings must be a number.")
			ok
		ok
		
		_nStartCol_ = panStartNode[1]
		_nStartRow_ = panStartNode[2]

		# Validate positions
		if NOT IsValidPosition(_nStartCol_, _nStartRow_)
			stzRaise("Invalid start position!")
		ok
		
		# Clear existing path
		This.ClearPath()
		This.SetCurrentNode(_nStartCol_, _nStartRow_)

		# Start from start position
		This.AddPathNode(_nStartCol_, _nStartRow_)
		
		# Define directions: right, down, left, up
		_aDirections_ = [[1,0], [0,1], [-1,0], [0,-1]]
		_nDirIndex_ = 0
		
		# Current position
		_nCurrentCol_ = _nStartCol_
		_nCurrentRow_ = _nStartRow_
		
		# Spiral parameters
		_nSteps_ = 1
		_nStepCount_ = 0
		_nTurnCount_ = 0
		
		# Create spiral path
		for i = 1 to _nRings_ * 8  # Maximum number of steps in a spiral with nRings
			# Move in current direction
			_nCurrentCol_ += _aDirections_[_nDirIndex_ + 1][1]
			_nCurrentRow_ += _aDirections_[_nDirIndex_ + 1][2]
			
			# Check if we're still in bounds
			if NOT IsValidPosition(_nCurrentCol_, _nCurrentRow_)
				exit
			ok
			
			# Check for obstacle
			if This.IsObstacle(_nCurrentCol_, _nCurrentRow_)
				# Skip this position
				_nCurrentCol_ -= _aDirections_[_nDirIndex_ + 1][1]
				_nCurrentRow_ -= _aDirections_[_nDirIndex_ + 1][2]
				
				# Try turning
				_nDirIndex_ = (_nDirIndex_ + 1) % 4
				_nTurnCount_++
				
				# If we've tried all directions, stop
				if _nTurnCount_ >= 4
					exit
				ok
				
				loop
			ok
			
			# Add to path
			This.AddPathNode(_nCurrentCol_, _nCurrentRow_)
			
			# Reset turn count
			_nTurnCount_ = 0
			
			# Increment step count
			_nStepCount_++
			
			# Check if we need to turn
			if _nStepCount_ = _nSteps_
				_nStepCount_ = 0
				_nDirIndex_ = (_nDirIndex_ + 1) % 4
				
				# Increase steps every 2 turns
				if _nDirIndex_ % 2 = 0
					_nSteps_++
				ok
			ok
		next
		
		return @aPath

	def ZigZagPath(panStart, panEnd, _nZigZagWidth_)
		# Creates a zig-zag path from start to end with the specified width

		if CheckParams()
			if NOT (isList(panStart) and IsPairOfNumbers(panStart) and
				isList(panEnd) and IsPairOfNumbers(panEnd))

				StzRaise("Incorrect param type! panStart and panEnd must be pairs of numbers.")

			ok

			if isList(_nZigZagWidth_) and IsWidthNamedParamList(_nZigZagWidth_)
				_nZigZagWidth_ = _nZigZagWidth_[2]
			ok

			if NOT isNumber(_nZigZagWidth_)
				StzRaise("Incorrect param type! nZigZagWidth must be a number.")
			ok
		ok

		_nStartCol_ = panStart[1]
		_nStartRow_ = panStart[2]
		_nEndCol_ = panEnd[1]
		_nEndRow_ = panEnd[2]

		# Validate positions
		if NOT IsValidPosition(_nStartCol_, _nStartRow_)
			stzRaise("Invalid start position!")
		ok
		
		if NOT IsValidPosition(_nEndCol_, _nEndRow_)
			stzRaise("Invalid end position!")
		ok
		
		# Clear existing path
		This.ClearPath()
		This.SetCurrentNode(_nStartCol_, _nStartRow_)

		# Start from start position
		This.AddPathNode(_nStartCol_, _nStartRow_)
		
		# Current position
		_nCurrentCol_ = _nStartCol_
		_nCurrentRow_ = _nStartRow_
		
		# Calculate direction
		_nDirCol_ = sign(_nEndCol_ - _nStartCol_)
		_nDirRow_ = sign(_nEndRow_ - _nStartRow_)
		
		# Default to horizontal if no clear direction
		if _nDirCol_ = 0 and _nDirRow_ = 0
			return [_nStartCol_, _nStartRow_]
		ok
		
		# Use dominant direction for zig-zag
		_lVerticalDominant_ = (abs(_nEndRow_ - _nStartRow_) > abs(_nEndCol_ - _nStartCol_))
		
		if _lVerticalDominant_

			# Vertical zig-zag
			_nZigZag_ = 0
			_lZigZagRight_ = TRUE
			
			while _nCurrentRow_ != _nEndRow_
				# Move vertically
				_nCurrentRow_ += _nDirRow_
				
				# Check if we're still in bounds
				if NOT IsValidPosition(_nCurrentCol_, _nCurrentRow_)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(_nCurrentCol_, _nCurrentRow_)
					# Try to go around obstacle
					if IsValidPosition(_nCurrentCol_ + 1, _nCurrentRow_) and NOT This.IsObstacle(_nCurrentCol_ + 1, _nCurrentRow_)
						_nCurrentCol_++
					but IsValidPosition(_nCurrentCol_ - 1, _nCurrentRow_) and NOT This.IsObstacle(_nCurrentCol_ - 1, _nCurrentRow_)
						_nCurrentCol_--
					else
						# Can't find a way around, use A* for the rest
						_aPartialPath_ = This.ShortestPath(_nCurrentCol_, _nCurrentRow_ - _nDirRow_, _nEndCol_, _nEndRow_)
						
						# Remove first node to avoid duplication
						if len(_aPartialPath_) > 0
							del(_aPartialPath_, 1)
						ok
						
						# Add the rest of the path
						_nPartialPathLen_4 = len(_aPartialPath_)
						for i = 1 to _nPartialPathLen_4
							This.AddPathNode(_aPartialPath_[i][1], _aPartialPath_[i][2])
						next
						
						return @aPath
					ok
				ok
				
				This.AddPathNode(_nCurrentCol_, _nCurrentRow_)
				
				# Zig-zag horizontally
				_nZigZag_++
				if _nZigZag_ >= _nZigZagWidth_
					_nZigZag_ = 0
					
					# Move horizontally in zigzag pattern
					_nHorizontalSteps_ = @IF(_lZigZagRight_, 1, -1)
					
					for i = 1 to 2  # Move 2 steps horizontally
						_nCurrentCol_ += _nHorizontalSteps_
						
						# Check if we're still in bounds
						if NOT IsValidPosition(_nCurrentCol_, _nCurrentRow_)
							exit
						ok
						
						# Check for obstacle
						if This.IsObstacle(_nCurrentCol_, _nCurrentRow_)
							_nCurrentCol_ -= _nHorizontalSteps_
							exit
						ok
						
						This.AddPathNode(_nCurrentCol_, _nCurrentRow_)
					next
					
					_lZigZagRight_ = NOT _lZigZagRight_
				ok
			end
			
			# Final horizontal movement to reach end position
			while _nCurrentCol_ != _nEndCol_
				if _nCurrentCol_ < _nEndCol_
					_nCurrentCol_++
				else
					_nCurrentCol_--
				ok
				
				# Check if we're still in bounds
				if NOT IsValidPosition(_nCurrentCol_, _nCurrentRow_)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(_nCurrentCol_, _nCurrentRow_)
					# Can't find a way around, use A* for the rest
					_aPartialPath_ = This.ShortestPath(_nCurrentCol_ - @IF(_nCurrentCol_ > _nEndCol_, 1, -1), _nCurrentRow_, _nEndCol_, _nEndRow_)
					
					# Remove first node to avoid duplication
					if len(_aPartialPath_) > 0
						del(_aPartialPath_, 1)
					ok
					
					# Add the rest of the path
					_nPartialPathLen_3 = len(_aPartialPath_)
					for i = 1 to _nPartialPathLen_3
						This.AddPathNode(_aPartialPath_[i][1], _aPartialPath_[i][2])
					next
					
					return @aPath
				ok
				
				This.AddPathNode(_nCurrentCol_, _nCurrentRow_)
			end
		else

			# Horizontal zig-zag
			_nZigZag_ = 0
			_lZigZagDown_ = TRUE
			
			while _nCurrentCol_ != _nEndCol_
				# Move horizontally
				_nCurrentCol_ += _nDirCol_
				
				# Check if we're still in bounds
				if NOT IsValidPosition(_nCurrentCol_, _nCurrentRow_)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(_nCurrentCol_, _nCurrentRow_)
					# Try to go around obstacle
					if IsValidPosition(_nCurrentCol_, _nCurrentRow_ + 1) and NOT This.IsObstacle(_nCurrentCol_, _nCurrentRow_ + 1)
						_nCurrentRow_++
					but IsValidPosition(_nCurrentCol_, _nCurrentRow_ - 1) and NOT This.IsObstacle(_nCurrentCol_, _nCurrentRow_ - 1)
						_nCurrentRow_--
					else
						# Can't find a way around, use A* for the rest
						_aPartialPath_ = This.ShortestPath(_nCurrentCol_ - _nDirCol_, _nCurrentRow_, _nEndCol_, _nEndRow_)
						
						# Remove first node to avoid duplication
						if len(_aPartialPath_) > 0
							del(_aPartialPath_, 1)
						ok
						
						# Add the rest of the path
						_nPartialPathLen_2 = len(_aPartialPath_)
						for i = 1 to _nPartialPathLen_2
							This.AddPathNode(_aPartialPath_[i][1], _aPartialPath_[i][2])
						next
						
						return @aPath
					ok

				ok
				
				This.AddPathNode(_nCurrentCol_, _nCurrentRow_)
				
				# Zig-zag vertically
				_nZigZag_++
				if _nZigZag_ >= _nZigZagWidth_
					_nZigZag_ = 0
					
					# Move vertically in zigzag pattern
					_nVerticalSteps_ = @if(_lZigZagDown_, 1, -1)
					
					for i = 1 to 2  # Move 2 steps vertically
						_nCurrentRow_ += _nVerticalSteps_
						
						# Check if we're still in bounds
						if NOT IsValidPosition(_nCurrentCol_, _nCurrentRow_)
							exit
						ok
						
						# Check for obstacle
						if This.IsObstacle(_nCurrentCol_, _nCurrentRow_)
							_nCurrentRow_ -= _nVerticalSteps_
							exit
						ok
						
						This.AddPathNode(_nCurrentCol_, _nCurrentRow_)
					next
					
					_lZigZagDown_ = NOT _lZigZagDown_
				ok
			end
			
			# Final vertical movement to reach end position
			while _nCurrentRow_ != _nEndRow_
				if _nCurrentRow_ < _nEndRow_
					_nCurrentRow_++
				else
					_nCurrentRow_--
				ok
				
				# Check if we're still in bounds
				if NOT IsValidPosition(_nCurrentCol_, _nCurrentRow_)
					exit
				ok
				
				# Check for obstacle
				if This.IsObstacle(_nCurrentCol_, _nCurrentRow_)
					# Can't find a way around, use A* for the rest
					_aPartialPath_ = This.ShortestPath(_nCurrentCol_, _nCurrentRow_ - @IF(_nCurrentRow_ > _nEndRow_, 1, -1), _nEndCol_, _nEndRow_)
					
					# Remove first node to avoid duplication
					if len(_aPartialPath_) > 0
						del(_aPartialPath_, 1)
					ok
					
					# Add the rest of the path
					_nPartialPathLen_ = len(_aPartialPath_)
					for i = 1 to _nPartialPathLen_
						This.AddPathNode(_aPartialPath_[i][1], _aPartialPath_[i][2])
					next
					
					return @aPath
				ok
				
				This.AddPathNode(_nCurrentCol_, _nCurrentRow_)
			end
		ok
		
		return @aPath


	def ShowPath(aPathToUse, cCustomChar)

		# Store the original path character
		_cOriginalPathChar_ = @cPathChar

		# Set custom path character if provided
		if cCustomChar != NULL
			@cPathChar = cCustomChar
		ok

		# Store the original path
		_aOriginalPath_ = @aPath

		# Use the provided path if given
		if aPathToUse != NULL
			@aPath = aPathToUse
		ok

		# Instead of calling This.Show() directly, return the string representation
		_cResult_ = This.ToString()

		# Restore original path character and path
		@cPathChar = _cOriginalPathChar_
		@aPath = _aOriginalPath_

		# Print the result instead of calling Show()
		? _cResult_

		return _cResult_


	def ShowNode(_nCol_, _nRow_, _cChar_)
		This.ShowNodes([ [_nCol_, _nRow_] ], _cChar_)

		def ShowCell(_nCol_, _nRow_, _cChar_)
			This.ShowNode(_nCol_, _nRow_, _cChar_)

	def ShowNodes(aNodes, _cChar_)
		# Temporarily draw nodes with the specified character
		
		if NOT (isString(_cChar_) and IsChar(_cChar_))
			stzRaise("Node character must be a single character!")
		ok
		
		# Store current path
		_aOldPath_ = @aPath
		
		# Clear path and add nodes
		This.ClearPath()
		
		_nNodesLen_ = len(aNodes)
		for i = 1 to _nNodesLen_
			if isList(aNodes[i]) and len(aNodes[i]) = 2
				_nCol_ = aNodes[i][1]
				_nRow_ = aNodes[i][2]
				
				if IsValidPosition(_nCol_, _nRow_)
					This.AddPathNode(_nCol_, _nRow_)
				ok
			ok
		next
		
		# Draw with the specified character
		This.ShowPath(@aPath, _cChar_)
		
		# Restore original path
		@aPath = _aOldPath_

		def ShowCells(aNodes, _cChar_)
			This.ShowNodes(aNodes, _cChar_)


	def ShowRegions()
		# Paint multiple regions with different characters
		_aRegions_ = This.ConnectedRegions()
		_nLen_ = len(_aRegions_)
		_acChars_ = []
	
		for i = 1 to _nLen_
			# Use numbers starting from 1 (not modulo)
			_acChars_ + (""+ i)
		next
	
		# Store current Grid state
		_aOldPath_ = @aPath
	
		# Create a temporary Grid with empty cells
		_aGrid_ = list(@nRows)
	
		for y = 1 to @nRows
			_aGrid_[y] = list(@nCols)
			for x = 1 to @nCols
				_aGrid_[y][x] = @cEmptyChar
			next
		next
	
		# Add obstacles to the Grid
		if @bShowObstacles
			_nObstaclesLen_2 = len(@aObstacles)
			for i = 1 to _nObstaclesLen_2
				_nObsCol_ = @aObstacles[i][1]
				_nObsRow_ = @aObstacles[i][2]
	
				if IsValidPosition(_nObsCol_, _nObsRow_)
					_aGrid_[_nObsRow_][_nObsCol_] = @cObstacleChar
				ok
			next
		ok
	
		# Add all regions to the Grid
		for i = 1 to _nLen_
			_aRegion_ = _aRegions_[i]
			_cChar_ = _acChars_[i]
	
			_nRegionLen_3 = len(_aRegion_)
			for j = 1 to _nRegionLen_3
				_nCol_ = _aRegion_[j][1]
				_nRow_ = _aRegion_[j][2]
	
				if IsValidPosition(_nCol_, _nRow_)
					# Skip if it's an obstacle
					if NOT This.IsObstacle(_nCol_, _nRow_)
						_aGrid_[_nRow_][_nCol_] = _cChar_
					ok
				ok
			next
		next
	
		# Mark current position
		if IsValidPosition(@nCurrentCol, @nCurrentRow)
			_aGrid_[@nCurrentRow][@nCurrentCol] = @cCurrentChar
		ok
	
		# Display the Grid with all regions
		This.ShowCustomGrid(_aGrid_)
	
		# Restore original path
		@aPath = _aOldPath_
	
	def ShowRegionsXT(pacChars)
		# Paint multiple regions with custom characters
		# pacChars: List of characters to use for each region (optional)
		
		_aRegions_ = This.ConnectedRegions()
		_nLen_ = len(_aRegions_)
		_acChars_ = []
		
		# Use provided characters or generate them
		if isList(pacChars) and len(pacChars) > 0
			# Use provided characters (cycling if needed)
			_nLenChars_ = len(pacChars)
			
			for i = 1 to _nLen_
				_cChar_ = pacChars[(i-1) % _nLenChars_ + 1]
				# Ensure each character is a single character            
				_acChars_ + _cChar_
			next
		else
			# Generate default characters (numbers 1-9 cycling)
			for i = 1 to _nLen_
				_acChars_ + (""+ i)
			next
		ok
		
		# Store current Grid state
		_aOldPath_ = @aPath
		
		# Create a temporary Grid with empty cells
		_aGrid_ = list(@nRows)
		
		for y = 1 to @nRows
			_aGrid_[y] = list(@nCols)
			for x = 1 to @nCols
				_aGrid_[y][x] = @cEmptyChar
			next
		next
		
		# Add obstacles to the Grid
		if @bShowObstacles
			_nObstaclesLen_ = len(@aObstacles)
			for i = 1 to _nObstaclesLen_
				_nObsCol_ = @aObstacles[i][1]
				_nObsRow_ = @aObstacles[i][2]
				
				if IsValidPosition(_nObsCol_, _nObsRow_)
					_aGrid_[_nObsRow_][_nObsCol_] = @cObstacleChar
				ok
			next
		ok
		
		# Add all regions to the Grid
		for i = 1 to _nLen_
			_aRegion_ = _aRegions_[i]
			_cChar_ = _acChars_[i]
			
			_nRegionLen_2 = len(_aRegion_)
			for j = 1 to _nRegionLen_2
				_nCol_ = _aRegion_[j][1]
				_nRow_ = _aRegion_[j][2]
				
				if IsValidPosition(_nCol_, _nRow_)
					# Skip if it's an obstacle
					if NOT This.IsObstacle(_nCol_, _nRow_)
						_aGrid_[_nRow_][_nCol_] = _cChar_
					ok
				ok
			next
		next
		
		# Mark current position
		if IsValidPosition(@nCurrentCol, @nCurrentRow)
			_aGrid_[@nCurrentRow][@nCurrentCol] = @cCurrentChar
		ok
		
		# Display the Grid with all regions
		This.ShowCustomGrid(_aGrid_)
		
		# Restore original path
		@aPath = _aOldPath_
	
	def ShowCustomGrid(aCustomGrid)
		# Display a custom Grid without changing the internal Grid state

		_cResult_ = ""

		# Add X-axis labels if requested

		if @bShowCoordinates
			_cResult_ += "    " # Space for alignment with the Grid

			for x = 1 to @nCols
				if x % 10 = 0
					_cResult_ += "0 "
				else
					_cResult_ += ""+ (x % 10) + " "
				ok
			next

			_cResult_ += NL()
		ok

		# Add top border with rounded corners

		_cResult_ += "  ╭"

		for x = 1 to @nCols
			if x = @nCurrentCol
				_cResult_ += "─v─"
			else
				_cResult_ += "──"
			ok
		next

		_cResult_ += "╮" + NL()

		# Add rows with Y-axis labels and borders

		for y = 1 to @nRows
			# Add Y indicator for current Cell - resetting at multiples of 10

			if @bShowCoordinates
				if y % 10 = 0
					_yLabel_ = "0"
				else
					_yLabel_ = ""+ (y % 10)
				ok
			else
				_yLabel_ = " "
			ok

			if y = @nCurrentRow
				_cResult_ += _yLabel_ + " > "
			else
				_cResult_ += _yLabel_ + " │ "
			ok

			for x = 1 to @nCols
				_cResult_ += ""+ aCustomGrid[y][x] + " "
			next

			_cResult_ += "│" + NL()
		next

		# Add bottom border with rounded corners

		_cResult_ += "  ╰"

		for x = 1 to @nCols
			_cResult_ += "──"
		next

		_cResult_ += "─╯" + NL()
    
		? _cResult_

	#-- HELPER FUNCTIONS FOR PATHFINDING

	def HeuristicCost(panStart, panEnd)

		if CheckParams()
			if NOT (isList(panStart) and IsPairOfNumbers(panStart) and
				isList(panEnd) and IsPairOfNumbers(panEnd))

				StzRaise("Incorrect param type! panStart and panEnd must be pairs of numbers.")

			ok
		ok

		_nStartCol_ = panStart[1]
		_nStartRow_ = panStart[2]
		_nEndCol_ = panEnd[1]
		_nEndRow_ = panEnd[2]

		# Manhattan distance heuristic
		return abs(_nStartCol_ - _nEndCol_) + abs(_nStartRow_ - _nEndRow_)

	def WalkableNeighbors(_nCol_, _nRow_)

		if CheckParams()
			if NOT (isNumber(_nCol_) and isNumber(_nRow_))
				StzRaise("Incorrect param type! nCol and nRow must be numbers.")
			ok
		ok

		# Get all valid neighbors that are not obstacles
		_aNeighbors_ = []
		
		# Check all 4 directions (up, right, down, left)
		_aDirections_ = [[-1,0], [0,1], [1,0], [0,-1]]
		_nLen_ = len(_aDirections_)

		for i = 1 to _nLen_
			_nNewCol_ = _nCol_ + _aDirections_[i][1]
			_nNewRow_ = _nRow_ + _aDirections_[i][2]
			
			if IsValidPosition(_nNewCol_, _nNewRow_) and NOT This.IsObstacle(_nNewCol_, _nNewRow_)
				_aNeighbors_ + [_nNewCol_, _nNewRow_]
			ok
		next
		
		return _aNeighbors_

		def WalkableNeighborsOfNode(_nCol_, _nRow_)
			return This.WalkableNeighbors(_nCol_, _nRow_)

		def WalkableNeighborsOfCell(_nCol_, _nRow_)
			return This.WalkableNeighbors(_nCol_, _nRow_)

		def WalkableNeighborsOf(_nCol_, _nRow_)
			return This.WalkableNeighbors(_nCol_, _nRow_)
	
		def WalkableAdjacents(_nCol_, _nRow_)
			return This.WalkableNeighbors(_nCol_, _nRow_)

		def WalkableAdjacentsOfNode(_nCol_, _nRow_)
			return This.WalkableNeighbors(_nCol_, _nRow_)

		def WalkableAdjacentsOfCell(_nCol_, _nRow_)
			return This.WalkableNeighbors(_nCol_, _nRow_)

		def WalkableAdjacentsOf(_nCol_, _nRow_)
			return This.WalkableNeighbors(_nCol_, _nRow_)

	def IsInList(aList, _nCol_, _nRow_)

		if CheckParams()
			if NOT isList(aList)
				StzRaise("Incorrect param type! aList must be a list.")
			ok

			if NOT (isNumber(_nCol_) and isNumber(_nRow_))
				StzRaise("Incorrect param type! nRow and nCol must be both numbers.")
			ok
		ok

		_nLen_ = len(aList)

		for i = 1 to _nLen_
			if aList[i][1] = _nCol_ and aList[i][2] = _nRow_
				return TRUE
			ok
		next
		return FALSE

	def LowestFScore(_aOpenSet_, _aFScore_)

		_nLowestIdx_ = 1
		_nLowestScore_ = This.GetScoreAt(_aFScore_, _aOpenSet_[1][1], _aOpenSet_[1][2])
		
		_nLen_ = len(_aOpenSet_)

		for i = 2 to _nLen_
			_nScore_ = This.GetScoreAt(_aFScore_, _aOpenSet_[i][1], _aOpenSet_[i][2])
			if _nScore_ < _nLowestScore_
				_nLowestScore_ = _nScore_
				_nLowestIdx_ = i
			ok
		next
		
		return _nLowestIdx_

	def GetScoreAt(aScores, _nCol_, _nRow_)

		_nLen_ = len(aScores)

		for i = 1 to _nLen_
			if aScores[i][1][1] = _nCol_ and aScores[i][1][2] = _nRow_
				return aScores[i][2]
			ok
		next
		return 999999  # Default to infinity

	def SetScoreAt(aScores, _nCol_, _nRow_, _nScore_)

		_nLen_ = len(aScores)

		for i = 1 to _nLen_
			if aScores[i][1][1] = _nCol_ and aScores[i][1][2] = _nRow_
				aScores[i][2] = _nScore_
				return aScores
			ok
		next
		
		# If not found, add it
		aScores + [[_nCol_, _nRow_], _nScore_]
		return aScores

	def SetCameFrom(_aCameFrom_, _nCol_, _nRow_, nFromCol, nFromRow)

		_nLen_ = len(_aCameFrom_)

		for i = 1 to _nLen_
			if _aCameFrom_[i][1][1] = _nCol_ and _aCameFrom_[i][1][2] = _nRow_
				_aCameFrom_[i][2] = [nFromCol, nFromRow]
				return _aCameFrom_
			ok
		next
		
		# If not found, add it
		_aCameFrom_ + [[_nCol_, _nRow_], [nFromCol, nFromRow]]
		return _aCameFrom_

	def GetCameFrom(_aCameFrom_, _nCol_, _nRow_)

		_nLen_ = len(_aCameFrom_)

		for i = 1 to _nLen_
			if _aCameFrom_[i][1][1] = _nCol_ and _aCameFrom_[i][1][2] = _nRow_
				return _aCameFrom_[i][2]
			ok
		next
		return NULL

	def ReconstructPath(_aCameFrom_, _nEndCol_, _nEndRow_)

		_aPath_ = []
		_nCurrentCol_ = _nEndCol_
		_nCurrentRow_ = _nEndRow_

		# Add end position

		_aPath_ + [_nCurrentCol_, _nCurrentRow_]

		# Trace back the path

		while TRUE

			_aPrev_ = This.GetCameFrom(_aCameFrom_, _nCurrentCol_, _nCurrentRow_)

 			if _aPrev_ = NULL
				exit
			ok

			_nCurrentCol_ = _aPrev_[1]
			_nCurrentRow_ = _aPrev_[2]

			# Add to path (at the beginning)
			insert(_aPath_, 1, [_nCurrentCol_, _nCurrentRow_])
		end

		return _aPath_

	#-- PATH COMPLEXITY ANALYSIS

	def PathComplexity()
		# Analyze path complexity based on number of turns and direction changes
		
		_nLen_ = len(@aPath)
		
		if _nLen_ <= 2
			return 0  # Straight line or single point
		ok
		
		_nTurns_ = 0
		_nLastDirX_ = 0
		_nLastDirY_ = 0
		
		for i = 2 to _nLen_

			_nDirX_ = @aPath[i][1] - @aPath[i-1][1]
			_nDirY_ = @aPath[i][2] - @aPath[i-1][2]
			
			# First direction, just store it

			if i = 2
				_nLastDirX_ = _nDirX_
				_nLastDirY_ = _nDirY_
				loop
			ok
			
			# Direction changed, count as a turn

			if _nDirX_ != _nLastDirX_ or _nDirY_ != _nLastDirY_
				_nTurns_++
				_nLastDirX_ = _nDirX_
				_nLastDirY_ = _nDirY_
			ok
		next
		
		return _nTurns_
	
	def PathEfficiency()
		# Calculate path efficiency compared to direct distance
		
		_nLen_ = len(@aPath)

		if _nLen_ < 2
			return 100  # Perfect efficiency for single point
		ok
		
		_nStart_ = @aPath[1]
		_nEnd_ = @aPath[_nLen_]
		
		# Calculate direct Manhattan distance
		_nDirectDist_ = abs(_nStart_[1] - _nEnd_[1]) + abs(_nStart_[2] - _nEnd_[2])
		
		# Calculate efficiency
		_nEfficiency_ = (_nDirectDist_ / (_nLen_ - 1)) * 100
		
		# Cap at 100%
		if _nEfficiency_ > 100
			return 100
		else
			return _nEfficiency_
		ok
	
	#-- REGION MANAGEMENT
	
	def Fill(_nStartCol_, _nStartRow_)
		# Perform flood fill from start position, ignoring obstacles
		# Returns a list of all reachable positions
		
		_aResult_ = []
		_aQueue_ = []
		_aVisited_ = []
		
		# Add start position to queue
		_aQueue_ + [_nStartCol_, _nStartRow_]
		_aVisited_ + [_nStartCol_, _nStartRow_]
		
		while len(_aQueue_) > 0
			# Get next position from queue
			_nCol_ = _aQueue_[1][1]
			_nRow_ = _aQueue_[1][2]
			del(_aQueue_, 1)
			
			# Add to result
			_aResult_ + [_nCol_, _nRow_]
			
			# Check all 4 adjacent positions
			_aDirections_ = [[0,1], [1,0], [0,-1], [-1,0]]
			_nLen_ = len(_aDirections_)

			for i = 1 to _nLen_
				_nNewCol_ = _nCol_ + _aDirections_[i][1]
				_nNewRow_ = _nRow_ + _aDirections_[i][2]
				
				# Check if valid position that is not an obstacle and not visited
				if IsValidPosition(_nNewCol_, _nNewRow_) and 
				   NOT This.IsObstacle(_nNewCol_, _nNewRow_) and
				   NOT This.IsInList(_aVisited_, _nNewCol_, _nNewRow_)
					
					# Add to queue and mark as visited
					_aQueue_ + [_nNewCol_, _nNewRow_]
					_aVisited_ + [_nNewCol_, _nNewRow_]
				ok
			next
		end
		
		return _aResult_

		def FloodFill(_nStartCol_, _nStartRow_)
			return This.Fill(_nStartCol_, _nStartRow_)

	def AreConnected(panNode1, panNode2)
		# Check if two positions are connected (can reach each other without hitting obstacles)
		
		if CheckParams()
			if NOT (isList(panNode1) and IsPairOfNumbers(panNode1) and
				isList(panNode2) and IsPairOfNumbers(panNode2))

				StzRaise("Incorrect param type! panNode1 and panNode2 must be both pairs of numbers.")
			ok
		ok

		_nCol1_ = panNode1[1]
		_nRow1_ = panNode1[2]

		_nCol2_ = panNode2[1]
		_nRow2_ = panNode2[2]

		# Quick check for invalid positions
		if NOT IsValidPosition(_nCol1_, _nRow1_) or NOT IsValidPosition(_nCol2_, _nRow2_)
			return FALSE
		ok
		
		# Check if either position is an obstacle
		if This.IsObstacle(_nCol1_, _nRow1_) or This.IsObstacle(_nCol2_, _nRow2_)
			return FALSE
		ok
		
		# Do flood fill from first position
		_aReachable_ = This.FloodFill(_nCol1_, _nRow1_)
		
		# Check if second position is in the reachable list
		return This.IsInList(_aReachable_, _nCol2_, _nRow2_)

	def Regions()
		# Find all connected regions separated by obstacles
		# Returns a list of lists, each containing the positions in a region
		
		_aResult_ = []
		_aVisited_ = []
		
		# Check each position
		for y = 1 to @nRows
			for x = 1 to @nCols
				# Skip if obstacle or already visited
				if This.IsObstacle(x, y) or This.IsInList(_aVisited_, x, y)
					loop
				ok
				
				# Flood fill from this position
				_aRegion_ = This.FloodFill(x, y)
				
				# Add region to result if not empty
				if len(_aRegion_) > 0
					_aResult_ + _aRegion_
					
					# Mark all cells in this region as visited
					_nRegionLen_ = len(_aRegion_)
					for i = 1 to _nRegionLen_
						_aVisited_ + [ _aRegion_[i][1], _aRegion_[i][2] ]
					next
				ok
			next
		next
		
		return _aResult_

		def ConnectedRegions()
			return This.Regions()

	#-- RANDOM MAZE GENERATION
	
	def RandomMaze(_nObstacleDensity_)
		# Generate a random maze with the given obstacle density (0-100%)
		# 0% = no obstacles, 100% = completely blocked (except current position)
		
		# Clear obstacles
		This.ClearObstacles()
		
		# Cap density
		if _nObstacleDensity_ < 0
			_nObstacleDensity_ = 0
		ok
		
		if _nObstacleDensity_ > 90
			_nObstacleDensity_ = 90  # Max 90% to ensure some paths exist
		ok
		
		# Add random obstacles
		for y = 1 to @nRows
			for x = 1 to @nCols
				# Skip current position
				if x = @nCurrentCol and y = @nCurrentRow
					loop
				ok
				
				# Add obstacle with probability based on density
				if random(100) < _nObstacleDensity_
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

		_nStartCol_ = panStart[1]
		_nStartRow_ = panStart[2]
		_nEndCol_ = panEnd[1]
		_nEndRow_ = panEnd[2]
	
		# Clear obstacles
		This.ClearObstacles()
		
		# Create a path first
		This.ClearPath()
		This.MoveTo(_nStartCol_, _nStartRow_)
		This.ShortestPath([_nStartCol_, _nStartRow_], [_nEndCol_, _nEndRow_])
		
		# Store path positions
		_aPathPositions_ = @aPath
		
		# Add random obstacles avoiding the path
		for y = 1 to @nRows
			for x = 1 to @nCols
				# Skip if on path
				if This.IsInList(_aPathPositions_, x, y)
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

		_aGrid_ = list(@nRows)

		for y = 1 to @nRows

			_aGrid_[y] = list(@nCols)

			for x = 1 to @nCols
				_aGrid_[y][x] = @cEmptyChar
			next
		next
    
		# Add obstacles

		if @bShowObstacles

			_nLen_ = len(@aObstacles)

			for i = 1 to _nLen_

				_nObsCol_ = @aObstacles[i][1]
				_nObsRow_ = @aObstacles[i][2]

				if IsValidPosition(_nObsCol_, _nObsRow_)
					_aGrid_[_nObsRow_][_nObsCol_] = @cObstacleChar
				ok
			next
		ok

		# Add path

		if @bShowPath and len(@aPath) > 0

			# Mark ALL path nodes with the path character

			_nPathLen_ = len(@aPath)
			for i = 1 to _nPathLen_

				_nPathCol_ = @aPath[i][1]
				_nPathRow_ = @aPath[i][2]

				if IsValidPosition(_nPathCol_, _nPathRow_)
					# Skip if it's an obstacle

					if NOT This.IsObstacle(_nPathCol_, _nPathRow_)
						_aGrid_[_nPathRow_][_nPathCol_] = @cPathChar
					ok
				ok
			next
		ok

		# Mark current position with direction character or current char

		if IsValidPosition(@nCurrentCol, @nCurrentRow)

			# Use the appropriate direction character based on current direction
			_aGrid_[@nCurrentRow][@nCurrentCol] = @cCurrentChar
		ok

		# Convert grid to string representation

		_cResult_ = ""

		# Add X-axis labels if requested

		if @bShowCoordinates

			_cResult_ += "    " # Space for alignment with the grid

			for x = 1 to @nCols

				if x % 10 = 0
					_cResult_ += "0 "
				else
					_cResult_ += ""+ (x % 10) + " "
				ok
			next

			_cResult_ += NL()
		ok
		
		# Add top border with rounded corners and indicator for current X position

		_cResult_ += "  ╭"

		for x = 1 to @nCols

			if x = @nCurrentCol
				_cResult_ += "─v─"
			else
				_cResult_ += "──"
			ok
		next

		_cResult_ += "╮" + NL()

		# Add rows with Y-axis labels and borders

		for y = 1 to @nRows

			# Add Y indicator for current position - resetting at multiples of 10

			if @bShowCoordinates

				if y % 10 = 0
					_yLabel_ = "0"
				else
					_yLabel_ = ""+ (y % 10)
				ok
			else
				_yLabel_ = " "
			ok

			if y = @nCurrentRow
				_cResult_ += _yLabel_ + " > "
			else
				_cResult_ += _yLabel_ + " │ "
			ok

			for x = 1 to @nCols
				_cResult_ += ""+ _aGrid_[y][x] + " "
			next

			_cResult_ += "│" + NL()
		next

		# Add bottom border with rounded corners

		_cResult_ += "  ╰"

		for x = 1 to @nCols
			_cResult_ += "──"
		next

		_cResult_ += "─╯" + NL()

		return _cResult_

	def Legend()

		# Create a legend string with all relevant information

		_cResult_ = "Grid: " + @nCols + "x" + @nRows + " | "
		_cResult_ += "Current: " + @cCurrentChar + " | "

		if @bShowObstacles
			_cResult_ += "Obstacles: " + @cObstacleChar + " | "
		ok

		if @bShowPath
			_cResult_ += "Path: " + @cPathChar + " | "
		ok

		return _cResult_

	# ReplaceAll(:With = val): record val as the fill value. The
	# subsequent Content() call materialises a @nRows x @nCols list
	# of lists filled with val. Used by stzObject.RepeatXT to spell
	# 'a grid of N x M filled with this value' as a fluent chain:
	#
	#   StzGridQ([3, 3]).ReplaceAllQ(:With = 5).Content()
	#     -> [[5,5,5], [5,5,5], [5,5,5]]

	def ReplaceAll(pNamedParam)
		if isList(pNamedParam) and len(pNamedParam) = 2 and
		   isString(pNamedParam[1]) and lower(pNamedParam[1]) = "with"
			@xFillValue = pNamedParam[2]
			@bHasFillValue = 1
			return
		ok
		StzRaise("ReplaceAll: expected :With = <value>.")

		def ReplaceAllQ(pNamedParam)
			This.ReplaceAll(pNamedParam)
			return This

	def Content()
		if NOT @bHasFillValue
			return []
		ok
		_aGrid_ = []
		for _iCgR_ = 1 to @nRows
			_aRow_ = []
			for _jCgC_ = 1 to @nCols
				_aRow_ + @xFillValue
			next
			_aGrid_ + _aRow_
		next
		return _aGrid_
