#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZGRIDNAV                 #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Grid navigation class backed by the         #
#                  Softanza Engine (stz_gridnav module).        #
#                  2D grid with position, movement, distance.   #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

# Direction constants
$STZ_GRID_UP    = 0
$STZ_GRID_DOWN  = 1
$STZ_GRID_LEFT  = 2
$STZ_GRID_RIGHT = 3

func StzGridNavQ(cName, nRows, nCols)
	return new stzGridNav(cName, nRows, nCols)

func IsStzGridNav(pObj)
	if isObject(pObj) and classname(pObj) = "stzgridnav"
		return 1
	else
		return 0
	ok

	func @IsStzGridNav(pObj)
		return IsStzGridNav(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

# Holds a named grid of rows and columns with a current cell that moves, and never leaves the grid.
#
# The class wraps the engine's grid navigation module: a position, moves that refuse to leave the
# grid, a neighbour count, a validity test and a Manhattan distance. Rows and columns are counted
# from 0, so a 3 by 4 grid has rows 0 to 2 and columns 0 to 3, and a new grid starts on row 0,
# column 0. The engine holds ONE grid at a time, so the object keeps its own size and position and
# hands them to the engine again before every call: several objects can live side by side, and a
# copy of an object moves on its own. The directions of the class are 0 up, 1 down, 2 left, 3 right
# (the engine reads 0 up, 1 right, 2 down, 3 left, and the class converts).
#
#   receiver   o1 = new stzGridNav("g", 3, 4)
#   example    ? o1.CurrentRow()
#              #--> 0
#              o1.MoveDown()
#              o1.MoveRight()
#              ? [ o1.CurrentRow(), o1.CurrentCol() ]
#              #--> [ 1, 1 ]
#              ? o1.NeighborCount()
#              #--> 4
#              ? o1.DistanceTo(2, 3)
#              #--> 3
#   see        stzObject, stzGraph
class stzGridNav from stzObject

	@cName = ""
	@nRows = 0
	@nCols = 0
	@nRow  = 0
	@nCol  = 0

	  #--------------#
	 #     INIT     #
	#--------------#

	# Builds a named grid of rows and columns with the current cell on row 0, column 0.
	#
	#   cName      the name of the grid, a non-empty text
	#   nRows      the number of rows, a whole number from 1 to 2147483647
	#   nCols      the number of columns, a whole number from 1 to 2147483647
	#   returns    nothing; the object is the grid
	#   note       the engine keeps one grid with no name, so the name lives in the object; an empty
	#              or non-text name, and a size that is not a whole number from 1 to 2147483647,
	#              raise their own parameter errors before the engine is called
	#   see        SetPosition, StzGridNavQ
	def init(cName, nRows, nCols)

		if NOT isString(cName)
			StzRaise("Can't create stzGridNav! cName must be a non-empty string.")
		ok
		if cName = ""
			StzRaise("Can't create stzGridNav! cName must be a non-empty string.")
		ok
		if NOT This._GridIsSize(nRows)
			StzRaise("Incorrect param! nRows must be a positive whole number, at most 2147483647.")
		ok
		if NOT This._GridIsSize(nCols)
			StzRaise("Incorrect param! nCols must be a positive whole number, at most 2147483647.")
		ok

		@cName = cName
		@nRows = nRows
		@nCols = nCols
		@nRow  = 0
		@nCol  = 0

		_nResult_ = StzEngineGridCreate(nRows, nCols)

		if _nResult_ < 0
			StzRaise("Can't create stzGridNav! Engine returned error.")
		ok

	  #-------------------------------#
	 #     POSITION                  #
	#-------------------------------#

	# Moves the current cell to a row and a column inside the grid.
	#
	#   nRow       the row, from 0
	#   nCol       the column, from 0
	#   returns    nothing; the position changes. SetPositionQ returns the object
	#   note       a cell outside the grid raises Can't set position! Out of bounds, and the position
	#              stays where it was; the bounds are checked by the class, since the engine does not
	def SetPosition(nRow, nCol)
		if NOT isNumber(nRow) or NOT isNumber(nCol)
			StzRaise("Incorrect params! nRow and nCol must be numbers.")
		ok
		if nRow != floor(nRow) or nCol != floor(nCol)
			StzRaise("Incorrect params! nRow and nCol must be whole numbers.")
		ok

		if NOT This.IsValidPosition(nRow, nCol)
			StzRaise("Can't set position! Out of bounds.")
		ok

		@nRow = nRow
		@nCol = nCol

		def SetPositionQ(nRow, nCol)
			This.SetPosition(nRow, nCol)
			return This

	# Returns the row of the current cell, counted from 0.
	#
	#   returns    a number from 0 to the number of rows less one
	#   note       Row is the same call
	#   see        CurrentCol, SetPosition
	def CurrentRow()
		This._GridSync()
		return StzEngineGridGetRow()

		def Row()
			return This.CurrentRow()

	# Returns the column of the current cell, counted from 0.
	#
	#   returns    a number from 0 to the number of columns less one
	#   note       Col is the same call
	#   see        CurrentRow, SetPosition
	def CurrentCol()
		This._GridSync()
		return StzEngineGridGetCol()

		def Col()
			return This.CurrentCol()

	  #-------------------------------#
	 #     MOVEMENT                  #
	#-------------------------------#

	# Moves the current cell one step in a direction.
	#
	#   nDirection   0 for up, 1 for down, 2 for left, 3 for right
	#   returns      nothing; the position changes. MoveDirectionQ returns the object
	#   note         a step off the grid raises Can't move! Would go out of bounds, and the position
	#                stays where it was; any other direction raises its own parameter error
	#   see          MoveUp, MoveDown, MoveLeft, MoveRight
	def MoveDirection(nDirection)
		if NOT isNumber(nDirection)
			StzRaise("Incorrect param! nDirection must be 0-3 (up/down/left/right).")
		ok
		if NOT This._GridIsInt(nDirection) or nDirection < 0 or nDirection > 3
			StzRaise("Incorrect param! nDirection must be 0-3 (up/down/left/right).")
		ok

		# the class order 0 up, 1 down, 2 left, 3 right, in the engine order 0 up, 1 right, 2 down, 3 left
		_aEngineDir_ = [ 0, 2, 3, 1 ]

		This._GridSync()
		_nResult_ = StzEngineGridMove(_aEngineDir_[nDirection + 1])
		if _nResult_ < 0
			StzRaise("Can't move! Would go out of bounds.")
		ok

		@nRow = StzEngineGridGetRow()
		@nCol = StzEngineGridGetCol()

		def MoveDirectionQ(nDirection)
			This.MoveDirection(nDirection)
			return This

	# Moves the current cell one row up.
	#
	#   returns    nothing; the position changes. MoveUpQ returns the object
	#   note       it raises Can't move! Would go out of bounds on row 0
	#   see        MoveDown, MoveDirection
	def MoveUp()
		_nDir_ = 0
		This.MoveDirection(_nDir_)

		def MoveUpQ()
			This.MoveUp()
			return This

	# Moves the current cell one row down.
	#
	#   returns    nothing; the position changes. MoveDownQ returns the object
	#   note       it raises Can't move! Would go out of bounds on the last row
	#   see        MoveUp, MoveDirection
	def MoveDown()
		_nDir_ = 1
		This.MoveDirection(_nDir_)

		def MoveDownQ()
			This.MoveDown()
			return This

	# Moves the current cell one column left.
	#
	#   returns    nothing; the position changes. MoveLeftQ returns the object
	#   note       it raises Can't move! Would go out of bounds on column 0
	#   see        MoveRight, MoveDirection
	def MoveLeft()
		_nDir_ = 2
		This.MoveDirection(_nDir_)

		def MoveLeftQ()
			This.MoveLeft()
			return This

	# Moves the current cell one column right.
	#
	#   returns    nothing; the position changes. MoveRightQ returns the object
	#   note       it raises Can't move! Would go out of bounds on the last column
	#   see        MoveLeft, MoveDirection
	def MoveRight()
		_nDir_ = 3
		This.MoveDirection(_nDir_)

		def MoveRightQ()
			This.MoveRight()
			return This

	  #-------------------------------#
	 #     QUERIES                   #
	#-------------------------------#

	# Returns how many cells touch the current one, up, down, left and right, inside the grid.
	#
	#   returns    a number: 2 in a corner, 3 on an edge, 4 inside; a 1 by 1 grid has 0 and a single
	#              row or column has at most 2. NumberOfNeighbors is the same call
	#   see        IsValidPosition, DistanceTo
	def NeighborCount()
		This._GridSync()
		return StzEngineGridNeighborCount()

		def NumberOfNeighbors()
			return This.NeighborCount()

	# Tells whether a row and a column name a cell inside the grid.
	#
	#   nRow       the row, from 0
	#   nCol       the column, from 0
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a number that is not whole, or too large for the engine, names no cell and answers
	#              0; a value that is not a number raises its own parameter error
	#   see        SetPosition, DistanceTo
	def IsValidPosition(nRow, nCol)
		if NOT isNumber(nRow) or NOT isNumber(nCol)
			StzRaise("Incorrect params! nRow and nCol must be numbers.")
		ok
		if NOT This._GridIsInt(nRow) or NOT This._GridIsInt(nCol)
			return 0
		ok

		This._GridSync()
		_nResult_ = StzEngineGridIsValid(nRow, nCol)
		if _nResult_ = 1
			return 1
		else
			return 0
		ok

	# Returns the Manhattan distance from the current cell to another cell of the grid.
	#
	#   nRow       the row of the other cell, from 0
	#   nCol       the column of the other cell, from 0
	#   returns    a number, the rows apart plus the columns apart; 0 for the current cell itself
	#   note       a target outside the grid raises Can't measure! The target cell is outside the grid
	#   see        IsValidPosition, NeighborCount
	def DistanceTo(nRow, nCol)
		if NOT isNumber(nRow) or NOT isNumber(nCol)
			StzRaise("Incorrect params! nRow and nCol must be numbers.")
		ok
		if NOT This.IsValidPosition(nRow, nCol)
			StzRaise("Can't measure! The target cell is outside the grid.")
		ok

		This._GridSync()
		return StzEngineGridDistance(StzEngineGridGetRow(), StzEngineGridGetCol(), nRow, nCol)

	  #-------------------------------#
	 #     INFO AND RESET            #
	#-------------------------------#

	# Returns the label the grid was built with.
	#
	#   returns    the label as text
	#   see        init
	def Name()
		return @cName

	# Puts the current cell back on row 0, column 0 and keeps the grid.
	#
	#   returns    nothing; the position changes. ResetPositionQ returns the object
	#   note       the grid keeps its size, so every cell stays valid afterwards
	#   see        SetPosition, CurrentRow
	def ResetPosition()
		@nRow = 0
		@nCol = 0

		def ResetPositionQ()
			This.ResetPosition()
			return This

	  #-------------------------------#
	 #     PRIVATE                   #
	#-------------------------------#

	# Hands the engine this object's grid and position, because the engine holds one grid for all.
	def _GridSync()
		_nResult_ = StzEngineGridCreate(@nRows, @nCols)
		if _nResult_ < 0
			StzRaise("Can't use stzGridNav! Engine returned error.")
		ok
		StzEngineGridSetPos(@nRow, @nCol)

	# Tells whether a value is a whole number the engine can read as a 32-bit integer.
	def _GridIsInt(nValue)
		if NOT isNumber(nValue)
			return 0
		ok
		if nValue != floor(nValue)
			return 0
		ok
		if nValue < -2147483648 or nValue > 2147483647
			return 0
		ok
		return 1

	# Tells whether a value is a whole number from 1 to 2147483647.
	def _GridIsSize(nValue)
		if NOT This._GridIsInt(nValue)
			return 0
		ok
		if nValue < 1
			return 0
		ok
		return 1
