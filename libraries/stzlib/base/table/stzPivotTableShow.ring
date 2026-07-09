# Dynamic Pivot Table Display System
# This system provides a configurable and automatically adjusting
# display framework for pivot tables with interdependent dimensions

# 1. CORE CONFIGURATION CLASS
# ===========================

Class TableDisplayConfig
    
    # Container for all configuration and dynamic calculations
    
    # Basic display settings
    _aSettings_ = [
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
    _aContentDimensions_ = [
        :RowLabels         = [],   # Width measurements for row labels
        :ColumnDimValues   = [],   # Lists of dimension values for columns
        :ColumnHeaders     = [],   # Width measurements for column headers
        :DataCells         = [],   # Width measurements for data cells
        :TotalLabels       = [],   # Width measurements for total labels
        :TotalCells        = []    # Width measurements for total cells
    ]
    
    # Final calculated dimensions (used for rendering)
    _aCalculatedLayout_ = [
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
    _aDecorators_ = [
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
    _aPivotData_ = []        # Reference to pivot table data
    _aRowLabels_ = []        # Row dimension labels
    _aColLabels_ = []        # Column dimension labels
    _cTotalLabel_ = ""       # Label used for totals
    _bShowTotalRow_ = true   # Whether to show totals row
    _bShowTotalColumn_ = true # Whether to show totals column
    
    # Initialize with pivot table data
    func init(aPivotTable, aRowDims, aColDims, cTotalLbl)
        _aPivotData_ = aPivotTable
        _aRowLabels_ = aRowDims
        _aColLabels_ = aColDims
        _cTotalLabel_ = cTotalLbl
        
        # Perform initial measurements
        MeasureContentDimensions()
        CalculateLayout()
        return self
    
    # 1. Measure all content to determine natural sizes
    func MeasureContentDimensions()
        _aContentDimensions_[:RowLabels] = []
        _aContentDimensions_[:ColumnDimValues] = []
        _aContentDimensions_[:ColumnHeaders] = []
        _aContentDimensions_[:DataCells] = []
        _aContentDimensions_[:TotalLabels] = []
        _aContentDimensions_[:TotalCells] = []
        
        # 1.1 Analyze row labels
        _nRowLabelsLen_2 = len(_aRowLabels_)
        for i = 1 to _nRowLabelsLen_2
            _cLabel_ = _aRowLabels_[i]
            _nWidth_ = StzLen(_cLabel_)
            
            # Find max width of actual data in this column
            _nMaxDataWidth_ = _nWidth_
            _nPivotDataLen_5 = len(_aPivotData_)
            for r = 2 to _nPivotDataLen_5
                _nValueWidth_ = StzLen(_aPivotData_[r][i])
                if _nValueWidth_ > _nMaxDataWidth_
                    _nMaxDataWidth_ = _nValueWidth_
                ok
            next
            
            # Store both label width and max content width
            add(_aContentDimensions_[:RowLabels], [
                :label = _cLabel_,
                :labelWidth = _nWidth_,
                :maxContentWidth = _nMaxDataWidth_,
                :finalWidth = 0  # Will be calculated later
            ])
        next
        
        # 1.2 Extract and measure column dimension values
        _aColumnValues_ = GetUniqueColumnDimensionValues()
        _aContentDimensions_[:ColumnDimValues] = _aColumnValues_
        
        # 1.3 Measure column headers
        _aColumnHeaders_ = []
        _nColLabelsLen_ = len(_aColLabels_)
        for i = 1 to _nColLabelsLen_
            _cLabel_ = _aColLabels_[i]
            _nWidth_ = StzLen(_cLabel_)
            
            # For each value in this dimension, measure width
            _aColumnValuesi1_ = _aColumnValues_[i]
            _nColumnValuesi1Len_ = len(_aColumnValuesi1_)
            for _iLoopColumnValuesi1_ = 1 to _nColumnValuesi1Len_
            	_cValue_ = _aColumnValuesi1_[_iLoopColumnValuesi1_]
                _nValueWidth_ = StzLen(_cValue_)
                if _nValueWidth_ > _nWidth_
                    _nWidth_ = _nValueWidth_
                ok
            next
            
            add(_aColumnHeaders_, [
                :label = _cLabel_,
                :width = _nWidth_
            ])
        next
        _aContentDimensions_[:ColumnHeaders] = _aColumnHeaders_
        
        # 1.4 Measure data cells
        # Create a map to store maximum width for each column combination
        _aDataWidths_ = []
        
        # Process all data rows
        _nPivotDataLen_4 = len(_aPivotData_)
        for r = 2 to _nPivotDataLen_4 - 1  # Skip header and total rows
            _nPivotData1Len_4 = len(_aPivotData_[1])
            for c = len(_aRowLabels_) + 1 to _nPivotData1Len_4 - 1  # Skip row labels and total column
                _cHeader_ = _aPivotData_[1][c]
                if _cHeader_ = _cTotalLabel_  # Skip total columns
                    loop
                ok
                
                # Get the cell value and measure it
                _cValue_ = "" + _aPivotData_[r][c]
                _nWidth_ = StzLen(_cValue_)
                
                # Store in our map with the header as key
                if _nWidth_ > 0  # Only store non-empty cells
                    if !@IsHashList(_aDataWidths_[_cHeader_])
                        _aDataWidths_[_cHeader_] = 0
                    ok
                    
                    if _nWidth_ > _aDataWidths_[_cHeader_]
                        _aDataWidths_[_cHeader_] = _nWidth_
                    ok
                ok
            next
        next
        
        _aContentDimensions_[:DataCells] = _aDataWidths_
        
        # 1.5 Measure total labels and cells
        _nTotalLabelWidth_ = StzLen(_cTotalLabel_)
        _aContentDimensions_[:TotalLabels] = [
            :label = _cTotalLabel_,
            :width = _nTotalLabelWidth_
        ]
        
        # Measure total cells (rightmost column)
        _nMaxTotalWidth_ = 0
        if _bShowTotalColumn_
            _nPivotDataLen_3 = len(_aPivotData_)
            for r = 2 to _nPivotDataLen_3
                _nCol_ = len(_aPivotData_[r])
                _cValue_ = "" + _aPivotData_[r][_nCol_]
                _nWidth_ = StzLen(_cValue_)
                
                if _nWidth_ > _nMaxTotalWidth_
                    _nMaxTotalWidth_ = _nWidth_
                ok
            next
        ok
        
        _aContentDimensions_[:TotalCells] = [
            :width = _nMaxTotalWidth_
        ]
    
    # Helper: Get unique values for each column dimension
    func GetUniqueColumnDimensionValues()
        _aResult_ = []
        _nColLabelCount_ = len(_aColLabels_)
        
        # Initialize arrays for each dimension
        for i = 1 to _nColLabelCount_
            add(_aResult_, [])
        next
        
        # Extract unique values for each column dimension
        for i = 1 to _nColLabelCount_
            _aUnique_ = []
            _nPivotDataLen_2 = len(_aPivotData_)
            for r = 2 to _nPivotDataLen_2
                _nPivotData1Len_3 = len(_aPivotData_[1])
                for c = len(_aRowLabels_) + 1 to _nPivotData1Len_3
                    _cHeader_ = _aPivotData_[1][c]
                    if _cHeader_ = _cTotalLabel_
                        loop
                    ok
                    
                    _aParts_ = split(_cHeader_, "|")
                    if len(_aParts_) >= i and not find(_aUnique_, _aParts_[i])
                        add(_aUnique_, _aParts_[i])
                    ok
                next
            next
            _aResult_[i] = _aUnique_
        next
        
        return _aResult_
    
    # 2. Calculate final layout dimensions based on content and settings
    func CalculateLayout()
        # 2.1 Calculate row label widths
        _aFinalRowWidths_ = []
        _nRowLabelSectionWidth_ = 0
        
        _nContentDimensionsRowLabelsLen_ = len(_aContentDimensions_[:RowLabels])
        for i = 1 to _nContentDimensionsRowLabelsLen_
            _item_ = _aContentDimensions_[:RowLabels][i]
            
            # Calculate width with growth ratio and constraints
            _nWidth_ = max([ _item_[:labelWidth], _item_[:maxContentWidth] ])
            _nWidth_ = ceil(_nWidth_ * _aSettings_[:RowLabelGrowthRatio])
            
            # Apply min/max constraints
            _nWidth_ = max([ _nWidth_, _aSettings_[:MinCellWidth] ])
            _nWidth_ = min([ _nWidth_, _aSettings_[:MaxHeaderWidth] ])
            
            # Update item's final width
            _aContentDimensions_[:RowLabels][i][:finalWidth] = _nWidth_
            add(_aFinalRowWidths_, _nWidth_)
            
            # Add to section width (including separators)
            _nRowLabelSectionWidth_ += _nWidth_
            if i < len(_aContentDimensions_[:RowLabels])
                _nRowLabelSectionWidth_ += StzLen(_aDecorators_[:RowLabelSeparator])
            ok
        next
        
        _aCalculatedLayout_[:RowLabelWidths] = _aFinalRowWidths_
        _aCalculatedLayout_[:RowLabelSectionWidth] = _nRowLabelSectionWidth_
        
        # 2.2 Calculate data column widths based on dimension combinations
        _aFinalDataWidths_ = []
        _aDimWidthSums_ = []  # Width sums for each primary dimension group
        
        # Get dimension values
        _aColDimValues_ = _aContentDimensions_[:ColumnDimValues]
        
        # Create a map for each dimension combination
        _aColDimValues16_ = _aColDimValues_[1]
        _nColDimValues16Len_ = len(_aColDimValues16_)
        for _iLoopColDimValues16_ = 1 to _nColDimValues16Len_
        	_dim1_ = _aColDimValues16_[_iLoopColDimValues16_]
            _nGroupWidth_ = 0
            
            _aColDimValues28_ = _aColDimValues_[2]
            _nColDimValues28Len_ = len(_aColDimValues28_)
            for _iLoopColDimValues28_ = 1 to _nColDimValues28Len_
            	_dim2_ = _aColDimValues28_[_iLoopColDimValues28_]
                _cKey_ = _dim1_ + "|" + _dim2_
                
                # Get measured content width or minimum width
                _nWidth_ = _aSettings_[:MinCellWidth]
                if @IsHashList(_aContentDimensions_[:DataCells][_cKey_])
                    _nWidth_ = _aContentDimensions_[:DataCells][_cKey_]
                ok
                
                # Apply growth ratio and constraints
                _nWidth_ = ceil(_nWidth_ * _aSettings_[:CellGrowthRatio])
                _nWidth_ = max([ _nWidth_, _aSettings_[:MinCellWidth] ])
                _nWidth_ = min([ _nWidth_, _aSettings_[:MaxCellWidth] ])
                
                # Add padding on both sides
                _nPaddedWidth_ = _nWidth_ + (2 * _aSettings_[:DefaultPadding])
                
                # Store the final width
                if !@IsHashList(_aFinalDataWidths_[_cKey_])
                    _aFinalDataWidths_[_cKey_] = _nPaddedWidth_
                else
                    _aFinalDataWidths_[_cKey_] = _nPaddedWidth_
                ok
                
                _nGroupWidth_ += _nPaddedWidth_
            next
            
            # Account for separators within the group
            if len(_aColDimValues_[2]) > 1
                _nGroupWidth_ += (len(_aColDimValues_[2]) - 1)
            ok
            
            add(_aDimWidthSums_, _nGroupWidth_)
        next
        
        _aCalculatedLayout_[:DataColumnWidths] = _aFinalDataWidths_
        
        # 2.3 Calculate total column width
        _nTotalColumnWidth_ = 0
        if _bShowTotalColumn_
            _nWidth_ = max([
                _aContentDimensions_[:TotalLabels][:width],
                _aContentDimensions_[:TotalCells][:width]
            ])
            
            # Apply growth and constraints
            _nWidth_ = ceil(_nWidth_ * _aSettings_[:CellGrowthRatio])
            _nWidth_ = max([ _nWidth_, _aSettings_[:MinCellWidth] ])
            _nWidth_ = min([ _nWidth_, _aSettings_[:MaxCellWidth] ])
            
            # Add padding
            _nTotalColumnWidth_ = _nWidth_ + (2 * _aSettings_[:DefaultPadding])
        ok
        
        _aCalculatedLayout_[:TotalColumnWidth] = _nTotalColumnWidth_
        
        # 2.4 Calculate overall table width and adjustments
        _nTableWidth_ = _nRowLabelSectionWidth_
        
        # Add width for each dimension group
        _nDimWidthSumsLen_2 = len(_aDimWidthSums_)
        for i = 1 to _nDimWidthSumsLen_2
            _nTableWidth_ += _aDimWidthSums_[i]
            if i < len(_aDimWidthSums_)
                _nTableWidth_ += 1  # Separator between dimension groups
            ok
        next
        
        # Add total column if enabled
        if _bShowTotalColumn_
            _nTableWidth_ += _nTotalColumnWidth_ + 1  # Include separator
        ok
        
        # Add outer border characters
        _nTableWidth_ += 2  # Left and right borders
        
        _aCalculatedLayout_[:TableWidth] = _nTableWidth_
        
        # Calculate left padding
        _nLeftPadding_ = _aSettings_[:OuterPadding]
        if _aSettings_[:MaxTableWidth] > 0 and _nTableWidth_ < _aSettings_[:MaxTableWidth]
            _nLeftPadding_ = floor((_aSettings_[:MaxTableWidth] - _nTableWidth_) / 2)
        ok
        
        _aCalculatedLayout_[:LeftPadding] = _nLeftPadding_
        
        # 2.5 Calculate border width offsets for alignment
        # This helps with complex border rendering
        _aBorderOffsets_ = []
        _nCurrentOffset_ = 0
        
        # Add row labels section offset
        _nCurrentOffset_ += _nRowLabelSectionWidth_ + 1  # +1 for the initial border character
        add(_aBorderOffsets_, _nCurrentOffset_)
        
        # Add each dimension group offset
        _nDimWidthSumsLen_ = len(_aDimWidthSums_)
        for i = 1 to _nDimWidthSumsLen_
            _nCurrentOffset_ += _aDimWidthSums_[i] + 1  # +1 for separator
            add(_aBorderOffsets_, _nCurrentOffset_)
        next
        
        _aCalculatedLayout_[:BorderWidthOffsets] = _aBorderOffsets_
    
    # Helper: Get the overall width for a specific column dimension group
    func GetDimensionGroupWidth(nDimIndex)
        _aColDimValues_ = _aContentDimensions_[:ColumnDimValues]
        _nGroupWidth_ = 0
        
        _aColDimValues15_ = _aColDimValues_[1]
        _nColDimValues15Len_ = len(_aColDimValues15_)
        for _iLoopColDimValues15_ = 1 to _nColDimValues15Len_
        	_dim1_ = _aColDimValues15_[_iLoopColDimValues15_]
            _aColDimValues27_ = _aColDimValues_[2]
            _nColDimValues27Len_ = len(_aColDimValues27_)
            for _iLoopColDimValues27_ = 1 to _nColDimValues27Len_
            	_dim2_ = _aColDimValues27_[_iLoopColDimValues27_]
                _cKey_ = _dim1_ + "|" + _dim2_
                _nGroupWidth_ += _aFinalDataWidths_[_cKey_]
            next
        next
        
        return _nGroupWidth_
    
    # Helper: Get actual cell width for a specific dimension combination
    func GetCellWidth(_dim1_, _dim2_)
        _cKey_ = _dim1_ + "|" + _dim2_
        if @IsHashList(_aCalculatedLayout_[:DataColumnWidths][_cKey_])
            return _aCalculatedLayout_[:DataColumnWidths][_cKey_]
        ok
        
        return _aSettings_[:MinCellWidth]  # Default fallback
    
    # Apply a custom setting
    func SetSetting(cSetting, _value_)
        _aSettings_[cSetting] = _value_
        # Recalculate on setting change
        CalculateLayout()
        return self
    
    # Get a specific layout measurement
    func GetLayoutValue(_cKey_)
        if @IsHashList(_aCalculatedLayout_[_cKey_])
            return _aCalculatedLayout_[_cKey_]
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
        see "Row Label Section Width: " + _aCalculatedLayout_[:RowLabelSectionWidth] + nl
        see "Row Label Widths: " + nl
        _nCalculatedLayoutRowLabelWidthsLen_ = len(_aCalculatedLayout_[:RowLabelWidths])
        for i = 1 to _nCalculatedLayoutRowLabelWidthsLen_
            see "  " + _aRowLabels_[i] + ": " + _aCalculatedLayout_[:RowLabelWidths][i] + nl
        next
        
        see "Data Column Widths: " + nl
        _aColDimValues_ = _aContentDimensions_[:ColumnDimValues]
        _aColDimValues14_ = _aColDimValues_[1]
        _nColDimValues14Len_ = len(_aColDimValues14_)
        for _iLoopColDimValues14_ = 1 to _nColDimValues14Len_
        	_dim1_ = _aColDimValues14_[_iLoopColDimValues14_]
            _aColDimValues26_ = _aColDimValues_[2]
            _nColDimValues26Len_ = len(_aColDimValues26_)
            for _iLoopColDimValues26_ = 1 to _nColDimValues26Len_
            	_dim2_ = _aColDimValues26_[_iLoopColDimValues26_]
                _cKey_ = _dim1_ + "|" + _dim2_
                if @IsHashList(_aCalculatedLayout_[:DataColumnWidths][_cKey_])
                    see "  " + _cKey_ + ": " + _aCalculatedLayout_[:DataColumnWidths][_cKey_] + nl
                ok
            next
        next
        
        see "Total Column Width: " + _aCalculatedLayout_[:TotalColumnWidth] + nl
        see "Total Table Width: " + _aCalculatedLayout_[:TableWidth] + nl
        see "Left Padding: " + _aCalculatedLayout_[:LeftPadding] + nl
        see "=========================" + nl
    
end  # End of TableDisplayConfig class

# 2. RENDERING ENGINE
# ==================

Class TableRenderer
    
    # Configuration object reference
    _oConfig_ = null
    
    # Initialize with configuration object
    func init(oTableConfig)
        _oConfig_ = oTableConfig
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
        _aColDimValues_ = _oConfig_.aContentDimensions[:ColumnDimValues]
        _aRowWidths_ = _oConfig_.aCalculatedLayout[:RowLabelWidths]
        _aDataColumnWidths_ = _oConfig_.aCalculatedLayout[:DataColumnWidths]
        _nTotalColWidth_ = _oConfig_.aCalculatedLayout[:TotalColumnWidth]
        _nLeftPadding_ = _oConfig_.aCalculatedLayout[:LeftPadding]
        _nRowLabelSectionWidth_ = _oConfig_.aCalculatedLayout[:RowLabelSectionWidth]
        _aBorderChars_ = _oConfig_.aDecorators[:BorderChars]
        
        # Add top padding
        see nl + copy(nl, _oConfig_.aSettings[:HeaderTopPadding] - 1)
        
        # 1.1 Top border
        _cLeftPad_ = copy(" ", _nLeftPadding_)
        _cTopBorder_ = _cLeftPad_ + _aBorderChars_[:TopLeft]
        
        # Add horizontal lines for each column group
        _nColDimValues1Len_8 = len(_aColDimValues_[1])
        for i = 1 to _nColDimValues1Len_8
            # Calculate width for this dimension group
            _nGroupWidth_ = 0
            _aColDimValues25_ = _aColDimValues_[2]
            _nColDimValues25Len_ = len(_aColDimValues25_)
            for _iLoopColDimValues25_ = 1 to _nColDimValues25Len_
            	_dim2_ = _aColDimValues25_[_iLoopColDimValues25_]
                _cKey_ = _aColDimValues_[1][i] + "|" + _dim2_
                if @IsHashList(_aDataColumnWidths_[_cKey_])
                    _nGroupWidth_ += _aDataColumnWidths_[_cKey_]
                else
                    _nGroupWidth_ += _oConfig_.aSettings[:MinCellWidth]
                ok
            next
            
            # Add separator spaces
            if len(_aColDimValues_[2]) > 1
                _nGroupWidth_ += len(_aColDimValues_[2]) - 1
            ok
            
            _cTopBorder_ += copy(_aBorderChars_[:Horizontal], _nGroupWidth_)
            
            if i < len(_aColDimValues_[1])
                _cTopBorder_ += _aBorderChars_[:TeeDown]
            ok
        next
        
        _cTopBorder_ += _aBorderChars_[:TopRight]
        ? _cTopBorder_
        
        # 1.2 First header row - first dimension
        _cHeader1_ = _cLeftPad_ + _aBorderChars_[:Vertical]
        
        _nColDimValues1Len_7 = len(_aColDimValues_[1])
        for i = 1 to _nColDimValues1Len_7
            _dim1_ = _aColDimValues_[1][i]
            
            # Calculate width for this dimension group
            _nGroupWidth_ = 0
            _aColDimValues24_ = _aColDimValues_[2]
            _nColDimValues24Len_ = len(_aColDimValues24_)
            for _iLoopColDimValues24_ = 1 to _nColDimValues24Len_
            	_dim2_ = _aColDimValues24_[_iLoopColDimValues24_]
                _cKey_ = _dim1_ + "|" + _dim2_
                if @IsHashList(_aDataColumnWidths_[_cKey_])
                    _nGroupWidth_ += _aDataColumnWidths_[_cKey_]
                else
                    _nGroupWidth_ += _oConfig_.aSettings[:MinCellWidth]
                ok
            next
            
            # Add separator spaces
            if len(_aColDimValues_[2]) > 1
                _nGroupWidth_ += len(_aColDimValues_[2]) - 1
            ok
            
            _cCell_ = _center(_dim1_, _nGroupWidth_)
            _cHeader1_ += _cCell_ + _aBorderChars_[:Vertical]
        next
        
        ? _cHeader1_
        
        # 1.3 Separator after first header
        _cSep1_ = _cLeftPad_ + _aBorderChars_[:Vertical]
        
        _nColDimValues1Len_6 = len(_aColDimValues_[1])
        for i = 1 to _nColDimValues1Len_6
            _dim1_ = _aColDimValues_[1][i]
            _cSep_ = ""
            
            # Add horizontal lines for each subcolumn
            _nColDimValues2Len_6 = len(_aColDimValues_[2])
            for j = 1 to _nColDimValues2Len_6
                _dim2_ = _aColDimValues_[2][j]
                _cKey_ = _dim1_ + "|" + _dim2_
                
                _nWidth_ = _oConfig_.aSettings[:MinCellWidth]
                if @IsHashList(_aDataColumnWidths_[_cKey_])
                    _nWidth_ = _aDataColumnWidths_[_cKey_]
                ok
                
                _cSep_ += copy(_aBorderChars_[:Horizontal], _nWidth_)
                
                if j < len(_aColDimValues_[2])
                    _cSep_ += _aBorderChars_[:TeeDown]
                ok
            next
            
            _cSep1_ += _cSep_
            
            if i < len(_aColDimValues_[1])
                _cSep1_ += _aBorderChars_[:Cross]
            ok
        next
        
        _cSep1_ += _aBorderChars_[:Vertical]
        ? _cSep1_
        
        # 1.4 Second header row with row labels and second dimension
        _nHeaderPadding_ = _oConfig_.aSettings[:DefaultPadding]
        _cHeader2_ = copy(" ", _nLeftPadding_ - _nRowLabelSectionWidth_)
        
        # Add row labels with separators
        _nConfigaRowLabelsLen_ = len(_oConfig_.aRowLabels)
        for i = 1 to _nConfigaRowLabelsLen_
            _cLabel_ = _center(_oConfig_.aRowLabels[i], _aRowWidths_[i])
            _cHeader2_ += _cLabel_
            
            if i < len(_oConfig_.aRowLabels)
                _cHeader2_ += _oConfig_.aDecorators[:RowLabelSeparator]
            ok
        next
        
        _cHeader2_ += _aBorderChars_[:Vertical]
        
        # Add second dimension values
        _nColDimValues1Len_5 = len(_aColDimValues_[1])
        for dim1_idx = 1 to _nColDimValues1Len_5
            _dim1_ = _aColDimValues_[1][dim1_idx]
            
            _nColDimValues2Len_5 = len(_aColDimValues_[2])
            for dim2_idx = 1 to _nColDimValues2Len_5
                _dim2_ = _aColDimValues_[2][dim2_idx]
                _cKey_ = _dim1_ + "|" + _dim2_
                
                _nWidth_ = _oConfig_.aSettings[:MinCellWidth]
                if @IsHashList(_aDataColumnWidths_[_cKey_])
                    _nWidth_ = _aDataColumnWidths_[_cKey_]
                ok
                
                _cHeader2_ += " " + _center(_dim2_, _nWidth_ - _nHeaderPadding_)
                
                if dim2_idx < len(_aColDimValues_[2])
                    _cHeader2_ += _aBorderChars_[:Vertical]
                ok
            next
            
            _cHeader2_ += " " + _aBorderChars_[:Vertical]
        next
        
        # Add AVERAGE/TOTAL header if enabled
        if _oConfig_.bShowTotalColumn
            _cHeader2_ += " " + _center(_oConfig_.cTotalLabel, _nTotalColWidth_ - _nHeaderPadding_)
            _cHeader2_ += " " + _aBorderChars_[:Vertical]
        ok
        
        ? _cHeader2_
        
        # 1.5 Main separator before data rows
        _cMainSep_ = _aBorderChars_[:TeeRight] + copy(_aBorderChars_[:Horizontal], _nRowLabelSectionWidth_) + _aBorderChars_[:Cross]
        
        _nColDimValues1Len_4 = len(_aColDimValues_[1])
        for i = 1 to _nColDimValues1Len_4
            _dim1_ = _aColDimValues_[1][i]
            _nGroupWidth_ = 0
            
            _nColDimValues2Len_4 = len(_aColDimValues_[2])
            for j = 1 to _nColDimValues2Len_4
                _dim2_ = _aColDimValues_[2][j]
                _cKey_ = _dim1_ + "|" + _dim2_
                
                _nWidth_ = _oConfig_.aSettings[:MinCellWidth]
                if @IsHashList(_aDataColumnWidths_[_cKey_])
                    _nWidth_ = _aDataColumnWidths_[_cKey_]
                ok
                
                _nGroupWidth_ += _nWidth_
                
                if j < len(_aColDimValues_[2])
                    _nGroupWidth_ += 1  # For separator
                ok
            next
            
            _cMainSep_ += copy(_aBorderChars_[:Horizontal], _nGroupWidth_)
            
            if i < len(_aColDimValues_[1])
                _cMainSep_ += _aBorderChars_[:Cross]
            ok
        next
        
        if _oConfig_.bShowTotalColumn
            _cMainSep_ += _aBorderChars_[:Cross] + copy(_aBorderChars_[:Horizontal], _nTotalColWidth_) + _aBorderChars_[:TeeLeft]
        else
            _cMainSep_ += _aBorderChars_[:TeeLeft]
        ok
        
        # Add left padding to the main separator
        _cMainSep_ = copy(" ", _nLeftPadding_ - 1) + _cMainSep_
        ? _cMainSep_
    
    # 2. Render data rows
    func RenderDataRows()
        # Extract needed values from config
        _aColDimValues_ = _oConfig_.aContentDimensions[:ColumnDimValues]
        _aRowWidths_ = _oConfig_.aCalculatedLayout[:RowLabelWidths]
        _aDataColumnWidths_ = _oConfig_.aCalculatedLayout[:DataColumnWidths]
        _nTotalColWidth_ = _oConfig_.aCalculatedLayout[:TotalColumnWidth]
        _nLeftPadding_ = _oConfig_.aCalculatedLayout[:LeftPadding]
        _nRowLabelSectionWidth_ = _oConfig_.aCalculatedLayout[:RowLabelSectionWidth]
        _aBorderChars_ = _oConfig_.aDecorators[:BorderChars]
        _aPivotData_ = _oConfig_.aPivotData
        
        _cCurrentDept_ = ""  # Track current department for grouping
        
        _nPivotDataLen_ = len(_aPivotData_)
        for r = 2 to _nPivotDataLen_ - 1  # Skip header and total row
            # Check if this is a new department
            if _aPivotData_[r][1] != _cCurrentDept_
                _cCurrentDept_ = _aPivotData_[r][1]
                
                # Insert empty row between departments (except for first dept)
                if r > 2
                    RenderEmptyRow()
                ok
                
                # Start row with department
                _cRowStart_ = copy(" ", _nLeftPadding_) + _aBorderChars_[:Vertical] + " "
                _cRowData_ = _padRight(_cCurrentDept_, _aRowWidths_[1] - _oConfig_.aSettings[:DefaultPadding])
            else
                # Empty department column for same department
                _cRowStart_ = copy(" ", _nLeftPadding_) + _aBorderChars_[:Vertical] + " "
                _cRowData_ = copy(" ", _aRowWidths_[1] - _oConfig_.aSettings[:DefaultPadding])
            ok
            
            # Add location if we have it
            if len(_oConfig_.aRowLabels) > 1
                _cRowData_ += " " + _oConfig_.aDecorators[:RowLabelSeparator] + " "
                _cRowData_ += _padRight(_aPivotData_[r][2], _aRowWidths_[2] - _oConfig_.aSettings[:DefaultPadding])
            ok
            
            # Pad to full row label section width if needed
            while StzLen(_cRowData_) < _nRowLabelSectionWidth_
                _cRowData_ += " "
            end
            
            _cRowData_ = _cRowStart_ + _cRowData_ + " " + _aBorderChars_[:Vertical]
            
            # Add data cells for each dimension combination
            _nColDimValues1Len_3 = len(_aColDimValues_[1])
            for dim1_idx = 1 to _nColDimValues1Len_3
                _dim1_ = _aColDimValues_[1][dim1_idx]
                
                _nColDimValues2Len_3 = len(_aColDimValues_[2])
                for dim2_idx = 1 to _nColDimValues2Len_3
                    _dim2_ = _aColDimValues_[2][dim2_idx]
                    _cKey_ = _dim1_ + "|" + _dim2_
                    
                    # Find column index for this combination
                    _nColIndex_ = 0
                    _nPivotData1Len_2 = len(_aPivotData_[1])
                    for c = len(_oConfig_.aRowLabels) + 1 to _nPivotData1Len_2
                        if _aPivotData_[1][c] = _cKey_
                            _nColIndex_ = c
                            exit
                        ok
                    next
                    
                    _nCellWidth_ = _oConfig_.aSettings[:MinCellWidth]
                    if @IsHashList(_aDataColumnWidths_[_cKey_])
                        _nCellWidth_ = _aDataColumnWidths_[_cKey_]
                    ok
                    
                    # Add data with proper padding
                    if _nColIndex_ > 0
                        _cValue_ = "" + _aPivotData_[r][_nColIndex_]
                        if StzLen(_cValue_) > 0
                            _cRowData_ += " " + _padLeft(_cValue_, _nCellWidth_ - _oConfig_.aSettings[:DefaultPadding])
                        else
                            _cRowData_ += " " + copy(" ", _nCellWidth_ - _oConfig_.aSettings[:DefaultPadding])
                        ok
                    else
                        _cRowData_ += " " + copy(" ", _nCellWidth_ - _oConfig_.aSettings[:DefaultPadding])
                    ok
                    
                    if dim2_idx < len(_aColDimValues_[2])
                        _cRowData_ += " " + _aBorderChars_[:Vertical]
                    ok
                next
                
                _cRowData_ += " " + _aBorderChars_[:Vertical]
            next
            
            # Add total column if enabled
            if _oConfig_.bShowTotalColumn
                _nTotalCol_ = len(_aPivotData_[r])
                _cTotal_ = "" + _aPivotData_[r][_nTotalCol_]
                
                _cRowData_ += " " + _padLeft(_cTotal_, _nTotalColWidth_ - _oConfig_.aSettings[:DefaultPadding])
                _cRowData_ += " " + _aBorderChars_[:Vertical]
            ok
            
            ? _cRowData_
        next
    
    # 3. Render empty row (for visual separation)
    func RenderEmptyRow()
        _nLeftPadding_ = _oConfig_.aCalculatedLayout[:LeftPadding]
        _nTableWidth_ = _oConfig_.aCalculatedLayout[:TableWidth]
        _aBorderChars_ = _oConfig_.aDecorators[:BorderChars]
        
        _cEmptyRow_ = copy(" ", _nLeftPadding_) + _aBorderChars_[:Vertical]
        _cEmptyRow_ += copy(" ", _nTableWidth_ - 2)  # -2 for the left and right borders
        _cEmptyRow_ += _aBorderChars_[:Vertical]
        
        ? _cEmptyRow_
    
    # 4. Render table footer (total row)
    func RenderTableFooter()
        # Extract needed values from config
        _aColDimValues_ = _oConfig_.aContentDimensions[:ColumnDimValues]
        _aRowWidths_ = _oConfig_.aCalculatedLayout[:RowLabelWidths]
        _aDataColumnWidths_ = _oConfig_.aCalculatedLayout[:DataColumnWidths]
        _nTotalColWidth_ = _oConfig_.aCalculatedLayout[:TotalColumnWidth]
        _nLeftPadding_ = _oConfig_.aCalculatedLayout[:LeftPadding]
        _nRowLabelSectionWidth_ = _oConfig_.aCalculatedLayout[:RowLabelSectionWidth]
        _aBorderChars_ = _oConfig_.aDecorators[:BorderChars]
        _aPivotData_ = _oConfig_.aPivotData
        
        # Bottom separator
        _cBottomSep_ = copy(" ", _nLeftPadding_)
        _cBottomSep_ += _aBorderChars_[:BottomLeft] + copy(_aBorderChars_[:Horizontal], _nRowLabelSectionWidth_)
        
        _nColDimValues1Len_2 = len(_aColDimValues_[1])
        for i = 1 to _nColDimValues1Len_2
            _dim1_ = _aColDimValues_[1][i]
            _nGroupWidth_ = 0
            
            _nColDimValues2Len_2 = len(_aColDimValues_[2])
            for j = 1 to _nColDimValues2Len_2
                _dim2_ = _aColDimValues_[2][j]
                _cKey_ = _dim1_ + "|" + _dim2_
                
                _nWidth_ = _oConfig_.aSettings[:MinCellWidth]
                if @IsHashList(_aDataColumnWidths_[_cKey_])
                    _nWidth_ = _aDataColumnWidths_[_cKey_]
                ok
                
                _nGroupWidth_ += _nWidth_
                
                if j < len(_aColDimValues_[2])
                    _nGroupWidth_ += 1  # For separator
                ok
            next
            
            _cBottomSep_ += _aBorderChars_[:TeeUp]
            _cBottomSep_ += copy(_aBorderChars_[:Horizontal], _nGroupWidth_)
        next
        
        if _oConfig_.bShowTotalColumn
            _cBottomSep_ += _aBorderChars_[:TeeUp]
            _cBottomSep_ += copy(_aBorderChars_[:Horizontal], _nTotalColWidth_)
        ok
        
        _cBottomSep_ += _aBorderChars_[:BottomRight]
        ? _cBottomSep_
        
        # Total row if enabled
        if _oConfig_.bShowTotalRow
            _nLastRow_ = len(_aPivotData_)
            _cTotalRow_ = copy(" ", _nLeftPadding_) + _oConfig_.cTotalLabel
            
            # Pad to row label section width
            while StzLen(_cTotalRow_) < _nLeftPadding_ + _nRowLabelSectionWidth_
                _cTotalRow_ += " "
            end
            
            _cTotalRow_ += " " + _aBorderChars_[:Vertical]
            
            # Add totals for each dimension combination
            _nColDimValues1Len_ = len(_aColDimValues_[1])
            for dim1_idx = 1 to _nColDimValues1Len_
                _dim1_ = _aColDimValues_[1][dim1_idx]
                
                _nColDimValues2Len_ = len(_aColDimValues_[2])
                for dim2_idx = 1 to _nColDimValues2Len_
                    _dim2_ = _aColDimValues_[2][dim2_idx]
                    _cKey_ = _dim1_ + "|" + _dim2_
                    
                    # Find column index for this combination
                    _nColIndex_ = 0
                    _nPivotData1Len_ = len(_aPivotData_[1])
                    for c = len(_oConfig_.aRowLabels) + 1 to _nPivotData1Len_
                        if _aPivotData_[1][c] = _cKey_
                            _nColIndex_ = c
                            exit
                        ok
                    next
                    
                    _nCellWidth_ = _oConfig_.aSettings[:MinCellWidth]
                    if @IsHashList(_aDataColumnWidths_[_cKey_])
                        _nCellWidth_ = _aDataColumnWidths_[_cKey_]
                    ok
                    
                    # Add total value with proper padding
                    if _nColIndex_ > 0
                        _cValue_ = "" + _aPivotData_[_nLastRow_][_nColIndex_]
                        if StzLen(_cValue_) > 0
                            _cTotalRow_ += " " + _padLeft(_cValue_, _nCellWidth_ - _oConfig_.aSettings[:DefaultPadding])
                        else
                            _cTotalRow_ += " " + copy(" ", _nCellWidth_ - _oConfig_.aSettings[:DefaultPadding])
                        ok
                    else
                        _cTotalRow_ += " " + copy(" ", _nCellWidth_ - _oConfig_.aSettings[:DefaultPadding])
                    ok
                    
                    if dim2_idx < len(_aColDimValues_[2])
                        _cTotalRow_ += " " + _aBorderChars_[:Vertical]
                    ok
                next
                
                _cTotalRow_ += " " + _aBorderChars_[:Vertical]
            next
            
            # Add grand total if enabled
            if _oConfig_.bShowTotalColumn

                _nTotalCol_ = len(_aPivotData_[_nLastRow_])
                _cTotal_ = "" + _aPivotData_[_nLastRow_][_nTotalCol_]
                
                _cTotalRow_ += " " + _padLeft(_cTotal_, _nTotalColWidth_ - _oConfig_.aSettings[:DefaultPadding])
                _cTotalRow_ += " " + _aBorderChars_[:Vertical]
            ok
            
            ? _cTotalRow_
        ok
    
    # Helper: Center text in a fixed width
    func _center(cText, _nWidth_)
        _nTextLen_ = StzLen(cText)
        if _nTextLen_ >= _nWidth_
            return StzLeft(cText, _nWidth_)
        ok
        
        _nLeftPad_ = floor((_nWidth_ - _nTextLen_) / 2)
        _nRightPad_ = _nWidth_ - _nTextLen_ - _nLeftPad_
        
        return copy(" ", _nLeftPad_) + cText + copy(" ", _nRightPad_)
    
    # Helper: Right pad text to fixed width
    func _padRight(cText, _nWidth_)
        _nTextLen_ = StzLen(cText)
        if _nTextLen_ >= _nWidth_
            return StzLeft(cText, _nWidth_)
        ok
        
        return cText + copy(" ", _nWidth_ - _nTextLen_)
    
    # Helper: Left pad text to fixed width
    func _padLeft(cText, _nWidth_)
        _nTextLen_ = StzLen(cText)
        if _nTextLen_ >= _nWidth_
            return StzLeft(cText, _nWidth_)
        ok
        
        return copy(" ", _nWidth_ - _nTextLen_) + cText
    
end  # End of TableRenderer class

# 3. ENHANCED CONFIGURATION MANAGEMENT
# ===================================

Class TableConfigManager
    
    # Reference to configuration object
    _oConfig_ = null
    
    # Callback function for events
    _fOnConfigChanged_ = null
    
    # Initialize with configuration object
    func init(oTableConfig)
        _oConfig_ = oTableConfig
        return self
    
    # Set a callback to be called when config changes
    func SetChangeCallback(fCallback)
        _fOnConfigChanged_ = fCallback
        return self
    
    # Batch update settings
    func UpdateSettings(aNewSettings)
        _nNewSettings1Len_ = len(aNewSettings)
        for _iLoopNewSettings1_ = 1 to _nNewSettings1Len_
        	_aPair_ = aNewSettings[_iLoopNewSettings1_]
            _cKey_ = _aPair_[1]
            _value_ = _aPair_[2]										
            _oConfig_.SetSetting(_cKey_, _value_)
        next
        
        # Trigger recalculation
        _oConfig_.Recalculate()
        
        # Fire callback if set
        if type(_fOnConfigChanged_) = "BLOCK"
            call _fOnConfigChanged_()
        ok
        
        return self
    
    # Auto-optimize table layout based on content
    func OptimizeLayout()
        # Analyze current content and adjust settings
        
        # 1. Adjust cell widths based on actual content
        if _oConfig_.aSettings[:AutoAdjustWidths]
            _aRowLabels_ = _oConfig_.aContentDimensions[:RowLabels]
            _nRowLabelsLen_ = len(_aRowLabels_)
            for i = 1 to _nRowLabelsLen_
                _nOptimalWidth_ = max([ _aRowLabels_[i][:labelWidth], _aRowLabels_[i][:maxContentWidth] ])
                _nOptimalWidth_ = ceil(_nOptimalWidth_ * _oConfig_.aSettings[:RowLabelGrowthRatio])
                
                # Update the final width with constraints
                _nOptimalWidth_ = max([ _nOptimalWidth_, _oConfig_.aSettings[:MinCellWidth] ])
                _nOptimalWidth_ = min([ _nOptimalWidth_, _oConfig_.aSettings[:MaxHeaderWidth] ])
                
                _oConfig_.aContentDimensions[:RowLabels][i][:finalWidth] = _nOptimalWidth_
            next
        ok
        
        # 2. Balance column widths if enabled
        if _oConfig_.aSettings[:BalanceColumns]
            _aColDimValues_ = _oConfig_.aContentDimensions[:ColumnDimValues]
            _aDataColumnWidths_ = _oConfig_.aCalculatedLayout[:DataColumnWidths]
            
            # Find average column width
            _nTotalWidth_ = 0
            _nColumnCount_ = 0
            
            _aColDimValues13_ = _aColDimValues_[1]
            _nColDimValues13Len_ = len(_aColDimValues13_)
            for _iLoopColDimValues13_ = 1 to _nColDimValues13Len_
            	_dim1_ = _aColDimValues13_[_iLoopColDimValues13_]
                _aColDimValues23_ = _aColDimValues_[2]
                _nColDimValues23Len_ = len(_aColDimValues23_)
                for _iLoopColDimValues23_ = 1 to _nColDimValues23Len_
                	_dim2_ = _aColDimValues23_[_iLoopColDimValues23_]
                    _cKey_ = _dim1_ + "|" + _dim2_
                    if @IsHashList(_aDataColumnWidths_[_cKey_])
                        _nTotalWidth_ += _aDataColumnWidths_[_cKey_]
                        _nColumnCount_++
                    ok
                next
            next
            
            if _nColumnCount_ > 0
                _nAvgWidth_ = _nTotalWidth_ / _nColumnCount_
                
                # Adjust columns to be closer to average (but not exact)
                _aColDimValues12_ = _aColDimValues_[1]
                _nColDimValues12Len_ = len(_aColDimValues12_)
                for _iLoopColDimValues12_ = 1 to _nColDimValues12Len_
                	_dim1_ = _aColDimValues12_[_iLoopColDimValues12_]
                    _aColDimValues22_ = _aColDimValues_[2]
                    _nColDimValues22Len_ = len(_aColDimValues22_)
                    for _iLoopColDimValues22_ = 1 to _nColDimValues22Len_
                    	_dim2_ = _aColDimValues22_[_iLoopColDimValues22_]
                        _cKey_ = _dim1_ + "|" + _dim2_
                        if @IsHashList(_aDataColumnWidths_[_cKey_])
                            _nCurrentWidth_ = _aDataColumnWidths_[_cKey_]
                            _nDiff_ = _nCurrentWidth_ - _nAvgWidth_
                            
                            # Only adjust if difference is significant
                            if abs(_nDiff_) > _nAvgWidth_ * 0.3
                                _nNewWidth_ = _nCurrentWidth_ - (_nDiff_ * 0.5)
                                _oConfig_.aCalculatedLayout[:DataColumnWidths][_cKey_] = _nNewWidth_
                            ok
                        ok
                    next
                next
            ok
        ok
        
        # 3. Check if table exceeds maximum width
        _nTableWidth_ = _oConfig_.aCalculatedLayout[:TableWidth]
        _nMaxWidth_ = _oConfig_.aSettings[:MaxTableWidth]
        
        if _nMaxWidth_ > 0 and _nTableWidth_ > _nMaxWidth_
            # Scale down all widths proportionally
            _nScaleFactor_ = _nMaxWidth_ / _nTableWidth_
            
            # Apply to row labels
            _nConfigaCalculatedLayoutRowLabeLen_ = len(_oConfig_.aCalculatedLayout[:RowLabelWidths])
            for i = 1 to _nConfigaCalculatedLayoutRowLabeLen_
                _oConfig_.aCalculatedLayout[:RowLabelWidths][i] *= _nScaleFactor_
            next
            
            # Apply to data columns
            _aColDimValues_ = _oConfig_.aContentDimensions[:ColumnDimValues]
            _aColDimValues11_ = _aColDimValues_[1]
            _nColDimValues11Len_ = len(_aColDimValues11_)
            for _iLoopColDimValues11_ = 1 to _nColDimValues11Len_
            	_dim1_ = _aColDimValues11_[_iLoopColDimValues11_]
                _aColDimValues21_ = _aColDimValues_[2]
                _nColDimValues21Len_ = len(_aColDimValues21_)
                for _iLoopColDimValues21_ = 1 to _nColDimValues21Len_
                	_dim2_ = _aColDimValues21_[_iLoopColDimValues21_]
                    _cKey_ = _dim1_ + "|" + _dim2_
                    if @IsHashList(_oConfig_.aCalculatedLayout[:DataColumnWidths][_cKey_])
                        _oConfig_.aCalculatedLayout[:DataColumnWidths][_cKey_] *= _nScaleFactor_
                    ok
                next
            next
            
            # Apply to total column
            _oConfig_.aCalculatedLayout[:TotalColumnWidth] *= _nScaleFactor_
        ok
        
        # Trigger recalculation
        _oConfig_.Recalculate()
        
        # Fire callback if set
        if type(_fOnConfigChanged_) = "BLOCK"
            call _fOnConfigChanged_()
        ok
        
        return self
    
    # Save current configuration to a map
    func ExportConfig()
        _aConfig_ = []
        
        # Copy settings
        _aConfig_[:Settings] = _oConfig_.aSettings
        
        # Copy calculated measurements (for reference)
        _aConfig_[:Layout] = _oConfig_.aCalculatedLayout
        
        return _aConfig_
    
    # Load configuration from a map
    func ImportConfig(_aConfig_)
        if @IsHashList(_aConfig_[:Settings])
            # Apply all settings
            _aConfigSettings1_ = _aConfig_[:Settings]
            _nConfigSettings1Len_ = len(_aConfigSettings1_)
            for _iLoopConfigSettings1_ = 1 to _nConfigSettings1Len_
            	_aPair_ = _aConfigSettings1_[_iLoopConfigSettings1_]
                _cKey_ = _aPair_[1]
                _value_ = _aPair_[2]
                _oConfig_.SetSetting(_cKey_, _value_)
            next
        ok
        
        # Recalculate everything
        _oConfig_.Recalculate()
        
        # Fire callback if set
        if type(_fOnConfigChanged_) = "BLOCK"
            call _fOnConfigChanged_()
        ok
        
        return self
    
end  # End of TableConfigManager class

# 4. TABLE THEME MANAGER
# =====================

Class TableThemeManager
    
    # Reference to configuration object
    _oConfig_ = null
    
    # Predefined themes
    _aThemes_ = [
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
        _oConfig_ = oTableConfig
        return self
    
    # Apply a predefined theme
    func ApplyTheme(_cThemeName_)
        if !@IsHashList(_aThemes_[_cThemeName_])
            see "Theme '" + _cThemeName_ + "' not found. Using Default." + nl
            _cThemeName_ = :Default
        ok
        
        _aTheme_ = _aThemes_[_cThemeName_]
        
        # Apply theme settings to config
        _nTheme1Len_ = len(_aTheme_)
        for _iLoopTheme1_ = 1 to _nTheme1Len_
        	_aPair_ = _aTheme_[_iLoopTheme1_]
            _cKey_ = _aPair_[1]
            _value_ = _aPair_[2]
            if _cKey_ = :BorderChars
                # Special case for border chars
                _nValue1Len_ = len(_value_)
                for _iLoopValue1_ = 1 to _nValue1Len_
                	_aPairr_ = _value_[_iLoopValue1_]
                    _cBorderKey_ = _aPairr_[1]
                    _cChar_ = _aPairr_[2]
                    _oConfig_.aDecorators[:BorderChars][_cBorderKey_] = _cChar_
                next
            else
                # Regular settings
                _oConfig_.SetSetting(_cKey_, _value_)
            ok
        next
        
        # Recalculate layout
        _oConfig_.Recalculate()
        
        return self
    
    # Create a custom theme
    func CreateTheme(_cThemeName_, aThemeSettings)
        _aThemes_[_cThemeName_] = aThemeSettings
        return self
    
    # Get a list of available themes
    func ListThemes()
        _aThemeNames_ = []
        _nThemes1Len_ = len(_aThemes_)
        for _iLoopThemes1_ = 1 to _nThemes1Len_
        	_aPair_ = _aThemes_[_iLoopThemes1_]
            _cKey_ = _aPair_[1]
            _value_ = _aPair_[2]
            add(_aThemeNames_, _cKey_)
        next
        return _aThemeNames_
    
end  # End of TableThemeManager class
