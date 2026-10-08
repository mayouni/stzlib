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

# Tracks a position on a grid of columns and rows, moves it in six directions, and finds routes around obstacles.
#
# A grid holds no data of its own. It keeps a current position counted from 1 at the top left, a
# direction, a set of obstacles and a stored path, and draws them as text. Positions are always [
# column, row ], the column first. Reach for it to walk a board, a maze or a map: move by steps, ask
# for the cell above, below or beside, list the neighbours, test whether two cells connect, split
# the grid into regions, or ask for a route. Moves that would leave the grid or land on an obstacle
# change nothing, without an error, while the Node and NthNode readers raise an error outside the
# grid. ManhattanPath and ZigZagPath raise when an obstacle is on the way; see their warnings.
#
#   receiver   o1 = new stzGrid([ 5, 4 ])
#   example    ? @@( o1.NodeRight() )
#              #--> [ 2, 1 ]
#              ? o1.DistanceTo(4, 3)
#              #--> 5
#   see        stzGraph, stzMatrix
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

	@bShowCoordinates = 1
	@bShowObstacles = 1
	@bShowPath = 1

	# When set via ReplaceAll(:With = val), Content() materializes
	# a 2D list of the grid dimensions filled with this value.
	@xFillValue = ""
	@bHasFillValue = 0

	# Builds a grid of the given numbers of columns and rows, with the current position on column 1, row 1.
	#
	#   panColRow   the size as [ columns, rows ], a pair of numbers
	#   returns     nothing; the object is built
	#   note        the grid holds no data of its own: it keeps a current position, a direction,
	#               obstacles and a path; anything but a pair of numbers raises an error
	#   see         Size, NumberOfColumns, NumberOfRows
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
	
	# Returns how many cells the grid has, its columns times its rows.
	#
	#   returns    a number
	#   see        NumberOfColumns, NumberOfRows, Nodes
	#@ aka  -- INFORMATION METHODS
	def Size()
		return @nCols * @nRows

		def NumberOfNodes()
			return This.Size()

		def NumberOfCells()
			return This.Size()

	def SizeXT()
		return [ @nCols, @nRows ]

	# Returns how many columns the grid has.
	#
	#   returns    a number
	#   see        NumberOfRows, Size
	def NumberOfColumns()
		return @nCols
	
	# Returns how many rows the grid has.
	#
	#   returns    a number
	#   see        NumberOfColumns, Size
	def NumberOfRows()
		return @nRows
		
	# Returns the current position as [ column, row ], counted from 1 at the top left.
	#
	#   returns    a pair of numbers [ column, row ]
	#   note       the column comes first, then the row
	#   see        CurrentColumn, CurrentRow, SetCurrentNode
	def CurrentPosition()
		return [ @nCurrentCol, @nCurrentRow ]

		# Returns the current position as [ column, row ], counted from 1 at the top left.
		#
		#   returns    a pair of numbers [ column, row ]
		#   note       the column comes first, then the row
		#   see        CurrentColumn, CurrentRow, SetCurrentNode
		def Position()
			return [ @nCurrentCol, @nCurrentRow ]

		# Returns the current position as [ column, row ], counted from 1 at the top left.
		#
		#   returns    a pair of numbers [ column, row ]
		#   note       the column comes first, then the row
		#   see        CurrentColumn, CurrentRow, SetCurrentNode
		def CurrentNode()
			return [ @nCurrentCol, @nCurrentRow ]

		# Returns the current position as [ column, row ], counted from 1 at the top left.
		#
		#   returns    a pair of numbers [ column, row ]
		#   note       the column comes first, then the row
		#   see        CurrentColumn, CurrentRow, SetCurrentNode
		def CurrentCell()
			return [ @nCurrentCol, @nCurrentRow ]

	# Returns the column of the current position, counted from 1.
	#
	#   returns    a number
	#   see        CurrentRow, CurrentPosition
	def CurrentColumn()
		return @nCurrentCol

	# Returns the row of the current position, counted from 1.
	#
	#   returns    a number
	#   see        CurrentColumn, CurrentPosition
	def CurrentRow()
		return @nCurrentRow
		
	# TRUE if the column and the row both fall inside the grid, counted from 1.
	#
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    TRUE or FALSE
	#   note       an obstacle is a valid position
	#   see        IsCurrentPositionValid, IsObstacle
	def IsValidPosition(_nCol_, _nRow_)

		if _nCol_ >= 1 and _nCol_ <= @nCols and
		   _nRow_ >= 1 and _nRow_ <= @nRows

			return 1
		else
			return 0
		ok

		def IsValideNode(_nCol_, _nRow_)
			return This.IsValidPosition(_nCol_, _nRow_)

		def IsValidCell(_nCol_, _nRow_)
			return This.IsValidPosition(_nCol_, _nRow_)

	# TRUE if the current position falls inside the grid, which it always does unless it was forced.
	#
	#   returns    TRUE or FALSE
	#   see        IsValidPosition
	def IsCurrentPositionValid() # For debugging purposes
		return IsValidPosition( @nCurrentCol, @nCurrentRow)

		def IsCurrentNodeValid()
			return This.IsCurrentPositionValid()

		def IsCurrentCellValid()
			return This.IsCurrentPositionValid()

	# Returns the direction the grid is facing, in lower case: forward, backward, left, right, up or down.
	#
	#   returns    a text, forward by default
	#   note       the Move...N methods turn the direction as they go
	#   see        SetDirection, MoveN
	#@ aka  -- CONFIGURATION
	def Direction()
		return @cDirection
		
	# Turns the grid to face forward, backward, left, right, up or down; any other word raises an error.
	#
	#   _cDirection_   The direction: forward, backward, left, right, up or down; case is ignored.
	#   returns        nothing; the direction changes
	#   note           case is ignored; the position does not change
	#   see            Direction, MoveToNextNode
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

	# Puts the current position on the given cell, whatever is there; raises an error outside the grid.
	#
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    nothing; the position changes
	#   note       unlike MoveToNode it does not check for an obstacle and does not turn the
	#              direction
	#   warning    The error raised for a cell outside the grid is R24, Using uninitialized variable
	#              @nrow, instead of the intended range message: the message reads an attribute that
	#              does not exist
	#   see        MoveToNode, CurrentPosition
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

		# Puts the current position on the given cell, whatever is there; raises an error outside the grid.
		#
		#   _nCol_     The column, counted from 1 at the left.
		#   _nRow_     The row, counted from 1 at the top.
		#   returns    nothing; the position changes
		#   note       unlike MoveToNode it does not check for an obstacle and does not turn the
		#              direction
		#   warning    The error raised for a cell outside the grid is R24, Using uninitialized
		#              variable @nrow, instead of the intended range message: the message reads an
		#              attribute that does not exist
		#   see        MoveToNode, CurrentPosition
		def SetCurrentPosition(_nCol_, _nRow_)
			This.SetCurrentNode(_nCol_, _nRow_)

		# Puts the current position on the given cell, whatever is there; raises an error outside the grid.
		#
		#   _nCol_     The column, counted from 1 at the left.
		#   _nRow_     The row, counted from 1 at the top.
		#   returns    nothing; the position changes
		#   note       unlike MoveToNode it does not check for an obstacle and does not turn the
		#              direction
		#   warning    The error raised for a cell outside the grid is R24, Using uninitialized
		#              variable @nrow, instead of the intended range message: the message reads an
		#              attribute that does not exist
		#   see        MoveToNode, CurrentPosition
		#@ aka  SetCurrenCell is missing the T of Current. It stays, because someone may have typed it, but the name a caller would actually reach for now exists.
		def SetCurrenCell(_nCol_, _nRow_)
			This.SetCurrentNode(_nCol_, _nRow_)

		# Puts the current position on the given cell, whatever is there; raises an error outside the grid.
		#
		#   _nCol_     The column, counted from 1 at the left.
		#   _nRow_     The row, counted from 1 at the top.
		#   returns    nothing; the position changes
		#   note       unlike MoveToNode it does not check for an obstacle and does not turn the
		#              direction
		#   warning    The error raised for a cell outside the grid is R24, Using uninitialized
		#              variable @nrow, instead of the intended range message: the message reads an
		#              attribute that does not exist
		#   see        MoveToNode, CurrentPosition
		def SetCurrentCell(_nCol_, _nRow_)
			This.SetCurrentNode(_nCol_, _nRow_)

	# Moves the current position onto the given cell; raises an error outside the grid, and stays put on an obstacle.
	#
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    nothing; the position changes
	#   note       an obstacle blocks the move without any error; the direction is kept
	#   see        SetCurrentNode, MoveBy
	#@ aka  -- MOVEMENT METHODS
	def MoveToNode(_nCol_, _nRow_)
		if NOT IsValidPosition(_nCol_, _nRow_)
			StzRaise("Can't move! The provided position is not valid.")
		ok

		if NOT IsObstacle(_nCol_, _nRow_)
			@nCurrentCol = _nCol_
			@nCurrentRow = _nRow_
		ok

		# Moves the current position onto the given cell; raises an error outside the grid, and stays put on an obstacle.
		#
		#   _nCol_     The column, counted from 1 at the left.
		#   _nRow_     The row, counted from 1 at the top.
		#   returns    nothing; the position changes
		#   note       an obstacle blocks the move without any error; the direction is kept
		#   see        SetCurrentNode, MoveBy
		def Moveto(_nCol_, _nRow_)
			This.MoveToNode(_nCol_, _nRow_)

		# Moves the current position onto the given cell; raises an error outside the grid, and stays put on an obstacle.
		#
		#   _nCol_     The column, counted from 1 at the left.
		#   _nRow_     The row, counted from 1 at the top.
		#   returns    nothing; the position changes
		#   note       an obstacle blocks the move without any error; the direction is kept
		#   see        SetCurrentNode, MoveBy
		def MoveToCell(_nCol_, _nRow_)
			This.MoveToNode(_nCol_, _nRow_)

	# Moves the current position to column 1, row 1, the top left cell, unless it is an obstacle.
	#
	#   returns    nothing; the position changes
	#   see        MoveToLastNode, MoveToNode
	def MoveToFirstNode()
		This.MoveToNode(1, 1)
		
		# Moves the current position to column 1, row 1, the top left cell, unless it is an obstacle.
		#
		#   returns    nothing; the position changes
		#   see        MoveToLastNode, MoveToNode
		def MovetoFirstPosition()
			This.MoveToNode(1, 1)

		# Moves the current position to column 1, row 1, the top left cell, unless it is an obstacle.
		#
		#   returns    nothing; the position changes
		#   see        MoveToLastNode, MoveToNode
		def MoveToFirstCell()
			This.MoveToNode(1, 1)

	# Moves the current position to the last column of the last row, the bottom right cell, unless it is an obstacle.
	#
	#   returns    nothing; the position changes
	#   see        MoveToFirstNode, MoveToNode
	def MoveToLastNode()
		This.MoveToNode(@nCols, @nRows)
		
		# Moves the current position to the last column of the last row, the bottom right cell, unless it is an obstacle.
		#
		#   returns    nothing; the position changes
		#   see        MoveToFirstNode, MoveToNode
		def MovetoLastPosition()
			This.MoveToNode(@nCols, @nRows)

		# Moves the current position to the last column of the last row, the bottom right cell, unless it is an obstacle.
		#
		#   returns    nothing; the position changes
		#   see        MoveToFirstNode, MoveToNode
		def MoveToLast()
			This.MoveToNode(@nCols, @nRows)

		# Moves the current position to the last column of the last row, the bottom right cell, unless it is an obstacle.
		#
		#   returns    nothing; the position changes
		#   see        MoveToFirstNode, MoveToNode
		def MoveLast()
			This.MoveToNode(@nCols, @nRows)

		# Moves the current position to the last column of the last row, the bottom right cell, unless it is an obstacle.
		#
		#   returns    nothing; the position changes
		#   see        MoveToFirstNode, MoveToNode
		def MovetoLastCell()
			This.MoveToNode(@nCols, @nRows)

	# Moves the current position one step in the direction the grid faces.
	#
	#   returns    nothing; the position changes
	#   note       forward and backward wrap from one row to the next; the other directions stop at
	#              the edge; an obstacle blocks the step
	#   see        MoveToPreviousNode, SetDirection, MoveN
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

		# Moves the current position one step in the direction the grid faces.
		#
		#   returns    nothing; the position changes
		#   note       forward and backward wrap from one row to the next; the other directions stop
		#              at the edge; an obstacle blocks the step
		#   see        MoveToPreviousNode, SetDirection, MoveN
		def MoveToNextPosition()
			This.MoveToNextNode()

		# Moves the current position one step in the direction the grid faces.
		#
		#   returns    nothing; the position changes
		#   note       forward and backward wrap from one row to the next; the other directions stop
		#              at the edge; an obstacle blocks the step
		#   see        MoveToPreviousNode, SetDirection, MoveN
		def MoveToNext()
			This.MoveToNextNode()

		# Moves the current position one step in the direction the grid faces.
		#
		#   returns    nothing; the position changes
		#   note       forward and backward wrap from one row to the next; the other directions stop
		#              at the edge; an obstacle blocks the step
		#   see        MoveToPreviousNode, SetDirection, MoveN
		def MoveNext()
			This.MoveToNextNode()

		# Moves the current position one step in the direction the grid faces.
		#
		#   returns    nothing; the position changes
		#   note       forward and backward wrap from one row to the next; the other directions stop
		#              at the edge; an obstacle blocks the step
		#   see        MoveToPreviousNode, SetDirection, MoveN
		def MoveToNextCell()
			This.MoveToNextNode()

	# Moves the current position one step against the direction the grid faces.
	#
	#   returns    nothing; the position changes
	#   note       it leaves the direction turned round: facing forward becomes backward, right
	#              becomes left
	#   see        MoveToNextNode, SetDirection
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
		
		# Moves the current position one step against the direction the grid faces.
		#
		#   returns    nothing; the position changes
		#   note       it leaves the direction turned round: facing forward becomes backward, right
		#              becomes left
		#   see        MoveToNextNode, SetDirection
		def MoveToPreviousPosition()
			This.MoveToPreviousNode()

		# Moves the current position one step against the direction the grid faces.
		#
		#   returns    nothing; the position changes
		#   note       it leaves the direction turned round: facing forward becomes backward, right
		#              becomes left
		#   see        MoveToNextNode, SetDirection
		def MoveToPrevious()
			This.MoveToPreviousNode()

		# Moves the current position one step against the direction the grid faces.
		#
		#   returns    nothing; the position changes
		#   note       it leaves the direction turned round: facing forward becomes backward, right
		#              becomes left
		#   see        MoveToNextNode, SetDirection
		def MovePrevious()
			This.MoveToPreviousNode()

		# Moves the current position one step against the direction the grid faces.
		#
		#   returns    nothing; the position changes
		#   note       it leaves the direction turned round: facing forward becomes backward, right
		#              becomes left
		#   see        MoveToNextNode, SetDirection
		def MoveToPreviousCell()
			This.MoveToPreviousNode()

	# Moves the current position n steps in the direction the grid faces, in one jump.
	#
	#   n          The number of steps.
	#   returns    nothing; the position changes
	#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
	#              direction is kept
	#   see        MoveToNextNthNode, MoveN
	#@ aka  --
	def MoveToNthNode(n)
		This.MoveToNextNthNode(n)

		# Moves the current position n steps in the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
		#              direction is kept
		#   see        MoveToNextNthNode, MoveN
		def MoveToNthPosition(n)
			This.MoveToNthNode(n)

		# Moves the current position n steps in the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
		#              direction is kept
		#   see        MoveToNextNthNode, MoveN
		def MoveToNthCell(n)
			This.MoveToNthNode(n)

	# Moves the current position n steps in the direction the grid faces, in one jump.
	#
	#   n          The number of steps.
	#   returns    nothing; the position changes
	#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
	#              direction is kept
	#   see        NextNthNode, MoveN, MoveToPreviousNthNode
	def MoveToNextNthNode(n)
		_aNode_ = This.NextNthNode(n)
		This.MoveToNode(_aNode_[1], _aNode_[2])

		# Moves the current position n steps in the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing;
		#              the direction is kept
		#   see        NextNthNode, MoveN, MoveToPreviousNthNode
		def MoveToNthNextNode(n)
			This.MoveToNextNthNode(n)

		# Moves the current position n steps in the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing;
		#              the direction is kept
		#   see        NextNthNode, MoveN, MoveToPreviousNthNode
		def MoveToNthNext(n)
			This.MoveToNextNthNode(n)

		# Moves the current position n steps in the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing;
		#              the direction is kept
		#   see        NextNthNode, MoveN, MoveToPreviousNthNode
		def MoveToNextNth(n)
			This.MoveToNextNthNode(n)


		# Moves the current position n steps in the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing;
		#              the direction is kept
		#   see        NextNthNode, MoveN, MoveToPreviousNthNode
		def MoveToNextNthPosition(n)
			This.MoveToNextNthNode(n)

		# Moves the current position n steps in the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing;
		#              the direction is kept
		#   see        NextNthNode, MoveN, MoveToPreviousNthNode
		def MoveToNthNextPosition(n)
			This.MoveToNextNthNode(n)


		# Moves the current position n steps in the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing;
		#              the direction is kept
		#   see        NextNthNode, MoveN, MoveToPreviousNthNode
		def MoveToNextNthCell(n)
			This.MoveToNextNthNode(n)

		# Moves the current position n steps in the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing;
		#              the direction is kept
		#   see        NextNthNode, MoveN, MoveToPreviousNthNode
		def MoveToNthNextCell(n)
			This.MoveToNextNthNode(n)

	# Moves the current position n steps against the direction the grid faces, in one jump.
	#
	#   n          The number of steps.
	#   returns    nothing; the position changes
	#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
	#              direction is kept
	#   see        MoveToNextNthNode, PreviousNthNode
	#@ aka  --
	def MoveToPreviousNthNode(n)
		_aNode_ = This.PreviousNthNode(n)
		This.MoveToNode(_aNode_[1], _aNode_[2])

		# Moves the current position n steps against the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
		#              direction is kept
		#   see        MoveToNextNthNode, PreviousNthNode
		def MoveToNthPreviousNode(n)
			This.MoveToPreviousNthNode(n)

		# Moves the current position n steps against the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
		#              direction is kept
		#   see        MoveToNextNthNode, PreviousNthNode
		def MoveToNthPrevious(n)
			This.MoveToPreviousNthNode(n)

		# Moves the current position n steps against the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
		#              direction is kept
		#   see        MoveToNextNthNode, PreviousNthNode
		def MoveToPreviousNth(n)
			This.MoveToPreviousNthNode(n)


		# Moves the current position n steps against the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
		#              direction is kept
		#   see        MoveToNextNthNode, PreviousNthNode
		def MoveToPreviousNthPosition(n)
			This.MoveToPreviousNthNode(n)

		# Moves the current position n steps against the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
		#              direction is kept
		#   see        MoveToNextNthNode, PreviousNthNode
		def MoveToNthPreviousPosition(n)
			This.MoveToPreviousNthNode(n)


		# Moves the current position n steps against the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
		#              direction is kept
		#   see        MoveToNextNthNode, PreviousNthNode
		def MoveToPreviousNthCell(n)
			This.MoveToPreviousNthNode(n)

		# Moves the current position n steps against the direction the grid faces, in one jump.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       a jump that would leave the grid, or land on an obstacle, changes nothing; the
		#              direction is kept
		#   see        MoveToNextNthNode, PreviousNthNode
		def MoveToNthPreviousCell(n)
			This.MoveToPreviousNthNode(n)

	# Moves the current position by a number of columns and rows, which may be negative.
	#
	#   nCols      The number of columns to move by; a negative number moves left.
	#   nRows      The number of rows to move by; a negative number moves up.
	#   returns    nothing; the position changes
	#   note       a target outside the grid raises an error; a target on an obstacle changes
	#              nothing; the direction is kept
	#   see        MoveToNode, MoveN
	#@ aka  --
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

		# Moves the current position by a number of columns and rows, which may be negative.
		#
		#   nCols      The number of columns to move by; a negative number moves left.
		#   nRows      The number of rows to move by; a negative number moves up.
		#   returns    nothing; the position changes
		#   note       a target outside the grid raises an error; a target on an obstacle changes
		#              nothing; the direction is kept
		#   see        MoveToNode, MoveN
		def MoveByNColsNRows(nCols, nRows)
			This.MoveBy(nCols, nRows)

		# Moves the current position by a number of columns and rows, which may be negative.
		#
		#   nCols      The number of columns to move by; a negative number moves left.
		#   nRows      The number of rows to move by; a negative number moves up.
		#   returns    nothing; the position changes
		#   note       a target outside the grid raises an error; a target on an obstacle changes
		#              nothing; the direction is kept
		#   see        MoveToNode, MoveN
		def MoveFor(nCols, nRows)
			This.MoveBy(nCols, nRows)

		# Moves the current position by a number of columns and rows, which may be negative.
		#
		#   nCols      The number of columns to move by; a negative number moves left.
		#   nRows      The number of rows to move by; a negative number moves up.
		#   returns    nothing; the position changes
		#   note       a target outside the grid raises an error; a target on an obstacle changes
		#              nothing; the direction is kept
		#   see        MoveToNode, MoveN
		def MoveForNColsNRows(nCols, nRows)
			This.MoveBy(nCols, nRows)

	# Moves the current position n steps in the direction the grid faces, whatever it is.
	#
	#   n          The number of steps.
	#   returns    nothing; the position changes
	#   note       it turns to the direction method of the current direction, so the direction may
	#              be set by it
	#   see        Move, MoveForwardN, MoveRightN
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
		
		# Moves the current position n steps in the direction the grid faces, whatever it is.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       it turns to the direction method of the current direction, so the direction
		#              may be set by it
		#   see        Move, MoveForwardN, MoveRightN
		def MoveNNodes(n)
			This.MoveN(n)

		# Moves the current position n steps in the direction the grid faces, whatever it is.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       it turns to the direction method of the current direction, so the direction
		#              may be set by it
		#   see        Move, MoveForwardN, MoveRightN
		def MoveNCells(n)
			This.MoveN(n)

	# Moves the current position one step in the direction the grid faces.
	#
	#   returns    nothing; the position changes
	#   see        MoveN, MoveToNextNode
	def Move()
		This.MoveN(1)

	# Turns the grid forward and moves n columns right, or to column 1 of the row n lower when the row has no room.
	#
	#   n          The number of steps.
	#   returns    nothing; the position changes
	#   note       forward reads the grid row by row, but the wrap goes n rows down, not n cells on,
	#              so from column 3 of 4, row 1, two steps land on column 1, row 3; with no such
	#              row, or an obstacle, nothing moves
	#   see        MoveForward, MoveBackwardN, MoveRightN
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

		# Turns the grid forward and moves n columns right, or to column 1 of the row n lower when the row has no room.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       forward reads the grid row by row, but the wrap goes n rows down, not n cells
		#              on, so from column 3 of 4, row 1, two steps land on column 1, row 3; with no
		#              such row, or an obstacle, nothing moves
		#   see        MoveForward, MoveBackwardN, MoveRightN
		def MoveForwardNNodes(n)
			This.MoveForwardN(n)

		# Turns the grid forward and moves n columns right, or to column 1 of the row n lower when the row has no room.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       forward reads the grid row by row, but the wrap goes n rows down, not n cells
		#              on, so from column 3 of 4, row 1, two steps land on column 1, row 3; with no
		#              such row, or an obstacle, nothing moves
		#   see        MoveForward, MoveBackwardN, MoveRightN
		def MoveNForward(n)
			This.MoveForwardN(n)

		# Turns the grid forward and moves n columns right, or to column 1 of the row n lower when the row has no room.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       forward reads the grid row by row, but the wrap goes n rows down, not n cells
		#              on, so from column 3 of 4, row 1, two steps land on column 1, row 3; with no
		#              such row, or an obstacle, nothing moves
		#   see        MoveForward, MoveBackwardN, MoveRightN
		def MoveNNodesForward(n)
			This.MoveForwardN(n)

		# Turns the grid forward and moves n columns right, or to column 1 of the row n lower when the row has no room.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       forward reads the grid row by row, but the wrap goes n rows down, not n cells
		#              on, so from column 3 of 4, row 1, two steps land on column 1, row 3; with no
		#              such row, or an obstacle, nothing moves
		#   see        MoveForward, MoveBackwardN, MoveRightN
		def MoveForwardNCells(n)
			This.MoveForwardN(n)

		# Turns the grid forward and moves n columns right, or to column 1 of the row n lower when the row has no room.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       forward reads the grid row by row, but the wrap goes n rows down, not n cells
		#              on, so from column 3 of 4, row 1, two steps land on column 1, row 3; with no
		#              such row, or an obstacle, nothing moves
		#   see        MoveForward, MoveBackwardN, MoveRightN
		def MoveNCellsForward(n)
			This.MoveForwardN(n)

	# Turns the grid forward and moves one cell on, to column 1 of the next row at the end of a row.
	#
	#   returns    nothing; the position changes
	#   note       at the last cell, or before an obstacle, it stays put
	#   see        MoveForwardN, MoveBackward
	def MoveForward()
		This.MoveForwardN(1)

	# Turns the grid backward and moves n columns left, or to the last column of the row n higher when the row has no room.
	#
	#   n          The number of steps.
	#   returns    nothing; the position changes
	#   note       with no such row, or an obstacle, nothing moves: from column 2 of row 2 two steps
	#              back stay where they are
	#   see        MoveBackward, MoveForwardN, MoveLeftN
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

		# Turns the grid backward and moves n columns left, or to the last column of the row n higher when the row has no room.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       with no such row, or an obstacle, nothing moves: from column 2 of row 2 two
		#              steps back stay where they are
		#   see        MoveBackward, MoveForwardN, MoveLeftN
		def MoveBackwardNNodes(n)
			This.MoveBackwardN(n)

		# Turns the grid backward and moves n columns left, or to the last column of the row n higher when the row has no room.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       with no such row, or an obstacle, nothing moves: from column 2 of row 2 two
		#              steps back stay where they are
		#   see        MoveBackward, MoveForwardN, MoveLeftN
		def MoveNBackward(n)
			This.MoveBackwardN(n)

		# Turns the grid backward and moves n columns left, or to the last column of the row n higher when the row has no room.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       with no such row, or an obstacle, nothing moves: from column 2 of row 2 two
		#              steps back stay where they are
		#   see        MoveBackward, MoveForwardN, MoveLeftN
		def MoveNNodesBackward(n)
			This.MoveBackwardN(n)

		# Turns the grid backward and moves n columns left, or to the last column of the row n higher when the row has no room.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       with no such row, or an obstacle, nothing moves: from column 2 of row 2 two
		#              steps back stay where they are
		#   see        MoveBackward, MoveForwardN, MoveLeftN
		def MoveBackwardNCells(n)
			This.MoveBackwardN(n)

		# Turns the grid backward and moves n columns left, or to the last column of the row n higher when the row has no room.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       with no such row, or an obstacle, nothing moves: from column 2 of row 2 two
		#              steps back stay where they are
		#   see        MoveBackward, MoveForwardN, MoveLeftN
		def MoveNCellsBackward(n)
			This.MoveBackwardN(n)

	# Turns the grid backward and moves one cell back, to the last column of the row above at the start of a row.
	#
	#   returns    nothing; the position changes
	#   note       at the first cell, or before an obstacle, it stays put
	#   see        MoveBackwardN, MoveForward
	def MoveBackward()
		This.MoveBackwardN(1)

	# Turns the grid right and moves n columns right, unless that leaves the grid or lands on an obstacle.
	#
	#   n          The number of steps.
	#   returns    nothing; the position changes
	#   note       nothing moves when the target is outside the grid or an obstacle; the cells in
	#              between are not checked
	#   see        MoveRight, MoveLeftN, MoveN
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

		# Turns the grid right and moves n columns right, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       nothing moves when the target is outside the grid or an obstacle; the cells
		#              in between are not checked
		#   see        MoveRight, MoveLeftN, MoveN
		def MoveRightNNodes(n)
			This.MoveRightN(n)

		# Turns the grid right and moves n columns right, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveRightN, MoveN
		def MoveNRight(n)
			This.MoveRightN(n)

		# Turns the grid right and moves n columns right, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveRightN, MoveN
		def MoveNNodesRight(n)
			This.MoveRightN(n)

		# Turns the grid right and moves n columns right, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       nothing moves when the target is outside the grid or an obstacle; the cells
		#              in between are not checked
		#   see        MoveRight, MoveLeftN, MoveN
		def MoveRightNCells(n)
			This.MoveRightN(n)

		# Turns the grid right and moves n columns right, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveRightN, MoveN
		def MoveNCellsRight(n)
			This.MoveRightN(n)

	# Turns the grid right and moves one cell right.
	#
	#   returns    nothing; the position changes
	#   note       at the edge, or before an obstacle, it stays put
	#   see        MoveRightN, MoveLeft
	def MoveRight()
		This.MoveRightN(1)

	# Turns the grid left and moves n columns left, unless that leaves the grid or lands on an obstacle.
	#
	#   n          The number of steps.
	#   returns    nothing; the position changes
	#   see        MoveLeft, MoveRightN, MoveN
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

		# Turns the grid left and moves n columns left, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   see        MoveLeft, MoveRightN, MoveN
		def MoveLeftNNodes(n)
			This.MoveLeftN(n)

		# Turns the grid left and moves n columns left, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveLeftN, MoveN
		def MoveNLeft(n)
			This.MoveLeftN(n)

		# Turns the grid left and moves n columns left, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveLeftN, MoveN
		def MoveNNodesLeft(n)
			This.MoveLeftN(n)

		# Turns the grid left and moves n columns left, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   see        MoveLeft, MoveRightN, MoveN
		def MoveLeftNCells(n)
			This.MoveLeftN(n)

		# Turns the grid left and moves n columns left, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveLeftN, MoveN
		def MoveNCellsLeft(n)
			This.MoveLeftN(n)

	# Turns the grid left and moves one cell left.
	#
	#   returns    nothing; the position changes
	#   note       at the edge, or before an obstacle, it stays put
	#   see        MoveLeftN, MoveRight
	def MoveLeft()
		This.MoveLeftN(1)

	# Turns the grid up and moves n rows up, unless that leaves the grid or lands on an obstacle.
	#
	#   n          The number of steps.
	#   returns    nothing; the position changes
	#   see        MoveUp, MoveDownN, MoveN
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

		# Turns the grid up and moves n rows up, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   see        MoveUp, MoveDownN, MoveN
		def MoveUpNNodes(n)
			This.MoveUpN(n)

		# Turns the grid up and moves n rows up, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveUpN, MoveN
		def MoveNUp(n)
			This.MoveUpN(n)

		# Turns the grid up and moves n rows up, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveUpN, MoveN
		def MoveNNodesUp(n)
			This.MoveUpN(n)

		# Turns the grid up and moves n rows up, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   see        MoveUp, MoveDownN, MoveN
		def MoveUpNCells(n)
			This.MoveUpN(n)

		# Turns the grid up and moves n rows up, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveUpN, MoveN
		def MoveNCellsUp(n)
			This.MoveUpN(n)

	# Turns the grid up and moves one cell up.
	#
	#   returns    nothing; the position changes
	#   note       at the edge, or before an obstacle, it stays put
	#   see        MoveUpN, MoveDown
	def MoveUp()
		This.MoveUpN(1)

	# Turns the grid down and moves n rows down, unless that leaves the grid or lands on an obstacle.
	#
	#   n          The number of steps.
	#   returns    nothing; the position changes
	#   see        MoveDown, MoveUpN, MoveN
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

		# Turns the grid down and moves n rows down, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   see        MoveDown, MoveUpN, MoveN
		def MoveDownNNodes(n)
			This.MoveDownN(n)

		# Turns the grid down and moves n rows down, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveDownN, MoveN
		def MoveNDown(n)
			This.MoveDownN(n)

		# Turns the grid down and moves n rows down, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveDownN, MoveN
		def MoveNNodesDown(n)
			This.MoveDownN(n)

		# Turns the grid down and moves n rows down, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   see        MoveDown, MoveUpN, MoveN
		def MoveDownNCells(n)
			This.MoveDownN(n)

		# Turns the grid down and moves n rows down, unless that leaves the grid or lands on an obstacle.
		#
		#   n          The number of steps.
		#   returns    nothing; the position changes
		#   note       the cells in between are not checked
		#   see        MoveDownN, MoveN
		def MoveNCellsDown(n)
			This.MoveDownN(n)

	# Turns the grid down and moves one cell down.
	#
	#   returns    nothing; the position changes
	#   note       at the edge, or before an obstacle, it stays put
	#   see        MoveDownN, MoveUp
	def MoveDown()
		This.MoveDownN(1)

	# Returns every cell of the grid as [ column, row ], column by column, from the top of column 1.
	#
	#   returns    a list of [ column, row ] pairs
	#   note       Positions and Cells give the same list
	#   see        Size, Neighbors
	#@ aka  -- TRAVERSAL METHODS
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
		
	# Returns the up to eight cells around the current position, obstacles included, ordered by column then row.
	#
	#   returns    a list of [ column, row ] pairs
	#   note       a corner has three, an edge five; WalkableNeighbors drops the obstacles and the
	#              diagonals
	#   see        WalkableNeighbors, ShowNeighbors
	#@ aka  -- NEIGHBORS & RELATIVE POSITIONS
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

	# Prints the grid with the cells around the current position marked by the neighbour character.
	#
	#   returns    nothing; the grid is printed
	#   see        Neighbors, SetNeighborChar, Show
	def ShowNeighbors()
		This.ShowNodes(This.Neighbors(), @cNeighborChar)

		# Prints the grid with the cells around the current position marked by the neighbour character.
		#
		#   returns    nothing; the grid is printed
		#   see        Neighbors, SetNeighborChar, Show
		def ShowAdjacent()
			This.ShowNeighbors()

		# Prints the grid with the cells around the current position marked by the neighbour character.
		#
		#   returns    nothing; the grid is printed
		#   see        Neighbors, SetNeighborChar, Show
		def ShowAdjacents()
			This.ShowNeighbors()

		# Prints the grid with the cells around the current position marked by the neighbour character.
		#
		#   returns    nothing; the grid is printed
		#   see        Neighbors, SetNeighborChar, Show
		def ShowAdjacentNodes()
			This.ShowNeighbors()

		# Prints the grid with the cells around the current position marked by the neighbour character.
		#
		#   returns    nothing; the grid is printed
		#   see        Neighbors, SetNeighborChar, Show
		def ShowAdjacentCells()
			This.ShowNeighbors()

	# Returns the cell just above the current position; raises an error at the top row.
	#
	#   returns    a pair [ column, row ]
	#   see        NodeDown, NthNodeUp
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

	# Returns the cell above and to the left of the current position; raises an error when there is none.
	#
	#   returns    a pair [ column, row ]
	#   note       the error message says above, even when the left edge is the cause
	#   see        NodeUp, NodeLeft
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

	# Returns the cell above and to the right of the current position; raises an error when there is none.
	#
	#   returns    a pair [ column, row ]
	#   see        NodeUp, NodeRight
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

	# Returns the cell just below the current position; raises an error at the bottom row.
	#
	#   returns    a pair [ column, row ]
	#   see        NodeUp, NthNodeDown
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

	# Returns the cell below and to the left of the current position; raises an error when there is none.
	#
	#   returns    a pair [ column, row ]
	#   see        NodeDown, NodeLeft
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

	# Returns the cell below and to the right of the current position; raises an error when there is none.
	#
	#   returns    a pair [ column, row ]
	#   see        NodeDown, NodeRight
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

	# Returns the cell just left of the current position; raises an error at the first column.
	#
	#   returns    a pair [ column, row ]
	#   see        NodeRight, NthNodeLeft
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

	# Returns the cell just right of the current position; raises an error at the last column.
	#
	#   returns    a pair [ column, row ]
	#   see        NodeLeft, NthNodeRight
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

	# Returns the Manhattan distance, columns plus rows, from the current position to the given cell.
	#
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    a number
	#   note       obstacles are ignored
	#   see        EuclideanDistanceTo, HeuristicCost
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

	# Returns the straight-line distance from the current position to the given cell.
	#
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    a number
	#   see        DistanceTo
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
	
	# Returns the cell n steps ahead in the direction the grid faces, without moving; the current cell when the move is blocked.
	#
	#   n          The number of steps.
	#   returns    a pair [ column, row ]
	#   note       a jump out of the grid or onto an obstacle answers the current position, not an
	#              error; forward and backward wrap as MoveForwardN does
	#   see        PreviousNthNode, MoveToNextNthNode
	#@ aka  -- N-NODE RELATIVE POSITION METHODS
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

	# Returns the cell n steps against the direction the grid faces, without moving.
	#
	#   n          The number of steps.
	#   returns    a pair [ column, row ]
	#   note       a jump out of the grid or onto an obstacle answers the current position; the
	#              position and the direction are left as they were
	#   see        NextNthNode, MoveToPreviousNthNode
	def PreviousNthNode(n)
		# Save current position
		_nOldCol_ = @nCurrentCol
		_nOldRow_ = @nCurrentRow
		_cOldDirection_ = @cDirection
		
		# Turn round ONCE, then move n steps (turning round per step cancelled the steps)
		if @cDirection = :forward
			@cDirection = :backward
		but @cDirection = :backward
			@cDirection = :forward
		but @cDirection = :left
			@cDirection = :right
		but @cDirection = :right
			@cDirection = :left
		but @cDirection = :up
			@cDirection = :down
		but @cDirection = :down
			@cDirection = :up
		ok
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

	
	# Returns the cell n rows above the current position; raises an error when it falls outside the grid.
	#
	#   n          The number of steps.
	#   returns    a pair [ column, row ]
	#   see        NodeUp, NthNodeDown
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

	# Returns the cell n rows below the current position; raises an error when it falls outside the grid.
	#
	#   n          The number of steps.
	#   returns    a pair [ column, row ]
	#   see        NodeDown, NthNodeUp
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

	# Returns the cell n columns left of the current position; raises an error when it falls outside the grid.
	#
	#   n          The number of steps.
	#   returns    a pair [ column, row ]
	#   see        NodeLeft, NthNodeRight
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

	# Returns the cell n columns right of the current position; raises an error when it falls outside the grid.
	#
	#   n          The number of steps.
	#   returns    a pair [ column, row ]
	#   see        NodeRight, NthNodeLeft
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

	# Marks a cell as an obstacle that moves and paths avoid; raises an error outside the grid.
	#
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    nothing; the obstacle is recorded
	#   note       adding the same cell twice records it once; an obstacle may sit under the current
	#              position
	#   see        AddObstacles, RemoveObstacle, IsObstacle
	#@ aka  -- OBSTACLES MANAGEMENT
	def AddObstacle(_nCol_, _nRow_)
		if NOT IsValidPosition(_nCol_, _nRow_)
			stzRaise("Invalid position for obstacle!")
		ok
		
		if NOT This.IsObstacle(_nCol_, _nRow_)
			@aObstacles + [_nCol_, _nRow_]
		ok
		
	# Marks each cell of a list as an obstacle, skipping items that are not a pair.
	#
	#   aPositions   A list of [ column, row ] pairs.
	#   returns      nothing; the obstacles are recorded
	#   note         a pair outside the grid raises an error and the pairs before it are kept
	#   see          AddObstacle, ClearObstacles
	def AddObstacles(aPositions)
		_nPositionsLen_ = len(aPositions)
		for i = 1 to _nPositionsLen_
			if isList(aPositions[i]) and len(aPositions[i]) = 2
				This.AddObstacle(aPositions[i][1], aPositions[i][2])
			ok
		next
		
	# Removes the obstacle on a cell; a cell without one changes nothing.
	#
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    nothing; the obstacle is removed
	#   see        AddObstacle, ClearObstacles
	def RemoveObstacle(_nCol_, _nRow_)
		_nObstaclesLen_4 = len(@aObstacles)
		for i = 1 to _nObstaclesLen_4
			if @aObstacles[i][1] = _nCol_ and @aObstacles[i][2] = _nRow_
				del(@aObstacles, i)
				return
			ok
		next
		
	# Removes every obstacle.
	#
	#   returns    nothing; the obstacles are removed
	#   see        RemoveObstacle, AddObstacles
	def ClearObstacles()
		@aObstacles = []
		
		# Removes every obstacle.
		#
		#   returns    nothing; the obstacles are removed
		#   see        RemoveObstacle, AddObstacles
		def RemoveObstacles()
			@aObstacles = []

	# TRUE if the cell holds an obstacle.
	#
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    TRUE or FALSE
	#   see        AddObstacle, Obstacles
	def IsObstacle(_nCol_, _nRow_)
		_nObstaclesLen_3 = len(@aObstacles)
		for i = 1 to _nObstaclesLen_3
			if @aObstacles[i][1] = _nCol_ and @aObstacles[i][2] = _nRow_
				return 1
			ok
		next
		return 0

	# Tells whether every cell of a list of [ column, row ] pairs holds an obstacle.
	#
	#   panColRow   A list of [ column, row ] pairs.
	#   returns     TRUE or FALSE; TRUE for an empty list
	#   note        anything but a list of pairs of numbers raises an error
	#   see         IsObstacle
	def AreObstacles(panColRow)
		if CheckParams()
			if NOT (isList(panColRow) and IsListOfPairsOfNumbers(panColRow))
				StzRaise("Incorrect param type! panColrow must be a list of pairs of numbers.")
			ok
		ok

		_nLen_ = len(panColRow)
		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT This.IsObstacle(panColRow[i][1], panColRow[i][2])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

	# Sets the character that draws the obstacles; anything but one character raises an error.
	#
	#   _cChar_    The single character to draw with.
	#   returns    nothing; the character changes
	#   see        ObstacleChar, ToString
	def SetObstacleChar(_cChar_)
		if isString(_cChar_) and @IsChar(_cChar_)
			@cObstacleChar = _cChar_
		else
			stzRaise("Obstacle character must be a single character!")
		ok

		# Sets the character that draws the obstacles; anything but one character raises an error.
		#
		#   _cChar_    The single character to draw with.
		#   returns    nothing; the character changes
		#   see        ObstacleChar, ToString
		def SetObstacleNode(_cChar_)
			This.SetObstacleChar(_cChar_)

	# Returns the character that draws the obstacles.
	#
	#   returns    a text of one character, ■ by default
	#   see        SetObstacleChar
	def ObstacleChar()
		return @cObstacleChar
		
	# Returns the obstacles as a list of [ column, row ] pairs, in the order they were added.
	#
	#   returns    a list of [ column, row ] pairs
	#   see        AddObstacle, IsObstacle
	def Obstacles()
		return @aObstacles
	
	# Appends the cells of a list, in order, to the stored path.
	#
	#   panColRow   A list of [ column, row ] pairs.
	#   returns     nothing; the path grows
	#   note        the cells are not checked against the grid, so a cell outside it is kept and
	#               ignored when drawn; a value that is not a list raises an error
	#   see         AddPathNode, ClearPath, ShowPath
	#@ aka  -- PATH MANAGEMENT
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

		# Appends the cells of a list, in order, to the stored path.
		#
		#   panColRow   A list of [ column, row ] pairs.
		#   returns     nothing; the path grows
		#   note        the cells are not checked against the grid, so a cell outside it is kept and
		#               ignored when drawn; a value that is not a list raises an error
		#   see         AddPathNode, ClearPath, ShowPath
		def AddPathNodes(panColRow)
			This.AddPath(panColRow)

		# Appends the cells of a list, in order, to the stored path.
		#
		#   pancolRow   A list of [ column, row ] pairs.
		#   returns     nothing; the path grows
		#   note        the cells are not checked against the grid, so a cell outside it is kept and
		#               ignored when drawn; a value that is not a list raises an error
		#   see         AddPathNode, ClearPath, ShowPath
		def AddPathCells(pancolRow)
			This.AddPath(panColRow)

	# Appends one cell to the stored path; raises an error outside the grid.
	#
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    nothing; the path grows
	#   see        AddPath, ClearPath
	def AddPathNode(_nCol_, _nRow_)
		if NOT IsValidPosition(_nCol_, _nRow_)
			stzRaise("Invalid position for path node!")
		ok
		
		@aPath + [_nCol_, _nRow_]
		
		# Appends one cell to the stored path; raises an error outside the grid.
		#
		#   _nCol_     The column, counted from 1 at the left.
		#   _nRow_     The row, counted from 1 at the top.
		#   returns    nothing; the path grows
		#   see        AddPath, ClearPath
		def AddPathCell(_nCol_, _nRow_)
			This.AddPathNode(_nCol_, _nRow_)

	# Empties the stored path.
	#
	#   returns    nothing; the path is emptied
	#   see        AddPath, Path
	def ClearPath()
		@aPath = []
		
		# Empties the stored path.
		#
		#   returns    nothing; the path is emptied
		#   see        AddPath, Path
		def RemovePath()
			@aPath = []

	# Returns the stored path as a list of [ column, row ] pairs, in order.
	#
	#   returns    a list of [ column, row ] pairs
	#   see        AddPath, PathLength, ShortestPath
	def Path()
		return @aPath
		
	# Returns how many cells the stored path holds.
	#
	#   returns    a number
	#   see        Path, PathComplexity
	def PathLength()
		return len(@aPath)
		
		# Returns how many cells the stored path holds.
		#
		#   returns    a number
		#   see        Path, PathComplexity
		def PathLen()
			return len(@aPath)

	# Sets the character that draws the path; anything but one character raises an error.
	#
	#   _cChar_    The single character to draw with.
	#   returns    nothing; the character changes
	#   see        PathChar, ShowPath
	def SetPathChar(_cChar_)
		if isString(_cChar_) and IsChar(_cChar_)
			@cPathChar = _cChar_
		else
			stzRaise("Path character must be a single character!")
		ok
		
	# Returns the character that draws the path.
	#
	#   returns    a text of one character, ○ by default
	#   see        SetPathChar
	def PathChar()
		return @cPathChar
		
	# Sets the character that draws the current position; anything but one character raises an error.
	#
	#   _cChar_    The single character to draw with.
	#   returns    nothing; the character changes
	#   see        CurrentChar, ToString
	def SetCurrentChar(_cChar_)
		if isString(_cChar_) and IsChar(_cChar_)
			@cCurrentChar = _cChar_
		else
			stzRaise("Current position character must be a single character!")
		ok
		
	# Returns the character that draws the current position.
	#
	#   returns    a text of one character, x by default
	#   see        SetCurrentChar
	def CurrentChar()
		return @cCurrentChar
		
	# Sets the character that draws an empty cell; anything but one character raises an error.
	#
	#   _cChar_    The single character to draw with.
	#   returns    nothing; the character changes
	#   see        EmptyChar, ToString
	def SetEmptyChar(_cChar_)
		if isString(_cChar_) and IsChar(_cChar_)
			@cEmptyChar = _cChar_
		else
			stzRaise("Empty cell character must be a single character!")
		ok
		
	# Returns the character that draws an empty cell.
	#
	#   returns    a text of one character, a dot by default
	#   see        SetEmptyChar
	def EmptyChar()
		return @cEmptyChar

	# Sets the character that marks the neighbours; anything but one character raises an error.
	#
	#   _cChar_    The single character to draw with.
	#   returns    nothing; the character changes
	#   see        NeighborChar, ShowNeighbors
	#@ aka  THE FIFTH CHARACTER. The grid draws with five -- obstacle, path, current, empty and NEIGHBOUR -- and four of them had a setter and a reader. The neighbour character had neither, though ShowNeighbors() draws with it, so the one mark you cannot choose is the one marking what is next to you.
	def SetNeighborChar(_cChar_)
		if isString(_cChar_) and IsChar(_cChar_)
			@cNeighborChar = _cChar_
		else
			stzRaise("Neighbor character must be a single character!")
		ok

		# Sets the character that marks the neighbours; anything but one character raises an error.
		#
		#   _cChar_    The single character to draw with.
		#   returns    nothing; the character changes
		#   see        NeighborChar, ShowNeighbors
		def SetNeighbourChar(_cChar_)
			This.SetNeighborChar(_cChar_)

	# Returns the character that marks the neighbours.
	#
	#   returns    a text of one character, N by default
	#   see        SetNeighborChar
	def NeighborChar()
		return @cNeighborChar

		# Returns the character that marks the neighbours.
		#
		#   returns    a text of one character, N by default
		#   see        SetNeighborChar
		def NeighbourChar()
			return @cNeighborChar
			
	# Returns a shortest route from start to end around the obstacles, start first.
	#
	#   panStart   The start cell, as [ column, row ].
	#   panEnd     The end cell, as [ column, row ].
	#   returns    a list of [ column, row ] pairs, start first and end last; [ ] when no route exists
	#   note       moves are up, down, left and right; the route is stored as the path; a start or
	#              end outside the grid, or on an obstacle, raises an error
	#   see        ManhattanPath, Path, Regions
	#TODO // Add this method AddRandomPath()
	#@ aka  -- PATH FINDING ALGORITHMS
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

	# Returns and stores a route that walks along the row of the start, then along the column of the end.
	#
	#   panStart   The start cell, as [ column, row ].
	#   panEnd     The end cell, as [ column, row ].
	#   returns    a list of [ column, row ] pairs
	#   note       an end or start outside the grid raises an error; the current position is not
	#              moved
	#   warning    Raises R14 today, or R20, when an obstacle is on the way: the horizontal leg
	#              calls FindManhattanPathVerticalFirst, which exists nowhere, and the vertical leg
	#              calls ShortestPath with four arguments instead of two
	#   see        ManhattanPathVerticalFirst, ShortestPath
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

	# Returns and stores a route that walks along the column of the start, then along the row of the end.
	#
	#   panStart   The start cell, as [ column, row ].
	#   panEnd     The end cell, as [ column, row ].
	#   returns    a list of [ column, row ] pairs
	#   note       the positions are not checked against the grid; the current position is not moved
	#   warning    Raises R20 today when an obstacle is on the way: it calls ShortestPath with four
	#              arguments instead of two
	#   see        ManhattanPath, ShortestPath
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

	# Returns and stores a spiral that winds out from the start for up to eight steps per ring, turning right, down, left, up.
	#
	#   panStartNode   The cell to start from, as [ column, row ].
	#   _nRings_       How many rings to walk; the path has at most 8 steps per ring.
	#   returns        a list of [ column, row ] pairs
	#   note           it moves the current position to the start; it stops at the edge or when
	#                  every direction is blocked; a start outside the grid raises an error
	#   see            ZigZagPath, ManhattanPath
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

	# Returns and stores a snaking route from start to end, swinging sideways after every width cells.
	#
	#   panStart         The start cell, as [ column, row ].
	#   panEnd           The end cell, as [ column, row ].
	#   _nZigZagWidth_   How many cells to advance before each sideways swing.
	#   returns          a list of [ column, row ] pairs
	#   note             it moves the current position to the start; when start and end are the same
	#                    cell it answers that one pair, not a list of pairs; a position outside the
	#                    grid raises an error
	#   warning          Raises R20 today when it cannot sidestep an obstacle: the fallback calls
	#                    ShortestPath with four arguments instead of two
	#   see              SpiralPath, ManhattanPath
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
			_lZigZagRight_ = 1
			
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
			_lZigZagDown_ = 1
			
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


	# Prints the grid with a path drawn in, and returns the picture as text.
	#
	#   aPathToUse    The path to draw, as a list of [ column, row ] pairs; an empty text draws the
	#                 stored path.
	#   cCustomChar   The character to draw the path with; an empty text keeps the path character.
	#   returns       a text: the picture of the grid
	#   note          an empty text for the path draws the stored path, and an empty text for the
	#                 character keeps the path character; the stored path and character are restored
	#                 after
	#   see           ShowNodes, ToString, SetPathChar
	def ShowPath(aPathToUse, cCustomChar)

		# Store the original path character
		_cOriginalPathChar_ = @cPathChar

		# Set custom path character if provided
		if cCustomChar != ""
			@cPathChar = cCustomChar
		ok

		# Store the original path
		_aOriginalPath_ = @aPath

		# Use the provided path if given
		if aPathToUse != ""
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


	# Prints the grid with one cell marked by the given character.
	#
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   _cChar_    The single character to draw with.
	#   returns    nothing; the grid is printed
	#   note       the picture is not returned, unlike ShowNodes
	#   see        ShowNodes, ShowPath
	def ShowNode(_nCol_, _nRow_, _cChar_)
		This.ShowNodes([ [_nCol_, _nRow_] ], _cChar_)

		# Prints the grid with one cell marked by the given character.
		#
		#   _nCol_     The column, counted from 1 at the left.
		#   _nRow_     The row, counted from 1 at the top.
		#   _cChar_    The single character to draw with.
		#   returns    nothing; the grid is printed
		#   note       the picture is not returned, unlike ShowNodes
		#   see        ShowNodes, ShowPath
		def ShowCell(_nCol_, _nRow_, _cChar_)
			This.ShowNode(_nCol_, _nRow_, _cChar_)

	# Prints the grid with the given cells marked by a character, and returns the picture as text.
	#
	#   aNodes     The cells to mark, as a list of [ column, row ] pairs.
	#   _cChar_    The single character to draw with.
	#   returns    a text: the picture of the grid
	#   note       cells outside the grid are ignored; the stored path is untouched
	#   see        ShowNode, ShowPath
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
		
		# Draw with the specified character.
		#
		# ShowPath RETURNS the picture it drew as well as printing it; this threw
		# that away, so nothing could ask what had been drawn -- which is why the
		# neighbour mark had no way to be checked. The path is restored before
		# returning, so the result is held first.
		_cDrawn_ = This.ShowPath(@aPath, _cChar_)
		
		# Restore original path
		@aPath = _aOldPath_
		return _cDrawn_

		# Prints the grid with the given cells marked by a character.
		#
		#   aNodes     The cells to mark, as a list of [ column, row ] pairs.
		#   _cChar_    The single character to draw with.
		#   returns    nothing; the grid is printed
		#   note       the picture is not returned, unlike ShowNodes
		#   see        ShowNodes
		def ShowCells(aNodes, _cChar_)
			This.ShowNodes(aNodes, _cChar_)


	# Prints the grid with each region cut by the obstacles drawn with its own number, 1, 2, 3 and so on.
	#
	#   returns    nothing; the grid is printed
	#   see        Regions, AreConnected
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
	
	# Prints a picture given as rows of one-character items, inside the frame of the grid.
	#
	#   aCustomGrid   The picture to draw: a list of rows, each a list of one-character items, as
	#                 many rows and columns as the grid has.
	#   returns       nothing; the picture is printed
	#   note          the rows and columns must be as many as the grid has
	#   see           ShowNodes, ToString
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

			_cResult_ += char(10)
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

		_cResult_ += "╮" + char(10)

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

			_cResult_ += "│" + char(10)
		next

		# Add bottom border with rounded corners

		_cResult_ += "  ╰"

		for x = 1 to @nCols
			_cResult_ += "──"
		next

		_cResult_ += "─╯" + char(10)
    
		? _cResult_

	# Returns the Manhattan distance between two cells, the estimate path finding uses.
	#
	#   panStart   The start cell, as [ column, row ].
	#   panEnd     The end cell, as [ column, row ].
	#   returns    a number
	#   see        DistanceTo, ShortestPath
	#@ aka  -- HELPER FUNCTIONS FOR PATHFINDING
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

	# Returns the up to four cells next to a cell, to its left, below, right and above in that order, without the obstacles.
	#
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    a list of [ column, row ] pairs
	#   note       cells outside the grid and obstacles are left out
	#   see        Neighbors, ShortestPath
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

	# TRUE if the cell is one of the [ column, row ] pairs of a list.
	#
	#   aList      A list of [ column, row ] pairs.
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    TRUE or FALSE
	#   see        WalkableNeighbors, Fill
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
				return 1
			ok
		next
		return 0

	# Returns the position, in the list of open cells, of the cell with the lowest score.
	#
	#   _aOpenSet_   The cells still to examine, as a list of [ column, row ] pairs.
	#   _aFScore_    The scores, as a list of [ [ column, row ], score ] items.
	#   returns      a number: a position in the open list
	#   note         the first one wins a tie
	#   see          GetScoreAt, ShortestPath
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

	# Returns the score stored for a cell in a score list; 999999 when the cell has none.
	#
	#   aScores    A list of [ [ column, row ], score ] items.
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   returns    a number
	#   see        SetScoreAt, LowestFScore
	def GetScoreAt(aScores, _nCol_, _nRow_)

		_nLen_ = len(aScores)

		for i = 1 to _nLen_
			if aScores[i][1][1] = _nCol_ and aScores[i][1][2] = _nRow_
				return aScores[i][2]
			ok
		next
		return 999999  # Default to infinity

	# Stores the score of a cell in a score list, in place, adding the cell when absent, and returns the list.
	#
	#   aScores    A list of [ [ column, row ], score ] items.
	#   _nCol_     The column, counted from 1 at the left.
	#   _nRow_     The row, counted from 1 at the top.
	#   _nScore_   The score to store.
	#   returns    the score list, which was changed in place
	#   note       the list passed in is the one changed, so the result may be ignored; the cell is
	#              added when it has no score
	#   see        GetScoreAt
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

	# Records in a predecessor map which cell a cell was reached from, in place, and returns the map.
	#
	#   _aCameFrom_   The predecessor map, as a list of [ [ column, row ], [ column, row ] ] items.
	#   _nCol_        The column, counted from 1 at the left.
	#   _nRow_        The row, counted from 1 at the top.
	#   nFromCol      The column of the cell it was reached from.
	#   nFromRow      The row of the cell it was reached from.
	#   returns       the predecessor map, which was changed in place
	#   note          the map passed in is the one changed, so the result may be ignored; an
	#                 existing entry is replaced
	#   see           GetCameFrom, ReconstructPath
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

	# Returns the cell a cell was reached from, in a predecessor map; an empty text when it has none.
	#
	#   _aCameFrom_   The predecessor map, as a list of [ [ column, row ], [ column, row ] ] items.
	#   _nCol_        The column, counted from 1 at the left.
	#   _nRow_        The row, counted from 1 at the top.
	#   returns       a pair [ column, row ], or an empty text
	#   see           SetCameFrom, ReconstructPath
	def GetCameFrom(_aCameFrom_, _nCol_, _nRow_)

		_nLen_ = len(_aCameFrom_)

		for i = 1 to _nLen_
			if _aCameFrom_[i][1][1] = _nCol_ and _aCameFrom_[i][1][2] = _nRow_
				return _aCameFrom_[i][2]
			ok
		next
		return ""

	# Returns the route that ends on a cell by following a predecessor map back, start first.
	#
	#   _aCameFrom_   The predecessor map, as a list of [ [ column, row ], [ column, row ] ] items.
	#   _nEndCol_     The column of the end cell.
	#   _nEndRow_     The row of the end cell.
	#   returns       a list of [ column, row ] pairs, from the start to the end cell
	#   note          an empty map answers the end cell alone
	#   see           SetCameFrom, ShortestPath
	def ReconstructPath(_aCameFrom_, _nEndCol_, _nEndRow_)

		_aPath_ = []
		_nCurrentCol_ = _nEndCol_
		_nCurrentRow_ = _nEndRow_

		# Add end position

		_aPath_ + [_nCurrentCol_, _nCurrentRow_]

		# Trace back the path

		while 1

			_aPrev_ = This.GetCameFrom(_aCameFrom_, _nCurrentCol_, _nCurrentRow_)

 			if _aPrev_ = ""
				exit
			ok

			_nCurrentCol_ = _aPrev_[1]
			_nCurrentRow_ = _aPrev_[2]

			# Gathered end-first, turned round below
			_aPath_ + [_nCurrentCol_, _nCurrentRow_]
		end

		# Ring's insert(list, 1, item) puts the item AFTER item 1, so
		# the route is gathered from the end and reversed here instead
		_aResult_ = []
		_nLenPath_ = len(_aPath_)
		for i = _nLenPath_ to 1 step -1
			_aResult_ + _aPath_[i]
		next

		return _aResult_

	# Returns how many turns the stored path takes, counted as changes of direction after the first step.
	#
	#   returns    a number; 0 for a path of two cells or fewer
	#   see        PathEfficiency, PathLength
	#@ aka  -- PATH COMPLEXITY ANALYSIS
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
	
	# Returns, as a percentage capped at 100, the straight Manhattan distance of the stored path over the steps it takes.
	#
	#   returns    a number from 0 to 100; 100 for a path of fewer than two cells
	#   note       a snaking path scores low: 4 straight cells over 12 steps give 33.33
	#   see        PathComplexity, PathLength
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
	
	# Returns every cell reachable from a cell by up, down, left and right steps that avoid the obstacles, in the order of the search.
	#
	#   _nStartCol_   The column to start from.
	#   _nStartRow_   The row to start from.
	#   returns       a list of [ column, row ] pairs
	#   note          the start cell is always in the answer, even when it is an obstacle, and the
	#                 search then spreads from it; FloodFill gives the same list
	#   see           Regions, AreConnected
	#@ aka  -- REGION MANAGEMENT
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

	# TRUE if two cells can reach each other by up, down, left and right steps that avoid the obstacles.
	#
	#   panNode1   A cell, as [ column, row ].
	#   panNode2   A cell, as [ column, row ].
	#   returns    TRUE or FALSE
	#   note       an obstacle, or a cell outside the grid, answers FALSE; a value that is not a
	#              pair of numbers raises an error
	#   see        Fill, Regions
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
			return 0
		ok
		
		# Check if either position is an obstacle
		if This.IsObstacle(_nCol1_, _nRow1_) or This.IsObstacle(_nCol2_, _nRow2_)
			return 0
		ok
		
		# Do flood fill from first position
		_aReachable_ = This.FloodFill(_nCol1_, _nRow1_)
		
		# Check if second position is in the reachable list
		return This.IsInList(_aReachable_, _nCol2_, _nRow2_)

	# Returns the groups of cells that the obstacles cut the grid into, each group as a list of [ column, row ] pairs.
	#
	#   returns    a list of regions, each a list of pairs
	#   note       regions are found by scanning row by row from the top left; the obstacles belong
	#              to none
	#   see        Fill, ShowRegions, AreConnected
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

	# Replaces the obstacles by random ones, each cell having the given percentage of chance, never on the current position.
	#
	#   _nObstacleDensity_   The chance of an obstacle in each cell, as a percentage from 0 to 90; a
	#                        larger number counts as 90.
	#   returns              nothing; the obstacles change
	#   note                 a density below 0 counts as 0 and one above 90 as 90, so the grid is
	#                        never full; the result differs from call to call
	#   see                  MazeWithPath, ClearObstacles
	#@ aka  -- RANDOM MAZE GENERATION
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
				if StzEngineRandomInt(0, 100) < _nObstacleDensity_
					This.AddObstacle(x, y)
				ok
			next
		next

		# Replaces the obstacles by random ones, each cell having a 30 percent chance, never on the current position.
		#
		#   returns    nothing; the obstacles change
		#   note       the result differs from call to call
		#   see        RandomMaze, MazeWithPath
		def Maze()
			This.RandomMaze(30)
	
	# Clears the obstacles, moves to the start, stores a route to the end, and scatters obstacles at random on the other cells.
	#
	#   panStart   The start cell, as [ column, row ].
	#   panEnd     The end cell, as [ column, row ].
	#   returns    nothing; the obstacles and the path change
	#   note       each cell off the route has a 30 percent chance of an obstacle, so the route
	#              stays free; the current position ends on the start; the result differs from call
	#              to call; the stored route runs from the start to the end
	#   see        RandomMaze, ShortestPath
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
				if StzEngineRandomInt(0, 100) < 30
					This.AddObstacle(x, y)
				ok
			next
		next
	
	# Prints the grid as text: the column numbers, a frame, one line per row, with obstacles, path and the current cell drawn.
	#
	#   returns    nothing; the grid is printed
	#   see        ToString, Legend, ShowPath
	#@ aka  -- VISUALIZING THE GRID
	def Show()
		? This.ToString()


	# Returns the grid as text: the column numbers, a frame, one line per row, with obstacles, path and the current cell drawn.
	#
	#   returns    a text of several lines
	#   note       a > marks the current row and a v the current column; the frame uses box-drawing
	#              characters; the current cell is drawn over the path, the path over the obstacles
	#   see        Show, Legend
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

			_cResult_ += char(10)
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

		_cResult_ += "╮" + char(10)

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

			_cResult_ += "│" + char(10)
		next

		# Add bottom border with rounded corners

		_cResult_ += "  ╰"

		for x = 1 to @nCols
			_cResult_ += "──"
		next

		_cResult_ += "─╯" + char(10)

		return _cResult_

	# Returns one line naming the grid size and the characters used for the current cell, the obstacles and the path.
	#
	#   returns    a text on one line, as Grid: 5x4 followed by the characters, separated by
	#              vertical bars
	#   see        ToString, SetCurrentChar
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

	# Records the value, given as :With = value, that every cell of Content will hold; any other argument raises an error.
	#
	#   pNamedParam   The named parameter :With = value, the value every cell takes.
	#   returns       nothing; the fill value is recorded
	#   note          ReplaceAllQ chains
	#   see           Content
	#@ aka  ReplaceAll(:With = val): record val as the fill value. The subsequent Content() call materialises a @nRows x @nCols list of lists filled with val. Used by stzObject.RepeatXT to spell 'a grid of N x M filled with this value' as a fluent chain:
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

	# Returns the grid as a list of rows filled with the value given to ReplaceAll; an empty list before that.
	#
	#   returns    a list of rows, each a list of values
	#   note       rows come first: a grid of 3 columns and 2 rows gives 2 lists of 3 values
	#   see        ReplaceAll, Size
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
