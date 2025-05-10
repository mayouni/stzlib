func stzPivotTable(pSource)
    return new stzPivotTable(pSource)

class stzPivotTable
    @oSourceTable
    @aRowLabels = []
    @aColLabels = []
    @aValues = []
    @cAggregationFunction = "SUM"
    @aPivotData = []
    @oResultTable
    @bShowTotalRow = TRUE
    @bShowTotalColumn = TRUE
    @cTotalLabel = "TOTAL"
    @cCellNullValue = ""
    @cRowLabelsSeparator = "_"
    
    # Cache for calculations
    @aCellCache = []
    
    # State tracking
    @bIsGenerated = FALSE

    #--

    def init(pSource)
        if isString(pSource) and lower(pSource) = :fromsource
            return
        ok
        
        # Check if pSource is already a stzTable, if not create one properly
        if isObject(pSource) and classname(pSource) = "stztable"
            @oSourceTable = pSource
        else
            # Make sure to properly initialize the source table
            @oSourceTable = new stzTable(pSource)
        ok
        
        # Initialize cache
        @aCellCache = []

    #--

	def Analyze(paValues, pcFunc)
		This.SetValues(paValues)
		This.SetAggregateFunction(pcFunc)
		This.SetTotalLabel(pcFunc)

	def SetRowsBy(paLabels)
		This.SetRowLabels(paLabels)

	def SetColsBy(paLabels)
		This.SetColumnLabels(paLabels)

	#--

    def SetRowLabels(paLabels)
        if isString(paLabels)
            @aRowLabels = [paLabels]
        else
            @aRowLabels = paLabels
        ok
        @bIsGenerated = FALSE


    def SetRowLabel(pcLabel)
        @aRowLabels = [pcLabel]
        @bIsGenerated = FALSE


    def SetColumnLabels(paLabels)
        if isString(paLabels)
            @aColLabels = [paLabels]
        else
            @aColLabels = paLabels
        ok
        @bIsGenerated = FALSE


    def SetColumnLabel(pcLabel)
        @aColLabels = [pcLabel]
        @bIsGenerated = FALSE


    def SetValues(paValues)
        if isString(paValues)
            @aValues = [paValues]
        else
            @aValues = paValues
        ok
        @bIsGenerated = FALSE


    def SetValue(pcValue)
        @aValues = [pcValue]
        @bIsGenerated = FALSE


    def SetAggregateFunction(pcFunction)
        @cAggregationFunction = upper(pcFunction)
        @bIsGenerated = FALSE


    def SetRowLabelsSeparator(pcSeparator)
        @cRowLabelsSeparator = pcSeparator
        @bIsGenerated = FALSE


    def SetShowTotals(pbShowRow, pbShowCol)
        @bShowTotalRow = pbShowRow
        @bShowTotalColumn = pbShowCol
        @bIsGenerated = FALSE


    def SetHideTotals()
        @bShowTotalRow = FALSE
        @bShowTotalColumn = FALSE
        @bIsGenerated = FALSE


    def SetTotalLabel(pcLabel)
        @cTotalLabel = pcLabel
        @bIsGenerated = FALSE


    def SetNullValue(pcValue)
        @cCellNullValue = pcValue
        @bIsGenerated = FALSE


    #--

    def Generate()
        if len(@aRowLabels) = 0
            stzRaise("You must specify at least one row label")
        ok
        if len(@aColLabels) = 0
            stzRaise("You must specify at least one column label")
        ok
        if len(@aValues) = 0
            stzRaise("You must specify at least one value column")
        ok
        
        # Clear cache
        @aCellCache = []
        
        # Make sure the source table is properly initialized before proceeding
        if NOT isObject(@oSourceTable)
            stzRaise("Source table is not properly initialized")
        ok
        
        # Get unique combinations for rows and columns
        aUniqueRowCombos = _getUniqueCombinations(@aRowLabels)
        aUniqueColCombos = _getUniqueCombinations(@aColLabels)
        
        # Create header structure - this needs to be a flat structure for stzTable compatibility
        @aPivotData = [ @Flatten(_createHeaderStructure(aUniqueColCombos)) ]
        
        # Generate all data rows based on row combinations
        _generateDataRows(aUniqueRowCombos, aUniqueColCombos)
        
        # Create totals if needed
        if @bShowTotalRow
            _addTotalRow()
        ok

        # Create the result table
        @oResultTable = new stzTable(@aPivotData)
        @bIsGenerated = TRUE
        


    #-- 
    
    # Helper function to get all unique combinations of specified fields
    def _getUniqueCombinations(paFields)
        if len(paFields) = 0
            return []
        ok
        
        if len(paFields) = 1
            # For single field, just get unique values
            # Make sure we're handling column names properly
            nColIndex = @oSourceTable.FindCol(paFields[1])
            if nColIndex = 0
                stzRaise("Column not found: " + paFields[1])
            ok
            
            # Get column data starting from row 2 (skip header)
            aCells = []
            nRows = @oSourceTable.NumberOfRows()
            for i = 2 to nRows
                aCells + @oSourceTable.Cell(nColIndex, i)
            next
            
            aUniqueValues = U(aCells)
            aResult = []
            
            for value in aUniqueValues
                aResult + [[value]]
            next
            
            return aResult
        ok
        
        # For multiple fields, we need all combinations
        aAllCombos = []
        aFieldIndices = []
        
        # Get column indices for all fields
        for field in paFields
            nColIndex = @oSourceTable.FindCol(field)
            if nColIndex = 0
                stzRaise("Column not found: " + field)
            ok
            aFieldIndices + nColIndex
        next
        
        # Get all existing combinations from data
        nRowCount = @oSourceTable.NumberOfRows()
        
        # Skip header row
        for r = 2 to nRowCount
            aCombination = []
            
            for i = 1 to len(aFieldIndices)
                aCombination + @oSourceTable.Cell(aFieldIndices[i], r)
            next
            
            # Check if this combination already exists
            bExists = FALSE
            
            for existing in aAllCombos
                if _arraysEqual(existing, aCombination)
                    bExists = TRUE
                    exit
                ok
            next
            
            if not bExists
                aAllCombos + aCombination
            ok
        next
        
        return aAllCombos
    
    # Helper to compare arrays for equality
    def _arraysEqual(a1, a2)
        if len(a1) != len(a2)
            return FALSE
        ok
        
        for i = 1 to len(a1)
            if a1[i] != a2[i]
                return FALSE
            ok
        next
        
        return TRUE
    
    # Create a flat header structure for stzTable compatibility
    def _createHeaderStructure(aColCombos)
        aHeaders = []
        
        # First row includes empty cells for row labels
        aFirstRow = []
        for i = 1 to len(@aRowLabels)
            aFirstRow + ""
        next
        
        # Add column combinations as headers
        for combo in aColCombos
            # Ensure we store the column header as a string, not as an array
            aFirstRow + _combineLabels(combo)
        next
        
        if @bShowTotalColumn
            aFirstRow + @cTotalLabel
        ok
        
        aHeaders + aFirstRow
        
        return [aHeaders]
    
    # Combine multiple labels with separator
    def _combineLabels(aLabels)
        if len(aLabels) = 1
            return aLabels[1]
        ok
        
        cResult = ""
        for i = 1 to len(aLabels)
            if i > 1
                cResult += @cRowLabelsSeparator
            ok
            cResult += aLabels[i]
        next
        
        return cResult
    
    # Generate all data rows based on row combinations
    def _generateDataRows(aRowCombos, aColCombos)
        for rowCombo in aRowCombos
            aRow = []
            aFlatRowCombo = _flattenArray(rowCombo)
            
            # Add row labels
            for i = 1 to len(aFlatRowCombo)
                if i <= len(@aRowLabels)
                    aRow + aFlatRowCombo[i]
                ok
            next
            
            # Fill any missing row labels with empty strings
            while len(aRow) < len(@aRowLabels)
                aRow + ""
            end
            
            nRowTotal = 0
            
            # Add values for each column combination
            for colCombo in aColCombos
                aFlatColCombo = _flattenArray(colCombo)
                nCellValue = _calculateCellValueMulti(aFlatRowCombo, aFlatColCombo)
                aRow + nCellValue
                
                if @bShowTotalColumn and isNumber(nCellValue)
                    nRowTotal += nCellValue
                ok
            next
            
            # Add row total if needed
            if @bShowTotalColumn
                aRow + nRowTotal
            ok
            
            @aPivotData + aRow
        next
    
    # Add total row
    def _addTotalRow()
        aTotalRow = []
        
        # Add label(s) for total row
        for i = 1 to len(@aRowLabels)
            if i = 1
                aTotalRow + @cTotalLabel
            else
                aTotalRow + ""
            ok
        next
        
        # Calculate column totals
        nColCount = len(@aPivotData[1])
        nRowCount = len(@aPivotData)
        
        for c = len(@aRowLabels) + 1 to nColCount
            nColTotal = 0
            
            # Sum values in this column (skip header row)
            for r = 2 to nRowCount
                if isNumber(@aPivotData[r][c])
                    nColTotal += @aPivotData[r][c]
                ok
            next
            
            aTotalRow + nColTotal
        next
        
        @aPivotData + aTotalRow
    
    # Calculate cell value for multiple row and column dimensions
    def _calculateCellValueMulti(aRowValues, aColValues)
        # Handle nested arrays (flatten them)
        aFlatRowValues = _flattenArray(aRowValues)
        aFlatColValues = _flattenArray(aColValues)
        
        # Check cache first
        cCacheKey = _getCacheKey(aFlatRowValues, aFlatColValues)
        if _checkCache(cCacheKey)
            return _getFromCache(cCacheKey)
        ok
        
        # Collect matching values
        aMatchingValues = []
        cValueField = @aValues[1]
        nValueColIndex = @oSourceTable.FindCol(cValueField)
        
        # Make sure value column exists
        if nValueColIndex = 0
            stzRaise("Value column not found: " + cValueField)
        ok
        
        # Get indices for all row and column fields
        aRowIndices = []
        for field in @aRowLabels
            nRowIndex = @oSourceTable.FindCol(field)
            if nRowIndex = 0
                stzRaise("Row column not found: " + field)
            ok
            aRowIndices + nRowIndex
        next
        
        aColIndices = []
        for field in @aColLabels
            nColIndex = @oSourceTable.FindCol(field)
            if nColIndex = 0
                stzRaise("Column not found: " + field)
            ok
            aColIndices + nColIndex
        next
        
        # Loop through all data rows (skip header)
        nRowCount = @oSourceTable.NumberOfRows()
        
        for r = 2 to nRowCount
            bRowMatch = TRUE
            bColMatch = TRUE
            
            # Check if row fields match
            for i = 1 to len(aRowIndices)
                if i <= len(aFlatRowValues)
                    if @oSourceTable.Cell(aRowIndices[i], r) != aFlatRowValues[i]
                        bRowMatch = FALSE
                        exit
                    ok
                ok
            next
            
            if not bRowMatch
                loop
            ok
            
            # Check if column fields match
            for i = 1 to len(aColIndices)
                if i <= len(aFlatColValues)
                    if @oSourceTable.Cell(aColIndices[i], r) != aFlatColValues[i]
                        bColMatch = FALSE
                        exit
                    ok
                ok
            next
            
            if not bColMatch
                loop
            ok
            
            # All conditions match, add value
            value = @oSourceTable.Cell(nValueColIndex, r)
            if isNumber(value)
                aMatchingValues + value
            ok
        next
        
        # Apply aggregation and cache result
        result = _applyAggregateFunction(aMatchingValues)
        _addToCache(cCacheKey, result)
        
        return result
    
    # Cache operations
    def _getCacheKey(aRowValues, aColValues)
        cKey = ""
        
        # Handle nested arrays or simple values
        if isList(aRowValues) 
            if len(aRowValues) > 0 and isList(aRowValues[1])
                # Handle nested arrays like [ [ "North" ] ]
                for subArr in aRowValues
                    for value in subArr
                        cKey += "R:" + value + ";"
                    next
                next
            else
                # Handle flat arrays like [ "North" ]
                for value in aRowValues
                    cKey += "R:" + value + ";"
                next
            ok
        ok
        
        # Same logic for column values
        if isList(aColValues)
            if len(aColValues) > 0 and isList(aColValues[1])
                for subArr in aColValues
                    for value in subArr
                        cKey += "C:" + value + ";"
                    next
                next
            else
                for value in aColValues
                    cKey += "C:" + value + ";"
                next
            ok
        ok
        
        return cKey
    
    def _checkCache(cKey)
        for item in @aCellCache
            if item[1] = cKey
                return TRUE
            ok
        next
        return FALSE
    
    def _getFromCache(cKey)
        for item in @aCellCache
            if item[1] = cKey
                return item[2]
            ok
        next
        return NULL
    
    def _addToCache(cKey, value)
        @aCellCache + [cKey, value]
    
    def _applyAggregateFunction(aValues)
        if len(aValues) = 0
            return @cCellNullValue
        ok
        
        switch @cAggregationFunction
            on "SUM"
                nResult = 0
                for value in aValues
                    nResult += value
                next
                return nResult
                
            on "AVERAGE"
                nSum = 0
                for value in aValues
                    nSum += value
                next
                return nSum / len(aValues)
                
            on "COUNT"
                return len(aValues)
                
            on "MIN"
                nMin = aValues[1]
                for value in aValues
                    if value < nMin
                        nMin = value
                    ok
                next
                return nMin
                
            on "MAX"
                nMax = aValues[1]
                for value in aValues
                    if value > nMax
                        nMax = value
                    ok
                next
                return nMax
                
            on "MEDIAN"
                aValuesSorted = sort(aValues)
                nLen = len(aValuesSorted)
                
                if nLen % 2 = 1
                    return aValuesSorted[ceil(nLen/2)]
                else
                    return (aValuesSorted[nLen/2] + aValuesSorted[(nLen/2)+1]) / 2
                ok
                
            on "FIRST"
                return aValues[1]
                
            on "LAST"
                return aValues[len(aValues)]
                
            other
                stzRaise("Unsupported aggregation function: " + @cAggregationFunction)
        off

    #--

    # DATA ACCESS METHODS

    # Helper method to flatten arrays (handle nested arrays)
    def _flattenArray(aArray)
        if not isList(aArray)
            return [aArray]
        ok
        
        if len(aArray) = 0
            return []
        ok
        
        if isList(aArray[1])
            # Handle nested arrays
            aResult = []
            for subArr in aArray
                if isList(subArr)
                    for item in subArr
                        aResult + item
                    next
                else
                    aResult + subArr
                ok
            next
            return aResult
        else
            # Already flat
            return aArray
        ok
    
    def Value(paRowValues, paColValues)
        if not @bIsGenerated
            Generate()
        ok
        
        # Flatten arrays if needed
        aFlatRowValues = _flattenArray(paRowValues)
        aFlatColValues = _flattenArray(paColValues)
        
        # Find row index
        nRowIndex = 0
        for r = 2 to len(@aPivotData)
            bMatch = TRUE
            
            for i = 1 to len(aFlatRowValues)
                if i <= len(@aRowLabels) and @aPivotData[r][i] != aFlatRowValues[i]
                    bMatch = FALSE
                    exit
                ok
            next
            
            if bMatch
                nRowIndex = r
                exit
            ok
        next
        
        if nRowIndex = 0
            return NULL
        ok
        
        # Find column index
        nColIndex = 0
        cColLabel = _combineLabels(aFlatColValues)
        
        for c = len(@aRowLabels) + 1 to len(@aPivotData[1])
            if @aPivotData[1][c] = cColLabel
                nColIndex = c
                exit
            ok
        next
        
        if nColIndex = 0
            return NULL
        ok
        
        return @aPivotData[nRowIndex][nColIndex]

    def RowTotal(paRowValues)
        if not @bIsGenerated
            Generate()
        ok
        
        if not @bShowTotalColumn
            return NULL
        ok
        
        # Flatten arrays if needed
        aFlatRowValues = _flattenArray(paRowValues)
        
        # Find row
        nRowIndex = 0
        for r = 2 to len(@aPivotData)
            bMatch = TRUE
            
            for i = 1 to len(aFlatRowValues)
                if i <= len(@aRowLabels) and @aPivotData[r][i] != aFlatRowValues[i]
                    bMatch = FALSE
                    exit
                ok
            next
            
            if bMatch
                nRowIndex = r
                exit
            ok
        next
        
        if nRowIndex = 0
            return NULL
        ok
        
        return @aPivotData[nRowIndex][len(@aPivotData[1])]

    def ColumnTotal(paColValues)
        if not @bIsGenerated
            Generate()
        ok
        
        if not @bShowTotalRow
            return NULL
        ok
        
        # Flatten arrays if needed
        aFlatColValues = _flattenArray(paColValues)
        
        # Find column
        nColIndex = 0
        cColLabel = _combineLabels(aFlatColValues)
        
        for c = len(@aRowLabels) + 1 to len(@aPivotData[1])
            if @aPivotData[1][c] = cColLabel
                nColIndex = c
                exit
            ok
        next
        
        if nColIndex = 0
            return NULL
        ok
        
        return @aPivotData[len(@aPivotData)][nColIndex]

    def GrandTotal()
        if not @bIsGenerated
            Generate()
        ok
        
        if not (@bShowTotalRow and @bShowTotalColumn)
            return NULL
        ok
        
        return @aPivotData[len(@aPivotData)][len(@aPivotData[1])]

    #-- SERIALIZATION METHODS

    def SaveToFile(cFileName)
        if not @bIsGenerated
            Generate()
        ok
        
        aSerializedData = [
            :RowLabels = @aRowLabels,
            :ColLabels = @aColLabels,
            :Values = @aValues,
            :AggregationFunction = @cAggregationFunction,
            :ShowTotalRow = @bShowTotalRow,
            :ShowTotalColumn = @bShowTotalColumn,
            :TotalLabel = @cTotalLabel,
            :CellNullValue = @cCellNullValue,
            :RowLabelsSeparator = @cRowLabelsSeparator,
            :PivotData = @aPivotData
        ]
        
        write(cFileName, list2str(aSerializedData))


    def LoadFromFile(cFileName)
        if not fexists(cFileName)
            stzRaise("File not found: " + cFileName)
        ok
        
        cContent = read(cFileName)
        aData = str2list(cContent)
        
        @aRowLabels = aData[:RowLabels]
        @aColLabels = aData[:ColLabels]
        @aValues = aData[:Values]
        @cAggregationFunction = aData[:AggregationFunction]
        @bShowTotalRow = aData[:ShowTotalRow]
        @bShowTotalColumn = aData[:ShowTotalColumn]
        @cTotalLabel = aData[:TotalLabel]
        @cCellNullValue = aData[:CellNullValue]
        @cRowLabelsSeparator = aData[:RowLabelsSeparator]
        @aPivotData = aData[:PivotData]
        
        # Create result table from loaded data
        @oResultTable = new stzTable(@aPivotData)
        @bIsGenerated = TRUE
        


    #--

    def ToTable()
        if not @bIsGenerated
            Generate()
        ok
        return @oResultTable

    #--

    def Show()
        if not @bIsGenerated
            Generate()
        ok
        
        # Create a formatted display that properly handles multi-dimensional data
		if len(@aColLabels) <= 2 and len(@aRowLabels) <=2
       		_showFormattedPivotTable2D()
		else
			_showFormattedPivotTable2DPlus()
		ok        

/*===================
*/
def _showFormattedPivotTable2D()
	aPivotData = @aPivotData
	aRowDims = @aRowLabels
	aColDims = @aColLabels
	cTotalLabel = @cTotalLabel

    # Extract dimension values from headers
    aRowLabelCols = []
    aDataCols = []
    nTotalColIndex = 0
    
    # Get header row for analysis
    aHeaderRow = aPivotData[1]
    
    # Process row dimensions
    for i = 1 to len(aRowDims)
        add(aRowLabelCols, i)
    next
    
    # Process data columns and find totals column
    for i = len(aRowDims) + 1 to len(aHeaderRow)
        if aHeaderRow[i] = cTotalLabel
            nTotalColIndex = i
        else
            add(aDataCols, i)
        ok
    next
    
    # Parse dimension values from headers
    aColDim1Values = []  # First column dimension values (replaces aExperience)
    aColDim2Values = []  # Second column dimension values (replaces aGender)
    aColGroups = []
    
    for i = 1 to len(aDataCols)
        colIdx = aDataCols[i]
        colHeader = aHeaderRow[colIdx]
        
        if colHeader != ""
            aParts = @split(colHeader, "_")
            
            dim1Value = aParts[1]
            dim2Value = aParts[2]
            
            # Add to dimension values if not already included (using general approach)
            if ring_find(aColDim1Values, dim1Value) = 0
                add(aColDim1Values, dim1Value)
            ok
            
            if ring_find(aColDim2Values, dim2Value) = 0
                add(aColDim2Values, dim2Value)
            ok
            
            # Store column mapping - using a proper key structure
            key = dim1Value + "_" + dim2Value
            aColGroups[key] = colIdx
        ok
    next

    # NOTE: Removed hard-coded sorting for junior/senior and female/male
    # Values will be displayed in the order they appear in the data
    
    # Calculate widths for row labels
    aRowLabelWidths = []
    for i = 1 to len(aRowDims)
        maxWidth = len(aRowDims[i])
        
        # Check all data rows
        for r = 2 to len(aPivotData) - 1
            cellValue = "" + aPivotData[r][i]
            if len(cellValue) > maxWidth
                maxWidth = len(cellValue)
            ok
        next
        
        add(aRowLabelWidths, maxWidth + 2)  # Add padding
    next
   
    # Calculate widths for data columns
    aDataColWidths = []
    nMinDataWidth = 10  # Minimum width for data columns
    
    for dim1Value in aColDim1Values
        for dim2Value in aColDim2Values
            key = dim1Value + "_" + dim2Value
            colIdx = aColGroups[key]
            
            if colIdx != NULL
                maxWidth = len(dim2Value)  # Use second dimension for width calculation
                
                # Check all data rows
                for r = 2 to len(aPivotData)
                    if colIdx <= len(aPivotData[r])
                        cellValue = "" + aPivotData[r][colIdx]
                        if len(cellValue) > maxWidth
                            maxWidth = len(cellValue)
                        ok
                    ok
                next
                
                aDataColWidths[key] = max([nMinDataWidth, maxWidth + 2])  # Add padding
            ok
        next
    next
    
    # Calculate width for total column
    nTotalColWidth = len(cTotalLabel)
    
    for r = 2 to len(aPivotData)
        if nTotalColIndex <= len(aPivotData[r])
            cellValue = "" + aPivotData[r][nTotalColIndex]
            if len(cellValue) > nTotalColWidth
                nTotalColWidth = len(cellValue)
            ok
        ok
    next
    
    nTotalColWidth += 2  # Add padding
    
    # Row label section width
    nRowLabelSectionWidth = 0
    for width in aRowLabelWidths
        nRowLabelSectionWidth += width
    next
    nRowLabelSectionWidth += len(aRowDims) - 1  # For separators
    
    # Border characters
    aBorder = [
        :TopLeft = "╭",
        :TopRight = "╮",
        :BottomLeft = "╰",
        :BottomRight = "╯",
        :Horizontal = "─",
        :Vertical = "│",
        :TeeRight = "├",
        :TeeLeft = "┤",
        :TeeDown = "┬",
        :TeeUp = "┴",
        :Cross = "┼"
    ]
    
    # Start building the output
    cOutput = ""
    
    # 1. Top border of the table
    cLine = aBorder[:TopLeft]
    
    # Add row labels section
    for i = 1 to len(aRowLabelWidths)
        cLine += StrFill(aRowLabelWidths[i], aBorder[:Horizontal])
        if i < len(aRowLabelWidths)
            cLine += aBorder[:Horizontal]
        ok
    next
    
    # Add column headers section - first dimension groups
    cLine += aBorder[:TeeDown]
    
    # Calculate width for first dimension groups
    aDim1Widths = []
    for dim1Value in aColDim1Values
        dim1Width = 0
        for dim2Value in aColDim2Values
            key = dim1Value + "_" + dim2Value
            if aDataColWidths[key] != NULL
                dim1Width += aDataColWidths[key]
            ok
        next
        # Add separators between second dimension values
        if len(aColDim2Values) > 1
            dim1Width += len(aColDim2Values) - 1
        ok
        aDim1Widths[dim1Value] = dim1Width
    next
    
    # Add dimension sections
    for i = 1 to len(aColDim1Values)
        dim1Value = aColDim1Values[i]
        cLine += StrFill(aDim1Widths[dim1Value], aBorder[:Horizontal])
        if i < len(aColDim1Values)
            cLine += aBorder[:TeeDown]
        ok
    next
    
    # Add the total column
    cLine += aBorder[:TeeDown] + StrFill(nTotalColWidth, aBorder[:Horizontal]) + aBorder[:TopRight]
    cOutput += cLine + nl()
    
    # 2. First header row with first dimension groups
    cLine = aBorder[:Vertical]
    
    # Space for row dimension headers
    for i = 1 to len(aRowLabelWidths)
        cLine += StrFill(aRowLabelWidths[i], " ")
        if i < len(aRowLabelWidths)
            cLine += " "
        ok
    next
    
    cLine += aBorder[:Vertical]
    
    # Add first dimension headers
    for i = 1 to len(aColDim1Values)
        dim1Value = aColDim1Values[i]
        # Capitalize first letter for display
        dim1Display = Upper(Left(dim1Value, 1)) + SubStr(dim1Value, 2)
        cLine += CenterText(dim1Display, aDim1Widths[dim1Value])
        
        if i < len(aColDim1Values)
            cLine += aBorder[:Vertical]
        ok
    next
    
    # Add empty space for total column
    cLine += aBorder[:Vertical] + StrFill(nTotalColWidth, " ") + aBorder[:Vertical]
    cOutput += cLine + nl()
    
    # 3. Horizontal line separator after first dimension headers
    cLine = aBorder[:TeeRight]
    
    # Add separators for row dimensions
    for i = 1 to len(aRowLabelWidths)
        cLine += StrFill(aRowLabelWidths[i], aBorder[:Horizontal])
        if i < len(aRowLabelWidths)
            cLine += aBorder[:TeeDown]
        ok
    next
    
    cLine += aBorder[:Cross]
    
    # Add separators under first dimension headers
    for dim1Value in aColDim1Values
        # Get all second dimension columns for this first dimension
        for dim2Value in aColDim2Values
            key = dim1Value + "_" + dim2Value
            if aDataColWidths[key] != NULL
                dim2Width = aDataColWidths[key]
                cLine += StrFill(dim2Width, aBorder[:Horizontal])
                
                if dim2Value != aColDim2Values[len(aColDim2Values)]
                    cLine += aBorder[:TeeDown]
                ok
            ok
        next
        
        if dim1Value != aColDim1Values[len(aColDim1Values)]
            cLine += aBorder[:Cross]
        ok
    next
    
    # Add separator for total column
    cLine += aBorder[:TeeLeft] + StrFill(nTotalColWidth," ") + aBorder[:Vertical]
    cOutput += cLine + nl()
    
    # 4. Second dimension header row
    cLine = aBorder[:Vertical]
    
    # Add row dimension headers
    for i = 1 to len(aRowDims)
        dim = aRowDims[i]
        oDim = StzStringQ(dim)
        capitalized = Upper(Left(dim, 1)) + oDim.Section(2, oDim.NumberOfChars())
        cLine += CenterText(capitalized, aRowLabelWidths[i])
        
        if i < len(aRowDims)
            cLine += aBorder[:Vertical]
        ok
    next
    
    cLine += aBorder[:Vertical]
    
    # Add second dimension headers under each first dimension group
    for dim1Value in aColDim1Values
        for dim2Value in aColDim2Values
            key = dim1Value + "_" + dim2Value
            if aDataColWidths[key] != NULL
                oDim2 = new stzString(dim2Value)
                capitalizedDim2 = Upper(Left(dim2Value, 1)) + oDim2.Section(2, oDim2.NumberOfChars())
                cLine += CenterText(capitalizedDim2, aDataColWidths[key])
                
                if dim2Value != aColDim2Values[len(aColDim2Values)]
                    cLine += aBorder[:Vertical]
                ok
            ok
        next
        
        if dim1Value != aColDim1Values[len(aColDim1Values)]
            cLine += aBorder[:Vertical]
        ok
    next
    
    # Add TOTAL label to total column
    cLine += aBorder[:Vertical] + CenterText(Upper(cTotalLabel), nTotalColWidth) + aBorder[:Vertical]
    cOutput += cLine + nl()
    
    # 5. Horizontal line before data rows
    cLine = aBorder[:TeeRight]
    
    # Add separators for row dimensions
    for i = 1 to len(aRowLabelWidths)
        cLine += StrFill(aRowLabelWidths[i], aBorder[:Horizontal])
        if i < len(aRowLabelWidths)
            cLine += aBorder[:Cross]
        ok
    next
    
    cLine += aBorder[:Cross]
    
    # Add separators under second dimension headers
    for dim1Value in aColDim1Values
        for dim2Value in aColDim2Values
            key = dim1Value + "_" + dim2Value
            if aDataColWidths[key] != NULL
                cLine += StrFill(aDataColWidths[key], aBorder[:Horizontal])
                
                if dim2Value != aColDim2Values[len(aColDim2Values)]
                    cLine += aBorder[:Cross]
                ok
            ok
        next
        
        if dim1Value != aColDim1Values[len(aColDim1Values)]
            cLine += aBorder[:Cross]
        ok
    next
    
    # Add separator for total column
    cLine += aBorder[:Cross] + StrFill(nTotalColWidth, aBorder[:Horizontal]) + aBorder[:TeeLeft]
    cOutput += cLine + nl()
    
    # 6. Data rows
    cLastRowDim1 = NULL
    nRowDim1Count = 0
    
    # For each data row (skip header row and total row)
    for r = 2 to len(aPivotData) - 1
        cCurrentRowDim1 = aPivotData[r][1]
        
        # Handle first row dimension grouping
        if cCurrentRowDim1 != cLastRowDim1
            nRowDim1Count++
            cLastRowDim1 = cCurrentRowDim1
        ok
        
        # Data row
        cLine = aBorder[:Vertical]
        
        # Add row dimension values - first dimension
        if cCurrentRowDim1 != aPivotData[r-1][1] or r = 2
            cLine += " " + cCurrentRowDim1 + StrFill(aRowLabelWidths[1] - len(cCurrentRowDim1) - 1, " ")
        else
            cLine += StrFill(aRowLabelWidths[1], " ")
        ok
        
        cLine += aBorder[:Vertical]
        
        # Add second row dimension
        cLine += " " + aPivotData[r][2] + StrFill(aRowLabelWidths[2] - len(aPivotData[r][2]) - 1, " ")
        cLine += aBorder[:Vertical]
        
        # Add data cells grouped by column dimensions
        for dim1Value in aColDim1Values
            for dim2Value in aColDim2Values
                key = dim1Value + "_" + dim2Value
                colIdx = aColGroups[key]
                
                if colIdx != NULL
                    value = @if(colIdx <= len(aPivotData[r]), aPivotData[r][colIdx], "")
                    
                    # Right align numeric values
                    if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
                        cLine += " " + PadLeft(value, aDataColWidths[key] - 2) + " "
                    else
                        cLine += " " + PadRight(value, aDataColWidths[key] - 2) + " "
                    ok
                    
                    if dim2Value != aColDim2Values[len(aColDim2Values)]
                        cLine += aBorder[:Vertical]
                    ok
                ok
            next
            
            if dim1Value != aColDim1Values[len(aColDim1Values)]
                cLine += aBorder[:Vertical]
            ok
        next
        
        # Add the total column
        totalValue = @if(nTotalColIndex <= len(aPivotData[r]), aPivotData[r][nTotalColIndex], "")
        
        # Right-align total value
        if isNumber(totalValue) or (isString(totalValue) and totalValue != "" and isNumber(0 + totalValue))
            cLine += aBorder[:Vertical] + " " + PadLeft(totalValue, nTotalColWidth - 2) + " " + aBorder[:Vertical]
        else
            cLine += aBorder[:Vertical] + " " + PadRight(totalValue, nTotalColWidth - 2) + " " + aBorder[:Vertical]
        ok
        
        cOutput += cLine + nl()
        
        # Add empty line after each category (except the last one)
        if r < len(aPivotData) - 1 and cCurrentRowDim1 != aPivotData[r+1][1] and aPivotData[r+1][1] != cTotalLabel
            # Create an empty row with proper vertical separators
            cLine = aBorder[:Vertical]
            cLine += StrFill(aRowLabelWidths[1], " ") + aBorder[:Vertical]
            cLine += StrFill(aRowLabelWidths[2], " ") + aBorder[:Vertical]
            
            # Add empty cells for each data column
            for dim1Value in aColDim1Values
                for dim2Value in aColDim2Values
                    key = dim1Value + "_" + dim2Value
                    if aDataColWidths[key] != NULL
                        cLine += StrFill(aDataColWidths[key], " ")
                        
                        if dim2Value != aColDim2Values[len(aColDim2Values)]
                            cLine += aBorder[:Vertical]
                        ok
                    ok
                next
                
                if dim1Value != aColDim1Values[len(aColDim1Values)]
                    cLine += aBorder[:Vertical]
                ok
            next
            
            # Add empty total column
            cLine += aBorder[:Vertical] + StrFill(nTotalColWidth, " ") + aBorder[:Vertical]
            cOutput += cLine + nl()
        ok
    next
    
    # 7. Bottom border of data section
    cLine = aBorder[:BottomLeft]
    
    # Add border for row dimensions
    for i = 1 to len(aRowLabelWidths)
        cLine += StrFill(aRowLabelWidths[i], aBorder[:Horizontal])
        if i = 1
            cLine += aBorder[:TeeUp]
        but i < len(aRowLabelWidths)
            cLine += aBorder[:Cross]
        ok
    next
    
    cLine += aBorder[:TeeUp]
    
    # Add border under data cells
    for dim1Value in aColDim1Values
        for dim2Value in aColDim2Values
            key = dim1Value + "_" + dim2Value
            if aDataColWidths[key] != NULL
                cLine += StrFill(aDataColWidths[key], aBorder[:Horizontal])
                
                if dim2Value != aColDim2Values[len(aColDim2Values)]
                    cLine += aBorder[:TeeUp]
                ok
            ok
        next
        
        if dim1Value != aColDim1Values[len(aColDim1Values)]
            cLine += aBorder[:TeeUp]
        ok
    next
    
    # Add separator for total column
    cLine += aBorder[:TeeUp] + StrFill(nTotalColWidth, aBorder[:Horizontal]) + aBorder[:BottomRight]
    cOutput += cLine + nl()
    
    # 8. Totals row
    if len(aPivotData) > 1 and aPivotData[len(aPivotData)][1] = cTotalLabel
        totalRow = aPivotData[len(aPivotData)]

        # Calculate total column width for all cells
        nTotalTextWidth = nRowLabelSectionWidth + 1  # +1 for first vertical bar

        # Format the average label (aligned to center of the first section)
        cLine = " " + PadLeft(Upper(totalRow[1]+" "), nRowLabelSectionWidth) + aBorder[:Vertical]
        
        # Add totals for each data cell by dimension
        for dim1Value in aColDim1Values
            for dim2Value in aColDim2Values
                key = dim1Value + "_" + dim2Value
                colIdx = aColGroups[key]
                
                if colIdx != NULL
                    value = @if(colIdx <= len(totalRow), totalRow[colIdx], "")
                    
                    # Right align numeric values
                    if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
                        cLine += " " + PadLeft(value, aDataColWidths[key] - 2) + " "
                    else
                        cLine += " " + PadRight(value, aDataColWidths[key] - 2) + " "
                    ok
                    
                    if dim2Value != aColDim2Values[len(aColDim2Values)]
                        cLine += aBorder[:Vertical]
                    ok
                ok
            next
            
            if dim1Value != aColDim1Values[len(aColDim1Values)]
                cLine += aBorder[:Vertical]
            ok
        next
        
        # Add the grand total
        grandTotal = @if(nTotalColIndex <= len(totalRow), totalRow[nTotalColIndex], "")
        
        # Right-align grand total
        if isNumber(grandTotal) or (isString(grandTotal) and grandTotal != "" and isNumber(0 + grandTotal))
            cLine += aBorder[:Vertical] + " " + PadLeft(grandTotal, nTotalColWidth - 2) + " " + aBorder[:Vertical]
        else
            cLine += aBorder[:Vertical] + " " + PadRight(grandTotal, nTotalColWidth - 2) + " " + aBorder[:Vertical]
        ok
        
        cOutput += cLine + nl()
    ok

    ? StzStringQ(trim(cOutput)).LastCharRemoved()

# Helper Functions
func PadRight(text, width)
    cStr = "" + text
    nPad = width - len(cStr)
    if nPad > 0
        return cStr + copy(" ", nPad)
    else
        return cStr
    ok

func PadLeft(text, width)
    cStr = "" + text
    nPad = width - len(cStr)
    if nPad > 0
        return copy(" ", nPad) + cStr
    else
        return cStr
    ok

func CenterText(text, width)
    cStr = "" + text
    nPadTotal = width - len(cStr)
    if nPadTotal <= 0
        return cStr
    ok
    
    nPadLeft = floor(nPadTotal / 2)
    nPadRight = nPadTotal - nPadLeft
    
    return copy(" ", nPadLeft) + cStr + copy(" ", nPadRight)

func StrFill(nCount, cChar)
    cResult = ""
    for i = 1 to nCount
        cResult += cChar
    next
    return cResult

def _showFormattedPivotTable2DPlus()
    # Calculate column widths
    aColWidths = []
    for c = 1 to len(@aPivotData[1])
        nMaxWidth = 0
        # Check header width
        if c <= len(@aRowLabels)
            nMaxWidth = len(@aRowLabels[c])
        else
            nMaxWidth = len("" + @aPivotData[1][c])
        ok
        # Check data widths
        for r = 2 to len(@aPivotData)
            nCellWidth = len("" + @aPivotData[r][c])
            if nCellWidth > nMaxWidth
                nMaxWidth = nCellWidth
            ok
        next
        aColWidths + Max([nMaxWidth, 10])  # Minimum width of 10
    next

    # Build header line
    cHeaderLine = ""
    for i = 1 to len(@aRowLabels)
        cPadded = _padRight(@aRowLabels[i], aColWidths[i], " ")
        cHeaderLine += cPadded + " "
    next
    cHeaderLine += "| "
    for c = len(@aRowLabels)+1 to len(@aPivotData[1])
        cPadded = _padRight('' + @aPivotData[1][c], aColWidths[c], " ")
        cHeaderLine += cPadded + " "
    next
    ? @trim(cHeaderLine)

    # Build separator line
    cSepLine = ""
    for c = 1 to len(@aRowLabels)
        cPaddedSep = _padRight('', aColWidths[c], "-")
        cSepLine += cPaddedSep + " "
    next
    cSepLine += "+ "
    for c = len(@aRowLabels)+1 to len(@aPivotData[1])
        cPaddedSep = _padRight('', aColWidths[c], "-")
        cSepLine += cPaddedSep + " "
    next
    ? @trim(cSepLine)

    # Print data rows
    for r = 2 to len(@aPivotData)
        if @bShowTotalRow and r = len(@aPivotData)
            ? trim(cSepLine)  # Separator before total row
        ok
        cRowLine = ""
        # Build left part (row labels)
        for c = 1 to len(@aRowLabels)
            cCell = "" + @aPivotData[r][c]
            cPadded = PadRight(cCell, aColWidths[c], " ")
            cRowLine += cPadded + " "
        next
        cRowLine = @trim(cRowLine) + " | "
        # Build right part (data)
        cDataPart = ""
        for c = len(@aRowLabels)+1 to len(@aPivotData[r])
            cCell = "" + @aPivotData[r][c]
            if isNumber(@aPivotData[r][c])
                cPadded = PadLeft(cCell, aColWidths[c], " ")
            else
                cPadded = PadRight(cCell, aColWidths[c], " ")
            ok
            cDataPart += cPadded + " "
        next
        cRowLine += @trim(cDataPart)
        ? cRowLine
    next
end
