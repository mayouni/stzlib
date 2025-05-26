/*
A class for ascii-based charts, working with stzTable and stzPivotTable

Get inspiration from:
https://www.bloomberg.com/graphics/year-ahead-2016/
https://github.com/alincoop/obsidian-tinychart
https://github.com/madnight/bitcoin-chart-cli


^         ╭╮                                     
│        ╭╯╰╮                                    
│        │  ╰╮         
│       ╭╯   ╰────╮
│    ╭──╯         ╰╮   
│   ╭╯             ╰──╮    
│ ──╯                 ╰──────    
╰─────────────────────────────>

# Softanza Chart System Design

## Core Philosophy

The Softanza Chart System is designed to create expressive ASCII-based visualizations that are:
1. **Purpose-driven** - Charts are categorized by analytical intent: comparison, relation, composition, distribution
2. **Modular** - Easy to extend with new chart types via inheritance
3. **Clean yet expressive** - Modern ASCII design that conveys information clearly
4. **Insightful** - Provides automatic insights and suggestions for further exploration

## System Architecture

stzChart (Abstract Base Class)
├── stzComparisonChart
│   ├── stzBarChart
│   ├── stzColumnChart
│   └── stzRadarChart
├── stzRelationChart
│   ├── stzScatterChart
│   ├── stzLineChart
│   └── stzHeatMapChart
├── stzCompositionChart
│   ├── stzPieChart
│   ├── stzTreeMapChart
│   └── stzStackedChart
└── stzDistributionChart
    ├── stzHistogramChart
    ├── stzBoxPlotChart
    └── stzAreaChart

TODO: Learn from IBM offering for data anlytics to empower
Softanza designs and data analytics experience for entreprise
https://dataplatform.cloud.ibm.com/docs/content/wsj/getting-started/welcome-main.html
*/

#----------------------------#
#  ABSTRACT BAR CHART CLASS  #
#----------------------------#

class stzChart

	@anValues = []
	@acLabels = []
	@acCanvas = []

	@nWidth = 40
	@nHeight = 10
	@nMaxValue = 0
	@nMinValue = 0

	# 	@cBarChar = "█" ~> Defined by subclasses
	@cXAxisChar = "│"
	@cYAxisChar = "─"
	@cXArrowChar = "^"
	@cYArrowChar = ">"
	@cOriginChar = "╰"
	@cAverageChar = "-"


	def init(paDataSet)

		# It must be a list of numbers or a hashlist where
		# the values are all numbers

		if CheckParams()

			if NOT isList(paDataSet)
				StzRaise("Can't create the stzChart object! paDataSet must be a list.")
			ok

			# In case a list of numbers is provided (the dataset
			# contains no labels ~> Added automatically as :1, :2, etc.

			if IsListOfNumbers(paDataSet)

				aTemp = []
				nLen = len(paDataSet)

				for i = 1 to nLen
					aTemp + [ ""+i, paDataSet[i] ]
				next

				paDataSet = aTemp
			ok
		ok

		# Forming the object container attributes from the hashlist

		oHash = new stzHashList(paDataSet)
		@anValues = oHash.Values()

		if NOT IsListOfNumbers(@anValues)
			StzRaise("Incorrect param value! The values in paDataSet must be numbers.")
		ok

		@acLabels = oHash.Keys()
		_calculateRange()


	def SetSize(nWidth, nHeight)

		if CheckParams()
			if NOT (isNumber(nWidth) and isNumber(nHeight))
				StzRaise("Incorrect param type! nWidth and nHeight must be both numbers.")
			ok
		ok

		@nWidth = nWidth
		@nHeight = nHeight

		def SetDimensions(nWidth, nHeight)
			This.SetSize(nWidth, nHeight)


	def SetWidth(n)

		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be number.")
			ok
		ok

		@nWidth = n


	def SetHight(n)

		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be number.")
			ok
		ok

		@nHight = n

		def SetHeight(n)
			This.SetHight(n)


	def SetBarChar(c)
		if CheckParams()
			if NOT (isString(c) and IsChar(c))
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		@cBarChar = c

		def BarChar()
			return @cBarChar

	def SetXAxisChar(c)
		if CheckParams()
			if NOT (isString(c) and IsChar(c))
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		@cXAxisChar = c

		def XAxisChar()
			return @cXAxisChar

	def SetYAxisChar(c)
		if CheckParams()
			if NOT (isString(c) and IsChar(c))
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		@cYAxisChar = c

		def YAxisChar()
			return @cYAxisChar

	def SetXArrowChar(c)
		if CheckParams()
			if NOT (isString(c) and IsChar(c))
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		@cXArrowChar = c

		def XArrowChar()
			return @cXArrowChar

	def SetYArrowChar(c)
		if CheckParams()
			if NOT (isString(c) and IsChar(c))
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		@cYArrowChar = c

		def YArrowChar()
			return @cYArrowChar

	def SetOriginChar(c)
		if CheckParams()
			if NOT (isString(c) and IsChar(c))
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		@cOringinChar = c

		def OriginChar()
			return @cOriginChar

	def SetAverageChar(c)
		if CheckParams()
			if NOT (isString(c) and IsChar(c))
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		@cAverageChar = c

		def AverageChar()
			return @cAverageChar


	def _calculateRange()

		@nMaxValue = max(@anValues)
		@nMinValue = min(@anValues)


	def _initCanvas()

		@acCanvas = []
		aTempSpaces = []

		for i = 1 to @nWidth-1
			aTempSpaces + " "
		next

		for i = 1 to @nHeight
			@acCanvas + aTempSpaces
		next


	def _finalizeCanvas()

		cResult = ""
		nLen = len(@acCanvas)

		# Ignoring the trailing empty lines

		nLen--
		if @bSetLabels = FALSE
			nLen--
		ok

		# Finalizing the canvas

		for i = 1 to nLen

			cLine = ""
			nLenCurrent = len(@acCanvas[i])

			for j = 1 to nLenCurrent
				cLine += @acCanvas[i][j]
			next

			cResult += cLine + nl
		next

		return cResult


	def Values()
		return @anValues

	def Labels()
		return @acLabels


#------------------------------#
#  CLEAN VERTICAL BAR CHART    #
#------------------------------#

class stzVBarChart from stzChart

	@bSetXAxis = True
	@bSetYAxis = True
	@bSetLabels = True
	@bSetAverageLine = False
	@bShowValues = False

	@nBarWidth = 2
	@nMaxWidth = 132
	@nBarInterSpace = 1

	@cBarChar = "█"

	# Layout constants for consistent spacing
	@nYAxisWidth = 1        # Width of Y-axis column
	@nAxisPadding = 1       # Space between Y-axis and bars
	@nLabelPadding = 1      # Space between bars and labels


	def init(paData)
		super.init(paData)


	def SetXAxis(bShow)
		@bSetXAxis = bShow

		def SetHAxis(bShow)
			@bSetXAxis = bShow

	def SetYAxis(bShow)
		@bSetYAxis = bShow

		def SetVAxis(bShow)
			@bSetYAxis = bShow

	def SetXYAxis(bShow)
		if isList(bShow) and len(bShow) = 2
			@bSetXAxis = bShow[1]
			@bSetYAxis = bShow[2]
		else
			@bSetXAxis = bShow
			@bSetYAxis = bShow
		ok

	def SetYLabels(bShow)
		@bSetLabels = bShow

		def SetLabels(bShow)
			This.SetYLabels(bShow)

		def AddYLabels()
			This.SetYLabels(_TRUE_)

		def AddLabels()
			This.SetYLabels(_TRUE_)

		def SetVLabels(bShow)
			This.SetYLabels(_TRUE_)

		def AddVLabels()
			This.SetYLabels(_TRUE_)

	def SetAverageLine(bShow)
		@bSetAverageLine = bShow

	def SetValues(bShow)
		@bShowValues = bShow

	def AddValues()
		This.SetValues(_TRUE_)

	def SetBarWidth(nWidth)
		@nBarWidth = max([1, nWidth])

	def SetMaxWidth(nWidth)
		@nMaxWidth = nWidth

	def SetBarChar(c)
		if CheckParams()
			if not IsChar(c)
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok
		@cBarChar = c


	def SetYXAxis(bShow)

		if isList(bShow) and IsPairOfNumbers(bShow)
			@bSetYAxis = bShow[1]
			@bSetXAxis = bShow[2]
			return
		ok

		@bSetXAxis = bShow
		@bSetYAxis = bShow

		def SetVHAxis(bShow)
			This.SetYXAxis(bShow)

		def SetHVAxis(bShow)
			This.SetXYAxis(bShow)

	def Show()
		? This.ToString()


	def ToString()
		
		# Step 1: Calculate layout dimensions
		oLayout = _calculateLayout()
		
		# Step 2: Initialize canvas with exact dimensions
		@nWidth = oLayout[:total_width]
		@nHeight = oLayout[:chart_height]
		_initCanvas()
		
		# Step 3: Draw components in order
		if @bSetYAxis
			_drawYAxis(oLayout)
		ok
		
		if @bSetXAxis  
			_drawXAxis(oLayout)
		ok
		
		_drawBars(oLayout)
		
		if @bShowValues
			_drawValues(oLayout)
		ok
		
		if @bSetLabels
			_drawXLabels(oLayout)
		ok
		
		if @bSetAverageLine
			_drawAverageLine(oLayout)
		ok
		
		return _finalizeCanvas()


	def _calculateLayout()
		
		nBars = len(@anValues)
		oLayout = new stzHashList([])
		
		# Calculate bar spacing
		aBarSpacing = []
		for i = 1 to nBars - 1
			aBarSpacing + @nBarInterSpace
		next
		
		# Calculate element widths (bar or label, whichever is wider)
		aElementWidths = []
		for i = 1 to nBars
			nBarWidth = @nBarWidth
			nLabelWidth = 0
			
			if @bSetLabels and i <= len(@acLabels)
				nLabelWidth = len(@acLabels[i])
			ok
			
			nElementWidth = max([nBarWidth, nLabelWidth])
			aElementWidths + nElementWidth
		next
		
		# Calculate total bars area width
		nBarsAreaWidth = 0
		for i = 1 to len(aElementWidths)
			nBarsAreaWidth += aElementWidths[i]
		next
		for i = 1 to len(aBarSpacing)
			nBarsAreaWidth += aBarSpacing[i]
		next
		
		# Calculate layout positions
		nYAxisStart = 1
		nYAxisEnd = nYAxisStart + @nYAxisWidth - 1
		
		nBarsStart = nYAxisEnd + 1
		if @bSetYAxis
			nBarsStart += @nAxisPadding
		ok
		
		nBarsEnd = nBarsStart + nBarsAreaWidth - 1
		
		nXAxisStart = nYAxisStart
		if @bSetYAxis
			nXAxisStart = nYAxisEnd + @nAxisPadding
		ok
		nXAxisEnd = nBarsEnd + @nAxisPadding
		
		# Calculate total width
		nTotalWidth = nXAxisEnd + 1  # +1 for arrow
		
		# Validate against max width
		if nTotalWidth > @nMaxWidth
			StzRaise("Chart width (" + nTotalWidth + ") exceeds maximum (" + @nMaxWidth + ")")
		ok
		
		# Calculate height
		nChartHeight = @nHeight
		if @bSetLabels
			nChartHeight += 1  # Extra row for labels
		ok
		
		# Store layout information
		oLayout.AddPair([:y_axis_col, nYAxisStart])
		oLayout.AddPair([:bars_start_col, nBarsStart]) 
		oLayout.AddPair([:bars_end_col, nBarsEnd])
		oLayout.AddPair([:x_axis_start_col, nXAxisStart])
		oLayout.AddPair([:x_axis_end_col, nXAxisEnd])
		oLayout.AddPair([:x_axis_row, nChartHeight - 1])
		oLayout.AddPair([:labels_row, nChartHeight - 1])
		oLayout.AddPair([:chart_height, nChartHeight])
		oLayout.AddPair([:bars_area_height, nChartHeight - 3])  # Space for axes and labels
		oLayout.AddPair([:total_width, nTotalWidth])
		oLayout.AddPair([:element_widths, aElementWidths])
		oLayout.AddPair([:bar_spacing, aBarSpacing])
		
		return oLayout


	def _drawYAxis(oLayout)
		
		nAxisCol = oLayout[:y_axis_col]
		nAxisRow = oLayout[:x_axis_row]
		
		# Draw vertical line
		for i = 2 to nAxisRow - 1
			@acCanvas[i][nAxisCol] = @cXAxisChar
		next
		
		# Draw arrow at top
		@acCanvas[1][nAxisCol] = @cXArrowChar


	def _drawXAxis(oLayout)
		
		nAxisRow = oLayout[:x_axis_row]
		nStartCol = oLayout[:x_axis_start_col]
		nEndCol = oLayout[:x_axis_end_col]
		nYAxisCol = oLayout[:y_axis_col]
		
		# Draw horizontal line
		for i = nStartCol to nEndCol
			@acCanvas[nAxisRow][i] = @cYAxisChar
		next
		
		# Draw origin if Y-axis is present
		if @bSetYAxis
			@acCanvas[nAxisRow][nYAxisCol] = @cOriginChar
		ok
		
		# Draw arrow at end

		@acCanvas[nAxisRow][nEndCol] = @cYArrowChar


	def _drawBars(oLayout)
		
		nBars = len(@anValues)
		nBarsStartCol = oLayout[:bars_start_col] 
		nAxisRow = oLayout[:x_axis_row]
		nBarsAreaHeight = oLayout[:bars_area_height]
		aElementWidths = oLayout[:element_widths]
		aBarSpacing = oLayout[:bar_spacing]
		
		nCurrentX = nBarsStartCol
		
		for i = 1 to nBars
			
			nElementWidth = aElementWidths[i]
			nVal = @anValues[i]
			
			# Calculate bar height
			if @nMaxValue = 0
				nBarHeight = 1
			else
				nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
			ok
			
			# Calculate bar position within element
			nBarStartX = nCurrentX + floor((nElementWidth - @nBarWidth) / 2)
			
			# Draw bar
			for j = 1 to nBarHeight
				for k = 1 to @nBarWidth
					nCol = nBarStartX + k - 1
					nRow = nAxisRow - j
					if nCol <= @nWidth and nRow >= 1
						@acCanvas[nRow][nCol] = @cBarChar
					ok
				next
			next
			
			# Move to next position
			if i < nBars
				nCurrentX += nElementWidth + aBarSpacing[i]
			ok
		next


	def _drawValues(oLayout)
		
		nBars = len(@anValues)
		nBarsStartCol = oLayout[:bars_start_col]
		nAxisRow = oLayout[:x_axis_row] 
		nBarsAreaHeight = oLayout[:bars_area_height]
		aElementWidths = oLayout[:element_widths]
		aBarSpacing = oLayout[:bar_spacing]
		
		nCurrentX = nBarsStartCol
		
		for i = 1 to nBars
			
			nElementWidth = aElementWidths[i]
			nVal = @anValues[i]
			
			# Calculate bar height (same logic as _drawBars)
			if @nMaxValue = 0
				nBarHeight = 1
			else
				nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
			ok
			
			# Calculate bar position
			nBarStartX = nCurrentX + floor((nElementWidth - @nBarWidth) / 2)
			
			# Calculate value position (above bar)
			nValueRow = nAxisRow - nBarHeight - 1
			if nValueRow < 1
				nValueRow = 1
			ok
			
			cValue = "" + nVal
			nValueLen = len(cValue)
			nValueStartX = nBarStartX + floor((@nBarWidth - nValueLen) / 2)
			
			# Draw value
			for k = 1 to nValueLen
				nCol = nValueStartX + k - 1
				if nCol <= @nWidth and nCol >= 1
					@acCanvas[nValueRow][nCol] = cValue[k]
				ok
			next
			
			# Move to next position
			if i < nBars
				nCurrentX += nElementWidth + aBarSpacing[i]
			ok
		next


	def _drawXLabels(oLayout)
		
		nBars = len(@anValues)
		nBarsStartCol = oLayout[:bars_start_col]
		nLabelsRow = oLayout[:labels_row]
		aElementWidths = oLayout[:element_widths]
		aBarSpacing = oLayout[:bar_spacing]
		
		nCurrentX = nBarsStartCol
		nLenCanvas = len(@acCanvas)

		for i = 1 to nBars
			
			if i <= len(@acLabels)
				
				nElementWidth = aElementWidths[i]
				cLabel = Capitalize(@acLabels[i])
				nLabelLen = len(cLabel)
				
				# Center label within element width
				nLabelStartX = nCurrentX + floor((nElementWidth - nLabelLen) / 2)


				# Draw label
				for j = 1 to nLabelLen
				    nCol = nLabelStartX + j - 1
				    if nCol <= @nWidth and nLabelsRow <= nLenCanvas
				        @acCanvas[nLabelsRow][nCol] = cLabel[j]
				    ok
				next
			ok
			
			# Move to next position
			if i < nBars
				nCurrentX += aElementWidths[i] + aBarSpacing[i]
			ok
		next


	def _drawAverageLine(oLayout)
		
		# Calculate average
		nSum = 0
		for i = 1 to len(@anValues)
			nSum += @anValues[i]
		next
		nAvg = nSum / len(@anValues)
		
		nBarsStartCol = oLayout[:bars_start_col]
		nBarsEndCol = oLayout[:bars_end_col] 
		nAxisRow = oLayout[:x_axis_row]
		nBarsAreaHeight = oLayout[:bars_area_height]
		
		# Calculate average line position
		if @nMaxValue = 0
			nAvgRow = nAxisRow - 1
		else
			nAvgRow = nAxisRow - ceil(nBarsAreaHeight * nAvg / @nMaxValue)
		ok
		
		# Draw average line
		for i = nBarsStartCol to nBarsEndCol
			if @acCanvas[nAvgRow][i] != @cBarChar
				@acCanvas[nAvgRow][i] = @cAverageChar
			ok
		next

#------------------------------#
#  HORIZONTAL BAR CHART CLASS  #
#------------------------------#

class stzHBarChart from stzChart

	@bSetXAxis = True
	@bSetYAxis = True
	@bSetLabels = True

	@bShowValues = False
	@nBarHeight = 1
	@nBarInterSpace = 0
	@nMaxLabelWidth = 12
	@nLeftPadding = 0

	@cBarChar = "▇"

	@nLargestBarWidth = 0
	@nLargestLabelWidth = 0


	def init(paData)
		super.init(paData)


	def SetXAxis(bShow)
		@bSetXAxis = bShow

		def SetHAxis(bShow)
			@bSetXAxis = bShow


	def SetYAxis(bShow)
		@bSetYAxis = bShow

		def SetVAxis(bShow)
			@bSetYAxis = bShow


	def SetXYAxis(bShow)

		if isList(bShow) and IsPairOfNumbers(bShow)
			@bSetXAxis = bShow[1]
			@bSetYAxis = bShow[2]
			return
		ok
		@bSetXAxis = bShow
		@bSetYAxis = bShow

		def SetHVAxis(bShow)
			This.SetXYAxis(bShow)


	def SetYXAxis(bShow)

		if isList(bShow) and IsPairOfNumbers(bShow)
			@bSetYAxis = bShow[1]
			@bSetXAxis = bShow[2]
			return
		ok

		@bSetXAxis = bShow
		@bSetYAxis = bShow

		def SetVHAxis(bShow)
			This.SetYXAxis(bShow)


	def SetXLabels(bShow)
		@bSetLabels = bShow

		def SetLabels(bShow)
			@bSetLabels = bShow

		def SetVLabels(bShow)
			@bSetLabels = bShow

		def AddXLabels()
			This.SetXLabels(_TRUE_)

			def AddVLabels()
				This.SetXLabels(_TRUE_)

		def AddLabels()
			This.SetXLabels(_TRUE_)


	def SetValues(bShow)
		@bShowValues = bShow
		def AddValues()
			This.SetValues(_TRUE_)


	def SetBarHeight(nHeight)
		@nBarHeight = max([1, nHeight])


	def SetMaxLabelWidth(n)
		@nMaxLabelWidth = n


	def SetLabelWidth(nWidth)
		@nMaxLabelWidth = max([8, nWidth])


	def SetBarChar(c)

		if CheckParams()
			if not IsChar(c)
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		@cBarChar = c


	def Show()
		? This.ToString()


	def _initCanvas()

		@acCanvas = []

		# Create empty canvas

		for row = 1 to @nHeight
			aRow = []
			for col = 1 to @nWidth
				aRow + " "
			next
			@acCanvas + aRow
		next


	def LargestBarWidth()
		return @nLargestBarWidth


	def LargestLabelWidth()

		nLen = len(@acLabels)
		nLargest = len(@acLabels[1])

		if nLen = 1
			return nLArgest
		ok

		for i  = 2 to nLen
			nLenLabel = len(@acLabels[i])
			if nLenLabel  > nLargest
				nLargest = nLenLabel
			ok
		next

		return nLargest


	def _drawYAxis(nLabelAreaWidth)

		nAxisCol = nLabelAreaWidth + 2

		# Only draw if we have enough height and X-axis is enabled
		if @bSetXAxis

			# Vertical line

			for row = 2 to @nHeight - 2
				@acCanvas[row][nAxisCol] = @cYAxisChar
			next

			# Arrow at top only if Y-axis is enabled
			@acCanvas[1][nAxisCol] = @cYArrowChar

		ok


	def _drawXAxis(nLabelAreaWidth, nBarAreaWidth)

		nAxisRow = @nHeight - 1
		nStartCol = nLabelAreaWidth + 2
		
		# Use the LargestBarWidth() method to get actual largest bar width
		nLongestBarWidth = This.LargestBarWidth()
		
		# X-axis extends one character beyond the longest actual bar
		nEndCol = nStartCol + nLongestBarWidth + 1
	
		for col = nStartCol to min([nEndCol, @nWidth])
			@acCanvas[nAxisRow][col] = @cXAxisChar
		next
	
		# Only draw origin character if Y-axis is also enabled

		if @bSetYAxis
			@acCanvas[nAxisRow][nStartCol] = @cOriginChar
		ok

		if nEndCol + 1 <= @nWidth
			@acCanvas[nAxisRow][nEndCol + 1] = @cXArrowChar
		ok


	def _drawBars(nLabelAreaWidth, nBarAreaWidth)

		nBars = len(@anValues)
		nAxisCol = nLabelAreaWidth + 2
		nStartRow = 2
	
		# Draw each bar

		for i = 1 to nBars

			nBarRow = nStartRow + (i - 1)

			# Skip if row exceeds canvas

			if nBarRow >= @nHeight
				loop
			ok
			
			# Fixed calculation: Scale value relative to max value

			nVal = @anValues[i]

			if @nMaxValue = 0
				nBarWidth = 1
			else
				nBarWidth = max([1, ceil(nBarAreaWidth * nVal / @nMaxValue)])
			ok
	
			if nBarWidth > @nLargestBarWidth
				@nLargestBarWidth = nBarWidth + len(@@(@anValues[i])) + 1
			ok

			# Calculate bar start position - add space after Y axis when enabled

			nBarStartCol = nAxisCol + 1

			if @bSetYAxis
				nBarStartCol = nAxisCol + 2  # Add extra space after Y axis
			ok
			
			# Draw bar characters

			for w = 1 to nBarWidth

				nCol = nBarStartCol + w - 1

				if nCol <= @nWidth
					@acCanvas[nBarRow][nCol] = @cBarChar
				ok

			next

		next


	def _drawValues(nLabelAreaWidth, nBarAreaWidth)

		nBars = len(@anValues)
		nAxisCol = nLabelAreaWidth + 2

		# Adjust starting row based on axes

		nStartRow = 1

		if @bSetYAxis or @bSetXAxis
			nStartRow = 2
		ok

		for i = 1 to nBars

			nBarRow = nStartRow + (i - 1) * (@nBarHeight + @nBarInterSpace)

			# Skip if exceeds canvas (accounting for X-axis space)

			nMaxRow = @nHeight

			if @bSetXAxis
				nMaxRow = @nHeight - 1
			ok

			if nBarRow >= nMaxRow
				exit
			ok
			
			nVal = @anValues[i]
			
			# Fixed calculation to match _drawBars

			if @nMaxValue = 0
				nBarWidth = 1

			else
				nBarWidth = max([1, ceil(nBarAreaWidth * nVal / @nMaxValue)])
			ok
			
			cValue = "" + nVal
			nValueLen = len(cValue)
			
			# Calculate bar start column - add space after Y axis when enabled

			nBarStartCol = nAxisCol + 1

			if @bSetYAxis
				nBarStartCol = nAxisCol + 2  # Add extra space after Y axis
			ok
			
			# Calculate value position - exactly one space after bar end
			nValueCol = nBarStartCol + nBarWidth + 1
			
			# Ensure value fits within canvas width
			nRequiredWidth = nValueCol + nValueLen

			if nRequiredWidth > @nWidth

				# Expand canvas rows to accommodate larger width
				nOldWidth = @nWidth
				@nWidth = nRequiredWidth + 1

				# Extend existing rows

				nLenCanvas = len(@acCanvas)

				for row = 1 to nLenCanvas

					for col = nOldWidth + 1 to @nWidth
						@acCanvas[row] + " "
					next

				next

			ok
			
			# Draw value

			for j = 1 to nValueLen

				nCol = nValueCol + j - 1

				if nCol <= @nWidth and nCol > 0 and nBarRow < nMaxRow
					@acCanvas[nBarRow][nCol] = cValue[j]
				ok

			next

		next


	def ToString()

		# Temp flags I'll use to let the axies be generated
		# in any case, and then use those flags to retrieve
		# the FALSE axis by simple ring_substr()

		bTempSetXAxis = TRUE
		bTempSetYAxis = TRUE

		if @bSetXAxis = FALSE
			bTempSetXAxis = FALSE
			@bSetXAxis = TRUE
		ok

		if @bSetYAxis = FALSE
			bTempSetYAxis = FALSE
			@bSetYAxis = TRUE
		ok

		# Start of the processing

		nBars = len(@anValues)
		nActualLabelWidth = 0

		if @bSetLabels

			# Find the longest label

			for i = 1 to len(@acLabels)

				nLen = len(@acLabels[i])

				if nLen > nActualLabelWidth
					nActualLabelWidth = nLen
				ok

			next

			# Apply maximum width limit if label exceeds it

			if nActualLabelWidth > @nMaxLabelWidth
				nActualLabelWidth = @nMaxLabelWidth
			ok

			nActualLabelWidth += @nLeftPadding

		else
			nActualLabelWidth = 0

		ok

		# Use the calculated actual width
		nLabelAreaWidth = nActualLabelWidth
		
		# Calculate required width based on largest bar

		nMinRequiredWidth = nLabelAreaWidth + 4 + This.LargestBarWidth() + 1

		if @nWidth < nMinRequiredWidth
			@nWidth = nMinRequiredWidth
		ok
		
		# Calculate required height

		nRequiredHeight = nBars + 2

		if @bSetXAxis
			nRequiredHeight += 1
		ok

		# Set height to exactly what's needed

		@nHeight = nRequiredHeight
		This._initCanvas()
		
		# Calculate max bar width for X-axis length

		nRange = @nMaxValue - @nMinValue

		if nRange = 0
			nRange = 1
		ok

		nMaxBarWidth = @nWidth - nLabelAreaWidth - 4

		if @bSetYAxis
			nMaxBarWidth = @nWidth - nLabelAreaWidth - 5  # Extra space for Y axis
		ok

		nBarAreaWidth = nMaxBarWidth

		if @bSetYAxis
			This._drawYAxis(nLabelAreaWidth)
		ok

		# Draw bars BEFORE X-axis so LargestBarWidth() is populated

		This._drawBars(nLabelAreaWidth, nBarAreaWidth)

		if @bSetXAxis
			This._drawXAxis(nLabelAreaWidth, nBarAreaWidth)
		ok

		if @bShowValues
			This._drawValues(nLabelAreaWidth, nBarAreaWidth)
		ok

		if @bSetLabels
			This._drawLabels(nLabelAreaWidth)
		ok

		cResult = This._buildOutput()

		# A hack for true Y axis width (not so clean but works)

		if ring_substr1(cResult, "─>") > 0

			cResult += @copy(" ", This.LargestLabelWidth() + 1) +
				@cOriginChar + @copy("─", This.LargestBarWidth() + 1 + 5) + @cYArrowChar
		ok

		# Managing the axis display

		if bTempSetXAxis = FALSE
			cResult = ring_substr2(cResult, @cXArrowChar, "")
			cResult = ring_substr2(cResult, @cOriginChar, "")
			cResult = ring_substr2(cResult, @cYAxisChar, "")
			cResult = ring_substr2(cResult, @cYArrowChar, "")
		ok

		if bTempSetYAxis = FALSE
			cResult = ring_substr2(cResult, @cXArrowChar, "")
			cResult = ring_substr2(cResult, @cOriginChar, "")
			cResult = ring_substr2(cResult, @cXAxisChar, "")
		ok

		return cResult


	def _drawLabels(nLabelAreaWidth)

		nBars = len(@anValues)
		nStartRow = 2

		for i = 1 to nBars

			if i <= len(@acLabels)

				nBarRow = nStartRow + (i - 1)

				# Skip if row exceeds canvas height minus X-axis space

				if nBarRow >= @nHeight - 1
					exit
				ok

				cOriginalLabel = @acLabels[i]
				cLabel = Capitalize(cOriginalLabel)

				# Truncate label if it exceeds maximum width

				if len(cLabel) > @nMaxLabelWidth
					cLabel = StzStringQ(cLabel).Section(1, @nMaxLabelWidth - 2) + ".."
				ok

				nLabelLen = len(cLabel)

				# Right-align label within the actual label area

				nStartCol = nLabelAreaWidth - nLabelLen + 1

				if nStartCol < 1
					nStartCol = 1
				ok

				for j = 1 to nLabelLen

					nCol = nStartCol + j - 1

					if nCol <= nLabelAreaWidth and nBarRow < @nHeight
						@acCanvas[nBarRow][nCol] = cLabel[j]
					ok

				next

			ok
		next


	def _buildOutput()

		cResult = ""

		# Determine the last row to output

		nLastContentRow = min([@nHeight, len(@acCanvas)])

		if @bSetXAxis and nLastContentRow > 0
			nLastContentRow = min([nLastContentRow, @nHeight - 2])
		ok

		for row = 1 to nLastContentRow

			cLine = ""

			if row <= len(@acCanvas)

				nMaxCol = min([@nWidth, len(@acCanvas[row])])

				for col = 1 to nMaxCol
					cLine += @acCanvas[row][col]
				next
			ok

			# Remove trailing spaces for cleaner output

			cLine = rtrim(cLine)
			cResult += cLine + nl

		next

		return cResult
