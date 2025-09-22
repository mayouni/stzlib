
class stzHBarChart from stzHBarPlot

class stzHBarPlot from stzBarPlot

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
	@cVArrowChar = "▲"
	@cHArrowChar = "►"
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

	def SetBarInterSpace(n)
		@nBarInterSpace = max([0, n])

		def SetBarSpace(n)
			This.SetBarInterSpace(n)

		def SetInterBarSpace(n)
			This.SetBarInterSpace(n)

	def SetWidth(n)
		@nWidth = max([10, n])

	def SetHVAxis(bHShow, bVShow)
		@bShowHAxis = bHShow

		@bShowVAxis = bVShow
		@bShowAxisLabels = bVShow

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

	def SetVAxisLabels(bShow)
		This.SetAxisLabels(bShow)

		def AddVAxisLabels(bShow)
			This.SetAxisLabels(bShow)

		def WithoutAxisLabels()
			This.SetAxisLabels(FALSE)

		def WithoutVAxisLabels()
			This.SetAxisLabels(FALSE)

	# --- Horizontal Layout Calculation ---

	def _calculateLayout()
	    nBars = len(@anValues)
	    
	    # Cap the number of bars to @nMaxHeight
	    nBarsToShow = min([nBars, @nMaxHeight])  # e.g., 3 bars if @nMaxHeight = 3
	    nBarsHeight = nBarsToShow * @nBarHeight  # Total height for bars
	    
	    # Calculate maximum label width
	    nMaxLabelWidth = 0
	    if @bShowLabels and @bShowAxisLabels
	        for i = 1 to nBarsToShow  # Only consider shown bars
	            if i <= len(@acLabels)
	                nLabelWidth = min([len(@acLabels[i]), @nMaxLabelWidth])
	                nMaxLabelWidth = max([nMaxLabelWidth, nLabelWidth])
	            ok
	        next
	    ok
	    
	    # Layout dimensions
	    nCurrentCol = 1
	    
	    # Labels column
	    nLabelsCol = 0
	    if @bShowLabels and @bShowAxisLabels and nMaxLabelWidth > 0
	        nLabelsCol = nCurrentCol
	        nCurrentCol += nMaxLabelWidth + @nAxisPadding
	    ok
	    
	    # Vertical axis column
	    nVAxisCol = 0
	    if @bShowVAxis
	        nVAxisCol = nCurrentCol
	        nCurrentCol += 1 + @nAxisPadding
	    ok
	    
	    # Bars area
	    nBarsStart = nCurrentCol
	    nBarsEnd = nCurrentCol + @nWidth - 1
	    nCurrentCol = nBarsEnd + 1
	    
	    # Values column
	    nValuesCol = 0
	    if @bShowValues or @bShowPercent
	        nValuesCol = nCurrentCol + 1
	        nMaxValueWidth = 0
	        for i = 1 to nBarsToShow
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
	    
	    # Total width
	    nTotalWidth = nCurrentCol - 1
	    if @bShowAverage
	        nTotalWidth = max([nTotalWidth, nBarsEnd + 10])
	    ok
	    
	    # Row positions
	    nCurrentRow = 1
	    if @bShowVAxis
	        nCurrentRow = 2  # Arrow in row 1
	    ok
	    
	    # Bars area
	    nBarsStartRow = nCurrentRow
	    nBarsEndRow = nCurrentRow + nBarsHeight - 1
	    nCurrentRow = nBarsEndRow + 1
	    
	    # Horizontal axis row
	    nHAxisRow = 0
	    if @bShowHAxis
	        nHAxisRow = nCurrentRow
	        nCurrentRow += 1
	    ok
	    
	    # Annotation row for average
	    nAnnotationRow = 0
	    if @bShowAverage
	        nAnnotationRow = nCurrentRow
	        nCurrentRow += 1
	    ok
	    
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
	        :max_label_width = nMaxLabelWidth,
	        :bars_to_show = nBarsToShow,
	        :annotation_row = nAnnotationRow
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
	    nEnd = oLayout[:total_width]     

	    if @bShowVAxis
	        _setChar(nRow, nStart, @cOriginChar)
	    else
			if @bShowHAxis
				 _setChar(nRow, nStart, @cHAxisChar)
			ok
		ok

	    for i = nStart + 1 to nEnd - 1
	        _setChar(nRow, i, @cHAxisChar)
	    next
	    _setChar(nRow, nEnd, @cHArrowChar)


	def _drawBars(oLayout)
	    nBarsToShow = oLayout[:bars_to_show]
	    nBarsStartRow = oLayout[:bars_start_row]
	    nBarsStart = oLayout[:bars_start]
	    nBarsWidth = oLayout[:bars_end] - oLayout[:bars_start] + 1
	    
	    nCurrentRow = nBarsStartRow
	    
	    for i = 1 to nBarsToShow
	        nValue = @anValues[i]
	        
	        nBarWidth = 0
	        if @nMaxValue > 0 and nValue > 0
	            nBarWidth = max([1, ceil(nBarsWidth * nValue / @nMaxValue)])
	        ok
	        
	        for k = 1 to nBarWidth
	            nCol = nBarsStart + k - 1
	            _setChar(nCurrentRow, nCol, @cBarChar)
	        next
	        
	        nCurrentRow += 1
	    next


	def _drawLabels(oLayout)
	    if not @bShowLabels or not @bShowAxisLabels or oLayout[:labels_col] = 0
	        return
	    ok
	    
	    nBarsToShow = oLayout[:bars_to_show]
	    nLabelsCol = oLayout[:labels_col]
	    nCurrentRow = oLayout[:bars_start_row]
	    
	    for i = 1 to nBarsToShow
	        if i <= len(@acLabels)
	            cLabel = @acLabels[i]
	            
	            if len(cLabel) > @nMaxLabelWidth
	                cLabel = Left(cLabel, @nMaxLabelWidth - 2) + ".."
	            ok
	            
	            nLabelStart = nLabelsCol + oLayout[:max_label_width] - len(cLabel)
	            nLen = len(cLabel)
	            for j = 1 to nLen
	                _setChar(nCurrentRow, nLabelStart + j - 1, cLabel[j])
	            next
	        ok
	        nCurrentRow += 1
	    next
	

	def _drawValues(oLayout)
	    if not (@bShowValues or @bShowPercent)
	        return
	    ok
	    
	    nBarsToShow = oLayout[:bars_to_show]
	    nBarsStart = oLayout[:bars_start]
	    nBarsStartRow = oLayout[:bars_start_row]
	    nBarsWidth = oLayout[:bars_end] - oLayout[:bars_start] + 1
	    
	    for i = 1 to nBarsToShow
	        nValue = @anValues[i]
	        
	        nBarWidth = 0
	        if @nMaxValue > 0 and nValue > 0
	            nBarWidth = max([1, ceil(nBarsWidth * nValue / @nMaxValue)])
	        ok
	        
	        nValueStartCol = nBarsStart + nBarWidth + 1
	        
	        cValue = ""
	        if @bShowValues
	            if IsInteger(nValue)
	                cValue = "" + nValue
	            else
	                cValue = "" + RoundN(nValue, 1)
	            ok
	        but @bShowPercent and @nSum > 0
	            nPercent = RoundN((nValue * 100) / @nSum, 1)
	            cValue = "" + nPercent + "%"
				cValue = ring_substr2(cValue, ".0%", "%")
	        ok
	        
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
	    
	    nBarsToShow = oLayout[:bars_to_show]
	    nBarsStart = oLayout[:bars_start]
	    nBarsWidth = oLayout[:bars_end] - oLayout[:bars_start] + 1
	    nBarsStartRow = oLayout[:bars_start_row]
	    nBarsEndRow = nBarsStartRow + nBarsToShow - 1
	    
	    nAvgCol = nBarsStart
	    if @nMaxValue > 0
	        nAvgWidth = ceil(nBarsWidth * @nAverage / @nMaxValue)
	        nAvgCol = nBarsStart + nAvgWidth - 1
	    ok
	    
	    for i = nBarsStartRow to nBarsEndRow
	        if @acCanvas[i][nAvgCol] = " "
	            _setChar(i, nAvgCol, "|")
	        ok
	    next
	    
	    if oLayout[:annotation_row] > 0
	        cAvgValue = "avg: " + RoundN(@nAverage, 1)
	        nAvgValueStartCol = nAvgCol + 2
	        nLen = len(cAvgValue)
	        for j = 1 to nLen
	            _setChar(oLayout[:annotation_row], nAvgValueStartCol + j - 1, cAvgValue[j])
	        next
	    ok
