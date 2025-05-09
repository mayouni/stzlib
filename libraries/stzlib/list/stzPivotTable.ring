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
    # Prepare table dimensions and data
    aDimensions = _preparePivotDimensions()
    aFormatting = _calculateColumnWidths(aDimensions)
    
    # Start building the table
    _renderTableHeaders(aDimensions, aFormatting)
    _renderDataRows(aDimensions, aFormatting)
    _renderTableFooter(aDimensions, aFormatting)
    
    see nl

# Step 1: Prepare dimensions for the pivot table
def _preparePivotDimensions()
    aDimensions = []
    
    # Basic structure
    aDimensions["nRowLabelCount"] = len(@aRowLabels)
    aDimensions["nColLabelCount"] = len(@aColLabels)
    
    # Get unique values for each column dimension
    aColDimValues = []
    for i = 1 to aDimensions["nColLabelCount"]
        aUnique = []
        for r = 2 to len(@aPivotData)
            for c = aDimensions["nRowLabelCount"] + 1 to len(@aPivotData[1])
                cHeader = @aPivotData[1][c]
                if cHeader = @cTotalLabel
                    loop
                ok
                
                aParts = split(cHeader, @cRowLabelsSeparator)
                if len(aParts) >= i and not find(aUnique, aParts[i])
                    add(aUnique, aParts[i])
                ok
            next
        next
        add(aColDimValues, aUnique)
    next
    
    aDimensions["aColDimValues"] = aColDimValues
    return aDimensions

# Step 2: Calculate widths for all table elements
def _calculateColumnWidths(aDimensions)
    aFormatting = []
    nRowLabelCount = aDimensions["nRowLabelCount"]
    aColDimValues = aDimensions["aColDimValues"]
    
    // Calculate subcolumn widths
    aSubColWidths = []
    
    // First initialize width based on header labels with padding
    for dim1 in aColDimValues[1]
        for dim2 in aColDimValues[2]
            cKey = dim1 + @cRowLabelsSeparator + dim2
            // Adding minimum spacing (2 spaces + value + 1 space)
            aSubColWidths[cKey] = max([len(dim1), len(dim2)]) + 3
        next
    next
    
    // Find max width for actual data in each column (include total row)
    for r = 2 to len(@aPivotData)
        for c = nRowLabelCount + 1 to len(@aPivotData[1])
            if @aPivotData[1][c] != @cTotalLabel
                cValue = "" + @aPivotData[r][c]
                // Need padding (2 space + value)
                nValueLen = len(cValue) + 2
                if nValueLen > aSubColWidths[@aPivotData[1][c]]
                    aSubColWidths[@aPivotData[1][c]] = nValueLen
                ok
            ok
        next
    next
    
    // Calculate row label widths with extra padding
    aRowWidths = []
    for i = 1 to nRowLabelCount
        nMaxWidth = len(@aRowLabels[i])
        for r = 2 to len(@aPivotData)
            nCellWidth = len("" + @aPivotData[r][i])
            if nCellWidth > nMaxWidth
                nMaxWidth = nCellWidth
            ok
        next
        add(aRowWidths, nMaxWidth + 3) // Add 3 spaces padding (increased from 2)
    next
    
    // Calculate width for dimension groups
    aDim1Widths = []
    for dim1 in aColDimValues[1]
        nGroupWidth = 0
        
        for dim2 in aColDimValues[2]
            cKey = dim1 + @cRowLabelsSeparator + dim2
            nGroupWidth += aSubColWidths[cKey]
        next
        
        add(aDim1Widths, nGroupWidth)
    next
    
    // Calculate total column width if needed
    nTotalColWidth = len(@cTotalLabel) + 2  // Add padding for AVERAGE
    if @bShowTotalColumn
        // Include last row (totals) in calculation
        nLastRow = len(@aPivotData)
        for r = 2 to nLastRow
            nCellWidth = len("" + @aPivotData[r][len(@aPivotData[r])]) + 2
            if nCellWidth > nTotalColWidth
                nTotalColWidth = nCellWidth
            ok
        next
    ok
    
    // Calculate row labels section width
    nRowLabelSectionWidth = 0
    for i = 1 to nRowLabelCount
        nRowLabelSectionWidth += aRowWidths[i]
        if i < nRowLabelCount
            nRowLabelSectionWidth += 3  // " | " separator
        ok
    next
    nRowLabelSectionWidth += 4  // Extra padding around section
    
    // Calculate left padding for consistent alignment
    nLeftPadding = 28  // Increased from 26 for target example
    
    aFormatting["aSubColWidths"] = aSubColWidths
    aFormatting["aRowWidths"] = aRowWidths
    aFormatting["aDim1Widths"] = aDim1Widths
    aFormatting["nTotalColWidth"] = nTotalColWidth
    aFormatting["nRowLabelSectionWidth"] = nRowLabelSectionWidth
    aFormatting["nLeftPadding"] = nLeftPadding
    
    return aFormatting

def _renderTableHeaders(aDimensions, aFormatting)
    nRowLabelCount = aDimensions["nRowLabelCount"]
    aColDimValues = aDimensions["aColDimValues"]
    aSubColWidths = aFormatting["aSubColWidths"]
    aDim1Widths = aFormatting["aDim1Widths"]
    nTotalColWidth = aFormatting["nTotalColWidth"]
    nLeftPadding = aFormatting["nLeftPadding"]
    aRowWidths = aFormatting["aRowWidths"]
    nRowLabelSectionWidth = aFormatting["nRowLabelSectionWidth"]
    
    cLeftPad = copy(" ", nLeftPadding + 2)  // Add 2 more spaces for indentation
    see nl
    
    // Top border of the table - aligned with row label end
    cTopBorder = cLeftPad + "╭"
    for i = 1 to len(aColDimValues[1])
        cTopBorder += copy("─", aDim1Widths[i])
        if i < len(aColDimValues[1])
            cTopBorder += "┬"
        ok
    next
    if @bShowTotalColumn
        cTopBorder += "╮"
    else
        cTopBorder += "╮"
    ok
    ? cTopBorder
    
    // First header row - first dimension
    cHeader1 = cLeftPad + "│"
    for i = 1 to len(aColDimValues[1])
        cDim1 = aColDimValues[1][i]
        cCell = _center(cDim1, aDim1Widths[i])
        cHeader1 += cCell + "│"
    next
    ? cHeader1
    
    // Separator after first header - using horizontal lines instead of crosses
    cSep1 = cLeftPad + "│"
    for i = 1 to len(aColDimValues[1])
        cSep = ""
        // Add horizontal lines for each subcolumn
        for j = 1 to len(aColDimValues[2])
            dim2 = aColDimValues[2][j]
            cKey = aColDimValues[1][i] + @cRowLabelsSeparator + dim2
            cSep += copy("─", aSubColWidths[cKey])
            if j < len(aColDimValues[2])
                cSep += "┬"
            ok
        next
        cSep1 += cSep
        if i < len(aColDimValues[1])
            cSep1 += "┼"
        ok
    next
    cSep1 += "│"
    ? cSep1
    
    // Second header row - second dimension
    cHeader2 = copy(" ", 3)
    for i = 1 to nRowLabelCount
        if i > 1
            cHeader2 += " | "
        ok
        cHeader2 += _center(@aRowLabels[i], aRowWidths[i])
    next
    cHeader2 += " │"
    
    // Add second dimension values with better padding
    for dim1 in aColDimValues[1]
        for dim2 in aColDimValues[2]
            cKey = dim1 + @cRowLabelsSeparator + dim2
            cHeader2 += " " + dim2 + copy(" ", aSubColWidths[cKey] - len(dim2) - 2) + "│"
        next
    next
    
    if @bShowTotalColumn
        cHeader2 += " " + @cTotalLabel + " "
    ok
    ? cHeader2
    
    // Main separator before data rows - use ┴ instead of ┼ for subcolumns
    nRowLabelSectionWidth = aFormatting["nRowLabelSectionWidth"] - 2  // Adjust width
    cMainSep = "╭" + copy("─", nRowLabelSectionWidth) + "┼"
    
    for i = 1 to len(aColDimValues[1])
        // First add ─ for the first subcol width
        dim1 = aColDimValues[1][i]
        dim2First = aColDimValues[2][1]
        cKeyFirst = dim1 + @cRowLabelsSeparator + dim2First
        cMainSep += copy("─", aSubColWidths[cKeyFirst])
        
        // Then add ┴ separator and ─ for remaining subcols
        for j = 2 to len(aColDimValues[2])
            dim2 = aColDimValues[2][j]
            cKey = dim1 + @cRowLabelsSeparator + dim2
            cMainSep += "┴" + copy("─", aSubColWidths[cKey] - 1)
        next
        
        if i < len(aColDimValues[1])
            cMainSep += "┼"
        ok
    next
    
    if @bShowTotalColumn
        cMainSep += "┼" + copy("─", nTotalColWidth)
    ok
    cMainSep += "╮"
    ? cMainSep


// Step 4: Render data rows - with adjusted department/location formatting
def _renderDataRows(aDimensions, aFormatting)
    nRowLabelCount = aDimensions["nRowLabelCount"]
    aColDimValues = aDimensions["aColDimValues"]
    aSubColWidths = aFormatting["aSubColWidths"]
    aDim1Widths = aFormatting["aDim1Widths"]
    nTotalColWidth = aFormatting["nTotalColWidth"]
    nRowLabelSectionWidth = aFormatting["nRowLabelSectionWidth"] - 2  // Adjust width
    aRowWidths = aFormatting["aRowWidths"]
    
    cCurrentDept = ""
    for r = 2 to len(@aPivotData) - 1  // Skip header and total row
        if @aPivotData[r][1] != cCurrentDept
            cCurrentDept = @aPivotData[r][1]
            if r > 2
                // Empty row between departments
                _renderEmptyRow(aDimensions, aFormatting)
            ok
            // Show department in first column
            cRowData = "│ " + _padRight(cCurrentDept, aRowWidths[1] - 1)
        else
            // Leave department column empty for subsequent rows
            cRowData = "│ " + copy(" ", aRowWidths[1] - 1)
        ok
        
        if nRowLabelCount > 1
            cRowData += " │ " + _padRight(@aPivotData[r][2], aRowWidths[2] - 1)
        ok
        
        // Pad to full row label width
        while len(cRowData) < nRowLabelSectionWidth + 1  // +1 for initial "│"
            cRowData += " "
        end
        
        cRowData += "│"
        
        // Add data cells by dimension groups
        for dim1 in aColDimValues[1]
            cGroupData = ""
            for dim2 in aColDimValues[2]
                cKey = dim1 + @cRowLabelsSeparator + dim2
                nColIndex = 0
                
                // Find the column index for this combination
                for c = nRowLabelCount + 1 to len(@aPivotData[1])
                    if @aPivotData[1][c] = cKey
                        nColIndex = c
                        exit
                    ok
                next

                // Add data with proper justification
                if nColIndex > 0
                    cValue = ""+ @aPivotData[r][nColIndex]
                    nWidth = aSubColWidths[cKey]
                    cFormattedValue = "  " + cValue + copy(" ", nWidth - len(cValue) - 2)
                    cGroupData += cFormattedValue
                else
                    cGroupData += _padRight("", aSubColWidths[cKey])
                ok
            next
            
            cRowData += cGroupData + "│"
        next
 
        // Add total if enabled
        if @bShowTotalColumn
            cValue = ""+ @aPivotData[r][len(@aPivotData[r])]
            cRowData += "  " + cValue + copy(" ", nTotalColWidth - len(cValue) - 2) + "│"
        ok
      
        ? cRowData
    next

// Helper function to render empty row with adjusted formatting
def _renderEmptyRow(aDimensions, aFormatting)
    aColDimValues = aDimensions["aColDimValues"]
    aDim1Widths = aFormatting["aDim1Widths"]
    nTotalColWidth = aFormatting["nTotalColWidth"]
    nRowLabelSectionWidth = aFormatting["nRowLabelSectionWidth"] - 2  // Adjust width
    
    cEmptyRow = "│" + copy(" ", nRowLabelSectionWidth) + "│"
    
    nLenDim = len(aDim1Widths)
    for q = 1 to nLenDim
        cEmptyData = copy(" ", aDim1Widths[q])
        cEmptyRow += cEmptyData + "│"
    next
    
    if @bShowTotalColumn
        cEmptyRow += copy(" ", nTotalColWidth) + "│"
    ok
    ? cEmptyRow

// Step 5: Render table footer with adjusted formatting
def _renderTableFooter(aDimensions, aFormatting)
    aColDimValues = aDimensions["aColDimValues"]
    aDim1Widths = aFormatting["aDim1Widths"]
    nTotalColWidth = aFormatting["nTotalColWidth"]
    nRowLabelSectionWidth = aFormatting["nRowLabelSectionWidth"] - 2  // Adjust width
    nLeftPadding = aFormatting["nLeftPadding"]
    aSubColWidths = aFormatting["aSubColWidths"]
    
    // Bottom border before total row
    cBottomBorder = "╰" + copy("─", nRowLabelSectionWidth) + "┴"
    
    for i = 1 to len(aColDimValues[1])
        cBottomBorder += copy("─", aDim1Widths[i])
        if i < len(aColDimValues[1])
            cBottomBorder += "┴"
        ok
    next
    
    if @bShowTotalColumn
        cBottomBorder += "┴" + copy("─", nTotalColWidth)
    ok
    cBottomBorder += "╯"
    ? cBottomBorder
    
    // Total row if enabled
    if @bShowTotalRow
        _renderTotalRow(aDimensions, aFormatting)
    ok
/*
// Helper function to render total row with adjusted padding
def _renderTotalRow(aDimensions, aFormatting)
    aColDimValues = aDimensions["aColDimValues"]
    aSubColWidths = aFormatting["aSubColWidths"]
    nTotalColWidth = aFormatting["nTotalColWidth"]
    nLeftPadding = aFormatting["nLeftPadding"]
    
    nLastRow = len(@aPivotData)
    // Add extra padding before AVERAGE text
    cTotalRow = copy(" ", nLeftPadding - len(@cTotalLabel) + 1) + @cTotalLabel + " │"
    
    // Process column groups
    for dim1 in aColDimValues[1]
        cGroupTotal = ""
        for dim2 in aColDimValues[2]
            cKey = dim1 + @cRowLabelsSeparator + dim2
            nColIndex = 0
            
            // Find the column index for this combination
            for c = aDimensions["nRowLabelCount"] + 1 to len(@aPivotData[1])
                if @aPivotData[1][c] = cKey
                    nColIndex = c
                    exit
                ok
            next
            
            if nColIndex > 0
                cValue = ""+ @aPivotData[nLastRow][nColIndex]
                cGroupTotal += " " + cValue + copy(" ", aSubColWidths[cKey] - len(cValue) - 1)
            else
                cGroupTotal += _padRight("", aSubColWidths[cKey])
            ok
        next
        cTotalRow += cGroupTotal + "│"
    next
    
    // Add grand total if enabled
 //   if @bShowTotalColumn
//        cTotalRow += " " + @aPivotData[nLastRow][len(@aPivotData[nLastRow])] + copy(" ", nTotalColWidth - len(@aPivotData[nLastRow][len(@aPivotData[nLastRow])]) - 1) + "│"
//    ok
    
        if @bShowTotalColumn
            cValue = ""+ @aPivotData[r][len(@aPivotData[r])]
            cRowData += "  " + cValue + copy(" ", nTotalColWidth - len(cValue) - 2) + "│"
        ok
    ? cTotalRow
*/

/*
# Step 2: Calculate widths for all table elements
def _calculateColumnWidths(aDimensions)
    aFormatting = []
    nRowLabelCount = aDimensions["nRowLabelCount"]
    aColDimValues = aDimensions["aColDimValues"]
    
    # Calculate subcolumn widths
    aSubColWidths = []
    
    # First initialize width based on header labels with padding
    for dim1 in aColDimValues[1]
        for dim2 in aColDimValues[2]
            cKey = dim1 + @cRowLabelsSeparator + dim2
            # Adding minimum spacing (2 spaces + value + 1 space)
            aSubColWidths[cKey] = max([len(dim1), len(dim2)]) + 3
        next
    next
    
    # Find max width for actual data in each column (include total row)
    for r = 2 to len(@aPivotData)
        for c = nRowLabelCount + 1 to len(@aPivotData[1])
            if @aPivotData[1][c] != @cTotalLabel
                cValue = "" + @aPivotData[r][c]
                # Need padding (2 space + value)
                nValueLen = len(cValue) + 2
                if nValueLen > aSubColWidths[@aPivotData[1][c]]
                    aSubColWidths[@aPivotData[1][c]] = nValueLen
                ok
            ok
        next
    next
    
    # Calculate row label widths
    aRowWidths = []
    for i = 1 to nRowLabelCount
        nMaxWidth = len(@aRowLabels[i])
        for r = 2 to len(@aPivotData)
            nCellWidth = len("" + @aPivotData[r][i])
            if nCellWidth > nMaxWidth
                nMaxWidth = nCellWidth
            ok
        next
        add(aRowWidths, nMaxWidth + 2) # Add 2 spaces padding (1 on each side)
    next
    
    # Calculate width for dimension groups
    aDim1Widths = []
    for dim1 in aColDimValues[1]
        nGroupWidth = 0
        
        for dim2 in aColDimValues[2]
            cKey = dim1 + @cRowLabelsSeparator + dim2
            nGroupWidth += aSubColWidths[cKey]
        next
        
        add(aDim1Widths, nGroupWidth)
    next
    
    # Calculate total column width if needed
    nTotalColWidth = len(@cTotalLabel) + 2  # Add padding for AVERAGE
    if @bShowTotalColumn
        # Include last row (totals) in calculation
        nLastRow = len(@aPivotData)
        for r = 2 to nLastRow
            nCellWidth = len("" + @aPivotData[r][len(@aPivotData[r])]) + 2
            if nCellWidth > nTotalColWidth
                nTotalColWidth = nCellWidth
            ok
        next
    ok
    
    # Calculate row labels section width
    nRowLabelSectionWidth = 0
    for i = 1 to nRowLabelCount
        nRowLabelSectionWidth += aRowWidths[i]
        if i < nRowLabelCount
            nRowLabelSectionWidth += 3  # " | " separator
        ok
    next
    nRowLabelSectionWidth += 4  # Extra padding around section
    
    # Calculate left padding for consistent alignment
    nLeftPadding = 26  # Adjusted for target example
    
    aFormatting["aSubColWidths"] = aSubColWidths
    aFormatting["aRowWidths"] = aRowWidths
    aFormatting["aDim1Widths"] = aDim1Widths
    aFormatting["nTotalColWidth"] = nTotalColWidth
    aFormatting["nRowLabelSectionWidth"] = nRowLabelSectionWidth
    aFormatting["nLeftPadding"] = nLeftPadding
    
    return aFormatting


# Step 3: Render table headers
def _renderTableHeaders(aDimensions, aFormatting)
    nRowLabelCount = aDimensions["nRowLabelCount"]
    aColDimValues = aDimensions["aColDimValues"]
    aSubColWidths = aFormatting["aSubColWidths"]
    aDim1Widths = aFormatting["aDim1Widths"]
    nTotalColWidth = aFormatting["nTotalColWidth"]
    nLeftPadding = aFormatting["nLeftPadding"]
    aRowWidths = aFormatting["aRowWidths"]
    nRowLabelSectionWidth = aFormatting["nRowLabelSectionWidth"]
    
    cLeftPad = copy(" ", nLeftPadding)
    see nl
    
    # Top border of the table - aligned with row label end
    cTopBorder = cLeftPad + "╭"
    for i = 1 to len(aColDimValues[1])
        cTopBorder += copy("─", aDim1Widths[i])
        if i < len(aColDimValues[1])
            cTopBorder += "┬"
        ok
    next
    if @bShowTotalColumn
        cTopBorder += "╮"
    else
        cTopBorder += "╮"
    ok
    ? cTopBorder
    
    # First header row - first dimension
    cHeader1 = cLeftPad + "│"
    for i = 1 to len(aColDimValues[1])
        cDim1 = aColDimValues[1][i]
        cCell = _center(cDim1, aDim1Widths[i])
        cHeader1 += cCell + "│"
    next
    ? cHeader1
    
    # Separator after first header
    cSep1 = cLeftPad + "├"
    for i = 1 to len(aColDimValues[1])
        cSep = ""
        # Add horizontal lines for each subcolumn
        for j = 1 to len(aColDimValues[2])
            dim2 = aColDimValues[2][j]
            cKey = aColDimValues[1][i] + @cRowLabelsSeparator + dim2
            cSep += copy("─", aSubColWidths[cKey])
            if j < len(aColDimValues[2])
                cSep += "┬"
            ok
        next
        cSep1 += cSep
        if i < len(aColDimValues[1])
            cSep1 += "┼"
        ok
    next
    cSep1 += "│"
    ? cSep1
    
    # Second header row - second dimension
    cHeader2 = copy(" ", 3)
    for i = 1 to nRowLabelCount
        if i > 1
            cHeader2 += " | "
        ok
        cHeader2 += _center(@aRowLabels[i], aRowWidths[i])
    next
    cHeader2 += " │"
    
    # Add second dimension values
    for dim1 in aColDimValues[1]
        for dim2 in aColDimValues[2]
            cKey = dim1 + @cRowLabelsSeparator + dim2
            cHeader2 += " " + dim2 + " " + copy(" ", aSubColWidths[cKey] - len(dim2) - 2) + "│"
        next
    next
    
    if @bShowTotalColumn
        cHeader2 += " " + @cTotalLabel + " "
    ok
    ? cHeader2
    
    # Main separator before data rows
    nRowLabelSectionWidth = aFormatting["nRowLabelSectionWidth"]
    cMainSep = "╭" + copy("─", nRowLabelSectionWidth) + "┼"
    
    for i = 1 to len(aColDimValues[1])
        dim1Group = copy("─", aDim1Widths[i])
        cMainSep += dim1Group
        
        if i < len(aColDimValues[1])
            cMainSep += "┼"
        ok
    next
    
    if @bShowTotalColumn
        cMainSep += "┼" + copy("─", nTotalColWidth)
    ok
    cMainSep += "╮"
    ? cMainSep

# Step 4: Render data rows
def _renderDataRows(aDimensions, aFormatting)
    nRowLabelCount = aDimensions["nRowLabelCount"]
    aColDimValues = aDimensions["aColDimValues"]
    aSubColWidths = aFormatting["aSubColWidths"]
    aDim1Widths = aFormatting["aDim1Widths"]
    nTotalColWidth = aFormatting["nTotalColWidth"]
    nRowLabelSectionWidth = aFormatting["nRowLabelSectionWidth"]
    aRowWidths = aFormatting["aRowWidths"]
    
    cCurrentDept = ""
    for r = 2 to len(@aPivotData) - 1  # Skip header and total row
        if @aPivotData[r][1] != cCurrentDept
            cCurrentDept = @aPivotData[r][1]
            if r > 2
                # Empty row between departments
                _renderEmptyRow(aDimensions, aFormatting)
            ok
        ok
        
        # Row data
        cRowData = "│ " + _padRight(cCurrentDept, aRowWidths[1] - 1)
        
        if nRowLabelCount > 1
            cRowData += " │ " + _padRight(@aPivotData[r][2], aRowWidths[2] - 1)
        ok
        
        # Pad to full row label width
        while len(cRowData) < nRowLabelSectionWidth + 1  # +1 for initial "│"
            cRowData += " "
        end
        
        cRowData += "│"
        
        # Add data cells by dimension groups
        for dim1 in aColDimValues[1]
            cGroupData = ""
            for dim2 in aColDimValues[2]
                cKey = dim1 + @cRowLabelsSeparator + dim2
                nColIndex = 0
                
                # Find the column index for this combination
                for c = nRowLabelCount + 1 to len(@aPivotData[1])
                    if @aPivotData[1][c] = cKey
                        nColIndex = c
                        exit
                    ok
                next

                # Add data with proper justification
                if nColIndex > 0
                    cValue = ""+ @aPivotData[r][nColIndex]

																				nLen = len(aSubColWidths)
																				for v = 1 to nLen
																						if aSubColWidths[v][1] = cKey
																							nPos = aSubColWidths[v][2]
																				  	exit
																				  ok
																				next

                    cFormattedValue = "  " + cValue + copy(" ", nPos - len(cValue) - 2)
                    cGroupData += cFormattedValue
                else
                    cGroupData += _padRight("", aSubColWidths[cKey])
                ok
            next
            
            cRowData += cGroupData + "│"
        next
 
        # Add total if enabled
        if @bShowTotalColumn
            cValue = ""+ @aPivotData[r][len(@aPivotData[r])]
            cRowData += "  " + cValue + copy(" ", nTotalColWidth - len(cValue) - 2) + "│"
        ok
      
        ? cRowData
    next

# Helper function to render empty row
def _renderEmptyRow(aDimensions, aFormatting)
    aColDimValues = aDimensions["aColDimValues"]
    aDim1Widths = aFormatting["aDim1Widths"]
    nTotalColWidth = aFormatting["nTotalColWidth"]
    nRowLabelSectionWidth = aFormatting["nRowLabelSectionWidth"]
    
    cEmptyRow = "│" + _padRight("", nRowLabelSectionWidth) + "│"
    
    nLenDim = len(aDim1Widths)
    for q = 1 to nLenDim
        cEmptyData = _padRight("", aDim1Widths[q])
        cEmptyRow += cEmptyData + "│"
    next
    
    if @bShowTotalColumn
        cEmptyRow += _padRight("", nTotalColWidth) + "│"
    ok
    ? cEmptyRow

# Step 5: Render table footer
def _renderTableFooter(aDimensions, aFormatting)
    aColDimValues = aDimensions["aColDimValues"]
    aDim1Widths = aFormatting["aDim1Widths"]
    nTotalColWidth = aFormatting["nTotalColWidth"]
    nRowLabelSectionWidth = aFormatting["nRowLabelSectionWidth"]
    nLeftPadding = aFormatting["nLeftPadding"]
    aSubColWidths = aFormatting["aSubColWidths"]
    
    # Bottom border before total row
    cBottomBorder = "╰" + copy("─", nRowLabelSectionWidth) + "┴"
    
    for i = 1 to len(aColDimValues[1])
        cBottomBorder += copy("─", aDim1Widths[i])
        if i < len(aColDimValues[1])
            cBottomBorder += "┴"
        ok
    next
    
    if @bShowTotalColumn
        cBottomBorder += "┴" + copy("─", nTotalColWidth)
    ok
    cBottomBorder += "╯"
    ? cBottomBorder
    
    # Total row if enabled
    if @bShowTotalRow
        _renderTotalRow(aDimensions, aFormatting)
    ok
*/
# Helper function to render total row
def _renderTotalRow(aDimensions, aFormatting)
    aColDimValues = aDimensions["aColDimValues"]
    aSubColWidths = aFormatting["aSubColWidths"]
    nTotalColWidth = aFormatting["nTotalColWidth"]
    nLeftPadding = aFormatting["nLeftPadding"]
    
    nLastRow = len(@aPivotData)
    cTotalRow = copy(" ", nLeftPadding - len(@cTotalLabel) - 3) + @cTotalLabel + " │"
    
    # Process column groups
    for dim1 in aColDimValues[1]
        cGroupTotal = ""
        for dim2 in aColDimValues[2]
            cKey = dim1 + @cRowLabelsSeparator + dim2
            nColIndex = 0
            
            # Find the column index for this combination
            for c = aDimensions["nRowLabelCount"] + 1 to len(@aPivotData[1])
                if @aPivotData[1][c] = cKey
                    nColIndex = c
                    exit
                ok
            next
            
            if nColIndex > 0
                cValue = ""+ @aPivotData[nLastRow][nColIndex]
                cGroupTotal += " " + cValue + copy(" ", aSubColWidths[cKey] - len(cValue) - 2) + " "
            else
                cGroupTotal += _padRight("", aSubColWidths[cKey])
            ok
        next
        cTotalRow += cGroupTotal + "│"
    next
    
    # Add grand total if enabled
    if @bShowTotalColumn
        cTotalRow += _padRight(" " + @aPivotData[nLastRow][len(@aPivotData[nLastRow])], nTotalColWidth) + "│"
    ok
    
    ? cTotalRow

def _center(cText, nWidth)
    nTextLen = len(cText)
    if nTextLen >= nWidth
        return cText
    ok
    
    nLeftPad = floor((nWidth - nTextLen) / 2)
    nRightPad = nWidth - nTextLen - nLeftPad
    
    return copy(" ", nLeftPad) + cText + copy(" ", nRightPad)
end

def _padRight(cText, nWidth)
    cResult = "" + cText
    while len(cResult) < nWidth
        cResult += " "
    end
    return cResult
end

def _padLeft(cText, nWidth)
    cResult = "" + cText
    while len(cResult) < nWidth
        cResult = " " + cResult
    end
    return cResult
end

def _padCenter(cText, nWidth)
    return _center(cText, nWidth)
end

    def ShowXT(paOptions)
        if not @bIsGenerated
            Generate()
        ok
        
        @oResultTable.ShowXT(paOptions)
