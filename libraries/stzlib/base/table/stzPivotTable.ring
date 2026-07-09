#--------------------------------#
#  PIVOT TABLE CORE FUNCTIONALITY #
#--------------------------------#

func stzPivotTable(pSource)
	# Creates a new instance of stzPivotTable with the provided source data	# data
	return new stzPivotTable(pSource)

class stzPivotTable from stzList
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
		if isString(pSource) and StzLower(pSource) = :fromsource
			return
		ok
		
		# Handle different source types (object or raw data)
		if isObject(pSource) and ring_classname(pSource) = "stztable"
			@oSourceTable = pSource
		else
			@oSourceTable = new stzTable(pSource)
		ok
		
		# Initialize cache
		@aCellCache = []

	def ClassName() #TODO // Add it to all the classes in Softanza
		return "stzpivottable"

		def KlassName()
			return "stzpivottable"

	  #--------------------------#
	 #  CONFIGURATION METHODS   #
	#--------------------------#

	def Analyze(paValues, pcFunc)
		if CheckParams()
			if isList(pcFunc) and IsWithOrUsingOrInNamedParamList(pcFunc)
				pcFunc = pcFunc[2]
			ok
		ok

		# Configure values and aggregation function for analysis
		This.SetValues(paValues)
		This.SetAggregateFunction(pcFunc)
		This.SetTotalLabel(pcFunc)

	def By(paRows, paCols)

		if isList(paCols) and IsAndNamedParamList(paCols)
				paCols = paCols[2]
		ok

		This.SetRowsBy(paRows)
		This.SetColsBy(paCols)

	def SetRowsBy(paLabels)
		# Set row labels for pivot table
		This.SetRowLabels(paLabels)

		def InRowsPut(paLabels)
			This.SetRowLabels(paLabels)

	def SetColsBy(paLabels)
		# Set column labels for pivot table
		This.SetColumnLabels(paLabels)

		def SetColumnsBy(paLabels)
			This.SetColumnLabels(paLabels)

		def InColsPut(paLabels)
			This.SetColumnLabels(paLabels)

		def InColumnsPut(paLabels)
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
		@cAggFunc = StzUpper(pcFunction)
		This.SetTotalLabel(@cAggFunc)
		@bIsGenerated = FALSE

	def SetRowLabelsSeparator(pcSeparator)
		# Set separator for multi-level row labels
		@cRowLabelsSeparator = pcSeparator
		@bIsGenerated = FALSE

		#-- @Misspelled

		def SetRowLabelsSeperator(pcSeparator)
			This.SetRowLabelsSeparator(pcSeparator)

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
		if len(@aRowLabels) = 0
			stzRaise("You must specify at least one row label")
		ok
		if len(@aColLabels) = 0
			stzRaise("You must specify at least one column label")
		ok
		if len(@aValues) = 0
			stzRaise("You must specify at least one value column")
		ok

		@aCellCache = []

		if NOT isObject(@oSourceTable)
			stzRaise("Source table is not properly initialized")
		ok

		# Engine fast path: delegate crossTab to Zig engine
		if _CanUseEngine()
			_GenerateViaEngine()
			return
		ok

		# Ring fallback
		_aUniqueRowCombos_ = _getUniqueCombinations(@aRowLabels)
		_aUniqueColCombos_ = _getUniqueCombinations(@aColLabels)

		@aPivotData = [ @Flatten(_createHeaderStructure(_aUniqueColCombos_)) ]

		_generateDataRows(_aUniqueRowCombos_, _aUniqueColCombos_)

		if @bShowTotalRow
			_addTotalRow()
		ok

		@oResultTable = new stzTable(@aPivotData)
		@bIsGenerated = TRUE

	  #-----------------------------------------#
	 #  ENGINE-BACKED PIVOT (ZIG FAST PATH)   #
	#-----------------------------------------#

	def _CanUseEngine()
		if len(@aColLabels) != 1
			return FALSE
		ok
		if len(@aRowLabels) < 1 or len(@aRowLabels) > 2
			return FALSE
		ok
		if len(@aValues) != 1
			return FALSE
		ok
		return TRUE

	def _AggFuncToInt()
		# Accept common synonyms. Previously "avg" / "mean" / "cnt"
		# didn't match any branch and fell through to `return 0`
		# (which is SUM) -- so pivot tables built with Analyze(...,
		# "AVG") silently aggregated as SUM.
		_cFn = StzLower(@cAggFunc)
		if _cFn = "avg" or _cFn = "mean"  _cFn = "average" ok
		if _cFn = "cnt"                   _cFn = "count"   ok

		if _cFn = "sum"      return 0 ok
		if _cFn = "count"    return 1 ok
		if _cFn = "average"  return 2 ok
		if _cFn = "min"      return 3 ok
		if _cFn = "max"      return 4 ok
		if _cFn = "product"  return 5 ok
		if _cFn = "stdev"    return 6 ok
		if _cFn = "variance" return 7 ok
		if _cFn = "median"   return 8 ok
		return 0

	def _GenerateViaEngine()
		_pSrcHandle = @oSourceTable.EngineHandle()

		_nAggInt = _AggFuncToInt()

		_nRowCol1 = @oSourceTable.FindCol(@aRowLabels[1]) - 1
		_nColCol  = @oSourceTable.FindCol(@aColLabels[1]) - 1
		_nValCol  = @oSourceTable.FindCol(@aValues[1]) - 1

		_nIncRowTotal = 0
		if @bShowTotalColumn _nIncRowTotal = 1 ok
		_nIncColTotal = 0
		if @bShowTotalRow _nIncColTotal = 1 ok

		_nRowLabels = len(@aRowLabels)

		if _nRowLabels = 1
			_pResult = StzEnginePivotCrossTab1(
				_pSrcHandle, _nRowCol1,
				_nColCol, _nValCol, _nAggInt,
				_nIncRowTotal, _nIncColTotal
			)
		else
			_nRowCol2 = @oSourceTable.FindCol(@aRowLabels[2]) - 1
			_pResult = StzEnginePivotCrossTab2(
				_pSrcHandle, _nRowCol1, _nRowCol2,
				_nColCol, _nValCol, _nAggInt,
				_nIncRowTotal, _nIncColTotal
			)
		ok

		if _pResult = NULL
			stzRaise("Engine pivot failed!")
		ok

		_nResCols = StzEngineTableNumCols(_pResult)
		_nResRows = StzEngineTableNumRows(_pResult)

		_aHeader = []
		for _iP = 1 to _nResCols
			_aHeader + StzEngineTableColName(_pResult, _iP - 1)
		next

		@aPivotData = [_aHeader]

		for _rP = 1 to _nResRows
			_aRow = []
			for _cP = 1 to _nResCols
				_nType = StzEngineTableGetCellType(_pResult, _cP - 1, _rP - 1)
				if _nType = 2
					_aRow + StzEngineTableGetCellInt(_pResult, _cP - 1, _rP - 1)
				but _nType = 3
					_aRow + StzEngineTableGetCellFloat(_pResult, _cP - 1, _rP - 1)
				but _nType = 4
					_aRow + StzEngineTableGetCellString(_pResult, _cP - 1, _rP - 1)
				else
					_aRow + ""
				ok
			next
			@aPivotData + _aRow
		next

		StzEngineTableFree(_pResult)

		@oResultTable = new stzTable(@aPivotData)
		@bIsGenerated = TRUE

	  #--------------------------------#
	 #  DATA PROCESSING HELPERS       #
	#--------------------------------#

	def _getUniqueCombinations(paFields)

		_nRows_ = @oSourceTable.NumberOfRows()

		# Get unique combinations of values for specified fields

		_nLenFields_ = len(paFields)
		if _nLenFields_ = 0
			return []
		ok

		if _nLenFields_ = 1

			# Handle single field

			_nColIndex_ = @oSourceTable.FindCol(paFields[1])

			if _nColIndex_ = 0
				stzRaise("Column not found: " + paFields[1])
			ok

			# Collect unique values

			_aCells_ = []

			for i = 2 to _nRows_
				_aCells_ + @oSourceTable.Cell(_nColIndex_, i)
			next

			_aUniqueValues_ = U(_aCells_)
			_nLenU_ = len(_aUniqueValues_)

			# Apply custom ordering if available and this is a column field

			_nLenColOrder_ = len(@aColumnOrder)

			if paFields = @aColLabels and _nLenColOrder_ > 0
				_aOrdered_ = []

				# First add values from the custom order

				for i = 1 to _nLenColOrder_
					if StzFindFirst(_aUniqueValues_, @aColumnOrder[i]) > 0
						_aOrdered_ + @aColumnOrder[i]
					ok
				next

				# Then add any values not in the custom order

				for i = 1 to _nLenU_
					_cItem_ = _aUniqueValues_[i]
					if not StzFindFirst(_aOrdered_, _cItem_) > 0
						_aOrdered_ + _cItem_
					ok
				next

				_aUniqueValues_ = _aOrdered_
			ok

			_nLenU_ = len(_aUniqueValues_)
			_aResult_ = []

			for i = 1 to _nLenU_
				_aResult_ + [[ _aUniqueValues_[i] ]]
			next

			return _aResult_
		ok

		# Handle multiple fields

		_aAllCombos_ = []
		_aFieldIndices_ = []

		# Get column indices

		for i = 1 to _nLenFields_
			_nColIndex_ = @oSourceTable.FindCol(paFields[i])
			if _nColIndex_ = 0
				StzRaise("Column not found: " + paFields[i])
			ok
			_aFieldIndices_ + _nColIndex_
		next
		_nLenFieldIndices_ = len(_aFieldIndices_)

		# Collect all combinations

		for r = 2 to _nRows_
			_aCombination_ = []

			for i = 1 to _nLenFieldIndices_
				_aCombination_ + @oSourceTable.Cell(_aFieldIndices_[i], r)
			next

			# Check for duplicates
			_bExists_ = FALSE
			_nLenCombos_ = len(_aAllCombos_)

			for i = 1 to _nLenCombos_
				if _arraysEqual(_aAllCombos_[i], _aCombination_)
					_bExists_ = TRUE
					exit
				ok
			next

			if not _bExists_
				_aAllCombos_ + _aCombination_
			ok
		next

		return _aAllCombos_

	def _arraysEqual(a1, a2)
		# Compare two arrays for equality
		if len(a1) != len(a2)
			return FALSE
		ok
		
		_nA1Len_ = len(a1)
		for i = 1 to _nA1Len_
			if a1[i] != a2[i]
				return FALSE
			ok
		next
		
		return TRUE

	def _createHeaderStructure(aColCombos)
		# Create header structure for pivot table
		_aHeaders_ = []
		
		# Initialize first row with empty cells for row labels
		_aFirstRow_ = []
		_nRowLabelsLen_ = len(@aRowLabels)
		for i = 1 to _nRowLabelsLen_
			_aFirstRow_ + ""
		next
		
		# Add column combinations
		_nColCombos1Len_ = len(aColCombos)
		for _iLoopColCombos1_ = 1 to _nColCombos1Len_
			_combo_ = aColCombos[_iLoopColCombos1_]
			_aFirstRow_ + _combineLabels(_combo_)
		next
		
		if @bShowTotalColumn
			_aFirstRow_ + @cTotalLabel
		ok
		
		_aHeaders_ + _aFirstRow_
		
		return [_aHeaders_]

	def _combineLabels(aLabels)
		# Combine multiple labels with separator
		if len(aLabels) = 1
			return aLabels[1]
		ok
		
		_cResult_ = ""
		_nLabelsLen_ = len(aLabels)
		for i = 1 to _nLabelsLen_
			if i > 1
				_cResult_ += @cRowLabelsSeparator
			ok
			_cResult_ += aLabels[i]
		next
		
		return _cResult_

	def _generateDataRows(aRowCombos, aColCombos)

		# Generate data rows for pivot table

		_nLenRows_ = len(aRowCombos)
		_nLenRowsLabels_ = len(@aRowLabels)
		_nRawTotalForCount_ = 0

		for i = 1 to _nLenRows_

			_rowCombo_ = aRowCombos[i]
			_aRow_ = []
			_aFlatRowCombo_ = _flattenArray(_rowCombo_)
			
			# Add row labels

			_nLenFlat_ = len(_aFlatRowCombo_)

			for j = 1 to _nLenFlat_
				if j <= _nLenRowsLabels_
					_aRow_ + _aFlatRowCombo_[j]
				ok
			next
			
			# Fill missing labels

			while len(_aRow_) < _nLenRowsLabels_
				_aRow_ + ""
			end
			
			_aRowValues_ = []
			
			# Add values for each column combination

			_nLenCols_ = len(aColCombos)

			for j = 1 to _nLenCols_

				_aFlatColCombo_ = _flattenArray(aColCombos[j])
				_nCellValue_ = _calculateCellValueMulti(_aFlatRowCombo_, _aFlatColCombo_)
				_aRow_ + _nCellValue_
				
				if @bShowTotalColumn and isNumber(_nCellValue_)
					_aRowValues_ + _nCellValue_
				ok
			next
			
			# Add row total

			if @bShowTotalColumn

				if StzLower(@cAggFunc) = "count"
					_aRow_ + _aRowValues_[1]
				else

					_nRowTotal_ = _applyAggregateFunction(_aRowValues_)
					_aRow_ + _nRowTotal_
				ok

			ok
			
			@aPivotData + _aRow_
		next


	def _addTotalRow()
		# Add total row to pivot table
		_aTotalRow_ = []
		_nLenRows_ = len(@aRowLabels)

		# Add total label
		for i = 1 to _nLenRows_
			if i = 1
				_aTotalRow_ + @cTotalLabel
			else
				_aTotalRow_ + ""
			ok
		next
		
		# Calculate column totals
		_nColCount_ = len(@aPivotData[1])
		_nRowCount_ = len(@aPivotData)
		
		for c = _nLenRows_ + 1 to _nColCount_
			_aColValues_ = []
			
			# Collect column values

			for r = 2 to _nRowCount_
				if isNumber(@aPivotData[r][c])
					_aColValues_ + @aPivotData[r][c]
				ok
			next
			
			# Apply aggregation

			if StzLower(@cAggFunc) = "count"
				_cOrigAggFunc_ = @cAggFunc
				@cAggFunc = :Sum
				_nColTotal_ = _applyAggregateFunction(_aColValues_)
				@cAggFunc = _cOrigAggFunc_
			else
				_nColTotal_ = _applyAggregateFunction(_aColValues_)
			ok

			_nColTotal_ = _applyAggregateFunction(_aColValues_)
			_aTotalRow_ + _nColTotal_
		next
		
		@aPivotData + _aTotalRow_


	def _calculateCellValueMulti(_aRowValues_, _aColValues_)

		# Calculate cell value for given row and column combinations
		_aFlatRowValues_ = _flattenArray(_aRowValues_)
		_aFlatColValues_ = _flattenArray(_aColValues_)

		_nLenFlatRows_ = len(_aFlatRowValues_)
		_nLenFlatCols_ = len(_aFlatColValues_)

		# Check cache
		_cCacheKey_ = _getCacheKey(_aFlatRowValues_, _aFlatColValues_)
		if _checkCache(_cCacheKey_)
			return _getFromCache(_cCacheKey_)
		ok
		
		# Collect matching values
		_aMatchingValues_ = []
		_cValueField_ = @aValues[1]
		_nValueColIndex_ = @oSourceTable.FindCol(_cValueField_)
		
		if _nValueColIndex_ = 0
			stzRaise("Value column not found: " + _cValueField_)
		ok
		
		# Get indices for row and column fields
		_aRowIndices_ = []
		_nLenRows_ = len(@aRowLabels)

		for i = 1 to _nLenRows_

			_nRowIndex_ = @oSourceTable.FindCol(@aRowLabels[i])

			if _nRowIndex_ = 0
				stzRaise("Row column not found: " + @aRowLabels[i])
			ok

			_aRowIndices_ + _nRowIndex_

		next
		
		_aColIndices_ = []
		_nLenCols_ = len(@aColLabels)

		for i = 1 to _nLenCols_ 

			_nColIndex_ = @oSourceTable.FindCol(@aColLabels[i])
			if _nColIndex_ = 0
				stzRaise("Column not found: " + @aColLabels[i])
			ok
			_aColIndices_ + _nColIndex_
		next
		
		# Process data rows
		_nRowCount_ = @oSourceTable.NumberOfRows()
		
		for r = 2 to _nRowCount_
			_bRowMatch_ = TRUE
			_bColMatch_ = TRUE
			
			# Check row matches
			_nLenRows_ = len(_aRowIndices_)

			for i = 1 to _nLenRows_

				if i <= _nLenFlatRows_

					if @oSourceTable.Cell(_aRowIndices_[i], r) != _aFlatRowValues_[i]
						_bRowMatch_ = FALSE
						exit
					ok

				ok
			next
			
			if not _bRowMatch_
				loop
			ok
			
			# Check column matches
			for i = 1 to _nLenCols_

				if i <= _nLenFlatCols_

					if @oSourceTable.Cell(_aColIndices_[i], r) != _aFlatColValues_[i]
						_bColMatch_ = FALSE
						exit
					ok

				ok

			next
			
			if not _bColMatch_
				loop
			ok
			
			# Add matching value
			value = @oSourceTable.Cell(_nValueColIndex_, r)
			_aMatchingValues_ + value

		next
		
		# Apply aggregation and cache result
		_result_ = _applyAggregateFunction(_aMatchingValues_)
		_addToCache(_cCacheKey_, _result_)
		
		return _result_


	  #---------------------#
	 #  CACHE MANAGEMENT   #
	#---------------------#

	def _getCacheKey(_aRowValues_, _aColValues_)
		# Generate cache key for cell values
		_cKey_ = ""
		
		if isList(_aRowValues_) 
			if len(_aRowValues_) > 0 and isList(_aRowValues_[1])
				_nRowValues2Len_ = len(_aRowValues_)
				for _iLoopRowValues2_ = 1 to _nRowValues2Len_
					_subArr_ = _aRowValues_[_iLoopRowValues2_]
					_nSubArr3Len_ = len(_subArr_)
					for _iLoopSubArr3_ = 1 to _nSubArr3Len_
						value = _subArr_[_iLoopSubArr3_]
						_cKey_ += "R:" + value + ";"
					next
				next
			else
				_nRowValues1Len_ = len(_aRowValues_)
				for _iLoopRowValues1_ = 1 to _nRowValues1Len_
					value = _aRowValues_[_iLoopRowValues1_]
					_cKey_ += "R:" + value + ";"
				next
			ok
		ok
		
		if isList(_aColValues_)
			if len(_aColValues_) > 0 and isList(_aColValues_[1])
				_nColValues2Len_ = len(_aColValues_)
				for _iLoopColValues2_ = 1 to _nColValues2Len_
					_subArr_ = _aColValues_[_iLoopColValues2_]
					_nSubArr2Len_ = len(_subArr_)
					for _iLoopSubArr2_ = 1 to _nSubArr2Len_
						value = _subArr_[_iLoopSubArr2_]
						_cKey_ += "C:" + value + ";"
					next
				next
			else
				_nColValues1Len_ = len(_aColValues_)
				for _iLoopColValues1_ = 1 to _nColValues1Len_
					value = _aColValues_[_iLoopColValues1_]
					_cKey_ += "C:" + value + ";"
				next
			ok
		ok
		
		return _cKey_

	def _checkCache(_cKey_)
		# Check if cache contains key
		_nCellCache2Len_ = len(@aCellCache)
		for _iLoopCellCache2_ = 1 to _nCellCache2Len_
			_item_ = @aCellCache[_iLoopCellCache2_]
			if _item_[1] = _cKey_
				return TRUE
			ok
		next
		return FALSE

	def _getFromCache(_cKey_)
		# Retrieve value from cache
		_nCellCache1Len_ = len(@aCellCache)
		for _iLoopCellCache1_ = 1 to _nCellCache1Len_
			_item_ = @aCellCache[_iLoopCellCache1_]
			if _item_[1] = _cKey_
				return _item_[2]
			ok
		next
		return NULL

	def _addToCache(_cKey_, value)
		# Add value to cache
		@aCellCache + [_cKey_, value]

	  #-----------------------------#
	 #  AGGREGATION FUNCTIONS      #
	#-----------------------------#
	
	def _applyAggregateFunction(aValues)
		# Apply configured aggregation function to values
		if len(aValues) = 0
			return @cCellNullValue
		ok

		# Accept common synonyms so "AVG" / "MEAN" both work alongside
		# "AVERAGE", and "CNT" alongside "COUNT". Previously only the
		# long forms matched and "AVG" silently fell through, then
		# whichever branch followed (here SUM was before AVERAGE in
		# the switch) produced the wrong result.
		_cAggFunc_ = StzLower(@cAggFunc)
		if _cAggFunc_ = "avg" or _cAggFunc_ = "mean"
			_cAggFunc_ = "average"
		but _cAggFunc_ = "cnt"
			_cAggFunc_ = "count"
		ok

		switch _cAggFunc_

			on "sum"

				_nResult_ = 0
				_nLen_ = len(aValues)

				for i = 1 to _nLen_
					_nResult_ += aValues[i]
				next

				return _nResult_

			on "average"

				_nResult_ = 0
				_nLen_ = len(aValues)

				for i = 1 to _nLen_
					_nResult_ += aValues[i]
				next

				return _nResult_ / _nLen_

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
			_aResult_ = []
			_nArray1Len_ = len(aArray)
			for _iLoopArray1_ = 1 to _nArray1Len_
				_subArr_ = aArray[_iLoopArray1_]
				if isList(_subArr_)
					_nSubArr1Len_ = len(_subArr_)
					for _iLoopSubArr1_ = 1 to _nSubArr1Len_
						_item_ = _subArr_[_iLoopSubArr1_]
						_aResult_ + _item_
					next
				else
					_aResult_ + _subArr_
				ok
			next
			return _aResult_
		else
			return aArray
		ok

	def Value(paRowValues, paColValues)
		# Get value for specific row and column combination
		if not @bIsGenerated
			Generate()
		ok
		
		_aFlatRowValues_ = _flattenArray(paRowValues)
		_aFlatColValues_ = _flattenArray(paColValues)
		_nLenFlatRows_ = len(_aFlatRowValues_)

		_nLen_ = len(@aPivotData)
		_nRowLabels_ = len(@aRowLabels)

		# Find row index
		_nRowIndex_ = 0
		for r = 2 to _nLen_
			_bMatch_ = TRUE
			
			for i = 1 to _nLenFlatRows_
				if i <= _nRowLabels_ and @aPivotData[r][i] != _aFlatRowValues_[i]
					_bMatch_ = FALSE
					exit
				ok
			next
			
			if _bMatch_
				_nRowIndex_ = r
				exit
			ok
		next
		
		if _nRowIndex_ = 0
			return NULL
		ok
		
		# Find column index
		_nColIndex_ = 0
		_cColLabel_ = _combineLabels(_aFlatColValues_)

		_nLen1_ = len(@aPivotData[1])

		for c =  _nRowLabels_+ 1 to _nLen1_
			if @aPivotData[1][c] = _cColLabel_
				_nColIndex_ = c
				exit
			ok
		next
		
		if _nColIndex_ = 0
			return NULL
		ok
		
		return @aPivotData[_nRowIndex_][_nColIndex_]

	def RowTotal(paRowValues)
		# Get total for specific row
		if not @bIsGenerated
			Generate()
		ok
		
		if not @bShowTotalColumn
			return NULL
		ok
		
		_aFlatRowValues_ = _flattenArray(paRowValues)
		_nLenFlat_ = len(_aFlatRowValues_)

		_nRowLabels_ = len(@aRowLabels)

		# Find row
		_nRowIndex_ = 0
		_nLen_ = len(@aPivotData)
		for r = 2 to _nLen_
			_bMatch_ = TRUE
			
			for i = 1 to _nLenFlat_
				if i <= _nRowLabels_ and @aPivotData[r][i] != _aFlatRowValues_[i]
					_bMatch_ = FALSE
					exit
				ok
			next
			
			if _bMatch_
				_nRowIndex_ = r
				exit
			ok
		next
		
		if _nRowIndex_ = 0
			return NULL
		ok
		
		return @aPivotData[_nRowIndex_][len(@aPivotData[1])]

	def ColumnTotal(paColValues)
		# Get total for specific column
		if not @bIsGenerated
			Generate()
		ok
		
		if not @bShowTotalRow
			return NULL
		ok
		
		_aFlatColValues_ = _flattenArray(paColValues)
		
		# Find column
		_nColIndex_ = 0
		_cColLabel_ = _combineLabels(_aFlatColValues_)
		
		_nPivotData1Len_ = len(@aPivotData[1])
		for c = len(@aRowLabels) + 1 to _nPivotData1Len_
			if @aPivotData[1][c] = _cColLabel_
				_nColIndex_ = c
				exit
			ok
		next
		
		if _nColIndex_ = 0
			return NULL
		ok
		
		return @aPivotData[len(@aPivotData)][_nColIndex_]

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
		
		_aSerializedData_ = [
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
		
		write(cFileName, list2str(_aSerializedData_))

	def LoadFromFile(cFileName)
		# Load pivot table from file
		if not fexists(cFileName)
			stzRaise("File not found: " + cFileName)
		ok
		
		_cContent_ = read(cFileName)
		_aData_ = str2list(_cContent_)
		
		@aRowLabels = _aData_[:RowLabels]
		@aColLabels = _aData_[:ColLabels]
		@aValues = _aData_[:Values]
		@cAggFunc = _aData_[:AggregationFunction]
		@bShowTotalRow = _aData_[:ShowTotalRow]
		@bShowTotalColumn = _aData_[:ShowTotalColumn]
		@cTotalLabel = _aData_[:TotalLabel]
		@cCellNullValue = _aData_[:CellNullValue]
		@cRowLabelsSeparator = _aData_[:RowLabelsSeparator]
		@aPivotData = _aData_[:PivotData]
		
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

		_aPivotData_ = @aPivotData
		_aRowDims_ = @aRowLabels
		_aColDims_ = @aColLabels
		_cTotalLabel_ = @cTotalLabel

		# Initialize column tracking
		_aRowLabelCols_ = []
		_aDataCols_ = []
		_nTotalColIndex_ = 0
	
		_aHeaderRow_ = _aPivotData_[1]
	
		# Process row dimensions - for 1D we only have one
		_aRowLabelCols_ + 1
	
		# Process data columns
		_nHeaderLen_ = len(_aHeaderRow_)
		for i = 2 to _nHeaderLen_
			if _aHeaderRow_[i] = _cTotalLabel_
				_nTotalColIndex_ = i
			else
				_aDataCols_ + i
			ok
		next
	
		# Calculate row label width
		_maxLabelWidth_ = len(_aRowDims_[1])
		_nPivotLen_ = len(_aPivotData_)
		for r = 2 to _nPivotLen_ - 1
			_cellValue_ = "" + _aPivotData_[r][1]
			if len(_cellValue_) > _maxLabelWidth_
				_maxLabelWidth_ = len(_cellValue_)
			ok
		next
		_nRowLabelWidth_ = _maxLabelWidth_ + 2
	
		# Calculate data column widths
		_aDataColWidths_ = []
		_nMinDataWidth_ = 10
		_nDataColsLen_ = len(_aDataCols_)
	
		for i = 1 to _nDataColsLen_
			_colIdx_ = _aDataCols_[i]
			_maxWidth_ = len(_aHeaderRow_[_colIdx_])
		
			for r = 2 to _nPivotLen_
				if _colIdx_ <= len(_aPivotData_[r])
					_cellValue_ = "" + _aPivotData_[r][_colIdx_]
					if len(_cellValue_) > _maxWidth_
						_maxWidth_ = len(_cellValue_)
					ok
				ok
			next
		
			_aDataColWidths_ + @Max([_nMinDataWidth_, _maxWidth_ + 2])
		next
	
		# Calculate total column width
		_nTotalColWidth_ = len(_cTotalLabel_)
		for r = 2 to _nPivotLen_
			if _nTotalColIndex_ <= len(_aPivotData_[r])
				_cellValue_ = "" + _aPivotData_[r][_nTotalColIndex_]
				if len(_cellValue_) > _nTotalColWidth_
					_nTotalColWidth_ = len(_cellValue_)
				ok
			ok
		next
		_nTotalColWidth_ += 2
	
		# Calculate experience column width (sum of data column widths)
		_nExpWidth_ = 0
		_nDataColWidthsLen_ = len(_aDataColWidths_)
		for i = 1 to _nDataColWidthsLen_
			_nExpWidth_ += _aDataColWidths_[i]
		next

		# Add separators length
		_nExpWidth_ += _nDataColsLen_ - 1
	
		# Build table output
		_cOutput_ = ""
	
		# Top border
		_cLine_ = @aBorder[:TopLeft] + StrFill(_nRowLabelWidth_, @aBorder[:Horizontal]) + @aBorder[:TeeDown]
	
		# Experience column group
		_cLine_ += StrFill(_nExpWidth_, @aBorder[:Horizontal])
	
		# Total column
		_cLine_ += @aBorder[:TeeDown] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:TopRight]
		_cOutput_ += _cLine_ + NL
	
		# Experience header row
		_cLine_ = @aBorder[:Vertical]
	
		# Column for row dimension
		_cLine_ += RepeatChar(" ", _nRowLabelWidth_) + @aBorder[:Vertical]

		# Experience header
		_cLine_ += CenterText(@Capitalize(_aColDims_[1]), _nExpWidth_) + @aBorder[:Vertical]
	
		# Median header
		_cLine_ += RepeatChar(" ", _nTotalColWidth_) + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
	
		# Separator after Experience row
		_cLine_ = @aBorder[:Vertical] + StrFill(_nRowLabelWidth_, " ") + @aBorder[:Vertical]
	
		# Sub-headers separator
		pos = 0
		for i = 1 to _nDataColsLen_
			_cLine_ += StrFill(_aDataColWidths_[i], @aBorder[:Horizontal])
			pos += _aDataColWidths_[i]
		
			if i < _nDataColsLen_
				_cLine_ += @aBorder[:TeeDown]
				pos += 1
			ok
		next
	
		_cLine_ += @aBorder[:Vertical] + StrFill(_nTotalColWidth_, " ") + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
	
		# Sub-headers row
		_cLine_ = @aBorder[:Vertical]
	
		# Empty cell for Department column
		_cLine_ += CenterText(@Capitalize(_aRowDims_[1]), _nRowLabelWidth_) + @aBorder[:Vertical]

		# Sub-headers for experience columns
		for i = 1 to _nDataColsLen_
			_colIdx_ = _aDataCols_[i]
			_colHeader_ = _aHeaderRow_[_colIdx_]
			_capitalized_ = StzUpper(StzLeft(_colHeader_, 1)) + StzMid(_colHeader_, 2, StzLen(_colHeader_) - 1)
			_cLine_ += CenterText(_capitalized_, _aDataColWidths_[i])
		
			if i < _nDataColsLen_
				_cLine_ += @aBorder[:Vertical]
			ok
		next
	
		# MEDIAN cell in this row
		_cLine_ += @aBorder[:Vertical] + CenterText(Upper(_cTotalLabel_), _nTotalColWidth_) + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL

		# Separator before data
		_cLine_ = @aBorder[:TeeRight] + StrFill(_nRowLabelWidth_, @aBorder[:Horizontal]) + @aBorder[:Cross]
	
		for i = 1 to _nDataColsLen_
			_cLine_ += StrFill(_aDataColWidths_[i], @aBorder[:Horizontal])
			if i < _nDataColsLen_
				_cLine_ += @aBorder[:Cross]
			ok
		next
	
		_cLine_ += @aBorder[:Cross] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:TeeLeft]
		_cOutput_ += _cLine_ + NL
	
		# Data rows
		for r = 2 to _nPivotLen_ - 1
			_cLine_ = @aBorder[:Vertical]
		
			# Row label
			_rowValue_ = _aPivotData_[r][1]
			_cLine_ += " " + _rowValue_ + StrFill(_nRowLabelWidth_ - len(_rowValue_) - 1, " ") + @aBorder[:Vertical]
		
			# Data cells
			for i = 1 to _nDataColsLen_
				_colIdx_ = _aDataCols_[i]
				value = ""
				if _colIdx_ <= len(_aPivotData_[r])
					value = _aPivotData_[r][_colIdx_]
				ok
			
				if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
					_cLine_ += " " + PadLeft(value, _aDataColWidths_[i] - 2) + " "
				else
					_cLine_ += " " + PadRight(value, _aDataColWidths_[i] - 2) + " "
				ok
			
				if i < _nDataColsLen_
					_cLine_ += @aBorder[:Vertical]
				ok
			next
		
			# Total column
			_totalValue_ = ""
			if _nTotalColIndex_ <= len(_aPivotData_[r])
				_totalValue_ = _aPivotData_[r][_nTotalColIndex_]
			ok

			if isNumber(_totalValue_) or (isString(_totalValue_) and _totalValue_ != "" and isNumber(0 + value))
				_cLine_ += @aBorder[:Vertical] + " " + PadLeft(_totalValue_, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			else
				_cLine_ += @aBorder[:Vertical] + " " + PadRight(_totalValue_, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			ok
		
			_cOutput_ += _cLine_ + NL
		next
	
		# Check if there is a total row
		_hasTotal_ = _nPivotLen_ > 1 and _aPivotData_[_nPivotLen_][1] = _cTotalLabel_
		
		# Bottom border
		if _hasTotal_
			_cLine_ = @aBorder[:BottomLeft] + StrFill(_nRowLabelWidth_, @aBorder[:Horizontal]) + @aBorder[:TeeUp]
		
			for i = 1 to _nDataColsLen_
				_cLine_ += StrFill(_aDataColWidths_[i], @aBorder[:Horizontal])
				if i < _nDataColsLen_
					_cLine_ += @aBorder[:TeeUp]
				ok
			next
		
			_cLine_ += @aBorder[:TeeUp] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
			_cOutput_ += _cLine_ + NL

			# Total row
			_totalRow_ = _aPivotData_[_nPivotLen_]
		
			_cLine_ = "  " + PadLeft(Upper(_totalRow_[1]), _nRowLabelWidth_ - 2) + " " + @aBorder[:Vertical]
		
			for i = 1 to _nDataColsLen_
				_colIdx_ = _aDataCols_[i]
				value = ""
				if _colIdx_ <= len(_totalRow_)
					value = _totalRow_[_colIdx_]
				ok
			
				if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
					_cLine_ += " " + PadLeft(value, _aDataColWidths_[i] - 2) + " "
				else
					_cLine_ += " " + PadRight(value, _aDataColWidths_[i] - 2) + " "
				ok
			
				if i < _nDataColsLen_
					_cLine_ += @aBorder[:Vertical]
				ok
			next
		
			grandTotal = ""
			if _nTotalColIndex_ <= len(_totalRow_)
				grandTotal = _totalRow_[_nTotalColIndex_]
			ok

			if isNumber(grandTotal) or (isString(grandTotal) and grandTotal != "" and isNumber(0 + grandTotal))
				_cLine_ += @aBorder[:Vertical] + " " + PadLeft(grandTotal, _nTotalColWidth_ - 2) + "  "
			else
				_cLine_ += @aBorder[:Vertical] + " " + PadRight(grandTotal, _nTotalColWidth_ - 2) + "  "
			ok
		
			_cOutput_ += _cLine_ + NL
		else
			# Bottom border if no total row
			_cLine_ = @aBorder[:BottomLeft] + StrFill(_nRowLabelWidth_, @aBorder[:Horizontal]) + @aBorder[:TeeUp]
		
			for i = 1 to _nDataColsLen_
				_cLine_ += StrFill(_aDataColWidths_[i], @aBorder[:Horizontal])
				if i < _nDataColsLen_
					_cLine_ += @aBorder[:TeeUp]
				ok
			next
		
			_cLine_ += @aBorder[:TeeUp] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
			_cOutput_ += _cLine_
		ok
	
		? _cOutput_

	  #---------------------------#
	 #   2D Pivot Table Display  #
	#===========================#

	def _showFormattedPivotTable2D()
		# Display 2D pivot table with formatted output

		_aPivotData_ = @aPivotData
		_aRowDims_ = @aRowLabels
		_aColDims_ = @aColLabels
		_cTotalLabel_ = @cTotalLabel

		# Initialize column tracking
		_aRowLabelCols_ = []
		_aDataCols_ = []
		_nTotalColIndex_ = 0
		
		_aHeaderRow_ = _aPivotData_[1]
		
		# Process row dimensions
		_nRowDimsLen_ = len(_aRowDims_)
		for i = 1 to _nRowDimsLen_
			_aRowLabelCols_ + i
		next
		
		# Process data columns
		_nHeaderLen_ = len(_aHeaderRow_)
		for i = _nRowDimsLen_ + 1 to _nHeaderLen_
			if _aHeaderRow_[i] = _cTotalLabel_
				_nTotalColIndex_ = i
			else
				_aDataCols_ + i
			ok
		next
		
		# Parse column dimensions
		_aColDim1Values_ = []
		_aColDim2Values_ = []
		_aColGroups_ = []
		
		_nDataColsLen_ = len(_aDataCols_)
		for i = 1 to _nDataColsLen_
			_colIdx_ = _aDataCols_[i]
			_colHeader_ = _aHeaderRow_[_colIdx_]
			
			if _colHeader_ != ""
				_aParts_ = @split(_colHeader_, "_")
				_dim1Value_ = _aParts_[1]
				_dim2Value_ = _aParts_[2]
				
				if StzFindFirst(_aColDim1Values_, _dim1Value_) = 0
					_aColDim1Values_ + _dim1Value_
				ok
				
				if StzFindFirst(_aColDim2Values_, _dim2Value_) = 0
					_aColDim2Values_ + _dim2Value_
				ok
				
				_key_ = _dim1Value_ + "_" + _dim2Value_
				_aColGroups_[_key_] = _colIdx_
			ok
		next
		
		# Calculate row label widths
		_aRowLabelWidths_ = []
		for i = 1 to _nRowDimsLen_
			_maxWidth_ = len(_aRowDims_[i])
			_nPivotLen_ = len(_aPivotData_)
			
			for r = 2 to _nPivotLen_ - 1
				_cellValue_ = "" + _aPivotData_[r][i]
				if len(_cellValue_) > _maxWidth_
					_maxWidth_ = len(_cellValue_)
				ok
			next
			
			_aRowLabelWidths_ + (_maxWidth_ + 2)
		next
		
		# Calculate data column widths
		_aDataColWidths_ = []
		_nMinDataWidth_ = 10
		_nColDim1ValuesLen_ = len(_aColDim1Values_)
		_nColDim2ValuesLen_ = len(_aColDim2Values_)
		_nPivotLen_ = len(_aPivotData_)
		
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]
			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]
				_key_ = _dim1Value_ + "_" + _dim2Value_
				_colIdx_ = _aColGroups_[_key_]
				
				if _colIdx_ != NULL
					_maxWidth_ = len(_dim2Value_)
					
					for r = 2 to _nPivotLen_
						if _colIdx_ <= len(_aPivotData_[r])
							_cellValue_ = "" + _aPivotData_[r][_colIdx_]
							if len(_cellValue_) > _maxWidth_
								_maxWidth_ = len(_cellValue_)
							ok
						ok
					next
					
					_aDataColWidths_[_key_] = @Max([_nMinDataWidth_, _maxWidth_ + 2])
				ok
			next
		next
		
		# Calculate total column width
		_nTotalColWidth_ = len(_cTotalLabel_)
		
		for r = 2 to _nPivotLen_
			if _nTotalColIndex_ <= len(_aPivotData_[r])
				_cellValue_ = "" + _aPivotData_[r][_nTotalColIndex_]
				if len(_cellValue_) > _nTotalColWidth_
					_nTotalColWidth_ = len(_cellValue_)
				ok
			ok
		next
		
		_nTotalColWidth_ += 2
		
		# Calculate row label section width
		_nRowLabelSectionWidth_ = 0
		_nRowLabelWidthsLen_ = len(_aRowLabelWidths_)
		for i = 1 to _nRowLabelWidthsLen_
			_nRowLabelSectionWidth_ += _aRowLabelWidths_[i]
		next
		_nRowLabelSectionWidth_ += _nRowDimsLen_ - 1
		
		# Build table output
		_cOutput_ = ""
		
		# Top border
		_cLine_ = @aBorder[:TopLeft]
		
		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], @aBorder[:Horizontal])
			if i < _nRowLabelWidthsLen_
				_cLine_ += @aBorder[:Horizontal]
			ok
		next
		
		_cLine_ += @aBorder[:TeeDown]
		
		# Calculate first dimension widths
		_aDim1Widths_ = []
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]
			_dim1Width_ = 0
			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]
				_key_ = _dim1Value_ + "_" + _dim2Value_
				if HasKey(_aDataColWidths_, _key_)
					_dim1Width_ += _aDataColWidths_[_key_]
				ok
			next
			if _nColDim2ValuesLen_ > 1
				_dim1Width_ += _nColDim2ValuesLen_ - 1
			ok
			_aDim1Widths_[_dim1Value_] = _dim1Width_
		next
		
		# Add dimension sections
		for i = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i]
			_cLine_ += StrFill(_aDim1Widths_[_dim1Value_], @aBorder[:Horizontal])
			if i < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:TeeDown]
			ok
		next
		
		_cLine_ += @aBorder[:TeeDown] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:TopRight]
		_cOutput_ += _cLine_ + NL
		
		# First header row
		_cLine_ = @aBorder[:Vertical]
		
		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], " ")
			if i < _nRowLabelWidthsLen_
				_cLine_ += " "
			ok
		next
		
		_cLine_ += @aBorder[:Vertical]
		
		for i = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i]
			_dim1Display_ = Upper(Left(_dim1Value_, 1)) + SubStr(_dim1Value_, 2)
			_cLine_ += CenterText(_dim1Display_, _aDim1Widths_[_dim1Value_])
			
			if i < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:Vertical]
			ok
		next
		
		_cLine_ += @aBorder[:Vertical] + StrFill(_nTotalColWidth_, " ") + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
		
		# Separator after first dimension
		_cLine_ = @aBorder[:Vertical]
		
		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], " ")
		next
		
		_cLine_ += " " + @aBorder[:Vertical]
		
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]
			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]
				_key_ = _dim1Value_ + "_" + _dim2Value_
				if HasKey(_aDataColWidths_, _key_)
					_dim2Width_ = _aDataColWidths_[_key_]
					_cLine_ += StrFill(_dim2Width_, @aBorder[:Horizontal])
					
					if i2 < _nColDim2ValuesLen_
						_cLine_ += @aBorder[:TeeDown]
					ok
				ok
			next
			
			if i1 < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:Cross]
			ok
		next
		
		_cLine_ += @aBorder[:Vertical] + StrFill(_nTotalColWidth_," ") + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
		
		# Second dimension header
		_cLine_ = @aBorder[:Vertical]
		
		for i = 1 to _nRowDimsLen_
			_dim_ = _aRowDims_[i]
			_capitalized_ = StzUpper(StzLeft(_dim_, 1)) + StzMid(_dim_, 2, StzLen(_dim_) - 1)
			_cLine_ += CenterText(_capitalized_, _aRowLabelWidths_[i])
			
			if i < _nRowDimsLen_
				_cLine_ += @aBorder[:Vertical]
			ok
		next
		
		_cLine_ += @aBorder[:Vertical]
		
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]

			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]

				_key_ = _dim1Value_ + "_" + _dim2Value_
				if HasKey(_aDataColWidths_, _key_)
					_oDim2_ = new stzString(_dim2Value_)
					_capitalizedDim2_ = Upper(Left(_dim2Value_, 1)) + _oDim2_.Section(2, _oDim2_.NumberOfChars())
					_cLine_ += CenterText(_capitalizedDim2_, _aDataColWidths_[_key_])
					
					if i2 < _nColDim2ValuesLen_
						_cLine_ += @aBorder[:Vertical]
					ok
				ok
			next
			
			if i1 < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:Vertical]
			ok
		next
		
		_cLine_ += @aBorder[:Vertical] + CenterText(Upper(_cTotalLabel_), _nTotalColWidth_) + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
		
		# Separator before data
		_cLine_ = @aBorder[:TeeRight]
		
		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], @aBorder[:Horizontal])

			if i < _nRowLabelWidthsLen_
				_cLine_ += @aBorder[:TeeDown]
			ok
		next
		
		_cLine_ += @aBorder[:Cross]
		
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]

			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]

				_key_ = _dim1Value_ + "_" + _dim2Value_

				if HasKey(_aDataColWidths_, _key_)
					_cLine_ += StrFill(_aDataColWidths_[_key_], @aBorder[:Horizontal])
					
					if i2 < _nColDim2ValuesLen_
						_cLine_ += @aBorder[:Cross]
					ok
				ok
			next
			
			if i1 < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:Cross]
			ok
		next
		
		_cLine_ += @aBorder[:Cross] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:TeeLeft]
		_cOutput_ += _cLine_ + NL
		
		# Data rows
		_cLastRowDim1_ = NULL
		_nRowDim1Count_ = 0
		
		for r = 2 to _nPivotLen_ - 1
			_cCurrentRowDim1_ = _aPivotData_[r][1]
			
			if _cCurrentRowDim1_ != _cLastRowDim1_
				_nRowDim1Count_++
				_cLastRowDim1_ = _cCurrentRowDim1_
			ok
			
			_cLine_ = @aBorder[:Vertical]
			
			# First dimension
			if _cCurrentRowDim1_ != _aPivotData_[r-1][1] or r = 2
				_cLine_ += " " + _cCurrentRowDim1_ + StrFill(_aRowLabelWidths_[1] - len(_cCurrentRowDim1_) - 1, " ")
			else
				_cLine_ += StrFill(_aRowLabelWidths_[1], " ")
			ok
			
			_cLine_ += @aBorder[:Vertical]
			
			# Second dimension
			_cLine_ += " " + _aPivotData_[r][2] + StrFill(_aRowLabelWidths_[2] - len(_aPivotData_[r][2]) - 1, " ")
			_cLine_ += @aBorder[:Vertical]
			
			# Data cells
			for i1 = 1 to _nColDim1ValuesLen_
				_dim1Value_ = _aColDim1Values_[i1]

				for i2 = 1 to _nColDim2ValuesLen_
					_dim2Value_ = _aColDim2Values_[i2]

					_key_ = _dim1Value_ + "_" + _dim2Value_
					_colIdx_ = _aColGroups_[_key_]
					
					if _colIdx_ != NULL
						value = @if(_colIdx_ <= len(_aPivotData_[r]), _aPivotData_[r][_colIdx_], "")
						
						if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
							_cLine_ += " " + PadLeft(value, _aDataColWidths_[_key_] - 2) + " "
						else
							_cLine_ += " " + PadRight(value, _aDataColWidths_[_key_] - 2) + " "
						ok
						
						if i2 < _nColDim2ValuesLen_
							_cLine_ += @aBorder[:Vertical]
						ok
					ok
				next
				
				if i1 < _nColDim1ValuesLen_
					_cLine_ += @aBorder[:Vertical]
				ok
			next
			
			# Total column
			_totalValue_ = @if(_nTotalColIndex_ <= len(_aPivotData_[r]), _aPivotData_[r][_nTotalColIndex_], "")
			
			if isNumber(_totalValue_) or (isString(_totalValue_) and _totalValue_ != "" and isNumber(0 + value))
				_cLine_ += @aBorder[:Vertical] + " " + PadLeft(_totalValue_, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			else
				_cLine_ += @aBorder[:Vertical] + " " + PadRight(_totalValue_, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			ok
			
			_cOutput_ += _cLine_ + NL
			
			# Add empty line between categories
			if r < _nPivotLen_ - 1 and _cCurrentRowDim1_ != _aPivotData_[r+1][1] and _aPivotData_[r+1][1] != _cTotalLabel_
				_cLine_ = @aBorder[:Vertical]
				_cLine_ += StrFill(_aRowLabelWidths_[1], " ") + @aBorder[:Vertical]
				_cLine_ += StrFill(_aRowLabelWidths_[2], " ") + @aBorder[:Vertical]
				
				for i1 = 1 to _nColDim1ValuesLen_
					_dim1Value_ = _aColDim1Values_[i1]

					for i2 = 1 to _nColDim2ValuesLen_
						_dim2Value_ = _aColDim2Values_[i2]

						_key_ = _dim1Value_ + "_" + _dim2Value_

						if HasKey(_aDataColWidths_, _key_)
							_cLine_ += StrFill(_aDataColWidths_[_key_], " ")
							
							if i2 < _nColDim2ValuesLen_
								_cLine_ += @aBorder[:Vertical]
							ok
						ok
					next
					
					if i1 < _nColDim1ValuesLen_
						_cLine_ += @aBorder[:Vertical]
					ok
				next
				
				_cLine_ += @aBorder[:Vertical] + StrFill(_nTotalColWidth_, " ") + @aBorder[:Vertical]
				_cOutput_ += _cLine_ + NL
			ok
		next
		
		# Bottom border
		_cLine_ = @aBorder[:BottomLeft]
		
		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], @aBorder[:Horizontal])

			if i = 1
				_cLine_ += @aBorder[:TeeUp]
			but i < _nRowLabelWidthsLen_
				_cLine_ += @aBorder[:Cross]
			ok
		next
		
		_cLine_ += @aBorder[:TeeUp]
		
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]

			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]

				_key_ = _dim1Value_ + "_" + _dim2Value_

				if HasKey(_aDataColWidths_, _key_)
					_cLine_ += StrFill(_aDataColWidths_[_key_], @aBorder[:Horizontal])
					
					if i2 < _nColDim2ValuesLen_
						_cLine_ += @aBorder[:TeeUp]
					ok
				ok
			next
			
			if i1 < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:TeeUp]
			ok
		next
		
		_cLine_ += @aBorder[:TeeUp] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
		_cOutput_ += _cLine_ + NL
		
		# Totals row

		if _nPivotLen_ > 1 and _aPivotData_[_nPivotLen_][1] = _cTotalLabel_
			_totalRow_ = _aPivotData_[_nPivotLen_]
			_nLenTotalRow_ = len(_totalRow_)

			_cLine_ = " " + PadLeft(Upper(_totalRow_[1]+" "), _nRowLabelSectionWidth_) + @aBorder[:Vertical]
			
			for i1 = 1 to _nColDim1ValuesLen_
				_dim1Value_ = _aColDim1Values_[i1]

				for i2 = 1 to _nColDim2ValuesLen_
					_dim2Value_ = _aColDim2Values_[i2]

					_key_ = _dim1Value_ + "_" + _dim2Value_
					_colIdx_ = _aColGroups_[_key_]
					
					if _colIdx_ != NULL

						value = @if(_colIdx_ <= _nLenTotalRow_, _totalRow_[_colIdx_], "")
						
						if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
							_cLine_ += " " + PadLeft(value, _aDataColWidths_[_key_] - 2) + " "
						else
							_cLine_ += " " + PadRight(value, _aDataColWidths_[_key_] - 2) + " "
						ok
						
						if _dim2Value_ != _aColDim2Values_[_nColDim2ValuesLen_]
							_cLine_ += @aBorder[:Vertical]
						ok
					ok

				next
				
				if _dim1Value_ != _aColDim1Values_[_nColDim1ValuesLen_]
					_cLine_ += @aBorder[:Vertical]
				ok

			next
		
			grandTotal = @if(_nTotalColIndex_ <= _nLenTotalRow_, _totalRow_[_nTotalColIndex_], "")
			
			if isNumber(grandTotal) or (isString(grandTotal) and grandTotal != "" and isNumber(0 + grandTotal))
				_cLine_ += @aBorder[:Vertical] + " " + PadLeft(grandTotal, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]

			else
				_cLine_ += @aBorder[:Vertical] + " " + PadRight(grandTotal, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			ok
			
			_cOutput_ += _cLine_
		ok

		_cTrimmed_ = trim(_cOutput_)
		? StzLeft(_cTrimmed_, len(_cTrimmed_) - 1) + NL

	#-------------------------------------#
	#  2D PIVOT TABLE DISPLAY - eXTended  #
	#-------------------------------------#

	def _showFormattedPivotTable2DXT(pSubTotal, pGrandTotal)
		if CheckParams()
	
			if isList(pSubTotal) and IsSubTotalNamedParamList(pSubTotal)
				pSubTotal = pSubTotal[2]
			ok
	
			if isList(pGrandTotal) and IsGrandTotalNamedParamList(pGrandTotal)
				pGrandTotal = pGrandTotal[2]
			ok
	
			if NOT (isBoolean(pSubTotal) and isBoolean(pGrandTotal))
				StzRaise("Incorrect param values! pSubTotal and pGrandTotal must be both booleans.")
			ok
		ok
	
		_aPivotData_ = @aPivotData
		_aRowDims_ = @aRowLabels
		_aColDims_ = @aColLabels
		_cTotalLabel_ = @cTotalLabel
	
		# Initialize column tracking
		_aRowLabelCols_ = []
		_aDataCols_ = []
		_nTotalColIndex_ = 0
		
		_aHeaderRow_ = _aPivotData_[1]
		
		# Process row dimensions
		_nRowDimsLen_ = len(_aRowDims_)
		for i = 1 to _nRowDimsLen_
			_aRowLabelCols_ + i
		next
		
		# Process data columns
		_nHeaderLen_ = len(_aHeaderRow_)
		for i = _nRowDimsLen_ + 1 to _nHeaderLen_
			if _aHeaderRow_[i] = _cTotalLabel_
				_nTotalColIndex_ = i
			else
				_aDataCols_ + i
			ok
		next
		
		# Parse column dimensions
		_aColDim1Values_ = []
		_aColDim2Values_ = []
		_aColGroups_ = []
		
		_nDataColsLen_ = len(_aDataCols_)
		for i = 1 to _nDataColsLen_
			_colIdx_ = _aDataCols_[i]
			_colHeader_ = _aHeaderRow_[_colIdx_]
			
			if _colHeader_ != ""
				_aParts_ = @split(_colHeader_, "_")
				_dim1Value_ = _aParts_[1]
				_dim2Value_ = _aParts_[2]
				
				if StzFindFirst(_aColDim1Values_, _dim1Value_) = 0
					_aColDim1Values_ + _dim1Value_
				ok
				
				if StzFindFirst(_aColDim2Values_, _dim2Value_) = 0
					_aColDim2Values_ + _dim2Value_
				ok
				
				_key_ = _dim1Value_ + "_" + _dim2Value_
				_aColGroups_[_key_] = _colIdx_
			ok
		next
		
		# Calculate row label widths
		_aRowLabelWidths_ = []
		for i = 1 to _nRowDimsLen_
			_maxWidth_ = len(_aRowDims_[i])
			_nPivotLen_ = len(_aPivotData_)
			
			# Account for "Sub-total" text if needed
			if pSubTotal and i = 1
				if _maxWidth_ < len("Sub-total")
					_maxWidth_ = len("Sub-total")
				ok
			ok
			
			# Account for "GRAND-TOTAL" text if needed
			if pGrandTotal and i = 1
				if _maxWidth_ < len("GRAND-TOTAL")
					_maxWidth_ = len("GRAND-TOTAL")
				ok
			ok
			
			for r = 2 to _nPivotLen_ - 1
				_cellValue_ = "" + _aPivotData_[r][i]
				if len(_cellValue_) > _maxWidth_
					_maxWidth_ = len(_cellValue_)
				ok
			next
			
			_aRowLabelWidths_ + (_maxWidth_ + 2)
		next
		
		# Calculate data column widths
		_aDataColWidths_ = []
		_nMinDataWidth_ = 10
		_nColDim1ValuesLen_ = len(_aColDim1Values_)
		_nColDim2ValuesLen_ = len(_aColDim2Values_)
		_nPivotLen_ = len(_aPivotData_)
		
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]
			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]
				_key_ = _dim1Value_ + "_" + _dim2Value_
				_colIdx_ = _aColGroups_[_key_]
				
				if _colIdx_ != NULL
					_maxWidth_ = len(_dim2Value_)
					
					for r = 2 to _nPivotLen_
						if _colIdx_ <= len(_aPivotData_[r])
							_cellValue_ = "" + _aPivotData_[r][_colIdx_]
							if len(_cellValue_) > _maxWidth_
								_maxWidth_ = len(_cellValue_)
							ok
						ok
					next
					
					_aDataColWidths_[_key_] = @Max([_nMinDataWidth_, _maxWidth_ + 2])
				ok
			next
		next
		
		# Calculate total column width
		_nTotalColWidth_ = len(_cTotalLabel_)
		
		for r = 2 to _nPivotLen_
			if _nTotalColIndex_ <= len(_aPivotData_[r])
				_cellValue_ = "" + _aPivotData_[r][_nTotalColIndex_]
				if len(_cellValue_) > _nTotalColWidth_
					_nTotalColWidth_ = len(_cellValue_)
				ok
			ok
		next
		
		_nTotalColWidth_ += 2
		
		# Calculate row label section width
		_nRowLabelSectionWidth_ = 0
		_nRowLabelWidthsLen_ = len(_aRowLabelWidths_)
		for i = 1 to _nRowLabelWidthsLen_
			_nRowLabelSectionWidth_ += _aRowLabelWidths_[i]
		next
		_nRowLabelSectionWidth_ += _nRowDimsLen_ - 1
		
		# Initialize totals tracking for subtotals and grand totals
		_aGroupTotals_ = []
		_aGrandTotals_ = []
		
		# Initialize grand totals
		for i = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i]
			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]
				_key_ = _dim1Value_ + "_" + _dim2Value_
				_aGrandTotals_[_key_] = 0
			next
		next
		
		# Add grand total for the total column
		_aGrandTotals_["total"] = 0
		
		# First pass: calculate subtotals and grand totals
		if pSubTotal or pGrandTotal
			_cCurrentGroup_ = ""
			_aGroups_ = []
			
			for r = 2 to _nPivotLen_ - 1
				_cGroup_ = "" + _aPivotData_[r][1]
				
				# Add to group list if new
				if NOT StzFindFirst(_aGroups_, _cGroup_) > 0
					_aGroups_ + _cGroup_
					_aGroupTotals_[_cGroup_] = []
					
					# Initialize group totals for each column combination
					for i1 = 1 to _nColDim1ValuesLen_
						_dim1Value_ = _aColDim1Values_[i1]
						for i2 = 1 to _nColDim2ValuesLen_
							_dim2Value_ = _aColDim2Values_[i2]
							_key_ = _dim1Value_ + "_" + _dim2Value_
							_aGroupTotals_[_cGroup_][_key_] = 0
						next
					next
					
					# Initialize group total for the total column
					_aGroupTotals_[_cGroup_]["total"] = 0
				ok
				
				# Update totals for each data column
				for i1 = 1 to _nColDim1ValuesLen_
					_dim1Value_ = _aColDim1Values_[i1]
					for i2 = 1 to _nColDim2ValuesLen_
						_dim2Value_ = _aColDim2Values_[i2]
						_key_ = _dim1Value_ + "_" + _dim2Value_
						_colIdx_ = _aColGroups_[_key_]
						
						if _colIdx_ != NULL and _colIdx_ <= len(_aPivotData_[r])
							_cellValue_ = _aPivotData_[r][_colIdx_]
							
							if isNumber(_cellValue_) or (isString(_cellValue_) and _cellValue_ != "" and @IsNumberInString(_cellValue_))
								# Update group total
								_aGroupTotals_[_cGroup_][_key_] += (0 + _cellValue_)
								
								# Update grand total
								_aGrandTotals_[_key_] += (0 + _cellValue_)
							ok
						ok
					next
				next
				
				# Update totals for the total column
				if _nTotalColIndex_ <= len(_aPivotData_[r])
					_totalValue_ = _aPivotData_[r][_nTotalColIndex_]
					
					if isNumber(_totalValue_) or (isString(_totalValue_) and _totalValue_ != "" and @IsNumberInString(_totalValue_))
						# Update group total
						_aGroupTotals_[_cGroup_]["total"] += (0 + _totalValue_)
						
						# Update grand total
						_aGrandTotals_["total"] += (0 + _totalValue_)
					ok
				ok
			next
		ok
		
		# Build table output
		_cOutput_ = ""
		
		# Top border
		_cLine_ = @aBorder[:TopLeft] + @aBorder[:Horizontal]
		
		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], @aBorder[:Horizontal])
			if i > 1 and i < _nRowLabelWidthsLen_
				_cLine_ += @aBorder[:TeeDown]
			ok
		next
		
		_cLine_ += @aBorder[:TeeDown]
		
		# Calculate first dimension widths
		_aDim1Widths_ = []
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]
			_dim1Width_ = 0
			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]
				_key_ = _dim1Value_ + "_" + _dim2Value_
				if HasKey(_aDataColWidths_, _key_)
					_dim1Width_ += _aDataColWidths_[_key_]
				ok
			next
			if _nColDim2ValuesLen_ > 1
				_dim1Width_ += _nColDim2ValuesLen_ - 1
			ok
			_aDim1Widths_[_dim1Value_] = _dim1Width_
		next
		
		# Add dimension sections
		for i = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i]
			_cLine_ += StrFill(_aDim1Widths_[_dim1Value_], @aBorder[:Horizontal])
			if i < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:TeeDown]
			ok
		next
		
		_cLine_ += @aBorder[:TeeDown] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:TopRight]
		_cOutput_ += _cLine_ + NL
		
		# First header row
		_cLine_ = @aBorder[:Vertical]
		
		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], " ")
			if i < _nRowLabelWidthsLen_
				_cLine_ += " "
			ok
		next
		
		_cLine_ += @aBorder[:Vertical]
		
		for i = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i]
			_dim1Display_ = Upper(Left(_dim1Value_, 1)) + SubStr(_dim1Value_, 2)
			_cLine_ += CenterText(_dim1Display_, _aDim1Widths_[_dim1Value_])
			
			if i < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:Vertical]
			ok
		next
		
		_cLine_ += @aBorder[:Vertical] + StrFill(_nTotalColWidth_, " ") + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
		
		# Separator after first dimension
		_cLine_ = @aBorder[:Vertical]
		
		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], " ")
		next
		
		_cLine_ += " " + @aBorder[:Vertical]
		
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]
			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]
				_key_ = _dim1Value_ + "_" + _dim2Value_
				if HasKey(_aDataColWidths_, _key_)
					_dim2Width_ = _aDataColWidths_[_key_]
					_cLine_ += StrFill(_dim2Width_, @aBorder[:Horizontal])
					
					if i2 < _nColDim2ValuesLen_
						_cLine_ += @aBorder[:TeeDown]
					ok
				ok
			next
			
			if i1 < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:Cross]
			ok
		next
		
		_cLine_ += @aBorder[:Vertical] + StrFill(_nTotalColWidth_," ") + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
		
		# Second dimension header
		_cLine_ = @aBorder[:Vertical]
		
		for i = 1 to _nRowDimsLen_
			_dim_ = _aRowDims_[i]
			_capitalized_ = StzUpper(StzLeft(_dim_, 1)) + StzMid(_dim_, 2, StzLen(_dim_) - 1)
			_cLine_ += CenterText(_capitalized_, _aRowLabelWidths_[i])
			
			if i < _nRowDimsLen_
				_cLine_ += @aBorder[:Vertical]
			ok
		next
		
		_cLine_ += @aBorder[:Vertical]
		
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]
	
			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]
	
				_key_ = _dim1Value_ + "_" + _dim2Value_
				if HasKey(_aDataColWidths_, _key_)
					_oDim2_ = new stzString(_dim2Value_)
					_capitalizedDim2_ = Upper(Left(_dim2Value_, 1)) + _oDim2_.Section(2, _oDim2_.NumberOfChars())
					_cLine_ += CenterText(_capitalizedDim2_, _aDataColWidths_[_key_])
					
					if i2 < _nColDim2ValuesLen_
						_cLine_ += @aBorder[:Vertical]
					ok
				ok
			next
			
			if i1 < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:Vertical]
			ok
		next
		
		_cLine_ += @aBorder[:Vertical] + CenterText(Upper(_cTotalLabel_), _nTotalColWidth_) + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
		
		# Separator before data
		_cLine_ = @aBorder[:TeeRight]
		
		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], @aBorder[:Horizontal])
	
			if i < _nRowLabelWidthsLen_
				_cLine_ += @aBorder[:TeeDown]
			ok
		next
		
		_cLine_ += @aBorder[:Cross]
		
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]
	
			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]
	
				_key_ = _dim1Value_ + "_" + _dim2Value_
	
				if HasKey(_aDataColWidths_, _key_)
					_cLine_ += StrFill(_aDataColWidths_[_key_], @aBorder[:Horizontal])
					
					if i2 < _nColDim2ValuesLen_
						_cLine_ += @aBorder[:Cross]
					ok
				ok
			next
			
			if i1 < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:Cross]
			ok
		next
		
		_cLine_ += @aBorder[:Cross] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:TeeLeft]
		_cOutput_ += _cLine_ + NL
		
		# Data rows
		_cLastRowDim1_ = NULL
		_nRowDim1Count_ = 0
		
		for r = 2 to _nPivotLen_ - 1
			_cCurrentRowDim1_ = _aPivotData_[r][1]
			
			# If group changed and not first row, print group totals
			
			if _cCurrentRowDim1_ != _cLastRowDim1_
				_nRowDim1Count_++
				_cLastRowDim1_ = _cCurrentRowDim1_
			ok
			
			_cLine_ = @aBorder[:Vertical]
			
			# First dimension
			if _cCurrentRowDim1_ != _aPivotData_[r-1][1] or r = 2
				_cLine_ += " " + _cCurrentRowDim1_ + StrFill(_aRowLabelWidths_[1] - len(_cCurrentRowDim1_) - 1, " ")
			else
				_cLine_ += StrFill(_aRowLabelWidths_[1], " ")
			ok
			
			_cLine_ += @aBorder[:Vertical]
			
			# Second dimension
			_cLine_ += " " + _aPivotData_[r][2] + StrFill(_aRowLabelWidths_[2] - len(_aPivotData_[r][2]) - 1, " ")
			_cLine_ += @aBorder[:Vertical]
			
			# Data cells
			for i1 = 1 to _nColDim1ValuesLen_
				_dim1Value_ = _aColDim1Values_[i1]
	
				for i2 = 1 to _nColDim2ValuesLen_
					_dim2Value_ = _aColDim2Values_[i2]
	
					_key_ = _dim1Value_ + "_" + _dim2Value_
					_colIdx_ = _aColGroups_[_key_]
					
					if _colIdx_ != NULL
						value = @if(_colIdx_ <= len(_aPivotData_[r]), _aPivotData_[r][_colIdx_], "")
						
						if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
							_cLine_ += " " + PadLeft(value, _aDataColWidths_[_key_] - 2) + " "
						else
							_cLine_ += " " + PadRight(value, _aDataColWidths_[_key_] - 2) + " "
						ok
						
						if i2 < _nColDim2ValuesLen_
							_cLine_ += @aBorder[:Vertical]
						ok
					ok
				next
				
				if i1 < _nColDim1ValuesLen_
					_cLine_ += @aBorder[:Vertical]
				ok
			next
			
			# Total column
			_totalValue_ = @if(_nTotalColIndex_ <= len(_aPivotData_[r]), _aPivotData_[r][_nTotalColIndex_], "")
			
			if isNumber(_totalValue_) or (isString(_totalValue_) and _totalValue_ != "" and isNumber(0 + _totalValue_))
				_cLine_ += @aBorder[:Vertical] + " " + PadLeft(_totalValue_, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			else
				_cLine_ += @aBorder[:Vertical] + " " + PadRight(_totalValue_, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			ok
			
			_cOutput_ += _cLine_ + NL
			
			# Add SUM row for each group, including the last one
			if (r < _nPivotLen_ - 1 and _cCurrentRowDim1_ != _aPivotData_[r+1][1] and _aPivotData_[r+1][1] != _cTotalLabel_) or r = _nPivotLen_ - 1
				_cLine_ = @aBorder[:Vertical]
				_cLine_ += StrFill(_aRowLabelWidths_[1], " ") + @aBorder[:Vertical]
				_cLine_ += StrFill(_aRowLabelWidths_[2], " ") + @aBorder[:Vertical]
				
				# Add dashes for data columns
				for i1 = 1 to _nColDim1ValuesLen_
					_dim1Value_ = _aColDim1Values_[i1]
	
					for i2 = 1 to _nColDim2ValuesLen_
						_dim2Value_ = _aColDim2Values_[i2]
	
						_key_ = _dim1Value_ + "_" + _dim2Value_
	
						if HasKey(_aDataColWidths_, _key_)
							_cLine_ += " " + RepeatChar("-", _aDataColWidths_[_key_] - 2) + " "
							
							if i2 < _nColDim2ValuesLen_
								_cLine_ += @aBorder[:Vertical]
							ok
						ok
					next
					
					if i1 < _nColDim1ValuesLen_
						_cLine_ += @aBorder[:Vertical]
					ok
				next
				
				_cLine_ += @aBorder[:Vertical] + " " + RepeatChar("-", _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
				_cOutput_ += _cLine_ + NL
				
				# Add SUM row
				_cLine_ = @aBorder[:Vertical]
				
				# First column
				_cLine_ += " " + PadLeft("SUM", _aRowLabelWidths_[1] - 2) + " " + @aBorder[:Vertical]
				
				# Second column empty but right-aligned
				_cLine_ += " " + PadRight("", _aRowLabelWidths_[2] - 2) + " " + @aBorder[:Vertical]
				
				# Add subtotal values for each data column
				for i1 = 1 to _nColDim1ValuesLen_
					_dim1Value_ = _aColDim1Values_[i1]
	
					for i2 = 1 to _nColDim2ValuesLen_
						_dim2Value_ = _aColDim2Values_[i2]
	
						_key_ = _dim1Value_ + "_" + _dim2Value_
						
						if HasKey(_aDataColWidths_, _key_)
							value = _aGroupTotals_[_cCurrentRowDim1_][_key_]
							
							if isNumber(value) and value != 0
								_cLine_ += " " + PadLeft("" + value, _aDataColWidths_[_key_] - 2) + " "
							else
								_cLine_ += " " + PadLeft("", _aDataColWidths_[_key_] - 2) + " "
							ok
							
							if i2 < _nColDim2ValuesLen_
								_cLine_ += @aBorder[:Vertical]
							ok
						ok
					next
					
					if i1 < _nColDim1ValuesLen_
						_cLine_ += @aBorder[:Vertical]
					ok
				next
				
				# Add subtotal for total column
				value = _aGroupTotals_[_cCurrentRowDim1_]["total"]
				
				if isNumber(value) and value != 0
					_cLine_ += @aBorder[:Vertical] + " " + PadLeft("" + value, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
				else
					_cLine_ += @aBorder[:Vertical] + " " + PadLeft("", _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
				ok
				
				_cOutput_ += _cLine_ + NL
				
				# Add empty line after subtotals
	
				_cLine_ = @aBorder[:Vertical]
				_cLine_ += StrFill(_aRowLabelWidths_[1]+1, " ") //+ @aBorder[:Vertical]
				_cLine_ += StrFill(_aRowLabelWidths_[2]+1, " ") //+ @aBorder[:Vertical]
				
				for i1 = 1 to _nColDim1ValuesLen_
					_dim1Value_ = _aColDim1Values_[i1]
	
					for i2 = 1 to _nColDim2ValuesLen_
						_dim2Value_ = _aColDim2Values_[i2]
	
						_key_ = _dim1Value_ + "_" + _dim2Value_
	
						if HasKey(_aDataColWidths_, _key_)
							_cLine_ += StrFill(_aDataColWidths_[_key_], " ")
							
						ok
					next
					
				next
				
				_cLine_ += "  " + StrFill(_nTotalColWidth_+2, " ") + @aBorder[:Vertical]
				_cOutput_ += _cLine_ + NL
	
			ok
		next
		
		# Bottom border
		_cLine_ = @aBorder[:BottomLeft]
		
		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], @aBorder[:Horizontal])
	
			if i = 1
				_cLine_ += @aBorder[:Horizontal]
			but i < _nRowLabelWidthsLen_
				_cLine_ += @aBorder[:Cross]
			ok
		next
		
		_cLine_ += @aBorder[:Horizontal]
		
		for i1 = 1 to _nColDim1ValuesLen_
			_dim1Value_ = _aColDim1Values_[i1]
	
			for i2 = 1 to _nColDim2ValuesLen_
				_dim2Value_ = _aColDim2Values_[i2]
	
				_key_ = _dim1Value_ + "_" + _dim2Value_
	
				if HasKey(_aDataColWidths_, _key_)
					_cLine_ += StrFill(_aDataColWidths_[_key_], @aBorder[:Horizontal])
					
					if i2 < _nColDim2ValuesLen_
						_cLine_ += @aBorder[:Horizontal]
					ok
				ok
			next
			
			if i1 < _nColDim1ValuesLen_
				_cLine_ += @aBorder[:Horizontal]
			ok
		next
		
		_cLine_ += @aBorder[:Horizontal] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
		_cOutput_ += _cLine_ + NL
		
		# Totals row
		if _nPivotLen_ > 1 and _aPivotData_[_nPivotLen_][1] = _cTotalLabel_
			_totalRow_ = _aPivotData_[_nPivotLen_]
			_nLenTotalRow_ = len(_totalRow_)
	
			_cLine_ = " " + PadLeft(Upper(_totalRow_[1]+" "), _nRowLabelSectionWidth_) + @aBorder[:Vertical]
			
			for i1 = 1 to _nColDim1ValuesLen_
				_dim1Value_ = _aColDim1Values_[i1]
	
				for i2 = 1 to _nColDim2ValuesLen_
					_dim2Value_ = _aColDim2Values_[i2]
	
					_key_ = _dim1Value_ + "_" + _dim2Value_
					_colIdx_ = _aColGroups_[_key_]
					
					if _colIdx_ != NULL
						value = @if(_colIdx_ <= _nLenTotalRow_, _totalRow_[_colIdx_], "")
						
						if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
							_cLine_ += " " + PadLeft(value, _aDataColWidths_[_key_] - 2) + " "
						else
							_cLine_ += " " + PadRight(value, _aDataColWidths_[_key_] - 2) + " "
						ok
						
						if _dim2Value_ != _aColDim2Values_[_nColDim2ValuesLen_]
							_cLine_ += @aBorder[:Vertical]
						ok
					ok
				next
				
				if _dim1Value_ != _aColDim1Values_[_nColDim1ValuesLen_]
					_cLine_ += @aBorder[:Vertical]
				ok
			next
		
			grandTotal = @if(_nTotalColIndex_ <= _nLenTotalRow_, _totalRow_[_nTotalColIndex_], "")
			
			if isNumber(grandTotal) or (isString(grandTotal) and grandTotal != "" and isNumber(0 + grandTotal))
				_cLine_ += @aBorder[:Vertical] + " " + PadLeft(grandTotal, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			else
				_cLine_ += @aBorder[:Vertical] + " " + PadRight(grandTotal, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			ok
			
			_cOutput_ += _cLine_
		ok
	
		_cTrimmed_ = trim(_cOutput_)
		? StzLeft(_cTrimmed_, len(_cTrimmed_) - 1) + NL
	
	  #------------------------------------------#
	 #  1D Rows 2D Columns Pivot Table Display  #
	#==========================================#

	def _showFormattedPivotTable1DRows2DCols()
		# Display pivot table with 1D rows and 2D columns with formatted output

		_aPivotData_ = @aPivotData
		_aRowDims_ = @aRowLabels
		_aColDims_ = @aColLabels
		_cTotalLabel_ = @cTotalLabel

		# Initialize column tracking

		_aRowLabelCols_ = []
		_aDataCols_ = []
		_nTotalColIndex_ = 0
	
		_aHeaderRow_ = _aPivotData_[1]
	
		# Process row dimensions - only use the first row dimension

		_aRowLabelCols_ = _aRowLabelCols_ + 1  # We only use the first row dimension
	
		# Process data columns
		_nHeaderLen_ = len(_aHeaderRow_)
		for i = 2 to _nHeaderLen_  # Start from 2 since we only have 1 row dimension

			if _aHeaderRow_[i] = _cTotalLabel_
				_nTotalColIndex_ = i
			else
				_aDataCols_ = _aDataCols_ + i
			ok

		next
	
		# Parse column dimensions

		_aColDim1Values_ = []
		_aColDim2Values_ = []
		_aColGroups_ = []
	
		_nDataColsLen_ = len(_aDataCols_)

		for i = 1 to _nDataColsLen_

			_colIdx_ = _aDataCols_[i]
			_colHeader_ = _aHeaderRow_[_colIdx_]
		
			if _colHeader_ != ""
				_aParts_ = split(_colHeader_, "_")
				_dim1Value_ = _aParts_[1]
				_dim2Value_ = _aParts_[2]
			
				if StzFindFirst(_aColDim1Values_, _dim1Value_) = 0
					_aColDim1Values_ = _aColDim1Values_ + _dim1Value_
				ok
			
				if StzFindFirst(_aColDim2Values_, _dim2Value_) = 0
					_aColDim2Values_ = _aColDim2Values_ + _dim2Value_
				ok
			
				_key_ = _dim1Value_ + "_" + _dim2Value_
				_aColGroups_[_key_] = _colIdx_
			ok

		next
	
		# Calculate row label width

		_nRowLabelWidth_ = len(_aRowDims_[1])  # This is the first (and only) row dimension
		_nLenPivotData_ = len(_aPivotData_)

		for r = 2 to _nLenPivotData_ - 1

			_cellValue_ = "" + _aPivotData_[r][1]

			if len(_cellValue_) > _nRowLabelWidth_
				_nRowLabelWidth_ = len(_cellValue_)
			ok

		next
	
		_nRowLabelWidth_ += 2  # Add padding
	
		# Calculate data column widths

		_aDataColWidths_ = []
		_nMinDataWidth_ = 10
		
		_nColDim1Len_ = len(_aColDim1Values_)
		_nColDim2Len_ = len(_aColDim2Values_)
	
		for i = 1 to _nColDim1Len_
			_dim1Value_ = _aColDim1Values_[i]

			for j = 1 to _nColDim2Len_
				_dim2Value_ = _aColDim2Values_[j]

				_key_ = _dim1Value_ + "_" + _dim2Value_
				_colIdx_ = _aColGroups_[_key_]
			
				if _colIdx_ != NULL
					_maxWidth_ = len(_dim2Value_)
				
					for r = 2 to _nLenPivotData_

						if _colIdx_ <= len(_aPivotData_[r])

							_cellValue_ = "" + _aPivotData_[r][_colIdx_]

							if len(_cellValue_) > _maxWidth_
								_maxWidth_ = len(_cellValue_)
							ok

						ok

					next
				
					_aDataColWidths_[_key_] = @Max([_nMinDataWidth_, _maxWidth_ + 2])
				ok

			next

		next
	
		# Calculate total column width

		_nTotalColWidth_ = len(_cTotalLabel_)
	
		for r = 2 to _nLenPivotData_

			if _nTotalColIndex_ <= len(_aPivotData_[r])

				_cellValue_ = "" + _aPivotData_[r][_nTotalColIndex_]

				if len(_cellValue_) > _nTotalColWidth_
					_nTotalColWidth_ = len(_cellValue_)
				ok

			ok

		next
	
		_nTotalColWidth_ += 2
	
		# Build table output

		_cOutput_ = ""
	
		# Top border

		_cLine_ = @aBorder[:TopLeft] + StrFill(_nRowLabelWidth_, @aBorder[:Horizontal]) + @aBorder[:TeeDown]
	
		# Calculate first dimension widths

		_aDim1Widths_ = []

		for i = 1 to _nColDim1Len_
			_dim1Value_ = _aColDim1Values_[i]

			_dim1Width_ = 0

			for j = 1 to _nColDim2Len_
				_dim2Value_ = _aColDim2Values_[j]

				_key_ = _dim1Value_ + "_" + _dim2Value_

				if HasKey(_aDataColWidths_, _key_)
					_dim1Width_ += _aDataColWidths_[_key_]
				ok

			next

			if _nColDim2Len_ > 1
				_dim1Width_ += _nColDim2Len_ - 1
			ok

			_aDim1Widths_[_dim1Value_] = _dim1Width_

		next
	
		# Add dimension sections

		for i = 1 to _nColDim1Len_
			_dim1Value_ = _aColDim1Values_[i]

			_cLine_ += StrFill(_aDim1Widths_[_dim1Value_], @aBorder[:Horizontal])

			if i < _nColDim1Len_
				_cLine_ += @aBorder[:TeeDown]
			ok

		next
	
		_cLine_ += @aBorder[:TeeDown] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:TopRight]
		_cOutput_ += _cLine_ + NL
	
		# First header row - column dimension 1
		# First cell is empty in the first row

		_cLine_ = @aBorder[:Vertical] + StrFill(_nRowLabelWidth_, " ") + @aBorder[:Vertical]
	
		for i = 1 to _nColDim1Len_
			_dim1Value_ = _aColDim1Values_[i]
			_dim1Display_ = Upper(Left(_dim1Value_, 1)) + SubStr(_dim1Value_, 2)
			_cLine_ += CenterText(_dim1Display_, _aDim1Widths_[_dim1Value_])
		
			if i < _nColDim1Len_
				_cLine_ += @aBorder[:Vertical]
			ok

		next
	
		# Last column in the first row should also be empty

		_cLine_ += @aBorder[:Vertical] + StrFill(_nTotalColWidth_, " ") + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
	
		# Separator between column dimensions - hide the Department header cell's top border

		_cLine_ = @aBorder[:Vertical] + StrFill(_nRowLabelWidth_, " ") + @aBorder[:Vertical]
	
		for i = 1 to _nColDim1Len_
			_dim1Value_ = _aColDim1Values_[i]

			for j = 1 to _nColDim2Len_
				_dim2Value_ = _aColDim2Values_[j]

				_key_ = _dim1Value_ + "_" + _dim2Value_

				if HasKey(_aDataColWidths_, _key_)

					_dim2Width_ = _aDataColWidths_[_key_]
					_cLine_ += StrFill(_dim2Width_, @aBorder[:Horizontal])
				
					if j < _nColDim2Len_
						_cLine_ += @aBorder[:TeeDown]
					ok

				ok

			next
		
			if i < _nColDim1Len_
				_cLine_ += @aBorder[:Vertical]
			ok

		next
	
		_cLine_ += @aBorder[:Vertical] + StrFill(_nTotalColWidth_, " ") + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
	
		# Second dimension header - row and column dimension 2
		_cLine_ = @aBorder[:Vertical]
	
		# Row dimension header

		_dim_ = _aRowDims_[1]
		_oDim_ = StzStringQ(_dim_)
		_capitalized_ = Upper(Left(_dim_, 1)) + _oDim_.Section(2, _oDim_.NumberOfChars())
		_cLine_ += CenterText(_capitalized_, _nRowLabelWidth_) + @aBorder[:Vertical]
	
		# Column dimension 2 headers

		for i = 1 to _nColDim1Len_
			_dim1Value_ = _aColDim1Values_[i]

			for j = 1 to _nColDim2Len_
				_dim2Value_ = _aColDim2Values_[j]

				_key_ = _dim1Value_ + "_" + _dim2Value_

				if HasKey(_aDataColWidths_, _key_)

					_oDim2_ = new stzString(_dim2Value_)
					_capitalizedDim2_ = Upper(Left(_dim2Value_, 1)) + _oDim2_.Section(2, _oDim2_.NumberOfChars())
					_cLine_ += CenterText(_capitalizedDim2_, _aDataColWidths_[_key_])
				
					if j < _nColDim2Len_
						_cLine_ += @aBorder[:Vertical]
					ok

				ok

			next
		
			if i < _nColDim1Len_
				_cLine_ += @aBorder[:Vertical]
			ok

		next
	
		_cLine_ += @aBorder[:Vertical] + CenterText(Upper(_cTotalLabel_), _nTotalColWidth_) + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
	
		# Separator before data

		_cLine_ = @aBorder[:TeeRight] + StrFill(_nRowLabelWidth_, @aBorder[:Horizontal]) + @aBorder[:Cross]
	
		for i = 1 to _nColDim1Len_
			_dim1Value_ = _aColDim1Values_[i]

			for j = 1 to _nColDim2Len_
				_dim2Value_ = _aColDim2Values_[j]

				_key_ = _dim1Value_ + "_" + _dim2Value_

				if HasKey(_aDataColWidths_, _key_)

					_cLine_ += StrFill(_aDataColWidths_[_key_], @aBorder[:Horizontal])
				
					if j < _nColDim2Len_
						_cLine_ += @aBorder[:Cross]
					ok

				ok

			next
		
			if i < _nColDim1Len_
				_cLine_ += @aBorder[:Cross]
			ok

		next
	
		_cLine_ += @aBorder[:Cross] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:TeeLeft]
		_cOutput_ += _cLine_ + NL
	
		# Data rows

		for r = 2 to _nLenPivotData_ - 1

			_cLine_ = @aBorder[:Vertical] + " " + _aPivotData_[r][1] + StrFill(_nRowLabelWidth_ - len(_aPivotData_[r][1]) - 1, " ") + @aBorder[:Vertical]
		
			# Data cells

			for i = 1 to _nColDim1Len_
				_dim1Value_ = _aColDim1Values_[i]

				for j = 1 to _nColDim2Len_
					_dim2Value_ = _aColDim2Values_[j]

					_key_ = _dim1Value_ + "_" + _dim2Value_
					_colIdx_ = _aColGroups_[_key_]
				
					if _colIdx_ != NULL
						value = @if(_colIdx_ <= len(_aPivotData_[r]), _aPivotData_[r][_colIdx_], "")
					
						if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
							_cLine_ += " " + PadLeft(value, _aDataColWidths_[_key_] - 2) + " "
						else
							_cLine_ += " " + PadRight(value, _aDataColWidths_[_key_] - 2) + " "
						ok
					
						if j < _nColDim2Len_
							_cLine_ += @aBorder[:Vertical]
						ok
					ok

				next
			
				if i < _nColDim1Len_
					_cLine_ += @aBorder[:Vertical]
				ok

			next
		
			# Total column

			_totalValue_ = @if(_nTotalColIndex_ <= len(_aPivotData_[r]), _aPivotData_[r][_nTotalColIndex_], "")

			if isNumber(_totalValue_) or (isString(_totalValue_) and _totalValue_ != "" and isNumber(0 + value))
				_cLine_ += @aBorder[:Vertical] + " " + PadLeft(_totalValue_, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]

			else
				_cLine_ += @aBorder[:Vertical] + " " + PadRight(_totalValue_, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			ok
		
			_cOutput_ += _cLine_ + NL

		next
	
		# Bottom border

		_cLine_ = @aBorder[:BottomLeft] + StrFill(_nRowLabelWidth_, @aBorder[:Horizontal]) + @aBorder[:TeeUp]
	
		for i = 1 to _nColDim1Len_
			_dim1Value_ = _aColDim1Values_[i]

			for j = 1 to _nColDim2Len_
				_dim2Value_ = _aColDim2Values_[j]

				_key_ = _dim1Value_ + "_" + _dim2Value_

				if HasKey(_aDataColWidths_, _key_)

					_cLine_ += StrFill(_aDataColWidths_[_key_], @aBorder[:Horizontal])
				
					if j < _nColDim2Len_
						_cLine_ += @aBorder[:TeeUp]
					ok
				ok

			next
		
			if i < _nColDim1Len_
				_cLine_ += @aBorder[:TeeUp]
			ok

		next
	
		_cLine_ += @aBorder[:TeeUp] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
		_cOutput_ += _cLine_ + NL
	
		# Totals row

		if _nLenPivotData_ > 1 and _aPivotData_[_nLenPivotData_][1] = _cTotalLabel_

			_totalRow_ = _aPivotData_[_nLenPivotData_]
			_nLenTotalRow_ = len(_totalRow_)
		
			# Format the AVERAGE label with right alignment followed by a space

			_cLine_ = " " + PadLeft(Upper(_totalRow_[1]), _nRowLabelWidth_ - 1) + " " + @aBorder[:Vertical]
		
			for i = 1 to _nColDim1Len_
				_dim1Value_ = _aColDim1Values_[i]

				for j = 1 to _nColDim2Len_
					_dim2Value_ = _aColDim2Values_[j]

					_key_ = _dim1Value_ + "_" + _dim2Value_
					_colIdx_ = _aColGroups_[_key_]
				
					if _colIdx_ != NULL

						value = @if(_colIdx_ <= _nLenTotalRow_, _totalRow_[_colIdx_], "")
					
						if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
							_cLine_ += " " + PadLeft(value, _aDataColWidths_[_key_] - 2) + " "

						else
							_cLine_ += " " + PadRight(value, _aDataColWidths_[_key_] - 2) + " "
						ok
					
						if j < _nColDim2Len_
							_cLine_ += @aBorder[:Vertical]
						ok

					ok

				next
			
				if i < _nColDim1Len_
					_cLine_ += @aBorder[:Vertical]
				ok

			next
		
			grandTotal = @if(_nTotalColIndex_ <= _nLenTotalRow_, _totalRow_[_nTotalColIndex_], "")
		
			if isNumber(grandTotal) or (isString(grandTotal) and grandTotal != "" and isNumber(0 + grandTotal))
				_cLine_ += @aBorder[:Vertical] + " " + PadLeft(grandTotal, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]

			else
				_cLine_ += @aBorder[:Vertical] + " " + PadRight(grandTotal, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			ok
		
			_cOutput_ += _cLine_
		
			# No final bottom border after totals
		ok

		_cTrimmed_ = trim(_cOutput_)
		? StzLeft(_cTrimmed_, len(_cTrimmed_) - 1) + NL

	  #------------------------------------------#
	 #  2D Rows 1D Columns Pivot Table Display  #
	#------------------------------------------#

	def _showFormattedPivotTable2DRows1DCols()
		# Display pivot table with formatted output - for mixed dimensions

		_aPivotData_ = @aPivotData
		_aRowDims_ = @aRowLabels
		_aColDims_ = @aColLabels
		_cTotalLabel_ = @cTotalLabel
		_nLenPivotData_ = len(_aPivotData_)
	
		# Initialize column tracking

		_aRowLabelCols_ = []
		_aDataCols_ = []
		_nTotalColIndex_ = 0
	
		_aHeaderRow_ = _aPivotData_[1]
	
		# Process row dimensions - for 2D we have two

		_aRowLabelCols_ + 1
		_aRowLabelCols_ + 2
	
		# Process data columns

		_nHeaderLen_ = len(_aHeaderRow_)
		for i = 3 to _nHeaderLen_
			if _aHeaderRow_[i] = _cTotalLabel_
				_nTotalColIndex_ = i
			else
				_aDataCols_ + i
			ok
		next
	
		# Calculate row label widths

		_aRowLabelWidths_ = [0, 0]  # One for each dimension
	
		# First dimension

		_maxLabelWidth_ = len(_aRowDims_[1])

		for r = 2 to _nLenPivotData_ - 1
			if r = 2  # Skip header row
				loop
			ok

			_cellValue_ = "" + _aPivotData_[r][1]

			if len(_cellValue_) > _maxLabelWidth_
				_maxLabelWidth_ = len(_cellValue_)
			ok
		next

		_aRowLabelWidths_[1] = _maxLabelWidth_ + 2
	
		# Second dimension

		_maxLabelWidth_ = len(_aRowDims_[2])

		for r = 2 to _nLenPivotData_ - 1
			if r = 2  # Skip header row
				loop
			ok

			_cellValue_ = "" + _aPivotData_[r][2]

			if len(_cellValue_) > _maxLabelWidth_
				_maxLabelWidth_ = len(_cellValue_)
			ok
		next

		_aRowLabelWidths_[2] = _maxLabelWidth_ + 2
	
		# Calculate data column widths

		_aDataColWidths_ = []
		_nMinDataWidth_ = 10
		_nDataColsLen_ = len(_aDataCols_)
	
		for i = 1 to _nDataColsLen_
			_colIdx_ = _aDataCols_[i]
			_maxWidth_ = len(_aHeaderRow_[_colIdx_])
		
			for r = 2 to _nLenPivotData_

				if _colIdx_ <= len(_aPivotData_[r])

					_cellValue_ = "" + _aPivotData_[r][_colIdx_]

					if len(_cellValue_) > _maxWidth_
						_maxWidth_ = len(_cellValue_)
					ok
				ok

			next
		
			_aDataColWidths_ + @Max([_nMinDataWidth_, _maxWidth_ + 2])
		next
	
		# Calculate total column width
		_nTotalColWidth_ = len(_cTotalLabel_)

		for r = 2 to _nLenPivotData_

			if _nTotalColIndex_ <= len(_aPivotData_[r])

				_cellValue_ = "" + _aPivotData_[r][_nTotalColIndex_]

				if len(_cellValue_) > _nTotalColWidth_
					_nTotalColWidth_ = len(_cellValue_)
				ok

			ok
		next

		_nTotalColWidth_ += 2
	
		# Build table output

		_cOutput_ = ""
	
		# Top border

		_cLine_ = @aBorder[:TopLeft]
		_nRowLabelWidthsLen_ = len(_aRowLabelWidths_)

		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], @aBorder[:Horizontal])

			if i = 1
				_cLine_ += @aBorder[:Horizontal]
			else
				_cLine_ += @aBorder[:TeeDown]
			ok
		next
	
		# Calculate combined width of data columns

		_nCombinedDataWidth_ = 0
		_nDataColWidthsLen_ = len(_aDataColWidths_)

		for i = 1 to _nDataColWidthsLen_
			_nCombinedDataWidth_ += _aDataColWidths_[i]

			if i < _nDataColWidthsLen_
				_nCombinedDataWidth_ += 1  # For the vertical border
			ok
		next
	
		# Add horizontal line for the combined data column header

		_cLine_ += StrFill(_nCombinedDataWidth_, @aBorder[:Horizontal])
		_cLine_ += @aBorder[:TeeDown] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:TopRight]
		_cOutput_ += _cLine_ + NL
	
		# First header row with main label spanning data columns

		_cLine_ = @aBorder[:Vertical]
	
		# Columns for row dimensions

		_cRowDimsWidth_ = 0
		for i = 1 to _nRowLabelWidthsLen_
			_cRowDimsWidth_ += _aRowLabelWidths_[i]
		next
		_cRowDimsWidth_ += 1  # For the vertical separator
	
		_cLine_ += StrFill(_cRowDimsWidth_, " ") + @aBorder[:Vertical]
	
		# The main raw label centered across all data columns

		_cLine_ += CenterText(@Capitalize(_aColDims_[1]), _nCombinedDataWidth_)
		_cLine_ += @aBorder[:Vertical] + RepeatChar(" ", _nTotalColWidth_) + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
	
		# Separator after main raw header

		_cLine_ = @aBorder[:Vertical]

		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], " ")

			if i < _nRowLabelWidthsLen_
				_cLine_ += " "
			else
				_cLine_ += @aBorder[:Vertical]
			ok
		next
	
		# Add horizontal line separators under the main raw label

		for i = 1 to _nDataColsLen_
			_cLine_ += StrFill(_aDataColWidths_[i], @aBorder[:Horizontal])

			if i < _nDataColsLen_
				_cLine_ += @aBorder[:TeeDown]
			ok
		next
	
		_cLine_ += @aBorder[:Vertical] + StrFill(_nTotalColWidth_, " ") + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
	
		# Second header row with dimension names

		_cLine_ = @aBorder[:Vertical]
		_nRowDimsLen_ = len(_aRowDims_)
	
		# Columns for row dimensions

		_oDimStrList_ = []
		for i = 1 to _nRowDimsLen_
			_oDimStrList_ + new stzString(_aRowDims_[i])
		next

		for i = 1 to _nRowDimsLen_
			_dimName_ = _aRowDims_[i]
			_oDim_ = _oDimStrList_[i]
			_capitalized_ = Upper(Left(_dimName_, 1)) + _oDim_.Section(2, _oDim_.NumberOfChars())
			_cLine_ += CenterText(_capitalized_, _aRowLabelWidths_[i]) + @aBorder[:Vertical]
		next
	
		# Header for data columns

		_oColHeaderStrList_ = []
		for i = 1 to _nDataColsLen_
			_colIdx_ = _aDataCols_[i]
			_colHeader_ = _aHeaderRow_[_colIdx_]
			_oColHeaderStrList_ + StzStringQ(_colHeader_)
		next

		for i = 1 to _nDataColsLen_
			_colIdx_ = _aDataCols_[i]
			_colHeader_ = _aHeaderRow_[_colIdx_]
			_oDim_ = _oColHeaderStrList_[i]
			_capitalized_ = Upper(Left(_colHeader_, 1)) + _oDim_.Section(2, _oDim_.NumberOfChars())
			_cLine_ += CenterText(_capitalized_, _aDataColWidths_[i])
		
			if i < _nDataColsLen_
				_cLine_ += @aBorder[:Vertical]
			ok
		next
	
		_cLine_ += @aBorder[:Vertical] + CenterText(Upper(_cTotalLabel_), _nTotalColWidth_) + @aBorder[:Vertical]
		_cOutput_ += _cLine_ + NL
	
		# Separator before data

		_cLine_ = @aBorder[:TeeRight]

		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], @aBorder[:Horizontal])
			if i < _nRowLabelWidthsLen_
				_cLine_ += @aBorder[:TeeDown]
			else
				_cLine_ += @aBorder[:Cross]
			ok
		next
	
		for i = 1 to _nDataColsLen_
			_cLine_ += StrFill(_aDataColWidths_[i], @aBorder[:Horizontal])
			if i < _nDataColsLen_
				_cLine_ += @aBorder[:Cross]
			ok
		next
	
		_cLine_ += @aBorder[:Cross] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:TeeLeft]
		_cOutput_ += _cLine_ + NL
	
		# Data rows

		_lastDim1Value_ = ""

		for r = 3 to _nLenPivotData_ - 1
			_cLine_ = @aBorder[:Vertical]
		
			# Row labels - handle merging for first dimension

			_dim1Value_ = ''+ _aPivotData_[r][1]

			if _dim1Value_ = _lastDim1Value_
				_cLine_ += " " + StrFill(_aRowLabelWidths_[1] - 2, " ") + " " + @aBorder[:Vertical]
			else
				_cLine_ += " " + _dim1Value_ + StrFill(_aRowLabelWidths_[1] - len(_dim1Value_) - 1, " ") + @aBorder[:Vertical]
				_lastDim1Value_ = _dim1Value_
			ok
		
			# Second dimension

			_dim2Value_ = ''+ _aPivotData_[r][2]
			_cLine_ += " " + _dim2Value_ + StrFill(_aRowLabelWidths_[2] - len(_dim2Value_) - 1, " ") + @aBorder[:Vertical]
		
			# Data cells

			for i = 1 to _nDataColsLen_
				_colIdx_ = _aDataCols_[i]
				value = ""

				if _colIdx_ <= len(_aPivotData_[r])
					value = _aPivotData_[r][_colIdx_]
				ok
			
				if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
					_cLine_ += " " + PadLeft(value, _aDataColWidths_[i] - 2) + " "

				else
					_cLine_ += " " + PadRight(value, _aDataColWidths_[i] - 2) + " "
				ok
			
				if i < _nDataColsLen_
					_cLine_ += @aBorder[:Vertical]
				ok

			next
		
			# Total column

			_totalValue_ = ""

			if _nTotalColIndex_ <= len(_aPivotData_[r])
				_totalValue_ = _aPivotData_[r][_nTotalColIndex_]
			ok
		
			if isNumber(_totalValue_) or (isString(_totalValue_) and _totalValue_ != "" and isNumber(0 + value))
				_cLine_ += @aBorder[:Vertical] + " " + PadLeft(_totalValue_, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			else
				_cLine_ += @aBorder[:Vertical] + " " + PadRight(_totalValue_, _nTotalColWidth_ - 2) + " " + @aBorder[:Vertical]
			ok
		
			_cOutput_ += _cLine_ + NL
		
			# Add subtotal separator if needed

			if r < _nLenPivotData_ - 1 and _aPivotData_[r+1][1] != _aPivotData_[r][1] and _aPivotData_[r+1][1] != _cTotalLabel_

				_cLine_ = @aBorder[:Vertical] + StrFill(_aRowLabelWidths_[1], " ") + 
						@aBorder[:Vertical] + StrFill(_aRowLabelWidths_[2], " ") + @aBorder[:Vertical]
			
				for i = 1 to _nDataColsLen_

					_cLine_ += StrFill(_aDataColWidths_[i], " ")

					if i < _nDataColsLen_
						_cLine_ += @aBorder[:Vertical]
					ok

				next
			
				_cLine_ += @aBorder[:Vertical] + StrFill(_nTotalColWidth_, " ") + @aBorder[:Vertical]
				_cOutput_ += _cLine_ + NL

			ok
		next
	
		# Bottom border

		_cLine_ = @aBorder[:BottomLeft]

		for i = 1 to _nRowLabelWidthsLen_
			_cLine_ += StrFill(_aRowLabelWidths_[i], @aBorder[:Horizontal])
			_cLine_ += @aBorder[:TeeUp]
		next
	
		for i = 1 to _nDataColsLen_

			_cLine_ += StrFill(_aDataColWidths_[i], @aBorder[:Horizontal])

			if i < _nDataColsLen_
				_cLine_ += @aBorder[:TeeUp]
			ok

		next
	
		_cLine_ += @aBorder[:TeeUp] + StrFill(_nTotalColWidth_, @aBorder[:Horizontal]) + @aBorder[:BottomRight]
		_cOutput_ += _cLine_ + NL
	
		# Total row

		_totalRow_ = _aPivotData_[_nLenPivotData_]
	
		_cLine_ = "  " + PadLeft(Upper(_totalRow_[1]), _aRowLabelWidths_[1] + _aRowLabelWidths_[2] - 1) + " " + @aBorder[:Vertical]

		for i = 1 to _nDataColsLen_

			_colIdx_ = _aDataCols_[i]
			value = ""

			if _colIdx_ <= len(_totalRow_)
				value = _totalRow_[_colIdx_]
			ok

			if isNumber(value) or (isString(value) and value != "" and isNumber(0 + value))
				_cLine_ += " " + PadLeft(value, _aDataColWidths_[i] - 2) + " "

			else
				_cLine_ += " " + PadRight(value, _aDataColWidths_[i] - 2) + " "
			ok
		
			if i < _nDataColsLen_
				_cLine_ += @aBorder[:Vertical]
			ok

		next
	
		grandTotal = ""

		if _nTotalColIndex_ <= len(_totalRow_)
			grandTotal = _totalRow_[_nTotalColIndex_]
		ok
	
		if isNumber(grandTotal) or (isString(grandTotal) and grandTotal != "" and isNumber(0 + grandTotal))
			_cLine_ += @aBorder[:Vertical] + " " + PadLeft(grandTotal, _nTotalColWidth_ - 2) + "  "

		else
			_cLine_ += @aBorder[:Vertical] + " " + PadRight(grandTotal, _nTotalColWidth_ - 2) + "  "
		ok
	
		_cOutput_ += _cLine_
	
		? _cOutput_ + NL

	  #-----------------------------#
	 #  UTILITY FUNCTIONS          #
	#-----------------------------#

	def PadRight(text, width)
		# Pad text to the right
		_cStr_ = "" + text
		_nPad_ = width - len(_cStr_)
		if _nPad_ > 0
			return _cStr_ + RepeatChar(" ", _nPad_)
		else
			return _cStr_
		ok
	
	def PadLeft(text, width)
		# Pad text to the left
		_cStr_ = "" + text
		_nPad_ = width - len(_cStr_)
		if _nPad_ > 0
			return RepeatChar(" ", _nPad_) + _cStr_
		else
			return _cStr_
		ok
	
	def CenterText(text, width)
		# Center text within width
		_cStr_ = "" + text
		_nPadTotal_ = width - len(_cStr_)
		if _nPadTotal_ <= 0
			return _cStr_
		ok
		
		_nPadLeft_ = floor(_nPadTotal_ / 2)
		_nPadRight_ = _nPadTotal_ - _nPadLeft_
		
		return RepeatChar(" ", _nPadLeft_) + _cStr_ + RepeatChar(" ", _nPadRight_)
	
	def StrFill(nCount, cChar)
		# Create string of repeated character
		_cResult_ = ""
		for i = 1 to nCount
			_cResult_ += cChar
		next
		return _cResult_
