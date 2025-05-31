/*
A class for ascii-based charts, working with stzTable and stzPivotTable

Get inspiration from:
https://www.bloomberg.com/graphics/year-ahead-2016/
https://github.com/alincoop/obsidian-tinychart
https://github.com/madnight/bitcoin-chart-cli


^         ╭●╮                                     
│        ╭╯ ╰╮                                    
│        │   ╰╮         
│       ╭╯    ╰──●╮
│    ╭──╯         ╰╮   
│   ●╯             ╰──╮    
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

$aStzChartsTypes = [

	:stzBarChart = [
		:BarChart, :VBarChart, :VBar, :Bar,
		:VerticalBarChart, :VerticalBar,
		:VBarChart, :VBar
	],

	:stzMbarChart = [
		:MultiBarChart, :MultiVBarChart, :MultiVBar, :MultiBar,
		:MultiVerticalBarChart, :MultiVerticalBar,
		:MultiVBarChart, :MultiVBar,
	
		:VMultiBarChart, :VMultiBar, :VMultiBar,
		:VerticalMultiBarChart, :VerticalMultiBar,
		:VMultiBarChart, :VMultiBar,
	
		:MBarChart, :MVBarChart, :MVBar, :MBar,
		:MVerticalBarChart, :MVerticalBar,
		:MVBarChart, :MVBar,
	
		:VMBarChart, :VMBar,
		:VMBarChart, :VMBar
	],

	:stzHBarChart = [
		:HBarChart, :HBar,
		:HorizontalBarChart, :HorizontalBar
	]
]

func StzChartsTypes()
	return Flatten(StzHashListQ($aStzChartsTypes).Values())

	func StzCharts()
		return StzCharsTypes()

func StzChartsClasses()
		return StzHashListQ($aStzChartsTypes).Keys()


func StzChartQ(pcChartType, paDataSet)

		if NOT ring_find(StzChartsTypes(), pcChartType)
			StzRaise("Insupported chart type!")
		ok

		aChartsClasses = StzChartsClasses()

		oHash = new stzHashList($aStzChartsTypes)
		aPos = oHash.FindInValues(pcChartType)
		cChartClass = aChartsClasses[aPos[1][1]]

		switch cChartClass

		on :stzBarChart 
			return new stzBarChart(paDataSet)

		on :stzMBarChart
			return new stzMBarChart(paDataSet)

		on :stzHBarChart
			return new stzHBarChart(paDataSet)

		off


class stzChart

	@anValues = []
	@acLabels = []
	@acCanvas = []

	@nWidth = 40
	@nHight = 10
	@nMaxValue = 0
	@nMinValue = 0

	# @cBarChar = "█" ~> Defined by subclasses
	@cXAxisChar = "│"
	@cYAxisChar = "─"
	@cXArrowChar = "^"
	@cYArrowChar = "─>"
	@cOriginChar = "╰"
	@cAverageChar = "-"

	# @cFinalBarChar = "█"  ~> Defined by subclasses

	def init(paDataSet)

		# It must be a list of numbers or a hashlist where
		# the values are all numbers

		if CheckParams()

			if CheckParams()

				if NOT isList(paDataSet)
					StzRaise("Can't create the stzChart object! paDataSet must be a list.")
				ok
	
				if NOT (IsListOfNumbers(paDataSet) or IsHashListOfNumbers(paDataSet))
					StzRaise("Can't create the stzChart object! paDataSet must be a list of numbers or a hashlist containing numbers.")
				ok
	
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
			StzRaise("Incorrect param value! You must provide only psoitive numbers.")
		ok

		@acLabels = oHash.Keys()
		_calculateRange()

	def Sum()
		return @Sum(@anValues)
	
	def Average()
		return @Average(@anValues)
	
	def NumberOfValues()
		return len(@anValues)

	def SetSize(nWidth, nHeight)

		if CheckParams()
			if NOT (isNumber(nWidth) and isNumber(nHeight))
				StzRaise("Incorrect param type! nWidth and nHeight must be both numbers.")
			ok
		ok

		@nWidth = nWidth
		@nHight = nHeight

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

		for i = 1 to @nHight
			@acCanvas + aTempSpaces
		next


	def _finalizeCanvas()

		cResult = ""
		nLen = len(@acCanvas)

		# When labels are disabled, exclude the empty last row
		if @bShowLabels = FALSE
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

class stzVBarChart from stzBarChart

class stzBarChart from stzChart

	@bShowXAxis = True
	@bShowYAxis = True
	@bShowLabels = True
	@bShowAverage = False
	@bShowValues = False
	@bShowPercent = False

	@nBarWidth = 2
	@nMaxWidth = 132
	@nMaxLabelWidth = 12
	@nBarInterSpace = 1

	@cBarChar = "█"
	@cFinalBarChar = ""

	# Layout constants for consistent spacing
	@nYAxisWidth = 1        # Width of Y-axis column
	@nAxisPadding = 1       # Space between Y-axis and bars
	@nLabelPadding = 1      # Space between bars and labels


	def init(paData)
		super.init(paData)


	def SetXAxis(bShow)
		@bShowXAxis = bShow

		def SetHAxis(bShow)
			@bShowXAxis = bShow

		def WithoutXAxis()
			@bShowXAxis = FALSE

		def WithoutHAxis()
			@bShowXAxis = FALSE

	def SetYAxis(bShow)
		@bShowYAxis = bShow

		def SetVAxis(bShow)
			@bShowYAxis = bShow

		def WithoutYAxis()
			@bShowYAxis = FALSE

		def WithoutVAxis()
			@bShowYAxis = FALSE


	def SetXYAxis(bShow)
		if isList(bShow) and len(bShow) = 2
			@bShowXAxis = bShow[1]
			@bShowYAxis = bShow[2]
		else
			@bShowXAxis = bShow
			@bShowYAxis = bShow
		ok

		def SetXYAxies(bShow)
			This.SetXYAxis(bShow)

		def SetYXAxis(bShow)
			This.SetXYAxis(bShow)

		def SetYXAxies(bShow)
			This.SetXYAxis(bShow)

		def SetBothAxis(bShow)
			This.SetXYAxis(bShow)

		def SetBothAxies(bShow)
			This.SetXYAxis(bShow)

		def WithoutAxises()
			This.SetXYAxis(FALSE)

		def WithoutXYAxis()
			This.SetXYAxis(FALSE)

		def WithoutXYAxies()
			This.SetXYAxis(FALSE)

		def WithoutYXAxis()
			This.SetXYAxis(FALSE)

		def WithoutYXAxies()
			This.SetYXAxis(FALSE)

		#--

		def SetVHAxis(bShow)
			This.SetVHAxis(bShow)
		def SetVHAxies(bShow)
			This.SetVHAxis(bShow)

		def SetHVAxis(bShow)
			This.SetVHAxis(bShow)

		def SetHVAxies(bShow)
			This.SetVHAxis(bShow)

		def WithoutVHAxis()
			This.SetVHAxis(FALSE)

		def WithoutVHAxies()
			This.SetVHAxis(FALSE)

		def WithoutHVAxis()
			This.SetVHAxis(FALSE)

		def WithoutHVAxies()
			This.SetHVAxis(FALSE)


	def SetYLabels(bShow)
		@bShowLabels = bShow

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

		def WithoutYLabels()
			@bShowLabels = FALSE

		def WithoutLabels()
			@bShowLabels = FALSE


	def SetAverageLine(bShow)
		@bShowAverage = bShow

		def SetAverage(bShow)
			@bShowAverage = bShow

		def AddAverage()
			@bShowAverage = _TRUE_

		def AddAverageLine()
			@bShowAverage = _TRUE_

		def IncludeAverage()
			@bShowAverage = _TRUE_

		def IncludeAverageLine()
			@bShowAverage = _TRUE_


	def SetValues(bShow)
		@bShowValues = bShow

		def AddValues()
			This.SetValues(_TRUE_)

		def IncludeValues()
			This.SetValues(_TRUE_)


	def SetPercent(bShow)
		@bShowPercent = bShow

		def SetPercentage(bShow)
			@bShowPercent = bShow

		def AddPercent()
			@bShowPercent = _TRUE_
	
		def AddPercentage()
			@bShowPercent = _TRUE_

		def IncludePercent()
			@bShowPercent = _TRUE_
	
		def IncludePercentage()
			@bShowPercent = _TRUE_


	def SetBarWidth(nWidth)
		@nBarWidth = max([1, nWidth])

	def SetMaxWidth(nWidth)
		@nMaxWidth = nWidth

		def MaxWidth()
			return @nMaxWidth

	def SetBarInterSpace(n)
		@nBarInterSpace = n
	
		def BarInterSpace()
			return @nBarInterSpace
	

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


    def TopBarChar()
        return @cFinalBarChar

		def FinalBarChar()
			return @cFinalBarChar

	
	def SetYAxisWidth(n)
		@nYAxisWidth = n

		def YAxisWidth()
			return @nYAxisWidth

		def SetHAxisWidth(n)
			@nYAxisWidth = n

		def HAxisWidth()
			return @nYAxisWidth


	def SetXAxisWidth(n)
		@nXAxisWidth = n

		def XAxisWidth()
			return @nXAxisWidth

		def SetVAxisWidth(n)
			@nXAxisWidth = n

		def VAxisWidth()
			return @nXAxisWidth


	def SetMaxLabelWidth(n)
		@nMaxLabelWidth = n

		def MaxLabelWidth(n)
			return @nMaxLabelWidth



	def Show()
		? This.ToString()


	def ToString()
		
		# Step 1: Calculate layout dimensions
		oLayout = _calculateLayout()
		
		# Step 2: Initialize canvas with exact dimensions
		@nWidth = oLayout[:total_width]
		@nHight = oLayout[:chart_height]
		_initCanvas()
		
		# Step 3: Draw components in order
		if @bShowYAxis
			_drawYAxis(oLayout)
		ok
		
		if @bShowXAxis  
			_drawXAxis(oLayout)
		ok
		
		if @bShowAverage
			_drawAverageLine(oLayout)
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

		# A hack to add a space at the top of the X Axis
		if ring_substr1(cResult, @cXArrowChar) > 0
			cResult = ring_substr2(cResult, @cXArrowChar, @cXAxisChar)
			cResult = @cXArrowChar + NL + cResult
		ok

		# A hack to add the average value
		if @bShowAverage
			oTempStr = new stzString(cResult)
			if @bShowValues

				cValue = " " + RoundN(This.Average(), 1)
				if cValue[len(cValue)] = "0"
					cValue = ring_substr2(cValue, ".0", "")
				ok

				oTempStr.InsertAfterLast(@cAverageChar, cValue)

			but @bShowPercent
				cPercent = " 50%"
				oTempStr.InsertAfterLast(@cAverageChar, cPercent)
			ok

			cResult = oTempStr.Content()
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
		nSum = This.Sum()  # For percentage calculations
		
		for i = 1 to nBars
			nBarWidth = @nBarWidth
			nLabelWidth = 0
			nValueWidth = 0
			
			# Label width
			if @bShowLabels and i <= len(@acLabels)
				nLabelWidth = len(@acLabels[i])
				# Apply maximum width limit
				if nLabelWidth > @nMaxLabelWidth
					nLabelWidth = @nMaxLabelWidth
				ok
			ok
			
			# Value width (if showing values or percentages)
			if @bShowValues
				nValueWidth = len("" + @anValues[i])
			but @bShowPercent
				cPercent = roundN((@anValues[i]/nSum)*100, 1)
				nValueWidth = len("" + cPercent + '%')
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
		if @bShowYAxis
			nBarsStart += @nAxisPadding
		ok
		
		nBarsEnd = nBarsStart + nBarsAreaWidth - 1
		
		nXAxisStart = nYAxisStart
		if @bShowYAxis
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
		if @bShowLabels
			nChartHeight = @nHight      # No extra height needed
			nXAxisRow = @nHight - 1     # X-axis at height - 1
			nLabelsRow = @nHight        # Labels on last row
		else
			nChartHeight = @nHight
			nXAxisRow = @nHight - 1     # X-axis at bottom
			nLabelsRow = @nHight        # Not used when labels disabled
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
		if @bShowYAxis
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
			                # Use top bar character for the highest bar segment
			                if j = nBarHeight and @cFinalBarChar != ""
			                    @acCanvas[nRow][nCol] = @cFinalBarChar
			                else
			                    @acCanvas[nRow][nCol] = @cBarChar
			                ok
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
		
		# Calculate average row for conflict avoidance
		nAvg = This.Average()
		nAvgRow = nAxisRow - ceil(nBarsAreaHeight * nAvg / @nMaxValue)
		
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
			
			# Avoid average line conflict - move value up if necessary
			if @bShowAverage and nValueRow = nAvgRow
				nValueRow = max([1, nAvgRow - 1])
			ok
			
			cValue = "" + nVal
			nValueLen = len(cValue)
			
			# Center within element width
			nValueStartX = nCurrentX + floor((nElementWidth - nValueLen) / 2)
			
			# Draw value with bounds checking
			for k = 1 to nValueLen
				nCol = nValueStartX + k - 1
				if nCol <= @nWidth and nCol >= 1 and nValueRow >= 1
					@acCanvas[nValueRow][nCol] = cValue[k]
				ok
			next
			
			# Move to next position
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
	
		# Calculate average row for conflict avoidance
		nSum = This.Sum()
		nAvg = nSum / len(@anValues)
		nAvgRow = nAxisRow - ceil(nBarsAreaHeight * nAvg / @nMaxValue)
	
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
	
			# Avoid average line conflict - move value up if necessary
			if @bShowAverage and nValueRow = nAvgRow
				nValueRow = max([1, nAvgRow - 1])
			ok
	
			# Format percentage with 1 decimal place
			nPercent = RoundN((nVal/nSum)*100, 1)
			cValue = "" + nPercent + '%'
	
			nValueLen = len(cValue)
	
			# Center within element width (same logic as _drawLabels)
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


	def _drawLabels(oLayout)

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
				nLenLabel = len(cLabel)

				# Truncate label if needed
				if nLenLabel > @nMaxLabelWidth
					nLenLabel = @nMaxLabelWidth
					cLabel = StzStringQ(cLabel).Section(1, @nMaxLabelWidth - 2) + ".." 
				ok

				# Center label within element width
				nLabelStartX = nCurrentX + floor((nElementWidth - nLenLabel) / 2)

				# Draw label
				for j = 1 to nLenLabel
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
		nAvg = This.Average()
		
		nBarsStartCol = oLayout[:bars_start_col]
		nBarsEndCol = oLayout[:bars_end_col] 
		nAxisRow = oLayout[:x_axis_row]
		nBarsAreaHeight = oLayout[:bars_area_height]
		nYAxisCol = oLayout[:y_axis_col]
		
		# Calculate average line position
		if @nMaxValue = 0
			nAvgRow = nAxisRow - 1
		else
			nAvgRow = nAxisRow - ceil(nBarsAreaHeight * nAvg / @nMaxValue)
		ok
		
		# Start position: right after Y-axis if it exists, otherwise at bars start
		nLineStart = nBarsStartCol
		if @bShowYAxis
			nLineStart = nYAxisCol + 1
		ok
		
		# End position: one position beyond current end
		nLineEnd = nBarsEndCol + 1
		
		# Draw average line
		for i = nLineStart to nLineEnd
			if i <= @nWidth and @acCanvas[nAvgRow][i] != @cBarChar
				@acCanvas[nAvgRow][i] = @cAverageChar
			ok
		next
		
		# Add average value/percent to the right of the line
		nSum = This.Sum()
		if @bShowValues or @bShowPercent
			cAvgText = ""
			if @bShowValues
				cAvgText = "" + RoundN(nAvg, 1)
			but @bShowPercent
				nAvgPercent = RoundN((nAvg/nSum)*100, 1)
				cAvgText = "" + nAvgPercent + '%'
			ok
			
			# Position text right after line end with a space
			nTextStart = nLineEnd + 2
			nTextLen = len(cAvgText)
			
			# Draw average text
			for j = 1 to nTextLen
				nCol = nTextStart + j - 1
				if nCol <= @nWidth
					@acCanvas[nAvgRow][nCol] = cAvgText[j]
				ok
			next
		ok
	

#------------------------------#
#  HORIZONTAL BAR CHART CLASS  #
#------------------------------#

class stzHBarChart from stzChart

	@bShowXAxis = True
	@bShowYAxis = True
	@bShowLabels = True
	@bShowValues = False
	@bShowPercent = False

	@nBarHeight = 1
	@nWidth = 20
	@nBarInterSpace = 0
	@nMaxLabelWidth = 12
	@nLeftPadding = 0

	@cBarChar = "▇"


	def init(paData)
		super.init(paData)

	def SetXAxis(bShow)
		@bShowXAxis = bShow

		def SetHAxis(bShow)
			@bShowXAxis = bShow

	def SetYAxis(bShow)
		@bShowYAxis = bShow

		def SetVAxis(bShow)
			@bShowYAxis = bShow

	def SetXYAxis(bShow)
		if isList(bShow) and IsPairOfNumbers(bShow)
			@bShowXAxis = bShow[1]
			@bShowYAxis = bShow[2]
			return
		ok
		@bShowXAxis = bShow
		@bShowYAxis = bShow

		def SetHVAxis(bShow)
			This.SetXYAxis(bShow)

	def SetYXAxis(bShow)
		if isList(bShow) and IsPairOfNumbers(bShow)
			@bShowYAxis = bShow[1]
			@bShowXAxis = bShow[2]
			return
		ok

		@bShowXAxis = bShow
		@bShowYAxis = bShow

		def SetVHAxis(bShow)
			This.SetYXAxis(bShow)

	def SetXLabels(bShow)
		@bShowLabels = bShow

		def SetLabels(bShow)
			@bShowLabels = bShow

		def SetVLabels(bShow)
			@bShowLabels = bShow

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

	def SetPercent(bShow)
		@bShowPercent = bShow

		def SetPercentage(bShow)
			@bShowPercent = bShow

	def AddPercent()
		@bShowPercent = _TRUE_

		def AddPercentage()
			@bShowPercent = _TRUE_

	def SetBarHeight(nHeight)
		@nBarHeight = max([1, nHeight])

		def SetBarHight(nHeight)
			This.SetBarHeight(nHeight)

		def BarHight()
			return @nBarHeight

		def BarHeight()
			return @nBarHeight

	def SetMaxLabelWidth(n)
		@nMaxLabelWidth = n

		def MaxLabelWidth(n)
			return @nMaxLabelWidth

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
		@nHight = oLayout[:chart_height]
		_initCanvas()
		
		# Step 3: Draw components in order
		if @bShowYAxis
			_drawYAxis(oLayout)
		ok
		
		if @bShowXAxis  
			_drawXAxis(oLayout)
		ok

		_drawBars(oLayout)
		
		if @bShowValues
			_drawValues(oLayout)
		ok

		if @bShowPercent
       		_drawPercent(oLayout)
    	ok

		if @bShowLabels
			_drawXLabels(oLayout)
		ok

		if @bShowLabels
			_drawLabels(oLayout)
		ok

		cResult = _finalizeCanvas()

		# A hack to remove .0 from values and percentages
		if @bShowValues
			cResult = ring_substr2(cResult, ".0", "")

		but @bShowPercent
			cResult = ring_substr2(cResult, ".0%", "%")
		ok

		# A hack to remobve an orphelin NL at the start of the string
		if ring_substr1(cResult, "^") = FALSE
			oTempStr = new stzString(cResult)
			oTempStr.RemoveFirstChar()
			oTempStr.Replace("   ", " ")
			cResult = oTempStr.Content()
		ok

		return cResult


	def _calculateLayout()
		
		nBars = len(@anValues)
		oLayout = new stzHashList([])
		
		# Calculate label area width
		nLabelAreaWidth = 0
		if @bShowLabels
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
		but @bShowPercent
		    nSum = @Sum(@anValues)
		    for i = 1 to nBars    
		        nValueLen = len('' + RoundN((@anValues[i]/nSum)*100, 1) + "%")  # Include "%"
		        if nValueLen > nValueAreaWidth
		            nValueAreaWidth = nValueLen
		        ok
		    next
		    nValueAreaWidth += 1  # Space before value
		ok
	
		# Calculate bar widths - use @nWidth directly as max bar area
		nMaxBarWidth = 0
		for i = 1 to nBars
			nVal = @anValues[i]
			if @nMaxValue = 0
				nBarWidth = 1
			else
				if @nWidth > 0
					# Use @nWidth as the maximum bar width available
					nBarWidth = max([1, ceil(@nWidth * nVal / @nMaxValue)])
				else
					# Use original scaling
					nBarWidth = max([1, ceil(30 * nVal / @nMaxValue)])
				ok
			ok
			if nBarWidth > nMaxBarWidth
				nMaxBarWidth = nBarWidth
			ok
		next
		
		# Override max bar width if user set width
		if @nWidth > 0
			nMaxBarWidth = @nWidth
		ok
	
		# Calculate positions
		nLabelsStart = 1
		nLabelsEnd = nLabelAreaWidth
		
		nYAxisCol = nLabelsEnd + 2  # +2 for space between labels and Y-axis
		if nLabelAreaWidth = 0
			nYAxisCol = 1
		ok
				
		nBarsStart = nYAxisCol + 2  # +2 for Y-axis and space
		
		nBarsEnd = nBarsStart + nMaxBarWidth - 1
		
		nValuesStart = nBarsEnd + 2
		nValuesEnd = nValuesStart + nValueAreaWidth - 1
		
		nXAxisStart = nYAxisCol
		nXAxisEnd = nBarsEnd + 1
		if @bShowValues or @bShowPercent
			nXAxisEnd = nValuesEnd
		ok
		
		# Calculate total dimensions
		nTotalWidth = nXAxisEnd + 5  # +3 for 0% and +2 for arrow
		
		nChartHeight = nBars + 1     # +1 for Y-axis arrow at top
		if @bShowXAxis
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
		oLayout.AddPair([:x_axis_row, nChartHeight])
		oLayout.AddPair([:bars_start_row, 2])  # Row 2 to leave space for arrow
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

		for i = 1 to @nHight
			@acCanvas + aTempSpaces
		next


	def _drawXAxis(oLayout)
		
		nAxisRow = oLayout[:x_axis_row]
		nStartCol = oLayout[:x_axis_start_col]
		nEndCol = oLayout[:x_axis_end_col]
		nYAxisCol = oLayout[:y_axis_col]
		
		# Draw horizontal line
		for i = nStartCol to nEndCol
			if i <= @nWidth  # Add bounds check
				@acCanvas[nAxisRow][i] = @cYAxisChar
			ok
		next
		
		# Draw origin if Y-axis is present
		if @bShowYAxis and nYAxisCol <= @nWidth  # Add bounds check
			@acCanvas[nAxisRow][nYAxisCol] = @cOriginChar
		ok
		
		# Draw arrow at end - add bounds check
		if nEndCol + 1 <= @nWidth
			@acCanvas[nAxisRow][nEndCol + 1] = @cYArrowChar
		ok


	def _drawYAxis(oLayout)
		
		nAxisCol = oLayout[:y_axis_col]
		nBarsStartRow = oLayout[:bars_start_row]
		
		# Calculate end row - stop before X-axis if it exists
		nEndRow = nBarsStartRow + len(@anValues) - 1
		if @bShowXAxis
			nEndRow = oLayout[:x_axis_row] - 1
		ok
		
		# Draw vertical line
		for i = nBarsStartRow to nEndRow
			@acCanvas[i][nAxisCol] = @cXAxisChar
		next
		
		# Draw arrow at top (row 1)
		@acCanvas[1][nAxisCol] = @cXArrowChar


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
					if nCol <= @nWidth and nBarRow <= @nHight
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
				if nCol <= @nWidth and nBarRow <= @nHight
					@acCanvas[nBarRow][nCol] = cValue[k]
				ok
			next
		next


	def _drawPercent(oLayout)
	    nBars = len(@anValues)
	    nBarsStartCol = oLayout[:bars_start_col]
	    nBarsStartRow = oLayout[:bars_start_row]
	    nMaxBarWidth = oLayout[:max_bar_width]
	    
	    nSum = @Sum(@anValues)
	
	    for i = 1 to nBars
	        nBarRow = nBarsStartRow + (i - 1)
	        nVal = @anValues[i]  # Use actual value for bar width
	
	        # Calculate bar width based on actual value (same as _drawBars)
	        if @nMaxValue = 0 or nVal = 0
	            nBarWidth = 0
	        else
	            nBarWidth = max([1, ceil(nMaxBarWidth * nVal / @nMaxValue)])
	        ok
	        
	        # Calculate percentage for display
	        nPercent = (nVal / nSum) * 100
	        cPercent = '' + RoundN(nPercent, 1) + "%"  # Format as "XX.X%"
	        
	        # Position percentage text after the bar
	        nValueStartCol = nBarsStartCol + nBarWidth + 1
	
	        # Draw percentage text
	        for k = 1 to len(cPercent)
	            nCol = nValueStartCol + k - 1
	            if nCol <= @nWidth and nBarRow <= @nHight
	                @acCanvas[nBarRow][nCol] = cPercent[k]
	            ok
	        next
	    next


	def _drawLabels(oLayout)
		
		nBars = len(@anValues)
		nLabelAreaWidth = oLayout[:label_area_width]
		nBarsStartRow = oLayout[:bars_start_row]
		
		for i = 1 to nBars
			
			if i <= len(@acLabels)
	
				nBarRow = nBarsStartRow + (i - 1)
				cOriginalLabel = @acLabels[i]
				cLabel = Capitalize(cOriginalLabel)
	
				# Truncate label if needed - use fixed max width
				if len(cLabel) > @nMaxLabelWidth
					cLabel = StzStringQ(cLabel).Section(1, @nMaxLabelWidth - 2) + ".."
				ok
	
				nLenLabel = len(cLabel)
				
				# Right-align label within label area
				nStartCol = nLabelAreaWidth - nLenLabel + 1
				if nStartCol < 1
					nStartCol = 1
				ok
				
				# Draw label
				for j = 1 to nLenLabel
					nCol = nStartCol + j - 1
					if nCol <= nLabelAreaWidth and nBarRow <= @nHight
						@acCanvas[nBarRow][nCol] = cLabel[j]
					ok
				next
			ok
		next

		def _drawXLabels(oLayout)
			This._drawLabels(oLayout)


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




#-------------------------#
#  MULTI-BAR CHART CLASS  #
#-------------------------#

class stzMBarChart from stzMultiBarChart

class stzMultiBarChart from stzChart

	@aaMultiValues = []     # Array of arrays for each series
	@acSeriesNames = []     # Names of each data series
	@acSeriesChars = []     # Characters for each series (bar styles)
	@acCategories = []      # Category labels (x-axis)
	@nSeriesCount = 0       # Number of data series

	@bShowXAxis = True
	@bShowYAxis = True
	@bShowLabels = True
	@bShowAverage = False
	@bShowValues = False
	@bShowPercent = False
	@bShowLegend = True
	@bmanualsizing = True

	@nBarWidth = 2
	@nMaxWidth = 132
	@nMaxLabelWidth = 12

	@nSeriesInterSpace = 1       # Space between bars within same category
	@nCategoryInterSpace = 3     # Space between different categories

	@cFinalBarChar = ""
	@acBarsChars = ["█", "▒", "▓", "░", "■", "□", "▦", "▤"]
	@cBarChar = @acBarsChars[1]

	# Layout constants
	@nYAxisWidth = 1
	@nAxisPadding = 1
	@nLabelPadding = 1

	@cLegendLayout = :Horizontal


	def init(paMultiData)
	
		if CheckParams()
			if NOT isList(paMultiData)
				StzRaise("Can't create stzMultiBarChart! paMultiData must be a list.")
			ok
		ok
	
		# Initialize manual sizing flag BEFORE parsing data
		@bManualSizing = False
	
		# Parse multi-series data structure
		_parseMultiSeriesData(paMultiData)
		_calculateMultiRange()
	
	# Apply smart defaults after data is parsed
	_applySmartDefaults()


	def _applySmartDefaults()
		
		# Skip if user has manually set sizing
		if @bManualSizing = True
			return
		ok
		
		# Calculate maximum value/percent string width
		nMaxValueWidth = _calculateMaxDisplayWidth()
		
		# Smart defaults based on display requirements
		if @bShowValues or @bShowPercent
			
			# For values/percentages, need more space
			if nMaxValueWidth <= 2  # "10", "5%"
				@nBarWidth = 2
				@nSeriesInterSpace = 1
				@nCategoryInterSpace = 3

			but nMaxValueWidth <= 3  # "100", "15%"  
				@nBarWidth = 2
				@nSeriesInterSpace = 1
				@nCategoryInterSpace = 4

			but nMaxValueWidth <= 4  # "1000", "25.5%"
				@nBarWidth = 3
				@nSeriesInterSpace = 1
				@nCategoryInterSpace = 4

			but nMaxValueWidth <= 5  # "10000", "100.0%"
				@nBarWidth = 3
				@nSeriesInterSpace = 2
				@nCategoryInterSpace = 5

			else  # Very long values
				@nBarWidth = 4
				@nSeriesInterSpace = 2
				@nCategoryInterSpace = 6
			ok
	
		else
			# No values/percentages displayed, can be more compact
			@nBarWidth = 2
			@nSeriesInterSpace = 1
			@nCategoryInterSpace = 3
		ok


	def _calculateMaxDisplayWidth()
		
		nMaxWidth = 0
		
		if @bShowValues
			# Find widest value
			for i = 1 to @nSeriesCount
				if i <= len(@aaMultiValues)
					aCurrentSeries = @aaMultiValues[i]
					for j = 1 to len(aCurrentSeries)
						nValueWidth = len("" + aCurrentSeries[j])
						if nValueWidth > nMaxWidth
							nMaxWidth = nValueWidth
						ok
					next
				ok
			next
			
		but @bShowPercent
			# Calculate all percentages and find widest
			nOverallSum = _calculateOverallSum()
			if nOverallSum > 0
				for i = 1 to @nSeriesCount
					if i <= len(@aaMultiValues)
						aCurrentSeries = @aaMultiValues[i]
						for j = 1 to len(aCurrentSeries)
							nPercent = RoundN((aCurrentSeries[j]/nOverallSum)*100, 1)
							cPercent = "" + nPercent + '%'
							nPercentWidth = len(cPercent)
							if nPercentWidth > nMaxWidth
								nMaxWidth = nPercentWidth
							ok
						next
					ok
				next
			ok
		ok
		
		return nMaxWidth

	def _parseMultiSeriesData(paData)

		@aaMultiValues = []
		@acSeriesNames = []
		@acCategories = []
		@acSeriesChars = []

		# Extract series names and data
		oMultiHash = new stzHashList(paData)
		@acSeriesNames = oMultiHash.Keys()
		@nSeriesCount = len(@acSeriesNames)

		# Extract categories from first series
		if @nSeriesCount > 0
			oFirstSeries = new stzHashList(oMultiHash.Values()[1])
			@acCategories = oFirstSeries.Keys()
		ok

		# Extract values for each series
		aSeriesData = oMultiHash.Values()
		for i = 1 to @nSeriesCount
			oSeriesHash = new stzHashList(aSeriesData[i])
			aSeriesValues = oSeriesHash.Values()
			
			if NOT IsListOfPositiveNumbers(aSeriesValues)
				StzRaise("Incorrect data! All values must be positive numbers.")
			ok
			
			@aaMultiValues + aSeriesValues
		next

		# Assign default characters for each series
		for i = 1 to @nSeriesCount
			if i <= len(@acBarsChars)
				@acSeriesChars + @acBarsChars[i]
			else
				@acSeriesChars + @cBarChar
			ok
		next

	def _calculateMultiRange()

		@nMaxValue = 0
		@nMinValue = 0

		# Find max and min across all series
		for i = 1 to @nSeriesCount
			aCurrentSeries = @aaMultiValues[i]
			nCurrentMax = max(aCurrentSeries)
			nCurrentMin = min(aCurrentSeries)

			if nCurrentMax > @nMaxValue
				@nMaxValue = nCurrentMax
			ok

			if i = 1 or nCurrentMin < @nMinValue
				@nMinValue = nCurrentMin
			ok
		next

	def SetSeriesChars(acChars)
		if CheckParams()
			if NOT isList(acChars)
				StzRaise("Incorrect param! acChars must be a list of characters.")
			ok
		ok

		@acSeriesChars = []
		for i = 1 to min([len(acChars), @nSeriesCount])
			@acSeriesChars + acChars[i]
		next

		# Fill remaining with defaults if needed
		for i = len(@acSeriesChars) + 1 to @nSeriesCount
			@acSeriesChars + @cBarChar
		next


	def SetLegend(bShow)
		@bShowLegend = bShow

		def AddLegend()
			@bShowLegend = _TRUE_

	# Inherit common methods from stzBarChart
	def SetXAxis(bShow)
		@bShowXAxis = bShow

	def SetYAxis(bShow)
		@bShowYAxis = bShow

	def SetLabels(bShow)
		@bShowLabels = bShow

		def AddLabels()
			@bShowLabels = _TRUE_

	def SetValues(bShow)
		@bShowValues = bShow
		if bShow
			@bShowPercent = False  # Can't show both
			_applySmartDefaults()
		ok

	def AddValues()
		@bShowValues = _TRUE_
		@bShowPercent = False
		_applySmartDefaults()

	def SetPercent(bShow)
		@bShowPercent = bShow
		if bShow
			@bShowValues = False  # Can't show both
			_applySmartDefaults()
		ok

	def AddPercent()
		@bShowPercent = _TRUE_
		@bShowValues = False
		_applySmartDefaults()

	def SetAverage(bShow)
		@bShowAverage = bShow

		def AddAverage()
			@bShowAverage = _TRUE_

	# Allow manual override of smart defaults
	def SetBarWidth(nWidth)
		@nBarWidth = max([1, nWidth])
		@bManualSizing = True  # Flag to prevent auto-override
	
	def SetSeriesInterSpace(n)
		@nSeriesInterSpace = n
		@bManualSizing = True

		def SetBarInterSpace(n)
			This.SetSeriesInterSpace(n)

	def SetCategoryInterSpace(n) 
		@nCategoryInterSpace = n
		@bManualSizing = True

	def SetMaxWidth(nWidth)
		@nMaxWidth = nWidth

	def SetBarsChars(pacChars)
		@acBarsChars = pacChars
		_UpdateSeriesChars()

	def _UpdateSeriesChars()
	    # Reassign characters from updated @acBarsChars array
	    @acSeriesChars = []
		nLenBarsChars = len(@acBarsChars)

	    for i = 1 to @nSeriesCount
	        if i <= nLenBarsChars
	            @acSeriesChars + @acBarsChars[i]
	        else
	            @acSeriesChars + @cBarChar
	        ok
	    next

	def SetFinalBarChar(c)
		@cFinalBarChar = c

		def SetTopBarChar(c)
			@cFinalBarChar = c

	def SetLegendLayout(pcDirection)
		if CheckParams()
			if NOT isString(pcDirection)
				StzRaise("Incorrect param type! pcDirection must be a string.")
			ok
		ok

		cDirection = lower(pcDirection)
		if NOT (cDirection = :Horizontal or cDirection = :Vertical)
			StzRaise("Incorrect param value! cDirection must be a :Horizontal or :Vertical.")
		ok

		@cLegendLayout = cDirection

	def UseHLegend()
		@cLegendLayout = :Horizontal

		def UseHorizontalLegend()
			@cLegendLayout = :Horizontal

	def UseVLegend()
		@cLegendLayout = :Vertical

		def UseVerticalLegend()
			@cLegendLayout = :Vertical

	def Show()
		? This.ToString()

	def ToString()

		# Step 1: Calculate layout for multi-series
		oLayout = _calculateMultiLayout()

		# Step 2: Initialize canvas
		@nWidth = oLayout[:total_width]
		@nHight = oLayout[:chart_height]
		_initCanvas()

		# Step 3: Draw components
		if @bShowYAxis
			_drawYAxis(oLayout)
		ok

		if @bShowXAxis
			_drawXAxis(oLayout)
		ok

		if @bShowAverage
			_drawMultiAverageLine(oLayout)
		ok

		_drawMultiBars(oLayout)

		if @bShowValues
			_drawMultiValues(oLayout)
		but @bShowPercent
			_drawMultiPercent(oLayout)
		ok

		if @bShowPercent
			_drawMultiPercent(oLayout)
		ok

		if @bShowLabels
			_drawMultiLabels(oLayout)
		ok

		if @bShowLegend
			_drawLegend(oLayout)
		ok

		cResult = _finalizeCanvas()

		# Add space at top of X axis
		if ring_substr1(cResult, @cXArrowChar) > 0
			cResult = ring_substr2(cResult, @cXArrowChar, @cXAxisChar)
			cResult = @cXArrowChar + NL + cResult
		ok

		if @bShowAverage
			oTempStr = new stzString(cResult)
			if @bShowValues
	
				cValue = " " + RoundN(_calculateOverallAverage(), 1)
				if cValue[len(cValue)] = "0"
					cValue = ring_substr2(cValue, ".0", "")
				ok
	
				oTempStr.InsertAfterLast(@cAverageChar, cValue)
	
			but @bShowPercent
				nOverallSum = _calculateOverallSum()
				nOverallAvg = _calculateOverallAverage()
				nAvgPercent = RoundN((nOverallAvg/nOverallSum)*100, 1)
				cPercent = " " + nAvgPercent + "%"
				oTempStr.InsertAfterLast(@cAverageChar, cPercent)
			ok
	
			cResult = oTempStr.Content()
		ok
	
		return cResult


	def _calculateMultiLayout()

		nCategories = len(@acCategories)
		oLayout = new stzHashList([])

		# Calculate spacing within categories
		nBarsPerCategory = @nSeriesCount
		nSeriesSpacing = (@nSeriesCount - 1) * @nSeriesInterSpace

		# Calculate category widths
		aCategoryWidths = []
		nLenCat = len(@acCategories)

		for i = 1 to nCategories

			# Width = (bars * bar_width) + series_spacing + label_consideration
			nCategoryBarWidth = nBarsPerCategory * @nBarWidth + nSeriesSpacing
			nLabelWidth = 0
			
			if @bShowLabels and i <= nLenCat
				nLabelWidth = len(@acCategories[i])
				if nLabelWidth > @nMaxLabelWidth
					nLabelWidth = @nMaxLabelWidth
				ok
			ok
			
			nCategoryWidth = max([nCategoryBarWidth, nLabelWidth])
			aCategoryWidths + nCategoryWidth

		next

		# Calculate total bars area width
		nBarsAreaWidth = 0
		nLenCatW = len(aCategoryWidths)
		for i = 1 to nLenCatW
			nBarsAreaWidth += aCategoryWidths[i]
		next
		nBarsAreaWidth += (nCategories - 1) * @nCategoryInterSpace

		# Calculate layout positions
		nYAxisStart = 1
		nYAxisEnd = nYAxisStart + @nYAxisWidth - 1

		nBarsStart = nYAxisEnd + 1
		if @bShowYAxis
			nBarsStart += @nAxisPadding
		ok

		nBarsEnd = nBarsStart + nBarsAreaWidth - 1

		nXAxisStart = nYAxisStart
		if @bShowYAxis
			nXAxisStart = nYAxisEnd + @nAxisPadding
		ok
		nXAxisEnd = nBarsEnd + @nAxisPadding

		nTotalWidth = nXAxisEnd + 1

		# Height calculations
		nExtraHeight = 0
		if @bShowLegend
		    if @cLegendLayout = :Vertical
		        nExtraHeight += @nSeriesCount + 1  # One row per series + empty line
		    else
		        nExtraHeight += 3  # Space for empty line + legend
		    ok
		ok
		
		if @bShowLabels
			nChartHeight = @nHight + nExtraHeight
			nXAxisRow = @nHight - 1
			nLabelsRow = @nHight
			nLegendRow = @nHight + 2  # Skip one line after labels
		else
			nChartHeight = @nHight + nExtraHeight
			nXAxisRow = @nHight - 1
			nLabelsRow = @nHight
			nLegendRow = @nHight + 2  # Skip one line after x-axis
		ok

		# Bars area height
		nBarsAreaHeight = nXAxisRow - 1
		if @bShowValues or @bShowPercent
			nBarsAreaHeight = nXAxisRow - 2
		ok

		# Store layout
		oLayout.AddPair([:y_axis_col, nYAxisStart])
		oLayout.AddPair([:bars_start_col, nBarsStart])
		oLayout.AddPair([:bars_end_col, nBarsEnd])
		oLayout.AddPair([:x_axis_start_col, nXAxisStart])
		oLayout.AddPair([:x_axis_end_col, nXAxisEnd])
		oLayout.AddPair([:x_axis_row, nXAxisRow])
		oLayout.AddPair([:labels_row, nLabelsRow])
		oLayout.AddPair([:legend_row, nLegendRow])
		oLayout.AddPair([:chart_height, nChartHeight])
		oLayout.AddPair([:bars_area_height, nBarsAreaHeight])
		oLayout.AddPair([:total_width, nTotalWidth])
		oLayout.AddPair([:category_widths, aCategoryWidths])

		return oLayout

	def _drawYAxis(oLayout)
		nAxisCol = oLayout[:y_axis_col]
		nAxisRow = oLayout[:x_axis_row]

		for i = 2 to nAxisRow - 1
			@acCanvas[i][nAxisCol] = @cXAxisChar
		next

		@acCanvas[1][nAxisCol] = @cXArrowChar

	def _drawXAxis(oLayout)
		nAxisRow = oLayout[:x_axis_row]
		nStartCol = oLayout[:x_axis_start_col]
		nEndCol = oLayout[:x_axis_end_col]
		nYAxisCol = oLayout[:y_axis_col]

		for i = nStartCol to nEndCol
			@acCanvas[nAxisRow][i] = @cYAxisChar
		next

		if @bShowYAxis
			@acCanvas[nAxisRow][nYAxisCol] = @cOriginChar
		ok

		@acCanvas[nAxisRow][nEndCol] = @cYArrowChar

	def _drawMultiBars(oLayout)

		nCategories = len(@acCategories)
		nBarsStartCol = oLayout[:bars_start_col]
		nAxisRow = oLayout[:x_axis_row]
		nBarsAreaHeight = oLayout[:bars_area_height]
		aCategoryWidths = oLayout[:category_widths]

		nCurrentX = nBarsStartCol

		for i = 1 to nCategories

			nCategoryWidth = aCategoryWidths[i]

			# Calculate bars positioning within category
			nTotalBarsWidth = @nSeriesCount * @nBarWidth + (@nSeriesCount - 1) * @nSeriesInterSpace
			nBarsStartX = nCurrentX + floor((nCategoryWidth - nTotalBarsWidth) / 2)

			# Draw bars for each series in this category
			for j = 1 to @nSeriesCount

				if j <= len(@aaMultiValues) and i <= len(@aaMultiValues[j])

					nVal = @aaMultiValues[j][i]
					cSeriesChar = @acSeriesChars[j]

					# Calculate bar height
					if @nMaxValue = 0 or nVal = 0
						nBarHeight = 0
					else
						nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
					ok

					# Calculate this series bar position
					nBarX = nBarsStartX + (j - 1) * (@nBarWidth + @nSeriesInterSpace)

					# Draw bar
					if nBarHeight > 0

						for k = 1 to nBarHeight

							for l = 1 to @nBarWidth
								nCol = nBarX + l - 1
								nRow = nAxisRow - k

								if nCol <= @nWidth and nRow >= 1
									if k = nBarHeight and @cFinalBarChar != ""
										@acCanvas[nRow][nCol] = @cFinalBarChar
									else
										@acCanvas[nRow][nCol] = cSeriesChar
									ok
								ok

							next

						next

					ok
				ok
			next

			# Move to next category
			if i < nCategories
				nCurrentX += nCategoryWidth + @nCategoryInterSpace
			ok
		next

	def _drawMultiLabels(oLayout)

		nCategories = len(@acCategories)
		nBarsStartCol = oLayout[:bars_start_col]
		nLabelsRow = oLayout[:labels_row]
		aCategoryWidths = oLayout[:category_widths]

		nCurrentX = nBarsStartCol

		for i = 1 to nCategories

			if i <= len(@acCategories)

				nCategoryWidth = aCategoryWidths[i]
				cLabel = "" + Capitalize(@acCategories[i])
				nLabelLen = len(cLabel)

				if nLabelLen > @nMaxLabelWidth
					nLabelLen = @nMaxLabelWidth
					cLabel = StzStringQ(cLabel).Section(1, @nMaxLabelWidth - 2) + ".."
				ok

				# Center label within category
				nLabelStartX = nCurrentX + floor((nCategoryWidth - nLabelLen) / 2)

				for j = 1 to nLabelLen
					nCol = nLabelStartX + j - 1
					if nCol <= @nWidth and nLabelsRow <= len(@acCanvas)
						@acCanvas[nLabelsRow][nCol] = cLabel[j]
					ok
				next
			ok

			if i < nCategories
				nCurrentX += aCategoryWidths[i] + @nCategoryInterSpace
			ok
		next

	def _drawLegend(oLayout)
	
		nLegendRow = oLayout[:legend_row]
	
		# Ensure we have enough canvas rows
		if nLegendRow > len(@acCanvas)
			return
		ok
	
		# Build legend based on layout direction
		if @cLegendLayout = :Horizontal
		    # Original horizontal logic
		    cLegend = ""
		    nLenSeriesNames = len(@acSeriesNames)
		    nLenSeriesChars = len(@acSeriesChars)
		
		    for i = 1 to @nSeriesCount
		        if i <= nLenSeriesNames and i <= nLenSeriesChars
		            if i > 1
		                cLegend += "   "
		            ok
		            cLegend += @acSeriesChars[i] + @acSeriesChars[i] + " " + Capitalise(@acSeriesNames[i])
		        ok
		    next
		    
		    # Write horizontal legend (keep existing code for writing to canvas)
		    
		else  # Vertical layout
		    # Draw each legend item on separate rows
		    nLenSeriesNames = len(@acSeriesNames)
		    nLenSeriesChars = len(@acSeriesChars)
		    
		    for i = 1 to @nSeriesCount
		        if i <= nLenSeriesNames and i <= nLenSeriesChars
		            nCurrentRow = nLegendRow + i - 1
		            
		            # Ensure we have enough canvas rows
		            if nCurrentRow > len(@acCanvas)
		                return
		            ok
		            
		            cLegendItem = @acSeriesChars[i] + @acSeriesChars[i] + " " + Capitalise(@acSeriesNames[i])
		            nItemLen = len(cLegendItem)
		            
		            # Extend canvas row if needed
		            nCurrentRowWidth = len(@acCanvas[nCurrentRow])
		            if nItemLen > nCurrentRowWidth
		                for k = nCurrentRowWidth + 1 to nItemLen
		                    @acCanvas[nCurrentRow] + " "
		                next
		            ok
		            
		            # Write legend item
		            for j = 1 to nItemLen
		                @acCanvas[nCurrentRow][j] = cLegendItem[j]
		            next
		        ok
		    next
		    return  # Exit early for vertical layout
		ok
	
		# Extend canvas row if needed to fit legend
		nLegendLen = len(cLegend)
		nStartCol = 1
		nRequiredWidth = nStartCol + nLegendLen
		nCurrentRowWidth = len(@acCanvas[nLegendRow])
		
		if nRequiredWidth > nCurrentRowWidth
			# Extend this row with spaces
			for k = nCurrentRowWidth + 1 to nRequiredWidth
				@acCanvas[nLegendRow] + " "
			next
		ok
	
		# Write legend to canvas
		for j = 1 to nLegendLen
			nCol = nStartCol + j - 1
			@acCanvas[nLegendRow][nCol] = cLegend[j]
		next
	

	def _drawMultiValues(oLayout)
		
		nCategories = len(@acCategories)
		nBarsStartCol = oLayout[:bars_start_col]
		nAxisRow = oLayout[:x_axis_row] 
		nBarsAreaHeight = oLayout[:bars_area_height]
		aCategoryWidths = oLayout[:category_widths]
		
		# Calculate average row for conflict avoidance
		nOverallAvg = _calculateOverallAverage()
		nAvgRow = nAxisRow - ceil(nBarsAreaHeight * nOverallAvg / @nMaxValue)
		
		nCurrentX = nBarsStartCol
		
		for i = 1 to nCategories
			
			nCategoryWidth = aCategoryWidths[i]
			
			# Calculate bars positioning within category
			nTotalBarsWidth = @nSeriesCount * @nBarWidth + (@nSeriesCount - 1) * @nSeriesInterSpace
			nBarsStartX = nCurrentX + floor((nCategoryWidth - nTotalBarsWidth) / 2)
			
			# Draw values for each series in this category
			for j = 1 to @nSeriesCount
				
				if j <= len(@aaMultiValues) and i <= len(@aaMultiValues[j])
					
					nVal = @aaMultiValues[j][i]
					
					# Calculate bar height (same logic as _drawMultiBars)
					if @nMaxValue = 0 or nVal = 0
						nBarHeight = 1
					else
						nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
					ok
					
					# Calculate this series bar position
					nBarX = nBarsStartX + (j - 1) * (@nBarWidth + @nSeriesInterSpace)
					
					# Calculate value position (above bar)
					nValueRow = nAxisRow - nBarHeight - 1
					if nValueRow < 1
						nValueRow = 1
					ok
					
					# If value position conflicts with bar, move it above
					if nValueRow >= nAxisRow - nBarHeight
						nValueRow = max([1, nAxisRow - nBarHeight - 1])
					ok
					
					# Avoid average line conflict - move value up if necessary
					if @bShowAverage and nValueRow = nAvgRow
						nValueRow = max([1, nAvgRow - 1])
					ok
					
					cValue = "" + nVal
					nValueLen = len(cValue)
					
					# Center within bar width
					nValueStartX = nBarX + floor((@nBarWidth - nValueLen) / 2)
					
					# Draw value with bounds checking
					for k = 1 to nValueLen
						nCol = nValueStartX + k - 1
						if nCol <= @nWidth and nCol >= 1 and nValueRow >= 1
							@acCanvas[nValueRow][nCol] = cValue[k]
						ok
					next
				ok
			next
			
			# Move to next category
			if i < nCategories
				nCurrentX += nCategoryWidth + @nCategoryInterSpace
			ok
		next
	
	def _drawMultiPercent(oLayout)
		
		nCategories = len(@acCategories)
		nBarsStartCol = oLayout[:bars_start_col]
		nAxisRow = oLayout[:x_axis_row] 
		nBarsAreaHeight = oLayout[:bars_area_height]
		aCategoryWidths = oLayout[:category_widths]
		
		# Calculate overall sum for percentage calculations
		nOverallSum = _calculateOverallSum()
		
		# Calculate average row for conflict avoidance
		nOverallAvg = nOverallSum / (_getTotalValueCount())
		nAvgRow = nAxisRow - ceil(nBarsAreaHeight * nOverallAvg / @nMaxValue)
		
		nCurrentX = nBarsStartCol
		
		for i = 1 to nCategories
			
			nCategoryWidth = aCategoryWidths[i]
			
			# Calculate bars positioning within category
			nTotalBarsWidth = @nSeriesCount * @nBarWidth + (@nSeriesCount - 1) * @nSeriesInterSpace
			nBarsStartX = nCurrentX + floor((nCategoryWidth - nTotalBarsWidth) / 2)
			
			# Draw percentages for each series in this category
			for j = 1 to @nSeriesCount
				
				if j <= len(@aaMultiValues) and i <= len(@aaMultiValues[j])
					
					nVal = @aaMultiValues[j][i]
					
					# Calculate bar height (same logic as _drawMultiBars)
					if @nMaxValue = 0 or nVal = 0
						nBarHeight = 1
					else
						nBarHeight = max([1, ceil(nBarsAreaHeight * nVal / @nMaxValue)])
					ok
					
					# Calculate this series bar position
					nBarX = nBarsStartX + (j - 1) * (@nBarWidth + @nSeriesInterSpace)
					
					# Calculate value position (above bar)
					nValueRow = nAxisRow - nBarHeight - 1
					if nValueRow < 1
						nValueRow = 1
					ok
					
					# If value position conflicts with bar, move it above
					if nValueRow >= nAxisRow - nBarHeight
						nValueRow = max([1, nAxisRow - nBarHeight - 1])
					ok
					
					# Avoid average line conflict - move value up if necessary
					if @bShowAverage and nValueRow = nAvgRow
						nValueRow = max([1, nAvgRow - 1])
					ok
					
					# Format percentage with 1 decimal place
					nPercent = RoundN((nVal/nOverallSum)*100, 1)
					cValue = "" + nPercent + '%'
					nValueLen = len(cValue)
					
					# Center within bar width
					nValueStartX = nBarX + floor((@nBarWidth - nValueLen) / 2)
					
					# Draw value with bounds checking
					for k = 1 to nValueLen
						nCol = nValueStartX + k - 1
						if nCol <= @nWidth and nCol >= 1 and nValueRow >= 1
							@acCanvas[nValueRow][nCol] = cValue[k]
						ok
					next
				ok
			next
			
			# Move to next category
			if i < nCategories
				nCurrentX += nCategoryWidth + @nCategoryInterSpace
			ok
		next
	
	def _drawMultiAverageLine(oLayout)
		
		# Calculate overall average across all series
		nOverallAvg = _calculateOverallAverage()
		
		nBarsStartCol = oLayout[:bars_start_col]
		nBarsEndCol = oLayout[:bars_end_col] 
		nAxisRow = oLayout[:x_axis_row]
		nBarsAreaHeight = oLayout[:bars_area_height]
		nYAxisCol = oLayout[:y_axis_col]
		
		# Calculate average line position
		if @nMaxValue = 0
			nAvgRow = nAxisRow - 1
		else
			nAvgRow = nAxisRow - ceil(nBarsAreaHeight * nOverallAvg / @nMaxValue)
		ok
		
		# Start position: right after Y-axis if it exists, otherwise at bars start
		nLineStart = nBarsStartCol
		if @bShowYAxis
			nLineStart = nYAxisCol + 1
		ok
		
		# End position: one position beyond current end
		nLineEnd = nBarsEndCol + 1
		
		# Draw average line
		nLenCanvas = len(@acCanvas)
		for i = nLineStart to nLineEnd
			if i <= @nWidth and nAvgRow >= 1 and nAvgRow <= nLenCanvas
				# Don't overwrite bars
				if @acCanvas[nAvgRow][i] = " "
					@acCanvas[nAvgRow][i] = @cAverageChar
				ok
			ok
		next
		
		# Add average value/percent to the right of the line
		nOverallSum = _calculateOverallSum()
		if @bShowValues or @bShowPercent
			cAvgText = ""
			if @bShowValues
				cAvgText = "" + RoundN(nOverallAvg, 1)
			but @bShowPercent
				nAvgPercent = RoundN((nOverallAvg/nOverallSum)*100, 1)
				cAvgText = "" + nAvgPercent + '%'
			ok
			
			# Position text right after line end with a space
			nTextStart = nLineEnd + 2
			nTextLen = len(cAvgText)
			
			# Draw average text
			for j = 1 to nTextLen
				nCol = nTextStart + j - 1
				if nCol <= @nWidth and nAvgRow >= 1 and nAvgRow <= nLenCanvas
					@acCanvas[nAvgRow][nCol] = cAvgText[j]
				ok
			next
		ok
	
	# Helper methods for multi-series calculations
	
	def _calculateOverallAverage()
		nSum = _calculateOverallSum()
		nCount = _getTotalValueCount()
		if nCount = 0
			return 0
		ok
		return nSum / nCount

	def Average()
		return _calculateOverallAverage()

	def _calculateOverallSum()
		nSum = 0
		for i = 1 to @nSeriesCount
			if i <= len(@aaMultiValues)
				aCurrentSeries = @aaMultiValues[i]
				for j = 1 to len(aCurrentSeries)
					nSum += aCurrentSeries[j]
				next
			ok
		next
		return nSum

	def Sum()
		return _calculateOverallSum()
	
	def _getTotalValueCount()
		nCount = 0
		nLenMVal = len(@aaMultiValues)
		for i = 1 to @nSeriesCount
			if i <= nLenMVal
				nCount += len(@aaMultiValues[i])
			ok
		next
		return nCount


#------------------------------#
#  CLEAN CURVE CHART           #
#------------------------------#

#------------------------------#
#  CLEAN CURVE CHART           #
#------------------------------#

class stzMCurveChart from stzMultiCurveChart

class stzMultiCurveChart from stzChart

	# Multi-series container structure
	@aaMultiValues = []     # Array of arrays for each curve series
	@acSeriesNames = []     # Names of each curve series  
	@acSeriesChars = []     # Point characters for each series
	@acCategories = []      # X-axis category labels (shared across all series)
	@nSeriesCount = 0       # Number of curve series

	@bShowXAxis = True
	@bShowYAxis = True
	@bShowLabels = True
	@bShowAverage = False
	@bShowValues = False
	@bShowPercent = False
	@bShowLegend = True

	@nMaxWidth = 132
	@nMaxLabelWidth = 12
	@nPointSpacing = 3  # Horizontal spacing between data points

	# Curve drawing characters for different series
	@acPointChars = ["●", "○", "▲", "■", "□"]
	@cLineChar = "─"
	@cCornerTL = "╭"  # Top-left corner
	@cCornerTR = "╮"  # Top-right corner
	@cCornerBL = "╰"  # Bottom-left corner
	@cCornerBR = "╯"  # Bottom-right corner
	@cVerticalChar = "│"
	@cHorizontalChar = "─"

	# Layout constants
	@nYAxisWidth = 1
	@nAxisPadding = 1
	@nLabelPadding = 1

	def init(paMultiData)
		if CheckParams()
			if NOT isList(paMultiData)
				StzRaise("Can't create stzMultiCurveChart! paMultiData must be a list.")
			ok
		ok

		# Parse multi-series data structure
		_parseMultiSeriesData(paMultiData)
		_calculateMultiRange()


	def _parseMultiSeriesData(paMultiData)
		# Expected formats:
		# Single series: [ :Sales = [ :Jan = 15, :Feb = 28, :Mar = 23 ] ]
		# Multi series: [ :Revenue = [...], :Profit = [...], :Expenses = [...] ]

		@aaMultiValues = []
		@acSeriesNames = []
		@acCategories = []
		@nSeriesCount = 0

		# Handle hashlist input format
		oHashList = new stzHashList(paMultiData)
		aKeys = oHashList.Keys()
		aValues = oHashList.Values()

		for i = 1 to len(aKeys)
			cSeriesName = aKeys[i]
			aSeriesData = aValues[i]
			
			# Handle nested hashlist (category-value pairs)
			if isList(aSeriesData) and len(aSeriesData) > 0 and isList(aSeriesData[1])
				oSeriesHash = new stzHashList(aSeriesData)
				aSeriesCategories = oSeriesHash.Keys()
				aSeriesValues = oSeriesHash.Values()
				
				# Use categories from first series
				if len(@acCategories) = 0
					@acCategories = aSeriesCategories
				ok
				
				@acSeriesNames + cSeriesName
				@aaMultiValues + aSeriesValues
				@nSeriesCount++
			ok
		next

		# Generate default categories if still empty
		if len(@acCategories) = 0 and @nSeriesCount > 0
			nMaxPoints = 0
			for aSeries in @aaMultiValues
				if len(aSeries) > nMaxPoints
					nMaxPoints = len(aSeries)
				ok
			next
			
			for i = 1 to nMaxPoints
				@acCategories + ("" + i)
			next
		ok

		# Assign default point characters for each series
		@acSeriesChars = []
		for i = 1 to @nSeriesCount
			nCharIndex = ((i-1) % len(@acPointChars)) + 1
			@acSeriesChars + @acPointChars[nCharIndex]
		next


	def _calculateMultiRange()
		@nMaxValue = 0
		@nMinValue = 0
		
		if @nSeriesCount > 0
			# Find global min and max across all series
			for aSeries in @aaMultiValues
				for nValue in aSeries
					if nValue > @nMaxValue
						@nMaxValue = nValue
					ok
					if nValue < @nMinValue
						@nMinValue = nValue
					ok
				next
			next
		ok

		# Ensure we have a reasonable range
		if @nMaxValue = @nMinValue
			@nMaxValue = @nMinValue + 1
		ok

	def SeriesCount()
		return @nSeriesCount

	def SeriesNames()
		return @acSeriesNames

	def SeriesValues(nIndex)
		if nIndex >= 1 and nIndex <= @nSeriesCount
			return @aaMultiValues[nIndex]
		ok
		return []

	def Categories()
		return @acCategories

	def SetSeriesPointChar(nSeriesIndex, cChar)
		if nSeriesIndex >= 1 and nSeriesIndex <= @nSeriesCount
			@acSeriesChars[nSeriesIndex] = cChar
		ok

	def SetAllSeriesPointChars(acChars)
		if isList(acChars)
			for i = 1 to min([len(acChars), @nSeriesCount])
				@acSeriesChars[i] = acChars[i]
			next
		ok


	def SetXAxis(bShow)
		@bShowXAxis = bShow

		def SetHAxis(bShow)
			@bShowXAxis = bShow

		def WithoutXAxis()
			@bShowXAxis = FALSE

		def WithoutHAxis()
			@bShowXAxis = FALSE

	def SetYAxis(bShow)
		@bShowYAxis = bShow

		def SetVAxis(bShow)
			@bShowYAxis = bShow

		def WithoutYAxis()
			@bShowYAxis = FALSE

		def WithoutVAxis()
			@bShowYAxis = FALSE

	def SetXYAxis(bShow)
		if isList(bShow) and len(bShow) = 2
			@bShowXAxis = bShow[1]
			@bShowYAxis = bShow[2]
		else
			@bShowXAxis = bShow
			@bShowYAxis = bShow
		ok

		def SetXYAxies(bShow)
			This.SetXYAxis(bShow)

		def SetYXAxis(bShow)
			This.SetXYAxis(bShow)

		def SetBothAxis(bShow)
			This.SetXYAxis(bShow)

		def WithoutAxises()
			This.SetXYAxis(FALSE)

		def WithoutXYAxis()
			This.SetXYAxis(FALSE)

	def SetYLabels(bShow)
		@bShowLabels = bShow

		def SetLabels(bShow)
			This.SetYLabels(bShow)

		def AddYLabels()
			This.SetYLabels(_TRUE_)

		def AddLabels()
			This.SetYLabels(_TRUE_)

		def WithoutYLabels()
			@bShowLabels = FALSE

		def WithoutLabels()
			@bShowLabels = FALSE

	def SetAverageLine(bShow)
		@bShowAverage = bShow

		def SetAverage(bShow)
			@bShowAverage = bShow

		def AddAverage()
			@bShowAverage = _TRUE_

		def AddAverageLine()
			@bShowAverage = _TRUE_

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

	def SetPointSpacing(n)
		@nPointSpacing = max([2, n])

		def PointSpacing()
			return @nPointSpacing

	def SetMaxWidth(nWidth)
		@nMaxWidth = nWidth

		def MaxWidth()
			return @nMaxWidth

	def SetMaxLabelWidth(n)
		@nMaxLabelWidth = n

		def MaxLabelWidth()
			return @nMaxLabelWidth

	def SetPointChar(c)
		if CheckParams()
			if not IsChar(c)
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok
		@cPointChar = c


	def _initCanvas()
		@acCanvas = []
		for i = 1 to @nHight
			aRow = []
			for j = 1 to @nWidth
				aRow + " "
			next
			@acCanvas + aRow
		next


	def _finalizeCanvas()
		cResult = ""
		for i = 1 to len(@acCanvas)
			for j = 1 to len(@acCanvas[i])
				cResult += @acCanvas[i][j]
			next
			if i < len(@acCanvas)
				cResult += nl
			ok
		next

		return cResult

	def ToString()
		# Return empty chart if no data
		if @nSeriesCount = 0
			return "No data to display"
		ok

		# Step 1: Calculate layout dimensions
		oLayout = _calculateLayout()
		
		# Step 2: Initialize canvas
		@nWidth = oLayout[:total_width]
		@nHight = oLayout[:chart_height]
		_initCanvas()
		
		# Step 3: Draw components
		if @bShowYAxis
			_drawYAxis(oLayout)
		ok
		
		if @bShowXAxis  
			_drawXAxis(oLayout)
		ok
		
		if @bShowAverage
			_drawAverageLine(oLayout)
		ok

		_drawMultiCurves(oLayout)

		if @bShowValues
			_drawMultiValues(oLayout)
		ok
		
		if @bShowLabels
			_drawLabels(oLayout)
		ok

		return _finalizeCanvas()


	def _calculateLayout()
		if @nSeriesCount = 0 or len(@acCategories) = 0
			return new stzHashList([
				[:total_width, 20],
				[:chart_height, 10],
				[:curve_start_col, 5],
				[:x_axis_row, 8]
			])
		ok

		nPoints = len(@acCategories)
		oLayout = new stzHashList([])
		
		# Calculate curve area width
		nCurveAreaWidth = (nPoints - 1) * @nPointSpacing + 4
		
		# Calculate layout positions
		nYAxisStart = 1
		nYAxisEnd = nYAxisStart + @nYAxisWidth - 1
		
		nCurveStart = nYAxisEnd + 1
		if @bShowYAxis
			nCurveStart += @nAxisPadding
		ok
		
		nCurveEnd = nCurveStart + nCurveAreaWidth - 1
		
		nXAxisStart = nYAxisStart
		if @bShowYAxis
			nXAxisStart = nYAxisEnd + @nAxisPadding
		ok
		nXAxisEnd = nCurveEnd + @nAxisPadding
		
		# Calculate total width
		nTotalWidth = nXAxisEnd + 2
		
		# Calculate height - reduce spacing
		nChartHeight = 10
		nXAxisRow = nChartHeight - 1
		nLabelsRow = nChartHeight + 1  # Only 1 line gap
		
		if @bShowLabels
			nChartHeight = nLabelsRow
		ok
		
		# Calculate curve area height
		nCurveAreaHeight = nXAxisRow - 2
		
		# Store layout information
		oLayout.AddPair([:y_axis_col, nYAxisStart])
		oLayout.AddPair([:curve_start_col, nCurveStart])
		oLayout.AddPair([:curve_end_col, nCurveEnd])
		oLayout.AddPair([:x_axis_start_col, nXAxisStart])
		oLayout.AddPair([:x_axis_end_col, nXAxisEnd])
		oLayout.AddPair([:x_axis_row, nXAxisRow])
		oLayout.AddPair([:labels_row, nLabelsRow])
		oLayout.AddPair([:chart_height, nChartHeight])
		oLayout.AddPair([:curve_area_height, nCurveAreaHeight])
		oLayout.AddPair([:total_width, nTotalWidth])
		
		return oLayout

	def _drawYAxis(oLayout)
		nAxisCol = oLayout[:y_axis_col]
		nAxisRow = oLayout[:x_axis_row]
		
		# Draw vertical line
		for i = 2 to nAxisRow - 1
			if i <= len(@acCanvas) and nAxisCol <= len(@acCanvas[i])
				@acCanvas[i][nAxisCol] = @cXAxisChar
			ok
		next
		
		# Draw arrow at top
		if nAxisCol <= len(@acCanvas[1])
			@acCanvas[1][nAxisCol] = @cXArrowChar
		ok

	def _drawXAxis(oLayout)
		nAxisRow = oLayout[:x_axis_row]
		nStartCol = oLayout[:x_axis_start_col]
		nEndCol = oLayout[:x_axis_end_col]
		nYAxisCol = oLayout[:y_axis_col]
		
		# Bounds check
		if nAxisRow > len(@acCanvas)
			return
		ok
		
		# Draw horizontal line
		for i = nStartCol to min([nEndCol, len(@acCanvas[nAxisRow])])
			@acCanvas[nAxisRow][i] = @cYAxisChar
		next
		
		# Draw origin if Y-axis is present
		if @bShowYAxis and nYAxisCol <= len(@acCanvas[nAxisRow])
			@acCanvas[nAxisRow][nYAxisCol] = @cOriginChar
		ok
		
		# Draw arrow at end
		if nEndCol <= len(@acCanvas[nAxisRow])
			@acCanvas[nAxisRow][nEndCol] = @cYArrowChar
		ok

	def _drawMultiCurves(oLayout)
		# Draw each series
		for nSeries = 1 to @nSeriesCount
			_drawSingleCurve(nSeries, oLayout)
		next

	def _drawSingleCurve(nSeriesIndex, oLayout)
		if nSeriesIndex > @nSeriesCount
			return
		ok
		
		aValues = @aaMultiValues[nSeriesIndex]
		cPointChar = @acSeriesChars[nSeriesIndex]
		
		nPoints = len(aValues)
		nCurveStartCol = oLayout[:curve_start_col]
		nAxisRow = oLayout[:x_axis_row]
		nCurveAreaHeight = oLayout[:curve_area_height]
		
		if nPoints < 1
			return
		ok
		
		# Calculate point positions
		aPoints = []
		for i = 1 to nPoints
			nVal = aValues[i]
			nX = nCurveStartCol + (i-1) * @nPointSpacing
			
			if @nMaxValue = 0 or nVal = 0
				nY = nAxisRow - 1
			else
				nY = nAxisRow - ceil(nCurveAreaHeight * nVal / @nMaxValue)
			ok
			
			aPoints + [nX, nY]
		next
		
		# Draw curve lines between points
		for i = 1 to len(aPoints) - 1
			nX1 = aPoints[i][1]
			nY1 = aPoints[i][2]
			nX2 = aPoints[i+1][1]
			nY2 = aPoints[i+1][2]
			
			_drawCurveSegment(nX1, nY1, nX2, nY2)
		next
		
		# Draw points (after lines so they appear on top)
		for i = 1 to nPoints
			nX = aPoints[i][1]
			nY = aPoints[i][2]
			
			if nY >= 1 and nY <= len(@acCanvas) and nX >= 1 and nX <= len(@acCanvas[nY])
				@acCanvas[nY][nX] = cPointChar
			ok
		next

def _drawCurveSegment(nX1, nY1, nX2, nY2)
	# Draw curved lines between two points
	if nX1 = nX2
		# Vertical line
		nStartY = min([nY1, nY2])
		nEndY = max([nY1, nY2])
		for nY = nStartY to nEndY
			if nY >= 1 and nY <= len(@acCanvas) and nX1 >= 1 and nX1 <= len(@acCanvas[nY])
				if @acCanvas[nY][nX1] = " "
					@acCanvas[nY][nX1] = @cVerticalChar
				ok
			ok
		next
	else
		# Curved horizontal connection
		nStartX = min([nX1, nX2])
		nEndX = max([nX1, nX2])
		
		if nY1 = nY2
			# Pure horizontal line
			for nX = nStartX to nEndX
				if nY1 >= 1 and nY1 <= len(@acCanvas) and nX >= 1 and nX <= len(@acCanvas[nY1])
					if @acCanvas[nY1][nX] = " "
						@acCanvas[nY1][nX] = @cHorizontalChar
					ok
				ok
			next
		else
			# Curved connection between different Y levels
			nMidX = nX1 + floor((nX2 - nX1) / 2)
			
			# Determine curve direction
			bGoingUp = (nY2 < nY1)  # Lower Y values are higher on screen
			bGoingRight = (nX2 > nX1)
			
			if bGoingRight
				# Moving right
				if bGoingUp
					# Going right and up: use ╯ at start, ╭ at end
					# Horizontal from start
					for nX = nX1 to nMidX - 1
						if nY1 >= 1 and nY1 <= len(@acCanvas) and nX >= 1 and nX <= len(@acCanvas[nY1])
							if @acCanvas[nY1][nX] = " "
								@acCanvas[nY1][nX] = @cHorizontalChar
							ok
						ok
					next
					
					# Corner at transition point
					if nMidX >= 1 and nMidX <= @nWidth and nY1 >= 1 and nY1 <= len(@acCanvas)
						@acCanvas[nY1][nMidX] = @cCornerBR  # ╯
					ok
					
					# Vertical segment
					nStartY = min([nY1, nY2])
					nEndY = max([nY1, nY2])
					for nY = nStartY + 1 to nEndY - 1
						if nY >= 1 and nY <= len(@acCanvas) and nMidX >= 1 and nMidX <= len(@acCanvas[nY])
							if @acCanvas[nY][nMidX] = " "
								@acCanvas[nY][nMidX] = @cVerticalChar
							ok
						ok
					next
					
					# Corner at end
					if nMidX >= 1 and nMidX <= @nWidth and nY2 >= 1 and nY2 <= len(@acCanvas)
						@acCanvas[nY2][nMidX] = @cCornerTL  # ╭
					ok
					
					# Horizontal to end point
					for nX = nMidX + 1 to nX2
						if nY2 >= 1 and nY2 <= len(@acCanvas) and nX >= 1 and nX <= len(@acCanvas[nY2])
							if @acCanvas[nY2][nX] = " "
								@acCanvas[nY2][nX] = @cHorizontalChar
							ok
						ok
					next
				else
					# Going right and down: use ╮ at start, ╰ at end
					# Horizontal from start
					for nX = nX1 to nMidX - 1
						if nY1 >= 1 and nY1 <= len(@acCanvas) and nX >= 1 and nX <= len(@acCanvas[nY1])
							if @acCanvas[nY1][nX] = " "
								@acCanvas[nY1][nX] = @cHorizontalChar
							ok
						ok
					next
					
					# Corner at transition point
					if nMidX >= 1 and nMidX <= @nWidth and nY1 >= 1 and nY1 <= len(@acCanvas)
						@acCanvas[nY1][nMidX] = @cCornerTR  # ╮
					ok
					
					# Vertical segment
					nStartY = min([nY1, nY2])
					nEndY = max([nY1, nY2])
					for nY = nStartY + 1 to nEndY - 1
						if nY >= 1 and nY <= len(@acCanvas) and nMidX >= 1 and nMidX <= len(@acCanvas[nY])
							if @acCanvas[nY][nMidX] = " "
								@acCanvas[nY][nMidX] = @cVerticalChar
							ok
						ok
					next
					
					# Corner at end
					if nMidX >= 1 and nMidX <= @nWidth and nY2 >= 1 and nY2 <= len(@acCanvas)
						@acCanvas[nY2][nMidX] = @cCornerBL  # ╰
					ok
					
					# Horizontal to end point
					for nX = nMidX + 1 to nX2
						if nY2 >= 1 and nY2 <= len(@acCanvas) and nX >= 1 and nX <= len(@acCanvas[nY2])
							if @acCanvas[nY2][nX] = " "
								@acCanvas[nY2][nX] = @cHorizontalChar
							ok
						ok
					next
				ok
			else
				# Moving left - mirror the logic
				if bGoingUp
					# Going left and up: use ╯ at start, ╭ at end
					for nX = nX1 to nMidX + 1 step -1
						if nY1 >= 1 and nY1 <= len(@acCanvas) and nX >= 1 and nX <= len(@acCanvas[nY1])
							if @acCanvas[nY1][nX] = " "
								@acCanvas[nY1][nX] = @cHorizontalChar
							ok
						ok
					next
					
					if nMidX >= 1 and nMidX <= @nWidth and nY1 >= 1 and nY1 <= len(@acCanvas)
						@acCanvas[nY1][nMidX] = @cCornerBR  # ╯
					ok
					
					nStartY = min([nY1, nY2])
					nEndY = max([nY1, nY2])
					for nY = nStartY + 1 to nEndY - 1
						if nY >= 1 and nY <= len(@acCanvas) and nMidX >= 1 and nMidX <= len(@acCanvas[nY])
							if @acCanvas[nY][nMidX] = " "
								@acCanvas[nY][nMidX] = @cVerticalChar
							ok
						ok
					next
					
					if nMidX >= 1 and nMidX <= @nWidth and nY2 >= 1 and nY2 <= len(@acCanvas)
						@acCanvas[nY2][nMidX] = @cCornerTL  # ╭
					ok
					
					for nX = nMidX - 1 to nX2 step -1
						if nY2 >= 1 and nY2 <= len(@acCanvas) and nX >= 1 and nX <= len(@acCanvas[nY2])
							if @acCanvas[nY2][nX] = " "
								@acCanvas[nY2][nX] = @cHorizontalChar
							ok
						ok
					next
				else
					# Going left and down: use ╮ at start, ╰ at end
					for nX = nX1 to nMidX + 1 step -1
						if nY1 >= 1 and nY1 <= len(@acCanvas) and nX >= 1 and nX <= len(@acCanvas[nY1])
							if @acCanvas[nY1][nX] = " "
								@acCanvas[nY1][nX] = @cHorizontalChar
							ok
						ok
					next
					
					if nMidX >= 1 and nMidX <= @nWidth and nY1 >= 1 and nY1 <= len(@acCanvas)
						@acCanvas[nY1][nMidX] = @cCornerTR  # ╮
					ok
					
					nStartY = min([nY1, nY2])
					nEndY = max([nY1, nY2])
					for nY = nStartY + 1 to nEndY - 1
						if nY >= 1 and nY <= len(@acCanvas) and nMidX >= 1 and nMidX <= len(@acCanvas[nY])
							if @acCanvas[nY][nMidX] = " "
								@acCanvas[nY][nMidX] = @cVerticalChar
							ok
						ok
					next
					
					if nMidX >= 1 and nMidX <= @nWidth and nY2 >= 1 and nY2 <= len(@acCanvas)
						@acCanvas[nY2][nMidX] = @cCornerBL  # ╰
					ok
					
					for nX = nMidX - 1 to nX2 step -1
						if nY2 >= 1 and nY2 <= len(@acCanvas) and nX >= 1 and nX <= len(@acCanvas[nY2])
							if @acCanvas[nY2][nX] = " "
								@acCanvas[nY2][nX] = @cHorizontalChar
							ok
						ok
					next
				ok
			ok
		ok
	ok

	def _drawMultiValues(oLayout)
		# Draw values for each series
		for nSeries = 1 to @nSeriesCount
			_drawSeriesValues(nSeries, oLayout)
		next

	def _drawSeriesValues(nSeriesIndex, oLayout)
		if nSeriesIndex > @nSeriesCount
			return
		ok
		
		aValues = @aaMultiValues[nSeriesIndex]
		nPoints = len(aValues)
		nCurveStartCol = oLayout[:curve_start_col]
		nAxisRow = oLayout[:x_axis_row]
		nCurveAreaHeight = oLayout[:curve_area_height]
		
		for i = 1 to nPoints
			nVal = aValues[i]
			nX = nCurveStartCol + (i-1) * @nPointSpacing
			
			if @nMaxValue = 0 or nVal = 0
				nPointY = nAxisRow - 1
			else
				nPointY = nAxisRow - ceil(nCurveAreaHeight * nVal / @nMaxValue)
			ok
			
			# Position value above the point (offset by series to avoid overlap)
			nValueY = max([1, nPointY - 1 - (nSeriesIndex-1)])
			
			cValue = "" + nVal
			nValueLen = len(cValue)
			nValueStartX = nX - floor(nValueLen / 2)
			
			# Draw value
			for k = 1 to nValueLen
				nCol = nValueStartX + k - 1
				if nCol >= 1 and nCol <= @nWidth and nValueY >= 1 and nValueY <= len(@acCanvas)
					@acCanvas[nValueY][nCol] = cValue[k]
				ok
			next
		next

	def _drawLabels(oLayout)
		nPoints = len(@acCategories)
		nCurveStartCol = oLayout[:curve_start_col]
		nLabelsRow = oLayout[:labels_row]
		
		for i = 1 to nPoints
			nX = nCurveStartCol + (i-1) * @nPointSpacing
			
			cLabel = @acCategories[i]
			nLenLabel = len(cLabel)
			
			# Truncate label if needed
			if nLenLabel > @nMaxLabelWidth
				nLenLabel = @nMaxLabelWidth
				cLabel = left(cLabel, @nMaxLabelWidth - 2) + ".."
			ok
			
			# Center label under the point
			nLabelStartX = nX - floor(nLenLabel / 2)
			
			# Draw label
			for j = 1 to nLenLabel
				nCol = nLabelStartX + j - 1
				if nCol >= 1 and nCol <= @nWidth and nLabelsRow <= len(@acCanvas)
					@acCanvas[nLabelsRow][nCol] = cLabel[j]
				ok
			next
		next

	def _drawAverageLine(oLayout)
		# Calculate global average across all series
		nTotalSum = 0
		nTotalCount = 0
		
		for aSeries in @aaMultiValues
			for nVal in aSeries
				nTotalSum += nVal
				nTotalCount++
			next
		next
		
		if nTotalCount = 0
			return
		ok
		
		nAvg = nTotalSum / nTotalCount
		
		nCurveStartCol = oLayout[:curve_start_col]
		nCurveEndCol = oLayout[:curve_end_col]
		nAxisRow = oLayout[:x_axis_row]
		nCurveAreaHeight = oLayout[:curve_area_height]
		nYAxisCol = oLayout[:y_axis_col]
		
		# Calculate average line position
		if @nMaxValue = 0
			nAvgRow = nAxisRow - 1
		else
			nAvgRow = nAxisRow - ceil(nCurveAreaHeight * nAvg / @nMaxValue)
		ok
		
		# Start position
		nLineStart = nCurveStartCol
		if @bShowYAxis
			nLineStart = nYAxisCol + 1
		ok
		
		# End position
		nLineEnd = nCurveEndCol
		
		# Draw average line
		for i = nLineStart to nLineEnd
			if i <= @nWidth and nAvgRow <= len(@acCanvas) and @acCanvas[nAvgRow][i] = " "
				@acCanvas[nAvgRow][i] = @cAverageChar
			ok
		next

	def Show()
		? This.ToString()


	def _drawCurve(oLayout)
		nPoints = len(@anValues)
		nCurveStartCol = oLayout[:curve_start_col]
		nAxisRow = oLayout[:x_axis_row]
		nCurveAreaHeight = oLayout[:curve_area_height]
		
		if nPoints < 2
			return
		ok
		
		# Calculate point positions
		aPoints = []
		for i = 1 to nPoints
			nVal = @anValues[i]
			nX = nCurveStartCol + (i-1) * @nPointSpacing
			
			if @nMaxValue = 0 or nVal = 0
				nY = nAxisRow - 1
			else
				nY = nAxisRow - ceil(nCurveAreaHeight * nVal / @nMaxValue)
			ok
			
			aPoints + [nX, nY]
		next
		
		# Draw curve segments between points
		for i = 1 to len(aPoints) - 1
			nX1 = aPoints[i][1]
			nY1 = aPoints[i][2]
			nX2 = aPoints[i+1][1]
			nY2 = aPoints[i+1][2]
			
			_drawCurveSegment(nX1, nY1, nX2, nY2)
		next


	def _drawValues(oLayout)
		nPoints = len(@anValues)
		nCurveStartCol = oLayout[:curve_start_col]
		nAxisRow = oLayout[:x_axis_row]
		nCurveAreaHeight = oLayout[:curve_area_height]
		
		for i = 1 to nPoints
			nVal = @anValues[i]
			nX = nCurveStartCol + (i-1) * @nPointSpacing
			
			if @nMaxValue = 0 or nVal = 0
				nPointY = nAxisRow - 1
			else
				nPointY = nAxisRow - ceil(nCurveAreaHeight * nVal / @nMaxValue)
			ok
			
			# Position value above the point
			nValueY = max([1, nPointY - 1])
			
			cValue = "" + nVal
			nValueLen = len(cValue)
			nValueStartX = nX - floor(nValueLen / 2)
			
			# Draw value
			for k = 1 to nValueLen
				nCol = nValueStartX + k - 1
				if nCol >= 1 and nCol <= @nWidth and nValueY >= 1
					@acCanvas[nValueY][nCol] = cValue[k]
				ok
			next
		next

	def _drawPercent(oLayout)
		nPoints = len(@anValues)
		nCurveStartCol = oLayout[:curve_start_col]
		nAxisRow = oLayout[:x_axis_row]
		nCurveAreaHeight = oLayout[:curve_area_height]
		nSum = This.Sum()
		
		for i = 1 to nPoints
			nVal = @anValues[i]
			nX = nCurveStartCol + (i-1) * @nPointSpacing
			
			if @nMaxValue = 0 or nVal = 0
				nPointY = nAxisRow - 1
			else
				nPointY = nAxisRow - ceil(nCurveAreaHeight * nVal / @nMaxValue)
			ok
			
			# Position percentage above the point
			nValueY = max([1, nPointY - 1])
			
			nPercent = RoundN((nVal/nSum)*100, 1)
			cValue = "" + nPercent + '%'
			nValueLen = len(cValue)
			nValueStartX = nX - floor(nValueLen / 2)
			
			# Draw percentage
			for k = 1 to nValueLen
				nCol = nValueStartX + k - 1
				if nCol >= 1 and nCol <= @nWidth and nValueY >= 1
					@acCanvas[nValueY][nCol] = cValue[k]
				ok
			next
		next

