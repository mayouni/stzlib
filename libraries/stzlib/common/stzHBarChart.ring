class stzHBarChart from stzBarChart

	# Data properties (inherited from stzBarChart)
	# @anValues = []
	# @acLabels = []
	# @acCanvas = []

	# Display options (inherited)
	# @bShowHAxis = True
	# @bShowVAxis = True
	# @bShowLabels = True
	# @bShowAxisLabels = True
	# @bShowAverage = False
	# @bShowValues = False
	# @bShowPercent = False

	# Horizontal-specific dimensions
	@nWidth = 18        # Default horizontal width for bars
	@nHeight = 12       # Height to accommodate multiple bars vertically
	@nBarHeight = 1     # Height of each horizontal bar
	@nMaxHeight = 30    # Maximum chart height  
	@nMaxLabelWidth = 12
	@nBarInterSpace = 0 # No space between bars - compact layout

	# Override characters for horizontal layout
	@cBarChar = "▇"
	@cTopChar = "▇"
	@cVAxisChar = "│"
	@cHAxisChar = "─"
	@cVArrowChar = "^"
	@cHArrowChar = ">"
	@cOriginChar = "╰"
	@cAverageChar = "|"
	@cLabelChar = "X"

	# Horizontal-specific layout constants
	@nHAxisHeight = 1
	@nAxisPadding = 1

	# Override configuration methods for horizontal orientation

	def SetSize(nWidth, nHeight)
		@nWidth = max([20, nWidth])
		@nHeight = max([4, nHeight])

	def Size()
		return [@nHeight, @nWidth]

		def SizeHV()
			return [@nWidth, @nHeight]

		def SizeVH()
			return [@nHeight, @nWidth]

	def SetBarHeight(nHeight)
		@nBarHeight = max([1, nHeight])

	def SetBarInterSpace(nSpacing)
		@nBarInterSpace = max([0, nSpacing])

	def SetWidth(n)
		@nWidth = max([10, n])

	def Width()
		return @nWidth

	def SetHeight(n)  
		@nHeight = max([4, n])

	def Height()
		return @nHeight

	def SetMaxHeight(n)
		@nMaxHeight = max([3, n])

	def MaxHeight()
		return @nMaxHeight

	# --- Horizontal Layout Calculation ---

	def _calculateLayout()
		nBars = len(@anValues)
		
		# Calculate maximum label width
		nMaxLabelWidth = 0
		if @bShowLabels and @bShowAxisLabels
			for i = 1 to nBars
				if i <= len(@acLabels)
					nLabelWidth = min([len(@acLabels[i]), @nMaxLabelWidth])
					nMaxLabelWidth = max([nMaxLabelWidth, nLabelWidth])
				ok
			next
		ok
		
		# Calculate total height needed for bars (compact - no inter-spacing)
		nBarsHeight = nBars * @nBarHeight
		
		# Layout dimensions
		nCurrentCol = 1
		
		# Labels column (only if labels shown)
		nLabelsCol = 0
		if @bShowLabels and @bShowAxisLabels and nMaxLabelWidth > 0
			nLabelsCol = nCurrentCol
			nCurrentCol += nMaxLabelWidth + @nAxisPadding
		ok
		
		# V-axis column (only if shown)
		nVAxisCol = 0
		if @bShowVAxis
			nVAxisCol = nCurrentCol  
			nCurrentCol += 1 + @nAxisPadding
		ok
		
		# Bars area
		nBarsStart = nCurrentCol
		nBarsEnd = nCurrentCol + @nWidth - 1
		nCurrentCol = nBarsEnd + 1
		
		# Values column (only if shown)
		nValuesCol = 0
		if @bShowValues or @bShowPercent
			nValuesCol = nCurrentCol + 1
			# Calculate max value width
			nMaxValueWidth = 0
			for i = 1 to nBars
				nValue = @anValues[i]
				if @bShowValues
					nValueWidth = len("" + nValue)
				but @bShowPercent and @nSum > 0
					nPercent = (@anValues[i] * 100) / @nSum
					nValueWidth = len('' + RoundN(nPercent, 1) + "%")
				ok
				nMaxValueWidth = max([nMaxValueWidth, nValueWidth])
			next
			nCurrentCol += nMaxValueWidth + 1
		ok
		
		# Calculate total width
		nTotalWidth = nCurrentCol - 1
		
		# Add space for average if shown
		if @bShowAverage
			nTotalWidth = max([nTotalWidth, nBarsEnd + 10])
		ok
		
		# Calculate row positions (compact layout)
		nCurrentRow = 1
		
		# V-axis arrow row (only if shown)
		if @bShowVAxis
			nCurrentRow = 2  # Arrow in row 1, bars start at row 2
		ok
		
		# Bars area (compact - consecutive rows)
		nBarsStartRow = nCurrentRow
		nBarsEndRow = nCurrentRow + nBarsHeight - 1
		nCurrentRow = nBarsEndRow + 1
		
		# H-axis row (only if shown)
		nHAxisRow = 0
		if @bShowHAxis
			nHAxisRow = nCurrentRow
			nCurrentRow += 1
		ok
		
		# Total height
		nTotalHeight = nCurrentRow - 1
		
		return [
			:total_width = nTotalWidth,
			:total_height = nTotalHeight,
			:bars_start = nBarsStart,
			:bars_end = nBarsEnd,
			:bars_start_row = nBarsStartRow,
			:bars_end_row = nBarsEndRow,
			:h_axis_row = nHAxisRow,
			:labels_col = nLabelsCol,
			:values_col = nValuesCol,
			:v_axis_col = nVAxisCol,
			:bars_height = nBarsHeight,
			:max_label_width = nMaxLabelWidth
		]

	# --- Horizontal Drawing Methods ---

	def _drawVAxis(oLayout)
		if not @bShowVAxis or oLayout[:v_axis_col] = 0
			return
		ok
		
		nCol = oLayout[:v_axis_col]
		nStartRow = 2  # Start after arrow
		nEndRow = iff(oLayout[:h_axis_row] > 0, oLayout[:h_axis_row], oLayout[:bars_end_row])
		
		# Draw arrow at top
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
	    nStart = iff(@bShowVAxis, oLayout[:v_axis_col], oLayout[:bars_start])  # e.g., 3
	    nEnd = oLayout[:total_width]                                           # e.g., 54
	    if @bShowVAxis
	        _setChar(nRow, nStart, @cOriginChar)
	    ok
	    for i = nStart + 1 to nEnd - 1
	        _setChar(nRow, i, @cHAxisChar)
	    next
	    _setChar(nRow, nEnd, @cHArrowChar)


	def _drawBars(oLayout)
		nBars = len(@anValues)
		nBarsStartRow = oLayout[:bars_start_row]
		nBarsStart = oLayout[:bars_start]
		nBarsWidth = oLayout[:bars_end] - oLayout[:bars_start] + 1
		
		nCurrentRow = nBarsStartRow
		
		for i = 1 to nBars
			nValue = @anValues[i]
			
			# Calculate bar width
			nBarWidth = 0
			if @nMaxValue > 0 and nValue > 0
				nBarWidth = max([1, ceil(nBarsWidth * nValue / @nMaxValue)])
			ok
			
			# Draw horizontal bar (single row, no spacing)
			for k = 1 to nBarWidth
				nCol = nBarsStart + k - 1
				_setChar(nCurrentRow, nCol, @cBarChar)
			next
			
			# Move to next bar position (consecutive rows)
			nCurrentRow += 1
		next

	def _drawLabels(oLayout)
		if not @bShowLabels or not @bShowAxisLabels or oLayout[:labels_col] = 0
			return
		ok
		
		nBars = len(@anValues)
		nLabelsCol = oLayout[:labels_col]
		nCurrentRow = oLayout[:bars_start_row]
		
		for i = 1 to nBars
			if i <= len(@acLabels)
				cLabel = @acLabels[i]
				
				# Truncate if needed
				if len(cLabel) > @nMaxLabelWidth
					cLabel = Left(cLabel, @nMaxLabelWidth - 2) + ".."
				ok
				
				# Right-align label in the labels column
				nLabelStart = nLabelsCol + oLayout[:max_label_width] - len(cLabel)
				
				# Draw label
				nLen = len(cLabel)
				for j = 1 to nLen
					_setChar(nCurrentRow, nLabelStart + j - 1, cLabel[j])
				next
			ok
			
			# Move to next position (consecutive rows)
			nCurrentRow += 1
		next


	def _drawValues(oLayout)
	    if not (@bShowValues or @bShowPercent)
	        return
	    ok
	    
	    nBars = len(@anValues)
	    nBarsStart = oLayout[:bars_start]
	    nBarsStartRow = oLayout[:bars_start_row]
	    nBarsWidth = oLayout[:bars_end] - oLayout[:bars_start] + 1
	    
	    for i = 1 to nBars
	        nValue = @anValues[i]
	        
	        # Calculate bar width
	        nBarWidth = 0
	        if @nMaxValue > 0 and nValue > 0
	            nBarWidth = max([1, ceil(nBarsWidth * nValue / @nMaxValue)])
	        ok
	        
	        # Calculate the column where the value should start (one space after the bar ends)
	        nValueStartCol = nBarsStart + nBarWidth + 1
	        
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
				cValue = ring_substr2(cValue, ".0%", "%")
	        ok
	        
	        # Draw value on the same row as the bar
	        nRow = nBarsStartRow + (i - 1)
	        nLen = len(cValue)
	        for j = 1 to nLen
	            _setChar(nRow, nValueStartCol + j - 1, cValue[j])
	        next
	    next

	def _drawAverage(oLayout)
		if not @bShowAverage
			return
		ok
		
		nBarsStart = oLayout[:bars_start]
		nBarsWidth = oLayout[:bars_end] - oLayout[:bars_start] + 1
		nBarsStartRow = oLayout[:bars_start_row]
		nBarsEndRow = oLayout[:bars_end_row]
		
		# Calculate average line position
		nAvgCol = nBarsStart
		if @nMaxValue > 0
			nAvgWidth = ceil(nBarsWidth * @nAverage / @nMaxValue)
			nAvgCol = nBarsStart + nAvgWidth - 1
		ok
		
		# Draw vertical average line
		for i = nBarsStartRow to nBarsEndRow
			if @acCanvas[i][nAvgCol] = " "
				_setChar(i, nAvgCol, "|")
			ok
		next
		
		# Draw average value above the line
		if @bShowValues
			cAvgValue = "avg:" + RoundN(@nAverage, 1)
			nValueRow = max([1, nBarsStartRow - 1])
			nValueStart = max([1, nAvgCol - floor(len(cAvgValue) / 2)])
			
			nLen = len(cAvgValue)
			for j = 1 to nLen
				nCol = nValueStart + j - 1
				if nCol <= len(@acCanvas[1])
					_setChar(nValueRow, nCol, cAvgValue[j])
				ok
			next
		ok
