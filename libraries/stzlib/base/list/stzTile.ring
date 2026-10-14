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

# Draws a grid of square cells with box lines, marking the current cell, obstacles and a path, for navigation and puzzles.
#
# A stzTile is a stzGrid, so build one with new stzTile([ columns, rows ]) or StzTileQ(...) and use
# every grid method: AddObstacle, MoveToNode, paths, connected regions (Rooms). The class adds the
# drawing: Show prints it, ToString returns it, Legend names the characters used, and ShowCustomGrid
# draws other contents in the same frame. Positions count from 1, with the column first.
#
#   receiver   o1 = new stzTile([ 3, 2 ])
#   example    o1.AddObstacle(2, 1)
#              o1.Show()
#              #--> 1   2   3
#              #--> ╭─v─┬───┬───╮
#              #--> 1 > ♥ │███│   │
#              #--> ├───┼───┼───┤
#              #--> 2 │   │   │   │
#              #--> ╰───┴───┴───╯
#   see        stzGrid, stzList2D
Class stzTile From stzGrid

	# The stzTile class is a square-based counterpart of stzGrid.


	@cObstacleChar = "███"

	@cCurrentChar = "♥"
	@cEmptyChar = " "

	# Builds a tile, a grid of square cells drawn with box lines, from its number of columns and rows.
	#
	#   panColRow   a pair of numbers, [ columns, rows ]
	#   returns     nothing; the object is built, current cell at column 1, row 1
	#   note        everything stzGrid offers (AddObstacle, MoveToNode, paths, regions) is available
	#               on a tile
	#   warning     anything but a pair of numbers raises "Incorrect param type! panColRow must be a
	#               pair of numbers."
	#   see         SetObstacleCell, Show
	def init(panColRow)

		super.init(panColRow)
	

	# Sets the text that fills an obstacle cell when the tile is drawn, up to 3 characters.
	#
	#   cChar      the text drawn in an obstacle cell, 3 bytes at most
	#   returns    nothing
	#   note       a one-character text is padded with a space on each side the first time the tile
	#              is drawn, so Legend afterwards shows " X " for "X"
	#   warning    A text longer than 3 bytes raises "Incorrect param value! cChar must be a string
	#              of maximum 3 chars.", and the size is counted in bytes: one emoji, 4 bytes, is
	#              refused although it is one character
	#   see        SetObstacleChar, ToString
	def SetObstacleCell(cChar)
		if isString(cChar) and len(cChar) < 4
			@cObstacleChar = cChar
		else
			StzRaise("Incorrect param value! cChar must be a string of maximum 3 chars.")
		ok

		# Sets the text that fills an obstacle cell when the tile is drawn, the same as SetObstacleCell.
		#
		#   cChar      the text drawn in an obstacle cell, 3 bytes at most
		#   returns    nothing
		#   warning    the same byte limit: one emoji is refused
		#   see        SetObstacleCell
		def SetObstacleChar(cChar)
			This.SetObstacleCell(cChar)

	#-- ROOMS

	def Rooms()
		return This.ConnectedRegions()

	
	# Prints the tile on the console: column and row numbers, box lines, the current cell as a heart and the obstacles filled in.
	#
	#   returns    nothing
	#   note       the box characters need a UTF-8 console
	#   see        ToString, Legend
	#@ aka  -- VISUALIZING THE Tile
	def Show()
		? This.ToString()

	# Returns the tile drawn as text with box lines and numbers, the current cell marked by a heart, and the obstacles filled in.
	#
	#   returns    a text of several lines
	#   note       the drawing changes with the grid state: obstacles, the current cell and a path
	#              if one is shown
	#   see        Show, Legend
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
			_cResult_ += char(10)
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
		_cResult_ += "╮" + char(10)
	
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
			_cResult_ += "│" + char(10)
	
			# Horizontal line between rows
			if y < @nRows
				_cResult_ += "  ├"
				for x = 1 to @nCols
					_cResult_ += "───"
					if x < @nCols
						_cResult_ += "┼"
					ok
				next
				_cResult_ += "┤" + char(10)
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
		_cResult_ += "╯" + char(10)
	
		return _cResult_

	# Returns a one-line text that names the size of the tile and the characters used for the current cell, the obstacles and the path.
	#
	#   returns    a text that starts "Tile: 4x3" and lists the current, obstacle and path
	#              characters
	#   see        ToString
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


	# Prints the frame of the tile with the given items in its cells instead of its own state.
	#
	#   aCustomGrid   a list of rows, each a list of the texts to show, with at least as many rows
	#                 and columns as the tile
	#   returns       nothing
	#   note          the current cell is still marked by the arrow and v, but not by the heart
	#   warning       A list with fewer rows or columns than the tile raises R2 (Array Access, Index
	#                 out of range)
	#   see           ToString
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
			_cResult_ += char(10)
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
		_cResult_ += "╮" + char(10)
	
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
			_cResult_ += "│" + char(10)
	
			# Horizontal line between rows
			if y < @nRows
				_cResult_ += "  ├"
				for x = 1 to @nCols
					_cResult_ += "───"
					if x < @nCols
						_cResult_ += "┼"
					ok
				next
				_cResult_ += "┤" + char(10)
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
		_cResult_ += "╯" + char(10)
	
		? _cResult_
