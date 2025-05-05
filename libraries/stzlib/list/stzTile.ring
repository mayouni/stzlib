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
					if IsChar(@cObstacleChar) = 1
						@cObstacleChar = " " + @cObstacleChar + " "
					ok
					aCells[nObstacleRow][nObstacleCol] = @cObstacleChar  # Use obstacle character
				ok
			next
		ok
	
		# Add path
		if @bShowPath and len(@aPath) > 0
			# Mark ALL path cells with the path character
			for i = 1 to len(@aPath)
				nPathCol = @aPath[i][1]
				nPathRow = @aPath[i][2]
	
				if IsValidPosition(nPathCol, nPathRow)
					# Skip if it's a Obstacle
					if NOT This.IsObstacle(nPathCol, nPathRow)
						aCells[nPathRow][nPathCol] = @cPathChar
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
			cResult += "    "  # Space for alignment
			for x = 1 to @nCols
				if x % 10 = 0
					cResult += "0   "
				else
					cResult += ""+ (x % 10) + "   "
				ok
			next
			cResult += NL()
		ok
	
		# Top border with column indicator for current position
		cResult += "  ╭"
		for x = 1 to @nCols
			if x = @nCurrentCol
				cResult += "─v─"
			else
				cResult += "───"
			ok
	
			if x < @nCols
				cResult += "┬"
			ok
		next
		cResult += "╮" + NL()
	
		# Rows with cells
		for y = 1 to @nRows
			if @bShowCoordinates
				if y % 10 = 0
					yLabel = "0"
				else
					yLabel = ""+ (y % 10)
				ok
			else
				yLabel = " "
			ok
	
			# Row indicator for current position
			if y = @nCurrentRow
				cResult += yLabel + " >"
			else
				cResult += yLabel + " │"
			ok
			for x = 1 to @nCols
				if aCells[y][x] = @cObstacleChar
					# Fill the entire cell with the obstacle character
					cResult += @cObstacleChar
				else
					# Normal spacing for other characters
					cResult += " " + aCells[y][x] + " "
				ok
	
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


	def DisplayCustomGrid(aCustomGrid)
		# Display a custom Grid without changing the internal Grid state
		cResult = ""
	
		# Add X-axis labels if requested
		if @bShowCoordinates
			cResult += "    "  # Space for alignment
			for x = 1 to @nCols
				if x % 10 = 0
					cResult += "0   "
				else
					cResult += ""+ (x % 10) + "   "
				ok
			next
			cResult += NL()
		ok
	
		# Top border with column indicator for current position
		cResult += "  ╭"
		for x = 1 to @nCols
			if x = @nCurrentCol
				cResult += "─v─"
			else
				cResult += "───"
			ok
	
			if x < @nCols
				cResult += "┬"
			ok
		next
		cResult += "╮" + NL()
	
		# Rows with cells
		for y = 1 to @nRows
			if @bShowCoordinates
				if y % 10 = 0
					yLabel = "0"
				else
					yLabel = ""+ (y % 10)
				ok
			else
				yLabel = " "
			ok
	
			# Row indicator for current position
			if y = @nCurrentRow
				cResult += yLabel + " >"
			else
				cResult += yLabel + " │"
			ok
	

		
			for x = 1 to @nCols

				if aCustomGrid[y][x] = @cObstacleChar
					# Fill the entire cell with the obstacle character
					cResult += @cObstacleChar
				else
					# Normal spacing for other characters
					cResult += " " + aCustomGrid[y][x] + " "
				ok

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
	
		? cResult
