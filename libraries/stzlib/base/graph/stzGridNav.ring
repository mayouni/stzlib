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

# Is meant to hold a grid of rows and columns with a current cell that moves, but no object of it can be built today.
#
# The class wraps the engine's grid navigation module: a position, moves that refuse to leave the
# grid, a neighbour count, a validity test and a Manhattan distance. Today new stzGridNav always
# raises Can't create stzGridNav! Engine returned error, because the wrapper hands the engine a grid
# name that the engine does not take, so every row and column is read one argument too late; the
# direction constants of the class also disagree with the engine's. The engine functions themselves
# work when called directly with their own arguments, as StzEngineGridCreate(3, 4).
#
#   receiver   nOk = StzEngineGridCreate(3, 4)
#   example    ? nOk
#              #--> 0
#              try
#              o1 = new stzGridNav("g", 3, 4)
#              catch
#              ? "raised"
#              #--> raised
#              done
#   see        stzObject, stzGraph
class stzGridNav from stzObject

	@cName = ""

	  #--------------#
	 #     INIT     #
	#--------------#

	# Raises error Can't create stzGridNav! Engine returned error today instead of building a named grid.
	#
	#   cName      the name of the grid
	#   nRows      the number of rows, a positive number
	#   nCols      the number of columns, a positive number
	#   returns    nothing; it always raises
	#   note       the engine keeps one global grid with no name; an empty or non-text name, or a
	#              size below 1, raise their own parameter errors first
	#   warning    new stzGridNav("g", 3, 4) and new stzGridNav("g5", 5, 5) both raise, because the
	#              engine function StzEngineGridCreate takes (rows, cols) and is handed (name, rows,
	#              cols): the text is read as 0 rows and the call returns -1; StzEngineGridCreate(3,
	#              4) called directly succeeds
	#   see        SetPosition, StzGridNavQ
	def init(cName, nRows, nCols)

		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Can't create stzGridNav! cName must be a non-empty string.")
			ok
			if NOT isNumber(nRows) or nRows < 1
				StzRaise("Incorrect param! nRows must be a positive number.")
			ok
			if NOT isNumber(nCols) or nCols < 1
				StzRaise("Incorrect param! nCols must be a positive number.")
			ok
		ok

		@cName = cName
		_nResult_ = StzEngineGridCreate(cName, nRows, nCols)

		if _nResult_ < 0
			StzRaise("Can't create stzGridNav! Engine returned error.")
		ok

	  #-------------------------------#
	 #     POSITION                  #
	#-------------------------------#

	# Moves the position to a row and a column, from 0, once a grid exists; none can be built today.
	#
	#   nRow       the row, from 0
	#   nCol       the column, from 0
	#   returns    nothing; the position changes. SetPositionQ returns the object
	#   note       the engine does not check the bounds, so the intended Out of bounds error cannot
	#              fire
	#   warning    unreachable today because init raises; on an object made without init,
	#              SetPosition(2, 3) left the position at 0,2, since the grid name is passed as the
	#              first engine argument and the engine takes none
	#   see        CurrentRow, MoveDirection
	def SetPosition(nRow, nCol)
		if CheckingParams()
			if NOT isNumber(nRow) or NOT isNumber(nCol)
				StzRaise("Incorrect params! nRow and nCol must be numbers.")
			ok
		ok

		_nResult_ = StzEngineGridSetPos(@cName, nRow, nCol)
		if _nResult_ < 0
			StzRaise("Can't set position! Out of bounds.")
		ok

		def SetPositionQ(nRow, nCol)
			This.SetPosition(nRow, nCol)
			return This

	# Returns the row of the current position, once a grid exists; none can be built today.
	#
	#   returns    a number, from 0
	#   note       Row is the same call
	#   warning    unreachable today because init raises
	#   see        CurrentCol, SetPosition
	def CurrentRow()
		return StzEngineGridGetRow(@cName)

		def Row()
			return This.CurrentRow()

	# Returns the column of the current position, once a grid exists; none can be built today.
	#
	#   returns    a number, from 0
	#   note       Col is the same call
	#   warning    unreachable today because init raises
	#   see        CurrentRow, SetPosition
	def CurrentCol()
		return StzEngineGridGetCol(@cName)

		def Col()
			return This.CurrentCol()

	  #-------------------------------#
	 #     MOVEMENT                  #
	#-------------------------------#

	# Moves the position one cell in a direction, once a grid exists; none can be built today.
	#
	#   nDirection   0 for up, 1 for down, 2 for left, 3 for right
	#   returns      nothing; the position changes. MoveDirectionQ returns the object
	#   note         a move off the grid is meant to raise Can't move! Would go out of bounds
	#   warning      unreachable today because init raises; the engine also reads 0 up, 1 right, 2
	#                down, 3 left, so down, left and right would be swapped
	#   see          MoveUp, MoveDown, MoveLeft, MoveRight
	def MoveDirection(nDirection)
		if CheckingParams()
			if NOT isNumber(nDirection)
				StzRaise("Incorrect param! nDirection must be 0-3 (up/down/left/right).")
			ok
		ok

		_nResult_ = StzEngineGridMove(@cName, nDirection)
		if _nResult_ < 0
			StzRaise("Can't move! Would go out of bounds.")
		ok

		def MoveDirectionQ(nDirection)
			This.MoveDirection(nDirection)
			return This

	# Moves the position one row up, once a grid exists; none can be built today.
	#
	#   returns    nothing; the position changes. MoveUpQ returns the object
	#   note       it calls MoveDirection with the class constant for up
	#   warning    unreachable today because init raises
	#   see        MoveDown, MoveDirection
	def MoveUp()
		This.MoveDirection($STZ_GRID_UP)

		def MoveUpQ()
			This.MoveUp()
			return This

	# Moves the position one row down, once a grid exists; none can be built today.
	#
	#   returns    nothing; the position changes. MoveDownQ returns the object
	#   note       it calls MoveDirection with the class constant for down
	#   warning    unreachable today because init raises; it sends the class constant 1, which the
	#              engine reads as right
	#   see        MoveUp, MoveDirection
	def MoveDown()
		This.MoveDirection($STZ_GRID_DOWN)

		def MoveDownQ()
			This.MoveDown()
			return This

	# Moves the position one column left, once a grid exists; none can be built today.
	#
	#   returns    nothing; the position changes. MoveLeftQ returns the object
	#   note       it calls MoveDirection with the class constant for left
	#   warning    unreachable today because init raises; it sends the class constant 2, which the
	#              engine reads as down
	#   see        MoveRight, MoveDirection
	def MoveLeft()
		This.MoveDirection($STZ_GRID_LEFT)

		def MoveLeftQ()
			This.MoveLeft()
			return This

	# Moves the position one column right, once a grid exists; none can be built today.
	#
	#   returns    nothing; the position changes. MoveRightQ returns the object
	#   note       it calls MoveDirection with the class constant for right
	#   warning    unreachable today because init raises; it sends the class constant 3, which the
	#              engine reads as left
	#   see        MoveLeft, MoveDirection
	def MoveRight()
		This.MoveDirection($STZ_GRID_RIGHT)

		def MoveRightQ()
			This.MoveRight()
			return This

	  #-------------------------------#
	 #     QUERIES                   #
	#-------------------------------#

	# Returns how many cells touch the current one, up, down, left and right, inside the grid; none can be built today.
	#
	#   returns    a number from 2 in a corner to 4 inside; NumberOfNeighbors is the same call
	#   warning    unreachable today because init raises
	#   see        IsValidPosition, DistanceTo
	def NeighborCount()
		return StzEngineGridNeighborCount(@cName)

		def NumberOfNeighbors()
			return This.NeighborCount()

	# TRUE if a row and a column lie inside the grid, once a grid exists; none can be built today.
	#
	#   nRow       the row, from 0
	#   nCol       the column, from 0
	#   returns    TRUE or FALSE, as 1 or 0
	#   warning    unreachable today because init raises; the grid name is passed first, so the
	#              engine would read the column as the row
	#   see        SetPosition, DistanceTo
	def IsValidPosition(nRow, nCol)
		_nResult_ = StzEngineGridIsValid(@cName, nRow, nCol)
		if _nResult_ = 1
			return 1
		else
			return 0
		ok

	# Returns the Manhattan distance between the current cell and another, once a grid exists; none can be built today.
	#
	#   nRow       the row of the other cell
	#   nCol       the column of the other cell
	#   returns    a number, the rows apart plus the columns apart
	#   note       the engine function called directly with four numbers answers 6 for (3, 3) and
	#              (0, 0)
	#   warning    unreachable today because init raises; it also sends 3 arguments to an engine
	#              function that takes 4 (both cells), so the answer would not be the distance from
	#              the current cell
	#   see        IsValidPosition, NeighborCount
	def DistanceTo(nRow, nCol)
		return StzEngineGridDistance(@cName, nRow, nCol)

	  #-------------------------------#
	 #     INFO AND RESET            #
	#-------------------------------#

	# Returns the name the grid was given.
	#
	#   returns    the name as text
	#   warning    unreachable today because init raises
	#   see        init
	def Name()
		return @cName

	# Puts the position back to row 0, column 0, and also clears the grid size, once a grid exists.
	#
	#   returns    nothing; the position changes. ResetPositionQ returns the object
	#   note       the name says position only
	#   warning    unreachable today because init raises; the engine reset sets the grid size to 0,
	#              so no cell is valid afterwards
	#   see        SetPosition, CurrentRow
	def ResetPosition()
		StzEngineGridReset(@cName)

		def ResetPositionQ()
			This.ResetPosition()
			return This
