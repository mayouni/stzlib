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

/*
Simplified stzBarChart System
- Fixed 2-char bar width with 2-char spacing
- Optional Y-labels (max 4 chars, auto-padded)
- Right-aligned X-axis values in vertical column
- Optional average line
- Improved ASCII arrows
*/

Class stzChart
    # Core attributes
    @aData = []
    @aLabels = []
    @cCanvas = []
    @nWidth = 40
    @nHeight = 15
    @nMaxValue = 0
    @nMinValue = 0

    def init(paData)
        if isList(paData)
            @aData = paData
            _calculateRange()
        ok

    def SetLabels(aLabels)
        @aLabels = aLabels
        return Self

    def SetDimensions(nWidth, nHeight)
        @nWidth = nWidth
        @nHeight = nHeight
        return Self

    def _calculateRange()
        if len(@aData) > 0
            @nMaxValue = max(@aData)
            @nMinValue = min(@aData)
            if @nMinValue > 0
                @nMinValue = 0
            ok
        ok

    def _initializeCanvas()
        @cCanvas = []
        aTempSpaces = []
        for i = 1 to @nWidth
            aTempSpaces + " "
        next
        for i = 1 to @nHeight
            @cCanvas + aTempSpaces
        next

    def _finalizeCanvas()
        cResult = ""
        nLen = len(@cCanvas)
        for i = 1 to nLen
            cLine = ""
            nLenCurrent = len(@cCanvas[i])
            for j = 1 to nLenCurrent
                cLine += @cCanvas[i][j]
            next
            cResult += cLine + nl
        next
        return cResult

Class stzBarChart from stzChart
    @lShowYLabels = False
    @lShowAverage = False
    @nYAxisWidth = 6  # Fixed width for Y-axis value column

    def init(paData)
        super.init(paData)

    def ShowYLabels(lShow)
        @lShowYLabels = lShow
        return Self

    def ShowAverage(lShow)
        @lShowAverage = lShow
        return Self

    def Render()
        # Calculate required width based on data
        nBars = len(@aData)
        nChartAreaWidth = (nBars * 4) - 2  # 2 chars per bar + 2 spaces between, minus last spacing
        @nWidth = @nYAxisWidth + nChartAreaWidth + 2  # Y-axis + chart + margin
        
        _initializeCanvas()
        _renderYAxis()
        _renderXAxis()
        _renderBars()
        
        if @lShowYLabels
            _renderYLabels()
        ok
        
        if @lShowAverage
            _renderAverageLine()
        ok
        
        return _finalizeCanvas()

    def _renderYAxis()
        # Calculate Y-axis values (5 levels)
        nRange = @nMaxValue - @nMinValue
        aYValues = []
        
        for i = 0 to 4
            nValue = @nMinValue + (nRange * i / 4)
            aYValues + floor(nValue * 100) / 100  # Round to 2 decimals
        next
        
        # Draw Y-axis values and indicators
        for i = 1 to 5
            nRow = @nHeight - 2 - ((i-1) * (@nHeight - 4) / 4)
            nRow = floor(nRow)
            
            # Right-align value in Y-axis column
            cValue = "" + aYValues[6-i]  # Reverse order (top to bottom)
            nValueLen = len(cValue)
            nStartPos = @nYAxisWidth - nValueLen
            
            # Place value
            for j = 1 to nValueLen
                if nStartPos + j - 1 >= 1
                    @cCanvas[nRow][nStartPos + j - 1] = cValue[j]
                ok
            next
            
            # Place indicator on axis
            @cCanvas[nRow][@nYAxisWidth] = "┤"
        next
        
        # Draw vertical axis line
        for i = 2 to @nHeight - 2
            @cCanvas[i][@nYAxisWidth] = "│"
        next
        
        # Improved arrows
        @cCanvas[1][@nYAxisWidth] = "▲"  # Top arrow
        @cCanvas[@nHeight-1][@nWidth-1] = "▶"  # Right arrow

    def _renderXAxis()
        # Draw horizontal axis line
        for i = @nYAxisWidth + 1 to @nWidth - 2
            @cCanvas[@nHeight-2][i] = "─"
        next
        
        # Corner piece
        @cCanvas[@nHeight-2][@nYAxisWidth] = "└"

    def _renderBars()
        nBars = len(@aData)
        nRange = @nMaxValue - @nMinValue
        
        for i = 1 to nBars
            # Calculate bar height
            nVal = @aData[i]
            if nRange = 0
                nBarHeight = 1
            else
                nBarHeight = max([1, floor((@nHeight - 4) * (nVal - @nMinValue) / nRange)])
            ok
            
            # Calculate bar position (2 chars per bar + 2 spaces between)
            nXPos = @nYAxisWidth + 1 + ((i-1) * 4)
            
            # Draw 2-character wide bar
            for j = 1 to nBarHeight
                @cCanvas[@nHeight-2-j][nXPos] = "█"
                @cCanvas[@nHeight-2-j][nXPos+1] = "█"
            next
        next

    def _renderYLabels()
        nBars = len(@aData)
        nLabels = len(@aLabels)
        
        for i = 1 to nBars
            if i <= nLabels
                cLabel = @aLabels[i]
                
                # Ensure label is exactly 4 characters (pad or truncate)
                if len(cLabel) > 4
                    cLabel = left(cLabel, 4)
                else
                    while len(cLabel) < 4
                        cLabel += " "
                    end
                ok
                
                # Position label under bar (2-char bar width)
                nXPos = @nYAxisWidth + 2 + ((i-1) * 4)
                
                # Place 4-character label (2 under bar + 1 on each side)
                for j = 1 to 4
                    if nXPos + j - 2 >= 1 and nXPos + j - 2 <= @nWidth
                        @cCanvas[@nHeight-1][nXPos + j - 2] = cLabel[j]
                    ok
                next
            ok
        next

    def _renderAverageLine()
        # Calculate average
        nSum = 0
        for i = 1 to len(@aData)
            nSum += @aData[i]
        next
        nAvg = nSum / len(@aData)
        
        # Calculate average line position
        nRange = @nMaxValue - @nMinValue
        if nRange > 0
            nAvgRow = @nHeight - 2 - floor((@nHeight - 4) * (nAvg - @nMinValue) / nRange)
        else
            nAvgRow = @nHeight - 3
        ok
        
        # Draw average line across chart area
        nBars = len(@aData)
        for i = @nYAxisWidth + 1 to @nYAxisWidth + (nBars * 4) - 2
            nCol = i
            if @cCanvas[nAvgRow][nCol] = "█"
                @cCanvas[nAvgRow][nCol] = "█"  # Keep bar character
            else
                @cCanvas[nAvgRow][nCol] = "-"  # Draw line
            ok
        next

    def GenerateInsights()
        aInsights = []
        nLenData = len(@aData)
        
        add(aInsights, "Chart displays " + nLenData + " data points.")
        
        # Find extremes
        nMaxIndex = 1
        nMinIndex = 1
        for i = 2 to nLenData
            if @aData[i] > @aData[nMaxIndex]
                nMaxIndex = i
            ok
            if @aData[i] < @aData[nMinIndex]
                nMinIndex = i
            ok
        next
        
        # Calculate average
        nSum = 0
        for i = 1 to len(@aData)
            nSum += @aData[i]
        next
        nAvg = floor((nSum / len(@aData)) * 100) / 100
        
        add(aInsights, "Highest: " + @aData[nMaxIndex] + ", Lowest: " + @aData[nMinIndex] + ", Average: " + nAvg)
        
        cResult = ""
        for i = 1 to len(aInsights)
            cResult += aInsights[i]
            if i < len(aInsights)
                cResult += nl
            ok
        next
        
        return cResult

/*
Class stzChart
    # Core attributes
    @aData = []
    @aLabels = []
    @cCanvas = []  # 2D array to hold the ASCII art
    @nWidth = 40
    @nHeight = 15
    @nMaxValue = 0
    @nMinValue = 0

    # Constructor
    def init(paData)
        if isList(paData)
            @aData = paData
            _calculateRange()
        ok

    # Core configuration methods
    def SetLabels(aLabels)
        @aLabels = aLabels
        return Self

    def SetDimensions(nWidth, nHeight)
        @nWidth = nWidth
        @nHeight = nHeight
        return Self

    # Core rendering methods
    def Render()
        _initializeCanvas()
        _renderAxis()
        _renderData()
        return _finalizeCanvas()

    def _initializeCanvas()
        @cCanvas = []

        aTempSpaces = []
        for i = 1 to @nWidth
            aTempSpaces + " "
        next

        for i = 1 to @nHeight
            @cCanvas + aTempSpaces
        next

    def _renderAxis()
        # Draw Y-axis
        for i = 1 to @nHeight - 2
            @cCanvas[i][1] = "│"
        next

        # Draw X-axis
        for i = 1 to @nWidth - 2
            @cCanvas[@nHeight-2][i] = "─"
        next

        # Draw origin
        @cCanvas[@nHeight-2][1] = "└"

        # Add arrow to Y-axis
        @cCanvas[1][1] = "↑"

        # Add arrow to X-axis
        @cCanvas[@nHeight-2][@nWidth-2] = "→"

    def _renderData()
        # Abstract method to be implemented by subclasses
        return

    def _finalizeCanvas()
        cResult = ""
        nLen = len(@cCanvas)

        for i = 1 to nLen
            cLine = ""
            nLenCurrent = len(@cCanvas[i])
            for j = 1 to nLenCurrent
                cLine += @cCanvas[i][j]
            next
            cResult += cLine + nl
        next
        return cResult

    # Helper methods
    def _calculateRange()
        if len(@aData) > 0
            @nMaxValue = max(@aData)
            @nMinValue = min(@aData)

            # Ensure range starts from 0
            if @nMinValue > 0
                @nMinValue = 0
            ok
        ok

    def _drawText(nRow, cText)
        nLen = len(cText)

        for i = 1 to nLen
            if i <= @nWidth
                @cCanvas[nRow][i] = cText[i]
            ok
        next

Class stzBarChart from stzChart
    @cType = "bar"
    @nMaxConsoleWidth = 120
    @nMinBarWidth = 1
    @nLabelSpacing = 1

    def init(paData)
        super.init(paData)

    def _renderData()
        nBars = len(@aData)
        if nBars = 0
            return
        ok

        # Calculate optimal layout within max width constraint
        aLayout = _calculateOptimalLayout()
        nBarWidth = aLayout[1]
        nBarSpacing = aLayout[2]
        nLabelSpacing = aLayout[3]

        for i = 1 to nBars
            # Calculate bar height
            nVal = @aData[i]
            nRange = @nMaxValue - @nMinValue
            if nRange = 0
                nBarHeight = 1
            else
                nBarHeight = max([1, floor((@nHeight - 4) * (nVal - @nMinValue) / nRange)])
            ok

            # Calculate bar position
            nXPos = 5 + ((i-1) * (nBarWidth + nBarSpacing))
            
            # Draw bar
            for j = 1 to nBarHeight
                for k = 0 to nBarWidth-1
                    if nXPos + k <= @nWidth - 2
                        @cCanvas[@nHeight-2-j][nXPos+k] = "█"
                    ok
                next
            next

            # Draw label below bar - optimized alignment pattern
            if i <= len(@aLabels)
                cLabel = @aLabels[i]
                nLabelLen = len(cLabel)
                
                # Label starts 1 position before bar for better alignment
                nLabelStart = max([1, nXPos - 1])
                
                # Ensure label doesn't exceed allocated space
                nMaxAllowedLen = nBarWidth + 2  # Bar width + 1 before + 1 after
                if nLabelLen > nMaxAllowedLen
                    cLabel = left(cLabel, nMaxAllowedLen)
                    nLabelLen = len(cLabel)
                ok
                
                # Place label characters
                for k = 1 to nLabelLen
                    nPos = nLabelStart + k - 1
                    if nPos <= @nWidth - 1 and nPos >= 1
                        @cCanvas[@nHeight-1][nPos] = cLabel[k]
                    ok
                next
            ok
        next

    def _calculateOptimalLayout()
        nBars = len(@aData)
        nAvailableWidth = min([@nWidth, @nMaxConsoleWidth]) - 10
        
        if nBars = 0
            return [1, 1, 1]
        ok

        # Get maximum label length
        nMaxLabelLen = 0
        if len(@aLabels) > 0
            for i = 1 to len(@aLabels)
                nLabelLen = len(@aLabels[i])
                if nLabelLen > nMaxLabelLen
                    nMaxLabelLen = nLabelLen
                ok
            next
        ok

        # Calculate optimal pattern: label can start 1 position before bar
        # This allows better alignment and space utilization
        nBarWidth = max([2, floor(nMaxLabelLen / 2) + 1])  # At least 2 chars wide
        nLabelOverhang = 1  # Label starts 1 position before bar
        
        # Space needed: label width + min spacing between labels
        nSpaceBetweenLabels = max([1, nMaxLabelLen - nBarWidth + 1])
        nTotalSpacePerUnit = nMaxLabelLen + nSpaceBetweenLabels
        nTotalNeededSpace = nBars * nTotalSpacePerUnit - nSpaceBetweenLabels
        
        if nTotalNeededSpace <= nAvailableWidth
            # Perfect fit or extra space - can increase bar width
            nExtraSpace = nAvailableWidth - nTotalNeededSpace
            nExtraBarWidth = floor(nExtraSpace / nBars)
            nBarWidth = nBarWidth + nExtraBarWidth
            
            nBarSpacing = nMaxLabelLen + nSpaceBetweenLabels
        else
            # Tight fit - optimize for readability
            nBarSpacing = floor(nAvailableWidth / nBars)
            nBarWidth = min([nBarWidth, nBarSpacing - 1])
            nSpaceBetweenLabels = max([1, nBarSpacing - nMaxLabelLen])
        ok

        # Update chart width to accommodate all bars
        nActualWidth = (nBars * nBarSpacing) + 10
        @nWidth = min([nActualWidth, @nMaxConsoleWidth])

        return [nBarWidth, nBarSpacing, nSpaceBetweenLabels]

    def GenerateInsights()
        aInsights = []
        nLenData = len(@aData)

        add(aInsights, "The chart displays " + nLenData + " data points.")

        # Find max and min values
        nMaxIndex = 1
        nMinIndex = 1

        for i = 2 to nLenData
            if @aData[i] > @aData[nMaxIndex]
                nMaxIndex = i
            ok
            if @aData[i] < @aData[nMinIndex]
                nMinIndex = i
            ok
        next

        nLenLabels = len(@aLabels)
        cMaxLabel = ""
        cMinLabel = ""

        if nMaxIndex <= nLenLabels
            cMaxLabel = @aLabels[nMaxIndex]
        else
            cMaxLabel = "Bar " + nMaxIndex
        ok

        if nMinIndex <= nLenLabels
            cMinLabel = @aLabels[nMinIndex]
        else
            cMinLabel = "Bar " + nMinIndex
        ok

        add(aInsights, "The highest value is " + @aData[nMaxIndex] + ", represented by " + cMaxLabel + ".")
        add(aInsights, "The lowest value is " + @aData[nMinIndex] + ", represented by " + cMinLabel + ".")

        # Calculate average
        nSum = 0
        for i = 1 to len(@aData)
            nSum += @aData[i]
        next
        nAvg = nSum / len(@aData)
        nFormattedAvg = floor(nAvg * 100) / 100

        add(aInsights, "The average value across all data points is " + nFormattedAvg + ".")

        cResult = ""
        for i = 1 to len(aInsights)
            cResult += aInsights[i]
            if i < len(aInsights)
                cResult += nl
            ok
        next

        return cResult
