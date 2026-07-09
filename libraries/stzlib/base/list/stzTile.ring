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

Class stzTile From stzGrid

	# The stzTile class is a square-based counterpart of stzGrid.


	@cObstacleChar = "███"

	@cCurrentChar = "♥"
	@cEmptyChar = " "

	def init(panColRow)

		super.init(panColRow)
	

	def SetObstacleCell(cChar)
		if isString(cChar) and len(cChar) < 4
			@cObstacleChar = cChar
		else
			StzRaise("Incorrect param value! cChar must be a string of maximum 3 chars.")
		ok

		def SetObstacleChar(cChar)
			This.SetObstacleCell(cChar)

	#-- ROOMS

	def Rooms()
		return This.ConnectedRegions()

	
	#-- VISUALIZING THE Tile
	
	def Show()
		? This.ToString()

	def ToString()
		# Create an empty tile grid
		_aCells_ = list(@nRows)
	
		for y = 1 to @nRows
			_aCells_[y] = list(@nCols)
			for x = 1 to @nCols
				_aCells_[y][x] = @cEmptyChar
			next
		next
	
		# Add Obstacles (obstacles)
		if @bShowObstacles
			_nLen_ = len(@aObstacles)
			for i = 1 to _nLen_
				_nObstacleCol_ = @aObstacles[i][1]
				_nObstacleRow_ = @aObstacles[i][2]
	
				if IsValidPosition(_nObstacleCol_, _nObstacleRow_)
					if IsChar(@cObstacleChar) = 1
						@cObstacleChar = " " + @cObstacleChar + " "
					ok
					_aCells_[_nObstacleRow_][_nObstacleCol_] = @cObstacleChar  # Use obstacle character
				ok
			next
		ok
	
		# Add path
		if @bShowPath and len(@aPath) > 0
			# Mark ALL path cells with the path character
			_nPathLen_ = len(@aPath)
			for i = 1 to _nPathLen_
				_nPathCol_ = @aPath[i][1]
				_nPathRow_ = @aPath[i][2]
	
				if IsValidPosition(_nPathCol_, _nPathRow_)
					# Skip if it's a Obstacle
					if NOT This.IsObstacle(_nPathCol_, _nPathRow_)
						_aCells_[_nPathRow_][_nPathCol_] = @cPathChar
					ok
				ok
			next
		ok
	
		# Mark current cell position
		if IsValidPosition(@nCurrentCol, @nCurrentRow)
			_aCells_[@nCurrentRow][@nCurrentCol] = @cCurrentChar
		ok
	
		# Convert tile grid to string representation
		_cResult_ = ""
	
		# Add X-axis labels if requested
		if @bShowCoordinates
			_cResult_ += "    "  # Space for alignment
			for x = 1 to @nCols
				if x % 10 = 0
					_cResult_ += "0   "
				else
					_cResult_ += ""+ (x % 10) + "   "
				ok
			next
			_cResult_ += NL()
		ok
	
		# Top border with column indicator for current position
		_cResult_ += "  ╭"
		for x = 1 to @nCols
			if x = @nCurrentCol
				_cResult_ += "─v─"
			else
				_cResult_ += "───"
			ok
	
			if x < @nCols
				_cResult_ += "┬"
			ok
		next
		_cResult_ += "╮" + NL()
	
		# Rows with cells
		for y = 1 to @nRows
			if @bShowCoordinates
				if y % 10 = 0
					_yLabel_ = "0"
				else
					_yLabel_ = ""+ (y % 10)
				ok
			else
				_yLabel_ = " "
			ok
	
			# Row indicator for current position
			if y = @nCurrentRow
				_cResult_ += _yLabel_ + " >"
			else
				_cResult_ += _yLabel_ + " │"
			ok
			for x = 1 to @nCols
				if _aCells_[y][x] = @cObstacleChar
					# Fill the entire cell with the obstacle character
					_cResult_ += @cObstacleChar
				else
					# Normal spacing for other characters
					_cResult_ += " " + _aCells_[y][x] + " "
				ok
	
				if x < @nCols
					_cResult_ += "│"
				ok
			next
			_cResult_ += "│" + NL()
	
			# Horizontal line between rows
			if y < @nRows
				_cResult_ += "  ├"
				for x = 1 to @nCols
					_cResult_ += "───"
					if x < @nCols
						_cResult_ += "┼"
					ok
				next
				_cResult_ += "┤" + NL()
			ok
		next
	
		# Bottom border
		_cResult_ += "  ╰"
		for x = 1 to @nCols
			_cResult_ += "───"
			if x < @nCols
				_cResult_ += "┴"
			ok
		next
		_cResult_ += "╯" + NL()
	
		return _cResult_

	def Legend()

		# Create a legend string with all relevant information

		_cResult_ = "Tile: " + @nCols + "x" + @nRows + " | "
		_cResult_ += "Current: " + @cCurrentChar + " | "

		if @bShowObstacles
			_cResult_ += "Obstacles: " + @cObstacleChar + " | "
		ok

		if @bShowPath
			_cResult_ += "Path: " + @cPathChar + " | "
		ok

		return _cResult_


	def ShowCustomGrid(aCustomGrid)
		# Display a custom Grid without changing the internal Grid state
		_cResult_ = ""
	
		# Add X-axis labels if requested
		if @bShowCoordinates
			_cResult_ += "    "  # Space for alignment
			for x = 1 to @nCols
				if x % 10 = 0
					_cResult_ += "0   "
				else
					_cResult_ += ""+ (x % 10) + "   "
				ok
			next
			_cResult_ += NL()
		ok
	
		# Top border with column indicator for current position
		_cResult_ += "  ╭"
		for x = 1 to @nCols
			if x = @nCurrentCol
				_cResult_ += "─v─"
			else
				_cResult_ += "───"
			ok
	
			if x < @nCols
				_cResult_ += "┬"
			ok
		next
		_cResult_ += "╮" + NL()
	
		# Rows with cells
		for y = 1 to @nRows
			if @bShowCoordinates
				if y % 10 = 0
					_yLabel_ = "0"
				else
					_yLabel_ = ""+ (y % 10)
				ok
			else
				_yLabel_ = " "
			ok
	
			# Row indicator for current position
			if y = @nCurrentRow
				_cResult_ += _yLabel_ + " >"
			else
				_cResult_ += _yLabel_ + " │"
			ok
	

		
			for x = 1 to @nCols

				if aCustomGrid[y][x] = @cObstacleChar
					# Fill the entire cell with the obstacle character
					_cResult_ += @cObstacleChar
				else
					# Normal spacing for other characters
					_cResult_ += " " + aCustomGrid[y][x] + " "
				ok

				if x < @nCols
					_cResult_ += "│"
				ok
			next
			_cResult_ += "│" + NL()
	
			# Horizontal line between rows
			if y < @nRows
				_cResult_ += "  ├"
				for x = 1 to @nCols
					_cResult_ += "───"
					if x < @nCols
						_cResult_ += "┼"
					ok
				next
				_cResult_ += "┤" + NL()
			ok
		next
	
		# Bottom border
		_cResult_ += "  ╰"
		for x = 1 to @nCols
			_cResult_ += "───"
			if x < @nCols
				_cResult_ += "┴"
			ok
		next
		_cResult_ += "╯" + NL()
	
		? _cResult_
