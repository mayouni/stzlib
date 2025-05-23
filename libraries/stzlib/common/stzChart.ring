/*
A class for ascii-based charts, working with stzTable and stzPivotTable

Get inspiration from:
https://www.bloomberg.com/graphics/year-ahead-2016/

https://github.com/alincoop/obsidian-tinychart

https://github.com/madnight/bitcoin-chart-cli


╭────────────────────────────────────────────────────╮
│                                                  	 │
│   MOBILE DEVICES RUNNING IOS                     	 │
│   2022 - 2024 forecasts                          	 │
│                                       XXX        	 │
│   XXX Smartphones                     XXX          │                             	 │
│	||| Tablets 	      	    	    XXX   		 │
│		      	      	      	      	XXX   		 │
│		      	      	      	XXX   	XXX   		 │
│		      	      	      	XXX   	XXX|||		 │		
│		      	      	      	XXX   	XXX|||		 │
│		      	      	XXX   	XXX   	XXX|||		 │
│		      	      	XXX   	XXX|||	XXX|||		 │
│		      	XXX   	XXX   	XXX|||	XXX|||		 │
│		      	XXX   	XXX   	XXX|||	XXX|||		 │
│		XXX   	XXX   	XXX|||	XXX|||	XXX|||		 │
│		XXX   	XXX	   	XXX|||	XXX|||	XXX|||		 │
│		XXX   	XXX   	XXX|||	XXX|||	XXX|||		 │
│		XXX   	XXX|||	XXX|||	XXX|||	XXX|||		 │
│		XXX|||  XXX|||	XXX|||	XXX|||	XXX|||		 │
│		XXX|||	XXX|||	XXX|||	XXX|||	XXX|||		 │
│		XXX|||	XXX|||	XXX|||	XXX|||	XXX|||		 │
│                                                    │
│		 2020 	 2021 	 2022	 2023 	 2024        │
│                        forecast------------>       │
│                                                    │
╰────────────────────────────────────────────────────╯
			             Made with ♥ using stzChart


            ╭╮
           ╭╯╰╮
           │  ╰╮
          ╭╯   ╰────╮
       ╭──╯         ╰╮
	  ╭╯             ╰──╮
    ──╯                 ╰──────


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
		if NOT ( isList(paDataSet) and IsHashList(paDataSet) )
			StzRaise("Can't create the stzChart object! paDataSet must be a hashlist.")
		ok

		oHash = new stzHashList(paDataSet)
		@aDataSet = oHash.Values()
		if NOT ISListOfNumbers(@aDataSet)
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

    def _calculateRange()

        if len(@aDataSet) > 0
            @nMaxValue = max(@aDataSet)
            @nMinValue = min(@aDataSet)
        ok

    def _initializeCanvas()
        @acCanvas = []
        aTempSpaces = []
        for i = 1 to @nWidth
            aTempSpaces + " "
        next
        for i = 1 to @nHeight
            @acCanvas + aTempSpaces
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
            cResult += cLine + nl
        next
        return cResult


class stzBarChart from stzChart
    @bSetYLabels = False
    @bSetAverageLine = False
    @bShowValues = False    # New attribute to toggle value display
    @nBarWidth = 2
    @nMaxWidth = 132
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
        @bSetYLabels = bShow
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

    def SetShowValues(bShow)    # New method to set value display
        @bShowValues = bShow

    def AddValues()             # New convenience method
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
        @nWidth = nYAxisWidth + @nBarInterSpace + @nBarInterSpace + nTotalChartWidth + @nBarInterSpace
        
        if not @bSetYLabels
            @nWidth += (@nBarInterSpace * 2)
        ok
        
        if @nWidth > @nMaxWidth
            raise("Chart width (" + @nWidth + ") exceeds maximum allowed width (" + @nMaxWidth + ")")
        ok
        
        _initializeCanvas()
        _renderYAxis(nYAxisWidth)
        _renderXAxis(nYAxisWidth, nTotalChartWidth)
        _renderBars(nYAxisWidth, aSpacing)
        
        if @bShowValues         # Check and render values if enabled
            _renderValues(nYAxisWidth, aSpacing)
        ok
        
        if @bSetYLabels
            _renderXLabels(nYAxisWidth, aSpacing)
        ok
        
        if @bSetAverageLine
            _renderAverageLine(nYAxisWidth, nTotalChartWidth)
        ok
        
        return " " + @trim(_finalizeCanvas())

    def _calculateOptimalSpacing()
        nBars = len(@aDataSet)
        aSpacing = []
        
        if not @bSetYLabels
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
            if @bSetYLabels
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
        nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace
        for i = 2 to @nHeight - 2
            @acCanvas[i][nAxisCol] = @cXAxisChar
        next
        @acCanvas[1][nAxisCol] = @cXArrowChar

    def _renderXAxis(nYAxisWidth, nTotalChartWidth)
        nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace
        nAxisRow = @nHeight - 2
        nEndCol = nAxisCol + nTotalChartWidth
        nStartCol = nAxisCol
        if not @bSetYLabels
            nStartCol = nAxisCol + @nBarInterSpace
            nEndCol = nEndCol + @nBarInterSpace
        ok
        for i = nStartCol to nEndCol
            @acCanvas[nAxisRow][i] = @cYAxisChar
        next
        @acCanvas[nAxisRow][nAxisCol] = @cOriginChar
        @acCanvas[nAxisRow][nEndCol + @nBarInterSpace] = @cYArrowChar

    def _renderBars(nYAxisWidth, aSpacing)
        nBars = len(@aDataSet)
        nRange = @nMaxValue - @nMinValue
        nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace
        nAxisRow = @nHeight - 2
        nChartHeight = @nHeight - 4
        
        nCurrentX = nAxisCol + @nBarInterSpace
        if not @bSetYLabels
            nCurrentX += @nBarInterSpace
        ok
        
        for i = 1 to nBars
            if @bSetYLabels
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

    def _renderValues(nYAxisWidth, aSpacing)    # New method to render values
        nBars = len(@aDataSet)
        nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace
        nAxisRow = @nHeight - 2
        nChartHeight = @nHeight - 4
        
        nCurrentX = nAxisCol + @nBarInterSpace
        if not @bSetYLabels
            nCurrentX += @nBarInterSpace
        ok
        
        for i = 1 to nBars
            if @bSetYLabels
                cLabel = ""
                if i <= len(@acLabels)
                    cLabel = @acLabels[i]
                ok
                nLabelLen = len(cLabel)
                nElementWidth = max([nLabelLen, @nBarWidth])
            else
                nElementWidth = @nBarWidth
            ok
            
            nBarStartX = nCurrentX + floor((nElementWidth - @nBarWidth) / 2.0)
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
            
            cValue = string(@aDataSet[i])
            nValueLen = len(cValue)
            nStart = nBarStartX + floor((@nBarWidth - nValueLen) / 2.0)
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
        nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace
        nLabelRow = @nHeight - 1
        nBars = len(@aDataSet)
        
        nCurrentX = nAxisCol + @nBarInterSpace

		
        for i = 1 to nBars
            if i <= len(@acLabels)
                cLabel = Capitalize(@acLabels[i])
                nLabelLen = len(cLabel)
                nElementWidth = max([nLabelLen, @nBarWidth])
                nLabelStartX = nCurrentX + floor((nElementWidth - nLabelLen) / 2.0)
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
        
        nAxisCol = nYAxisWidth + @nBarInterSpace + @nBarInterSpace
        nLineStart = nAxisCol + @nBarInterSpace
        nLineEnd = nAxisCol + nTotalChartWidth
        
        for i = nLineStart to nLineEnd
            if @acCanvas[nAvgRow][i] = @cBarChar
                @acCanvas[nAvgRow][i] = @cBarChar
            else
                @acCanvas[nAvgRow][i] = "-"
            ok
        next
