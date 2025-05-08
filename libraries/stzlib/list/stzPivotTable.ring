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
    @cRowLabelsSeparator = " / "
    
    # Cache for calculations
    @aCellCache = []
    
    # State tracking
    @bIsGenerated = FALSE

    #--

    def init(pSource)
        if isString(pSource) and lower(pSource) = :fromsource
            return
        ok
        
        # Fix: Check if pSource is already a stzTable, if not create one properly
        if isObject(pSource) and classname(pSource) = "stztable"
            @oSourceTable = pSource
        else
            # Fix: Make sure to properly initialize the source table
            @oSourceTable = new stzTable(pSource)
        ok
        
        # Initialize cache
        @aCellCache = []

    #--

    def SetRowLabels(paLabels)
        if isString(paLabels)
            @aRowLabels = [paLabels]
        else
            @aRowLabels = paLabels
        ok
        @bIsGenerated = FALSE
        return self

    def SetRowLabel(pcLabel)
        @aRowLabels = [pcLabel]
        @bIsGenerated = FALSE
        return self

    def SetColumnLabels(paLabels)
        if isString(paLabels)
            @aColLabels = [paLabels]
        else
            @aColLabels = paLabels
        ok
        @bIsGenerated = FALSE
        return self

    def SetColumnLabel(pcLabel)
        @aColLabels = [pcLabel]
        @bIsGenerated = FALSE
        return self

    def SetValues(paValues)
        if isString(paValues)
            @aValues = [paValues]
        else
            @aValues = paValues
        ok
        @bIsGenerated = FALSE
        return self

    def SetValue(pcValue)
        @aValues = [pcValue]
        @bIsGenerated = FALSE
        return self

    def SetAggregateFunction(pcFunction)
        @cAggregationFunction = upper(pcFunction)
        @bIsGenerated = FALSE
        return self

    def SetRowLabelsSeparator(pcSeparator)
        @cRowLabelsSeparator = pcSeparator
        @bIsGenerated = FALSE
        return self

    def SetShowTotals(pbShowRow, pbShowCol)
        @bShowTotalRow = pbShowRow
        @bShowTotalColumn = pbShowCol
        @bIsGenerated = FALSE
        return self

    def SetHideTotals()
        @bShowTotalRow = FALSE
        @bShowTotalColumn = FALSE
        @bIsGenerated = FALSE
        return self

    def SetTotalLabel(pcLabel)
        @cTotalLabel = pcLabel
        @bIsGenerated = FALSE
        return self

    def SetNullValue(pcValue)
        @cCellNullValue = pcValue
        @bIsGenerated = FALSE
        return self

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
        
        # Fix: Make sure the source table is properly initialized before proceeding
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
        
        return self

    #-- 
    
    # Helper function to get all unique combinations of specified fields
    def _getUniqueCombinations(paFields)
        if len(paFields) = 0
            return []
        ok
        
        if len(paFields) = 1
            # For single field, just get unique values
            # Fix: Make sure we're handling column names properly
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
    
    # FIX: Create a flat header structure for stzTable compatibility
    def _createHeaderStructure(aColCombos)
        aHeaders = []
        
        # First row includes empty cells for row labels
        aFirstRow = []
        for i = 1 to len(@aRowLabels)
            aFirstRow + ""
        next
        
        # Add column combinations as headers
        for combo in aColCombos
            # FIX: Ensure we store the column header as a string, not as an array
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
        
        # Fix: Make sure value column exists
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
        return self

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
        
        return self

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
        _showFormattedPivotTable()

def _showFormattedPivotTable()
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
            cPadded = _padRight(cCell, aColWidths[c], " ")
            cRowLine += cPadded + " "
        next
        cRowLine = @trim(cRowLine) + " | "
        # Build right part (data)
        cDataPart = ""
        for c = len(@aRowLabels)+1 to len(@aPivotData[r])
            cCell = "" + @aPivotData[r][c]
            if isNumber(@aPivotData[r][c])
                cPadded = _padLeft(cCell, aColWidths[c], " ")
            else
                cPadded = _padRight(cCell, aColWidths[c], " ")
            ok
            cDataPart += cPadded + " "
        next
        cRowLine += @trim(cDataPart)
        ? cRowLine
    next
end

def _padRight(cText, nWidth, cPadChar)
    cResult = "" + cText
    while len(cResult) < nWidth
        cResult += cPadChar
    end
    return cResult
end

def _padLeft(cText, nWidth, cPadChar)
    cResult = "" + cText
    while len(cResult) < nWidth
        cResult = cPadChar + cResult
    end
    return cResult
end

    def ShowXT(paOptions)
        if not @bIsGenerated
            Generate()
        ok
        
        @oResultTable.ShowXT(paOptions)
