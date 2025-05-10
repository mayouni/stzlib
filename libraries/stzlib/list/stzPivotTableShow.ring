# Dynamic Pivot Table Display System
# This system provides a configurable and automatically adjusting
# display framework for pivot tables with interdependent dimensions

# 1. CORE CONFIGURATION CLASS
# ===========================

Class TableDisplayConfig
    
    # Container for all configuration and dynamic calculations
    
    # Basic display settings
    aSettings = [
        :MinCellWidth         = 5,    # Minimum width for any cell
        :MaxCellWidth         = 20,   # Maximum width for data cells
        :MaxHeaderWidth       = 30,   # Maximum width for header cells
        :DefaultPadding       = 1,    # Default cell padding (both sides)
        :CellGrowthRatio      = 1.2,  # How much larger than content cells should be
        :RowLabelGrowthRatio  = 1.5,  # How much extra space for row labels vs content
        :TotalLabelOffset     = 5,    # Offset for total labels
        :EmptyRowHeight       = 1,    # Height of empty separator rows
        :HeaderTopPadding     = 1,    # Space before headers
        :OuterPadding         = 1,    # Padding outside table edges
        :MaxTableWidth        = 120,  # Maximum total table width (0 = no limit)
        :AutoAdjustWidths     = true, # Whether to dynamically adjust widths
        :BalanceColumns       = true, # Whether to balance column widths
        :ExpandToContent      = true  # Whether cells expand to fit content
    ]
    
    # Content-specific measurements (calculated dynamically)
    aContentDimensions = [
        :RowLabels         = [],   # Width measurements for row labels
        :ColumnDimValues   = [],   # Lists of dimension values for columns
        :ColumnHeaders     = [],   # Width measurements for column headers
        :DataCells         = [],   # Width measurements for data cells
        :TotalLabels       = [],   # Width measurements for total labels
        :TotalCells        = []    # Width measurements for total cells
    ]
    
    # Final calculated dimensions (used for rendering)
    aCalculatedLayout = [
        :RowLabelWidths      = [],   # Final widths for row label columns
        :DataColumnWidths    = [],   # Final widths for data columns (by dimension)
        :TotalColumnWidth    = 0,    # Final width for total column
        :RowLabelSectionWidth = 0,   # Total width of row label section
        :TableWidth          = 0,    # Total width of entire table
        :LeftPadding         = 0,    # Left padding for entire table
        :HeaderRowHeight     = 0,    # Height of header rows
        :BorderWidthOffsets  = []    # Offsets for border positioning
    ]
    
    # Separators and decorators
    aDecorators = [
        :RowLabelSeparator   = " | ", # Separator between row labels
        :CellSeparator       = " │ ", # Separator between cells
        :BorderChars = [
            :TopLeft       = "╭",
            :TopRight      = "╮",
            :BottomLeft    = "╰", 
            :BottomRight   = "╯",
            :Horizontal    = "─",
            :Vertical      = "│",
            :Cross         = "┼",
            :TeeDown       = "┬",
            :TeeUp         = "┴",
            :TeeRight      = "├",
            :TeeLeft       = "┤"
        ]
    ]
    
    # Data/formatting references
    aPivotData = []        # Reference to pivot table data
    aRowLabels = []        # Row dimension labels
    aColLabels = []        # Column dimension labels
    cTotalLabel = ""       # Label used for totals
    bShowTotalRow = true   # Whether to show totals row
    bShowTotalColumn = true # Whether to show totals column
    
    # Initialize with pivot table data
    func init(aPivotTable, aRowDims, aColDims, cTotalLbl)
        aPivotData = aPivotTable
        aRowLabels = aRowDims
        aColLabels = aColDims
        cTotalLabel = cTotalLbl
        
        # Perform initial measurements
        MeasureContentDimensions()
        CalculateLayout()
        return self
    
    # 1. Measure all content to determine natural sizes
    func MeasureContentDimensions()
        aContentDimensions[:RowLabels] = []
        aContentDimensions[:ColumnDimValues] = []
        aContentDimensions[:ColumnHeaders] = []
        aContentDimensions[:DataCells] = []
        aContentDimensions[:TotalLabels] = []
        aContentDimensions[:TotalCells] = []
        
        # 1.1 Analyze row labels
        for i = 1 to len(aRowLabels)
            cLabel = aRowLabels[i]
            nWidth = len(cLabel)
            
            # Find max width of actual data in this column
            nMaxDataWidth = nWidth
            for r = 2 to len(aPivotData)
                nValueWidth = len(aPivotData[r][i])
                if nValueWidth > nMaxDataWidth
                    nMaxDataWidth = nValueWidth
                ok
            next
            
            # Store both label width and max content width
            add(aContentDimensions[:RowLabels], [
                :label = cLabel,
                :labelWidth = nWidth,
                :maxContentWidth = nMaxDataWidth,
                :finalWidth = 0  # Will be calculated later
            ])
        next
        
        # 1.2 Extract and measure column dimension values
        aColumnValues = GetUniqueColumnDimensionValues()
        aContentDimensions[:ColumnDimValues] = aColumnValues
        
        # 1.3 Measure column headers
        aColumnHeaders = []
        for i = 1 to len(aColLabels)
            cLabel = aColLabels[i]
            nWidth = len(cLabel)
            
            # For each value in this dimension, measure width
            for cValue in aColumnValues[i]
                nValueWidth = len(cValue)
                if nValueWidth > nWidth
                    nWidth = nValueWidth
                ok
            next
            
            add(aColumnHeaders, [
                :label = cLabel,
                :width = nWidth
            ])
        next
        aContentDimensions[:ColumnHeaders] = aColumnHeaders
        
        # 1.4 Measure data cells
        # Create a map to store maximum width for each column combination
        aDataWidths = []
        
        # Process all data rows
        for r = 2 to len(aPivotData) - 1  # Skip header and total rows
            for c = len(aRowLabels) + 1 to len(aPivotData[1]) - 1  # Skip row labels and total column
                cHeader = aPivotData[1][c]
                if cHeader = cTotalLabel  # Skip total columns
                    loop
                ok
                
                # Get the cell value and measure it
                cValue = "" + aPivotData[r][c]
                nWidth = len(cValue)
                
                # Store in our map with the header as key
                if nWidth > 0  # Only store non-empty cells
                    if !@IsHashList(aDataWidths[cHeader])
                        aDataWidths[cHeader] = 0
                    ok
                    
                    if nWidth > aDataWidths[cHeader]
                        aDataWidths[cHeader] = nWidth
                    ok
                ok
            next
        next
        
        aContentDimensions[:DataCells] = aDataWidths
        
        # 1.5 Measure total labels and cells
        nTotalLabelWidth = len(cTotalLabel)
        aContentDimensions[:TotalLabels] = [
            :label = cTotalLabel,
            :width = nTotalLabelWidth
        ]
        
        # Measure total cells (rightmost column)
        nMaxTotalWidth = 0
        if bShowTotalColumn
            for r = 2 to len(aPivotData)
                nCol = len(aPivotData[r])
                cValue = "" + aPivotData[r][nCol]
                nWidth = len(cValue)
                
                if nWidth > nMaxTotalWidth
                    nMaxTotalWidth = nWidth
                ok
            next
        ok
        
        aContentDimensions[:TotalCells] = [
            :width = nMaxTotalWidth
        ]
    
    # Helper: Get unique values for each column dimension
    func GetUniqueColumnDimensionValues()
        aResult = []
        nColLabelCount = len(aColLabels)
        
        # Initialize arrays for each dimension
        for i = 1 to nColLabelCount
            add(aResult, [])
        next
        
        # Extract unique values for each column dimension
        for i = 1 to nColLabelCount
            aUnique = []
            for r = 2 to len(aPivotData)
                for c = len(aRowLabels) + 1 to len(aPivotData[1])
                    cHeader = aPivotData[1][c]
                    if cHeader = cTotalLabel
                        loop
                    ok
                    
                    aParts = split(cHeader, "|")
                    if len(aParts) >= i and not find(aUnique, aParts[i])
                        add(aUnique, aParts[i])
                    ok
                next
            next
            aResult[i] = aUnique
        next
        
        return aResult
    
    # 2. Calculate final layout dimensions based on content and settings
    func CalculateLayout()
        # 2.1 Calculate row label widths
        aFinalRowWidths = []
        nRowLabelSectionWidth = 0
        
        for i = 1 to len(aContentDimensions[:RowLabels])
            item = aContentDimensions[:RowLabels][i]
            
            # Calculate width with growth ratio and constraints
            nWidth = max([ item[:labelWidth], item[:maxContentWidth] ])
            nWidth = ceil(nWidth * aSettings[:RowLabelGrowthRatio])
            
            # Apply min/max constraints
            nWidth = max([ nWidth, aSettings[:MinCellWidth] ])
            nWidth = min([ nWidth, aSettings[:MaxHeaderWidth] ])
            
            # Update item's final width
            aContentDimensions[:RowLabels][i][:finalWidth] = nWidth
            add(aFinalRowWidths, nWidth)
            
            # Add to section width (including separators)
            nRowLabelSectionWidth += nWidth
            if i < len(aContentDimensions[:RowLabels])
                nRowLabelSectionWidth += len(aDecorators[:RowLabelSeparator])
            ok
        next
        
        aCalculatedLayout[:RowLabelWidths] = aFinalRowWidths
        aCalculatedLayout[:RowLabelSectionWidth] = nRowLabelSectionWidth
        
        # 2.2 Calculate data column widths based on dimension combinations
        aFinalDataWidths = []
        aDimWidthSums = []  # Width sums for each primary dimension group
        
        # Get dimension values
        aColDimValues = aContentDimensions[:ColumnDimValues]
        
        # Create a map for each dimension combination
        for dim1 in aColDimValues[1]
            nGroupWidth = 0
            
            for dim2 in aColDimValues[2]
                cKey = dim1 + "|" + dim2
                
                # Get measured content width or minimum width
                nWidth = aSettings[:MinCellWidth]
                if @IsHashList(aContentDimensions[:DataCells][cKey])
                    nWidth = aContentDimensions[:DataCells][cKey]
                ok
                
                # Apply growth ratio and constraints
                nWidth = ceil(nWidth * aSettings[:CellGrowthRatio])
                nWidth = max([ nWidth, aSettings[:MinCellWidth] ])
                nWidth = min([ nWidth, aSettings[:MaxCellWidth] ])
                
                # Add padding on both sides
                nPaddedWidth = nWidth + (2 * aSettings[:DefaultPadding])
                
                # Store the final width
                if !@IsHashList(aFinalDataWidths[cKey])
                    aFinalDataWidths[cKey] = nPaddedWidth
                else
                    aFinalDataWidths[cKey] = nPaddedWidth
                ok
                
                nGroupWidth += nPaddedWidth
            next
            
            # Account for separators within the group
            if len(aColDimValues[2]) > 1
                nGroupWidth += (len(aColDimValues[2]) - 1)
            ok
            
            add(aDimWidthSums, nGroupWidth)
        next
        
        aCalculatedLayout[:DataColumnWidths] = aFinalDataWidths
        
        # 2.3 Calculate total column width
        nTotalColumnWidth = 0
        if bShowTotalColumn
            nWidth = max([
                aContentDimensions[:TotalLabels][:width],
                aContentDimensions[:TotalCells][:width]
            ])
            
            # Apply growth and constraints
            nWidth = ceil(nWidth * aSettings[:CellGrowthRatio])
            nWidth = max([ nWidth, aSettings[:MinCellWidth] ])
            nWidth = min([ nWidth, aSettings[:MaxCellWidth] ])
            
            # Add padding
            nTotalColumnWidth = nWidth + (2 * aSettings[:DefaultPadding])
        ok
        
        aCalculatedLayout[:TotalColumnWidth] = nTotalColumnWidth
        
        # 2.4 Calculate overall table width and adjustments
        nTableWidth = nRowLabelSectionWidth
        
        # Add width for each dimension group
        for i = 1 to len(aDimWidthSums)
            nTableWidth += aDimWidthSums[i]
            if i < len(aDimWidthSums)
                nTableWidth += 1  # Separator between dimension groups
            ok
        next
        
        # Add total column if enabled
        if bShowTotalColumn
            nTableWidth += nTotalColumnWidth + 1  # Include separator
        ok
        
        # Add outer border characters
        nTableWidth += 2  # Left and right borders
        
        aCalculatedLayout[:TableWidth] = nTableWidth
        
        # Calculate left padding
        nLeftPadding = aSettings[:OuterPadding]
        if aSettings[:MaxTableWidth] > 0 and nTableWidth < aSettings[:MaxTableWidth]
            nLeftPadding = floor((aSettings[:MaxTableWidth] - nTableWidth) / 2)
        ok
        
        aCalculatedLayout[:LeftPadding] = nLeftPadding
        
        # 2.5 Calculate border width offsets for alignment
        # This helps with complex border rendering
        aBorderOffsets = []
        nCurrentOffset = 0
        
        # Add row labels section offset
        nCurrentOffset += nRowLabelSectionWidth + 1  # +1 for the initial border character
        add(aBorderOffsets, nCurrentOffset)
        
        # Add each dimension group offset
        for i = 1 to len(aDimWidthSums)
            nCurrentOffset += aDimWidthSums[i] + 1  # +1 for separator
            add(aBorderOffsets, nCurrentOffset)
        next
        
        aCalculatedLayout[:BorderWidthOffsets] = aBorderOffsets
    
    # Helper: Get the overall width for a specific column dimension group
    func GetDimensionGroupWidth(nDimIndex)
        aColDimValues = aContentDimensions[:ColumnDimValues]
        nGroupWidth = 0
        
        for dim1 in aColDimValues[1]
            for dim2 in aColDimValues[2]
                cKey = dim1 + "|" + dim2
                nGroupWidth += aFinalDataWidths[cKey]
            next
        next
        
        return nGroupWidth
    
    # Helper: Get actual cell width for a specific dimension combination
    func GetCellWidth(dim1, dim2)
        cKey = dim1 + "|" + dim2
        if @IsHashList(aCalculatedLayout[:DataColumnWidths][cKey])
            return aCalculatedLayout[:DataColumnWidths][cKey]
        ok
        
        return aSettings[:MinCellWidth]  # Default fallback
    
    # Apply a custom setting
    func SetSetting(cSetting, value)
        aSettings[cSetting] = value
        # Recalculate on setting change
        CalculateLayout()
        return self
    
    # Get a specific layout measurement
    func GetLayoutValue(cKey)
        if @IsHashList(aCalculatedLayout[cKey])
            return aCalculatedLayout[cKey]
        ok
        return null
    
    # Update all calculations based on current data
    func Recalculate()
        MeasureContentDimensions()
        CalculateLayout()
        return self
    
    # Debug function to show all calculated dimensions
    func DebugLayout()
        see "=== TABLE LAYOUT DEBUG ===" + nl
        see "Row Label Section Width: " + aCalculatedLayout[:RowLabelSectionWidth] + nl
        see "Row Label Widths: " + nl
        for i = 1 to len(aCalculatedLayout[:RowLabelWidths])
            see "  " + aRowLabels[i] + ": " + aCalculatedLayout[:RowLabelWidths][i] + nl
        next
        
        see "Data Column Widths: " + nl
        aColDimValues = aContentDimensions[:ColumnDimValues]
        for dim1 in aColDimValues[1]
            for dim2 in aColDimValues[2]
                cKey = dim1 + "|" + dim2
                if @IsHashList(aCalculatedLayout[:DataColumnWidths][cKey])
                    see "  " + cKey + ": " + aCalculatedLayout[:DataColumnWidths][cKey] + nl
                ok
            next
        next
        
        see "Total Column Width: " + aCalculatedLayout[:TotalColumnWidth] + nl
        see "Total Table Width: " + aCalculatedLayout[:TableWidth] + nl
        see "Left Padding: " + aCalculatedLayout[:LeftPadding] + nl
        see "=========================" + nl
    
end  # End of TableDisplayConfig class

# 2. RENDERING ENGINE
# ==================

Class TableRenderer
    
    # Configuration object reference
    oConfig = null
    
    # Initialize with configuration object
    func init(oTableConfig)
        oConfig = oTableConfig
        return self
    
    # Render the complete table
    func RenderTable()
        RenderTableHeaders()
        RenderDataRows()
        RenderTableFooter()
        return self
    
    # 1. Render table headers
    func RenderTableHeaders()
        # Extract needed values from config
        aColDimValues = oConfig.aContentDimensions[:ColumnDimValues]
        aRowWidths = oConfig.aCalculatedLayout[:RowLabelWidths]
        aDataColumnWidths = oConfig.aCalculatedLayout[:DataColumnWidths]
        nTotalColWidth = oConfig.aCalculatedLayout[:TotalColumnWidth]
        nLeftPadding = oConfig.aCalculatedLayout[:LeftPadding]
        nRowLabelSectionWidth = oConfig.aCalculatedLayout[:RowLabelSectionWidth]
        aBorderChars = oConfig.aDecorators[:BorderChars]
        
        # Add top padding
        see nl + copy(nl, oConfig.aSettings[:HeaderTopPadding] - 1)
        
        # 1.1 Top border
        cLeftPad = copy(" ", nLeftPadding)
        cTopBorder = cLeftPad + aBorderChars[:TopLeft]
        
        # Add horizontal lines for each column group
        for i = 1 to len(aColDimValues[1])
            # Calculate width for this dimension group
            nGroupWidth = 0
            for dim2 in aColDimValues[2]
                cKey = aColDimValues[1][i] + "|" + dim2
                if @IsHashList(aDataColumnWidths[cKey])
                    nGroupWidth += aDataColumnWidths[cKey]
                else
                    nGroupWidth += oConfig.aSettings[:MinCellWidth]
                ok
            next
            
            # Add separator spaces
            if len(aColDimValues[2]) > 1
                nGroupWidth += len(aColDimValues[2]) - 1
            ok
            
            cTopBorder += copy(aBorderChars[:Horizontal], nGroupWidth)
            
            if i < len(aColDimValues[1])
                cTopBorder += aBorderChars[:TeeDown]
            ok
        next
        
        cTopBorder += aBorderChars[:TopRight]
        ? cTopBorder
        
        # 1.2 First header row - first dimension
        cHeader1 = cLeftPad + aBorderChars[:Vertical]
        
        for i = 1 to len(aColDimValues[1])
            dim1 = aColDimValues[1][i]
            
            # Calculate width for this dimension group
            nGroupWidth = 0
            for dim2 in aColDimValues[2]
                cKey = dim1 + "|" + dim2
                if @IsHashList(aDataColumnWidths[cKey])
                    nGroupWidth += aDataColumnWidths[cKey]
                else
                    nGroupWidth += oConfig.aSettings[:MinCellWidth]
                ok
            next
            
            # Add separator spaces
            if len(aColDimValues[2]) > 1
                nGroupWidth += len(aColDimValues[2]) - 1
            ok
            
            cCell = _center(dim1, nGroupWidth)
            cHeader1 += cCell + aBorderChars[:Vertical]
        next
        
        ? cHeader1
        
        # 1.3 Separator after first header
        cSep1 = cLeftPad + aBorderChars[:Vertical]
        
        for i = 1 to len(aColDimValues[1])
            dim1 = aColDimValues[1][i]
            cSep = ""
            
            # Add horizontal lines for each subcolumn
            for j = 1 to len(aColDimValues[2])
                dim2 = aColDimValues[2][j]
                cKey = dim1 + "|" + dim2
                
                nWidth = oConfig.aSettings[:MinCellWidth]
                if @IsHashList(aDataColumnWidths[cKey])
                    nWidth = aDataColumnWidths[cKey]
                ok
                
                cSep += copy(aBorderChars[:Horizontal], nWidth)
                
                if j < len(aColDimValues[2])
                    cSep += aBorderChars[:TeeDown]
                ok
            next
            
            cSep1 += cSep
            
            if i < len(aColDimValues[1])
                cSep1 += aBorderChars[:Cross]
            ok
        next
        
        cSep1 += aBorderChars[:Vertical]
        ? cSep1
        
        # 1.4 Second header row with row labels and second dimension
        nHeaderPadding = oConfig.aSettings[:DefaultPadding]
        cHeader2 = copy(" ", nLeftPadding - nRowLabelSectionWidth)
        
        # Add row labels with separators
        for i = 1 to len(oConfig.aRowLabels)
            cLabel = _center(oConfig.aRowLabels[i], aRowWidths[i])
            cHeader2 += cLabel
            
            if i < len(oConfig.aRowLabels)
                cHeader2 += oConfig.aDecorators[:RowLabelSeparator]
            ok
        next
        
        cHeader2 += aBorderChars[:Vertical]
        
        # Add second dimension values
        for dim1_idx = 1 to len(aColDimValues[1])
            dim1 = aColDimValues[1][dim1_idx]
            
            for dim2_idx = 1 to len(aColDimValues[2])
                dim2 = aColDimValues[2][dim2_idx]
                cKey = dim1 + "|" + dim2
                
                nWidth = oConfig.aSettings[:MinCellWidth]
                if @IsHashList(aDataColumnWidths[cKey])
                    nWidth = aDataColumnWidths[cKey]
                ok
                
                cHeader2 += " " + _center(dim2, nWidth - nHeaderPadding)
                
                if dim2_idx < len(aColDimValues[2])
                    cHeader2 += aBorderChars[:Vertical]
                ok
            next
            
            cHeader2 += " " + aBorderChars[:Vertical]
        next
        
        # Add AVERAGE/TOTAL header if enabled
        if oConfig.bShowTotalColumn
            cHeader2 += " " + _center(oConfig.cTotalLabel, nTotalColWidth - nHeaderPadding)
            cHeader2 += " " + aBorderChars[:Vertical]
        ok
        
        ? cHeader2
        
        # 1.5 Main separator before data rows
        cMainSep = aBorderChars[:TeeRight] + copy(aBorderChars[:Horizontal], nRowLabelSectionWidth) + aBorderChars[:Cross]
        
        for i = 1 to len(aColDimValues[1])
            dim1 = aColDimValues[1][i]
            nGroupWidth = 0
            
            for j = 1 to len(aColDimValues[2])
                dim2 = aColDimValues[2][j]
                cKey = dim1 + "|" + dim2
                
                nWidth = oConfig.aSettings[:MinCellWidth]
                if @IsHashList(aDataColumnWidths[cKey])
                    nWidth = aDataColumnWidths[cKey]
                ok
                
                nGroupWidth += nWidth
                
                if j < len(aColDimValues[2])
                    nGroupWidth += 1  # For separator
                ok
            next
            
            cMainSep += copy(aBorderChars[:Horizontal], nGroupWidth)
            
            if i < len(aColDimValues[1])
                cMainSep += aBorderChars[:Cross]
            ok
        next
        
        if oConfig.bShowTotalColumn
            cMainSep += aBorderChars[:Cross] + copy(aBorderChars[:Horizontal], nTotalColWidth) + aBorderChars[:TeeLeft]
        else
            cMainSep += aBorderChars[:TeeLeft]
        ok
        
        # Add left padding to the main separator
        cMainSep = copy(" ", nLeftPadding - 1) + cMainSep
        ? cMainSep
    
    # 2. Render data rows
    func RenderDataRows()
        # Extract needed values from config
        aColDimValues = oConfig.aContentDimensions[:ColumnDimValues]
        aRowWidths = oConfig.aCalculatedLayout[:RowLabelWidths]
        aDataColumnWidths = oConfig.aCalculatedLayout[:DataColumnWidths]
        nTotalColWidth = oConfig.aCalculatedLayout[:TotalColumnWidth]
        nLeftPadding = oConfig.aCalculatedLayout[:LeftPadding]
        nRowLabelSectionWidth = oConfig.aCalculatedLayout[:RowLabelSectionWidth]
        aBorderChars = oConfig.aDecorators[:BorderChars]
        aPivotData = oConfig.aPivotData
        
        cCurrentDept = ""  # Track current department for grouping
        
        for r = 2 to len(aPivotData) - 1  # Skip header and total row
            # Check if this is a new department
            if aPivotData[r][1] != cCurrentDept
                cCurrentDept = aPivotData[r][1]
                
                # Insert empty row between departments (except for first dept)
                if r > 2
                    RenderEmptyRow()
                ok
                
                # Start row with department
                cRowStart = copy(" ", nLeftPadding) + aBorderChars[:Vertical] + " "
                cRowData = _padRight(cCurrentDept, aRowWidths[1] - oConfig.aSettings[:DefaultPadding])
            else
                # Empty department column for same department
                cRowStart = copy(" ", nLeftPadding) + aBorderChars[:Vertical] + " "
                cRowData = copy(" ", aRowWidths[1] - oConfig.aSettings[:DefaultPadding])
            ok
            
            # Add location if we have it
            if len(oConfig.aRowLabels) > 1
                cRowData += " " + oConfig.aDecorators[:RowLabelSeparator] + " "
                cRowData += _padRight(aPivotData[r][2], aRowWidths[2] - oConfig.aSettings[:DefaultPadding])
            ok
            
            # Pad to full row label section width if needed
            while len(cRowData) < nRowLabelSectionWidth
                cRowData += " "
            end
            
            cRowData = cRowStart + cRowData + " " + aBorderChars[:Vertical]
            
            # Add data cells for each dimension combination
            for dim1_idx = 1 to len(aColDimValues[1])
                dim1 = aColDimValues[1][dim1_idx]
                
                for dim2_idx = 1 to len(aColDimValues[2])
                    dim2 = aColDimValues[2][dim2_idx]
                    cKey = dim1 + "|" + dim2
                    
                    # Find column index for this combination
                    nColIndex = 0
                    for c = len(oConfig.aRowLabels) + 1 to len(aPivotData[1])
                        if aPivotData[1][c] = cKey
                            nColIndex = c
                            exit
                        ok
                    next
                    
                    nCellWidth = oConfig.aSettings[:MinCellWidth]
                    if @IsHashList(aDataColumnWidths[cKey])
                        nCellWidth = aDataColumnWidths[cKey]
                    ok
                    
                    # Add data with proper padding
                    if nColIndex > 0
                        cValue = "" + aPivotData[r][nColIndex]
                        if len(cValue) > 0
                            cRowData += " " + _padLeft(cValue, nCellWidth - oConfig.aSettings[:DefaultPadding])
                        else
                            cRowData += " " + copy(" ", nCellWidth - oConfig.aSettings[:DefaultPadding])
                        ok
                    else
                        cRowData += " " + copy(" ", nCellWidth - oConfig.aSettings[:DefaultPadding])
                    ok
                    
                    if dim2_idx < len(aColDimValues[2])
                        cRowData += " " + aBorderChars[:Vertical]
                    ok
                next
                
                cRowData += " " + aBorderChars[:Vertical]
            next
            
            # Add total column if enabled
            if oConfig.bShowTotalColumn
                nTotalCol = len(aPivotData[r])
                cTotal = "" + aPivotData[r][nTotalCol]
                
                cRowData += " " + _padLeft(cTotal, nTotalColWidth - oConfig.aSettings[:DefaultPadding])
                cRowData += " " + aBorderChars[:Vertical]
            ok
            
            ? cRowData
        next
    
    # 3. Render empty row (for visual separation)
    func RenderEmptyRow()
        nLeftPadding = oConfig.aCalculatedLayout[:LeftPadding]
        nTableWidth = oConfig.aCalculatedLayout[:TableWidth]
        aBorderChars = oConfig.aDecorators[:BorderChars]
        
        cEmptyRow = copy(" ", nLeftPadding) + aBorderChars[:Vertical]
        cEmptyRow += copy(" ", nTableWidth - 2)  # -2 for the left and right borders
        cEmptyRow += aBorderChars[:Vertical]
        
        ? cEmptyRow
    
    # 4. Render table footer (total row)
    func RenderTableFooter()
        # Extract needed values from config
        aColDimValues = oConfig.aContentDimensions[:ColumnDimValues]
        aRowWidths = oConfig.aCalculatedLayout[:RowLabelWidths]
        aDataColumnWidths = oConfig.aCalculatedLayout[:DataColumnWidths]
        nTotalColWidth = oConfig.aCalculatedLayout[:TotalColumnWidth]
        nLeftPadding = oConfig.aCalculatedLayout[:LeftPadding]
        nRowLabelSectionWidth = oConfig.aCalculatedLayout[:RowLabelSectionWidth]
        aBorderChars = oConfig.aDecorators[:BorderChars]
        aPivotData = oConfig.aPivotData
        
        # Bottom separator
        cBottomSep = copy(" ", nLeftPadding)
        cBottomSep += aBorderChars[:BottomLeft] + copy(aBorderChars[:Horizontal], nRowLabelSectionWidth)
        
        for i = 1 to len(aColDimValues[1])
            dim1 = aColDimValues[1][i]
            nGroupWidth = 0
            
            for j = 1 to len(aColDimValues[2])
                dim2 = aColDimValues[2][j]
                cKey = dim1 + "|" + dim2
                
                nWidth = oConfig.aSettings[:MinCellWidth]
                if @IsHashList(aDataColumnWidths[cKey])
                    nWidth = aDataColumnWidths[cKey]
                ok
                
                nGroupWidth += nWidth
                
                if j < len(aColDimValues[2])
                    nGroupWidth += 1  # For separator
                ok
            next
            
            cBottomSep += aBorderChars[:TeeUp]
            cBottomSep += copy(aBorderChars[:Horizontal], nGroupWidth)
        next
        
        if oConfig.bShowTotalColumn
            cBottomSep += aBorderChars[:TeeUp]
            cBottomSep += copy(aBorderChars[:Horizontal], nTotalColWidth)
        ok
        
        cBottomSep += aBorderChars[:BottomRight]
        ? cBottomSep
        
        # Total row if enabled
        if oConfig.bShowTotalRow
            nLastRow = len(aPivotData)
            cTotalRow = copy(" ", nLeftPadding) + oConfig.cTotalLabel
            
            # Pad to row label section width
            while len(cTotalRow) < nLeftPadding + nRowLabelSectionWidth
                cTotalRow += " "
            end
            
            cTotalRow += " " + aBorderChars[:Vertical]
            
            # Add totals for each dimension combination
            for dim1_idx = 1 to len(aColDimValues[1])
                dim1 = aColDimValues[1][dim1_idx]
                
                for dim2_idx = 1 to len(aColDimValues[2])
                    dim2 = aColDimValues[2][dim2_idx]
                    cKey = dim1 + "|" + dim2
                    
                    # Find column index for this combination
                    nColIndex = 0
                    for c = len(oConfig.aRowLabels) + 1 to len(aPivotData[1])
                        if aPivotData[1][c] = cKey
                            nColIndex = c
                            exit
                        ok
                    next
                    
                    nCellWidth = oConfig.aSettings[:MinCellWidth]
                    if @IsHashList(aDataColumnWidths[cKey])
                        nCellWidth = aDataColumnWidths[cKey]
                    ok
                    
                    # Add total value with proper padding
                    if nColIndex > 0
                        cValue = "" + aPivotData[nLastRow][nColIndex]
                        if len(cValue) > 0
                            cTotalRow += " " + _padLeft(cValue, nCellWidth - oConfig.aSettings[:DefaultPadding])
                        else
                            cTotalRow += " " + copy(" ", nCellWidth - oConfig.aSettings[:DefaultPadding])
                        ok
                    else
                        cTotalRow += " " + copy(" ", nCellWidth - oConfig.aSettings[:DefaultPadding])
                    ok
                    
                    if dim2_idx < len(aColDimValues[2])
                        cTotalRow += " " + aBorderChars[:Vertical]
                    ok
                next
                
                cTotalRow += " " + aBorderChars[:Vertical]
            next
            
            # Add grand total if enabled
            if oConfig.bShowTotalColumn

                nTotalCol = len(aPivotData[nLastRow])
                cTotal = "" + aPivotData[nLastRow][nTotalCol]
                
                cTotalRow += " " + _padLeft(cTotal, nTotalColWidth - oConfig.aSettings[:DefaultPadding])
                cTotalRow += " " + aBorderChars[:Vertical]
            ok
            
            ? cTotalRow
        ok
    
    # Helper: Center text in a fixed width
    func _center(cText, nWidth)
        nTextLen = len(cText)
        if nTextLen >= nWidth
            return left(cText, nWidth)
        ok
        
        nLeftPad = floor((nWidth - nTextLen) / 2)
        nRightPad = nWidth - nTextLen - nLeftPad
        
        return copy(" ", nLeftPad) + cText + copy(" ", nRightPad)
    
    # Helper: Right pad text to fixed width
    func _padRight(cText, nWidth)
        nTextLen = len(cText)
        if nTextLen >= nWidth
            return left(cText, nWidth)
        ok
        
        return cText + copy(" ", nWidth - nTextLen)
    
    # Helper: Left pad text to fixed width
    func _padLeft(cText, nWidth)
        nTextLen = len(cText)
        if nTextLen >= nWidth
            return left(cText, nWidth)
        ok
        
        return copy(" ", nWidth - nTextLen) + cText
    
end  # End of TableRenderer class

# 3. ENHANCED CONFIGURATION MANAGEMENT
# ===================================

Class TableConfigManager
    
    # Reference to configuration object
    oConfig = null
    
    # Callback function for events
    fOnConfigChanged = null
    
    # Initialize with configuration object
    func init(oTableConfig)
        oConfig = oTableConfig
        return self
    
    # Set a callback to be called when config changes
    func SetChangeCallback(fCallback)
        fOnConfigChanged = fCallback
        return self
    
    # Batch update settings
    func UpdateSettings(aNewSettings)
        for aPair in aNewSettings
            cKey = aPair[1]
            value = aPair[2]										
            oConfig.SetSetting(cKey, value)
        next
        
        # Trigger recalculation
        oConfig.Recalculate()
        
        # Fire callback if set
        if type(fOnConfigChanged) = "BLOCK"
            call fOnConfigChanged()
        ok
        
        return self
    
    # Auto-optimize table layout based on content
    func OptimizeLayout()
        # Analyze current content and adjust settings
        
        # 1. Adjust cell widths based on actual content
        if oConfig.aSettings[:AutoAdjustWidths]
            aRowLabels = oConfig.aContentDimensions[:RowLabels]
            for i = 1 to len(aRowLabels)
                nOptimalWidth = max([ aRowLabels[i][:labelWidth], aRowLabels[i][:maxContentWidth] ])
                nOptimalWidth = ceil(nOptimalWidth * oConfig.aSettings[:RowLabelGrowthRatio])
                
                # Update the final width with constraints
                nOptimalWidth = max([ nOptimalWidth, oConfig.aSettings[:MinCellWidth] ])
                nOptimalWidth = min([ nOptimalWidth, oConfig.aSettings[:MaxHeaderWidth] ])
                
                oConfig.aContentDimensions[:RowLabels][i][:finalWidth] = nOptimalWidth
            next
        ok
        
        # 2. Balance column widths if enabled
        if oConfig.aSettings[:BalanceColumns]
            aColDimValues = oConfig.aContentDimensions[:ColumnDimValues]
            aDataColumnWidths = oConfig.aCalculatedLayout[:DataColumnWidths]
            
            # Find average column width
            nTotalWidth = 0
            nColumnCount = 0
            
            for dim1 in aColDimValues[1]
                for dim2 in aColDimValues[2]
                    cKey = dim1 + "|" + dim2
                    if @IsHashList(aDataColumnWidths[cKey])
                        nTotalWidth += aDataColumnWidths[cKey]
                        nColumnCount++
                    ok
                next
            next
            
            if nColumnCount > 0
                nAvgWidth = nTotalWidth / nColumnCount
                
                # Adjust columns to be closer to average (but not exact)
                for dim1 in aColDimValues[1]
                    for dim2 in aColDimValues[2]
                        cKey = dim1 + "|" + dim2
                        if @IsHashList(aDataColumnWidths[cKey])
                            nCurrentWidth = aDataColumnWidths[cKey]
                            nDiff = nCurrentWidth - nAvgWidth
                            
                            # Only adjust if difference is significant
                            if abs(nDiff) > nAvgWidth * 0.3
                                nNewWidth = nCurrentWidth - (nDiff * 0.5)
                                oConfig.aCalculatedLayout[:DataColumnWidths][cKey] = nNewWidth
                            ok
                        ok
                    next
                next
            ok
        ok
        
        # 3. Check if table exceeds maximum width
        nTableWidth = oConfig.aCalculatedLayout[:TableWidth]
        nMaxWidth = oConfig.aSettings[:MaxTableWidth]
        
        if nMaxWidth > 0 and nTableWidth > nMaxWidth
            # Scale down all widths proportionally
            nScaleFactor = nMaxWidth / nTableWidth
            
            # Apply to row labels
            for i = 1 to len(oConfig.aCalculatedLayout[:RowLabelWidths])
                oConfig.aCalculatedLayout[:RowLabelWidths][i] *= nScaleFactor
            next
            
            # Apply to data columns
            aColDimValues = oConfig.aContentDimensions[:ColumnDimValues]
            for dim1 in aColDimValues[1]
                for dim2 in aColDimValues[2]
                    cKey = dim1 + "|" + dim2
                    if @IsHashList(oConfig.aCalculatedLayout[:DataColumnWidths][cKey])
                        oConfig.aCalculatedLayout[:DataColumnWidths][cKey] *= nScaleFactor
                    ok
                next
            next
            
            # Apply to total column
            oConfig.aCalculatedLayout[:TotalColumnWidth] *= nScaleFactor
        ok
        
        # Trigger recalculation
        oConfig.Recalculate()
        
        # Fire callback if set
        if type(fOnConfigChanged) = "BLOCK"
            call fOnConfigChanged()
        ok
        
        return self
    
    # Save current configuration to a map
    func ExportConfig()
        aConfig = []
        
        # Copy settings
        aConfig[:Settings] = oConfig.aSettings
        
        # Copy calculated measurements (for reference)
        aConfig[:Layout] = oConfig.aCalculatedLayout
        
        return aConfig
    
    # Load configuration from a map
    func ImportConfig(aConfig)
        if @IsHashList(aConfig[:Settings])
            # Apply all settings
            for aPair in aConfig[:Settings]
                cKey = aPair[1]
                value = aPair[2]
                oConfig.SetSetting(cKey, value)
            next
        ok
        
        # Recalculate everything
        oConfig.Recalculate()
        
        # Fire callback if set
        if type(fOnConfigChanged) = "BLOCK"
            call fOnConfigChanged()
        ok
        
        return self
    
end  # End of TableConfigManager class

# 4. TABLE THEME MANAGER
# =====================

Class TableThemeManager
    
    # Reference to configuration object
    oConfig = null
    
    # Predefined themes
    aThemes = [
        :Default = [
            :MinCellWidth = 5,
            :MaxCellWidth = 20,
            :MaxHeaderWidth = 30,
            :DefaultPadding = 1,
            :BorderChars = [
                :TopLeft = "╭",
                :TopRight = "╮",
                :BottomLeft = "╰", 
                :BottomRight = "╯",
                :Horizontal = "─",
                :Vertical = "│",
                :Cross = "┼",
                :TeeDown = "┬",
                :TeeUp = "┴",
                :TeeRight = "├",
                :TeeLeft = "┤"
            ]
        ],
        
        :Simple = [
            :MinCellWidth = 4,
            :MaxCellWidth = 15,
            :MaxHeaderWidth = 25,
            :DefaultPadding = 1,
            :BorderChars = [
                :TopLeft = "+",
                :TopRight = "+",
                :BottomLeft = "+", 
                :BottomRight = "+",
                :Horizontal = "-",
                :Vertical = "|",
                :Cross = "+",
                :TeeDown = "+",
                :TeeUp = "+",
                :TeeRight = "+",
                :TeeLeft = "+"
            ]
        ],
        
        :Compact = [
            :MinCellWidth = 3,
            :MaxCellWidth = 10,
            :MaxHeaderWidth = 15,
            :DefaultPadding = 0,
            :CellGrowthRatio = 1.0,
            :RowLabelGrowthRatio = 1.0,
            :BorderChars = [
                :TopLeft = "+",
                :TopRight = "+",
                :BottomLeft = "+", 
                :BottomRight = "+",
                :Horizontal = "-",
                :Vertical = "|",
                :Cross = "+",
                :TeeDown = "+",
                :TeeUp = "+",
                :TeeRight = "+",
                :TeeLeft = "+"
            ]
        ],
        
        :Elegant = [
            :MinCellWidth = 6,
            :MaxCellWidth = 25,
            :MaxHeaderWidth = 35,
            :DefaultPadding = 2,
            :CellGrowthRatio = 1.3,
            :RowLabelGrowthRatio = 1.7,
            :BorderChars = [
                :TopLeft = "┌",
                :TopRight = "┐",
                :BottomLeft = "└", 
                :BottomRight = "┘",
                :Horizontal = "─",
                :Vertical = "│",
                :Cross = "┼",
                :TeeDown = "┬",
                :TeeUp = "┴",
                :TeeRight = "├",
                :TeeLeft = "┤"
            ]
        ]
    ]
    
    # Initialize with configuration object
    func init(oTableConfig)
        oConfig = oTableConfig
        return self
    
    # Apply a predefined theme
    func ApplyTheme(cThemeName)
        if !@IsHashList(aThemes[cThemeName])
            see "Theme '" + cThemeName + "' not found. Using Default." + nl
            cThemeName = :Default
        ok
        
        aTheme = aThemes[cThemeName]
        
        # Apply theme settings to config
        for aPair in aTheme
            cKey = aPair[1]
            value = aPair[2]
            if cKey = :BorderChars
                # Special case for border chars
                for aPairr in value
                    cBorderKey = aPairr[1]
                    cChar = aPairr[2]
                    oConfig.aDecorators[:BorderChars][cBorderKey] = cChar
                next
            else
                # Regular settings
                oConfig.SetSetting(cKey, value)
            ok
        next
        
        # Recalculate layout
        oConfig.Recalculate()
        
        return self
    
    # Create a custom theme
    func CreateTheme(cThemeName, aThemeSettings)
        aThemes[cThemeName] = aThemeSettings
        return self
    
    # Get a list of available themes
    func ListThemes()
        aThemeNames = []
        for aPair in aThemes
            cKey = aPair[1]
            value = aPair[2]
            add(aThemeNames, cKey)
        next
        return aThemeNames
    
end  # End of TableThemeManager class
