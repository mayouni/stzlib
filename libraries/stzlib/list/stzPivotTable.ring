#--------------------------------#
#  PIVOT TABLE CORE FUNCTIONALITY #
#--------------------------------#

func stzPivotTable(pSource)
	# Creates a new instance of stzPivotTable with the provided source data	# data
	return new stzPivotTable(pSource)

class stzPivotTable
	# Instance variables for pivot table configuration and state
	@oSourceTable
	@aRowLabels = []
	@aColLabels = []
	@aValues = []
	@cAggFunc = "SUM"
	@aPivotData = []
	@oResultTable
	@bShowTotalRow = TRUE
	@bShowTotalColumn = TRUE
	@cTotalLabel = "TOTAL"
	@cCellNullValue = ""
	@cRowLabelsSeparator = "_"
	
	# Cache for performance optimization
	@aCellCache = []
	
	# State tracking for generation status
	@bIsGenerated = FALSE

	# Define border characters
	@aBorder = [
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

	@aColumnOrder = []  # Will store custom column order if specified

	  #-----------------------------#
	 #  INITIALIZATION AND SETUP   #
	#-----------------------------#

	def init(pSource)
		# Initialize the pivot table with source data
		if isString(pSource) and lower(pSource) = :fromsource
			return
		ok
		
		# Handle different source types (object or raw data)
		if isObject(pSource) and classname(pSource) = "stztable"
			@oSourceTable = pSource
		else
			@oSourceTable = new stzTable(pSource)
		ok
		
		# Initialize cache
		@aCellCache = []

	  #--------------------------#
	 #  CONFIGURATION METHODS   #
	#--------------------------#

	def Analyze(paValues, pcFunc)
		if CheckParams()
			if isList(pcFunc) and StzListQ(pcFunc).IsWithOrUsingNamedParam()
				pcFunc = pcFunc[2]
			ok
		ok

		# Configure values and aggregation function for analysis
		This.SetValues(paValues)
		This.SetAggregateFunction(pcFunc)
		This.SetTotalLabel(pcFunc)

	def SetRowsBy(paLabels)
		# Set row labels for pivot table
		This.SetRowLabels(paLabels)

	def SetColsBy(paLabels)
		# Set column labels for pivot table
		This.SetColumnLabels(paLabels)

	def SetRowLabels(paLabels)
		# Configure row labels, accepting string or list
		if isString(paLabels)
			@aRowLabels = [paLabels]
		else
			@aRowLabels = paLabels
		ok
		@bIsGenerated = FALSE

	def SetRowLabel(pcLabel)
		# Set single row label
		@aRowLabels = [pcLabel]
		@bIsGenerated = FALSE

	def SetColumnLabels(paLabels)
		# Configure column labels, accepting string or list
		if isString(paLabels)
			@aColLabels = [paLabels]
		else
			@aColLabels = paLabels
		ok
		@bIsGenerated = FALSE

	def SetColumnLabel(pcLabel)
		# Set single column label
		@aColLabels = [pcLabel]
		@bIsGenerated = FALSE

	def SetValues(paValues)
		# Configure values for aggregation
		if isString(paValues)
			@aValues = [paValues]
		else
			@aValues = paValues
		ok
		@bIsGenerated = FALSE

	def SetValue(pcValue)
		# Set single value for aggregation
		@aValues = [pcValue]
		@bIsGenerated = FALSE

	def SetAggregateFunction(pcFunction)
		# Set aggregation function (e.g., SUM, AVG)
		@cAggFunc = upper(pcFunction)
		This.SetTotalLabel(@cAggFunc)
		@bIsGenerated = FALSE

	def SetRowLabelsSeparator(pcSeparator)
		# Set separator for multi-level row labels
		@cRowLabelsSeparator = pcSeparator
		@bIsGenerated = FALSE

	def SetShowTotals(pbShowRow, pbShowCol)
		# Configure visibility of total row and column
		@bShowTotalRow = pbShowRow
		@bShowTotalColumn = pbShowCol
		@bIsGenerated = FALSE

	def SetHideTotals()
		# Hide both total row and column
		@bShowTotalRow = FALSE
		@bShowTotalColumn = FALSE
		@bIsGenerated = FALSE

	def SetTotalLabel(pcLabel)
		# Set label for totals
		@cTotalLabel = pcLabel
		@bIsGenerated = FALSE

	def SetNullValue(pcValue)
		# Set value for null/empty cells
		@cCellNullValue = pcValue
		@bIsGenerated = FALSE

	def SetColumnOrder(paOrder)
		@aColumnOrder = paOrder

	  #-----------------------------#
	 #  PIVOT TABLE GENERATION     #
	#-----------------------------#

	def Generate()
		# Generate the pivot table based on configuration
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
		
		# Validate source table
		if NOT isObject(@oSourceTable)
			stzRaise("Source table is not properly initialized")
		ok
		
		# Get unique combinations for rows and columns
		aUniqueRowCombos = _getUniqueCombinations(@aRowLabels)
		aUniqueColCombos = _getUniqueCombinations(@aColLabels)
		
		# Create header structure for the pivot table
		@aPivotData = [ @Flatten(_createHeaderStructure(aUniqueColCombos)) ]
		
		# Generate data rows
		_generateDataRows(aUniqueRowCombos, aUniqueColCombos)
		
		# Add total row if configured
		if @bShowTotalRow
			_addTotalRow()
		ok

		# Create result table
		@oResultTable = new stzTable(@aPivotData)
		@bIsGenerated = TRUE

	  #--------------------------------#
	 #  DATA PROCESSING HELPERS       #
	#--------------------------------#

	def _getUniqueCombinations(paFields)

		nRows = @oSourceTable.NumberOfRows()

		# Get unique combinations of values for specified fields

		nLenFields = len(paFields)
		if nLenFields = 0
			return []
		ok

		if nLenFields = 1

			# Handle single field

			nColIndex = @oSourceTable.FindCol(paFields[1])

			if nColIndex = 0
				stzRaise("Column not found: " + paFields[1])
			ok

			# Collect unique values

			aCells = []

			for i = 2 to nRows
				aCells + @oSourceTable.Cell(nColIndex, i)
			next

			aUniqueValues = U(aCells)
			nLenU = len(aUniqueValues)

			# Apply custom ordering if available and this is a column field

			nLenColOrder = len(@aColumnOrder)

			if paFields = @aColLabels and nLenColOrder > 0
				aOrdered = []

				# First add values from the custom order

				for i = 1 to nLenColOrder
					if ring_find(aUniqueValues, @aColumnOrder[i]) > 0
						aOrdered + @aColumnOrder[i]
					ok
				next

				# Then add any values not in the custom order

				for i = 1 to nLenU
					cItem = aUniqueValues[i]
					if not ring_find(aOrdered, cItem) > 0
						aOrdered + cItem
					ok
				next

				aUniqueValues = aOrdered
			ok

			nLenU = len(aUniqueValues)
			aResult = []

			for i = 1 to nLenU
				aResult + [[ aUniqueValues[i] ]]
			next

			return aResult
		ok

		# Handle multiple fields

		aAllCombos = []
		aFieldIndices = []

		# Get column indices

		for i = 1 to nLenFields
			nColIndex = @oSourceTable.FindCol(paFields[i])
			if nColIndex = 0
				StzRaise("Column not found: " + paFields[i])
			ok
			aFieldIndices + nColIndex
		next
		nLenFieldIndices = len(aFieldIndices)

		# Collect all combinations

		for r = 2 to nRows
			aCombination = []

			for i = 1 to nLenFieldIndices
				aCombination + @oSourceTable.Cell(aFieldIndices[i], r)
			next

			# Check for duplicates
			bExists = FALSE
			nLenCombos = len(aAllCombos)

			for i = 1 to nLenCombos
				if _arraysEqual(aAllCombos[i], aCombination)
					bExists = TRUE
					exit
				ok
			next

			if not bExists
				aAllCombos + aCombination
			ok
		next

		return aAllCombos

	def _arraysEqual(a1, a2)
		# Compare two arrays for equality
		if len(a1) != len(a2)
			return FALSE
		ok
		
		for i = 1 to len(a1)
			if a1[i] != a2[i]
				return FALSE
			ok
		next
		
		return TRUE

	def _createHeaderStructure(aColCombos)
		# Create header structure for pivot table
		aHeaders = []
		
		# Initialize first row with empty cells for row labels
		aFirstRow = []
		for i = 1 to len(@aRowLabels)
			aFirstRow + ""
		next
		
		# Add column combinations
		for combo in aColCombos
			aFirstRow + _combineLabels(combo)
		next
		
		if @bShowTotalColumn
			aFirstRow + @cTotalLabel
		ok
		
		aHeaders + aFirstRow
		
		return [aHeaders]

	def _combineLabels(aLabels)
		# Combine multiple labels with separator
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

	def _generateDataRows(aRowCombos, aColCombos)

		# Generate data rows for pivot table

		nLenRows = len(aRowCombos)
		nLenRowsLabels = len(@aRowLabels)

		for i = 1 to nLenRows

			rowCombo = aRowCombos[i]
			aRow = []
			aFlatRowCombo = _flattenArray(rowCombo)
			
			# Add row labels

			nLenFlat = len(aFlatRowCombo)

			for j = 1 to nLenFlat
				if j <= nLenRowsLabels
					aRow + aFlatRowCombo[j]
				ok
			next
			
			# Fill missing labels

			while len(aRow) < nLenRowsLabels
				aRow + ""
			end
			
			aRowValues = []
			
			# Add values for each column combination

			nLenCols = len(aColCombos)

			for j = 1 to nLenCols

				aFlatColCombo = _flattenArray(aColCombos[j])
				nCellValue = _calculateCellValueMulti(aFlatRowCombo, aFlatColCombo)
				aRow + nCellValue
				
				if @bShowTotalColumn and isNumber(nCellValue)
					aRowValues + nCellValue
				ok
			next
			
			# Add row total

			if @bShowTotalColumn
				nRowTotal = _applyAggregateFunction(aRowValues)
				aRow + nRowTotal
			ok
			
			@aPivotData + aRow
		next

	def _addTotalRow()
		# Add total row to pivot table
		aTotalRow = []
		nLenRows = len(@aRowLabels)

		# Add total label
		for i = 1 to nLenRows
			if i = 1
				aTotalRow + @cTotalLabel
			else
				aTotalRow + ""
			ok
		next
		
		# Calculate column totals
		nColCount = len(@aPivotData[1])
		nRowCount = len(@aPivotData)
		
		for c = nLenRows + 1 to nColCount
			aColValues = []
			
			# Collect column values

			for r = 2 to nRowCount
				if isNumber(@aPivotData[r][c])
					aColValues + @aPivotData[r][c]
				ok
			next
			
			# Apply aggregation
			nColTotal = _applyAggregateFunction(aColValues)
			aTotalRow + nColTotal
		next
		
		@aPivotData + aTotalRow

	def _calculateCellValueMulti(aRowValues, aColValues)

		# Calculate cell value for given row and column combinations
		aFlatRowValues = _flattenArray(aRowValues)
		aFlatColValues = _flattenArray(aColValues)

		nLenFlatRows = len(aFlatRowValues)
		nLenFlatCols = len(aFlatColValues)

		# Check cache
		cCacheKey = _getCacheKey(aFlatRowValues, aFlatColValues)
		if _checkCache(cCacheKey)
			return _getFromCache(cCacheKey)
		ok
		
		# Collect matching values
		aMatchingValues = []
		cValueField = @aValues[1]
		nValueColIndex = @oSourceTable.FindCol(cValueField)
		
		if nValueColIndex = 0
			stzRaise("Value column not found: " + cValueField)
		ok
		
		# Get indices for row and column fields
		aRowIndices = []
		nLenRows = len(@aRowLabels)

		for i = 1 to nLenRows

			nRowIndex = @oSourceTable.FindCol(@aRowLabels[i])

			if nRowIndex = 0
				stzRaise("Row column not found: " + @aRowLabels[i])
			ok

			aRowIndices + nRowIndex

		next
		
		aColIndices = []
		nLenCols = len(@aColLabels)

		for i = 1 to nLenCols 

			nColIndex = @oSourceTable.FindCol(@aColLabels[i])
			if nColIndex = 0
				stzRaise("Column not found: " + @aColLabels[i])
			ok
			aColIndices + nColIndex
		next
		
		# Process data rows
		nRowCount = @oSourceTable.NumberOfRows()
		
		for r = 2 to nRowCount
			bRowMatch = TRUE
			bColMatch = TRUE
			
			# Check row matches
			nLenRows = len(aRowIndices)

			for i = 1 to nLenRows

				if i <= nLenFlatRows

					if @oSourceTable.Cell(aRowIndices[i], r) != aFlatRowValues[i]
						bRowMatch = FALSE
						exit
					ok

				ok
			next
			
			if not bRowMatch
				loop
			ok
			
			# Check column matches
			for i = 1 to nLenCols

				if i <= nLenFlatRows

					if @oSourceTable.Cell(aColIndices[i], r) != aFlatColValues[i]
						bColMatch = FALSE
						exit
					ok

				ok

			next
			
			if not bColMatch
				loop
			ok
			
			# Add matching value
			value = @oSourceTable.Cell(nValueColIndex, r)
			aMatchingValues + value

		next
		
		# Apply aggregation and cache result
		result = _applyAggregateFunction(aMatchingValues)
		_addToCache(cCacheKey, result)
		
		return result

	  #---------------------#
	 #  CACHE MANAGEMENT   #
	#---------------------#

	def _getCacheKey(aRowValues, aColValues)
		# Generate cache key for cell values
		cKey = ""
		
		if isList(aRowValues) 
			if len(aRowValues) > 0 and isList(aRowValues[1])
				for subArr in aRowValues
					for value in subArr
						cKey += "R:" + value + ";"
					next
				next
			else
				for value in aRowValues
					cKey += "R:" + value + ";"
				next
			ok
		ok
		
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
		# Check if cache contains key
		for item in @aCellCache
			if item[1] = cKey
				return TRUE
			ok
		next
		return FALSE

	def _getFromCache(cKey)
		# Retrieve value from cache
		for item in @aCellCache
			if item[1] = cKey
				return item[2]
			ok
		next
		return NULL

	def _addToCache(cKey, value)
		# Add value to cache
		@aCellCache + [cKey, value]

	  #-----------------------------#
	 #  AGGREGATION FUNCTIONS      #
	#-----------------------------#
	
	def _applyAggregateFunction(aValues)
		# Apply configured aggregation function to values
		if len(aValues) = 0
			return @cCellNullValue
		ok

		switch lower(@cAggFunc)

			on "sum"

				nResult = 0
				nLen = len(aValues)

				for i = 1 to nLen
					nResult += aValues[i]
				next

				return nResult
				
			on "average"

				nResult = 0
				nLen = len(aValues)

				for i = 1 to nLen
					nResult += aValues[i]
				next

				return nResult / nLen
				
			on "count"
				return len(aValues)
				
			on "min"
				return Min(aValues)
				
			on "max"
				return Max(aValues)
				
			on "median"
				return Median(aValues)
				
			on "first"
				return aValues[1]
				
			on "last"
				return aValues[len(aValues)]
				
			other
				stzRaise("Unsupported aggregation function: " + @cAggFunc)
		off

	  #-----------------------------#
	 #  DATA ACCESS METHODS        #
	#-----------------------------#
	
	def _flattenArray(aArray)
		# Flatten nested arrays
		if not isList(aArray)
			return [aArray]
		ok
		
		if len(aArray) = 0
			return []
		ok
		
		if isList(aArray[1])
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
			return aArray
		ok

	def Value(paRowValues, paColValues)
		# Get value for specific row and column combination
		if not @bIsGenerated
			Generate()
		ok
		
		aFlatRowValues = _flattenArray(paRowValues)
		aFlatColValues = _flattenArray(paColValues)
		nLenFlatRows = len(aFlatRowValues)

		nLen = len(@aPivotData)
		nRowLabels = len(@aRowLabels)

		# Find row index
		nRowIndex = 0
		for r = 2 to nLen
			bMatch = TRUE
			
			for i = 1 to nLenFlatRows
				if i <= nRowLabels and @aPivotData[r][i] != aFlatRowValues[i]
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

		nLen1 = len(@aPivotData[1])

		for c =  nRowLabels+ 1 to nLen1
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
		# Get total for specific row
		if not @bIsGenerated
			Generate()
		ok
		
		if not @bShowTotalColumn
			return NULL
		ok
		
		aFlatRowValues = _flattenArray(paRowValues)
		nLenFlat = len(aFlatRowValues)

		nRowLabels = len(@aRowLabels)

		# Find row
		nRowIndex = 0
		nLen = len(@aPivotData)
		for r = 2 to nLen
			bMatch = TRUE
			
			for i = 1 to nLenFlat
				if i <= nRowLabels and @aPivotData[r][i] != aFlatRowValues[i]
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
		# Get total for specific column
		if not @bIsGenerated
			Generate()
		ok
		
		if not @bShowTotalRow
			return NULL
		ok
		
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
		# Get grand total
		if not @bIsGenerated
			Generate()
		ok
		
		if not (@bShowTotalRow and @bShowTotalColumn)
			return NULL
		ok
		
		return @aPivotData[len(@aPivotData)][len(@aPivotData[1])]

	  #-----------------------------#
	 #  SERIALIZATION METHODS      #
	#-----------------------------#
	
	def SaveToFile(cFileName)
		# Save pivot table configuration and data to file
		if not @bIsGenerated
			Generate()
		ok
		
		aSerializedData = [
			:RowLabels = @aRowLabels,
			:ColLabels = @aColLabels,
			:Values = @aValues,
			:AggregationFunction = @cAggFunc,
			:ShowTotalRow = @bShowTotalRow,
			:ShowTotalColumn = @bShowTotalColumn,
			:TotalLabel = @cTotalLabel,
			:CellNullValue = @cCellNullValue,
			:RowLabelsSeparator = @cRowLabelsSeparator,
			:PivotData = @aPivotData
		]
		
		write(cFileName, list2str(aSerializedData))

	def LoadFromFile(cFileName)
		# Load pivot table from file
		if not fexists(cFileName)
			stzRaise("File not found: " + cFileName)
		ok
		
		cContent = read(cFileName)
		aData = str2list(cContent)
		
		@aRowLabels = aData[:RowLabels]
		@aColLabels = aData[:ColLabels]
		@aValues = aData[:Values]
		@cAggFunc = aData[:AggregationFunction]
		@bShowTotalRow = aData[:ShowTotalRow]
		@bShowTotalColumn = aData[:ShowTotalColumn]
		@cTotalLabel = aData[:TotalLabel]
		@cCellNullValue = aData[:CellNullValue]
		@cRowLabelsSeparator = aData[:RowLabelsSeparator]
		@aPivotData = aData[:PivotData]
		
		# Create result table
		@oResultTable = new stzTable(@aPivotData)
		@bIsGenerated = TRUE


	  #=============================#
	 #  OUTPUT AND DISPLAY         #
	#=============================#

	# ToTable Method
	def ToTable()
		# Return pivot table as stzTable object
		if not @bIsGenerated
			Generate()
		ok
		return @oResultTable

	# Show Method

	def Show()
		# Display formatted pivot table
		if not @bIsGenerated
			Generate()
		ok

		if len(@aCollabels) = 1 and len(@aRowlabels) = 1
			_showFormattedPivotTable1D()
	
		but len(@aCollabels) = 1 and len(@aRowlabels) = 2
			_showFormattedPivotTable2DRows1DCols()  
	
		but len(@aCollabels) = 2 and len(@aRowlabels) = 1
			_showFormattedPivotTable1DRows2DCols()
	
		but len(@aCollabels) = 2 and len(@aRowlabels) = 2
			_showFormattedPivotTable2D()
	
		else
			StzRaise("Can't display the pivot table! Only 2D columns/rows or less are displayable.")
		ok

	def ShowXT(pbSubTotal, pbGrandTotal)
		# Display formatted pivot table
		if not @bIsGenerated
			Generate()
		ok

	
		if len(@aCollabels) = 2 and len(@aRowlabels) = 1
			_showFormattedPivotTable1DRows2DColsXT(pbSubTotal, pbGrandTotal)
	
		but len(@aCollabels) = 2 and len(@aRowlabels) = 2
			_showFormattedPivotTable2DXT(pbSubTotal, pbGrandTotal)
	
		else
			StzRaise("Can't display the pivot table! Only 2 column dimensions are displayable.")
		ok

	  #--------------------------#
	 #  1D Pivot Table Display  #
	#==========================#

	def _showFormattedPivotTable1D()
		# Display pivot table with formatted output - for 1D analysis (simpler format)

		aPivotData = @aPivotData
		aRowDims = @aRowLabels
		aColDims = @aColLabels
		cTotalLabel = @cTotalLabel

		# Initialize column tracking
		aRowLabelCols = []
		aDataCols = []
		nTotalColIndex = 0
	
		aHeaderRow = aPivotData[1]
	
		# Process row dimensions - for 1D we only have one
		aRowLabelCols + 1
	
		# Process data columns
		nHeaderLen = len(aHeaderRow)
		for i = 2 to nHeaderLen
			if aHeaderRow[i] = cTotalLabel
				nTotalColIndex = i
			else
				aDataCols + i
			ok
		next
	
		# Calculate row label width
		maxLabelWidth = len(aRowDims[1])
		nPivotLen = len(aPivotData)
		for r = 2 to nPivotLen - 1
			cellValue = "" + aPivotData[r][1]
			if len(cellValue) > maxLabelWidth
				maxLabelWidth = len(cellValue)
			ok
		next
		nRowLabelWidth = maxLabelWidth + 2
	
		# Calculate data column widths
		aDataColWidths = []
		nMinDataWidth = 10
		nDataColsLen = len(aDataCols)
	
		for i = 1 to nDataColsLen
			colIdx = aDataCols[i]
			maxWidth = len(aHeaderRow[colIdx])
		
			for r = 2 to nPivotLen
				if colIdx <= len(aPivotData[r])
					cellValue = "" + aPivotData[r][colIdx]
					if len(cellValue) > maxWidth
						maxWidth = len(cellValue)
					ok
				ok
			next
		
			aDataColWidths + max([nMinDataWidth, maxWidth + 2])
		next
	
		# Calculate total column width
		nTotalColWidth = len(cTotalLabel)
		for r = 2 to nPivotLen
			if nTotalColIndex <= len(aPivotData[r])
				cellValue = "" + aPivotData[r][nTotalColIndex]
				if len(cellValue) > nTotalColWidth
					nTotalColWidth = len(cellValue)
				ok
			ok
		next
		nTotalColWidth += 2
	
		# Calculate experience column width (sum of data column widths)
		nExpWidth = 0
		nDataColWidthsLen = len(aDataColWidths)
		for i = 1 to nDataColWidthsLen
			nExpWidth += aDataColWidths[i]
		next

		# Add separators length
		nExpWidth += nDataColsLen - 1
	
		# Build table output
		cOutput = ""
	
		# Top border
		cLine = @aBorder[:TopLeft] + StrFill(nRowLabelWidth, @aBorder[:Horizontal]) + @aBorder[:TeeDown]
	
		# Experience column group
		cLine += StrFill(nExpWidth, @aBorder[:Horizontal])
	
		# Total column
		cLine += @aBorder[:TeeDown] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:TopRight]
		cOutput += cLine + NL
	
		# Experience header row
		cLine = @aBorder[:Vertical]
	
		# Column for row dimension
		cLine += copy(" ", nRowLabelWidth) + @aBorder[:Vertical]

		# Experience header
		cLine += CenterText(Capitalize(aColDims[1]), nExpWidth) + @aBorder[:Vertical]
	
		# Median header
		cLine += copy(" ", nTotalColWidth) + @aBorder[:Vertical]
		cOutput += cLine + NL
	
		# Separator after Experience row
		cLine = @aBorder[:Vertical] + StrFill(nRowLabelWidth, " ") + @aBorder[:Vertical]
	
		# Sub-headers separator
		pos = 0
		for i = 1 to nDataColsLen
			cLine += StrFill(aDataColWidths[i], @aBorder[:Horizontal])
			pos += aDataColWidths[i]
		
			if i < nDataColsLen
				cLine += @aBorder[:TeeDown]
				pos += 1
			ok
		next
	
		cLine += @aBorder[:Vertical] + StrFill(nTotalColWidth, " ") + @aBorder[:Vertical]
		cOutput += cLine + NL
	
		# Sub-headers row
		cLine = @aBorder[:Vertical]
	
		# Empty cell for Department column
		cLine += CenterText(Capitalize(aRowDims[1]), nRowLabelWidth) + @aBorder[:Vertical]

		# Sub-headers for experience columns
		for i = 1 to nDataColsLen
			colIdx = aDataCols[i]
			colHeader = aHeaderRow[colIdx]
			oDim = StzStringQ(colHeader)
			capitalized = Upper(Left(colHeader, 1)) + oDim.Section(2, oDim.NumberOfChars())
			cLine += CenterText(capitalized, aDataColWidths[i])
		
			if i < nDataColsLen
				cLine += @aBorder[:Vertical]
			ok
		next
	
		# MEDIAN cell in this row
		cLine += @aBorder[:Vertical] + CenterText(Upper(cTotalLabel), nTotalColWidth) + @aBorder[:Vertical]
		cOutput += cLine + NL

		# Separator before data
		cLine = @aBorder[:TeeRight] + StrFill(nRowLabelWidth, @aBorder[:Horizontal]) + @aBorder[:Cross]
	
		for i = 1 to nDataColsLen
			cLine += StrFill(aDataColWidths[i], @aBorder[:Horizontal])
			if i < nDataColsLen
				cLine += @aBorder[:Cross]
			ok
		next
	
		cLine += @aBorder[:Cross] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:TeeLeft]
		cOutput += cLine + NL
	
		# Data rows
		for r = 2 to nPivotLen - 1
			cLine = @aBorder[:Vertical]
		
			# Row label
			rowValue = aPivotData[r][1]
			cLine += " " + rowValue + StrFill(nRowLabelWidth - len(rowValue) - 1, " ") + @aBorder[:Vertical]
		
			# Data cells
			for i = 1 to nDataColsLen
				colIdx = aDataCols[i]
				value = ""
				if colIdx <= len(aPivotData[r])
					value = aPivotData[r][colIdx]
				ok
			
				if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
					cLine += " " + PadLeft(value, aDataColWidths[i] - 2) + " "
				else
					cLine += " " + PadRight(value, aDataColWidths[i] - 2) + " "
				ok
			
				if i < nDataColsLen
					cLine += @aBorder[:Vertical]
				ok
			next
		
			# Total column
			totalValue = ""
			if nTotalColIndex <= len(aPivotData[r])
				totalValue = aPivotData[r][nTotalColIndex]
			ok

			if isNumber(totalValue) or (isString(totalValue) and totalValue != "" and isNumber(0 + value))
				cLine += @aBorder[:Vertical] + " " + PadLeft(totalValue, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			else
				cLine += @aBorder[:Vertical] + " " + PadRight(totalValue, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			ok
		
			cOutput += cLine + NL
		next
	
		# Check if there is a total row
		hasTotal = nPivotLen > 1 and aPivotData[nPivotLen][1] = cTotalLabel
		
		# Bottom border
		if hasTotal
			cLine = @aBorder[:BottomLeft] + StrFill(nRowLabelWidth, @aBorder[:Horizontal]) + @aBorder[:TeeUp]
		
			for i = 1 to nDataColsLen
				cLine += StrFill(aDataColWidths[i], @aBorder[:Horizontal])
				if i < nDataColsLen
					cLine += @aBorder[:TeeUp]
				ok
			next
		
			cLine += @aBorder[:TeeUp] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
			cOutput += cLine + NL

			# Total row
			totalRow = aPivotData[nPivotLen]
		
			cLine = "  " + PadLeft(Upper(totalRow[1]), nRowLabelWidth - 2) + " " + @aBorder[:Vertical]
		
			for i = 1 to nDataColsLen
				colIdx = aDataCols[i]
				value = ""
				if colIdx <= len(totalRow)
					value = totalRow[colIdx]
				ok
			
				if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
					cLine += " " + PadLeft(value, aDataColWidths[i] - 2) + " "
				else
					cLine += " " + PadRight(value, aDataColWidths[i] - 2) + " "
				ok
			
				if i < nDataColsLen
					cLine += @aBorder[:Vertical]
				ok
			next
		
			grandTotal = ""
			if nTotalColIndex <= len(totalRow)
				grandTotal = totalRow[nTotalColIndex]
			ok

			if isNumber(grandTotal) or (isString(grandTotal) and grandTotal != "" and isNumber(0 + grandTotal))
				cLine += @aBorder[:Vertical] + " " + PadLeft(grandTotal, nTotalColWidth - 2) + "  "
			else
				cLine += @aBorder[:Vertical] + " " + PadRight(grandTotal, nTotalColWidth - 2) + "  "
			ok
		
			cOutput += cLine + NL
		else
			# Bottom border if no total row
			cLine = @aBorder[:BottomLeft] + StrFill(nRowLabelWidth, @aBorder[:Horizontal]) + @aBorder[:TeeUp]
		
			for i = 1 to nDataColsLen
				cLine += StrFill(aDataColWidths[i], @aBorder[:Horizontal])
				if i < nDataColsLen
					cLine += @aBorder[:TeeUp]
				ok
			next
		
			cLine += @aBorder[:TeeUp] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
			cOutput += cLine
		ok
	
		? cOutput

	  #---------------------------#
	 #   2D Pivot Table Display  #
	#===========================#

	def _showFormattedPivotTable2D()
		# Display 2D pivot table with formatted output

		aPivotData = @aPivotData
		aRowDims = @aRowLabels
		aColDims = @aColLabels
		cTotalLabel = @cTotalLabel

		# Initialize column tracking
		aRowLabelCols = []
		aDataCols = []
		nTotalColIndex = 0
		
		aHeaderRow = aPivotData[1]
		
		# Process row dimensions
		nRowDimsLen = len(aRowDims)
		for i = 1 to nRowDimsLen
			aRowLabelCols + i
		next
		
		# Process data columns
		nHeaderLen = len(aHeaderRow)
		for i = nRowDimsLen + 1 to nHeaderLen
			if aHeaderRow[i] = cTotalLabel
				nTotalColIndex = i
			else
				aDataCols + i
			ok
		next
		
		# Parse column dimensions
		aColDim1Values = []
		aColDim2Values = []
		aColGroups = []
		
		nDataColsLen = len(aDataCols)
		for i = 1 to nDataColsLen
			colIdx = aDataCols[i]
			colHeader = aHeaderRow[colIdx]
			
			if colHeader != ""
				aParts = @split(colHeader, "_")
				dim1Value = aParts[1]
				dim2Value = aParts[2]
				
				if ring_find(aColDim1Values, dim1Value) = 0
					aColDim1Values + dim1Value
				ok
				
				if ring_find(aColDim2Values, dim2Value) = 0
					aColDim2Values + dim2Value
				ok
				
				key = dim1Value + "_" + dim2Value
				aColGroups[key] = colIdx
			ok
		next
		
		# Calculate row label widths
		aRowLabelWidths = []
		for i = 1 to nRowDimsLen
			maxWidth = len(aRowDims[i])
			nPivotLen = len(aPivotData)
			
			for r = 2 to nPivotLen - 1
				cellValue = "" + aPivotData[r][i]
				if len(cellValue) > maxWidth
					maxWidth = len(cellValue)
				ok
			next
			
			aRowLabelWidths + (maxWidth + 2)
		next
		
		# Calculate data column widths
		aDataColWidths = []
		nMinDataWidth = 10
		nColDim1ValuesLen = len(aColDim1Values)
		nColDim2ValuesLen = len(aColDim2Values)
		nPivotLen = len(aPivotData)
		
		for i1 = 1 to nColDim1ValuesLen
			dim1Value = aColDim1Values[i1]
			for i2 = 1 to nColDim2ValuesLen
				dim2Value = aColDim2Values[i2]
				key = dim1Value + "_" + dim2Value
				colIdx = aColGroups[key]
				
				if colIdx != NULL
					maxWidth = len(dim2Value)
					
					for r = 2 to nPivotLen
						if colIdx <= len(aPivotData[r])
							cellValue = "" + aPivotData[r][colIdx]
							if len(cellValue) > maxWidth
								maxWidth = len(cellValue)
							ok
						ok
					next
					
					aDataColWidths[key] = max([nMinDataWidth, maxWidth + 2])
				ok
			next
		next
		
		# Calculate total column width
		nTotalColWidth = len(cTotalLabel)
		
		for r = 2 to nPivotLen
			if nTotalColIndex <= len(aPivotData[r])
				cellValue = "" + aPivotData[r][nTotalColIndex]
				if len(cellValue) > nTotalColWidth
					nTotalColWidth = len(cellValue)
				ok
			ok
		next
		
		nTotalColWidth += 2
		
		# Calculate row label section width
		nRowLabelSectionWidth = 0
		nRowLabelWidthsLen = len(aRowLabelWidths)
		for i = 1 to nRowLabelWidthsLen
			nRowLabelSectionWidth += aRowLabelWidths[i]
		next
		nRowLabelSectionWidth += nRowDimsLen - 1
		
		# Build table output
		cOutput = ""
		
		# Top border
		cLine = @aBorder[:TopLeft]
		
		for i = 1 to nRowLabelWidthsLen
			cLine += StrFill(aRowLabelWidths[i], @aBorder[:Horizontal])
			if i < nRowLabelWidthsLen
				cLine += @aBorder[:Horizontal]
			ok
		next
		
		cLine += @aBorder[:TeeDown]
		
		# Calculate first dimension widths
		aDim1Widths = []
		for i1 = 1 to nColDim1ValuesLen
			dim1Value = aColDim1Values[i1]
			dim1Width = 0
			for i2 = 1 to nColDim2ValuesLen
				dim2Value = aColDim2Values[i2]
				key = dim1Value + "_" + dim2Value
				if aDataColWidths[key] != NULL
					dim1Width += aDataColWidths[key]
				ok
			next
			if nColDim2ValuesLen > 1
				dim1Width += nColDim2ValuesLen - 1
			ok
			aDim1Widths[dim1Value] = dim1Width
		next
		
		# Add dimension sections
		for i = 1 to nColDim1ValuesLen
			dim1Value = aColDim1Values[i]
			cLine += StrFill(aDim1Widths[dim1Value], @aBorder[:Horizontal])
			if i < nColDim1ValuesLen
				cLine += @aBorder[:TeeDown]
			ok
		next
		
		cLine += @aBorder[:TeeDown] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:TopRight]
		cOutput += cLine + NL
		
		# First header row
		cLine = @aBorder[:Vertical]
		
		for i = 1 to nRowLabelWidthsLen
			cLine += StrFill(aRowLabelWidths[i], " ")
			if i < nRowLabelWidthsLen
				cLine += " "
			ok
		next
		
		cLine += @aBorder[:Vertical]
		
		for i = 1 to nColDim1ValuesLen
			dim1Value = aColDim1Values[i]
			dim1Display = Upper(Left(dim1Value, 1)) + SubStr(dim1Value, 2)
			cLine += CenterText(dim1Display, aDim1Widths[dim1Value])
			
			if i < nColDim1ValuesLen
				cLine += @aBorder[:Vertical]
			ok
		next
		
		cLine += @aBorder[:Vertical] + StrFill(nTotalColWidth, " ") + @aBorder[:Vertical]
		cOutput += cLine + NL
		
		# Separator after first dimension
		cLine = @aBorder[:Vertical]
		
		for i = 1 to nRowLabelWidthsLen
			cLine += StrFill(aRowLabelWidths[i], " ")
		next
		
		cLine += " " + @aBorder[:Vertical]
		
		for i1 = 1 to nColDim1ValuesLen
			dim1Value = aColDim1Values[i1]
			for i2 = 1 to nColDim2ValuesLen
				dim2Value = aColDim2Values[i2]
				key = dim1Value + "_" + dim2Value
				if aDataColWidths[key] != NULL
					dim2Width = aDataColWidths[key]
					cLine += StrFill(dim2Width, @aBorder[:Horizontal])
					
					if i2 < nColDim2ValuesLen
						cLine += @aBorder[:TeeDown]
					ok
				ok
			next
			
			if i1 < nColDim1ValuesLen
				cLine += @aBorder[:Cross]
			ok
		next
		
		cLine += @aBorder[:Vertical] + StrFill(nTotalColWidth," ") + @aBorder[:Vertical]
		cOutput += cLine + NL
		
		# Second dimension header
		cLine = @aBorder[:Vertical]
		
		for i = 1 to nRowDimsLen
			dim = aRowDims[i]
			oDim = StzStringQ(dim)
			capitalized = Upper(Left(dim, 1)) + oDim.Section(2, oDim.NumberOfChars())
			cLine += CenterText(capitalized, aRowLabelWidths[i])
			
			if i < nRowDimsLen
				cLine += @aBorder[:Vertical]
			ok
		next
		
		cLine += @aBorder[:Vertical]
		
		for i1 = 1 to nColDim1ValuesLen
			dim1Value = aColDim1Values[i1]

			for i2 = 1 to nColDim2ValuesLen
				dim2Value = aColDim2Values[i2]

				key = dim1Value + "_" + dim2Value
				if aDataColWidths[key] != NULL
					oDim2 = new stzString(dim2Value)
					capitalizedDim2 = Upper(Left(dim2Value, 1)) + oDim2.Section(2, oDim2.NumberOfChars())
					cLine += CenterText(capitalizedDim2, aDataColWidths[key])
					
					if i2 < nColDim2ValuesLen
						cLine += @aBorder[:Vertical]
					ok
				ok
			next
			
			if i1 < nColDim1ValuesLen
				cLine += @aBorder[:Vertical]
			ok
		next
		
		cLine += @aBorder[:Vertical] + CenterText(Upper(cTotalLabel), nTotalColWidth) + @aBorder[:Vertical]
		cOutput += cLine + NL
		
		# Separator before data
		cLine = @aBorder[:TeeRight]
		
		for i = 1 to nRowLabelWidthsLen
			cLine += StrFill(aRowLabelWidths[i], @aBorder[:Horizontal])

			if i < nRowLabelWidthsLen
				cLine += @aBorder[:TeeDown]
			ok
		next
		
		cLine += @aBorder[:Cross]
		
		for i1 = 1 to nColDim1ValuesLen
			dim1Value = aColDim1Values[i1]

			for i2 = 1 to nColDim2ValuesLen
				dim2Value = aColDim2Values[i2]

				key = dim1Value + "_" + dim2Value

				if aDataColWidths[key] != NULL
					cLine += StrFill(aDataColWidths[key], @aBorder[:Horizontal])
					
					if i2 < nColDim2ValuesLen
						cLine += @aBorder[:Cross]
					ok
				ok
			next
			
			if i1 < nColDim1ValuesLen
				cLine += @aBorder[:Cross]
			ok
		next
		
		cLine += @aBorder[:Cross] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:TeeLeft]
		cOutput += cLine + NL
		
		# Data rows
		cLastRowDim1 = NULL
		nRowDim1Count = 0
		
		for r = 2 to nPivotLen - 1
			cCurrentRowDim1 = aPivotData[r][1]
			
			if cCurrentRowDim1 != cLastRowDim1
				nRowDim1Count++
				cLastRowDim1 = cCurrentRowDim1
			ok
			
			cLine = @aBorder[:Vertical]
			
			# First dimension
			if cCurrentRowDim1 != aPivotData[r-1][1] or r = 2
				cLine += " " + cCurrentRowDim1 + StrFill(aRowLabelWidths[1] - len(cCurrentRowDim1) - 1, " ")
			else
				cLine += StrFill(aRowLabelWidths[1], " ")
			ok
			
			cLine += @aBorder[:Vertical]
			
			# Second dimension
			cLine += " " + aPivotData[r][2] + StrFill(aRowLabelWidths[2] - len(aPivotData[r][2]) - 1, " ")
			cLine += @aBorder[:Vertical]
			
			# Data cells
			for i1 = 1 to nColDim1ValuesLen
				dim1Value = aColDim1Values[i1]

				for i2 = 1 to nColDim2ValuesLen
					dim2Value = aColDim2Values[i2]

					key = dim1Value + "_" + dim2Value
					colIdx = aColGroups[key]
					
					if colIdx != NULL
						value = @if(colIdx <= len(aPivotData[r]), aPivotData[r][colIdx], "")
						
						if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
							cLine += " " + PadLeft(value, aDataColWidths[key] - 2) + " "
						else
							cLine += " " + PadRight(value, aDataColWidths[key] - 2) + " "
						ok
						
						if i2 < nColDim2ValuesLen
							cLine += @aBorder[:Vertical]
						ok
					ok
				next
				
				if i1 < nColDim1ValuesLen
					cLine += @aBorder[:Vertical]
				ok
			next
			
			# Total column
			totalValue = @if(nTotalColIndex <= len(aPivotData[r]), aPivotData[r][nTotalColIndex], "")
			
			if isNumber(totalValue) or (isString(totalValue) and totalValue != "" and isNumber(0 + value))
				cLine += @aBorder[:Vertical] + " " + PadLeft(totalValue, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			else
				cLine += @aBorder[:Vertical] + " " + PadRight(totalValue, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			ok
			
			cOutput += cLine + NL
			
			# Add empty line between categories
			if r < nPivotLen - 1 and cCurrentRowDim1 != aPivotData[r+1][1] and aPivotData[r+1][1] != cTotalLabel
				cLine = @aBorder[:Vertical]
				cLine += StrFill(aRowLabelWidths[1], " ") + @aBorder[:Vertical]
				cLine += StrFill(aRowLabelWidths[2], " ") + @aBorder[:Vertical]
				
				for i1 = 1 to nColDim1ValuesLen
					dim1Value = aColDim1Values[i1]

					for i2 = 1 to nColDim2ValuesLen
						dim2Value = aColDim2Values[i2]

						key = dim1Value + "_" + dim2Value

						if aDataColWidths[key] != NULL
							cLine += StrFill(aDataColWidths[key], " ")
							
							if i2 < nColDim2ValuesLen
								cLine += @aBorder[:Vertical]
							ok
						ok
					next
					
					if i1 < nColDim1ValuesLen
						cLine += @aBorder[:Vertical]
					ok
				next
				
				cLine += @aBorder[:Vertical] + StrFill(nTotalColWidth, " ") + @aBorder[:Vertical]
				cOutput += cLine + NL
			ok
		next
		
		# Bottom border
		cLine = @aBorder[:BottomLeft]
		
		for i = 1 to nRowLabelWidthsLen
			cLine += StrFill(aRowLabelWidths[i], @aBorder[:Horizontal])

			if i = 1
				cLine += @aBorder[:TeeUp]
			but i < nRowLabelWidthsLen
				cLine += @aBorder[:Cross]
			ok
		next
		
		cLine += @aBorder[:TeeUp]
		
		for i1 = 1 to nColDim1ValuesLen
			dim1Value = aColDim1Values[i1]

			for i2 = 1 to nColDim2ValuesLen
				dim2Value = aColDim2Values[i2]

				key = dim1Value + "_" + dim2Value

				if aDataColWidths[key] != NULL
					cLine += StrFill(aDataColWidths[key], @aBorder[:Horizontal])
					
					if i2 < nColDim2ValuesLen
						cLine += @aBorder[:TeeUp]
					ok
				ok
			next
			
			if i1 < nColDim1ValuesLen
				cLine += @aBorder[:TeeUp]
			ok
		next
		
		cLine += @aBorder[:TeeUp] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
		cOutput += cLine + NL
		
		# Totals row

		if nPivotLen > 1 and aPivotData[nPivotLen][1] = cTotalLabel
			totalRow = aPivotData[nPivotLen]
			nLenTotalRow = len(totalRow)

			cLine = " " + PadLeft(Upper(totalRow[1]+" "), nRowLabelSectionWidth) + @aBorder[:Vertical]
			
			for i1 = 1 to nColDim1ValuesLen
				dim1Value = aColDim1Values[i1]

				for i2 = 1 to nColDim2ValuesLen
					dim2Value = aColDim2Values[i2]

					key = dim1Value + "_" + dim2Value
					colIdx = aColGroups[key]
					
					if colIdx != NULL

						value = @if(colIdx <= nLenTotalRow, totalRow[colIdx], "")
						
						if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
							cLine += " " + PadLeft(value, aDataColWidths[key] - 2) + " "
						else
							cLine += " " + PadRight(value, aDataColWidths[key] - 2) + " "
						ok
						
						if dim2Value != aColDim2Values[nColDim2ValuesLen]
							cLine += @aBorder[:Vertical]
						ok
					ok

				next
				
				if dim1Value != aColDim1Values[nColDim1ValuesLen]
					cLine += @aBorder[:Vertical]
				ok

			next
		
			grandTotal = @if(nTotalColIndex <= nLenTotalRow, totalRow[nTotalColIndex], "")
			
			if isNumber(grandTotal) or (isString(grandTotal) and grandTotal != "" and isNumber(0 + grandTotal))
				cLine += @aBorder[:Vertical] + " " + PadLeft(grandTotal, nTotalColWidth - 2) + " " + @aBorder[:Vertical]

			else
				cLine += @aBorder[:Vertical] + " " + PadRight(grandTotal, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			ok
			
			cOutput += cLine
		ok

		? StzStringQ(trim(cOutput)).LastCharRemoved() + NL

	#-------------------------------------#
	#  2D PIVOT TABLE DISPLAY - eXTended  #
	#-------------------------------------#

def _showFormattedPivotTable2DXT(pSubTotal, pGrandTotal)
	if CheckParams()

		if isList(pSubTotal) and StzListQ(pSubTotal).IsSubTotalNamedParam()
			pSubTotal = pSubTotal[2]
		ok

		if isList(pGrandTotal) and StzListQ(pGrandTotal).IsGrandTotalNamedParam()
			pGrandTotal = pGrandTotal[2]
		ok

		if NOT (isBoolean(pSubTotal) and isBoolean(pGrandTotal))
			StzRaise("Incorrect param values! pSubTotal and pGrandTotal must be both booleans.")
		ok
	ok

	aPivotData = @aPivotData
	aRowDims = @aRowLabels
	aColDims = @aColLabels
	cTotalLabel = @cTotalLabel

	# Initialize column tracking
	aRowLabelCols = []
	aDataCols = []
	nTotalColIndex = 0
	
	aHeaderRow = aPivotData[1]
	
	# Process row dimensions
	nRowDimsLen = len(aRowDims)
	for i = 1 to nRowDimsLen
		aRowLabelCols + i
	next
	
	# Process data columns
	nHeaderLen = len(aHeaderRow)
	for i = nRowDimsLen + 1 to nHeaderLen
		if aHeaderRow[i] = cTotalLabel
			nTotalColIndex = i
		else
			aDataCols + i
		ok
	next
	
	# Parse column dimensions
	aColDim1Values = []
	aColDim2Values = []
	aColGroups = []
	
	nDataColsLen = len(aDataCols)
	for i = 1 to nDataColsLen
		colIdx = aDataCols[i]
		colHeader = aHeaderRow[colIdx]
		
		if colHeader != ""
			aParts = @split(colHeader, "_")
			dim1Value = aParts[1]
			dim2Value = aParts[2]
			
			if ring_find(aColDim1Values, dim1Value) = 0
				aColDim1Values + dim1Value
			ok
			
			if ring_find(aColDim2Values, dim2Value) = 0
				aColDim2Values + dim2Value
			ok
			
			key = dim1Value + "_" + dim2Value
			aColGroups[key] = colIdx
		ok
	next
	
	# Calculate row label widths
	aRowLabelWidths = []
	for i = 1 to nRowDimsLen
		maxWidth = len(aRowDims[i])
		nPivotLen = len(aPivotData)
		
		# Account for "Sub-total" text if needed
		if pSubTotal and i = 1
			if maxWidth < len("Sub-total")
				maxWidth = len("Sub-total")
			ok
		ok
		
		# Account for "GRAND-TOTAL" text if needed
		if pGrandTotal and i = 1
			if maxWidth < len("GRAND-TOTAL")
				maxWidth = len("GRAND-TOTAL")
			ok
		ok
		
		for r = 2 to nPivotLen - 1
			cellValue = "" + aPivotData[r][i]
			if len(cellValue) > maxWidth
				maxWidth = len(cellValue)
			ok
		next
		
		aRowLabelWidths + (maxWidth + 2)
	next
	
	# Calculate data column widths
	aDataColWidths = []
	nMinDataWidth = 10
	nColDim1ValuesLen = len(aColDim1Values)
	nColDim2ValuesLen = len(aColDim2Values)
	nPivotLen = len(aPivotData)
	
	for i1 = 1 to nColDim1ValuesLen
		dim1Value = aColDim1Values[i1]
		for i2 = 1 to nColDim2ValuesLen
			dim2Value = aColDim2Values[i2]
			key = dim1Value + "_" + dim2Value
			colIdx = aColGroups[key]
			
			if colIdx != NULL
				maxWidth = len(dim2Value)
				
				for r = 2 to nPivotLen
					if colIdx <= len(aPivotData[r])
						cellValue = "" + aPivotData[r][colIdx]
						if len(cellValue) > maxWidth
							maxWidth = len(cellValue)
						ok
					ok
				next
				
				aDataColWidths[key] = max([nMinDataWidth, maxWidth + 2])
			ok
		next
	next
	
	# Calculate total column width
	nTotalColWidth = len(cTotalLabel)
	
	for r = 2 to nPivotLen
		if nTotalColIndex <= len(aPivotData[r])
			cellValue = "" + aPivotData[r][nTotalColIndex]
			if len(cellValue) > nTotalColWidth
				nTotalColWidth = len(cellValue)
			ok
		ok
	next
	
	nTotalColWidth += 2
	
	# Calculate row label section width
	nRowLabelSectionWidth = 0
	nRowLabelWidthsLen = len(aRowLabelWidths)
	for i = 1 to nRowLabelWidthsLen
		nRowLabelSectionWidth += aRowLabelWidths[i]
	next
	nRowLabelSectionWidth += nRowDimsLen - 1
	
	# Initialize totals tracking for subtotals and grand totals
	aGroupTotals = []
	aGrandTotals = []
	
	# Initialize grand totals
	for i = 1 to nColDim1ValuesLen
		dim1Value = aColDim1Values[i]
		for i2 = 1 to nColDim2ValuesLen
			dim2Value = aColDim2Values[i2]
			key = dim1Value + "_" + dim2Value
			aGrandTotals[key] = 0
		next
	next
	
	# Add grand total for the total column
	aGrandTotals["total"] = 0
	
	# First pass: calculate subtotals and grand totals
	if pSubTotal or pGrandTotal
		cCurrentGroup = ""
		aGroups = []
		
		for r = 2 to nPivotLen - 1
			cGroup = "" + aPivotData[r][1]
			
			# Add to group list if new
			if NOT ring_find(aGroups, cGroup) > 0
				aGroups + cGroup
				aGroupTotals[cGroup] = []
				
				# Initialize group totals for each column combination
				for i1 = 1 to nColDim1ValuesLen
					dim1Value = aColDim1Values[i1]
					for i2 = 1 to nColDim2ValuesLen
						dim2Value = aColDim2Values[i2]
						key = dim1Value + "_" + dim2Value
						aGroupTotals[cGroup][key] = 0
					next
				next
				
				# Initialize group total for the total column
				aGroupTotals[cGroup]["total"] = 0
			ok
			
			# Update totals for each data column
			for i1 = 1 to nColDim1ValuesLen
				dim1Value = aColDim1Values[i1]
				for i2 = 1 to nColDim2ValuesLen
					dim2Value = aColDim2Values[i2]
					key = dim1Value + "_" + dim2Value
					colIdx = aColGroups[key]
					
					if colIdx != NULL and colIdx <= len(aPivotData[r])
						cellValue = aPivotData[r][colIdx]
						
						if isNumber(cellValue) or (isString(cellValue) and cellValue != "" and @IsNumberInString(cellValue))
							# Update group total
							aGroupTotals[cGroup][key] += (0 + cellValue)
							
							# Update grand total
							aGrandTotals[key] += (0 + cellValue)
						ok
					ok
				next
			next
			
			# Update totals for the total column
			if nTotalColIndex <= len(aPivotData[r])
				totalValue = aPivotData[r][nTotalColIndex]
				
				if isNumber(totalValue) or (isString(totalValue) and totalValue != "" and @IsNumberInString(totalValue))
					# Update group total
					aGroupTotals[cGroup]["total"] += (0 + totalValue)
					
					# Update grand total
					aGrandTotals["total"] += (0 + totalValue)
				ok
			ok
		next
	ok
	
	# Build table output
	cOutput = ""
	
	# Top border
	cLine = @aBorder[:TopLeft] + @aBorder[:Horizontal]
	
	for i = 1 to nRowLabelWidthsLen
		cLine += StrFill(aRowLabelWidths[i], @aBorder[:Horizontal])
		if i > 1 and i < nRowLabelWidthsLen
			cLine += @aBorder[:TeeDown]
		ok
	next
	
	cLine += @aBorder[:TeeDown]
	
	# Calculate first dimension widths
	aDim1Widths = []
	for i1 = 1 to nColDim1ValuesLen
		dim1Value = aColDim1Values[i1]
		dim1Width = 0
		for i2 = 1 to nColDim2ValuesLen
			dim2Value = aColDim2Values[i2]
			key = dim1Value + "_" + dim2Value
			if aDataColWidths[key] != NULL
				dim1Width += aDataColWidths[key]
			ok
		next
		if nColDim2ValuesLen > 1
			dim1Width += nColDim2ValuesLen - 1
		ok
		aDim1Widths[dim1Value] = dim1Width
	next
	
	# Add dimension sections
	for i = 1 to nColDim1ValuesLen
		dim1Value = aColDim1Values[i]
		cLine += StrFill(aDim1Widths[dim1Value], @aBorder[:Horizontal])
		if i < nColDim1ValuesLen
			cLine += @aBorder[:TeeDown]
		ok
	next
	
	cLine += @aBorder[:TeeDown] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:TopRight]
	cOutput += cLine + NL
	
	# First header row
	cLine = @aBorder[:Vertical]
	
	for i = 1 to nRowLabelWidthsLen
		cLine += StrFill(aRowLabelWidths[i], " ")
		if i < nRowLabelWidthsLen
			cLine += " "
		ok
	next
	
	cLine += @aBorder[:Vertical]
	
	for i = 1 to nColDim1ValuesLen
		dim1Value = aColDim1Values[i]
		dim1Display = Upper(Left(dim1Value, 1)) + SubStr(dim1Value, 2)
		cLine += CenterText(dim1Display, aDim1Widths[dim1Value])
		
		if i < nColDim1ValuesLen
			cLine += @aBorder[:Vertical]
		ok
	next
	
	cLine += @aBorder[:Vertical] + StrFill(nTotalColWidth, " ") + @aBorder[:Vertical]
	cOutput += cLine + NL
	
	# Separator after first dimension
	cLine = @aBorder[:Vertical]
	
	for i = 1 to nRowLabelWidthsLen
		cLine += StrFill(aRowLabelWidths[i], " ")
	next
	
	cLine += " " + @aBorder[:Vertical]
	
	for i1 = 1 to nColDim1ValuesLen
		dim1Value = aColDim1Values[i1]
		for i2 = 1 to nColDim2ValuesLen
			dim2Value = aColDim2Values[i2]
			key = dim1Value + "_" + dim2Value
			if aDataColWidths[key] != NULL
				dim2Width = aDataColWidths[key]
				cLine += StrFill(dim2Width, @aBorder[:Horizontal])
				
				if i2 < nColDim2ValuesLen
					cLine += @aBorder[:TeeDown]
				ok
			ok
		next
		
		if i1 < nColDim1ValuesLen
			cLine += @aBorder[:Cross]
		ok
	next
	
	cLine += @aBorder[:Vertical] + StrFill(nTotalColWidth," ") + @aBorder[:Vertical]
	cOutput += cLine + NL
	
	# Second dimension header
	cLine = @aBorder[:Vertical]
	
	for i = 1 to nRowDimsLen
		dim = aRowDims[i]
		oDim = StzStringQ(dim)
		capitalized = Upper(Left(dim, 1)) + oDim.Section(2, oDim.NumberOfChars())
		cLine += CenterText(capitalized, aRowLabelWidths[i])
		
		if i < nRowDimsLen
			cLine += @aBorder[:Vertical]
		ok
	next
	
	cLine += @aBorder[:Vertical]
	
	for i1 = 1 to nColDim1ValuesLen
		dim1Value = aColDim1Values[i1]

		for i2 = 1 to nColDim2ValuesLen
			dim2Value = aColDim2Values[i2]

			key = dim1Value + "_" + dim2Value
			if aDataColWidths[key] != NULL
				oDim2 = new stzString(dim2Value)
				capitalizedDim2 = Upper(Left(dim2Value, 1)) + oDim2.Section(2, oDim2.NumberOfChars())
				cLine += CenterText(capitalizedDim2, aDataColWidths[key])
				
				if i2 < nColDim2ValuesLen
					cLine += @aBorder[:Vertical]
				ok
			ok
		next
		
		if i1 < nColDim1ValuesLen
			cLine += @aBorder[:Vertical]
		ok
	next
	
	cLine += @aBorder[:Vertical] + CenterText(Upper(cTotalLabel), nTotalColWidth) + @aBorder[:Vertical]
	cOutput += cLine + NL
	
	# Separator before data
	cLine = @aBorder[:TeeRight]
	
	for i = 1 to nRowLabelWidthsLen
		cLine += StrFill(aRowLabelWidths[i], @aBorder[:Horizontal])

		if i < nRowLabelWidthsLen
			cLine += @aBorder[:TeeDown]
		ok
	next
	
	cLine += @aBorder[:Cross]
	
	for i1 = 1 to nColDim1ValuesLen
		dim1Value = aColDim1Values[i1]

		for i2 = 1 to nColDim2ValuesLen
			dim2Value = aColDim2Values[i2]

			key = dim1Value + "_" + dim2Value

			if aDataColWidths[key] != NULL
				cLine += StrFill(aDataColWidths[key], @aBorder[:Horizontal])
				
				if i2 < nColDim2ValuesLen
					cLine += @aBorder[:Cross]
				ok
			ok
		next
		
		if i1 < nColDim1ValuesLen
			cLine += @aBorder[:Cross]
		ok
	next
	
	cLine += @aBorder[:Cross] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:TeeLeft]
	cOutput += cLine + NL
	
	# Data rows
	cLastRowDim1 = NULL
	nRowDim1Count = 0
	
	for r = 2 to nPivotLen - 1
		cCurrentRowDim1 = aPivotData[r][1]
		
		# If group changed and not first row, print group totals
		
		if cCurrentRowDim1 != cLastRowDim1
			nRowDim1Count++
			cLastRowDim1 = cCurrentRowDim1
		ok
		
		cLine = @aBorder[:Vertical]
		
		# First dimension
		if cCurrentRowDim1 != aPivotData[r-1][1] or r = 2
			cLine += " " + cCurrentRowDim1 + StrFill(aRowLabelWidths[1] - len(cCurrentRowDim1) - 1, " ")
		else
			cLine += StrFill(aRowLabelWidths[1], " ")
		ok
		
		cLine += @aBorder[:Vertical]
		
		# Second dimension
		cLine += " " + aPivotData[r][2] + StrFill(aRowLabelWidths[2] - len(aPivotData[r][2]) - 1, " ")
		cLine += @aBorder[:Vertical]
		
		# Data cells
		for i1 = 1 to nColDim1ValuesLen
			dim1Value = aColDim1Values[i1]

			for i2 = 1 to nColDim2ValuesLen
				dim2Value = aColDim2Values[i2]

				key = dim1Value + "_" + dim2Value
				colIdx = aColGroups[key]
				
				if colIdx != NULL
					value = @if(colIdx <= len(aPivotData[r]), aPivotData[r][colIdx], "")
					
					if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
						cLine += " " + PadLeft(value, aDataColWidths[key] - 2) + " "
					else
						cLine += " " + PadRight(value, aDataColWidths[key] - 2) + " "
					ok
					
					if i2 < nColDim2ValuesLen
						cLine += @aBorder[:Vertical]
					ok
				ok
			next
			
			if i1 < nColDim1ValuesLen
				cLine += @aBorder[:Vertical]
			ok
		next
		
		# Total column
		totalValue = @if(nTotalColIndex <= len(aPivotData[r]), aPivotData[r][nTotalColIndex], "")
		
		if isNumber(totalValue) or (isString(totalValue) and totalValue != "" and isNumber(0 + totalValue))
			cLine += @aBorder[:Vertical] + " " + PadLeft(totalValue, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
		else
			cLine += @aBorder[:Vertical] + " " + PadRight(totalValue, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
		ok
		
		cOutput += cLine + NL
		
		# Add SUM row for each group, including the last one
		if (r < nPivotLen - 1 and cCurrentRowDim1 != aPivotData[r+1][1] and aPivotData[r+1][1] != cTotalLabel) or r = nPivotLen - 1
			cLine = @aBorder[:Vertical]
			cLine += StrFill(aRowLabelWidths[1], " ") + @aBorder[:Vertical]
			cLine += StrFill(aRowLabelWidths[2], " ") + @aBorder[:Vertical]
			
			# Add dashes for data columns
			for i1 = 1 to nColDim1ValuesLen
				dim1Value = aColDim1Values[i1]

				for i2 = 1 to nColDim2ValuesLen
					dim2Value = aColDim2Values[i2]

					key = dim1Value + "_" + dim2Value

					if aDataColWidths[key] != NULL
						cLine += " " + @Copy("-", aDataColWidths[key] - 2) + " "
						
						if i2 < nColDim2ValuesLen
							cLine += @aBorder[:Vertical]
						ok
					ok
				next
				
				if i1 < nColDim1ValuesLen
					cLine += @aBorder[:Vertical]
				ok
			next
			
			cLine += @aBorder[:Vertical] + " " + @Copy("-", nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			cOutput += cLine + NL
			
			# Add SUM row
			cLine = @aBorder[:Vertical]
			
			# First column
			cLine += " " + PadLeft("SUM", aRowLabelWidths[1] - 2) + " " + @aBorder[:Vertical]
			
			# Second column empty but right-aligned
			cLine += " " + PadRight("", aRowLabelWidths[2] - 2) + " " + @aBorder[:Vertical]
			
			# Add subtotal values for each data column
			for i1 = 1 to nColDim1ValuesLen
				dim1Value = aColDim1Values[i1]

				for i2 = 1 to nColDim2ValuesLen
					dim2Value = aColDim2Values[i2]

					key = dim1Value + "_" + dim2Value
					
					if aDataColWidths[key] != NULL
						value = aGroupTotals[cCurrentRowDim1][key]
						
						if isNumber(value) and value != 0
							cLine += " " + PadLeft("" + value, aDataColWidths[key] - 2) + " "
						else
							cLine += " " + PadLeft("", aDataColWidths[key] - 2) + " "
						ok
						
						if i2 < nColDim2ValuesLen
							cLine += @aBorder[:Vertical]
						ok
					ok
				next
				
				if i1 < nColDim1ValuesLen
					cLine += @aBorder[:Vertical]
				ok
			next
			
			# Add subtotal for total column
			value = aGroupTotals[cCurrentRowDim1]["total"]
			
			if isNumber(value) and value != 0
				cLine += @aBorder[:Vertical] + " " + PadLeft("" + value, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			else
				cLine += @aBorder[:Vertical] + " " + PadLeft("", nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			ok
			
			cOutput += cLine + NL
			
			# Add empty line after subtotals

			cLine = @aBorder[:Vertical]
			cLine += StrFill(aRowLabelWidths[1]+1, " ") //+ @aBorder[:Vertical]
			cLine += StrFill(aRowLabelWidths[2]+1, " ") //+ @aBorder[:Vertical]
			
			for i1 = 1 to nColDim1ValuesLen
				dim1Value = aColDim1Values[i1]

				for i2 = 1 to nColDim2ValuesLen
					dim2Value = aColDim2Values[i2]

					key = dim1Value + "_" + dim2Value

					if aDataColWidths[key] != NULL
						cLine += StrFill(aDataColWidths[key], " ")
						
					ok
				next
				
			next
			
			cLine += "  " + StrFill(nTotalColWidth+2, " ") + @aBorder[:Vertical]
			cOutput += cLine + NL

		ok
	next
	
	# Bottom border
	cLine = @aBorder[:BottomLeft]
	
	for i = 1 to nRowLabelWidthsLen
		cLine += StrFill(aRowLabelWidths[i], @aBorder[:Horizontal])

		if i = 1
			cLine += @aBorder[:Horizontal]
		but i < nRowLabelWidthsLen
			cLine += @aBorder[:Cross]
		ok
	next
	
	cLine += @aBorder[:Horizontal]
	
	for i1 = 1 to nColDim1ValuesLen
		dim1Value = aColDim1Values[i1]

		for i2 = 1 to nColDim2ValuesLen
			dim2Value = aColDim2Values[i2]

			key = dim1Value + "_" + dim2Value

			if aDataColWidths[key] != NULL
				cLine += StrFill(aDataColWidths[key], @aBorder[:Horizontal])
				
				if i2 < nColDim2ValuesLen
					cLine += @aBorder[:Horizontal]
				ok
			ok
		next
		
		if i1 < nColDim1ValuesLen
			cLine += @aBorder[:Horizontal]
		ok
	next
	
	cLine += @aBorder[:Horizontal] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
	cOutput += cLine + NL
	
	# Totals row
	if nPivotLen > 1 and aPivotData[nPivotLen][1] = cTotalLabel
		totalRow = aPivotData[nPivotLen]
		nLenTotalRow = len(totalRow)

		cLine = " " + PadLeft(Upper(totalRow[1]+" "), nRowLabelSectionWidth) + @aBorder[:Vertical]
		
		for i1 = 1 to nColDim1ValuesLen
			dim1Value = aColDim1Values[i1]

			for i2 = 1 to nColDim2ValuesLen
				dim2Value = aColDim2Values[i2]

				key = dim1Value + "_" + dim2Value
				colIdx = aColGroups[key]
				
				if colIdx != NULL
					value = @if(colIdx <= nLenTotalRow, totalRow[colIdx], "")
					
					if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
						cLine += " " + PadLeft(value, aDataColWidths[key] - 2) + " "
					else
						cLine += " " + PadRight(value, aDataColWidths[key] - 2) + " "
					ok
					
					if dim2Value != aColDim2Values[nColDim2ValuesLen]
						cLine += @aBorder[:Vertical]
					ok
				ok
			next
			
			if dim1Value != aColDim1Values[nColDim1ValuesLen]
				cLine += @aBorder[:Vertical]
			ok
		next
	
		grandTotal = @if(nTotalColIndex <= nLenTotalRow, totalRow[nTotalColIndex], "")
		
		if isNumber(grandTotal) or (isString(grandTotal) and grandTotal != "" and isNumber(0 + grandTotal))
			cLine += @aBorder[:Vertical] + " " + PadLeft(grandTotal, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
		else
			cLine += @aBorder[:Vertical] + " " + PadRight(grandTotal, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
		ok
		
		cOutput += cLine
	ok

	? StzStringQ(trim(cOutput)).LastCharRemoved() + NL

	  #------------------------------------------#
	 #  1D Rows 2D Columns Pivot Table Display  #
	#==========================================#

	def _showFormattedPivotTable1DRows2DCols()
		# Display pivot table with 1D rows and 2D columns with formatted output

		aPivotData = @aPivotData
		aRowDims = @aRowLabels
		aColDims = @aColLabels
		cTotalLabel = @cTotalLabel

		# Initialize column tracking

		aRowLabelCols = []
		aDataCols = []
		nTotalColIndex = 0
	
		aHeaderRow = aPivotData[1]
	
		# Process row dimensions - only use the first row dimension

		aRowLabelCols = aRowLabelCols + 1  # We only use the first row dimension
	
		# Process data columns
		nHeaderLen = len(aHeaderRow)
		for i = 2 to nHeaderLen  # Start from 2 since we only have 1 row dimension

			if aHeaderRow[i] = cTotalLabel
				nTotalColIndex = i
			else
				aDataCols = aDataCols + i
			ok

		next
	
		# Parse column dimensions

		aColDim1Values = []
		aColDim2Values = []
		aColGroups = []
	
		nDataColsLen = len(aDataCols)

		for i = 1 to nDataColsLen

			colIdx = aDataCols[i]
			colHeader = aHeaderRow[colIdx]
		
			if colHeader != ""
				aParts = split(colHeader, "_")
				dim1Value = aParts[1]
				dim2Value = aParts[2]
			
				if ring_find(aColDim1Values, dim1Value) = 0
					aColDim1Values = aColDim1Values + dim1Value
				ok
			
				if ring_find(aColDim2Values, dim2Value) = 0
					aColDim2Values = aColDim2Values + dim2Value
				ok
			
				key = dim1Value + "_" + dim2Value
				aColGroups[key] = colIdx
			ok

		next
	
		# Calculate row label width

		nRowLabelWidth = len(aRowDims[1])  # This is the first (and only) row dimension
		nLenPivotData = len(aPivotData)

		for r = 2 to nLenPivotData - 1

			cellValue = "" + aPivotData[r][1]

			if len(cellValue) > nRowLabelWidth
				nRowLabelWidth = len(cellValue)
			ok

		next
	
		nRowLabelWidth += 2  # Add padding
	
		# Calculate data column widths

		aDataColWidths = []
		nMinDataWidth = 10
		
		nColDim1Len = len(aColDim1Values)
		nColDim2Len = len(aColDim2Values)
	
		for i = 1 to nColDim1Len
			dim1Value = aColDim1Values[i]

			for j = 1 to nColDim2Len
				dim2Value = aColDim2Values[j]

				key = dim1Value + "_" + dim2Value
				colIdx = aColGroups[key]
			
				if colIdx != NULL
					maxWidth = len(dim2Value)
				
					for r = 2 to nLenPivotData

						if colIdx <= len(aPivotData[r])

							cellValue = "" + aPivotData[r][colIdx]

							if len(cellValue) > maxWidth
								maxWidth = len(cellValue)
							ok

						ok

					next
				
					aDataColWidths[key] = max([nMinDataWidth, maxWidth + 2])
				ok

			next

		next
	
		# Calculate total column width

		nTotalColWidth = len(cTotalLabel)
	
		for r = 2 to nLenPivotData

			if nTotalColIndex <= len(aPivotData[r])

				cellValue = "" + aPivotData[r][nTotalColIndex]

				if len(cellValue) > nTotalColWidth
					nTotalColWidth = len(cellValue)
				ok

			ok

		next
	
		nTotalColWidth += 2
	
		# Build table output

		cOutput = ""
	
		# Top border

		cLine = @aBorder[:TopLeft] + StrFill(nRowLabelWidth, @aBorder[:Horizontal]) + @aBorder[:TeeDown]
	
		# Calculate first dimension widths

		aDim1Widths = []

		for i = 1 to nColDim1Len
			dim1Value = aColDim1Values[i]

			dim1Width = 0

			for j = 1 to nColDim2Len
				dim2Value = aColDim2Values[j]

				key = dim1Value + "_" + dim2Value

				if aDataColWidths[key] != NULL
					dim1Width += aDataColWidths[key]
				ok

			next

			if nColDim2Len > 1
				dim1Width += nColDim2Len - 1
			ok

			aDim1Widths[dim1Value] = dim1Width

		next
	
		# Add dimension sections

		for i = 1 to nColDim1Len
			dim1Value = aColDim1Values[i]

			cLine += StrFill(aDim1Widths[dim1Value], @aBorder[:Horizontal])

			if i < nColDim1Len
				cLine += @aBorder[:TeeDown]
			ok

		next
	
		cLine += @aBorder[:TeeDown] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:TopRight]
		cOutput += cLine + NL
	
		# First header row - column dimension 1
		# First cell is empty in the first row

		cLine = @aBorder[:Vertical] + StrFill(nRowLabelWidth, " ") + @aBorder[:Vertical]
	
		for i = 1 to nColDim1Len
			dim1Value = aColDim1Values[i]
			dim1Display = Upper(Left(dim1Value, 1)) + SubStr(dim1Value, 2)
			cLine += CenterText(dim1Display, aDim1Widths[dim1Value])
		
			if i < nColDim1Len
				cLine += @aBorder[:Vertical]
			ok

		next
	
		# Last column in the first row should also be empty

		cLine += @aBorder[:Vertical] + StrFill(nTotalColWidth, " ") + @aBorder[:Vertical]
		cOutput += cLine + NL
	
		# Separator between column dimensions - hide the Department header cell's top border

		cLine = @aBorder[:Vertical] + StrFill(nRowLabelWidth, " ") + @aBorder[:Vertical]
	
		for i = 1 to nColDim1Len
			dim1Value = aColDim1Values[i]

			for j = 1 to nColDim2Len
				dim2Value = aColDim2Values[j]

				key = dim1Value + "_" + dim2Value

				if aDataColWidths[key] != NULL

					dim2Width = aDataColWidths[key]
					cLine += StrFill(dim2Width, @aBorder[:Horizontal])
				
					if j < nColDim2Len
						cLine += @aBorder[:TeeDown]
					ok

				ok

			next
		
			if i < nColDim1Len
				cLine += @aBorder[:Vertical]
			ok

		next
	
		cLine += @aBorder[:Vertical] + StrFill(nTotalColWidth, " ") + @aBorder[:Vertical]
		cOutput += cLine + NL
	
		# Second dimension header - row and column dimension 2
		cLine = @aBorder[:Vertical]
	
		# Row dimension header

		dim = aRowDims[1]
		oDim = StzStringQ(dim)
		capitalized = Upper(Left(dim, 1)) + oDim.Section(2, oDim.NumberOfChars())
		cLine += CenterText(capitalized, nRowLabelWidth) + @aBorder[:Vertical]
	
		# Column dimension 2 headers

		for i = 1 to nColDim1Len
			dim1Value = aColDim1Values[i]

			for j = 1 to nColDim2Len
				dim2Value = aColDim2Values[j]

				key = dim1Value + "_" + dim2Value

				if aDataColWidths[key] != NULL

					oDim2 = new stzString(dim2Value)
					capitalizedDim2 = Upper(Left(dim2Value, 1)) + oDim2.Section(2, oDim2.NumberOfChars())
					cLine += CenterText(capitalizedDim2, aDataColWidths[key])
				
					if j < nColDim2Len
						cLine += @aBorder[:Vertical]
					ok

				ok

			next
		
			if i < nColDim1Len
				cLine += @aBorder[:Vertical]
			ok

		next
	
		cLine += @aBorder[:Vertical] + CenterText(Upper(cTotalLabel), nTotalColWidth) + @aBorder[:Vertical]
		cOutput += cLine + NL
	
		# Separator before data

		cLine = @aBorder[:TeeRight] + StrFill(nRowLabelWidth, @aBorder[:Horizontal]) + @aBorder[:Cross]
	
		for i = 1 to nColDim1Len
			dim1Value = aColDim1Values[i]

			for j = 1 to nColDim2Len
				dim2Value = aColDim2Values[j]

				key = dim1Value + "_" + dim2Value

				if aDataColWidths[key] != NULL

					cLine += StrFill(aDataColWidths[key], @aBorder[:Horizontal])
				
					if j < nColDim2Len
						cLine += @aBorder[:Cross]
					ok

				ok

			next
		
			if i < nColDim1Len
				cLine += @aBorder[:Cross]
			ok

		next
	
		cLine += @aBorder[:Cross] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:TeeLeft]
		cOutput += cLine + NL
	
		# Data rows

		for r = 2 to nLenPivotData - 1

			cLine = @aBorder[:Vertical] + " " + aPivotData[r][1] + StrFill(nRowLabelWidth - len(aPivotData[r][1]) - 1, " ") + @aBorder[:Vertical]
		
			# Data cells

			for i = 1 to nColDim1Len
				dim1Value = aColDim1Values[i]

				for j = 1 to nColDim2Len
					dim2Value = aColDim2Values[j]

					key = dim1Value + "_" + dim2Value
					colIdx = aColGroups[key]
				
					if colIdx != NULL
						value = @if(colIdx <= len(aPivotData[r]), aPivotData[r][colIdx], "")
					
						if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
							cLine += " " + PadLeft(value, aDataColWidths[key] - 2) + " "
						else
							cLine += " " + PadRight(value, aDataColWidths[key] - 2) + " "
						ok
					
						if j < nColDim2Len
							cLine += @aBorder[:Vertical]
						ok
					ok

				next
			
				if i < nColDim1Len
					cLine += @aBorder[:Vertical]
				ok

			next
		
			# Total column

			totalValue = @if(nTotalColIndex <= len(aPivotData[r]), aPivotData[r][nTotalColIndex], "")

			if isNumber(totalValue) or (isString(totalValue) and totalValue != "" and isNumber(0 + value))
				cLine += @aBorder[:Vertical] + " " + PadLeft(totalValue, nTotalColWidth - 2) + " " + @aBorder[:Vertical]

			else
				cLine += @aBorder[:Vertical] + " " + PadRight(totalValue, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			ok
		
			cOutput += cLine + NL

		next
	
		# Bottom border

		cLine = @aBorder[:BottomLeft] + StrFill(nRowLabelWidth, @aBorder[:Horizontal]) + @aBorder[:TeeUp]
	
		for i = 1 to nColDim1Len
			dim1Value = aColDim1Values[i]

			for j = 1 to nColDim2Len
				dim2Value = aColDim2Values[j]

				key = dim1Value + "_" + dim2Value

				if aDataColWidths[key] != NULL

					cLine += StrFill(aDataColWidths[key], @aBorder[:Horizontal])
				
					if j < nColDim2Len
						cLine += @aBorder[:TeeUp]
					ok
				ok

			next
		
			if i < nColDim1Len
				cLine += @aBorder[:TeeUp]
			ok

		next
	
		cLine += @aBorder[:TeeUp] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
		cOutput += cLine + NL
	
		# Totals row

		if nLenPivotData > 1 and aPivotData[nLenPivotData][1] = cTotalLabel

			totalRow = aPivotData[nLenPivotData]
			nLenTotalRow = len(totalRow)
		
			# Format the AVERAGE label with right alignment followed by a space

			cLine = " " + PadLeft(Upper(totalRow[1]), nRowLabelWidth - 1) + " " + @aBorder[:Vertical]
		
			for i = 1 to nColDim1Len
				dim1Value = aColDim1Values[i]

				for j = 1 to nColDim2Len
					dim2Value = aColDim2Values[j]

					key = dim1Value + "_" + dim2Value
					colIdx = aColGroups[key]
				
					if colIdx != NULL

						value = @if(colIdx <= nLenTotalRow, totalRow[colIdx], "")
					
						if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
							cLine += " " + PadLeft(value, aDataColWidths[key] - 2) + " "

						else
							cLine += " " + PadRight(value, aDataColWidths[key] - 2) + " "
						ok
					
						if j < nColDim2Len
							cLine += @aBorder[:Vertical]
						ok

					ok

				next
			
				if i < nColDim1Len
					cLine += @aBorder[:Vertical]
				ok

			next
		
			grandTotal = @if(nTotalColIndex <= nLenTotalRow, totalRow[nTotalColIndex], "")
		
			if isNumber(grandTotal) or (isString(grandTotal) and grandTotal != "" and isNumber(0 + grandTotal))
				cLine += @aBorder[:Vertical] + " " + PadLeft(grandTotal, nTotalColWidth - 2) + " " + @aBorder[:Vertical]

			else
				cLine += @aBorder[:Vertical] + " " + PadRight(grandTotal, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			ok
		
			cOutput += cLine
		
			# No final bottom border after totals
		ok

		? StzStringQ(trim(cOutput)).LastCharRemoved() + NL

	  #------------------------------------------#
	 #  2D Rows 1D Columns Pivot Table Display  #
	#------------------------------------------#

	def _showFormattedPivotTable2DRows1DCols()
		# Display pivot table with formatted output - for mixed dimensions

		aPivotData = @aPivotData
		aRowDims = @aRowLabels
		aColDims = @aColLabels
		cTotalLabel = @cTotalLabel
		nLenPivotData = len(aPivotData)
	
		# Initialize column tracking

		aRowLabelCols = []
		aDataCols = []
		nTotalColIndex = 0
	
		aHeaderRow = aPivotData[1]
	
		# Process row dimensions - for 2D we have two

		aRowLabelCols + 1
		aRowLabelCols + 2
	
		# Process data columns

		nHeaderLen = len(aHeaderRow)
		for i = 3 to nHeaderLen
			if aHeaderRow[i] = cTotalLabel
				nTotalColIndex = i
			else
				aDataCols + i
			ok
		next
	
		# Calculate row label widths

		aRowLabelWidths = [0, 0]  # One for each dimension
	
		# First dimension

		maxLabelWidth = len(aRowDims[1])

		for r = 2 to nLenPivotData - 1
			if r = 2  # Skip header row
				loop
			ok

			cellValue = "" + aPivotData[r][1]

			if len(cellValue) > maxLabelWidth
				maxLabelWidth = len(cellValue)
			ok
		next

		aRowLabelWidths[1] = maxLabelWidth + 2
	
		# Second dimension

		maxLabelWidth = len(aRowDims[2])

		for r = 2 to nLenPivotData - 1
			if r = 2  # Skip header row
				loop
			ok

			cellValue = "" + aPivotData[r][2]

			if len(cellValue) > maxLabelWidth
				maxLabelWidth = len(cellValue)
			ok
		next

		aRowLabelWidths[2] = maxLabelWidth + 2
	
		# Calculate data column widths

		aDataColWidths = []
		nMinDataWidth = 10
		nDataColsLen = len(aDataCols)
	
		for i = 1 to nDataColsLen
			colIdx = aDataCols[i]
			maxWidth = len(aHeaderRow[colIdx])
		
			for r = 2 to nLenPivotData

				if colIdx <= len(aPivotData[r])

					cellValue = "" + aPivotData[r][colIdx]

					if len(cellValue) > maxWidth
						maxWidth = len(cellValue)
					ok
				ok

			next
		
			aDataColWidths + max([nMinDataWidth, maxWidth + 2])
		next
	
		# Calculate total column width
		nTotalColWidth = len(cTotalLabel)

		for r = 2 to nLenPivotData

			if nTotalColIndex <= len(aPivotData[r])

				cellValue = "" + aPivotData[r][nTotalColIndex]

				if len(cellValue) > nTotalColWidth
					nTotalColWidth = len(cellValue)
				ok

			ok
		next

		nTotalColWidth += 2
	
		# Build table output

		cOutput = ""
	
		# Top border

		cLine = @aBorder[:TopLeft]
		nRowLabelWidthsLen = len(aRowLabelWidths)

		for i = 1 to nRowLabelWidthsLen
			cLine += StrFill(aRowLabelWidths[i], @aBorder[:Horizontal])

			if i = 1
				cLine += @aBorder[:Horizontal]
			else
				cLine += @aBorder[:TeeDown]
			ok
		next
	
		# Calculate combined width of data columns

		nCombinedDataWidth = 0
		nDataColWidthsLen = len(aDataColWidths)

		for i = 1 to nDataColWidthsLen
			nCombinedDataWidth += aDataColWidths[i]

			if i < nDataColWidthsLen
				nCombinedDataWidth += 1  # For the vertical border
			ok
		next
	
		# Add horizontal line for the combined data column header

		cLine += StrFill(nCombinedDataWidth, @aBorder[:Horizontal])
		cLine += @aBorder[:TeeDown] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:TopRight]
		cOutput += cLine + NL
	
		# First header row with main label spanning data columns

		cLine = @aBorder[:Vertical]
	
		# Columns for row dimensions

		cRowDimsWidth = 0
		for i = 1 to nRowLabelWidthsLen
			cRowDimsWidth += aRowLabelWidths[i]
		next
		cRowDimsWidth += 1  # For the vertical separator
	
		cLine += StrFill(cRowDimsWidth, " ") + @aBorder[:Vertical]
	
		# The main raw label centered across all data columns

		cLine += CenterText(Capitalize(aColDims[1]), nCombinedDataWidth)
		cLine += @aBorder[:Vertical] + copy(" ", nTotalColWidth) + @aBorder[:Vertical]
		cOutput += cLine + NL
	
		# Separator after main raw header

		cLine = @aBorder[:Vertical]

		for i = 1 to nRowLabelWidthsLen
			cLine += StrFill(aRowLabelWidths[i], " ")

			if i < nRowLabelWidthsLen
				cLine += " "
			else
				cLine += @aBorder[:Vertical]
			ok
		next
	
		# Add horizontal line separators under the main raw label

		for i = 1 to nDataColsLen
			cLine += StrFill(aDataColWidths[i], @aBorder[:Horizontal])

			if i < nDataColsLen
				cLine += @aBorder[:TeeDown]
			ok
		next
	
		cLine += @aBorder[:Vertical] + StrFill(nTotalColWidth, " ") + @aBorder[:Vertical]
		cOutput += cLine + NL
	
		# Second header row with dimension names

		cLine = @aBorder[:Vertical]
		nRowDimsLen = len(aRowDims)
	
		# Columns for row dimensions

		oDimStrList = []
		for i = 1 to nRowDimsLen
			oDimStrList + new stzString(aRowDims[i])
		next

		for i = 1 to nRowDimsLen
			dimName = aRowDims[i]
			oDim = oDimStrList[i]
			capitalized = Upper(Left(dimName, 1)) + oDim.Section(2, oDim.NumberOfChars())
			cLine += CenterText(capitalized, aRowLabelWidths[i]) + @aBorder[:Vertical]
		next
	
		# Header for data columns

		oColHeaderStrList = []
		for i = 1 to nDataColsLen
			colIdx = aDataCols[i]
			colHeader = aHeaderRow[colIdx]
			oColHeaderStrList + StzStringQ(colHeader)
		next

		for i = 1 to nDataColsLen
			colIdx = aDataCols[i]
			colHeader = aHeaderRow[colIdx]
			oDim = oColHeaderStrList[i]
			capitalized = Upper(Left(colHeader, 1)) + oDim.Section(2, oDim.NumberOfChars())
			cLine += CenterText(capitalized, aDataColWidths[i])
		
			if i < nDataColsLen
				cLine += @aBorder[:Vertical]
			ok
		next
	
		cLine += @aBorder[:Vertical] + CenterText(Upper(cTotalLabel), nTotalColWidth) + @aBorder[:Vertical]
		cOutput += cLine + NL
	
		# Separator before data

		cLine = @aBorder[:TeeRight]

		for i = 1 to nRowLabelWidthsLen
			cLine += StrFill(aRowLabelWidths[i], @aBorder[:Horizontal])
			if i < nRowLabelWidthsLen
				cLine += @aBorder[:TeeDown]
			else
				cLine += @aBorder[:Cross]
			ok
		next
	
		for i = 1 to nDataColsLen
			cLine += StrFill(aDataColWidths[i], @aBorder[:Horizontal])
			if i < nDataColsLen
				cLine += @aBorder[:Cross]
			ok
		next
	
		cLine += @aBorder[:Cross] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:TeeLeft]
		cOutput += cLine + NL
	
		# Data rows

		lastDim1Value = ""

		for r = 3 to nLenPivotData - 1
			cLine = @aBorder[:Vertical]
		
			# Row labels - handle merging for first dimension

			dim1Value = ''+ aPivotData[r][1]

			if dim1Value = lastDim1Value
				cLine += " " + StrFill(aRowLabelWidths[1] - 2, " ") + " " + @aBorder[:Vertical]
			else
				cLine += " " + dim1Value + StrFill(aRowLabelWidths[1] - len(dim1Value) - 1, " ") + @aBorder[:Vertical]
				lastDim1Value = dim1Value
			ok
		
			# Second dimension

			dim2Value = ''+ aPivotData[r][2]
			cLine += " " + dim2Value + StrFill(aRowLabelWidths[2] - len(dim2Value) - 1, " ") + @aBorder[:Vertical]
		
			# Data cells

			for i = 1 to nDataColsLen
				colIdx = aDataCols[i]
				value = ""

				if colIdx <= len(aPivotData[r])
					value = aPivotData[r][colIdx]
				ok
			
				if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
					cLine += " " + PadLeft(value, aDataColWidths[i] - 2) + " "

				else
					cLine += " " + PadRight(value, aDataColWidths[i] - 2) + " "
				ok
			
				if i < nDataColsLen
					cLine += @aBorder[:Vertical]
				ok

			next
		
			# Total column

			totalValue = ""

			if nTotalColIndex <= len(aPivotData[r])
				totalValue = aPivotData[r][nTotalColIndex]
			ok
		
			if isNumber(totalValue) or (isString(totalValue) and totalValue != "" and isNumber(0 + value))
				cLine += @aBorder[:Vertical] + " " + PadLeft(totalValue, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			else
				cLine += @aBorder[:Vertical] + " " + PadRight(totalValue, nTotalColWidth - 2) + " " + @aBorder[:Vertical]
			ok
		
			cOutput += cLine + NL
		
			# Add subtotal separator if needed

			if r < nLenPivotData - 1 and aPivotData[r+1][1] != aPivotData[r][1] and aPivotData[r+1][1] != cTotalLabel

				cLine = @aBorder[:Vertical] + StrFill(aRowLabelWidths[1], " ") + 
						@aBorder[:Vertical] + StrFill(aRowLabelWidths[2], " ") + @aBorder[:Vertical]
			
				for i = 1 to nDataColsLen

					cLine += StrFill(aDataColWidths[i], " ")

					if i < nDataColsLen
						cLine += @aBorder[:Vertical]
					ok

				next
			
				cLine += @aBorder[:Vertical] + StrFill(nTotalColWidth, " ") + @aBorder[:Vertical]
				cOutput += cLine + NL

			ok
		next
	
		# Bottom border

		cLine = @aBorder[:BottomLeft]

		for i = 1 to nRowLabelWidthsLen
			cLine += StrFill(aRowLabelWidths[i], @aBorder[:Horizontal])
			cLine += @aBorder[:TeeUp]
		next
	
		for i = 1 to nDataColsLen

			cLine += StrFill(aDataColWidths[i], @aBorder[:Horizontal])

			if i < nDataColsLen
				cLine += @aBorder[:TeeUp]
			ok

		next
	
		cLine += @aBorder[:TeeUp] + StrFill(nTotalColWidth, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
		cOutput += cLine + NL
	
		# Total row

		totalRow = aPivotData[nLenPivotData]
	
		cLine = "  " + PadLeft(Upper(totalRow[1]), aRowLabelWidths[1] + aRowLabelWidths[2] - 1) + " " + @aBorder[:Vertical]

		for i = 1 to nDataColsLen

			colIdx = aDataCols[i]
			value = ""

			if colIdx <= len(totalRow)
				value = totalRow[colIdx]
			ok

			if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
				cLine += " " + PadLeft(value, aDataColWidths[i] - 2) + " "

			else
				cLine += " " + PadRight(value, aDataColWidths[i] - 2) + " "
			ok
		
			if i < nDataColsLen
				cLine += @aBorder[:Vertical]
			ok

		next
	
		grandTotal = ""

		if nTotalColIndex <= len(totalRow)
			grandTotal = totalRow[nTotalColIndex]
		ok
	
		if isNumber(grandTotal) or (isString(grandTotal) and grandTotal != "" and isNumber(0 + grandTotal))
			cLine += @aBorder[:Vertical] + " " + PadLeft(grandTotal, nTotalColWidth - 2) + "  "

		else
			cLine += @aBorder[:Vertical] + " " + PadRight(grandTotal, nTotalColWidth - 2) + "  "
		ok
	
		cOutput += cLine
	
		? cOutput + NL

	  #-----------------------------#
	 #  UTILITY FUNCTIONS          #
	#-----------------------------#

	def PadRight(text, width)
		# Pad text to the right
		cStr = "" + text
		nPad = width - len(cStr)
		if nPad > 0
			return cStr + copy(" ", nPad)
		else
			return cStr
		ok
	
	def PadLeft(text, width)
		# Pad text to the left
		cStr = "" + text
		nPad = width - len(cStr)
		if nPad > 0
			return copy(" ", nPad) + cStr
		else
			return cStr
		ok
	
	def CenterText(text, width)
		# Center text within width
		cStr = "" + text
		nPadTotal = width - len(cStr)
		if nPadTotal <= 0
			return cStr
		ok
		
		nPadLeft = floor(nPadTotal / 2)
		nPadRight = nPadTotal - nPadLeft
		
		return copy(" ", nPadLeft) + cStr + copy(" ", nPadRight)
	
	def StrFill(nCount, cChar)
		# Create string of repeated character
		cResult = ""
		for i = 1 to nCount
			cResult += cChar
		next
		return cResult
