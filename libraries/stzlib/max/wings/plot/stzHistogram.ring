#-------------------------#
#  HISTOGRAM PLOT CLASS  #
#-------------------------#

class stzHistogram

	@bShowVAxis = True      # Vertical axis (was Y-axis)
	@bShowHAxis = True      # Horizontal axis (was X-axis)
	@bShowLabels = True
	@bShowFrequency = False
	@bShowPercent = False
	@bShowStats = False  # Show mean, std dev, etc.

	@nBinCount = 0       # Number of bins (0 = auto-calculate)
	@nBinRange = 0       # Width of each bin (0 = auto-calculate)
	@nBarWidth = 2
	@nMaxWidth = 132
	@nMaxLabelWidth = 12
	@nBarInterSpace = 1
	@nLabelInterSpace = 1

	@cBarChar = "█"
	@cFinalBarChar = ""

	# Histogram-specific data
	@aBinRanges = []     # [min, max] for each bin
	@aBinCounts = []     # Frequency count for each bin
	@aBinLabels = []     # Label for each bin (e.g., "20-30")
	@anRawData  = []      # Original data before binning
	@anValues   = []       # Processed values for display
	@acLabels   = []       # Processed labels for display

	# Display canvas and dimensions
	@acCanvas = []
	@nWidth = 0
	@nHeight = 10
	@nMinValue = 0
	@nMaxValue = 0

	# Layout constants
	@nVAxisWidth = 1     # Vertical axis width (was Y-axis)
	@nAxisPadding = 1
	@nLabelPadding = 1

	# Axis characters
	@cVAxisChar = "│"
	@cHAxisChar = "─"
	@cVArrowChar = "▲"
	@cHArrowChar = "►"
	@cOriginChar = "╰"
	@cAverageChar = "-"

	# Histogram aggregation types
	@cAggregationType = "frequency"  # frequency, sum, average, min, max
	@bShowValues = FALSE # General flag to control value display for any aggregation

	def init(paData)
		
		# For histogram, we expect a simple list of numbers (raw data)
		if CheckParams()
			if NOT isList(paData)
				StzRaise("Can't create stzHistogram! paData must be a list of numbers.")
			ok

			if NOT IsListOfNumbers(paData)
				StzRaise("Can't create stzHistogram! paData must contain only numbers.")
			ok
		ok

		@anRawData = paData
		_calculateBins()
		_processBinnedData()

	def _calculateBins()
		
		if len(@anRawData) = 0
			return
		ok

		@nMinValue = min(@anRawData)
		@nMaxValue = max(@anRawData)
		
		# Auto-calculate bin count using Sturges' rule if not set
		if @nBinCount = 0
			@nBinCount = max([5, ceil(1 + log(len(@anRawData)) / log(2))])
		ok
		
		# Calculate bin width
		nRange = @nMaxValue - @nMinValue
		if nRange = 0
			@nBinRange = 1
		else
			@nBinRange = nRange / @nBinCount
		ok

		# Create bin ranges
		@aBinRanges = []
		@aBinLabels = []
		
		for i = 1 to @nBinCount
			nBinMin = @nMinValue + (i-1) * @nBinRange
			nBinMax = @nMinValue + i * @nBinRange
			
			# Last bin includes the maximum value
			if i = @nBinCount
				nBinMax = @nMaxValue
			ok
			
			@aBinRanges + [nBinMin, nBinMax]
			
			# Create labels
			cLabel = StzNumberQ(nBinMin).CompactForm() + "-" + StzNumberQ(nBinMax).ToCompactForm()
			@aBinLabels + cLabel
		next

	def _findBinIndex(nValue)
		nLen = len(@aBinRanges)
		for i = 1 to nLen
			nMin = @aBinRanges[i][1]
			nMax = @aBinRanges[i][2]
			
			# Last bin includes maximum value
			if i = nLen
				if nValue >= nMin and nValue <= nMax
					return i
				ok
			else
				if nValue >= nMin and nValue < nMax
					return i
				ok
			ok
		next
		
		return 0  # Should not happen with valid data

	# Configuration methods
	def SetBinCount(n)
		if n > 0
			@nBinCount = n
			_calculateBins()
			_processBinnedData()
		ok

		def SetBarCount(n)
			This.SetBinCount(n)

		def SetClassCount(n)
			This.SetBinCount(n)

		def DivideToNClasses(n)
			This.SetBinCount(n)

		def DivideToNGroups(n)
			This.SetBinCount(n)

	def SetBinRange(n)
		if n > 0
			@nBinRange = n
			@nBinCount = ceil((@nMaxValue - @nMinValue) / n)
			_calculateBins()
			_processBinnedData()
		ok

		def SetClassRange(n)
			This.SetBinRange(n)

	def SetHeight(n) #TODO //n should be the number of positions in the bar
		@nHeight = n

	def SetValues(bShow)
		@bShowValues = bShow
	
		def IncludeValues()
			@bShowValues = TRUE

		def AddValues()
			@bShowValues = TRUE

		def WithoutValues()
			@bShowValues = FALSE

	def SetAggregation(cType)
		@cAggregationType = cType
		_processBinnedData()

	def AggregationType()
		return @cAggregationType

		def Aggregation()
			return @cAggregationType

	def AggregationTypes()
		return [ "frequency", "sum", "average", "min", "max" ]

	def UseFrequency()
		@cAggregationType = "frequency"
		_processBinnedData()

		def UseFreq()
			This.UseFrequency()

	def UseSum()
		@cAggregationType = "sum"
		_processBinnedData()

	def UseAverage()
		@cAggregationType = "average"
		_processBinnedData()

	def UseMin()
		@cAggregationType = "min"
		_processBinnedData()

	def UseMax()
		@cAggregationType = "max"
		_processBinnedData()

	def SetStats(bShow) # Displays a recap of stats line at the bottom
		@bShowStats = bShow

		def AddStats()
			@bShowStats = TRUE

		def IncludeStats()
			@bShowStats = TRUE

	# Vertical axis methods (with X aliases for compatibility)
	def SetVAxis(bShow)
		@bShowVAxis = bShow

		def AddVAxis()
			@bShowVAxis = TRUE

		def IncludeVAxis()
			@bShowVAxis = TRUE

		def WithoutVAxis()
			@bShowVAxis = FALSE

		# X-axis aliases for backward compatibility
		def SetXAxis(bShow)
			This.SetVAxis(bShow)

		def AddXAxis()
			This.AddVAxis()

		def IncludeXAxis()
			This.IncludeVAxis()

		def WithoutXAxis()
			This.WithoutVAxis()

	# Horizontal axis methods (with Y aliases for compatibility)
	def SetHAxis(bShow)
		@bShowHAxis = bShow

		def AddHAxis()
			@bShowHAxis = TRUE

		def IncludeHAxis()
			@bShowHAxis = TRUE

		def WithoutHAxis()
			@bShowHAxis = FALSE

		# Y-axis aliases for backward compatibility
		def SetYAxis(bShow)
			This.SetHAxis(bShow)

		def AddYAxis()
			This.AddHAxis()

		def IncludeYAxis()
			This.IncludeHAxis()

		def WithoutYAxis()
			This.WithoutHAxis()

	def SetLabels(bShow)
		@bShowLabels = bShow

		def AddLabels()
			@bShowLabels = TRUE

		def IncludeLabels()
			@bShowLabels = TRUE

		def WithoutLabels()
			@bShowLabels = FALSE

	def SetPercent(bShow)
		@bShowPercent = bShow

		def AddPercent()
			@bShowPercent = TRUE

		def IncludePercent()
			@bShowPercent = TRUE

	def SetBarWidth(nWidth)
		@nBarWidth = max([1, nWidth])

	def SetMaxWidth(nWidth)
		@nMaxWidth = nWidth

	def SetBarInterSpace(n)
		@nBarInterSpace = n  # 0 = auto-calculate, >0 = fixed spacing

	def SetBarChar(c)
		if CheckParams()
			if not IsChar(c)
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok
		@cBarChar = c

	def SetFinalBarChar(c)
		if CheckParams()
			if not IsChar(c)
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok
		@cFinalBarChar = c

		def SetTopBarChar(c)
			This.SetFinalBarChar(c)

	def SetLabelInterSpace(n)
	    @nLabelInterSpace = n

	# Statistical methods for histogram
	def Mean()
		nLen = len(@anRawData)

		if nLen = 0
			return 0
		ok

		nSum = 0

		for i = 1 to nLen
			nSum += @anRawData[i]
		next

		return nSum / nlen

	def StandardDeviation()
		nLen = len(@anRawData)

		if nLen <= 1
			return 0
		ok
		
		nMean = This.Mean()
		nSumSquares = 0
		
		for i = 1 to nLen
			nSumSquares += pow(@anRawData[i] - nMean, 2)
		next
		
		return sqrt(nSumSquares / (nLen - 1))

	def Median()
		nLen = len(@anRawData)
		if nLen = 0
			return 0
		ok
		
		aSorted = sort(@anRawData)
		
		if nLen % 2 = 1
			return aSorted[ceil(nLen/2)]

		else
			nMid1 = aSorted[nLen/2]
			nMid2 = aSorted[nLen/2 + 1]
			return (nMid1 + nMid2) / 2
		ok

	def Mode()
		# Find the bin with highest frequency
		nMaxFreq = max(@aBinCounts)
		nModeIndex = ring_find(@aBinCounts, nMaxFreq)
		
		if nModeIndex > 0
			return @aBinRanges[nModeIndex]
		else
			return [0, 0]
		ok

	def DataCount()
		return len(@anRawData)

		def DataSize()
			return This.DataCount()

		def Count()
			return This.DataCount()

	def _processBinnedData()

		# Initialize bin data based on aggregation type
		@aBinCounts = []
		
		for i = 1 to @nBinCount

			switch @cAggregationType
			on "frequency"
				@aBinCounts + 0

			on "sum"
				@aBinCounts + 0

			on "average"
				@aBinCounts + 0

			on "min"
				@aBinCounts + 0

			on "max"
				@aBinCounts + 0

			off
		next

		# Process each data point
		nLen = len(@anRawData)
		for i = 1 to nLen

			nBinIndex = _findBinIndex(@anRawData[i])

			if nBinIndex > 0

				switch @cAggregationType
				on "frequency"
					@aBinCounts[nBinIndex]++

				on "sum"
					@aBinCounts[nBinIndex] += @anRawData[i]

				on "average"
					# Store sum first, calculate average later
					@aBinCounts[nBinIndex] += @anRawData[i]

				on "min"
					if @aBinCounts[nBinIndex] = 0
						@aBinCounts[nBinIndex] = @anRawData[i]

					else
						@aBinCounts[nBinIndex] = min([@aBinCounts[nBinIndex], @anRawData[i]])
					ok

				on "max"
					@aBinCounts[nBinIndex] = max([@aBinCounts[nBinIndex], @anRawData[i]])

				off
			ok
		next
		
		# Post-process for average
		if @cAggregationType = "average"
			for i = 1 to @nBinCount
				nCount = _getFrequencyForBin(i)
				if nCount > 0
					@aBinCounts[i] = @aBinCounts[i] / nCount
				else
					@aBinCounts[i] = 0
				ok
			next
		ok
		
		# Set up processed data
		@anValues = @aBinCounts
		@acLabels = @aBinLabels
		@nMaxValue = max(@aBinCounts)
		@nMinValue = min(@aBinCounts)
	
	# Helper method to get frequency count for a bin (needed for average calculation)
	def _getFrequencyForBin(nBinIndex)

		nCount = 0
		nLen = len(@anRawData)

		for i = 1 to nLen
			if _findBinIndex(@anRawData[i]) = nBinIndex
				nCount++
			ok
		next

		return nCount

	# Canvas management methods
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
		nLen = len(@acCanvas)
		for i = 1 to nLen
			cLine = ""
			nLenCurrent = len(@acCanvas[i])
			for j = 1 to nLenCurrent
				cLine += @acCanvas[i][j]
			next
			# Trim trailing spaces
			while len(cLine) > 0 and right(cLine, 1) = " "
				cLine = left(cLine, len(cLine) - 1)
			end
			cResult += cLine + NL
		next
		
		# Remove final newline
		if len(cResult) > 0 and right(cResult, 1) = NL
			cResult = left(cResult, len(cResult) - 1)
		ok
		
		return cResult
	
	#--- DISPLAY

	def Show()
		? This.ToString()

	def ToString()
		
		# Use the same layout logic as bar chart
		oLayout = _calculateLayout()
		
		@nWidth = oLayout[:total_width]
		@nHeight = oLayout[:chart_height]
		_initCanvas()
		
		# Draw components
		if @bShowVAxis
			_drawVAxis(oLayout)
		ok
		
		if @bShowHAxis  
			_drawHAxis(oLayout)
		ok
		
		_drawBars(oLayout)
	
		if @bShowValues
			_drawValues(oLayout)
		but @bShowPercent
			_drawPercent(oLayout)
		ok
		
		if @bShowLabels
			_drawLabels(oLayout)
		ok
		
		cResult = _finalizeCanvas()

		# A hack to remove an unnecessary empty line from the top
		if @bShowHAxis = FALSE

			oStrTemp = new stzString(cResult)
			nPos = oStrTemp.FindFirst(NL)
			oStrTemp.RemoveSection(1, nPos)
			cResult = oStrTemp.Content()
		ok

		# A hack to add an empty at the top of the H Axis

		if ring_substr1(cResult, @cVArrowChar) > 0

			oStrTemp = new stzString(cResult)
			nPos = oStrTemp.FindNth(1, NL)
			bFirstLineIsEmpty = @trim(oStrTemp.Section(4, nPos-1)) = ""

			if NOT bFirstLineIsEmpty # then add an empty line
				cResult = ring_substr2(cResult, @cVArrowChar, @cVAxisChar)
				cResult = @cVArrowChar + NL + cResult
			ok

		ok

		# Add statistics if requested
		if @bShowStats

			cStats = NL + NL +
				"Mean:   " + RoundN(This.Mean(), 2) + NL +
			    "StdDev: " + RoundN(This.StandardDeviation(), 2) + NL +
			    "Median: " + RoundN(This.Median(), 2) + NL +
			    "Count:  " + This.DataCount()

			cResult += cStats
		ok
	
		return cResult

	def _calculateLayout()
		# Calculate layout for histogram display
		nBars = len(@anValues)
		oLayout = new stzHashList([])
		
		# First calculate all element widths
		aElementWidths = []
		nSum = This.DataCount()  # Total data points for percentage
		
		for i = 1 to nBars
		    nBarWidth = @nBarWidth
		    nLabelWidth = 0
		    nValueWidth = 0
		    
		    if @bShowLabels and i <= len(@acLabels)
		        # Calculate width for two-line labels (use the longer of the two values)
		        cLabel1 = "" + RoundN(@aBinRanges[i][1], 1)
		        cLabel2 = "" + RoundN(@aBinRanges[i][2], 1)
		        nLabelWidth = max([len(cLabel1), len(cLabel2)])
		        if nLabelWidth > @nMaxLabelWidth
		            nLabelWidth = @nMaxLabelWidth
		        ok
		    ok
		    
		    if @bShowFrequency
		        nValueWidth = len("" + @anValues[i])
		    but @bShowPercent
		        cPercent = RoundN((@anValues[i]/nSum)*100, 1)
		        nValueWidth = len("" + cPercent + '%')
		    ok
		    
		    # Use bar width as minimum, but allow labels to determine spacing
		    nElementWidth = max([nBarWidth, nLabelWidth, nValueWidth])
		    aElementWidths + nElementWidth
		next
		
		# Then calculate bar spacing using the calculated element widths
		aBarSpacing = []
		for i = 1 to nBars - 1
		    aBarSpacing + (@nBarInterSpace + @nLabelInterSpace)
		next
		
		nBarsAreaWidth = 0
		nLen = len(aElementWidths)
		for i = 1 to nLen
			nBarsAreaWidth += aElementWidths[i]
		next

		nLen = len(aBarSpacing)
		for i = 1 to nLen
			nBarsAreaWidth += aBarSpacing[i]
		next
		
		nVAxisStart = 1
		nVAxisEnd = nVAxisStart + @nVAxisWidth - 1
		
		nBarsStart = nVAxisEnd + 1
		if @bShowVAxis
			nBarsStart += @nAxisPadding
		ok
		
		nBarsEnd = nBarsStart + nBarsAreaWidth - 1
		nHAxisStart = nVAxisStart
		if @bShowVAxis
			nHAxisStart = nVAxisEnd + @nAxisPadding
		ok
		nHAxisEnd = nBarsEnd + @nAxisPadding
		nTotalWidth = nHAxisEnd + 1
		
		if nTotalWidth > @nMaxWidth
			StzRaise("Histogram width (" + nTotalWidth + ") exceeds maximum (" + @nMaxWidth + ")")
		ok
		
		# Estimate initial height for calculation
		nEstimatedHeight = @nHeight
		if nEstimatedHeight = 0
			nEstimatedHeight = 20  # Default estimate
		ok
		
		# Calculate chart height based on requirements
		if @bShowLabels
			nPlotHeight = nEstimatedHeight + 1  # Add one more row for two-line labels
			nHAxisRow = nEstimatedHeight - 1
			nLabelsRow = nEstimatedHeight + 1
		else
			nPlotHeight = nEstimatedHeight
			nHAxisRow = nEstimatedHeight - 1  
			nLabelsRow = nEstimatedHeight
		ok
		
		# Calculate bars area height
		nBarsAreaHeight = nHAxisRow - 1
		if @bShowValues or @bShowPercent
			nBarsAreaHeight = nHAxisRow - 2
		ok
		
		# Now calculate required height based on actual bar heights
		nRequiredHeight = This._getRequiredHeight(nBarsAreaHeight)
		
		# Recalculate final positions with correct height
		if @bShowLabels
			nPlotHeight = nRequiredHeight + 1
			nHAxisRow = nRequiredHeight - 1
			nLabelsRow = nRequiredHeight + 1
		else
			nPlotHeight = nRequiredHeight
			nHAxisRow = nRequiredHeight - 1
			nLabelsRow = nRequiredHeight
		ok
		
		# Update @nHeight to match calculated height
		@nHeight = nPlotHeight
		
		# Recalculate bars area height with final positions
		nBarsAreaHeight = nHAxisRow - 1
		if @bShowValues or @bShowPercent
			nBarsAreaHeight = nHAxisRow - 2
		ok
		
		oLayout.AddPair([:v_axis_col, nVAxisStart])
		oLayout.AddPair([:bars_start_col, nBarsStart]) 
		oLayout.AddPair([:bars_end_col, nBarsEnd])
		oLayout.AddPair([:h_axis_start_col, nHAxisStart])
		oLayout.AddPair([:h_axis_end_col, nHAxisEnd])
		oLayout.AddPair([:h_axis_row, nHAxisRow])
		oLayout.AddPair([:labels_row, nLabelsRow])
		oLayout.AddPair([:chart_height, nPlotHeight])
		oLayout.AddPair([:bars_area_height, nBarsAreaHeight])
		oLayout.AddPair([:total_width, nTotalWidth])
		oLayout.AddPair([:element_widths, aElementWidths])
		oLayout.AddPair([:bar_spacing, aBarSpacing])
		
		return oLayout

	def _drawVAxis(oLayout)
		nAxisCol = oLayout[:v_axis_col]
		nAxisRow = oLayout[:h_axis_row]
		
		# Draw axis from row 2 to avoid overwriting arrow
		for i = 2 to nAxisRow - 1
			@acCanvas[i][nAxisCol] = @cVAxisChar
		next
		
		# Place arrow at the top (row 1)
		@acCanvas[1][nAxisCol] = @cVArrowChar

	def _drawHAxis(oLayout)
		nAxisRow = oLayout[:h_axis_row]
		nStartCol = oLayout[:h_axis_start_col]
		nEndCol = oLayout[:h_axis_end_col]
		nVAxisCol = oLayout[:v_axis_col]
		
		for i = nStartCol to nEndCol
			@acCanvas[nAxisRow][i] = @cHAxisChar
		next
		
		if @bShowVAxis
			@acCanvas[nAxisRow][nVAxisCol] = @cOriginChar
		ok
		
		@acCanvas[nAxisRow][nEndCol] = @cHArrowChar

	def _drawBars(oLayout)
		# Same logic as bar chart but with improved height calculation for histograms
		nBars = len(@anValues)
		nBarsStartCol = oLayout[:bars_start_col] 
		nAxisRow = oLayout[:h_axis_row]
		nBarsAreaHeight = oLayout[:bars_area_height]
		aElementWidths = oLayout[:element_widths]
		aBarSpacing = oLayout[:bar_spacing]
		
		nCurrentX = nBarsStartCol
		
		for i = 1 to nBars
			nElementWidth = aElementWidths[i]
			nVal = @anValues[i]  # This is frequency count
			
			# Improved height calculation for histograms
			if nVal = 0
				nBarHeight = 0
			else
				# Use 1:1 mapping if frequencies fit within available height
				if @nMaxValue <= nBarsAreaHeight
					nBarHeight = nVal  # Direct mapping: frequency 2 = height 2
				else
					# Only use proportional scaling when frequencies exceed available space
					nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
				ok
			ok
			
			nBarStartX = nCurrentX + floor((nElementWidth - @nBarWidth) / 2)

			if nBarHeight > 0
				for j = 1 to nBarHeight
					for k = 1 to @nBarWidth
						nCol = nBarStartX + k - 1
						nRow = nAxisRow - j
						if nCol <= @nWidth and nRow >= 1
							if j = nBarHeight and @cFinalBarChar != ""
								@acCanvas[nRow][nCol] = @cFinalBarChar
							else
								@acCanvas[nRow][nCol] = @cBarChar
							ok
						ok
					next
				next
			ok

			if i < nBars
				nCurrentX += nElementWidth + aBarSpacing[i]
			ok
		next

	# Helper method to calculate actual required height
	def _getRequiredHeight(nBarsAreaHeight)
		nMaxBarHeight = 0
		nLen = len(@anValues)
		for i = 1 to nLen
			nVal = @anValues[i]
			if nVal > 0
				if @nMaxValue <= nBarsAreaHeight
					nBarHeight = nVal
				else
					nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
				ok
				nMaxBarHeight = max([nMaxBarHeight, nBarHeight])
			ok
		next
		
		# Add space for values above bars + axis + labels
		nRequiredHeight = nMaxBarHeight + 2  # +1 for values above, +1 for axis
		if @bShowLabels
			nRequiredHeight += 2  # +2 for two-line labels
		ok
		
		return nRequiredHeight

	def _drawValues(oLayout)
		nBars = len(@anValues)
		nBarsStartCol = oLayout[:bars_start_col]
		nAxisRow = oLayout[:h_axis_row] 
		nBarsAreaHeight = oLayout[:bars_area_height]
		aElementWidths = oLayout[:element_widths]
		aBarSpacing = oLayout[:bar_spacing]
		
		nCurrentX = nBarsStartCol
		
		for i = 1 to nBars
			nElementWidth = aElementWidths[i]
			nVal = @anValues[i]
			
			# Use same height calculation as bars
			if nVal = 0
				nBarHeight = 0
			else
				if @nMaxValue <= nBarsAreaHeight
					nBarHeight = nVal
				else
					nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
				ok
			ok
			
			# Position value above the bar (one row above)
			nValueRow = nAxisRow - nBarHeight - 1
			if nValueRow < 1
				nValueRow = 1
			ok
			
			# Format value based on aggregation type
			switch @cAggregationType
			on "frequency"
			    cValue = "" + nVal
			on "sum"
			    nRounded = 0+ RoundN(nVal, 1)
			    cValue = iff(nRounded = floor(nRounded), ('' + floor(nRounded)), ("" + nRounded))
			on "average"
			    nRounded = 0+ RoundN(nVal, 2)
			    cValue = iff(nRounded = floor(nRounded), ('' + floor(nRounded)), ("" + nRounded))
			on "min"
			    nRounded = 0+ RoundN(nVal, 1)
			    cValue = iff(nRounded = floor(nRounded), ('' + floor(nRounded)), ("" + nRounded))
			on "max"
			    nRounded = 0+ RoundN(nVal, 1)
			    cValue = iff(nRounded = floor(nRounded), ('' + floor(nRounded)), ("" + nRounded))
			off
			
			nValueLen = len(cValue)
			nValueStartX = nCurrentX + floor((nElementWidth - nValueLen) / 2)
			
			for k = 1 to nValueLen
				nCol = nValueStartX + k - 1
				if nCol <= @nWidth and nCol >= 1 and nValueRow >= 1
					@acCanvas[nValueRow][nCol] = cValue[k]
				ok
			next
			
			if i < nBars
				nCurrentX += nElementWidth + aBarSpacing[i]
			ok
		next

	def _drawPercent(oLayout)
		nBars = len(@anValues)
		nBarsStartCol = oLayout[:bars_start_col]
		nAxisRow = oLayout[:h_axis_row] 
		nBarsAreaHeight = oLayout[:bars_area_height]
		aElementWidths = oLayout[:element_widths]
		aBarSpacing = oLayout[:bar_spacing]
		
		nTotalCount = This.DataCount()
		nCurrentX = nBarsStartCol
		
		for i = 1 to nBars
			nElementWidth = aElementWidths[i]
			nVal = @anValues[i]
			
			# Use same height calculation as bars
			if nVal = 0
				nBarHeight = 0
			else
				if @nMaxValue <= nBarsAreaHeight
					nBarHeight = nVal
				else
					nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
				ok
			ok
			
			# Position percentage above the bar (one row above)
			nValueRow = nAxisRow - nBarHeight - 1
			if nValueRow < 1
				nValueRow = 1
			ok
			
			# Calculate percentage based on frequency, not scaled bar height
			nPercent = 0+ RoundN((nVal/nTotalCount)*100, 1)
			if nPercent = floor(nPercent)
			    cValue = "" + floor(nPercent) + '%'
			else
			    cValue = "" + nPercent + '%'
			ok
			
			nValueLen = len(cValue)
			nValueStartX = nCurrentX + floor((nElementWidth - nValueLen) / 2)
			
			for k = 1 to nValueLen
				nCol = nValueStartX + k - 1
				if nCol <= @nWidth and nCol >= 1 and nValueRow >= 1
					@acCanvas[nValueRow][nCol] = cValue[k]
				ok
			next
			
			if i < nBars
				nCurrentX += nElementWidth + aBarSpacing[i]
			ok
		next


	def _drawLabels(oLayout)
		# Draw bin range labels in two rows
		nBars = len(@anValues)
		nBarsStartCol = oLayout[:bars_start_col]
		nLabelsRow = oLayout[:labels_row]
		aElementWidths = oLayout[:element_widths]
		aBarSpacing = oLayout[:bar_spacing]
	
		nCurrentX = nBarsStartCol
		nLenCanvas = len(@acCanvas)
	
		for i = 1 to nBars
			if i <= len(@aBinRanges)
				nElementWidth = aElementWidths[i]
				
				# First row: start values
				//cLabel1 = "" + RoundN(@aBinRanges[i][1], 1)
				cLabel1 = StzNumberQ(@aBinRanges[i][1]).ToCompactForm()
				nLenLabel1 = len(cLabel1)
				nLabelStartX1 = nCurrentX + floor((nElementWidth - nLenLabel1) / 2)
	
				for j = 1 to nLenLabel1
					nCol = nLabelStartX1 + j - 1
					if nCol <= @nWidth and (nLabelsRow - 1) <= nLenCanvas
						@acCanvas[nLabelsRow - 1][nCol] = cLabel1[j]
					ok
				next
	
				# Second row: end values  
				//cLabel2 = "" + RoundN(@aBinRanges[i][2], 1)
				cLabel2 = StzNumberQ(@aBinRanges[i][2]).CompactForm()
				nLenLabel2 = len(cLabel2)
				nLabelStartX2 = nCurrentX + floor((nElementWidth - nLenLabel2) / 2)
	
				for j = 1 to nLenLabel2
					nCol = nLabelStartX2 + j - 1
					if nCol <= @nWidth and nLabelsRow <= nLenCanvas
						@acCanvas[nLabelsRow][nCol] = cLabel2[j]
					ok
				next
			ok
	
			if i < nBars
				nCurrentX += aElementWidths[i] + aBarSpacing[i]
			ok
		next
