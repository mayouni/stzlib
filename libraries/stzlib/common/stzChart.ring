/*
A class for ascii-based charts, working with stzTable and stzPivotTable
# Softanza Chart System Design

## Core Philosophy

The Softanza Chart System is designed to create expressive ASCII-based visualizations that are:
1. **Purpose-driven** - Charts are categorized by analytical intent: comparison, relation, composition, distribution
2. **Modular** - Easy to extend with new chart types via inheritance
3. **Clean yet expressive** - Modern ASCII design that conveys information clearly
4. **Insightful** - Provides automatic insights and suggestions for further exploration

#TODO: Learn from IBM offering for data anlytics to empower
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

/*
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

		def SetVAxis(c)
			This.SetXAxisChar(c)

		def XAxisChar()
			return @cXAxisChar

		def VAxisChar()
			return @cXAxisChar


	def SetYAxisChar(c)
		if CheckParams()
			if NOT (isString(c) and IsChar(c))
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		@cYAxisChar = c

		def SetHAxisChar(c)
			This.SetYAxisChar(c)

		def YAxisChar()
			return @cYAxisChar

		def HAxisChar()
			return @cYAxisChar

	def SetXArrowChar(c)
		if CheckParams()
			if NOT (isString(c) and IsChar(c))
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		@cXArrowChar = c

		def SetVArrowChar(c)
			This.SetXArrowChar(c)

		def XArrowChar()
			return @cXArrowChar

		def VArrowChar()
			return @cXArrowChar

	def SetYArrowChar(c)
		if CheckParams()
			if NOT (isString(c) and IsChar(c))
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		@cYArrowChar = c

		def SetHArrowChar(c)
			This.SetYArrowChar(c)

		def YArrowChar()
			return @cYArrowChar

		def HArrowChar()
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

		# A hack to add an empty at the top of the X Axis
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


		def _drawHAxis(oLayout)
			This._drawYAxis(oLayout)

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


		def _drawVAxis(oLayout)
			This._drawXAxis(oLayout)

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

		def SetVAxis(bShow)
			@bShowXAxis = bShow

	def SetYAxis(bShow)
		@bShowYAxis = bShow

		def SetHAxis(bShow)
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


#-------------------------#
#  HISTOGRAM CHART CLASS  #
#-------------------------#

class stzHistogram from stzChart

	@bShowXAxis = True
	@bShowYAxis = True
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
	@anRawData = []      # Original data before binning

	# Layout constants
	@nYAxisWidth = 1
	@nAxisPadding = 1
	@nLabelPadding = 1

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
			nDecimals = iff(floor(nBinMin) = nBinMin and floor(nBinMax) = nBinMax, 0, 1)
			cLabel = _formatNumber(nBinMin) + "-" + _formatNumber(nBinMax)

			@aBinLabels + cLabel
		next


	def _findBinIndex(nValue)
		
		for i = 1 to len(@aBinRanges)
			nMin = @aBinRanges[i][1]
			nMax = @aBinRanges[i][2]
			
			# Last bin includes maximum value
			if i = len(@aBinRanges)
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

	def SetStats(bShow) # Displays a recap of stats line at the bottom
		@bShowStats = bShow

		def AddStats()
			@bShowStats = TRUE

		def IncludeStats()
			@bShowStats = TRUE

	# Inherit and adapt bar chart methods

	def SetXAxis(bShow)
		@bShowXAxis = bShow

		def AddXAxis(bShow)
			@bShowXAxis = bShow

		def IncludeXAxis(bShow)
			@bShowXAxis = bShow

		def WithoutXAxis()
			@bShowXAxis = FALSE

		#--

		def SetVAxis(bShow)
			@bShowXAxis = bShow

		def AddVAxis(bShow)
			@bShowXAxis = bShow

		def IncludeVAxis(bShow)
			@bShowXAxis = bShow

		def WithoutVAxis()
			@bShowXAxis = FALSE

	def SetYAxis(bShow)
		@bShowYAxis = bShow

		def AddYAxis(bShow)
			@bShowXAxis = bShow

		def IncludeYAxis(bShow)
			@bShowYAxis = bShow

		def WithoutYAxis()
			@bShowYAxis = FALSE

		#--

		def SetHAxis(bShow)
			@bShowYAxis = bShow

		def AddHAxis(bShow)
			@bShowYAxis = bShow

		def IncludeHAxis(bShow)
			@bShowYAxis = bShow

		def WithoutHAxis()
			@bShowYAxis = FALSE


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

	#--- AGGREGATION

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
		
		# Set up parent class data
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

	
	#--- DISPLAY

	def Show()
		? This.ToString()

	def ToString()
		
		# Use the same layout logic as bar chart
		oLayout = _calculateLayout()
		
		@nWidth = oLayout[:total_width]
		@nHight = oLayout[:chart_height]
		_initCanvas()
		
		# Draw components
		if @bShowYAxis
			_drawYAxis(oLayout)
		ok
		
		if @bShowXAxis  
			_drawXAxis(oLayout)
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

		# A hack to remove an unncessary empty line from the top
		if @bShowXAxis = FALSE

			oStrTemp = new stzString(cResult)
			nPos = oStrTemp.FindFirst(NL)
			oStrTemp.RemoveSection(1, nPos)
			cResult = oStrTemp.Content()
		ok

		# A hack to add an empty at the top of the X Axis

		if ring_substr1(cResult, @cXArrowChar) > 0

			oStrTemp = new stzString(cResult)
			nPos = oStrTemp.FindNth(1, NL)
			bFirstLineIsEmpty = @trim(oStrTemp.Section(4, nPos-1)) = ""

			if NOT bFirstLineIsEmpty # then add an empty line
				cResult = ring_substr2(cResult, @cXArrowChar, @cXAxisChar)
				cResult = @cXArrowChar + NL + cResult
			ok

		ok

		# Add statistics if requested
		if @bShowStats

			cStats = NL + NL +
				"Mean: " + RoundN(This.Mean(), 2) + NL +
			    "StdDev: " + RoundN(This.StandardDeviation(), 2) + NL +
			    "Median: " + RoundN(This.Median(), 2) + NL +
			    "Count: " + This.DataCount()

			cResult += cStats
		ok
	
		return cResult


	# Reuse bar chart drawing methods with minor adaptations
	def _calculateLayout()
		# Delegate to bar chart logic - works the same for histograms
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
		        cPercent = roundN((@anValues[i]/nSum)*100, 1)
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
		for i = 1 to len(aElementWidths)
			nBarsAreaWidth += aElementWidths[i]
		next
		for i = 1 to len(aBarSpacing)
			nBarsAreaWidth += aBarSpacing[i]
		next
		
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
		
		if nTotalWidth > @nMaxWidth
			StzRaise("Histogram width (" + nTotalWidth + ") exceeds maximum (" + @nMaxWidth + ")")
		ok
		
		# Estimate initial height for calculation
		nEstimatedHeight = @nHight
		if nEstimatedHeight = 0
			nEstimatedHeight = 20  # Default estimate
		ok
		
		# Calculate chart height based on requirements
		if @bShowLabels
			nChartHeight = nEstimatedHeight + 1  # Add one more row for two-line labels
			nXAxisRow = nEstimatedHeight - 1
			nLabelsRow = nEstimatedHeight + 1
		else
			nChartHeight = nEstimatedHeight
			nXAxisRow = nEstimatedHeight - 1  
			nLabelsRow = nEstimatedHeight
		ok
		
		# Calculate bars area height
		nBarsAreaHeight = nXAxisRow - 1
		if @bShowValues or @bShowPercent
			nBarsAreaHeight = nXAxisRow - 2
		ok
		
		# Now calculate required height based on actual bar heights
		nRequiredHeight = This._getRequiredHeight(nBarsAreaHeight)
		
		# Recalculate final positions with correct height
		if @bShowLabels
			nChartHeight = nRequiredHeight + 1
			nXAxisRow = nRequiredHeight - 1
			nLabelsRow = nRequiredHeight + 1
		else
			nChartHeight = nRequiredHeight
			nXAxisRow = nRequiredHeight - 1
			nLabelsRow = nRequiredHeight
		ok
		
		# Update @nHight to match calculated height
		@nHight = nChartHeight
		
		# Recalculate bars area height with final positions
		nBarsAreaHeight = nXAxisRow - 1
		if @bShowValues or @bShowPercent
			nBarsAreaHeight = nXAxisRow - 2
		ok
		
		oLayout.AddPair([:y_axis_col, nYAxisStart])
		oLayout.AddPair([:bars_start_col, nBarsStart]) 
		oLayout.AddPair([:bars_end_col, nBarsEnd])
		oLayout.AddPair([:x_axis_start_col, nXAxisStart])
		oLayout.AddPair([:x_axis_end_col, nXAxisEnd])
		oLayout.AddPair([:x_axis_row, nXAxisRow])
		oLayout.AddPair([:labels_row, nLabelsRow])
		oLayout.AddPair([:chart_height, nChartHeight])
		oLayout.AddPair([:bars_area_height, nBarsAreaHeight])
		oLayout.AddPair([:total_width, nTotalWidth])
		oLayout.AddPair([:element_widths, aElementWidths])
		oLayout.AddPair([:bar_spacing, aBarSpacing])
		
		return oLayout


	# Delegate drawing methods to bar chart implementations

	def _drawYAxis(oLayout)
		nAxisCol = oLayout[:y_axis_col]
		nAxisRow = oLayout[:x_axis_row]
		
		# Draw axis from row 2 to avoid overwriting arrow
		for i = 2 to nAxisRow - 1
			@acCanvas[i][nAxisCol] = @cXAxisChar
		next
		
		# Place arrow at the top (row 1)
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



	def _drawBars(oLayout)
		# Same logic as bar chart but with improved height calculation for histograms
		nBars = len(@anValues)
		nBarsStartCol = oLayout[:bars_start_col] 
		nAxisRow = oLayout[:x_axis_row]
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
		
		for i = 1 to len(@anValues)
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
		nAxisRow = oLayout[:x_axis_row] 
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
		nAxisRow = oLayout[:x_axis_row] 
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
				cLabel1 = _formatNumber(@aBinRanges[i][1])
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
				cLabel2 = _formatNumber(@aBinRanges[i][2])
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


	def _formatNumber(nNumber)
	    if nNumber >= 1000
	        return '' + RoundN(nNumber/1000, 1) + "K"
	    else
	        return "" + RoundN(nNumber, 0)
	    ok

#---------------------------------------#
#  TREEMAP COMPOSITTION-ORIENTED CHART  #
#---------------------------------------#

class stzTreeChart from stzChart

	@bShowPercent = FALSE
	@bShowBorders = TRUE
	@bShowLabels = TRUE
	@bShowValues = FALSE

	@nMinWidth = 40
	@nMinHeight = 12
	@nMaxWidth = 120
	@nMaxHeight = 30
	
	@nWidth = 40
	@nHeight = 12
	@nMinLabelWidth = 3  # Minimum characters to show from label

	# Border characters
	@cTopLeft = "╭"
	@cTopRight = "╮"
	@cBottomLeft = "╰"
	@cBottomRight = "╯"
	@cHorizontal = "─"
	@cVertical = "│"
	@cTeeDown = "┬"
	@cTeeUp = "┴"
	@cTeeRight = "├"
	@cTeeLeft = "┤"
	@cCross = "┼"

	@aRectangles = []
	@nSum = 0
	@anValues = []
	@acLabels = []
	@acCanvas = []
	@bShowLegend = FALSE
	@aLegend = []


def init(paData)

	if CheckParams()

		if NOT isList(paData)
			StzRaise("Can't create the stzChart object! paData must be a list.")
		ok

		if NOT (IsListOfNumbers(paData) or IsHashList(paData))
			StzRaise("Can't create the stzChart object! paData must be a list of numbers or a hashlist.")
		ok

	ok

	# In case a list of numbers is provided (the dataset
	# contains no labels ~> Added automatically as :1, :2, etc.

	if IsListOfNumbers(paData)

		aTemp = []
		nLen = len(paData)

		for i = 1 to nLen
			aTemp + [ ""+i, paData[i] ]
		next

		paData = aTemp
	ok

	# Forming the object container attributes from the hashlist

	oHash = new stzHashList(paData)
	@anValues = oHash.Values()
	@acLabels = oHash.Keys()

	if NOT IsListOfPositiveNumbers(@anValues)
		StzRaise("Incorrect param value! You must provide only positive numbers.")
	ok

	@nSum = @Sum(@anValues)	
	_calculateTreemap()


	def AddPercent()
		@bShowPercent = TRUE
		return This

		def SetPercent(bShow)
			@bShowPercent = bShow
			return This

		def IncludePercent()
			@bShowPercent = TRUE
			return This

	def AddValues()
		@bShowValues = TRUE
		return This

		def SetValues(bShow)
			@bShowValues = bShow
			return This

		def IncludeValues()
			@bShowValues = TRUE
			return This

	def WithoutBorders()
		@bShowBorders = FALSE
		return This

	def SetBorders(bShow)
		@bShowBorders = bShow
		return This

	def WithoutLabels()
		@bShowLabels = FALSE
		return This

	def SetLabels(bShow)
		@bShowLabels = bShow
		return This

	def AddLegend()
		@bShowLegend = TRUE
		return This

	def SetLegend(bShow)
		@bShowLegend = bShow
		return This

	def IncludeLegend()
		@bShowLegend = TRUE
		return This

	def SetSize(nWidth, nHeight)
		if CheckParams()
			if NOT (isNumber(nWidth) and isNumber(nHeight))
				StzRaise("Incorrect param type! nWidth and nHeight must be both numbers.")
			ok
		ok

		@nWidth = max([@nMinWidth, nWidth])
		@nHeight = max([@nMinHeight, nHeight])

		if @nWidth > @nMaxWidth
			@nWidth = @nMaxWidth
		ok
		
		if @nHeight > @nMaxHeight
			@nHeight = @nMaxHeight
		ok

		_calculateTreemap()
		return This

		def SetDimensions(nWidth, nHeight)
			return This.SetSize(nWidth, nHeight)

	def Show()
		? This.ToString()

	def ToString()
		_autoResize()  # Auto-resize based on content needs
		_calculateTreemap()
		_initCanvas()
		
		if @bShowBorders
			_drawBorders()
			_connectBordersToOuter()
		ok
		
		_drawContent()
		
		return _finalizeCanvas()

	def _autoResize()
		# Calculate minimum size needed for labels
		nMaxLabelLen = 0
		for i = 1 to len(@acLabels)
			if len(@acLabels[i]) > nMaxLabelLen
				nMaxLabelLen = len(@acLabels[i])
			ok
		next
		
		# Calculate minimum width needed
		nMinNeededWidth = max([@nMinWidth, nMaxLabelLen + 4])  # +4 for borders and spacing
		if @nWidth < nMinNeededWidth
			@nWidth = min([nMinNeededWidth, @nMaxWidth])
		ok
		
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
		for i = 1 to @nHeight
			for j = 1 to @nWidth
				cResult += @acCanvas[i][j]
			next
			if i < @nHeight
				cResult += nl
			ok
		next
		return cResult

	def _calculateTreemap()
		@aRectangles = []
		nValues = len(@anValues)
		
		if nValues = 0
			return
		ok
		
		# Sort values by size (descending) for better layout
		aSorted = []
		for i = 1 to nValues
			aSorted + [@anValues[i], @acLabels[i], i]
		next
		
		# Simple bubble sort (descending)
		for i = 1 to len(aSorted) - 1
			for j = i + 1 to len(aSorted)
				if aSorted[i][1] < aSorted[j][1]
					temp = aSorted[i]
					aSorted[i] = aSorted[j]
					aSorted[j] = temp
				ok
			next
		next
		
		# Calculate available area (excluding borders if shown)
		nAvailWidth = @nWidth
		nAvailHeight = @nHeight
		
		if @bShowBorders
			nAvailWidth -= 2
			nAvailHeight -= 2
		ok
		
		nTotalArea = nAvailWidth * nAvailHeight
		
		# Calculate rectangles using squarified treemap algorithm (simplified)
		_squarifyLayout(aSorted, 1, 1, nAvailWidth, nAvailHeight, nTotalArea)

	def _squarifyLayout(aSorted, nX, nY, nWidth, nHeight, nTotalArea)
		
		nLen = len(aSorted)
		if nLen = 0
			return
		ok
		
		if nLen = 1
			# Single rectangle fills the space
			nValue = aSorted[1][1]
			cLabel = aSorted[1][2]
			nIndex = aSorted[1][3]
			
			@aRectangles + [nX, nY, nWidth, nHeight, nValue, cLabel, nIndex]
			return
		ok
		
		# Improved treemap layout - better space utilization
		if nLen <= 4
			# Small number of rectangles - create a 2x2 or similar grid
			_createGridLayout(aSorted, nX, nY, nWidth, nHeight)
		else
			# Larger number - use recursive division
			_recursiveDivision(aSorted, nX, nY, nWidth, nHeight)
		ok

	def _createGridLayout(aSorted, nX, nY, nWidth, nHeight)
		nLen = len(aSorted)
		
		if nLen = 2
			# Two rectangles - divide by larger dimension
			if nWidth > nHeight
				# Split horizontally
				nValue1 = aSorted[1][1]
				nValue2 = aSorted[2][1]
				nTotal = nValue1 + nValue2
				nWidth1 = max([1, floor((nValue1 / nTotal) * nWidth)])
				nWidth2 = nWidth - nWidth1
				
				@aRectangles + [nX, nY, nWidth1, nHeight, nValue1, aSorted[1][2], aSorted[1][3]]
				@aRectangles + [nX + nWidth1, nY, nWidth2, nHeight, nValue2, aSorted[2][2], aSorted[2][3]]
			else
				# Split vertically
				nValue1 = aSorted[1][1]
				nValue2 = aSorted[2][1]
				nTotal = nValue1 + nValue2
				nHeight1 = max([1, floor((nValue1 / nTotal) * nHeight)])
				nHeight2 = nHeight - nHeight1
				
				@aRectangles + [nX, nY, nWidth, nHeight1, nValue1, aSorted[1][2], aSorted[1][3]]
				@aRectangles + [nX, nY + nHeight1, nWidth, nHeight2, nValue2, aSorted[2][2], aSorted[2][3]]
			ok
			
		but nLen = 3
			# Three rectangles - one large, two smaller
			nLargest = aSorted[1][1]
			nSecond = aSorted[2][1]
			nThird = aSorted[3][1]
			nTotal = nLargest + nSecond + nThird
			
			if nWidth > nHeight
				# Horizontal layout: largest left, two on right
				nWidth1 = max([1, floor((nLargest / nTotal) * nWidth)])
				nWidth2 = nWidth - nWidth1
				
				# Largest rectangle on left
				@aRectangles + [nX, nY, nWidth1, nHeight, nLargest, aSorted[1][2], aSorted[1][3]]
				
				# Two smaller on right, split vertically
				nSubTotal = nSecond + nThird
				nHeight1 = max([1, floor((nSecond / nSubTotal) * nHeight)])
				nHeight2 = nHeight - nHeight1
				
				@aRectangles + [nX + nWidth1, nY, nWidth2, nHeight1, nSecond, aSorted[2][2], aSorted[2][3]]
				@aRectangles + [nX + nWidth1, nY + nHeight1, nWidth2, nHeight2, nThird, aSorted[3][2], aSorted[3][3]]
			else
				# Vertical layout: largest top, two below
				nHeight1 = max([1, floor((nLargest / nTotal) * nHeight)])
				nHeight2 = nHeight - nHeight1
				
				# Largest rectangle on top
				@aRectangles + [nX, nY, nWidth, nHeight1, nLargest, aSorted[1][2], aSorted[1][3]]
				
				# Two smaller below, split horizontally
				nSubTotal = nSecond + nThird
				nWidth1 = max([1, floor((nSecond / nSubTotal) * nWidth)])
				nWidth2 = nWidth - nWidth1
				
				@aRectangles + [nX, nY + nHeight1, nWidth1, nHeight2, nSecond, aSorted[2][2], aSorted[2][3]]
				@aRectangles + [nX + nWidth1, nY + nHeight1, nWidth2, nHeight2, nThird, aSorted[3][2], aSorted[3][3]]
			ok
			
		else # nLen = 4
			# Four rectangles - 2x2 grid
			nSum1 = aSorted[1][1] + aSorted[2][1]
			nSum2 = aSorted[3][1] + aSorted[4][1]
			nTotal = nSum1 + nSum2
			
			if nWidth >= nHeight
				# Split horizontally first
				nWidth1 = max([1, floor((nSum1 / nTotal) * nWidth)])
				nWidth2 = nWidth - nWidth1
				
				# Left column
				nSubTotal1 = aSorted[1][1] + aSorted[2][1]
				nHeight1 = max([1, floor((aSorted[1][1] / nSubTotal1) * nHeight)])
				nHeight2 = nHeight - nHeight1
				
				@aRectangles + [nX, nY, nWidth1, nHeight1, aSorted[1][1], aSorted[1][2], aSorted[1][3]]
				@aRectangles + [nX, nY + nHeight1, nWidth1, nHeight2, aSorted[2][1], aSorted[2][2], aSorted[2][3]]
				
				# Right column
				nSubTotal2 = aSorted[3][1] + aSorted[4][1]
				nHeight3 = max([1, floor((aSorted[3][1] / nSubTotal2) * nHeight)])
				nHeight4 = nHeight - nHeight3
				
				@aRectangles + [nX + nWidth1, nY, nWidth2, nHeight3, aSorted[3][1], aSorted[3][2], aSorted[3][3]]
				@aRectangles + [nX + nWidth1, nY + nHeight3, nWidth2, nHeight4, aSorted[4][1], aSorted[4][2], aSorted[4][3]]
			else
				# Split vertically first
				nHeight1 = max([1, floor((nSum1 / nTotal) * nHeight)])
				nHeight2 = nHeight - nHeight1
				
				# Top row
				nSubTotal1 = aSorted[1][1] + aSorted[2][1]
				nWidth1 = max([1, floor((aSorted[1][1] / nSubTotal1) * nWidth)])
				nWidth2 = nWidth - nWidth1
				
				@aRectangles + [nX, nY, nWidth1, nHeight1, aSorted[1][1], aSorted[1][2], aSorted[1][3]]
				@aRectangles + [nX + nWidth1, nY, nWidth2, nHeight1, aSorted[2][1], aSorted[2][2], aSorted[2][3]]
				
				# Bottom row
				nSubTotal2 = aSorted[3][1] + aSorted[4][1]
				nWidth3 = max([1, floor((aSorted[3][1] / nSubTotal2) * nWidth)])
				nWidth4 = nWidth - nWidth3
				
				@aRectangles + [nX, nY + nHeight1, nWidth3, nHeight2, aSorted[3][1], aSorted[3][2], aSorted[3][3]]
				@aRectangles + [nX + nWidth3, nY + nHeight1, nWidth4, nHeight2, aSorted[4][1], aSorted[4][2], aSorted[4][3]]
			ok
		ok

	def _recursiveDivision(aSorted, nX, nY, nWidth, nHeight)
		# For larger numbers, use simple recursive division
		nLen = len(aSorted)
		nMid = floor(nLen / 2)
		
		# Calculate sum for first half
		nSum1 = 0
		for i = 1 to nMid
			nSum1 += aSorted[i][1]
		next
		
		# Calculate sum for second half
		nSum2 = 0
		for i = nMid + 1 to nLen
			nSum2 += aSorted[i][1]
		next
		
		nTotal = nSum1 + nSum2
		
		if nWidth >= nHeight
			# Divide horizontally
			nWidth1 = max([1, floor((nSum1 / nTotal) * nWidth)])
			nWidth2 = nWidth - nWidth1
			
			# First half
			aFirst = []
			for i = 1 to nMid
				aFirst + aSorted[i]
			next
			_squarifyLayout(aFirst, nX, nY, nWidth1, nHeight, nWidth1 * nHeight)
			
			# Second half
			aSecond = []
			for i = nMid + 1 to nLen
				aSecond + aSorted[i]
			next
			_squarifyLayout(aSecond, nX + nWidth1, nY, nWidth2, nHeight, nWidth2 * nHeight)
		else
			# Divide vertically
			nHeight1 = max([1, floor((nSum1 / nTotal) * nHeight)])
			nHeight2 = nHeight - nHeight1
			
			# First half
			aFirst = []
			for i = 1 to nMid
				aFirst + aSorted[i]
			next
			_squarifyLayout(aFirst, nX, nY, nWidth, nHeight1, nWidth * nHeight1)
			
			# Second half
			aSecond = []
			for i = nMid + 1 to nLen
				aSecond + aSorted[i]
			next
			_squarifyLayout(aSecond, nX, nY + nHeight1, nWidth, nHeight2, nWidth * nHeight2)
		ok

	def _drawBorders()
		
		# Draw outer border
		# Top border
		@acCanvas[1][1] = @cTopLeft
		@acCanvas[1][@nWidth] = @cTopRight
		for i = 2 to @nWidth - 1
			@acCanvas[1][i] = @cHorizontal
		next
		
		# Bottom border
		@acCanvas[@nHeight][1] = @cBottomLeft
		@acCanvas[@nHeight][@nWidth] = @cBottomRight
		for i = 2 to @nWidth - 1
			@acCanvas[@nHeight][i] = @cHorizontal
		next
		
		# Side borders
		for i = 2 to @nHeight - 1
			@acCanvas[i][1] = @cVertical
			@acCanvas[i][@nWidth] = @cVertical
		next
		
		# Draw internal borders between rectangles
		_drawInternalBorders()

	def _connectBordersToOuter()
	    # Check each position on outer border for connections
	    
	    # Top border connections
	    for j = 2 to @nWidth - 1
	        if @acCanvas[2][j] = @cVertical  # Internal border connects from below
	            @acCanvas[1][j] = @cTeeDown
	        ok
	    next
	    
	    # Bottom border connections  
	    for j = 2 to @nWidth - 1
	        if @acCanvas[@nHeight-1][j] = @cVertical  # Internal border connects from above
	            @acCanvas[@nHeight][j] = @cTeeUp
	        ok
	    next
	    
	    # Left border connections
	    for i = 2 to @nHeight - 1
	        if @acCanvas[i][2] = @cHorizontal  # Internal border connects from right
	            @acCanvas[i][1] = @cTeeRight
	        ok
	    next
	    
	    # Right border connections
	    for i = 2 to @nHeight - 1
	        if @acCanvas[i][@nWidth-1] = @cHorizontal  # Internal border connects from left
	            @acCanvas[i][@nWidth] = @cTeeLeft
	        ok
	    next


def _drawInternalBorders()
    
    nLen = len(@aRectangles)
    
    # First pass: draw all borders without intersections
    for i = 1 to nLen
        aRect = @aRectangles[i]
        nX = aRect[1]
        nY = aRect[2] 
        nW = aRect[3]
        nH = aRect[4]
        
        # Adjust for outer border offset
        if @bShowBorders
            nX++
            nY++
        ok
        
        # Draw right border if not at edge
        if nX + nW < @nWidth
            for j = nY to nY + nH - 1
                if j >= 1 and j <= @nHeight
                    if @acCanvas[j][nX + nW] = " "
                        @acCanvas[j][nX + nW] = @cVertical
                    ok
                ok
            next
        ok
        
        # Draw bottom border if not at edge
        if nY + nH < @nHeight and nY + nH > 1
            for j = nX to nX + nW - 1
                if j >= 1 and j <= @nWidth
                    if @acCanvas[nY + nH][j] = " "
                        @acCanvas[nY + nH][j] = @cHorizontal
                    ok
                ok
            next
        ok
    next
    
    # Second pass: fix all intersections
    _fixBorderIntersections()


def _fixBorderIntersections()
	
	for i = 1 to @nHeight
		for j = 1 to @nWidth
			
			cCurrent = @acCanvas[i][j]
			
			# Only process positions that have border characters
			if cCurrent = @cVertical or cCurrent = @cHorizontal
			
				# Check all four directions for connections
				bUp = FALSE
				bDown = FALSE
				bLeft = FALSE
				bRight = FALSE
				
				# Check up
				if i > 1
					cUp = @acCanvas[i-1][j]
					bUp = (cUp = @cVertical or cUp = @cTeeDown or cUp = @cTeeUp or cUp = @cCross or cUp = @cTeeLeft or cUp = @cTeeRight)
				ok
				
				# Check down
				if i < @nHeight
					cDown = @acCanvas[i+1][j]
					bDown = (cDown = @cVertical or cDown = @cTeeDown or cDown = @cTeeUp or cDown = @cCross or cDown = @cTeeLeft or cDown = @cTeeRight)
				ok
				
				# Check left
				if j > 1
					cLeft = @acCanvas[i][j-1]
					bLeft = (cLeft = @cHorizontal or cLeft = @cTeeLeft or cLeft = @cTeeRight or cLeft = @cCross or cLeft = @cTeeDown or cLeft = @cTeeUp)
				ok
				
				# Check right
				if j < @nWidth
					cRight = @acCanvas[i][j+1]
					bRight = (cRight = @cHorizontal or cRight = @cTeeLeft or cRight = @cTeeRight or cRight = @cCross or cRight = @cTeeDown or cRight = @cTeeUp)
				ok
				
				# Determine proper intersection character
				nConnections = 0
				if bUp: nConnections++ ok
				if bDown: nConnections++ ok
				if bLeft: nConnections++ ok
				if bRight: nConnections++ ok
				
				# Apply appropriate intersection character
				if nConnections >= 2
					if bUp and bDown and bLeft and bRight
						@acCanvas[i][j] = @cCross
					but bUp and bDown and bRight and not bLeft
						@acCanvas[i][j] = @cTeeRight
					but bUp and bDown and bLeft and not bRight
						@acCanvas[i][j] = @cTeeLeft
					but bLeft and bRight and bDown and not bUp
						@acCanvas[i][j] = @cTeeDown
					but bLeft and bRight and bUp and not bDown
						@acCanvas[i][j] = @cTeeUp
					but bUp and bRight and not bDown and not bLeft
						@acCanvas[i][j] = @cBottomLeft
					but bUp and bLeft and not bDown and not bRight
						@acCanvas[i][j] = @cBottomRight
					but bDown and bRight and not bUp and not bLeft
						@acCanvas[i][j] = @cTopLeft
					but bDown and bLeft and not bUp and not bRight
						@acCanvas[i][j] = @cTopRight
					ok
				ok
			ok
		next
	next

	
	def _truncateLabel(cLabel, nMaxWidth)
		if len(cLabel) <= nMaxWidth
			return cLabel
		ok
		
		if nMaxWidth <= @nMinLabelWidth
			return left(cLabel, max([1, nMaxWidth - 1])) + "."
		ok
		
		return left(cLabel, nMaxWidth - 1) + "."


def _drawContent()
    
    nLen = len(@aRectangles)
    
    for i = 1 to nLen
        aRect = @aRectangles[i]
        nX = aRect[1]
        nY = aRect[2]
        nW = aRect[3]
        nH = aRect[4]
        nValue = aRect[5]
        cLabel = Capitalise(aRect[6])
        nOrigIndex = aRect[7]
        
        # Adjust for border offset
        if @bShowBorders
            nX++
            nY++
        ok
        
        # Calculate usable content area (avoiding borders)
        nContentX = nX
        nContentY = nY
        nContentW = nW
        nContentH = nH

        if @bShowBorders
            # Shrink content area to avoid internal borders
            if nX + nW < @nWidth
                nContentW -= 1  # Avoid right border
            ok
            if nY + nH < @nHeight
                nContentH -= 1  # Avoid bottom border
            ok
        ok

        # Only proceed if we have reasonable space
        if nContentW < 3 or nContentH < 1
            loop  # Skip this rectangle - too small for meaningful content
        ok

        # Build content lines
        aContentLines = []

        # Prepare label and value content
        cMainContent = ""
        cSubContent = ""

        if @bShowLabels and len(cLabel) > 0
            cMainContent = _truncateLabel(cLabel, nContentW)
        ok

        # Build value/percent string
        cValueStr = ""
        if @bShowValues
            cValueStr = "" + _cleanNumber(nValue)
        ok

        if @bShowPercent
            nPercent = _cleanNumber(RoundN((nValue / @nSum) * 100, 1))
            cPercentStr = "" + nPercent + "%"
            
            if len(cValueStr) > 0
                cSubContent = cValueStr + " (" + cPercentStr + ")"
            else
                cSubContent = cPercentStr
            ok
        but len(cValueStr) > 0
            cSubContent = cValueStr
        ok

        # Ensure sub-content fits
        if len(cSubContent) > nContentW
            if nContentW > 3
                cSubContent = left(cSubContent, nContentW - 1) + "."
            else
                cSubContent = left(cSubContent, nContentW)
            ok
        ok

        # Determine layout - prioritize compact, clean display
        bShowMain = (len(cMainContent) > 0 and len(cMainContent) <= nContentW)
        bShowSub = (len(cSubContent) > 0 and len(cSubContent) <= nContentW)
        
        if bShowMain and bShowSub
            if nContentH >= 2
                # Multi-line: label on top, value below
                aContentLines + cMainContent
                aContentLines + cSubContent
            but nContentW >= (len(cMainContent) + len(cSubContent) + 1)
                # Single line if they fit together
                aContentLines + cMainContent + " " + cSubContent
            else
                # Prioritize more important content
                if @bShowPercent or @bShowValues
                    aContentLines + cSubContent  # Values/percentages more important in compact view
                else
                    aContentLines + cMainContent
                ok
            ok
        but bShowMain
            aContentLines + cMainContent
        but bShowSub
            aContentLines + cSubContent
        ok
        
        # Draw content lines centered in available space
        if len(aContentLines) > 0
            # Vertical centering
            nStartY = nContentY + max([0, floor((nContentH - len(aContentLines)) / 2)])

            for k = 1 to len(aContentLines)
                cLine = aContentLines[k]
                nLineLen = len(cLine)
                nCurrentY = nStartY + k - 1
                
                # Horizontal centering
                nCenterX = nContentX + max([0, floor((nContentW - nLineLen) / 2)])
                
                # Draw the line
                if nCurrentY >= nContentY and nCurrentY < nContentY + nContentH and nCurrentY >= 1 and nCurrentY <= @nHeight
                    for j = 1 to nLineLen
                        nCol = nCenterX + j - 1
                        if nCol >= nContentX and nCol < nContentX + nContentW and nCol >= 1 and nCol <= @nWidth
                            if @acCanvas[nCurrentY][nCol] = " "
                                @acCanvas[nCurrentY][nCol] = cLine[j]
                            ok
                        ok
                    next
                ok
            next
        ok
    next
	
	
	def _cleanNumber(nNum)
	    cStr = "" + nNum
	    # Remove .0 from end if it exists
	    if right(cStr, 2) = ".0"
	        return left(cStr, len(cStr) - 2)
	    ok
	    return cStr


#-----------------------#
#  SCATTER CHART CLASS  #
#-----------------------#

class stzScatterChart from stzChart

	@anXValues = []
	@anYValues = []
	@acPointLabels = []

	@bShowXAxis = True
	@bShowYAxis = True
	@bShowGrid = False
	@bShowLabels = false

	# X and Y letters at the end of the axies
	@bShowXLetter = FALSE
	@bShowYLetter = FALSE

	# Console defaults
	@nMaxWidth = 42 
	@nMaxHeight = 12 
	@nXAxisHeight = 2

	@cPointChar = "●"
	@cVerticalGridChar = "⁞"
	@cHorizontalGridChar = "-"

	@cXTickChar = "┬"
	@cXTickChar2 = "┼"
	@cYTickChar = "┤"

	@nXMin = 0
	@nXMax = 0
	@nYMin = 0
	@nYMax = 0

	@nWidth = 0
	@nHeight = 0


	def init(paDataSet)
		if CheckParams()
			if NOT isList(paDataSet)
				StzRaise("Can't create stzChart! paDataSet must be a list.")
			ok

			if IsListOfPairs(paDataSet) and len(paDataSet) > 0 and IsListOfNumbers(paDataSet[1])
				@anXValues = []
				@anYValues = []
				@acPointLabels = []

				for i = 1 to len(paDataSet)
					if len(paDataSet[i]) >= 2
						@anXValues + paDataSet[i][1]
						@anYValues + paDataSet[i][2]
						@acPointLabels + ("P" + i)
					ok
				next

			but IsHashList(paDataSet)
				oHash = new stzHashList(paDataSet)
				aKeys = oHash.Keys()

				if len(aKeys) = 2 and (aKeys[1] = "X" or aKeys[1] = :X) and (aKeys[2] = "Y" or aKeys[2] = :Y)
					@anXValues = paDataSet[:X]
					@anYValues = paDataSet[:Y]
	
					if len(@anXValues) != len(@anYValues)
						StzRaise("X and Y value arrays must have same length!")
					ok

					@acPointLabels = []
					for i = 1 to len(@anXValues)
						@acPointLabels + ("P" + i)
					next

				else
					@anXValues = []
					@anYValues = []
					@acPointLabels = oHash.Keys()

					aValues = oHash.Values()
					for i = 1 to len(aValues)
						if isList(aValues[i]) and len(aValues[i]) >= 2
							@anXValues + aValues[i][1]
							@anYValues + aValues[i][2]
						ok
					next
				ok

			else
				StzRaise("Invalid data format! Use [[x1,y1], [x2,y2]] or hashlist format.")
			ok
		ok

		if NOT (IsListOfNumbers(@anXValues) and IsListOfNumbers(@anYValues))
			StzRaise("X and Y values must all be numbers!")
		ok

		_calculateRanges()

		@bShowXLetter = TRUE
		@bShowYLetter = TRUE

	def XValues()
		return @anXValues

	def YValues()
		return @anYValues

	def PointLabels()
		return @acPointLabels

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

		def SetYXAxis(bShow)
			This.SetXYAxis(bShow)

		def SetXYAxies(bShow)
			This.SetXYAxis(bShow)

		def SetYXAxies(bShow)
			This.SetXYAxis(bShow)

		def WithoutXYAxis()
			This.SetXyAxis(FALSE)

		def WithoutYXAxis()
			This.SetXyAxis(FALSE)


	def SetXYLetters(bShow)
		@bShowXLetter = bShow
		@bShowYLetter = bShow

		def SetXY(bShow)
			This.SetXYLetters(bShow)

		def WithoutXY()
			This.SetXYLetters(FALSE)

		def WithoutXYLetters()
			This.SetXYLetters(FALSE)

	def SetXLetter(bShow)
		@bShowXLetter = bShow

		def SetX(bShow)
			@bShowXLetter = bShow

		def WithoutX()
			@bShowXLetter = FALSE

		def WithXLetter()
			@bShowXLetter = FALSE

	def SetYLetter(bShow)
		@bShowYLetter = bShow

		def SetY(bShow)
			@bShowYLetter = bShow

		def WithoutY()
			@bShowYLetter = FALSE

		def WithoutYLetter()
			@bShowYLetter = FALSE

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
		if CheckParams()
			if NOT (isString(c) and IsChar(c))
				StzRaise("c must be a char.")
			ok
		ok
		@cPointChar = c

		def PointChar()
			return @cPointChar

	def SetMaxSize(nWidth, nHeight)
		if CheckParams()
			if NOT (isNumber(nWidth) and isNumber(nHeight))
				StzRaise("nWidth and nHeight must be numbers.")
			ok
		ok
		@nMaxWidth = max([40, nWidth])
		@nMaxHeight = max([10, nHeight])

	def SetWidth(nWidth)
		if CheckParams()
			if NOT isNumber(nWidth)
				StzRaise("nWidth must be a number.")
			ok
		ok
		@nMaxWidth = max([50, nWidth])

	def SetHeight(nHeight)
		if CheckParams()
			if NOT isNumber(nHeight)
				StzRaise("nHeight must be a number.")
			ok
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

		if @bShowYAxis
			_drawYAxis(oLayout)
		ok

		if @bShowXAxis
			_drawXAxis(oLayout)
		ok

		_drawPoints(oLayout)

		if @bShowLabels
			_drawPointLabels(oLayout)
		ok

		return _finalizeCanvas()


	def _calculateRanges()
		if len(@anXValues) = 0 or len(@anYValues) = 0
			@nXMin = 0
			@nXMax = 10
			@nYMin = 0
			@nYMax = 10
			return
		ok

		@nXMin = min(@anXValues)
		@nXMax = max(@anXValues)
		@nYMin = min(@anYValues)
		@nYMax = max(@anYValues)

		if _areAllIntegers(@anXValues)
			@nXMin = floor(@nXMin)
			@nXMax = ceil(@nXMax)
		ok
		if _areAllIntegers(@anYValues)
			@nYMin = floor(@nYMin)
			@nYMax = ceil(@nYMax)
		ok

	def _areAllIntegers(anList)
		for n in anList
			if NOT isNumber(n) or floor(n) != n
				return FALSE
			ok
		next
		return TRUE

	def _calculateLayout()
		# Calculate dynamic Y-axis width based on actual labels
		nDynamicYAxisWidth = 0
		if @bShowYAxis
			aUniqueY = U(@anYValues)
			aUniqueY = ring_sort(aUniqueY)
			nMaxYLabelLen = 0
			for nY in aUniqueY
				cLabel = _formatValue(nY)
				cLabel = Trim(cLabel)
				if len(cLabel) > nMaxYLabelLen
					nMaxYLabelLen = len(cLabel)
				ok
			next
			# Y-axis width = max label length + space + tick mark + small buffer
			nDynamicYAxisWidth = nMaxYLabelLen + 3
			# Ensure minimum width for readability
			nDynamicYAxisWidth = max([4, nDynamicYAxisWidth])
		ok
	
		# Calculate available space for the plot area
		nYAxisSpace = nDynamicYAxisWidth
		nXAxisSpace = iff(@bShowXAxis, @nXAxisHeight, 0)
		
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
		nPlotWidth = @nMaxWidth - nYAxisSpace - nRightMargin
		nPlotHeight = @nMaxHeight - nXAxisSpace - nTopMargin
		
		# Ensure minimum plot area
		nPlotWidth = max([20, nPlotWidth])
		nPlotHeight = max([8, nPlotHeight])
		
		# Calculate positions
		nYAxisCol = nYAxisSpace
		nPlotStartCol = nYAxisCol + 1
		nPlotEndCol = nPlotStartCol + nPlotWidth - 1
		
		nPlotStartRow = nTopMargin + 1
		nXAxisRow = nPlotStartRow + nPlotHeight
		nPlotEndRow = nXAxisRow - 1
		
		# Total canvas dimensions
		nTotalWidth = nPlotEndCol + nRightMargin
		nTotalHeight = nXAxisRow + nXAxisSpace
		
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
		oLayout.AddPair([:y_axis_col, nYAxisCol])
		oLayout.AddPair([:x_axis_row, nXAxisRow])
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
		for i = 1 to len(@anXValues)
			nX = @anXValues[i]
			nY = @anYValues[i]
			
			# Calculate point position
			nCol = nStartCol + floor((nX - @nXMin) * (nPlotWidth - 1) / (@nXMax - @nXMin))
			nRow = nEndRow - floor((nY - @nYMin) * (nPlotHeight - 1) / (@nYMax - @nYMin))
			
			# Draw horizontal line from Y-axis to point
			for j = nStartCol to nCol
				if @acCanvas[nRow][j] = " "
					@acCanvas[nRow][j] = @cHorizontalGridChar
				ok
			next
			
			# Draw vertical line from X-axis to point
			for j = nRow to nEndRow
				if @acCanvas[j][nCol] = " "
					@acCanvas[j][nCol] = @cVerticalGridChar
				ok
			next
		next
	

	def _drawYAxis(oLayout)
		if NOT @bShowYAxis
			return
		ok
		
		nAxisCol = oLayout[:y_axis_col]
		nStartRow = oLayout[:plot_start_row]
		nEndRow = oLayout[:plot_end_row]
		nXAxisRow = oLayout[:x_axis_row]
		nPlotHeight = oLayout[:plot_height]
	
		cVArrowChar = @cXArrowChar

		# Draw vertical line
		for i = nStartRow to nEndRow
			if i >= 1 and i <= len(@acCanvas) and nAxisCol >= 1 and nAxisCol <= len(@acCanvas[i])
				@acCanvas[i][nAxisCol] = @cXAxisChar
			ok
		next

		# Draw arrow at top
		if nStartRow - 1 >= 1 and nStartRow - 1 <= len(@acCanvas) and nAxisCol >= 1 and nAxisCol <= len(@acCanvas[nStartRow - 1])
			@acCanvas[nStartRow - 1][nAxisCol] = cVArrowChar
		ok

		# Draw origin (only if X-axis is also visible)
		if @bShowXAxis and nXAxisRow >= 1 and nXAxisRow <= len(@acCanvas) and nAxisCol >= 1 and nAxisCol <= len(@acCanvas[nXAxisRow])
			@acCanvas[nXAxisRow][nAxisCol] = @cOriginChar
		ok

		# Always draw Y-axis labels when Y-axis is visible
		aUniqueY = U(@anYValues)
		aUniqueY = ring_sort(aUniqueY)
		for nY in aUniqueY
			nRow = nEndRow - floor((nY - @nYMin) * (nPlotHeight - 1) / (@nYMax - @nYMin))
			if nRow >= nStartRow and nRow <= nEndRow
				cLabel = _formatValue(nY)
				cLabel = Trim(cLabel)
				nLabelLen = len(cLabel)
				nLabelStart = nAxisCol - nLabelLen - 1  # Add space before tick mark
				if nLabelStart >= 1
					for j = 1 to nLabelLen
						@acCanvas[nRow][nLabelStart + j - 1] = cLabel[j]
					next
					@acCanvas[nRow][nAxisCol] = @cYTickChar
				ok
			ok
		next

	def _drawXAxis(oLayout)
		if NOT @bShowXAxis
			return
		ok
		
		nAxisRow = oLayout[:x_axis_row]
		nStartCol = oLayout[:plot_start_col]
		nEndCol = oLayout[:plot_end_col]
		nYAxisCol = oLayout[:y_axis_col]
		nPlotWidth = oLayout[:plot_width]
		nTotalWidth = oLayout[:total_width]
	
		cHArrowChar = @copy(@cYAxischar, 2) + @cYArrowChar

		# Draw horizontal line
		if nAxisRow >= 1 and nAxisRow <= len(@acCanvas)
			for i = nStartCol to nEndCol
				if i >= 1 and i <= nTotalWidth
					@acCanvas[nAxisRow][i] = @cYAxischar
				ok
			next
		ok

		# Draw arrow at end
		if nAxisRow >= 1 and nAxisRow <= len(@acCanvas) and nEndCol + 1 >= 1 and nEndCol + 1 <= nTotalWidth
			@acCanvas[nAxisRow][nEndCol + 1] = cHArrowChar
		ok

		# Draw origin
		if @bShowYAxis and nAxisRow >= 1 and nAxisRow <= len(@acCanvas) and nYAxisCol >= 1 and nYAxisCol <= nTotalWidth
			@acCanvas[nAxisRow][nYAxisCol] = @cOriginChar
		ok

		# Always draw X-axis labels when X-axis is visible
		aUniqueX = U(@anXValues)
		aUniqueX = ring_sort(aUniqueX)
		for nX in aUniqueX
			nCol = nStartCol + floor((nX - @nXMin) * (nPlotWidth - 1) / (@nXMax - @nXMin))
			if nCol >= nStartCol and nCol <= nEndCol
				cLabel = _formatValue(nX)
				nLabelLen = len(cLabel)
				nLabelStart = nCol - floor(nLabelLen / 2)
				
				# Draw tick mark
				if nCol >= 1 and nCol <= nTotalWidth
					@acCanvas[nAxisRow][nCol] = @cXTickChar
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
		if _areAllIntegers(@anXValues) and _areAllIntegers(@anYValues)
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

		for i = 1 to len(@anXValues)
			nX = @anXValues[i]
			nY = @anYValues[i]

			# Improved coordinate mapping to ensure all points are plotted
			if @nXMax = @nXMin
				nCol = nStartCol + floor(nPlotWidth / 2)
			else
				nCol = nStartCol + floor((nX - @nXMin) * (nPlotWidth - 1) / (@nXMax - @nXMin))
			ok
			
			if @nYMax = @nYMin
				nRow = nStartRow + floor(nPlotHeight / 2)
			else
				nRow = nEndRow - floor((nY - @nYMin) * (nPlotHeight - 1) / (@nYMax - @nYMin))
			ok
			
			# Ensure point is within plot bounds
			nCol = max([nStartCol, min([nEndCol, nCol])])
			nRow = max([nStartRow, min([nEndRow, nRow])])
			
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
	
		nLenXVal = len(@anXValues)
		nLenLabels = len(@acPointLabels)
	
		for i = 1 to nLenXVal
			if i <= nLenLabels
				nX = @anXValues[i]
				nY = @anYValues[i]
				cLabel = " " + Capitalise(@acPointLabels[i])
	
				# Calculate point position (same as in _drawPoints)
				if @nXMax = @nXMin
					nCol = nStartCol + floor(nPlotWidth / 2)
				else
					nCol = nStartCol + floor((nX - @nXMin) * (nPlotWidth - 1) / (@nXMax - @nXMin))
				ok
				
				if @nYMax = @nYMin
					nRow = nStartRow + floor(nPlotHeight / 2)
				else
					nRow = nEndRow - floor((nY - @nYMin) * (nPlotHeight - 1) / (@nYMax - @nYMin))
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

		# A hack to remove unnecessary empty lines
		oTempStr = new stzString(cResult)
		if @bShowYAxis = FALSE
			nPos = oTempStr.FindFirst(NL)
			oTempStr.RemoveSection(1, nPos)
		ok

		anPos = oTempStr.FindAll(NL)
		nPos = anPos[len(anPos)-1]
		oTempStr.RemoveSection(nPos, oTempStr.NumberOfChars())

		# A hack to adjust marquers when grid is active
		if @bShowGrid
			oTempStr.ReplaceMany([@cXTickChar, @cYTickChar], @cXTickChar2)
		ok

		# A hack to add X and Y letters if required
		if @bShowXLetter and @bShowXAxis
			nPos = oTempStr.FindFirst(@cXArrowChar)
			cTemp = @copy(" ", nPos-1) + "X" + NL
			oTempStr.InsertAt(1, ctemp)
		ok

		if @bShowYLetter and @bShowYAxis
			nPos1 = oTempStr.FindFirst(@cYArrowChar) +2
			nPos2 = oTempStr.FindLast(NL)-1
			oTempStr.ReplaceSection(nPos1,nPos2," Y")
		ok

		cResult = oTempStr.Content()

		return cResult
