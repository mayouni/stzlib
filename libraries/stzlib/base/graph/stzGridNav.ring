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

class stzGridNav from stzObject

	@cName = ""

	  #--------------#
	 #     INIT     #
	#--------------#

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
		nResult = StzEngineGridCreate(cName, nRows, nCols)

		if nResult < 0
			StzRaise("Can't create stzGridNav! Engine returned error.")
		ok

	  #-------------------------------#
	 #     POSITION                  #
	#-------------------------------#

	def SetPosition(nRow, nCol)
		if CheckingParams()
			if NOT isNumber(nRow) or NOT isNumber(nCol)
				StzRaise("Incorrect params! nRow and nCol must be numbers.")
			ok
		ok

		nResult = StzEngineGridSetPos(@cName, nRow, nCol)
		if nResult < 0
			StzRaise("Can't set position! Out of bounds.")
		ok

		def SetPositionQ(nRow, nCol)
			This.SetPosition(nRow, nCol)
			return This

	def CurrentRow()
		return StzEngineGridGetRow(@cName)

		def Row()
			return This.CurrentRow()

	def CurrentCol()
		return StzEngineGridGetCol(@cName)

		def Col()
			return This.CurrentCol()

	  #-------------------------------#
	 #     MOVEMENT                  #
	#-------------------------------#

	def MoveDirection(nDirection)
		if CheckingParams()
			if NOT isNumber(nDirection)
				StzRaise("Incorrect param! nDirection must be 0-3 (up/down/left/right).")
			ok
		ok

		nResult = StzEngineGridMove(@cName, nDirection)
		if nResult < 0
			StzRaise("Can't move! Would go out of bounds.")
		ok

		def MoveDirectionQ(nDirection)
			This.MoveDirection(nDirection)
			return This

	def MoveUp()
		This.MoveDirection($STZ_GRID_UP)

		def MoveUpQ()
			This.MoveUp()
			return This

	def MoveDown()
		This.MoveDirection($STZ_GRID_DOWN)

		def MoveDownQ()
			This.MoveDown()
			return This

	def MoveLeft()
		This.MoveDirection($STZ_GRID_LEFT)

		def MoveLeftQ()
			This.MoveLeft()
			return This

	def MoveRight()
		This.MoveDirection($STZ_GRID_RIGHT)

		def MoveRightQ()
			This.MoveRight()
			return This

	  #-------------------------------#
	 #     QUERIES                   #
	#-------------------------------#

	def NeighborCount()
		return StzEngineGridNeighborCount(@cName)

		def NumberOfNeighbors()
			return This.NeighborCount()

	def IsValidPosition(nRow, nCol)
		nResult = StzEngineGridIsValid(@cName, nRow, nCol)
		if nResult = 1
			return 1
		else
			return 0
		ok

	def DistanceTo(nRow, nCol)
		return StzEngineGridDistance(@cName, nRow, nCol)

	  #-------------------------------#
	 #     INFO AND RESET            #
	#-------------------------------#

	def Name()
		return @cName

	def ResetPosition()
		StzEngineGridReset(@cName)

		def ResetPositionQ()
			This.ResetPosition()
			return This
