#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLEAGGREGATOR          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table aggregator subclass -- fill,          #
#                  calculated columns/rows, SUM/PRODUCT/       #
#                  AVERAGE/MAX/MIN, pivot, filter, group by.   #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableAggregator from stzTable

	  #===========================================================#
	 #  FILLING ALL THE TABLE WITH A GIVEN CELL, COLUMN, OR ROW  #
	#===========================================================#

	def Fill(pValue)
		/*

		EXAMPLE 1:

		_o1_ = new stzTable([3, 3])
		_o1_.Fill( :With = "A" )	# or ( :WithCell = "A" )
		_o1_.Show()
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "A"	  "A"
		# 2	  "A"	  "A"	  "A"
		# 3	  "A"	  "A"	  "A"

		EXAMPLE 2:

		_o1_ = new stzTable([3, 3])
		_o1_.Fill( :WithCol = [ "A", "B", "C" ])
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "A"	  "A"
		# 2	  "B"	  "B"	  "B"
		# 3	  "C"	  "C"	  "C"

		EXAMPLE 3:

		_o1_ = new stzTable([3, 3])
		_o1_.Fill( :WithRow = [ "A", "B", "C" ])
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "B"	  "C"
		# 2	  "A"	  "B"	  "C"
		# 3	  "A"	  "B"	  "C"

		*/

		_cFill_ = :WithCell

		if isList(pValue) and
		   IsOneOfTheseNamedParamsList(pValue,[
			:With, :WithCell, :WithCol, :WithColumn, :WithRow,
			:Using, :UsingCell, :UsingCol, :UsingColumn, :UsingRow ])

			_cFill_  = pValue[1]
			pValue = pValue[2]
		ok

		if _cFill_ = :With or _cFill_ = :WithCell

			_nLenCol_ = This.NumberOfCols()
			_nLenRow_ = This.NumberOfRows()
			_oCopy_ = This.Copy()

			for @i = 1 to _nLenCol_
				for @v = 1 to _nLenRow_
					_oCopy_.ReplaceCell(@i, @v, pValue)
				next
			next

			This.UpdateWith( _oCopy_.Content() )

		but StzFindFirst([
			:WithCol, :WithColumn, :UsingCol, :UsingColumn ], _cFill_) > 0

			This.ReplaceCols(:With = pValue)

		but _cFill_ = :WithRow or _cFill_ = :UsingRow

			This.ReplaceRows(:By = pValue)

		else
			StzRaise("Unsupported syntax! Allowed named params are: " +
				 ":WithCell, :WithColumn, and :WithRow.")
		ok

		#< @FunctionFuentForm

		def FillQ(pValue)
			This.Fill(pValue)
			return This

		def FillCQ(pValue) #TODO // Add this to all functions
			return This.Copy().FillQ(pValue)

	def Filled(pValue)
		_aResult_ = This.Copy().FillQ(pValue).Content()
		return _aResult_

	  #=================================#
	 #  MISC. : SOME USEFUL UTILITIES  #
	#=================================#

	def ToStzHashList()
		return new stzHashList( This.Table() )

	def ColToColName(p)
		if isList(p) and
		   IsOneOfTheseNamedParamsList(p,[
			:Col, :InCol, :Cols, :InCols,
			:Column, :InColumn, :Columns, :InColumns
		   ])

			p = p[2]
		ok

		if NOT Q(p).IsNumberOrString()
			StzRaise("Incorrect param type! p must be a number or string.")
		ok

		if isString(p)

			if StzFindFirst([ :First, :FirstCol, :FirstColumn ], p) > 0
				p = 1

			but StzFindFirst([ :Last, :LastCol, :LastColumn ], p) > 0
				p = This.NumberOfCols()

			but This.HasColName(p)
				p = This.FindCol(p)

			else
				StzRaise("Incorrect param value! p must be a number or string. Allowed strings are :First, :FirstCol, :Last, :LastCol and any valid column name.")
			ok
		ok

		_cResult_ = This.ColName(p)
		return _cResult_

		def ColumnToColumnName(p)
			return This.ColToColName(p)

		def ColToName(p)
			return This.ColToColName(p)

		def ColAsName(p)
			return This.ColToColName(p)

		def ColumnAsName(p)
			return This.ColToColName(p)

	def TheseColsToColNames(paCols)
		if NOT ( isList(paCols) and ( Q(paCols).IsListOfNumbers() or
				Q(paCols).IsListOfStrings() or
				Q(paCols).IsListOfNumbersAndStrings() ) )

			StzRaise("Incorrect param type! paCols must be a list of numbers or strings or numbers/strings.")
		ok

		_nLen_ = len(paCols)
		_acResult_ = []

		for i = 1 to _nLen_
			_acResult_ + This.ColToColName(paCols[i])
		next

		return _acResult_

		#< @FunctionAlternativeForms

		def TheseColsToColsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsToColumnNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsToColumnsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColsToNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsToNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColsAsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def TheseColumnsAsNames(paCols)
			return This.TheseColsToColNames(paCols)

		#--

		def ColsToColNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColsToColsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColsToColumnNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColsToColumnsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColsNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColumnNames(paCols)
			return This.TheseColsToColNames(paCols)

		def ColumnsToColumnsNames(paCols)
			return This.TheseColsToColNames(paCols)

		#>

	def ColToColNumber(p)
		if isNumber(p) and p <= This.NumberOfCol()
			return p
		ok

		if NOT Q(p).IsNumberOrString()
			StzRaise("Incorrect param type! p must be a number or string.")
		ok

		if isString(p)

			if StzFindFirst([ :First, :FirstCol, :FirstColumn ], p) > 0
				p = 1

			but StzFindFirst([ :Last, :LastCol, :LastColumn ], p) > 0
				p = This.NumberOfCols()

			but This.HasColName(p)
				p = This.ColNamesQ().FindFirst(p)

			else
				StzRaise("Incorrect param value! p must be a number or string. Allowed strings are :First, :FirstCol, :Last, :LastCol and any valid column name.")
			ok
		ok

		if NOT ( p >= 1 and p <= This.NumberOfCols() )
			StzRaise("Incorrect value! n must correspond to a valid number of column.")
		ok

		_nResult_ = p
		return _nResult_

		#< @functionAlternativeForms

		def ColumnToColumnNumber(p)
			return This.ColToColNumber(p)

		def ColToNumber(p)
			return This.ColToColNumber(p)

		def ColNumber(p)
			return This.ColToColNumber(p)

		def ColumnToNumber(p)
			return This.ColToColNumber(p)

		def ColumnNumber(p)
			return This.ColToColNumber(p)

		def ColAsNumber(p)
			return This.ColToColNumber(p)

		def ColumnAsNumber(p)
			return This.ColToColNumber(p)

		#>

	def TheseColsToColNumbers(paCols)
		if NOT ( isList(paCols) and ( Q(paCols).IsListOfNumbers() or
				Q(paCols).IsListOfStrings() or
				Q(paCols).IsListOfNumbersAndStrings() ) )

			StzRaise("Incorrect param type! paCols must be a list of numbers or strings or numbers/strings.")
		ok

		_nLen_ = len(paCols)
		_anResult_ = []

		for i = 1 to _nLen_
			_anResult_ + This.ColToColNumber(paCols[i])
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def TheseColsToColsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColumnsToColumnNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColsToNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColumnsToNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColumnsAsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def TheseColsAsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		#--

		def ColsToColNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColsToColsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColsToColumnNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColsToColumnsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColumnNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		def ColumnsToColumnsNumbers(paCols)
			return This.TheseColsToColNumbers(paCols)

		#>

	def RowToRowNumber(pRow)
		if isList(pRow) and IsOneOfTheseNamedParamsList(pRow,[ :Row, :Rows, :InRow, :InRows, :OfRow, :OfRows ])
			pRow = pRow[2]
		ok

		if isString(pRow)
			if pRow = :First or pRow = :FirstRow
				pRow = 1
			but pRow = :Last or pRow = :LastRow
				pRow = This.NumberOfRows()
			ok
		ok

		if NOT isNumber(pRow)
			StzRaise("Incorrect param type! pRow must be a number.")
		ok

		return pRow

		def RowToNumber(pRow)
			return This.RowToRowNumber(pRow)

		def RowAsNumber(pRow)
			return This.RowToRowNumber(pRow)

	def TheseRowsToRowsNumbers(paRows)
		if NOT ( isList(paRows) and Q(paRows).IsListOfLists() )
			StzRaise("Incorrect param type! paRows must be a list of lists.")
		ok

		_nLen_ = len(paRows)
		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + This.RowToNumber(paRows[i])
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def TheseRowsToNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		def TheseRowsAsNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		def RowsToRowsNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		def RowsToRowNumbers(paRows)
			return This.TheseRowsToRowsNumbers(paRows)

		#>

	  #=============================#
	 #  USED BY SQL EXTERNAL CODE  #
	#=============================#

	def @(pacColNames)
		/*
		@([

		:id    = SMALLINT,
		:name  = VARCHAR(30),
		:score = SMALLINT

		])
		*/

		if CheckingParams()
			if NOT ( isString(pacColNames) or
				 (isList(pacColNames) and Q(pacColNames).IsHasHListOrListOfStrings()) )

				StzRaise("Incorrect param type! pacColNames must be a hashlist or a string containing a column name.")
			ok
		ok

		if isString(pacColNames)
			if This.IsAColName(pacColNames)
				_n_ = This.ColToColNumber(pacColNames)
				return '( This.Cell(' + _n_ + ', j) )'
			else
				return pacColNames
			ok
		ok

		_nLen_ = len(pacColNames)
		_acColNames_ = []

		if Q(pacColNames).IsListOfStrings()
			for i = 1 to _nLen_
				_acColNames_ + [ pacColNames[i], [ "" ] ]
			next

		else // IsHashList()
			for i = 1 to _nLen_
				_acColNames_ + [ pacColNames[i][1], [ "" ] ]
			next
		ok

		This.AddCols(_acColNames_)
		This.RemoveCol(1)

		_aRow_ = []
		for i = 1 to _nLen_
			_aRow_ + ""
		next

		This.AddRow(_aRow_)

	  #==============================#
	 #  ADDING A CALCULATED COLUMN  #
	#==============================#

	def InsertCalculatedCol(_n_, pcColName, pcFormula)
		if CheckingParams()
			if NOT @BothAreStrings(pcColName, pcFormula)
				StzRaise("Incorrect param types! pcColName and pcFormula must be both strings.")
			ok

			if ring_trim(pcColName) = ""
				StzRaise("Can't proceed! You must provide a name for the calculated column.")
			ok

			if This.IsAColName(pcColName)
				StzRaise("Can't proceed! The column name you provided already exists.")
			ok

			if ring_trim(pcFormula) = ""
				StzRaise("Cant' proceed! You must provide a formula.")
			ok
		ok

		_aColData_ = []
		_nCols_ = This.NumberOfCols()
		_nRows_ = This.NumberOfRows()

		@NumberOfRows = _nRows_
		@NumberOfCols = _nCols_
		@NumberOfColumns = _nCols_

		# Engine-first calculated column, DENSE path. Lower @(:ColName) to This[j]
		# where j is the column's position among the REFERENCED columns, so we
		# pass ONLY those -- read by the engine as a dense f64 matrix with NO
		# per-cell boxing (the boxing in the nested-list path was the marshalling
		# floor). The formula compiles ONCE and evaluates natively per row. (The
		# classic path below re-ran the Ring compiler with eval() on EACH row --
		# ~11us/row, seconds of pure compile overhead at scale.)
		# Detect referenced columns and lower them in ONE pass, VIA the replace
		# itself. We can't use StzFind here: it returns 0 for a needle that
		# contains @(:...) (the engine find mishandles those chars), and
		# case-insensitive find is broken for multi-char needles -- so a
		# find-based check silently misses every reference, leaves the formula
		# unlowered, and drops to the slow eval-per-row fallback. Instead, try
		# ReplaceCS (case-insensitive: names are stored lower-cased, formulas may
		# write @(:A)); if the content changed, the column was referenced, and it
		# gets the NEXT This[j] position (j = its rank among referenced columns).
		_oEngFormula_ = new stzString(pcFormula)
		_aRefCols_ = []
		for i = 1 to _nCols_
			_cTok_ = '@(:' + This.ColName(i) + ')'
			_cBefore_ = _oEngFormula_.Content()
			_nNext_ = len(_aRefCols_) + 1
			_oEngFormula_.ReplaceCS(_cTok_, 'This[' + _nNext_ + ']', 0)
			if _oEngFormula_.Content() != _cBefore_
				_aRefCols_ + i
			ok
		next
		_nRefLen_ = len(_aRefCols_)

		# One pass: gather the referenced columns' data (the dense input) and
		# confirm each is numeric. The engine evaluates arithmetically, so a
		# formula over a string column (e.g. a concatenation) must take the Ring
		# fallback below to preserve its semantics.
		_aRefData_ = []
		_bNumericRefs_ = TRUE
		for j = 1 to _nRefLen_
			_aColVals_ = This.Col(_aRefCols_[j])
			_nCVLen_ = len(_aColVals_)
			for c = 1 to _nCVLen_
				if NOT isNumber(_aColVals_[c])
					_bNumericRefs_ = FALSE
					exit
				ok
			next
			_aRefData_ + _aColVals_
			if NOT _bNumericRefs_
				exit
			ok
		next

		if _bNumericRefs_ and _nRefLen_ > 0
			_aColData_ = StzEngineListEvalColumnsDense(_aRefData_, _nRows_, _oEngFormula_.Content())
		ok

		# Fallback: a non-numeric reference, or a formula the engine DSL cannot
		# compile (which returns an empty column), is evaluated the classic way
		# so no existing formula regresses.
		if len(_aColData_) != _nRows_
			_aColData_ = []
			_oForumla_ = new stzString(pcFormula)
			for i = 1 to _nCols_
				_oForumla_.ReplaceCS( ('@(:'+ This.ColName(i)+')'), 'This.Cell(' + i + ', i)', 0)
			next
			_cCode_ = "_value_ = " + _oForumla_.Content()
			for i = 1 to _nRows_
				eval(_cCode_)
				_aColData_ + _value_
			next
		ok

		_aContent_ = @aContent
		_aContent_ = ring_insert(_aContent_, _n_, [ pcColName, _aColData_ ])
		This.UpdateWith(_aContent_)
		@anCalculatedCols + _n_

		#< @FunctionAlternativeForms

		def InsertCalculatedColAt(_n_, pcColName, pcFormula)
			This.InsertCalculatedCol(_n_, pcColName, pcFormula)

		def InsertCalculatedColumn(_n_, pcColName, pcFormula)
			This.InsertCalculatedCol(_n_, pcColName, pcFormula)

		def InsertCalculatedColumnAt(_n_, pcColName, pcFormula)
			This.InsertCalculatedCol(_n_, pcColName, pcFormula)

		#>

	def AddCalculatedCol(pcColName, pcFormula)
		This.InsertCalculatedCol(This.NumberOfCols()+1, pcColName, pcFormula)

		#< @FunctionAlternativeForm

		def AddCalculatedColumn(pcColName, pcFormula)
			This.AddCalculatedCol(pcColName, pcFormula)

		#>

	  #-----------------------------------------------#
	 #  GETTING THE POSITIONS OF CALCULATED COLUMNS  #
	#-----------------------------------------------#

	def FindCalculatedCols()
		_anResult_ = new stzList(@anCalculatedCols).Sorted()
		return _anResult_

		def FindCalculatedColumns()
			return This.FindcalculatedCols()

	  #--------------------------------------------------#
	 #  GETTING THE CONTENT OF THE CALCULATED COLUMNS  #
	#-------------------------------------------------#

	def CalculatedCols()
		_anPos_ = This.FindCalculatedCols()
		_aResult_ = This.TheseCols(_anPos_)
		return _aResult_

		def CalculatedColumns()
			return This.CalculatedCols()

	  #-----------------------------------------------#
	 #  GETTING THE NAMES OF THE CALCULATED COLUMNS  #
	#-----------------------------------------------#

	def CalculatedColNames()
		_anPos_ = This.FindCalculatedCols()
		_acResult_ = This.TheseColNames(_anPos_)
		return _acResult_

		def CalculatedColsNams()
			return This.CalculatedColNames()

		def CalculatedColumnNams()
			return This.CalculatedColNames()

		def CalculatedColumnsNams()
			return This.CalculatedColNames()

	  #===========================#
	 #  ADDING A CALCULATED ROW  #
	#===========================#

	def InsertCalculatedRow(_n_, pacFormulas)
		if CheckingParams()
			if NOT ( isList(pacFormulas) and @IsListOfStrings(pacFormulas) )
				StzRaise("Incorrect param type! pacFormulas must be a list of strings.")
			ok
		ok

		_aRowData_ = []
		_nLen_ = len(pacFormulas)
		_nCols_ = This.NumberOfCols()
		_nRows_ = This.NumberOfRows()
		_nMin_ = @Min([ _nRows_, _nLen_ ])

		# Preparing the list of formulas

		_aoForumlas_ = StzListQ(pacFormulas).ToListOfStzStrings()
		_acCodes_ = []
		for i = 1 to _nMin_
			_cColName_ = This.ColName(i)
			_aoForumlas_[i].ReplaceCS( ('@(:'+ _cColName_ +')'), 'This.Col(:' + _cColName_ + ')', 0)
			_cCode_ =  _aoForumlas_[i].Content()
			if _cCode_ != ""
				_cCode_ = '_value_ = ' + _cCode_
			ok
			_acCodes_ + _cCode_
		next

		@NumberOfRows = _nRows_
		@NumberOfCols = _nCols_
		@NumberOfColumns = _nCols_

		for i = 1 to _nMin_
			if _acCodes_[i] != ""
				eval(_acCodes_[i])
				_aRowData_ + _value_
			else
				_aRowData_ + " "
			ok
		next

		if _nMin_ < _nCols_
			for i = _nMin_+1 to _nCols_
				_aRowData_ + ""
			next
		ok

		This.InsertRow(_n_, _aRowData_)
		@anCalculatedRows + _n_

	def AddCalculatedRow(pacFormulas)
		This.InsertCalculatedRow( This.NumberOfRows() + 1, pacFormulas)

	  #--------------------------------------------#
	 #  GETTING THE POSITIONS OF CALCULATED ROWS  #
	#--------------------------------------------#

	def FindCalculatedRows()
		_anResult_ = new stzList( @anCalculatedRows ).Sorted()
		return _anResult_

	  #------------------------------------------#
	 #  GETTING THE CONTENT OF CALCULATED ROWS  #
	#------------------------------------------#

	def CalculatedRows()
		_aResult_ = This.TheseRows(This.FindCalculatedRows())
		return _aResult_

	  #======================================================#
	 #  EXCEL-LIKE FUNCTIONS APPLIED TO A SECTION OF CELLS  #
	#=====================================================#

	def SUM(paCell1, paCell2)
		_aCells_ = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(_aCells_)
			return 0
		ok

		_nLen_ = len(_aCells_)

		_nResult_ = 0

		for i = 1 to _nLen_
			_nResult_ += _aCells_[i]
		next

		return _nResult_

	def PRODUCT(paCell1, paCell2)
		_aCells_ = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(_aCells_)
			return 0
		ok

		_nLen_ = len(_aCells_)

		_nResult_ = 1

		for i = 1 to _nLen_
			_nResult_ *= _aCells_[i]
		next

		return _nResult_

	def AVERAGE(paCell1, paCell2)
		_aCells_ = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(_aCells_)
			return 0
		ok

		_nLen_ = len(_aCells_)

		_nSum_ = 0

		for i = 1 to _nLen_
			_nSum_ += _aCells_[i]
		next

		_nResult_ = _nSum_ / _nLen_
		return _nResult_

		def MEAN(paCell1, paCell2)
			return AVERAGE(paCell1, paCell2)

	def KOUNT(paCell1, paCell2)
		_nResult_ = len( This.CellsInSection(paCell1, paCell2) )
		return _nResult_

	def MAX(paCell1, paCell2)
		_aCells_ = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(_aCells_)
			return 0
		ok

		_nResult_ = @Max(_aCells_)

		return _nResult_

	def MIN(paCell1, paCell2)
		_aCells_ = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(_aCells_)
			return 0
		ok

		_nResult_ = @Min(_aCells_)

		return _nResult_

	  #==========================================================#
	 #  ENGINE-BACKED COLUMN AGGREGATION (whole-column, fast)    #
	#==========================================================#

	def SumCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableSumCol(@pEngine, _nCol_-1)

		def SumColumn(pCol)
			return This.SumCol(pCol)

	def AvgCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableAvgCol(@pEngine, _nCol_-1)

		def AvgColumn(pCol)
			return This.AvgCol(pCol)

		def AverageCol(pCol)
			return This.AvgCol(pCol)

		def AverageColumn(pCol)
			return This.AvgCol(pCol)

		def MeanCol(pCol)
			return This.AvgCol(pCol)

		def MeanColumn(pCol)
			return This.AvgCol(pCol)

	def MinCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableMinCol(@pEngine, _nCol_-1)

		def MinColumn(pCol)
			return This.MinCol(pCol)

	def MaxCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableMaxCol(@pEngine, _nCol_-1)

		def MaxColumn(pCol)
			return This.MaxCol(pCol)

	def ProductCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableProductCol(@pEngine, _nCol_-1)

		def ProductColumn(pCol)
			return This.ProductCol(pCol)

	def CountNonNullInCol(pCol)
		_nCol_ = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableCountNonNull(@pEngine, _nCol_-1)

		def CountNonNullInColumn(pCol)
			return This.CountNonNullInCol(pCol)

	  #============================================#
	 #  CASTING THE TABLE INTO A STZTABLE OBJECT  #
	#============================================#

	#NOTE // stzPivotTable belongs to the MAX layer of StzLib
	# For the fellowing method to work, you must load "stzmax.ring"

	def ToStzPivotTable()
		return new stzPivotTable(This)

	  #=======================#
	 #  FILTERING THE TABLE  #
	#=======================#

	# Filters table rows based on specified column/value pairs

    def Filter(paColValues)

        # Validate input is a hash list

        if NOT (isList(paColValues) and Q(paColValues).IsHashList())
            StzRaise("Filter requires a hash list of filtering [ColName, ColValue] pairs.")
        ok

        # Validate column existence and prepare filtering

		_nLen_ = len(paColValues)

		for i = 1 to _nLen_
            _cColName_ = paColValues[i][1]

            # Check if column exists (case-insensitive)

            _nColIndex_ = This.FindCol(_cColName_)
            if _nColIndex_ = 0
                StzRaise("Column '" + _cColName_ + "' not found in the table")
            ok
        next

        # Perform filtering

        _nRows_ = This.NumberOfRows()
        _aRowsToKeep_ = []

        for nRow = 1 to _nRows_
            _bKeepRow_ = 1
			_nLenValues_ = len(paColValues)

			for v = 1 to _nLenValues_
                _cColName_ = paColValues[v][1]
                _aFilterValues_ = paColValues[v][2]

                # Get column index
                _nColIndex_ = This.FindCol(_cColName_)

                # Get cell value
                _cellValue_ = This.Cell(_nColIndex_, nRow)

                # Check if cell value matches filter conditions
                # Support both single value and list of values

                if isList(_aFilterValues_)

                    _bValueMatches_ = 0
					_nLenFilterValues_ = len(_aFilterValues_)

					for j = 1 to _nLenFilterValues_

                        if _cellValue_ = _aFilterValues_[j]
                            _bValueMatches_ = 1
                            exit
                        ok

					next

                else
                    _bValueMatches_ = (_cellValue_ = _aFilterValues_)
                ok

                # If any condition fails, exclude the row
                if NOT _bValueMatches_
                    _bKeepRow_ = 0
                    exit
                ok
            next

            if _bKeepRow_
                _aRowsToKeep_ + This.Row(nRow)
            ok
        next

        # Rebuild the table with filtered rows

        _aResult_ = []

        # Recreate columns with filtered data

        _nCols_ = This.NumberOfCols()

        for _nCol_ = 1 to _nCols_
            _cColName_ = This.ColName(_nCol_)
            _colData_ = []

			_nLenRowsToKeep_ = len(_aRowsToKeep_)
            for nRow = 1 to _nLenRowsToKeep_
                _colData_ + _aRowsToKeep_[nRow][_nCol_]
            next

            _aResult_ + [_cColName_, _colData_]
        next

        @aContent = _aResult_

    #< @FunctionFluentForm

    def FilterQ(paColValues)
        This.Filter(paColValues)
        return This

	def FilterCQ(paColValues)
			_oCopy_ = This.Copy()
			_oCopy_.Filter(paColValues)
			return _oCopy_
	#>

	#< @FunctionAlternativeForm

	def FilterBy(paColValues)
		This.Filter(paColValues)

		def FilterByQ(paColValues)
			return This.FilterQ(paColValues)

		def FilterByCQ(paColValues)
			return This.FilterCQ(paColValues)

	#>

	  #--------------------------------------------#
	 #  FILTERING THE TABLE BY A GIVEN CONDITION  #
	#--------------------------------------------#

	def FilterW(pcCondition)

		# Validate input is a string

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		if ring_trim(pcCondition) = ""
			StzRaise("Can't proceed! You must provide a condition.")
		ok


		# Early check for complex condition

		_oCondition_ = new stzString(pcCondition)
		if _oCondition_.NumberOfOccurrence('@(') > 1
			This.FilterWXT(pcCondition)
			return
		ok

		# Prepare the condition expression

		_nCols_ = This.NumberOfCols()

		for i = 1 to _nCols_
			_cColName_ = This.ColName(i)
			_oCondition_.ReplaceCS('@(:' + _cColName_ + ')', 'This.Cell(' + i + ', nRow)', 0)
		next

		_cCondition_ = _oCondition_.Content()

		# Prepare evaluation code
		_cCode_ = "_bResult_ = " + _cCondition_

		# Perform filtering
		_nRows_ = This.NumberOfRows()
		_aRowsToKeep_ = []

		for nRow = 1 to _nRows_
			# Evaluate the condition for the current row
			eval(_cCode_)
			if _bResult_
				_aRowsToKeep_ + This.Row(nRow)
			ok
		next
		_nLenRowsToKeep_ = len(_aRowsToKeep_)

		# Rebuild the table with filtered rows
		_aResult_ = []
		_nCols_ = This.NumberOfCols()

		for _nCol_ = 1 to _nCols_

			_cColName_ = This.ColName(_nCol_)
			_colData_ = []


			for nRow = 1 to _nLenRowsToKeep_
				_colData_ + _aRowsToKeep_[nRow][_nCol_]
			next

			_aResult_ + [_cColName_, _colData_]

		next

		@aContent = _aResult_

		#< @FunctionFluentForm

		def FilterWQ(pcCondition)
			This.FilterW(pcCondition)
			return This

		def FilterWCQ(pcCondition)
			_oCopy_ = This.Copy()
			_oCopy_.FilterW(pcCondition)
			return _oCopy_

		#>

		#< @FunctionAlternativeForm

		def FilterByW(pcCondition)
			This.FilterW(pcCondition)

		def FilterByWQ(pcCondition)
			return This.FilterWQ(pcCondition)

		def FilterByWCQ(pcCondition)
			return This.FilterWCQ(pcCondition)

		#>

	  #----------------------------------------------#
	 #  FILTERING THE TABLE BY A COMPLEX CONDITION  #
	#----------------------------------------------#

	def FilterWXT(pcCondition)

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		if ring_trim(pcCondition) = ""
			StzRaise("Can't proceed! You must provide a condition.")
		ok

		# Validate that all referenced column names exist

		_oConditionTemp_ = new stzString(pcCondition)
		_acColNames_ = This.ColNames()
		_nLenCols_ = len(_acColNames_)

		for i = 1 to _nLenCols_

			if _oConditionTemp_.ContainsCS('@(:' + _acColNames_[i] + ')', 0)
				if NOT This.IsColName(_acColNames_[i])
					StzRaise("Invalid column name! The column '@(:" + _acColNames_[i] + ")' does not exist in the table.")
				ok
			ok

		next

		# Prepare the condition expression

		_oCondition_ = new stzString(pcCondition)
		_nCols_ = This.NumberOfCols()

		for i = 1 to _nCols_
			_cColName_ = This.ColName(i)
			_oCondition_.ReplaceCS('@(:' + _cColName_ + ')', 'This.Cell(' + i + ', nRow)', 0)
		next

		_cCondition_ = _oCondition_.Content()

		# Verify that no '@(:...)' patterns remain

		if Q(_cCondition_).Contains('@(:')
			StzRaise("Invalid condition! Unresolved column reference found in: " + _cCondition_)
		ok

		# Prepare evaluation code

		_cCode_ = "_bOk_ = " + _cCondition_

		# Perform filtering

		_nRows_ = This.NumberOfRows()
		_aRowsToKeep_ = []

		for nRow = 1 to _nRows_
			try
				eval(_cCode_)
				if _bOk_
					_aRowsToKeep_ + This.Row(nRow)
				ok
			catch
				StzRaise("Error evaluating condition: " + _cCondition_ + " at row " + nRow)
			done
		next

		# Rebuild the table with filtered rows

		_aResult_ = []
		_nCols_ = This.NumberOfCols()

		for _nCol_ = 1 to _nCols_

			_cColName_ = This.ColName(_nCol_)
			_colData_ = []
			_nLenRowsToKeep_ = len(_aRowsToKeep_)

			for nRow = 1 to _nLenRowsToKeep_
				_colData_ + _aRowsToKeep_[nRow][_nCol_]
			next

			_aResult_ + [_cColName_, _colData_]

		next

		@aContent = _aResult_

		#< @FunctionFluentForm

		def FilterWXTQ(pcCondition)
			This.FilterWXT(pcCondition)
			return This

		def FilterWXTCQ(pcCondition)
			_oCopy_ = This.Copy()
			_oCopy_.FilterWXT(pcCondition)
			return _oCopy_

		#>

		#< @FunctionAlternativeForm

		def FilterByWXT(pcCondition)
			This.FilterWXT(pcCondition)

			def FilterByWXTQ(pcCondition)
				return This.FilterWXTQ(pcCondition)

			def FilterByWXTCQ(pcCondition)
				return This.FilterWXTCQ(pcCondition)

		#>

	  #============================================================================#
	 #  Aggregating (Grouping) table data based on specified columns and methods  #
	#============================================================================#

	def Aggregate(paAggregations)
		# Validate input is a hash list
		if NOT (isList(paAggregations) and Q(paAggregations).IsHashList())
			StzRaise("Aggregate requires a hash list of aggregation specifications")
		ok

		# Predefined aggregation methods
		_aValidMethods_ = [
			:Sum,
			:Average,
			:Count,
			:Max,
			:Min,
			:First,
			:Last
		]

		# Validate and process aggregations
		_aProcessedAggs_ = []
		_nLen_ = len(paAggregations)

		for i = 1 to _nLen_
			_cColName_ = paAggregations[i][1]
			_cAggMethod_ = StzLower(paAggregations[i][2])

			# Validate column existence
			_nColIndex_ = This.FindCol(_cColName_)
			if _nColIndex_ = 0
				StzRaise("Column '" + _cColName_ + "' not found in the table")
			ok

			# Validate aggregation method
			if StzFindFirst(_aValidMethods_, _cAggMethod_) = 0
				StzRaise("Invalid aggregation method: " + _cAggMethod_)
			ok

			_aProcessedAggs_ + [_cColName_, _cAggMethod_]
		next

		# Perform aggregation
		_aResult_ = []

		# Add columns for aggregation results
		_nLen_ = len(_aProcessedAggs_)

		for i = 1 to _nLen_
			_cColName_ = _aProcessedAggs_[i][1]
			_cAggMethod_ = _aProcessedAggs_[i][2]

			# Create aggregated column name
			_cAggColName_ = _cAggMethod_ + "(" + _cColName_ + ")"

			# Perform aggregation
			_nColIndex_ = This.FindCol(_cColName_)
			_aColData_ = This.Col(_nColIndex_)
			_nLenData_ = len(_aColData_)

			_nResult_ = 0

			switch _cAggMethod_

			on :Sum

				for v = 1 to _nLenData_
					_nResult_ += _aColData_[v]
				next

			on :Average

				_nSum_ = 0

				for v = 1 to _nLenData_
					_nSum_ += _aColData_[v]
				next

				_nResult_ = _nSum_ / _nLenData_

			on :Count
				_nResult_ = _nLenData_

			on :Max

				_nResult_ = _aColData_[1]

				for v = 2 to _nLenData_
					if _aColData_[v] > _nResult_
						_nResult_ = _aColData_[v]
					ok
				next

			on :Min

				_nResult_ = _aColData_[1]

				for v = 2 to _nLenData_
					if _aColData_[v] < _nResult_
						_nResult_ = _aColData_[v]
					ok
				next

			on :First
				_nResult_ = _aColData_[1]

			on :Last
				_nResult_ = _aColData_[_nLenData_]
			off

			# Add aggregated column
			_aResult_ + [ _cAggColName_, [_nResult_] ]

		next

		@aContent = _aResult_

		#< @FunctionFluentForm

		def AggregateQ(paAggregations)
			This.Aggregate(paAggregations)
			return This
		#>

		#< @FunctionAlternativeForm

		def AggregateBy(paAggregations)
			This.Aggregate(paAggregations)

			def AggregateByQ(paAggregations)
				return This.AggregateQ(paAggregation)

		#>

	  #===============================================#
	 #  GROUPING DATA (ROWS) BY A GIVEN VALUE (COL)  #
	#===============================================#

	def GroupBy(paCols)

		if NOT isList(paCols)
			if isString(paCols) This.IsCol(paCols) and @IsListOfLists(This.Col(paCols))
				This.GroupByListItems(paCols)
				return
			ok

			_aTemp_ = [] + paCols
			paCols = _aTemp_
		ok

		# Validate input is a list of column names
		if NOT (isList(paCols) and len(paCols) > 0)
			StzRaise("GroupBy requires a non-empty list of column names")
		ok

		# Validate column existence
		_nLen_ = len(paCols)
		for i = 1 to _nLen_
			if This.FindCol(paCols[i]) = 0
				StzRaise("Column '" + paCols[i] + "' not found in the table")
			ok
		next

		# Prepare to group rows
		_nRows_ = This.NumberOfRows()
		_aGroupedRows_ = []
		_aGroupKeys_ = []
		_aUniqueGroups_ = []

		# Iterate through rows to create groups
		_nLenCols_ = len(paCols)
		for nRow = 1 to _nRows_
			# Create group key from specified columns
			_aGroupKey_ = []
			for i = 1 to _nLenCols_
				_nColIndex_ = This.FindCol(paCols[i])
				_aGroupKey_ + This.Cell(_nColIndex_, nRow)
			next

			# Convert group key to string for easy comparison
			_cGroupKey_ = ""
			_nGroupKeyLen_ = len(_aGroupKey_)
			for i = 1 to _nGroupKeyLen_
				_cGroupKey_ += ""+ _aGroupKey_[i] + '|'
			next

			# Check if this group key exists
			_nGroupIndex_ = StzFindFirst(_aGroupKeys_, _cGroupKey_)
			if _nGroupIndex_ = 0
				# New group, add to groups
				_aGroupKeys_ + _cGroupKey_
				_aUniqueGroups_ + _aGroupKey_
				_aGroupedRows_ + [ This.Row(nRow) ]
			else
				# Existing group, append row
				_aGroupedRows_[_nGroupIndex_] + This.Row(nRow)
			ok
		next

		# Build result table structure
		_aResult_ = []
		_acColNames_ = This.ColNames()

		# Add all columns to result
		_nColNamesLen_3 = len(_acColNames_)
		for i = 1 to _nColNamesLen_3
			_aResult_ + [ _acColNames_[i], [] ]
		next

		# Add rows from each group to result
		_nLenGroups_ = len(_aUniqueGroups_)
		for i = 1 to _nLenGroups_
			_aRows_ = _aGroupedRows_[i]
			_nRowsLen_ = len(_aRows_)
			for j = 1 to _nRowsLen_
				_aRow_ = _aRows_[j]
				# Add each value to its column
				_nRowLen_ = len(_aRow_)
				for k = 1 to _nRowLen_
					_aResult_[k][2] + _aRow_[k]
				next
			next
		next

		@aContent = _aResult_


		#< @FunctionFluentForm

		def GroupByQ(paCols)
			This.GroupBy(paCols)
			return This

		def GroupByCQ(paCols)
				_oCopy_ = This.Copy()
				_oCopy_.GroupBy(paCols)
				return _oCopy_
		#>

	  #-------------------------------------------#
	 #  GROUPING BY AND AGRREGATING -- EXTENDED  #
	#-------------------------------------------#

	def GroupByXT(paCols, paAggregations)

		# Validate input is a list of column names

		if NOT (isList(paCols) and len(paCols) > 0)
			StzRaise("GroupBy requires a non-empty list of column names")
		ok

		# Validate column existence

		_nLen_ = len(paCols)

		for i = 1 to _nLen_
			if This.FindCol(paCols[i]) = 0
				StzRaise("Column '" + paCols[i] + "' not found in the table")
			ok
		next

		# Validate aggregation input

		if NOT (isList(paAggregations) and @IsListOfPairsOfStrings(paAggregations))
				StzRaise("Aggregations must be a hash list of [column, method] pairs")
		ok

		# Default aggregation if none provided: First value for non-grouped columns

		_nLenAgg_ = len(paAggregations)

		if _nLenAgg_ = 0

			_acColNames_ = This.ColNames()

			for i = 1 to _nLenAgg_

				if NOT StzFindFirst(paCols, _acColNames_[i]) > 0
					paAggregations + [_cColName_, :First]
				ok

			next
		else

		# Lowercase all the aggregation functions

		for i = 1 to _nLenAgg_
			paAggregations[i][2] = StzLower(paAggregations[i][2])
		next

		# Valid aggregation methods

		_aValidMethods_ = [ :Sum, :Average, :Count, :Max, :Min, :First, :Last ]

		for i = 1 to _nLenAgg_

			_cColName_ = paAggregations[i][1]
			_cAggMethod_ = paAggregations[i][2]

			# Validate column exists

			if This.FindCol(_cColName_) = 0
				StzRaise("Column '" + _cColName_ + "' not found in the table")
			ok

			# Validate method is supported

			if NOT StzFindFirst(_aValidMethods_, _cAggMethod_)
				StzRaise("Invalid aggregation method: " + _cAggMethod_)
			ok

			# Validate column is not in grouping columns

			if StzFindFirst(paCols, _cColName_) > 0
				StzRaise("Cannot aggregate grouping column: " + _cColName_)
			ok

		next
	ok

	# Prepare to group rows

	_nRows_ = This.NumberOfRows()
	_aGroupedRows_ = []
	_aGroupKeys_ = []
	_aUniqueGroups_ = []

	# Iterate through rows to create groups

	_nLenCols_ = len(paCols)

	for nRow = 1 to _nRows_

		# Create group key from specified columns

		_aGroupKey_ = []

		for i = 1 to _nLenCols_
			_nColIndex_ = This.FindCol(paCols[i])
			_aGroupKey_ + This.Cell(_nColIndex_, nRow)
		next
		_nLenKeys_ = len(_aGroupKey_)

		# Convert group key to string for easy comparison

		_cGroupKey_ = ""

		for i = 1 to _nLenKeys_
			_cGroupKey_ += ""+ _aGroupKey_[i] + '|'
		next

		# Check if this group key exists

		_nGroupIndex_ = StzFindFirst(_aGroupKeys_, _cGroupKey_)

		if _nGroupIndex_ = 0

			# New group, add to groups

			_aGroupKeys_ + _cGroupKey_
			_aUniqueGroups_ + _aGroupKey_
			_aGroupRows_ = [ This.Row(nRow) ]
			_aGroupedRows_ + _aGroupRows_

		else
			# Existing group, append row
			_aGroupedRows_[_nGroupIndex_] + This.Row(nRow)
		ok
	next

	# Build result table structure

	_aResult_ = []

	# Add grouping columns first

	for i = 1 to _nLenCols_
		_aResult_ + [ paCols[i], [] ]
	next

	# Process aggregations and add aggregated columns

	for i = 1 to _nLenAgg_
		_cColName_ = paAggregations[i][1]
		_cAggMethod_ = paAggregations[i][2]
		_cAggColName_ = _cAggMethod_ + "(" + _cColName_ + ")"
		_aResult_ + [ _cAggColName_, [] ]
	next

	# Perform aggregations for each group

	_nLenGroups_ = len(_aUniqueGroups_)

	for i = 1 to _nLenGroups_

		_aGroupKey_ = _aUniqueGroups_[i]
		_aRows_ = _aGroupedRows_[i]
		_nLenRows_ = len(_aRows_)

		# Add group key values to result

		for j = 1 to _nLenCols_
			_aResult_[j][2] + _aGroupKey_[j]
		next

		# Calculate aggregations for this group

		_nColOffset_ = _nLenCols_ + 1

		for j = 1 to _nLenAgg_

			_cColName_ = paAggregations[j][1]
			_cAggMethod_ = paAggregations[j][2]
			_nColIndex_ = This.FindCol(_cColName_)

			# Extract values for this column from group rows

			_aValues_ = []

			for r = 1 to _nLenRows_
				_aValues_ + _aRows_[r][_nColIndex_]
			next

			# Apply aggregation method

			_nResult_ = NULL
			_nLenVal_ = len(_aValues_)

			switch _cAggMethod_

				on :Sum

					_nResult_ = 0

					for v = 1 to _nLenVal_
						_nResult_ += _aValues_[v]
					next

				on :Average

						_nSum_ = 0

						for v = 1 to _nLenVal_
							_nSum_ += _aValues_[v]
						next

						_nResult_ = _nSum_ / _nLenVal_

				on :Count
					_nResult_ = _nLenVal_

				on :Max
					_nResult_ = _aValues_[1]

					for v = 2 to _nLenVal_
						if _aValues_[v] > _nResult_
							_nResult_ = _aValues_[v]
						ok
					next

				on :Min
					_nResult_ = _aValues_[1]

					for v = 2 to _nLenVal_
						if _aValues_[v] < _nResult_
							_nResult_ = _aValues_[v]
						ok
					next

				on :First
					_nResult_ = _aValues_[1]

				on :Last
					_nResult_ = _aValues_[_nLenVal_]
				off

				# Add result to output

				_aResult_[_nColOffset_][2] + _nResult_
				_nColOffset_++

			next

		next

		@aContent = _aResult_


		#< @FunctionFluentForm

		def GroupByXTQ(paCols, paAggregations)
			This.GroupByXT(paCols, paAggregations)
			return This

		#>

		#< @FunctionAlternativeForm

		def GroupByAndAggregate(paCols, paAggregations)
			This.GroupByXT(paCols, paAggregations)

			def GroupByAndAggregateQ(paCols, paAggregations)
				return This.GroupByXTQ(paCols, paAggregations)

		#>

	  #---------------------------------------------#
	 #  GROUPING DATA BY A COLUMN CONTAINING LIST  #
	#---------------------------------------------#

	def GroupByListItems(paCols) #TODO // check why there is a dependance with "HOBBY"!
		if NOT isList(paCols)
			_aTemp_ = [] + paCols
			paCols = _aTemp_
		ok
	    # Validate input is a list of column names
	    if NOT (isList(paCols) and len(paCols) > 0)
	        StzRaise("GroupByListItems requires a non-empty list of column names")
	    ok

	    # Validate column existence
	    _nLen_ = len(paCols)
	    for i = 1 to _nLen_
	        if This.FindCol(paCols[i]) = 0
	            StzRaise("Column '" + paCols[i] + "' not found in the table")
	        ok
	    next

	    # Get the lists column we're grouping by
	    _cListColumn_ = paCols[1]  # Use the first column as the list column
	    _nListColIndex_ = This.FindCol(_cListColumn_)

	    # Prepare to collect unique hobby values and associated rows
	    _nRows_ = This.NumberOfRows()
	    _aHobbyMap_ = []  # Will be a list of [hobby, [row1, row2, ...]] pairs

	    # Process each row and collect unique hobby values
	    for nRow = 1 to _nRows_
	        _vCellValue_ = This.Cell(_nListColIndex_, nRow)

	        # Skip if not a list
	        if NOT isList(_vCellValue_)
	            loop
	        ok

	        # Process each hobby in the list
	        _nVCellValueLen_ = len(_vCellValue_)
	        for j = 1 to _nVCellValueLen_
	            _cHobby_ = _vCellValue_[j]

	            # Find this hobby in our map
	            _nHobbyIndex_ = 0
	            _nHobbyMapLen_2 = len(_aHobbyMap_)
	            for k = 1 to _nHobbyMapLen_2
	                if _aHobbyMap_[k][1] = _cHobby_
	                    _nHobbyIndex_ = k
	                    exit
	                ok
	            next

	            if _nHobbyIndex_ = 0
	                # New hobby, add it with this row
	                _aHobbyMap_ + [_cHobby_, [nRow]]
	            else
	                # Existing hobby, check if row already exists
	                _bFound_ = FALSE
	                _nHobbyMapnHobbyIndex2Len_ = len(_aHobbyMap_[_nHobbyIndex_][2])
	                for r = 1 to _nHobbyMapnHobbyIndex2Len_
	                    if _aHobbyMap_[_nHobbyIndex_][2][r] = nRow
	                        _bFound_ = TRUE
	                        exit
	                    ok
	                next

	                # Add row if not found
	                if NOT _bFound_
	                    _aHobbyMap_[_nHobbyIndex_][2] + nRow
	                ok
	            ok
	        next
	    next

	    # Build the new table structure with hobbies as the first column
	    _aNewColumns_ = [_cListColumn_]
	    _acColNames_ = This.ColNames()

	    # Add all other columns except the list column
	    _nColNamesLen_2 = len(_acColNames_)
	    for i = 1 to _nColNamesLen_2
	        if _acColNames_[i] != _cListColumn_
	            _aNewColumns_ + _acColNames_[i]
	        ok
	    next

	    # Create the result table structure
	    _aResult_ = []
	    _nNewColumnsLen_ = len(_aNewColumns_)
	    for i = 1 to _nNewColumnsLen_
	        _aResult_ + [_aNewColumns_[i], []]
	    next

	    # Fill in the data for each hobby group
	    _nHobbyMapLen_ = len(_aHobbyMap_)
	    for i = 1 to _nHobbyMapLen_
	        _cHobby_ = _aHobbyMap_[i][1]
	        _aRowIndices_ = _aHobbyMap_[i][2]

	        # For each row that has this hobby
	        _nRowIndicesLen_ = len(_aRowIndices_)
	        for j = 1 to _nRowIndicesLen_
	            _nRowIndex_ = _aRowIndices_[j]

	            # Add the hobby as the first column value
	            _aResult_[1][2] + _cHobby_

	            # Add all other columns from the original row
	            _nColOffset_ = 2  # Start from second column
	            _nColNamesLen_ = len(_acColNames_)
	            for k = 1 to _nColNamesLen_
	                if _acColNames_[k] != _cListColumn_
	                    _nColIndex_ = This.FindCol(_acColNames_[k])
	                    _aResult_[_nColOffset_][2] + This.Cell(_nColIndex_, _nRowIndex_)
	                    _nColOffset_++
	                ok
	            next
	        next
	    next

	    @aContent = _aResult_
