load "../stzmax.ring"

pr()

_aPivotData = [
    [
        "",
        "",
        "junior_female",
        "senior_male",
        "senior_female",
        "junior_male",
        "average"
    ],
    [
        "Sales",
        "New York",
        46000,
        75000,
        76000,
        "",
        197000
    ],
    [
        "Sales",
        "Chicago",
        43000,
        72000,
        73000,
        42000,
        230000
    ],
    [
        "IT",
        "New York",
        53000,
        85000,
        86000,
        52000,
        276000
    ],
    [
        "IT",
        "Chicago",
        51000,
        82000,
        83000,
        50000,
        266000
    ],
    [
        "HR",
        "New York",
        43000,
        68000,
        69000,
        42000,
        222000
    ],
    [
        "HR",
        "Chicago",
        41000,
        65000,
        66000,
        40000,
        212000
    ],
    [
        "average",
        "",
        277000,
        447000,
        453000,
        226000,
        1403000
    ]
]
_aRowDims = [ "department", "location" ]
_aColDims = [ "experience", "gender" ]
_cTotalLabel = "average"

? DisplayPivotTable(_aPivotData, _aRowDims, _aColDims, _cTotalLabel)

pf()

func DisplayPivotTable(aPivotData, aRowDims, aColDims, cTotalLabel)
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
            if HasKey(aDataColWidths, key)
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
            if HasKey(aDataColWidths, key)
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
            if HasKey(aDataColWidths, key)
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
            if HasKey(aDataColWidths, key)
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
                    if HasKey(aDataColWidths, key)
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
            if HasKey(aDataColWidths, key)
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

    return StzStringQ(trim(cOutput)).LastCharRemoved()

# Helper Functions

func StrFill(nCount, cChar)
    cResult = ""
    for i = 1 to nCount
        cResult += cChar
    next
    return cResult
