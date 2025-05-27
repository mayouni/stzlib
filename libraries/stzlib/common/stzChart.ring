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
	@cYArrowChar = "─>"
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

		if NOT IsListOfPositiveNumbers(@anValues)
			StzRaise("Incorrect param value! You must privide only psoitive numbers.")
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

		# When labels are disabled, exclude the empty last row
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

			# Don't add newline after the last line
			if i < nLen
				cResult += cLine + nl
			else
				cResult += cLine
			ok
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
	@bShowPercent = False

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

		def SetAverage(bShow)
			@bSetAverageLine = bShow

		def AddAverage()
			@bSetAverageLine = _TRUE_

		def AddAverageLine()
			@bSetAverageLine = _TRUE_

	def SetValues(bShow)
		@bShowValues = bShow

	def AddValues()
		This.SetValues(_TRUE_)

	def SetPercent(bShow)
		@bShowPercent = bShow

		def SetPercentage(bShow)
			@bShowPercent = bShow

	def AddPercent()
		@bShowPercent = _TRUE_

		def AddPercentage()
			@bShowPercent = _TRUE_

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

		but @bShowPercent
			_drawPercent(oLayout)
		ok
		
		if @bSetLabels
			_drawXLabels(oLayout)
		ok
		
		if @bSetAverageLine
			_drawAverageLine(oLayout)
		ok
		
		cResult = _finalizeCanvas()

		# A hack to add a space at the top of the X Axis
		if ring_substr1(cResult, @cXArrowChar) > 0
			cResult = ring_substr2(cResult, @cXArrowChar, @cXAxisChar)
			cResult = @cXArrowChar + NL + cResult
		ok

		return cResult


	def _calculateLayout()
		
		nBars = len(@anValues)
		oLayout = new stzHashList([])
		
		# Calculate bar spacing
		aBarSpacing = []
		for i = 1 to nBars - 1
			aBarSpacing + @nBarInterSpace
		next
		
		# Calculate element widths (bar, label, or value - whichever is wider)
		aElementWidths = []
		nSum = Sum(@anValues)  # For percentage calculations
		
		for i = 1 to nBars
			nBarWidth = @nBarWidth
			nLabelWidth = 0
			nValueWidth = 0
			
			# Label width
			if @bSetLabels and i <= len(@acLabels)
				nLabelWidth = len(@acLabels[i])
			ok
			
			# Value width (if showing values or percentages)
			if @bShowValues
				nValueWidth = len("" + @anValues[i])
			but @bShowPercent
				nPercent = roundN((@anValues[i]/nSum)*100, 1)
				nValueWidth = len("" + nPercent + '%')
			ok
			
			# Element width is maximum of all components
			nElementWidth = max([nBarWidth, nLabelWidth, nValueWidth])
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
		
		# Calculate height and positions
		if @bSetLabels
			nChartHeight = @nHeight      # No extra height needed
			nXAxisRow = @nHeight - 1     # X-axis at height - 1
			nLabelsRow = @nHeight        # Labels on last row
		else
			nChartHeight = @nHeight
			nXAxisRow = @nHeight - 1     # X-axis at bottom
			nLabelsRow = @nHeight        # Not used when labels disabled
		ok
		
		# Store layout information
		oLayout.AddPair([:y_axis_col, nYAxisStart])
		oLayout.AddPair([:bars_start_col, nBarsStart]) 
		oLayout.AddPair([:bars_end_col, nBarsEnd])
		oLayout.AddPair([:x_axis_start_col, nXAxisStart])
		oLayout.AddPair([:x_axis_end_col, nXAxisEnd])
		oLayout.AddPair([:x_axis_row, nXAxisRow])
		oLayout.AddPair([:labels_row, nLabelsRow])
		oLayout.AddPair([:chart_height, nChartHeight])
		# Calculate bars area height - reserve top space for values if needed
		nBarsAreaHeight = nXAxisRow - 1
		if @bShowValues or @bShowPercent
			nBarsAreaHeight = nXAxisRow - 2  # Reserve top row for values
		ok
		
		oLayout.AddPair([:bars_area_height, nBarsAreaHeight])
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
		
		# Draw arfrow at top
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
			if @nMaxValue = 0 or nVal = 0
				nBarHeight = 0
			else
				nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
			ok
			
			# Calculate bar position within element
			nBarStartX = nCurrentX + floor((nElementWidth - @nBarWidth) / 2)
			
			# Draw bar
			if nBarHeight > 0

				for j = 1 to nBarHeight
					for k = 1 to @nBarWidth
						nCol = nBarStartX + k - 1
						nRow = nAxisRow - j
						if nCol <= @nWidth and nRow >= 1
							@acCanvas[nRow][nCol] = @cBarChar
						ok
					next
				next
			ok

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
			if @nMaxValue = 0 or nVal = 0
				nBarHeight = 1
			else
				nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
			ok
			
			# Calculate value position (above bar)
			nValueRow = nAxisRow - nBarHeight - 1
			if nValueRow < 1
				nValueRow = 1
			ok
			
			# If value position conflicts with bar, move it above
			if nValueRow >= nAxisRow - nBarHeight
				nValueRow = max([1, nAxisRow - nBarHeight - 1])
			ok
			
			cValue = "" + nVal
			nValueLen = len(cValue)
			
			# Center within element width (same logic as _drawXLabels)
			nValueStartX = nCurrentX + floor((nElementWidth - nValueLen) / 2)
			
			# Draw value with bounds checking
			for k = 1 to nValueLen
				nCol = nValueStartX + k - 1
				if nCol <= @nWidth and nCol >= 1 and nValueRow >= 1
					@acCanvas[nValueRow][nCol] = cValue[k]
				ok
			next
			
			# Move to next position (same logic as other drawing methods)
			if i < nBars
				nCurrentX += nElementWidth + aBarSpacing[i]
			ok
		next


	def _drawPercent(oLayout)
		
		nBars = len(@anValues)
		nBarsStartCol = oLayout[:bars_start_col]
		nAxisRow = oLayout[:x_axis_row] 
		nBarsAreaHeight = oLayout[:bars_area_height]
		aElementWidths = oLayout[:element_widths]
		aBarSpacing = oLayout[:bar_spacing]
		
		nCurrentX = nBarsStartCol
		nSum = Sum(@anValues)
	
		for i = 1 to nBars
			
			nElementWidth = aElementWidths[i]
			nVal = @anValues[i]
			
			# Calculate bar height (same logic as _drawBars)
			if @nMaxValue = 0 or nVal = 0
				nBarHeight = 1
			else
				nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
			ok
			
			# Calculate value position (above bar)
			nValueRow = nAxisRow - nBarHeight - 1
			if nValueRow < 1
				nValueRow = 1
			ok
			
			# If value position conflicts with bar, move it above
			if nValueRow >= nAxisRow - nBarHeight
				nValueRow = max([1, nAxisRow - nBarHeight - 1])
			ok
			
			# Format percentage with 1 decimal place
			nPercent = RoundN((nVal/nSum)*100, 1)
			cValue = "" + nPercent + '%'
	
			nValueLen = len(cValue)
			
			# Center within element width (same logic as _drawXLabels)
			nValueStartX = nCurrentX + floor((nElementWidth - nValueLen) / 2)
			
			# Draw value with bounds checking
			for k = 1 to nValueLen
				nCol = nValueStartX + k - 1
				if nCol <= @nWidth and nCol >= 1 and nValueRow >= 1
					@acCanvas[nValueRow][nCol] = cValue[k]
				ok
			next
			
			# Move to next position (same logic as other drawing methods)
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
		
		cResult = _finalizeCanvas()
		return cResult

	def _calculateLayout()
		
		nBars = len(@anValues)
		oLayout = new stzHashList([])
		
		# Calculate label area width
		nLabelAreaWidth = 0
		if @bSetLabels
			# Find longest label
			for i = 1 to len(@acLabels)
				nLen = len(@acLabels[i])
				if nLen > nLabelAreaWidth
					nLabelAreaWidth = nLen
				ok
			next
			# Apply maximum width limit
			if nLabelAreaWidth > @nMaxLabelWidth
				nLabelAreaWidth = @nMaxLabelWidth
			ok
		ok
		
		# Calculate bar widths to determine maximum bar area needed
		nMaxBarWidth = 0
		for i = 1 to nBars
			nVal = @anValues[i]
			if @nMaxValue = 0
				nBarWidth = 1
			else
				# Use a reasonable scale factor
				nBarWidth = max([1, ceil(30 * nVal / @nMaxValue)])
			ok
			if nBarWidth > nMaxBarWidth
				nMaxBarWidth = nBarWidth
			ok
		next
		
		# Calculate value area width if showing values
		nValueAreaWidth = 0
		if @bShowValues
			for i = 1 to nBars
				nValueLen = len("" + @anValues[i])
				if nValueLen > nValueAreaWidth
					nValueAreaWidth = nValueLen
				ok
			next
			nValueAreaWidth += 1  # Space before value
		ok
		
		# Calculate positions
		nLabelsStart = 1
		nLabelsEnd = nLabelAreaWidth
		
		nYAxisCol = nLabelsEnd + 1
		if nLabelAreaWidth = 0
			nYAxisCol = 1
		ok
		
		nBarsStart = nYAxisCol + 1
		if @bSetYAxis
			nBarsStart = nYAxisCol + 2  # Extra space after Y-axis
		ok
		
		nBarsEnd = nBarsStart + nMaxBarWidth - 1
		
		nValuesStart = nBarsEnd + 2
		nValuesEnd = nValuesStart + nValueAreaWidth - 1
		
		nXAxisStart = nYAxisCol
		if not @bSetYAxis
			nXAxisStart = nBarsStart - 1
		ok
		nXAxisEnd = nBarsEnd + 1
		if @bShowValues
			nXAxisEnd = nValuesEnd
		ok
		
		# Calculate total dimensions
		nTotalWidth = nXAxisEnd + 2  # +2 for arrow
		nChartHeight = nBars + 2     # +2 for top/bottom margins
		if @bSetXAxis
			nChartHeight += 1        # +1 for X-axis
		ok
		
		# Store layout information
		oLayout.AddPair([:label_area_width, nLabelAreaWidth])
		oLayout.AddPair([:y_axis_col, nYAxisCol])
		oLayout.AddPair([:bars_start_col, nBarsStart])
		oLayout.AddPair([:bars_end_col, nBarsEnd])
		oLayout.AddPair([:values_start_col, nValuesStart])
		oLayout.AddPair([:x_axis_start_col, nXAxisStart])
		oLayout.AddPair([:x_axis_end_col, nXAxisEnd])
		oLayout.AddPair([:x_axis_row, nChartHeight - 1])
		oLayout.AddPair([:bars_start_row, 2])
		oLayout.AddPair([:chart_height, nChartHeight])
		oLayout.AddPair([:total_width, nTotalWidth])
		oLayout.AddPair([:max_bar_width, nMaxBarWidth])
		
		return oLayout

	def _initCanvas()
		@acCanvas = []
		aTempSpaces = []

		for i = 1 to @nWidth
			aTempSpaces + " "
		next

		for i = 1 to @nHeight
			@acCanvas + aTempSpaces
		next

	def _drawYAxis(oLayout)
		
		nAxisCol = oLayout[:y_axis_col]
		nAxisRow = oLayout[:x_axis_row]
		nBarsStartRow = oLayout[:bars_start_row]
		
		# Draw vertical line
		for i = nBarsStartRow to nAxisRow - 1
			@acCanvas[i][nAxisCol] = @cXAxisChar  # Use consistent vertical char
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
			@acCanvas[nAxisRow][i] = @cYAxisChar  # Use horizontal char
		next
		
		# Draw origin if Y-axis is present
		if @bSetYAxis
			@acCanvas[nAxisRow][nYAxisCol] = @cOriginChar
		ok
		
		# Draw arrow at end
		@acCanvas[nAxisRow][nEndCol + 1] = @cYArrowChar

	def _drawBars(oLayout)
		
		nBars = len(@anValues)
		nBarsStartCol = oLayout[:bars_start_col]
		nBarsStartRow = oLayout[:bars_start_row]
		nMaxBarWidth = oLayout[:max_bar_width]
		
		for i = 1 to nBars
			
			nBarRow = nBarsStartRow + (i - 1)
			nVal = @anValues[i]
			
			# Calculate bar width
			if @nMaxValue = 0 or nVal = 0
				nBarWidth = 0
			else
				nBarWidth = max([1, ceil(nMaxBarWidth * nVal / @nMaxValue)])
			ok
			
			# Draw bar
			if nBarWidth > 0
				for j = 1 to nBarWidth
					nCol = nBarsStartCol + j - 1
					if nCol <= @nWidth and nBarRow <= @nHeight
						@acCanvas[nBarRow][nCol] = @cBarChar
					ok
				next
			ok
		next

	def _drawValues(oLayout)
		
		nBars = len(@anValues)
		nBarsStartCol = oLayout[:bars_start_col]
		nBarsStartRow = oLayout[:bars_start_row]
		nMaxBarWidth = oLayout[:max_bar_width]
		
		for i = 1 to nBars
			
			nBarRow = nBarsStartRow + (i - 1)
			nVal = @anValues[i]
			
			# Calculate bar width (same as _drawBars)
			if @nMaxValue = 0 or nVal = 0
				nBarWidth = 1
			else
				nBarWidth = max([1, ceil(nMaxBarWidth * nVal / @nMaxValue)])
			ok
			
			# Position value after bar
			nValueStartCol = nBarsStartCol + nBarWidth + 1
			cValue = "" + nVal
			
			# Draw value
			for k = 1 to len(cValue)
				nCol = nValueStartCol + k - 1
				if nCol <= @nWidth and nBarRow <= @nHeight
					@acCanvas[nBarRow][nCol] = cValue[k]
				ok
			next
		next

	def _drawXLabels(oLayout)
		
		nBars = len(@anValues)
		nLabelAreaWidth = oLayout[:label_area_width]
		nBarsStartRow = oLayout[:bars_start_row]
		
		for i = 1 to nBars
			
			if i <= len(@acLabels)
				
				nBarRow = nBarsStartRow + (i - 1)
				cOriginalLabel = @acLabels[i]
				cLabel = Capitalize(cOriginalLabel)
				
				# Truncate label if needed
				if len(cLabel) > @nMaxLabelWidth
					cLabel = StzStringQ(cLabel).Section(1, @nMaxLabelWidth - 2) + ".."
				ok
				
				nLabelLen = len(cLabel)
				
				# Right-align label within label area
				nStartCol = nLabelAreaWidth - nLabelLen + 1
				if nStartCol < 1
					nStartCol = 1
				ok
				
				# Draw label
				for j = 1 to nLabelLen
					nCol = nStartCol + j - 1
					if nCol <= nLabelAreaWidth and nBarRow <= @nHeight
						@acCanvas[nBarRow][nCol] = cLabel[j]
					ok
				next
			ok
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

			# Remove trailing spaces and add newline except for last line
			cLine = rtrim(cLine)
			if i < nLen
				cResult += cLine + nl
			else
				cResult += cLine
			ok
		next

		return cResult

