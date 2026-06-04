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

		o1 = new stzTable([3, 3])
		o1.Fill( :With = "A" )	# or ( :WithCell = "A" )
		o1.Show()
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "A"	  "A"
		# 2	  "A"	  "A"	  "A"
		# 3	  "A"	  "A"	  "A"

		EXAMPLE 2:

		o1 = new stzTable([3, 3])
		o1.Fill( :WithCol = [ "A", "B", "C" ])
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "A"	  "A"
		# 2	  "B"	  "B"	  "B"
		# 3	  "C"	  "C"	  "C"

		EXAMPLE 3:

		o1 = new stzTable([3, 3])
		o1.Fill( :WithRow = [ "A", "B", "C" ])
		#-->
		# #	:COL1	:COL2	:COL3
		# 1	  "A"	  "B"	  "C"
		# 2	  "A"	  "B"	  "C"
		# 3	  "A"	  "B"	  "C"

		*/

		cFill = :WithCell

		if isList(pValue) and
		   IsOneOfTheseNamedParamsList(pValue,[
			:With, :WithCell, :WithCol, :WithColumn, :WithRow,
			:Using, :UsingCell, :UsingCol, :UsingColumn, :UsingRow ])

			cFill  = pValue[1]
			pValue = pValue[2]
		ok

		if cFill = :With or cFill = :WithCell

			_nLenCol_ = This.NumberOfCols()
			_nLenRow_ = This.NumberOfRows()
			_oCopy_ = This.Copy()

			for @i = 1 to _nLenCol_
				for @v = 1 to _nLenRow_
					_oCopy_.ReplaceCell(@i, @v, pValue)
				next
			next

			This.UpdateWith( _oCopy_.Content() )

		but StzFind([
			:WithCol, :WithColumn, :UsingCol, :UsingColumn ], cFill) > 0

			This.ReplaceCols(:With = pValue)

		but cFill = :WithRow or cFill = :UsingRow

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
		aResult = This.Copy().FillQ(pValue).Content()
		return aResult

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

			if StzFind([ :First, :FirstCol, :FirstColumn ], p) > 0
				p = 1

			but StzFind([ :Last, :LastCol, :LastColumn ], p) > 0
				p = This.NumberOfCols()

			but This.HasColName(p)
				p = This.FindCol(p)

			else
				StzRaise("Incorrect param value! p must be a number or string. Allowed strings are :First, :FirstCol, :Last, :LastCol and any valid column name.")
			ok
		ok

		cResult = This.ColName(p)
		return cResult

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

		nLen = ring_len(paCols)
		acResult = []

		for i = 1 to nLen
			acResult + This.ColToColName(paCols[i])
		next

		return acResult

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

			if StzFind([ :First, :FirstCol, :FirstColumn ], p) > 0
				p = 1

			but StzFind([ :Last, :LastCol, :LastColumn ], p) > 0
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

		nResult = p
		return nResult

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

		nLen = ring_len(paCols)
		anResult = []

		for i = 1 to nLen
			anResult + This.ColToColNumber(paCols[i])
		next

		return anResult

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

		nLen = ring_len(paRows)
		aResult = []

		for i = 1 to nLen
			aResult + This.RowToNumber(paRows[i])
		next

		return aResult

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
				n = This.ColToColNumber(pacColNames)
				return '( This.Cell(' + n + ', j) )'
			else
				return pacColNames
			ok
		ok

		nLen = ring_len(pacColNames)
		acColNames = []

		if Q(pacColNames).IsListOfStrings()
			for i = 1 to nLen
				acColNames + [ pacColNames[i], [ "" ] ]
			next

		else // IsHashList()
			for i = 1 to nLen
				acColNames + [ pacColNames[i][1], [ "" ] ]
			next
		ok

		This.AddCols(acColNames)
		This.RemoveCol(1)

		aRow = []
		for i = 1 to nLen
			aRow + ""
		next

		This.AddRow(aRow)

	  #==============================#
	 #  ADDING A CALCULATED COLUMN  #
	#==============================#

	def InsertCalculatedCol(n, pcColName, pcFormula)
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

		aColData = []
		nCols = This.NumberOfCols()
		nRows = This.NumberOfRows()

		# Preparing the formula expression

		oForumla = new stzString(pcFormula)
		for i = 1 to nCols
			oForumla.ReplaceCS( ('@(:'+ This.ColName(i)+')'), 'This.Cell(' + i + ', i)', 0)
		next

		pcFormula = oForumla.Content()
		cCode = "value = " + pcFormula

		@NumberOfRows = nRows
		@NumberOfCols = nCols
		@NumberOfColumns = nCols

		for i = 1 to nRows
			eval(cCode)
			aColData + value

		next

		aContent = @aContent
		aContent = ring_insert(aContent, n, [ pcColName, aColData ])
		This.UpdateWith(aContent)
		@anCalculatedCols + n

		#< @FunctionAlternativeForms

		def InsertCalculatedColAt(n, pcColName, pcFormula)
			This.InsertCalculatedCol(n, pcColName, pcFormula)

		def InsertCalculatedColumn(n, pcColName, pcFormula)
			This.InsertCalculatedCol(n, pcColName, pcFormula)

		def InsertCalculatedColumnAt(n, pcColName, pcFormula)
			This.InsertCalculatedCol(n, pcColName, pcFormula)

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
		anResult = new stzList(@anCalculatedCols).Sorted()
		return anResult

		def FindCalculatedColumns()
			return This.FindcalculatedCols()

	  #--------------------------------------------------#
	 #  GETTING THE CONTENT OF THE CALCULATED COLUMNS  #
	#-------------------------------------------------#

	def CalculatedCols()
		anPos = This.FindCalculatedCols()
		aResult = This.TheseCols(anPos)
		return aResult

		def CalculatedColumns()
			return This.CalculatedCols()

	  #-----------------------------------------------#
	 #  GETTING THE NAMES OF THE CALCULATED COLUMNS  #
	#-----------------------------------------------#

	def CalculatedColNames()
		anPos = This.FindCalculatedCols()
		acResult = This.TheseColNames(anPos)
		return acResult

		def CalculatedColsNams()
			return This.CalculatedColNames()

		def CalculatedColumnNams()
			return This.CalculatedColNames()

		def CalculatedColumnsNams()
			return This.CalculatedColNames()

	  #===========================#
	 #  ADDING A CALCULATED ROW  #
	#===========================#

	def InsertCalculatedRow(n, pacFormulas)
		if CheckingParams()
			if NOT ( isList(pacFormulas) and @IsListOfStrings(pacFormulas) )
				StzRaise("Incorrect param type! pacFormulas must be a list of strings.")
			ok
		ok

		aRowData = []
		nLen = ring_len(pacFormulas)
		nCols = This.NumberOfCols()
		nRows = This.NumberOfRows()
		nMin = @Min([ nRows, nLen ])

		# Preparing the list of formulas

		aoForumlas = StzListQ(pacFormulas).ToListOfStzStrings()
		acCodes = []
		for i = 1 to nMin
			cColName = This.ColName(i)
			aoForumlas[i].ReplaceCS( ('@(:'+ cColName +')'), 'This.Col(:' + cColName + ')', 0)
			cCode =  aoForumlas[i].Content()
			if cCode != ""
				cCode = 'value = ' + cCode
			ok
			acCodes + cCode
		next

		@NumberOfRows = nRows
		@NumberOfCols = nCols
		@NumberOfColumns = nCols

		for i = 1 to nMin
			if acCodes[i] != ""
				eval(acCodes[i])
				aRowData + value
			else
				aRowData + " "
			ok
		next

		if nMin < nCols
			for i = nMin+1 to nCols
				aRowData + ""
			next
		ok

		This.InsertRow(n, aRowData)
		@anCalculatedRows + n

	def AddCalculatedRow(pacFormulas)
		This.InsertCalculatedRow( This.NumberOfRows() + 1, pacFormulas)

	  #--------------------------------------------#
	 #  GETTING THE POSITIONS OF CALCULATED ROWS  #
	#--------------------------------------------#

	def FindCalculatedRows()
		anResult = new stzList( @anCalculatedRows ).Sorted()
		return anResult

	  #------------------------------------------#
	 #  GETTING THE CONTENT OF CALCULATED ROWS  #
	#------------------------------------------#

	def CalculatedRows()
		aResult = This.TheseRows(This.FindCalculatedRows())
		return aResult

	  #======================================================#
	 #  EXCEL-LIKE FUNCTIONS APPLIED TO A SECTION OF CELLS  #
	#=====================================================#

	def SUM(paCell1, paCell2)
		aCells = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(aCells)
			return 0
		ok

		nLen = ring_len(aCells)

		nResult = 0

		for i = 1 to nLen
			nResult += aCells[i]
		next

		return nResult

	def PRODUCT(paCell1, paCell2)
		aCells = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(aCells)
			return 0
		ok

		nLen = ring_len(aCells)

		nResult = 1

		for i = 1 to nLen
			nResult *= aCells[i]
		next

		return nResult

	def AVERAGE(paCell1, paCell2)
		aCells = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(aCells)
			return 0
		ok

		nLen = ring_len(aCells)

		nSum = 0

		for i = 1 to nLen
			nSum += aCells[i]
		next

		nResult = nSum / nLen
		return nResult

		def MEAN(paCell1, paCell2)
			return AVERAGE(paCell1, paCell2)

	def KOUNT(paCell1, paCell2)
		nResult = ring_len( This.CellsInSection(paCell1, paCell2) )
		return nResult

	def MAX(paCell1, paCell2)
		aCells = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(aCells)
			return 0
		ok

		nResult = @Max(aCells)

		return nResult

	def MIN(paCell1, paCell2)
		aCells = This.CellsInSection(paCell1, paCell2)

		if NOT @IsListOfNumbers(aCells)
			return 0
		ok

		nResult = @Min(aCells)

		return nResult

	  #==========================================================#
	 #  ENGINE-BACKED COLUMN AGGREGATION (whole-column, fast)    #
	#==========================================================#

	def SumCol(pCol)
		nCol = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableSumCol(@pEngine, nCol-1)

		def SumColumn(pCol)
			return This.SumCol(pCol)

	def AvgCol(pCol)
		nCol = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableAvgCol(@pEngine, nCol-1)

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
		nCol = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableMinCol(@pEngine, nCol-1)

		def MinColumn(pCol)
			return This.MinCol(pCol)

	def MaxCol(pCol)
		nCol = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableMaxCol(@pEngine, nCol-1)

		def MaxColumn(pCol)
			return This.MaxCol(pCol)

	def ProductCol(pCol)
		nCol = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableProductCol(@pEngine, nCol-1)

		def ProductColumn(pCol)
			return This.ProductCol(pCol)

	def CountNonNullInCol(pCol)
		nCol = This.ColToColNumber(pCol)
		This._EnsureEngine()
		return StzEngineTableCountNonNull(@pEngine, nCol-1)

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

		nLen = ring_len(paColValues)

		for i = 1 to nLen
            cColName = paColValues[i][1]

            # Check if column exists (case-insensitive)

            nColIndex = This.FindCol(cColName)
            if nColIndex = 0
                StzRaise("Column '" + cColName + "' not found in the table")
            ok
        next

        # Perform filtering

        nRows = This.NumberOfRows()
        aRowsToKeep = []

        for nRow = 1 to nRows
            bKeepRow = 1
			nLenValues = ring_len(paColValues)

			for v = 1 to nLenValues
                cColName = paColValues[v][1]
                aFilterValues = paColValues[v][2]

                # Get column index
                nColIndex = This.FindCol(cColName)

                # Get cell value
                cellValue = This.Cell(nColIndex, nRow)

                # Check if cell value matches filter conditions
                # Support both single value and list of values

                if isList(aFilterValues)

                    bValueMatches = 0
					nLenFilterValues = ring_len(aFilterValues)

					for j = 1 to nLenFilterValues

                        if cellValue = aFilterValues[j]
                            bValueMatches = 1
                            exit
                        ok

					next

                else
                    bValueMatches = (cellValue = aFilterValues)
                ok

                # If any condition fails, exclude the row
                if NOT bValueMatches
                    bKeepRow = 0
                    exit
                ok
            next

            if bKeepRow
                aRowsToKeep + This.Row(nRow)
            ok
        next

        # Rebuild the table with filtered rows

        aResult = []

        # Recreate columns with filtered data

        nCols = This.NumberOfCols()

        for nCol = 1 to nCols
            cColName = This.ColName(nCol)
            colData = []

			nLenRowsToKeep = ring_len(aRowsToKeep)
            for nRow = 1 to nLenRowsToKeep
                colData + aRowsToKeep[nRow][nCol]
            next

            aResult + [cColName, colData]
        next

        @aContent = aResult

    #< @FunctionFluentForm

    def FilterQ(paColValues)
        This.Filter(paColValues)
        return This

	def FilterCQ(paColValues)
			oCopy = This.Copy()
			oCopy.Filter(paColValues)
			return oCopy
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

		oCondition = new stzString(pcCondition)
		if oCondition.NumberOfOccurrence('@(') > 1
			This.FilterWXT(pcCondition)
			return
		ok

		# Prepare the condition expression

		nCols = This.NumberOfCols()

		for i = 1 to nCols
			cColName = This.ColName(i)
			oCondition.ReplaceCS('@(:' + cColName + ')', 'This.Cell(' + i + ', nRow)', 0)
		next

		cCondition = oCondition.Content()

		# Prepare evaluation code
		cCode = "bResult = " + cCondition

		# Perform filtering
		nRows = This.NumberOfRows()
		aRowsToKeep = []

		for nRow = 1 to nRows
			# Evaluate the condition for the current row
			eval(cCode)
			if bResult
				aRowsToKeep + This.Row(nRow)
			ok
		next
		nLenRowsToKeep = ring_len(aRowsToKeep)

		# Rebuild the table with filtered rows
		aResult = []
		nCols = This.NumberOfCols()

		for nCol = 1 to nCols

			cColName = This.ColName(nCol)
			colData = []


			for nRow = 1 to nLenRowsToKeep
				colData + aRowsToKeep[nRow][nCol]
			next

			aResult + [cColName, colData]

		next

		@aContent = aResult

		#< @FunctionFluentForm

		def FilterWQ(pcCondition)
			This.FilterW(pcCondition)
			return This

		def FilterWCQ(pcCondition)
			oCopy = This.Copy()
			oCopy.FilterW(pcCondition)
			return oCopy

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

		oConditionTemp = new stzString(pcCondition)
		acColNames = This.ColNames()
		nLenCols = ring_len(acColNames)

		for i = 1 to nLenCols

			if oConditionTemp.ContainsCS('@(:' + acColNames[i] + ')', 0)
				if NOT This.IsColName(acColNames[i])
					StzRaise("Invalid column name! The column '@(:" + acColNames[i] + ")' does not exist in the table.")
				ok
			ok

		next

		# Prepare the condition expression

		oCondition = new stzString(pcCondition)
		nCols = This.NumberOfCols()

		for i = 1 to nCols
			cColName = This.ColName(i)
			oCondition.ReplaceCS('@(:' + cColName + ')', 'This.Cell(' + i + ', nRow)', 0)
		next

		cCondition = oCondition.Content()

		# Verify that no '@(:...)' patterns remain

		if Q(cCondition).Contains('@(:')
			StzRaise("Invalid condition! Unresolved column reference found in: " + cCondition)
		ok

		# Prepare evaluation code

		cCode = "bOk = " + cCondition

		# Perform filtering

		nRows = This.NumberOfRows()
		aRowsToKeep = []

		for nRow = 1 to nRows
			try
				eval(cCode)
				if bOk
					aRowsToKeep + This.Row(nRow)
				ok
			catch
				StzRaise("Error evaluating condition: " + cCondition + " at row " + nRow)
			done
		next

		# Rebuild the table with filtered rows

		aResult = []
		nCols = This.NumberOfCols()

		for nCol = 1 to nCols

			cColName = This.ColName(nCol)
			colData = []
			nLenRowsToKeep = ring_len(aRowsToKeep)

			for nRow = 1 to nLenRowsToKeep
				colData + aRowsToKeep[nRow][nCol]
			next

			aResult + [cColName, colData]

		next

		@aContent = aResult

		#< @FunctionFluentForm

		def FilterWXTQ(pcCondition)
			This.FilterWXT(pcCondition)
			return This

		def FilterWXTCQ(pcCondition)
			oCopy = This.Copy()
			oCopy.FilterWXT(pcCondition)
			return oCopy

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
		aValidMethods = [
			:Sum,
			:Average,
			:Count,
			:Max,
			:Min,
			:First,
			:Last
		]

		# Validate and process aggregations
		aProcessedAggs = []
		nLen = ring_len(paAggregations)

		for i = 1 to nLen
			cColName = paAggregations[i][1]
			cAggMethod = StzLower(paAggregations[i][2])

			# Validate column existence
			nColIndex = This.FindCol(cColName)
			if nColIndex = 0
				StzRaise("Column '" + cColName + "' not found in the table")
			ok

			# Validate aggregation method
			if StzFind(aValidMethods, cAggMethod) = 0
				StzRaise("Invalid aggregation method: " + cAggMethod)
			ok

			aProcessedAggs + [cColName, cAggMethod]
		next

		# Perform aggregation
		aResult = []

		# Add columns for aggregation results
		nLen = ring_len(aProcessedAggs)

		for i = 1 to nLen
			cColName = aProcessedAggs[i][1]
			cAggMethod = aProcessedAggs[i][2]

			# Create aggregated column name
			cAggColName = cAggMethod + "(" + cColName + ")"

			# Perform aggregation
			nColIndex = This.FindCol(cColName)
			aColData = This.Col(nColIndex)
			nLenData = ring_len(aColData)

			nResult = 0

			switch cAggMethod

			on :Sum

				for v = 1 to nLenData
					nResult += aColData[v]
				next

			on :Average

				nSum = 0

				for v = 1 to nLenData
					nSum += aColData[v]
				next

				nResult = nSum / nLenData

			on :Count
				nResult = nLenData

			on :Max

				nResult = aColData[1]

				for v = 2 to nLenData
					if aColData[v] > nResult
						nResult = aColData[v]
					ok
				next

			on :Min

				nResult = aColData[1]

				for v = 2 to nLenData
					if aColData[v] < nResult
						nResult = aColData[v]
					ok
				next

			on :First
				nResult = aColData[1]

			on :Last
				nResult = aColData[nLenData]
			off

			# Add aggregated column
			aResult + [ cAggColName, [nResult] ]

		next

		@aContent = aResult

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

			aTemp = [] + paCols
			paCols = aTemp
		ok

		# Validate input is a list of column names
		if NOT (isList(paCols) and ring_len(paCols) > 0)
			StzRaise("GroupBy requires a non-empty list of column names")
		ok

		# Validate column existence
		nLen = ring_len(paCols)
		for i = 1 to nLen
			if This.FindCol(paCols[i]) = 0
				StzRaise("Column '" + paCols[i] + "' not found in the table")
			ok
		next

		# Prepare to group rows
		nRows = This.NumberOfRows()
		aGroupedRows = []
		aGroupKeys = []
		aUniqueGroups = []

		# Iterate through rows to create groups
		nLenCols = ring_len(paCols)
		for nRow = 1 to nRows
			# Create group key from specified columns
			aGroupKey = []
			for i = 1 to nLenCols
				nColIndex = This.FindCol(paCols[i])
				aGroupKey + This.Cell(nColIndex, nRow)
			next

			# Convert group key to string for easy comparison
			cGroupKey = ""
			_nGroupKeyLen_ = ring_len(aGroupKey)
			for i = 1 to _nGroupKeyLen_
				cGroupKey += ""+ aGroupKey[i] + '|'
			next

			# Check if this group key exists
			nGroupIndex = StzFind(aGroupKeys, cGroupKey)
			if nGroupIndex = 0
				# New group, add to groups
				aGroupKeys + cGroupKey
				aUniqueGroups + aGroupKey
				aGroupedRows + [ This.Row(nRow) ]
			else
				# Existing group, append row
				aGroupedRows[nGroupIndex] + This.Row(nRow)
			ok
		next

		# Build result table structure
		aResult = []
		acColNames = This.ColNames()

		# Add all columns to result
		_nColNamesLen_3 = ring_len(acColNames)
		for i = 1 to _nColNamesLen_3
			aResult + [ acColNames[i], [] ]
		next

		# Add rows from each group to result
		nLenGroups = ring_len(aUniqueGroups)
		for i = 1 to nLenGroups
			aRows = aGroupedRows[i]
			_nRowsLen_ = ring_len(aRows)
			for j = 1 to _nRowsLen_
				aRow = aRows[j]
				# Add each value to its column
				_nRowLen_ = ring_len(aRow)
				for k = 1 to _nRowLen_
					aResult[k][2] + aRow[k]
				next
			next
		next

		@aContent = aResult


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

		if NOT (isList(paCols) and ring_len(paCols) > 0)
			StzRaise("GroupBy requires a non-empty list of column names")
		ok

		# Validate column existence

		nLen = ring_len(paCols)

		for i = 1 to nLen
			if This.FindCol(paCols[i]) = 0
				StzRaise("Column '" + paCols[i] + "' not found in the table")
			ok
		next

		# Validate aggregation input

		if NOT (isList(paAggregations) and @IsListOfPairsOfStrings(paAggregations))
				StzRaise("Aggregations must be a hash list of [column, method] pairs")
		ok

		# Default aggregation if none provided: First value for non-grouped columns

		nLenAgg = ring_len(paAggregations)

		if nLenAgg = 0

			acColNames = This.ColNames()

			for i = 1 to nLenAgg

				if NOT StzFind(paCols, acColNames[i]) > 0
					paAggregations + [cColName, :First]
				ok

			next
		else

		# Lowercase all the aggregation functions

		for i = 1 to nLenAgg
			paAggregations[i][2] = StzLower(paAggregations[i][2])
		next

		# Valid aggregation methods

		aValidMethods = [ :Sum, :Average, :Count, :Max, :Min, :First, :Last ]

		for i = 1 to nLenAgg

			cColName = paAggregations[i][1]
			cAggMethod = paAggregations[i][2]

			# Validate column exists

			if This.FindCol(cColName) = 0
				StzRaise("Column '" + cColName + "' not found in the table")
			ok

			# Validate method is supported

			if NOT StzFind(aValidMethods, cAggMethod)
				StzRaise("Invalid aggregation method: " + cAggMethod)
			ok

			# Validate column is not in grouping columns

			if StzFind(paCols, cColName) > 0
				StzRaise("Cannot aggregate grouping column: " + cColName)
			ok

		next
	ok

	# Prepare to group rows

	nRows = This.NumberOfRows()
	aGroupedRows = []
	aGroupKeys = []
	aUniqueGroups = []

	# Iterate through rows to create groups

	nLenCols = ring_len(paCols)

	for nRow = 1 to nRows

		# Create group key from specified columns

		aGroupKey = []

		for i = 1 to nLenCols
			nColIndex = This.FindCol(paCols[i])
			aGroupKey + This.Cell(nColIndex, nRow)
		next
		nLenKeys = ring_len(aGroupKey)

		# Convert group key to string for easy comparison

		cGroupKey = ""

		for i = 1 to nLenKeys
			cGroupKey += ""+ aGroupKey[i] + '|'
		next

		# Check if this group key exists

		nGroupIndex = StzFind(aGroupKeys, cGroupKey)

		if nGroupIndex = 0

			# New group, add to groups

			aGroupKeys + cGroupKey
			aUniqueGroups + aGroupKey
			aGroupRows = [ This.Row(nRow) ]
			aGroupedRows + aGroupRows

		else
			# Existing group, append row
			aGroupedRows[nGroupIndex] + This.Row(nRow)
		ok
	next

	# Build result table structure

	aResult = []

	# Add grouping columns first

	for i = 1 to nLenCols
		aResult + [ paCols[i], [] ]
	next

	# Process aggregations and add aggregated columns

	for i = 1 to nLenAgg
		cColName = paAggregations[i][1]
		cAggMethod = paAggregations[i][2]
		cAggColName = cAggMethod + "(" + cColName + ")"
		aResult + [ cAggColName, [] ]
	next

	# Perform aggregations for each group

	nLenGroups = ring_len(aUniqueGroups)

	for i = 1 to nLenGroups

		aGroupKey = aUniqueGroups[i]
		aRows = aGroupedRows[i]
		nLenRows = ring_len(aRows)

		# Add group key values to result

		for j = 1 to nLenCols
			aResult[j][2] + aGroupKey[j]
		next

		# Calculate aggregations for this group

		nColOffset = nLenCols + 1

		for j = 1 to nLenAgg

			cColName = paAggregations[j][1]
			cAggMethod = paAggregations[j][2]
			nColIndex = This.FindCol(cColName)

			# Extract values for this column from group rows

			aValues = []

			for r = 1 to nLenRows
				aValues + aRows[r][nColIndex]
			next

			# Apply aggregation method

			nResult = NULL
			nLenVal = ring_len(aValues)

			switch cAggMethod

				on :Sum

					nResult = 0

					for v = 1 to nLenVal
						nResult += aValues[v]
					next

				on :Average

						nSum = 0

						for v = 1 to nLenVal
							nSum += aValues[v]
						next

						nResult = nSum / nLenVal

				on :Count
					nResult = nLenVal

				on :Max
					nResult = aValues[1]

					for v = 2 to nLenVal
						if aValues[v] > nResult
							nResult = aValues[v]
						ok
					next

				on :Min
					nResult = aValues[1]

					for v = 2 to nLenVal
						if aValues[v] < nResult
							nResult = aValues[v]
						ok
					next

				on :First
					nResult = aValues[1]

				on :Last
					nResult = aValues[nLenVal]
				off

				# Add result to output

				aResult[nColOffset][2] + nResult
				nColOffset++

			next

		next

		@aContent = aResult


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
			aTemp = [] + paCols
			paCols = aTemp
		ok
	    # Validate input is a list of column names
	    if NOT (isList(paCols) and ring_len(paCols) > 0)
	        StzRaise("GroupByListItems requires a non-empty list of column names")
	    ok

	    # Validate column existence
	    nLen = ring_len(paCols)
	    for i = 1 to nLen
	        if This.FindCol(paCols[i]) = 0
	            StzRaise("Column '" + paCols[i] + "' not found in the table")
	        ok
	    next

	    # Get the lists column we're grouping by
	    cListColumn = paCols[1]  # Use the first column as the list column
	    nListColIndex = This.FindCol(cListColumn)

	    # Prepare to collect unique hobby values and associated rows
	    nRows = This.NumberOfRows()
	    aHobbyMap = []  # Will be a list of [hobby, [row1, row2, ...]] pairs

	    # Process each row and collect unique hobby values
	    for nRow = 1 to nRows
	        vCellValue = This.Cell(nListColIndex, nRow)

	        # Skip if not a list
	        if NOT isList(vCellValue)
	            loop
	        ok

	        # Process each hobby in the list
	        _nVCellValueLen_ = ring_len(vCellValue)
	        for j = 1 to _nVCellValueLen_
	            cHobby = vCellValue[j]

	            # Find this hobby in our map
	            nHobbyIndex = 0
	            _nHobbyMapLen_2 = ring_len(aHobbyMap)
	            for k = 1 to _nHobbyMapLen_2
	                if aHobbyMap[k][1] = cHobby
	                    nHobbyIndex = k
	                    exit
	                ok
	            next

	            if nHobbyIndex = 0
	                # New hobby, add it with this row
	                aHobbyMap + [cHobby, [nRow]]
	            else
	                # Existing hobby, check if row already exists
	                bFound = FALSE
	                _nHobbyMapnHobbyIndex2Len_ = ring_len(aHobbyMap[nHobbyIndex][2])
	                for r = 1 to _nHobbyMapnHobbyIndex2Len_
	                    if aHobbyMap[nHobbyIndex][2][r] = nRow
	                        bFound = TRUE
	                        exit
	                    ok
	                next

	                # Add row if not found
	                if NOT bFound
	                    aHobbyMap[nHobbyIndex][2] + nRow
	                ok
	            ok
	        next
	    next

	    # Build the new table structure with hobbies as the first column
	    aNewColumns = [cListColumn]
	    acColNames = This.ColNames()

	    # Add all other columns except the list column
	    _nColNamesLen_2 = ring_len(acColNames)
	    for i = 1 to _nColNamesLen_2
	        if acColNames[i] != cListColumn
	            aNewColumns + acColNames[i]
	        ok
	    next

	    # Create the result table structure
	    aResult = []
	    _nNewColumnsLen_ = ring_len(aNewColumns)
	    for i = 1 to _nNewColumnsLen_
	        aResult + [aNewColumns[i], []]
	    next

	    # Fill in the data for each hobby group
	    _nHobbyMapLen_ = ring_len(aHobbyMap)
	    for i = 1 to _nHobbyMapLen_
	        cHobby = aHobbyMap[i][1]
	        aRowIndices = aHobbyMap[i][2]

	        # For each row that has this hobby
	        _nRowIndicesLen_ = ring_len(aRowIndices)
	        for j = 1 to _nRowIndicesLen_
	            nRowIndex = aRowIndices[j]

	            # Add the hobby as the first column value
	            aResult[1][2] + cHobby

	            # Add all other columns from the original row
	            nColOffset = 2  # Start from second column
	            _nColNamesLen_ = ring_len(acColNames)
	            for k = 1 to _nColNamesLen_
	                if acColNames[k] != cListColumn
	                    nColIndex = This.FindCol(acColNames[k])
	                    aResult[nColOffset][2] + This.Cell(nColIndex, nRowIndex)
	                    nColOffset++
	                ok
	            next
	        next
	    next

	    @aContent = aResult
