
class stzVBarChart from stzBarChart

class stzBarChart

	# Data properties
	@anValues = []
	@acLabels = []
	@acCanvas = []

	# Display options
	@bShowXAxis = True
	@bShowYAxis = True
	@bShowLabels = True
	@bShowAxisLabels = True

	@bShowAverage = False
	@bShowValues = False
	@bShowPercent = False

	# Dimensions
	@nWidth = 60
	@nHeight = 10
	@nBarWidth = 2
	@nMaxWidth = 120
	@nMaxLabelWidth = 12
	@nBarInterSpace = 1

	# Characters
	@cBarChar = "█"
	@cFinalBarChar = "█"
	@cXAxisChar = "│"
	@cYAxisChar = "─"
	@cXArrowChar = "↑"
	@cYArrowChar = ">"
	@cOriginChar = "╰"
	@cAverageChar = "-"

	# Layout constants
	@nYAxisWidth = 1
	@nAxisPadding = 1

	# Calculated values
	@nMaxValue = 0
	@nSum = 0
	@nAverage = 0

	def init(paDataSet)
		if not isList(paDataSet)
			StzRaise("Dataset must be a list")
		ok

		_processDataSet(paDataSet)
		_calculateMetrics()

	# --- Data Processing ---

	def _processDataSet(paDataSet)
		if IsListOfNumbers(paDataSet)
			# Convert simple number list to labeled data
			@anValues = paDataSet
			@acLabels = []
			nLen = len(paDataSet)
			for i = 1 to nLen
				@acLabels + ("B" + i)
			next

		but IsHashListOfNumbers(paDataSet)
			# Extract keys and values from hashlist
			oHash = new stzHashList(paDataSet)
			@anValues = oHash.Values()
			@acLabels = oHash.KeysQ().Capitalised()

		but IsHashList(paDataSet)
			oHash = new stzHashList(paDataSet)
			aValues = oHash.Values()

			if IsListOfNumbers(aValues)
				@anValues = aValues
				@acLabels = oHash.KeysQ().Capitalised()
			ok
			
		else
			StzRaise("Dataset must be a list of numbers or hashlist with numeric values")
		ok

		# Validate positive numbers
		for nVal in @anValues
			if nVal < 0
				StzRaise("All values must be positive numbers")
			ok
		next

	def _calculateMetrics()
		@nMaxValue = max(@anValues)
		@nSum = @sum(@anValues)
		@nAverage = @nSum / len(@anValues)

	# --- Configuration Methods ---

	def SetSize(nWidth, nHeight)
		@nWidth = max([20, nWidth])
		@nHeight = max([6, nHeight])

	def SetBarWidth(nWidth)
		@nBarWidth = max([1, nWidth])

	def SetBarInterSpace(nSpacing)
		@nBarInterSpace = max([0, nSpacing])

	def SetMaxLabelWidth(nWidth)
		@nMaxLabelWidth = max([3, nWidth])

	def SetHeight(n)
		@nHeight = max([2, n]) # Minimum 2 for visibility

	def SetWidth(n)
		@nWidth = n

	# Display options
	def SetXAxis(bShow)
		@bShowXAxis = bShow

		def WithoutXAxis()
			@bShowXAxis = FALSE

	def SetYAxis(bShow)
		@bShowYAxis = bShow

		def WithoutYAxis()
			@bShowYAxis = FALSE

	def SetXYAxis(bShow)
		@bShowXAxis = bShow
		@bShowYAxis = bShow
		@bShowAxisLabels = bShow

		def SetXYAxies(bShow)
			This.SetXYAxis(bShow)

		def WithoutXYAxis()
			This.SetXYAxis(FALSE)

		def WithoutXYAxies()
			This.SetXYAxis(FALSE)

		def WithoutAxis()
			This.SetXYAxis(FALSE)

		def WithoutAxies()
			This.SetXYAxis(FALSE)

	def SetLabels(bShow)
		@bShowLabels = bShow
	
		def AddLabels()
			@bShowLabels = TRUE

	def SetAverage(bShow)
		@bShowAverage = bShow

		def AddAverage()
			@bShowAverage = TRUE

	def SetValues(bShow)
		@bShowValues = bShow
		if bShow
			@bShowPercent = False
		ok

		def AddValues()
			This.SetValues(TRUE)

	def SetPercent(bShow)
		@bShowPercent = bShow
		if bShow
			@bShowValues = False
		ok

		def AddPercent()
			This.SetPercent(TRUE)

	def SetAxisLables(bShow)
		@bShowAxisLabels = bShow

		# A hack to erase the axis labels and
		# let the bars spacing be accurate

		if @bShowAxisLabels = FALSE
			nLen = len(@acLabels)
			for i = 1 to nLen
				@acLabels[i] = ""
			next
		ok

		def WithoutAxisLabels()
			This.SetAxisLables(FALSE)

	# Character customization
	def SetBarChar(cChar)
		if IsChar(cChar)
			@cBarChar = cChar
		ok

	def SetTopChar(cChar)
		if IsChar(cChar)
			@cFinalBarChar = cChar
		ok

	def SetAxisChars(cX, cY)
		if IsChar(cX)
			@cXAxisChar = cX
		ok
		if IsChar(cY)
			@cYAxisChar = cY
		ok

	# --- Layout Calculation ---

	def _calculateLayout()
		nBars = len(@anValues)
		
		# Calculate element widths (max of bar, label, value widths)
		aElementWidths = []
		for i = 1 to nBars
			nMaxWidth = @nBarWidth
			
			# Check label width
			if @bShowLabels and i <= len(@acLabels)
				nLabelWidth = min([len(@acLabels[i]), @nMaxLabelWidth])
				nMaxWidth = max([nMaxWidth, nLabelWidth])
			ok
			
			# Check value/percent width
			if @bShowValues
				nValueWidth = len("" + @anValues[i])
				nMaxWidth = max([nMaxWidth, nValueWidth])
			but @bShowPercent and @nSum > 0
				nPercent = (@anValues[i] * 100) / @nSum
				nValueWidth = len('' + RoundN(nPercent, 1) + "%")
				nMaxWidth = max([nMaxWidth, nValueWidth])
			ok
			
			aElementWidths + nMaxWidth
		next
		
		# Calculate total width needed
		nBarsWidth = @sum(aElementWidths) + (nBars - 1) * @nBarInterSpace
		nTotalWidth = nBarsWidth + iff(@bShowYAxis, @nYAxisWidth + @nAxisPadding, 0) + 2
		
		if nTotalWidth > @nMaxWidth
			nTotalWidth = @nMaxWidth
		ok
		
		# Calculate layout dimensions - @nHeight is the bars area height
		nBarsHeight = @nHeight  # Use user-specified height for bars area
		nTotalHeight = nBarsHeight + 1  # Start with bars + 1 for spacing

		# Add height for each enabled feature
		if @bShowXAxis
			nTotalHeight += 1
		ok
		if @bShowValues or @bShowPercent
			nTotalHeight += 1
		ok
		if @bShowLabels
			nTotalHeight += 1
		ok
		
		# Calculate row positions
		nYAxisCol = 1
		nBarsStart = iff(@bShowYAxis, @nYAxisWidth + @nAxisPadding + 1, 1)
		nXAxisRow = nBarsHeight + 1
		nValuesRow = nXAxisRow - 1
		nLabelsRow = nTotalHeight
		
		# Adjust positions if X-axis is shown
		if @bShowXAxis
			nXAxisRow = nBarsHeight + 1
			if @bShowValues or @bShowPercent
				nValuesRow = nXAxisRow + 1
			ok
			if @bShowLabels
				nLabelsRow = nXAxisRow + 1 + iff(@bShowValues or @bShowPercent, 1, 0)
			ok
		else
			if @bShowValues or @bShowPercent
				nValuesRow = nBarsHeight + 1
			ok
			if @bShowLabels
				nLabelsRow = nBarsHeight + 1 + iff(@bShowValues or @bShowPercent, 1, 0)
			ok
		ok
	
		return [
			:total_width = nTotalWidth,
			:total_height = nTotalHeight,
			:bars_start = nBarsStart,
			:x_axis_row = nXAxisRow,
			:values_row = nValuesRow,
			:labels_row = nLabelsRow,
			:y_axis_col = nYAxisCol,
			:bars_height = nBarsHeight,
			:element_widths = aElementWidths
		]

	# --- Canvas Operations ---

	def _initCanvas(nWidth, nHeight)
		@acCanvas = []
		for i = 1 to nHeight
			aRow = []
			for j = 1 to nWidth
				aRow + " "
			next
			@acCanvas + aRow
		next

	def _setChar(nRow, nCol, cChar)
		if nRow >= 1 and nRow <= len(@acCanvas) and
		   nCol >= 1 and nCol <= len(@acCanvas[1])
			@acCanvas[nRow][nCol] = cChar
		ok

	# --- Drawing Methods ---

	def _drawYAxis(oLayout)
		if not @bShowYAxis
			return
		ok
		
		nCol = oLayout[:y_axis_col]
		nAxisRow = oLayout[:x_axis_row]
		
		# Draw vertical line
		for i = 2 to nAxisRow
			_setChar(i, nCol, @cXAxisChar)
		next
		
		# Draw arrow
		_setChar(1, nCol, @cXArrowChar)

	def _drawXAxis(oLayout)
		if not @bShowXAxis
			return
		ok
		
		nRow = oLayout[:x_axis_row]
		nStart = iff(@bShowYAxis, oLayout[:y_axis_col], oLayout[:bars_start])
		nEnd = oLayout[:total_width] - 1
		
		# Draw horizontal line
		for i = nStart to nEnd
			_setChar(nRow, i, @cYAxisChar)
		next
		
		# Draw origin and arrow
		if @bShowYAxis
			_setChar(nRow, oLayout[:y_axis_col], @cOriginChar)
		ok
		_setChar(nRow, nEnd + 1, @cYArrowChar)

	def _drawBars(oLayout)
		nBars = len(@anValues)
		nCurrentX = oLayout[:bars_start]
		nAxisRow = oLayout[:x_axis_row]
		nBarsHeight = oLayout[:bars_height]
		aElementWidths = oLayout[:element_widths]
		
		for i = 1 to nBars
			nValue = @anValues[i]
			nElementWidth = aElementWidths[i]
			
			# Calculate bar height

		    if @nMaxValue > 0 and nValue > 0
		        nBarHeight = max([1, ceil(@nHeight * nValue / @nMaxValue)])  # Use @nHeight not @nHeight
		    ok
			
			# Calculate bar position (centered in element)
			nBarStart = nCurrentX + floor((nElementWidth - @nBarWidth) / 2)
			
			# Draw bar
			for j = 1 to nBarHeight
				for k = 1 to @nBarWidth
					nCol = nBarStart + k - 1
					nRow = nAxisRow - j
					
					cChar = @cBarChar
					if j = nBarHeight and @cFinalBarChar != ""
						cChar = @cFinalBarChar
					ok
					
					_setChar(nRow, nCol, cChar)
				next
			next
			
			# Move to next position
			if i < nBars
				nCurrentX += nElementWidth + @nBarInterSpace
			ok
		next

	def _drawValues(oLayout)
		if not (@bShowValues or @bShowPercent)
			return
		ok
		
		nBars = len(@anValues)
		nCurrentX = oLayout[:bars_start]
		nAxisRow = oLayout[:x_axis_row]
		nBarsHeight = oLayout[:bars_height]
		aElementWidths = oLayout[:element_widths]
		
		for i = 1 to nBars
			nValue = @anValues[i]
			nElementWidth = aElementWidths[i]
			
			# Format value
			cValue = ""
			if @bShowValues
				cValue = "" + nValue
			but @bShowPercent and @nSum > 0
				nPercent = RoundN((nValue * 100) / @nSum, 1)
				cValue = '' + nPercent + "%"
			ok
			
			# Calculate position
			
			nValueRow = max([1, nAxisRow - @nHeight])
			nValueStart = nCurrentX + floor((nElementWidth - len(cValue)) / 2)
			
			# Draw value
			nLen = len(cValue)
			for j = 1 to nLen
				_setChar(nValueRow, nValueStart + j - 1, cValue[j])
			next
			
			# Move to next position
			if i < nBars
				nCurrentX += nElementWidth + @nBarInterSpace
			ok
		next

	def _drawLabels(oLayout)
		if not @bShowLabels
			return
		ok
		
		nBars = len(@anValues)
		nCurrentX = oLayout[:bars_start]
		nLabelsRow = oLayout[:labels_row]
		aElementWidths = oLayout[:element_widths]
		
		for i = 1 to nBars
			if i <= len(@acLabels)
				cLabel = @acLabels[i]
				nElementWidth = aElementWidths[i]
				
				# Truncate if needed
				if len(cLabel) > @nMaxLabelWidth
					cLabel = Left(cLabel, @nMaxLabelWidth - 2) + ".."
				ok
				
				# Center label
				nLabelStart = nCurrentX + floor((nElementWidth - len(cLabel)) / 2)
				
				# Draw label
				nLen = len(cLabel)
				for j = 1 to nLen
					_setChar(nLabelsRow, nLabelStart + j - 1, cLabel[j])
				next
			ok
			
			# Move to next position
			if i < nBars
				nCurrentX += aElementWidths[i] + @nBarInterSpace
			ok
		next

	def _drawAverage(oLayout)
		if not @bShowAverage
			return
		ok
		
		nAxisRow = oLayout[:x_axis_row]
		nBarsHeight = oLayout[:bars_height]
		nStart = iff(@bShowYAxis, oLayout[:y_axis_col] + 1, oLayout[:bars_start])
		nEnd = oLayout[:total_width]
		
		# Calculate average line position
		nAvgRow = nAxisRow - 1
		if @nMaxValue > 0
			nAvgRow = nAxisRow - ceil(nBarsHeight * @nAverage / @nMaxValue)
		ok
		
		# Draw average line
		for i = nStart to nEnd
			if @acCanvas[nAvgRow][i] = " "  # Don't overwrite bars
				_setChar(nAvgRow, i, @cAverageChar)
			ok
		next

	# --- Main Methods ---

	def ToString()
		oLayout = _calculateLayout()
   		_initCanvas(oLayout[:total_width], oLayout[:total_height])  # Use calculated total height
	
		_drawYAxis(oLayout)
		_drawXAxis(oLayout)
		_drawBars(oLayout)
		_drawValues(oLayout)
		_drawLabels(oLayout)
		_drawAverage(oLayout)
		
		return _canvasToString()

	def _canvasToString()
		cResult = ""
		nRows = len(@acCanvas)
		
		# Skip last row if labels are disabled
		if not @bShowLabels
			nRows--
		ok
		
		for i = 1 to nRows
			cLine = ""
			nLen = len(@acCanvas[i])
			for j = 1 to nLen
				cLine += @acCanvas[i][j]
			next
			
			if i < nRows
				cResult += cLine + nl
			else
				cResult += cLine
			ok
		next

		# Hacks

		oTempStr = new stzString(cResult)

		# Hack for removing empty line from the top
		if @bShowYAxis = FALSE
			nPos = oTempStr.FindFirst(NL)
			if @trim(oTempStr.Section(1, nPos-1)) = ""
				oTempStr.RemoveSection(1, nPos)
			ok

		else # Hack for adding an empty line after the ^
			oTempStr.InsertAfterPosition(2, NL + @cXAxisChar + " ")
		ok

		
		# Hack for the axis labels visibility

		if @bShowAxisLabels = FALSE
			if @bShowYAxis = TRUE 
				nPos = otempStr.FindFirst(@cYArrowchar)
				oTempStr.RemoveSection(nPos+1, oTempStr.Numberofchars()) + NL

			else
				anPos = otempStr.FindAll(NL)
				nLen = len(anPos)
				oTempStr.RemoveSection(anPos[nLen-1], oTempStr.NumberOfChars())
			ok

		ok

		cResult = oTempStr.Content()
		return cResult

	def Show()
		? ToString()

	# --- Accessors ---

	def Values()
		return @anValues

	def Labels()
		return @acLabels

	def Sum()
		return @nSum

	def Average()
		return @nAverage

	def MaxValue()
		return @nMaxValue
