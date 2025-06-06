#-----------------------#
#  SCATTER CHART CLASS  #
#-----------------------#

class stzScatterChart

	@anHValues = []
	@anVValues = []
	@acPointLabels = []

	@bShowHAxis = True
	@bShowVAxis = True
	@bShowGrid = False
	@bShowLabels = false

	# V and H letters at the end of the axes
	@bShowHLetter = FALSE
	@bShowVLetter = FALSE

	# Console defaults
	@nMaxWidth = 42 
	@nMaxHeight = 12 
	@nHAxisHeight = 2

	@cPointChar = "●"
	@cVerticalGridChar = "⁞"
	@cHorizontalGridChar = "-"

	@cHTickChar = "┬"
	@cHTickChar2 = "┼"
	@cVTickChar = "┤"

	# Axis and drawing characters
	@cHAxisChar = "─"
	@cVAxisChar = "│"
	@cOriginChar = "╰"
	@cHArrowChar = "►"
	@cVArrowChar = "▲"

	@nHMin = 0
	@nHMax = 0
	@nVMin = 0
	@nVMax = 0

	@nWidth = 0
	@nHeight = 0
	@acCanvas = []

	def init(paDataSet)
		if NOT isList(paDataSet)
			StzRaise("Can't create stzScatterChart! paDataSet must be a list.")
		ok

		if IsListOfPairs(paDataSet) and len(paDataSet) > 0 and IsListOfNumbers(paDataSet[1])
			@anHValues = []
			@anVValues = []
			@acPointLabels = []

			for i = 1 to len(paDataSet)
				if len(paDataSet[i]) >= 2
					@anHValues + paDataSet[i][1]
					@anVValues + paDataSet[i][2]
					@acPointLabels + ("P" + i)
				ok
			next

		but IsHashList(paDataSet)
			oHash = new stzHashList(paDataSet)
			aKeys = oHash.Keys()

			if len(aKeys) = 2 and (aKeys[1] = "H" or aKeys[1] = :H or aKeys[1] = "X" or aKeys[1] = :X) and 
			   (aKeys[2] = "V" or aKeys[2] = :V or aKeys[2] = "Y" or aKeys[2] = :Y)
				
				if aKeys[1] = "H" or aKeys[1] = :H
					@anHValues = paDataSet[:H]
				else
					@anHValues = paDataSet[:X]
				ok
				
				if aKeys[2] = "V" or aKeys[2] = :V
					@anVValues = paDataSet[:V]
				else
					@anVValues = paDataSet[:Y]
				ok

				if len(@anHValues) != len(@anVValues)
					StzRaise("H and V value arrays must have same length!")
				ok

				@acPointLabels = []
				for i = 1 to len(@anHValues)
					@acPointLabels + ("P" + i)
				next

			else
				@anHValues = []
				@anVValues = []
				@acPointLabels = oHash.Keys()

				aValues = oHash.Values()
				for i = 1 to len(aValues)
					if isList(aValues[i]) and len(aValues[i]) >= 2
						@anHValues + aValues[i][1]
						@anVValues + aValues[i][2]
					ok
				next
			ok

		else
			StzRaise("Invalid data format! Use [[h1,v1], [h2,v2]] or hashlist format.")
		ok

		if NOT (IsListOfNumbers(@anHValues) and IsListOfNumbers(@anVValues))
			StzRaise("H and V values must all be numbers!")
		ok

		_calculateRanges()

		@bShowHLetter = TRUE
		@bShowVLetter = TRUE

	# Primary methods with V/H semantics
	def HValues()
		return @anHValues
		
		def XValues()  # Alias
			return This.HValues()

	def VValues()
		return @anVValues
		
		def YValues()  # Alias
			return This.VValues()

	def PointLabels()
		return @acPointLabels

	def SetHAxis(bShow)
		@bShowHAxis = bShow
		
		def SetXAxis(bShow)  # Alias
			This.SetHAxis(bShow)

		def WithoutHAxis()
			@bShowHAxis = FALSE
			
		def WithoutXAxis()  # Alias
			This.WithoutHAxis()

	def SetVAxis(bShow)
		@bShowVAxis = bShow
		
		def SetYAxis(bShow)  # Alias
			This.SetVAxis(bShow)

		def WithoutVAxis()
			@bShowVAxis = FALSE
			
		def WithoutYAxis()  # Alias
			This.WithoutVAxis()

	def SetHVAxis(bShow)
		@bShowHAxis = bShow
		@bShowVAxis = bShow

		def SetVHAxis(bShow)
			This.SetHVAxis(bShow)

		def SetHVAxes(bShow)
			This.SetHVAxis(bShow)

		def SetVHAxes(bShow)
			This.SetHVAxis(bShow)
			
		# X/Y aliases
		def SetXYAxis(bShow)
			This.SetHVAxis(bShow)
			
		def SetYXAxis(bShow)
			This.SetHVAxis(bShow)
			
		def SetXYAxes(bShow)
			This.SetHVAxis(bShow)
			
		def SetYXAxes(bShow)
			This.SetHVAxis(bShow)

		def WithoutHVAxis()
			This.SetHVAxis(FALSE)

		def WithoutVHAxis()
			This.SetHVAxis(FALSE)
			
		def WithoutXYAxis()  # Alias
			This.SetHVAxis(FALSE)

		def WithoutYXAxis()  # Alias
			This.SetHVAxis(FALSE)

	def SetHVLetters(bShow)
		@bShowHLetter = bShow
		@bShowVLetter = bShow

		def SetVH(bShow)
			This.SetHVLetters(bShow)
			
		def SetXYLetters(bShow)  # Alias
			This.SetHVLetters(bShow)

		def SetXY(bShow)  # Alias
			This.SetHVLetters(bShow)

		def WithoutHV()
			This.SetHVLetters(FALSE)
			
		def WithoutXY()  # Alias
			This.SetHVLetters(FALSE)

		def WithoutHVLetters()
			This.SetHVLetters(FALSE)
			
		def WithoutXYLetters()  # Alias
			This.SetHVLetters(FALSE)

	def SetHLetter(bShow)
		@bShowHLetter = bShow

		def SetH(bShow)
			@bShowHLetter = bShow
			
		def SetXLetter(bShow)  # Alias
			@bShowHLetter = bShow

		def SetX(bShow)  # Alias
			@bShowHLetter = bShow

		def WithoutH()
			@bShowHLetter = FALSE
			
		def WithoutX()  # Alias
			@bShowHLetter = FALSE

		def WithoutHLetter()
			@bShowHLetter = FALSE
			
		def WithoutXLetter()  # Alias
			@bShowHLetter = FALSE

	def SetVLetter(bShow)
		@bShowVLetter = bShow

		def SetV(bShow)
			@bShowVLetter = bShow
			
		def SetYLetter(bShow)  # Alias
			@bShowVLetter = bShow

		def SetY(bShow)  # Alias
			@bShowVLetter = bShow

		def WithoutV()
			@bShowVLetter = FALSE
			
		def WithoutY()  # Alias
			@bShowVLetter = FALSE

		def WithoutVLetter()
			@bShowVLetter = FALSE
			
		def WithoutYLetter()  # Alias
			@bShowVLetter = FALSE

	def SetGrid(bShow)
		@bShowGrid = bShow

		def AddGrid()
			@bShowGrid = TRUE

		def WithoutGrid()
			@bShowGrid = FALSE

	def SetLabels(bShow)
		@bShowLabels = bShow

		def AddLabels()
			@bShowLabels = TRUE

		def WithoutLabels()
			@bShowLabels = FALSE

	def SetPointChar(c)
		if NOT (isString(c) and IsChar(c))
			StzRaise("c must be a char.")
		ok
		@cPointChar = c

		def PointChar()
			return @cPointChar

	def SetMaxSize(nWidth, nHeight)
		if NOT (isNumber(nWidth) and isNumber(nHeight))
			StzRaise("nWidth and nHeight must be numbers.")
		ok
		@nMaxWidth = max([40, nWidth])
		@nMaxHeight = max([10, nHeight])

	def SetWidth(nWidth)
		if NOT isNumber(nWidth)
			StzRaise("nWidth must be a number.")
		ok
		@nMaxWidth = max([50, nWidth])

	def SetHeight(nHeight)
		if NOT isNumber(nHeight)
			StzRaise("nHeight must be a number.")
		ok
		@nMaxHeight = max([10, nHeight])

	def Show()
		? This.ToString()

	def ToString()
		oLayout = _calculateLayout()
		_initCanvas()

		if @bShowGrid
			_drawCoordinateGrid(oLayout)
		ok

		if @bShowVAxis
			_drawVAxis(oLayout)
		ok

		if @bShowHAxis
			_drawHAxis(oLayout)
		ok

		_drawPoints(oLayout)

		if @bShowLabels
			_drawPointLabels(oLayout)
		ok

		return _finalizeCanvas()

	def _calculateRanges()
		if len(@anHValues) = 0 or len(@anVValues) = 0
			@nHMin = 0
			@nHMax = 10
			@nVMin = 0
			@nVMax = 10
			return
		ok

		@nHMin = min(@anHValues)
		@nHMax = max(@anHValues)
		@nVMin = min(@anVValues)
		@nVMax = max(@anVValues)

		if _areAllIntegers(@anHValues)
			@nHMin = floor(@nHMin)
			@nHMax = ceil(@nHMax)
		ok
		if _areAllIntegers(@anVValues)
			@nVMin = floor(@nVMin)
			@nVMax = ceil(@nVMax)
		ok

	def _areAllIntegers(anList)
		for n in anList
			if NOT isNumber(n) or floor(n) != n
				return FALSE
			ok
		next
		return TRUE

	def _calculateLayout()
		# Calculate dynamic V-axis width based on actual labels
		nDynamicVAxisWidth = 0
		if @bShowVAxis
			aUniqueV = U(@anVValues)
			aUniqueV = ring_sort(aUniqueV)
			nMaxVLabelLen = 0
			for nV in aUniqueV
				cLabel = _formatValue(nV)
				cLabel = Trim(cLabel)
				if len(cLabel) > nMaxVLabelLen
					nMaxVLabelLen = len(cLabel)
				ok
			next
			# V-axis width = max label length + space + tick mark + small buffer
			nDynamicVAxisWidth = nMaxVLabelLen + 3
			# Ensure minimum width for readability
			nDynamicVAxisWidth = max([4, nDynamicVAxisWidth])
		ok

		# Calculate available space for the plot area
		nVAxisSpace = nDynamicVAxisWidth
		nHAxisSpace = iff(@bShowHAxis, @nHAxisHeight, 0)
		
		# Reserve space for arrow character
		nTopMargin = 1    # For vertical arrow
		
		# Calculate right margin based on longest label
		nLenPointLabels = len(@acPointLabels)
		nRightMargin = 2  # Default minimum
		if @bShowLabels
		    nMaxLabelLen = 0
		    for i = 1 to nLenPointLabels
				nLenLabel = len(@acPointLabels[i])
		        if nLenLabel > nMaxLabelLen
		            nMaxLabelLen = nLenLabel
		        ok
		    next
		    nRightMargin = nMaxLabelLen + 3  # Label length + spacing + buffer
		ok

		# Calculate plot dimensions with proper margins
		nPlotWidth = @nMaxWidth - nVAxisSpace - nRightMargin
		nPlotHeight = @nMaxHeight - nHAxisSpace - nTopMargin
		
		# Ensure minimum plot area
		nPlotWidth = max([20, nPlotWidth])
		nPlotHeight = max([8, nPlotHeight])
		
		# Calculate positions
		nVAxisCol = nVAxisSpace
		nPlotStartCol = nVAxisCol + 1
		nPlotEndCol = nPlotStartCol + nPlotWidth - 1
		
		nPlotStartRow = nTopMargin + 1
		nHAxisRow = nPlotStartRow + nPlotHeight
		nPlotEndRow = nHAxisRow - 1
		
		# Total canvas dimensions
		nTotalWidth = nPlotEndCol + nRightMargin
		nTotalHeight = nHAxisRow + nHAxisSpace
		
		# Set instance variables
		@nWidth = nTotalWidth
		@nHeight = nTotalHeight

		oLayout = new stzHashList([])
		oLayout.AddPair([:plot_start_col, nPlotStartCol])
		oLayout.AddPair([:plot_end_col, nPlotEndCol])
		oLayout.AddPair([:plot_start_row, nPlotStartRow])
		oLayout.AddPair([:plot_end_row, nPlotEndRow])
		oLayout.AddPair([:plot_width, nPlotWidth])
		oLayout.AddPair([:plot_height, nPlotHeight])
		oLayout.AddPair([:v_axis_col, nVAxisCol])
		oLayout.AddPair([:h_axis_row, nHAxisRow])
		oLayout.AddPair([:total_width, nTotalWidth])
		oLayout.AddPair([:total_height, nTotalHeight])

		return oLayout

	def _drawCoordinateGrid(oLayout)
		nStartCol = oLayout[:plot_start_col]
		nEndCol = oLayout[:plot_end_col]
		nStartRow = oLayout[:plot_start_row]
		nEndRow = oLayout[:plot_end_row]
		nPlotWidth = oLayout[:plot_width]
		nPlotHeight = oLayout[:plot_height]

		# Draw grid lines only from axis to each data point
		for i = 1 to len(@anHValues)
			nH = @anHValues[i]
			nV = @anVValues[i]
			
			# Calculate point position
			nCol = nStartCol + floor((nH - @nHMin) * (nPlotWidth - 1) / (@nHMax - @nHMin))
			nRow = nEndRow - floor((nV - @nVMin) * (nPlotHeight - 1) / (@nVMax - @nVMin))
			
			# Draw horizontal line from V-axis to point
			for j = nStartCol to nCol
				if @acCanvas[nRow][j] = " "
					@acCanvas[nRow][j] = @cHorizontalGridChar
				ok
			next
			
			# Draw vertical line from H-axis to point
			for j = nRow to nEndRow
				if @acCanvas[j][nCol] = " "
					@acCanvas[j][nCol] = @cVerticalGridChar
				ok
			next
		next

	def _drawVAxis(oLayout)
		if NOT @bShowVAxis
			return
		ok
		
		nAxisCol = oLayout[:v_axis_col]
		nStartRow = oLayout[:plot_start_row]
		nEndRow = oLayout[:plot_end_row]
		nHAxisRow = oLayout[:h_axis_row]
		nPlotHeight = oLayout[:plot_height]

		# Draw vertical line
		for i = nStartRow to nEndRow
			if i >= 1 and i <= len(@acCanvas) and nAxisCol >= 1 and nAxisCol <= len(@acCanvas[i])
				@acCanvas[i][nAxisCol] = @cVAxisChar
			ok
		next

		# Draw arrow at top
		if nStartRow - 1 >= 1 and nStartRow - 1 <= len(@acCanvas) and nAxisCol >= 1 and nAxisCol <= len(@acCanvas[nStartRow - 1])
			@acCanvas[nStartRow - 1][nAxisCol] = @cVArrowChar
		ok

		# Draw origin (only if H-axis is also visible)
		if @bShowHAxis and nHAxisRow >= 1 and nHAxisRow <= len(@acCanvas) and nAxisCol >= 1 and nAxisCol <= len(@acCanvas[nHAxisRow])
			@acCanvas[nHAxisRow][nAxisCol] = @cOriginChar
		ok

		# Always draw V-axis labels when V-axis is visible
		aUniqueV = U(@anVValues)
		aUniqueV = ring_sort(aUniqueV)
		for nV in aUniqueV
			nRow = nEndRow - floor((nV - @nVMin) * (nPlotHeight - 1) / (@nVMax - @nVMin))
			if nRow >= nStartRow and nRow <= nEndRow
				cLabel = _formatValue(nV)
				cLabel = Trim(cLabel)
				nLabelLen = len(cLabel)
				nLabelStart = nAxisCol - nLabelLen - 1  # Add space before tick mark
				if nLabelStart >= 1
					for j = 1 to nLabelLen
						@acCanvas[nRow][nLabelStart + j - 1] = cLabel[j]
					next
					@acCanvas[nRow][nAxisCol] = @cVTickChar
				ok
			ok
		next

	def _drawHAxis(oLayout)
		if NOT @bShowHAxis
			return
		ok
		
		nAxisRow = oLayout[:h_axis_row]
		nStartCol = oLayout[:plot_start_col]
		nEndCol = oLayout[:plot_end_col]
		nVAxisCol = oLayout[:v_axis_col]
		nPlotWidth = oLayout[:plot_width]
		nTotalWidth = oLayout[:total_width]

		# Draw horizontal line
		if nAxisRow >= 1 and nAxisRow <= len(@acCanvas)
			for i = nStartCol to nEndCol
				if i >= 1 and i <= nTotalWidth
					@acCanvas[nAxisRow][i] = @cHAxisChar
				ok
			next
		ok

		# Draw arrow at end
		if nAxisRow >= 1 and nAxisRow <= len(@acCanvas) and nEndCol + 1 >= 1 and nEndCol + 1 <= nTotalWidth
			@acCanvas[nAxisRow][nEndCol + 1] = @cHArrowChar
		ok

		# Draw origin
		if @bShowVAxis and nAxisRow >= 1 and nAxisRow <= len(@acCanvas) and nVAxisCol >= 1 and nVAxisCol <= nTotalWidth
			@acCanvas[nAxisRow][nVAxisCol] = @cOriginChar
		ok

		# Always draw H-axis labels when H-axis is visible
		aUniqueH = U(@anHValues)
		aUniqueH = ring_sort(aUniqueH)
		for nH in aUniqueH
			nCol = nStartCol + floor((nH - @nHMin) * (nPlotWidth - 1) / (@nHMax - @nHMin))
			if nCol >= nStartCol and nCol <= nEndCol
				cLabel = _formatValue(nH)
				nLabelLen = len(cLabel)
				nLabelStart = nCol - floor(nLabelLen / 2)
				
				# Draw tick mark
				if nCol >= 1 and nCol <= nTotalWidth
					@acCanvas[nAxisRow][nCol] = @cHTickChar
				ok
				
				# Draw label below axis (always when axis is visible)
				if nAxisRow + 1 >= 1 and nAxisRow + 1 <= len(@acCanvas) and
				   nLabelStart >= 1 and nLabelStart + nLabelLen - 1 <= nTotalWidth
					for j = 1 to nLabelLen
						@acCanvas[nAxisRow + 1][nLabelStart + j - 1] = cLabel[j]
					next
				ok
			ok
		next

	def _formatValue(nValue)
		if _areAllIntegers(@anHValues) and _areAllIntegers(@anVValues)
			return "" + floor(nValue)
		else
			return "" + RoundN(nValue, 1)
		ok

	def _drawPoints(oLayout)
		nStartCol = oLayout[:plot_start_col]
		nEndCol = oLayout[:plot_end_col]
		nStartRow = oLayout[:plot_start_row]
		nEndRow = oLayout[:plot_end_row]
		nPlotWidth = oLayout[:plot_width]
		nPlotHeight = oLayout[:plot_height]

		for i = 1 to len(@anHValues)
			nH = @anHValues[i]
			nV = @anVValues[i]

			# Calculate point position
			if @nHMax = @nHMin
				nCol = nStartCol + floor(nPlotWidth / 2)
			else
				nCol = nStartCol + floor((nH - @nHMin) * (nPlotWidth - 1) / (@nHMax - @nHMin))
			ok
			
			if @nVMax = @nVMin
				nRow = nStartRow + floor(nPlotHeight / 2)
			else
				nRow = nEndRow - floor((nV - @nVMin) * (nPlotHeight - 1) / (@nVMax - @nVMin))
			ok
			
			# Ensure point is within bounds
			nCol = max([nStartCol, min([nEndCol, nCol])])
			nRow = max([nStartRow, min([nEndRow, nRow])])
			
			# Draw the point
			if nRow >= 1 and nRow <= len(@acCanvas) and nCol >= 1 and nCol <= len(@acCanvas[nRow])
				@acCanvas[nRow][nCol] = @cPointChar
			ok
		next

	def _drawPointLabels(oLayout)
		nStartCol = oLayout[:plot_start_col]
		nEndCol = oLayout[:plot_end_col]
		nStartRow = oLayout[:plot_start_row]
		nEndRow = oLayout[:plot_end_row]
		nPlotWidth = oLayout[:plot_width]
		nPlotHeight = oLayout[:plot_height]

		nLenHVal = len(@anHValues)
		nLenLabels = len(@acPointLabels)

		for i = 1 to nLenHVal
			if i <= nLenLabels
				nH = @anHValues[i]
				nV = @anVValues[i]
				cLabel = " " + Capitalise(@acPointLabels[i])

				# Calculate point position (same as in _drawPoints)
				if @nHMax = @nHMin
					nCol = nStartCol + floor(nPlotWidth / 2)
				else
					nCol = nStartCol + floor((nH - @nHMin) * (nPlotWidth - 1) / (@nHMax - @nHMin))
				ok
				
				if @nVMax = @nVMin
					nRow = nStartRow + floor(nPlotHeight / 2)
				else
					nRow = nEndRow - floor((nV - @nVMin) * (nPlotHeight - 1) / (@nVMax - @nVMin))
				ok

				# Position label right next to the point (1 space to the right)
				nLabelCol = nCol + 1
				nLabelRow = nRow

				# Check bounds and draw label
				nLenLabel = len(cLabel)

				if nLabelRow >= 1 and nLabelRow <= @nHeight and 
				   nLabelCol >= 1 and nLabelCol + nLenLabel - 1 <= @nWidth
					for j = 1 to nLenLabel
						if nLabelCol + j - 1 <= @nWidth
							@acCanvas[nLabelRow][nLabelCol + j - 1] = cLabel[j]
						ok
					next
				ok
			ok
		next

	def _initCanvas()
		@acCanvas = []
		for i = 1 to @nHeight
			aRow = []
			for j = 1 to @nWidth
				aRow + " "
			next
			@acCanvas + aRow
		next

	def _finalizeCanvas()
		cResult = ""
		nLenCanvas = len(@acCanvas)
		for i = 1 to nLenCanvas
			cLine = ""
			nLenCurrent = len(@acCanvas[i])
			for j = 1 to nLenCurrent
				cLine += @acCanvas[i][j]
			next
			cResult += cLine + nl
		next

		# Remove unnecessary empty lines
		oTempStr = new stzString(cResult)
		if @bShowVAxis = FALSE
			nPos = oTempStr.FindFirst(NL)
			oTempStr.RemoveSection(1, nPos)
		ok

		anPos = oTempStr.FindAll(NL)
		if len(anPos) > 0
			nPos = anPos[len(anPos)-1]
			oTempStr.RemoveSection(nPos, oTempStr.NumberOfChars())
		ok

		# Adjust markers when grid is active
		if @bShowGrid
			oTempStr.ReplaceMany([@cHTickChar, @cVTickChar], @cHTickChar2)
		ok

		# Add H and V letters if required (showing as X/Y for backward compatibility)

		if @bShowHLetter and @bShowHAxis
			# Place Y letter at the end of horizontal axis
			oTempStr.Replace(@cHArrowChar, @cHAxisChar + @cHAxisChar + @cHArrowChar + " Y")
		ok

		if @bShowVLetter and @bShowVAxis
			# Place X letter at the end of vertical axis
			nPos = oTempStr.FindFirst(@cVArrowChar)
			oTempStr.InsertAt(1, @copy(" ", nPos-1) + "X" + NL)

			oTempStr.Replace(@cVArrowChar, @cVArrowChar + NL + @copy(" ", nPos-1) + @cVAxisChar)
		ok


		cResult = oTempStr.Content()
		return cResult
