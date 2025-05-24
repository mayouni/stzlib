/*
A class for ascii-based charts, working with stzTable and stzPivotTable

Get inspiration from:
https://www.bloomberg.com/graphics/year-ahead-2016/

https://github.com/alincoop/obsidian-tinychart

https://github.com/madnight/bitcoin-chart-cli

```
^         ╭╮                                     
│        ╭╯╰╮                                    
│        │  ╰╮         
│       ╭╯   ╰────╮
│    ╭──╯         ╰╮   
│   ╭╯             ╰──╮    
│ ──╯                 ╰──────    
╰─────────────────────────────>
```
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

*/

class stzChart
	# Core attributes
	@aDataSet = []
	@acLabels = []
	@acCanvas = []
	@nWidth = 40
	@nHeight = 10
	@nMaxValue = 0
	@nMinValue = 0

	def init(paDataSet)

		# It mus be a list of numbers or a hashlist where
		# the values are all numbers

		if CheckParams()
	
			if NOT isList(paDataSet)
				StzRaise("Can't create the stzChart object! paDataSet must be a list.")
			ok
	
			# In case a list of numbers is provided (the dataset	
			# conatins no lables ~> Added automatical as :1, :2, etc.
	
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
		@aDataSet = oHash.Values()

		if NOT IsListOfNumbers(@aDataSet)
			StzRaise("Incorrect param value! The values in paDataSet must be numbers.")
		ok

        @acLabels = oHash.Keys()

		# 
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

    def _calculateRange()
       @nMaxValue = max(@aDataSet)
       @nMinValue = min(@aDataSet)


    def _initializeCanvas()

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

		# Ignoring the tralilng empty lines

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


class stzBarChart from stzChart

    @bSetLabels = False

    @bSetAverageLine = False
    @bShowValues = False
    @nBarWidth = 2
    @nMaxWidth = 12
    @nBarInterSpace = 1
	
    @cBarChar = "█"
    @cBarCharHalf = "▄"
    @cXAxisChar = "│"
    @cYAxisChar = "─"
    @cXArrowChar = "^"
    @cYArrowChar = ">"
    @cOriginChar = "╰"
	
    def init(paData)
        super.init(paData)

    def SetYLabels(bShow)

        @bSetLabels = bShow

        if bShow = FALSE
            @cYArrowChar = "─>"
        ok

        def AddYLabels()
            This.SetYLabels(_TRUE_)

        def AddLabels()
            This.SetYLabels(_TRUE_)

    def SetAverageLine(bShow)
        @bSetAverageLine = bShow
 
        def AddAverageLine()
            @bSetAverageLine = _TRUE_

        def AddAverage()
            @bSetAverageLine = _TRUE_

    def SetShowValues(bShow)
        @bShowValues = bShow

    def AddValues()
        This.SetShowValues(_TRUE_)

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

    def Show()
        ? This.ToString()


    def ToString()

        # Calculate Y-axis width (minimal - no labels)
        nYAxisWidth = 0
        
        # Calculate optimal spacing and total width
        aSpacing = _calculateOptimalSpacing()
        nTotalChartWidth = _calculateTotalChartWidth(aSpacing)
        
        # Set canvas width to exact requirement (no excess)
        @nWidth = nYAxisWidth + @nBarInterSpace + @nBarInterSpace + nTotalChartWidth + @nBarInterSpace - 1
        
        if not @bSetLabels
            @nWidth += (@nBarInterSpace * 2)
        ok
        
        if @nWidth > @nMaxWidth
            raise("Chart width (" + @nWidth + ") exceeds maximum allowed width (" + @nMaxWidth + ")")
        ok
        
        _initializeCanvas()
        _renderYAxis(nYAxisWidth)
        _renderXAxis(nYAxisWidth, nTotalChartWidth)
        _renderBars(nYAxisWidth, aSpacing)
        
		# Check and render values if enabled
        if @bShowValues
            _renderValues(nYAxisWidth, aSpacing)
        ok
        
        if @bSetLabels
            _renderXLabels(nYAxisWidth, aSpacing)
        ok
        
        if @bSetAverageLine
            _renderAverageLine(nYAxisWidth, nTotalChartWidth)
        ok
        
        return _finalizeCanvas()

    def _calculateOptimalSpacing()

        nBars = len(@aDataSet)
        aSpacing = []
        
        if not @bSetLabels

            for i = 1 to nBars - 1
                aSpacing + @nBarInterSpace
            next

        else

            aElementWidths = []

            for i = 1 to nBars

                cLabel = ""

                if i <= len(@acLabels)
                    cLabel = @acLabels[i]
                ok

                nLabelLen = len(cLabel)

                if nLabelLen > @nBarWidth
                    nElementWidth = nLabelLen

                else
                    nElementWidth = @nBarWidth

                ok

                aElementWidths + nElementWidth

            next

            for i = 1 to nBars - 1
                aSpacing + @nBarInterSpace

            next

        ok

        return aSpacing

    def _calculateTotalChartWidth(aSpacing)

        nBars = len(@aDataSet)
        nTotalWidth = 0
        
        for i = 1 to nBars

            if @bSetLabels

                cLabel = ""

                if i <= len(@acLabels)
                    cLabel = @acLabels[i]
                ok

                nLabelLen = len(cLabel)
                nElementWidth = max([nLabelLen, @nBarWidth])

            else
                nElementWidth = @nBarWidth

            ok

            nTotalWidth += nElementWidth

        next
        
        for i = 1 to len(aSpacing)
            nTotalWidth += aSpacing[i]
        next

        return nTotalWidth

    def _renderYAxis(nYAxisWidth)

        nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace - 1

        for i = 2 to @nHeight - 2
            @acCanvas[i][nAxisCol] = @cXAxisChar
        next

        @acCanvas[1][nAxisCol] = @cXArrowChar


	def _renderXAxis(nYAxisWidth, nTotalChartWidth)
	    nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace - 1  # Shift left by 1
	    nAxisRow = @nHeight - 2
	    nEndCol = nAxisCol + nTotalChartWidth
	    nStartCol = nAxisCol
	
	    if not @bSetLabels
	        nStartCol = nAxisCol + @nBarInterSpace
	        nEndCol = nEndCol + @nBarInterSpace
	    ok
	
	    # Ensure nEndCol does not exceed canvas width
	    if nEndCol > @nWidth - 1
	        nEndCol = @nWidth - 1
	    ok
	
	    for i = nStartCol to nEndCol
	        @acCanvas[nAxisRow][i] = @cYAxisChar
	    next
	
	    @acCanvas[nAxisRow][nAxisCol] = @cOriginChar
	    # Adjust Y-arrow placement to stay within bounds
	    if nEndCol + @nBarInterSpace <= @nWidth - 1
	        @acCanvas[nAxisRow][nEndCol + @nBarInterSpace] = @cYArrowChar
	    else
	        @acCanvas[nAxisRow][nEndCol] = @cYArrowChar  # Place at last valid column
	    ok


    def _renderBars(nYAxisWidth, aSpacing)

        nBars = len(@aDataSet)
        nRange = @nMaxValue - @nMinValue
        nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace - 1
        nAxisRow = @nHeight - 2
        nChartHeight = @nHeight - 4
        
        nCurrentX = nAxisCol + @nBarInterSpace

        if not @bSetLabels
            nCurrentX += @nBarInterSpace
        ok
        
        for i = 1 to nBars

            if @bSetLabels

                cLabel = ""

                if i <= len(@acLabels)
                    cLabel = @acLabels[i]
                ok

                nLabelLen = len(cLabel)
                nElementWidth = max([nLabelLen, @nBarWidth])

            else
                nElementWidth = @nBarWidth
            ok
            
            nVal = @aDataSet[i]

            if nRange = 0
                nBarHeight = 1
            else
                nBarHeight = max([1, floor(nChartHeight * (nVal - @nMinValue) / nRange)])
            ok
            
            nBarStartX = nCurrentX + floor((nElementWidth - @nBarWidth) / 2.0)

            for j = 1 to nBarHeight

                for k = 1 to @nBarWidth
                    @acCanvas[nAxisRow - j][nBarStartX + k - 1] = @cBarChar
                next

            next

            if i < nBars
                nCurrentX += nElementWidth + aSpacing[i]
            ok

        next

    def _renderValues(nYAxisWidth, aSpacing)

        nBars = len(@aDataSet)
        nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace - 1
        nAxisRow = @nHeight - 2
        nChartHeight = @nHeight - 4
        
        nCurrentX = nAxisCol + @nBarInterSpace
        if not @bSetLabels
            nCurrentX += @nBarInterSpace
        ok
        
        for i = 1 to nBars

            if @bSetLabels

                cLabel = ""

                if i <= len(@acLabels)
                    cLabel = @acLabels[i]
                ok

                nLabelLen = len(cLabel)
                nElementWidth = max([nLabelLen, @nBarWidth])

            else

                nElementWidth = @nBarWidth
            ok
            
            nBarStartX = nCurrentX + floor((nElementWidth - @nBarWidth) / 2)

            nVal = @aDataSet[i]

            if @nMaxValue - @nMinValue = 0
                nBarHeight = 1

            else
                nBarHeight = max([1, floor(nChartHeight * (nVal - @nMinValue) / (@nMaxValue - @nMinValue))])
            ok
            
            nTop = nAxisRow - nBarHeight
            nValueRow = nTop - 1
            if nValueRow < 1
                nValueRow = 1
            ok
            
            cValue = ""+ @aDataSet[i]
            nValueLen = len(cValue)
            nStart = nBarStartX + floor((@nBarWidth - nValueLen) / 2)

            if nStart < nAxisCol + 1
                nStart = nAxisCol + 1
            ok
            
            for k = 1 to nValueLen

                nCol = nStart + k - 1

                if nCol <= @nWidth
                    @acCanvas[nValueRow][nCol] = cValue[k]
                ok

            next
            
            if i < nBars
                nCurrentX += nElementWidth + aSpacing[i]
            ok
        next

    def _renderXLabels(nYAxisWidth, aSpacing)

        nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace - 1
        nLabelRow = @nHeight - 1
        nBars = len(@aDataSet)
        
        nCurrentX = nAxisCol + @nBarInterSpace

		
        for i = 1 to nBars

            if i <= len(@acLabels)

                cLabel = Capitalize(@acLabels[i])
                nLabelLen = len(cLabel)
                nElementWidth = max([nLabelLen, @nBarWidth])
                nLabelStartX = nCurrentX + floor((nElementWidth - nLabelLen) / 2)

                for j = 1 to nLabelLen
                    @acCanvas[nLabelRow][nLabelStartX + j - 1] = cLabel[j]
                next

            ok

            if i < nBars

                cCurrentLabel = ""

                if i <= len(@acLabels)
                    cCurrentLabel = @acLabels[i]
                ok

                nCurrentElementWidth = max([len(cCurrentLabel), @nBarWidth])
                nCurrentX += nCurrentElementWidth + aSpacing[i]
            ok

        next


	def _renderAverageLine(nYAxisWidth, nTotalChartWidth)
	    nSum = 0
	    for i = 1 to len(@aDataSet)
	        nSum += @aDataSet[i]
	    next
	    nAvg = nSum / len(@aDataSet)
	    
	    nRange = @nMaxValue - @nMinValue
	    nAxisRow = @nHeight - 2
	    nChartHeight = @nHeight - 4
	    
	    if nRange > 0
	        nAvgRow = nAxisRow - floor(nChartHeight * (nAvg - @nMinValue) / nRange)
	    else
	        nAvgRow = nAxisRow - 1
	    ok
	    
	    nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace - 1  # Shift left by 1
	    nLineStart = nAxisCol + @nBarInterSpace
	    nLineEnd = nAxisCol + nTotalChartWidth
	    
	    # Ensure nLineEnd does not exceed canvas width
	    if nLineEnd > @nWidth - 1
	        nLineEnd = @nWidth - 1
	    ok
	
	    for i = nLineStart to nLineEnd
	        if @acCanvas[nAvgRow][i] = @cBarChar
	            @acCanvas[nAvgRow][i] = @cBarChar
	        else
	            @acCanvas[nAvgRow][i] = "-"
	        ok
	    next


class stzHBarChart from stzChart

	@bSetXAxis = True
	@bSetYAxis = True
    @bSetLabels = True
    @bSetAverageLine = False
    @bShowValues = False
    @nBarHeight = 1
    @nMaxHeight = 30
    @nBarInterSpace = 0
    @nMaxLabelWidth = 12  # Now acts as true maximum width limit
    @nLeftPadding = 0

    @cBarChar = "▇"
	@cPartialBarChar = "░"
    @cXAxisChar = "─"
    @cYAxisChar = "│"
    @cXArrowChar = ">"
    @cYArrowChar = "^"
    @cOriginChar = "╰"
    
    def init(paData)
        super.init(paData)

	def SetXAxis(bShow)
		@bSetXAxis = bShow

	def SetYAxis(bShow)
		@bSetYAxis = bShow

	def SetXYAxis(bShow)
		@bSetXAxis = bShow
		@bSetYAxis = bShow

    def SetXLabels(bShow)
        @bSetLabels = bShow
        
        def AddXLabels()
            This.SetXLabels(_TRUE_)

        def AddLabels()
            This.SetXLabels(_TRUE_)

    def SetAverageLine(bShow)
        @bSetAverageLine = bShow
 
        def AddAverageLine()
            @bSetAverageLine = _TRUE_

        def AddAverage()
            @bSetAverageLine = _TRUE_

    def SetShowValues(bShow)
        @bShowValues = bShow

        def AddValues()
            This.SetShowValues(_TRUE_)

    def SetBarHeight(nHeight)
        @nBarHeight = max([1, nHeight])
        
    def SetMaxHeight(nHeight)
        @nMaxHeight = nHeight

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
        nBars = len(@aDataSet)
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

        # Use the calculated actual width (no fixed container)
        nLabelAreaWidth = nActualLabelWidth

        # Calculate required height based on axes
        nExtraHeight = 0
        if @bSetXAxis
            nExtraHeight = 2  # Space for X-axis
        ok

        nRequiredHeight = nBars * (@nBarHeight + @nBarInterSpace) + nExtraHeight
        @nHeight = min([nRequiredHeight, @nMaxHeight])
        This._initCanvas()
        
        # Calculate max bar width for X-axis length
        nRange = @nMaxValue - @nMinValue
        if nRange = 0
            nRange = 1
        ok
        nMaxBarWidth = @nWidth - nLabelAreaWidth - 4
        nBarAreaWidth = nMaxBarWidth

        if @bSetYAxis
            This._drawYAxis(nLabelAreaWidth)
        ok
        
        if @bSetXAxis
            This._drawXAxis(nLabelAreaWidth, nBarAreaWidth)
        ok
        
        This._drawBars(nLabelAreaWidth, nBarAreaWidth)

        if @bShowValues
            This._drawValues(nLabelAreaWidth, nBarAreaWidth)
        ok

        if @bSetLabels
            This._drawLabels(nLabelAreaWidth)
        ok

        if @bSetAverageLine
            This._drawAverageLine(nLabelAreaWidth, nBarAreaWidth)
        ok

        return This._buildOutput()

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
        nEndCol = nStartCol + nBarAreaWidth + 1

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
        nBars = len(@aDataSet)
        nRange = @nMaxValue - @nMinValue
        if nRange = 0
            nRange = 1  # Prevent division by zero
        ok
        
        nAxisCol = nLabelAreaWidth + 2
        
        # Adjust starting row based on axes
        nStartRow = 1
        if @bSetYAxis or @bSetXAxis
            nStartRow = 2
        ok
        
        for i = 1 to nBars
            # Calculate bar position
            nBarRow = nStartRow + (i - 1) * (@nBarHeight + @nBarInterSpace)
            
            # Skip if exceeds canvas (accounting for X-axis space)
            nMaxRow = @nHeight
            if @bSetXAxis
                nMaxRow = @nHeight - 1
            ok
            
            if nBarRow + @nBarHeight - 1 >= nMaxRow
                exit
            ok
            
            # Calculate exact bar width (with decimals)
            nVal = @aDataSet[i]
            nExactWidth = nBarAreaWidth * (nVal - @nMinValue) / nRange
            nBarWidth = max([0, floor(nExactWidth)])
            
            # Determine if we need a partial character for visual granularity
            nFractionalPart = nExactWidth - nBarWidth
            bNeedsPartial = (nFractionalPart > 0.3)  # Threshold for showing partial
            
            # For values that result in zero bar width, always show at least partial character
            if nBarWidth = 0
                bNeedsPartial = True
            ok
            
            # Draw bar
            for h = 0 to @nBarHeight - 1
                nCurrentRow = nBarRow + h
                if nCurrentRow < nMaxRow
                    # Calculate bar start position
                    nBarStartCol = nAxisCol + 1
                    if not @bSetYAxis
                        nBarStartCol = nAxisCol
                    ok
                    
                    # Draw full characters
                    for w = 1 to nBarWidth
                        nCol = nBarStartCol + w
                        if nCol <= @nWidth
                            @acCanvas[nCurrentRow][nCol] = @cBarChar
                        ok
                    next
                    
                    # Draw partial character if needed
                    if bNeedsPartial
                        nCol = nBarStartCol + nBarWidth + 1
                        if nCol <= @nWidth
                            @acCanvas[nCurrentRow][nCol] = @cPartialBarChar  # Light shade for partial
                        ok
                    ok
                ok
            next
        next

    def _drawValues(nLabelAreaWidth, nBarAreaWidth)
        nBars = len(@aDataSet)
        nRange = @nMaxValue - @nMinValue
        if nRange = 0
            nRange = 1
        ok
        
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
            
            nVal = @aDataSet[i]
            # Calculate exact width to match _drawBars logic
            nExactWidth = nBarAreaWidth * (nVal - @nMinValue) / nRange
            nBarWidth = max([0, floor(nExactWidth)])
            
            # Check if we're showing a partial character
            nFractionalPart = nExactWidth - nBarWidth
            bHasPartial = (nFractionalPart > 0.3) or (nBarWidth = 0)
            
            cValue = "" + nVal
            nValueLen = len(cValue)
            
            # Calculate bar start column
            nBarStartCol = nAxisCol + 1
            if not @bSetYAxis
                nBarStartCol = nAxisCol
            ok
            
            # Calculate value position - always one space after bar end
            nValueCol = nBarStartCol + nBarWidth + 1
            if bHasPartial
                nValueCol += 1  # Account for partial character
            ok
            nValueCol += 1  # One space before value
            
            # Ensure value fits within canvas width
            nRequiredWidth = nValueCol + nValueLen
            if nRequiredWidth > @nWidth
                # Expand canvas rows to accommodate larger width
                nOldWidth = @nWidth
                @nWidth = nRequiredWidth + 1
                
                # Extend existing rows
                for row = 1 to len(@acCanvas)
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

    def _drawLabels(nLabelAreaWidth)
        nBars = len(@aDataSet)
        
        # Adjust starting row based on axes
        nStartRow = 1
        if @bSetYAxis or @bSetXAxis
            nStartRow = 2
        ok
        
        for i = 1 to nBars
            if i <= len(@acLabels)
                nBarRow = nStartRow + (i - 1) * (@nBarHeight + @nBarInterSpace)
                
                # Skip if exceeds canvas (accounting for X-axis space)
                nMaxRow = @nHeight
                if @bSetXAxis
                    nMaxRow = @nHeight - 1
                ok
                
                if nBarRow >= nMaxRow
                    exit
                ok
                
                cOriginalLabel = @acLabels[i]
                cLabel = Capitalize(cOriginalLabel)
                
                # Truncate label if it exceeds maximum width
                if len(cLabel) > @nMaxLabelWidth
                    cLabel = substr(cLabel, 1, @nMaxLabelWidth - 3) + "..."
                ok
                
                nLabelLen = len(cLabel)
                
                # Right-align label within the actual label area (no fixed container)
                nStartCol = nLabelAreaWidth - nLabelLen + 1
                if nStartCol < 1
                    nStartCol = 1
                ok
                
                for j = 1 to nLabelLen
                    nCol = nStartCol + j - 1
                    if nCol <= nLabelAreaWidth and nBarRow < nMaxRow
                        @acCanvas[nBarRow][nCol] = cLabel[j]
                    ok
                next
            ok
        next

    def _drawAverageLine(nLabelAreaWidth, nBarAreaWidth)
        # Calculate average
        nSum = 0
        for i = 1 to len(@aDataSet)
            nSum += @aDataSet[i]
        next
        nAvg = nSum / len(@aDataSet)
        
        # Calculate position
        nRange = @nMaxValue - @nMinValue
        if nRange = 0
            nRange = 1
        ok
        
        nAxisCol = nLabelAreaWidth + 2
        nAvgCol = nAxisCol + 1 + floor(nBarAreaWidth * (nAvg - @nMinValue) / nRange)
        
        # Adjust row range based on axes
        nStartRow = 1
        nEndRow = @nHeight
        if @bSetYAxis or @bSetXAxis
            nStartRow = 2
        ok
        if @bSetXAxis
            nEndRow = @nHeight - 1
        ok
        
        # Draw vertical line
        for row = nStartRow to nEndRow
            if nAvgCol <= @nWidth and row < @nHeight
                if @acCanvas[row][nAvgCol] != @cBarChar
                    @acCanvas[row][nAvgCol] = "|"
                ok
            ok
        next

    def _buildOutput()
        cResult = ""
        
        # Determine the last row to output
        nLastContentRow = @nHeight
        if @bSetXAxis
            nLastContentRow = @nHeight - 1
        ok
        
        for row = 1 to nLastContentRow
            cLine = ""
            for col = 1 to @nWidth
                cLine += @acCanvas[row][col]
            next
            # Remove trailing spaces for cleaner output
            cLine = rtrim(cLine)
            cResult += cLine + nl
        next
        
        return cResult

	# Methods with no effect, left here for compatibility
	def SetBarWidth(n)
		# No effect in horizontal bar chart
