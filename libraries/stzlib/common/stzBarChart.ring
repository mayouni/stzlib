class stzVBarChart from stzBarChart

class stzBarChart

	# Data properties
	@anValues = []
	@acLabels = []
	@acCanvas = []

	# Display options
	@bShowHAxis = True
	@bShowVAxis = True
	@bShowLabels = True
	@bShowAxisLabels = True

	@bShowAverage = False
	@bShowValues = False
	@bShowPercent = False

	# Dimensions
	@nWidth = 60
	@nHeight = 7
	@nBarWidth = 2
	@nMaxWidth = 120
	@nMaxLabelWidth = 12
	@nBarInterSpace = 1

	# Characters
	@cBarChar = "█"
	@cTopChar = "█"
	@cVAxisChar = "│"
	@cHAxisChar = "─"
	@cVArrowChar = "▲"
	@cHArrowChar = "►"
	@cOriginChar = "╰"
	@cAverageChar = "-"
	@cLabelChar = "X"

	# Layout constants
	@nVAxisWidth = 1
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
				@acLabels + (@cLabelChar + i)
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

	def Size()
		return [@nHeight, @nWidth]

		def SizeHV()
			return [@nWidth, @nHeight]

		def SizeVH()
			return [@nHeight, @nWidth]

	def Width()
		return @nWidth

	def Height()
		return @nHeight

	def MaxWidth()
		return @nMaxWidth

	def SetBarWidth(nWidth)
		@nBarWidth = max([1, nWidth])

	def SetBarInterSpace(n)
		@nBarInterSpace = max([0, nSpacing])

		def SetBarSpace(n)
			This.SetBarInterSpace(n)

		def SetInterBarSpace(n)
			This.SetBarInterSpace(n)

	def SetMaxLabelWidth(nWidth)
		@nMaxLabelWidth = max([3, nWidth])

	def SetHeight(n)
		@nHeight = max([2, n]) # Minimum 2 for visibility

	def SetWidth(n)
		@nWidth = n

	def SetMaxWidth(n)
		@nMaxWidth = n

	# Display options with H/V naming and XY aliases
	def SetHAxis(bShow)
		@bShowHAxis = bShow

		def WithoutHAxis()
			@bShowHAxis = FALSE

		# XY Aliases
		def SetXAxis(bShow)
			This.SetHAxis(bShow)

		def WithoutXAxis()
			This.WithoutHAxis()

	def SetVAxis(bShow)
		@bShowVAxis = bShow

		def WithoutVAxis()
			@bShowVAxis = FALSE

		# XY Aliases
		def SetYAxis(bShow)
			This.SetVAxis(bShow)

		def WithoutYAxis()
			This.WithoutVAxis()

	def SetHVAxis(bHShow, bVShow)
		@bShowHAxis = bHShow
		@bShowVAxis = bVShow

		def SetHVAxies(bHShow, bVShow)
			This.SetHVAxis(bHShow, bVShow)

		def WithoutHVAxis()
			This.SetHVAxis(FALSE, FALSE)

		def WithoutHVAxies()
			This.SetHVAxis(FALSE, FALSE)

		def WithoutAxis()
			This.SetHVAxis(FALSE, FALSE)

		def WithoutAxies()
			This.SetHVAxis(FALSE, FALSE)

		# XY Aliases
		def SetXYAxis(bHShow, bVShow)
			This.SetHVAxis(bHShow, bVShow)

		def SetXYAxies(bHShow, bVShow)
			This.SetHVAxis(bHShow, bVShow)

		def WithoutXYAxis()
			This.SetHVAxis(FALSE, FALSE)

		def WithoutXYAxies()
			This.SetHVAxis(FALSE, FALSE)

	def SetLabels(bShow)
		@bShowLabels = bShow
	
		def AddLabels()
			@bShowLabels = TRUE

	def SetLabelChar(c)

		if isNumber(c)

			if c = 0
				c = ""
			else
				c = "X"
			ok

		but NOT (IsChar(c) or isNull(c))
			c = "X"
		ok

		nLen = len(@acLabels)
		for i = 1 to nLen
			@acLabels[i] = (c + i)
		next

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

	def SetAxisLabels(bShow)
		@bShowAxisLabels = bShow

		def SetHAxisLabels(bShow)
			This.SetAxisLabels(bShow)

		def AddHAxisLabels(bShow)
			This.SetAxisLabels(bShow)

		def WithoutAxisLabels()
			This.SetAxisLabels(FALSE)

		def WithoutHAxisLabels()
			This.SetAxisLabels(FALSE)

	# Character customization with H/V naming
	def SetBarChar(cChar)
		if IsChar(cChar)
			@cBarChar = cChar
			if @cTopChar != cChar
				@cTopChar = cChar
			ok
		ok

	def SetTopChar(cChar)
		if IsChar(cChar)
			@cTopChar = cChar
		ok

	def SetAxisChars(cH, cV)
		if IsChar(cH)
			@cHAxisChar = cH
		ok
		if IsChar(cV)
			@cVAxisChar = cV
		ok

	# --- Layout Calculation ---

	def _calculateLayout()
		nBars = len(@anValues)
		
		# Calculate element widths (max of bar, label, value widths)
		aElementWidths = []
		for i = 1 to nBars
			nMaxWidth = @nBarWidth
			
			# Check label width (only if labels will actually be displayed)
			if @bShowLabels and @bShowAxisLabels and i <= len(@acLabels)
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
		nBaseWidth = nBarsWidth + iff(@bShowVAxis, @nVAxisWidth + @nAxisPadding, 0) + 2
		
		# Add space for average value if shown
		if @bShowAverage
		    nAvgValueWidth = len("" + RoundN(@nAverage, 1))
		    nTotalWidth = nBaseWidth + 2 + nAvgValueWidth
		else
		    nTotalWidth = nBaseWidth
		ok
		
		# Calculate layout dimensions - only allocate rows for visible components
		nBarsHeight = @nHeight
		nCurrentRow = 1
		
		# V-axis arrow row (only if V-axis shown)
		if @bShowVAxis
			nCurrentRow = 2  # Arrow goes in row 1, content starts at row 2
		ok
		
		# Values row (only if shown)
		nValuesRow = 0
		if @bShowValues or @bShowPercent
			nValuesRow = nCurrentRow
			nCurrentRow += 1
		ok
		
		# V-axis starts after arrow and values (only if V-axis shown)
		nVAxisStart = iff(@bShowVAxis, 2, 1)
		
		# Bars area
		nBarsStartRow = nCurrentRow
		nBarsEndRow = nCurrentRow + nBarsHeight - 1
		nCurrentRow = nBarsEndRow + 1
		
		# H-axis row (only if shown)
		nHAxisRow = 0
		if @bShowHAxis
			nHAxisRow = nCurrentRow
			nCurrentRow += 1
		ok
		
		# Labels row (only if shown AND axis labels enabled)
		nLabelsRow = 0
		if @bShowLabels and @bShowAxisLabels
			nLabelsRow = nCurrentRow
			nCurrentRow += 1
		ok
		
		# Total height is the last used row
		nTotalHeight = nCurrentRow - 1
		
		# Column positions
		nVAxisCol = 1
		nBarsStart = iff(@bShowVAxis, @nVAxisWidth + @nAxisPadding + 1, 1)
		
		return [
			:total_width = nTotalWidth,
			:total_height = nTotalHeight,
			:bars_start = nBarsStart,
			:bars_start_row = nBarsStartRow,
			:bars_end_row = nBarsEndRow,
			:h_axis_row = nHAxisRow,
			:values_row = nValuesRow,
			:labels_row = nLabelsRow,
			:v_axis_col = nVAxisCol,
			:v_axis_start = nVAxisStart,
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

	def _drawVAxis(oLayout)
		if not @bShowVAxis
			return
		ok
		
		nCol = oLayout[:v_axis_col]
		nStartRow = oLayout[:v_axis_start]
		nEndRow = iff(oLayout[:h_axis_row] > 0, oLayout[:h_axis_row], oLayout[:bars_end_row] + 1)
		
		# Draw arrow at top (always in row 1)
		_setChar(1, nCol, @cVArrowChar)
		
		# Draw vertical line
		for i = nStartRow to nEndRow
			_setChar(i, nCol, @cVAxisChar)
		next

	def _drawHAxis(oLayout)
		if not @bShowHAxis or oLayout[:h_axis_row] = 0
			return
		ok
		
		nRow = oLayout[:h_axis_row]
		nStart = iff(@bShowVAxis, oLayout[:v_axis_col], oLayout[:bars_start])
		nEnd = oLayout[:total_width] - iff(@bShowAverage, len("" + RoundN(@nAverage, 1)) + 2, 0) - 1
		
		# Draw horizontal line
		for i = nStart to nEnd
			_setChar(nRow, i, @cHAxisChar)
		next
		
		# Draw origin and arrow
		if @bShowVAxis
			_setChar(nRow, oLayout[:v_axis_col], @cOriginChar)
		ok
		_setChar(nRow, nEnd + 1, @cHArrowChar)

	def _drawBars(oLayout)
		nBars = len(@anValues)
		nCurrentH = oLayout[:bars_start]
		nBarsStartRow = oLayout[:bars_start_row]
		nBarsEndRow = oLayout[:bars_end_row]
		nBarsHeight = oLayout[:bars_height]
		aElementWidths = oLayout[:element_widths]
		
		for i = 1 to nBars
			nValue = @anValues[i]
			nElementWidth = aElementWidths[i]
			
			# Calculate bar height
			nBarHeight = 0
			if @nMaxValue > 0 and nValue > 0
				nBarHeight = max([1, ceil(nBarsHeight * nValue / @nMaxValue)])
			ok
			
			# Calculate bar position (centered in element)
			nBarStart = nCurrentH + floor((nElementWidth - @nBarWidth) / 2)
			
			# Draw bar from bottom up
			for j = 1 to nBarHeight
				for k = 1 to @nBarWidth
					nCol = nBarStart + k - 1
					nRow = nBarsEndRow - j + 1  # Draw from bottom up
					
					cChar = @cBarChar
					if j = nBarHeight and @cTopChar != ""
						cChar = @cTopChar
					ok
					
					_setChar(nRow, nCol, cChar)
				next
			next
			
			# Move to next position
			if i < nBars
				nCurrentH += nElementWidth + @nBarInterSpace
			ok
		next

	def _drawValues(oLayout)
		if not (@bShowValues or @bShowPercent) or oLayout[:values_row] = 0
			return
		ok
		
		nBars = len(@anValues)
		nCurrentH = oLayout[:bars_start]
		nBarsStartRow = oLayout[:bars_start_row]
		nBarsHeight = oLayout[:bars_height]
		aElementWidths = oLayout[:element_widths]
		
		for i = 1 to nBars
			nValue = @anValues[i]
			nElementWidth = aElementWidths[i]
			
			# Format value
			cValue = ""
			if @bShowValues
				if IsInteger(nValue)
					cValue = "" + nValue
				else
					cValue = "" + RoundN(nValue, 1)
				ok
			but @bShowPercent and @nSum > 0
				nPercent = RoundN((nValue * 100) / @nSum, 1)
				cValue = '' + nPercent + "%"
			ok
			
			# Calculate bar height to position value above it
			nBarHeight = 0
			if @nMaxValue > 0 and nValue > 0
				nBarHeight = max([1, ceil(nBarsHeight * nValue / @nMaxValue)])
			ok
			
			# Position value just above the bar top
			nValueRow = nBarsStartRow + nBarsHeight - nBarHeight - 1
			if nValueRow < 1
				nValueRow = 1  # Ensure it's within canvas bounds
			ok
			
			# Center value horizontally
			nValueStart = nCurrentH + floor((nElementWidth - len(cValue)) / 2)
			
			# Draw value
			nLen = len(cValue)
			for j = 1 to nLen
				if nValueStart + j - 1 <= oLayout[:total_width]
					_setChar(nValueRow, nValueStart + j - 1, cValue[j])
				ok
			next
			
			# Move to next position
			if i < nBars
				nCurrentH += nElementWidth + @nBarInterSpace
			ok
		next

	def _drawLabels(oLayout)
		if not @bShowLabels or not @bShowAxisLabels or oLayout[:labels_row] = 0
			return
		ok
		
		nBars = len(@anValues)
		nCurrentH = oLayout[:bars_start]
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
				nLabelStart = nCurrentH + floor((nElementWidth - len(cLabel)) / 2)
				
				# Draw label
				nLen = len(cLabel)
				for j = 1 to nLen
					_setChar(nLabelsRow, nLabelStart + j - 1, cLabel[j])
				next
			ok
			
			# Move to next position
			if i < nBars
				nCurrentH += aElementWidths[i] + @nBarInterSpace
			ok
		next

	def _drawAverage(oLayout)
		if not @bShowAverage
			return
		ok
		
		nBarsStartRow = oLayout[:bars_start_row]
		nBarsHeight = oLayout[:bars_height]
		nStart = iff(@bShowVAxis, oLayout[:v_axis_col] + 1, oLayout[:bars_start])
		nEnd = oLayout[:total_width] - iff(@bShowAverage, len("" + RoundN(@nAverage, 1)) + 2, 0)
		
		# Calculate average line position
		nAvgRow = nBarsStartRow + nBarsHeight - 1
		if @nMaxValue > 0
			nAvgHeight = ceil(nBarsHeight * @nAverage / @nMaxValue)
			nAvgRow = nBarsStartRow + nBarsHeight - nAvgHeight
		ok
		
		# Draw average line
		for i = nStart to nEnd
			if nAvgRow >= 1 and nAvgRow <= len(@acCanvas) and
			   i <= len(@acCanvas[1]) and @acCanvas[nAvgRow][i] = " "
				_setChar(nAvgRow, i, @cAverageChar)
			ok
		next
		
		# Draw average value at the end of the line
		if NOT @bShowValues
			return
		ok

		cAvgValue = "" + RoundN(@nAverage, 1)
		nValueStart = nEnd + 2
		nLen = len(cAvgValue)
		for j = 1 to nLen
		    nCol = nValueStart + j - 1
		    if nCol <= len(@acCanvas[1])  # Check if within canvas bounds
		        _setChar(nAvgRow, nCol, cAvgValue[j])
		    ok
		next

	# --- Main Methods ---

	def ToString()
		oLayout = _calculateLayout()
		_initCanvas(oLayout[:total_width], oLayout[:total_height])
	
		_drawVAxis(oLayout)
		_drawHAxis(oLayout)
		_drawBars(oLayout)
		_drawValues(oLayout)
		_drawLabels(oLayout)
		_drawAverage(oLayout)
		
		return _canvasToString()

	def _canvasToString()
		cResult = ""
		nRows = len(@acCanvas)
		
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


		# A hack for removing the │ from a last lin in:
		# ^
		# │    ██    
		# │ ██ ██ ██  
		# │ ██ ██ ██  
		# │ A  B  C   

		if classname(This) = "stzbarchart"
			if @bShowVAxis and not @bShowHAxis
				oTempStr = new stzString(cResult)
				nPos = oTempStr.FindLast(@cVAxisChar)
				oTempStr.ReplacecharAt(nPos, " ")
				cResult = oTempStr.Content()
			ok
		ok

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

